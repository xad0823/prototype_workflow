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
//   Sub-module of css600_dp
//
//----------------------------------------------------------------------------


module css600_dpmstr #(parameter
  APB_ADDR_WIDTH = 32,
  FF_SYNC_DEPTH  = 2
)
(
  clk,
  reset_n,
  psel_m,
  pwakeup_m,
  penable_m,
  pwrite_m,
  paddr_m,
  pwdata_m,
  prdata_m,
  pready_m,
  pslverr_m,


  clk_qreq_n,
  clk_qaccept_n,
  clk_qactive,
  clk_qdeny,

  bus_req,
  bus_req_payload,
  bus_ack,
  bus_ack_payload,
  dp_abort_req,
  dp_abort_ack,

  dp_abort

);

  localparam  ADDR_SIZE    = (APB_ADDR_WIDTH == 12) ? 12 :
                             (APB_ADDR_WIDTH == 20) ? 20 :
                             32;

  localparam SYNC_DEPTH = (FF_SYNC_DEPTH == 3) ? 3 : 2;


  input  wire        clk;
  input  wire        reset_n;

  output wire                 psel_m;
  output wire                 pwakeup_m;
  output wire                 penable_m;
  output wire                 pwrite_m;
  output wire [ADDR_SIZE-1:0] paddr_m;
  output wire          [31:0] pwdata_m;
  input  wire          [31:0] prdata_m;
  input  wire                 pready_m;
  input  wire                 pslverr_m;

  input  wire                 clk_qreq_n;
  output wire                 clk_qaccept_n;
  output wire                 clk_qactive;
  output wire                 clk_qdeny;


  input  wire                    bus_req;
  input  wire [ADDR_SIZE+31-1:0] bus_req_payload;
  output wire                    bus_ack;
  output wire [33:0]             bus_ack_payload;
  input  wire                    dp_abort_req;
  output wire                    dp_abort_ack;

  output wire                    dp_abort;

  wire       qactive_pulseasyncbridge;
  wire       apb_active;
  wire       lp_request_done;
  wire       clk_qreq_n_sync;
  wire       dev_run;
  wire [3:0] or_inputs;
  wire       bus_req_sync;


  css600_dpmstr_apb_if
    #(.ADDR_SIZE (ADDR_SIZE),
      .SYNC_DEPTH  (SYNC_DEPTH)
     )
    u_css600_dpmstr_apb_if
     (
      .clk                (clk),
      .reset_n            (reset_n),

      .prdata_i           (prdata_m),
      .pready_i           (pready_m),
      .pslverr_i          (pslverr_m),

      .bus_req_dp_mstr_i  (bus_req),
      .bus_req_dp_mstr_o  (bus_req_sync),
      .bus_req_payload_i  (bus_req_payload),

      .dev_run_i          (dev_run),

      .psel_o             (psel_m),
      .pwakeup_o          (pwakeup_m),
      .penable_o          (penable_m),
      .pwrite_o           (pwrite_m),
      .paddr_o            (paddr_m),
      .pwdata_o           (pwdata_m),

      .bus_ack_payload_o  (bus_ack_payload),
      .bus_ack_dp_mstr_o  (bus_ack),

      .apb_active_o       (apb_active)
    );

  css600_pulseasyncbridgemstr_qactive_only
    #(.WIDTH (1),
      .FF_SYNC_DEPTH (SYNC_DEPTH)
     )
   u_css600_pulseasyncbridgemstr
    (
    .clk_m        (clk),
    .reset_m_n    (reset_n),
    .pulse_out    (dp_abort),
    .pulse_req    (dp_abort_req),
    .pulse_ack    (dp_abort_ack),
    .clk_m_qactive  (qactive_pulseasyncbridge)
    );


  css600_lpislave
    u_css600_lpislave_clk
      (
       .clk           (clk),
       .reset_n       (reset_n),
       .qreq_sync_n   (clk_qreq_n_sync),
       .qaccept_n     (clk_qaccept_n),
       .qdeny         (clk_qdeny),
       .lp_request    (lp_request_done),
       .dev_active    (apb_active),
       .lp_done       (lp_request_done),
       .dev_run       (dev_run),
       .cg_en         ()
      );

  assign or_inputs = {bus_req, bus_req_sync, bus_ack, qactive_pulseasyncbridge};

  css600_or_tree #(
     .NUM_OR_INPUTS (4)
  ) u_qactive_async (
    .or_inputs (or_inputs),
    .or_output (clk_qactive)
  );


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
      u_css600_cdc_capt_sync_qreq_n(
                                    .clk       (clk),
                                    .reset_n   (reset_n),
                                    .d_async_i (clk_qreq_n),
                                    .q_sync_o  (clk_qreq_n_sync)
                                   );

endmodule


