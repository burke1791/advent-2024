%define api.pure true
%parse-param { struct Spec **s }

%{

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#include "spec.h"

void yyerror(Spec **sp, char *s, ...);

%}

%union {
  int i;
  
  struct Spec *spec;
  struct Rule *rule;
  struct Update *update;
  struct List *list;
}

%token NEWLINE
%token <i> NUMBER

%type <rule> rule
%type <update> update
%type <spec> spec
%type <list> rule_list update_list
%type <i> page

%start result

%%

result: spec {
      *s = $1;
      YYACCEPT;
    }
  ;

spec: rule_list NEWLINE NEWLINE update_list   {
      Spec *s = malloc(sizeof(Spec));
      s->rules = $1;
      s->updates = $4;

      $$ = s;
    }
  ;

rule_list: rule {
      List *l = new_list(5, T_Rule);
      append_to_list(l, $1);

      $$ = l;
    }
  | rule_list NEWLINE rule {
      append_to_list($1, $3);
    }
  ;

rule: NUMBER '|' NUMBER {
    Rule *r = new_rule($1, $3);
    $$ = r;
  }

update_list: update {
      List *l = new_list(5, T_Update);
      append_to_list(l, $1);

      $$ = l;
    }
  | update_list NEWLINE update {
      append_to_list($1, $3);
    }
  ;

update: page {
      Update *u = new_update(5);
      append_page(u, $1);

      $$ = u;
    }
  | update ',' page {
      append_page($1, $3);
    }
  ;

page: NUMBER
  ;

%%

void yyerror(Spec **sp, char* s, ...) {
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "error: ");
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}