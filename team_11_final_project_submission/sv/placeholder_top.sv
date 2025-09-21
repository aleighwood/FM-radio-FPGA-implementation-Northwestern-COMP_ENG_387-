
module placeholder_top #(  
    parameter DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 32)
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
);

logic [DATA_WIDTH-1:0] in_dout, out_left_din,out_right_din;
logic in_empty,  out_left_full, out_right_full;
logic in_rd_en,  out_left_wr_en, out_right_wr_en;

placeholder #(
  .DATA_WIDTH(DATA_WIDTH)
) placeholder_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .out_left_din(out_left_din),
    .out_left_full(out_left_full),
    .out_left_wr_en(out_left_wr_en),
    .out_right_din(out_right_din),
    .out_right_full(out_right_full),
    .out_right_wr_en(out_right_wr_en)
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
) left_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_left_wr_en),
    .din(out_left_din),
    .full(out_left_full),
    .rd_clk(clock),
    .rd_en(out_left_rd_en),
    .dout(out_left_dout),
    .empty(out_left_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) right_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_right_wr_en),
    .din(out_right_din),
    .full(out_right_full),
    .rd_clk(clock),
    .rd_en(out_right_rd_en),
    .dout(out_right_dout),
    .empty(out_right_empty)
);

endmodule