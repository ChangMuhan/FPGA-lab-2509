`timescale 1ns/1ps

module tb_vga_must;

reg sys_clk ;
reg sys_rst_n ;

wire hsync ;
wire [15:0] rgb ;
wire vsync ;

initial begin
    #30000000
    $finish;
end

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	#100
	sys_rst_n <= 1'b1;
end

always #10 sys_clk = ~sys_clk ;

vga_must vga_must_inst
(
 .sys_clk (sys_clk ), 
 .sys_rst_n (sys_rst_n ), 

 .hsync (hsync ), 
 .vsync (vsync ), 
 .rgb (rgb ) 
);


 endmodule
