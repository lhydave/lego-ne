// Convert constraint programs into Z3 codes
#ifndef Z3_HPP
#define Z3_HPP
#include "constraint.hpp"
#include <algorithm>
#include <deque>
#include <format>
#include <iostream>
#include <numeric>
#include <regex>
#include <string>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

using std::deque;
using std::endl;
using std::format;
using std::make_unique;
using std::ostream;
using std::string;
using std::tuple;
using std::unique_ptr;
using std::unordered_map;
using std::unordered_set;
using std::vector;

namespace Z3 {

class generator {
public:
	const constraint::optimization_tree &tree;
	const size_t num_players;
	const double bound_to_prove;

	generator(const constraint::optimization_tree &tree, double bound_to_prove);
	string gen_code(const string &file) const;

private:
	string opt_mix_func_name = "optmix";
	string solver_name = "solver";
    string opt_mix_bound_prefix = "bound";
	string gen_alias_and_param() const;
	string gen_opt_mix_func() const;
	tuple<string, string> gen_opt_mix_bounds() const;
	string gen_constraints() const;
	string gen_approx_bound_constraint(const string& bound_exp) const;
};

} // namespace Z3

#endif