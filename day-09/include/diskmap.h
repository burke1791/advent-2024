#ifndef DISKMAP_H
#define DISKMAP_H

typedef enum BlockType {
  BT_FILE,
  BT_FREE
} BlockType;

typedef struct Block {
  BlockType type;
  int fileId;
  int size;
} Block;

typedef struct DiskMap {
  int size;
  int count;
  Block **blocks;
} DiskMap;

Block *new_block(BlockType type, int fileId, int size);
void free_block(Block *b);

DiskMap *new_diskmap(int size);
void free_diskmap(DiskMap *dm);

void append_block(DiskMap *dm, Block *b);

#endif /* DISKMAP_H */