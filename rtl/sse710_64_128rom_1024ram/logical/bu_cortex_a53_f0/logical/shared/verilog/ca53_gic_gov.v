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

// This is the specification for the interface between the GIC and GOV blocks.
// Inputs and outputs are from the point of view of the GIC.


// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_gic_gov_defs.v"
`include "cortexa53params.v"
`include "ca53_gov_dcu_defs.v"

module ca53_gic_gov #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input [(`CA53_CPADDR_W-1):0] cp_gov_addr_i,
  input         cp_gov_ns_i,
  input         cp_gov_req_i,
  input [(`CA53_CPSEL_W-1):0] cp_gov_sel_i,
  input [(`CA53_CPDATA_W-1):0] cp_gov_wdata_i,
  input         cp_gov_wenable_i,
  input         gov_aarch64_at_el3_i,
  input [(`CA53_EXCP_LEV_W-1):0] gov_exception_level_i,
  input         gov_giccdisable_i,
  input         gov_hcr_el2_amo_i,
  input         gov_hcr_el2_fmo_i,
  input         gov_hcr_el2_imo_i,
  input         gov_monitor_mode_i,
  input         gov_scr_el3_fiq_i,
  input         gov_scr_el3_irq_i,
  input         gov_scr_el3_ns_i,
  input         nfiq_rs_i,
  input         nirq_rs_i,
  input         nvfiq_rs_i,
  input         nvirq_rs_i,
  input         gic_fiq_i,
  input         gic_ich_hcr_el2_tall0_i,
  input         gic_ich_hcr_el2_tall1_i,
  input         gic_ich_hcr_el2_tc_i,
  input         gic_icc_sre_el1_ns_sre_i,
  input         gic_icc_sre_el1_s_sre_i,
  input         gic_icc_sre_el2_enable_i,
  input         gic_icc_sre_el2_sre_i,
  input         gic_icc_sre_el3_enable_i,
  input         gic_icc_sre_el3_sre_i,
  input         gic_irq_i,
  input         gic_vfiq_i,
  input         gic_virq_i,
  input         gic_cp_ack_i,
  input [(`CA53_CPDATA_W-1):0] gic_cp_rdata_i,
  input         gic_stall_dsb_i,
  input         gic_nxt_int_active_i);


  wire [(`CA53_CPADDR_W-1):0] cp_gov_addr = cp_gov_addr_i;
  wire         cp_gov_ns = cp_gov_ns_i;
  wire         cp_gov_req = cp_gov_req_i;
  wire [(`CA53_CPSEL_W-1):0] cp_gov_sel = cp_gov_sel_i;
  wire [(`CA53_CPDATA_W-1):0] cp_gov_wdata = cp_gov_wdata_i;
  wire         cp_gov_wenable = cp_gov_wenable_i;
  wire         gov_aarch64_at_el3 = gov_aarch64_at_el3_i;
  wire [(`CA53_EXCP_LEV_W-1):0] gov_exception_level = gov_exception_level_i;
  wire         gov_giccdisable = gov_giccdisable_i;
  wire         gov_hcr_el2_amo = gov_hcr_el2_amo_i;
  wire         gov_hcr_el2_fmo = gov_hcr_el2_fmo_i;
  wire         gov_hcr_el2_imo = gov_hcr_el2_imo_i;
  wire         gov_monitor_mode = gov_monitor_mode_i;
  wire         gov_scr_el3_fiq = gov_scr_el3_fiq_i;
  wire         gov_scr_el3_irq = gov_scr_el3_irq_i;
  wire         gov_scr_el3_ns = gov_scr_el3_ns_i;
  wire         nfiq_rs = nfiq_rs_i;
  wire         nirq_rs = nirq_rs_i;
  wire         nvfiq_rs = nvfiq_rs_i;
  wire         nvirq_rs = nvirq_rs_i;
  wire         gic_fiq = gic_fiq_i;
  wire         gic_ich_hcr_el2_tall0 = gic_ich_hcr_el2_tall0_i;
  wire         gic_ich_hcr_el2_tall1 = gic_ich_hcr_el2_tall1_i;
  wire         gic_ich_hcr_el2_tc = gic_ich_hcr_el2_tc_i;
  wire         gic_icc_sre_el1_ns_sre = gic_icc_sre_el1_ns_sre_i;
  wire         gic_icc_sre_el1_s_sre = gic_icc_sre_el1_s_sre_i;
  wire         gic_icc_sre_el2_enable = gic_icc_sre_el2_enable_i;
  wire         gic_icc_sre_el2_sre = gic_icc_sre_el2_sre_i;
  wire         gic_icc_sre_el3_enable = gic_icc_sre_el3_enable_i;
  wire         gic_icc_sre_el3_sre = gic_icc_sre_el3_sre_i;
  wire         gic_irq = gic_irq_i;
  wire         gic_vfiq = gic_vfiq_i;
  wire         gic_virq = gic_virq_i;
  wire         gic_cp_ack = gic_cp_ack_i;
  wire [(`CA53_CPDATA_W-1):0] gic_cp_rdata = gic_cp_rdata_i;
  wire         gic_stall_dsb = gic_stall_dsb_i;
  wire         gic_nxt_int_active = gic_nxt_int_active_i;

  wire [(`CA53_CPDATA_W-1):0] gic_cp_data_mask;
  wire         sre_el2_enable;
  wire         irq_virtual_access;
  wire         fiq_virtual_access;
  wire         sys_reg_sel_irq;
  wire         cp_gic_request_sys;
  wire         sre_el1_s_sre;
  wire         cp_gov_addr_sys_ro;
  wire         sre_el3_sre;
  wire         sys_reg_en;
  wire [(`CA53_GICCP_W-1):0] cp_gov_addr_sys;
  wire         sys_reg_sel_fiq;
  wire         cp_gov_addr_sys_wo;
  wire         cp_gov_sel_gic;
  wire         sys_reg_sel_common_virtual;
  wire         cp_gic_request;
  wire         fiq_cpu_el_valid;
  wire         sre_el3_enable;
  wire         new_cp_gic_request;
  wire         common_virtual_access;
  wire         el3_monitor;
  wire         cp_gic_request_mem;
  wire         sys_reg_sel_fiq_virtual;
  wire         sys_reg_sel_irq_virtual;
  wire         sre_el1_ns_sre;
  wire         sys_reg_sel_el3;
  wire         sre_el2_sre;
  wire         sys_reg_sel_common;
  wire         sys_reg_sel_all;
  wire [(`CA53_CPDATA_W-1):0] aligned_gic_cp_rdata_valid;
  wire         cp_gov_sel_gic_sys;
  wire         sys_reg_sel_el2_virtual_fiq;
  wire         end_cp_gic_request;
  wire [(`CA53_CPDATA_W-1):0] aligned_gic_cp_wdata_valid;
  wire         sys_reg_sel_el2_virtual_irq;
  wire         irq_cpu_el_valid;
  wire         cp_gov_sel_gic_mem;
  wire         sys_reg_sel_el2;

  reg         initialization_done;
  reg         first_access_observed;
  reg         gic_cp_ack_observed;

  reg         initialization_done_reg;
  reg         gov_hcr_el2_amo_reg;
  reg [(`CA53_EXCP_LEV_W-1):0] gov_exception_level_reg;
  reg [(`CA53_CPADDR_W-1):0] cp_gov_addr_reg;
  reg [(`CA53_CPDATA_W-1):0] cp_gov_wdata_reg;
  reg         cp_gov_wenable_reg;
  reg         gic_stall_dsb_reg;
  reg         gic_cp_ack_observed_reg;
  reg         gov_scr_el3_ns_reg;
  reg         gov_hcr_el2_imo_reg;
  reg         gov_scr_el3_fiq_reg;
  reg [(`CA53_CPSEL_W-1):0] cp_gov_sel_reg;
  reg         cp_gic_request_reg;
  reg         gov_aarch64_at_el3_reg;
  reg         cp_gov_ns_reg;
  reg         gic_cp_ack_reg;
  reg         gic_cp_ack_reg_reg;
  reg         gic_cp_ack_reg_reg_reg;
  reg         gic_cp_ack_reg_reg_reg_reg;
  reg         gov_monitor_mode_reg;
  reg         gov_giccdisable_reg;
  reg         gov_hcr_el2_fmo_reg;
  reg         gov_scr_el3_irq_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    initialization_done_reg <= 1'b0;
    gov_hcr_el2_amo_reg <= 1'b0;
    gov_exception_level_reg <= {(((`CA53_EXCP_LEV_W-1)) - (0) + 1){1'b0}};
    cp_gov_addr_reg <= {(((`CA53_CPADDR_W-1)) - (0) + 1){1'b0}};
    cp_gov_wdata_reg <= {(((`CA53_CPDATA_W-1)) - (0) + 1){1'b0}};
    cp_gov_wenable_reg <= 1'b0;
    gic_stall_dsb_reg <= 1'b0;
    gic_cp_ack_observed_reg <= 1'b0;
    gov_scr_el3_ns_reg <= 1'b0;
    gov_hcr_el2_imo_reg <= 1'b0;
    gov_scr_el3_fiq_reg <= 1'b0;
    cp_gov_sel_reg <= {(((`CA53_CPSEL_W-1)) - (0) + 1){1'b0}};
    cp_gic_request_reg <= 1'b0;
    gov_aarch64_at_el3_reg <= 1'b0;
    cp_gov_ns_reg <= 1'b0;
    gic_cp_ack_reg <= 1'b0;
    gic_cp_ack_reg_reg <= 1'b0;
    gic_cp_ack_reg_reg_reg <= 1'b0;
    gic_cp_ack_reg_reg_reg_reg <= 1'b0;
    gov_monitor_mode_reg <= 1'b0;
    gov_giccdisable_reg <= 1'b0;
    gov_hcr_el2_fmo_reg <= 1'b0;
    gov_scr_el3_irq_reg <= 1'b0;
  end
  else
  begin
    cp_gov_addr_reg <= cp_gov_addr;
    cp_gov_ns_reg <= cp_gov_ns;
    cp_gov_sel_reg <= cp_gov_sel;
    cp_gov_wdata_reg <= cp_gov_wdata;
    cp_gov_wenable_reg <= cp_gov_wenable;
    gov_aarch64_at_el3_reg <= gov_aarch64_at_el3;
    gov_exception_level_reg <= gov_exception_level;
    gov_giccdisable_reg <= gov_giccdisable;
    gov_hcr_el2_amo_reg <= gov_hcr_el2_amo;
    gov_hcr_el2_fmo_reg <= gov_hcr_el2_fmo;
    gov_hcr_el2_imo_reg <= gov_hcr_el2_imo;
    gov_monitor_mode_reg <= gov_monitor_mode;
    gov_scr_el3_fiq_reg <= gov_scr_el3_fiq;
    gov_scr_el3_irq_reg <= gov_scr_el3_irq;
    gov_scr_el3_ns_reg <= gov_scr_el3_ns;
    gic_cp_ack_reg <= gic_cp_ack;
    gic_cp_ack_reg_reg <= gic_cp_ack_reg;
    gic_cp_ack_reg_reg_reg <= gic_cp_ack_reg_reg;
    gic_cp_ack_reg_reg_reg_reg <= gic_cp_ack_reg_reg_reg;
    gic_stall_dsb_reg <= gic_stall_dsb;
    initialization_done_reg <= initialization_done;
    gic_cp_ack_observed_reg <= gic_cp_ack_observed;
    cp_gic_request_reg <= cp_gic_request;
  end



  // ------------------------------------------------------
  // Interface signals : CP bus (GOV is master)
  // ------------------------------------------------------

  // The memory or system register address for a request.  For memory mapped
  // access this must be word aligned.  Accesses are defined by setting
  // cp_gov_sel appropriately.
  //  input [(`CA53_CPADDR_W-1):0] cp_gov_addr valid cp_gic_request timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_CPADDR_W-1)) - (0) + 1), INOPTIONS, "cp_gov_addr X or Z")
  u_ovl_intf_x_cp_gov_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gic_request),
    .test_expr (cp_gov_addr));


  // Indicates a DCU memory mapped request is non-secure.
  //  input cp_gov_ns valid cp_gic_request_mem timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "cp_gov_ns X or Z")
  u_ovl_intf_x_cp_gov_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gic_request_mem),
    .test_expr (cp_gov_ns));


  // Indicates an active DCU request.
  //  input cp_gov_req valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "cp_gov_req X or Z")
  u_ovl_intf_x_cp_gov_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (cp_gov_req));


  // DCU device select for the CP request
  //  input [(`CA53_CPSEL_W-1):0] cp_gov_sel valid cp_gov_req timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_CPSEL_W-1)) - (0) + 1), INOPTIONS, "cp_gov_sel X or Z")
  u_ovl_intf_x_cp_gov_sel (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gov_req),
    .test_expr (cp_gov_sel));


  // The Write Data for a DCU write request:
  // - System register accesses are 64-bit
  // - Memory mapped accesses are 32-bit (word aligned)
  //  input [(`CA53_CPDATA_W-1):0] cp_gov_wdata valid mask aligned_gic_cp_wdata_valid timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_CPDATA_W-1)) - (0) + 1), INOPTIONS, "cp_gov_wdata & (aligned_gic_cp_wdata_valid) X or Z")
  u_ovl_intf_x_3e06e8b9e513277b45b821011c5b93dc710f10af (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (cp_gov_wdata & (aligned_gic_cp_wdata_valid)));


  // Write enable for a DCU request.
  //  input cp_gov_wenable valid cp_gic_request timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "cp_gov_wenable X or Z")
  u_ovl_intf_x_cp_gov_wenable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_gic_request),
    .test_expr (cp_gov_wenable));


  //  output gic_cp_ack valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gic_cp_ack X or Z")
  u_ovl_intf_x_gic_cp_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_cp_ack));


  // The Read Data for a DCU read request:
  // - System register accesses are 64-bit
  // - Memory mapped accesses are 32-bit (word aligned)
  //  output [(`CA53_CPDATA_W-1):0] gic_cp_rdata valid mask aligned_gic_cp_rdata_valid timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_CPDATA_W-1)) - (0) + 1), OUTOPTIONS, "gic_cp_rdata & (aligned_gic_cp_rdata_valid) X or Z")
  u_ovl_intf_x_0a9592bf92448a143e1f41ab90e9371e94f6b880 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_cp_rdata & (aligned_gic_cp_rdata_valid)));



  // ------------------------------------------------------
  // Interface signals : CPU state
  // ------------------------------------------------------

  // NOTE: The following are registered by GOV when both CPU and GIC are
  //       enabled.  These are used by the GIC for interrupt signalling
  //       and processing.

  // AArch64 at EL3
  //  input gov_aarch64_at_el3 valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_aarch64_at_el3 X or Z")
  u_ovl_intf_x_gov_aarch64_at_el3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_aarch64_at_el3));


  // The current exception level
  //  input [(`CA53_EXCP_LEV_W-1):0] gov_exception_level valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_EXCP_LEV_W-1)) - (0) + 1), INOPTIONS, "gov_exception_level X or Z")
  u_ovl_intf_x_gov_exception_level (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_exception_level));


  // GIC CPU Interface hardware disabled (active high)
  //  input gov_giccdisable valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_giccdisable X or Z")
  u_ovl_intf_x_gov_giccdisable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gov_giccdisable));


  // HCR_EL2.AMO
  //  input gov_hcr_el2_amo valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_hcr_el2_amo X or Z")
  u_ovl_intf_x_gov_hcr_el2_amo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_hcr_el2_amo));


  // HCR_EL2.FMO
  //  input gov_hcr_el2_fmo valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_hcr_el2_fmo X or Z")
  u_ovl_intf_x_gov_hcr_el2_fmo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_hcr_el2_fmo));


  // HCR_EL2.IMO
  //  input gov_hcr_el2_imo valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_hcr_el2_imo X or Z")
  u_ovl_intf_x_gov_hcr_el2_imo (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_hcr_el2_imo));


  // CPU is in Monitor mode
  //  input gov_monitor_mode valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_monitor_mode X or Z")
  u_ovl_intf_x_gov_monitor_mode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_monitor_mode));


  // SCR_EL3.FIQ
  //  input gov_scr_el3_fiq valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_scr_el3_fiq X or Z")
  u_ovl_intf_x_gov_scr_el3_fiq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_scr_el3_fiq));


  // SCR_EL3.IRQ
  //  input gov_scr_el3_irq valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_scr_el3_irq X or Z")
  u_ovl_intf_x_gov_scr_el3_irq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_scr_el3_irq));


  // SCR_EL3.NS
  //  input gov_scr_el3_ns valid ~gov_giccdisable timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "gov_scr_el3_ns X or Z")
  u_ovl_intf_x_gov_scr_el3_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (~gov_giccdisable),
    .test_expr (gov_scr_el3_ns));



  // ------------------------------------------------------
  // Interface signals : GIC state
  // ------------------------------------------------------

  // DSBs stall while the CPU Interface and Distributor are synchronizing
  //  output gic_stall_dsb valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gic_stall_dsb X or Z")
  u_ovl_intf_x_gic_stall_dsb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_stall_dsb));



  // ------------------------------------------------------
  // Interface signals : Interrupts
  // ------------------------------------------------------

  // Top level external nFIQ synchronized by GOV
  //  input nfiq_rs valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "nfiq_rs X or Z")
  u_ovl_intf_x_nfiq_rs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nfiq_rs));


  // Top level external nIRQ synchronized by GOV
  //  input nirq_rs valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "nirq_rs X or Z")
  u_ovl_intf_x_nirq_rs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nirq_rs));


  // Top level external nVFIQ synchronized by GOV
  //  input nvfiq_rs valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "nvfiq_rs X or Z")
  u_ovl_intf_x_nvfiq_rs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nvfiq_rs));


  // Top level external nVIRQ synchronized by GOV
  //  input nvirq_rs valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "nvirq_rs X or Z")
  u_ovl_intf_x_nvirq_rs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nvirq_rs));


  // The GIC is asserting an interrupt (external or internal source)
  //  output gic_nxt_int_active valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "gic_nxt_int_active X or Z")
  u_ovl_intf_x_gic_nxt_int_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (gic_nxt_int_active));



  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Configuration
  // ------------------------------------------------------

  // Configuration signals should not change after reset

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    initialization_done <= 1'b0;
  else
    initialization_done <= 1'b1;



  assert_implication #(`OVL_FATAL, INOPTIONS, "initialization_done@1  => gov_giccdisable == gov_giccdisable@1")
  u_ovl_intf_assume_e15806fbba00f4ade41e121a6d495379698e3ea7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (initialization_done_reg ),
    .consequent_expr (gov_giccdisable == gov_giccdisable_reg));


  // Configuration signals should not change after reset.  However, some signals
  // take several cycles after reset to be synchronized between the DPU and the
  // GIC.  From reset the GIC is in bypass mode and interrupt routing based on
  // CPU configuration is not relevant.  Hence, only after the first access,
  // where the GIC configuration MAY be changed, static signals used to factor
  // interrupt routing MUST be stable.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_access_observed <= 1'b0;
  else
    first_access_observed <= new_cp_gic_request | first_access_observed;



  assert_implication #(`OVL_FATAL, INOPTIONS, "first_access_observed  => gov_aarch64_at_el3 == gov_aarch64_at_el3@1")
  u_ovl_intf_assume_a8d9a71980b88a2efcb2e2c72a8dcb8f0af32c1d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_access_observed ),
    .consequent_expr (gov_aarch64_at_el3 == gov_aarch64_at_el3_reg));



  // ------------------------------------------------------
  // CP Request Handshake Rules
  // ------------------------------------------------------

  assign cp_gov_sel_gic_mem  = ( cp_gov_sel == `CA53_GIC_DCU_MEM );
  assign cp_gov_sel_gic_sys  = ( cp_gov_sel == `CA53_GIC_DCU_SYS );
  assign cp_gov_sel_gic      = cp_gov_sel_gic_mem | cp_gov_sel_gic_sys;

  // Detect a memory mapped or system register request to the GIC
  assign cp_gic_request  = cp_gov_req & cp_gov_sel_gic;

  // No accesses should be routed to the GIC CPU Interface if it is disabled

  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_giccdisable  => ~cp_gic_request")
  u_ovl_intf_assume_ca6a6b5485f9f7ebc78671b56948d19dc4a32e79 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~cp_gic_request));


  // Detect a new request
  assign new_cp_gic_request  =  cp_gic_request & ~cp_gic_request_reg;

  // Detect end of request
  assign end_cp_gic_request  = ~cp_gic_request &  cp_gic_request_reg;

  // ACK signal can only be asserted during a request

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gic_cp_ack  => cp_gic_request")
  u_ovl_intf_assert_2e351e1b906d3877a4bfb4deebb9de237d8dd616 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gic_cp_ack ),
    .consequent_expr (cp_gic_request));


  // Detect if an Acknowledge has been observed
  // NOTE: The request signal is expected to remain asserted for several cycles
  // after the Acknowledge has been observed.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    gic_cp_ack_observed <= 1'b0;
  else
    gic_cp_ack_observed <= gic_cp_ack | ( gic_cp_ack_observed & cp_gic_request_reg );


  // ACK should be one-to-one with requests

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gic_cp_ack  => ~gic_cp_ack_observed")
  u_ovl_intf_assert_095659291f21a66da1c8678f2ad305b767c81b4d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gic_cp_ack ),
    .consequent_expr (~gic_cp_ack_observed));


  // A request should be asserted for several cycles after an ACK

  assert_implication #(`OVL_FATAL, INOPTIONS, "end_cp_gic_request  => gic_cp_ack@4")
  u_ovl_intf_assume_612cba110f96ea79f7b299953d6fb3fc84cd9b66 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (end_cp_gic_request ),
    .consequent_expr (gic_cp_ack_reg_reg_reg_reg));


  // Address signal must remain stable during a request

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request & ( ~new_cp_gic_request )  => cp_gov_addr == cp_gov_addr@1")
  u_ovl_intf_assume_b62238433fc8644cae663b6da2ef25e0a006ba47 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request & ( ~new_cp_gic_request ) ),
    .consequent_expr (cp_gov_addr == cp_gov_addr_reg));


  // Select mode signal must remain stable during a request

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request & ( ~new_cp_gic_request )  => cp_gov_sel == cp_gov_sel@1")
  u_ovl_intf_assume_30df46544afdb6b7bc90da03c5bed2d5ba7c30d6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request & ( ~new_cp_gic_request ) ),
    .consequent_expr (cp_gov_sel == cp_gov_sel_reg));


  // Write Enable signal must remain stable during a request

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request & ( ~new_cp_gic_request )  => cp_gov_wenable == cp_gov_wenable@1")
  u_ovl_intf_assume_d7947472737dfe9294cfbea9e5f035994017352d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request & ( ~new_cp_gic_request ) ),
    .consequent_expr (cp_gov_wenable == cp_gov_wenable_reg));


  // Data presented to the GIC is word aligned for memory mapped accesses -
  // only the word aligned word is required to be valid.  For system register
  // access all data words are required to be valid.
  assign gic_cp_data_mask             = { ({(`CA53_CPDATA_W>>1){cp_gov_sel_gic_sys |  cp_gov_addr[2]}}), ({(`CA53_CPDATA_W>>1){cp_gov_sel_gic_sys | ~cp_gov_addr[2]}})};

  assign aligned_gic_cp_rdata_valid   = {`CA53_CPDATA_W{( ~cp_gov_wenable & gic_cp_ack )}}     & gic_cp_data_mask;

  assign aligned_gic_cp_wdata_valid   = {`CA53_CPDATA_W{(  cp_gov_wenable & cp_gic_request )}} & gic_cp_data_mask;

  // Write Data signal must remain stable during a request

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request & ( ~new_cp_gic_request ) & cp_gov_wenable  => ( cp_gov_wdata & gic_cp_data_mask ) == ( cp_gov_wdata@1 & gic_cp_data_mask )")
  u_ovl_intf_assume_a6bcb7ecd203220b3b36041068c5c6268da36a5f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request & ( ~new_cp_gic_request ) & cp_gov_wenable ),
    .consequent_expr (( cp_gov_wdata & gic_cp_data_mask ) == ( cp_gov_wdata_reg & gic_cp_data_mask )));



  // ------------------------------------------------------
  // GIC state
  // ------------------------------------------------------

  // The GIC should not stall DSBs when it is disabled

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_giccdisable  => ~gic_stall_dsb")
  u_ovl_intf_assert_bd4b7cf0bdd7c62e6e948349eccc6353810d5d74 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_giccdisable ),
    .consequent_expr (~gic_stall_dsb));


  // The transfer of CPU Interface state to the Distributor can only be
  // initiated during a CP request until the cycle the request is
  // acknowledged.  The GIC takes an extra cycle to register this before
  // passing it to the GOV.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~gic_stall_dsb@1 & gic_stall_dsb  => cp_gic_request & ~gic_cp_ack_observed@1")
  u_ovl_intf_assert_e6101e4e86eb6c28944e7538000f64e1e9a977de (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~gic_stall_dsb_reg & gic_stall_dsb ),
    .consequent_expr (cp_gic_request & ~gic_cp_ack_observed_reg));


  // Whenever the GIC CPU Interface is driving an interrupt the
  // gic_nxt_int_active signal is asserted.  However, gic_nxt_int_active
  // can be asserted without a valid interrupt.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "( gic_fiq | gic_irq | gic_vfiq | gic_virq )  => gic_nxt_int_active")
  u_ovl_intf_assert_001716739cf637ec9a2687ac87f5c70ba584ff21 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (( gic_fiq | gic_irq | gic_vfiq | gic_virq ) ),
    .consequent_expr (gic_nxt_int_active));



  // ------------------------------------------------------
  // Memory Mapped Access Rules
  // ------------------------------------------------------

  // Detect a memory mapped request to the GIC
  assign cp_gic_request_mem  = cp_gov_req & cp_gov_sel_gic_mem;

  // All memory mapped requests must be 32-bit aligned

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_mem  => cp_gov_addr[1:0] == 2'b0")
  u_ovl_intf_assume_cb9ab99b4d96fd0d5a8ef9ea54831015938aa509 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_mem ),
    .consequent_expr (cp_gov_addr[1:0] == 2'b0));


  // Non-Secure signal must remain stable from assertion of REQ until assertion of ACK

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gov_req & ( ~new_cp_gic_request ) & cp_gov_sel_gic_mem  => cp_gov_ns == cp_gov_ns@1")
  u_ovl_intf_assume_4cc0c0cdd729fcf125167c53cdd99e595185e5a7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gov_req & ( ~new_cp_gic_request ) & cp_gov_sel_gic_mem ),
    .consequent_expr (cp_gov_ns == cp_gov_ns_reg));



  // ------------------------------------------------------
  // System Register Access Rules
  // ------------------------------------------------------

  // Detect a system register request to the GIC
  assign cp_gic_request_sys  = cp_gov_req & cp_gov_sel_gic_sys;

  // The system register address bus is a subset of full address bus width
  assign cp_gov_addr_sys  = cp_gov_addr[(`CA53_GICCP_W-1):0];


  // ------------------------------------------------------
  // DPU Interface Rules
  // ------------------------------------------------------

  // All internal CPU signals used for the routing of an interrupt are expected
  // to be stable while a CPU request is being made on the GIC CPU Interface.

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_exception_level  == gov_exception_level@1")
  u_ovl_intf_assume_11dc4fd84a07d3e21749e2c18581ac2e258bc091 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_exception_level  == gov_exception_level_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_monitor_mode     == gov_monitor_mode@1")
  u_ovl_intf_assume_f084e06377a1b33561bee97664c8408c1cec3eeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_monitor_mode     == gov_monitor_mode_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_hcr_el2_amo      == gov_hcr_el2_amo@1")
  u_ovl_intf_assume_ef68c4ef4c4dec8997e430ffd40a7159508c5652 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_hcr_el2_amo      == gov_hcr_el2_amo_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_hcr_el2_fmo      == gov_hcr_el2_fmo@1")
  u_ovl_intf_assume_fe2e59d3836935c3611bb9136421c7d403c6ffcf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_hcr_el2_fmo      == gov_hcr_el2_fmo_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_hcr_el2_imo      == gov_hcr_el2_imo@1")
  u_ovl_intf_assume_4f49381c5658178ddd8048b4e2bb60c98c180458 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_hcr_el2_imo      == gov_hcr_el2_imo_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_scr_el3_fiq      == gov_scr_el3_fiq@1")
  u_ovl_intf_assume_16b6b6dbc0582a0352f7780ca158f327503ae765 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_scr_el3_fiq      == gov_scr_el3_fiq_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_scr_el3_irq      == gov_scr_el3_irq@1")
  u_ovl_intf_assume_8b6b7955ff5f1d0b0c136b4c8bcd595de1977f63 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_scr_el3_irq      == gov_scr_el3_irq_reg));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ~new_cp_gic_request  => gov_scr_el3_ns       == gov_scr_el3_ns@1")
  u_ovl_intf_assume_fbdbc7069405c76209bf95930df23221430d3b42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ~new_cp_gic_request ),
    .consequent_expr (gov_scr_el3_ns       == gov_scr_el3_ns_reg));


  // EL2 is always non-secure

  assert_implication #(`OVL_FATAL, INOPTIONS, "( gov_exception_level == `CA53_EL2 )  => gov_scr_el3_ns")
  u_ovl_intf_assume_df2e8d3044763ee162ed0ffba9081d08f7434810 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (( gov_exception_level == `CA53_EL2 ) ),
    .consequent_expr (gov_scr_el3_ns));


  // El1 is always non-secure in AArch32

  assert_implication #(`OVL_FATAL, INOPTIONS, "( gov_exception_level == `CA53_EL1 ) & ~gov_aarch64_at_el3 & first_access_observed  => gov_scr_el3_ns")
  u_ovl_intf_assume_24c2cea5c36b44eb4a03d003ccd15e8ad577c139 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (( gov_exception_level == `CA53_EL1 ) & ~gov_aarch64_at_el3 & first_access_observed ),
    .consequent_expr (gov_scr_el3_ns));


  // Monitor mode in AArch32 runs at EL3

  assert_implication #(`OVL_FATAL, INOPTIONS, "gov_monitor_mode & ~gov_aarch64_at_el3 & first_access_observed  => gov_exception_level == `CA53_EL3")
  u_ovl_intf_assume_8a5c94f55545c072f600a351e4107a87e42173f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (gov_monitor_mode & ~gov_aarch64_at_el3 & first_access_observed ),
    .consequent_expr (gov_exception_level == `CA53_EL3));


  // CPU is in EL3 when AArch32 is at EL3 or Monitor mode when AArch32 is at EL3
  assign el3_monitor  = ( gov_exception_level == `CA53_EL3 ) & ( gov_aarch64_at_el3 | gov_monitor_mode );


  // ------------------------------------------------------
  // System Register Enables
  // ------------------------------------------------------

  // System register decoding:
  //  ICC_SRE_EL3.SRE | ICC_SRE_EL1_S.SRE | ICC_SRE_EL2.SRE     | {AMO,FMO,IMO}           | ICC_SRE_EL1_NS.SRE
  //  ----------------------------------------------------------------------------------------------------------
  //                0 | (forced by EL3) 0 |   (forced by EL3) 0 |                       X |    (forced by EL3) 0
  //                1 |                 0 |                   0 |                       X |    (forced by EL2) 0
  //                1 |                 0 |                   1 |                       X |                    0
  //                1 |                 0 |                   1 |                       X |                    1
  //                1 |                 1 | (forced by EL1_S) 1 | (not all virtualized) 0 |  (forced by EL1_S) 1
  //                1 |                 1 | (forced by EL1_S) 1 |     (all virtualized) 1 |                    0
  //                1 |                 1 | (forced by EL1_S) 1 |     (all virtualized) 1 |                    1

  assign sre_el3_sre     = gic_icc_sre_el3_sre;

  assign sre_el1_s_sre   = gic_icc_sre_el3_sre & gic_icc_sre_el1_s_sre;

  assign sre_el2_sre     = gic_icc_sre_el3_sre & ( gic_icc_sre_el1_s_sre | gic_icc_sre_el2_sre );

  assign sre_el1_ns_sre  = ( sre_el2_sre   &    gic_icc_sre_el1_ns_sre ) | ( sre_el1_s_sre & ( ~gov_hcr_el2_amo | ~gov_hcr_el2_fmo | ~gov_hcr_el2_imo ) );

  // System registers are enabled at the current exception level
  assign sys_reg_en  = (   el3_monitor                        &                    sre_el3_sre   ) | ( ( gov_exception_level >= `CA53_EL1 ) & ~gov_scr_el3_ns  & sre_el1_s_sre ) | ( ( gov_exception_level == `CA53_EL2 ) &                    sre_el2_sre )   | ( ( gov_exception_level == `CA53_EL1 ) &  gov_scr_el3_ns  & sre_el1_ns_sre );

  // Exception level check for ICC_SRE_EL3

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL3 )  => el3_monitor")
  u_ovl_intf_assume_379018eb4fe267195189e1ac6fb2b883b851d1c7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL3 ) ),
    .consequent_expr (el3_monitor));


  // Exception level check for ICC_SRE_EL2

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL2 )  => gov_exception_level >= `CA53_EL2")
  u_ovl_intf_assume_a61bd35ba57d86901d69253a71267a0a1547fd19 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL2 ) ),
    .consequent_expr (gov_exception_level >= `CA53_EL2));


  // Exception level check for ICC_SRE_EL1

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 )  => gov_exception_level >= `CA53_EL1")
  u_ovl_intf_assume_a5a48546c78edeabf97dfd46afea397de886fb67 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 ) ),
    .consequent_expr (gov_exception_level >= `CA53_EL1));


  // Treated value of ICC_SRE_EL3.ENABLE
  assign sre_el3_enable  = ~sre_el3_sre | gic_icc_sre_el3_enable;

  // Treated value of ICC_SRE_EL2.ENABLE
  assign sre_el2_enable  = ~sre_el3_sre | ~sre_el2_sre | gic_icc_sre_el2_enable;

  // SRE Enable trapping for ICC_SRE_EL2

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL2 )  => el3_monitor | sre_el3_enable")
  u_ovl_intf_assume_af5e2bbe07ab430d9d16aaaa5b1e769d201134d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL2 ) ),
    .consequent_expr (el3_monitor | sre_el3_enable));


  // SRE Enable trapping for ICC_SRE_EL1 non-secure

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 ) & gov_scr_el3_ns  => el3_monitor | ( sre_el3_enable & ( gov_exception_level >= `CA53_EL2 ) ) | ( sre_el2_enable & ( gov_exception_level == `CA53_EL1 ) )")
  u_ovl_intf_assume_3fa4b05303182686371620e0cdc3eb8d7744ec8a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 ) & gov_scr_el3_ns ),
    .consequent_expr (el3_monitor | ( sre_el3_enable & ( gov_exception_level >= `CA53_EL2 ) ) | ( sre_el2_enable & ( gov_exception_level == `CA53_EL1 ) )));


  // SRE Enable trapping for ICC_SRE_EL1 secure

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 ) & ~gov_scr_el3_ns  => el3_monitor | sre_el3_enable")
  u_ovl_intf_assume_36dc9d83604ad30a62d9036ebf79ccba70218cda (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( cp_gov_addr_sys == `CA53_GICCP_GICC_SRE_EL1 ) & ~gov_scr_el3_ns ),
    .consequent_expr (el3_monitor | sre_el3_enable));


  // SRE is enabled at the current EL for system register accesses
  // NOTEL This excludes SRE registers

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( sys_reg_sel_el3 | sys_reg_sel_el2 | sys_reg_sel_el2_virtual_fiq | sys_reg_sel_el2_virtual_irq | sys_reg_sel_fiq | sys_reg_sel_fiq_virtual | sys_reg_sel_irq | sys_reg_sel_irq_virtual | sys_reg_sel_common | sys_reg_sel_common_virtual )  => sys_reg_en")
  u_ovl_intf_assume_13398802cf2524dba57cef36bd79f3b1d4549d2e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( sys_reg_sel_el3 | sys_reg_sel_el2 | sys_reg_sel_el2_virtual_fiq | sys_reg_sel_el2_virtual_irq | sys_reg_sel_fiq | sys_reg_sel_fiq_virtual | sys_reg_sel_irq | sys_reg_sel_irq_virtual | sys_reg_sel_common | sys_reg_sel_common_virtual ) ),
    .consequent_expr (sys_reg_en));



  // ------------------------------------------------------
  // System Registers : EL3 or Monitor Mode
  // ------------------------------------------------------

  // System registers only accessible at EL3 (AArch64) or Monitor mode (AArch32)
  assign sys_reg_sel_el3   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN1_EL3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_CTLR_EL3 ));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_el3  => el3_monitor")
  u_ovl_intf_assume_18dcc01cd1b171cd60bb0792c844fdf09d9ccac9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_el3 ),
    .consequent_expr (el3_monitor));



  // ------------------------------------------------------
  // System Register : EL2 Registers
  // ------------------------------------------------------

  // System physical registers only accessible at EL2 (AArch64) or Hyp mode (AArch32) and above
  assign sys_reg_sel_el2   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICH_EISR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_ELSR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_HCR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_MISR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VTR ));

  // Group 0 system register accessed either via the Hypervisor at EL2 and
  // above or via the guest OS.
  assign sys_reg_sel_el2_virtual_fiq  = ((cp_gov_addr_sys ==  `CA53_GICCP_GICH_APR0));

  // Group 1 system register accessed either via the Hypervisor at EL2 and
  // above or via the guest OS.
  assign sys_reg_sel_el2_virtual_irq  = ((cp_gov_addr_sys ==  `CA53_GICCP_GICH_APR1));

  // Check the exception level is valid for physical accesses

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_el2  => gov_exception_level >= `CA53_EL2")
  u_ovl_intf_assume_6a884260f5a5faec8a6bda5af3fe9105b26bb2f1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_el2 ),
    .consequent_expr (gov_exception_level >= `CA53_EL2));


  // Check the exception level is valid for physical or virtual accesses (accounting for traps)

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_el2_virtual_fiq  => ( gov_exception_level >= `CA53_EL2 ) | ( fiq_virtual_access & ~gic_ich_hcr_el2_tall0 )")
  u_ovl_intf_assume_f70925dd2adade37a2070620e89c15cba0dd5de5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_el2_virtual_fiq ),
    .consequent_expr (( gov_exception_level >= `CA53_EL2 ) | ( fiq_virtual_access & ~gic_ich_hcr_el2_tall0 )));



  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_el2_virtual_irq  => ( gov_exception_level >= `CA53_EL2 ) | ( irq_virtual_access & ~gic_ich_hcr_el2_tall1 )")
  u_ovl_intf_assume_c0dd624125d91cf030341dce6be3f031553be052 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_el2_virtual_irq ),
    .consequent_expr (( gov_exception_level >= `CA53_EL2 ) | ( irq_virtual_access & ~gic_ich_hcr_el2_tall1 )));



  // ------------------------------------------------------
  // System registers : Group 0
  // ------------------------------------------------------

  // System group 0 physical registers governed by the routing of FIQ
  assign sys_reg_sel_fiq   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICC_AP0R0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_BPR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_HPPIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN0_EL1 ));

  // System group 0 virtual registers
  // NOTE: ICC_AP0R0_EL1 is shared with EL2
  assign sys_reg_sel_fiq_virtual   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_BPR0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_EOIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_HPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_IAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_VENG0 ));

  assign fiq_virtual_access  = ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns & gov_hcr_el2_fmo;

  assign fiq_cpu_el_valid  = gov_scr_el3_fiq                     ? el3_monitor: ( gov_scr_el3_ns  & gov_hcr_el2_fmo ) ? ( gov_exception_level >= `CA53_EL2 ): ( gov_exception_level >= `CA53_EL1 );

  // Check the exception level is valid for physical accesses

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_fiq  => fiq_cpu_el_valid")
  u_ovl_intf_assume_87c64ec27022208ef3a5119f4d293fd6a56b85df (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_fiq ),
    .consequent_expr (fiq_cpu_el_valid));


  // Register physical encodings should not be used when group 0 registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & fiq_virtual_access  => ~sys_reg_sel_fiq")
  u_ovl_intf_assume_c0dd09f13712cbc95c878d095a3024938a60807f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & fiq_virtual_access ),
    .consequent_expr (~sys_reg_sel_fiq));


  // Register virtual encodings should only be used when group 0 registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_fiq_virtual  => fiq_virtual_access")
  u_ovl_intf_assume_96b3811196e790fbae86d16c40e2bf2e67b986ef (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_fiq_virtual ),
    .consequent_expr (fiq_virtual_access));


  // All accesses trap at EL1 non-secure when ICH_HCR_EL2.TALL0==1

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( sys_reg_sel_fiq | sys_reg_sel_fiq_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns  => ~gic_ich_hcr_el2_tall0")
  u_ovl_intf_assume_7a51cb14856b1e8986385f4bec2618f29bea5a10 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( sys_reg_sel_fiq | sys_reg_sel_fiq_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns ),
    .consequent_expr (~gic_ich_hcr_el2_tall0));



  // ------------------------------------------------------
  // System registers : Group 1
  // ------------------------------------------------------

  // System group 1 physical registers governed by the routing of IRQ
  assign sys_reg_sel_irq   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICC_AP1R0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_BPR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_HPPIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN1_EL1 ));

  // System group 1 virtual registers
  // NOTE: ICC_AP1R0_EL1 is shared with EL2
  assign sys_reg_sel_irq_virtual   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_BPR1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AEOIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AHPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AIAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_VENG1 ));

  assign irq_virtual_access  = ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns & gov_hcr_el2_imo;

  assign irq_cpu_el_valid  = gov_scr_el3_irq                     ? el3_monitor: ( gov_scr_el3_ns  & gov_hcr_el2_imo ) ? ( gov_exception_level >= `CA53_EL2 ): ( gov_exception_level >= `CA53_EL1 );

  // Check the exception level is valid for physical accesses

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_irq  => irq_cpu_el_valid")
  u_ovl_intf_assume_340c9a654aaaefb0a449a460b6dd6c1818b073a7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_irq ),
    .consequent_expr (irq_cpu_el_valid));


  // Register physical encodings should not be used when group 1 registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & irq_virtual_access  => ~sys_reg_sel_irq")
  u_ovl_intf_assume_0705b3fea26d690433468c9289d3ce224b89d71a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & irq_virtual_access ),
    .consequent_expr (~sys_reg_sel_irq));


  // Register virtual encodings should only be used when group 1 registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_irq_virtual  => irq_virtual_access")
  u_ovl_intf_assume_7d0d2b279ac6d35b701a8e7af0d52edb06bf3c33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_irq_virtual ),
    .consequent_expr (irq_virtual_access));


  // All accesses trap at EL1 non-secure when ICH_HCR_EL2.TALL1==1

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( sys_reg_sel_irq | sys_reg_sel_irq_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns  => ~gic_ich_hcr_el2_tall1")
  u_ovl_intf_assume_427ecfe60b8b6f080f95a105ca52c6cc6f296e5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( sys_reg_sel_irq | sys_reg_sel_irq_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns ),
    .consequent_expr (~gic_ich_hcr_el2_tall1));



  // ------------------------------------------------------
  // System registers : Common Group 0 and Group 1
  // ------------------------------------------------------

  // System physical register governed by the routing of FIQ and IRQ
  assign sys_reg_sel_common  = ((cp_gov_addr_sys ==  `CA53_GICCP_GICC_ASGI1R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_CTLR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_DIR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_PMR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_RPR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI0R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI1R_EL1 ));

  // Virtual common system registers
  // NOTE: ICC_ASGI1R_EL1, ICC_SGI0R_EL1, and ICC_SGI1R_EL1 are not virtualized
  assign sys_reg_sel_common_virtual  = ((cp_gov_addr_sys ==  `CA53_GICCP_GICV_CTLR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_DIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_PMR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_RPR ));

  assign common_virtual_access  = fiq_virtual_access | irq_virtual_access;

  // Check the exception level is valid for physical accesses

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_common  => irq_cpu_el_valid | fiq_cpu_el_valid")
  u_ovl_intf_assume_7de192a9a70161f7ee74d839dbc584e6bfac616a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_common ),
    .consequent_expr (irq_cpu_el_valid | fiq_cpu_el_valid));


  // Register physical encodings should not be used when common registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( fiq_virtual_access | irq_virtual_access )  => ~sys_reg_sel_common")
  u_ovl_intf_assume_f554c08c729138c9ae52bdd7f7bf56f03e435862 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( fiq_virtual_access | irq_virtual_access ) ),
    .consequent_expr (~sys_reg_sel_common));


  // Register virtual encodings should only be used when common registers are being virtualized

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & sys_reg_sel_common_virtual  => common_virtual_access")
  u_ovl_intf_assume_6d07e12e81c69961f9936960383349d83edfd86f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & sys_reg_sel_common_virtual ),
    .consequent_expr (common_virtual_access));


  // All accesses trap at EL1 non-secure when ICH_HCR_EL2.TC==1

  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & ( sys_reg_sel_common | sys_reg_sel_common_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns  => ~gic_ich_hcr_el2_tc")
  u_ovl_intf_assume_702aea63b7537612b3a2dfba767affac524e52bd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & ( sys_reg_sel_common | sys_reg_sel_common_virtual ) & ( gov_exception_level == `CA53_EL1 ) & gov_scr_el3_ns ),
    .consequent_expr (~gic_ich_hcr_el2_tc));



  // ------------------------------------------------------
  // System Registers : Misc
  // ------------------------------------------------------

  // System register is defined
  assign sys_reg_sel_all   = ((cp_gov_addr_sys ==  `CA53_GICCP_GICC_AP0R0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_AP1R0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_ASGI1R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_BPR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_BPR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_CTLR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_CTLR_EL3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_DIR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_HPPIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_HPPIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IGRPEN1_EL3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_PMR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_RPR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI0R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI1R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SRE_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SRE_EL2) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SRE_EL3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_APR0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_APR1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_EISR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_ELSR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_HCR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR0_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR1_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR2_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3_H) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_LR3_L) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_MISR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_BPR0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_BPR1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_PMR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_VENG0) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VMCR_VENG1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICH_VTR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AEOIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AHPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AIAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_CTLR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_DIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_EOIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_HPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_IAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_RPR ));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys  => sys_reg_sel_all")
  u_ovl_intf_assume_9bd5423fd6b3fb87e19783d389cf8ca53b2d7e03 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys ),
    .consequent_expr (sys_reg_sel_all));


  // System register is Read Only
  assign cp_gov_addr_sys_ro  = ((cp_gov_addr_sys ==   `CA53_GICCP_GICC_HPPIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_HPPIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_IAR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_RPR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AHPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AIAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_HPPIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_IAR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_RPR ));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & cp_gov_addr_sys_ro  => ~cp_gov_wenable")
  u_ovl_intf_assume_3b3a491a5c502fd282e0e24d7ba98f9a269c2b9a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & cp_gov_addr_sys_ro ),
    .consequent_expr (~cp_gov_wenable));


  // System register is Write Only
  assign cp_gov_addr_sys_wo  = ((cp_gov_addr_sys ==   `CA53_GICCP_GICC_ASGI1R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_DIR_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR0_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_EOIR1_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI0R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICC_SGI1R_EL1) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_AEOIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_DIR) | (cp_gov_addr_sys ==  `CA53_GICCP_GICV_EOIR ));


  assert_implication #(`OVL_FATAL, INOPTIONS, "cp_gic_request_sys & cp_gov_addr_sys_wo  => cp_gov_wenable")
  u_ovl_intf_assume_f9e44c9cad8ab4404c7b59a900717a0404b43715 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_gic_request_sys & cp_gov_addr_sys_wo ),
    .consequent_expr (cp_gov_wenable));





endmodule

`define CA53_UNDEFINE
`include "ca53_gov_dcu_defs.v"
`include "cortexa53params.v"
`include "ca53_gic_gov_defs.v"
`undef CA53_UNDEFINE

`endif

