module divideModule #(parameter DIV_WIDTH=4) (
	input SE
,	input resetn
,	input clk_in
,	input [DIV_WIDTH-1:0] divisor
,	output out_clk
);
//`ifdef _EZ_SIM_MODEL_
reg fout;
reg clk_out_p;
reg clk_out_n;
reg resetn_d0;
reg [DIV_WIDTH-1:0] counter;
reg [DIV_WIDTH-1:0] cnt_p;
reg [DIV_WIDTH-1:0] cnt_n;
always@(posedge clk_in) begin
		resetn_d0 <= resetn;
end


reg resetn_d1;
reg resetn_d2;
always@(posedge clk_in or negedge resetn) begin
	if(!resetn) begin
		resetn_d1 <= 1'b0;
	end
	else begin
		resetn_d1 <= resetn_d0;
	end
end

always@(posedge clk_in or negedge resetn) begin
	if(!resetn) begin
		resetn_d2 <= 1'b0;
	end
	else begin
		resetn_d2 <= resetn_d1 & divisor[0];
	end
end

always@(posedge clk_in) begin
		cnt_p <= (divisor[DIV_WIDTH-1:1] - 1);
		cnt_n <= divisor[0] ? {1'b0,divisor[DIV_WIDTH-1:1]} : cnt_p;
end

wire resetn_d1_dft;
assign resetn_d1_dft = (SE) ? resetn : resetn_d1;
always@(posedge clk_in or negedge resetn_d1_dft) begin
	if(~resetn_d1_dft) begin
		fout <= 1'b0;
		counter <= 1'b0;
		clk_out_p <= 1'b0;
	end
	else begin
		clk_out_p <= fout;
		if((fout == 1'b0 && counter >= cnt_n) || (fout == 1'b1 && counter >= cnt_p)) begin
			fout <= ~fout;
			counter <= 1'b0;
		end else begin
			counter <= counter+1;
		end
	end
end

wire resetn_d2_dft;
assign resetn_d2_dft = (SE) ? resetn : resetn_d2;
always@(negedge clk_in or negedge resetn_d2_dft) begin
	if(~resetn_d2_dft) begin
		clk_out_n <= 1'b0;
	end
	else begin
		clk_out_n <= clk_out_p;
	end
end

wire out_clk_div;
wire div01_bypass = divisor == 1 || divisor === 0;
wire sel_buf;
ez_cknand U_EZ_CKNAND (
	.I1(~clk_out_n),
	.I2(~clk_out_p),
	.O(out_clk_div)
);
ez_ckbuf U_EZ_CKBUF (
	.O(sel_buf),
	.I(div01_bypass)
);
ez_ck2mux1 U_EZ_CK2MUX1 (
	.resetn(resetn_d1_dft),
	.clk0(out_clk_div),
	.clk1(clk_in),
	.sel(sel_buf),
	.out_clk(out_clk)
);
//`else
//`endif //_EZ_SIM_MODEL_
endmodule
