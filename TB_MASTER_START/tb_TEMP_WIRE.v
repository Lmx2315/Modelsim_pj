`timescale 1 ns / 1 ns

module tb_TEMP_wire ();

logic clk_125 =0;
logic rst=0;
logic  TMP_SIG=1;
logic TMP_OE;
logic [31:0] timer0=200*125;

logic e1=0;

always #4 clk_125=~clk_125;

initial
begin
	@(posedge clk_125)
	#0
	@(posedge clk_125)
	rst = 1'b1;
	#100
	@(posedge clk_125)
	rst = 1'b0;	
	#400000
	@(posedge e1)
	TMP_SIG=0;
	#200000
	TMP_SIG=1;

/*	
	#6000000
	@(posedge clk_125)
	#0
	@(posedge clk_125)
	rst = 1'b1;
	#100
	@(posedge clk_125)
	rst = 1'b0;	
	@e1
	TMP_SIG=0;
	#200000
	TMP_SIG=1;
*/	
end

always_ff @(posedge TMP_OE or negedge TMP_OE)
if (TMP_OE) e1<=0;
else        e1<=1;

temp_1wire
dut1(
.clk       (clk_125),	//тактирование
.rst       (rst),		//сброс модуля
.done      (),			//сигнал готовности результата
.T_data    (),          //результат
.tmp_oe	   (TMP_OE),	//тестовый сигнал - говорит о направлении работы TEMP_DQ
.tmp_out   (TMP_SIG),
.tmp_in    (TMP_SIG),
.TEMP_DQ   ()			//бинаправленный вывод
);

endmodule