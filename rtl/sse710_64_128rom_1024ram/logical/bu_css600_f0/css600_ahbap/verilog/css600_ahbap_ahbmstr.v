//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_ahbap
//
//----------------------------------------------------------------------------


module css600_ahbap_ahbmstr
(
  input  wire         clk,
  input  wire         reset_n,

  input  wire         mstr_tr_req,
  input  wire         mstr_rd_wr,
  input  wire  [31:0] mstr_wr_data,
  output wire         mstr_tr_in_prog,
  output wire         mstr_tr_done,
  output wire   [1:0] mstr_state,

  output wire         htrans,
  output reg          hwrite_m,
  output reg   [31:0] hwdata_m,
  input  wire         hready_m
);

`include "css600_ahbap_localparams.v"


  wire          state_en;
  wire          ha_en;
  wire          hd_en;

  reg [1:0]     state;
  reg [1:0]     next_state;


  always @*
  begin : p_next_state
    case (state)
      ST_AHBMSTR_IDLE     : next_state = mstr_tr_req ? ST_AHBMSTR_AD_PHASE :
                                                       ST_AHBMSTR_IDLE;
      ST_AHBMSTR_AD_PHASE : next_state = hready_m ? ST_AHBMSTR_DT_PHASE :
                                                    ST_AHBMSTR_AD_PHASE;
      ST_AHBMSTR_DT_PHASE : next_state = hready_m ? ST_AHBMSTR_IDLE :
                                                    ST_AHBMSTR_DT_PHASE;
      default             : next_state = ST_AHBMSTR_UNDEF;
    endcase
  end


  assign state_en = (state != next_state);

  always @(posedge clk or negedge reset_n)
  begin : p_state
    if (!reset_n)
      state <= ST_AHBMSTR_IDLE;
    else if (state_en)
      state <= next_state;
  end

  assign mstr_state = state;

  assign htrans = (state == ST_AHBMSTR_AD_PHASE);

  assign mstr_tr_in_prog = (state != ST_AHBMSTR_IDLE);

  assign mstr_tr_done = (state == ST_AHBMSTR_DT_PHASE) & hready_m;

  assign ha_en = (state == ST_AHBMSTR_IDLE) & mstr_tr_req;

  always @ (posedge clk or negedge reset_n)
  begin : p_add_ph
    if (!reset_n)
      hwrite_m <= 1'b0;
    else if (ha_en)
      hwrite_m <= mstr_rd_wr;
  end

  assign hd_en = (state == ST_AHBMSTR_AD_PHASE) & mstr_rd_wr & hready_m;

  always @ (posedge clk)
  begin : p_data_ph
    if (hd_en)
      hwdata_m <= mstr_wr_data;
  end


endmodule

