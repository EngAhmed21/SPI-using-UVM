vlib work

vlog -f Files.txt +define+SIM +cover

vsim -voptargs=+acc work.RAM_top -cover -sv_seed random

add wave -position insertpoint sim:/RAM_top/intf/*

coverage save RAM_cv.ucdb -onexit

run -all
