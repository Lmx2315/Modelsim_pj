
`timescale 1ns/1ps

module tb_cntr_module (); /* this is automatically generated */

	// clock 48
	logic clk;
	initial begin
		clk = '0;
		forever #(10.42) clk = ~clk;
	end

	// clock 125
	logic clk1;
	initial begin
		clk1 = '0;
		forever #(4.0) clk1 = ~clk1;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	logic  sync0;
	logic  sync1;
	logic  sync2;
	logic  rst;
	logic [31:0]  min_data0;
	logic [31:0]  min_data1;
	logic [31:0]  min_data2;

	logic [31:0]  max_data0;
	logic [31:0]  max_data1;
	logic [31:0]  max_data2;

logic TST_sync0;
logic TST_sync1;
logic TST_sync2;

	test_sync #(
			.INTERV0(100_000),//задаётся в клоках 48 МГц
			.INTERV1(25_000),
			.INTERV2(48_000_000)
		) inst_test_sync (
			.clk   (clk),
			.sync0 (TST_sync0),
			.sync1 (TST_sync1),
			.sync2 (TST_sync2)
		);



	cntr_module inst_cntr_module
		(
			.clk   (clk),
			.clk125(clk1),
			.sync0 (TST_sync0),//sync0
			.sync1 (TST_sync1),//sync1
			.sync2 (TST_sync2),//sync2
			.rst   (rst),
			.FLAG_1Hz(),
			.T1hz(),
			.max0(max_data0),
			.max1(max_data1),
			.max2(max_data2),
			.min0(min_data0),
			.min1(min_data1),
			.min2(min_data2)
		);

	task init();
		sync0 <= '0;
		sync1 <= '0;
		sync2 <= '0;
		rst   <= '1;
	endtask

	task automatic drive(int delay,int dimp,int dpeiod,ref logic state);		
		begin
			for(int it = 0; it < delay; it++) @(posedge clk);
			state = 1;
			for(int it = 0; it < dimp; it++) @(posedge clk);
			state = 0;
			@(posedge clk);
			for(int it = 0; it < dpeiod; it++) @(posedge clk);
			state = 1;
			for(int it = 0; it < dimp; it++) @(posedge clk);
			state = 0;
			@(posedge clk);
		end
	endtask



	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		rst   <= 0;
		@(posedge clk);
		rst   <= 1;
		@(posedge clk);	

		repeat(48_048_000)@(posedge clk);

		rst   <= 0;
		@(posedge clk);
		rst   <= 1;
		@(posedge clk);	

/*
		fork
		repeat(10) drive(0,5,15,.state(sync0));

		repeat(10) drive(10,5,10,.state(sync1));

		repeat(10) drive(10,5,20,.state(sync2));
		join

		fork
		drive(10,5,15,.state(sync0));

		drive(10,5,10,.state(sync1));

		drive(10,5,20,.state(sync2));
		join

		repeat(50)@(posedge clk);

		rst   <= 0;
		@(posedge clk);
		rst   <= 1;
		@(posedge clk);	

		fork
		repeat(10) drive(0,5,15,.state(sync0));

		repeat(10) drive(10,5,10,.state(sync1));

		repeat(10) drive(10,5,4800,.state(sync2));
		join	

		repeat(10) drive(10,5,4800,.state(sync2));	
*/
//		$finish;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_cntr_module.fsdb");
			$fsdbDumpvars(0, "tb_cntr_module", "+mda", "+functions");
		end
	end

endmodule
