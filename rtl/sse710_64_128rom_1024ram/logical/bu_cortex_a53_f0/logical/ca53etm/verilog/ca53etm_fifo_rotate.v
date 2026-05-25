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
// 1) Rotate the FIFO data input to the FIFO so that it can
// be written into the next empty space.
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_fifo_rotate (



  // -----------------------------
  // Interface Signals
  // -----------------------------

  // Inputs
  input wire  [4:0]       rotation_i,        // Rotation Value
  input wire  [203:0]     pack_fifo_in_t6_i, // Rotation Input Data

  // Outputs
  output wire  [223:0]    fifo_data_in_t6_o  // Rotated Data

 );
 
  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire [223:  0] full_rot_in;
  wire [223:  0] rotate1;
  wire [223:  0] rotate16;
  wire [223:  0] rotate2;
  wire [223:  0] rotate4;
  wire [223:  0] rotate8;

  // -----------------------------
  // Main Code
  // -----------------------------
  assign full_rot_in[223:221] = {3{1'b0}};
  assign full_rot_in[220: 20] = pack_fifo_in_t6_i[203: 3];
  assign full_rot_in[     19] = 1'b0;
  assign full_rot_in[ 18: 16] = pack_fifo_in_t6_i[2  : 0];
  assign full_rot_in[ 15:  0] = {16{1'b0}};

  assign rotate1[223:0] = rotation_i[0] ? {full_rot_in[215:0], full_rot_in[223:216]} :
                                           full_rot_in[223:0];

  assign rotate2[223:0] = rotation_i[1] ? {rotate1[207:0], rotate1[223:208]} :
                                           rotate1[223:0];

  assign rotate4[223:0] = rotation_i[2] ? {rotate2[191:0], rotate2[223:192]} :
                                           rotate2[223:0];

  assign rotate8[223:0] = rotation_i[3] ? {rotate4[159:0], rotate4[223:160]} :
                                           rotate4[223:0];

  assign rotate16[223:0]= rotation_i[4] ? {rotate8[95:0], rotate8[223:96]} :
                                           rotate8[223:0];

  assign fifo_data_in_t6_o[223:0]= rotate16[223:0];



endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

