import uvm_pkg::*;

class my_uvm_driver extends uvm_driver#(my_uvm_transaction);

    `uvm_component_utils(my_uvm_driver)

    virtual my_uvm_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        drive();
    endtask: run_phase

    virtual task drive();
        my_uvm_transaction tx;

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        vif.in_din = 32'b0;
        vif.in_wr_en = 1'b0;

        forever begin
            @(negedge vif.clock) 
            begin         
                // $display("vif in full: %d", vif.in_full);
                if (vif.in_full == 1'b0) begin
                    // $display("vif in not full");
                    seq_item_port.get_next_item(tx);
                    vif.in_din = tx.val;
                    vif.in_wr_en = 1'b1;
                    // $display("value: %h", vif.in_din);
                    seq_item_port.item_done();
                end else begin
                    vif.in_wr_en = 1'b0;
                    vif.in_din = 32'b0;
                end
            end
        end
    endtask: drive

endclass
