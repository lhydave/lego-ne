#include "constraint.hpp"
using namespace constraint;

unique_ptr<exp_node> constraint::num_exp_node::clone(const unordered_map<string, string> &instantiated_var) const
{
    return make_unique<num_exp_node>(value);
}

string constraint::num_exp_node::to_string(const unordered_map<string, string> &name_alias) const
{
    return std::to_string(value);
}

unique_ptr<exp_node> constraint::op_exp_node::clone(const unordered_map<string, string> &instantiated_var) const
{
    return make_unique<op_exp_node>(op, left->clone(instantiated_var), right->clone(instantiated_var));
}

string constraint::op_exp_node::to_string(const unordered_map<string, string> &name_alias) const
{
    string op_string;
    switch (op)
    {
    case op_type::ADD:
        op_string = "+";
        break;
    case op_type::SUB:
        op_string = "-";
        break;
    case op_type::MUL:
        op_string = "*";
        break;
    case op_type::DIV:
        op_string = "/";
        break;
    case op_type::LEQ:
        op_string = "<=";
        break;
    case op_type::EQ:
        op_string = "==";
        break;
    case op_type::GEQ:
        op_string = ">=";
        break;
    default:
        throw std::runtime_error("Unsupported operation type");
    }
    return format("({} {} {})", left->to_string(name_alias), op_string, right->to_string(name_alias));
}

unique_ptr<exp_node> constraint::payoff_exp_node::clone(const unordered_map<string, string> &instantiated_var) const
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

string constraint::payoff_exp_node::to_string(const unordered_map<string, string> &name_alias) const
{
    auto strategies_string = strategy_to_string(strategies);
    if (name_alias.find(strategies_string) != name_alias.end()) // use name alias
    {
        strategies_string = name_alias.at(strategies_string);
        return format("{}_{}", strategies_string, payoff_name);
    }
    // ordinary presentation
    return format("{}{}", payoff_name, strategies_string);
}

unique_ptr<exp_node> constraint::f_val_exp_node::clone(const unordered_map<string, string> &instantiated_var) const
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

string constraint::f_val_exp_node::to_string(const unordered_map<string, string> &name_alias) const
{
    auto strategies_string = strategy_to_string(strategies);
    if (name_alias.find(strategies_string) != name_alias.end()) // use name alias
    {
        strategies_string = name_alias.at(strategies_string);
        return format("{}_{}", strategies_string, f_name);
    }
    // ordinary presentation
    return format("{}{}", f_name, strategies_string);
}

unique_ptr<exp_node> constraint::param_exp_node::clone(const unordered_map<string, string> &instantiated_var) const
{
    return make_unique<param_exp_node>(param_name);
}

string constraint::param_exp_node::to_string(const unordered_map<string, string> &name_alias) const
{
    return param_name;
}

void constraint::optimization_tree::gen_tree(const legone::ast_root &ast)
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
    // put in all payoff names
    player_strategies[0] = unordered_set<string>();
    for (int i = 1; i <= num_players; i++)
    {
        player_strategies[0].insert(format("U{}", i));
    }

    // generate all name_alias
    gen_alias();
    // generate all constraints
    for (const auto &construct : ast.algo->constructs)
    {
        auto operation_name = construct->operation_name;
        const auto &operation = ast.operations.at(operation_name);
        // push in all extra params
        for (const auto &param : operation->extra_params)
        {
            params.insert(param);
        }
        for (const auto &constraint : operation->constraints)
        {
            auto quantified_constraint = constraint_node2constraint(constraint, operation, construct);
            // eliminate quantifiers
            deque<tuple<string, int>> quantifiers;
            for (const auto &[name, type] : constraint->quantifiers)
            {
                quantifiers.push_back({name, static_cast<int>(type)});
            }
            unordered_map<string, string> instantiated_var;
            quantifier_eliminate(quantified_constraint, quantifiers, instantiated_var);
            // also eliminate quantifiers but keep one
            auto num_quantifier = quantifiers.size();
            for (size_t i = 0; i < num_quantifier; i++)
            {
                auto [var, type] = quantifiers.front();
                quantifiers.pop_front();
                quantifiers.push_back({var, type});
                quantifier_eliminate_with_f(quantified_constraint, quantifiers, instantiated_var);
            }
        }
    }
    // generate optimal mixing definitions
    gen_opt_mix_func_def();

    // generate optimal mixing bounds
    gen_opt_mix_bounds();
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

void constraint::optimization_tree::generate_combinations(vector<vector<string>> &combinations, vector<string> &current,
                                                          int depth, vector<int> &player_indices)
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

void constraint::optimization_tree::print_constraints(ostream &os, bool with_alias) const
{
    if (with_alias)
    {
        for (const auto &constraint : constraints)
        {
            os << constraint->to_string(name_alias) << ',' << endl;
        }
        return;
    }
    // create an empty alias
    unordered_map<string, string> empty_alias;
    for (const auto &constraint : constraints)
    {
        os << constraint->to_string(empty_alias) << ',' << endl;
    }
}

static string join(const vector<string> &vec, string_view delim)
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
        generate for all (x1,x2,...), where xk is the strategy name for player
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
    std::iota(begin(player_indices), end(player_indices), 1);

    generate_combinations(strategy_combinations, current, 0, player_indices);

    for (size_t i = 0; i < strategy_combinations.size(); ++i)
    {
        string alias = aliases[i];
        name_alias["(" + join(strategy_combinations[i], ",") + ")"] = alias;
    }
}

static vector<string> replace_fstrategy_with_rstrategy(const vector<tuple<string, legone::basic_type>> &fparams,
                                                       const vector<unique_ptr<legone::rparam_node>> &rparams,
                                                       const vector<tuple<string, legone::basic_type>> &frets,
                                                       const vector<tuple<string, legone::basic_type>> &rrets,
                                                       const vector<string> &strategies)
{
    vector<string> result;
    for (auto &strategy : strategies)
    {
        // check fparam
        auto it = find_if(fparams.begin(), fparams.end(),
                          [&strategy](const tuple<string, legone::basic_type> &p) { return get<0>(p) == strategy; });
        if (it != fparams.end())
        {
            auto index = std::distance(fparams.begin(), it);
            result.push_back(dynamic_cast<const legone::strategy_rparam_node *>(rparams[index].get())->strategy_name);
        }
        // check rets
        else
        {
            auto it = find_if(frets.begin(), frets.end(), [&strategy](const tuple<string, legone::basic_type> &p) {
                return get<0>(p) == strategy;
            });
            if (it != frets.end())
            {
                auto index = std::distance(frets.begin(), it);
                result.push_back(std::get<0>(rrets.at(index)));
            }
            else
            {
                result.push_back(strategy);
            }
        }
    }
    return result;
}

static unique_ptr<exp_node> replace_fpayoff_with_rpayoff(const legone::payoff_exp_node &payoff_exp,
                                                         const vector<tuple<string, legone::basic_type>> &fparams,
                                                         const vector<unique_ptr<legone::rparam_node>> &rparams,
                                                         const vector<tuple<string, legone::basic_type>> &frets,
                                                         const vector<tuple<string, legone::basic_type>> &rrets)
{
    auto new_strategies = replace_fstrategy_with_rstrategy(fparams, rparams, frets, rrets, payoff_exp.strategies);

    // find the location of the payoff in rparams
    auto it = find_if(fparams.begin(), fparams.end(), [&payoff_exp](const tuple<string, legone::basic_type> &p) {
        return get<0>(p) == payoff_exp.payoff_name;
    });
    if (it == fparams.end()) // the payoff is not in fparams
    {
        return make_unique<payoff_exp_node>(payoff_exp.payoff_name, new_strategies);
    }
    auto index = std::distance(fparams.begin(), it);
    auto payoff_rparam = dynamic_cast<const legone::payoff_exp_rparam_node *>(rparams.at(index).get());
    // build the tree for the new payoff
    unique_ptr<exp_node> root = make_unique<payoff_exp_node>(payoff_rparam->basic_payoffs.at(0), new_strategies);
    for (size_t i = 1; i < payoff_rparam->basic_payoffs.size(); i++)
    {
        auto op_type = constraint::op_exp_node::op_type::ADD;
        if (payoff_rparam->coefficients.at(i) < 0)
        {
            op_type = constraint::op_exp_node::op_type::SUB;
        }
        auto new_payoff = make_unique<payoff_exp_node>(payoff_rparam->basic_payoffs.at(i), new_strategies);
        auto new_coeff = make_unique<num_exp_node>(std::abs(payoff_rparam->coefficients.at(i)));
        if (std::abs(new_coeff->value) != 1)
        {
            auto mul_node = make_unique<op_exp_node>(constraint::op_exp_node::op_type::MUL, std::move(new_coeff),
                                                     std::move(new_payoff));
            root = make_unique<op_exp_node>(op_type, std::move(root), std::move(mul_node));
        }
        else
        {
            root = make_unique<op_exp_node>(op_type, std::move(root), std::move(new_payoff));
        }
    }
    return root;
}

unique_ptr<exp_node> optimization_tree::legone_ast_walk(const unique_ptr<legone::exp_node> &exp,
                                                        const unique_ptr<legone::operation_node> &operation,
                                                        const unique_ptr<legone::construct_stmt_node> &construct)
{
    if (exp->type == legone::exp_node::exp_type::NUM)
    {
        const auto num_exp = dynamic_cast<const legone::num_exp_node *>(exp.get());
        return make_unique<num_exp_node>(num_exp->val);
    }
    else if (exp->type == legone::exp_node::exp_type::OP)
    {
        const auto op_exp = dynamic_cast<const legone::op_exp_node *>(exp.get());
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
        default:
            throw std::runtime_error("Unsupported operation type");
        }
        return make_unique<op_exp_node>(op_type, legone_ast_walk(op_exp->left, operation, construct),
                                        legone_ast_walk(op_exp->right, operation, construct));
    }
    else if (exp->type == legone::exp_node::exp_type::PARAM)
    {
        const auto param_exp = dynamic_cast<const legone::param_exp_node *>(exp.get());
        params.insert(param_exp->param_name);
        return make_unique<param_exp_node>(param_exp->param_name);
    }
    else if (exp->type == legone::exp_node::exp_type::F_VAL)
    {
        const auto f_val_exp = dynamic_cast<const legone::f_val_exp_node *>(exp.get());
        return make_unique<f_val_exp_node>(
            f_val_exp->f_name, replace_fstrategy_with_rstrategy(operation->fparams, construct->rparams, operation->rets,
                                                                construct->rets, f_val_exp->strategies));
    }
    else if (exp->type == legone::exp_node::exp_type::PAYOFF)
    {
        return replace_fpayoff_with_rpayoff(*dynamic_cast<const legone::payoff_exp_node *>(exp.get()),
                                            operation->fparams, construct->rparams, operation->rets, construct->rets);
    }
    else
    {
        throw std::runtime_error("Unsupported expression type");
    }
}

unique_ptr<exp_node> constraint::optimization_tree::constraint_node2constraint(
    const unique_ptr<legone::constraint_node> &constraint, const unique_ptr<legone::operation_node> &operation,
    const unique_ptr<legone::construct_stmt_node> &construct)
{
    auto left_exp = legone_ast_walk(constraint->left_exp, operation, construct);
    auto right_exp = legone_ast_walk(constraint->right_exp, operation, construct);
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
    default:
        throw std::runtime_error("Unsupported operation type");
    }
    return make_unique<op_exp_node>(op_type, std::move(left_exp), std::move(right_exp));
}

void constraint::optimization_tree::quantifier_eliminate(const unique_ptr<exp_node> &exp,
                                                         deque<tuple<string, int>> &quantifiers,
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
    // restore the quantifier
    quantifiers.push_back({var, type});
}

/*
    for quantifier forall xi:i, when there is a Ui(x1, x2, ..., xi, ...,
   xn), replace it with fi(x1, x2, ..., xi, ..., xn)+Ui(x1, x2, ..., xi,
   ..., xn) but instantiate xi with a strategy
*/
static void change_payoff2f(unique_ptr<exp_node> &exp, int player_index, string_view var_name)
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
        if (payoff_index == player_index and payoff_exp.strategies.at(player_index - 1) == var_name)
        {
            auto new_f_val = make_unique<f_val_exp_node>(format("f{}", payoff_index), payoff_exp.strategies);
            auto new_op =
                make_unique<op_exp_node>(op_exp_node::op_type::ADD, std::move(op_exp.left), std::move(new_f_val));
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
        if (payoff_index == player_index and payoff_exp.strategies.at(player_index - 1) == var_name)
        {
            auto new_f_val = make_unique<f_val_exp_node>(format("f{}", payoff_index), payoff_exp.strategies);
            auto new_op =
                make_unique<op_exp_node>(op_exp_node::op_type::ADD, std::move(op_exp.right), std::move(new_f_val));
            op_exp.right = std::move(new_op);
        }
    }
    else // internal node
    {
        change_payoff2f(op_exp.right, player_index, var_name);
    }
}

static void identity_check_walk(unique_ptr<exp_node> &exp, int player_index, string_view var_name,
                                unordered_set<string> &identity_set)
{
    if (identity_set.size() > 1)
    {
        return;
    }
    if (exp->type == exp_node::exp_type::OP)
    {
        auto &op_exp = dynamic_cast<op_exp_node &>(*exp);
        identity_check_walk(op_exp.left, player_index, var_name, identity_set);
        identity_check_walk(op_exp.right, player_index, var_name, identity_set);
    }
    else if (exp->type == exp_node::exp_type::PAYOFF)
    {
        auto &payoff_exp = dynamic_cast<payoff_exp_node &>(*exp);
        if (payoff_exp.strategies.at(player_index - 1) == var_name)
        {
            identity_set.insert(payoff_exp.payoff_name + strategy_to_string(payoff_exp.strategies));
        }
    }
    else if (exp->type == exp_node::exp_type::F_VAL)
    {
        auto &f_val_exp = dynamic_cast<f_val_exp_node &>(*exp);
        if (f_val_exp.strategies.at(player_index - 1) == var_name)
        {
            identity_set.insert(f_val_exp.f_name + strategy_to_string(f_val_exp.strategies));
        }
    }
}

void constraint::optimization_tree::quantifier_eliminate_with_f(const unique_ptr<exp_node> &exp,
                                                                deque<tuple<string, int>> &quantifiers,
                                                                unordered_map<string, string> &instantiated_var)
{
    // the final quantifier, but a payoff quantifier
    if (quantifiers.size() == 1 and std::get<1>(quantifiers.front()) == 0)
    {
        return;
    }
    // the final quantifier, and a strategy quantifier
    if (quantifiers.size() == 1)
    {
        auto one_quantified_exp = exp->clone(instantiated_var);
        // do the identity check
        unordered_set<string> identity_set;
        identity_check_walk(one_quantified_exp, std::get<1>(quantifiers.front()), std::get<0>(quantifiers.front()),
                            identity_set);
        if (identity_set.size() > 1) // not the same identity, cannot eliminate
        {
            return;
        }
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
    // not the final quantifier
    auto [var, type] = quantifiers.back();
    quantifiers.pop_back();
    for (const auto &strategy : player_strategies[type])
    {
        instantiated_var[var] = strategy;
        quantifier_eliminate_with_f(exp, quantifiers, instantiated_var);
        instantiated_var.erase(var);
    }
    // restore the quantifier
    quantifiers.push_back({var, type});
}

string constraint::strategy_to_string(const vector<string> &strategies)
{
    string result = format("({}", strategies.at(0));
    for (size_t i = 1; i < strategies.size(); i++)
    {
        result += format(",{}", strategies.at(i));
    }
    result += ")";
    return result;
}

constraint::func_def::exp_node::exp_node(op_type op, vector<unique_ptr<exp_node>> op_params)
    : op(op), op_params(std::move(op_params))
{
    if (op == op_type::VAR or op == op_type::NUM)
    {
        throw std::runtime_error("calling wrong constructor of constraint::func_def::exp_node::exp_node");
    }
}

constraint::func_def::exp_node::exp_node(op_type op, string_view val) : op(op), val(val)
{
    if (op != op_type::VAR and op != op_type::NUM)
    {
        throw std::runtime_error("calling wrong constructor of constraint::func_def::exp_node::exp_node");
    }
}

constraint::func_def::exp_node::exp_node(op_type op, string_view val, vector<unique_ptr<exp_node>> op_params)
    : op(op), val(val), op_params(std::move(op_params))
{
    if (op != op_type::FUNC_CALL)
    {
        throw std::runtime_error("calling wrong constructor of constraint::func_def::exp_node::exp_node");
    }
}

constraint::func_def::func_def::func_def(string_view func_name, const vector<string> &func_param,
                                         unique_ptr<exp_node> body)
    : func_name(func_name), func_param(func_param), body(std::move(body))
{
}

constraint::func_def::assign_stmt::assign_stmt(string_view lval, unique_ptr<exp_node> rval, string_view comment)
    : lval(lval), rval(std::move(rval)), comment(comment)
{
}

/******************** gen_opt_mix_func ****************************/

// convenient to construct ast
static auto as_var(string_view var_name)
{
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::VAR, var_name);
}

static auto as_num(int num)
{
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::NUM, std::to_string(num));
}

static auto cal_add(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::ADD, std::move(params));
}

static auto cal_sub(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::SUB, std::move(params));
}

static auto cal_div(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::DIV, std::move(params));
}

static auto cal_mul(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::MUL, std::move(params));
}

static auto le(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::LE, std::move(params));
}

static auto ge(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::GE, std::move(params));
}

static auto cal_and(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::AND, std::move(params));
}

static auto cal_or(unique_ptr<func_def::exp_node> a, unique_ptr<func_def::exp_node> b)
{
    auto params = vector<std::unique_ptr<func_def::exp_node>>();
    params.push_back(std::move(a));
    params.push_back(std::move(b));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::OR, std::move(params));
}

// generate a function that computes the intersection point
static auto gen_intersect_point()
{
    auto ret_body = cal_div(cal_sub(as_var("a1"), as_var("a2")),
                            cal_sub(cal_sub(cal_add(as_var("a1"), as_var("b2")), as_var("a2")), as_var("b1")));
    return make_unique<func_def::func_def>(optimization_tree::intersect_point_func_name,
                                           vector<string>{"a1", "a2", "b1", "b2"}, std::move(ret_body));
}

// generate a function that computes the intersection value on two end points
static auto gen_intersect_val()
{
    auto ret_body =
        cal_add(cal_mul(as_var("a"), cal_sub(as_num(1), as_var("lam"))), cal_mul(as_var("b"), as_var("lam")));
    return make_unique<func_def::func_def>(optimization_tree::intersect_val_func_name,
                                           vector<string>{"a", "b", "lam"}, std::move(ret_body));
}

// generate the maximum term of i,j
static auto gen_max_intersect(int i, int j, int num_player)
{
    auto if_cond_1 = cal_or(le(as_var(format("vara{}", i)), as_var(format("vara{}", j))),
                             ge(as_var(format("varb{}", i)), as_var(format("varb{}", j))));
    auto if_cond_2 = cal_or(ge(as_var(format("vara{}", i)), as_var(format("vara{}", j))),
                             le(as_var(format("varb{}", i)), as_var(format("varb{}", j))));
    auto if_cond = cal_and(std::move(if_cond_1), std::move(if_cond_2));

    vector<unique_ptr<func_def::exp_node>> max_list;
    auto max_ij = std::max(i, j);
    for (auto k = 1; k <= num_player; k++)
    {
        if (k == max_ij) // skip one of i,j term and only keep one i,j term.
        {
            continue;
        }
        auto inter_pt_param = vector<unique_ptr<func_def::exp_node>>();
        inter_pt_param.emplace_back(as_var(format("vara{}", i)));
        inter_pt_param.emplace_back(as_var(format("vara{}", j)));
        inter_pt_param.emplace_back(as_var(format("varb{}", i)));
        inter_pt_param.emplace_back(as_var(format("varb{}", j)));
        auto inter_pt =
            make_unique<func_def::exp_node>(func_def::exp_node::op_type::FUNC_CALL,
                                            optimization_tree::intersect_point_func_name, std::move(inter_pt_param));
        auto inter_val_param = vector<unique_ptr<func_def::exp_node>>();
        inter_val_param.emplace_back(as_var(format("vara{}", k)));
        inter_val_param.emplace_back(as_var(format("varb{}", k)));
        inter_val_param.push_back(std::move(inter_pt));

        max_list.push_back(make_unique<func_def::exp_node>(func_def::exp_node::op_type::FUNC_CALL,
                                                           optimization_tree::intersect_val_func_name,
                                                           std::move(inter_val_param)));
    }
    unique_ptr<func_def::exp_node> if_false;
    if (max_list.size() == 1)
    {
        if_false = std::move(max_list.at(0));
    }
    else
    {
        if_false = make_unique<func_def::exp_node>(func_def::exp_node::op_type::MAX, std::move(max_list));
    }
    vector<unique_ptr<func_def::exp_node>> if_exp_param;
    if_exp_param.push_back(std::move(if_cond));
    if_exp_param.emplace_back(as_num(1));
    if_exp_param.push_back(std::move(if_false));
    return make_unique<func_def::exp_node>(func_def::exp_node::op_type::IF, std::move(if_exp_param));
}

// generate the default term
static auto gen_default(int num_player)
{
    vector<unique_ptr<func_def::exp_node>> a_list, b_list;
    for (auto i = 1; i <= num_player; i++)
    {
        a_list.emplace_back(as_var(format("vara{}", i)));
        b_list.emplace_back(as_var(format("varb{}", i)));
    }
    auto max_a = make_unique<func_def::exp_node>(func_def::exp_node::op_type::MAX, std::move(a_list));
    auto max_b = make_unique<func_def::exp_node>(func_def::exp_node::op_type::MAX, std::move(b_list));
    return std::make_tuple(std::move(max_a), std::move(max_b));
}

void constraint::optimization_tree::gen_opt_mix_func_def()
{
    opt_mix_func_def.emplace_back(gen_intersect_point());
    opt_mix_func_def.emplace_back(gen_intersect_val());

    // generate the true optimal mixing function
    vector<unique_ptr<func_def::exp_node>> min_list;
    auto [max_a, max_b] = gen_default(num_players);
    min_list.push_back(std::move(max_a));
    min_list.push_back(std::move(max_b));
    for (auto i = 1; i <= num_players; i++)
    {
        for (auto j = i + 1; j <= num_players; j++)
        {
            min_list.emplace_back(gen_max_intersect(i, j, num_players));
        }
    }
    auto opt_mix_func_body = make_unique<func_def::exp_node>(func_def::exp_node::op_type::MIN, std::move(min_list));
    vector<string> opt_mix_param;
    for (auto i = 1; i <= num_players; i++)
    {
        opt_mix_param.emplace_back(format("vara{}", i));
        opt_mix_param.emplace_back(format("varb{}", i));
    }
    opt_mix_func_def.push_back(
        make_unique<func_def::func_def>(opt_mix_func_name, opt_mix_param, std::move(opt_mix_func_body)));
}

/*********************** gen_opt_mix_bounds **************************/

static void gen_all_combinations_with_one_fix(int num_players, int fix_player_id,
                                              const unordered_map<int, unordered_set<string>> &player_strategies,
                                              vector<vector<string>> &combinations, vector<string> &current, int depth,
                                              vector<int> &player_indices)
{
    if (depth == num_players)
    {
        combinations.push_back(current);
        return;
    }
    if (player_indices[depth] == fix_player_id)
    {
        depth += 1; // skip the fixed player
        if (depth == num_players)
        {
            combinations.push_back(current);
            return;
        }
    }
    for (const auto &strategy : player_strategies.at(player_indices[depth]))
    {
        current[depth] = strategy;
        gen_all_combinations_with_one_fix(num_players, fix_player_id, player_strategies, combinations, current,
                                          depth + 1, player_indices);
    }
}

static auto gen_all_opt_mix_pairs(int num_players, const unordered_map<int, unordered_set<string>> &player_strategies)
{
    vector<tuple<vector<string>, vector<string>>> ret;
    // generate all pairs of strategies for each player
    unordered_map<int, vector<tuple<string, string>>> strategy_pairs;
    for (auto i = 1; i <= num_players; i++)
    {
        vector<tuple<string, string>> pairs;
        for (auto iter = player_strategies.at(i).begin(); iter != player_strategies.at(i).end(); iter++)
        {
            auto iter2 = iter;
            ++iter2;
            for (; iter2 != player_strategies.at(i).end(); iter2++)
            {
                pairs.push_back(std::make_tuple(*iter, *iter2));
            }
        }
        strategy_pairs[i] = pairs;
    }
    // generate all strategy combinations with one fixed player
    vector<int> player_indices(num_players);
    std::iota(player_indices.begin(), player_indices.end(), 1);
    for (auto fix_player_id = 1; fix_player_id <= num_players; fix_player_id++)
    {
        if (strategy_pairs[fix_player_id].empty()) // cannot form a pair
        {
            continue;
        }
        vector<vector<string>> combinations;
        vector<string> current(num_players);
        gen_all_combinations_with_one_fix(num_players, fix_player_id, player_strategies, combinations, current, 0,
                                          player_indices);
        for (const auto &combination : combinations)
        {
            for (const auto &[pair1, pair2] : strategy_pairs.at(fix_player_id))
            {
                auto ret_pair = make_tuple(combination, combination);
                std::get<0>(ret_pair)[fix_player_id - 1] = pair1;
                std::get<1>(ret_pair)[fix_player_id - 1] = pair2;
                ret.push_back(std::move(ret_pair));
            }
        }
    }
    return ret;
}

static auto final_bound(int num_edges, string_view opt_mix_bound_prefix)
{
    if (num_edges == 1)
    {
        return make_unique<func_def::assign_stmt>(opt_mix_bound_prefix, as_var(format("{}1", opt_mix_bound_prefix)),
                                                  "final bound");
    }
    vector<unique_ptr<func_def::exp_node>> min_list;
    for (auto i = 1; i <= num_edges; i++)
    {
        min_list.emplace_back(as_var(format("{}{}", opt_mix_bound_prefix, i)));
    }
    auto bound_exp = make_unique<func_def::exp_node>(func_def::exp_node::op_type::MIN, std::move(min_list));
    return make_unique<func_def::assign_stmt>(opt_mix_bound_prefix, std::move(bound_exp), "final bound");
}

void constraint::optimization_tree::gen_opt_mix_bounds()
{
    auto all_pair_combinations = gen_all_opt_mix_pairs(num_players, player_strategies);
    num_edges = all_pair_combinations.size();
    int count = 0;
    for (const auto &[pair1, pair2] : all_pair_combinations)
    {
        count += 1;
        auto endpoint_a = constraint::strategy_to_string(pair1);
        auto endpoint_a_alias = name_alias.at(endpoint_a);
        auto endpoint_b = constraint::strategy_to_string(pair2);
        auto endpoint_b_alias = name_alias.at(endpoint_b);
        auto lval = format("{}{}", opt_mix_bound_prefix, count);
        vector<unique_ptr<func_def::exp_node>> func_param;
        for (auto i = 1; i <= num_players; i++)
        {
            func_param.emplace_back(as_var(format("{}_f{}", endpoint_a_alias, i)));
            func_param.emplace_back(as_var(format("{}_f{}", endpoint_b_alias, i)));
        }
        auto rval = make_unique<func_def::exp_node>(func_def::exp_node::op_type::FUNC_CALL, opt_mix_func_name,
                                                    std::move(func_param));
        auto comment = format("line {} -- {}", endpoint_a, endpoint_b);
        opt_mix_bounds.push_back(make_unique<func_def::assign_stmt>(lval, std::move(rval), comment));
    }
    opt_mix_bounds.emplace_back(final_bound(num_edges, opt_mix_bound_prefix));
}