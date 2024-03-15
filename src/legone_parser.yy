/* The parser file to build AST from LegoNE code */
%language "c++"
%skeleton "lalr1.cc"
%require "3.8.2"

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {
    #include<string>
    #include "ast.hpp"
    class driver;
    using namespace legone; // this is the parser of legone
}

%param { driver& drv }

%locations
%define parse.trace
%define parse.error detailed
%define parse.lac full

%code {
    #include "driver.hpp"
}

%define api.token.prefix {TOK_}
%token
  ASSIGN       "="
  MINUS        "-"
  PLUS         "+"
  STAR         "*"
  LPAREN       "("
  RPAREN       ")"
  RPAREN_DOT   ")."
  LBRACKET     "["
  RBRACKET     "]"
  COLON        ":"
  COMMA        ","
  EQ           "=="
  LEQ          "<="
  GEQ          ">="
  ARROW        "->"
  DEF          "def"
  RETURN       "return"
  FORALL       "forall"
  LIST_T       "List"
  PAYOFF_T     "Payoff"
  DESCRIPTION  "description"
  EXTRA_PARAMS "extra_params"
  CONSTRAINTS  "constraints"
  ALGO         "algo"
  NUM_PLAYERS  "num_players"
  NEWLINE
  INDENT
  DEDENT
;
%token <int> NUMBER "number"
%token <string> IDENTIFIER "identifier"
%token <string> F_NAME "f"
%token <string> PAYOFF_NAME "payoff_name"
%token <string> STRING "string"
%token <basic_type> PLAYER_T "player_type"

%nterm <size_t> n_player_decl
%nterm <unordered_map<string, unique_ptr<operation_node>>> operation_defs
%nterm <unique_ptr<operation_node>> operation_def
%nterm <string> operation_name
%nterm <vector<tuple<string, basic_type>>> operation_fparams
%nterm <tuple<string, basic_type>> operation_fparam
%nterm <tuple<string, basic_type>> strategy_fparam
%nterm <tuple<string, basic_type>> payoff_fparam

%nterm <tuple<unordered_set<string>, vector<unique_ptr<constraint_node>>, vector<string>>> operation_body
%nterm description_stmt
%nterm <unordered_set<string>> extra_params_stmt
%nterm <unordered_set<string>> param_list
%nterm <vector<unique_ptr<constraint_node>>> constraints_stmt
%nterm <vector<unique_ptr<constraint_node>>> constraint_list
%nterm <vector<string>> return_stmt

%nterm <unique_ptr<constraint_node>> constraint_string
%nterm <vector<tuple<string, basic_type>>> quantifiers
%nterm <tuple<string, basic_type>> quantifier
%nterm <tuple<constraint_node::comp_op, unique_ptr<exp_node>, unique_ptr<exp_node>>> constraint
%nterm <unique_ptr<exp_node>> exp
%nterm <unique_ptr<exp_node>> add_exp
%nterm <unique_ptr<exp_node>> mul_exp
%nterm <unique_ptr<exp_node>> primary_exp
%nterm <unique_ptr<payoff_exp_node>> payoff_val
%nterm <unique_ptr<f_val_exp_node>> f_val
%nterm <vector<string>> strategy_list

%nterm <unique_ptr<algo_node>> algo_def
%nterm <unique_ptr<algo_node>> algo_body
%nterm <unique_ptr<construct_stmt_node>> construct_stmt
%nterm <vector<unique_ptr<construct_stmt_node>>> construct_stmts
%nterm <vector<tuple<string, basic_type>>> strategy_with_type_list
%nterm <tuple<string, basic_type>> strategy_with_type
%nterm <vector<unique_ptr<rparam_node>>> operation_rparams
%nterm <unique_ptr<rparam_node>> operation_rparam
%nterm <unique_ptr<strategy_rparam_node>> strategy_rparam
%nterm <unique_ptr<payoff_exp_rparam_node>> payoff_rparam
%nterm <vector<tuple<string, int>>> linear_combination
%nterm <tuple<string, int>> linear_term

%nterm <vector<basic_type>> ret_type
%nterm <vector<basic_type>> player_types


%%
%start program;

program: 
  n_player_decl operation_defs algo_def {
    drv.legone_ast.num_players = $1;
    drv.legone_ast.operations = std::move($2);
    drv.legone_ast.algo = std::move($3);
  } 
n_player_decl: 
  "num_players" NUMBER NEWLINE { 
    $$ = $2; 
  }

operation_defs: 
  %empty { 
    $$ = unordered_map<string, unique_ptr<operation_node>>(); 
  }
  | operation_defs operation_def { 
    $$ = std::move($1);
    if($$.find($2->name)!=$$.end()) {
      yy::parser::error(drv.location, "operation " + $2->name + " already defined");
    } else {
      $$[$2->name] = std::move($2);
    }
  }
operation_def:
  "def" operation_name "(" operation_fparams ")" "->" ret_type ":" NEWLINE INDENT operation_body DEDENT {
    auto& [extra_params, constraints, rets] = $11;
    $$ = std::make_unique<operation_node>($2, $4, $7, extra_params, std::move(constraints), rets);
  }
operation_name: 
  "identifier" { 
    $$ = $1; 
  }
operation_fparams:
  %empty { 
    $$ = vector<tuple<string, basic_type>>(); 
  }
  | operation_fparams operation_fparam { 
    $$ = std::move($1);
    $$.push_back($2);
  }
operation_fparam:
  strategy_fparam { 
    $$ = $1; 
  }
  | payoff_fparam { 
    $$ = $1; 
  }
strategy_fparam:
  "identifier" ":" "player_type" { 
      $$ = std::make_tuple($1, static_cast<basic_type>($3));
  }
payoff_fparam:
  "identifier" ":" "Payoff" { 
    $$ = std::make_tuple($1, basic_type::Payoff); 
  }
  | "payoff_name" ":" "Payoff" { 
    $$ = std::make_tuple($1, basic_type::Payoff); 
  }

operation_body:
  description_stmt extra_params_stmt constraints_stmt return_stmt {
    $$ = std::make_tuple(std::move($2), std::move($3), std::move($4));
  }
description_stmt:
  "description" "=" STRING NEWLINE {}
extra_params_stmt:
  "extra_params" "=" "[" param_list "]" NEWLINE {
    $$ = std::move($4);
  }
param_list:
  %empty { 
    $$ = unordered_set<string>(); 
  }
  | param_list "," STRING { 
    $$ = std::move($1);
    if($$.find($3) != $$.end()) {
      yy::parser::error(drv.location, "extra param " + $3 + " already defined");
    } else {
      $$.insert($3);
    }
  }
constraints_stmt:
  "constraints" "=" "[" constraint_list "]" NEWLINE {
    $$ = std::move($4);
  } 
constraint_list:
  %empty { 
    $$ = vector<unique_ptr<constraint_node>>(); 
  }
  | constraint_list "," constraint_string { 
    $$ = std::move($1);
    $$.push_back(std::move($3));
  }
return_stmt:
  "return" strategy_list {
    $$ = $2;
  }

constraint_string:
  constraint {
    auto& [op, left_exp, right_exp] = $1;
    $$ = make_unique<constraint_node>(vector<tuple<string, basic_type>>(), std::move(left_exp), std::move(right_exp), op);
  }
  | quantifiers "(" constraint ")" {
    auto& [op, left_exp, right_exp] = $3;
    $$ = make_unique<constraint_node>($1, std::move(left_exp), std::move(right_exp), op);
  }
quantifiers:
  %empty { 
    $$ = vector<tuple<string, basic_type>>(); 
  }
  | quantifiers quantifier { 
    $$ = std::move($1);
    $$.push_back($2);
  }
quantifier:
  "forall" "(" strategy_fparam ")."  { 
    $$ = $3; 
  }
  | "forall" "(" payoff_fparam ")." { 
    $$ = $3; 
  }
constraint:
  exp "==" exp { 
    $$ = std::make_tuple(constraint_node::comp_op::EQ, std::move($1), std::move($3)); 
  }
  | exp "<=" exp { 
    $$ = std::make_tuple(constraint_node::comp_op::LEQ, std::move($1), std::move($3)); 
  }
  | exp ">=" exp { 
    $$ = std::make_tuple(constraint_node::comp_op::GEQ, std::move($1), std::move($3)); 
  }
exp: 
  add_exp { 
    $$ = std::move($1); 
  }
add_exp:
  add_exp "+" mul_exp { 
    $$ = make_unique<op_exp_node>(op_exp_node::op_type::ADD, std::move($1), std::move($3)); 
  }
  | add_exp "-" mul_exp { 
    $$ = make_unique<op_exp_node>(op_exp_node::op_type::SUB, std::move($1), std::move($3)); 
  }
  | mul_exp { 
    $$ = std::move($1); 
  }
mul_exp:
  mul_exp "*" primary_exp { 
    $$ = make_unique<op_exp_node>(op_exp_node::op_type::MUL, std::move($1), std::move($3)); 
  }
  | primary_exp { 
    $$ = std::move($1); 
  }
primary_exp:
  payoff_val { 
    $$ = std::move($1); 
  }
  | f_val { 
    $$ = std::move($1); 
  }
  | NUMBER { 
    $$ = make_unique<num_exp_node>($1); 
  }
payoff_val:
  "identifier" "(" strategy_list ")" { 
    $$ = make_unique<payoff_exp_node>($1, $3); 
  }
  | "payoff_name" "(" strategy_list ")" { 
    $$ = make_unique<payoff_exp_node>($1, $3); 
  }
f_val:
  F_NAME "(" strategy_list ")" { 
    $$ = make_unique<f_val_exp_node>($1, $3); 
  }
strategy_list:
  %empty { 
    $$ = vector<string>(); 
  }
  | strategy_list "," strategy_rparam { 
    $$ = std::move($1);
    $$.push_back($3->strategy_name);
  }

algo_def:
  "def" "algo" "(" ")" ":" NEWLINE INDENT algo_body DEDENT {
    $$ = std::move($8);
  }
algo_body:
  construct_stmts {
    $$ = make_unique<algo_node>(std::move($1), vector<string>());
  }
  | construct_stmts return_stmt {
    $$ = make_unique<algo_node>(std::move($1), $2);
  }
construct_stmts:
  %empty { 
    $$ = vector<unique_ptr<construct_stmt_node>>(); 
  }
  | construct_stmts construct_stmt { 
    $$ = std::move($1);
    $$.push_back(std::move($2));
  }
construct_stmt:
  strategy_with_type_list "=" operation_name "(" operation_rparams ")" NEWLINE {
    $$ = make_unique<construct_stmt_node>($1, $3, std::move($5));
  }
strategy_with_type_list:
  %empty { 
    $$ = vector<tuple<string, basic_type>>(); 
  }
  | strategy_with_type_list "," strategy_with_type { 
    $$ = std::move($1);
    $$.push_back($3);
  }
strategy_with_type:
  "identifier" ":" "player_type" { 
    if ($3 == basic_type::Payoff)
    {
      yy::parser::error(drv.location, "strategy cannot be of type Payoff");
    }
    else
    {
      $$ = std::make_tuple($1, $3);
    }
  }
operation_rparams:
  %empty { 
    $$ = vector<unique_ptr<rparam_node>>(); 
  }
  | operation_rparams "," operation_rparam { 
    $$ = std::move($1);
    $$.push_back(std::move($3));
  }
operation_rparam:
  strategy_rparam { 
    $$ = std::move($1);
  }
  | payoff_rparam { 
    $$ = std::move($1);
  }
strategy_rparam:
  "identifier" { 
    $$ = make_unique<strategy_rparam_node>($1); 
  }
payoff_rparam:
  linear_combination { 
    $$ = std::make_unique<payoff_exp_rparam_node>($1);
  }
linear_combination:
  linear_term { 
    $$ = vector<tuple<string, int>>(); 
    $$.push_back(std::move($1)); 
  }
  | linear_combination "+" linear_term { 
    $$ = std::move($1);
    $$.push_back(std::move($3));
  }
  | linear_combination "-" linear_term { 
    $$ = std::move(std::move($1));
    $$.push_back(std::make_tuple(std::get<0>($3), -std::get<1>($3)));
  }
linear_term:
  "payoff_name" { 
    $$ = std::make_tuple($1, 1); 
  }
  | NUMBER "*" "payoff_name" { 
    $$ = std::make_tuple($3, $1); 
  }
ret_type:
  "player_type" { 
    $$ = vector<basic_type>(1, $1); 
  }
  | "List" "[" player_types "]" { 
    $$ = std::move($3);
  }
player_types:
  "player_type" { 
    $$ = vector<basic_type>(1, $1); 
  }
  | player_types "," "player_type" { 
    $$ = std::move($1);
    $$.push_back($3);
  }

%%

void yy::parser::error(const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}