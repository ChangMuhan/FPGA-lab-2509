`timescale 1ns/1ps

module vga_ctrl(
    input  wire        vga_clk,    // VGA working clock, 25MHz
    input  wire        sys_rst_n,  // Reset signal. Low level is effective
    input  wire [15:0] pix_data,   // Color information

    output wire [9:0]  pix_x,      // X coordinate
    output wire [9:0]  pix_y,      // Y coordinate
    output wire        hsync,      // Line sync signal
    output wire        vsync,      // Field sync signal
    output wire [15:0] rgb         // RGB565 data
);

    // parameter define based on VGA timing diagram (640x480@60)
    parameter H_SYNC  = 10'd96;
    parameter H_BACK  = 10'd40;
    parameter H_LEFT  = 10'd8;
    parameter H_VALID = 10'd640;
    parameter H_RIGHT = 10'd8;
    parameter H_FRONT = 10'd8;
    parameter H_TOTAL = 10'd800;

    parameter V_SYNC  = 10'd2;
    parameter V_BACK  = 10'd25;
    parameter V_TOP   = 10'd8;
    parameter V_VALID = 10'd480;
    parameter V_BOTTOM= 10'd8;
    parameter V_FRONT = 10'd2;
    parameter V_TOTAL = 10'd525;

    // wire define
    wire rgb_valid;     // image valid signal
    wire pix_data_req;  // image request signal

    // reg define
    reg [9:0] cnt_h;    // counter for line sync
    reg [9:0] cnt_v;    // counter for field sync

    // Counter for line sync
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_h <= 10'd0;
        else if (cnt_h == H_TOTAL - 1'b1)
            cnt_h <= 10'd0;
        else
            cnt_h <= cnt_h + 1'b1;
    end

    // Generate line sync signal (active-high pulse as in original code)
    assign hsync = (cnt_h <= H_SYNC - 1'b1) ? 1'b1 : 1'b0;

    // Counter for field sync
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_v <= 10'd0;
        else if ((cnt_v == V_TOTAL - 1'b1) && (cnt_h == H_TOTAL - 1'b1))
            cnt_v <= 10'd0;
        else if (cnt_h == H_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else
            cnt_v <= cnt_v;
    end

    // Generate field sync signal (active-high pulse as in original code)
    assign vsync = (cnt_v <= V_SYNC - 1'b1) ? 1'b1 : 1'b0;

    // Generate image valid signal
    assign rgb_valid = ( (cnt_h >= H_SYNC + H_BACK + H_LEFT)
                      && (cnt_h <  H_SYNC + H_BACK + H_LEFT + H_VALID)
                      && (cnt_v >= V_SYNC + V_BACK + V_TOP)
                      && (cnt_v <  V_SYNC + V_BACK + V_TOP + V_VALID) );

    // Generate pixel request signal (1 pixel early)
    assign pix_data_req = ( (cnt_h >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                         && (cnt_h <  H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1)
                         && (cnt_v >= V_SYNC + V_BACK + V_TOP)
                         && (cnt_v <  V_SYNC + V_BACK + V_TOP + V_VALID) );

    // Generate x and y coordinate of current pixel
    assign pix_x = (pix_data_req)
                 ? (cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 10'h3ff;
    assign pix_y = (pix_data_req)
                 ? (cnt_v - (V_SYNC + V_BACK + V_TOP))        : 10'h3ff;

    // Generate RGB signal
    assign rgb = (rgb_valid) ? pix_data : 16'b0;

endmodule