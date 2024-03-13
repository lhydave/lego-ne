#include "indenter.hpp"

legone::indenter::indenter(size_t indent_size) :
	indent_size(indent_size), bracket_level(0)
{
	indent_levels.push(0);
}

bool legone::indenter::in_bracket() const
{
	return bracket_level > 0;
}

void legone::indenter::increase_bracket_level()
{
	bracket_level += 1;
}

void legone::indenter::decrease_bracket_level()
{
	if (bracket_level == 0)
	{
		throw std::runtime_error("Too many closing brackets");
	}
	bracket_level -= 1;
}

bool legone::indenter::gen_token_stack(const std::string &text)
{
	auto indent = text2indent(text);
	if (not token_stack.empty())
	{
		throw std::runtime_error(
			"Token stack is not empty when generating new token stack");
	}
	if (indent > indent_levels.top()) // increase indent
	{
		token_stack.push(indent_token::INDENT);
		indent_levels.push(indent);
		return true;
	}
	else if (indent < indent_levels.top()) // decrease indent
	{
		while (indent < indent_levels.top())
		{
			token_stack.push(indent_token::DEDENT);
			indent_levels.pop();
		}
		if (indent != indent_levels.top())
		{
			return false; // error
		}
		return true;
	}
	else
	{
		return true; // no change in indent
	}
}

size_t legone::indenter::text2indent(const std::string &text) const
{
	size_t indent = 0;
	for (auto c : text)
	{
		switch (c)
		{
		case ' ': indent += 1; break;
		case '\t': indent += indent_size; break;
		case '\f': break; // omit form feed
		default:
			throw std::runtime_error(
				"Invalid character in calculation of indent");
		}
	}
	return indent;
}
