
# tests, depends and so on..

TOOLS = ndmerge

.PHONY: all clean depends test veryclean

all: depends test

clean:
	rm -rf tmp

depends:
	make -C $@

test:
	make -C test/ndmerge

veryclean: clean
	make -C depends clean
