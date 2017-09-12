BIN=ndproc
VERB=-vvvv

.PHONY: always test clean

all: test clean

include ../_common.mk

test: \
	t_disable_module \
	t_rules_builtin_format \
	t_rules_embed \
	t_m__UNKNOWN_via_rules \
	t_m_Remove_dump_rules \
	t_m_Remove_multiargs \
	t_m_Remove__dump_blame \
	t_m_Remove__embed_blame \
	t_m_Remove__noblame \
	t_m_Remove__unsupported_opt \
	t_m_Remove__STDIN_STDOUT
	@echo === ALL $(BIN) TESTS PASSED ===

t_rules_builtin_format:
	cp $@.struct.exp $@.0000.got
	$(BIN) $(VERB) --builtin-format JSON --builtin-rules '[3]{builtin}{rules}' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_disable_module:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --rules $@.rules.json --disable-module Insert $@.0000.got
	diff $@.0000.exp $@.0000.got
	cp ../alpha.json $@.0010.got
	$(BIN) $(VERB) --rules $@.rules.json --disable-module Remove $@.0010.got
	diff $@.0010.exp $@.0010.got
	cp ../alpha.json $@.0020.got
	$(BIN) $(VERB) --rules $@.rules.json --disable-module Insert --disable-module Remove $@.0020.got
	diff ../alpha.json $@.0020.got

t_m__UNKNOWN_via_rules:
	$(BIN) $(VERB) --rules $@.rules.json ../_data/menu.a.json; $(VRFY_EXIT_1)

t_m_Pipe:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Pipe --path '{files}' --cmd 'sed "s/1/42/g"' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_dump_rules:
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_multiargs:
	cp ../_data/menu.a.json $@.0000.got
	cp ../_data/menu.b.json $@.0010.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.got $@.0010.got

t_m_Remove__dump_blame:
	cp ../_data/menu.a.json $@.0010.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' --dump-blame $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__embed_blame:
	cp ../_data/menu.a.json $@.0000.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' --embed-blame '[1]{Edit}[3]{_blame_}' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__noblame:
	cp ../_data/menu.a.json $@.0010.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' --noblame --dump-blame $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__unsupported_opt:
	$(BIN) --module Remove --unsupported-opt-test --path '[1]{Edit}[3..5]' ../_data/menu.a.json 2>/dev/null; $(VRFY_EXIT_1)

t_m_Remove__STDIN_STDOUT:
	cat ../alpha.json | $(BIN) $(VERB) --module Remove --path '{files}' - > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_rules_embed:
	cp ../_data/menu.a.json $@.0000.got
	$(BIN) $(VERB) --rules $@.rules.json --embed-rules '[3]{builtin}{rules}' $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --builtin-rules '[3]{builtin}{rules}' $@.0000.got --dump-rules $@.0010.got
	diff $@.rules.json $@.0010.got
