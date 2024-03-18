// Eliminate the quantifiers and generate the AST of constraint programs

#ifndef LEGO_CONSTRAINT_HPP
#define LEGO_CONSTRAINT_HPP
#include "../ast.hpp"
#include <format>
#include <iostream>
#include <numeric>
#include <regex>
#include <string>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <deque>
#include <variant>
#include <vector>
#include <algorithm>

using std::endl;
using std::format;
using std::make_unique;
using std::ostream;
using std::string;
using std::tuple;
using std::unique_ptr;
using std::unordered_map;
using std::unordered_set;
using std::vector;
using std::deque;

namespace constraint {

class exp_node {
public:
	enum class exp_type { NUM, OP, PAYOFF, F_VAL, PARAM };
	exp_type type;

	virtual ~exp_node() = default;
	virtual unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var)
		const = 0; // for quantifier elimination
	virtual string to_string(const unordered_map<string, string>& name_alias) const = 0;
};

class num_exp_node : public exp_node {
public:
	int value;

	num_exp_node(int value) : value(value)
	{
		type = exp_type::NUM;
	}
	unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var) const override;
	string to_string(const unordered_map<string, string>& name_alias) const override;
};

class op_exp_node : public exp_node {
public:
	enum class op_type { ADD, SUB, MUL, DIV, LEQ, EQ, GEQ };
	op_type op;
	unique_ptr<exp_node> left;
	unique_ptr<exp_node> right;

	op_exp_node(op_type op, unique_ptr<exp_node> left,
		unique_ptr<exp_node> right) :
		op(op),
		left(std::move(left)), right(std::move(right))
	{
		type = exp_type::OP;
	}
	unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var) const override;
	string to_string(const unordered_map<string, string>& name_alias) const override;
};

class payoff_exp_node : public exp_node {
public:
	string payoff_name;
	vector<string> strategies;

	payoff_exp_node(const string &payoff_name, vector<string> strategies) :
		payoff_name(payoff_name), strategies(std::move(strategies))
	{
		type = exp_type::PAYOFF;
	}
	unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var) const override;
	string to_string(const unordered_map<string, string>& name_alias) const override;
};

class f_val_exp_node : public exp_node {
public:
	string f_name;
	vector<string> strategies;

	f_val_exp_node(const string &f_name, vector<string> strategies) :
		f_name(f_name), strategies(std::move(strategies))
	{
		type = exp_type::F_VAL;
	}
	unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var) const override;
	string to_string(const unordered_map<string, string>& name_alias) const override;
};

class param_exp_node : public exp_node {
public:
	string param_name;

	param_exp_node(const string &param_name) : param_name(param_name)
	{
		type = exp_type::PARAM;
	}
	unique_ptr<exp_node> clone(
		const unordered_map<string, string> &instantiated_var) const override;
	string to_string(const unordered_map<string, string>& name_alias) const override;
};

class optimization_tree {
public:
	size_t num_players;
	unordered_map<int, unordered_set<string>> player_strategies;
	/* naming rule:
	 * 1. name_alias is the prefix for (x1, x2, ...)
	 * 2. for payoff Uk(x1, x2, ...), the alias is name_alias + "_Uk"
	 * 3. for f_val fk(x1, x2, ...), the alias is name_alias + "_fk"
	 */
	unordered_map<string, string> name_alias;
	unordered_set<string> params;
	vector<unique_ptr<exp_node>> constraints;

	void gen_tree(const legone::ast_root &ast);
	void generate_combinations(vector<vector<string>> &combinations,
		vector<string> &current, int depth, vector<int> &player_indices);
	void print_constraints(ostream &os, bool with_alias) const;

private:
	void gen_alias();
	void gen_default_constraints();
	unique_ptr<exp_node> constraint_node2constraint(
		const unique_ptr<legone::constraint_node> &constraint,
		const unique_ptr<legone::operation_node> &operation,
		const unique_ptr<legone::construct_stmt_node> &construct);
	void quantifier_eliminate(const unique_ptr<exp_node> &exp,
		deque<tuple<string, int>> &quantifiers,
		unordered_map<string, string>
			&instantiated_var); // put the results in constraints
	
	void quantifier_eliminate_with_f(const unique_ptr<exp_node> &exp,
		deque<tuple<string, int>> &quantifiers,
		unordered_map<string, string>
			&instantiated_var); // replace forall xi:i Ui with fi+Ui
};

string strategy_to_string(const vector<string> &strategies);
} // namespace constraint

#endif