vlib work

vlog -f Files.txt +define+RAM_SIM +define+SLAVE_SIM +define+WRAPPER_SIM +cover

vsim -voptargs=+acc work.wrapper_top -classdebug -uvmcontrol=all -cover -sv_seed random

add wave -position insertpoint sim:/wrapper_top/W_if/*

coverage save wrapper_cv.ucdb -onexit

run -all
