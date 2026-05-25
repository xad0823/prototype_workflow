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

// This is the specification for the interface between the Governor and DCU.
// Inputs and outputs are from the point of view of the GOV.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gov_dcu_defs.v"
`include "cortexa53params.v"

module ca53_gov_dcu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         dcu_excl_mon_cleared_i,
  input  [17:0] dcu_cp_gov_addr_i,
  input         dcu_cp_gov_ns_i,
  input         dcu_cp_gov_req_i,
  input   [2:0] dcu_cp_gov_sel_i,
  input  [63:0] dcu_cp_gov_wdata_i,
  input         dcu_cp_gov_wenable_i,
  input         dcu_wfx_ready_i,
  input         gov_giccdisable_i,
  input         gov_stall_dsb_i,
  input         gov_cp_ack_i,
  input  [63:0] gov_cp_rdata_i,
  input         gov_wfx_drain_req_i,
  input         gov_standbywfe_i,
  input         gov_standbywfi_i,
  input         gov_mbist_req_i,
  input         gov_dbgl1rstdisable_i);


  wire         dcu_excl_mon_cleared = dcu_excl_mon_cleared_i;
  wire  [17:0] dcu_cp_gov_addr = dcu_cp_gov_addr_i;
  wire         dcu_cp_gov_ns = dcu_cp_gov_ns_i;
  wire         dcu_cp_gov_req = dcu_cp_gov_req_i;
  wire   [2:0] dcu_cp_gov_sel = dcu_cp_gov_sel_i;
  wire  [63:0] dcu_cp_gov_wdata = dcu_cp_gov_wdata_i;
  wire         dcu_cp_gov_wenable = dcu_cp_gov_wenable_i;
  wire         dcu_wfx_ready = dcu_wfx_ready_i;
  wire         gov_giccdisable = gov_giccdisable_i;
  wire         gov_stall_dsb = gov_stall_dsb_i;
  wire         gov_cp_ack = gov_cp_ack_i;
  wire  [63:0] gov_cp_rdata = gov_cp_rdata_i;
  wire         gov_wfx_drain_req = gov_wfx_drain_req_i;
  wire         gov_standbywfe = gov_standbywfe_i;
  wire         gov_standbywfi = gov_standbywfi_i;
  wire         gov_mbist_req = gov_mbist_req_i;
  wire         gov_dbgl1rstdisable = gov_dbgl1rstdisable_i;

  wire  [63:0] mem_mapped_mask;
  wire  [63:0] rdata_mask;
  wire         cp_gov_sel_l2;
  wire  [63:0] wdata_mask;
  wire         cp_gov_sel_timers;
  wire         cp_gov_sel_mem;
  wire         cp_gov_sel_sys;
  wire         cp_gov_valid;


  reg         gov_stall_dsb_reg;
  reg         dcu_cp_gov_req_reg;
  reg         dcu_cp_gov_req_reg_reg;
  reg         gov_cp_ack_reg;
  reg         gov_cp_ack_reg_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    gov_stall_dsb_reg <= 1'b0;
    dcu_cp_gov_req_reg <= 1'b0;
    dcu_cp_gov_req_reg_reg <= 1'b0;
    gov_cp_ack_reg <= 1'b0;
    gov_cp_ack_reg_reg <= 1'b0;
  end
  else
  begin
    dcu_cp_gov_req_reg <= dcu_cp_gov_req;
    dcu_cp_gov_req_reg_reg <= dcu_cp_gov_req_reg;
    gov_stall_dsb_reg <= gov_stall_dsb;
    gov_cp_ack_reg <= gov_cp_ack;
    gov_cp_ack_reg_reg <= gov_cp_ack_reg;
  end




  assign cp_gov_sel_mem      = (dcu_cp_gov_sel == `CA53_GIC_DCU_MEM);
  assign cp_gov_sel_sys      = (dcu_cp_gov_sel == `CA53_GIC_DCU_SYS);
  assign cp_gov_sel_l2       = (dcu_cp_gov_sel == `CA53_GOV_DCU_L2);
  assign cp_gov_sel_timers   = (dcu_cp_gov_sel == `CA53_GOV_DCU_TIMERS);
  assign cp_gov_valid        = cp_gov_sel_mem | cp_gov_sel_sys | cp_gov_sel_l2 | cp_gov_sel_timers;

  // - System register accesses are 64-bit
  // - Memory mapped accesses are 32-bit, with data aligned to correct half
  assign mem_mapped_mask  = dcu_cp_gov_addr[2] ? 64'hffffffff_00000000 : 64'h00000000_ffffffff;

  assign wdata_mask  = {64{dcu_cp_gov_req & cp_gov_valid & dcu_cp_gov_wenable}} & ({64{~cp_gov_sel_mem}} | mem_mapped_mask);

  // - System register accesses are 64-bit
  // - Memory mapped accesses are 32-bit, with data aligned to correct half
  assign rdata_mask  = {64{dcu_cp_gov_req & cp_gov_valid & gov_cp_ack & ~dcu_cp_gov_wenable}} & ({64{~cp_gov_sel_mem}} | mem_mapped_mask);

  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Inputs to the GOV from the DCU
  //  input          dcu_excl_mon_cleared        valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_excl_mon_cleared X or Z")
  u_ovl_intf_x_dcu_excl_mon_cleared (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_excl_mon_cleared));

  //  input [17:0]   dcu_cp_gov_addr             valid dcu_cp_gov_req & cp_gov_valid      timing 30%

  assert_never_unknown #(`OVL_FATAL, 18, INOPTIONS, "dcu_cp_gov_addr X or Z")
  u_ovl_intf_x_dcu_cp_gov_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_gov_req & cp_gov_valid),
    .test_expr (dcu_cp_gov_addr));

  //  input          dcu_cp_gov_ns               valid dcu_cp_gov_req & cp_gov_sel_mem    timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cp_gov_ns X or Z")
  u_ovl_intf_x_dcu_cp_gov_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_gov_req & cp_gov_sel_mem),
    .test_expr (dcu_cp_gov_ns));

  //  input          dcu_cp_gov_req              valid cp_gov_valid                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cp_gov_req X or Z")
  u_ovl_intf_x_dcu_cp_gov_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gov_valid),
    .test_expr (dcu_cp_gov_req));

  //  input [2:0]    dcu_cp_gov_sel              valid dcu_cp_gov_req & cp_gov_valid      timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dcu_cp_gov_sel X or Z")
  u_ovl_intf_x_dcu_cp_gov_sel (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_gov_req & cp_gov_valid),
    .test_expr (dcu_cp_gov_sel));

  //  input [63:0]   dcu_cp_gov_wdata            valid mask wdata_mask                    timing 30%

  assert_never_unknown #(`OVL_FATAL, 64, INOPTIONS, "dcu_cp_gov_wdata & (wdata_mask) X or Z")
  u_ovl_intf_x_7325ad860a15cc742705ba87d6602462a24cdc53 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_gov_wdata & (wdata_mask)));

  //  input          dcu_cp_gov_wenable          valid dcu_cp_gov_req & cp_gov_valid      timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cp_gov_wenable X or Z")
  u_ovl_intf_x_dcu_cp_gov_wenable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_gov_req & cp_gov_valid),
    .test_expr (dcu_cp_gov_wenable));

  //  input          dcu_wfx_ready               valid always                             timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_wfx_ready X or Z")
  u_ovl_intf_x_dcu_wfx_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_wfx_ready));


  // Outputs from the GOV to the DCU  
  //  output         gov_giccdisable             valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_giccdisable X or Z")
  u_ovl_intf_x_gov_giccdisable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_giccdisable));

  //  output         gov_stall_dsb               valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_stall_dsb X or Z")
  u_ovl_intf_x_gov_stall_dsb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_stall_dsb));

  //  output         gov_cp_ack                  valid cp_gov_valid                       timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_cp_ack X or Z")
  u_ovl_intf_x_gov_cp_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gov_valid),
    .test_expr (gov_cp_ack));

  //  output [63:0]  gov_cp_rdata                valid mask rdata_mask                    timing 30%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "gov_cp_rdata & (rdata_mask) X or Z")
  u_ovl_intf_x_f4ccc759393b57b9871ca07cfe4f245dd44a7357 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_cp_rdata & (rdata_mask)));

  //  output         gov_wfx_drain_req           valid always                             timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_wfx_drain_req X or Z")
  u_ovl_intf_x_gov_wfx_drain_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_wfx_drain_req));

  //  output         gov_standbywfe              valid always                             timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_standbywfe X or Z")
  u_ovl_intf_x_gov_standbywfe (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_standbywfe));

  //  output         gov_standbywfi              valid always                             timing 80%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_standbywfi X or Z")
  u_ovl_intf_x_gov_standbywfi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_standbywfi));

  //  output         gov_mbist_req               valid always                             timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_mbist_req X or Z")
  u_ovl_intf_x_gov_mbist_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_mbist_req));

  //  output         gov_dbgl1rstdisable         valid always                             timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gov_dbgl1rstdisable X or Z")
  u_ovl_intf_x_gov_dbgl1rstdisable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_dbgl1rstdisable));


  // ------------------------------------------------------
  // Interface description (GOV-Inputs/DCU-Outputs)
  // ------------------------------------------------------

  // dcu_excl_mon_cleared
  // Exclusive monitor clear

  // dcu_cp_gov_addr
  // The memory or system register address for a request.  For memory mapped
  // access this must be word aligned.  Accesses are defined by setting
  // dcu_cp_gov_sel appropriately.

  // dcu_cp_gov_ns
  // Indicates a DCU memory mapped request is non-secure.

  // dcu_cp_gov_req
  // Indicates an active DCU request.

  // dcu_cp_gov_sel:
  // Indicates the type of the access:
  //  000: No Access 
  //  001: Architectural timers
  //  010: GIC System Register Access
  //  011: GIC Memory Mapped Access
  //  100: L2 Register Access

  // dcu_cp_gov_wdata
  // The Write Data for a DCU read request.

  // dcu_cp_gov_wenable
  // Write enable for a DCU request.

  // dcu_wfx_ready
  // Indicates that the DCU has no requests in progress and thus is ready to
  // enter WFx state. This may be asserted at any time, even if the governor
  // has not requested a WFx. It may also be deasserted at any time, even
  // if the governor has requested a WFx and the DCU was previously ready (this
  // can happen if a new CCB request comes in from the SCU).

  // ------------------------------------------------------
  // Interface description (DCU-Inputs/GOV-Outputs)
  // ------------------------------------------------------

  // gov_giccdisable
  // Configuration signals

  // gov_cp_ack
  // The Governor acknowledge for a DCU request.  Marks the end of a DCU request.

  // gov_cp_rdata 
  // The Read Data for a DCU read request.

  // gov_wfx_drain_req
  // Governor requests a WFx so the DCU should be drained

  // gov_standbywfe
  // The core is in WFE

  // gov_standbywfi
  // The core is in WFI

  // gov_mbist_req
  // The global enable for MBIST

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // Ack should only be asserted during a request

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cp_ack  => dcu_cp_gov_req")
  u_ovl_intf_assert_59b7b28c6ee45d1c2dacbf84d540b04f2e085840 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cp_ack ),
    .consequent_expr (dcu_cp_gov_req));


  // Ack should only be asserted for a cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_cp_ack@1  => ~gov_cp_ack")
  u_ovl_intf_assert_4df2459fcb2cfa209ce7a4129b62b7e092439ec3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_cp_ack_reg ),
    .consequent_expr (~gov_cp_ack));


  // DCU should hold request until ack received, and on cycle after:

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cp_gov_req@1 & ~gov_cp_ack@2  => dcu_cp_gov_req")
  u_ovl_intf_assume_6de02cecb2639cef8fdfe3bc66b9b7b7fd4149a8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_gov_req_reg & ~gov_cp_ack_reg_reg ),
    .consequent_expr (dcu_cp_gov_req));


  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cp_gov_req@1 & gov_cp_ack@1  => dcu_cp_gov_req")
  u_ovl_intf_assume_422bc9afa9ffd1538319570c7bfc58bcb395021f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_gov_req_reg & gov_cp_ack_reg ),
    .consequent_expr (dcu_cp_gov_req));


  // Req can only be deasserted after an ack

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cp_gov_req@1 & ~dcu_cp_gov_req  => gov_cp_ack@2")
  u_ovl_intf_assume_ab58e23bd02cf042e273e3eb540e4cf0d5c1d3db (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_gov_req_reg & ~dcu_cp_gov_req ),
    .consequent_expr (gov_cp_ack_reg_reg));


  // Req must be desserted after an ack

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cp_gov_req@2 & gov_cp_ack@2  => dcu_cp_gov_req@1 & ~dcu_cp_gov_req")
  u_ovl_intf_assume_9908e456c26eb892ec94cd7975784e7a2f1e8618 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_gov_req_reg_reg & gov_cp_ack_reg_reg ),
    .consequent_expr (dcu_cp_gov_req_reg & ~dcu_cp_gov_req));


  // The stall_dsb signal should only be asserted when a request is active, up
  // to or on the cycle after the request is acked.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_stall_dsb & ~gov_stall_dsb@1  => dcu_cp_gov_req")
  u_ovl_intf_assert_3a6fb59ed9fe1b9733abef22069efb835b8c7330 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_stall_dsb & ~gov_stall_dsb_reg ),
    .consequent_expr (dcu_cp_gov_req));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_gov_dcu_defs.v"
`undef CA53_UNDEFINE

`endif

