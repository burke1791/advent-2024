%{

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

Coord *compute_distance(Coord *loc1, Coord *loc2) {
  int x = loc2->x - loc1->x;
  int y = loc2->y - loc1->y;
  return new_coord(x, y);
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
        Coord *dist = compute_distance(a1->loc, a2->loc);
        Coord *anti1 = new_coord(a1->loc->x - dist->x, a1->loc->y - dist->y);
        Coord *anti2 = new_coord(a1->loc->x + (2 * dist->x), a1->loc->y + (2 * dist->y));

        if (anti1->x >= 0 && anti1->x <= maxCol && anti1->y >= 0 && anti1->y <= maxRow) {
          append_antinode(l, anti1);
        }

        if (anti2->x >= 0 && anti2->x <= maxCol && anti2->y >= 0 && anti2->y <= maxRow) {
          append_antinode(l, anti2);
        }

        free_coord(dist);
        free_coord(anti1);
        free_coord(anti2);
      }
    }
  }

  return l;
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