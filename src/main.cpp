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
			drv.print_ast = true;
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
	return 0;
}