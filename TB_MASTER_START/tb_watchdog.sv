
`timescale 1ns/1ps

module tb_watchdog (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(4.0) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	logic  event_mk;
	logic  boot0;
	logic  rst_n;

	watchdog inst_watchdog (.clk(clk), .event_mk(event_mk), .boot0(boot0), .rst_n(rst_n));

	task init();
		event_mk <= '0;
		boot0    <= '0;
	endtask


	task automatic drive(int dimp,ref logic state);		
		begin
			state = 1;
			for(int it = 0; it < dimp; it++) @(posedge clk);
			state = 0;
		end
	endtask

	initial begin
		// do something

		init();
		#1000;
		drive(100,.state(event_mk));
		#20000000
		drive(100,.state(event_mk));
		#200000
		drive(1000000,.state(boot0));	
	
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_watchdog.fsdb");
			$fsdbDumpvars(0, "tb_watchdog", "+mda", "+functions");
		end
	end

endmodule
