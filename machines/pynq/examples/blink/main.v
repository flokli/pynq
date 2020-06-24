module main (
	output	[3:0]led,

	output       led4_b,
	output       led4_g,
	output       led4_r,

	output       led5_b,
	output       led5_g,
	output       led5_r,

	input   [3:0]btn,
	input        sw0
	input        sw1
);

	wire [3:0] fclkclk;
	wire [3:0] fclkresetn;

	PS7 the_PS (
		.FCLKCLK (fclkclk),
		.FCLKRESETN (fclkresetn)
	);

	mkMod the_mod (
		.CLK (fclkclk[0]),
		.RST_N (fclkresetn[0]),

		.led (led),

		.led4({ led4_r, led4_g, led4_b }),
		.led5({ led5_r, led5_g, led5_b }),

		.btn (btn),
		.sw0(sw0),
		.sw1(sw1)
	);
endmodule


