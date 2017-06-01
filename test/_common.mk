# common tests and opts for all utils

VERBi ?= -vvvv

define VRFY_EXIT_1
e=$$?; [ $$e -ne 1 ] && { echo "--- WRONG EXIT CODE. EXPECTED: 1, GOT: $$e --- "; exit 255; } || true
endef

define VRFY_EXIT_4
e=$$?; [ $$e -ne 4 ] && { echo "--- WRONG EXIT CODE. EXPECTED: 4, GOT: $$e --- "; exit 255; } || true
endef

define VRFY_EXIT_8
e=$$?; [ $$e -ne 8 ] && { echo "--- WRONG EXIT CODE. EXPECTED: 8, GOT: $$e --- "; exit 255; } || true
endef

clean:
	rm -f *.got

