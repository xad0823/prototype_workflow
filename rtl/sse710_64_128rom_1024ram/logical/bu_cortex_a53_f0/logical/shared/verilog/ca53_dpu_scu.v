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
// and the SCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_scu_defs.v"
`include "cortexa53params.v"

module ca53_dpu_scu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         scu_evnt_l2_access_i,
  input         scu_evnt_l2_refill_i,
  input         scu_evnt_l2_wb_i,
  input         scu_evnt_snooped_data_i,
  input         scu_evnt_bus_cycle_i,
  input         scu_evnt_bus_acc_rd_i,
  input         scu_evnt_bus_acc_wr_i,
  input         scu_evnt_eviction_i);


  wire         scu_evnt_l2_access = scu_evnt_l2_access_i;
  wire         scu_evnt_l2_refill = scu_evnt_l2_refill_i;
  wire         scu_evnt_l2_wb = scu_evnt_l2_wb_i;
  wire         scu_evnt_snooped_data = scu_evnt_snooped_data_i;
  wire         scu_evnt_bus_cycle = scu_evnt_bus_cycle_i;
  wire         scu_evnt_bus_acc_rd = scu_evnt_bus_acc_rd_i;
  wire         scu_evnt_bus_acc_wr = scu_evnt_bus_acc_wr_i;
  wire         scu_evnt_eviction = scu_evnt_eviction_i;





  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // SCU performance monitor events
  //  input          scu_evnt_l2_access     valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_l2_access X or Z")
  u_ovl_intf_x_scu_evnt_l2_access (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_l2_access));

  //  input          scu_evnt_l2_refill     valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_l2_refill X or Z")
  u_ovl_intf_x_scu_evnt_l2_refill (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_l2_refill));

  //  input          scu_evnt_l2_wb         valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_l2_wb X or Z")
  u_ovl_intf_x_scu_evnt_l2_wb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_l2_wb));

  //  input          scu_evnt_snooped_data  valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_snooped_data X or Z")
  u_ovl_intf_x_scu_evnt_snooped_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_snooped_data));

  //  input          scu_evnt_bus_cycle     valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_bus_cycle X or Z")
  u_ovl_intf_x_scu_evnt_bus_cycle (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_bus_cycle));

  //  input          scu_evnt_bus_acc_rd    valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_bus_acc_rd X or Z")
  u_ovl_intf_x_scu_evnt_bus_acc_rd (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_bus_acc_rd));

  //  input          scu_evnt_bus_acc_wr    valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_bus_acc_wr X or Z")
  u_ovl_intf_x_scu_evnt_bus_acc_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_bus_acc_wr));

  //  input          scu_evnt_eviction      valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_evnt_eviction X or Z")
  u_ovl_intf_x_scu_evnt_eviction (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_evnt_eviction));


  // ------------------------------------------------------
  // Interface description
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_scu_defs.v"
`undef CA53_UNDEFINE

`endif

