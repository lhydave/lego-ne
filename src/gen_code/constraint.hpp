// Eliminate the quantifiers and generate the AST of constraint programs

#ifndef LEGO_CONSTRAINT_HPP
#define LEGO_CONSTRAINT_HPP
#include <algorithm>
#include <deque>
#include <format>
#include <iostream>
#include <numeric>
#include <regex>
#include <string>
#include <string_view>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

#include "../ast.hpp"

using std::deque;
using std::endl;
using std::format;
using std::make_unique;
using std::ostream;
using std::string;
using std::string_view;
using std::tuple;
using std::unique_ptr;
using std::unordered_map;
using std::unordered_set;
using std::vector;

namespace constraint
{

class exp_node
{
  public:
    enum class exp_type
    {
        NUM,
        OP,
        PAYOFF,
        F_VAL,
        PARAM
    };
    exp_type type;

    virtual ~exp_node() = default;
    virtual unique_ptr<exp_node> clone(
        const unordered_map<string, string> &instantiated_var) const = 0; // for quantifier elimination
    virtual string to_string(const unordered_map<string, string> &name_alias) const = 0;
};

class num_exp_node : public exp_node
{
  public:
    double value;

    num_exp_node(double value) : value(value)
    {
        type = exp_type::NUM;
    }
    unique_ptr<exp_node> clone(const unordered_map<string, string> &instantiated_var) const override;
    string to_string(const unordered_map<string, string> &name_alias) const override;
};

class op_exp_node : public exp_node
{
  public:
    enum class op_type
    {
        ADD,
        SUB,
        MUL,
        DIV,
        LEQ,
        EQ,
        GEQ
    };
    op_type op;
    unique_ptr<exp_node> left;
    unique_ptr<exp_node> right;

    op_exp_node(op_type op, unique_ptr<exp_node> left, unique_ptr<exp_node> right)
        : op(op), left(std::move(left)), right(std::move(right))
    {
        type = exp_type::OP;
    }
    unique_ptr<exp_node> clone(const unordered_map<string, string> &instantiated_var) const override;
    string to_string(const unordered_map<string, string> &name_alias) const override;
};

class payoff_exp_node : public exp_node
{
  public:
    string payoff_name;
    vector<string> strategies;

    payoff_exp_node(string_view payoff_name, vector<string> strategies)
        : payoff_name(payoff_name), strategies(std::move(strategies))
    {
        type = exp_type::PAYOFF;
    }
    unique_ptr<exp_node> clone(const unordered_map<string, string> &instantiated_var) const override;
    string to_string(const unordered_map<string, string> &name_alias) const override;
};

class f_val_exp_node : public exp_node
{
  public:
    string f_name;
    vector<string> strategies;

    f_val_exp_node(string_view f_name, vector<string> strategies) : f_name(f_name), strategies(std::move(strategies))
    {
        type = exp_type::F_VAL;
    }
    unique_ptr<exp_node> clone(const unordered_map<string, string> &instantiated_var) const override;
    string to_string(const unordered_map<string, string> &name_alias) const override;
};

class param_exp_node : public exp_node
{
  public:
    string param_name;

    param_exp_node(string_view param_name) : param_name(param_name)
    {
        type = exp_type::PARAM;
    }
    unique_ptr<exp_node> clone(const unordered_map<string, string> &instantiated_var) const override;
    string to_string(const unordered_map<string, string> &name_alias) const override;
};

// components for defining optimal mixing function, ugly but works!
namespace func_def
{
class exp_node
{
  public:
    enum class op_type
    {
        NUM,
        VAR,
        ADD,
        SUB,
        MUL,
        DIV,
        AND,
        OR,
        LE,
        GE,
        IF,
        MAX,
        MIN,
        FUNC_CALL
    };
    op_type op;
    string val; // only for NUM, VAR, and func_call type
    vector<unique_ptr<exp_node>> op_params;

    exp_node(op_type op, vector<unique_ptr<exp_node>> op_params);
    exp_node(op_type op, string_view val);
    exp_node(op_type op, string_view val, vector<unique_ptr<exp_node>> op_params);
};

class func_def
{
  public:
    string func_name;
    vector<string> func_param;
    unique_ptr<exp_node> body;
    func_def(string_view func_name, const vector<string> &func_param, unique_ptr<exp_node> body);
};

class assign_stmt // only for boundx = optmix(...)
{
  public:
    string lval;
    unique_ptr<exp_node> rval;
    string comment;
    assign_stmt(string_view lval, unique_ptr<exp_node> rval, string_view comment);
};

} // namespace func_def

class optimization_tree
{
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

    vector<unique_ptr<func_def::func_def>> opt_mix_func_def;
    vector<unique_ptr<func_def::assign_stmt>> opt_mix_bounds;
    static constexpr string_view opt_mix_bound_prefix = "bound";
    static constexpr string_view opt_mix_func_name = "optMix";
    static constexpr string_view intersect_point_func_name = "interPt";
    static constexpr string_view intersect_val_func_name = "interVal";
    int num_edges; // number of edges in optimal mixing bound

    void gen_tree(const legone::ast_root &ast);
    void generate_combinations(vector<vector<string>> &combinations, vector<string> &current, int depth,
                               vector<int> &player_indices);
    void print_constraints(ostream &os, bool with_alias) const;

  private:
    void gen_alias();
    unique_ptr<exp_node> legone_ast_walk(const unique_ptr<legone::exp_node> &exp,
                                         const unique_ptr<legone::operation_node> &operation,
                                         const unique_ptr<legone::construct_stmt_node> &construct);
    unique_ptr<exp_node> constraint_node2constraint(const unique_ptr<legone::constraint_node> &constraint,
                                                    const unique_ptr<legone::operation_node> &operation,
                                                    const unique_ptr<legone::construct_stmt_node> &construct);
    void quantifier_eliminate(const unique_ptr<exp_node> &exp, deque<tuple<string, int>> &quantifiers,
                              unordered_map<string, string> &instantiated_var); // put the results in constraints

    void quantifier_eliminate_with_f(
        const unique_ptr<exp_node> &exp, deque<tuple<string, int>> &quantifiers,
        unordered_map<string, string> &instantiated_var); // replace forall xi:i Ui with fi+Ui
    void gen_opt_mix_func_def();
    void gen_opt_mix_bounds();
};

string strategy_to_string(const vector<string> &strategies);
} // namespace constraint

#endif