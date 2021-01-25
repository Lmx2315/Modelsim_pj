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
module spi_write ( clk,sclk,mosi,miso,cs,clr,out);	

parameter Nbit=8;	
parameter param_adr=1; 

output  [Nbit-1:0] out ;

output  miso;
output  clr;

input clk ;
wire clk ;	 
input sclk ;
wire sclk ;
input mosi ;
wire mosi ;
input cs ;
wire cs ;

logic [Nbit-1:0] data_tmp='1;//

logic FLAG_SYNC=0;
logic [7:0] sch=0;
logic [Nbit+8-1:0]  REG_SPI=0;
logic [6:0] ADR='1;
logic 	FLAG_WR=0;

logic [2:0] frnt=0;

logic 		 FLAG_SPI_ADR_RCV     =0;
logic 		 FLAG_SPI_ADR_OK      =0;
logic        FLAG_SPI_DATA_PROCESS=0;

//------синхронный приём на частоте SPI----------
always_ff @(posedge sclk or posedge cs) 
 if(cs) sch<=8'h00;
 else
 	begin
 		 if (sch<(Nbit+8-1)) sch<=sch+1; else sch<=8'hff;
		 REG_SPI<={REG_SPI[Nbit+8-2:0],mosi};
	end 
//----------------------------------------------
always_ff @(posedge clk) frnt<={frnt[1:0],FLAG_SPI_ADR_RCV};//ищем фронт флага

always_ff @(posedge clk)
if (sch==8'hff)
begin
	 ADR    <=REG_SPI[Nbit+8-2:Nbit];
	 FLAG_WR<=REG_SPI[Nbit+8-1];
	 FLAG_SPI_ADR_RCV<=1;
end 
else FLAG_SPI_ADR_RCV<=0;

always_ff @(posedge clk)
if (frnt==3'b001)
begin
	if ((ADR    ==param_adr)&&(FLAG_WR==1'b1)) FLAG_SPI_ADR_OK<=1;
	else 									   FLAG_SPI_ADR_OK<=0;
end
	else
		if (FLAG_SPI_ADR_OK) 
		begin
		data_tmp       <=REG_SPI[Nbit-1:0];
		FLAG_SPI_ADR_OK<=0;
		FLAG_SYNC<=1;
		end 
			else FLAG_SYNC<=0;

assign     out=data_tmp;
assign    clr =FLAG_SYNC;

endmodule