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
#include <string_view>
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
using std::string_view;
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
	string gen_code(string_view file) const;

private:
	static constexpr string_view constraint_name = "constraints";
	static constexpr string_view solver_name = "solver";
	tuple<string, string> gen_alias_and_param() const;
	string gen_opt_mix_func() const;
	string gen_opt_mix_bounds() const;
	string gen_constraints() const;
	string gen_approx_bound_constraint(string_view alias_in_exist) const;
};

} // namespace Z3

#endif