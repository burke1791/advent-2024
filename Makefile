
TARGETS = d1p1 d1p2 d2p1 d2p2 d3p1 d3p2 d4p1 d4p2 d5p1 d5p2 d6p1 d6p2 d7p1 d7p2 d8p1 d8p2 d9p1 d9p2 d10p1 d10p2

all: $(TARGETS)

d1p1:
	cd day-01/part1 && $(MAKE)

d1p2:
	cd day-01/part2 && $(MAKE)

d2p1:
	cd day-02/part1 && $(MAKE)

d2p2:
	cd day-02/part2 && $(MAKE)

d3p1:
	cd day-03/part1 && $(MAKE)

d3p2:
	cd day-03/part2 && $(MAKE)

d4p1:
	cd day-04/part1 && $(MAKE)

d4p2:
	cd day-04/part2 && $(MAKE)

d5p1:
	cd day-05/part1 && $(MAKE)

d5p2:
	cd day-05/part2 && $(MAKE)

d6p1:
	cd day-06/part1 && $(MAKE)

d6p2:
	cd day-06/part2 && $(MAKE)

d7p1:
	cd day-07/part1 && $(MAKE)

d7p2:
	cd day-07/part2 && $(MAKE)

d8p1:
	cd day-08/part1 && $(MAKE)

d8p2:
	cd day-08/part2 && $(MAKE)

d9p1:
	cd day-09/part1 && $(MAKE)

d9p2:
	cd day-09/part2 && $(MAKE)

d10p1:
	cd day-10/part1 && $(MAKE)

d10p2:
	cd day-10/part2 && $(MAKE)


clean:
	rm -rf build
	cd day-01/part1 && $(MAKE) clean
	cd day-01/part2 && $(MAKE) clean
	cd day-02/part1 && $(MAKE) clean
	cd day-02/part2 && $(MAKE) clean
	cd day-03/part1 && $(MAKE) clean
	cd day-03/part2 && $(MAKE) clean
	cd day-04/part1 && $(MAKE) clean
	cd day-04/part2 && $(MAKE) clean
	cd day-05/part1 && $(MAKE) clean
	cd day-05/part2 && $(MAKE) clean
	cd day-06/part1 && $(MAKE) clean
	cd day-06/part2 && $(MAKE) clean
	cd day-07/part1 && $(MAKE) clean
	cd day-07/part2 && $(MAKE) clean
	cd day-08/part1 && $(MAKE) clean
	cd day-08/part2 && $(MAKE) clean
	cd day-09/part1 && $(MAKE) clean
	cd day-09/part2 && $(MAKE) clean
	cd day-10/part1 && $(MAKE) clean
	cd day-10/part2 && $(MAKE) clean