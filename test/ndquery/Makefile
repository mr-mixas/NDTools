BIN=ndquery
VERB=-vvvv

.PHONY: always test clean

all: test clean

test: \
	t_default \
	t_list \
	t_list_values \
	t_md5 \
	t_md5_nonref \
	t_out_fmt \
	t_path \
	t_raw_output \
	t_strict \
	t_utf8
	@echo === ALL $(BIN) TESTS PASSED ===

include ../_common.mk

t_default:
	$(BIN) $(VERB) ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_list:
	$(BIN) $(VERB) --list ../alpha.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --list --depth 1 ../alpha.json > $@.0010.got
	diff $@.0010.exp $@.0010.got
	$(BIN) $(VERB) --path '{files}' --list ../alpha.json > $@.0020.got
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) --colors --list ../_data/deep-down-lorem.a.json > $@.0030.got
	diff $@.0030.exp $@.0030.got

t_list_values:
	$(BIN) $(VERB) --list --values --vals ../_data/menu.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got
	$(BIN) $(VERB) --depth 3 --list --values --vals ../_data/menu.a.json > $@.0010.got
	diff $@.0010.exp $@.0010.got

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
	$(BIN) $(VERB) --path '[1]{Edit}[]{id}(eq "edit_paste")(<<)' ../_data/menu.a.json > $@.0020.got
	diff $@.0020.exp $@.0020.got
	$(BIN) $(VERB) --path '[1]{Edit}[](not defined)' ../_data/menu.a.json > $@.0030.got
	diff $@.0030.exp $@.0030.got

t_raw_output:
	$(BIN) $(VERB) --path '[0]{File}[1]' ../_data/menu.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got # will be JSON because it's a structure
	$(BIN) $(VERB) --raw-output --path '[0]{File}[1]{label}' ../_data/menu.a.json > $@.0010.got
	diff $@.0010.exp $@.0010.got # will be bare string

t_strict:
	$(BIN) $(VERB) --strict --path '[0]{NoTeXiStS}' ../_data/menu.a.json; $(VRFY_EXIT_8)
	$(BIN) $(VERB) --nostrict --path '[0]{NoTeXiStS}' ../_data/menu.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

t_utf8:
	$(BIN) $(VERB) --path '{"текст"}' ../_data/text-utf8.a.json > $@.0000.got
	diff $@.0000.exp $@.0000.got

