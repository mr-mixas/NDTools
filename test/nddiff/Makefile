BIN=nddiff
VERB=-vvv

.PHONY: always test clean

all: test clean

test: \
	t_term_bool \
	t_term_quiet \
	t_term_text \
	t_term_text_changed_seqs \
	t_term_text_newlines \
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

t_show:
	$(BIN) $(VERB) --show t_show.diff.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_show_brief:
	$(BIN) $(VERB) --brief --show t_show.diff.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got


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

t_term_text_newlines:
	$(BIN) $(VERB) ../_data/text-newlines.a.json ../_data/text-newlines.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) ../_data/text-newlines.b.json ../_data/text-newlines.a.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) ../_data/text-newlines2.a.json ../_data/text-newlines2.b.json > $@.0020.got; $(VRFY_EXIT_8)
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) ../_data/text-newlines2.b.json ../_data/text-newlines2.a.json > $@.0030.got; $(VRFY_EXIT_8)
	diff $@.0030.exp $@.0030.got

t_term_text_utf8:
	$(BIN) $(VERB) ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got

t_term_text_AR:
	$(BIN) $(VERB) ../_data/text-AR.a.json ../_data/text-AR.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) ../_data/text-AR.b.json ../_data/text-AR.a.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got

t_term_text_ctx:
	$(BIN) $(VERB) --ctx-text 0 ../_data/text-changed-seqs.a.json ../_data/text-changed-seqs.b.json > $@.0000.got; $(VRFY_EXIT_8)
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --ctx-text 1 ../_data/text-changed-seqs.a.json ../_data/text-changed-seqs.b.json > $@.0010.got; $(VRFY_EXIT_8)
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) --ctx-text 2 ../_data/text-changed-seqs.a.json ../_data/text-changed-seqs.b.json > $@.0020.got; $(VRFY_EXIT_8)
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) --ctx-text 3 ../_data/text-changed-seqs.a.json ../_data/text-changed-seqs.b.json > $@.0030.got; $(VRFY_EXIT_8)
	diff $@.0030.exp $@.0030.got
	$(BIN) $(VERB) --ctx-text 0 ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0040.got; $(VRFY_EXIT_8)
	diff $@.0040.exp $@.0040.got
	$(BIN) $(VERB) --ctx-text 1 ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0050.got; $(VRFY_EXIT_8)
	diff $@.0050.exp $@.0050.got
	$(BIN) $(VERB) --ctx-text 2 ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0060.got; $(VRFY_EXIT_8)
	diff $@.0060.exp $@.0060.got
	$(BIN) $(VERB) --ctx-text 3 ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0070.got; $(VRFY_EXIT_8)
	diff $@.0070.exp $@.0070.got
	$(BIN) $(VERB) --ctx-text 9 ../_data/text-utf8.a.json ../_data/text-utf8.b.json > $@.0080.got; $(VRFY_EXIT_8)
	diff $@.0080.exp $@.0080.got
	$(BIN) $(VERB) --ctx-text 0 ../_data/deep-down-lorem.a.json ../_data/deep-down-lorem.b.json > $@.0090.got; $(VRFY_EXIT_8)
	diff $@.0090.exp $@.0090.got
	$(BIN) $(VERB) --ctx-text 0 ../_data/text-AR.a.json ../_data/text-AR.b.json > $@.0100.got; $(VRFY_EXIT_8)
	diff $@.0100.exp $@.0100.got
	$(BIN) $(VERB) --ctx-text 1 ../_data/text-AR.a.json ../_data/text-AR.b.json > $@.0110.got; $(VRFY_EXIT_8)
	diff $@.0110.exp $@.0110.got

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
