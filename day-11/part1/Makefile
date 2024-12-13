CC = gcc
LEX = flex
CFLAGS = -I../include -fsanitize=address -fsanitize=undefined -static-libasan -g -lfl

BUILD_DIR = ../../build
TARGET_EXEC = d11p1

$(BUILD_DIR)/$(TARGET_EXEC): lex.yy.c main.c ../src/stone.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $?

lex.yy.c: ../parser/scan.l
	$(LEX) -o $*.c $<


clean:
	rm -f lex.yy.c