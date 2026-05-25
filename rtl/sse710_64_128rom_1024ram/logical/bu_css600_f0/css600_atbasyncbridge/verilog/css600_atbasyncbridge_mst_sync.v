//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2017 Arm Limited or its affiliates.
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


module css600_atbasyncbridge_mst_sync #(parameter
  SYNC_DEPTH = 2
)
(
  clk_m,
  reset_m_n,
  wrptr_gray,
  flush_done,

  sync_clear,
  sync_clear_sync,
  clk_m_qreq_n,
  wrptr_gray_sync,
  flush_done_sync,
  clk_m_qreq_n_sync
  );


  input wire         clk_m;

  input wire         reset_m_n;
  input wire [3:0]   wrptr_gray;
  input wire         flush_done;
  input wire         sync_clear;
  input wire         clk_m_qreq_n;

  output wire [3:0]  wrptr_gray_sync;
  output wire        flush_done_sync;
  output wire        sync_clear_sync;
  output wire        clk_m_qreq_n_sync;


  wire [3:0]   wrptr_gray_corrupt;
  wire         flush_done_corrupt;
  wire         sync_clear_corrupt;
  assign wrptr_gray_corrupt = wrptr_gray;


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_wr_ptr_sync0 (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (wrptr_gray_corrupt[0]),
      .q_sync_o   (wrptr_gray_sync[0])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_wr_ptr_sync1 (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (wrptr_gray_corrupt[1]),
      .q_sync_o   (wrptr_gray_sync[1])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_wr_ptr_sync2 (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (wrptr_gray_corrupt[2]),
      .q_sync_o   (wrptr_gray_sync[2])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_wr_ptr_sync3 (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (wrptr_gray_corrupt[3]),
      .q_sync_o   (wrptr_gray_sync[3])
  );


  assign flush_done_corrupt = flush_done;


  css600_cdc_capt_sync_high #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_flush_done_sync (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (flush_done_corrupt),
      .q_sync_o   (flush_done_sync)
  );


  assign sync_clear_corrupt = sync_clear;


  css600_cdc_capt_sync_high #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_sync_clear (
      .clk       (clk_m),
      .reset_n    (reset_m_n),
      .d_async_i   (sync_clear_corrupt),
      .q_sync_o   (sync_clear_sync)
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_clk_q_req_sync
  (
    .clk       (clk_m),
    .reset_n   (reset_m_n),
    .d_async_i (clk_m_qreq_n),
    .q_sync_o  (clk_m_qreq_n_sync)
  );


endmodule

