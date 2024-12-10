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
  struct DiskMapItem *dmi;
}

%token <i> FREEBLOCK FILEBLOCK
%type <disk> diskmap
%type <dmi> item

%start result

%%

result: diskmap {
      *dm = $1;
      YYACCEPT;
    }
  ;

diskmap: item {
      DiskMap *diskmap = new_diskmap(5);
      append_diskmapitem(diskmap, $1);

      $$ = diskmap;
    }
  | diskmap item {
      append_diskmapitem($1, $2);
    }
  ;

item: FREEBLOCK {
      DiskMapItem *it = new_diskmapitem(BT_FREE, $1, -1);
      $$ = it;
    }
  | FILEBLOCK {
      DiskMapItem *it = new_diskmapitem(BT_FILE, $1, -1);
      $$ = it;
    }


%%

void yyerror(DiskMap **dm, char* s, ...) {
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "error: ");
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}