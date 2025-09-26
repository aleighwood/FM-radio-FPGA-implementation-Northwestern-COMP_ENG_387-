import uvm_pkg::*;

`uvm_analysis_imp_decl(_output)
`uvm_analysis_imp_decl(_compare)

class my_uvm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_uvm_scoreboard)

    uvm_analysis_export #(my_uvm_transaction) sb_export_output;
    uvm_analysis_export #(my_uvm_transaction) sb_export_compare;

    uvm_tlm_analysis_fifo #(my_uvm_transaction) output_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) compare_fifo;

    my_uvm_transaction tx_out;
    my_uvm_transaction tx_cmp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        tx_out    = new("tx_out");
        tx_cmp = new("tx_cmp");
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sb_export_output    = new("sb_export_output", this);
        sb_export_compare   = new("sb_export_compare", this);

           output_fifo        = new("output_fifo", this);
        compare_fifo    = new("compare_fifo", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        sb_export_output.connect(output_fifo.analysis_export);
        sb_export_compare.connect(compare_fifo.analysis_export);
    endfunction: connect_phase

    virtual task run();
        forever begin
            output_fifo.get(tx_out);
            compare_fifo.get(tx_cmp);            
            comparison();
        end
    endtask: run

    virtual function void comparison();
        if (tx_out.right != tx_cmp.right) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            // `uvm_info("SB_CMP", tx_out.sprint(), UVM_LOW);
            // `uvm_info("SB_CMP", tx_cmp.sprint(), UVM_LOW);
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.right, tx_out.right))
        end


        if (tx_out.left != tx_cmp.left) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            // `uvm_info("SB_CMP", tx_out.sprint(), UVM_LOW);
            // `uvm_info("SB_CMP", tx_cmp.sprint(), UVM_LOW);
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.left, tx_out.left))
        end
    endfunction: comparison
endclass: my_uvm_scoreboard
