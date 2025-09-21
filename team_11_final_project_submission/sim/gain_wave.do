add wave -noupdate -group gain_tb
add wave -noupdate -group gain_tb -radix hexadecimal /gain_tb/*

add wave -noupdate -group gain_tb/gain_top_inst
add wave -noupdate -group gain_tb/gain_top_inst -radix hexadecimal /gain_tb/gain_top_inst/*

add wave -noupdate -group gain_tb/gain_top_inst/add_inst
add wave -noupdate -group gain_tb/gain_top_inst/add_inst -radix hexadecimal /gain_tb/gain_top_inst/gain_inst/*

add wave -noupdate -group gain_tb/gain_top_inst/in_inst
add wave -noupdate -group gain_tb/gain_top_inst/in_inst -radix hexadecimal /gain_tb/gain_top_inst/in_inst/*

add wave -noupdate -group gain_tb/gain_top_inst/out_inst
add wave -noupdate -group gain_tb/gain_top_inst/out_inst -radix hexadecimal /gain_tb/gain_top_inst/out_inst/*
