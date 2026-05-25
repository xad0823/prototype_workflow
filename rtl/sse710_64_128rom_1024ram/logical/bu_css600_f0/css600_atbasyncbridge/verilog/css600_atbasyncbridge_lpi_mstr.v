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
//   Sub-module of css600_atbasyncbridge
//
//----------------------------------------------------------------------------


module css600_atbasyncbridge_lpi_mstr
(
  clk,
  reset_n,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,

  lp_request,
  lp_done,
  dev_active

  );


  input wire                       clk;
  input wire                       reset_n;

  input wire                       clk_qreq_n;

  input wire                       lp_done;

  output wire                      clk_qaccept_n;
  output wire                      clk_qdeny;

  output wire                      lp_request;
  input  wire                      dev_active;


  wire clk_qreq_n_sync;


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (2)
  )
  u_clk_q_req_synch
  (
    .clk       (clk),
    .reset_n   (reset_n),
    .d_async_i (clk_qreq_n),
    .q_sync_o  (clk_qreq_n_sync)
  );

    css600_lpislave u_css600_atbasyncbridge_clk_lpi_slv (

    .clk(clk),
    .reset_n(reset_n),
    .qreq_sync_n(clk_qreq_n_sync),
    .qaccept_n(clk_qaccept_n),
    .qdeny(clk_qdeny),
    .lp_request(lp_request),
    .dev_active(dev_active),
    .lp_done(lp_done),
    .dev_run(),
    .cg_en()

  );


endmodule
