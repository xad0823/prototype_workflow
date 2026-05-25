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
//   Sub-module of css600_atbsyncbridge
//
//----------------------------------------------------------------------------


module css600_atbsyncbridgeslv #(parameter
  ATB_DATA_WIDTH = 32,
  FF_SYNC_DEPTH = 2
)
(
  clk_s,

  reset_s_n,
  atwakeup_s,
  atvalid_s,
  atid_s,
  atbytes_s,
  atdata_s,
  afready_s,

  atready_s,
  afvalid_s,

  syncreq_s,
  syncreq_req,
  syncreq_ack,

  atb_fwd_data,
  flush_req,
  flush_done,
  wr_pointer,
  rd_pointer,
  sync_clear,
  sync_done,

  clk_s_qreq_n,
  clk_s_qaccept_n,
  clk_s_qdeny,
  clk_s_qactive,

  pwr_qreq_n,
  pwr_qaccept_n,
  pwr_qdeny,
  pwr_qactive
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATB_DATA_WIDTH_LOC =  (
                                          (ATB_DATA_WIDTH ==  8)  ||
                                          (ATB_DATA_WIDTH == 16)  ||
                                          (ATB_DATA_WIDTH == 32)  ||
                                          (ATB_DATA_WIDTH == 64)  ||
                                          (ATB_DATA_WIDTH == 128)
                                       ) ? ATB_DATA_WIDTH : 32;

  localparam FF_SYNC_DEPTH_LOC = (FF_SYNC_DEPTH == 3) ? 3 : 2;

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;
  localparam PAYLD_WIDTH   = (ATBYTES_WIDTH+ATB_DATA_WIDTH_LOC+7+1);

  localparam FIFO_PTR_WIDTH = 1;


  input  wire                       clk_s;

  input  wire                       reset_s_n;
  input  wire                       atwakeup_s;
  input  wire                       atvalid_s;
  input  wire  [6:0]                atid_s;
  input  wire  [ATBYTES_WIDTH-1:0]  atbytes_s;
  input  wire  [ATB_DATA_WIDTH_LOC-1:0] atdata_s;
  output wire                       atready_s;

  input  wire                       afready_s;
  output wire                       afvalid_s;

  output wire                       syncreq_s;
  input  wire                       syncreq_req;
  output wire                       syncreq_ack;
  output wire  [2*PAYLD_WIDTH-1:0]  atb_fwd_data;
  input  wire                       flush_req;
  output wire                       flush_done;
  output wire  [FIFO_PTR_WIDTH:0]   wr_pointer;
  input  wire  [FIFO_PTR_WIDTH:0]   rd_pointer;
  output wire                       sync_clear;
  input wire                        sync_done;

  input wire                        clk_s_qreq_n;
  output wire                       clk_s_qaccept_n;
  output wire                       clk_s_qdeny;
  output wire                       clk_s_qactive;

  input wire                        pwr_qreq_n;
  output wire                       pwr_qaccept_n;
  output wire                       pwr_qdeny;
  output wire                       pwr_qactive;


  wire clk_lp_req_w;
  wire clk_lp_done_w;

  wire pwr_lp_req_w;
  wire pwr_lp_done_w;

  wire dev_active;


  wire clk_s_qreq_n_sync;
  wire pwr_qreq_n_sync;


  assign pwr_qactive   = 1'b0;
  assign dev_active =  atvalid_s | flush_req | syncreq_req | (pwr_qreq_n_sync ^ pwr_qaccept_n);

  css600_lpislave u_clk_lpi_s (

    .clk         (clk_s),
    .reset_n     (reset_s_n),

    .qreq_sync_n (clk_s_qreq_n_sync),
    .qaccept_n   (clk_s_qaccept_n),
    .qdeny       (clk_s_qdeny),

    .lp_request  (clk_lp_req_w),
    .dev_active  (dev_active),
    .lp_done     (clk_lp_done_w),
    .dev_run     (),
    .cg_en       ()

  );

  css600_lpislave u_pwr_lpi_s (

    .clk           (clk_s),
    .reset_n       (reset_s_n),

    .qreq_sync_n   (pwr_qreq_n_sync),
    .qaccept_n     (pwr_qaccept_n),
    .qdeny         (pwr_qdeny),

    .lp_request    (pwr_lp_req_w),
    .dev_active    (1'b0),
    .lp_done       (pwr_lp_done_w),
    .dev_run       (),
    .cg_en         ()

  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH_LOC)
  ) u_clk_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (clk_s_qreq_n),
    .q_sync_o  (clk_s_qreq_n_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH_LOC)
  ) u_pwr_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (pwr_qreq_n),
    .q_sync_o  (pwr_qreq_n_sync)
  );

  css600_atbsyncbridge_slv_async u_qactive_async (
    .atwakeup_s    (atwakeup_s),
    .pwr_qreq_n    (pwr_qreq_n),
    .pwr_qaccept_n (pwr_qaccept_n),
    .flush_req     (flush_req),
    .syncreq_req   (syncreq_req),
    .clk_s_qactive (clk_s_qactive)
  );

  css600_atbsyncbridgeslv_core # (
    .ATB_DATA_WIDTH(ATB_DATA_WIDTH_LOC)
  ) u_css600_atbsyncbridgeslv_core
  (
    .clk            (clk_s),
    .reset_n        (reset_s_n),

    .atvalid_s      (atvalid_s),
    .atid_s         (atid_s),
    .atbytes_s      (atbytes_s),
    .atdata_s       (atdata_s),
    .afready_s      (afready_s),

    .atready_s      (atready_s),
    .afvalid_s      (afvalid_s),

    .atb_fwd_data   (atb_fwd_data),
    .flush_req      (flush_req),
    .flush_done     (flush_done),
    .wr_pointer     (wr_pointer),
    .rd_pointer     (rd_pointer),
    .sync_clear     (sync_clear),
    .sync_done      (sync_done),

    .pwr_lp_request (pwr_lp_req_w),
    .pwr_lp_done    (pwr_lp_done_w),
    .clk_lp_request (clk_lp_req_w),
    .clk_lp_done    (clk_lp_done_w),
    .clk_qreq       (clk_s_qreq_n_sync),
    .clk_qaccept    (clk_s_qaccept_n),
    .dev_active     (dev_active)
);

  css600_pulsesyncbridgemstr #(
    .WIDTH(1)
  ) u_css600_pulsesyncbridgemstr
  (
    .clk_m     (clk_s),
    .reset_m_n (reset_s_n),
    .pulse_out (syncreq_s),
    .pulse_req (syncreq_req),
    .pulse_ack (syncreq_ack)
  );


endmodule
