# tests, depends and so on..

CWD := $(shell pwd -P)
export PATH := $(CWD):$(PATH)
export PERL5LIB := $(CWD)

.PHONY: all clean depends dist test veryclean

all: dist

clean:
	make -C test clean
	make -C dist veryclean

depends: \
	NDTools/INC/Log/Log4Cli.pm \
	NDTools/INC/Struct/Diff.pm \
	NDTools/INC/Struct/Path.pm \
	NDTools/INC/Struct/Path/PerlStyle.pm

dist:
	make -C dist deb

test:
	make -C test
	@echo ===== ALL TESTS PASSED =====

NDTools/INC/Log/Log4Cli.pm:
	mkdir -p $(@D)
	wget -O $@ "https://api.metacpan.org/source/MIXAS/Log-Log4Cli-0.12/lib/Log/Log4Cli.pm"

NDTools/INC/Struct/Diff.pm:
	mkdir -p $(@D)
	wget -O $@ "https://raw.githubusercontent.com/mr-mixas/Struct-Diff.pm/master/lib/Struct/Diff.pm"

NDTools/INC/Struct/Path.pm:
	mkdir -p $(@D)
	wget -O $@ "https://raw.githubusercontent.com/mr-mixas/Struct-Path.pm/master/lib/Struct/Path.pm"

NDTools/INC/Struct/Path/PerlStyle.pm:
	mkdir -p $(@D)
	wget -O $@ "https://raw.githubusercontent.com/mr-mixas/Struct-Path-PerlStyle.pm/master/lib/Struct/Path/PerlStyle.pm"

veryclean: clean
	rm -rf NDTools/INC/*
