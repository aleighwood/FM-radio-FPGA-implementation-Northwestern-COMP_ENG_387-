
module read_IQ #(  
    parameter DATA_WIDTH = 32
) (
    input  logic clock,
    input  logic reset,
    input logic signed [7:0] in_dout,
    input  logic in_empty,
    output logic in_rd_en,
    output logic [DATA_WIDTH-1:0] I_din,
    input  logic I_full,
    output logic I_wr_en,
    output logic [DATA_WIDTH-1:0] Q_din,
    input  logic Q_full,
    output logic Q_wr_en
);

    localparam int BITS = 10;
    localparam int QUANT_VAL = (1 << BITS);



    function int QUANTIZE_I(int i);
        
        return (i <<< BITS);

        
    endfunction


typedef enum logic [0:0] {s0, s1} state_t;
state_t state, state_c;

logic signed [31:0] temp_i, temp_q, temp_i_c, temp_q_c;

logic [2:0] count, count_c;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
    	temp_i <= '0;
    	temp_q <= '0;
        count <= '0;
    end else begin
        state <= state_c;
       
        temp_i <= temp_i_c;
        temp_q <= temp_q_c;
        count <= count_c;
    end
end

always_comb begin
    I_din = 'b0;
    I_wr_en = 1'b0;
    Q_din = 'b0;
    Q_wr_en = 1'b0;
    in_rd_en = 1'b0;

   
    state_c = state;
    temp_i_c = temp_i;
    temp_q_c = temp_q;
    count_c = count;

    case (state)
        s0: begin

            if (in_empty == 1'b0 ) begin
                
                in_rd_en = 1'b1;
            //   $display("ReadIQ input: %h", in_dout);
             
                if (count == 0) begin
                    temp_i_c = in_dout;
                    // $display("First i temp val: %h", temp_i_c);
                    count_c = count+1'b1;
                end else if (count == 1) begin
                    // $display("Pre-quant second i temp val: %h", in_dout << 8 | temp_i);
                    // temp_i_c = QUANTIZE_I((in_dout << 8) | 8'(temp_i));
                    temp_i_c = QUANTIZE_I($signed((16'($unsigned(in_dout) << 8)) | 8'(temp_i)));
                    // $display("Second i temp val: %h", temp_i_c);
                    count_c = count+1'b1;
                end else if (count == 2) begin
                    temp_q_c = in_dout;
                    count_c = count+1'b1;
                end else if (count > 2 && I_full == 1'b0 && Q_full == 1'b0) begin
                temp_q_c = QUANTIZE_I($signed((16'($unsigned(in_dout) << 8)) | 8'(temp_q)));
                count_c = '0;
                I_din = temp_i;
                Q_din = temp_q_c;
                I_wr_en = 1'b1;
                Q_wr_en = 1'b1;
                
                // $display("PreQuant: %h %h Middle: %h PostQuant: %h", in_dout, 8'(temp_q), 32'($unsigned(in_dout) << 8) | 8'(temp_q), temp_q_c);
                // state_c = s1;

                end
                
            end

        end

        // s1: begin
        //     if (I_full == 1'b0 && Q_full == 1'b0) begin
        //         count_c = '0;
        //         I_din = temp_i;
        //         Q_din = temp_q;
        //         I_wr_en = 1'b1;
        //         Q_wr_en = 1'b1;
        //         state_c = s0;
        //         // $display("ReadIQ I out: %h", I_din);
        //     end
        // end

        default: begin
            state_c = s0;
           
        end
    endcase
end

endmodule