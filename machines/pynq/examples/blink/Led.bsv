// TODO: import from bsv-contrib?

(* always_ready, always_enabled *)
interface LED#(numeric type width);
   method Action set(Bit#(width) value);
endinterface

(* synthesize *)
//module mkLED#(Wire#(Bit#(width)) x)(LED#(width) ifc);
module mkLED (int width,
              Wire#(Bit#(width)) x,
              LED#(width) ifc);
	method Action set(Bit#(width) value);
		x <= value;
	endmethod
endmodule
