%{

#include <stdbool.h>

typedef struct Calibration {
  int size;
  int count;
  int result;
  int *arr;
} Calibration;

typedef struct CalibrationList {
  int size;
  int count;
  Calibration **list;
} CalibrationList;

void new_operand(CalibrationList *cl, int val);
Calibration *c new_calibration(int size, int result);
void append_calibration(CalibrationList *cl, Calibration *c);

%}

%s ROW

%%

<ROW>[0-9]+   {
    int val = atoi(yytext);
    new_operand(cl, val);
  }

[0-9]+  {
    int val = atoi(yytext);
    Calibration *c = new_calibration(5, val);
    append_calibration(cl, c);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%

Calibration *new_calibration(int size, int result) {
  Calibration *c = malloc(sizeof(Calibration));
  c->count = 0;
  c->size = size;
  c->arr = malloc(size * sizeof(int));
  c->result = result;
  return c;
}

void free_calibration(Calibration *c) {
  free(c->arr);
  free(c);
}

CalibrationList *new_calibrationlist(int size) {
  CalibrationList *cl = malloc(sizeof(CalibrationList));
  cl->size = size;
  cl->count = 0;
  cl->list = malloc(size * sizeof(Calibration));
  return cl;
}

void free_calibrationlist(CalibrationList *cl) {
  for (int i = 0; i < cl->count; i++) {
    free_calibration(cl->list[i]);
  }
  free(cl->list);
  free(cl);
}

void append_calibration(CalibrationList *cl, Calibration *c) {
  if (cl->count >= cl->size) {
    cl->size <<= 1;
    cl->list = realloc(cl->list, cl->size * sizeof(Calibration));
  }

  cl->list[cl->count] = c;
  cl->count++;
}

void new_operand(CalibrationList *cl, int val) {
  Calibration *c = cl->list[cl->count - 1];

  if (c->count >= c->size) {
    c->size <<= 1;
    c->arr = realloc(c->arr, c->size * sizeof(int));
  }

  c->arr[c->count] = val;
  c->count++;
}

void print_calibration(Calibration *c) {
  printf("%d | ", c->result);

  for (int i = 0; i < c->count; i++) {
    printf("%d  ", c->arr[i]);
  }

  printf("\n");
}

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  CalibrationList *cl = new_calibrationlist(5);

  yylex();

  for (int i = 0; i < cl->count; i++) {
    print_calibration(cl->list[i]);
  }

  free_calibrationlist(cl);
}