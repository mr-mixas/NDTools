BIN=nddiff
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_diff_human \
	t_diff_human_full_headers \
	t_diff_json \
	t_diff_yaml
	@echo === ALL $(BIN) TESTS PASSED ===

include ../_common.mk

# redefine from common - diff requires two arguments
t_verbose: always
	$(BIN) -vv -v2 --verbose --verbose 3 ../alpha.json ../alpha.json >/dev/null 2>&1 #check aliases and args

t_diff_human:
	$(BIN) $(VERB) ../alpha.json ../beta.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_diff_human_full_headers:
	$(BIN) $(VERB) ../alpha.json ../beta.json --full-headers > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_diff_json:
	$(BIN) $(VERB) --out-fmt json ../alpha.json ../beta.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_diff_yaml:
	$(BIN) $(VERB) --out-fmt yaml ../alpha.json ../beta.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===
