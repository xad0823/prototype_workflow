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

// This is the specification for the interface between the IFU and DPU

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_ifu_defs.v"
`include "cortexa53params.v"

module ca53_dpu_ifu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input  [47:0] ifu_instr0_if3_i,
  input  [47:0] ifu_instr1_if3_i,
  input   [1:0] ifu_instr_valid_if3_i,
  input         ifu_early_two_valid_if3_i,
  input  [48:0] ifu_pred_addr_if4_i,
  input         ifu_pred_addr_valid_if4_i,
  input  [31:1] ifu_ifar_i,
  input   [6:0] ifu_ifsr_i,
  input   [1:0] ifu_ifsr_stage2_i,
  input         ifu_ifsr_lpae_i,
  input  [27:0] ifu_hpfar_i,
  input         ifu_evnt_ic_lf_i,
  input         ifu_evnt_ic_access_i,
  input         ifu_evnt_ic_miss_wait_i,
  input         ifu_evnt_iutlb_miss_wait_i,
  input         ifu_evnt_pdc_valid_i,
  input         ifu_evnt_throttle_i,
  input         ifu_dbg_ready_i,
  input         ifu_pty_valid_i,
  input         ifu_pty_ramid_i,
  input         ifu_pty_way_bank_id_i,
  input  [11:0] ifu_pty_index_i,
  input         tlb_lpae_mode_i,
  input         dpu_iq_full_i,
  input         dpu_iq_part_full_i,
  input         dpu_fe_valid_wr_i,
  input  [48:1] dpu_fe_addr_opa_wr_i,
  input  [27:1] dpu_fe_addr_opb_wr_i,
  input   [1:0] dpu_fe_isa_wr_i,
  input         dpu_pred_br_ex2_i,
  input  [12:3] dpu_br_addr_ex2_i,
  input         dpu_pred_br_wr_i,
  input         dpu_mispred_wr_i,
  input         dpu_br_taken_wr_i,
  input         dpu_br_return_wr_i,
  input         dpu_br_call_wr_i,
  input         dpu_fe_valid_ret_i,
  input  [63:0] dpu_fe_addr_opa_ret_i,
  input  [17:1] dpu_fe_addr_opb_ret_i,
  input   [1:0] dpu_fe_isa_ret_i,
  input   [7:0] dpu_fe_itstate_ret_i,
  input         dpu_fe_context_sync_ret_i,
  input         dpu_btac_ret_i,
  input         dpu_halt_ifu_i,
  input         dpu_mmu_on_i,
  input         dpu_ipa_to_pa_en_i,
  input   [1:0] dpu_exception_level_i,
  input   [3:1] dpu_aarch64_at_el_i,
  input         dpu_flush_i_utlb_i,
  input         dpu_sif_only_i,
  input  [31:0] dpu_dacr_i,
  input         dpu_sctlr_itd_i,
  input         dpu_throttle_enable_i,
  input         dpu_ns_state_i,
  input         dpu_default_cacheable_i,
  input         dpu_icache_on_i,
  input         dpu_dbg_valid_i,
  input         dpu_kill_wr_i,
  input  [31:0] dpu_dbg_ins_i,
  input         dpu_reset_catch_pending_i,
  input         dpu_expt_catch_pending_i);


  wire  [47:0] ifu_instr0_if3 = ifu_instr0_if3_i;
  wire  [47:0] ifu_instr1_if3 = ifu_instr1_if3_i;
  wire   [1:0] ifu_instr_valid_if3 = ifu_instr_valid_if3_i;
  wire         ifu_early_two_valid_if3 = ifu_early_two_valid_if3_i;
  wire  [48:0] ifu_pred_addr_if4 = ifu_pred_addr_if4_i;
  wire         ifu_pred_addr_valid_if4 = ifu_pred_addr_valid_if4_i;
  wire  [31:1] ifu_ifar = ifu_ifar_i;
  wire   [6:0] ifu_ifsr = ifu_ifsr_i;
  wire   [1:0] ifu_ifsr_stage2 = ifu_ifsr_stage2_i;
  wire         ifu_ifsr_lpae = ifu_ifsr_lpae_i;
  wire  [27:0] ifu_hpfar = ifu_hpfar_i;
  wire         ifu_evnt_ic_lf = ifu_evnt_ic_lf_i;
  wire         ifu_evnt_ic_access = ifu_evnt_ic_access_i;
  wire         ifu_evnt_ic_miss_wait = ifu_evnt_ic_miss_wait_i;
  wire         ifu_evnt_iutlb_miss_wait = ifu_evnt_iutlb_miss_wait_i;
  wire         ifu_evnt_pdc_valid = ifu_evnt_pdc_valid_i;
  wire         ifu_evnt_throttle = ifu_evnt_throttle_i;
  wire         ifu_dbg_ready = ifu_dbg_ready_i;
  wire         ifu_pty_valid = ifu_pty_valid_i;
  wire         ifu_pty_ramid = ifu_pty_ramid_i;
  wire         ifu_pty_way_bank_id = ifu_pty_way_bank_id_i;
  wire  [11:0] ifu_pty_index = ifu_pty_index_i;
  wire         tlb_lpae_mode = tlb_lpae_mode_i;
  wire         dpu_iq_full = dpu_iq_full_i;
  wire         dpu_iq_part_full = dpu_iq_part_full_i;
  wire         dpu_fe_valid_wr = dpu_fe_valid_wr_i;
  wire  [48:1] dpu_fe_addr_opa_wr = dpu_fe_addr_opa_wr_i;
  wire  [27:1] dpu_fe_addr_opb_wr = dpu_fe_addr_opb_wr_i;
  wire   [1:0] dpu_fe_isa_wr = dpu_fe_isa_wr_i;
  wire         dpu_pred_br_ex2 = dpu_pred_br_ex2_i;
  wire  [12:3] dpu_br_addr_ex2 = dpu_br_addr_ex2_i;
  wire         dpu_pred_br_wr = dpu_pred_br_wr_i;
  wire         dpu_mispred_wr = dpu_mispred_wr_i;
  wire         dpu_br_taken_wr = dpu_br_taken_wr_i;
  wire         dpu_br_return_wr = dpu_br_return_wr_i;
  wire         dpu_br_call_wr = dpu_br_call_wr_i;
  wire         dpu_fe_valid_ret = dpu_fe_valid_ret_i;
  wire  [63:0] dpu_fe_addr_opa_ret = dpu_fe_addr_opa_ret_i;
  wire  [17:1] dpu_fe_addr_opb_ret = dpu_fe_addr_opb_ret_i;
  wire   [1:0] dpu_fe_isa_ret = dpu_fe_isa_ret_i;
  wire   [7:0] dpu_fe_itstate_ret = dpu_fe_itstate_ret_i;
  wire         dpu_fe_context_sync_ret = dpu_fe_context_sync_ret_i;
  wire         dpu_btac_ret = dpu_btac_ret_i;
  wire         dpu_halt_ifu = dpu_halt_ifu_i;
  wire         dpu_mmu_on = dpu_mmu_on_i;
  wire         dpu_ipa_to_pa_en = dpu_ipa_to_pa_en_i;
  wire   [1:0] dpu_exception_level = dpu_exception_level_i;
  wire   [3:1] dpu_aarch64_at_el = dpu_aarch64_at_el_i;
  wire         dpu_flush_i_utlb = dpu_flush_i_utlb_i;
  wire         dpu_sif_only = dpu_sif_only_i;
  wire  [31:0] dpu_dacr = dpu_dacr_i;
  wire         dpu_sctlr_itd = dpu_sctlr_itd_i;
  wire         dpu_throttle_enable = dpu_throttle_enable_i;
  wire         dpu_ns_state = dpu_ns_state_i;
  wire         dpu_default_cacheable = dpu_default_cacheable_i;
  wire         dpu_icache_on = dpu_icache_on_i;
  wire         dpu_dbg_valid = dpu_dbg_valid_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire  [31:0] dpu_dbg_ins = dpu_dbg_ins_i;
  wire         dpu_reset_catch_pending = dpu_reset_catch_pending_i;
  wire         dpu_expt_catch_pending = dpu_expt_catch_pending_i;

  wire         dpu_force;
  wire         el_change;
  wire         i0_abort;
  wire         i0_parity;
  wire         valid_abort;
  wire         i0_expt_catch;
  wire         i0_bkpt;
  wire         initialize_ifar;

  reg         under_parity;
  reg         ifu_fetching;
  reg         first_force_seen;
  reg         abort_in_flight;
  reg         ovl_in_debug_state;
  reg         dbg_instr_in_flight;
  reg         ifu_ifar_held_reset_n;
  reg         initialization_done;
  reg         first_instr_seen;
  reg         dpu_alive;
  reg         instr_since_last_addr;
  reg         ovl_in_wfx;

  reg         dpu_flush_i_utlb_reg;
  reg         dpu_sctlr_itd_reg;
  reg   [6:0] ifu_ifsr_reg;
  reg         dpu_dbg_valid_reg;
  reg         dpu_dbg_valid_reg_reg;
  reg         dpu_icache_on_reg;
  reg   [3:1] dpu_aarch64_at_el_reg;
  reg  [27:0] ifu_hpfar_reg;
  reg   [1:0] ifu_ifsr_stage2_reg;
  reg         ifu_ifsr_lpae_reg;
  reg         dpu_default_cacheable_reg;
  reg         dpu_expt_catch_pending_reg;
  reg         el_change_reg;
  reg         dpu_reset_catch_pending_reg;
  reg  [31:1] ifu_ifar_reg;
  reg         dpu_sif_only_reg;
  reg         dpu_pred_br_ex2_reg;
  reg         ifu_dbg_ready_reg;
  reg         dpu_fe_valid_wr_reg;
  reg         abort_in_flight_reg;
  reg         valid_abort_reg;
  reg         dpu_halt_ifu_reg;
  reg         ovl_in_debug_state_reg;
  reg   [1:0] ifu_instr_valid_if3_reg;
  reg         dpu_ns_state_reg;
  reg         dpu_fe_valid_ret_reg;
  reg   [1:0] dpu_exception_level_reg;
  reg         dpu_iq_full_reg;
  reg         ifu_pred_addr_valid_if4_reg;
  reg         tlb_lpae_mode_reg;
  reg         dpu_iq_part_full_reg;
  reg  [31:0] dpu_dacr_reg;
  reg         dpu_mmu_on_reg;
  reg         dpu_ipa_to_pa_en_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dpu_flush_i_utlb_reg <= 1'b0;
    dpu_sctlr_itd_reg <= 1'b0;
    ifu_ifsr_reg <= {7{1'b0}};
    dpu_dbg_valid_reg <= 1'b0;
    dpu_dbg_valid_reg_reg <= 1'b0;
    dpu_icache_on_reg <= 1'b0;
    dpu_aarch64_at_el_reg <= 3'b000;
    ifu_hpfar_reg <= {28{1'b0}};
    ifu_ifsr_stage2_reg <= 2'b00;
    ifu_ifsr_lpae_reg <= 1'b0;
    dpu_default_cacheable_reg <= 1'b0;
    dpu_expt_catch_pending_reg <= 1'b0;
    el_change_reg <= 1'b0;
    dpu_reset_catch_pending_reg <= 1'b0;
    ifu_ifar_reg <= {31{1'b0}};
    dpu_sif_only_reg <= 1'b0;
    dpu_pred_br_ex2_reg <= 1'b0;
    ifu_dbg_ready_reg <= 1'b0;
    dpu_fe_valid_wr_reg <= 1'b0;
    abort_in_flight_reg <= 1'b0;
    valid_abort_reg <= 1'b0;
    dpu_halt_ifu_reg <= 1'b0;
    ovl_in_debug_state_reg <= 1'b0;
    ifu_instr_valid_if3_reg <= 2'b00;
    dpu_ns_state_reg <= 1'b0;
    dpu_fe_valid_ret_reg <= 1'b0;
    dpu_exception_level_reg <= 2'b00;
    dpu_iq_full_reg <= 1'b0;
    ifu_pred_addr_valid_if4_reg <= 1'b0;
    tlb_lpae_mode_reg <= 1'b0;
    dpu_iq_part_full_reg <= 1'b0;
    dpu_dacr_reg <= {32{1'b0}};
    dpu_mmu_on_reg <= 1'b0;
    dpu_ipa_to_pa_en_reg <= 1'b0;
  end
  else
  begin
    ifu_instr_valid_if3_reg <= ifu_instr_valid_if3;
    ifu_pred_addr_valid_if4_reg <= ifu_pred_addr_valid_if4;
    ifu_ifar_reg <= ifu_ifar;
    ifu_ifsr_reg <= ifu_ifsr;
    ifu_ifsr_stage2_reg <= ifu_ifsr_stage2;
    ifu_ifsr_lpae_reg <= ifu_ifsr_lpae;
    ifu_hpfar_reg <= ifu_hpfar;
    ifu_dbg_ready_reg <= ifu_dbg_ready;
    tlb_lpae_mode_reg <= tlb_lpae_mode;
    dpu_iq_full_reg <= dpu_iq_full;
    dpu_iq_part_full_reg <= dpu_iq_part_full;
    dpu_fe_valid_wr_reg <= dpu_fe_valid_wr;
    dpu_pred_br_ex2_reg <= dpu_pred_br_ex2;
    dpu_fe_valid_ret_reg <= dpu_fe_valid_ret;
    dpu_halt_ifu_reg <= dpu_halt_ifu;
    dpu_mmu_on_reg <= dpu_mmu_on;
    dpu_ipa_to_pa_en_reg <= dpu_ipa_to_pa_en;
    dpu_exception_level_reg <= dpu_exception_level;
    dpu_aarch64_at_el_reg <= dpu_aarch64_at_el;
    dpu_flush_i_utlb_reg <= dpu_flush_i_utlb;
    dpu_sif_only_reg <= dpu_sif_only;
    dpu_dacr_reg <= dpu_dacr;
    dpu_sctlr_itd_reg <= dpu_sctlr_itd;
    dpu_ns_state_reg <= dpu_ns_state;
    dpu_default_cacheable_reg <= dpu_default_cacheable;
    dpu_icache_on_reg <= dpu_icache_on;
    dpu_dbg_valid_reg <= dpu_dbg_valid;
    dpu_dbg_valid_reg_reg <= dpu_dbg_valid_reg;
    dpu_reset_catch_pending_reg <= dpu_reset_catch_pending;
    dpu_expt_catch_pending_reg <= dpu_expt_catch_pending;
    el_change_reg <= el_change;
    abort_in_flight_reg <= abort_in_flight;
    valid_abort_reg <= valid_abort;
    ovl_in_debug_state_reg <= ovl_in_debug_state;
  end



  // Any DPU outputs initialized by the reset FSM rather than by reset itself
  // will not be valid for the 1st two cycles after reset has been deasserted

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    initialization_done <= 1'b0;
  else
    initialization_done <= 1'b1;


  // ifu_ifar will be x out of reset until first instruction is passed to DPU

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ifu_ifar_held_reset_n <= 1'b0;
  else if (|ifu_instr_valid_if3)
    ifu_ifar_held_reset_n <= 1'b1;


  assign initialize_ifar  = ifu_ifar_held_reset_n | (|ifu_instr_valid_if3);

  // Import the tlb_lpae_mode signal to qualify the DACR

  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------
  // Inputs to the DPU from the IFU
  //  input [47:0]  ifu_instr0_if3              valid ifu_instr_valid_if3[0]                 timing 70%

  assert_never_unknown #(`OVL_FATAL, 48, INOPTIONS, "ifu_instr0_if3 X or Z")
  u_ovl_intf_x_ifu_instr0_if3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_instr_valid_if3[0]),
    .test_expr (ifu_instr0_if3));

  //  input [47:0]  ifu_instr1_if3              valid ifu_instr_valid_if3[1]                 timing 70%

  assert_never_unknown #(`OVL_FATAL, 48, INOPTIONS, "ifu_instr1_if3 X or Z")
  u_ovl_intf_x_ifu_instr1_if3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_instr_valid_if3[1]),
    .test_expr (ifu_instr1_if3));

  //  input [1:0]   ifu_instr_valid_if3         valid always                                 timing 65%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ifu_instr_valid_if3 X or Z")
  u_ovl_intf_x_ifu_instr_valid_if3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_instr_valid_if3));

  //  input         ifu_early_two_valid_if3     valid ifu_instr_valid_if3[0]                 timing 65%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_early_two_valid_if3 X or Z")
  u_ovl_intf_x_ifu_early_two_valid_if3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_instr_valid_if3[0]),
    .test_expr (ifu_early_two_valid_if3));

  //  input [48:0]  ifu_pred_addr_if4           valid ifu_pred_addr_valid_if4                timing 75%

  assert_never_unknown #(`OVL_FATAL, 49, INOPTIONS, "ifu_pred_addr_if4 X or Z")
  u_ovl_intf_x_ifu_pred_addr_if4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_pred_addr_valid_if4),
    .test_expr (ifu_pred_addr_if4));

  //  input         ifu_pred_addr_valid_if4     valid always                                 timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_pred_addr_valid_if4 X or Z")
  u_ovl_intf_x_ifu_pred_addr_valid_if4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_pred_addr_valid_if4));

  //  input [31:1]  ifu_ifar                    valid initialize_ifar                        timing 60%

  assert_never_unknown #(`OVL_FATAL, 31, INOPTIONS, "ifu_ifar X or Z")
  u_ovl_intf_x_ifu_ifar (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (initialize_ifar),
    .test_expr (ifu_ifar));

  //  input [6:0]   ifu_ifsr                    valid always                                 timing 40%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ifu_ifsr X or Z")
  u_ovl_intf_x_ifu_ifsr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_ifsr));

  //  input [1:0]   ifu_ifsr_stage2             valid always                                 timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ifu_ifsr_stage2 X or Z")
  u_ovl_intf_x_ifu_ifsr_stage2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_ifsr_stage2));

  //  input         ifu_ifsr_lpae               valid always                                 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_ifsr_lpae X or Z")
  u_ovl_intf_x_ifu_ifsr_lpae (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_ifsr_lpae));

  //  input [27:0]  ifu_hpfar                   valid ifu_ifsr_stage2[1] & dpu_fe_valid_ret  timing 40%

  assert_never_unknown #(`OVL_FATAL, 28, INOPTIONS, "ifu_hpfar X or Z")
  u_ovl_intf_x_ifu_hpfar (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_ifsr_stage2[1] & dpu_fe_valid_ret),
    .test_expr (ifu_hpfar));

  //  input         ifu_evnt_ic_lf              valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_ic_lf X or Z")
  u_ovl_intf_x_ifu_evnt_ic_lf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_ic_lf));

  //  input         ifu_evnt_ic_access          valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_ic_access X or Z")
  u_ovl_intf_x_ifu_evnt_ic_access (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_ic_access));

  //  input         ifu_evnt_ic_miss_wait       valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_ic_miss_wait X or Z")
  u_ovl_intf_x_ifu_evnt_ic_miss_wait (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_ic_miss_wait));

  //  input         ifu_evnt_iutlb_miss_wait    valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_iutlb_miss_wait X or Z")
  u_ovl_intf_x_ifu_evnt_iutlb_miss_wait (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_iutlb_miss_wait));

  //  input         ifu_evnt_pdc_valid          valid always                                 timing 25%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_pdc_valid X or Z")
  u_ovl_intf_x_ifu_evnt_pdc_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_pdc_valid));

  //  input         ifu_evnt_throttle           valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_evnt_throttle X or Z")
  u_ovl_intf_x_ifu_evnt_throttle (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_evnt_throttle));

  //  input         ifu_dbg_ready               valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_dbg_ready X or Z")
  u_ovl_intf_x_ifu_dbg_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_dbg_ready));

  //  input         ifu_pty_valid               valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_pty_valid X or Z")
  u_ovl_intf_x_ifu_pty_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_pty_valid));

  //  input         ifu_pty_ramid               valid ifu_pty_valid                          timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_pty_ramid X or Z")
  u_ovl_intf_x_ifu_pty_ramid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_pty_valid),
    .test_expr (ifu_pty_ramid));

  //  input         ifu_pty_way_bank_id         valid ifu_pty_valid                          timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_pty_way_bank_id X or Z")
  u_ovl_intf_x_ifu_pty_way_bank_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_pty_valid),
    .test_expr (ifu_pty_way_bank_id));

  //  input [11:0]  ifu_pty_index               valid ifu_pty_valid                          timing 50%

  assert_never_unknown #(`OVL_FATAL, 12, INOPTIONS, "ifu_pty_index X or Z")
  u_ovl_intf_x_ifu_pty_index (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_pty_valid),
    .test_expr (ifu_pty_index));

  // Outputs from the DPU to the IFU
  //  output        dpu_iq_full                 valid always                                 timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_iq_full X or Z")
  u_ovl_intf_x_dpu_iq_full (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_iq_full));

  //  output        dpu_iq_part_full            valid always                                 timing 45%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_iq_part_full X or Z")
  u_ovl_intf_x_dpu_iq_part_full (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_iq_part_full));

  //  output        dpu_fe_valid_wr             valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_fe_valid_wr X or Z")
  u_ovl_intf_x_dpu_fe_valid_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_fe_valid_wr));

  //  output [48:1] dpu_fe_addr_opa_wr          valid dpu_fe_valid_wr                        timing 50%

  assert_never_unknown #(`OVL_FATAL, 48, OUTOPTIONS, "dpu_fe_addr_opa_wr X or Z")
  u_ovl_intf_x_dpu_fe_addr_opa_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_wr),
    .test_expr (dpu_fe_addr_opa_wr));

  //  output [27:1] dpu_fe_addr_opb_wr          valid dpu_fe_valid_wr & ~dpu_halt_ifu        timing 50%

  assert_never_unknown #(`OVL_FATAL, 27, OUTOPTIONS, "dpu_fe_addr_opb_wr X or Z")
  u_ovl_intf_x_dpu_fe_addr_opb_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_wr & ~dpu_halt_ifu),
    .test_expr (dpu_fe_addr_opb_wr));

  //  output [1:0]  dpu_fe_isa_wr               valid dpu_fe_valid_wr                        timing 65%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_fe_isa_wr X or Z")
  u_ovl_intf_x_dpu_fe_isa_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_wr),
    .test_expr (dpu_fe_isa_wr));

  //  output        dpu_pred_br_ex2             valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pred_br_ex2 X or Z")
  u_ovl_intf_x_dpu_pred_br_ex2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_pred_br_ex2));

  //  output [12:3] dpu_br_addr_ex2             valid dpu_pred_br_ex2                        timing 50%

  assert_never_unknown #(`OVL_FATAL, 10, OUTOPTIONS, "dpu_br_addr_ex2 X or Z")
  u_ovl_intf_x_dpu_br_addr_ex2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_pred_br_ex2),
    .test_expr (dpu_br_addr_ex2));

  //  output        dpu_pred_br_wr              valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_pred_br_wr X or Z")
  u_ovl_intf_x_dpu_pred_br_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_pred_br_wr));

  //  output        dpu_mispred_wr              valid dpu_pred_br_wr                         timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mispred_wr X or Z")
  u_ovl_intf_x_dpu_mispred_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_pred_br_wr),
    .test_expr (dpu_mispred_wr));

  //  output        dpu_br_taken_wr             valid dpu_pred_br_wr                         timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_br_taken_wr X or Z")
  u_ovl_intf_x_dpu_br_taken_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_pred_br_wr),
    .test_expr (dpu_br_taken_wr));

  //  output        dpu_br_return_wr            valid dpu_pred_br_wr                         timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_br_return_wr X or Z")
  u_ovl_intf_x_dpu_br_return_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_pred_br_wr),
    .test_expr (dpu_br_return_wr));

  //  output        dpu_br_call_wr              valid dpu_pred_br_wr                         timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_br_call_wr X or Z")
  u_ovl_intf_x_dpu_br_call_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_pred_br_wr),
    .test_expr (dpu_br_call_wr));

  //  output        dpu_fe_valid_ret            valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_fe_valid_ret X or Z")
  u_ovl_intf_x_dpu_fe_valid_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_fe_valid_ret));

  //  output [63:0] dpu_fe_addr_opa_ret         valid dpu_fe_valid_ret                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "dpu_fe_addr_opa_ret X or Z")
  u_ovl_intf_x_dpu_fe_addr_opa_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_ret),
    .test_expr (dpu_fe_addr_opa_ret));

  //  output [17:1] dpu_fe_addr_opb_ret         valid dpu_fe_valid_ret                       timing 50%

  assert_never_unknown #(`OVL_FATAL, 17, OUTOPTIONS, "dpu_fe_addr_opb_ret X or Z")
  u_ovl_intf_x_dpu_fe_addr_opb_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_ret),
    .test_expr (dpu_fe_addr_opb_ret));

  //  output [1:0]  dpu_fe_isa_ret              valid dpu_fe_valid_ret                       timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_fe_isa_ret X or Z")
  u_ovl_intf_x_dpu_fe_isa_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_ret),
    .test_expr (dpu_fe_isa_ret));

  //  output [7:0]  dpu_fe_itstate_ret          valid dpu_fe_valid_ret                       timing 60%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dpu_fe_itstate_ret X or Z")
  u_ovl_intf_x_dpu_fe_itstate_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_ret),
    .test_expr (dpu_fe_itstate_ret));

  //  output        dpu_fe_context_sync_ret     valid dpu_fe_valid_ret                       timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_fe_context_sync_ret X or Z")
  u_ovl_intf_x_dpu_fe_context_sync_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_ret),
    .test_expr (dpu_fe_context_sync_ret));

  //  output        dpu_btac_ret                valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_btac_ret X or Z")
  u_ovl_intf_x_dpu_btac_ret (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_btac_ret));

  //  output        dpu_halt_ifu                valid dpu_fe_valid_wr | dpu_fe_valid_ret     timing 25%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_halt_ifu X or Z")
  u_ovl_intf_x_dpu_halt_ifu (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_fe_valid_wr | dpu_fe_valid_ret),
    .test_expr (dpu_halt_ifu));

  //  output        dpu_mmu_on                  valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_mmu_on X or Z")
  u_ovl_intf_x_dpu_mmu_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_mmu_on));

  //  output        dpu_ipa_to_pa_en            valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ipa_to_pa_en X or Z")
  u_ovl_intf_x_dpu_ipa_to_pa_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ipa_to_pa_en));

  //  output [1:0]  dpu_exception_level         valid always                                 timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_exception_level X or Z")
  u_ovl_intf_x_dpu_exception_level (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_exception_level));

  //  output [3:1]  dpu_aarch64_at_el           valid always                                 timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_aarch64_at_el X or Z")
  u_ovl_intf_x_dpu_aarch64_at_el (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_aarch64_at_el));

  //  output        dpu_flush_i_utlb            valid always                                 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_flush_i_utlb X or Z")
  u_ovl_intf_x_dpu_flush_i_utlb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_flush_i_utlb));

  //  output        dpu_sif_only                valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sif_only X or Z")
  u_ovl_intf_x_dpu_sif_only (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sif_only));

  //  output [31:0] dpu_dacr                    valid dpu_mmu_on & ~tlb_lpae_mode@1          timing 50%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "dpu_dacr X or Z")
  u_ovl_intf_x_dpu_dacr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_mmu_on & ~tlb_lpae_mode_reg),
    .test_expr (dpu_dacr));

  //  output        dpu_sctlr_itd               valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_sctlr_itd X or Z")
  u_ovl_intf_x_dpu_sctlr_itd (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_sctlr_itd));

  //  output        dpu_throttle_enable         valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_throttle_enable X or Z")
  u_ovl_intf_x_dpu_throttle_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_throttle_enable));

  //  output        dpu_ns_state                valid always                                 timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_ns_state X or Z")
  u_ovl_intf_x_dpu_ns_state (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ns_state));

  //  output        dpu_default_cacheable       valid always                                 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_default_cacheable X or Z")
  u_ovl_intf_x_dpu_default_cacheable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_default_cacheable));

  //  output        dpu_icache_on               valid always                                 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_icache_on X or Z")
  u_ovl_intf_x_dpu_icache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_icache_on));

  //  output        dpu_dbg_valid               valid always                                 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_dbg_valid X or Z")
  u_ovl_intf_x_dpu_dbg_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dbg_valid));

  //  output        dpu_kill_wr                 valid always                                 timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_kill_wr X or Z")
  u_ovl_intf_x_dpu_kill_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_kill_wr));

  //  output [31:0] dpu_dbg_ins                 valid dpu_dbg_valid                          timing 20%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "dpu_dbg_ins X or Z")
  u_ovl_intf_x_dpu_dbg_ins (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dpu_dbg_valid),
    .test_expr (dpu_dbg_ins));

  //  output        dpu_reset_catch_pending     valid always                                 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_reset_catch_pending X or Z")
  u_ovl_intf_x_dpu_reset_catch_pending (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_reset_catch_pending));

  //  output        dpu_expt_catch_pending      valid always                                 timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_expt_catch_pending X or Z")
  u_ovl_intf_x_dpu_expt_catch_pending (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_expt_catch_pending));


  // ------------------------------------------------------
  // Interface description
  // ------------------------------------------------------

  // dpu_iq_full:
  // When the instruction queue in the DPU only either has zero spare
  // slots or only one spare slot it signals the IFU that it can no
  // longer accept any more instructions.  While it would be possible
  // to signal 'nearly full' and push one more instruction from the
  // IFU, in practice this would cause increased toggling in the IFU
  // instruction muxes thereby consuming more power, yet no
  // performance benefit would be noticed as the IQ has enough entries
  // to decouple the DPU from small fetch variations from the IFU.

  // dpu_iq_part_full:
  // The DPU IQ is part full so an entry should not be allocated to
  // the BTIC.

  // dpu_fe_valid_wr:
  // Indicates to the IFU that there is a new fetch address from a
  // direct branch that was mispredicted or a direction mispredict for
  // a return that was predicted taken.
  //
  // Also used to indicate that the IFU must go into WFI halt state.
  //
  // This signal should only be asserted by the DPU for one cycle.
  //
  // If a force is also being signalled from the Ret stage the Wr
  // stage signals are suppressed.

  // dpu_fe_addr_opa_wr:
  // The 'a' operand for the force signalled by dpu_fe_valid_wr.
  // This bus goes directly to the AGU 'a' operand mux.

  // dpu_fe_addr_opb_wr:
  // The 'b' operand for the force signalled by dpu_fe_valid_wr.
  // This bus goes directly to the AGU 'b' operand mux.
  // Note that valid condition needs to be more precise to prevent
  // false positives due to absence of pipelining for WFx force.

  // dpu_fe_isa_wr:
  // Valid CPSR bits from the DPU Wr stage to be used by the IFU in
  // the case of a direct branch mispredict or a direction mispredict
  // on a return.  This bus is only valid when the dpu_fe_valid_wr
  // signal is asserted.  The bus is encoded as:
  //
  // 2'b00 => a32; 2'b01 => t32, 2'b10 => a64

  // dpu_brn_addr_wr:
  // Provides the Wr stage instruction address.  This is used in the
  // branch predictor as an index into the prediction tables.

  // dpu_pred_br_ex2:
  // The branch in Ex2 stage of the DPU that was predicted by the IFU.
  // It is used to read the prediction registers in the IFU a cycle 
  // before they are updated in the Wr stage. The Ex2 could stall in front
  // of Wr. The Ex2 could be high while a branch ahead is in Wr.  

  // dpu_pred_br_wr:
  // The branch in the Wr stage of the DPU was predicted by the IFU.
  // This is figured out in the DPU De stage as it is exactly known
  // what branch instructions the IFU can predict and what it can
  // not.

  // dpu_mispred_wr:
  // The direction of the branch in the Wr stage that was predicted by
  // the IFU was incorrect.

  // dpu_br_taken_wr:
  // Indicates the actual outcome of the branch in Wr (analogous to
  // condition code pass).  This will be asserted regardless of whether
  // the branch was predicted or not.

  // dpu_br_return_wr:
  // Indicates that the branch in the Wr stage is for a return
  // instruction.  The IFU uses this signal to commit pointers in its
  // call/return stack.

  // dpu_br_call_wr:
  // Indicates that the branch in the Wr stage is for a call
  // instruction.  The IFU uses this signal to commit pointers in its
  // call/return stack.

  // dpu_fe_valid_ret:
  // Indicates to the IFU that there is a new fetch address from an
  // indirect branch that was mispredicted.  This signal is also
  // asserted after a reset or an exception.

  // dpu_fe_addr_opa_ret:
  // The 'a' operand for the force signalled by dpu_fe_valid_ret.
  // This bus goes directly to the AGU 'a' operand mux.

  // dpu_fe_addr_opb_ret:
  // The 'b' operand for the force signalled by dpu_fe_valid_ret.
  // This bus goes directly to the AGU 'b' operand mux.

  // dpu_fe_isa_ret:
  // Valid CPSR bits from the DPU Ret stage to be used by the IFU in
  // the case of a indirect branch.This bus is only valid when the
  // dpu_fe_valid_ret signal is asserted.  The bus is encoded as:
  //
  // 2'b00 => a32; 2'b01 => t32, 2'b10 => a64

  // dpu_fe_itstate_ret:
  // Valid CPSR bits from the DPU Ret stage to be used by the IFU in
  // the case of a indirect branch.This bus is only valid when the
  // dpu_fe_valid_ret signal is asserted.  The bus is encoded as:
  //
  // dpu_fe_itstate_ret[7:4] = IT condition
  // dpu_fe_itstate_ret[3:0] = IT mask

  // dpu_btac_ret:
  // Indicates that a BTAC'able instruction has reached the Ret stage
  // and if necessary the IFU BTAC should be updated.

  // dpu_halt_ifu:
  // Indicates to the IFU that it should stop fetching.  This signal
  // is asserted either by the debug logic or by the WFI logic in the
  // DPU.

  // dpu_mmu_on:
  // Indicates that the MMU is on according to the DPU system control
  // registers.

  // dpu_ipa_to_pa_en:
  // Indicates that the second stage of translation is enabled in the
  // hypervisor which allows branch prediction to occur while the MMU
  // is off.

  // dpu_exception_level:
  // The exception level of the processor.  This is registered in the
  // IFU on the if1/if2 boundary and used to indicate the mode in
  // which a fetch was requested.
  // 2'b00 => EL0 Applications
  // 2'b01 => EL1 OS Kernel and associated functions that are typically described as "privileged"
  // 2'b10 => EL2 Hypervisor
  // 2'b11 => EL3 Security Monitor  

  // dpu_flush_i_utlb:
  // If the exception level changes or if certain bits in the CP15
  // registers are changed (e.g. MMU on, ICache on) then the micro-TLBs
  // are flushed on the DSide and ISide.

  // dpu_sif_only:
  // Indicates that the processor is in secure state (either ns_scr is
  // clear or in monitor mode) and the CP15 SCR Secure Instruction
  // Fetch bit is set.  This signal will never be set if the processor
  // is in non-secure state.  When set the IFU must take a fetch abort
  // rather than fetch from non-secure regions of memory as marked by
  // the micro-TLB entry.

  // dpu_dacr:
  // The contents of the CP15 DACR register for the current security state.
  // The DACR can change on the cycle after a micro-TLB flush when the
  // security state changes or the cycle of a micro-TLB flush when DACR is
  // written.

  // dpu_dbg_valid:
  // The debug instruction being presented to the IFU from the DPU is valid.

  // dpu_kill_wr
  // The kill signal is used to suppress any local cp15 request

  // dpu_dbg_ins:
  // Debug instruction from the DPU. This is an ARM opcode

  // ifu_instr0_if3:
  // The first instruction of the possible pair.

  // ifu_instr1_if3
  // The second instruction of the possible pair.

  // ifu_instr_valid_if3:
  // Indicates to the DPU how many instructions that the IFU wants to
  // send.  This bus will be fully deasserted if the DPU is signalling
  // that the IQ is full.  This bus can never indicate that there is an
  // invalid instr0 but a valid instr1.  Typically the IFU will try
  // and send two instructions to the DPU, but it can only send
  // predictable branches via instruction-0 which may limit the number
  // of instructions that can be pushed to one on some occasions.

  // ifu_early_two_valid_if3:
  // Indicates to the DPU that two instructions may be pushed this
  // cycle.  This is a power saving signal to better gate the DPU IQ
  // when only one instruction is being sent.  This is because the
  // upper bit of the ifu_instr_valid_if3 bus is too late to be used in
  // clock gating logic.  As such ifu_early_two_valid_if3 will always
  // be asserted if the ifu_instr_valid_if3[1] is set, but not always
  // when the ifu_instr_valid_if3[0] is set.

  // ifu_ifar:
  // Address for the instruction fault address register (IFAR) that
  // provides the virtual address in memory where the abort occured.
  //
  // If the fault was a stage-1 fault (VMSA or LPAE) then this bus
  // carries the virtual address.  If the fault was a stage-2 fault
  // then this bus carries the intermediate physical address in bits
  // 31:4 and zero in bits 3:0.
  //
  // Once an abort has been signalled on the IFU instruction interface
  // the ifu_ifar value should not change until the abort is processed.

  // ifu_ifsr:
  // Information for the instruction fault status register (IFSR) that
  // indicates the type of abort that has occured in the ISide memory
  // system.
  //
  // Once an abort has been signalled on the IFU instruction interface
  // the ifu_ifsr value should not change until the abort is processed.

  // ifu_ifsr_stage2:
  // When the upper bit is set it indicates that the fault status
  // information (and IFAR) are from a stage-2 abort.  When the lower
  // bit is set then it indicates that the stage-2 abort was due to a
  // first stage pagewalk.

  // ifu_ifsr_lpae:
  // When set it indicates that the abort being indicated on the IFU
  // IFSR buses was triggered in lpae_mode.

  // ifu_hpfar:
  // Address for the hypervisor fault address register (HPFAR) that
  // provides the IPA address in memory where the abort occured.

  // icu_evnt_ic_lf
  // Indicates to the DPU event registers that an ICache line fill
  // request was made

  // ifu_evnt_ic_access:
  // An instruction cache access occured that was requested by the
  // IFU.  Used by the event monitors in the DPU.

  // ifu_evnt_ic_miss_wait:
  // An instruction cache miss occurred in the IFU and we're
  // waiting for the L2/DDR to return the instructions.  Used by the
  // event monitors in the DPU.

  // ifu_evnt_iutlb_miss_wait:
  // An instruction micro-TLB miss occurred in the IFU and we're
  // waiting for the main TLB to return the page.  Used by the
  // event monitors in the DPU.

  // ifu_evnt_pdc_valid:
  // A pre-decode error was detected.  Used by the event monitors in
  // the DPU.

  // ifu_evnt_throttle:
  // The IFU has throttled an instruction cache fetch.

  // ifu_dbg_ready:
  // To gain debug entry permission the DPU has to chek that the are no 
  // line fill in progress in the ICU. This is because a debug instruction will
  // follow the same path as a normal instruction within the ICU (predecoders,linefill,pfu)

  // ifu_pty_valid:
  // Indicate that there is a parity error on the L1 instruction cache RAMs
  // to allow the DPU cp15 CPUMERRSR register and events to be updated.
  // This signal must always be valid (never x) and must be one-shot (single-cycle)
  // for each parity error, though it is possible to get back-to-back parity
  // errors. 
  // This signal will not necessary match with a PTY packet sent to the DPU.
  // This signal will be set as soon as the error is seen while the packet could be
  // send to the DPU several cycles later. This signal will always go high on an
  // error while teh packet is only set if a hit is seen. 
  // In case of multiple errors across different RAMS the priority is as follow
  // TAG0 -> TAG1 -> DATA 0 -> DATA 1

  // ifu_pty_ramid:
  // On a valid parity error indicate which RAM produced the error
  // 1'b0 = Instruction Tag RAM
  // 1'b1 = Instruction Data RAM


  // ifu_pty_way_bank_id
  // On a valid parity error indicate which bank of the RAM produced the error
  // 1'b0 = Way-0 (if the error is on the Tag RAM) or Bank-0 (if the error is on the Data RAM)
  // 1'b1 = Way-1 (if the error is on the Tag RAM) or Bank-1 (if the error is on the Data RAM)

  // ifu_pty_index:
  // On a vald parity error indicate the index of the RAM which produced the error.
  // The full bus width is only needed by the Data RAM and only in a 64K instruction
  // cache configuration.  Unused bits should be zero'ed out.  Essentially this bus
  // communicates the unmodified RAM address to allow partners to identify which
  // portion of the RAM has failed.
  // Even though it is called index this is in fact the address, hence a TAG
  // address is from [8:0] and NOT [11:3] as seen in other signals where the 
  // index is required. The DATA will be [11:0] which reppresent the address

  // ------------------------------------------------------
  // Logic for OVLs
  // ------------------------------------------------------


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_in_debug_state <= 1'b0;
  else if (dpu_fe_valid_ret & dpu_alive)
    ovl_in_debug_state <= dpu_halt_ifu;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_in_wfx <= 1'b0;
  else if (dpu_alive & (ovl_in_wfx ? dpu_fe_valid_ret : dpu_fe_valid_wr))
    ovl_in_wfx <= dpu_halt_ifu;


  assign dpu_force  = dpu_fe_valid_ret | dpu_fe_valid_wr;

  // ------------------------------------------------------
  // Interface OVLs (inputs from DPU)
  // ------------------------------------------------------

  // Guidance for OVLs:
  // - When is the signal valid?
  // - When is the signal not valid?
  // - When does the signal change?
  // - When does the signal remain the same?
  // - Can the signal be asserted for consecutive cycles?

  // To prevent the need to reset registers in the RTL simply to get
  // OVLs working correctly after reset we wait until at least one force
  // has been signalled.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dpu_alive <= 1'b0;
  else
    dpu_alive <= dpu_alive | (dpu_fe_valid_ret & ~dpu_halt_ifu);



  // Assertions for dpu_iq_full:
  //
  // The dpu_iq_full signal can only be asserted on the cycle after a push or
  // if the dpu_iq_full signal is currently asserted.
  //
  // The dpu_iq_full signal should never be asserted on the cycle after a flush
  //
  // The dpu_iq_full signal should never be asserted while in debug

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_iq_full  => ifu_instr_valid_if3[0]@1 | ifu_pred_addr_valid_if4@1 | dpu_iq_full@1")
  u_ovl_intf_assert_da2434473714dfc20e72579f36106c5fbcec7e34 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_full ),
    .consequent_expr (ifu_instr_valid_if3_reg[0] | ifu_pred_addr_valid_if4_reg | dpu_iq_full_reg));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_iq_full  => (~(dpu_fe_valid_wr@1 & ~dpu_halt_ifu@1) & ~dpu_fe_valid_ret@1)")
  u_ovl_intf_assert_a40a858e13d01f751d2207996d812ae477f9c7fa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_full ),
    .consequent_expr ((~(dpu_fe_valid_wr_reg & ~dpu_halt_ifu_reg) & ~dpu_fe_valid_ret_reg)));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ovl_in_debug_state  => ~dpu_iq_full")
  u_ovl_intf_assert_b108d4731e85b1be6ced0a3e89a0b7bf334d6f7f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~dpu_iq_full));


  // Asserions for dpu_iq_part_full:
  //
  // The dpu_iq_part_full signal can only be asserted on the cycle after a push or
  // if the dpu_iq_full signal is currently asserted.
  //
  // The dpu_iq_part_full must be set if dpu_iq_full is high
  //
  // The dpu_iq_part_full signal should never be asserted on the cycle after a flush
  //
  // The dpu_iq_part_full signal should never be asserted while in debug

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_iq_part_full  => ifu_instr_valid_if3[0]@1 | ifu_pred_addr_valid_if4@1 | dpu_iq_part_full@1")
  u_ovl_intf_assert_24ae1c8efd5844d3337c2c11a29769dc6188767a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_part_full ),
    .consequent_expr (ifu_instr_valid_if3_reg[0] | ifu_pred_addr_valid_if4_reg | dpu_iq_part_full_reg));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_iq_full  => dpu_iq_part_full")
  u_ovl_intf_assert_6f1962566bace5ec70de0ad635cc1c74800b106f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_full ),
    .consequent_expr (dpu_iq_part_full));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_iq_part_full  => (~(dpu_fe_valid_wr@1 & ~dpu_halt_ifu@1) & ~dpu_fe_valid_ret@1)")
  u_ovl_intf_assert_b94c1bc87767ea4d429461f250f925e4b8dc6ff6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_part_full ),
    .consequent_expr ((~(dpu_fe_valid_wr_reg & ~dpu_halt_ifu_reg) & ~dpu_fe_valid_ret_reg)));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ovl_in_debug_state  => ~dpu_iq_part_full")
  u_ovl_intf_assert_a6aa3f956b55aa2314d495f14afe97857f3dbe1f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~dpu_iq_part_full));


  // Assertions for dpu_fe_valid_wr:
  //
  // The dpu_fe_valid_wr signal should only be asserted for one cycle.
  //
  // The dpu_fe_valid_wr signal should not be asserted the cycle after a force from ret
  //
  // The dpu_fe_valid_wr signal should not be asserted until after the initial dpu_fe_valid_ret
  //
  // The dpu_fe_valid_wr signal should not be asserted once in debug state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_wr@1  => ~dpu_fe_valid_wr")
  u_ovl_intf_assert_4188477d66c197e9d036d3655e2953f3d7317776 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_wr_reg ),
    .consequent_expr (~dpu_fe_valid_wr));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret@1  => ~dpu_fe_valid_wr")
  u_ovl_intf_assert_5b737ce1db2450ea24fee85d14631d98c870f72c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret_reg ),
    .consequent_expr (~dpu_fe_valid_wr));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive == 1'b0  => dpu_fe_valid_wr == 1'b0")
  u_ovl_intf_assert_a904fba5268940c028171bd798de3bbf40b3379b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive == 1'b0 ),
    .consequent_expr (dpu_fe_valid_wr == 1'b0));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ovl_in_debug_state  => ~dpu_fe_valid_wr")
  u_ovl_intf_assert_43483841d235573cc99e7f57a1e82560b0a7733f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~dpu_fe_valid_wr));


  // Create a window which is set after the first force has been seen

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_force_seen <= 1'b0;
  else
    first_force_seen <= first_force_seen | dpu_fe_valid_ret;

  // Can only enter debug after at least one force

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret & dpu_halt_ifu       => first_force_seen")
  u_ovl_intf_assert_cc9b7251412c4f5f30dd76c37b2ae4e4fcbadc92 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret & dpu_halt_ifu      ),
    .consequent_expr (first_force_seen));


  // Create a window which is set after the first instruction has been seen

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_instr_seen <= 1'b0;
  else
    first_instr_seen <= first_instr_seen | ifu_instr_valid_if3[0];

  // Can only see a force from WR after at least one instruction has been seen

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_wr  => first_instr_seen")
  u_ovl_intf_assert_eb81919716ee2511aaed140bd637541fe7813860 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_wr ),
    .consequent_expr (first_instr_seen));



  // Assertions for dpu_fe_addr_opa_wr:
  //
  // In AArch32, must only present 32-bit operands

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_wr & ~dpu_fe_isa_wr[1]  => dpu_fe_addr_opa_wr[48:32] == 17'd0")
  u_ovl_intf_assert_6eb52d66f18bd28d1a962dd9c466f312e06bbb95 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_wr & ~dpu_fe_isa_wr[1] ),
    .consequent_expr (dpu_fe_addr_opa_wr[48:32] == 17'd0));


  // Assertions for dpu_fe_isa_wr:
  //
  // Unknown state must never be indicated

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_wr  => dpu_fe_isa_wr != 2'b11")
  u_ovl_intf_assert_8f3379353dd39f474807d1b5cfe846c186c69db4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_wr ),
    .consequent_expr (dpu_fe_isa_wr != 2'b11));


  // Assertions for dpu_fe_addr_opa_ret:
  //
  // In AArch32, must only present 32-bit operands (Unless in Debug state, when address is ignored)
  // In AArch32, cannot set bit 0 of target address

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret & ~dpu_fe_isa_ret[1] & ~dpu_halt_ifu  => dpu_fe_addr_opa_ret[63:32] == 32'd0")
  u_ovl_intf_assert_4ea035cba52069294c64b04fd065d08c43f04dcc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret & ~dpu_fe_isa_ret[1] & ~dpu_halt_ifu ),
    .consequent_expr (dpu_fe_addr_opa_ret[63:32] == 32'd0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret & ~dpu_fe_isa_ret[1] & ~dpu_halt_ifu  => dpu_fe_addr_opa_ret[ 0]    ==  1'b0")
  u_ovl_intf_assert_4f75a116f710f32e885284f17ab5b889ed07542d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret & ~dpu_fe_isa_ret[1] & ~dpu_halt_ifu ),
    .consequent_expr (dpu_fe_addr_opa_ret[ 0]    ==  1'b0));


  // Assertions for dpu_fe_isa_ret:
  //
  // Unknown state must never be indicated

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret  => dpu_fe_isa_ret != 2'b11")
  u_ovl_intf_assert_de812cdbbb47491a6f709530e8280fbe90b1e99b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret ),
    .consequent_expr (dpu_fe_isa_ret != 2'b11));


  // Assertions for dpu_fe_itstate_ret:
  //
  // it_cond and it_mask can be non zero only for Thumb and only in non-Debug state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret & (~dpu_fe_isa_ret[0] | dpu_halt_ifu)  => dpu_fe_itstate_ret[7:0] == 8'h00")
  u_ovl_intf_assert_04615ff24c4012786ea402108f38869039275e9b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret & (~dpu_fe_isa_ret[0] | dpu_halt_ifu) ),
    .consequent_expr (dpu_fe_itstate_ret[7:0] == 8'h00));


  // Assertions for dpu_pred_br_ex2
  // If there is a branch in Wr the same branch must have been in Ex2 in the previous cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_pred_br_wr  => dpu_pred_br_ex2@1")
  u_ovl_intf_assert_fdd65a1cee3cb585e858737621e38aa2a5ce4fea (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_pred_br_wr ),
    .consequent_expr (dpu_pred_br_ex2_reg));


  // Assertions for dpu_pred_br_wr:
  //
  // None beyond X/Z check.


  // Assertions for dpu_mispred_br_wr:
  //
  // None beyond X/Z check.


  // Assertions for dpu_br_taken_wr:
  //
  // None beyond X/Z check.


  // Assertions for dpu_br_return_wr:
  //
  // DPU can not signal a call and a return at the same time.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~(dpu_br_return_wr & dpu_br_call_wr)")
  u_ovl_intf_assert_966deef815516579979d14cfc860ccb06a236556 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~(dpu_br_return_wr & dpu_br_call_wr)));



  // Assertions for dpu_br_call_wr:
  //
  // None beyond X/Z check.


  // Assertions for dpu_fe_valid_ret:
  //
  // The dpu_fe_valid_ret signal should only be asserted for one cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret@1  => ~dpu_fe_valid_ret")
  u_ovl_intf_assert_2294c014a8c8d1eec788bce4cac1133e54a35288 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret_reg ),
    .consequent_expr (~dpu_fe_valid_ret));


  // Assertions for dpu_btac_ret:
  //
  // None beyond X/Z check.

  // Assertions for : dpu_aarch64_at_el
  //
  // IFU only interested in bit 3.
  // bit 3 stable out of reset 

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive  => dpu_aarch64_at_el[3]@1 == dpu_aarch64_at_el[3]")
  u_ovl_intf_assert_52790f81ffa06a24a59ed5348e800e518332a685 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive ),
    .consequent_expr (dpu_aarch64_at_el_reg[3] == dpu_aarch64_at_el[3]));


  // Assertions for dpu_exception_level:
  //
  // If the dpu_exception_level changes a force from ret is expected

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & ~ovl_in_debug_state & dpu_exception_level@1 != dpu_exception_level  => dpu_fe_valid_ret")
  u_ovl_intf_assert_c0a9835f0f87decb7ab9245df7dca6145ff13a39 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & ~ovl_in_debug_state & dpu_exception_level_reg != dpu_exception_level ),
    .consequent_expr (dpu_fe_valid_ret));


  // Assertions for dpu_flush_i_utlb:
  //
  // If the dpu_btac_ret signal is asserted we can not get a micro-TLB flush

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_btac_ret  => ~dpu_flush_i_utlb")
  u_ovl_intf_assert_1cc2fd0e92b936f942b9b6fa6d2fe82ceed9ad17 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_btac_ret ),
    .consequent_expr (~dpu_flush_i_utlb));


  // Assertions for debug catch
  //
  // The cycle debug_catch is asserted must be the following cycle of a force.
  // The cycle it is changing must be the following cycle of a force.
  // At any other time the behaviour is unpredictable  

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_reset_catch_pending != dpu_reset_catch_pending@1  => dpu_fe_valid_ret@1")
  u_ovl_intf_assert_0253be3e768c0915d922a6b095b920609b51b0e1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_reset_catch_pending != dpu_reset_catch_pending_reg ),
    .consequent_expr (dpu_fe_valid_ret_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_expt_catch_pending  != dpu_expt_catch_pending@1   => dpu_fe_valid_ret@1")
  u_ovl_intf_assert_447efa0747201e949f27815d9d6c73e973d10a9d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_expt_catch_pending  != dpu_expt_catch_pending_reg  ),
    .consequent_expr (dpu_fe_valid_ret_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_sctlr_itd@1         != dpu_sctlr_itd              => dpu_fe_valid_ret@1")
  u_ovl_intf_assert_4c50bda10e7468229734dfc27dcbe40b140f49d5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_sctlr_itd_reg         != dpu_sctlr_itd             ),
    .consequent_expr (dpu_fe_valid_ret_reg));


  // Assertions for dpu_ns_state:
  //
  // The dpu_ns_state signal can only change on a force from Ret

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_ns_state != dpu_ns_state@1  => dpu_fe_valid_ret")
  u_ovl_intf_assert_6d1944c2bdc4e618aeac10fe15d2bd92c96b6559 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_ns_state != dpu_ns_state_reg ),
    .consequent_expr (dpu_fe_valid_ret));


  // EL3 always secure
  // EL2 always non-secure

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & ~dpu_ns_state  => dpu_exception_level != `CA53_EL2")
  u_ovl_intf_assert_b6b0b7c43ef19be08fc1e3ff71cfce074d65f016 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & ~dpu_ns_state ),
    .consequent_expr (dpu_exception_level != `CA53_EL2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive &  dpu_ns_state  => dpu_exception_level != `CA53_EL3")
  u_ovl_intf_assert_20695895281275432634bd342a7e9807939ee7f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive &  dpu_ns_state ),
    .consequent_expr (dpu_exception_level != `CA53_EL3));


`ifndef L1_TB
  assign el_change  = dpu_exception_level_reg != dpu_exception_level;
  // There are 5 groups of control registers
  // [a] always flush current cycle due to a register write, but never flush 
  //     if the change is due to an exception level change
  // [b] always flush previous cycle due to a register write, but never flush 
  //     if the change is due to an exception level change
  // [c] always flush current cycle
  // [d] always flush previous cycle
  // [e] always flush current cycle due to a register write, always flush
  //     previous cycle due to exception level change
  //
  // Type [a]

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_icache_on@1         != dpu_icache_on         & ~el_change    => dpu_flush_i_utlb")
  u_ovl_intf_assert_1921bea590449b8a76bbdc36c7f65fa979a3327a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_icache_on_reg         != dpu_icache_on         & ~el_change   ),
    .consequent_expr (dpu_flush_i_utlb));

  // Type [b]

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_mmu_on@1            != dpu_mmu_on            & ~el_change@1  => dpu_flush_i_utlb@1")
  u_ovl_intf_assert_d943938fcb1ca8292f7c7103fd24ba819b89391d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_mmu_on_reg            != dpu_mmu_on            & ~el_change_reg ),
    .consequent_expr (dpu_flush_i_utlb_reg));

  // Type [c]  

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_ns_state@1          != dpu_ns_state                          => dpu_flush_i_utlb")
  u_ovl_intf_assert_111df7c746b56fd54174e2c79e10d6e64efd2747 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_ns_state_reg          != dpu_ns_state                         ),
    .consequent_expr (dpu_flush_i_utlb));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_default_cacheable@1 != dpu_default_cacheable                 => dpu_flush_i_utlb")
  u_ovl_intf_assert_f2d037bea8d4874c951c3d149fb9e16596923075 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_default_cacheable_reg != dpu_default_cacheable                ),
    .consequent_expr (dpu_flush_i_utlb));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_sif_only@1          != dpu_sif_only                          => dpu_flush_i_utlb")
  u_ovl_intf_assert_956da37ddefbb0746ca91eeb4eabec5549bd7826 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_sif_only_reg          != dpu_sif_only                         ),
    .consequent_expr (dpu_flush_i_utlb));

  // Type [d]

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_ipa_to_pa_en@1      !== dpu_ipa_to_pa_en                     => dpu_flush_i_utlb@1")
  u_ovl_intf_assert_168885f7941a8535af6f497651912c92ef5d82ad (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_ipa_to_pa_en_reg      !== dpu_ipa_to_pa_en                    ),
    .consequent_expr (dpu_flush_i_utlb_reg));

  // Type [e]  

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_mmu_on & dpu_dacr@1 !== dpu_dacr             & ~el_change@1  => dpu_flush_i_utlb")
  u_ovl_intf_assert_3d9f07348073646b69214d9293efdd133e45b9c9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_mmu_on & dpu_dacr_reg !== dpu_dacr             & ~el_change_reg ),
    .consequent_expr (dpu_flush_i_utlb));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_alive & dpu_mmu_on & dpu_dacr@1 !== dpu_dacr             &  el_change@1  => dpu_flush_i_utlb@1")
  u_ovl_intf_assert_67a5dfd44cec8bc1f7e2e709a964be7605c40e01 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & dpu_mmu_on & dpu_dacr_reg !== dpu_dacr             &  el_change_reg ),
    .consequent_expr (dpu_flush_i_utlb_reg));

`endif

  // ------------------------------------------------------
  // Interface OVLs (outputs from IFU)
  // ------------------------------------------------------

  assign i0_expt_catch  = (ifu_instr0_if3[47:37] == 11'b000000_0100_1) && (ifu_instr0_if3[35:26] == 10'b0_00_1110_000) & ifu_instr_valid_if3[0];
  assign i0_abort       = (ifu_instr0_if3[47:37] == 11'b000000_0100_1) && (ifu_instr0_if3[35:26] == 10'b0_00_1110_100) & ifu_instr_valid_if3[0];
  assign i0_bkpt        = (ifu_instr0_if3[47:37] == 11'b000000_0100_1) && (ifu_instr0_if3[35:26] == 10'b0_00_1110_110) & ifu_instr_valid_if3[0];
  assign i0_parity      = (ifu_instr0_if3[47:37] == 11'b000000_0100_1) && (ifu_instr0_if3[35:26] == 10'b0_00_1110_111) & ifu_instr_valid_if3[0];

  // check dual issue bits 

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[0] & ifu_instr0_if3[47:42] == 6'b000000  => ifu_instr0_if3[34:33] == 2'b00")
  u_ovl_intf_assume_a9456f8f2c1b396700826660369a6355462785e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[0] & ifu_instr0_if3[47:42] == 6'b000000 ),
    .consequent_expr (ifu_instr0_if3[34:33] == 2'b00));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[1] & ifu_instr1_if3[47:42] == 6'b000000  => ifu_instr1_if3[34:33] == 2'b00")
  u_ovl_intf_assume_86c5bfef6da56868d5de1092d2608283b52df91e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[1] & ifu_instr1_if3[47:42] == 6'b000000 ),
    .consequent_expr (ifu_instr1_if3[34:33] == 2'b00));


  // Assertions for ifu_instr_valid_if3:

  // Out of reset, the IFU does not start fetching until forced by the DPU

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ifu_fetching <= 1'b0;
  else
    ifu_fetching <= (ifu_fetching & ~i0_expt_catch & ~i0_abort & ~i0_bkpt) | dpu_force;



  assert_implication #(`OVL_FATAL, INOPTIONS, "~ifu_fetching  => ifu_instr_valid_if3 == 2'b00")
  u_ovl_intf_assume_3688a9c0b9b07753f47d5934eeafb1db8ee228a8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ifu_fetching ),
    .consequent_expr (ifu_instr_valid_if3 == 2'b00));


  // Cannot issue an instruction immediately after a force from the DPU

  assert_implication #(`OVL_FATAL, INOPTIONS, "(dpu_fe_valid_wr@1 | dpu_fe_valid_ret@1)  => ifu_instr_valid_if3 == 2'b00")
  u_ovl_intf_assume_15e33d1accd289e1f3dc21e51d71b9f4ddb29df7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dpu_fe_valid_wr_reg | dpu_fe_valid_ret_reg) ),
    .consequent_expr (ifu_instr_valid_if3 == 2'b00));


  // In debug, only one instruction can be issued per cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state  => ifu_instr_valid_if3 != 2'b11")
  u_ovl_intf_assume_3cfb7f32de867049ecf7c6bbd0efbbf53a42cea1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (ifu_instr_valid_if3 != 2'b11));


  // An instruction can only be issued if one has been sent by the DPU

  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state & ifu_instr_valid_if3 == 2'b01  => dbg_instr_in_flight")
  u_ovl_intf_assume_e688eee0adf953541565eb3f3d2c87451c4c7709 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state & ifu_instr_valid_if3 == 2'b01 ),
    .consequent_expr (dbg_instr_in_flight));


  // Cannot get aborts etc in debug state

  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state  => ~i0_abort")
  u_ovl_intf_assume_5eaa2cb5b1a481f63a334eb88817d467246d7191 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~i0_abort));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state  => ~i0_expt_catch")
  u_ovl_intf_assume_1a3fbf5858af9f0b75e933820381993948d6606f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~i0_expt_catch));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state  => ~i0_bkpt")
  u_ovl_intf_assume_050ee071a88dad762c64281bdb094bde231817c7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~i0_bkpt));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state  => ~i0_parity")
  u_ovl_intf_assume_ec4e5ee6553bc7f37312846bc434b11387ef6a4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state ),
    .consequent_expr (~i0_parity));


  // expt_catch instruction type must be at least one of exception catch
  // or reset catch

  assert_implication #(`OVL_FATAL, INOPTIONS, "i0_expt_catch  => ifu_instr0_if3[1:0] != 2'b00")
  u_ovl_intf_assume_ea6b755721b7629df0392fe84f6f173cdc573067 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (i0_expt_catch ),
    .consequent_expr (ifu_instr0_if3[1:0] != 2'b00));



  assert_implication #(`OVL_FATAL, INOPTIONS, "i0_expt_catch & ifu_instr0_if3[0]  => dpu_reset_catch_pending")
  u_ovl_intf_assume_391c539416df21874fe18172836a44723b3f5d06 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (i0_expt_catch & ifu_instr0_if3[0] ),
    .consequent_expr (dpu_reset_catch_pending));


  assert_implication #(`OVL_FATAL, INOPTIONS, "i0_expt_catch & ifu_instr0_if3[1]  => dpu_expt_catch_pending")
  u_ovl_intf_assume_def6ce5ee171b6abc94681cbe8096614c8197c94 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (i0_expt_catch & ifu_instr0_if3[1] ),
    .consequent_expr (dpu_expt_catch_pending));


  //
  // Top four bits of instruction-0 must be one-hot
  //

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[0]  => ((ifu_instr0_if3[41:38] == 4'b0000) | (ifu_instr0_if3[41:38] == 4'b0001) | (ifu_instr0_if3[41:38] == 4'b0010) | (ifu_instr0_if3[41:38] == 4'b0100) | (ifu_instr0_if3[41:38] == 4'b1000))")
  u_ovl_intf_assume_a580b3035d06631144c29891ceba8f9bf772acec (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[0] ),
    .consequent_expr (((ifu_instr0_if3[41:38] == 4'b0000) | (ifu_instr0_if3[41:38] == 4'b0001) | (ifu_instr0_if3[41:38] == 4'b0010) | (ifu_instr0_if3[41:38] == 4'b0100) | (ifu_instr0_if3[41:38] == 4'b1000))));


  // Assertions for ifu_early_two_valid_if3:
  //
  // If ifu_early_two_valid_if3 is asserted so must ifu_instr_valid_if3[0].  In
  // other words, we must be pushing at least one instruction to assert this.
  //
  // If ifu_instr_valid_if3[1] is asserted then ifu_early_two_valid_if3 must be
  // valid.
  //

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_early_two_valid_if3  => ifu_instr_valid_if3[0]")
  u_ovl_intf_assume_ac60b0021b3d8834c1d8be0ed1b7582a39d427e8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_early_two_valid_if3 ),
    .consequent_expr (ifu_instr_valid_if3[0]));



  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[1]  => ifu_early_two_valid_if3")
  u_ovl_intf_assume_ed9ceb1281cb3a71cdb683505d3f7dcfebeaec5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[1] ),
    .consequent_expr (ifu_early_two_valid_if3));


  // Assertions for ifu_instr1_if3:
  //
  // Top four bits of instruction-1 must be one-hot
  //

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[1]  => ((ifu_instr1_if3[41:38] == 4'b0000) | (ifu_instr1_if3[41:38] == 4'b0001) | (ifu_instr1_if3[41:38] == 4'b0010) | (ifu_instr1_if3[41:38] == 4'b0100) | (ifu_instr1_if3[41:38] == 4'b1000))")
  u_ovl_intf_assume_3079f21f58fbd1c4a1dba9721d8bc7e5facd01f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[1] ),
    .consequent_expr (((ifu_instr1_if3[41:38] == 4'b0000) | (ifu_instr1_if3[41:38] == 4'b0001) | (ifu_instr1_if3[41:38] == 4'b0010) | (ifu_instr1_if3[41:38] == 4'b0100) | (ifu_instr1_if3[41:38] == 4'b1000))));



  // Assertions for ifu_instr_valid_if3:
  //
  // The ifu_pd_instr_valid bus can not be 2'b10
  //
  // IFU can not push instructions when IQ is signalling full
  //
  // IFU can not push instructions when pushing a predicted address
  //
  // IFU can not push a prefetch abort in instruction-1
  //
  // IFU can not push a breakpoint in instruction-1

  assert_always #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3 != 2'b10")
  u_ovl_intf_assume_f984af15f7becb2407c4b9d4f732fa97e88e2d64 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (ifu_instr_valid_if3 != 2'b10));



  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_iq_full    => ifu_instr_valid_if3[1:0] == 2'b00")
  u_ovl_intf_assume_0fa62e10627dce7f5ddbd0a7bd5e92d8f0c742b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_iq_full   ),
    .consequent_expr (ifu_instr_valid_if3[1:0] == 2'b00));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    instr_since_last_addr <= 1'b0;
  else
    instr_since_last_addr <= (|ifu_instr_valid_if3) | (instr_since_last_addr & ~ifu_pred_addr_valid_if4);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    under_parity <= 1'b0;
  else
    under_parity <= i0_parity | (under_parity & ~dpu_fe_valid_ret);



  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_pred_addr_valid_if4  => (ifu_instr_valid_if3 == 2'b00)")
  u_ovl_intf_assume_f91a571057d1c7666e8f67851e41acad87adf21f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_pred_addr_valid_if4 ),
    .consequent_expr ((ifu_instr_valid_if3 == 2'b00)));

  // we suppress the check if a prity error is seen since it could corrupt the pre-fetch creating a back to back
  // valid if4 first with a corrupted return (which is not a return) and then with a BTAC. the dpu will ignore both
  // the corrupted return and the subsequent BTAC and send a force from ret instead to take care of teh parity issue

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_pred_addr_valid_if4 & ~under_parity  => instr_since_last_addr")
  u_ovl_intf_assume_b26e67683f286c159c564c2571c4f1a879775ff2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_pred_addr_valid_if4 & ~under_parity ),
    .consequent_expr (instr_since_last_addr));



  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[1]  => ~((ifu_instr1_if3[47:37] == 11'b000000_0100_1) & (ifu_instr1_if3[35:27] == 9'b0_11_1110_10))")
  u_ovl_intf_assume_5e0964c08e91f7d5c607969b3a22afc057861552 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[1] ),
    .consequent_expr (~((ifu_instr1_if3[47:37] == 11'b000000_0100_1) & (ifu_instr1_if3[35:27] == 9'b0_11_1110_10))));



  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_instr_valid_if3[1]  => ~((ifu_instr1_if3[47:37] == 11'b000000_0100_1) & (ifu_instr1_if3[34:27] ==   8'b11_1110_10))")
  u_ovl_intf_assume_204a17056c7387236b0fd7921e57903343ca99ca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_instr_valid_if3[1] ),
    .consequent_expr (~((ifu_instr1_if3[47:37] == 11'b000000_0100_1) & (ifu_instr1_if3[34:27] ==   8'b11_1110_10))));


  // Assertions for ifu_pred_addr_valid_if4:
  //
  // A predicted address can not be pushed if there was a force in the previous
  // cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_pred_addr_valid_if4  => (~dpu_fe_valid_wr@1 & ~dpu_fe_valid_ret@1)")
  u_ovl_intf_assume_dcd02acb235137593b2ee26f2b38426b76de60b6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_pred_addr_valid_if4 ),
    .consequent_expr ((~dpu_fe_valid_wr_reg & ~dpu_fe_valid_ret_reg)));


  // Assertions for ifu_ifar:
  //
  // The IFAR bus must remain constant one cycle after an abort has been signalled until a force 
  // from the DPU occurs unless the abort crosses a fetch boundary in which case a single
  // increment will occur
  //
  // The IFAR bus must remain constant two cycles after an abort has been signalled until a 
  // force from the DPU occurs
  //
  // The least significant bit of the IFAR must always be zero
  assign valid_abort  = (ifu_instr0_if3[47:37] == 11'b000000_0100_1) && (ifu_instr0_if3[35:26] == 10'b0_00_1110_100) & ifu_instr_valid_if3[0] & ~dpu_force;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    abort_in_flight <= 1'b0;
  else if (valid_abort | dpu_force)
    abort_in_flight <= valid_abort;



  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_alive & abort_in_flight & abort_in_flight@1                               => (ifu_ifar[31:1]@1 == ifu_ifar[31:1])")
  u_ovl_intf_assume_6ddfeec8fceff52a760a132533106bb2a5097f88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & abort_in_flight & abort_in_flight_reg                              ),
    .consequent_expr ((ifu_ifar_reg[31:1] == ifu_ifar[31:1])));


  // Assertions for ifu_ifsr:
  //
  // Constrain the possible values on the IFSR bus for LPAE faults
  // (even when the fault is VMSA it is presented as LPAE to the DPU)
  //
  // The IFSR bus must remain constant after an abort has been signalled
  // until a force from the DPU occurs. NOTE: always LPAE passed to to the DPU

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_abort@1  => ifu_ifsr[6:0] in [`CA53_FAULT_LPAE_ADDR_SIZE_L0, `CA53_FAULT_LPAE_ADDR_SIZE_L1, `CA53_FAULT_LPAE_ADDR_SIZE_L2, `CA53_FAULT_LPAE_ADDR_SIZE_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_PERMISSION_L1, `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3, `CA53_FAULT_LPAE_DOMAIN_L1, `CA53_FAULT_LPAE_DOMAIN_L2, `CA53_FAULT_LPAE_EXT_DEC, `CA53_FAULT_LPAE_EXT_SLV, `CA53_FAULT_LPAE_ECC, `CA53_FAULT_LPAE_ALIGNMENT]")
  u_ovl_intf_assume_7f5efc450ec53489f9dba892aa19e69daa30995b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_abort_reg ),
    .consequent_expr (((ifu_ifsr[6:0] == `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_PERMISSION_L3) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_DOMAIN_L1) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_DOMAIN_L2) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_EXT_DEC) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_EXT_SLV) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ECC) | (ifu_ifsr[6:0] ==  `CA53_FAULT_LPAE_ALIGNMENT))));



  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_alive & abort_in_flight & abort_in_flight@1  => ifu_ifsr[6:0]@1 == ifu_ifsr[6:0]")
  u_ovl_intf_assume_e5475963993f9b672115fdc8aeed9a37caa44dc7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & abort_in_flight & abort_in_flight_reg ),
    .consequent_expr (ifu_ifsr_reg[6:0] == ifu_ifsr[6:0]));


  // Assertions for ifu_ifsr_stage2:
  //
  // Constrain the possible values for the bus

  assert_always #(`OVL_FATAL, INOPTIONS, "ifu_ifsr_stage2[1:0] in [2'b00, 2'b10, 2'b11]")
  u_ovl_intf_assume_9bee8fa188313783fd5f20c17978044322379c07 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((ifu_ifsr_stage2[1:0] == 2'b00) | (ifu_ifsr_stage2[1:0] ==  2'b10) | (ifu_ifsr_stage2[1:0] ==  2'b11))));


  // Stage 2 aborts are only possible in non-secure state, below EL2

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_abort@1 & ifu_ifsr_stage2[1:0] in [2'b10, 2'b11]  => dpu_ns_state@1 & dpu_exception_level@1 < `CA53_EL2")
  u_ovl_intf_assume_82ce71c9af1df6ab52588477678dd18945d8da83 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_abort_reg & ((ifu_ifsr_stage2[1:0] == 2'b10) | (ifu_ifsr_stage2[1:0] ==  2'b11)) ),
    .consequent_expr (dpu_ns_state_reg & dpu_exception_level_reg < `CA53_EL2));



  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_alive & abort_in_flight & abort_in_flight@1  => ifu_ifsr_stage2@1 == ifu_ifsr_stage2")
  u_ovl_intf_assume_d91342a6b2e8983e971613689253b88eeac56464 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & abort_in_flight & abort_in_flight_reg ),
    .consequent_expr (ifu_ifsr_stage2_reg == ifu_ifsr_stage2));


  // Assertions for ifu_ifsr_lpae:
  //
  // The ifu_ifsr bus will remain constant between valid instructions

  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_alive & ~(ifu_instr_valid_if3[0] | ifu_instr_valid_if3[0]@1)  => ifu_ifsr_lpae == ifu_ifsr_lpae@1")
  u_ovl_intf_assume_4e29e8238d8353d25507f5d313b0aa5ca5a8eb39 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & ~(ifu_instr_valid_if3[0] | ifu_instr_valid_if3_reg[0]) ),
    .consequent_expr (ifu_ifsr_lpae == ifu_ifsr_lpae_reg));


  // Assertions for ifu_hpfar:
  //
  // The HPFAR bus must remain constant after an abort has been signalled
  // until a force from the DPU occurs

  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_alive & abort_in_flight & ifu_ifsr_stage2[1]  => ifu_hpfar[27:0]@1 == ifu_hpfar[27:0]")
  u_ovl_intf_assume_1ee5818aaf92e5fada8153e9d2ada3bdb9f2b031 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_alive & abort_in_flight & ifu_ifsr_stage2[1] ),
    .consequent_expr (ifu_hpfar_reg[27:0] == ifu_hpfar[27:0]));


  // Assertions for dpu_dbg_valid:
  //  
  // The DPU will only send the first instruction if ifu_dbg_ready is high
  // Even though it seems we are proving an IFU signal this is an assert for DPU 
  // because it is the dpu_dbg_valid that can only be set if ifu_dbg_ready is set

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_valid  => ifu_dbg_ready")
  u_ovl_intf_assert_9ea47f51d66736f2d2073f4f6e37d052ef3b5031 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_valid ),
    .consequent_expr (ifu_dbg_ready));


  // The icu_dbg_ready signal will stay high while the processor is in debug

  assert_implication #(`OVL_FATAL, INOPTIONS, "ovl_in_debug_state@1 & ifu_dbg_ready@1  => ifu_dbg_ready")
  u_ovl_intf_assume_ec5b2e02873004fdab8beacc7f793199dfca6c08 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state_reg & ifu_dbg_ready_reg ),
    .consequent_expr (ifu_dbg_ready));


  // The hardware has been built considering that we cannot have back to back 
  // debug instructions. In fact it is expected that at least a full pipeline 
  // stage has to be seen between debugs.
  // Check that there are at least 2 cycles latency between debug instructions.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_valid  => ~(dpu_dbg_valid@1 | dpu_dbg_valid@2)")
  u_ovl_intf_assert_58963a78f739fad932706e7865de27042bf3c42e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_valid ),
    .consequent_expr (~(dpu_dbg_valid_reg | dpu_dbg_valid_reg_reg)));


  // DPU must be at least alive before sending any dbg instruction

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_dbg_valid  => ovl_in_debug_state")
  u_ovl_intf_assert_1c5c0e576c1369f68915bd1961fd1216387a1357 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_dbg_valid ),
    .consequent_expr (ovl_in_debug_state));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dbg_instr_in_flight <= 1'b0;
  else
    dbg_instr_in_flight <= dpu_dbg_valid | (dbg_instr_in_flight & ~ifu_instr_valid_if3[0]);

  // while we are allowed to have forces from ret that changes cpsr state while in debug
  // those can only be present when there are no outstanding instructions

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ovl_in_debug_state & (dpu_dbg_valid | dbg_instr_in_flight)  => ~dpu_fe_valid_ret")
  u_ovl_intf_assert_23beb2f64d742049dfb2990edbd9dc4753dc8139 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state & (dpu_dbg_valid | dbg_instr_in_flight) ),
    .consequent_expr (~dpu_fe_valid_ret));


  // a new debug instruction cannot be set if we already have one in flight

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ovl_in_debug_state & dbg_instr_in_flight  => ~dpu_dbg_valid")
  u_ovl_intf_assert_3f26db644c3b48735caff8cd259ed07cff4e4033 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_in_debug_state & dbg_instr_in_flight ),
    .consequent_expr (~dpu_dbg_valid));


  // only T32 or A64 allowed in debug

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_fe_valid_ret & dpu_halt_ifu  => dpu_fe_isa_ret != 2'b00")
  u_ovl_intf_assert_ea0d763b9cf555a956b6ddcfad69a44eb8943089 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_fe_valid_ret & dpu_halt_ifu ),
    .consequent_expr (dpu_fe_isa_ret != 2'b00));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_ifu_defs.v"
`undef CA53_UNDEFINE

`endif

