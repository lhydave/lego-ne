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
  ASSIGN    "="
  MINUS     "-"
  PLUS      "+"
  STAR      "*"
  LPAREN    "("
  RPAREN    ")"
  LBRACKET  "["
  RBRACKET  "]"
  COLON     ":"
  COMMA     ","
  EQ        "=="
  LEQ       "<="
  GEQ       ">="
  DEF       "def"
  RETURN    "return"
  FORALL    "forall"
  LIST_T    "List"
  PAYOFF_T  "Payoff"
  NEWLINE
  INDENT
  DEDENT
;
%token <int> NUMBER "number"
%token <std::string> IDENTIFIER "identifier"
%token <std::string> STRING "string"
%token <int> PLAYER_T "player_type"


%nterm <int> exp
%printer { yyo << $$; } <*>;

%%
%start unit;
unit: assignments exp  { drv.result = $2; };

assignments:
  %empty                 {}
| assignments assignment {};

assignment:
  "identifier" ":=" exp { drv.variables[$1] = $3; };

%left "+" "-";
%left "*" "/";
exp:
    "number"
    | "identifier"  { $$ = drv.variables[$1]; }
    | exp "+" exp   { $$ = $1 + $3; }
    | exp "-" exp   { $$ = $1 - $3; }
    | exp "*" exp   { $$ = $1 * $3; }
    | exp "/" exp   { $$ = $1 / $3; }
    | "(" exp ")"   { $$ = $2; }
%%

void yy::parser::error (const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}