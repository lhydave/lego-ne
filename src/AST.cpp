#include "ast.hpp"

legone::num_exp_node::num_exp_node(int val) : val(val)
{
	type = exp_type::NUM;
}

legone::op_exp_node::op_exp_node(op_type o_type, unique_ptr<exp_node> left,
	unique_ptr<exp_node> right) :
	o_type(o_type),
	left(std::move(left)), right(std::move(right))
{
	type = exp_type::OP;
}

legone::payoff_exp_node::payoff_exp_node(const string &payoff_name,
	vector<string> strategies) :
	payoff_name(payoff_name),
	strategies(std::move(strategies))
{
	type = exp_type::PAYOFF;
}

legone::f_val_exp_node::f_val_exp_node(const string& f_name,
	vector<string> strategies) :
	f_name(f_name),
	strategies(std::move(strategies))
{
	type = exp_type::F_VAL;
}

legone::algo_node::algo_node(
	vector<unique_ptr<construct_stmt_node>> constructs, vector<string> rets) :
	constructs(std::move(constructs)), rets(std::move(rets))
{
}

legone::constraint_node::constraint_node(
	vector<tuple<string, basic_type>> quantifiers,
	unique_ptr<exp_node> left_exp, unique_ptr<exp_node> right_exp, comp_op op) :
	quantifiers(std::move(quantifiers)),
	left_exp(std::move(left_exp)), right_exp(std::move(right_exp)), op(op)
{
}

legone::constraint_node::comp_op legone::constraint_node::str2comp_op(
	const string &op)
{
	if (op == "==")
		return comp_op::EQ;
	else if (op == "<=")
		return comp_op::LEQ;
	else if (op == ">=")
		return comp_op::GEQ;
	else
		throw std::runtime_error("Invalid comparison operator: " + op);
}

legone::construct_stmt_node::construct_stmt_node(
	vector<tuple<string, basic_type>> rets, const string &operation_name,
	vector<unique_ptr<rparam_node>> rparams) :
	rets(std::move(rets)),
	operation_name(operation_name), rparams(std::move(rparams))
{
}

legone::strategy_rparam_node::strategy_rparam_node(
	const string &strategy_name) :
	strategy_name(strategy_name)
{
}

legone::payoff_exp_rparam_node::payoff_exp_rparam_node(
	vector<tuple<string, int>> linear_terms)
{
	for (auto &term : linear_terms)
	{
		basic_payoffs.push_back(std::get<0>(term));
		coefficients.push_back(std::get<1>(term));
	}
}

legone::operation_node::operation_node(const string &name,
	vector<tuple<string, basic_type>> fparams, vector<basic_type> ret_types,
	unordered_set<string> extra_params,
	vector<unique_ptr<constraint_node>> constraints, vector<string> ret_names) :
	name(name),
	fparams(std::move(fparams)), extra_params(std::move(extra_params)),
	constraints(std::move(constraints))
{
	if (ret_names.size() != ret_types.size())
		throw std::runtime_error(
			"ret_names and ret_types must have the same size");
	for (auto i = 0; i < ret_names.size(); i++)
	{
		if (ret_types[i] == basic_type::Payoff)
		{
			throw std::runtime_error("Payoff type is not allowed in the return "
									 "type of an operation");
		}
		rets.push_back(std::make_tuple(ret_names[i], ret_types[i]));
	}
}