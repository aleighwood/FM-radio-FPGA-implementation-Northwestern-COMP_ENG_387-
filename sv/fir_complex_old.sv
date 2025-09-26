module fir_complex #(
    parameter TAPS,
    parameter DATA_WIDTH = 16
    //parameter AUDIO_DEC =1
)(
    input  logic        clock,
    input  logic        reset,
    output logic        Q_in_rd_en,
    output logic        I_in_rd_en,
    input  logic        I_in_empty,
    input  logic        Q_in_empty,
    input  logic [DATA_WIDTH-1:0] Q_din,
    input  logic [DATA_WIDTH-1:0] I_din,
    output logic       Q_out_wr_en,
    output logic       I_out_wr_en,
    input  logic       I_out_full,
    input  logic       Q_out_full,
    output logic [DATA_WIDTH-1:0]  I_dout,
    output logic [DATA_WIDTH-1:0]  Q_dout
);

// I: real
// Q: imaginary

localparam logic [31:0] CHANNEL_COEFFS_REAL[0:19] =
{
	32'h00000001, 32'h00000008, 32'hfffffff3, 32'h00000009, 32'h0000000b, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 
	32'hffffffb1, 32'h00000257, 32'h00000257, 32'hffffffb1, 32'hffffffd3, 32'h00000045, 32'hffffffd3, 32'h0000000b, 
	32'h00000009, 32'hfffffff3, 32'h00000008, 32'h00000001
};

localparam logic [31:0] CHANNEL_COEFFS_IMAG[0:19] =
{
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 
	32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000
};

logic signed [TAPS:0] [DATA_WIDTH-1:0] x_real, x_imag;
logic signed [TAPS-1:0] [DATA_WIDTH-1:0] tap_out_real, tap_out_imag;
logic signed [TAPS:0] valid;
logic signed [DATA_WIDTH-1:0] taps_sum_real, taps_sum_imag;
logic signed [DATA_WIDTH-1:0] x_real_c, x_imag_c;
logic valid_c;
logic shift,shift_c;

logic [15:0] count;
//logic Q_out_wr_en, I_out_wr_en;


localparam int BITS = 10;
localparam int QUANT_VAL = (1 << BITS);

function int QUANTIZE_I(int i);

    return i << BITS;
endfunction


function int QUANTIZE_F(real f);
    return $rtoi(f * QUANT_VAL);  
endfunction


function int DEQUANTIZE(int i);
   
    if (i[DATA_WIDTH-1] == 1) begin
       

        return (i + (1 << BITS)-1) >>> BITS;

    end else begin
        return i >>> BITS;
    end
endfunction

typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;


//generate taps 
genvar i;
generate 
    for (i = 32'b0; i < TAPS; i = i+32'b1) 
    //$display("TAP : %d , tap weight: %04x", i, AUDIO_LPR_COEFFS[TAPS - i - 1]);
    begin : fir_complex_tap_gen
            fir_complex_tap #(
                .TAP_NUMBER(i),
                .TAP_WEIGHT_REAL(CHANNEL_COEFFS_REAL[TAPS - i - 1]),
                .TAP_WEIGHT_IMAG(CHANNEL_COEFFS_IMAG[TAPS - i - 1]),
                .DATA_WIDTH(DATA_WIDTH)
            )
            fir_complex_tap_inst(
                .clock(clock),
                .reset(reset),
                .shift(shift),
                .x_in_real(x_real[i]),
                .x_out_real(x_real[i+1]),
                .x_in_imag(x_imag[i]),
                .x_out_imag(x_imag[i+1]),
                .valid_in(valid[i]),
                .valid_out(valid[i+1]),
                .tap_out_real(tap_out_real[i]),
                .tap_out_imag(tap_out_imag[i])
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
        Q_out_wr_en <= 1'b0;
        I_out_wr_en <= 1'b0;
        x_real[0] <= '0;
        x_imag[0] <= '0;
        valid[0] <= 1'b0;
        I_dout <= '0;
        Q_dout <= '0;
        shift <= '0;

    end else begin
        
        //if(shift_c == 1'b1)begin
        Q_out_wr_en <= 1'b0;
        I_out_wr_en <= 1'b0;
        x_real[0] <= x_real_c;
        x_imag[0] <= x_imag_c;
        valid[0] <= valid_c;
        shift <= shift_c;
        //end 
        I_dout <= '0;
        Q_dout <= '0;


        if(valid[1] == 1'b1 && shift == 1'b1) begin
            count += 16'b1;

            //if (count % AUDIO_DEC == 0) begin
            if(I_out_full == 1'b0 && Q_out_full == 1'b0) begin
            I_dout <= taps_sum_real;
            Q_dout <= taps_sum_imag;
            Q_out_wr_en <= 1'b1;
            I_out_wr_en <= 1'b1;
            end
        end 
        
    end
end

//take sum of taps
always_comb begin 
    int f;
    taps_sum_real = '0;
    taps_sum_imag = '0;
    for (f = 0; f < TAPS; f +=1 ) begin
        taps_sum_real += $signed(tap_out_real[f]);
        taps_sum_imag += $signed(tap_out_imag[f]);
    end
end

//read into taps stream
always_comb begin
    I_in_rd_en = 1'b0;
    Q_in_rd_en = 1'b0;
    valid_c= 1'b0;
    x_real_c = '0;
    x_imag_c = '0;
    shift_c = 1'b0;

    if (I_in_empty == 1'b0 && Q_in_empty == 1'b0) begin
        x_real_c = I_din;
        x_imag_c = Q_din;
        I_in_rd_en = 1'b1;
        Q_in_rd_en = 1'b1;
        valid_c = 1'b1;
        shift_c = 1'b1;
    end 

end

endmodule
