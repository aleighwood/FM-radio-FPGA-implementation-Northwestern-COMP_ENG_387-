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
   
    int error_count = 0;  // Error counter
    time start_time, end_time;  // Simulation timing variables

    function new(string name, uvm_component parent);
        super.new(name, parent);
        tx_out = new("tx_out");
        tx_cmp = new("tx_cmp");
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sb_export_output = new("sb_export_output", this);
        sb_export_compare = new("sb_export_compare", this);

        output_fifo = new("output_fifo", this);
        compare_fifo = new("compare_fifo", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        sb_export_output.connect(output_fifo.analysis_export);
        sb_export_compare.connect(compare_fifo.analysis_export);
    endfunction: connect_phase

    virtual task run();
        start_time = $time; // ✅ Capture simulation start time

        forever begin
            output_fifo.get(tx_out);
            compare_fifo.get(tx_cmp);            
            comparison();
        end
    endtask: run

    virtual function void comparison();
        if (tx_out.right != tx_cmp.right) begin
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.right, tx_out.right))
            error_count++;
        end

        if (tx_out.left != tx_cmp.left) begin
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.left, tx_out.left))
            error_count++;
        end
    endfunction: comparison

    virtual function void end_of_simulation_phase(uvm_phase phase);
        end_time = $time; // ✅ Capture simulation end time

        // ✅ Print total simulation time
        `uvm_info("SIM_TIME", $sformatf("Total Simulation Time: %0t", end_time - start_time), UVM_MEDIUM)

        `uvm_info("SB_CMP", $sformatf("Total number of errors: %0d", error_count), UVM_MEDIUM)
    endfunction: end_of_simulation_phase

endclass: my_uvm_scoreboard