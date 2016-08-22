# tests, depends and so on..

CWD := $(shell pwd -P)
export PATH := $(CWD):$(PATH)
export PERL5LIB := $(CWD)

.PHONY: all clean depends dist test veryclean

all: dist

clean:
	make -C test clean
	make -C dist veryclean

depends:
	make -C $@

dist:
	make -C dist deb

test: depends
	make -C test
	@echo ===== ALL TESTS PASSED =====

veryclean: clean
	make -C depends clean
	make -C dist veryclean
