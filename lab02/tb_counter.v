`timescale 1ns / 1ns
module tb_counter();

    reg sys_clk = 0;
    reg sys_rst_n = 0;
    wire led_out;
    wire [24:0] cnt;
    localparam CNT = 10 - 1;
    reg [24:0] cnt_reg = 0;
    reg led_out_reg = 0;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_reg <= 0;
        else if (cnt_reg == CNT)
            cnt_reg <= 0;
        else
            cnt_reg <= cnt_reg + 1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            led_out_reg <= 0;
        else if (cnt_reg == CNT)
            led_out_reg <= ~led_out_reg;
    end

    assign cnt = cnt_reg;
    assign led_out = led_out_reg;

    always #10 sys_clk = ~sys_clk;

    initial begin
        #100 sys_rst_n = 1;
        #2000000;

        $stop;
    end

endmodule
