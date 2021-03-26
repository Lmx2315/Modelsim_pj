
`timescale 1ns/1ps

module tb_delay_96 (); /* this is automatically generated */

	logic [31:0] var_arr=0;

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

	parameter size = 20;

	logic        rst;
	logic [31:0] Idat0;
	logic [31:0] Idat1;
	logic        wr_comm0;
	logic        wr_comm1;
	logic  [7:0] upr0;
	logic  [7:0] upr1;
	logic [31:0] Odat0;
	logic [31:0] Odat1;

	delay_96 #(
			.size(size)
		) inst_delay_96_0 (
			.clk     (clk),
			.rst     (rst),
			.Idat    (Idat0),
			.wr_comm (wr_comm0),
			.upr     (upr0),
			.Odat    (Odat0)
		);


	delay_96 #(
			.size(size)
		) inst_delay_96_1 (
			.clk     (clk),
			.rst     (rst),
			.Idat    (Idat1),
			.wr_comm (wr_comm1),
			.upr     (upr1),
			.Odat    (Odat1)
		);

	task init();
		rst      <= '0;
		Idat0    <= '0;
		wr_comm0 <= '0;
		upr0     <= '0;
		Idat1    <= '0;
		wr_comm1 <= '0;
		upr1     <= '0;
	endtask

	task automatic drv (ref logic a);
		a=1;
	    @(posedge clk);
		a=0;
	endtask

	 task automatic data_send (ref logic [31:0] z);
		 int a=0;
		for (int i=0;i<32;i++) 
		begin
			a=a+1;
			z=a;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

	    drv(rst);
	    upr0=0;
		drv(wr_comm0);
		upr1=1;
		drv(wr_comm1);
		Idat0=0;
		Idat1=0;
	    fork
	    //-----------------------
		data_send (Idat0);
	    //-----------------------
		data_send (Idat1);	
		//-----------------------
        join
        Idat0=0;
        Idat1=0;

        #1000

        drv(rst);
	    upr0=0;
		drv(wr_comm0);
		upr1=2;
		drv(wr_comm1);
		Idat0=0;
		Idat1=0;
	    fork
	    //-----------------------
		data_send (Idat0);
	    //-----------------------
		data_send (Idat1);	
		//-----------------------
        join

        Idat0=0;
        Idat1=0;

        #1000

        drv(rst);
	    upr0=0;
		drv(wr_comm0);
		upr1=3;
		drv(wr_comm1);
		Idat0=0;
		Idat1=0;
	    fork
	    //-----------------------
		data_send (Idat0);
	    //-----------------------
		data_send (Idat1);	
		//-----------------------
        join

        Idat0=0;
        Idat1=0;

	//	$finish;
	end

	// dump wave
	initial 
	begin

		$monitor ("Odat:%d | %d",Odat0,Odat1);
	end

endmodule
