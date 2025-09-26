
module read_IQ_top #( 
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter DATA_WIDTH = 32
 )
(
    input  logic clock,
    input  logic reset,
    output logic in_full,
    input  logic in_wr_en,
    input  logic [7:0] in_din,
    input  logic I_rd_en,
    output logic I_empty,
    output logic [DATA_WIDTH-1:0] I_dout,
    input  logic Q_rd_en,
    output logic Q_empty,
    output logic [DATA_WIDTH-1:0] Q_dout
);


logic in_rd_en;
logic in_empty;
logic [7:0] in_dout;

logic [DATA_WIDTH-1:0] Q_din;
logic Q_wr_en;
logic Q_full;

logic [DATA_WIDTH-1:0] I_din;
logic I_wr_en;
logic I_full;

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


read_IQ #(
  .DATA_WIDTH(DATA_WIDTH)
) read_IQ_inst (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .I_din(I_din),
    .I_wr_en(I_wr_en),
    .I_full(I_full),
    .Q_din(Q_din),
    .Q_wr_en(Q_wr_en),
    .Q_full(Q_full)
);



fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) I_out_inst (
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
) Q_out_inst (
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

endmodule