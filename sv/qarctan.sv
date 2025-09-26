//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"
module qarctan #(  
    parameter DATA_WIDTH = 32
) (
    input  logic clock,
    input  logic reset,
    input  logic signed [DATA_WIDTH-1:0] I_dout,
    input  logic I_empty,
    output logic I_rd_en,
    input  logic signed [DATA_WIDTH-1:0] R_dout,
    input  logic R_empty,
    output logic R_rd_en,
    output logic signed [DATA_WIDTH-1:0] out_din,
    input  logic out_full,
    output logic out_wr_en
);


localparam real PI = 3.1415926535897932384626433832795;
localparam int BITS = 10;
localparam int QUANT_VAL = (1 << BITS);



function int QUANTIZE_I(int i);
    return i << BITS;
endfunction

function int QUANTIZE_F(real f);
    return $rtoi(f * QUANT_VAL);   
    //return (f*QUANT_VAL);
endfunction


function int DEQUANTIZE(int i);
    if ( i[DATA_WIDTH-1] == 1'b1 && $signed(i) >= -$signed(1 << QUANT_VAL) ) begin

        return 0; 

    end
    if (i[DATA_WIDTH-1] == 1) begin
        return (i + (1 << BITS)-1) >>> BITS;
    end else begin
        return i >>> BITS;
    end
endfunction


// function automatic int divide(int dividend, int divisor);
//     int N = $bits(dividend); // Get bit-width of operands
//     int a, b, p, q, sign, remainder;

  
//     a = (dividend < 0) ? -dividend : dividend;
//     b = (divisor < 0) ? -divisor : divisor;
    
//     q = 0;
//     p = 0;

   
//     if (b == 1) begin
//         q = a;
//         a = 0;
//     end else begin
//         while (b != 0 && b < a) begin
           
//             p = $clog2(a) - $clog2(b);
//             if ((b << p) > a) p--;

//             q = q + (1 << p);
//             a = a - (b << p);
//         end
//     end

//     sign = (dividend >> (N-1)) ^ (divisor >> (N-1));
//     q = (sign == 1) ? -q : q;
//     remainder = (dividend < 0) ? -a : a;

//     return q;
// endfunction
function automatic int divide(int dividend, int divisor);
    int N = $bits(dividend); // Get bit-width of operands
    int a, b, p, q, sign, remainder;

    a = (dividend < 0) ? -dividend : dividend;
    b = (divisor < 0) ? -divisor : divisor;
    
    q = 0;
    p = 0;


    while (b != 0 && b <= a) begin
        p = $clog2(a) - $clog2(b);
        if ((b << p) > a) p--;

        q = q + (1 << p);
        a = a - (b << p);
    end


    sign = (dividend < 0) ^ (divisor < 0);
    q = (sign == 1) ? -q : q;
    
 
    remainder = (dividend < 0) ? -a : a;

    return q;
endfunction


typedef enum logic [0:0] {s0, s1} state_t;
state_t state, state_c;
logic [DATA_WIDTH-1:0] sum, sum_c;

int quad1, quad3;
logic signed [31:0] angle, r;
logic  signed [31:0] abs_I;

initial begin
    // Compute the values at initialization
    quad1 = QUANTIZE_F(3.1415926535897932384626433832795 / 4.0);
    quad3 = QUANTIZE_F(3.0 * 3.1415926535897932384626433832795 / 4.0);
    $display("quad1: %h",quad1);
    $display("quad3: %h",quad3);

end

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        sum <= '0;

    end else begin
        state <= state_c;
        sum <= sum_c;
    end
end

always_comb begin
    out_din = 'b0;
    out_wr_en = 1'b0;
    I_rd_en = 1'b0;
    R_rd_en = 1'b0;
    sum_c = sum;
    state_c = state;
    angle = 0;
    r = 0;
    abs_I = 0;

    case (state)
        s0: begin
            if (I_empty == 1'b0 && R_empty == 1'b0) begin
                abs_I = (I_dout[DATA_WIDTH-1] == 1) ? (-(I_dout)) +1: (I_dout) +1;
                //$display("abs_I: %h normal I: %h", abs_I, I_dout);

                if (R_dout[DATA_WIDTH-1] == 0) begin
                    r = divide(QUANTIZE_I(R_dout - abs_I),  (R_dout + abs_I));

                    angle = quad1 - DEQUANTIZE(quad1*r);
                    // $display("Positive: dequant val: %h predequant: %h angle: %h r: %d", DEQUANTIZE(quad1*r), quad1*r, angle, r);

                    // $display("r: %h numer: %h prequent numer: %h Rdout: %h abs_I: %h", r, QUANTIZE_I(R_dout - abs_I), (R_dout - abs_I), R_dout, abs_I);

                end else begin
                    r = divide(QUANTIZE_I(R_dout + abs_I), (abs_I - R_dout));
                    // $display("Negative: r: %h numer: %h prequant numer: %h R_dout: %h abs_I: %h" , r, QUANTIZE_I(R_dout + abs_I), (R_dout + abs_I), R_dout, abs_I);

                    angle = quad3 - DEQUANTIZE(quad1*r);
                    // $display("Negative: dequant val: %h predequant: %h angle: r: %h %d", DEQUANTIZE(quad1*r), quad1*r, angle, r);
                end
                
                sum_c = (I_dout[DATA_WIDTH-1] == 1) ? -angle: angle;
                //sum_c = angle;
            //    $display("angle: %h output: %h", angle, sum_c);
                I_rd_en = 1'b1;
                R_rd_en = 1'b1;
                state_c = s1;
            end
        end

        s1: begin
            if (out_full == 1'b0) begin
                out_din = sum;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end

        default: begin
            state_c = s0;
            sum_c = 'x;
        end
    endcase
end

endmodule