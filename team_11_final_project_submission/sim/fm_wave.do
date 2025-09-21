add wave -noupdate -group read_IQ_tb
add wave -noupdate -group read_IQ_tb -radix hexadecimal /read_IQ_tb/*

add wave -noupdate -group read_IQ_tb/read_IQ_top_inst
add wave -noupdate -group read_IQ_tb/read_IQ_top_inst -radix hexadecimal /read_IQ_tb/read_IQ_top_inst/*

add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/read_IQ_inst
add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/vectorsum_inst -radix hexadecimal /read_IQ_tb/read_IQ_top_inst/read_IQ_inst/*

add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/in_inst
add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/in_inst -radix hexadecimal /read_IQ_tb/read_IQ_top_inst/in_inst/*

add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/I_out_inst
add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/I_out_inst -radix hexadecimal /read_IQ_tb/read_IQ_top_inst/I_out_inst/*

add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/Q_out_inst
add wave -noupdate -group read_IQ_tb/read_IQ_top_inst/Q_out_inst -radix hexadecimal /read_IQ_tb/read_IQ_top_inst/Q_out_inst/*
