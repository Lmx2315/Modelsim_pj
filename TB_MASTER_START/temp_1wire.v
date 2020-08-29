module temp_1wire(

input  wire clk,			 //тактирование
input  wire rst,			 //сброс модуля
output wire done,			 //сигнал готовности результата
output wire [15:0] T_data,//результат
output wire tmp_oe,          //временный сигнал,для отладки 
output wire tmp_out,         //временный сигнал,для отладки 
input  wire tmp_in,          //временный сигнал,для отладки 
inout  wire TEMP_DQ
);

parameter  FCLK   = 125;
localparam PPULSE = 60;
localparam CMD_length = 8+1;
localparam DATA_length=16+1;

enum {INIT,ROM_COMM,FUNC_COMM,RESET_PULSE,WAIT_DS,PRESENCE_PULSE,COMMAND,CMD_8hCC,CMD_8h44,CMD_8hBE,READ_TEMP,DQ_LINE_HOLD,IDLE}    WIRE_Var,WIRE_State,WIRE_Next,WIRE_Pointer;
enum {IDLE_TS,START_TS,WRITE_TS,END_TS} DATA_STATE,DATA_NEXT;

wire data_i;			//вход с шины   1-wire

logic tick_us=0;
logic [15:0] tmp_data=0;
logic [31:0] timer0=0;
logic [31:0] timer1=0;
logic [31:0] timer2=0;
logic [31:0] delay =0;
logic [31:0] presence_pulse=0;
logic [ 7:0] COMMAND_ROM=8'hCC;
logic 		 BIT_OUT=0;
logic [ 7:0] SCH_CMD=0;
logic [ 3:0] FLAG_STATE=0;
logic [ 3:0] N_STAGE=0;
logic [15:0] TEMP_DATA=0;

logic reg_data_o    =0;
logic reg_out_enable=0;
logic reg_data_i    =0;

//------------------часы---------------------
always_ff @(posedge clk)
if (rst)
begin
timer0<=0;
end else
begin
if (timer0!=FCLK) 
begin
timer0 <=timer0+1; 
tick_us<=0;
end
else 
	begin
	timer0<=0;
	tick_us<=1;
	end
end

always_ff @(posedge clk)
if ((tick_us)&&(timer1>0)) 
	begin
	timer1<=timer1-1;
	timer2<=timer2+1;
	end
else
	if (timer1==0) //нужно ввести задержку в такт!!!
		begin
		if (WIRE_State!=COMMAND) 
			begin
			if (FLAG_STATE==3) timer1<=delay;//для установки состояний
			end else
			if (FLAG_STATE==4) timer1<=delay;//для передачи даных
			
		timer2<=0;
		end

//-------------------------------------------
//      STATE MASHINE1
		
always_ff @(posedge clk)
if (rst) 
begin
WIRE_Var  <=CMD_8h44;//сначало посылаем команду "измерение температуры"
FLAG_STATE<=0;
delay	  <=0;
WIRE_State<=INIT;
DATA_STATE<=IDLE_TS;
   SCH_CMD<=CMD_length;//счётчик числа бит в команде
end
else
begin
	
	if (FLAG_STATE==0) 
	begin
	if (WIRE_State!=COMMAND) WIRE_State<=WIRE_Next;		
	FLAG_STATE<=1;
	end 
		else
			if (FLAG_STATE==1) FLAG_STATE<=2;
				else
					if (FLAG_STATE==2) FLAG_STATE<=3;
						else
							if (FLAG_STATE==3) 
							begin
							if  ((DATA_STATE==END_TS)&&(WIRE_State==COMMAND))  WIRE_State<=WIRE_Next;//закончили передавать команду
							FLAG_STATE<=4;
							end
								else
								if (FLAG_STATE==4) FLAG_STATE<=5;
									else
										if (timer1==0)     FLAG_STATE<=0;
	
	
	if (WIRE_State==DQ_LINE_HOLD)
	begin
	delay         <=200;     //проверяем линию DQ 200 us
	WIRE_Pointer  <=CMD_8h44;//какое состояние следующее
	end else
	if (WIRE_State==CMD_8hBE)
	begin
	delay         <=1;
	SCH_CMD       <=DATA_length;
	WIRE_Pointer  <=READ_TEMP;//какое состояние следующее
	COMMAND_ROM   <=8'hBE;
	end else
	if (WIRE_State==CMD_8hCC)
	begin
	delay         <=1;
	WIRE_Pointer  <=WIRE_Var;//какое состояние следующее
	WIRE_Var      <=CMD_8hBE;//команда чтения scratchpad-a
	COMMAND_ROM   <=8'hCC;
	end else
	if (WIRE_State==CMD_8h44)
	begin
	delay         <=1;
	WIRE_Pointer  <=DQ_LINE_HOLD;//какое состояние следующее
	end else
	if (WIRE_State==INIT)
	begin
	delay         <=1;
	reg_out_enable<=0;
	reg_data_o    <=1;	
	end else
	if (WIRE_State==RESET_PULSE)
	begin
	delay         <=480;
	reg_out_enable<=1;
	reg_data_o    <=0;	
	end else
	if (WIRE_State==WAIT_DS)
	begin
	delay         <=60;
	reg_out_enable<=1;
	reg_data_o    <=1;	
	end else
	if (WIRE_State==PRESENCE_PULSE)
	begin
	delay         <=480;
	reg_out_enable<=0;	
	if  (data_i==0) presence_pulse<=timer2; //подсчитываем длительность "нуля" ответа датчика  
	end else
	if (WIRE_State==COMMAND)
	begin
		if ((SCH_CMD!=0)&&(FLAG_STATE==2)) DATA_STATE<=DATA_NEXT; 

		if  (DATA_STATE==START_TS)
		begin
		if (FLAG_STATE==4) 
			begin
			SCH_CMD<=SCH_CMD-1;
			COMMAND_ROM<=COMMAND_ROM>>1;//отсылаем побитно начиная с младшего
			BIT_OUT<=COMMAND_ROM[0];
			end
		delay 		  <=12;//длительность интервала
		reg_out_enable<=1;
		reg_data_o    <=0;
		end else
		if (DATA_STATE==WRITE_TS)
		begin
		delay 		  <=90;			//длительность интервала
		if (BIT_OUT==0)
			begin
			reg_out_enable<=1;
			reg_data_o    <=0;
			end else
			begin
			reg_out_enable<=1;
			reg_data_o    <=1;
			end		
		end else
		if (DATA_STATE==END_TS)
		begin
		   SCH_CMD<=CMD_length;//счётчик числа бит в команде
		   DATA_STATE<=IDLE_TS;
		end
	end else
	if (WIRE_State==READ_TEMP)
	begin
		if ((SCH_CMD!=0)&&(FLAG_STATE==2)) DATA_STATE<=DATA_NEXT; 

		if  (DATA_STATE==START_TS)
		begin
		if (FLAG_STATE==4) 
			begin
			SCH_CMD  <=SCH_CMD-1;
			TEMP_DATA<=TEMP_DATA>>1;
			end
		delay 		  <=2;//длительность интервала
		reg_out_enable<=1;
		reg_data_o    <=0;
		end else
		if (DATA_STATE==WRITE_TS)
		begin
		reg_out_enable<=0; //освобождаем линию для слейва, чтобы прочитать что он там будет передавать
		delay 		  <=45;//длительность интервала
		TEMP_DATA[15] <=tmp_in;	
		end else
		if (DATA_STATE==END_TS)
		begin
		   tmp_data  <=TEMP_DATA;
		   DATA_STATE<=IDLE_TS;
		end
	end else
	if (WIRE_State==IDLE)
	begin
 	reg_out_enable<=0;
	reg_data_o    <=1;	
	end
end
//-------------------------------------------

always_comb
begin
case (WIRE_State)
		INIT	   		:WIRE_Next=RESET_PULSE;
		RESET_PULSE		:WIRE_Next=WAIT_DS;
		WAIT_DS	   		:WIRE_Next=PRESENCE_PULSE;
		PRESENCE_PULSE	:if (presence_pulse>PPULSE) WIRE_Next=CMD_8hCC;	else  WIRE_Next=IDLE;					
		COMMAND			:WIRE_Next=WIRE_Pointer;
		CMD_8h44		:WIRE_Next=COMMAND;	
		CMD_8hCC		:WIRE_Next=COMMAND;
		CMD_8hBE 		:WIRE_Next=COMMAND;
		READ_TEMP 		:WIRE_Next=IDLE;
		DQ_LINE_HOLD	:WIRE_Next=RESET_PULSE;  //ждём конца измерения температуры
		default 		:WIRE_Next=IDLE;
endcase
end		

always_comb
begin
case (DATA_STATE)
		 IDLE_TS:DATA_NEXT=START_TS;
		START_TS:DATA_NEXT=WRITE_TS;
		WRITE_TS:if (SCH_CMD!=1) DATA_NEXT=START_TS; else DATA_NEXT<=END_TS;
		default :DATA_NEXT=IDLE_TS;
endcase
end	

assign data_i	 =tmp_in;//TEMP_DQ;//
assign tmp_out   =reg_data_o;
assign tmp_oe    =reg_out_enable;
assign done      =1;
assign T_data    =tmp_data;
assign TEMP_DQ   =(reg_out_enable)?reg_data_o:1'bz;

endmodule	