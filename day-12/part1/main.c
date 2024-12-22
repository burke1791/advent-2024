#include <stdlib.h>
#include <stdio.h>

#include "plot.h"

extern int yylex(void);
extern FILE* yyin;

extern Grid *g;

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  g = new_grid(5);

  yylex();

  // print_grid(g);

  Farm *f = new_farm(5);

  analyze_farm(f, g);
  // print_farm(f);

  int price = compute_fence_price(f);
  printf("price: %d\n", price);

  free_grid(g);
  free_farm(f);
}