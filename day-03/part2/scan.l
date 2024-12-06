%option case-insensitive

%{

#include <stdio.h>
#include <stdlib.h>

int num1 = 0;
int num2 = 0;
int total = 0;

%}

%s MULTIPLY MUL_OPEN MUL_OPEN_SEPARATOR MUL_OPEN2 MUL_READY_CLOSE
%x DONT

%%

<DONT>"do()"    {
    BEGIN INITIAL;
  }

<DONT>.

<MULTIPLY>[(]   {
    BEGIN MUL_OPEN;
  }

<MUL_OPEN>[0-9]+    {
    num1 = atoi(yytext);
    BEGIN MUL_OPEN_SEPARATOR;
  }

<MUL_OPEN_SEPARATOR>[,]   {
    BEGIN MUL_OPEN2;
  }

<MUL_OPEN2>[0-9]+   {
    num2 = atoi(yytext);
    BEGIN MUL_READY_CLOSE;
  }

<MUL_READY_CLOSE>[)]    {
    total += num1 * num2;
    BEGIN INITIAL;
  }

MUL   { BEGIN MULTIPLY; }

"don't()"   {
    BEGIN DONT;
  }

.   { BEGIN INITIAL; }

%%

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  yylex();
  printf("Total: %d\n", total);
}