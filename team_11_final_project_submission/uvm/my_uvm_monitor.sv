import uvm_pkg::*;


// Reads data from output fifo to scoreboard
class my_uvm_monitor_output extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_output)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_output;

    virtual my_uvm_if vif;
    int out_left_file;
    int out_right_file;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_output = new(.name("mon_ap_output"), .parent(this));

        out_left_file = $fopen(OUT_LEFT_NAME, "wb");
        out_right_file = $fopen(OUT_RIGHT_NAME, "wb");

        if ( !out_left_file ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", OUT_LEFT_NAME));
        end
        if ( !out_right_file ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", OUT_RIGHT_NAME));
        end
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_bytes;
        my_uvm_transaction tx_out;
        logic signed [31:0] data;

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_out = my_uvm_transaction::type_id::create(.name("tx_out"), .contxt(get_full_name()));


        vif.out_left_rd_en = 1'b0;
        vif.out_right_rd_en = 1'b0;

        forever begin
            @(negedge vif.clock)
            begin
                if (vif.out_left_empty == 1'b0 && vif.out_right_empty == 1'b0) begin

                    $fwrite(out_left_file, "%h\n", vif.out_left_dout);
                    $fwrite(out_right_file, "%h\n", vif.out_right_dout);
                    tx_out.left = vif.out_left_dout;
                    tx_out.right = vif.out_right_dout;
                    mon_ap_output.write(tx_out);
                    vif.out_left_rd_en = 1'b1;
                    vif.out_right_rd_en = 1'b1;
                end else begin
                    vif.out_left_rd_en = 1'b0;
                    vif.out_right_rd_en = 1'b0;
                end
            end
        end
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", OUT_LEFT_NAME), UVM_LOW);
        $fclose(out_left_file);
        super.final_phase(phase);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", OUT_RIGHT_NAME), UVM_LOW);
        $fclose(out_right_file);
    endfunction: final_phase

endclass: my_uvm_monitor_output


// Reads data from compare file to scoreboard
class my_uvm_monitor_compare extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_compare)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_compare;
    virtual my_uvm_if vif;
    int cmp_left_file, cmp_right_file,n_bytes;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_compare = new(.name("mon_ap_compare"), .parent(this));

        cmp_left_file = $fopen(LEFT_CMP_NAME, "rb");
        if ( !cmp_left_file ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", LEFT_CMP_NAME));
        end

        cmp_right_file = $fopen(RIGHT_CMP_NAME, "rb");
        if ( !cmp_right_file ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", RIGHT_CMP_NAME));
        end

        // store the BMP header as packed array
        // n_bytes = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
        // uvm_config_db#(logic[0:BMP_HEADER_SIZE-1][7:0])::set(null, "*", "bmp_header", {>> 8{bmp_header}});
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_bytes=0, i=0;
        logic [31:0] val;
        my_uvm_transaction tx_cmp;
        string line;

        // extend the run_phase 20 clock cycles
        phase.phase_done.set_drain_time(this, (CLOCK_PERIOD*20));

        // notify that run_phase has started
        phase.raise_objection(.obj(this));

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_cmp = my_uvm_transaction::type_id::create(.name("tx_cmp"), .contxt(get_full_name()));

        // syncronize file read with fifo data
        while ( !$feof(cmp_right_file)  && !$feof(cmp_left_file) && i < TEST_OUT_LENGTH) begin
            @(negedge vif.clock)
            begin
                if ( vif.out_left_empty == 1'b0 && vif.out_right_empty == 1'b0) begin

                    void'($fgets(line, cmp_left_file));
                    $sscanf(line, "%h",val);
                    // $fscanf(line, "%h",val);
                    tx_cmp.left = val;

                    void'($fgets(line, cmp_right_file));
                    $sscanf(line, "%h",val);
                    // $fscanf(line, "%h",val);
                    tx_cmp.right = val;

                    mon_ap_compare.write(tx_cmp);
                    i += 1;
                end
            end
        end        

        // notify that run_phase has completed
        phase.drop_objection(.obj(this));
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", LEFT_CMP_NAME), UVM_LOW);
        $fclose(cmp_left_file);
                `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", RIGHT_CMP_NAME), UVM_LOW);
        $fclose(cmp_right_file);
    endfunction: final_phase

endclass: my_uvm_monitor_compare
