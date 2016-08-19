BIN=ndquery
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_default \
	t_list \
	t_out_fmt \
	t_path
	@echo === ALL $(BIN) TESTS PASSED ===

t_default:
	$(BIN) $(VERB) ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_list:
	$(BIN) $(VERB) --list ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --list --depth 1 ../alpha.json > $@.0010.got
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) --path '{files}' --list ../alpha.json > $@.0020.got
	diff $@.0020.exp $@.0020.got

t_out_fmt:
	$(BIN) $(VERB) --out-fmt yaml ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_path:
	$(BIN) $(VERB) --path '{files}{"/etc/hosts"}' ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

include ../_common.mk
