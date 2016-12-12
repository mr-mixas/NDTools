BIN=ndproc
VERB=-vvvv

.PHONY: always test clean

all: test clean

include ../_common.mk

test: \
	t_common \
	t_list_modules \
	t_m__UNKNOWN_via_args \
	t_m_Remove \
	t_m_Remove__strict \
	t_m_Remove__dump_blame
	@echo === ALL $(BIN) TESTS PASSED ===

t_list_modules:
	$(BIN) $(VERB) --list-modules -l > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m__UNKNOWN_via_args:
	$(BIN) $(VERB) --module NoTeXiStEd; $(VRFY_EXIT_1)

# TODO:
# t_m__UNKNOWN_via_rules:

t_m_Remove:
	$(BIN) $(VERB) --module Remove --path '{some}[0..5]' ../_data/deep-down-lorem.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_m_Remove__strict:
	$(BIN) $(VERB) --module Remove --path '{some}[1000]' --strict ../_data/deep-down-lorem.a.json; $(VRFY_EXIT_4)

t_m_Remove__dump_blame:
	$(BIN) $(VERB) --module Remove --path '[1]{Edit}[3..5]' ../_data/menu.a.json --dump-blame $@.0000.got >/dev/null
	diff $@.0000.exp $@.0000.got

t_pod:
	@# bin itself doesn't contain pod
