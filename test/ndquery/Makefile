BIN=ndquery
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_default \
	t_path
	@echo === ALL $(BIN) TESTS PASSED ===

t_default:
	$(BIN) $(VERB) ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_path:
	$(BIN) $(VERB) --path '{files}{"/etc/hosts"}' ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

include ../_common.mk
