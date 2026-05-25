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


module css600_ntsasyncbridgemstr_lpi #(parameter
  FF_SYNC_DEPTH = 2
)
(

  input wire clkm,
  input wire resetmn,

  input wire clk_m_qreq_n,
  output wire clk_m_qaccept_n,

  input wire s_lp_async,
  output reg s_lp,

  output wire clk_lp_req,
  input  wire clk_lp_done,

  output reg m_lp,
  input wire master_stopped,

  output wire m_lp_request
  );

  wire s_lp_sync;

  wire clk_m_qreq_n_sync;

  wire nxt_m_lp;


  css600_lpislave u_clk_lpi_m (

  .clk(clkm),
  .reset_n(resetmn),

  .qreq_sync_n(clk_m_qreq_n_sync),
  .qaccept_n(clk_m_qaccept_n),
  .qdeny(),

  .lp_request(clk_lp_req),
  .dev_active(1'b0),
  .lp_done(clk_lp_done),
  .dev_run(),
  .cg_en()

  );

  css600_cdc_capt_sync_high #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_s_lp_m
  (
      .clk       (clkm),
      .reset_n   (resetmn),
      .d_async_i (s_lp_async),
      .q_sync_o  (s_lp_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_q_req_synch
  (
      .clk       (clkm),
      .reset_n   (resetmn),
      .d_async_i (clk_m_qreq_n),
      .q_sync_o  (clk_m_qreq_n_sync)
  );

  assign m_lp_request = s_lp_sync;


  assign nxt_m_lp = clk_lp_req | master_stopped;

  always @ (posedge clkm or negedge resetmn)
  begin
    if (!resetmn)
      m_lp <= 1'b0;
    else if (m_lp_request)
      m_lp <= 1'b0;
    else
      m_lp <= nxt_m_lp;
  end

  always @ (posedge clkm or negedge resetmn)
  begin
    if (!resetmn)
      s_lp <= 1'b1;
    else
      s_lp <= s_lp_sync;
  end

endmodule
