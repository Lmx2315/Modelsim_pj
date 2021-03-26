vsim -c
.main clear
cd C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32
vlog -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32/crc32_m7.sv
vlog -sv -reportprogress 300 -work work C:/Work_murmansk/Quartus/Modelsim_pj/TB_crc32/tb_CRC32_eth.sv
vsim -gui work.tb_CRC32_eth -novopt
run 10 us



55555555555555D50010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011

crc:
B331881B