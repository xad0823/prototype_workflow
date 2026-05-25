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

// This is the specification for the interface between the IFU and BIU

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_ifu_biu_defs.v"
`include "cortexa53params.v"
`include "cortexa53params.v"

module ca53_ifu_biu #(parameter CPU_CACHE_PROTECTION = 0, parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         biu_i_arready_i,
  input         biu_i_rvalid_i,
  input   [1:0] biu_i_rid_i,
  input [127:0] biu_i_rdata_i,
  input   [2:0] biu_i_rresp_i,
  input   [1:0] biu_i_rchunk_i,
  input         gov_mbist_req_i,
  input         ifu_arvalid_i,
  input   [1:0] ifu_arid_i,
  input  [39:0] ifu_araddr_i,
  input   [1:0] ifu_arlen_i,
  input   [7:0] ifu_attrs_i,
  input   [1:0] ifu_arprot_i,
  input         ifu_rready_i,
  input   [2:0] ifu_outstanding_lfb_i,
  input [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6_i);


  wire         biu_i_arready = biu_i_arready_i;
  wire         biu_i_rvalid = biu_i_rvalid_i;
  wire   [1:0] biu_i_rid = biu_i_rid_i;
  wire [127:0] biu_i_rdata = biu_i_rdata_i;
  wire   [2:0] biu_i_rresp = biu_i_rresp_i;
  wire   [1:0] biu_i_rchunk = biu_i_rchunk_i;
  wire         gov_mbist_req = gov_mbist_req_i;
  wire         ifu_arvalid = ifu_arvalid_i;
  wire   [1:0] ifu_arid = ifu_arid_i;
  wire  [39:0] ifu_araddr = ifu_araddr_i;
  wire   [1:0] ifu_arlen = ifu_arlen_i;
  wire   [7:0] ifu_attrs = ifu_attrs_i;
  wire   [1:0] ifu_arprot = ifu_arprot_i;
  wire         ifu_rready = ifu_rready_i;
  wire   [2:0] ifu_outstanding_lfb = ifu_outstanding_lfb_i;
  wire [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6 = ifu_mbist_out_data_mb6_i;


  reg   [2:0] tr_len_0;
  reg   [2:0] tr_len_1;
  reg   [2:0] tr_len_2;

  reg         biu_i_rvalid_reg;
  reg         ifu_arvalid_reg;
  reg   [1:0] ifu_arid_reg;
  reg         biu_i_arready_reg;
  reg [127:0] biu_i_rdata_reg;
  reg   [1:0] biu_i_rchunk_reg;
  reg   [1:0] ifu_arlen_reg;
  reg         ifu_rready_reg;
  reg  [39:0] ifu_araddr_reg;
  reg   [7:0] ifu_attrs_reg;
  reg   [1:0] biu_i_rid_reg;
  reg   [1:0] ifu_arprot_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    biu_i_rvalid_reg <= 1'b0;
    ifu_arvalid_reg <= 1'b0;
    ifu_arid_reg <= 2'b00;
    biu_i_arready_reg <= 1'b0;
    biu_i_rdata_reg <= {128{1'b0}};
    biu_i_rchunk_reg <= 2'b00;
    ifu_arlen_reg <= 2'b00;
    ifu_rready_reg <= 1'b0;
    ifu_araddr_reg <= {40{1'b0}};
    ifu_attrs_reg <= {8{1'b0}};
    biu_i_rid_reg <= 2'b00;
    ifu_arprot_reg <= 2'b00;
  end
  else
  begin
    biu_i_arready_reg <= biu_i_arready;
    biu_i_rvalid_reg <= biu_i_rvalid;
    biu_i_rid_reg <= biu_i_rid;
    biu_i_rdata_reg <= biu_i_rdata;
    biu_i_rchunk_reg <= biu_i_rchunk;
    ifu_arvalid_reg <= ifu_arvalid;
    ifu_arid_reg <= ifu_arid;
    ifu_araddr_reg <= ifu_araddr;
    ifu_arlen_reg <= ifu_arlen;
    ifu_attrs_reg <= ifu_attrs;
    ifu_arprot_reg <= ifu_arprot;
    ifu_rready_reg <= ifu_rready;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------
  // Inputs to the IFU from the BIU
  //  input          biu_i_arready       valid always                            timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_i_arready X or Z")
  u_ovl_intf_x_biu_i_arready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_i_arready));

  //  input          biu_i_rvalid        valid always                            timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "biu_i_rvalid X or Z")
  u_ovl_intf_x_biu_i_rvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_i_rvalid));

  //  input [1:0]    biu_i_rid           valid biu_i_rvalid                      timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_i_rid X or Z")
  u_ovl_intf_x_biu_i_rid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_i_rvalid),
    .test_expr (biu_i_rid));

  //  input [127:0]  biu_i_rdata         valid biu_i_rvalid & ~|biu_i_rresp[2:1] timing 30%

  assert_never_unknown #(`OVL_FATAL, 128, INOPTIONS, "biu_i_rdata X or Z")
  u_ovl_intf_x_biu_i_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_i_rvalid & ~|biu_i_rresp[2:1]),
    .test_expr (biu_i_rdata));

  //  input [2:0]    biu_i_rresp         valid biu_i_rvalid                      timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "biu_i_rresp X or Z")
  u_ovl_intf_x_biu_i_rresp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_i_rvalid),
    .test_expr (biu_i_rresp));

  //  input [1:0]    biu_i_rchunk        valid biu_i_rvalid                      timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "biu_i_rchunk X or Z")
  u_ovl_intf_x_biu_i_rchunk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_i_rvalid),
    .test_expr (biu_i_rchunk));


  // Outputs from the IFU to the BIU
  //  output         ifu_arvalid         valid always                            timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ifu_arvalid X or Z")
  u_ovl_intf_x_ifu_arvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_arvalid));

  //  output [1:0]   ifu_arid            valid ifu_arvalid                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "ifu_arid X or Z")
  u_ovl_intf_x_ifu_arid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_arvalid),
    .test_expr (ifu_arid));

  //  output [39:0]  ifu_araddr          valid ifu_arvalid                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 40, OUTOPTIONS, "ifu_araddr X or Z")
  u_ovl_intf_x_ifu_araddr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_arvalid),
    .test_expr (ifu_araddr));

  //  output [1:0]   ifu_arlen           valid ifu_arvalid                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "ifu_arlen X or Z")
  u_ovl_intf_x_ifu_arlen (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_arvalid),
    .test_expr (ifu_arlen));

  //  output [7:0]   ifu_attrs           valid ifu_arvalid                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "ifu_attrs X or Z")
  u_ovl_intf_x_ifu_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_arvalid),
    .test_expr (ifu_attrs));

  //  output [1:0]   ifu_arprot          valid ifu_arvalid                       timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "ifu_arprot X or Z")
  u_ovl_intf_x_ifu_arprot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_arvalid),
    .test_expr (ifu_arprot));

  //  output         ifu_rready          valid always                            timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ifu_rready X or Z")
  u_ovl_intf_x_ifu_rready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_rready));


  // The IFU has outstanding accesses for an IFU request.
  //  output [2:0]   ifu_outstanding_lfb valid always                            timing 17%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "ifu_outstanding_lfb X or Z")
  u_ovl_intf_x_ifu_outstanding_lfb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_outstanding_lfb));


  // The output data read from the RAMs 
  //  output [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6 valid always       timing 50%

  assert_never_unknown #(`OVL_FATAL, (((`CA53_IDATA_RAM_W-1)) - (0) + 1), OUTOPTIONS, "ifu_mbist_out_data_mb6 X or Z")
  u_ovl_intf_x_ifu_mbist_out_data_mb6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_mbist_out_data_mb6));


  // ------------------------------------------------------
  // Rules
  // ------------------------------------------------------
  // This is a simplified version of an AXI transfer
  //
  // Address Stage
  //
  //
  // During either a linefill or non-cacheable request the ifu_arvalid
  // signal is set and it will stay set until biu_i_arready is returned.
  // The valid signal must be low after valid and ready have been seen.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid@1 & biu_i_arready@1  => ~ifu_arvalid")
  u_ovl_intf_assert_4552526297adf81b230d196fd048a2f699eb31e4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & biu_i_arready_reg ),
    .consequent_expr (~ifu_arvalid));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid@1 & ~biu_i_arready@1  => ifu_arvalid")
  u_ovl_intf_assert_6605f73298b6e70846856284c08206dbaad67acd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & ~biu_i_arready_reg ),
    .consequent_expr (ifu_arvalid));


  // First cycle of ARVALID ARREADY must be low

  assert_implication #(`OVL_FATAL, INOPTIONS, "~ifu_arvalid@1 & ifu_arvalid  => ~biu_i_arready")
  u_ovl_intf_assume_ef037570ef174d6be8ca411a27c83b3e28477694 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ifu_arvalid_reg & ifu_arvalid ),
    .consequent_expr (~biu_i_arready));

  // Cycle after handshake ARREADY is low

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid@1 & biu_i_arready@1  => ~ biu_i_arready")
  u_ovl_intf_assume_968dcb94e4e7a249f5a3d07373bdf2994ef60ad8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & biu_i_arready_reg ),
    .consequent_expr (~ biu_i_arready));


  // Together with the valid signal the following are sent:
  //
  // ifu_araddr  => full 31 bits of the physical address 128 bit aligned

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ifu_arvalid@1 & ~gov_mbist_req  => ifu_araddr == ifu_araddr@1")
  u_ovl_intf_assert_fb0af5ab961476e5ff6962fec1182280742c7972 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ifu_arvalid_reg & ~gov_mbist_req ),
    .consequent_expr (ifu_araddr == ifu_araddr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ~gov_mbist_req  => ifu_araddr[3:0] == 4'b0000")
  u_ovl_intf_assert_1a29cd7d8a064a377515d382eea7550adbc21d8e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ~gov_mbist_req ),
    .consequent_expr (ifu_araddr[3:0] == 4'b0000));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ifu_arvalid@1  => ifu_arlen == ifu_arlen@1")
  u_ovl_intf_assert_ea4c0c5821bd5d0c6506bb0792da4b029ed8210b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ifu_arvalid_reg ),
    .consequent_expr (ifu_arlen == ifu_arlen_reg));



  // ifu_arid

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ifu_arvalid@1  => ifu_arid == ifu_arid@1")
  u_ovl_intf_assert_5e71a9864b5cbffbd194076db566c3d3a0441bc2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ifu_arvalid_reg ),
    .consequent_expr (ifu_arid == ifu_arid_reg));


  // ifu_attrs
  // See cortexa53params for the encodings

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ifu_arvalid@1  => ifu_attrs == ifu_attrs@1")
  u_ovl_intf_assert_356c90e5399c3c4886f85f5112f43afd6b39f8d7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ifu_arvalid_reg ),
    .consequent_expr (ifu_attrs == ifu_attrs_reg));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid  => ~`CA53_MEM_UNUSED(ifu_attrs)")
  u_ovl_intf_assert_e7efb47cc82fa50a2c9364380f558f3f7fa5e4a2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid ),
    .consequent_expr (~`CA53_MEM_UNUSED(ifu_attrs)));


  // ifu_arprot  => Protection Information:
  //                bit |  high      | low
  //                ----+------------+---------
  //                [1] | Non-Secure | Secure
  //                [0] | Privilege  | User

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ifu_arvalid@1  => ifu_arprot == ifu_arprot@1")
  u_ovl_intf_assert_d46f265b3ee43af44fd8a1b504dabc3cb3ec2518 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ifu_arvalid_reg ),
    .consequent_expr (ifu_arprot == ifu_arprot_reg));


  // The length must be a full cache line if the memory type is inner cacheable

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & (`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs))  => ifu_arlen == 2'b11")
  u_ovl_intf_assert_8028fe3093cefcc2d93ac246abfe6dba1c8c69b9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & (`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs)) ),
    .consequent_expr (ifu_arlen == 2'b11));


  // Non inner cacheable requests must not wrap around a cache line boundary

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ~(`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs))  => (ifu_araddr[5:4] + ifu_arlen) < 3'b100")
  u_ovl_intf_assert_aa5778130c3d3b68e959266071fc7d1109a66652 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ~(`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs)) ),
    .consequent_expr ((ifu_araddr[5:4] + ifu_arlen) < 3'b100));


  // Non inner cacheable requests must not make an unaligned halfline request

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & ~(`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs)) & (ifu_arlen == 2'b01)  => (ifu_araddr[4] == 1'b0)")
  u_ovl_intf_assert_dc0e221a8c4fc327fc9fc7fa0d77dc98da42afeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & ~(`CA53_MEM_WB(ifu_attrs) | `CA53_MEM_WT(ifu_attrs)) & (ifu_arlen == 2'b01) ),
    .consequent_expr ((ifu_araddr[4] == 1'b0)));


  // IFU must never request three beats

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid  => ifu_arlen != 2'b10")
  u_ovl_intf_assert_838eccc6241ee519a8032bf0a35f81344a913618 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid ),
    .consequent_expr (ifu_arlen != 2'b10));


  //
  // Read Data Stage
  //
  // The IFU is capable to accept a full cache line (4 beats of 128-bit wide)
  // during a linefill, and to pass the non-cacheable accesses directly to the Pre Fetch
  // The IFU will try to keep RREADY high as much as possible, the only time the RREADY
  // signal will be low is if there is a Pre Fetch request and an allocation outstanding
  // and two more beats have arrived since.
  // Every time the BIU has valid data it will set biu_i_rvalid.
  // biu_i_rvalid:
  //   1'b0 => no data
  //   1'b1 => data

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_i_rvalid@1 & !ifu_rready@1  => biu_i_rid@1    == biu_i_rid")
  u_ovl_intf_assume_eb2213fee2ddc9d1ee26efd522b92f8ce1bce685 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_i_rvalid_reg & !ifu_rready_reg ),
    .consequent_expr (biu_i_rid_reg    == biu_i_rid));


  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_i_rvalid@1 & !ifu_rready@1  => biu_i_rchunk@1 == biu_i_rchunk")
  u_ovl_intf_assume_ab7af5ec9904a1dc91008e539cf6d28217837fd5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_i_rvalid_reg & !ifu_rready_reg ),
    .consequent_expr (biu_i_rchunk_reg == biu_i_rchunk));


  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_i_rvalid@1 & !ifu_rready@1 & ~gov_mbist_req  => biu_i_rdata@1  == biu_i_rdata")
  u_ovl_intf_assume_c43e967aaee3cd7b074554b2cc6d469d0e33b445 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_i_rvalid_reg & !ifu_rready_reg & ~gov_mbist_req ),
    .consequent_expr (biu_i_rdata_reg  == biu_i_rdata));


  // For each cycle where biu_i_rvalid is high a beat of the burst is acknowledged.
  // There will be as many beats as set using ifu_arlen. It can be set back to back.
  // We can construct a register which is set to len plus 1 at the end of the
  // address stage, it decreases by one on the cycle after a valid. This means that
  // when rlast is seen the value should be one and zero the cycle after.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tr_len_0 <= 3'b000;
  else
    tr_len_0 <= ((ifu_arvalid & biu_i_arready & ifu_arid == 2'b00) ? ({1'b0,ifu_arlen} + 3'b001) : ((biu_i_rvalid & ifu_rready & biu_i_rid == 2'b00) ? (tr_len_0 - 2'b01) : tr_len_0));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tr_len_1 <= 3'b000;
  else
    tr_len_1 <= ((ifu_arvalid & biu_i_arready & ifu_arid == 2'b01) ? ({1'b0,ifu_arlen} + 3'b001) : ((biu_i_rvalid & ifu_rready & biu_i_rid == 2'b01) ? (tr_len_1 - 2'b01) : tr_len_1));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    tr_len_2 <= 3'b000;
  else
    tr_len_2 <= ((ifu_arvalid & biu_i_arready & ifu_arid == 2'b10) ? ({1'b0,ifu_arlen} + 3'b001) : ((biu_i_rvalid & ifu_rready & biu_i_rid == 2'b10) ? (tr_len_2 - 2'b01) : tr_len_2));


  // check that outstanding lfb flag is asserted while read data is expected

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_0 != 3'b000)  => ifu_outstanding_lfb[0]")
  u_ovl_intf_assert_6dcb031bba66f5b6fb3b7076b5016359bd989d82 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_0 != 3'b000) ),
    .consequent_expr (ifu_outstanding_lfb[0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_1 != 3'b000)  => ifu_outstanding_lfb[1]")
  u_ovl_intf_assert_b9339a519b630443a2f3b27fec850ca412726f2f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_1 != 3'b000) ),
    .consequent_expr (ifu_outstanding_lfb[1]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_2 != 3'b000)  => ifu_outstanding_lfb[2]")
  u_ovl_intf_assert_9fb36b2c9192f355a056bde7efe1b5bf47cfcebc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_2 != 3'b000) ),
    .consequent_expr (ifu_outstanding_lfb[2]));


  // check that no spurious beats are seen

  assert_implication #(`OVL_FATAL, INOPTIONS, "(tr_len_0 == 3'b000)  => ~(biu_i_rvalid & biu_i_rid == 2'b00)")
  u_ovl_intf_assume_037efafb99ce9bd65a349169aefe639e0caa38f6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_0 == 3'b000) ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b00)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(tr_len_1 == 3'b000)  => ~(biu_i_rvalid & biu_i_rid == 2'b01)")
  u_ovl_intf_assume_a9f0491de76221046215a3a12a6c2faf2963646c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_1 == 3'b000) ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b01)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "(tr_len_2 == 3'b000)  => ~(biu_i_rvalid & biu_i_rid == 2'b10)")
  u_ovl_intf_assume_508955888e1eab0d4be4c052f55ffc40fd35c9e5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_2 == 3'b000) ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b10)));

  // check that no new address are sent while line fill are in progress

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_0 != 3'b000)  => ~(ifu_arvalid & ifu_arid == 2'b00)")
  u_ovl_intf_assert_36232a2bb38ad33b3bea9033725239940d06239c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_0 != 3'b000) ),
    .consequent_expr (~(ifu_arvalid & ifu_arid == 2'b00)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_1 != 3'b000)  => ~(ifu_arvalid & ifu_arid == 2'b01)")
  u_ovl_intf_assert_fdc80557095ed50ede0bf253136590275e803d7e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_1 != 3'b000) ),
    .consequent_expr (~(ifu_arvalid & ifu_arid == 2'b01)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "(tr_len_2 != 3'b000)  => ~(ifu_arvalid & ifu_arid == 2'b10)")
  u_ovl_intf_assert_1c26a444fd09037d4cf18cdb01122662e523f327 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr ((tr_len_2 != 3'b000) ),
    .consequent_expr (~(ifu_arvalid & ifu_arid == 2'b10)));

  // The IFU relies on the fact that the first read data valid signal will never arrive
  // in the same cycle as an address handshake or the cycle after

  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid & biu_i_arready & ifu_arid == 2'b00  => ~(biu_i_rvalid & biu_i_rid == 2'b00)")
  u_ovl_intf_assume_238223d64c00ef1062ef7809156555f643ba28b8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & biu_i_arready & ifu_arid == 2'b00 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b00)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid & biu_i_arready & ifu_arid == 2'b01  => ~(biu_i_rvalid & biu_i_rid == 2'b01)")
  u_ovl_intf_assume_065536c07c4bcf2d29e327c3bafa27d75d10c0f7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & biu_i_arready & ifu_arid == 2'b01 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b01)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid & biu_i_arready & ifu_arid == 2'b10  => ~(biu_i_rvalid & biu_i_rid == 2'b10)")
  u_ovl_intf_assume_9244c909f8d23574d42cf137df27d1701930ae7b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & biu_i_arready & ifu_arid == 2'b10 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b10)));



  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid@1 & biu_i_arready@1 & ifu_arid@1 == 2'b00  => ~(biu_i_rvalid & biu_i_rid == 2'b00)")
  u_ovl_intf_assume_5984a84e633674f20dd1f1e975787edfbe7ca9ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & biu_i_arready_reg & ifu_arid_reg == 2'b00 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b00)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid@1 & biu_i_arready@1 & ifu_arid@1 == 2'b01  => ~(biu_i_rvalid & biu_i_rid == 2'b01)")
  u_ovl_intf_assume_c3b61ee82556157819cd65090f5f20dc4ddb3daa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & biu_i_arready_reg & ifu_arid_reg == 2'b01 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b01)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ifu_arvalid@1 & biu_i_arready@1 & ifu_arid@1 == 2'b10  => ~(biu_i_rvalid & biu_i_rid == 2'b10)")
  u_ovl_intf_assume_8943193088b211be9c0e90a4a930498602c35f8d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid_reg & biu_i_arready_reg & ifu_arid_reg == 2'b10 ),
    .consequent_expr (~(biu_i_rvalid & biu_i_rid == 2'b10)));


  // Ensure that no more that 3 transfer are requested at any one time

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & biu_i_arready  => (tr_len_0[1:0] == 2'b00) | (tr_len_1[1:0] == 2'b00) | (tr_len_2[1:0] == 2'b00)")
  u_ovl_intf_assert_4d7b867095829cf1f3f0e2a3728cf323a3034eb8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & biu_i_arready ),
    .consequent_expr ((tr_len_0[1:0] == 2'b00) | (tr_len_1[1:0] == 2'b00) | (tr_len_2[1:0] == 2'b00)));

  // Ensure that the IFU never sends an ID of 11 ...

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_arvalid & biu_i_arready  => ifu_arid  != 2'b11")
  u_ovl_intf_assert_20511dc459e125fea204531f722aa11eedc5b70e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_arvalid & biu_i_arready ),
    .consequent_expr (ifu_arid  != 2'b11));

  // .. and in return ensure that the BIU never sends an ID back of 2'b11

  assert_implication #(`OVL_FATAL, INOPTIONS, "biu_i_rvalid & ifu_rready    => biu_i_rid != 2'b11")
  u_ovl_intf_assume_2003b77e2c818ee54a1cfa377fddf204545b03de (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_i_rvalid & ifu_rready   ),
    .consequent_expr (biu_i_rid != 2'b11));


  // The response signal is returned for each beat. An error response on the first
  // access of a linefill or during a non cacheable access is reported to the PFU
  // An error response on subsequent linefill accesses will cause the linefill
  // to be ignored by the IFU but not interrupt since a burst cannot be interrupted
  // biu_i_rresp[1:0]:
  // 2'b10 : slave error
  // 2'b11 : decode error
  // biu_i_rresp[2]:
  // 1'b1  : ECC error


endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "cortexa53params.v"
`include "ca53_ifu_biu_defs.v"
`undef CA53_UNDEFINE

`endif

