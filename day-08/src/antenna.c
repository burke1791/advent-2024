#include <stdlib.h>
#include <stdbool.h>

#include "antenna.h"

Coord *new_coord(int x, int y) {
  Coord *c = malloc(sizeof(Coord));
  c->x = x;
  c->y = y;
  return c;
}

void free_coord(Coord *c) {
  free(c);
}

Antenna *new_antenna(char freq, Coord *loc) {
  Antenna *a = malloc(sizeof(Antenna));
  a->freq = freq;
  a->loc = loc;
  return a;
}

void free_antenna(Antenna *a) {
  free_coord(a->loc);
  free(a);
}

AntennaList *new_antennalist(int size) {
  AntennaList *al = malloc(sizeof(AntennaList));
  al->size = size;
  al->count = 0;
  al->list = malloc(size * sizeof(Antenna));
  return al;
}

void free_antennalist(AntennaList *al) {
  for (int i = 0; i < al->count; i++) {
    free_antenna(al->list[i]);
  }
  free(al->list);
  free(al);
}

void append_antenna(AntennaList *al, Antenna *a) {
  if (al->count >= al->size) {
    al->size <<= 1;
    al->list = realloc(al->list, al->size * sizeof(Antenna));
  }

  al->list[al->count] = a;
  al->count++;
}

AntinodeList *new_antinodelist(int size) {
  AntinodeList *al = malloc(sizeof(AntinodeList));
  al->size = size;
  al->count = 0;
  al->list = malloc(size * sizeof(Coord));
  return al;
}

void free_antinodelist(AntinodeList *l) {
  for (int i = 0; i < l->count; i++) {
    free_coord(l->list[i]);
  }
  free(l->list);
  free(l);
}

void append_antinode(AntinodeList *l, Coord *loc) {
  for (int i = 0; i < l->count; i++) {
    if (l->list[i]->x == loc->x && l->list[i]->y == loc->y) return;
  }

  Coord *dupe = new_coord(loc->x, loc->y);

  if (l->count >= l->size) {
    l->size <<= 1;
    l->list = realloc(l->list, l->size * sizeof(Coord));
  }

  l->list[l->count] = dupe;
  l->count++;
}