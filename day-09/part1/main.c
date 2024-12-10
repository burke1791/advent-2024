#include <stdlib.h>
#include <stdio.h>

#include "diskmap.h"
#include "gram.tab.h"

extern FILE *yyin;

void print_block(Block *b) {
  for (int i = 0; i < b->size; i++) {
    switch (b->type) {
      case BT_FILE:
        printf("%d", b->fileId);
        break;
      case BT_FREE:
        printf(".");
        break;
    }
  }
}

void print_diskmap(DiskMap *dm) {
  for (int i = 0; i < dm->count; i++) {
    Block *b = dm->blocks[i];
    print_block(b);
  }
  printf("\n");
}

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  DiskMap *dm;

  yyparse(&dm);

  print_diskmap(dm);

  free_diskmap(dm);
}