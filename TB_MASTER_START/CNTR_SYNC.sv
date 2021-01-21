
`timescale 1 ps / 1 ps

module cntr_module(
	input clk,     //сюда подавать 48 МГц
	input clk125,  //сюда подавать 125 МГц
	input sync0,
	input sync1,
	input sync2,   //секундная метка
	input rst,
	output logic FLAG_1Hz,    //флаг сообщает об источнике секундной метки 1 - внешняя , 0 - внутренняя
	output logic T1hz,		  //выход секундной метки, либо внешней либо внутренней
	output logic [31:0] duration_T1hz,
	output logic [31:0] max0,
	output logic [31:0] max1,
	output logic [31:0] max2,
	output logic [31:0] min0,
	output logic [31:0] min1,
	output logic [31:0] min2

	);

parameter FREQ_CLK = 48_000;
parameter DELTA    = 1000;

logic [3:0] frnt0=0;
logic [3:0] frnt1=0;
logic [3:0] frnt2=0;

logic [31:0] sch0=0;
logic [31:0] sch1=0;
logic [31:0] sch2=0;

logic [31:0] time_T1hz=0;
logic [31:0] data_T1hz=0;

logic [31:0] time0_min='1;
logic [31:0] time1_min='1;
logic [31:0] time2_min='1;

logic [31:0] time0_max='0;
logic [31:0] time1_max='0;
logic [31:0] time2_max='0;

logic [31:0] dmin0=0;
logic [31:0] dmin1=0;
logic [31:0] dmin2=0;

logic [31:0] dmax0=0;
logic [31:0] dmax1=0;
logic [31:0] dmax2=0;

logic FLAG_RST0=0;
logic FLAG_RST1=0;
logic FLAG_RST2=0;

logic FLAG_RESET=0;

logic flg0=0;		   //флаг наличия внешней секундной метки
logic [31:0] sch_1hz=0;//счётчик секундной метки
logic flg_1Hz=0;	   //импульс внутренней секундной метки

always_ff @(posedge clk125) //переводим в другой клоковый домен
begin
dmax0<=time0_max;
dmax1<=time1_max;
dmax2<=time2_max;

dmin0<=time0_min;
dmin1<=time1_min;
dmin2<=time2_min;

data_T1hz<=time_T1hz;
end

always_ff @(posedge clk)
begin
	if (sch_1hz<(FREQ_CLK-1)) 
		begin
		if (sch_1hz>(FREQ_CLK-100))	flg_1Hz<=1'b1;
			sch_1hz<=sch_1hz+1'b1; 
		end
	else 
	begin 
		sch_1hz<=0; 
		flg_1Hz<=1'b0; 
	end
end

always_ff @(posedge clk) frnt0<={frnt0[2:0],sync0};
always_ff @(posedge clk) frnt1<={frnt1[2:0],sync1};
always_ff @(posedge clk) frnt2<={frnt2[2:0],sync2};//секундная метка


always_ff @(posedge clk) 
begin
if (frnt0[3:1]==3'b011) sch0<='0; else if (sch0<'1)  sch0<=sch0+1'b1;
if (frnt1[3:1]==3'b011) sch1<='0; else if (sch1<'1)  sch1<=sch1+1'b1;
if (frnt2[3:1]==3'b011) sch2<='0; else if (sch2<'1)  sch2<=sch2+1'b1;
end

always_ff @(posedge clk or negedge rst) 
begin 
	if(~rst) begin
 	time0_max<='0;
 	time1_max<='0;
 	time2_max<='0;

 	FLAG_RST0<=1;
 	FLAG_RST1<=1;
 	FLAG_RST2<=1;
	end else 
	begin
		if (frnt0[3:1]==3'b011) 
		begin		  
		 	if (time0_min>sch0) time0_min<=sch0+1;
		 	if (time0_max<sch0) time0_max<=sch0+1; 
		end else 
			begin
				if (FLAG_RST0) begin time0_min<='1; FLAG_RST0<=0;end
				if (time0_max<sch0) time0_max<=sch0; 
			end

		if (frnt1[3:1]==3'b011) 
		begin
		 	if (time1_min>sch1) time1_min<=sch1+1;
		 	if (time1_max<sch1) time1_max<=sch1+1;
		end else 
			begin
				if (FLAG_RST1) begin time1_min<='1; FLAG_RST1<=0;end
				if (time1_max<sch1) time1_max<=sch1; 
			end

		if (frnt2[3:1]==3'b011) //секундная метка
		begin	  
		 	if (time2_min>sch2) time2_min<=sch2+1;
		 	if (time2_max<sch2) time2_max<=sch2+1;
		 	                    time_T1hz<=sch2+1;//remember the current duration second mark
		 	if (sch2>(FREQ_CLK-DELTA)) flg0<=1;//проверяем что интервал секундной метки не короче минимума
		end else 
			begin	
				if (FLAG_RST2) begin time2_min<='1; FLAG_RST2<=0;end
				if (time2_max<sch2) time2_max<=sch2;
				if (sch2>(FREQ_CLK+DELTA))  flg0<=0; //сбрасываем флаг внешней секундной метки, если интервал секндной метки превышен!
			end
	end
end
	assign FLAG_1Hz	    = flg0;
	assign T1hz 	    =(flg0)?sync2:flg_1Hz; //если флаг внешней секундной метки есть - то выводим её
	assign max0		    =dmax0;
	assign max1		    =dmax1;
	assign max2		    =dmax2;
	assign min0		    =dmin0;
	assign min1		    =dmin1;
	assign min2		    =dmin2;
	assign duration_T1hz=data_T1hz;

endmodule