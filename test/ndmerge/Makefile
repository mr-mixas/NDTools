BIN=ndmerge
VERB=-vvvv

.PHONY: always test clean

all: test clean

define COMPLEX_MERGE_01
$(BIN) $(VERB) \
	--file ../alpha.json \
	--file ../beta.json \
		--style L_OVERRIDE \
		--merge '{}' \
		--merge '{"fqdn"}' \
			--style 'R_OVERRIDE' \
		--merge '{"mtime"}' \
			--style 'R_OVERRIDE'
endef

test: \
	t_common \
	t_dump_prereqs \
	t_dump_rules \
	t_merge_embed_rules \
	t_ignore \
	t_load_rules \
	t_merge_loaded_rules \
	t_merge_args_files
	@echo === ALL $(BIN) TESTS PASSED ===

t_dump_prereqs: always
	$(BIN) $(VERB) --load-rules t_dump_rules.0010.exp --dump-prereqs $@.0000.got
	diff $@.0000.exp $@.0000.got

t_dump_rules: always
	# simple rules by opt
	$(BIN) $(VERB) --dump-rules $@.0000.got a.json b.json c.json
	diff $@.0000.exp $@.0000.got
	# complex rules by opts
	$(COMPLEX_MERGE_01) --dump-rules $@.0010.got
	diff $@.0010.exp $@.0010.got
	@echo === $@ PASS ===

t_ignore: always
	$(BIN) $(VERB) > $@.0000.got \
		--file ../alpha.json \
			--ignore '{"files"}{"/etc/resolv.conf"}'
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===

t_load_rules: always
	$(BIN) $(VERB) --load-rules t_dump_rules.0010.got --dump-rules $@.0000.got
	diff $@.0000.exp $@.0000.got
	diff t_dump_rules.0010.exp $@.0000.got # must be no changes in redump

t_merge_args_files: always
	$(BIN) $(VERB) ../alpha.json ../beta.json ../gamma.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(COMPLEX_MERGE_01) --dump-blame $@.0010.blame.got > $@.0010.got
	diff $@.0010.exp $@.0010.got
	diff $@.0010.blame.exp $@.0010.blame.got
	@echo === $@ PASS ===

t_merge_loaded_rules: always
	$(BIN) $(VERB) --dump-blame $@.0000.blame.got --load-rules t_dump_rules.0010.got > $@.0000.got
	diff $@.0000.exp $@.0000.got
	diff t_merge_args_files.0010.exp $@.0000.got # opts or rules - result must be the same
	diff $@.0000.blame.exp $@.0000.blame.got
	@echo === $@ PASS ===

t_merge_embed_rules: always
	$(BIN) $(VERB) --embed-rules '{__ndmerge__}{rules}' --load-rules t_dump_rules.0010.got > $@.0000.got
	diff $@.0000.exp $@.0000.got
	@echo === $@ PASS ===


include ../_common.mk
