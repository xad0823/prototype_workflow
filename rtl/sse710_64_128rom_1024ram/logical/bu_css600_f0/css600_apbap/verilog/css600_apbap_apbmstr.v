//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2003-2004, 2012, 2016 Arm Limited or its affiliates.
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
//   Sub-module of css600_apbap
//
//----------------------------------------------------------------------------


module css600_apbap_apbmstr
(
  input  wire         clk,
  input  wire         reset_n,

  input  wire         mstr_tr_req,
  input  wire         mstr_rd_wr,
  input  wire  [31:0] mstr_wr_data,
  output wire         mstr_tr_done,

  output reg          psel_m,
  output reg          penable_m,
  output reg          pwrite_m,
  output reg   [31:0] pwdata_m,
  input  wire         pready_m
);

`include "css600_apbap_localparams.v"

  wire          apbm_ctl_en;
  wire          next_psel;
  wire          next_penable;

  reg [1:0]     state;
  reg [1:0]     next_state;


  always @*
  begin : p_next_state
    case (state)
      ST_APBMSTR_IDLE   : next_state = mstr_tr_req ? ST_APBMSTR_SETUP :
                                                       ST_APBMSTR_IDLE;
      ST_APBMSTR_SETUP  : next_state = ST_APBMSTR_ACCESS;
      ST_APBMSTR_ACCESS : next_state = pready_m ? ST_APBMSTR_IDLE :
                                                    ST_APBMSTR_ACCESS;
      default           : next_state = ST_APBMSTR_UNDEF;
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : p_state
    if (!reset_n)
      state <= ST_APBMSTR_IDLE;
    else
      state <= next_state;
  end

  assign apbm_ctl_en = (next_state == ST_APBMSTR_SETUP);

  assign next_psel = (next_state == ST_APBMSTR_SETUP) |
                     (next_state == ST_APBMSTR_ACCESS);

  assign next_penable = (next_state == ST_APBMSTR_ACCESS);

  assign mstr_tr_done = pready_m & (state == ST_APBMSTR_ACCESS);

  always @(posedge clk or negedge reset_n)
  begin : p_psel_m
    if (!reset_n)
      psel_m <= 1'b0;
    else
      psel_m <= next_psel;
  end

  always @(posedge clk or negedge reset_n)
  begin : p_penable_m
    if (!reset_n)
      penable_m <= 1'b0;
    else
      penable_m <= next_penable;
  end

  always @(posedge clk or negedge reset_n)
  begin : p_pwrite_m
    if (!reset_n)
      pwrite_m <= 1'b0;
    else
      if (apbm_ctl_en)
        pwrite_m <= mstr_rd_wr;
  end

  always @(posedge clk or negedge reset_n)
  begin : p_pwdata_m
    if (!reset_n)
      pwdata_m <= {32{1'b0}};
    else
      if(apbm_ctl_en)
        pwdata_m <= mstr_wr_data;
  end


endmodule

