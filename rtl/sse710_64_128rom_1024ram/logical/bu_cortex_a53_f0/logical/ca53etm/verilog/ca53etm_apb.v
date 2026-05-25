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

// This block does the following operations:
// 1) Instantiate most registers which are in the clk_gated domain.
// 2) Implement handshaking for reading and writing
//    these registers.
// 3) The registers which have an effect due to their writing are
//    instantiated in the blocks which use them.

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_apb (



//
// Interface Signals
// =================
//

// Global inputs
  input wire           clk_gated,                                       // CPU clock
  input wire           po_reset_n,                                         // Debug trace reset

  //APB interface
  input  wire          clk_reg_req_i,                                   //APB select
  input  wire  [31:0]  gov_pwdatadbg_i,                                 //APB write data
  input  wire  [11:2]  gov_paddrdbg_i,                                  //APB address
  input  wire          gov_pwritedbg_i,                                 //APB read/write control
  input  wire          gov_etmpdsr_rd_i,                                //SW unlock or external access
  output wire  [31:0]  etm_prdatadbg_o,                                 //APB read data
  output wire          etm_preadydbg_o,                                 //APB control


// Inputs

  input wire           atb_reg_ack_i,                                   // Register Ack from ATCLK Domain
  input wire           atb_afvalid_i,                                   // AFVALID for integration register
  input wire           atb_atready_i,                                   // ATREADY for integration register
  input wire  [6:0]    etm_atidm_reg_i,                                 // AT ID register read value

  input wire           trcstatr_idle_i,                                 // Idle bit read value in status register
  input wire           trcstatr_pmstable_i,                             // PMSTABLE bit read value in status register
  input wire           viewinst_sstatus_i,                              // Start Stop bit read value in View Inst Register
  input wire  [15:0]   counter0_value_i,                                // Counter 0 Read value
  input wire  [15:0]   counter1_value_i,                                // Counter 1 Read value
  input wire  [1:0]    seq_state_t2_i,                                  // Sequencer Current state Read value
  input wire           ssc_status_t2_i,                                 // Single Shot Comparator state Read value

// Outputs

  output wire          int_test_enable_o,                               // Integration Test Enable
  output wire          write_at_id_o,                                   // Write to AT ID register
  output wire          write_ir_atb_out_o,                              // Write to Integration Control Register
  output wire          write_ir_atb_data_o,                             // Write to Integration Data Register
  output wire          apb_pwdatadbg_31_o,                              // APB write data bit 31
  output wire [16:0]   apb_pwdatadbg_16to0_o,                           // APB write data [16:0]

  output wire          istall_reg_o,                                    // Stall CPU control bit
  output wire [1:0]    stall_level_reg_o,                               // FIFO threshold level for stalling CPU
  output wire          trace_enable_reg_o,                              // Trace Enable Register
  output wire          etm_if_en_o,                                     // Interface enable to CPU
  output wire          etm_oslock_o,                                    // ETM OS Lock status, for top level output
  output wire          etm_os_lock_trace_o,                             // ETM OS Lock status

  output wire          vmid_reg_o,                                      // VM ID Tracing Control
  output wire          return_stack_en_reg_o,                           // Return Stack Enable Control
  output wire          timestamp_en_reg_o,                              // TimeStamp Enable Control
  output wire          context_id_reg_o,                                // Context ID Tracing control
  output wire          cycle_counting_reg_o,                            // Cycle Counting Mode Control
  output wire          branch_broadcast_reg_o,                          // Branch Broadcast Control

  output wire          lp_override_reg_o,                               // low power override
  output wire          event_atbtrig_en_reg_o,                          // ATB Trigger Enable
  output wire  [3:0]   event_enable_reg_o,                              // Enable generation of event element
  output wire  [11:0]  cc_threshold_reg_o,                              // Cycle Count Threshold Register
  output wire  [4:0]   sync_period_reg_o,                               // Synchronization Period Register
  output wire          bb_mode_reg_o,                                   // Branch Broadcast ARC Include/Exclude mode
  output wire  [3:0]   bb_range_reg_o,                                  // Branch Broadcast ARC

  output wire          viewinst_write_o,                                // ViewInst register write
  output wire  [7:0]   viewinst_start_cmp_reg_o,                        // ViewInst Start Control
  output wire  [7:0]   viewinst_stop_cmp_reg_o,                         // ViewInst Stop Control
  output wire  [4:0]   viewinst_event_reg_o,                            // ViewInst Event Register
  output wire  [2:0]   viewinst_exlevel_ns_reg_o,                       // ViewInst Non Secure Exception Level Disable
  output wire  [2:0]   viewinst_exlevel_s_reg_o,                        // ViewInst Secure Exception Level Disable
  output wire          viewinst_trcerr_reg_o,                           // ViewInst Trace System Error
  output wire          viewinst_trcreset_reg_o,                         // ViewInst Trace Reset Exception
  output wire  [3:0]   viewinst_exc_ranges_reg_o,                       // ViewInst Exclude Ranges
  output wire  [3:0]   viewinst_inc_ranges_reg_o,                       // ViewInst Include Ranges

  output wire  [4:0]   ts_event_reg_o,                                  // TimeStamp Event Register

  output wire  [48:0]  comp0_addr_reg_o,                                // Comparator 0 Address Value
  output wire  [48:0]  comp1_addr_reg_o,                                // Comparator 1 Address Value
  output wire  [48:0]  comp2_addr_reg_o,                                // Comparator 2 Address Value
  output wire  [48:0]  comp3_addr_reg_o,                                // Comparator 3 Address Value
  output wire  [48:0]  comp4_addr_reg_o,                                // Comparator 4 Address Value
  output wire  [48:0]  comp5_addr_reg_o,                                // Comparator 5 Address Value
  output wire  [48:0]  comp6_addr_reg_o,                                // Comparator 6 Address Value
  output wire  [48:0]  comp7_addr_reg_o,                                // Comparator 7 Address Value
  output wire  [2:0]   comp0_exlevel_s_reg_o,                           // Comparator 0 Secure State Control
  output wire  [2:0]   comp0_exlevel_ns_reg_o,                          // Comparator 0 Non Secure State Control
  output wire  [1:0]   comp0_context_reg_o,                             // Comparator 0 Context Control
  output wire  [2:0]   comp1_exlevel_s_reg_o,                           // Comparator 1 Secure State Control
  output wire  [2:0]   comp1_exlevel_ns_reg_o,                          // Comparator 1 Non Secure State Control
  output wire  [1:0]   comp1_context_reg_o,                             // Comparator 1 Context Control
  output wire  [2:0]   comp2_exlevel_s_reg_o,                           // Comparator 2 Secure State Control
  output wire  [2:0]   comp2_exlevel_ns_reg_o,                          // Comparator 2 Non Secure State Control
  output wire  [1:0]   comp2_context_reg_o,                             // Comparator 2 Context Control
  output wire  [2:0]   comp3_exlevel_s_reg_o,                           // Comparator 3 Secure State Control
  output wire  [2:0]   comp3_exlevel_ns_reg_o,                          // Comparator 3 Non Secure State Control
  output wire  [1:0]   comp3_context_reg_o,                             // Comparator 3 Context Control
  output wire  [2:0]   comp4_exlevel_s_reg_o,                           // Comparator 4 Secure State Control
  output wire  [2:0]   comp4_exlevel_ns_reg_o,                          // Comparator 4 Non Secure State Control
  output wire  [1:0]   comp4_context_reg_o,                             // Comparator 4 Context Control
  output wire  [2:0]   comp5_exlevel_s_reg_o,                           // Comparator 5 Secure State Control
  output wire  [2:0]   comp5_exlevel_ns_reg_o,                          // Comparator 5 Non Secure State Control
  output wire  [1:0]   comp5_context_reg_o,                             // Comparator 5 Context Control
  output wire  [2:0]   comp6_exlevel_s_reg_o,                           // Comparator 6 Secure State Control
  output wire  [2:0]   comp6_exlevel_ns_reg_o,                          // Comparator 6 Non Secure State Control
  output wire  [1:0]   comp6_context_reg_o,                             // Comparator 6 Context Control
  output wire  [2:0]   comp7_exlevel_s_reg_o,                           // Comparator 7 Secure State Control
  output wire  [2:0]   comp7_exlevel_ns_reg_o,                          // Comparator 7 Non Secure State Control
  output wire  [1:0]   comp7_context_reg_o,                             // Comparator 7 Context Control

  output wire  [31:0]  cid_comp_value_reg_o,                            // Context ID Value Register
  output wire  [3:0]   cid_comp_mask_reg_o,                             // Context ID Mask Register
  output wire  [7:0]   vmid_comp_value_reg_o,                           // VMID Value Register

  output wire  [15:0]  counter0_reload_reg_o,                           // Counter 0 Reload Register Value
  output wire  [15:0]  counter1_reload_reg_o,                           // Counter 1 Reload Register Value
  output wire  [4:0]   counter0_cntevent_reg_o,                         // Counter 0 Enable Event Register
  output wire  [4:0]   counter1_cntevent_reg_o,                         // Counter 1 Enable Event Register
  output wire          counter0_rldself_reg_o,                          // Counter 0 Self Reload Mode
  output wire          counter1_rldself_reg_o,                          // Counter 1 Self Reload Mode
  output wire          counter1_cntchain_reg_o,                         // Counter 1 Chain Mode
  output wire  [4:0]   counter0_rldevent_reg_o,                         // Counter 0 Reload Event Register
  output wire  [4:0]   counter1_rldevent_reg_o,                         // Counter 1 Reload Event Register
  output wire          counter0_write_o,                                // Write to Counter 0
  output wire          counter1_write_o,                                // Write to Counter 1
  output wire          counter0_control_write_o,                        // Write to Counter Control 0
  output wire          counter1_control_write_o,                        // Write to Counter Control 1

  output wire  [4:0]   seq_transition_b0_reg_o,                         // Sequencer B0 Transition Event Register
  output wire  [4:0]   seq_transition_f0_reg_o,                         // Sequencer F0 Transition Event Register
  output wire  [4:0]   seq_transition_b1_reg_o,                         // Sequencer B1 Transition Event Register
  output wire  [4:0]   seq_transition_f1_reg_o,                         // Sequencer F1 Transition Event Register
  output wire  [4:0]   seq_transition_b2_reg_o,                         // Sequencer B2 Transition Event Register
  output wire  [4:0]   seq_transition_f2_reg_o,                         // Sequencer F2 Transition Event Register
  output wire  [4:0]   seq_rst_reg_o,                                   // Sequencer Reset Event Register
  output wire          seq_write_o,                                     // Write to Sequencer State

  output wire          ssc_rst_reg_o,                                   // Single Shot Comparator 0 Reset Control
  output wire  [3:0]   ssc_arc_reg_o,                                   // Single Shot Comparator 0 ARC Control
  output wire  [7:0]   ssc_sac_reg_o,                                   // Single Shot Comparator 0 SAC Control
  output wire          ssc_write_o,                                     // Write to Single Shot Comparator Control Status

  output wire  [4:0]   event0_sel_reg_o,                                // Event/External Output 0 Event Register
  output wire  [4:0]   event1_sel_reg_o,                                // Event/External Output 1 Event Register
  output wire  [4:0]   event2_sel_reg_o,                                // Event/External Output 2 Event Register
  output wire  [4:0]   event3_sel_reg_o,                                // Event/External Output 3 Event Register

  output wire  [4:0]   extin_sel0_reg_o,                                // Extended External Input 0 Selection
  output wire  [4:0]   extin_sel1_reg_o,                                // Extended External Input 1 Selection
  output wire  [4:0]   extin_sel2_reg_o,                                // Extended External Input 2 Selection
  output wire  [4:0]   extin_sel3_reg_o,                                // Extended External Input 3 Selection

  output wire  [7:0]   trcrsctlr2_select_reg_o,                         // Resource Selection Control Register 2 Select
  output wire  [2:0]   trcrsctlr2_group_reg_o,                          // Resource Selection Control Register 2 Group
  output wire          trcrsctlr2_inv_reg_o,                            // Resource Selection Control Register 2 Invert
  output wire          trcrsctlr2_pairinv_reg_o,                        // Resource Selection Control Register 2 Pair Invert
  output wire  [7:0]   trcrsctlr3_select_reg_o,                         // Resource Selection Control Register 3 Select
  output wire  [2:0]   trcrsctlr3_group_reg_o,                          // Resource Selection Control Register 3 Group
  output wire          trcrsctlr3_inv_reg_o,                            // Resource Selection Control Register 3 Invert
  output wire  [7:0]   trcrsctlr4_select_reg_o,                         // Resource Selection Control Register 4 Select
  output wire  [2:0]   trcrsctlr4_group_reg_o,                          // Resource Selection Control Register 4 Group
  output wire          trcrsctlr4_inv_reg_o,                            // Resource Selection Control Register 4 Invert
  output wire          trcrsctlr4_pairinv_reg_o,                        // Resource Selection Control Register 4 Pair Invert
  output wire  [7:0]   trcrsctlr5_select_reg_o,                         // Resource Selection Control Register 5 Select
  output wire  [2:0]   trcrsctlr5_group_reg_o,                          // Resource Selection Control Register 5 Group
  output wire          trcrsctlr5_inv_reg_o,                            // Resource Selection Control Register 5 Invert
  output wire  [7:0]   trcrsctlr6_select_reg_o,                         // Resource Selection Control Register 6 Select
  output wire  [2:0]   trcrsctlr6_group_reg_o,                          // Resource Selection Control Register 6 Group
  output wire          trcrsctlr6_inv_reg_o,                            // Resource Selection Control Register 6 Invert
  output wire          trcrsctlr6_pairinv_reg_o,                        // Resource Selection Control Register 6 Pair Invert
  output wire  [7:0]   trcrsctlr7_select_reg_o,                         // Resource Selection Control Register 7 Select
  output wire  [2:0]   trcrsctlr7_group_reg_o,                          // Resource Selection Control Register 7 Group
  output wire          trcrsctlr7_inv_reg_o,                            // Resource Selection Control Register 7 Invert
  output wire  [7:0]   trcrsctlr8_select_reg_o,                         // Resource Selection Control Register 8 Select
  output wire  [2:0]   trcrsctlr8_group_reg_o,                          // Resource Selection Control Register 8 Group
  output wire          trcrsctlr8_inv_reg_o,                            // Resource Selection Control Register 8 Invert
  output wire          trcrsctlr8_pairinv_reg_o,                        // Resource Selection Control Register 8 Pair Invert
  output wire  [7:0]   trcrsctlr9_select_reg_o,                         // Resource Selection Control Register 9 Select
  output wire  [2:0]   trcrsctlr9_group_reg_o,                          // Resource Selection Control Register 9 Group
  output wire          trcrsctlr9_inv_reg_o,                            // Resource Selection Control Register 9 Invert
  output wire  [7:0]   trcrsctlr10_select_reg_o,                        // Resource Selection Control Register 10 Select
  output wire  [2:0]   trcrsctlr10_group_reg_o,                         // Resource Selection Control Register 10 Group
  output wire          trcrsctlr10_inv_reg_o,                           // Resource Selection Control Register 10 Invert
  output wire          trcrsctlr10_pairinv_reg_o,                       // Resource Selection Control Register 10 Pair Invert
  output wire  [7:0]   trcrsctlr11_select_reg_o,                        // Resource Selection Control Register 11 Select
  output wire  [2:0]   trcrsctlr11_group_reg_o,                         // Resource Selection Control Register 11 Group
  output wire          trcrsctlr11_inv_reg_o,                           // Resource Selection Control Register 11 Invert
  output wire  [7:0]   trcrsctlr12_select_reg_o,                        // Resource Selection Control Register 12 Select
  output wire  [2:0]   trcrsctlr12_group_reg_o,                         // Resource Selection Control Register 12 Group
  output wire          trcrsctlr12_inv_reg_o,                           // Resource Selection Control Register 12 Invert
  output wire          trcrsctlr12_pairinv_reg_o,                       // Resource Selection Control Register 12 Pair Invert
  output wire  [7:0]   trcrsctlr13_select_reg_o,                        // Resource Selection Control Register 13 Select
  output wire  [2:0]   trcrsctlr13_group_reg_o,                         // Resource Selection Control Register 13 Group
  output wire          trcrsctlr13_inv_reg_o,                           // Resource Selection Control Register 13 Invert
  output wire  [7:0]   trcrsctlr14_select_reg_o,                        // Resource Selection Control Register 14 Select
  output wire  [2:0]   trcrsctlr14_group_reg_o,                         // Resource Selection Control Register 14 Group
  output wire          trcrsctlr14_inv_reg_o,                           // Resource Selection Control Register 14 Invert
  output wire          trcrsctlr14_pairinv_reg_o,                       // Resource Selection Control Register 14 Pair Invert
  output wire  [7:0]   trcrsctlr15_select_reg_o,                        // Resource Selection Control Register 15 Select
  output wire  [2:0]   trcrsctlr15_group_reg_o,                         // Resource Selection Control Register 15 Group
  output wire          trcrsctlr15_inv_reg_o,                           // Resource Selection Control Register 15 Invert
  output wire          auxctlr_frc_afready_reg_o,                       // always response to AFREADY immediately
  output wire          auxctlr_frc_ovflow_reg_o,                        // Forced Overflow enable
  output wire          auxctlr_frc_ts_nodelay_reg_o,                    // Timestamps delayed by fifo depth
  output wire          auxctlr_frc_sync_delay_reg_o,                    // Sync delayed by fifo depth
  output wire          auxctlr_frc_idleack_reg_o,                       // Force ETM idle acknowledgment
  output wire          auxctlr_frc_auth_noflush_reg_o                   // Disable flush when dbgniden goes low
 );


  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           addr_atb_domain;
  wire           addr_aux_control;
  wire           addr_branchbroadcast_control;
  wire           addr_cid_comp_mask;
  wire           addr_cid_comp_value;
  wire           addr_claimclr;
  wire           addr_claimset;
  wire           addr_oslar;
  wire           addr_oslsr;
  wire           addr_comp0_access;
  wire           addr_comp0_hi_addr;
  wire           addr_comp0_lo_addr;
  wire           addr_comp1_access;
  wire           addr_comp1_hi_addr;
  wire           addr_comp1_lo_addr;
  wire           addr_comp2_access;
  wire           addr_comp2_hi_addr;
  wire           addr_comp2_lo_addr;
  wire           addr_comp3_access;
  wire           addr_comp3_hi_addr;
  wire           addr_comp3_lo_addr;
  wire           addr_comp4_access;
  wire           addr_comp4_hi_addr;
  wire           addr_comp4_lo_addr;
  wire           addr_comp5_access;
  wire           addr_comp5_hi_addr;
  wire           addr_comp5_lo_addr;
  wire           addr_comp6_access;
  wire           addr_comp6_hi_addr;
  wire           addr_comp6_lo_addr;
  wire           addr_comp7_access;
  wire           addr_comp7_hi_addr;
  wire           addr_comp7_lo_addr;
  wire           addr_counter0_control;
  wire           addr_counter0_reload;
  wire           addr_counter0_value;
  wire           addr_counter1_control;
  wire           addr_counter1_reload;
  wire           addr_counter1_value;
  wire           addr_trcidr0;
  wire           addr_trcidr1;
  wire           addr_trcidr2;
  wire           addr_trcidr3;
  wire           addr_trcidr4;
  wire           addr_trcidr5;
  wire           addr_cyclecount_control;
  wire           addr_event_control0;
  wire           addr_event_control1;
  wire           addr_extin_sel;
  wire           addr_ir_atb_in;
  wire           addr_ir_atb_out;
  wire           addr_ir_atb_data;
  wire           addr_ir_itctrl;
  wire           addr_ir_atbid;
  wire           addr_prog_control;
  wire           addr_seq_rst;
  wire           addr_seq_state;
  wire           addr_seq_transition_control0;
  wire           addr_seq_transition_control1;
  wire           addr_seq_transition_control2;
  wire           addr_ssc_control;
  wire           addr_ssc_status;
  wire           addr_stall_ctrl;
  wire           addr_status;
  wire           addr_sync_period;
  wire           addr_trace_config;
  wire           addr_trace_id;
  wire           addr_trcrsctlr10;
  wire           addr_trcrsctlr11;
  wire           addr_trcrsctlr12;
  wire           addr_trcrsctlr13;
  wire           addr_trcrsctlr14;
  wire           addr_trcrsctlr15;
  wire           addr_trcrsctlr2;
  wire           addr_trcrsctlr3;
  wire           addr_trcrsctlr4;
  wire           addr_trcrsctlr5;
  wire           addr_trcrsctlr6;
  wire           addr_trcrsctlr7;
  wire           addr_trcrsctlr8;
  wire           addr_trcrsctlr9;
  wire           addr_ts_event;
  wire           addr_viewinst_control;
  wire           addr_viewinst_incexc_control;
  wire           addr_viewinst_ss_control;
  wire           addr_vmid_comp_value;
  wire           atb_ack_active;
  reg            atb_reg_ack_q;
  reg            bb_mode_reg_q;
  reg  [  3:  0] bb_range_reg_q;
  reg            branch_broadcast_reg_q;
  reg  [ 11:  0] cc_threshold_reg_q;
  reg  [  3:  0] cid_comp_mask_reg_q;
  reg  [ 31:  0] cid_comp_value_reg_q;
  wire [  3:  0] claimclr;
  wire [  3:  0] claimset;
  wire [  3:  0] claimstate;
  wire           claimstate_en;
  reg  [  3:  0] claimstate_q;
  reg  [  1:  0] comp0_context_reg_q;
  reg  [  2:  0] comp0_exlevel_ns_reg_q;
  reg  [  2:  0] comp0_exlevel_s_reg_q;
  reg  [ 16:  0] comp0_hi_addr_reg_q;
  reg  [ 31:  0] comp0_lo_addr_reg_q;
  reg  [  1:  0] comp1_context_reg_q;
  reg  [  2:  0] comp1_exlevel_ns_reg_q;
  reg  [  2:  0] comp1_exlevel_s_reg_q;
  reg  [ 16:  0] comp1_hi_addr_reg_q;
  reg  [ 31:  0] comp1_lo_addr_reg_q;
  reg  [  1:  0] comp2_context_reg_q;
  reg  [  2:  0] comp2_exlevel_ns_reg_q;
  reg  [  2:  0] comp2_exlevel_s_reg_q;
  reg  [ 16:  0] comp2_hi_addr_reg_q;
  reg  [ 31:  0] comp2_lo_addr_reg_q;
  reg  [  1:  0] comp3_context_reg_q;
  reg  [  2:  0] comp3_exlevel_ns_reg_q;
  reg  [  2:  0] comp3_exlevel_s_reg_q;
  reg  [ 16:  0] comp3_hi_addr_reg_q;
  reg  [ 31:  0] comp3_lo_addr_reg_q;
  reg  [  1:  0] comp4_context_reg_q;
  reg  [  2:  0] comp4_exlevel_ns_reg_q;
  reg  [  2:  0] comp4_exlevel_s_reg_q;
  reg  [ 16:  0] comp4_hi_addr_reg_q;
  reg  [ 31:  0] comp4_lo_addr_reg_q;
  reg  [  1:  0] comp5_context_reg_q;
  reg  [  2:  0] comp5_exlevel_ns_reg_q;
  reg  [  2:  0] comp5_exlevel_s_reg_q;
  reg  [ 16:  0] comp5_hi_addr_reg_q;
  reg  [ 31:  0] comp5_lo_addr_reg_q;
  reg  [  1:  0] comp6_context_reg_q;
  reg  [  2:  0] comp6_exlevel_ns_reg_q;
  reg  [  2:  0] comp6_exlevel_s_reg_q;
  reg  [ 16:  0] comp6_hi_addr_reg_q;
  reg  [ 31:  0] comp6_lo_addr_reg_q;
  reg  [  1:  0] comp7_context_reg_q;
  reg  [  2:  0] comp7_exlevel_ns_reg_q;
  reg  [  2:  0] comp7_exlevel_s_reg_q;
  reg  [ 16:  0] comp7_hi_addr_reg_q;
  reg  [ 31:  0] comp7_lo_addr_reg_q;
  reg            context_id_reg_q;
  reg  [  4:  0] counter0_cntevent_reg_q;
  reg  [ 15:  0] counter0_reload_reg_q;
  reg  [  4:  0] counter0_rldevent_reg_q;
  reg            counter0_rldself_reg_q;
  reg            counter1_cntchain_reg_q;
  reg  [  4:  0] counter1_cntevent_reg_q;
  reg  [ 15:  0] counter1_reload_reg_q;
  reg  [  4:  0] counter1_rldevent_reg_q;
  reg            counter1_rldself_reg_q;
  reg            cycle_counting_reg_q;
  reg            auxctlr_frc_idleack_reg;
  reg            auxctlr_frc_coreifen_reg;
  reg            auxctlr_frc_auth_noflush_reg;
  reg            auxctlr_frc_ts_nodelay_reg;
  reg            auxctlr_frc_sync_delay_reg;
  reg            auxctlr_frc_ovflow_reg;
  reg            auxctlr_frc_afready_reg;
  wire           reg_req_en;
  reg            reg_req_q;
  wire           reg_sel_en;
  wire           reg_sel_d;
  reg            reg_sel_q;
  reg  [  4:  0] event0_sel_reg_q;
  reg  [  4:  0] event1_sel_reg_q;
  reg  [  4:  0] event2_sel_reg_q;
  reg  [  4:  0] event3_sel_reg_q;
  reg            lp_override_reg_q;
  reg            event_atbtrig_en_reg_q;
  reg  [  3:  0] event_enable_reg_q;
  reg  [  4:  0] extin_sel0_reg_q;
  reg  [  4:  0] extin_sel1_reg_q;
  reg  [  4:  0] extin_sel2_reg_q;
  reg  [  4:  0] extin_sel3_reg_q;
  reg            istall_reg_q;
  reg  [  1:  0] stall_level_reg_q;
  reg            int_test_enable_q;
  wire           reg_ack;
  wire           reg_ack_en;
  reg            reg_ack_q;
  wire [ 31:  0] reg_rdata;
  reg  [ 31:  0] reg_rdata_q;
  reg            return_stack_en_reg_q;
  reg  [  4:  0] seq_rst_reg_q;
  reg  [  4:  0] seq_transition_b0_reg_q;
  reg  [  4:  0] seq_transition_b1_reg_q;
  reg  [  4:  0] seq_transition_b2_reg_q;
  reg  [  4:  0] seq_transition_f0_reg_q;
  reg  [  4:  0] seq_transition_f1_reg_q;
  reg  [  4:  0] seq_transition_f2_reg_q;
  reg  [  3:  0] ssc_arc_reg_q;
  reg            ssc_rst_reg_q;
  reg  [  7:  0] ssc_sac_reg_q;
  reg  [  4:  0] sync_period_reg_q;
  reg            timestamp_en_reg_q;
  reg            trace_enable_reg;
  reg  [  2:  0] trcrsctlr10_group_reg_q;
  reg            trcrsctlr10_inv_reg_q;
  reg            trcrsctlr10_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr10_select_reg_q;
  reg  [  2:  0] trcrsctlr11_group_reg_q;
  reg            trcrsctlr11_inv_reg_q;
  reg  [  7:  0] trcrsctlr11_select_reg_q;
  reg  [  2:  0] trcrsctlr12_group_reg_q;
  reg            trcrsctlr12_inv_reg_q;
  reg            trcrsctlr12_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr12_select_reg_q;
  reg  [  2:  0] trcrsctlr13_group_reg_q;
  reg            trcrsctlr13_inv_reg_q;
  reg  [  7:  0] trcrsctlr13_select_reg_q;
  reg  [  2:  0] trcrsctlr14_group_reg_q;
  reg            trcrsctlr14_inv_reg_q;
  reg            trcrsctlr14_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr14_select_reg_q;
  reg  [  2:  0] trcrsctlr15_group_reg_q;
  reg            trcrsctlr15_inv_reg_q;
  reg  [  7:  0] trcrsctlr15_select_reg_q;
  reg  [  2:  0] trcrsctlr2_group_reg_q;
  reg            trcrsctlr2_inv_reg_q;
  reg            trcrsctlr2_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr2_select_reg_q;
  reg  [  2:  0] trcrsctlr3_group_reg_q;
  reg            trcrsctlr3_inv_reg_q;
  reg  [  7:  0] trcrsctlr3_select_reg_q;
  reg  [  2:  0] trcrsctlr4_group_reg_q;
  reg            trcrsctlr4_inv_reg_q;
  reg            trcrsctlr4_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr4_select_reg_q;
  reg  [  2:  0] trcrsctlr5_group_reg_q;
  reg            trcrsctlr5_inv_reg_q;
  reg  [  7:  0] trcrsctlr5_select_reg_q;
  reg  [  2:  0] trcrsctlr6_group_reg_q;
  reg            trcrsctlr6_inv_reg_q;
  reg            trcrsctlr6_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr6_select_reg_q;
  reg  [  2:  0] trcrsctlr7_group_reg_q;
  reg            trcrsctlr7_inv_reg_q;
  reg  [  7:  0] trcrsctlr7_select_reg_q;
  reg  [  2:  0] trcrsctlr8_group_reg_q;
  reg            trcrsctlr8_inv_reg_q;
  reg            trcrsctlr8_pairinv_reg_q;
  reg  [  7:  0] trcrsctlr8_select_reg_q;
  reg  [  2:  0] trcrsctlr9_group_reg_q;
  reg            trcrsctlr9_inv_reg_q;
  reg  [  7:  0] trcrsctlr9_select_reg_q;
  reg  [  4:  0] ts_event_reg_q;
  reg  [  4:  0] viewinst_event_reg_q;
  reg  [  3:  0] viewinst_exc_ranges_reg_q;
  reg  [  2:  0] viewinst_exlevel_ns_reg_q;
  reg  [  2:  0] viewinst_exlevel_s_reg_q;
  reg  [  3:  0] viewinst_inc_ranges_reg_q;
  reg  [  7:  0] viewinst_start_cmp_reg_q;
  reg  [  7:  0] viewinst_stop_cmp_reg_q;
  reg            viewinst_trcerr_reg_q;
  reg            viewinst_trcreset_reg_q;
  reg  [  7:  0] vmid_comp_value_reg_q;
  reg            vmid_reg_q;
  reg            etm_os_lock_q;
  reg            etm_os_lock_trace_q;
  wire           etm_os_lock_trace;
  reg            sticky_pd_q;
  wire           write_active;
  wire           write_always_active;
  wire           write_atb_domain;
  wire           write_aux_control;
  wire           write_branchbroadcast_control;
  wire           write_cid_comp_mask;
  wire           write_cid_comp_value;
  wire           write_comp0_access;
  wire           write_comp0_hi_addr;
  wire           write_comp0_lo_addr;
  wire           write_comp1_access;
  wire           write_comp1_hi_addr;
  wire           write_comp1_lo_addr;
  wire           write_comp2_access;
  wire           write_comp2_hi_addr;
  wire           write_comp2_lo_addr;
  wire           write_comp3_access;
  wire           write_comp3_hi_addr;
  wire           write_comp3_lo_addr;
  wire           write_comp4_access;
  wire           write_comp4_hi_addr;
  wire           write_comp4_lo_addr;
  wire           write_comp5_access;
  wire           write_comp5_hi_addr;
  wire           write_comp5_lo_addr;
  wire           write_comp6_access;
  wire           write_comp6_hi_addr;
  wire           write_comp6_lo_addr;
  wire           write_comp7_access;
  wire           write_comp7_hi_addr;
  wire           write_comp7_lo_addr;
  wire           write_counter0_control;
  wire           write_counter0_reload;
  wire           write_counter0_value;
  wire           write_counter1_control;
  wire           write_counter1_reload;
  wire           write_counter1_value;
  wire           write_cyclecount_control;
  wire           write_event_control0;
  wire           write_event_control1;
  wire           write_extin_sel;
  wire           write_itctrcl;
  wire           write_prog_control;
  wire           write_seq_rst;
  wire           write_seq_state;
  wire           write_seq_transition_control0;
  wire           write_seq_transition_control1;
  wire           write_seq_transition_control2;
  wire           write_ssc_control;
  wire           write_ssc_status;
  wire           write_stall_ctrl;
  wire           write_sync_period;
  wire           write_trace_config;
  wire           write_oslar;
  wire           write_trcrsctlr10;
  wire           write_trcrsctlr11;
  wire           write_trcrsctlr12;
  wire           write_trcrsctlr13;
  wire           write_trcrsctlr14;
  wire           write_trcrsctlr15;
  wire           write_trcrsctlr2;
  wire           write_trcrsctlr3;
  wire           write_trcrsctlr4;
  wire           write_trcrsctlr5;
  wire           write_trcrsctlr6;
  wire           write_trcrsctlr7;
  wire           write_trcrsctlr8;
  wire           write_trcrsctlr9;
  wire           write_ts_event;
  wire           write_viewinst_control;
  wire           write_viewinst_incexc_control;
  wire           write_viewinst_ss_control;
  wire           write_vmid_comp_value;
  wire  [11:2]   et_reg_addr;                                   // Register Address
  wire  [31:0]   et_reg_wdata;                                  // Write Data for Register
  wire           et_reg_write;                                  // Register Write/!Read
  wire           addr_pdsr;
  wire           stick_pd_clear;

  wire  [31:0]   et_reg_rdata;                                  // Register Read Value
  reg [11:2]     gov_paddrdbg_q;                                // APB address
  reg [31:0]     gov_pwdatadbg_q;                               // APB write data
  reg            gov_pwritedbg_q;                               // APB write signal
  reg            gov_etmpdsr_rd_q;                              // SW unlock or external debugger access
  
//----------------------------------------------------------------------------
// Main Code
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// APB and Internal register read write signals
//----------------------------------------------------------------------------
  always @(posedge clk_gated or negedge po_reset_n)
    begin: ugov_paddrdbg_q
    if (!po_reset_n)
      gov_paddrdbg_q    <= {10{1'b0}};
    else if (clk_reg_req_i)
      gov_paddrdbg_q    <= gov_paddrdbg_i;
    end
  
  always @(posedge clk_gated)
    begin: ugov_pwdatadbg_q
      if (clk_reg_req_i) begin
          gov_pwdatadbg_q   <= gov_pwdatadbg_i;
          gov_pwritedbg_q   <= gov_pwritedbg_i;
          gov_etmpdsr_rd_q  <= gov_etmpdsr_rd_i;
      end
    end

  //register read/write enable
  //inputs
  assign et_reg_wdata = gov_pwdatadbg_q;
  assign et_reg_write = gov_pwritedbg_q & gov_etmpdsr_rd_q;
  assign et_reg_addr  = gov_paddrdbg_q;
  //outputs
  assign etm_prdatadbg_o       = et_reg_rdata;
  assign apb_pwdatadbg_16to0_o = gov_pwdatadbg_q[16:0];
  assign apb_pwdatadbg_31_o    = gov_pwdatadbg_q[31];

//----------------------------------------------------------------------------
// Register Write Control Logic
//----------------------------------------------------------------------------
// Detect start of transaction and register to use for write enable
// PCLK registers respond with single wait state
// ATCLK registers respond after 4 phase handshake through ATCLKEN
//       This handshake is requested by psel
  assign reg_req_en = (reg_req_q | clk_reg_req_i);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureg_req_q
    if (!po_reset_n)
      reg_req_q <= 1'b0;
    else if (reg_req_en)
      reg_req_q <= clk_reg_req_i;
  end

  assign reg_sel_en = (reg_sel_q | clk_reg_req_i);
  assign reg_sel_d  = clk_reg_req_i | (reg_sel_q & ~reg_ack_q);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureg_sel_q
    if (!po_reset_n)
      reg_sel_q <= 1'b0;
    else if (reg_sel_en)
      reg_sel_q <= reg_sel_d;
  end


// Keep write active valid for only one cycle
  assign write_always_active = reg_req_q & et_reg_write;

// Ignore writes to trace registers except TRCPRGCTLR, TRCCLAIMSET and TRCCLAIMCLR
// when trace is enabled
  assign write_active = write_always_active & (~trace_enable_reg | etm_os_lock_q);


//---------------------------------------------------------------------------
// Trace registers
//---------------------------------------------------------------------------

//______________________________________________________________________________________________________
// Block  |  Registers  | 32/64 |   Trace or    |      Purpose                                          |
// Number |             |  bit  |   Management  |                                                       |
//________|_____________|_______|_______________|_______________________________________________________|
//   0    |    0-31     |  32   |   Trace       |   Main control and configuration                      |
//   1    |    32-63    |  32   |   Trace       |   Trace filtering controls                            |
//   2    |    64-95    |  32   |   Trace       |   Derived resources                                   |
//   3    |    96-127   |  32   |   Trace       |   Implementation Defined and ID registers             |
//   4    |    128-159  |  32   |   Trace       |   Resource Selectors                                  |
//   5    |    160-191  |  32   |   Trace       |   Single-Shot Comparator Control                      |
//   6    |    192-223  |  32   |   Management  |   OS Lock and Power Control                           |
//   7    |    224-255  |  -    |   -           |   Reserved                                            |
//   8    |    256-287  |  64   |   Trace       |   Address Comparator Value Registers                  |
//   9    |    288-319  |  64   |   Trace       |   Address Comparator Access Type Registers            |
//   10   |    320-351  |  64   |   Trace       |   Data Value Comparator Value Registers               |
//   11   |    352-383  |  64   |   Trace       |   Data Value Comparator Mask                          |
//   12   |    384-415  |  64   |   Trace       |   Context Comparators                                 |
//   13   |    416-447  |  32   |   Trace       |   Context Comparator Controls                         |
//  14-28 |    448-927  |  -    |   -           |   Reserved                                            |
//   29   |    928-959  |  -    |   -           |   Reserved for IMPLEMENTATION DEFINED Integration and |
//        |             |       |               |   Topology Detection Registers.                       |
//  30-31 |    960-1023 |  32   |   Management  |   CoreSight Management Registers                      |
//________|_____________|_______|_______________|_ _____________________________________________________|

//---------------------------------------------------------------------------
// Main Control and Configuration Registers
//---------------------------------------------------------------------------

// TRCPRGCTLR
// Programming Control Register
// Register 1   Offset 0x004
  assign addr_prog_control  = (et_reg_addr[11:2] == 10'h001);
  assign write_prog_control = write_always_active & addr_prog_control;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_enable_reg
    if (!po_reset_n)
      trace_enable_reg <= 1'b0;
    else if (write_prog_control)
      trace_enable_reg <= et_reg_wdata[0];
  end


  assign trace_enable_reg_o = trace_enable_reg;

// TRCSTATR
// Status Register
// Register 3   Offset 0x00C
// Read only
  assign addr_status = (et_reg_addr[11:2] == 10'h003);

// TRCCONFIGR
// Trace Configuration Register
// Register 4   Offset 0x010
  assign addr_trace_config  = (et_reg_addr[11:2] == 10'h004);
  assign write_trace_config = write_active & addr_trace_config;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: utrace_config_q
    if (!po_reset_n) begin
      return_stack_en_reg_q  <= 1'b0;
      timestamp_en_reg_q     <= 1'b0;
      vmid_reg_q             <= 1'b0;
      context_id_reg_q       <= 1'b0;
      cycle_counting_reg_q   <= 1'b0;
      branch_broadcast_reg_q <= 1'b0;
    end
    else if (write_trace_config) begin
      return_stack_en_reg_q  <= et_reg_wdata[12];
      timestamp_en_reg_q     <= et_reg_wdata[11];
      vmid_reg_q             <= et_reg_wdata[7];
      context_id_reg_q       <= et_reg_wdata[6];
      cycle_counting_reg_q   <= et_reg_wdata[4];
      branch_broadcast_reg_q <= et_reg_wdata[3];
    end
  end


  assign return_stack_en_reg_o = return_stack_en_reg_q;
  assign timestamp_en_reg_o    = timestamp_en_reg_q;
  assign vmid_reg_o            = vmid_reg_q;
  assign context_id_reg_o      = context_id_reg_q;
  assign cycle_counting_reg_o  = cycle_counting_reg_q;
  assign branch_broadcast_reg_o= branch_broadcast_reg_q;

// TRCAUXCTLR
// Auxiliary Control Register
// Register 6   Offset 0x018

  assign addr_aux_control  = (et_reg_addr[11:2] == 10'h006);
  assign write_aux_control =  write_active & addr_aux_control;
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uaux_control_q
    if (!po_reset_n) begin
      auxctlr_frc_coreifen_reg     <= 1'b0;
      auxctlr_frc_auth_noflush_reg <= 1'b0;
      auxctlr_frc_ts_nodelay_reg   <= 1'b0;
      auxctlr_frc_sync_delay_reg   <= 1'b0;
      auxctlr_frc_ovflow_reg       <= 1'b0;
      auxctlr_frc_idleack_reg      <= 1'b0;
      auxctlr_frc_afready_reg      <= 1'b0;
    end
    else if (write_aux_control) begin
      auxctlr_frc_coreifen_reg     <= et_reg_wdata[7];
      auxctlr_frc_auth_noflush_reg <= et_reg_wdata[5];
      auxctlr_frc_ts_nodelay_reg   <= et_reg_wdata[4];
      auxctlr_frc_sync_delay_reg   <= et_reg_wdata[3];
      auxctlr_frc_ovflow_reg       <= et_reg_wdata[2];
      auxctlr_frc_idleack_reg      <= et_reg_wdata[1];
      auxctlr_frc_afready_reg      <= et_reg_wdata[0];
    end
  end // block: uaux_control_q


  assign auxctlr_frc_auth_noflush_reg_o = auxctlr_frc_auth_noflush_reg;
  assign auxctlr_frc_ts_nodelay_reg_o   = auxctlr_frc_ts_nodelay_reg;
  assign auxctlr_frc_sync_delay_reg_o   = auxctlr_frc_sync_delay_reg;
  assign auxctlr_frc_ovflow_reg_o       = auxctlr_frc_ovflow_reg;
  assign auxctlr_frc_idleack_reg_o      = auxctlr_frc_idleack_reg;
  assign auxctlr_frc_afready_reg_o      = auxctlr_frc_afready_reg;
  assign etm_if_en_o                    = trace_enable_reg | auxctlr_frc_coreifen_reg;



// TRCEVENTCTL0R
// Event Control 0 Register
// Register 8   Offset 0x020
  assign addr_event_control0  = (et_reg_addr[11:2] == 10'h008);
  assign write_event_control0 =  write_active & addr_event_control0;

  always @(posedge clk_gated)
  begin: uevent_control0_q
    if (write_event_control0) begin
      event3_sel_reg_q[4:0] <= {et_reg_wdata[31], et_reg_wdata[27:24]};
      event2_sel_reg_q[4:0] <= {et_reg_wdata[23], et_reg_wdata[19:16]};
      event1_sel_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      event0_sel_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign event3_sel_reg_o[4:0] = event3_sel_reg_q[4:0];
  assign event2_sel_reg_o[4:0] = event2_sel_reg_q[4:0];
  assign event1_sel_reg_o[4:0] = event1_sel_reg_q[4:0];
  assign event0_sel_reg_o[4:0] = event0_sel_reg_q[4:0];

// TRCEVENTCTL1R
// Event Control 1 Register
// Register 9   Offset 0x024
  assign addr_event_control1  = (et_reg_addr[11:2] == 10'h009);
  assign write_event_control1 =  write_active & addr_event_control1;

  always @(posedge clk_gated)
  begin: uevent_control1_q
    if (write_event_control1) begin
      lp_override_reg_q       <= et_reg_wdata[12];
      event_atbtrig_en_reg_q  <= et_reg_wdata[11];
      event_enable_reg_q[3:0] <= et_reg_wdata[3:0];
    end
  end


  assign lp_override_reg_o      = lp_override_reg_q;
  assign event_atbtrig_en_reg_o = event_atbtrig_en_reg_q;
  assign event_enable_reg_o[3:0]= event_enable_reg_q[3:0];

// TRCSTALLCTLR
// Stall control register
// Register 11   Offset 0x02C
  assign addr_stall_ctrl  = (et_reg_addr[11:2] == 10'h00B);
  assign write_stall_ctrl =  write_active & addr_stall_ctrl;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ustall_ctrl_q
    if (!po_reset_n) begin
      istall_reg_q            <= 1'b0;
      stall_level_reg_q[1:0]  <= {2{1'b0}};
    end
    else if (write_stall_ctrl) begin
      istall_reg_q            <= et_reg_wdata[8];
      stall_level_reg_q[1:0]  <= et_reg_wdata[3:2];
    end
  end

  assign istall_reg_o            = istall_reg_q;
  assign stall_level_reg_o[1:0]  = stall_level_reg_q[1:0];


// TRCTSCTLR
// Global Timestamp Control Register
// Register 12   Offset 0x030
  assign addr_ts_event  = (et_reg_addr[11:2] == 10'h00C);
  assign write_ts_event = write_active & addr_ts_event;

  always @(posedge clk_gated)
  begin: uts_event_reg_q_4_0
    if (write_ts_event)
      ts_event_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
  end


  assign ts_event_reg_o[4:0] = ts_event_reg_q[4:0];

// TRCSYNCPR
// Synchronization Period Register
// Register 13   Offset 0x034
  assign addr_sync_period  = (et_reg_addr[11:2] == 10'h00D);
  assign write_sync_period = write_active & addr_sync_period;

  always @(posedge clk_gated)
  begin: usync_period_reg_q_4_0
    if (write_sync_period)
      sync_period_reg_q[4:0] <= et_reg_wdata[4:0];
  end


  assign sync_period_reg_o[4:0] = sync_period_reg_q[4:0];

// TRCCCCTLR
// Cycle Count Control Register
// Register 14   Offset 0x038
  assign addr_cyclecount_control  = (et_reg_addr[11:2] == 10'h00E);
  assign write_cyclecount_control = write_active & addr_cyclecount_control;

  always @(posedge clk_gated)
  begin: ucc_threshold_reg_q_11_0
    if (write_cyclecount_control)
      cc_threshold_reg_q[11:0] <= et_reg_wdata[11:0];
  end


  assign cc_threshold_reg_o[11:0] = cc_threshold_reg_q[11:0];

// TRCBBCTLR
// Branch Broadcast Control Register
// Register 15   Offset 0x03C
  assign addr_branchbroadcast_control  = (et_reg_addr[11:2] == 10'h00F);
  assign write_branchbroadcast_control = write_active & addr_branchbroadcast_control;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ubranchbroadcast_control_q
    if (!po_reset_n) begin
      bb_mode_reg_q       <= 1'b0;
      bb_range_reg_q[3:0] <= {4{1'b0}};
      end
    else if (write_branchbroadcast_control) begin
      bb_mode_reg_q       <= et_reg_wdata[8];
      bb_range_reg_q[3:0] <= et_reg_wdata[3:0];
      end
  end
  
  assign bb_mode_reg_o       = bb_mode_reg_q;
  assign bb_range_reg_o[3:0] = bb_range_reg_q[3:0];

// TRCTRACEIDR
// Trace ID Register
// Register 16   Offset 0x040
// Implemented in ATB domain
  assign addr_trace_id = (et_reg_addr[11:2] == 10'h010);


//---------------------------------------------------------------------------
// Trace Filtering Control Registers
//---------------------------------------------------------------------------

// TRCVICTLR
// ViewInst Main Control Register
// Register 32   Offset 0x080
  assign addr_viewinst_control  = (et_reg_addr[11:2] == 10'h020);
  assign write_viewinst_control = write_active & addr_viewinst_control;

  always @(posedge clk_gated)
  begin: uviewinst_control_q
    if (write_viewinst_control) begin
      viewinst_exlevel_ns_reg_q[2:0] <= et_reg_wdata[22:20];
      viewinst_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[19], et_reg_wdata[17:16]};
      viewinst_trcerr_reg_q          <= et_reg_wdata[11];
      viewinst_trcreset_reg_q        <= et_reg_wdata[10];
      viewinst_event_reg_q[4:0]      <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign viewinst_exlevel_ns_reg_o[2:0] = viewinst_exlevel_ns_reg_q[2:0];
  assign viewinst_exlevel_s_reg_o[2:0]  = viewinst_exlevel_s_reg_q[2:0];
  assign viewinst_trcerr_reg_o          = viewinst_trcerr_reg_q;
  assign viewinst_trcreset_reg_o        = viewinst_trcreset_reg_q;
  assign viewinst_event_reg_o[4:0]      = viewinst_event_reg_q[4:0];

  assign viewinst_write_o = write_viewinst_control;

// TRCVIIECTLR
// ViewInst Include/Exclude Control Register
// Register 33   Offset 0x084
  assign addr_viewinst_incexc_control  = (et_reg_addr[11:2] == 10'h021);
  assign write_viewinst_incexc_control = write_active & addr_viewinst_incexc_control;

  always @(posedge clk_gated)
  begin: uviewinst_incexc_control_q
    if (write_viewinst_incexc_control) begin
      viewinst_exc_ranges_reg_q[3:0] <= et_reg_wdata[19:16];
      viewinst_inc_ranges_reg_q[3:0] <= et_reg_wdata[3:0];
    end
  end


  assign viewinst_exc_ranges_reg_o[3:0] = viewinst_exc_ranges_reg_q[3:0];
  assign viewinst_inc_ranges_reg_o[3:0] = viewinst_inc_ranges_reg_q[3:0];

// TRCVISSCTLR
// ViewInst Start/Stop Control Register
// Register 34   Offset 0x088
  assign addr_viewinst_ss_control  = (et_reg_addr[11:2] == 10'h022);
  assign write_viewinst_ss_control = write_active & addr_viewinst_ss_control;

  always @(posedge clk_gated)
  begin: uviewinst_ss_control_q
    if (write_viewinst_ss_control) begin
      viewinst_stop_cmp_reg_q[7:0]  <= et_reg_wdata[23:16];
      viewinst_start_cmp_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign viewinst_stop_cmp_reg_o[7:0]  = viewinst_stop_cmp_reg_q[7:0];
  assign viewinst_start_cmp_reg_o[7:0] = viewinst_start_cmp_reg_q[7:0];


//---------------------------------------------------------------------------
// Derived Resources
//---------------------------------------------------------------------------

// TRCSEQEVR0
// Sequencer State Transition Control Register 0
// Register 64   Offset 0x100
  assign addr_seq_transition_control0  = (et_reg_addr[11:2] == 10'h040);
  assign write_seq_transition_control0 = write_active & addr_seq_transition_control0;

  always @(posedge clk_gated)
  begin: useq_transition_control0_q
    if (write_seq_transition_control0) begin
      seq_transition_b0_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      seq_transition_f0_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign seq_transition_b0_reg_o[4:0] = seq_transition_b0_reg_q[4:0];
  assign seq_transition_f0_reg_o[4:0] = seq_transition_f0_reg_q[4:0];

// TRCSEQEVR1
// Sequencer State Transition Control Register 1
// Register 65   Offset 0x104
  assign addr_seq_transition_control1  = (et_reg_addr[11:2] == 10'h041);
  assign write_seq_transition_control1 = write_active & addr_seq_transition_control1;

  always @(posedge clk_gated)
  begin: useq_transition_control1_q
    if (write_seq_transition_control1) begin
      seq_transition_b1_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      seq_transition_f1_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign seq_transition_b1_reg_o[4:0] = seq_transition_b1_reg_q[4:0];
  assign seq_transition_f1_reg_o[4:0] = seq_transition_f1_reg_q[4:0];

// TRCSEQEVR2
// Sequencer State Transition Control Register 2
// Register 66   Offset 0x108
  assign addr_seq_transition_control2  = (et_reg_addr[11:2] == 10'h042);
  assign write_seq_transition_control2 = write_active & addr_seq_transition_control2;

  always @(posedge clk_gated)
  begin: useq_transition_control2_q
    if (write_seq_transition_control2) begin
      seq_transition_b2_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      seq_transition_f2_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign seq_transition_b2_reg_o[4:0] = seq_transition_b2_reg_q[4:0];
  assign seq_transition_f2_reg_o[4:0] = seq_transition_f2_reg_q[4:0];

// TRCSEQRSTEVR
// Sequencer Reset Control Register
// Register 70   Offset 0x118
  assign addr_seq_rst  = (et_reg_addr[11:2] == 10'h046);
  assign write_seq_rst = write_active & addr_seq_rst;

  always @(posedge clk_gated)
  begin: useq_rst_reg_q_4_0
    if (write_seq_rst)
      seq_rst_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
  end


  assign seq_rst_reg_o[4:0] = seq_rst_reg_q[4:0];

// TRCSEQSTR
// Sequencer State Register
// Register 71   Offset 0x11C
  assign addr_seq_state  = (et_reg_addr[11:2] == 10'h047);
  assign write_seq_state = write_active & addr_seq_state;

// Sequencer implemented in derived resources
  assign seq_write_o = write_seq_state;

// TRCEXTINSELR
// External Input Select Register
// Register 72   Offset 0x120
  assign addr_extin_sel  = (et_reg_addr[11:2] == 10'h048);
  assign write_extin_sel = write_active & addr_extin_sel;

  always @(posedge clk_gated)
  begin: uextin_sel_q
    if (write_extin_sel) begin
      extin_sel3_reg_q[4:0] <= et_reg_wdata[28:24];
      extin_sel2_reg_q[4:0] <= et_reg_wdata[20:16];
      extin_sel1_reg_q[4:0] <= et_reg_wdata[12:8];
      extin_sel0_reg_q[4:0] <= et_reg_wdata[4:0];
    end
  end


  assign extin_sel3_reg_o[4:0] = extin_sel3_reg_q[4:0];
  assign extin_sel2_reg_o[4:0] = extin_sel2_reg_q[4:0];
  assign extin_sel1_reg_o[4:0] = extin_sel1_reg_q[4:0];
  assign extin_sel0_reg_o[4:0] = extin_sel0_reg_q[4:0];

// TRCCNTRLDVR0
// Counter Reload Value Register 0
// Register 80   Offset 0x140
  assign addr_counter0_reload  = (et_reg_addr[11:2] == 10'h050);
  assign write_counter0_reload = write_active & addr_counter0_reload;

  always @(posedge clk_gated)
  begin: ucounter0_reload_reg_q_15_0
    if (write_counter0_reload)
      counter0_reload_reg_q[15:0] <= et_reg_wdata[15:0];
  end


  assign counter0_reload_reg_o[15:0] = counter0_reload_reg_q[15:0];

// TRCCNTRLDVR1
// Counter Reload Value Register 1
// Register 81   Offset 0x144
  assign addr_counter1_reload  = (et_reg_addr[11:2] == 10'h051);
  assign write_counter1_reload = write_active & addr_counter1_reload;

  always @(posedge clk_gated)
  begin: ucounter1_reload_reg_q_15_0
    if (write_counter1_reload)
      counter1_reload_reg_q[15:0] <= et_reg_wdata[15:0];
  end


  assign counter1_reload_reg_o[15:0] = counter1_reload_reg_q[15:0];

// TRCCNTCTLR0
// Counter Control Register 0
// Register 84   Offset 0x150
  assign addr_counter0_control  = (et_reg_addr[11:2] == 10'h054);
  assign write_counter0_control = write_active & addr_counter0_control;

  // Reset for X-prop reasons
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucounter0_rld_self_q
    if (!po_reset_n)
      counter0_rldself_reg_q       <= 1'b0;
    else if (write_counter0_control)
      counter0_rldself_reg_q       <= et_reg_wdata[16];
  end
  
  always @(posedge clk_gated)
  begin: ucounter0_control_q
    if (write_counter0_control) begin
      counter0_rldevent_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      counter0_cntevent_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign counter0_rldself_reg_o       = counter0_rldself_reg_q;
  assign counter0_rldevent_reg_o[4:0] = counter0_rldevent_reg_q[4:0];
  assign counter0_cntevent_reg_o[4:0] = counter0_cntevent_reg_q[4:0];

// TRCCNTCTLR1
// Counter Control Register 1
// Register 85   Offset 0x154
  assign addr_counter1_control  = (et_reg_addr[11:2] == 10'h055);
  assign write_counter1_control = write_active & addr_counter1_control;

  // Reset for X-prop reasons
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucounter1_rld_self_q
    if (!po_reset_n)
      counter1_rldself_reg_q       <= 1'b0;
    else if (write_counter1_control)
      counter1_rldself_reg_q       <= et_reg_wdata[16];
  end


  always @(posedge clk_gated)
  begin: ucounter1_control_q
    if (write_counter1_control) begin
      counter1_cntchain_reg_q      <= et_reg_wdata[17];
      counter1_rldevent_reg_q[4:0] <= {et_reg_wdata[15], et_reg_wdata[11:8]};
      counter1_cntevent_reg_q[4:0] <= {et_reg_wdata[7], et_reg_wdata[3:0]};
    end
  end


  assign counter1_cntchain_reg_o      = counter1_cntchain_reg_q;
  assign counter1_rldself_reg_o       = counter1_rldself_reg_q;
  assign counter1_rldevent_reg_o[4:0] = counter1_rldevent_reg_q[4:0];
  assign counter1_cntevent_reg_o[4:0] = counter1_cntevent_reg_q[4:0];

// TRCCNTVR0
// Counter Value Register 0
// Register 88   Offset 0x160
  assign addr_counter0_value  = (et_reg_addr[11:2] == 10'h058);
  assign write_counter0_value = write_active & addr_counter0_value;

// Counter implemented in derived resources
  assign counter0_write_o         = write_counter0_value;
  assign counter0_control_write_o = write_counter0_control;

// TRCCNTVR1
// Counter Value Register 1
// Register 89   Offset 0x164
  assign addr_counter1_value  = (et_reg_addr[11:2] == 10'h059);
  assign write_counter1_value = write_active & addr_counter1_value;

// Counter implemented in derived resources
  assign counter1_write_o         = write_counter1_value;
  assign counter1_control_write_o = write_counter1_control;

//---------------------------------------------------------------------------
// ID Registers
//---------------------------------------------------------------------------
// TRCIDR0
// Trace ID register 0
// Register 120   Offset 0x1E0
  assign addr_trcidr0  = (et_reg_addr[11:2] == 10'h078);

// TRCIDR1
// Trace ID register 1
// Register 121   Offset 0x1E4
  assign addr_trcidr1  = (et_reg_addr[11:2] == 10'h079);

// TRCIDR2
// Trace ID register 2
// Register 122   Offset 0x1E8
  assign addr_trcidr2  = (et_reg_addr[11:2] == 10'h07A);

// TRCIDR3
// Trace ID register 3
// Register 123   Offset 0x1EC
  assign addr_trcidr3  = (et_reg_addr[11:2] == 10'h07B);

// TRCIDR4
// Trace ID register 4
// Register 124   Offset 0x1F0
  assign addr_trcidr4  = (et_reg_addr[11:2] == 10'h07C);

// TRCIDR5
// Trace ID register 5
// Register 125   Offset 0x1F4
  assign addr_trcidr5  = (et_reg_addr[11:2] == 10'h07D);

//---------------------------------------------------------------------------
// Resource Selection Control Registers
//---------------------------------------------------------------------------

// TRCRSCTLR2
// Resource Selection Control Register 2
// Register 130   Offset 0x208
  assign addr_trcrsctlr2  = (et_reg_addr[11:2] == 10'h082);
  assign write_trcrsctlr2 = write_active & addr_trcrsctlr2;

  always @(posedge clk_gated)
  begin: utrcrsctlr2_reg_q
    if (write_trcrsctlr2) begin
      trcrsctlr2_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr2_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr2_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr2_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr2_pairinv_reg_o     = trcrsctlr2_pairinv_reg_q;
  assign trcrsctlr2_inv_reg_o         = trcrsctlr2_inv_reg_q;
  assign trcrsctlr2_group_reg_o[2:0]  = trcrsctlr2_group_reg_q[2:0];
  assign trcrsctlr2_select_reg_o[7:0] = trcrsctlr2_select_reg_q[7:0];

// TRCRSCTLR3
// Resource Selection Control Register 3
// Register 131   Offset 0x20C
  assign addr_trcrsctlr3  = (et_reg_addr[11:2] == 10'h083);
  assign write_trcrsctlr3 = write_active & addr_trcrsctlr3;

  always @(posedge clk_gated)
  begin: utrcrsctlr3_reg_q
    if (write_trcrsctlr3) begin
      trcrsctlr3_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr3_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr3_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr3_inv_reg_o         = trcrsctlr3_inv_reg_q;
  assign trcrsctlr3_group_reg_o[2:0]  = trcrsctlr3_group_reg_q[2:0];
  assign trcrsctlr3_select_reg_o[7:0] = trcrsctlr3_select_reg_q[7:0];

// TRCRSCTLR4
// Resource Selection Control Register 4
// Register 132   Offset 0x210
  assign addr_trcrsctlr4  = (et_reg_addr[11:2] == 10'h084);
  assign write_trcrsctlr4 = write_active & addr_trcrsctlr4;

  always @(posedge clk_gated)
  begin: utrcrsctlr4_reg_q
    if (write_trcrsctlr4) begin
      trcrsctlr4_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr4_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr4_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr4_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr4_pairinv_reg_o     = trcrsctlr4_pairinv_reg_q;
  assign trcrsctlr4_inv_reg_o         = trcrsctlr4_inv_reg_q;
  assign trcrsctlr4_group_reg_o[2:0]  = trcrsctlr4_group_reg_q[2:0];
  assign trcrsctlr4_select_reg_o[7:0] = trcrsctlr4_select_reg_q[7:0];

// TRCRSCTLR5
// Resource Selection Control Register 5
// Register 133   Offset 0x214
  assign addr_trcrsctlr5  = (et_reg_addr[11:2] == 10'h085);
  assign write_trcrsctlr5 = write_active & addr_trcrsctlr5;

  always @(posedge clk_gated)
  begin: utrcrsctlr5_reg_q
    if (write_trcrsctlr5) begin
      trcrsctlr5_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr5_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr5_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr5_inv_reg_o         = trcrsctlr5_inv_reg_q;
  assign trcrsctlr5_group_reg_o[2:0]  = trcrsctlr5_group_reg_q[2:0];
  assign trcrsctlr5_select_reg_o[7:0] = trcrsctlr5_select_reg_q[7:0];

// TRCRSCTLR6
// Resource Selection Control Register 6
// Register 134   Offset 0x218
  assign addr_trcrsctlr6  = (et_reg_addr[11:2] == 10'h086);
  assign write_trcrsctlr6 = write_active & addr_trcrsctlr6;

  always @(posedge clk_gated)
  begin: utrcrsctlr6_reg_q
    if (write_trcrsctlr6) begin
      trcrsctlr6_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr6_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr6_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr6_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr6_pairinv_reg_o     = trcrsctlr6_pairinv_reg_q;
  assign trcrsctlr6_inv_reg_o         = trcrsctlr6_inv_reg_q;
  assign trcrsctlr6_group_reg_o[2:0]  = trcrsctlr6_group_reg_q[2:0];
  assign trcrsctlr6_select_reg_o[7:0] = trcrsctlr6_select_reg_q[7:0];

// TRCRSCTLR7
// Resource Selection Control Register 7
// Register 135   Offset 0x21C
  assign addr_trcrsctlr7  = (et_reg_addr[11:2] == 10'h087);
  assign write_trcrsctlr7 = write_active & addr_trcrsctlr7;

  always @(posedge clk_gated)
  begin: utrcrsctlr7_reg_q
    if (write_trcrsctlr7) begin
      trcrsctlr7_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr7_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr7_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr7_inv_reg_o         = trcrsctlr7_inv_reg_q;
  assign trcrsctlr7_group_reg_o[2:0]  = trcrsctlr7_group_reg_q[2:0];
  assign trcrsctlr7_select_reg_o[7:0] = trcrsctlr7_select_reg_q[7:0];

// TRCRSCTLR8
// Resource Selection Control Register 8
// Register 136   Offset 0x220
  assign addr_trcrsctlr8  = (et_reg_addr[11:2] == 10'h088);
  assign write_trcrsctlr8 =  write_active & addr_trcrsctlr8;

  always @(posedge clk_gated)
  begin: utrcrsctlr8_reg_q
    if (write_trcrsctlr8) begin
      trcrsctlr8_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr8_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr8_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr8_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr8_pairinv_reg_o     = trcrsctlr8_pairinv_reg_q;
  assign trcrsctlr8_inv_reg_o         = trcrsctlr8_inv_reg_q;
  assign trcrsctlr8_group_reg_o[2:0]  = trcrsctlr8_group_reg_q[2:0];
  assign trcrsctlr8_select_reg_o[7:0] = trcrsctlr8_select_reg_q[7:0];

// TRCRSCTLR9
// Resource Selection Control Register 9
// Register 137   Offset 0x224
  assign addr_trcrsctlr9  = (et_reg_addr[11:2] == 10'h089);
  assign write_trcrsctlr9 =  write_active & addr_trcrsctlr9;

  always @(posedge clk_gated)
  begin: utrcrsctlr9_reg_q
    if (write_trcrsctlr9) begin
      trcrsctlr9_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr9_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr9_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr9_inv_reg_o         = trcrsctlr9_inv_reg_q;
  assign trcrsctlr9_group_reg_o[2:0]  = trcrsctlr9_group_reg_q[2:0];
  assign trcrsctlr9_select_reg_o[7:0] = trcrsctlr9_select_reg_q[7:0];

// TRCRSCTLR10
// Resource Selection Control Register 10
// Register 138   Offset 0x228
  assign addr_trcrsctlr10  = (et_reg_addr[11:2] == 10'h08A);
  assign write_trcrsctlr10 =  write_active & addr_trcrsctlr10;

  always @(posedge clk_gated)
  begin: utrcrsctlr10_reg_q
    if (write_trcrsctlr10) begin
      trcrsctlr10_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr10_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr10_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr10_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr10_pairinv_reg_o     = trcrsctlr10_pairinv_reg_q;
  assign trcrsctlr10_inv_reg_o         = trcrsctlr10_inv_reg_q;
  assign trcrsctlr10_group_reg_o[2:0]  = trcrsctlr10_group_reg_q[2:0];
  assign trcrsctlr10_select_reg_o[7:0] = trcrsctlr10_select_reg_q[7:0];

// TRCRSCTLR11
// Resource Selection Control Register 11
// Register 139   Offset 0x22C
  assign addr_trcrsctlr11  = (et_reg_addr[11:2] == 10'h08B);
  assign write_trcrsctlr11 =  write_active & addr_trcrsctlr11;

  always @(posedge clk_gated)
  begin: utrcrsctlr11_reg_q
    if (write_trcrsctlr11) begin
      trcrsctlr11_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr11_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr11_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr11_inv_reg_o         = trcrsctlr11_inv_reg_q;
  assign trcrsctlr11_group_reg_o[2:0]  = trcrsctlr11_group_reg_q[2:0];
  assign trcrsctlr11_select_reg_o[7:0] = trcrsctlr11_select_reg_q[7:0];

// TRCRSCTLR12
// Resource Selection Control Register 12
// Register 140   Offset 0x230
  assign addr_trcrsctlr12  = (et_reg_addr[11:2] == 10'h08C);
  assign write_trcrsctlr12 =  write_active & addr_trcrsctlr12;

  always @(posedge clk_gated)
  begin: utrcrsctlr12_reg_q
    if (write_trcrsctlr12) begin
      trcrsctlr12_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr12_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr12_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr12_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr12_pairinv_reg_o     = trcrsctlr12_pairinv_reg_q;
  assign trcrsctlr12_inv_reg_o         = trcrsctlr12_inv_reg_q;
  assign trcrsctlr12_group_reg_o[2:0]  = trcrsctlr12_group_reg_q[2:0];
  assign trcrsctlr12_select_reg_o[7:0] = trcrsctlr12_select_reg_q[7:0];

// TRCRSCTLR13
// Resource Selection Control Register 13
// Register 141   Offset 0x234
  assign addr_trcrsctlr13  = (et_reg_addr[11:2] == 10'h08D);
  assign write_trcrsctlr13 =  write_active & addr_trcrsctlr13;

  always @(posedge clk_gated)
  begin: utrcrsctlr13_reg_q
    if (write_trcrsctlr13) begin
      trcrsctlr13_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr13_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr13_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr13_inv_reg_o         = trcrsctlr13_inv_reg_q;
  assign trcrsctlr13_group_reg_o[2:0]  = trcrsctlr13_group_reg_q[2:0];
  assign trcrsctlr13_select_reg_o[7:0] = trcrsctlr13_select_reg_q[7:0];

// TRCRSCTLR14
// Resource Selection Control Register 14
// Register 142   Offset 0x238
  assign addr_trcrsctlr14  = (et_reg_addr[11:2] == 10'h08E);
  assign write_trcrsctlr14 =  write_active & addr_trcrsctlr14;

  always @(posedge clk_gated)
  begin: utrcrsctlr14_reg_q
    if (write_trcrsctlr14) begin
      trcrsctlr14_pairinv_reg_q     <= et_reg_wdata[21];
      trcrsctlr14_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr14_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr14_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr14_pairinv_reg_o     = trcrsctlr14_pairinv_reg_q;
  assign trcrsctlr14_inv_reg_o         = trcrsctlr14_inv_reg_q;
  assign trcrsctlr14_group_reg_o[2:0]  = trcrsctlr14_group_reg_q[2:0];
  assign trcrsctlr14_select_reg_o[7:0] = trcrsctlr14_select_reg_q[7:0];

// TRCRSCTLR15
// Resource Selection Control Register 15
// Register 143   Offset 0x23C
  assign addr_trcrsctlr15  = (et_reg_addr[11:2] == 10'h08F);
  assign write_trcrsctlr15 =  write_active & addr_trcrsctlr15;

  always @(posedge clk_gated)
  begin: utrcrsctlr15_reg_q
    if (write_trcrsctlr15) begin
      trcrsctlr15_inv_reg_q         <= et_reg_wdata[20];
      trcrsctlr15_group_reg_q[2:0]  <= et_reg_wdata[18:16];
      trcrsctlr15_select_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign trcrsctlr15_inv_reg_o         = trcrsctlr15_inv_reg_q;
  assign trcrsctlr15_group_reg_o[2:0]  = trcrsctlr15_group_reg_q[2:0];
  assign trcrsctlr15_select_reg_o[7:0] = trcrsctlr15_select_reg_q[7:0];

//---------------------------------------------------------------------------
// Single-Shot Comparator Registers
//---------------------------------------------------------------------------

// TRCSSCCR0
// Single-Shot Comparator Control Register 0
// Register 160   Offset 0x280
  assign addr_ssc_control  = (et_reg_addr[11:2] == 10'h0A0);
  assign write_ssc_control =  write_active & addr_ssc_control;

  // Reset for C-prop reasons
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ussc_control_reg_q
    if (!po_reset_n) begin
      ssc_rst_reg_q      <= 1'b0;
      ssc_arc_reg_q[3:0] <= {4{1'b0}};
      ssc_sac_reg_q[7:0] <= {8{1'b0}};
    end
    else if (write_ssc_control) begin
      ssc_rst_reg_q      <= et_reg_wdata[24];
      ssc_arc_reg_q[3:0] <= et_reg_wdata[19:16];
      ssc_sac_reg_q[7:0] <= et_reg_wdata[7:0];
    end
  end


  assign ssc_rst_reg_o      = ssc_rst_reg_q;
  assign ssc_arc_reg_o[3:0] = ssc_arc_reg_q[3:0];
  assign ssc_sac_reg_o[7:0] = ssc_sac_reg_q[7:0];

// TRCSSCSR0
// Single-Shot Comparator Status Register 0
// Register 168   Offset 0x2A0
  assign addr_ssc_status  = (et_reg_addr[11:2] == 10'h0A8);
  assign write_ssc_status =  write_active & addr_ssc_status;

// SSC implemented in derived resources
  assign ssc_write_o = write_ssc_status;

//---------------------------------------------------------------------------
// Power Control Registers
//---------------------------------------------------------------------------
// Management Registers implemented outside of ETM

//---------------------------------------------------------------------------
// Address Comparator Value Registers
//---------------------------------------------------------------------------

// TRCACVR0
// Address Comparator Value Register 0
// Register 256   Offset 0x400
  assign addr_comp0_lo_addr  = (et_reg_addr[11:2] == 10'h100);
  assign write_comp0_lo_addr = write_active & addr_comp0_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp0_lo_addr_reg_q_31_0
    if (write_comp0_lo_addr)
      comp0_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 257   Offset 0x404
  assign addr_comp0_hi_addr  = (et_reg_addr[11:2] == 10'h101);
  assign write_comp0_hi_addr = write_active & addr_comp0_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp0_hi_addr_reg_q_16_0
    if (write_comp0_hi_addr)
      comp0_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp0_addr_reg_o[48:0] = {comp0_hi_addr_reg_q[16:0],comp0_lo_addr_reg_q[31:0]};

// TRCACVR1
// Address Comparator Value Register 1
// Register 258   Offset 0x408
  assign addr_comp1_lo_addr  = (et_reg_addr[11:2] == 10'h102);
  assign write_comp1_lo_addr = write_active & addr_comp1_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp1_lo_addr_reg_q_31_0
    if (write_comp1_lo_addr)
      comp1_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 259   Offset 0x40C
  assign addr_comp1_hi_addr  = (et_reg_addr[11:2] == 10'h103);
  assign write_comp1_hi_addr = write_active & addr_comp1_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp1_hi_addr_reg_q_16_0
    if (write_comp1_hi_addr)
      comp1_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp1_addr_reg_o[48:0] = {comp1_hi_addr_reg_q[16:0],comp1_lo_addr_reg_q[31:0]};

// TRCACVR2
// Address Comparator Value Register 2
// Register 260   Offset 0x410
  assign addr_comp2_lo_addr  = (et_reg_addr[11:2] == 10'h104);
  assign write_comp2_lo_addr = write_active & addr_comp2_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp2_lo_addr_reg_q_31_0
    if (write_comp2_lo_addr)
      comp2_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 261   Offset 0x414
  assign addr_comp2_hi_addr  = (et_reg_addr[11:2] == 10'h105);
  assign write_comp2_hi_addr = write_active & addr_comp2_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp2_hi_addr_reg_q_16_0
    if (write_comp2_hi_addr)
      comp2_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp2_addr_reg_o[48:0] = {comp2_hi_addr_reg_q[16:0],comp2_lo_addr_reg_q[31:0]};

// TRCACVR3
// Address Comparator Value Register 3
// Register 262   Offset 0x418
  assign addr_comp3_lo_addr  = (et_reg_addr[11:2] == 10'h106);
  assign write_comp3_lo_addr = write_active & addr_comp3_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp3_lo_addr_reg_q_31_0
    if (write_comp3_lo_addr)
      comp3_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 263   Offset 0x41C
  assign addr_comp3_hi_addr  = (et_reg_addr[11:2] == 10'h107);
  assign write_comp3_hi_addr = write_active & addr_comp3_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp3_hi_addr_reg_q_16_0
    if (write_comp3_hi_addr)
      comp3_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp3_addr_reg_o[48:0] = {comp3_hi_addr_reg_q[16:0],comp3_lo_addr_reg_q[31:0]};

// TRCACVR4
// Address Comparator Value Register 4
// Register 264  Offset 0x420
  assign addr_comp4_lo_addr  = (et_reg_addr[11:2] == 10'h108);
  assign write_comp4_lo_addr = write_active & addr_comp4_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp4_lo_addr_reg_q_31_0
    if (write_comp4_lo_addr)
      comp4_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 265   Offset 0x424
  assign addr_comp4_hi_addr  = (et_reg_addr[11:2] == 10'h109);
  assign write_comp4_hi_addr = write_active & addr_comp4_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp4_hi_addr_reg_q_16_0
    if (write_comp4_hi_addr)
      comp4_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp4_addr_reg_o[48:0] = {comp4_hi_addr_reg_q[16:0],comp4_lo_addr_reg_q[31:0]};

// TRCACVR5
// Address Comparator Value Register 5
// Register 266   Offset 0x428
  assign addr_comp5_lo_addr  = (et_reg_addr[11:2] == 10'h10A);
  assign write_comp5_lo_addr = write_active & addr_comp5_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp5_lo_addr_reg_q_31_0
    if (write_comp5_lo_addr)
      comp5_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 267   Offset 0x42C
  assign addr_comp5_hi_addr  = (et_reg_addr[11:2] == 10'h10B);
  assign write_comp5_hi_addr = write_active & addr_comp5_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp5_hi_addr_reg_q_16_0
    if (write_comp5_hi_addr)
      comp5_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp5_addr_reg_o[48:0] = {comp5_hi_addr_reg_q[16:0],comp5_lo_addr_reg_q[31:0]};

// TRCACVR6
// Address Comparator Value Register 6
// Register 268   Offset 0x430
  assign addr_comp6_lo_addr  = (et_reg_addr[11:2] == 10'h10C);
  assign write_comp6_lo_addr = write_active & addr_comp6_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp6_lo_addr_reg_q_31_0
    if (write_comp6_lo_addr)
      comp6_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 269   Offset 0x434
  assign addr_comp6_hi_addr  = (et_reg_addr[11:2] == 10'h10D);
  assign write_comp6_hi_addr = write_active & addr_comp6_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp6_hi_addr_reg_q_16_0
    if (write_comp6_hi_addr)
      comp6_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp6_addr_reg_o[48:0] = {comp6_hi_addr_reg_q[16:0],comp6_lo_addr_reg_q[31:0]};

// TRCACVR7
// Address Comparator Value Register 7
// Register 270   Offset 0x438
  assign addr_comp7_lo_addr  = (et_reg_addr[11:2] == 10'h10E);
  assign write_comp7_lo_addr = write_active & addr_comp7_lo_addr;

  always @(posedge clk_gated)
  begin: ucomp7_lo_addr_reg_q_31_0
    if (write_comp7_lo_addr)
      comp7_lo_addr_reg_q[31:0] <= et_reg_wdata[31:0];
  end


// Register 271   Offset 0x43C
  assign addr_comp7_hi_addr  = (et_reg_addr[11:2] == 10'h10F);
  assign write_comp7_hi_addr = write_active & addr_comp7_hi_addr;

  always @(posedge clk_gated)
  begin: ucomp7_hi_addr_reg_q_16_0
    if (write_comp7_hi_addr)
      comp7_hi_addr_reg_q[16:0] <= et_reg_wdata[16:0];
  end


  assign comp7_addr_reg_o[48:0] = {comp7_hi_addr_reg_q[16:0],comp7_lo_addr_reg_q[31:0]};

//---------------------------------------------------------------------------
// Address Comparator Access Type Registers
//---------------------------------------------------------------------------

// TRCACATR0
// Address Comparator Access Type Register 0
// Register 288   Offset 0x480
  assign addr_comp0_access  = (et_reg_addr[11:2] == 10'h120);
  assign write_comp0_access = write_active & addr_comp0_access;

  always @(posedge clk_gated)
  begin: ucomp0_access_reg_q
    if (write_comp0_access) begin
      comp0_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp0_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp0_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp0_exlevel_ns_reg_o[2:0] = comp0_exlevel_ns_reg_q[2:0];
  assign comp0_exlevel_s_reg_o[2:0]  = comp0_exlevel_s_reg_q[2:0];
  assign comp0_context_reg_o[1:0]    = comp0_context_reg_q[1:0];

// TRCACATR1
// Address Comparator Access Type Register 1
// Register 290   Offset 0x488
  assign addr_comp1_access  = (et_reg_addr[11:2] == 10'h122);
  assign write_comp1_access = write_active & addr_comp1_access;

  always @(posedge clk_gated)
  begin: ucomp1_access_reg_q
    if (write_comp1_access) begin
      comp1_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp1_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp1_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp1_exlevel_ns_reg_o[2:0] = comp1_exlevel_ns_reg_q[2:0];
  assign comp1_exlevel_s_reg_o[2:0]  = comp1_exlevel_s_reg_q[2:0];
  assign comp1_context_reg_o[1:0]    = comp1_context_reg_q[1:0];

// TRCACATR2
// Address Comparator Access Type Register 2
// Register 292   Offset 0x490
  assign addr_comp2_access  = (et_reg_addr[11:2] == 10'h124);
  assign write_comp2_access = write_active & addr_comp2_access;

  always @(posedge clk_gated)
  begin: ucomp2_access_reg_q
    if (write_comp2_access) begin
      comp2_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp2_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp2_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp2_exlevel_ns_reg_o[2:0] = comp2_exlevel_ns_reg_q[2:0];
  assign comp2_exlevel_s_reg_o[2:0]  = comp2_exlevel_s_reg_q[2:0];
  assign comp2_context_reg_o[1:0]    = comp2_context_reg_q[1:0];

// TRCACATR3
// Address Comparator Access Type Register 3
// Register 294   Offset 0x498
  assign addr_comp3_access  = (et_reg_addr[11:2] == 10'h126);
  assign write_comp3_access = write_active & addr_comp3_access;

  always @(posedge clk_gated)
  begin: ucomp3_access_reg_q
    if (write_comp3_access) begin
      comp3_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp3_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp3_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp3_exlevel_ns_reg_o[2:0] = comp3_exlevel_ns_reg_q[2:0];
  assign comp3_exlevel_s_reg_o[2:0]  = comp3_exlevel_s_reg_q[2:0];
  assign comp3_context_reg_o[1:0]    = comp3_context_reg_q[1:0];

// TRCACATR4
// Address Comparator Access Type Register 4
// Register 296   Offset 0x4A0
  assign addr_comp4_access  = (et_reg_addr[11:2] == 10'h128);
  assign write_comp4_access = write_active & addr_comp4_access;

  always @(posedge clk_gated)
  begin: ucomp4_access_reg_q
    if (write_comp4_access) begin
      comp4_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp4_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp4_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp4_exlevel_ns_reg_o[2:0] = comp4_exlevel_ns_reg_q[2:0];
  assign comp4_exlevel_s_reg_o[2:0]  = comp4_exlevel_s_reg_q[2:0];
  assign comp4_context_reg_o[1:0]    = comp4_context_reg_q[1:0];

// TRCACATR5
// Address Comparator Access Type Register 5
// Register 298   Offset 0x4A8
  assign addr_comp5_access  = (et_reg_addr[11:2] == 10'h12A);
  assign write_comp5_access = write_active & addr_comp5_access;

  always @(posedge clk_gated)
  begin: ucomp5_access_reg_q
    if (write_comp5_access) begin
      comp5_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp5_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp5_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp5_exlevel_ns_reg_o[2:0] = comp5_exlevel_ns_reg_q[2:0];
  assign comp5_exlevel_s_reg_o[2:0]  = comp5_exlevel_s_reg_q[2:0];
  assign comp5_context_reg_o[1:0]    = comp5_context_reg_q[1:0];

// TRCACATR6
// Address Comparator Access Type Register 6
// Register 300   Offset 0x4B0
  assign addr_comp6_access  = (et_reg_addr[11:2] == 10'h12C);
  assign write_comp6_access = write_active & addr_comp6_access;

  always @(posedge clk_gated)
  begin: ucomp6_access_reg_q
    if (write_comp6_access) begin
      comp6_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp6_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp6_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp6_exlevel_ns_reg_o[2:0] = comp6_exlevel_ns_reg_q[2:0];
  assign comp6_exlevel_s_reg_o[2:0]  = comp6_exlevel_s_reg_q[2:0];
  assign comp6_context_reg_o[1:0]    = comp6_context_reg_q[1:0];

// TRCACATR7
// Address Comparator Access Type Register 7
// Register 302   Offset 0x4B8
  assign addr_comp7_access  = (et_reg_addr[11:2] == 10'h12E);
  assign write_comp7_access = write_active & addr_comp7_access;

  always @(posedge clk_gated)
  begin: ucomp7_access_reg_q
    if (write_comp7_access) begin
      comp7_exlevel_ns_reg_q[2:0] <= et_reg_wdata[14:12];
      comp7_exlevel_s_reg_q[2:0]  <= {et_reg_wdata[11], et_reg_wdata[9:8]};
      comp7_context_reg_q[1:0]    <= et_reg_wdata[3:2];
    end
  end


  assign comp7_exlevel_ns_reg_o[2:0] = comp7_exlevel_ns_reg_q[2:0];
  assign comp7_exlevel_s_reg_o[2:0]  = comp7_exlevel_s_reg_q[2:0];
  assign comp7_context_reg_o[1:0]    = comp7_context_reg_q[1:0];

//---------------------------------------------------------------------------
// Context Comparator Registers
//---------------------------------------------------------------------------

// TRCCIDCVR0
// Context ID Comparator Value Register 0
// Register 384   Offset 0x600
  assign addr_cid_comp_value  = (et_reg_addr[11:2] == 10'h180);
  assign write_cid_comp_value =  write_active & addr_cid_comp_value;

  always @(posedge clk_gated)
  begin: ucid_comp_value_reg_q_31_0
    if (write_cid_comp_value)
      cid_comp_value_reg_q[31:0] <= et_reg_wdata[31:0];
  end


  assign cid_comp_value_reg_o[31:0] = cid_comp_value_reg_q[31:0];

// TRCVMIDCVR0
// Virtual Machine ID Comparator Value Register 0
// Register 400   Offset 0x640
  assign addr_vmid_comp_value  = (et_reg_addr[11:2] == 10'h190);
  assign write_vmid_comp_value =  write_active & addr_vmid_comp_value;

  always @(posedge clk_gated)
  begin: uvmid_comp_value_reg_q_7_0
    if (write_vmid_comp_value)
      vmid_comp_value_reg_q[7:0] <= et_reg_wdata[7:0];
  end

  assign vmid_comp_value_reg_o[7:0] = vmid_comp_value_reg_q[7:0];

//---------------------------------------------------------------------------
// Context Comparator Control Registers
//---------------------------------------------------------------------------

// TRCCIDCCTLR0
// Context ID Comparator Control Register 0
// Register 416   Offset 0x680
  assign addr_cid_comp_mask  = (et_reg_addr[11:2] == 10'h1A0);
  assign write_cid_comp_mask =  write_active & addr_cid_comp_mask;

  always @(posedge clk_gated)
  begin: ucid_comp_mask_reg_q_3_0
    if (write_cid_comp_mask)
      cid_comp_mask_reg_q[3:0] <= et_reg_wdata[3:0];
  end

  assign cid_comp_mask_reg_o[3:0] = cid_comp_mask_reg_q[3:0];

//---------------------------------------------------------------------------
// Integration and Topology Detection Registers
//---------------------------------------------------------------------------

// TRCITMISCOUT not implemented

// TRCITMISCIN not implemented

// TRCITATBIDR
// Trace Intergration ATB Identification Register, same as TRCTRACEIDR
// Register 953  Offset 0xEE4
  assign addr_ir_atbid = (et_reg_addr[11:2] == 10'h3B9);
  assign write_at_id_o   = write_atb_domain & ((addr_ir_atbid & int_test_enable_q) |
                                               (addr_trace_id & (~trace_enable_reg | etm_os_lock_q)));

// TRCITATBDATAR
// Trace Integration ATB Data Register
// Register 955   Offset 0xEEC
// Implemented in ATB domain
// Write only
  assign addr_ir_atb_data    = (et_reg_addr[11:2] == 10'h3BB);
  assign write_ir_atb_data_o = write_atb_domain & addr_ir_atb_data;

// TRCITATBINR
// Trace Integration ATB In Register
// Register 957   Offset 0xEF4
// Implemented in ATB domain
// Read only
  assign addr_ir_atb_in = (et_reg_addr[11:2] == 10'h3BD);

// TRCITATBOUTR
// Trace Integration ATB Out Register
// Register 958   Offset 0xEFC
// Implemented in ATB domain
// Write only
  assign addr_ir_atb_out      = (et_reg_addr[11:2] == 10'h3BF);
  assign write_ir_atb_out_o   = write_atb_domain & addr_ir_atb_out;

//---------------------------------------------------------------------------
// CoreSight Management Registers
//---------------------------------------------------------------------------

// TRCITCTRL
// Integration Mode Control Register
// Register 960   Offset 0xF00
  assign addr_ir_itctrl = (et_reg_addr[11:2] == 10'h3C0);
  assign write_itctrcl  = write_active & addr_ir_itctrl;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uint_test_enable_q
    if (!po_reset_n)
      int_test_enable_q <= 1'b0;
    else if (write_itctrcl)
      int_test_enable_q <= et_reg_wdata[0];
  end

  assign int_test_enable_o = int_test_enable_q;

// TRCCLAIMSET
// Claim Tag Set Register
// Register 1000   Offset 0xFA0
  assign addr_claimset = (et_reg_addr[11:2] == 10'h3E8);

// TRCCLAIMCLR
// Claim Tag Clear Register
// Register 1001   Offset 0xFA4
  assign addr_claimclr = (et_reg_addr[11:2] == 10'h3E9);

  assign claimset[3:0]   = {4{addr_claimset}} & et_reg_wdata[3:0];
  assign claimclr[3:0]   = {4{addr_claimclr}} & et_reg_wdata[3:0];
  assign claimstate[3:0] = (claimstate_q[3:0] | claimset[3:0]) & (~claimclr[3:0]);

  assign claimstate_en = write_always_active & (addr_claimset | addr_claimclr);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uclaimstate_q_3_0
    if (!po_reset_n)
      claimstate_q[3:0] <= {4{1'b0}};
    else if (claimstate_en)
      claimstate_q[3:0] <= claimstate[3:0];
  end


// TRCOSLAR
// OS Lock register
// Register 192   Offset 0x300
  assign addr_oslar  = (et_reg_addr[11:2] == 10'h0C0);
  assign write_oslar = write_always_active & addr_oslar;

  assign etm_oslock_o        = etm_os_lock_q;
  assign etm_os_lock_trace_o = etm_os_lock_trace_q;


  always @(posedge clk_gated or negedge po_reset_n)
  begin: u_os_lock_q
    if (!po_reset_n)
      etm_os_lock_q <= {1{1'b1}};
    else if (write_oslar)
      etm_os_lock_q <= et_reg_wdata[0];
  end

  assign etm_os_lock_trace = etm_os_lock_q | (etm_os_lock_trace_q & ~trcstatr_idle_i);
  always @(posedge clk_gated or negedge po_reset_n)
  begin: u_os_lock_trace_q
    if (!po_reset_n)
      etm_os_lock_trace_q <= {1{1'b1}};
    else
      etm_os_lock_trace_q <= etm_os_lock_trace;
  end

// TRCOSLAR
// OS Lock register 
// Register 193   Offset 0x304
  assign addr_oslsr  = (et_reg_addr[11:2] == 10'h0C1);

// TRCPDSR
// Power Down Status Register
// Register 197   Offset 0x314
// Sticky Power Down only cleared by read if SW unlock or external debug access

  assign addr_pdsr      = (et_reg_addr[11:2] == 10'h0C5);
  assign stick_pd_clear = addr_pdsr & reg_req_q & ~gov_pwritedbg_q & gov_etmpdsr_rd_q;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: u_sticky_pd_q
    if (!po_reset_n)
      sticky_pd_q <= 1'b1;
    else if(stick_pd_clear)
      sticky_pd_q <= 1'b0;
  end


//----------------------------------------------------------------------------
// Register Read Control Logic
//----------------------------------------------------------------------------

  assign reg_rdata[31:0] =
              // Main Control and Configuration Registers
              // TRCPRGCTLR
              ({32{addr_prog_control}} & {{31{1'b0}},                                               // Reserved
                                          trace_enable_reg}) |                                      // EN
              // TRCSTATR
              ({32{addr_status}} & {{30{1'b0}},                                                     // Reserved
                                    trcstatr_pmstable_i,                                            // PMSTABLE
                                    trcstatr_idle_i & ~trace_enable_reg}) |                         // IDLE
              // TRCCONFIGR
              ({32{addr_trace_config}} & {{14{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DV
                                          1'b0,                                                     // DA
                                          1'b0,                                                     // Reserved
                                          2'b00,                                                    // Q element disabled
                                          return_stack_en_reg_q,                                    // RS
                                          timestamp_en_reg_q,                                       // TS
                                          3'b000,                                                   // COND
                                          vmid_reg_q,                                               // VMID
                                          context_id_reg_q,                                         // CID
                                          1'b0,                                                     // Reserved
                                          cycle_counting_reg_q,                                     // CCI
                                          branch_broadcast_reg_q,                                   // BB
                                          2'b00,                                                    // INSTP0
                                          1'b1}) |                                                  // Reserved
              // TRCAUXCTLR
              ({32{addr_aux_control}} & {{24{1'b0}},                                                // Reserved
                                         auxctlr_frc_coreifen_reg,                                  // Force IF enabled
                                         {1'b0},
                                         auxctlr_frc_auth_noflush_reg,                              // Don't flush for NIDEN etc.
                                         auxctlr_frc_ts_nodelay_reg,                                // Timestamp delay
                                         auxctlr_frc_sync_delay_reg,                                // Synchronisation delay
                                         auxctlr_frc_ovflow_reg,                                    // Synchronisation overflow
                                         auxctlr_frc_idleack_reg,                                   // Force idel drain acknowledge
                                         auxctlr_frc_afready_reg}) |                                // Force AFREADY response high
              // TRCEVENTCTL0R
              ({32{addr_event_control0}} & {event3_sel_reg_q[4],3'b000,event3_sel_reg_q[3:0],       // EVENT3
                                            event2_sel_reg_q[4],3'b000,event2_sel_reg_q[3:0],       // EVENT2
                                            event1_sel_reg_q[4],3'b000,event1_sel_reg_q[3:0],       // EVENT1
                                            event0_sel_reg_q[4],3'b000,event0_sel_reg_q[3:0]}) |    // EVENT0
              // TRCEVENTCTL1R
              ({32{addr_event_control1}} & {{19{1'b0}},                                             // Reserved
                                            lp_override_reg_q,                                      // low power override
                                            event_atbtrig_en_reg_q,                                 // ATB
                                            {6{1'b0}},                                              // Reserved
                                            1'b0,                                                   // DATAEN
                                            event_enable_reg_q[3:0]}) |                             // INSTEN
             // TRCSTALLCTLR
              ({32{addr_stall_ctrl}} & {{23{1'b0}},                                                 // Reserved
                                        istall_reg_q,                                               // Stall CPU control
                                        4'b0000,                                                    // Reserved
                                        stall_level_reg_q, 2'b00}) |                                // Stall level [3:2]



              // TRCTSCTLR
              ({32{addr_ts_event}} & {{24{1'b0}},                                                   // Reserved
                                      ts_event_reg_q[4],3'b000,ts_event_reg_q[3:0]}) |              // EVENT
              // TRCSYNCPR
              ({32{addr_sync_period}} & {{27{1'b0}},                                                // Reserved
                                         sync_period_reg_q[4:0]}) |                                 // PERIOD
              // TRCCCCTLR
              ({32{addr_cyclecount_control}} & {{20{1'b0}},                                         // Reserved
                                                cc_threshold_reg_q[11:0]}) |                        // THRESHOLD
              // TRCBBCTLR
              ({32{addr_branchbroadcast_control}} & {{23{1'b0}},                                    // Reserved
                                                     bb_mode_reg_q,                                 // MODE
                                                    4'b0000,bb_range_reg_q[3:0]}) |                 // RANGE
              // TRCTRACEIDR
              ({32{addr_trace_id}} & {{25{1'b0}},                                                   // Reserved
                                      etm_atidm_reg_i[6:0]}) |                                          // TRACEID

              // Trace Filtering Control Registers
              // TRCVICTLR
              ({32{addr_viewinst_control}} & {{8{1'b0}},                                            // Reserved
                                              1'b0,viewinst_exlevel_ns_reg_q[2:0],                  // EXLEVEL_NS
                                              viewinst_exlevel_s_reg_q[2],1'b0,                     // EXLEVEL_S HI
                                              viewinst_exlevel_s_reg_q[1:0],                        // EXLEVEL_S LO
                                              4'b0000,                                              // Reserved
                                              viewinst_trcerr_reg_q,                                // TRCERR
                                              viewinst_trcreset_reg_q,                              // TRCRESET
                                              viewinst_sstatus_i,                                   // SSSTATUS
                                              1'b0,                                                 // Reserved
                                              viewinst_event_reg_q[4],3'b000,                       // EVENT HI
                                              viewinst_event_reg_q[3:0]}) |                         // EVENT LO
              // TRCVIIECTLR
              ({32{addr_viewinst_incexc_control}} & {{8{1'b0}},                                     // Reserved
                                                     {4{1'b0}},viewinst_exc_ranges_reg_q[3:0],      // EXCLUDE
                                                     {8{1'b0}},                                     // Reserved
                                                     {4{1'b0}},viewinst_inc_ranges_reg_q[3:0]}) |   // EXCLUDE
              // TRCVISSCTLR
              ({32{addr_viewinst_ss_control}} & {{8{1'b0}},viewinst_stop_cmp_reg_q[7:0],            // STOP
                                                 {8{1'b0}},viewinst_start_cmp_reg_q[7:0]}) |        // START

              // Derived Resources
              // TRCSEQEVR0
              ({32{addr_seq_transition_control0}} & {{16{1'b0}},                                    // Reserved
                                                     seq_transition_b0_reg_q[4],3'b000,             // B0 HI
                                                     seq_transition_b0_reg_q[3:0],                  // B0 LO
                                                     seq_transition_f0_reg_q[4],3'b000,             // F0 HI
                                                     seq_transition_f0_reg_q[3:0]}) |               // F0 LO
              // TRCSEQEVR1
              ({32{addr_seq_transition_control1}} & {{16{1'b0}},                                    // Reserved
                                                     seq_transition_b1_reg_q[4],3'b000,             // B1 HI
                                                     seq_transition_b1_reg_q[3:0],                  // B1 LO
                                                     seq_transition_f1_reg_q[4],3'b000,             // F1 HI
                                                     seq_transition_f1_reg_q[3:0]}) |               // F1 LO
              // TRCSEQEVR2
              ({32{addr_seq_transition_control2}} & {{16{1'b0}},                                    // Reserved
                                                     seq_transition_b2_reg_q[4],3'b000,             // B2 HI
                                                     seq_transition_b2_reg_q[3:0],                  // B2 LO
                                                     seq_transition_f2_reg_q[4],3'b000,             // F2 HI
                                                     seq_transition_f2_reg_q[3:0]}) |               // F2 LO
              // TRCSEQRSTEVR
              ({32{addr_seq_rst}} & {{24{1'b0}},                                                    // Reserved
                                     seq_rst_reg_q[4],3'b000,seq_rst_reg_q[3:0]}) |                 // RST
              // TRCSEQSTR
              ({32{addr_seq_state}} & {{30{1'b0}},                                                  // Reserved
                                       seq_state_t2_i[1:0]}) |                                      // STATE
              // TRCEXTINSELR
              ({32{addr_extin_sel}} & {3'b000,extin_sel3_reg_q[4:0],                                // SEL3
                                       3'b000,extin_sel2_reg_q[4:0],                                // SEL2
                                       3'b000,extin_sel1_reg_q[4:0],                                // SEL1
                                       3'b000,extin_sel0_reg_q[4:0]}) |                             // SEL0
              // TRCCNTRLDVR0
              ({32{addr_counter0_reload}} & {{16{1'b0}},                                            // Reserved
                                             counter0_reload_reg_q[15:0]}) |                        // VALUE
              // TRCCNTRLDVR1
              ({32{addr_counter1_reload}} & {{16{1'b0}},                                            // Reserved
                                             counter1_reload_reg_q[15:0]}) |                        // VALUE
              // TRCCNTCTLR0
              ({32{addr_counter0_control}} & {{14{1'b0}},                                           // Reserved
                                              1'b0,                                                 // Reserved
                                              counter0_rldself_reg_q,                               // RLDSELF
                                              counter0_rldevent_reg_q[4],3'b000,                    // RLDEVENT HI
                                              counter0_rldevent_reg_q[3:0],                         // RLDEVENT LO
                                              counter0_cntevent_reg_q[4],3'b000,                    // CNTEVENT HI
                                              counter0_cntevent_reg_q[3:0]}) |                      // CNTEVENT LO
              // TRCCNTCTLR1
              ({32{addr_counter1_control}} & {{14{1'b0}},                                           // Reserved
                                              counter1_cntchain_reg_q,                              // CNTCHAIN
                                              counter1_rldself_reg_q,                               // RLDSELF
                                              counter1_rldevent_reg_q[4],3'b000,                    // RLDEVENT HI
                                              counter1_rldevent_reg_q[3:0],                         // RLDEVENT LO
                                              counter1_cntevent_reg_q[4],3'b000,                    // CNTEVENT HI
                                              counter1_cntevent_reg_q[3:0]}) |                      // CNTEVENT LO
              // TRCCNTVR0
              ({32{addr_counter0_value}} & {{16{1'b0}},                                             // Reserved
                                            counter0_value_i[15:0]}) |                              // VALUE
              // TRCCNTVR1
              ({32{addr_counter1_value}} & {{16{1'b0}},                                             // Reserved
                                            counter1_value_i[15:0]}) |                              // VALUE

              // Implementation Defined and ID Registers
              ({32{addr_trcidr0}} & {{2{1'b0}},                                                     // RESERVED
                                      1'b1,                                                         // Commit Mode
                                      5'b01000,                                                     // TSSIZE
                                      {7{1'b0}},                                                    // Reserved
                                      {3{1'b0}},                                                    // Q Elements
                                      2'b00,                                                        // CONDTYPE
                                      2'b11,                                                        // NUMEVENT
                                      1'b1,                                                         // RETSTACK
                                      1'b0,                                                         // Reserved
                                      1'b1,                                                         // TRCCCI
                                      1'b0,                                                         // TRCCOND
                                      1'b1,                                                         // TRCBB
                                      2'b00,                                                        // TRCDATA
                                      2'b00,                                                        // INSTP0
                                     1'b1}) |                                                       // RES1
              // TRCIDR1
              ({32{addr_trcidr1}} & {8'h41,                                                         // DESIGNER
                                     8'h00,                                                         // RES0
                                     4'hF,                                                          // RES1
                                     4'b0100,                                                       // TRCARCHMAJ
                                     4'b0000,                                                       // TRCARCHMIN
                                     `CA53_PERPH_REVISION}) |                                       // REVISION
              // TRCIDR2
              ({32{addr_trcidr2}} & {{17{1'b0}},                                                    // not implemented
                                     5'b00001,                                                      // VMIDSIZE
                                     5'b00100,                                                      // CIDSIZE
                                     5'b01000}) |                                                   // IASIZE
              // TRCIDR3
              ({32{addr_trcidr3}} & {4'b0000,                                                       // not implemented
                                     1'b1,                                                          // SYSSTALL
                                     1'b1,                                                          // STALLCTL
                                     1'b0,                                                          // SYNCPR
                                     1'b1,                                                          // TRCERR
                                     4'b0111,                                                       // EXLEVEL_NS
                                     4'b1011,                                                       // EXLEVEL_S
                                     4'b0000,                                                       // Reserved
                                     12'b000000000100}) |                                           // CCITMIN
              // TRCIDR4
              ({32{addr_trcidr4}} & {4'b0001,                                                       // NUMVMIDC
                                     4'b0001,                                                       // NUMCIDC
                                     4'b0001,                                                       // NUMSSCC
                                     4'b0111,                                                       // NUMRSPAIR
                                     4'b0000,                                                       // NUMPC
                                     3'b000,                                                        // Reserved
                                     1'b0,                                                          // SUPPDAV
                                     4'b0000,                                                       // NUMDVC
                                     4'b0100}) |                                                    // NUMACPAIRS
              // TRCIDR5
              ({32{addr_trcidr5}} & {1'b0,                                                          // REDFUNCNTR
                                     3'b010,                                                        // NUMCNTR
                                     3'b100,                                                        // NUMSEQSTATE
                                     1'b0,                                                          // Reserved
                                     1'b1,                                                          // LPOVERIDE
                                     1'b1,                                                          // ATBTRIG
                                     6'b000111,                                                     // TRACEIDSIZE
                                     4'b0000,                                                       // Reserved
                                     3'b100,                                                        // NUMEXTINSEL
                                     9'b000011110}) |                                               // NUMEXTIN

              // Resource Selection Control Registers
              // TRCRSCTLR2
              ({32{addr_trcrsctlr2}} & {{10{1'b0}},                                                 // Reserved
                                        trcrsctlr2_pairinv_reg_q,                                   // PAIRINV
                                        trcrsctlr2_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr2_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr2_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR3
              ({32{addr_trcrsctlr3}} & {{10{1'b0}},                                                 // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr3_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr3_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr3_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR4
              ({32{addr_trcrsctlr4}} & {{10{1'b0}},                                                 // Reserved
                                        trcrsctlr4_pairinv_reg_q,                                   // PAIRINV
                                        trcrsctlr4_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr4_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr4_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR5
              ({32{addr_trcrsctlr5}} & {{10{1'b0}},                                                 // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr5_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr5_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr5_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR6
              ({32{addr_trcrsctlr6}} & {{10{1'b0}},                                                 // Reserved
                                        trcrsctlr6_pairinv_reg_q,                                   // PAIRINV
                                        trcrsctlr6_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr6_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr6_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR7
              ({32{addr_trcrsctlr7}} & {{10{1'b0}},                                                 // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr7_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr7_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr7_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR8
              ({32{addr_trcrsctlr8}} & {{10{1'b0}},                                                 // Reserved
                                        trcrsctlr8_pairinv_reg_q,                                   // PAIRINV
                                        trcrsctlr8_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr8_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr8_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR9
              ({32{addr_trcrsctlr9}} & {{10{1'b0}},                                                 // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr9_inv_reg_q,                                       // INV
                                        1'b0,trcrsctlr9_group_reg_q[2:0],                           // GROUP
                                        {8{1'b0}},trcrsctlr9_select_reg_q[7:0]}) |                  // SELECT
              // TRCRSCTLR10
              ({32{addr_trcrsctlr10}} & {{10{1'b0}},                                                // Reserved
                                        trcrsctlr10_pairinv_reg_q,                                  // PAIRINV
                                        trcrsctlr10_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr10_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr10_select_reg_q[7:0]}) |                 // SELECT
              // TRCRSCTLR11
              ({32{addr_trcrsctlr11}} & {{10{1'b0}},                                                // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr11_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr11_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr11_select_reg_q[7:0]}) |                 // SELECT
              // TRCRSCTLR12
              ({32{addr_trcrsctlr12}} & {{10{1'b0}},                                                // Reserved
                                        trcrsctlr12_pairinv_reg_q,                                  // PAIRINV
                                        trcrsctlr12_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr12_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr12_select_reg_q[7:0]}) |                 // SELECT
              // TRCRSCTLR13
              ({32{addr_trcrsctlr13}} & {{10{1'b0}},                                                // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr13_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr13_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr13_select_reg_q[7:0]}) |                 // SELECT
              // TRCRSCTLR14
              ({32{addr_trcrsctlr14}} & {{10{1'b0}},                                                // Reserved
                                        trcrsctlr14_pairinv_reg_q,                                  // PAIRINV
                                        trcrsctlr14_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr14_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr14_select_reg_q[7:0]}) |                 // SELECT
              // TRCRSCTLR15
              ({32{addr_trcrsctlr15}} & {{10{1'b0}},                                                // Reserved
                                        1'b0,                                                       // Reserved
                                        trcrsctlr15_inv_reg_q,                                      // INV
                                        1'b0,trcrsctlr15_group_reg_q[2:0],                          // GROUP
                                        {8{1'b0}},trcrsctlr15_select_reg_q[7:0]}) |                 // SELECT

              // Single Shot Comparator Registers
              // TRCSSCCR0
              ({32{addr_ssc_control}} & {{7{1'b0}},                                                 // Reserved
                                         ssc_rst_reg_q,                                             // RST
                                         4'b0000,ssc_arc_reg_q[3:0],                                // ARC
                                         {8{1'b0}},ssc_sac_reg_q[7:0]}) |                           // SAC
              // TRCSSCSR0
              ({32{addr_ssc_status}} & {ssc_status_t2_i,                                            // STATUS
                                        {28{1'b0}},                                                 // Reserved
                                        1'b0,                                                       // DV => No support for Data Value Comparator
                                        1'b0,                                                       // DA => No support for Data Address Comparator
                                        1'b1}) |                                                    // INST => Support for Instruction Address Comparator

              // Address Comparator Value Registers
              // TRCACVR0
              ({32{addr_comp0_lo_addr}} & comp0_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp0_hi_addr}} & {{16{comp0_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp0_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR1
              ({32{addr_comp1_lo_addr}} & comp1_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp1_hi_addr}} & {{16{comp1_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp1_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR2
              ({32{addr_comp2_lo_addr}} & comp2_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp2_hi_addr}} & {{16{comp2_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp2_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR3
              ({32{addr_comp3_lo_addr}} & comp3_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp3_hi_addr}} & {{16{comp3_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp3_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR4
              ({32{addr_comp4_lo_addr}} & comp4_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp4_hi_addr}} & {{16{comp4_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp4_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR5
              ({32{addr_comp5_lo_addr}} & comp5_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp5_hi_addr}} & {{16{comp5_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp5_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR6
              ({32{addr_comp6_lo_addr}} & comp6_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp6_hi_addr}} & {{16{comp6_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp6_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]
              // TRCACVR7
              ({32{addr_comp7_lo_addr}} & comp7_lo_addr_reg_q[31:0]) |                              // ADDRESS[31:0]
              ({32{addr_comp7_hi_addr}} & {{16{comp7_hi_addr_reg_q[16]}},                           // ADDRESS[63:48]
                                           comp7_hi_addr_reg_q[15:0]}) |                            // ADDRESS[47:32]

              // Address Comparator Access Type Registers
              // TRCACATR0
              ({32{addr_comp0_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp0_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp0_exlevel_s_reg_q[2],1'b0,comp0_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp0_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR1
              ({32{addr_comp1_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp1_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp1_exlevel_s_reg_q[2],1'b0,comp1_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp1_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR2
              ({32{addr_comp2_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp2_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp2_exlevel_s_reg_q[2],1'b0,comp2_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp2_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR3
              ({32{addr_comp3_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp3_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp3_exlevel_s_reg_q[2],1'b0,comp3_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp3_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR4
              ({32{addr_comp4_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp4_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp4_exlevel_s_reg_q[2],1'b0,comp4_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp4_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR5
              ({32{addr_comp5_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp5_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp5_exlevel_s_reg_q[2],1'b0,comp5_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp5_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR6
              ({32{addr_comp6_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp6_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp6_exlevel_s_reg_q[2],1'b0,comp6_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp6_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE
              // TRCACATR7
              ({32{addr_comp7_access}} & {{10{1'b0}},                                               // Reserved
                                          1'b0,                                                     // DTBM
                                          1'b0,                                                     // DATARANGE
                                          2'b00,                                                    // DATASIZE
                                          2'b00,                                                    // DATAMATCH
                                          1'b0,comp7_exlevel_ns_reg_q[2:0],                         // EXLEVEL_NS
                                          comp7_exlevel_s_reg_q[2],1'b0,comp7_exlevel_s_reg_q[1:0], // EXLEVEL_S
                                          1'b0,                                                     // Reserved
                                          3'b000,                                                   // CONTEXT
                                          comp7_context_reg_q[1:0],                                 // CONTEXTTYPE
                                          2'b00}) |                                                 // TYPE

              // Context Comparator Registers
              // TRCCIDCVR0
              ({32{addr_cid_comp_value}} & cid_comp_value_reg_q[31:0]) |                            // VALUE
              // TRCVMIDCVR0
              ({32{addr_vmid_comp_value}} & {{24{1'b0}},
                                             vmid_comp_value_reg_q[7:0]}) |                         // VALUE
              // TRCCIDCCTLR0
              ({32{addr_cid_comp_mask}} & {{28{1'b0}},
                                            cid_comp_mask_reg_q[3:0]}) |                            // COMP0

              // Integration and Topology Detection Registers
               // TRCITATBID
              ({32{addr_ir_atbid}} & {{25{1'b0}},                                                   // Reserved
                                       etm_atidm_reg_i[6:0]}) |                                     // ATB ID
              // TRCITATBCTR2
              ({32{addr_ir_atb_in}} & {{30{1'b0}},                                                  // Reserved
                                       atb_afvalid_i,                                               // AFVALID
                                       atb_atready_i})|                                             // ATREADY

              // CoreSight Management Registers
              // TRCITCTRL
              ({32{addr_ir_itctrl}} & {{31{1'b0}},                                                  // Reserved
                                        int_test_enable_q}) |                                       // ITEN
              // TRCCLAIMSET
              ({32{addr_claimset}} & {{28{1'b0}},                                                   // Reserved
                                      {4{1'b1}}}) |                                                 // SET
              // TRCCLAIMCLR
              ({32{addr_claimclr}} & {{28{1'b0}},                                                   // Reserved
                                      claimstate_q[3:0]}) |
              //TRCOSLSR
              ({32{addr_oslsr}}    & {{28{1'b0}},                                                   // Reserved
                                      1'b1,                                                         // OSLM[1] 1'b1
                                      1'b0,                                                         // nTT 0:32 bit access required
                                      etm_os_lock_q,                                                // OS lock status
                                      1'b0}) |                                                      // OSLM[0] 1'b0
              //TRCPDSR (bit[3] added in governor
              ({32{addr_pdsr}}     & {{26{1'b0}},                                                   // Reserved
                                      etm_os_lock_q,
                                      3'b000,
                                      sticky_pd_q,
                                      1'b0});

  always @(posedge clk_gated)
  begin: ureg_rdata_q_31_0
    if (reg_req_q)
      reg_rdata_q[31:0] <= reg_rdata[31:0];
  end

  assign et_reg_rdata[31:0] = reg_rdata_q[31:0];

//--------------------------------------------------------------------------
// Control Logic for ATB Domain Registers
//--------------------------------------------------------------------------

// For writes to ATID, IR_ATB_OUT, IR_ATB_DATA
// transaction needs to be propagated to ATCLK domain
  assign addr_atb_domain   = ((addr_trace_id & (~trace_enable_reg | etm_os_lock_q)) |
                              ((addr_ir_atb_out | addr_ir_atbid |addr_ir_atb_data) & int_test_enable_q));

  assign write_atb_domain  = reg_sel_q & et_reg_write & addr_atb_domain  & ~atb_reg_ack_q;

//--------------------------------------------------------------------------
// ATB Register read write Ack
//--------------------------------------------------------------------------

// Reads to all registers are handled here.
// Only writes to ATB domain need to wait for ack from ATB domain.

// New transactions are stalled from making request until old resp
// is cleared down. Transaction completes on first sampled cycle of resp
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uatb_reg_ack_q
    if (!po_reset_n)
      atb_reg_ack_q <= 1'b0;
    else if (addr_atb_domain)
      atb_reg_ack_q <= atb_reg_ack_i;
  end

  assign atb_ack_active = atb_reg_ack_i & ~atb_reg_ack_q;

  assign reg_ack = (et_reg_write & addr_atb_domain) ? (atb_ack_active) : (reg_req_q);
  assign reg_ack_en = reg_sel_q | reg_ack_q;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ureg_ack_q
    if (!po_reset_n)
      reg_ack_q <= 1'b0;
    else if (reg_ack_en)
      reg_ack_q <= reg_ack;
  end

  assign etm_preadydbg_o = reg_ack_q;

//--------------------------------------------------------------------------
// ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON
`include "ca53etm_val_defs.v"
// ETM Registers

  usva_atb_waiting_resp: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
     (~atb_reg_ack_q & reg_sel_q & et_reg_write & addr_atb_domain) |->
                                     (write_at_id_o |
                                      write_ir_atb_out_o |
                                      write_ir_atb_data_o))
    `SVA_FATAL("Waiting for ATB response without pending request");

// Compare old idle status bit with the old version of the trace enable and oslock.
  // Architecture requires read of status, so delay could be over 6 cycles
  // Overflow recovery needs this to be 4 cycles
  usva_status_idle_bit: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    $rose(trace_enable_reg_o)  |-> $past(trcstatr_idle_i,4))
    `SVA_FATAL("Trace enable should not be changed unless it agrees with the status reg idle bit");

  usva_oslock_change: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    $fell(etm_os_lock_q)  |-> $past(etm_os_lock_q,2))
    `SVA_FATAL("OS lock can only be written to at APB access rate");

  // Check for write to any APB register except for Programming Control Register,
  // Software lock register and OS lock register
  usva_write_when_not_idle: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                        (etm_os_lock_q | ~trace_enable_reg) &
                        !trcstatr_idle_i && !write_prog_control && !write_oslar |-> !write_always_active)
    `SVA_WARN("Writing APB registers when not idle");

  // Trap for problem with AVS tests
  usva_active_TRCVIIECTLR: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    trace_enable_reg_o |-> ~$isunknown(viewinst_inc_ranges_reg_q))
    `SVA_FATAL("TRCVIIECTLR must always be programmed before start of session");
`endif //  `ifdef CA53_SVA_ON
`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_atb_domain")
  u_ovl_x_addr_atb_domain (.clk       (clk_gated),
                           .reset_n   (po_reset_n),
                           .qualifier (1'b1),
                           .test_expr (addr_atb_domain));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: claimstate_en")
  u_ovl_x_claimstate_en (.clk       (clk_gated),
                         .reset_n   (po_reset_n),
                         .qualifier (1'b1),
                         .test_expr (claimstate_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clk_reg_req_i")
  u_ovl_x_clk_reg_req_i (.clk       (clk_gated),
                         .reset_n   (po_reset_n),
                         .qualifier (1'b1),
                         .test_expr (clk_reg_req_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_ack_en")
  u_ovl_x_reg_ack_en (.clk       (clk_gated),
                      .reset_n   (po_reset_n),
                      .qualifier (1'b1),
                      .test_expr (reg_ack_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_req_en")
  u_ovl_x_reg_req_en (.clk       (clk_gated),
                      .reset_n   (po_reset_n),
                      .qualifier (1'b1),
                      .test_expr (reg_req_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_req_q")
  u_ovl_x_reg_req_q (.clk       (clk_gated),
                     .reset_n   (po_reset_n),
                     .qualifier (1'b1),
                     .test_expr (reg_req_q));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: reg_sel_en")
  u_ovl_x_reg_sel_en (.clk       (clk_gated),
                      .reset_n   (po_reset_n),
                      .qualifier (1'b1),
                      .test_expr (reg_sel_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: stick_pd_clear")
  u_ovl_x_stick_pd_clear (.clk       (clk_gated),
                          .reset_n   (po_reset_n),
                          .qualifier (1'b1),
                          .test_expr (stick_pd_clear));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_aux_control")
  u_ovl_x_write_aux_control (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_aux_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_branchbroadcast_control")
  u_ovl_x_write_branchbroadcast_control (.clk       (clk_gated),
                                         .reset_n   (po_reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (write_branchbroadcast_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_cid_comp_mask")
  u_ovl_x_write_cid_comp_mask (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_cid_comp_mask));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_cid_comp_value")
  u_ovl_x_write_cid_comp_value (.clk       (clk_gated),
                                .reset_n   (po_reset_n),
                                .qualifier (1'b1),
                                .test_expr (write_cid_comp_value));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp0_access")
  u_ovl_x_write_comp0_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp0_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp0_hi_addr")
  u_ovl_x_write_comp0_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp0_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp0_lo_addr")
  u_ovl_x_write_comp0_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp0_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp1_access")
  u_ovl_x_write_comp1_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp1_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp1_hi_addr")
  u_ovl_x_write_comp1_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp1_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp1_lo_addr")
  u_ovl_x_write_comp1_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp1_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp2_access")
  u_ovl_x_write_comp2_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp2_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp2_hi_addr")
  u_ovl_x_write_comp2_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp2_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp2_lo_addr")
  u_ovl_x_write_comp2_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp2_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp3_access")
  u_ovl_x_write_comp3_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp3_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp3_hi_addr")
  u_ovl_x_write_comp3_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp3_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp3_lo_addr")
  u_ovl_x_write_comp3_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp3_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp4_access")
  u_ovl_x_write_comp4_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp4_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp4_hi_addr")
  u_ovl_x_write_comp4_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp4_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp4_lo_addr")
  u_ovl_x_write_comp4_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp4_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp5_access")
  u_ovl_x_write_comp5_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp5_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp5_hi_addr")
  u_ovl_x_write_comp5_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp5_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp5_lo_addr")
  u_ovl_x_write_comp5_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp5_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp6_access")
  u_ovl_x_write_comp6_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp6_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp6_hi_addr")
  u_ovl_x_write_comp6_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp6_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp6_lo_addr")
  u_ovl_x_write_comp6_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp6_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp7_access")
  u_ovl_x_write_comp7_access (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_comp7_access));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp7_hi_addr")
  u_ovl_x_write_comp7_hi_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp7_hi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_comp7_lo_addr")
  u_ovl_x_write_comp7_lo_addr (.clk       (clk_gated),
                               .reset_n   (po_reset_n),
                               .qualifier (1'b1),
                               .test_expr (write_comp7_lo_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_counter0_control")
  u_ovl_x_write_counter0_control (.clk       (clk_gated),
                                  .reset_n   (po_reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (write_counter0_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_counter0_reload")
  u_ovl_x_write_counter0_reload (.clk       (clk_gated),
                                 .reset_n   (po_reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (write_counter0_reload));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_counter1_control")
  u_ovl_x_write_counter1_control (.clk       (clk_gated),
                                  .reset_n   (po_reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (write_counter1_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_counter1_reload")
  u_ovl_x_write_counter1_reload (.clk       (clk_gated),
                                 .reset_n   (po_reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (write_counter1_reload));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_cyclecount_control")
  u_ovl_x_write_cyclecount_control (.clk       (clk_gated),
                                    .reset_n   (po_reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (write_cyclecount_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_event_control0")
  u_ovl_x_write_event_control0 (.clk       (clk_gated),
                                .reset_n   (po_reset_n),
                                .qualifier (1'b1),
                                .test_expr (write_event_control0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_event_control1")
  u_ovl_x_write_event_control1 (.clk       (clk_gated),
                                .reset_n   (po_reset_n),
                                .qualifier (1'b1),
                                .test_expr (write_event_control1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_extin_sel")
  u_ovl_x_write_extin_sel (.clk       (clk_gated),
                           .reset_n   (po_reset_n),
                           .qualifier (1'b1),
                           .test_expr (write_extin_sel));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_itctrcl")
  u_ovl_x_write_itctrcl (.clk       (clk_gated),
                         .reset_n   (po_reset_n),
                         .qualifier (1'b1),
                         .test_expr (write_itctrcl));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_oslar")
  u_ovl_x_write_oslar (.clk       (clk_gated),
                       .reset_n   (po_reset_n),
                       .qualifier (1'b1),
                       .test_expr (write_oslar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_prog_control")
  u_ovl_x_write_prog_control (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_prog_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_seq_rst")
  u_ovl_x_write_seq_rst (.clk       (clk_gated),
                         .reset_n   (po_reset_n),
                         .qualifier (1'b1),
                         .test_expr (write_seq_rst));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_seq_transition_control0")
  u_ovl_x_write_seq_transition_control0 (.clk       (clk_gated),
                                         .reset_n   (po_reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (write_seq_transition_control0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_seq_transition_control1")
  u_ovl_x_write_seq_transition_control1 (.clk       (clk_gated),
                                         .reset_n   (po_reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (write_seq_transition_control1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_seq_transition_control2")
  u_ovl_x_write_seq_transition_control2 (.clk       (clk_gated),
                                         .reset_n   (po_reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (write_seq_transition_control2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_ssc_control")
  u_ovl_x_write_ssc_control (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_ssc_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_stall_ctrl")
  u_ovl_x_write_stall_ctrl (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_stall_ctrl));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_sync_period")
  u_ovl_x_write_sync_period (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_sync_period));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trace_config")
  u_ovl_x_write_trace_config (.clk       (clk_gated),
                              .reset_n   (po_reset_n),
                              .qualifier (1'b1),
                              .test_expr (write_trace_config));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr10")
  u_ovl_x_write_trcrsctlr10 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr10));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr11")
  u_ovl_x_write_trcrsctlr11 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr11));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr12")
  u_ovl_x_write_trcrsctlr12 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr12));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr13")
  u_ovl_x_write_trcrsctlr13 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr13));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr14")
  u_ovl_x_write_trcrsctlr14 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr14));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr15")
  u_ovl_x_write_trcrsctlr15 (.clk       (clk_gated),
                             .reset_n   (po_reset_n),
                             .qualifier (1'b1),
                             .test_expr (write_trcrsctlr15));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr2")
  u_ovl_x_write_trcrsctlr2 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr3")
  u_ovl_x_write_trcrsctlr3 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr4")
  u_ovl_x_write_trcrsctlr4 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr5")
  u_ovl_x_write_trcrsctlr5 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr6")
  u_ovl_x_write_trcrsctlr6 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr6));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr7")
  u_ovl_x_write_trcrsctlr7 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr7));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr8")
  u_ovl_x_write_trcrsctlr8 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr8));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_trcrsctlr9")
  u_ovl_x_write_trcrsctlr9 (.clk       (clk_gated),
                            .reset_n   (po_reset_n),
                            .qualifier (1'b1),
                            .test_expr (write_trcrsctlr9));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_ts_event")
  u_ovl_x_write_ts_event (.clk       (clk_gated),
                          .reset_n   (po_reset_n),
                          .qualifier (1'b1),
                          .test_expr (write_ts_event));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_viewinst_control")
  u_ovl_x_write_viewinst_control (.clk       (clk_gated),
                                  .reset_n   (po_reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (write_viewinst_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_viewinst_incexc_control")
  u_ovl_x_write_viewinst_incexc_control (.clk       (clk_gated),
                                         .reset_n   (po_reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (write_viewinst_incexc_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_viewinst_ss_control")
  u_ovl_x_write_viewinst_ss_control (.clk       (clk_gated),
                                     .reset_n   (po_reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (write_viewinst_ss_control));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_vmid_comp_value")
  u_ovl_x_write_vmid_comp_value (.clk       (clk_gated),
                                 .reset_n   (po_reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (write_vmid_comp_value));

     
`endif
endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

