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
	t_m_Insert_help \
	t_m_Insert_nopath \
	t_m_Insert_file \
	t_m_Insert_value \
	t_m_Insert_value_multiargs \
	t_m_Merge \
	t_m_Merge_ignore \
	t_m_Merge_implicit_array_item \
	t_m_Merge_merge \
	t_m_Merge_merge_path_not_exists_default \
	t_m_Merge_merge_path_not_exists_nostrict \
	t_m_Merge_merge_path_not_exists_strict \
	t_m_Merge_merge_style \
	t_m_Merge_multiargs \
	t_m_Remove \
	t_m_Remove_dump_rules \
	t_m_Remove_help \
	t_m_Remove_multiargs \
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
	cp ../_data/bool.a.json $@.0000.got
	$(BIN) $(VERB) --module Insert --path '{some}[0..1]{path}' --path '{another}[1,0]{path}' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_help:
	$(BIN) --module Insert --help -h 2>$@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_nopath:
	cp ../_data/bool.a.json $@.0000.got
	$(BIN) $(VERB) --module Insert $@.0000.got
	diff ../_data/bool.a.json $@.0000.got # no path -- no insert =)

t_m_Insert_file:
	cp ../_data/bool.a.json $@.0000.got
	$(BIN) $(VERB) --module Insert --path '{some}[1]{path}' --file ../_data/text-utf8.a.json $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_value:
	cp ../_data/bool.a.json $@.0000.got
	$(BIN) $(VERB) --module Insert --path '{some}[1]{path}' --value 'string' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Insert_value_multiargs:
	cp ../_data/bool.a.json $@.0000.got
	cp ../_data/bool.b.json $@.0010.got
	$(BIN) $(VERB) --module Insert --path '{some}[1]{path}' --value 'string' $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.exp $@.0010.got

t_m_Merge:
	cp ../alpha.json $@.0000.got
	# sequently merge three files
	$(BIN) $(VERB) --module Merge --source ../beta.json --source ../gamma.json $@.0000.got --dump-blame $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.exp $@.0010.got # blame

t_m_Merge_ignore:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json --ignore "{files}{'/etc/hostname'}" $@.0000.got
	diff $@.0000.exp $@.0000.got

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

t_m_Merge_merge_style:
	cp ../alpha.json $@.0000.got
	$(BIN) $(VERB) --module Merge --source ../beta.json $@.0000.got \
		--merge "{files}" --style L_OVERRIDE \
		--merge "{mtime}"
	diff $@.0000.exp $@.0000.got

t_m_Remove:
	cp ../_data/deep-down-lorem.a.json $@.0000.got
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_dump_rules:
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove_help:
	$(BIN) --module Remove --help -h > $@.0000.got 2>&1
	diff $@.0000.exp $@.0000.got

t_m_Remove_multiargs:
	cp ../_data/menu.a.json $@.0000.got
	cp ../_data/menu.b.json $@.0010.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got
	diff $@.0010.got $@.0010.got

t_m_Remove__strict:
	cp ../_data/deep-down-lorem.a.json $@.0000.got
	$(BIN) $(VERB) --module Remove --path '{some}[1000]' --strict $@.0000.got; $(VRFY_EXIT_4)

t_m_Remove_version:
	$(BIN) --module Remove --version -V > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__dump_blame:
	cp ../_data/menu.a.json $@.0010.got
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' --dump-blame $@.0000.got $@.0010.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__unsupported_opt:
	$(BIN) --module Remove --unsupported-opt-test --path '[1]{Edit}[3..5]' ../_data/menu.a.json 2>/dev/null; $(VRFY_EXIT_1)

t_rules:
	cp ../_data/menu.a.json $@.0000.got
	$(BIN) $(VERB) --rules $@.rules.json $@.0000.got
	diff $@.0000.exp $@.0000.got

t_rules_redump:
	$(BIN) $(VERB) --rules $@.0000.exp --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got
