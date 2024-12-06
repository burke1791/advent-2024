%{

#include <stdlib.h>
#include <stdio.h>

typedef struct NumArray {
  int size;
  int count;
  int *arr;
} NumArray;

NumArray* left;
NumArray* right;

void append_array(NumArray *arr, int num);

%}

%s RIGHT

%%

<RIGHT>[0-9]+   {
    int num = atoi(yytext);
    append_array(right, num);
  }

[\r\n]    { BEGIN INITIAL; }

[0-9]+    {
    int num = atoi(yytext);
    append_array(left, num);
    BEGIN RIGHT;
  }

.   /* everything else - do nothing */

%%

NumArray *new_array(int size) {
  NumArray *arr = malloc(sizeof(NumArray));
  arr->arr = malloc(size * sizeof(int));
  arr->size = size;
  arr->count = 0;

  return arr;
}

void free_array(NumArray *arr) {
  free(arr->arr);
  free(arr);
}

void append_array(NumArray *arr, int num) {
  if (arr->count >= arr->size) {
    arr->size <<= 1;
    arr->arr = realloc(arr->arr, arr->size * sizeof(int));
  }

  arr->arr[arr->count] = num;
  arr->count++;
}

int compare(const void *a, const void *b) {
  int int_a = *((int*)a);
  int int_b = *((int*)b);

  return int_a - int_b;
}

int compute_distance(NumArray *left, NumArray *right) {
  int total = 0;

  for (int i = 0; i < left->count; i++) {
    total += abs(left->arr[i] - right->arr[i]);
  }

  return total;
}

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  left = new_array(5);
  right = new_array(5);

  yylex();

  qsort(left->arr, left->count, sizeof(int), compare);
  qsort(right->arr, right->count, sizeof(int), compare);

  int total = compute_distance(left, right);

  printf("total: %d\n", total);

  free_array(left);
  free_array(right);
}