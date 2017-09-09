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
	t_m_Merge \
	t_m_Merge_dump_rules \
	t_m_Merge_ignore \
	t_m_Merge_implicit_source \
	t_m_Merge_implicit_array_item \
	t_m_Merge_merge \
	t_m_Merge_merge_path_not_exists_default \
	t_m_Merge_merge_path_not_exists_nostrict \
	t_m_Merge_merge_path_not_exists_strict \
	t_m_Merge_preserve \
	t_m_Merge_merge_style \
	t_m_Merge_multiargs \
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

t_m_Merge:
	cp ../alpha.json $@.0000.got
	# sequently merge three files
	$(BIN) $(VERB) --module Merge --source ../beta.json --source ../gamma.json $@.0000.got --dump-blame $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.exp $@.0010.got # blame

t_m_Merge_dump_rules:
	$(BIN) $(VERB) --module Merge --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --module Merge --path {common} --dump-rules $@.0010.got \
		--source ../beta.json --nostrict \
			--path {fqdn} --style L_OVERRIDE \
		--source ../gamma.json --style L_REPLACE \
			--path {mtime} --style "R_REPLACE" \
			--path {another} \
			--path {one_more} --nostrict
	diff $@.0010.exp $@.0010.got

t_m_Merge_ignore:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json --ignore "{files}{'/etc/hostname'}" $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Merge_implicit_source:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --rules $@.rules.json $@.0000.got --dump-blame $@.blame.got
	diff $@.0000.exp $@.0000.got
	diff $@.blame.exp $@.blame.got

t_m_Merge_implicit_array_item:
	cp ../_data/menu.a.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[1]{Edit}[]{id}(eq 'edit_replace')(<<)" $@.0000.got
	diff $@.0000.exp $@.0000.got
	cp ../_data/menu.a.json $@.0010.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[1]{/Edit/}[]{id}(eq 'edit_replace')(<<)" $@.0010.got
	diff $@.0010.exp $@.0010.got
	cp ../_data/menu.a.json $@.0020.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[1]{/Edit/}" $@.0020.got
	diff $@.0020.exp $@.0020.got
	cp ../_data/menu.a.json $@.0030.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[]{/Edit/}" $@.0030.got
	diff $@.0030.exp $@.0030.got
	cp ../_data/menu.a.json $@.0040.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[]{/Edit/}[]{id}(eq 'edit_replace')(<<)" $@.0040.got
	diff $@.0040.exp $@.0040.got
	echo '[]' > $@.0050.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[]{/Edit/}[]{id}(eq 'edit_replace')(<<)" $@.0050.got
	diff $@.0050.exp $@.0050.got
	cp ../_data/menu.a.json $@.0060.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[]{/Edit/}[]{id}(eq 'edit_replace')(<<)" $@.0060.got
	$(BIN) $(VERB) --module Merge --source ../_data/menu.b.json --path "[]{/Edit/}[]{id}(eq 'edit_replace')(<<)" $@.0060.got
	diff $@.0060.exp $@.0060.got # double merge mustn't corrupt result

t_m_Merge_merge:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json $@.0000.got \
		--merge "{files}" --merge "{mtime}"
	diff $@.0000.exp $@.0000.got

t_m_Merge_multiargs:
	cp ../alpha.json $@.0000.got
	cp ../beta.json $@.0010.got
	$(BIN) $(VERB) --module Merge --source ../gamma.json $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.exp $@.0010.got

t_m_Merge_merge_path_not_exists_default:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json --merge '{not_exists}' $@.0000.got; $(VRFY_EXIT_4)
	diff ../alpha.json $@.0000.got # must remain unchanged

t_m_Merge_merge_path_not_exists_strict:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --strict --source ../beta.json --merge '{not_exists}' $@.0000.got; $(VRFY_EXIT_4)
	diff ../alpha.json $@.0000.got # must remain unchanged

t_m_Merge_merge_path_not_exists_nostrict:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --strict --source ../beta.json --merge '{not_exists}' --nostrict --merge '{mtime}' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Merge_preserve:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json --style R_REPLACE --preserve "{fqdn}" $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Merge_merge_style:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json $@.0000.got \
		--merge "{files}" --style L_OVERRIDE \
		--merge "{mtime}"
	diff $@.0000.exp $@.0000.got

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
