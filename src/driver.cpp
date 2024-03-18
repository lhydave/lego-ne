#include "driver.hpp"
#include "legone_parser.hpp"

driver::driver() : trace_parsing(false), trace_scanning(false)
{
}

int driver::parse2ast(const std::string &f)
{
	file = f;
	location.initialize(&file);
	scan_begin();
	yy::parser parse(*this);
	parse.set_debug_level(trace_parsing);
	int res = parse();
	scan_end();
	return res;
}

void driver::gen_constraint_ast()
{
	optimization_ast.gen_tree(legone_ast);
}