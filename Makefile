
TARGETS = d1p1 d1p2 d2p1 d2p2 d3p1 d3p2 d4p1 d4p2 d5p1 d5p2 d6p1 d6p2

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