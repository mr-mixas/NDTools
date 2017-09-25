# tests, depends and so on..

CWD := $(shell pwd -P)
export PATH := $(CWD):$(PATH)
export PERL5LIB := lib/$(CWD)

TEST_JOBS ?= 4

.PHONY: all clean depends dist test veryclean

all: dist

clean: clean_test
	make -C dist veryclean

clean_test:
	rm -f t/*/*.d/*.got

depends: \
	lib/NDTools/INC/Hash/Merge/Extra.pm \
	lib/NDTools/INC/Log/Log4Cli.pm \
	lib/NDTools/INC/Struct/Diff.pm \
	lib/NDTools/INC/Struct/Path.pm \
	lib/NDTools/INC/Struct/Path/PerlStyle.pm

dist:
	make -C dist deb

test: depends
	prove -l t/*.t t/lib/*.t
	prove -l --jobs $(TEST_JOBS) t/bin/*.t

lib/NDTools/INC/Hash/Merge/Extra.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Hash-Merge-Extra-0.02/lib/Hash/Merge/Extra.pm"

lib/NDTools/INC/Log/Log4Cli.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Log-Log4Cli-0.18/lib/Log/Log4Cli.pm"

lib/NDTools/INC/Struct/Diff.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Diff-0.90/lib/Struct/Diff.pm"

lib/NDTools/INC/Struct/Path.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Path-0.71/lib/Struct/Path.pm"

lib/NDTools/INC/Struct/Path/PerlStyle.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Path-PerlStyle-0.70/lib/Struct/Path/PerlStyle.pm"

veryclean: clean
	rm -rf lib/NDTools/INC/*
