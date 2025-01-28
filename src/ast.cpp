#include "ast.hpp"

void legone::ast_root::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        std::cout << std::endl << "ast_root begin: " << std::endl;
    }

    sym_tab.increase_scope();
    sym_tab.def_symbol("algo", "algo");

    // add default Ui and fi
    for (auto i = 1; i <= num_players; i++)
    {
        sym_tab.def_symbol(format("U{}", i), "payoff");
        sym_tab.def_symbol(format("f{}", i), format("f{}", i));
    }

    for (auto &op : operations)
    {
        op.second->walk(sym_tab, print);
    }
    algo->walk(sym_tab, print);
    sym_tab.decrease_scope();
    if (print)
    {
        std::cout << "ast_root end" << std::endl;
    }
}

legone::num_exp_node::num_exp_node(double val) : val(val)
{
    type = exp_type::NUM;
}

void legone::num_exp_node::display(ostream &os) const
{
    auto s = format("\t\t\texp_node: number: {}", val);
    os << s << endl;
}

void legone::num_exp_node::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        display(std::cout);
    }
}

legone::op_exp_node::op_exp_node(op_type o_type, unique_ptr<exp_node> left, unique_ptr<exp_node> right)
    : o_type(o_type), left(std::move(left)), right(std::move(right))
{
    type = exp_type::OP;
}

void legone::op_exp_node::display(ostream &os) const
{
    string op_str;
    switch (o_type)
    {
    case op_type::ADD:
        op_str = "+";
        break;
    case op_type::SUB:
        op_str = "-";
        break;
    case op_type::MUL:
        op_str = "*";
        break;
    case op_type::DIV:
        op_str = "/";
        break;
    default:
        throw std::runtime_error("Invalid op_type");
    }
    auto s = format("\t\t\texp_node: op: {}", op_str);
    os << s << endl;
}

void legone::op_exp_node::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        display(std::cout);
    }
    left->walk(sym_tab, print);
    right->walk(sym_tab, print);
}

legone::payoff_exp_node::payoff_exp_node(const string &payoff_name, vector<string> strategies)
    : payoff_name(payoff_name), strategies(std::move(strategies))
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

void legone::payoff_exp_node::walk(SymTab &sym_tab, bool print) const
{
    auto func_type = sym_tab.get_type(payoff_name);
    auto s = format("cannot resolve term {}(", payoff_name);
    for (auto &strategy : strategies)
    {
        s += strategy + ", ";
    }
    s.pop_back();
    s.pop_back();
    s += "): ";
    if (not func_type)
    {
        s += format("{} is not defined", payoff_name);

        throw std::runtime_error(s);
    }
    // check params type
    for (auto i = 0; i < strategies.size(); i++)
    {
        auto &strategy = strategies[i];
        auto param_type = sym_tab.get_type(strategy);
        if (not param_type)
        {
            s += format("{} is not defined", strategy);
            throw std::runtime_error(s);
        }
        if (*param_type != format("p{}", i + 1))
        {
            s += format("{} is not a strategy of player {}", strategy, i + 1);
            throw std::runtime_error(s);
        }
    }

    if (print)
    {
        display(std::cout);
    }
}

legone::f_val_exp_node::f_val_exp_node(const string &f_name, vector<string> strategies)
    : f_name(f_name), strategies(std::move(strategies))
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

void legone::f_val_exp_node::walk(SymTab &sym_tab, bool print) const
{
    auto func_type = sym_tab.get_type(f_name);
    auto s = format("cannot resolve term {}(", f_name);
    for (auto &strategy : strategies)
    {
        s += strategy + ", ";
    }
    s.pop_back();
    s.pop_back();
    s += "): ";
    if (not func_type)
    {
        s += format("{} is not defined", f_name);

        throw std::runtime_error(s);
    }
    // check params type
    for (auto i = 0; i < strategies.size(); i++)
    {
        auto &strategy = strategies[i];
        auto param_type = sym_tab.get_type(strategy);
        if (not param_type)
        {
            s += format("{} is not defined", strategy);
            throw std::runtime_error(s);
        }
        if (*param_type != format("p{}", i + 1))
        {
            s += format("{} is not a strategy of player {}", strategy, i + 1);
            throw std::runtime_error(s);
        }
    }

    if (print)
    {
        display(std::cout);
    }
}

legone::algo_node::algo_node(vector<unique_ptr<construct_stmt_node>> constructs, vector<string> rets)
    : constructs(std::move(constructs)), rets(std::move(rets))
{
}

void legone::algo_node::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        std::cout << "algo begin: " << std::endl;
    }
    sym_tab.increase_scope();
    for (auto &construct : constructs)
    {
        construct->walk(sym_tab, print);
    }
    sym_tab.decrease_scope();
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

legone::constraint_node::constraint_node(vector<tuple<string, basic_type>> quantifiers, unique_ptr<exp_node> left_exp,
                                         unique_ptr<exp_node> right_exp, comp_op op)
    : quantifiers(std::move(quantifiers)), left_exp(std::move(left_exp)), right_exp(std::move(right_exp)), op(op)
{
}

void legone::constraint_node::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        std::cout << "\tconstraint begin: " << std::endl;
    }

    auto print_quantifier = [](const tuple<string, basic_type> &quantifier) {
        string ret = std::get<0>(quantifier) + ":";
        if (std::get<1>(quantifier) == basic_type::Payoff)
        {
            ret += "Payoff";
        }
        else
        {
            ret += format("p{}", int(std::get<1>(quantifier)));
        }
        return ret;
    };

    // def quantifier symbols
    for (auto &quantifier : quantifiers)
    {
        auto &[q_name, q_type] = quantifier;
        if (sym_tab.get_type(q_name))
        {
            throw std::runtime_error(format("cannot claim quantifier ({}): symbol {} already used for another purpose",
                                            print_quantifier(quantifier), q_name));
        }
        if (q_type == basic_type::Payoff)
        {
            sym_tab.def_symbol(q_name, "Payoff");
        }
        else
        {
            sym_tab.def_symbol(q_name, std::format("p{}", int(q_type)));
        }
    }

    if (print)
    {
        if (quantifiers.size() > 0)
        {
            std::cout << "\t\tquantifiers: " << std::get<0>(quantifiers.at(0));
            for (auto i = 1; i < quantifiers.size(); i++)
            {
                std::cout << ", " << std::get<0>(quantifiers.at(i));
            }
            std::cout << std::endl;
        }
        else
        {
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

    if (print)
    {
        std::cout << "\t\tleft_exp: " << std::endl;
    }
    left_exp->walk(sym_tab, print);
    if (print)
    {
        std::cout << "\t\tright_exp: " << std::endl;
    }
    right_exp->walk(sym_tab, print);
    if (print)
    {
        std::cout << "\tconstraint end" << std::endl;
    }
}

legone::constraint_node::comp_op legone::constraint_node::str2comp_op(const string &op)
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

legone::construct_stmt_node::construct_stmt_node(vector<tuple<string, basic_type>> rets, const string &operation_name,
                                                 vector<unique_ptr<rparam_node>> rparams)
    : rets(std::move(rets)), operation_name(operation_name), rparams(std::move(rparams))
{
    if (this->rets.size() == 0)
    {
        throw std::runtime_error("Construct statement must have at least one return value");
    }
}

void legone::construct_stmt_node::walk(SymTab &sym_tab, bool print) const
{
    auto operation_type = sym_tab.get_type(operation_name);
    if (not operation_type)
    {
        throw std::runtime_error(format("{} is not defined in algo", operation_name, operation_name));
    }
    OperationType decl_type;
    try
    {
        decl_type = std::get<OperationType>(operation_type.value());
    }
    catch (const std::bad_variant_access &e)
    {
        throw std::runtime_error(format("{} is not an operation in algo", operation_name));
    }

    // check the type of real params
    for (auto i = 0; i < rparams.size(); i++)
    {

        if (rparams[i]->type == rparam_node::rparam_type::PAYOFF_EXP)
        {
            continue;
        }
        else
        {
            auto &rparam = dynamic_cast<strategy_rparam_node &>(*rparams[i]);
            auto supposed_type = decl_type.params_type[i];
            auto current_type = sym_tab.get_type(rparam.strategy_name);
            if (not current_type)
            {
                throw std::runtime_error(
                    format("error when calling {}: {} is not defined", operation_name, rparam.strategy_name));
            }
            if (supposed_type != current_type.value())
            {
                throw std::runtime_error(format("error when calling {}: {} does not have an expected type",
                                                operation_name, rparam.strategy_name));
            }
        }
    }

    if (print)
    {
        std::cout << "\tconstruct_stmt begin: " << std::endl;
        if (rets.size() > 0)
        {
            std::cout << "\t\trets: " << std::get<0>(rets.at(0)) << " : "
                      << static_cast<int>((std::get<1>(rets.at(0))));
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
        if (rparams.size() == 0)
        {
            std::cout << "none" << std::endl;
        }
        else
        {
            std::cout << std::endl;
        }
    }
    for (auto &rparam : rparams)
    {
        rparam->walk(sym_tab, print);
    }

    // def return symbols and check return type
    if (decl_type.ret_type.size() != rets.size())
    {
        throw std::runtime_error(format("error when calling {}: miss match number of arguments", operation_name));
    }
    auto print_type = [](const basic_type &ret_type) {
        if (ret_type == basic_type::Payoff)
        {
            return string("Payoff");
        }
        else
        {
            return format("p{}", int(ret_type));
        }
    };

    for (auto i = 0; i < rets.size(); i++)
    {
        auto current_type = print_type(std::get<1>(rets[i]));
        auto expected_type = decl_type.ret_type[i];
        if (current_type != expected_type)
        {
            throw std::runtime_error(
                format("error when calling {}: return type of {} is different from the expected one", operation_name,
                       std::get<0>(rets[i])));
        }
        sym_tab.def_symbol(std::get<0>(rets[i]), current_type);
    }

    if (print)
    {
        std::cout << "\tconstruct_stmt end" << std::endl;
    }
}

legone::strategy_rparam_node::strategy_rparam_node(const string &strategy_name) : strategy_name(strategy_name)
{
}

void legone::strategy_rparam_node::display(ostream &os) const
{
    os << "\t\t\trparam_node: strategy: " << strategy_name << endl;
}

void legone::strategy_rparam_node::walk(SymTab &sym_tab, bool print) const
{
    if (print)
    {
        display(std::cout);
    }
}

legone::payoff_exp_rparam_node::payoff_exp_rparam_node(vector<tuple<string, int>> linear_terms)
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
        if (coefficients.at(i) > 1)
        {
            payoff = format("{} * {}", coefficients.at(i), payoff);
        }
        else if (coefficients.at(i) < -1)
        {
            payoff = format("{} * {}", coefficients.at(i), payoff);
        }
        else if (coefficients.at(i) == -1)
        {
            payoff = format(" - {}", payoff);
        }
        else if (coefficients.at(i) == 0)
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

void legone::payoff_exp_rparam_node::walk(SymTab &sym_tab, bool print) const
{
    for (auto payoff_term : basic_payoffs)
    {
        auto term_type = sym_tab.get_type(payoff_term);
        if (not term_type)
        {
            throw std::runtime_error(
                format("error when using {} as a payoff: {} is not defined", payoff_term, payoff_term));
        }
        if (term_type.value() != "U")
        {
            throw std::runtime_error(
                format("error when using {} as a payoff: {} is not a payoff function", payoff_term, payoff_term));
        }
    }
    if (print)
    {
        display(std::cout);
    }
}

legone::operation_node::operation_node(const string &name, vector<tuple<string, basic_type>> fparams,
                                       vector<basic_type> ret_types, unordered_set<string> extra_params,
                                       vector<unique_ptr<constraint_node>> constraints, vector<string> ret_names)
    : name(name), fparams(std::move(fparams)), extra_params(std::move(extra_params)),
      constraints(std::move(constraints))
{
    if (ret_names.size() != ret_types.size())
        throw std::runtime_error("ret_names and ret_types must have the same size");
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

void legone::operation_node::walk(SymTab &sym_tab, bool print) const
{
    auto print_type = [](const basic_type &ret_type) {
        if (ret_type == basic_type::Payoff)
        {
            return string("Payoff");
        }
        else
        {
            return format("p{}", int(ret_type));
        }
    };
    // def the operation symbol
    OperationType operation_type;
    for (auto &fparam : fparams)
    {
        operation_type.params_type.emplace_back(print_type(std::get<1>(fparam)));
    }
    for (auto &ret : rets)
    {
        operation_type.ret_type.emplace_back(print_type(std::get<1>(ret)));
    }
    sym_tab.def_symbol(name, operation_type);

    sym_tab.increase_scope();

    // def the formal parameters and returns
    for (auto &[param_name, param_type] : fparams)
    {
        sym_tab.def_symbol(param_name, print_type(param_type));
    }
    for (auto &[ret_name, ret_type] : rets)
    {
        sym_tab.def_symbol(ret_name, print_type(ret_type));
    }

    // def the extra parameter symbols
    for (auto &extra_param : extra_params)
    {
        sym_tab.def_symbol(extra_param, "param");
    }
    if (print)
    {
        std::cout << "operation begin: " << std::endl;
        std::cout << "\tname: " << name << std::endl;
        std::cout << "\tfparams: ";
        if (fparams.size() == 0)
        {
            std::cout << "none" << std::endl;
        }
        else
        {
            std::cout << std::endl;
        }
        for (auto &fparam : fparams)
        {
            std::cout << "\t\t" << std::get<0>(fparam) << " : " << static_cast<int>(std::get<1>(fparam)) << std::endl;
        }
        std::cout << "\trets: ";
        if (rets.size() == 0)
        {
            std::cout << "none" << std::endl;
        }
        else
        {
            std::cout << std::endl;
        }
        for (auto &ret : rets)
        {
            std::cout << "\t\t" << std::get<0>(ret) << " : " << static_cast<int>(std::get<1>(ret)) << std::endl;
        }
        std::cout << "\textra_params: ";
        if (extra_params.size() == 0)
        {
            std::cout << "none" << std::endl;
        }
        else
        {
            std::cout << std::endl;
        }
        for (auto &extra_param : extra_params)
        {
            std::cout << "\t\t" << extra_param << std::endl;
        }
        std::cout << "\tconstraints: ";
        if (constraints.size() == 0)
        {
            std::cout << "none" << std::endl;
        }
        else
        {
            std::cout << std::endl;
        }
    }
    for (auto &constraint : constraints)
    {
        constraint->walk(sym_tab, print);
    }

    sym_tab.decrease_scope();
    if (print)
    {
        std::cout << "operation end" << std::endl << std::endl;
    }
}

bool legone::operator==(const Type &a, const Type &b)
{
    if (a.index() != b.index())
    {
        return false;
    }
    return std::visit([](auto &&arg1, auto &&arg2) { return arg1 == arg2; }, a, b);
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

void legone::param_exp_node::walk(SymTab &sym_tab, bool print) const
{
    if (not sym_tab.get_type(param_name))
    {
        throw std::runtime_error(format("symbol {} is not defined", param_name));
    }
    if (print)
    {
        display(std::cout);
    }
}

void legone::SymTab::def_symbol(const string &symbol, const Type &sym_type)
{
    auto &scope = *tab.rbegin();
    if (scope.contains(symbol))
    {
        throw std::runtime_error(format("cannot define symbol {}: it was already defined.", symbol));
    }
    scope[symbol] = sym_type;
}

optional<legone::Type> legone::SymTab::get_type(const string &symbol) const
{
    for (auto scope = tab.rbegin(); scope != tab.rend(); scope--)
    {
        if (not scope->contains(symbol))
        {
            continue;
        }
        return scope->at(symbol);
    }
    return std::nullopt;
}

void legone::SymTab::increase_scope()
{
    tab.push_back(unordered_map<string, Type>());
}

void legone::SymTab::decrease_scope()
{
    if (tab.size() > 0)
    {
        tab.pop_back();
    }
}

bool legone::OperationType::operator==(const OperationType &other)
{
    if (params_type.size() != other.params_type.size())
    {
        return false;
    }
    if (ret_type.size() != other.ret_type.size())
    {
        return false;
    }
    for (auto i = 0; i < params_type.size(); i++)
    {
        if (params_type[i] != other.params_type[i])
        {
            return false;
        }
    }
    for (auto i = 0; i < ret_type.size(); i++)
    {
        if (ret_type[i] != other.ret_type[i])
        {
            return false;
        }
    }
    return true;
}
