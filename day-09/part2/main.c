#include <stdlib.h>
#include <stdio.h>

#include "diskmap.h"
#include "gram.tab.h"

extern FILE *yyin;

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  Disk *d = new_disk();

  yyparse(&(d->dm));

  compact_diskmap(d->dm);
  construct_filesystem(d);

  long checksum = compute_checksum(d->fs);
  printf("checksum: %ld\n", checksum);

  free_disk(d);
}