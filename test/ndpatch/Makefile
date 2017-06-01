BIN=ndpatch
VERB=-vvvv

.PHONY: always test clean

all: test clean

include ../_common.mk

test: \
	t_patch \
	t_patch__STDIN
	@echo === ALL $(BIN) TESTS PASSED ===

t_patch:
	cp ../_data/menu.a.json $@.0000.got
	$(BIN) $(VERB) $@.0000.got $@.0000.patch
	diff ../_data/menu.b.json $@.0000.got

t_patch__STDIN:
	cp ../_data/menu.b.json $@.0000.got
	cat $@.0000.patch | $(BIN) $(VERB) $@.0000.got
	diff ../_data/menu.a.json $@.0000.got

