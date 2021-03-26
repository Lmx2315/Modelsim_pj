module crc (
	input clk,
	input rst,
	input  [31:0]  in,
	output reg [31:0] dat_out
);
reg  [31:0] crcIn=0;
reg  [ 7:0] data0 =0;
reg  [ 7:0] data1 =0;
reg  [ 7:0] data2 =0;
reg  [ 7:0] data3 =0;

reg [31:0] crc0;
reg [31:0] crc1;
reg [31:0] crc2;
reg [31:0] crc3;

reg step=0;

always_ff @(posedge clk)
if (rst) 
	begin	
	step<=0;
	end
else
begin
	if (step==0) begin crcIn<=32'hffff_ffff; step<=1;end
		else  crcIn<=crc3;

   dat_out<=crc3;
/*
   data3  <={in[ 0],in[ 1],in[ 2],in[ 3],in[ 4],in[ 5],in[ 6],in[ 7]};
   data2  <={in[ 8],in[ 9],in[10],in[11],in[12],in[13],in[14],in[15]};
   data1  <={in[16],in[17],in[18],in[19],in[20],in[21],in[22],in[23]};
   data0  <={in[24],in[25],in[26],in[27],in[28],in[29],in[30],in[31]};
*/

   data3<=in[ 7: 0];
   data2<=in[15: 8];
   data1<=in[23:16];
   data0<=in[31:24]; 

end

always_comb
begin
crc0 = crc_32x8(crcIn,data0);
crc1 = crc_32x8( crc0,data1);
crc2 = crc_32x8( crc1,data2);
crc3 = crc_32x8( crc2,data3);
// dat_out=crc3;
end


function bit [31:0] crc_32x1 (input bit [31:0] crc, input bit d);
    bit msb;
  begin
    msb       = crc[31];
    crc_32x1  = crc << 1;

    crc_32x1[ 0] = d ^ msb;
    crc_32x1[ 1] = d ^ msb ^ crc[ 0];
    crc_32x1[ 2] = d ^ msb ^ crc[ 1];
    crc_32x1[ 4] = d ^ msb ^ crc[ 3];
    crc_32x1[ 5] = d ^ msb ^ crc[ 4];
    crc_32x1[ 7] = d ^ msb ^ crc[ 6];
    crc_32x1[ 8] = d ^ msb ^ crc[ 7];
    crc_32x1[10] = d ^ msb ^ crc[ 9];
    crc_32x1[11] = d ^ msb ^ crc[10];
    crc_32x1[12] = d ^ msb ^ crc[11];
    crc_32x1[16] = d ^ msb ^ crc[15];
    crc_32x1[22] = d ^ msb ^ crc[21];
    crc_32x1[23] = d ^ msb ^ crc[22];
    crc_32x1[26] = d ^ msb ^ crc[25];
  end
  endfunction
  //
  //
  //
 
  function bit [31:0] crc_32x8(input bit [31:0] crc, input bit [7:0] data);
    int i;
  begin
    crc_32x8 = crc;
    for (i = 8; i > 0; i--) begin
      crc_32x8 = crc_32x1 (crc_32x8, data[i-1]);
    end
  end
  endfunction

endmodule


