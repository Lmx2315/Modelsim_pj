module wcm (
input 		 CLK 		   ,
input 		 rst_n 		   ,
input [47:0] FREQ          ,
input [47:0] FREQ_STEP     ,
input [31:0] FREQ_RATE     , 
input [63:0] TIME_START    ,
input [15:0] N_impuls 	   ,
input [ 1:0] TYPE_impulse  ,
input [31:0] Interval_Ti   ,
input [31:0] Interval_Tp   ,
input [31:0] Tblank1 	   ,
input [31:0] Tblank2       ,
input 		 WR 		    		 
)

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
logic [338:0] 	 w_REG_DATA         =0;//данные для записи в реестр
logic [  7:0] 	 w_REG_ADDR         =0;//адрес в реестре куда можно делать свежую запись
logic [  7:0]	 tmp_REG_ADDR		=0;
logic 		   	 WR_REG	            =0;//сигнал записи в память реестра

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
	end
end

assign data_sig = {tmp_FREQ       ,tmp_FREQ_STEP  ,tmp_FREQ_RATE,
				   tmp_TIME_START ,tmp_N_impulse  ,tmp_TYPE_impulse,
				   tmp_Interval_Ti,tmp_Interval_Tp,tmp_Tblank1,tmp_Tblank2};

always_ff @(posedge CLK)
begin
	w_REG_DATA<=data_sig;
	WR_REG    <=1'b1;
	w_REG_ADDR<=tmp_REG_ADDR;
end 

registre_MEM	
sregistre_MEM_inst (
	.clock 			( CLK ),
	.data 			( w_REG_DATA ),
	.rdaddress 		(  ),
	.rden 			(  ),
	.wraddress 		( w_REG_ADDR ),
	.wren 			(  ),
	.q 				(  )
	);


endmodule