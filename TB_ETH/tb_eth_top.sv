
`timescale 1ns/1ps

module tb_eth_1g_top (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(4.0) clk = ~clk;
	end

	logic clk_12;
	initial begin
		clk_12 = '0;
		forever #(41.6666666666667) clk_12 = ~clk_12;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	parameter     adr_spi_rd_stat_mem1 = 18;
	parameter     adr_spi_rd_data_mem1 = 17;
	parameter adr_spi_wr_data_adr_mem1 = 16;
	parameter adr_spi_wr_data_UDP_MAC0 = 15;
	parameter      adr_spi_wr_adr_MAC0 = 13;
	parameter     adr_spi_wr_data_MAC0 = 12;
	parameter     adr_spi_rd_data_MAC0 = 14;
	parameter             adr_spi_eth1 = 9;
	parameter         adr_spi_i2c_upr1 = 10;
	parameter          adr_spi_i2c_rd1 = 11;
	parameter      adr_spi_wr_adr_mem2 = 34;
	parameter     adr_spi_rd_data_mem2 = 37;
	parameter      adr_spi_wr_adr_MEM3 = 38;
	parameter     adr_spi_wr_data_MEM3 = 39;
	parameter      adr_spi_wr_crc_MEM3 = 44;
	parameter            adr_spi_wr_IP = 21;
	parameter      adr_spi_wr_ETH_PORT = 21;
	parameter           adr_spi_wr_MAC = 21;

	logic [31:0] data_1ch;
	logic [31:0] data_2ch;
	logic        wr_data_1ch;
	logic        wr_data_2ch;
	logic        wrclk;
	logic        clk_125_eth;
	logic        reset_all;
	logic        xCS_FPGA1;
	logic        xSPI3_SCK;
	logic        xSPI3_MOSI;
	logic        xSPI3_MISO;
	logic        RX_GTP;
	logic        TX_GTP;
	logic        SDATA1_I2C;
	logic        SCLK1_I2C;
	logic        SFP1_TX_FAULT;
	logic        SFP1_PRESENT;
	logic        SFP1_LOS;
	logic        RATE1_SELECTION;
	logic        SFP1_TX_DISABLE;
	logic        INT_MK;

	eth_1g_top #(
			.adr_spi_rd_stat_mem1(adr_spi_rd_stat_mem1),
			.adr_spi_rd_data_mem1(adr_spi_rd_data_mem1),
			.adr_spi_wr_data_adr_mem1(adr_spi_wr_data_adr_mem1),
			.adr_spi_wr_data_UDP_MAC0(adr_spi_wr_data_UDP_MAC0),
			.adr_spi_wr_adr_MAC0(adr_spi_wr_adr_MAC0),
			.adr_spi_wr_data_MAC0(adr_spi_wr_data_MAC0),
			.adr_spi_rd_data_MAC0(adr_spi_rd_data_MAC0),
			.adr_spi_eth1(adr_spi_eth1),
			.adr_spi_i2c_upr1(adr_spi_i2c_upr1),
			.adr_spi_i2c_rd1(adr_spi_i2c_rd1),
			.adr_spi_wr_adr_mem2(adr_spi_wr_adr_mem2),
			.adr_spi_rd_data_mem2(adr_spi_rd_data_mem2),
			.adr_spi_wr_adr_MEM3(adr_spi_wr_adr_MEM3),
			.adr_spi_wr_data_MEM3(adr_spi_wr_data_MEM3),
			.adr_spi_wr_crc_MEM3(adr_spi_wr_crc_MEM3),
			.adr_spi_wr_IP(adr_spi_wr_IP),
			.adr_spi_wr_ETH_PORT(adr_spi_wr_ETH_PORT),
			.adr_spi_wr_MAC(adr_spi_wr_MAC)
		) inst_eth_1g_top (
			.data_1ch        (data_1ch),
			.data_2ch        (data_2ch),
			.wr_data_1ch     (wr_data_1ch),
			.wr_data_2ch     (wr_data_2ch),
			.wrclk           (wrclk),
			.clk_12          (clk_12),
			.clk_125         (clk),
			.clk_125_eth     (clk_125_eth),
			.reset_all       (reset_all),
			.xCS_FPGA1       (xCS_FPGA1),
			.xSPI3_SCK       (xSPI3_SCK),
			.xSPI3_MOSI      (xSPI3_MOSI),
			.xSPI3_MISO      (xSPI3_MISO),
			.RX_GTP          (RX_GTP),
			.TX_GTP          (TX_GTP),
			.SDATA1_I2C      (SDATA1_I2C),
			.SCLK1_I2C       (SCLK1_I2C),
			.SFP1_TX_FAULT   (SFP1_TX_FAULT),
			.SFP1_PRESENT    (SFP1_PRESENT),
			.SFP1_LOS        (SFP1_LOS),
			.RATE1_SELECTION (RATE1_SELECTION),
			.SFP1_TX_DISABLE (SFP1_TX_DISABLE),
			.INT_MK          (INT_MK)
		);

	task init();
		data_1ch      <= '0;
		data_2ch      <= '0;
		wr_data_1ch   <= '0;
		wr_data_2ch   <= '0;
		wrclk         <= '0;
		clk_12        <= '0;
		clk_125_eth   <= '0;
		reset_all     <= '0;
		xCS_FPGA1     <= '0;
		xSPI3_SCK     <= '0;
		xSPI3_MOSI    <= '0;
		RX_GTP        <= '0;
		SFP1_TX_FAULT <= '0;
		SFP1_PRESENT  <= '0;
		SFP1_LOS      <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			data_1ch      <= '0;
			data_2ch      <= '0;
			wr_data_1ch   <= '0;
			wr_data_2ch   <= '0;
			wrclk         <= '0;
			clk_12        <= '0;
			clk_125_eth   <= '0;
			reset_all     <= '0;
			xCS_FPGA1     <= '0;
			xSPI3_SCK     <= '0;
			xSPI3_MOSI    <= '0;
			RX_GTP        <= '0;
			SFP1_TX_FAULT <= '0;
			SFP1_PRESENT  <= '0;
			SFP1_LOS      <= '0;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(20);

		repeat(10)@(posedge clk);
		$finish;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_eth_1g_top.fsdb");
			$fsdbDumpvars(0, "tb_eth_1g_top", "+mda", "+functions");
		end
	end

endmodule
