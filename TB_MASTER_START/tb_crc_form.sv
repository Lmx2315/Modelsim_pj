
`timescale 1ns/1ps

module tb_crc_form (); /* this is automatically generated */

	logic rstb;
	logic srst;
	logic clk;

	// clock
	initial begin
		clk = '0;
		forever #(4) clk = ~clk;
	end

	// reset
	initial begin
		rstb <= '0;
		srst <= '0;
		#20
		rstb <= '1;
		repeat (5) @(posedge clk);
		srst <= '1;
		repeat (1) @(posedge clk);
		srst <= '0;
	end

	// (*NOTE*) replace reset, clock, others

	parameter n_buf = 360;
	parameter z     = 50;

	logic  [7:0] upr;
	logic  [7:0] channel;
	logic  [8:0] af0;
	logic  [8:0] af1;
	logic        rst;
	logic [31:0] fifo0;
	logic [31:0] fifo1;
	logic        rdreq0;
	logic        rdreq1;
	logic        fifo_empty0;
	logic        fifo_empty1;
	logic        end_tx;
	logic [31:0] q_ram;
	logic [10:0] adr_ram;
	logic [31:0] crc_buf;
	logic [15:0] nbuf;
	logic        full0;
	logic        full1;
	logic        fifo_clr;
	logic        start;

	crc_form #(
			.n_buf(n_buf),
			.z(z)
		) inst_crc_form (
			.upr         (upr),
			.channel     (channel),
			.af0         (af0),
			.af1         (af1),
			.clk         (clk),
			.rst         (rst),
			.fifo0       (fifo0),
			.fifo1       (fifo1),
			.rdreq0      (rdreq0),
			.rdreq1      (rdreq1),
			.fifo_empty0 (fifo_empty0),
			.fifo_empty1 (fifo_empty1),
			.end_tx      (end_tx),
			.q_ram       (q_ram),
			.adr_ram     (adr_ram),
			.crc_buf     (crc_buf),
			.nbuf        (nbuf),
			.full0       (full0),
			.full1       (full1),
			.fifo_clr    (fifo_clr),
			.start       (start)
		);

	initial begin
		// do something
		#0

		channel 	=0;
		upr 		=1;
		af0     	=360;
		af1 		=360;
		fifo0   	=32'haaaabbbb;
		fifo1   	=32'hccccdddd;
		fifo_empty0 =0;
		fifo_empty1 =0;
		end_tx 		=1;
		full0 		=0;
		full1 		=0;

		@(posedge clk)
		rst 			= 1'b0;
		@(posedge clk)
		rst 			= 1'b1;
		@(posedge clk)
		rst 			= 1'b0;

		#100000

		@(posedge clk)

		fifo_empty0 =1;
		fifo_empty1 =1;

		af0     	=0;
		af1 		=0;

		#100000

		@(posedge clk)

		fifo_empty0 =0;
		fifo_empty1 =0;

		af0     	=360;
		af1 		=360;


		repeat(10)@(posedge clk);
//		$finish;
	end

	// dump wave
	initial begin
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_crc_form.fsdb");
			$fsdbDumpvars(0, "tb_crc_form", "+mda", "+functions");
		end
	end

endmodule
