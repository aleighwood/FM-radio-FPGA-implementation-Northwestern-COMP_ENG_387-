// `include "tap_weights_pkg.sv"




module fir_complex_top #(
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter DATA_WIDTH = 16,
    parameter TAPS = 20
   
)
(
    input logic clock, 
    input logic reset,
    output logic I_in_full,
    output logic Q_in_full,
    input logic I_in_wr_en,
    input logic Q_in_wr_en,
    input logic [DATA_WIDTH-1:0] I_din,
    input logic [DATA_WIDTH-1:0] Q_din,
    output logic Q_out_empty,
    output logic I_out_empty,
    input logic Q_out_rd_en,
    input logic I_out_rd_en,
    output logic [DATA_WIDTH-1:0] I_dout,
    output logic [DATA_WIDTH-1:0] Q_dout
);


//logic I_wr_en, Q_wr_en;
//logic I_rd_en, Q_rd_en;

localparam logic [31:0] CHANNEL_COEFFS_REAL[0:19] =
{
	32'h00000001, 32'h00000008, 32'hfffffff3, 32'h00000009, 32'h0000000b, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 
	32'hffffffb1, 32'h00000257, 32'h00000257, 32'hffffffb1, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 32'h0000000b, 
	32'h00000009, 32'hfffffff3, 32'h00000008, 32'h00000001
};


localparam logic [31:0] CHANNEL_COEFFS_IMAG[0:19] =
{
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000
};

logic [DATA_WIDTH-1:0] I_in_dout, Q_in_dout;
logic [DATA_WIDTH-1:0] fir_I_dout, fir_Q_dout;

//input fifo signals
logic I_in_rd_en, Q_in_rd_en;
logic Q_in_empty, I_in_empty;

//output fifo signals
logic I_out_wr_en, Q_out_wr_en;
logic I_out_full, Q_out_full;

localparam logic [31:0] fir_complex_real_coeffs [0:19] = CHANNEL_COEFFS_REAL;
localparam logic [31:0] fir_complex_imag_coeffs [0:19] = CHANNEL_COEFFS_IMAG;



// combine input FIFO signals to testbench
//logic I_full, Q_full;
//assign in_full = I_full && Q_full; 


//combine signals from fir to input FIFOs
//logic fir_cmplx_rd_en;

//logic in_empty,I_in_empty, Q_in_empty;;
//assign in_empty = I_in_empty && Q_in_empty;

//logic out_full, I_out_full, Q_out_full;
//assign out_full = I_out_full && Q_out_full;

//combine signals from fir_complex to output FIFO
//logic out_wr_en,I_out_empty, Q_out_empty;
//assign out_empty = I_out_empty && Q_out_empty;


// input I FIFO 
fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) input_I_FIFO (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(I_in_wr_en),
    .din(I_din),
    .full(I_in_full),
    .rd_clk(clock),
    .rd_en(I_in_rd_en),
    .dout(I_in_dout),
    .empty(I_in_empty)
);


// input Q FIFO
fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) input_Q_FIFO (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(Q_in_wr_en),
    .din(Q_din),
    .full(Q_in_full),
    .rd_clk(clock),
    .rd_en(Q_in_rd_en),
    .dout(Q_in_dout),
    .empty(Q_in_empty)
);

// FIR module 

fir_complex #(.DATA_WIDTH(DATA_WIDTH),
    .TAPS(TAPS),
    .CHANNEL_WEIGHTS_REAL(fir_complex_real_coeffs),
    .CHANNEL_WEIGHTS_IMAG(fir_complex_imag_coeffs)
)
fir_complex_inst(
    .reset(reset),
    .clock(clock),
    .I_din(I_in_dout),
    .Q_din(Q_in_dout),
    .Q_in_empty(Q_in_empty),
    .I_in_empty(I_in_empty),
    .I_in_rd_en(I_in_rd_en),
    .Q_in_rd_en(Q_in_rd_en),
    .Q_out_wr_en(Q_out_wr_en),
    .I_out_wr_en(I_out_wr_en),
    .Q_out_full(Q_out_full),
    .I_out_full(I_out_full),
    .I_dout(fir_I_dout),
    .Q_dout(fir_Q_dout)

);

//output I FIFO
fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) I_output_FIFO (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(I_out_wr_en),
    .din(fir_I_dout),
    .full(I_out_full),
    .rd_clk(clock),
    .rd_en(I_out_rd_en),
    .dout(I_dout),
    .empty(I_out_empty)
);


// output Q FIFO

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) Q_output_FIFO (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(Q_out_wr_en),
    .din(fir_Q_dout),
    .full(Q_out_full),
    .rd_clk(clock),
    .rd_en(Q_out_rd_en),
    .dout(Q_dout),
    .empty(Q_out_empty)
);

endmodule