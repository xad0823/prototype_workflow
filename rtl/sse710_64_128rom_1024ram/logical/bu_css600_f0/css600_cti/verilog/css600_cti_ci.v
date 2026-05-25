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
//   Sub-module of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti_ci
#(
  parameter CHANNEL_WIDTH = 4
)(
  input  wire                      clk,
  input  wire                      reset_n,
  input  wire                      cti_en,
  input  wire [CHANNEL_WIDTH-1:0]  ch_out_enable,
  input  wire [CHANNEL_WIDTH-1:0]  ctichin,
  output wire [CHANNEL_WIDTH-1:0]  map_ch_in,
  output wire [CHANNEL_WIDTH-1:0]  ch_in_status,
  output wire [CHANNEL_WIDTH-1:0]  ctichout,
  input  wire [CHANNEL_WIDTH-1:0]  map_ch_out,
  output wire [CHANNEL_WIDTH-1:0]  ch_out_status,
  input  wire                      iten,
  input  wire [CHANNEL_WIDTH-1:0]  it_ch_out


);

  reg  [CHANNEL_WIDTH-1:0]   chout_q;
  wire                       chout_q_en;
  wire [CHANNEL_WIDTH-1:0]   chout_chouten;
  wire [CHANNEL_WIDTH-1:0]   chout_ctien;
  wire [CHANNEL_WIDTH-1:0]   chout_int;


  assign map_ch_in = {CHANNEL_WIDTH{cti_en}} & ch_out_enable & ctichin;

  assign ch_in_status = ctichin;


  assign chout_chouten = ch_out_enable & map_ch_out;

  assign chout_ctien = {CHANNEL_WIDTH{cti_en}} & chout_chouten;

  assign chout_int = (iten == 1'b1) ? it_ch_out : chout_ctien;

  assign chout_q_en = |(chout_q ^ chout_int);
  always @(posedge clk or negedge reset_n)
  begin : reg_chout
    if (!reset_n)
      chout_q <= {CHANNEL_WIDTH{1'b0}};
    else if (chout_q_en)
      chout_q <= chout_int;
  end

  assign ctichout = chout_q;

  assign ch_out_status = chout_q;


endmodule

