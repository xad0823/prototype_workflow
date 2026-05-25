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
//   Sub-module of css600_ntsasyncbridge
//
//----------------------------------------------------------------------------


module css600_ntsasyncbridgeslv_lpi  #(parameter
  FF_SYNC_DEPTH = 2
)
(

  input  wire clks,
  input  wire resetsn,

  input  wire  clk_s_qreq_n,
  output wire clk_s_qaccept_n,

  output wire clk_lp_req,
  input  wire clk_lp_done,

  input  wire  pwr_qreq_n,
  output wire pwr_qaccept_n,

  input  wire  m_lp_async,

  input  wire s_lp_async,
  output reg  s_lp,

  output wire s_lp_request,
  output wire set_tssyncready
  );

  wire s_lp_sync;
  wire pwr_lp_req_w;

  wire clk_s_qreq_n_sync;
  wire pwr_qreq_n_sync;

  wire pwr_lp_done_w;
  wire       lp_en;


  css600_lpislave u_clk_lpi_s (

  .clk(clks),
  .reset_n(resetsn),

  .qreq_sync_n(clk_s_qreq_n_sync),
  .qaccept_n(clk_s_qaccept_n),
  .qdeny(),

  .lp_request(clk_lp_req),
  .dev_active(1'b0),
  .lp_done(clk_lp_done),
  .dev_run(),
  .cg_en()

  );

  css600_lpislave u_pwr_lpi_s (

  .clk(clks),
  .reset_n(resetsn),

  .qreq_sync_n(pwr_qreq_n_sync),
  .qaccept_n(pwr_qaccept_n),
  .qdeny(),

  .lp_request(pwr_lp_req_w),
  .dev_active(1'b0),
  .lp_done(pwr_lp_done_w),
  .dev_run(),
  .cg_en()

  );

  assign pwr_lp_done_w = ~set_tssyncready & s_lp_sync;

  assign s_lp_request = s_lp_sync;

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_clk_q_req_synch
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (clk_s_qreq_n),
      .q_sync_o  (clk_s_qreq_n_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_pwr_q_req_synch
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (pwr_qreq_n),
      .q_sync_o  (pwr_qreq_n_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_m_lp
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (m_lp_async),
      .q_sync_o  (set_tssyncready)
  );

  css600_cdc_capt_sync_high #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_s_lp
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (s_lp_async),
      .q_sync_o  (s_lp_sync)
  );

  assign lp_en = pwr_lp_req_w | s_lp_sync;

  always @ (posedge clks or negedge resetsn)
  begin
    if (!resetsn)
      s_lp <= 1'b1;
    else if (lp_en)
      s_lp <= pwr_lp_req_w;
  end

endmodule
