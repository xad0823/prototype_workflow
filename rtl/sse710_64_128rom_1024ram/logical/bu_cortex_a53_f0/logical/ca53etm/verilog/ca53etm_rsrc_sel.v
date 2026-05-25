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

// ETM resource selection
// This block does the following operations:
// 1) Generates an event from single resource selector
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_rsrc_sel (



//
// Interface Signals
// =================
//

// Inputs
  input wire  [24:0]  resources_i,             // Resource bus
  input wire  [7:0]   select_reg_i,            // Resource select
  input wire  [2:0]   group_reg_i,             // Resource group
  input wire          invert_i,                // Resource invert_i

// Outputs
  output wire         rsrc_sel_o               // Resulting selected resource

 );

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire [ 24: 0] grp_sel;

//
// Main Code
// =========
//

  assign grp_sel[ 0] = (group_reg_i[2:0] == 3'b000) & select_reg_i[0]; // EXTIN 0
  assign grp_sel[ 1] = (group_reg_i[2:0] == 3'b000) & select_reg_i[1]; // EXTIN 1
  assign grp_sel[ 2] = (group_reg_i[2:0] == 3'b000) & select_reg_i[2]; // EXTIN 2
  assign grp_sel[ 3] = (group_reg_i[2:0] == 3'b000) & select_reg_i[3]; // EXTIN 3

  assign grp_sel[ 4] = (group_reg_i[2:0] == 3'b010) & select_reg_i[0]; // Counter 0 Zero
  assign grp_sel[ 5] = (group_reg_i[2:0] == 3'b010) & select_reg_i[1]; // Counter 1 Zero

  assign grp_sel[ 6] = (group_reg_i[2:0] == 3'b010) & select_reg_i[4]; // Sequencer State 0
  assign grp_sel[ 7] = (group_reg_i[2:0] == 3'b010) & select_reg_i[5]; // Sequencer State 1
  assign grp_sel[ 8] = (group_reg_i[2:0] == 3'b010) & select_reg_i[6]; // Sequencer State 2
  assign grp_sel[ 9] = (group_reg_i[2:0] == 3'b010) & select_reg_i[7]; // Sequencer State 3

  assign grp_sel[10] = (group_reg_i[2:0] == 3'b011) & select_reg_i[0]; // Single Shot Comparator Control 0

  assign grp_sel[11] = (group_reg_i[2:0] == 3'b100) & select_reg_i[0]; // Single Address Comparator 0
  assign grp_sel[12] = (group_reg_i[2:0] == 3'b100) & select_reg_i[1]; // Single Address Comparator 1
  assign grp_sel[13] = (group_reg_i[2:0] == 3'b100) & select_reg_i[2]; // Single Address Comparator 2
  assign grp_sel[14] = (group_reg_i[2:0] == 3'b100) & select_reg_i[3]; // Single Address Comparator 3
  assign grp_sel[15] = (group_reg_i[2:0] == 3'b100) & select_reg_i[4]; // Single Address Comparator 4
  assign grp_sel[16] = (group_reg_i[2:0] == 3'b100) & select_reg_i[5]; // Single Address Comparator 5
  assign grp_sel[17] = (group_reg_i[2:0] == 3'b100) & select_reg_i[6]; // Single Address Comparator 6
  assign grp_sel[18] = (group_reg_i[2:0] == 3'b100) & select_reg_i[7]; // Single Address Comparator 7

  assign grp_sel[19] = (group_reg_i[2:0] == 3'b101) & select_reg_i[0]; // Address Range Comparator 0
  assign grp_sel[20] = (group_reg_i[2:0] == 3'b101) & select_reg_i[1]; // Address Range Comparator 1
  assign grp_sel[21] = (group_reg_i[2:0] == 3'b101) & select_reg_i[2]; // Address Range Comparator 2
  assign grp_sel[22] = (group_reg_i[2:0] == 3'b101) & select_reg_i[3]; // Address Range Comparator 3

  assign grp_sel[23] = (group_reg_i[2:0] == 3'b110) & select_reg_i[0]; // Context ID Comparator 0

  assign grp_sel[24] = (group_reg_i[2:0] == 3'b111) & select_reg_i[0]; // Virtual Machine ID Comparator 0

  assign rsrc_sel_o = (|(resources_i[24:0] & grp_sel[24:0])) ^ invert_i;


endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

