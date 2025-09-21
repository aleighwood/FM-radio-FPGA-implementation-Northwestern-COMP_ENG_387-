
//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"
module fir_tap # ( parameter TAP_WEIGHT = 32'h0,
                    parameter DATA_WIDTH = 16,
                    parameter TAP_NUMBER
) (
    input   logic clock,
    input   logic reset,
    input   logic [DATA_WIDTH-1:0] x_in,
    output  logic [DATA_WIDTH-1:0] x_out,
    input   logic valid_in,
    output  logic valid_out,
    output  logic [DATA_WIDTH-1:0] tap_out,
    input  logic shift
);

localparam int BITS = 10;
localparam int QUANT_VAL = (1 << BITS);


function int QUANTIZE_I(int i);

    return i << BITS;
endfunction


// function int QUANTIZE_F(real f);
//     return $rtoi(f * QUANT_VAL);   
//     //return (f*QUANT_VAL);
// endfunction


function int DEQUANTIZE(int i);
   
    if (i[DATA_WIDTH-1] == 1) begin
       

        return (i + (1 << BITS)-1) >>> BITS;

    end else begin
        return i >>> BITS;
    end
endfunction



logic signed [DATA_WIDTH-1:0] x_out_c;
logic signed [DATA_WIDTH-1:0] tap_out_c;
logic valid_out_c;

// initial begin
//     logic [32:0] test_result,test_result_tap;
//     // $display("tap: %d, tap weight: %04x ", TAP_NUMBER,TAP_WEIGHT);
//     test_result = DEQUANTIZE(32'h04a6 * 32'hfffffffd);
//     test_result_tap = DEQUANTIZE(32'h04a6 *TAP_WEIGHT);
//     // $display("test_result: %04x", test_result);
//     // $display("test_result_tap: %04x ", test_result_tap);

// end



always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        x_out <= '0;
        valid_out <= 1'b0;
        tap_out <= '0;

    end else begin
        if (shift ==1'b1) begin
        x_out <= x_out_c;
        valid_out <= valid_out_c;
        tap_out <= tap_out_c;
        end
    end
end


 always_comb begin 
        valid_out_c = '0;
        x_out_c = '0;
        tap_out_c = '0;

        if (/*valid_in == 1'b1 */ shift ==1'b1) begin

            tap_out_c = DEQUANTIZE(x_in * TAP_WEIGHT);
            //tap_out_c = DEQUANTIZE(TAP_WEIGHT);
            x_out_c = x_in;
            valid_out_c = 1'b1;
        end
 end 
 


endmodule