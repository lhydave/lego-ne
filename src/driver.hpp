// The parsing driver from LegoNE to AST

#ifndef LEGO_DRIVER_HPP
#define LEGO_DRIVER_HPP
#include "legone_parser.hpp"
#include "symtab.hpp"
#include "indenter.hpp"
#include <map>
#include <string>
// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex(driver &drv)
// ... and declare it for the parser's sake.
YY_DECL;
// Conducting the whole scanning and parsing of Calc++.
class driver {
public:
	driver();

	std::map<std::string, int> variables;

	int result;
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
	// The indenter
	legone::indenter indenter;
}; // class driver

#endif // LEGO_DRIVER_HPP