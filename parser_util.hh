#ifndef PARSER_UTIL_HH
#define PARSER_UTIL_HH

#include <set>
#include <string>
#include <vector>

/**
 * @brief      struct to store Bison locations
 */
struct Location {
    int first_line;
    int first_column;
    int last_line;
    int last_column;
};

/**
 * @brief      struct to form expression ASTs
 */
struct Ast {
    enum Type { NOT, AND, OR, IF, IFF, TERM } tag;
    std::string term_val;
    Ast *left;
    Ast *right;

    /**
     * @brief      Constructs a new instance of a Ast::TERM AST
     *
     * @param[in]  str   Name of the term
     */
    Ast(const std::string str);

    /**
     * @brief      Constructs a new instance of Ast
     *
     * @param[in]  tag    connective tag
     * @param      left   left AST
     * @param      right  right AST
     */
    Ast(Ast::Type tag, Ast *left, Ast *right);

    /**
     * @brief      collects all the terms part of the AST
     *
     * @return     a std::set of all terms(as strings)
     */
    std::set<std::string> collect_terms();

    /**
     * @brief      Prints terms.
     */
    void print_terms();

    /**
     * @brief      Determines if the AST is an and.
     *
     * @return     True if and, False otherwise.
     */
    bool is_and();

    /**
     * @brief      Determines if the AST is an or.
     *
     * @return     True if or, False otherwise.
     */
    bool is_or();

    /**
     * @brief      Determines if the AST is a not
     *
     * @return     True if not, False otherwise.
     */
    bool is_not();

    /**
     * @brief      Determines if the AST is an if
     *
     * @return     True if if, False otherwise.
     */
    bool is_if();

    /**
     * @brief      Determines if the AST is an iff
     *
     * @return     True if iff, False otherwise.
     */
    bool is_iff();

    /**
     * @brief      Determines if the AST is a term.
     *
     * @return     True if term, False otherwise.
     */
    bool is_term();
};

/**
 * @brief      struct to encapsulate reasoning of a statement
 */
struct Reason {
    enum Type {
        HYPOTHESIS,
        AND_INTRO,
        AND_ELIM_L,
        AND_ELIM_R,
        REPEAT,
        ASSUMPTION,
        IMPL_INTRO,
        IMPL_ELIM,
        NOT_INTRO,
        NOT_ELIM,
        OR_INTRO_L,
        OR_INTRO_R,
        OR_ELIM,
        IFF_INTRO,
        IFF_ELIM_R,
        IFF_ELIM_L,
    } tag;
    int step1, step2, step3;
};

/**
 * @brief      struct used by Bison to pass values around rules
 */
struct Value {
    int int_val;
    std::string str_val;
    Ast *ast_val;
    Reason reason_val;
    Location loc_val;
};

/**
 * @brief      ostream << overloading for Ast
 *
 * @param      out   output stream
 * @param[in]  node  Ast to be outputted
 *
 * @return     modified ostream
 */
std::ostream &operator<<(std::ostream &out, const Ast &node);

/**
 * @brief      Determines if two Asts are equals.
 *
 * @param[in]  op1   Operand #1
 * @param[in]  op2   Operand #2
 *
 * @return     True if the two Asts are equals, False otherwise.
 */
bool ast_equals(const Ast &op1, const Ast &op2);

/**
 * @brief      ostream << overloading for Reason
 *
 * @param      out     output stream
 * @param[in]  reason  Reason to be outputted
 *
 * @return     modified ostream
 */
std::ostream &operator<<(std::ostream &out, const Reason &reason);

#endif
