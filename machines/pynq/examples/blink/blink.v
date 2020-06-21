module blink (
	output	[3:0]led
);

	wire [3:0] fclk;
	reg status;

	always @(posedge fclk[0]) begin
		if (status == 0)
			status <= 1;
		else
			status <= 0;
	end

	assign led[0] = status;
	assign led[1] = status;
	assign led[2] = status;
	assign led[3] = status;

	PS7 the_PS (
		.FCLKCLK (fclk)
	);
endmodule


