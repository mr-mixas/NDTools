export DEVSCRIPTS_CHECK_DIRNAME_LEVEL=0

NDTOOLS=nddiff ndmerge ndquery

.PHONY: deb man veryclean

all:

deb: man
	debuild

man: $(addsuffix .1, $(NDTOOLS))

%.1:
	pod2man --center ndtools --section 1 --release $(shell ../$* --ver) --name $* ../$* > $@.TMP
	mv $@.TMP $@

veryclean:
	debclean
	rm -f \
        $(addsuffix .1, $(NDTOOLS)) \
        $(addprefix ../, $(addprefix ndtools_*, .dsc .tar.gz .deb .build .changes))
