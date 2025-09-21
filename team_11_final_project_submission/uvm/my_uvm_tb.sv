
import uvm_pkg::*;
import my_uvm_package::*;

`include "my_uvm_if.sv"

`timescale 1 ns / 1 ns

module my_uvm_tb;

    my_uvm_if vif();

    // placeholder_top #(
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    // ) placeholder_top_inst (
    //     .clock(vif.clock),
    //     .reset(vif.reset),
    //     .in_full(vif.in_full),
    //     .in_wr_en(vif.in_wr_en),
    //     .in_din(vif.in_din),
    //     .out_left_empty(vif.out_left_empty),
    //     .out_left_rd_en(vif.out_left_rd_en),
    //     .out_left_dout(vif.out_left_dout),
    //     .out_right_empty(vif.out_right_empty),
    //     .out_right_rd_en(vif.out_right_rd_en),
    //     .out_right_dout(vif.out_right_dout)

        
    // );

    // read_IQ_top #(
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    // ) read_IQ_top_inst (
    //     .clock(vif.clock),
    //     .reset(vif.reset),
    //     .in_full(vif.in_full),
    //     .in_wr_en(vif.in_wr_en),
    //     .in_din(vif.in_din),
    //     .Q_rd_en(vif.out_left_rd_en),
    //     .Q_empty(vif.out_left_empty),
    //     .Q_dout(vif.out_left_dout),
    //     .I_rd_en(vif.out_right_rd_en),
    //     .I_empty(vif.out_right_empty),
    //     .I_dout(vif.out_right_dout)
    // );

    
    radio_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
        .TAPS(20)
    ) radio_top_inst (
        .clock(vif.clock),
        .reset(vif.reset),
        .in_full(vif.in_full),
        .in_wr_en(vif.in_wr_en),
        .in_din(vif.in_din),
        .out_left_rd_en(vif.out_left_rd_en),
        .out_left_empty(vif.out_left_empty),
        .out_left_dout(vif.out_left_dout),
        .out_right_rd_en(vif.out_right_rd_en),
        .out_right_empty(vif.out_right_empty),
        .out_right_dout(vif.out_right_dout)
    );

    initial begin
        // store the vif so it can be retrieved by the driver & monitor
        uvm_resource_db#(virtual my_uvm_if)::set
            (.scope("ifs"), .name("vif"), .val(vif));

        // run the test
        run_test("my_uvm_test");        
    end

    // reset
    initial begin
        vif.clock <= 1'b1;
        vif.reset <= 1'b0;
        @(posedge vif.clock);
        vif.reset <= 1'b1;
        @(posedge vif.clock);
        vif.reset <= 1'b0;
    end

    // 10ns clock
    always
        #(CLOCK_PERIOD/2) vif.clock = ~vif.clock;
endmodule






