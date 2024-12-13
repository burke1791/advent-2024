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
  int cacheBlinks = atoi(argv[3]);

  l = new_stonelist(5);

  yylex();

  CacheList *cl = new_cachelist(10);
  fill_cachelist(cl, 10, cacheBlinks);

  for (int i = 0; i < cl->count; i++) {
    StoneList *sl = new_stonelist(1);
    append_stone(sl, cl->cache[i]->stone, true);

    long totalStones = blink_stones(sl, cl->cache[i]->numBlinks, cl);
    cl->cache[i]->result = totalStones;
  }

  // print_cachelist(cl);

  // print_stonelist(l);
  long total = blink_stones(l, numBlinks, cl);

  printf("num blinks: %d\n", numBlinks);
  printf("cache blinks: %d\n", cacheBlinks);
  printf("total: %ld\n", total);

  free_cachelist(cl);
}