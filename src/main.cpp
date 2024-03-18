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
			drv.print_mathematica_code = true;
		}
		else if (argv[i] == std::string("-o"))
		{
			if (i + 1 < argc)
			{
				drv.mathematica_filename = argv[i + 1];
				i++;
			}
			else
			{
				if (!filename.empty())
				{
					std::cerr << "Error: more than one file name" << std::endl;
					return 1;
				}
			}
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
	drv.gen_mathematica_code();
	if (drv.print_mathematica_code)
	{
		std::cout << std::endl
				  << "printing mathematica code..." << std::endl;
		std::cout << drv.mathematica_code;
	}
	return 0;
}