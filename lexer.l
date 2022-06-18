%option noyywrap
%option yylineno
%{
#include "parser.hh"
#include <string>
#include <cstdlib>

int yycolumn = 1;
#define YY_USER_ACTION                              \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn;                 \
    yylloc.last_column = yycolumn + yyleng - 1;     \
    yycolumn += yyleng;

extern int yyerror(std::string);
%}

%%

"Theorem"      { return THRM; }
"Proof"        { return PRF; }
"Qed"          { return QED; }
"Hypothesis"   { return HYP; }
"Hyp"          { return HYP; }
"Repeat"       { return REP; }
"Rep"          { return REP; }
"Assumption"   { return ASS; }
"Asmp"         { return ASS; }
"AndIntro"     { return AINTRO; }
"/\\I"         { return AINTRO; }
"AndElimLeft"  { return AELIML; }
"/\\EL"        { return AELIML; }
"AndElimRight" { return AELIMR; }
"/\\ER"        { return AELIMR; }
"ImplIntro"    { return IMPLINTRO; }
"->I"          { return IMPLINTRO; }
"ImplElim"     { return IMPLELIM; }
"->E"          { return IMPLELIM; }
[a-zA-Z]+      { yylval.str_val = std::string(yytext); return TERM; }
[0-9]+         { yylval.int_val = atoi(yytext); return NUM; }
"~"            { return NOT; }
"/\\"          { return AND; }
"\\/"          { return OR; }
"->"           { return IF; }
"<->"          { return IFF; }
"("            { return LPAREN; }
")"            { return RPAREN; }
";"            { return SCOL; }
","            { return COM; }
"."            { return DOT; }
":"            { return COL; }
"|-"           { return TRN; }
[ \t]          { /* do nothing */ }
\n             { yycolumn = 1; }
.              { yyerror("Unknown character."); }
%%

