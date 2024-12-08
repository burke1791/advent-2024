#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "spec.h"
#include "gram.tab.h"

extern FILE *yyin;

void print_update(Update *u) {
  for (int j = 0; j < u->count; j++) {
    printf("%d,", u->pages[j]);
  }
  printf("\n");
}

void print_update_list(List *l) {
  for (int i = 0; i < l->count; i++) {
    Update *u = l->l[i];
    print_update(u);
  }
}

void print_rule(Rule *r) {
  printf("Rule: %d|%d\n", r->left, r->right);
}

bool is_update_valid(Update *u, List *rules) {

  for (int i = 0; i < rules->count; i++) {
    bool first = false;
    bool second = false;
    bool redFlag = false;

    Rule *r = rules->l[i];
    for (int j = 0; j < u->count; j++) {
      if (u->pages[j] == r->left) first = true;
      if (u->pages[j] == r->right) second = true;

      if (second && !first) {
        redFlag = true;
      }
    }

    if (redFlag && first) {
      return false;
    }
  }

  return true;
}

List *get_invalid_updates(Spec *s) {
  List *l = new_list(5, T_Update);

  for (int i = 0; i < s->updates->count; i++) {
    if (!is_update_valid((Update*)s->updates->l[i], s->rules)) {
      append_to_list(l, s->updates->l[i]);
    }
  }

  return l;
}

int compute_middle_sum(List *updates) {
  int sum = 0;

  for (int i = 0; i < updates->count; i++) {
    Update *u = updates->l[i];
    if (u->count % 2 == 0) printf("even number: %d\n", u->count);

    int ind = u->count / 2;
    sum += u->pages[ind];
  }

  return sum;
}

List *get_subrules(Update *u, List *rules) {
  List *subRules = new_list(5, T_Rule);

  for (int i = 0; i < rules->count; i++) {
    Rule *r = rules->l[i];
    bool left = false;
    bool right = false;

    for (int j = 0; j < u->count; j++) {
      if (r->left == u->pages[j]) left = true;
      if (r->right == u->pages[j]) right = true;
    }

    if (left && right) {
      append_to_list(subRules, r);
    }
  }

  return subRules;
}

void swap_page(Update *u, int pos1, int pos2) {
  int tmp = u->pages[pos1];
  u->pages[pos1] = u->pages[pos2];
  u->pages[pos2] = tmp;
}

void sort_update(Update *u, List *subRules) {
  int loopCount = 0;
  bool isValid = false;

  while (loopCount < 100 && !isValid) {
    isValid = true;
    for (int i = 0; i < subRules->count; i++) {
      Rule *r = subRules->l[i];
      int leftPos = -1;
      int rightPos = -1;
      for (int j = 0; j < u->count; j++) {
        if (u->pages[j] == r->left) leftPos = j;
        if (u->pages[j] == r->right) rightPos = j;

        if (leftPos >= 0 && rightPos >= 0) {
          if (leftPos > rightPos) {
            swap_page(u, leftPos, rightPos);
            isValid = false;
          }
          break;
        }
      }
    }
    loopCount++;
  }

  if (loopCount >= 100) {
    printf("infinite loop blocker hit\n");
  }
}

void sort_updates(List *updates, List *rules) {
  for (int i = 0; i < updates->count; i++) {
    Update *u = updates->l[i];
    List *subRules = get_subrules(u, rules);
    sort_update(u, subRules);
    free(subRules->l);
    free(subRules);
  }
}

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  Spec *s;

  yyparse(&s);

  printf("rule count:   %d\n", s->rules->count);
  printf("update count: %d\n", s->updates->count);

  List *invalidUpdates = get_invalid_updates(s);
  sort_updates(invalidUpdates, s->rules);
  int middleSum = compute_middle_sum(invalidUpdates);

  printf("sum: %d\n", middleSum);

  free_spec(s);

  free(invalidUpdates->l);
  free(invalidUpdates);
}