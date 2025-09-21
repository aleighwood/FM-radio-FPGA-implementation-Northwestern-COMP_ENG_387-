
`timescale 1 ns / 1 ns

module deemph_tb ();

    localparam string I_NAME = "../test_files/deemph_in.txt";
    
    localparam string OUT_NAME = "../test_files/deemph_out.txt";

    localparam string IMG_OUT_NAME = "../test_files/deemph_FPGA_out.txt";
    //localparam string IMG_CMP_NAME = "../files/fir_input_file.txt";


    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 64;
    localparam FIFO_BUFFER_SIZE = 8;
    localparam CLOCK_PERIOD = 10;

    logic clock = 1'b0;
    logic reset = 1'b0;

    logic [DATA_WIDTH-1:0] in_din;
    logic in_wr_en, in_full;

    logic [DATA_WIDTH-1:0] out_dout;
    logic out_rd_en, out_empty;

    logic   in_write_done = '0;
    logic   out_read_done  = '0;
    integer out_errors     = '0;

    deemph_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
    ) deemph_top_inst (
        .clock(clock),
        .reset(reset),
        .in_full(in_full),
        .in_wr_en(in_wr_en),
        .in_din(in_din),
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
        in_din = '0;
        in_wr_en = 1'b0;
        

        @(negedge reset);
        $display("@ %0t: Loading file %s...", $time, I_NAME);
        
        fd = $fopen(I_NAME, "r");

        x = 0;
        while ( x < VECTOR_SIZE+1 ) begin
            @(negedge clock);
            in_wr_en = 1'b0;
            if (in_full == 1'b0) begin
                count = $fscanf(fd, "%h", in_din);
                in_wr_en = 1'b1;   
                x++;         
            end
        end

        @(posedge clock);
        in_wr_en = 1'b0;
        $fclose(fd);
        in_write_done = 1'b1;
    end


    initial begin : out_write
        integer fd, z, count;
        logic [DATA_WIDTH-1:0] out_data_cmp;
        int out_write_file;
        out_rd_en = 1'b0;
        out_data_cmp = '0;
    
        
        @(negedge reset);
        @(negedge clock);

        out_write_file = $fopen(IMG_OUT_NAME, "wb");

        $display("@ %0t: Comparing file %s...", $time, OUT_NAME);
        fd = $fopen(OUT_NAME, "r");

        z = 0;
        while ( z < VECTOR_SIZE ) begin
            @(negedge clock);            
            out_rd_en = 1'b0;
            if (out_empty == 1'b0) begin
                out_rd_en = 1'b1;
                $fwrite(out_write_file, "%04x \n", out_dout);
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
        $fclose(out_write_file);
    end

endmodule
