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
