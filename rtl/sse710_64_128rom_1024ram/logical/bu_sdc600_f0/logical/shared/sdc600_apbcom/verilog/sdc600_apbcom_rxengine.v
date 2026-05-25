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
//      Checked In          : Thu Jun 7 16:35:25 2018 +0200
//
//      Revision            : 605319a
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------


module sdc600_apbcom_rxengine (
   input  wire           reset_n,
   input  wire           clk,
   input  wire    [7:0]  rx_data,
   input  wire           rx_valid,
   output wire           rx_ready,
   output wire           rx_linkup,
   input  wire           rx_linkest,
   input  wire           rempur,
   input  wire           rempua_sync,
   input  wire           rd_str_dr,
   output wire   [7:0]   rdata_dr,
   output wire           rxfifo_full,
   input  wire           set_txlerr,
   input  wire           wr_str_lph1ra,
   input  wire           wr_str_lph1rl,
   input  wire           clk_dev_run,
   input  wire           pwr_dev_run,
   output reg            rx_linkest_reg
);


localparam FLAG_LPH1RA = 8'ha6;
localparam FLAG_LPH1RL = 8'ha7;
localparam FLAG_LPH2RA = 8'ha8;
localparam FLAG_LPH2RL = 8'ha9;
localparam FLAG_LERR   = 8'hab;
localparam FLAG_NULL   = 8'haf;
localparam ENCODED_LPH1RA = 3'b000;
localparam ENCODED_LPH1RL = 3'b001;
localparam ENCODED_LPH2RA = 3'b010;
localparam ENCODED_LPH2RL = 3'b011;
localparam ENCODED_LERR   = 3'b100;
localparam ENCODED_EMPTY  = 3'b111;


wire         fb_full;
wire         rd_str_data;
wire         load_data;
wire  [7:0]  rdata_flag;
wire         rempu_chg;
wire         load_lph1ra;
wire         load_lph1rl;
wire         load_lph2ra;
wire         load_lph2rl;
wire         set_fboe_consecutive;
wire         set_fboe_simultaneous;
wire         load_lerr;
wire         dev_run;

reg   [2:0]  fb_reg;
reg          db_full;
reg   [7:0]  db_reg;
reg          rx_ready_reg;
reg          rempur_reg;
reg          rempua_reg;
reg          rx_linkup_reg;

assign dev_run = pwr_dev_run & clk_dev_run;

assign rdata_flag = (fb_reg == ENCODED_LPH1RA) ? FLAG_LPH1RA :
                    (fb_reg == ENCODED_LPH1RL) ? FLAG_LPH1RL :
                    (fb_reg == ENCODED_LPH2RA) ? FLAG_LPH2RA :
                    (fb_reg == ENCODED_LPH2RL) ? FLAG_LPH2RL :
                    (fb_reg == ENCODED_LERR  ) ? FLAG_LERR   :
                                                 FLAG_NULL;

assign fb_full  = (fb_reg != ENCODED_EMPTY);
assign rdata_dr = fb_full ? rdata_flag : db_reg;
assign rxfifo_full = fb_full | db_full;

assign rd_str_data = ~fb_full & rd_str_dr;
assign load_data = ~db_full & rx_valid & dev_run;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    db_full <= 1'b0;
    db_reg  <= FLAG_NULL;
  end
  else if (load_data) begin
    db_full <= 1'b1;
    db_reg  <= rx_data;
  end
  else if (rd_str_data) begin
    db_full <= 1'b0;
    db_reg  <= FLAG_NULL;
  end
end


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    rx_ready_reg <= 1'b0;
  end
  else if (load_data) begin
    rx_ready_reg <= 1'b1;
  end
  else begin
    rx_ready_reg <= 1'b0;
  end
end

assign rx_ready = rx_ready_reg;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    rempur_reg <= 1'b0;
    rempua_reg <= 1'b0;
    rx_linkest_reg <= 1'b0;
  end
  else if (dev_run) begin
    rempur_reg <= rempur;
    rempua_reg <= rempua_sync;
    rx_linkest_reg <= rx_linkest;
  end
end


assign rempu_chg = (rempur ^ rempur_reg) | (rempua_sync ^ rempua_reg);
assign load_lph1ra = (rempu_chg | wr_str_lph1ra) & rempur & rempua_sync & dev_run;
assign load_lph1rl = (rempu_chg | wr_str_lph1rl) & ~rempur & ~rempua_sync & dev_run;
assign load_lph2ra = rx_linkest & ~rx_linkest_reg & dev_run;
assign load_lph2rl = ~rx_linkest & rx_linkest_reg & dev_run;

assign set_fboe_consecutive  = (load_lph1ra | load_lph1rl | load_lph2ra | load_lph2rl) & fb_full & ~rd_str_dr;
assign set_fboe_simultaneous = (load_lph1ra | load_lph1rl) & (load_lph2ra | load_lph2rl);
assign load_lerr = set_fboe_consecutive | set_fboe_simultaneous | set_txlerr;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    fb_reg <= ENCODED_EMPTY;
  end
  else if (load_lerr) begin
    fb_reg <= ENCODED_LERR;
  end
  else if (load_lph1ra) begin
    fb_reg <= ENCODED_LPH1RA;
  end
  else if (load_lph1rl) begin
    fb_reg <= ENCODED_LPH1RL;
  end
  else if (load_lph2ra) begin
    fb_reg <= ENCODED_LPH2RA;
  end
  else if (load_lph2rl) begin
    fb_reg <= ENCODED_LPH2RL;
  end
  else if (rd_str_dr) begin
    fb_reg <= ENCODED_EMPTY;
  end
end

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    rx_linkup_reg <= 1'b0;
  end
  else if (!pwr_dev_run) begin
    rx_linkup_reg <= 1'b0;
  end
  else begin
    rx_linkup_reg <= 1'b1;
  end
end


assign rx_linkup = rx_linkup_reg;


endmodule
