
`timescale 1ns/1ps

module tb_spi_write (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(4.0) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	parameter      Nbit = 32;
	parameter param_adr = 1;//1-ца в старшем разряде признак "записи"
	parameter     Dlitl = 5; //длительность интервала sclk относительно clk    

	logic            sclk;
	logic            mosi;
	logic            miso;
	logic            cs;
	logic [Nbit-1:0] outport;
	int 	         adr;
	logic [Nbit-1:0] data;

	spi_write #(
			.Nbit(Nbit),
			.param_adr(param_adr)
		) inst_Block_write_spi (
			.clk    (clk),
			.sclk   (sclk),
			.mosi   (mosi),
			.miso   (miso),
			.cs     (cs),
			.clr    (),
			.out    (outport)
		);


	task init();
		sclk   <= '0;
		mosi   <= '1;
		cs     <= '1;
		adr    <= 1;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			sclk   <= '1;
			mosi   <= '1;
			cs     <= '1;
			@(posedge clk);
		end
	endtask


 task automatic SPI_READER(int Nbit,int dimp,ref logic miso,ref logic sclk);		
		begin
			fork
			drv_imp(0,dimp,Nbit,sclk);
			join
		end
	endtask

 task automatic SPI_WRITER(int Nbit,int data,int dimp,ref logic mosi,ref logic sclk);//bit - разрядность, data - данные		
		begin
			logic out;
			fork
			drv_imp(dimp,dimp,Nbit,sclk);//тут делаем Nbit клоков с задержкой перед клоками = dimp и длинной импульса = dimp
			for(int i = 0; i < Nbit; i++)
				begin
					drv(dimp,data[Nbit-1],mosi);
					data=data<<1;			 		
				end
			drv(dimp,32,mosi);
			join
		end
	endtask



task automatic drv_imp (int delay,int dimp,int col,ref logic state);//delay - задержка сигнала,state - внешний сигнал, dimp - длительность импульса, col - количество импульсов
	begin
		for(int i = 0; i < delay; i++) @(posedge clk); //задержка на delay тактов
        for(int n = 0; n < col;  n++)
        begin        	
        	state = 1;
			for(int i = 0; i < dimp;  i++) @(posedge clk);
			state = 0;
			for(int j = 0; j < dimp;  j++) @(posedge clk);
	    end
	end
endtask

task automatic drv (int dimp,int state,ref logic pin);//pin - внешний сигнал, dimp - длительность сигнала, state - уровень сигнала
	begin
	int j;
  	if (state==1) begin pin=1; for(j = 0; j < 2*dimp; j++) @(posedge clk); end 
	else
	if (state==0) begin pin=0; for(j = 0; j < 2*dimp; j++) @(posedge clk); end
	end
endtask

	initial begin
		// do something
		data=32'hdeedbeef;
		init();
		repeat(10)@(posedge clk);
		adr = 1|8'h80;
		cs=0;
		repeat(10)@(posedge clk);
		SPI_WRITER(8,adr,Dlitl,mosi,sclk);
		repeat(1)@(posedge clk);
        SPI_WRITER(32,data,Dlitl,mosi,sclk);
        repeat(10)@(posedge clk);
        cs=1;

        #5000;

        data=32'habcdef01;
		init();
		repeat(10)@(posedge clk);
		adr = 2|8'h80;
		cs=0;
		repeat(10)@(posedge clk);
		SPI_WRITER(8,adr,Dlitl,mosi,sclk);
		repeat(1)@(posedge clk);
        SPI_WRITER(32,data,Dlitl,mosi,sclk);
        repeat(10)@(posedge clk);
        cs=1;


        #5000;

        data=32'h23cdef01;
		init();
		repeat(10)@(posedge clk);
		adr = 1|8'h80;
		cs=0;
		repeat(10)@(posedge clk);
		SPI_WRITER(8,adr,Dlitl,mosi,sclk);
		repeat(1)@(posedge clk);
        SPI_WRITER(32,data,Dlitl,mosi,sclk);
        repeat(10)@(posedge clk);
        cs=1;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_Block_read_spi.fsdb");
			$fsdbDumpvars(0, "tb_Block_read_spi", "+mda", "+functions");
		end
	end

endmodule
