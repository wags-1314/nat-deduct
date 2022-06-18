#ifndef PARSER_UTIL_HH
#define PARSER_UTIL_HH

#include <set>
#include <string>
#include <vector>

struct Location {
    int first_line;
    int first_column;
    int last_line;
    int last_column;
};

struct Ast {
    enum Type { NOT, AND, OR, IF, IFF, TERM } tag;
    std::string term_val;
    Ast *left;
    Ast *right;

    Ast(const std::string);
    Ast(Ast::Type, Ast *, Ast *);

    std::set<std::string> collect_terms();
    void print_terms();

    bool is_and();
    bool is_or();
    bool is_not();
    bool is_if();
    bool is_iff();
    bool is_term();
};

struct Reason {
    enum Type {
        HYPOTHESIS,
        AND_INTRO,
        AND_ELIM_L,
        AND_ELIM_R,
        REPEAT,
        ASSUMPTION,
        IMPL_INTRO,
        IMPL_ELIM
    } tag;
    int step1, step2, step3;
};

struct Value {
    int int_val;
    std::string str_val;
    Ast *ast_val;
    Reason reason_val;
    Location loc_val;
};

std::ostream &operator<<(std::ostream &, const Ast &);
bool operator==(const Ast &, const Ast &);
bool ast_equals(const Ast &, const Ast &);

std::ostream &operator<<(std::ostream &, const Reason &);

#endif
