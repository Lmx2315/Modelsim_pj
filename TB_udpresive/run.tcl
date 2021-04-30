quit -sim
cls
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_udpresive
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_udpresive/udp_reciver.v
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_udpresive/tb_udp_reciver.sv
vsim -t 1ns work.tb_udp_reciver -novopt
add wave -position insertpoint sim:/tb_udp_reciver/*
add wave -position insertpoint sim:/tb_udp_reciver/inst_udp_reciver/*
configure wave -timelineunits us
run -all
wave zoom full