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

// -----------------------------
// Overview
// -----------------------------
//
// External Output Resource Block


`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_extout (



// -----------------------------
// Interface signals
// -----------------------------

// Global inputs
  input wire                  clk_gated,               // CPU clock
  input wire                  po_reset_n,                 // Debug trace reset

// Inputs
  input wire  [22:2]          evt_resources_t2_i,      // Resources Bus
  input wire  [4:0]           extout_event_reg_i,      // Extout Event Register
  input wire                  extout_enabled_t2_i,     // Extout Event enable

// Outputs
  output wire                 extout_o                 // Extout value

 );
  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           ext_out;
  wire           ext_out_en;
  reg            ext_out_q;
  wire           extout_event;

  // -----------------------------
  // Main Code
  // -----------------------------


// External Output
// Generation based on Event Control Register
// Drives EXTOUT at interface level
// Also a packet is inserted in trace stream.


// Event
  ca53etm_event u_extout_event(
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (extout_event_reg_i[4]),
    .event_sel_i        (extout_event_reg_i[3:0]),

    .event_out_o        (extout_event)
  );

// In integration mode, use the value from write data.
  assign ext_out    = extout_event & extout_enabled_t2_i;

  assign ext_out_en = ext_out | ext_out_q;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uext_out_q
    if (!po_reset_n)
      ext_out_q <= 1'b0;
    else if (ext_out_en)
      ext_out_q <= ext_out;
  end


  assign extout_o = ext_out_q;


endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

