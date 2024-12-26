#include "Z3.hpp"

using namespace Z3;

Z3::generator::generator(const constraint::optimization_tree &tree, double bound_to_prove) : tree(tree), num_players(tree.num_players), bound_to_prove(bound_to_prove)
{
}

string Z3::generator::gen_code(string_view file) const
{
	auto [alias_decl, alias_in_exist] = gen_alias_and_param();
	auto opt_mix_func = gen_opt_mix_func();
	auto constraints = gen_constraints();
	auto [opt_mix_bounds_decl, opt_mix_bounds_in_fun_call] =
		gen_opt_mix_bounds();

	auto approx_bound_constraint = gen_approx_bound_constraint(opt_mix_bounds_in_fun_call, alias_in_exist);

	auto preamble = format("# Z3 code generated from {}\n", file) +
					R"(from z3 import ArithRef, If, Solver, Real, sat, unsat, z3, Exists, And
from functools import reduce

z3.set_param("proof", True) # need to give the proof

# predefined functions

# find the maximum of a list of arithmetic expressions
def max_list(nums: list[ArithRef]):
	def max2(a, b):
		return If(a > b, a, b)
	return reduce(max2, nums)

# find the minimum of a list of arithmetic expressions
def min_list(nums: list[ArithRef]):
	def min2(a, b):
		return If(a < b, a, b)
	return reduce(min2, nums)

# piecewise expressions
def piecewise(cases):
    """
    Implements a piecewise function in Z3.
    
    Args:
        cases: A list of (condition, value) pairs.
              The last condition can be True to represent the default case.
    
    Returns:
        A Z3 expression representing the piecewise function.
        
    Example:
        x = Real('x')
        f = piecewise([
            (x * x,     x < 0),
            (x,         x < 1),
            (2 * x + 1, True)
        ])
    """
    if not cases:
        raise ValueError("cases cannot be empty")
    
    *cases_before_last, last_case = cases
    result = last_case[0]  # start with the value of the last case
    
    # build If expressions from back to front
    for value, condition in reversed(cases_before_last):
        result = If(condition, value, result)
    
    return result)" +
					format("\n\n{} = Solver()\n", solver_name) + format("\n{} = []\n", constraint_name);

	auto postamble = format("check_ret = {}.check()\n"
							"if check_ret == unsat:\n"
							"\tprint(\"The given algorithm is proven to have approximation bound {}. The proof is as follows.\")\n"
							"\tprint({}.proof())\n"
							"elif check_ret == sat:\n"
							"\tprint(\"Possible counterexample are found when proving approximation bound {} for the given algorithm.\")\n"
							"\tprint({}.model())\n"
							"else:\n"
							"\tprint(\"Z3 solver failed to work.\")\n",
							solver_name, bound_to_prove, solver_name, bound_to_prove, solver_name);

	return format("{}\n# name alias and parameters\n{}\n"
				  "# constraint for optimal mixing operation\n{}\n{}\n"
				  "# constraints\n{}\n"
				  "# constraints for approximation bounds\n{}\n"
				  "# solve the SMT problem\n{}\n",
				  preamble, alias_decl, opt_mix_func, opt_mix_bounds_decl, constraints, approx_bound_constraint, postamble);
}

tuple<string, string> Z3::generator::gen_alias_and_param() const
{
	string alias_decl, alias_in_exist;
	alias_in_exist = "[";
	for (const auto &[name, alias] : tree.name_alias)
	{
		for (auto i = 1; i <= num_players; i++)
		{
			alias_decl += format("{}_U{} = Real('{}_U{}')\t# U{}{}\n", alias, i, alias, i, i, name);
			alias_decl += format("{}_f{} = Real('{}_f{}')\t# f{}{}\n", alias, i, alias, i, i, name);
			alias_in_exist += format("{}_U{}, ", alias, i);
			alias_in_exist += format("{}_f{}, ", alias, i);
		}
	}
	for (const auto &param : tree.params)
	{
		alias_decl += format("{} = Real('{}') # param {}\n", param, param, param);
		alias_in_exist += format("{}, ", param);
	}
	alias_in_exist.pop_back();
	alias_in_exist.pop_back();
	alias_in_exist.push_back(']');
	return {alias_decl, alias_in_exist};
}

// generate the intersection point of two lines and a1-b1, a2-b2, and its
// condition
static tuple<string, string> gen_intersect_point(string_view a1,
												 string_view a2, string_view b1, string_view b2)
{
	return {format("({} - {}) / ({} + {} - {} - {})", a2, a1,
				   a1, b2, a2, b1),
			format("((({} > {}) & ({} < {})) | (({} < {}) & ({} > {})))", a1, b1, a2, b2,
				   a1, b1, a2, b2)};
}

// generate the intersection of two lines and a1-b1, a2-b2 and evaluate at f
// values
static tuple<string, string> gen_intersect(string_view a1, string_view a2,
										   string_view b1, string_view b2, int num_players)
{
	auto [v, c] = gen_intersect_point(a1, a2, b1, b2);
	string ret_v = "max_list([";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret_v += ", ";
		ret_v += format("(1 - {}) * vara{} + {} * varb{}", v, i, v, i);
	}
	ret_v += "])";
	return {ret_v, c};
}

// the default minimum: the minimum over two endpoints a,b, a series of maximum
static string gen_default_min(int num_players)
{
	string ret = "min_list([max_list([";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("vara{}", i);
	}
	ret += "]), max_list([";
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("varb{}", i);
	}
	ret += "])])";
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
			  [](const auto &a, const auto &b)
			  { return a.size() > b.size(); });
	return ret;
}

string Z3::generator::gen_opt_mix_func() const
{
	auto ret = format("def {}(", opt_mix_func_name);
	// function args
	for (auto i = 1; i <= num_players; i++)
	{
		if (i != 1)
			ret += ", ";
		ret += format("vara{}, varb{}", i, i);
	}
	ret += "):\n\treturn piecewise([\n";
	// generate all pair sets
	auto pair_sets = generate_all_pair_sets(num_players);
	for (auto &pair_set : pair_sets)
	{
		if (pair_set.empty())
			continue;
		ret += "\t\t(";
		// generate the intersection of two lines from pair_set
		string val = "min_list([";
		string condition;
		for (auto [i, j] : pair_set)
		{
			auto [v, c] =
				gen_intersect(format("vara{}", i), format("vara{}", j),
							  format("varb{}", i), format("varb{}", j), num_players);
			val += format("{}, ", v);
			condition += format(" {} &", c);
		}
		val.pop_back();
		val.pop_back();
		val += "])";
		condition.pop_back();
		condition.pop_back();
		ret += format("{},{}),\n", val, condition);
	}
	ret.pop_back();
	ret.pop_back();
	// add default value
	ret += format(",({}, True)])\n", gen_default_min(num_players));
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
		if (depth == num_players)
		{
			combinations.push_back(current);
			return;
		}
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
				pairs.push_back(std::make_tuple(*iter, *iter2));
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

tuple<string, string> Z3::generator::gen_opt_mix_bounds() const
{
	auto all_pair_combinations =
		gen_all_opt_mix_pairs(num_players, tree.player_strategies);
	string ret_decl, ret_in_fun_call = "";
	if (all_pair_combinations.size() > 1)
	{
		ret_in_fun_call = "min_list([";
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
		auto ret_decl_code = format("{}{} = {}(", opt_mix_bound_prefix, count,
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
		ret_decl_code += ")";
		auto ret_decl_comment =
			format("# {} -- {}\n", endpoint_a, endpoint_b);
		maximum_length = std::max(maximum_length, ret_decl_code.size());
		codes.push_back(ret_decl_code);
		comments.push_back(ret_decl_comment);
	}
	ret_in_fun_call.pop_back();
	ret_in_fun_call.pop_back();
	if (all_pair_combinations.size() > 1)
	{
		ret_in_fun_call += "])";
	}
	for (size_t i = 0; i < codes.size(); i++)
	{
		ret_decl +=
			format("{:<{}s}\t{}\n", codes[i], maximum_length, comments[i]);
	}
	return {ret_decl, ret_in_fun_call};
}

string Z3::generator::gen_constraints() const
{
	auto ret = string();
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
		ret += format("{}.append({:<{}s})  # {}\n", constraint_name, constraints[i],
					  maximum_length, constraints_comments[i]);
	}
	return ret;
}

string Z3::generator::gen_approx_bound_constraint(string_view bound_exp, string_view alias_in_exist) const
{
	return format("final_bound_exp = {}\n"
				  "{}.append(final_bound_exp > {})\n"
				  "# the negation of the bound\n"
				  "neg_theorem = Exists({}, And({}))\n"
				  "{}.add(neg_theorem)\n",
				  bound_exp, constraint_name, bound_to_prove, alias_in_exist, constraint_name, solver_name);
}
