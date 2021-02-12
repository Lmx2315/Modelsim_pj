
`timescale 1ns/1ps

module tb_crc_form (); /* this is automatically generated */

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

	function automatic int data_fifo ;		
			 data_fifo=$random();
		endfunction

	task automatic drv (int dimp,int state,ref logic pin);//pin - внешний сигнал, dimp - длительность сигнала, state - уровень сигнала
	begin
	int j;
  	if (state==1) begin pin=1; for(j = 0; j < 2*dimp; j++) @(posedge clk); end 
	else
	if (state==0) begin pin=0; for(j = 0; j < 2*dimp; j++) @(posedge clk); end
	end
	endtask

	task automatic drive(int state,int iter,ref logic pin);
		for(int it = 0; it < iter; it++) begin
			pin= state;
			@(posedge clk);
			pin=~state;
		end
	endtask

	parameter n_buf = 360;
	parameter     z = 125;

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
			.DELAY_PKG(z)
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

	task init();
		upr         <= '0;
		af0         <= 365;
		af1         <= 365;
		rst         <= '0;
		fifo0       <= '0;
		fifo1       <= '0;
		fifo_empty0 <= '0;
		fifo_empty1 <= '0;
		end_tx      <=  1;
		full0       <= '0;
		full1       <= '0;
	endtask


	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		#1000;
		drive(1,2,rst);

		#10000;


	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
	end

endmodule
