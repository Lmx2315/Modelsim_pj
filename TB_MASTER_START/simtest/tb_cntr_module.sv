
`timescale 1ns/1ps

module tb_cntr_module (); /* this is automatically generated */

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

	logic  sync0;
	logic  sync1;
	logic  sync2;
	logic  rst;
	logic  data0;
	logic  data1;
	logic  data2;

	cntr_module inst_cntr_module
		(
			.clk   (clk),
			.sync0 (sync0),
			.sync1 (sync1),
			.sync2 (sync2),
			.rst   (rst),
			.data0 (data0),
			.data1 (data1),
			.data2 (data2)
		);

	task init();
		sync0 <= '0;
		sync1 <= '0;
		sync2 <= '0;
		rst   <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			sync0 <= '0;
			sync1 <= '0;
			sync2 <= '0;
			rst   <= '0;
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
			$fsdbDumpfile("tb_cntr_module.fsdb");
			$fsdbDumpvars(0, "tb_cntr_module", "+mda", "+functions");
		end
	end

endmodule
