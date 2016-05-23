
# fetch and update dependent modules

MODS = Log-Log4Cli.pm Struct-Diff.pm Struct-Path.pm Struct-Path-PerlStyle.pm

.PHONY: all always clean pull test
.PRECIOUS: $(MODS)

all: pull

clean:
	rm -rf $(addsuffix *, $(MODS))

pull: $(addsuffix .pull, $(MODS))

test: $(addsuffix .test, $(MODS))

%.pm.test: %.pm
	cd $^ && perl Makefile.PL
	make -C $^ test

%.pm.pull: %.pm
	git -C $^ pull

%.pm:
	git clone git@github.com:mr-mixas/$@.git
