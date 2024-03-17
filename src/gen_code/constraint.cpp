#include "constraint.hpp"
using namespace constraint;

unique_ptr<exp_node> constraint::num_exp_node::clone(
	const unordered_map<string, string> &instantiated_var) const
{
	return make_unique<num_exp_node>(value);
}

unique_ptr<exp_node> constraint::op_exp_node::clone(
	const unordered_map<string, string> &instantiated_var) const
{
	return make_unique<op_exp_node>(op, left->clone(instantiated_var),
		right->clone(instantiated_var));
}

string constraint::payoff_exp_node::strategy_to_string() const
{
	string result = format("({}", strategies.at(0));
	for (size_t i = 1; i < strategies.size(); i++)
	{
		result += format(",{}", strategies.at(i));
	}
	result += ")";
	return result;
}

unique_ptr<exp_node> constraint::payoff_exp_node::clone(
	const unordered_map<string, string> &instantiated_var) const
{
	vector<string> new_strategies;
	for (const auto &s : strategies)
	{
		if (instantiated_var.find(s) != instantiated_var.end())
		{
			new_strategies.push_back(instantiated_var.at(s));
		}
		else
		{
			new_strategies.push_back(s);
		}
	}
	auto new_payoff_name = payoff_name;
	if (instantiated_var.find(payoff_name) != instantiated_var.end())
	{
		new_payoff_name = instantiated_var.at(payoff_name);
	}
	return make_unique<payoff_exp_node>(new_payoff_name, new_strategies);
}

string constraint::f_val_exp_node::strategy_to_string() const
{
	string result = format("({}", strategies.at(0));
	for (size_t i = 1; i < strategies.size(); i++)
	{
		result += format(",{}", strategies.at(i));
	}
	result += ")";
	return result;
}

unique_ptr<exp_node> constraint::f_val_exp_node::clone(
	const unordered_map<string, string> &instantiated_var) const
{
	vector<string> new_strategies;
	for (const auto &s : strategies)
	{
		if (instantiated_var.find(s) != instantiated_var.end())
		{
			new_strategies.push_back(instantiated_var.at(s));
		}
		else
		{
			new_strategies.push_back(s);
		}
	}
	return make_unique<f_val_exp_node>(f_name, new_strategies);
}

unique_ptr<exp_node> constraint::param_exp_node::clone(
	const unordered_map<string, string> &instantiated_var) const
{
	return make_unique<param_exp_node>(param_name);
}

void constraint::optimization_tree::gen_tree(
	const legone::ast_root &ast)
{
	num_players = ast.num_players;
	// find all strategy names
	for (const auto &construct : ast.algo->constructs)
	{
		for (const auto &[name, type] : construct->rets)
		{
			auto int_type = static_cast<int>(type);
			if (player_strategies.find(int_type) == player_strategies.end())
			{
				player_strategies[int_type] = unordered_set<string>();
			}
			player_strategies[int_type].insert(name);
		}
	}
	// generate all name_alias
	gen_alias();
	// generate all constraints
	for (const auto &construct : ast.algo->constructs)
	{
		auto operation_name = construct->operation_name;
		const auto &operation = ast.operations.at(operation_name);
		for (const auto &constraint : operation->constraints)
		{
			auto quantified_constraint =
				constraint_node2constraint(constraint, operation, construct);
			// eliminate quantifiers
			deque<tuple<string, int>> quantifiers;
			for (const auto &[name, type] : constraint->quantifiers)
			{
				quantifiers.push_back({name, static_cast<int>(type)});
			}
			unordered_map<string, string> instantiated_var;
			quantifier_eliminate(quantified_constraint, quantifiers,
				instantiated_var);
			// also eliminate quantifiers but keep one
			auto num_quantifier = quantifiers.size();
			for (size_t i = 0; i < num_quantifier; i++)
			{
				auto [var, type] = quantifiers.front();
				quantifiers.pop_front();
				quantifiers.push_back({var, type});
				quantifier_eliminate_with_f(quantified_constraint, quantifiers,
					instantiated_var);
			}
		}
	}
}

static vector<string> generate_aliases(int n)
{
	vector<string> aliases;
	int count = 0;
	while (aliases.size() < n)
	{
		string alias;
		int temp = count;
		while (temp >= 0)
		{
			char letter = 'a' + temp % 26;
			alias = letter + alias;
			temp = temp / 26 - 1;
		}
		aliases.push_back(alias);
		++count;
	}
	return aliases;
}

void constraint::optimization_tree::generate_combinations(
	vector<vector<string>> &combinations, vector<string> &current, int depth,
	vector<int> &player_indices)
{
	if (depth == num_players)
	{
		combinations.push_back(current);
		return;
	}

	for (const auto &strategy : player_strategies[player_indices[depth]])
	{
		current[depth] = strategy;
		generate_combinations(combinations, current, depth + 1, player_indices);
	}
}

static string join(const vector<string> &vec, const string &delim)
{
	string result;
	for (size_t i = 0; i < vec.size(); ++i)
	{
		if (i > 0)
			result += delim;
		result += vec[i];
	}
	return result;
}

void constraint::optimization_tree::gen_alias()
{
	/*
		follow the order "a", "b", "c", ..., "z", "aa", "ab", ...
		generate for all (x1, x2, ...), where xk is the strategy name for player
		k from player_strategies
	*/
	int total_combinations = 1;
	for (const auto &p : player_strategies)
	{
		total_combinations *= p.second.size();
	}

	auto aliases = generate_aliases(total_combinations);
	vector<vector<string>> strategy_combinations;
	vector<string> current(num_players);
	vector<int> player_indices(num_players);
	std::iota(begin(player_indices), end(player_indices), 0);

	generate_combinations(strategy_combinations, current, 0, player_indices);

	for (size_t i = 0; i < strategy_combinations.size(); ++i)
	{
		string alias = aliases[i];
		name_alias["(" + join(strategy_combinations[i], ", ") + ")"] = alias;
	}
}

static vector<string> replace_fstrategy_with_rstrategy(
	const vector<tuple<string, legone::basic_type>> &fparams,
	const vector<unique_ptr<legone::rparam_node>> &rparams,
	const vector<string> &strategies)
{
	vector<string> result;
	for (auto &strategy : strategies)
	{
		auto it = find_if(fparams.begin(), fparams.end(),
			[&strategy](const tuple<string, legone::basic_type> &p) {
				return get<0>(p) == strategy;
			});
		if (it != fparams.end())
		{
			auto index = std::distance(fparams.begin(), it);
			result.push_back(dynamic_cast<const legone::strategy_rparam_node *>(
				rparams[index].get())
								 ->strategy_name);
		}
		else
		{
			result.push_back(strategy);
		}
	}
	return result;
}

static unique_ptr<exp_node> replace_fpayoff_with_rpayoff(
	const legone::payoff_exp_node &payoff_exp,
	const vector<tuple<string, legone::basic_type>> &fparams,
	const vector<unique_ptr<legone::rparam_node>> &rparams)
{
	auto new_strategies = replace_fstrategy_with_rstrategy(fparams, rparams,
		payoff_exp.strategies);

	// find the location of the payoff in rparams
	auto it = find_if(fparams.begin(), fparams.end(),
		[&payoff_exp](const tuple<string, legone::basic_type> &p) {
			return get<0>(p) == payoff_exp.payoff_name;
		});
	if (it == fparams.end()) // the payoff is not in fparams
	{
		return make_unique<payoff_exp_node>(payoff_exp.payoff_name,
			new_strategies);
	}
	auto index = std::distance(fparams.begin(), it);
	auto payoff_rparam = dynamic_cast<const legone::payoff_exp_rparam_node *>(
		rparams.at(index).get());
	// build the tree for the new payoff
	unique_ptr<exp_node> root = make_unique<payoff_exp_node>(
		payoff_rparam->basic_payoffs.at(0), new_strategies);
	for (size_t i = 1; i < payoff_rparam->basic_payoffs.size(); i++)
	{
		auto op_type = constraint::op_exp_node::op_type::ADD;
		if (payoff_rparam->coefficients.at(i) < 0)
		{
			op_type = constraint::op_exp_node::op_type::SUB;
		}
		auto new_payoff = make_unique<payoff_exp_node>(
			payoff_rparam->basic_payoffs.at(i), new_strategies);
		auto new_coeff = make_unique<num_exp_node>(
			std::abs(payoff_rparam->coefficients.at(i)));
		if (std::abs(new_coeff->value) != 1)
		{
			auto mul_node =
				make_unique<op_exp_node>(constraint::op_exp_node::op_type::MUL,
					std::move(new_coeff), std::move(new_payoff));
			root = make_unique<op_exp_node>(op_type, std::move(root),
				std::move(mul_node));
		}
		else
		{
			root = make_unique<op_exp_node>(op_type, std::move(root),
				std::move(new_payoff));
		}
	}
	return root;
}

static unique_ptr<exp_node> legone_ast_walk(
	const unique_ptr<legone::exp_node> &exp,
	const unique_ptr<legone::operation_node> &operation,
	const unique_ptr<legone::construct_stmt_node> &construct)
{
	if (exp->type == legone::exp_node::exp_type::NUM)
	{
		const auto num_exp =
			dynamic_cast<const legone::num_exp_node *>(exp.get());
		return make_unique<num_exp_node>(num_exp->val);
	}
	else if (exp->type == legone::exp_node::exp_type::OP)
	{
		const auto op_exp =
			dynamic_cast<const legone::op_exp_node *>(exp.get());
		op_exp_node::op_type op_type;
		switch (op_exp->o_type)
		{
		case legone::op_exp_node::op_type::ADD:
			op_type = op_exp_node::op_type::ADD;
			break;
		case legone::op_exp_node::op_type::SUB:
			op_type = op_exp_node::op_type::SUB;
			break;
		case legone::op_exp_node::op_type::MUL:
			op_type = op_exp_node::op_type::MUL;
			break;
		default: throw std::runtime_error("Unsupported operation type");
		}
		return make_unique<op_exp_node>(op_type,
			legone_ast_walk(op_exp->left, operation, construct),
			legone_ast_walk(op_exp->right, operation, construct));
	}
	else if (exp->type == legone::exp_node::exp_type::PARAM)
	{
		const auto param_exp =
			dynamic_cast<const legone::param_exp_node *>(exp.get());
		return make_unique<param_exp_node>(param_exp->param_name);
	}
	else if (exp->type == legone::exp_node::exp_type::F_VAL)
	{
		const auto f_val_exp =
			dynamic_cast<const legone::f_val_exp_node *>(exp.get());
		return make_unique<f_val_exp_node>(f_val_exp->f_name,
			replace_fstrategy_with_rstrategy(operation->fparams,
				construct->rparams, f_val_exp->strategies));
	}
	else if (exp->type == legone::exp_node::exp_type::PAYOFF)
	{
		return replace_fpayoff_with_rpayoff(
			*dynamic_cast<const legone::payoff_exp_node *>(exp.get()),
			operation->fparams, construct->rparams);
	}
	else
	{
		throw std::runtime_error("Unsupported expression type");
	}
}

unique_ptr<exp_node> constraint::optimization_tree::constraint_node2constraint(
	const unique_ptr<legone::constraint_node> &constraint,
	const unique_ptr<legone::operation_node> &operation,
	const unique_ptr<legone::construct_stmt_node> &construct)
{
	auto left_exp = legone_ast_walk(constraint->left_exp, operation, construct);
	auto right_exp =
		legone_ast_walk(constraint->right_exp, operation, construct);
	op_exp_node::op_type op_type;
	switch (constraint->op)
	{
	case legone::constraint_node::comp_op::LEQ:
		op_type = op_exp_node::op_type::LEQ;
		break;
	case legone::constraint_node::comp_op::EQ:
		op_type = op_exp_node::op_type::EQ;
		break;
	case legone::constraint_node::comp_op::GEQ:
		op_type = op_exp_node::op_type::GEQ;
		break;
	default: throw std::runtime_error("Unsupported operation type");
	}
	return make_unique<op_exp_node>(op_type, std::move(left_exp),
		std::move(right_exp));
}

void constraint::optimization_tree::quantifier_eliminate(
	const unique_ptr<exp_node> &exp, deque<tuple<string, int>> &quantifiers,
	unordered_map<string, string> &instantiated_var)
{
	if (quantifiers.empty()) // all variables are instantiated
	{
		auto ret = exp->clone(instantiated_var);
		constraints.push_back(std::move(ret));
		return;
	}
	auto [var, type] = quantifiers.back();
	quantifiers.pop_back();
	for (const auto &strategy : player_strategies[type])
	{
		instantiated_var[var] = strategy;
		quantifier_eliminate(exp, quantifiers, instantiated_var);
		instantiated_var.erase(var);
	}
}

/*
	for quantifier forall xi:i, when there is a Ui(x1, x2, ..., xi, ..., xn),
   replace it with fi(x1, x2, ..., xi, ..., xn)+Ui(x1, x2, ..., xi, ..., xn) but
   instantiate xi with a strategy
*/
static void change_payoff2f(unique_ptr<exp_node> &exp, int player_index,
	const string &var_name)
{
	if (exp->type != exp_node::exp_type::OP)
	{
		return;
	}
	auto &op_exp = dynamic_cast<op_exp_node &>(*exp);
	if (op_exp.left->type == exp_node::exp_type::PAYOFF) // leaf node
	{
		auto &payoff_exp = dynamic_cast<payoff_exp_node &>(*op_exp.left);
		auto payoff_index = std::stoi(payoff_exp.payoff_name.substr(1));
		if (payoff_index == player_index)
		{
			auto new_f_val = make_unique<f_val_exp_node>(
				format("f{}", payoff_index), payoff_exp.strategies);
			auto new_op = make_unique<op_exp_node>(op_exp_node::op_type::ADD,
				std::move(op_exp.left), std::move(new_f_val));
			op_exp.left = std::move(new_op);
		}
	}
	else // internal node
	{
		change_payoff2f(op_exp.left, player_index, var_name);
	}
	if (op_exp.right->type == exp_node::exp_type::PAYOFF) // leaf node
	{
		auto &payoff_exp = dynamic_cast<payoff_exp_node &>(*op_exp.right);
		auto payoff_index = std::stoi(payoff_exp.payoff_name.substr(1));
		if (payoff_index == player_index)
		{
			auto new_f_val = make_unique<f_val_exp_node>(
				format("f{}", payoff_index), payoff_exp.strategies);
			auto new_op = make_unique<op_exp_node>(op_exp_node::op_type::ADD,
				std::move(op_exp.right), std::move(new_f_val));
			op_exp.right = std::move(new_op);
		}
	}
	else // internal node
	{
		change_payoff2f(op_exp.right, player_index, var_name);
	}
}

void constraint::optimization_tree::quantifier_eliminate_with_f(
	const unique_ptr<exp_node> &exp, deque<tuple<string, int>> &quantifiers,
	unordered_map<string, string> &instantiated_var)
{
	if (quantifiers.size() == 1) // the final quantifier
	{
		auto one_quantified_exp = exp->clone(instantiated_var);
		change_payoff2f(one_quantified_exp, std::get<1>(quantifiers.front()), std::get<0>(quantifiers.front()));
		auto [var, type] = quantifiers.front();
		for (const auto &strategy : player_strategies[type])
		{
			instantiated_var[var] = strategy;
			auto ret = one_quantified_exp->clone(instantiated_var);
			constraints.push_back(std::move(ret));
			instantiated_var.erase(var);
		}
		return;
	}
	auto [var, type] = quantifiers.front();
	quantifiers.pop_front();
	for (const auto &strategy : player_strategies[type])
	{
		instantiated_var[var] = strategy;
		quantifier_eliminate_with_f(exp, quantifiers, instantiated_var);
		instantiated_var.erase(var);
	}
}
