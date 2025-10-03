module running_light(
	input wire sys_clk,
	input wire sys_rst_n,
	
	output reg[3:0] led_out
);

parameter TIME_INTERVAL = 25000;
reg[25:0] counter;
reg[3:0] led;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)begin
		counter <= 0;
		led <= 4'b0001;
		led_out <= ~4'b0001;
	end

	else if (counter == TIME_INTERVAL)begin
		counter <= 0;
		if (led == 4'b1000)begin
			led <= 4'b0001;
		end
		else begin
			led <= led << 1;
		end
		led_out <= ~led;
	end

	else begin
		counter <= counter + 1;
		led_out <= ~led;
	end

end

endmodule
