module tb_1 ();

reg  clk=0;
reg  enable=0;
wire lat,dck;

always #50 clk=~clk;

initial
begin
 enable=0;
 #1000
 enable=0;
 @(posedge clk);
 enable=1;
  #10000
 enable=0;
 @(posedge clk);
 enable=1;  
end

initial
begin
$monitor("lat:%d  dck:%d",lat,dck);
end

pulse_init
inst1(.clk(clk), .enable(enable), .lat(lat), .dck(dck));

endmodule