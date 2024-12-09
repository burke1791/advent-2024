#ifndef ANTENNA_H
#define ANTENNA_H

typedef struct Coord {
  int x;
  int y;
} Coord;

typedef struct Antenna {
  char freq;
  Coord *loc;
} Antenna;

typedef struct AntennaList {
  int size;
  int count;
  Antenna **list;
} AntennaList;

typedef struct AntinodeList {
  int size;
  int count;
  Coord **list;
} AntinodeList;

Coord *new_coord(int x, int y);
void free_coord(Coord *c);

Antenna *new_antenna(char freq, Coord *loc);
void free_antenna(Antenna *a);

AntennaList *new_antennalist(int size);
void free_antennalist(AntennaList *al);

void append_antenna(AntennaList *al, Antenna *a);

AntinodeList *new_antinodelist(int size);
void free_antinodelist(AntinodeList *l);

void append_antinode(AntinodeList *l, Coord *loc);

#endif /* ANTENNA_H */