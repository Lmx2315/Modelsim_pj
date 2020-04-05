module wcm (
input 		  CLK 		    ,
input 		  rst_n 	    ,
input 		  REQ_COMM 	    ,
input  [47:0] FREQ          ,//данные с интерфейса МК
input  [47:0] FREQ_STEP     ,//----------------------
input  [31:0] FREQ_RATE     ,//--------//------------ 
input  [63:0] TIME_START    ,
input  [15:0] N_impuls 	    ,
input  [ 1:0] TYPE_impulse  ,
input  [31:0] Interval_Ti   ,
input  [31:0] Interval_Tp   ,
input  [31:0] Tblank1 	    ,
input  [31:0] Tblank2       ,
input 		 WR 		    ,
output [47:0] FREQ_z        ,//части команды выводимые из модуля в блок синхронизации и исполнения
output [47:0] FREQ_STEP_z   ,
output [31:0] FREQ_RATE_z   ,
output [63:0] TIME_START_z  ,
output [15:0] N_impuls_z    ,
output [ 1:0] TYPE_impulse_z,
output [31:0] Interval_Ti_z ,
output [31:0] Interval_Tp_z ,
output [31:0] Tblank1_z     ,
output [31:0] Tblank2_z    	 //-----//-------	 
)

parameter N_IDX=255;

logic [ 47:0] 	 tmp_FREQ 		    =0;
logic [ 47:0] 	 tmp_FREQ_STEP 	    =0;
logic [ 31:0] 	 tmp_FREQ_RATE	    =0;
logic [ 63:0]    tmp_TIME_START     =0;
logic [ 15:0]    tmp_N_impulse      =0;
logic [  1:0]    tmp_TYPE_impulse   =0;
logic [ 31:0]    tmp_Interval_Ti    =0;
logic [ 31:0]    tmp_Interval_Tp    =0;
logic [ 31:0]    tmp_Tblank1	    =0;
logic [ 31:0]    tmp_Tblank2	    =0;
logic [337:0]    data_sig           =0;
logic [337:0] 	   w_REG_DATA       =0;//данные для записи в реестр
logic [  7:0] 	   w_REG_ADDR       =0;//адрес в реестре куда можно делать свежую запись
logic [  7:0]     rd_REG_ADDR       =0;//адрес в реестре для чтения
logic [  7:0]	 tmp_REG_ADDR		=0;//
logic [  7:0]    clr_REG_ADDR 		=0;//адресс под очистку
logic 			 RD_REG 			=0;
logic 		   	 WR_REG	            =0;//сигнал записи в память реестра
logic 			 FLAG_WORK_PROCESS	=0;//сигнал что идёт какой-то процесс
logic 			 FLAG_CLR_COMMAND   =0;//флаг того что надо стереть команду в памяти
logic 			 FLAG_WR_COMMAND    =0;//флаг того что надо записать новую команду в память
logic 			 FLAG_SEARCH_MEM 	=0;
logic 			 FLAG_SPI_WR 		=0;//флаг того что произошла запись из spi
logic [  2:0]	 FLAG_REG_STATUS	=0;//флаг того что найдено место в памяти для новой команды
logic [337:0] 	 DATA_TIME_REG 		=0;//

always_ff @(posedge CLK or negedge rst_n) begin 
	if(~rst_n) 
	begin
	tmp_FREQ 		<=0;
	tmp_FREQ_STEP 	<=0;
	tmp_FREQ_RATE	<=0;
	tmp_TIME_START  <=0;
	tmp_N_impulse   <=0;
	tmp_TYPE_impulse<=0;
	tmp_Interval_Ti <=0;
	tmp_Interval_Tp <=0;
	tmp_Tblank1	    <=0;
	tmp_Tblank2	    <=0;
	end else
	if (WR)
	begin
	tmp_FREQ 		<=FREQ;
	tmp_FREQ_STEP 	<=FREQ_STEP;
	tmp_FREQ_RATE	<=FREQ_RATE;
	tmp_TIME_START  <=TIME_START;
	tmp_N_impulse   <=N_impulse;
	tmp_TYPE_impulse<=TYPE_impulse;
	tmp_Interval_Ti <=Interval_Ti;
	tmp_Interval_Tp <=Interval_Tp;
	tmp_Tblank1	    <=Tblank1;
	tmp_Tblank2	    <=Tblank2;
	FLAG_SEARCH_MEM	<=1'b1;			//вызываем процедуру поиска места под новую команду в памяти
	end	else
		begin
			FLAG_SEARCH_MEM 	<=1'b0;
		end
end

assign data_sig = {tmp_TIME_START,tmp_FREQ        ,tmp_FREQ_STEP  ,tmp_FREQ_RATE ,
				   tmp_N_impulse ,tmp_TYPE_impulse,tmp_Interval_Ti,tmp_Interval_Tp,tmp_Tblank1,tmp_Tblank2};
//------------------------блок записи данных в память----------------------
enum {idle,start,clrear,cycle,end_cycle 			  } clr_state,clr_next_state;
enum {clr_all,clr_data,wr_data,idle    				  } status   ,next_status   ; 
enum {search,end_search,read_data,end_read_data,idle  } rd_status,rd_next_status;

always_comb
 begin
	case (rd_status)
		       search:rd_next_status=end_search;
		   end_search:rd_next_status=idle;
		    read_data:rd_next_status=end_read_data;
		end_read_data:rd_next_status=idle;
	endcase
end

always_comb
 begin
	case (clr_state)
		 idle:clr_next_state=start;
		start:clr_next_state=clear;
		clear:clr_next_state=end_cycle;
	endcase
end

always_comb
 begin
	case (status)
		 clr_all:next_status=idle;
		clr_data:next_status=idle;
		 wr_data:next_status=idle;
	endcase
end

always_ff @(posedge CLK) 
begin
	if(~rst_n) 
	begin
	rd_status  <=idle;
	FLAG_REG_OK<=0;
	end else
	if (rd_status==idle)
	begin
	FLAG_REG_OK<=0;
	rd_REG_ADDR<=0;
	if (FLAG_SEARCH_MEM) rd_status<=search;//по сигналу приёма по spi данных - начинаем поиск свободной строки в памяти
	end else
	if (rd_status==search) 
	begin
		RD_REG<=1'b1;
	  if (DATA_TIME_REG[337:274]!=64'hFFFF_FFFF_FFFF_FFFF) 
	  	begin
	  		if (rd_REG_ADDR<N_IDX) rd_REG_ADDR<=rd_REG_ADDR+1'b1; 
	  		else 
	  			begin
	  			FLAG_REG_STATUS<=3'b011;	//не найдено свободное место в памяти
	  			rd_status 	   <=idle;
	  			end
	  	end else 
	  		begin
	  		FLAG_REG_STATUS<=3'b001;		//   найдено свободное место в памяти
	  		rd_status 	   <=rd_next_status;
	  		w_REG_ADDR     <=rd_REG_ADDR;	//запоминаем адресс под запись новой команды
	  	 	end
	end else
	if (rd_status==end_search)
	begin
		FLAG_WR_COMMAND<=1; 			//поиск успешно завершён вызываем процедуру записи в память команды
	end

end


//------------write---------------------
always_ff @(posedge CLK) 
begin 
	if(~rst_n) 
	begin
	FLAG_WORK_PROCESS <= 0;
	status            <= clr_all;
	tmp_REG_ADDR      <= 0;
	end else 
	if (status==clr_all) //режим очистки памяти
	begin
		FLAG_WORK_PROCESS<=1'b1;
		 if (tmp_REG_ADDR<N_IDX) 
		 	begin
		 		tmp_REG_ADDR<=tmp_REG_ADDR+1'b1;
		 		WR_REG      <=1'b1;
		 		w_REG_DATA  <={64'hffffffff_ffffffff,273'h0000};
		 	end	 else status<=next_status;
	end else
	if (status==clr_data) 			//режим удаления команды
	begin
		FLAG_WORK_PROCESS<=1'b1;
		tmp_REG_ADDR<=clr_REG_ADDR; //записываем адресс удаляемой строки из памяти
		WR_REG      <=1'b1;
	end else
	if (status==wr_data) 			//режим записи командного слова в память
	begin
		FLAG_WORK_PROCESS<=1'b1;
		tmp_REG_ADDR<=w_REG_ADDR;
		WR_REG      <=1'b1;
		w_REG_DATA  <=data_sig;
	end else
	if (status==idle)
	begin
				   FLAG_WORK_PROCESS<=1'b0;
						WR_REG      <=1'b0;
		if (FLAG_CLR_COMMAND) status<=clr_data;else
		if (FLAG_WR_COMMAND ) status<=wr_data ;
	end 
end
 

registre_MEM	
sregistre_MEM_inst (
	.clock 			( CLK ),
	.data 			( w_REG_DATA ),
	.rdaddress 		( rd_REG_ADDR ),
	.rden 			( RD_REG ),
	.wraddress 		( tmp_REG_ADDR ),
	.wren 			( WR_REG  ),
	.q 				( DATA_TIME_REG )
	);


endmodule