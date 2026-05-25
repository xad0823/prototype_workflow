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

// This is the specification for the interface between the DCU and IFU for CP15
// cache maintenance and debug operations, and MBIST data.
// The DCU accepts and arbitrates requests from the DPU and the SCU, and passes
// the relevant operations on to the IFU for execution.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dcu_ifu_defs.v"
`include "cortexa53params.v"

module ca53_dcu_ifu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [2:0] ifu_outstanding_lfb_i,
  input         ifu_cp_ack_i,
  input         ifu_valid_if2_i,
  input         dpu_kill_wr_i,
  input         gov_mbist_req_i,
  input         dcu_cp_valid_ifu_i,
  input         dcu_dvm_valid_ifu_i,
  input   [2:0] dcu_cp_op_ifu_i,
  input  [39:0] dcu_cp_addr_ifu_i,
  input         dcu_cp_ns_i);


  wire   [2:0] ifu_outstanding_lfb = ifu_outstanding_lfb_i;
  wire         ifu_cp_ack = ifu_cp_ack_i;
  wire         ifu_valid_if2 = ifu_valid_if2_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire         gov_mbist_req = gov_mbist_req_i;
  wire         dcu_cp_valid_ifu = dcu_cp_valid_ifu_i;
  wire         dcu_dvm_valid_ifu = dcu_dvm_valid_ifu_i;
  wire   [2:0] dcu_cp_op_ifu = dcu_cp_op_ifu_i;
  wire  [39:0] dcu_cp_addr_ifu = dcu_cp_addr_ifu_i;
  wire         dcu_cp_ns = dcu_cp_ns_i;

  wire         cp_or_dvm_valid_ifu;
  wire         mbist_req;
  wire         ifu_op;

  reg         out_of_reset;

  reg         cp_or_dvm_valid_ifu_reg;
  reg         ifu_cp_ack_reg;
  reg         dcu_cp_valid_ifu_reg;
  reg         dpu_kill_wr_reg;
  reg         dcu_cp_ns_reg;
  reg  [39:0] dcu_cp_addr_ifu_reg;
  reg   [2:0] dcu_cp_op_ifu_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    cp_or_dvm_valid_ifu_reg <= 1'b0;
    ifu_cp_ack_reg <= 1'b0;
    dcu_cp_valid_ifu_reg <= 1'b0;
    dpu_kill_wr_reg <= 1'b0;
    dcu_cp_ns_reg <= 1'b0;
    dcu_cp_addr_ifu_reg <= {40{1'b0}};
    dcu_cp_op_ifu_reg <= 3'b000;
  end
  else
  begin
    ifu_cp_ack_reg <= ifu_cp_ack;
    dpu_kill_wr_reg <= dpu_kill_wr;
    dcu_cp_valid_ifu_reg <= dcu_cp_valid_ifu;
    dcu_cp_op_ifu_reg <= dcu_cp_op_ifu;
    dcu_cp_addr_ifu_reg <= dcu_cp_addr_ifu;
    dcu_cp_ns_reg <= dcu_cp_ns;
    cp_or_dvm_valid_ifu_reg <= cp_or_dvm_valid_ifu;
  end



  //-----------------------------------------------------------------------------
  //
  // CP15 interface
  //
  //-----------------------------------------------------------------------------

  // The cp_valid signal initiates a new cp maintenance or debug operation, caused
  // by a local CP15 instruction.
  // A new request may start at any time, including when the cache is off.
  // There may be ongoing accesses and linefills at the time of the request, and
  // it is the IFU's responsibility to synchronise the request with them.
  //  output dcu_cp_valid_ifu valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_valid_ifu X or Z")
  u_ovl_intf_x_dcu_cp_valid_ifu (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_valid_ifu));


  // The IFU has outstanding accesses for an IFU request.
  // Each bit reppresent one of the LFB control logic. Each LFB control logic is capable
  // to set a BIU request. This signal will be set the cycle after IFU_ARVALID goes high
  // and it will be clear the cycle after the last data beat arrives.
  //  input [2:0] ifu_outstanding_lfb valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ifu_outstanding_lfb X or Z")
  u_ovl_intf_x_ifu_outstanding_lfb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_outstanding_lfb));


  // The dvm_valid signal initiates a new cp maintenance operation caused by a
  // DVM operation.
  //  output dcu_dvm_valid_ifu valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_dvm_valid_ifu X or Z")
  u_ovl_intf_x_dcu_dvm_valid_ifu (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_dvm_valid_ifu));


  // The DCU should never send local and DVM operations at the same time.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "!(dcu_cp_valid_ifu & dcu_dvm_valid_ifu)")
  u_ovl_intf_assert_cb5b972ccf28fa5dafdab81705d6845d45423997 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (!(dcu_cp_valid_ifu & dcu_dvm_valid_ifu)));



  assign cp_or_dvm_valid_ifu  = ((dcu_cp_valid_ifu & ~dpu_kill_wr) | dcu_dvm_valid_ifu) & ~gov_mbist_req;



  // The CP15 maintenance operation being performed.
  //  output [2:0] dcu_cp_op_ifu valid cp_or_dvm_valid_ifu timing 50%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dcu_cp_op_ifu X or Z")
  u_ovl_intf_x_dcu_cp_op_ifu (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_or_dvm_valid_ifu),
    .test_expr (dcu_cp_op_ifu));


  assign ifu_op  = ((dcu_cp_op_ifu == `CA53_CP_ICACHE_INV_ALL) | (dcu_cp_op_ifu ==  `CA53_CP_ICACHE_INV_MVA) | (dcu_cp_op_ifu ==  `CA53_CP_ICACHE_INV_VA) | (dcu_cp_op_ifu ==  `CA53_CP_ICACHE_INV_PA) | (dcu_cp_op_ifu ==  `CA53_CP_ICACHE_DBG_TAG) | (dcu_cp_op_ifu ==  `CA53_CP_ICACHE_DBG_DATA));

  // A cp 15 request to the IFU implies that ifu_op is true

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu  => ifu_op")
  u_ovl_intf_assert_5e6dd1149f3258ff5c8c2603bc70a2fef0af0877 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu ),
    .consequent_expr (ifu_op));


  // The addresses or index to use for the operation.
  // For invalidate by MVA:
  // bits [39:15] are the physical address
  // bits [14:6]  are the virtual address
  // bits [5:3]   not used
  // bits [2:0]   are bits [14:12] of the physical address
  // For invalidate by VA:
  // bits [14:6]  are the virtual address
  // bits [5:0]   not used
  // For invalidate by PA:
  // bits [39:15] are the physical address
  // bots [14:12] not used
  // bits [11:6]  are the virtual address (physical == virtual)
  // bits [5:3]   not used
  // bits [2:0]   are bits [14:12] of the physical address
  // For cache debug reads:
  // bit  [31]   is the way
  // bits [14:6] are the index
  // bits [5:2]  are the offset within the line (data read only)
  //  output [39:0] dcu_cp_addr_ifu valid (cp_or_dvm_valid_ifu & (dcu_cp_op_ifu != `CA53_CP_ICACHE_INV_ALL)) timing 60%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "dcu_cp_addr_ifu X or Z")
  u_ovl_intf_x_dcu_cp_addr_ifu (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((cp_or_dvm_valid_ifu & (dcu_cp_op_ifu != `CA53_CP_ICACHE_INV_ALL))),
    .test_expr (dcu_cp_addr_ifu));


  // The TrustZone non-secure bit of the cp op.
  //  output dcu_cp_ns valid cp_or_dvm_valid_ifu timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_ns X or Z")
  u_ovl_intf_x_dcu_cp_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (cp_or_dvm_valid_ifu),
    .test_expr (dcu_cp_ns));


  // Debug operation must be in secure mode

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu & dcu_cp_op_ifu == `CA53_CP_ICACHE_DBG_TAG   => ~dcu_cp_ns")
  u_ovl_intf_assert_445368c7efabc0bd205a423497958c5e6dbcef46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu & dcu_cp_op_ifu == `CA53_CP_ICACHE_DBG_TAG  ),
    .consequent_expr (~dcu_cp_ns));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu & dcu_cp_op_ifu == `CA53_CP_ICACHE_DBG_DATA  => ~dcu_cp_ns")
  u_ovl_intf_assert_24f75c7715fbea8e2c3a2be8337942a5d26dae2c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu & dcu_cp_op_ifu == `CA53_CP_ICACHE_DBG_DATA ),
    .consequent_expr (~dcu_cp_ns));


  // Acknowledge from the IFU that the requested operation has been accepted.
  //  input ifu_cp_ack valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_cp_ack X or Z")
  u_ovl_intf_x_ifu_cp_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_cp_ack));


  // The type of maintenance operation must remain constant throughout the request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu@1 & ~ifu_cp_ack@1 & ~gov_mbist_req  => dcu_cp_op_ifu == dcu_cp_op_ifu@1")
  u_ovl_intf_assert_8a2dbcd7169b0be4df3cfc86f6b1007b74b8be9d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu_reg & ~ifu_cp_ack_reg & ~gov_mbist_req ),
    .consequent_expr (dcu_cp_op_ifu == dcu_cp_op_ifu_reg));


  // The address/index must remain constant throughout the request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu@1 & ~ifu_cp_ack@1 & ~gov_mbist_req  & (dcu_cp_op_ifu != `CA53_CP_ICACHE_INV_ALL)  => dcu_cp_addr_ifu == dcu_cp_addr_ifu@1")
  u_ovl_intf_assert_a0763e0cd02dc765ac893cb9d8499cf2bff5daee (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu_reg & ~ifu_cp_ack_reg & ~gov_mbist_req  & (dcu_cp_op_ifu != `CA53_CP_ICACHE_INV_ALL) ),
    .consequent_expr (dcu_cp_addr_ifu == dcu_cp_addr_ifu_reg));


  // The non-secure bit must remain constant throughout the request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu@1 & ~ifu_cp_ack@1 & ~gov_mbist_req  => dcu_cp_ns == dcu_cp_ns@1")
  u_ovl_intf_assert_4a6460f16b109e1338820047d9fffcd3f864f692 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu_reg & ~ifu_cp_ack_reg & ~gov_mbist_req ),
    .consequent_expr (dcu_cp_ns == dcu_cp_ns_reg));


  // The request must remain high until the ack is recieved.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "cp_or_dvm_valid_ifu@1 & ~ifu_cp_ack@1 & ~gov_mbist_req  => cp_or_dvm_valid_ifu")
  u_ovl_intf_assert_b9db5c5fef6d378219c1e5a320044474539b0d14 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (cp_or_dvm_valid_ifu_reg & ~ifu_cp_ack_reg & ~gov_mbist_req ),
    .consequent_expr (cp_or_dvm_valid_ifu));


  // The ack must only be asserted in response to a request to the IFU.

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_cp_ack & ~gov_mbist_req  => cp_or_dvm_valid_ifu")
  u_ovl_intf_assume_2b989c32418b00938a54ffe8202811284cd81c1e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_cp_ack & ~gov_mbist_req ),
    .consequent_expr (cp_or_dvm_valid_ifu));


  // Ack must only be high for a single cycle.

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_cp_ack@1  => ~ifu_cp_ack")
  u_ovl_intf_assume_342d2407005a3a62628ae013987cfa7e847da02b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_cp_ack_reg ),
    .consequent_expr (~ifu_cp_ack));


  // if a local cp15 op has started dpu_kill should never be seen

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_valid_ifu & dcu_cp_valid_ifu@1  => ~dpu_kill_wr")
  u_ovl_intf_assert_49637b59cb51dab1627eb32d907e1bc58a6f9409 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_valid_ifu & dcu_cp_valid_ifu_reg ),
    .consequent_expr (~dpu_kill_wr));


  // if a local cp15 has arrived with a kill it should be low next cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_valid_ifu@1 & dpu_kill_wr@1 & ~gov_mbist_req  => ~dcu_cp_valid_ifu")
  u_ovl_intf_assert_5aa7f8accf133bca8290caffec81fa6361bf2d6c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_valid_ifu_reg & dpu_kill_wr_reg & ~gov_mbist_req ),
    .consequent_expr (~dcu_cp_valid_ifu));


  //-----------------------------------------------------------------------------
  //
  // MBIST interface
  //
  //-----------------------------------------------------------------------------

  // with the address containing the following encodings
  // [39:35] = 5'b00000
  // [   34] = sel
  // [   33] = config mode
  // [   32] = read enable
  // [   31] = write enable
  // [30:27] = strobes
  // [26:25] = array processor
  // [24:18] = array encoding
  // [17: 6] = addr    
  // [ 5: 0] = 6'b000000
  assign mbist_req  = gov_mbist_req & (dcu_cp_addr_ifu[33] | dcu_cp_addr_ifu[34]);

  // If writing, at least one of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "mbist_req & dcu_cp_addr_ifu[31]  => |dcu_cp_addr_ifu[30:27]")
  u_ovl_intf_assert_8fc0036b1328e4de0a4fb86f65fa5d2c68b42cae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (mbist_req & dcu_cp_addr_ifu[31] ),
    .consequent_expr (|dcu_cp_addr_ifu[30:27]));


  // Cannot read and write on the same cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "mbist_req & dcu_cp_addr_ifu[31]  => ~dcu_cp_addr_ifu[32]")
  u_ovl_intf_assert_d0588024e0ad5ad053c810f9d924233fb867e026 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (mbist_req & dcu_cp_addr_ifu[31] ),
    .consequent_expr (~dcu_cp_addr_ifu[32]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "mbist_req & dcu_cp_addr_ifu[32]  => ~dcu_cp_addr_ifu[31]")
  u_ovl_intf_assert_053309aa5c88d9f3831e2cf05a21d6ac2badb4c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (mbist_req & dcu_cp_addr_ifu[32] ),
    .consequent_expr (~dcu_cp_addr_ifu[31]));


  // in the first cyle of MBIST we cannot have an MB3 request

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~out_of_reset & gov_mbist_req  => ~dcu_cp_addr_ifu[33]")
  u_ovl_intf_assert_a3c3a9bca1efea56e7b044e971bcb2fb242675ef (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~out_of_reset & gov_mbist_req ),
    .consequent_expr (~dcu_cp_addr_ifu[33]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~out_of_reset & gov_mbist_req  => ~dcu_cp_addr_ifu[34]")
  u_ovl_intf_assert_d7ec60e3db73b8a25548b6dac372f09d116ad892 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~out_of_reset & gov_mbist_req ),
    .consequent_expr (~dcu_cp_addr_ifu[34]));

  // in the first cycle of MBIST we cannot have any cp15 req, in the second
  // cycle the inval all will sneak in but the IFU will ack it without doing anything

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~out_of_reset & gov_mbist_req  => ~dcu_cp_valid_ifu")
  u_ovl_intf_assert_99bdb68d5c9bea143bc6978d63b070b01dfd7470 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~out_of_reset & gov_mbist_req ),
    .consequent_expr (~dcu_cp_valid_ifu));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~out_of_reset & gov_mbist_req  => ~dcu_dvm_valid_ifu")
  u_ovl_intf_assert_e3858f6b3bfbd1b2ec001095cb8746a44e2273b3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~out_of_reset & gov_mbist_req ),
    .consequent_expr (~dcu_dvm_valid_ifu));


  // Indicate if a valid fe2 request is underway or it was underway and it has
  // been killed (incomplete_fetch). This is used to allow the DCU to track when
  // operations are still outstanding which have used old pagetables, after a
  // TLB invalidate instruction.
  //  input        ifu_valid_if2      valid always                               timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ifu_valid_if2 X or Z")
  u_ovl_intf_x_ifu_valid_if2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_valid_if2));




endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dcu_ifu_defs.v"
`undef CA53_UNDEFINE

`endif

