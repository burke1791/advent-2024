%{

#include <string.h>
#include <stdbool.h>

typedef struct Coord {
  int x;
  int y;
} Coord;

typedef struct CoordList {
  int size;
  int count;
  Coord **coords;
} CoordList;

typedef enum GuardDirection {
  NORTH,
  EAST,
  SOUTH,
  WEST
} GuardDirection;

typedef enum GuardStatus {
  MARCHING,
  INFINITE,
  GONE
} GuardStatus;

typedef struct Guard {
  GuardDirection dir;
  GuardStatus status;
  Coord *pos;
} Guard;

/**
 * Grid values are as follows:
 *  0: walkway
 *  1: obstacle
 *  9: unknown
 */
typedef struct Row {
  int size;
  int count;
  int *arr;
} Row;

typedef struct Grid {
  Guard *guard;
  int size;
  int count;
  Row **rows;
} Grid;

Grid *g;

void new_pos(Grid *g, char *l);
void append_row(Grid *g, Row *r);
Row *new_row(int size);

%}

%s ROW

%%

<ROW>[.#<>\^v]   {
    new_pos(g, yytext);
  }

[.#<>\^v]   {
    Row *r = new_row(5);
    append_row(g, r);
    new_pos(g, yytext);
    BEGIN ROW;
  }

[\r\n]  { BEGIN INITIAL; }

.   /* everything else - do nothing */

%%

Coord *new_coord(int x, int y) {
  Coord *c = malloc(sizeof(Coord));
  c->x = x;
  c->y = y;
  return c;
}

void free_coord(Coord *c) {
  free(c);
}

Row *new_row(int size) {
  Row *r = malloc(sizeof(Row));
  r->size = size;
  r->count = 0;
  r->arr = malloc(size * sizeof(int));
  return r;
}

void free_row(Row *r) {
  free(r->arr);
  free(r);
}

Grid *new_grid(int size) {
  Grid *g = malloc(sizeof(Grid));
  g->guard = malloc(sizeof(Guard));
  g->guard->pos = NULL;
  g->guard->status = MARCHING;
  g->size = size;
  g->count = 0;
  g->rows = malloc(size * sizeof(Row));
  return g;
}

void free_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    free_row(g->rows[i]);
  }
  free_coord(g->guard->pos);
  free(g->guard);
  free(g->rows);
  free(g);
}

void append_row(Grid *g, Row *r) {
  if (g->count >= g->size) {
    g->size <<= 1;
    g->rows = realloc(g->rows, g->size * sizeof(Row));
  }

  g->rows[g->count] = r;
  g->count++;
}

void append_pos(Row *r, int val) {
  if (r->count >= r->size) {
    r->size <<= 1;
    r->arr = realloc(r->arr, r->size * sizeof(int));
  }

  r->arr[r->count] = val;
  r->count++;
}

void set_guard_pos(Grid *g, int x, int y, GuardDirection dir) {
  if (g->guard->pos == NULL) {
    g->guard->pos = new_coord(x, y);
  } else {
    g->guard->pos->x = x;
    g->guard->pos->y = y;
  }

  g->guard->dir = dir;
}

void new_pos(Grid *g, char *l) {
  Row *r = g->rows[g->count - 1];
  if (strcmp(l, ".") == 0) {
    append_pos(r, 0);
  } else if (strcmp(l, "#") == 0) {
    append_pos(r, 1);
  } else if (strcmp(l, "^") == 0) {
    append_pos(r, 0);
    set_guard_pos(g, r->count - 1, g->count - 1, NORTH);
  } else if (strcmp(l, ">") == 0) {
    append_pos(r, 0);
    set_guard_pos(g, r->count - 1, g->count - 1, EAST);
  } else if (strcmp(l, "v") == 0) {
    append_pos(r, 0);
    set_guard_pos(g, r->count - 1, g->count - 1, SOUTH);
  } else if (strcmp(l, "<") == 0) {
    append_pos(r, 0);
    set_guard_pos(g, r->count - 1, g->count - 1, WEST);
  } else {
    append_pos(r, 9);
  }
}

CoordList *new_coordlist(int size) {
  CoordList *cl = malloc(sizeof(CoordList));
  cl->size = size;
  cl->count = 0;
  cl->coords = malloc(size * sizeof(Coord));
  return cl;
}

void free_coordlist(CoordList *cl) {
  for (int i = 0; i < cl->count; i++) {
    free_coord(cl->coords[i]);
  }

  free(cl->coords);
  free(cl);
}

void append_coord(CoordList *cl, Coord *c) {
  if (cl->count >= cl->size) {
    cl->size <<= 1;
    cl->coords = realloc(cl->coords, cl->size * sizeof(Coord));
  }

  cl->coords[cl->count] = c;
  cl->count++;
}

void print_grid(Grid *g) {
  for (int i = 0; i < g->count; i++) {
    Row *r = g->rows[i];
    for (int j = 0; j < r->count; j++) {
      if (g->guard->pos->x == j && g->guard->pos->y == i) {
        printf(" ");
      } else {
        switch (r->arr[j]) {
          case 0:
            printf(".");
            break;
          case 1:
            printf("#");
            break;
          case 2:
            printf("^");
            break;
          case 3:
            printf(">");
            break;
          case 4:
            printf("v");
            break;
          case 5:
            printf("<");
            break;
          case 8:
            printf(" ");
            break;
          default:
            printf("*");
        }
      }
    }
    printf("\n");
  }
}

Guard *get_guard(Grid *g) {
  for (int j = 0; j < g->count; j++) {
    for (int i = 0; i < g->rows[0]->count; i++) {
      int val = g->rows[j]->arr[i];
      if (val >= 2 && val <= 5) {
        Guard *guard = malloc(sizeof(Guard));
        guard->pos = new_coord(i, j);

        switch (val) {
          case 2:
            guard->dir = NORTH;
            break;
          case 3:
            guard->dir = EAST;
            break;
          case 4:
            guard->dir = SOUTH;
            break;
          case 5:
            guard->dir = WEST;
            break;
        }
        
        return guard;
      }
    }
  }
}

void advance_north(Grid *g) {
  if (g->guard->pos->y == 0) {
    g->guard->status = GONE;
    return;
  }

  // if the next pos is an obstacle, turn east. Otherwise advance and add the new coord to the list
  if (g->rows[g->guard->pos->y - 1]->arr[g->guard->pos->x] == 1) {
    g->guard->dir = EAST;
  } else {
    g->guard->pos->y--;
  }
}

void advance_east(Grid *g) {
  int maxCol = g->rows[0]->count - 1;
  if (g->guard->pos->x == maxCol) {
    g->guard->status = GONE;
    return;
  }

  // if the next pos is an obstacle, turn east. Otherwise advance and add the new coord to the list
  if (g->rows[g->guard->pos->y]->arr[g->guard->pos->x + 1] == 1) {
    g->guard->dir = SOUTH;
  } else {
    g->guard->pos->x++;
  }
}

void advance_south(Grid *g) {
  int maxRow = g->count - 1;
  if (g->guard->pos->y == maxRow) {
    g->guard->status = GONE;
    return;
  }

  // if the next pos is an obstacle, turn east. Otherwise advance and add the new coord to the list
  if (g->rows[g->guard->pos->y + 1]->arr[g->guard->pos->x] == 1) {
    g->guard->dir = WEST;
  } else {
    g->guard->pos->y++;
  }
}

void advance_west(Grid *g) {
  if (g->guard->pos->x == 0) {
    g->guard->status = GONE;
    return;
  }

  // if the next pos is an obstacle, turn east. Otherwise advance and add the new coord to the list
  if (g->rows[g->guard->pos->y]->arr[g->guard->pos->x - 1] == 1) {
    g->guard->dir = NORTH;
  } else {
    g->guard->pos->x--;
  }
}

/* advances the guard one position in the direction she's facing, or rotates the guard clockwise 90 degrees if she can't move */
void patrol_march(Grid *g, Guard *start) {
  switch (g->guard->dir) {
    case NORTH:
      advance_north(g);
      break;
    case EAST:
      advance_east(g);
      break;
    case SOUTH:
      advance_south(g);
      break;
    case WEST:
      advance_west(g);
      break;
  }

  // check if the guard is back at her starting position and direction
  Guard *guard = g->guard;
  if (guard->pos->x == start->pos->x && guard->pos->y == start->pos->y && guard->dir == start->dir) {
    guard->status = INFINITE;
  }
}

bool patrol(Grid *g, Guard *start) {
  int loopCount = 0;
  int maxLoops = 10000;

  while (loopCount < maxLoops && g->guard->status == MARCHING) {
    patrol_march(g, start);

    loopCount++;
  }

  if (loopCount >= maxLoops) {
    printf("Loops: %d\n", loopCount);
  }

  return g->guard->status == INFINITE;
}

void place_obstacle(Grid *g, int x, int y) {
  g->rows[y]->arr[x] = 1;
}

void remove_obstacle(Grid *g, int x, int y) {
  g->rows[y]->arr[x] = 0;
}

int find_infinite_loops(Grid *g) {
  int infLoopCount = 0;
  Guard *guardStart = malloc(sizeof(Guard));
  guardStart->dir = g->guard->dir;
  guardStart->pos = new_coord(g->guard->pos->x, g->guard->pos->y);

  for (int y = 0; y < g->count; y++) {
    for (int x = 0; x < g->rows[y]->count; x++) {
      if (g->rows[y]->arr[x] != 1 && g->guard->pos->x != x && g->guard->pos->y != y) {
        place_obstacle(g, x, y);

        if (patrol(g)) infLoopCount++;

        remove_obstacle(g, x, y);
      }
    }
  }

  free_coord(guardStart->pos);
  free(guardStart);

  return infLoopCount;
}

int main(int argc, char** argv) {
  if (!(yyin = fopen(argv[1], "r"))) {
    perror(argv[1]);
    exit(EXIT_FAILURE);
  }

  g = new_grid(5);

  yylex();

  /* print_grid(g); */
  int infLoopCount = find_infinite_loops(g);
  /* print_grid(g); */

  printf("Infinite loops: %d\n", infLoopCount);

  free_coordlist(cl);
  free_grid(g);
}