//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
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

//-----------------------------------------------------------------------------
// Abstract : DPU exception handler
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// This module contains the main exception handler logic, which lives in Wr
// and is responsible for detecting and routing interrupts (including those
// pre-detected and routed using the early logic in Iss).
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_exception (
  // Inputs
  input  wire                               clk,
  input  wire                               reset_n,
  input  wire                               sctlr_ns_hivecs_i,
  input  wire                               sctlr_s_hivecs_i,
  input  wire                       [39:2]  rvbaraddr_i,
  input  wire                        [3:1]  aarch64_at_el_i,
  input  wire                               aarch64_state_i,
  input  wire                        [1:0]  dpu_exception_level_i,
  input  wire                               gic_fiq_i,
  input  wire                               gic_irq_i,
  input  wire                               gic_vfiq_i,
  input  wire                               gic_virq_i,
  input  wire                               gov_sei_level_req_i,
  input  wire                               gov_vsei_level_req_i,
  input  wire                               gov_rei_level_req_i,
  input  wire                               gov_int_active_i,
  input  wire                               cc_pass_instr0_wr_i,
  input  wire                               cc_pass_instr1_wr_i,
  input  wire                               dcu_valid_dc3_i,
  input  wire                               dcu_p_abort_dc3_i,
  input  wire                        [3:0]  dcu_p_domain_dc3_i,
  input  wire                        [6:0]  dcu_p_fault_dc3_i,
  input  wire                        [1:0]  dcu_p_fault_stage_dc3_i,
  input  wire                               dcu_p_direction_dc3_i,
  input  wire                               dcu_ecc_err_dc3_i,
  input  wire                       [39:12] dcu_pa_dc3_i,
  input  wire                       [63:0]  dcu_va_dc3_i,
  input  wire                               dcu_cm_operation_dc3_i,
  input  wire                               dcu_v2p_lpae_dc3_i,
  input  wire                               dcu_wpt_hit_dc3_i,
  input  wire                               tlb_lpae_mode_i,
  input  wire                               tlb_lpae_mode_s_i,
  input  wire                               biu_w_imp_abort_i,
  input  wire                        [1:0]  biu_w_imp_fault_i,
  input  wire                               dpu_fe_valid_wr_i,
  input  wire                               dpu_fe_valid_ret_i,
  input  wire                               cpsr_ssbit_ret_i,
  input  wire                               cpsr_ibit_ret_i,
  input  wire                               cpsr_fbit_ret_i,
  input  wire                               cpsr_abit_ret_i,
  input  wire                        [4:0]  cpsr_mode_ret_i,
  input  wire                               stall_wr_i,
  input  wire                               br_flush_ret_i,
  input  wire                               slot0_br_flush_wr_i,
  input  wire                        [1:0]  pre_valid_instrs_wr_i,
  input  wire                               pre_head_instr0_wr_i,
  input  wire                               unflushable_wr_i,
  input  wire                               no_interrupt_wr_i,
  input  wire  [`CA53_LS_INSTR_TYPE_W-1:0]  ls_instr_type_wr_i,
  input  wire                               ls_isv_set_wr_i,
  input  wire                               ls_synd_sf_wr_i,
  input  wire                               ls_valid_wr_i,
  input  wire                        [1:0]  ls_size_wr_i,
  input  wire                               slot1_ls_wr_i,
  input  wire                               in_halt_i,
  input  wire                        [1:0]  edscr_intdis_i,
  input  wire                               dbgen_synced_i,
  input  wire                               spiden_synced_i,
  input  wire                               dbg_bkpt_wpt_en_i,
  input  wire                               dbg_hw_halt_req_i,
  input  wire                               held_dbg_hw_halt_req_i,
  input  wire                               held_dbg_osuc_halt_req_i,
  input  wire                               held_dbg_ext_hw_halt_req_i,
  input  wire                               dbg_soft_step_active_i,
  input  wire                               hdcr_tde_i,
  input  wire                               dbg_restart_qual_i,
  input  wire                               dbg_cancel_biu_i,
  input  wire                               ss_enter_halt_i,
  input  wire                       [63:0]  pc_instr0_wr_i,
  input  wire                       [63:0]  pc_instr0_ret_i,
  input  wire                               expt_slot1_ret_i,
  input  wire                               size_instr1_ret_i,
  input  wire                       [27:0]  ifu_hpfar_i,
  input  wire                       [31:1]  ifu_ifar_i,
  input  wire                        [6:0]  ifu_ifsr_i,
  input  wire                        [1:0]  ifu_ifsr_stage2_i,
  input  wire                               ifu_ifsr_lpae_i,
  input  wire                       [63:5]  cp_vbar_el3_i,
  input  wire                       [63:5]  cp_vbar_el1_i,
  input  wire                       [31:5]  cp_mvbar_i,
  input  wire                       [63:5]  cp_hvbar_i,
  input  wire                               hcr_amo_i,
  input  wire                               hcr_imo_i,
  input  wire                               hcr_fmo_i,
  input  wire                               scr_ea_i,
  input  wire                               scr_fiq_i,
  input  wire                               scr_irq_i,
  input  wire                               scr_aw_i,
  input  wire                               scr_fw_i,
  input  wire                               nxt_ns_scr_i,
  input  wire                               hcr_tge_i,
  input  wire                               hcr_va_i,
  input  wire                               hcr_vi_i,
  input  wire                               hcr_vf_i,
  input  wire                               cp_icimvau_i,
  input  wire                               nxt_mon_el3_mode_ret_i,
  input  wire                               size_instr0_wr_i,
  input  wire                               size_instr1_wr_i,
  input  wire                        [4:0]  ls_synd_srt_wr_i,
  input  wire                               raw_wfi_req_i,
  input  wire                               raw_wfe_req_i,
  input  wire                               nxt_wfx_ifu_halt_i,
  input  wire                               wfx_stall_wr_i,
  input  wire       [`CA53_EXPT_BUS_W-1:0]  exception_data_wr_i,
  input  wire                               thumb_instr0_wr_i,
  input  wire                               thumb_instr1_wr_i,
  input  wire                        [1:0]  isa_instr0_wr_i,
  input  wire                        [1:0]  isa_instr0_ret_i,
  input  wire     [`CA53_INSTR_TYPE_W-1:0]  instr_type_wr_i,
  input  wire                               soft_step_isv_i,
  input  wire                               halt_step_isv_i,
  input  wire                               step_ex_i,
  input  wire                               fpu_interlock_iss_i,
  // Outputs
  output wire                               insert_forceop_wr_o,        // Exception in Wr will insert forceop
  output wire                               insert_forceop_ret_o,       // Exception in Ret will insert forceop
  output reg                                forceop_valid_de_o,         // Forceop is in De
  output wire                               forceop_valid_wr_o,         // Forceop is in Wr
  output reg                                dbg_halt_ecc_expt_de_o,
  output reg    [`CA53_FORCEOP_TYPE_W-1:0]  forceop_type_o,             // Used by forceop decoder in De
  output reg  [`CA53_FORCEOP_OFFSET_W-1:0]  forceop_offset_o,           // Offset to apply to PC on forceop
  output reg                                forceop_aa64_o,             // Exception inserting forceop from AA64 state
  output wire                       [63:0]  forceop_pc_ret_o,           // PC to use on forceop for exception currently in Ret (registered in Br and forced in Ret+1)
  output wire                       [17:1]  forceop_pc_offset_ret_o,
  output wire    [`CA53_SEL_CPSR_EN_W-1:0]  expt_cpsr_wr_en_ret_o,      // PSR write enable for exception in Ret
  output wire                        [4:0]  expt_cpsr_mode_ret_o,       // - Mode to write to PSR
  output wire   [`CA53_SEL_CPSR_SRC_W-1:0]  expt_cpsr_wr_src_ret_o,     // Source for PSR value
  output wire      [`CA53_EXPT_TYPE_W-1:0]  expt_type_o,                // For ETM IF
  output wire                               expt_type_l1_ecc_o,         // L1 ECC error exception for debug logic
  output wire                               etm_trace_expt_o,           // - " "
  output wire                               etm_trace_dbgentry_o,       // - " "
  output wire                               expt_dbgexit_o,             // For ETM and debug logic
  output wire                               expt_quash_wr_o,            // Quash instruction in Wr
  output reg                                expt_ls_quash_wr_o,         // - special versions of quash_wr
  output reg                                expt_quash_slot0_wr_o,      // - " "
  output wire                               expt_slot1_wr_o,            // There is an exception being caused by the instruction in slot 1
  output reg                                expt_quash_no_data_wr_o,
  output wire                               early_expt_dcu_wr_o,        // There is a DCU exception in Wr (may not be exception being taken)
  output reg                                expt_flush_ret_o,           // Flush pipeline from Ret
  output wire                               expt_in_halt_o,             // For debug logic
  output wire                               end_expt_in_halt_o,         // - " "
  output wire                               dbg_event_o,                // - " "
  output wire                               dbg_event_halt_wr_o,        // - " "
  output wire                               dbg_ss_vld_expt_type_ret_o, // - " "
  output wire                               dbg_expt_o,                 // - " "
  output wire                               nxt_dbg_ifu_halt_o,         // - " "
  output wire                               evnt_expt_taken_o,          // - " "
  output wire                               evnt_call_expt_taken_o,     // - " "
  output wire                        [3:0]  expt_status_moe_data_wr_o,  // - " "
  output wire                               expt_idle_o,                // - " "
  output wire                        [1:0]  target_exception_level_o,   // - " "
  output wire   [`CA53_FAULT_REG_EN_W-1:0]  expt_fault_reg_en_wr_o,     // ESR/fault status register control signals
  output wire                       [31:0]  expt_esr_data_wr_o,         // - " "
  output reg                        [12:0]  expt_ifsr_wr_o,             // - " "
  output reg                        [12:0]  expt_dfsr_wr_o,             // - " "
  output wire                       [63:0]  expt_far_data_wr_o,         // - " "
  output wire                       [27:0]  expt_hpfar_data_wr_o,       // - " "
  output wire                               expt_aa32_uses_el1_esr_wr_o,
  output wire                               expt_fault_reg_sel_wr_o,    // - Used for controlling register input data muxes in CP block
  output wire                               clear_virtual_ea_o,
  output wire                               wfi_expt_exception_pending_o,
  output wire                               wfe_expt_exception_pending_o,
  output wire                               expt_mon_mode_clear_ns_o,
  output wire                               ns_state_o,
  output wire                               wfi_expt_wr_o,
  output wire                               wfe_expt_wr_o,
  output wire                               expt_serr_pending_o,
  output wire                               expt_irq_pending_o,
  output wire                               expt_fiq_pending_o,
  output wire                               evnt_fiq_taken_o,
  output wire                               evnt_irq_taken_o,
  output reg                                dpu_irq_pended_o,
  output reg                                dpu_fiq_pended_o,
  output reg                                dpu_sei_pended_o,
  output reg                                dpu_irq_masked_o,
  output reg                                dpu_fiq_masked_o,
  output reg                                dpu_sei_masked_o,
  output reg                                dpu_virq_pended_o,
  output reg                                dpu_vfiq_pended_o,
  output reg                                dpu_vsei_pended_o,
  output reg                                dpu_virq_masked_o,
  output reg                                dpu_vfiq_masked_o,
  output reg                                dpu_vsei_masked_o,
  output wire                               dpu_rei_level_ack_o,
  output wire                               dpu_sei_level_ack_o,
  output wire                               dpu_vsei_level_ack_o,
  output wire                               dpu_imp_abort_pending_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam                  EXPT_FSM_W                 = 4;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_RESET0             = 4'b0000;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_RESET1             = 4'b0001;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_RESET_FLUSH        = 4'b0010;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_IDLE               = 4'b0011;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_DPU_FLUSH          = 4'b0100;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_DE_FORCEOP         = 4'b0101;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_ISS_FORCEOP        = 4'b0110;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_EX1_FORCEOP        = 4'b0111;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_EX2_FORCEOP        = 4'b1000;
  localparam [EXPT_FSM_W-1:0] ST_EXPT_WR_FORCEOP         = 4'b1001;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                             [17:1]  forceop_reexec_pc_offset_sl0_ret;
  reg                             [17:1]  forceop_reexec_pc_offset_sl1_ret;
  reg                                     imp_abort_pending;
  reg                              [1:0]  imp_abort_fault;
  reg                   [EXPT_FSM_W-1:0]  current_state;
  reg                   [EXPT_FSM_W-1:0]  nxt_state;
  reg                                     expt_in_halt;
  reg                                     end_expt_in_halt;
  reg                                     expt_end_in_halt;
  reg                                     ns_state;
  reg                              [4:0]  exception_mode_ret;
  reg                              [1:0]  exception_el_ret;
  reg                              [3:0]  exception_vector_offset_ret;
  reg     [`CA53_CPSR_WR_EN_EARLY_W-1:0]  cpsr_wr_en_ret;
  reg          [`CA53_SEL_CPSR_EN_W-1:0]  full_cpsr_wr_en_ret;
  reg                             [31:5]  exception_vector_aa32_base_ret;
  reg                             [63:11] exception_vector_aa64_base_ret;
  reg                                     insert_forceop_ret;
  reg                                     dbg_halt_ecc_expt_ret;
  reg                                     gic_irq_reg;
  reg                                     gic_fiq_reg;
  reg                                     gic_virq_reg;
  reg                                     gic_vfiq_reg;
  reg                                     gov_sei_reg;
  reg                                     gov_vsei_reg;
  reg                                     gov_rei_reg;
  reg                                     gov_int_active_reg;
  reg            [`CA53_EXPT_TYPE_W-1:0]  expt_type;
  reg                                     exception_aa64_wr;
  reg                                     expt_slot1_wr;
  reg                              [1:0]  final_late_expt_el_wr;
  reg                              [4:0]  final_late_expt_mode_wr;
  reg       [`CA53_FORCEOP_OFFSET_W-1:0]  forceop_offset_aa64_wr;
  reg       [`CA53_FORCEOP_OFFSET_W-1:0]  forceop_offset_aa32_wr;
  reg         [`CA53_FAULT_REG_EN_W-1:0]  expt_fault_reg_en;
  reg                             [25:0]  late_expt_esr_wr;
  reg                              [5:0]  late_expt_ec_wr;
  reg                                     cpsr_wr_src_ret;
  reg                                     dbg_ss_vld_expt_type;
  reg                                     exception_valid_wr;
  reg                                     expt_quash_wr;
  reg                                     lower_level_aa64;
  reg                                     intdis_mask_fiq;
  reg                                     intdis_mask_vfiq;
  reg                                     intdis_mask_irq;
  reg                                     intdis_mask_virq;
  reg                                     intdis_mask_imp;
  reg                                     intdis_mask_vimp;
  reg                                     dpu_rei_level_ack;
  reg                                     dpu_sei_level_ack;
  reg                                     dpu_vsei_level_ack;
  reg                                     ecc_suppress_async;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire    [`CA53_CPSR_WR_EN_EARLY_W-1:0]  cpsr_wr_en_aa32_wr;
  wire                            [17:1]  forceop_reexec_pc_offset_ret;
  wire                            [39:2]  exception_vector_reset_ret;
  wire                                    set_expt_in_halt;
  wire                                    clear_imp_abort;
  wire                                    nxt_ns_state;
  wire                                    expt_early_hipri_wr;
  wire                                    expt_early_lopri_wr;
  wire                                    expt_early_ccfail_wr;
  wire                                    take_early_expt_wr;
  wire                                    dbg_expt;
  wire                                    dbg_halt_ecc_expt_wr;
  wire                                    nxt_expt_in_halt;
  wire                                    nxt_end_expt_in_halt;
  wire                                    nxt_expt_end_in_halt;
  wire                                    defer_async_expt;
  wire                                    defer_enter_hw_halt_expt;
  wire                                    defer_step_expt;
  wire                                    sample_dcu_wr;
  wire                                    nxt_imp_abort_pending;
  wire                             [1:0]  nxt_imp_abort_fault;
  wire                                    set_imp_abort;
  wire                                    ls_synd_sse_wr;
  wire                                    ls_synd_ar_wr;
  wire                                    external_dabort;
  wire                                    stack_align_abort;
  wire                                    in_el2;
  wire                                    in_el3;
  wire                                    cpsr_fiq_mask;
  wire                                    cpsr_irq_mask;
  wire                                    cpsr_ea_mask;
  wire                                    mask_fiq;
  wire                                    mask_irq;
  wire                                    mask_ea;
  wire                                    mask_vf;
  wire                                    mask_vi;
  wire                                    mask_va;
  wire                                    pend_fiq;
  wire                                    pend_irq;
  wire                                    pend_ea;
  wire                                    pend_vf;
  wire                                    pend_vi;
  wire                                    pend_va;
  wire                                    ls_instr_syndrome_valid;
  wire                             [4:0]  final_ls_synd_srt_wr;
  wire                             [4:0]  ls_synd_srt_aa64_wr;
  wire                             [5:0]  expt_ec_wr;
  wire                                    exception_at_same_el_wr;
  wire                                    exception_el2_wr;
  wire                                    early_expt_is_wfi;
  wire                                    early_expt_is_wfe;
  wire                                    exception_valid_nostate_wr;
  wire                             [1:0]  exception_el_wr;
  wire                             [4:0]  exception_mode_wr;
  wire                                    early_expt_quash_wr;
  wire                                    early_expt_is_conditional_wr;
  wire           [`CA53_EXPT_TYPE_W-1:0]  early_expt_type_wr;
  wire                             [1:0]  early_expt_el_wr;
  wire                             [4:0]  early_expt_mode_wr;
  wire                             [4:0]  early_expt_aa32_vect_offset_wr;
  wire                                    early_expt_enter_halt_wr;
  wire                             [5:0]  early_expt_ec_wr;
  wire                            [25:0]  early_expt_esr_wr;
  wire                                    early_expt_high_priority_wr;
  wire                                    enter_halt_wr;
  wire                             [4:0]  exception_vector_aa32_offset_wr;
  wire                            [10:0]  exception_vector_aa64_offset_wr;
  wire                             [3:0]  exception_vector_offset_wr;
  wire    [`CA53_CPSR_WR_EN_EARLY_W-1:0]  nxt_cpsr_wr_en_ret;
  wire                                    nxt_dbg_ss_vld_expt_type;
  wire        [`CA53_FORCEOP_TYPE_W-1:0]  forceop_type_wr;
  wire      [`CA53_FORCEOP_OFFSET_W-1:0]  forceop_offset_wr;
  wire                                    thumb_mode_wr;
  wire                                    ns_state_en;
  wire                             [6:0]  dcu_fault_vmsa_wr;
  wire                             [6:0]  ifu_fault_vmsa_wr;
  wire                            [25:0]  expt_esr_wr;
  wire           [`CA53_EXPT_TYPE_W-1:0]  expt_type_wr;
  wire           [`CA53_EXPT_TYPE_W-1:0]  late_expt_type_wr;
  wire                             [1:0]  late_expt_el_wr;
  wire                             [4:0]  late_expt_aa32_mode_wr;
  wire          [`CA53_DBG_STATUS_W-1:0]  late_debug_status_wr;
  wire    [`CA53_CPSR_WR_EN_EARLY_W-1:0]  early_aa32_cpsr_wr_en_wr;
  wire [`CA53_FORCEOP_OFFSET_TYPE_W-1:0]  late_forceop_offset_type_aa32_wr;
  wire [`CA53_FORCEOP_OFFSET_TYPE_W-1:0]  early_forceop_offset_type_aa32_wr;
  wire [`CA53_FORCEOP_OFFSET_TYPE_W-1:0]  forceop_offset_type_aa32_wr;
  wire    [`CA53_CPSR_WR_EN_EARLY_W-1:0]  late_aa32_cpsr_wr_en_wr;
  wire          [`CA53_DBG_STATUS_W-1:0]  early_expt_debug_status_wr;
  wire          [`CA53_DBG_STATUS_W-1:0]  debug_status_wr;
  wire                             [4:0]  late_expt_aa32_vect_offset_wr;
  wire                                    late_expt_quash_wr;
  wire                                    late_expt_quash_slot0_wr;
  wire                                    late_expt_slot1_wr;
  wire                                    expt_fiq_taken;
  wire                                    expt_irq_taken;
  wire                                    expt_imprecise_taken;
  wire                                    expt_vimprecise_taken;
  wire                                    late_expt_ls_quash_wr;
  wire                                    expt_reset;
  wire                                    expt_fiq;
  wire                                    expt_vfiq;
  wire                                    expt_irq;
  wire                                    expt_virq;
  wire                                    expt_imprecise;
  wire                                    expt_vimprecise;
  wire                                    expt_ext_halt;
  wire                                    expt_osuc_halt;
  wire                                    expt_hard_step;
  wire                                    expt_soft_step;
  wire                                    expt_data_wr;
  wire                                    expt_stack_align_wr;
  wire                                    expt_wpt_wr;
  wire                                    expt_l1_ecc_wr;
  wire                                    take_data_expt_wr;
  wire                                    external_dabort_to_el3;
  wire                                    s2_dabort;
  wire                                    iabort_lpae_wr;
  wire                                    dcu_abort_lpae_wr;
  wire                                    imp_abort_lpae_wr;
  wire                                    wpt_lpae_wr;
  wire                                    external_iabort_ns_to_mon;
  wire                                    external_dcu_abort_ns_to_mon;
  wire                                    external_imp_abort_ns_to_mon;
  wire                                    cpsr_wr_src_wr;
  wire                                    imprecise_pending;
  wire                                    vimprecise_pending;
  wire                                    imprec_taken_qual;
  wire                                    vimprec_taken_qual;
  wire                                    imprec_taken_gov_sei;
  wire                                    imprec_taken_gov_rei;
  wire                                    vimprec_taken_hcr;
  wire                                    vimprec_taken_gov_sei;
  wire                                    expt_force_to_instr_addr;
  wire                                    taken_en;
  wire                                    nxt_ecc_suppress_async;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Decode current exception level
  assign in_el2 = (dpu_exception_level_i == `CA53_EL2); // EL2/Hyp
  assign in_el3 = (dpu_exception_level_i == `CA53_EL3); // EL3/Monitor

  // ------------------------------------------------------
  // Exception masks
  // ------------------------------------------------------
  // Mask asynchronous interrupts based on EDSCR.INTdis (debug register)
  // - When debug enabled, can disable external interrupts (including virtual
  // interrupts) based on what exception level they target.
  always @*
    case ({edscr_intdis_i[1:0], dbgen_synced_i, spiden_synced_i})
      `ca53dpu_sel_00xx,
      `ca53dpu_sel_xx00,
      `ca53dpu_sel_xx01: begin
        // Do not mask any interrupts
        intdis_mask_fiq   = 1'b0;
        intdis_mask_vfiq  = 1'b0;
        intdis_mask_irq   = 1'b0;
        intdis_mask_virq  = 1'b0;
        intdis_mask_imp   = 1'b0;
        intdis_mask_vimp  = 1'b0;
      end
      4'b01_10,
      4'b01_11: begin
        // Mask interrupts targetting nS EL1
        intdis_mask_fiq   = ns_state & ~dpu_exception_level_i[1] & ~scr_fiq_i & ~(hcr_fmo_i | hcr_tge_i); // Will not route to EL2/3
        intdis_mask_irq   = ns_state & ~dpu_exception_level_i[1] & ~scr_irq_i & ~(hcr_imo_i | hcr_tge_i);
        intdis_mask_imp   = ns_state & ~dpu_exception_level_i[1] & ~scr_ea_i  & ~(hcr_amo_i | hcr_tge_i);
        intdis_mask_vfiq  = 1'b1; // Always target nS EL1
        intdis_mask_virq  = 1'b1;
        intdis_mask_vimp  = 1'b1;
      end
      4'b10_10,
      4'b11_10: begin
        // Mask interrupts targetting nS EL1, EL2
        intdis_mask_fiq   = ns_state & ~scr_fiq_i;
        intdis_mask_irq   = ns_state & ~scr_irq_i;
        intdis_mask_imp   = ns_state & ~scr_ea_i;
        intdis_mask_vfiq  = 1'b1; // Always target nS EL1
        intdis_mask_virq  = 1'b1;
        intdis_mask_vimp  = 1'b1;
      end
      4'b10_11: begin
        // Mask interrupts targetting nS EL1, S EL1, EL2
        intdis_mask_fiq   = ~scr_fiq_i & ~(~ns_state & ~aarch64_at_el_i[3]) & ~in_el3;  // Interrupts in secure state when EL3 is AA32 always target EL3
        intdis_mask_irq   = ~scr_irq_i & ~(~ns_state & ~aarch64_at_el_i[3]) & ~in_el3;
        intdis_mask_imp   = ~scr_ea_i  & ~(~ns_state & ~aarch64_at_el_i[3]) & ~in_el3;
        intdis_mask_vfiq  = 1'b1; // Always target nS EL1
        intdis_mask_virq  = 1'b1;
        intdis_mask_vimp  = 1'b1;
      end
      4'b11_11: begin
        // Mask interrupts targetting all exception levels
        intdis_mask_fiq   = 1'b1;
        intdis_mask_irq   = 1'b1;
        intdis_mask_imp   = 1'b1;
        intdis_mask_vfiq  = 1'b1;
        intdis_mask_virq  = 1'b1;
        intdis_mask_vimp  = 1'b1;
      end
      default: begin
        intdis_mask_fiq   = 1'bx;
        intdis_mask_irq   = 1'bx;
        intdis_mask_imp   = 1'bx;
        intdis_mask_vfiq  = 1'bx;
        intdis_mask_virq  = 1'bx;
        intdis_mask_vimp  = 1'bx;
      end
    endcase

  // Create cpsr mask signals that combine the AIF control bits from the CPSR register
  // and the mask override signals from the CP15 Secure Configuration Register (SCR)
  function cpsr_mask;
    input scr_route_to_el3, scr_mask_bit_writable, hcr_mask_override, hcr_tge, aarch64_at_el3, ns_state, in_el2, in_el3;

    cpsr_mask = scr_route_to_el3 ? (aarch64_at_el3 ? in_el3
                                                   : ((hcr_mask_override | hcr_tge) ?  ~ns_state
                                                                                    : (~ns_state | scr_mask_bit_writable)))
                                 : (~(hcr_mask_override | hcr_tge) | (~ns_state | in_el2));
  endfunction

  assign cpsr_ea_mask  = cpsr_abit_ret_i & cpsr_mask(scr_ea_i,  scr_aw_i, hcr_amo_i, hcr_tge_i, aarch64_at_el_i[3], ns_state, in_el2, in_el3);
  assign cpsr_fiq_mask = cpsr_fbit_ret_i & cpsr_mask(scr_fiq_i, scr_fw_i, hcr_fmo_i, hcr_tge_i, aarch64_at_el_i[3], ns_state, in_el2, in_el3);
  assign cpsr_irq_mask = cpsr_ibit_ret_i & cpsr_mask(scr_irq_i, 1'b1,     hcr_imo_i, hcr_tge_i, aarch64_at_el_i[3], ns_state, in_el2, in_el3);

  // Mask => recognise but don't take,
  // Pend => don't recognise
  // - Distinction only matters for WFI/WFE
  assign mask_fiq = cpsr_fiq_mask   | intdis_mask_fiq;
  assign mask_irq = cpsr_irq_mask   | intdis_mask_irq;
  assign mask_ea  = cpsr_ea_mask    | intdis_mask_imp;
  assign mask_vf  = cpsr_fbit_ret_i | intdis_mask_vfiq;
  assign mask_vi  = cpsr_ibit_ret_i | intdis_mask_virq;
  assign mask_va  = cpsr_abit_ret_i | intdis_mask_vimp;

  function force_pend;
    input scr_route_to_el3, hcr_mask_override, hcr_tge, aarch64_at_el2, aarch64_at_el3, in_el2, in_el3;

    force_pend = aarch64_at_el3 & ~scr_route_to_el3 & (in_el3 | (in_el2 & aarch64_at_el2 & ~(hcr_mask_override | hcr_tge)));
  endfunction

  assign pend_ea  = force_pend(scr_ea_i,  hcr_amo_i, hcr_tge_i, aarch64_at_el_i[2], aarch64_at_el_i[3], in_el2, in_el3);
  assign pend_fiq = force_pend(scr_fiq_i, hcr_fmo_i, hcr_tge_i, aarch64_at_el_i[2], aarch64_at_el_i[3], in_el2, in_el3);
  assign pend_irq = force_pend(scr_irq_i, hcr_imo_i, hcr_tge_i, aarch64_at_el_i[2], aarch64_at_el_i[3], in_el2, in_el3);

  // - Pend virtual interrupts when in EL2-3, when TGE is set or when physical
  // interrupts are not being routed to EL2.
  assign pend_vf  = ~hcr_fmo_i | ~ns_state | in_el2 | hcr_tge_i;
  assign pend_vi  = ~hcr_imo_i | ~ns_state | in_el2 | hcr_tge_i;
  assign pend_va  = ~hcr_amo_i | ~ns_state | in_el2 | hcr_tge_i;

  // Interrupts should be suppressed between a data ECC error and the
  // re-execution of the instruction
  
  assign nxt_ecc_suppress_async = (exception_valid_wr & ~take_early_expt_wr & (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC)) |
                                  (ecc_suppress_async & (~((pre_valid_instrs_wr_i[0] & (current_state == ST_EXPT_IDLE) & ~unflushable_wr_i) & (~stall_wr_i | exception_valid_wr)) | 
                                                         (exception_valid_wr & (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC))));

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ecc_suppress_async <= 1'b0;
    else
      ecc_suppress_async <= nxt_ecc_suppress_async;

  // In addition to the architectural masking/pending of interrupts, the DPU
  // can defer exceptions for microarchitectural reasons in certain cases:
  assign defer_async_expt          = dpu_fe_valid_wr_i | dpu_fe_valid_ret_i       | // Forcing IFU address from Wr or Ret
                                     in_halt_i                                    | // Mask asynchronous interrupts in debug states
                                     ss_enter_halt_i                              | // Mask asynchronous interrupts while a step is pending
                                     (dbg_soft_step_active_i & ~cpsr_ssbit_ret_i) |
                                     no_interrupt_wr_i                            |
                                     wfx_stall_wr_i                               |
                                     ecc_suppress_async;

  assign defer_enter_hw_halt_expt  = ((dpu_fe_valid_wr_i | dpu_fe_valid_ret_i |
                                       no_interrupt_wr_i |
                                       wfx_stall_wr_i) &
                                      ~dbg_cancel_biu_i) |
                                     in_halt_i           |
                                     ecc_suppress_async;

  assign defer_step_expt           = unflushable_wr_i   |
                                     dpu_fe_valid_ret_i |
                                     no_interrupt_wr_i  |
                                     wfx_stall_wr_i;

  // ------------------------------------------------------
  // Imprecise data abort trigger
  // ------------------------------------------------------
  // The imprecise abort input from the BIU is pulsed for one cycle, so need
  // to register and hold in DPU until exception is taken. Note imprecise
  // aborts are ignored when halted.

  // Clear imprecise abort when taking imprecise abort exception
  assign clear_imp_abort = expt_imprecise_taken & (current_state == ST_EXPT_IDLE);

  assign nxt_imp_abort_pending = biu_w_imp_abort_i | (imp_abort_pending & ~clear_imp_abort);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      imp_abort_pending <= 1'b0;
    else
      imp_abort_pending <= nxt_imp_abort_pending;

  // Register ExT fault information when registering new imprecise abort to
  // use when reporting fault in DFSR
  assign set_imp_abort = biu_w_imp_abort_i & (~imp_abort_pending | clear_imp_abort);

  assign nxt_imp_abort_fault = set_imp_abort ? biu_w_imp_fault_i :  // Register when setting imprecise abort
                                               imp_abort_fault;     // Otherwise maintain

  always @(posedge clk)
    imp_abort_fault <= nxt_imp_abort_fault;

  // ------------------------------------------------------
  // Imprecise abort/System error handling
  // ------------------------------------------------------

  assign imprecise_pending     = imp_abort_pending | gov_sei_reg  | gov_rei_reg;
  assign vimprecise_pending    = hcr_va_i          | gov_vsei_reg;

  assign imprec_taken_qual     = expt_imprecise_taken  & (current_state == ST_EXPT_IDLE);
  assign vimprec_taken_qual    = expt_vimprecise_taken & (current_state == ST_EXPT_IDLE);

  assign imprec_taken_gov_sei  = imprec_taken_qual & ~imp_abort_pending &  gov_sei_reg;
  assign imprec_taken_gov_rei  = imprec_taken_qual & ~imp_abort_pending & ~gov_sei_reg & gov_rei_reg;

  assign vimprec_taken_hcr     = vimprec_taken_qual &  hcr_va_i;
  assign vimprec_taken_gov_sei = vimprec_taken_qual & ~hcr_va_i & gov_vsei_reg;

  assign taken_en = gov_int_active_reg | dpu_sei_level_ack | dpu_vsei_level_ack | dpu_rei_level_ack;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_sei_level_ack   <= 1'b0;
      dpu_vsei_level_ack  <= 1'b0;
      dpu_rei_level_ack   <= 1'b0;
    end else if (taken_en) begin
      dpu_sei_level_ack   <= imprec_taken_gov_sei;
      dpu_vsei_level_ack  <= vimprec_taken_gov_sei;
      dpu_rei_level_ack   <= imprec_taken_gov_rei;
    end

  // Clear virtual imprecise abort when it is taken
  assign clear_virtual_ea_o = vimprec_taken_hcr;

  // ------------------------------------------------------
  // Detect and route late exceptions
  // ------------------------------------------------------
  // Late exceptions are all asynchronous exceptions and DCU aborts, which are
  // detected and routed in Wr. All other synchronous exceptions are detected
  // and routed in Iss and pipelined.

  // Register interrupt signals from GIC to decouple timing
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      gov_int_active_reg <= 1'b0;
    else
      gov_int_active_reg <= gov_int_active_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      gic_irq_reg   <= 1'b0;
      gic_fiq_reg   <= 1'b0;
      gic_virq_reg  <= 1'b0;
      gic_vfiq_reg  <= 1'b0;
      gov_sei_reg   <= 1'b0;
      gov_vsei_reg  <= 1'b0;
      gov_rei_reg   <= 1'b0;
    end else if (gov_int_active_reg) begin
      gic_irq_reg   <= gic_irq_i;
      gic_fiq_reg   <= gic_fiq_i;
      gic_virq_reg  <= gic_virq_i;
      gic_vfiq_reg  <= gic_vfiq_i;
      gov_sei_reg   <= gov_sei_level_req_i;
      gov_vsei_reg  <= gov_vsei_level_req_i;
      gov_rei_reg   <= gov_rei_level_req_i;
    end

  // Asynchronous exceptions
  assign expt_reset         = (current_state == ST_EXPT_RESET_FLUSH);
  assign expt_fiq           = gic_fiq_reg                & ~defer_async_expt         & ~mask_fiq & ~pend_fiq;
  assign expt_irq           = gic_irq_reg                & ~defer_async_expt         & ~mask_irq & ~pend_irq;
  assign expt_imprecise     = imprecise_pending          & ~defer_async_expt         & ~mask_ea  & ~pend_ea;
  assign expt_vfiq          = (gic_vfiq_reg | hcr_vf_i)  & ~defer_async_expt         & ~mask_vf  & ~pend_vf;
  assign expt_virq          = (gic_virq_reg | hcr_vi_i)  & ~defer_async_expt         & ~mask_vi  & ~pend_vi;
  assign expt_vimprecise    = vimprecise_pending         & ~defer_async_expt         & ~mask_va  & ~pend_va;
  assign expt_ext_halt      = held_dbg_ext_hw_halt_req_i & ~defer_enter_hw_halt_expt;
  assign expt_osuc_halt     = held_dbg_osuc_halt_req_i   & ~defer_enter_hw_halt_expt;

  // Single-step exceptions
  assign expt_hard_step     = ss_enter_halt_i                            & pre_valid_instrs_wr_i[0] & pre_head_instr0_wr_i & ~defer_step_expt;
  assign expt_soft_step     = dbg_soft_step_active_i & ~cpsr_ssbit_ret_i & pre_valid_instrs_wr_i[0] & pre_head_instr0_wr_i & ~defer_step_expt;

  // Precise data aborts (from DCU)
  assign sample_dcu_wr = ls_valid_wr_i                          & // Transaction in wr
                         (slot1_ls_wr_i ? cc_pass_instr1_wr_i :   // Instruction passed
                                          cc_pass_instr0_wr_i)  &
                         ~stall_wr_i                            & // Instruction is not stalled
                         ~br_flush_ret_i &                        // Not being flushed
                         ~slot0_br_flush_wr_i;

  assign expt_data_wr        = dcu_p_abort_dc3_i & sample_dcu_wr & ~(dcu_wpt_hit_dc3_i & external_dabort) & ~stack_align_abort;  // Ignore external aborts on watchpoints
  assign expt_stack_align_wr = dcu_p_abort_dc3_i & sample_dcu_wr & stack_align_abort;
  assign expt_wpt_wr         = dcu_wpt_hit_dc3_i & sample_dcu_wr & (~dcu_p_abort_dc3_i | external_dabort);
  assign expt_l1_ecc_wr      = dcu_ecc_err_dc3_i & sample_dcu_wr;

  // The logic to control the routing of late interrupts is generated automatically
  assign external_dabort    = `CA53_FAULT_GEN_EXT(dcu_p_fault_dc3_i);
  assign stack_align_abort  = `CA53_FAULT_STACK_ALIGN(dcu_p_fault_dc3_i);

  assign external_dabort_to_el3 = external_dabort & scr_ea_i & ~in_halt_i;
  assign s2_dabort = dcu_p_fault_stage_dc3_i[1];

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  wire   net_1, net_2, net_3, net_4, net_5, net_6, net_7, net_8, net_9, net_10,
         net_11, net_12, net_13, net_14, net_15, net_16, net_17, net_18,
         net_19, net_21, net_22, net_23, net_24, net_25, net_26, net_27,
         net_29, net_30, net_31, net_32, net_33, net_34, net_35, net_36,
         net_37, net_38, net_39, net_40, net_41, net_42, net_43, net_44,
         net_45, net_46, net_47, net_48, net_49, net_50, net_51, net_52,
         net_53, net_54, net_55, net_56, net_57, net_58, net_59, net_60,
         net_61, net_62, net_63, net_64, net_65, net_66, net_67, net_68,
         net_69, net_70, net_71, net_72, net_73, net_74, net_75, net_76,
         net_77, net_78, net_79, net_80, net_81, net_82, net_83, net_84,
         net_85, net_86, net_87, net_88, net_89, net_90, net_91, net_92,
         net_93, net_94, net_95, net_96, net_97, net_98, net_99, net_100,
         net_101, net_102, net_103, net_104, net_105, net_106, net_107,
         net_108, net_109, net_110, net_111, net_112, net_113, net_114,
         net_115, net_116, net_117, net_118, net_119, net_120, net_121,
         net_122, net_123, net_124, net_125, net_126, net_127, net_128,
         net_129, net_130, net_131, net_132, net_133, net_134, net_135,
         net_136, net_137, net_138, net_139, net_140, net_141, net_142,
         net_143, net_144, net_145, net_146, net_147, net_148, net_149,
         net_150, net_151, net_152, net_153, net_154, net_155, net_156,
         net_160, net_166, net_167, net_168, net_169, net_170, net_171,
         net_172, net_173, net_174, net_175, net_181, net_185, net_186,
         net_187, net_188, net_189, net_190, net_191, net_192, net_193,
         net_194, net_195, net_196, net_197, net_198, net_199, net_200,
         net_201, net_202, net_203, net_204, net_207, net_208, net_209,
         net_210, net_211, net_212, net_213, net_214, net_215, net_216,
         net_217, net_218, net_219, net_220, net_221, net_222, net_223,
         net_224, net_225, net_226, net_227, net_228, net_229, net_230,
         net_231, net_232, net_233, net_234, net_235, net_236, net_237,
         net_238, net_239, net_240, net_241, net_242, net_243, net_244,
         net_245, net_246, net_247, net_248, net_249, net_250, net_251,
         net_252, net_253, net_254, net_255, net_256, net_257, net_258,
         net_259, net_260, net_261, net_262, net_263, net_264, net_265,
         net_266, net_267, net_268, net_269, net_270, net_271, net_272,
         net_273, net_274, net_275, net_276, net_277, net_278, net_279,
         net_280, net_281, net_282, net_283, net_284, net_285, net_286,
         net_287, net_288, net_289, net_290, net_291, net_292, net_293,
         net_294, net_295, net_296, net_297, net_298, net_299, net_300,
         net_301, net_302, net_303, net_304, net_305, net_306, net_307,
         net_308, net_309, net_310, net_311, net_312, net_313, net_314,
         net_315, net_316, net_317, net_318, net_319, net_320, net_321,
         net_322, net_323, net_324, net_325, net_326, net_327, net_328,
         net_329, net_330, net_331, net_332, net_333, net_334, net_335,
         net_336, net_337, net_338, net_339, net_340, net_341, net_342,
         net_343, net_344, net_345, net_346, net_347, net_348, net_349,
         net_350, net_351, net_352, net_353, net_354, net_355, net_356,
         net_357, net_358, net_359, net_360, net_361, net_362, net_363,
         net_364, net_365, net_366, net_367, net_368, net_369, net_370,
         net_371, net_372, net_373, net_374, net_375, net_376, net_377,
         net_378, net_379, net_380, net_381, net_382, net_383, net_384,
         net_385, net_386, net_387, net_388, net_389, net_390, net_391,
         net_392, net_393, net_394, net_395;

  assign late_expt_aa32_vect_offset_wr[1] = 1'b0;
  assign late_expt_aa32_vect_offset_wr[0] = 1'b0;
  assign net_1 = ~net_325;
  assign net_2 = ~expt_reset;
  assign net_3 = ~expt_early_hipri_wr;
  assign net_4 = ~expt_soft_step;
  assign net_5 = ~expt_fiq;
  assign net_6 = ~net_128;
  assign net_7 = ~net_82;
  assign net_8 = ~expt_vfiq;
  assign net_9 = ~expt_irq;
  assign net_10 = ~net_86;
  assign net_11 = ~net_174;
  assign net_12 = ~expt_imprecise;
  assign net_13 = ~expt_vimprecise;
  assign net_14 = ~net_131;
  assign net_15 = ~net_172;
  assign net_16 = ~expt_early_ccfail_wr;
  assign net_17 = ~net_91;
  assign net_18 = ~expt_stack_align_wr;
  assign net_19 = ~net_311;
  assign net_21 = ~expt_data_wr;
  assign net_22 = ~expt_wpt_wr;
  assign net_23 = ~dbg_restart_qual_i;
  assign net_24 = ~net_263;
  assign net_25 = ~net_181;
  assign net_26 = ~net_254;
  assign net_27 = ~dpu_exception_level_i[1];
  assign take_early_expt_wr = (net_2 & net_29);
  assign net_29 = (expt_early_hipri_wr | net_30);
  assign net_30 = (expt_early_lopri_wr & net_31);
  assign net_31 = ~(expt_hard_step | net_32);
  assign take_data_expt_wr = (expt_imprecise_taken | net_33);
  assign net_33 = ~(net_34 & net_35);
  assign net_35 = ~(net_36 & net_37);
  assign net_37 = ~(net_38 | net_14);
  assign late_forceop_offset_type_aa32_wr[1] = (expt_imprecise_taken | net_39);
  assign net_39 = ~(net_40 & net_41);
  assign net_41 = ~(net_42 & net_43);
  assign net_40 = (net_38 | net_44);
  assign late_forceop_offset_type_aa32_wr[0] = (net_45 | net_46);
  assign net_46 = ~(net_47 & net_48);
  assign net_48 = ~(net_49 & net_15);
  assign net_47 = ~(net_50 & net_42);
  assign net_50 = (expt_early_ccfail_wr & net_51);
  assign late_expt_type_wr[4] = (net_52 & net_53);
  assign net_53 = (expt_stack_align_wr | net_54);
  assign net_54 = (expt_l1_ecc_wr & net_55);
  assign late_expt_type_wr[3] = ~(expt_hard_step | net_56);
  assign net_56 = ~(net_57 & net_58);
  assign net_58 = (net_59 | expt_soft_step);
  assign net_59 = (net_51 & net_60);
  assign net_60 = (expt_early_ccfail_wr | net_61);
  assign late_expt_type_wr[2] = ~(net_62 & net_1);
  assign net_62 = ~(net_63 & net_64);
  assign net_64 = (net_65 | net_66);
  assign net_66 = (net_67 & net_68);
  assign late_expt_type_wr[1] = ~(net_1 & net_69);
  assign net_69 = ~(net_70 & net_71);
  assign net_71 = (net_72 | net_73);
  assign net_72 = ~(net_74 & net_75);
  assign net_75 = (net_76 | expt_early_lopri_wr);
  assign net_76 = (net_16 & net_77);
  assign net_77 = (expt_stack_align_wr | net_78);
  assign net_70 = (net_63 & net_79);
  assign late_expt_type_wr[0] = ~(net_80 & net_81);
  assign net_81 = ~(net_82 & net_83);
  assign net_83 = ~(net_84 | net_85);
  assign net_85 = (net_86 & net_87);
  assign net_87 = ~(net_74 & net_88);
  assign net_88 = (net_89 | net_73);
  assign net_89 = (net_67 & net_90);
  assign net_90 = (net_91 | net_92);
  assign net_92 = (net_18 & net_93);
  assign net_93 = (net_94 | net_95);
  assign net_95 = (expt_wpt_wr & dbg_bkpt_wpt_en_i);
  assign net_94 = (net_22 & net_96);
  assign net_96 = (expt_l1_ecc_wr | dbg_restart_qual_i);
  assign late_expt_slot1_wr = ~(net_97 | net_98);
  assign net_98 = ~(slot1_ls_wr_i & net_52);
  assign late_expt_quash_wr = ~(net_99 & net_100);
  assign late_expt_quash_slot0_wr = ~(net_99 & net_101);
  assign net_101 = (slot1_ls_wr_i | net_100);
  assign net_100 = (net_97 | net_102);
  assign net_99 = ~(net_103 | late_expt_ls_quash_wr);
  assign net_103 = ~(net_16 | net_102);
  assign net_102 = (expt_early_hipri_wr | expt_early_lopri_wr);
  assign late_expt_ls_quash_wr = ~(net_80 & net_104);
  assign net_104 = ~(net_3 & net_32);
  assign net_32 = (net_65 | expt_soft_step);
  assign late_expt_el_wr[1] = ~(net_105 & net_2);
  assign net_105 = (net_106 & net_107);
  assign net_107 = ~(net_108 & net_109);
  assign net_109 = (hdcr_tde_i & net_110);
  assign net_110 = (ns_state & net_111);
  assign net_111 = (expt_soft_step | net_112);
  assign net_112 = (net_113 & net_114);
  assign net_106 = ~(net_115 & net_116);
  assign net_116 = (net_117 | net_118);
  assign net_118 = (net_119 | net_120);
  assign net_120 = ~(net_121 & net_122);
  assign net_122 = ~(dpu_exception_level_i[1] & net_123);
  assign net_123 = ~(net_124 | net_14);
  assign net_121 = (net_7 | net_125);
  assign net_119 = ~(net_126 & net_127);
  assign net_127 = (net_27 | net_128);
  assign net_126 = ~(net_129 | net_130);
  assign net_130 = (net_131 & net_132);
  assign net_132 = (net_133 | net_134);
  assign net_134 = (net_128 & net_135);
  assign net_133 = ~(net_136 | net_137);
  assign net_137 = ~(dpu_exception_level_i[1] | net_138);
  assign net_138 = ~(expt_virq | net_139);
  assign net_139 = (expt_vimprecise | net_140);
  assign net_140 = ~(net_141 & ns_state);
  assign net_117 = (ns_state & net_142);
  assign net_142 = (net_143 | net_144);
  assign net_144 = (hcr_imo_i & net_145);
  assign net_143 = (net_146 | net_147);
  assign net_147 = (net_148 | net_149);
  assign net_149 = (net_141 & net_150);
  assign net_150 = (expt_irq | net_151);
  assign net_151 = ~(net_12 | expt_virq);
  assign net_141 = (hcr_tge_i & net_8);
  assign net_148 = (net_152 & net_114);
  assign net_146 = ~(net_153 & net_154);
  assign net_154 = ~(expt_fiq & net_155);
  assign net_153 = ~(net_82 & net_156);
  assign net_167 = ~(net_168 & net_169);
  assign net_169 = ~(expt_imprecise | net_170);
  assign net_170 = ~(net_171 | net_172);
  assign net_173 = (net_174 & net_175);
  assign net_108 = ~(expt_hard_step | expt_early_hipri_wr);
  assign net_171 = (net_136 & net_124);
  assign net_186 = (dpu_exception_level_i[1] | net_187);
  assign net_187 = ~(expt_vfiq | net_188);
  assign net_188 = ~(net_189 & net_190);
  assign net_190 = ~(net_191 & expt_irq);
  assign net_189 = (net_192 | expt_irq);
  assign net_192 = ~(expt_virq | net_193);
  assign net_193 = ~(net_194 & net_195);
  assign net_195 = (net_196 | hcr_tge_i);
  assign net_196 = (net_197 & net_198);
  assign net_198 = (net_12 | hcr_amo_i);
  assign net_197 = (net_199 | net_11);
  assign net_199 = ~(expt_stack_align_wr | net_200);
  assign net_200 = ~(net_21 | s2_dabort);
  assign net_185 = (net_201 | expt_vfiq);
  assign net_201 = (net_125 & net_202);
  assign net_202 = ~(net_203 & net_204);
  assign late_expt_aa32_vect_offset_wr[4] = (net_208 | late_expt_aa32_vect_offset_wr[3]);
  assign net_208 = (net_42 & net_209);
  assign net_209 = ~(net_44 & net_12);
  assign net_44 = (net_13 & net_210);
  assign net_210 = (net_14 | net_211);
  assign late_expt_aa32_vect_offset_wr[3] = (expt_fiq_taken | net_212);
  assign late_expt_aa32_vect_offset_wr[2] = (expt_fiq_taken | net_213);
  assign net_213 = (net_42 & net_214);
  assign net_214 = (net_215 | net_216);
  assign net_216 = (net_203 & net_217);
  assign net_203 = (net_15 & net_218);
  assign net_215 = (net_219 & net_220);
  assign net_220 = (net_221 & net_86);
  assign late_expt_aa32_mode_wr[4] = (net_222 | net_223);
  assign net_223 = (net_224 | expt_reset);
  assign net_224 = (net_115 & net_6);
  assign late_expt_aa32_mode_wr[3] = (net_225 | net_226);
  assign net_226 = ~(scr_ea_i | net_227);
  assign net_227 = ~(net_219 & expt_imprecise_taken);
  assign net_219 = (net_228 & net_229);
  assign net_225 = (net_42 & net_230);
  assign net_230 = (net_231 | net_43);
  assign net_43 = ~(net_232 & net_233);
  assign net_233 = (net_191 | net_234);
  assign net_234 = (scr_irq_i | net_235);
  assign net_235 = ~(net_145 & net_228);
  assign net_232 = (net_236 & net_237);
  assign net_237 = ~(net_238 & net_239);
  assign net_236 = (net_240 | expt_fiq);
  assign net_240 = (net_241 | net_26);
  assign net_241 = (net_242 & net_243);
  assign net_243 = ~(expt_virq & net_9);
  assign net_242 = ~(expt_vfiq | net_244);
  assign net_244 = ~(scr_irq_i | net_9);
  assign net_231 = ~(net_245 & net_246);
  assign net_246 = ~(net_51 & net_217);
  assign net_217 = (expt_early_ccfail_wr | net_247);
  assign net_247 = (net_228 & net_248);
  assign net_248 = (net_249 | net_250);
  assign net_250 = (net_113 & hdcr_tde_i);
  assign net_249 = (net_251 & net_252);
  assign net_51 = (net_15 & net_128);
  assign net_245 = ~(net_168 & net_253);
  assign net_253 = (net_254 & net_255);
  assign net_255 = ~(net_256 & net_194);
  assign net_168 = ~(expt_fiq | expt_irq);
  assign late_expt_aa32_mode_wr[2] = (net_257 | net_258);
  assign net_258 = (net_259 | net_45);
  assign net_45 = ~(net_260 & net_261);
  assign net_261 = ~(expt_imprecise_taken & net_262);
  assign net_262 = ~(net_263 & net_264);
  assign net_264 = ~(scr_ea_i | net_265);
  assign net_260 = (net_266 & net_267);
  assign net_267 = ~(expt_vimprecise_taken & net_27);
  assign net_266 = (net_25 | net_34);
  assign net_34 = (net_13 | net_38);
  assign net_259 = (net_131 & net_49);
  assign net_49 = (net_268 & net_18);
  assign net_268 = ~(net_38 | net_269);
  assign net_269 = (net_270 & net_271);
  assign net_271 = ~(net_272 & net_12);
  assign net_272 = (net_273 | net_274);
  assign net_274 = (expt_data_wr & net_275);
  assign net_275 = (net_276 | net_277);
  assign net_277 = (external_dabort_to_el3 & net_13);
  assign net_273 = (net_21 & net_278);
  assign net_278 = (net_279 & expt_wpt_wr);
  assign net_270 = ~(net_280 & net_24);
  assign net_257 = (net_42 & net_281);
  assign net_281 = (net_129 | net_282);
  assign net_282 = (scr_irq_i & net_145);
  assign net_145 = (expt_irq & net_82);
  assign late_expt_aa32_mode_wr[1] = (net_160 | net_283);
  assign net_283 = (net_284 | net_285);
  assign net_285 = (net_115 & net_286);
  assign net_286 = (net_287 | net_288);
  assign net_288 = (expt_fiq & net_239);
  assign net_239 = ~(net_26 & net_289);
  assign net_289 = ~(net_228 & net_155);
  assign net_287 = ~(net_290 & net_291);
  assign net_291 = ~(expt_vfiq & net_254);
  assign net_290 = (net_7 | net_218);
  assign net_284 = (net_82 & net_222);
  assign net_222 = (net_292 & net_293);
  assign net_293 = ~(net_16 & net_211);
  assign net_211 = ~(net_18 & net_280);
  assign net_280 = ~(net_21 & net_124);
  assign net_124 = (dbg_bkpt_wpt_en_i | net_22);
  assign net_292 = (net_115 & net_15);
  assign net_160 = (expt_reset | net_294);
  assign net_294 = (net_115 & net_129);
  assign net_129 = (expt_fiq & scr_fiq_i);
  assign late_expt_aa32_mode_wr[0] = (expt_reset | net_295);
  assign net_295 = (net_115 & net_296);
  assign net_296 = (net_297 | net_298);
  assign net_298 = ~(expt_fiq | net_299);
  assign net_299 = (net_300 & net_301);
  assign net_301 = ~(expt_vfiq & net_26);
  assign net_300 = ~(net_86 & net_302);
  assign net_302 = ~(net_303 & net_304);
  assign net_304 = (net_194 | net_254);
  assign net_303 = ~(net_305 | net_306);
  assign net_306 = ~(net_307 & net_308);
  assign net_308 = ~(net_265 & net_221);
  assign net_265 = ~(dpu_exception_level_i[1] | net_229);
  assign net_229 = (hcr_tge_i | hcr_amo_i);
  assign net_307 = (net_263 | net_256);
  assign net_256 = ~(net_221 | net_309);
  assign net_309 = ~(net_11 | net_310);
  assign net_310 = ~(net_251 | net_113);
  assign net_113 = ~(dbg_bkpt_wpt_en_i | net_19);
  assign net_221 = ~(scr_ea_i | net_12);
  assign net_305 = (net_174 & net_312);
  assign net_312 = ~(net_313 & net_314);
  assign net_314 = ~(net_276 & net_251);
  assign net_251 = ~(external_dabort_to_el3 | net_17);
  assign net_276 = ~(dpu_exception_level_i[1] | net_252);
  assign net_252 = (hcr_tge_i | s2_dabort);
  assign net_313 = ~(net_175 | net_315);
  assign net_315 = (expt_early_ccfail_wr & net_316);
  assign net_316 = ~(expt_vfiq | expt_vimprecise);
  assign net_175 = (net_279 & net_311);
  assign net_279 = ~(dpu_exception_level_i[1] | net_317);
  assign net_317 = (dbg_bkpt_wpt_en_i | hdcr_tde_i);
  assign net_174 = ~(expt_imprecise | net_172);
  assign net_297 = (net_238 & net_318);
  assign net_318 = (net_207 | net_24);
  assign net_263 = ~(net_181 | net_166);
  assign net_166 = ~(dpu_exception_level_i[1] | ns_state);
  assign net_181 = (dpu_exception_level_i[1] & dpu_exception_level_i[0]);
  assign net_207 = ~(dpu_exception_level_i[1] | net_155);
  assign net_155 = (hcr_tge_i | hcr_fmo_i);
  assign net_238 = ~(scr_fiq_i | net_5);
  assign late_debug_status_wr[3] = ~(net_319 & net_320);
  assign net_320 = (net_321 | expt_ext_halt);
  assign net_321 = (net_6 | net_322);
  assign net_322 = ~(net_42 & net_323);
  assign net_323 = (expt_osuc_halt | net_324);
  assign net_324 = (net_311 & net_67);
  assign net_319 = (net_1 | halt_step_isv_i);
  assign late_debug_status_wr[1] = (net_326 | net_325);
  assign net_326 = (net_311 & net_327);
  assign net_327 = (net_63 & net_114);
  assign late_debug_status_wr[0] = (net_325 & net_328);
  assign net_328 = (halt_step_isv_i & step_ex_i);
  assign late_aa32_cpsr_wr_en_wr[1] = ~(net_80 & net_329);
  assign net_329 = (net_330 | net_84);
  assign net_330 = ~(net_65 | net_331);
  assign net_331 = ~(net_78 | net_332);
  assign net_332 = ~(net_67 & net_18);
  assign net_78 = (net_55 & net_333);
  assign net_333 = (expt_l1_ecc_wr | net_23);
  assign net_65 = (net_73 | net_6);
  assign late_aa32_cpsr_wr_en_wr[0] = ~(net_80 & net_334);
  assign net_334 = (net_84 | net_335);
  assign net_335 = ~(net_336 | net_337);
  assign net_337 = (net_254 & net_338);
  assign net_338 = ~(net_339 & net_218);
  assign net_339 = (expt_stack_align_wr | net_340);
  assign net_340 = (net_55 | expt_early_lopri_wr);
  assign net_55 = (net_22 & net_21);
  assign net_254 = ~(dpu_exception_level_i[0] | net_27);
  assign net_336 = (net_341 | net_342);
  assign net_342 = (net_343 | net_344);
  assign net_344 = ~(net_125 & net_82);
  assign net_125 = (net_345 & net_346);
  assign net_346 = ~(scr_irq_i & expt_irq);
  assign net_345 = ~(scr_ea_i & net_347);
  assign net_343 = (net_218 & net_348);
  assign net_348 = (net_73 | net_349);
  assign net_349 = ~(expt_early_lopri_wr | net_350);
  assign net_350 = ~(net_204 | net_351);
  assign net_351 = (net_68 | net_352);
  assign net_352 = (net_228 & net_353);
  assign net_353 = (net_152 | net_354);
  assign net_354 = (net_311 & hdcr_tde_i);
  assign net_152 = (s2_dabort & net_91);
  assign net_68 = (net_61 | net_355);
  assign net_204 = (expt_early_ccfail_wr | net_135);
  assign net_135 = (external_dabort_to_el3 & net_91);
  assign net_341 = (net_228 & net_356);
  assign net_356 = (net_357 | net_156);
  assign net_156 = (hcr_amo_i & net_347);
  assign net_347 = (expt_imprecise & net_86);
  assign net_357 = ~(net_358 & net_359);
  assign net_359 = (net_360 | expt_virq);
  assign net_360 = ~(hcr_tge_i & net_361);
  assign net_361 = ~(net_12 & net_362);
  assign net_362 = (net_363 | expt_vimprecise);
  assign net_363 = (expt_early_lopri_wr | net_17);
  assign net_91 = (expt_data_wr & net_18);
  assign net_358 = (net_9 | net_191);
  assign net_191 = ~(hcr_tge_i | hcr_imo_i);
  assign net_228 = (ns_state & net_27);
  assign net_80 = (net_2 & net_364);
  assign net_364 = ~(expt_hard_step & net_3);
  assign expt_vimprecise_taken = ~(net_194 | net_38);
  assign net_194 = ~(expt_vimprecise & net_12);
  assign expt_irq_taken = (net_82 & net_212);
  assign net_212 = (net_10 & net_42);
  assign expt_imprecise_taken = ~(net_12 | net_38);
  assign net_38 = ~(net_42 & net_79);
  assign net_79 = (net_86 & net_82);
  assign expt_fiq_taken = (net_42 & net_7);
  assign exception_valid_nostate_wr = ~(net_97 & net_365);
  assign net_365 = (net_23 & net_52);
  assign enter_halt_wr = (late_debug_status_wr[2] | net_366);
  assign net_366 = ~(net_367 & net_368);
  assign net_368 = ~(net_369 & net_4);
  assign net_369 = (net_128 & net_370);
  assign net_370 = (net_371 | net_372);
  assign net_372 = (expt_early_lopri_wr & net_373);
  assign net_371 = (net_57 & net_374);
  assign net_374 = (expt_osuc_halt | net_375);
  assign net_375 = (net_355 & net_67);
  assign net_67 = ~(expt_early_lopri_wr | expt_early_ccfail_wr);
  assign net_355 = (dbg_bkpt_wpt_en_i & net_311);
  assign net_311 = (net_136 & expt_wpt_wr);
  assign net_367 = ~(net_373 & expt_early_hipri_wr);
  assign net_373 = (early_expt_enter_halt_wr & net_2);
  assign late_debug_status_wr[2] = (net_376 | net_325);
  assign net_325 = (expt_hard_step & net_57);
  assign net_376 = (expt_ext_halt & net_377);
  assign net_377 = (net_63 & net_128);
  assign net_63 = (net_57 & net_4);
  assign net_57 = (net_3 & net_2);
  assign cpsr_wr_src_wr = (net_61 & net_52);
  assign net_52 = (net_42 & net_114);
  assign net_114 = (net_128 & net_131);
  assign net_131 = ~(expt_early_ccfail_wr | net_172);
  assign net_172 = (expt_early_lopri_wr | net_73);
  assign net_73 = (expt_ext_halt | expt_osuc_halt);
  assign net_128 = (net_218 & net_82);
  assign net_82 = ~(expt_fiq | expt_vfiq);
  assign net_218 = (net_86 & net_74);
  assign net_74 = ~(expt_vimprecise | expt_imprecise);
  assign net_86 = ~(expt_irq | expt_virq);
  assign net_42 = (net_115 & net_2);
  assign net_115 = ~(expt_hard_step | net_84);
  assign net_84 = (expt_soft_step | expt_early_hipri_wr);
  assign net_61 = (net_97 & dbg_restart_qual_i);
  assign net_97 = ~(expt_l1_ecc_wr | net_36);
  assign net_36 = ~(net_136 & net_22);
  assign net_136 = ~(expt_stack_align_wr | expt_data_wr);
  assign net_378 = (net_128 | net_25);
  assign net_379 = ~(expt_fiq & net_207);
  assign net_380 = ~(net_378 & net_379);
  assign net_381 = (net_185 & net_186);
  assign net_382 = ~(expt_fiq | net_381);
  assign net_383 = (net_382 | net_380);
  assign net_384 = ~(net_181 & net_15);
  assign net_385 = ~(net_171 | net_384);
  assign net_386 = (net_385 | net_383);
  assign net_387 = ~(net_167 & net_166);
  assign net_388 = ~(net_173 & net_168);
  assign net_389 = ~(net_387 & net_388);
  assign net_390 = ~(ns_state & hdcr_tde_i);
  assign net_391 = (expt_soft_step & net_390);
  assign net_392 = (net_391 | net_389);
  assign net_393 = (net_108 & net_392);
  assign net_394 = (net_115 & net_386);
  assign net_395 = (net_394 | net_393);
  assign late_expt_el_wr[0] = (net_160 | net_395);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Final routing of late exceptions in Wr
  // ------------------------------------------------------
  // Perform the final steps of routing late exceptions manually and combine with
  // pipelined information for early exceptions.

  // Auto-generated logic calculates mode assuming targetting AA32, and does not deal with
  // the fact that when EL3 is AA32 there is no secure EL1.
  always @*
    case (late_expt_el_wr)
      `CA53_EL3: begin
        final_late_expt_el_wr   = late_expt_el_wr;
        final_late_expt_mode_wr = aarch64_at_el_i[3] ? `CA53_FULL_MODE_EL3H : late_expt_aa32_mode_wr;
      end
      `CA53_EL2: begin
        final_late_expt_el_wr   = late_expt_el_wr;
        final_late_expt_mode_wr = aarch64_at_el_i[2] ? `CA53_FULL_MODE_EL2H : late_expt_aa32_mode_wr;
      end
      `CA53_EL1: begin
        case (~aarch64_at_el_i[3] & ~ns_state)
          1'b1: begin
            // Targetting Secure EL1, but EL3 is AA32, so actually need to go to EL3
            final_late_expt_el_wr   = `CA53_EL3;
            final_late_expt_mode_wr = late_expt_aa32_mode_wr;
          end
          1'b0: begin
            final_late_expt_el_wr   = late_expt_el_wr;
            final_late_expt_mode_wr = aarch64_at_el_i[1] ? `CA53_FULL_MODE_EL1H : late_expt_aa32_mode_wr;
          end
          default: begin
            final_late_expt_el_wr   = 2'bxx;
            final_late_expt_mode_wr = 5'bxxxxx;
          end
        endcase
      end
      `CA53_EL0: begin
        // Default if no late exception, keep late signals at 0 to make muxing easier
        final_late_expt_el_wr   = late_expt_el_wr;
        final_late_expt_mode_wr = late_expt_aa32_mode_wr;
      end
      default: begin
        final_late_expt_el_wr   = 2'bxx;
        final_late_expt_mode_wr = 5'bxxxxx;
      end
    endcase

  // ------------------------------------------------------
  // Detect early exceptions
  // ------------------------------------------------------
  // Pick up exceptions which have been detected using the early logic
  // earlier in the pipeline.
  // - Indicated by the instr_type from the control pipeline

  // Early exceptions are routed in Iss and pipelined to Wr down store pipe 0.
  // - Unpack exception information from store data
  assign early_expt_type_wr                = exception_data_wr_i[`CA53_EXPT_BUS_EXPT_TYPE_BITS];
  assign early_expt_el_wr                  = exception_data_wr_i[`CA53_EXPT_BUS_TARGET_EL_BITS];
  assign early_expt_mode_wr                = exception_data_wr_i[`CA53_EXPT_BUS_TARGET_MODE_BITS];
  assign early_expt_quash_wr               = exception_data_wr_i[`CA53_EXPT_BUS_QUASH_BIT];
  assign early_aa32_cpsr_wr_en_wr          = exception_data_wr_i[`CA53_EXPT_BUS_CPSR_BITS];
  assign early_expt_aa32_vect_offset_wr    = {exception_data_wr_i[`CA53_EXPT_BUS_VEC_OFFSET_BITS], 2'b00}; // Always word aligned
  assign early_expt_enter_halt_wr          = exception_data_wr_i[`CA53_EXPT_BUS_ENTER_HALT_BIT];
  assign early_expt_ec_wr                  = exception_data_wr_i[`CA53_EXPT_BUS_EC_BITS];
  assign early_expt_esr_wr                 = exception_data_wr_i[`CA53_EXPT_BUS_ESR_BITS];
  assign early_expt_high_priority_wr       = exception_data_wr_i[`CA53_EXPT_BUS_HIGH_PRI_BIT];
  assign early_forceop_offset_type_aa32_wr = exception_data_wr_i[`CA53_EXPT_BUS_FORCEOP_BITS];
  assign early_expt_debug_status_wr        = exception_data_wr_i[`CA53_EXPT_BUS_DBG_STATUS_BITS];

  // Detect early exceptions
  assign early_expt_is_conditional_wr = (early_expt_type_wr == `CA53_EXPT_TYPE_CALL)      | // Only call-type exceptions are conditional
                                        (early_expt_type_wr == `CA53_EXPT_TYPE_COND_TRAP) |
                                        (early_expt_type_wr == `CA53_EXPT_TYPE_COND_TRAP_OR_UND);
  assign early_expt_is_wfi            = (early_expt_type_wr == `CA53_EXPT_TYPE_WFI);
  assign early_expt_is_wfe            = (early_expt_type_wr == `CA53_EXPT_TYPE_WFE);

  assign expt_early_hipri_wr = (instr_type_wr_i == `CA53_INSTR_TYPE_SYNC_EXPT) &
                               pre_valid_instrs_wr_i[0] & ~br_flush_ret_i &
                               early_expt_high_priority_wr;

  assign expt_early_lopri_wr = (instr_type_wr_i == `CA53_INSTR_TYPE_SYNC_EXPT) &
                               pre_valid_instrs_wr_i[0] & ~br_flush_ret_i &
                               ~early_expt_high_priority_wr &
                               ~(early_expt_is_conditional_wr & ~cc_pass_instr0_wr_i) &
                               ~(early_expt_is_wfi & ~raw_wfi_req_i) &
                               ~(early_expt_is_wfe & ~raw_wfe_req_i);

  assign expt_early_ccfail_wr = (instr_type_wr_i == `CA53_INSTR_TYPE_SYNC_EXPT) &
                                 pre_valid_instrs_wr_i[0] & ~br_flush_ret_i &
                                 (early_expt_type_wr == `CA53_EXPT_TYPE_COND_TRAP_OR_UND);

  // ------------------------------------------------------
  // Final routing of exceptions
  // ------------------------------------------------------
  // Combine early and late exceptions to form final exception routing

  assign exception_el_wr    = enter_halt_wr       ? dpu_exception_level_i :
                              take_early_expt_wr  ? early_expt_el_wr      :
                                                    final_late_expt_el_wr;

  assign exception_mode_wr  = enter_halt_wr       ? cpsr_mode_ret_i    :
                              take_early_expt_wr  ? early_expt_mode_wr :
                                                    final_late_expt_mode_wr;

  // Indicate when exception routed to an AA64 exception level
  always @*
    case (exception_el_wr)
      `CA53_EL0: exception_aa64_wr = 1'b0;  // Can be reached when in halt
      `CA53_EL1: exception_aa64_wr = aarch64_at_el_i[1];
      `CA53_EL2: exception_aa64_wr = aarch64_at_el_i[2];
      `CA53_EL3: exception_aa64_wr = aarch64_at_el_i[3];
      default  : exception_aa64_wr = 1'bx;
    endcase

  // Indicate when exception routed to EL2
  assign exception_el2_wr         = (exception_el_wr == `CA53_EL2);

  // Indicate when exception routed to current EL
  assign exception_at_same_el_wr  = (dpu_exception_level_i == exception_el_wr);

  // ------------------------------------------------------
  // Exception state machine
  // ------------------------------------------------------

  always @* begin
    exception_valid_wr      = 1'b0;
    expt_quash_wr           = 1'b0;
    expt_quash_slot0_wr_o   = 1'b0;
    expt_quash_no_data_wr_o = 1'b0;
    expt_slot1_wr           = 1'b0;
    expt_ls_quash_wr_o      = 1'b0;
    expt_flush_ret_o        = 1'b0;

    case (current_state)
      // Delay processing reset for 2 cycles to allow all DPU state sampled at reset
      // to become valid.
      ST_EXPT_RESET0 : nxt_state = ST_EXPT_RESET1;
      ST_EXPT_RESET1 : nxt_state = ST_EXPT_RESET_FLUSH;
      ST_EXPT_RESET_FLUSH,
      ST_EXPT_IDLE : begin
        if (exception_valid_nostate_wr) begin
          // There is an exception in Wr
          nxt_state = ST_EXPT_DPU_FLUSH;

          // Apply quash and calculate forceop/flush when detect exception in Wr
          exception_valid_wr = 1'b1;

          // Calculate quash
          expt_quash_wr           = take_early_expt_wr ? early_expt_quash_wr : late_expt_quash_wr;
          expt_quash_slot0_wr_o   = take_early_expt_wr ? early_expt_quash_wr : late_expt_quash_slot0_wr;  // Early exceptions always slot 0
          expt_slot1_wr           = take_early_expt_wr ? 1'b0                : late_expt_slot1_wr;        // Only late exceptions can be slot 1
          // end_instr is suppressed in ctl when quashing, but not when quashing because of a data abort
          expt_quash_no_data_wr_o = take_early_expt_wr ? early_expt_quash_wr : late_expt_ls_quash_wr;

          // Indicate when a load/store should be quashed, ignoring any
          // exception generated by the load/store itself.
          expt_ls_quash_wr_o = late_expt_ls_quash_wr | take_early_expt_wr; // Always quash on early, even if not asserting quash (improves timing)

        end else begin
          // No exception - stay in idle
          nxt_state = ST_EXPT_IDLE;
        end
      end

      ST_EXPT_DPU_FLUSH : begin
        nxt_state = ST_EXPT_DE_FORCEOP;

        // Apply flush
        expt_flush_ret_o    = 1'b1;

      end
      ST_EXPT_DE_FORCEOP  : nxt_state = ST_EXPT_ISS_FORCEOP;
      ST_EXPT_ISS_FORCEOP : nxt_state = fpu_interlock_iss_i ? ST_EXPT_ISS_FORCEOP : ST_EXPT_EX1_FORCEOP;
      ST_EXPT_EX1_FORCEOP : nxt_state = ST_EXPT_EX2_FORCEOP;
      ST_EXPT_EX2_FORCEOP : nxt_state = ST_EXPT_WR_FORCEOP;
      ST_EXPT_WR_FORCEOP  : nxt_state = ST_EXPT_IDLE;

      default : begin
        nxt_state                 = {EXPT_FSM_W{1'bx}};
        exception_valid_wr        = 1'bx;
        expt_quash_wr             = 1'bx;
        expt_quash_slot0_wr_o     = 1'bx;
        expt_slot1_wr             = 1'bx;
        expt_ls_quash_wr_o        = 1'bx;
        expt_flush_ret_o          = 1'bx;
      end
    endcase
  end

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      current_state <= ST_EXPT_RESET0;
    else
      current_state <= nxt_state;

  assign expt_idle_o         = current_state == ST_EXPT_IDLE;
  assign nxt_dbg_ifu_halt_o  = in_halt_i & ~dbg_restart_qual_i;

  // ------------------------------------------------------
  // Calculate CPSR write enable and exception vector offset
  // ------------------------------------------------------

  // Applied in Ret, but calculated in Wr to improve timing
  assign cpsr_wr_en_aa32_wr = take_early_expt_wr ? early_aa32_cpsr_wr_en_wr : late_aa32_cpsr_wr_en_wr;

  // Exception vector offset depends on whether exception will be taken to AA64 or AA32.
  // - In AA32, need 3-bits of offset, corresponding to address[4:2]
  // - In AA64, need 4-bits of offset, corresponding to address[10:7]
  //
  // Same flops are used for pipelining AA32 and AA64 offset, so calculcate separately
  // then mux depending on target mode. Top bit of offset reg is unused on AA32 targets.

  // AA32 offset
  assign exception_vector_aa32_offset_wr = take_early_expt_wr ? early_expt_aa32_vect_offset_wr : late_expt_aa32_vect_offset_wr;

  // In AA64, bottom of offset is based on type of exception, and top of offset is based on where exception taken from
  // - Exception type
  assign exception_vector_aa64_offset_wr[8:0] = expt_fiq_taken                                  ? 9'h100 :
                                                expt_irq_taken                                  ? 9'h080 :
                                                (expt_imprecise_taken | expt_vimprecise_taken)  ? 9'h180 :
                                                                                                  9'h000;

  // - Where exception generated from
  
  // Need to determine if the exception level immediately below the target is AArch64,
  // rather than necessarily looking at the register width of the current level
  always @*
    case (exception_el_wr)
      `CA53_EL3: lower_level_aa64 = aarch64_at_el_i[2];
      `CA53_EL2: lower_level_aa64 = aarch64_at_el_i[1];
      `CA53_EL1: lower_level_aa64 = aarch64_state_i;
      default:   lower_level_aa64 = 1'bx;
    endcase
  
  assign exception_vector_aa64_offset_wr[10:9] = exception_at_same_el_wr ? (cpsr_mode_ret_i[0] ? 2'b01 :   // Current EL using SP_ELx
                                                                                                 2'b00)  : // Current EL using SP_EL0
                                                 lower_level_aa64        ? 2'b10                         : // Lower AA64 level
                                                                           2'b11;                          // Lower AA32 level

  assign exception_vector_offset_wr = exception_aa64_wr ? exception_vector_aa64_offset_wr[10:7] : {1'b0, exception_vector_aa32_offset_wr[4:2]};

  // ------------------------------------------------------
  // Calculate type of forceop required
  // ------------------------------------------------------
  // This is calculated in Wr and registered to be picked up by the forceop
  // decoder when the forceop is in De.
  assign forceop_type_wr    = (expt_reset |
                               (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC) |
                               in_halt_i  |
                               enter_halt_wr)     ? `CA53_FORCEOP_TYPE_NULL :
                              exception_aa64_wr   ? (aarch64_state_i ? `CA53_FORCEOP_TYPE_ADD : `CA53_FORCEOP_TYPE_SUB) :
                              exception_el2_wr    ? `CA53_FORCEOP_TYPE_EL2  :
                              take_data_expt_wr   ? `CA53_FORCEOP_TYPE_ADD  :
                                                    `CA53_FORCEOP_TYPE_SUB;

  assign thumb_mode_wr = expt_slot1_wr ? thumb_instr1_wr_i : thumb_instr0_wr_i;

  // The Forceop is used to write exception return address into ELR/R14. This is done using
  // ALU0, which takes the PC of the instruction on which the exception is taken (i.e.
  // the instruction currently in Wr), and applies an offset which is calculcated here.

  // The value written into the link register/R14 is specified by the architecture based
  // on the address of the instruction causing the exception. This is the fetch address,
  // which in AA32 is different from the architectural PC. When going to an AA32 exception
  // level, an additional architectural offset is applied. This is combined with the offset
  // required to form the fetch address to produce a single offset value for all forceops.

  // Offset to apply when targetting AA64 exception level
  // - Need to get fetch address from PC and then take either address of current or next instruction
  always @*
    case ({aarch64_state_i, thumb_mode_wr, (expt_type_wr == `CA53_EXPT_TYPE_CALL)})
      // In AA64, PC == Fetch address.
      3'b1_0_1 : forceop_offset_aa64_wr = `CA53_FORCEOP_OFFSET_4; //  Call => Next   : +4
      3'b1_0_0 : forceop_offset_aa64_wr = `CA53_FORCEOP_OFFSET_0; // !Call => Current: +0
      // In AA32, Need to apply offset to PC to get fetch address
      3'b0_1_1 : forceop_offset_aa64_wr = (size_instr0_wr_i ? `CA53_FORCEOP_OFFSET_0 : `CA53_FORCEOP_OFFSET_2); //  Call => Next   : -0/-2
      3'b0_1_0 : forceop_offset_aa64_wr = `CA53_FORCEOP_OFFSET_4; // !Call => Current: -4
      3'b0_0_1 : forceop_offset_aa64_wr = `CA53_FORCEOP_OFFSET_4; //  Call => Next   : -4
      3'b0_0_0 : forceop_offset_aa64_wr = `CA53_FORCEOP_OFFSET_8; // !Call => Current: -4-8
      default:   forceop_offset_aa64_wr = {`CA53_FORCEOP_OFFSET_W{1'bx}};
    endcase

  // Offset to apply when targetting AA32 exception level (must currently be in AA32)
  // - Calculated by auto-generated generated logic for early and late exceptions
  assign forceop_offset_type_aa32_wr = take_early_expt_wr ? early_forceop_offset_type_aa32_wr : late_forceop_offset_type_aa32_wr;

  always @*
    case (forceop_offset_type_aa32_wr)
      `CA53_FORCEOP_OFFSET_TYPE_0_4: forceop_offset_aa32_wr = (thumb_mode_wr ? `CA53_FORCEOP_OFFSET_0 : `CA53_FORCEOP_OFFSET_4);
      `CA53_FORCEOP_OFFSET_TYPE_2_4: forceop_offset_aa32_wr = (thumb_mode_wr ? `CA53_FORCEOP_OFFSET_2 : `CA53_FORCEOP_OFFSET_4);
      `CA53_FORCEOP_OFFSET_TYPE_4_8: forceop_offset_aa32_wr = (thumb_mode_wr ? `CA53_FORCEOP_OFFSET_4 : `CA53_FORCEOP_OFFSET_8);
      `CA53_FORCEOP_OFFSET_TYPE_4_0: forceop_offset_aa32_wr = (thumb_mode_wr ? `CA53_FORCEOP_OFFSET_4 : `CA53_FORCEOP_OFFSET_0);
      default                      : forceop_offset_aa32_wr = {`CA53_FORCEOP_OFFSET_W{1'bx}};
    endcase

  // Exception return address in AA64 of either address of next instruction (on calls),
  // or address of current instruction, both with no offset.
  assign forceop_offset_wr  = // When entering halt, exception_aa64_wr can go X, so force offset to 0 to prevent x-generation
                              enter_halt_wr     ? `CA53_FORCEOP_OFFSET_0  :
                              exception_aa64_wr ? forceop_offset_aa64_wr  :
                                                  forceop_offset_aa32_wr;

  // Mode changed by time forceop in De, so need record whether exception taken
  // from AA64 or AA32 mode
  always @(posedge clk)
    if (exception_valid_wr) begin
      forceop_aa64_o    <= aarch64_state_i;
      forceop_type_o    <= forceop_type_wr;
      forceop_offset_o  <= forceop_offset_wr;
    end

  // ------------------------------------------------------
  // Pipeline exception signals to Ret
  // ------------------------------------------------------

  assign nxt_cpsr_wr_en_ret = (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC) ? `CA53_CPSR_WR_EN_EARLY_NULL :
                              exception_aa64_wr                            ? `CA53_CPSR_WR_EN_EARLY_AIFM :
                                                                             cpsr_wr_en_aa32_wr;
  assign nxt_dbg_ss_vld_expt_type = (expt_type_wr != `CA53_EXPT_TYPE_ECC_REEXEC) & (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_HLT) & expt_quash_wr;


  always @(posedge clk)
    if (exception_valid_wr) begin
      exception_el_ret            <= exception_el_wr;
      exception_mode_ret          <= exception_mode_wr;
      exception_vector_offset_ret <= exception_vector_offset_wr;
      cpsr_wr_en_ret              <= nxt_cpsr_wr_en_ret;
      cpsr_wr_src_ret             <= cpsr_wr_src_wr;
      dbg_ss_vld_expt_type        <= nxt_dbg_ss_vld_expt_type;
    end

  assign dbg_ss_vld_expt_type_ret_o = dbg_ss_vld_expt_type & (current_state == ST_EXPT_EX2_FORCEOP);

  // ------------------------------------------------------
  // Expand compressed CPSR signals in Ret
  // ------------------------------------------------------

  // Update CPSR with mode for exception
  assign expt_cpsr_mode_ret_o  = exception_mode_ret;

  // Decode compressed form of cpsr_wr_en
  always @*
    case (cpsr_wr_en_ret)
      `CA53_CPSR_WR_EN_EARLY_NULL : full_cpsr_wr_en_ret = `CA53_SEL_CPSR_EN_NULL;
      `CA53_CPSR_WR_EN_EARLY_IM   : full_cpsr_wr_en_ret = `CA53_SEL_CPSR_EN_ETIM;
      `CA53_CPSR_WR_EN_EARLY_AIM  : full_cpsr_wr_en_ret = `CA53_SEL_CPSR_EN_ETAIM;
      `CA53_CPSR_WR_EN_EARLY_AIFM : full_cpsr_wr_en_ret = `CA53_SEL_CPSR_EN_ETAIFM;
      default                     : full_cpsr_wr_en_ret = {`CA53_SEL_CPSR_EN_W{1'bx}};
    endcase

  assign expt_cpsr_wr_en_ret_o  = ({`CA53_SEL_CPSR_EN_W{cpsr_wr_src_ret == `CA53_SEL_CPSR_SRC_TYPE_FORCE}} & full_cpsr_wr_en_ret) |
                                  ({`CA53_SEL_CPSR_EN_W{cpsr_wr_src_ret == `CA53_SEL_CPSR_SRC_TYPE_DSPSR}} & `CA53_SEL_CPSR_EN_SPSR);

  assign expt_cpsr_wr_src_ret_o = ({`CA53_SEL_CPSR_SRC_W{cpsr_wr_src_ret == `CA53_SEL_CPSR_SRC_TYPE_FORCE}} & `CA53_SEL_CPSR_SRC_FORCE) |
                                  ({`CA53_SEL_CPSR_SRC_W{cpsr_wr_src_ret == `CA53_SEL_CPSR_SRC_TYPE_DSPSR}} & `CA53_SEL_CPSR_SRC_DSPSR);

  // ------------------------------------------------------
  // Calculate exception vector address in Ret
  // ------------------------------------------------------

  // Determine the base address to use for the exception vector. Offset already
  // calculated in Wr and pipelined, so here just need to calculate base address
  // and concatenate.
  //
  // - Calculated differently depending on whether exception taken to AA32 or AA64
  // mode.
  // - Calculate offset for each separately then mux based on target mode.

  // AA32 base address
  always @* begin
    exception_vector_aa32_base_ret[31:5] = {27{1'b0}};
    case (exception_el_ret)
      `CA53_EL1: exception_vector_aa32_base_ret[31:5] = sctlr_ns_hivecs_i ? {24'hFFFF_00, 3'b000} : cp_vbar_el1_i[31:5];
      `CA53_EL2: exception_vector_aa32_base_ret[31:5] = cp_hvbar_i[31:5];
      `CA53_EL3: begin
        if (exception_mode_ret == `CA53_FULL_MODE_MON) begin
          // In AA32 Monitor mode, use MVBAR
          exception_vector_aa32_base_ret[31:5] = cp_mvbar_i[31:5];
        end else begin
          // In AA32 EL3 mode which is not Monitor mode, use same address as
          // would do in Secure AA32 EL1 mode
          exception_vector_aa32_base_ret[31:5] = sctlr_s_hivecs_i  ? {24'hFFFF_00, 3'b000} : cp_vbar_el3_i[31:5];
        end
      end
      default: exception_vector_aa32_base_ret[31:5] = {27{1'bx}};
    endcase
  end

  // AA64 base address
  always @*
    case (exception_el_ret)
      `CA53_EL1: exception_vector_aa64_base_ret[63:11] = cp_vbar_el1_i[63:11];
      `CA53_EL2: exception_vector_aa64_base_ret[63:11] = cp_hvbar_i[63:11];
      `CA53_EL3: exception_vector_aa64_base_ret[63:11] = cp_vbar_el3_i[63:11];
      default: exception_vector_aa64_base_ret[63:11] = {53{1'bx}};
    endcase

  // Reset is a special case, as when reset to AA64 mode the exception vector is determined
  // by a dedicated external input.
  // - Note MMU disabled at reset, so addresses are flat mapped. Therefore only need 40-bits
  // of address for reset vector address (as have a 40-bit physical address space).
  assign exception_vector_reset_ret[39:2] = aarch64_at_el_i[3] ? {rvbaraddr_i[39:2]}               :       // AA64
                                            sctlr_s_hivecs_i   ? {{8{1'b0}}, 28'hFFFF_000, 2'b00}  :       // AA32 hivecs
                                                                 {{8{1'b0}}, cp_vbar_el3_i[31:5], 3'b000}; // AA32 not hivecs

  assign expt_force_to_instr_addr = (expt_type == `CA53_EXPT_TYPE_DEBUG_HLT)  |
                                    (expt_type == `CA53_EXPT_TYPE_DEBUG_EXIT) |
                                    (expt_type == `CA53_EXPT_TYPE_ECC_REEXEC);

  // Form exception vector address based on exception type and target mode
  assign forceop_pc_ret_o = (expt_type == `CA53_EXPT_TYPE_RESET)  ? {{24{1'b0}}, exception_vector_reset_ret[39:2], 2'b00} :
                            expt_force_to_instr_addr              ? (expt_slot1_ret_i ? pc_instr0_wr_i : pc_instr0_ret_i) :
                            exception_mode_ret[4]                 ? // AA32 exception mode
                                                                    {{32{1'b0}},
                                                                     exception_vector_aa32_base_ret[31:5],
                                                                     exception_vector_offset_ret[2:0],  // Correponds to offset[4:2]
                                                                     2'b00}                                               :
                                                                    // AA64 exception mode
                                                                    {exception_vector_aa64_base_ret[63:11],
                                                                     exception_vector_offset_ret[3:0],  // Corresponds to offset[10:7]
                                                                     7'b0000000};

  // ------------------------------------------------------
  // Detect an exeption in halting debug
  // ------------------------------------------------------

  assign set_expt_in_halt     = exception_valid_nostate_wr & (current_state == ST_EXPT_IDLE) & in_halt_i;

  assign dbg_expt             = set_expt_in_halt & (expt_type_wr != `CA53_EXPT_TYPE_CALL)       &
                                                   (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXIT) & 
                                                   (expt_type_wr != `CA53_EXPT_TYPE_ECC_REEXEC);

  assign dbg_halt_ecc_expt_wr = set_expt_in_halt & (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC);

  assign dbg_expt_o           = dbg_expt;

  assign nxt_expt_in_halt     = dbg_expt | (expt_in_halt & (current_state != ST_EXPT_WR_FORCEOP));

  assign nxt_expt_end_in_halt = (set_expt_in_halt & (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXIT) &
                                                    (expt_type_wr != `CA53_EXPT_TYPE_ECC_REEXEC)) |
                                (expt_end_in_halt & (current_state != ST_EXPT_WR_FORCEOP));

  assign nxt_end_expt_in_halt = (expt_end_in_halt & (current_state == ST_EXPT_WR_FORCEOP));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      expt_in_halt     <= 1'b0;
      expt_end_in_halt <= 1'b0;
      end_expt_in_halt <= 1'b0;
    end else begin
      expt_in_halt     <= nxt_expt_in_halt;
      expt_end_in_halt <= nxt_expt_end_in_halt;
      end_expt_in_halt <= nxt_end_expt_in_halt;
    end

  // ------------------------------------------------------
  // Calculate offset to use when forcing IFU on a forceop for dbg entry or
  // return, or on an ECC error
  // ------------------------------------------------------

  // Slot 0 exception: pc_instr0_ret is for instruction causing exception, just adjust for architectural offset
  always @*
    case (isa_instr0_ret_i[1:0])
      2'b00:   forceop_reexec_pc_offset_sl0_ret = 17'h1FFFC; // A32: -8
      2'b01:   forceop_reexec_pc_offset_sl0_ret = 17'h1FFFE; // T32: -4
      2'b10:   forceop_reexec_pc_offset_sl0_ret = 17'h00000; // A64:  0
      default: forceop_reexec_pc_offset_sl0_ret = {17{1'bx}};
    endcase

  // Slot 1 exception: Need to decrement pc_instr0_wr by size of faulting instruction,
  //                   then adjust for architectural offset based on ISA of Wr-stage instruction
  always @* 
    case ({size_instr1_ret_i, isa_instr0_wr_i[1:0]})
      3'b100:  forceop_reexec_pc_offset_sl1_ret = 17'h1FFFA;   // -4 + -8 = -12
      3'b001:  forceop_reexec_pc_offset_sl1_ret = 17'h1FFFD;   // -2 + -4 = -6
      3'b101:  forceop_reexec_pc_offset_sl1_ret = 17'h1FFFC;   // -4 + -4 = -8
      3'b110:  forceop_reexec_pc_offset_sl1_ret = 17'h1FFFE;   // -4
      default: forceop_reexec_pc_offset_sl1_ret = {17{1'bx}};
    endcase

  assign forceop_reexec_pc_offset_ret = expt_slot1_ret_i ? forceop_reexec_pc_offset_sl1_ret : forceop_reexec_pc_offset_sl0_ret;

  // Always applied when inserting a forceop, so mask to zero when forceop is
  // not for debug entry or ECC
  assign forceop_pc_offset_ret_o = forceop_reexec_pc_offset_ret & {17{expt_force_to_instr_addr & (expt_type != `CA53_EXPT_TYPE_DEBUG_EXIT)}};

  // ------------------------------------------------------
  // Update NS state in Ret based on new mode
  // ------------------------------------------------------

  // Clear NS bit in SCR when taking an exception in monitor mode
  // - unless exception is debug entry or exit
  assign expt_mon_mode_clear_ns_o = (current_state == ST_EXPT_DPU_FLUSH) & 
                                    (cpsr_mode_ret_i == `CA53_FULL_MODE_MON) & 
                                    ~((expt_type == `CA53_EXPT_TYPE_DEBUG_HLT)  |
                                      (expt_type == `CA53_EXPT_TYPE_DEBUG_EXIT) |
                                      (expt_type == `CA53_EXPT_TYPE_ECC_REEXEC));

  assign nxt_ns_state = ~nxt_mon_el3_mode_ret_i & nxt_ns_scr_i;

  assign ns_state_en  = ~exception_valid_wr &                   // Ignore change when there is an exception (in case instruction being quashed is changing state)
                        (~(stall_wr_i | br_flush_ret_i) |
                         (current_state == ST_EXPT_DPU_FLUSH)); // Ignore stalls when flushing for exception

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ns_state  <= 1'b0;
    else if (ns_state_en)
      ns_state  <= nxt_ns_state;

  // ------------------------------------------------------
  // Insert forceop
  // ------------------------------------------------------

  // Signals to indicate when inserting forceop in Ret, and when forceop is valid
  // in De are registered to improve timing.
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      insert_forceop_ret     <= 1'b0;
      forceop_valid_de_o     <= 1'b0;
      dbg_halt_ecc_expt_ret  <= 1'b0;
      dbg_halt_ecc_expt_de_o <= 1'b0;
    end else begin
      insert_forceop_ret     <= exception_valid_wr;  // Exception will always be in Ret on cycle after detect exception in Wr
      forceop_valid_de_o     <= insert_forceop_ret;  // Never stall in Ret, so forceop will always be in De on cycle after
      dbg_halt_ecc_expt_ret  <= dbg_halt_ecc_expt_wr;
      dbg_halt_ecc_expt_de_o <= dbg_halt_ecc_expt_ret;
    end

  // ------------------------------------------------------
  // Determine fault register enables
  // ------------------------------------------------------
  // The fault registers written depend on the exception type and target mode.
  // - Some of the physical flops for the fault status registers are shared in the CP block,
  // but the exception logic has a separate enable bit for each logical register, with the
  // CP block responsible for mapping the logical registers to the physical flops.
  always @* begin
    expt_fault_reg_en = {`CA53_FAULT_REG_EN_W{1'b0}};
    case (expt_type_wr)
      `CA53_EXPT_TYPE_DATA     : begin
        expt_fault_reg_en[`CA53_FAULT_REG_EN_DFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_DFAR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr & cp_icimvau_i;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HDFAR]    = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HPFAR]    = (exception_el_wr == `CA53_EL2) & dcu_p_fault_stage_dc3_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_WPT      : begin
        expt_fault_reg_en[`CA53_FAULT_REG_EN_DFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_DFAR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr & cp_icimvau_i;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HDFAR]    = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_SP_ALIGNMENT: begin
        // Can only happen in AA64
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_IMPRECISE   : begin
        expt_fault_reg_en[`CA53_FAULT_REG_EN_DFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_PC_ALIGNMENT,
      `CA53_EXPT_TYPE_INSTR_FAULT : begin
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFAR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HIFAR]    = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HPFAR]    = (exception_el_wr == `CA53_EL2) & ifu_ifsr_stage2_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_FAR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_DEBUG_EXPT  : begin
        // Same as INSTR_FAULT, but doesn't write HPFAR, or FAR_ELx
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFSR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_IFAR]     = (exception_el_wr != `CA53_EL2) & ~exception_aa64_wr;
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HIFAR]    = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_TRAP,
      `CA53_EXPT_TYPE_CALL,
      `CA53_EXPT_TYPE_WFI,
      `CA53_EXPT_TYPE_WFE,
      `CA53_EXPT_TYPE_COND_TRAP,
      `CA53_EXPT_TYPE_COND_TRAP_OR_UND : begin
        expt_fault_reg_en[`CA53_FAULT_REG_EN_HSR]      = (exception_el_wr == `CA53_EL2) & ~aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL1]  = (exception_el_wr == `CA53_EL1) & aarch64_at_el_i[1];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL2]  = (exception_el_wr == `CA53_EL2) & aarch64_at_el_i[2];
        expt_fault_reg_en[`CA53_FAULT_REG_EN_ESR_EL3]  = (exception_el_wr == `CA53_EL3) & aarch64_at_el_i[3];
      end
      `CA53_EXPT_TYPE_FIQ,
      `CA53_EXPT_TYPE_IRQ,
      `CA53_EXPT_TYPE_DEBUG_HLT,
      `CA53_EXPT_TYPE_DEBUG_EXIT,
      `CA53_EXPT_TYPE_ECC_REEXEC,
      `CA53_EXPT_TYPE_RESET     : begin
        // Don't write any fault registers (use default)
      end
      default                   : begin
        expt_fault_reg_en = {`CA53_FAULT_REG_EN_W{1'bx}};
      end
    endcase
  end

  // Mask enable sent to CP block when not taking a valid exception
  assign expt_fault_reg_en_wr_o = {`CA53_FAULT_REG_EN_W{exception_valid_wr}} & expt_fault_reg_en;

  // Bias exception fault register inputs to inputs from exception logic when there is an exception in Wr
  assign expt_fault_reg_sel_wr_o = exception_valid_nostate_wr;

  // When writing an AA32 banked register, need to map it to either the EL1 or EL3 AA64 equivalent
  assign expt_aa32_uses_el1_esr_wr_o = (exception_el_wr == `CA53_EL1) & (ns_state | aarch64_at_el_i[3]);

  // ------------------------------------------------------
  // Calculate LPAE format to use for fault registers
  // ------------------------------------------------------
  // Faults are generally reported using the current LPAE mode when they are
  // recognised, with the following exception:
  // - Imprecise aborts routed to Montor mode because of SCR.EA use the
  // secure TTBCR.EAE (reported on tlb_lpae_mode_s) to determine whether or
  // not to use LPAE mode.
  //
  // Additionally, LPAE mode is forced in the following situations:
  // - When the target exception level is EL2 or AA64 (the fault encodings
  // used in those cases are based on the LPAE format fault encodings)
  // - On stage 2 faults
  // - On external aborts routed to Monitor mode because of SCR.EA when
  // the secure TTBCR.EAE bit is set (indicated by tlb_lpae_mode_s)
  // - When indicated by the DCU on trapped address translation instructions

  // The LPAE mode to use for exception reporting is only ever required for
  // DCU, imprecise and instruction aborts, and is used separately for each.
  assign external_iabort_ns_to_mon    = (early_expt_type_wr == `CA53_EXPT_TYPE_INSTR_FAULT) & `CA53_FAULT_GEN_EXT(ifu_ifsr_i) & ns_state & scr_ea_i;
  assign external_dcu_abort_ns_to_mon = external_dabort_to_el3 & ns_state;
  assign external_imp_abort_ns_to_mon = expt_imprecise  & ns_state & scr_ea_i;  // Imprecise always external (but vImprecise not affected by SCR.EA)

  // Note that for IFU faults, the current LPAE mode may have changed (because
  // of a write to the TTBCR) between the fault being detected and being
  // taken. In that case, the LPAE mode from when the fault was detected
  // (provided by the IFU) is used.
  // - The exception to that is when an external IFU abort is routed to
  // monitor mode because of SCR.EA. In that case, the current secure
  // TTBCR.EAE bit is used (which may have changed since the fault was
  // detected).
  assign iabort_lpae_wr     = ifu_ifsr_lpae_i  |
                              // Note that the IFU ifsr and ifsr_stage signals are only valid on prefetch aborts
                              (ifu_ifsr_stage2_i[1] & (early_expt_type_wr == `CA53_EXPT_TYPE_INSTR_FAULT)) |
                              exception_aa64_wr |
                              exception_el2_wr |
                              (external_iabort_ns_to_mon & tlb_lpae_mode_s_i);

  assign dcu_abort_lpae_wr  = tlb_lpae_mode_i |
                              dcu_p_fault_stage_dc3_i[1] |
                              dcu_v2p_lpae_dc3_i |
                              exception_aa64_wr |
                              exception_el2_wr |
                              (external_dcu_abort_ns_to_mon & tlb_lpae_mode_s_i);

  assign imp_abort_lpae_wr  = exception_aa64_wr |
                              exception_el2_wr |
                              (external_imp_abort_ns_to_mon ? tlb_lpae_mode_s_i : tlb_lpae_mode_i);

  assign wpt_lpae_wr        = exception_aa64_wr |
                              exception_el2_wr |
                              tlb_lpae_mode_i;

  // ------------------------------------------------------
  // ESR/HSR/FAR/HPFAR data
  // ------------------------------------------------------

  // ESR value for precise data aborts
  // - ESR.SSE (syndrome sign extend)
  assign ls_synd_sse_wr = (ls_instr_type_wr_i == `CA53_LS_INSTR_SIGN_EXT);

  // - ESR.AR (acquire/release)
  assign ls_synd_ar_wr = ((ls_instr_type_wr_i == `CA53_LS_INSTR_ORDERED) |
                          (ls_instr_type_wr_i == `CA53_LS_INSTR_ORD_EXCL_SGL));

  // - ESR.ISV (instruction syndrome valid)
  // - This bit is 0 for aborts other than those generated by the second stage of translation,
  // excluding second stage aborts on first stage translation table walks
  // - Only set when writing ESR_EL2/HSR
  assign ls_instr_syndrome_valid = ls_isv_set_wr_i &
                                   (dcu_p_fault_stage_dc3_i[1:0] == 2'b10) &
                                   (late_expt_el_wr == `CA53_EL2);

  // - ESR.SRT (syndrome transfer register - register number of Rt)
  // - When taking an exception to AA64, this needs to be the AA64 view of the register number,
  // so when coming from AA32 need to convert.
  ca53dpu_ctl_reg_aa32_aa64 u_reg_aa32_aa64 (
    .aa32_addr_i      (ls_synd_srt_wr_i[3:0]),
    .cpsr_mode_ret_i  (cpsr_mode_ret_i),
    .aa64_addr_o      (ls_synd_srt_aa64_wr)
  );

  assign final_ls_synd_srt_wr = (exception_aa64_wr & ~aarch64_state_i) ? ls_synd_srt_aa64_wr :
                                                                         ls_synd_srt_wr_i;

  always @* begin
    late_expt_ec_wr   = {6{1'b0}};
    late_expt_esr_wr  = {26{1'b0}};

    case (late_expt_type_wr)
      `CA53_EXPT_TYPE_IMPRECISE: begin
        late_expt_ec_wr         = exception_aa64_wr       ? 6'h2F :
                                  exception_at_same_el_wr ? 6'h25 :
                                                            6'h24;

        late_expt_esr_wr[25]    = 1'b1; // IL

        case ({exception_aa64_wr, expt_imprecise_taken, expt_vimprecise_taken})
          3'b0_10: begin
            case ({imp_abort_pending, gov_sei_reg, gov_rei_reg})
              `ca53dpu_sel_1xx: begin
                late_expt_esr_wr[ 9]    = (imp_abort_fault == 2'b00);
                late_expt_esr_wr[ 8]    = 1'b0;
                late_expt_esr_wr[ 7]    = 1'b0;
                late_expt_esr_wr[ 6]    = 1'b1;
                late_expt_esr_wr[ 5: 0] = imp_abort_fault[1] ? 6'b01_1001 : 6'b01_0001;
              end
              `ca53dpu_sel_01x: begin
                late_expt_esr_wr[ 9]    = 1'b0;
                late_expt_esr_wr[ 8]    = 1'b0;
                late_expt_esr_wr[ 7]    = 1'b0;
                late_expt_esr_wr[ 6]    = 1'b1;
                late_expt_esr_wr[ 5: 0] = 6'b01_0001;
              end
              3'b001          : begin
                late_expt_esr_wr[ 9]    = 1'b0;
                late_expt_esr_wr[ 8]    = 1'b0;
                late_expt_esr_wr[ 7]    = 1'b0;
                late_expt_esr_wr[ 6]    = 1'b1;
                late_expt_esr_wr[ 5: 0] = 6'b01_1001;
              end
              default         : late_expt_esr_wr[24: 0] = {25{1'bx}};
            endcase
          end
          3'b0_01: begin
            late_expt_esr_wr[ 9]    = 1'b0;
            late_expt_esr_wr[ 8]    = 1'b0;
            late_expt_esr_wr[ 7]    = 1'b0;
            late_expt_esr_wr[ 6]    = 1'b1;
            late_expt_esr_wr[ 5: 0] = 6'b01_0001;
          end
          3'b1_10: begin
            case ({imp_abort_pending, gov_sei_reg, gov_rei_reg})
              `ca53dpu_sel_1xx: begin
                late_expt_esr_wr[24]    = 1'b1;
                late_expt_esr_wr[23:22] = 2'b00;
                late_expt_esr_wr[ 1]    = (imp_abort_fault == 2'b00);
                late_expt_esr_wr[ 0]    = imp_abort_fault[1];
              end
              `ca53dpu_sel_01x: begin
                late_expt_esr_wr[24]    = 1'b1;
                late_expt_esr_wr[23:22] = 2'b01;
                late_expt_esr_wr[ 0]    = 1'b0;
              end
              3'b001          : begin
                late_expt_esr_wr[24]    = 1'b1;
                late_expt_esr_wr[23:22] = 2'b01;
                late_expt_esr_wr[ 0]    = 1'b1;
              end
              default         : late_expt_esr_wr[24: 0] = {25{1'bx}};
            endcase
          end
          3'b1_01: begin
            case ({hcr_va_i, gov_vsei_reg})
              `ca53dpu_sel_1x: begin
                late_expt_esr_wr[24]    = 1'b0;
              end
              2'b01          : begin
                late_expt_esr_wr[24]    = 1'b1;
                late_expt_esr_wr[23:22] = 2'b01;
                late_expt_esr_wr[ 0]    = 1'b0;
              end
              default        : late_expt_esr_wr[24: 0] = {25{1'bx}};
            endcase
          end
          default: late_expt_esr_wr[24: 0] = {25{1'bx}};
        endcase
      end
      `CA53_EXPT_TYPE_SP_ALIGNMENT: begin
        late_expt_ec_wr         = 6'h26;
        late_expt_esr_wr[25]    = 1'b1;   // IL
                                          // Iss is RES0
      end
      `CA53_EXPT_TYPE_DATA     : begin
        late_expt_ec_wr         = exception_at_same_el_wr ? 6'h25 :
                                                            6'h24;

        late_expt_esr_wr[25]    = (~ls_instr_syndrome_valid | (slot1_ls_wr_i ? size_instr1_wr_i : size_instr0_wr_i));  // IL

        case ({cp_icimvau_i, ls_instr_syndrome_valid})
          2'b00: begin
            late_expt_esr_wr[ 9: 0] = {dcu_p_fault_dc3_i[6],
                                       dcu_cm_operation_dc3_i,
                                       dcu_p_fault_stage_dc3_i[0],
                                       dcu_p_direction_dc3_i,
                                       dcu_p_fault_dc3_i[5:0]};
          end
          2'b01: begin
            late_expt_esr_wr[24: 0] = {1'b1,                        // [24]     ISV
                                       ls_size_wr_i[1:0],           // [23:22]  SAS
                                       ls_synd_sse_wr,              // [21]     SSE
                                       final_ls_synd_srt_wr[4:0],   // [20:16]  SRT
                                       ls_synd_sf_wr_i,             // [15]     SF (RES0 when going to AA32)
                                       ls_synd_ar_wr,               // [14]     AR (RES0 when going to AA32)
                                       {4{1'b0}},                   // [13:10]  RES0
                                       dcu_p_fault_dc3_i[6],        // [9]      EA
                                       dcu_cm_operation_dc3_i,      // [8]      CM
                                       dcu_p_fault_stage_dc3_i[0],  // [7]      S1PTW
                                       dcu_p_direction_dc3_i,       // [6]      WnR
                                       dcu_p_fault_dc3_i[5:0]};     // [5:0]    DFSC
          end
          `ca53dpu_sel_1x: begin
            late_expt_esr_wr[ 9: 0] = {dcu_p_fault_dc3_i[6],
                                       dcu_cm_operation_dc3_i,
                                       dcu_p_fault_stage_dc3_i[0],
                                       1'b1,
                                       dcu_p_fault_dc3_i[5:0]};
          end
          default: begin
            late_expt_esr_wr[24:0] = {25{1'bx}};
          end
        endcase
      end
      `CA53_EXPT_TYPE_WPT      : begin
        late_expt_ec_wr         = ((exception_el_wr == 2'h2) & ~aarch64_at_el_i[2'h2]) ? 6'h24 :
                                  exception_at_same_el_wr                              ? 6'h35 :
                                                                                         6'h34;
        late_expt_esr_wr[25]    = 1'b1;
        late_expt_esr_wr[ 8: 0] = {dcu_cm_operation_dc3_i,
                                   1'b0,
                                   dcu_p_direction_dc3_i,
                                   6'b10_0010};
      end
      `CA53_EXPT_TYPE_DEBUG_EXPT : begin
        late_expt_ec_wr         = exception_at_same_el_wr ? 6'h33 :
                                                            6'h32;
        late_expt_esr_wr[25]    = 1'b1;
        late_expt_esr_wr[24]    = soft_step_isv_i;
        late_expt_esr_wr[ 6]    = soft_step_isv_i & step_ex_i;
        late_expt_esr_wr[ 5: 0] = 6'b10_0010;
      end
      default                    : begin
        late_expt_ec_wr  = {6{1'bx}};
        late_expt_esr_wr = {26{1'bx}};
      end
    endcase
  end

  // Form ESR data based on type of exception
  assign expt_ec_wr   = take_early_expt_wr ? early_expt_ec_wr  : late_expt_ec_wr;
  assign expt_esr_wr  = take_early_expt_wr ? early_expt_esr_wr : late_expt_esr_wr;

  assign expt_esr_data_wr_o   = {expt_ec_wr, expt_esr_wr};

  assign expt_far_data_wr_o   = take_data_expt_wr ? dcu_va_dc3_i    :
                                aarch64_state_i   ? pc_instr0_wr_i  :
                                                    { {32{1'b0}}, ifu_ifar_i, 1'b0};

  assign expt_hpfar_data_wr_o = take_data_expt_wr ? dcu_pa_dc3_i :
                                                    ifu_hpfar_i;

  // ------------------------------------------------------
  // DFSR/IFSR data
  // ------------------------------------------------------

  function [6:0] vmsa_fault;
    input [6:0] fault;

    case (fault)
      `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT1_DEC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT2_DEC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT1_SLV;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT2_SLV;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT1_ECC;
      `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2: vmsa_fault = `CA53_FAULT_VMSA_PAGEWALK_EXT2_ECC;
      `CA53_FAULT_LPAE_TRANSLATION_L1:      vmsa_fault = `CA53_FAULT_VMSA_TRANSLATION_SEC;
      `CA53_FAULT_LPAE_TRANSLATION_L2:      vmsa_fault = `CA53_FAULT_VMSA_TRANSLATION_PAGE;
      `CA53_FAULT_LPAE_ACCESS_L1:           vmsa_fault = `CA53_FAULT_VMSA_ACCESS_SEC;
      `CA53_FAULT_LPAE_ACCESS_L2:           vmsa_fault = `CA53_FAULT_VMSA_ACCESS_PAGE;
      `CA53_FAULT_LPAE_ALIGNMENT:           vmsa_fault = `CA53_FAULT_VMSA_ALIGNMENT;
      `CA53_FAULT_LPAE_PERMISSION_L1:       vmsa_fault = `CA53_FAULT_VMSA_PERMISSION_SEC;
      `CA53_FAULT_LPAE_PERMISSION_L2:       vmsa_fault = `CA53_FAULT_VMSA_PERMISSION_PAGE;
      `CA53_FAULT_LPAE_DOMAIN_L1:           vmsa_fault = `CA53_FAULT_VMSA_DOMAIN_SEC;
      `CA53_FAULT_LPAE_DOMAIN_L2:           vmsa_fault = `CA53_FAULT_VMSA_DOMAIN_PAGE;
      `CA53_FAULT_LPAE_EXT_DEC:             vmsa_fault = `CA53_FAULT_VMSA_EXT_DEC;
      `CA53_FAULT_LPAE_EXT_SLV:             vmsa_fault = `CA53_FAULT_VMSA_EXT_SLV;
      `CA53_FAULT_LPAE_ECC:                 vmsa_fault = `CA53_FAULT_VMSA_ECC;
      `CA53_FAULT_LPAE_LDREX:               vmsa_fault = `CA53_FAULT_VMSA_LDREX;
      default:                              vmsa_fault = 7'bxxxxxxx;
    endcase
  endfunction

  assign dcu_fault_vmsa_wr = vmsa_fault(dcu_p_fault_dc3_i);
  assign ifu_fault_vmsa_wr = vmsa_fault(ifu_ifsr_i);

  // DFSR
  // - DFSR[31:14], DFSR[8] is RAZ for both LPAE and VMSA format, so do not encode
  always @*
    case (late_expt_type_wr)
      `CA53_EXPT_TYPE_IMPRECISE:
        case ({imp_abort_lpae_wr, expt_imprecise_taken, expt_vimprecise_taken})
          3'b0_10: begin
            expt_dfsr_wr_o[12]    = 1'b0;                                               // [13]    Cache Maintenance
            expt_dfsr_wr_o[10]    = 1'b1;                                               // [11]    WnR
            expt_dfsr_wr_o[ 9]    = 1'b1;                                               // [10]    FS[4]
            expt_dfsr_wr_o[ 8]    = 1'b0;                                               // [9]     LPAE format
                                                                                        // [8]     Always RAZ so not sent
            expt_dfsr_wr_o[ 7: 4] = 4'b0000;                                            // [7:4]   RAZ

            case ({imp_abort_pending, gov_sei_reg, gov_rei_reg})
              `ca53dpu_sel_1xx: begin
                expt_dfsr_wr_o[11]    = (imp_abort_fault == 2'b00);                     // [12]    ExT
                expt_dfsr_wr_o[ 3: 0] = imp_abort_fault[1] ? 4'b1000 : 4'b0110;         // [3:0]   FS[3:0]
              end
              `ca53dpu_sel_01x: begin
                expt_dfsr_wr_o[11]    = 1'b0;                                           // [12]    ExT
                expt_dfsr_wr_o[ 3: 0] = 4'b0110;                                        // [3:0]   FS[3:0]
              end
              3'b001          : begin
                expt_dfsr_wr_o[11]    = 1'b0;                                           // [12]    ExT
                expt_dfsr_wr_o[ 3: 0] = 4'b1000;                                        // [3:0]   FS[3:0]
              end
              default: expt_dfsr_wr_o = {13{1'bx}};
            endcase
          end
          3'b0_01: begin
            expt_dfsr_wr_o[12]    = 1'b0;                                               // [13]    Cache Maintenance
            expt_dfsr_wr_o[11]    = 1'b0;                                               // [12]    ExT
            expt_dfsr_wr_o[10]    = 1'b1;                                               // [11]    WnR
            expt_dfsr_wr_o[ 9]    = 1'b1;                                               // [10]    FS[4]
            expt_dfsr_wr_o[ 8]    = 1'b0;                                               // [9]     LPAE format
                                                                                        // [8]     Always RAZ so not sent
            expt_dfsr_wr_o[ 7: 4] = 4'b0000;                                            // [7:4]   RAZ
            expt_dfsr_wr_o[ 3: 0] = 4'b0110;                                            // [3:0]   FS[3:0]
          end
          3'b1_10: begin
            expt_dfsr_wr_o[12]    = 1'b0;                                               // [13]    Cache Maintenance
            expt_dfsr_wr_o[10]    = 1'b1;                                               // [11]    WnR
            expt_dfsr_wr_o[ 9]    = 1'b0;                                               // [10]    RAZ
            expt_dfsr_wr_o[ 8]    = 1'b1;                                               // [9]     LPAE format
                                                                                        // [8]     Always RAZ so not sent
            expt_dfsr_wr_o[ 7: 6] = 2'b00;                                              // [7:6]   RAZ

            case ({imp_abort_pending, gov_sei_reg, gov_rei_reg})
              `ca53dpu_sel_1xx: begin
                expt_dfsr_wr_o[11]    = (imp_abort_fault == 2'b00);                     // [12]    ExT
                expt_dfsr_wr_o[ 5: 0] = imp_abort_fault[1] ? 6'b01_1001 : 6'b01_0001;   // [5:0]   Status
              end
              `ca53dpu_sel_01x: begin
                expt_dfsr_wr_o[11]    = 1'b0;                                           // [12]    ExT
                expt_dfsr_wr_o[ 5: 0] = 6'b01_0001;                                     // [5:0]   Status
              end
              3'b001          : begin
                expt_dfsr_wr_o[11]    = 1'b0;                                           // [12]    ExT
                expt_dfsr_wr_o[ 5: 0] = 6'b01_1001;                                     // [5:0]   Status
              end
              default: expt_dfsr_wr_o = {13{1'bx}};
            endcase
          end
          3'b1_01: begin
            expt_dfsr_wr_o[12]    = 1'b0;                                               // [13]    Cache Maintenance
            expt_dfsr_wr_o[11]    = 1'b0;                                               // [12]    ExT
            expt_dfsr_wr_o[10]    = 1'b1;                                               // [11]    WnR
            expt_dfsr_wr_o[ 9]    = 1'b0;                                               // [10]    RAZ
            expt_dfsr_wr_o[ 8]    = 1'b1;                                               // [9]     LPAE format
                                                                                        // [8]     Always RAZ so not sent
            expt_dfsr_wr_o[ 7: 6] = 2'b00;                                              // [7:6]   RAZ
            expt_dfsr_wr_o[ 5: 0] = 6'b01_0001;                                         // [5:0]   Status
          end
          default: expt_dfsr_wr_o = {13{1'bx}};
        endcase
      `CA53_EXPT_TYPE_DATA:
        case (cp_icimvau_i)
          1'b0:
            expt_dfsr_wr_o = {dcu_cm_operation_dc3_i,   // [13]    Cache Maintenance
                              dcu_p_fault_dc3_i[6],     // [12]    ExT
                              dcu_p_direction_dc3_i,    // [11]    WnR
                              (dcu_abort_lpae_wr ? {1'b0,                      // [10]    RAZ
                                                    1'b1,                      // [9]     LPAE format
                                                                               // [8]     Always RAZ so not sent
                                                    {2{1'b0}},                 // [7:6]   RAZ
                                                    dcu_p_fault_dc3_i[5:0]}    // [5:0]   Status
                                                 :
                                                   {dcu_fault_vmsa_wr[4],      // [10]    Status
                                                    1'b0,                      // [9]     RAZ
                                                                               // [8]     Always RAZ so not sent
                                                    dcu_p_domain_dc3_i[3:0],   // [7:4]   Domain
                                                    dcu_fault_vmsa_wr[3:0]})}; // [3:0]   Status
          1'b1:
            expt_dfsr_wr_o = {dcu_cm_operation_dc3_i, // [13]    Cache Maintenance
                              dcu_p_fault_dc3_i[6],   // [12]    ExT
                              dcu_p_direction_dc3_i,  // [11]    WnR
                              (dcu_abort_lpae_wr ? {1'b0,                    // [10]    RAZ
                                                    1'b1,                    // [9]     LPAE format
                                                                             // [8]     Always RAZ so not sent
                                                    {2{1'b0}},               // [7:6]   RAZ
                                                    dcu_p_fault_dc3_i[5:0]}  // [5:0]   Status
                                                 :
                                                   {1'b0,                    // [10]    Status
                                                    1'b0,                    // [9]     RAZ
                                                                             // [8]     Always RAZ so not sent
                                                    dcu_p_domain_dc3_i[3:0], // [7:4]   Domain
                                                    4'b0100})}; // [3:0]   Status
          default: expt_dfsr_wr_o = {13{1'bx}};
        endcase
      `CA53_EXPT_TYPE_WPT:
        expt_dfsr_wr_o = {dcu_cm_operation_dc3_i,     // [13]    Cache Maintenance
                          1'b0,                       // [12]    ExT
                          dcu_p_direction_dc3_i,      // [11]    WnR
                          (wpt_lpae_wr ? {1'b0,       // [10]    RAZ
                                          1'b1,       // [9]     LPAE format
                                                      // [8]     Always RAZ so not sent
                                          {2{1'b0}},  // [7:6]   RAZ
                                          6'b100010}  // [5:0]   Status
                                       :
                                         {1'b0,       // [10]    Status
                                          1'b0,       // [9]     RAZ
                                                      // [8]     Always RAZ so not sent
                                          {4{1'b0}},  // [7:4]   Domain - unknown for WPT
                                          4'b0010})}; // [3:0]   Status
      default: expt_dfsr_wr_o = {13{1'bx}};
    endcase

  // IFSR
  // - IFSR[31:13] is RAZ for both LPAE and VMSA format, so do not encode
  always @*
    case ({cp_icimvau_i, (early_expt_type_wr == `CA53_EXPT_TYPE_INSTR_FAULT) | (early_expt_type_wr == `CA53_EXPT_TYPE_PC_ALIGNMENT)})
      `ca53dpu_sel_1x: // Instruction cache invalidate precise data abort
        expt_ifsr_wr_o = dcu_abort_lpae_wr ? {dcu_p_fault_dc3_i[6],    // [12]    ExT
                                              2'b00,                   // [11:10] RAZ
                                              1'b1,                    // [9]     LPAE Format
                                              3'b000,                  // [8:6]   RAZ
                                              dcu_p_fault_dc3_i[5:0]}  // [5:0]   Status
                                           :
                                             {dcu_fault_vmsa_wr[6],    // [12]    ExT
                                              {8{1'b0}},               // [11:4]  RAZ
                                              dcu_fault_vmsa_wr[3:0]}; // [3:0]   Status
      2'b01          : // Prefetch abort
        expt_ifsr_wr_o = iabort_lpae_wr    ? {ifu_ifsr_i[6],           // [12]    ExT
                                              2'b00,                   // [11:10] RAZ
                                              1'b1,                    // [9]     LPAE Format
                                              3'b000,                  // [8:6]   RAZ
                                              ifu_ifsr_i[5:0]}         // [5:0]   Status
                                           :
                                             {ifu_fault_vmsa_wr[6],    // [12]    ExT
                                              {8{1'b0}},               // [11:4]  RAZ
                                              ifu_fault_vmsa_wr[3:0]}; // [3:0]   Status
      2'b00          : // Debug event
        expt_ifsr_wr_o = iabort_lpae_wr    ? {1'b0,                    // [12]    ExT (must be 0)
                                              2'b00,                   // [11:10] RAZ
                                              1'b1,                    // [9]     LPAE Format
                                              3'b000,                  // [8:6]   RAZ
                                              6'b100010}               // [5:0]   Status
                                           :
                                             {1'b0,                    // [12]    ExT (must be 0)
                                              {8{1'b0}},               // [11:4]  RAZ
                                              4'b0010};                // [3:0]   Status
      default        : expt_ifsr_wr_o = {13{1'bx}};
    endcase

  // ------------------------------------------------------
  // WFI/WFE exception pending signals
  // ------------------------------------------------------
  // When an interrupt or imprecise abort has occured then from the WFI/WFE perspective
  // the exception is outstanding until handled. WFE differs from WFI in that the masked
  // interrupt sources must be used
  assign wfi_expt_exception_pending_o =  (gic_fiq_reg               & ~pend_fiq)  |
                                         (gic_irq_reg               & ~pend_irq)  |
                                         (imprecise_pending         & ~pend_ea)   |
                                         (vimprecise_pending        & ~pend_va)   |
                                         ((gic_vfiq_reg | hcr_vf_i) & ~pend_vf)   |
                                         ((gic_virq_reg | hcr_vi_i) & ~pend_vi)   |
                                         dbg_hw_halt_req_i                        |
                                         held_dbg_hw_halt_req_i;

  assign wfe_expt_exception_pending_o = ((gic_fiq_reg               & ~mask_fiq & ~pend_fiq) |
                                         (gic_irq_reg               & ~mask_irq & ~pend_irq) |
                                         (imprecise_pending         & ~mask_ea  & ~pend_ea)  |
                                         (vimprecise_pending        & ~mask_va  & ~pend_va)  |
                                         ((gic_vfiq_reg | hcr_vf_i) & ~mask_vf  & ~pend_vf)  |
                                         ((gic_virq_reg | hcr_vi_i) & ~mask_vi  & ~pend_vi)  |
                                         dbg_hw_halt_req_i                                   |
                                         held_dbg_hw_halt_req_i) &
                                        (current_state == ST_EXPT_IDLE);

  // ------------------------------------------------------
  // Governor power control and GIC interface signals
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_irq_pended_o  <= 1'b0;
      dpu_fiq_pended_o  <= 1'b0;
      dpu_sei_pended_o  <= 1'b0;
      dpu_irq_masked_o  <= 1'b0;
      dpu_fiq_masked_o  <= 1'b0;
      dpu_sei_masked_o  <= 1'b0;
      dpu_virq_pended_o <= 1'b0;
      dpu_vfiq_pended_o <= 1'b0;
      dpu_vsei_pended_o <= 1'b0;
      dpu_virq_masked_o <= 1'b0;
      dpu_vfiq_masked_o <= 1'b0;
      dpu_vsei_masked_o <= 1'b0;
    end else if (nxt_wfx_ifu_halt_i) begin
      dpu_irq_pended_o  <= pend_irq;
      dpu_fiq_pended_o  <= pend_fiq;
      dpu_sei_pended_o  <= pend_ea;
      dpu_irq_masked_o  <= mask_irq;
      dpu_fiq_masked_o  <= mask_fiq;
      dpu_sei_masked_o  <= mask_ea;
      dpu_virq_pended_o <= pend_vi;
      dpu_vfiq_pended_o <= pend_vf;
      dpu_vsei_pended_o <= pend_va;
      dpu_virq_masked_o <= mask_vi;
      dpu_vfiq_masked_o <= mask_vf;
      dpu_vsei_masked_o <= mask_va;
    end

  // ------------------------------------------------------
  // Output aliases
  // ------------------------------------------------------

  // Indicate which interrupts are pending (used to form ISR in CP block)
  assign expt_serr_pending_o  = pend_va ? imprecise_pending :  vimprecise_pending;
  assign expt_irq_pending_o   = pend_vi ? gic_irq_reg       : (hcr_vi_i | gic_virq_reg);
  assign expt_fiq_pending_o   = pend_vf ? gic_fiq_reg       : (hcr_vf_i | gic_vfiq_reg);

  assign insert_forceop_wr_o  = exception_valid_wr; // All exceptions insert a forceop
  assign insert_forceop_ret_o = insert_forceop_ret;
  assign forceop_valid_wr_o   = (current_state == ST_EXPT_WR_FORCEOP);
  assign ns_state_o           = ns_state;
  assign wfi_expt_wr_o        = early_expt_is_wfi;
  assign wfe_expt_wr_o        = early_expt_is_wfe;
  assign expt_in_halt_o       = expt_in_halt;
  assign end_expt_in_halt_o   = end_expt_in_halt;
  assign expt_slot1_wr_o      = expt_slot1_wr;
  assign expt_quash_wr_o      = expt_quash_wr;

  // Output to Governor WFx wakeup logic
  assign dpu_imp_abort_pending_o = imp_abort_pending;

  // - Indicate to control logic when the DCU is returing an exception as
  // so that it can determine when an exception is for slot 1 and not slot 0.
  // - A speculative version of the signal is used, however it will only be
  // wrong when either Wr is stalling (not a problem as the signal factors
  // into logic qualified with ~stall) or when the DCU exception is not the
  // exception taken (not a problem as both slot 0 and slot 1 will be
  // quashed).
  assign early_expt_dcu_wr_o = ls_valid_wr_i & dcu_valid_dc3_i & (dcu_p_abort_dc3_i | dcu_wpt_hit_dc3_i | dcu_ecc_err_dc3_i);

  // Debug control signals
  assign dbg_event_o            = ((expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT) |
                                   (expt_type_wr == `CA53_EXPT_TYPE_WPT)) & 
                                  (current_state == ST_EXPT_IDLE) & ~exception_aa64_wr;

  assign dbg_event_halt_wr_o    = enter_halt_wr & (current_state == ST_EXPT_IDLE);
  
  assign debug_status_wr        = take_early_expt_wr ? early_expt_debug_status_wr :
                                                       late_debug_status_wr;

  // PMU events
  assign evnt_fiq_taken_o       = (current_state == ST_EXPT_IDLE) & expt_fiq_taken;
  assign evnt_irq_taken_o       = (current_state == ST_EXPT_IDLE) & expt_irq_taken;
  assign evnt_expt_taken_o      = (current_state == ST_EXPT_DPU_FLUSH) & ~in_halt_i;
  assign evnt_call_expt_taken_o = (current_state == ST_EXPT_DPU_FLUSH) & (expt_type == `CA53_EXPT_TYPE_CALL);

  // Signals for ETM interface
  // - Form exception type
  assign expt_type_wr = take_early_expt_wr  ? early_expt_type_wr : late_expt_type_wr;
  
  always @(posedge clk)
    if (exception_valid_wr)
      expt_type <= expt_type_wr;

  assign expt_type_l1_ecc_o   = (nxt_state == ST_EXPT_DPU_FLUSH)     & (expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC);
  assign expt_type_o          = expt_type;
  assign etm_trace_expt_o     = (current_state == ST_EXPT_DPU_FLUSH) & (expt_type != `CA53_EXPT_TYPE_ECC_REEXEC) & ~in_halt_i;  // In flush and not entering halt
  assign etm_trace_dbgentry_o = (current_state == ST_EXPT_DPU_FLUSH) & (expt_type == `CA53_EXPT_TYPE_DEBUG_HLT);
  assign expt_dbgexit_o       = (current_state == ST_EXPT_DPU_FLUSH) & (expt_type == `CA53_EXPT_TYPE_DEBUG_EXIT);

  // DBGDSCR.MOE (method of debug entry) is updated in wr-stage when exception is taken.
  // Use the same generation method as the EDSCR.STATUS field
  assign expt_status_moe_data_wr_o = debug_status_wr;

  assign target_exception_level_o  = exception_el_ret;

  assign dpu_sei_level_ack_o  = dpu_sei_level_ack;
  assign dpu_vsei_level_ack_o = dpu_vsei_level_ack;
  assign dpu_rei_level_ack_o  = dpu_rei_level_ack;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // In debug state data abort exceptions are never taken to EL3
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"In debug state data abort exceptions are never taken to EL3")
    ovl_expt_dbg_d_abt_el3 (.clk              (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (in_halt_i & (late_expt_type_wr == `CA53_EXPT_TYPE_DATA) & (dpu_exception_level_i != `CA53_EL3) & 
                                               ((aarch64_at_el_i[`CA53_EL3]) | (~aarch64_at_el_i[`CA53_EL3] & ns_state))),
                            .consequent_expr  (exception_el_wr != `CA53_EL3));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Undefined instructions in debug state are taken to the current EL or EL1 if currently EL0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Undefined instructions in debug state are taken to the current EL or EL1 if currently EL0")
    ovl_expt_dbg_undef_el (.clk              (clk),
                           .reset_n          (reset_n),
                           .antecedent_expr  (in_halt_i & (late_expt_type_wr == `CA53_EXPT_TYPE_TRAP)),
                           .consequent_expr  ((exception_el_wr == dpu_exception_level_i) | 
                                               ((dpu_exception_level_i == `CA53_EL0) & exception_el_wr == `CA53_EL0)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should not be writing ESR when x-assignment can be reached in late_expt_esr case statement
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"late_expt_type_wr unexpected value when writing esr")
    ovl_expt_typ_esr   (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (~take_early_expt_wr &
                                           (expt_fault_reg_en_wr_o[`CA53_FAULT_REG_EN_ESR_EL1] |
                                            expt_fault_reg_en_wr_o[`CA53_FAULT_REG_EN_ESR_EL2] |
                                            expt_fault_reg_en_wr_o[`CA53_FAULT_REG_EN_ESR_EL3])),
                        .consequent_expr  ((late_expt_type_wr == `CA53_EXPT_TYPE_IMPRECISE) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_SP_ALIGNMENT) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_DATA) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_WPT) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_DEBUG_EXPT)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should not be writing DFSR when x-assignment can be reached in late_expt_esr case statement
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"late_expt_type_wr unexpected value when writing dfsr")
    ovl_expt_type_dfsr (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (expt_fault_reg_en_wr_o[`CA53_FAULT_REG_EN_DFSR]),
                        .consequent_expr  ((late_expt_type_wr == `CA53_EXPT_TYPE_IMPRECISE) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_DATA) |
                                           (late_expt_type_wr == `CA53_EXPT_TYPE_WPT)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and take an exception at a lower exception level than current
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr is trying to go to lower exception level than current")
    ovl_el_lower       (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_wr &
                                           (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXIT) &
                                           (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                        .consequent_expr  (exception_el_wr >= dpu_exception_level_i));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and take an exception at EL0
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr is trying to take exception in EL0")
    ovl_el0            (.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_wr & ~enter_halt_wr &
                                           (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXIT) &
                                           (expt_type_wr != `CA53_EXPT_TYPE_ECC_REEXEC)),
                        .consequent_expr  (exception_el_wr != `CA53_EL0));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Should never try and go to AA32 mode on exception taken in AA64
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr is trying to go from AA64 to AA32")
    ovl_el_aa64_to_aa32(.clk              (clk),
                        .reset_n          (reset_n),
                        .antecedent_expr  (exception_valid_wr & aarch64_state_i &
                                           (expt_type_wr != `CA53_EXPT_TYPE_RESET) &
                                           (expt_type_wr != `CA53_EXPT_TYPE_DEBUG_EXIT)),
                        .consequent_expr  (~exception_mode_wr[4]));  // Mode[4] specifies AA32/64
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of exception_aa64_wr case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "exception_aa64_wr x-assignment should not be reached")
  u_ovl_expt_aa64_wr_x       (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (exception_valid_wr & ~enter_halt_wr & ~dbg_restart_qual_i),
                              .test_expr (exception_aa64_wr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Exception state machine state should never be X
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, EXPT_FSM_W, `OVL_ASSERT, "Exception state machine state X")
  u_ovl_current_state_x      (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (current_state));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Exception state machine should never be in invalid state
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Exception state machine in invalid state")
    ovl_current_state_valid (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr ((current_state == ST_EXPT_RESET0)            |
                                         (current_state == ST_EXPT_RESET1)            |
                                         (current_state == ST_EXPT_RESET_FLUSH)       |
                                         (current_state == ST_EXPT_IDLE)              |
                                         (current_state == ST_EXPT_DPU_FLUSH)         |
                                         (current_state == ST_EXPT_DE_FORCEOP)        |
                                         (current_state == ST_EXPT_ISS_FORCEOP)       |
                                         (current_state == ST_EXPT_EX1_FORCEOP)       |
                                         (current_state == ST_EXPT_EX2_FORCEOP)       |
                                         (current_state == ST_EXPT_WR_FORCEOP)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of cpsr_wr_en_ret case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, `CA53_SEL_CPSR_EN_W, `OVL_ASSERT, "cpsr_wr_en_ret x-assignment should not be reached")
  u_ovl_expt_cpsr_wr_en_ret_x(.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (insert_forceop_ret_o),
                              .test_expr (expt_cpsr_wr_en_ret_o));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of exception_vector_aa32_base_ret case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 27, `OVL_ASSERT, "exception_vector_aa32_base_ret x-assignment should not be reached")
  u_ovl_expt_vec_base_aa32_ret_x  (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (insert_forceop_ret_o & (expt_type != `CA53_EXPT_TYPE_RESET) & ~expt_force_to_instr_addr & exception_mode_ret[4]),
                                   .test_expr (exception_vector_aa32_base_ret[31:5]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of exception_vector_aa64_base_ret case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 53, `OVL_ASSERT, "exception_vector_aa64_base_ret x-assignment should not be reached")
  u_ovl_expt_vec_base_aa64_ret_x  (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (insert_forceop_ret_o & (expt_type != `CA53_EXPT_TYPE_RESET) & ~expt_force_to_instr_addr & ~exception_mode_ret[4]),
                                   .test_expr (exception_vector_aa64_base_ret[63:11]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Unspecified branch of forceop_reexec_pc_offset_sl0_ret case statement should never be exercised
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Unspecified input combination for forceop_reexec_pc_offset_sl0_ret should not be seen")
    ovl_reexec_pc_offset_sl0_unspecified (
      .clk       (clk),
      .reset_n   (reset_n),
      .antecedent_expr ((current_state == ST_EXPT_DPU_FLUSH) & 
                        expt_force_to_instr_addr &
                        (expt_type != `CA53_EXPT_TYPE_DEBUG_EXIT) &
                        ~expt_slot1_ret_i),
      .consequent_expr (isa_instr0_ret_i[1:0] != 2'b11)
    );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Unspecified branch of forceop_reexec_pc_offset_sl1_ret case statement should never be exercised
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Unspecified input combination for forceop_reexec_pc_offset_sl1_ret should not be seen")
    ovl_reexec_pc_offset_sl1_unspecified (
      .clk       (clk),
      .reset_n   (reset_n),
      .antecedent_expr ((current_state == ST_EXPT_DPU_FLUSH) & 
                        expt_force_to_instr_addr &
                        (expt_type != `CA53_EXPT_TYPE_DEBUG_EXIT) &
                        expt_slot1_ret_i),
      .consequent_expr (({size_instr1_ret_i, isa_instr0_wr_i[1:0]} == 3'b100) |
                        ({size_instr1_ret_i, isa_instr0_wr_i[1:0]} == 3'b001) |
                        ({size_instr1_ret_i, isa_instr0_wr_i[1:0]} == 3'b101) |
                        ({size_instr1_ret_i, isa_instr0_wr_i[1:0]} == 3'b110))
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Default branch of forceop_reexec_pc_offset_ret case statement should never be reached
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never_unknown #(`OVL_FATAL, 17, `OVL_ASSERT, "forceop_reexec_pc_offset_ret x-assignment should not be reached")
  u_ovl_reexec_pc_offset_x (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((current_state == ST_EXPT_DPU_FLUSH) &
                expt_force_to_instr_addr &
                (expt_type != `CA53_EXPT_TYPE_DEBUG_EXIT)),
    .test_expr (forceop_reexec_pc_offset_ret)
  );
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Signals which are registered to improve timing should be same as their combinatorial equivalents
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"insert_forceop_ret register not equivalent to combinatorial version")
    ovl_forceop_ret_valid   (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (insert_forceop_ret == ((current_state == ST_EXPT_DPU_FLUSH))));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"forceop_valid_de_o register not equivalent to combinatorial version")
    ovl_forceop_de_valid    (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (forceop_valid_de_o == (current_state == ST_EXPT_DE_FORCEOP)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Auto-generated x-check asserts for register enables
  //----------------------------------------------------------------------------
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gov_int_active_reg")
  u_ovl_x_gov_int_active_reg (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (gov_int_active_reg));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_wfx_ifu_halt_i")
  u_ovl_x_nxt_wfx_ifu_halt_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (nxt_wfx_ifu_halt_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: taken_en")
  u_ovl_x_taken_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (taken_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: exception_valid_wr")
  u_ovl_x_exception_valid_wr (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (exception_valid_wr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ns_state_en")
  u_ovl_x_ns_state_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (ns_state_en));

  //----------------------------------------------------------------------------
  // x-check asserts for signals used in if statements (other than register enables)
  //----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "If statement x-check: exception_valid_nostate_wr")
  u_ovl_x_exception_valid_nostate_wr (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .qualifier (1'b1),
                                      .test_expr (exception_valid_nostate_wr));

  //----------------------------------------------------------------------------
  // Mode should be consistent with exception level
  // Exclude halt entry, as will remain in current mode
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA64 EL1")
    ovl_mode_el_aa64_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL1) & ~enter_halt_wr &
                                             aarch64_at_el_i[1] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  (exception_mode_wr == `CA53_FULL_MODE_EL1H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA32 EL1")
    ovl_mode_el_aa32_el1 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL1) & ~enter_halt_wr &
                                             ~aarch64_at_el_i[1] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  ((exception_mode_wr == `CA53_FULL_MODE_SVC) |
                                             (exception_mode_wr == `CA53_FULL_MODE_UND) |
                                             (exception_mode_wr == `CA53_FULL_MODE_FIQ) |
                                             (exception_mode_wr == `CA53_FULL_MODE_IRQ) |
                                             (exception_mode_wr == `CA53_FULL_MODE_ABT) |
                                             (exception_mode_wr == `CA53_FULL_MODE_MON)));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA64 EL2")
    ovl_mode_el_aa64_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL2) & ~enter_halt_wr &
                                             aarch64_at_el_i[2] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  (exception_mode_wr == `CA53_FULL_MODE_EL2H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA32 EL2")
    ovl_mode_el_aa32_el2 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL2) & ~enter_halt_wr &
                                             ~aarch64_at_el_i[2] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  (exception_mode_wr == `CA53_FULL_MODE_HYP));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA64 EL3")
    ovl_mode_el_aa64_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL3) & ~enter_halt_wr &
                                             aarch64_at_el_i[3] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  (exception_mode_wr == `CA53_FULL_MODE_EL3H));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Exception in Wr: Mode not consistent with target exception level of AA32 EL3")
    ovl_mode_el_aa32_el3 (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (exception_valid_wr & (exception_el_wr == `CA53_EL3) & ~enter_halt_wr &
                                             ~aarch64_at_el_i[3] & (nxt_cpsr_wr_en_ret != `CA53_CPSR_WR_EN_EARLY_NULL)),
                          .consequent_expr  ((exception_mode_wr == `CA53_FULL_MODE_SVC) |
                                             (exception_mode_wr == `CA53_FULL_MODE_SYS) |
                                             (exception_mode_wr == `CA53_FULL_MODE_UND) |
                                             (exception_mode_wr == `CA53_FULL_MODE_FIQ) |
                                             (exception_mode_wr == `CA53_FULL_MODE_IRQ) |
                                             (exception_mode_wr == `CA53_FULL_MODE_ABT) |
                                             (exception_mode_wr == `CA53_FULL_MODE_MON)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // Ensure that interrupt signals are clocked low
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Interrupt clock enable low while interrupt active")
    ovl_int_clk_en (.clk              (clk),
                    .reset_n          (reset_n),
                    .antecedent_expr  (gic_irq_reg  |
                                       gic_fiq_reg  |
                                       gic_virq_reg |
                                       gic_vfiq_reg |
                                       gov_sei_reg  |
                                       gov_vsei_reg |
                                       gov_rei_reg),
                    .consequent_expr  (gov_int_active_reg | gov_int_active_i));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_exception

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
