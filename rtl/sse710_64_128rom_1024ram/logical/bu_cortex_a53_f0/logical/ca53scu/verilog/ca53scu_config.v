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

//-----------------------------------------------------------------------------
// Description:
//  Contains registers to capture top-level configuration inputs
//-----------------------------------------------------------------------------


`include "ca53scu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53scu_config #(`CA53_SCU_INT_PARAM_DECL) (
  input  wire        clk,
  input  wire        reset_n,
  input  wire        broadcastinner_i,
  input  wire        broadcastouter_i,
  input  wire        broadcastcachemaint_i,
  input  wire        sysbardisable_i,
  input  wire [2:0]  l1_dc_size_i,
  input  wire [3:0]  l2_size_i,
  input  wire        l2rstdisable_i,
  input  wire [6:0]  ext_nodeid_i,
  output wire        config_broadcastinner_o,
  output wire        config_broadcastouter_o,
  output wire        config_broadcastcachemaint_o,
  output wire        config_sysbardisable_o,
  output wire [2:0]  config_l1_dc_size_o,
  output wire [3:0]  config_l2_size_o,
  output wire        config_l2rstdisable_o,
  output wire [6:0]  config_nodeid_o,
  output wire        leaving_reset_o
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  reg        load_initial;
  reg        leaving_reset;
  reg        config_broadcastinner;
  reg        config_broadcastouter;
  reg        config_broadcastcachemaint;
  reg        config_sysbardisable;
  reg [2:0]  config_l1_dc_size;
  genvar     i;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  // ---------------------------------------------------------------------------------------
  // Logic to get an enable one cycle after reset
  // ---------------------------------------------------------------------------------------

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    load_initial  <= 1'b1;
    leaving_reset <= 1'b1;
  end else if (leaving_reset) begin
    load_initial  <= 1'b0;
    leaving_reset <= load_initial;
  end

  // Active for two cycles after reset
  assign leaving_reset_o = leaving_reset;

  // ---------------------------------------------------------------------------------------
  // Register config signals when leaving reset
  // ---------------------------------------------------------------------------------------

  always @(posedge clk)
  if (load_initial) begin
    config_broadcastinner      <= broadcastinner_i;
    config_broadcastouter      <= broadcastouter_i;
    config_broadcastcachemaint <= broadcastcachemaint_i;
    config_sysbardisable       <= sysbardisable_i;
    config_l1_dc_size          <= l1_dc_size_i;
  end

  assign config_broadcastinner_o      = config_broadcastinner;
  assign config_broadcastouter_o      = config_broadcastouter;
  assign config_broadcastcachemaint_o = config_broadcastcachemaint;
  assign config_sysbardisable_o       = config_sysbardisable;
  assign config_l1_dc_size_o          = config_l1_dc_size;

  generate if (L2_CACHE) begin : g_l2rstdisable
    reg       config_l2rstdisable;
    reg [3:0] config_l2_size;

    always @(posedge clk)
    if (load_initial) begin
      config_l2rstdisable <= l2rstdisable_i;
      config_l2_size      <= l2_size_i;
    end

    assign config_l2rstdisable_o = config_l2rstdisable;
    assign config_l2_size_o      = config_l2_size;

  end else begin : g_n_l2rstdisable

    assign config_l2rstdisable_o = 1'b0;
    assign config_l2_size_o = 4'b0000;

  end endgenerate

  generate if (ACE) begin : g_ace

    assign config_nodeid_o = 7'b0000000;

  end else begin : g_skyros
    reg [6:0]  config_nodeid;

    always @(posedge clk)
    if (load_initial) begin
      config_nodeid <= ext_nodeid_i;
    end

    assign config_nodeid_o = config_nodeid;

  end endgenerate

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: leaving_reset")
  u_ovl_x_leaving_reset (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (leaving_reset));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial")
  u_ovl_x_load_initial (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (load_initial));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
