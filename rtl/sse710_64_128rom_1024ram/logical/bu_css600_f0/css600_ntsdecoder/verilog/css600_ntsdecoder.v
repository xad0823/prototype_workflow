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
//   Top level of css600_ntsdecoder
//
//----------------------------------------------------------------------------


module css600_ntsdecoder #(parameter
  FF_SYNC_DEPTH = 2
)
(
  clk,
  reset_n,
  tsbit_s,
  tssync_s,
  tssyncready_s,
  tsvalue_b_m,
  clk_qreq_n,
  clk_qaccept_n
);


  input wire        clk;
  input wire        reset_n;

  input wire [6:0]  tsbit_s;
  input wire [1:0]  tssync_s;
  output wire       tssyncready_s;

  output wire [63:0] tsvalue_b_m;

  input  wire clk_qreq_n;
  output wire clk_qaccept_n;

localparam SYNC_DEPTH_LOC = (FF_SYNC_DEPTH == 3) ? 3 : 2;


  wire lp_ack_w;
  wire lp_req_w;

  wire clk_qreq_n_sync;


  css600_ntsdecoder_core u_css600_ntsdecoder_core (

    .clk(clk),
    .reset_n(reset_n),
    .tsbit(tsbit_s),
    .tssync(tssync_s),
    .tssyncready(tssyncready_s),
    .tsvalue(tsvalue_b_m),
    .lp_req(lp_req_w),
    .lp_ack(lp_ack_w)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH_LOC)
  )
  u_clk_q_req_synch
  (
      .clk       (clk),
      .reset_n   (reset_n),
      .d_async_i (clk_qreq_n),
      .q_sync_o  (clk_qreq_n_sync)
  );

  css600_lpislave u_tsd_lpi_slave (

    .clk(clk),
    .reset_n(reset_n),
    .qreq_sync_n(clk_qreq_n_sync),
    .qaccept_n(clk_qaccept_n),
    .qdeny(),
    .lp_request(lp_req_w),
    .dev_active(1'b0),
    .lp_done(lp_ack_w),
    .dev_run(),
    .cg_en()

  );

endmodule
