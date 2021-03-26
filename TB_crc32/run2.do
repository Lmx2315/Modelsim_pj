cls

vlog -sv -reportprogress 300 -work work crc32_m8.sv
vlog -sv -reportprogress 300 -work work tb_CRC32_eth.sv
vsim -t 1ns 
vsim -gui work.tb_CRC32_eth -novopt
add wave -position insertpoint sim:/tb_CRC32_eth/c1/*
configure wave -timelineunits us
run -all
wave zoom full

