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

// This is the specification for the interface between the DCU and rams


// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_dcu_rams_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_dcu_rams #(parameter CPU_CACHE_PROTECTION = 0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input   [2:0] dc_size_i,
  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata0_i,
  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata1_i,
  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata2_i,
  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata3_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata0_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata1_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata2_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata3_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata4_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata5_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata6_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata7_i,
  input [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_rdata_i,
  input   [3:0] dc_tagram_en_i,
  input         dc_tagram_wr_i,
  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_wdata_i,
  input   [7:0] dc_tagram_addr_i,
  input   [7:0] dc_dataram_en_i,
  input         dc_dataram_wr_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb0_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb1_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb2_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb3_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb4_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb5_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb6_i,
  input [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb7_i,
  input  [10:0] dc_dataram_addr0_i,
  input  [10:0] dc_dataram_addr1_i,
  input  [10:0] dc_dataram_addr2_i,
  input  [10:0] dc_dataram_addr3_i,
  input  [10:0] dc_dataram_addr4_i,
  input  [10:0] dc_dataram_addr5_i,
  input  [10:0] dc_dataram_addr6_i,
  input  [10:0] dc_dataram_addr7_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata0_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata1_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata2_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata3_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata4_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata5_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata6_i,
  input [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata7_i,
  input         dc_dirtyram_en_i,
  input         dc_dirtyram_wr_i,
  input [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_strb_i,
  input   [8:0] dc_dirtyram_addr_i,
  input [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_wdata_i);


  wire   [2:0] dc_size = dc_size_i;
  wire [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata0 = dc_tagram_rdata0_i;
  wire [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata1 = dc_tagram_rdata1_i;
  wire [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata2 = dc_tagram_rdata2_i;
  wire [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata3 = dc_tagram_rdata3_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata0 = dc_dataram_rdata0_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata1 = dc_dataram_rdata1_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata2 = dc_dataram_rdata2_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata3 = dc_dataram_rdata3_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata4 = dc_dataram_rdata4_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata5 = dc_dataram_rdata5_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata6 = dc_dataram_rdata6_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_rdata7 = dc_dataram_rdata7_i;
  wire [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_rdata = dc_dirtyram_rdata_i;
  wire   [3:0] dc_tagram_en = dc_tagram_en_i;
  wire         dc_tagram_wr = dc_tagram_wr_i;
  wire [(`CA53_DTAG_RAM_W-1):0] dc_tagram_wdata = dc_tagram_wdata_i;
  wire   [7:0] dc_tagram_addr = dc_tagram_addr_i;
  wire   [7:0] dc_dataram_en = dc_dataram_en_i;
  wire         dc_dataram_wr = dc_dataram_wr_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb0 = dc_dataram_strb0_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb1 = dc_dataram_strb1_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb2 = dc_dataram_strb2_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb3 = dc_dataram_strb3_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb4 = dc_dataram_strb4_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb5 = dc_dataram_strb5_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb6 = dc_dataram_strb6_i;
  wire [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb7 = dc_dataram_strb7_i;
  wire  [10:0] dc_dataram_addr0 = dc_dataram_addr0_i;
  wire  [10:0] dc_dataram_addr1 = dc_dataram_addr1_i;
  wire  [10:0] dc_dataram_addr2 = dc_dataram_addr2_i;
  wire  [10:0] dc_dataram_addr3 = dc_dataram_addr3_i;
  wire  [10:0] dc_dataram_addr4 = dc_dataram_addr4_i;
  wire  [10:0] dc_dataram_addr5 = dc_dataram_addr5_i;
  wire  [10:0] dc_dataram_addr6 = dc_dataram_addr6_i;
  wire  [10:0] dc_dataram_addr7 = dc_dataram_addr7_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata0 = dc_dataram_wdata0_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata1 = dc_dataram_wdata1_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata2 = dc_dataram_wdata2_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata3 = dc_dataram_wdata3_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata4 = dc_dataram_wdata4_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata5 = dc_dataram_wdata5_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata6 = dc_dataram_wdata6_i;
  wire [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata7 = dc_dataram_wdata7_i;
  wire         dc_dirtyram_en = dc_dirtyram_en_i;
  wire         dc_dirtyram_wr = dc_dirtyram_wr_i;
  wire [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_strb = dc_dirtyram_strb_i;
  wire   [8:0] dc_dirtyram_addr = dc_dirtyram_addr_i;
  wire [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_wdata = dc_dirtyram_wdata_i;

  wire  [38:0] wdata5_valid;
  wire  [38:0] wdata4_valid;
  wire  [38:0] wdata6_valid;
  wire  [38:0] wdata3_valid;
  wire  [38:0] wdata0_valid;
  wire         dirty_way_0_strb;
  wire  [38:0] wdata7_valid;
  wire         dirty_way_3_strb;
  wire  [38:0] wdata2_valid;
  wire         dirty_way_2_strb;
  wire         dirty_way_1_strb;
  wire   [7:0] tagram_addr_valid_mask;
  wire  [38:0] wdata1_valid;

  reg         out_of_reset;

  reg   [2:0] dc_size_reg;
  reg   [3:0] dc_tagram_en_reg;
  reg         dc_tagram_wr_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dc_size_reg <= 3'b000;
    dc_tagram_en_reg <= 4'b0000;
    dc_tagram_wr_reg <= 1'b0;
  end
  else
  begin
    dc_size_reg <= dc_size;
    dc_tagram_en_reg <= dc_tagram_en;
    dc_tagram_wr_reg <= dc_tagram_wr;
  end



  //-----------------------------------------------------------------------------
  //
  // RAM sizes
  //
  //-----------------------------------------------------------------------------

  //  input [2:0]    dc_size           valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dc_size X or Z")
  u_ovl_intf_x_dc_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_size));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // The RAM size cannot change outside of reset.

  assert_implication #(`OVL_FATAL, INOPTIONS, "out_of_reset  => dc_size == dc_size@1")
  u_ovl_intf_assume_ba11dcffa9a7b279d8422ce8185e8fc294a63179 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset ),
    .consequent_expr (dc_size == dc_size_reg));


  //-----------------------------------------------------------------------------
  //
  // Tag RAM signals
  //
  //-----------------------------------------------------------------------------

  // Encoding for the tag RAM is:
  // MM nS Tag[39:n]
  //
  // Where MM  = Partial MOESI state
  //       nS  = Non-secure state of the line
  //       Tag = Tag used for lookup comparisons. The value of n depends on the cache size (8KB => n=11, 64KB => n=14)

  // Enable for each RAM bank.
  //  output [3:0] dc_tagram_en valid always timing 55%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "dc_tagram_en X or Z")
  u_ovl_intf_x_dc_tagram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_tagram_en));


  // The access is a write.
  //  output dc_tagram_wr valid always timing 45%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dc_tagram_wr X or Z")
  u_ovl_intf_x_dc_tagram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_tagram_wr));


  // The data to write to the RAM.
  //  output [(`CA53_DTAG_RAM_W-1):0] dc_tagram_wdata valid |dc_tagram_en & dc_tagram_wr timing 70%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DTAG_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_tagram_wdata X or Z")
  u_ovl_intf_x_dc_tagram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|dc_tagram_en & dc_tagram_wr),
    .test_expr (dc_tagram_wdata));


  // The index of the RAM to access.
  // - The top bits are not used for cache sizes smaller than the maximum.
  assign tagram_addr_valid_mask  = {dc_size_i, 5'b11111} & {8{|dc_tagram_en}};

  //  output [7:0] dc_tagram_addr valid mask tagram_addr_valid_mask timing 45%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dc_tagram_addr & (tagram_addr_valid_mask) X or Z")
  u_ovl_intf_x_dd71ffa53efa5568e4d3874102ef8dcb1409db80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_tagram_addr & (tagram_addr_valid_mask)));


  // The read data from the RAM, returned in the cycle after the enable.
  //  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata0  valid dc_tagram_en@1[0] & ~dc_tagram_wr@1 timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DTAG_RAM_W-1)) - (0) + 1), INOPTIONS, "dc_tagram_rdata0 X or Z")
  u_ovl_intf_x_dc_tagram_rdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_tagram_en_reg[0] & ~dc_tagram_wr_reg),
    .test_expr (dc_tagram_rdata0));

  //  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata1  valid dc_tagram_en@1[1] & ~dc_tagram_wr@1 timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DTAG_RAM_W-1)) - (0) + 1), INOPTIONS, "dc_tagram_rdata1 X or Z")
  u_ovl_intf_x_dc_tagram_rdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_tagram_en_reg[1] & ~dc_tagram_wr_reg),
    .test_expr (dc_tagram_rdata1));

  //  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata2  valid dc_tagram_en@1[2] & ~dc_tagram_wr@1 timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DTAG_RAM_W-1)) - (0) + 1), INOPTIONS, "dc_tagram_rdata2 X or Z")
  u_ovl_intf_x_dc_tagram_rdata2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_tagram_en_reg[2] & ~dc_tagram_wr_reg),
    .test_expr (dc_tagram_rdata2));

  //  input [(`CA53_DTAG_RAM_W-1):0] dc_tagram_rdata3  valid dc_tagram_en@1[3] & ~dc_tagram_wr@1 timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DTAG_RAM_W-1)) - (0) + 1), INOPTIONS, "dc_tagram_rdata3 X or Z")
  u_ovl_intf_x_dc_tagram_rdata3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_tagram_en_reg[3] & ~dc_tagram_wr_reg),
    .test_expr (dc_tagram_rdata3));


  // If writing, at least one bank must be enabled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_tagram_wr  => |dc_tagram_en")
  u_ovl_intf_assert_9a157e5af4c52e4038a122d588f62cfd3b11b028 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_tagram_wr ),
    .consequent_expr (|dc_tagram_en));


  //-----------------------------------------------------------------------------
  //
  // Data RAM signals
  //
  //-----------------------------------------------------------------------------

  // Enable for each RAM bank.
  //  output [7:0] dc_dataram_en valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "dc_dataram_en X or Z")
  u_ovl_intf_x_dc_dataram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_en));


  // The access is a write.
  //  output dc_dataram_wr valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dc_dataram_wr X or Z")
  u_ovl_intf_x_dc_dataram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wr));


  // The byte strobes for a write.
  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb0 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb0 X or Z")
  u_ovl_intf_x_dc_dataram_strb0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb0));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb1 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb1 X or Z")
  u_ovl_intf_x_dc_dataram_strb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb1));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb2 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb2 X or Z")
  u_ovl_intf_x_dc_dataram_strb2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb2));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb3 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb3 X or Z")
  u_ovl_intf_x_dc_dataram_strb3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb3));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb4 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb4 X or Z")
  u_ovl_intf_x_dc_dataram_strb4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb4));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb5 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb5 X or Z")
  u_ovl_intf_x_dc_dataram_strb5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb5));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb6 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb6 X or Z")
  u_ovl_intf_x_dc_dataram_strb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb6));

  //  output [(`CA53_DDATA_WEN_W-1):0] dc_dataram_strb7 valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_strb7 X or Z")
  u_ovl_intf_x_dc_dataram_strb7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_strb7));


  // The index of the RAM to access.
  //  output [10:0] dc_dataram_addr0 valid dc_dataram_en[0] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr0 X or Z")
  u_ovl_intf_x_dc_dataram_addr0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[0]),
    .test_expr (dc_dataram_addr0));

  //  output [10:0] dc_dataram_addr1 valid dc_dataram_en[1] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr1 X or Z")
  u_ovl_intf_x_dc_dataram_addr1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[1]),
    .test_expr (dc_dataram_addr1));

  //  output [10:0] dc_dataram_addr2 valid dc_dataram_en[2] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr2 X or Z")
  u_ovl_intf_x_dc_dataram_addr2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[2]),
    .test_expr (dc_dataram_addr2));

  //  output [10:0] dc_dataram_addr3 valid dc_dataram_en[3] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr3 X or Z")
  u_ovl_intf_x_dc_dataram_addr3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[3]),
    .test_expr (dc_dataram_addr3));

  //  output [10:0] dc_dataram_addr4 valid dc_dataram_en[4] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr4 X or Z")
  u_ovl_intf_x_dc_dataram_addr4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[4]),
    .test_expr (dc_dataram_addr4));

  //  output [10:0] dc_dataram_addr5 valid dc_dataram_en[5] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr5 X or Z")
  u_ovl_intf_x_dc_dataram_addr5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[5]),
    .test_expr (dc_dataram_addr5));

  //  output [10:0] dc_dataram_addr6 valid dc_dataram_en[6] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr6 X or Z")
  u_ovl_intf_x_dc_dataram_addr6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[6]),
    .test_expr (dc_dataram_addr6));

  //  output [10:0] dc_dataram_addr7 valid dc_dataram_en[7] timing 40%

  assert_never_unknown #(`OVL_FATAL, 11, OUTOPTIONS, "dc_dataram_addr7 X or Z")
  u_ovl_intf_x_dc_dataram_addr7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dataram_en[7]),
    .test_expr (dc_dataram_addr7));


  // For ECC, where the read-modify-write operation is performed from STB, it is possible
  // to get data with x's when STB requests a linefill and the linefill gets an external
  // abort so the stb can passes x's to the Data RAM. For this reason the write mask for
  // the assertion is set to zero when ECC is present.
  assign wdata0_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb0[3]}}, {8{dc_dataram_strb0[2]}}, {8{dc_dataram_strb0[1]}}, {8{dc_dataram_strb0[0]}}};

  assign wdata1_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb1[3]}}, {8{dc_dataram_strb1[2]}}, {8{dc_dataram_strb1[1]}}, {8{dc_dataram_strb1[0]}}};

  assign wdata2_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb2[3]}}, {8{dc_dataram_strb2[2]}}, {8{dc_dataram_strb2[1]}}, {8{dc_dataram_strb2[0]}}};

  assign wdata3_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb3[3]}}, {8{dc_dataram_strb3[2]}}, {8{dc_dataram_strb3[1]}}, {8{dc_dataram_strb3[0]}}};

  assign wdata4_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb4[3]}}, {8{dc_dataram_strb4[2]}}, {8{dc_dataram_strb4[1]}}, {8{dc_dataram_strb4[0]}}};

  assign wdata5_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb5[3]}}, {8{dc_dataram_strb5[2]}}, {8{dc_dataram_strb5[1]}}, {8{dc_dataram_strb5[0]}}};

  assign wdata6_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb6[3]}}, {8{dc_dataram_strb6[2]}}, {8{dc_dataram_strb6[1]}}, {8{dc_dataram_strb6[0]}}};

  assign wdata7_valid  = CPU_CACHE_PROTECTION ? {39{1'b0}} : {{7{1'b0}}, {8{dc_dataram_strb7[3]}}, {8{dc_dataram_strb7[2]}}, {8{dc_dataram_strb7[1]}}, {8{dc_dataram_strb7[0]}}};

  // The data to write to the RAM.
  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata0 valid mask wdata0_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata0 & (wdata0_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_ce9e226bf8e8681e6d3e13a1a995de81a6bcfa78 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata0 & (wdata0_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata1 valid mask wdata1_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata1 & (wdata1_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_07f8185a40c8f6826c15356cc70d6d3e32905a20 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata1 & (wdata1_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata2 valid mask wdata2_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata2 & (wdata2_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_13f715ee1a3a2aca778af893d5369c1506474195 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata2 & (wdata2_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata3 valid mask wdata3_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata3 & (wdata3_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_fcaa79cee5e9f944be2ed151ea10360653eaa069 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata3 & (wdata3_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata4 valid mask wdata4_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata4 & (wdata4_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_efdfcc9982d978b436363542dc42b157192e2922 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata4 & (wdata4_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata5 valid mask wdata5_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata5 & (wdata5_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_91488e4c917138012576b9e36d798cd9119afcd2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata5 & (wdata5_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata6 valid mask wdata6_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata6 & (wdata6_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_df64f0145a1d811695dadcf8f47f53d83fcfdabc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata6 & (wdata6_valid[(`CA53_DDATA_RAM_W-1):0])));

  //  output [(`CA53_DDATA_RAM_W-1):0] dc_dataram_wdata7 valid mask wdata7_valid[(`CA53_DDATA_RAM_W-1):0] timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dataram_wdata7 & (wdata7_valid[(`CA53_DDATA_RAM_W-1):0]) X or Z")
  u_ovl_intf_x_08e142e66c5dd6096381433da321f579843b1541 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dataram_wdata7 & (wdata7_valid[(`CA53_DDATA_RAM_W-1):0])));


  // The read data returned from the RAMs - validity checked in DCU itself - only valid if tag hits

  // Certain combinations of dataram enables are not valid.
generate if (!CPU_CACHE_PROTECTION) begin : g_dataram_en_valid_noecc
  // - In ECC configurations the cache way tracker can end up storing a way which is not one-hot,
  // which means loads can enable any combination of dc_dataram_en. This is not a problem as such
  // a load will return an ECC error to the DPU.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(|dc_dataram_en)  => dc_dataram_en in [8'b1111_1111,    8'b0101_0101,   8'b1010_1010,   8'b1111_0000,   8'b0111_0000,   8'b1011_0000,   8'b1101_0000,   8'b1110_0000,   8'b0110_0000,   8'b1001_0000,   8'b1010_0000,   8'b0101_0000,   8'b0011_1100,   8'b0001_1100,   8'b0010_1100,   8'b0011_0100,   8'b0011_1000,   8'b0001_1000,   8'b0010_0100,   8'b0010_1000,   8'b0001_0100,   8'b0000_1111,   8'b0000_0111,   8'b0000_1011,   8'b0000_1101,   8'b0000_1110,   8'b0000_0110,   8'b0000_1001,   8'b0000_1010,   8'b0000_0101,   8'b1100_0011,   8'b1100_0001,   8'b1100_0010,   8'b0100_0011,   8'b1000_0011,   8'b1000_0001,   8'b0100_0010,   8'b1000_0010,   8'b0100_0001,   8'b1100_0000,   8'b0011_0000,   8'b0000_1100,   8'b0000_0011,   8'b1000_0000,   8'b0100_0000,   8'b0010_0000,   8'b0001_0000,   8'b0000_1000,   8'b0000_0100,   8'b0000_0010,   8'b0000_0001]")
  u_ovl_intf_assert_6b716e957ca6189f8bf61d4cd9009edcad452852 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((|dc_dataram_en) ),
    .consequent_expr (((dc_dataram_en == 8'b1111_1111) | (dc_dataram_en ==     8'b0101_0101) | (dc_dataram_en ==    8'b1010_1010) | (dc_dataram_en ==    8'b1111_0000) | (dc_dataram_en ==    8'b0111_0000) | (dc_dataram_en ==    8'b1011_0000) | (dc_dataram_en ==    8'b1101_0000) | (dc_dataram_en ==    8'b1110_0000) | (dc_dataram_en ==    8'b0110_0000) | (dc_dataram_en ==    8'b1001_0000) | (dc_dataram_en ==    8'b1010_0000) | (dc_dataram_en ==    8'b0101_0000) | (dc_dataram_en ==    8'b0011_1100) | (dc_dataram_en ==    8'b0001_1100) | (dc_dataram_en ==    8'b0010_1100) | (dc_dataram_en ==    8'b0011_0100) | (dc_dataram_en ==    8'b0011_1000) | (dc_dataram_en ==    8'b0001_1000) | (dc_dataram_en ==    8'b0010_0100) | (dc_dataram_en ==    8'b0010_1000) | (dc_dataram_en ==    8'b0001_0100) | (dc_dataram_en ==    8'b0000_1111) | (dc_dataram_en ==    8'b0000_0111) | (dc_dataram_en ==    8'b0000_1011) | (dc_dataram_en ==    8'b0000_1101) | (dc_dataram_en ==    8'b0000_1110) | (dc_dataram_en ==    8'b0000_0110) | (dc_dataram_en ==    8'b0000_1001) | (dc_dataram_en ==    8'b0000_1010) | (dc_dataram_en ==    8'b0000_0101) | (dc_dataram_en ==    8'b1100_0011) | (dc_dataram_en ==    8'b1100_0001) | (dc_dataram_en ==    8'b1100_0010) | (dc_dataram_en ==    8'b0100_0011) | (dc_dataram_en ==    8'b1000_0011) | (dc_dataram_en ==    8'b1000_0001) | (dc_dataram_en ==    8'b0100_0010) | (dc_dataram_en ==    8'b1000_0010) | (dc_dataram_en ==    8'b0100_0001) | (dc_dataram_en ==    8'b1100_0000) | (dc_dataram_en ==    8'b0011_0000) | (dc_dataram_en ==    8'b0000_1100) | (dc_dataram_en ==    8'b0000_0011) | (dc_dataram_en ==    8'b1000_0000) | (dc_dataram_en ==    8'b0100_0000) | (dc_dataram_en ==    8'b0010_0000) | (dc_dataram_en ==    8'b0001_0000) | (dc_dataram_en ==    8'b0000_1000) | (dc_dataram_en ==    8'b0000_0100) | (dc_dataram_en ==    8'b0000_0010) | (dc_dataram_en ==    8'b0000_0001))));


end endgenerate

  // If writing, at least one bank must be enabled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_wr  => |dc_dataram_en")
  u_ovl_intf_assert_6a06408c8b8f7f158e6536366b163d99d06ee2dd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_wr ),
    .consequent_expr (|dc_dataram_en));


  // If writing, at least one of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[0] & dc_dataram_wr  => |dc_dataram_strb0")
  u_ovl_intf_assert_b507d99945ff74b521c60ed465e8e733a4be6a81 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[0] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[1] & dc_dataram_wr  => |dc_dataram_strb1")
  u_ovl_intf_assert_83fd9451228d4aa36f74ec585c3a7546900c82a3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[1] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[2] & dc_dataram_wr  => |dc_dataram_strb2")
  u_ovl_intf_assert_e7f9037a1deaf13b2ccf30bf19ba40b981cc84a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[2] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[3] & dc_dataram_wr  => |dc_dataram_strb3")
  u_ovl_intf_assert_d5f565c0734151249311ea2f5571042f94edf257 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[3] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[4] & dc_dataram_wr  => |dc_dataram_strb4")
  u_ovl_intf_assert_9c86705f090e273ed8f17b2bd74449ee26e7044a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[4] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb4));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[5] & dc_dataram_wr  => |dc_dataram_strb5")
  u_ovl_intf_assert_a839483091dd2446ee735cfd9acbda5d984e00e7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[5] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb5));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[6] & dc_dataram_wr  => |dc_dataram_strb6")
  u_ovl_intf_assert_01a051470b7cd29f77af4129b5980e535da214f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[6] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb6));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dataram_en[7] & dc_dataram_wr  => |dc_dataram_strb7")
  u_ovl_intf_assert_66669b5832e287ea8da50df57806837f4075044f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dataram_en[7] & dc_dataram_wr ),
    .consequent_expr (|dc_dataram_strb7));


  // If reading, none of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb0")
  u_ovl_intf_assert_56d3ff8ede476a58f6cce8aa6fe721e2f6cdec6b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb1")
  u_ovl_intf_assert_74327d2e8cce3956047c3cadc9ae441ec8a87b1e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb2")
  u_ovl_intf_assert_a1b868c7bf03da6a9aa768154aa7aadc16feb3bb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb3")
  u_ovl_intf_assert_1c712ae357ef3184334e87fed960215d2a7a48a3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb4")
  u_ovl_intf_assert_47b5875bf6183891fae95634b624a4201e3bd624 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb4));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb5")
  u_ovl_intf_assert_2afb90647d6c133eefd136b5dc4ce166f930d4b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb5));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb6")
  u_ovl_intf_assert_fd44289c94ec8aa2f6072e2b0e3a1102a6b899e7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb6));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|dc_dataram_en & ~dc_dataram_wr  => ~|dc_dataram_strb7")
  u_ovl_intf_assert_2857262af289caac879c486a3c99676c2fb069e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|dc_dataram_en & ~dc_dataram_wr ),
    .consequent_expr (~|dc_dataram_strb7));


  // If not accessing a particular bank, none of the strobes for that bank should be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[0]  => ~|dc_dataram_strb0")
  u_ovl_intf_assert_5157f020463be95c19668e048a7bf00572abfec1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[0] ),
    .consequent_expr (~|dc_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[1]  => ~|dc_dataram_strb1")
  u_ovl_intf_assert_772d732cd29edb43c81bb7af1e9c5274a2a314d0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[1] ),
    .consequent_expr (~|dc_dataram_strb1));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[2]  => ~|dc_dataram_strb2")
  u_ovl_intf_assert_365f77b094bd492c67076adf2ff04d74d94343a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[2] ),
    .consequent_expr (~|dc_dataram_strb2));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[3]  => ~|dc_dataram_strb3")
  u_ovl_intf_assert_fd19c48caadb1eca33dadc6c622edd659de2f5f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[3] ),
    .consequent_expr (~|dc_dataram_strb3));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[4]  => ~|dc_dataram_strb4")
  u_ovl_intf_assert_bbda431c1eb7e52fd46f1b1dda899b2a6572c5aa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[4] ),
    .consequent_expr (~|dc_dataram_strb4));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[5]  => ~|dc_dataram_strb5")
  u_ovl_intf_assert_923807e9ed83d4f74a7c1a7311ef569aa5ce0b14 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[5] ),
    .consequent_expr (~|dc_dataram_strb5));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[6]  => ~|dc_dataram_strb6")
  u_ovl_intf_assert_84a86d5d03e161b6daaedf8ae6dab30c677fe36d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[6] ),
    .consequent_expr (~|dc_dataram_strb6));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dataram_en[7]  => ~|dc_dataram_strb7")
  u_ovl_intf_assert_936e4cdba4f6a2e6074892331e244c557630812e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dataram_en[7] ),
    .consequent_expr (~|dc_dataram_strb7));


  //-----------------------------------------------------------------------------
  //
  // Dirty RAM signals
  //
  //-----------------------------------------------------------------------------

  // Encoding for the dirty RAM is:
  // |--- Way 1/3 ---|--- Way 0/2 ---|--- Way 1/3 ---|--- Way 0/2 ---|
  // |    DC2  DC1   |    DC2  DC1   |   AH AGE M LM |   AH AGE M LM |
  //
  // Where AH  = Outer Allocation Hint
  //       AGE = Age information
  //       M   = Partial MOESI, used with the tag, and potentially the LM bit, to form the MOESI state of the line
  //       LM  = For non-migratory lines, this is the dirty state. For migratory lines, it is the Locally Modified bit
  //       DC1 = Dirty Copy1 when ECC is enabled
  //       DC2 = Dirty Copy2 when ECC is enabled

  // Enable for the single RAM bank.
  //  output dc_dirtyram_en valid always timing 45%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dc_dirtyram_en X or Z")
  u_ovl_intf_x_dc_dirtyram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dirtyram_en));


  // The access is a write.
  //  output dc_dirtyram_wr valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "dc_dirtyram_wr X or Z")
  u_ovl_intf_x_dc_dirtyram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dirtyram_wr));


  // Bit strobes for a write.
  //  output [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_strb valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDIRTY_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dirtyram_strb X or Z")
  u_ovl_intf_x_dc_dirtyram_strb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dc_dirtyram_strb));


  // The index of the RAM to access.
  //  output [8:0] dc_dirtyram_addr valid dc_dirtyram_en timing 50%

  assert_never_unknown #(`OVL_FATAL, 9, OUTOPTIONS, "dc_dirtyram_addr X or Z")
  u_ovl_intf_x_dc_dirtyram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dirtyram_en),
    .test_expr (dc_dirtyram_addr));


  // The data to write to the RAM.
  //  output [(`CA53_DDIRTY_RAM_W-1):0] dc_dirtyram_wdata valid dc_dirtyram_en & dc_dirtyram_wr timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_DDIRTY_RAM_W-1)) - (0) + 1), OUTOPTIONS, "dc_dirtyram_wdata X or Z")
  u_ovl_intf_x_dc_dirtyram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dc_dirtyram_en & dc_dirtyram_wr),
    .test_expr (dc_dirtyram_wdata));


  // The read data returned from the RAMs the cycle after the enable.
  // Validity is checked in DCU as only valid if tag hits


  // If writing, the RAM must be enabled.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dirtyram_wr  => dc_dirtyram_en")
  u_ovl_intf_assert_c5a7a219279ed80803f3e72fb0a3d703a33d0f4d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dirtyram_wr ),
    .consequent_expr (dc_dirtyram_en));


  // If writing, at least one of the bit enables must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dirtyram_en & dc_dirtyram_wr  => |dc_dirtyram_strb")
  u_ovl_intf_assert_4a63d086729814ec68dfc2cc751136f4ad53764a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dirtyram_en & dc_dirtyram_wr ),
    .consequent_expr (|dc_dirtyram_strb));


  // If reading, none of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dc_dirtyram_en & ~dc_dirtyram_wr  => ~|dc_dirtyram_strb")
  u_ovl_intf_assert_80d177099c2533597edad9baeae7d4f2348e1b42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dc_dirtyram_en & ~dc_dirtyram_wr ),
    .consequent_expr (~|dc_dirtyram_strb));


  // If not enabled, none of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~dc_dirtyram_en  => ~|dc_dirtyram_strb")
  u_ovl_intf_assert_5933a268b109480044b1920b8c57e40945ef705f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~dc_dirtyram_en ),
    .consequent_expr (~|dc_dirtyram_strb));


  // Only one way should be written at a time.
generate if (CPU_CACHE_PROTECTION) begin : g_dirty_strb_ecc

  assign dirty_way_0_strb  = (|dc_dirtyram_strb[3:0]) | (|dc_dirtyram_strb[9:8]);
  assign dirty_way_1_strb  = (|dc_dirtyram_strb[7:4]) | (|dc_dirtyram_strb[11:10]);
  assign dirty_way_2_strb  = (|dc_dirtyram_strb[3:0]) | (|dc_dirtyram_strb[9:8]);
  assign dirty_way_3_strb  = (|dc_dirtyram_strb[7:4]) | (|dc_dirtyram_strb[11:10]);


  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "{dirty_way_0_strb, dirty_way_1_strb}")
  u_ovl_intf_assert_8380b9a037550f492db0d63fba06d731db68bb6c (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dirty_way_0_strb, dirty_way_1_strb}));


  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "{dirty_way_2_strb, dirty_way_3_strb}")
  u_ovl_intf_assert_9668716ca97eab15fdd909aedc2c880ed50485b9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dirty_way_2_strb, dirty_way_3_strb}));


end endgenerate
generate if (!CPU_CACHE_PROTECTION) begin : g_dirty_strb_no_ecc

  assign dirty_way_0_strb  = (|dc_dirtyram_strb[3:0]);
  assign dirty_way_1_strb  = (|dc_dirtyram_strb[7:4]);
  assign dirty_way_2_strb  = (|dc_dirtyram_strb[3:0]);
  assign dirty_way_3_strb  = (|dc_dirtyram_strb[7:4]);


  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "{dirty_way_0_strb, dirty_way_1_strb}")
  u_ovl_intf_assert_8380b9a037550f492db0d63fba06d731db68bb6c (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dirty_way_0_strb, dirty_way_1_strb}));


  assert_zero_one_hot #(`OVL_FATAL, 2, OUTOPTIONS, "{dirty_way_2_strb, dirty_way_3_strb}")
  u_ovl_intf_assert_9668716ca97eab15fdd909aedc2c880ed50485b9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr ({dirty_way_2_strb, dirty_way_3_strb}));


end endgenerate



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_dcu_rams_defs.v"
`undef CA53_UNDEFINE

`endif

