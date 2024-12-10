%option case-insensitive nodefault noyywrap
%option bison-bridge

%{

#include "gram.tab.h"

%}

%s FREE

%%

<FREE>[0-9]   {
    yylval->i = atoi(yytext);
    BEGIN INITIAL;
    return FREEBLOCK;
  }

[0-9]  {
    yylval->i = atoi(yytext);
    BEGIN FREE;
    return FILEBLOCK;
  }

.   /* everything else */

%%