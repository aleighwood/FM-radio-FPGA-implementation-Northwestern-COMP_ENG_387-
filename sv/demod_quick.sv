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


// function automatic int divide(int dividend, int divisor);
//     int N = $bits(dividend); // Get bit-width of operands
//     int a, b, p, q, sign, remainder;

//     a = (dividend < 0) ? -dividend : dividend;
//     b = (divisor < 0) ? -divisor : divisor;
    
//     q = 0;
//     p = 0;


//     for (int i = 0; i < N; i++) begin
//         if (b == 0 || b > a) break;  // Exit condition

//         p = get_msb_pos(a) - get_msb_pos(b);
//         if ((b << p) > a) p--;

//         q = q + (1 << p);
//         a = a - (b << p);
//     end

//     sign = (dividend < 0) ^ (divisor < 0);
//     q = (sign == 1) ? -q : q;
 
//     remainder = (dividend < 0) ? -a : a;
//     return q;
// endfunction







localparam int ADC_RATE = 64000000;  // 64 MS/s
localparam int USRP_DECIM = 250;
localparam int QUAD_RATE = ADC_RATE / USRP_DECIM;  // 256 kS/s
localparam real MAX_DEV = 55000.0;


typedef enum logic [4:0] {s0, s1, s2,s3,s4, s5, s6 ,s7 ,s8, s9} state_t;
state_t state, state_c;
logic [DATA_WIDTH-1:0] sum, sum_c;
localparam logic [31:0] quad1 =32'h00000324;
localparam logic [31:0] quad3 =32'h0000096c;
logic signed [31:0] angle, r_c, r;
logic  signed [31:0] abs_I;
logic signed [31:0] prev_real, prev_imag, prev_real_c, prev_imag_c;
logic signed [31:0] i,r_demod, i_c, r_demod_c;
localparam logic [31:0] gain =32'h000002f6;

logic signed [DATA_WIDTH-1:0] divisor, divisor_c, dividend, dividend_c;
logic [5:0] count, count_c;
logic signed [DATA_WIDTH-1:0]  a, b, p, q, sign, a_c, b_c, p_c, q_c, pos_a, pos_b, pos_a_c, pos_b_c, N_a_c, N_b_c, N_a, N_b;
logic [6:0] N, N_c;
logic msb_count_a, msb_count_b, msb_count_a_c, msb_count_b_c;
logic signed [DATA_WIDTH-1:0] pr, pr_c, pi, pi_c;


always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        sum <= '0;
        prev_real <=0;
        prev_imag <= 0;
        i <= 0;
        r_demod <= 0;
        r<= 0;
        dividend <= '0;
        divisor <= '0;
        count <= '0;
        a<= '0;
        b<= '0;
        p<= '0;
        q<= '0;
        N<= '0;
        msb_count_a <= '0;
        msb_count_b <= '0;

        N_a <= '0;
        pos_a<= '0;
        N_b <= '0;
        pos_b<= '0;
        pr<='0;
        pi<= '0;
    end else begin
        state <= state_c;
        sum <= sum_c;
        prev_real <= prev_real_c;
        prev_imag <= prev_imag_c;
        i<=i_c;
        r_demod <= r_demod_c;
        r <= r_c;
        dividend <= dividend_c;
        divisor <= divisor_c;
        count <= count_c;
        a<= a_c;
        b<= b_c;
        p<=p_c;
        q<=q_c;
        N<= N_c;
        msb_count_a <= msb_count_a_c;
        msb_count_b <= msb_count_b_c;

        N_a <= N_a_c;
        pos_a<= pos_a_c;
        N_b <= N_b_c;
        pos_b<= pos_b_c;
        pr<= pr_c;
        pi<= pi_c;
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
    divisor_c = divisor;
    dividend_c = dividend;
    count_c = count;
    a_c = a;
    b_c = b;
    q_c = q;
    p_c = p;
    N_c = N;
    msb_count_a_c = msb_count_a;
    msb_count_b_c = msb_count_b;

    N_a_c = N_a;
    pos_a_c = pos_a;
    N_b_c = N_b;
    pos_b_c = pos_b;
    pi_c = pi;
    pr_c = pr;
    case (state)
        // s0: begin
        //     if (I_empty == 1'b0 && Q_empty == 1'b0) begin
        //         r_demod_c = DEQUANTIZE(I_dout * prev_real) ;
        //         i_c = DEQUANTIZE(Q_dout * prev_real);
        //         pi_c = prev_imag;
        //         I_rd_en = 1'b1;
        //         Q_rd_en = 1'b1;
        //         state_c = s1;
        //         prev_imag_c = Q_dout;
        //         prev_real_c = I_dout;

        //     end
        // end

        // s1: begin
        //     r_demod_c = r_demod - DEQUANTIZE(prev_imag * (-pi));
        //     i_c = i + DEQUANTIZE(prev_real * (-pi));
        //     state_c = s2;
        // end
        s0: begin
            if (I_empty == 1'b0 && Q_empty == 1'b0) begin
                r_demod_c = DEQUANTIZE(I_dout * prev_real) ;
                i_c = DEQUANTIZE(Q_dout * prev_real);

                pr_c = DEQUANTIZE(Q_dout * (-prev_imag));
                pi_c = DEQUANTIZE(I_dout * (-prev_imag));
                I_rd_en = 1'b1;
                Q_rd_en = 1'b1;
                state_c = s1;
                prev_imag_c = Q_dout;
                prev_real_c = I_dout;

            end
        end

        s1: begin
            r_demod_c = r_demod - pr;
            i_c = i + pi;
            state_c = s2;
        end

        s2: begin
            

                abs_I = (i[DATA_WIDTH-1] == 1) ? (-(i)) +1: (i) +1;
                if (r_demod[DATA_WIDTH-1] == 0) begin
                    // r_c = divide(QUANTIZE_I(r_demod - abs_I), (r_demod + abs_I));
                    divisor_c = (r_demod + abs_I);
                    dividend_c = QUANTIZE_I(r_demod - abs_I);
                    // angle = quad1 - DEQUANTIZE(quad1*r);
                    state_c = s3;
                end else begin
                    // r_c = divide(QUANTIZE_I(r_demod + abs_I), (abs_I - r_demod));
                    divisor_c = (abs_I - r_demod);
                    dividend_c = QUANTIZE_I(r_demod + abs_I);
                    // angle = quad3 - DEQUANTIZE(quad1*r);
                    state_c = s3;
                end
                // sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
                N_c = $bits(dividend_c); 
                q_c = 0;
                p_c = 0;
                a_c = (dividend_c < 0) ? -dividend_c : dividend_c;
                b_c = (divisor_c < 0) ? -divisor_c : divisor_c;
                count_c = '0;
                
        end
        s3: begin
                if (b == 0 || b > a || count >= N) begin
                    count_c = '0;
                    state_c = s6;
                end else begin

                // p_c = get_msb_pos(a) - get_msb_pos(b);
                state_c = s5;
                pos_a_c = -1;
                pos_b_c = -1;
                N_a_c = $bits(a)-1;
                N_b_c = $bits(b)-1;
                msb_count_a_c = '0;
                msb_count_b_c = '0;
                p_c = get_msb_pos(a) - get_msb_pos(b);
                if ((b << p_c) > a) p_c= p_c-1;

                end
                //  

        end

        s5: begin

                if ((b << p) > a) p_c= p-1;

                q_c = q + (1 << p);
                a_c = a - (b << p);
                count_c = count+1;

 
                state_c = s3;
                

        end

        s6: begin

                // $display("out of loops");

            sign = (dividend < 0) ^ (divisor < 0);
            q_c = (sign == 1) ? -q : q;
 
            // remainder = (dividend < 0) ? -a : a;
            if (r_demod[DATA_WIDTH-1] == 0) begin
                state_c = s7;
            end else begin
                state_c = s8;
            end
        end

        s7: begin

                state_c = s9;
                angle = quad1 - DEQUANTIZE(quad1*q);
                sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
        end
        s8: begin

                state_c = s9;
                angle = quad3 - DEQUANTIZE(quad1*q);
                sum_c = (i[DATA_WIDTH-1] == 1) ? -angle: angle;
        end

        s9: begin
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