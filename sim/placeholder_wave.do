#add wave -noupdate -group my_uvm_tb
#add wave -noupdate -group my_uvm_tb -radix hexadecimal /my_uvm_tb/*

add wave -noupdate -group my_uvm_tb/placeholder_top_inst
add wave -noupdate -group my_uvm_tb/placeholder_top_inst -radix hexadecimal /my_uvm_tb/placeholder_top_inst/*

add wave -noupdate -group my_uvm_tb/placeholder_top_inst/placeholder_inst
add wave -noupdate -group my_uvm_tb/placeholder_top_inst/placeholder_inst -radix hexadecimal /my_uvm_tb/placeholder_top_inst/placeholder_inst/*

add wave -noupdate -group my_uvm_tb/placeholder_top_inst/in_inst
add wave -noupdate -group my_uvm_tb/placeholder_top_inst/in_inst -radix hexadecimal /my_uvm_tb/placeholder_top_inst/in_inst/*

add wave -noupdate -group my_uvm_tb/placeholder_top_inst/left_inst
add wave -noupdate -group my_uvm_tb/placeholder_top_inst/left_inst -radix hexadecimal /my_uvm_tb/placeholder_top_inst/left_inst/*

add wave -noupdate -group my_uvm_tb/placeholder_top_inst/right_inst
add wave -noupdate -group my_uvm_tb/placeholder_top_inst/right_inst -radix hexadecimal /my_uvm_tb/placeholder_top_inst/right_inst/*
