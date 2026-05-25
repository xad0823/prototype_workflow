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

// This is the specification for the interface between the governor
// and the ETM.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_etm_gov_defs.v"
`include "cortexa53params.v"

module ca53_etm_gov #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         po_reset_n,
  input         gov_atclken_i,
  input         gov_atreadym_i,
  input         gov_afvalidm_i,
  input         gov_syncreqm_i,
  input         gov_pseldbg_etm_i,
  input         gov_penabledbg_i,
  input  [31:0] gov_pwdatadbg_i,
  input  [11:2] gov_paddrdbg_i,
  input         gov_pwritedbg_i,
  input         gov_etmpdsr_rd_i,
  input   [3:0] gov_extin_i,
  input  [63:0] gov_tsvalueb_i,
  input         gov_niden_i,
  input         gov_dbgen_i,
  input         gov_wfx_drain_req_i,
  input         etm_atvalidm_i,
  input         etm_afreadym_i,
  input  [31:0] etm_atdatam_i,
  input   [1:0] etm_atbytesm_i,
  input   [6:0] etm_atidm_i,
  input  [31:0] etm_prdatadbg_i,
  input         etm_preadydbg_i,
  input   [3:0] etm_extout_i,
  input         etm_oslock_i,
  input         etm_wfx_ready_i);


  wire         gov_atclken = gov_atclken_i;
  wire         gov_atreadym = gov_atreadym_i;
  wire         gov_afvalidm = gov_afvalidm_i;
  wire         gov_syncreqm = gov_syncreqm_i;
  wire         gov_pseldbg_etm = gov_pseldbg_etm_i;
  wire         gov_penabledbg = gov_penabledbg_i;
  wire  [31:0] gov_pwdatadbg = gov_pwdatadbg_i;
  wire  [11:2] gov_paddrdbg = gov_paddrdbg_i;
  wire         gov_pwritedbg = gov_pwritedbg_i;
  wire         gov_etmpdsr_rd = gov_etmpdsr_rd_i;
  wire   [3:0] gov_extin = gov_extin_i;
  wire  [63:0] gov_tsvalueb = gov_tsvalueb_i;
  wire         gov_niden = gov_niden_i;
  wire         gov_dbgen = gov_dbgen_i;
  wire         gov_wfx_drain_req = gov_wfx_drain_req_i;
  wire         etm_atvalidm = etm_atvalidm_i;
  wire         etm_afreadym = etm_afreadym_i;
  wire  [31:0] etm_atdatam = etm_atdatam_i;
  wire   [1:0] etm_atbytesm = etm_atbytesm_i;
  wire   [6:0] etm_atidm = etm_atidm_i;
  wire  [31:0] etm_prdatadbg = etm_prdatadbg_i;
  wire         etm_preadydbg = etm_preadydbg_i;
  wire   [3:0] etm_extout = etm_extout_i;
  wire         etm_oslock = etm_oslock_i;
  wire         etm_wfx_ready = etm_wfx_ready_i;



  reg         gov_wfx_drain_req_reg;
  reg         gov_wfx_drain_req_reg_reg;
  reg         gov_wfx_drain_req_reg_reg_reg;
  reg         gov_wfx_drain_req_reg_reg_reg_reg;
  reg         gov_wfx_drain_req_reg_reg_reg_reg_reg;

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
  begin
    gov_wfx_drain_req_reg <= 1'b0;
    gov_wfx_drain_req_reg_reg <= 1'b0;
    gov_wfx_drain_req_reg_reg_reg <= 1'b0;
    gov_wfx_drain_req_reg_reg_reg_reg <= 1'b0;
    gov_wfx_drain_req_reg_reg_reg_reg_reg <= 1'b0;
  end
  else
  begin
    gov_wfx_drain_req_reg <= gov_wfx_drain_req;
    gov_wfx_drain_req_reg_reg <= gov_wfx_drain_req_reg;
    gov_wfx_drain_req_reg_reg_reg <= gov_wfx_drain_req_reg_reg;
    gov_wfx_drain_req_reg_reg_reg_reg <= gov_wfx_drain_req_reg_reg_reg;
    gov_wfx_drain_req_reg_reg_reg_reg_reg <= gov_wfx_drain_req_reg_reg_reg_reg;
  end



  // ------------------------------------------------------
  //  Interface signals
  // ------------------------------------------------------

  //clk edge qualifier for ATB interface
  //  input         gov_atclken           valid   always      timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_atclken X or Z")
  u_ovl_intf_x_gov_atclken (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_atclken));


  // ATB interface 
  //  output        etm_atvalidm          valid   always                         timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "etm_atvalidm X or Z")
  u_ovl_intf_x_etm_atvalidm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_atvalidm));

  //  input         gov_atreadym          valid   gov_atclken                    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_atreadym X or Z")
  u_ovl_intf_x_gov_atreadym (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_atclken),
    .test_expr (gov_atreadym));

  //  output        etm_afreadym          valid   always                         timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "etm_afreadym X or Z")
  u_ovl_intf_x_etm_afreadym (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_afreadym));

  //  input         gov_afvalidm          valid   gov_atclken                    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_afvalidm X or Z")
  u_ovl_intf_x_gov_afvalidm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_atclken),
    .test_expr (gov_afvalidm));

  //  output [31:0] etm_atdatam           valid   etm_atvalidm & (&etm_atbytesm) timing 30%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "etm_atdatam X or Z")
  u_ovl_intf_x_etm_atdatam (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (etm_atvalidm & (&etm_atbytesm)),
    .test_expr (etm_atdatam));

  //  output [1:0]  etm_atbytesm          valid   etm_atvalidm                   timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "etm_atbytesm X or Z")
  u_ovl_intf_x_etm_atbytesm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (etm_atvalidm),
    .test_expr (etm_atbytesm));

  //  output [6:0]  etm_atidm             valid   etm_atvalidm                   timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, OUTOPTIONS, "etm_atidm X or Z")
  u_ovl_intf_x_etm_atidm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (etm_atvalidm),
    .test_expr (etm_atidm));

  //  input         gov_syncreqm          valid   gov_atclken                    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_syncreqm X or Z")
  u_ovl_intf_x_gov_syncreqm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_atclken),
    .test_expr (gov_syncreqm));



  //APB interface
  //  input         gov_pseldbg_etm       valid   always                                       timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pseldbg_etm X or Z")
  u_ovl_intf_x_gov_pseldbg_etm (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_pseldbg_etm));

  //  input         gov_penabledbg        valid   always                                       timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_penabledbg X or Z")
  u_ovl_intf_x_gov_penabledbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_penabledbg));

  //  input  [31:0] gov_pwdatadbg         valid   gov_pseldbg & gov_pwritedbg                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 32, INOPTIONS, "gov_pwdatadbg X or Z")
  u_ovl_intf_x_gov_pwdatadbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_pseldbg & gov_pwritedbg),
    .test_expr (gov_pwdatadbg));

  //  input  [11:2] gov_paddrdbg          valid   gov_pseldbg                                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 10, INOPTIONS, "gov_paddrdbg X or Z")
  u_ovl_intf_x_gov_paddrdbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_pseldbg),
    .test_expr (gov_paddrdbg));

  //  input         gov_pwritedbg         valid   gov_pseldbg                                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_pwritedbg X or Z")
  u_ovl_intf_x_gov_pwritedbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_pseldbg),
    .test_expr (gov_pwritedbg));

  //  output [31:0] etm_prdatadbg         valid   gov_pseldbg & ~gov_pwritedbg & etm_preadydbg timing 30%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "etm_prdatadbg X or Z")
  u_ovl_intf_x_etm_prdatadbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (gov_pseldbg & ~gov_pwritedbg & etm_preadydbg),
    .test_expr (etm_prdatadbg));

  //  output        etm_preadydbg         valid   always                                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "etm_preadydbg X or Z")
  u_ovl_intf_x_etm_preadydbg (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_preadydbg));

  //  input         gov_etmpdsr_rd        valid   always                                       timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_etmpdsr_rd X or Z")
  u_ovl_intf_x_gov_etmpdsr_rd (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_etmpdsr_rd));


  //CTI, miscellaneous signals
  //  input  [3:0]  gov_extin             valid   always      timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "gov_extin X or Z")
  u_ovl_intf_x_gov_extin (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_extin));

  //  output [3:0]  etm_extout            valid   always      timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "etm_extout X or Z")
  u_ovl_intf_x_etm_extout (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_extout));

  //  input  [63:0] gov_tsvalueb          valid   always      timing 70%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "gov_tsvalueb X or Z")
  u_ovl_intf_x_gov_tsvalueb (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_tsvalueb));

  //  output        etm_oslock            valid   always      timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "etm_oslock X or Z")
  u_ovl_intf_x_etm_oslock (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_oslock));

  //  input         gov_niden             valid   always      timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_niden X or Z")
  u_ovl_intf_x_gov_niden (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_niden));

  //  input         gov_dbgen             valid   always      timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_dbgen X or Z")
  u_ovl_intf_x_gov_dbgen (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgen));

  //  input         gov_wfx_drain_req     valid   always      timing 50% wiring 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_wfx_drain_req X or Z")
  u_ovl_intf_x_gov_wfx_drain_req (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (gov_wfx_drain_req));

  //  output        etm_wfx_ready         valid   always      timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "etm_wfx_ready X or Z")
  u_ovl_intf_x_etm_wfx_ready (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_wfx_ready));


  // WFX req requires an instruction to execute and cannot re-assert within 5 cycles

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gov_wfx_drain_req@1 & gov_wfx_drain_req  => ~gov_wfx_drain_req@2 &  ~gov_wfx_drain_req@3 & ~gov_wfx_drain_req@4 & ~gov_wfx_drain_req@5")
  u_ovl_intf_assert_24638c7242050f885dd8413971aa83f11f28f3ad (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (~gov_wfx_drain_req_reg & gov_wfx_drain_req ),
    .consequent_expr (~gov_wfx_drain_req_reg_reg &  ~gov_wfx_drain_req_reg_reg_reg & ~gov_wfx_drain_req_reg_reg_reg_reg & ~gov_wfx_drain_req_reg_reg_reg_reg_reg));





endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_etm_gov_defs.v"
`undef CA53_UNDEFINE

`endif

