BIN=ndproc
VERB=-vvvv

.PHONY: always test clean

all: test clean

include ../_common.mk

test: \
	t_common \
	t_list_modules \
	t_rules \
	t_rules_redump \
	t_m__UNKNOWN_via_args \
	t_m__UNKNOWN_via_rules \
	t_m_Insert \
	t_m_Insert_nopath \
	t_m_Insert_file \
	t_m_Insert_value \
	t_m_Remove \
	t_m_Remove_dump_rules \
	t_m_Remove_help \
	t_m_Remove__strict \
	t_m_Remove_version \
	t_m_Remove__dump_blame \
	t_m_Remove__unsupported_opt
	@echo === ALL $(BIN) TESTS PASSED ===

t_list_modules:
	$(BIN) $(VERB) --list-modules -l > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m__UNKNOWN_via_args:
	$(BIN) $(VERB) --module NoTeXiStEd; $(VRFY_EXIT_1)

t_m__UNKNOWN_via_rules:
	$(BIN) $(VERB) --rules $@.rules.json ../_data/menu.a.json; $(VRFY_EXIT_1)

t_m_Insert:
	$(BIN) $(VERB) --module Insert --path '{some}[0..1]{path}' --path '{another}[1,0]{path}' ../_data/bool.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_nopath:
	$(BIN) $(VERB) --module Insert ../_data/bool.a.json > $@.0000.got
	diff ../_data/bool.a.json $@.0000.got # no path -- no insert =)

t_m_Insert_file:
	$(BIN) $(VERB) --module Insert --path '{some}[1]{path}' --file ../_data/text-utf8.a.json ../_data/bool.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_value:
	$(BIN) $(VERB) --module Insert --path '{some}[1]{path}' --value 'string' ../_data/bool.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove:
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' ../_data/deep-down-lorem.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_dump_rules:
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_help:
	$(BIN) --module Remove --help -h > $@.0000.got 2>&1
	diff $@.0000.exp $@.0000.got

t_m_Remove__strict:
	$(BIN) $(VERB) --module Remove --path '{some}[1000]' --strict ../_data/deep-down-lorem.a.json; $(VRFY_EXIT_4)

t_m_Remove_version:
	$(BIN) --module Remove --version -V > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__dump_blame:
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' ../_data/menu.a.json --dump-blame $@.0000.got >/dev/null
	diff $@.0000.exp $@.0000.got

t_m_Remove__unsupported_opt:
	$(BIN) --module Remove --unsupported-opt-test --path '[1]{Edit}[3..5]' ../_data/menu.a.json 2>/dev/null; $(VRFY_EXIT_1)

t_rules:
	$(BIN) $(VERB) --rules $@.rules.json ../_data/menu.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_rules_redump:
	$(BIN) $(VERB) --rules $@.0000.exp --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got
