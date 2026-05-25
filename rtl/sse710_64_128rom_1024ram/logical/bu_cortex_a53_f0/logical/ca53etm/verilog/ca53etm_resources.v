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
// 1) Assemble  Resources
// 2) Generate Trace resources for event generation
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_resources (



//
// Interface Signals
// =================
//

// Inputs
  input wire           clk_gated,                           // Clock
  input wire           po_reset_n,                             // Reset
  input wire           resource_active_t2_i,                // Resource control
  input wire   [3:0]   extin_rsrc_t2_i,                     // External input selector
  input wire           counter0_zero_t3_i,                  // Counter 0 at zero
  input wire           counter1_zero_t3_i,                  // Counter 1 at zero
  input wire   [3:0]   seq_resource_t2_i,                   // Sequencer state
  input wire           ssc_resource_t2_i,                   // Single Shot Comparator Control 0
  input wire           comp0_match_t2_i,                    // Single Address Comparator 0
  input wire           comp1_match_t2_i,                    // Single Address Comparator 1
  input wire           comp2_match_t2_i,                    // Single Address Comparator 2
  input wire           comp3_match_t2_i,                    // Single Address Comparator 3
  input wire           comp4_match_t2_i,                    // Single Address Comparator 4
  input wire           comp5_match_t2_i,                    // Single Address Comparator 5
  input wire           comp6_match_t2_i,                    // Single Address Comparator 6
  input wire           comp7_match_t2_i,                    // Single Address Comparator 7
  input wire           range0_match_t2_i,                   // Address Range Comparator 0
  input wire           range1_match_t2_i,                   // Address Range Comparator 1
  input wire           range2_match_t2_i,                   // Address Range Comparator 2
  input wire           range3_match_t2_i,                   // Address Range Comparator 3
  input wire           cid_match_t2_i,                      // Context ID Comparator
  input wire           vmid_match_t2_i,                     // VMID Comparator

  input wire   [7:0]   trcrsctlr2_select_reg_i,             // Resource Selection Control Register 2 Select
  input wire   [2:0]   trcrsctlr2_group_reg_i,              // Resource Selection Control Register 2 Group
  input wire           trcrsctlr2_inv_reg_i,                // Resource Selection Control Register 2 Invert
  input wire           trcrsctlr2_pairinv_reg_i,            // Resource Selection Control Register 2 Pair Invert
  input wire   [7:0]   trcrsctlr3_select_reg_i,             // Resource Selection Control Register 3 Select
  input wire   [2:0]   trcrsctlr3_group_reg_i,              // Resource Selection Control Register 3 Group
  input wire           trcrsctlr3_inv_reg_i,                // Resource Selection Control Register 3 Invert

  input wire   [7:0]   trcrsctlr4_select_reg_i,             // Resource Selection Control Register 4 Select
  input wire   [2:0]   trcrsctlr4_group_reg_i,              // Resource Selection Control Register 4 Group
  input wire           trcrsctlr4_inv_reg_i,                // Resource Selection Control Register 4 Invert
  input wire           trcrsctlr4_pairinv_reg_i,            // Resource Selection Control Register 4 Pair Invert
  input wire   [7:0]   trcrsctlr5_select_reg_i,             // Resource Selection Control Register 5 Select
  input wire   [2:0]   trcrsctlr5_group_reg_i,              // Resource Selection Control Register 5 Group
  input wire           trcrsctlr5_inv_reg_i,                // Resource Selection Control Register 5 Invert

  input wire   [7:0]   trcrsctlr6_select_reg_i,             // Resource Selection Control Register 6 Select
  input wire   [2:0]   trcrsctlr6_group_reg_i,              // Resource Selection Control Register 6 Group
  input wire           trcrsctlr6_inv_reg_i,                // Resource Selection Control Register 6 Invert
  input wire           trcrsctlr6_pairinv_reg_i,            // Resource Selection Control Register 6 Pair Invert
  input wire   [7:0]   trcrsctlr7_select_reg_i,             // Resource Selection Control Register 7 Select
  input wire   [2:0]   trcrsctlr7_group_reg_i,              // Resource Selection Control Register 7 Group
  input wire           trcrsctlr7_inv_reg_i,                // Resource Selection Control Register 7 Invert

  input wire   [7:0]   trcrsctlr8_select_reg_i,             // Resource Selection Control Register 8 Select
  input wire   [2:0]   trcrsctlr8_group_reg_i,              // Resource Selection Control Register 8 Group
  input wire           trcrsctlr8_inv_reg_i,                // Resource Selection Control Register 8 Invert
  input wire           trcrsctlr8_pairinv_reg_i,            // Resource Selection Control Register 8 Pair Invert
  input wire   [7:0]   trcrsctlr9_select_reg_i,             // Resource Selection Control Register 9 Select
  input wire   [2:0]   trcrsctlr9_group_reg_i,              // Resource Selection Control Register 9 Group
  input wire           trcrsctlr9_inv_reg_i,                // Resource Selection Control Register 9 Invert

  input wire   [7:0]   trcrsctlr10_select_reg_i,            // Resource Selection Control Register 10 Select
  input wire   [2:0]   trcrsctlr10_group_reg_i,             // Resource Selection Control Register 10 Group
  input wire           trcrsctlr10_inv_reg_i,               // Resource Selection Control Register 10 Invert
  input wire           trcrsctlr10_pairinv_reg_i,           // Resource Selection Control Register 10 Pair Invert
  input wire   [7:0]   trcrsctlr11_select_reg_i,            // Resource Selection Control Register 11 Select
  input wire   [2:0]   trcrsctlr11_group_reg_i,             // Resource Selection Control Register 11 Group
  input wire           trcrsctlr11_inv_reg_i,               // Resource Selection Control Register 11 Invert

  input wire   [7:0]   trcrsctlr12_select_reg_i,            // Resource Selection Control Register 12 Select
  input wire   [2:0]   trcrsctlr12_group_reg_i,             // Resource Selection Control Register 12 Group
  input wire           trcrsctlr12_inv_reg_i,               // Resource Selection Control Register 12 Invert
  input wire           trcrsctlr12_pairinv_reg_i,           // Resource Selection Control Register 12 Pair Invert
  input wire   [7:0]   trcrsctlr13_select_reg_i,            // Resource Selection Control Register 13 Select
  input wire   [2:0]   trcrsctlr13_group_reg_i,             // Resource Selection Control Register 13 Group
  input wire           trcrsctlr13_inv_reg_i,               // Resource Selection Control Register 13 Invert

  input wire   [7:0]   trcrsctlr14_select_reg_i,            // Resource Selection Control Register 14 Select
  input wire   [2:0]   trcrsctlr14_group_reg_i,             // Resource Selection Control Register 14 Group
  input wire           trcrsctlr14_inv_reg_i,               // Resource Selection Control Register 14 Invert
  input wire           trcrsctlr14_pairinv_reg_i,           // Resource Selection Control Register 14 Pair Invert
  input wire   [7:0]   trcrsctlr15_select_reg_i,            // Resource Selection Control Register 15 Select
  input wire   [2:0]   trcrsctlr15_group_reg_i,             // Resource Selection Control Register 15 Group
  input wire           trcrsctlr15_inv_reg_i,               // Resource Selection Control Register 15 Invert

// Outputs
  output wire          resource_active_t3_o,                // Resource active
  output wire          resource_active_t4_o,                // Resource active
  output wire          resource_active_t5_o,                // Resource active
  output wire  [22:2]  evt_resources_t2_o                   // Event Resources

 );

  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           pair_rsrc_sel1;
  wire           pair_rsrc_sel2;
  wire           pair_rsrc_sel3;
  wire           pair_rsrc_sel4;
  wire           pair_rsrc_sel5;
  wire           pair_rsrc_sel6;
  wire           pair_rsrc_sel7;
  wire [ 24: 00] resources_t2;
  wire           rsrc_sel10;
  wire           rsrc_sel11;
  wire           rsrc_sel12;
  wire           rsrc_sel13;
  wire           rsrc_sel14;
  wire           rsrc_sel15;
  wire           rsrc_sel2;
  wire           rsrc_sel3;
  wire           rsrc_sel4;
  wire           rsrc_sel5;
  wire           rsrc_sel6;
  wire           rsrc_sel7;
  wire           rsrc_sel8;
  wire           rsrc_sel9;
  reg [22:2]     evt_resources_t2;
  reg            resource_active_t3;
  reg            resource_active_t4;
  reg            resource_active_t5;


//
// Main Code
// =========
//

//----------------------------------------------------------------------------
// Resource active control
//----------------------------------------------------------------------------

// Resources need to be disabled when trace is disabled.
// Use pipelined version of this signal to disable resources in corresponding cycles.
// Counter and Sequencer go through one more iteration after trace is disabled.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uresource_active
    if (!po_reset_n) begin
      resource_active_t3 <= 1'b0;
      resource_active_t4 <= 1'b0;
      resource_active_t5 <= 1'b0;
    end
    else begin
      resource_active_t3 <= resource_active_t2_i;
      resource_active_t4 <= resource_active_t3;
      resource_active_t5 <= resource_active_t4;
    end
  end

  assign resource_active_t3_o = resource_active_t3;
  assign resource_active_t4_o = resource_active_t4;
  assign resource_active_t5_o = resource_active_t5;
//----------------------------------------------------------------------------
// Generate a resource bus for resource selection
//----------------------------------------------------------------------------
  assign resources_t2[00] = extin_rsrc_t2_i[0];
  assign resources_t2[01] = extin_rsrc_t2_i[1];
  assign resources_t2[02] = extin_rsrc_t2_i[2];
  assign resources_t2[03] = extin_rsrc_t2_i[3];

  assign resources_t2[04] = counter0_zero_t3_i;
  assign resources_t2[05] = counter1_zero_t3_i;

  assign resources_t2[06] = seq_resource_t2_i[0];
  assign resources_t2[07] = seq_resource_t2_i[1];
  assign resources_t2[08] = seq_resource_t2_i[2];
  assign resources_t2[09] = seq_resource_t2_i[3];

  assign resources_t2[10] = ssc_resource_t2_i;

  assign resources_t2[11] = comp0_match_t2_i;
  assign resources_t2[12] = comp1_match_t2_i;
  assign resources_t2[13] = comp2_match_t2_i;
  assign resources_t2[14] = comp3_match_t2_i;
  assign resources_t2[15] = comp4_match_t2_i;
  assign resources_t2[16] = comp5_match_t2_i;
  assign resources_t2[17] = comp6_match_t2_i;
  assign resources_t2[18] = comp7_match_t2_i;

  assign resources_t2[19] = range0_match_t2_i;
  assign resources_t2[20] = range1_match_t2_i;
  assign resources_t2[21] = range2_match_t2_i;
  assign resources_t2[22] = range3_match_t2_i;

  assign resources_t2[23] = cid_match_t2_i;

  assign resources_t2[24] = vmid_match_t2_i;

//----------------------------------------------------------------------------
// Resource Selection pairs
//----------------------------------------------------------------------------
// Resource selection pair0 is reserved
// Resource selection single resource 0 is always false
// Resource selection single resource 1 is always true

// Instantiate trace resource selection pair1 i.e single resource 2 and 3
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair1 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr2_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr2_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr2_inv_reg_i),

    .hi_select_i         (trcrsctlr3_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr3_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr3_inv_reg_i),

    .pair_invert_i       (trcrsctlr2_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel1),
    .lo_rsrc_sel_o       (rsrc_sel2),
    .hi_rsrc_sel_o       (rsrc_sel3)
  );

// Instantiate trace resource selection pair2 i.e single resource 4 and 5
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair2 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr4_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr4_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr4_inv_reg_i),

    .hi_select_i         (trcrsctlr5_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr5_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr5_inv_reg_i),

    .pair_invert_i       (trcrsctlr4_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel2),
    .lo_rsrc_sel_o       (rsrc_sel4),
    .hi_rsrc_sel_o       (rsrc_sel5)
  );

// Instantiate trace resource selection pair3 i.e single resource 6 and 7
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair3 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr6_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr6_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr6_inv_reg_i),

    .hi_select_i         (trcrsctlr7_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr7_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr7_inv_reg_i),

    .pair_invert_i       (trcrsctlr6_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel3),
    .lo_rsrc_sel_o       (rsrc_sel6),
    .hi_rsrc_sel_o       (rsrc_sel7)
  );

// Instantiate trace resource selection pair4 i.e single resource 8 and 9
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair4 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr8_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr8_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr8_inv_reg_i),

    .hi_select_i         (trcrsctlr9_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr9_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr9_inv_reg_i),

    .pair_invert_i       (trcrsctlr8_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel4),
    .lo_rsrc_sel_o       (rsrc_sel8),
    .hi_rsrc_sel_o       (rsrc_sel9)
  );

// Instantiate trace resource selection pair5 i.e single resource 10 and 11
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair5 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr10_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr10_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr10_inv_reg_i),

    .hi_select_i         (trcrsctlr11_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr11_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr11_inv_reg_i),

    .pair_invert_i       (trcrsctlr10_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel5),
    .lo_rsrc_sel_o       (rsrc_sel10),
    .hi_rsrc_sel_o       (rsrc_sel11)
  );

// Instantiate trace resource selection pair6 i.e single resource 12 and 13
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair6 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr12_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr12_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr12_inv_reg_i),

    .hi_select_i         (trcrsctlr13_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr13_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr13_inv_reg_i),

    .pair_invert_i       (trcrsctlr12_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel6),
    .lo_rsrc_sel_o       (rsrc_sel12),
    .hi_rsrc_sel_o       (rsrc_sel13)
  );

// Instantiate trace resource selection pair7 i.e single resource 14 and 15
  ca53etm_rsrc_sel_pair u_rsrc_sel_pair7 (
    .resources_i         (resources_t2[24:0]),
    .lo_select_i         (trcrsctlr14_select_reg_i[7:0]),
    .lo_group_i          (trcrsctlr14_group_reg_i[2:0]),
    .lo_invert_i         (trcrsctlr14_inv_reg_i),

    .hi_select_i         (trcrsctlr15_select_reg_i[7:0]),
    .hi_group_i          (trcrsctlr15_group_reg_i[2:0]),
    .hi_invert_i         (trcrsctlr15_inv_reg_i),

    .pair_invert_i       (trcrsctlr14_pairinv_reg_i),

    .pair_rsrc_sel_o     (pair_rsrc_sel7),
    .lo_rsrc_sel_o       (rsrc_sel14),
    .hi_rsrc_sel_o       (rsrc_sel15)
  );

//----------------------------------------------------------------------------
// Resource Selection pairs
//----------------------------------------------------------------------------
  always @(posedge clk_gated)
  begin: uresource_bus
    evt_resources_t2[22:2] <= {pair_rsrc_sel7,
                               pair_rsrc_sel6,
                               pair_rsrc_sel5,
                               pair_rsrc_sel4,
                               pair_rsrc_sel3,
                               pair_rsrc_sel2,
                               pair_rsrc_sel1,
                               rsrc_sel15,
                               rsrc_sel14,
                               rsrc_sel13,
                               rsrc_sel12,
                               rsrc_sel11,
                               rsrc_sel10,
                               rsrc_sel9,
                               rsrc_sel8,
                               rsrc_sel7,
                               rsrc_sel6,
                               rsrc_sel5,
                               rsrc_sel4,
                               rsrc_sel3,
                               rsrc_sel2};
    end

  assign evt_resources_t2_o[22:2] = evt_resources_t2[22:2];


endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

