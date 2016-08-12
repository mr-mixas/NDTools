.PHONY: all clean test

all: test

clean:
	make -C nddiff  clean
	make -C ndmerge clean
	make -C ndquery clean

test:
	make -C nddiff
	make -C ndmerge
	make -C ndquery
