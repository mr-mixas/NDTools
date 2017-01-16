BIN=ndquery
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_common \
	t_default \
	t_insert \
	t_list \
	t_md5 \
	t_md5_nonref \
	t_out_fmt \
	t_path \
	t_utf8
	@echo === ALL $(BIN) TESTS PASSED ===

t_default:
	$(BIN) $(VERB) ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_insert:
	$(BIN) $(VERB) ../alpha.json --insert ../beta.json > $@.0000.got # whole doc must be rewritten
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) ../alpha.json --path '{files}' --insert ../beta.json > $@.0010.got
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) ../alpha.json --path '{some}{new}{path}' --insert ../beta.json > $@.0020.got
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) ../alpha.json --path '{}' --insert ../beta.json > $@.0030.got
	diff $@.0030.exp $@.0030.got

t_list:
	$(BIN) $(VERB) --list ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --list --depth 1 ../alpha.json > $@.0010.got
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) --path '{files}' --list ../alpha.json > $@.0020.got
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) --colors --list ../_data/deep-down-lorem.a.json > $@.0030.got
	diff $@.0030.exp $@.0030.got

t_md5:
	$(BIN) $(VERB) --md5 ../_data/menu.a.json ../_data/menu.b.json ../_data/menu.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_md5_nonref:
	$(BIN) $(VERB) --md5 --path '[0]{File}[0]{label}' ../_data/menu.a.json ../_data/menu.b.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_out_fmt:
	$(BIN) $(VERB) --out-fmt yaml ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_path:
	$(BIN) $(VERB) --path '{files}{"/etc/hosts"}' ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --path '[]' ../_data/menu.a.json > $@.0010.got
	diff $@.0010.exp $@.0010.got

t_utf8:
	$(BIN) $(VERB) --path '{"текст"}' ../_data/text-utf8.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

include ../_common.mk

t_barebin:
	$(BIN) $(VERB) </dev/null && false || true
