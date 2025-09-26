package quant_function_pkg;


localparam DATA_WIDTH =32;
localparam int BITS = 10;
localparam int QUANT_VAL = (1 << BITS);


function int QUANTIZE_I(int i);
    return i << BITS;
endfunction

function int QUANTIZE_F(int f);
    //return $rtoi(f * QUANT_VAL);   
    return (f*QUANT_VAL);
endfunction

function int DEQUANTIZE(int i);
    
    if (i[DATA_WIDTH-1] == 1) begin
        return (i + (1 << BITS)-1) >>> BITS;
    end else begin
        return i >>> BITS;
    end
endfunction

endpackage : quant_function_pkg