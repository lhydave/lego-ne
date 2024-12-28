#include "Z3.hpp"

using namespace Z3;

Z3::generator::generator(const constraint::optimization_tree &tree, double bound_to_prove)
    : tree(tree), num_players(tree.num_players), bound_to_prove(bound_to_prove)
{
}

string Z3::generator::gen_code(string_view file) const
{
    auto [alias_decl, alias_in_exist] = gen_alias_and_param();
    auto opt_mix_func = gen_opt_mix_func();
    auto constraints = gen_constraints();
    auto opt_mix_bounds_decl = gen_opt_mix_bounds();

    auto approx_bound_constraint = gen_approx_bound_constraint(alias_in_exist);

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
	return reduce(min2, nums))" +
                    format("\n\n{} = Solver()\n", solver_name) + format("\n{} = []\n", constraint_name);

    auto postamble = format(
        "check_ret = {}.check()\n"
        "if check_ret == unsat:\n"
        "\tprint(f\"The given algorithm is proven to have approximation bound {{{}}}. The proof is as follows.\")\n"
        "\tprint({}.proof())\n"
        "elif check_ret == sat:\n"
        "\tprint(f\"Possible counterexample are found when proving approximation bound {{{}}} for the given "
        "algorithm.\")\n"
        "\tprint({}.model())\n"
        "else:\n"
        "\tprint(\"Z3 solver failed to work.\")\n",
        solver_name, bound_name, solver_name, bound_name, solver_name);

    return format("{}\n# name alias and parameters\n{}\n"
                  "# constraint for optimal mixing operation\n{}\n{}\n"
                  "# constraints\n{}\n"
                  "# constraints for approximation bounds\n{}\n"
                  "# solve the SMT problem\n{}\n",
                  preamble, alias_decl, opt_mix_func, opt_mix_bounds_decl, constraints, approx_bound_constraint,
                  postamble);
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

static string exp_to_string(const unique_ptr<constraint::func_def::exp_node> &exp_node)
{
    using op_type = constraint::func_def::exp_node::op_type;
    switch (exp_node->op)
    {
    case op_type::NUM:
    case op_type::VAR:
        return exp_node->val;
    case op_type::ADD:
        return format("({} + {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::SUB:
        return format("({} - {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::MUL:
        return format("({} * {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::DIV:
        return format("({} / {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::AND:
        return format("({} & {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::OR:
        return format("({} | {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::LE:
        return format("({} <= {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::GE:
        return format("({} >= {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::FUNC_CALL: {
        string params;
        for (auto &param : exp_node->op_params)
        {
            params += exp_to_string(param) + ", ";
        }
        if (not params.empty())
        {
            params.pop_back();
            params.pop_back();
        }
        return format("{}({})", exp_node->val, params);
    }
    default:
        throw std::runtime_error("Should not handle min, max, and if in exp_to_string!");
    }
}

static string gen_func_def(const unique_ptr<constraint::func_def::func_def> &func_def_stmt)
{
    string params;
    for (auto &param : func_def_stmt->func_param)
    {
        params += param + ", ";
    }
    if (not params.empty())
    {
        params.pop_back();
        params.pop_back();
    }
    return format("def {}({}):\n\treturn {}\n\n", func_def_stmt->func_name, params, exp_to_string(func_def_stmt->body));
}

static string gen_optmix_def(const unique_ptr<constraint::func_def::func_def> &func_def_stmt)
{
    using op_type = constraint::func_def::exp_node::op_type;
    string body_str;
    auto &body = func_def_stmt->body;
    body_str += "min_list([\n";
    auto &min_elements = body->op_params;
    // the two default end points
    body_str += "\t\tmax_list([";
    for (auto &ele : min_elements[0]->op_params) // max{a1,a2,...,ar}
    {
        body_str += exp_to_string(ele) + ", ";
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "]),\n";

    body_str += "\t\tmax_list([";
    for (auto &ele : min_elements[1]->op_params) // max{b1,b2,...,br}
    {
        body_str += exp_to_string(ele) + ", ";
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "]),\n";
    // the intersection cases
    for (auto &if_term : min_elements)
    {
        if (if_term->op != op_type::IF)
        {
            continue;
        }
        body_str +=
            format("\t\tIf({}, {}, ", exp_to_string(if_term->op_params[0]), exp_to_string(if_term->op_params[1]));
        auto &if_false = if_term->op_params[2];
        if (if_false->op != op_type::MAX) // not a max list
        {
            body_str += format("\n\t\t\t{}),\n", exp_to_string(if_false));
        }
        else // a max list
        {
            body_str += "max_list([\n";
            for (auto &max_ele : if_term->op_params[2]->op_params)
            {
                body_str += format("\t\t\t{},\n", exp_to_string(max_ele));
            }
            body_str.pop_back();
            body_str.pop_back();
            body_str += "])),\n";
        }
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "])\n";
    string params;
    for (auto &param : func_def_stmt->func_param)
    {
        params += param + ", ";
    }
    if (not params.empty())
    {
        params.pop_back();
        params.pop_back();
    }

    return format("def {}({}):\n\treturn {}\n\n", func_def_stmt->func_name, params, body_str);
}

string Z3::generator::gen_opt_mix_func() const
{
    string ret;
    for (auto i = 0; i < tree.opt_mix_func_def.size() - 1; i++)
    {
        ret += gen_func_def(tree.opt_mix_func_def[i]);
    }
    ret += gen_optmix_def(*tree.opt_mix_func_def.rbegin());
    return ret;
}

string Z3::generator::gen_opt_mix_bounds() const
{
    vector<string> bounds;
    vector<string> comments;
    auto max_bound_name_len = format("{}{}", tree.opt_mix_bound_prefix, tree.num_edges).size();
    size_t max_code_len = 0;
    for (auto &bound : tree.opt_mix_bounds)
    {
        string bound_code;

        if (bound->rval->op != constraint::func_def::exp_node::op_type::MIN)
        {
            bound_code = format("{:<{}s} = {}", bound->lval, max_bound_name_len, exp_to_string(bound->rval));
            max_code_len = std::max(max_code_len, bound_code.size());
        }
        else
        {
            string params;
            for (auto &param : bound->rval->op_params)
            {
                params += exp_to_string(param) + ", ";
            }
            params.pop_back();
            params.pop_back();
            bound_code = format("{:<{}s} = min_list([{}])", bound->lval, max_bound_name_len, params);
        }
        bounds.push_back(std::move(bound_code));
        comments.push_back(bound->comment);
    }

    string ret;
    for (size_t i = 0; i < bounds.size(); i++)
    {
        ret += format("{:<{}s} # {}\n", bounds[i], max_code_len, comments[i]);
    }
    return ret;
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
        ret += format("{}.append({:<{}s}) # {}\n", constraint_name, constraints[i], maximum_length,
                      constraints_comments[i]);
    }
    return ret;
}

string Z3::generator::gen_approx_bound_constraint(string_view alias_in_exist) const
{
    return format("{} = {}\n"
                  "{}.append({} > {})\n"
                  "# the negation of the bound\n"
                  "neg_theorem = Exists({}, And({}))\n"
                  "{}.add(neg_theorem)\n",
                  bound_name, bound_to_prove, constraint_name, tree.opt_mix_bound_prefix, bound_name, alias_in_exist,
                  constraint_name, solver_name);
}
