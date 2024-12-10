#include <stdlib.h>

#include "diskmap.h"

Block *new_block(BlockType type, int fileId, int size) {
  Block *b = malloc(sizeof(Block));
  b->type = type;
  b->fileId = fileId;
  b->size = size;
  return b;
}

void free_block(Block *b) {
  free(b);
}

DiskMap *new_diskmap(int size) {
  DiskMap *dm = malloc(sizeof(DiskMap));
  dm->size = size;
  dm->count = 0;
  dm->blocks = malloc(size * sizeof(Block));
  return dm;
}

void free_diskmap(DiskMap *dm) {
  for (int i = 0; i < dm->count; i++) {
    free_block(dm->blocks[i]);
  }
  free(dm->blocks);
  free(dm);
}

void set_block_file_id(DiskMap *dm, Block *b) {
  int maxFileId = -1;

  for (int i = 0; i < dm->count; i++) {
    if (dm->blocks[i]->fileId > maxFileId) maxFileId = dm->blocks[i]->fileId;
  }

  b->fileId = maxFileId + 1;
}

void append_block(DiskMap *dm, Block *b) {
  if (b->type == BT_FILE) {
    set_block_file_id(dm, b);
  }

  if (dm->count >= dm->size) {
    dm->size <<= 1;
    dm->blocks = realloc(dm->blocks, dm->size * sizeof(Block));
  }

  dm->blocks[dm->count] = b;
  dm->count++;
}