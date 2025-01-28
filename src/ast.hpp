// The AST for the compiler
#ifndef AST_HPP
#define AST_HPP
#include <format>
#include <iostream>
#include <optional>
#include <regex>
#include <string>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

using std::endl;
using std::format;
using std::make_unique;
using std::optional;
using std::ostream;
using std::string;
using std::tuple;
using std::unique_ptr;
using std::unordered_map;
using std::unordered_set;
using std::variant;
using std::vector;

namespace legone
{

// from 1, they are player types
enum class basic_type : int
{
    Payoff = 0
};

class operation_node;
class algo_node;
class constraint_node;
class construct_stmt_node;
class exp_node;
class rparam_node;

// basic types, as follows
// - fi: loss function of player i, only has one element fi
// - pi: strategy of player i
// - payoff: payoff function
// - param: parameter type
// - algo: the type of algo
using BasicType = string;

// operation types, as follows
// Ti1,...,Tik -> To1,...Tol, where Tij's and Toj's are either strategy or payoff
struct OperationType
{
    vector<BasicType> params_type;
    vector<BasicType> ret_type;
    bool operator==(const OperationType& other);
};

using Type = variant<BasicType, OperationType>;

bool operator==(const Type& a, const Type&b);

// record whether a symbol has been defined, and its type
struct SymTab
{
    using TabType = vector<unordered_map<string, Type>>; // stacked tables
    TabType tab;
    SymTab() = default;
    void def_symbol(const string &symbol, const Type &sym_type);
    optional<Type> get_type(const string &symbol) const;
    void increase_scope();
    void decrease_scope();
};

class ast_node_base
{
  public:
    virtual ~ast_node_base() = default;
    virtual void walk(legone::SymTab &sym_tab, bool print = false) const = 0;
};

class ast_root : public ast_node_base
{
  public:
    size_t num_players;
    unordered_map<string, unique_ptr<operation_node>> operations;
    unique_ptr<algo_node> algo;

    ast_root() = default;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class operation_node : public ast_node_base
{
  public:
    string name;
    vector<tuple<string, basic_type>> fparams;
    vector<tuple<string, basic_type>> rets;
    unordered_set<string> extra_params;
    vector<unique_ptr<constraint_node>> constraints;

    operation_node(const string &name, vector<tuple<string, basic_type>> fparams, vector<basic_type> ret_types,
                   unordered_set<string> extra_params, vector<unique_ptr<constraint_node>> constraints,
                   vector<string> ret_names);
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class algo_node : public ast_node_base
{
  public:
    vector<unique_ptr<construct_stmt_node>> constructs;
    vector<string> rets;

    algo_node(vector<unique_ptr<construct_stmt_node>> construct, vector<string> rets);
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class constraint_node : public ast_node_base
{
  public:
    enum class comp_op
    {
        EQ,
        LEQ,
        GEQ
    };
    vector<tuple<string, basic_type>> quantifiers;
    unique_ptr<exp_node> left_exp;
    unique_ptr<exp_node> right_exp;
    comp_op op;

    constraint_node(vector<tuple<string, basic_type>> quantifiers, unique_ptr<exp_node> left_exp,
                    unique_ptr<exp_node> right_exp, comp_op op);
    void walk(legone::SymTab &sym_tab, bool print = false) const override;

    static comp_op str2comp_op(const string &op);
};

class construct_stmt_node : public ast_node_base
{
  public:
    vector<tuple<string, basic_type>> rets;
    string operation_name;
    vector<unique_ptr<rparam_node>> rparams;

    construct_stmt_node(vector<tuple<string, basic_type>> rets, const string &operation_name,
                        vector<unique_ptr<rparam_node>> rparams);
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class rparam_node : public ast_node_base
{
  public:
    enum class rparam_type
    {
        STRATEGY,
        PAYOFF_EXP
    };
    rparam_type type;
    virtual ~rparam_node() = default;

    virtual void display(ostream &os) const = 0;
    virtual void walk(legone::SymTab &sym_tab, bool print = false) const = 0;
};

class strategy_rparam_node : public rparam_node
{
  public:
    string strategy_name;

    strategy_rparam_node(const string &strategy_name);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class payoff_exp_rparam_node : public rparam_node
{
  public:
    vector<string> basic_payoffs;
    vector<int> coefficients;

    payoff_exp_rparam_node(vector<tuple<string, int>> linear_terms);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class exp_node : public ast_node_base
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
    virtual void display(ostream &os) const = 0;
    virtual void walk(legone::SymTab &sym_tab, bool print = false) const = 0;
};

class num_exp_node : public exp_node
{
  public:
    double val;
    num_exp_node(double val);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class op_exp_node : public exp_node
{
  public:
    enum class op_type
    {
        ADD,
        SUB,
        MUL,
        DIV
    };
    op_type o_type;
    unique_ptr<exp_node> left;
    unique_ptr<exp_node> right;

    op_exp_node(op_type o_type, unique_ptr<exp_node> left, unique_ptr<exp_node> right);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class payoff_exp_node : public exp_node
{
  public:
    string payoff_name; // must be in form of U1, U2, ...
    vector<string> strategies;

    payoff_exp_node(const string &payoff_name, vector<string> strategies);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class f_val_exp_node : public exp_node
{
  public:
    string f_name; // must be in form of f1, f2, ...
    vector<string> strategies;

    f_val_exp_node(const string &f_name, vector<string> strategies);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

class param_exp_node : public exp_node
{
  public:
    string param_name;

    param_exp_node(const string &param_name);
    void display(ostream &os) const override;
    void walk(legone::SymTab &sym_tab, bool print = false) const override;
};

bool is_f_val(const string &s);
bool is_payoff(const string &s);

} // namespace legone

#endif