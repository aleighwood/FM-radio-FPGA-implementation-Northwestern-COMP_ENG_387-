import uvm_pkg::*;

interface my_uvm_if;
    logic        clock;
    logic        reset;
    logic        in_full;
    logic        in_wr_en;
    logic [31:0] in_din;
    logic        out_left_empty;
    logic        out_left_rd_en;
    logic  [31:0] out_left_dout;
    logic        out_right_empty;
    logic        out_right_rd_en;
    logic  [31:0] out_right_dout;
endinterface
