vsim -c
.main clear
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32/crc32_m7.sv
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32/tb_CRC32_eth.sv
vsim -gui work.tb_CRC32_eth -novopt
run 10 us
