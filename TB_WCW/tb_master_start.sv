
`timescale 1ns/1ps

module tb_master_start (); /* this is automatically generated */

	// clock
	logic clk48;
	initial begin
		clk48 = '0;
		forever #(10.0) clk48 = ~clk48;
	end

		// clock
	logic clk96;
	initial begin
		clk96 = '0;
		forever #(10.0) clk96 = ~clk96;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk48)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	logic [47:0] DDS_freq;
	logic [47:0] DDS_delta_freq;
	logic [31:0] DDS_delta_rate;
	logic        DDS_start;
	logic        REQ;
	logic        ACK;
	logic        REQ_COMMAND;
	logic        RESET;
	logic        CLK;
	logic [63:0] SYS_TIME;
	logic        SYS_TIME_UPDATE;
	logic        T1hz;
	logic        WR_DATA;
	logic [47:0] MEM_DDS_freq;
	logic [47:0] MEM_DDS_delta_freq;
	logic [31:0] MEM_DDS_delta_rate;
	logic [63:0] MEM_TIME_START;
	logic [15:0] MEM_N_impuls;
	logic [ 1:0] MEM_TYPE_impulse;
	logic [31:0] MEM_Interval_Ti;
	logic [31:0] MEM_Interval_Tp;
	logic [31:0] MEM_Tblank1;
	logic [31:0] MEM_Tblank2;
	logic        SYS_TIME_UPDATE_OK;
	logic [63:0] TIME;
	logic [63:0] TEST;
	logic        En_ADC;
	logic        En_Iz;
	logic        En_Pr;

	master_start inst_master_start
		(
			.DDS_freq           (DDS_freq),
			.DDS_delta_freq     (DDS_delta_freq),
			.DDS_delta_rate     (DDS_delta_rate),
			.DDS_start          (DDS_start),
			.REQ                (REQ),
			.ACK                (ACK),
			.REQ_COMMAND        (REQ_COMMAND),
			.RESET              (~srstb),
			.CLK                (clk48),
			.SYS_TIME           (SYS_TIME),
			.SYS_TIME_UPDATE    (SYS_TIME_UPDATE),
			.T1hz               (T1hz),
			.WR_DATA            (WR_DATA),
			.MEM_DDS_freq       (MEM_DDS_freq),
			.MEM_DDS_delta_freq (MEM_DDS_delta_freq),
			.MEM_DDS_delta_rate (MEM_DDS_delta_rate),
			.MEM_TIME_START     (MEM_TIME_START),
			.MEM_N_impuls       (MEM_N_impuls),
			.MEM_TYPE_impulse   (MEM_TYPE_impulse),
			.MEM_Interval_Ti    (MEM_Interval_Ti),
			.MEM_Interval_Tp    (MEM_Interval_Tp),
			.MEM_Tblank1        (MEM_Tblank1),
			.MEM_Tblank2        (MEM_Tblank2),
			.SYS_TIME_UPDATE_OK (SYS_TIME_UPDATE_OK),
			.TIME               (TIME),
			.TEST               (TEST),
			.En_ADC             (En_ADC),
			.En_Iz              (En_Iz),
			.En_Pr              (En_Pr)
		);

	dds_chirp 
dds1(
	.clk_96 		(clk96),    	// Clock
	.clk_48 		(clk48 	),
	.REQ			(REQ		),  	//запрос на передачу данных из 125 МГц в 96 МГц
    .ACK			(wACK		),		//подтверждение что данные переданы
	.DDS_freq 		(wFREQ 		),
	.DDS_delta_freq (wFREQ_STEP ),
	.DDS_delta_rate (wFREQ_RATE ),
	.start 			(DDS_start 	),
	.data_I 		(data_I 	),
	.data_Q 		(data_Q 	),
	.valid 			(dds_valid 	)	
);

	task init();
		ACK                <= '0;
		RESET              <= '0;
		CLK                <= '0;
		SYS_TIME           <= '0;
		SYS_TIME_UPDATE    <= '0;
		T1hz               <= '0;
		WR_DATA            <= '0;
		MEM_DDS_freq       <= 1000;
		MEM_DDS_delta_freq <= 10;
		MEM_DDS_delta_rate <=  1;
		MEM_TIME_START     <= 100;
		MEM_N_impuls       <= 1;
		MEM_TYPE_impulse   <= '0;
		MEM_Interval_Ti    <= 5000;
		MEM_Interval_Tp    <= 50;
		MEM_Tblank1        <= 500;
		MEM_Tblank2        <= 500;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			ACK                <= '0;
			RESET              <= '0;
			CLK                <= '0;
			SYS_TIME           <= '0;
			SYS_TIME_UPDATE    <= '0;
			T1hz               <= '0;
			WR_DATA            <= '0;
			MEM_DDS_freq       <= '0;
			MEM_DDS_delta_freq <= '0;
			MEM_DDS_delta_rate <= '0;
			MEM_TIME_START     <= '0;
			MEM_N_impuls       <= '0;
			MEM_TYPE_impulse   <= '0;
			MEM_Interval_Ti    <= '0;
			MEM_Interval_Tp    <= '0;
			MEM_Tblank1        <= '0;
			MEM_Tblank2        <= '0;
			@(posedge clk48);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk48);
		#100
		WR_DATA=1;
		#100
		WR_DATA=0;
		#1000
		T1hz=1;
		#100
		T1hz=0;

	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_master_start.fsdb");
			$fsdbDumpvars(0, "tb_master_start", "+mda", "+functions");
		end
	end

endmodule
