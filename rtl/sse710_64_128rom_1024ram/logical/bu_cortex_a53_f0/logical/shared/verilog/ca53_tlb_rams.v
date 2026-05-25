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

// This is the specification for the interface between the TLB and rams

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"
`include "ca53tlb_defs.v"
`include "cortexa53params.v"

module ca53_tlb_rams #(parameter CPU_CACHE_PROTECTION = 0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata0_i,
  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata1_i,
  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata2_i,
  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata3_i,
  input   [3:0] tlb_ram_en_i,
  input         tlb_ram_wr_i,
  input [`CA53_TLB_RAM_ADDR_W-1:0] tlb_ram_addr_i,
  input [`CA53_TLB_RAM_W-1:0] tlb_ram_wdata_i);


  wire [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata0 = tlb_ram_rdata0_i;
  wire [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata1 = tlb_ram_rdata1_i;
  wire [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata2 = tlb_ram_rdata2_i;
  wire [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata3 = tlb_ram_rdata3_i;
  wire   [3:0] tlb_ram_en = tlb_ram_en_i;
  wire         tlb_ram_wr = tlb_ram_wr_i;
  wire [`CA53_TLB_RAM_ADDR_W-1:0] tlb_ram_addr = tlb_ram_addr_i;
  wire [`CA53_TLB_RAM_W-1:0] tlb_ram_wdata = tlb_ram_wdata_i;

  wire         valid_walk_write;
  wire   [7:0] read_mem_attrs1;
  wire   [7:0] mem_walk_attrs3;
  wire   [7:0] read_mem_attrs0;
  wire   [7:0] mem_walk_attrs2;
  wire   [7:0] read_mem_attrs2;
  wire   [7:0] mem_walk_attrs0;
  wire   [7:0] mem_walk_attrs1;
  wire   [7:0] read_mem_attrs3;
  wire         valid_tlb_write;
  wire   [7:0] mem_attrs;
  wire   [3:0] valid_walk_read;
  wire   [3:0] valid_tlb_read;
  wire         valid_ipa_write;
  wire   [3:0] valid_ipa_read;

  reg   [3:0] tlb_ram_en_q;

  reg [`CA53_TLB_RAM_ADDR_W-1:0] tlb_ram_addr_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    tlb_ram_addr_reg <= {((`CA53_TLB_RAM_ADDR_W-1) - (0) + 1){1'b0}};
  end
  else
  begin
    tlb_ram_addr_reg <= tlb_ram_addr;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------


  // The global enable for the RAM, 1 bit per bank.
  //  output [3:0] tlb_ram_en valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "tlb_ram_en X or Z")
  u_ovl_intf_x_tlb_ram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_ram_en));


  // The write enable, applies to whichever banks the global enable is set for.
  //  output tlb_ram_wr valid |tlb_ram_en timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "tlb_ram_wr X or Z")
  u_ovl_intf_x_tlb_ram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|tlb_ram_en),
    .test_expr (tlb_ram_wr));


  // The RAM address to access.
  //  output [`CA53_TLB_RAM_ADDR_W-1:0] tlb_ram_addr valid |tlb_ram_en timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_ADDR_W-1) - (0) + 1), OUTOPTIONS, "tlb_ram_addr X or Z")
  u_ovl_intf_x_tlb_ram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|tlb_ram_en),
    .test_expr (tlb_ram_addr));


  // The data to write to the RAM if a write is being performed.
  //  output [`CA53_TLB_RAM_W-1:0] tlb_ram_wdata valid |tlb_ram_en & tlb_ram_wr timing 50%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_W-1) - (0) + 1), OUTOPTIONS, "tlb_ram_wdata X or Z")
  u_ovl_intf_x_tlb_ram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|tlb_ram_en & tlb_ram_wr),
    .test_expr (tlb_ram_wdata));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tlb_ram_en_q <= 4'b0000;
  else
    tlb_ram_en_q <= tlb_ram_en & {4{~tlb_ram_wr}};


  // The read data from the RAMs. Valid in the cycle after they were enabled.
  //  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata0 valid tlb_ram_en_q[0] timing 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_W-1) - (0) + 1), INOPTIONS, "tlb_ram_rdata0 X or Z")
  u_ovl_intf_x_tlb_ram_rdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_ram_en_q[0]),
    .test_expr (tlb_ram_rdata0));

  //  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata1 valid tlb_ram_en_q[1] timing 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_W-1) - (0) + 1), INOPTIONS, "tlb_ram_rdata1 X or Z")
  u_ovl_intf_x_tlb_ram_rdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_ram_en_q[1]),
    .test_expr (tlb_ram_rdata1));

  //  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata2 valid tlb_ram_en_q[2] timing 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_W-1) - (0) + 1), INOPTIONS, "tlb_ram_rdata2 X or Z")
  u_ovl_intf_x_tlb_ram_rdata2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_ram_en_q[2]),
    .test_expr (tlb_ram_rdata2));

  //  input [`CA53_TLB_RAM_W-1:0] tlb_ram_rdata3 valid tlb_ram_en_q[3] timing 40%

  assert_never_unknown #(`OVL_FATAL, ((`CA53_TLB_RAM_W-1) - (0) + 1), INOPTIONS, "tlb_ram_rdata3 X or Z")
  u_ovl_intf_x_tlb_ram_rdata3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_ram_en_q[3]),
    .test_expr (tlb_ram_rdata3));



  // ------------------------------------------------------
  // Rules
  // ------------------------------------------------------

  // TLB RAM Write Enable should only be asserted when one of the TLB enables is set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "tlb_ram_wr  => |tlb_ram_en")
  u_ovl_intf_assert_2be50fbbdd834385ebf88fe6c776f1a9a0ecfb28 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_ram_wr ),
    .consequent_expr (|tlb_ram_en));


  assign valid_tlb_write   = |tlb_ram_en & tlb_ram_wr & tlb_ram_wdata[0] & (tlb_ram_addr[7] == 1'b0);
  assign valid_walk_write  = |tlb_ram_en & tlb_ram_wr & tlb_ram_wdata[0] & (tlb_ram_addr[7:4] == `CA53_RAM_WALK_PREFIX_ADDR);
  assign valid_ipa_write   = |tlb_ram_en & tlb_ram_wr & tlb_ram_wdata[0] & (tlb_ram_addr[7:4] == `CA53_RAM_IPA_PREFIX_ADDR);



generate if (CPU_CACHE_PROTECTION) begin : g_protection_intf0
  assign valid_tlb_read   = tlb_ram_en_q &  {4{tlb_ram_addr_reg[7] == 1'b0}} & { (tlb_ram_rdata3[0] & (tlb_ram_rdata3[116:114] == {^tlb_ram_rdata3[113:62],^tlb_ram_rdata3[61:31],^tlb_ram_rdata3[30:0]})), (tlb_ram_rdata2[0] & (tlb_ram_rdata2[116:114] == {^tlb_ram_rdata2[113:62],^tlb_ram_rdata2[61:31],^tlb_ram_rdata2[30:0]})), (tlb_ram_rdata1[0] & (tlb_ram_rdata1[116:114] == {^tlb_ram_rdata1[113:62],^tlb_ram_rdata1[61:31],^tlb_ram_rdata1[30:0]})), (tlb_ram_rdata0[0] & (tlb_ram_rdata0[116:114] == {^tlb_ram_rdata0[113:62],^tlb_ram_rdata0[61:31],^tlb_ram_rdata0[30:0]}))};

  assign valid_walk_read  = tlb_ram_en_q &  {4{tlb_ram_addr_reg[7:4] == `CA53_RAM_WALK_PREFIX_ADDR}} & {(tlb_ram_rdata3[0] & (tlb_ram_rdata3[116:114] == {^tlb_ram_rdata3[113:62],^tlb_ram_rdata3[61:31],^tlb_ram_rdata3[30:0]})), (tlb_ram_rdata2[0] & (tlb_ram_rdata2[116:114] == {^tlb_ram_rdata2[113:62],^tlb_ram_rdata2[61:31],^tlb_ram_rdata2[30:0]})), (tlb_ram_rdata1[0] & (tlb_ram_rdata1[116:114] == {^tlb_ram_rdata1[113:62],^tlb_ram_rdata1[61:31],^tlb_ram_rdata1[30:0]})), (tlb_ram_rdata0[0] & (tlb_ram_rdata0[116:114] == {^tlb_ram_rdata0[113:62],^tlb_ram_rdata0[61:31],^tlb_ram_rdata0[30:0]}))};

  assign valid_ipa_read   = tlb_ram_en_q & {4{tlb_ram_addr_reg[7:4] == `CA53_RAM_IPA_PREFIX_ADDR}} & {(tlb_ram_rdata3[0] & (tlb_ram_rdata3[116:114] == {^tlb_ram_rdata3[113:62],^tlb_ram_rdata3[61:31],^tlb_ram_rdata3[30:0]})), (tlb_ram_rdata2[0] & (tlb_ram_rdata2[116:114] == {^tlb_ram_rdata2[113:62],^tlb_ram_rdata2[61:31],^tlb_ram_rdata2[30:0]})), (tlb_ram_rdata1[0] & (tlb_ram_rdata1[116:114] == {^tlb_ram_rdata1[113:62],^tlb_ram_rdata1[61:31],^tlb_ram_rdata1[30:0]})), (tlb_ram_rdata0[0] & (tlb_ram_rdata0[116:114] == {^tlb_ram_rdata0[113:62],^tlb_ram_rdata0[61:31],^tlb_ram_rdata0[30:0]}))};
end endgenerate

generate if (!CPU_CACHE_PROTECTION) begin : g_no_protection_intf0
  assign valid_tlb_read   = tlb_ram_en_q & {tlb_ram_rdata3[0], tlb_ram_rdata2[0], tlb_ram_rdata1[0], tlb_ram_rdata0[0]} & {4{tlb_ram_addr_reg[7] == 1'b0}};
  assign valid_walk_read  = tlb_ram_en_q & {tlb_ram_rdata3[0], tlb_ram_rdata2[0], tlb_ram_rdata1[0], tlb_ram_rdata0[0]} & {4{tlb_ram_addr_reg[7:4] == `CA53_RAM_WALK_PREFIX_ADDR}};
  assign valid_ipa_read   = tlb_ram_en_q & {tlb_ram_rdata3[0], tlb_ram_rdata2[0], tlb_ram_rdata1[0], tlb_ram_rdata0[0]} & {4{tlb_ram_addr_reg[7:4] == `CA53_RAM_IPA_PREFIX_ADDR}};
end endgenerate

  // Only the lowest 160 entries are accessed.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|tlb_ram_en  => (tlb_ram_addr <= 8'd159)")
  u_ovl_intf_assert_2e66ed563f736cb92a700bd6138b2925a3e9e6f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|tlb_ram_en ),
    .consequent_expr ((tlb_ram_addr <= 8'd159)));


  // The unused bits of the VA for particular page sizes should always be written with zeroes

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assert_32063b532e69daa78210e45ba9b8d42ca572ed00 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assert_3e1b48daa818a28538596e90536d6499a1ccf3e6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assert_3d7510d2f407b439889b175f4bfa531471ba2624 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assert_e5c1cb5d0929407c90770403499359a8dcc6e6ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assert_469b90923fce14db6467acc74e35a7371168b96c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assert_11553969b2d5c08451966bb8b0780bc30165a74c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}));


  // The unused bits of the PA for particular page sizes should always be written with zeroes

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assert_d32962bb65b6c24b439b32f7ba941cac39066062 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assert_7c85531da93a9e34771c3943403b3e1282135141 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assert_4a3d3df453fb0112b2b945885f82d4335500246f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assert_7253feb787f2e7f25ca574b01213d45e125c981c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assert_6276325e1e450a15d7f284ce9225def853dca8af (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assert_56b97e7d1bda374f56ba6d0f6d134db6437efdb0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_wdata[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}));


  // The descriptor ns bit should always be set if the entry was fetched from non-secure state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & tlb_ram_wdata[`CA53_RAM_NS_WALK_BITS]  => tlb_ram_wdata[`CA53_RAM_NS_DESC_BITS]")
  u_ovl_intf_assert_b9dce83e48f0b65dc65c53b977621220e52a2291 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & tlb_ram_wdata[`CA53_RAM_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_wdata[`CA53_RAM_NS_DESC_BITS]));


  assign mem_attrs  = tlb_ram_wdata[`CA53_RAM_MEMATTR_BITS];

  // Only some page type encodings are valid

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write  => ~`CA53_MEM_UNUSED(mem_attrs)")
  u_ovl_intf_assert_735130d37f1d2844d96538056e51521ad4aa9b9f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_attrs)));



  // The combined size must not be larger than the S1 size
  // S1Size      Combined Size
  // 011 (2M)    100  (1M)  
  // 100 (16M)   001  (4K)   non-VMSA (4K VMSA is still possible)
  // 100 (16M)   011  (64K)  non-VMSA (64K VMSA is stil possible)
  // 100 (16M)   101  (2M)
  // 100 (16M)   111  (512M)
  // 101 (512M)  100  (1M)
  // 101 (512M)  110  (16M)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write  => tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] != 3'b111")
  u_ovl_intf_assert_459e6201cb7058f2cfecea1d9326f8faa64b59a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write ),
    .consequent_expr (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] != 3'b111));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b000)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001]")
  u_ovl_intf_assert_6941f11451555b0594f74ebeef4610bacebe286c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b000)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b001)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011]")
  u_ovl_intf_assert_3b5013ca6ea3cb1f8d5e2b5be5c6fc1081a79e5b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b001)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b010)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100]")
  u_ovl_intf_assert_3fbdb8f878eed51bc4c8ff4c8f307952e781beaf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b010)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b011)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101]")
  u_ovl_intf_assert_ec62527aae357c56557d962f7bf27947abf6d7d5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b011)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b100)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b010,3'b100,3'b110]")
  u_ovl_intf_assert_692056f5b8c3aedf1ab31afdccc282e64aadb793 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b100)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b101)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101,3'b111]")
  u_ovl_intf_assert_a5bc250dea45768a6ceaf0ed6f5b71c6ce613b30 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b101)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b110)   => tlb_ram_wdata[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111]")
  u_ovl_intf_assert_e2fb4e904f3983b4ed2820c28aeafa2ef6f4e23c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S1SIZE_BITS] == 3'b110)  ),
    .consequent_expr (((tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b110) | (tlb_ram_wdata[`CA53_RAM_SIZE_BITS] == 3'b111))));



  // The XN2 should be set if there was no stage2 translation

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S2LEVEL_BITS] == 2'b00)  => (tlb_ram_wdata[`CA53_RAM_XS2_BITS] == 1'b1)")
  u_ovl_intf_assert_bcb89345a2c11c6f214d39435f65c22bd9ce4d83 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S2LEVEL_BITS] == 2'b00) ),
    .consequent_expr ((tlb_ram_wdata[`CA53_RAM_XS2_BITS] == 1'b1)));


  // The HAP bits must be full access if there was no stage2 translation

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_wdata[`CA53_RAM_APHYP_BITS] != 3'b100)  => tlb_ram_wdata[`CA53_RAM_HAP_BITS] == 2'b11")
  u_ovl_intf_assert_9948ae806c92f2c8ccb135ba582f19bc44b1663c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_write & (tlb_ram_wdata[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_wdata[`CA53_RAM_APHYP_BITS] != 3'b100) ),
    .consequent_expr (tlb_ram_wdata[`CA53_RAM_HAP_BITS] == 2'b11));


  // The walk cache must have the lowest VA bit masked when in LPAE.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_walk_write & (tlb_ram_wdata[`CA53_RAM_WALK_ARCH_BITS]==2'b01)  => tlb_ram_wdata[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0")
  u_ovl_intf_assert_ba9dc417e8df648772bdeccda4a84c516606d517 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_write & (tlb_ram_wdata[`CA53_RAM_WALK_ARCH_BITS]==2'b01) ),
    .consequent_expr (tlb_ram_wdata[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0));


  // The descriptor ns bit should always be set if the entry was fetched from non-secure state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "valid_walk_write & tlb_ram_wdata[`CA53_RAM_WALK_NS_WALK_BITS]  => tlb_ram_wdata[`CA53_RAM_WALK_NS_WALK_BITS]")
  u_ovl_intf_assert_72d515880b3980e0296550a42f5c6da202e58920 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_write & tlb_ram_wdata[`CA53_RAM_WALK_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_wdata[`CA53_RAM_WALK_NS_WALK_BITS]));


  // The unused bits of the VA for particular page sizes should always be zero

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_d31223b988313c77cd8db99c43b2f3ca06647e94 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_34cafb6c3455a3f21f78ebbaa4b675fe0cc48892 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_c42776b644865f2c9e037ea699922ca984348f2d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_968e554b066e3cb638d5f4d78cb947e907db36f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_b5fd371a03567b223cf0a9ccf6940c732f4a74c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_d25f1b4537ee5dfb85e9484cc461021d81c3ecbb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_354396785dbc0ee76359874b9374fc1bd50fc9c9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_97759bf7f019b4ceb797b8506a0f479bd3ed1216 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_6128c7e3d2db44a18ad45be3d23c60461b42f6c3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_9695262bc17124e8379031b192c55cf51ea39dbc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_e1243e427630f48e7599953d01d5bd13de4f9783 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_34f91f62c65b2982d4ebb517a4d5a02075073ca8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_0c939b9670402e48d46c026f8d7f0a744e49bd91 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_1cb8c4488a76cd7a12d931aaffb20983a1b2eacd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_7b99c7a99a42f032e15d4c437447dfdc800d6f8c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_92294ce346296633e5a492143dda81ac5d4980f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_17b02ef46dbe0d991698f2fdbe106222232b15e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_f027860043bc7b86701a5e9fb89d206898822bb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_d3ed94720fe9734ef28ad373333f14b3d4c9a272 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_107111903132c430c3de86113e1ba373332c98c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+4)-1:`CA53_RAM_VA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_7a57a0220e113218749271d4f87182e003fc4562 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+8)-1:`CA53_RAM_VA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_aa52d195f969e5dc4608de95556a242db94d4aa7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+9)-1:`CA53_RAM_VA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_526401f09ecba3f4ee76fb5638e97c00fe7180ba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+12)-1:`CA53_RAM_VA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_a1cd8b0f40f83dfc0a2d9f7431dac291f2b781b0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_VA_MIN_BITS+17)-1:`CA53_RAM_VA_MIN_BITS] == {17{1'b0}}));


  // The unused bits of the PA for particular page sizes should always be zero

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_fb0e68e271f5beaf2ec17e1ca1900904bf5e2b90 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_449d95abb268ba988ea10883dce291ee38d24cff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_a788f343bf19fbd12c89952a503b80ee1c242384 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_76895104283e998c903003f2a799751b3c651426 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_54f25ddcf99a6bc5e9154bbd3f8c0241851acaae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_68aec435adb48175c22ba1f814c6983ee03db1f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata0[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_07ddc353b2418df0d071de5fc3e39e425409e7cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_1eb991077adbbe488d6c42e00bd8ef905a55cbcb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_01e183423727e5a1ec8c73a681adeb8bad16f1bd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_91b2b3f892afce906ca3d34c283d6e11293024bd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_61a46b857ef7e77e342853a13fcf580f8ef7de55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_ae9956920419a1b888bab4aad457023b034c156e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata1[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_7ac07d36bd3aa252a7e7d8b24db43beeb57f8e98 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_f6edf35e2c16ab9512c9e1b4e06175f5c1aea009 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_4437d5ddd38b783910d61bd1ad0eec02f79a7d61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_981ff8299fc5a9dd330c76d1b51741b172118432 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_d6c7754f6c828e36ada179857601ddcc9f044230 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_d29fce9584fcee137e6cc4ab58e6cddffd0bdfd7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata2[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_e6802497211cff6be6b9abe7a17f7241cd6bd735 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}")
  u_ovl_intf_assume_aea9300e67d5e67a66042dea4adb19eef3098e8d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+4)-1:`CA53_RAM_PA_MIN_BITS] == {4{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}")
  u_ovl_intf_assume_ebe576f7c136417d4c9e636b8c268377d361d8d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+8)-1:`CA53_RAM_PA_MIN_BITS] == {8{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}")
  u_ovl_intf_assume_364450369082cf2c4500df57ae0a8f52fef6e3bb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+9)-1:`CA53_RAM_PA_MIN_BITS] == {9{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}")
  u_ovl_intf_assume_51edf11d5bc6b289753df2d1f330fbc44c292a9c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+12)-1:`CA53_RAM_PA_MIN_BITS] == {12{1'b0}}));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111)  => tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}")
  u_ovl_intf_assume_a76e5c6323b5e4455b4fd62f93e16cff11e8ddf4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111) ),
    .consequent_expr (tlb_ram_rdata3[(`CA53_RAM_PA_MIN_BITS+17)-1:`CA53_RAM_PA_MIN_BITS] == {17{1'b0}}));


  // The descriptor ns bit should always be set if the entry was fetched from non-secure state

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & tlb_ram_rdata0[`CA53_RAM_NS_WALK_BITS]  => tlb_ram_rdata0[`CA53_RAM_NS_DESC_BITS]")
  u_ovl_intf_assume_0bfa6f13c3c2dd2111e7acac952d83ae6927dc57 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & tlb_ram_rdata0[`CA53_RAM_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata0[`CA53_RAM_NS_DESC_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & tlb_ram_rdata1[`CA53_RAM_NS_WALK_BITS]  => tlb_ram_rdata1[`CA53_RAM_NS_DESC_BITS]")
  u_ovl_intf_assume_e8c29c76c657e994e866f64f9fd04b1f35fb8cf9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & tlb_ram_rdata1[`CA53_RAM_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata1[`CA53_RAM_NS_DESC_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & tlb_ram_rdata2[`CA53_RAM_NS_WALK_BITS]  => tlb_ram_rdata2[`CA53_RAM_NS_DESC_BITS]")
  u_ovl_intf_assume_069e5c94095fa708a6c6ba72643fcfa65c44b010 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & tlb_ram_rdata2[`CA53_RAM_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata2[`CA53_RAM_NS_DESC_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & tlb_ram_rdata3[`CA53_RAM_NS_WALK_BITS]  => tlb_ram_rdata3[`CA53_RAM_NS_DESC_BITS]")
  u_ovl_intf_assume_5a4a2ebf93eead3288cef0cd39e31ef4480e62ae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & tlb_ram_rdata3[`CA53_RAM_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata3[`CA53_RAM_NS_DESC_BITS]));


  assign read_mem_attrs0  = tlb_ram_rdata0[`CA53_RAM_MEMATTR_BITS];
  assign read_mem_attrs1  = tlb_ram_rdata1[`CA53_RAM_MEMATTR_BITS];
  assign read_mem_attrs2  = tlb_ram_rdata2[`CA53_RAM_MEMATTR_BITS];
  assign read_mem_attrs3  = tlb_ram_rdata3[`CA53_RAM_MEMATTR_BITS];

  // Only some page type encodings are valid

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0]  => ~`CA53_MEM_UNUSED(read_mem_attrs0)")
  u_ovl_intf_assume_e24e8c70bd1c9f7d184f3c4a4362c53aa0efd793 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] ),
    .consequent_expr (~`CA53_MEM_UNUSED(read_mem_attrs0)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1]  => ~`CA53_MEM_UNUSED(read_mem_attrs1)")
  u_ovl_intf_assume_1db9de97260053b0326d60014819713697ca3612 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] ),
    .consequent_expr (~`CA53_MEM_UNUSED(read_mem_attrs1)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2]  => ~`CA53_MEM_UNUSED(read_mem_attrs2)")
  u_ovl_intf_assume_398a40a091ffd990b50e798cc251eafe738e02ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] ),
    .consequent_expr (~`CA53_MEM_UNUSED(read_mem_attrs2)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3]  => ~`CA53_MEM_UNUSED(read_mem_attrs3)")
  u_ovl_intf_assume_65be49c69ba969f44f5e34dab40550a3a1bc5267 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] ),
    .consequent_expr (~`CA53_MEM_UNUSED(read_mem_attrs3)));


  // The combined size must not be larger than the S1 size

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0]  => tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] != 3'b111")
  u_ovl_intf_assume_bbf171ac69b959e6ca1111bf85b7fc4146c9cc59 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] ),
    .consequent_expr (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] != 3'b111));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b000)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001]")
  u_ovl_intf_assume_57e63d2dc81fd7bde210682e340a57b0600919c5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b000)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b001)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011]")
  u_ovl_intf_assume_0c45719e2fba91ce64ac695f0bc3aa8560b9ae00 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b001)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b010)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100]")
  u_ovl_intf_assume_f86fbd15c8df13e591f4987b6032f77772f98a3c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b010)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b011)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101]")
  u_ovl_intf_assume_647635f0a064732950b032f86f7a7a323033ca80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b011)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b100)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b010,3'b100,3'b110]")
  u_ovl_intf_assume_b5a0a53661683a802d67c2ace8243c565f17d74c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b100)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b101)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101,3'b111]")
  u_ovl_intf_assume_ce9ecfd95218a1ff20bef4b65cd853c34b8ca4fe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b101)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b110)   => tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111]")
  u_ovl_intf_assume_f91d2b1336b392c235fb64dddcf1f59cf36c2d4d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S1SIZE_BITS] == 3'b110)  ),
    .consequent_expr (((tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b110) | (tlb_ram_rdata0[`CA53_RAM_SIZE_BITS] == 3'b111))));




  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1]  => tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] != 3'b111")
  u_ovl_intf_assume_c7d914c288fa5a7f3f256d7954421642deb396d0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] ),
    .consequent_expr (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] != 3'b111));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b000)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001]")
  u_ovl_intf_assume_9deeaaed8a28c242e2ccda0cbffc34296caba569 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b000)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b001)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011]")
  u_ovl_intf_assume_08d13f791999c4dad1b127092c39d75ff7dc196f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b001)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b010)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100]")
  u_ovl_intf_assume_b69f21f3ffd979942a4d2f84a2030d60ddab39ba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b010)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b011)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101]")
  u_ovl_intf_assume_d93a8757b7685edbee50517cc71f24d3a157731e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b011)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b100)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b010,3'b100,3'b110]")
  u_ovl_intf_assume_5ea14c7fe42a7d7c6be8fad68cacf01daaa08d0d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b100)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b101)  => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101,3'b111]")
  u_ovl_intf_assume_aef53cecd9b31290bc5728c43cef0c3b623ee8cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b101) ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b110)   => tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111]")
  u_ovl_intf_assume_21132e8f070fe3d7c05ab2d3e2cbeb44c312a756 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S1SIZE_BITS] == 3'b110)  ),
    .consequent_expr (((tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b110) | (tlb_ram_rdata1[`CA53_RAM_SIZE_BITS] == 3'b111))));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2]  => tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] != 3'b111")
  u_ovl_intf_assume_2a66f052903a36770e221f063080ef979795b9ef (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] ),
    .consequent_expr (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] != 3'b111));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b000)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001]")
  u_ovl_intf_assume_8b7bbdc1f5a7a2a79efb27649ff1e1f1df730d6a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b000)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b001)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011]")
  u_ovl_intf_assume_15685726016b56c7261f67b470fe630640cf2dba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b001)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b010)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100]")
  u_ovl_intf_assume_647a9311bc0e04717e6fd71ac07628a940080f1c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b010)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b011)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101]")
  u_ovl_intf_assume_e9388f4ec594f229d430714b03eee9a6c06eb359 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b011)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b100)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b010,3'b100,3'b110]")
  u_ovl_intf_assume_388c7d8b0935e5d683f093997f5a7b2e75eabf16 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b100)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b101)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101,3'b111]")
  u_ovl_intf_assume_2b38d2ed0525b4eb509582e67619bbb94c5f48bb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b101)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b110)   => tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111]")
  u_ovl_intf_assume_2908584b34e1451adaa0429aa52759486d74c72d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S1SIZE_BITS] == 3'b110)  ),
    .consequent_expr (((tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b110) | (tlb_ram_rdata2[`CA53_RAM_SIZE_BITS] == 3'b111))));



  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3]  => tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] != 3'b111")
  u_ovl_intf_assume_7639c27e0f0fdf1c232316852079fc599966debc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] ),
    .consequent_expr (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] != 3'b111));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b000)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001]")
  u_ovl_intf_assume_f42144c6251454776ee39e77a9fa3893d5c8a8a6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b000)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b001)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011]")
  u_ovl_intf_assume_3e77ce02334b837d495881a829265a5d2da759d6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b001)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b010)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100]")
  u_ovl_intf_assume_18949775695037af1ef1ab86611d3d1380ca52f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b010)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b011)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101]")
  u_ovl_intf_assume_b5fd679253b9f9b232c8584d6d42ba2ee4b5f53c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b011)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b100)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b010,3'b100,3'b110]")
  u_ovl_intf_assume_d7c1ced42067080f5f27ffc0b6a81bfa8ce455ae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b100)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b101)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b101,3'b111]")
  u_ovl_intf_assume_9782ea42ee5cc6f76abb3c8ced63fe0583903341 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b101)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111))));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b110)   => tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] in [3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111]")
  u_ovl_intf_assume_31ee37cd8042275a781c0d85948edf07e2ad7597 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S1SIZE_BITS] == 3'b110)  ),
    .consequent_expr (((tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b000) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b001) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b010) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b011) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b100) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b101) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b110) | (tlb_ram_rdata3[`CA53_RAM_SIZE_BITS] == 3'b111))));



  // The XN2 bit cannot be set if there was no stage2 translation

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S2LEVEL_BITS] == 2'b00)  => (tlb_ram_rdata0[`CA53_RAM_XS2_BITS] == 1'b1)")
  u_ovl_intf_assume_ae36517ee274767fca6efb5187100af992fa13b5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S2LEVEL_BITS] == 2'b00) ),
    .consequent_expr ((tlb_ram_rdata0[`CA53_RAM_XS2_BITS] == 1'b1)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S2LEVEL_BITS] == 2'b00)  => (tlb_ram_rdata1[`CA53_RAM_XS2_BITS] == 1'b1)")
  u_ovl_intf_assume_ef5719bda7b04ab852d79ae82fa03fb8108c898b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S2LEVEL_BITS] == 2'b00) ),
    .consequent_expr ((tlb_ram_rdata1[`CA53_RAM_XS2_BITS] == 1'b1)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S2LEVEL_BITS] == 2'b00)  => (tlb_ram_rdata2[`CA53_RAM_XS2_BITS] == 1'b1)")
  u_ovl_intf_assume_158741347a71cbb7acaa9625a7317e287d16361c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S2LEVEL_BITS] == 2'b00) ),
    .consequent_expr ((tlb_ram_rdata2[`CA53_RAM_XS2_BITS] == 1'b1)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S2LEVEL_BITS] == 2'b00)  => (tlb_ram_rdata3[`CA53_RAM_XS2_BITS] == 1'b1)")
  u_ovl_intf_assume_b94e3878e6ab21d081511edab1ffc650eecd70a9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S2LEVEL_BITS] == 2'b00) ),
    .consequent_expr ((tlb_ram_rdata3[`CA53_RAM_XS2_BITS] == 1'b1)));


  // The HAP bits must be full access if there was no stage2 translation

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata0[`CA53_RAM_APHYP_BITS] != 3'b100)  => tlb_ram_rdata0[`CA53_RAM_HAP_BITS] == 2'b11")
  u_ovl_intf_assume_4875a8f9bdc0eb10fe5394da4df4101323dcd1ca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[0] & (tlb_ram_rdata0[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata0[`CA53_RAM_APHYP_BITS] != 3'b100) ),
    .consequent_expr (tlb_ram_rdata0[`CA53_RAM_HAP_BITS] == 2'b11));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata1[`CA53_RAM_APHYP_BITS] != 3'b100)  => tlb_ram_rdata1[`CA53_RAM_HAP_BITS] == 2'b11")
  u_ovl_intf_assume_04d1575556d5652785efdf7260241abf911916d2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[1] & (tlb_ram_rdata1[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata1[`CA53_RAM_APHYP_BITS] != 3'b100) ),
    .consequent_expr (tlb_ram_rdata1[`CA53_RAM_HAP_BITS] == 2'b11));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata2[`CA53_RAM_APHYP_BITS] != 3'b100)  => tlb_ram_rdata2[`CA53_RAM_HAP_BITS] == 2'b11")
  u_ovl_intf_assume_2d2d4b4d6590783f64987f120e5eaf914d17db4d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[2] & (tlb_ram_rdata2[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata2[`CA53_RAM_APHYP_BITS] != 3'b100) ),
    .consequent_expr (tlb_ram_rdata2[`CA53_RAM_HAP_BITS] == 2'b11));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata3[`CA53_RAM_APHYP_BITS] != 3'b100)  => tlb_ram_rdata3[`CA53_RAM_HAP_BITS] == 2'b11")
  u_ovl_intf_assume_c386bc12a01faaa120c526c299123990e7e4d705 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_tlb_read[3] & (tlb_ram_rdata3[`CA53_RAM_S2LEVEL_BITS] == 2'b00) & (tlb_ram_rdata3[`CA53_RAM_APHYP_BITS] != 3'b100) ),
    .consequent_expr (tlb_ram_rdata3[`CA53_RAM_HAP_BITS] == 2'b11));


  // The walk cache must have the lowest VA bit masked when in LPAE.

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[0] & (tlb_ram_rdata0[`CA53_RAM_WALK_ARCH_BITS]==2'b01)  => tlb_ram_rdata0[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0")
  u_ovl_intf_assume_e55f3daa37cb16eb2cbb3a7541b510648802b60a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[0] & (tlb_ram_rdata0[`CA53_RAM_WALK_ARCH_BITS]==2'b01) ),
    .consequent_expr (tlb_ram_rdata0[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[1] & (tlb_ram_rdata1[`CA53_RAM_WALK_ARCH_BITS]==2'b01)  => tlb_ram_rdata1[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0")
  u_ovl_intf_assume_f9a791b00cd3799e2892ef88639d0d64a463ad44 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[1] & (tlb_ram_rdata1[`CA53_RAM_WALK_ARCH_BITS]==2'b01) ),
    .consequent_expr (tlb_ram_rdata1[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[2] & (tlb_ram_rdata2[`CA53_RAM_WALK_ARCH_BITS]==2'b01)  => tlb_ram_rdata2[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0")
  u_ovl_intf_assume_26ccc77e796b21f4468d7b1e66cd92418a1f3ffa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[2] & (tlb_ram_rdata2[`CA53_RAM_WALK_ARCH_BITS]==2'b01) ),
    .consequent_expr (tlb_ram_rdata2[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[3] & (tlb_ram_rdata3[`CA53_RAM_WALK_ARCH_BITS]==2'b01)  => tlb_ram_rdata3[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0")
  u_ovl_intf_assume_5de50dd11ca2d89a1cfd977d59c8fb88b59dcc2b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[3] & (tlb_ram_rdata3[`CA53_RAM_WALK_ARCH_BITS]==2'b01) ),
    .consequent_expr (tlb_ram_rdata3[`CA53_RAM_WALK_VA_LS_BITS] == 1'b0));


  // The descriptor ns bit should always be set if the entry was fetched from non-secure state

  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[0] & tlb_ram_rdata0[`CA53_RAM_WALK_NS_WALK_BITS]  => tlb_ram_rdata0[`CA53_RAM_WALK_NSTABLE_BITS]")
  u_ovl_intf_assume_b7651b5dfa0f299ad875ec368fe3bc5a2b6dd6e1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[0] & tlb_ram_rdata0[`CA53_RAM_WALK_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata0[`CA53_RAM_WALK_NSTABLE_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[1] & tlb_ram_rdata1[`CA53_RAM_WALK_NS_WALK_BITS]  => tlb_ram_rdata1[`CA53_RAM_WALK_NSTABLE_BITS]")
  u_ovl_intf_assume_7e8e5c8127a1734faa6979a61b679a050e229da1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[1] & tlb_ram_rdata1[`CA53_RAM_WALK_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata1[`CA53_RAM_WALK_NSTABLE_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[2] & tlb_ram_rdata2[`CA53_RAM_WALK_NS_WALK_BITS]  => tlb_ram_rdata2[`CA53_RAM_WALK_NSTABLE_BITS]")
  u_ovl_intf_assume_28264bc8bcbf64a98e2529cf842a63b562c00c55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[2] & tlb_ram_rdata2[`CA53_RAM_WALK_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata2[`CA53_RAM_WALK_NSTABLE_BITS]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[3] & tlb_ram_rdata3[`CA53_RAM_WALK_NS_WALK_BITS]  => tlb_ram_rdata3[`CA53_RAM_WALK_NSTABLE_BITS]")
  u_ovl_intf_assume_807397c8d94aed9cb1b9df56c92d492a8175592e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[3] & tlb_ram_rdata3[`CA53_RAM_WALK_NS_WALK_BITS] ),
    .consequent_expr (tlb_ram_rdata3[`CA53_RAM_WALK_NSTABLE_BITS]));


  assign mem_walk_attrs0  = tlb_ram_rdata0[`CA53_RAM_WALK_MEMATTR_BITS];
  assign mem_walk_attrs1  = tlb_ram_rdata1[`CA53_RAM_WALK_MEMATTR_BITS];
  assign mem_walk_attrs2  = tlb_ram_rdata2[`CA53_RAM_WALK_MEMATTR_BITS];
  assign mem_walk_attrs3  = tlb_ram_rdata3[`CA53_RAM_WALK_MEMATTR_BITS];


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[0]  => ~`CA53_MEM_UNUSED(mem_walk_attrs0)")
  u_ovl_intf_assume_3da8fadb293ffe251973c45db5df819afb281c98 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[0] ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_walk_attrs0)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[1]  => ~`CA53_MEM_UNUSED(mem_walk_attrs1)")
  u_ovl_intf_assume_3bbc7209693fc382610b2f2e91daf3bf7b387a07 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[1] ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_walk_attrs1)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[2]  => ~`CA53_MEM_UNUSED(mem_walk_attrs2)")
  u_ovl_intf_assume_6e2b35583b0fc167075e6b89232e7ff0189b49dd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[2] ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_walk_attrs2)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "valid_walk_read[3]  => ~`CA53_MEM_UNUSED(mem_walk_attrs3)")
  u_ovl_intf_assume_e60d3607810906f889bdfc24cd749f6e37e8e9eb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (valid_walk_read[3] ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_walk_attrs3)));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53tlb_defs.v"
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`undef CA53_UNDEFINE

`endif

