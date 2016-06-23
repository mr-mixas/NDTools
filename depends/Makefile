
# fetch and update dependent modules

MODS = Log-Log4Cli.pm Struct-Diff.pm Struct-Path.pm Struct-Path-PerlStyle.pm

.PHONY: all always clean links pull test
.PRECIOUS: $(MODS)

all: pull links

clean:
	rm -rf $(addsuffix *, $(MODS))

links: $(MODS)
	mkdir -p ../NDTools/INC/Log
	ln -sf ../../../depends/Log-Log4Cli.pm/lib/Log/Log4Cli.pm ../NDTools/INC/Log/Log4Cli.pm
	mkdir -p ../NDTools/INC/Struct
	ln -sf ../../../depends/Struct-Diff.pm/lib/Struct/Diff.pm ../NDTools/INC/Struct/Diff.pm
	ln -sf ../../../depends/Struct-Path.pm/lib/Struct/Path.pm ../NDTools/INC/Struct/Path.pm
	mkdir -p ../NDTools/INC/Struct/Path
	ln -sf ../../../../depends/Struct-Path-PerlStyle.pm/lib/Struct/Path/PerlStyle.pm \
		../NDTools/INC/Struct/Path/PerlStyle.pm

pull: $(addsuffix .pull, $(MODS))

test: $(addsuffix .test, $(MODS))

%.pm.test: %.pm
	cd $^ && perl Makefile.PL
	make -C $^ test

%.pm.pull: %.pm
	git -C $^ pull

%.pm:
	git clone git@github.com:mr-mixas/$@.git
