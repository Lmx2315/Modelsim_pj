
//---------------------------------------------------------------
//автор СС ОАО НПК НИИДАР
//
//
//tb для модуль приёма 51 байта данных из МК по SPI (через мк-ный DMA)
//Прием данных работает на частоте SPI МК и переводится в домен CLK ПЛИС
//
//---------------------------------------------------------------
`timescale 1 ns / 1 ns


module tb_DMA_SPI (); /* this is automatically generated */

logic clk_48 				=0;
logic clk_96 				=0;
logic rst_n	 				=0;
logic SCLK					=0;

	// clock
always #10.41666 clk_48=~clk_48;
always #20         SCLK=~SCLK;

	// reset
	initial begin
		rst_n <= '0;
		#20
		rst_n <= '1;
	end

	logic		clk_en			=1;
	logic        MOSI 			=0;
	logic        CS   			=1;
	logic [63:0] TIME 			=0;
	logic        SYS_TIME_UPDATE;
	logic [47:0] FREQ;
	logic [47:0] FREQ_STEP;
	logic [31:0] FREQ_RATE;
	logic [63:0] TIME_START;
	logic [15:0] N_impulse;
	logic [ 7:0] TYPE_impulse;
	logic [31:0] Interval_Ti;
	logic [31:0] Interval_Tp;
	logic [31:0] Tblank1;
	logic [31:0] Tblank2;
	logic        SPI_WR;
	logic [407:0] data_reg=0;


	DMA_SPI inst_DMA_SPI
		(
			.clk             (clk_48),
			.clk_en          (clk_en),
			.rst_n           (rst_n),
			.MOSI            (MOSI),
			.CS              (CS),
			.SCLK            (SCLK),
			.TIME            (),
			.SYS_TIME_UPDATE (),
			.FREQ            (),
			.FREQ_STEP       (),
			.FREQ_RATE       (),
			.TIME_START      (),
			.N_impulse       (),
			.TYPE_impulse    (),
			.Interval_Ti     (),
			.Interval_Tp     (),
			.Tblank1         (),
			.Tblank2         (),
			.SPI_WR          (SPI_WR)
		);

	initial 
	begin

	TIME        =64'h8000000000000001;
	FREQ        =48'h1;
	FREQ_STEP   =48'h2;
	FREQ_RATE   =32'h3;
	TIME_START  =64'h4;
	N_impulse   =16'h1;
	TYPE_impulse= 8'h0;
	Interval_Ti =32'h5;
	Interval_Tp =32'h6;
	Tblank1     =32'h7;
	Tblank2     =32'h8;

	#10
	data_reg    ={TIME,FREQ,FREQ_STEP,FREQ_RATE,TIME_START,N_impulse,
	TYPE_impulse,Interval_Ti,Interval_Tp,Tblank1,Tblank2};


	#1000
	@(negedge SCLK);
	repeat(408+1)
	begin
	@(negedge SCLK);
	CS=0;	
	MOSI    <=data_reg[407];
    data_reg<=data_reg<<1;
    end
    CS=1;


	//	$finish;
	end

	// dump wave
	initial begin
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_DMA_SPI.fsdb");
			$fsdbDumpvars(0, "tb_DMA_SPI", "+mda", "+functions");
		end
	end

endmodule
