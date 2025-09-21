
module qarctan_top #(  
    parameter DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 32)
(
    input  logic clock,
    input  logic reset,
    output logic I_full,
    input  logic I_wr_en,
    input  logic signed [DATA_WIDTH-1:0] I_din,
    output logic R_full,
    input  logic R_wr_en,
    input  logic signed [DATA_WIDTH-1:0] R_din,
    input  logic out_rd_en,
    output logic out_empty,
    output logic [DATA_WIDTH-1:0] out_dout
);

logic signed [DATA_WIDTH-1:0] I_dout, R_dout, out_din;
logic I_empty, R_empty, out_full;
logic I_rd_en, R_rd_en, out_wr_en;

qarctan #(
  .DATA_WIDTH(DATA_WIDTH)
) qarctan_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(I_dout),
    .I_rd_en(I_rd_en),
    .I_empty(I_empty),
    .R_dout(R_dout),
    .R_rd_en(R_rd_en),
    .R_empty(R_empty),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) I_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(I_wr_en),
    .din(I_din),
    .full(I_full),
    .rd_clk(clock),
    .rd_en(I_rd_en),
    .dout(I_dout),
    .empty(I_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) R_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(R_wr_en),
    .din(R_din),
    .full(R_full),
    .rd_clk(clock),
    .rd_en(R_rd_en),
    .dout(R_dout),
    .empty(R_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) out_inst (
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