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
// Generates Context ID Comparator Match resource.
// Generates Single Address Comparator Match resources.
// Generates Address Range Comparator Match resources.

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "ca53_dpu_etm_defs.v"
`include "cortexa53params.v"

module  ca53etm_cmp (



//
// Interface Signals
// =================
//

// Global inputs
  input wire           clk_gated,                                   // CPU clock
  input wire           po_reset_n,                                  // Power on Reset

// Inputs

// Waypoint information
  input wire           wpt_valid_t1_i,                              // Valid waypoint in current cycle
  input wire           wpt_valid_t2_i,                              // Valid waypoint in previous cycle
  input wire           wpt_adv_t1_i,                                // Current waypoint pc >= previous waypoint target address
  input wire           wpt_range_t1_i,                              // Suppress address comparators for first waypoint after prohibited or debug

  input wire  [2:0]    wpt_type_t1_i,                               // Cuurent waypoint type
  input wire  [63:1]   wpt_addr_t1_i,                               // Current waypoint pc
  input wire  [63:1]   wpt_target_pc_t2_i,                          // Previous waypoint target pc
  input wire  [31:0]   wpt_context_id_t2_i,                         // Previous context id
  input wire  [7:0]    wpt_vmid_t2_i,                               // Previous vmid
  input wire           wpt_aarch64_t2_i,                            // Previous 64bit state
  input wire           wpt_non_secure_t2_i,                         // Previous security state
  input wire  [3:0]    wpt_exlevel_t2_i,                            // Previous exception level
  input wire           wpt_prohibited_t2_i,                         // Previous prohibited state

// Drain State inputs
  input wire           wfx_resource_t3_i,
  input wire           resource_active_t2_i,                        // resource active

  input wire  [48:0]   comp0_addr_reg_i,                            // Address comparator 0 value
  input wire  [2:0]    comp0_exlevel_s_reg_i,                       // Address comparator 0 secure exception level match control bits
  input wire  [2:0]    comp0_exlevel_ns_reg_i,                      // Address comparator 0 non secure exception level match control bits
  input wire  [1:0]    comp0_context_reg_i,                         // Address comparator 0 context match bits

  input wire  [48:0]   comp1_addr_reg_i,                            // Address comparator 1 value
  input wire  [2:0]    comp1_exlevel_s_reg_i,                       // Address comparator 1 secure exception level match control bits
  input wire  [2:0]    comp1_exlevel_ns_reg_i,                      // Address comparator 1 non secure exception level match control bits
  input wire  [1:0]    comp1_context_reg_i,                         // Address comparator 1 context match bits

  input wire  [48:0]   comp2_addr_reg_i,                            // Address comparator 2 value
  input wire  [2:0]    comp2_exlevel_s_reg_i,                       // Address comparator 2 secure exception level match control bits
  input wire  [2:0]    comp2_exlevel_ns_reg_i,                      // Address comparator 2 non secure exception level match control bits
  input wire  [1:0]    comp2_context_reg_i,                         // Address comparator 2 context match bits

  input wire  [48:0]   comp3_addr_reg_i,                            // Address comparator 3 value
  input wire  [2:0]    comp3_exlevel_s_reg_i,                       // Address comparator 3 secure exception level match control bits
  input wire  [2:0]    comp3_exlevel_ns_reg_i,                      // Address comparator 3 non secure exception level match control bits
  input wire  [1:0]    comp3_context_reg_i,                         // Address comparator 3 context match bits

  input wire  [48:0]   comp4_addr_reg_i,                            // Address comparator 4 value
  input wire  [2:0]    comp4_exlevel_s_reg_i,                       // Address comparator 4 secure exception level match control bits
  input wire  [2:0]    comp4_exlevel_ns_reg_i,                      // Address comparator 4 non secure exception level match control bits
  input wire  [1:0]    comp4_context_reg_i,                         // Address comparator 4 context match bits

  input wire  [48:0]   comp5_addr_reg_i,                            // Address comparator 5 value
  input wire  [2:0]    comp5_exlevel_s_reg_i,                       // Address comparator 5 secure exception level match control bits
  input wire  [2:0]    comp5_exlevel_ns_reg_i,                      // Address comparator 5 non secure exception level match control bits
  input wire  [1:0]    comp5_context_reg_i,                         // Address comparator 5 context match bits

  input wire  [48:0]   comp6_addr_reg_i,                            // Address comparator 6 value
  input wire  [2:0]    comp6_exlevel_s_reg_i,                       // Address comparator 6 secure exception level match control bits
  input wire  [2:0]    comp6_exlevel_ns_reg_i,                      // Address comparator 6 non secure exception level match control bits
  input wire  [1:0]    comp6_context_reg_i,                         // Address comparator 6 context match bits

  input wire  [48:0]   comp7_addr_reg_i,                            // Address comparator 7 value
  input wire  [2:0]    comp7_exlevel_s_reg_i,                       // Address comparator 7 secure exception level match control bits
  input wire  [2:0]    comp7_exlevel_ns_reg_i,                      // Address comparator 7 non secure exception level match control bits
  input wire  [1:0]    comp7_context_reg_i,                         // Address comparator 7 context match bits

  input wire  [31:0]   cid_comp_value_reg_i,                        // CID comparator value
  input wire  [3:0]    cid_comp_mask_reg_i,                         // CID byte mask value

  input wire  [7:0]    vmid_comp_value_reg_i,                       // VMID comparator value

  input wire           ssc_rst_reg_i,                               // Single Shot Comparator 0 Reset Control
  input wire  [3:0]    ssc_arc_reg_i,                               // Single Shot Comparator 0 ARC Control
  input wire  [7:0]    ssc_sac_reg_i,                               // Single Shot Comparator 0 ARC Control
  input wire           ssc_write_i,                                 // Write to Single Shot Comparator Control Status
  input wire           apb_pwdatadbg_31_i,                          // Single Shot Comparator 0 Status Write Value

// Outputs
  output wire          comp0_match_t2_o,                            // SAC 0 match
  output wire          comp1_match_t2_o,                            // SAC 1 match
  output wire          comp2_match_t2_o,                            // SAC 2 match
  output wire          comp3_match_t2_o,                            // SAC 3 match
  output wire          comp4_match_t2_o,                            // SAC 4 match
  output wire          comp5_match_t2_o,                            // SAC 5 match
  output wire          comp6_match_t2_o,                            // SAC 6 match
  output wire          comp7_match_t2_o,                            // SAC 7 match
  output wire          range0_match_t2_o,                           // ARC 0 include match
  output wire          range1_match_t2_o,                           // ARC 1 include match
  output wire          range2_match_t2_o,                           // ARC 2 include match
  output wire          range3_match_t2_o,                           // ARC 3 include match
  output wire          range0_excl_t2_o,                            // ARC 0 exclude match
  output wire          range1_excl_t2_o,                            // ARC 1 exclude match
  output wire          range2_excl_t2_o,                            // ARC 2 exclude match
  output wire          range3_excl_t2_o,                            // ARC 3 exclude match
  output wire          cid_match_t2_o,                              // CID comparator match
  output wire          vmid_match_t2_o,                             // VMID comparator match

  output wire          ssc_status_t2_o,                             // Single Shot Comparator Value to Read Mux
  output wire          ssc_resource_t2_o                            // Single Shot Comparator Value to Resource Bus
 );

localparam CA53_ETM_SSC_IDLE          =2'b00;
localparam CA53_ETM_SSC_ACTIVE        =2'b01;
localparam CA53_ETM_SSC_DONE          =2'b10;
localparam CA53_ETM_SSC_UNUSED        =2'b11;

//
//
// Internal Signals - Automatic Declarations
// =========================================
//
  wire           match_update_en;
  wire           cid_match_t1;
  reg            cid_match_t2;
  wire           clear_ssc_status;
  wire           ssc_match_t2;
  wire           comp0_addr_match_t1;
  wire [ 63:  0] comp0_addr_value;
  wire           comp0_cid_match_t1;
  wire           comp0_match_t1;
  reg            comp0_match_t2;
  wire           comp0_match_t2_comb;
  reg            comp0_addr_match_t2;
  wire           comp0_mode_match_t1;
  wire           comp0_nsec_match_t1;
  wire           comp0_sec_match_t1;
  wire           comp0_vmid_match_t1;
  wire           comp1_addr_match_t1;
  wire [ 63:  0] comp1_addr_value;
  wire           comp1_cid_match_t1;
  wire           comp1_match_t1;
  reg            comp1_match_t2;
  wire           comp1_match_t2_comb;
  reg            comp1_addr_match_t2;
  wire           comp1_mode_match_t1;
  wire           comp1_nsec_match_t1;
  wire           comp1_sec_match_t1;
  wire           comp1_vmid_match_t1;
  wire           comp2_addr_match_t1;
  wire [ 63:  0] comp2_addr_value;
  wire           comp2_cid_match_t1;
  wire           comp2_match_t1;
  reg            comp2_match_t2;
  wire           comp2_match_t2_comb;
  reg            comp2_addr_match_t2;
  wire           comp2_mode_match_t1;
  wire           comp2_nsec_match_t1;
  wire           comp2_sec_match_t1;
  wire           comp2_vmid_match_t1;
  wire           comp3_addr_match_t1;
  wire [ 63:  0] comp3_addr_value;
  wire           comp3_cid_match_t1;
  wire           comp3_match_t1;
  reg            comp3_match_t2;
  wire           comp3_match_t2_comb;
  reg            comp3_addr_match_t2;
  wire           comp3_mode_match_t1;
  wire           comp3_nsec_match_t1;
  wire           comp3_sec_match_t1;
  wire           comp3_vmid_match_t1;
  wire           comp4_addr_match_t1;
  wire [ 63:  0] comp4_addr_value;
  wire           comp4_cid_match_t1;
  wire           comp4_match_t1;
  reg            comp4_match_t2;
  wire           comp4_match_t2_comb;
  reg            comp4_addr_match_t2;
  wire           comp4_mode_match_t1;
  wire           comp4_nsec_match_t1;
  wire           comp4_sec_match_t1;
  wire           comp4_vmid_match_t1;
  wire           comp5_addr_match_t1;
  wire [ 63:  0] comp5_addr_value;
  wire           comp5_cid_match_t1;
  wire           comp5_match_t1;
  reg            comp5_match_t2;
  wire           comp5_match_t2_comb;
  reg            comp5_addr_match_t2;
  wire           comp5_mode_match_t1;
  wire           comp5_nsec_match_t1;
  wire           comp5_sec_match_t1;
  wire           comp5_vmid_match_t1;
  wire           comp6_addr_match_t1;
  wire [ 63:  0] comp6_addr_value;
  wire           comp6_cid_match_t1;
  wire           comp6_match_t1;
  reg            comp6_match_t2;
  wire           comp6_match_t2_comb;
  reg            comp6_addr_match_t2;
  wire           comp6_mode_match_t1;
  wire           comp6_nsec_match_t1;
  wire           comp6_sec_match_t1;
  wire           comp6_vmid_match_t1;
  wire           comp7_addr_match_t1;
  wire [ 63:  0] comp7_addr_value;
  wire           comp7_cid_match_t1;
  wire           comp7_match_t1;
  reg            comp7_match_t2;
  wire           comp7_match_t2_comb;
  reg            comp7_addr_match_t2;
  wire           comp7_mode_match_t1;
  wire           comp7_nsec_match_t1;
  wire           comp7_sec_match_t1;
  wire           comp7_vmid_match_t1;
  wire           range0_addr_excl_l_t1;
  wire           range0_addr_excl_h_t1;
  reg            range0_addr_excl_l_t2;
  reg            range0_addr_excl_h_t2;
  wire           range0_addr_match_t1;
  reg            range0_addr_match_t2;
  wire           range0_excl_t1;
  reg            range0_excl_t2;
  wire           range0_match_t1;
  reg            range0_match_t2;
  wire           range0_match_t2_comb;
  wire           range1_addr_excl_l_t1;
  wire           range1_addr_excl_h_t1;
  reg            range1_addr_excl_l_t2;
  reg            range1_addr_excl_h_t2;
  wire           range1_addr_match_t1;
  reg            range1_addr_match_t2;
  wire           range1_excl_t1;
  reg            range1_excl_t2;
  wire           range1_match_t1;
  reg            range1_match_t2;
  wire           range1_match_t2_comb;
  wire           range2_addr_excl_l_t1;
  wire           range2_addr_excl_h_t1;
  reg            range2_addr_excl_l_t2;
  reg            range2_addr_excl_h_t2;
  wire           range2_addr_match_t1;
  reg            range2_addr_match_t2;
  wire           range2_excl_t1;
  reg            range2_excl_t2;
  wire           range2_match_t1;
  reg            range2_match_t2;
  wire           range2_match_t2_comb;
  wire           range3_addr_excl_l_t1;
  wire           range3_addr_excl_h_t1;
  reg            range3_addr_excl_l_t2;
  reg            range3_addr_excl_h_t2;
  wire           range3_addr_match_t1;
  reg            range3_addr_match_t2;
  wire           range3_excl_t1;
  reg            range3_excl_t2;
  wire           range3_match_t1;
  reg            range3_match_t2;
  wire           range3_match_t2_comb;
  wire           set_ssc_status;
  wire           ssc_resource_t2;
  reg            ssc_resource_t3;
  wire           ssc_state_en;
  reg  [  1:  0] ssc_state_t2;
  reg  [  1:  0] ssc_state_t3;
  wire           ssc_status_t2;
  reg            ssc_status_t3;
  wire           vmid_match_t1;
  reg            vmid_match_t2;
  wire [ 63:  0] wpt_pc_exec_t1;
  wire [ 63:  0] wpt_addr_t1;
  wire           wpt_type_excp_or_dbgentry;
  wire           wpt_adv_valid_t1;
  wire           comp_active_t1;
  wire           first_wpt_after_enable_t1;
  reg            first_wpt_after_enable_t2;
  wire           next_comp0_addr_value_top_half_zero; 
  reg            comp0_addr_value_top_half_zero; 
  wire           next_comp1_addr_value_top_half_zero; 
  reg            comp1_addr_value_top_half_zero; 
  wire           next_comp2_addr_value_top_half_zero; 
  reg            comp2_addr_value_top_half_zero; 
  wire           next_comp3_addr_value_top_half_zero; 
  reg            comp3_addr_value_top_half_zero; 
  wire           next_comp4_addr_value_top_half_zero; 
  reg            comp4_addr_value_top_half_zero; 
  wire           next_comp5_addr_value_top_half_zero; 
  reg            comp5_addr_value_top_half_zero; 
  wire           next_comp6_addr_value_top_half_zero; 
  reg            comp6_addr_value_top_half_zero; 
  wire           next_comp7_addr_value_top_half_zero; 
  reg            comp7_addr_value_top_half_zero; 



//
// Main Code
// =========
//

//use first_wpt_after_enable_t2 to suppress the resource match for the first wpt
//after trace is enabled
  assign first_wpt_after_enable_t1 = (~resource_active_t2_i & ~wfx_resource_t3_i) |
                                      (first_wpt_after_enable_t2 & ~wpt_valid_t2_i);


  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufirst_wpt_after_enable
    if (!po_reset_n)
      first_wpt_after_enable_t2 <= 1'b1;
    else
      first_wpt_after_enable_t2 <= first_wpt_after_enable_t1;
  end



// comparator match control signals assignment
  assign wpt_adv_valid_t1  = wpt_adv_t1_i & wpt_valid_t1_i;
  assign comp_active_t1    = wpt_adv_valid_t1 & wpt_range_t1_i & ~first_wpt_after_enable_t1;
  assign match_update_en   = (~resource_active_t2_i | wpt_valid_t1_i | wpt_valid_t2_i);

// Waypoint type is exception or debug entry
  assign wpt_type_excp_or_dbgentry = (wpt_type_t1_i[2:0] == `CA53_ETM_WPT_EXCEPTION) |
                                     (wpt_type_t1_i[2:0] == `CA53_ETM_WPT_DBGENTRY);

// Use current pc for normal waypoints
// Use current pc -1 for exception type waypoints
  assign wpt_addr_t1[63:0]    = {wpt_addr_t1_i[63:1], 1'b0};
  assign wpt_pc_exec_t1[63:0] = wpt_type_excp_or_dbgentry ?
                                (wpt_aarch64_t2_i ? (wpt_addr_t1[63:0] - {{63{1'b0}},1'b1}) :
                                                    ({{32{1'b0}},(wpt_addr_t1[31:0] - {{31{1'b0}},1'b1})})) :
                                (wpt_addr_t1[63:0]);

//---------------------------------------------------------------------------
//  VMID Comparator
//---------------------------------------------------------------------------

// VMID change applies to block following a waypoint, so take previous value for the current block
// Current waypoint pc >= previous waypoint target with no exception
// Matches for any cycles if at least one instruction is executed with VMID value.
// Need to suppress on exit from debug state or prohibited region
  assign vmid_match_t1 = (vmid_comp_value_reg_i[7:0] == wpt_vmid_t2_i[7:0]) &
                         comp_active_t1 &
                         ~wpt_prohibited_t2_i;

// VMID match is only valid for one cycle
  assign vmid_match_t2_o = vmid_match_t2 & resource_active_t2_i;

//---------------------------------------------------------------------------
//  Context ID Comparator
//---------------------------------------------------------------------------

// Bits set in mask are ignored.
// CID change applies to block following a waypoint, so take previous value for the current block
// Current waypoint pc >= previous waypoint target with no exception
// Matches for any cycles if at least one instruction is executed with CID value.
// Need to suppress on exit from debug state or prohibited region
  assign cid_match_t1 = (&(({{8{cid_comp_mask_reg_i[3]}},{8{cid_comp_mask_reg_i[2]}},{8{cid_comp_mask_reg_i[1]}},{8{cid_comp_mask_reg_i[0]}}}) |
                           (cid_comp_value_reg_i[31:0] ^ ~wpt_context_id_t2_i[31:0]))) &
                           comp_active_t1 &
                           ~wpt_prohibited_t2_i;

// Context ID match is only valid for one cycle
  assign cid_match_t2_o = cid_match_t2 & resource_active_t2_i;

//---------------------------------------------------------------------------
//  Address Comparator VMID, CID and Security state and Exception Level control
//---------------------------------------------------------------------------

// VMID match
// compn_context_reg[1]
// 0 => Ignore match, 1 => Match Match VMID comparator
  assign comp0_vmid_match_t1 = vmid_match_t1 | ~comp0_context_reg_i[1];
  assign comp1_vmid_match_t1 = vmid_match_t1 | ~comp1_context_reg_i[1];
  assign comp2_vmid_match_t1 = vmid_match_t1 | ~comp2_context_reg_i[1];
  assign comp3_vmid_match_t1 = vmid_match_t1 | ~comp3_context_reg_i[1];
  assign comp4_vmid_match_t1 = vmid_match_t1 | ~comp4_context_reg_i[1];
  assign comp5_vmid_match_t1 = vmid_match_t1 | ~comp5_context_reg_i[1];
  assign comp6_vmid_match_t1 = vmid_match_t1 | ~comp6_context_reg_i[1];
  assign comp7_vmid_match_t1 = vmid_match_t1 | ~comp7_context_reg_i[1];

// CID match
// compn_context_reg[0]
// 0 => Ignore match, 1 => Match CID comparator
  assign comp0_cid_match_t1 = cid_match_t1 | ~comp0_context_reg_i[0];
  assign comp1_cid_match_t1 = cid_match_t1 | ~comp1_context_reg_i[0];
  assign comp2_cid_match_t1 = cid_match_t1 | ~comp2_context_reg_i[0];
  assign comp3_cid_match_t1 = cid_match_t1 | ~comp3_context_reg_i[0];
  assign comp4_cid_match_t1 = cid_match_t1 | ~comp4_context_reg_i[0];
  assign comp5_cid_match_t1 = cid_match_t1 | ~comp5_context_reg_i[0];
  assign comp6_cid_match_t1 = cid_match_t1 | ~comp6_context_reg_i[0];
  assign comp7_cid_match_t1 = cid_match_t1 | ~comp7_context_reg_i[0];

// Security and Exception level match.

// compn_exlevel_s_reg[1] => Secure EL3
// compn_exlevel_s_reg[1] => Secure EL1
// compn_exlevel_s_reg[0] => Secure EL0
  assign comp0_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp0_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp1_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp1_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp2_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp2_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp3_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp3_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp4_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp4_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp5_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp5_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp6_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp6_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});
  assign comp7_sec_match_t1 = ~wpt_non_secure_t2_i & |(~comp7_exlevel_s_reg_i[2:0] & {wpt_exlevel_t2_i[3],wpt_exlevel_t2_i[1:0]});


// compn_exlevel_ns_reg[2] => Non Secure EL2
// compn_exlevel_ns_reg[1] => Non Secure EL1
// compn_exlevel_ns_reg[0] => Non Secure EL0
  assign comp0_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp0_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp1_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp1_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp2_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp2_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp3_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp3_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp4_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp4_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp5_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp5_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp6_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp6_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);
  assign comp7_nsec_match_t1 = wpt_non_secure_t2_i & |(~comp7_exlevel_ns_reg_i[2:0] & wpt_exlevel_t2_i[2:0]);

  assign comp0_mode_match_t1 = comp0_sec_match_t1 | comp0_nsec_match_t1;
  assign comp1_mode_match_t1 = comp1_sec_match_t1 | comp1_nsec_match_t1;
  assign comp2_mode_match_t1 = comp2_sec_match_t1 | comp2_nsec_match_t1;
  assign comp3_mode_match_t1 = comp3_sec_match_t1 | comp3_nsec_match_t1;
  assign comp4_mode_match_t1 = comp4_sec_match_t1 | comp4_nsec_match_t1;
  assign comp5_mode_match_t1 = comp5_sec_match_t1 | comp5_nsec_match_t1;
  assign comp6_mode_match_t1 = comp6_sec_match_t1 | comp6_nsec_match_t1;
  assign comp7_mode_match_t1 = comp7_sec_match_t1 | comp7_nsec_match_t1;

//---------------------------------------------------------------------------
// Address Comparator value
//---------------------------------------------------------------------------

// Sign extend upper 16 bits of addr value in AArch 64 mode and AArch32 mode
// Zero extend upper 32 bits of current pc and prev target pc in AArch32 mode

  assign comp0_addr_value[63:0] = {{16{comp0_addr_reg_i[48]}}, comp0_addr_reg_i[47:32], comp0_addr_reg_i[31:0]};
  assign comp1_addr_value[63:0] = {{16{comp1_addr_reg_i[48]}}, comp1_addr_reg_i[47:32], comp1_addr_reg_i[31:0]};
  assign comp2_addr_value[63:0] = {{16{comp2_addr_reg_i[48]}}, comp2_addr_reg_i[47:32], comp2_addr_reg_i[31:0]};
  assign comp3_addr_value[63:0] = {{16{comp3_addr_reg_i[48]}}, comp3_addr_reg_i[47:32], comp3_addr_reg_i[31:0]};
  assign comp4_addr_value[63:0] = {{16{comp4_addr_reg_i[48]}}, comp4_addr_reg_i[47:32], comp4_addr_reg_i[31:0]};
  assign comp5_addr_value[63:0] = {{16{comp5_addr_reg_i[48]}}, comp5_addr_reg_i[47:32], comp5_addr_reg_i[31:0]};
  assign comp6_addr_value[63:0] = {{16{comp6_addr_reg_i[48]}}, comp6_addr_reg_i[47:32], comp6_addr_reg_i[31:0]};
  assign comp7_addr_value[63:0] = {{16{comp7_addr_reg_i[48]}}, comp7_addr_reg_i[47:32], comp7_addr_reg_i[31:0]};


  assign next_comp0_addr_value_top_half_zero = ~|comp0_addr_value[48:32];
  assign next_comp1_addr_value_top_half_zero = ~|comp1_addr_value[48:32];
  assign next_comp2_addr_value_top_half_zero = ~|comp2_addr_value[48:32];
  assign next_comp3_addr_value_top_half_zero = ~|comp3_addr_value[48:32];
  assign next_comp4_addr_value_top_half_zero = ~|comp4_addr_value[48:32];
  assign next_comp5_addr_value_top_half_zero = ~|comp5_addr_value[48:32];
  assign next_comp6_addr_value_top_half_zero = ~|comp6_addr_value[48:32];
  assign next_comp7_addr_value_top_half_zero = ~|comp7_addr_value[48:32];



  always @(posedge clk_gated )
  begin: comp_addr_value_top_half_zero
    comp0_addr_value_top_half_zero <= next_comp0_addr_value_top_half_zero;
    comp1_addr_value_top_half_zero <= next_comp1_addr_value_top_half_zero;
    comp2_addr_value_top_half_zero <= next_comp2_addr_value_top_half_zero;
    comp3_addr_value_top_half_zero <= next_comp3_addr_value_top_half_zero;
    comp4_addr_value_top_half_zero <= next_comp4_addr_value_top_half_zero;
    comp5_addr_value_top_half_zero <= next_comp5_addr_value_top_half_zero;
    comp6_addr_value_top_half_zero <= next_comp6_addr_value_top_half_zero;
    comp7_addr_value_top_half_zero <= next_comp7_addr_value_top_half_zero;
  end




//---------------------------------------------------------------------------
//  Single Address Comparators (SACs)
//---------------------------------------------------------------------------

// Address match for SAC
// Addr >= previous target and ((Addr <= current pc and not exception) or
// (Addr <= current pc-1 and exception))
  assign comp0_addr_match_t1 = ((comp0_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp0_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp0_addr_value_top_half_zero) |
                                 ((comp0_addr_value[63:0] == {wpt_addr_t1_i[63:1], 1'b0}) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp1_addr_match_t1 = ((comp1_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp1_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp1_addr_value_top_half_zero) |
                                 ((comp1_addr_value[63:0] == {wpt_addr_t1_i[63:1], 1'b0}) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp2_addr_match_t1 = ((comp2_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp2_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp2_addr_value_top_half_zero) |
                                 ((comp2_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp3_addr_match_t1 = ((comp3_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp3_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp3_addr_value_top_half_zero) |
                                 ((comp3_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp4_addr_match_t1 = ((comp4_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp4_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp4_addr_value_top_half_zero) |
                                 ((comp4_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp5_addr_match_t1 = ((comp5_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp5_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp5_addr_value_top_half_zero) |
                                 ((comp5_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp6_addr_match_t1 = ((comp6_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp6_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) | 
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp6_addr_value_top_half_zero) |
                                 ((comp6_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );
  assign comp7_addr_match_t1 = ((comp7_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1]) &
                                ((comp7_addr_value[63:0]  <  {wpt_addr_t1_i[63:1], 1'b0}) |
                                 ((~|wpt_addr_t1[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                 ((~|wpt_addr_t1[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp7_addr_value_top_half_zero) |
                                 ((comp7_addr_value[63:0] == wpt_addr_t1[63:0]) & ~wpt_type_excp_or_dbgentry))
                               );

// SAC Match
// wpt_adv_t1_i makes sure that current pc >= previous target with no exception
// wpt_range_t1_i makes sure that matches are suppressed in prohibit/debug regions.
  assign comp0_match_t1 = comp0_cid_match_t1 & comp0_vmid_match_t1 & comp0_mode_match_t1 &
                          comp_active_t1;
  assign comp1_match_t1 = comp1_cid_match_t1 & comp1_vmid_match_t1 & comp1_mode_match_t1 &
                          comp_active_t1;
  assign comp2_match_t1 = comp2_cid_match_t1 & comp2_vmid_match_t1 & comp2_mode_match_t1 &
                          comp_active_t1;
  assign comp3_match_t1 = comp3_cid_match_t1 & comp3_vmid_match_t1 & comp3_mode_match_t1 &
                          comp_active_t1;
  assign comp4_match_t1 = comp4_cid_match_t1 & comp4_vmid_match_t1 & comp4_mode_match_t1 &
                          comp_active_t1;
  assign comp5_match_t1 = comp5_cid_match_t1 & comp5_vmid_match_t1 & comp5_mode_match_t1 &
                          comp_active_t1;
  assign comp6_match_t1 = comp6_cid_match_t1 & comp6_vmid_match_t1 & comp6_mode_match_t1 &
                          comp_active_t1;
  assign comp7_match_t1 = comp7_cid_match_t1 & comp7_vmid_match_t1 & comp7_mode_match_t1 &
                          comp_active_t1;

// SAC match valid only for one cycle
// Enable from current and previous to allow set and clear

  always @(posedge clk_gated)
  begin: ucomp_match_t2
    if (match_update_en) begin
      vmid_match_t2       <= vmid_match_t1;
      cid_match_t2        <= cid_match_t1;
      comp0_addr_match_t2 <= comp0_addr_match_t1;
      comp1_addr_match_t2 <= comp1_addr_match_t1;
      comp2_addr_match_t2 <= comp2_addr_match_t1;
      comp3_addr_match_t2 <= comp3_addr_match_t1;
      comp4_addr_match_t2 <= comp4_addr_match_t1;
      comp5_addr_match_t2 <= comp5_addr_match_t1;
      comp6_addr_match_t2 <= comp6_addr_match_t1;
      comp7_addr_match_t2 <= comp7_addr_match_t1;
      comp0_match_t2 <= comp0_match_t1;
      comp1_match_t2 <= comp1_match_t1;
      comp2_match_t2 <= comp2_match_t1;
      comp3_match_t2 <= comp3_match_t1;
      comp4_match_t2 <= comp4_match_t1;
      comp5_match_t2 <= comp5_match_t1;
      comp6_match_t2 <= comp6_match_t1;
      comp7_match_t2 <= comp7_match_t1;
    end
  end


  assign comp0_match_t2_comb = comp0_match_t2 & comp0_addr_match_t2 & resource_active_t2_i;
  assign comp1_match_t2_comb = comp1_match_t2 & comp1_addr_match_t2 & resource_active_t2_i;
  assign comp2_match_t2_comb = comp2_match_t2 & comp2_addr_match_t2 & resource_active_t2_i;
  assign comp3_match_t2_comb = comp3_match_t2 & comp3_addr_match_t2 & resource_active_t2_i;
  assign comp4_match_t2_comb = comp4_match_t2 & comp4_addr_match_t2 & resource_active_t2_i;
  assign comp5_match_t2_comb = comp5_match_t2 & comp5_addr_match_t2 & resource_active_t2_i;
  assign comp6_match_t2_comb = comp6_match_t2 & comp6_addr_match_t2 & resource_active_t2_i;
  assign comp7_match_t2_comb = comp7_match_t2 & comp7_addr_match_t2 & resource_active_t2_i;

  assign comp0_match_t2_o = comp0_match_t2_comb ;
  assign comp1_match_t2_o = comp1_match_t2_comb ;
  assign comp2_match_t2_o = comp2_match_t2_comb ;
  assign comp3_match_t2_o = comp3_match_t2_comb ;
  assign comp4_match_t2_o = comp4_match_t2_comb ;
  assign comp5_match_t2_o = comp5_match_t2_comb ;
  assign comp6_match_t2_o = comp6_match_t2_comb ;
  assign comp7_match_t2_o = comp7_match_t2_comb ;


//---------------------------------------------------------------------------
//  Address Range Comparators (ARC)
//---------------------------------------------------------------------------

// Address match for ARC include
// Match if there is any overlap
// ((Low Addr <= current pc and not exception ) or
// (Low Addr <= current pc-1 and exception)) and High Addr >= previous target
  assign range0_addr_match_t1 = (((comp0_addr_value[63:1]  <  wpt_addr_t1_i[63:1]) |     
                                  ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                  ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp0_addr_value_top_half_zero) |
                                  ((comp0_addr_value[63:0] == {wpt_addr_t1_i[63:1],1'b0}) & ~wpt_type_excp_or_dbgentry)) &
                                 (comp1_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1])
                                );
  assign range1_addr_match_t1 = (((comp2_addr_value[63:1]  <  wpt_addr_t1_i[63:1]) | 
                                  ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                  ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp2_addr_value_top_half_zero) |
                                  ((comp2_addr_value[63:0] == {wpt_addr_t1_i[63:1],1'b0}) & ~wpt_type_excp_or_dbgentry)) &
                                 (comp3_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1])
                                );
  assign range2_addr_match_t1 = (((comp4_addr_value[63:1]  <  wpt_addr_t1_i[63:1]) |  
                                  ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                  ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp4_addr_value_top_half_zero) |
                                  ((comp4_addr_value[63:0] == {wpt_addr_t1_i[63:1],1'b0}) & ~wpt_type_excp_or_dbgentry)) &
                                 (comp5_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1])
                                );
  assign range3_addr_match_t1 = (((comp6_addr_value[63:1]  <  wpt_addr_t1_i[63:1]) |   
                                  ((~|wpt_addr_t1_i[63:1])   &  wpt_type_excp_or_dbgentry & wpt_aarch64_t2_i  ) |
                                  ((~|wpt_addr_t1_i[31:1])   &  wpt_type_excp_or_dbgentry & ~wpt_aarch64_t2_i & comp6_addr_value_top_half_zero) |
                                  ((comp6_addr_value[63:0] == {wpt_addr_t1_i[63:1],1'b0}) & ~wpt_type_excp_or_dbgentry)) &
                                 (comp7_addr_value[63:1]   >= wpt_target_pc_t2_i[63:1])
                                );

// ARC Include Match
// wpt_adv_t1_i makes sure that current pc >= previous target
// wpt_range_t1_i makes sure that matches are suppressed in prohibit/debug regions.
// do not match if trace is disabled
  assign range0_match_t1 = comp0_cid_match_t1 & comp0_vmid_match_t1 & comp0_mode_match_t1 &
                           comp1_cid_match_t1 & comp1_vmid_match_t1 & comp1_mode_match_t1 &
                           comp_active_t1;
  assign range1_match_t1 = comp2_cid_match_t1 & comp2_vmid_match_t1 & comp2_mode_match_t1 &
                           comp3_cid_match_t1 & comp3_vmid_match_t1 & comp3_mode_match_t1 &
                           comp_active_t1;
  assign range2_match_t1 = comp4_cid_match_t1 & comp4_vmid_match_t1 & comp4_mode_match_t1 &
                           comp5_cid_match_t1 & comp5_vmid_match_t1 & comp5_mode_match_t1 &
                           comp_active_t1;
  assign range3_match_t1 = comp6_cid_match_t1 & comp6_vmid_match_t1 & comp6_mode_match_t1 &
                           comp7_cid_match_t1 & comp7_vmid_match_t1 & comp7_mode_match_t1 &
                           comp_active_t1;

// ARC include match valid only for one cycle

  always @(posedge clk_gated)
  begin: urange_match_t2
    if (match_update_en) begin
      range0_addr_match_t2 <= range0_addr_match_t1;
      range1_addr_match_t2 <= range1_addr_match_t1;
      range2_addr_match_t2 <= range2_addr_match_t1;
      range3_addr_match_t2 <= range3_addr_match_t1;
      range0_match_t2 <= range0_match_t1;
      range1_match_t2 <= range1_match_t1;
      range2_match_t2 <= range2_match_t1;
      range3_match_t2 <= range3_match_t1;
    end
  end


  assign range0_match_t2_comb = range0_match_t2 & range0_addr_match_t2 & resource_active_t2_i;
  assign range1_match_t2_comb = range1_match_t2 & range1_addr_match_t2 & resource_active_t2_i;
  assign range2_match_t2_comb = range2_match_t2 & range2_addr_match_t2 & resource_active_t2_i;
  assign range3_match_t2_comb = range3_match_t2 & range3_addr_match_t2 & resource_active_t2_i;

  assign range0_match_t2_o = range0_match_t2_comb;
  assign range1_match_t2_o = range1_match_t2_comb;
  assign range2_match_t2_o = range2_match_t2_comb;
  assign range3_match_t2_o = range3_match_t2_comb;


// Address match for ARC exclude
// Match if the block is completely within the range
// Low Addr <= previous target and ((High Addr >= current pc and not an exception) or
//                                  (High Addr >= current pc -1 and an exception))
  assign range0_addr_excl_l_t1 = comp0_addr_value[63:0] <= {wpt_target_pc_t2_i[63:1],1'b0};
  assign range0_addr_excl_h_t1 = comp1_addr_value[63:0] >= wpt_pc_exec_t1[63:0];
  assign range1_addr_excl_l_t1 = comp2_addr_value[63:0] <= {wpt_target_pc_t2_i[63:1],1'b0};
  assign range1_addr_excl_h_t1 = comp3_addr_value[63:0] >= wpt_pc_exec_t1[63:0];
  assign range2_addr_excl_l_t1 = comp4_addr_value[63:0] <= {wpt_target_pc_t2_i[63:1],1'b0};
  assign range2_addr_excl_h_t1 = comp5_addr_value[63:0] >= wpt_pc_exec_t1[63:0];
  assign range3_addr_excl_l_t1 = comp6_addr_value[63:0] <= {wpt_target_pc_t2_i[63:1],1'b0};
  assign range3_addr_excl_h_t1 = comp7_addr_value[63:0] >= wpt_pc_exec_t1[63:0];

// ARC Exclude Match
// wpt_adv_t1_i makes sure that current pc >= previous target
// match if prog bit is set
  assign range0_excl_t1 = (comp0_cid_match_t1 & comp0_vmid_match_t1 & comp0_mode_match_t1 &
                           comp1_cid_match_t1 & comp1_vmid_match_t1 & comp1_mode_match_t1 &
                           wpt_adv_valid_t1);
  assign range1_excl_t1 = (comp2_cid_match_t1 & comp2_vmid_match_t1 & comp2_mode_match_t1 &
                           comp3_cid_match_t1 & comp3_vmid_match_t1 & comp3_mode_match_t1 &
                           wpt_adv_valid_t1);
  assign range2_excl_t1 = (comp4_cid_match_t1 & comp4_vmid_match_t1 & comp4_mode_match_t1 &
                           comp5_cid_match_t1 & comp5_vmid_match_t1 & comp5_mode_match_t1 &
                           wpt_adv_valid_t1);
  assign range3_excl_t1 = (comp6_cid_match_t1 & comp6_vmid_match_t1 & comp6_mode_match_t1 &
                           comp7_cid_match_t1 & comp7_vmid_match_t1 & comp7_mode_match_t1 &
                           wpt_adv_valid_t1 );

// ARC exclude match valid only for one cycle

  always @(posedge clk_gated)
  begin: urange_excl_t2
    if (match_update_en) begin
      range0_addr_excl_l_t2 <= range0_addr_excl_l_t1;
      range0_addr_excl_h_t2 <= range0_addr_excl_h_t1;
      range1_addr_excl_l_t2 <= range1_addr_excl_l_t1;
      range1_addr_excl_h_t2 <= range1_addr_excl_h_t1;
      range2_addr_excl_l_t2 <= range2_addr_excl_l_t1;
      range2_addr_excl_h_t2 <= range2_addr_excl_h_t1;
      range3_addr_excl_l_t2 <= range3_addr_excl_l_t1;
      range3_addr_excl_h_t2 <= range3_addr_excl_h_t1;
      range0_excl_t2 <= range0_excl_t1;
      range1_excl_t2 <= range1_excl_t1;
      range2_excl_t2 <= range2_excl_t1;
      range3_excl_t2 <= range3_excl_t1;
    end
  end

  assign range0_excl_t2_o = (range0_excl_t2 & range0_addr_excl_l_t2 & range0_addr_excl_h_t2) | ~resource_active_t2_i;
  assign range1_excl_t2_o = (range1_excl_t2 & range1_addr_excl_l_t2 & range1_addr_excl_h_t2) | ~resource_active_t2_i;
  assign range2_excl_t2_o = (range2_excl_t2 & range2_addr_excl_l_t2 & range2_addr_excl_h_t2) | ~resource_active_t2_i;
  assign range3_excl_t2_o = (range3_excl_t2 & range3_addr_excl_l_t2 & range3_addr_excl_h_t2) | ~resource_active_t2_i;

//---------------------------------------------------------------------------------
// Single Shot Comparator Control
//---------------------------------------------------------------------------------

// Update to Single Shot Comparator is based on
//  Status register write or
//  Selected ARC match or
//  Selected SAC match
// Multiple matches can occur if reset is enabled or else
// only a single match can occur
// SSC resource can be high only for one cycle due to a single match


// Register write to SSC status
  assign set_ssc_status   = ssc_write_i & apb_pwdatadbg_31_i;
  assign clear_ssc_status = ssc_write_i & ~apb_pwdatadbg_31_i;

// SAC or ARC selection match
  assign ssc_match_t2 = (|(ssc_sac_reg_i[7:0] & {comp7_match_t2_comb,
                                                 comp6_match_t2_comb,
                                                 comp5_match_t2_comb,
                                                 comp4_match_t2_comb,
                                                 comp3_match_t2_comb,
                                                 comp2_match_t2_comb,
                                                 comp1_match_t2_comb,
                                                 comp0_match_t2_comb
                                              })) |
                        (|(ssc_arc_reg_i[3:0] & {range3_match_t2_comb,
                                                 range2_match_t2_comb,
                                                 range1_match_t2_comb,
                                                 range0_match_t2_comb
                                              }));


  always @*
    case(ssc_state_t3)
      CA53_ETM_SSC_IDLE: ssc_state_t2 = resource_active_t2_i ? CA53_ETM_SSC_ACTIVE :
                                        ~set_ssc_status      ? CA53_ETM_SSC_IDLE   :
                                         ssc_rst_reg_i       ? CA53_ETM_SSC_ACTIVE :
                                                               CA53_ETM_SSC_DONE;
      CA53_ETM_SSC_ACTIVE: ssc_state_t2 = resource_active_t2_i ?
                                          ((~ssc_rst_reg_i & ssc_match_t2) ? 
                                           CA53_ETM_SSC_DONE    : 
                                           CA53_ETM_SSC_ACTIVE) : 
                                          (clear_ssc_status ? CA53_ETM_SSC_IDLE :
                                           ((set_ssc_status | ssc_status_t3) & ~ssc_rst_reg_i ? 
                                            CA53_ETM_SSC_DONE : 
                                            CA53_ETM_SSC_ACTIVE));
      CA53_ETM_SSC_DONE: ssc_state_t2 = resource_active_t2_i ?
                                        (ssc_rst_reg_i ? CA53_ETM_SSC_ACTIVE  :
                                                         CA53_ETM_SSC_DONE)   :
                                        (clear_ssc_status ? CA53_ETM_SSC_IDLE :
                                         ((set_ssc_status & ssc_rst_reg_i) ? 
                                          CA53_ETM_SSC_ACTIVE : 
                                          CA53_ETM_SSC_DONE));
      default: ssc_state_t2 = {2{1'bx}};
    endcase // case (ssc_state_t3)

  assign ssc_status_t2 = resource_active_t2_i ?
                         (((ssc_state_t3 == CA53_ETM_SSC_ACTIVE) & ssc_match_t2) |
                          ssc_status_t3) :
                         (set_ssc_status | (~clear_ssc_status  & ssc_status_t3));

  assign ssc_resource_t2 = resource_active_t2_i & ssc_match_t2 & 
                           (ssc_state_t3 == CA53_ETM_SSC_ACTIVE);
  
  assign ssc_state_en =  (set_ssc_status | clear_ssc_status) |     // Register write to SSC status or
                         (ssc_state_t3 == CA53_ETM_SSC_ACTIVE & ~ssc_rst_reg_i) | // Non-reset state
                         (resource_active_t2_i | ssc_resource_t3); // enabled/disabled

// On reset ssc_state_t3 should be 2'b00
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ussc_state_q
    if (!po_reset_n) begin
      ssc_state_t3[1:0] <= CA53_ETM_SSC_IDLE;
      ssc_status_t3     <= 1'b0;
      ssc_resource_t3   <= 1'b0;
    end
    else if (ssc_state_en) begin
      ssc_state_t3[1:0] <= ssc_state_t2[1:0];
      ssc_status_t3     <= ssc_status_t2;
      ssc_resource_t3   <= ssc_resource_t2;
    end
  end


// Read value of status bit in TRCSSCSR0
  assign ssc_status_t2_o   = ssc_status_t2;
  assign ssc_resource_t2_o = ssc_resource_t2;
//--------------------------------------------------------------------------
//  ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON
`include "ca53etm_val_defs.v"


  usva_cmp_ssc_resource: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
          ~ssc_rst_reg_i & ssc_resource_t2 |=> ~ssc_resource_t2 )
    `SVA_FATAL("ssc_resource_t2 can only assert for 1 cycle if ssc_rst_reg not set");

  usva_cmp_ssc_reach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
          ssc_state_t3 != CA53_ETM_SSC_UNUSED)
    `SVA_FATAL("Single Shot reached illegal state");

  usva_cmp_ssc_state1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
          ssc_state_t3 == CA53_ETM_SSC_IDLE |->
                                        ~ssc_status_t3 & ~ssc_resource_t3)
    `SVA_FATAL("Single Shot reached illegal state");
  usva_cmp_ssc_state2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
          ssc_state_t3 == CA53_ETM_SSC_ACTIVE &  ssc_resource_t3 |-> ssc_status_t3)
    `SVA_FATAL("Single Shot reached illegal state");
  usva_cmp_ssc_state3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
          ssc_state_t3 == CA53_ETM_SSC_DONE |->
                                        ssc_status_t3)
    `SVA_FATAL("Single Shot reached illegal state");
  usva_cmp_ssc_state_x: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        !$isunknown(ssc_state_t2))
    `SVA_FATAL("Resource SSC state logic reached X");
    
`endif
endmodule // ca53etm_cmp
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53_dpu_etm_defs.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

