module SPI_TEST (
input clk,
input cs,
input sclk,
input mosi,
output miso,
input [31:0] data );

reg [3:0] frnt=0;

always @
