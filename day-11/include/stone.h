#ifndef STONE_H
#define STONE_H

#include <stdbool.h>


typedef struct Stone {
  long val;
  char *engraving;
} Stone;

typedef struct StoneList {
  int size;
  int count;
  Stone **stones;
} StoneList;

typedef struct Cache {
  Stone *stone;
  long result;
  int numBlinks;
} Cache;

typedef struct CacheList {
  int size;
  int count;
  Cache **cache;
} CacheList;

Stone *new_stone(char *engraving);
void free_stone(Stone *s);

StoneList *new_stonelist(int size);
void free_stonelist(StoneList *l, bool freeStones);

void append_stone(StoneList *l, Stone *s, bool copyStone);
void print_stonelist(StoneList *l);

Cache *new_cache(Stone *s, bool copyStone);
void free_cache(Cache *c);

CacheList *new_cachelist(int size);
void free_cachelist(CacheList *l);

void append_cache(CacheList *l, Cache *c);
void print_cachelist(CacheList *l);

void fill_cachelist(CacheList *l, int range, int cacheBlinks);

void blink(StoneList **l, int numBlinks, bool printEachLoop);
long blink_stones(StoneList *l, int numBlinks, CacheList *cl);

#endif /* STONE_H */