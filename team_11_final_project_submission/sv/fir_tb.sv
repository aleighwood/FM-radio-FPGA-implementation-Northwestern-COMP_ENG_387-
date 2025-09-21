
`timescale 1 ns / 1 ns

module fir_tb;

localparam string IMG_IN_NAME  = "../test_files/fir_input_file.txt";
localparam string IMG_OUT_NAME = "../test_files/fir_output_file.txt";

//localparam string IMG_CMP_NAME = "../test_files/fir_input_file.txt";
localparam CLOCK_PERIOD = 10;
localparam int DATA_WIDTH = 32;
localparam int SAMPLES = 512;
localparam int ELEMENTS = 63;
//localparam int ELEMENTS = 64;



logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;

logic        in_full;
logic        in_wr_en  = '0;
logic [DATA_WIDTH-1:0] in_din    = '0;
logic        out_rd_en;
logic        out_empty;
logic  [DATA_WIDTH-1:0] out_dout;

logic   hold_clock    = '0;
logic   in_write_done = '0;
logic   out_read_done = '0;
integer out_errors    = '0;

//localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 4;
//localparam BMP_DATA_SIZE = WIDTH*HEIGHT*BYTES_PER_PIXEL;

fir_top #(
    .DATA_WIDTH(DATA_WIDTH)
) fir_top_inst (
    .clock(clock),
    .reset(reset),
    .in_full(in_full),
    .in_wr_en(in_wr_en),
    .in_din(in_din),
    .out_empty(out_empty),
    .out_rd_en(out_rd_en),
    .out_dout(out_dout)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    // end the simulation
    $finish;
end

// just copy from HW2

initial begin : img_read_process
    int i, r;
    int in_file;
    logic [31:0] temp_data; // Temporary variable to hold 16-bit data
    

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IMG_IN_NAME);

    in_file = $fopen(IMG_IN_NAME, "rb");
    in_wr_en = 1'b0;

    

    // Read data from image file
    i = 0;
    while ( !$feof(in_file) && i < SAMPLES) begin
        @(negedge clock);
        in_wr_en = 1'b0;
        if (in_full == 1'b0) begin
            r = $fscanf(in_file, "%h", temp_data);
            //$display("line %d, temp_data: %x", i,temp_data);
            //in_din = temp_data[9:0];
            in_din = temp_data;

            in_wr_en = 1'b1;
            i += 1;
        end
    end

    @(negedge clock);
    in_wr_en = 1'b0;
    $fclose(in_file);
    in_write_done = 1'b1;
end

initial begin : img_write_process
    int i, r;
    int out_file;
    int cmp_file;
    logic [31:0] cmp_dout;
    //logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME);
    
    //out_file = $fopen(IMG_OUT_NAME, "wb");
    cmp_file = $fopen(IMG_OUT_NAME, "rb");
    out_rd_en = 1'b0;
    
    // Copy the BMP header
   // r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
    //for (i = 0; i < BMP_HEADER_SIZE; i++) begin
   //    $fwrite(out_file, "%c", bmp_header[i]);
   // end

    i = 0;
    while (i < ELEMENTS-1) begin
        @(negedge clock);
        out_rd_en = 1'b0;
        if (out_empty == 1'b0) begin
            //r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            //$fwrite(out_file, "%04x \n", out_dout);
            r = $fscanf(cmp_file, "%h", cmp_dout);

            if (cmp_dout != out_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0%x.\n", $time, IMG_OUT_NAME, i+1, out_dout, cmp_dout, i);
            end

            out_rd_en = 1'b1;
            i += 1;
        end
    end

    @(negedge clock);
    out_rd_en = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule
