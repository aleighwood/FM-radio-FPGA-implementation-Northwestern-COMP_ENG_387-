
module sub #(  
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
// endfunction

function int DEQUANTIZE(int i);
    
    if (i[DATA_WIDTH-1] == 1) begin
        return (i + (1 << BITS)-1) >>> BITS;
    end else begin
        return i >>> BITS;
    end
endfunction


typedef enum logic [1:0] {s0, s1, s2} state_t;
state_t state, state_c;
logic [DATA_WIDTH-1:0] sum, sum_c;



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
    Q_rd_en = 1'b0;
    sum_c = sum;
    state_c = state;

    

    case (state)
        s0: begin
            if (I_empty == 1'b0 && Q_empty == 1'b0 && out_full == 1'b0) begin
                out_din = I_dout - Q_dout;
                I_rd_en = 1'b1;
                Q_rd_en = 1'b1;
                // state_c = s1;
                out_wr_en = 1'b1;

            end
        end


        default: begin
            state_c = s0;
            sum_c = 'x;
        end
    endcase
end

endmodule