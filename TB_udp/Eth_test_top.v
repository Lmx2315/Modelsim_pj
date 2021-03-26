
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten

module eth_1g_top (TIME_CLR,data_1ch,data_2ch,
					wr_data_1ch,
					wr_data_2ch,
wrclk,clk_12,clk_125,reset_all,INT_MK,LED0,LED1,TST);

input TIME_CLR;//сброс счетчика времени

input [31:0] data_1ch;
input [31:0] data_2ch;	

input wr_data_1ch;
input wr_data_2ch;			
				
input  wrclk;				
input  clk_12;
input  clk_125;
input  reset_all;
output INT_MK;

output LED0;
output LED1;

output TST;


wire xSPI3_MISO1;
wire xSPI3_MISO2;
wire xSPI3_MISO3;
wire xSPI3_MISO4;
wire xSPI3_MISO5;
wire xSPI3_MISO6;
wire xSPI3_MISO7;


assign xSPI3_MISO = xSPI3_MISO1& 
					xSPI3_MISO2& 
					xSPI3_MISO3&
					xSPI3_MISO4&
					xSPI3_MISO5&
					xSPI3_MISO6&
					xSPI3_MISO7;

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

 mac_rst
 mrst1
(
  .clk(clk_125),
  .en(locked_125),
  .reset(reset_mac)
);

reg  [31:0] reg_IP_dest2_SPI=32'h01030101;
reg  [31:0] reg_IP_dest_SPI =32'h01030102;
reg  [31:0] reg_IP_my_SPI   =32'h01030102;
reg  [47:0] reg_MAC_my_SPI  =48'h000000000001;
reg  [47:0] reg_MAC_DEST_SPI=48'h222222222222;

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


wire [10:0] mem1_w_adr_wr;
wire [10:0] mem1_w_adr_rd;
wire [31:0] mem1_data_to_mem;
wire [31:0] mem1_data_from_mem;
wire [15:0] mem1_size;
wire mem1_wr_en;

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
 .source_mac_ARP(w_source_mac),//тут получаем MAC адресс принятый при ARP запросе
 .source_mac(w_source_mac_UDP),//тут получаем MAC адресс принятый при UDP запросе
 .test(w_test),

 .reply(w_reply),
 .type_i(w_type),
 .code(w_code),
 .identifier(w_identifier),
 .seq_number(w_seq_number),
 .identification(w_identification),
 .ip_my(reg_IP_my_SPI),//ip_my
 //--------для работы с UDP пакетами--------------
 .adr_udp(adr_mem_upr),//16 бит
 .length_packet_udp(packet_length),//16 бит
 .SDRAM_WR(xSDRAM_wr),
 .SDRAM_RD(xSDRAM_rd),
 .data_mem2(data_to_mem2),
 .crc_icmp(w_crc_ICMP),
 .icmp_length(w_icmp_length),
 .socket_port(reg_PORT_my_SPI),
 .ICMP_IP_DEST(w_IP_DEST_icpm) //тут IP адресс того кто нам отправил запрос
 ); 

 wire [15:0] w_icmp_length; 
 assign INT_MK=xSDRAM_wr;
 
//-----------------------------------------------
wire [7:0] control_UDP_form;
wire udp_en;
//-------------UDP reciver-------------------

wire [10:0] mem2_wr_adr;
wire [31:0] mem2_wr_data;
wire [31:0] mem2_rd_data;
wire [15:0] mem2_adr_rd;
wire mem2_wr;

//блок памяти для хранения принятых данных из UDP пакета
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

//блок принимает поток данных из ресивера UDP и отправляет его в память МЕМ2
udp_packet_rcv 
rcv1( 
.clk(clk_125) ,
.sdram_wr(xSDRAM_wr) ,
.sdram_rd(xSDRAM_rd) ,
.adr_mem(adr_mem_upr) ,//адрес начала записи
.packet_length(packet_length) ,
.data(data_to_mem2) ,
.mem_adr(mem2_wr_adr) ,
.mem_data_to(mem2_wr_data),
.mem_wr(mem2_wr)
 );


wire [31:0] mem3_wr_data;
wire [15:0] mem3_adr_rd;
wire [15:0] mem3_wr_adr;
wire mem3_wr;
wire [31:0] mem3_rd_data;
wire w_UDP2_start; //запускает выдачу пакета данных (квитанции) в UDP - начинается по окончании записи CRC в модуль udp_send2
wire [15:0] w_data_size;

//--------память для квитанций от МК -> UDP ------------	
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

wire [31:0] w_tx_data3;
wire 		w_tx_sop3 ;
wire 		w_tx_eop3 ;
wire 		w_tx_rdy3 ;
wire 		w_tx_wren3;
wire [ 1:0] w_tx_mod3;

wire w_en_UDP1;
wire [31:0] w_crc_data_mem3;
wire sch_start;

mk_to_udp_sender_v2 
udp_send2( 
.en         (w_UDP2_start),//запуск передачи
.tx_uflow   (0) ,
.tx_septy   (0) ,
.tx_mod     (w_tx_mod3) ,//показывает число валидных байт в последнем передаваемом слове
.tx_err     () ,
.tx_crc_fwd () ,
.tx_wren    (w_tx_wren3) ,
.tx_rdy     (w_tx_rdy3) ,
.tx_eop     (w_tx_eop3) ,
.tx_sop     (w_tx_sop3) ,
.tx_data    (w_tx_data3) ,
.clk        (clk_125) ,
.mem_data   (mem3_rd_data),
.mem_adr_rd (mem3_adr_rd),
.mem_length (w_data_size),			//длинна посылки в байтах= 128 , временно - надо сделать либо счётчик либо передачу из МК!!!
.crc_data   (w_crc_data_mem3),		//контрольная сумма блока для передачи по UDP расчитывается микроконтроллером, должна быть также приложена к концу блока
.END_TX()
);


//-----------------------------------------------------

udp_arbitr_3 //это модуль принимает решение кого подключить к МАС для выдачи данных :блок ARP ,UDP1 или UDP2
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

wire w_tx_sop2;
wire w_tx_eop2;
wire w_tx_wren2;
wire [31:0] w_tx_data2;
wire [ 1:0] w_tx_mod2;	
wire w_tx_rdy2;

wire [31:0] w_time_buf;
logic  clr_TIME;

reg [3:0] tmp_TIME_CLR;
always @(posedge clk_125) tmp_TIME_CLR<={tmp_TIME_CLR[2:0],TIME_CLR};
always @(posedge clk_125) clr_TIME=tmp_TIME_CLR[2]|clr_time_control;

time_control 
time1( 
.clk12(clk_12) ,//по этому сигналу считаем время оно должно быть 12 мгц
.clk(clk_125) ,
.rst(reset_all) ,
.clr(clr_TIME) ,
.nbuf(w_n_buf) ,
.q(w_time_buf) );
	
reg [47:0] my_mac=48'h01c23174acb;// mac 00-1C-23-17-4A-CB

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
.port_dest(reg_PORT_dest_SPI+1) ,//139+1 Данные посылаются на номер порта : порт управления + 1 !
.port_source(reg_PORT_my_SPI) ,  //77
.ip_dest(reg_IP_dest2_SPI) ,     //
.ip_source(reg_IP_my_SPI) ,//ip_my
.dest_mac(reg_MAC_DEST_SPI) ,
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
//блок памяти для хранения передаваемых через UDP данных,после расчёта СRC

wire [31:0] w_Q_RAM;
wire [10:0] w_adr_rd_RAM;

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

wire w_END_TX;
wire [31:0] w_data_RAM;
wire [10:0] w_adr_wr_RAM;
wire [31:0] w_CRC_buf;
wire [15:0] w_n_buf; 
wire w_start;
wire [7:0] w_channel;

//------------задержка перезапуска-------------------------
reg rst_crc  =0;
reg rst_crc_z=0;
reg [31:0] timer_rst_crc=0;
always @(posedge clk_125) 
begin
rst_crc<=control_UDP_form[0]|wrst_crc|TIME_CLR;
if (rst_crc) begin timer_rst_crc<=0; rst_crc_z<=1; end
else
	begin
	if (timer_rst_crc <1000) timer_rst_crc<=timer_rst_crc+1; 
	if (timer_rst_crc== 990) rst_crc_z<=1; else rst_crc_z<=0;	
	end
end
//-------------------------------------------------------

wire clr_fifo;

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

reg [2:0] clr_fifo_0=0;
reg [2:0] clr_fifo_1=0;

reg clr_time_control=0;

always @(posedge clk_125) clr_fifo_0<={clr_fifo_0[1:0],clr_fifo};
always @(posedge clk_125) clr_fifo_1<={clr_fifo_1[1:0],clr_fifo};


always @(posedge clk_125) 
begin
clr_time_control <=clr_fifo;
end 

wire [31:0] fifo_data0;

wire wr_fifo0;
wire rd_fifo0;
wire empty_fifo0;
wire full_fifo0;
wire [8:0] w_almost_full0;

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
wire [31:0] data_test; 
wire [15:0]	d_gen; 

assign 	data_test = {16'h0000,d_gen};


wire [31:0] fifo_data1;
wire rd_fifo1;
wire empty_fifo1;
wire full_fifo1;
wire [8:0] w_almost_full1;


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
	
wire w_tx_sop1;
wire w_tx_eop1;
wire w_tx_wren1;
wire [31:0] w_tx_data1;
wire [ 1:0] w_tx_mod1;	
wire w_tx_rdy1;

wire [31:0] mem_icmp_q;
wire [10:0] mem_icmp_adr;
wire wrst_crc;
wire [31:0] w_IP_DEST_icpm;

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
	.ip_dest  (w_IP_DEST_icpm) ,// 32'h01030101 reg_IP_dest_SPI
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

	 
	 
wire [139:0] reconfig_to_xcvr_w1;
wire [91:0]  reconfig_from_xcvr_w1;

wire  ff_rx_a_full_w;
wire  ff_rx_a_empty_w;
wire w_rx_err;
wire w_ff_rx_rdy;
wire w_rx_full;
wire w_rx_empty;


logic reg_tst=0;
always @(posedge clk_125) reg_tst<=clr_time_control;//w_END_TX
assign TST=reg_tst;


endmodule