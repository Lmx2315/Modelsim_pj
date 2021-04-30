
`timescale 1ns/1ps

module tb_udp_reciver (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk);
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	logic [31:0] rx_data;
	logic        rx_sop;
	logic        rx_eop;
	logic        rx_rdy;
	logic        rx_dval;
	logic        rx_dsav;
	logic  [5:0] rx_err;
	logic [17:0] rx_err_stat;
	logic  [3:0] rx_frm_type;
	logic  [1:0] rx_mod;
	logic        rx_a_full;
	logic        rx_a_empty;
	logic [15:0] adr;
	logic [31:0] data;
	logic        rd;
	logic        rst;
	logic [10:0] adr_wr;
	logic [10:0] adr_rd;
	logic        int_rsv;
	logic [31:0] data_to_mem;
	logic [31:0] data_from_mem;
	logic [31:0] stat_err;
	logic        wren_mem;
	logic [15:0] size;
	logic        send;
	logic [47:0] source_mac_ARP;
	logic [47:0] source_mac;
	logic [31:0] test;
	logic  [7:0] reply;
	logic  [7:0] type_i;
	logic  [7:0] code;
	logic [15:0] identifier;
	logic [15:0] seq_number;
	logic [15:0] identification;
	logic [31:0] ip_my;
	logic [15:0] adr_udp;
	logic [15:0] length_packet_udp;
	logic        SDRAM_WR;
	logic        SDRAM_RD;
	logic [31:0] data_mem2;
	logic [31:0] crc_icmp;
	logic [15:0] icmp_length;
	logic [15:0] socket_port;
	logic [31:0] ICMP_IP_DEST;

	logic [31:0] Arr [0:27];
	int sz=0;
	int index=0;
	int i=0;

	initial 
    begin
    	$readmemh("hex.txt", Arr);
    	sz=$size(Arr);
    end

    task automatic drv (ref logic a);
		a=1;
	    @(posedge clk);
		a=0;
	endtask

	udp_reciver inst_udp_reciver
		(
			.clk               (clk),
			.rx_data           (rx_data),
			.rx_sop            (rx_sop),
			.rx_eop            (rx_eop),
			.rx_rdy            (rx_rdy),
			.rx_dval           (rx_dval),
			.rx_dsav           (rx_dsav),
			.rx_err            (rx_err),
			.rx_err_stat       (rx_err_stat),
			.rx_frm_type       (rx_frm_type),
			.rx_mod            (rx_mod),
			.rx_a_full         (rx_a_full),
			.rx_a_empty        (rx_a_empty),
			.adr               (adr),
			.data              (data),
			.rd                (rd),
			.rst               (rst),
			.adr_wr            (adr_wr),
			.adr_rd            (adr_rd),
			.int_rsv           (int_rsv),
			.data_to_mem       (data_to_mem),
			.data_from_mem     (data_from_mem),
			.stat_err          (stat_err),
			.wren_mem          (wren_mem),
			.size              (size),
			.send              (send),
			.source_mac_ARP    (source_mac_ARP),
			.source_mac        (source_mac),
			.test              (test),
			.reply             (reply),
			.type_i            (type_i),
			.code              (code),
			.identifier        (identifier),
			.seq_number        (seq_number),
			.identification    (identification),
			.ip_my             (ip_my),
			.adr_udp           (adr_udp),
			.length_packet_udp (length_packet_udp),
			.SDRAM_WR          (SDRAM_WR),
			.SDRAM_RD          (SDRAM_RD),
			.data_mem2         (data_mem2),
			.crc_icmp          (crc_icmp),
			.icmp_length       (icmp_length),
			.socket_port       (socket_port),
			.ICMP_IP_DEST      (ICMP_IP_DEST)
		);

	task init();
		rx_data       <= '0;
		rx_sop        <= '0;
		rx_eop        <= '0;
		rx_dval       <= '0;
		rx_dsav       <= '0;
		rx_err        <= '0;
		rx_err_stat   <= '0;
		rx_frm_type   <= '0;
		rx_mod        <= '0;
		rx_a_full     <= '0;
		rx_a_empty    <= '0;
		adr           <= '0;
		rd            <= '0;
		rst           <= '0;
		data_from_mem <= '0;
		ip_my         <= '0;
		socket_port   <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			rx_data       <= '0;
			rx_sop        <= '0;
			rx_eop        <= '0;
			rx_dval       <= '0;
			rx_dsav       <= '0;
			rx_err        <= '0;
			rx_err_stat   <= '0;
			rx_frm_type   <= '0;
			rx_mod        <= '0;
			rx_a_full     <= '0;
			rx_a_empty    <= '0;
			adr           <= '1;
			rd            <= '0;
			rst           <= '0;
			data_from_mem <= '0;
			ip_my         <= 32'h0103033c;//32'h0103033c
			socket_port   <= 3002;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);
		drive(20);
		repeat(10)@(posedge clk);
//-----------------------------------
		drv(rst);

	    rx_dval=1;

	    index=0;
        repeat(sz)
        begin
        	rx_data=Arr[index];
          	if (index==(sz-1)) rx_eop=1;
          	if (index==0     ) rx_sop=1; else  rx_sop=0;    	
        	@(posedge clk);
        	index++;
        end
        
        rx_eop=0;
        rx_dval=0;
        @(posedge clk);


        $display("--------------");
 		repeat (15) @(posedge clk);

		$finish;
	end

	// dump wave
	initial begin
		$monitor("size:%d data:%h int_rsv:%h data_mem2:%h wren_mem:%h adr_wr:%h adr_rd:%h data_to_mem:%h ICMP_IP_DEST:%h identification:%h reply:%h type_i:%h code:%h identifier:%h send:%h",
			size,data,int_rsv,data_mem2,wren_mem,adr_wr,adr_rd,data_to_mem,ICMP_IP_DEST,identification,reply,type_i,code,identifier,send);
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_udp_reciver.fsdb");
			$fsdbDumpvars(0, "tb_udp_reciver", "+mda", "+functions");
		end
	end

endmodule
