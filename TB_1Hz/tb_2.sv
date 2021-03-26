
//---------------------------------------------------------------
//����� �� ��� ��� ������
//
//
//tb ��� ������ ����� 51 ����� ������ �� �� �� SPI (����� ��-��� DMA)
//����� ������ �������� �� ������� SPI �� � ����������� � ����� CLK ����
//
//---------------------------------------------------------------
`timescale 1 ns / 1 ns

module tb_2 (); /* this is automatically generated */

logic clk_48 				=0;
logic clk_96 				=0;
logic rst	 				=0;
logic SCLK					=0;

	// clock 10.41666667
always #10		  clk_48=~clk_48;
always #20          SCLK=~SCLK;
	
	logic [63:0] wTIME 			;
	logic 		 T1HZ 			=0;
	
	logic		clk_en			=1;
	logic        MOSI 			=0;
	logic        CS   			=1;
	logic [63:0] sTIME 			=0;
	logic        sSYS_TIME_UPDATE;
	logic [47:0] sFREQ;
	logic [47:0] sFREQ_STEP;
	logic [31:0] sFREQ_RATE;
	logic [63:0] sTIME_START;
	logic [15:0] sN_impulse;
	logic [ 7:0] sTYPE_impulse;
	logic [31:0] sInterval_Ti;
	logic [31:0] sInterval_Tp;
	logic [31:0] sTblank1;
	logic [31:0] sTblank2;
	logic        SPI_WR;
	logic [407:0] data_reg=0;

	logic [407:0] test_data;
	logic [  7:0]  DATA_out;
	logic 		   TxD_busy;	 
	logic 		   SEND;

	logic [ 63:0]	 tmp_TIME 		  ;
	logic [ 47:0] 	 tmp_FREQ 		  ;
	logic [ 47:0] 	 tmp_FREQ_STEP 	  ;
	logic [ 31:0] 	 tmp_FREQ_RATE	  ;
	logic [ 63:0]    tmp_TIME_START   ;
	logic [ 15:0]    tmp_N_impulse    ;
	logic [  7:0]    tmp_TYPE_impulse ;
	logic [ 31:0]    tmp_Interval_Ti  ;
	logic [ 31:0]    tmp_Interval_Tp  ;
	logic [ 31:0]    tmp_Tblank1	  ;
	logic [ 31:0]    tmp_Tblank2	  ;
	
// ����� ��� ����� ������� � ��������������
logic [47:0] mFREQ     		;
logic [47:0] mFREQ_STEP 	;
logic [31:0] mFREQ_RATE 	;
logic [63:0] mTIME_START	;
logic [15:0] mN_impuls 		;
logic [ 1:0] mTYPE_impulse 	;
logic [31:0] mInterval_Ti 	;
logic [31:0] mInterval_Tp 	;
logic [31:0] mTblank1 		;
logic [31:0] mTblank2 		;

//----------------------------

logic [47:0] 	wFREQ 		;
logic [47:0] 	wFREQ_STEP 	;
logic [31:0] 	wFREQ_RATE	;
logic 			DDS_START 	;

logic [15:0] dds_data_I;
logic [15:0] dds_data_Q;
logic 		 dds_valid ;

logic 		SYS_TIME_UPDATE_OK;
logic 		wEn_Iz;
logic 		wEn_Pr;

logic wREQ=0;
logic wACK=0;
logic RSR_WCW=0;
//---------------------------------
	assign test_data={tmp_TIME       ,tmp_FREQ     ,tmp_FREQ_STEP   ,tmp_FREQ_RATE  ,
					  tmp_TIME_START ,tmp_N_impulse,tmp_TYPE_impulse,tmp_Interval_Ti,
					  tmp_Interval_Tp,tmp_Tblank1  ,tmp_Tblank2};
//----------------------------------------------
	DMA_SPI spi1
		(
			.clk             (clk_48),
			.clk_en          (clk_en),
			.rst_n           (~rst),
			.MOSI            (MOSI),
			.CS              (CS),
			.SCLK            (SCLK),
//-----------------------------------------------
			.TIME            (tmp_TIME),
			.SYS_TIME_UPDATE (sSYS_TIME_UPDATE),
			.FREQ            (tmp_FREQ),
			.FREQ_STEP       (tmp_FREQ_STEP),
			.FREQ_RATE       (tmp_FREQ_RATE),
			.TIME_START      (tmp_TIME_START),
			.N_impulse       (tmp_N_impulse),
			.TYPE_impulse    (tmp_TYPE_impulse),
			.Interval_Ti     (tmp_Interval_Ti),
			.Interval_Tp     (tmp_Interval_Tp),
			.Tblank1         (tmp_Tblank1),
			.Tblank2         (tmp_Tblank2),
//----------------------------------------------
			.SPI_WR          (SPI_WR),
			.RESET_WCW       (RSR_WCW)
		);
		
wcm 
wcm1(						  		  //���� ������ � ������ ������ ��������� ������� � ������ � ��.
.CLK 		    (clk_48),
.rst_n 	        (~RSR_WCW           ),//rst
.REQ_COMM 	    (w_REQ_COMM   		),//������ ����� ������� ��� ���������� ��������������� (��� ����)
.TIME 		    (wTIME 		 		),//������� ��������� ����� 
.SYS_TIME_UPDATE(SYS_TIME_UPDATE_OK	),//������ ���������� � ������������ ���������� �������!!!
.FREQ           (tmp_FREQ	 		),//������ � ���������� ��
.FREQ_STEP      (tmp_FREQ_STEP 		),//----------------------
.FREQ_RATE      (tmp_FREQ_RATE 		),//--------//------------ 
.TIME_START     (tmp_TIME_START	 	),
.N_impulse 	    (tmp_N_impulse 		),
.TYPE_impulse   (tmp_TYPE_impulse 	),
.Interval_Ti    (tmp_Interval_Ti	),
.Interval_Tp    (tmp_Interval_Tp	),
.Tblank1 	    (tmp_Tblank1 		),
.Tblank2        (tmp_Tblank2 		),
.SPI_WR		    (SPI_WR 		 	),  //������ ������ ��� ������ �� ��� � ������ ��������� �������
.DATA_WR 	    (mem_WR		 		),  //������ ������ ��� �������� ������ � ���� �������������
.FREQ_z         (mFREQ 		 		),  //����� ������� ��������� �� ������ � ���� ������������� � ����������
.FREQ_STEP_z    (mFREQ_STEP 	 	),
.FREQ_RATE_z    (mFREQ_RATE 	 	),
.TIME_START_z   (mTIME_START	 	),
.N_impuls_z     (mN_impuls 	 		),
.TYPE_impulse_z (mTYPE_impulse		),
.Interval_Ti_z  (mInterval_Ti 		),
.Interval_Tp_z  (mInterval_Tp 		),
.Tblank1_z      (mTblank1 	 		),
.Tblank2_z      (mTblank2 	 		), //-----//-------	
.FLAG_CMD_SEARCH_FAULT(				),	//���� � "1" �� � ������ �� ������� ����� ������� �� ����������, �� ����� ������� ������������ ����� ������ � ������ !!!
.SCH_BUSY_REG_MEM_port(             ),	//��� ������� ���������� ������� ����� ������ - ����� ����������� ������
.TEST 			(					) 
);		
//-------------������������� ����������� 48 ��� !!!-------------
master_start 
sync1(
.DDS_freq 			(wFREQ 				),
.DDS_delta_freq 	(wFREQ_STEP 		),
.DDS_delta_rate 	(wFREQ_RATE 		),
.DDS_start 			(DDS_START 			),
.REQ				(wREQ				),	//������ �� �������� ������
.ACK				(wACK				),  //������������� �������� ������ �� DDS
.REQ_COMMAND 		(w_REQ_COMM 		),  //������ ����� ������� �� ������� ��������� �������
.RESET 				(rst 				),
.CLK 				(clk_48 			),
.SYS_TIME 			(tmp_TIME			),	//��� ������� ��� ������������� �� ������� T1c
.SYS_TIME_UPDATE 	(sSYS_TIME_UPDATE 	),	//������ ���������� ������� �������� ���������� ��������� ���������� ������� �� ������� T1hz 
.TIME 				(wTIME 				),
.TEST 				(			        ),	
.T1hz 				(T1HZ 				),	//������ ��������� �����
.WR_DATA 			(mem_WR 			),  //������ ������ ������ � �������������
.MEM_DDS_freq 		(mFREQ 				),  //������ ������� �� ������� ��������� �������
.MEM_DDS_delta_freq (mFREQ_STEP  		),  //������ ������� �� ������� ��������� �������
.MEM_DDS_delta_rate (mFREQ_RATE			),  //������ ������� �� ������� ��������� �������
.MEM_TIME_START 	(mTIME_START 		),  //������ ������� �� ������� ��������� �������
.MEM_N_impuls 		(mN_impuls 			),  //������ ������� �� ������� ��������� �������
.MEM_TYPE_impulse 	(mTYPE_impulse   	),  //��� ����������� �����  :0 - ������������� (�������������),1 - ����������� (DDS �� �������������������)
.MEM_Interval_Ti 	(mInterval_Ti 		),  //������ ������� �� ������� ��������� �������
.MEM_Interval_Tp 	(mInterval_Tp 		),  //������ ������� �� ������� ��������� �������
.MEM_Tblank1		(mTblank1 			),  //������ ������� �� ������� ��������� �������
.MEM_Tblank2 		(mTblank2 			),  //������ ������� �� ������� ��������� �������
.SYS_TIME_UPDATE_OK (SYS_TIME_UPDATE_OK ),	//���� ������������,��� �� ��������� ����� ��������� ��������� ���������� �������
.En_Iz 				(En_Iz 				),  //������������� �������� ���������
.En_Pr 				(En_Pr 				)   //������������� �������� �����
);

	initial 
	begin
	#100
	@(posedge clk_48)
	rst 			= 1'b0 				 ;
	#100
	@(posedge clk_48)
	rst 			= 1'b1 				 ;
	#300
	@(posedge clk_48)
	rst 			= 1'b0 				 ;  // ������� ������ ������ ��������� ������� �� 256 ��������� ��� 6 ���!!! (48 ��� clk)	

//--------------�������� ��������� �����--------------------
	#1000;
	@(posedge clk_48)
	T1HZ 			= 1'b1 				 ;	

	#1000;
	@(posedge clk_48)
	T1HZ 			= 1'b0 				 ;
//----------------------------------------------------------	
	
	#1000000
	@(posedge clk_48)

	sTIME        =64'h0000000000000001;//������������� �������
	sFREQ        =48'h280000000000;
	sFREQ_STEP   =48'h0000002cbd3f;
	sFREQ_RATE   =32'h00000001;
	sTIME_START  =64'd50000;//����� ����� 10 ��
	sN_impulse   =16'd10;
	sTYPE_impulse= 8'h00;
	sInterval_Ti =32'd100;//1000 us
	sInterval_Tp =32'd100;
	sTblank1     =32'd10;//10 us
	sTblank2     =32'd5;

	#1000
	data_reg    ={sTIME,sFREQ,sFREQ_STEP,sFREQ_RATE,sTIME_START,sN_impulse,
	sTYPE_impulse,sInterval_Ti,sInterval_Tp,sTblank1,sTblank2};

	#1000000
	@(negedge SCLK);
	repeat(408+1)
	begin
	@(negedge SCLK);
	CS=0;	
	MOSI    <=data_reg[407];
    data_reg<=data_reg<<1;
    end
    CS=1;

	#4000000
//--------------�������� ��������� �����--------------------
	#1000;
	@(posedge clk_48)
	T1HZ 			= 1'b1 				 ;	

	#10000;
	@(posedge clk_48)
	T1HZ 			= 1'b0 				 ;
//----------------------------------------------------------	

	#18000000
	sTIME        =64'h0000000000000000;//������������� �������
	sTIME_START  =64'd24000;//����� ����� ... ��
	
	data_reg    ={sTIME,sFREQ,sFREQ_STEP,sFREQ_RATE,sTIME_START,sN_impulse,
	sTYPE_impulse,sInterval_Ti,sInterval_Tp,sTblank1,sTblank2};

	#1000000
	@(negedge SCLK);
	repeat(408+1)
	begin
	@(negedge SCLK);
	CS=0;	
	MOSI    <=data_reg[407];
    data_reg<=data_reg<<1;
    end
    CS=1;
//-------------------------------------------------------------	
	#1000000
	sTIME        =64'h0000000000000000;//������������� �������
	sTIME_START  =64'd48000;//����� ����� ... ��
	
	data_reg    ={sTIME,sFREQ,sFREQ_STEP,sFREQ_RATE,sTIME_START,sN_impulse,
	sTYPE_impulse,sInterval_Ti,sInterval_Tp,sTblank1,sTblank2};

	#1000000
	@(negedge SCLK);
	repeat(408+1)
	begin
	@(negedge SCLK);
	CS=0;	
	MOSI    <=data_reg[407];
    data_reg<=data_reg<<1;
    end
    CS=1;	
	
    #1000000
	//--------------�������� ��������� �����--------------------
	#1000;
	@(posedge clk_48)
	T1HZ 			= 1'b1 				 ;	

	#10000;
	@(posedge clk_48)
	T1HZ 			= 1'b0 				 ;
//----------------------------------------------------------

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
