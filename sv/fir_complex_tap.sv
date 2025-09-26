//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"

module fir_complex_tap # ( 
                    parameter TAP_WEIGHT_REAL = 32'h0,
                    parameter TAP_WEIGHT_IMAG = 32'h0,
                    parameter DATA_WIDTH = 16,
                    parameter TAP_NUMBER
) (
    input   logic clock,
    input   logic reset,
    input logic shift,
    input   logic [DATA_WIDTH-1:0] x_in_real,
    output  logic [DATA_WIDTH-1:0] x_out_real,
    input   logic [DATA_WIDTH-1:0] x_in_imag,
    output  logic [DATA_WIDTH-1:0] x_out_imag,
    input   logic valid_in,
    output  logic valid_out,
    output  logic [DATA_WIDTH-1:0] tap_out_real,
    output  logic [DATA_WIDTH-1:0] tap_out_imag
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


logic signed [DATA_WIDTH-1:0] x_out_real_c;
logic signed [DATA_WIDTH-1:0] x_out_imag_c;
logic signed [DATA_WIDTH-1:0] tap_out_real_c;
logic signed [DATA_WIDTH-1:0] tap_out_imag_c;
logic valid_out_c;
/*

initial begin
    logic [32:0] test_result,test_result_tap;
    $display("tap: %d, tap weight: %04x ", TAP_NUMBER,TAP_WEIGHT);
    test_result = DEQUANTIZE(32'h04a6 * 32'hfffffffd);
    test_result_tap = DEQUANTIZE(32'h04a6 *TAP_WEIGHT);
    $display("test_result: %04x", test_result);
    $display("test_result_tap: %04x ", test_result_tap);

end
*/

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        x_out_real <= '0;
        x_out_imag <= '0;
        valid_out <= 1'b0;
        tap_out_real <= '0;
        tap_out_imag <= '0;

    end else begin

        if (shift == 1'b1) begin
        x_out_real <= x_out_real_c;
        x_out_imag <= x_out_imag_c;
        valid_out <= valid_out_c;
        tap_out_real <= tap_out_real_c;
        tap_out_imag <= tap_out_imag_c;
    end
    end
end


 always_comb begin 
        valid_out_c = '0;
        x_out_real_c = '0;
        x_out_imag_c = '0;
        
        tap_out_real_c = '0;
        tap_out_imag_c = '0;

        if (/*valid_in == 1'b1 &&*/ shift ==1'b1) begin

            tap_out_real_c = DEQUANTIZE( (TAP_WEIGHT_REAL * x_in_real) - (TAP_WEIGHT_IMAG * x_in_imag));
            tap_out_imag_c = DEQUANTIZE( (TAP_WEIGHT_REAL * x_in_imag) - (TAP_WEIGHT_IMAG * x_in_real));

            x_out_real_c = x_in_real;
            x_out_imag_c = x_in_imag;
            valid_out_c = 1'b1;
        end
 end 
 


endmodule