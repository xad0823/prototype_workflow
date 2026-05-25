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
// and the ETM.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dpu_etm_defs.v"
`include "cortexa53params.v"

module ca53_dpu_etm #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         po_reset_n,
  input         etm_if_en_i,
  input         etm_stall_cpu_i,
  input         gov_wfx_drain_req_i,
  input   [1:0] tlb_d_tcr_el1_tbi_i,
  input         tlb_d_tcr_el2_tbi0_i,
  input         tlb_d_tcr_el3_tbi0_i,
  input         dpu_wpt_valid_i,
  input  [63:1] dpu_wpt_addr_i,
  input  [63:1] dpu_wpt_target_addr_opa_i,
  input  [27:1] dpu_wpt_target_addr_opb_i,
  input         dpu_wpt_advance_i,
  input         dpu_wpt_range_i,
  input   [2:0] dpu_wpt_type_i,
  input         dpu_wpt_link_i,
  input         dpu_wpt_taken_i,
  input   [1:0] dpu_wpt_target_isa_i,
  input         dpu_wpt_t32_nt16_i,
  input   [3:0] dpu_wpt_exception_type_i,
  input         dpu_wpt_non_secure_i,
  input   [3:0] dpu_wpt_exlevel_i,
  input         dpu_wpt_prohibited_i,
  input  [25:0] dpu_pmuevent_i);


  wire         etm_if_en = etm_if_en_i;
  wire         etm_stall_cpu = etm_stall_cpu_i;
  wire         gov_wfx_drain_req = gov_wfx_drain_req_i;
  wire   [1:0] tlb_d_tcr_el1_tbi = tlb_d_tcr_el1_tbi_i;
  wire         tlb_d_tcr_el2_tbi0 = tlb_d_tcr_el2_tbi0_i;
  wire         tlb_d_tcr_el3_tbi0 = tlb_d_tcr_el3_tbi0_i;
  wire         dpu_wpt_valid = dpu_wpt_valid_i;
  wire  [63:1] dpu_wpt_addr = dpu_wpt_addr_i;
  wire  [63:1] dpu_wpt_target_addr_opa = dpu_wpt_target_addr_opa_i;
  wire  [27:1] dpu_wpt_target_addr_opb = dpu_wpt_target_addr_opb_i;
  wire         dpu_wpt_advance = dpu_wpt_advance_i;
  wire         dpu_wpt_range = dpu_wpt_range_i;
  wire   [2:0] dpu_wpt_type = dpu_wpt_type_i;
  wire         dpu_wpt_link = dpu_wpt_link_i;
  wire         dpu_wpt_taken = dpu_wpt_taken_i;
  wire   [1:0] dpu_wpt_target_isa = dpu_wpt_target_isa_i;
  wire         dpu_wpt_t32_nt16 = dpu_wpt_t32_nt16_i;
  wire   [3:0] dpu_wpt_exception_type = dpu_wpt_exception_type_i;
  wire         dpu_wpt_non_secure = dpu_wpt_non_secure_i;
  wire   [3:0] dpu_wpt_exlevel = dpu_wpt_exlevel_i;
  wire         dpu_wpt_prohibited = dpu_wpt_prohibited_i;
  wire  [25:0] dpu_pmuevent = dpu_pmuevent_i;

  wire  [63:1] dpu_wpt_target_addr;
  wire  [63:1] raw_dpu_wpt_target_addr;

  reg         prev_wpt_prohibited;
  reg  [63:1] prev_wpt_target_addr;
  reg   [1:0] prev_wpt_target_isa;
  reg         align_fault;
  reg         prev_wpt_valid;
  reg         prev_wpt_non_secure;
  reg         prev_wpt_target_64;
  reg   [3:0] prev_wpt_exlevel;
  reg         prev_wpt_target_tbit;

  reg         dpu_wpt_valid_reg;
  reg         dpu_wpt_valid_reg_reg;
  reg         dpu_wpt_valid_reg_reg_reg;
  reg   [2:0] dpu_wpt_type_reg;
  reg   [2:0] dpu_wpt_type_reg_reg;
  reg   [2:0] dpu_wpt_type_reg_reg_reg;
  reg         gov_wfx_drain_req_reg;
  reg         gov_wfx_drain_req_reg_reg;

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
  begin
    dpu_wpt_valid_reg <= 1'b0;
    dpu_wpt_valid_reg_reg <= 1'b0;
    dpu_wpt_valid_reg_reg_reg <= 1'b0;
    dpu_wpt_type_reg <= 3'b000;
    dpu_wpt_type_reg_reg <= 3'b000;
    dpu_wpt_type_reg_reg_reg <= 3'b000;
    gov_wfx_drain_req_reg <= 1'b0;
    gov_wfx_drain_req_reg_reg <= 1'b0;
  end
  else
  begin
    gov_wfx_drain_req_reg <= gov_wfx_drain_req;
    gov_wfx_drain_req_reg_reg <= gov_wfx_drain_req_reg;
    dpu_wpt_valid_reg <= dpu_wpt_valid;
    dpu_wpt_valid_reg_reg <= dpu_wpt_valid_reg;
    dpu_wpt_valid_reg_reg_reg <= dpu_wpt_valid_reg_reg;
    dpu_wpt_type_reg <= dpu_wpt_type;
    dpu_wpt_type_reg_reg <= dpu_wpt_type_reg;
    dpu_wpt_type_reg_reg_reg <= dpu_wpt_type_reg_reg;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  //Power control for core's ETM interface, indicating to core that trace is
  //desired 
  //  input         etm_if_en                  valid   always      timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "etm_if_en X or Z")
  u_ovl_intf_x_etm_if_en (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_if_en));

  // Request from ETM to stall DPU pipeline
  //  input         etm_stall_cpu              valid   always      timing 20% wiring 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "etm_stall_cpu X or Z")
  u_ovl_intf_x_etm_stall_cpu (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (etm_stall_cpu));


  //  output        dpu_wpt_valid              valid   always      timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_valid X or Z")
  u_ovl_intf_x_dpu_wpt_valid (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_wpt_valid));

  //  output [63:1] dpu_wpt_addr               valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 63, OUTOPTIONS, "dpu_wpt_addr X or Z")
  u_ovl_intf_x_dpu_wpt_addr (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_addr));

  //  output [63:1] dpu_wpt_target_addr_opa    valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 63, OUTOPTIONS, "dpu_wpt_target_addr_opa X or Z")
  u_ovl_intf_x_dpu_wpt_target_addr_opa (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_target_addr_opa));

  //  output [27:1] dpu_wpt_target_addr_opb    valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 27, OUTOPTIONS, "dpu_wpt_target_addr_opb X or Z")
  u_ovl_intf_x_dpu_wpt_target_addr_opb (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_target_addr_opb));


  //wpt_advance is low if exception is back-to-back with no execution in between.
  //  output        dpu_wpt_advance            valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_advance X or Z")
  u_ovl_intf_x_dpu_wpt_advance (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_advance));


  //wpt_range is low if reset/debug/prohibited since last waypoint
  //  output        dpu_wpt_range              valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_range X or Z")
  u_ovl_intf_x_dpu_wpt_range (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_range));


  //  output [2:0]  dpu_wpt_type               valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dpu_wpt_type X or Z")
  u_ovl_intf_x_dpu_wpt_type (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_type));

  //  output        dpu_wpt_link               valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_link X or Z")
  u_ovl_intf_x_dpu_wpt_link (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_link));

  //  output        dpu_wpt_taken              valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_taken X or Z")
  u_ovl_intf_x_dpu_wpt_taken (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_taken));

   //waypoint  target ISA: 10: A64, 01: T32, 00: A32
  //  output [1:0]  dpu_wpt_target_isa         valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "dpu_wpt_target_isa X or Z")
  u_ovl_intf_x_dpu_wpt_target_isa (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_target_isa));


  // Waypoint instructions size 16 or 32
  //  output        dpu_wpt_t32_nt16           valid   (dpu_wpt_valid & dpu_wpt_link)  timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_t32_nt16 X or Z")
  u_ovl_intf_x_dpu_wpt_t32_nt16 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier ((dpu_wpt_valid & dpu_wpt_link)),
    .test_expr (dpu_wpt_t32_nt16));


  //  output [3:0]  dpu_wpt_exception_type     valid   (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION))   timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_wpt_exception_type X or Z")
  u_ovl_intf_x_dpu_wpt_exception_type (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier ((dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION))),
    .test_expr (dpu_wpt_exception_type));

  // Target is NS state
  //  output        dpu_wpt_non_secure         valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_non_secure X or Z")
  u_ovl_intf_x_dpu_wpt_non_secure (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_non_secure));


  //  output [3:0]  dpu_wpt_exlevel            valid   dpu_wpt_valid   timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_wpt_exlevel X or Z")
  u_ovl_intf_x_dpu_wpt_exlevel (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (dpu_wpt_valid),
    .test_expr (dpu_wpt_exlevel));

  //Core is executing in prohibited region, this signal only change its state
  //when dpu_wpt_valid is valid
  //  output        dpu_wpt_prohibited         valid   always      timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dpu_wpt_prohibited X or Z")
  u_ovl_intf_x_dpu_wpt_prohibited (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_wpt_prohibited));


  //  output [25:0] dpu_pmuevent               valid   always      timing 50%

  assert_never_unknown #(`OVL_FATAL, 26, OUTOPTIONS, "dpu_pmuevent X or Z")
  u_ovl_intf_x_dpu_pmuevent (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_pmuevent));



  // ------------------------------------------------------
  // Interface description
  // ------------------------------------------------------

  // waypoint type




   // Exception types



  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // EL1 TBI is a two bit signal giving TCR_EL1.{TBI1,TBI0},

  // DPU presents target address as two components which should be added together
  assign raw_dpu_wpt_target_addr  = (dpu_wpt_target_addr_opa[63:1] +  { {37{dpu_wpt_target_addr_opb[27]}}, dpu_wpt_target_addr_opb[26:1]});

  assign dpu_wpt_target_addr  =  ~dpu_wpt_target_isa[1]                                                        ? { {32{1'b0}}, raw_dpu_wpt_target_addr[31:1]} : ( dpu_wpt_exlevel[3]   & tlb_d_tcr_el3_tbi0)                                  ? {  {8{1'b0}}, raw_dpu_wpt_target_addr[55:1]} : ( dpu_wpt_exlevel[2]   & tlb_d_tcr_el2_tbi0)                                  ? {  {8{1'b0}}, raw_dpu_wpt_target_addr[55:1]} : (|dpu_wpt_exlevel[1:0] & tlb_d_tcr_el1_tbi[1] &  raw_dpu_wpt_target_addr[55]) ? {  {8{1'b1}}, raw_dpu_wpt_target_addr[55:1]} : (|dpu_wpt_exlevel[1:0] & tlb_d_tcr_el1_tbi[0] & ~raw_dpu_wpt_target_addr[55]) ? {  {8{1'b0}}, raw_dpu_wpt_target_addr[55:1]} : raw_dpu_wpt_target_addr[63:1];

  // Store properties of the previous waypoint

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_target_tbit <= 1'b0;
  else if (dpu_wpt_valid)
    prev_wpt_target_tbit <= dpu_wpt_target_isa[0];


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_target_64 <= 1'b0;
  else if (dpu_wpt_valid)
    prev_wpt_target_64 <= dpu_wpt_target_isa[1];


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_target_isa <= 2'b00;
  else if (dpu_wpt_valid)
    prev_wpt_target_isa <= dpu_wpt_target_isa;


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_target_addr <= {63{1'b0}};
  else if (dpu_wpt_valid)
    prev_wpt_target_addr <= dpu_wpt_target_addr;


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_prohibited <= 1'b0;
  else if (dpu_wpt_valid)
    prev_wpt_prohibited <= dpu_wpt_prohibited;


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_non_secure <= 1'b0;
  else if (dpu_wpt_valid)
    prev_wpt_non_secure <= dpu_wpt_non_secure;


  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_exlevel <= 4'b0000;
  else if (dpu_wpt_valid)
    prev_wpt_exlevel <= dpu_wpt_exlevel;

// This is used to help checking across sequences where wpt_range is low.

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    prev_wpt_valid <= 1'b0;
  else if (dpu_wpt_valid)
    prev_wpt_valid <= 1'b1;


  // wpt_type must be a valid type

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid  => dpu_wpt_type in     [`CA53_ETM_WPT_DIRECTBRANCH, `CA53_ETM_WPT_INDIRECT, `CA53_ETM_WPT_EXCEPTION, `CA53_ETM_WPT_ISB, `CA53_ETM_WPT_DBGENTRY, `CA53_ETM_WPT_DBGEXIT, `CA53_ETM_WPT_EXCP_RETURN]")
  u_ovl_intf_assert_7a2c08b0b642361a08bf35e11bd69d4a45e92029 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid ),
    .consequent_expr (((dpu_wpt_type == `CA53_ETM_WPT_DIRECTBRANCH) | (dpu_wpt_type ==  `CA53_ETM_WPT_INDIRECT) | (dpu_wpt_type ==  `CA53_ETM_WPT_EXCEPTION) | (dpu_wpt_type ==  `CA53_ETM_WPT_ISB) | (dpu_wpt_type ==  `CA53_ETM_WPT_DBGENTRY) | (dpu_wpt_type ==  `CA53_ETM_WPT_DBGEXIT) | (dpu_wpt_type ==  `CA53_ETM_WPT_EXCP_RETURN))));



  // Exception type must be a valid type

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)  => dpu_wpt_exception_type in [`CA53_ETM_RESET_EXCP, `CA53_ETM_CALL_EXCP, `CA53_ETM_TRAP_EXCP, `CA53_ETM_SYS_ERR_EXCP, `CA53_ETM_INST_DEBUG_EXCP, `CA53_ETM_DATA_DEBUG_EXCP, `CA53_ETM_ALIGN_EXCP, `CA53_ETM_INST_FAULT_EXCP, `CA53_ETM_DATA_FAULT_EXCP, `CA53_ETM_IRQ_EXCP, `CA53_ETM_FIQ_EXCP]")
  u_ovl_intf_assert_f48c9f9d6a3b1fbe7a8dd29e994efe654aa72bc3 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) ),
    .consequent_expr (((dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_CALL_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_TRAP_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_SYS_ERR_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_INST_DEBUG_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_DATA_DEBUG_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_ALIGN_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_INST_FAULT_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_DATA_FAULT_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_IRQ_EXCP) | (dpu_wpt_exception_type ==  `CA53_ETM_FIQ_EXCP))));


  // When core is asserting gov_wfx_drain_req, waypoint should not be valid
  // and also for 2 cycles before (req goes through governor)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_wfx_drain_req   => ~dpu_wpt_valid")
  u_ovl_intf_assert_aba070dce185c8bc58286723bcdf97f578fe0fe4 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_wfx_drain_req  ),
    .consequent_expr (~dpu_wpt_valid));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_wfx_drain_req   => ~dpu_wpt_valid@1")
  u_ovl_intf_assert_03a098368237e004828a7053c3c8057e8e19088b (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_wfx_drain_req  ),
    .consequent_expr (~dpu_wpt_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "gov_wfx_drain_req   => ~dpu_wpt_valid@2")
  u_ovl_intf_assert_e2cde17bda7df75421cc94fb350876a53ef345ce (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (gov_wfx_drain_req  ),
    .consequent_expr (~dpu_wpt_valid_reg_reg));


  // When core is asserting dpu_wpt_valid, wfx_req must be low
  // for 2 previous cycles  (req goes through governor)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid  => ~gov_wfx_drain_req@1")
  u_ovl_intf_assert_dfe9685ccd10e65968d9733548bfbdf349802549 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid ),
    .consequent_expr (~gov_wfx_drain_req_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid  => ~gov_wfx_drain_req@2")
  u_ovl_intf_assert_4ed91ea013f54210f04d2c4cfac7fef55ca8e13f (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid ),
    .consequent_expr (~gov_wfx_drain_req_reg_reg));


  // exception level is one hot
  // EL3 to EL0, wpt_exlevel[3] to EL3, wpt_exlevel[0] to EL0

  assert_one_hot #(`OVL_FATAL, 4, OUTOPTIONS, "dpu_wpt_exlevel")
  u_ovl_intf_assert_04b47822e692cfdeddbef9b447f03704e3a1c2b7 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .test_expr (dpu_wpt_exlevel));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY)   => (dpu_wpt_exception_type == `CA53_ETM_DEBUG_HALT)")
  u_ovl_intf_assert_3d67226442327914830481c0e98100abb5b6b6ad (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY)  ),
    .consequent_expr ((dpu_wpt_exception_type == `CA53_ETM_DEBUG_HALT)));



// From debug entry to debug exit, a minimum of 3 cycles is required

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT)  => ~(dpu_wpt_valid@1 & (dpu_wpt_type@1 == `CA53_ETM_WPT_DBGENTRY))")
  u_ovl_intf_assert_783b8fddfd2067d6dac0dbb1cba1d9472d9b736d (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT) ),
    .consequent_expr (~(dpu_wpt_valid_reg & (dpu_wpt_type_reg == `CA53_ETM_WPT_DBGENTRY))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT)  => ~(dpu_wpt_valid@2 & (dpu_wpt_type@2 == `CA53_ETM_WPT_DBGENTRY))")
  u_ovl_intf_assert_994a1d21db7384e5d45ccd13a8a626592ad2badb (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT) ),
    .consequent_expr (~(dpu_wpt_valid_reg_reg & (dpu_wpt_type_reg_reg == `CA53_ETM_WPT_DBGENTRY))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT)  => ~(dpu_wpt_valid@3 & (dpu_wpt_type@3 == `CA53_ETM_WPT_DBGENTRY))")
  u_ovl_intf_assert_62cbf500574b1bbe03b65434f0771eb042436db7 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT) ),
    .consequent_expr (~(dpu_wpt_valid_reg_reg_reg & (dpu_wpt_type_reg_reg_reg == `CA53_ETM_WPT_DBGENTRY))));


  // After an exception, minimum of 2 cycles before another waypoint is seen

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid  => ~(dpu_wpt_valid@1 & (dpu_wpt_type@1 == `CA53_ETM_WPT_EXCEPTION))")
  u_ovl_intf_assert_8db63c2989439b4b9184931debeb3344d8e38a55 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid ),
    .consequent_expr (~(dpu_wpt_valid_reg & (dpu_wpt_type_reg == `CA53_ETM_WPT_EXCEPTION))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid  => ~(dpu_wpt_valid@2 & (dpu_wpt_type@2 == `CA53_ETM_WPT_EXCEPTION))")
  u_ovl_intf_assert_848d5a1935e49ae75cd0522af4f3be1aaeeefe14 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid ),
    .consequent_expr (~(dpu_wpt_valid_reg_reg & (dpu_wpt_type_reg_reg == `CA53_ETM_WPT_EXCEPTION))));


  //When ETM acknoledge the WFx request, ATVALID must be low, AFREADY must be
  //high

  // Behaviors for wpt is prohibit or debug entry
  // wpt_target_addr is zero if wpt_type is 'proh/debug entry'

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY) & dpu_wpt_valid  => |dpu_wpt_target_addr == 1'b0")
  u_ovl_intf_assert_641cc97c52bf5c4033348255e917930f73adc5dc (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr ((dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY) & dpu_wpt_valid ),
    .consequent_expr (|dpu_wpt_target_addr == 1'b0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_prohibited & dpu_wpt_valid  => |dpu_wpt_target_addr == 1'b0")
  u_ovl_intf_assert_e4782c3b0aff849041cde9af7af8d5d36a3f14de (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_prohibited & dpu_wpt_valid ),
    .consequent_expr (|dpu_wpt_target_addr == 1'b0));

  // dpu_wpt_range is low if proh/debug entry since last way point

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid & prev_wpt_prohibited  => (dpu_wpt_range == 1'b0)")
  u_ovl_intf_assert_19e1b374d70d1c0f0420abb2990d79bff1a5c4cb (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid & prev_wpt_prohibited ),
    .consequent_expr ((dpu_wpt_range == 1'b0)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid &  (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT) => (dpu_wpt_range == 1'b0)")
  u_ovl_intf_assert_fbfa15770e4ef638fdeb081c0fd289be084527d7 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid &  (dpu_wpt_type == `CA53_ETM_WPT_DBGEXIT)),
    .consequent_expr ((dpu_wpt_range == 1'b0)));

  // first addresss after prohibited region should be 0

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid & prev_wpt_prohibited  => (|dpu_wpt_addr == 1'b0)")
  u_ovl_intf_assert_9f2c8a02c3e164059d9444e5ba38853a42ac30ea (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid & prev_wpt_prohibited ),
    .consequent_expr ((|dpu_wpt_addr == 1'b0)));




  // wpt_t32_nt16 must be set if previous target ISA is ARM state and current
  // waypoint is link

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~prev_wpt_target_tbit & prev_wpt_valid & dpu_wpt_valid & dpu_wpt_link & dpu_wpt_range  => dpu_wpt_t32_nt16")
  u_ovl_intf_assert_77dee909c41074744f33b2b14fa8d01efe4ac34b (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (~prev_wpt_target_tbit & prev_wpt_valid & dpu_wpt_valid & dpu_wpt_link & dpu_wpt_range ),
    .consequent_expr (dpu_wpt_t32_nt16));



  // wpt_addr[1] is zero unless previous wpt target was Thumb (unless this is an anlignment fault)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid & ~prev_wpt_target_tbit & dpu_wpt_range & (dpu_wpt_type != `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_type != `CA53_ETM_WPT_DBGENTRY)  => dpu_wpt_addr[1] == 1'b0")
  u_ovl_intf_assert_86468298255d50063170ec49c11d6a7af0ed3c6f (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid & ~prev_wpt_target_tbit & dpu_wpt_range & (dpu_wpt_type != `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_type != `CA53_ETM_WPT_DBGENTRY) ),
    .consequent_expr (dpu_wpt_addr[1] == 1'b0));


  // wpt_addr[63:32] must be 0 in A32/T32

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid & ((prev_wpt_target_isa[1:0]== 2'b00) | (prev_wpt_target_isa[1:0]== 2'b01))  => dpu_wpt_addr[63:32] == 32'h00000000")
  u_ovl_intf_assert_59278ba98125cd1c30f36152d876eda6ff2d036c (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid & ((prev_wpt_target_isa[1:0]== 2'b00) | (prev_wpt_target_isa[1:0]== 2'b01)) ),
    .consequent_expr (dpu_wpt_addr[63:32] == 32'h00000000));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & prev_wpt_valid & ((dpu_wpt_target_isa[1:0]== 2'b00) | (dpu_wpt_target_isa[1:0]== 2'b01))  => dpu_wpt_target_addr[63:32] == 32'h00000000")
  u_ovl_intf_assert_d257d6d1466ee85361014a7cadef0dfbca8d9127 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & prev_wpt_valid & ((dpu_wpt_target_isa[1:0]== 2'b00) | (dpu_wpt_target_isa[1:0]== 2'b01)) ),
    .consequent_expr (dpu_wpt_target_addr[63:32] == 32'h00000000));




  // Alignment fault from bad target address in A64 (and remain in A64)

  always @(posedge clk or negedge po_reset_n)
  if (~po_reset_n)
    align_fault <= 1'b0;
  else if (dpu_wpt_valid)
    align_fault <= prev_wpt_target_64 & dpu_wpt_target_isa[1] & (~( (dpu_wpt_target_addr[63:48] == 16'h0000) | ((dpu_wpt_target_addr[63:48] == 16'hFFFF) & |dpu_wpt_exlevel[1:0])) | dpu_wpt_target_addr[1]);


  // An exception must be generated after a branch to a bad address - either
  // an alignment abort or prefetch abort (depending on the address), or
  // another exception pre-empting the abort

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & align_fault & dpu_wpt_range  => (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) | (dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY)")
  u_ovl_intf_assert_ca74c7b3b9d6c8cbf12d59ab8f3c0191af54f4dc (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & align_fault & dpu_wpt_range ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) | (dpu_wpt_type == `CA53_ETM_WPT_DBGENTRY)));


  // Alignment fault exception is only used when the exception is taken in AArch64

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_ALIGN_EXCP) & ~dpu_wpt_prohibited  => dpu_wpt_target_isa[1]")
  u_ovl_intf_assert_5d965bcf9ba40ec44f63ec4e1516ab2797ac7710 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_ALIGN_EXCP) & ~dpu_wpt_prohibited ),
    .consequent_expr (dpu_wpt_target_isa[1]));


  // Debug exception types are only used when the exception is taken in AArch64

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_INST_DEBUG_EXCP) & ~dpu_wpt_prohibited  => dpu_wpt_target_isa[1]")
  u_ovl_intf_assert_e252aaa169ca56b0a9dfcce6168a7cefd5bca1ec (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_INST_DEBUG_EXCP) & ~dpu_wpt_prohibited ),
    .consequent_expr (dpu_wpt_target_isa[1]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_DATA_DEBUG_EXCP) & ~dpu_wpt_prohibited  => dpu_wpt_target_isa[1]")
  u_ovl_intf_assert_152e70c25011f7264563845e8745d9318eaa5451 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_DATA_DEBUG_EXCP) & ~dpu_wpt_prohibited ),
    .consequent_expr (dpu_wpt_target_isa[1]));


  // wpt_addr is zero if wpt is reset exception

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP)  => |dpu_wpt_addr == 1'b0")
  u_ovl_intf_assert_a8a5be933975eeb91ab1d2796dfff4c82a6085c6 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP) ),
    .consequent_expr (|dpu_wpt_addr == 1'b0));


  // wpt_range is zero if wpt is reset exception

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP)  => dpu_wpt_range == 1'b0")
  u_ovl_intf_assert_aa690a4dfc3cb877979a71e4db476a7f0c75c138 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP) ),
    .consequent_expr (dpu_wpt_range == 1'b0));


  // wpt_advance is zero if wpt is reset exception

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP)  => dpu_wpt_advance == 1'b0")
  u_ovl_intf_assert_99b72080f0551a049b54148d3ab9f3ac728d8c1b (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exception_type == `CA53_ETM_RESET_EXCP) ),
    .consequent_expr (dpu_wpt_advance == 1'b0));



  //wpt_link is set only for branch 

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_link   => ((dpu_wpt_type == `CA53_ETM_WPT_DIRECTBRANCH) | (dpu_wpt_type == `CA53_ETM_WPT_INDIRECT))")
  u_ovl_intf_assert_b74cbc3a6c951449915dfa7b806b68103a6290d0 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_link  ),
    .consequent_expr (((dpu_wpt_type == `CA53_ETM_WPT_DIRECTBRANCH) | (dpu_wpt_type == `CA53_ETM_WPT_INDIRECT))));


  //wpt_link must not be set for the first waypoint out of a prohibited region

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "prev_wpt_prohibited & prev_wpt_valid & dpu_wpt_valid  => ~dpu_wpt_link")
  u_ovl_intf_assert_8ef6062427972137a0686cec50abc082820f7051 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (prev_wpt_prohibited & prev_wpt_valid & dpu_wpt_valid ),
    .consequent_expr (~dpu_wpt_link));


  //when wpt_prohibited is valid, only one wpt_valid can be generated (for
  //prohibited entry): 

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_prohibited & dpu_wpt_valid  => ~prev_wpt_prohibited")
  u_ovl_intf_assert_a06ca0d44fa8843362eec2469d079624619468ca (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_prohibited & dpu_wpt_valid ),
    .consequent_expr (~prev_wpt_prohibited));


  //wpt_taken must be set except for branch/ISB (which can be set or not set)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & ((dpu_wpt_type != `CA53_ETM_WPT_DIRECTBRANCH) & (dpu_wpt_type != `CA53_ETM_WPT_INDIRECT) & (dpu_wpt_type != `CA53_ETM_WPT_EXCP_RETURN) & (dpu_wpt_type != `CA53_ETM_WPT_ISB))   => dpu_wpt_taken")
  u_ovl_intf_assert_549434c6accf76b70197873a9f41ebe1d8548a65 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & ((dpu_wpt_type != `CA53_ETM_WPT_DIRECTBRANCH) & (dpu_wpt_type != `CA53_ETM_WPT_INDIRECT) & (dpu_wpt_type != `CA53_ETM_WPT_EXCP_RETURN) & (dpu_wpt_type != `CA53_ETM_WPT_ISB))  ),
    .consequent_expr (dpu_wpt_taken));


  // Consecutive waypoints without intervening execution should have matching source/target addresses, or vice versa (for exception)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & ~dpu_wpt_advance  => prev_wpt_target_addr == dpu_wpt_addr")
  u_ovl_intf_assert_aa08ab9ea1d6547dd6774029d754f35873706da5 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & ~dpu_wpt_advance ),
    .consequent_expr (prev_wpt_target_addr == dpu_wpt_addr));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & (prev_wpt_target_addr == dpu_wpt_addr) & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)   => ~dpu_wpt_advance")
  u_ovl_intf_assert_b8de18d2890b7b70a563ef58ad59561b96f683b0 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & (prev_wpt_target_addr == dpu_wpt_addr) & (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)  ),
    .consequent_expr (~dpu_wpt_advance));


  // Can only transition non-secure to secure via an exception to EL3

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & prev_wpt_non_secure & ~dpu_wpt_non_secure   => (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exlevel == 4'b1000)")
  u_ovl_intf_assert_e918eb8f90c9506f00aca811ce611487e5baf257 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & prev_wpt_non_secure & ~dpu_wpt_non_secure  ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION) & (dpu_wpt_exlevel == 4'b1000)));


  // In AArch64, can only transition secure to non-secure via an exception return from EL3

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & ~prev_wpt_non_secure & dpu_wpt_non_secure & prev_wpt_target_64   => (dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN) & (prev_wpt_exlevel == 4'b1000)")
  u_ovl_intf_assert_06ad2c0228cba2bc1656cd219aab86d534f96206 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & prev_wpt_valid & ~prev_wpt_non_secure & dpu_wpt_non_secure & prev_wpt_target_64  ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN) & (prev_wpt_exlevel == 4'b1000)));


  // Can only increase exception level due to an exception

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & (prev_wpt_exlevel < dpu_wpt_exlevel)   => (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)")
  u_ovl_intf_assert_cca31a7d79801b0fed0a8207195e36fc33060042 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & (prev_wpt_exlevel < dpu_wpt_exlevel)  ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)));


  // In AArch64, can only decrease exception level due to an exception return

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & (prev_wpt_exlevel > dpu_wpt_exlevel) & prev_wpt_target_64  => (dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN)")
  u_ovl_intf_assert_658bbdf2b47be61517991f042b9cf26522572ce3 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & (prev_wpt_exlevel > dpu_wpt_exlevel) & prev_wpt_target_64 ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN)));


  // Can only transition from AArch32 to AArch64 due to an exception

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~prev_wpt_target_64 & dpu_wpt_target_isa[1]   => (dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)")
  u_ovl_intf_assert_83934f5f71a74811c3e7d928f36d53f4b97c213a (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~prev_wpt_target_64 & dpu_wpt_target_isa[1]  ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCEPTION)));


  // Can only transition from AArch64 to AArch32 due to an exception return

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & prev_wpt_target_64 & ~dpu_wpt_target_isa[1]  => (dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN)")
  u_ovl_intf_assert_f4e1e57a32f2de63ebd2e9cd38d4352f82504354 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & prev_wpt_target_64 & ~dpu_wpt_target_isa[1] ),
    .consequent_expr ((dpu_wpt_type == `CA53_ETM_WPT_EXCP_RETURN)));


  //For changing the ISA type, the wpt must be a taken wpt.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken   => dpu_wpt_target_isa == prev_wpt_target_isa")
  u_ovl_intf_assert_d04af5ae55ceebb15ca5c5084d8232a27cf1128f (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken  ),
    .consequent_expr (dpu_wpt_target_isa == prev_wpt_target_isa));


  //Instruction address can only increase by the size indicated by the ISA for
  //not taken way point for A64                                         

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & prev_wpt_target_isa[1]  => dpu_wpt_target_addr == (dpu_wpt_addr + 63'h2)")
  u_ovl_intf_assert_f6aba020a175e21c0a0b2b5da98dd41ccd8569b3 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & prev_wpt_target_isa[1] ),
    .consequent_expr (dpu_wpt_target_addr == (dpu_wpt_addr + 63'h2)));

  //for A32:

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[1:0] == 2'b00)  => dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h2)")
  u_ovl_intf_assert_a62f1ab5fac24245ed4b1813a584bbfecbfeb1d4 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[1:0] == 2'b00) ),
    .consequent_expr (dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h2)));

  //for Thumb, only check the situation for wpt_link is valid

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[0])  & dpu_wpt_link & dpu_wpt_t32_nt16  => dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h2)")
  u_ovl_intf_assert_503ec3506fd700cfd01b93774e4f34b10ac6524e (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[0])  & dpu_wpt_link & dpu_wpt_t32_nt16 ),
    .consequent_expr (dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h2)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[0])  & dpu_wpt_link & ~dpu_wpt_t32_nt16  => dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h1)")
  u_ovl_intf_assert_3b9af9ddbd626cd584e35a6d96af1f2773a6da77 (
    .clk       (clk),
    .reset_n   (po_reset_n),
    .antecedent_expr (dpu_wpt_valid & dpu_wpt_range & ~dpu_wpt_prohibited & prev_wpt_valid & ~dpu_wpt_taken & (prev_wpt_target_isa[0])  & dpu_wpt_link & ~dpu_wpt_t32_nt16 ),
    .consequent_expr (dpu_wpt_target_addr[31:1] == (dpu_wpt_addr[31:1] + 31'h1)));





endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dpu_etm_defs.v"
`undef CA53_UNDEFINE

`endif

