

// so far, we import only the following from PS7:
//    output [3:0] FCLKCLK;
//    output [3:0] FCLKRESETN;

interface PS7;
	//(* always_ready *)
	//method Bit#(4) getFCLKCLK();
	//(* always_ready *)
	//method Bit#(4) getFCLKRESETN();
	////(* always_ready *)
	////method Bit#(4) setLED();

	interface Clock clock_out;
	interface Reset reset_out;

        (* always_ready *)
	method Bit#(4) read_btn();
	(* always_ready *)
	method Bit#(1) read_sw0();
	(* always_ready *)
	method Bit#(1) read_sw1();

	method Action write_led(Bit#(4) v);
endinterface



import "BVI" PS7 =
module mkPS7 (PS7);
	// TODO: make this 4 bits
	Wire#(Bit#(4)) fclkclk ← mkBypassWire();

	// Wire#(Bit#(4)) led <- mkWire;

	// default_clock clk;
	// default_reset rst_RST_N;
	default_clock no_clock;
	default_reset no_reset;

	// input_clock clk (fclkclk) <- exposeCurrentClock;
	// input_reset rst_RST_N (fclkresetn) clocked_by(clk) <- exposeCurrentReset;

	// Verilog non-clock inputs translate to:
	// - Enables for Action or ActionValue methods
	// - Arguments for any type method - Action, ActionValue or value

	// Verilog non-clock outputs translate to:
	// - Return values from ActionValue or value methods
	// - Ready signals for methods

	//method FCLKCLK getFCLKCLK();
	//method FCLKRESETN getFCLKRESETN();

        output_clock clock_out(FCLKCLK);
	output_reset reset_out(FCLKRESETN) clocked_by(no_clock);

	method btn read_btn;
	method sw0 read_sw0;
	method sw1 read_sw1;

	schedule (read_btn, read_sw0, read_sw1 ) CF (read_btn, read_sw0, read_sw1);

	method write_led(led) enable((*inhigh*) ignore) clocked_by(clock_out);

	schedule (write_led) CF (write_led);
endmodule


///// TODO: import from
///interface LED#(numeric type n);
///   (* always_ready *)
///   method Bit#(n) out;
///endinterface
///
///module mkLED (LED#(width));
///	Wire#(Bit#(width)) x  <- mkWire;
///
///	method Bit#(width) out();
///		return x;
///	endmethod
///endmodule

interface Blinker;
	(* always_ready *)
	method Bit#(1) getValue();
endinterface

(* synthesize *)
//module mkBlinker(Clock clk, Reset rst, Blinker ifc);
module mkBlinker(Blinker);
	Reg#(Bool) value <- mkReg(False);

	rule toggler;
		value <= !value;
	endrule

	method Bit#(1) getValue();
		return pack(value);
	endmethod
endmodule

interface LEDsBlinker;
endinterface

// HACK: pass in the PS7 instead
module mkLEDsBlinker(PS7 the_PS, LEDsBlinker ifc);
	Reg#(Bool) value <- mkReg(False);

	rule toggler;
		//let ledValues = pack([value, !value, value, !value]);
		Bit#(4) ledValues;

		ledValues[0] = pack(value);
		ledValues[1] = pack(!value);
		ledValues[2] = pack(the_PS.read_btn()[0]);
		ledValues[3] = pack(!value);

		value <= !value;

		the_PS.write_led(ledValues);
	endrule
endmodule


(* synthesize, no_default_clock, no_default_reset *)
module mkTop (Empty);

	PS7 the_PS <- mkPS7;// reset_by(no_reset) clocked_by(no_clock);

	//(* reset_by="no_reset" *);

	////MakeClockIfc#(Bit#(1)) clk_gen <- mkUngatedClock(0);
	////Clock ps7Clock = clk_gen.new_clk;

	////MakeResetIfc r <- mkReset(0, True, ps7Clock);
	////Reset ps7Reset = r.new_rst;

	////rule do_clk;
	////	clk_gen.setClockValue(the_PS.getFCLKCLK()[0]);
	////endrule
	// MakeClockIfc#(Bit#(1)) osc <- mkReg(0);
	//MakeClockIfc#(Bit#(1)) mc <- mkClock(False, True);
	//Clock ps7Clock = mkUngatedClock(the_PS.getFCLKCLK()[0]);
	//Clock ps7Clock = mkUngatedClock(the_PS.getFCLKCLK()[0]);

	//Clock ps7Clock <- mkClock(the_PS.getFCLKCLK()[0], True);
	//Reset ps7Reset <- mkNewReset;

	//Blinker blinker1 <- mkBlinker(ps7Clock, ps7Reset);
	//Blinker blinker1 <- mkBlinker(the_PS.clock_out, the_PS.reset_out);
	//Blinker blinker1 <- mkBlinker(the_PS.clock_out, the_PS.reset_out);

        //Blinker blinker1 <- mkBlinker(clocked_by the_PS.clock_out, reset_by the_PS.reset_out);

        // TODO: abstract led, and use that, instead of passing in the ps7
        LEDsBlinker blinker1 <- mkLEDsBlinker(the_PS, clocked_by the_PS.clock_out, reset_by the_PS.reset_out);

	//rule foo;
        //	the_PS.write_led('b0101);
        //        led <=  the_PS.setLED(led);
        //endrule

	//rule foo;
	//	ps7Clock <= the_PS.getFCLKCLK()[0];
	//	ps7Reset <= the_PS.getFCLKRESETN()[0];
	//endrule
endmodule
