#include <stdlib.h>
#include <stdio.h>

#include "diskmap.h"

Block *new_block(BlockType type, int fileId) {
  Block *b = malloc(sizeof(Block));
  b->type = type;
  b->fileId = fileId;
  return b;
}

void free_block(Block *b) {
  free(b);
}

Filesystem *new_filesystem(int size) {
  Filesystem *fs = malloc(sizeof(Filesystem));
  fs->size = size;
  fs->count = 0;
  fs->blocks = malloc(size * sizeof(Block));
  return fs;
}

void free_filesystem(Filesystem *fs) {
  for (int i = 0; i < fs->count; i++) {
    free_block(fs->blocks[i]);
  }
  free(fs->blocks);
  free(fs);
}

void append_block(Filesystem *fs, Block *b) {
  if (fs->count >= fs->size) {
    fs->size <<= 1;
    fs->blocks = realloc(fs->blocks, fs->size * sizeof(Block));
  }

  fs->blocks[fs->count] = b;
  fs->count++;
}

DiskMapItem *new_diskmapitem(BlockType type, int size, int fileId) {
  DiskMapItem *dmi = malloc(sizeof(DiskMapItem));
  dmi->type = type;
  dmi->size = size;
  dmi->fileId = fileId;
  return dmi;
}

void free_diskmapitem(DiskMapItem *dmi) {
  free(dmi);
}

DiskMap *new_diskmap(int size) {
  DiskMap *dm = malloc(sizeof(DiskMap));
  dm->size = size;
  dm->count = 0;
  dm->items = malloc(size * sizeof(DiskMapItem));
  return dm;
}

void free_diskmap(DiskMap *dm) {
  for (int i = 0; i < dm->count; i++) {
    free_diskmapitem(dm->items[i]);
  }
  free(dm->items);
  free(dm);
}

Disk *new_disk() {
  Disk *d = malloc(sizeof(Disk));
  d->dm = NULL;   // will be created by the bison parser
  d->fs = new_filesystem(5);
  return d;
}

void free_disk(Disk *d) {
  free_diskmap(d->dm);
  free_filesystem(d->fs);
  free(d);
}

void set_diskmapitem_file_id(DiskMap *dm, DiskMapItem *dmi) {
  int maxFileId = -1;

  for (int i = 0; i < dm->count; i++) {
    if (dm->items[i]->fileId > maxFileId) maxFileId = dm->items[i]->fileId;
  }

  dmi->fileId = maxFileId + 1;
}

void append_diskmapitem(DiskMap *dm, DiskMapItem *dmi) {
  if (dmi->type == BT_FILE) {
    set_diskmapitem_file_id(dm, dmi);
  }

  if (dm->count >= dm->size) {
    dm->size <<= 1;
    dm->items = realloc(dm->items, dm->size * sizeof(DiskMapItem));
  }

  dm->items[dm->count] = dmi;
  dm->count++;
}

void print_block(Block *b) {
  switch (b->type) {
    case BT_FILE:
      printf("%d", b->fileId);
      break;
    case BT_FREE:
      printf(".");
      break;
  }
}

void print_filesystem(Filesystem *fs) {
  for (int i = 0; i < fs->count; i++) {
    print_block(fs->blocks[i]);
  }
  printf("\n");
}

void construct_filesystem(Disk *d) {
  DiskMap *dm = d->dm;
  Filesystem *fs = d->fs;

  for (int i = 0; i < dm->count; i++) {
    for (int j = 0; j < dm->items[i]->size; j++) {
      Block *b;
      switch (dm->items[i]->type) {
        case BT_FILE:
          b = new_block(BT_FILE, dm->items[i]->fileId);
          break;
        case BT_FREE:
          b = new_block(BT_FREE, -1);
          break;
      }
      append_block(fs, b);
    }
  }
}

void swap_blocks(Block **b1, Block **b2) {
  Block *tmp = *b2;
  *b2 = *b1;
  *b1 = tmp;
}

void compact_filesystem(Filesystem *fs) {
  for (int i = 0; i < fs->count; i++) {
    if (fs->blocks[i]->type == BT_FREE) {
      for (int j = fs->count - 1; j > i; j--) {
        if (fs->blocks[j]->type == BT_FILE) {
          swap_blocks(&fs->blocks[i], &fs->blocks[j]);
          break;
        }
      }
    }
  }
}

void move_diskmapitem(DiskMap *dm, int from, int to) {
  if (from <= to) printf("WHY IS FROM <= TO???\n");

  DiskMapItem *tmp = dm->items[from];
  // shuffle items down one position
  for (int i = from - 1; i >= to; i--) {
    dm->items[i + 1] = dm->items[i];
  }
  dm->items[to] = tmp;

  // squash the freespace block by the size of the file block
  dm->items[to + 1]->size -= tmp->size;

  // expand the freespace block next to the file we just moved
  dm->items[from]->size += tmp->size;
}

void compact_diskmap(DiskMap *dm) {
  for (int j = dm->count - 1; j > 0; j--) {
    if (dm->items[j]->type == BT_FILE) {
      for (int i = 0; i < j; i++) {
        if (dm->items[i]->type == BT_FREE && dm->items[i]->size >= dm->items[j]->size) {
          move_diskmapitem(dm, j, i);
          break;
        }
      }
    }
  }
}

long compute_checksum(Filesystem *fs) {
  long checksum = 0;
  for (int i = 0; i < fs->count; i++) {
    if (fs->blocks[i]->type == BT_FILE) {
      checksum += (i * fs->blocks[i]->fileId);
    }
  }

  return checksum;
}