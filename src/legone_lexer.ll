/* The lexer file to parse LegoNE */
%{ /* -*- C++ -*- */
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring> // strerror
#include <string>
#include "driver.hpp"
#include "legone_parser.hpp"
%}

%option noyywrap nounput noinput batch debug

%{
  // A number symbol corresponding to the value in S.
  yy::parser::symbol_type make_NUMBER(const std::string &s, const yy::parser::location_type& loc);
  // the player type symbol corresponding to the value in S.
  yy::parser::symbol_type make_PLAYER_T(const std::string &s, const yy::parser::location_type& loc);
%}


id              [_a-zA-Z][a-zA-Z_0-9]*
int             [0-9]+
comment         #.*(\n|\r\n)
indent_at_start ^[ \t\f]*
whitespace      [ \t\f]+
newline         \n|\r\n
empty_line      ^[ \t\f]*(\n|\r\n)
player_type     p[0-9]+
string          \"([^\\\"]|\\.)*\"

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns(yyleng);
%}
%%
%{
  // pop out all remaining tokens in indenters
  if (not drv.indenters.empty())
    {
      auto indent_token = drv.indenters.top();
      drv.indenters.pop();
      if (indent_token == legone::identer::INDENT)
        return yy::parser::make_INDENT(loc);
      else
        return yy::parser::make_DEDENT(loc);
    }
  // A handy shortcut to the location held by the driver.
  yy::location& loc = drv.location;
  // Code run each time yylex is called.
  loc.step();
%}

comment         { loc.lines(yyleng); loc.step(); }
empty_line      { loc.lines(yyleng); loc.step(); }
newline         { loc.lines(yyleng); loc.step();
                  if(not drv.indenters.in_bracket()) // only when we are not in a bracket
                  {
                    return yy::parser::make_NEWLINE(loc);
                  }
                }
indent_at_start { if(not drv.indenters.in_bracket()) // only when we are not in a bracket
                   {
                     auto success = drv.indenters.gen_token_stack(yytext);
                     if (not success)
                       {
                         throw yy::parser::syntax_error (loc, "invalid indentation: " + std::string(yytext));
                       }
                   }
                   // when success, we return a series of INDENT and DEDENT for next calls on yylex().
                }
whitespace      { loc.step(); }

"="             return yy::parser::make_ASSIGN(loc);
"-"             return yy::parser::make_MINUS(loc);
"+"             return yy::parser::make_PLUS(loc);
"*"             return yy::parser::make_STAR(loc);
"("             return yy::parser::make_LPAREN(loc);
")"             return yy::parser::make_RPAREN(loc);
"["             return yy::parser::make_LBRACKET(loc);
"]"             return yy::parser::make_RBRACKET(loc);
":"             return yy::parser::make_COLON(loc);
","             return yy::parser::make_COMMA(loc);
"=="            return yy::parser::make_EQ(loc);
"<="            return yy::parser::make_LEQ(loc);
">="            return yy::parser::make_GEQ(loc);
"def"           return yy::parser::make_DEF(loc);
"return"        return yy::parser::make_RETURN(loc);
"forall"        return yy::parser::make_FORALL(loc);
"List"          return yy::parser::make_LIST_T(loc);
"Payoff"        return yy::parser::make_PAYOFF_T(loc);

{int}           return make_NUMBER(yytext, loc);
{player_type}   return make_PLAYER_T(yytext, loc);
{id}            return yy::parser::make_IDENTIFIER(yytext, loc);
{string}        return yy::parser::make_STRING(yytext, loc);

.               {
                  throw yy::parser::syntax_error
                    (loc, "invalid character: " + std::string(yytext));
                }
<<EOF>>         return yy::parser::make_YYEOF(loc);
%%

yy::parser::symbol_type make_NUMBER(const std::string &s, const yy::parser::location_type& loc)
{
  errno = 0;
  long n = strtol(s.c_str(), NULL, 10);
  if (not (INT_MIN <= n and n <= INT_MAX and errno != ERANGE))
    throw yy::parser::syntax_error(loc, "integer is out of range: " + s);
  return yy::parser::make_NUMBER((int) n, loc);
}

yy::parser::symbol_type make_PLAYER_T(const std::string &s, const yy::parser::location_type& loc)
{
  errno = 0;
  long n = strtol(s.c_str()+1, NULL, 10);
  if (not (1 <= n and n <= INT_MAX and errno != ERANGE))
    throw yy::parser::syntax_error(loc, "player type is out of range: " + s);
  return yy::parser::make_PLAYER_T((int) n, loc);
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