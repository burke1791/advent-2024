%{

#include "stone.h"

StoneList *l;

%}

%%

[0-9]+  {
    Stone *s = new_stone(yytext);
    append_stone(l, s, false);
  }

.   /* everything else - do nothing */

%%