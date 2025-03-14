// The parsing driver from LegoNE to AST

#ifndef LEGO_DRIVER_HPP
#define LEGO_DRIVER_HPP
#include "legone_parser.hpp"
#include "ast.hpp"
#include "gen_code/constraint.hpp"
#include "gen_code/mathematica.hpp"
#include "gen_code/Z3.hpp"
#include <map>
#include <memory>
#include <fstream>
#include <string>
// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex(driver &drv)
// ... and declare it for the parser's sake.
YY_DECL;

// Conducting the whole compilation process.
class driver {
public:
	driver();

	// the ast
	legone::ast_root legone_ast;

	// Run the parser on file F. and obtain the ast. Return 0 on success.
	int parse2ast(const std::string &f);
	// The name of the file being parsed.
	std::string file;
	// Whether to generate parser debug traces.
	bool trace_parsing;

	// Handling the scanner.
	void scan_begin();
	void scan_end();
	// Whether to generate scanner debug traces.
	bool trace_scanning;
	// The token's location used by the scanner.
	yy::location location;
	// print the ast
	bool print_ast;

	// generate constraint program AST
	constraint::optimization_tree optimization_ast;
	void gen_constraint_ast();

	// generate mathematica code
	unique_ptr<mathematica::generator> mathematica_gen;
	string mathematica_filename;
	string mathematica_code;
	bool print_mathematica_code;
	void gen_mathematica_code();

	// generate Z3 code
	unique_ptr<Z3::generator> Z3_gen;
	string Z3_filename;
	string Z3_code;
	double bound_to_prove;
	bool print_Z3_code;
	void gen_Z3_code();
}; // class driver

#endif // LEGO_DRIVER_HPP