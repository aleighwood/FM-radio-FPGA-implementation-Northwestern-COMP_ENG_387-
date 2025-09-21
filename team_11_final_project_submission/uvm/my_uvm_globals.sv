`ifndef __GLOBALS__
`define __GLOBALS__

// UVM Globals
localparam string IN_NAME  = "../test_files/iq_raw.txt";
localparam string OUT_LEFT_NAME = "../test_files/test_out_left.txt";
localparam string OUT_RIGHT_NAME = "../test_files/test_out_right.txt";
localparam string RIGHT_CMP_NAME = "../test_files/right_audio_out.txt";
localparam string LEFT_CMP_NAME = "../test_files/left_audio_out.txt";


localparam int DATA_WIDTH = 32;
localparam int TEST_LENGTH = 262144;
localparam int TEST_OUT_LENGTH = 8187;
localparam int FIFO_BUFFER_SIZE = 32;
localparam int CLOCK_PERIOD = 10;


    // localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam VECTOR_SIZE = 64;
    // localparam FIFO_BUFFER_SIZE = 8;
    // localparam CLOCK_PERIOD = 10;
    localparam DATA_LENGTH = 262144;


`endif
