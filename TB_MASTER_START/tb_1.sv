module tb_1 ();

logic clk_125=0;
logic clk_96 =0;
logic rst=0;

logic [47:0] FREQ     =48'h0;
logic [47:0] FREQ_STEP=48'h0;
logic [31:0] FREQ_RATE=32'h0;
logic [63:0] TIME_INIT=64'h0;

logic [47:0] 	wFREQ;
logic [47:0] 	wFREQ_STEP;
logic [31:0] 	wFREQ_RATE;
logic 			DDS_START;

logic [15:0] dds_data_I;
logic [15:0] dds_data_Q;
logic 		 dds_valid ;


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

//-------------Синхронизатор тактируется 125 МГц !!!-------------
MASTER_START (
.DDS_freq 			(wFREQ 		),
.DDS_delta_freq 	(wFREQ_STEP ),
.DDS_delta_rate 	(wFREQ_RATE ),
.DDS_start 			(DDS_START 	),
.RESET 				(rst),
.CLK 				(clk_125),
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