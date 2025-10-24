`timescale 1ns/1ps

// Render the provided bitmap centered on screen.
// Each row has 12 bytes (96 bits). In each byte, bit7 is leftmost pixel.
module vga_pic_end(
    input  wire        vga_clk,   // VGA working clock, 25MHz
    input  wire        sys_rst_n, // Reset signal. Low level is effective
    input  wire [9:0]  pix_x,     // X coordinate of current pixel
    input  wire [9:0]  pix_y,     // Y coordinate of current pixel
    output reg  [15:0] pix_data   // Color information (RGB565)
);
    // Screen valid size
    localparam H_VALID = 10'd640;
    localparam V_VALID = 10'd480;

    // Bitmap size for "END"
    localparam integer BMP_W = 96;   // pixels
    localparam integer BMP_H = 32;   // lines
    localparam integer BYTES_PER_ROW = (BMP_W/8); // 12

    // Scale (power of two recommended)
    localparam integer SCALE_SHIFT = 2;           // 4x scale
    localparam integer SCALE       = (1 << SCALE_SHIFT);

    // Scaled bitmap size
    localparam integer BMP_W_SCALED = (BMP_W << SCALE_SHIFT); // 384
    localparam integer BMP_H_SCALED = (BMP_H << SCALE_SHIFT); // 128

    // Center position
    localparam integer ORG_X = (H_VALID - BMP_W_SCALED) >> 1; // 128
    localparam integer ORG_Y = (V_VALID - BMP_H_SCALED) >> 1; // 176

    // Colors
    localparam [15:0] FG = 16'hFFFF; // white
    localparam [15:0] BG = 16'h0000; // black

    // Return a 96-bit vector for the bitmap row r (0..31).
    function [95:0] bm_row;
        input [4:0] r; // row index 0..31
        begin
            case (r)
                // "END" bitmap data, 32 rows, 96 bits (12 bytes) per row
                5'd0:  bm_row = 96'h000000000000000000000000;
                5'd1:  bm_row = 96'h000000000000000000000000;
                5'd2:  bm_row = 96'h3FFFFF003E0078003FFF8000;
                5'd3:  bm_row = 96'h3FFFFF003F0078003FFFC000;
                5'd4:  bm_row = 96'h3FFFFF003F0078003FFFE000;
                5'd5:  bm_row = 96'h3C0000003F8078003C03F000;
                5'd6:  bm_row = 96'h3C0000003FC078003C01F800;
                5'd7:  bm_row = 96'h3C0000003FC078003C00F800;
                5'd8:  bm_row = 96'h3C0000003FE078003C007C00;
                5'd9:  bm_row = 96'h3C0000003FF078003C007C00;
                5'd10: bm_row = 96'h3C0000003DF078003C007C00;
                5'd11: bm_row = 96'h3C0000003DF878003C007C00;
                5'd12: bm_row = 96'h3FFFFE003CF878003C007C00;
                5'd13: bm_row = 96'h3FFFFE003C7C78003C003C00;
                5'd14: bm_row = 96'h3FFFFE003C7E78003C007C00;
                5'd15: bm_row = 96'h3C0000003C3F78003C007C00;
                5'd16: bm_row = 96'h3C0000003C1F78003C007C00;
                5'd17: bm_row = 96'h3C0000003C1FF8003C007C00;
                5'd18: bm_row = 96'h3C0000003C0FF8003C007C00;
                5'd19: bm_row = 96'h3C0000003C07F8003C00F800;
                5'd20: bm_row = 96'h3C0000003C07F8003C01F800;
                5'd21: bm_row = 96'h3C0000003C03F8003C07F000;
                5'd22: bm_row = 96'h3FFFFF003C01F8003FFFE000;
                5'd23: bm_row = 96'h3FFFFF003C01F8003FFFC000;
                5'd24: bm_row = 96'h3FFFFF003C00F8003FFF8000;
                5'd25: bm_row = 96'h000000000000000000000000;
                5'd26: bm_row = 96'h000000000000000000000000;
                5'd27: bm_row = 96'h000000000000000000000000;
                5'd28: bm_row = 96'h000000000000000000000000;
                5'd29: bm_row = 96'h000000000000000000000000;
                5'd30: bm_row = 96'h000000000000000000000000;
                5'd31: bm_row = 96'h000000000000000000000000;
                default: bm_row = 96'h00;
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
    wire [4:0] row = ly[9:SCALE_SHIFT]; // 0..31
    wire [6:0] col = lx[9:SCALE_SHIFT]; // 0..95

    // Combinational color generation; registered on vga_clk to match pipeline
    reg [95:0] row_bits96;
    reg [15:0] next_pix;

    always @* begin
        if (in_area) begin
            row_bits96 = bm_row(row);
            next_pix   = row_bits96[95 - col] ? FG : BG;
        end else begin
            next_pix   = BG;
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