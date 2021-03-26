quit -sim
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_code
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_code/code.v
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_code/tb_1.sv
vsim -gui -novopt work.tb_1
add wave -position insertpoint sim:/tb_1/inst1/*
run 10 us