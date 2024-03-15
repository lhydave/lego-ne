LEX 		:= flex
YACC 		:= bison
CC 			:= g++
CFLAGS 		:= -lm -O2 -Wall -std=c++20 #$(CDEBUG)
INCLUDEDIR 	:= -Ifront -Iback
INCLUDE 	:= main.cpp ast.cpp driver.cpp indenter.cpp symtab.cpp
INCLUDE		+= gen_code/constraint.cpp gen_code/mathematica.cpp
YACCDEBUG	:= # -v --report=all
PARSER_NAME := legone_parser
LEXER_NAME  := legone_lexer
all: compiler

compiler: lexer parser
	$(CC) $(CFLAGS) $(INCLUDEDIR) $(PARSER_NAME).cpp $(LEXER_NAME).cpp $(INCLUDE) -o compiler

parser: legone_parser.yy
	$(YACC) $(YACCDEBUG) -d -o $(PARSER_NAME).cpp legone_parser.yy

lexer: legone_lexer.ll
	$(LEX) -o $(LEXER_NAME).cpp legone_lexer.ll

clean:
	rm -f compiler *.output *.out *.S
	rm -f $(PARSER_NAME).cpp $(LEXER_NAME).cpp $(PARSER_NAME).hpp location.hh location.hpp
