import uvm_pkg::*;


class my_uvm_transaction extends uvm_sequence_item;
    logic [31:0] val;
    logic [31:0] left;
    logic [31:0] right;
    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(my_uvm_transaction)
        `uvm_field_int(val, UVM_ALL_ON)
        `uvm_field_int(left, UVM_ALL_ON)

        `uvm_field_int(right, UVM_ALL_ON)

    `uvm_object_utils_end
endclass: my_uvm_transaction


class my_uvm_sequence extends uvm_sequence#(my_uvm_transaction);
    `uvm_object_utils(my_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        my_uvm_transaction tx;
        int in_file, n_bytes=0, it=0;
        string line;
        logic signed [31:0] input_val;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", IN_NAME), UVM_LOW);

        in_file = $fopen(IN_NAME, "rb");
        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", IN_NAME));
        end

        $display("before loop");
        while ( !$feof(in_file) && it < TEST_LENGTH ) begin
            // $display("in loop");
            tx = my_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
            // $display("before start");
            start_item(tx);
            void'($fgets(line, in_file));
            $sscanf(line, "%h",input_val);
            // $display("input_val: %h",input_val );
            tx.val = input_val;
            finish_item(tx);
            it += 1;
            // $display("i = %d", i);
        end

        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", IN_NAME), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: my_uvm_sequence

typedef uvm_sequencer#(my_uvm_transaction) my_uvm_sequencer;
