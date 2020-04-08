onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 20 /tb_1/sync1/DDS_freq
add wave -noupdate -height 20 /tb_1/sync1/DDS_delta_freq
add wave -noupdate -height 20 /tb_1/sync1/DDS_delta_rate
add wave -noupdate -height 20 /tb_1/sync1/DDS_start
add wave -noupdate -height 20 /tb_1/sync1/REQ
add wave -noupdate -height 20 /tb_1/sync1/ACK
add wave -noupdate -height 20 /tb_1/sync1/RESET
add wave -noupdate -height 20 /tb_1/sync1/CLK
add wave -noupdate -height 20 /tb_1/sync1/SYS_TIME
add wave -noupdate -height 20 /tb_1/sync1/SYS_TIME_UPDATE
add wave -noupdate -height 20 /tb_1/sync1/T1hz
add wave -noupdate -height 20 /tb_1/sync1/WR_DATA
add wave -noupdate -height 20 /tb_1/sync1/MEM_DDS_freq
add wave -noupdate -height 20 /tb_1/sync1/MEM_DDS_delta_freq
add wave -noupdate -height 20 /tb_1/sync1/MEM_DDS_delta_rate
add wave -noupdate -height 20 /tb_1/sync1/MEM_TIME_START
add wave -noupdate -height 20 /tb_1/sync1/MEM_N_impuls
add wave -noupdate -height 20 /tb_1/sync1/MEM_TYPE_impulse
add wave -noupdate -height 20 /tb_1/sync1/MEM_Interval_Ti
add wave -noupdate -height 20 /tb_1/sync1/MEM_Interval_Tp
add wave -noupdate -height 20 /tb_1/sync1/MEM_Tblank1
add wave -noupdate -height 20 /tb_1/sync1/MEM_Tblank2
add wave -noupdate -height 20 /tb_1/sync1/SYS_TIME_UPDATE_OK
add wave -noupdate -height 20 /tb_1/sync1/En_Iz
add wave -noupdate -height 20 /tb_1/sync1/En_Pr
add wave -noupdate -height 20 /tb_1/sync1/TIME_MASTER
add wave -noupdate -height 20 /tb_1/sync1/reg_En_Iz
add wave -noupdate -height 20 /tb_1/sync1/reg_En_Pr
add wave -noupdate -height 20 /tb_1/sync1/reg_DDS_start
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_DDS_freq
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_DDS_delta_freq
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_DDS_delta_rate
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_TIME_START
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_N_impuls
add wave -noupdate -height 20 /tb_1/sync1/reg_temp_N_impuls
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_Interval_Ti
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_TYPE_impulse
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_Interval_Tp
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_Tblank1
add wave -noupdate -height 20 /tb_1/sync1/reg_MEM_Tblank2
add wave -noupdate -height 20 /tb_1/sync1/FLAG_SYS_TIME_UPDATE
add wave -noupdate -height 20 /tb_1/sync1/FLAG_SYS_TIME_UPDATED
add wave -noupdate -height 20 /tb_1/sync1/frnt_T1hz
add wave -noupdate -height 20 /tb_1/sync1/FLAG_START_PROCESS_CMD
add wave -noupdate -height 20 /tb_1/sync1/FLAG_END_PROCESS_CMD
add wave -noupdate -height 20 /tb_1/sync1/temp_TIMER1
add wave -noupdate -height 20 /tb_1/sync1/temp_TIMER2
add wave -noupdate -height 20 /tb_1/sync1/temp_TIMER3
add wave -noupdate -height 20 /tb_1/sync1/temp_TIMER4
add wave -noupdate -height 20 /tb_1/sync1/tmp_MEM_DDS_freq
add wave -noupdate -height 20 /tb_1/sync1/tmp_MEM_DDS_delta_freq
add wave -noupdate -height 20 /tb_1/sync1/tmp_MEM_DDS_delta_rate
add wave -noupdate -height 20 /tb_1/sync1/tmp_REQ
add wave -noupdate -height 20 /tb_1/sync1/FLAG_REQ
add wave -noupdate -height 20 /tb_1/sync1/state
add wave -noupdate -height 20 /tb_1/sync1/new_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1370 ns} 0} {{Cursor 2} {1390 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 255
configure wave -valuecolwidth 176
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1349 ns} {1753 ns}
