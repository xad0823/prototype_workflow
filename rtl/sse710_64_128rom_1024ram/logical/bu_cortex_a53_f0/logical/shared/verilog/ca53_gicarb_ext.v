//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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

// This is the specification for the interface between the GIC Arbiter and the
// top level.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gicarb_ext_defs.v"
`include "cortexa53params.v"

module ca53_gicarb_ext #(parameter NUM_CPUS = 4, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         icctready_i,
  input [(`CA53_TDATA_W-1):0] icdtdata_i,
  input   [1:0] icdtdest_i,
  input         icdtlast_i,
  input         icdtvalid_i,
  input         gov_giccdisable_i,
  input [(`CA53_TDATA_W-1):0] icctdata_i,
  input         icctlast_i,
  input   [1:0] icctid_i,
  input         icctvalid_i,
  input         icdtready_i);


  wire         icctready = icctready_i;
  wire [(`CA53_TDATA_W-1):0] icdtdata = icdtdata_i;
  wire   [1:0] icdtdest = icdtdest_i;
  wire         icdtlast = icdtlast_i;
  wire         icdtvalid = icdtvalid_i;
  wire         gov_giccdisable = gov_giccdisable_i;
  wire [(`CA53_TDATA_W-1):0] icctdata = icctdata_i;
  wire         icctlast = icctlast_i;
  wire   [1:0] icctid = icctid_i;
  wire         icctvalid = icctvalid_i;
  wire         icdtready = icdtready_i;

  wire   [1:0] max_cpu_present;





  // ------------------------------------------------------
  // Interface signals : Cluster to Distributor (AMBA 4 AXI4-Stream)
  // ------------------------------------------------------

  // TDATA
  //  output [(`CA53_TDATA_W-1):0] icctdata valid icctvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_TDATA_W-1)) - (0) + 1), OUTOPTIONS, "icctdata X or Z")
  u_ovl_intf_x_icctdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icctvalid),
    .test_expr (icctdata));


  // TVALID
  //  output icctlast valid icctvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "icctlast X or Z")
  u_ovl_intf_x_icctlast (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icctvalid),
    .test_expr (icctlast));


  // TID
  //  TDID  | Source
  //  -----------------------
  //  2'b00 | CPU Interface 0
  //  2'b01 | CPU Interface 1
  //  2'b10 | CPU Interface 2
  //  2'b11 | CPU Interface 3
  //  output [1:0] icctid valid icctvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "icctid X or Z")
  u_ovl_intf_x_icctid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icctvalid),
    .test_expr (icctid));


  // TREADY
  //  input icctready valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "icctready X or Z")
  u_ovl_intf_x_icctready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icctready));


  // TVALID
  //  output icctvalid valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "icctvalid X or Z")
  u_ovl_intf_x_icctvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icctvalid));



  // ------------------------------------------------------
  // Interface signals : Distributor to Cluster ( AMBA 4 AXI4-Stream)
  // ------------------------------------------------------

  // TDATA
  //  input [(`CA53_TDATA_W-1):0] icdtdata valid icdtvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_TDATA_W-1)) - (0) + 1), INOPTIONS, "icdtdata X or Z")
  u_ovl_intf_x_icdtdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icdtvalid),
    .test_expr (icdtdata));


  // TDEST
  //  TTDEST  | Destination
  //  -------------------------
  //  2'b00   | CPU Interface 0
  //  2'b01   | CPU Interface 1
  //  2'b10   | CPU Interface 2
  //  2'b11   | CPU Interface 3
  //  input [1:0] icdtdest valid icdtvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "icdtdest X or Z")
  u_ovl_intf_x_icdtdest (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icdtvalid),
    .test_expr (icdtdest));


  // TVALID
  //  input icdtlast valid icdtvalid timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "icdtlast X or Z")
  u_ovl_intf_x_icdtlast (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icdtvalid),
    .test_expr (icdtlast));


  // TREADY
  //  output icdtready valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "icdtready X or Z")
  u_ovl_intf_x_icdtready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icdtready));


  // TVALID
  //  input icdtvalid valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "icdtvalid X or Z")
  u_ovl_intf_x_icdtvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icdtvalid));



  // ------------------------------------------------------
  // Interface description (AXI4-Stream bus from CPU Interface to Distributor)
  // ------------------------------------------------------

  // Packet IDs

  // Transfers per packet



  // ------------------------------------------------------
  // Interface description (AXI4-Stream bus from Distributor to CPU Interface)
  // ------------------------------------------------------

  // packet IDs

  // Transfers per packet



  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Hardware Disable
  // ------------------------------------------------------


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_giccdisable  => ~icctvalid")
  u_ovl_intf_assert_bf67d0a6b4d81f5b6dcb2a0a91b2d99f2d5fe52d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~icctvalid));



  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~icdtvalid")
  u_ovl_intf_assume_b7c7d014b48a268abda58f3c9be773379b64a954 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~icdtvalid));



  // ------------------------------------------------------
  // GIC CPU Interface Addressing
  // ------------------------------------------------------

  assign max_cpu_present  = NUM_CPUS[1:0] - 1'b1;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "icctvalid  => icctid <= max_cpu_present")
  u_ovl_intf_assert_fdc94a598bb966ad47214be2bacf8413ea5eeda5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icctvalid ),
    .consequent_expr (icctid <= max_cpu_present));



  assert_implication #(`OVL_FATAL, INOPTIONS, "icdtvalid  => icdtdest <= max_cpu_present")
  u_ovl_intf_assume_4db3ae4f96a84df1c678bd3b73e34a8943548143 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icdtvalid ),
    .consequent_expr (icdtdest <= max_cpu_present));





endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_gicarb_ext_defs.v"
`undef CA53_UNDEFINE

`endif

