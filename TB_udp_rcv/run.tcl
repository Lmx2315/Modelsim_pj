quit -sim
cls
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_udp_rcv
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_udp_rcv/udp_rcv.sv
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_udp_rcv/tb_udp_rcv.sv
vsim -gui work.tb_udp_rcv -novopt -L C:/Work_murmansk/Quartus/Modelsim_pj/lib/verilog_libs/altera_lnsim_ver -L C:/Work_murmansk/Quartus/Modelsim_pj/lib/verilog_libs/altera_mf_ver 
add wave -position insertpoint sim:/tb_udp_rcv/*
add wave -position insertpoint sim:/tb_udp_rcv/inst_udp_rcv/*
add wave -position insertpoint sim:/tb_udp_rcv/fifi_desc_inst/*
add wave -position insertpoint sim:/tb_udp_rcv/fifo_udp_rcv_inst/*
configure wave -timelineunits us
run -all
wave zoom full