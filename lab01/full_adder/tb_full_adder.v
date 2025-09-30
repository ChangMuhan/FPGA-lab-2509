`timescale 1ns/1ns

module tb_full_adder;

	reg addend, augend, c_in;
	wire sum, c_out;

	full_adder full_adder(
		 .addend(addend),
		 .augend(augend), 
		 .c_in(c_in),
		 .sum(sum),
		 .c_out(c_out)
	);

	initial begin
		 addend = 0; augend = 0; c_in = 0;
		 #10;
		 
		 addend = 1; augend = 0; c_in = 0;
		 #10;
		 
		 addend = 1; augend = 1; c_in = 0;
		 #10;
		 
		 addend = 1; augend = 1; c_in = 1;
		 #10;
		 
		 addend = 0; augend = 1; c_in = 1;
		 #10;
end
endmodule