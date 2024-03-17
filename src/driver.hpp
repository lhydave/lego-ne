// The parsing driver from LegoNE to AST

#ifndef LEGO_DRIVER_HPP
#define LEGO_DRIVER_HPP
#include "legone_parser.hpp"
#include "ast.hpp"
#include <map>
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

}; // class driver

#endif // LEGO_DRIVER_HPP