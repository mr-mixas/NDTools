.PHONY: all clean test

all: test

clean:
	make -C nddiff  clean
	make -C ndproc clean
	make -C ndquery clean

test:
	make -C nddiff
	make -C ndproc
	make -C ndquery
