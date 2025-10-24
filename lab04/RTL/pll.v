`timescale 1ns/1ps

module pll(
	input wire sys_clk, //50mhz
	input wire sys_rst_n,
	
	output wire vga_clk //25mhz

);

reg clk_25;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)begin
		clk_25 <= 0;
	end
	else begin
		clk_25 <= ~clk_25;
	end
end

assign vga_clk = clk_25;

endmodule
