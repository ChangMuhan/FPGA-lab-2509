`timescale 1ns/1ns

module tb_comparator;

	reg A, B;
	wire LED1, LED2, LED3;
	
	comparator comparator(
		.A(A),
		.B(B),
		.smaller(LED1),
		.equal(LED2),
		.larger(LED3)
	);

	initial begin
		A=0;B=0;
		#10;
		A=0;B=1;
		#10;
		A=1;B=0;
		#10;
	end
endmodule