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


module css600_atbasyncbridgeslv #(parameter
  ATB_DATA_WIDTH = 32,
  FF_SYNC_DEPTH  = 2
)
(
  clk_s,
  reset_s_n,
  atvalid_s,
  atid_s,
  atbytes_s,
  atdata_s,
  afready_s,
  atwakeup_s,
  atb_fwd_data,
  flush_done,
  flush_req,
  sync_clear,
  sync_done,
  syncreq_async_req,
  syncreq_async_ack,
  wr_pointer_gray,
  rd_pointer_gray,

  syncreq_s,
  atready_s,
  afvalid_s,

  clk_s_qreq_n,
  clk_s_qaccept_n,
  clk_s_qactive,
  clk_s_qdeny,

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

  localparam FF_SYNC_DEPTH_LOC =  (
                                     (FF_SYNC_DEPTH == 2)  ||
                                     (FF_SYNC_DEPTH == 3)
                                  ) ? FF_SYNC_DEPTH : 2;


  localparam BUFFER_DEPTH =  (FF_SYNC_DEPTH_LOC == 2) ? 6 : 8;

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;

  localparam FIFO_DATA_WIDTH = ATB_DATA_WIDTH_LOC + 7 + ATBYTES_WIDTH;

  input wire                               clk_s;
  input wire                               reset_s_n;
  input wire                               atvalid_s;
  input wire [6:0]                         atid_s;
  input wire [ATBYTES_WIDTH-1:0]           atbytes_s;
  input wire [ATB_DATA_WIDTH_LOC-1:0]      atdata_s;
  input wire                               afready_s;
  input wire                               atwakeup_s;

  output wire [3:0]                        wr_pointer_gray;
  input  wire [3:0]                        rd_pointer_gray;
  input wire                               flush_req;
  output wire                              flush_done;
  output wire                              sync_clear;
  input wire                               sync_done;

  output wire                              syncreq_s;

  input  wire                              syncreq_async_req;
  output wire                              syncreq_async_ack;

  output wire                              atready_s;
  output wire                              afvalid_s;
  output wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1 : 0] atb_fwd_data;

  input wire                               clk_s_qreq_n;
  output wire                              clk_s_qaccept_n;
  output wire                              clk_s_qactive;
  output wire                              clk_s_qdeny;

  input wire                               pwr_qreq_n;
  output wire                              pwr_qaccept_n;
  output wire                              pwr_qdeny;
  output wire                              pwr_qactive;


  wire [3:0]                               rdptr_gray_sync;
  wire                                     flush_req_sync;

  wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1:0]  fifo_data;

  wire                                     pwr_lp_request;
  wire                                     pwr_lp_done;

  wire                                     clk_lp_request;
  wire                                     clk_lp_done;

  wire                                     pulse_qreq_n;
  wire                                     pulse_qaccept_n;
  wire                                     pulse_qactive;
  wire                                     bridge_active;
  wire                                     clk_s_qreq_n_sync;
  wire                                     pwr_qreq_n_sync;
  wire                                     sync_done_sync;


  css600_atbasyncbridge_slv_async u_qactive_async (
    .pwr_qreq_n        (pwr_qreq_n),
    .pwr_qaccept_n     (pwr_qaccept_n),
    .pulse_qactive     (pulse_qactive),
    .atwakeup_s        (atwakeup_s),
    .flush_req         (flush_req),
    .clk_s_qactive     (clk_s_qactive)
  );

  assign pwr_qactive = 1'b0;
  assign pwr_qdeny   = 1'b0;

  assign bridge_active = flush_req_sync | atvalid_s | (pwr_qreq_n_sync ^ pwr_qaccept_n);

  assign atb_fwd_data = fifo_data;

  css600_atbasyncbridge_slv_fifo #(
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
    .BUFFER_DEPTH(BUFFER_DEPTH)
  ) u_css600_atbasyncbridge_slv_fifo
  (
    .write_data       ({atbytes_s,atid_s,atdata_s}),
    .atreadys         (atready_s),
    .afvalids         (afvalid_s),
    .fifo_data        (fifo_data),
    .wrptr_gray       (wr_pointer_gray),
    .flush_done       (flush_done),
    .clk_s            (clk_s),
    .reset_s_n        (reset_s_n),
    .atvalids         (atvalid_s),
    .afreadys         (afready_s),
    .rdptr_gray_sync  (rdptr_gray_sync[3:0]),
    .flush_req_sync   (flush_req_sync),
    .sync_clear       (sync_clear),
    .sync_done_sync   (sync_done_sync),

    .pwr_lp_request   (pwr_lp_request),
    .pwr_lp_done      (pwr_lp_done),

    .clk_lp_request   (clk_lp_request),
    .clk_lp_done      (clk_lp_done),
    .clk_lp_dny       (bridge_active),
    .pulse_qaccept_n  (pulse_qaccept_n),
    .clk_qreq_n_sync  (clk_s_qreq_n_sync),
    .clk_qaccept_n    (clk_s_qaccept_n)
  );

  css600_atbasyncbridge_slv_sync#(
    .SYNC_DEPTH(FF_SYNC_DEPTH_LOC)
  ) u_css600_atbasyncbridge_slv_sync
  (
    .rdptr_gray_sync   (rdptr_gray_sync[3:0]),
    .flush_req_sync    (flush_req_sync),
    .clk_s_qreq_n_sync (clk_s_qreq_n_sync),
    .pwr_qreq_n_sync   (pwr_qreq_n_sync),
    .sync_done_sync    (sync_done_sync),
    .clk_s             (clk_s),
    .reset_s_n         (reset_s_n),
    .rdptr_gray        (rd_pointer_gray),
    .flush_req         (flush_req),
    .clk_s_qreq_n      (clk_s_qreq_n),
    .pwr_qreq_n        (pwr_qreq_n),
    .sync_done         (sync_done)
  );

  css600_pulseasyncbridgemstr #(
    .WIDTH(1),
    .FF_SYNC_DEPTH(FF_SYNC_DEPTH_LOC)
  ) u_css600_pulseasyncbridgemstr
  (
    .clk_m           (clk_s),
    .reset_m_n       (reset_s_n),
    .pulse_out       (syncreq_s),
    .pulse_req       (syncreq_async_req),
    .pulse_ack       (syncreq_async_ack),
    .clk_m_qreq_n    (pulse_qreq_n),
    .clk_m_qaccept_n (pulse_qaccept_n),
    .clk_m_qactive   (pulse_qactive)
  );
  assign pulse_qreq_n = clk_s_qreq_n | clk_s_qdeny;


  css600_lpislave u_css600_atbasyncbridge_clk_lpi_slv (
    .clk             (clk_s),
    .reset_n         (reset_s_n),
    .qreq_sync_n     (clk_s_qreq_n_sync),
    .qaccept_n       (clk_s_qaccept_n),
    .qdeny           (clk_s_qdeny),
    .lp_request      (clk_lp_request),
    .dev_active      (bridge_active),
    .lp_done         (clk_lp_done),
    .dev_run         (),
    .cg_en           ()
  );

  css600_lpislave u_css600_atbasyncbridge_pwr_lpi_slv (
    .clk            (clk_s),
    .reset_n        (reset_s_n),
    .qreq_sync_n    (pwr_qreq_n_sync),
    .qaccept_n      (pwr_qaccept_n),
    .qdeny          (),
    .lp_request     (pwr_lp_request),
    .dev_active     (1'b0),
    .lp_done        (pwr_lp_done),
    .dev_run        (),
    .cg_en          ()
  );

endmodule

