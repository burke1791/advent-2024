#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

#include "stone.h"

static long blink_0(int numBlinks, long total, CacheList *cl);
static long blink_1(int numBlinks, long total, CacheList *cl);
static long blink_2(int numBlinks, long total, CacheList *cl);
static long blink_3(int numBlinks, long total, CacheList *cl);
static long blink_4(int numBlinks, long total, CacheList *cl);
static long blink_5(int numBlinks, long total, CacheList *cl);
static long blink_6(int numBlinks, long total, CacheList *cl);
static long blink_7(int numBlinks, long total, CacheList *cl);
static long blink_8(int numBlinks, long total, CacheList *cl);
static long blink_9(int numBlinks, long total, CacheList *cl);
static long compute_total_stones(long val, int numBlinks, long total, CacheList *cl);

char *long_to_char(long val) {
  char buffer[64] = { 0 };
  snprintf(buffer, sizeof(buffer), "%li", val);
  return strdup(buffer);
}

Stone *new_stone(char *engraving) {
  Stone *s = malloc(sizeof(Stone));
  
  long val = atol(engraving);
  s->val = val;
  s->engraving = long_to_char(val);

  return s;
}

void free_stone(Stone *s) {
  if (s->engraving != NULL) free(s->engraving);
  free(s);
}

StoneList *new_stonelist(int size) {
  StoneList *l = malloc(sizeof(StoneList));
  l->size = size;
  l->count = 0;
  l->stones = malloc(size * sizeof(Stone));
  return l;
}

void free_stonelist(StoneList *l, bool freeStones) {
  if (freeStones) {
    for (int i = 0; i < l->count; i++) {
      free_stone(l->stones[i]);
    }
  }
  free(l->stones);
  free(l);
}

void append_stone(StoneList *l, Stone *s, bool copyStone) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->stones = realloc(l->stones, l->size * sizeof(Stone));
  }

  Stone *s2;
  
  if (copyStone) {
    s2 = new_stone(s->engraving);
  } else {
    s2 = s;
  }

  l->stones[l->count] = s2;
  l->count++;
}

static void print_stone(Stone *s) {
  printf("  %s", s->engraving);
}

void print_stonelist(StoneList *l) {
  for (int i = 0; i < l->count; i++) {
    print_stone(l->stones[i]);
  }
  printf("\n");
}

Cache *new_cache(Stone *s, bool copyStone) {
  Cache *c = malloc(sizeof(Cache));
  c->result = 0;
  c->numBlinks = 0;

  Stone *s2;
  
  if (copyStone) {
    s2 = new_stone(s->engraving);
  } else {
    s2 = s;
  }

  c->stone = s2;

  return c;
}

void free_cache(Cache *c) {
  free_stone(c->stone);
  free(c);
}

CacheList *new_cachelist(int size) {
  CacheList *l = malloc(sizeof(CacheList));
  l->size = size;
  l->count = 0;
  l->cache = malloc(size * sizeof(Cache));
  return l;
}

void free_cachelist(CacheList *l) {
  for (int i = 0; i < l->count; i++) {
    free_cache(l->cache[i]);
  }
  free(l->cache);
  free(l);
}

void append_cache(CacheList *l, Cache *c) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->cache = realloc(l->cache, l->size * sizeof(Cache));
  }

  l->cache[l->count] = c;
  l->count++;
}

static void print_cache(Cache *c) {
  printf("blinks: %d\n", c->numBlinks);
  printf("val: %ld | total: %ld\n", c->stone->val, c->result);
}

void print_cachelist(CacheList *l) {
  printf("===========  Cache List  ============\n");
  for (int i = 0; i < l->count; i++) {
    print_cache(l->cache[i]);
    printf("-----\n");
  }
  printf("=====================================\n");
}

void change_stone(StoneList *l, Stone *s) {
  int len = strlen(s->engraving);
  if (s->val == 0) {
    Stone *s1 = new_stone("1");
    append_stone(l, s1, false);
  } else if ((len % 2) == 0) {
    char *c1 = malloc(((len / 2) + 1) * sizeof(char));
    char *c2 = malloc(((len / 2) + 1) * sizeof(char));
    memcpy(c1, s->engraving, len / 2);
    c1[len / 2] = '\0';
    memcpy(c2, s->engraving + (len / 2), len / 2);
    c2[len / 2] = '\0';

    Stone *s1 = new_stone(c1);
    Stone *s2 = new_stone(c2);

    free(c1);
    free(c2);

    append_stone(l, s1, false);
    append_stone(l, s2, false);
  } else {
    char *c1 = long_to_char(s->val * 2024);
    Stone *s1 = new_stone(c1);
    free(c1);
    append_stone(l, s1, false);
  }
}

void change_stones(StoneList **l) {
  StoneList *sl = new_stonelist(5);

  for (int i = 0; i < (*l)->count; i++) {
    change_stone(sl, (*l)->stones[i]);
  }

  free_stonelist(*l, true);
  *l = sl;
}

void blink(StoneList **l, int numBlinks, bool printEachLoop) {
  for (int i = 0; i < numBlinks; i++) {
    change_stones(l);
    if (printEachLoop) print_stonelist(*l);
  }
}

static long get_cache_result(CacheList *cl, int numBlinks, long val) {
  if (cl != NULL) {
    for (int i = 0; i < cl->count; i++) {
      if (cl->cache[i]->stone->val == val && cl->cache[i]->numBlinks == numBlinks) {
        return cl->cache[i]->result;
      }
    }
  }

  return -1;
}

static long compute_total_stones(long val, int numBlinks, long total, CacheList *cl) {
  long cachedStones = get_cache_result(cl, numBlinks, val);

  if (cachedStones > 0) {
    return total + cachedStones;
  }

  StoneList *l = new_stonelist(5);
  char *c1 = long_to_char(val);
  Stone *s2 = new_stone(c1);
  append_stone(l, s2, false);
  free(c1);
  blink(&l, 1, false);
  return total + blink_stones(l, numBlinks - 1, cl);
}

void fill_cachelist(CacheList *l, int range, int cacheBlinks) {
  for (int i = 0; i < range; i++) {
    for (int j = 1; j <= cacheBlinks; j++) {
      char *c1 = long_to_char((long)i);
      Stone *s = new_stone(c1);
      free(c1);
      Cache *c = new_cache(s, false);
      c->numBlinks = j;
      append_cache(l, c);
    }
  }
}

long blink_stones(StoneList *l, int numBlinks, CacheList *cl) {
  long totalStones = 0;

  if (numBlinks > 0) {
    for (int i = 0; i < l->count; i++) {
      totalStones += compute_total_stones(l->stones[i]->val, numBlinks, 0, cl);
    }
  } else {
    totalStones = l->count;
  }

  free_stonelist(l, true);
  return totalStones;
}