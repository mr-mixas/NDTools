VERBOSE=-vvvv

.PHONY: always test clean

all: test clean

clean:
	rm *.got

test: \
	t_dump_rules \
	t_ignore \
	t_merge_args_files
	@echo === ALL NDMERGE TESTS PASSED ===

t_dump_rules: always
	# simple rules by opt
	ndmerge $(VERBOSE) --dump-rules -- a.json b.json c.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	# complex rules by opts
	ndmerge $(VERBOSE) > $@.0010.got \
		--dump-rules \
		--file a.json \
			--ignore '{a}[0]{b}' \
		--file b.json \
			--style L_OVERRIDE \
			--merge '{}' \
			--merge '[1]{}' --style R_OVERRIDE \
		--file c.json \
			--style L_OVERRIDE
	diff $@.0010.exp $@.0010.got
	@echo === $@ PASS ===

t_ignore:
	ndmerge $(VERBOSE) > $@.0000.got \
		--file ../alpha.json \
			--ignore '{"files"}{"/etc/resolv.conf"}'
	diff $@.0000.exp $@.0000.got

t_merge_args_files: always
	ndmerge $(VERBOSE) ../alpha.json ../beta.json ../gamma.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	ndmerge $(VERBOSE) --dump-blame $@.0010.blame.got > $@.0010.got \
		--file ../alpha.json \
		--file ../beta.json \
			--style L_OVERRIDE \
			--merge '{}' \
			--merge '{"fqdn"}' \
				--style 'R_OVERRIDE' \
			--merge '{"mtime"}' \
				--style 'R_OVERRIDE'
	diff $@.0010.exp $@.0010.got
	diff $@.0010.blame.exp $@.0010.blame.got
	@echo === $@ PASS ===
