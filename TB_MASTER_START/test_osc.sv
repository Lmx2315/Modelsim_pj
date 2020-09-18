module tst_osc (
input clk,
output o);

parameter del = 125;

logic [31:0] acc=0;
logic front=0;

always @(posedge clk)
begin

if (acc!=del) acc<=acc+1; 
else 
	begin
	acc<=0; 
	front<=~front;
	end
end

assign o=front;

endmodule