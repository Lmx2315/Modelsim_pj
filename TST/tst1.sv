module tb_tst ;
	logic [3:0] data;
	logic clk=0;
	logic [3:0] Q;
	logic [7:0] Array [0:9];
	int i;

always #8 clk=~clk;

latch	
DUT(.clk(clk),.d(data),.q(Q));

initial
begin

$readmemh ("C:/Work_murmansk/Quartus/Modelsim_pj/TST/tst.txt",Array);

foreach (Array[i])
begin
	@(posedge clk);
	data=Array[i];
//	$display("input %h output %h",data,Q);
end
//$finish;
end

initial 
begin
$monitor("input %h output %h",data,Q,$time);
end

endmodule




module latch(input logic clk,
input logic[3:0] d,
output reg [3:0] q);
always @(clk)
if (clk) q <= d;
endmodule