// Handle indentation in the code
#ifndef INDENTER_HPP
#define INDENTER_HPP
#include<string>
#include<stack>

namespace legone {
    class indenter {
    public:
        indenter(size_t indent_size = 4);
        enum class indent_token {
            INDENT,
            DEDENT
        };
        bool in_bracket() const;
        void increase_bracket_level();
        void decrease_bracket_level();
        bool gen_token_stack(const std::string &text);
    private:
        std::stack<size_t> indent_levels;
        std::stack<indent_token> token_stack;
        size_t bracket_level;
        size_t indent_size;
        size_t text2indent(const std::string &text);
    };

} // namespace legone
#endif // INDENTER_HPP