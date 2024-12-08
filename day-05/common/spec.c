#include <stdlib.h>

#include "spec.h"

Spec *new_spec() {
  Spec *s = malloc(sizeof(Spec));
  s->rules = new_list(5, T_Rule);
  s->updates = new_list(5, T_Update);
  return s;
}

void free_spec(Spec *s) {
  free_list(s->rules);
  free_list(s->updates);
  free(s);
}

List *new_list(int size, ListType type) {
  List *l = malloc(sizeof(List));
  l->type = type;
  l->size = size;
  l->count = 0;
  
  switch (type) {
    case T_Rule:
      l->l = malloc(size * sizeof(Rule));
      break;
    case T_Update:
      l->l = malloc(size * sizeof(Update));
      break;
  }

  return l;
}

void free_list(List *l) {
  for (int i = 0; i < l->count; i++) {
    switch (l->type) {
      case T_Rule:
        free_rule((Rule*)l->l[i]);
        break;
      case T_Update:
        free_update((Update*)l->l[i]);
        break;
    }
  }
  free(l->l);
  free(l);
}

Rule *new_rule(int left, int right) {
  Rule *r = malloc(sizeof(Rule));
  r->left = left;
  r->right = right;
  return r;
}

void free_rule(Rule *r) {
  free(r);
}

Update *new_update(int size) {
  Update *u = malloc(sizeof(Update));
  u->size = size;
  u->count = 0;
  u->pages = malloc(size * sizeof(int));
  return u;
}

void free_update(Update *u) {
  free(u->pages);
  free(u);
}

void append_page(Update *u, int page) {
  if (u->count >= u->size) {
    u->size <<= 1;
    u->pages = realloc(u->pages, u->size * sizeof(int));
  }

  u->pages[u->count] = page;
  u->count++;
}

static void append_rule(List *l, Rule *r) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->l = realloc(l->l, l->size * sizeof(Rule));
  }

  l->l[l->count] = r;
  l->count++;
}

static void append_update(List *l, Update *u) {
  if (l->count >= l->size) {
    l->size <<= 1;
    l->l = realloc(l->l, l->size * sizeof(Update));
  }

  l->l[l->count] = u;
  l->count++;
}

void append_to_list(List *l, void *item) {
  switch (l->type) {
    case T_Rule:
      append_rule(l, (Rule*)item);
      break;
    case T_Update:
      append_update(l, (Update*)item);
      break;
  }
}