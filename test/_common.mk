# common tests and opts for all utils

VERB=-vvvv

define VRFY_EXIT_1
e=$$?; [ $$e -ne 1 ] && { echo "--- WRONG EXIT CODE. EXPECTED: 1, GOT: $$e --- "; exit 255; } || true
endef

clean:
	rm -f *.got

t_common: t_barebin t_help t_pod t_verbose t_version

t_barebin: always
	$(BIN); $(VRFY_EXIT_1)

t_help: always
	$(BIN) --help > $@.got 2>&1; $(VRFY_EXIT_1)
	diff $@.exp $@.got

t_pod:
	podchecker ../../$(BIN)

t_verbose: always
	$(BIN) -vv -v2 --verbose --verbose 3 ../alpha.json >/dev/null 2>&1 #check aliases and args

t_version: always
	$(BIN) --version --ver | grep --quiet --perl-regexp '^\d+\.\d+' # also to check aliases
