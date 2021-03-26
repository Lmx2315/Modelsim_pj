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
	if (step==0) begin crcIn<=32'hffffffff; step<=1;end
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
crc0=crc(data0,crcIn);
crc1=crc(data1,crc0);
crc2=crc(data2,crc1);
crc3=crc(data3,crc2);
end

function automatic [31:0] crc;
    input [7:0] data;
  input [31:0] crcIn;

begin
  crc[0] = (crcIn[2] ^ crcIn[8] ^ data[2]);
  crc[1] = (crcIn[0] ^ crcIn[3] ^ crcIn[9] ^ data[0] ^ data[3]);
  crc[2] = (crcIn[0] ^ crcIn[1] ^ crcIn[4] ^ crcIn[10] ^ data[0] ^ data[1] ^ data[4]);
  crc[3] = (crcIn[1] ^ crcIn[2] ^ crcIn[5] ^ crcIn[11] ^ data[1] ^ data[2] ^ data[5]);
  crc[4] = (crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[6] ^ crcIn[12] ^ data[0] ^ data[2] ^ data[3] ^ data[6]);
  crc[5] = (crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[7] ^ crcIn[13] ^ data[1] ^ data[3] ^ data[4] ^ data[7]);
  crc[6] = (crcIn[4] ^ crcIn[5] ^ crcIn[14] ^ data[4] ^ data[5]);
  crc[7] = (crcIn[0] ^ crcIn[5] ^ crcIn[6] ^ crcIn[15] ^ data[0] ^ data[5] ^ data[6]);
  crc[8] = (crcIn[1] ^ crcIn[6] ^ crcIn[7] ^ crcIn[16] ^ data[1] ^ data[6] ^ data[7]);
  crc[9] = (crcIn[7] ^ crcIn[17] ^ data[7]);
  crc[10] = (crcIn[2] ^ crcIn[18] ^ data[2]);
  crc[11] = (crcIn[3] ^ crcIn[19] ^ data[3]);
  crc[12] = (crcIn[0] ^ crcIn[4] ^ crcIn[20] ^ data[0] ^ data[4]);
  crc[13] = (crcIn[0] ^ crcIn[1] ^ crcIn[5] ^ crcIn[21] ^ data[0] ^ data[1] ^ data[5]);
  crc[14] = (crcIn[1] ^ crcIn[2] ^ crcIn[6] ^ crcIn[22] ^ data[1] ^ data[2] ^ data[6]);
  crc[15] = (crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ crcIn[23] ^ data[2] ^ data[3] ^ data[7]);
  crc[16] = (crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[24] ^ data[0] ^ data[2] ^ data[3] ^ data[4]);
  crc[17] = (crcIn[0] ^ crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[25] ^ data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[5]);
  crc[18] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[26] ^ data[0] ^ data[1] ^ data[2] ^ data[4] ^ data[5] ^ data[6]);
  crc[19] = (crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[27] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[6] ^ data[7]);
  crc[20] = (crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[28] ^ data[3] ^ data[4] ^ data[6] ^ data[7]);
  crc[21] = (crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[29] ^ data[2] ^ data[4] ^ data[5] ^ data[7]);
  crc[22] = (crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[30] ^ data[2] ^ data[3] ^ data[5] ^ data[6]);
  crc[23] = (crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[31] ^ data[3] ^ data[4] ^ data[6] ^ data[7]);
  crc[24] = (crcIn[0] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ data[0] ^ data[2] ^ data[4] ^ data[5] ^ data[7]);
  crc[25] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[6]);
  crc[26] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[7]);
  crc[27] = (crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ data[1] ^ data[3] ^ data[4] ^ data[5] ^ data[7]);
  crc[28] = (crcIn[0] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ data[0] ^ data[4] ^ data[5] ^ data[6]);
  crc[29] = (crcIn[0] ^ crcIn[1] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ data[0] ^ data[1] ^ data[5] ^ data[6] ^ data[7]);
  crc[30] = (crcIn[0] ^ crcIn[1] ^ crcIn[6] ^ crcIn[7] ^ data[0] ^ data[1] ^ data[6] ^ data[7]);
  crc[31] = (crcIn[1] ^ crcIn[7] ^ data[1] ^ data[7]);
end
endfunction

endmodule


