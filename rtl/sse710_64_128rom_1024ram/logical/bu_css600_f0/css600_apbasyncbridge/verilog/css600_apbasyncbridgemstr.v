//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2014-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_apbasyncbridge
//
//----------------------------------------------------------------------------


module css600_apbasyncbridgemstr #(parameter
  APB_ADDR_WIDTH = 12,
  FF_SYNC_DEPTH  = 2
)
(
  clk_m,
  reset_m_n,
  dftcgen,
  psel_m,
  penable_m,
  paddr_m,
  pwrite_m,
  pwdata_m,
  pprot_m,
  prdata_m,
  pready_m,
  pslverr_m,
  pwakeup_m,
  clk_m_qreq_n,
  clk_m_qaccept_n,
  clk_m_qdeny,
  clk_m_qactive,
  apb_async_req,
  apb_async_req_payload,
  apb_async_resp_payload,
  apb_async_ack
);

  localparam L_APB_ADDR_WIDTH = (APB_ADDR_WIDTH >= 12) && (APB_ADDR_WIDTH <= 37)
                                ? APB_ADDR_WIDTH
                                : 12;
  localparam PAYLOAD_WIDTH    = L_APB_ADDR_WIDTH + 36;

  input  wire                        clk_m;
  input  wire                        reset_m_n;
  input wire                         dftcgen;
  output wire                        psel_m;
  output wire                        penable_m;
  output wire [L_APB_ADDR_WIDTH-1:0] paddr_m;
  output wire                        pwrite_m;
  output wire [31:0]                 pwdata_m;
  output wire [2:0]                  pprot_m;
  input  wire [31:0]                 prdata_m;
  input  wire                        pready_m;
  input  wire                        pslverr_m;
  output wire                        pwakeup_m;
  input  wire                        clk_m_qreq_n;
  output wire                        clk_m_qaccept_n;
  output wire                        clk_m_qdeny;
  output wire                        clk_m_qactive;
  input  wire                        apb_async_req;
  input  wire [PAYLOAD_WIDTH-1:0]    apb_async_req_payload;
  output wire [32:0]                 apb_async_resp_payload;
  output wire                        apb_async_ack;


  wire clk_gated;
  wire clken;

  wire apb_async_req_ss;
  wire clkmqreqn_ss;
  wire        apb_async_ack_int;
  wire [32:0] apb_async_resp_payload_int;


  css600_apbasyncbridgemstr_core #(
    .PAYLOAD_WIDTH (PAYLOAD_WIDTH)
  ) u_mstr_core
  (
    .clk_m                    (clk_gated),
    .reset_m_n                (reset_m_n),
    .psel_o                   (psel_m),
    .penable_o                (penable_m),
    .paddr_o                  (paddr_m),
    .pwrite_o                 (pwrite_m),
    .pwdata_o                 (pwdata_m),
    .pprot_o                  (pprot_m),
    .prdata_i                 (prdata_m),
    .pready_i                 (pready_m),
    .pslverr_i                (pslverr_m),
    .pwakeup_o                (pwakeup_m),
    .clkmqreqn_i              (clkmqreqn_ss),
    .clkmqacceptn_o           (clk_m_qaccept_n),
    .clkmqdeny_o              (clk_m_qdeny),
    .apb_async_req_i          (apb_async_req_ss),
    .apb_async_req_payload_i  (apb_async_req_payload),
    .apb_async_resp_payload_o (apb_async_resp_payload_int),
    .apb_async_ack_o          (apb_async_ack_int),
    .clken_o                  (clken)
  );


  css600_apbasyncbridgemstr_async
  u_qactive_async
  (
    .apb_async_req_async_i (apb_async_req),
    .apb_async_ack_i       (apb_async_ack),
    .clkmqactive_o         (clk_m_qactive)
  );


  css600_clk_gate
  u_clk_gate
  (
    .clk_i        (clk_m),
    .clk_enable_i (clken),
    .clk_o        (clk_gated),
    .dftcgen      (dftcgen)
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
  ) u_req_sync
  (
    .clk       (clk_m),
    .reset_n   (reset_m_n),
    .d_async_i (apb_async_req),
    .q_sync_o  (apb_async_req_ss)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
  ) u_clk_qreq_sync
  (
    .clk       (clk_m),
    .reset_n   (reset_m_n),
    .d_async_i (clk_m_qreq_n),
    .q_sync_o  (clkmqreqn_ss)
  );

  assign apb_async_resp_payload = apb_async_resp_payload_int;

  assign apb_async_ack = apb_async_ack_int;


endmodule
