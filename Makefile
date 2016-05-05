
# tests and such stuff

EMODS = Log-Log4Cli.pm Struct-Diff.pm Struct-Path.pm
LPATH = ./ext
TOOLS =

.PHONY: all always clean depends test

all: depends test

clean:

depends: $(MODS)

test:
	echo $@ not implemented yet

veryclean: clean
	rm -rf $(MODS)

%.pm: always
	test -d $@ && git -C $@ pull || \
		git clone git@github.com:mr-mixas/$@.git
