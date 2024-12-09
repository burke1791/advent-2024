%{

#include <stdbool.h>

#include "antenna.h"

typedef struct Row {
  int size;
  int count;
  char *arr;
} Row;

typedef struct Grid {
  int size;
  int count;
  Row **rows;
} Grid;

Grid *g;

void new_pos(Grid *g, char c);
void append_row(Grid *g, Row *r);
Row *new_row(int size);

%}

%s ROW

%%

<ROW>[a-zA-Z0-9.]   {
    new_pos(g, yytext[0]);
  }

[a-zA-Z0-9.]    {
    Row *r = new_row(5);
    append_row(g, r);
    new_pos(g, yytext[0]);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%

Row *new_row(int size) {
  Row *r = malloc(sizeof(Row));
  r->size = size;
  r->count = 0;
  r->arr = malloc(size * sizeof(char));
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

void append_pos(Row *r, char c) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->arr = realloc(r->arr, r->size * sizeof(char));
  }

  r->arr[r->count] = c;
  r->count++;
}

void new_pos(Grid *g, char c) {
  Row *r = g->rows[g->count - 1];
  append_pos(r, c);
}

void print_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    for (int j = 0; j < g->rows[i]->count; j++) {
      printf("%c", g->rows[i]->arr[j]);
    }
    printf("\n");
  }
}

AntennaList *find_antennas(Grid *g) {
  AntennaList *al = new_antennalist(5);

  for (int y = 0; y < g->count; y++) {
    for (int x = 0; x < g->rows[y]->count; x++) {
      char c = g->rows[y]->arr[x];
      if (c != '.') {
        Coord *loc = new_coord(x, y);
        Antenna *a = new_antenna(c, loc);
        append_antenna(al, a);
      }
    }
  }

  return al;
}

bool is_identical_coord(Coord *c1, Coord *c2) {
  return c1->x == c2->x && c1->y == c2->y;
}

Coord *compute_distance(Coord *loc1, Coord *loc2) {
  int x = loc2->x - loc1->x;
  int y = loc2->y - loc1->y;
  return new_coord(x, y);
}

void add_antinodes(AntinodeList *l, Antenna *a1, Antenna *a2, int maxRow, int maxCol) {
  Coord *dist = compute_distance(a1->loc, a2->loc);

  bool withinBoundary = true;
  int loopCount = 0;
  int maxLoops = 10000;
  int multiple = 1;

  // antinodes for the antennas
  append_antinode(l, a1->loc);
  append_antinode(l, a2->loc);

  // move in the upper direction
  while (withinBoundary && loopCount < maxLoops) {
    Coord *c = new_coord(a1->loc->x - (multiple * dist->x), a1->loc->y - (multiple * dist->y));
    if (c->x < 0 || c->x > maxCol || c->y < 0 || c->y > maxRow) {
      withinBoundary = false;
    } else {
      append_antinode(l, c);
    }
    free_coord(c);
    loopCount++;
    multiple++;
  }

  if (loopCount >= maxLoops) printf("infinite loop :(\n");

  // move in the lower direction
  withinBoundary = true;
  loopCount = 0;
  multiple = 1;
  while (withinBoundary && loopCount < maxLoops) {
    Coord *c = new_coord(a1->loc->x + (multiple * dist->x), a1->loc->y + (multiple * dist->y));
    if (c->x < 0 || c->x > maxCol || c->y < 0 || c->y > maxRow) {
      withinBoundary = false;
    } else {
      append_antinode(l, c);
    }
    free_coord(c);
    loopCount++;
    multiple++;
  }

  if (loopCount >= maxLoops) printf("infinite loop :(\n");

  free(dist);
}

AntinodeList *identify_antinodes(Grid *g, AntennaList *al) {
  int maxRow = g->count - 1;
  int maxCol = g->rows[0]->count - 1;
  AntinodeList *l = new_antinodelist(5);

  for (int i = 0; i < (al->count - 1); i++) {
    Antenna *a1 = al->list[i];
    for (int j = i + 1; j < al->count; j++) {
      Antenna *a2 = al->list[j];
      if (a1->freq == a2->freq) {
        add_antinodes(l, a1, a2, maxRow, maxCol);
      }
    }
  }

  return l;
}

char get_char(Grid *g, AntinodeList *l, int x, int y) {
  char ch = '.';
  if (g->rows[y]->arr[x] != ch) return g->rows[y]->arr[x];

  Coord *c = new_coord(x, y);
  for (int i = 0; i < l->count; i++) {
    if (is_identical_coord(c, l->list[i])) ch = '#';
  }

  free_coord(c);

  return ch;
}

void print_grid_with_antinodes(Grid *g, AntinodeList *l) {
  for (int i = 0; i < g->count; i++) {
    for (int j = 0; j < g->rows[i]->count; j++) {
      char c = get_char(g, l, j, i);
      printf("%c", c);
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

  AntennaList *al = find_antennas(g);
  AntinodeList *l = identify_antinodes(g, al);
  printf("Num antinodes: %d\n", l->count);

  free_grid(g);
  free_antennalist(al);
  free_antinodelist(l);
}