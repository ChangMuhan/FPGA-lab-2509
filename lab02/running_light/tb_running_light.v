`timescale 1us/1us

module tb_running_light;

	reg clk, rst;
	wire[3:0] led;
	
	running_light running_light(
		.sys_clk(clk),
		.sys_rst_n(rst),
		.led_out(led)
	);
	initial begin
		clk = 1'b1;
		forever #10 clk = ~clk;
	end
	
	initial begin
		rst = 1'b0;
      #0.2;
      rst = 1'b1;
      #3000000;
		rst = 1'b0;
		#10000;
		rst = 1'b1;
		#3000000;
        
      // $finish;
	end

   initial begin
      $monitor("Time = %t, reset = %b, leds = %b", $time, rst, led);
   end
	
endmodule