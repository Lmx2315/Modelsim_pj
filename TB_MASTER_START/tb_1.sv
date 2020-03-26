module tb_1 ();

logic clk_48 				=0;
logic clk_96 				=0;
logic rst 	 				=0;

logic [47:0] FREQ     		=48'h0;
logic [47:0] FREQ_STEP 		=48'h0;
logic [31:0] FREQ_RATE 		=32'h0;
logic [63:0] TIME_START		=64'h0;
logic [63:0] TIME_INIT		=64'h0;
logic 		 SYS_TIME_UPDATE=0;
logic 		 T1HZ 			=0;
logic 		 WR 			=0;
logic [15:0] N_impuls 		=0;
logic [ 1:0] TYPE_impulse 	=0;
logic [31:0] Interval_Ti 	=0;
logic [31:0] Interval_Tp 	=0;
logic [31:0] Tblank1 		=0;
logic [31:0] Tblank2 		=0;

logic [47:0] 	wFREQ 		=0;
logic [47:0] 	wFREQ_STEP 	=0;
logic [31:0] 	wFREQ_RATE	=0;
logic 			DDS_START 	=0;

logic [15:0] dds_data_I;
logic [15:0] dds_data_Q;
logic 		 dds_valid ;

logic 		SYS_TIME_UPDATE_OK;
logic 		En_Iz;
logic 		En_Pr;


//----------DDS тактируется 96 МГц !!!---------------------------
dds_chirp (
	.clk 			(clk_96),    // Clock
	.DDS_freq 		(wFREQ),
	.DDS_delta_freq (wFREQ_STEP),
	.DDS_delta_rate (wFREQ_RATE),
	.start 			(DDS_START),
	.data_I 		(data_I),
	.data_Q 		(data_Q),
	.valid 			(dds_valid)	
);

//-------------Синхронизатор тактируется 48 МГц !!!-------------
MASTER_START (
.DDS_freq 			(wFREQ 				),
.DDS_delta_freq 	(wFREQ_STEP 		),
.DDS_delta_rate 	(wFREQ_RATE 		),
.DDS_start 			(DDS_START 			),
.RESET 				(rst 				),
.CLK 				(clk_48 			),
.SYS_TIME 			(TIME_INIT			),	//код времени для предустановки по сигналу T1c
.SYS_TIME_UPDATE 	(SYS_TIME_UPDATE 	),	//сигнал управления который включает готовность установки системного времени по сигналу T1hz 
.T1hz 				(T1HZ 				),	//сигнал секундной метки
.WR_DATA 			(WR 				),  //сигнал записи данных в синхронизатор
.MEM_DDS_freq 		(FREQ 				),
.MEM_DDS_delta_freq (FREQ_STEP  		),
.MEM_DDS_delta_rate (FREQ_RATE 			),
.MEM_TIME_START 	(TIME_START 		),
.MEM_N_impuls 		(N_impuls 			),
.MEM_TYPE_impulse 	(TYPE_impulse   	),  //тип формируемой пачки  :0 - повторяющаяся (некогерентный),1 - когерентная (DDS не перепрограммируется)
.MEM_Interval_Ti 	(Interval_Ti 		),
.MEM_Interval_Tp 	(Interval_Tp 		),
.MEM_Tblank1		(Tblank1 			),
.MEM_Tblank2 		(Tblank2 			),
.SYS_TIME_UPDATE_OK (SYS_TIME_UPDATE_OK ),	//флаг показывающий,что по секундной метке произошла установка системного времени
.En_Iz 				(En_Iz 				),
.En_Pr 				(En_Pr 				)
);

endmodule