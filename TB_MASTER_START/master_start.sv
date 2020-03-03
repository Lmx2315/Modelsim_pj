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

output FLAG_SYS_TIME_UPDATE,//флаг показывающий,что по секундной метке произошла установка системного времени

output En_Iz,
output En_Pr);

logic [63:0] TIME_MASTER=0;
logic l_En_Iz=0;
logic l_En_Pr=0;
logic [47:0] reg_MEM_DDS_freq      =0;
logic [47:0] reg_MEM_DDS_delta_freq=0;
logic [31:0] reg_MEM_DDS_delta_rate=0;
logic [47:0] reg_MEM_TIME_START    =0;
logic [15:0] reg_MEM_N_impuls      =0;
logic [31:0] reg_MEM_Interval_Ti   =0;
logic [31:0] reg_MEM_Interval_Tp   =0;
logic [31:0] reg_MEM_Tblank1       =0;
logic [31:0] reg_MEM_Tblank2       =0;
logic FLAG_SYS_TIME_UPDATE         =0;
logic FLAG_SYS_TIME_UPDATED        =0;
logic [3:0] frnt_T1hz=0;

logic [31:0] temp_TIMER1=0;



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
	if (WR_DATA)
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
end
else
begin
	if (reg_MEM_TIME_START==)


end


endmodule