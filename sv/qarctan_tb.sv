
`timescale 1 ns / 1 ns

module qarctan_tb ();

    localparam string I_NAME = "../test_files/arctan_i.txt";
    localparam string R_NAME = "../test_files/arctan_r.txt";
    localparam string OUT_NAME = "../test_files/arctan_angle.txt";
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 64;
    localparam FIFO_BUFFER_SIZE = 8;
    localparam CLOCK_PERIOD = 10;

    logic clock = 1'b0;
    logic reset = 1'b0;

    logic signed [DATA_WIDTH-1:0] I_din;
    logic I_wr_en, I_full;
    logic signed [DATA_WIDTH-1:0] R_din;
    logic R_wr_en, R_full;
    logic signed [DATA_WIDTH-1:0] out_dout;
    logic out_rd_en, out_empty;

    logic   I_write_done = '0;
    logic   R_write_done = '0;
    logic   out_read_done  = '0;
    integer out_errors     = '0;

    qarctan_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    ) qarctan_top_inst (
        .clock(clock),
        .reset(reset),
        .I_full(I_full),
        .I_wr_en(I_wr_en),
        .I_din(I_din),
        .R_full(R_full),
        .R_wr_en(R_wr_en),
        .R_din(R_din),
        .out_rd_en(out_rd_en),
        .out_empty(out_empty),
        .out_dout(out_dout)
    );

    // clock process
    always begin
        #(CLOCK_PERIOD/2) clock = 1'b1;
        #(CLOCK_PERIOD/2) clock = 1'b0;
    end

    // reset process
    initial begin
        #(CLOCK_PERIOD) reset = 1'b1;
        #(CLOCK_PERIOD) reset = 1'b0;
    end

    initial begin
        time start_time, end_time;

        @(negedge reset);
        @(posedge clock);
        start_time = $time;
        $display("@ %0t: Beginning simulation...", start_time);

        wait(out_read_done);

        end_time = $time;
        $display("@ %0t: Simulation completed.", end_time);
        $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
        $display("Total error count: %0d", out_errors);

        $stop;
    end

    initial begin : I_write
        integer fd, x, count;
        I_din = '0;
        I_wr_en = 1'b0;

        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, I_NAME);
        
        fd = $fopen(I_NAME, "r");

        x = 0;
        while ( x < 262144 ) begin
            @(negedge clock);
            I_wr_en = 1'b0;
            if (I_full == 1'b0) begin
                count = $fscanf(fd, "%h", I_din);
                I_wr_en = 1'b1;   
                x++;         
            end
        end

        @(posedge clock);
        I_wr_en = 1'b0;
        $fclose(fd);
        I_write_done = 1'b1;
    end

    initial begin : R_write
        integer fd, y, count;
        R_din = '0;
        R_wr_en = 1'b0;
        
        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, R_NAME);
        
        fd = $fopen(R_NAME, "r");

        y = 0;
        while ( y < 262144 ) begin
            @(negedge clock);
            R_wr_en = 1'b0;
            if (R_full == 1'b0) begin
                count = $fscanf(fd, "%h", R_din);
                R_wr_en = 1'b1; 
                y++;           
            end
        end

        @(posedge clock);
        R_wr_en = 1'b0;
        $fclose(fd);
        R_write_done = 1'b1;
    end

    initial begin : out_write
        integer fd, z, count;
        logic [DATA_WIDTH-1:0] out_data_cmp;
        out_rd_en = 1'b0;
        out_data_cmp = '0;

        @(negedge reset);
        @(negedge clock);

        $display("@ %0t: Comparing file %s...", $time, OUT_NAME);
        fd = $fopen(OUT_NAME, "r");

        z = 0;
        while ( z < 262144 ) begin
            @(negedge clock);            
            out_rd_en = 1'b0;
            if (out_empty == 1'b0) begin
                out_rd_en = 1'b1;
                count = $fscanf(fd, "%h", out_data_cmp);
                if (out_dout != out_data_cmp) begin
                    out_errors++;
                    $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%d.", $time, OUT_NAME, z+1, out_dout, out_data_cmp, z);
                end
                z++;
            end
        end
        out_rd_en = 1'b0;
        out_read_done = 1'b1;
        $fclose(fd);
    end

endmodule
