#ifndef DISKMAP_H
#define DISKMAP_H

typedef enum BlockType {
  BT_FILE,
  BT_FREE
} BlockType;

typedef struct Block {
  BlockType type;
  int fileId;
} Block;

typedef struct Filesystem {
  int size;
  int count;
  Block **blocks;
} Filesystem;

typedef struct DiskMapItem {
  BlockType type;
  int size;
  int fileId;
} DiskMapItem;

typedef struct DiskMap {
  int size;
  int count;
  DiskMapItem **items;
} DiskMap;

typedef struct Disk {
  DiskMap *dm;
  Filesystem *fs;
} Disk;

Block *new_block(BlockType type, int fileId);
void free_block(Block *b);

DiskMapItem *new_diskmapitem(BlockType type, int size, int fileId);
void free_diskmapitem(DiskMapItem *dmi);

DiskMap *new_diskmap(int size);
void free_diskmap(DiskMap *dm);

Disk *new_disk();
void free_disk(Disk *d);

void append_diskmapitem(DiskMap *dm, DiskMapItem *dmi);

void construct_filesystem(Disk *d);
void compact_filesystem(Filesystem *fs);
void compact_diskmap(DiskMap *dm);
long compute_checksum(Filesystem *fs);

void print_filesystem(Filesystem *fs);

#endif /* DISKMAP_H */