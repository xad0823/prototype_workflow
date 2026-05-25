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

// This is the specification for the interface between the IFU and rams


// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_ifu_rams_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_ifu_rams #(parameter CPU_CACHE_PROTECTION = 0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata0_i,
  input [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata1_i,
  input [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata0_i,
  input [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata1_i,
  input   [2:0] ic_size_i,
  input [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_rdata_i,
  input [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_rdata_i,
  input   [1:0] ic_tagram_en_i,
  input         ic_tagram_wr_i,
  input [(`CA53_ITAG_RAM_W-1):0] ic_tagram_wdata_i,
  input   [8:0] ic_tagram_addr_i,
  input   [3:0] ic_dataram_en_i,
  input         ic_dataram_wr_i,
  input  [11:0] ic_dataram_addr0_i,
  input  [11:0] ic_dataram_addr1_i,
  input [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0_i,
  input [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1_i,
  input [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0_i,
  input [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1_i,
  input         btac_stg0_ram_en_i,
  input         btac_stg0_ram_wr_i,
  input [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_wdata_i,
  input [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr_i,
  input         btac_stg1_ram_en_i,
  input         btac_stg1_ram_wr_i,
  input [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_wdata_i,
  input [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr_i);


  wire [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata0 = ic_tagram_rdata0_i;
  wire [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata1 = ic_tagram_rdata1_i;
  wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata0 = ic_dataram_rdata0_i;
  wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata1 = ic_dataram_rdata1_i;
  wire   [2:0] ic_size = ic_size_i;
  wire [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_rdata = btac_stg0_ram_rdata_i;
  wire [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_rdata = btac_stg1_ram_rdata_i;
  wire   [1:0] ic_tagram_en = ic_tagram_en_i;
  wire         ic_tagram_wr = ic_tagram_wr_i;
  wire [(`CA53_ITAG_RAM_W-1):0] ic_tagram_wdata = ic_tagram_wdata_i;
  wire   [8:0] ic_tagram_addr = ic_tagram_addr_i;
  wire   [3:0] ic_dataram_en = ic_dataram_en_i;
  wire         ic_dataram_wr = ic_dataram_wr_i;
  wire  [11:0] ic_dataram_addr0 = ic_dataram_addr0_i;
  wire  [11:0] ic_dataram_addr1 = ic_dataram_addr1_i;
  wire [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0 = ic_dataram_strb0_i;
  wire [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1 = ic_dataram_strb1_i;
  wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0 = ic_dataram_wdata0_i;
  wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1 = ic_dataram_wdata1_i;
  wire         btac_stg0_ram_en = btac_stg0_ram_en_i;
  wire         btac_stg0_ram_wr = btac_stg0_ram_wr_i;
  wire [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_wdata = btac_stg0_ram_wdata_i;
  wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr = btac_stg0_ram_addr_i;
  wire         btac_stg1_ram_en = btac_stg1_ram_en_i;
  wire         btac_stg1_ram_wr = btac_stg1_ram_wr_i;
  wire [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_wdata = btac_stg1_ram_wdata_i;
  wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr = btac_stg1_ram_addr_i;


  reg         out_of_reset;
  reg   [1:0] tagram_en_q;

  reg         btac_stg0_ram_wr_reg;
  reg   [2:0] ic_size_reg;
  reg         btac_stg0_ram_en_reg;
  reg         btac_stg1_ram_wr_reg;
  reg         btac_stg1_ram_en_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    btac_stg0_ram_wr_reg <= 1'b0;
    ic_size_reg <= 3'b000;
    btac_stg0_ram_en_reg <= 1'b0;
    btac_stg1_ram_wr_reg <= 1'b0;
    btac_stg1_ram_en_reg <= 1'b0;
  end
  else
  begin
    ic_size_reg <= ic_size;
    btac_stg0_ram_en_reg <= btac_stg0_ram_en;
    btac_stg0_ram_wr_reg <= btac_stg0_ram_wr;
    btac_stg1_ram_en_reg <= btac_stg1_ram_en;
    btac_stg1_ram_wr_reg <= btac_stg1_ram_wr;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------
  // Inputs to the IFU from the rams
  //  input [(`CA53_ITAG_RAM_W-1):0]       ic_tagram_rdata0    valid tagram_en_q[0]                           timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_ITAG_RAM_W-1)) - (0) + 1), INOPTIONS, "ic_tagram_rdata0 X or Z")
  u_ovl_intf_x_ic_tagram_rdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tagram_en_q[0]),
    .test_expr (ic_tagram_rdata0));

  //  input [(`CA53_ITAG_RAM_W-1):0]       ic_tagram_rdata1    valid tagram_en_q[1]                           timing 40%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_ITAG_RAM_W-1)) - (0) + 1), INOPTIONS, "ic_tagram_rdata1 X or Z")
  u_ovl_intf_x_ic_tagram_rdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tagram_en_q[1]),
    .test_expr (ic_tagram_rdata1));


  //  input [2:0]                        ic_size             valid always                                   timing 20%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ic_size X or Z")
  u_ovl_intf_x_ic_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ic_size));


  //  input [(`CA53_BTAC_RAM_S0D_W-1):0]   btac_stg0_ram_rdata valid btac_stg0_ram_en@1 & ~btac_stg0_ram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_S0D_W-1)) - (0) + 1), INOPTIONS, "btac_stg0_ram_rdata X or Z")
  u_ovl_intf_x_btac_stg0_ram_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg0_ram_en_reg & ~btac_stg0_ram_wr_reg),
    .test_expr (btac_stg0_ram_rdata));

  //  input [(`CA53_BTAC_RAM_S1D_W-1):0]   btac_stg1_ram_rdata valid btac_stg1_ram_en@1 & ~btac_stg1_ram_wr@1 timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_S1D_W-1)) - (0) + 1), INOPTIONS, "btac_stg1_ram_rdata X or Z")
  u_ovl_intf_x_btac_stg1_ram_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg1_ram_en_reg & ~btac_stg1_ram_wr_reg),
    .test_expr (btac_stg1_ram_rdata));


  // Outputs from the IFU to the rams
  //  output [1:0]                       ic_tagram_en        valid always                                   timing 60%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "ic_tagram_en X or Z")
  u_ovl_intf_x_ic_tagram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ic_tagram_en));

  //  output                             ic_tagram_wr        valid |ic_tagram_en                            timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ic_tagram_wr X or Z")
  u_ovl_intf_x_ic_tagram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_tagram_en),
    .test_expr (ic_tagram_wr));

  //  output [(`CA53_ITAG_RAM_W-1):0]      ic_tagram_wdata     valid |ic_tagram_en & ic_tagram_wr             timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_ITAG_RAM_W-1)) - (0) + 1), OUTOPTIONS, "ic_tagram_wdata X or Z")
  u_ovl_intf_x_ic_tagram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_tagram_en & ic_tagram_wr),
    .test_expr (ic_tagram_wdata));

  //  output [8:0]                       ic_tagram_addr      valid |ic_tagram_en                            timing 60%

  assert_never_unknown #(`OVL_FATAL, 9, OUTOPTIONS, "ic_tagram_addr X or Z")
  u_ovl_intf_x_ic_tagram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_tagram_en),
    .test_expr (ic_tagram_addr));


  //  output [3:0]                       ic_dataram_en       valid always                                   timing 60%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "ic_dataram_en X or Z")
  u_ovl_intf_x_ic_dataram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ic_dataram_en));

  //  output                             ic_dataram_wr       valid |ic_dataram_en                           timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ic_dataram_wr X or Z")
  u_ovl_intf_x_ic_dataram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en),
    .test_expr (ic_dataram_wr));

  //  output [11:0]                      ic_dataram_addr0    valid |ic_dataram_en[1:0]                      timing 60%

  assert_never_unknown #(`OVL_FATAL, 12, OUTOPTIONS, "ic_dataram_addr0 X or Z")
  u_ovl_intf_x_ic_dataram_addr0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[1:0]),
    .test_expr (ic_dataram_addr0));

  //  output [11:0]                      ic_dataram_addr1    valid |ic_dataram_en[3:2]                      timing 60%

  assert_never_unknown #(`OVL_FATAL, 12, OUTOPTIONS, "ic_dataram_addr1 X or Z")
  u_ovl_intf_x_ic_dataram_addr1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[3:2]),
    .test_expr (ic_dataram_addr1));

  //  output [(`CA53_IDATA_WEN_W-1):0]     ic_dataram_strb0    valid |ic_dataram_en[1:0]                      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_IDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "ic_dataram_strb0 X or Z")
  u_ovl_intf_x_ic_dataram_strb0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[1:0]),
    .test_expr (ic_dataram_strb0));

  //  output [(`CA53_IDATA_WEN_W-1):0]     ic_dataram_strb1    valid |ic_dataram_en[3:2]                      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_IDATA_WEN_W-1)) - (0) + 1), OUTOPTIONS, "ic_dataram_strb1 X or Z")
  u_ovl_intf_x_ic_dataram_strb1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[3:2]),
    .test_expr (ic_dataram_strb1));

  //  output [(`CA53_IDATA_RAM_W-1):0]     ic_dataram_wdata0   valid |ic_dataram_en[1:0] & ic_dataram_wr      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_IDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "ic_dataram_wdata0 X or Z")
  u_ovl_intf_x_ic_dataram_wdata0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[1:0] & ic_dataram_wr),
    .test_expr (ic_dataram_wdata0));

  //  output [(`CA53_IDATA_RAM_W-1):0]     ic_dataram_wdata1   valid |ic_dataram_en[3:2] & ic_dataram_wr      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_IDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "ic_dataram_wdata1 X or Z")
  u_ovl_intf_x_ic_dataram_wdata1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|ic_dataram_en[3:2] & ic_dataram_wr),
    .test_expr (ic_dataram_wdata1));


  //  output                             btac_stg0_ram_en    valid always                                   timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "btac_stg0_ram_en X or Z")
  u_ovl_intf_x_btac_stg0_ram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (btac_stg0_ram_en));

  //  output                             btac_stg0_ram_wr    valid btac_stg0_ram_en                         timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "btac_stg0_ram_wr X or Z")
  u_ovl_intf_x_btac_stg0_ram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg0_ram_en),
    .test_expr (btac_stg0_ram_wr));

  //  output [(`CA53_BTAC_RAM_S0D_W-1):0]  btac_stg0_ram_wdata valid btac_stg0_ram_en & btac_stg0_ram_wr      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_S0D_W-1)) - (0) + 1), OUTOPTIONS, "btac_stg0_ram_wdata X or Z")
  u_ovl_intf_x_btac_stg0_ram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg0_ram_en & btac_stg0_ram_wr),
    .test_expr (btac_stg0_ram_wdata));

  //  output [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr  valid btac_stg0_ram_en                         timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_ADDR_W-1)) - (0) + 1), OUTOPTIONS, "btac_stg0_ram_addr X or Z")
  u_ovl_intf_x_btac_stg0_ram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg0_ram_en),
    .test_expr (btac_stg0_ram_addr));

  //  output                             btac_stg1_ram_en    valid always                                   timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "btac_stg1_ram_en X or Z")
  u_ovl_intf_x_btac_stg1_ram_en (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (btac_stg1_ram_en));

  //  output                             btac_stg1_ram_wr    valid btac_stg1_ram_en                         timing 60%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "btac_stg1_ram_wr X or Z")
  u_ovl_intf_x_btac_stg1_ram_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg1_ram_en),
    .test_expr (btac_stg1_ram_wr));

  //  output [(`CA53_BTAC_RAM_S1D_W-1):0]  btac_stg1_ram_wdata valid btac_stg1_ram_en & btac_stg1_ram_wr      timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_S1D_W-1)) - (0) + 1), OUTOPTIONS, "btac_stg1_ram_wdata X or Z")
  u_ovl_intf_x_btac_stg1_ram_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg1_ram_en & btac_stg1_ram_wr),
    .test_expr (btac_stg1_ram_wdata));

  //  output [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr  valid btac_stg1_ram_en                         timing 60%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_BTAC_RAM_ADDR_W-1)) - (0) + 1), OUTOPTIONS, "btac_stg1_ram_addr X or Z")
  u_ovl_intf_x_btac_stg1_ram_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (btac_stg1_ram_en),
    .test_expr (btac_stg1_ram_addr));


  // ------------------------------------------------------
  // Registers
  // ------------------------------------------------------
  // Set enable signals for the read data (next cycle)

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tagram_en_q <= 2'b00;
  else
    tagram_en_q <= ic_tagram_en & {2{~ic_tagram_wr}};


  // ------------------------------------------------------
  // Rules
  // ------------------------------------------------------
  // TAG Ram
  //
  // In the first cycle the following signals are valid:
  // o Enable: it is a 2 entry bus, one per way.
  //   During a lookup both are set, during a line fill
  //   one is choosen for the entire linefill operation.
  //   CP15 and MBIST will pass the correct information to
  //   way to read or write
  // o Write: it is set for memory writes during line fill,
  //   also during CP15 operation to invalidate the valid bit.
  //   MBIST can requests a specific TAG write
  // o Address: One address for both ways.
  // o Write Data: 31 bits :
  //              [30:29] valid (2'b00 = valid A32, 
  //                             2'b01 = valid T32,  
  //                             2'b10 = valid A64,
  //                             2'b11 = not valid)
  //              [28]    non-secure
  //              [27:0]  physical address[39:12]
  //
  // In the second cycle the read data is returned
  // o Read Data : 2 x 31 bits :
  //              [30:29] valid (2'b00 = valid A32, 
  //                             2'b01 = valid T32,  
  //                             2'b10 = valid A64,
  //                             2'b11 = not valid)
  //              [28]    non-secure
  //              [27:0]  physical address[39:12]
  //
  // DATA
  //
  // In the first cycle the following signals are valid:
  // o Enable : it is a 2 entry bus, one per bank.
  // o Write : it is set for writes.
  // o Address: One address per bank
  // o Write Data: 2 x 80 bits divided into four packets each.
  // o Write strobes : 4 bit each reppresent a packet.
  //
  // In the second cycle the read data is returned
  // o Read Data : 2 x 80 bits divided into four packets each

  // If writing, at least one of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|ic_dataram_en[1:0] & ic_dataram_wr  => |ic_dataram_strb0")
  u_ovl_intf_assert_690b605e60291856e3cce46dc25f5f140d677557 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|ic_dataram_en[1:0] & ic_dataram_wr ),
    .consequent_expr (|ic_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|ic_dataram_en[3:2] & ic_dataram_wr  => |ic_dataram_strb1")
  u_ovl_intf_assert_d99af8bc2bf5a8f301c224587a18be6b8009d40d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|ic_dataram_en[3:2] & ic_dataram_wr ),
    .consequent_expr (|ic_dataram_strb1));


  // If reading, none of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|ic_dataram_en[1:0] & ~ic_dataram_wr  => ~|ic_dataram_strb0")
  u_ovl_intf_assert_88460bf152d75155ebc670fc3ba56d1dc8a7ca06 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|ic_dataram_en[1:0] & ~ic_dataram_wr ),
    .consequent_expr (~|ic_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "|ic_dataram_en[3:2] & ~ic_dataram_wr  => ~|ic_dataram_strb1")
  u_ovl_intf_assert_7e52dc1b296ec72f594cf526f740284ff5f984cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (|ic_dataram_en[3:2] & ~ic_dataram_wr ),
    .consequent_expr (~|ic_dataram_strb1));


  // If not enabling, none of the strobes must be set.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~|ic_dataram_en[1:0]  => ~|ic_dataram_strb0")
  u_ovl_intf_assert_76d2bc9f44fdca071531768f4e6d7ab67da7e83c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~|ic_dataram_en[1:0] ),
    .consequent_expr (~|ic_dataram_strb0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~|ic_dataram_en[3:2]  => ~|ic_dataram_strb1")
  u_ovl_intf_assert_205d08ec4fb37b8481a56413730b8f541a0e60be (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~|ic_dataram_en[3:2] ),
    .consequent_expr (~|ic_dataram_strb1));


  // --------------------------------------------------------------------------
  // RAM Sizes
  // --------------------------------------------------------------------------

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // The RAM size cannot change outside of reset.

  assert_implication #(`OVL_FATAL, INOPTIONS, "out_of_reset  => ic_size == ic_size@1")
  u_ovl_intf_assume_22c296dc97ac8e262e308b2c4c4500f51dc57a6d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (out_of_reset ),
    .consequent_expr (ic_size == ic_size_reg));



  assert_always #(`OVL_FATAL, INOPTIONS, "ic_size in [3'b000, 3'b001, 3'b011, 3'b111]")
  u_ovl_intf_assume_fe1b7fd22fee466727f4cd3a40d4b5f5e4abd629 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (((ic_size == 3'b000) | (ic_size ==  3'b001) | (ic_size ==  3'b011) | (ic_size ==  3'b111))));


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_ifu_rams_defs.v"
`undef CA53_UNDEFINE

`endif

