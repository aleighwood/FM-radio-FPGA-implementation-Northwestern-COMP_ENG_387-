
`timescale 1 ns / 1 ns

module read_IQ_tb ();

    localparam string IN_NAME = "../test_files/iq_raw.txt";
    localparam string I_NAME = "../test_files/iq_processed_I.txt";
    localparam string Q_NAME = "../test_files/iq_processed_Q.txt";
    
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 64;
    localparam FIFO_BUFFER_SIZE = 8;
    localparam CLOCK_PERIOD = 10;
    localparam DATA_LENGTH = 262144;

    logic clock = 1'b0;
    logic reset = 1'b0;

    logic [7:0] in_din;
    logic in_wr_en, in_full;
    logic [DATA_WIDTH-1:0] Q_dout;
    logic Q_rd_en, Q_empty;
    logic [DATA_WIDTH-1:0] I_dout;
    logic I_rd_en, I_empty;

    logic   in_write_done = '0;

    logic   Q_read_done  = '0;
    integer Q_errors     = '0;
    logic   I_read_done  = '0;
    integer I_errors     = '0;

    read_IQ_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    ) read_IQ_top_inst (
        .clock(clock),
        .reset(reset),
        .in_full(in_full),
        .in_wr_en(in_wr_en),
        .in_din(in_din),
        .Q_rd_en(Q_rd_en),
        .Q_empty(Q_empty),
        .Q_dout(Q_dout),
        .I_rd_en(I_rd_en),
        .I_empty(I_empty),
        .I_dout(I_dout)
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

        wait(I_read_done);

        end_time = $time;
        $display("@ %0t: Simulation completed.", end_time);
        $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
        $display("Total I error count: %0d", I_errors);
        $display("Total Q error count: %0d", Q_errors);

        $stop;
    end


initial begin : in_write
    integer fd, count;
    integer iter =0;
    in_din = '0;
    in_wr_en = 1'b0;
    in_din = 8'h00;    // Initialize to 8-bit zero
    
    
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IN_NAME);
    
    fd = $fopen(IN_NAME, "r");
    if (fd == 0) begin
        $display("Error: Could not open file %s", IN_NAME);
        $finish;
    end
    
    // Read until EOF
    while (!$feof(fd) && iter < DATA_LENGTH) begin
        @(negedge clock);
        in_wr_en = 1'b0;
        
        if (in_full == 1'b0) begin
            count = $fscanf(fd, "%h", in_din);  // Read 8-bit hex value
    
            if (count == 1) begin              // Check if read was successful
                in_wr_en = 1'b1;              // Enable write only if data was read
                iter++;
            end

        end
    end
    
    @(posedge clock);
    in_wr_en = 1'b0;
    $fclose(fd);
    in_write_done = 1'b1;
end

initial begin : IQ_write
    integer fdI, fdQ, z, countI, countQ;
    logic [DATA_WIDTH-1:0] I_data_cmp;
    logic [DATA_WIDTH-1:0] Q_data_cmp;
    integer iter = 0;
    I_rd_en = 1'b0;
    I_data_cmp = '0;
    
    Q_rd_en = 1'b0;
    Q_data_cmp = '0;

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing files %s and %s...", $time, I_NAME, Q_NAME);
    
    fdI = $fopen(I_NAME, "r");
    fdQ = $fopen(Q_NAME, "r");

    // Check if files opened successfully
    if (fdI == 0) begin
        $display("ERROR: Unable to open file %s", I_NAME);
        $finish;
    end
    if (fdQ == 0) begin
        $display("ERROR: Unable to open file %s", Q_NAME);
        $finish;
    end

    z = 0;
    while (!$feof(fdI) && !$feof(fdQ) && iter < DATA_LENGTH/4) begin
        @(negedge clock);
        I_rd_en = 1'b0;
        Q_rd_en = 1'b0;

        if (I_empty == 1'b0 && Q_empty == 1'b0) begin
            I_rd_en = 1'b1;
            Q_rd_en = 1'b1;
            
            // Read values from both files
            countI = $fscanf(fdI, "%h", I_data_cmp);
            countQ = $fscanf(fdQ, "%h", Q_data_cmp);
            
            // Ensure values were read correctly
            if (countI != 1) begin
                $display("ERROR: Unexpected end of file or read failure in %s at line %0d", I_NAME, z+1);
                break;
            end
            if (countQ != 1) begin
                $display("ERROR: Unexpected end of file or read failure in %s at line %0d", Q_NAME, z+1);
                break;
            end

            // Compare I and Q values
            if (I_dout !== I_data_cmp) begin
                I_errors++;
                $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%h.", 
                         $time, I_NAME, z+1, I_dout, I_data_cmp, z);
            end
            if (Q_dout !== Q_data_cmp) begin
                Q_errors++;
                $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%h.", 
                         $time, Q_NAME, z+1, Q_dout, Q_data_cmp, z);
            end
            z++;
            iter++;
            // $display("iter: ", iter);
        end
    end

    // If one file ends before the other, print a warning
    if (!$feof(fdI) || !$feof(fdQ)) begin
        $display("WARNING: One file ended before the other. Check for missing data.");
    end

    // Cleanup
    I_rd_en = 1'b0;
    I_read_done = 1'b1;
    Q_rd_en = 1'b0;
    Q_read_done = 1'b1;
    
    $fclose(fdI);
    $fclose(fdQ);
end


endmodule
