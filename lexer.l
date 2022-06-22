%option noyywrap
%option yylineno
%{
#include "parser.hh"
#include <string>
#include <cstdlib>

int yycolumn = 1;
std::string yyline;
#define YY_USER_ACTION                               \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn;                  \
    yylloc.last_column = yycolumn + yyleng - 1;      \
    yycolumn += yyleng;                              \
    yyline += std::string(yytext);

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
"NotIntro"     { return NOTINTRO; }
"~I"           { return NOTINTRO; }
"NotElim"      { return NOTELIM; }
"~E"           { return NOTELIM; }
"OrIntroLeft"  { return ORINTROL; }
"\\/IL"        { return ORINTROL; }
"OrIntroRight" { return ORINTROR; }
"\\/IR"        { return ORINTROR; }
"OrElim"       { return ORELIM; }
"\\/E"         { return ORELIM; }
"IffIntro"     { return IFFINTRO; }
"<->I"         { return IFFINTRO; }
"IffElimLeft"  { return IFFELIML; }
"<->EL"        { return IFFELIML; }
"IffElimRight" { return IFFELIMR; }
"<->ER"        { return IFFELIMR; }
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
\n             { yycolumn = 1; yyline = std::string(""); }
.              { yyerror("Unknown character."); }
%%

