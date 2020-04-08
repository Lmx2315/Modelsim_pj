module wcm (
input 		  CLK 		    ,
input 		  rst_n 	    ,
input 		  REQ_COMM 	    ,
input  [63:0] TIME 			,
input  [47:0] FREQ          ,//данные с интерфейса МК
input  [47:0] FREQ_STEP     ,//----------------------
input  [31:0] FREQ_RATE     ,//--------//------------ 
input  [63:0] TIME_START    ,
input  [15:0] N_impulse     ,
input  [ 1:0] TYPE_impulse  ,
input  [31:0] Interval_Ti   ,
input  [31:0] Interval_Tp   ,
input  [31:0] Tblank1 	    ,
input  [31:0] Tblank2       ,
input 		       WR	    ,
output 		  DATA_WR 		,//сигнал записи данных команды в блок синхронизации
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
);

parameter N_IDX      = 255;//размер памяти в строках (N-1)
parameter TIME_REZERV=48*8;//8 мкс запас времени
//-------регистры для хранения команды из spi
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
//-------регистры для хранения команды считаной из памяти реального времени
logic [ 47:0] 	 mem_FREQ 		    =0;
logic [ 47:0] 	 mem_FREQ_STEP 	    =0;
logic [ 31:0] 	 mem_FREQ_RATE	    =0;
logic [ 63:0]    mem_TIME_START     =0;
logic [ 15:0]    mem_N_impulse      =0;
logic [  1:0]    mem_TYPE_impulse   =0;
logic [ 31:0]    mem_Interval_Ti    =0;
logic [ 31:0]    mem_Interval_Tp    =0;
logic [ 31:0]    mem_Tblank1	    =0;
logic [ 31:0]    mem_Tblank2	    =0;
//----------------------------------------
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
logic 			 FLAG_CMD_SEARCH    =0;//флаг что найдена команда к исполнению в следующие 8 мкс
logic 			 FLAG_SPI_WR 		=0;//флаг того что произошла запись из spi
logic [  2:0]	 FLAG_REG_STATUS	=0;//флаг того что найдено место в памяти для новой команды
logic [337:0] 	 DATA_TIME_REG 		=0;//
logic [ 63:0]    CMD_TIME			=0;//время исполнения команды
logic [ 63:0]    reg_TIME 			=0;//тут храним текущее время
logic [ 63:0]    tmp_TIME 			=0;//временное время, для поиска ближайшей на исполнение команды
logic 			 reg_DATA_WR		=0;//сигнал записи данных в память синхроблока

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

always_ff @(posedge CLK) 
begin
	if(~rst_n) 
	begin
	reg_TIME<= 64'h0;
	end else
	 begin
	 reg_TIME <= TIME ;//перезапоминаем время
	 tmp_TIME <= reg_TIME+TIME_REZERV;
	 end
end

//------------------------блок записи данных в память----------------------
enum {idle_clr,start,clear,cycle,end_cycle			  							  } clr_state,clr_next_state;
enum {clr_all,clr_data,wr_data,idle_status			  							  } status   ,next_status   ; 
enum {search,end_search,read_data,end_read_data,search_time,end_search_time,idle  } rd_status,rd_next_status;

always_comb
 begin
	case (rd_status)
		       search:rd_next_status=end_search;
		   end_search:rd_next_status=idle;
		    read_data:rd_next_status=end_read_data;
		end_read_data:rd_next_status=idle;
		  search_time:rd_next_status=end_search_time;
	  end_search_time:rd_next_status=idle;
	endcase
end

always_comb
 begin
	case (clr_state)
		 idle_clr:clr_next_state=start;
		    start:clr_next_state=clear;
		    clear:clr_next_state=end_cycle;
	endcase
end

//-------тут всё чтение!-----------------------
always_ff @(posedge CLK) 
begin
	if(~rst_n) 
	begin
	rd_status  <=idle;
	end else
	if (rd_status==idle)
	begin
	rd_REG_ADDR<=0;
	if (FLAG_SEARCH_MEM) rd_status<=search;   //по сигналу приёма по spi данных - начинаем поиск свободной строки в памяти
	if (REQ_COMM) 		 rd_status<=read_data;//считываем новую(подготовленную) команду для синхронизатора 
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
	end else
	if (rd_status==read_data)
	begin
	reg_DATA_WR   <=1;					//устанавливаем сигнал записи данных в блок синхронизации
	end else
	if (rd_status==end_read_data)
	begin
	reg_DATA_WR   <=0;
	end else
	if (rd_status==search_time)
	begin
	if (!((DATA_TIME_REG[337:274]<tmp_TIME)&& //сравниваем время исполнения с временным временем
	      (DATA_TIME_REG[337:274]>reg_TIME)))  //проверяем что время исполнения команды актуальное (не старое)	
	  	begin
	  		if (rd_REG_ADDR<N_IDX) rd_REG_ADDR<=rd_REG_ADDR+1'b1; 
	  		else 
	  			begin
	  			FLAG_CMD_SEARCH<=0;	//не найдена команда
	  			rd_status 	   <=idle;
	  			end
	  	end else 
	  		begin
	  		FLAG_CMD_SEARCH<=3'b001;		//   найдена команда для исполнения
	  		rd_status 	   <=rd_next_status;
	  		w_REG_ADDR     <=rd_REG_ADDR;	//запоминаем адресс команды
	  	 	end	
	end else
	if (rd_status==end_search_time)//сохраняем данные команды в промежуточные регисты перед выдачей
	begin
		{
		mem_TIME_START  ,
		mem_FREQ        ,
		mem_FREQ_STEP   ,
		mem_FREQ_RATE   ,
	    mem_N_impulse   ,
	    mem_TYPE_impulse,
	    mem_Interval_Ti ,
	    mem_Interval_Tp ,
	    mem_Tblank1     ,
	    mem_Tblank2}      <=DATA_TIME_REG;
	end 

end

assign DATA_WR       = reg_DATA_WR     ;
assign FREQ_z        = mem_FREQ        ;      
assign FREQ_STEP_z   = mem_FREQ_STEP   ;
assign FREQ_RATE_z   = mem_FREQ_RATE   ;
assign TIME_START_z  = mem_TIME_START  ;
assign N_impuls_z    = mem_N_impulse   ;
assign TYPE_impulse_z= mem_TYPE_impulse;
assign Interval_Ti_z = mem_Interval_Ti ;
assign Interval_Tp_z = mem_Interval_Tp ;
assign Tblank1_z     = mem_Tblank1     ;
assign Tblank2_z     = mem_Tblank2     ;	

//------------write---------------------
always_comb
 begin
	case (status)
		 clr_all:next_status=idle_status;
		clr_data:next_status=idle_status;
		 wr_data:next_status=idle_status;
	endcase
end

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
		 		w_REG_DATA  <={64'hffffffff_ffffffff,274'h0000};
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
		w_REG_DATA  <={tmp_TIME_START,tmp_FREQ        ,tmp_FREQ_STEP  ,tmp_FREQ_RATE ,
				   	   tmp_N_impulse ,tmp_TYPE_impulse,tmp_Interval_Ti,tmp_Interval_Tp,tmp_Tblank1,tmp_Tblank2};
		status<=next_status;
	end else
	if (status==idle_status)
	begin
				   FLAG_WORK_PROCESS<=1'b0;
						WR_REG      <=1'b0;
		if (FLAG_CLR_COMMAND) status<=clr_data;else
		if (FLAG_WR_COMMAND ) status<=wr_data ;
	end 
end
 

mem1	
registre_MEM_inst (
	.clock 			( CLK ),
	.data 			( w_REG_DATA ),
	.rdaddress 		( rd_REG_ADDR ),
	.rden 			( RD_REG ),
	.wraddress 		( tmp_REG_ADDR ),
	.wren 			( WR_REG  ),
	.q 				( DATA_TIME_REG )
	);


endmodule