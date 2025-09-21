setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# cordic architecture
vlog -work work "../sv/tap_weights_pkg.sv"
vlog -work work "../sv/quant_function_pkg.sv"
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/read_IQ.sv"
vlog -work work "../sv/read_IQ_top.sv"
vlog -work work "../sv/read_IQ_tb.sv"
vlog -work work "../sv/demod.sv"
vlog -work work "../sv/demod_top.sv"
vlog -work work "../sv/demod_tb.sv"
vlog -work work "../sv/qarctan.sv"
vlog -work work "../sv/qarctan_top.sv"
vlog -work work "../sv/qarctan_tb.sv"
vlog -work work "../sv/deemph.sv"
vlog -work work "../sv/deemph_top.sv"
vlog -work work "../sv/deemph_tb.sv"
vlog -work work "../sv/mult.sv"
vlog -work work "../sv/mult_top.sv"
vlog -work work "../sv/mult_tb.sv"
vlog -work work "../sv/add.sv"
vlog -work work "../sv/add_top.sv"
vlog -work work "../sv/add_tb.sv"
vlog -work work "../sv/sub.sv"
vlog -work work "../sv/sub_top.sv"
vlog -work work "../sv/sub_tb.sv"
vlog -work work "../sv/gain.sv"
vlog -work work "../sv/gain_top.sv"
vlog -work work "../sv/gain_tb.sv"
vlog -work work "../sv/radio_top.sv"
vlog -work work "../sv/radio_tb.sv"
vlog -work work "../sv/fir_complex_tb.sv"
vlog -work work "../sv/deemph.sv"


vlog -work work "../sv/fir_complex.sv"
vlog -work work "../sv/fir_complex_tap.sv"
vlog -work work "../sv/fir_complex_top.sv"
vlog -work work "../sv/placeholder.sv"
vlog -work work "../sv/placeholder_top.sv"
vlog -work work "../sv/fir.sv"
vlog -work work "../sv/fir_tap.sv"
vlog -work work "../sv/fir_top.sv"
vlog -work work "../sv/fir_tb.sv"


# uvm library
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm.sv
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm_macros.svh
vlog -work work +incdir+$env(UVM_HOME)/src $env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv

# uvm package
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_pkg.sv"
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_tb.sv"

# start uvm simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.my_uvm_tb -wlf my_uvm_tb.wlf -sv_lib lib/uvm_dpi -dpicpppath /usr/bin/gcc +incdir+$env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/

# start basic simulation
#vsim -voptargs=+acc +notimingchecks -L work work.read_IQ_tb -wlf read_IQ_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.demod_tb -wlf demod_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.qarctan_tb -wlf qarctan_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.deemph_tb -wlf deemph_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.mult_tb -wlf mult_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.add_tb -wlf add_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.sub_tb -wlf sub_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.gain_tb -wlf gain_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.radio_tb -wlf radio_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.fir_complex_tb -wlf fir_complex_tb.wlf
#vsim -voptargs=+acc +notimingchecks -L work work.fir_tb -wlf fir_tb.wlf


#do fm_wave.do
#do demod_wave.do
#do qarctan_wave.do
#do deemph_wave.do
#do mult_wave.do
#do add_wave.do
#do sub_wave.do
#do gain_wave.do
#do radio_wave.do
#do fir_complex_wave.do
#do fir_wave.do
do uvm_wave.do

#do placeholder_wave.do



run -all
#quit;