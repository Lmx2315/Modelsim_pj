module tb_1 ();




dds_chirp (
	.clk 			(),    // Clock
	.DDS_freq 		(),
	.DDS_delta_freq (),
	.DDS_delta_rate (),
	.start 			(),
	.data_I 		(),
	.data_Q 		(),
	.valid 			()	
);


MASTER_START (
.DDS_freq 			(),
.DDS_delta_freq 	(),
.DDS_delta_rate 	(),
.DDS_start 			(),
.RESET 				(),
.CLK 				(),
.TIME_RST 			(),
.SYS_TIME 			(),
.SYS_TIME_UPDATE 	(),//сигнал управления который включает готовность установки системного времени по сигналу T1hz 
.T1hz 				(),			  //сигнал секундной метки
.WR_DATA 			(),
.MEM_DDS_freq 		(),
.MEM_DDS_delta_freq (),
.MEM_DDS_delta_rate (),
.MEM_TIME_START 	(),
.MEM_N_impuls 		(),
.MEM_TYPE_impulse 	(),  //тип формируемой пачки  :0 - повторяющаяся (некогерентный),1 - когерентная (DDS не перепрограммируется)
.MEM_Interval_Ti 	(),
.MEM_Interval_Tp 	(),
.MEM_Tblank1		(),
.MEM_Tblank2 		(),
.SYS_TIME_UPDATE_OK (),//флаг показывающий,что по секундной метке произошла установка системного времени
.En_Iz 				(),
.En_Pr 				()
);

endmodule