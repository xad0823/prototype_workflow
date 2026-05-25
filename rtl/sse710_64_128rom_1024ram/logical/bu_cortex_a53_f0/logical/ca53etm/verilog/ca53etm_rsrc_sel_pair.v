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

// ETM Resource selection pair
// This block does the following operations:
// 1) Generates single resource selector
// 2) Generates pair resource selector

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_rsrc_sel_pair (



//
// Interface Signals
// =================
//

// Inputs
  input wire  [24:0]  resources_i,             // Resource bus

  input wire  [7:0]   lo_select_i,             // Resource select for low
  input wire  [2:0]   lo_group_i,              // Resource group for low
  input wire          lo_invert_i,             // Resource invert for low

  input wire  [7:0]   hi_select_i,             // Resource select for high
  input wire  [2:0]   hi_group_i,              // Resource group for high
  input wire          hi_invert_i,             // Resource invert for high

  input wire          pair_invert_i,           // Resource pair invertor

// Outputs
  output wire         pair_rsrc_sel_o,         // Resulting selected resource pair
  output wire         lo_rsrc_sel_o,           // Resource selected from low
  output wire         hi_rsrc_sel_o            // Resource selected from high

 );
//
//
// Main Code
// =========
//
  wire               lo_rsrc_sel;
  wire               hi_rsrc_sel;

// Instantiate resource selection for low
  ca53etm_rsrc_sel u_rsrc_sel_lo (
    .resources_i    (resources_i[24:0]),
    .select_reg_i   (lo_select_i[7:0]),
    .group_reg_i    (lo_group_i[2:0]),
    .invert_i       (lo_invert_i),

    .rsrc_sel_o     (lo_rsrc_sel)
  );

// Instantiate resource selection for high
  ca53etm_rsrc_sel u_rsrc_sel_hi (
    .resources_i    (resources_i[24:0]),
    .select_reg_i   (hi_select_i[7:0]),
    .group_reg_i    (hi_group_i[2:0]),
    .invert_i       (hi_invert_i),

    .rsrc_sel_o     (hi_rsrc_sel)
  );


  assign lo_rsrc_sel_o   = lo_rsrc_sel;
  assign hi_rsrc_sel_o   = hi_rsrc_sel;
  assign pair_rsrc_sel_o = (lo_rsrc_sel & hi_rsrc_sel) ^ pair_invert_i;


endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

