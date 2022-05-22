all: test

.PHONY: test

GHDL_FLAGS = --std=08
VHDL_FILES = $(wildcard *.vhdl)

work-obj08.cf: $(VHDL_FILES)
	ghdl -a ${GHDL_FLAGS} $^

subordinate.v: work-obj08.cf
	ghdl --synth ${GHDL_FLAGS} --out=verilog subordinate > $@

test: work-obj08.cf
	ghdl -r ${GHDL_FLAGS} subordinate_tb --wave=subordinate_tb.ghw

formal/subordinate_prove: subordinate.v formal/subordinate.sby formal/subordinate_verification.v formal/faxil_slave.v
	rm -rf $@
	cd formal && sby -f subordinate.sby prove

formal/subordinate_cover: subordinate.v formal/subordinate.sby formal/subordinate_verification.v formal/faxil_slave.v
	rm -rf $@
	cd formal && sby -f subordinate.sby cover
