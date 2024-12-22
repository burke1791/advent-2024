%{

#include "plot.h"

Grid *g;

%}

%s ROW

%%

<ROW>[A-Z]    {
    Row *r = g->rows[g->count - 1];
    append_char(r, yytext[0]);
  }

[A-Z]  {
    Row *r = new_row(5);
    append_row(g, r);
    append_char(r, yytext[0]);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%