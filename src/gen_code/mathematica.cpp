#include "mathematica.hpp"

using namespace mathematica;

mathematica::generator::generator(const constraint::optimization_tree &tree) : tree(tree), num_players(tree.num_players)
{
}

string mathematica::generator::gen_code(string_view file) const
{
    auto [alias_decl, vars] = gen_alias_and_param();
    auto opt_mix_func = gen_opt_mix_func();
    auto constraints = gen_constraints();
    auto opt_mix_bounds_decl = gen_opt_mix_bounds();
    auto approx_bound_optimization = gen_approx_bound_optimization(vars);

    auto preamble = format("(* Mathematica code generated from {} *)\n", file);

    return format("{}\n(* name alias and parameters *)\n{}\n"
                  "(* constraint for optimal mixing operation *)\n{}\n{}\n"
                  "(* constraints *)\n{}\n"
                  "(* optimization for approximation bounds *)\n{}\n",
                  preamble, alias_decl, opt_mix_func, opt_mix_bounds_decl, constraints, approx_bound_optimization);
}

tuple<string, string> mathematica::generator::gen_alias_and_param() const
{
    string alias_decl, vars;
    size_t max_length = 0;
    for (const auto &[_, alias] : tree.name_alias)
    {
        max_length = std::max(max_length, format("{}_f{}", alias, num_players).length());
    }
    for (const auto &param : tree.params)
    {
        max_length = std::max(max_length, param.length());
    }
    for (const auto &[name, alias] : tree.name_alias)
    {
        for (auto i = 1; i <= num_players; i++)
        {
            alias_decl += format("{}_U{};\t{:<{}}(* U{}{} *)\n", alias, i, " ",
                                 max_length - alias.length() - 2 - std::to_string(i).length(), i, name);
            alias_decl += format("{}_f{};\t{:<{}}(* f{}{} *)\n", alias, i, " ",
                                 max_length - alias.length() - 2 - std::to_string(i).length(), i, name);
            vars += format("{}_U{}, ", alias, i);
            vars += format("{}_f{}, ", alias, i);
        }
    }
    for (const auto &param : tree.params)
    {
        alias_decl += format("{};\t{:<{}}(* param {} *)\n", param, " ", max_length - param.length(), param);
        vars += format("{}, ", param);
    }
    vars.pop_back();
    vars.pop_back();
    return {alias_decl, vars};
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
        return format("({} && {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
    case op_type::OR:
        return format("({} || {})", exp_to_string(exp_node->op_params[0]), exp_to_string(exp_node->op_params[1]));
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
        return format("{}[{}]", exp_node->val, params);
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
        params += param + "_, ";
    }
    if (not params.empty())
    {
        params.pop_back();
        params.pop_back();
    }
    return format("{}[{}] :=\n\t{}\n\n", func_def_stmt->func_name, params, exp_to_string(func_def_stmt->body));
}

static string gen_optmix_def(const unique_ptr<constraint::func_def::func_def> &func_def_stmt)
{
    using op_type = constraint::func_def::exp_node::op_type;
    string body_str;
    auto &body = func_def_stmt->body;
    body_str += "Min[\n";
    auto &min_elements = body->op_params;
    // the two default end points
    body_str += "\t\tMax[";
    for (auto &ele : min_elements[0]->op_params) // max{a1,a2,...,ar}
    {
        body_str += exp_to_string(ele) + ", ";
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "],\n";

    body_str += "\t\tMax[";
    for (auto &ele : min_elements[1]->op_params) // max{b1,b2,...,br}
    {
        body_str += exp_to_string(ele) + ", ";
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "],\n";
    // the intersection cases
    for (auto &if_term : min_elements)
    {
        if (if_term->op != op_type::IF)
        {
            continue;
        }
        body_str +=
            format("\t\tIf[{}, {}, ", exp_to_string(if_term->op_params[0]), exp_to_string(if_term->op_params[1]));
        auto &if_false = if_term->op_params[2];
        if (if_false->op != op_type::MAX) // not a max list
        {
            body_str += format("\n\t\t\t{}],\n", exp_to_string(if_false));
        }
        else // a max list
        {
            body_str += "Max[\n";
            for (auto &max_ele : if_term->op_params[2]->op_params)
            {
                body_str += format("\t\t\t{},\n", exp_to_string(max_ele));
            }
            body_str.pop_back();
            body_str.pop_back();
            body_str += "]],\n";
        }
    }
    body_str.pop_back();
    body_str.pop_back();
    body_str += "]\n";
    string params;
    for (auto &param : func_def_stmt->func_param)
    {
        params += param + "_, ";
    }
    if (not params.empty())
    {
        params.pop_back();
        params.pop_back();
    }

    return format("{}[{}] :=\n\t{}\n\n", func_def_stmt->func_name, params, body_str);
}

string mathematica::generator::gen_opt_mix_func() const
{
    string ret;
    for (auto i = 0; i < tree.opt_mix_func_def.size() - 1; i++)
    {
        ret += gen_func_def(tree.opt_mix_func_def[i]);
    }
    ret += gen_optmix_def(*tree.opt_mix_func_def.rbegin());
    return ret;
}

string mathematica::generator::gen_opt_mix_bounds() const
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
            bound_code = format("{:<{}s} = {};", bound->lval, max_bound_name_len, exp_to_string(bound->rval));
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
            bound_code = format("{:<{}s} = Min[{}];", bound->lval, max_bound_name_len, params);
        }
        bounds.push_back(std::move(bound_code));
        comments.push_back(bound->comment);
    }

    string ret;
    for (size_t i = 0; i < bounds.size(); i++)
    {
        ret += format("{:<{}s}  (* {} *)\n", bounds[i], max_code_len, comments[i]);
    }
    return ret;
}

string mathematica::generator::gen_constraints() const
{
    auto ret = format("{} = {{\n", constraint_name);
    vector<string> constraints;
    vector<string> constraints_comments;
    unordered_map<string, string> empty_alias;
    for (const auto &constraint : tree.constraints)
    {
        auto constraint_str = constraint->to_string(tree.name_alias);
        auto comment_str = constraint->to_string(empty_alias);
        constraints.push_back(constraint_str);
        constraints_comments.push_back(comment_str);
    }
    for (size_t i = 0; i < constraints.size(); i++)
    {
        if (i == constraints.size() - 1)
        {
            ret += format("\t(* {} *)\n\t{}\n}};\n", constraints_comments[i], constraints[i]);
        }
        else
        {
            ret += format("\t(* {} *)\n\t{},\n", constraints_comments[i], constraints[i]);
        }
    }
    return ret;
}

string mathematica::generator::gen_approx_bound_optimization(string_view vars) const
{
    return format("NMaximize[{{{}, {}}}, {{{}}}, {}]\n", tree.opt_mix_bound_prefix, constraint_name, vars,
                  optimization_extra_param);
}
