
`timescale 1ns/1ps

module tb_udp_rcv (); /* this is automatically generated */

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

	logic [31:0] Arr [0:27];
	int sz=0;
	int index=0;
	int i=0;

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
	logic        rst;
	logic [31:0] data_to_mem;
	logic [31:0] stat_err;
	logic [15:0] size;
	logic        int_rsv;

logic FIFO_UDPrcv_rdreq;
logic FIFO_UDPrcv_rst;
logic FIFO_UDPrcv_wrreq;
logic fifo_desc_req;
logic w_descr_wr;
logic [31:0] fifo_data;
logic [15:0] fifo_desc;

fifo_udp_rcv	
fifo_udp_rcv_inst (
	.clock ( clk ),
	.data  ( data_to_mem ),
	.rdreq ( FIFO_UDPrcv_rdreq ),
	.sclr  ( FIFO_UDPrcv_rst ),//сброс fifo, формируется когда МК присылает 0xFFFF по "адресу"
	.wrreq ( FIFO_UDPrcv_wrreq ),
	.full  (  ),
	.q     (fifo_data)
	);

fifi_desc	
fifi_desc_inst (
	.clock   ( clk ),
	.data    ( size ),
	.rdreq   ( fifo_desc_req ),
	.sclr    ( FIFO_UDPrcv_rst ),
	.wrreq   ( w_descr_wr ),
	.full    (  ),
	.q       ( fifo_desc )
	);

	udp_rcv inst_udp_rcv
		(
			.clk         (clk),
			.rx_data     (rx_data),
			.rx_sop      (rx_sop),
			.rx_eop      (rx_eop),
			.rx_rdy      (rx_rdy),
			.rx_dval     (rx_dval),
			.rx_dsav     (rx_dsav),
			.rx_err      (rx_err),
			.rx_err_stat (rx_err_stat),
			.rx_frm_type (rx_frm_type),
			.rx_mod      (rx_mod),
			.rx_a_full   (rx_a_full),
			.rx_a_empty  (rx_a_empty),
			.rst         (rst),
			.data_to_mem (data_to_mem),
			.stat_err    (stat_err),
			.wren_mem    (FIFO_UDPrcv_wrreq),
			.size        (size),
			.int_rsv     (int_rsv),
			.desc_wr     (w_descr_wr)
		);

	task init();
		FIFO_UDPrcv_rdreq<=0;
        FIFO_UDPrcv_rst<=0;
        FIFO_UDPrcv_wrreq<=0;
        fifo_desc_req<=0;
        w_descr_wr<=0;
		rx_data     <= '0;
		rx_sop      <= '0;
		rx_eop      <= '0;
		rx_dval     <= '0;
		rx_dsav     <= '0;
		rx_err      <= '0;
		rx_err_stat <= '0;
		rx_frm_type <= '0;
		rx_mod      <= '0;
		rx_a_full   <= '0;
		rx_a_empty  <= '0;
		rst         <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			rx_data     <= '0;
			rx_sop      <= '0;
			rx_eop      <= '0;
			rx_dval     <= '0;
			rx_dsav     <= '0;
			rx_err      <= '0;
			rx_err_stat <= '0;
			rx_frm_type <= '0;
			rx_mod      <= '0;
			rx_a_full   <= '0;
			rx_a_empty  <= '0;
			rst         <= '0;
			@(posedge clk);
		end
	endtask

	task automatic drv (ref logic a);
		a=1;
	 @(posedge clk);
		a=0;
	endtask

	initial 
    begin
    	$readmemh("hex.txt", Arr);
    	sz=$size(Arr);
    	$display("size: %0d", sz);
    end

	initial begin
		// do something

		init();
		repeat(5)@(posedge clk);
		drive(5);
		drv(rst);
		drv(FIFO_UDPrcv_rst);//сбрасываем фифо
		repeat(10)@(posedge clk);
	    rx_dval=1;
	    index=0;
        repeat(sz-4)
        begin
        	rx_data=Arr[index];
          	if (index==(sz-5)) rx_eop=1;
          	if (index==0     ) rx_sop=1; else  rx_sop=0;    	
        	@(posedge clk);
        	index++;
        end        
        rx_eop=0;
        rx_dval=0;
        repeat(20)@(posedge clk);

//--------------------------------------------
        drv(fifo_desc_req); 

        repeat(sz-4) 
        begin
        	drv(FIFO_UDPrcv_rdreq);
        	@(posedge clk);
        	@(posedge clk);
        end
//--------------------------------------------

        #200
        repeat(10)@(posedge clk);
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
        repeat(20)@(posedge clk);

//--------------------------------------------
        drv(fifo_desc_req); 
        repeat(sz) 
        begin
        	drv(FIFO_UDPrcv_rdreq);
        	@(posedge clk);
        	@(posedge clk);
        end
//--------------------------------------------
        $display("--------------");
 		repeat (15) @(posedge clk);

		$finish;
	end

	initial begin
		$monitor("size:%dint_rsv:%h data_to_mem:%h",
			size,int_rsv,data_to_mem);
	end
	// dump wave
	initial begin
		// dump wave

		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_udp_rcv.fsdb");
			$fsdbDumpvars(0, "tb_udp_rcv", "+mda", "+functions");
		end
	end

endmodule
