
`timescale 1ns/1ps

module tb_eth_1g_top (); /* this is automatically generated */

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

	logic        TIME_CLR;
	logic [31:0] data_1ch;
	logic [31:0] data_2ch;
	logic        wr_data_1ch;
	logic        wr_data_2ch;
	logic        wrclk;
	logic        clk_12;
	logic        reset_all;
	logic        INT_MK;
	logic        LED0;
	logic        LED1;
	logic        TST;

	eth_1g_top inst_eth_1g_top
		(
			.TIME_CLR    (TIME_CLR),
			.data_1ch    (data_1ch),
			.data_2ch    (data_2ch),
			.wr_data_1ch (wr_data_1ch),
			.wr_data_2ch (wr_data_2ch),
			.wrclk       (wrclk),
			.clk_12      (clk_12),
			.clk_125     (clk),
			.reset_all   (reset_all),
			.INT_MK      (INT_MK),
			.LED0        (LED0),
			.LED1        (LED1),
			.TST         (TST)
		);

	task init();
		TIME_CLR    <= '0;
		data_1ch    <= '0;
		data_2ch    <= '0;
		wr_data_1ch <= '0;
		wr_data_2ch <= '0;
		wrclk       <= '0;
		clk_12      <= '0;
		reset_all   <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			TIME_CLR    <= '0;
			data_1ch    <= '0;
			data_2ch    <= '0;
			wr_data_1ch <= '0;
			wr_data_2ch <= '0;
			wrclk       <= '0;
			clk_12      <= '0;
			reset_all   <= '0;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(20);

		repeat(10)@(posedge clk);
		$finish;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_eth_1g_top.fsdb");
			$fsdbDumpvars(0, "tb_eth_1g_top", "+mda", "+functions");
		end
	end

endmodule
