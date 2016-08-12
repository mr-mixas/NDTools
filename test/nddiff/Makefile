BIN=nddiff
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_common
	@echo === ALL $(BIN) TESTS PASSED ===

include ../_common.mk

# redefine from common - diff requires two arguments
t_verbose: always
	$(BIN) -vv -v2 --verbose --verbose 3 ../alpha.json ../alpha.json >/dev/null 2>&1 #check aliases and args


