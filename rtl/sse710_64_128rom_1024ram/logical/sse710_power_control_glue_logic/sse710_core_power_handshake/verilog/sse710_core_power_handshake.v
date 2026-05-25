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
module sse710_core_power_handshake (

  input  wire       clk,
  input  wire       resetn,

  input  wire       preq_power_handshake,
  input  wire [3:0] pstate_power_handshake,
  output wire       pdeny_power_handshake,
  output wire       paccept_power_handshake,

  input  wire       preq_warmrst_check,
  input  wire [3:0] pstate_warmrst_check,
  output wire       pdeny_warmrst_check,
  output wire       paccept_warmrst_check,

  output wire       cpuqactive_o,
  
  output wire       cpuqreqn_o,
  input  wire       cpuqdeny_i,
  input  wire       cpuqacceptn_i,
  input  wire       cpuqactive_i,

  input  wire       standbywfi,
  input  wire       warmrstreq,
  input  wire       dbgrstreq,
  input  wire       cpuwait_i,

  output wire       cpuwait_o,

  input  wire       dftcgen

);

wire       preq_power_handshake_ss;
wire [3:0] pstate_power_handshake_ss;
wire       preq_power_handshake_ss_d0;
wire       preq_edge_power_handshake;

wire       preq_warmrst_check_ss;
wire [3:0] pstate_warmrst_check_ss;
wire       preq_warmrst_check_ss_d0;
wire       preq_edge_warmrst_check;

wire cpuwait_ss;
wire dbgrstreq_ss;
wire standbywfi_ss;

wire       cpuqreqn_from_p2q;
wire       cpuqacceptn_to_p2q;
wire       cpuqdeny_to_p2q;

wire       cpuqreqn_to_cpu;
wire       cpuqacceptn_from_cpu;
wire       cpuqdeny_from_cpu;


arm_element_cdc_capt_sync u_sync_preq_power_handshake (
  .clk     (clk),
  .nreset  (resetn),
  .d_async (preq_power_handshake),
  .q       (preq_power_handshake_ss_d0)
);

arm_element_cdc_capt_nosync u_nosync_ctrl_preq_power_handshake (
  .clk     (clk),
  .nreset  (resetn),
  .en      (1'b1),
  .d_async (preq_power_handshake_ss_d0),
  .q       (preq_power_handshake_ss)
);

arm_element_std_xor2 u_xor2_preq_edge_power_handshake (
  .A  (preq_power_handshake_ss_d0),
  .B  (preq_power_handshake_ss),
  .Y  (preq_edge_power_handshake)
);

arm_element_cdc_capt_nosync #(
  .IH (3)
) u_nosync_pstate_power_handshake (
  .clk     (clk),
  .nreset  (resetn),
  .en      (preq_edge_power_handshake),
  .d_async (pstate_power_handshake),
  .q       (pstate_power_handshake_ss)
);


arm_element_cdc_capt_sync u_sync_preq_warmrst_check (
  .clk     (clk),
  .nreset  (resetn),
  .d_async (preq_warmrst_check),
  .q       (preq_warmrst_check_ss_d0)
);

arm_element_cdc_capt_nosync u_nosync_ctrl_preq_warmrst_check (
  .clk     (clk),
  .nreset  (resetn),
  .en      (1'b1),
  .d_async (preq_warmrst_check_ss_d0),
  .q       (preq_warmrst_check_ss)
);

arm_element_std_xor2 u_xor2_preq_warmrst_check (
  .A  (preq_warmrst_check_ss_d0),
  .B  (preq_warmrst_check_ss),
  .Y  (preq_edge_warmrst_check)
);

arm_element_cdc_capt_nosync #(
  .IH (3)
) u_nosync_pstate_warmrst_check (
  .clk     (clk),
  .nreset  (resetn),
  .en      (preq_edge_warmrst_check),
  .d_async (pstate_warmrst_check),
  .q    (pstate_warmrst_check_ss)
);


arm_element_cdc_capt_sync u_sync_cpuwait (
  .clk     (clk),
  .nreset  (resetn),
  .d_async (cpuwait_i),
  .q       (cpuwait_ss)
);


arm_element_cdc_capt_sync u_sync_dbgrstreq (
  .clk     (clk),
  .nreset  (resetn),
  .d_async (dbgrstreq),
  .q       (dbgrstreq_ss)
);


sse710_warmrst_check #(
  .SYNC_ENABLE (1'b1)
) u_sse710_warmrst_check (

  .clk         (clk),
  .resetn      (resetn),

  .preq_i      (preq_warmrst_check_ss),
  .pstate_i    (pstate_warmrst_check_ss),
  .paccept_o   (paccept_warmrst_check),
  .pdeny_o     (pdeny_warmrst_check),

  .warmrstreq_i (warmrstreq)

);


pck600_p2q #(
  .CTRL_P_CH_SYNC (0),
  .DEV_Q_CH_SYNC (1),
  .CTRL_P_CH_PWR_PSTATE_MAP (16'b1111_1101_1101_0000),
  .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
  .CTRL_P_CH_PACTIVE (32'd0)
) u_core_p2q (
  .clk             (clk),
  .reset_n         (resetn),

  .ctrl_preq_i     (preq_power_handshake_ss),
  .ctrl_pstate_i   ({4'b0000,pstate_power_handshake_ss}),
  .ctrl_paccept_o  (paccept_power_handshake),
  .ctrl_pdeny_o    (pdeny_power_handshake),
  .ctrl_pactive_o  ( ),

  .dev_qreqn_o     (cpuqreqn_from_p2q),
  .dev_qacceptn_i  (cpuqacceptn_to_p2q),
  .dev_qdeny_i     (cpuqdeny_to_p2q),
  .dev_qactive_i   (1'b0),

  .clk_qactive_o   (),

  .dftcgen         (dftcgen)

);


arm_element_cdc_capt_sync u_standbywfi_sync (
  .clk       (clk),
  .nreset    (resetn),

  .d_async   (standbywfi),
  .q         (standbywfi_ss)
);


wire cpuqreqn_int;
wire cpuqacceptn_int;
wire cpuqdeny_int;

sse710_q_ch_bridge u_qch_bridge_cpuwait
(
  .clk                       (clk),
  .resetn                    (resetn),

  .ctrl_qreqn_i              (cpuqreqn_from_p2q),
  .ctrl_pstate_i             (pstate_power_handshake_ss),
  .ctrl_qacceptn_o           (cpuqacceptn_to_p2q),
  .ctrl_qdeny_o              (cpuqdeny_to_p2q),

  .dev_qreqn_o               (cpuqreqn_int),
  .dev_qacceptn_i            (cpuqacceptn_int),
  .dev_qdeny_i               (cpuqdeny_int),

  .standbywfi_i              (standbywfi_ss),
  .dbgrstreq_i               (dbgrstreq_ss),

  .dev_reset_status_i        (cpuwait_ss),

  .cpuwait_o                 (cpuwait_o)
);


sse710_core_powerup_q_chan #(
  .SYNC_ENABLE (1'b1)
)  u_core_powerup (
  .clk            (clk),
  .resetn         (resetn),

  .pwr_qreqn_i    (cpuqreqn_to_cpu),
  .pwr_qacceptn_o (cpuqacceptn_from_cpu),
  .pwr_qdeny_o    (cpuqdeny_from_cpu),
  
  .pstate_i       (pstate_power_handshake_ss),

  .cpuqreqn_o     (cpuqreqn_o),
  .cpuqacceptn_i  (cpuqacceptn_i),
  .cpuqdeny_i     (cpuqdeny_i),

  .standbywfi_i   (standbywfi_ss)

);


assign cpuqreqn_to_cpu = cpuqreqn_int;
assign cpuqacceptn_int = (cpuqreqn_int | (pstate_power_handshake_ss == 4'h5)) ? cpuqacceptn_from_cpu : cpuqreqn_int;
assign cpuqdeny_int    = (cpuqreqn_int | (pstate_power_handshake_ss == 4'h5)) ? cpuqdeny_from_cpu : 1'b0;
assign cpuqactive_o    = cpuqactive_i;

endmodule
