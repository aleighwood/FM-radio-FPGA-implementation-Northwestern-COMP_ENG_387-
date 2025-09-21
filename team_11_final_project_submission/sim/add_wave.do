add wave -noupdate -group add_tb
add wave -noupdate -group add_tb -radix hexadecimal /add_tb/*

add wave -noupdate -group add_tb/add_top_inst
add wave -noupdate -group add_tb/add_top_inst -radix hexadecimal /add_tb/add_top_inst/*

add wave -noupdate -group add_tb/add_top_inst/add_inst
add wave -noupdate -group add_tb/add_top_inst/add_inst -radix hexadecimal /add_tb/add_top_inst/add_inst/*

add wave -noupdate -group add_tb/add_top_inst/I_inst
add wave -noupdate -group add_tb/add_top_inst/I_inst -radix hexadecimal /add_tb/add_top_inst/I_inst/*

add wave -noupdate -group add_tb/add_top_inst/Q_inst
add wave -noupdate -group add_tb/add_top_inst/Q_inst -radix hexadecimal /add_tb/add_top_inst/Q_inst/*

add wave -noupdate -group add_tb/add_top_inst/out_inst
add wave -noupdate -group add_tb/add_top_inst/out_inst -radix hexadecimal /add_tb/add_top_inst/out_inst/*
