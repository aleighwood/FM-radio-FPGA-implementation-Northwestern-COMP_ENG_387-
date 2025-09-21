
`timescale 1 ns / 1 ns

module fir_complex_tb;

localparam string IMG_IN_NAME_REAL  = "../test_files/fir_I_input_file.txt";
localparam string IMG_IN_NAME_IMAG  = "../test_files/fir_Q_input_file.txt";


localparam string IMG_OUT_NAME_REAL = "../test_files/fir_I_FPGA_output.txt";
localparam string IMG_OUT_NAME_IMAG = "../test_files/fir_Q_FPGA_output.txt";


localparam string IMG_CMP_NAME_REAL = "../test_files/fir_I_output_file.txt";
localparam string IMG_CMP_NAME_IMAG = "../test_files/fir_Q_output_file.txt";


localparam CLOCK_PERIOD = 10;
localparam int DATA_WIDTH = 32;
localparam int SAMPLES = 512;
localparam int ELEMENTS = 512;



logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;

logic        Q_in_full;
logic        I_in_full;
logic        Q_in_wr_en;
logic       I_in_wr_en;
logic [DATA_WIDTH-1:0] I_din;
logic [DATA_WIDTH-1:0] Q_din;
logic       I_out_empty;
logic       Q_out_empty;
logic       I_out_rd_en;
logic       Q_out_rd_en;
logic [DATA_WIDTH-1:0] I_dout;
logic [DATA_WIDTH-1:0] Q_dout;


logic   hold_clock    = '0;
logic   in_write_done = '0;
logic   out_read_done = '0;
integer out_errors    = '0;

//localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 4;
//localparam BMP_DATA_SIZE = WIDTH*HEIGHT*BYTES_PER_PIXEL;

fir_complex_top #(
    .DATA_WIDTH(DATA_WIDTH)
) fir_complex_top_inst (
    .clock(clock),
    .reset(reset),
    .I_in_full(I_in_full),
    .Q_in_full(Q_in_full),
    .Q_in_wr_en(Q_in_wr_en),
    .I_in_wr_en(I_in_wr_en),
    .I_din(I_din),
    .Q_din(Q_din),
    .I_out_empty(I_out_empty),
    .Q_out_empty(Q_out_empty),
    .I_out_rd_en(I_out_rd_en),
    .Q_out_rd_en(Q_out_rd_en),
    .I_dout(I_dout),
    .Q_dout(Q_dout)
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
    int i, r_real, r_imag;
    int in_file_real, in_file_imag;
    logic [31:0] temp_data_I; 
    logic [31:0] temp_data_Q;

    

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IMG_IN_NAME_REAL);
    $display("@ %0t: Loading file %s...", $time, IMG_IN_NAME_IMAG);

    in_file_real = $fopen(IMG_IN_NAME_REAL, "rb");
    in_file_imag = $fopen(IMG_IN_NAME_IMAG, "rb");
    Q_in_wr_en = 1'b0;
    I_in_wr_en = 1'b0;

    

    // Read data from image file
    i = 0;
    while ( i < SAMPLES) begin
        @(negedge clock);
        Q_in_wr_en = 1'b0;
        I_in_wr_en = 1'b0;
        if (Q_in_full == 1'b0 && I_in_full ==1'b0) begin
            r_real = $fscanf(in_file_real, "%h", temp_data_I);
            r_imag = $fscanf(in_file_imag, "%h", temp_data_Q);
            //$display("line %d, temp_data: %x", i,temp_data);
            //in_din = temp_data[9:0];
            I_din = temp_data_I;
            Q_din = temp_data_Q;

            Q_in_wr_en = 1'b1;
            I_in_wr_en = 1'b1;
            i += 1;
        end
    end

    @(negedge clock);
    Q_in_wr_en = 1'b0;
    I_in_wr_en = 1'b0;
    $fclose(in_file_real);
    $fclose(in_file_imag);
    in_write_done = 1'b1;
end

initial begin : img_write_process
    int i, r_real,r_imag;
    int out_file_real, out_file_imag;
    int cmp_file_real, cmp_file_imag;
    logic [15:0] cmp_dout_real, cmp_dout_imag;
    //logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME_REAL, IMG_OUT_NAME_IMAG);
    
    out_file_real = $fopen(IMG_OUT_NAME_REAL, "wb");
    out_file_imag = $fopen(IMG_OUT_NAME_IMAG, "wb");
    cmp_file_real = $fopen(IMG_CMP_NAME_REAL, "rb");
    cmp_file_imag = $fopen(IMG_CMP_NAME_IMAG, "rb");
    Q_out_rd_en = 1'b0;
    I_out_rd_en = 1'b0;
    
    // Copy the BMP header
   // r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
    //for (i = 0; i < BMP_HEADER_SIZE; i++) begin
   //    $fwrite(out_file, "%c", bmp_header[i]);
   // end

    i = 0;
    while (i < ELEMENTS-1) begin
        @(negedge clock);
        I_out_rd_en = 1'b0;
        Q_out_rd_en = 1'b0;
        if (Q_out_empty== 1'b0 && I_out_empty  == 1'b0) begin
            //r_real = $fread(cmp_dout_real, cmp_file_real, i BYTES_PER_PIXEL);
            r_real = $fscanf(cmp_file_real, "%h", cmp_dout_real);
            r_imag = $fscanf(cmp_file_imag, "%h", cmp_dout_imag);
            $fwrite(out_file_real, "%04x \n", I_dout);
            $fwrite(out_file_imag, "%04x \n", Q_dout);


            if (cmp_dout_real != I_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0%x.\n", $time, IMG_OUT_NAME_REAL, i+1, I_dout, cmp_dout_real, i);
            end

            if (cmp_dout_imag != Q_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0%x.\n", $time, IMG_OUT_NAME_IMAG, i+1, Q_dout, cmp_dout_imag, i);
            end


            Q_out_rd_en = 1'b1;
            I_out_rd_en = 1'b1;
            i += 1;
        end
    end

    @(negedge clock);
    I_out_rd_en = 1'b0;
    Q_out_rd_en = 1'b0;
    $fclose(out_file_real);
    $fclose(out_file_imag);
    //$fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule
