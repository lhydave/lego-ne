#include "driver.hpp"
#include <iostream>

int main(int argc, char *argv[])
{
	driver drv;
	string filename;
	for (int i = 1; i < argc; ++i)
		if (argv[i] == std::string("-p"))
			drv.trace_parsing = true;
		else if (argv[i] == std::string("-s"))
			drv.trace_scanning = true;
		else if (argv[i] == std::string("-v"))
		{
			drv.print_ast = true;
		}
		else
			filename = argv[i];
	auto success = drv.parse2ast(filename);
	if (success != 0)
	{
		std::cerr << "Error parsing file " << filename << std::endl;
	}
	else if (drv.print_ast)
	{
		drv.legone_ast.walk(true);
	}
	std::cout << std::endl << "building constraint tree..." << std::endl;
	drv.gen_constraint_ast();
	if (drv.print_ast)
	{
		std::cout << std::endl
				  << "printing constraints without alias..." << std::endl;
		drv.optimization_ast.print_constraints(std::cout, false);
		std::cout << std::endl
				  << "printing constraints with alias..." << std::endl;
		drv.optimization_ast.print_constraints(std::cout, true);
	}
	return 0;
}