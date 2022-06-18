#include <cstdio>
#include <iostream>

#include "parser.hh"
#include "parser_util.hh"
#include "terminal.hh"

extern FILE *yyin;
extern std::vector<Ast *> stmts;

int main(int argc, char const *argv[]) {
    FILE *source = fopen(argv[1], "r");
    yyin = source;
    yyparse();
    fclose(source);

    // for (auto stmt : stmts) {
    //     std::cout << *stmt << '\n';
    // }

    std::cout << fg::red << "Hello," << reset << " World!\n";

    return 0;
}
