//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"
module demod #(  
    parameter DATA_WIDTH = 32
) (
    input  logic clock,
    input  logic reset,
    input  logic [DATA_WIDTH-1:0] I_dout,
    input  logic I_empty,
    output logic I_rd_en,
    input  logic [DATA_WIDTH-1:0] Q_dout,
    input  logic Q_empty,
    output logic Q_rd_en,
    output logic [DATA_WIDTH-1:0] out_din,
    input  logic out_full,
    output logic out_wr_en
);
localparam real PI = 3.1415926535897932384626433832795;
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

    function automatic int get_msb_pos(int value);
        int pos;
        int N;
        N = $bits(value);
        pos = -1;  // Default to -1 if value is 0
        for (int i = N-1; i >= 0; i--) begin
            if (value & (1 << i)) begin
                pos = i;
                break;
            end
        end
        return pos;
    endfunction
// function automatic int get_msb_pos(int value);
//     int pos;
//     if (value == 0) begin
//         pos = -1;  // Return -1 if value is 0
//     end else begin
//         pos = 0;
//         if (value >> 16) begin pos = pos + 16; value = value >> 16; end
//         if (value >> 8) begin pos = pos + 8; value = value >> 8; end
//         if (value >> 4) begin pos = pos + 4; value = value >> 4; end
//         if (value >> 2) begin pos = pos + 2; value = value >> 2; end
//         if (value >> 1) begin pos = pos + 1; value = value >> 1; end
//     end
//     return pos;
// endfunction

function automatic int divide(int dividend, int divisor);
    int N = $bits(dividend); // Get bit-width of operands
    int a, b, p, q, sign, remainder;

    a = (dividend < 0) ? -dividend : dividend;
    b = (divisor < 0) ? -divisor : divisor;
    
    q = 0;
    p = 0;


    for (int i = 0; i < N; i++) begin
        if (b == 0 || b > a) break;  // Exit condition

        p = get_msb_pos(a) - get_msb_pos(b);
        if ((b << p) > a) p--;

        q = q + (1 << p);
        a = a - (b << p);
    end

    sign = (dividend < 0) ^ (divisor < 0);
    q = (sign == 1) ? -q : q;
    
 
    remainder = (dividend < 0) ? -a : a;

    return q;
endfunction







localparam int ADC_RATE = 64000000;  // 64 MS/s
localparam int USRP_DECIM = 250;
localparam int QUAD_RATE = ADC_RATE / USRP_DECIM;  // 256 kS/s
localparam real MAX_DEV = 55000.0;


typedef enum logic [2:0] {s0, s1, s2,s3,s4} state_t;
state_t state, state_c;
logic [DATA_WIDTH-1:0] sum, sum_c;
localparam logic [31:0] quad1 =32'h00000324;
localparam logic [31:0] quad3 =32'h0000096c;
logic signed [31:0] angle, r_c, r;
logic  signed [31:0] abs_I;
logic signed [31:0] prev_real, prev_imag, prev_real_c, prev_imag_c;
logic signed [31:0] i,r_demod, i_c, r_demod_c;
localparam logic [31:0] gain =32'h000002f6;





always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        sum <= '0;
        prev_real <=0;
        prev_imag <= 0;
        i <= 0;
        r_demod <= 0;
        r<= 0;
    end else begin
        state <= state_c;
        sum <= sum_c;
        prev_real <= prev_real_c;
        prev_imag <= prev_imag_c;
        i<=i_c;
        r_demod <= r_demod_c;
        r <= r_c;
    end
end

always_comb begin
    out_din = 'b0;
    out_wr_en = 1'b0;
    I_rd_en = 1'b0;
    Q_rd_en = 1'b0;
    sum_c = sum;
    state_c = state;
    angle = 0;
    abs_I = 0;
    prev_imag_c = prev_imag;
    prev_real_c = prev_real;
    i_c = i;
    r_demod_c = r_demod;
    r_c = r;

    case (state)
        s0: begin
            if (I_empty == 1'b0 && Q_empty == 1'b0) begin
                r_demod_c = DEQUANTIZE(I_dout * prev_real_c) - DEQUANTIZE(Q_dout * (-prev_imag_c));
                i_c = DEQUANTIZE(Q_dout * prev_real_c) + DEQUANTIZE(I_dout * (-prev_imag_c));
                I_rd_en = 1'b1;
                Q_rd_en = 1'b1;
                state_c = s1;
                prev_imag_c = Q_dout;
                prev_real_c = I_dout;

            end
        end

        s1: begin
            

                abs_I = (i[DATA_WIDTH-1] == 1) ? (-(i)) +1: (i) +1;

                if (r_demod[DATA_WIDTH-1] == 0) begin
                    r_c = divide(QUANTIZE_I(r_demod - abs_I), (r_demod + abs_I));
                    // angle = quad1 - DEQUANTIZE(quad1*r);
                    state_c = s2;
                end else begin
                    r_c = divide(QUANTIZE_I(r_demod + abs_I), (abs_I - r_demod));
                    // angle = quad3 - DEQUANTIZE(quad1*r);
                    state_c = s3;

                end
                
                // sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
            
        end

        s2: begin

                state_c = s4;
                angle = quad1 - DEQUANTIZE(quad1*r);
                sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
        end
        s3: begin

                state_c = s4;
                angle = quad3 - DEQUANTIZE(quad1*r);
                sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
        end

        s4: begin
            if (out_full == 1'b0) begin
                out_din = DEQUANTIZE(gain*sum);
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