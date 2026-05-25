//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

// This is the specification for the interface between the DPU
// and the top level governor.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_gov_defs.v"
`include "cortexa53params.v"

module ca53_dpu_gov #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         po_reset_n,
  input   [1:0] cpu_id_i,
  input   [3:0] ctr_cwg_i,
  input   [3:0] ctr_erg_i,
  input   [7:0] gov_clusteridaff1_i,
  input   [7:0] gov_clusteridaff2_i,
  input         gov_cp15sdisable_i,
  input         gov_cryptodisable_i,
  input         gov_giccdisable_i,
  input         gov_aa64naa32_i,
  input         gov_cfgend_i,
  input         gov_cfgte_i,
  input         gov_vinithi_i,
  input  [39:2] gov_rvbaraddr_i,
  input         gov_dbgromaddrv_i,
  input [39:12] gov_dbgromaddr_i,
  input [39:18] gov_periphbase_i,
  input         gov_pseldbg_dbg_i,
  input         gov_pseldbg_pmu_i,
  input  [11:2] gov_paddrdbg_i,
  input         gov_paddrdbg31_i,
  input         gov_pwritedbg_i,
  input  [31:0] gov_pwdatadbg_i,
  input         gov_dbgen_i,
  input         gov_niden_i,
  input         gov_spiden_i,
  input         gov_spniden_i,
  input         gov_edecr_osuce_i,
  input         gov_edecr_rce_i,
  input         gov_edecr_ss_i,
  input         gov_edbgrq_i,
  input         gov_edlsr_slk_i,
  input         gov_pmlsr_slk_i,
  input         gov_dbgrestart_i,
  input         gov_dbgpwrupreq_i,
  input         gov_event_reg_i,
  input         gov_wfx_wake_i,
  input         gov_stall_neon_i,
  input         gov_pcnt_kernel_access_i,
  input         gov_pcnt_usr_access_i,
  input         gov_vcnt_usr_access_i,
  input         gov_cntp_usr_access_i,
  input         gov_cntv_usr_access_i,
  input         gov_cntp_kernel_access_i,
  input         gov_sei_level_req_i,
  input         gov_vsei_level_req_i,
  input         gov_rei_level_req_i,
  input         gov_int_active_i,
  input         gov_wfx_drain_req_i,
  input         reset_n_i,
  input         gic_fiq_i,
  input         gic_irq_i,
  input         gic_vfiq_i,
  input         gic_virq_i,
  input         dpu_preadydbg_i,
  input  [31:0] dpu_prdatadbg_i,
  input         dpu_pslverrdbg_i,
  input         dpu_ncommirq_i,
  input         dpu_commrx_i,
  input         dpu_commtx_i,
  input         dpu_dbgack_i,
  input         dpu_dbgtrigger_i,
  input         dpu_dbgnopwrdwn_i,
  input         dpu_dbgrstreq_i,
  input         dpu_dscr_halted_i,
  input         dpu_wfi_req_i,
  input         dpu_wfe_req_i,
  input         dpu_sev_req_i,
  input         dpu_clr_event_register_i,
  input         dpu_irq_pended_i,
  input         dpu_fiq_pended_i,
  input         dpu_sei_pended_i,
  input         dpu_irq_masked_i,
  input         dpu_fiq_masked_i,
  input         dpu_sei_masked_i,
  input         dpu_virq_pended_i,
  input         dpu_vfiq_pended_i,
  input         dpu_vsei_pended_i,
  input         dpu_virq_masked_i,
  input         dpu_vfiq_masked_i,
  input         dpu_vsei_masked_i,
  input         dpu_imp_abort_pending_i,
  input         dpu_dbg_double_lock_set_i,
  input         dpu_neon_active_i,
  input   [2:0] dpu_cpuectlr_cpu_ret_delay_i,
  input   [2:0] dpu_cpuectlr_neon_ret_delay_i,
  input         dpu_scr_el3_ns_i,
  input         dpu_sei_level_ack_i,
  input         dpu_vsei_level_ack_i,
  input         dpu_rei_level_ack_i,
  input         dpu_hcr_el2_fmo_i,
  input         dpu_hcr_el2_imo_i,
  input         dpu_hcr_el2_amo_i,
  input         dpu_scr_el3_fiq_i,
  input         dpu_scr_el3_irq_i,
  input         dpu_monitor_mode_i,
  input         dpu_smp_en_i,
  input         dpu_npmuirq_i,
  input         dpu_warmrstreq_i);


  wire   [1:0] cpu_id = cpu_id_i;
  wire   [3:0] ctr_cwg = ctr_cwg_i;
  wire   [3:0] ctr_erg = ctr_erg_i;
  wire   [7:0] gov_clusteridaff1 = gov_clusteridaff1_i;
  wire   [7:0] gov_clusteridaff2 = gov_clusteridaff2_i;
  wire         gov_cp15sdisable = gov_cp15sdisable_i;
  wire         gov_cryptodisable = gov_cryptodisable_i;
  wire         gov_giccdisable = gov_giccdisable_i;
  wire         gov_aa64naa32 = gov_aa64naa32_i;
  wire         gov_cfgend = gov_cfgend_i;
  wire         gov_cfgte = gov_cfgte_i;
  wire         gov_vinithi = gov_vinithi_i;
  wire  [39:2] gov_rvbaraddr = gov_rvbaraddr_i;
  wire         gov_dbgromaddrv = gov_dbgromaddrv_i;
  wire [39:12] gov_dbgromaddr = gov_dbgromaddr_i;
  wire [39:18] gov_periphbase = gov_periphbase_i;
  wire         gov_pseldbg_dbg = gov_pseldbg_dbg_i;
  wire         gov_pseldbg_pmu = gov_pseldbg_pmu_i;
  wire  [11:2] gov_paddrdbg = gov_paddrdbg_i;
  wire         gov_paddrdbg31 = gov_paddrdbg31_i;
  wire         gov_pwritedbg = gov_pwritedbg_i;
  wire  [31:0] gov_pwdatadbg = gov_pwdatadbg_i;
  wire         gov_dbgen = gov_dbgen_i;
  wire         gov_niden = gov_niden_i;
  wire         gov_spiden = gov_spiden_i;
  wire         gov_spniden = gov_spniden_i;
  wire         gov_edecr_osuce = gov_edecr_osuce_i;
  wire         gov_edecr_rce = gov_edecr_rce_i;
  wire         gov_edecr_ss = gov_edecr_ss_i;
  wire         gov_edbgrq = gov_edbgrq_i;
  wire         gov_edlsr_slk = gov_edlsr_slk_i;
  wire         gov_pmlsr_slk = gov_pmlsr_slk_i;
  wire         gov_dbgrestart = gov_dbgrestart_i;
  wire         gov_dbgpwrupreq = gov_dbgpwrupreq_i;
  wire         gov_event_reg = gov_event_reg_i;
  wire         gov_wfx_wake = gov_wfx_wake_i;
  wire         gov_stall_neon = gov_stall_neon_i;
  wire         gov_pcnt_kernel_access = gov_pcnt_kernel_access_i;
  wire         gov_pcnt_usr_access = gov_pcnt_usr_access_i;
  wire         gov_vcnt_usr_access = gov_vcnt_usr_access_i;
  wire         gov_cntp_usr_access = gov_cntp_usr_access_i;
  wire         gov_cntv_usr_access = gov_cntv_usr_access_i;
  wire         gov_cntp_kernel_access = gov_cntp_kernel_access_i;
  wire         gov_sei_level_req = gov_sei_level_req_i;
  wire         gov_vsei_level_req = gov_vsei_level_req_i;
  wire         gov_rei_level_req = gov_rei_level_req_i;
  wire         gov_int_active = gov_int_active_i;
  wire         gov_wfx_drain_req = gov_wfx_drain_req_i;
  wire         reset_n = reset_n_i;
  wire         gic_fiq = gic_fiq_i;
  wire         gic_irq = gic_irq_i;
  wire         gic_vfiq = gic_vfiq_i;
  wire         gic_virq = gic_virq_i;
  wire         dpu_preadydbg = dpu_preadydbg_i;
  wire  [31:0] dpu_prdatadbg = dpu_prdatadbg_i;
  wire         dpu_pslverrdbg = dpu_pslverrdbg_i;
  wire         dpu_ncommirq = dpu_ncommirq_i;
  wire         dpu_commrx = dpu_commrx_i;
  wire         dpu_commtx = dpu_commtx_i;
  wire         dpu_dbgack = dpu_dbgack_i;
  wire         dpu_dbgtrigger = dpu_dbgtrigger_i;
  wire         dpu_dbgnopwrdwn = dpu_dbgnopwrdwn_i;
  wire         dpu_dbgrstreq = dpu_dbgrstreq_i;
  wire         dpu_dscr_halted = dpu_dscr_halted_i;
  wire         dpu_wfi_req = dpu_wfi_req_i;
  wire         dpu_wfe_req = dpu_wfe_req_i;
  wire         dpu_sev_req = dpu_sev_req_i;
  wire         dpu_clr_event_register = dpu_clr_event_register_i;
  wire         dpu_irq_pended = dpu_irq_pended_i;
  wire         dpu_fiq_pended = dpu_fiq_pended_i;
  wire         dpu_sei_pended = dpu_sei_pended_i;
  wire         dpu_irq_masked = dpu_irq_masked_i;
  wire         dpu_fiq_masked = dpu_fiq_masked_i;
  wire         dpu_sei_masked = dpu_sei_masked_i;
  wire         dpu_virq_pended = dpu_virq_pended_i;
  wire         dpu_vfiq_pended = dpu_vfiq_pended_i;
  wire         dpu_vsei_pended = dpu_vsei_pended_i;
  wire         dpu_virq_masked = dpu_virq_masked_i;
  wire         dpu_vfiq_masked = dpu_vfiq_masked_i;
  wire         dpu_vsei_masked = dpu_vsei_masked_i;
  wire         dpu_imp_abort_pending = dpu_imp_abort_pending_i;
  wire         dpu_dbg_double_lock_set = dpu_dbg_double_lock_set_i;
  wire         dpu_neon_active = dpu_neon_active_i;
  wire   [2:0] dpu_cpuectlr_cpu_ret_delay = dpu_cpuectlr_cpu_ret_delay_i;
  wire   [2:0] dpu_cpuectlr_neon_ret_delay = dpu_cpuectlr_neon_ret_delay_i;
  wire         dpu_scr_el3_ns = dpu_scr_el3_ns_i;
  wire         dpu_sei_level_ack = dpu_sei_level_ack_i;
  wire         dpu_vsei_level_ack = dpu_vsei_level_ack_i;
  wire         dpu_rei_level_ack = dpu_rei_level_ack_i;
  wire         dpu_hcr_el2_fmo = dpu_hcr_el2_fmo_i;
  wire         dpu_hcr_el2_imo = dpu_hcr_el2_imo_i;
  wire         dpu_hcr_el2_amo = dpu_hcr_el2_amo_i;
  wire         dpu_scr_el3_fiq = dpu_scr_el3_fiq_i;
  wire         dpu_scr_el3_irq = dpu_scr_el3_irq_i;
  wire         dpu_monitor_mode = dpu_monitor_mode_i;
  wire         dpu_smp_en = dpu_smp_en_i;
  wire         dpu_npmuirq = dpu_npmuirq_i;
  wire         dpu_warmrstreq = dpu_warmrstreq_i;

  wire         pseldbg;

  reg         in_wfx;
  reg         out_of_reset;

  reg         gov_edlsr_slk_reg;
  reg         in_wfx_reg;
  reg         out_of_reset_reg;
  reg         out_of_reset_reg_reg;
  reg         pseldbg_reg;
  reg         gov_pmlsr_slk_reg;

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
  begin
    gov_edlsr_slk_reg <= 1'b0;
    in_wfx_reg <= 1'b0;
    out_of_reset_reg <= 1'b0;
    out_of_reset_reg_reg <= 1'b0;
    pseldbg_reg <= 1'b0;
    gov_pmlsr_slk_reg <= 1'b0;
  end
  else
  begin
    gov_edlsr_slk_reg <= gov_edlsr_slk;
    gov_pmlsr_slk_reg <= gov_pmlsr_slk;
    in_wfx_reg <= in_wfx;
    out_of_reset_reg <= out_of_reset;
    out_of_reset_reg_reg <= out_of_reset_reg;
    pseldbg_reg <= pseldbg;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Configuration signals
  //  input [1:0]    cpu_id                       valid always                          timing 10%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "cpu_id X or Z")
  u_ovl_intf_x_cpu_id (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (cpu_id));

  //  input [3:0]    ctr_cwg                      valid always                          timing 10%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "ctr_cwg X or Z")
  u_ovl_intf_x_ctr_cwg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (ctr_cwg));

  //  input [3:0]    ctr_erg                      valid always                          timing 10%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "ctr_erg X or Z")
  u_ovl_intf_x_ctr_erg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (ctr_erg));

  //  input [7:0]    gov_clusteridaff1            valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "gov_clusteridaff1 X or Z")
  u_ovl_intf_x_gov_clusteridaff1 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_clusteridaff1));

  //  input [7:0]    gov_clusteridaff2            valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "gov_clusteridaff2 X or Z")
  u_ovl_intf_x_gov_clusteridaff2 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_clusteridaff2));

  //  input          gov_cp15sdisable             valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cp15sdisable X or Z")
  u_ovl_intf_x_gov_cp15sdisable (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cp15sdisable));

  //  input          gov_cryptodisable            valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cryptodisable X or Z")
  u_ovl_intf_x_gov_cryptodisable (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cryptodisable));

  //  input          gov_giccdisable              valid always                          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_giccdisable X or Z")
  u_ovl_intf_x_gov_giccdisable (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_giccdisable));

  //  input          gov_aa64naa32                valid always                          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_aa64naa32 X or Z")
  u_ovl_intf_x_gov_aa64naa32 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_aa64naa32));

  //  input          gov_cfgend                   valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cfgend X or Z")
  u_ovl_intf_x_gov_cfgend (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cfgend));

  //  input          gov_cfgte                    valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cfgte X or Z")
  u_ovl_intf_x_gov_cfgte (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cfgte));

  //  input          gov_vinithi                  valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_vinithi X or Z")
  u_ovl_intf_x_gov_vinithi (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_vinithi));

  //  input [39:2]   gov_rvbaraddr                valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 38, INOPTIONS, "gov_rvbaraddr X or Z")
  u_ovl_intf_x_gov_rvbaraddr (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_rvbaraddr));

  //  input          gov_dbgromaddrv              valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_dbgromaddrv X or Z")
  u_ovl_intf_x_gov_dbgromaddrv (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgromaddrv));

  //  input [39:12]  gov_dbgromaddr               valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 28, INOPTIONS, "gov_dbgromaddr X or Z")
  u_ovl_intf_x_gov_dbgromaddr (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgromaddr));

  //  input [39:18]  gov_periphbase               valid always                          timing 30% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 22, INOPTIONS, "gov_periphbase X or Z")
  u_ovl_intf_x_gov_periphbase (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_periphbase));


  // APB interface
  //  input          gov_pseldbg_dbg              valid always                          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pseldbg_dbg X or Z")
  u_ovl_intf_x_gov_pseldbg_dbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pseldbg_dbg));

  //  input          gov_pseldbg_pmu              valid always                          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pseldbg_pmu X or Z")
  u_ovl_intf_x_gov_pseldbg_pmu (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pseldbg_pmu));

  //  input [11:2]   gov_paddrdbg                 valid pseldbg                         timing 70%

  assert_never_unknown #(`OVL_FATAL, 10, INOPTIONS, "gov_paddrdbg X or Z")
  u_ovl_intf_x_gov_paddrdbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (pseldbg),
    .test_expr (gov_paddrdbg));

  //  input          gov_paddrdbg31               valid pseldbg                         timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_paddrdbg31 X or Z")
  u_ovl_intf_x_gov_paddrdbg31 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (pseldbg),
    .test_expr (gov_paddrdbg31));

  //  input          gov_pwritedbg                valid pseldbg                         timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pwritedbg X or Z")
  u_ovl_intf_x_gov_pwritedbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (pseldbg),
    .test_expr (gov_pwritedbg));

  //  input [31:0]   gov_pwdatadbg                valid pseldbg & gov_pwritedbg         timing 70%

  assert_never_unknown #(`OVL_FATAL, 32, INOPTIONS, "gov_pwdatadbg X or Z")
  u_ovl_intf_x_gov_pwdatadbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (pseldbg & gov_pwritedbg),
    .test_expr (gov_pwdatadbg));

  //  output         dpu_preadydbg                valid always                          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_preadydbg X or Z")
  u_ovl_intf_x_dpu_preadydbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_preadydbg));

  //  output [31:0]  dpu_prdatadbg                valid dpu_preadydbg & ~gov_pwritedbg  timing 30%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "dpu_prdatadbg X or Z")
  u_ovl_intf_x_dpu_prdatadbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_preadydbg & ~gov_pwritedbg),
    .test_expr (dpu_prdatadbg));

  //  output         dpu_pslverrdbg               valid dpu_preadydbg                   timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pslverrdbg X or Z")
  u_ovl_intf_x_dpu_pslverrdbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_preadydbg),
    .test_expr (dpu_pslverrdbg));


  // Debug signals
  //  input          gov_dbgen                    valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_dbgen X or Z")
  u_ovl_intf_x_gov_dbgen (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgen));

  //  input          gov_niden                    valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_niden X or Z")
  u_ovl_intf_x_gov_niden (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_niden));

  //  input          gov_spiden                   valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_spiden X or Z")
  u_ovl_intf_x_gov_spiden (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_spiden));

  //  input          gov_spniden                  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_spniden X or Z")
  u_ovl_intf_x_gov_spniden (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_spniden));

  //  input          gov_edecr_osuce              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_edecr_osuce X or Z")
  u_ovl_intf_x_gov_edecr_osuce (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_edecr_osuce));

  //  input          gov_edecr_rce                valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_edecr_rce X or Z")
  u_ovl_intf_x_gov_edecr_rce (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_edecr_rce));

  //  input          gov_edecr_ss                 valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_edecr_ss X or Z")
  u_ovl_intf_x_gov_edecr_ss (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_edecr_ss));

  //  input          gov_edbgrq                   valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_edbgrq X or Z")
  u_ovl_intf_x_gov_edbgrq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_edbgrq));

  //  input          gov_edlsr_slk                valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_edlsr_slk X or Z")
  u_ovl_intf_x_gov_edlsr_slk (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_edlsr_slk));

  //  input          gov_pmlsr_slk                valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pmlsr_slk X or Z")
  u_ovl_intf_x_gov_pmlsr_slk (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pmlsr_slk));

  //  input          gov_dbgrestart               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_dbgrestart X or Z")
  u_ovl_intf_x_gov_dbgrestart (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgrestart));

  //  input          gov_dbgpwrupreq              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_dbgpwrupreq X or Z")
  u_ovl_intf_x_gov_dbgpwrupreq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgpwrupreq));


  //  output         dpu_ncommirq                 valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ncommirq X or Z")
  u_ovl_intf_x_dpu_ncommirq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ncommirq));

  //  output         dpu_commrx                   valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_commrx X or Z")
  u_ovl_intf_x_dpu_commrx (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_commrx));

  //  output         dpu_commtx                   valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_commtx X or Z")
  u_ovl_intf_x_dpu_commtx (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_commtx));

  //  output         dpu_dbgack                   valid always                          timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbgack X or Z")
  u_ovl_intf_x_dpu_dbgack (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbgack));

  //  output         dpu_dbgtrigger               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbgtrigger X or Z")
  u_ovl_intf_x_dpu_dbgtrigger (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbgtrigger));

  //  output         dpu_dbgnopwrdwn              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbgnopwrdwn X or Z")
  u_ovl_intf_x_dpu_dbgnopwrdwn (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbgnopwrdwn));

  //  output         dpu_dbgrstreq                valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbgrstreq X or Z")
  u_ovl_intf_x_dpu_dbgrstreq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbgrstreq));

  //  output         dpu_dscr_halted              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dscr_halted X or Z")
  u_ovl_intf_x_dpu_dscr_halted (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dscr_halted));


  // Clock/power control signals
  //  input          gov_event_reg                valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_event_reg X or Z")
  u_ovl_intf_x_gov_event_reg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_event_reg));

  //  input          gov_wfx_wake                 valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_wfx_wake X or Z")
  u_ovl_intf_x_gov_wfx_wake (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_wfx_wake));

  //  output         dpu_wfi_req                  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wfi_req X or Z")
  u_ovl_intf_x_dpu_wfi_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_wfi_req));

  //  output         dpu_wfe_req                  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wfe_req X or Z")
  u_ovl_intf_x_dpu_wfe_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_wfe_req));

  //  output         dpu_sev_req                  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sev_req X or Z")
  u_ovl_intf_x_dpu_sev_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sev_req));

  //  output         dpu_clr_event_register       valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_clr_event_register X or Z")
  u_ovl_intf_x_dpu_clr_event_register (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_clr_event_register));


  //  output         dpu_irq_pended               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_irq_pended X or Z")
  u_ovl_intf_x_dpu_irq_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_irq_pended));

  //  output         dpu_fiq_pended               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_fiq_pended X or Z")
  u_ovl_intf_x_dpu_fiq_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_fiq_pended));

  //  output         dpu_sei_pended               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sei_pended X or Z")
  u_ovl_intf_x_dpu_sei_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sei_pended));

  //  output         dpu_irq_masked               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_irq_masked X or Z")
  u_ovl_intf_x_dpu_irq_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_irq_masked));

  //  output         dpu_fiq_masked               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_fiq_masked X or Z")
  u_ovl_intf_x_dpu_fiq_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_fiq_masked));

  //  output         dpu_sei_masked               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sei_masked X or Z")
  u_ovl_intf_x_dpu_sei_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sei_masked));

  //  output         dpu_virq_pended              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_virq_pended X or Z")
  u_ovl_intf_x_dpu_virq_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_virq_pended));

  //  output         dpu_vfiq_pended              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_vfiq_pended X or Z")
  u_ovl_intf_x_dpu_vfiq_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vfiq_pended));

  //  output         dpu_vsei_pended              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_vsei_pended X or Z")
  u_ovl_intf_x_dpu_vsei_pended (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vsei_pended));

  //  output         dpu_virq_masked              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_virq_masked X or Z")
  u_ovl_intf_x_dpu_virq_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_virq_masked));

  //  output         dpu_vfiq_masked              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_vfiq_masked X or Z")
  u_ovl_intf_x_dpu_vfiq_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vfiq_masked));

  //  output         dpu_vsei_masked              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_vsei_masked X or Z")
  u_ovl_intf_x_dpu_vsei_masked (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vsei_masked));

  //  output         dpu_imp_abort_pending        valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_imp_abort_pending X or Z")
  u_ovl_intf_x_dpu_imp_abort_pending (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_imp_abort_pending));

  //  output         dpu_dbg_double_lock_set      valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_double_lock_set X or Z")
  u_ovl_intf_x_dpu_dbg_double_lock_set (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_double_lock_set));


  //  input          gov_stall_neon               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_stall_neon X or Z")
  u_ovl_intf_x_gov_stall_neon (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_stall_neon));

  //  output         dpu_neon_active              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_neon_active X or Z")
  u_ovl_intf_x_dpu_neon_active (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_neon_active));

  //  output [2:0]   dpu_cpuectlr_cpu_ret_delay   valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_cpuectlr_cpu_ret_delay X or Z")
  u_ovl_intf_x_dpu_cpuectlr_cpu_ret_delay (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_cpuectlr_cpu_ret_delay));

  //  output [2:0]   dpu_cpuectlr_neon_ret_delay  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_cpuectlr_neon_ret_delay X or Z")
  u_ovl_intf_x_dpu_cpuectlr_neon_ret_delay (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_cpuectlr_neon_ret_delay));


  // Generic timer signals
  //  input          gov_pcnt_kernel_access       valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pcnt_kernel_access X or Z")
  u_ovl_intf_x_gov_pcnt_kernel_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pcnt_kernel_access));

  //  input          gov_pcnt_usr_access          valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pcnt_usr_access X or Z")
  u_ovl_intf_x_gov_pcnt_usr_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pcnt_usr_access));

  //  input          gov_vcnt_usr_access          valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_vcnt_usr_access X or Z")
  u_ovl_intf_x_gov_vcnt_usr_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_vcnt_usr_access));

  //  input          gov_cntp_usr_access          valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cntp_usr_access X or Z")
  u_ovl_intf_x_gov_cntp_usr_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cntp_usr_access));

  //  input          gov_cntv_usr_access          valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cntv_usr_access X or Z")
  u_ovl_intf_x_gov_cntv_usr_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cntv_usr_access));

  //  input          gov_cntp_kernel_access       valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_cntp_kernel_access X or Z")
  u_ovl_intf_x_gov_cntp_kernel_access (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cntp_kernel_access));

  //  output         dpu_scr_el3_ns               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_scr_el3_ns X or Z")
  u_ovl_intf_x_dpu_scr_el3_ns (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_scr_el3_ns));


  // External error signals
  //  input          gov_sei_level_req            valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_sei_level_req X or Z")
  u_ovl_intf_x_gov_sei_level_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_sei_level_req));

  //  input          gov_vsei_level_req           valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_vsei_level_req X or Z")
  u_ovl_intf_x_gov_vsei_level_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_vsei_level_req));

  //  input          gov_rei_level_req            valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_rei_level_req X or Z")
  u_ovl_intf_x_gov_rei_level_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_rei_level_req));

  //  input          gov_int_active               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_int_active X or Z")
  u_ovl_intf_x_gov_int_active (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_int_active));

  //  output         dpu_sei_level_ack            valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sei_level_ack X or Z")
  u_ovl_intf_x_dpu_sei_level_ack (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sei_level_ack));

  //  output         dpu_vsei_level_ack           valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_vsei_level_ack X or Z")
  u_ovl_intf_x_dpu_vsei_level_ack (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_vsei_level_ack));

  //  output         dpu_rei_level_ack            valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_rei_level_ack X or Z")
  u_ovl_intf_x_dpu_rei_level_ack (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_rei_level_ack));


  // GIC CPU Interface
  //  output         dpu_hcr_el2_fmo              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_hcr_el2_fmo X or Z")
  u_ovl_intf_x_dpu_hcr_el2_fmo (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_hcr_el2_fmo));

  //  output         dpu_hcr_el2_imo              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_hcr_el2_imo X or Z")
  u_ovl_intf_x_dpu_hcr_el2_imo (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_hcr_el2_imo));

  //  output         dpu_hcr_el2_amo              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_hcr_el2_amo X or Z")
  u_ovl_intf_x_dpu_hcr_el2_amo (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_hcr_el2_amo));

  //  output         dpu_scr_el3_fiq              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_scr_el3_fiq X or Z")
  u_ovl_intf_x_dpu_scr_el3_fiq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_scr_el3_fiq));

  //  output         dpu_scr_el3_irq              valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_scr_el3_irq X or Z")
  u_ovl_intf_x_dpu_scr_el3_irq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_scr_el3_irq));

  //  output         dpu_monitor_mode             valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_monitor_mode X or Z")
  u_ovl_intf_x_dpu_monitor_mode (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_monitor_mode));


  // Miscellaneous
  //  output         dpu_smp_en                   valid always                          timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_smp_en X or Z")
  u_ovl_intf_x_dpu_smp_en (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_smp_en));

  //  output         dpu_npmuirq                  valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_npmuirq X or Z")
  u_ovl_intf_x_dpu_npmuirq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_npmuirq));

  //  output         dpu_warmrstreq               valid always                          timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_warmrstreq X or Z")
  u_ovl_intf_x_dpu_warmrstreq (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_warmrstreq));


  // ------------------------------------------------------
  // Interface description
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  assign pseldbg  = gov_pseldbg_dbg | gov_pseldbg_pmu;


  assert_implication #(`OVL_FATAL, INOPTIONS, "(gov_sei_level_req | gov_vsei_level_req | gov_rei_level_req)  => gov_int_active")
  u_ovl_intf_assume_c3c6a500c1e61e4dbce74482b3232fc859626f70 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr ((gov_sei_level_req | gov_vsei_level_req | gov_rei_level_req) ),
    .consequent_expr (gov_int_active));



  assert_always #(`OVL_FATAL, INOPTIONS, "~(gov_pseldbg_dbg & gov_pseldbg_pmu)")
  u_ovl_intf_assume_53403ec1c326e79630ef5000e3854b8d440b84ef (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .test_expr (~(gov_pseldbg_dbg & gov_pseldbg_pmu)));


  // The SLK bits in the EDLSR/PMLSR should not change while an APB transaction to the DPU is in progress

  assert_implication #(`OVL_FATAL, INOPTIONS, "pseldbg@1 & pseldbg  => gov_edlsr_slk == gov_edlsr_slk@1")
  u_ovl_intf_assume_a5dc522f60e86e9365de8ea0f6323e6bee326ddc (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (pseldbg_reg & pseldbg ),
    .consequent_expr (gov_edlsr_slk == gov_edlsr_slk_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "pseldbg@1 & pseldbg  => gov_pmlsr_slk == gov_pmlsr_slk@1")
  u_ovl_intf_assume_c24ac40319fd45173f6e059828df60288d05c0e2 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (pseldbg_reg & pseldbg ),
    .consequent_expr (gov_pmlsr_slk == gov_pmlsr_slk_reg));





  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    in_wfx <= 1'b0;
  else
    in_wfx <= (dpu_wfi_req | dpu_wfe_req) | (in_wfx & ~gov_wfx_wake & reset_n);



  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_wfx_wake       => in_wfx & in_wfx@1 & ~gov_wfx_drain_req")
  u_ovl_intf_assume_7a4dda317042f93048722ff076c54f35939f8004 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_wfx_wake      ),
    .consequent_expr (in_wfx & in_wfx_reg & ~gov_wfx_drain_req));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_wfx_drain_req  => in_wfx & in_wfx@1 & ~gov_wfx_wake")
  u_ovl_intf_assume_1def61079e64108727bc7dd8b1e2210878d295b2 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_wfx_drain_req ),
    .consequent_expr (in_wfx & in_wfx_reg & ~gov_wfx_wake));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_wfx  => ~dpu_wfi_req")
  u_ovl_intf_assert_cb643244484fb7d29dff54fbc4051f465fae58b9 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (in_wfx ),
    .consequent_expr (~dpu_wfi_req));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "in_wfx  => ~dpu_wfe_req")
  u_ovl_intf_assert_d6d51ac59614ece8868b6b3e4fccf408d236aaff (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (in_wfx ),
    .consequent_expr (~dpu_wfe_req));



  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // gov_stall_neon must be low for the first few cycles out of reset to allow the DPU logic to stabilise

  assert_implication #(`OVL_FATAL, INOPTIONS, "~out_of_reset | ~out_of_reset@1 | ~out_of_reset@2  => ~gov_stall_neon")
  u_ovl_intf_assume_2605648bfe644e4854cbdde7ebc417cca0f3d0b6 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (~out_of_reset | ~out_of_reset_reg | ~out_of_reset_reg_reg ),
    .consequent_expr (~gov_stall_neon));


  // gov_int_active should be set if any interrupts are asserted

  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_sei_level_req   => gov_int_active")
  u_ovl_intf_assume_8bcc1b9aca76092fd13ae72ade47698db67de8ab (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_sei_level_req  ),
    .consequent_expr (gov_int_active));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_vsei_level_req  => gov_int_active")
  u_ovl_intf_assume_95c8a7882e821a423124d31e4b6f84bacb91965f (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_vsei_level_req ),
    .consequent_expr (gov_int_active));


  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_rei_level_req   => gov_int_active")
  u_ovl_intf_assume_b92e4dc3114669616976944b2666595f4b3b15e5 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_rei_level_req  ),
    .consequent_expr (gov_int_active));




endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_gov_defs.v"
`undef CA53_UNDEFINE

`endif

