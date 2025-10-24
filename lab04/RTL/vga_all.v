`timescale 1ns/1ps

// Top-level: generate VGA timing and render based on state
module vga_all(
    input  wire        sys_clk,   // System Clock, 50MHz
    input  wire        sys_rst_n, // Reset signal. Low level is effective
    input  wire        key_in,    // Button for state transition
    output wire        hsync,     // Line sync signal
    output wire        vsync,     // Field sync signal
    output wire [15:0] rgb        // RGB565 color data
);
    // wire define
    wire        vga_clk;        // 25MHz pixel clock
    wire [9:0]  pix_x;          // current pixel x
    wire [9:0]  pix_y;          // current pixel y
    wire [15:0] pix_data;       // pixel color from selected generator
    wire [15:0] color_bar_data; // from color bar generator
    wire [15:0] must_pic_data;  // from "MUST" picture generator
    wire [15:0] end_pic_data;   // from "END" picture generator

    // --- State Machine ---
    // States
    parameter S_COLOR_BAR = 2'b00;
    parameter S_MUST      = 2'b01;
    parameter S_END       = 2'b10;

    // State registers
    reg [1:0] current_state;
    reg [1:0] next_state;

    // Button debouncer and edge detector
    reg [19:0] debounce_cnt;
    reg        key_reg0, key_reg1, key_reg2;
    wire       key_posedge;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            key_reg0 <= 1'b1;
            key_reg1 <= 1'b1;
            key_reg2 <= 1'b1;
        end else begin
            key_reg0 <= key_in;
            key_reg1 <= key_reg0;
            key_reg2 <= key_reg1;
        end
    end
assign key_posedge = (key_reg1 == 1'b0) && (key_reg2 == 1'b1); // Correctly detect falling edge (1 -> 0)

    // State register logic
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            current_state <= S_COLOR_BAR;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S_COLOR_BAR: next_state = key_posedge ? S_MUST : S_COLOR_BAR;
            S_MUST:      next_state = key_posedge ? S_END  : S_MUST;
            S_END:       next_state = key_posedge ? S_COLOR_BAR : S_END;
            default:     next_state = S_COLOR_BAR;
        endcase
    end

    // --- Instantiations ---

    // Clock generator (1/2 divider)
    pll pll_inst (
        .sys_clk  (sys_clk),
        .sys_rst_n(sys_rst_n),
        .vga_clk  (vga_clk)
    );

    // Picture generator: Color Bar
    vga_pic_colorbar vga_pic_colorbar_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
	.pix_y    (pix_y),
        .pix_data (color_bar_data)
    );

    // Picture generator: draws "MUST"
    vga_pic_must vga_pic_must_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .pix_data (must_pic_data)
    );

    // Picture generator: draws "END"
    vga_pic_end vga_pic_end_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .pix_data (end_pic_data)
    );

    // VGA timing controller
    vga_ctrl vga_ctrl_inst (
        .vga_clk  (vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_data (pix_data),   // Muxed data
        .pix_x    (pix_x),
        .pix_y    (pix_y),
        .hsync    (hsync),
        .vsync    (vsync),
        .rgb      (rgb)
    );

    // Output MUX: select pixel data based on state
    assign pix_data = (current_state == S_COLOR_BAR) ? color_bar_data :
                      (current_state == S_MUST)      ? must_pic_data  :
                      (current_state == S_END)       ? end_pic_data   :
                                                       16'h0000; // Default to black

endmodule