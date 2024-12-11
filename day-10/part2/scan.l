%{

#include "trail.h"

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

int compute_trailhead_score(Grid *g, SummitList *l, int prevElevation, int x, int y) {
  int maxRow = g->count - 1;
  int maxCol = g->rows[0]->count - 1;
  if (x < 0 || x > maxCol || y < 0 || y > maxRow) return 0;

  int currentElevation = g->rows[y]->arr[x];

  if ((currentElevation - prevElevation) != 1) return 0;

  if (currentElevation == 9 && prevElevation == 8) {
    Coord *c = new_coord(x, y);
    append_summit(l, c);
    return 1;
  }

  return compute_trailhead_score(g, l, currentElevation, x, y - 1) +
    compute_trailhead_score(g, l, currentElevation, x + 1, y) +
    compute_trailhead_score(g, l, currentElevation, x, y + 1) +
    compute_trailhead_score(g, l, currentElevation, x - 1, y);
}

void compute_scores(TrailHeadList *l, Grid *g) {
  for (int i = 0; i < l->count; i++) {
    TrailHead *th = l->trails[i];
    SummitList *l = new_summitlist(5);
    int score = compute_trailhead_score(g, l, -1, th->loc->x, th->loc->y);
    th->score = score;
    free_summitlist(l);
  }
}

TrailHeadList *find_trailheads(Grid *g) {
  TrailHeadList *l = new_trailheadlist(5);

  for (int y = 0; y < g->count; y++) {
    Row *r = g->rows[y];
    for (int x = 0; x < r->count; x++) {
      if (r->arr[x] == 0) {
        Coord *c = new_coord(x, y);
        TrailHead *th = new_trailhead(c);
        append_trailhead(l, th);
      }
    }
  }

  return l;
}

int compute_total_score(TrailHeadList *l) {
  int total = 0;
  for (int i = 0; i < l->count; i++) {
    total += l->trails[i]->score;
  }

  return total;
}

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  g = new_grid(5);

  yylex();

  /* print_grid(g); */

  TrailHeadList *l = find_trailheads(g);
  compute_scores(l, g);
  int totalScore = compute_total_score(l);
  printf("total: %d\n", totalScore);

  free_grid(g);
  free_trailheadlist(l);
}