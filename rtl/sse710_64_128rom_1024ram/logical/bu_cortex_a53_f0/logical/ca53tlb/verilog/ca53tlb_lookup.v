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

//-----------------------------------------------------------------------------
// Abstract : TLB descriptor lookup logic.
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_lookup `CA53_TLB_PARAM_DECL
 (
  input  wire                           clk,
  input  wire                           reset_n,

  input  wire                           dpu_ns_state_i,
  input  wire                           dpu_scr_el3_ns_i,
  input  wire                           dpu_mmu_on_el3_i,
  input  wire                           dpu_mmu_on_el1_i,
  input  wire                           dpu_mmu_on_el2_i,

  input  wire                           dcu_va_valid_dc1_i,
  input  wire                           dcu_va_valid_early_dc1_i,
  input  wire [2:0]                     dcu_transl_type_dc1_i,
  input  wire                           dpu_utlb_hit_dc1_i,
  input  wire [63:12]                   dpu_va_dc1_i,
  input  wire                           dcu_block_lookups_i,

  input  wire                           ifu_utlb_miss_req_i,
  input  wire [63:12]                   ifu_va_if2_i,

  output wire                           start_pagewalk_o,
  output wire                           lookup_active_o,
  output wire                           lookup_iside_o,
  output wire [1:0]                     lookup_victim_way_size0_o,
  output wire [1:0]                     lookup_victim_way_size1_o,
  output wire [1:0]                     lookup_victim_way_size2_o,
  output wire [1:0]                     lookup_victim_way_size3_o,

  input  wire                           lookup_ram_pri_i,
  input  wire                           pagewalk_state_idle_i,
  input  wire                           pagewalk_busy_iside_i,
  input  wire                           pagewalk_busy_dside_i,
  input  wire                           pagewalk_invalidated_i,
  output wire [48:12]                   lookup_va_o,
  output wire                           lookup_va_sign_err_o,
  output wire                           lookup_va_mmuoff_sign_err_o,
  output wire                           lookup_ns_o,
  output wire                           lookup_mmuon_o,
  output wire                           lookup_el2_o,
  output wire                           lookup_v2p_ipa_o,
  output wire                           tlb_cp_reg_write_ready_o,
  output wire                           tlb_wfx_ready_o,

  input  wire [`CA53_ASID_W-1:0]        asid_lookup_i,
  input  wire                           tcr_tbi0_i,
  input  wire                           tcr_tbi1_i,
  output wire                           cp_op_waiting_o,
  input  wire                           dcu_cp_ns_i,
  input  wire [`CA53_DCU_CP_ADDR_W-1:0] dcu_cp_addr_tlb_i,
  input  wire [7:0]                     tlb_vmid_i,
  input  wire                           dpu_default_cacheable_i,
  input  wire [1:0]                     dpu_exception_level_i,
  input  wire [3:1]                     dpu_aarch64_at_el_i,

  input  wire                           dpu_tlb_abandon_i,
  input  wire                           sel_victim_round_robin_i,
  input  wire [1:0]                     first_available_way_i,

  output wire                           cp_inv_finished_o,
  output wire                           tlb_cp_ack_o,

  output wire                           lookup_ram_req_o,
  output wire [3:0]                     lookup_ram_way_o,
  output wire                           lookup_ram_next_req_o,
  output wire                           lookup_ram_wr_o,
  output wire                           lookup_ram_ready_o,
  output wire [7:0]                     lookup_ram_next_addr_o,
  output wire [2:0]                     lookup_ram_d_size_o,
  output wire [2:0]                     lookup_ram_i_size_o,
  output wire                           lookup_state_lookup_o,

  output wire [48:12]                   lookup_compare_va_o,
  output wire [2:0]                     lookup_compare_size_o,
  output wire                           lookup_compare_size_ipa_o,
  output wire                           lookup_compare_ns_o,
  output wire                           lookup_compare_hyp_o,
  output wire                           lookup_compare_el3_o,
  output wire [`CA53_ASID_W-1:0]        lookup_compare_asid_o,
  output wire [7:0]                     lookup_compare_vmid_o,

  output wire                           lookup_compare_use_va_o,
  output wire                           lookup_compare_use_asid_o,
  output wire                           lookup_compare_use_global_o,
  output wire                           lookup_compare_use_vmid_o,
  input  wire                           lookup_hit_i,
  input  wire [3:0]                     cp_lookup_hit_way_i,

  output wire                           lookup_i_utlb_might_enable_o,
  output wire                           lookup_d_utlb_might_enable_o,
  output wire                           lookup_i_utlb_next_might_enable_o,
  output wire                           lookup_d_utlb_next_might_enable_o,

  input  wire                           pagewalk_hitmap_update_iside_i,
  input  wire                           pagewalk_hitmap_update_dside_i,
  input  wire [2:0]                     pagewalk_hitmap_size_i,
  input  wire                           pagewalk_size_reduced_i,

  output wire                           ipa_hitmap_flush_o,

  input  wire                           ttbcr_eae_s_i,
  input  wire                           ttbcr_eae_ns_i,

  input  wire                           dcu_cp_valid_tlb_i,
  input  wire [`CA53_DCU_CP_OP_W-1:0]   dcu_cp_op_tlb_i,

  output wire                           dbgdr_reg_wr_en_o,
  output wire [1:0]                     dbgdr_ram_way_o,

  output wire [3:1]                     lookup_aarch64_at_el_o,
  output wire                           lookup_aarch64_o,
  output wire [1:0]                     lookup_exception_level_o,
  output wire [3:2]                     lookup_exception_level_early_o,

  input  wire                           lookup_ecc_err_i,
  input  wire [3:0]                     lookup_ecc_err_way_i,
  output wire                           lookup_ecc_err_early_o,
  output wire [3:0]                     lookup_ecc_err_way_early_o,

  input  wire                           mbist_en_i,

  // Support for granule calculation 
  input  wire [5:0]                     tcr_a64_el1_t0sz_i,
  input  wire [5:0]                     tcr_a64_el2_t0sz_i,
  input  wire [5:0]                     tcr_a64_el3_t0sz_i,
  input  wire                           tcr_a64_el2_tg0_i,
  input  wire                           tcr_a64_el3_tg0_i,
  input  wire                           vtcr_tg0_i,
  input  wire                           dpu_ipa_to_pa_en_i,

  output wire [47:20]                   lookup_va_early_o,
  output wire                           lookup_ns_early_o,
  output wire                           lookup_aarch64_at_el3_early_o,
  output wire                           lookup_aarch64_early_o,

  output wire [5:0]                     lookup_tcr_a64_muxed_t0sz_o,
  output wire                           lookup_stage2_a64_g64_o,
  output wire                           lookup_el3_el2_o,
  output wire                           lookup_el3_el2_g64_o,
  output wire                           lookup_ttbr0_sign_match_o,

  // Support for ECC reporting
  output wire                           tlb_pty_valid_cp_o,
  output wire [2:0]                     tlb_pty_way_cp_o
  );

  //------------------------------------------------------------------------------
  // Flop declarations
  //------------------------------------------------------------------------------

  reg [`CA53_LOOKUP_ST_WIDTH-1:0]      lookup_state;
  reg                                  lookup_iside_early;
  reg                                  lookup_ns_early;
  reg [48:12]                          lookup_va_early;
  reg                                  lookup_va_sign_err_early;
  reg                                  lookup_el2_early;
  reg                                  lookup_el0_early;
  reg                                  lookup_el1_early;
  reg                                  lookup_el3_early;
  reg                                  lookup_lpae_early;
  reg [4:0]                            lookup_cp15_type_early;
  reg [`CA53_ASID_W-1:0]               lookup_asid;
  reg [7:0]                            lookup_vmid;
  reg [7:0]                            master_hitmap;
  reg [5:0]                            i_size_order;
  reg [5:0]                            d_size_order;
  reg [2:0]                            lookup_compare_size;
  reg                                  lookup_compare_size_ipa;
  reg [3:1]                            lookup_size_remaining;
  reg [1:0]                            lookup_victim_way_size0_early;
  reg [1:0]                            lookup_victim_way_size1_early;
  reg [1:0]                            lookup_victim_way_size2_early;
  reg [1:0]                            lookup_victim_way_size3_early;

  reg [1:0]                            victim_round_robin;
  reg                                  cp_op_waiting;
  reg [7:0]                            cp_inv_count;
  reg [3:0]                            cp_hit_way;
  reg                                  reduced_size_hitmap;

  reg  [`CA53_LOOKUP_ST_WIDTH-1:0]     next_lookup_state;

  reg  [3:1]                           lookup_aarch64_at_el_early;
  reg  [6:0]                           next_lookup_ram_addr;
  reg                                  lookup_va_mmuoff_sign_err_early;

  //------------------------------------------------------------------------------
  // Wire declarations
  //------------------------------------------------------------------------------

  wire                                 lookup_state_idle;
  wire                                 lookup_state_lookup;
  wire                                 lookup_state_wait;
  wire                                 lookup_state_cp_read0;
  wire                                 lookup_state_cp_read1;
  wire                                 lookup_state_cp_write0;
  wire                                 lookup_state_cp_write1;
  wire                                 lookup_state_dbg_rd_addr;
  wire                                 lookup_state_dbg_rd_data;
  wire                                 lookup_state_cp;
  wire                                 lookup_state_cp_write_all;
  wire                                 new_lookup_starting;
  wire                                 start_pagewalk;
  wire                                 lookup_iside;
  wire                                 lookup_ns;
  wire [48:12]                         lookup_va;
  wire                                 lookup_va_sign_err;
  wire [`CA53_ASID_W-1 :0]             next_lookup_asid;
  wire [7:0]                           next_lookup_vmid;
  wire                                 master_hitmap_flush;
  wire                                 ipa_hitmap_flush;
  wire                                 lookup_en;
  wire                                 tlb_ram_en_lookups;
  wire                                 cp_inv_finished;
  wire [1:0]                           dbgdr_ram_way;
  wire [3:0]                           dbgdr_ram_en;
  wire                                 cp_ack_dbgdr;
  wire                                 lookup_state_en;
  wire                                 master_hitmap_en;
  wire [7:0]                           next_master_hitmap;
  wire [7:0]                           full_i_size_order;
  wire [7:0]                           full_d_size_order;
  wire [1:0]                           i_size_order_shift;
  wire [1:0]                           d_size_order_shift;
  wire [5:0]                           next_i_size_order;
  wire [5:0]                           next_d_size_order;
  wire                                 i_size_order_en;
  wire                                 d_size_order_en;
  wire [1:0]                           i_hit_size;
  wire [1:0]                           d_hit_size;
  wire                                 lookup_lpae;
  wire [7:0]                           lookup_size_order;
  wire [3:0]                           lookup_size_order_valid;
  wire [2:0]                           next_lookup_compare_size;
  wire                                 next_lookup_compare_size_ipa;
  wire [3:0]                           next_lookup_size;
  wire [7:0]                           next_ram_addr_early;
  wire [3:0]                           lookup_compare_size_onehot;
  wire [1:0]                           next_victim_round_robin;
  wire [1:0]                           victim_way;
  wire [1:0]                           lookup_victim_way_size0;
  wire [1:0]                           lookup_victim_way_size1;
  wire [1:0]                           lookup_victim_way_size2;
  wire [1:0]                           lookup_victim_way_size3;
  wire [1:0]                           next_lookup_victim_way_size0_early;
  wire [1:0]                           next_lookup_victim_way_size1_early;
  wire [1:0]                           next_lookup_victim_way_size2_early;
  wire [1:0]                           next_lookup_victim_way_size3_early;
  wire [4:0]                           lookup_cp15_type;
  wire                                 next_cp_op_waiting;
  wire                                 main_inval_finished;
  wire                                 walk_inval_finished;
  wire                                 ipa_inval_finished;
  wire                                 ipa_inval_start;
  wire                                 walk_inval_start;
  wire                                 lookup_el0;
  wire                                 lookup_el2;
  wire                                 lookup_el1;
  wire                                 lookup_el3;
  wire [7:0]                           next_cp_inv_count;
  wire [7:0]                           cp_inv_count_incr;
  wire                                 cp_inv_count_en;
  wire                                 invalidating_walk;
  wire                                 invalidating_ipa;
  wire                                 main_inval_addr;
  wire                                 walk_inval_addr;
  wire                                 lookup_ready;
  wire                                 iside_request;
  wire                                 dside_request;
  wire                                 abandon_existing_lookup_iside;
  wire                                 abandon_existing_lookup_dside;
  wire                                 abandon_existing_lookup;
  wire                                 abandon_lookup;
  wire                                 new_cp_op_starting;
  wire                                 new_cp_op_possible;
  wire                                 lookup_mmuon;
  wire                                 lookup_required;
  wire                                 dside_ns_state;
  wire                                 dside_el0;
  wire                                 dside_el1;
  wire                                 dside_el2;
  wire                                 dside_el3;
  wire                                 lookup_v2p_ipa;
  wire [7:0]                           next_cp_index;
  wire [7:0]                           tlb_dbg_addr;
  wire                                 lpae_mispredict;
  wire [3:1]                           next_lookup_size_remaining;
  wire [3:0]                           lookup_size_valid;
  wire [2:0]                           lookup_size_sel;
  wire                                 lookup_utlb_next_might_enable;
  wire                                 next_reduced_size_hitmap;
  wire                                 sel_next_cp_index;
  wire                                 sel_tlb_dbg_addr;
  wire                                 sel_next_lookup_ram_walk_addr;
  wire [7:0]                           next_lookup_ram_walk_addr;
  wire                                 sel_next_lookup_ram_ipa_addr;
  wire [7:0]                           next_lookup_ram_ipa_addr;
  wire                                 lookup_aarch64;
  wire [3:1]                           lookup_aarch64_at_el;
  wire [63:48]                         va_sign_field;
  wire                                 va_sign_clear;
  wire                                 va_sign_set;
  wire                                 va_sign_err;
  wire [47:40]                         va_mmuoff_sign_check;
  wire                                 va_mmuoff_sign_clear;
  wire                                 va_mmuoff_sign_err;
  wire                                 lookup_va_mmuoff_sign_err;
  wire                                 dpu_exception_el0;
  wire                                 dpu_exception_el1;
  wire                                 dpu_exception_el2;
  wire                                 dpu_exception_el3;

  reg                                  lookup_aarch64_early;
  wire                                 start_pagewalk_ecc_err;
  wire                                 start_pagewalk_no_err;

  wire                                 lookup_ecc_err_early_common;
  wire [3:0]                           lookup_ecc_err_way_early_common;

  wire                                 lookup_hitmap_update_iside;
  wire                                 lookup_hitmap_update_dside;

  wire                                 dcu_va_valid_negating;

  // Support for granule calculation 
  wire [5:0]                           next_lookup_tcr_a64_muxed_t0sz;
  wire                                 stage2_lookup_a64_g64;
  wire                                 lookup_stage2_required;
  wire                                 next_lookup_stage2_a64_g64;
  wire                                 next_lookup_el3_el2;
  wire                                 next_lookup_el3_el2_g64;
  wire                                 next_lookup_ttbr0_sign_match;

  reg  [5:0]                           lookup_tcr_a64_muxed_t0sz;
  reg                                  lookup_stage2_a64_g64;
  reg                                  lookup_el3_el2;
  reg                                  lookup_el3_el2_g64;
  reg                                  lookup_ttbr0_sign_match;

  // Support for ECC reporting
  wire                                 tlb_pty_valid_cp_cmn;
  wire [2:0]                           tlb_pty_way_cp_cmn;

  //----------------------------------------------------------------------------
  // 
  //----------------------------------------------------------------------------

  assign dpu_exception_el0 = (dpu_exception_level_i == 2'b00);
  assign dpu_exception_el1 = (dpu_exception_level_i == 2'b01);
  assign dpu_exception_el2 = (dpu_exception_level_i == 2'b10);
  assign dpu_exception_el3 = (dpu_exception_level_i == 2'b11);

  //----------------------------------------------------------------------------
  // New request arbitration
  //----------------------------------------------------------------------------

  // Identify when there is an iside or dside request that is ready for
  // arbitration. If there is a pagewalk in progress for the same side then the
  // request may not start until the pagewalk has completed. This simplifies
  // some logic, and ensures that if the pagewalk is for the same page then the
  // lookup will hit in the main TLB and not have to start a duplicate pagewalk.

  assign dcu_va_valid_negating = ~dcu_va_valid_dc1_i & dcu_va_valid_early_dc1_i;

  assign iside_request = (ifu_utlb_miss_req_i &
                          ~dcu_block_lookups_i &
                          ~dcu_va_valid_negating &
                          ~pagewalk_busy_iside_i);

  assign dside_request = (dcu_va_valid_dc1_i &
                          ~dpu_utlb_hit_dc1_i &
                          ~pagewalk_busy_dside_i);


  // Register when a CP15 request is being made. This allows the registered
  // version to be used for arbitration earlier in the following cycle.
  assign next_cp_op_waiting = dcu_cp_valid_tlb_i & ~(cp_inv_finished | cp_ack_dbgdr);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    cp_op_waiting <= 1'b0;
  end else begin
    cp_op_waiting <= next_cp_op_waiting;
  end

  // New iside lookups have higher priority than CP15 ops if the requests start
  // in the same cycle, however if the CP15 op has been waiting for a cycle or
  // more then it has the highest priority. If a pagewalk is accessing the RAMs
  // this cycle then a new lookup cannot start because it will not be able to
  // read the RAMs.
  assign lookup_ready = lookup_state_idle & ~cp_op_waiting;

  // A new lookup starts whenever the iside or dside can be arbitrated.
  assign new_lookup_starting = (dside_request | iside_request) & lookup_ready & lookup_ram_pri_i;

  // Indicate to the ramctl block when a new request is starting so that it
  // can select the RAM index. The new request from the DCU/IFU is factored in
  // later in the ramctl module to help timing.
  assign lookup_ram_ready_o = lookup_ready;

  // Maintenance requests must not wait for the current pagewalk to finish,
  // because a pagewalk read might be blocked behind the maintenance request.
  // However they can only start once the pagewalk has indicated that it will
  // not update the main TLB at the end of the walk.
  assign new_cp_op_possible = (lookup_state_idle &
                               (cp_op_waiting |
                                (~ifu_utlb_miss_req_i &
                                 ~dcu_va_valid_dc1_i)) & (pagewalk_state_idle_i |
                                                          pagewalk_invalidated_i));

  assign new_cp_op_starting = new_cp_op_possible & dcu_cp_valid_tlb_i;

  // The dside has priority over the iside
  assign lookup_iside = lookup_state_idle ? ~dside_request : lookup_iside_early;

  // A lookup is abandoned part way through if the request that caused it is
  // flushed, or if the MMU is enabled/disabled during the lookup. In the
  // latter case the lookup will start again in the next cycle, taking the new
  // value into account.
  // It will also be abandoned if a cp op is waiting to start and there is an
  // ongoing pagewalk that may not complete before the cp op needs to start.
  assign abandon_existing_lookup_iside = (((lookup_state_lookup | lookup_state_wait) &
                                           (~ifu_utlb_miss_req_i |
                                            (lookup_state_wait & pagewalk_invalidated_i & cp_op_waiting))) |
                                          dpu_tlb_abandon_i);

  assign abandon_existing_lookup_dside = (((lookup_state_lookup | lookup_state_wait) &
                                           (~dcu_va_valid_dc1_i |
                                            (lookup_state_wait & pagewalk_invalidated_i & cp_op_waiting))) |
                                          dpu_tlb_abandon_i);

  assign abandon_existing_lookup = lookup_iside_early ? abandon_existing_lookup_iside :
                                                        abandon_existing_lookup_dside;

  // A lookup is also abandoned on the first cycle if the LPAE format was mispredicted.
  assign abandon_lookup = abandon_existing_lookup | lpae_mispredict;


  //----------------------------------------------------------------------------
  // Capture state required for the lookup
  //----------------------------------------------------------------------------

  // The NS state of a dside lookup must be modified if the operation
  // is a CP15 address translation operation.
  assign dside_ns_state = dpu_ns_state_i |
                          (dpu_exception_el3 & dpu_aarch64_at_el_i[3] & dpu_scr_el3_ns_i &
                           ((dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL0)  |
                            (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL1)  |
                            (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL0)  |
                            (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL1)))  |
                          (dpu_exception_el3 & ~dpu_aarch64_at_el_i[3] &
                           ((dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL0)  |
                            (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL1))) |
                          (dpu_exception_el3 & ~dpu_ns_state_i & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL2) &
                           ((dpu_aarch64_at_el_i[3] & dpu_scr_el3_ns_i) |
                            (~dpu_aarch64_at_el_i[3])));

  // The non-secure state of the current lookup or maintenance op.
  assign lookup_ns = (lookup_state_idle ? (new_cp_op_possible ? dcu_cp_ns_i :
                                           (lookup_iside ? dpu_ns_state_i : dside_ns_state)) :
                      lookup_ns_early);


  // The exception level of dside lookup must be modified if the operation
  // is a CP15 address translation operation.
  assign dside_el2 = (dpu_ns_state_i & dpu_exception_el2 &
                      ((dcu_transl_type_dc1_i == `CA53_TRANSL_NORMAL)  |
                       (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL2))) |
                     (dpu_exception_el3 & ~dpu_ns_state_i & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL2) &
                       ((dpu_aarch64_at_el_i[3] & dpu_scr_el3_ns_i) |
                        (~dpu_aarch64_at_el_i[3])));

  assign dside_el0 = (dpu_exception_el0 & (dcu_transl_type_dc1_i == `CA53_TRANSL_NORMAL)) |
                     (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL0) | // S1_EL0 can not execute in EL0
                     ((dpu_exception_el2 |
                       dpu_exception_el3) & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL0));

  assign dside_el1 = (dpu_exception_el1 & (dcu_transl_type_dc1_i == `CA53_TRANSL_NORMAL)) |
                     ((dpu_exception_el1 |
                       dpu_exception_el2) & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL1)) |
                     (dpu_exception_el3 & dpu_aarch64_at_el_i[3] &
                      (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL1)) |
                     ((dpu_exception_el2 |
                       dpu_exception_el3) & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S12_EL1));

  assign dside_el3 = (dpu_exception_el3 & (dcu_transl_type_dc1_i == `CA53_TRANSL_NORMAL)) |
                     (dpu_exception_el3 & ~dpu_aarch64_at_el_i[3] &
                      (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL1)) |
                     (dpu_exception_el3 & (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL3));

  // The lookup is being performed for hypervisor mode. Although the mode
  // signal is from the issue stage, the DPU will flush its pipe when
  // entering or leaving HYP mode and so does not need pipelining.
  // For CortexA53 CP ops, it is hypervisor mode only if VMID is set with NS broadcast.
  assign lookup_el2 = (lookup_state_idle ? (new_cp_op_possible ?
                                              (dcu_cp_ns_i & dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_VMID_VALID_BITS] ) :
                                              (lookup_iside ? (dpu_ns_state_i & dpu_exception_el2) :
                                                               dside_el2)) :
                       lookup_el2_early);

  assign lookup_el0 = lookup_state_idle ? (lookup_iside ? dpu_exception_el0 : dside_el0) : lookup_el0_early;
  assign lookup_el1 = lookup_state_idle ? (lookup_iside ? dpu_exception_el1 : dside_el1) : lookup_el1_early;
  assign lookup_el3 = lookup_state_idle ? (lookup_iside ? dpu_exception_el3 : dside_el3) : lookup_el3_early;

  // The virtual address for the current lookup or maintenance op. Also holds
  // the index and way for a TLB debug read.
  // Address bit 48 is used for detecting sign bit error. All error cases are captured by using
  // lookup_va_sign_err signal and bit[48] will not be valid in this case
  assign lookup_va[48:12] = lookup_state_idle ?
                             (new_cp_op_possible ? {dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_MVA_SIGN_BITS],
                                                    dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_MVA_BITS]} :
                              lookup_iside ? ifu_va_if2_i[48:12]
                                           : dpu_va_dc1_i[48:12]) : lookup_va_early;

  // - VA[63:48]/VA[55:48] decide the sign. If VA top bits are neither all set nor all clear,
  //   it is an error. When TLB gets a request with this error, it triggers lookup SM,
  //   ignores lookup result and triggers pagewalk SM.
  // - Pagewalk SM, without doing a pagewalk, updates uTLB with translation fault.
  // - Timing of lookup_va_sign_err is same as of lookup_va
  // - TBI is valid for A64 only but here these are checked without differentiating b/w
  //   A32/A64 as for A32 DPU clears [63:48]
  assign va_sign_field = dside_request ? dpu_va_dc1_i[63:48] : ifu_va_if2_i[63:48];
  assign va_sign_clear = tcr_tbi0_i ? ~|(va_sign_field[55:48]) : ~|(va_sign_field[63:48]);
  assign va_sign_set   = tcr_tbi1_i ? &(va_sign_field[55:48]) : &(va_sign_field[63:48]);

  // For EL0/EL1, address should be within  bottom or top address ranges, for EL2 and EL3
  // address should be within bottom address range
  assign va_sign_err = (lookup_iside ? (dpu_exception_el0 | dpu_exception_el1) : (dside_el0 | dside_el1)) ?
                       ~(va_sign_clear | va_sign_set) : ~va_sign_clear;

  assign lookup_va_sign_err = lookup_state_idle ? va_sign_err : lookup_va_sign_err_early;


  // For MMU off case, VA is same as output address. In addition to checking
  // VA[63:48], additional bits VA[47:40] are also checked. But unlike the
  // va_sign_err which is used to generate Translation fault on input address,
  // va_mmuoff_sign_err is used to generate Address size fault on output address
  assign va_mmuoff_sign_check = dside_request ? dpu_va_dc1_i[47:40] : ifu_va_if2_i[47:40];
  assign va_mmuoff_sign_clear = ~|(va_mmuoff_sign_check[47:40]);
  assign va_mmuoff_sign_err   = ~(va_sign_clear & va_mmuoff_sign_clear);

  assign lookup_va_mmuoff_sign_err = lookup_state_idle ? va_mmuoff_sign_err : lookup_va_mmuoff_sign_err_early;

  // The type of maintenance op, or debug read.
  assign lookup_cp15_type = lookup_state_idle ? dcu_cp_op_tlb_i : lookup_cp15_type_early;

  // The ASID for lookups or maintenance ops. This cannot change during the
  // lookup, but is registered to help timing when used in the comparators.
  // TLB always compares full 16-bit ASID from DCU irrespective of present
  // exception level or architecture.
  assign next_lookup_asid = new_cp_op_possible ? dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_ASID_BITS] : asid_lookup_i;

  // The VMID for lookups or maintenance ops. This cannot change during the
  // lookup, but is registered to help timing on cp ops when used in the
  // comparators.
  assign next_lookup_vmid = ((new_cp_op_possible & dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_VMID_VALID_BITS]) ?
                             dcu_cp_addr_tlb_i[`CA53_DCU_CP_ADDR_VMID_BITS] :
                             (~new_cp_op_possible & (lookup_ns & ~lookup_el2)) ? tlb_vmid_i :
                             8'h00);
  // For AR64 and AR32-EL2, LPAE is always set
  // For current exception in A32 and EL3 in AR64, value is from NS register
  // For current exception in A32 and EL3 in AR32, value is from banked NS/S register
  assign lookup_lpae = lookup_state_idle ?
                        (lookup_aarch64 | lookup_el2 |
                         (((lookup_aarch64_at_el[3]) |
                           (lookup_iside ? dpu_ns_state_i : dside_ns_state)) ? ttbcr_eae_ns_i : ttbcr_eae_s_i)):
                       lookup_lpae_early;

  // Select the correct SCTLR.M bit for the current security state and mode,
  // after they have been modified if required for CP15 address translation
  // operations.
  // The UNPREDICTABLE behaviour of HCR.DC and SCTLR.M both being set is
  // treated as if SCTLR.M is not set.
  //
  // Current_exception  Security  EL3  MMU signal to use
  //       EL2          x         x    mmu_on_el2
  //       EL1          NS        x    mmu_on_el1 & ~default_cacheable
  //       EL0          NS        x    mmu_on_el1 & ~default_cacheable
  //       EL1          S         x    mmu_on_el1
  //       EL0          S         A64  mmu_on_el1
  //       EL3          x         x    mmu_on_el3
  //       EL0          S         A32  mmu_on_el3
  assign lookup_mmuon = lookup_el2 ? dpu_mmu_on_el2_i :
                        ((lookup_el0 | lookup_el1) & lookup_ns) ? (dpu_mmu_on_el1_i & ~dpu_default_cacheable_i) :
                        (((lookup_el0 & lookup_aarch64_at_el[3]) | lookup_el1) & ~lookup_ns) ? dpu_mmu_on_el1_i :
                        dpu_mmu_on_el3_i;

  // If either SCTLR.M or HCR.DC is set then translations may be cached in the
  // TLB and so we should do a lookup for them. If neither are set then we can
  // skip the lookup and go straight to starting a pagewalk.
  assign lookup_required = lookup_mmuon | (dpu_default_cacheable_i & ~lookup_el2 & lookup_ns);

  // If the translation requires an IPA as the output, then we should not
  // lookup in the main TLB as the result would be incorrect.
  // Instead, go straight to the wait state, and then start a pagewalk.
  assign lookup_v2p_ipa = (~lookup_iside &
                            lookup_ns & ((dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL0) |
                                         (dcu_transl_type_dc1_i == `CA53_TRANSL_V2P_S1_EL1)));
  assign lookup_v2p_ipa_o = lookup_v2p_ipa;



  assign lookup_aarch64_at_el = lookup_state_idle ? dpu_aarch64_at_el_i : lookup_aarch64_at_el_early;

  assign lookup_aarch64 = (lookup_el0 | lookup_el1) ? lookup_aarch64_at_el[1] :
                          (lookup_el2) ? lookup_aarch64_at_el[2] : lookup_aarch64_at_el[3];

  //------------------------------------------------------------------------------
  // Capture the information only when a new lookup or cp15 op starts.
  //------------------------------------------------------------------------------

  assign lookup_en = new_cp_op_starting | new_lookup_starting;

  always @(posedge clk)
  if (lookup_en) begin
    lookup_ns_early                 <= lookup_ns;
    lookup_el2_early                <= lookup_el2;
    lookup_el0_early                <= lookup_el0;
    lookup_el1_early                <= lookup_el1;
    lookup_el3_early                <= lookup_el3;
    lookup_iside_early              <= lookup_iside;
    lookup_va_early                 <= lookup_va;
    lookup_va_sign_err_early        <= lookup_va_sign_err;
    lookup_va_mmuoff_sign_err_early <= lookup_va_mmuoff_sign_err;
    lookup_cp15_type_early          <= lookup_cp15_type;
    lookup_asid                     <= next_lookup_asid;
    lookup_vmid                     <= next_lookup_vmid;
    lookup_aarch64_at_el_early      <= lookup_aarch64_at_el;
    lookup_aarch64_early            <= lookup_aarch64;
    // Support for granule calculation 
    lookup_tcr_a64_muxed_t0sz       <= next_lookup_tcr_a64_muxed_t0sz;
    lookup_stage2_a64_g64           <= next_lookup_stage2_a64_g64;
    lookup_el3_el2                  <= next_lookup_el3_el2;
    lookup_el3_el2_g64              <= next_lookup_el3_el2_g64;
    lookup_ttbr0_sign_match         <= next_lookup_ttbr0_sign_match;
  end

  // The early lookup_lpae signal must be reset because it is used in the
  // first cycle of the lookup, when it hasn't been updated. Therefore in
  // this cycle it is a speculative signal based on the format of the
  // previous lookup.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    lookup_lpae_early <= 1'b0;
  end else if (lookup_en) begin
    lookup_lpae_early <= lookup_lpae;
  end

  //------------------------------------------------------------------------------
  // Lookup state machine
  //------------------------------------------------------------------------------

  always @*
  begin
    next_lookup_state = lookup_state;
    case (lookup_state)
      `CA53_LOOKUP_ST_IDLE: begin
        if (new_lookup_starting & ~abandon_lookup) begin
          if (lookup_v2p_ipa | ~lookup_required) begin
            next_lookup_state = `CA53_LOOKUP_ST_WAIT;
          end else begin
            next_lookup_state = `CA53_LOOKUP_ST_LOOKUP;
          end
        end else if (new_cp_op_starting) begin
          if (dcu_cp_op_tlb_i == `CA53_CP_TLB_DBG) begin
            next_lookup_state = `CA53_LOOKUP_ST_DBG_RD_ADDR;
          end else if (dcu_cp_op_tlb_i == `CA53_CP_TLBI_ALL_ON_RST) begin
            // If the invalidate all is in secure state, every entry in the RAM
            // is invalidated, so there is no need to read the previous contents.
            next_lookup_state = `CA53_LOOKUP_ST_CP_WRITE_ALL;
          end else begin
            next_lookup_state = `CA53_LOOKUP_ST_CP_READ0;
          end
        end
      end

      `CA53_LOOKUP_ST_LOOKUP: begin
        if (abandon_lookup) begin
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end else if (lookup_ecc_err_i) begin
          // ECC error (with or without hit), PW required
          next_lookup_state = `CA53_LOOKUP_ST_WAIT;
        end else if (lookup_hit_i) begin
          // No ECC error, lookup hit, No PW
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end else if (|lookup_size_remaining) begin
          // No ECC error, no hit, more lookup required
          next_lookup_state = `CA53_LOOKUP_ST_LOOKUP;
        end else begin
          // No ECC error, no hit, no more lookup required, PW required 
          // To help ECC error timing, SM need to wait for a cycle
          next_lookup_state = `CA53_LOOKUP_ST_WAIT;
        end
      end

      `CA53_LOOKUP_ST_WAIT: begin
        if (abandon_lookup) begin
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end else if (pagewalk_state_idle_i) begin
          // The pagewalk can now start
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end
      end

      `CA53_LOOKUP_ST_CP_READ0: begin
        next_lookup_state = `CA53_LOOKUP_ST_CP_READ1;
      end
      `CA53_LOOKUP_ST_CP_READ1: begin
        next_lookup_state = `CA53_LOOKUP_ST_CP_WRITE0;
      end
      `CA53_LOOKUP_ST_CP_WRITE0: begin
        next_lookup_state = `CA53_LOOKUP_ST_CP_WRITE1;
      end
      `CA53_LOOKUP_ST_CP_WRITE1: begin
        if (cp_inv_finished) begin
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end else if (walk_inval_finished &
                     ((lookup_cp15_type  == `CA53_CP_TLB_INV_ALL_NSNH) |
                      ((lookup_cp15_type == `CA53_CP_TLBI_ALLE1) & lookup_ns))) begin

          // Operations that need to invalidate the entire IPA cache can
          // avoid the read/compare/write sequence once the main and walk
          // cache invalidates have finished.
          next_lookup_state = `CA53_LOOKUP_ST_CP_WRITE_ALL;
        end else begin
          next_lookup_state = `CA53_LOOKUP_ST_CP_READ0;
        end
      end
      `CA53_LOOKUP_ST_CP_WRITE_ALL: begin
        if (cp_inv_finished | mbist_en_i) begin
          next_lookup_state = `CA53_LOOKUP_ST_IDLE;
        end else begin
          next_lookup_state = `CA53_LOOKUP_ST_CP_WRITE_ALL;
        end
      end
      `CA53_LOOKUP_ST_DBG_RD_ADDR: begin
        next_lookup_state = `CA53_LOOKUP_ST_DBG_RD_DATA;
      end
      `CA53_LOOKUP_ST_DBG_RD_DATA: begin
        next_lookup_state = `CA53_LOOKUP_ST_IDLE;
      end
      default: begin
        next_lookup_state = `CA53_LOOKUP_ST_X;
      end
    endcase
  end

  // Enable the state machine and other auxiliary logic whenever a request is
  // starting or is in progress.
  assign lookup_state_en = lookup_en | ~lookup_state_idle;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    lookup_state <= `CA53_LOOKUP_ST_IDLE;
  end else if (lookup_state_en) begin
    lookup_state <= next_lookup_state;
  end


  // These comparisons are required in a lot of places.
  assign lookup_state_idle         = lookup_state == `CA53_LOOKUP_ST_IDLE;
  assign lookup_state_lookup       = lookup_state == `CA53_LOOKUP_ST_LOOKUP;
  assign lookup_state_wait         = lookup_state == `CA53_LOOKUP_ST_WAIT;
  assign lookup_state_cp_read0     = lookup_state == `CA53_LOOKUP_ST_CP_READ0;
  assign lookup_state_cp_read1     = lookup_state == `CA53_LOOKUP_ST_CP_READ1;
  assign lookup_state_cp_write0    = lookup_state == `CA53_LOOKUP_ST_CP_WRITE0;
  assign lookup_state_cp_write1    = lookup_state == `CA53_LOOKUP_ST_CP_WRITE1;
  assign lookup_state_cp_write_all = lookup_state == `CA53_LOOKUP_ST_CP_WRITE_ALL;
  assign lookup_state_dbg_rd_addr  = lookup_state == `CA53_LOOKUP_ST_DBG_RD_ADDR;
  assign lookup_state_dbg_rd_data  = lookup_state == `CA53_LOOKUP_ST_DBG_RD_DATA;
  assign lookup_state_cp           = `CA53_LOOKUP_CP(lookup_state);

  assign lookup_state_lookup_o = lookup_state_lookup;
  //-----------------------------------------------------------------------------
  // Logic for TLB maintenance operations
  //-----------------------------------------------------------------------------

  // Count the current position within a CP15 invalidate maintenance operation.
  // For invalidate all operations this corresponds to the RAM index, and for
  // invalidate address operations the lower bits correspond to the page size
  // being looked up.

  assign cp_inv_count_en = (new_cp_op_starting |
                            lookup_state_cp_read0 |
                            lookup_state_cp_write1 |
                            lookup_state_cp_write_all);

  // For walk cache invalidation for MVA/MVA_ASID/MVA_HYP, TLB starts invalidation from
  // locations corresponding to  1M size. Count is selected (i.e. 132) such that LS
  // 3-bits of ram address correspond to size encoding of 1M.
  assign cp_inv_count_incr = ((lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1) ?
                               (cp_inv_count + 8'b00000010) : // Add two
                               (cp_inv_count + 8'b00000001)); // Add one

  assign next_cp_inv_count = (new_cp_op_possible & (lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1)) ? 8'b10010001 : // 145
                              new_cp_op_possible  ? 8'b00000000 :
                              main_inval_finished ? (walk_inval_addr ? 8'b10000100 : 8'b10000000) : // 132:128
                              walk_inval_finished ? 8'b10010000 : // 144
                              cp_inv_count_incr;

  always @(posedge clk)
  if (cp_inv_count_en) begin
    cp_inv_count <= next_cp_inv_count;
  end

  // The upper bits of the count determine which portion of the RAM is being
  // accessed (main TLB, walk cache or IPA cache).
  assign invalidating_walk = (cp_inv_count[7:4] == `CA53_RAM_WALK_PREFIX_ADDR);

  assign invalidating_ipa = (cp_inv_count[7:4] == `CA53_RAM_IPA_PREFIX_ADDR);

  // Signal showing if MVA CP operations in main TLB RAM can look into targeted
  // RAM addresses only
  // - MVA CP operations for single stage translations (MVA_HYP) can always
  //   look into targeted addresses only, ignoring reduced size signal
  // - MVA CP operations for two stage translations can look into targeted
  //   addresses only when reduced size hitmap was not asserted
  assign main_inval_addr = (lookup_cp15_type == `CA53_CP_TLBI_VAE2) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VAE3) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VALE3) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VALE2) |
                           (((lookup_cp15_type == `CA53_CP_TLBI_VALE1) |
                            (lookup_cp15_type == `CA53_CP_TLBI_VAALE1) |
                             (lookup_cp15_type == `CA53_CP_TLBI_VAE1) |
                             (lookup_cp15_type == `CA53_CP_TLBI_VAAE1)) &
                            ~(lookup_ns & reduced_size_hitmap));

  // Signal showing MVA CP operation in walk RAM is required
  assign walk_inval_addr = (lookup_cp15_type == `CA53_CP_TLBI_VAE2) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VAE1) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VAAE1) |
                           (lookup_cp15_type == `CA53_CP_TLBI_VAE3);

  // Determine when the operation has invalidated all the relevant entries in
  // the main TLB RAM.
  //   For CP OPs that can use targeted lookups, count ends at 9
  //   For CP OPs that lookup in all TLB RAM, count ends at 127
  assign main_inval_finished = (lookup_state_cp_write1 &
                                (((cp_inv_count == 8'b00001001) & main_inval_addr) |
                                 (cp_inv_count == 8'b01111111)));

  // Determine when the operation has invalidated all the relevant entries in
  // the walk cache portion of the RAM.
  //  - count is 135 and it is an MVA operation
  //  - count is 143
  assign walk_inval_finished = (lookup_state_cp_write1 &
                               (((cp_inv_count == 8'b10000111) & walk_inval_addr) |
                                (cp_inv_count == 8'b10001111)));

  // Leaf instructions don't invalidate walk cache
  assign walk_inval_start = main_inval_finished &
                             ((lookup_cp15_type == `CA53_CP_TLB_INV_ALL) |
                              (lookup_cp15_type == `CA53_CP_TLBI_VAE1) |
                              (lookup_cp15_type == `CA53_CP_TLBI_ASIDE1) |
                              (lookup_cp15_type == `CA53_CP_TLBI_VAAE1) |
                              (lookup_cp15_type == `CA53_CP_TLBI_VAE2) |
                              (lookup_cp15_type == `CA53_CP_TLBI_ALLE2) |
                              (lookup_cp15_type == `CA53_CP_TLBI_VMALLS12E1) |
                              (lookup_cp15_type == `CA53_CP_TLB_INV_ALL_NSNH) |
                              (lookup_cp15_type == `CA53_CP_TLBI_ALLE1) |
                              (lookup_cp15_type == `CA53_CP_TLBI_VAE3) |
                              (lookup_cp15_type == `CA53_CP_TLBI_ALLE3));

  // Determine when the operation has invalidated all the relevant entries in
  // the IPA cache portion of the RAM.
  assign ipa_inval_finished = lookup_state_cp_write1 &
                               (((cp_inv_count == 8'b10011011) & (lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1)) |
                                (cp_inv_count == 8'b10011111));


  // The IPA cache is only invalidated from secure state or hyp mode, and then
  // only when non-secure non-hyp entries need to be invalidated.
  assign ipa_inval_start =  (walk_inval_finished &
                             ((lookup_cp15_type == `CA53_CP_TLB_INV_ALL) & lookup_el2) |
                             (lookup_cp15_type == `CA53_CP_TLB_INV_ALL_NSNH) |
                             ((lookup_cp15_type == `CA53_CP_TLBI_VMALLS12E1) & lookup_ns) |
                             ((lookup_cp15_type == `CA53_CP_TLBI_ALLE1) & lookup_ns));

  // Calculate when the invalidate operation has completed in all portions of the RAM.
  assign cp_inv_finished = ((lookup_state_cp_write_all & (cp_inv_count == 8'b10011111)) |
                            (lookup_state_cp_write1 & ((walk_inval_finished & ~ipa_inval_start) |
                                                       (main_inval_finished & ~walk_inval_start) |
                                                       ipa_inval_finished)));

  // Clear the master hitmap when the entire main TLB has been invalidated.
  assign master_hitmap_flush = cp_inv_finished & (lookup_cp15_type == `CA53_CP_TLBI_ALL_ON_RST);

  // Clear the IPA hitmap when the entire IPA cache has been invalidated.
  assign ipa_hitmap_flush = cp_inv_finished & ((lookup_cp15_type == `CA53_CP_TLBI_ALL_ON_RST ) |
                                               (lookup_cp15_type == `CA53_CP_TLB_INV_ALL_NSNH) |
                                               ((lookup_cp15_type == `CA53_CP_TLBI_ALLE1) & lookup_ns));

  assign ipa_hitmap_flush_o = ipa_hitmap_flush;

  // Register the ways that hit when looking up entries, to be used in the
  // following cycle to determine whether to write to the RAM.
  always @(posedge clk)
  if (lookup_state_en) begin
    cp_hit_way <= cp_lookup_hit_way_i;
  end

  // Support for ECC reporting
  generate if (CPU_CACHE_PROTECTION) begin : g_protection_lookup1

    reg [3:0] cp_ecc_way;

    always @(posedge clk)
    if (lookup_state_en) begin
      cp_ecc_way <= lookup_ecc_err_way_i;
    end

    assign tlb_pty_valid_cp_cmn = (lookup_state_cp_write0 | lookup_state_cp_write1) & (|cp_ecc_way);
    //Only Bits[2:0] are used as Bit[3] is selected in default condition by logic using this signal
    assign tlb_pty_way_cp_cmn = cp_ecc_way[2:0];

  end else begin : g_protection_stubs_lookup1

    assign tlb_pty_valid_cp_cmn = 1'b0;
    assign tlb_pty_way_cp_cmn   = {3{1'b0}};

  end endgenerate

  assign tlb_pty_valid_cp_o = tlb_pty_valid_cp_cmn;
  assign tlb_pty_way_cp_o   = tlb_pty_way_cp_cmn; 

  //-----------------------------------------------------------------------------
  // Comparator control
  //-----------------------------------------------------------------------------

  // Tell the comparators in ramctl what fields should be used in the
  // comparison for CP ops.
  assign lookup_compare_use_va_o = invalidating_ipa ? (lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1) :
                                     ((lookup_cp15_type == `CA53_CP_TLBI_VAE3) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VALE3) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VALE2) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VALE1) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VAALE1) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VAE2) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VAE1) |
                                      (lookup_cp15_type == `CA53_CP_TLBI_VAAE1));

  assign lookup_compare_use_asid_o = (~(invalidating_ipa | invalidating_walk) &
                                      ((lookup_cp15_type_early == `CA53_CP_TLBI_VAE1) |
                                       (lookup_cp15_type_early == `CA53_CP_TLBI_ASIDE1) |
                                       (lookup_cp15_type == `CA53_CP_TLBI_VALE1)));

  assign lookup_compare_use_global_o = (~(invalidating_ipa | invalidating_walk) &
                                        ((lookup_cp15_type_early == `CA53_CP_TLBI_VAE1) |
                                         (lookup_cp15_type_early == `CA53_CP_TLBI_VALE1)));

  // CA53_CP_TLBI_ALLE3/CA53_CP_TLBI_VAE3/CA53_CP_TLBI_VALE3 are not excluded from this logic as
  // these can not be executed in NS mode.
  assign lookup_compare_use_vmid_o = lookup_ns_early &
                                      ~((lookup_cp15_type_early == `CA53_CP_TLBI_VAE2)  |
                                        (lookup_cp15_type_early == `CA53_CP_TLBI_ALLE2)  |
                                        (lookup_cp15_type_early == `CA53_CP_TLB_INV_ALL_NSNH) |
                                        (lookup_cp15_type_early == `CA53_CP_TLBI_VALE2) |
                                        (lookup_cp15_type_early == `CA53_CP_TLBI_ALLE1));

  // Provide the data to compare the RAM contents against.
  assign lookup_compare_va_o   = lookup_va_early[48:12];
  assign lookup_compare_size_o = lookup_compare_size;
  assign lookup_compare_size_ipa_o = lookup_compare_size_ipa;

  // This signal is set (i.e. TLB invalidates NS entries) when
  //   - DCU request was NS
  //   - DCU request was secure but operation was HYP, MVA_HYP or NSNH
  // Otherwise this signal is clear (i.e. TLB invalidates secure entries)
  //
  assign lookup_compare_ns_o   = lookup_ns_early |
                                  (lookup_state_cp & ((lookup_cp15_type_early == `CA53_CP_TLBI_VAE2) |
                                                      (lookup_cp15_type_early == `CA53_CP_TLBI_ALLE2) |
                                                      (lookup_cp15_type_early == `CA53_CP_TLB_INV_ALL_NSNH)|
                                                      (lookup_cp15_type_early == `CA53_CP_TLBI_VALE2)));

  assign lookup_compare_hyp_o  = (lookup_state_lookup ? lookup_el2_early :
                                  ((lookup_cp15_type_early == `CA53_CP_TLBI_VAE2) |
                                   (lookup_cp15_type_early == `CA53_CP_TLBI_ALLE2) |
                                   (lookup_cp15_type_early == `CA53_CP_TLBI_VALE2)));

  // This signal is used to match EL3 exception level. It is required for A64-EL3
  // only and not required for secure A32-EL3 mode.
  assign lookup_compare_el3_o  = lookup_state_lookup ?
                                   (lookup_el3_early & lookup_aarch64_early) :
                                   ((lookup_cp15_type_early == `CA53_CP_TLBI_ALLE3) |
                                    (lookup_cp15_type_early == `CA53_CP_TLBI_VAE3) |
                                    (lookup_cp15_type_early == `CA53_CP_TLBI_VALE3));

  assign lookup_compare_asid_o = lookup_asid;
  assign lookup_compare_vmid_o = lookup_vmid;

  //-----------------------------------------------------------------------------
  // Victim way selection
  //-----------------------------------------------------------------------------

  // Increment the round robin counter every time a pagewalk is started.
  assign next_victim_round_robin = start_pagewalk_no_err ? (victim_round_robin+2'b01) : victim_round_robin;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    victim_round_robin <= 2'b00;
  end else if (lookup_state_en) begin
    victim_round_robin <= next_victim_round_robin;
  end

  // Based on the valid bits seen from the RAMs during a lookup read data phase,
  // pick the victim way for the current size. If one way is invalid, then
  // pick that starting from way zero, otherwise choose randomly based on round robin counter.
  assign victim_way = sel_victim_round_robin_i ? victim_round_robin : first_available_way_i;

  assign lookup_compare_size_onehot = {4{lookup_state_lookup}} & {lookup_compare_size[2:1] == 2'b11,
                                                                  lookup_compare_size[2:1] == 2'b10,
                                                                  lookup_compare_size[2:1] == 2'b01,
                                                                  lookup_compare_size[2:1] == 2'b00};

  // The page size of the new entry will not be known until the pagewalk
  // completes, and so we need to store a victim way for each possible page
  // size. These are updated when that particular size is accessed. If
  // a size is not accessed (because it is not present in the master hitmap)
  // then the victim way is initialised to the random value (from the round
  // robin counter)
  assign lookup_victim_way_size0 = lookup_compare_size_onehot[0] ? victim_way : lookup_victim_way_size0_early;
  assign lookup_victim_way_size1 = lookup_compare_size_onehot[1] ? victim_way : lookup_victim_way_size1_early;
  assign lookup_victim_way_size2 = lookup_compare_size_onehot[2] ? victim_way : lookup_victim_way_size2_early;
  assign lookup_victim_way_size3 = lookup_compare_size_onehot[3] ? victim_way : lookup_victim_way_size3_early;

  assign next_lookup_victim_way_size0_early = lookup_state_idle ? victim_round_robin : lookup_victim_way_size0;
  assign next_lookup_victim_way_size1_early = lookup_state_idle ? victim_round_robin : lookup_victim_way_size1;
  assign next_lookup_victim_way_size2_early = lookup_state_idle ? victim_round_robin : lookup_victim_way_size2;
  assign next_lookup_victim_way_size3_early = lookup_state_idle ? victim_round_robin : lookup_victim_way_size3;

  always @(posedge clk)
  if (lookup_state_en) begin
    lookup_victim_way_size0_early <= next_lookup_victim_way_size0_early;
    lookup_victim_way_size1_early <= next_lookup_victim_way_size1_early;
    lookup_victim_way_size2_early <= next_lookup_victim_way_size2_early;
    lookup_victim_way_size3_early <= next_lookup_victim_way_size3_early;
  end

  assign lookup_victim_way_size0_o = lookup_victim_way_size0;
  assign lookup_victim_way_size1_o = lookup_victim_way_size1;
  assign lookup_victim_way_size2_o = lookup_victim_way_size2;
  assign lookup_victim_way_size3_o = lookup_victim_way_size3;

  //-----------------------------------------------------------------------------
  // Hitmap logic
  //-----------------------------------------------------------------------------

  // Calculate the master hitmap. This indicates which page sizes have been
  // placed into the TLB since the last reset
  // The bits correspond to the size as follows:
  // [0] 4k  (VMSAv7)
  // [1] 4k  (LPAE)
  // [2] 64k (VMSAv7)
  // [3] 64k (LPAE)
  // [4] 1M  (VMSAv7)
  // [5] 2M  (LPAE)
  // [6] 16M (VMSAv7)
  // [7] 512M/1G  (LPAE)

  assign master_hitmap_en = (pagewalk_hitmap_update_iside_i |
                             pagewalk_hitmap_update_dside_i |
                             master_hitmap_flush);

  assign next_master_hitmap = master_hitmap_flush ? 8'h00 : (master_hitmap | (8'h01 << pagewalk_hitmap_size_i));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    master_hitmap <= 8'h00;
  end else if (master_hitmap_en) begin
    master_hitmap <= next_master_hitmap;
  end

  // Record if an entry with a smaller combined size than the stage1 size has
  // been placed in the main TLB since the last invalidate of all non-secure
  // main TLB entries. This is used to reduce the number of entries we need to
  // search when invalidating by MVA if we know the stage1 pages cannot have
  // been broken up into smaller sizes.
  assign next_reduced_size_hitmap = ((reduced_size_hitmap | pagewalk_size_reduced_i) &
                                     ~ipa_hitmap_flush);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    reduced_size_hitmap <= 1'b1;
  end else begin
    reduced_size_hitmap <= next_reduced_size_hitmap;
  end

  // Maintain the order of the most recently used page sizes. This is updated
  // whenever a lookup hits. Note that this just stores the size assuming the
  // format (VMSA/LPAE) does not change. It should be compared before use with
  // the master hitmap to check if the size actually exists in the current
  // format.
  //
  // The order is arranged as 3 entries of 2 bits each:
  // [1:0] is the highest priority size
  // [3:2] is the second highest priority size
  // [5:4] is the third highest priority size
  // [7:6] is the lowest priority, but is calculated from the others rather than stored.
  //
  // Order is kept in two bits. Third LS bit is added based on LPAE/VMSA once order has
  // been calculated

  // Calculate the lowest priority size. This is the size that isn't already present in the 3 stored entries.
  assign full_i_size_order[5:0] = i_size_order;
  assign full_i_size_order[6] = full_i_size_order[4] ^ full_i_size_order[2] ^ full_i_size_order[0];
  assign full_i_size_order[7] = full_i_size_order[5] ^ full_i_size_order[3] ^ full_i_size_order[1];

  assign full_d_size_order[5:0] = d_size_order;
  assign full_d_size_order[6] = full_d_size_order[4] ^ full_d_size_order[2] ^ full_d_size_order[0];
  assign full_d_size_order[7] = full_d_size_order[5] ^ full_d_size_order[3] ^ full_d_size_order[1];

  // The size that hit on the current lookup, or was written due to a pagewalk.
  assign i_hit_size = pagewalk_hitmap_update_iside_i ? pagewalk_hitmap_size_i[2:1] : lookup_compare_size[2:1];
  assign d_hit_size = pagewalk_hitmap_update_dside_i ? pagewalk_hitmap_size_i[2:1] : lookup_compare_size[2:1];

  // Work out which entries need to be shifted down the priority, to fit the
  // new entry as the highest priority. Only entries above the current position
  // of the new size need to shift.
  assign i_size_order_shift[0] = (i_hit_size != full_i_size_order[1:0]);
  assign i_size_order_shift[1] = (i_hit_size != full_i_size_order[3:2]) & i_size_order_shift[0];

  assign d_size_order_shift[0] = (d_hit_size != full_d_size_order[1:0]);
  assign d_size_order_shift[1] = (d_hit_size != full_d_size_order[3:2]) & d_size_order_shift[0];

  // Shift the entries as calculated above, and insert the new entry.
  assign next_i_size_order = {i_size_order_shift[1] ? full_i_size_order[3:2] : full_i_size_order[5:4],
                              i_size_order_shift[0] ? full_i_size_order[1:0] : full_i_size_order[3:2],
                              i_hit_size};

  assign next_d_size_order = {d_size_order_shift[1] ? full_d_size_order[3:2] : full_d_size_order[5:4],
                              d_size_order_shift[0] ? full_d_size_order[1:0] : full_d_size_order[3:2],
                              d_hit_size};

  // Update the order whenever a lookup hits or a pagewalk completes. These could both
  // happen at the same time for different sides.
  assign lookup_hitmap_update_iside = lookup_state_lookup & lookup_hit_i &  lookup_iside;
  assign lookup_hitmap_update_dside = lookup_state_lookup & lookup_hit_i & ~lookup_iside;

  assign i_size_order_en = lookup_hitmap_update_iside | pagewalk_hitmap_update_iside_i;
  assign d_size_order_en = lookup_hitmap_update_dside | pagewalk_hitmap_update_dside_i;


  // The size order is reset to give 4k highest priority, followed by the other
  // sizes in increasing order. This ensures that the list always contains
  // exactly one of each page size.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    i_size_order <= 6'b10_01_00;
  end else if (i_size_order_en) begin
    i_size_order <= next_i_size_order;
  end

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    d_size_order <= 6'b10_01_00;
  end else if (d_size_order_en) begin
    d_size_order <= next_d_size_order;
  end

  // Output the first size to try, for the ramctl block when a new lookup starts.
  assign lookup_ram_i_size_o = {i_size_order[1:0], lookup_lpae_early};
  assign lookup_ram_d_size_o = {d_size_order[1:0], lookup_lpae_early};


  // Pick the order of sizes for the current lookup side.
  assign lookup_size_order = lookup_iside ? full_i_size_order : full_d_size_order;

  // Calculate which entries in lookup_size_order are valid (i.e. present in
  // the master hitmap). The highest priority size is always treated as valid,
  // even if it is not in the master hitmap. This allows the address selection
  // to be fast on the first cycle, when it can't be calculated in advance.
  assign lookup_size_order_valid[3] = master_hitmap[{lookup_size_order[7:6], lookup_lpae}];
  assign lookup_size_order_valid[2] = master_hitmap[{lookup_size_order[5:4], lookup_lpae}];
  assign lookup_size_order_valid[1] = master_hitmap[{lookup_size_order[3:2], lookup_lpae}];
  assign lookup_size_order_valid[0] = 1'b1;


  // Indicate which entries in lookup_size_order are valid and haven't already
  // been accessed this lookup.
  assign lookup_size_valid = lookup_state_idle ? lookup_size_order_valid : {lookup_size_remaining, 1'b0};

  // Work out the sizes that are still to be looked up after the one being
  // accessed this cycle has been removed. This will use all sizes in order
  // of priority, until all the remaining sizes are not present in the master
  // hitmap. If a lower priority size is present in the master hitmap when a
  // higher priority size is not, then the higher priority size will be looked
  // up even though it doesn't need to be. However this situation should very
  // rarely occur because anything in the master hitmap is likely to be
  // accessed more than something that is not.
  assign next_lookup_size_remaining = { lookup_size_valid[3]   & |lookup_size_valid[2:0],
                                       |lookup_size_valid[3:2] & |lookup_size_valid[1:0],
                                       |lookup_size_valid[3:1] &  lookup_size_valid[0]};

  always @(posedge clk)
  if (lookup_state_en) begin
    lookup_size_remaining <= next_lookup_size_remaining;
  end

  // On the first cycle we always select the highest priority size, otherwise
  // the highest priority size that hasn't already been looked up.
  assign lookup_size_sel = {lookup_size_remaining[2:1], lookup_state_idle};

  assign next_lookup_compare_size = (lookup_state_cp ? cp_inv_count[2:0] :
                                     {(lookup_size_sel[0] ? lookup_size_order[1:0] :
                                       lookup_size_sel[1] ? lookup_size_order[3:2] :
                                       lookup_size_sel[2] ? lookup_size_order[5:4] :
                                                            lookup_size_order[7:6]), lookup_lpae});
  assign next_lookup_compare_size_ipa = cp_inv_count[3];

  // Register the size used for the RAM access, so that in the following cycle
  // the comparators know what size to compare against when the data is
  // returned from the RAMs.
  always @(posedge clk)
  if (lookup_state_en) begin
    lookup_compare_size     <= next_lookup_compare_size;
    lookup_compare_size_ipa <= next_lookup_compare_size_ipa;
  end

  // On the first cycle, the LPAE bit of the size is predicted based on the
  // last lookup, if this was wrong and it would make a difference to the
  // address bits selected (i.e. the size was not 4k or 64k where the address
  // bits are the same for VMSA and LPAE), then we do not remove that size
  // from the transaction hitmap as it will not hit and will need to be looked
  // up again.
  assign lpae_mispredict = (lookup_lpae != lookup_lpae_early) & lookup_size_order[1];

  assign next_lookup_size = (new_cp_op_possible | lookup_state_cp) ? next_cp_index[3:0] :
                            {1'b0, (lookup_size_sel[0] ? lookup_size_order[3:2] :
                                    lookup_size_sel[1] ? lookup_size_order[5:4] :
                                                         lookup_size_order[7:6]), lookup_lpae};

  // Select the correct portion of the address based on the size we will be
  // accessing in the next cycle.
  always @*
  case (next_lookup_size)
    4'b0_000,
    4'b0_001:  next_lookup_ram_addr = lookup_va[18:12]; // 4k
    4'b0_010,
    4'b0_011:  next_lookup_ram_addr = lookup_va[22:16]; // 64k
    4'b0_100:  next_lookup_ram_addr = lookup_va[26:20]; // 1M
    4'b0_101:  next_lookup_ram_addr = lookup_va[27:21]; // 2M
    4'b0_110:  next_lookup_ram_addr = lookup_va[30:24]; // 16M
    4'b0_111:  next_lookup_ram_addr = lookup_va[35:29]; // 512M
    4'b1_000, 4'b1_001, 4'b1_010, 4'b1_011,
    4'b1_100, 4'b1_101, 4'b1_110, 
    4'b1_111:  next_lookup_ram_addr = {lookup_va[35:30],~lookup_va[29]}; // 512M
    default:   next_lookup_ram_addr = {7{1'bx}};
  endcase

  // For CP operations that must read and then write all entries, the address
  // must be modified for the write cycles as next_cp_inv_count has already been
  // updated to the start of the next pair of addresses.
  assign next_cp_index = (lookup_state_cp_read1 ?
                          ((lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1) ?
                            {cp_inv_count[7:2], 1'b0, cp_inv_count[0]} :
                            {cp_inv_count[7:1], 1'b0}) :
                          lookup_state_cp_write0 ? cp_inv_count :
                          next_cp_inv_count);

  // For RAM addresses that are not implemented, wrap around to the start. Wrapping is implemented
  // only to make sure that no un-implemented addresses are accessed. Wrapping is not implemented
  // to give exact wrapped offset address.
  assign tlb_dbg_addr = { ( (dcu_cp_addr_tlb_i[7] & (dcu_cp_addr_tlb_i[6] | dcu_cp_addr_tlb_i[5])) ?
                             3'b000 : dcu_cp_addr_tlb_i[7:5]), (dcu_cp_addr_tlb_i[4:0])};

  // - This signal selects the CP OPs for which all locations are looked up
  //    - Non-MVA CP operations
  //    - MVA CP operations with reduced hit map, (i.e. targeted addresses
  //      can not be looked up and all RAM locations have to be looked up)
  // - MVA operations for EL2/EL3 are not included as these are
  //   single stage translations  and can always use targeted address lookups
  //    MVAH/VAE2,VALE2,VAE3,VALE3
  assign sel_next_cp_index = (new_cp_op_possible | lookup_state_cp) &
                              ((lookup_cp15_type == `CA53_CP_TLBI_ALL_ON_RST) |
                               (lookup_cp15_type == `CA53_CP_TLB_INV_ALL) |
                               (lookup_cp15_type == `CA53_CP_TLBI_ASIDE1) |
                               (lookup_cp15_type == `CA53_CP_TLBI_ALLE2) |
                               (lookup_cp15_type == `CA53_CP_TLB_INV_ALL_NSNH) |
                               (lookup_cp15_type == `CA53_CP_TLBI_VMALLS12E1) |
                               (lookup_cp15_type == `CA53_CP_TLBI_ALLE3) |
                               (lookup_cp15_type == `CA53_CP_TLBI_ALLE1) |
                               (((lookup_cp15_type == `CA53_CP_TLBI_VALE1) |
                                 (lookup_cp15_type == `CA53_CP_TLBI_VAALE1) |
                                 (lookup_cp15_type == `CA53_CP_TLBI_VAE1) |
                                 (lookup_cp15_type == `CA53_CP_TLBI_VAAE1)) &
                                (lookup_ns & reduced_size_hitmap &
                                 ~(lookup_state_cp & (main_inval_finished | invalidating_walk)))) |
                               (lookup_state_cp & (walk_inval_finished | invalidating_ipa) &
                                (lookup_cp15_type != `CA53_CP_TLBI_IPAS2LE1)));

  assign sel_tlb_dbg_addr = (lookup_state_idle & new_cp_op_possible & (dcu_cp_op_tlb_i == `CA53_CP_TLB_DBG));

  assign sel_next_lookup_ram_walk_addr = (lookup_state_cp & (main_inval_finished | invalidating_walk));

  assign sel_next_lookup_ram_ipa_addr  = (new_cp_op_possible | lookup_state_cp) &
                                          (lookup_cp15_type == `CA53_CP_TLBI_IPAS2LE1);

  // From 1000,0000 (128) to 1001,1111 (159)
  assign next_lookup_ram_walk_addr = {`CA53_RAM_WALK_PREFIX_ADDR, next_lookup_ram_addr[3:0]};
  assign next_lookup_ram_ipa_addr  = {`CA53_RAM_IPA_PREFIX_ADDR, next_lookup_ram_addr[3:0]};

  assign next_ram_addr_early = sel_next_cp_index ? next_cp_index : // CP OPs requiring all locations looked up
                               sel_tlb_dbg_addr ? tlb_dbg_addr  :  // Debug RAM read
                               sel_next_lookup_ram_walk_addr ? 
                                 next_lookup_ram_walk_addr : // CP OPs requiring targeted lookups in walk RAM
                               sel_next_lookup_ram_ipa_addr ? 
                                 next_lookup_ram_ipa_addr :  // CP OPs requiring targeted lookups in IPA RAM
                               {1'b0, next_lookup_ram_addr}; // CP OPs requiring targeted lookups in TLB RAM

  //----------------------------------------------------------------------------
  // Calculate the RAM enable terms
  //----------------------------------------------------------------------------

  // The RAM enable to use during lookups. All banks can be read
  // for a hit simultaneously.
  assign tlb_ram_en_lookups = `CA53_LOOKUP_LOOKUP(lookup_state) & |lookup_size_remaining;


  assign lookup_ram_req_o = (tlb_ram_en_lookups |
                             `CA53_LOOKUP_CP_DBG_RD(lookup_state) |
                             (`CA53_LOOKUP_CP_WR(lookup_state) & |cp_hit_way));

  assign lookup_ram_way_o = ({4{tlb_ram_en_lookups | lookup_state_cp_read0 | lookup_state_cp_read1 | lookup_state_cp_write_all}}) |
                            ({4{lookup_state_cp_write0 | lookup_state_cp_write1}} & cp_hit_way) |
                            ({4{lookup_state_dbg_rd_addr}} & dbgdr_ram_en);

  // Indicate when we might be making a request in the following cycle.
  assign lookup_ram_next_req_o = (new_lookup_starting |
                                  new_cp_op_starting |
                                  ~lookup_state_idle);

  assign lookup_ram_wr_o = (lookup_state_cp_write0 |
                            lookup_state_cp_write1 |
                            lookup_state_cp_write_all);

  assign lookup_ram_next_addr_o = next_ram_addr_early;

  //------------------------------------------------------------------------------
  // ECC registers
  //------------------------------------------------------------------------------

  generate if (CPU_CACHE_PROTECTION) begin : g_protection_lookup0

    reg        lookup_ecc_err_early;
    reg [3:0]  lookup_ecc_err_way_early;
    wire       next_lookup_ecc_err_early;
    wire [3:0] next_lookup_ecc_err_way_early;

    assign next_lookup_ecc_err_early = (lookup_ecc_err_i & lookup_state_lookup) |
                                       (lookup_ecc_err_early & ~lookup_state_idle);

    assign next_lookup_ecc_err_way_early = lookup_state_lookup ? lookup_ecc_err_way_i :
                                                                 lookup_ecc_err_way_early;

    always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      lookup_ecc_err_early <= 1'b0;
    end else begin
      lookup_ecc_err_early <= next_lookup_ecc_err_early;
    end

    always @(posedge clk)
    if (lookup_state_en) begin
      lookup_ecc_err_way_early <= next_lookup_ecc_err_way_early;
    end

    assign lookup_ecc_err_early_common     = lookup_ecc_err_early;
    assign lookup_ecc_err_way_early_common = lookup_ecc_err_way_early;

  end else begin : g_protection_stubs_lookup0

    assign lookup_ecc_err_early_common     = 1'b0;
    assign lookup_ecc_err_way_early_common = 4'h0;

  end endgenerate

  assign lookup_ecc_err_early_o     = lookup_ecc_err_early_common;
  assign lookup_ecc_err_way_early_o = lookup_ecc_err_way_early_common;

  //------------------------------------------------------------------------------
  // React to the hit information from the RAMs
  //------------------------------------------------------------------------------

  // Indicate to the DPU/IFU if the uTLBs might be updated this cycle, depending
  // on the lookup result. This allows a reduction of fanout on the real hit signal.
  assign lookup_i_utlb_might_enable_o = lookup_state_lookup &  lookup_iside_early & ~abandon_existing_lookup_iside;
  assign lookup_d_utlb_might_enable_o = lookup_state_lookup & ~lookup_iside_early & ~abandon_existing_lookup_dside;

  // Generate a signal that indicates when the uTLB might be enabled in the following cycle.
  assign lookup_utlb_next_might_enable = (new_lookup_starting |
                                          (tlb_ram_en_lookups & ~lookup_hit_i)) & ~abandon_lookup;
  assign lookup_i_utlb_next_might_enable_o = lookup_utlb_next_might_enable &  lookup_iside;
  assign lookup_d_utlb_next_might_enable_o = lookup_utlb_next_might_enable & ~lookup_iside;


  // Start a pagewalk if we have looked up all sizes and missed all of them.
  assign start_pagewalk_ecc_err = (pagewalk_state_idle_i & (lookup_state_wait &
                                                            lookup_ecc_err_early_common) &
                                   ~abandon_existing_lookup);

  assign start_pagewalk_no_err = (pagewalk_state_idle_i & (lookup_state_wait &
                                                           ~lookup_ecc_err_early_common) &
                                 ~abandon_existing_lookup);

  assign start_pagewalk = (start_pagewalk_ecc_err | start_pagewalk_no_err);
  assign start_pagewalk_o = start_pagewalk;

  //------------------------------------------------------------------------------
  // DBGDR outputs back to the cp_regs block
  //------------------------------------------------------------------------------

  // VA[47:12] is sent by DCU on dcu_cp_addr_tlb_i[35:0]. This is saved as lookup_va/lookup_va_early[47:12].
  // For debug RAM operation DCU sends TLB WAY information on dcu_cp_addr_tlb_i[31:30] which corresponds
  // to lookup_va,lookup_va_early[43:42]
  assign dbgdr_ram_way = lookup_va_early[43:42];

  assign dbgdr_ram_en = {(dbgdr_ram_way==2'b11), (dbgdr_ram_way==2'b10),
                         (dbgdr_ram_way==2'b01), (dbgdr_ram_way==2'b00)};

  assign dbgdr_ram_way_o = dbgdr_ram_way;
  assign dbgdr_reg_wr_en_o = lookup_state_dbg_rd_data;

  assign cp_ack_dbgdr = lookup_state_dbg_rd_data;

  //------------------------------------------------------------------------------
  // Support for granule calculation 
  //------------------------------------------------------------------------------

  assign next_lookup_tcr_a64_muxed_t0sz = lookup_el3 ? tcr_a64_el3_t0sz_i :
                                          lookup_el2 ? tcr_a64_el2_t0sz_i : tcr_a64_el1_t0sz_i;

  assign stage2_lookup_a64_g64 = lookup_aarch64_at_el[2] & vtcr_tg0_i;

  // This logic is same as for stage2_translation_required signal during
  // pagewalk, except the exclusion of V2P related logic. This is because lookup
  // stage2 required is used only at start of pagewalk, to find the walk cache
  // address, while V2P related logic in stage2_translation_required is to get
  // IPA address towards the end of translation.
  assign lookup_stage2_required = (lookup_ns & ~lookup_el2) &
                                  (dpu_ipa_to_pa_en_i | dpu_default_cacheable_i);

  assign next_lookup_stage2_a64_g64 = ((~lookup_stage2_required) |
                                       (lookup_stage2_required & stage2_lookup_a64_g64));

  assign next_lookup_el3_el2     = (lookup_el3 | lookup_el2);
  assign next_lookup_el3_el2_g64 = (lookup_el3 & tcr_a64_el3_tg0_i) | (lookup_el2 & tcr_a64_el2_tg0_i);

  assign next_lookup_ttbr0_sign_match = ~lookup_va_sign_err & ~lookup_va[48] ;

  //------------------------------------------------------------------------------
  // Output assignments
  //------------------------------------------------------------------------------

  // Tell the pagewalk logic when it must not gate out its clock, as there could
  // be a new pagewalk starting in the next cycle. Also include some cp maint ops
  // that might cause the IPA hitmap to be flushed.
  assign lookup_active_o = (new_lookup_starting |
                            lookup_state_lookup |
                            lookup_state_wait   |
                            lookup_state_cp_write_all);

  // Ready does not include any new dside request for timing, but it is not
  // required anyway because if the dside is making a request then it cannot
  // be writing a register at the same time.
  assign tlb_cp_reg_write_ready_o = (~lookup_state_lookup &
                                     ~lookup_state_wait &
                                     ~iside_request &
                                     ~pagewalk_busy_iside_i &
                                     ~pagewalk_busy_dside_i);

  // The TLB is ready to enter WFx state when both state machines are idle.
  // This does not factor in new requests, because the units making those new
  // requests should have their own WFx ready signals low.
  assign tlb_wfx_ready_o = lookup_state_idle & pagewalk_state_idle_i;

  assign lookup_iside_o                 = lookup_iside;
  assign lookup_va_o                    = lookup_va;
  assign lookup_va_sign_err_o           = lookup_va_sign_err;
  assign lookup_va_mmuoff_sign_err_o    = lookup_va_mmuoff_sign_err;
  assign lookup_ns_o                    = lookup_ns;
  assign lookup_mmuon_o                 = lookup_mmuon;
  assign lookup_el2_o                   = lookup_el2;
  assign lookup_aarch64_o               = lookup_aarch64;
  assign lookup_aarch64_at_el_o         = lookup_aarch64_at_el;
  assign lookup_exception_level_o       = (lookup_el3 ? 2'b11 :
                                           lookup_el2 ? 2'b10 :
                                           lookup_el1 ? 2'b01 : 2'b00);
  assign lookup_exception_level_early_o = {lookup_el3_early, lookup_el2_early}; // Only EL3/EL2 are required
  assign cp_op_waiting_o                = cp_op_waiting;
  assign cp_inv_finished_o              = cp_inv_finished;
  assign tlb_cp_ack_o                   = cp_inv_finished | cp_ack_dbgdr;

  // Support for granule calculation 
  assign lookup_va_early_o              = lookup_va_early[47:20];
  assign lookup_ns_early_o              = lookup_ns_early;
  assign lookup_aarch64_early_o         = lookup_aarch64_early;
  assign lookup_aarch64_at_el3_early_o  = lookup_aarch64_at_el_early[3];

  assign lookup_tcr_a64_muxed_t0sz_o    = lookup_tcr_a64_muxed_t0sz;
  assign lookup_stage2_a64_g64_o        = lookup_stage2_a64_g64;
  assign lookup_el3_el2_o               = lookup_el3_el2;

  assign lookup_el3_el2_g64_o           = lookup_el3_el2_g64;
  assign lookup_ttbr0_sign_match_o      = lookup_ttbr0_sign_match;
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  reg ovl_lookup_ns_reg;
  reg ovl_lookup_el2_reg;
  reg ovl_lookup_lpae_reg;
  reg ovl_lookup_mmuon_reg;
  reg [2:0] ovl_next_lookup_size_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_lookup_ns_reg <= 1'b0;
    ovl_lookup_el2_reg <= 1'b0;
    ovl_lookup_lpae_reg <= 1'b0;
    ovl_lookup_mmuon_reg <= 1'b0;
    ovl_next_lookup_size_reg <= 3'b000;
  end else begin
    ovl_lookup_ns_reg <= lookup_ns;
    ovl_lookup_el2_reg <= lookup_el2;
    ovl_lookup_lpae_reg <= lookup_lpae;
    ovl_lookup_mmuon_reg <= lookup_mmuon;
    ovl_next_lookup_size_reg <= next_lookup_size;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Maintenance ops should not start pagewalks")
  u_ovl_cp_no_pagewalks (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (lookup_state_cp),
                         .consequent_expr (~start_pagewalk));


  assert_always #(`OVL_ERROR,`OVL_ASSERT,"The TLB Lookup state machine must be in a valid state")
  u_ovl_valid_lookup_state (.clk            (clk),
                            .reset_n        (reset_n),
                            .test_expr      ((lookup_state == `CA53_LOOKUP_ST_IDLE) |
                                             (lookup_state == `CA53_LOOKUP_ST_LOOKUP) |
                                             (lookup_state == `CA53_LOOKUP_ST_WAIT) |
                                             (lookup_state == `CA53_LOOKUP_ST_CP_READ0) |
                                             (lookup_state == `CA53_LOOKUP_ST_CP_READ1) |
                                             (lookup_state == `CA53_LOOKUP_ST_CP_WRITE0) |
                                             (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1) |
                                             (lookup_state == `CA53_LOOKUP_ST_CP_WRITE_ALL) |
                                             (lookup_state == `CA53_LOOKUP_ST_DBG_RD_ADDR) |
                                             (lookup_state == `CA53_LOOKUP_ST_DBG_RD_DATA)));

  wire ovl_lookup_in_progress = lookup_state_lookup | lookup_state_wait;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_ns must remain constant while it is being used")
  u_ovl_lookup_ns_constant (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_lookup_in_progress & ~abandon_lookup),
                            .consequent_expr (lookup_ns == ovl_lookup_ns_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_el2 must remain constant while it is being used")
  u_ovl_lookup_el2_constant (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr (ovl_lookup_in_progress & ~abandon_lookup),
                             .consequent_expr (lookup_el2 == ovl_lookup_el2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_lpae must remain constant while it is being used")
  u_ovl_lookup_lpae_constant (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_lookup_in_progress & ~abandon_lookup),
                              .consequent_expr (lookup_lpae == ovl_lookup_lpae_reg));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_mmuon must remain constant while it is being used")
  u_ovl_lookup_mmuon_constant (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (ovl_lookup_in_progress & ~abandon_lookup),
                               .consequent_expr (lookup_mmuon == ovl_lookup_mmuon_reg));


  assert_width #(`OVL_FATAL, 1, 4, `OVL_ASSERT, "Must not remain in the lookup state for more than 4 cycles")
  u_ovl_lookup_state_length (.clk       (clk),
                             .reset_n   (reset_n),
                             .test_expr (lookup_state == `CA53_LOOKUP_ST_LOOKUP));



  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "lookup_size matches next_lookup_size from the last cycle")
  u_ovl_lookup_size (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (lookup_state_lookup & |lookup_size_remaining),
                     .consequent_expr (next_lookup_compare_size == ovl_next_lookup_size_reg));

  reg [7:0] ovl_sizes_accessed;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_sizes_accessed <= 8'h00;
  end else begin
    ovl_sizes_accessed <= lookup_state_idle ? 8'h00 : (ovl_sizes_accessed | (1'b1 << lookup_compare_size));
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A lookup must not access the same size more than once")
  u_ovl_lookup_same_size (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (lookup_state_lookup),
                          .consequent_expr (~|(ovl_sizes_accessed & (1'b1 << lookup_compare_size))));


  wire [3:0] ovl_i_size_order_set = ((1'b1 << full_i_size_order[7:6]) |
                                     (1'b1 << full_i_size_order[5:4]) |
                                     (1'b1 << full_i_size_order[3:2]) |
                                     (1'b1 << full_i_size_order[1:0]));

  wire [3:0] ovl_d_size_order_set = ((1'b1 << full_d_size_order[7:6]) |
                                     (1'b1 << full_d_size_order[5:4]) |
                                     (1'b1 << full_d_size_order[3:2]) |
                                     (1'b1 << full_d_size_order[1:0]));

  assert_always #(`OVL_FATAL,`OVL_ASSERT, "full_i_size_order contains exactly one entry for each size")
  u_ovl_i_size_unique (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr (ovl_i_size_order_set == 4'b1111));

  assert_always #(`OVL_FATAL,`OVL_ASSERT, "full_d_size_order contains exactly one entry for each size")
  u_ovl_d_size_unique (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr (ovl_d_size_order_set == 4'b1111));

  reg [7:0]  ovl_cp_ram_addr_0;
  reg [7:0]  ovl_cp_ram_addr_1;
  reg [7:0]  ovl_cp_ram_addr_2;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_cp_ram_addr_0 <= 8'h00;
    ovl_cp_ram_addr_1 <= 8'h00;
    ovl_cp_ram_addr_2 <= 8'h00;
  end else begin
    ovl_cp_ram_addr_0 <= next_ram_addr_early;
    ovl_cp_ram_addr_1 <= ovl_cp_ram_addr_0;
    ovl_cp_ram_addr_2 <= ovl_cp_ram_addr_1;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "A CP write must be to the same address as the earlier lookup")
  u_ovl_cp_wr_same_addr (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (lookup_ram_req_o &
                                           ((lookup_state == `CA53_LOOKUP_ST_CP_WRITE0) |
                                            (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1))),
                         .consequent_expr (ovl_cp_ram_addr_0 == ovl_cp_ram_addr_2));


  // X checks on signals used in if statements

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pagewalk_state_idle_i should never be X")
  u_ovl_x_pagewalk_state_idle_i (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (pagewalk_state_idle_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "cp_inv_finished should never be X in CP_WRITE1 state")
  u_ovl_x_cp_inv_finished (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier ((lookup_state == `CA53_LOOKUP_ST_CP_WRITE1) |
                                       (lookup_state == `CA53_LOOKUP_ST_CP_WRITE_ALL)),
                           .test_expr (cp_inv_finished));

  assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "lookup_cp15_type should never be X in CP_WRITE1 state")
  u_ovl_x_lookup_cp15_type (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1),
                            .test_expr (lookup_cp15_type));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_ns should never be X in CP_WRITE1 state")
  u_ovl_x_lookup_ns (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1),
                     .test_expr (lookup_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dcu_cp_ns_i should never be X")
  u_ovl_x_dcu_cp_ns_i (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (new_cp_op_starting | (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1)),
                       .test_expr (dcu_cp_ns_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "walk_inval_finished should never be X in CP_WRITE1 state")
  u_ovl_x_walk_inval_finished (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (lookup_state == `CA53_LOOKUP_ST_CP_WRITE1),
                               .test_expr (walk_inval_finished));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_ram_pri_i should never be X in IDLE state")
  u_ovl_x_lookup_ram_pri_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (lookup_state == `CA53_LOOKUP_ST_IDLE),
                            .test_expr (lookup_ram_pri_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_hit should never be X in LOOKUP state")
  u_ovl_x_lookup_hit (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (lookup_state == `CA53_LOOKUP_ST_LOOKUP),
                      .test_expr (lookup_hit_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "new_lookup_starting should never be X")
  u_ovl_x_new_lookup_starting (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (new_lookup_starting));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_required should never be X")
  u_ovl_x_lookup_required (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (new_lookup_starting),
                           .test_expr (lookup_required));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "lookup_v2p_ipa should never be X")
  u_ovl_x_lookup_v2p_ipa (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (lookup_v2p_ipa));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "new_cp_op_starting should never be X")
  u_ovl_x_new_cp_op_starting (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (new_cp_op_starting));

  assert_never_unknown #(`OVL_FATAL, `CA53_DCU_CP_OP_W, `OVL_ASSERT, "dcu_cp_op_tlb_i should never be X")
  u_ovl_x_dcu_cp_op_tlb_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (new_cp_op_starting),
                           .test_expr (dcu_cp_op_tlb_i));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "lookup_size_remaining should never be X")
  u_ovl_x_lookup_size_remaining (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (~lookup_state_idle),
                                 .test_expr (lookup_size_remaining));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "abandon_lookup should never be X")
  u_ovl_x_abandon_lookup (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (new_lookup_starting | ovl_lookup_in_progress),
                          .test_expr (abandon_lookup));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_inv_count_en")
  u_ovl_x_cp_inv_count_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_inv_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: d_size_order_en")
  u_ovl_x_d_size_order_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (d_size_order_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: i_size_order_en")
  u_ovl_x_i_size_order_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (i_size_order_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lookup_en")
  u_ovl_x_lookup_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (lookup_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lookup_state_en")
  u_ovl_x_lookup_state_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (lookup_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: master_hitmap_en")
  u_ovl_x_master_hitmap_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (master_hitmap_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: mbist_en_i")
  u_ovl_x_mbist_en_i (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (lookup_state == `CA53_LOOKUP_ST_CP_WRITE_ALL),
                      .test_expr (mbist_en_i));

`endif


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53tlb_defs.v"
`undef CA53_UNDEFINE
/*END*/
