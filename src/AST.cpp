#include "ast.hpp"

void legone::ast_root::walk(bool print) const
{
	if (print)
	{
		std::cout << std::endl << "ast_root begin: " << std::endl;
	}	
	for (auto &op : operations)
	{
		op.second->walk(print);
	}
	algo->walk(print);
	if (print)
	{
		std::cout << "ast_root end" << std::endl;
	}
}

legone::num_exp_node::num_exp_node(int val) : val(val)
{
	type = exp_type::NUM;
}

void legone::num_exp_node::display(ostream &os) const
{
	auto s = format("\t\t\texp_node: number: {}", val);
	os << s << endl;
}

void legone::num_exp_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
}

legone::op_exp_node::op_exp_node(op_type o_type, unique_ptr<exp_node> left,
	unique_ptr<exp_node> right) :
	o_type(o_type),
	left(std::move(left)), right(std::move(right))
{
	type = exp_type::OP;
}

void legone::op_exp_node::display(ostream &os) const
{
	auto op_str = "";
	switch (o_type)
	{
	case op_type::ADD: op_str = "+"; break;
	case op_type::SUB: op_str = "-"; break;
	case op_type::MUL: op_str = "*"; break;
	default: throw std::runtime_error("Invalid op_type");
	}
	auto s = format("\t\t\texp_node: op: {}", op_str);
	os << s << endl;
}

void legone::op_exp_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
	left->walk(print);
	right->walk(print);
}

legone::payoff_exp_node::payoff_exp_node(const string &payoff_name,
	vector<string> strategies) :
	payoff_name(payoff_name),
	strategies(std::move(strategies))
{
	type = exp_type::PAYOFF;
}

void legone::payoff_exp_node::display(ostream &os) const
{
	auto s = format("\t\t\texp_node: payoff: {}(", payoff_name);
	for (auto &strategy : strategies)
	{
		s += strategy + ", ";
	}
	s.pop_back();
	s.pop_back();
	s += ")";
	os << s << endl;
}

void legone::payoff_exp_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
}

legone::f_val_exp_node::f_val_exp_node(const string &f_name,
	vector<string> strategies) :
	f_name(f_name),
	strategies(std::move(strategies))
{
	type = exp_type::F_VAL;
}

void legone::f_val_exp_node::display(ostream &os) const
{
	auto s = format("\t\t\texp_node: f_val: {}(", f_name);
	for (auto &strategy : strategies)
	{
		s += strategy + ", ";
	}
	s.pop_back();
	s.pop_back();
	s += ")";
	os << s << endl;
}

void legone::f_val_exp_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
}

legone::algo_node::algo_node(vector<unique_ptr<construct_stmt_node>> constructs,
	vector<string> rets) :
	constructs(std::move(constructs)),
	rets(std::move(rets))
{
}

void legone::algo_node::walk(bool print) const
{
	if (print)
	{
		std::cout << "algo begin: " << std::endl;
	}
	for (auto &construct : constructs)
	{
		construct->walk(print);
	}
	if (print)
	{
		if (rets.size() > 0)
		{
			std::cout << "algo return: " << rets.at(0);
			for (auto i = 1; i < rets.size(); i++)
			{
				std::cout << ", " << rets.at(i);
			}
			std::cout << std::endl << "algo end" << std::endl;
		}
	}
}

legone::constraint_node::constraint_node(
	vector<tuple<string, basic_type>> quantifiers,
	unique_ptr<exp_node> left_exp, unique_ptr<exp_node> right_exp, comp_op op) :
	quantifiers(std::move(quantifiers)),
	left_exp(std::move(left_exp)), right_exp(std::move(right_exp)), op(op)
{
}

void legone::constraint_node::walk(bool print) const
{
	if (print)
	{
		std::cout << "\tconstraint begin: " << std::endl;
	}
	if (print)
	{
		if(quantifiers.size() > 0)
		{
			std::cout << "\t\tquantifiers: " << std::get<0>(quantifiers.at(0));
			for (auto i = 1; i < quantifiers.size(); i++)
			{
				std::cout << ", " << std::get<0>(quantifiers.at(i));
			}
			std::cout << std::endl;
		}
		else{
			std::cout << "\t\tquantifiers: none" << std::endl;
		}
		switch (op)
		{
		case comp_op::EQ:
			std::cout << "\t\tcomp_op: ==" << std::endl;
			break;
		case comp_op::LEQ:
			std::cout << "\t\tcomp_op: <=" << std::endl;
			break;
		case comp_op::GEQ:
			std::cout << "\t\tcomp_op: >=" << std::endl;
			break;
		default:
			throw std::runtime_error("Invalid comp_op");
		}
	}
	if(print)
	{
		std::cout << "\t\tleft_exp: " << std::endl;
	}
	left_exp->walk(print);
	if(print)
	{
		std::cout << "\t\tright_exp: " << std::endl;
	}
	right_exp->walk(print);
	if (print)
	{
		std::cout << "\tconstraint end" << std::endl;
	}
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
	// TODO: figure out why this is error
	// if(rets.size() == 0)
	// {
	// 	throw std::runtime_error("Construct statement must have at least one return value");
	// }
}

void legone::construct_stmt_node::walk(bool print) const
{
	if (print)
	{
		std::cout << "\tconstruct_stmt begin: " << std::endl;
		if (rets.size() > 0)
		{
			std::cout << "\t\trets: " << std::get<0>(rets.at(0)) << " : "<< static_cast<int>((std::get<1>(rets.at(0))));
			for (auto i = 1; i < rets.size(); i++)
			{
				std::cout << ", " << std::get<0>(rets.at(i)) << " : " << static_cast<int>((std::get<1>(rets.at(i))));
			}
			std::cout << std::endl;
		}
		else
		{
			std::cout << "\t\trets: none" << std::endl;
		}
		std::cout << "\t\toperation_name: " << operation_name << std::endl;
		std::cout << "\t\trparams: ";
		if(rparams.size() == 0)
		{
			std::cout << "none" << std::endl;
		}
		else
		{
			std::cout << std::endl;
		}
	}
	for(auto &rparam : rparams)
	{
		rparam->walk(print);
	}
	if (print)
	{
		std::cout << "\tconstruct_stmt end" << std::endl;
	}
}

legone::strategy_rparam_node::strategy_rparam_node(
	const string &strategy_name) :
	strategy_name(strategy_name)
{
}

void legone::strategy_rparam_node::display(ostream &os) const
{
	os << "\t\t\trparam_node: strategy: " << strategy_name << endl;
}

void legone::strategy_rparam_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
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

void legone::payoff_exp_rparam_node::display(ostream &os) const
{
	string s = "\t\t\trparam_node: payoff_exp: ";
	for (auto i = 0; i < basic_payoffs.size(); i++)
	{
		auto payoff = basic_payoffs.at(i);
		if(coefficients.at(i) > 1)
		{
			payoff = format("{} * {}", coefficients.at(i), payoff);
		}
		else if(coefficients.at(i) < -1)
		{
			payoff = format("{} * {}", coefficients.at(i), payoff);
		}
		else if(coefficients.at(i) == -1)
		{
			payoff = format(" - {}", payoff);
		}
		else if(coefficients.at(i) == 0)
		{
			continue;
		}
		s += payoff + " + ";
	}
	s.pop_back();
	s.pop_back();
	s.pop_back();
	os << s << endl;
}

void legone::payoff_exp_rparam_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
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

void legone::operation_node::walk(bool print) const
{
	if (print)
	{
		std::cout << "operation begin: " << std::endl;
		std::cout << "\tname: " << name << std::endl;
		std::cout << "\tfparams: ";
		if(fparams.size() == 0)
		{
			std::cout << "none" << std::endl;
		}
		else
		{
			std::cout << std::endl;
		}
	}
	for(auto &fparam : fparams)
	{
		std::cout << "\t\t" << std::get<0>(fparam) << " : " << static_cast<int>(std::get<1>(fparam)) << std::endl;
	}
	if (print)
	{
		std::cout << "\trets: ";
		if(rets.size() == 0)
		{
			std::cout << "none" << std::endl;
		}
		else
		{
			std::cout << std::endl;
		}
	}
	for(auto &ret : rets)
	{
		std::cout << "\t\t" << std::get<0>(ret) << " : " << static_cast<int>(std::get<1>(ret)) << std::endl;
	}
	if (print)
	{
		std::cout << "\textra_params: ";
		if(extra_params.size() == 0)
		{
			std::cout << "none" << std::endl;
		}
		else
		{
			std::cout << std::endl;
		}
	}
	for(auto &extra_param : extra_params)
	{
		std::cout << "\t\t" << extra_param << std::endl;
	}
	if (print)
	{
		std::cout << "\tconstraints: ";
		if(constraints.size() == 0)
		{
			std::cout << "none" << std::endl;
		}
		else
		{
			std::cout << std::endl;
		}
	}
	for(auto &constraint : constraints)
	{
		constraint->walk(print);
	}
	if (print)
	{
		std::cout << "operation end" << std::endl << std::endl;
	}
}

bool legone::is_f_val(const string &s)
{
	std::regex f_val_regex("f[0-9]+");
	return std::regex_match(s, f_val_regex);
}

bool legone::is_payoff(const string &s)
{
	std::regex payoff_regex("U[0-9]+");
	return std::regex_match(s, payoff_regex);
}

legone::param_exp_node::param_exp_node(const string &param_name) : param_name(param_name)
{
	type = exp_type::PARAM;
}

void legone::param_exp_node::display(ostream &os) const
{
	auto s = format("\t\t\texp_node: param: {}", param_name);
	os << s << endl;
}

void legone::param_exp_node::walk(bool print) const
{
	if (print)
	{
		display(std::cout);
	}
}
