# tests, depends and so on..

CWD := $(shell pwd -P)
export PATH := $(CWD):$(PATH)
export PERL5LIB := $(CWD)

.PHONY: all clean depends test veryclean

all: depends test

clean:
	make -C test clean

depends:
	make -C $@

test:
	make -C test
	@echo ===== ALL TESTS PASSED =====

veryclean: clean
	make -C depends clean
