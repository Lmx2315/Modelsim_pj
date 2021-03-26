module crc32(clk,en,d,q);
localparam N=32, P=32'hEDB88320;
input clk,en;
input [N-1:0] d;
output [31:0] q;
integer i; 
reg [31:0] c;
always@(posedge clk)begin
	if(en) for(i=0;i<N;i=i+1) c=(c^d[i])&1?(c>>1)^P:c>>1; 	
	else c=~0; 		
end		
assign q=~c;
endmodule