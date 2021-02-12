
`timescale 1ns/1ps

module tb_fifo_to_125 (); /* this is automatically generated */

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

	logic        aclr;
	logic [31:0] data;
	logic        rdclk;
	logic        rdreq;
	logic        wrclk;
	logic        wrreq;
	logic [31:0] q;
	logic        rdempty;
	logic        rdfull;
	logic  [8:0] rdusedw;

	fifo_to_125 inst_fifo_to_125
		(
			.aclr    (aclr),
			.data    (data),
			.rdclk   (rdclk),
			.rdreq   (rdreq),
			.wrclk   (wrclk),
			.wrreq   (wrreq),
			.q       (q),
			.rdempty (rdempty),
			.rdfull  (rdfull),
			.rdusedw (rdusedw)
		);

	task init();
		aclr  <= '0;
		data  <= '0;
		rdclk <= '0;
		rdreq <= '0;
		wrclk <= '0;
		wrreq <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			aclr  <= '0;
			data  <= '0;
			rdclk <= '0;
			rdreq <= '0;
			wrclk <= '0;
			wrreq <= '0;
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
			$fsdbDumpfile("tb_fifo_to_125.fsdb");
			$fsdbDumpvars(0, "tb_fifo_to_125", "+mda", "+functions");
		end
	end

endmodule
