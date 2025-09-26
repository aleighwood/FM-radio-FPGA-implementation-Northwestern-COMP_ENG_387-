//import quant_function_pkg::*;
//`include "quant_function_pkg.sv"

module deemph #(
    parameter TAPS = 2,
    parameter DATA_WIDTH = 32,
    parameter AUDIO_DEC =1
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


localparam logic [31:0] IIR_Y_COEFFS [1:0] = 
{
    32'h0 ,32'hfffffd66
};

localparam logic [31:0] Y_TAP = 32'hfffffd66;

localparam logic [31:0] IIR_X_COEFFS [1:0] = 
{
    32'hb2 ,32'hb2
};



logic signed [TAPS-1:0] [DATA_WIDTH-1:0] x,y;
logic signed [TAPS-1:0] [DATA_WIDTH-1:0] tap_out_x, tap_out_y;
logic signed [TAPS:0] valid_x;
logic signed [TAPS-1:0] valid_y;
logic signed [DATA_WIDTH-1:0] taps_sum_x, taps_sum_y,taps_sum_total;
logic signed [DATA_WIDTH-1:0] x_c,y_c;
logic valid_c;
logic shift,shift_c;

logic [15:0] count;
logic [DATA_WIDTH-1:0] y0, y0_c;
logic valid_y0, valid_y0_c;

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






//generate x  taps 
genvar i;
generate 
    for (i = 32'b0; i < TAPS; i = i+32'b1) 
    //$display("TAP : %d , tap weight: %04x", i, AUDIO_LPR_COEFFS[TAPS - i - 1]);
    begin : fir_tap_gen_x
            fir_tap #(
                .TAP_NUMBER(i),
                .TAP_WEIGHT(IIR_X_COEFFS[TAPS - i - 1]),
                .DATA_WIDTH(DATA_WIDTH)
                
            )
            fir_tap_inst(
                .clock(clock),
                .reset(reset),
                .x_in(x[i]),
                .x_out(x[i+1]),
                .valid_in(valid_x[i]),
                .valid_out(valid_x[i+1]),
                .tap_out(tap_out_x[i]),
                .shift(shift)
        );
        end
endgenerate



//generate y taps
genvar j;
generate 
    for (j = 32'b0; j < 1; j = j+32'b1) 
    //$display("TAP : %d , tap weight: %04x", i, AUDIO_LPR_COEFFS[TAPS - i - 1]);
    begin : fir_tap_gen_y
            fir_tap #(
                .TAP_NUMBER(j),
                .TAP_WEIGHT(Y_TAP),
                .DATA_WIDTH(DATA_WIDTH)
            )
            fir_tap_inst(
                .clock(clock),
                .reset(reset),
                .x_in(y[j]),
                .x_out(y[j+1]),
                .valid_in(valid_y[j]),
                .valid_out(valid_y[j+1]),
                .tap_out(tap_out_y[j]),
                .shift(shift)
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

// X process
always_ff @(posedge clock or posedge reset) begin
    
    
    if (reset == 1'b1) begin
        x[0] <= '0;
        valid_x[0] <= 1'b0;
        count <= 16'h0;
		out_wr_en <= 1'b0;
		shift<= '0;
		out_din <= '0;
		y0 <= '0;
		valid_y0 <= '0;
    end else begin
        out_wr_en <= 1'b0;
        x[0] <= x_c;
        valid_x[0] <= valid_c;
        out_din <= '0;
        shift <= shift_c;
        y0 <= y0_c;
        valid_y0 <= valid_y0_c;
        if(valid_x[0] == 1'b1 && shift ==1'b1 && out_full == 1'b0) begin
            count += 16'b1;
            out_din <= taps_sum_total;
            out_wr_en <= 1'b1;
        end 
        
    end
end



//take sum of taps
always_comb begin 
    int f;
    taps_sum_x = '0;
    taps_sum_y = '0;
    taps_sum_total = '0;
    //y[0] = '0;
       y[0] = y0;
    valid_y[0] = valid_y0;
    y0_c = y0;
    valid_y0_c = valid_y0;
    for (f = 0; f < TAPS; f +=1 ) begin
        taps_sum_x += $signed(tap_out_x[f]);
        //taps_sum_y += $signed(tap_out_y[f]);
        taps_sum_y = $signed(tap_out_y[0]);
    end
    taps_sum_total = taps_sum_x + taps_sum_y;

    if (valid_x[1] == 1'b1) begin
       y0_c = taps_sum_total;
       //y[1] = taps_sum_total;
       valid_y0_c = 1'b1;
       //valid_y[1] = 1'b1;
    end


 
end

//read into taps stream
always_comb begin
    in_rd_en = 1'b0;
    valid_c= 1'b0;
    x_c = '0;
    shift_c = 1'b0;

    if (in_empty == 1'b0) begin 
        x_c = in_dout;
        in_rd_en = 1'b1;
        valid_c = 1'b1;
        shift_c = 1'b1;
 		
    end 


end

endmodule