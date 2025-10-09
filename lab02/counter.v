module counter(
    input wire sys_clk,
    input wire sys_rst_n,
    output reg led_out,
    output reg [24:0] cnt
);
    parameter CNT = 10000000 - 1;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt <= 0;
        else if (cnt == CNT)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            led_out <= 0;
        else if (cnt == CNT)
            led_out <= ~led_out;
    end

endmodule