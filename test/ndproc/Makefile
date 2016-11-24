BIN=ndproc
VERB=-vvvv

.PHONY: always test clean

all: test clean

include ../_common.mk

test: \
	t_common \
	t_list_modules
	@echo === ALL $(BIN) TESTS PASSED ===

t_list_modules:
	$(BIN) $(VERB) --list-modules -l > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_pod:
	@# bin itself doesn't contain pod
