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
// File   : test_sync.sv
// Create : 2021-01-13 14:02:37
// Revise : 2021-01-13 14:23:21
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ps / 1 ps

module test_sync(
	input clk,     //сюда подавать 48 МГц
	output sync0,
	output sync1,
	output sync2   //секундная метка
	);

parameter INTERV0=48_000_000;
parameter INTERV1=10_000_000;
parameter INTERV2=1_000;

logic [31:0] sch0=0;
logic [31:0] sch1=0;
logic [31:0] sch2=0;

logic flg0=0;
logic flg1=0;
logic flg2=0;

always_ff @(posedge clk) 
begin 
	if (sch0<(INTERV0-1)) begin sch0<=sch0+1; if (sch0>25) flg0<=0; end  
		else 			  begin sch0<=0;      flg0<=1; end

	if (sch1<(INTERV1-1)) begin sch1<=sch1+1; if (sch1>25) flg1<=0; end  
		else 			  begin sch1<=0;      flg1<=1; end

	if (sch2<(INTERV2-1)) begin sch2<=sch2+1; if (sch2>25) flg2<=0; end  
		else 			  begin sch2<=0;      flg2<=1; end
end

assign sync0=flg0;
assign sync1=flg1;
assign sync2=flg2;

endmodule