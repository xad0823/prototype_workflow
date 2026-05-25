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

// External Input Selection Resource

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_extin (



//
// Interface Signals
// =================
//

// Global inputs
  input wire                         clk_gated,          // CPU clock

// Inputs
  input wire  [4:0]                  extin_sel_reg_i,    // Extended External Input Selection
  input wire  [3:0]                  cti_event_etm_t1_i, // External input to ETM
  input wire  [25:0]                 pm_event_bus_t1_i,  // Event bus from PMU

// Outputs
  output wire                        extin_rsrc_t2_o     // Extended External Input Resource

 );

  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire [`CA53_PMUEVNT_CPU_W+3:0] extin_rsrc;
  wire                           extin_rsrc_t1;
  reg                            extin_rsrc_t2;

//
// Main Code
// =========
//

// External Input
  assign extin_rsrc[ 0] = (extin_sel_reg_i[4:0] == 5'b00000) & cti_event_etm_t1_i[0];
  assign extin_rsrc[ 1] = (extin_sel_reg_i[4:0] == 5'b00001) & cti_event_etm_t1_i[1];
  assign extin_rsrc[ 2] = (extin_sel_reg_i[4:0] == 5'b00010) & cti_event_etm_t1_i[2];
  assign extin_rsrc[ 3] = (extin_sel_reg_i[4:0] == 5'b00011) & cti_event_etm_t1_i[3];

// PMU Events
  assign extin_rsrc[ 4] = (extin_sel_reg_i[4:0] == 5'b00100) & pm_event_bus_t1_i[ 0];
  assign extin_rsrc[ 5] = (extin_sel_reg_i[4:0] == 5'b00101) & pm_event_bus_t1_i[ 1];
  assign extin_rsrc[ 6] = (extin_sel_reg_i[4:0] == 5'b00110) & pm_event_bus_t1_i[ 2];
  assign extin_rsrc[ 7] = (extin_sel_reg_i[4:0] == 5'b00111) & pm_event_bus_t1_i[ 3];
  assign extin_rsrc[ 8] = (extin_sel_reg_i[4:0] == 5'b01000) & pm_event_bus_t1_i[ 4];
  assign extin_rsrc[ 9] = (extin_sel_reg_i[4:0] == 5'b01001) & pm_event_bus_t1_i[ 5];
  assign extin_rsrc[10] = (extin_sel_reg_i[4:0] == 5'b01010) & pm_event_bus_t1_i[ 6];
  assign extin_rsrc[11] = (extin_sel_reg_i[4:0] == 5'b01011) & pm_event_bus_t1_i[ 7];
  assign extin_rsrc[12] = (extin_sel_reg_i[4:0] == 5'b01100) & pm_event_bus_t1_i[ 8];
  assign extin_rsrc[13] = (extin_sel_reg_i[4:0] == 5'b01101) & pm_event_bus_t1_i[ 9];
  assign extin_rsrc[14] = (extin_sel_reg_i[4:0] == 5'b01110) & pm_event_bus_t1_i[10];
  assign extin_rsrc[15] = (extin_sel_reg_i[4:0] == 5'b01111) & pm_event_bus_t1_i[11];
  assign extin_rsrc[16] = (extin_sel_reg_i[4:0] == 5'b10000) & pm_event_bus_t1_i[12];
  assign extin_rsrc[17] = (extin_sel_reg_i[4:0] == 5'b10001) & pm_event_bus_t1_i[13];
  assign extin_rsrc[18] = (extin_sel_reg_i[4:0] == 5'b10010) & pm_event_bus_t1_i[14];
  assign extin_rsrc[19] = (extin_sel_reg_i[4:0] == 5'b10011) & pm_event_bus_t1_i[15];
  assign extin_rsrc[20] = (extin_sel_reg_i[4:0] == 5'b10100) & pm_event_bus_t1_i[16];
  assign extin_rsrc[21] = (extin_sel_reg_i[4:0] == 5'b10101) & pm_event_bus_t1_i[17];
  assign extin_rsrc[22] = (extin_sel_reg_i[4:0] == 5'b10110) & pm_event_bus_t1_i[18];
  assign extin_rsrc[23] = (extin_sel_reg_i[4:0] == 5'b10111) & pm_event_bus_t1_i[19];
  assign extin_rsrc[24] = (extin_sel_reg_i[4:0] == 5'b11000) & pm_event_bus_t1_i[20];
  assign extin_rsrc[25] = (extin_sel_reg_i[4:0] == 5'b11001) & pm_event_bus_t1_i[21];
  assign extin_rsrc[26] = (extin_sel_reg_i[4:0] == 5'b11010) & pm_event_bus_t1_i[22];
  assign extin_rsrc[27] = (extin_sel_reg_i[4:0] == 5'b11011) & pm_event_bus_t1_i[23];
  assign extin_rsrc[28] = (extin_sel_reg_i[4:0] == 5'b11100) & pm_event_bus_t1_i[24];
  assign extin_rsrc[29] = (extin_sel_reg_i[4:0] == 5'b11101) & pm_event_bus_t1_i[25];

  assign extin_rsrc_t1 = (|extin_rsrc);

  always @(posedge clk_gated)
    begin: uextin_rsrc_t2
      extin_rsrc_t2 <= extin_rsrc_t1;
    end

  assign extin_rsrc_t2_o = extin_rsrc_t2;

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

