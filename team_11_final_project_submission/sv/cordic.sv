
module cordic (
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic signed [31:0] in_dout,
    output logic        out_wr_en_sin,
    input  logic        out_full_sin,
    output logic signed [15:0]  out_din_sin,
    output logic        out_wr_en_cos,
    input  logic        out_full_cos,
    output logic signed [15:0]  out_din_cos
);

`define BITS 14
localparam int QUANT_VAL = 1 << `BITS;

localparam int CORDIC_1K = 'd9949;
localparam int PI = 'd51471;
localparam int TWO_PI = 102943;
localparam int HALF_PI = 25735;

logic [9:0] count, count_c;
typedef enum logic [2:0] {s0, s1, s2, s3} state_types;
state_types state, state_c;

logic [31:0] gs, gs_c;
logic [16:0] valid_in, valid_out;
// logic [15:0] [15:0]x_in, y_in, z_in;
logic signed [16:0] [15:0] x_out, y_out, z_out,x_out_c, y_out_c, z_out_c;
logic signed [31:0] z_temp, z_temp_c, x_temp, x_temp_c, y_temp, y_temp_c;

generate
for (genvar i = 0; i < 16; i++) begin 
    cordic_stage #(
        .STAGE(i)
    ) cordic_stage_inst (
        .clock(clock),
        .reset(reset),
        .valid_in(valid_out[i]),
        .valid_out(valid_out[i+1]),
        .x_in(x_out_c[i]),
        .y_in(y_out_c[i]),
        .z_in(z_out_c[i]),
        .x_out(x_out_c[i+1]),
        .y_out(y_out_c[i+1]),
        .z_out(z_out_c[i+1])
    );

end
endgenerate


always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        gs <= 31'h0;
        z_temp <= 31'b0;
        x_temp <= 31'b0;
        y_temp <= 31'b0;
        count <= 0;
    end else begin
        state <= state_c;
        gs <= gs_c;
        z_temp <= z_temp_c;
        x_temp <= x_temp_c;
        y_temp <= y_temp_c;
        x_out <= x_out_c;
        y_out <= y_out_c;
        z_out <= z_out_c;
        count <= count_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en_cos = 1'b0;
    out_wr_en_sin = 1'b0;
    out_din_cos   = 32'b0;
    out_din_sin   = 32'b0;
    state_c   = state;
    gs_c = gs;
    valid_out[0] = 1'b0;
    z_temp_c = z_temp;
    x_temp_c = x_temp;
    y_temp_c = y_temp;
    count_c = count;

case (state)
    s0: begin
        if (in_empty == 1'b0) begin
            
            z_temp_c = in_dout ;

         
            in_rd_en = 1'b1;
            
 
            if (z_temp_c > PI) begin
                z_temp_c = z_temp_c - TWO_PI;
            end else if (z_temp_c < -PI) begin
                z_temp_c = z_temp_c + TWO_PI;
            end
       
            if (z_temp_c > HALF_PI) begin
                z_out_c[0] = z_temp_c - PI;
                y_out_c[0] = -16'b0;
                x_out_c[0] = -CORDIC_1K;
            

            end else if (z_temp_c < -HALF_PI) begin
                z_out_c[0] = z_temp_c + PI;
                y_out_c[0] = -16'b0;
                x_out_c[0] = - CORDIC_1K;
                

            end else begin
                x_out_c[0] = CORDIC_1K;
                y_out_c[0] = 16'b0;
                z_out_c[0] = z_temp_c;
               

            end
            
      
            valid_out[0] = 1'b1;
            count_c = count+1;
            if (valid_out[16] == 1'b1) begin
                state_c = s1;
            end else begin
                state_c = s0;
            end
        end
    end




        s1: begin
            
            if (out_full_cos == 1'b0 && out_full_sin == 1'b0 ) begin
                // $display("got in");
                // $display("x: %h", x_out[16]);
               

                out_din_cos = x_out[16];
                out_din_sin = y_out[16];
                out_wr_en_cos = 1'b1;
                out_wr_en_sin = 1'b1;
                
            end
            state_c = s0;
        end

        default: begin
            in_rd_en  = 1'b0;
            out_wr_en_cos = 1'b0;
            out_wr_en_sin = 1'b0;
            out_din_cos = 32'b0;
            out_din_sin = 32'b0;
            state_c = s0;
           
        end

    endcase
end

endmodule
