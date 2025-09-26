
module sub_top #(  
    parameter DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 32)
(
    input  logic clock,
    input  logic reset,
    output logic I_full,
    input  logic I_wr_en,
    input  logic [DATA_WIDTH-1:0] I_din,
    output logic Q_full,
    input  logic Q_wr_en,
    input  logic [DATA_WIDTH-1:0] Q_din,
    input  logic out_rd_en,
    output logic out_empty,
    output logic [DATA_WIDTH-1:0] out_dout
);

logic [DATA_WIDTH-1:0] I_dout, Q_dout, out_din;
logic I_empty, Q_empty, out_full;
logic I_rd_en, Q_rd_en, out_wr_en;

sub #(
  .DATA_WIDTH(DATA_WIDTH)
) sub_inst (
    .clock(clock),
    .reset(reset),
    .I_dout(I_dout),
    .I_rd_en(I_rd_en),
    .I_empty(I_empty),
    .Q_dout(Q_dout),
    .Q_rd_en(Q_rd_en),
    .Q_empty(Q_empty),
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
) Q_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(Q_wr_en),
    .din(Q_din),
    .full(Q_full),
    .rd_clk(clock),
    .rd_en(Q_rd_en),
    .dout(Q_dout),
    .empty(Q_empty)
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