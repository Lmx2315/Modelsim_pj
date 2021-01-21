// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : yongchan jeon (Kris) poucotm@gmail.com
// File   : watchdog.sv
// Create : 2021-01-19 09:50:44
// Revise : 2021-01-19 11:13:49
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module watchdog (
	input clk,      // Clock
	input event_mk, // Clock Enable
	input boot0,    // вход для сигнала программирования с FTDI
	output rst_n   // Asynchronous reset active low	
);

parameter DELAY = 2_000_000;

logic [31:0]  sch=0;
logic [ 3:0] frnt=0;
logic     FLG_RST=1;

always_ff @(posedge clk) frnt<={frnt[2:0],event_mk};

always_ff @(posedge clk)
if (boot0==0)
begin
	if(frnt[3:1]==3'b011) 
	begin
	sch<= 0;
	end 
	else 
	begin
		if (sch<DELAY) 
			begin 
			sch<=sch+1; 
			if (sch>1000)	FLG_RST<=1; 
			end 
			else 
				begin
				sch    <=0;
				FLG_RST<=0;
				end
	end
end else
begin
sch    <= 0;
FLG_RST<= 1;
end

assign rst_n=FLG_RST;

endmodule