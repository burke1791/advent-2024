%define api.pure true
%parse-param { struct DiskMap **dm }

%{

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#include "diskmap.h"

void yyerror(DiskMap **dm, char *s, ...);

%}

%union {
  int i;

  struct DiskMap *disk;
  struct Block *b;
}

%token <i> FREEBLOCK FILEBLOCK
%type <disk> diskmap
%type <b> block

%start result

%%

result: diskmap {
      *dm = $1;
      YYACCEPT;
    }
  ;

diskmap: block {
      DiskMap *diskmap = new_diskmap(5);
      append_block(diskmap, $1);

      $$ = diskmap;
    }
  | diskmap block {
      append_block($1, $2);
    }
  ;

block: FREEBLOCK {
      Block *b = new_block(BT_FREE, -1, $1);
      $$ = b;
    }
  | FILEBLOCK {
      Block *b = new_block(BT_FILE, -1, $1);
      $$ = b;
    }


%%

void yyerror(DiskMap **dm, char* s, ...) {
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "error: ");
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}