`timescale 1ns/1ps

// Render the provided 128x64 monochrome bitmap (bitmap_bytes) centered on screen.
// Each row has 16 bytes (left to right). In each byte, bit7 is leftmost pixel.
module vga_pic(
    input  wire        vga_clk,   // VGA working clock, 25MHz
    input  wire        sys_rst_n, // Reset signal. Low level is effective
    input  wire [9:0]  pix_x,     // X coordinate of current pixel
    input  wire [9:0]  pix_y,     // Y coordinate of current pixel
    output reg  [15:0] pix_data   // Color information (RGB565)
);
    // Screen valid size
    localparam H_VALID = 10'd640;
    localparam V_VALID = 10'd480;

    // Bitmap size
    localparam integer BMP_W = 128;  // pixels
    localparam integer BMP_H = 64;   // lines
    localparam integer BYTES_PER_ROW = (BMP_W/8); // 16

    // Scale (power of two recommended)
    localparam integer SCALE_SHIFT = 2;           // 2x
    localparam integer SCALE       = (1 << SCALE_SHIFT);

    // Scaled bitmap size
    localparam integer BMP_W_SCALED = (BMP_W << SCALE_SHIFT); // 512
    localparam integer BMP_H_SCALED = (BMP_H << SCALE_SHIFT); // 256

    // Center position
    localparam integer ORG_X = (H_VALID - BMP_W_SCALED) >> 1; // 64
    localparam integer ORG_Y = (V_VALID - BMP_H_SCALED) >> 1; // 112

    // Colors
    localparam [15:0] FG = 16'hFFFF; // white
    localparam [15:0] BG = 16'h0000; // black

    // Return a 128-bit vector for the bitmap row r (0..63).
    // Concatenation order: {byte0, byte1, ..., byte15}, so bit[127] is the leftmost pixel of the row.
    function [127:0] bm_row;
        input [6:0] r;
        begin
            case (r)
                // Top padding rows
                7'd0:  bm_row = {16{8'h00}};
                7'd1:  bm_row = {16{8'h00}};
                // Content rows (2..31)
                7'd2:  bm_row = {8'h3f,8'h00,8'h1f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h07,8'hff,8'h00,8'h00,8'hff,8'hff,8'hf0,8'h00};
                7'd3:  bm_row = {8'h3f,8'h00,8'h1f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h0f,8'hff,8'h80,8'h00,8'hff,8'hff,8'hf0,8'h00};
                7'd4:  bm_row = {8'h3f,8'h00,8'h1f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h1f,8'hff,8'hc0,8'h00,8'hff,8'hff,8'hf0,8'h00};
                7'd5:  bm_row = {8'h3f,8'h80,8'h3f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h1f,8'hff,8'hc0,8'h00,8'hff,8'hff,8'hf0,8'h00};
                7'd6:  bm_row = {8'h3f,8'h80,8'h3f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3f,8'hff,8'he0,8'h00,8'hff,8'hff,8'hf0,8'h00};
                7'd7:  bm_row = {8'h3f,8'h80,8'h3f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3f,8'h07,8'he0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd8:  bm_row = {8'h3f,8'hc0,8'h7f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3e,8'h03,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd9:  bm_row = {8'h3f,8'hc0,8'h7f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3c,8'h01,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd10: bm_row = {8'h3f,8'hc0,8'h7f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3c,8'h01,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd11: bm_row = {8'h3f,8'hc0,8'h7f,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3e,8'h01,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd12: bm_row = {8'h3f,8'he0,8'hff,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3f,8'h80,8'h00,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd13: bm_row = {8'h3f,8'he0,8'hf7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h3f,8'hf8,8'h00,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd14: bm_row = {8'h3d,8'he0,8'hf7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h1f,8'hff,8'h00,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd15: bm_row = {8'h3d,8'he0,8'hf7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h1f,8'hff,8'h00,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd16: bm_row = {8'h3d,8'hf1,8'hf7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h0f,8'hff,8'hc0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd17: bm_row = {8'h3d,8'hf1,8'he7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h07,8'hff,8'he0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd18: bm_row = {8'h3c,8'hf1,8'he7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h00,8'hff,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd19: bm_row = {8'h3c,8'hf1,8'he7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h00,8'h0f,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd20: bm_row = {8'h3c,8'hfb,8'he7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h00,8'h07,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd21: bm_row = {8'h3c,8'hfb,8'hc7,8'h80,8'h3c,8'h00,8'h78,8'h00,8'h78,8'h01,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd22: bm_row = {8'h3c,8'h7b,8'hc7,8'h80,8'h3e,8'h00,8'hf8,8'h00,8'h78,8'h00,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd23: bm_row = {8'h3c,8'h7f,8'hc7,8'h80,8'h3e,8'h00,8'hf8,8'h00,8'h7c,8'h00,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd24: bm_row = {8'h3c,8'h7f,8'h87,8'h80,8'h3e,8'h00,8'hf8,8'h00,8'h7c,8'h00,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd25: bm_row = {8'h3c,8'h7f,8'h87,8'h80,8'h3f,8'h01,8'hf8,8'h00,8'h7e,8'h01,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd26: bm_row = {8'h3c,8'h3f,8'h87,8'h80,8'h3f,8'h83,8'hf8,8'h00,8'h7f,8'h83,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd27: bm_row = {8'h3c,8'h3f,8'h87,8'h80,8'h1f,8'hff,8'hf0,8'h00,8'h3f,8'hff,8'hf0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd28: bm_row = {8'h3c,8'h3f,8'h07,8'h80,8'h0f,8'hff,8'he0,8'h00,8'h1f,8'hff,8'he0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd29: bm_row = {8'h3c,8'h1f,8'h07,8'h80,8'h07,8'hff,8'hc0,8'h00,8'h0f,8'hff,8'hc0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd30: bm_row = {8'h3c,8'h1f,8'h07,8'h80,8'h07,8'hff,8'hc0,8'h00,8'h0f,8'hff,8'hc0,8'h00,8'h00,8'hf0,8'h00,8'h00};
                7'd31: bm_row = {8'h3c,8'h1f,8'h07,8'h80,8'h03,8'hff,8'h80,8'h00,8'h03,8'hff,8'h00,8'h00,8'h00,8'hf0,8'h00,8'h00};
                // Bottom padding rows (32..63)
                7'd32: bm_row = {16{8'h00}};
                7'd33: bm_row = {16{8'h00}};
                7'd34: bm_row = {16{8'h00}};
                7'd35: bm_row = {16{8'h00}};
                7'd36: bm_row = {16{8'h00}};
                7'd37: bm_row = {16{8'h00}};
                7'd38: bm_row = {16{8'h00}};
                7'd39: bm_row = {16{8'h00}};
                7'd40: bm_row = {16{8'h00}};
                7'd41: bm_row = {16{8'h00}};
                7'd42: bm_row = {16{8'h00}};
                7'd43: bm_row = {16{8'h00}};
                7'd44: bm_row = {16{8'h00}};
                7'd45: bm_row = {16{8'h00}};
                7'd46: bm_row = {16{8'h00}};
                7'd47: bm_row = {16{8'h00}};
                7'd48: bm_row = {16{8'h00}};
                7'd49: bm_row = {16{8'h00}};
                7'd50: bm_row = {16{8'h00}};
                7'd51: bm_row = {16{8'h00}};
                7'd52: bm_row = {16{8'h00}};
                7'd53: bm_row = {16{8'h00}};
                7'd54: bm_row = {16{8'h00}};
                7'd55: bm_row = {16{8'h00}};
                7'd56: bm_row = {16{8'h00}};
                7'd57: bm_row = {16{8'h00}};
                7'd58: bm_row = {16{8'h00}};
                7'd59: bm_row = {16{8'h00}};
                7'd60: bm_row = {16{8'h00}};
                7'd61: bm_row = {16{8'h00}};
                7'd62: bm_row = {16{8'h00}};
                7'd63: bm_row = {16{8'h00}};
                default: bm_row = {16{8'h00}};
            endcase
        end
    endfunction

    // In-bitmap area detection
    wire in_area = (pix_x >= ORG_X) && (pix_x < ORG_X + BMP_W_SCALED) &&
                   (pix_y >= ORG_Y) && (pix_y < ORG_Y + BMP_H_SCALED);

    // Local coordinates relative to bitmap origin
    wire [9:0] lx = pix_x - ORG_X; // only used when in_area=1
    wire [9:0] ly = pix_y - ORG_Y;

    // Downscale to bitmap coordinates
    wire [6:0] col = lx[9:SCALE_SHIFT]; // 0..127
    wire [6:0] row = ly[9:SCALE_SHIFT]; // 0..63

    // Combinational color generation; registered on vga_clk to match pipeline
    reg [127:0] row_bits128;
    reg [15:0]  next_pix;

    always @* begin
        if (in_area) begin
            row_bits128 = bm_row(row);
            next_pix    = row_bits128[127 - col] ? FG : BG;
        end else begin
            next_pix    = BG;
        end
    end

    // Register output to align with vga_ctrl one-pixel-early request
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pix_data <= 16'd0;
        else
            pix_data <= next_pix;
    end

endmodule