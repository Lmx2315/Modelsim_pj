cls
vlog -sv -reportprogress 300 -work work m_crc32_m8.sv
vlog -sv -reportprogress 300 -work work tb_CRC32_eth.sv
vsim -gui work.tb_CRC32_eth -novopt
run -all
