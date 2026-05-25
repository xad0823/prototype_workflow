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

// This is the specification for the interface between the DCU and TLB
// Inputs and outputs are from the point of view of the DCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dcu_tlb_defs.v"
`include "cortexa53params.v"

module ca53_dcu_tlb #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         tlb_d_utlb_enable_i,
  input  [15:0] tlb_wpt_hit_dc1_i,
  input   [1:0] tlb_cache_walk_lookup_req_m0_i,
  input  [39:3] tlb_cache_walk_addr_i,
  input         tlb_cache_walk_ns_dsc_i,
  input  [63:0] tlb_cp_read_data_dc2_i,
  input         tlb_pagewalk_invalidated_i,
  input         tlb_cp_reg_write_ready_i,
  input         tlb_cp_ack_i,
  input   [1:0] tlb_d_tcr_el1_tbi_i,
  input         tlb_d_tcr_el2_tbi0_i,
  input         tlb_d_tcr_el3_tbi0_i,
  input   [7:0] tlb_vmid_i,
  input         dpu_utlb_hit_dc1_i,
  input         tlb_d_utlb_flush_i,
  input         dcu_va_valid_early_dc1_i,
  input         dcu_va_valid_dc1_i,
  input         dcu_ongoing_burst_dc1_i,
  input         dcu_store_dc1_i,
  input         dcu_wpt_check_512_dc1_i,
  input         dcu_priv_dc1_i,
  input   [2:0] dcu_transl_type_dc1_i,
  input         dcu_cache_walk_has_priority_m0_i,
  input         dcu_cache_walk_ack_m1_i,
  input         dcu_cache_walk_hit_m2_i,
  input  [63:0] dcu_cache_walk_data_m2_i,
  input   [3:0] dcu_cache_walk_victim_way_m2_i,
  input         dcu_ecc_err_m3_i,
  input   [5:0] dcu_cp_reg_en_dc2_i,
  input         dcu_block_lookups_i,
  input         dcu_cp_reg_write_dc3_i,
  input         dcu_cp_reg_write_active_i,
  input   [5:0] dcu_cp_reg_en_dc3_i,
  input  [63:0] dcu_cp_reg_data_i,
  input         dcu_cp_reg_size_i,
  input         dcu_cp_valid_tlb_i,
  input  [61:0] dcu_cp_addr_tlb_i,
  input         dcu_cp_ns_i,
  input   [4:0] dcu_cp_op_tlb_i);


  wire         tlb_d_utlb_enable = tlb_d_utlb_enable_i;
  wire  [15:0] tlb_wpt_hit_dc1 = tlb_wpt_hit_dc1_i;
  wire   [1:0] tlb_cache_walk_lookup_req_m0 = tlb_cache_walk_lookup_req_m0_i;
  wire  [39:3] tlb_cache_walk_addr = tlb_cache_walk_addr_i;
  wire         tlb_cache_walk_ns_dsc = tlb_cache_walk_ns_dsc_i;
  wire  [63:0] tlb_cp_read_data_dc2 = tlb_cp_read_data_dc2_i;
  wire         tlb_pagewalk_invalidated = tlb_pagewalk_invalidated_i;
  wire         tlb_cp_reg_write_ready = tlb_cp_reg_write_ready_i;
  wire         tlb_cp_ack = tlb_cp_ack_i;
  wire   [1:0] tlb_d_tcr_el1_tbi = tlb_d_tcr_el1_tbi_i;
  wire         tlb_d_tcr_el2_tbi0 = tlb_d_tcr_el2_tbi0_i;
  wire         tlb_d_tcr_el3_tbi0 = tlb_d_tcr_el3_tbi0_i;
  wire   [7:0] tlb_vmid = tlb_vmid_i;
  wire         dpu_utlb_hit_dc1 = dpu_utlb_hit_dc1_i;
  wire         tlb_d_utlb_flush = tlb_d_utlb_flush_i;
  wire         dcu_va_valid_early_dc1 = dcu_va_valid_early_dc1_i;
  wire         dcu_va_valid_dc1 = dcu_va_valid_dc1_i;
  wire         dcu_ongoing_burst_dc1 = dcu_ongoing_burst_dc1_i;
  wire         dcu_store_dc1 = dcu_store_dc1_i;
  wire         dcu_wpt_check_512_dc1 = dcu_wpt_check_512_dc1_i;
  wire         dcu_priv_dc1 = dcu_priv_dc1_i;
  wire   [2:0] dcu_transl_type_dc1 = dcu_transl_type_dc1_i;
  wire         dcu_cache_walk_has_priority_m0 = dcu_cache_walk_has_priority_m0_i;
  wire         dcu_cache_walk_ack_m1 = dcu_cache_walk_ack_m1_i;
  wire         dcu_cache_walk_hit_m2 = dcu_cache_walk_hit_m2_i;
  wire  [63:0] dcu_cache_walk_data_m2 = dcu_cache_walk_data_m2_i;
  wire   [3:0] dcu_cache_walk_victim_way_m2 = dcu_cache_walk_victim_way_m2_i;
  wire         dcu_ecc_err_m3 = dcu_ecc_err_m3_i;
  wire   [5:0] dcu_cp_reg_en_dc2 = dcu_cp_reg_en_dc2_i;
  wire         dcu_block_lookups = dcu_block_lookups_i;
  wire         dcu_cp_reg_write_dc3 = dcu_cp_reg_write_dc3_i;
  wire         dcu_cp_reg_write_active = dcu_cp_reg_write_active_i;
  wire   [5:0] dcu_cp_reg_en_dc3 = dcu_cp_reg_en_dc3_i;
  wire  [63:0] dcu_cp_reg_data = dcu_cp_reg_data_i;
  wire         dcu_cp_reg_size = dcu_cp_reg_size_i;
  wire         dcu_cp_valid_tlb = dcu_cp_valid_tlb_i;
  wire  [61:0] dcu_cp_addr_tlb = dcu_cp_addr_tlb_i;
  wire         dcu_cp_ns = dcu_cp_ns_i;
  wire   [4:0] dcu_cp_op_tlb = dcu_cp_op_tlb_i;

  wire   [1:0] tlb_lookup_accepted;
  wire  [63:0] cp_reg_data_valid_mask;
  wire  [61:0] cp_addr_valid;
  wire  [63:0] cache_walk_data_mask;

  reg   [1:0] tlb_lookup_m1;
  reg         non_reset_seen;

  reg   [1:0] tlb_lookup_accepted_reg;
  reg   [1:0] tlb_lookup_accepted_reg_reg;
  reg         dcu_cache_walk_ack_m1_reg;
  reg         dcu_cp_reg_write_active_reg;
  reg  [63:0] dcu_cp_reg_data_reg;
  reg         dcu_cp_valid_tlb_reg;
  reg   [5:0] dcu_cp_reg_en_dc3_reg;
  reg         dcu_cp_ns_reg;
  reg         dcu_ongoing_burst_dc1_reg;
  reg         dcu_va_valid_dc1_reg;
  reg   [1:0] tlb_lookup_m1_reg;
  reg  [61:0] dcu_cp_addr_tlb_reg;
  reg         dpu_utlb_hit_dc1_reg;
  reg         dcu_cp_reg_write_dc3_reg;
  reg   [4:0] dcu_cp_op_tlb_reg;
  reg  [61:0] cp_addr_valid_reg;
  reg         tlb_cp_reg_write_ready_reg;
  reg         tlb_cp_ack_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    tlb_lookup_accepted_reg <= 2'b00;
    tlb_lookup_accepted_reg_reg <= 2'b00;
    dcu_cache_walk_ack_m1_reg <= 1'b0;
    dcu_cp_reg_write_active_reg <= 1'b0;
    dcu_cp_reg_data_reg <= {64{1'b0}};
    dcu_cp_valid_tlb_reg <= 1'b0;
    dcu_cp_reg_en_dc3_reg <= {6{1'b0}};
    dcu_cp_ns_reg <= 1'b0;
    dcu_ongoing_burst_dc1_reg <= 1'b0;
    dcu_va_valid_dc1_reg <= 1'b0;
    tlb_lookup_m1_reg <= 2'b00;
    dcu_cp_addr_tlb_reg <= {62{1'b0}};
    dpu_utlb_hit_dc1_reg <= 1'b0;
    dcu_cp_reg_write_dc3_reg <= 1'b0;
    dcu_cp_op_tlb_reg <= {5{1'b0}};
    cp_addr_valid_reg <= {62{1'b0}};
    tlb_cp_reg_write_ready_reg <= 1'b0;
    tlb_cp_ack_reg <= 1'b0;
  end
  else
  begin
    tlb_cp_reg_write_ready_reg <= tlb_cp_reg_write_ready;
    tlb_cp_ack_reg <= tlb_cp_ack;
    dpu_utlb_hit_dc1_reg <= dpu_utlb_hit_dc1;
    dcu_va_valid_dc1_reg <= dcu_va_valid_dc1;
    dcu_ongoing_burst_dc1_reg <= dcu_ongoing_burst_dc1;
    dcu_cache_walk_ack_m1_reg <= dcu_cache_walk_ack_m1;
    dcu_cp_reg_write_dc3_reg <= dcu_cp_reg_write_dc3;
    dcu_cp_reg_write_active_reg <= dcu_cp_reg_write_active;
    dcu_cp_reg_en_dc3_reg <= dcu_cp_reg_en_dc3;
    dcu_cp_reg_data_reg <= dcu_cp_reg_data;
    dcu_cp_valid_tlb_reg <= dcu_cp_valid_tlb;
    dcu_cp_addr_tlb_reg <= dcu_cp_addr_tlb;
    dcu_cp_ns_reg <= dcu_cp_ns;
    dcu_cp_op_tlb_reg <= dcu_cp_op_tlb;
    tlb_lookup_accepted_reg <= tlb_lookup_accepted;
    tlb_lookup_accepted_reg_reg <= tlb_lookup_accepted_reg;
    tlb_lookup_m1_reg <= tlb_lookup_m1;
    cp_addr_valid_reg <= cp_addr_valid;
  end



  //----------------------------------------------------------------------------
  //
  // DC1 translation request signals
  //
  //----------------------------------------------------------------------------

  // TLB Request Signals

  // The access in dc1 is valid, and requires a TLB lookup if dpu_utlb_hit_dc1
  // is low.
  //  output dcu_va_valid_early_dc1 valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_va_valid_early_dc1 X or Z")
  u_ovl_intf_x_dcu_va_valid_early_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_va_valid_early_dc1));

  //  output dcu_va_valid_dc1       valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_va_valid_dc1 X or Z")
  u_ovl_intf_x_dcu_va_valid_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_va_valid_dc1));


  // The DCU needs to see the uTLB enable signal from the TLB to the DPU, so that
  // it can detect when a translation is about to complete and clear its related
  // stall flag.
  //  input tlb_d_utlb_enable valid always timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_utlb_enable X or Z")
  u_ovl_intf_x_tlb_d_utlb_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_utlb_enable));


  // These signals come straight from the dpu to the tlb and are included in
  // the dcu interface only to ensure correct assertion behaviour.

  // There is an ongoing burst in dc1. This will be set for all but the last
  // transaction in an instruction (multiples and cross 64 transactions).
  // The uTLB must not be invalidated while this is set.
  //  output dcu_ongoing_burst_dc1 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ongoing_burst_dc1 X or Z")
  u_ovl_intf_x_dcu_ongoing_burst_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ongoing_burst_dc1));


  // There is a valid store or CP15 in dc1. The TLB uses this to match the access
  // control bits (load or store) in the watchpoint control register.
  // The DCU will ignore the watchpoint hit on a CP15 access.
  //  output dcu_store_dc1 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_store_dc1 X or Z")
  u_ovl_intf_x_dcu_store_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_store_dc1));


  // When asserted, TLB checkes watchpoints on an entire cacheline
  //  output dcu_wpt_check_512_dc1 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_wpt_check_512_dc1 X or Z")
  u_ovl_intf_x_dcu_wpt_check_512_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_wpt_check_512_dc1));


  // The transaction in DC1 is privileged. The TLB uses this to match the privilege
  // control bits in the watchpoint control register.
  //  output dcu_priv_dc1 valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_priv_dc1 X or Z")
  u_ovl_intf_x_dcu_priv_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_priv_dc1));


  // watchpoint hit signal for debug architecture
  // tlb_wpt_hit_dc1 signals that the virtual address sent in dc1 on
  // dpu_va_dc1[31:4] hits the watchpoint specified by the watchpoint register.
  // There is one bit for each byte, and the DCU must mask this with the bytes
  // actually being accessed.
  //  input [15:0] tlb_wpt_hit_dc1 valid dcu_va_valid_dc1 timing 80%

  assert_never_unknown #(`OVL_FATAL, 16, INOPTIONS, "tlb_wpt_hit_dc1 X or Z")
  u_ovl_intf_x_tlb_wpt_hit_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_va_valid_dc1),
    .test_expr (tlb_wpt_hit_dc1));


  // The type of CP15 V2P translation request, or normal for everything else.
  //  output [2:0] dcu_transl_type_dc1 valid dcu_va_valid_dc1 timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "dcu_transl_type_dc1 X or Z")
  u_ovl_intf_x_dcu_transl_type_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_va_valid_dc1),
    .test_expr (dcu_transl_type_dc1));



  // The uTLB must not be flushed in the middle of a burst.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_ongoing_burst_dc1  => ~tlb_d_utlb_flush")
  u_ovl_intf_assume_a1da199b4273f89242b1a0c5bcfaeb8444dd4ee0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_ongoing_burst_dc1 ),
    .consequent_expr (~tlb_d_utlb_flush));


  // DCU shouldn't assert dcu_va_valid_dc1 without asserting
  // dcu_va_valid_early_dc1 (but can assert early without full request)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_va_valid_dc1  => dcu_va_valid_early_dc1")
  u_ovl_intf_assert_c616bf2796c23db82295fa3dadcd01be55f047d9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_va_valid_dc1 ),
    .consequent_expr (dcu_va_valid_early_dc1));


  // When DC1 is flushed, va_valid_early should go low on the cycle
  // after va_valid (unless a new request starts)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dcu_va_valid_dc1@1 & ~dcu_va_valid_dc1  => ~dcu_va_valid_early_dc1")
  u_ovl_intf_assert_5c6e37bebb6ae00729189b697b92dd63ceac747c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dcu_va_valid_dc1_reg & ~dcu_va_valid_dc1 ),
    .consequent_expr (~dcu_va_valid_early_dc1));


  // While lookup request stays high and ready is not signalled, ongoing_burst should
  // not change.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_va_valid_dc1@1 & dcu_va_valid_dc1) & ~dpu_utlb_hit_dc1@1  => (dcu_ongoing_burst_dc1 == dcu_ongoing_burst_dc1@1)")
  u_ovl_intf_assert_da00796ac1a0ecc721cf0abb32de8d9ba62b618d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_va_valid_dc1_reg & dcu_va_valid_dc1) & ~dpu_utlb_hit_dc1_reg ),
    .consequent_expr ((dcu_ongoing_burst_dc1 == dcu_ongoing_burst_dc1_reg)));


  // The TLB should not assert tlb_d_utlb_enable when dcu_va_valid is not asserted

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_d_utlb_enable  => dcu_va_valid_dc1")
  u_ovl_intf_assume_c6a70beca525ad3090e940150a5f829f26507cd9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_d_utlb_enable ),
    .consequent_expr (dcu_va_valid_dc1));



  //----------------------------------------------------------------------------
  //
  // Cached Descriptor Interface
  //
  //----------------------------------------------------------------------------

  // The TLB wants to do a tag and data lookup in the cache. The two-bits indicate
  // which word within the supplied doubleword address the request is for (both
  // bits being set indicates a doubleword request).
  //  input [1:0] tlb_cache_walk_lookup_req_m0 valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_cache_walk_lookup_req_m0 X or Z")
  u_ovl_intf_x_tlb_cache_walk_lookup_req_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_cache_walk_lookup_req_m0));


  // The address to lookup.
  //  input [39:3] tlb_cache_walk_addr valid (|tlb_cache_walk_lookup_req_m0) timing 60%

  assert_never_unknown #(`OVL_FATAL, 37, INOPTIONS, "tlb_cache_walk_addr X or Z")
  u_ovl_intf_x_tlb_cache_walk_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((|tlb_cache_walk_lookup_req_m0)),
    .test_expr (tlb_cache_walk_addr));


  // The non-secure bit of the lookup address.
  //  input tlb_cache_walk_ns_dsc valid (|tlb_cache_walk_lookup_req_m0) timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_cache_walk_ns_dsc X or Z")
  u_ovl_intf_x_tlb_cache_walk_ns_dsc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((|tlb_cache_walk_lookup_req_m0)),
    .test_expr (tlb_cache_walk_ns_dsc));


  // The DCU indicates when TLB will have priority in m0 if it makes a request
  // this cycle. If the TLB makes a request and it has priority then it must
  // deassert the request in the following cycle.
  //  output dcu_cache_walk_has_priority_m0 valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cache_walk_has_priority_m0 X or Z")
  u_ovl_intf_x_dcu_cache_walk_has_priority_m0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cache_walk_has_priority_m0));


  // Ack from the cache that the request has been arbitrated and is enabling the
  // RAMs this cycle.
  //  output dcu_cache_walk_ack_m1 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cache_walk_ack_m1 X or Z")
  u_ovl_intf_x_dcu_cache_walk_ack_m1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cache_walk_ack_m1));


  // The lookup hit in the cache. If it did not hit then the TLB is responsible
  // for starting a linefill.
  //  output dcu_cache_walk_hit_m2 valid dcu_cache_walk_ack_m1@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cache_walk_hit_m2 X or Z")
  u_ovl_intf_x_dcu_cache_walk_hit_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cache_walk_ack_m1_reg),
    .test_expr (dcu_cache_walk_hit_m2));


  assign cache_walk_data_mask  = ({64{dcu_cache_walk_ack_m1_reg & dcu_cache_walk_hit_m2}} & {{32{tlb_lookup_m1_reg[1]}}, {32{tlb_lookup_m1_reg[0]}}});

  // The cached descriptor data read from the cache, if the lookup hit. The data
  // comes one clock after the ack.
  //  output [63:0] dcu_cache_walk_data_m2 valid mask cache_walk_data_mask timing 85%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "dcu_cache_walk_data_m2 & (cache_walk_data_mask) X or Z")
  u_ovl_intf_x_61204114bc151f5808cf84a4b7f5c092d1dca5d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cache_walk_data_m2 & (cache_walk_data_mask)));


  // The victim way to perform linefill to if the lookup failed.
  //  output [3:0] dcu_cache_walk_victim_way_m2 valid (dcu_cache_walk_ack_m1@1 & ~dcu_cache_walk_hit_m2) timing 80%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dcu_cache_walk_victim_way_m2 X or Z")
  u_ovl_intf_x_dcu_cache_walk_victim_way_m2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier ((dcu_cache_walk_ack_m1_reg & ~dcu_cache_walk_hit_m2)),
    .test_expr (dcu_cache_walk_victim_way_m2));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tlb_lookup_m1 <= 2'b00;
  else
    tlb_lookup_m1 <= ((tlb_cache_walk_lookup_req_m0 & {2{dcu_cache_walk_has_priority_m0}}) | (tlb_lookup_m1 & ~{2{dcu_cache_walk_ack_m1}}));



  // The victim way should be one hot.

  assert_one_hot #(`OVL_FATAL, 4, OUTOPTIONS, "(dcu_cache_walk_ack_m1@1 & ~dcu_cache_walk_hit_m2) ? dcu_cache_walk_victim_way_m2 : 4'b0001")
  u_ovl_intf_assert_bbf824b77961ebf5320866c54911963978ba8e29 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((dcu_cache_walk_ack_m1_reg & ~dcu_cache_walk_hit_m2) ? dcu_cache_walk_victim_way_m2 : 4'b0001));



  // Can only get an acknowledge back from the dcu if a lookup request
  // has previously been made.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cache_walk_ack_m1  => |tlb_lookup_m1")
  u_ovl_intf_assert_91154b4febd4a688f066bd1a2e228c62a0d35082 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cache_walk_ack_m1 ),
    .consequent_expr (|tlb_lookup_m1));


  // The TLB must not make a second request when the first is still outstanding.

  assert_implication #(`OVL_FATAL, INOPTIONS, "|tlb_lookup_m1  => ~|tlb_cache_walk_lookup_req_m0")
  u_ovl_intf_assume_4da092b1e82ab65a275c98702772575b70abd7a3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|tlb_lookup_m1 ),
    .consequent_expr (~|tlb_cache_walk_lookup_req_m0));



  // TLB internal pagewalk state machine guarantees that there will be no back
  // to back tag/data or data/tag lookups.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cache_walk_ack_m1@1  => ~|tlb_cache_walk_lookup_req_m0")
  u_ovl_intf_assume_e9b970bbc8ad2b148019152cf818bc6e55be4cf5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cache_walk_ack_m1_reg ),
    .consequent_expr (~|tlb_cache_walk_lookup_req_m0));


  assign tlb_lookup_accepted  = tlb_lookup_m1 & {2{dcu_cache_walk_ack_m1}};

  // ECC Error from Data RAM
  //  output dcu_ecc_err_m3 valid |tlb_lookup_accepted@2 timing 55%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_ecc_err_m3 X or Z")
  u_ovl_intf_x_dcu_ecc_err_m3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|tlb_lookup_accepted_reg_reg),
    .test_expr (dcu_ecc_err_m3));


  //----------------------------------------------------------------------------
  //
  // CP15 read interface (dc2)
  //
  //----------------------------------------------------------------------------

  // If there is a CP14/CP15 register read in dc2, then this indicates which
  // register. The TLB cannot tell if there is a read or not, but should provide
  // the data assuming that there is. If this does not indicate a valid register
  // then the TLB may return unknown data.

  // The data returned from the register read. It may be X if software has not
  // written to all the unreset registers. It is valid in the same cycle as
  // dcu_cp_reg_en_dc2 is driven.


  //----------------------------------------------------------------------------
  //
  // CP14/CP15 register write interface (dc3)
  //
  //----------------------------------------------------------------------------

  // There is a pagewalk in progress which has been invalidated by a CP15
  // operation but which has not yet completed, so the DCU should not retire or
  // broadcast the operation.
  //  input tlb_pagewalk_invalidated valid always timing 15%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_pagewalk_invalidated X or Z")
  u_ovl_intf_x_tlb_pagewalk_invalidated (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_pagewalk_invalidated));


  // The DCU synchronously resets the pagewalk invalidated tracking register by sampling the
  // input on the first cycle after reset, assuming it will be clear.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    non_reset_seen <= 1'b0;
  else
    non_reset_seen <= 1'b1;



  assert_implication #(`OVL_FATAL, INOPTIONS, "~non_reset_seen  => ~tlb_pagewalk_invalidated")
  u_ovl_intf_assume_83f620af6eee74720c1ce3b6bed9c3a15f05d92e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~non_reset_seen ),
    .consequent_expr (~tlb_pagewalk_invalidated));


  // The DCU has either detected a change in the cache on/off, or has a register
  // write in dc3, and so the TLB should not start any new iside lookups until
  // the change has been completed. (The DCU will not request any dside lookups
  // while this is asserted).
  //  output dcu_block_lookups valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_block_lookups X or Z")
  u_ovl_intf_x_dcu_block_lookups (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_block_lookups));


  // The DCU must not ask to block lookups if there is something in dc1.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_block_lookups  => ~dcu_va_valid_dc1")
  u_ovl_intf_assert_3492ca29545accf6ced3db18313e4a49a0b4924a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_block_lookups ),
    .consequent_expr (~dcu_va_valid_dc1));


  // The TLB is idle this cycle and is not starting a new request. Therefore
  // it is guaranteed to still be idle in the next cycle.
  //  input tlb_cp_reg_write_ready valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_cp_reg_write_ready X or Z")
  u_ovl_intf_x_tlb_cp_reg_write_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_cp_reg_write_ready));


  // A write to a CP14/CP15 register is in dc3 and has been committed. The
  // register write will happen only if both dcu_cp_reg_write_dc3 and
  // tlb_cp_reg_write_ready are asserted at the same time.
  // The DCU must hold this signal until the TLB is asserting ready.
  //  output dcu_cp_reg_write_dc3 valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_reg_write_dc3 X or Z")
  u_ovl_intf_x_dcu_cp_reg_write_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_reg_write_dc3));


  // There may be a write to a CP14/CP15 register on the next cycle.
  //  output dcu_cp_reg_write_active valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_reg_write_active X or Z")
  u_ovl_intf_x_dcu_cp_reg_write_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_reg_write_active));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3  => dcu_cp_reg_write_active@1")
  u_ovl_intf_assert_7461640de906afd235288856a29de965a4c42c50 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 ),
    .consequent_expr (dcu_cp_reg_write_active_reg));


  // The register being written
  //  output [5:0] dcu_cp_reg_en_dc3 valid dcu_cp_reg_write_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 6, OUTOPTIONS, "dcu_cp_reg_en_dc3 X or Z")
  u_ovl_intf_x_dcu_cp_reg_en_dc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_reg_write_dc3),
    .test_expr (dcu_cp_reg_en_dc3));


  // The data for a register write
  // - the upper 32-bits are only valid on a doubleword write
  // - the X-checking is suppressed on DBGDR writes, as the write data could be
  //   X if the simulation has not initialised the RAM before the debug op.
  assign cp_reg_data_valid_mask  = {64{dcu_cp_reg_write_dc3}} &                           {{32{dcu_cp_reg_size}}, {32{1'b1}}} &                  {64{~((dcu_cp_reg_en_dc3 == `CA53_CP15_REG_CDBGDR0) |    (dcu_cp_reg_en_dc3 == `CA53_CP15_REG_CDBGDR1) | (dcu_cp_reg_en_dc3 == `CA53_CP15_REG_CDBGDR2) | (dcu_cp_reg_en_dc3 == `CA53_CP15_REG_CDBGDR3))}};

  //  output [63:0] dcu_cp_reg_data valid mask cp_reg_data_valid_mask timing 60%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "dcu_cp_reg_data & (cp_reg_data_valid_mask) X or Z")
  u_ovl_intf_x_87b91bacd628f4f6b439f5ffd6ce76cd66af335d (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_reg_data & (cp_reg_data_valid_mask)));


  // The size of the register being written
  // - 1 => Doubleword, 0 => Word
  //  output dcu_cp_reg_size valid dcu_cp_reg_write_dc3 timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_reg_size X or Z")
  u_ovl_intf_x_dcu_cp_reg_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_reg_write_dc3),
    .test_expr (dcu_cp_reg_size));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3  => dcu_cp_reg_en_dc3 in [`CA53_CP15_REG_CDBGDR0,  `CA53_CP15_REG_CDBGDR1, `CA53_CP15_REG_CDBGDR2, `CA53_CP15_REG_CDBGDR3, `CA53_CP15_V2P_PAR, `CA53_CP15_REG_TTBR0_EL1, `CA53_CP15_REG_TTBR1_EL1, `CA53_CP15_REG_TCR_EL1, `CA53_CP15_REG_TTBR0_EL2, `CA53_CP15_REG_VTTBR_EL2, `CA53_CP15_REG_TCR_EL2, `CA53_CP15_REG_VTCR_EL2, `CA53_CP15_REG_PAR_EL1, `CA53_CP15_REG_MAIR_EL1, `CA53_CP15_REG_MAIR1, `CA53_CP15_REG_MAIR_EL2, `CA53_CP15_REG_HMAIR1, `CA53_CP15_REG_CTXTID_EL1, `CA53_CP15_REG_TTBR0_EL3, `CA53_CP15_REG_TCR_EL3, `CA53_CP15_REG_MAIR_EL3, `CA53_CP15_REG_DBGBVR0, `CA53_CP15_REG_DBGBVR1, `CA53_CP15_REG_DBGBVR2, `CA53_CP15_REG_DBGBVR3, `CA53_CP15_REG_DBGBVR4, `CA53_CP15_REG_DBGBVR5, `CA53_CP15_REG_DBGBCR0, `CA53_CP15_REG_DBGBCR1, `CA53_CP15_REG_DBGBCR2, `CA53_CP15_REG_DBGBCR3, `CA53_CP15_REG_DBGBCR4, `CA53_CP15_REG_DBGBCR5, `CA53_CP15_REG_DBGWVR0, `CA53_CP15_REG_DBGWVR1, `CA53_CP15_REG_DBGWVR2, `CA53_CP15_REG_DBGWVR3, `CA53_CP15_REG_DBGWCR0, `CA53_CP15_REG_DBGWCR1, `CA53_CP15_REG_DBGWCR2, `CA53_CP15_REG_DBGWCR3, `CA53_CP15_REG_DBGVCR, `CA53_CP15_REG_DBGBXVR4, `CA53_CP15_REG_DBGBXVR5]")
  u_ovl_intf_assert_90a9f37e6c6a03c6c8e47a571187a2eac78cc757 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 ),
    .consequent_expr (((dcu_cp_reg_en_dc3 == `CA53_CP15_REG_CDBGDR0) | (dcu_cp_reg_en_dc3 ==   `CA53_CP15_REG_CDBGDR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_CDBGDR2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_CDBGDR3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_V2P_PAR) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TTBR0_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TTBR1_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TCR_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TTBR0_EL2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_VTTBR_EL2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TCR_EL2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_VTCR_EL2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_PAR_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_MAIR_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_MAIR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_MAIR_EL2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_HMAIR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_CTXTID_EL1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TTBR0_EL3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_TCR_EL3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_MAIR_EL3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR0) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR4) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBVR5) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR0) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR4) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBCR5) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWVR0) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWVR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWVR2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWVR3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWCR0) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWCR1) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWCR2) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGWCR3) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGVCR) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBXVR4) | (dcu_cp_reg_en_dc3 ==  `CA53_CP15_REG_DBGBXVR5))));


  // Writes to the PAR for V2P instructions should always be marked as 64-bit.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3 & (dcu_cp_reg_en_dc3 == `CA53_CP15_V2P_PAR)  => dcu_cp_reg_size == 1'b1")
  u_ovl_intf_assert_1788bf06f2a717a5727afcfd49526ac0a34374e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 & (dcu_cp_reg_en_dc3 == `CA53_CP15_V2P_PAR) ),
    .consequent_expr (dcu_cp_reg_size == 1'b1));


  // The DCU must block lookups while it is trying to write to a CP register.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3  => dcu_block_lookups")
  u_ovl_intf_assert_9092055a1a5736a77962633de91f70e4021a8709 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 ),
    .consequent_expr (dcu_block_lookups));


  // If the TLB was ready last cycle and new requests cannot start this cycle
  // then it must remain ready.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_cp_reg_write_ready@1 & ~dcu_va_valid_dc1@1 & dcu_block_lookups  => tlb_cp_reg_write_ready")
  u_ovl_intf_assume_175696694600db873fd95fac3003f9c39c9116cf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_cp_reg_write_ready_reg & ~dcu_va_valid_dc1_reg & dcu_block_lookups ),
    .consequent_expr (tlb_cp_reg_write_ready));


  // A register write must remain in dc3 until the TLB has acked it.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3@1 & ~tlb_cp_reg_write_ready@1  => dcu_cp_reg_write_dc3")
  u_ovl_intf_assert_1912612e44d599a328a3ab194d121bb93fc493cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3_reg & ~tlb_cp_reg_write_ready_reg ),
    .consequent_expr (dcu_cp_reg_write_dc3));


  // The register enable must remain constant throughout a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3@1 & ~tlb_cp_reg_write_ready@1  => dcu_cp_reg_en_dc3 == dcu_cp_reg_en_dc3@1")
  u_ovl_intf_assert_5a2b3a1353585bd67b5d02c5056452c2f1c41749 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3_reg & ~tlb_cp_reg_write_ready_reg ),
    .consequent_expr (dcu_cp_reg_en_dc3 == dcu_cp_reg_en_dc3_reg));


  // The data to write must remain constant throughout a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3@1 & ~tlb_cp_reg_write_ready@1  => dcu_cp_reg_data == dcu_cp_reg_data@1")
  u_ovl_intf_assert_2290b850c519e985fbaf2115192243eefd96ac74 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3_reg & ~tlb_cp_reg_write_ready_reg ),
    .consequent_expr (dcu_cp_reg_data == dcu_cp_reg_data_reg));


  // The DCU must not make a new traslation request the same cycle or the cycle
  // after a register write.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3  => ~dcu_va_valid_dc1")
  u_ovl_intf_assert_6a89b67cefd249a7e1367520be4b3e4f010de002 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 ),
    .consequent_expr (~dcu_va_valid_dc1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3@1  => ~dcu_va_valid_dc1")
  u_ovl_intf_assert_670d139f6ece828a0670b3a5762450dd426d7bc3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3_reg ),
    .consequent_expr (~dcu_va_valid_dc1));


  // The DCU must not be in the middle of a burst during or the cycle after a
  // register write.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3  => ~dcu_ongoing_burst_dc1")
  u_ovl_intf_assert_b127799ae0b3f0fa748411c15a05bd3dee82ca0c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3 ),
    .consequent_expr (~dcu_ongoing_burst_dc1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_reg_write_dc3@1  => ~dcu_ongoing_burst_dc1")
  u_ovl_intf_assert_e3d0f22d910babaf57b7db7c9f704091c441177d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_reg_write_dc3_reg ),
    .consequent_expr (~dcu_ongoing_burst_dc1));



  //----------------------------------------------------------------------------
  //
  // CP15 maintenance interface (from dc3 or DVM)
  //
  //----------------------------------------------------------------------------

  // A CP15 TLB maintenance op is in dc3 and has been committed.
  // This signal is held until the TLB has acknowledged it.
  //  output dcu_cp_valid_tlb valid always timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_valid_tlb X or Z")
  u_ovl_intf_x_dcu_cp_valid_tlb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_valid_tlb));


  // The address/VMID/ASID for TLB maintenance ops:
  //   8  bits i.e. bits [61:54] are VMID
  //   1  bit  i.e. bit     [53] indicates whether a VMID is specified - this is not valid on secure invalidate all requests, as dcu_cp_addr_tlb is unknown in this case
  //   16 bits i.e. bits [52:37] are ASID
  //   37 bits i.e. bits  [36:0] are MVA (VA[48:12])


  assign cp_addr_valid  = {62{dcu_cp_valid_tlb}} & ({ {8{dcu_cp_addr_tlb[53] & (dcu_cp_op_tlb != `CA53_CP_TLBI_ALL_ON_RST)}},  (dcu_cp_op_tlb != `CA53_CP_TLBI_ALL_ON_RST),  {16{((dcu_cp_op_tlb == `CA53_CP_TLBI_VAE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VALE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_ASIDE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VAALE1))}},  {37{((dcu_cp_op_tlb == `CA53_CP_TLBI_VAE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VALE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VAAE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VAALE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_IPAS2LE1) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VAE2) | (dcu_cp_op_tlb ==   `CA53_CP_TLBI_VALE2) | (dcu_cp_op_tlb ==  `CA53_CP_TLBI_VAE3) | (dcu_cp_op_tlb ==    `CA53_CP_TLBI_VALE3))}} } | {62{dcu_cp_op_tlb == `CA53_CP_TLB_DBG}});

  //  output [61:0] dcu_cp_addr_tlb valid mask cp_addr_valid timing 60%

  assert_never_unknown #(`OVL_FATAL, 62, OUTOPTIONS, "dcu_cp_addr_tlb & (cp_addr_valid) X or Z")
  u_ovl_intf_x_5f5eb952bf80d83c96ee6a557ff9bbc4ce45c30e (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cp_addr_tlb & (cp_addr_valid)));



  // The TrustZone non-secure bit of the cp op. This will be the same as
  // dpu_ns_state if the op is from the local processor, but may be
  // different if it was broadcast from a different processor.
  //  output dcu_cp_ns valid dcu_cp_valid_tlb timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dcu_cp_ns X or Z")
  u_ovl_intf_x_dcu_cp_ns (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_valid_tlb),
    .test_expr (dcu_cp_ns));


   // unused                       5'b00010
   // unused                       5'b01101  // unused CA53_CP_TLBI_IPAS2E1 and CA53_CP_TLBI_IPAS2LE1 are same

  // The CP15 maintenance operation being performed.
  //  output [4:0] dcu_cp_op_tlb valid dcu_cp_valid_tlb timing 40%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "dcu_cp_op_tlb X or Z")
  u_ovl_intf_x_dcu_cp_op_tlb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cp_valid_tlb),
    .test_expr (dcu_cp_op_tlb));


  // The TLB has performed the maintenance op.
  // This may be asserted on the same cycle as the write request starts, or an
  // arbitrary number of cycles later.
  //  input tlb_cp_ack valid always timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_cp_ack X or Z")
  u_ovl_intf_x_tlb_cp_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_cp_ack));


  // The TLB should not ack if there was nothing being sent to it.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_cp_ack  => dcu_cp_valid_tlb")
  u_ovl_intf_assume_c0312f082b0ee8958f0dcc51d0a8d177dd0c2ab2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_cp_ack ),
    .consequent_expr (dcu_cp_valid_tlb));


  // The TLB should only assert tlb_cp_ack for one cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_cp_ack  => ~tlb_cp_ack@1")
  u_ovl_intf_assume_a03fced72cf58cf079e60a080d455dbe5fae2c33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_cp_ack ),
    .consequent_expr (~tlb_cp_ack_reg));


  // A maintenance op must remain in dc3 until the TLB has acked it.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_cp_valid_tlb@1) & ~tlb_cp_ack@1  => dcu_cp_valid_tlb")
  u_ovl_intf_assert_e1d5781d31d9aba93c78fc921044e4250c3c2bc8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_cp_valid_tlb_reg) & ~tlb_cp_ack_reg ),
    .consequent_expr (dcu_cp_valid_tlb));


  // The non-secure state must remain constant throughout a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_valid_tlb@1 & ~tlb_cp_ack@1  => dcu_cp_ns == dcu_cp_ns@1")
  u_ovl_intf_assert_aa68dbbba512421c211f07448c9603c5493d2260 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_valid_tlb_reg & ~tlb_cp_ack_reg ),
    .consequent_expr (dcu_cp_ns == dcu_cp_ns_reg));


  // The address/ASID/VMID must remain constant throughout a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_valid_tlb@1 & ~tlb_cp_ack@1  => (dcu_cp_addr_tlb & cp_addr_valid) == (dcu_cp_addr_tlb@1 & cp_addr_valid@1)")
  u_ovl_intf_assert_2699894d5b4de2e6ff4242d5308c6f2fbcf2d3df (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_valid_tlb_reg & ~tlb_cp_ack_reg ),
    .consequent_expr ((dcu_cp_addr_tlb & cp_addr_valid) == (dcu_cp_addr_tlb_reg & cp_addr_valid_reg)));


  // The type of maintenance op must remain constant throughout a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dcu_cp_valid_tlb@1 & ~tlb_cp_ack@1  => dcu_cp_op_tlb == dcu_cp_op_tlb@1")
  u_ovl_intf_assert_c97a612e6366cacc1208b93c75f6f521c13786c6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cp_valid_tlb_reg & ~tlb_cp_ack_reg ),
    .consequent_expr (dcu_cp_op_tlb == dcu_cp_op_tlb_reg));


  // TLB RAM DBG Reads should always be in secure state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_cp_op_tlb == `CA53_CP_TLB_DBG) & dcu_cp_valid_tlb  => ~dcu_cp_ns")
  u_ovl_intf_assert_abfe6f585f3bf700d1e5b2f24f13aa2c583d81b7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_cp_op_tlb == `CA53_CP_TLB_DBG) & dcu_cp_valid_tlb ),
    .consequent_expr (~dcu_cp_ns));


  // TLB DBG RAM reads will not issue on the CP op interface when block_lookups
  // is asserted

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(dcu_cp_op_tlb == `CA53_CP_TLB_DBG) & dcu_cp_valid_tlb  => ~dcu_block_lookups")
  u_ovl_intf_assert_4ab2e471caafb648c1437fc71b3ddab738647a00 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((dcu_cp_op_tlb == `CA53_CP_TLB_DBG) & dcu_cp_valid_tlb ),
    .consequent_expr (~dcu_block_lookups));



  //----------------------------------------------------------------------------
  //
  // Misc signals
  //
  //----------------------------------------------------------------------------

  // TCR.TBI signals
  // EL1 TBI is a two bit signal giving TCR_EL1{TBI1,TBI0},
  //  input [1:0]    tlb_d_tcr_el1_tbi    valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_d_tcr_el1_tbi X or Z")
  u_ovl_intf_x_tlb_d_tcr_el1_tbi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el1_tbi));

  //  input          tlb_d_tcr_el2_tbi0   valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el2_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el2_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el2_tbi0));

  //  input          tlb_d_tcr_el3_tbi0   valid always timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el3_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el3_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el3_tbi0));


  // The current VMID in the TLB.
  //  input [7:0] tlb_vmid valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "tlb_vmid X or Z")
  u_ovl_intf_x_tlb_vmid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_vmid));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_dcu_tlb_defs.v"
`undef CA53_UNDEFINE

`endif

