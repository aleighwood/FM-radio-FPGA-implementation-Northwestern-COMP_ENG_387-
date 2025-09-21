//include "tap_weights_pkg.sv"
//import tap_weights_pkg::*;





module fir_top#(DATA_WIDTH = 32

) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full,
    input  logic        in_wr_en,
    input  logic [DATA_WIDTH-1:0] in_din,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [DATA_WIDTH-1:0]  out_dout
);

logic [DATA_WIDTH-1:0] in_dout;
logic        in_empty;
logic        in_rd_en;
logic  [DATA_WIDTH-1:0] out_din;
logic        out_full;
logic        out_wr_en;

localparam logic [31:0] AUDIO_LPR_COEFFS [0:31] =
{
	32'hfffffffd, 32'hfffffffa, 32'hfffffff4, 32'hffffffed, 32'hffffffe5, 32'hffffffdf, 32'hffffffe2, 32'hfffffff3, 
	32'h00000015, 32'h0000004e, 32'h0000009b, 32'h000000f9, 32'h0000015d, 32'h000001be, 32'h0000020e, 32'h00000243, 
	32'h00000243, 32'h0000020e, 32'h000001be, 32'h0000015d, 32'h000000f9, 32'h0000009b, 32'h0000004e, 32'h00000015, 
	32'hfffffff3, 32'hffffffe2, 32'hffffffdf, 32'hffffffe5, 32'hffffffed, 32'hfffffff4, 32'hfffffffa, 32'hfffffffd
};

localparam logic [31:0] audio_lpr_coeffs [0:31] = AUDIO_LPR_COEFFS;


fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .TAP_WEIGHTS(audio_lpr_coeffs),
    .AUDIO_DEC(8)
) fir_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
    //.tap_weights(audio_lpr_coeffs)
);

fifo #(
    //.FIFO_BUFFER_SIZE(256),
    .FIFO_BUFFER_SIZE(512),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_in_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(in_din),
    .full(in_full),
    .rd_clk(clock),
    .rd_en(in_rd_en),
    .dout(in_dout),
    .empty(in_empty)
);

fifo #(
    //.FIFO_BUFFER_SIZE(256),
    .FIFO_BUFFER_SIZE(512),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_out_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .din(out_din),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_dout),
    .empty(out_empty)
);

endmodule