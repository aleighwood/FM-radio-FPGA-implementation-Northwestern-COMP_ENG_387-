//`include "tap_weights_pkg.sv"
//import tap_weights_pkg::*;
//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"
module fir #(
    parameter TAPS = 32,
    parameter DATA_WIDTH = 16,
    parameter AUDIO_DEC = 1,
    parameter  [31:0] TAP_WEIGHTS [0:TAPS-1]
)(
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [DATA_WIDTH-1:0] in_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [DATA_WIDTH-1:0]  out_din
);

//AUDIO_LPR_COEFFS
// localparam logic [31:0] TAP_WEIGHTS [0:31] =
// {
// 	32'hfffffffd, 32'hfffffffa, 32'hfffffff4, 32'hffffffed, 32'hffffffe5, 32'hffffffdf, 32'hffffffe2, 32'hfffffff3, 
// 	32'h00000015, 32'h0000004e, 32'h0000009b, 32'h000000f9, 32'h0000015d, 32'h000001be, 32'h0000020e, 32'h00000243, 
// 	32'h00000243, 32'h0000020e, 32'h000001be, 32'h0000015d, 32'h000000f9, 32'h0000009b, 32'h0000004e, 32'h00000015, 
// 	32'hfffffff3, 32'hffffffe2, 32'hffffffdf, 32'hffffffe5, 32'hffffffed, 32'hfffffff4, 32'hfffffffa, 32'hfffffffd
// };


logic signed [TAPS:0] [DATA_WIDTH-1:0] x;
logic signed [TAPS:0] [DATA_WIDTH-1:0] tap_out;
logic signed [TAPS:0] valid;
logic signed [DATA_WIDTH-1:0] taps_sum;
logic signed [DATA_WIDTH-1:0] x_c;
logic valid_c;
logic shift, shift_c;

logic [15:0] count;
typedef enum logic [1:0] {s0, s1,s2} state_t;
state_t state, next_state;


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






//generate taps 
genvar i;
generate 
    for (i = 32'b0; i < TAPS; i = i+32'b1) 
    //$display("TAP : %d , tap weight: %04x", i, AUDIO_LPR_COEFFS[TAPS - i - 1]);
    begin : fir_tap_gen
            fir_tap #(
                .TAP_NUMBER(i),
                .TAP_WEIGHT(TAP_WEIGHTS[TAPS - i - 1]),
                .DATA_WIDTH(DATA_WIDTH)
            )
            fir_tap_inst(
                .clock(clock),
                .reset(reset),
                .shift(shift),
                .x_in(x[i]),
                .x_out(x[i+1]),
                .valid_in(valid[i]),
                .valid_out(valid[i+1]),
                .tap_out(tap_out[i])
        );
        end
endgenerate

/*
initial begin 
    int f;
    logic [32:0] test_result, test_result_dequant;
    //for (f = 0; f < TAPS; f =  f+ 1) begin
        //$display("TAP : %d , tap weight: %04x", f, AUDIO_LPR_COEFFS[TAPS - f - 1]);
    //end
    test_result_dequant = DEQUANTIZE(32'h04a6 * 32'hfffffffd);
    test_result = 32'h04a6 * 32'hfffffffd;
    //$display("Test result: %04x", test_result);
    //$display("Test result dequant: %04x", test_result_dequant);

end
*/

always_ff @(posedge clock or posedge reset) begin
    
    if (reset == 1'b1) begin
    //     x[0] <= '0;
    //     valid[0] <= 1'b0;
    //     count <= 16'h0;
    // out_wr_en <= 1'b0;
    // shift<= '0;
    // out_din <= '0;
    state <= s0;
    
    end else begin
        //     out_wr_en <= 1'b0;
        // x[0] <= x_c;
        // valid[0] <= valid_c;
        // out_din <= '0;
        // shift <= shift_c;

        // if(valid[1] == 1'b1 && shift == 1'b1) begin
        //     count += 16'b1;

        //     if (count % AUDIO_DEC == 0 && out_full == 1'b0) begin
        //     out_din <= taps_sum;
        //     out_wr_en <= 1'b1;
        //     count <= 16'h0;
        //     end
        // end 
        state <= next_state;
        
    end
end

//take sum of taps
// always_comb begin 
//     int f;
//     taps_sum = '0;
//     for (f = 0; f < TAPS; f +=1 ) begin
//         taps_sum += $signed(tap_out[f]);
//     end
// end

//read into taps stream
always_comb begin
    in_rd_en = 1'b0;
    out_wr_en = 1'b0;
    valid[0]= 1'b0;
    x[0] = '0;
    shift = 1'b0;
    next_state = state;
    out_din = '0;


    case(state) 
        s0:begin
            if(out_full == 1'b0) begin
                next_state = s1;
                count = 16'h0;
            end
        end

        s1:begin
            if(in_empty ==1'b0) begin
                x[0] = in_dout;
                valid[0] = 1'b1;
                in_rd_en = 1'b1;
                shift = 1'b1;
                count += 16'b1;
                if(count % AUDIO_DEC == 0) begin
                    next_state = s2;
                end
        end
        end

        s2:begin
            if(out_full == 1'b0) begin
            int f;
            taps_sum = '0;
            for (f = 0; f < TAPS; f +=1 ) begin
                taps_sum += $signed(tap_out[f]);
            end
            out_din = taps_sum;
            out_wr_en = 1'b1;
            next_state = s0;
            end
        end

    endcase

    // if (in_empty == 1'b0 && out_full == 1'b0) begin
    //     x_c = in_dout;
    //     in_rd_en = 1'b1;
    //     valid_c = 1'b1;
    //     shift_c = 1'b1;
    // end 


end

endmodule