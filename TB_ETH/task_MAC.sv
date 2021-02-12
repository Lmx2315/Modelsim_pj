// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : Lmx2315
// File   : task_MAC.sv
// Create : 2021-02-10 19:14:47
// Revise : 2021-02-10 19:14:47
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1 ps / 1 ps
module eth1 (
		input  wire         clk,              // control_port_clock_connection.clk
		input  wire         reset,            //              reset_connection.reset
		output wire [31:0]  reg_data_out,     //                  control_port.readdata
		input  wire         reg_rd,           //                              .read
		input  wire [31:0]  reg_data_in,      //                              .writedata
		input  wire         reg_wr,           //                              .write
		output wire         reg_busy,         //                              .waitrequest
		input  wire [7:0]   reg_addr,         //                              .address
		input  wire         ff_rx_clk,        //      receive_clock_connection.clk
		input  wire         ff_tx_clk,        //     transmit_clock_connection.clk
		output wire [31:0]  ff_rx_data,       //                       receive.data
		output wire         ff_rx_eop,        //                              .endofpacket
		output wire [5:0]   rx_err,           //                              .error
		output wire [1:0]   ff_rx_mod,        //                              .empty
		input  wire         ff_rx_rdy,        //                              .ready
		output wire         ff_rx_sop,        //                              .startofpacket
		output wire         ff_rx_dval,       //                              .valid
		input  wire [31:0]  ff_tx_data,       //                      transmit.data
		input  wire         ff_tx_eop,        //                              .endofpacket
		input  wire         ff_tx_err,        //                              .error
		input  wire [1:0]   ff_tx_mod,        //                              .empty
		output wire         ff_tx_rdy,        //                              .ready
		input  wire         ff_tx_sop,        //                              .startofpacket
		input  wire         ff_tx_wren,       //                              .valid
		input  wire         ff_tx_crc_fwd,    //           mac_misc_connection.ff_tx_crc_fwd
		output wire         ff_tx_septy,      //                              .ff_tx_septy
		output wire         tx_ff_uflow,      //                              .tx_ff_uflow
		output wire         ff_tx_a_full,     //                              .ff_tx_a_full
		output wire         ff_tx_a_empty,    //                              .ff_tx_a_empty
		output wire [17:0]  rx_err_stat,      //                              .rx_err_stat
		output wire [3:0]   rx_frm_type,      //                              .rx_frm_type
		output wire         ff_rx_dsav,       //                              .ff_rx_dsav
		output wire         ff_rx_a_full,     //                              .ff_rx_a_full
		output wire         ff_rx_a_empty,    //                              .ff_rx_a_empty
		input  wire         ref_clk,          //  pcs_ref_clk_clock_connection.clk
		output wire         led_crs,          //         status_led_connection.crs
		output wire         led_link,         //                              .link
		output wire         led_panel_link,   //                              .panel_link
		output wire         led_col,          //                              .col
		output wire         led_an,           //                              .an
		output wire         led_char_err,     //                              .char_err
		output wire         led_disp_err,     //                              .disp_err
		output wire         rx_recovclkout,   //     serdes_control_connection.rx_recovclkout
		input  wire [139:0] reconfig_togxb,   //                              .reconfig_togxb
		output wire [91:0]  reconfig_fromgxb, //                              .reconfig_fromgxb
		input  wire         rxp,              //             serial_connection.rxp
		output wire         txp               //                              .txp
	);

int data_from_mac=0;
int data_to_mac  =0;
int sch=0;
logic tx_rdy=0;
logic [31:0] x_reg_data_out=0;
logic x_reg_rd=0;
logic [31:0] x_reg_data_in=0;


always_ff @(posedge clk)
	if(~reset) 
	begin
	data  <= 0;
	sch   <= 0;
	tx_rdy<=1;
	end 
	else
	if (ff_tx_sop) 
	begin
	sch	 <=0;
	end
	else
	begin
		
	end



endmodule