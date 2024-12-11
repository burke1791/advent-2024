#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "trail.h"

Coord *new_coord(int x, int y) {
  Coord *c = malloc(sizeof(Coord));
  c->x = x;
  c->y = y;
  return c;
}

void free_coord(Coord *c) {
  free(c);
}

TrailHead *new_trailhead(Coord *loc) {
  TrailHead *th = malloc(sizeof(TrailHead));
  th->loc = loc;
  th->score = 0;
  return th;
}

void free_trailhead(TrailHead *th) {
  free_coord(th->loc);
  free(th);
}

TrailHeadList *new_trailheadlist(int size) {
  TrailHeadList *l = malloc(sizeof(TrailHeadList));
  l->size = size;
  l->count = 0;
  l->trails = malloc(size * sizeof(TrailHead));
  return l;
}

void free_trailheadlist(TrailHeadList *l) {
  for (int i = 0; i < l->count; i++) {
    free_trailhead(l->trails[i]);
  }
  free(l->trails);
  free(l);
}

SummitList *new_summitlist(int size) {
  SummitList *l = malloc(sizeof(SummitList));
  l->size = size;
  l->count = 0;
  l->summits = malloc(size * sizeof(Coord));
  return l;
}

void free_summitlist(SummitList *l) {
  for (int i = 0; i < l->count; i++) {
    free_coord(l->summits[i]);
  }
  free(l->summits);
  free(l);
}

void append_trailhead(TrailHeadList *l, TrailHead *th) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->trails = realloc(l->trails, l->size * sizeof(TrailHead));
  }

  l->trails[l->count] = th;
  l->count++;
}

bool is_coord_identical(Coord *c1, Coord *c2) {
  return c1->x == c2->x && c1->y == c2->y;
}

void append_summit(SummitList *l, Coord *c) {
  for (int i = 0; i < l->count; i++) {
    if (is_coord_identical(l->summits[i], c)) {
      free_coord(c);
      return;
    }
  }

  Coord *c2 = new_coord(c->x, c->y);

  if (l->count >= l->size) {
    l->size <<= 1;
    l->summits = realloc(l->summits, l->size * sizeof(Coord));
  }

  l->summits[l->count] = c2;
  l->count++;

  free_coord(c);
}