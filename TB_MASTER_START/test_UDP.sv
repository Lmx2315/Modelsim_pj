module test_UDP (
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low

	output [31:0] out_dat,
	output  valid	
);

logic [15:0] dat_i=0;
logic [15:0] dat_q=0;
logic [15:0] sch=0;
logic reg_val=0;

always_ff @(posedge clk or negedge rst_n) 
begin : proc_
	if(~rst_n) 
	begin
	sch	 <= 0;
	dat_i<= 16'b0111111111111111;
	dat_q<= 16'b0111111111111111;
	end else 
	if(clk_en) 
	begin
	if (sch<20)	 
		begin
			sch<=sch+1;
			reg_val<=0;
		end
	else 
		begin
			sch<=0;
			dat_i<=~dat_i;
			dat_q<=~dat_q; 
			reg_val<=1;
		end
	end
end

assign out_dat={dat_i,dat_q};
assign valid  =reg_val;
endmodule