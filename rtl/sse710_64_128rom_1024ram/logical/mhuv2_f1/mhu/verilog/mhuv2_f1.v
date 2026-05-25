//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module mhuv2_f1
#(
   parameter [6:0] MHU_NUM_CH        = 7'd1
 )(

  input  wire           PCLK_SND,
  input  wire           PRESETN_SND,

  input wire            PWAKEUP_SND,
  input wire   [31:0]   PADDR_SND,
  input wire            PWRITE_SND,
  input wire   [31:0]   PWDATA_SND,
  input wire            PENABLE_SND,
  input wire            PSELx_SND,
  output  wire   [31:0] PRDATA_SND,
  output  wire          PREADY_SND,
  output  wire          PSLVERR_SND,

  input  wire           QREQn_PCLK_SND,
  output wire           QACCEPTn_PCLK_SND,
  output wire           QDENY_PCLK_SND,
  output wire           QACTIVE_PCLK_SND,


  input  wire           PCLK_REC,
  input  wire           PRESETN_REC,

  input wire            PWAKEUP_REC,
  input wire   [31:0]   PADDR_REC,
  input wire            PWRITE_REC,
  input wire   [31:0]   PWDATA_REC,
  input wire            PENABLE_REC,
  input wire            PSELx_REC,
  output  wire   [31:0] PRDATA_REC,
  output  wire          PREADY_REC,
  output  wire          PSLVERR_REC,

  input  wire           QREQn_PCLK_REC,
  output wire           QACCEPTn_PCLK_REC,
  output wire           QDENY_PCLK_REC,
  output wire           QACTIVE_PCLK_REC,

  input  wire           QREQn_PWR_REC,
  output wire           QACCEPTn_PWR_REC,
  output wire           QDENY_PWR_REC,
  output wire           QACTIVE_PWR_REC,

  output wire           MHU_IRQCOMB,
  output wire [MHU_NUM_CH-1:0]  MHU_IRQREG,

  output wire           INT_ACCESS_NR2R,
  output wire           INT_ACCESS_R2NR,
  output wire           INT_IRQCOMB,

  input wire                  DFTCGEN
 );


  wire                        apb_async_req;
  wire [48:0]                 apb_async_req_payload;
  wire [32:0]                 apb_async_resp_payload;
  wire                        apb_async_ack;
  wire                        recawake_async;
  wire                        recwakeup_async;

  wire [1:1]                  config_checker_0;

  wire [MHU_NUM_CH-1:0] edge_async_req;
  wire [MHU_NUM_CH-1:0] edge_async_ack;

  assign config_checker_0[((MHU_NUM_CH > 7'd0) & (MHU_NUM_CH < 7'd125) )] = 1'b1;

  assign QACTIVE_PWR_REC = recwakeup_async;


mhuv2_f1_sender #(
  .MHU_NUM_CH (MHU_NUM_CH)
) u_mhu_sender (
  .pclk_snd                             (PCLK_SND),
  .presetn_snd                          (PRESETN_SND),
  .pwakeup_snd                          (PWAKEUP_SND),
  .paddr_snd                            (PADDR_SND),
  .pwrite_snd                           (PWRITE_SND),
  .pwdata_snd                           (PWDATA_SND),
  .penable_snd                          (PENABLE_SND),
  .pselx_snd                            (PSELx_SND),
  .prdata_snd                           (PRDATA_SND),
  .pready_snd                           (PREADY_SND),
  .pslverr_snd                          (PSLVERR_SND),
  .qreqn_pclk_snd                       (QREQn_PCLK_SND),
  .qacceptn_pclk_snd                    (QACCEPTn_PCLK_SND),
  .qdeny_pclk_snd                       (QDENY_PCLK_SND),
  .qactive_pclk_snd                     (QACTIVE_PCLK_SND),
  .apb_async_req                        (apb_async_req),
  .apb_async_req_payload                (apb_async_req_payload),
  .apb_async_resp_payload               (apb_async_resp_payload),
  .apb_async_ack                        (apb_async_ack),
  .recawake_async                       (recawake_async),
  .recwakeup_async                      (recwakeup_async),
  .int_access_nr2r                      (INT_ACCESS_NR2R),
  .int_access_r2nr                      (INT_ACCESS_R2NR),
  .int_irqcomb                          (INT_IRQCOMB),
  .edge_async_req                       (edge_async_req),
  .edge_async_ack                       (edge_async_ack),
  .dftcgen                              (DFTCGEN)
);


mhuv2_f1_receiver #(
  .MHU_NUM_CH (MHU_NUM_CH)

) u_mhu_receiver (
  .pclk_rec                             (PCLK_REC),
  .presetn_rec                          (PRESETN_REC),
  .pwakeup_rec                          (PWAKEUP_REC),
  .paddr_rec                            (PADDR_REC),
  .pwrite_rec                           (PWRITE_REC),
  .pwdata_rec                           (PWDATA_REC),
  .penable_rec                          (PENABLE_REC),
  .pselx_rec                            (PSELx_REC),
  .prdata_rec                           (PRDATA_REC),
  .pready_rec                           (PREADY_REC),
  .pslverr_rec                          (PSLVERR_REC),
  .qreqn_pclk_rec                       (QREQn_PCLK_REC),
  .qacceptn_pclk_rec                    (QACCEPTn_PCLK_REC),
  .qdeny_pclk_rec                       (QDENY_PCLK_REC),
  .qactive_pclk_rec                     (QACTIVE_PCLK_REC),
  .qreqn_pwr_rec                        (QREQn_PWR_REC),
  .qacceptn_pwr_rec                     (QACCEPTn_PWR_REC),
  .qdeny_pwr_rec                        (QDENY_PWR_REC),
  .mhu_irqcomb                          (MHU_IRQCOMB),
  .mhu_irq_reg                          (MHU_IRQREG),
  .apb_async_req                        (apb_async_req),
  .apb_async_req_payload                (apb_async_req_payload),
  .apb_async_resp_payload               (apb_async_resp_payload),
  .apb_async_ack                        (apb_async_ack),
  .recawake_async                       (recawake_async),
  .recwakeup_async                      (recwakeup_async),
  .edge_async_req                       (edge_async_req),
  .edge_async_ack                       (edge_async_ack),
  .dftcgen                              (DFTCGEN)
);

endmodule
