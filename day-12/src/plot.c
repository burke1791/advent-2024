#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "plot.h"

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

void append_char(Row *r, char c) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->arr = realloc(r->arr, r->size * sizeof(char));
  }

  r->arr[r->count] = c;
  r->count++;
}

void print_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    for (int j = 0; j < g->rows[i]->count; j++) {
      printf("%c", g->rows[i]->arr[j]);
    }
    printf("\n");
  }
}

Coord *new_coord(int x, int y) {
  Coord *c = malloc(sizeof(Coord));
  c->x = x;
  c->y = y;
  return c;
}

void free_coord(Coord *c) {
  free(c);
}

CoordList *new_coordlist(int size) {
  CoordList *l = malloc(sizeof(CoordList));
  l->size = size;
  l->count = 0;
  l->coords = malloc(size * sizeof(Coord));
  return l;
}

void free_coordlist(CoordList *l) {
  for (int i = 0; i < l->count; i++) {
    free_coord(l->coords[i]);
  }
  free(l->coords);
  free(l);
}

void append_to_coordlist(CoordList *l, Coord *c) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->coords = realloc(l->coords, l->size * sizeof(Coord));
  }

  l->coords[l->count] = c;
  l->count++;
}

Plot *new_plot(Coord *c) {
  Plot *p = malloc(sizeof(Plot));
  p->boundaries = 0;
  p->loc = c;
  return p;
}

void free_plot(Plot *p) {
  free_coord(p->loc);
  free(p);
}

Region *new_region(int size, char crop) {
  Region *r = malloc(sizeof(Region));
  r->crop = crop;
  r->size = size;
  r->count = 0;
  r->perimeter = 0;
  r->vertices = 0;
  r->plots = malloc(size * sizeof(Plot));
  return r;
}

void free_region(Region *r) {
  for (int i = 0; i < r->count; i++) {
    free_plot(r->plots[i]);
  }
  free(r->plots);
  free(r);
}

Farm *new_farm(int size) {
  Farm *f = malloc(sizeof(Farm));
  f->size = size;
  f->count = 0;
  f->regions = malloc(size * sizeof(Region));
  return f;
}

void free_farm(Farm *f) {
  for (int i = 0; i < f->count; i++) {
    free_region(f->regions[i]);
  }
  free(f->regions);
  free(f);
}

void append_plot(Region *r, Plot *p) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->plots = realloc(r->plots, r->size * sizeof(Plot));
  }

  r->plots[r->count] = p;
  r->count++;
}

void append_region(Farm *f, Region *r) {
  if (f->count >= f->size) {
    f->size <<= 1;
    f->regions = realloc(f->regions, f->size * sizeof(Region));
  }

  f->regions[f->count] = r;
  f->count++;
}

static void print_region(Region *r) {
  printf("%c | area: %d | perimeter: %d | vertices: %d\n", r->crop, r->count, r->perimeter, r->vertices);
}

void print_farm(Farm *f) {
  for (int i = 0; i < f->count; i++) {
    print_region(f->regions[i]);
  }
}

static bool is_coord_identical(Coord *c1, Coord *c2) {
  return c1->x == c2->x && c1->y == c2->y;
}

static bool is_coord_in_list(CoordList *l, Coord *c) {
  for (int i = 0; i < l->count; i++) {
    if (is_coord_identical(l->coords[i], c)) return true;
  }

  return false;
}

static int identify_region(Farm *f, Grid *g, Region *r, CoordList *assigned, char crop, int x, int y) {
  int maxRow = g->count - 1;
  int maxCol = g->rows[0]->count - 1;

  if (x < 0 || x > maxCol || y < 0 || y > maxRow) return 0;
  if (g->rows[y]->arr[x] != crop) return 0;

  Coord *c = new_coord(x, y);

  if (is_coord_in_list(assigned, c)) {
    free(c);
    return 0;
  }

  append_to_coordlist(assigned, c);

  Coord *c2 = new_coord(x, y);
  append_coord(r, c2);

  return 1 +
    identify_region(f, g, r, assigned, crop, x - 1, y) +
    identify_region(f, g, r, assigned, crop, x + 1, y) +
    identify_region(f, g, r, assigned, crop, x, y - 1) +
    identify_region(f, g, r, assigned, crop, x, y + 1);
}

static int calc_perimter_for_plot(Grid *g, Plot *plot) {
  int perimeter = 0;

  char crop = g->rows[plot->loc->y]->arr[plot->loc->x];

  int maxRow = g->count - 1;
  int maxCol = g->rows[0]->count - 1;

  int x1 = plot->loc->x - 1;
  int x2 = plot->loc->x + 1;
  int y1 = plot->loc->y - 1;
  int y2 = plot->loc->y + 1;

  if (x1 < 0 || g->rows[plot->loc->y]->arr[x1] != crop) perimeter++;
  if (x2 > maxCol || g->rows[plot->loc->y]->arr[x2] != crop) perimeter++;
  if (y1 < 0 || g->rows[y1]->arr[plot->loc->x] != crop) perimeter++;
  if (y2 > maxRow || g->rows[y2]->arr[plot->loc->x] != crop) perimeter++;

  return perimeter;
}

static void compute_perimeters(Farm *f, Grid *g) {
  int perimeter;
  for (int i = 0; i < f->count; i++) {
    perimeter = 0;
    for (int j = 0; j < f->regions[i]->count; j++) {
      perimeter += calc_perimter_for_plot(g, f->regions[i]->plots[j]);
    }
    f->regions[i]->perimeter = perimeter;
  }
}

static int calc_boundaries_for_plot(Grid *g, Plot *plot) {
  char crop = g->rows[plot->loc->y]->arr[plot->loc->x];

  int maxRow = g->count - 1;
  int maxCol = g->rows[0]->count - 1;

  int x1 = plot->loc->x - 1;
  int x2 = plot->loc->x + 1;
  int y1 = plot->loc->y - 1;
  int y2 = plot->loc->y + 1;

  bool top = false;
  bool right = false;
  bool bot = false;
  bool left = false;

  if (x1 < 0 || g->rows[plot->loc->y]->arr[x1] != crop) left = true;
  if (x2 > maxCol || g->rows[plot->loc->y]->arr[x2] != crop) right = true;
  if (y1 < 0 || g->rows[y1]->arr[plot->loc->x] != crop) top = true;
  if (y2 > maxRow || g->rows[y2]->arr[plot->loc->x] != crop) bot = true;

  int numBoundaries = 0;

  if (left) numBoundaries++;
  if (top) numBoundaries++;
  if (right) numBoundaries++;
  if (bot) numBoundaries++;

  return numBoundaries;
}

static int calc_vertices_for_plot(Grid *g, Plot *p) {

}

static void compute_vertices(Farm *f, Grid *g) {
  int boundaries;
  for (int i = 0; i < f->count; i++) {
    boundaries = 0;
    for (int j = 0; j < f->regions[i]->count; j++) {
      f->regions[i]->plots[j]->boundaries = calc_boundaries_for_plot(g, f->regions[i]->plots[j]);
    }
  }

  
}

void analyze_farm(Farm *f, Grid *g) {
  CoordList *l = new_coordlist(5);

  int maxRow = g->count;
  int maxCol = g->rows[0]->count;

  for (int y = 0; y < maxRow; y++) {
    for (int x = 0; x < maxCol; x++) {
      Region *r = new_region(5, g->rows[y]->arr[x]);
      int regionSize = identify_region(f, g, r, l, g->rows[y]->arr[x], x, y);

      if (regionSize <= 0) {
        free_region(r);
      } else {
        append_region(f, r);
      }
    }
  }

  compute_perimeters(f, g);
  compute_vertices(f, g);

  free_coordlist(l);
}

int compute_fence_price(Farm *f) {
  int price = 0;
  for (int i = 0; i < f->count; i++) {
    price += (f->regions[i]->count * f->regions[i]->perimeter);
  }
  return price;
}

int compute_fence_price_with_discount(Farm *f) {
  int price = 0;
  for (int i = 0; i < f->count; i++) {
    price += (f->regions[i]->count * f->regions[i]->vertices);
  }
  return price;
}