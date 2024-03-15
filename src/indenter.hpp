// Handle indentation in the code
#ifndef INDENTER_HPP
#define INDENTER_HPP
#include <stack>
#include <string>

namespace legone {
class indenter {
public:	
	enum class indent_token { INDENT, DEDENT };
	std::stack<indent_token> token_stack;
	
	indenter(size_t indent_size = 4);
	bool in_bracket() const;
	void increase_bracket_level();
	void decrease_bracket_level();
	bool gen_token_stack(const std::string &text);

private:
	size_t indent_size;
	size_t bracket_level;
	std::stack<size_t> indent_levels;
	size_t text2indent(const std::string &text) const;
};

} // namespace legone
#endif // INDENTER_HPP