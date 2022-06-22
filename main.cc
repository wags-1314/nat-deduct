/**
 * @brief      Natural Deduction Proof Checker - Only Propositional Logic
 * currently
 *
 * @author     Bhargav Kishor Kulkarni
 * @date       22-06-2022
 */
#include <cstdio>
#include <iostream>
#include <vector>

#include "parser.hh"
#include "parser_util.hh"

extern FILE *yyin;
extern std::vector<Ast *> stmts;
extern std::string file_name;

int main(int argc, char const *argv[]) {
    file_name = std::string(argv[1]);
    FILE *source = fopen(argv[1], "r");
    yyin = source;
    yyparse();
    fclose(source);
}
