// The PS7 provides quite some inputs and outputs connecting to various
// peripherals It also provides a 4bit width clock and reset at FCLKCLK and
// FCLKRESETN respectively.

// Unfortunately, it seems it's not possible to express that in BVI, so we just
// pass along the 4 bits here, and take care of converting it to a proper clock
// and reset in the toplevel module.

//(* always_ready, always_enabled *)
interface PS7;
	method Bit#(4) fclkclk();
	method Bit#(4) fclkresetn();
endinterface

import "BVI" PS7 =
module mkPS7 (PS7);
	default_clock no_clock;
	default_reset no_reset;

	method FCLKCLK    fclkclk();
	method FCLKRESETN fclkresetn();

	//default_clock clk0;
	//output_clock clk(FCLKCLK[0]);
	//output_clock clk1(FCLKCLK_1);
	//output_clock clk2(FCLKCLK_2);
	//output_clock clk3(FCLKCLK_3);

	// TODO: verify this is actually the case
	//schedule (read_FCLKCLK, read_FCLKRESETN) CF (read_FCLKCLK, read_FCLKRESETN);

	// Verilog non-clock inputs translate to:
	// - Enables for Action or ActionValue methods
	// - Arguments for any type method - Action, ActionValue or value

	// Verilog non-clock outputs translate to:
	// - Return values from ActionValue or value methods
	// - Ready signals for methods

endmodule


// some temp blurb, might be useful later
// default_clock clk;
// default_reset rst_RST_N;
// input_clock clk (fclkclk) <- exposeCurrentClock;
// input_reset rst_RST_N (fclkresetn) clocked_by(clk) <- exposeCurrentReset;
// output_clock clock_out(FCLKCLK);
// output_reset reset_out(FCLKRESETN) clocked_by(no_clock);
