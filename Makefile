# tests, depends and so on..

CWD := $(shell pwd -P)
export PATH := $(CWD):$(PATH)
export PERL5LIB := $(CWD)

TOOLS = ndmerge

.PHONY: all clean depends test veryclean

all: depends test

clean:
	rm -rf tmp

depends:
	make -C $@

test:
	make -C test/ndmerge

veryclean: clean
	make -C depends clean
