BIN=nddiff
VERB=-vvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_human \
	t_human_colors \
	t_human_full_headers \
	t_human_arrays \
	t_human_quiet \
	t_human_text \
	t_ignore \
	t_json \
	t_list_modules \
	t_path \
	t_yaml
	@echo === ALL $(BIN) TESTS PASSED ===

include ../_common.mk

# has pods in modules only
t_pod:
	true

# redefine from common - diff requires two arguments
t_verbose: always
	$(BIN) -vv -v2 --verbose --verbose 3 ../alpha.json ../alpha.json >/dev/null 2>&1 #check aliases and args

t_human:
	$(BIN) $(VERB) ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_human_colors:
	$(BIN) $(VERB) --colors ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_human_full_headers:
	$(BIN) $(VERB) ../alpha.json ../beta.json --full-headers > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_human_arrays:
	$(BIN) $(VERB) ../_data/menu.a.json ../_data/menu.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) ../_data/menu.b.json ../_data/menu.a.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got

t_human_quiet:
	$(BIN) $(VERB) --quiet ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_human_text:
	$(BIN) $(VERB) ../_data/deep-down-lorem.a.json ../_data/deep-down-lorem.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_ignore:
	$(BIN) $(VERB) --json --ignore 'unsupported_path_format' ../_data/menu.a.json ../_data/menu.b.json; $(VRFY_EXIT_1)
	$(BIN) $(VERB) --json --ignore '[1]{Edit}[5]' ../_data/menu.a.json ../_data/menu.b.json > $@.0000.got;
	diff $@.0000.exp $@.0000.got # diff part ignored (removed)
	$(BIN) $(VERB) --json --ignore '[1]{notexists}[5]' ../_data/menu.a.json ../_data/menu.b.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got # check we doesn't corrupt diff specifying unexisted parts to ignore

t_json:
	$(BIN) $(VERB) --json ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_list_modules:
	$(BIN) $(VERB) --list-modules -l > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_path:
	$(BIN) $(VERB) --path '{files}' ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_yaml:
	$(BIN) $(VERB) --out-fmt yaml ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===
