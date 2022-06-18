#include <cstdio>
#include <iostream>

#include "parser.hh"
#include "parser_util.hh"
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

    return 0;
}
