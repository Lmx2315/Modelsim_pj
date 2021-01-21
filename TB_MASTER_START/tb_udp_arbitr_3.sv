
`timescale 1ns/1ps

module tb_udp_arbitr_3 (); /* this is automatically generated */

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
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	logic        tx_rdy;
	logic        en_arp;
	logic        en_udp1;
	logic        en_udp2;
	logic  [1:0] tx_mod1;
	logic        tx_wren1;
	logic        tx_eop1;
	logic        tx_sop1;
	logic [31:0] tx_data1;
	logic        tx_rdy1;
	logic  [1:0] tx_mod2;
	logic        tx_wren2;
	logic        tx_eop2;
	logic        tx_sop2;
	logic [31:0] tx_data2;
	logic        tx_rdy2;
	logic  [1:0] tx_mod3;
	logic        tx_wren3;
	logic        tx_eop3;
	logic        tx_sop3;
	logic [31:0] tx_data3;
	logic        tx_rdy3;
	logic        tx_wren;
	logic  [1:0] tx_mod;
	logic        tx_eop;
	logic        tx_sop;
	logic [31:0] tx_data;

	udp_arbitr_3 inst_udp_arbitr_3
		(
			.clk      (clk),
			.tx_rdy   (tx_rdy),
			.en_arp   (en_arp),
			.en_udp1  (en_udp1),
			.en_udp2  (en_udp2),
			.tx_mod1  (tx_mod1),
			.tx_wren1 (tx_wren1),
			.tx_eop1  (tx_eop1),
			.tx_sop1  (tx_sop1),
			.tx_data1 (tx_data1),
			.tx_rdy1  (tx_rdy1),
			.tx_mod2  (tx_mod2),
			.tx_wren2 (tx_wren2),
			.tx_eop2  (tx_eop2),
			.tx_sop2  (tx_sop2),
			.tx_data2 (tx_data2),
			.tx_rdy2  (tx_rdy2),
			.tx_mod3  (tx_mod3),
			.tx_wren3 (tx_wren3),
			.tx_eop3  (tx_eop3),
			.tx_sop3  (tx_sop3),
			.tx_data3 (tx_data3),
			.tx_rdy3  (tx_rdy3),
			.tx_wren  (tx_wren),
			.tx_mod   (tx_mod),
			.tx_eop   (tx_eop),
			.tx_sop   (tx_sop),
			.tx_data  (tx_data)
		);

	task init();
		tx_rdy   <= '1;
		en_arp   <= '0;
		en_udp1  <= '0;
		en_udp2  <= '0;
		tx_mod1  <= '0;
		tx_wren1 <= '0;
		tx_eop1  <= '0;
		tx_sop1  <= '0;
		tx_data1 <= '0;
		tx_mod2  <= '0;
		tx_wren2 <= '0;
		tx_eop2  <= '0;
		tx_sop2  <= '0;
		tx_data2 <= '0;
		tx_mod3  <= '0;
		tx_wren3 <= '0;
		tx_eop3  <= '0;
		tx_sop3  <= '0;
		tx_data3 <= '0;
	endtask

	task automatic drive(ref logic state);
		state=1;
		@(posedge clk);
		state=0;			
	endtask

	task automatic drive_pin(ref logic pin);
		pin=1;
		for (int i=0;i<35;i++) @(posedge clk);
		pin=0;			
	endtask

	task automatic MAC_sim(ref logic in_pin,ref logic pin);
	if (in_pin)	
	begin
		pin=1;
		for (int i=0;i<35;i++) @(posedge clk);
		pin=0;
	end			
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(en_udp1);
		repeat(100)@(posedge clk);

		drive(en_udp2);
		@(posedge clk);
		repeat(10)@(posedge clk);

		drive(en_udp1);

		repeat(10)@(posedge clk);
//		$finish;
	end

	always @(tx_wren)  //это заменяет едро МАС
	MAC_sim(tx_wren,tx_rdy);
	

	always @(en_udp1)  //это заменяет udp_sender
	 drive_pin(tx_wren2);

	always @(en_udp2)  //это заменяет udp_sender
	 drive_pin(tx_wren3);




	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_udp_arbitr_3.fsdb");
			$fsdbDumpvars(0, "tb_udp_arbitr_3", "+mda", "+functions");
		end
	end

endmodule
