
`timescale 1ns/1ps

module tb_CRC32_eth (); /* this is automatically generated */

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

	logic        rst;
	logic [31:0] tst;
 	logic [31:0] data;
	logic [31:0] crc;
	logic [31:0] rev_crc;
	logic [31:0] Arr [];
	int size=0;
	int index=0;
	int i=0;

	crc
	c1(.clk(clk),.rst(rst),.in(data),.dat_out(crc));

	function automatic [31:0] revers;
	   input [31:0] d;
       int i=0;
       for (i=0;i<32;i++)
       revers[32-i-1]=d[i];
   endfunction

   always @(*)  rev_crc=revers(crc);


    initial 
    begin
    	$readmemh("hex_tst.txt", Arr);
    	size=$size(Arr);
    end

    byte unsigned dat [128];

    initial begin

        for (i=0; i < size; i=i+1)    $display("%d:%h",i,Arr[i]);
        $display("--------------");

		@(posedge clk);
		rst  <= 1;
		@(posedge clk);
		rst  <= 0;
//	    @(posedge clk);
        index=2;
        repeat(size-2)
        begin
        	data=Arr[index];
        	@(posedge clk);
        	index++;
        end
        $display("--------------");
 		repeat (15) @(posedge clk);

		$finish;
	end

	// dump wave
	initial begin
		$monitor("index:%h data:%h crc:%h revers:%h inv:%h inv_rev:%h rst:%h",index,data,crc,rev_crc,~crc,~rev_crc,rst);
	end

endmodule

