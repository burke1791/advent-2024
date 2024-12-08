#ifndef SPEC_H
#define SPEC_H

typedef struct Rule {
  int left;
  int right;
} Rule;

typedef struct Update {
  int size;
  int count;
  int *pages;
} Update;

typedef enum ListType {
  T_Rule,
  T_Update
} ListType;

typedef struct List {
  ListType type;
  int size;
  int count;
  void **l;
} List;

typedef struct Spec {
  List *rules;
  List *updates;
} Spec;

Spec *new_spec();
void free_spec(Spec *s);

Rule *new_rule(int left, int right);
void free_rule(Rule *r);

Update *new_update(int size);
void free_update(Update *u);

List *new_list(int size, ListType type);
void free_list(List *l);

void append_page(Update *u, int page);
void append_to_list(List *l, void *item);

#endif /* SPEC_H */