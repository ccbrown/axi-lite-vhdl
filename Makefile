all: test

.PHONY: test

GHDL_FLAGS = --std=08
VHDL_FILES = $(wildcard *.vhdl)

work-obj08.cf: $(VHDL_FILES)
	ghdl -a ${GHDL_FLAGS} $^

test: work-obj08.cf
	ghdl -r ${GHDL_FLAGS} subordinate_tb --wave=subordinate_tb.ghw
