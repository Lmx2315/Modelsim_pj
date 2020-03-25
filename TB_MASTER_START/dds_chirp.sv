module dds_chirp (
	input clk,    // Clock
	input [47:0] DDS_freq,
	input [47:0] DDS_delta_freq,
	input [31:0] DDS_delta_rate,
	input start,
	output[15:0] data_I,
	output[15:0] data_Q,
	output       valid	
);

logic [47:0] phi_dds_reg=0;
logic [47:0] accum_dds  =0;
logic [31:0] temp_t1    =0;
logic [ 2:0] frt_start  =0;
logic reg_rst_n =0;
logic reg_clk_en=0;

always_ff @(posedge clk) frt_start<={frt_start[1:0],start};//ищум фронт сигнала start

always_ff @(posedge clk) 
begin 
	if (frt_start==3'b001) //пришёл фронт сигнала start для DDS
	begin
		accum_dds	 <=DDS_freq;
		temp_t1		 <=0;
		reg_rst_n	 <=1'b0;
		reg_clk_en	 <=1'b1;
	end else
	if (start)
	begin
		reg_rst_n    <=1'b1;
		phi_dds_reg  <=accum_dds;

		if (temp_t1==DDS_delta_rate)
			begin
			accum_dds   	<=accum_dds+DDS_delta_freq;	
			temp_t1			<=0;
			end else temp_t1<=temp_t1+1'b1;
	end else
	if (!start)
	begin
		accum_dds    <=48'd0;
		reg_rst_n    <= 1'b0;
		phi_dds_reg  <=48'd0;
		reg_clk_en	 <= 1'b0;
	end
end

DDS_48_v1 dds_0 (
		.clk         (clk),     		// clk.clk
		.reset_n     (reg_rst_n),  		// rst.reset_n
		.clken       (reg_clk_en),     	//  in.clken
		.phi_inc_i   (phi_dds_reg),   	//    .phi_inc_i  48'd43980465111040
		.freq_mod_i  (0),  				//    .freq_mod_i
		.phase_mod_i (0), 				//    .phase_mod_i
		.fsin_o      (data_I),     		// out.fsin_o
		.fcos_o      (data_Q),     		//    .fcos_o
		.out_valid   (valid)  			//    .out_valid
	);

endmodule