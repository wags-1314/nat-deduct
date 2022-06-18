%define api.value.type { Value }
%define api.location.type { Location }

%code requires {

#include <iostream>
#include "parser_util.hh"

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
int yyerror(std::string);
int lyyerror(YYLTYPE, std::string);
void reasoning_check(Ast *, Reason, YYLTYPE);

std::vector<Ast *> stmts;
std::stack<Ast *> scope;
Ast *hypo, *goal;

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

    std::cout << "Theorem is correct!\n";
} DOT  | THRM DOT TRN Expr[goal] {
    goal = $goal.ast_val;
    std::cout << *$goal.ast_val << '\n';
} DOT PRF DOT Proof QED {
    if (!scope.empty()) {
        yyerror("All assumptions have not been discharged.");
    }

    if(!ast_equals(*stmts.back(), *goal)) {
        yyerror("Goals of the theorem and " 
                "the result of the proof don't match.");
    }

    std::cout << "Theorem is correct!\n";
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

int yyerror(std::string msg) {
    std::cerr << "error @" << yylloc.first_line << ':' << yylloc.first_column;
    std::cerr << " - ";
    std::cerr << yylloc.last_line << ':' << yylloc.last_column << ": ";
    std::cerr << msg << '\n';
    exit(0);
}

int lyyerror(YYLTYPE loc, std::string msg) {
    std::cerr << "error @" << loc.first_line << ':' << loc.first_column;
    std::cerr << " - ";
    std::cerr << loc.last_line << ':' << loc.last_column << ": ";
    std::cerr << msg << '\n';
    exit(0);
}

void reasoning_check(Ast *expr, Reason reason, YYLTYPE loc) {
    Ast *e1, *e2, *e3;
    switch(reason.tag) {
        case Reason::HYPOTHESIS:
            if (!ast_equals(*expr, *hypo)) {
                lyyerror(loc, "Wrong reasoning.");
            }
            break;
        case Reason::AND_ELIM_L:
            if(!stmts[reason.step1 - 1]->is_and()) {
                lyyerror(loc, "Wrong reasoning.");
            }

            if(!ast_equals(*stmts[reason.step1 - 1]->left, *expr)) {
                lyyerror(loc, "Wrong reasoning.");
            }
            break;
        case Reason::AND_ELIM_R:
            if(!stmts[reason.step1 - 1]->is_and()) {
                lyyerror(loc, "Wrong reasoning.");
            }

            if(!ast_equals(*stmts[reason.step1 - 1]->right, *expr)) {
                lyyerror(loc, "Wrong reasoning.");
            }
            break;
        case Reason::AND_INTRO:
            if(!expr->is_and()) {
                lyyerror(loc, "Wrong reasoning.");
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
            }

            if(!ast_equals(*(e1->left), *e2)) {
                lyyerror(loc, "Wrong Reasoning");
            }

            if(!ast_equals(*(e1->right), *expr)) {
                lyyerror(loc, "Wrong Reasoning");
            }

            break;

        default: {}
    }
}
