BIN=nddiff
VERB=-vvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_brief \
	t_brief_colors \
	t_brief_lastpathitem \
	t_term \
	t_term_colors \
	t_term_full_headers \
	t_term_nopretty \
	t_term_arrays \
	t_term_bool \
	t_term_quiet \
	t_term_text \
	t_term_text_changed_seqs \
	t_term_text_utf8 \
	t_term_text_AR \
	t_ignore \
	t_json \
	t_json_nopretty \
	t_json_numbers \
	t_path \
	t_path_utf8 \
	t_show \
	t_show_brief \
	t_yaml
	@echo === ALL $(BIN) TESTS PASSED ===

include ../_common.mk

# redefine from common - diff requires two arguments
t_verbose: always
	$(BIN) -vv -v2 --verbose --verbose 3 ../alpha.json ../alpha.json >/dev/null 2>&1 #check aliases and args

t_brief:
	$(BIN) $(VERB) ../_data/menu.a.json ../_data/menu.b.json --brief > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_brief_colors:
	$(BIN) $(VERB) ../_data/bool.a.json ../_data/bool.b.json --brief --colors > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

# [5] here is added item, that's why empty STDOUT. But exit code must be 8 - diff exists after all
t_brief_lastpathitem:
	$(BIN) $(VERB) ../_data/menu.a.json ../_data/menu.b.json --path [1]{Edit}[5] --brief > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got # must be empty

t_show:
	$(BIN) $(VERB) --show t_show.diff.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_show_brief:
	$(BIN) $(VERB) --brief --show t_show.diff.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term:
	$(BIN) $(VERB) ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_colors:
	$(BIN) $(VERB) --colors ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_full_headers:
	$(BIN) $(VERB) ../alpha.json ../beta.json --full-headers > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_nopretty:
	$(BIN) $(VERB) --nopretty ../_data/menu.a.json ../_data/menu.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_arrays:
	$(BIN) $(VERB) ../_data/menu.a.json ../_data/menu.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) ../_data/menu.b.json ../_data/menu.a.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got

t_term_bool:
	$(BIN) $(VERB) --nopretty ../_data/bool.a.json ../_data/bool.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_quiet:
	$(BIN) $(VERB) --quiet ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_text:
	$(BIN) $(VERB) ../_data/deep-down-lorem.a.json ../_data/deep-down-lorem.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

# check that sequences of changed lines grouped by removed and added blocks
t_term_text_changed_seqs:
	$(BIN) $(VERB) ../_data/text-changed-seqs.a.json ../_data/text-changed-seqs.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_text_utf8:
	$(BIN) $(VERB) ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_text_AR:
	$(BIN) $(VERB) ../_data/text-AR.a.json ../_data/text-AR.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_ignore:
	$(BIN) $(VERB) --json --ignore 'unsupported_path_format' ../_data/menu.a.json ../_data/menu.b.json; $(VRFY_EXIT_1)
	$(BIN) $(VERB) --json --full --ignore "{some}[5]{text}[0]{buried}[1]{'deep down'}{in}[0]{'the structure'}" ../_data/deep-down-lorem.a.json ../_data/deep-down-lorem.b.json > $@.0000.got;
	diff $@.0000.exp $@.0000.got # diff part ignored (removed)
	$(BIN) $(VERB) --json --full --ignore '[1]{notexists}[5]' ../_data/menu.a.json ../_data/menu.b.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got # check we doesn't corrupt diff specifying unexisted parts to ignore

t_json:
	$(BIN) $(VERB) --json ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_json_nopretty:
	$(BIN) $(VERB) --nopretty --json ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_json_numbers:
	$(BIN) $(VERB) --json ../_data/numbers.a.json ../_data/numbers.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_path:
	$(BIN) $(VERB) --path '{files}' ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_path_utf8:
	$(BIN) $(VERB) --path '{"текст"}' ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_yaml:
	$(BIN) $(VERB) --out-fmt yaml ../alpha.json ../beta.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
