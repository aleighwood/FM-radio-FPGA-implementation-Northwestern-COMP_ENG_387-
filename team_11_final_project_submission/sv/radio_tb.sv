
`timescale 1 ns / 1 ns

module radio_tb ();

    localparam string IN_NAME = "../test_files/iq_raw.txt";
    localparam string LEFT_NAME = "../test_files/left_audio.txt";
    localparam string RIGHT_NAME = "../test_files/right_audio.txt";
   
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 64;
    localparam FIFO_BUFFER_SIZE = 32;
    localparam CLOCK_PERIOD = 10;
    localparam DATA_LENGTH = 262144;

    logic clock = 1'b0;
    logic reset = 1'b0;

    logic [31:0] in_din;
    logic in_wr_en, in_full;
    logic [DATA_WIDTH-1:0] left_dout;
    logic left_rd_en, left_empty;
    logic [DATA_WIDTH-1:0] right_dout;
    logic right_rd_en, right_empty;

    logic [DATA_WIDTH-1:0] demod_out;
    logic demod_out_wr_en;
    
    logic   in_write_done = '0;

    logic   Q_read_done  = '0;
    integer Q_errors     = '0;
    logic   I_read_done  = '0;
    integer I_errors     = '0;

    radio_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
        .TAPS(20)
    ) radio_top_inst (
        .clock(clock),
        .reset(reset),
        .in_full(in_full),
        .in_wr_en(in_wr_en),
        .in_din(in_din),
        .out_left_rd_en(left_rd_en),
        .out_left_empty(left_empty),
        .out_left_dout(left_dout),
        .out_right_rd_en(right_rd_en),
        .out_right_empty(right_empty),
        .out_right_dout(right_dout)
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
      

        $stop;
    end


initial begin : in_write
    integer fd, count;
    integer iter =0;
    in_din = '0;
    in_wr_en = 1'b0;
    in_din = 32'h00;    // Initialize to 8-bit zero
    
    
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
                // $display("write to module iter: %d", iter);
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
    logic [DATA_WIDTH-1:0] left_data_cmp;
    logic [DATA_WIDTH-1:0] right_data_cmp;

 
    integer iter = 0;
    left_rd_en = 1'b0;
    right_rd_en = 1'b0;

    left_data_cmp = '0;
    right_data_cmp = '0;



    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing files %s...", $time, LEFT_NAME );
    
    fdI = $fopen(LEFT_NAME, "r");
    

    // Check if files opened successfully
    if (fdI == 0) begin
        $display("ERROR: Unable to open file %s", LEFT_NAME);
        $finish;
    end

    
    $display("@ %0t: Comparing files %s...", $time, RIGHT_NAME );
    
    fdQ= $fopen(RIGHT_NAME, "r");
    

    // Check if files opened successfully
    if (fdQ == 0) begin
        $display("ERROR: Unable to open file %s", RIGHT_NAME);
        $finish;
    end


    z = 0;
    while (!$feof(fdI) && iter < ((DATA_LENGTH/32)-5)) begin
        @(negedge clock);
        left_rd_en = 1'b0;
        right_rd_en = 1'b0;


        if (left_empty == 1'b0 && right_empty == 1'b0) begin
            left_rd_en = 1'b1;
            right_rd_en = 1'b1;

            
            // Read values from both files
            countI = $fscanf(fdI, "%h", left_data_cmp);
       
            
            // Ensure values were read correctly
            if (countI != 1) begin
                $display("ERROR: Unexpected end of file or read failure in %s at line %0d", LEFT_NAME, z+1);
                break;
            end

                        // Read values from both files
            countI = $fscanf(fdQ, "%h", right_data_cmp);
       
            
            // Ensure values were read correctly
            if (countI != 1) begin
                $display("ERROR: Unexpected end of file or read failure in %s at line %0d", RIGHT_NAME, z+1);
                break;
            end

            
      

            // Compare I and Q values
            if (left_dout !== left_data_cmp) begin
                I_errors++;
                $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%d.", 
                         $time, LEFT_NAME, z+1, left_dout, left_data_cmp, z);
            end
            else begin
                $display("CORRECT: %d, output: %h",z,left_dout);
            end
            if (right_dout !== right_data_cmp) begin
                I_errors++;
                $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%d.", 
                         $time, RIGHT_NAME, z+1, right_dout, right_data_cmp, z);
            end
            else begin
                $display("CORRECT: %d, output: %h",z,right_dout);
            end
            z++;
            iter++;
            // $display("iter: ", iter);
        end
    end

    // If one file ends before the other, print a warning
    if (!$feof(fdI)) begin
        $display("WARNING: One file ended before the other. Check for missing data.");
    end

    // Cleanup
    left_rd_en = 1'b0;
    right_rd_en = 1'b0;


    I_read_done = 1'b1;

    
    $fclose(fdI);
     $fclose(fdQ);

end


endmodule
