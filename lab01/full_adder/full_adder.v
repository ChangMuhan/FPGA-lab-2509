module full_adder(
	input wire addend,
	input wire augend,
	input wire c_in,
	output wire c_out,
	output wire sum
);

assign sum = addend^augend^c_in;

assign c_out = ((addend^augend)&c_in) | (addend&augend);

endmodule
