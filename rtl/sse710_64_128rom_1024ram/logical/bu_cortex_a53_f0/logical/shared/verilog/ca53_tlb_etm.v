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

// This is the specification for the interface between the TLB
// and the etm.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_tlb_etm_defs.v"
`include "cortexa53params.v"

module ca53_tlb_etm #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         po_reset_n,
  input  [31:0] tlb_context_id_i,
  input   [7:0] tlb_vmid_i);


  wire  [31:0] tlb_context_id = tlb_context_id_i;
  wire   [7:0] tlb_vmid = tlb_vmid_i;





  // The context ID for the current security state.
  //  output [31:0]  tlb_context_id valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "tlb_context_id X or Z")
  u_ovl_intf_x_tlb_context_id (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_context_id));

  // The current VMID in the TLB.
  //  output [7:0] tlb_vmid valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "tlb_vmid X or Z")
  u_ovl_intf_x_tlb_vmid (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_vmid));




endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_etm_defs.v"
`undef CA53_UNDEFINE

`endif

