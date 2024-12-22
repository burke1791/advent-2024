#ifndef PLOT_H
#define PLOT_H

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

Grid *new_grid(int size);
void free_grid(Grid *g);

Row *new_row(int size);
void free_row(Row *r);

void append_row(Grid *g, Row *r);
void append_char(Row *r, char c);

void print_grid(Grid *g);

typedef struct Coord {
  int x;
  int y;
} Coord;

typedef struct CoordList {
  int size;
  int count;
  Coord **coords;
} CoordList;

typedef struct Plot {
  Coord *loc;
  int boundaries;
} Plot;

typedef struct Region {
  int perimeter;
  int vertices;
  char crop;
  int size;
  int count;  // same as area
  Plot **plots;
} Region;

typedef struct Farm {
  int size;
  int count;
  Region **regions;
} Farm;

Coord *new_coord(int x, int y);
void free_coord(Coord *c);

CoordList *new_coordlist(int size);
void free_coordlist(CoordList *l);
void append_to_coordlist(CoordList *l, Coord *c);

Region *new_region(int size, char crop);
void free_region(Region *r);

Farm *new_farm(int size);
void free_farm(Farm *f);

void append_plot(Region *r, Plot *p);
void append_region(Farm *f, Region *r);

void print_farm(Farm *f);

void analyze_farm(Farm *f, Grid *g);
int compute_fence_price(Farm *f);
int compute_fence_price_with_discount(Farm *f);

#endif /* PLOT_H */