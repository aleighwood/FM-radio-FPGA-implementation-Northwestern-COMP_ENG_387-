
module placeholder #(  
    parameter DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 8

) (
    input  logic clock,
    input  logic reset,
    input  logic [DATA_WIDTH-1:0] in_dout,
    input  logic in_empty,
    output logic in_rd_en,
    output logic [DATA_WIDTH-1:0] out_left_din,
    input  logic out_left_full,
    output logic out_left_wr_en,
    output logic [DATA_WIDTH-1:0] out_right_din,
    input  logic out_right_full,
    output logic out_right_wr_en
);



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
    out_left_din = 'b0;
    out_right_din = 'b0;
    out_left_wr_en = 1'b0;
    out_right_wr_en = 1'b0;
    in_rd_en = 1'b0;

    sum_c = sum;
    state_c = state;

    

    case (state)
        s0: begin
            if (in_empty == 1'b0 && out_left_full == 1'b0 && out_right_full == 1'b0) begin
                out_left_din = in_dout;
                out_right_din = in_dout;

                in_rd_en = 1'b1;
                // state_c = s1;
                out_left_wr_en = 1'b1;
                out_right_wr_en = 1'b1;


            end
        end


        default: begin
            state_c = s0;
            sum_c = 'x;
        end
    endcase
end

endmodule