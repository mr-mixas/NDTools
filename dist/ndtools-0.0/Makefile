NDTOOLS=nddiff ndmerge ndquery

all:

clean:
	rm -f manpages/*

deb: manpages
	debuild

manpages: $(addsuffix .1,$(addprefix manpages/, $(NDTOOLS)))

manpages/%.1:
	pod2man --center ndtools --section 1 --release $(shell ../../$* --ver) --name $* ../../$* > $@.TMP
	mv $@.TMP $@

veryclean: clean
	rm -f ../ndtools_*
