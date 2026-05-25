//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
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

//
// Overview
// ========
//

// ETM Trace Packet Generation
// This block does the following operations:
// 1) Trace packets generation.
// 2) Pack and Rotate Pre Calculation.
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "ca53_dpu_etm_defs.v"
`include "cortexa53params.v"

module  ca53etm_trace_gen (



//
// Interface Signals
// =================
//

// Global inputs
  input wire           clk_gated,                                       // CPU clock
  input wire           po_reset_n,                                      // Power On reset

// Inputs
  input wire           etm_os_lock_trace_i,                             // OS Lock status
  input wire           gov_wfx_drain_req_i,                             // ETM WFI/WFE request
  input wire           viewinst_en_t2_i,                                // View inst
  input wire           trace_active_1st_wpt_t4_i,                       // 1st wpt after trace enabled
  input wire           sync_req_t2_i,                                   // Synchronization request from ATB
  input wire  [63:0]   gov_tsvalueb_i,                                  // Timestamp Value
  input wire           ts_event_t2_i,                                   // Timestamp Event Enable from resources

  input wire           dpu_wpt_valid_i,                                 // Valid Waypoint
  input wire  [63:1]   dpu_wpt_addr_i,                                  // Waypoint PC Value
  input wire  [63:1]   dpu_wpt_target_addr_opa_i,                       // Waypoint Target PC value
  input wire  [27:1]   dpu_wpt_target_addr_opb_i,                       // Waypoint Target PC value
  input wire  [31:0]   tlb_context_id_i,                                // Waypoint Context ID value.
  input wire  [7:0]    tlb_vmid_i,                                      // Waypoint Context ID value.
  input  wire [1:0]    tlb_d_tcr_el1_tbi_i,
  input  wire          tlb_d_tcr_el2_tbi0_i,
  input  wire          tlb_d_tcr_el3_tbi0_i,

  input wire  [2:0]    dpu_wpt_type_i,                                  // Waypoint type direct, indirect etc.
  input wire           dpu_wpt_link_i,                                  // Waypoint is a branch and updates link register
  input wire           dpu_wpt_taken_i,                                 // Waypoint passed condition code
  input wire  [1:0]    dpu_wpt_target_isa_i,                            // Waypoint target ISA bit
  input wire           dpu_wpt_t32_nt16_i,                              // Size of last executed address in thumb state
  input wire  [3:0]    dpu_wpt_exception_type_i,                        // Waypoint Exception type
  input wire           dpu_wpt_non_secure_i,                            // Waypoint Non Secure state
  input wire  [3:0]    dpu_wpt_exlevel_i,                               // Waypoint excep level
  input wire           dpu_wpt_prohibited_i,                            // Prohibited Region.
  input wire           dpu_wpt_advance_i,                               // Waypoint advance
  input wire           dpu_wpt_range_i,                                 // Low if reset/debug/prohibited since last waypoint

  input wire           return_stack_en_reg_i,                           // Return Stack Enable bit 29 of Control Register
  input wire           timestamp_en_reg_i,                              // TimeStamp Enable bit 28 of Control Register
  input wire           cycle_counting_reg_i,                            // Cycle Accurate bit 12 of Control Register
  input wire  [11:0]   cc_threshold_reg_i,                              // Cycle Count Threshold
  input wire           context_id_reg_i,                                // Context ID Enable
  input wire           vmid_reg_i,                                      // VM ID bit 30 of Control Register
  input wire           branch_broadcast_reg_i,                          // Branch Broadcast bit 8 of Control Register
  input wire           bb_en_t2_i,                                      // Branch Broadcast enable
  input wire  [4:0]    sync_period_reg_i,                               // Synchronization Period Register
  input wire           auxctlr_frc_ovflow_reg_i,                        // Forced Overflow enable
  input wire           viewinst_idle_req_t2_i,                          // Idle request from ViewInst
  input wire           trace_req_t0_i,                                  // Programming control for trace
  input wire           core_at_main_run_t2_i,                           // Main idle state pipe active control
  input wire           wfx_resource_t3_i,                               // Inactive due to WFX
  input wire           fifo_overflow_i,                                 // FIFO in overflow condition
  input wire           fifo_empty_i,                                    // FIFO is empty
  input wire           fifo_8bytes_t6_i,                                // 8 bytes of trace have left the main trace FIFO
  input wire           fifo_level28_t7_i,                               // FIFO level. FIFO has more than 28 bytes.
  input wire           fifo_flush_req_i,                                // FIFO flush request

  input wire  [3:0]    etm_extout_i,                                    // Event selected
  input wire  [3:0]    event_enable_reg_i,                              // Event trace enable
  input wire           event_atbtrig_en_reg_i ,                         // ATB Event trace enable
  input wire           lp_override_reg_i,                               // low power state override register
  input wire           auxctlr_frc_sync_delay_reg_i,                    // Aux Control register - force synchronisation delay
  input wire           auxctlr_frc_ts_nodelay_reg_i,                    // Aux Control register - fifo can delay timestamp insert
  input wire           viewinst_trcerr_reg_i ,                          // System Error Trace
  input wire           viewinst_trcreset_reg_i ,                        // Reset Exception trace

// Outputs
  output wire           wpt_valid_t1_o,                                 // Valid waypoint in current cycle
  output wire           wpt_valid_t2_o,                                 // Valid waypoint in previous cycle
  output wire           wpt_adv_t1_o,                                   // Current waypoint pc >= previous waypoint target address
  output wire           wpt_adv_t2_o,                                   // Current waypoint pc >= previous waypoint target address
  output wire           wpt_range_t1_o,                                 // Suppress address comparators for first waypoint after prohibited or debug

  output wire  [2:0]    wpt_type_t1_o,                                  // Current waypoint type
  output wire  [63:1]   wpt_addr_t1_o,                                  // Current waypoint pc
  output wire  [63:1]   wpt_target_pc_t2_o,                             // Previous waypoint target pc
  output wire  [31:0]   wpt_context_id_t2_o,                            // Previous context id
  output wire  [7:0]    wpt_vmid_t2_o,                                  // Previous vmid
  output wire           wpt_aarch64_t2_o,                               // Previous 64bit state
  output wire           wpt_non_secure_t2_o,                            // Previous security state
  output wire  [3:0]    wpt_exlevel_t2_o,                               // Previous exception level
  output wire           wpt_prohibited_t2_o,                            // Previous prohibited state
  output wire           wpt_dbg_entry_t2_o,                             // Waypoint is debug entry
  output wire           wpt_dbg_exit_t2_o,                              // Waypoint is debug exit (not traced)

  output wire          async_req_t4_o,                                  // Async request to FIFO
  output wire          ovfl_req_t2_o,                                   // Overflow request to FIFO
  output wire  [3:0]   traced_event_t3_o,                               // The events occur during fifo overflow
  output wire          event_trigger_req_t3_o,                          // Trigger request to FIFO
  output wire          ts_output_en_pend_t3_o,                          // Timestamp output pending request status to FIFO for idle state entry.
  output wire          gov_wfx_drain_req_t2_o,                          // ETM WFI/WFE request
  output wire          trcgen_idle_ack_o,                               // ETM WFI/WFE request
  output wire          low_power_override_flush_o,                      // low power mode override fifo flush request
  output wire          trace_overflow_o,                                // Overflow state, must not become idle

  output wire  [4:0]   num_bytes_t5_o,                                  // Number of valid bytes to fifo input
  output wire  [203:0] pack_fifo_in_t5_o,                               // Trace data bytes to fifo input with static 0 removed
  output wire  [2:0]   num_first8_t5_o                                  // Number of valid bytes in the first 8 bytes.

 );

// These define values must not be changed without changing decode logic
localparam CA53_ETM_GEN_ST_IDLE           =2'b00;
localparam CA53_ETM_GEN_ST_TRACING        =2'b01;
localparam CA53_ETM_GEN_ST_OVERFLOW       =2'b10;
localparam CA53_ETM_GEN_ST_OFLOWIDLE      =2'b11;

localparam CA53_ETM_GENIDLE_ST_IDLE       =2'b00;
localparam CA53_ETM_GENIDLE_ST_CNT        =2'b01;
localparam CA53_ETM_GENIDLE_ST_OVERFLOW   =2'b10;
localparam CA53_ETM_GENIDLE_ST_ACK        =2'b11;

localparam ATOM_PKG_ST_IDLE             =3'b000;
localparam ATOM_PKG_ST_FMT1             =3'b001;
localparam ATOM_PKG_ST_FMT2             =3'b010;
localparam ATOM_PKG_ST_FMT3             =3'b011;
localparam ATOM_PKG_ST_FMT4             =3'b100;
localparam ATOM_PKG_ST_FMT5             =3'b101;
localparam ATOM_PKG_ST_FMT6             =3'b110;
localparam ATOM_PKG_ST_UNUSED           =3'b111;




  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           active_wpt_or_event_t3;
  wire [  7:  0] addr_or_cidheader_t3;
  wire           addr_pkt_en_t3;
  wire           address_change_b1_t3;
  wire           address_change_b23_t3;
  wire           address_change_b4567_t3;
  wire [ 63:  1] address_hist_0_t3;
  reg  [ 63:  1] address_hist_0_t4;
  wire [ 63:  1] address_hist_1_t3;
  reg  [ 63:  1] address_hist_1_t4;
  wire [ 63:  1] address_hist_2_t3;
  reg  [ 63:  1] address_hist_2_t4;
  wire           address_hist_reset_t3;
  wire           address_hist_update_t3;
  wire           address_hist_val_0_t3;
  reg            address_hist_val_0_t4;
  wire           address_hist_val_1_t3;
  reg            address_hist_val_1_t4;
  wire           address_hist_val_2_t3;
  reg            address_hist_val_2_t4;
  wire           address_match_0_t3;
  wire           address_match_1_t3;
  wire           address_match_2_t3;
  wire           address_exact_match_t3;
  wire [  7:  0] address_match_pkt_header_t3;
  reg  [  7:  0] address_pkt_header_t3;
  reg            address_pkt_header_h_t4;
  reg  [  4:  0] address_pkt_header_l_t4;
  wire           a32_state_0_t4;
  reg            a32_state_0_t5;
  wire           a32_state_1_t4;
  reg            a32_state_1_t5;
  wire           a32_state_2_t4;
  reg            a32_state_2_t5;
  wire           a32_state_t4;
  reg            a32_state_t5;
  wire           a32_state_new_t4;
  wire           a64_state_0_t4;
  reg            a64_state_0_t5;
  wire           a64_state_1_t4;
  reg            a64_state_1_t5;
  wire           a64_state_2_t4;
  reg            a64_state_2_t5;
  wire           a64_state_t4;
  reg            a64_state_t5;
  wire           arm_nthumb_state_t3;
  wire           async_pend_t3;
  reg            async_pend_t4;
  wire           periodic_async_pend_t3;
  reg            periodic_async_pend_t4;
  wire           async_req_t3;
  reg            async_req_t4;
  wire           async_trace_enable_t2;
  wire [  2:  0] atom_bit_count_t3;
  reg  [  2:  0] atom_bit_count_t4;
  wire [  4:  0] atom_bits_t3;
  reg  [  4:  0] atom_bits_t4;
  wire           atom_combine_t3;
  wire           atom_no_combine_t3;
  wire           atom_completion_t3;
  wire [  4:  0] atom_count_t3;
  wire [  4:  0] atom_count_t4_minus_one;
  reg  [  4:  0] atom_count_t4;
  wire           atom_forceout_t4;
  reg  [  2:  0] atom_pkg_st_t2;
  reg  [  2:  0] atom_pkg_st_t3;
  wire           atom_pkg_st_update_t3;
  wire           atom_pkt_format4_t3;
  wire           atom_pkt_format5_t3;
  wire           atom_pkt_format6_t3;
  wire           atom_pkt_gen_t4;
  reg  [  7:  0] atom_pkt_t3;
  reg            bb_en_t3;
  reg            bb_en_t4;
  wire           bb_entry_t3;
  wire           br_addr_byte0_en_t3;
  wire [  7:  0] br_addr_byte0_t3;
  wire           br_addr_byte1_en_t3;
  wire [  7:  0] br_addr_byte1_t3;
  wire           br_addr_byte2_en_t3;
  wire [  7:  0] br_addr_byte2_t3;
  wire           br_addr_byte3_en_t3;
  wire [  7:  0] br_addr_byte3_t3;
  wire           br_addr_byte4567_en_t3;
  wire [  7:  0] br_addr_byte4_t3;
  wire [  7:  0] br_addr_byte5_t3;
  wire [  7:  0] br_addr_byte6_t3;
  wire [  7:  0] br_addr_byte7_t3;
  wire           byte_0_valid_t3;
  reg            byte_0_valid_t4;
  wire           byte_1_valid_t3;
  reg            byte_1_valid_t4;
  wire           byte_2_valid_t3;
  reg            byte_2_valid_t4;
  wire           byte_3_valid_t3;
  reg            byte_3_valid_t4;
  wire           byte_4_valid_t3;
  reg            byte_4_valid_t4;
  wire           byte_5_valid_t3;
  reg            byte_5_valid_t4;
  wire           byte_6_valid_t3;
  reg            byte_6_valid_t4;
  wire           byte_7_valid_t3;
  reg            byte_7_valid_t4;
  wire           byte_8_valid_t3;
  reg            byte_8_valid_t4;
  wire           byte_9_valid_t3;
  reg            byte_9_valid_t4;
  wire           byte_a_valid_t3;
  reg            byte_a_valid_t4;
  wire           byte_b_valid_t3;
  reg            byte_b_valid_t4;
  wire           byte_c_valid_t3;
  reg            byte_c_valid_t4;
  wire           byte_d_valid_t3;
  reg            byte_d_valid_t4;
  wire           byte_e_valid_t3;
  reg            byte_e_valid_t4;
  wire           byte_f_valid_t3;
  reg            byte_f_valid_t4;
  wire [  1:  0] bytes_789_t3;
  reg  [  1:  0] bytes_789_t4;
  wire           cc_pkt_b0_en_t3;
  wire [  7:  0] cc_pkt_b0_t3;
  wire           cc_pkt_b1_en_t3;
  wire [  7:  0] cc_pkt_b1_t3;
  wire           cc_pkt_b2_en_t3;
  wire [  4:  0] cc_pkt_b2_t3;
  wire [ 11:  0] cc_pkt_counter_t3;
  wire           cc_pkt_format1_b2_t3;
  wire           cc_pkt_format2_t3;
  wire           cc_pkt_format3_t3;
  wire [  7:  0] cid_byte1_t3;
  reg  [  7:  0] cid_byte1_t4;
  wire [  7:  0] cid_byte2_t3;
  reg  [  7:  0] cid_byte2_t4;
  wire [  7:  0] cid_byte3_t3;
  reg  [  7:  0] cid_byte3_t4;
  wire [  7:  0] cid_byte4_t3;
  reg  [  7:  0] cid_byte4_t4;
  wire           cid_changed_t2;
  wire           cid_changed_t3_t4;
  reg            cid_changed_t3;
  reg            cid_changed_t4;
  wire [  2:  0] cid_numb_bytes_t3;
  wire           cid_valid;
  wire           context_cbit_t3;
  wire           context_changed_t3;
  wire [  7:  0] context_info_t3;
  wire           context_pkt_en_t3;
  wire           context_state_changed_t4;
  reg            context_state_changed_t5;
  wire           context_update_t3;
  wire           context_vbit_t3;
  wire           context_payld_t3;
  wire           context_force_out_t3;
  wire           core_in_debug_t2;
  reg            core_in_debug_t3;
  wire           curr_atom_pkt_gen_t4;
  wire           direct_branch_t3;
  reg  [  3:  0] etm_extout_t3;
  reg            gov_wfx_drain_req_t1;
  reg            gov_wfx_drain_req_t2;
  wire           wfx_state_t3;
  reg            wfx_state_t4;
  reg            trace_req_t1;
  reg            trace_req_t2;
  wire           event_pkt_en_t3;
  wire [  7:  0] event_pkt_t3;
  wire [  7:  0] excep_pkt_byte_t3;
  wire           excep_wpt_t3;
  wire           excep_pkt_gen_t2;
  wire           excep_pkt_gen_t3;
  reg            excep_wpt_t4;
  reg            excep_pkt_gen_t4;
  wire [  7:  0] excep_pkt_header_t3;
  wire           excep_pkt_wexec_t3;
  wire           ext_sync_pend_and_active_t3;
  reg            ext_sync_pend_and_active_t4;
  wire           ext_sync_pend_t3;
  reg            ext_sync_pend_t4;
  wire           external_sync_valid_t2;
  wire           external_sync_valid_t3;
  reg            external_sync_valid_t4;
  wire [  1:  0] final_16_0_t4;
  wire           final_16_1_t3a;
  wire [  3:  0] final_16_1_t4;
  reg            final_16_1_t4a;
  wire           final_16_2_t3a;
  wire [  3:  0] final_16_2_t4;
  reg            final_16_2_t4a;
  wire           final_16_3_t3a;
  wire [  3:  0] final_16_3_t4;
  reg            final_16_3_t4a;
  wire           final_16_4_t3a;
  wire [  3:  0] final_16_4_t4;
  reg            final_16_4_t4a;
  wire           final_16_5_t3a;
  wire [  3:  0] final_16_5_t4;
  reg            final_16_5_t4a;
  wire           final_16_6_t3a;
  wire [  3:  0] final_16_6_t4;
  reg            final_16_6_t4a;
  wire [  2:  0] final_16_7_t3a;
  wire [  3:  0] final_16_7_t4;
  reg  [  2:  0] final_16_7_t4a;
  wire [  3:  0] final_16_8_t4;
  wire [  3:  0] final_16_9_t4;
  wire [  3:  0] final_16_a_t4;
  wire [  3:  0] final_16_b_t4;
  wire [  3:  0] final_16_c_t4;
  wire [  3:  0] final_16_d_t4;
  wire [  3:  0] final_16_e_t4;
  wire [  3:  0] final_16_f_t4;
  wire [ 46:  0] packed_first_8_t3;
  reg  [ 46:  0] packed_first_8_t4;
  reg  [ 46:  0] packed_first_8_t5;
  reg  [ 63: 16] first_8_t3;
  wire           go_to_trace_overflow_idle;
  reg            go_to_trace_overflow_idle_q;
  wire           isync_addr_valid_t2;
  reg            isync_addr_valid_t3;
  reg            last_secure_state_output_t4;
  wire           new_secure_state_t3;
  wire [  3:  0] num_addr_bytes_t3;
  wire [  4:  0] num_bytes_t4;
  reg  [  4:  0] num_bytes_t5;
  wire [  1:  0] num_cycle_bytes_t3;
  wire [  2:  0] num_first8_info_t3;
  wire [  2:  0] num_first8_t3;
  wire [  2:  0] num_first8_true_t4;
  reg  [  2:  0] num_first8_t4;
  reg  [  2:  0] num_first8_t5;
  wire           numb_bytes_first8_update_en_t3;
  wire           numb_bytes_first8_update_t3;
  reg            numb_bytes_first8_update_t4;
  wire [  4:  0] nxt_num_bytes_t5;
  wire [  2:  0] nxt_num_first8_t5;
  reg            os_lock_set_t3;
  wire           overflow_state_t3;
  wire           overflow_state_t4;
  reg            overflow_state_t5;
  reg            overflow_state_t6;
  wire           ovfl_idle_state_t4;
  wire           overflow_supress;
  wire [  4:  0] pack16_bytes_in_t4;
  wire [  4:  0] pack16_bytes_part_t3;
  reg  [  4:  0] pack16_bytes_part_t4;
  wire [111:  0] pack16_data_in_common_t3;
  wire [111:  0] pack16_data_short_t3;
  reg  [111:  0] pack16_data_short_t4;
  wire [  7:  0] trace_on_or_curr_atom_t4;
  wire [127:  0] pack16_data_in_t4;
  wire [111:  0] pack16_data_short_ts_t3;
  wire           pack4_en_t3;
  wire [ 31:  0] pack4_in_t3;
  reg  [ 31:  0] pack_pack4_in_t4;
  wire [  2:  0] pack4_num_bytes_t3;
  reg  [  2:  0] pack4_num_bytes_t4;
  wire [  2:  0] ts_pack4_num_bytes_t4;
  wire [156:  0] pack_data_out_t5;
  wire           periodic_sync_valid_t3;
  reg            periodic_sync_valid_t4;
  wire           first_sync_t2;
  reg            first_sync_t3;

  wire           progbit_fall_t2;
  wire [ 63:  1] return_pc_t3;
  wire           return_stack_0_update_t3;
  wire           return_stack_0_valid_t3;
  reg            return_stack_0_valid_t4;
  wire           return_stack_0_valid_update_t3;
  wire           return_stack_1_update_t3;
  wire           return_stack_1_valid_t3;
  reg            return_stack_1_valid_t4;
  wire           return_stack_1_valid_update_t3;
  reg  [ 63:  1] return_stack_0_t4;
  reg  [ 63:  1] return_stack_1_t4;
  wire [ 63:  1] return_stack_t3_0;
  reg            return_stack_is_0_t4;
  reg            return_stack_is_1_t4;
  wire           return_stack_is_t3_0;
  wire           return_stack_hit_t3;
  wire [5:0]     return_stack_match_vec_t3;
  wire           return_stack_match_t3;
  reg            return_stack_match_t4;

  wire           return_stack_push_t3;
  wire           return_stack_valid_flush_t3;
  wire           set_overflow_t2;
  reg            set_overflow_t3;
  reg            set_overflow_t4;
  reg            set_overflow_t5;
  wire           sync_counter_match_t3;
  reg            sync_counter_match_t4;
  wire [ 17:  0] sync_counter_t3;
  wire           sync_counter_t3_en;
  reg  [ 17:  0] sync_counter_t4;
  wire           sync_insert_valid;
  reg            sync_period_check_bit_t3;
  wire           sync_periodic_req_t3;
  wire           sync_overflow;
  reg            sync_req_t3;
  wire           t32_state_0_t4;
  reg            t32_state_0_t5;
  wire           t32_state_1_t4;
  reg            t32_state_1_t5;
  wire           t32_state_2_t4;
  reg            t32_state_2_t5;
  wire           t32_state_t4;
  reg            t32_state_t5;
  wire           trace_active_t3;
  wire           trace_active_t4;
  reg            trace_active_t5;
  reg            trace_active_t6;
  reg            trace_active_t7;
  reg            trace_active_en_t5;
  wire           trace_enable_tx;
  wire           trace_enable_t2;
  reg            trace_enable_t3;
  reg            trace_enable_t4;
  reg            trace_enable_t5;
  reg            viewinst_idle_req_t3;
  wire           trace_event_pending_t3;
  wire           trace_go_inactive_t4;
  wire           trace_idle_state_cnt_en;
  wire [  3:  0] trace_idle_state_cnt_t2;
  reg  [  3:  0] trace_idle_state_cnt_t3;
  reg  [  1:  0] trace_idle_state_t2;
  reg  [  1:  0] trace_idle_state_t3;
  wire           idle_overflow_state_t3;
  wire           trace_info_pkt_cyct0_en_t3;
  wire [  7:  0] trace_info_pkt_cyct0_t3;
  wire           trace_info_pkt_cyct1_en_t3;
  wire [  7:  0] trace_info_pkt_cyct1_t3;
  wire           trace_info_pkt_en_t3;
  wire [  7:  0] trace_info_pkt_header;
  wire [  7:  0] trace_info_pkt_info_t3;
  wire [  7:  0] trace_info_pkt_plctl_t3;
  wire           trace_on_pkt_en_t3;
  reg            trace_on_pkt_en_t4;
  wire           trace_pending_excep_t2;
  reg            trace_pending_excep_t3;
  wire           trace_pending_excep_update_t2;
  wire           trace_reset_t3;
  reg            trace_reset_t4;
  reg  [  1:  0] trace_state_active_t3;
  wire [  1:  0] trace_state_t3;
  reg  [  1:  0] trace_state_t4;
  wire           trace_syserr_t3;
  reg            trace_syserr_t4;
  wire           trace_turnon_t3;
  wire           leave_idle_t3;
  wire [  3:  0] event_qual_t3;
  wire [  3:  0] traced_event_t3;
  reg  [  3:  0] traced_event_t4;
  wire [  3:  0] event_trace_pipe_t3;
  reg  [  3:  0] event_trace_pipe_t4;
  reg  [  3:  0] event_trace_pipe_t5;
  reg  [  3:  0] event_trace_pipe_t6;
  reg  [  3:  0] event_trace_pipe_t7;
  wire           ts_byte0_cc_bit_t3;
  reg            ts_byte0_cc_bit_t4;
  wire [  7:  0] ts_byte1_t3;
  wire [  7:  0] ts_byte2_t3;
  wire           ts_byte2_t3_en;
  wire [  7:  0] ts_byte3_t3;
  wire           ts_byte3_t3_en;
  wire [  7:  0] ts_byte4_t3;
  wire           ts_byte4_t3_en;
  wire [  7:  0] ts_byte5_t3;
  wire           ts_byte5_t3_en;
  wire [  7:  0] ts_byte6_t3;
  wire           ts_byte6_t3_en;
  wire [  7:  0] ts_byte7_t3;
  wire           ts_byte7_t3_en;
  wire [  7:  0] ts_byte8_t3;
  wire           ts_byte8_t3_en;
  wire [  7:  0] ts_byte9_t3;
  wire           ts_byte9_t3_en;
  wire [  7:  0] ts_bytea_t3;
  wire           ts_bytea_t3_en;
  wire [  4:  0] ts_byteb_t3;
  wire           ts_byteb_t3_en;
  wire [ 84:  0] ts_bytes_t3;
  reg            ts_event_t3;
  wire           ts_full_en_t3;
  wire           ts_full_pend_t3;
  reg            ts_full_pend_t4;
  reg  [ 63: 7 ] ts_last_t4;
  wire [  3:  0] ts_num_bytes_t3;
  reg  [  3:  0] ts_num_bytes_t4;
  wire           ts_output_en_pend_int_t3;
  wire           ts_output_en_t3;
  wire           ts_output_en_t4;
  wire           ts_output_en_poss_t3;
  reg            ts_output_en_poss_t4;
  wire           ts_part_pend_t3;
  reg            ts_part_pend_t4;
  wire           ts_valid_t3;
  reg            ts_valid_t4;
  wire           ts_pipe_t3;
  wire           ts_ready_t3;
  wire           ts_stall_t3;
  wire           ts_value_en_t2;
  wire [ 63:  0] ts_value_masked_t3;
  reg  [ 63:  0] ts_value_t3;
  wire           ts_value_update_t3;
  wire           update_bytelanes_en_t3;
  wire           update_bytes_en_t3;
  wire           valid_atom_packet_t4;
  wire           valid_atom_t3;
  wire           valid_atom_t4;
  wire           valid_branch_packet_t3;
  wire           valid_curr_atom_packet_t4;
  reg            valid_curr_atom_packet_t5;
  wire           valid_excp_return_out_t4;
  reg            viewinst_en_t3;
  reg            viewinst_en_t4;
  wire [  7:  0] vmid_byte1_t3;
  reg  [  7:  0] vmid_byte1_t4;
  wire           vmid_changed_t3;
  wire           vmid_changed_t4_t5;
  reg            vmid_changed_t4;
  reg            vmid_changed_t5;
  wire           vmid_valid;
  reg            wpt_aarch64_t4;
  reg            wpt_aarch64_t5;
  wire           wpt_address_generated_t2;
  reg            wpt_address_generated_t3;
  wire           wpt_address_update_en_t3;
  wire [ 63:  1] wpt_address_update_t3;
  reg  [ 63:  1] wpt_address_update_t4;
  reg            wpt_adv_t3;
  reg            wpt_adv_t4;
  wire           wpt_bytes_en_t4;
  wire [ 11:  0] wpt_cycle_counter_t3;
  reg  [ 11:  0] wpt_cycle_counter_t4;
  wire           cycle_count_unknown;
  wire [  1:  0] wpt_el_t3;
  reg  [  1:  0] wpt_el_t4;
  reg  [  1:  0] wpt_el_t5;
  wire           wpt_excep_notrace_t3;
  reg  [  3:  0] wpt_exception_type_t3;
  reg  [  3:  0] wpt_exception_type_t4;
  wire [  3:  0] wpt_exlevel_0_t3;
  reg  [  3:  0] wpt_exlevel_0_t4;
  wire [  3:  0] wpt_exlevel_1_t3;
  reg  [  3:  0] wpt_exlevel_1_t4;
  wire [  3:  0] wpt_exlevel_2_t3;
  reg  [  3:  0] wpt_exlevel_2_t4;
  reg  [  3:  0] wpt_exlevel_t3;
  reg            wpt_non_secure_t4;
  reg            wpt_non_secure_t5;
  reg            wpt_prohibited_t4;
  reg            wpt_prohibited_t5;
  wire           wpt_reset_t3;
  wire           wpt_syserr_t3;
  reg            wpt_taken_t4;
  reg            wpt_taken_t5;
  reg            wpt_taken_prev_t5;
  reg            wpt_target_tbit_t4;
  wire           wpt_traced_t3;
  reg            wpt_traced_t4;
  wire [  2:  0] wpt_type_mask_prohib_t3;
  reg  [  2:  0] wpt_type_t4;
  wire           wpt_valid_noprog_t2;
  reg            wpt_valid_noprog_t3;
  reg            wpt_valid_noprog_t4;
  wire           sync_sequence_complete_t3;
  wire           cc_pkt_b0_en_t2;
  wire           prevent_force_t3;

  //Core interface signals
  reg           wpt_valid_t1;
  reg           wpt_valid_t2;
  reg           wpt_valid_t3;
  reg           wpt_valid_t4;
  reg           dpu_wpt_adv_t1;
  wire          wpt_adv_t1;
  reg           wpt_adv_t2;
  reg           wpt_range_t1;

  reg  [2:0]    wpt_type_t1;
  reg  [2:0]    wpt_type_t2;
  reg  [2:0]    wpt_type_t3;
  reg           wpt_taken_t1;
  reg           wpt_taken_t2;
  reg           wpt_taken_t3 ;
  reg           wpt_link_t1;
  reg           wpt_link_t2;
  reg           wpt_link_t3;
  reg  [63:1]   wpt_addr_t1;
  reg  [63:1]   wpt_addr_t2;
  reg  [63:1]   wpt_addr_t3;
  reg  [63:1]   dpu_wpt_target_addr_opa_t1;
  reg  [27:1]   dpu_wpt_target_addr_opb_t1;
  reg  [1:0]    tlb_d_tcr_el1_tbi_t1;
  reg           tlb_d_tcr_el2_tbi0_t1;
  reg           tlb_d_tcr_el3_tbi0_t1;
  wire          zero_top_byte;
  wire          set_top_byte;
  wire [63:1]   wpt_target_pc_add_t1;
  wire [63:1]   wpt_target_pc_t1;
  reg  [63:1]   wpt_target_pc_t2;
  reg  [63:1]   wpt_target_pc_t3;
  reg  [31:0]   wpt_context_id_t1;
  reg  [31:0]   wpt_context_id_t2;
  reg  [31:0]   wpt_context_id_t3;
  reg  [7:0]    wpt_vmid_t1;
  reg  [7:0]    wpt_vmid_t2;
  reg  [7:0]    wpt_vmid_t3;
  reg  [1:0]    wpt_isa_t1;
  reg  [1:0]    wpt_isa_t2;
  reg  [1:0]    wpt_isa_t3;
  reg           wpt_t32_nt16_t1;
  reg           wpt_t32_nt16_t2;
  reg           wpt_t32_nt16_t3;
  reg           wpt_non_secure_t1;
  reg           wpt_non_secure_t2;
  reg           wpt_non_secure_t3;
  reg  [3:0]    wpt_exlevel_t1;
  reg  [3:0]    wpt_exlevel_t2;
  reg           wpt_prohibited_t1;
  reg           wpt_prohibited_t2;
  reg           wpt_prohibited_t3;

  reg  [3:0]    wpt_exception_type_t1;
  reg  [3:0]    wpt_exception_type_t2;



//
// Main Code
// =========
//


//---------------------------------------------------------------------------
// Capture core-in signals
//---------------------------------------------------------------------------

 // Wpt valid pipeline versions
  always @(posedge clk_gated or negedge po_reset_n)
    begin: ucore_in_wpt_valid
      if(!po_reset_n) begin
        wpt_valid_t1       <= 1'b0;
        wpt_valid_t2       <= 1'b0;
        wpt_valid_t3       <= 1'b0;
        wpt_valid_t4       <= 1'b0;
      end
      else begin
        wpt_valid_t1       <= dpu_wpt_valid_i;
        wpt_valid_t2       <= wpt_valid_t1;
        wpt_valid_t3       <= wpt_valid_t2;
        wpt_valid_t4       <= wpt_valid_t3;
      end
    end

 // resetable internal core interface signals: T1
  always @(posedge clk_gated or negedge po_reset_n)
    begin: ucore_in_resetable_signals_t1
      if(!po_reset_n) begin
        wpt_non_secure_t1  <= 1'b0;
        wpt_exlevel_t1     <= 4'b1000;
        wpt_prohibited_t1  <= 1'b1;
        wpt_isa_t1         <= 2'b10;  //A64
      end
      else if (dpu_wpt_valid_i)begin
        wpt_non_secure_t1  <= dpu_wpt_non_secure_i;
        wpt_exlevel_t1     <= dpu_wpt_exlevel_i ;
        wpt_prohibited_t1  <= dpu_wpt_prohibited_i;
        wpt_isa_t1         <= dpu_wpt_target_isa_i;
      end
    end

 // resetable internal core interface signals: T2
  always @(posedge clk_gated or negedge po_reset_n)
    begin: ucore_in_resetable_signals_t2
      if(!po_reset_n) begin
        wpt_non_secure_t2  <= 1'b0;
        wpt_exlevel_t2     <= 4'b1000;
        wpt_prohibited_t2  <= 1'b1;
        wpt_vmid_t2        <= {8{1'b0}};
        wpt_context_id_t2  <= {32{1'b0}};
        wpt_isa_t2         <= 2'b10;  //A64
      end
      else if (wpt_valid_t1)begin
        wpt_non_secure_t2  <= wpt_non_secure_t1;
        wpt_exlevel_t2     <= wpt_exlevel_t1 ;
        wpt_prohibited_t2  <= wpt_prohibited_t1;
        wpt_vmid_t2        <= wpt_vmid_t1;
        wpt_context_id_t2  <= wpt_context_id_t1;
        wpt_isa_t2         <= wpt_isa_t1;
      end
    end

 // resetable internal core interface signals: T3
  always @(posedge clk_gated or negedge po_reset_n)
    begin: ucore_in_resetable_signals_tb
      if(!po_reset_n) begin
        wpt_non_secure_t3 <= 1'b0;
        wpt_exlevel_t3    <= 4'b1000;
        wpt_prohibited_t3 <= 1'b1;
        wpt_vmid_t3       <= {8{1'b0}};
        wpt_context_id_t3 <= {32{1'b0}};
        wpt_isa_t3        <= 2'b10;  //A64
      end
      else if (wpt_valid_t2)begin
        wpt_non_secure_t3 <= wpt_non_secure_t2;
        wpt_exlevel_t3    <= wpt_exlevel_t2 ;
        wpt_prohibited_t3 <= wpt_prohibited_t2;
        wpt_vmid_t3       <= wpt_vmid_t2;
        wpt_context_id_t3 <= wpt_context_id_t2;
        wpt_isa_t3        <= wpt_isa_t2;
      end
    end

  always @(posedge clk_gated)
    begin: ucore_in_signals_t1
      if (dpu_wpt_valid_i)begin
        dpu_wpt_adv_t1             <= dpu_wpt_advance_i;
        wpt_range_t1               <= dpu_wpt_range_i;
        wpt_type_t1                <= dpu_wpt_type_i;
        wpt_taken_t1               <= dpu_wpt_taken_i;
        wpt_link_t1                <= dpu_wpt_link_i;
        wpt_addr_t1                <= dpu_wpt_addr_i;
        dpu_wpt_target_addr_opa_t1 <= dpu_wpt_target_addr_opa_i;
        dpu_wpt_target_addr_opb_t1 <= dpu_wpt_target_addr_opb_i;
        tlb_d_tcr_el1_tbi_t1       <= tlb_d_tcr_el1_tbi_i;
        tlb_d_tcr_el2_tbi0_t1      <= tlb_d_tcr_el2_tbi0_i;
        tlb_d_tcr_el3_tbi0_t1      <= tlb_d_tcr_el3_tbi0_i;
        wpt_context_id_t1          <= tlb_context_id_i;
        wpt_vmid_t1                <= tlb_vmid_i;
        wpt_t32_nt16_t1            <= dpu_wpt_t32_nt16_i;
        wpt_exception_type_t1      <= dpu_wpt_exception_type_i;
      end
    end //

  assign wpt_adv_t1 = dpu_wpt_adv_t1 | ((wpt_type_t1 != `CA53_ETM_WPT_EXCEPTION) & (wpt_type_t1 != `CA53_ETM_WPT_DBGENTRY));

  always @(posedge clk_gated)
    begin: ucore_in_signals_t2
      if (wpt_valid_t1)begin
        wpt_adv_t2            <= wpt_adv_t1;
        wpt_type_t2           <= wpt_type_t1;
        wpt_taken_t2          <= wpt_taken_t1;
        wpt_link_t2           <= wpt_link_t1;
        wpt_addr_t2           <= wpt_addr_t1;
        wpt_t32_nt16_t2       <= wpt_t32_nt16_t1;
        wpt_exception_type_t2 <= wpt_exception_type_t1;
      end
    end //

  always @(posedge clk_gated)
    begin: ucore_in_signals_t3
      if (wpt_valid_t2)begin
        wpt_adv_t3            <= wpt_adv_t2;
        wpt_type_t3           <= wpt_type_t2;
        wpt_taken_t3          <= wpt_taken_t2;
        wpt_link_t3           <= wpt_link_t2;
        wpt_addr_t3           <= wpt_addr_t2;
        wpt_t32_nt16_t3       <= wpt_t32_nt16_t2;
        wpt_exception_type_t3 <= wpt_exception_type_t2;
      end
    end //


  //Complete waypoint target calculation from two parts provided by DPU
  assign wpt_target_pc_add_t1 = {dpu_wpt_target_addr_opa_t1 + {{36{dpu_wpt_target_addr_opb_t1[27]}},dpu_wpt_target_addr_opb_t1}} &
                                {{32{wpt_isa_t1[1]}}, {31{1'b1}}};

  // Evaluate whether tagged addresses are in use, and the top PC byte should
  // be ignored
  assign zero_top_byte = ((|wpt_exlevel_t1[1:0] == 1'b1) & tlb_d_tcr_el1_tbi_t1[0] & ~wpt_target_pc_add_t1[55]) |
                          ((wpt_exlevel_t1[2]   == 1'b1) & tlb_d_tcr_el2_tbi0_t1)                          |
                          ((wpt_exlevel_t1[3]   == 1'b1) & tlb_d_tcr_el3_tbi0_t1);
  // Only in AArch64
  assign set_top_byte  = ((|wpt_exlevel_t1[1:0] == 1'b1) & tlb_d_tcr_el1_tbi_t1[1] & wpt_target_pc_add_t1[55]);
  
  assign wpt_target_pc_t1[63:56] = {8{set_top_byte}} |
                                  ({8{~zero_top_byte}} & wpt_target_pc_add_t1[63:56]);
  assign wpt_target_pc_t1[55:1]  = wpt_target_pc_add_t1[55:1];
  

  always @(posedge clk_gated or negedge po_reset_n)
    begin: uwpt_target_pc_t2
    if(!po_reset_n)
      wpt_target_pc_t2   <= {63{1'b0}};
    else if (wpt_valid_t1)
      wpt_target_pc_t2   <= wpt_target_pc_t1[63:1];
    end

  always @(posedge clk_gated or negedge po_reset_n)
    begin: uwpt_target_pc_t3
    if(!po_reset_n)
      wpt_target_pc_t3  <= {63{1'b0}};
    else if (wpt_valid_t2)
      wpt_target_pc_t3  <= wpt_target_pc_t2[63:1];
    end

  assign wpt_valid_t1_o      = wpt_valid_t1;
  assign wpt_valid_t2_o      = wpt_valid_t2;
  assign wpt_adv_t1_o        = wpt_adv_t1;
  assign wpt_adv_t2_o        = wpt_adv_t2;
  assign wpt_range_t1_o      = wpt_range_t1;
  assign wpt_type_t1_o       = wpt_type_t1;
  assign wpt_addr_t1_o       = wpt_addr_t1[63:1];
  assign wpt_target_pc_t2_o  = wpt_target_pc_t2[63:1];
  assign wpt_context_id_t2_o = wpt_context_id_t2;
  assign wpt_vmid_t2_o       = wpt_vmid_t2;
  assign wpt_aarch64_t2_o    = wpt_isa_t2[1];
  assign wpt_non_secure_t2_o = wpt_non_secure_t2;
  assign wpt_exlevel_t2_o    = wpt_exlevel_t2;
  assign wpt_prohibited_t2_o = wpt_prohibited_t2;
  assign wpt_dbg_entry_t2_o  = (wpt_type_t2[2:0] == `CA53_ETM_WPT_DBGENTRY) & wpt_valid_t2;
  assign wpt_dbg_exit_t2_o   = (wpt_type_t2[2:0] == `CA53_ETM_WPT_DBGEXIT)  & wpt_valid_t2;

//---------------------------------------------------------------------------
// TRACE ENABLE AND WAYPOINT CAPTURE.
//---------------------------------------------------------------------------

// trace enabled based on drain state machine
  assign trace_enable_t2 = core_at_main_run_t2_i;
  assign trace_enable_tx = trace_enable_t2 | trace_enable_t3;

// Pipeling trace enable status.
  assign progbit_fall_t2 = ~trace_enable_t3 & trace_enable_t2;

// Only take into account valid signals when progbit is not set and OS Lock is cleared
  assign wpt_valid_noprog_t2 = wpt_valid_t2 & trace_enable_t2 & ~viewinst_idle_req_t2_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uprogbit_q
    if (!po_reset_n) begin
      trace_enable_t3      <=  1'b0;
      trace_enable_t4      <=  1'b0;
      trace_enable_t5      <=  1'b0;
      os_lock_set_t3       <=  1'b0;
      viewinst_en_t3       <=  1'b0;
      viewinst_en_t4       <=  1'b0;
      etm_extout_t3        <=  {4{1'b0}};
      viewinst_idle_req_t3 <=  1'b0;
      wpt_valid_noprog_t3  <=  1'b0;
      wpt_valid_noprog_t4  <=  1'b0;
    end
    else begin
      trace_enable_t3      <=  trace_enable_t2;
      trace_enable_t4      <=  trace_enable_t3;
      trace_enable_t5      <=  trace_enable_t4;
      os_lock_set_t3       <=  etm_os_lock_trace_i;
      viewinst_en_t3       <=  viewinst_en_t2_i;
      viewinst_en_t4       <=  viewinst_en_t3;
      etm_extout_t3        <=  etm_extout_i;
      viewinst_idle_req_t3 <=  viewinst_idle_req_t2_i;
      wpt_valid_noprog_t3  <=  wpt_valid_noprog_t2;
      wpt_valid_noprog_t4  <=  wpt_valid_noprog_t3;

    end
  end // block: uprogbit_q


// Prohibited resume
// Make first waypoint after prohibited region look like debug exit
  assign wpt_type_mask_prohib_t3[2:0] = {3{wpt_prohibited_t4}} & `CA53_ETM_WPT_DBGEXIT |
                                        {3{~wpt_prohibited_t4}} & wpt_type_t3[2:0];


  assign wpt_el_t3[1:0] = (wpt_exlevel_t3[3])? 2'b11 :
                          (wpt_exlevel_t3[2])? 2'b10 :
                          (wpt_exlevel_t3[1])? 2'b01 :
                                               2'b00 ;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_all_q
    if (!po_reset_n) begin
      wpt_prohibited_t4          <=  1'b0;
      wpt_prohibited_t5          <=  1'b0;
      wpt_exception_type_t4[3:0] <=  {4{1'b0}};
      wpt_type_t4[2:0]           <=  {3{1'b0}};
      wpt_non_secure_t4          <=  1'b0;
      wpt_taken_t4               <=  1'b0;
      wpt_target_tbit_t4         <=  1'b0;
      wpt_aarch64_t4             <=  1'b0;
      wpt_el_t4[1:0]             <=  {2{1'b0}};
      wpt_adv_t4                 <=  1'b0;
    end
    else if (wpt_valid_t3) begin
      wpt_prohibited_t4          <=  wpt_prohibited_t3;
      wpt_prohibited_t5          <=  wpt_prohibited_t4;
      wpt_exception_type_t4[3:0] <=  wpt_exception_type_t3[3:0];
      wpt_type_t4[2:0]           <=  wpt_type_mask_prohib_t3[2:0];
      wpt_non_secure_t4          <=  wpt_non_secure_t3;
      wpt_taken_t4               <=  wpt_taken_t3;
      wpt_target_tbit_t4         <=  wpt_isa_t3[0];
      wpt_aarch64_t4             <=  wpt_isa_t3[1];
      wpt_el_t4[1:0]             <=  wpt_el_t3[1:0];
      wpt_adv_t4                 <=  wpt_adv_t3;
    end
  end

// Direct branch
  assign direct_branch_t3 = (wpt_type_t4[2:0] == `CA53_ETM_WPT_DIRECTBRANCH) |
                            (wpt_type_t4[2:0] == `CA53_ETM_WPT_ISB);

//---------------------------------------------------------------------------
//   TRACE GENERATION STATE MACHINE
//
//   Reset or Powerdown-----------
//                                |
//                                v
//           -------------(State == Idle)-------------------------
//          |                     ^                               |
//          |                     |                            viewinst_en &
//          |             ~ viewinst_en &                       Valid Isync &
//          |                ~Overflow                           ~Overflow
//          |                     |                               |
//          |                     |                               v
//          |                      ------------------------(State == Tracing)
//       Overflow                 |                               ^
//          |                     |                               |
//          |                 Overflow                            |
//          |                     |                               |
//          v                     |                               |
//   (State == Overflow)<---------                                |
//          |                                                     |
//          |                                                     |
//      Valid Isync &                                         Fifo Empty &
//      delay                                                 viewinst_en &
//          |                                                 Valid Waypoint
//          |                                                     |
//          v                                                     |
//   (State == Overflowidle)--------------------------------------
//
//---------------------------------------------------------------------------

//   Trace generation state control. Expects input to be held between wpts.
//   OverflowIdle indicates a waypoint has passed in Overflow, safe to turn
//   on again. Only powerdown clears overflow.
  assign leave_idle_t3 = isync_addr_valid_t3 & wpt_valid_noprog_t3 &
                         (wpt_syserr_t3 | wpt_reset_t3 | (viewinst_en_t3 & ~wpt_excep_notrace_t3));
  
  always @*
  begin
    case(trace_state_t4[1:0])
      CA53_ETM_GEN_ST_IDLE:       trace_state_active_t3  = set_overflow_t3 ? CA53_ETM_GEN_ST_OVERFLOW :
                                                           leave_idle_t3   ? CA53_ETM_GEN_ST_TRACING :
                                                                             CA53_ETM_GEN_ST_IDLE;
      CA53_ETM_GEN_ST_TRACING:    trace_state_active_t3 = set_overflow_t3 ?  CA53_ETM_GEN_ST_OVERFLOW :
                                                          viewinst_en_t3  ?  CA53_ETM_GEN_ST_TRACING :
                                                                             CA53_ETM_GEN_ST_IDLE;
      CA53_ETM_GEN_ST_OVERFLOW:   trace_state_active_t3 = ~go_to_trace_overflow_idle ? CA53_ETM_GEN_ST_OVERFLOW :
                                                           trace_event_pending_t3    ? CA53_ETM_GEN_ST_IDLE :
                                                                                       CA53_ETM_GEN_ST_OFLOWIDLE;
      CA53_ETM_GEN_ST_OFLOWIDLE:  trace_state_active_t3 = set_overflow_t3            ? CA53_ETM_GEN_ST_OVERFLOW :
                                                          ~active_wpt_or_event_t3    ? CA53_ETM_GEN_ST_OFLOWIDLE :
                                                          ~leave_idle_t3             ? CA53_ETM_GEN_ST_IDLE :
                                                                                       CA53_ETM_GEN_ST_TRACING;
      default     : trace_state_active_t3 = {2{1'bx}};
    endcase
  end // always @ *

  assign active_wpt_or_event_t3 = wpt_valid_noprog_t3 | trace_event_pending_t3;

  assign trace_state_t3[1:0] = trace_enable_t3 ? trace_state_active_t3 : CA53_ETM_GEN_ST_IDLE;

  assign trace_active_t3   = (trace_state_t3[1:0] == CA53_ETM_GEN_ST_TRACING);
  assign trace_active_t4   = (trace_state_t4[1:0] == CA53_ETM_GEN_ST_TRACING);

  assign trace_overflow_o  = overflow_state_t4 | fifo_overflow_i;

// Overflow is caused by either
// 1) Actual FIFO overflow
// 2) Forced overflow due to sync packets not output in time and not already in overflow.
  assign set_overflow_t2 = (sync_overflow & ~overflow_state_t4) | fifo_overflow_i;

//OverFlow Idle state is not still in overflow, it is state with no activity.
  assign overflow_state_t4  = trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW;
  assign ovfl_idle_state_t4 = trace_state_t4[1:0] == CA53_ETM_GEN_ST_OFLOWIDLE;
  assign overflow_state_t3  = trace_state_t3 == CA53_ETM_GEN_ST_OVERFLOW;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uoverflow_state
    if (!po_reset_n) begin
      overflow_state_t5 <=  1'b0;
      overflow_state_t6 <=  1'b0;
    end
    else begin
      overflow_state_t5 <=  overflow_state_t4;
      overflow_state_t6 <=  overflow_state_t5;
    end
  end

  // Overflow Idle state indicates a waypoint/event has been seen after fifo recovery, and trace can start
  assign go_to_trace_overflow_idle = fifo_empty_i &
                                     overflow_state_t4 &
                                     ~ set_overflow_t3 &
                                     ~ set_overflow_t4 &
                                     ~go_to_trace_overflow_idle_q &
                                     (trace_enable_tx | idle_overflow_state_t3);


  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_state_q
    if (!po_reset_n) begin
      trace_state_t4      <= CA53_ETM_GEN_ST_IDLE;
      set_overflow_t3     <=  1'b0;
    end
    else begin
      trace_state_t4      <=  trace_state_t3;
      set_overflow_t3     <=  set_overflow_t2;
    end
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_active_q
    if (!po_reset_n) begin
      trace_active_t5             <=  1'b0;
      trace_active_t6             <=  1'b0;
      trace_active_t7             <=  1'b0;
      set_overflow_t4             <=  1'b0;
      set_overflow_t5             <=  1'b0;
      go_to_trace_overflow_idle_q <=  1'b0;
    end
    else begin
      trace_active_t5             <=  trace_active_t4;
      trace_active_t6             <=  trace_active_t5;
      trace_active_t7             <=  trace_active_t6;
      set_overflow_t4             <=  set_overflow_t3;
      set_overflow_t5             <=  set_overflow_t4;
      go_to_trace_overflow_idle_q <=  go_to_trace_overflow_idle;
    end
  end


// Trace can be turned on again and valid ISYNC is generated if
// 1) we are not in overflow or we are out of overflow and
// 2) we are not in prohibited state and
// 4) prog bit is not set and
// 3) we have a waypoint this cycle or we have captured a waypoint in previous cycles.
  assign isync_addr_valid_t2 = ~overflow_state_t3 &
                               ~wpt_prohibited_t3 &
                                (wpt_valid_noprog_t3 | (isync_addr_valid_t3 & (trace_enable_tx | wfx_resource_t3_i)));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uisync_addr_valid_t3
    if (!po_reset_n)
      isync_addr_valid_t3 <=  1'b0;
    else
      isync_addr_valid_t3 <=  isync_addr_valid_t2;
  end

// Trace is getting captured whenever trace is active or
// waiting for a new waypoint while trace is inactive and
// progbit is not set and we are not in overflow state

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_active_t5
    if (!po_reset_n)
      trace_active_en_t5 <=  1'b0;
    else if (trace_enable_t4 | trace_enable_t5)
      trace_active_en_t5 <=  trace_active_t4;
  end

  assign core_in_debug_t2 = (wpt_type_t3[2:0] == `CA53_ETM_WPT_DBGENTRY) & wpt_valid_t3;

// If we are really exiting debug, keep track on it.
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucore_in_debug_t3
    if (!po_reset_n)
      core_in_debug_t3 <=  1'b0;
    else if (wpt_valid_t3)
      core_in_debug_t3 <=  core_in_debug_t2;
  end


// Security state change since last output isync or branch
  assign new_secure_state_t3 = last_secure_state_output_t4 ^ wpt_non_secure_t4;

//---------------------------------------------------------------------------
// Event PACKET
//---------------------------------------------------------------------------

// no event generation when
//   FIFO overflow
//   idle as indicated by trace status
// event has to be delayed until ovfl signal asserted to the fifo

  assign event_trace_pipe_t3[3:0] = etm_extout_t3[3:0] & event_enable_reg_i[3:0] &
                                     {4{trace_enable_t2 &
                                        (overflow_state_t4 |
                                        (~trace_idle_state_cnt_t3[3]))}};

  assign event_qual_t3[3:0] = (overflow_state_t3) ? 4'h0 :                    //in overflow
                                                    event_trace_pipe_t3[3:0]; //normal

  assign event_pkt_t3[7:0] = {4'b0111, event_qual_t3[3:0]};

  assign trace_event_pending_t3  = |(traced_event_t3);

  // Suppress events when disabling directly after leaving overflow
  // After 2 cycles, idle counter takes over
  assign event_pkt_en_t3 = |event_qual_t3[3:0];

  assign event_trigger_req_t3_o = event_atbtrig_en_reg_i  & event_qual_t3[0];

// Capture events affected by overflow. Entering overflow, any event up to t7 would be lost.
// Continue adding events from t3 until overflow recovery.
// At point of recovery, new events are traced again by passing through pipe as normal.
  assign traced_event_t3[3:0] = ({4{fifo_overflow_i}}   & (event_trace_pipe_t4 | event_trace_pipe_t5 | 
                                                           event_trace_pipe_t6 | event_trace_pipe_t7)) |
                                ({4{overflow_state_t4 | set_overflow_t3 | sync_overflow}}     & traced_event_t4) |
                                                                                                event_trace_pipe_t3;
  
  always @(posedge clk_gated or negedge po_reset_n)
  begin: traced_event_t4_q
    if (!po_reset_n) begin
      traced_event_t4      <= {4{1'b0}};
      event_trace_pipe_t4  <= {4{1'b0}};
      event_trace_pipe_t5  <= {4{1'b0}};
      event_trace_pipe_t6  <= {4{1'b0}};
      event_trace_pipe_t7  <= {4{1'b0}};
    end
    else begin
      traced_event_t4      <= traced_event_t3;
      event_trace_pipe_t4  <= event_trace_pipe_t3;
      event_trace_pipe_t5  <= event_trace_pipe_t4;
      event_trace_pipe_t6  <= event_trace_pipe_t5;
      event_trace_pipe_t7  <= event_trace_pipe_t6;
    end
  end

  assign traced_event_t3_o  = traced_event_t3[3:0];
//---------------------------------------------------------------------------
// CONTEXT PACKET
//---------------------------------------------------------------------------

// Context info
  assign context_info_t3[7:0] = {context_cbit_t3,
                                 context_vbit_t3,
                                 wpt_non_secure_t4,
                                 wpt_aarch64_t4,
                                 2'b00,
                                 wpt_el_t4[1:0]};

  assign context_update_t3 = trace_active_t3 | trace_active_t4 | trace_pending_excep_t3;

  // context state comparison for the current WP
  assign context_state_changed_t4 = (trace_active_t4 | trace_pending_excep_t3) &
                                     ((wpt_non_secure_t4 ^ wpt_non_secure_t5) |
                                      (wpt_aarch64_t4 ^ wpt_aarch64_t5)       |
                                      (|(wpt_el_t4[1:0] ^ wpt_el_t5[1:0]))
                                      );


  always @(posedge clk_gated or negedge po_reset_n)
  begin: context_state_q
    if (!po_reset_n) begin
      wpt_non_secure_t5        <= 1'b0;
      wpt_aarch64_t5           <= 1'b0;
      wpt_el_t5[1:0]           <= {2{1'b0}};
      context_state_changed_t5 <= 1'b0;
    end
    else if (context_update_t3) begin
      wpt_non_secure_t5        <= wpt_non_secure_t4;
      wpt_aarch64_t5           <= wpt_aarch64_t4;
      wpt_el_t5[1:0]           <= wpt_el_t4[1:0];
      context_state_changed_t5 <= context_state_changed_t4;
    end
  end


  assign context_changed_t3 = (~excep_pkt_gen_t3 & context_state_changed_t4  ) |
                              ( excep_pkt_gen_t4 & context_state_changed_t5);

// context id and vmid will be in context packet
//   changed and id is enabled
//   follow trace info if the id is enabled or
//   after trace is first enabled
  assign context_force_out_t3 = trace_info_pkt_en_t3 | trace_turnon_t3;
  assign context_cbit_t3 = (context_force_out_t3 | cid_changed_t3_t4 ) & context_id_reg_i;
  assign context_vbit_t3 = (context_force_out_t3 | vmid_changed_t4_t5) & vmid_reg_i;
  assign context_payld_t3= (context_force_out_t3 | context_changed_t3 | context_cbit_t3 | context_vbit_t3 |
                            (valid_branch_packet_t3 & ~address_exact_match_t3));


// context is output when trace is active and
//   CID or VMID or context state change
//   after trace info packet
//   after trace on packet
  assign context_pkt_en_t3 = ((trace_active_t3 | trace_pending_excep_t2 | trace_pending_excep_t3) &
                            ((trace_turnon_t3   & ~overflow_state_t4 & ~excep_pkt_gen_t3)| // not valid context when trace in overflow state
                             (trace_info_pkt_en_t3 & ~overflow_state_t4) |
                             ((excep_pkt_gen_t4 | ~excep_pkt_gen_t3) &
                              (cid_changed_t3_t4 | vmid_changed_t4_t5 | context_changed_t3))
                            )) |
                            ((trace_reset_t3 | trace_syserr_t3) & trace_turnon_t3) ;

//---------------------------------------------------------------------------
// CID bytes
//---------------------------------------------------------------------------

// CID valid
  assign cid_valid = cid_changed_t2 | async_req_t3;

// Output CID after trace info packet.

  assign cid_byte1_t3[7:0] = wpt_context_id_t3[7:0];
  assign cid_byte2_t3[7:0] = wpt_context_id_t3[15:8];
  assign cid_byte3_t3[7:0] = wpt_context_id_t3[23:16];
  assign cid_byte4_t3[7:0] = wpt_context_id_t3[31:24];

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucid_byte_t3
    if (!po_reset_n) begin
      cid_byte1_t4[7:0] <=  {8{1'b0}};
      cid_byte2_t4[7:0] <=  {8{1'b0}};
      cid_byte3_t4[7:0] <=  {8{1'b0}};
      cid_byte4_t4[7:0] <=  {8{1'b0}};
   end
   else if (cid_valid) begin
      cid_byte1_t4[7:0] <=  cid_byte1_t3[7:0];
      cid_byte2_t4[7:0] <=  cid_byte2_t3[7:0];
      cid_byte3_t4[7:0] <=  cid_byte3_t3[7:0];
      cid_byte4_t4[7:0] <=  cid_byte4_t3[7:0];
    end
  end


// Output CID packet if it is different from previous value.

  assign cid_changed_t2 = |(wpt_context_id_t3[31:0] ^ {cid_byte4_t4,cid_byte3_t4,cid_byte2_t4,cid_byte1_t4});

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucid_changed_t3
    if (!po_reset_n) begin
      cid_changed_t3 <=  1'b0;
      cid_changed_t4 <=  1'b0;
    end
    else begin
      cid_changed_t3 <=  cid_changed_t2;
      cid_changed_t4 <=  cid_changed_t3;
    end
  end

  assign cid_changed_t3_t4 = (~excep_pkt_gen_t3 & cid_changed_t3) |
                             ( excep_pkt_gen_t4 & cid_changed_t4);

//---------------------------------------------------------------------------
// VMID bytes
//---------------------------------------------------------------------------

// Output VMID after trace info packet.

  assign vmid_byte1_t3[7:0] = wpt_vmid_t3[7:0];
  assign vmid_valid = vmid_changed_t3 | trace_info_pkt_en_t3;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uvmid_byte1_t4_7_0
    if (!po_reset_n) begin
      vmid_byte1_t4[7:0] <= {8{1'b0}};
    end
    else if (vmid_valid) begin
      vmid_byte1_t4[7:0] <=  vmid_byte1_t3[7:0];
    end
  end



// Output VMID packet if it is different from previous value.
  assign vmid_changed_t3 = vmid_reg_i & (|(wpt_vmid_t3[7:0] ^ vmid_byte1_t4[7:0]));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uvmid_changed
    if (!po_reset_n) begin
      vmid_changed_t4 <=  1'b0;
      vmid_changed_t5 <=  1'b0;
    end
    else begin
      vmid_changed_t4 <=  vmid_changed_t3;
      vmid_changed_t5 <=  vmid_changed_t4;
    end
  end


  assign vmid_changed_t4_t5 = (~excep_pkt_gen_t3 & vmid_changed_t4) |
                              ( excep_pkt_gen_t4 & vmid_changed_t5);

//---------------------------------------------------------------------------
// CYCLE COUNT FOR CYCLE ACCURATE MODE
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Cycle count for Atom and Branch packets.
// Count Cycles between waypoints

// cycle count for normal operation start from 'd1
// cycle count is assigned to unkown (zero) when
// 1. after trace enabled
// 2. after cycle count  overflow

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_cycle_count_q
    if (!po_reset_n)
      wpt_cycle_counter_t4[11:0] <=  {12{1'b0}};
    else if (cycle_counting_reg_i)
      wpt_cycle_counter_t4[11:0] <=  wpt_cycle_counter_t3[11:0];
  end

// Set to 12'h001 only if packet was generated.
// Keep at 0 until packet is output:
//     Overflow
//     All set
//     All clear
//     First enabled

  assign cycle_count_unknown = overflow_state_t3 | (&wpt_cycle_counter_t4) | ~(|wpt_cycle_counter_t4) | ~trace_enable_t4;

  assign wpt_cycle_counter_t3[11:0] = {{11{~cycle_count_unknown & ~cc_pkt_b0_en_t3}}, ~cycle_count_unknown | cc_pkt_b0_en_t3} &
                                      ((wpt_cycle_counter_t4[11:0] + 12'h001) |
                                       {{11{1'b0}},cc_pkt_b0_en_t3});

// cycle count packet is generated when threshold is crossed for normal operation
// for unknown cycle count value, any packet generation will trigger cycle count packet
  assign cc_pkt_b0_en_t3 = cycle_counting_reg_i &
                         ((wpt_cycle_counter_t4 >= cc_threshold_reg_i) | ~|wpt_cycle_counter_t4) &
                          (valid_atom_t4 | excep_pkt_gen_t3);

  assign cc_pkt_b0_en_t2 = cycle_counting_reg_i &
                         (((wpt_cycle_counter_t4+1'b1) >= cc_threshold_reg_i) | ~|wpt_cycle_counter_t4 | &wpt_cycle_counter_t4) &
                          ((valid_atom_t3 & trace_active_t3) | excep_pkt_gen_t2);

  assign ts_output_en_t3 = ts_output_en_poss_t3 & ~cc_pkt_b0_en_t2;
  
  assign cc_pkt_b1_en_t3 = cc_pkt_b0_en_t3 & ~cc_pkt_format3_t3 & |wpt_cycle_counter_t4;

  assign cc_pkt_b2_en_t3 = cc_pkt_b1_en_t3 & cc_pkt_format1_b2_t3;


// cycle count packet
  assign cc_pkt_counter_t3[11:0] = wpt_cycle_counter_t4[11:0] - cc_threshold_reg_i[11:0];
  assign cc_pkt_format1_b2_t3 = |cc_pkt_counter_t3[11:7];
  assign cc_pkt_format2_t3 = ~|cc_pkt_counter_t3[11:4] & ~cc_pkt_format3_t3;
  assign cc_pkt_format3_t3 = ~|cc_pkt_counter_t3[11:2];

  assign cc_pkt_b0_t3[7:0] = (~|wpt_cycle_counter_t4) ?    8'b0000_1111                        :
                                  (cc_pkt_format3_t3) ?   {6'b0001_00, cc_pkt_counter_t3[1:0]} :
                                  (cc_pkt_format2_t3) ?    8'b0000_1101                        :
                                                          8'b0000_1110;

  assign cc_pkt_b1_t3[7:0] = (cc_pkt_format2_t3)    ? {4'b1111, cc_pkt_counter_t3[3:0]} :
                             (cc_pkt_format1_b2_t3) ? {1'b1, cc_pkt_counter_t3[6:0]}    :
                                                      {1'b0, cc_pkt_counter_t3[6:0]};

  assign cc_pkt_b2_t3[4:0] = cc_pkt_counter_t3[11:7];


//---------------------------------------------------------------------------
// RETURN STACK REPLACES BRANCH WITH ATOM IF ADDRESS MATCHES
//---------------------------------------------------------------------------
// Push for Link instructions.
// Pop on valid pc and security match or Isync output.
  assign return_stack_match_t3 = &return_stack_match_vec_t3 &
                                 ~return_stack_valid_flush_t3;

  assign return_stack_match_vec_t3 = {return_stack_0_valid_t4,
                                      wpt_valid_t3,
                                     (~wpt_link_t3 & wpt_taken_t3),
                                     (return_stack_0_t4[63:1] == wpt_target_pc_t3[63:1]),
                                     (return_stack_is_0_t4 == wpt_isa_t3[0]),
                                     (wpt_type_t3[2:0] == `CA53_ETM_WPT_INDIRECT)};

// Perform return stack comparison in t3, use in t4
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureturn_stack_match_t4
    if (!po_reset_n)
      return_stack_match_t4 <=  1'b0;
    else if(return_stack_en_reg_i)
      return_stack_match_t4 <=  return_stack_match_t3;
  end


  assign return_pc_t3[63:1] = wpt_addr_t3[63:1] +
                                    ({{61{1'b0}},arm_nthumb_state_t3 | wpt_t32_nt16_t3,~wpt_t32_nt16_t3});

// Push for Link instructions.
  assign return_stack_push_t3 =  return_stack_en_reg_i &
                                 wpt_address_generated_t3 &
                                 wpt_valid_noprog_t3 &
                                 wpt_link_t3 &
                                 wpt_taken_t3 &
                               ~(branch_broadcast_reg_i & bb_en_t3) ;

// return stack should not be pushed onto if no address is generated after a sync request
  assign wpt_address_generated_t2 = ~trace_info_pkt_en_t3 & (wpt_address_generated_t3 | valid_branch_packet_t3);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_address_generated_t3
    if (!po_reset_n)
      wpt_address_generated_t3 <= 1'b0;
    else if(return_stack_en_reg_i)
      wpt_address_generated_t3 <= wpt_address_generated_t2;
  end



// Return stack entry 0/1
  always @(posedge clk_gated)
  begin: ureturn_stack_0
    if (return_stack_0_update_t3) begin
      return_stack_0_t4[63:1]  <=  return_stack_t3_0[63:1];
      return_stack_is_0_t4     <=  return_stack_is_t3_0;
    end
  end

  always @(posedge clk_gated)
  begin: ureturn_stack_1
    if (return_stack_1_update_t3) begin
      return_stack_1_t4[63:1]  <=  return_stack_0_t4[63:1];
      return_stack_is_1_t4     <=  return_stack_is_0_t4;
    end
  end

  assign return_stack_t3_0[63:1] = (return_stack_match_t3)? return_stack_1_t4[63:1] : return_pc_t3[63:1];
  assign return_stack_is_t3_0    = (return_stack_match_t3)? return_stack_is_1_t4    : wpt_target_tbit_t4;

  assign return_stack_0_update_t3 = return_stack_push_t3 | return_stack_match_t3;
  assign return_stack_1_update_t3 = return_stack_push_t3;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureturn_stack_valid_0_t3
    if (!po_reset_n)
      return_stack_0_valid_t4 <=  1'b0;
    else if (return_stack_0_valid_update_t3)
      return_stack_0_valid_t4 <=  return_stack_0_valid_t3;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureturn_stack_valid_1_t3
    if (!po_reset_n)
      return_stack_1_valid_t4 <=  1'b0;
    else if (return_stack_1_valid_update_t3)
      return_stack_1_valid_t4 <=  return_stack_1_valid_t3;
  end


  assign return_stack_0_valid_t3 = ~return_stack_valid_flush_t3 &
                                   (return_stack_push_t3 | (return_stack_match_t3 & return_stack_1_valid_t4));

  assign return_stack_1_valid_t3 = ~return_stack_valid_flush_t3 & return_stack_push_t3 & return_stack_0_valid_t4;

  assign return_stack_0_valid_update_t3 = return_stack_valid_flush_t3 | return_stack_push_t3 | return_stack_match_t3;
  assign return_stack_1_valid_update_t3 = return_stack_0_valid_update_t3;

// flush out the return stack valid
// the current WPT will also be flushed

  assign return_stack_valid_flush_t3 = ((sync_periodic_req_t3 | async_pend_t4) & sync_insert_valid) | trace_on_pkt_en_t3 | bb_entry_t3;
  assign bb_entry_t3 = bb_en_t3 & ~bb_en_t4 & branch_broadcast_reg_i;

  assign return_stack_hit_t3 = return_stack_match_t4;


//---------------------------------------------------------------------------
// ATOM HEADER
//---------------------------------------------------------------------------

// Valid atom if
// 1) Direct branch
// 2) Non direct branch instruction
// 3) Exception return
// 3) ISB


  always @(posedge clk_gated or negedge po_reset_n)
  begin: ubb_en
    if (!po_reset_n) begin
      bb_en_t3  <=  1'b0;
      bb_en_t4  <=  1'b0;
    end
    else begin
      bb_en_t3  <=  bb_en_t2_i;
      bb_en_t4  <=  bb_en_t3;
    end
  end

  assign valid_atom_t3 = trace_active_t3 & wpt_valid_noprog_t3 &
                         ((wpt_type_t3[2:0] == `CA53_ETM_WPT_DIRECTBRANCH)  |
                          (wpt_type_t3[2:0] == `CA53_ETM_WPT_INDIRECT)      |
                          (wpt_type_t3[2:0] == `CA53_ETM_WPT_ISB)           |
                          (wpt_type_t3[2:0] == `CA53_ETM_WPT_EXCP_RETURN)
                         );
  assign valid_atom_t4 = trace_active_t4 & wpt_valid_noprog_t4 &
                         ((wpt_type_t4[2:0] == `CA53_ETM_WPT_DIRECTBRANCH)  |
                          (wpt_type_t4[2:0] == `CA53_ETM_WPT_INDIRECT)      |
                          (wpt_type_t4[2:0] == `CA53_ETM_WPT_ISB)           |
                          (wpt_type_t4[2:0] == `CA53_ETM_WPT_EXCP_RETURN)
                         );

// atom packet completion
// these sync/async events will cause the output of atom packet
  assign atom_completion_t3 =
   (atom_pkg_st_t3[2:0] != ATOM_PKG_ST_IDLE)       &  // atom is accumulating and
   (valid_branch_packet_t3                         |  // branch address packet pending
    context_pkt_en_t3                              |  // context packet pending
    excep_pkt_gen_t3                               |  // exception packet pending
    ~trace_active_t4                               |  // trace is inactive next cycle
    event_pkt_en_t3                                |  // event packet pending
    ts_output_en_t3                                |  // timestamp pending
    async_pend_t3                                  |  // async pending
    gov_wfx_drain_req_t1                           |  // Entering idle state
    set_overflow_t3                                   // trace overflow
   );

// atom is forced out (all old plus current cycle) by
  assign atom_forceout_t4 =
    valid_atom_t4                                  &
   (valid_branch_packet_t3                         |  // branch address packet pending
    context_pkt_en_t3                              |  // context packet pending
    cc_pkt_b0_en_t3                                |  // cycle count packet generation
    async_pend_t3)                                 ;  // async pending

// atom is combined if no event packet is present
  assign atom_combine_t3    = ~event_pkt_en_t3 & atom_forceout_t4;
  assign atom_no_combine_t3 =  event_pkt_en_t3 | ts_output_en_t3;

// atom packet state machine
// two events determine the next state
// 1. valid atom
// 2. atom completion
  assign atom_pkg_st_update_t3 = valid_atom_t4 | atom_completion_t3 | atom_pkt_gen_t4 | atom_forceout_t4;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: atom_pkg_st_q
    if (!po_reset_n)
      atom_pkg_st_t3[2:0] <=  ATOM_PKG_ST_IDLE;
    else if (atom_pkg_st_update_t3)
      atom_pkg_st_t3[2:0] <=  atom_pkg_st_t2[2:0];
  end


  always @*
  begin
    case(atom_pkg_st_t3[2:0])
      ATOM_PKG_ST_IDLE:     atom_pkg_st_t2 = (valid_atom_t4 & ~atom_forceout_t4)      ?
                                                                     ATOM_PKG_ST_FMT1 :
                                                                     ATOM_PKG_ST_IDLE;

      ATOM_PKG_ST_FMT1:     atom_pkg_st_t2 = (atom_completion_t3 & ~valid_atom_t4)    ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_forceout_t4)                      ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_completion_t3)                    ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (valid_atom_t4)?       ATOM_PKG_ST_FMT2 :
                                                                     ATOM_PKG_ST_FMT1;

      ATOM_PKG_ST_FMT2:     atom_pkg_st_t2 = (atom_completion_t3 & ~valid_atom_t4)    ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_forceout_t4)                      ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_completion_t3)                    ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (valid_atom_t4)?       ATOM_PKG_ST_FMT3 :
                                                                     ATOM_PKG_ST_FMT2;

      ATOM_PKG_ST_FMT3:     atom_pkg_st_t2 = (atom_completion_t3 & ~valid_atom_t4)    ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_forceout_t4)                      ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_completion_t3)                    ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (atom_pkt_format4_t3)                   ?
                                                                     ATOM_PKG_ST_FMT4 :
                                              (valid_atom_t4 & atom_pkt_format6_t3)   ?
                                                                     ATOM_PKG_ST_FMT6 :
                                              (valid_atom_t4)?       ATOM_PKG_ST_FMT1 :
                                                                     ATOM_PKG_ST_FMT3;

      ATOM_PKG_ST_FMT4:     atom_pkg_st_t2 = (atom_completion_t3 & ~valid_atom_t4)    ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_forceout_t4)                      ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (atom_completion_t3)                    ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (atom_pkt_format5_t3)                   ?
                                                                     ATOM_PKG_ST_FMT5 :
                                              (valid_atom_t4)?       ATOM_PKG_ST_FMT1 :
                                                                     ATOM_PKG_ST_FMT4;

      ATOM_PKG_ST_FMT5:     atom_pkg_st_t2 = (valid_atom_t4 & ~atom_forceout_t4)      ?
                                                                     ATOM_PKG_ST_FMT1 :
                                                                     ATOM_PKG_ST_IDLE;

      ATOM_PKG_ST_FMT6:     atom_pkg_st_t2 = (atom_completion_t3 & wpt_taken_prev_t5 & ~atom_no_combine_t3) ?
                                                                     ATOM_PKG_ST_IDLE :
                                             (atom_completion_t3 & ~valid_atom_t4) ?
                                                                     ATOM_PKG_ST_IDLE :
                                             (atom_forceout_t4) ?
                                                                     ATOM_PKG_ST_IDLE :
                                             (atom_completion_t3)  ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (~valid_atom_t4 & ~wpt_taken_prev_t5)   ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (                 ~wpt_taken_prev_t5)    ?
                                                                     ATOM_PKG_ST_FMT1 :
                                              (                 ~wpt_taken_t4)         ?
                                                                     ATOM_PKG_ST_IDLE :
                                              (valid_atom_t4 & (atom_count_t4 == 5'b10100))?
                                                                     ATOM_PKG_ST_IDLE :
                                                                     ATOM_PKG_ST_FMT6;

      default     : atom_pkg_st_t2 = {3{1'bx}};
    endcase
  end

// atom bits
// the bits are shifted left when new valid atom bit is generated
// the history will be reset to all zero for atom completion

  always @(posedge clk_gated or negedge po_reset_n)
  begin: atom_bits_q
    if (!po_reset_n)
      atom_bits_t4[4:0] <=  {5{1'b0}};
    else if (atom_pkg_st_update_t3)
      atom_bits_t4[4:0] <=  atom_bits_t3[4:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: atom_bit_count_q
    if (!po_reset_n)
      atom_bit_count_t4[2:0] <=  {3{1'b0}};
    else if (atom_pkg_st_update_t3)
      atom_bit_count_t4[2:0] <=  atom_bit_count_t3[2:0];
  end


  assign atom_bit_count_t3[2:0] =    (atom_forceout_t4)                ?                         3'b000 :
                                     (atom_pkt_gen_t4 & atom_pkg_st_t3[2:0]==ATOM_PKG_ST_FMT6 & 
                                      ~atom_no_combine_t3 & wpt_taken_prev_t5)?                  3'b000 :
                                     (atom_pkt_gen_t4 & ~valid_atom_t4)?                         3'b000 :
                                     (atom_pkt_gen_t4)                 ?                         3'b001 :
                                     (valid_atom_t4)                   ?     atom_bit_count_t4[2:0] + 3'b001 :
                                                                             atom_bit_count_t4[2:0];


  assign atom_bits_t3[4:0] =
                             (valid_atom_t4 & atom_pkt_gen_t4)                   ?  {4'b0000, wpt_taken_t4} :
                             (valid_atom_t4 & (atom_bit_count_t4[2:0] == 3'b000))?  {4'b0000, wpt_taken_t4} :
                             (valid_atom_t4 & (atom_bit_count_t4[2:0] == 3'b001))?  {3'b000, wpt_taken_t4, atom_bits_t4[0]} :
                             (valid_atom_t4 & (atom_bit_count_t4[2:0] == 3'b010))?  {2'b00, wpt_taken_t4, atom_bits_t4[1:0]}:
                             (valid_atom_t4 & (atom_bit_count_t4[2:0] == 3'b011))?  {1'b0, wpt_taken_t4, atom_bits_t4[2:0]} :
                             (valid_atom_t4 & (atom_bit_count_t4[2:0] == 3'b100))?  {wpt_taken_t4, atom_bits_t4[3:0]}       :
                                                                                    atom_bits_t4[4:0];


// atom bit comparison
// for the specific encoding patterns
  assign atom_pkt_format4_t3 = (atom_bit_count_t4[2:0] == 3'b011) & valid_atom_t4 &
                                (({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b1110) |
                                 ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b0000) |
                                 ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b1010) |
                                 ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b0101));

  assign atom_pkt_format5_t3 = (atom_bit_count_t4[2:0] == 3'b100) & valid_atom_t4 &
                                (({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b11110) |
                                 ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b00000) |
                                 ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b01010) |
                                 ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b10101));

  // only used from format 3, so count is known to be 3 already
  assign atom_pkt_format6_t3 = (atom_bits_t4[2:0] == 3'b111);

// atom counts
// for the atom header format 6
// the value of 00000 to 10100 corresponds to atom length of 4 to 24

  always @(posedge clk_gated or negedge po_reset_n)
  begin: atom_count_q
    if (!po_reset_n)
      atom_count_t4[4:0] <=  {5{1'b0}};
    else if (valid_atom_t4)
      atom_count_t4[4:0] <=  atom_count_t3[4:0];
  end

  assign atom_count_t3[4:0]  = (atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT6)? atom_count_t4[4:0] + {4'b0000, valid_atom_t4} :
                                                                          5'b00001;
  assign atom_count_t4_minus_one[4:0] = atom_count_t4[4:0] - 5'b00001;
// previous atom bit
// this is for format6 and event forced out atom packet
// event should have current atom following it, hence the previous atom bit is poped/kept
  always @(posedge clk_gated or negedge po_reset_n)
  begin:uwpt_taken_prev_t5
    if (!po_reset_n)
      wpt_taken_prev_t5 <=  1'b0;
    else if (valid_atom_t4)
      wpt_taken_prev_t5 <=  wpt_taken_t4;
  end

// atom packet generation enable
  assign atom_pkt_gen_t4 = atom_completion_t3 | atom_combine_t3 |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT3) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_FMT1)) |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT3) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_IDLE)) |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT4) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_FMT1)) |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT4) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_IDLE)) |
                          (atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT5) |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT6) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_FMT1)) |
                         ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT6) & (atom_pkg_st_t2[2:0] == ATOM_PKG_ST_IDLE));

// current atom packet generation enable (2nd atom packet)
  assign curr_atom_pkt_gen_t4 = atom_forceout_t4 &
                               (atom_no_combine_t3 |
                                ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT3) & ~atom_pkt_format4_t3) |
                                ((atom_pkg_st_t3[2:0] == ATOM_PKG_ST_FMT4) & ~atom_pkt_format5_t3) |
                                (atom_pkg_st_t3[2:0]  == ATOM_PKG_ST_FMT5)                         |
                                (atom_pkg_st_t3[2:0]  == ATOM_PKG_ST_FMT6  & ~wpt_taken_prev_t5)
                               );


// assemble atom packet, include current wpt when atom_combine_t3 is set
  always @*
  begin
    case(atom_pkg_st_t3[2:0])
      ATOM_PKG_ST_IDLE:     atom_pkt_t3[7:0] =                     {7'b1111_011, wpt_taken_t4};

      ATOM_PKG_ST_FMT1:     atom_pkt_t3[7:0] = (atom_combine_t3)?  {6'b1101_10, wpt_taken_t4, atom_bits_t4[0]} :
                                                                    {7'b1111_011, atom_bits_t4[0]};

      ATOM_PKG_ST_FMT2:     atom_pkt_t3[7:0] = (atom_combine_t3)?  {5'b1111_1, wpt_taken_t4, atom_bits_t4[1:0]} :
                                                                    {6'b1101_10, atom_bits_t4[1:0]};

      ATOM_PKG_ST_FMT3:     atom_pkt_t3[7:0] = (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b1110))?
                                                                     8'b1101_11_00 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b0000))?
                                                                     8'b1101_11_01 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b1010))?
                                                                     8'b1101_11_10 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[2:0]} == 4'b0101))?
                                                                     8'b1101_11_11 :
                                                                    {5'b1111_1, atom_bits_t4[2:0]};

      ATOM_PKG_ST_FMT4:     atom_pkt_t3[7:0] = (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b11110)) ?
                                                                     8'b11_1_101_01 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b00000))?
                                                                     8'b11_0_101_01 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b01010))?
                                                                     8'b11_0_101_10 :
                                                (atom_combine_t3 & ({wpt_taken_t4, atom_bits_t4[3:0]} == 5'b10101))?
                                                                     8'b11_0_101_11 :
                                                (atom_bits_t4[3:0] == 4'b1110)?
                                                                     8'b1101_11_00  :
                                                (atom_bits_t4[3:0] == 4'b0000)?
                                                                     8'b1101_11_01  :
                                                (atom_bits_t4[3:0] == 4'b1010)?
                                                                     8'b1101_11_10  :
                                                                     8'b1101_11_11; // for 4'b0101

      ATOM_PKG_ST_FMT5:     atom_pkt_t3[7:0] = (atom_bits_t4[4:0] == 5'b11110) ? 8'b11_1_101_01 :
                                                (atom_bits_t4[4:0] == 5'b00000)? 8'b11_0_101_01 :
                                                (atom_bits_t4[4:0] == 5'b01010)? 8'b11_0_101_10 :
                                                                                 8'b11_0_101_11; // for 5'b10101

      ATOM_PKG_ST_FMT6:     atom_pkt_t3[7:0] = (~wpt_taken_prev_t5)              ? {2'b11,  1'b1             , atom_count_t4_minus_one[4:0]} :
                                               (valid_atom_t4 & ~atom_no_combine_t3)? {2'b11, ~wpt_taken_t4,      atom_count_t4[4:0]} : 
                                               (valid_atom_t4                      )? {2'b11, ~wpt_taken_prev_t5, atom_count_t4_minus_one[4:0]} : 
                                                                                   {2'b11, 1'b0,               atom_count_t4_minus_one[4:0]};

      default         :     atom_pkt_t3[7:0] = {8{1'bx}};
    endcase
  end

//---------------------------------------------------------------------------
// WAYPOINT STATE
//---------------------------------------------------------------------------

  assign a32_state_new_t4 = ~(wpt_target_tbit_t4) & ~wpt_aarch64_t4;

// the exception changed state one cycle later
  assign a32_state_t4 = (excep_pkt_gen_t3)? a32_state_t5 : a32_state_new_t4;
  assign a64_state_t4 = (excep_pkt_gen_t3)? a64_state_t5 : wpt_aarch64_t4;
  assign t32_state_t4 = (excep_pkt_gen_t3)? t32_state_t5 : wpt_target_tbit_t4;
  assign arm_nthumb_state_t3 = (excep_pkt_gen_t3)? (a32_state_t5 | a64_state_t5) :
                                                   (a32_state_t4 | a64_state_t4);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ua32_state_t5
    if (!po_reset_n) begin
      a32_state_t5 <=  1'b0;
      a64_state_t5 <=  1'b0;
      t32_state_t5 <=  1'b0;
    end
    else begin
      a32_state_t5 <=  a32_state_new_t4;
      a64_state_t5 <=  wpt_aarch64_t4;
      t32_state_t5 <=  wpt_target_tbit_t4;
    end
  end

// Last output state of Isync and Branch packet
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ulast_state_output_q
    if (!po_reset_n) begin
      last_secure_state_output_t4 <=  1'b0;
    end
    else if (valid_branch_packet_t3) begin
      last_secure_state_output_t4 <=  wpt_non_secure_t4;
    end
  end



//---------------------------------------------------------------------------
// ADDRESS PACKET
//---------------------------------------------------------------------------


// Target address can be
// 1. current PC if exception
// 2. target PC otherwise

  assign wpt_address_update_t3[63:1] = ((trace_active_t3 | trace_pending_excep_t2) &
                                        excep_wpt_t3                               &
                                        (wpt_traced_t4 | wpt_adv_t3 | trace_reset_t3 | trace_syserr_t3))?
                                           wpt_addr_t3[63:1]     :
                                           wpt_target_pc_t3[63:1];

// both the current address and target pc logged for exception
  assign wpt_address_update_en_t3 = wpt_valid_noprog_t3 | excep_pkt_gen_t3;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_address_update_t4_63_1
    if (!po_reset_n)
      wpt_address_update_t4[63:1] <=  {63{1'b0}};
    else if (wpt_address_update_en_t3)
      wpt_address_update_t4[63:1] <=  wpt_address_update_t3[63:1];
  end

// Target Address history
// The program state is kept along with the address history so as to qualify the address comparison

  assign address_hist_reset_t3 = trace_info_pkt_en_t3 | trace_go_inactive_t4;

// trace goes inactive

  assign trace_go_inactive_t4 = ~trace_active_t5 & trace_active_t6;

  assign address_hist_0_t3[63:1] = wpt_address_update_t4[63:1];
  assign a64_state_0_t4          = a64_state_t4;
  assign a32_state_0_t4          = a32_state_t4;
  assign t32_state_0_t4          = t32_state_t4;
  assign wpt_exlevel_0_t3[3:0]   = wpt_exlevel_t3[3:0];
  assign address_hist_val_0_t3   = address_hist_update_t3 & ~address_hist_reset_t3 & trace_active_t4;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: address_hist_0_q
    if (!po_reset_n) begin
      address_hist_0_t4[63:1] <=  {63{1'b0}};
      a64_state_0_t5          <=  1'b0;
      a32_state_0_t5          <=  1'b0;
      t32_state_0_t5          <=  1'b0;
      wpt_exlevel_0_t4[3:0]   <=  {4{1'b0}};
      address_hist_val_0_t4   <=  1'b0;
    end
    else if (address_hist_update_t3) begin
      address_hist_0_t4[63:1] <=  address_hist_0_t3[63:1];
      a64_state_0_t5          <=  a64_state_0_t4;
      a32_state_0_t5          <=  a32_state_0_t4;
      t32_state_0_t5          <=  t32_state_0_t4;
      wpt_exlevel_0_t4[3:0]   <=  wpt_exlevel_0_t3[3:0];
      address_hist_val_0_t4   <=  address_hist_val_0_t3;
    end
  end

  assign address_hist_1_t3[63:1] = address_hist_0_t4[63:1];
  assign a64_state_1_t4          = a64_state_0_t5;
  assign a32_state_1_t4          = a32_state_0_t5;
  assign t32_state_1_t4          = t32_state_0_t5;
  assign wpt_exlevel_1_t3[3:0]   = wpt_exlevel_0_t4[3:0];
  assign address_hist_val_1_t3   = address_hist_val_0_t4 & ~address_hist_reset_t3 & trace_active_t4;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: address_hist_1_q
    if (!po_reset_n) begin
      address_hist_1_t4[63:1] <=  {63{1'b0}};
      a64_state_1_t5          <=  1'b0;
      a32_state_1_t5          <=  1'b0;
      t32_state_1_t5          <=  1'b0;
      wpt_exlevel_1_t4[3:0]   <=  {4{1'b0}};
      address_hist_val_1_t4   <=  1'b0;
    end
    else if (address_hist_update_t3) begin
      address_hist_1_t4[63:1] <=  address_hist_1_t3[63:1];
      a64_state_1_t5          <=  a64_state_1_t4;
      a32_state_1_t5          <=  a32_state_1_t4;
      t32_state_1_t5          <=  t32_state_1_t4;
      wpt_exlevel_1_t4[3:0]   <=  wpt_exlevel_1_t3[3:0];
      address_hist_val_1_t4   <=  address_hist_val_1_t3;
    end
  end


  assign address_hist_2_t3[63:1] = address_hist_1_t4[63:1];
  assign a64_state_2_t4          = a64_state_1_t5;
  assign a32_state_2_t4          = a32_state_1_t5;
  assign t32_state_2_t4          = t32_state_1_t5;
  assign wpt_exlevel_2_t3[3:0]   = wpt_exlevel_1_t4[3:0];
  assign address_hist_val_2_t3   = address_hist_val_1_t4 & ~address_hist_reset_t3 & trace_active_t4;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: address_hist_2_q
    if (!po_reset_n) begin
      address_hist_2_t4[63:1] <=  {63{1'b0}};
      a64_state_2_t5          <=  1'b0;
      a32_state_2_t5          <=  1'b0;
      t32_state_2_t5          <=  1'b0;
      wpt_exlevel_2_t4[3:0]   <=  {4{1'b0}};
      address_hist_val_2_t4   <=  1'b0;
    end
    else if (address_hist_update_t3) begin
      address_hist_2_t4[63:1] <=  address_hist_2_t3[63:1];
      a64_state_2_t5          <=  a64_state_2_t4;
      a32_state_2_t5          <=  a32_state_2_t4;
      t32_state_2_t5          <=  t32_state_2_t4;
      wpt_exlevel_2_t4[3:0]   <=  wpt_exlevel_2_t3[3:0];
      address_hist_val_2_t4   <=  address_hist_val_2_t3;
    end
  end

// address match with the Q including processor state bit
  assign address_match_0_t3 = (wpt_valid_noprog_t4 | excep_pkt_gen_t4)             &
                              ~trace_turnon_t3 & ~excep_pkt_wexec_t3               &
                              ~address_hist_reset_t3 & address_hist_val_0_t4       &
                              (wpt_address_update_t4[63:1] == address_hist_0_t4[63:1]) &
                              (wpt_exlevel_t3[3:0]         == wpt_exlevel_0_t4[3:0])   &
                              (a64_state_t4                == a64_state_0_t5)          &
                              (a32_state_t4                == a32_state_0_t5)          &
                              (t32_state_t4                == t32_state_0_t5);

  assign address_match_1_t3 = (wpt_valid_noprog_t4 | excep_pkt_gen_t4)             &
                              ~trace_turnon_t3 & ~excep_pkt_wexec_t3               &
                              ~address_hist_reset_t3 & address_hist_val_1_t4       &
                              (wpt_address_update_t4[63:1] == address_hist_1_t4[63:1]) &
                              (wpt_exlevel_t3[3:0]         == wpt_exlevel_1_t4[3:0])   &
                              (a64_state_t4                == a64_state_1_t5)          &
                              (a32_state_t4                == a32_state_1_t5)          &
                              (t32_state_t4                == t32_state_1_t5);

  assign address_match_2_t3 = (wpt_valid_noprog_t4 | excep_pkt_gen_t4)             &
                              ~trace_turnon_t3 & ~excep_pkt_wexec_t3               &
                              ~address_hist_reset_t3 & address_hist_val_2_t4       &
                              (wpt_address_update_t4[63:1] == address_hist_2_t4[63:1]) &
                              (wpt_exlevel_t3[3:0]         == wpt_exlevel_2_t4[3:0])   &
                              (a64_state_t4                == a64_state_2_t5)          &
                              (a32_state_t4                == a32_state_2_t5)          &
                              (t32_state_t4                == t32_state_2_t5);


  assign address_exact_match_t3 = address_match_0_t3 | address_match_1_t3 | address_match_2_t3;
// Q will be updated
// 1. new branch packet and no match in the Q
// 2. exception with execution

  assign address_hist_update_t3 = valid_branch_packet_t3 | excep_pkt_wexec_t3 | (excep_pkt_gen_t4 & ~core_in_debug_t3) |
                                  trace_info_pkt_en_t3 | trace_go_inactive_t4;

// exact match address packet header
  assign address_match_pkt_header_t3[7:0]  = (address_match_0_t3)? `CA53_ETM_PKT_ADDR_EACT_MATCH0 :
                                             (address_match_1_t3)? `CA53_ETM_PKT_ADDR_EACT_MATCH1 :
                                             (address_match_2_t3)? `CA53_ETM_PKT_ADDR_EACT_MATCH2 :
                                                                   8'b1001_0011;                // Reserved Header

// check the changing bytes of the address
  assign address_change_b4567_t3 = (wpt_address_update_t4[63:32] != address_hist_0_t4[63:32]) | address_hist_reset_t3 | ~address_hist_val_0_t4;

  assign address_change_b23_t3   = (address_hist_reset_t3 | ~address_hist_val_0_t4)? 1'b1 :
                                   arm_nthumb_state_t3? (wpt_address_update_t4[31:17] != address_hist_0_t4[31:17]) :
                                                        (wpt_address_update_t4[31:16] != address_hist_0_t4[31:16]) ;

  assign address_change_b1_t3    = (address_hist_reset_t3 | ~address_hist_val_0_t4)? 1'b1 :
                                   arm_nthumb_state_t3? (wpt_address_update_t4[16:9]  != address_hist_0_t4[16:9]) :
                                                        (wpt_address_update_t4[15:8]  != address_hist_0_t4[15:8]) ;

// assemble address packet header
  always @*
  begin
    case({context_pkt_en_t3, addr_pkt_en_t3, arm_nthumb_state_t3, address_change_b4567_t3, address_change_b23_t3})
      `ca53etm_sel_x0xxx: address_pkt_header_t3[7:0] = address_match_pkt_header_t3[7:0];                               // exact match
      `ca53etm_sel_01000: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS1_SHORT |  {8{1'b0}};                      // IS1/IS2 short
      `ca53etm_sel_01001: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS1_2_32;                                    // IS1/IS2 32
      `ca53etm_sel_0101x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS1_2_64;                                    // IS1/IS2 64
      `ca53etm_sel_01100: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS0_SHORT;                                   // IS0 short
      `ca53etm_sel_01101: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS0_32;                                      // IS0 32
      `ca53etm_sel_0111x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS0_64;                                      // IS0 64
      `ca53etm_sel_1100x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS1_2_32_LONG;                               // IS1/IS2 32 w/ context
      `ca53etm_sel_1101x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS1_2_64_LONG;                               // IS1/IS2 64 w/ context
      `ca53etm_sel_1110x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS0_32_LONG;                                 // IS0 32 w/ context
      `ca53etm_sel_1111x: address_pkt_header_t3[7:0] = `CA53_ETM_PKT_ADDR_IS0_64_LONG;                                 // IS0 64 w/ context
      default : address_pkt_header_t3[7:0] = {8{1'bx}};
    endcase
  end

assign addr_pkt_en_t3 = trace_turnon_t3    |
                        excep_pkt_wexec_t3 |
                      ((excep_pkt_gen_t4 | valid_branch_packet_t3) & ~address_exact_match_t3);

// assemble address packet data
  assign br_addr_byte0_en_t3 = address_pkt_header_t3[7:0] != address_match_pkt_header_t3[7:0];
  assign br_addr_byte1_en_t3 = br_addr_byte0_en_t3 & (address_change_b1_t3  | br_addr_byte2_en_t3    | context_pkt_en_t3);
  assign br_addr_byte2_en_t3 = br_addr_byte0_en_t3 & (address_change_b23_t3 | br_addr_byte3_en_t3    | context_pkt_en_t3);
  assign br_addr_byte3_en_t3 = br_addr_byte0_en_t3 & (address_change_b23_t3 | br_addr_byte4567_en_t3 | context_pkt_en_t3);
  assign br_addr_byte4567_en_t3 = br_addr_byte0_en_t3 & address_change_b4567_t3;

  assign br_addr_byte0_t3[7:0] = arm_nthumb_state_t3 ?
                                 {((address_pkt_header_t3[7:0] == `CA53_ETM_PKT_ADDR_IS0_SHORT) & address_change_b1_t3), wpt_address_update_t4[8:2]} :
                                 {((address_pkt_header_t3[7:0] == `CA53_ETM_PKT_ADDR_IS1_SHORT) & address_change_b1_t3), wpt_address_update_t4[7:1]} ;

  assign br_addr_byte1_t3[7:0] = arm_nthumb_state_t3 ?
                                 {((address_pkt_header_t3[7:0] == `CA53_ETM_PKT_ADDR_IS0_SHORT) & wpt_address_update_t4[16]), wpt_address_update_t4[15:9]} :
                                                                                                                              wpt_address_update_t4[15:8];

  assign {br_addr_byte7_t3[7:0],
          br_addr_byte6_t3[7:0],
          br_addr_byte5_t3[7:0],
          br_addr_byte4_t3[7:0],
          br_addr_byte3_t3[7:0],
          br_addr_byte2_t3[7:0]} = {wpt_address_update_t4[63:16]};

// Output a branch packet if
// 1) Trace is active and
// 2) We get a valid taken waypoint and
// 3) Direct branch with either branch broadcast enabled or security changed or
//    Indirect branch where return stack pc match fails or return stack security match fails or
//    Debug Entry Waypoint
//    Exception w/ execution
// 4) After trace info/on packet
  
  assign valid_branch_packet_t3 = (
                                   ((trace_turnon_t3) & ~overflow_state_t4)
                                 |
                                   (trace_info_pkt_en_t3 & ~overflow_state_t4) 
                                 |  // not valid branch when trace in overflow state
                                   (excep_pkt_gen_t4 & (trace_active_t5 | trace_pending_excep_t3 | trace_reset_t4 | trace_syserr_t4)
                                    & ~core_in_debug_t3 & ~wpt_prohibited_t4)
                                 |  // exception target address but not when trace is inactive or in debug state
                                   (wpt_valid_noprog_t4 & wpt_taken_t4 & trace_active_t4 &
                                     ((direct_branch_t3 & ((branch_broadcast_reg_i & bb_en_t4) | new_secure_state_t3))            |
                                      (wpt_type_t4[2:0] == `CA53_ETM_WPT_INDIRECT & (~return_stack_hit_t3 | new_secure_state_t3)) |
                                      (wpt_type_t4[2:0] == `CA53_ETM_WPT_EXCP_RETURN))
                                   )
                                 |  //wpt taken, branch or exception return
                                   (wpt_valid_noprog_t4 & wpt_taken_t4 & (trace_active_t4 | trace_pending_excep_t3 | trace_reset_t4 | trace_syserr_t4)
                                    & ~overflow_state_t4 & excep_wpt_t4)
                                    //wpt taken, exception address
                                 );

//---------------------------------------------------------------------------
// EXCEPTION PACKET
//---------------------------------------------------------------------------

// exception pkt is generated when there is
// 1. exception
// 2. debug state entry
// exception pkt can only be generated after address element is in the trace

  assign excep_wpt_t3 = wpt_valid_noprog_t3 & ~overflow_state_t4 &
                            ((wpt_type_t3[2:0] == `CA53_ETM_WPT_EXCEPTION) |
                             (wpt_type_t3[2:0] == `CA53_ETM_WPT_DBGENTRY));


// Exception waypoint can also infer instructions, and would be traced even without force
  assign wpt_excep_notrace_t3 = (~wfx_state_t4) &
                                ((excep_wpt_t3 & ~wpt_adv_t3) | (wpt_type_t3[2:0] == `CA53_ETM_WPT_DBGEXIT));

// exception packet generation
  assign excep_pkt_gen_t3 = excep_wpt_t4 & ~overflow_state_t4 &
                          ((trace_active_t4 & wpt_adv_t3)     |         // turnon 1: exception w/ execution after trace turns on
                           (trace_active_t4 & wpt_traced_t4)  |         // turnon 2: wpt generated after trace turns on
                           trace_pending_excep_t3  |
                           trace_reset_t4 | trace_syserr_t4);
  // Fast version for timestamp/cycle count
  assign excep_pkt_gen_t2 = excep_wpt_t3 & ~overflow_state_t3 &
                          ((trace_active_t3 & wpt_adv_t2)     |         // turnon 1: exception w/ execution after trace turns on
                           (trace_active_t3 & wpt_traced_t3)  |         // turnon 2: wpt generated after trace turns on
                           trace_pending_excep_t2  |
                           trace_reset_t3 | trace_syserr_t3);

// wpt generated in the trace
// wpt trace turned off for
//   1. os_lock set
//   2. prohib entry
//   3. one cycle after overflow idle exit
 assign wpt_traced_t3 = (excep_pkt_gen_t3 |
                         ((trace_active_t4 | wfx_state_t4) &
                          (wpt_traced_t4 | (wpt_valid_t4 & (wpt_type_t4[2:0] != `CA53_ETM_WPT_EXCEPTION) & (wpt_type_t4[2:0] != `CA53_ETM_WPT_DBGENTRY))))) &
                        ~wpt_prohibited_t4 &
                        ~overflow_state_t5;

// exception will be traced if previous instruction/exception is traced or system error or reset exception when they are enabled
  assign trace_pending_excep_t2 = (wpt_valid_t3 & ~viewinst_idle_req_t3) &
                                 ~(wpt_prohibited_t4 | overflow_state_t4) & (
              ((wpt_type_t3[2:0] == `CA53_ETM_WPT_EXCEPTION) & (((trace_pending_excep_t3 | (wpt_traced_t3 & ~trace_active_t3)) & ~wpt_adv_t3)
                                                                | trace_syserr_t3 | trace_reset_t3))                                       |
              ((wpt_type_t3[2:0] == `CA53_ETM_WPT_DBGENTRY)  & (((trace_pending_excep_t3 | wpt_traced_t3) & (trace_active_t3 | ~wpt_adv_t3)) |
                                                             (trace_active_t3 & wpt_adv_t3))));

  assign trace_pending_excep_update_t2 =  wpt_valid_noprog_t3 |overflow_state_t4 | ((~trace_enable_t3 | viewinst_idle_req_t3) & ~wfx_resource_t3_i);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwpt_traced_t4
    if (!po_reset_n)
      wpt_traced_t4 <=  1'b0;
    else
      wpt_traced_t4 <=  wpt_traced_t3;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_pending_excep_t3
    if (!po_reset_n)
      trace_pending_excep_t3 <=  1'b0;
   else if (trace_pending_excep_update_t2)
      trace_pending_excep_t3 <=  trace_pending_excep_t2;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uexcep_wpt_t4
    if (!po_reset_n) begin
        excep_wpt_t4        <=  1'b0;
    end
    else begin
        excep_wpt_t4        <=  excep_wpt_t3;
    end
  end

  assign excep_pkt_wexec_t3  = excep_pkt_gen_t3 & wpt_adv_t4;

  assign excep_pkt_header_t3[7:0] =  `CA53_ETM_PKT_EXCEPT;

  assign excep_pkt_byte_t3[7:0] = {1'b0, ~excep_pkt_wexec_t3, 1'b0, wpt_exception_type_t4[3:0], excep_pkt_wexec_t3};

// Disable the first wpt trace for SErr and Reset exception after trace enable
// System error trace
  assign trace_syserr_t3 = viewinst_trcerr_reg_i &
                           ~gov_wfx_drain_req_t2 &
                           ~overflow_state_t4 &
                           (wpt_type_t3[2:0] == `CA53_ETM_WPT_EXCEPTION) &
                           (wpt_exception_type_t3[3:0] == `CA53_ETM_SYS_ERR_EXCP) &
                             isync_addr_valid_t3 &
                            ~trace_active_1st_wpt_t4_i;

  assign wpt_syserr_t3 = trace_syserr_t3 & wpt_valid_noprog_t3;

// Reset exception trace
  assign trace_reset_t3  = viewinst_trcreset_reg_i &
                           ~gov_wfx_drain_req_t2 &
                           ~overflow_state_t4 &
                           (wpt_type_t3[2:0] == `CA53_ETM_WPT_EXCEPTION) &
                           (wpt_exception_type_t3[3:0] == `CA53_ETM_RESET_EXCP) &
                             isync_addr_valid_t3 &
                            ~trace_active_1st_wpt_t4_i;

  assign wpt_reset_t3 = trace_reset_t3 & wpt_valid_noprog_t3;

// T4 version of trace_syserr and trace_reset
  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_serr_reset_t4
    if (!po_reset_n) begin
        trace_syserr_t4 <= 1'b0;
        trace_reset_t4  <= 1'b0;
    end
    else begin
        trace_syserr_t4 <= trace_syserr_t3;
        trace_reset_t4  <= trace_reset_t3;
    end
  end

//---------------------------------------------------------------------------
// EXCEPTION RETURN PACKET
//---------------------------------------------------------------------------

// Exception return packet.
  assign valid_excp_return_out_t4 = wpt_valid_noprog_t4 & wpt_taken_t4 & trace_active_t4 & (wpt_type_t4[2:0] == `CA53_ETM_WPT_EXCP_RETURN);


//---------------------------------------------------------------------------
//   PERIODIC SYNCHRONISATION CONTROL
//---------------------------------------------------------------------------
// Generate sync requests at the most frequent of periodic or external req.
// Once pended, this generates A-sync, Trace Info,  and Trace On in order.
// After A-sync, Trace On and Trace On can be satisfied by non-periodic packets.
// If request recurs before all 3 were output, forced overflow condition occurs.

  always @*
  begin
    case(sync_period_reg_i[4:0])
    5'b00000: sync_period_check_bit_t3 = 1'b0;
    5'b00001: sync_period_check_bit_t3 = 1'b0;
    5'b00010: sync_period_check_bit_t3 = 1'b0;
    5'b00011: sync_period_check_bit_t3 = 1'b0;
    5'b00100: sync_period_check_bit_t3 = 1'b0;
    5'b00101: sync_period_check_bit_t3 = 1'b0;
    5'b00110: sync_period_check_bit_t3 = 1'b0;
    5'b00111: sync_period_check_bit_t3 = 1'b0;
    5'b01000: sync_period_check_bit_t3 = sync_counter_t4[5];
    5'b01001: sync_period_check_bit_t3 = sync_counter_t4[6];
    5'b01010: sync_period_check_bit_t3 = sync_counter_t4[7];
    5'b01011: sync_period_check_bit_t3 = sync_counter_t4[8];
    5'b01100: sync_period_check_bit_t3 = sync_counter_t4[9];
    5'b01101: sync_period_check_bit_t3 = sync_counter_t4[10];
    5'b01110: sync_period_check_bit_t3 = sync_counter_t4[11];
    5'b01111: sync_period_check_bit_t3 = sync_counter_t4[12];
    5'b10000: sync_period_check_bit_t3 = sync_counter_t4[13];
    5'b10001: sync_period_check_bit_t3 = sync_counter_t4[14];
    5'b10010: sync_period_check_bit_t3 = sync_counter_t4[15];
    5'b10011: sync_period_check_bit_t3 = sync_counter_t4[16];
    5'b10100: sync_period_check_bit_t3 = sync_counter_t4[17];
    5'b10101: sync_period_check_bit_t3 = 1'b0;
    5'b10110: sync_period_check_bit_t3 = 1'b0;
    5'b10111: sync_period_check_bit_t3 = 1'b0;
    5'b11000: sync_period_check_bit_t3 = 1'b0;
    5'b11001: sync_period_check_bit_t3 = 1'b0;
    5'b11010: sync_period_check_bit_t3 = 1'b0;
    5'b11011: sync_period_check_bit_t3 = 1'b0;
    5'b11100: sync_period_check_bit_t3 = 1'b0;
    5'b11101: sync_period_check_bit_t3 = 1'b0;
    5'b11110: sync_period_check_bit_t3 = 1'b0;
    5'b11111: sync_period_check_bit_t3 = 1'b0;
      default     : sync_period_check_bit_t3 = {1{1'bx}};
    endcase
  end

  assign sync_counter_match_t3 = sync_period_check_bit_t3 & trace_enable_t3;

  assign sync_counter_t3[17:0] = (sync_counter_match_t3 | progbit_fall_t2) ?
                                         {18{1'b0}} :
                                         (sync_counter_t4[17:0] + {{17{1'b0}}, 1'b1});

  assign sync_counter_t3_en = fifo_8bytes_t6_i | progbit_fall_t2 |
                              (sync_counter_match_t3 | sync_counter_match_t4);

  always @(posedge clk_gated)
  begin: usync_counter_t4_17_0
    if (sync_counter_t3_en)
      sync_counter_t4[17:0] <=  sync_counter_t3[17:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: usync_counter_match_t4
    if (!po_reset_n)
      sync_counter_match_t4 <=  1'b0;
    else if (sync_counter_t3_en)
      sync_counter_match_t4 <=  sync_counter_match_t3;
  end



// Complete handshaking for external request
  always @(posedge clk_gated or negedge po_reset_n)
  begin: usync_req_t3
    if (!po_reset_n)
      sync_req_t3 <=  1'b0;
    else
      sync_req_t3 <=  sync_req_t2_i;
  end


// Generate external sync only on rising edge of sync request
  assign external_sync_valid_t2 = trace_enable_t5 & ~os_lock_set_t3 & sync_req_t2_i & ~sync_req_t3;

// Valid signals indicate next request will be used. Cleared if other event occurs.
// Start with both valid after programming. Initial sync for A,I are not pended, must be in order
  assign periodic_sync_valid_t3 = sync_counter_match_t4 |
                                  (periodic_sync_valid_t4 & ~(external_sync_valid_t2 & external_sync_valid_t4)) |
                                  progbit_fall_t2;

  assign external_sync_valid_t3 = external_sync_valid_t2 |
                                  (external_sync_valid_t4 & ~(sync_counter_match_t4 & periodic_sync_valid_t4)) |
                                  progbit_fall_t2;

  assign prevent_force_t3 = ~auxctlr_frc_ovflow_reg_i |
                             sync_overflow        |
                             overflow_state_t3    |
                             wpt_prohibited_t5    |
                             viewinst_idle_req_t3 |
                             context_pkt_en_t3;

  reg  prevent_force_t4;
  
  always @(posedge clk_gated or negedge po_reset_n)
  begin: usync_valid_t4
    if (!po_reset_n) begin
      periodic_sync_valid_t4 <=  1'b0;
      external_sync_valid_t4 <=  1'b0;
      prevent_force_t4       <=  1'b0;
    end
    else begin
      periodic_sync_valid_t4 <=  periodic_sync_valid_t3;
      external_sync_valid_t4 <=  external_sync_valid_t3;
      prevent_force_t4       <=  prevent_force_t3;
    end
  end


// Periodic synchronization request
  assign sync_periodic_req_t3 = (periodic_sync_valid_t4 & sync_counter_match_t4 & ~overflow_state_t4) |
                                (external_sync_valid_t4 & external_sync_valid_t2);

  // Missing timestamp is not a justification for overflow
  assign sync_overflow = trace_active_t6 & trace_active_t7 &
                          ~prevent_force_t4 & 
                         ((periodic_sync_valid_t4 & sync_counter_match_t4) |
                          (ext_sync_pend_and_active_t4 & external_sync_valid_t4 & external_sync_valid_t2)) &
                         (periodic_async_pend_t4);

// Only take care of external requests for overflow if there was at least one request while trace was enabled.
// 2nd request co-incident with async_req_t3 should be dropped, use t4 for better timing
  assign ext_sync_pend_t3 = external_sync_valid_t4 & external_sync_valid_t2 |
                            (ext_sync_pend_t4 & ~(async_req_t3 | async_req_t4 | ~trace_enable_t5));

// Timestamp overflow tracking
  assign sync_sequence_complete_t3   = ts_output_en_t3 | ts_output_en_t4 |
                                       ((async_req_t3 | async_req_t4) & ~timestamp_en_reg_i);

  assign ext_sync_pend_and_active_t3 = (ext_sync_pend_t3 & trace_active_t4 & ~wfx_state_t4 & (ts_valid_t4 | ~timestamp_en_reg_i)) |
                                       (ext_sync_pend_and_active_t4 & ~gov_wfx_drain_req_t2 & ~(sync_sequence_complete_t3 |
                                                                        ~trace_enable_t5 | set_overflow_t3));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: usync_pend_t4
    if (!po_reset_n) begin
      ext_sync_pend_t4            <=  1'b0;
      ext_sync_pend_and_active_t4 <=  1'b0;
      first_sync_t3               <=  1'b0;
    end
    else begin
      ext_sync_pend_t4            <=  ext_sync_pend_t3;
      ext_sync_pend_and_active_t4 <=  ext_sync_pend_and_active_t3;
      first_sync_t3               <= first_sync_t2;
    end
  end


// Delay insertion of synchronization packets when trace activity is high
// delay until fifo has less than 28 bytes
// First sync must not be delayed
  assign first_sync_t2     = ~trace_enable_t2 | (first_sync_t3 & ~async_req_t3);
  assign sync_insert_valid = (~fifo_level28_t7_i) | ~auxctlr_frc_sync_delay_reg_i | first_sync_t3;

//---------------------------------------------------------------------------
// Trace gen idle handling
//   viewinst_idle_req_t2_i is asserted for the idle request
//   trcgen_idle_ack_o is one cycle pulse after trace gen ready to go idle
//   viewinst_idle_req_t2_i will go low immediately after ack
//---------------------------------------------------------------------------

  always @*
  begin
    case(trace_idle_state_t3)
      CA53_ETM_GENIDLE_ST_IDLE:      trace_idle_state_t2 = viewinst_idle_req_t2_i ? CA53_ETM_GENIDLE_ST_CNT :
                                                                                    CA53_ETM_GENIDLE_ST_IDLE;
      CA53_ETM_GENIDLE_ST_CNT:       trace_idle_state_t2 = ~viewinst_idle_req_t2_i ? CA53_ETM_GENIDLE_ST_IDLE     : 
                                           ((~fifo_empty_i & (set_overflow_t3 | overflow_state_t4))  ? CA53_ETM_GENIDLE_ST_OVERFLOW :
                                                         (&trace_idle_state_cnt_t3 ? CA53_ETM_GENIDLE_ST_ACK      :
                                                                                     CA53_ETM_GENIDLE_ST_CNT));
      CA53_ETM_GENIDLE_ST_OVERFLOW:  trace_idle_state_t2 = fifo_empty_i ? 
                                                           (viewinst_idle_req_t2_i ? CA53_ETM_GENIDLE_ST_CNT : CA53_ETM_GENIDLE_ST_IDLE):
                                                                                     CA53_ETM_GENIDLE_ST_OVERFLOW;
      CA53_ETM_GENIDLE_ST_ACK:       trace_idle_state_t2 = CA53_ETM_GENIDLE_ST_IDLE;
      default     :                  trace_idle_state_t2[1:0] = {2{1'bx}};
    endcase
  end
  // end of Macro CASE

  assign trcgen_idle_ack_o      = (trace_idle_state_t2 == CA53_ETM_GENIDLE_ST_ACK);
  assign idle_overflow_state_t3 = trace_idle_state_t3 == CA53_ETM_GENIDLE_ST_OVERFLOW;
  
  // In overflow, count up to half-way point to allow for delayed events in wfx
  // Idle request term aligned with async term for idle
  assign trace_idle_state_cnt_t2 = (trace_idle_state_t3 != CA53_ETM_GENIDLE_ST_CNT) ? 
                                   ({4{idle_overflow_state_t3 & viewinst_idle_req_t3}} & (trace_idle_state_cnt_t3 + {3'b000,~trace_idle_state_cnt_t3[3]})):
                                   (trace_idle_state_cnt_t3 + 4'b0001);
  assign trace_idle_state_cnt_en = (trace_idle_state_t2 != CA53_ETM_GENIDLE_ST_IDLE) | (|trace_idle_state_cnt_t3);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_idle_state_t3
    if (!po_reset_n)
      trace_idle_state_t3 <= CA53_ETM_GENIDLE_ST_IDLE;
    else
      trace_idle_state_t3 <= trace_idle_state_t2;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_idle_state_cnt_t3
    if (!po_reset_n)
      trace_idle_state_cnt_t3 <= {4{1'b0}};
    else if (trace_idle_state_cnt_en)
      trace_idle_state_cnt_t3 <= trace_idle_state_cnt_t2;
  end

//---------------------------------------------------------------------------
// Overflow PACKET
//---------------------------------------------------------------------------
// overflow packet is generated before trace info / trace on in the FIFO module
  assign ovfl_req_t2_o      = set_overflow_t3 & ~overflow_state_t4;


//---------------------------------------------------------------------------
// ASYNC PACKET
//---------------------------------------------------------------------------

// Async packet is a special packet which is inserted in the fifo directly
//   periodic Async pending is set
//   When trace is first enabled
//   after overflow
  assign periodic_async_pend_t3 = ((periodic_async_pend_t4 | sync_periodic_req_t3) & trace_enable_tx & ~viewinst_idle_req_t3) &
                                  ~async_req_t3 & ~async_req_t4;
  
  assign async_pend_t3 = ( (sync_periodic_req_t3 & trace_enable_tx & ~viewinst_idle_req_t3) |
                            async_trace_enable_t2 |
                            set_overflow_t4 |
                           (gov_wfx_drain_req_t2 & ~gov_wfx_drain_req_t1) |
                           (async_pend_t4  & trace_enable_tx)
                         ) &
                         ~async_req_t3;

  assign async_trace_enable_t2 = ~trace_enable_t3 & trace_enable_t2;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_pend_t4
    if (!po_reset_n)
      begin
        periodic_async_pend_t4 <= 1'b0;
        async_pend_t4          <=  1'b0;
      end
    else
      begin
        periodic_async_pend_t4 <= periodic_async_pend_t3;
        async_pend_t4          <= async_pend_t3;
      end
  end

  assign async_req_t3 =   ((~overflow_state_t4     &                                              // Fifo not in overflow
                            async_pend_t4          &                                              // Pending Async request
                            sync_insert_valid      &                                              // Can delay sync due to fifo depth
                            ~excep_pkt_gen_t3      &                                              // Exception pkt conflict with trace info
                            ~set_overflow_t3) |                                                   // Overflow
                             go_to_trace_overflow_idle) &
                             trace_enable_t2       &
                           (~viewinst_idle_req_t3 | overflow_state_t5) &                          // Event leaving overflow needs async
                            ~|trace_idle_state_cnt_t3[3:2];                                       // First sync should still be output

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_req_t4
    if (!po_reset_n)
      async_req_t4 <=  1'b0;
    else
      async_req_t4 <=  async_req_t3;
  end

  assign async_req_t4_o = async_req_t4 & ~set_overflow_t3;

//---------------------------------------------------------------------------
// Trace Info PACKET - Always output at the same time as async
//---------------------------------------------------------------------------

  assign trace_info_pkt_header[7:0]   = 8'b0000_0001;

  assign trace_info_pkt_plctl_t3[7:0] = {4'b0000, cycle_counting_reg_i, 3'b001};

  assign trace_info_pkt_info_t3[7:0]  = {7'b0000000, cycle_counting_reg_i} ;

  assign trace_info_pkt_cyct0_t3[7:0] = {trace_info_pkt_cyct1_en_t3, cc_threshold_reg_i[6:0]} ;
  assign trace_info_pkt_cyct1_t3[7:0] = {3'b000, cc_threshold_reg_i[11:7]} ;
  assign trace_info_pkt_cyct0_en_t3   = trace_info_pkt_en_t3 & cycle_counting_reg_i;
  assign trace_info_pkt_cyct1_en_t3   = trace_info_pkt_cyct0_en_t3 & |cc_threshold_reg_i[11:7];
  assign trace_info_pkt_en_t3         = async_req_t3;

//---------------------------------------------------------------------------
// Trace On PACKET
//---------------------------------------------------------------------------

// Trace On is generated when
// 1. trace overflow happened
// 2. trace goes from inactive to active
  assign trace_on_pkt_en_t3 = ((wpt_syserr_t3 | wpt_reset_t3) & ((trace_state_t4[1:0] == CA53_ETM_GEN_ST_IDLE) |
                                                                 (ovfl_idle_state_t4))) |
                              (trace_active_t3 & ~trace_active_t4);

  assign trace_turnon_t3 = trace_active_t3 & ~trace_active_t4;

//---------------------------------------------------------------------------
// TIMESTAMP PACKET
//---------------------------------------------------------------------------

// Timestamp packet is generated on timestamp request only if
// 1) we are currently tracing or
// 2) if it is the first request after tracing is turned off

// TS Event Register

  always @(posedge clk_gated)
  begin: uts_event_t3
    if (timestamp_en_reg_i)
      ts_event_t3 <=  ts_event_t2_i;
  end

// Partial timestamp is output for first request after tracing stops
// Partial timestamp is meaningless after overflow.
  assign ts_valid_t3 = (ts_valid_t4 | ts_value_en_t2) &
                        timestamp_en_reg_i & ~ts_output_en_t3 & ~set_overflow_t4 & ~trace_idle_state_cnt_t3[3];

  assign ts_part_pend_t3 = ts_valid_t3 & ~overflow_state_t5 &
                           (
                            (
                               (((wpt_type_t4[2:0] == `CA53_ETM_WPT_ISB) & wpt_valid_noprog_t4)         |
                                 excep_pkt_gen_t3                                                       |
                                ((wpt_type_t4[2:0] == `CA53_ETM_WPT_EXCP_RETURN) & wpt_valid_noprog_t4) |
                                 ts_event_t3                                                            |
                                 fifo_flush_req_i
                               )
                             ) |
                            (trace_enable_t4 &  viewinst_idle_req_t2_i) |
                            (ts_part_pend_t4 & ~ts_output_en_t3)
                            );

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_part_q
    if (!po_reset_n) begin
      ts_part_pend_t4 <=  1'b0;
      ts_valid_t4     <=  1'b0;
    end
    else begin
      ts_part_pend_t4 <=  ts_part_pend_t3;
      ts_valid_t4     <=  ts_valid_t3;
    end
  end

// Full timestamp is only required after overflow, new session or periodic request.
// Will not be output until after Isync. Ignore periodic request after progbit set.
  assign ts_full_pend_t3 = timestamp_en_reg_i & ~overflow_state_t5 &
                           (trace_info_pkt_en_t3 |
                            overflow_state_t6    |
                            (ts_full_pend_t4 & ~ts_output_en_t3)
                           );

// Full timestamp is possible only after periodic Isync is generated. When starting, Isyncs in t3 are seen whilst still off.
// Periodic synchronisation request while tracing implies new Isync is needed before Tsync

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_full_q
    if (!po_reset_n) begin
      ts_full_pend_t4     <=  1'b0;
    end
    else begin
      ts_full_pend_t4     <=  ts_full_pend_t3;
    end
  end


// TS packet should not be inserted just when OSLock is about to be cleared
// TS packet will need to be delayed until the async packet is output
  assign ts_ready_t3 = (ts_full_pend_t4 | ts_part_pend_t4 ) &
                       ts_valid_t4;

// Delay timestamp until periodic async and isync packets have been output
  assign ts_stall_t3 = (async_pend_t3 & viewinst_en_t4) & ~overflow_state_t4;

// Delay timestamp until Isync has been seen in t4, as this allows a full timestamp to be used if needed.
  assign ts_pipe_t3 = trace_info_pkt_en_t3;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uidle_req
    if (!po_reset_n) begin
      gov_wfx_drain_req_t1 <=  1'b0;
      gov_wfx_drain_req_t2 <=  1'b0;
      wfx_state_t4         <=  1'b0;
      trace_req_t1         <=  1'b0;
      trace_req_t2         <=  1'b0;
    end
    else begin
      gov_wfx_drain_req_t1 <=  gov_wfx_drain_req_i;
      gov_wfx_drain_req_t2 <=  gov_wfx_drain_req_t1;
      wfx_state_t4         <=  wfx_state_t3;
      trace_req_t1         <=  trace_req_t0_i;
      trace_req_t2         <=  trace_req_t1;
    end
  end

  assign gov_wfx_drain_req_t2_o = gov_wfx_drain_req_t2;

// low power mode request ignored but a FIFO flush request will be generated for the
// first wfx request cycle
  assign low_power_override_flush_o = gov_wfx_drain_req_t1 & ~gov_wfx_drain_req_t2 & lp_override_reg_i & trace_enable_t2;

  assign wfx_state_t3     = (wfx_state_t4 | (gov_wfx_drain_req_t2  & ~lp_override_reg_i & trace_active_t3)) &
                            trace_req_t2 & ~wpt_valid_t3;

// Avoid back-to-back timestamps (may need to recover an Isync)
// When not tracing, wait if there is a packet stored in T4, except when ending a session.
  assign ts_output_en_pend_int_t3 = ts_ready_t3  &
                                   ~ts_stall_t3  &
                                   ~ts_pipe_t3;

// This will prevent the fifo from draining.
  assign ts_output_en_pend_t3_o = ts_output_en_pend_int_t3 | overflow_supress;

//  Timestamp must be delayed to avoid conflict with other packets
//  When a timestamp is captured in the current cycle, tracing it must be
//  stalled to allow time for the packet to be updated
  assign ts_output_en_poss_t3 = ts_output_en_pend_int_t3 &
                               ~trace_on_pkt_en_t3      &
                               ~trace_on_pkt_en_t4      &
                               ~valid_branch_packet_t3  &
                               ~context_pkt_en_t3       &
                               ~overflow_supress  &
                               ~overflow_state_t4 &
                               ~ts_output_en_t4   &
                               ~cc_pkt_b0_en_t3   &           // CC for atom needs to come first
                               ~excep_pkt_gen_t3           & // New timestamp except for event related.
                               ~trace_idle_state_cnt_t3[3] &         // final drain state, after overflow
                              (~(fifo_level28_t7_i & ~auxctlr_frc_ts_nodelay_reg_i) | (&trace_idle_state_cnt_t3[1:0]));
  
  assign overflow_supress    = set_overflow_t3 | set_overflow_t4 | set_overflow_t5;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_output_en_t4
    if (!po_reset_n)
      ts_output_en_poss_t4 <=  1'b0;
    else
      ts_output_en_poss_t4 <=  ts_output_en_poss_t3;
  end

  assign ts_output_en_t4 = ts_output_en_poss_t4 & ~cc_pkt_b0_en_t3;
  
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_value_t3_63_0
    if (!po_reset_n)
      ts_value_t3[63:0] <=  {64{1'b0}};
    else if (ts_value_en_t2)
      ts_value_t3[63:0] <=  gov_tsvalueb_i[63:0];
  end


// Capture TS Value when a waypoint is traced
//   atom
//   exception
//   event
  assign ts_value_en_t2 = excep_pkt_gen_t3 |
                          valid_atom_t4    |
                          event_pkt_en_t3;

  assign ts_value_masked_t3[63:0] = {64{trace_enable_t5}} & ts_value_t3[63:0];

  assign ts_full_en_t3 = ts_full_pend_t4;

  assign ts_byte2_t3_en = (|(ts_value_masked_t3[13:7 ] ^ ts_last_t4[13:7 ]) | ts_byte3_t3_en | ts_full_en_t3);
  assign ts_byte3_t3_en = (|(ts_value_masked_t3[20:14] ^ ts_last_t4[20:14]) | ts_byte4_t3_en | ts_full_en_t3);
  assign ts_byte4_t3_en = (|(ts_value_masked_t3[27:21] ^ ts_last_t4[27:21]) | ts_byte5_t3_en | ts_full_en_t3);
  assign ts_byte5_t3_en = (|(ts_value_masked_t3[34:28] ^ ts_last_t4[34:28]) | ts_byte6_t3_en | ts_full_en_t3);
  assign ts_byte6_t3_en = (|(ts_value_masked_t3[41:35] ^ ts_last_t4[41:35]) | ts_byte7_t3_en | ts_full_en_t3);
  assign ts_byte7_t3_en = (|(ts_value_masked_t3[48:42] ^ ts_last_t4[48:42]) | ts_byte8_t3_en | ts_full_en_t3);
  assign ts_byte8_t3_en = (|(ts_value_masked_t3[55:49] ^ ts_last_t4[55:49]) | ts_byte9_t3_en | ts_full_en_t3);
  assign ts_byte9_t3_en = (|(ts_value_masked_t3[63:56] ^ ts_last_t4[63:56]) | ts_full_en_t3);
  assign ts_bytea_t3_en = |wpt_cycle_counter_t4[11:0];
  assign ts_byteb_t3_en = |wpt_cycle_counter_t4[11:7];

  assign ts_byte0_cc_bit_t3 = (|wpt_cycle_counter_t4[11:0]);
  assign ts_byte1_t3[7:0] = {ts_byte2_t3_en, ts_value_masked_t3[6:0]};
  assign ts_byte2_t3[7:0] = {ts_byte3_t3_en, ts_value_masked_t3[13:7]};
  assign ts_byte3_t3[7:0] = {ts_byte4_t3_en, ts_value_masked_t3[20:14]};
  assign ts_byte4_t3[7:0] = {ts_byte5_t3_en, ts_value_masked_t3[27:21]};
  assign ts_byte5_t3[7:0] = {ts_byte6_t3_en, ts_value_masked_t3[34:28]};
  assign ts_byte6_t3[7:0] = {ts_byte7_t3_en, ts_value_masked_t3[41:35]};
  assign ts_byte7_t3[7:0] = {ts_byte8_t3_en, ts_value_masked_t3[48:42]};
  assign ts_byte8_t3[7:0] = {ts_byte9_t3_en, ts_value_masked_t3[55:49]};
  assign ts_byte9_t3[7:0] = {ts_value_masked_t3[63:56]};
  assign ts_bytea_t3[7:0] = {ts_byteb_t3_en, wpt_cycle_counter_t4[6:0]};
  assign ts_byteb_t3[4:0] = {wpt_cycle_counter_t4[11:7]};

// Compression scheme requires old value.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_last_t4_63_7
    if (!po_reset_n)
      ts_last_t4[63:7] <=  {57{1'b0}};
    else if (ts_value_update_t3)
      ts_last_t4[63:7] <=  ts_value_masked_t3[63:7];
  end

 assign ts_value_update_t3 = (ts_output_en_t3 & ~cc_pkt_b0_en_t2) | (trace_enable_t5 & ~trace_enable_t4);

//---------------------------------------------------------------------------
// VALID PACKET TYPES CONTROL LOGIC
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Packet Type Output Enables.

  assign valid_atom_packet_t4      = (trace_active_t4 | trace_active_en_t5)  & atom_pkt_gen_t4;
  assign valid_curr_atom_packet_t4 = (trace_active_t4 | trace_active_en_t5)  & curr_atom_pkt_gen_t4;



//---------------------------------------------------------------------------
// VALID PACKET NUMBER OF BYTES COUNT LOGIC
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Number of bytes in First 8


// Use this to calculate pre-rotation in the fifo
// overflow or trace info

 assign num_first8_info_t3[2:0] = (trace_info_pkt_cyct1_en_t3)? 3'b101 :
                                  (trace_info_pkt_cyct0_en_t3)? 3'b100 :
                                  (trace_info_pkt_en_t3)?       3'b011 :
                                                                3'b000 ;


 assign num_first8_t3[2:0] =       num_first8_info_t3[2:0] +
                                   {2'b00, event_pkt_en_t3} +
                                   {1'b0 , excep_pkt_gen_t3, 1'b0} +
                                   {2'b00, valid_atom_packet_t4};

 assign numb_bytes_first8_update_t3 = excep_pkt_gen_t3     |
                                      trace_info_pkt_en_t3 |
                                      event_pkt_en_t3      |
                                      valid_atom_packet_t4 |
                                      (trace_idle_state_t2 != CA53_ETM_GENIDLE_ST_IDLE);

assign numb_bytes_first8_update_en_t3 = trace_enable_t5 | trace_enable_t4 | trace_enable_tx;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: unumb_bytes_first8_update_t4
    if (!po_reset_n)
      numb_bytes_first8_update_t4 <=  1'b0;
    else if (numb_bytes_first8_update_en_t3)
      numb_bytes_first8_update_t4 <=  numb_bytes_first8_update_t3;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: unum_first8_t4_2_0
    if (!po_reset_n)
      num_first8_t4[2:0] <=  {3{1'b0}};
    else if (numb_bytes_first8_update_t3)
      num_first8_t4[2:0] <=  num_first8_t3[2:0];
  end

  // After overflow, stored event packet must be suppressed (goes seperately to fifo on prev cycle)
  assign num_first8_true_t4[2:0] = num_first8_t4[2:0] & {3{numb_bytes_first8_update_t4 & ~overflow_state_t4}};

//---------------------------------------------------------------------------
// Total Number of bytes


// Number of bytes in TimeStamp packet.
  // here's the pla table sent to espresso:
  //
  // ts_byteb_t3_en
  // | ts_bytea_t3_en
  // | | ts_byte9_t3_en
  // | | | ts_byte8_t3_en
  // | | | | ts_byte7_t3_en
  // | | | | | ts_byte6_t3_en
  // | | | | | | ts_byte5_t3_en
  // | | | | | | | ts_byte4_t3_en
  // | | | | | | | | ts_byte3_t3_en
  // | | | | | | | | | ts_byte2_t3_en
  // | | | | | | | | | | ts_num_bytes_t3[3:0]
  // | | | | | | | | | | |
  // 0 0 0 0 0 0 0 0 0 0 0010
  // 0 0 0 0 0 0 0 0 0 1 0011
  // 0 0 0 0 0 0 0 0 1 - 0100
  // 0 0 0 0 0 0 0 1 - - 0101
  // 0 0 0 0 0 0 1 - - - 0110
  // 0 0 0 0 0 1 - - - - 0111
  // 0 0 0 0 1 - - - - - 1000
  // 0 0 0 1 - - - - - - 1001
  // 0 0 1 - - - - - - - 1010
  // 0 1 0 0 0 0 0 0 0 0 0011
  // 0 1 0 0 0 0 0 0 0 1 0100
  // 0 1 0 0 0 0 0 0 1 - 0101
  // 0 1 0 0 0 0 0 1 - - 0110
  // 0 1 0 0 0 0 1 - - - 0111
  // 0 1 0 0 0 1 - - - - 1000
  // 0 1 0 0 1 - - - - - 1001
  // 0 1 0 1 - - - - - - 1010
  // 0 1 1 - - - - - - - 1011
  // 1 - 0 0 0 0 0 0 0 0 0100
  // 1 - 0 0 0 0 0 0 0 1 0101
  // 1 - 0 0 0 0 0 0 1 - 0110
  // 1 - 0 0 0 0 0 1 - - 0111
  // 1 - 0 0 0 0 1 - - - 1000
  // 1 - 0 0 0 1 - - - - 1001
  // 1 - 0 0 1 - - - - - 1010
  // 1 - 0 1 - - - - - - 1011
  // 1 - 1 - - - - - - - 1100
  // default:
  //
  // the following equations are the espresso output

  assign ts_num_bytes_t3[3] = (ts_byteb_t3_en&!ts_byte9_t3_en&!ts_byte7_t3_en
    &ts_byte6_t3_en) | (!ts_bytea_t3_en&!ts_byte9_t3_en&ts_byte8_t3_en) | (
    ts_bytea_t3_en&!ts_byte9_t3_en&ts_byte8_t3_en) | (ts_byteb_t3_en
    &ts_byte5_t3_en) | (ts_bytea_t3_en&ts_byte6_t3_en) | (ts_byteb_t3_en
    &ts_byte9_t3_en) | (!ts_byteb_t3_en&ts_byte9_t3_en) | (
    ts_byte7_t3_en);

  assign ts_num_bytes_t3[2] = (ts_bytea_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en&ts_byte2_t3_en) | (
    !ts_bytea_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en
    &!ts_byte6_t3_en&!ts_byte5_t3_en&ts_byte4_t3_en) | (ts_bytea_t3_en
    &!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en&!ts_byte6_t3_en
    &!ts_byte5_t3_en&ts_byte4_t3_en) | (!ts_byte9_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en&ts_byte3_t3_en) | (
    !ts_byteb_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en
    &!ts_byte6_t3_en&ts_byte5_t3_en) | (ts_byteb_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en) | (!ts_byteb_t3_en
    &!ts_bytea_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en
    &ts_byte6_t3_en) | (ts_byteb_t3_en&ts_byte9_t3_en);

  assign ts_num_bytes_t3[1] = (!ts_byteb_t3_en&ts_bytea_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte4_t3_en&!ts_byte3_t3_en
    &!ts_byte2_t3_en) | (!ts_byteb_t3_en&!ts_bytea_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte4_t3_en&!ts_byte3_t3_en) | (ts_bytea_t3_en
    &!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en&!ts_byte6_t3_en
    &!ts_byte5_t3_en&ts_byte4_t3_en) | (!ts_byteb_t3_en&!ts_byte9_t3_en
    &!ts_byte8_t3_en&!ts_byte7_t3_en&!ts_byte6_t3_en&ts_byte5_t3_en) | (
    ts_byteb_t3_en&!ts_byte9_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en
    &ts_byte3_t3_en) | (ts_byteb_t3_en&!ts_byte9_t3_en&!ts_byte7_t3_en
    &!ts_byte6_t3_en&!ts_byte5_t3_en&ts_byte4_t3_en) | (!ts_byteb_t3_en
    &!ts_bytea_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en&!ts_byte7_t3_en
    &ts_byte6_t3_en) | (ts_byteb_t3_en&!ts_byte9_t3_en&ts_byte7_t3_en) | (
    ts_bytea_t3_en&!ts_byte9_t3_en&ts_byte8_t3_en) | (ts_byteb_t3_en
    &!ts_byte9_t3_en&ts_byte8_t3_en) | (!ts_byteb_t3_en&ts_byte9_t3_en);

  assign ts_num_bytes_t3[0] = (!ts_byteb_t3_en&ts_bytea_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte4_t3_en&!ts_byte3_t3_en
    &!ts_byte2_t3_en) | (!ts_byteb_t3_en&ts_bytea_t3_en&!ts_byte8_t3_en
    &!ts_byte6_t3_en&!ts_byte4_t3_en&ts_byte3_t3_en) | (!ts_bytea_t3_en
    &!ts_byte9_t3_en&!ts_byte7_t3_en&!ts_byte5_t3_en&!ts_byte3_t3_en
    &ts_byte2_t3_en) | (!ts_bytea_t3_en&!ts_byte9_t3_en&!ts_byte8_t3_en
    &!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en&ts_byte4_t3_en) | (
    ts_byteb_t3_en&!ts_byte9_t3_en&!ts_byte7_t3_en&!ts_byte5_t3_en
    &!ts_byte3_t3_en&ts_byte2_t3_en) | (!ts_byteb_t3_en&ts_bytea_t3_en
    &!ts_byte8_t3_en&!ts_byte6_t3_en&ts_byte5_t3_en) | (ts_byteb_t3_en
    &!ts_byte9_t3_en&!ts_byte7_t3_en&!ts_byte6_t3_en&!ts_byte5_t3_en
    &ts_byte4_t3_en) | (!ts_byteb_t3_en&!ts_bytea_t3_en&!ts_byte9_t3_en
    &!ts_byte8_t3_en&!ts_byte7_t3_en&ts_byte6_t3_en) | (!ts_byteb_t3_en
    &ts_bytea_t3_en&!ts_byte8_t3_en&ts_byte7_t3_en) | (!ts_byteb_t3_en
    &ts_bytea_t3_en&ts_byte9_t3_en) | (ts_byteb_t3_en&!ts_byte9_t3_en
    &!ts_byte7_t3_en&ts_byte6_t3_en) | (!ts_bytea_t3_en&!ts_byte9_t3_en
    &ts_byte8_t3_en) | (ts_byteb_t3_en&!ts_byte9_t3_en&ts_byte8_t3_en);



// Number of bytes in Context packet
// the last byte of cbit is in pack4
  assign cid_numb_bytes_t3[2:0] = (context_pkt_en_t3)? 3'b001 + {2'b00,context_payld_t3} + {2'b00, context_vbit_t3} + {context_cbit_t3, 2'b00} -
                                                       {2'b00, (valid_branch_packet_t3 & ~address_exact_match_t3)}:
                                                       3'b000;

// Address packet
  assign num_addr_bytes_t3[3:0] = (br_addr_byte4567_en_t3) ? 4'b1001 :
                                  (br_addr_byte3_en_t3) ?    4'b0101 :
                                  (br_addr_byte2_en_t3) ?    4'b0100 :
                                  (br_addr_byte1_en_t3) ?    4'b0011 :
                                  (br_addr_byte0_en_t3) ?    4'b0010 :
                                                             4'b0001 ;

// Cycle count packet
  assign num_cycle_bytes_t3[1:0] = cc_pkt_b2_en_t3 ? 2'b11 :
                                   cc_pkt_b1_en_t3 ? 2'b10 :
                                   cc_pkt_b0_en_t3 ? 2'b01 :
                                                     2'b00;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: unum_byte_q
    if (!po_reset_n) begin
      ts_num_bytes_t4           <=  {4{1'b0}};
      pack16_bytes_part_t4[4:0] <=  {5{1'b0}};
      pack4_num_bytes_t4[2:0]   <=  {3{1'b0}};
      valid_curr_atom_packet_t5 <=  1'b0;
    end
    else begin
      ts_num_bytes_t4           <=  ts_num_bytes_t3;
      pack16_bytes_part_t4[4:0] <=  pack16_bytes_part_t3[4:0];
      pack4_num_bytes_t4[2:0]   <=  pack4_num_bytes_t3[2:0];
      valid_curr_atom_packet_t5 <=  valid_curr_atom_packet_t4;
    end
  end
  assign ts_pack4_num_bytes_t4     =  ts_output_en_t4 ? {2'b00, valid_curr_atom_packet_t5} :
                                       pack4_num_bytes_t4;
  
  assign pack16_bytes_part_t3[4:0] = ({4'b0000, trace_on_pkt_en_t3} +
                                      {4'b0000, valid_curr_atom_packet_t4} +
                                      ({1'b0, num_addr_bytes_t3[3:0]} & {5{valid_branch_packet_t3}}) +
                                      {2'b00, cid_numb_bytes_t3[2:0]});

  assign pack16_bytes_in_t4[4:0] =  ts_output_en_t4 ? {1'b0, ts_num_bytes_t4[3:0]} : pack16_bytes_part_t4;

  assign pack4_num_bytes_t3[2:0] =  {1'b0, num_cycle_bytes_t3[1:0]} + {2'b00, valid_excp_return_out_t4};

  assign num_bytes_t4[4:0] = {2'b00,num_first8_true_t4[2:0]} + {2'b00,ts_pack4_num_bytes_t4[2:0]} + pack16_bytes_in_t4[4:0];

//---------------------------------------------------------------------------
// VALID DATA FOR DIFFERENT PACKETS
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------

  // 2 spare lanes not used here.
  // Currently event packets are before or after atom to reduce number of lane paths needed
  always @*
  begin
    case({excep_pkt_gen_t3, trace_info_pkt_en_t3, trace_info_pkt_cyct1_en_t3, trace_info_pkt_cyct0_en_t3, event_pkt_en_t3})
          `ca53etm_sel_00000: first_8_t3[63:16] = {atom_pkt_t3[7:0], {40{1'b0}}};
          `ca53etm_sel_00001: first_8_t3[63:16] = {event_pkt_t3[7:0], atom_pkt_t3[7:0], {32{1'b0}}};
          `ca53etm_sel_10000: first_8_t3[63:16] = {excep_pkt_byte_t3[7:0], excep_pkt_header_t3[7:0], atom_pkt_t3[7:0], {24{1'b0}}};
          `ca53etm_sel_10001: first_8_t3[63:16] = {excep_pkt_byte_t3[7:0], excep_pkt_header_t3[7:0], event_pkt_t3[7:0], atom_pkt_t3[7:0],
                                        {16{1'b0}}};
          `ca53etm_sel_01000: first_8_t3[63:16] = {trace_info_pkt_info_t3[7:0], trace_info_pkt_plctl_t3[7:0], trace_info_pkt_header[7:0],
                                        atom_pkt_t3[7:0], {16{1'b0}}};
          `ca53etm_sel_01001: first_8_t3[63:16] = {event_pkt_t3[7:0],trace_info_pkt_info_t3[7:0], trace_info_pkt_plctl_t3[7:0],
                                        trace_info_pkt_header[7:0], atom_pkt_t3[7:0], {8{1'b0}}};
          `ca53etm_sel_01010: first_8_t3[63:16] = {trace_info_pkt_cyct0_t3[7:0], trace_info_pkt_info_t3[7:0], trace_info_pkt_plctl_t3[7:0],
                                        trace_info_pkt_header[7:0], atom_pkt_t3[7:0], {8{1'b0}}};
          `ca53etm_sel_01011: first_8_t3[63:16] = {event_pkt_t3[7:0], trace_info_pkt_cyct0_t3[7:0], trace_info_pkt_info_t3[7:0],
                                        trace_info_pkt_plctl_t3[7:0], trace_info_pkt_header[7:0], atom_pkt_t3[7:0]};
          `ca53etm_sel_01110: first_8_t3[63:16] = {trace_info_pkt_cyct1_t3[7:0], trace_info_pkt_cyct0_t3[7:0], trace_info_pkt_info_t3[7:0],
                                        trace_info_pkt_plctl_t3[7:0], trace_info_pkt_header[7:0], atom_pkt_t3[7:0]};
          `ca53etm_sel_011x1: first_8_t3[63:16] = {event_pkt_t3[7:0], trace_info_pkt_cyct1_t3[7:0], trace_info_pkt_cyct0_t3[7:0],
                                        trace_info_pkt_info_t3[7:0], trace_info_pkt_plctl_t3[7:0], trace_info_pkt_header[7:0]};
      default      : first_8_t3[63:16] = {48{1'bx}};
    endcase
  end

  // bit [19] always zero
  assign packed_first_8_t3[46: 3] = first_8_t3[63:20];
  assign packed_first_8_t3[ 2: 0] = first_8_t3[18:16];

  assign update_bytes_en_t3 = wpt_valid_noprog_t4 | trace_active_t5 | trace_info_pkt_en_t3 | event_pkt_en_t3 | trace_on_pkt_en_t3 |
                              valid_branch_packet_t3 | context_pkt_en_t3;

  always @(posedge clk_gated)
  begin: ubytes_t4
    if (update_bytes_en_t3) begin
      packed_first_8_t4 <= packed_first_8_t3;
      
    end
  end
//---------------------------------------------------------------------------
// TimeStamp Packet Bytes.
  assign ts_bytes_t3[84:0] = {ts_byteb_t3[4:0], ts_bytea_t3[7:0],
                              ts_byte9_t3[7:0], ts_byte8_t3[7:0], ts_byte7_t3[7:0], ts_byte6_t3[7:0], ts_byte5_t3[7:0],
                              ts_byte4_t3[7:0], ts_byte3_t3[7:0], ts_byte2_t3[7:0], ts_byte1_t3[7:0]};



//---------------------------------------------------------------------------
// PACK DATA CONTROL LOGIC
//---------------------------------------------------------------------------




// Determine packed positions.
  assign byte_0_valid_t3 =  trace_on_pkt_en_t3                                                       |  (valid_curr_atom_packet_t4 & ~ts_output_en_t3);
  assign byte_1_valid_t3 =  valid_branch_packet_t3                                                   |  ts_output_en_t3;
  assign byte_2_valid_t3 = (valid_branch_packet_t3 & br_addr_byte0_en_t3)                            |  ts_output_en_t3;
  assign byte_3_valid_t3 = (valid_branch_packet_t3 & br_addr_byte1_en_t3)                            | (ts_output_en_t3 & ts_byte2_t3_en);
  assign byte_4_valid_t3 = (valid_branch_packet_t3 & br_addr_byte2_en_t3)                            | (ts_output_en_t3 & ts_byte3_t3_en);
  assign byte_5_valid_t3 = (valid_branch_packet_t3 & br_addr_byte3_en_t3)                            | (ts_output_en_t3 & ts_byte4_t3_en);
  assign byte_6_valid_t3 = (valid_branch_packet_t3 & br_addr_byte4567_en_t3)                         | (ts_output_en_t3 & ts_byte5_t3_en);
  assign byte_7_valid_t3 = (valid_branch_packet_t3 & br_addr_byte4567_en_t3)                         | (ts_output_en_t3 & ts_byte6_t3_en);
  assign byte_8_valid_t3 = (valid_branch_packet_t3 & br_addr_byte4567_en_t3)                         | (ts_output_en_t3 & ts_byte7_t3_en);
  assign byte_9_valid_t3 = (context_pkt_en_t3 & ~(valid_branch_packet_t3 & ~address_exact_match_t3)) |
                                (valid_branch_packet_t3 & br_addr_byte4567_en_t3) |
                                (ts_output_en_t3 & ts_byte8_t3_en);
  assign byte_a_valid_t3 = (context_pkt_en_t3 & context_payld_t3)                                    | (ts_output_en_t3 & ts_byte9_t3_en);
  assign byte_b_valid_t3 = (context_pkt_en_t3 & context_vbit_t3)                                     | (ts_output_en_t3 & ts_bytea_t3_en);
  assign byte_c_valid_t3 = (context_pkt_en_t3 & context_cbit_t3)                                     | (ts_output_en_t3 & ts_byteb_t3_en);
  assign byte_d_valid_t3 =  context_pkt_en_t3 & context_cbit_t3;
  assign byte_e_valid_t3 =  context_pkt_en_t3 & context_cbit_t3;
  assign byte_f_valid_t3 =  context_pkt_en_t3 & context_cbit_t3;

  assign final_16_1_t3a      = byte_0_valid_t3;
  assign final_16_2_t3a      = byte_1_valid_t3 ^ byte_0_valid_t3;
  assign final_16_3_t3a      = byte_2_valid_t3 ^ byte_1_valid_t3 ^ byte_0_valid_t3;
  assign final_16_4_t3a      = byte_3_valid_t3 ^ byte_2_valid_t3 ^ byte_1_valid_t3 ^ byte_0_valid_t3;
  assign final_16_5_t3a      = byte_4_valid_t3 ^ byte_3_valid_t3 ^ byte_2_valid_t3 ^ byte_1_valid_t3 ^ byte_0_valid_t3;
  assign final_16_6_t3a      = byte_5_valid_t3 ^ byte_4_valid_t3 ^ byte_3_valid_t3 ^ byte_2_valid_t3 ^
                               byte_1_valid_t3 ^ byte_0_valid_t3;
  assign final_16_7_t3a[2:0] = ({2'b00, byte_6_valid_t3} + {2'b00, byte_5_valid_t3} + {2'b00, byte_4_valid_t3} + {2'b00, byte_3_valid_t3} +
                                {2'b00, byte_2_valid_t3} + {2'b00, byte_1_valid_t3} + {2'b00, byte_0_valid_t3});

  assign bytes_789_t3[1:0] = {1'b0,byte_7_valid_t3} + {1'b0,byte_8_valid_t3} + {1'b0,byte_9_valid_t3};

  always @(posedge clk_gated)
  begin: ubytes_789_t4_1_0
    if (update_bytelanes_en_t3)
      bytes_789_t4[1:0] <=  bytes_789_t3[1:0];
  end


// Calculate these in the next pipeline stage
  assign final_16_0_t4[1:0] = {2{~byte_0_valid_t4}};
  assign final_16_1_t4[3:0] = {4{~byte_1_valid_t4}} | {3'b000, final_16_1_t4a};
  assign final_16_2_t4[3:0] = {4{~byte_2_valid_t4}} | {2'b00,  ~final_16_2_t4a, final_16_2_t4a};
  assign final_16_3_t4[3:0] = {4{~byte_3_valid_t4}} | {2'b00,  1'b1, final_16_3_t4a};
  assign final_16_4_t4[3:0] = {4{~byte_4_valid_t4}} | {1'b0,   ~final_16_4_t4a, final_16_4_t4a, final_16_4_t4a};
  assign final_16_5_t4[3:0] = {4{~byte_5_valid_t4}} | {1'b0,   2'b10,final_16_5_t4a};
  assign final_16_6_t4[3:0] = {4{~byte_6_valid_t4}} | {1'b0,   1'b1, ~final_16_6_t4a, final_16_6_t4a};
  assign final_16_7_t4[3:0] = {4{~byte_7_valid_t4}} | {1'b0,   final_16_7_t4a[2:0]};
  assign final_16_8_t4[3:0] = {4{~byte_8_valid_t4}} | ({3'b000,byte_7_valid_t4} + {1'b0, final_16_7_t4a[2:0]});
  assign final_16_9_t4[3:0] = {4{~byte_9_valid_t4}} | ({3'b000,byte_8_valid_t4} + {3'b000,byte_7_valid_t4} + {1'b0, final_16_7_t4a[2:0]});
  assign final_16_a_t4[3:0] = {4{~byte_a_valid_t4}} | ({1'b0, final_16_7_t4a[2:0]} + {2'b00,bytes_789_t4[1:0]});
  assign final_16_b_t4[3:0] = {4{~byte_b_valid_t4}} | ({3'b000,byte_a_valid_t4} + {2'b00,bytes_789_t4[1:0]} + {1'b0, final_16_7_t4a[2:0]});
  assign final_16_c_t4[3:0] = {4{~byte_c_valid_t4}} | ({3'b000,byte_b_valid_t4} + {3'b000,byte_a_valid_t4} + {2'b00,bytes_789_t4[1:0]} +
                                                        {1'b0, final_16_7_t4a[2:0]});
  assign final_16_d_t4[3:0] = {4{~byte_d_valid_t4}} | ({3'b000,byte_c_valid_t4} + {3'b000,byte_b_valid_t4} + {3'b000,byte_a_valid_t4} +
                                                        {2'b00,bytes_789_t4[1:0]} + {1'b0, final_16_7_t4a[2:0]});
  assign final_16_e_t4[3:0] = {4{~byte_e_valid_t4}} | ({3'b000,byte_d_valid_t4} + {3'b000,byte_c_valid_t4} + {3'b000,byte_b_valid_t4} +
                                                        {3'b000,byte_a_valid_t4} + {2'b00,bytes_789_t4[1:0]} + {1'b0, final_16_7_t4a[2:0]});
  assign final_16_f_t4[3:0] = {4{~byte_f_valid_t4}} | ({3'b000,byte_f_valid_t4} + {3'b000,byte_d_valid_t4} + {3'b000,byte_c_valid_t4} +
                                                        {3'b000,byte_b_valid_t4} + {3'b000,byte_a_valid_t4} + {2'b00,bytes_789_t4[1:0]} +
                                                        {1'b0, final_16_7_t4a[2:0]});


  assign update_bytelanes_en_t3 = (~trace_enable_tx |
                                   update_bytes_en_t3 |
                                   ts_output_en_t3 | ts_output_en_t4);

  always @(posedge clk_gated)
  begin: ufinal_16_t4
    if (update_bytelanes_en_t3) begin
      final_16_1_t4a     <=  final_16_1_t3a;
      final_16_2_t4a     <=  final_16_2_t3a;
      final_16_3_t4a     <=  final_16_3_t3a;
      final_16_4_t4a     <=  final_16_4_t3a;
      final_16_5_t4a     <=  final_16_5_t3a;
      final_16_6_t4a     <=  final_16_6_t3a;
      final_16_7_t4a     <=  final_16_7_t3a[2:0];
      byte_0_valid_t4    <=  byte_0_valid_t3;
      byte_1_valid_t4    <=  byte_1_valid_t3;
      byte_2_valid_t4    <=  byte_2_valid_t3;
      byte_3_valid_t4    <=  byte_3_valid_t3;
      byte_4_valid_t4    <=  byte_4_valid_t3;
      byte_5_valid_t4    <=  byte_5_valid_t3;
      byte_6_valid_t4    <=  byte_6_valid_t3;
      byte_7_valid_t4    <=  byte_7_valid_t3;
      byte_8_valid_t4    <=  byte_8_valid_t3;
      byte_9_valid_t4    <=  byte_9_valid_t3;
      byte_a_valid_t4    <=  byte_a_valid_t3;
      byte_b_valid_t4    <=  byte_b_valid_t3;
      byte_c_valid_t4    <=  byte_c_valid_t3;
      byte_d_valid_t4    <=  byte_d_valid_t3;
      byte_e_valid_t4    <=  byte_e_valid_t3;
      byte_f_valid_t4    <=  byte_f_valid_t3;
    end
  end


// Data for Packing logic.
  assign addr_or_cidheader_t3[7:0]       = (valid_branch_packet_t3 & br_addr_byte4567_en_t3)? br_addr_byte7_t3[7:0] : {7'b1000_000, context_payld_t3};


  // Remove the 3 static bits at bits 3,13,14 and re-insert in t4
  assign pack16_data_in_common_t3[111:0] = {cid_byte4_t4[7:0],
                                            cid_byte3_t4[7:0],
                                            cid_byte2_t4[7:0],
                                            cid_byte1_t4[7:0],
                                            vmid_byte1_t4[7:0],
                                            context_info_t3[7:0],
                                            addr_or_cidheader_t3[7:0],
                                            br_addr_byte6_t3[7:0],
                                            br_addr_byte5_t3[7:0],
                                            br_addr_byte4_t3[7:0],
                                            br_addr_byte3_t3[7:0],
                                            br_addr_byte2_t3[7:0],
                                            br_addr_byte1_t3[7:0],
                                            br_addr_byte0_t3[7:0]};

  // Upper bits not enabled when timestamp is used, Atom2 might be used. Timestamp header muxed in later
  assign pack16_data_short_ts_t3[111:0] = {pack16_data_in_common_t3[111:88], 3'b000, ts_bytes_t3[84:0]};

  assign pack16_data_short_t3[111:0] = ts_output_en_t3 ? pack16_data_short_ts_t3[111:0] : pack16_data_in_common_t3[111:0];

  always @(posedge clk_gated or negedge po_reset_n)
  begin: upack16_data_t4
    if (!po_reset_n) begin
      pack16_data_short_t4[111:0] <= {112{1'b0}};
      wpt_taken_t5                <= 1'b0;
      ts_byte0_cc_bit_t4          <= 1'b0;
      address_pkt_header_h_t4     <= 1'b0;
      address_pkt_header_l_t4     <= {5{1'b0}};
    end
    else begin
      pack16_data_short_t4[111:0] <= pack16_data_short_t3[111:0];
      wpt_taken_t5                <= wpt_taken_t4;
      ts_byte0_cc_bit_t4          <= ts_byte0_cc_bit_t3;
      address_pkt_header_h_t4     <= address_pkt_header_t3[7];
      address_pkt_header_l_t4     <= address_pkt_header_t3[4:0];
    end
  end

  // Not enabled when timestamp is used, no need to mask
  assign trace_on_or_curr_atom_t4[7:0]   = (trace_on_pkt_en_t4)? 8'b0000_0100 :
                                                                {7'b1111_011, wpt_taken_t5};
  
  // Add back in static bits
  assign pack16_data_in_t4[127:16] = pack16_data_short_t4[111:0];
  assign pack16_data_in_t4[ 15: 8] = ts_output_en_t4 ? {7'b0000001, ts_byte0_cc_bit_t4} : 
                                                       {address_pkt_header_h_t4,2'b00,address_pkt_header_l_t4};
  assign pack16_data_in_t4[  7: 0] = trace_on_or_curr_atom_t4[7:0];

  // Pack Exception return, cycle count then atom2 in timestamp case. E-ret implies no timestamp
  assign pack4_in_t3[7 : 0] = valid_excp_return_out_t4 ? 8'h07:
                              cc_pkt_b0_en_t3          ? cc_pkt_b0_t3[7:0]:
                                                         {7'b1111_011, wpt_taken_t5};
  assign pack4_in_t3[15: 8] = valid_excp_return_out_t4 ? cc_pkt_b0_t3[7:0]:
                              cc_pkt_b1_en_t3          ? cc_pkt_b1_t3[7:0] : 
                                                         {7'b1111_011, wpt_taken_t5};
  assign pack4_in_t3[23:16] = valid_excp_return_out_t4 ? cc_pkt_b1_t3[7:0]:
                              cc_pkt_b2_en_t3          ? {3'b000, cc_pkt_b2_t3[4:0]}: 
                                                         {7'b1111_011, wpt_taken_t5};
  assign pack4_in_t3[31:24] = valid_excp_return_out_t4 ? {3'b000, cc_pkt_b2_t3[4:0]}:
                                                         {7'b1111_011, wpt_taken_t5};
  
  assign pack4_en_t3 = valid_excp_return_out_t4 | cc_pkt_b0_en_t3 | valid_curr_atom_packet_t4;

  always @(posedge clk_gated)
  begin: upack4_in_t4_31_0
    if (pack4_en_t3)
      pack_pack4_in_t4[31:0] <=  pack4_in_t3[31:0];
  end

//Instantiate the packing block
  ca53etm_fifo_pack u_et_fifo_pack (
    .clk_gated              (clk_gated),
`ifdef CA53_SVA_ON
    .po_reset_n             (po_reset_n),
`endif

    .final_16_0_t4_i        (final_16_0_t4[1:0]),
    .final_16_1_t4_i        (final_16_1_t4[3:0]),
    .final_16_2_t4_i        (final_16_2_t4[3:0]),
    .final_16_3_t4_i        (final_16_3_t4[3:0]),
    .final_16_4_t4_i        (final_16_4_t4[3:0]),
    .final_16_5_t4_i        (final_16_5_t4[3:0]),
    .final_16_6_t4_i        (final_16_6_t4[3:0]),
    .final_16_7_t4_i        (final_16_7_t4[3:0]),
    .final_16_8_t4_i        (final_16_8_t4[3:0]),
    .final_16_9_t4_i        (final_16_9_t4[3:0]),
    .final_16_a_t4_i        (final_16_a_t4[3:0]),
    .final_16_b_t4_i        (final_16_b_t4[3:0]),
    .final_16_c_t4_i        (final_16_c_t4[3:0]),
    .final_16_d_t4_i        (final_16_d_t4[3:0]),
    .final_16_e_t4_i        (final_16_e_t4[3:0]),
    .final_16_f_t4_i        (final_16_f_t4[3:0]),
    .pack16_data_in_t4_i    (pack16_data_in_t4[127:0]),
    .pack16_bytes_in_t4_i   (pack16_bytes_in_t4[4:0]),
    .pack_pack4_data_in_t4_i(pack_pack4_in_t4[31:0]),
    .pack4_num_bytes_t4_i   (pack4_num_bytes_t4[2:0]),

    .pack_data_out_t5_o     (pack_data_out_t5[156:0])
  );



//---------------------------------------------------------------------------
// VALID BYTES AND DATA TO MAIN TRACE FIFO
//---------------------------------------------------------------------------

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uupdate_valid_q
    if (!po_reset_n) begin
      trace_on_pkt_en_t4        <=  1'b0;
      excep_pkt_gen_t4          <=  1'b0;
    end
    else begin
      trace_on_pkt_en_t4        <=  trace_on_pkt_en_t3;
      excep_pkt_gen_t4          <=  excep_pkt_gen_t3;
    end
  end


  assign nxt_num_bytes_t5[4:0]  = num_bytes_t4[4:0] & {5{~(overflow_supress | set_overflow_t2) & core_at_main_run_t2_i}};
  assign nxt_num_first8_t5[2:0] = num_first8_true_t4[2:0] & {3{~(overflow_supress | set_overflow_t2)}};

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ubytes_t5
    if (!po_reset_n) begin
      num_bytes_t5[4:0]  <=  {5{1'b0}};
      num_first8_t5[2:0] <=  {3{1'b0}};
    end
    else begin
      num_bytes_t5[4:0]  <=  nxt_num_bytes_t5[4:0];
      num_first8_t5[2:0] <=  nxt_num_first8_t5[2:0];
    end
  end


  assign num_first8_t5_o[2:0] = num_first8_t5[2:0];
  assign num_bytes_t5_o[4:0]  = num_bytes_t5[4:0];

// Packed Data
  assign wpt_bytes_en_t4 = |nxt_num_first8_t5[2:0];

  always @(posedge clk_gated)
  begin: ufirst_8_t5_36_0
    if (wpt_bytes_en_t4)
      packed_first_8_t5 <= packed_first_8_t4;
  end

  assign pack_fifo_in_t5_o[203:  0] = {pack_data_out_t5[156:0], packed_first_8_t5[46:0]};

//--------------------------------------------------------------------------
// SVA ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON

`include "ca53etm_val_defs.v"
  
// Assertions for X-Propagation related casez
  usva_address_pkt_header_t3_7_0_x_check: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown({context_pkt_en_t3, addr_pkt_en_t3, arm_nthumb_state_t3, address_change_b4567_t3, address_change_b23_t3}))
    `SVA_FATAL("address_pkt_header_t3_7_0 assignment control must not be unknown");

  usva_first_8_packed_t3_x_check:  assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown({excep_pkt_gen_t3, trace_info_pkt_en_t3, trace_info_pkt_cyct1_en_t3, trace_info_pkt_cyct0_en_t3, event_pkt_en_t3, atom_pkt_gen_t4}))
    `SVA_FATAL("first_8_packed_t3 assignment control must not be unknown");

  usva_viewinst_x_check:  assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown({viewinst_en_t2_i}))
    `SVA_FATAL("viewinst_en_t2_i must not be unknown");

  usva_num_bytes_x_check:  assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown({num_bytes_t5_o}))
    `SVA_FATAL("num_bytes_t5_o must not be unknown");

  //low_power_override_flush_o x check
  usva_low_power_override_flush_x_check:  assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown(low_power_override_flush_o))
    `SVA_FATAL("low_power_override_flush_o must not be unknown");
  usva_atom_pkt_t3_x_check:  assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown(atom_pkt_t3))
    `SVA_FATAL("Atom Packet must not be unknown");
    
// Signals for easier debug
  wire [63:0] dbg_wpt_addr_t1   = {wpt_addr_t1,1'b0};

// Byte counts correct in t4 (provided num_bytes is non zero)
// Pack does not distinguish between 15 and 16 inputs valid
  usva_byte_count:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     |num_bytes_t4 |->
     ((num_bytes_t4 == num_first8_true_t4 + pack4_num_bytes_t4 + {4{3'b000,final_16_0_t4 == 3'h0}}) 
      & (ts_output_en_poss_t4 & cc_pkt_b0_en_t3)) |
     ((num_bytes_t4 == num_first8_true_t4 + pack4_num_bytes_t4 + {4{3'b000,final_16_0_t4 == 3'h0}} + {4{3'b000,final_16_1_t4 == 4'h0}}) 
      & (ts_output_en_poss_t4 & cc_pkt_b0_en_t3)) |
     (num_bytes_t4 == u_et_fifo_pack.sva_no_valid_final_16 + pack4_num_bytes_t4 + num_first8_true_t4) |
     (num_bytes_t4 == (&u_et_fifo_pack.sva_no_valid_final_16[2:0]) + 
      u_et_fifo_pack.sva_no_valid_final_16 + pack4_num_bytes_t4 + num_first8_true_t4)
     )
    `SVA_FATAL("Pack byte enables does not match byte counts");

  usva_first_count:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      num_first8_t5 < 3'b111)
    `SVA_FATAL("More than 6 bytes in first part pack logic");
    

//Check pipeline of pack16_data with missing static bits
  usva_pack16_ts:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ##1 ts_output_en_t3 ##1 ~cc_pkt_b0_en_t3 |-> 
    pack16_data_in_t4[100:8] == $past({ts_bytes_t3[84:0],7'b0000001, ts_byte0_cc_bit_t3}))
    `SVA_FATAL("Timestamp packet not pipelined in t4");

  usva_pack16_ts1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ##1 ts_output_en_t3 ##1 ~cc_pkt_b0_en_t3 |-> pack16_data_in_t4[100:16] == $past(ts_bytes_t3[84:0]))
    `SVA_FATAL("Timestamp packet not pipelined in t4");
  usva_pack16_ts2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ##1 ts_output_en_t3 ##1 ~cc_pkt_b0_en_t3 |-> pack16_data_in_t4[15:8] == $past({7'b0000001, ts_byte0_cc_bit_t3}))
    `SVA_FATAL("Timestamp packet not pipelined in t4");
  usva_pack16_nts:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ##1 ~ts_output_en_t3 |=> pack16_data_in_t4[15:0] == $past({address_pkt_header_t3,
                                                               (trace_on_pkt_en_t3)? 8'b0000_0100 :
                                                                {7'b1111_011, wpt_taken_t4}}))
    `SVA_FATAL("Non timestamp packet not pipelined in t4");

//Atom generation is exclusive on some lanes
  usva_exclusive_lane_1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        $onehot0({valid_curr_atom_packet_t4, trace_on_pkt_en_t3}))
    `SVA_FATAL("Exclusive packet generated at Lane 1: Atom and Trace On");

  usva_exclusive_lane_2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        $onehot0({valid_branch_packet_t3, ts_output_en_t3}))
    `SVA_FATAL("Exclusive packet generated at Lane 2: Addr and TS");

  usva_exclusive_lane_9:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        $onehot0({(context_pkt_en_t3 & ~(valid_branch_packet_t3 & ~address_exact_match_t3)),
                                                  (valid_branch_packet_t3 & br_addr_byte4567_en_t3),
                                                  (ts_output_en_t3 & ts_byte8_t3_en)}))
    `SVA_FATAL("Exclusive packet generated at Lane 9: Addr and TS");

// When FIFO overflow happen, no more valid bytes should be send to FIFO
  usva_ap_etm_overflow_no_fifo_bytes:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                 fifo_overflow_i|=> ~|num_bytes_t5_o )
    `SVA_FATAL("No more data should send to FIFO when FIFO is overflow");

// After trace is truned on, the first packet need to be A-sync (Trace info valid also)
  reg  sva_progbit_fall_to_first_packet;
  always @(posedge clk_gated or negedge po_reset_n) begin
    if(!po_reset_n)
      sva_progbit_fall_to_first_packet <= 1'b0;
    else if (progbit_fall_t2)
      sva_progbit_fall_to_first_packet <= 1'b1;
    else if (async_req_t4_o)
      sva_progbit_fall_to_first_packet <= 1'b0;
  end

  usva_ap_etm_first_packet_after_enable:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_first_packet |-> ~|num_bytes_t5_o)
    `SVA_FATAL("Packets generated between main_enable and async request");

// Trace info packet need to be generated after trace turning on
// Detect trace_info packet by decode of output logic
   wire [2:0]    sva_trace_info_present;
  reg  sva_progbit_fall_to_trace_info_packet;
  always @(posedge clk_gated or negedge po_reset_n) begin
    if(!po_reset_n)
      sva_progbit_fall_to_trace_info_packet <= 1'b0;
    else if (progbit_fall_t2 |  | overflow_state_t5)
      sva_progbit_fall_to_trace_info_packet <= 1'b1;
    else if (|sva_trace_info_present)
      sva_progbit_fall_to_trace_info_packet <= 1'b0;
  end

  usva_ap_etm_trace_info_after_enable:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_trace_info_packet |-> $past(~|num_bytes_t5_o))
    `SVA_FATAL("Packets generated between main_enable and trace_info");

  usva_ap_etm_bytes_after_enable:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        async_trace_enable_t2 |-> ~|num_bytes_t5_o[*2])
    `SVA_FATAL("Packets generated before trace_enable async");

  usva_ap_etm_trace_info_after_enable1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_trace_info_packet[*2] |-> ~$past(trace_on_pkt_en_t3,3))
    `SVA_FATAL("Trace on packet generated after main_enable without async/trace_info");

  usva_ap_etm_trace_info_after_enable2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_trace_info_packet[*2] |-> ~$past(event_pkt_en_t3,3))
    `SVA_FATAL("Event packet generated after main_enable without async/trace_info");

  usva_ap_etm_trace_info_after_enable3:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_trace_info_packet[*2] |-> ~$past(ts_output_en_t3,2))
    `SVA_FATAL("Timestamp packet generated after main_enable without async/trace_info");

  // Trace info must be followed by address
  reg sva_info_needs_address;
  always @(posedge clk_gated or negedge po_reset_n)
    if(!po_reset_n)
      sva_info_needs_address <= 1'b0;
    else
      sva_info_needs_address <= (trace_info_pkt_en_t3 | sva_info_needs_address) & ~valid_branch_packet_t3;
    
  usva_info_needs_address:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    sva_info_needs_address |-> ~valid_atom_t4)
    `SVA_ERROR("Atom traced without address after trace info packet");
    
  // For fifo state sequence  
  reg sva_overflow_to_async;
  always @(posedge clk_gated or negedge po_reset_n) begin
    if(!po_reset_n)
      sva_overflow_to_async <= 1'b1;
    else 
      sva_overflow_to_async <= set_overflow_t3 | async_trace_enable_t2 | (sva_overflow_to_async & ~async_req_t3 & ~async_req_t4);
  end
    
  usva_overflow_no_active:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                             sva_overflow_to_async & ~overflow_supress |->
                                            $past(set_overflow_t3,3) |
                                             ~excep_pkt_gen_t4)
  `SVA_FATAL("Byte generation logic active when fifo recovering");

  usva_overflow_no_event:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                             sva_overflow_to_async & event_pkt_en_t3 |=>
                                            $past(set_overflow_t3,2) |
                                             async_req_t4_o)
  `SVA_FATAL("Event traced before async after overflow");
    
                              
  // Rapid sync request causes overflow, but must avoid scenario where old sync request got stuck
  usva_ap_etm_early_overflow: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
  (trace_enable_t5 & ~sync_req_t2_i)[*3]                 ##1
  (trace_enable_t5 & ~sync_req_t2_i & ~wpt_valid_t4 & ~fifo_level28_t7_i)[*5] |=>
  ~sync_overflow)
    `SVA_FATAL("Forced overflow occured too soon after start of session");

// Trace on packet need to be generated after trace turning on
  reg  sva_progbit_fall_to_trace_on_packet;
  always @(posedge clk_gated or negedge po_reset_n) begin
    if(!po_reset_n)
      sva_progbit_fall_to_trace_on_packet <= 1'b0;
    else if ((~wfx_state_t4 & ~wfx_resource_t3_i & ~trace_enable_t3 & trace_enable_t2) | overflow_state_t5)  
      sva_progbit_fall_to_trace_on_packet <= 1'b1;
    else if (trace_on_pkt_en_t4)
      sva_progbit_fall_to_trace_on_packet <= 1'b0;
  end

// From enable to trace on packet, only trace info, ts and events are allowed
  usva_ap_etm_trace_on_after_enable:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_progbit_fall_to_trace_on_packet |->
                                           (~|num_bytes_t5_o) |
                                           $past(trace_info_pkt_en_t3,2) |
                                           $past(ts_output_en_t3,2) |
                                           $past(event_pkt_en_t3,2))
    `SVA_FATAL("Packets generated between main_enable and trace on");

// Overflow request can't occur after some cycles in idle state
// Discount idle state due to WFX, since this is left without fifo empty
// Discount race condition (for property sequence) due to disable just after overflow recovery
  usva_idle_state_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        ~(gov_wfx_drain_req_t2 | async_req_t4)[*4] ##1
        trace_idle_state_cnt_t3 == 4'b1011 |-> 
                                          (~|num_bytes_t5_o) ##1
                                          (~|num_bytes_t5_o | async_req_t4) ##1
                                          (~|num_bytes_t5_o | async_req_t4 | $past(async_req_t4)))
    `SVA_FATAL("Packets generated while trace is in overflow state");

  usva_idle_state_bytes_xa: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        ~(gov_wfx_drain_req_t2 | async_req_t4)[*4] ##1
        (trace_idle_state_cnt_t3 == 4'b1011) & ~async_req_t4 & ~async_req_t3 & ~async_pend_t3|-> 
                                          (~|num_bytes_t5_o)[*3])
    `SVA_FATAL("Packets generated while trace is in overflow state");
  usva_idle_state_bytes_xa1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        ~(gov_wfx_drain_req_t2 | async_req_t4)[*4] ##1
        (trace_idle_state_cnt_t3 == 4'b1011) & ~async_req_t4 & ~async_req_t3 & ~async_pend_t3|-> 
                                          (~|num_bytes_t5_o)[*1])
    `SVA_FATAL("Packets generated while trace is in overflow state");
    
  usva_idle_state_bytes_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        ~(gov_wfx_drain_req_t2 | async_req_t4)[*4] ##1
        trace_idle_state_cnt_t3 == 4'b1011 & $past(viewinst_idle_req_t2_i) |-> 
                                          (~|num_bytes_t5_o)[*2])
    `SVA_FATAL("Packets generated while trace is in overflow state");
  usva_idle_req_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        viewinst_idle_req_t2_i[*12] |-> ~(|num_bytes_t5_o))
    `SVA_FATAL("Packets generated while trace is in overflow state");
  usva_idle_overflow_req_x: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        viewinst_idle_req_t2_i[*13] |-> ~fifo_overflow_i)
    `SVA_FATAL("Packets generated while trace is in overflow state");
  usva_idle_overflow_req_xy: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        viewinst_idle_req_t2_i[*14] |-> ~fifo_overflow_i)
    `SVA_FATAL("Packets generated while trace is in overflow state");
  usva_idle_overflow_req_xx: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        viewinst_idle_req_t2_i[*14] |-> ~set_overflow_t3)
    `SVA_FATAL("Packets generated while trace is in overflow state");

  usva_idle_req_context: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        viewinst_idle_req_t2_i[*3] |-> ~context_pkt_en_t3)
    `SVA_FATAL("Context packet generated while trace is in idle state");

    
//when trace is in overflow state, the following packets cannot be generated
  usva_ap_etm_gen_overflow_no_pack: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~|num_bytes_t5_o)   //No data output to FIFO
    `SVA_FATAL("Packets generated while trace is in overflow state");

  usva_ap_etm_gen_overflow_no_pack1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~ts_output_en_t3)   //No TS output
    `SVA_FATAL("TS packets generated while trace is in overflow state");


  usva_ap_etm_gen_overflow_no_pack2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~trace_on_pkt_en_t3)
    `SVA_FATAL("Trace On packets generated while trace is in overflow state");

// Scenario with only event trace and overflows is uncheckable Fatal here is for testbench
    reg sva_track_overflow;
    reg sva_track_overflow_event;
  always @(posedge clk_gated or negedge po_reset_n) begin
    if(!po_reset_n) begin
      sva_track_overflow <= 1'b0;
      sva_track_overflow_event <= 1'b0;
    end
    else begin
      sva_track_overflow <= ~trace_on_pkt_en_t3 & (sva_track_overflow | overflow_state_t4);
      sva_track_overflow_event <= ~trace_on_pkt_en_t3 & (sva_track_overflow_event |(sva_track_overflow & event_pkt_en_t3));
    end
  end

// First event trace at t3 can be with fifo signalling empty
  usva_ap_etm_gen_overflow_no_pack5: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW & ~go_to_trace_overflow_idle |-> ~event_pkt_en_t3)
    `SVA_FATAL("Event packets generated while trace is in overflow state");


  usva_ap_etm_gen_overflow_no_pack6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        ~go_to_trace_overflow_idle &
         trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~trace_info_pkt_en_t3)
    `SVA_FATAL("Trace Info packets generated while trace is in overflow state");

  usva_ap_etm_gen_overflow_no_pack8: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~valid_curr_atom_packet_t4)
    `SVA_FATAL("ATOM packets generated while trace is in overflow state");

  usva_ap_etm_gen_overflow_no_pack9: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t4 == CA53_ETM_GEN_ST_OVERFLOW |-> ~valid_excp_return_out_t4)
    `SVA_FATAL("Exception Return packets generated while trace is in overflow state");

  // If overflow state is entered, must also recover from overflow (t3 to avoid trace_enable mask)
  usva_overflow_no_pulse: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        trace_state_t3 != CA53_ETM_GEN_ST_OVERFLOW ##1
        trace_state_t3 == CA53_ETM_GEN_ST_OVERFLOW |=> 
        trace_state_t3 == CA53_ETM_GEN_ST_OVERFLOW)
    `SVA_FATAL("Must stay in overflow state for more than 1 cycle");
// After FIFO/force sync overflow recovery, an overflow request to FIFO need to be generated
  reg  sva_ovfl_req_generated;
  wire sva_enter_overflow =  (trace_state_t3 == CA53_ETM_GEN_ST_OVERFLOW) & (trace_state_t4 != CA53_ETM_GEN_ST_OVERFLOW);
  always @ (posedge clk_gated or negedge po_reset_n) begin
    if (!po_reset_n)
      sva_ovfl_req_generated  <= 1'b0;
    else if (ovfl_req_t2_o)
      sva_ovfl_req_generated  <= 1'b1;
    else if (sva_enter_overflow)
      sva_ovfl_req_generated  <= 1'b0;
   end

  usva_ap_etm_ovfl_req_after_overflow:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
         (trace_state_t4 == CA53_ETM_GEN_ST_OFLOWIDLE) |-> ##[0:3] sva_ovfl_req_generated )
    `SVA_FATAL("overflow request was not generated after overflow");

  // Scenario which could interfere with idle state
  usva_ap_bytes_when_idle:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
         $past(viewinst_idle_req_t3,6) & 
         $past(viewinst_idle_req_t3,5) & 
         $past(viewinst_idle_req_t3,4) & 
         $past(viewinst_idle_req_t3,3) & 
         $past(viewinst_idle_req_t3,2) & 
         (trace_state_t4 == CA53_ETM_GEN_ST_OFLOWIDLE) |-> ~|num_bytes_t5_o)
    `SVA_FATAL("Data input to Fifo before trace restarted");

  reg sva_overflow_not_recovered;
  always @ (posedge clk_gated or negedge po_reset_n) begin
    if (!po_reset_n)
      sva_overflow_not_recovered <= 1'b0;
    else
      sva_overflow_not_recovered <= set_overflow_t3 | (sva_overflow_not_recovered & ~async_req_t4_o);
  end

// After FIFO/force sync overflow recovery, A-sync request to FIFO need to be generated
  usva_ap_etm_async_req_after_overflow:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
         (sva_overflow_not_recovered & ~async_req_t4_o)
         |=> ~num_bytes_t5_o)
    `SVA_FATAL("Async request was not generated after overflow");

// Idle state must not go direct to tracing
  usva_ap_etm_overflow_state:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    trace_state_active_t3 == CA53_ETM_GEN_ST_OVERFLOW |=>
    trace_state_active_t3 != CA53_ETM_GEN_ST_TRACING)
    `SVA_FATAL("Trace state must go to one of the idle states after overflow");
    
  usva_ap_etm_overflow_active:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_i |=>
    trace_enable_t2)
    `SVA_FATAL("Overflow must not occur when trace pipe is inactive");

// Event trace (t3) must either reach fifo (t7), be captured for output in overflow (before o_idle)
// or be output after overflow.
// Events valid on exactly last cycle will be only event captured
  usva_event_lost_4:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                      |event_trace_pipe_t3 ##1 
                      (~set_overflow_t2 & ~|event_trace_pipe_t3)[*3] ##1 
                      (~|event_trace_pipe_t3 & fifo_overflow_i) |-> 
                      traced_event_t3_o == $past(event_qual_t3,4))
    `SVA_ERROR("Event lost when causing overflow");
  usva_event_lost_4_merge:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |event_trace_pipe_t3 ##4 fifo_overflow_i |=> (traced_event_t3_o & $past(event_trace_pipe_t3,5)) == $past(event_trace_pipe_t3,5))
    `SVA_ERROR("Event lost when 1 after overflow");
  usva_event_lost_3:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |event_trace_pipe_t3 ##3 fifo_overflow_i |=> (traced_event_t3_o & $past(event_trace_pipe_t3,4)) == $past(event_trace_pipe_t3,4))
    `SVA_ERROR("Event lost when 1 after overflow");
  usva_event_lost_2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |event_trace_pipe_t3 ##2 fifo_overflow_i |=> (traced_event_t3_o & $past(event_trace_pipe_t3,3)) == $past(event_trace_pipe_t3,3))
    `SVA_ERROR("Event lost when 2 after overflow");
  usva_event_lost_1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |event_trace_pipe_t3 ##1 fifo_overflow_i |=> (traced_event_t3_o & $past(event_trace_pipe_t3,2)) == $past(event_trace_pipe_t3,2))
    `SVA_ERROR("Event lost when 3 after overflow");
  usva_event_lost_0:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |event_trace_pipe_t3 &&  fifo_overflow_i |=> (traced_event_t3_o & $past(event_trace_pipe_t3,1)) == $past(event_trace_pipe_t3,1))
    `SVA_ERROR("Event lost when entering overflow");
  usva_event_lost_during:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                      (|event_trace_pipe_t3 &&  overflow_state_t3) ##1 overflow_state_t3 |=> 
                       (traced_event_t3_o & $past(event_trace_pipe_t3,2)) == $past(event_trace_pipe_t3,2))
    `SVA_ERROR("Event lost when during overflow");
// First opportunity after overflow, also needs async
  wire        sva_event_present;
  usva_event_lost_leaving:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       ~viewinst_idle_req_t2_i[*5] ##1
                      (~viewinst_idle_req_t2_i & overflow_state_t3 && ~|traced_event_t3_o & ~trace_idle_state_cnt_t3[3]) ##1
                       go_to_trace_overflow_idle && |event_trace_pipe_t3  & ~viewinst_idle_req_t2_i ##1 
                       ~viewinst_idle_req_t2_i|=> sva_event_present)
    `SVA_ERROR("Event should be traced by trace pipe after overflow");
    
// Last opportunity after overflow to trace an event in overflow packet
  usva_event_not_lost_leaving:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                      (|event_trace_pipe_t3 &&  overflow_state_t3) ##1 ~overflow_state_t3 |=> ~sva_event_present)
    `SVA_ERROR("Event traced in pipe when leaving overflow");

// Synchronisation overflow should not recycle t6,t7
  usva_event_repeat_lost:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                      ~|event_qual_t3 ##1
                       |event_trace_pipe_t3 & ~fifo_overflow_i ##1
                      ~|event_qual_t3 & ~fifo_overflow_i   & ~|etm_extout_i ##1                      
                        set_overflow_t2 & ~fifo_overflow_i & ~|etm_extout_i ##1 
                       ~set_overflow_t2 & ~|event_qual_t3  & ~|etm_extout_i |-> 
                                       traced_event_t3_o == 4'b0000)
    `SVA_ERROR("Event traced twice due to sync overflow");
     
// Fifo should only overflow after data presented to it - Assume when stopat is used.
  usva_overflow_abstract:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~|num_bytes_t5_o |-> ##2 ~$past(fifo_overflow_i))
    `SVA_ERROR("Fifo overflow without data input to fifo");
  usva_overflow_abstract2b:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    sync_overflow |=> set_overflow_t3)
    `SVA_ERROR("Fifo overflow_t3 abstraction failed");
    // Overflow can last 2 cycles, but then does not repeat
  usva_overflow_abstract3:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_i[*2] |=>  ~fifo_overflow_i[*4])
    `SVA_ERROR("Fifo overflow_t3 abstraction failed - occurs to quickly");
  usva_overflow_abstract4:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    go_to_trace_overflow_idle |=>  ~set_overflow_t3[*3])
    `SVA_ERROR("Fifo overflow_t3 abstraction failed - occurs to quickly");
  usva_overflow_abstract5:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    set_overflow_t3 |=> overflow_state_t4)
    `SVA_ERROR("Fifo overflow_t3 abstraction failed");
  usva_overflow_abstract6:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_i |=>  set_overflow_t3)
    `SVA_ERROR("Fifo overflow_t3 abstraction failed");
  usva_overflow_abstract7:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    overflow_state_t4 |-> trace_enable_t3)
    `SVA_ERROR("Fifo overflow_t3 abstraction failed");
  usva_overflow_abstract8:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    viewinst_idle_req_t2_i[*14] |-> ~set_overflow_t3)
    `SVA_ERROR("Fifo overflow_t3 abstraction failed");
                                             
  usva_context_in_idle:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    trace_state_t4 == CA53_ETM_GEN_ST_OFLOWIDLE & context_pkt_en_t3 |=>
                                          trace_state_t4 == CA53_ETM_GEN_ST_TRACING)
    `SVA_ERROR("Fifo overflow before tracing restarted");

  usva_ex_pend_in_idle:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    trace_state_t4 == CA53_ETM_GEN_ST_OFLOWIDLE |->
                                           ~trace_pending_excep_t3)
    `SVA_ERROR("Fifo overflow before tracing restarted");
  usva_traced_in_idle:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    trace_state_t4 == CA53_ETM_GEN_ST_OFLOWIDLE |->
                                           ~wpt_traced_t3)
    `SVA_ERROR("Fifo overflow before tracing restarted");
  usva_overflow_stay_overflow1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_i |-> ##2 (trace_state_t4 != CA53_ETM_GEN_ST_IDLE)[*2]
                                            )
    `SVA_ERROR("Fifo overflow must not be followed by idle");
  usva_overflow_stay_overflow2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_i |-> ##2 (trace_state_t4 != CA53_ETM_GEN_ST_TRACING)[*2]
                                            )
    `SVA_ERROR("Fifo overflow must not be followed by tracing");
  usva_overflow_enable:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    |num_bytes_t5_o |-> trace_enable_t2[*3])
    `SVA_ERROR("Fifo overflow must not be followed by tracing");

  // Performance corner case
  usva_perf_force_overflow_bytes:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~|num_bytes_t5_o[*4] ##1
    ~|num_bytes_t5_o & ~sync_req_t2_i ##1 sync_overflow
     |-> $past(fifo_level28_t7_i) | excep_pkt_gen_t4)
    `SVA_ERROR("Sync overflow should not occur with no fifo input");

  usva_cid_change_in_idle:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    gov_wfx_drain_req_t2[*2] |->
      ~context_changed_t3)
    `SVA_ERROR("Context ID changed whilst in WFX");

  usva_trc_en_flap:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      ~trace_enable_tx ##1 trace_enable_tx |=>
                                      trace_enable_tx[*3])
    `SVA_ERROR("TraceEnable expected to stay high for more than 4 cycles at a time");

  // Low power overide must capture any data when still in wfx after 16 cycles. (use 13 here)
  // Sync, Event and timestamp packets are allowed since this is the effect of LP-overide
  usva_wfx_flush_data: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    low_power_override_flush_o ##1 gov_wfx_drain_req_t1[*13] |-> ~|num_bytes_t5_o[4:1] |
                                                                   $past(ts_output_en_t4) |
                                                                   $past(async_req_t3,2))
    `SVA_FATAL("low_power_override_flush_o did not capture all data which was output in WFX state");

//Timestamp

// If a trace overflow occurs or after the first time trace is enabled, the next timestamp must not occur until at least
// one Atom, Exception, or Event element has been traced.
  wire sva_trace_enabled = core_at_main_run_t2_i;
  reg  sva_trace_enabled_pipe;
  wire sva_trace_enabled_rose = sva_trace_enabled & ~sva_trace_enabled_pipe;

  wire sva_trace_overflowed = overflow_state_t4;
  reg  sva_ts_pre_req_met;
  reg  sva_first_ts_after_trace_enable_or_overflow;
  wire sva_ts_pre_req_elements =  excep_pkt_gen_t3 |
                                  valid_atom_t4 |
                                  event_pkt_en_t3;


  // sva_trace_enabled_pipe signal
  always @ (posedge clk_gated or negedge po_reset_n) begin
    if (!po_reset_n)
      sva_trace_enabled_pipe  <= 1'b0;
    else
      sva_trace_enabled_pipe  <= sva_trace_enabled;
  end


  //TS output pre req met
  always @ (posedge clk_gated or negedge po_reset_n) begin
    if (!po_reset_n)
      sva_ts_pre_req_met  <= 1'b0;
    else if (sva_ts_pre_req_elements)
      sva_ts_pre_req_met  <= 1'b1;
    else if (ts_output_en_t3)
      sva_ts_pre_req_met  <= 1'b0;
  end

  //first TS after trace enable or overflow
  always @ (posedge clk_gated or negedge po_reset_n) begin
    if (!po_reset_n)
      sva_first_ts_after_trace_enable_or_overflow  <= 1'b0;
    else if (sva_trace_enabled_rose | sva_trace_overflowed)
      sva_first_ts_after_trace_enable_or_overflow  <= 1'b1;
    else if (ts_output_en_t3)
      sva_first_ts_after_trace_enable_or_overflow  <= 1'b0;
  end

  //TS after first trun trace on or after overflow must have pre traced element
  usva_ap_etm_ts_output_req_met:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_first_ts_after_trace_enable_or_overflow & ts_output_en_t3
        |-> sva_ts_pre_req_met )
    `SVA_FATAL("timestamp packet need have pre traced element after trace first enable or overflowed");

  // TS must be full time stamp for the first TS. Cycle count can be present or unknown
  wire  sva_all_ts_bytes_t3_en = ts_byte2_t3_en &
                                 ts_byte3_t3_en &
                                 ts_byte4_t3_en &
                                 ts_byte5_t3_en &
                                 ts_byte6_t3_en &
                                 ts_byte7_t3_en &
                                 ts_byte8_t3_en &
                                 ts_byte9_t3_en;
  // Full time stamp packet needed for the first TS after trace first trun on or overflow
  usva_ap_etm_ts_full_packet_req:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
        sva_first_ts_after_trace_enable_or_overflow & ts_output_en_t3
        |-> sva_all_ts_bytes_t3_en )
    `SVA_FATAL("Full time stamp packet needed");
  // Can't trace timestamp and trace on together
  usva_ap_etm_ts_not_on:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                           (ts_output_en_t3 |-> ~trace_on_pkt_en_t3))
    `SVA_FATAL("Timestamp must come after atom, not with trace on");

  usva_ap_etm_ts_synced:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                           (ts_output_en_t3 |-> ~first_sync_t3))
    `SVA_FATAL("Timestamp must come after first sync");

  // Can't trace atom2 and trace on together
  usva_ap_etm_atom2_not_on:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                           (trace_on_pkt_en_t3 |-> ~valid_curr_atom_packet_t4))
    `SVA_FATAL("Atom and trace on can't come together");


// When indirect branch happen, the atom and address packet need to be valid later


// When direct branch happen but in BB mode, the atom and address packet need to be valid later



// if NIDEN is not valid, no trace packet should be generated


// After trace is disabled N cycles later, no trace packet should be generated

// Final atom completion at end of session (trace active stays low) must not be followed by new
// atom which would then not be traced
  usva_ap_etm_complete_atom:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
              (trace_active_t5 & ~trace_active_t4)  |-> (trace_active_t4 | ~valid_atom_t4)[*3])
    `SVA_FATAL("trace data generated when final atom_completion term seen");

  usva_ap_etm_complete_atom1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                     (~core_at_main_run_t2_i & trace_enable_t4) |->
                      ~(atom_pkg_st_t3[2:0] != ATOM_PKG_ST_IDLE))
    `SVA_FATAL("Unexpected atom_completion term needed");
    
// Check unreachable atom packet generation logic
  usva_ap_atom_pk_state1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
         ~atom_combine_t3 & (atom_pkg_st_t3 == ATOM_PKG_ST_FMT4) |->
                                                (atom_bits_t4[3:0] == 4'b1110)|
                                                (atom_bits_t4[3:0] == 4'b0000)|
                                                (atom_bits_t4[3:0] == 4'b1010)|
                                                (atom_bits_t4[3:0] == 4'b0101))
    `SVA_FATAL("Unexpected atom packet state reached");
  usva_ap_atom_pk_state2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT5)  |-> (atom_bits_t4[4:0] == 5'b11110)|
                                                (atom_bits_t4[4:0] == 5'b00000)|
                                                (atom_bits_t4[4:0] == 5'b01010)|
                                                (atom_bits_t4[4:0] == 5'b10101))
    `SVA_FATAL("Unexpected atom packet state reached");
  usva_ap_atom_pk_count0:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_IDLE)  |-> (atom_bit_count_t4 == 3'b000))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT1)  |-> (atom_bit_count_t4 == 3'b001))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT2)  |-> (atom_bit_count_t4 == 3'b010))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count3:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT3)  |-> (atom_bit_count_t4 == 3'b011))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count4:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT4)  |-> (atom_bit_count_t4 == 3'b100))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count5:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT5)  |-> (atom_bit_count_t4 == 3'b101))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count6:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_pkg_st_t3 == ATOM_PKG_ST_FMT6)  |-> (atom_bit_count_t4 > 3'b011) | (atom_count_t4 > 5'b00100))
    `SVA_FATAL("Packet state and atom count mistmatch");
  usva_ap_atom_pk_count7:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      (atom_bit_count_t4 == 3'b111) |-> (atom_pkg_st_t3 == ATOM_PKG_ST_FMT6))
    `SVA_FATAL("Packet state and atom count mistmatch");

  usva_ap_etm_overflow_on:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    overflow_state_t4 |-> ~(trace_turnon_t3))
    `SVA_FATAL("Overflow term reachable");
  usva_ap_etm_overflow_on2_reach:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    overflow_state_t5 |-> ~trace_on_pkt_en_t4)
    `SVA_FATAL("Overflow term reachable");

  usva_context_change:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                      (trace_active_t4 | trace_pending_excep_t3) &                       
                     ~wpt_valid_t4 |->
                      (wpt_non_secure_t4 == wpt_non_secure_t5)  &
                      (wpt_aarch64_t4 == wpt_aarch64_t5)        &
                      (wpt_el_t4[1:0] == wpt_el_t5[1:0]))
           `SVA_FATAL("Context changed but no wpt_valid_noprog_t4");

  usva_active_overflow:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
            overflow_state_t3 | overflow_state_t4 |->
            ~(trace_active_t3))
           `SVA_FATAL("Coverage hole hit");
                                         
// no trace packet should be generated before turning trace on
  usva_ap_etm_no_trace_after_disabled:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    |num_bytes_t5_o |-> $past(core_at_main_run_t2_i , 1) |
                        $past(core_at_main_run_t2_i , 2) |
                        $past(core_at_main_run_t2_i , 3) |
                        $past(core_at_main_run_t2_i , 4) |
                        $past(core_at_main_run_t2_i , 5) |
                        $past(core_at_main_run_t2_i , 6) |
                        $past(core_at_main_run_t2_i , 7) |
                        $past(core_at_main_run_t2_i , 8) |
                        $past(core_at_main_run_t2_i , 9) )
    `SVA_FATAL("trace data generated when trace was disabled");

  usva_ap_enable_after_gen:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    |num_bytes_t5_o |=> core_at_main_run_t2_i[*3])
    `SVA_FATAL("trace disabled before fifo can be idle");
    

// Packing controls - must have increasing position.
// at 1 only for some lanes, and that implies previous lane was 0 or not used
// Helper for packet decode properties
  usva_ap_etm_final_0:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_0_t4 != 2'b11) |-> (final_16_0_t4 == 2'b00))
    `SVA_FATAL("Illegal pack control state byte 0");

  usva_ap_etm_final_1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_1_t4 == 4'b0001) & (final_16_0_t4 != 3'b111) |-> (final_16_0_t4 == 3'b000))
    `SVA_FATAL("Illegal pack control state byte 1");

  usva_ap_etm_final_1a:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_1_t4 != 4'b1111) |-> (final_16_1_t4 == 4'b0000) | (final_16_1_t4 == 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 1");

  usva_ap_etm_final_2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_2_t4 == 4'b0001) & (final_16_1_t4 != 4'b1111) |-> (final_16_1_t4 == 4'b0000))
    `SVA_FATAL("Illegal pack control state byte 2");

  usva_ap_etm_final_3:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_3_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 3");

  usva_ap_etm_final_4:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_4_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 4");

  usva_ap_etm_final_5:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_5_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 5");

  usva_ap_etm_final_6:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_6_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 6");

  usva_ap_etm_final_7:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_7_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 7");

  usva_ap_etm_final_8:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_8_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 8");

  usva_ap_etm_final_9:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_9_t4 == 4'b0001) |-> (final_16_8_t4 == 4'b1111))
    `SVA_FATAL("Illegal pack control state byte 9");

  usva_ap_etm_final_a:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_a_t4 == 4'b0001) & (final_16_9_t4 != 4'b1111) |-> (final_16_9_t4 == 4'b0000))
    `SVA_FATAL("Illegal pack control state byte 10");

  usva_ap_etm_final_b:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_b_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 11");

  usva_ap_etm_final_c:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (final_16_c_t4 != 4'b0001))
    `SVA_FATAL("Illegal pack control state byte 12");

  // Final terms for lanes 3,5 only convey one bit of information
  usva_ap_etm_final_3_val:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                               |num_bytes_t5 &  $past(final_16_3_t4,2) != 4'hF |-> 
                                             $past(final_16_3_t4 == 4'h2,2) | 
                                             $past(final_16_3_t4 == 4'h3,2))
    `SVA_FATAL("final_16_3_t3a is 2 if used");
  usva_ap_etm_final_5_val:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                               |num_bytes_t5 &  $past(final_16_5_t4,2) != 4'hF |-> 
                                             $past(final_16_5_t4 == 4'h4,2) |
                                             $past(final_16_5_t4 == 4'h5,2))
    `SVA_FATAL("final_16_5_t3a is 3 if used");

// Trace on packet need to be generated after trace is turned on

 //
 // Check packet formats as they enter the fifo
 //
   wire [7:0]    sva_fifo_in_t5[0:27];
   wire [63:0]   sva_fifo_first;
   wire          sva_event_present_case1;         //Event packet present before Trace Info packet or without Trace Info packet
   wire          sva_event_present_case2;         //Event packet present after Trace Info packet
   wire          sva_atom1_present;
   wire [1:0]    sva_exception_present;
   reg  [39:0]   sva_first_part3;
   wire [15:0]   sva_exception_packet;
   wire [63:16]  sva_first_8_t5;
   wire [220:16] sva_unpack_fifo_in_t5;
    

   assign sva_first_8_t5[63:20] = packed_first_8_t5[46: 3];
   assign sva_first_8_t5[   19] = 1'b0;
   assign sva_first_8_t5[18:16] = packed_first_8_t5[ 2: 0];

   assign sva_unpack_fifo_in_t5[220:16] = {pack_data_out_t5[156:0], sva_first_8_t5[63:16]};

   assign sva_fifo_in_t5[ 0] = {8{|num_first8_t5_o}} ;
   assign sva_fifo_in_t5[ 1] = {8{|num_first8_t5_o}} ;
   assign sva_fifo_in_t5[ 2] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 23: 16];
   assign sva_fifo_in_t5[ 3] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 31: 24];
   assign sva_fifo_in_t5[ 4] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 39: 32];
   assign sva_fifo_in_t5[ 5] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 47: 40];
   assign sva_fifo_in_t5[ 6] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 55: 48];
   assign sva_fifo_in_t5[ 7] = {8{|num_first8_t5_o}} &  sva_unpack_fifo_in_t5[ 63: 56];
   assign sva_fifo_in_t5[ 8] = {8{|(num_bytes_t5_o-num_first8_t5_o)}} &  sva_unpack_fifo_in_t5[ 71: 64];
   assign sva_fifo_in_t5[ 9] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h01}} &  sva_unpack_fifo_in_t5[ 79: 72];
   assign sva_fifo_in_t5[10] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h02}} &  sva_unpack_fifo_in_t5[ 87: 80];
   assign sva_fifo_in_t5[11] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h03}} &  sva_unpack_fifo_in_t5[ 95: 88];
   assign sva_fifo_in_t5[12] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h04}} &  sva_unpack_fifo_in_t5[103: 96];
   assign sva_fifo_in_t5[13] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h05}} &  sva_unpack_fifo_in_t5[111:104];
   assign sva_fifo_in_t5[14] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h06}} &  sva_unpack_fifo_in_t5[119:112];
   assign sva_fifo_in_t5[15] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h07}} &  sva_unpack_fifo_in_t5[127:120];
   assign sva_fifo_in_t5[16] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h08}} &  sva_unpack_fifo_in_t5[135:128];
   assign sva_fifo_in_t5[17] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h09}} &  sva_unpack_fifo_in_t5[143:136];
   assign sva_fifo_in_t5[18] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0A}} &  sva_unpack_fifo_in_t5[151:144];
   assign sva_fifo_in_t5[19] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0B}} &  sva_unpack_fifo_in_t5[159:152];
   assign sva_fifo_in_t5[20] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0C}} &  sva_unpack_fifo_in_t5[167:160];
   assign sva_fifo_in_t5[21] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0D}} &  sva_unpack_fifo_in_t5[175:168];
   assign sva_fifo_in_t5[22] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0E}} &  sva_unpack_fifo_in_t5[183:176];
   assign sva_fifo_in_t5[23] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h0F}} &  sva_unpack_fifo_in_t5[191:184];
   assign sva_fifo_in_t5[24] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h10}} &  sva_unpack_fifo_in_t5[199:192];
   assign sva_fifo_in_t5[25] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h11}} &  sva_unpack_fifo_in_t5[207:200];
   assign sva_fifo_in_t5[26] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h12}} &  sva_unpack_fifo_in_t5[215:208];
   assign sva_fifo_in_t5[27] = {8{(num_bytes_t5_o-num_first8_t5_o) > 5'h13}} &  {3'b000, sva_unpack_fifo_in_t5[220:216]};




   genvar   sva_i;

   generate for (sva_i = 0; sva_i < 8; sva_i = sva_i + 1) begin : g_first
     assign sva_fifo_first[sva_i*8+7:sva_i*8] = (num_first8_t5_o > sva_i) ?
                                               sva_fifo_in_t5[8-num_first8_t5_o+sva_i] : 8'h00;
   end
   endgenerate


   assign sva_event_present_case1 = (sva_fifo_first[7:4]   == 4'h7) |         //byte 0
                                    (sva_fifo_first[15:12] == 4'h7);          //byte 1

   assign sva_event_present_case2 = ((sva_fifo_first[31:28] == 4'h7) & (sva_fifo_first[15:8] == 8'h01)) |   //byte 3, not trace_info_pkt_cyct0_t3
                                    ((sva_fifo_first[39:36] == 4'h7) & (sva_fifo_first[7:0]  == 8'h01)) |   //byte 4, not trace_info_pkt_cyct0_t3
                                    ((sva_fifo_first[47:44] == 4'h7) & (sva_fifo_first[7:0]  == 8'h01)) ;   //byte 5, not trace_info_pkt_cyct0_t3

   assign sva_event_present = sva_event_present_case1 | sva_event_present_case2;

   assign sva_atom1_present = (sva_fifo_first[7:6] == 2'b11);

   always @(*)
     case ({sva_atom1_present,sva_event_present})
       2'b00:sva_first_part3 = sva_fifo_first[39:0];
       2'b01:sva_first_part3 = sva_event_present_case1 ? sva_fifo_first[47:8] : sva_fifo_first[39:0];
       2'b10:sva_first_part3 = sva_fifo_first[47:8];
       2'b11:sva_first_part3 = sva_fifo_first[55:16];  //sva_event_present_case1 always true for this scenario
       default:sva_first_part3 = {40{1'bx}};
     endcase // case ({sva_atom1_present,sva_event_present})

   assign sva_trace_info_present = (sva_first_part3[7:0] == 8'h01) ?
                                    (sva_first_part3[11] ?
                                     (sva_first_part3[31] ? 3'b101 : 3'b100) :
                                      3'b011) :
                                   3'b000;


   assign sva_exception_present = {sva_first_part3[7:0] == 8'h06,1'b0};

   usva_first_decode_headers: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                  num_first8_t5_o == (sva_event_present +
                                                      sva_atom1_present +
                                                      sva_trace_info_present +
                                                      sva_exception_present))
     `SVA_FATAL("Wrong num_first8_t5_o value assigned");

   usva_decode_info12: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                   |sva_trace_info_present |->
                                   ((sva_first_part3[10:8] == 3'b001) &
                                    (sva_first_part3[15:12] == 4'b0000) &
                                    (sva_first_part3[23:17] == 7'b0000000) &
                                    (sva_first_part3[11] == sva_first_part3[16])))
     `SVA_FATAL("Wrong Trace Info packet generated");

   // Continue bit (if more than 3 bytes) must match bytes=5
   usva_decode_info3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                     sva_trace_info_present[2] |-> sva_first_part3[31] == sva_trace_info_present[0])
     `SVA_FATAL("Wrong Trace Info packet generated");

   // Allow type = 01 or 10 - may not want to use 10
   wire [1:0] sva_exception_type = {sva_first_part3[14],sva_first_part3[8]};
   usva_decode_exception: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                   |sva_exception_present |->
                                   (~sva_first_part3[15] & ((sva_exception_type == 2'b01) | (sva_exception_type == 2'b10))))
     `SVA_FATAL("Wrong Exception type generated");

   wire       sva_atom2_present;
   wire       sva_atom3_present;
   reg  [3:0] sva_addr_present;
   wire [2:0] sva_addr_exact;   // Exact match packet 0-2
   wire [1:0] sva_addr_short;
   wire [3:0] sva_addr_long;
   wire [3:0] sva_addr_context;

   wire [9:0] sva_ts_bytes;
   wire [4:0] sva_ts_present;
   wire [2:0] sva_context_present;
   wire       sva_eret_present;
   wire [1:0] sva_cc_present;
   wire       sva_trace_on_present;


   assign sva_atom2_present    = sva_fifo_in_t5[8][7:6]  == 2'b11;
   assign sva_trace_on_present = sva_fifo_in_t5[8]       == 8'h04;
   wire [3:0] sva_pos_addr_header = 4'd8 + {3'b000,sva_trace_on_present} + {3'b000,sva_atom2_present};
   wire [7:0] sva_addr_header = sva_fifo_in_t5[sva_pos_addr_header];

   assign sva_addr_exact       = {sva_addr_header == 8'h90,
                                  sva_addr_header == 8'h91,
                                  sva_addr_header == 8'h92};

   assign sva_addr_short       = {sva_addr_header == 8'h95,
                                  sva_addr_header == 8'h96};

   assign sva_addr_long        = {sva_addr_header == 8'h9A,
                                  sva_addr_header == 8'h9B,
                                  sva_addr_header == 8'h9D,
                                  sva_addr_header == 8'h9E};

   assign sva_addr_context     = {sva_addr_header == 8'h82,
                                  sva_addr_header == 8'h83,
                                  sva_addr_header == 8'h85,
                                  sva_addr_header == 8'h86};
   always @(*)
     case ({|sva_addr_exact, |sva_addr_short, |sva_addr_long, |sva_addr_context})
       4'b0000: sva_addr_present = 4'h0;
         // Address + context, address part
       4'b0001: sva_addr_present = sva_addr_header[2] ? 4'h9 : 4'h5 ;
         // Long address packets
       4'b0010: sva_addr_present = sva_addr_header[2] ? 4'h9 : 4'h5 ;
         // Short address packets
       4'b0100: sva_addr_present = sva_fifo_in_t5[sva_pos_addr_header+1][7] ? 4'h3 : 4'h2;
         // Exact match
       4'b1000: sva_addr_present = 4'h1;
       default: sva_addr_present = 4'hX;
     endcase // case {|sva_addr_exact,


   assign sva_ts_bytes[0] = sva_fifo_in_t5[8][7:1] == 7'h01;
   assign sva_ts_bytes[1] = sva_ts_bytes[0];
   assign sva_ts_bytes[2] = sva_ts_bytes[1] & sva_fifo_in_t5[ 9][7];
   assign sva_ts_bytes[3] = sva_ts_bytes[2] & sva_fifo_in_t5[10][7];
   assign sva_ts_bytes[4] = sva_ts_bytes[3] & sva_fifo_in_t5[11][7];
   assign sva_ts_bytes[5] = sva_ts_bytes[4] & sva_fifo_in_t5[12][7];
   assign sva_ts_bytes[6] = sva_ts_bytes[5] & sva_fifo_in_t5[13][7];
   assign sva_ts_bytes[7] = sva_ts_bytes[6] & sva_fifo_in_t5[14][7];
   assign sva_ts_bytes[8] = sva_ts_bytes[7] & sva_fifo_in_t5[15][7];
   assign sva_ts_bytes[9] = sva_ts_bytes[8] & sva_fifo_in_t5[16][7];

   assign sva_ts_present = sva_ts_bytes[0] +
                             sva_ts_bytes[1] +
                             sva_ts_bytes[2] +
                             sva_ts_bytes[3] +
                             sva_ts_bytes[4] +
                             sva_ts_bytes[5] +
                             sva_ts_bytes[6] +
                             sva_ts_bytes[7] +
                             sva_ts_bytes[8] +
                             sva_ts_bytes[9];


   wire [4:0] sva_context_info_pos = 5'h08 + {4'h0,sva_trace_on_present} + {4'h0,sva_atom2_present}
                                             + {1'b0,sva_addr_present}     + {4'h0,~(|sva_addr_context)};
   wire [7:0] sva_context_info = sva_fifo_in_t5[sva_context_info_pos];
   wire       sva_context_no_header = |{sva_addr_context};
   wire [4:0] sva_context_header_pos = 5'h08 + {4'h0,sva_trace_on_present} + {4'h0,sva_atom2_present} + {1'b0,sva_addr_present};
   wire [7:0] sva_context_header = sva_context_no_header ? 8'h00 :
                                                      sva_fifo_in_t5[sva_context_header_pos];
   wire [2:0] sva_context_payload = ({2'b00,sva_context_info[6]} + // V bit
                                     {sva_context_info[7],2'b00}); // C bit


   assign   sva_context_present = ((sva_context_header == 8'h80) | (sva_context_header == 8'h81) | (|sva_addr_context)) ?
                                      (({1'b0,~|sva_addr_context & sva_context_header[0],|sva_addr_context | ~sva_context_header[0]}) +  
                                      //(header) + info (1 or 2 for stand alone, 1 if part of address)
                                       ({3{|sva_addr_context | (sva_context_header[0])}} & sva_context_payload)) :
                                      3'b000;

   assign     sva_eret_present = sva_fifo_in_t5[8+sva_trace_on_present+sva_atom2_present+sva_addr_present+sva_context_present] == 8'h07;
   wire [7:0] sva_possible_cc_header = sva_fifo_in_t5[8+sva_trace_on_present+sva_atom2_present+sva_addr_present+sva_context_present+sva_eret_present];
   wire [7:0] sva_possible_a3_header_pos = 8'h8+{7'h0,sva_trace_on_present}+{7'h0,sva_atom2_present}+{3'h0,sva_addr_present}+
                                                {5'h0,sva_context_present}+{7'h0,sva_eret_present}+{3'h0,sva_ts_present}+{6'h0,sva_cc_present};
   wire [7:0] sva_possible_a3_header = (sva_possible_a3_header_pos == 8'h1c) ? 8'h00 : sva_fifo_in_t5[sva_possible_a3_header_pos];
   wire [7:0] sva_possible_cc_byte1  = (sva_fifo_in_t5[8] == 8'h3) ?
              sva_fifo_in_t5[8+sva_ts_present] :
              sva_fifo_in_t5[9+sva_trace_on_present+sva_atom2_present+sva_addr_present+sva_context_present+sva_eret_present];

   wire       sva_tscc = (sva_fifo_in_t5[8] == 8'h3);
   assign     sva_cc_present = ((sva_possible_cc_header == 8'h0E) | (sva_tscc)) ? //CC format 1/TS with CC
                                 ((sva_possible_cc_byte1[7]) ?
                                                         {1'b1,~sva_tscc}:{~sva_tscc,sva_tscc}):
                                 (sva_possible_cc_header[7:1] == 7'h06 ? // CC format 2
                                     2'b10 :
                                     ((sva_possible_cc_header[7:4] == 4'h1) ? // CC format 3
                               2'b01:((sva_possible_cc_header == 8'h0F)?2'b01:2'b00))
                              );

   assign sva_atom3_present = sva_possible_a3_header[7:6] == 2'b11;
                                
   usva_addr_present_reachable_check: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                  $onehot0({|sva_addr_exact, |sva_addr_short, |sva_addr_long, |sva_addr_context}))
     `SVA_FATAL("Unexpected x state reached");


   usva_full_decode_headers: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                   num_bytes_t5_o == (num_first8_t5_o +
                                      sva_atom2_present +
                                      sva_atom3_present +
                                      sva_trace_on_present +
                                      sva_addr_present +
                                      sva_ts_present +
                                      sva_context_present +
                                      sva_eret_present +
                                      sva_cc_present))
     `SVA_FATAL("incorrect num_bytes_t5_o value assigned");

  wire sva_overflow_supress    = set_overflow_t2 | overflow_supress;

   //Link pipeline stages together - helper
   usva_decode_overflow: assert property (@(posedge clk_gated)
                   sva_overflow_supress |=> ~|{sva_atom2_present,
                                               sva_atom3_present +
                                               sva_atom1_present +
                                               sva_trace_on_present,
                                               sva_addr_present,
                                               sva_ts_present,
                                               sva_eret_present,
                                               sva_cc_present})
     `SVA_FATAL("Unexpected packet generated during trace overflow");

   usva_decode_atom_exc: assert property (@(posedge clk_gated)
                                           sva_atom2_present |-> ~sva_atom3_present)
     `SVA_FATAL("Decoded atom 2 and atom3 in same cycle");
     
   usva_decode_eret_t4: assert property (@(posedge clk_gated)
                    ~sva_overflow_supress & $past(valid_excp_return_out_t4) |=> sva_eret_present)
     `SVA_FATAL("Expected exception return packet was not generated");

   usva_decode_context_t4: assert property (@(posedge clk_gated)
                    ~sva_overflow_supress & $past(context_pkt_en_t3) |=> |sva_context_present)
     `SVA_FATAL("Expected Context packet was not generated");

   usva_decode_on: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                    sva_trace_on_present |-> $past(trace_on_pkt_en_t3,2))
     `SVA_FATAL("Trace on packet was generated due to unexpected reason");

   usva_decode_a2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                    sva_atom2_present |-> $past(valid_curr_atom_packet_t4,2))
     `SVA_FATAL("Atom packet was generated due to unexpected reason");

   usva_decode_a_fmt1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                    sva_atom2_present |-> sva_fifo_in_t5[8][7:1]  == 7'b1111011)
     `SVA_FATAL("Atom (position2) was not format1");

   usva_decode_br: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                    |sva_addr_present |-> sva_addr_present == $past(num_addr_bytes_t3[3:0] & {4{valid_branch_packet_t3}},2))
     `SVA_FATAL("Incorrect Address packet was generated");

   usva_decode_br_sz: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                               (sva_addr_present == 0) |
                               (sva_addr_present == 1) |
                               (sva_addr_present == 2) |
                               (sva_addr_present == 3) |
                               (sva_addr_present == 4) |
                               (sva_addr_present == 5) |
                               (sva_addr_present == 9))
     `SVA_FATAL("Incorrect Address packet was generated");

   usva_decode_cid: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |sva_context_present |-> sva_context_present == $past(cid_numb_bytes_t3,2))
     `SVA_FATAL("Incorrect Context packet was generated");

   usva_decode_cc: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |sva_cc_present & ~sva_ts_bytes[0] |-> sva_cc_present == $past(num_cycle_bytes_t3,2))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");
   // Helper for usva_decode_cc
   usva_decode_cc2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       (|num_cycle_bytes_t3 | ts_output_en_t3)##1 ~sva_overflow_supress[*2] |->
                                     sva_cc_present == ($past(num_cycle_bytes_t3,2) + 
                                     $past(ts_byteb_t3_en & ts_output_en_t3,2) + 
                                     $past(ts_bytea_t3_en & ts_output_en_t3,2)))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");
   usva_decode_cc3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       ~|num_cycle_bytes_t3 & ~ts_output_en_t3 ##1 ~sva_overflow_supress[*2] |->
                                     ~|sva_cc_present)
     `SVA_FATAL("Incorrect Cycle Count packet was generated");
     
// Helpers: To permit counter value to be cut/abstracted at wpt_cycle_counter_t4
   usva_cc_cut_value: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    (wpt_cycle_counter_t4 > 12'h001) |=>
                                    (wpt_cycle_counter_t4 == 12'h000) |
                                    (wpt_cycle_counter_t4 == 12'h001) |
                                    (wpt_cycle_counter_t4 == ($past(wpt_cycle_counter_t4) + 12'h001)))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");
   usva_cc_cut_increment: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    (~cc_pkt_b0_en_t3 & ~excep_pkt_gen_t3 & ~overflow_state_t3 & trace_enable_t4 & ~cycle_count_unknown) |=>
                                    (wpt_cycle_counter_t4 == ($past(wpt_cycle_counter_t4) + 12'h001)))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");

   usva_cc_cut_reset: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    cc_pkt_b0_en_t3 |=> 
                                    (wpt_cycle_counter_t4 == 12'h001))
     `SVA_FATAL("Cycle Count not reset");
   usva_cc_cut_zero: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                     cycle_count_unknown & ~cc_pkt_b0_en_t3|=> 
                                    (wpt_cycle_counter_t4 == 12'h000))
     `SVA_FATAL("Cycle Count not set unknown");

   usva_decode_cc_b0: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       cc_pkt_b0_en_t3 & ~cc_pkt_b1_en_t3 & ~sva_overflow_supress ##1 
                        ~sva_overflow_supress |=> (sva_cc_present == 2'b01))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");

   usva_decode_cc_b1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       cc_pkt_b1_en_t3 & ~cc_pkt_b2_en_t3 |-> ##2((sva_cc_present == 2'b10) | sva_overflow_supress))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");
     
   usva_decode_cc_b2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       cc_pkt_b2_en_t3 & ~sva_overflow_supress ##1 
                                         ~sva_overflow_supress|=> (sva_cc_present == 2'b11))
     `SVA_FATAL("Incorrect Cycle Count packet was generated");

   usva_decode_info_cid: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |sva_context_present |-> (sva_context_info == $past(context_info_t3,2)) |
                                                (sva_fifo_in_t5[sva_context_header_pos] == 8'h80))
     `SVA_FATAL("Incorrect Context packet Info was generated");

   usva_decode_ret: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       sva_eret_present |-> $past(valid_excp_return_out_t4,2))
     `SVA_FATAL("Incorrect Exception Return packet was generated");

   usva_decode_ts: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |sva_ts_present |-> ((sva_ts_present + sva_cc_present) == $past(ts_num_bytes_t4)))
     `SVA_FATAL("Incorrect TimeStamp packet was generated");

   // Timestamp means no other upper pack packets
   usva_decode_ts_only: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                       |sva_ts_present |-> ~|{sva_atom2_present,sva_trace_on_present,
                                              sva_addr_present,sva_context_present,
                                              sva_eret_present})
     `SVA_FATAL("Unexpected TimeStamp packet was generated");

  // Show stalled timestamp is released when going idle
   usva_ts_stall_idle1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        ts_output_en_pend_int_t3 &
                                         ~set_overflow_t4 &
                                        (fifo_level28_t7_i & ~auxctlr_frc_ts_nodelay_reg_i) &
                                        (trace_idle_state_cnt_t3[3:2] == 2'b01) &
                                        (&trace_idle_state_cnt_t3[1:0]) |->
                                        ts_output_en_t3 | ts_valid_t3)
     `SVA_WARN("Waiting TimeStamp packet not output when going to idle state");
   usva_ts_stall_idle2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        ts_output_en_pend_int_t3 &
                                         ~set_overflow_t4 &
                                        (fifo_level28_t7_i & ~auxctlr_frc_ts_nodelay_reg_i) &
                                        (trace_idle_state_cnt_t3[3:2] == 2'b01) &
                                        (&trace_idle_state_cnt_t3[1:0]) &
                                         ~ts_valid_t3 |->
                                        ts_output_en_t3)
     `SVA_WARN("Waiting TimeStamp packet not output when going to idle state");

   // These two signals are generated combinatorially in each cycle for timing
   usva_ts_stall_pipe: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
       ##1 $past(ts_output_en_t3) == ts_output_en_t4)
     `SVA_ERROR("Early timestamp signal not set");

   // Unreachable code assertion for first_8_packed_t3
   usva_first_8_packed_t3_unreachable_1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    excep_pkt_gen_t3 |-> ~trace_info_pkt_en_t3)
     `SVA_FATAL("Unexpected first_8_packed_t3 control reached 5'b11xxx");

   // Covers x001x, x010x, x011x
   usva_first_8_packed_t3_unreachable_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     trace_info_pkt_cyct1_en_t3 |-> trace_info_pkt_cyct0_en_t3)
     `SVA_FATAL("Unexpected first_8_packed_t3 control. Incomplete trace_info packet");
   usva_first_8_packed_t3_unreachable_3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     trace_info_pkt_cyct0_en_t3 |-> trace_info_pkt_en_t3)
     `SVA_FATAL("Unexpected first_8_packed_t3 control. Incomplete trace_info packet");
     

   usva_pack4_and_ts: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                       ts_output_en_t3 |->
                                       ~valid_excp_return_out_t4)
     `SVA_FATAL("Exception return should not be generated with Timestamp packet");

   // Helper for idle state count
   usva_idle_overflow: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
            trace_idle_state_t3 == CA53_ETM_GENIDLE_ST_OVERFLOW |->
                                        overflow_state_t4 | overflow_state_t5)
     `SVA_FATAL("Idle counter out of sync with overflow tracking");
     // Simpler term
   usva_idle_overflow_enter: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
            trace_idle_state_t3 != CA53_ETM_GENIDLE_ST_OVERFLOW ##1
            trace_idle_state_t3 == CA53_ETM_GENIDLE_ST_OVERFLOW |->
                                        overflow_state_t4 | overflow_state_t5)
     `SVA_FATAL("Idle counter out of sync with overflow tracking");
     // Idle count means trace must still be enabled
   usva_idle_count_enable: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
            trace_idle_state_t3 == CA53_ETM_GENIDLE_ST_CNT |->
                                        trace_enable_t3)
     `SVA_FATAL("Idle counter out of sync with trace enable");
     
   // Unreachable code assertion for atom_pkg_st_t3
   usva_atom_pkg_st_t3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     atom_pkg_st_t3 != ATOM_PKG_ST_UNUSED)
     `SVA_FATAL("Unexpected atom_pkg_st_t3 state reached");
     
   // Unreachable cover point
   // Non-forced atom can only take a sub-set of values for gaps between fmt 3->4,
   // and 4->6
   // Every format3 has at least 1 hole in fmt4
   // Every format4 only one path to fmt5, none to fmt6
   // Every format5 has no path to format6 so must complete
   // Format6 is terminated by N atom, or full
   usva_atom_unreach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     ~|{atom_forceout_t4,atom_completion_t3,event_pkt_en_t3} ##2 sva_atom1_present |->
     $past((atom_pkg_st_t3 == ATOM_PKG_ST_FMT3) & valid_atom_t4,2) |
     $past((atom_pkg_st_t3 == ATOM_PKG_ST_FMT4) & valid_atom_t4,2) |
     $past((atom_pkg_st_t3 == ATOM_PKG_ST_FMT5),2) |
     ($past(atom_pkg_st_t3 == ATOM_PKG_ST_FMT6,2) & sva_fifo_first[5] == 1'b1) |
     $past((atom_pkg_st_t3 == ATOM_PKG_ST_FMT6) & (atom_count_t4 == 5'h14),2))
     `SVA_WARN("Unexpected atom cover sequence detected");

   usva_atom_unreach_event: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     ~atom_completion_t3 & event_pkt_en_t3 |->
      (atom_pkg_st_t3 == ATOM_PKG_ST_IDLE))
     `SVA_WARN("Unexpected atom cover sequence detected");

   // Forceout uses both atom lanes for a clean start in the next cycle
   usva_atom_force: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     atom_forceout_t4 |=>
     (atom_pkg_st_t3 == ATOM_PKG_ST_IDLE))
     `SVA_WARN("Atom state machine must be idle after forceout");

   usva_atom_idle: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     viewinst_idle_req_t3 |-> ##2
     (atom_pkg_st_t3 == ATOM_PKG_ST_IDLE))
     `SVA_WARN("Atom state machine must be idle after forceout");
     
     // Possible format6 packet performance hole. Generate sequence x2 to verify dependant state
   usva_atom_neee_fmt6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3 == ATOM_PKG_ST_IDLE) & ~valid_atom_t4 ##1
     (valid_atom_t4 &  wpt_taken_t4 & ~atom_forceout_t4 & ~atom_completion_t3)[*3] ##1
     (valid_atom_t4 & ~wpt_taken_t4 & ~atom_forceout_t4 & ~atom_completion_t3) ##1
     (valid_atom_t4 &  wpt_taken_t4 & ~atom_forceout_t4 & ~atom_completion_t3)[*3] ##1
     (valid_atom_t4 & ~wpt_taken_t4 & ~atom_forceout_t4 & ~atom_completion_t3) ##1
     ~(overflow_supress | set_overflow_t2 | trace_idle_state_cnt_t3[3])[*3]|->
     (sva_fifo_first[7:0] == 8'b1110_0000))
          `SVA_ERROR("Format6 not used - Performance impact");

   // Functional coverage illegal     
   usva_atom_2_fmt6_illegal: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3 == ATOM_PKG_ST_FMT6) & ~wpt_taken_t4 & valid_atom_t4 |=>
     (atom_pkg_st_t3 != ATOM_PKG_ST_FMT6))
          `SVA_ERROR("Format6 with previous wpt_taken_prev_t5 is not reachable");
     
   usva_atom_fmt6_reach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                          (atom_pkg_st_t3 == ATOM_PKG_ST_FMT3) & 
                                          (atom_bits_t4[2:0] == 3'b111) |->
                                          (atom_bit_count_t4[2:0] == 3'b011))
          `SVA_ERROR("atom_pkt_format6_t3 assumes atom_bit_count_t4");

                                          
   // Simple condition, no new atom to handle
   usva_atom_ts1b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~cc_pkt_b0_en_t2          &
    ~fifo_level28_t7_i        &
    ~overflow_supress         &
    ~set_overflow_t2          &
     ts_output_en_pend_int_t3 &
    ~valid_branch_packet_t3   &
    ~context_pkt_en_t3        &
    ~valid_atom_t4            &
    ~excep_pkt_gen_t3         &
     (atom_pkg_st_t3 != ATOM_PKG_ST_IDLE) |->
     atom_pkt_gen_t4          &
     ts_output_en_t3)
     `SVA_WARN("Performance issue with timestamp insertion (corner case)");
   // New Atom at same time as timestamp
   usva_atom_ts2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~cc_pkt_b0_en_t2          &
    ~cc_pkt_b0_en_t3          &
    ~fifo_level28_t7_i        &
    ~overflow_supress         &
    ~set_overflow_t2          &
     ts_output_en_pend_int_t3 &
    ~valid_branch_packet_t3   &
    ~context_pkt_en_t3        &
     valid_atom_t4            &
     (atom_pkg_st_t3 != ATOM_PKG_ST_IDLE) |->
     atom_pkt_gen_t4          &
     ts_output_en_t3)
     `SVA_WARN("Performance issue with timestamp insertion");

// Coverage investigations
   usva_os_lock_idle2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      wpt_valid_t3 & $past(os_lock_set_t3) & ~viewinst_idle_req_t3 |-> ~trace_pending_excep_t3 & ~wpt_traced_t3)
     `SVA_ERROR("viewinst_idle_req_t3 must be high after os_lock_set_t3 if trace is enabled");

   usva_cycle_count_value: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     ts_output_en_t3 & |wpt_cycle_counter_t4[11:0] |-> cycle_counting_reg_i)
     `SVA_ERROR("Cycle count inserted in timestamp packet when not enabled");

   usva_atom_active: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3[2:0] != ATOM_PKG_ST_IDLE) |->
     (trace_active_t4 | trace_active_en_t5) & 
     ~trace_info_pkt_en_t3)
     `SVA_ERROR("Atoms being traced, but trace is inactive");

   usva_atom_eret: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     valid_excp_return_out_t4 |->valid_branch_packet_t3)
     `SVA_ERROR("Exception return is a type of branch packet");
  //wpt_valid_noprog_t4 not needed to qualify debug entry exceptions
   usva_atom_exception: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3[2:0] != ATOM_PKG_ST_IDLE) & (wpt_type_t4[2:0] == `CA53_ETM_WPT_DBGENTRY) |-> wpt_valid_noprog_t4 | ~trace_active_t4)
     `SVA_ERROR("Debug entry is always trace off");
   usva_atom_debug: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3[2:0] != 0) & trace_active_t4  & (wpt_type_t4[2:0] == 4) |->
      valid_branch_packet_t3 | excep_pkt_gen_t3);
   usva_atom_prohib: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (atom_pkg_st_t3[2:0] != 0) &  trace_active_t4 |-> ~wpt_prohibited_t5);

   // Enable term in numb_bytes_first8_update_en_t3
   usva_first_enable: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     numb_bytes_first8_update_t3 != numb_bytes_first8_update_t4 |-> trace_enable_t5 | trace_enable_tx);
   usva_ts_enable: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
       (ts_ready_t3 | ts_valid_t4 | ts_value_en_t2) |->
       core_at_main_run_t2_i & trace_enable_t4)
     `SVA_ERROR("Timestamp generated when ETM not enabled");
   usva_atom_enable: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     curr_atom_pkt_gen_t4 |-> trace_active_t4)
     `SVA_ERROR("Current atom can only be generated when trace is active or was in previous cycle");
   usva_excep_enable: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     wpt_valid_t3 & (trace_pending_excep_t3 | wpt_traced_t3) |-> trace_enable_t2 | viewinst_idle_req_t3)
     `SVA_ERROR("Tracing exception, but trace not enabled");

   usva_atom_ts_reach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     valid_curr_atom_packet_t4 |-> ~ts_output_en_poss_t3)
     `SVA_ERROR("Timestamp should not be possible when atom lane 2 is in use.");

`endif
     

endmodule // ca53etm_trace_gen
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53_dpu_etm_defs.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/
