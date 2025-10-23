`timescale 1ns/1ps

// Top-level: generate VGA timing and render "MUST"
module vga_must(
    input  wire        sys_clk,   // System Clock, 50MHz
    input  wire        sys_rst_n, // Reset signal. Low level is effective
    output wire        hsync,     // Line sync signal
    output wire        vsync,     // Field sync signal
    output wire [15:0] rgb        // RGB565 color data
);
    // wire define
    wire        vga_clk;   // 25MHz pixel clock
    wire [9:0]  pix_x;     // current pixel x
    wire [9:0]  pix_y;     // current pixel y
    wire [15:0] pix_data;  // pixel color from picture generator

    // Clock generator (1/2 divider)
    pll pll_inst (
        .sys_clk  (sys_clk),
        .sys_rst_n(sys_rst_n),
        .vga_clk  (vga_clk)
    );

    // Picture generator: draws "MUST"
    vga_pic vga_pic_inst (
        .vga_clk  (vga_clk),    // VGA working clock, 25MHz
        .sys_rst_n(sys_rst_n),  // Reset signal. Low level is effective
        .pix_x    (pix_x),      // x coordinate of current pixel
        .pix_y    (pix_y),      // y coordinate of current pixel
        .pix_data (pix_data)    // color information
    );

    // VGA timing controller
    vga_ctrl vga_ctrl_inst (
        .vga_clk  (vga_clk),    // VGA working clock, 25MHz
        .sys_rst_n(sys_rst_n),  // Reset signal. Low level is effective
        .pix_data (pix_data),   // color information
        .pix_x    (pix_x),      // x coordinate of current pixel
        .pix_y    (pix_y),      // y coordinate of current pixel
        .hsync    (hsync),      // Line sync signal
        .vsync    (vsync),      // Field sync signal
        .rgb      (rgb)         // RGB565 color data
    );

endmodule
