#include <stdlib.h>
#include <stdio.h>

#include "stone.h"

extern int yylex(void);
extern FILE* yyin;

extern StoneList *l;

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  int numBlinks = atoi(argv[2]);

  l = new_stonelist(5);

  yylex();

  print_stonelist(l);
  blink(&l, numBlinks, true);
  // print_stonelist(l);

  printf("num blinks: %d\n", numBlinks);
  printf("num stones: %d\n", l->count);

  free_stonelist(l);
}