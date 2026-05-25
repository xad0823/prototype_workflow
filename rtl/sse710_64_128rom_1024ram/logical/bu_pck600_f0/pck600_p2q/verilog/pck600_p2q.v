// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------

module pck600_p2q #(
                    parameter CTRL_P_CH_SYNC     = 1,
                    parameter DEV_Q_CH_SYNC      = 1,
                    parameter CTRL_P_CH_PWR_PSTATE_MAP = 16'b0000000111110000,
                    parameter CTRL_P_CH_OP_PSTATE_MAP = 16'b0000000111110000,
                    parameter CTRL_P_CH_PACTIVE  = 32'b11111111111111111111111111111111)
  (
  input  wire                          clk,
  input  wire                          reset_n,

  input  wire [7:0]                    ctrl_pstate_i,
  input  wire                          ctrl_preq_i,
  output wire                          ctrl_paccept_o,
  output wire                          ctrl_pdeny_o,
  output wire [31:0]                   ctrl_pactive_o,

  output wire                          dev_qreqn_o,
  input  wire                          dev_qacceptn_i,
  input  wire                          dev_qdeny_i,
  input  wire                          dev_qactive_i,

  output wire                          clk_qactive_o,

  input  wire                          dftcgen
);

  genvar                        I, G, H;

  wire                          clk_gated;
  wire                          clk_qactive0;
  wire                          clk_qactive;
  wire                          ctrl_preq_edge;
  wire                          ctrl_preq_ss;
  wire [7:0]                    ctrl_pstate_ss;
  wire                          dev_qacceptn_ss;
  wire                          dev_qdeny_ss;


  pck600_p2q_core #(.CTRL_P_CH_SYNC           (CTRL_P_CH_SYNC),
                    .CTRL_P_CH_PWR_PSTATE_MAP (CTRL_P_CH_PWR_PSTATE_MAP),
                    .CTRL_P_CH_OP_PSTATE_MAP  (CTRL_P_CH_OP_PSTATE_MAP),
                    .CTRL_P_CH_PACTIVE        (CTRL_P_CH_PACTIVE))
  u_p2q_core (.clk              (clk_gated),
              .reset_n          (reset_n),

              .ctrl_pstate_i    (ctrl_pstate_ss),
              .ctrl_preq_i      (ctrl_preq_ss),
              .ctrl_preq_edge_i (ctrl_preq_edge),
              .ctrl_paccept_o   (ctrl_paccept_o),
              .ctrl_pdeny_o     (ctrl_pdeny_o),
              .ctrl_pactive_o   (ctrl_pactive_o),

              .dev_qreqn_o      (dev_qreqn_o),
              .dev_qacceptn_i   (dev_qacceptn_ss),
              .dev_qdeny_i      (dev_qdeny_ss),
              .dev_qactive_i    (dev_qactive_i),

              .clk_qactive_o    (clk_qactive0));


  pck600_std_or2 u_pck600_or2_preq_qactive (
  .A (clk_qactive0),
  .B (ctrl_preq_i),
  .Y (clk_qactive)
  );

  pck600_clock_gate
  u_pck600_clock_gate
  (
    .clk_in  (clk),
    .enable  (clk_qactive0),
    .clk_out (clk_gated),
    .dftcgen (dftcgen)
  );


  pck600_p2q_pch_tinit_sync #(.CTRL_P_CH_SYNC (CTRL_P_CH_SYNC))
  u_p2q_tinit_sync
  (
    .clk                  (clk),
    .reset_n              (reset_n),
    .ctrl_preq_i          (ctrl_preq_i),
    .ctrl_pstate_i        (ctrl_pstate_i),
    .ctrl_preq_edge_o     (ctrl_preq_edge),
    .ctrl_preq_ss_o       (ctrl_preq_ss),
    .ctrl_pstate_ss_o     (ctrl_pstate_ss)
  );

  generate if(DEV_Q_CH_SYNC == 1)
  begin:dev_sync_inc

    pck600_cdc_capt_sync
    u_pck600_sync_qacceptn
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (dev_qacceptn_i),
      .sync    (dev_qacceptn_ss)
    );

    pck600_cdc_capt_sync
    u_pck600_sync_qdeny
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (dev_qdeny_i),
      .sync    (dev_qdeny_ss)
    );

  end
  else
  begin:dev_sync_excl

  assign dev_qacceptn_ss  = dev_qacceptn_i;
  assign dev_qdeny_ss     = dev_qdeny_i;

  end
  endgenerate

  assign clk_qactive_o = clk_qactive;


endmodule
