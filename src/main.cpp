#include "driver.hpp"
#include <iostream>

int main(int argc, char *argv[])
{
    driver drv;
    string filename;
    for (int i = 1; i < argc; ++i)
        if (argv[i] == std::string("-h") || argv[i] == std::string("--help"))
        {
            std::cout << "Usage: legone [options] filename" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  -p              Enable parser tracing." << std::endl;
            std::cout << "  -s              Enable scanner tracing." << std::endl;
            std::cout << "  -v              Verbose output. Print AST and Mathematica code to stdout." << std::endl;
            std::cout << "  -o <file>       Redirect Mathematica code output to <file>." << std::endl;
            std::cout << "  -h, --help      Display this help message." << std::endl;
            return 0;
        }
        else if (argv[i] == std::string("-p"))
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
        return 1;
    }
    auto print = drv.print_ast;
    auto sym_tab = legone::SymTab();
    drv.legone_ast.walk(sym_tab, print);
    if (drv.print_ast)
    {
        std::cout << std::endl << "building constraint tree..." << std::endl;
    }
    drv.gen_constraint_ast();
    if (drv.print_ast)
    {
        std::cout << "Done" << std::endl;
        std::cout << std::endl << "printing constraints without alias..." << std::endl;
        drv.optimization_ast.print_constraints(std::cout, false);
        std::cout << "Done" << std::endl;
        std::cout << std::endl << "printing constraints with alias..." << std::endl;
        drv.optimization_ast.print_constraints(std::cout, true);
        std::cout << "Done" << std::endl;
    }
    drv.gen_mathematica_code();
    if (drv.print_mathematica_code)
    {
        std::cout << std::endl << "printing mathematica code..." << std::endl;
        std::cout << drv.mathematica_code;
        std::cout << "Done" << std::endl;
    }
    return 0;
}