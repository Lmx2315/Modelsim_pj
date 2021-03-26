// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : Lmx2315 lmx2315@mail.ru
// File   : delay_96.sv
// Create : 2021-03-01 11:46:19
// Revise : 2021-03-01 11:46:19
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module delay_96 (
	input wire clk,
	input wire rst,
	input wire [31:0] Idat,//input signal
	input wire wr_comm,	   //write upr signal
	input wire [7:0] upr,  //control signal,delay level
	output wire [31:0] Odat
	);
parameter size=20;

logic [31:0] tmp [size-1:0] ;//array of delay
logic [ 7:0] addr=0;
logic [31:0] data_out=0;

always_ff @(posedge clk)
 if (rst)     addr<=0;
 else
 if (wr_comm) addr<=upr;
	else
	 begin
	  data_out <=tmp[addr];
	 end

always_ff @(posedge clk)
if (rst)
	begin
	for (int i=0;i<size;i++)
	tmp[i]<= '0;
	end 
	else 
	begin
	 tmp[0]<=Idat;
	 for (int i=0;i<(size-1);i++) tmp[i+1]<=tmp[i];
	end


assign Odat=data_out;

endmodule