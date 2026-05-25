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


module css600_apbasyncbridgeslv #(parameter
  WAKE_ON_TRANSACTION = 1,
  APB_ADDR_WIDTH      = 12,
  FF_SYNC_DEPTH       = 2
)
(
  clk_s,
  reset_s_n,
  dftcgen,
  psel_s,
  penable_s,
  paddr_s,
  pwrite_s,
  pwdata_s,
  pprot_s,
  prdata_s,
  pready_s,
  pslverr_s,
  pwakeup_s,
  clk_s_qreq_n,
  clk_s_qaccept_n,
  clk_s_qdeny,
  clk_s_qactive,
  pwr_qreq_n,
  pwr_qaccept_n,
  pwr_qdeny,
  pwr_qactive,
  apb_async_req,
  apb_async_req_payload,
  apb_async_resp_payload,
  apb_async_ack
);


  localparam L_WAKE_ON_TRANSACTION = WAKE_ON_TRANSACTION == 1 ? 1'b1 : 1'b0;
  localparam L_APB_ADDR_WIDTH      = (APB_ADDR_WIDTH >= 12) && (APB_ADDR_WIDTH <= 37)
                                     ? APB_ADDR_WIDTH
                                     : 12;
  localparam PAYLOAD_WIDTH         = L_APB_ADDR_WIDTH + 36;

  input  wire                        clk_s;
  input  wire                        reset_s_n;
  input wire                         dftcgen;
  input  wire                        psel_s;
  input  wire                        penable_s;
  input  wire [L_APB_ADDR_WIDTH-1:0] paddr_s;
  input  wire                        pwrite_s;
  input  wire [31:0]                 pwdata_s;
  input  wire [2:0]                  pprot_s;
  output wire [31:0]                 prdata_s;
  output wire                        pready_s;
  output wire                        pslverr_s;
  input  wire                        pwakeup_s;
  input  wire                        clk_s_qreq_n;
  output wire                        clk_s_qaccept_n;
  output wire                        clk_s_qdeny;
  output wire                        clk_s_qactive;
  input  wire                        pwr_qreq_n;
  output wire                        pwr_qaccept_n;
  output wire                        pwr_qdeny;
  output wire                        pwr_qactive;
  output wire                        apb_async_req;
  output wire [PAYLOAD_WIDTH-1:0]    apb_async_req_payload;
  input  wire [32:0]                 apb_async_resp_payload;
  input  wire                        apb_async_ack;


  wire clk_gated;
  wire clken;
  wire apb_async_ack_ss;
  wire clksqreqn_ss;
  wire pwrqreqn_ss;
  wire                     apb_async_req_int;
  wire [PAYLOAD_WIDTH-1:0] apb_async_req_payload_int;


  css600_apbasyncbridgeslv_core #(
    .PAYLOAD_WIDTH       (PAYLOAD_WIDTH),
    .WAKE_ON_TRANSACTION (L_WAKE_ON_TRANSACTION)
  )
  u_slv_core
  (
    .clk_s                    (clk_gated),
    .reset_s_n                (reset_s_n),
    .psel_i                   (psel_s),
    .paddr_i                  (paddr_s),
    .pwrite_i                 (pwrite_s),
    .pwdata_i                 (pwdata_s),
    .pprot_i                  (pprot_s),
    .prdata_o                 (prdata_s),
    .pready_o                 (pready_s),
    .pslverr_o                (pslverr_s),
    .clksqreqn_i              (clksqreqn_ss),
    .clksqacceptn_o           (clk_s_qaccept_n),
    .clksqdeny_o              (clk_s_qdeny),
    .pwrqreqn_i               (pwrqreqn_ss),
    .pwrqacceptn_o            (pwr_qaccept_n),
    .pwrqdeny_o               (pwr_qdeny),
    .pwrqactive_o             (pwr_qactive),
    .apb_async_req_o          (apb_async_req_int),
    .apb_async_req_payload_o  (apb_async_req_payload_int),
    .apb_async_resp_payload_i (apb_async_resp_payload),
    .apb_async_ack_i          (apb_async_ack_ss),
    .clken_o                  (clken)
  );


  css600_apbasyncbridgeslv_async
  u_qactive_async
  (
    .pwrqreqn_async_i (pwr_qreq_n),
    .pwakeup_i        (pwakeup_s),
    .pwrqacceptn_i    (pwr_qaccept_n),
    .pwrqdeny_i       (pwr_qdeny),
    .clksqactive_o    (clk_s_qactive)
  );


  css600_clk_gate
  u_clk_gate
  (
    .clk_i        (clk_s),
    .clk_enable_i (clken),
    .clk_o        (clk_gated),
    .dftcgen      (dftcgen)
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
  ) u_ack_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (apb_async_ack),
    .q_sync_o  (apb_async_ack_ss)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
  ) u_clk_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (clk_s_qreq_n),
    .q_sync_o  (clksqreqn_ss)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH)
  ) u_pwr_qreq_sync
  (
    .clk       (clk_s),
    .reset_n   (reset_s_n),
    .d_async_i (pwr_qreq_n),
    .q_sync_o  (pwrqreqn_ss)
  );

  assign apb_async_req_payload = apb_async_req_payload_int;

  assign apb_async_req = apb_async_req_int;


endmodule
