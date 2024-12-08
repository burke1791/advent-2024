%{

#include <string.h>
#include <stdbool.h>

typedef struct Row {
  int size;
  int count;
  int *arr;
} Row;

typedef struct Grid {
  int size;
  int count;
  Row **rows;
} Grid;

Grid *g;

void new_letter(Grid *g, char *l);
void append_row(Grid *g, Row *r);
Row *new_row(int size);


%}

%s ROW

%%

<ROW>[XMAS]  {
    new_letter(g, yytext);
  }

[XMAS]  {
    Row *r = new_row(5);
    append_row(g, r);
    new_letter(g, yytext);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%

Row *new_row(int size) {
  Row *r = malloc(sizeof(Row));
  r->size = size;
  r->count = 0;
  r->arr = malloc(size * sizeof(int));
  return r;
}

void free_row(Row *r) {
  free(r->arr);
  free(r);
}

Grid *new_grid(int size) {
  Grid *g = malloc(sizeof(Grid));
  g->size = size;
  g->count = 0;
  g->rows = malloc(size * sizeof(Row));
  return g;
}

void free_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    free_row(g->rows[i]);
  }
  free(g->rows);
  free(g);
}

void append_row(Grid *g, Row *r) {
  if (g->count >= g->size) {
    g->size <<= 1;
    g->rows = realloc(g->rows, g->size * sizeof(Row));
  }

  g->rows[g->count] = r;
  g->count++;
}

void append_letter(Row *r, int val) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->arr = realloc(r->arr, r->size * sizeof(int));
  }

  r->arr[r->count] = val;
  r->count++;
}

void new_letter(Grid *g, char *l) {
  Row *r = g->rows[g->count - 1];
  if (strcmp(l, "X") == 0) {
    append_letter(r, 1);
  } else if (strcmp(l, "M") == 0) {
    append_letter(r, 2);
  } else if (strcmp(l, "A") == 0) {
    append_letter(r, 4);
  } else if (strcmp(l, "S") == 0) {
    append_letter(r, 8);
  } else {
    append_letter(r, 0);
  }
}

int is_xmas(Grid *g, int x, int y) {
  int line1 = g->rows[y - 1]->arr[x - 1] + g->rows[y + 1]->arr[x + 1];
  int line2 = g->rows[y + 1]->arr[x - 1] + g->rows[y - 1]->arr[x + 1];

  if (line1 == 10 && line2 == 10) return 1;

  return 0;
}

int get_xmas_count(Grid *g) {
  int count = 0;

  for (int y = 1; y < g->count - 1; y++) {
    for (int x = 1; x < g->rows[0]->count - 1; x++) {
      if (g->rows[y]->arr[x] == 4) {
        count += is_xmas(g, x, y);
      }
    }
  }

  return count;
}

void print_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    Row *r = g->rows[i];
    for (int j = 0; j < r->count; j++) {
      printf("%d", r->arr[j]);
    }
    printf("\n");
  }
}

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  g = new_grid(5);

  yylex();

  int xmasCount = get_xmas_count(g);
  printf("Count: %d\n", xmasCount);

  /* print_grid(g); */

  free_grid(g);
}