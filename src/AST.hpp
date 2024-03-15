// The AST for the compiler
#ifndef AST_HPP
#define AST_HPP
#include <string>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

using std::make_unique;
using std::string;
using std::tuple;
using std::unique_ptr;
using std::unordered_map;
using std::unordered_set;
using std::vector;

namespace legone {

// from 1, they are player types
enum class basic_type : int { Payoff = 0 };

class operation_node;
class algo_node;
class constraint_node;
class construct_stmt_node;
class exp_node;
class rparam_node;

class ast_root {
public:
	size_t num_players;
	unordered_map<string, unique_ptr<operation_node>> operations;
	unique_ptr<algo_node> algo;

	ast_root() = default;
};

class operation_node {
public:
	string name;
	vector<tuple<string, basic_type>> fparams;
	vector<tuple<string, basic_type>> rets;
    unordered_set<string> extra_params;
	vector<unique_ptr<constraint_node>> constraints;

	operation_node(const string &name,
		vector<tuple<string, basic_type>> fparams,
		vector<basic_type> ret_types,
		unordered_set<string> extra_params,
		vector<unique_ptr<constraint_node>> constraints,
		vector<string> ret_names);

};

class algo_node {
public:
	vector<unique_ptr<construct_stmt_node>> constructs;
	vector<string> rets;

	algo_node(vector<unique_ptr<construct_stmt_node>> construct, vector<string> rets);
};

class constraint_node {
public:
	enum class comp_op { EQ, LEQ, GEQ };
	vector<tuple<string, basic_type>> quantifiers;
	unique_ptr<exp_node> left_exp;
	unique_ptr<exp_node> right_exp;
	comp_op op;

    constraint_node(vector<tuple<string, basic_type>> quantifiers,
        unique_ptr<exp_node> left_exp, unique_ptr<exp_node> right_exp,
        comp_op op);
    
    static comp_op str2comp_op(const string &op);
};

class construct_stmt_node {
public:
	vector<tuple<string, basic_type>> rets;
	string operation_name;
	vector<unique_ptr<rparam_node>> rparams;

    construct_stmt_node(vector<tuple<string, basic_type>> rets,
        const string &operation_name,
        vector<unique_ptr<rparam_node>> rparams);
};

class rparam_node {
public:
	enum class rparam_type { STRATEGY, PAYOFF_EXP };
	rparam_type type;
	virtual ~rparam_node() = default;
};

class strategy_rparam_node : public rparam_node {
public:
	string strategy_name;

	strategy_rparam_node(const string &strategy_name);
};

class payoff_exp_rparam_node : public rparam_node {
public:
	vector<string> basic_payoffs;
	vector<int> coefficients;

	payoff_exp_rparam_node(vector<tuple<string, int>> linear_terms);
};

class exp_node {
public:
	enum class exp_type { NUM, OP, PAYOFF, F_VAL };
	exp_type type;

	virtual ~exp_node() = default;
};

class num_exp_node : public exp_node {
public:
	int val;

	num_exp_node(int val);
};

class op_exp_node : public exp_node {
public:
	enum class op_type { ADD, SUB, MUL };
	op_type o_type;
	unique_ptr<exp_node> left;
	unique_ptr<exp_node> right;

	op_exp_node(op_type o_type, unique_ptr<exp_node> left,
		unique_ptr<exp_node> right);
};

class payoff_exp_node : public exp_node {
public:
	string payoff_name; // must be in form of U1, U2, ...
	vector<string> strategies;

	payoff_exp_node(const string &payoff_name, vector<string> strategies);
};

class f_val_exp_node : public exp_node {
public:
	string f_name; // must be in form of f1, f2, ...
	vector<string> strategies;

	f_val_exp_node(const string& f_name, vector<string> strategies);
};
} // namespace legone

#endif