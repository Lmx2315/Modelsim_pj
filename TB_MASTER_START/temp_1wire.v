module temp_1wire(

input  wire clk,			//тактирование
input  wire rst,			//сброс модуля
output wire done,			//сигнал готовности результата
output wire [7:0] temp_data,//результат
output wire tmp_oe,         //временный сигнал,для отладки 
output wire tmp_out,        //временный сигнал,для отладки 
input  wire tmp_in,         //временный сигнал,для отладки 
inout  wire TEMP_DQ
);

parameter  FCLK   = 125;
localparam PPULSE = 60;
localparam CMD_length=8+1;

enum {INIT,ROM_COMM,FUNC_COMM,RESET_PULSE,WAIT_DS,PRESENCE_PULSE,COMMAND,IDLE}    WIRE_State,WIRE_Next;
enum {IDLE_TS,START_TS,WRITE_TS,END_TS} DATA_STATE,DATA_NEXT;

wire data_i;			//вход с шины   1-wire

logic tick_us=0;
logic [31:0] timer0=0;
logic [31:0] timer1=0;
logic [31:0] timer2=0;
logic [31:0] delay =0;
logic [31:0] presence_pulse=0;
logic [ 7:0] COMMAND_ROM=8'hCC;
logic 		 BIT_OUT=0;
logic [ 7:0] SCH_CMD=0;
logic [ 3:0] FLAG_STATE=0;

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
FLAG_STATE<=0;
delay	  <=0;
WIRE_State<=INIT;
DATA_STATE<=IDLE_TS;
   SCH_CMD<=CMD_length;//счётчик числа бит в команде
end
else
begin

//	if (timer1==0) FLAG_STATE	  <=1; else FLAG_STATE	  <=0;

//	if  ((FLAG_STATE    ==1     )&&(WIRE_State!=COMMAND))  begin WIRE_State<=WIRE_Next;  end
//	else 
//	if  ((DATA_STATE==END_TS)&&(WIRE_State==COMMAND))  WIRE_State<=WIRE_Next;//закончили передавать команду
	
	
	if (FLAG_STATE==0) 
	begin
	if (WIRE_State!=COMMAND) WIRE_State<=WIRE_Next;
	else
	if  ((DATA_STATE==END_TS)&&(WIRE_State==COMMAND))  WIRE_State<=WIRE_Next;//закончили передавать команду
	
	    FLAG_STATE<=1;
	end 
	else
	if (FLAG_STATE==1) FLAG_STATE<=2;
	else
	if (FLAG_STATE==2) FLAG_STATE<=3;
	else
	if (FLAG_STATE==3) FLAG_STATE<=4;
	else
	if (FLAG_STATE==4) FLAG_STATE<=5;
	else
	if (timer1==0)     FLAG_STATE<=0;
	
	
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
		PRESENCE_PULSE	:if (presence_pulse>PPULSE) WIRE_Next=COMMAND;	else  WIRE_Next=IDLE;					
		COMMAND			:WIRE_Next=IDLE;	
		default 		:WIRE_Next=IDLE;
endcase
end		

always_comb
begin
case (DATA_STATE)
		 IDLE_TS:DATA_NEXT=START_TS;
		START_TS:DATA_NEXT=WRITE_TS;
		WRITE_TS:if (SCH_CMD!=0) DATA_NEXT=START_TS; else DATA_STATE<=END_TS;
		default :DATA_NEXT=IDLE_TS;
endcase
end	

assign data_i	 =tmp_in;//TEMP_DQ;//
assign tmp_out   =reg_data_o;
assign tmp_oe    =reg_out_enable;
assign done      =1;
assign temp_data =8'hff;
assign TEMP_DQ   =(reg_out_enable)?reg_data_o:1'bz;

endmodule	