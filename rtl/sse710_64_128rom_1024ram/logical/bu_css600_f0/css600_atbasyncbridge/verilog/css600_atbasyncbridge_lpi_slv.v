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


module css600_atbasyncbridge_lpi_slv
(
  clk,
  reset_n,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,
  pwr_qreq_n,
  pwr_qaccept_n,
  pwr_qdeny,

  syncreq_async_req,
  atvalid_s,
  syncreq_m,
  flush_req,

  lp_dev_active,

  pwr_lp_request,
  pwr_lp_done,

  clk_lp_request,
  clk_lp_done
  );


  input wire                       clk;
  input wire                       reset_n;

  input wire                       clk_qreq_n;
  input wire                       pwr_qreq_n;

  output wire                      clk_qaccept_n;
  output wire                      clk_qdeny;

  output wire                      pwr_qaccept_n;
  output wire                      pwr_qdeny;

  output wire                      pwr_lp_request;
  input wire                       pwr_lp_done;

  output wire                      clk_lp_request;
  input wire                       clk_lp_done;

  input wire                       syncreq_async_req;
  input wire                       atvalid_s;
  input wire                       syncreq_m;
  input wire                       flush_req;

  input wire                       lp_dev_active;


  wire pwr_qreq_n_sync;

  wire clk_wake_up_xor_w;
  wire sync_w;
  wire fu_valid_w;
  wire wake_up_w;
  wire clk_wake_up_or_w;
  wire pwr_dev_run;
  wire clk_lp_request_w;

  wire clk_qreq_n_sync;
  wire clk_dev_active;


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

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (2)
  )
  u_pwr_q_req_synch
  (
      .clk       (clk),
      .reset_n   (reset_n),
      .d_async_i (pwr_qreq_n),
      .q_sync_o  (pwr_qreq_n_sync)
  );


  css600_xor u_clk_lpi_wake_up_xor (
    .in_a(pwr_dev_run),
    .in_b(pwr_qreq_n),
    .out_y(clk_wake_up_xor_w)
  );


  css600_or u_sync_async_in_or (
  .in_a(syncreq_async_req),
  .in_b(syncreq_m),
  .out_y(sync_w)
  );

  css600_or u_lp_req_in_or (
  .in_a(flush_req),
  .in_b(atvalid_s),
  .out_y(fu_valid_w)
  );

  css600_or u_fu_valid_sync_or (
  .in_a(sync_w),
  .in_b(fu_valid_w),
  .out_y(clk_wake_up_or_w)
  );

  css600_or u_wake_up_or (
  .in_a(clk_wake_up_xor_w),
  .in_b(clk_wake_up_or_w),
  .out_y(wake_up_w)
  );

  css600_or u_clk_dev_active_or (
  .in_a(lp_dev_active),
  .in_b(wake_up_w),
  .out_y(clk_dev_active)
  );

    css600_lpislave u_css600_atbasyncbridge_clk_lpi_slv (

    .clk(clk),
    .reset_n(reset_n),
    .qreq_sync_n(clk_qreq_n_sync),
    .qaccept_n(clk_qaccept_n),
    .qdeny(clk_qdeny),
    .lp_request(clk_lp_request),
    .dev_active(clk_dev_active),
    .lp_done(clk_lp_done),
    .dev_run(),
    .cg_en()

  );

  css600_lpislave u_css600_atbasyncbridge_pwr_lpi_slv (

    .clk(clk),
    .reset_n(reset_n),
    .qreq_sync_n(pwr_qreq_n_sync),
    .qaccept_n(pwr_qaccept_n),
    .qdeny(pwr_qdeny),
    .lp_request(pwr_lp_request),
    .dev_active(1'b0),
    .lp_done(pwr_lp_done),
    .dev_run(pwr_dev_run),
    .cg_en()

  );


endmodule
