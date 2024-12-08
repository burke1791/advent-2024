%option case-insensitive nodefault noyywrap
%option bison-bridge

%{

#include "gram.tab.h"

%}

%%

[\r\n]    { return NEWLINE; }

[0-9]+  { yylval->i = atoi(yytext); return NUMBER; }

[|,]    { return yytext[0]; }


.   /* everything else */

%%