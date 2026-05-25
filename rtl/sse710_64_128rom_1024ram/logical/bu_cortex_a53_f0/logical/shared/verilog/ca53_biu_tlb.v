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


// This is the specification for the interface between the BIU and TLB

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_biu_tlb_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"

module ca53_biu_tlb #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [1:0] tlb_mem_granule_i,
  input         tlb_walk_lf_active_i,
  input         tlb_walk_nc_req_i,
  input         tlb_walk_lf_req_i,
  input  [39:0] tlb_walk_addr_i,
  input         tlb_walk_ns_dsc_i,
  input         tlb_walk_size_i,
  input   [7:0] tlb_walk_attrs_i,
  input   [1:0] tlb_walk_way_i,
  input [116:0] tlb_mbist_out_data_mb6_i,
  input         gov_mbist_req_i,
  input  [61:0] dcu_cp_addr_tlb_i,
  input         biu_walk_ack_i,
  input   [2:0] biu_walk_resp_i,
  input  [63:0] biu_walk_data_i,
  input         biu_walk_lf_hazard_i,
  input  [52:0] biu_mbist_in_data_hi_mb3_i);


  wire   [1:0] tlb_mem_granule = tlb_mem_granule_i;
  wire         tlb_walk_lf_active = tlb_walk_lf_active_i;
  wire         tlb_walk_nc_req = tlb_walk_nc_req_i;
  wire         tlb_walk_lf_req = tlb_walk_lf_req_i;
  wire  [39:0] tlb_walk_addr = tlb_walk_addr_i;
  wire         tlb_walk_ns_dsc = tlb_walk_ns_dsc_i;
  wire         tlb_walk_size = tlb_walk_size_i;
  wire   [7:0] tlb_walk_attrs = tlb_walk_attrs_i;
  wire   [1:0] tlb_walk_way = tlb_walk_way_i;
  wire [116:0] tlb_mbist_out_data_mb6 = tlb_mbist_out_data_mb6_i;
  wire         gov_mbist_req = gov_mbist_req_i;
  wire  [61:0] dcu_cp_addr_tlb = dcu_cp_addr_tlb_i;
  wire         biu_walk_ack = biu_walk_ack_i;
  wire   [2:0] biu_walk_resp = biu_walk_resp_i;
  wire  [63:0] biu_walk_data = biu_walk_data_i;
  wire         biu_walk_lf_hazard = biu_walk_lf_hazard_i;
  wire  [52:0] biu_mbist_in_data_hi_mb3 = biu_mbist_in_data_hi_mb3_i;

  wire         tlb_mbist_en_mb6;
  wire         tlb_mbist_read_en_mb6;
  wire         tlb_mbist_en_mb3;

  reg         tlb_walk_lf_req_held;

  reg         tlb_walk_ns_dsc_reg;
  reg  [61:0] dcu_cp_addr_tlb_reg;
  reg  [61:0] dcu_cp_addr_tlb_reg_reg;
  reg  [61:0] dcu_cp_addr_tlb_reg_reg_reg;
  reg         tlb_walk_nc_req_reg;
  reg  [39:0] tlb_walk_addr_reg;
  reg   [7:0] tlb_walk_attrs_reg;
  reg         biu_walk_ack_reg;
  reg         tlb_walk_lf_req_reg;
  reg         tlb_walk_lf_active_reg;
  reg         tlb_mbist_en_mb3_reg;
  reg         tlb_mbist_en_mb3_reg_reg;
  reg         tlb_mbist_en_mb3_reg_reg_reg;
  reg         tlb_walk_lf_req_held_reg;
  reg         biu_walk_lf_hazard_reg;
  reg         tlb_walk_size_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    tlb_walk_ns_dsc_reg <= 1'b0;
    dcu_cp_addr_tlb_reg <= {62{1'b0}};
    dcu_cp_addr_tlb_reg_reg <= {62{1'b0}};
    dcu_cp_addr_tlb_reg_reg_reg <= {62{1'b0}};
    tlb_walk_nc_req_reg <= 1'b0;
    tlb_walk_addr_reg <= {40{1'b0}};
    tlb_walk_attrs_reg <= {8{1'b0}};
    biu_walk_ack_reg <= 1'b0;
    tlb_walk_lf_req_reg <= 1'b0;
    tlb_walk_lf_active_reg <= 1'b0;
    tlb_mbist_en_mb3_reg <= 1'b0;
    tlb_mbist_en_mb3_reg_reg <= 1'b0;
    tlb_mbist_en_mb3_reg_reg_reg <= 1'b0;
    tlb_walk_lf_req_held_reg <= 1'b0;
    biu_walk_lf_hazard_reg <= 1'b0;
    tlb_walk_size_reg <= 1'b0;
  end
  else
  begin
    tlb_walk_lf_active_reg <= tlb_walk_lf_active;
    tlb_walk_nc_req_reg <= tlb_walk_nc_req;
    tlb_walk_lf_req_reg <= tlb_walk_lf_req;
    tlb_walk_addr_reg <= tlb_walk_addr;
    tlb_walk_ns_dsc_reg <= tlb_walk_ns_dsc;
    tlb_walk_size_reg <= tlb_walk_size;
    tlb_walk_attrs_reg <= tlb_walk_attrs;
    dcu_cp_addr_tlb_reg <= dcu_cp_addr_tlb;
    dcu_cp_addr_tlb_reg_reg <= dcu_cp_addr_tlb_reg;
    dcu_cp_addr_tlb_reg_reg_reg <= dcu_cp_addr_tlb_reg_reg;
    biu_walk_ack_reg <= biu_walk_ack;
    biu_walk_lf_hazard_reg <= biu_walk_lf_hazard;
    tlb_mbist_en_mb3_reg <= tlb_mbist_en_mb3;
    tlb_mbist_en_mb3_reg_reg <= tlb_mbist_en_mb3_reg;
    tlb_mbist_en_mb3_reg_reg_reg <= tlb_mbist_en_mb3_reg_reg;
    tlb_walk_lf_req_held_reg <= tlb_walk_lf_req_held;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // The size of the memory granule:
  // 2'b00:  4k
  // 2'b01: 16k
  // 2'b11: 64k
  //  input [1:0] tlb_mem_granule valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_mem_granule X or Z")
  u_ovl_intf_x_tlb_mem_granule (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_mem_granule));


  // The TLB may request a new linefill in the following clock cycle
  //  input tlb_walk_lf_active valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_walk_lf_active X or Z")
  u_ovl_intf_x_tlb_walk_lf_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_walk_lf_active));


  // The two request signals can be used to request a non-cacheable page table
  // descriptor or a linefill.
  // They are mutually exclusive signals. These request signals cannot be
  // deasserted to terminate a request, therefore rely on the acknowledge
  // signal coming back from the BIU to resume operations and complete the
  // pagewalk.
  //  input tlb_walk_nc_req valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_walk_nc_req X or Z")
  u_ovl_intf_x_tlb_walk_nc_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_walk_nc_req));

  //  input tlb_walk_lf_req valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_walk_lf_req X or Z")
  u_ovl_intf_x_tlb_walk_lf_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_walk_lf_req));


  // The address of the desciptor in an ongoing pagewalk. 
  // It is used by the BIU to fetch non-cacheable pagewalk desciptors, start
  // linefills and for monitoring linefill/eviction hazards when looking up
  // in the cache. 
  //  input [39:0] tlb_walk_addr valid tlb_walk_nc_req | tlb_walk_lf_req timing 20%

  assert_never_unknown #(`OVL_FATAL, 40, INOPTIONS, "tlb_walk_addr X or Z")
  u_ovl_intf_x_tlb_walk_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_nc_req | tlb_walk_lf_req),
    .test_expr (tlb_walk_addr));


  // Indicates that the requested descriptor is fetched from non-secure memory space. 
  //  input tlb_walk_ns_dsc valid tlb_walk_nc_req | tlb_walk_lf_req timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_walk_ns_dsc X or Z")
  u_ovl_intf_x_tlb_walk_ns_dsc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_nc_req | tlb_walk_lf_req),
    .test_expr (tlb_walk_ns_dsc));


  // The size of the transaction, only required for NC requests.
  // 0 - 32 bits
  // 1 - 64 bits
  //  input tlb_walk_size valid tlb_walk_nc_req timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_walk_size X or Z")
  u_ovl_intf_x_tlb_walk_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_nc_req),
    .test_expr (tlb_walk_size));



  //  The memory type that the walk is being performed to.
  //  input [7:0] tlb_walk_attrs valid tlb_walk_nc_req | tlb_walk_lf_req timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "tlb_walk_attrs X or Z")
  u_ovl_intf_x_tlb_walk_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_nc_req | tlb_walk_lf_req),
    .test_expr (tlb_walk_attrs));


  // The suggested victim way to perform a linefill to, if a linefill request is being made.
  //  input [1:0] tlb_walk_way valid tlb_walk_lf_req timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_walk_way X or Z")
  u_ovl_intf_x_tlb_walk_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_lf_req),
    .test_expr (tlb_walk_way));


  // The BIU raises ack as a response to an ongoing descriptor request when
  // data becomes available on the data bus.
  //  output biu_walk_ack valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_walk_ack X or Z")
  u_ovl_intf_x_biu_walk_ack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_walk_ack));


  // BIU Response mirrors AXI responses
  // bit[1:0]:
  // OK
  // EXOK (Treated as abort - Slave Error)
  // Slave Error
  // Decode Error
  // bit[2]:
  // ECC Error
  //  output [2:0] biu_walk_resp valid biu_walk_ack timing 40%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "biu_walk_resp X or Z")
  u_ovl_intf_x_biu_walk_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_walk_ack),
    .test_expr (biu_walk_resp));


  // The data from the BIU. The TLB must select the upper or lower 32bits based
  // upon the address it requested.
  //  output [63:0] biu_walk_data valid biu_walk_ack timing 50%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "biu_walk_data X or Z")
  u_ovl_intf_x_biu_walk_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_walk_ack),
    .test_expr (biu_walk_data));


  // The address of the pagewalk matches a linefill currently in progress.
  // This is valid when the TLB pagewalk FSM is non-IDLE but as this information
  // is not available on the interface, it is marked valid tlb_walk_lf_req which
  // covers some of this time.
  //  output biu_walk_lf_hazard valid tlb_walk_lf_req timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_walk_lf_hazard X or Z")
  u_ovl_intf_x_biu_walk_lf_hazard (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_walk_lf_req),
    .test_expr (biu_walk_lf_hazard));



  // ------------------------------------------------------
  // MBIST interface
  // ------------------------------------------------------


  // The upper bits (bits [116:64]) of the input data to write to the RAMs
  // (the lower 64 bits re-use biu_walk_data)
  //  output [52:0] biu_mbist_in_data_hi_mb3 valid gov_mbist_req timing 40%

  assert_never_unknown #(`OVL_FATAL, 53, OUTOPTIONS, "biu_mbist_in_data_hi_mb3 X or Z")
  u_ovl_intf_x_biu_mbist_in_data_hi_mb3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (gov_mbist_req),
    .test_expr (biu_mbist_in_data_hi_mb3));



  // MBIST enable to TLB, delayed by 3-clock cycles
                            //MBIST req     //MBIST select        // TLB RAMs selected
  assign tlb_mbist_en_mb3  = gov_mbist_req & dcu_cp_addr_tlb[34] & (dcu_cp_addr_tlb[24:21] == 4'b0100);
  assign tlb_mbist_en_mb6  = tlb_mbist_en_mb3_reg_reg_reg;

  // DCU to TLB read enable delayed by 3-clock cycles
  assign tlb_mbist_read_en_mb6  = dcu_cp_addr_tlb_reg_reg_reg[32];

  // The output data read from the TLB RAMs 
  //  input [116:0] tlb_mbist_out_data_mb6 valid tlb_mbist_en_mb6 & tlb_mbist_read_en_mb6 timing 20%

  assert_never_unknown #(`OVL_FATAL, 117, INOPTIONS, "tlb_mbist_out_data_mb6 X or Z")
  u_ovl_intf_x_tlb_mbist_out_data_mb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_mbist_en_mb6 & tlb_mbist_read_en_mb6),
    .test_expr (tlb_mbist_out_data_mb6));

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

  // The memory granule cannot be encoded as 2'b10 (unsupported encoding at the BIU level)

  assert_always #(`OVL_FATAL, INOPTIONS, "(tlb_mem_granule != 2'b10)")
  u_ovl_intf_assume_3d8974f72d995665c788e69a135d791157527c2a (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ((tlb_mem_granule != 2'b10)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tlb_walk_lf_req_held <= 1'b0;
  else
    tlb_walk_lf_req_held <= (tlb_walk_lf_req | tlb_walk_lf_req_held) & ~(tlb_walk_lf_req_held & (biu_walk_ack | (biu_walk_lf_hazard_reg & ~biu_walk_lf_hazard) | (~biu_walk_lf_hazard & ~tlb_walk_lf_req)));


  // The TLB cannot request a linefill and a non-cacheable walk at the same time.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req  => ~(tlb_walk_lf_req | tlb_walk_lf_req_held)")
  u_ovl_intf_assume_ba7253840d1d99b01caef1cacf39135f7d795416 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req ),
    .consequent_expr (~(tlb_walk_lf_req | tlb_walk_lf_req_held)));


  // The BIU must only send an ack in response to a request.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_walk_ack  => tlb_walk_nc_req | tlb_walk_lf_req_held")
  u_ovl_intf_assert_0ade0c9059a144bc9119bad66eb4ee37432f0d04 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_walk_ack ),
    .consequent_expr (tlb_walk_nc_req | tlb_walk_lf_req_held));


  // The BIU should only assert biu_walk_ack for 1 cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_walk_ack  => ~biu_walk_ack@1")
  u_ovl_intf_assert_caa21bfaf56a5227f3b98d868edad86478a14801 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_walk_ack ),
    .consequent_expr (~biu_walk_ack_reg));


  // If a non-cacheable request is sent, an acknowledge must be seen before it is deasserted. 

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req@1 & ~biu_walk_ack@1  => tlb_walk_nc_req")
  u_ovl_intf_assume_af9d769392787f025d0717cca548c97231386907 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req_reg & ~biu_walk_ack_reg ),
    .consequent_expr (tlb_walk_nc_req));


  // If a linefill request is sent, an acknowledge must not be seen before a linefill hazard.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "tlb_walk_lf_req & ~biu_walk_lf_hazard  => ~biu_walk_ack")
  u_ovl_intf_assert_c763ee6dab04aad1742e3255831bf1333ff36c20 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_lf_req & ~biu_walk_lf_hazard ),
    .consequent_expr (~biu_walk_ack));


  // The TLB must stop requesting a linefill when it sees a linefill hazard.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_lf_req@1 & biu_walk_lf_hazard@1  => ~tlb_walk_lf_req")
  u_ovl_intf_assume_e441d2330a8a1ce939ee603388d4389e5341480c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_lf_req_reg & biu_walk_lf_hazard_reg ),
    .consequent_expr (~tlb_walk_lf_req));


  // If a linefill hazard goes away then the TLB must stop requesting a linefill (until it has redone the tag lookup).

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_lf_req_held@1 & biu_walk_lf_hazard@1 & ~biu_walk_lf_hazard  => ~tlb_walk_lf_req")
  u_ovl_intf_assume_54d5dbb02fdf6ec0ff9219647d4496b15efff0a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_lf_req_held_reg & biu_walk_lf_hazard_reg & ~biu_walk_lf_hazard ),
    .consequent_expr (~tlb_walk_lf_req));


  // If there is an ongoing request which is not acknowledged, the address shouldn't change. 

  assert_implication #(`OVL_FATAL, INOPTIONS, "(tlb_walk_nc_req@1 | tlb_walk_lf_req_held) & ~biu_walk_ack@1  => (tlb_walk_addr == tlb_walk_addr@1)")
  u_ovl_intf_assume_bd713da9f1b432158ccc70008756c8cd66ca3c12 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tlb_walk_nc_req_reg | tlb_walk_lf_req_held) & ~biu_walk_ack_reg ),
    .consequent_expr ((tlb_walk_addr == tlb_walk_addr_reg)));


  // If there is an ongoing request which is not acknowledged, the attributes shouldn't change

  assert_implication #(`OVL_FATAL, INOPTIONS, "(tlb_walk_nc_req@1 | tlb_walk_lf_req_held) & ~biu_walk_ack@1  => (tlb_walk_attrs == tlb_walk_attrs@1)")
  u_ovl_intf_assume_28e545213169cb0a3e9bf5a508f4933cbd99242d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tlb_walk_nc_req_reg | tlb_walk_lf_req_held) & ~biu_walk_ack_reg ),
    .consequent_expr ((tlb_walk_attrs == tlb_walk_attrs_reg)));


  // If there is an ongoing request which is not acknowledged, the secure attributes shouldn't change

  assert_implication #(`OVL_FATAL, INOPTIONS, "(tlb_walk_nc_req@1 | tlb_walk_lf_req_held) & ~biu_walk_ack@1  => (tlb_walk_ns_dsc == tlb_walk_ns_dsc@1)")
  u_ovl_intf_assume_0e78625cfbb288f739b3c8bebc18c1374878d848 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tlb_walk_nc_req_reg | tlb_walk_lf_req_held) & ~biu_walk_ack_reg ),
    .consequent_expr ((tlb_walk_ns_dsc == tlb_walk_ns_dsc_reg)));


  // If there is an ongoing request which is not acknowledged, the size shouldn't change

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req@1 & ~biu_walk_ack@1  => (tlb_walk_size == tlb_walk_size@1)")
  u_ovl_intf_assume_904d8844313eddef885d2584f40047002e9ef720 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req_reg & ~biu_walk_ack_reg ),
    .consequent_expr ((tlb_walk_size == tlb_walk_size_reg)));


  // Only some attributes are generated by the TLB.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req | tlb_walk_lf_req  => ~`CA53_MEM_UNUSED(tlb_walk_attrs)")
  u_ovl_intf_assume_26a1edc42919fed0ef4a94dbc2b12b7c8bd127b4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req | tlb_walk_lf_req ),
    .consequent_expr (~`CA53_MEM_UNUSED(tlb_walk_attrs)));


  // The address must be aligned to the transaction size.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req & (tlb_walk_size == 1'b0)  => tlb_walk_addr[1:0] == 2'b00")
  u_ovl_intf_assume_f1c6d9acb2c3c6ad3698537e152afa94cd2a180a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req & (tlb_walk_size == 1'b0) ),
    .consequent_expr (tlb_walk_addr[1:0] == 2'b00));


  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_nc_req & (tlb_walk_size == 1'b1)  => tlb_walk_addr[2:0] == 3'b000")
  u_ovl_intf_assume_70156f26fd17a660f7fa0486a0d81ad150f1dfc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_nc_req & (tlb_walk_size == 1'b1) ),
    .consequent_expr (tlb_walk_addr[2:0] == 3'b000));


  // The TLB only requests linefills to coherent memory.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_lf_req  => `CA53_MEM_COHERENT(tlb_walk_attrs)")
  u_ovl_intf_assume_dba2058ba952d95a5fdec46ba276ec9002ffaf59 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_lf_req ),
    .consequent_expr (`CA53_MEM_COHERENT(tlb_walk_attrs)));


  // The TLB linefill must have been previously active if a linefill request is made

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_walk_lf_req  => tlb_walk_lf_active@1")
  u_ovl_intf_assume_c4a7ad3754d8c14cf9814a8490c72386b06b7935 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_walk_lf_req ),
    .consequent_expr (tlb_walk_lf_active_reg));



endmodule

`define CA53_UNDEFINE
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_biu_tlb_defs.v"
`undef CA53_UNDEFINE

`endif

