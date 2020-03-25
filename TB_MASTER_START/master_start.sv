/////////////////////////////////////////////////////////////////////////////
// Copyright 2020 SS  
////////////////////////////////////////////////////////////////////////////

module MASTER_START (
output  [47:0] DDS_freq,
output  [47:0] DDS_delta_freq,
output  [31:0] DDS_delta_rate,
output         DDS_start,

input RESET,
input CLK,
input TIME_RST,
input [63:0] SYS_TIME,
input SYS_TIME_UPDATE,//сигнал управления который включает готовность установки системного времени по сигналу T1hz 
input T1hz,			  //сигнал секундной метки

input 		 WR_DATA,
input [47:0] MEM_DDS_freq,
input [47:0] MEM_DDS_delta_freq,
input [31:0] MEM_DDS_delta_rate,
input [47:0] MEM_TIME_START,
input [15:0] MEM_N_impuls,
input [31:0] MEM_Interval_Ti,
input [31:0] MEM_Interval_Tp,
input [31:0] MEM_Tblank1,
input [31:0] MEM_Tblank2,

output SYS_TIME_UPDATE_OK,//флаг показывающий,что по секундной метке произошла установка системного времени

output En_Iz,
output En_Pr);

logic [63:0] TIME_MASTER=0;			   // часы с шагом  1/125 мкс
logic reg_En_Iz=0;
logic reg_En_Pr=0;
logic reg_DDS_start;
logic [47:0] reg_MEM_DDS_freq      =0;//начальная частота DDS
logic [47:0] reg_MEM_DDS_delta_freq=0;//шаг перестройки частоты DDS
logic [31:0] reg_MEM_DDS_delta_rate=0;//скорость перестройки частоты DDS
logic [47:0] reg_MEM_TIME_START    =0;//время начала исполнения команды
logic [15:0] reg_MEM_N_impuls      =0;//число одинаковых импульсов 
logic [31:0] reg_MEM_Interval_Ti   =0;//интервал времени для излучения
logic [31:0] reg_MEM_Interval_Tp   =0;//интервал времени для приёма
logic [31:0] reg_MEM_Tblank1       =0;//интервал времени для тишины перед излучением
logic [31:0] reg_MEM_Tblank2       =0;//интервал времени для тишины перед приёмом
logic FLAG_SYS_TIME_UPDATE         =0;//флаг - готовности к апдейту часов по секундной метке
logic FLAG_SYS_TIME_UPDATED        =0;//флаг - исполнения синхронизации часов по секундной метки
logic [3:0] frnt_T1hz=0;
logic 		FLAG_START_PROCESS_CMD =0;//флаг означающий что команда начинает выполняться
logic 		FLAG_END_PROCESS_CMD   =0;//флаг означающий что команда выполненна
logic [31:0] temp_TIMER1=0;
logic [31:0] temp_TIMER2=0;
logic [31:0] temp_TIMER3=0;
logic [31:0] temp_TIMER4=0;

enum {idle,off,blank1,Tizl,blank2,Tpr,end_cycle} state,new_state;

always_ff @(posedge CLK) frnt_T1hz<={frnt_T1hz[2:0],T1hz}; //ищем фронт сигнала T1hz

//----------------системное время-------------------
always_ff @(posedge CLK)
if (RESET)
begin
TIME_MASTER<=64'h0;
end
	else
begin	
	if ((frnt_T1hz[3:1]==3'b011)&&(FLAG_SYS_TIME_UPDATE)) 	//если FLAG_SYS_TIME_UPDATE поднят и пришла секундная метка то переустанавливаем системное время
	begin
		TIME_MASTER          <=SYS_TIME;					//перезаписываем системное время
		FLAG_SYS_TIME_UPDATED<=1;							//устанавливаем флаг подтверждения что произошла переустановка системного времени!
	end
	else
	begin
		TIME_MASTER<=TIME_MASTER+1;							//счётчик системного времени в 1/125 мкс
		if (frnt_T1hz[3:1]!=3'b011) FLAG_SYS_TIME_UPDATED<=0;
	end
end
//--------------------------------------------------------
//-------------запись внутренних регистров данных---------
always_ff @(posedge CLK)
if (RESET)
begin
reg_MEM_DDS_freq 	  <=64'hffffffffffffffff;
reg_MEM_DDS_delta_freq<=64'hffffffffffffffff;
reg_MEM_DDS_delta_rate<=64'hffffffffffffffff;
reg_MEM_TIME_START 	  <=64'hffffffffffffffff;
reg_MEM_N_impuls      <=16'hffff;
reg_MEM_Interval_Ti   <=32'hffffffff;
reg_MEM_Interval_Tp   <=32'hffffffff;
reg_MEM_Tblank1       <=32'hffffffff;
reg_MEM_Tblank2       <=32'hffffffff;
end
else
	if (WR_DATA)  //по сигналу записи переносим данные со входов в управляющие регистры
begin
reg_MEM_DDS_freq 	  <=MEM_DDS_freq;
reg_MEM_DDS_delta_freq<=MEM_DDS_delta_freq;
reg_MEM_DDS_delta_rate<=MEM_DDS_delta_rate;
reg_MEM_TIME_START 	  <=MEM_TIME_START;
reg_MEM_N_impuls      <=MEM_N_impuls;
reg_MEM_Interval_Ti   <=MEM_Interval_Ti;
reg_MEM_Interval_Tp   <=MEM_Interval_Tp;
reg_MEM_Tblank1       <=MEM_Tblank1;
reg_MEM_Tblank2       <=MEM_Tblank2;
end
//-----------------------------------------------------------------
//        Модуль проверки срабатывания команды по времени
always_ff @(posedge CLK)
if (RESET)
begin
FLAG_START_PROCESS_CMD<=1'b0;	
end
else
begin
	if ((reg_MEM_TIME_START==TIME_MASTER)&&(FLAG_START_PROCESS_CMD==1'b0)) FLAG_START_PROCESS_CMD<=1'b1;
	else
		if (FLAG_END_PROCESS_CMD==1'b1) 								   FLAG_START_PROCESS_CMD<=1'b0;
end
//----------------------------------------------------------------
//        Модуль исполнения команды
always_ff @(posedge CLK)
if (RESET)
begin
state<=off;
end
else
begin
	    state<=new_state;
	if (state==off) //начальное состояние стейт-машины
	begin		
		temp_TIMER1  		<=reg_MEM_Tblank1;     //переписываем управляющие регистры в рабочие переменные
		temp_TIMER2  		<=reg_MEM_Tblank2;
		temp_TIMER3			<=reg_MEM_Interval_Ti;
		temp_TIMER4			<=reg_MEM_Interval_Tp;	
		reg_En_Iz    		<=1'b0;
		reg_En_Pr    		<=1'b0;
		reg_DDS_start		<=1'b0;
		FLAG_END_PROCESS_CMD<=1'b0;
	end	else
	if (state==idle)							//ожидание начала работы
		begin

		end else
	if (state==blank1)							//стейт машина: состояние первый бланк (бланк излучения)
		begin
			temp_TIMER1<=temp_TIMER1-1'b1;
		end else
	if (state==Tizl)							//стейт машина: состояние интервал излучения
		begin
			reg_DDS_start	<=1'b1;				//запускаем синтезатор DDS
			reg_En_Iz  		<=1'b1;				//поднимаем флаг "излучения"
			temp_TIMER2 	<=temp_TIMER2-1'b1;
		end else
	if (state==blank2)							//стейт машина: состояние второй бланк (бланк приёма)
		begin
			reg_DDS_start	<=1'b0;				//выключаем синтезатор DDS
			reg_En_Iz  		<=1'b0;				//снимаем флаг  "излучения"
			temp_TIMER3 	<=temp_TIMER3-1'b1;
		end else
	if (state==Tpr)								//стейт машина: состояние интервал приёма
		begin
			reg_En_Pr  <=1'b1;					//поднимаем флаг  "интервала приёма"
			temp_TIMER4<=temp_TIMER4-1'b1;
		end else
	if (state==end_cycle)				 		//стейт машина: состояние - конец цикла
		begin
			reg_En_Pr  			<=1'b0;			//снимаем флаг  "интервала приёма"
			FLAG_END_PROCESS_CMD<=1'b1;			//поднимаем флаг конца цикла
		end
end

//-------------STATE МАШИНА----------------------------------

always_comb
begin
	case (state)
		   off:								new_state=idle;
		  idle: if (FLAG_START_PROCESS_CMD)	new_state=blank1;
		blank1: if (temp_TIMER1==0)			new_state=Tizl;
		  Tizl: if (temp_TIMER2==0)			new_state=blank2;
  	    blank2: if (temp_TIMER3==0)			new_state=Tpr;
  	       Tpr: if (temp_TIMER4==0)			new_state=end_cycle;
  	 end_cycle:								new_state=off;
  	endcase
end 
//-----------------------------------------------------------


endmodule