
module gain_top #(  
    parameter DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 32)
(
    input  logic clock,
    input  logic reset,
    output logic in_full,
    input  logic in_wr_en,
    input  logic [DATA_WIDTH-1:0] in_din,
    input  logic out_rd_en,
    output logic out_empty,
    output logic [DATA_WIDTH-1:0] out_dout
);

logic [DATA_WIDTH-1:0] in_dout, out_din;
logic in_empty,  out_full;
logic in_rd_en,  out_wr_en;

gain #(
  .DATA_WIDTH(DATA_WIDTH)
) gain_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

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