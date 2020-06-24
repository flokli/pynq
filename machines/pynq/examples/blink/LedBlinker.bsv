import Led::*;

interface LedBlinker;
endinterface

// If an enumerated type or union tag is applied to two or more arguments, an
// error will be reportedabout an unbound type constructor.  The constructor name
// will be the type name followed by thetag  name,  with  a  non-ASCII  center-dot
// character  separating  the  two.   The  position  of  the  errorcorrectly
// points to the location where the constructor is applied to too many arguments.

module mkLedBlinker(LED#(1) l, LedBlinker ifc);
//LedBlinker ifc, Wire#(Led#(1)) l);
	// flip a single bit on every clock cycle
	Reg#(Bool) x <- mkReg(False);

	rule toggler;
		x <= !x;

		l.set(pack(x));
	endrule
endmodule

