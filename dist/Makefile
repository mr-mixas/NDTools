export DEVSCRIPTS_CHECK_DIRNAME_LEVEL=0

INC_DIR=../lib/App/NDTools/INC
NDTOOLS=nddiff ndpatch ndproc ndquery

.PHONY: deb depends man veryclean

all:

deb: depends man
	debuild

depends: $(INC_DIR)

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

$(INC_DIR):
	sh -c 'cd .. && . ./SOURCEME' # fetch depends
	cp -al ../depends/lib/perl5/ $@
	find $@ -path '*/.meta/*' -delete
	find $@ -type f -name .packlist -delete
	find $@ -type f -name \*.pod -delete
	find $@ -type d -empty -delete

