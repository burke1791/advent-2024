LEX = flex
YACC = bison
CC = gcc

CFLAGS = -I../include -fsanitize=address -fsanitize=undefined -static-libasan -g

BUILD_DIR = ../../build
TARGET_EXEC = d9p1

$(BUILD_DIR)/$(TARGET_EXEC): lex.yy.o gram.tab.o main.c ../src/diskmap.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $?

gram.tab.h gram.tab.c: ../parser/gram.y
	$(YACC) -vd $?

lex.yy.c: ../parser/scan.l
	$(LEX) -o $*.c $<

lex.yy.o: gram.tab.h lex.yy.c


clean:
	rm -f $(wildcard *.tab.*)
	rm -f $(wildcard *.o)
	rm -f lex.yy.c
	rm -f scan.lex.h
	rm -f $(wildcard *.output)