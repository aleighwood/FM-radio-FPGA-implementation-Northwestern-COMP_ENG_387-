// `include "tap_weights_pkg.sv"
//`include "quant_function_pkg.sv"
// import tap_weights_pkg::*;
//import quant_function_pkg::*;
localparam [31:0] CHANNEL_COEFFS_REAL[0:19] =
{
	32'h00000001, 32'h00000008, 32'hfffffff3, 32'h00000009, 32'h0000000b, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 
	32'hffffffb1, 32'h00000257, 32'h00000257, 32'hffffffb1, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 32'h0000000b, 
	32'h00000009, 32'hfffffff3, 32'h00000008, 32'h00000001
};


localparam [31:0] CHANNEL_COEFFS_IMAG[0:19] =
{
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000
};
//FIR 5
// L+R low-pass FIR filter 
localparam [31:0] AUDIO_LPR_COEFFS [0:31] =
{
	32'hfffffffd, 32'hfffffffa, 32'hfffffff4, 32'hffffffed, 32'hffffffe5, 32'hffffffdf, 32'hffffffe2, 32'hfffffff3, 
	32'h00000015, 32'h0000004e, 32'h0000009b, 32'h000000f9, 32'h0000015d, 32'h000001be, 32'h0000020e, 32'h00000243, 
	32'h00000243, 32'h0000020e, 32'h000001be, 32'h0000015d, 32'h000000f9, 32'h0000009b, 32'h0000004e, 32'h00000015, 
	32'hfffffff3, 32'hffffffe2, 32'hffffffdf, 32'hffffffe5, 32'hffffffed, 32'hfffffff4, 32'hfffffffa, 32'hfffffffd
};

//FIR 1
// L-R band-pass filter 
localparam [31:0] BP_LMR_COEFFS[0:31] =
{
	32'h00000000, 32'h00000000, 32'hfffffffc, 32'hfffffff9, 32'hfffffffe, 32'h00000008, 32'h0000000c, 32'h00000002, 
	32'h00000003, 32'h0000001e, 32'h00000030, 32'hfffffffc, 32'hffffff8c, 32'hffffff58, 32'hffffffc3, 32'h0000008a, 
	32'h0000008a, 32'hffffffc3, 32'hffffff58, 32'hffffff8c, 32'hfffffffc, 32'h00000030, 32'h0000001e, 32'h00000003, 
	32'h00000002, 32'h0000000c, 32'h00000008, 32'hfffffffe, 32'hfffffff9, 32'hfffffffc, 32'h00000000, 32'h00000000
};

//FIR 2
// Pilot band-pass filter extracts the 19kHz pilot tone 
localparam [31:0] BP_PILOT_COEFFS[0:31] =
{
	32'h0000000e, 32'h0000001f, 32'h00000034, 32'h00000048, 32'h0000004e, 32'h00000036, 32'hfffffff8, 32'hffffff98, 
	32'hffffff2d, 32'hfffffeda, 32'hfffffec3, 32'hfffffefe, 32'hffffff8a, 32'h0000004a, 32'h0000010f, 32'h000001a1, 
	32'h000001a1, 32'h0000010f, 32'h0000004a, 32'hffffff8a, 32'hfffffefe, 32'hfffffec3, 32'hfffffeda, 32'hffffff2d, 
	32'hffffff98, 32'hfffffff8, 32'h00000036, 32'h0000004e, 32'h00000048, 32'h00000034, 32'h0000001f, 32'h0000000e
};

//FIR 3
// high-pass filter removes the tone at 0Hz created after the pilot tone is squared 
localparam [31:0] HP_COEFFS[0:31] =
{
	32'hffffffff, 32'h00000000, 32'h00000000, 32'h00000002, 32'h00000004, 32'h00000008, 32'h0000000b, 32'h0000000c, 
	32'h00000008, 32'hffffffff, 32'hffffffee, 32'hffffffd7, 32'hffffffbb, 32'hffffff9f, 32'hffffff87, 32'hffffff76, 
	32'hffffff76, 32'hffffff87, 32'hffffff9f, 32'hffffffbb, 32'hffffffd7, 32'hffffffee, 32'hffffffff, 32'h00000008, 
	32'h0000000c, 32'h0000000b, 32'h00000008, 32'h00000004, 32'h00000002, 32'h00000000, 32'h00000000, 32'hffffffff
};

//FIR 4
localparam [31:0] AUDIO_LMR_COEFFS[0:31] =
{
	32'hfffffffd, 32'hfffffffa, 32'hfffffff4, 32'hffffffed, 32'hffffffe5, 32'hffffffdf, 32'hffffffe2, 32'hfffffff3, 
	32'h00000015, 32'h0000004e, 32'h0000009b, 32'h000000f9, 32'h0000015d, 32'h000001be, 32'h0000020e, 32'h00000243, 
	32'h00000243, 32'h0000020e, 32'h000001be, 32'h0000015d, 32'h000000f9, 32'h0000009b, 32'h0000004e, 32'h00000015, 
    32'hfffffff3, 32'hffffffe2, 32'hffffffdf, 32'hffffffe5, 32'hffffffed, 32'hfffffff4, 32'hfffffffa, 32'hfffffffd
};




module radio_top #( 
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter DATA_WIDTH = 32,
    parameter TAPS = 20
 )
(
    input  logic clock,
    input  logic reset,
    output logic in_full,
    input  logic in_wr_en,
    input  logic [DATA_WIDTH-1:0] in_din,
    input  logic out_left_rd_en,
    output logic out_left_empty,
    output logic [DATA_WIDTH-1:0] out_left_dout,
    input  logic out_right_rd_en,
    output logic out_right_empty,
    output logic [DATA_WIDTH-1:0] out_right_dout
   // output logic demod_out
);

//localparam DATA_WIDTH =32;
//localparam int BITS = 10;
//localparam int QUANT_VAL = (1 << BITS);

localparam logic [31:0] fir_five_coeffs [0:31] = AUDIO_LPR_COEFFS;
localparam logic [31:0] fir_four_coeffs [0:31] = AUDIO_LMR_COEFFS;

localparam logic [31:0] fir_three_coeffs [0:31] = HP_COEFFS;
localparam logic [31:0] fir_two_coeffs [0:31] = BP_PILOT_COEFFS;
localparam logic [31:0] fir_one_coeffs [0:31] = BP_LMR_COEFFS;

localparam logic [31:0] fir_complex_real_coeffs [0:19] = CHANNEL_COEFFS_REAL;
localparam logic [31:0] fir_complex_imag_coeffs [0:19] = CHANNEL_COEFFS_IMAG;

//logic [DATA_WIDTH-1:0] demod_out;
//logic [DATA_WIDTH-1:0] demod_out_wr_en;

logic [20:0] rd_en;
logic [20:0] empty;
logic signed [20:0] [DATA_WIDTH-1:0] dout;

logic signed [20:0] [DATA_WIDTH-1:0] din;
logic [20:0] wr_en;
logic [20:0] full;
logic signed [DATA_WIDTH-1:0] in_dout;

logic in_rd_en, in_empty;
logic output_left_wr_en, output_left_full;
logic signed [DATA_WIDTH-1:0] output_left_din;

logic output_right_wr_en, output_right_full;
logic signed [DATA_WIDTH-1:0] output_right_din;

assign demod_out = din[4];
assign demod_out_wr_en = wr_en[4];

logic demod_full;
assign demod_full = full[4] || full[5] || full[6];

logic fir_four_full, fir_five_full, fir_two_full;
assign fir_four_full = full[13] || full[14];
assign fir_five_full = full[15] || full[16];
assign fir_two_full = full[7] || full[8];

assign din[8] = din[7];
assign wr_en[8] = wr_en[7];
assign din[5] = din[4];
assign wr_en[5] = wr_en[4];
assign din[6] = din[4];
assign wr_en[6] = wr_en[4];
assign din[14] = din[13];
assign wr_en[14] = wr_en[13]; 
assign din[16] = din[15];
assign wr_en[16] = wr_en[15]; 
// assign full[8]
// assign full[5] = full[4];

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) in_inst (
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


generate
    for (genvar i = 0; i < 21; i++) begin : fifo_gen

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(wr_en[i]),
    .din(din[i]),
    .full(full[i]),
    .rd_clk(clock),
    .rd_en(rd_en[i]),
    .dout(dout[i]),
    .empty(empty[i])
);

end
endgenerate



read_IQ #(
  .DATA_WIDTH(DATA_WIDTH)
) read_IQ_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .I_din(din[0]),
    .I_wr_en(wr_en[0]),
    .I_full(full[0]),
    .Q_din(din[1]),
    .Q_wr_en(wr_en[1]),
    .Q_full(full[1])
);


fir_complex #(.DATA_WIDTH(DATA_WIDTH),
    .TAPS(TAPS),
    .CHANNEL_WEIGHTS_REAL(fir_complex_real_coeffs),
    .CHANNEL_WEIGHTS_IMAG(fir_complex_imag_coeffs)
)
fir_complex_inst(
    .reset(reset),
    .clock(clock),
    .I_din(dout[0]),
    .Q_din(dout[1]),
    .I_in_empty(empty[0]),
    .I_in_rd_en(rd_en[0]),
    .I_out_wr_en(wr_en[2]),
    .Q_in_empty(empty[1]),
    .Q_in_rd_en(rd_en[1]),
    .Q_out_wr_en(wr_en[3]),
    .I_dout(din[2]),
    .Q_dout(din[3]),
    .I_out_full(full[2]),
    .Q_out_full(full[3])
);

demod #(
  .DATA_WIDTH(DATA_WIDTH)
) demod_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(dout[2]),
    .I_rd_en(rd_en[2]),
    .I_empty(empty[2]),
    .Q_dout(dout[3]),
    .Q_rd_en(rd_en[3]),
    .Q_empty(empty[3]),
    .out_din(din[4]),
    .out_full(demod_full), // five is missing
    .out_wr_en(wr_en[4])
);

fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .TAP_WEIGHTS(fir_one_coeffs)
) fir_one_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(dout[4]),
    .in_rd_en(rd_en[4]),
    .in_empty(empty[4]),
    .out_din(din[11]),
    .out_full(full[11]),
    .out_wr_en(wr_en[11])
);

fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .TAP_WEIGHTS(fir_two_coeffs)
) fir_two_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(dout[5]),
    .in_rd_en(rd_en[5]),
    .in_empty(empty[5]),
    .out_din(din[7]),
    .out_full(fir_two_full ), // missing 8
    .out_wr_en(wr_en[7])
);

mult #(
  .DATA_WIDTH(DATA_WIDTH)
) mult_one_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(dout[7]),
    .I_rd_en(rd_en[7]),
    .I_empty(empty[7]),
    .Q_dout(dout[8]),
    .Q_rd_en(rd_en[8]),
    .Q_empty(empty[8]),
    .out_din(din[9]),
    .out_full(full[9]),
    .out_wr_en(wr_en[9])
);


fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .TAP_WEIGHTS(fir_three_coeffs)
) fir_three_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(dout[9]),
    .in_rd_en(rd_en[9]),
    .in_empty(empty[9]),
    .out_din(din[10]),
    .out_full(full[10]),
    .out_wr_en(wr_en[10])
);

mult #(
  .DATA_WIDTH(DATA_WIDTH)
) mult_two_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(dout[11]),
    .I_rd_en(rd_en[11]),
    .I_empty(empty[11]),
    .Q_dout(dout[10]),
    .Q_rd_en(rd_en[10]),
    .Q_empty(empty[10]),
    .out_din(din[12]),
    .out_full(full[12]),
    .out_wr_en(wr_en[12])
);

fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .AUDIO_DEC(8),
    .TAP_WEIGHTS(fir_four_coeffs)
) fir_four_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(dout[12]),
    .in_rd_en(rd_en[12]),
    .in_empty(empty[12]),
    .out_din(din[13]),
    .out_full(fir_four_full),
    .out_wr_en(wr_en[13])
);

fir #(.TAPS(32),
    .DATA_WIDTH(DATA_WIDTH),
    .AUDIO_DEC(8),
    .TAP_WEIGHTS(fir_five_coeffs)
) fir_five_inst(
    .clock(clock),
    .reset(reset),
    .in_dout(dout[6]),
    .in_rd_en(rd_en[6]),
    .in_empty(empty[6]),
    .out_din(din[15]),
    .out_full(fir_five_full),
    .out_wr_en(wr_en[15])
);

sub #(
  .DATA_WIDTH(DATA_WIDTH)
) sub_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(dout[15]),
    .I_rd_en(rd_en[15]),
    .I_empty(empty[15]),
    .Q_dout(dout[14]),
    .Q_rd_en(rd_en[14]),
    .Q_empty(empty[14]),
    .out_din(din[18]),
    .out_full(full[18]),
    .out_wr_en(wr_en[18])
);

add #(
  .DATA_WIDTH(DATA_WIDTH)
) add_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(dout[13]),
    .I_rd_en(rd_en[13]),
    .I_empty(empty[13]),
    .Q_dout(dout[16]),
    .Q_rd_en(rd_en[16]),
    .Q_empty(empty[16]),
    .out_din(din[17]),
    .out_full(full[17]),
    .out_wr_en(wr_en[17])
);

deemph #(
  .DATA_WIDTH(DATA_WIDTH),
    .TAPS(2)
) deemph_left_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(dout[17]),
    .in_rd_en(rd_en[17]),
    .in_empty(empty[17]),
    .out_din(din[19]),
    .out_full(full[19]),
    .out_wr_en(wr_en[19])
);

deemph #(
  .DATA_WIDTH(DATA_WIDTH),
    .TAPS(2)
) deemph_right_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(dout[18]),
    .in_rd_en(rd_en[18]),
    .in_empty(empty[18]),
    .out_din(din[20]),
    .out_full(full[20]),
    .out_wr_en(wr_en[20])
);

gain #(
  .DATA_WIDTH(DATA_WIDTH)
) gain_left_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(dout[19]),
    .in_rd_en(rd_en[19]),
    .in_empty(empty[19]),
    .out_din(output_left_din),
    .out_full(output_left_full),
    .out_wr_en(output_left_wr_en)
);

gain #(
  .DATA_WIDTH(DATA_WIDTH)
) gain_right_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(dout[20]),
    .in_rd_en(rd_en[20]),
    .in_empty(empty[20]),
    .out_din(output_right_din),
    .out_full(output_right_full),
    .out_wr_en(output_right_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) out_left_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(output_left_wr_en),
    .din(output_left_din),
    .full(output_left_full),
    .rd_clk(clock),
    .rd_en(out_left_rd_en),
    .dout(out_left_dout),
    .empty(out_left_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) out_right_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(output_right_wr_en),
    .din(output_right_din),
    .full(output_right_full),
    .rd_clk(clock),
    .rd_en(out_right_rd_en),
    .dout(out_right_dout),
    .empty(out_right_empty)
);



endmodule