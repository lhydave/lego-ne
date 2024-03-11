/* The lexer file to parse LegoNE */

%option yylineno
%option noyywrap
%option noinput
%option nounput
%option C++
%option yyclass="Lexer"
%{
#include "AST.hpp"
#include "SysY.tab.hpp"
%}

indents         \n[\t]+
whitespace      [ \n\t\r\v\f]
comment         #.*\n
identifier      [_a-zA-Z][_0-9a-zA-Z]*
decimal         [1-9][0-9]*
SingleOp        [\+\-\*]
terminal        [=;,\(\)\{\}\[\]]
IllegalNum      [0-9]*.[0-9]+
IllegalName     [0-9][_0-9a-zA-Z]*
IllegalSymbol   .

%%



%%