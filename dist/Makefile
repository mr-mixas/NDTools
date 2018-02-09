export DEVSCRIPTS_CHECK_DIRNAME_LEVEL=0

INC_DIR=../lib/App/NDTools/INC
NDTOOLS=nddiff ndpatch ndproc ndquery

.PHONY: deb man veryclean

all:

deb: depends man
	debuild

depends: \
	$(INC_DIR)/Hash/Merge/Extra.pm \
	$(INC_DIR)/Log/Log4Cli.pm \
	$(INC_DIR)/Struct/Diff.pm \
	$(INC_DIR)/Struct/Path.pm \
	$(INC_DIR)/Struct/Path/PerlStyle.pm

man: $(addsuffix .1, $(NDTOOLS))

%.1:
	pod2man --center ndtools --section 1 --release $(shell ../$* -V) --name $* ../$* > $@.TMP
	mv $@.TMP $@

veryclean:
	debclean
	rm -f \
        $(addsuffix .1, $(NDTOOLS)) \
        $(addprefix ../, $(addprefix ndtools_*, .dsc .tar.gz .deb .build .changes))
	rm -rf $(INC_DIR)

$(INC_DIR)/Hash/Merge/Extra.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Hash-Merge-Extra-0.06/lib/Hash/Merge/Extra.pm"

$(INC_DIR)/Log/Log4Cli.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Log-Log4Cli-0.20/lib/Log/Log4Cli.pm"

$(INC_DIR)/Struct/Diff.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Diff-0.94/lib/Struct/Diff.pm"

$(INC_DIR)/Struct/Path.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Path-0.81/lib/Struct/Path.pm"

$(INC_DIR)/Struct/Path/PerlStyle.pm:
	mkdir -p $(@D)
	wget -O $@ "http://st.aticpan.org/source/MIXAS/Struct-Path-PerlStyle-0.80/lib/Struct/Path/PerlStyle.pm"

