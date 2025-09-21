
`timescale 1 ns / 1 ns

module add_tb ();

    localparam string I_NAME = "../test_files/add_x_in.txt";
    localparam string Q_NAME = "../test_files/add_y_in.txt";
    localparam string OUT_NAME = "../test_files/add_out.txt";
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 32768;
    localparam FIFO_BUFFER_SIZE = 8;
    localparam CLOCK_PERIOD = 10;

    logic clock = 1'b0;
    logic reset = 1'b0;

    logic [DATA_WIDTH-1:0] I_din;
    logic I_wr_en, I_full;
    logic [DATA_WIDTH-1:0] Q_din;
    logic Q_wr_en, Q_full;
    logic [DATA_WIDTH-1:0] out_dout;
    logic out_rd_en, out_empty;

    logic   I_write_done = '0;
    logic   Q_write_done = '0;
    logic   out_read_done  = '0;
    integer out_errors     = '0;

    add_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    ) add_top_inst (
        .clock(clock),
        .reset(reset),
        .I_full(I_full),
        .I_wr_en(I_wr_en),
        .I_din(I_din),
        .Q_full(Q_full),
        .Q_wr_en(Q_wr_en),
        .Q_din(Q_din),
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
        while ( x < VECTOR_SIZE ) begin
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

    initial begin : Q_write
        integer fd, y, count;
        Q_din = '0;
        Q_wr_en = 1'b0;
        
        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, Q_NAME);
        
        fd = $fopen(Q_NAME, "r");

        y = 0;
        while ( y < VECTOR_SIZE ) begin
            @(negedge clock);
            Q_wr_en = 1'b0;
            if (Q_full == 1'b0) begin
                count = $fscanf(fd, "%h", Q_din);
                Q_wr_en = 1'b1; 
                y++;           
            end
        end

        @(posedge clock);
        Q_wr_en = 1'b0;
        $fclose(fd);
        Q_write_done = 1'b1;
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
        while ( z < VECTOR_SIZE ) begin
            @(negedge clock);            
            out_rd_en = 1'b0;
            if (out_empty == 1'b0) begin
                out_rd_en = 1'b1;
                count = $fscanf(fd, "%h", out_data_cmp);
                if (out_dout != out_data_cmp) begin
                    out_errors++;
                    $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%h.", $time, OUT_NAME, z+1, out_dout, out_data_cmp, z);
                end
                z++;
            end
        end
        out_rd_en = 1'b0;
        out_read_done = 1'b1;
        $fclose(fd);
    end

endmodule
