#include "driver.hpp"
#include "legone_parser.hpp"

driver::driver() : trace_parsing(false), trace_scanning(false), print_ast(false), mathematica_gen(nullptr), print_mathematica_code(false), Z3_gen(nullptr), bound_to_prove(1.0), print_Z3_code(false)
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

void driver::gen_mathematica_code()
{
	// initialize mathematica generator
	mathematica_gen = make_unique<mathematica::generator>(optimization_ast);
	mathematica_code = mathematica_gen->gen_code(file);
	std::fstream output_file(mathematica_filename,
							 std::ios::out | std::ios::trunc);
	if (!output_file.is_open())
	{
		std::cerr << "Cannot open file " << mathematica_filename << std::endl;
		return;
	}
	output_file << mathematica_code;
	output_file.close();
}

void driver::gen_Z3_code()
{
	// initialize Z3 generator
	Z3_gen = make_unique<Z3::generator>(optimization_ast, bound_to_prove);
	Z3_code = Z3_gen->gen_code(file);
	std::fstream output_file(Z3_filename,
							 std::ios::out | std::ios::trunc);
	if (!output_file.is_open())
	{
		std::cerr << "Cannot open file " << Z3_filename << std::endl;
		return;
	}
	output_file << Z3_code;
	output_file.close();
}
