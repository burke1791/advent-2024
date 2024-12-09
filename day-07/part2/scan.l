%{

#include <stdbool.h>
#include <math.h>

typedef enum Operator {
  MUL,
  ADD,
  CONC
} Operator;

typedef struct Calibration {
  int size;
  int count;
  long long result;
  long long *arr;
} Calibration;

typedef struct CalibrationList {
  int size;
  int count;
  Calibration **list;
} CalibrationList;

CalibrationList *cl;

void new_operand(CalibrationList *cl, long long val);
Calibration *new_calibration(int size, long long result);
void append_calibration(CalibrationList *cl, Calibration *c);

%}

%s ROW

%%

<ROW>[0-9]+   {
    long long val = atoll(yytext);
    new_operand(cl, val);
  }

[0-9]+  {
    long long val = atoll(yytext);
    Calibration *c = new_calibration(5, val);
    append_calibration(cl, c);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%

Calibration *new_calibration(int size, long long result) {
  Calibration *c = malloc(sizeof(Calibration));
  c->count = 0;
  c->size = size;
  c->arr = malloc(size * sizeof(long long));
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

void new_operand(CalibrationList *cl, long long val) {
  Calibration *c = cl->list[cl->count - 1];

  if (c->count >= c->size) {
    c->size <<= 1;
    c->arr = realloc(c->arr, c->size * sizeof(long long));
  }

  c->arr[c->count] = val;
  c->count++;
}

void print_calibration(Calibration *c) {
  printf("%lld | ", c->result);

  for (int i = 0; i < c->count; i++) {
    printf("%lld  ", c->arr[i]);
  }

  printf("\n");
}

long long concatenate(unsigned long long val1, unsigned long long val2) {
  unsigned long long pow = 10;
  while (val2 >= pow) {
    pow *= 10LL;
  }

  return val1 * pow + val2;
}

long long compute(long long total, long long val, Operator op) {
  long long res;
  switch (op) {
    case MUL:
      res = total * val;
      break;
    case ADD:
      res = total + val;
      break;
    case CONC:
      res = concatenate(total, val);
      break;
  }

  return res;
}

bool calibration_is_valid(Calibration *c, long long total, int pos) {
  // the total is equal to the calibration result AND we have no more numbers to check
  if (total == c->result && pos >= c->count) return true;
  
  if (total > c->result || pos >= c->count) return false;

  // attempt addition
  long long res = compute(total, c->arr[pos], ADD);
  if (calibration_is_valid(c, res, pos + 1)) return true;

  // attempt multiplication
  res = compute(total, c->arr[pos], MUL);
  if (calibration_is_valid(c, res, pos + 1)) return true;

  // attempt concatenation
  res = compute(total, c->arr[pos], CONC);
  if (calibration_is_valid(c, res, pos + 1)) return true;
  
  return false;
}

long long find_total_calibration(CalibrationList *cl) {
  long long total = 0;
  long long result;
  for (int i = 0; i < cl->count; i++) {
    result = ((Calibration*)cl->list[i])->arr[0];
    if (calibration_is_valid(cl->list[i], result, 1)) {
      total += ((Calibration*)cl->list[i])->result;
    }
  }

  return total;
}

int main(int argc, char **argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  cl = new_calibrationlist(5);

  yylex();

  long long total = find_total_calibration(cl);
  printf("Total: %lld\n", total);

  free_calibrationlist(cl);
}