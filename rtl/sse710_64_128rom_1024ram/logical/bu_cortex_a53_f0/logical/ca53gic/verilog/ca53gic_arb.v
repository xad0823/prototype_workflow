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
// Abstract: CortexA53 GIC Arbiter Top Level
//-----------------------------------------------------------------------------


`include "cortexa53params.v"


module ca53gic_arb `CA53_GIC_PARAM_DECL (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire                              DFTSE,
  input   wire                              gov_giccdisable_i,  // Sampled at reset
  input   wire  [(NUM_CPUS-1):0]            gic_arb_ack_i,      // Arbiter Request bus handshake Acknowledge
  input   wire  [(`CA53_TDATA_PKDED_W-1):0] gic_tdata_i,        // CPU Interface Request bus TDATA
  input   wire  [(NUM_CPUS-1):0]            gic_tlast_i,        // CPU Interface Request bus TLAST
  input   wire  [(NUM_CPUS-1):0]            gic_tvalid_i,       // CPU Interface Request bus TVALID
  input   wire                              icctready_i,        // GIC CPU Interface AXI-4 Stream TREADY
  input   wire  [(`CA53_TDATA_W-1):0]       icdtdata_i,         // GIC Distributor AXI-4 Stream TDATA
  input   wire  [1:0]                       icdtdest_i,         // GIC Distributor AXI-4 Stream TDEST
  input   wire                              icdtlast_i,         // GIC Distributor AXI-4 Stream TLAST
  input   wire                              icdtvalid_i,        // GIC Distributor AXI-4 Stream TVALID
  // Outputs
  output  wire  [31:0]                      arb_data_o,         // Arbiter Request bus data
  output  wire  [(NUM_CPUS-1):0]            arb_req_o,          // Arbiter Requst bus handshake Request
  output  wire  [(NUM_CPUS-1):0]            arb_tready_o,       // AXI-4 Stream TREADY between Arbiter Master and CPU Interface
  output  wire  [(`CA53_TDATA_W-1):0]       icctdata_o,         // GIC CPU Interface AXI-4 Stream TDATA
  output  wire                              icctlast_o,         // GIC CPU Interface AXI-4 Stream TLAST
  output  wire  [1:0]                       icctid_o,           // GIC CPU Interface AXI-4 Stream TID
  output  wire                              icctvalid_o,        // GIC CPU Interface AXI-4 Stream TVALID
  output  wire                              icdtready_o         // GIC Distributor AXI-4 Stream TREADY
);

  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg   gic_active;
  reg   icdtvalid_rs;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire  clk_g;
  wire  gic_enable;
  wire  master_active;
  wire  nxt_gic_active;
  wire  slave_active;


  // ------------------------------------------------------
  // Register slice
  // ------------------------------------------------------

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      icdtvalid_rs <= 1'b0;
    end else begin
      icdtvalid_rs <= icdtvalid_i;
    end


  // ------------------------------------------------------
  // Architectural clock gate
  // ------------------------------------------------------

  assign gic_enable     = ~gov_giccdisable_i;

  assign nxt_gic_active = ( |gic_tvalid_i ) |
                          icdtvalid_rs |
                          master_active |
                          slave_active;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_active <= 1'b0;
    end else if ( gic_enable ) begin
      gic_active <= nxt_gic_active;
    end

  ca53_cell_clkgate u_ca53_cell_clkgate (
    .clk_i              (clk),
    .clk_enable_i       (gic_active),
    .clk_senable_i      (DFTSE),
    .clk_gated_o        (clk_g)
  ); // u_ca53_cell_clkgate


  // ------------------------------------------------------
  // CPU to Distributor arbitration
  // ------------------------------------------------------

  ca53gic_arb_m `CA53_GIC_PARAM_INST u_ca53gic_arb_m (
    // Inputs
    .clk                (clk_g),
    .reset_n            (reset_n),
    .gic_tdata_i        (gic_tdata_i),
    .gic_tlast_i        (gic_tlast_i),
    .gic_tvalid_i       (gic_tvalid_i),
    .icctready_i        (icctready_i),
    // Outputs
    .arb_tready_o       (arb_tready_o),
    .icctdata_o         (icctdata_o),
    .icctlast_o         (icctlast_o),
    .icctid_o           (icctid_o),
    .icctvalid_o        (icctvalid_o),
    .master_active_o    (master_active)
  ); // ca53gic_arb_m


  // ------------------------------------------------------
  // Distributor to CPU Interface arbitration
  // ------------------------------------------------------

  ca53gic_arb_s `CA53_GIC_PARAM_INST u_ca53gic_arb_s (
    // Inputs
    .clk                (clk_g),
    .reset_n            (reset_n),
    .gic_arb_ack_i      (gic_arb_ack_i),
    .icdtdata_i         (icdtdata_i),
    .icdtdest_i         (icdtdest_i),
    .icdtlast_i         (icdtlast_i),
    .icdtvalid_rs_i     (icdtvalid_rs),
    // Outputs
    .arb_data_o         (arb_data_o),
    .arb_req_o          (arb_req_o),
    .icdtready_o        (icdtready_o),
    .slave_active_o     (slave_active)
  ); // u_ca53gic_arb_s


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gic_enable")
  u_ovl_x_gic_enable (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (gic_enable));

  // OVL_ASSERT_END

`endif


endmodule // ca53gic_arb


`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE

