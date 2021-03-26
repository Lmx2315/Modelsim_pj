
quit -sim
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_delay_96/delay_96.sv
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_delay_96/tb_delay_96.sv
vsim -gui -novopt work.tb_delay_96
#add wave -position insertpoint sim:/tb_delay_96/inst_delay_96_0/*
#add wave -position insertpoint sim:/tb_delay_96/inst_delay_96_1/*
#add wave -position insertpoint  \
sim:/tb_delay_96/inst_delay_96_1/tmp
run 7 us

