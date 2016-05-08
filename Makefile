
# tests, depends and so on..

TOOLS = ndmerge

.PHONY: all clean depends test veryclean

all: depends test

clean:
	rm -rf tmp

depends:
	make -C $@

test:
	@echo $@ not implemented yet

veryclean: clean
	make -C depends clean
