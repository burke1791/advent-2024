CC = gcc
LEX = flex
CFLAGS = -I../include -fsanitize=address -fsanitize=undefined -static-libasan -g -lfl

BUILD_DIR = ../../build
TARGET_EXEC = d8p2

$(BUILD_DIR)/$(TARGET_EXEC): lex.yy.c ../src/antenna.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $?

lex.yy.c: scan.l
	flex scan.l


clean:
	rm -f lex.yy.c