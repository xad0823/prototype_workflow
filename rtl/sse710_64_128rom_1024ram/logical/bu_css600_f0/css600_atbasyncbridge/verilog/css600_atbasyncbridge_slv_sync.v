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


module css600_atbasyncbridge_slv_sync #(parameter
  SYNC_DEPTH = 3
)
(
  clk_s,
  reset_s_n,
  rdptr_gray,
  flush_req,
  clk_s_qreq_n,
  pwr_qreq_n,
  sync_done,
  rdptr_gray_sync,
  flush_req_sync,
  clk_s_qreq_n_sync,
  pwr_qreq_n_sync,
  sync_done_sync
);

  input wire         clk_s;

  input wire         reset_s_n;
  input wire [3:0]   rdptr_gray;
  input wire         flush_req;
  input wire         clk_s_qreq_n;
  input wire         pwr_qreq_n;
  input wire         sync_done;

  output wire [3:0]  rdptr_gray_sync;
  output wire        flush_req_sync;
  output wire        clk_s_qreq_n_sync;
  output wire        pwr_qreq_n_sync;
  output wire        sync_done_sync;


  wire [3:0]   rdptr_gray_corrupt;
  wire         flush_req_corrupt;
  wire         sync_done_corrupt;


  assign rdptr_gray_corrupt = rdptr_gray;


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_rd_ptr_sync_0 (
      .clk       (clk_s),
      .reset_n   (reset_s_n),
      .d_async_i (rdptr_gray_corrupt[0]),
      .q_sync_o  (rdptr_gray_sync[0])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_rd_ptr_sync_1 (
      .clk       (clk_s),
      .reset_n   (reset_s_n),
      .d_async_i (rdptr_gray_corrupt[1]),
      .q_sync_o  (rdptr_gray_sync[1])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_rd_ptr_sync_2 (
      .clk       (clk_s),
      .reset_n   (reset_s_n),
      .d_async_i (rdptr_gray_corrupt[2]),
      .q_sync_o  (rdptr_gray_sync[2])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_rd_ptr_sync_3 (
      .clk       (clk_s),
      .reset_n   (reset_s_n),
      .d_async_i (rdptr_gray_corrupt[3]),
      .q_sync_o  (rdptr_gray_sync[3])
  );


  assign flush_req_corrupt = flush_req;


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_cdc_flush_req (
      .clk       (clk_s),
      .reset_n    (reset_s_n),
      .d_async_i   (flush_req_corrupt),
      .q_sync_o   (flush_req_sync)
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  ) u_clk_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (clk_s_qreq_n),
    .q_sync_o  (clk_s_qreq_n_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  ) u_pwr_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (pwr_qreq_n),
    .q_sync_o  (pwr_qreq_n_sync)
  );


  assign sync_done_corrupt = sync_done;


  css600_cdc_capt_sync_high #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
    ) u_sync_done
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (sync_done_corrupt),
    .q_sync_o  (sync_done_sync)
  );

endmodule
