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

// Instantiate 2 resource select muxes and combine the outputs
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_event (



//
// Interface Signals
// =================
//

// Inputs
  input wire  [22:2]  evt_resources_t2_i,       // Resource Selection Bus
  input wire          event_type_i,             // Resource Type from event register
  input wire  [3:0]   event_sel_i,              // Resource Select from event register

// Outputs
  output wire         event_out_o               // Resulting generated event

 );

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire           event_pair;
  wire           event_single;

//
// Main Code
// =========
//

  // Single selected resource
  assign event_single =                                   // Select 0 is always 0
                        ((event_sel_i[3:0] == 4'b0001)) | // Select 1 is always 1
                        ((event_sel_i[3:0] == 4'b0010) & evt_resources_t2_i[2]) |
                        ((event_sel_i[3:0] == 4'b0011) & evt_resources_t2_i[3]) |
                        ((event_sel_i[3:0] == 4'b0100) & evt_resources_t2_i[4]) |
                        ((event_sel_i[3:0] == 4'b0101) & evt_resources_t2_i[5]) |
                        ((event_sel_i[3:0] == 4'b0110) & evt_resources_t2_i[6]) |
                        ((event_sel_i[3:0] == 4'b0111) & evt_resources_t2_i[7]) |
                        ((event_sel_i[3:0] == 4'b1000) & evt_resources_t2_i[8]) |
                        ((event_sel_i[3:0] == 4'b1001) & evt_resources_t2_i[9]) |
                        ((event_sel_i[3:0] == 4'b1010) & evt_resources_t2_i[10]) |
                        ((event_sel_i[3:0] == 4'b1011) & evt_resources_t2_i[11]) |
                        ((event_sel_i[3:0] == 4'b1100) & evt_resources_t2_i[12]) |
                        ((event_sel_i[3:0] == 4'b1101) & evt_resources_t2_i[13]) |
                        ((event_sel_i[3:0] == 4'b1110) & evt_resources_t2_i[14]) |
                        ((event_sel_i[3:0] == 4'b1111) & evt_resources_t2_i[15]);

  // Combined selected resource
  assign event_pair = ((event_sel_i[2:0] == 3'b001) & evt_resources_t2_i[16]) |
                      ((event_sel_i[2:0] == 3'b010) & evt_resources_t2_i[17]) |
                      ((event_sel_i[2:0] == 3'b011) & evt_resources_t2_i[18]) |
                      ((event_sel_i[2:0] == 3'b100) & evt_resources_t2_i[19]) |
                      ((event_sel_i[2:0] == 3'b101) & evt_resources_t2_i[20]) |
                      ((event_sel_i[2:0] == 3'b110) & evt_resources_t2_i[21]) |
                      ((event_sel_i[2:0] == 3'b111) & evt_resources_t2_i[22]);

  assign event_out_o = event_type_i ? event_pair : event_single;


endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

