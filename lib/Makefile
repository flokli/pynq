PART ?= xc7z020clg400
# TODO: this currently only works for pynqs, as we hardcode the pynq.xdc. Don't
# be fooled by the PART= variable above ;-)

# Remove all intermediate files
clean:
	rm -f *.edif *.tcl *.bit *.html *.xml
	rm -Rf .Xil

# Invoke yosys to turn .v to .edif
%.edif: %.v
	yosys -p "read_verilog +/xilinx/cells_xtra.v $^; synth_xilinx -edif $@ -top $(patsubst %.edif,%,$@)"

# Generate a TCL file, containing instructions for verilog to synthesize .edif to .bit
%.tcl: %.edif
	echo -e "set_param general.maxThreads 32\nread_xdc pynq.xdc\nread_edif $<\nlink_design -part $(PART) -top $(patsubst %.tcl,%,$@)\nplace_design\nroute_design\nwrite_bitstream -force $(patsubst %.tcl,%,$@).bit" > $@

# Use vivado to synthesize .edif files to .bit bitstreams
%.bit: %.tcl
	vivado -nolog -nojournal -mode batch -source $<
