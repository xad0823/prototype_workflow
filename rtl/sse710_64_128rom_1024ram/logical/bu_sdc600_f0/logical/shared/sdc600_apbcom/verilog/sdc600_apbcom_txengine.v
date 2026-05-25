//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Apr 27 14:09:24 2018 +0100
//
//      Revision            : a862b02
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------


module sdc600_apbcom_txengine #(
  parameter APBCOM_VAR  = 0
  )
  (
   input  wire           reset_n,
   input  wire           clk,
   output reg    [7:0]   tx_data,
   output reg            tx_valid,
   input  wire           tx_ready,
   input  wire           tx_linkup,
   output reg            tx_linkest,
   output reg            rempur,
   output wire           remrr,
   input  wire           remra_sync,
   input  wire           rrdis,
   input  wire           wr_str_dr,
   input  wire           wr_str_dbr,
   input  wire   [7:0]   wdata,
   output wire           txfifo_empty,
   output wire           set_txoe,
   output wire           delay_pready,
   output wire           set_txlerr,
   output wire           wr_str_lph1ra,
   output wire           wr_str_lph1rl,
   input  wire           pwr_dev_run
);

`include "sdc600_apbcom_variants.v"

localparam FLAG_LPH1RA = 8'ha6;
localparam FLAG_LPH1RL = 8'ha7;
localparam FLAG_LPH2RA = 8'ha8;
localparam FLAG_LPH2RL = 8'ha9;
localparam FLAG_LPH2RR = 8'haa;
localparam FLAG_NULL   = 8'haf;

wire         txfifo_access;
wire         wr_str_lph2ra;
wire         wr_str_lph2rl;
wire         wr_str_lph2rr;
wire         unsaved_flag;
wire         wr_str_txdata;
reg          tx_linkup_reg;

assign txfifo_access = (wr_str_dr & (txfifo_empty | tx_ready)) | (wr_str_dbr & txfifo_empty);
assign wr_str_lph1ra = txfifo_access & (wdata == FLAG_LPH1RA);
assign wr_str_lph1rl = txfifo_access & (wdata == FLAG_LPH1RL);
assign wr_str_lph2rr = txfifo_access & (wdata == FLAG_LPH2RR);
assign wr_str_lph2ra = txfifo_access & (wdata == FLAG_LPH2RA);
assign wr_str_lph2rl = txfifo_access & (wdata == FLAG_LPH2RL);
assign unsaved_flag = (wdata == FLAG_LPH1RA) | (wdata == FLAG_LPH1RL) | (wdata == FLAG_LPH2RR) |
                      (wdata == FLAG_LPH2RA) | (wdata == FLAG_LPH2RL) | (wdata == FLAG_NULL);
assign wr_str_txdata = txfifo_access & ~unsaved_flag & tx_linkup;

assign set_txoe = wr_str_dr & ~txfifo_empty & ~tx_ready & (wdata != FLAG_NULL);
assign set_txlerr = (txfifo_access & ~unsaved_flag & ~tx_linkup) | (tx_valid & tx_linkup_reg & ~tx_linkup);

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    tx_valid <= 1'b0;
  end
  else if (!tx_linkup) begin
    tx_valid <= 1'b0;
  end
  else if (wr_str_txdata) begin
    tx_valid <= 1'b1;
  end
  else if (tx_ready) begin
    tx_valid <= 1'b0;
  end
end

assign txfifo_empty = ~tx_valid;

assign delay_pready = tx_valid & ~tx_ready;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    tx_data <= 8'h0;
  end
  else if (!pwr_dev_run) begin
    tx_data <= 8'h0;
  end
  else if (wr_str_txdata) begin
    tx_data <= wdata;
  end
end

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    tx_linkest <= 1'b0;
  end
  else if (wr_str_lph2ra) begin
    tx_linkest <= 1'b1;
  end
  else if (wr_str_lph2rl) begin
    tx_linkest <= 1'b0;
  end
end

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    rempur <= 1'b0;
  end
  else if (wr_str_lph1ra) begin
    rempur <= 1'b1;
  end
  else if (wr_str_lph1rl) begin
    rempur <= 1'b0;
  end
end

generate
if (APBCOM_VAR == APBCOM_INT) begin  : GENREMRR_INT
  assign remrr = 1'b0;
end
else begin : GENREMRR_NON_INT
  reg remrr_reg;
  assign remrr = remrr_reg;
  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      remrr_reg <= 1'b0;
    end
    else if (remra_sync && remrr) begin
      remrr_reg <= 1'b0;
    end
    else if (wr_str_lph2rr && !rrdis) begin
      remrr_reg <= 1'b1;
    end
  end
end
endgenerate

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    tx_linkup_reg <= 1'b0;
  end
  else begin
    tx_linkup_reg <= tx_linkup;
  end
end


endmodule
