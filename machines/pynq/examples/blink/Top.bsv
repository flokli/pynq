import Clocks::*;

import PS7::*;
import LedBlinker::*;

interface Top;
        (* always_ready *)
        method Bit#(4) btn;
	(* always_ready *)
	method Bit#(1) sw0;
	(* always_ready *)
	method Bit#(1) sw1;

	(* always_ready *)
	method Bit#(4) led();
	////method Bit#(4) setLED();

	interface Clock fclk_clk;
	interface Reset fclk_rst;
endinterface


// leds, buttons and dipswitches are exposed to verilog as inputs and outputs
// to the toplevel module.

// More sophisticated peripherals are connected via PS7.
(* synthesize *)//, no_default_clock, no_default_reset *)
module mkTop (Top ifc);

	//Wire#(Bit#(4)) btn;

	PS7 the_PS <- mkPS7;// reset_by(no_reset) clocked_by(no_clock);

	let clk_gen <- mkUngatedClock(0);
	let rst_gen <- mkReset(0, False, clk_gen.new_clk);


	Reg#(bit) led0 <- mkReg(0);
	Reg#(bit) led1 <- mkReg(0);
	Reg#(bit) led2 <- mkReg(0);
	Reg#(bit) led3 <- mkReg(0);
	Reg#(Int#(32)) steps <- mkReg(0);

        rule do_clk;
        	clk_gen.setClockValue(the_PS.fclkclk[0]);
        endrule

        rule do_reset;
        	if (the_PS.fclkclk[0] == 1) rst_gen.assertReset();
        endrule

        rule foo;
        	led0 <= 0;
        	led1 <= 1;
        	led2 <= pack((steps % 20) == 0);
        	led3 <= pack((steps % 20) == 0);
        	steps <= steps + 1;
        endrule

        method Bit#(4) led();
        	return {led0._read, led1._read, led2._read, led3._read};
        endmethod

	interface Clock fclk_clk = clk_gen.new_clk;
	interface Reset fclk_rst = rst_gen.new_rst;

	//rule do_clk;
	//	Bit#(4) clockBits = the_PS.read_FCLKCLK();
	//	clk_gen.setClockValue(clockBits[0]);

	//	Bit#(4) resetBits = the_PS.read_FCLKRESETN();
	//	if (resetBits[0] == 1) rst_gen.assertReset();
	//endrule

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
        //LedBlinker blinker1 <- mkLedBlinker#((the_PS, clocked_by clk, reset_by rst);

	//rule foo;
        //	the_PS.write_led('b0101);
        //        led <=  the_PS.setLED(led);
        //endrule

	//rule foo;
	//	ps7Clock <= the_PS.getFCLKCLK()[0];
	//	ps7Reset <= the_PS.getFCLKRESETN()[0];
	//endrule

	// method btn read_btn;
	// method sw0 read_sw0;
	// method sw1 read_sw1;

	// schedule (read_btn, read_sw0, read_sw1 ) CF (read_btn, read_sw0, read_sw1);

	// method write_led(led) enable((*inhigh*) ignore) clocked_by(clock_out);

	// schedule (write_led) CF (write_led);
endmodule
