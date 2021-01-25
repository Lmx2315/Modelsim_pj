
//{{ Section below this comment is automatically maintained
//   and may be overwritten
//{module {Block_upr_spi1}}
module Block_read_spi_v2 ( clk,sclk,mosi,miso,cs ,rst ,clr,inport );	

parameter Nbit=8;	
parameter param_adr=1; 

input  [Nbit-1:0] inport ;
wire   [Nbit-1:0] inport ;

output  miso;
output clr;

input clk ;
wire clk ;	 
input sclk ;
wire sclk ;
input mosi ;
wire mosi ;
input cs ;
wire cs ;
input rst ;
wire rst ;	

reg clr_reg=0;
reg start=0;
reg [Nbit-1:0] data_port=0; 
reg [Nbit-1:0] data_in=0; 
reg [4:0] front_clk_spi=0;	 
reg [4:0] front_cs_spi=0;	 
reg [3:0] flag=0;   
reg [7:0] sch;	 
reg reg_o=0;
reg r_w = 0;//
reg [Nbit:0] reg_out='1;

always @(posedge clk) front_clk_spi<={front_clk_spi[3:0],sclk};
always @(posedge clk) front_cs_spi <={front_cs_spi [3:0],cs};
	
always @(posedge clk)
begin 
if (rst)
	begin sch<=0;flag<=0;reg_out<='1;r_w<=0; end
	else 
		if (front_cs_spi[3:1]==3'b110)	 begin sch<=0; flag<=0;start<=1;end
		else
			if (start==1) 
				begin
					if (flag==0)		//
					begin  		
						if (front_clk_spi[2:0]==3'b001) 
						begin
						data_in<={data_in[Nbit-2:0],mosi};
						sch<=sch+1;						
						end	
					    else if (sch==8)  
							begin 							
							if ((front_clk_spi[2:0]==3'b100   )&&//ждём спад 8-го импульса пачки записи для подготовки работы с чтением 	
							    (      data_in[6:0]==param_adr))
									begin
									reg_out[Nbit:1]<=inport;
									flag<=1; 
									sch<=0;
									end	
							else  if (data_in[6:0]!=param_adr) start<=0;
							
							r_w <=data_in[7]; 							
							end 		
					end
					else  
						if (flag==1)
							begin
								if (r_w==0) //
									begin
										if (front_clk_spi[2:0]==3'b100) 
										begin
											if (sch!=Nbit)
											begin
											reg_out<=reg_out<<1;
												sch<=sch+1;
											end 
										end
												else
													if (sch==Nbit)
													begin
					  							    reg_out<='1;	
													  start<=0;
													clr_reg<=1;													
													end
																					
									end
							end
				end	else clr_reg<=0;
end

  assign 	   miso =reg_out[Nbit];	
  assign   	   clr  =clr_reg;
	
endmodule  