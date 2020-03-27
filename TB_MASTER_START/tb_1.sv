`timescale 1 ns / 1 ns

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

logic wREQ=0;
logic wACK=0;

always #10.41666 clk_48=~clk_48;
always # 5.20833 clk_96=~clk_96;

initial
begin
	@(posedge clk_48)
	FREQ 			=48'h1000000000 	 ;
	FREQ_STEP 		=48'h100000    		 ;
	FREQ_RATE 		=48'h100 	   		 ;
	TIME_START 		=64'h00000000000012C0;  //пауза 100 мкс
	N_impuls 		=16'h2 				 ;  //число рабочих интервалов (импульсов излучения/приёма)
	TYPE_impulse 	= 2'h1 				 ;  //тип пачки импульсов - когерентная(когда DDS в паузе не выключается) или нет 
	Interval_Ti 	=32'h1800 			 ;  //длительность 128 мкс х 48 
	Interval_Tp 	=32'h1800 			 ;  //длительность 128 мкс х 48 
	Tblank1 	 	=32'h180 			 ;  //длительность   8 мкс х 48 
	Tblank2 	 	=32'h180 			 ;  //длительность   8 мкс х 48 
	TIME_INIT 		=64'h0000000000000000;
	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b1 				 ;
	T1HZ 			= 1'b0 				 ;
	rst 			= 1'b0 				 ;

	#30
	@(posedge clk_48)
	rst 			= 1'b1 				 ;
	#30
	@(posedge clk_48)
	rst 			= 1'b0 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b1 				 ;
	SYS_TIME_UPDATE = 1'b1 				 ;
	T1HZ 			= 1'b0 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b1 				 ;
	T1HZ 			= 1'b0 				 ;

	#1000;
	@(posedge clk_48)

	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b1 				 ;
	T1HZ 			= 1'b1 				 ;	

	#1000;
	@(posedge clk_48)
	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b0 				 ;
	T1HZ 			= 1'b0 				 ;


//--------------------------------------------------------------------
	#700000;
	@(posedge clk_48)
	FREQ 			=48'h2000000000 	 ;
	FREQ_STEP 		=48'h200000    		 ;
	FREQ_RATE 		=48'h200 	   		 ;
	TIME_START 		=64'h000000000000a48e;  //877 мкс
	N_impuls 		=16'h1 				 ;  //число рабочих интервалов (импульсов излучения/приёма)
	TYPE_impulse 	= 2'h1 				 ;  //тип пачки импульсов - когерентная(когда DDS в паузе не выключается) или нет 
	Interval_Ti 	=32'h2800 			 ;  //длительность 128 мкс х 48 
	Interval_Tp 	=32'h2800 			 ;  //длительность 128 мкс х 48 
	Tblank1 	 	=32'h280 			 ;  //длительность   8 мкс х 48 
	Tblank2 	 	=32'h280 			 ;  //длительность   8 мкс х 48 
	TIME_INIT 		=64'h0000000000000000;
	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b0 				 ;
	T1HZ 			= 1'b0 				 ;
	rst 			= 1'b0 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b1 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b0 				 ;

	//--------------------------------------------------------------------
	#640000;
	@(posedge clk_48)
	FREQ 			=48'h3000000000 	 ;
	FREQ_STEP 		=48'h300000    		 ;
	FREQ_RATE 		=48'h300 	   		 ;
	TIME_START 		=64'h000000000001380b;  //1664 мкс
	N_impuls 		=16'h4 				 ;  //число рабочих интервалов (импульсов излучения/приёма)
	TYPE_impulse 	= 2'h0 				 ;  //тип пачки импульсов - когерентная(когда DDS в паузе не выключается) или нет 
	Interval_Ti 	=32'h0800 			 ;  //длительность 128 мкс х 48 
	Interval_Tp 	=32'h0800 			 ;  //длительность 128 мкс х 48 
	Tblank1 	 	=32'h080 			 ;  //длительность   8 мкс х 48 
	Tblank2 	 	=32'h080 			 ;  //длительность   8 мкс х 48 
	TIME_INIT 		=64'h0000000000000000;
	WR 				= 1'b0 				 ;
	SYS_TIME_UPDATE = 1'b0 				 ;
	T1HZ 			= 1'b0 				 ;
	rst 			= 1'b0 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b1 				 ;

	#100;
	@(posedge clk_48)

	WR 				= 1'b0 				 ;

end


//----------DDS тактируется 96 МГц !!!---------------------------

dds_chirp 
dds1(
	.clk_96 		(clk_96 	),    	// Clock
	.clk_48 		(clk_48 	),
	.REQ			(wREQ		),  	//запрос на передачу данных из 125 МГц в 96 МГц
    .ACK			(wACK		),		//подтверждение что данные переданы
	.DDS_freq 		(wFREQ 		),
	.DDS_delta_freq (wFREQ_STEP ),
	.DDS_delta_rate (wFREQ_RATE ),
	.start 			(DDS_START 	),
	.data_I 		(data_I 	),
	.data_Q 		(data_Q 	),
	.valid 			(dds_valid 	)	
);

//-------------Синхронизатор тактируется 48 МГц !!!-------------
MASTER_START 
sync1(
.DDS_freq 			(wFREQ 				),
.DDS_delta_freq 	(wFREQ_STEP 		),
.DDS_delta_rate 	(wFREQ_RATE 		),
.DDS_start 			(DDS_START 			),
.REQ				(wREQ				),	//запрос на передачу данных
.ACK				(wACK				),
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