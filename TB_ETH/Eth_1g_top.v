
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten

module eth_1g_top (data_1ch,data_2ch,
					wr_data_1ch,
					wr_data_2ch,
wrclk,clk_12,clk_125,clk_125_eth,reset_all,xCS_FPGA1,xSPI3_SCK,xSPI3_MOSI,xSPI3_MISO,RX_GTP,TX_GTP,
SDATA1_I2C,SCLK1_I2C,SFP1_TX_FAULT,SFP1_PRESENT,SFP1_LOS,RATE1_SELECTION,SFP1_TX_DISABLE,INT_MK);

input [31:0] data_1ch;
input [31:0] data_2ch;	

input wr_data_1ch;
input wr_data_2ch;			
				
input  wrclk;				
input  clk_12;
input  clk_125;
input  clk_125_eth;
input  reset_all;
input  xCS_FPGA1;
input  xSPI3_SCK;
input  xSPI3_MOSI;
output xSPI3_MISO;
output SCLK1_I2C;
inout  SDATA1_I2C;	
input  SFP1_TX_FAULT;
input  SFP1_PRESENT;
input  SFP1_LOS;

output RATE1_SELECTION;
output SFP1_TX_DISABLE;
output INT_MK;

input  RX_GTP;
output TX_GTP;

parameter adr_spi_rd_stat_mem1    =18;//чтение 32 бит служебных данных из памяти UDP ресивера 
parameter adr_spi_rd_data_mem1    =17;//чтение 32 бит данных из памяти UDP ресивера 
parameter adr_spi_wr_data_adr_mem1=16;//запись адреса памяти для чтения,управление чтением пакета из фифо МАС
parameter adr_spi_wr_data_UDP_MAC0=15;//управление потоком в MAC 1 - вкл , 0 - выкл
parameter adr_spi_wr_adr_MAC0     =13;//записываем адресс чтения/записи (пишется первым)
parameter adr_spi_wr_data_MAC0    =12;//запись в МАС данных
parameter adr_spi_rd_data_MAC0    =14;//чтение 32 бит данных
parameter adr_spi_eth1            = 9;//чтение 32 бит данных TEST
parameter adr_spi_i2c_upr1        =10;//32 записываем команду в блок i2c в формате: {<w/r>[6:0][7:0]}
parameter adr_spi_i2c_rd1         =11;//24 записываем команду в блок i2c в формате: {<w/r>[6:0][7:0]}
parameter adr_spi_wr_adr_mem2     =34;//адресс чтения памяти UDP
parameter adr_spi_rd_data_mem2    =37;//данные чтения из памяти UDP
parameter adr_spi_wr_adr_MEM3     =38;//адресс для памяти МЕМ3 {adr,data} 48 бит 
parameter adr_spi_wr_data_MEM3    =39;//данные для памяти МЕМ3
parameter adr_spi_wr_crc_MEM3     =44;//Kонтрольная сумму для данных в блоке памяти МЕМ3 
parameter adr_spi_wr_IP     	  =21;//адрес записи для IP_my и IP_dest
parameter adr_spi_wr_ETH_PORT	  =21;//адрес записи для PORT_my и PORT_dest
parameter adr_spi_wr_MAC 		  =21;//адрес записи для МАС_my адреса

//parameter ip_my=32'h0103013e;

wire xSPI3_MISO1;
wire xSPI3_MISO2;
wire xSPI3_MISO3;
wire xSPI3_MISO4;
wire xSPI3_MISO5;
wire xSPI3_MISO6;


assign xSPI3_MISO = xSPI3_MISO1& 
					xSPI3_MISO2& 
					xSPI3_MISO3&
					xSPI3_MISO4&
					xSPI3_MISO5&
					xSPI3_MISO6;


wire led_crs;
wire led_col;
wire led_link;
wire led_panel_link;
wire led_an;
wire led_char_err;
wire led_disp_err;

wire [31:0] data_udp_form_tx;
wire [1:0] tx_mod_w;
wire tx_sop_w;
wire tx_eop_w;
wire tx_err_w;
wire tx_wren_w;
wire tx_crc_fwd_w;
wire tx_uflow_w;
wire tx_rdy_w;
wire tx_septy_w;
wire tx_a_full;
wire tx_a_empty_w;
wire reg_busy_w;
wire reset_mac;

wire [10:0] mem1_w_adr_wr;
wire [10:0] mem1_w_adr_rd;
wire [31:0] mem1_data_to_mem;
wire [31:0] mem1_data_from_mem;
wire [15:0] mem1_size;
wire mem1_wr_en;

wire [15:0] PORT_my_DATA_SPI;
wire [31:0] IP_my_SPI;
wire [31:0] IP_dest_SPI;
wire [47:0] MAC_my_SPI;

reg  [31:0] reg_IP_dest_SPI;
reg  [31:0] reg_IP_my_SPI;
reg  [47:0] reg_MAC_my_SPI;
wire wr1;
wire wr2;
wire wr3;

wire [15:0] adr_spi_mem;
wire [31:0] data_spi_mem;
wire [31:0] stat_spi_mem;
wire [17:0] w_rx_error_stat;
wire udp_spi_rd;
wire w_rx_rdy;
wire w_rx_sop;
wire w_rx_eop;
wire w_rx_dval;
wire w_rx_mod;
wire [ 3:0] w_rx_frm_type;
wire [31:0] udp_data_rx;

wire [15:0] PORT_my_SPI;
wire [15:0] PORT_dest_SPI;
reg  [15:0] reg_PORT_dest_SPI;
reg  [15:0] reg_PORT_my_SPI;

wire w_en_ARP;//сигнал сообщающий что послать пакет
wire [47:0] w_source_mac;    //это МАК адресс полученный из АРП пакета
wire [47:0] w_source_mac_UDP;//это МАК адресс полученный из принятого UDP пакета 
wire [31:0] w_test;

wire [ 7:0] w_reply;
wire [ 7:0] w_type;
wire [ 7:0] w_code;
wire [15:0] w_identifier;
wire [15:0] w_seq_number;
wire [15:0] w_identification;


wire [15:0] packet_length;
wire [15:0] adr_mem_upr;
wire xSDRAM_wr;
wire xSDRAM_rd;
wire [31:0] data_to_mem2;
wire [31:0] w_crc_ICMP;


wire [10:0] mem2_wr_adr;
wire [31:0] mem2_wr_data;
wire [31:0] mem2_rd_data;
wire [15:0] mem2_adr_rd;
wire mem2_wr;
wire [7:0] control_UDP_form;
wire udp_en;
wire [15:0] w_icmp_length;

wire [31:0] w_tx_data3;
wire 		w_tx_sop3 ;
wire 		w_tx_eop3 ;
wire 		w_tx_rdy3 ;
wire 		w_tx_wren3;
wire [ 1:0] w_tx_mod3;

wire w_en_UDP1;
wire [31:0] w_crc_data_mem3;
wire sch_start;

wire [31:0] sfp_i2c_wr_data;
wire [15:0] sfp_i2c_rd_data;
wire sfp_i2c_wr;
wire wire_i2c_in;
wire wire_i2c_out;
wire wire_i2c_drv;


wire [31:0] MAC_CONTROL_DATA_IN;
wire MAC_reg_wr;
wire MAC_reg_rd;
wire [7:0] MAC_control_adr;
wire [31:0] MAC_control_rd_data;

	 
wire [139:0] reconfig_to_xcvr_w1;
wire [91:0]  reconfig_from_xcvr_w1;

wire  ff_rx_a_full_w;
wire  ff_rx_a_empty_w;
wire w_rx_err;
wire w_ff_rx_rdy;
wire w_rx_full;
wire w_rx_empty;

wire w_tx_sop1;
wire w_tx_eop1;
wire w_tx_wren1;
wire [31:0] w_tx_data1;
wire [ 1:0] w_tx_mod1;	
wire w_tx_rdy1;

wire [31:0] mem_icmp_q;
wire [10:0] mem_icmp_adr;
wire wrst_crc;


wire [31:0] fifo_data1;
wire rd_fifo1;
wire empty_fifo1;
wire full_fifo1;
wire [8:0] w_almost_full1;

wire [31:0] mem3_wr_data;
wire [15:0] mem3_adr_rd;
wire [15:0] mem3_wr_adr;
wire mem3_wr;
wire [31:0] mem3_rd_data;
wire w_UDP2_start; // 
wire [15:0] w_data_size;

wire w_tx_sop2;
wire w_tx_eop2;
wire w_tx_wren2;
wire [31:0] w_tx_data2;
wire [ 1:0] w_tx_mod2;	
wire w_tx_rdy2;

wire [31:0] w_time_buf;
reg [47:0] my_mac=48'h01c23174acb;// mac 00-1C-23-17-4A-CB
wire [31:0] w_Q_RAM;
wire [10:0] w_adr_rd_RAM;
wire w_END_TX;
wire [31:0] w_data_RAM;
wire [10:0] w_adr_wr_RAM;
wire [31:0] w_CRC_buf;
wire [15:0] w_n_buf; 
wire w_start;
wire [7:0] w_channel;
wire clr_fifo;
reg [2:0] clr_fifo_0=0;
reg [2:0] clr_fifo_1=0;
reg clr_time_control=0;
wire [31:0] data_test; 
wire [15:0]	d_gen; 
wire [31:0] fifo_data0;

wire wr_fifo0;
wire rd_fifo0;
wire empty_fifo0;
wire full_fifo0;
wire [8:0] w_almost_full0;


 mac_rst
 mrst1
(
  .clk(clk_125),
  .en(locked_125),
  .reset(reset_mac)
);



always @(posedge clk_125)
	if (wr1)	
	begin
	reg_IP_my_SPI  <=IP_my_SPI;
	reg_IP_dest_SPI<=IP_dest_SPI;
	end

always @(posedge clk_125)
	if (wr2)	
	begin
	reg_PORT_dest_SPI  	<=PORT_dest_SPI;
	reg_PORT_my_SPI		<=PORT_my_SPI;
	end

always @(posedge clk_125)
	if (wr3)	
	begin
	reg_MAC_my_SPI  	<=MAC_my_SPI;
	end


Block_write_spi_mac //запись IP  в блок ETH
 #(48,adr_spi_wr_MAC) spi_wr_data_MAC_my(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (MAC_my_SPI),.wr(wr3),.wtreq(0));

Block_write_spi_mac //запись PORT в блок ETH
 #(32,adr_spi_wr_ETH_PORT) spi_wr_data_PORT_my(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out ({PORT_my_SPI,PORT_dest_SPI}),.wr(wr2),.wtreq(0));

Block_write_spi_mac //запись IP  в блок ETH
 #(64,adr_spi_wr_IP) spi_wr_data_IP_my(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out ({IP_my_SPI,IP_dest_SPI}),.wr(wr1),.wtreq(0));

Block_read_spi_mac  //чтение 32 бит служебных данных из памяти UDP ресивера 
 #(48,adr_spi_rd_stat_mem1) spi_rd_stat_mem1( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO1),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,.inport	 ({mem1_size,stat_spi_mem}),.clr(),.wtreq(0));//

Block_read_spi_mac  //чтение 32 бит данных из памяти UDP ресивера 
 #(32,adr_spi_rd_data_mem1) spi_rd_data_mem1( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO2),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,.inport	 (data_spi_mem),.clr(udp_spi_rd),.wtreq(0));//

Block_write_spi_mac //запись адреса памяти для чтения,управление чтением пакета из фифо МАС
 #(16,adr_spi_wr_data_adr_mem1) spi_wr_data_adr_mem1(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (adr_spi_mem),.wr(),.wtreq(0));




//-------------UDP resiver----------------


mem1	//mem - для скачивания на мк
mem1_inst 
(
	.clock ( clk_125 ),
	.data ( mem1_data_to_mem ),
	.rdaddress ( mem1_w_adr_rd ),
	.wraddress ( mem1_w_adr_wr ),
	.wren ( mem1_wr_en ),
	.q ( mem1_data_from_mem )
	);




udp_reciver 
 udp_rcv1( 
 .clk(clk_125) ,
 .rx_data(udp_data_rx),
 .rx_sop (w_rx_sop),
 .rx_eop (w_rx_eop),
 .rx_rdy (w_rx_rdy),
 .rx_dval(w_rx_dval),
 .rx_dsav(0),
 .rx_err (w_rx_err),
 .rx_err_stat(w_rx_error_stat),
 .rx_frm_type(w_rx_frm_type),
 .rx_mod(w_rx_mod) ,
 .rx_a_full(w_rx_full) ,
 .rx_a_empty(w_rx_empty) ,
 .adr(adr_spi_mem) , //spi
 .data(data_spi_mem),//spi
 .rd(udp_spi_rd) ,   //spi
 .rst(reset_all),
 .adr_wr(mem1_w_adr_wr),
 .adr_rd(mem1_w_adr_rd),
 .int_rsv(),
 .data_to_mem(mem1_data_to_mem),
 .data_from_mem(mem1_data_from_mem),
 .stat_err(stat_spi_mem),
 .wren_mem(mem1_wr_en),
 .size(mem1_size),
 .send(w_en_ARP),
 .source_mac_ARP(w_source_mac),// 
 .source_mac(w_source_mac_UDP),// 
 .test(w_test),

 .reply(w_reply),
 .type_i(w_type),
 .code(w_code),
 .identifier(w_identifier),
 .seq_number(w_seq_number),
 .identification(w_identification),
 .ip_my(reg_IP_my_SPI),//ip_my
 //-------- --------------
 .adr_udp(adr_mem_upr),//16 бит
 .length_packet_udp(packet_length),//16 бит
 .SDRAM_WR(xSDRAM_wr),
 .SDRAM_RD(xSDRAM_rd),
 .data_mem2(data_to_mem2),
 .crc_icmp(w_crc_ICMP),
 .icmp_length(w_icmp_length),
 .socket_port(reg_PORT_my_SPI)
 );


 
 assign INT_MK=xSDRAM_wr;
 
//-----------------------------------------------

Block_write_spi_mac // 
 #(8,adr_spi_wr_data_UDP_MAC0) spi_wr_data_UDP_MAC0(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (control_UDP_form),.wr(w_en_UDP1),.wtreq(0));


//-------------UDP reciver-------------------


// 
mem1	
mem2_inst 
(
	.clock ( clk_125 ),
	.data (mem2_wr_data),
	.rdaddress (mem2_adr_rd[10:0]),
	.wraddress ( mem2_wr_adr ),
	.wren (mem2_wr),
	.q (mem2_rd_data)
	);

// 2
udp_packet_rcv 
rcv1( 
.clk(clk_125) ,
.sdram_wr(xSDRAM_wr) ,
.sdram_rd(xSDRAM_rd) ,
.adr_mem(adr_mem_upr) ,// 
.packet_length(packet_length) ,
.data(data_to_mem2) ,
.mem_adr(mem2_wr_adr) ,
.mem_data_to(mem2_wr_data),
.mem_wr(mem2_wr)
 );

Block_write_spi_mac // 
 #(16,adr_spi_wr_adr_mem2) spi_wr_adr_mem2(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (mem2_adr_rd),.wr(),.wtreq(0));// 

Block_read_spi_mac  //
 #(32,adr_spi_rd_data_mem2) spi_rd_data_mem2( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO6),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,.inport	 (mem2_rd_data),.clr(),.wtreq(0));//

//-------------------------------------------



Block_write_spi_mac // 
 #(16,adr_spi_wr_adr_MEM3) spi_wr_adr_mem3(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (mem3_wr_adr),.wr(),.wtreq(0));
	
Block_write_spi_mac // 
 #(32,adr_spi_wr_data_MEM3) spi_wr_data_mem3(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (mem3_wr_data),.wr(mem3_wr),.wtreq(0));

Block_write_spi_mac // 
 #(48,adr_spi_wr_crc_MEM3) spi_wr_crc_mem3(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out ({w_data_size,w_crc_data_mem3}),.wr(w_UDP2_start),.wtreq(0));

//--------  ------------	
mem1	
mem3_inst 
(
	.clock ( clk_125 ),
	.data (mem3_wr_data),
	.rdaddress ( mem3_adr_rd[10:0]),
	.wraddress ( mem3_wr_adr[10:0]),
	.wren (mem3_wr),
	.q (mem3_rd_data)
	);



mk_to_udp_sender 
udp_send2( 
.en         (w_UDP2_start),// 
.tx_uflow   (0) ,
.tx_septy   (0) ,
.tx_mod     (w_tx_mod3) ,// 
.tx_err     () ,
.tx_crc_fwd () ,
.tx_wren    (w_tx_wren3) ,
.tx_rdy     (w_tx_rdy3) ,
.tx_eop     (w_tx_eop3) ,
.tx_sop     (w_tx_sop3) ,
.tx_data    (w_tx_data3) ,
.port_dest  (reg_PORT_dest_SPI) ,//139
.port_source(reg_PORT_my_SPI) ,//77
.ip_dest    (reg_IP_dest_SPI) ,
.ip_source  (reg_IP_my_SPI) ,//ip_my
.dest_mac   (w_source_mac_UDP) ,
.mac        (reg_MAC_my_SPI) ,//my_mac
.clk        (clk_125) ,
.mem_data   (mem3_rd_data),
.mem_adr_rd (mem3_adr_rd),
.mem_length (w_data_size),			// 
.crc_data   (w_crc_data_mem3),		// 
.END_TX()
);


//-----------------------------------------------------

udp_arbitr_3 //
ar1( 
.clk(clk_125) ,
.tx_rdy(tx_rdy_w),
.en_arp (w_en_ARP) ,
.en_udp1(w_start),//
.en_udp2(w_UDP2_start),
.tx_mod1(w_tx_mod1) ,
.tx_wren1(w_tx_wren1) ,
.tx_eop1(w_tx_eop1) ,
.tx_sop1(w_tx_sop1) ,
.tx_data1(w_tx_data1),
.tx_rdy1(w_tx_rdy1),
.tx_mod2(w_tx_mod2) ,
.tx_wren2(w_tx_wren2) ,
.tx_eop2(w_tx_eop2) ,
.tx_sop2(w_tx_sop2) ,
.tx_data2(w_tx_data2),
.tx_rdy2(w_tx_rdy2) ,
.tx_mod3(w_tx_mod3) ,
.tx_wren3(w_tx_wren3) ,
.tx_eop3(w_tx_eop3) ,
.tx_sop3(w_tx_sop3) ,
.tx_data3(w_tx_data3),
.tx_rdy3(w_tx_rdy3),
.tx_wren(tx_wren_w) ,
.tx_mod(tx_mod_w) ,
.tx_eop(tx_eop_w),
.tx_sop(tx_sop_w) ,
.tx_data(data_udp_form_tx) );





/*
z1 
z1_inst
(
.clk(clk_125),
.en(w_en_UDP1),
.start(sch_start)
);
*/


time_control 
time1( 
.clk12(clk_12) ,// 
.clk(clk_125) ,
.rst(reset_all) ,
.clr(clr_time_control) ,
.nbuf(w_n_buf) ,
.q(w_time_buf) );
	


udp_sender 
udp1( 
.en(w_start),
.tx_uflow(0) ,
.tx_septy(0) ,
.tx_mod(w_tx_mod2) ,
.tx_err() ,
.tx_crc_fwd() ,
.tx_wren(w_tx_wren2) ,
.tx_rdy(w_tx_rdy2) ,
.tx_eop(w_tx_eop2) ,
.tx_sop(w_tx_sop2) ,
.tx_data(w_tx_data2) ,
.port_dest(reg_PORT_dest_SPI) ,//139
.port_source(reg_PORT_my_SPI) ,//77
.ip_dest(reg_IP_dest_SPI) ,
.ip_source(reg_IP_my_SPI) ,//ip_my
.dest_mac(w_source_mac_UDP) ,
.mac(reg_MAC_my_SPI) ,//my_mac
.clk(clk_125) ,
.mem_data(w_Q_RAM),
.mem_adr_rd(w_adr_rd_RAM),
.mem_length(w_n_buf),//в байтах 
.crc_data(w_CRC_buf),
.END_TX(w_END_TX),
.time_buf(w_time_buf),//32'hdeedbeef
.channel(w_channel)
);

//----------RAM_UDP-------------
// 



ram4	
ram4_inst  (
	.clock ( clk_125 ),
	.data  ( w_data_RAM ),
	.rdaddress ( w_adr_rd_RAM ),
	.wraddress ( w_adr_wr_RAM ),
	.wren ( 1'b1 ),
	.q ( w_Q_RAM )
	);

//----------CRC-----------------



// 
reg rst_crc  =0;
reg rst_crc_z=0;
reg [31:0] timer_rst_crc=0;
always @(posedge clk_125) 
begin
rst_crc<=control_UDP_form[0]|wrst_crc;
if (rst_crc) begin timer_rst_crc<=0; rst_crc_z<=1; end
else
	begin
	if (timer_rst_crc <125000) timer_rst_crc<=timer_rst_crc+1; 
	if (timer_rst_crc==124998) rst_crc_z<=1; else rst_crc_z<=0;	
	end
end
//-------------------------------------------------------



crc_form 
crc1(
.upr(control_UDP_form),
.channel(w_channel),
.af0(w_almost_full0),//w_almost_full0
.af1(w_almost_full1),//w_almost_full1
.clk(clk_125) ,
.rst(rst_crc_z) ,
.fifo0(fifo_data0) ,
.fifo1(fifo_data1) ,
.rdreq0(rd_fifo0) ,
.rdreq1(rd_fifo1) ,
.fifo_empty0(empty_fifo0) ,//empty_fifo0
.fifo_empty1(empty_fifo1) ,//empty_fifo1
.end_tx(w_END_TX) ,// 
.q_ram(w_data_RAM) ,
.adr_ram(w_adr_wr_RAM) ,
.crc_buf(w_CRC_buf),
.nbuf(w_n_buf),//в байтах
.full0(full_fifo0),//full_fifo0  - номер канала
.full1(full_fifo1),//full_fifo1
.fifo_clr(clr_fifo),
.start(w_start)
);
//----------fifo -----------------



always @(posedge clk_125) clr_fifo_0<={clr_fifo_0[1:0],clr_fifo};
always @(posedge clk_125) clr_fifo_1<={clr_fifo_1[1:0],clr_fifo};


/*
always @(posedge clk_125 or posedge clr_fifo) 
if (clr_fifo)
begin
clr_fifo_125_0_1 <=clr_fifo;
clr_fifo_125_1_1 <=clr_fifo;
clr_time_control <=clr_fifo;
end else
begin
clr_fifo_125_0_1 <=clr_fifo;
clr_fifo_125_1_1 <=clr_fifo;
clr_time_control <=clr_fifo;
end
*/


fifo_to_125	
fifo_to_125_0 (
	.aclr (clr_fifo_0[2]),
	.data (data_1ch),//data_1ch
	.rdclk ( clk_125 ),
	.rdreq ( rd_fifo0 ),
	.wrclk ( wrclk ),//wrclk
	.wrreq ( wr_data_1ch ),//wr_data_1ch
	.q ( fifo_data0 ),
	.rdempty ( empty_fifo0 ),
	.rdfull ( full_fifo0 ),
	.rdusedw ( w_almost_full0 )
	);

//---------Test------------	


assign 	data_test = {16'h0000,d_gen};

/*
test_gen 
tst1(
.clk(clk_125),
.q(d_gen) ,
.wr(wr_fifo0) ,
.clk12(clk_12) );
*/
//----------fifo1-------------- 



fifo_to_125	
fifo_to_125_1 (
	.aclr ( clr_fifo_1[2]),
	.data ( data_2ch ),//data_2ch
	.rdclk ( clk_125 ),
	.rdreq ( rd_fifo1 ),
	.wrclk ( wrclk ),//wrclk
	.wrreq ( wr_data_2ch ),//wr_data_2ch
	.q ( fifo_data1 ),
	.rdempty ( empty_fifo1 ),
	.rdfull ( full_fifo1 ),
	.rdusedw ( w_almost_full1 )
	);
	
//--------------------------------
//блок памяти запоминающий ICMP сообщение
mem1	//mem - для ICMP
mem_ICMP_inst 
(
	.clock ( clk_125 ),
	.data ( mem1_data_to_mem ),
	.rdaddress ( mem_icmp_adr ),
	.wraddress ( mem1_w_adr_wr ),
	.wren ( mem1_wr_en ),
	.q ( mem_icmp_q )
	);
	


arp_sender //ARP и ICMP ответ
arp1( 
	.en(w_en_ARP),
	.tx_uflow() ,
	.tx_septy() ,
	.tx_mod(w_tx_mod1) ,
	.tx_err() ,
	.tx_crc_fwd() ,
	.tx_wren(w_tx_wren1) ,
	.tx_rdy(w_tx_rdy1) ,
	.tx_eop(w_tx_eop1) ,
	.tx_sop(w_tx_sop1) ,
	.tx_data(w_tx_data1) ,
	.ip_dest  (reg_IP_dest_SPI) ,// 32'h01030101
	.ip_source(reg_IP_my_SPI) ,//ip_my
	.dest_mac(w_source_mac) ,
	.mac(reg_MAC_my_SPI) ,//my_mac  MAC address is            
	.clk(clk_125),
	.reply(w_reply),
	.type_i(0),//0 - reply
	.code(w_code),
	.identifier(w_identifier),
	.seq_number(w_seq_number),
	.identification(w_identification),
	.mem_data(mem_icmp_q),
	.mem_adr(mem_icmp_adr),
	.crc_ICMP(w_crc_ICMP),
	.icmp_length(w_icmp_length),
	.rst_crc(wrst_crc)
	 );

//------------------------------


eth1_0002 
eth_full1_inst (
		.clk              (clk_125),              // control_port_clock_connection.clk
		.reset            (reset_mac),            //              reset_connection.reset
		.reg_data_out     (MAC_control_rd_data),  //                  control_port.readdata
		.reg_rd           (MAC_reg_rd),           //                              .read
		.reg_data_in      (MAC_CONTROL_DATA_IN),  //                              .writedata
		.reg_wr           (MAC_reg_wr),           //                              .write
		.reg_busy         (reg_busy_w),           //                              .waitrequest
		.reg_addr         (MAC_control_adr),      //                              .address
		.ff_rx_clk        (clk_125),        //      receive_clock_connection.clk
		.ff_tx_clk        (clk_125),        //     transmit_clock_connection.clk
		.ff_rx_data       (udp_data_rx),        //                       receive.data
		.ff_rx_eop        (w_rx_eop),        //                              .endofpacket
		.rx_err           (w_rx_err),        //                              .error
		.ff_rx_mod        (w_rx_mod),        //                              .empty
		.ff_rx_rdy        (w_rx_rdy),        //                              .ready
		.ff_rx_sop        (w_rx_sop),        //                              .startofpacket
		.ff_rx_dval       (w_rx_dval),        //                              .valid
		.ff_tx_data       (data_udp_form_tx),       //                      transmit.data
		.ff_tx_eop        (tx_eop_w),        //                              .endofpacket
		.ff_tx_err        (tx_err_w),        //   .error
		.ff_tx_mod        (tx_mod_w),        //   .empty
		.ff_tx_rdy        (tx_rdy_w),        //   .ready
		.ff_tx_sop        (tx_sop_w),        //   .startofpacket
		.ff_tx_wren       (tx_wren_w),       //   .valid
	//	.magic_wakeup     (),     //           mac_misc_connection.magic_wakeup
	//	.magic_sleep_n    (1'b1),    //           .magic_sleep_n
		.ff_tx_crc_fwd    (1'b0),    //           .ff_tx_crc_fwd   Связан с генерацией crc для отправляемого пакета 
		.ff_tx_septy      (),      //             .ff_tx_septy
		.tx_ff_uflow      (),      //             .tx_ff_uflow
		.ff_tx_a_full     (),     //              .ff_tx_a_full
		.ff_tx_a_empty    (),    //               .ff_tx_a_empty
		.rx_err_stat      (w_rx_error_stat),//    .rx_err_stat
		.rx_frm_type      (w_rx_frm_type),      //.rx_frm_type
		.ff_rx_dsav       (),       //            .ff_rx_dsav
		.ff_rx_a_full     (w_rx_full),     //     .ff_rx_a_full
		.ff_rx_a_empty    (w_rx_empty),    //     .ff_rx_a_empty
		.ref_clk          (clk_125_eth),          //  pcs_ref_clk_clock_connection.clk
		.led_crs          (led_crs),          //         status_led_connection.crs
		.led_link         (led_link),         //                              .link
		.led_panel_link   (led_panel_link),   //                              .panel_link
		.led_col          (led_col),          //                              .col
		.led_an           (led_an),           //                              .an
		.led_char_err     (led_char_err),     //                              .char_err
		.led_disp_err     (led_disp_err),     //                              .disp_err
		.rx_recovclkout   (),   //     serdes_control_connection.rx_recovclkout
		.reconfig_togxb   (reconfig_to_xcvr_w1),   //                              .reconfig_togxb
		.reconfig_fromgxb (reconfig_from_xcvr_w1), //                              .reconfig_fromgxb
		.rxp              (RX_GTP),              //             serial_connection.rxp
		.txp              (TX_GTP)               //                              .txp
	);

/*
reconfig_phy1 
rec_ph1(
		.reconfig_busy(),             //      reconfig_busy.reconfig_busy
		.mgmt_clk_clk(clk_125),              //       mgmt_clk_clk.clk
		.mgmt_rst_reset(reset_mac),            //     mgmt_rst_reset.reset
		.reconfig_mgmt_address(),     //      reconfig_mgmt.address
		.reconfig_mgmt_read(),        //                   .read
		.reconfig_mgmt_readdata(),    //                   .readdata
		.reconfig_mgmt_waitrequest(), //                   .waitrequest
		.reconfig_mgmt_write(),       //                   .write
		.reconfig_mgmt_writedata(),   //                   .writedata
		.reconfig_to_xcvr(reconfig_to_xcvr_w1),          //   reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr(reconfig_from_xcvr_w1)         // reconfig_from_xcvr.reconfig_from_xcvr
	);
*/



Block_write_spi //записываем адресс чтения/записи (пишется первым)
 #( 8,adr_spi_wr_adr_MAC0) spi_wr_adr_MAC0( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (MAC_control_adr));//адресс 32-bit word-aligned register address.

Block_write_spi_mac //запись в МАС данных
 #(32,adr_spi_wr_data_MAC0) spi_wr_data_MAC0(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (MAC_CONTROL_DATA_IN),.wr(MAC_reg_wr),.wtreq(reg_busy_w));

Block_read_spi_mac  //чтение 32 бит данных
 #(32,adr_spi_rd_data_MAC0) spi_rd_data_MAC0( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO3),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,.inport	 (MAC_control_rd_data),.clr(MAC_reg_rd),.wtreq(reg_busy_w));//

/* 
Block_read_spi 
 #(32,adr_spi_eth1) spi_eth1( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO4),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,
	.inport	 (w_test));
*/	

Block_read_spi 
 #(32,adr_spi_eth1) spi_eth1( .clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO4),
 .cs(xCS_FPGA1) ,.rst(reset_all) ,
	.inport	 ({		   16'h00,
						1'b0,
				//	w_rx_err,
				//	w_ff_rx_rdy,
				//	tx_a_empty_w,
				//	tx_a_full,
				//	ff_rx_a_empty_w,
				//	ff_rx_a_full_w,
				//	tx_rdy_w,
					locked_125,
					   led_crs,
					   led_col,
					   led_link,
					   led_panel_link,
					   led_an,
					   led_char_err,
					   led_disp_err}));
		   
//------------------------------------------

buf_i2c	
buf_i2c_inst (
	.datain ( wire_i2c_out ),
	.oe (wire_i2c_drv),//  
	.dataio ( SDATA1_I2C ),
	.dataout ( wire_i2c_in )
	);

i2c_master_v2 
i2c_1(
	.asc_err(),
	.data(sfp_i2c_rd_data),
	.ready(),
	.scl(SCLK1_I2C),
	.o_sda(wire_i2c_out),
	.i_sda(wire_i2c_in),
	.drv(wire_i2c_drv),
	.clk(clk_125),
	.rst(reset_all),
	.en(sfp_i2c_wr),
	.in(sfp_i2c_wr_data)
);

assign RATE1_SELECTION=1;
assign SFP1_TX_DISABLE=reset_mac;

// : {<w/r>[6:0][7:0]}
//                                    											
Block_write_spi_v2 
 #(32,adr_spi_i2c_upr1) spi_i2c_upr1(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(),.cs(xCS_FPGA1) ,.rst(reset_all) ,
	.out (sfp_i2c_wr_data),.wr(sfp_i2c_wr));

Block_read_spi 
 #(24,adr_spi_i2c_rd1) spi_i2c_rd1(.clk(clk_125),.sclk(xSPI3_SCK),.mosi(xSPI3_MOSI),.miso(xSPI3_MISO5),.cs(xCS_FPGA1),.rst(reset_all) ,
	.inport	 ({5'b00000,SFP1_TX_FAULT,SFP1_PRESENT,SFP1_LOS,sfp_i2c_rd_data}));

//-----------------------------------------------

endmodule