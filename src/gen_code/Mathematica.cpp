#include "mathematica.hpp"

using namespace mathematica;

mathematica::generator::generator(const constraint::optimization_tree &tree) :
	tree(tree), num_players(tree.num_players)
{
}

string mathematica::generator::gen_code(const string &file) const
{
	auto [alias_decl, alias_in_fun_call] = gen_alias_and_param();
	auto opt_mix_func = gen_opt_mix_func();
	auto constraints = gen_constraints();
	auto [opt_mix_bounds_decl, opt_mix_bounds_in_fun_call] =
		gen_opt_mix_bounds();
	return format("(* Mathematica code generated from {} *)\n\n(* name alias "
				  "and parameters *)\n{}\n(* constraint for optimal mixing "
				  "operation *)\n{}\n{}\n(* constraints *)\n{}\n(* solve the "
				  "approximation bound *)\nNMaximize[{{{}, {}}}, {{{}}}, {}]",
		file, alias_decl, opt_mix_func, opt_mix_bounds_decl, constraints,
		opt_mix_bounds_in_fun_call, constraint_name, alias_in_fun_call,
		optimization_extra_param);
}

tuple<string, string> mathematica::generator::gen_alias_and_param() const
{
	string alias_decl, alias_in_fun_call;
	for (const auto &[name, alias] : tree.name_alias)
	{
		for (auto i = 1; i <= num_players; i++)
		{
			alias_decl += format("{}_U{};\t(* U{}{} *)\n", alias, i, i, name);
			alias_decl += format("{}_f{};\t(* f{}{} *)\n", alias, i, i, name);
			alias_in_fun_call += format("{}_U{}, ", alias, i);
			alias_in_fun_call += format("{}_f{}, ", alias, i);
		}
	}
	for (const auto &param : tree.params)
	{
		alias_decl += format("{};\t(* param {} *)\n", param, param);
		alias_in_fun_call += format("{}, ", param);
	}
	alias_in_fun_call.pop_back();
	alias_in_fun_call.pop_back();

	return {alias_decl, alias_in_fun_call};
}

// generate the intersection point of two lines and a1-b1, a2-b2, and its
// condition
static tuple<string, string> gen_intersect_point(const string &a1,
	const string &a2, const string &b1, const string &b2)
{
	return {format("({} * {} - {} * {}) / ({} + {} - {} - {})", a1, b2, a2, b1,
				a1, b2, a2, b1),
		format("(({} > {} && {} < {}) || ({} < {} && {} > {}))", a1, b1, a2, b2,
			a1, b1, a2, b2)};
}

// generate the intersection of two lines and a1-b1, a2-b2 and evaluate at f
// values
static tuple<string, string> gen_intersect(const string &a1, const string &a2,
	const string &b1, const string &b2, int num_players)
{
	auto [v, c] = gen_intersect_point(a1, a2, b1, b2);
	string ret_v = "Max[";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret_v += ", ";
		ret_v += format("(1 - {}) * vara{} + {} * varb{}", v, i, v, i);
	}
	ret_v += "]";
	return {ret_v, c};
}

// the default minimum: the minimum over two endpoints a,b, a series of maximum
static string gen_default_min(int num_players)
{
	string ret = "Min[Max[";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("vara{}", i);
	}
	ret += "], Max[";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("varb{}", i);
	}
	ret += "]]";
	return ret;
}

static auto generate_all_pair_sets(int num_players)
{
	vector<tuple<int, int>> pair_sets;
	for (auto i = 1; i <= num_players; i++)
	{
		for (auto j = i + 1; j <= num_players; j++)
		{
			pair_sets.emplace_back(i, j);
		}
	}
	auto subset_count = 1 << pair_sets.size();
	vector<vector<tuple<int, int>>> ret(subset_count);
	for (auto i = 0; i < subset_count; i++)
	{
		for (auto j = 0; j < pair_sets.size(); j++)
		{
			if (i & (1 << j))
			{
				ret[i].push_back(pair_sets[j]);
			}
		}
	}
	std::sort(ret.begin(), ret.end(),
		[](const auto &a, const auto &b) { return a.size() > b.size(); });
	return ret;
}

string mathematica::generator::gen_opt_mix_func() const
{
	auto ret = opt_mix_func_name + "[";
	// function args
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("vara{}_, varb{}_", i, i);
	}
	ret += "] := Piecewise[{\n";
	// generate all pair sets
	auto pair_sets = generate_all_pair_sets(num_players);
	for (auto &pair_set : pair_sets)
	{
		if (pair_set.empty())
			continue;
		ret += "\t{ ";
		// generate the intersection of two lines from pair_set
		auto val = format("Min[{}", gen_default_min(num_players));
		string condition;
		for (auto [i, j] : pair_set)
		{
			auto [v, c] = gen_intersect(format("vara{}", i),
				format("vara{}", j), format("varb{}", i), format("varb{}", j), num_players);
			val += format(", {}", v);
			condition += format(" {} &&", c);
		}
		val += "]";
		condition.pop_back();
		condition.pop_back();
		ret += format("{},{}}},\n", val, condition);
	}
	ret.pop_back();
	ret.pop_back();
	// add default value
	ret += format("}},\n\t{}];\n", gen_default_min(num_players));
	return ret;
}

static void gen_all_combinations_with_one_fix(int num_players,
	int fix_player_id,
	const unordered_map<int, unordered_set<string>> &player_strategies,
	vector<vector<string>> &combinations, vector<string> &current, int depth,
	vector<int> &player_indices)
{
	if (depth == num_players)
	{
		combinations.push_back(current);
		return;
	}
	if (player_indices[depth] == fix_player_id)
	{
		depth += 1; // skip the fixed player
	}
	for (const auto &strategy : player_strategies.at(player_indices[depth]))
	{
		current[depth] = strategy;
		gen_all_combinations_with_one_fix(num_players, fix_player_id,
			player_strategies, combinations, current, depth + 1,
			player_indices);
	}
}

static auto gen_all_opt_mix_pairs(int num_players,
	const unordered_map<int, unordered_set<string>> &player_strategies)
{
	vector<tuple<vector<string>, vector<string>>> ret;
	// generate all pairs of strategies for each player
	unordered_map<int, vector<tuple<string, string>>> strategy_pairs;
	for (auto i = 1; i <= num_players; i++)
	{
		vector<tuple<string, string>> pairs;
		for (auto iter = player_strategies.at(i).begin();
			 iter != player_strategies.at(i).end(); iter++)
		{
			auto iter2 = iter;
			++iter2;
			for (; iter2 != player_strategies.at(i).end(); iter2++)
			{
				pairs.push_back({*iter, *iter2});
			}
		}
		strategy_pairs[i] = pairs;
	}
	// generate all strategy combinations with one fixed player
	vector<int> player_indices(num_players);
	std::iota(player_indices.begin(), player_indices.end(), 1);
	for (auto fix_player_id = 1; fix_player_id <= num_players; fix_player_id++)
	{
		if (strategy_pairs[fix_player_id].empty()) // cannot form a pair
		{
			continue;
		}
		vector<vector<string>> combinations;
		vector<string> current(num_players);
		gen_all_combinations_with_one_fix(num_players, fix_player_id,
			player_strategies, combinations, current, 0, player_indices);
		for (const auto &combination : combinations)
		{
			for (const auto &[pair1, pair2] : strategy_pairs.at(fix_player_id))
			{
				auto ret_pair = make_tuple(combination, combination);
				std::get<0>(ret_pair)[fix_player_id - 1] = pair1;
				std::get<1>(ret_pair)[fix_player_id - 1] = pair2;
				ret.push_back(std::move(ret_pair));
			}
		}
	}
	return ret;
}

tuple<string, string> mathematica::generator::gen_opt_mix_bounds() const
{
	auto all_pair_combinations =
		gen_all_opt_mix_pairs(num_players, tree.player_strategies);
	string ret_decl, ret_in_fun_call = "";
	if (all_pair_combinations.size() > 1)
	{
		ret_in_fun_call = "Min[";
	}
	int count = 0;
	vector<string> codes;
	vector<string> comments;
	size_t maximum_length = 0;
	for (const auto &[pair1, pair2] : all_pair_combinations)
	{
		count += 1;
		auto endpoint_a = constraint::strategy_to_string(pair1);
		auto endpoint_a_alias = tree.name_alias.at(endpoint_a);
		auto endpoint_b = constraint::strategy_to_string(pair2);
		auto endpoint_b_alias = tree.name_alias.at(endpoint_b);
		ret_in_fun_call += format("{}{}, ", opt_mix_bound_prefix, count);
		auto ret_decl_code = format("{}{} = {}[", opt_mix_bound_prefix, count,
			opt_mix_func_name);
		for (auto i = 0; i < num_players; i++)
		{
			if (i != 0)
			{
				ret_decl_code += ", ";
			}
			ret_decl_code += format("{}_f{}, {}_f{}", endpoint_a_alias, i + 1,
				endpoint_b_alias, i + 1);
		}
		ret_decl_code += "];";
		auto ret_decl_comment =
			format("(* {} -- {} *)\n", endpoint_a, endpoint_b);
		maximum_length = std::max(maximum_length, ret_decl_code.size());
		codes.push_back(ret_decl_code);
		comments.push_back(ret_decl_comment);
	}
	ret_in_fun_call.pop_back();
	ret_in_fun_call.pop_back();
	if (all_pair_combinations.size() > 1)
	{
		ret_in_fun_call += "]";
	}
	for (size_t i = 0; i < codes.size(); i++)
	{
		ret_decl +=
			format("{:<{}s}\t{}\n", codes[i], maximum_length, comments[i]);
	}
	return {ret_decl, ret_in_fun_call};
}

string mathematica::generator::gen_constraints() const
{
	auto ret = format("{} = {{\n", constraint_name);
	vector<string> constraints;
	vector<string> constraints_comments;
	size_t maximum_length = 0;
	unordered_map<string, string> empty_alias;
	for (const auto &constraint : tree.constraints)
	{
		auto constraint_str = constraint->to_string(tree.name_alias);
		auto comment_str = constraint->to_string(empty_alias);
		maximum_length = std::max(maximum_length, constraint_str.size());
		constraints.push_back(constraint_str);
		constraints_comments.push_back(comment_str);
	}
	for (size_t i = 0; i < constraints.size(); i++)
	{
		if (i == constraints.size() - 1)
		{
			ret += format("\t{:<{}s}  (* {} *)\n}};\n", constraints[i],
				maximum_length, constraints_comments[i]);
		}
		else
		{
			ret += format("\t{:<{}s}  (* {} *)\n", constraints[i] + ",",
				maximum_length, constraints_comments[i]);
		}
	}
	return ret;
}
