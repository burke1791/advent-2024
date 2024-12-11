#ifndef TRAIL_H
#define TRAIL_H

typedef struct Coord {
  int x;
  int y;
} Coord;

typedef struct TrailHead {
  Coord *loc;
  int score;
} TrailHead;

typedef struct TrailHeadList {
  int size;
  int count;
  TrailHead **trails;
} TrailHeadList;

typedef struct SummitList {
  int size;
  int count;
  Coord **summits;
} SummitList;

Coord *new_coord(int x, int y);
void free_coord(Coord *c);

TrailHead *new_trailhead(Coord *loc);
void free_trailhead(TrailHead *th);

TrailHeadList *new_trailheadlist(int size);
void free_trailheadlist(TrailHeadList *l);

SummitList *new_summitlist(int size);
void free_summitlist(SummitList *l);

void append_trailhead(TrailHeadList *l, TrailHead *th);
void append_summit(SummitList *l, Coord *c);

#endif /* TRAIL_H */