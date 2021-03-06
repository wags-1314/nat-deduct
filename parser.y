%define api.value.type { Value }
%define api.location.type { Location }

%code requires {

#include <iostream>
#include <iomanip>
#include <cstddef>
#include "parser_util.hh"
#include "terminal.hh"

}

%locations

%code {

#include <vector>
#include <string>
#include <stack>
int power(int a, int b);

extern int yylex();
extern int yyparse();
extern int yylineno;
extern int yycolumn;
extern std::string yyline;
int yyerror(std::string);
int lyyerror(YYLTYPE, std::string);
void reasoning_check(Ast *, Reason, YYLTYPE);

std::vector<Ast *> stmts;
std::stack<Ast *> scope;
Ast *hypo, *goal;

std::string file_name;

bool has_error_occurred = false;

}

%token TERM NUM
%token TRN
%token NOT AND OR IF IFF
%token LPAREN RPAREN
%token COM SCOL DOT COL
%token THRM PRF QED
%token HYP REP ASS
%token AINTRO AELIML AELIMR
%token IMPLINTRO IMPLELIM
%token NOTINTRO NOTELIM
%token ORINTROL ORINTROR ORELIM
%token IFFINTRO IFFELIML IFFELIMR

%left IFF
%left IF
%left OR
%left AND
%left NOT

%%

Theorem: THRM DOT Expr {
    hypo = $3.ast_val;
} TRN Expr[goal] {
    goal = $goal.ast_val;
} DOT PRF DOT Proof QED {

    if (!scope.empty()) {
        yyerror("All assumptions have not been discharged.");
    }

    if(!ast_equals(*stmts.back(), *goal)) {
        yyerror("Goals of the theorem and " 
                "the result of the proof don't match.");
    }

    if (has_error_occurred) {
        std::cout << fg::red << "Proof is not correct!\n" << fg::reset;
    } else {
        std::cout << fg::green << "Proof is correct!\n" << fg::reset;
    }
} DOT  | THRM DOT TRN Expr[goal] {
    goal = $goal.ast_val;
} DOT PRF DOT Proof QED {
    if (!scope.empty()) {
        yyerror("All assumptions have not been discharged.");
    }

    if(!ast_equals(*stmts.back(), *goal)) {
        yyerror("Goals of the theorem and " 
                "the result of the proof don't match.");
    }

    if (has_error_occurred) {
        std::cout << fg::red << "Proof is not correct!\n" << fg::reset;
    } else {
        std::cout << fg::green << "Proof is correct!\n" << fg::reset;
    }
} DOT  ;

Proof: /* empty */
     | StmtList DOT
     ;

StmtList: Stmt {
    stmts.push_back($1.ast_val);
    
    // Checking index
    if($1.int_val > 0 && (long unsigned int)$1.int_val != stmts.size()) {
        yyerror("Index is wrong");
    }
}       | StmtList DOT Stmt {
    stmts.push_back($3.ast_val);
    if($3.int_val > 0 && (long unsigned int)$3.int_val != stmts.size()) {
        yyerror("Index is wrong");
    }
}       ;

Stmt: NUM COL Expr SCOL Reasoning {
    $$.str_val = $3.str_val;
    $$.int_val = $1.int_val;
    $$.ast_val = $3.ast_val;
    $$.reason_val = $5.reason_val;
    reasoning_check($$.ast_val, $$.reason_val, $5.loc_val);
}   | Expr SCOL Reasoning {
    $$.int_val = 0;
    $$.str_val = $1.str_val;
    $$.ast_val = $1.ast_val;
    $$.reason_val = $3.reason_val;
    reasoning_check($$.ast_val, $$.reason_val, $3.loc_val);
}   ;

Reasoning: HYP { 
    $$.reason_val = { Reason::HYPOTHESIS, 0, 0, 0 }; 
    $$.loc_val = @1;
}        | AINTRO COL NUM COM NUM {
    $$.reason_val = { Reason::AND_INTRO, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        | AELIML COL NUM {
    $$.reason_val = { Reason::AND_ELIM_L, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | AELIMR COL NUM {
    $$.reason_val = { Reason::AND_ELIM_R, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | REP COL NUM {
    $$.reason_val = { Reason::REPEAT, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | ASS {
    $$.reason_val = { Reason::ASSUMPTION, 0, 0, 0 };
    $$.loc_val = @1;
}        | IMPLINTRO COL NUM COM NUM {
    $$.reason_val = { Reason::IMPL_INTRO, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        | IMPLELIM COL NUM COM NUM {
    $$.reason_val = { Reason::IMPL_ELIM, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        | NOTINTRO COL NUM COM NUM COM NUM {
    $$.reason_val = { Reason::NOT_INTRO, $3.int_val, $5.int_val, $7.int_val };
    $$.loc_val = @1;
}        | NOTELIM COL NUM {
    $$.reason_val = { Reason::NOT_ELIM, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | ORINTROL COL NUM {
    $$.reason_val = { Reason::OR_INTRO_L, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | ORINTROR COL NUM {
    $$.reason_val = { Reason::OR_INTRO_R, $3.int_val, 0, 0 };
    $$.loc_val = @1;
}        | ORELIM COL NUM COM NUM COM NUM {
    $$.reason_val = { Reason::OR_ELIM, $3.int_val, $5.int_val, $7.int_val };
    $$.loc_val = @1;
}        | IFFINTRO COL NUM COM NUM {
    $$.reason_val = { Reason::IFF_INTRO, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        | IFFELIML COL NUM COM NUM {
    $$.reason_val = { Reason::IFF_ELIM_L, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        | IFFELIMR COL NUM COM NUM {
    $$.reason_val = { Reason::IFF_ELIM_R, $3.int_val, $5.int_val, 0 };
    $$.loc_val = @1;
}        ;

Expr: TERM {
    $$.ast_val = new Ast($1.str_val);
}   | NOT Expr { 
    $$.ast_val = new Ast(Ast::NOT, $2.ast_val, nullptr);
}   | Expr AND Expr { 
    $$.ast_val = new Ast(Ast::AND, $1.ast_val, $3.ast_val);
}   | Expr OR Expr {
    $$.ast_val = new Ast(Ast::OR, $1.ast_val, $3.ast_val);
}   | Expr IF Expr {
    $$.ast_val = new Ast(Ast::IF, $1.ast_val, $3.ast_val);
}   | Expr IFF Expr {
    $$.ast_val = new Ast(Ast::IFF, $1.ast_val, $3.ast_val);
}   | LPAREN Expr RPAREN { $$ = $2; }
    ;

%%

/**
 * @brief     Error reporting function
 *
 * @param      msg   error message
 */
int yyerror(std::string msg) {
    lyyerror(yylloc, msg);
}

/**
 * @brief      Error reporting function
 *
 * @param      loc   error location
 * @param      msg   error message
 */
int lyyerror(YYLTYPE loc, std::string msg) {
    std::cerr << file_name << ':' << loc.first_line << ':' << loc.first_column
            << ": " << fg::red << "error: " << fg::reset
            << msg << '\n';

    std::cerr << std::setw(5) << loc.first_line << " | ";
    for(std::size_t i = 0; i < yyline.size(); i++) {
        if (i == (std::size_t)loc.first_column - 1) {
            std::cerr << fg::red;
        }

        if (i == (std::size_t)loc.last_column) {
            std::cerr << fg::reset;
        }

        std::cerr << yyline[i];
    }

    std::cerr << fg::reset << '\n';

    has_error_occurred = true;
}


/**
 * @brief      Checks if a expression logicall follows given the reason
 *
 * @param      expr    The expression
 * @param      reason  The reason
 * @param      loc     The location
 */
void reasoning_check(Ast *expr, Reason reason, YYLTYPE loc) {
    Ast *e1, *e2, *e3;
    bool flag;

    switch(reason.tag) {
        case Reason::HYPOTHESIS:
            if (!ast_equals(*expr, *hypo)) {
                lyyerror(loc, "Statement and hypothesis must match.");
            }
            break;
        case Reason::AND_ELIM_L:
            if(!stmts[reason.step1 - 1]->is_and()) {
                lyyerror(loc, "Statement being infered from must be an and statement.");
                break;
            }

            if(!ast_equals(*stmts[reason.step1 - 1]->left, *expr)) {
                lyyerror(loc, "The left branch of statement being infered from and the current statement must match.");
            }
            break;
        case Reason::AND_ELIM_R:
            if(!stmts[reason.step1 - 1]->is_and()) {
                lyyerror(loc, "Statement being infered from must be an and statement.");
                break;
            }

            if(!ast_equals(*stmts[reason.step1 - 1]->right, *expr)) {
                lyyerror(loc, "The right branch of statement being infered from and the current statement must match.");
            }
            break;
        case Reason::AND_INTRO:
            if(!expr->is_and()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];

            if(!ast_equals(*(expr->left), *e1) || !ast_equals(*(expr->right), *e2)) {
                lyyerror(loc, "Wrong reasoning.");
            }
            break;
        case Reason::REPEAT:
            e1 = stmts[reason.step1 - 1];

            if(!ast_equals(*e1, *expr)) {
                lyyerror(loc, "Wrong Reasoning.");
            }

            break;
        case Reason::ASSUMPTION:
            scope.push(expr);
            break;
        case Reason::IMPL_INTRO:

            if(!expr->is_if()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];
            e3 = scope.top();

            if(!(ast_equals(*(expr->left), *e1) && ast_equals(*(expr->left), *e3) && ast_equals(*(expr->right), *e2))) {
                lyyerror(loc, "Wrong reasoning.");
            } else {
                scope.pop();
            }
            break;
        case Reason::IMPL_ELIM:
            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];

            if(!e1->is_if()) {
                lyyerror(loc, "Wrong Reasoning.");
                break;
            }

            if(!ast_equals(*(e1->left), *e2)) {
                lyyerror(loc, "Wrong Reasoning");
            }

            if(!ast_equals(*(e1->right), *expr)) {
                lyyerror(loc, "Wrong Reasoning");
            }

            break;
        case Reason::NOT_INTRO:
            // std::cout << "here\n";
            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];
            e3 = stmts[reason.step3 - 1];
            flag = false;

            if (!ast_equals(*e1, *scope.top())) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }

            if (!e2->is_not() && !e3->is_not()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }

            if (e2->is_not() && !ast_equals(*(e2->left), *e3)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }

            if (e3->is_not() && !ast_equals(*(e3->left), *e2)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }

            if (!expr->is_not()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(expr->left), *e1)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }

            if (!flag) {
                scope.pop();
            }

            break;
        case Reason::NOT_ELIM:
            e1 = stmts[reason.step1 - 1];

            if (!e1->is_not()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!((e1->left)->is_not())) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(e1->left->left), *expr)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }
            break;

        case Reason::OR_INTRO_L:
            e1 = stmts[reason.step1 - 1];

            if (!expr->is_or()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(expr->left), *e1)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }
            break;

         case Reason::OR_INTRO_R:
            e1 = stmts[reason.step1 - 1];

            if (!expr->is_or()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(expr->right), *e1)) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
            }
            break;

        case Reason::OR_ELIM:
            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];
            e3 = stmts[reason.step3 - 1];

            if (!e1->is_or()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!e2->is_if()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!e3->is_if()) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(e1->left), *(e2->left))) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!ast_equals(*(e1->right), *(e3->left))) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            if (!(ast_equals(*(e2->right), *expr) && ast_equals(*(e3->right), *expr))) {
                lyyerror(loc, "Wrong reasoning.");
                flag = true;
                break;
            }

            break;

        case Reason::IFF_INTRO:
            if(!expr->is_iff()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            e1 = stmts[reason.step1 - 1]; // forward
            e2 = stmts[reason.step2 - 1]; // backward

            if(!e1->is_if()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!e2->is_if()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!(ast_equals(*(expr->left), *(e1->left)) && ast_equals(*(expr->right), *(e1->right)))) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!(ast_equals(*(expr->right), *(e2->left)) && ast_equals(*(expr->left), *(e2->right)))) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            break;

        case Reason::IFF_ELIM_R:

            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];

            if(!e1->is_iff()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!ast_equals(*(e1->left), *e2)) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!ast_equals(*(e1->right), *expr)) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }
            break;

        case Reason::IFF_ELIM_L:

            e1 = stmts[reason.step1 - 1];
            e2 = stmts[reason.step2 - 1];

            if(!e1->is_iff()) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!ast_equals(*(e1->right), *e2)) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }

            if(!ast_equals(*(e1->left), *expr)) {
                lyyerror(loc, "Wrong reasoning.");
                break;
            }


        default: {}
    }
}
