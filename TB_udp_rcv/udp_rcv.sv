`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten
//{module {udp_reciver}}
module udp_rcv ( clk ,rx_data ,rx_sop ,rx_eop ,rx_rdy ,
	rx_dval ,rx_dsav ,rx_err ,rx_err_stat,rx_frm_type ,
	rx_mod ,rx_a_full ,rx_a_empty,rst,data_to_mem,
	stat_err,wren_mem,size,int_rsv,desc_wr);
 
//------SPI block------------------------
output int_rsv ;//прерывание для МК
wire   int_rsv ;

output [15:0] size ;
wire [15:0] size ;

output [31:0] stat_err ; //reg_rx_mod + reg_frm_type + reg_rcv_err + reg_err_stat
wire [31:0] stat_err ;

//--------------MEM block----------------
output wren_mem ;
wire wren_mem ;

output [31:0] data_to_mem ;
wire [31:0] data_to_mem ; 

output desc_wr;
wire desc_wr;
//--------------------------------------

input clk ;
wire clk ;	

output rx_rdy ;	 //to MAC eth
wire rx_rdy ;
input [31:0] rx_data ;
wire [31:0] rx_data ;
input rx_sop ;
wire rx_sop ;
input rx_eop ;
wire rx_eop ; 
input rx_dval ;
wire rx_dval ;
input rx_dsav ;
wire rx_dsav ;
input [5:0] rx_err ;
wire [5:0] rx_err ;
input [17:0] rx_err_stat ;
wire [17:0] rx_err_stat ;
input [1:0] rx_mod ;
wire [1:0] rx_mod ;
input rx_a_full ;
wire rx_a_full ;
input rx_a_empty ;
wire rx_a_empty ; 
input [3:0] rx_frm_type;
wire [3:0] rx_frm_type;

input rst ;
wire rst ;

enum {ST0,ST1,ST2,ST3,IDLE} state,next_state;

reg reg_rdy=0; 
reg reg_wren_mem=0;
reg [31:0] reg_data_to_mem=0;
reg [ 3:0] reg_frm_type=0;
reg [ 5:0] reg_rcv_err=0;
reg [17:0] reg_err_stat=0;
reg [ 1:0] reg_rx_mod=0;   
reg [15:0] reg_size=0;//размер принятого пакета
reg [15:0] reg_sch_size=0;
reg INT_packet_RCV=0; 
reg [31:0] timer_sch=0;
reg reg_desc_wr=0;

assign int_rsv    		=INT_packet_RCV;//прерывание о том что принят пакет и он лежит в памяти
assign wren_mem   		=reg_wren_mem;
assign data_to_mem 		=reg_data_to_mem;
assign stat_err   		={2'b00,reg_rx_mod,reg_frm_type,reg_rcv_err,reg_err_stat};  
assign rx_rdy     		=reg_rdy;	
assign size       		=reg_size;
assign desc_wr          =reg_desc_wr;//сигнал записи дескриптора в память фифо

always @(posedge clk)
if (rst)
begin	
reg_rdy<=0;
reg_wren_mem<=0;
INT_packet_RCV<=0;
reg_err_stat<=0;
reg_rcv_err<=0;
reg_rx_mod<=0;
reg_sch_size<='1;
timer_sch<=0;
state<=ST0;
end 
else 
	if (state==ST0)
	begin
	reg_rdy<=1;//разрешаем чтение из МАКа
	reg_sch_size<=0;
	timer_sch<=0;
	INT_packet_RCV<=0;
	state<=ST1;
	end 
	else
	if (state==ST1)
	begin
	    if (rx_dval) //принимаем валидные данные от МАКа
	    begin	
	    	if (rx_sop)  reg_sch_size<=0;
	    	else         reg_sch_size<=reg_sch_size+1;//считаем размер пакета в 32-х словах		
        	reg_wren_mem<=1;	            //разрешаем запись в память

	        if (rx_eop) //конец пакета
				begin	
					if (rx_mod==0) reg_data_to_mem<= rx_data;                  else//данные из МАКа в память	
					if (rx_mod==1) reg_data_to_mem<={rx_data[31: 8], 8'h00   };else
					if (rx_mod==2) reg_data_to_mem<={rx_data[31:16],16'h0000 };else
					if (rx_mod==3) reg_data_to_mem<={rx_data[31:24],24'h00000};

				    state         <=ST2;				
					reg_err_stat  <=rx_err_stat;//ошибки приёма , принимаются в последнем байте
					reg_rcv_err   <=rx_err; 
					reg_rx_mod    <=rx_mod;//показывает какой байт в последнем слове ненужный 00 - все нужны
					reg_rdy<=0;   //
				end else reg_data_to_mem<=rx_data;
        end
        else reg_wren_mem<=0;
					
	end else
	if (state==ST2)
	begin
	reg_wren_mem  <=0;
    reg_size      <=reg_sch_size;//запоминаем размер пакета
    reg_desc_wr   <=1;
    INT_packet_RCV<=1;           //ПОДНИМАЕМ ФЛАГ ПРЕРЫВАНИЯ НА МК
    state         <=ST3;
	end else
	if (state==ST3) //задержка 1 us
	begin
	reg_desc_wr   <=0;
    if (timer_sch<10) timer_sch<=timer_sch+1;
    else state         <=ST0;
	end

endmodule