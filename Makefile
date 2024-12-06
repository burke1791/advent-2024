
TARGETS = d1p1 d1p2 d2p1

all: $(TARGETS)

d1p1:
	cd day-01/part1 && $(MAKE)

d1p2:
	cd day-01/part2 && $(MAKE)

d2p1:
	cd day-02/part1 && $(MAKE)

d2p2:
	cd day-02/part2 && $(MAKE)


clean:
	rm -rf build
	cd day-01/part1 && $(MAKE) clean
	cd day-01/part2 && $(MAKE) clean
	cd day-02/part1 && $(MAKE) clean
	cd day-02/part2 && $(MAKE) clean