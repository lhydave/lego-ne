/* The lexer file to parse LegoNE */
%{ /* -*- C++ -*- */
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring> // strerror
#include <string>
#include "driver.hpp"
#include "ast.hpp"
#include "legone_parser.hpp"
%}

%option noyywrap nounput noinput batch debug

%{
  // A number symbol corresponding to the value in S.
  yy::parser::symbol_type make_NUMBER(const std::string &s, const yy::parser::location_type& loc);
  // the player type symbol corresponding to the value in S.
  yy::parser::symbol_type make_PLAYER_T(const std::string &s, const yy::parser::location_type& loc);
  // handle string
  yy::parser::symbol_type make_STRING(const std::string &s, const yy::parser::location_type& loc);
%}


id              [_a-zA-Z][a-zA-Z_0-9]*
float           [0-9]+\.[0-9]+
int             [0-9]+
comment         #.*(\n|\r\n)
indent_at_start ^[ \t\f]*
whitespace      [ \t\f\n]+
player_type     p[0-9]+
string          \"([^\\\"]|\\.)*\"

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns(yyleng);
%}
%%
%{
  // A handy shortcut to the location held by the driver.
  yy::location& loc = drv.location;
  // Code run each time yylex is called.
  loc.step();
%}

{comment}         { loc.lines(yyleng); loc.step(); }
{whitespace}      { loc.step(); }

"="               return yy::parser::make_ASSIGN(loc);
"-"               return yy::parser::make_MINUS(loc);
"+"               return yy::parser::make_PLUS(loc);
"*"               return yy::parser::make_STAR(loc);
"/"               return yy::parser::make_DIV(loc);
"("               { return yy::parser::make_LPAREN(loc); }
")."              { return yy::parser::make_RPAREN_DOT(loc); }
")"               { return yy::parser::make_RPAREN(loc); }
"["               { return yy::parser::make_LBRACKET(loc); }
"]"               { return yy::parser::make_RBRACKET(loc); }
":"               return yy::parser::make_COLON(loc);
","               return yy::parser::make_COMMA(loc);
"=="              return yy::parser::make_EQ(loc);
"<="              return yy::parser::make_LEQ(loc);
">="              return yy::parser::make_GEQ(loc);
"->"              return yy::parser::make_ARROW(loc);
"def"             return yy::parser::make_DEF(loc);
"return"          return yy::parser::make_RETURN(loc);
"forall"          return yy::parser::make_FORALL(loc);
"List"            return yy::parser::make_LIST_T(loc);
"Payoff"          return yy::parser::make_PAYOFF_T(loc);
"description"     return yy::parser::make_DESCRIPTION(loc);
"extra_params"    return yy::parser::make_EXTRA_PARAMS(loc);
"constraints"     return yy::parser::make_CONSTRAINTS(loc);
"algo"            return yy::parser::make_ALGO(loc);
"num_players"     return yy::parser::make_NUM_PLAYERS(loc);

{int}             return make_NUMBER(yytext, loc);
{float}           return make_NUMBER(yytext, loc);
{player_type}     return make_PLAYER_T(yytext, loc);
{id}              return yy::parser::make_IDENTIFIER(yytext, loc);
{string}          return make_STRING(yytext, loc);

.                 {
                    throw yy::parser::syntax_error
                      (loc, "invalid character: " + std::string(yytext));
                  }
<<EOF>>           return yy::parser::make_YYEOF(loc);
%%

yy::parser::symbol_type make_NUMBER(const std::string &s, const yy::parser::location_type& loc)
{
  errno = 0;
  auto n = std::stod(s);
  return yy::parser::make_NUMBER(static_cast<double>(n), loc);
}

yy::parser::symbol_type make_PLAYER_T(const std::string &s, const yy::parser::location_type& loc)
{
  errno = 0;
  long n = strtol(s.c_str()+1, NULL, 10);
  if (not (1 <= n and n <= INT_MAX and errno != ERANGE))
    throw yy::parser::syntax_error(loc, "player type is out of range: " + s);
  return yy::parser::make_PLAYER_T(static_cast<legone::basic_type>(n), loc);
}

yy::parser::symbol_type make_STRING(const std::string &s, const yy::parser::location_type& loc)
{
  std::string str = s.substr(1, s.size()-2);
  return yy::parser::make_STRING(str, loc);
}

void driver::scan_begin()
{
  yy_flex_debug = trace_scanning;
  if (file.empty() || file == "-")
    yyin = stdin;
  else if (not (yyin = fopen(file.c_str(), "r")))
    {
      std::cerr << "cannot open " << file << ": " << strerror(errno) << std::endl;
      exit(EXIT_FAILURE);
    }
}

void driver::scan_end ()
{
  fclose(yyin);
}