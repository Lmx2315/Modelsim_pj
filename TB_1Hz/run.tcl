quit -sim
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/DDS_48_v1.v 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/DDS_48_v1_nco_ii_0.v 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/DMA_SPI.sv 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/master_start.sv 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/mem_wcw.v 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/tb_3.sv 
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/writer_com_mem.sv
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_1Hz/dds_chirp.sv
vsim -gui work.tb_3 -novopt -L C:/Work_murmansk/Quartus/Modelsim_pj/lib/verilog_libs/altera_mf_ver -L C:/Work_murmansk/Quartus/Modelsim_pj/lib/verilog_libs/altera_ver
add wave -position end sim:/tb_3/sync1/*
add wave -position end sim:/tb_3/wcm1/*
add wave -position insertpoint sim:/tb_3/dds1/*
run 30000 us
wave zoom full
