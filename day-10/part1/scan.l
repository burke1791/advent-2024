%{

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

void new_pos(Grid *g, int val);
void append_row(Grid *g, Row *r);
Row *new_row(int size);

%}

%s ROW

%%

<ROW>[0-9]   {
    int val = atoi(yytext);
    new_pos(g, val);
  }

[0-9]    {
    Row *r = new_row(5);
    append_row(g, r);
    int val = atoi(yytext);
    new_pos(g, val);
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

void append_pos(Row *r, int val) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->arr = realloc(r->arr, r->size * sizeof(int));
  }

  r->arr[r->count] = val;
  r->count++;
}

void new_pos(Grid *g, int val) {
  Row *r = g->rows[g->count - 1];
  append_pos(r, val);
}

void print_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    for (int j = 0; j < g->rows[i]->count; j++) {
      printf("%d", g->rows[i]->arr[j]);
    }
    printf("\n");
  }
}

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  g = new_grid(5);

  yylex();

  print_grid(g);

  free_grid(g);
}