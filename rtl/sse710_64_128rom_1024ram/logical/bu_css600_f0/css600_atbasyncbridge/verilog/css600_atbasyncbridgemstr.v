//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2019 Arm Limited or its affiliates.
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


module css600_atbasyncbridgemstr #(parameter
  ATB_DATA_WIDTH=32,
  FF_SYNC_DEPTH=2
)
(
  clk_m,
  reset_m_n,
  atready_m,
  afvalid_m,

  atb_fwd_data,
  atvalid_m,
  atbytes_m,
  atid_m,
  atdata_m,
  afready_m,
  atwakeup_m,
  wr_pointer_gray,
  rd_pointer_gray,
  flush_done,
  flush_req,
  sync_clear,
  sync_done,
  syncreq_async_req,
  syncreq_async_ack,
  syncreq_m,

  clk_m_qreq_n,
  clk_m_qaccept_n,
  clk_m_qdeny,
  clk_m_qactive
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

  localparam FF_SYNC_DEPTH_LOC =  (
                                          (FF_SYNC_DEPTH == 2)  ||
                                          (FF_SYNC_DEPTH == 3)
                                         ) ? FF_SYNC_DEPTH : 2;


  localparam BUFFER_DEPTH =  (FF_SYNC_DEPTH_LOC == 2) ? 6 : 8;

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;

  localparam FIFO_DATA_WIDTH = ATB_DATA_WIDTH_LOC + 7 + ATBYTES_WIDTH;


  input wire                              clk_m;

  input wire                              reset_m_n;
  input wire                              atready_m;
  input wire                              afvalid_m;

  input wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1 : 0] atb_fwd_data;

  output wire                             atvalid_m;
  output wire [ATBYTES_WIDTH-1:0]         atbytes_m;

  output wire [6:0]                       atid_m;
  output wire [ATB_DATA_WIDTH_LOC-1:0]    atdata_m;
  output wire                             afready_m;
  output wire                             atwakeup_m;
  output wire [3:0]                       rd_pointer_gray;
  input  wire [3:0]                       wr_pointer_gray;
  output wire                             flush_req;
  input  wire                             flush_done;
  input  wire                             sync_clear;
  output wire                             sync_done;
  output wire                             syncreq_async_req;
  input wire                              syncreq_async_ack;
  input wire                              syncreq_m;

  input wire                              clk_m_qreq_n;
  output wire                             clk_m_qaccept_n;
  output wire                             clk_m_qdeny;
  output wire                             clk_m_qactive;


  wire [3:0] wrptr_gray_sync;
  wire       flush_done_sync;

  wire       lp_request;
  wire       lp_dny;
  wire       lp_done;

  wire       pulse_qactive;
  wire       sync_clear_sync;

  wire       clk_m_qreq_n_sync;
  wire       pulse_done;

  wire       pulse_lpi_req;

  wire       syncreq_m_gated;
  wire       syncreq_gate_w;

  assign atwakeup_m = atvalid_m;

  css600_atbasyncbridge_mst_async u_qactive_async (
  .rd_pointer_gray (rd_pointer_gray),
  .wr_pointer_gray (wr_pointer_gray),
  .afvalid_m       (afvalid_m),
  .pulse_qactive   (pulse_qactive),
  .atwakeup_m      (atwakeup_m),
  .sync_clear      (sync_clear),
  .sync_done       (sync_done),
  .clk_m_qactive   (clk_m_qactive)
  );

  css600_atbasyncbridge_mst_fifo #(
    .ATB_DATA_WIDTH (ATB_DATA_WIDTH_LOC),
    .ATBYTES_WIDTH  (ATBYTES_WIDTH),
    .BUFFER_DEPTH   (BUFFER_DEPTH)
  )
  u_css600_atbasyncbridge_mst_fifo
    (
    .atvalidm                          (atvalid_m),
    .atbytesm                          (atbytes_m),
    .atidm                             (atid_m),
    .atdatam                           (atdata_m),
    .afreadym                          (afready_m),
    .rd_ptr_gray                       (rd_pointer_gray),
    .flush_req                         (flush_req),

    .clk_m                             (clk_m),

    .reset_m_n                         (reset_m_n),

    .atreadym                          (atready_m),
    .afvalidm                          (afvalid_m),
    .fifo_data                         (atb_fwd_data),
    .wrptr_gray_sync                   (wrptr_gray_sync),

    .lp_request                        (lp_request),
    .lp_done                           (lp_done),
    .lp_dny                            (lp_dny),
    .sync_clear_sync                   (sync_clear_sync),
    .sync_done                         (sync_done),
    .pulse_done                        (pulse_done),
    .pulse_qactive                     (pulse_qactive),
    .syncreq_gate                      (syncreq_gate_w),

    .flush_done_sync                   (flush_done_sync));

  css600_atbasyncbridge_mst_sync#
  (
    .SYNC_DEPTH(FF_SYNC_DEPTH)
  )
  u_css600_atbasyncbridge_mst_sync
    (
    .wrptr_gray_sync   (wrptr_gray_sync),
    .flush_done_sync   (flush_done_sync),
    .clk_m_qreq_n_sync (clk_m_qreq_n_sync),
    .clk_m             (clk_m),
    .reset_m_n         (reset_m_n),
    .wrptr_gray        (wr_pointer_gray),
    .sync_clear        (sync_clear),
    .sync_clear_sync   (sync_clear_sync),
    .flush_done        (flush_done),
    .clk_m_qreq_n      (clk_m_qreq_n));


  assign pulse_lpi_req = ~sync_clear;
  assign syncreq_m_gated = syncreq_gate_w ? 1'b0 : syncreq_m;

  css600_pulseasyncbridgeslv #
  (
    .WIDTH(1),
    .WAKE_ON_PULSE(0),
    .FF_SYNC_DEPTH(FF_SYNC_DEPTH)
  )
  u_css600_pulseasyncbridgeslv
  (
    .clk_s(clk_m),
    .reset_s_n(reset_m_n),
    .pulse_in(syncreq_m_gated),
    .pulse_req(syncreq_async_req),
    .pulse_ack(syncreq_async_ack),
    .clk_s_qactive(),
    .pwr_qreq_n(pulse_lpi_req),
    .pwr_qaccept_n(pulse_done),
    .pwr_qactive(pulse_qactive)
  );

   css600_lpislave u_lpislave (
     .clk(clk_m),
     .reset_n(reset_m_n),
     .qreq_sync_n(clk_m_qreq_n_sync),
     .qaccept_n(clk_m_qaccept_n),
     .qdeny(clk_m_qdeny),
     .lp_request(lp_request),
     .dev_active(lp_dny),
     .lp_done(lp_done),
     .dev_run(),
     .cg_en()
  );

endmodule

