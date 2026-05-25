//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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

// This is the specification for the interface between the DPU
// and the RAMS.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_l2rams_defs.v"
`include "cortexa53params.v"

module ca53_dpu_l2rams #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [3:0] l2_size_i);


  wire   [3:0] l2_size = l2_size_i;





  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Inputs to the DPU from the SCU
  //  input    [3:0] l2_size           valid always timing 10%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "l2_size X or Z")
  u_ovl_intf_x_l2_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2_size));



  // ------------------------------------------------------
  // Interface description
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_l2rams_defs.v"
`undef CA53_UNDEFINE

`endif

