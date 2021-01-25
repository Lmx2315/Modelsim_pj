//---------------------------------------------------------------
//автор СС ОАО НПК НИИДАР
//
//
//модуль приёма 51 байта данных из МК по SPI (через мк-ный DMA)
//Прием данных работает на частоте SPI МК и переводится в домен CLK ПЛИС
//когда МК посылает како-то время отличное от нуля - устанавливается флаг синхронизации с
//секундной меткой.
//---------------------------------------------------------------
`timescale 1 ns / 1 ns
module spi_read ( clk,sclk,mosi,miso,cs,clr,inport );	

parameter Nbit=8;	
parameter param_adr=1; 

input  [Nbit-1:0] inport ;
wire   [Nbit-1:0] inport ;

output  miso;
input clk ;
wire clk ;	 
input sclk ;
wire sclk ;
input mosi ;
wire mosi ;
input cs ;
wire cs ;

output  clr;

logic [Nbit:0] data_tmp ;//асинхронный регистр
logic [Nbit:0] data_sync;//синхронный регистр

logic [2:0] FLAG_SYNC=0;


logic [7:0] sch=0;
logic [7:0] sch_rd=0;

logic [7:0]  REG_SPI=0;

logic 		 FLAG_SPI_ADR_RCV     =0;
logic 		 FLAG_SPI_ADR_OK      =0;
logic        FLAG_SPI_DATA_PROCESS=0;

//------синхронный приём на частоте SPI----------
always_ff @(posedge sclk or posedge cs) 
 if(cs) sch<=8'h00;
	else
 	begin
 		 if (sch<7) sch<=sch+1; else sch<=8'hff;
		 REG_SPI<={REG_SPI[6:0],mosi};
	end 
	 


always_ff @(negedge sclk or posedge cs) 
 if(cs) 
 begin 
 sch_rd  <=8'h00;
 data_tmp<='1;
 end
 else
 	begin
		 if (FLAG_SPI_DATA_PROCESS)
		 	begin
		 		if (FLAG_SPI_ADR_OK)  data_tmp<=data_sync<<1;
		 		else   		 	      data_tmp<=data_tmp <<1;
		 	  	sch_rd<=sch_rd+1;
		 	end  
	end 

//----------------------------------------------
always_ff @(posedge clk)
begin
	if (sch==8'hff)
	begin
		 FLAG_SPI_ADR_RCV<=1;
		 data_sync<=inport;
	end
	else 
		begin
		FLAG_SPI_ADR_RCV<=0;
		data_sync<='1;
		end
end

always_ff @(posedge clk) 
begin
	if (FLAG_SPI_ADR_RCV)
	begin
		if (REG_SPI==param_adr) 
		begin 
			  FLAG_SPI_ADR_OK<=1;
		end 
		else  FLAG_SPI_ADR_OK<=0;
	end 
		else  FLAG_SPI_ADR_OK<=0;
end

always_ff @(posedge clk) 
begin
	if (FLAG_SPI_ADR_OK)  begin FLAG_SPI_DATA_PROCESS<=1; FLAG_SYNC<=1;end
	else
		begin
        if (sch_rd==Nbit) 
        	begin 
        	FLAG_SPI_DATA_PROCESS<=0;
        	FLAG_SYNC<=FLAG_SYNC<<1;
        	end
		end
end

assign miso=data_tmp[Nbit];
assign clr =FLAG_SYNC[2];

endmodule