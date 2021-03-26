module pulse_init(clk, enable, lat, dck);

input wire clk;
input wire enable;
output  reg lat;
output wire dck;

parameter DELAY0   =1;//задержка в тактах
parameter DELAY1   =1; //задержка в тактах

reg [31:0] sch0      =0;
reg [31:0] delay_us  =0;
reg [ 6:0] tmp       =0;
reg [ 3:0] state     =0;
reg [ 3:0] next_state=0;

always @(posedge clk) if (sch0>0) sch0 <=sch0-1; else sch0<=delay_us;

always @(posedge clk) 
	if (~enable) 
	begin
    delay_us<=0;
	state   <=0;			
	end else
	begin
	state<=next_state;
	end

always @(*)
begin
	case (state)
	 0: begin lat=0;tmp=7'b0101010; next_state=1; end
	 1: begin next_state=2;  lat=1; delay_us=(DELAY0-1); end
	 2: if (sch0==0)  
	    begin 
	    tmp=tmp>>1;
	    delay_us=(DELAY1-1);	
	    if (tmp!=0) next_state=2; else begin next_state=3; delay_us=(DELAY0-1);end	    
	    end 
	 3: begin 	 	
	 	next_state=4;
	    end
	 4: if (sch0==0) lat=0;
	 default: next_state=0;
	endcase 
end

assign dck=tmp[0];

endmodule 