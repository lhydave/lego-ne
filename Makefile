LEX 		:= flex
YACC 		:= bison
CC 			:= g++
CDEBUG		:= -D DEBUG=2 -g
CFLAGS 		:= -lm -O2 -Wall -std=c++20 #$(CDEBUG)
INCLUDEDIR 	:= -Ifront -Iback
INCLUDE 	:= main.cc ast.cc driver.cc indenter.cc symtab.cc
INCLUDE		+= gen_code/constraint.cc gen_code/mathematica.cc
YACCDEBUG	:= #-v --report=all

all: compiler

compiler: eeyore-tab $(INCLUDE)
	$(CC) $(CFLAGS) $(INCLUDEDIR) SysY.tab.cpp lex.yy.cpp $(INCLUDE) -o compiler

eeyore-tab: eeyore-lex $(INCLUDE)
	$(YACC) $(YACCDEBUG) -d -o SysY.tab.cpp front/SysY.y

eeyore-lex: front/SysY.l
	$(LEX) -o lex.yy.cpp front/SysY.l

clean:
	rm -f compiler *.output *.out *.S
	rm -f SysY.tab.cpp lex.yy.cpp SysY.tab.hpp
	rm -rf *.dSYM .vscode .VSCodeCounter

#TODO: rewrite this