%{
  
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

typedef struct Report {
  int size;
  int count;
  int *levels;
} Report;

typedef struct ReportList {
  int size;
  int count;
  Report **reports;
} ReportList;

ReportList *rl;

Report *new_report(int size);
void append_report(ReportList *rl, Report *r);
void new_level(ReportList *rl, int num);

%}

%s REPORT

%%

<REPORT>[0-9]+    {
    int num = atoi(yytext);
    new_level(rl, num);
  }

[\r\n]  { BEGIN INITIAL; }

[0-9]+    {
    int num = atoi(yytext);
    Report *r = new_report(5);
    append_report(rl, r);
    new_level(rl, num);
    BEGIN REPORT;
  }

.   /* everything else - do nothing */

%%

Report *new_report(int size) {
  Report *r = malloc(sizeof(Report));
  r->size = size;
  r->count = 0;
  r->levels = malloc(size * sizeof(int));
  return r;
}

void free_report(Report *r) {
  free(r->levels);
  free(r);
}

ReportList *new_reportlist(int size) {
  ReportList *rl = malloc(sizeof(ReportList));
  rl->size = size;
  rl->count = 0;
  rl->reports = malloc(size * sizeof(ReportList));
  return rl;
}

void free_reportlist(ReportList *rl) {
  for (int i = 0; i < rl->count; i++) {
    free_report(rl->reports[i]);
  }
  free(rl->reports);
  free(rl);
}

void append_report(ReportList *rl, Report *r) {
  if (rl->count >= rl->size) {
    rl->size <<= 1;
    rl->reports = realloc(rl->reports, rl->size * sizeof(Report));
  }

  rl->reports[rl->count] = r;
  rl->count++;
}

// append the level to the last report
void new_level(ReportList *rl, int num) {
  Report *r = rl->reports[rl->count - 1];

  if (r->count >= r->size) {
    r->size <<= 1;
    r->levels = realloc(r->levels, r->size * sizeof(int));
  }

  r->levels[r->count] = num;
  r->count++;
}

bool analyze_level(int prev, int curr, int dir) {
  if (abs(curr - prev) > 3 || abs(curr - prev) < 1) return false;

  int newDir = 0;
  if ((curr - prev) > 0) {
    newDir = 1;
  } else {
    newDir = -1;
  }

  if (dir != 0 && dir != newDir) return false;

  return true;
}

bool analyze_report(Report *r, int tolerance) {
  int num;
  int prevNum;
  int direction = 0;
  int skipCount = 0;

  prevNum = r->levels[0];
  for (int i = 1; i < r->count; i++) {
    num = r->levels[i];

    if (!analyze_level(prevNum, num, direction)) {
      skipCount++;
    } else {
      if ((num - prevNum) > 0) {
        direction = 1;
      } else {
        direction = -1;
      }

      prevNum = num;
    }
  }

  return skipCount <= tolerance;
}

bool analyze_report_reverse(Report *r, int tolerance) {
  int num;
  int prevNum;
  int direction = 0;
  int skipCount = 0;

  prevNum = r->levels[r->count - 1];
  for (int i = r->count - 2; i >= 0; i--) {
    num = r->levels[i];

    if (!analyze_level(prevNum, num, direction)) {
      skipCount++;
    } else {
      if ((num - prevNum) > 0) {
        direction = 1;
      } else {
        direction = -1;
      }

      prevNum = num;
    }
  }

  return skipCount <= tolerance;
}

void print_report(Report *r) {
  for (int i = 0; i < r->count; i++) {
    printf("%d ", r->levels[i]);
  }
  printf("\n");
}

int count_safe_reports(ReportList *rl) {
  int numSafe = 0;

  for (int i = 0; i < rl->count; i++) {
    if (analyze_report(rl->reports[i], 1)) {
      numSafe++;
    } else if (analyze_report_reverse(rl->reports[i], 1)) {
      numSafe++;
    }
  }

  return numSafe;
}

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  rl = new_reportlist(5);

  yylex();

  printf("Num Reports: %d\n", rl->count);

  int safeReports = count_safe_reports(rl);

  printf("Safe: %d\n", safeReports);

  free_reportlist(rl);
}