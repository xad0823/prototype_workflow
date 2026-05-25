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


// This is the specification for the interface between the SCU and the DCU for
// snoop requests.
// Inputs and outputs are from the point of view of the SCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_scu_dcu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_biu_scu_defs.v"

module ca53_scu_dcu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         dcu_ac_ready_i,
  input         dcu_cr_valid_i,
  input   [2:0] dcu_cr_id_i,
  input         dcu_cr_dirty_i,
  input         dcu_cr_age_i,
  input         dcu_cr_alloc_i,
  input         dcu_cr_migratory_i,
  input         dcu_dvm_complete_i,
  input         scu_ac_valid_i,
  input   [2:0] scu_ac_id_i,
  input   [3:0] scu_ac_l2db_id_i,
  input   [3:0] scu_ac_snoop_i,
  input  [40:0] scu_ac_addr_i,
  input   [3:0] scu_ac_way_i,
  input   [7:0] scu_reqbufs_busy_i,
  input         scu_broadcastinner_i);


  wire         dcu_ac_ready = dcu_ac_ready_i;
  wire         dcu_cr_valid = dcu_cr_valid_i;
  wire   [2:0] dcu_cr_id = dcu_cr_id_i;
  wire         dcu_cr_dirty = dcu_cr_dirty_i;
  wire         dcu_cr_age = dcu_cr_age_i;
  wire         dcu_cr_alloc = dcu_cr_alloc_i;
  wire         dcu_cr_migratory = dcu_cr_migratory_i;
  wire         dcu_dvm_complete = dcu_dvm_complete_i;
  wire         scu_ac_valid = scu_ac_valid_i;
  wire   [2:0] scu_ac_id = scu_ac_id_i;
  wire   [3:0] scu_ac_l2db_id = scu_ac_l2db_id_i;
  wire   [3:0] scu_ac_snoop = scu_ac_snoop_i;
  wire  [40:0] scu_ac_addr = scu_ac_addr_i;
  wire   [3:0] scu_ac_way = scu_ac_way_i;
  wire   [7:0] scu_reqbufs_busy = scu_reqbufs_busy_i;
  wire         scu_broadcastinner = scu_broadcastinner_i;

  wire         scu_dvm_sync;
  wire   [3:0] crnt_snoop;
  wire         ac_handshake;
  wire   [2:0] crnt_id;
  wire         push;
  wire   [9:0] dvm_cmd;
  wire         ac_valid_not_dvm;
  wire         dvm_req;
  wire         first_dvm_req;
  wire         ecc_clean;
  wire         pop;
  wire         ac_valid_wants_data;

  reg   [8:0] outstanding_syncs;
  reg   [7:0] outstanding_ac_ids;
  reg   [2:0] id_1;
  reg  [40:0] addr_1;
  reg   [3:0] snoop_0;
  reg         expecting_second_dvm;
  reg  [40:0] addr_0;
  reg   [1:0] outstanding_resps;
  reg   [2:0] id_0;
  reg   [3:0] snoop_1;

  reg         dcu_ac_ready_reg;
  reg   [2:0] scu_ac_id_reg;
  reg  [40:0] addr_0_reg;
  reg   [3:0] scu_ac_snoop_reg;
  reg         ac_handshake_reg;
  reg  [40:0] addr_1_reg;
  reg         ac_valid_not_dvm_reg;
  reg   [3:0] scu_ac_way_reg;
  reg         scu_ac_valid_reg;
  reg   [3:0] snoop_0_reg;
  reg   [1:0] outstanding_resps_reg;
  reg         dvm_req_reg;
  reg         dcu_cr_valid_reg;
  reg   [3:0] scu_ac_l2db_id_reg;
  reg  [40:0] scu_ac_addr_reg;
  reg   [3:0] snoop_1_reg;
  reg         ac_valid_wants_data_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    dcu_ac_ready_reg <= 1'b0;
    scu_ac_id_reg <= 3'b000;
    addr_0_reg <= {41{1'b0}};
    scu_ac_snoop_reg <= 4'b0000;
    ac_handshake_reg <= 1'b0;
    addr_1_reg <= {41{1'b0}};
    ac_valid_not_dvm_reg <= 1'b0;
    scu_ac_way_reg <= 4'b0000;
    scu_ac_valid_reg <= 1'b0;
    snoop_0_reg <= 4'b0000;
    outstanding_resps_reg <= 2'b00;
    dvm_req_reg <= 1'b0;
    dcu_cr_valid_reg <= 1'b0;
    scu_ac_l2db_id_reg <= 4'b0000;
    scu_ac_addr_reg <= {41{1'b0}};
    snoop_1_reg <= 4'b0000;
    ac_valid_wants_data_reg <= 1'b0;
  end
  else
  begin
    dcu_ac_ready_reg <= dcu_ac_ready;
    dcu_cr_valid_reg <= dcu_cr_valid;
    scu_ac_valid_reg <= scu_ac_valid;
    scu_ac_id_reg <= scu_ac_id;
    scu_ac_l2db_id_reg <= scu_ac_l2db_id;
    scu_ac_snoop_reg <= scu_ac_snoop;
    scu_ac_addr_reg <= scu_ac_addr;
    scu_ac_way_reg <= scu_ac_way;
    addr_0_reg <= addr_0;
    ac_handshake_reg <= ac_handshake;
    addr_1_reg <= addr_1;
    ac_valid_not_dvm_reg <= ac_valid_not_dvm;
    snoop_0_reg <= snoop_0;
    outstanding_resps_reg <= outstanding_resps;
    dvm_req_reg <= dvm_req;
    snoop_1_reg <= snoop_1;
    ac_valid_wants_data_reg <= ac_valid_wants_data;
  end



  //----------------------------------------------------------------------------
  // AC Interface
  //----------------------------------------------------------------------------


  // - Some AC signals are only valid when the AC request isn't a DVM Message
  assign ac_valid_not_dvm  = scu_ac_valid & (scu_ac_snoop != `CA53_SNOOP_DVM);

  // Some snoops always transfer data, the rest never do.
  assign ac_valid_wants_data  = scu_ac_valid & ((scu_ac_snoop == `CA53_SNOOP_CLEANSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_CLEANINVALID) | (scu_ac_snoop ==  `CA53_SNOOP_READONCE) | (scu_ac_snoop ==  `CA53_SNOOP_READSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_READMAKESHARED));

  // AC Channel handshake.
  //  output          scu_ac_valid          valid always            timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ac_valid X or Z")
  u_ovl_intf_x_scu_ac_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ac_valid));

  //  input           dcu_ac_ready          valid always            timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_ac_ready X or Z")
  u_ovl_intf_x_dcu_ac_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_ac_ready));


  // ID for the request, to be driven back to the SCU on CR.
  //  output [2:0]    scu_ac_id             valid ac_valid_not_dvm  timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ac_id X or Z")
  u_ovl_intf_x_scu_ac_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ac_valid_not_dvm),
    .test_expr (scu_ac_id));


  // Data buffer ID for the request, to be driven back to the SCU with snoop data.
  //  output [3:0]    scu_ac_l2db_id        valid ac_valid_wants_data timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ac_l2db_id X or Z")
  u_ovl_intf_x_scu_ac_l2db_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ac_valid_wants_data),
    .test_expr (scu_ac_l2db_id));


  // Snoop command sent to the DCU.
  //  output    [3:0] scu_ac_snoop          valid scu_ac_valid      timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ac_snoop X or Z")
  u_ovl_intf_x_scu_ac_snoop (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ac_valid),
    .test_expr (scu_ac_snoop));


  // The physical address of the request. Snoop requests will always be at least
  // half-line aligned, but DVM requests require the rest of the bits.
  // Bit 40 is the non-secure bit for all requests except DVM.
  //  output   [40:0] scu_ac_addr           valid scu_ac_valid      timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 41, OUTOPTIONS, "scu_ac_addr X or Z")
  u_ovl_intf_x_scu_ac_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ac_valid),
    .test_expr (scu_ac_addr));


  // The way in which the duplicate tags indicate the line is present.
  //  output    [3:0] scu_ac_way            valid ac_valid_not_dvm  timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ac_way X or Z")
  u_ovl_intf_x_scu_ac_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ac_valid_not_dvm),
    .test_expr (scu_ac_way));


  //----------------------------------------------------------------------------
  // CR Interface
  //----------------------------------------------------------------------------

  // Channel handshake. Note there is no scu_cr_ready signal, as the SCU can
  // always accept the CR response.
  //  input           dcu_cr_valid          valid always          timing 20% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cr_valid X or Z")
  u_ovl_intf_x_dcu_cr_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_cr_valid));


  // ID for the request - matches the original ac_id.
  //  input [2:0]     dcu_cr_id             valid dcu_cr_valid    timing 25% wiring 45%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dcu_cr_id X or Z")
  u_ovl_intf_x_dcu_cr_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cr_valid),
    .test_expr (dcu_cr_id));


  // The line was dirty. This must be accurate for all snoop types except DVM and ECC CLEAN due
  // an ECC error.
  //  input           dcu_cr_dirty           valid dcu_cr_valid & ~ecc_clean   timing 25% wiring 45%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cr_dirty X or Z")
  u_ovl_intf_x_dcu_cr_dirty (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cr_valid & ~ecc_clean),
    .test_expr (dcu_cr_dirty));


  // The approximate age of the line. Clear if this is the first time the line
  // has been in the L1 cache, set if it has previously been in L1 or L2 before
  // entering this cache.
  //  input           dcu_cr_age             valid dcu_cr_valid & ~ecc_clean  timing 25% wiring 45%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cr_age X or Z")
  u_ovl_intf_x_dcu_cr_age (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cr_valid & ~ecc_clean),
    .test_expr (dcu_cr_age));


  // Outer allocation hint for the snoop response.
  //  input           dcu_cr_alloc           valid dcu_cr_valid & ~ecc_clean timing 25% wiring 45%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cr_alloc X or Z")
  u_ovl_intf_x_dcu_cr_alloc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cr_valid & ~ecc_clean),
    .test_expr (dcu_cr_alloc));


  // The line was initially provided as migratory, and remains migratory.
  // If set, the DCU must invalidate the line after responding to the snoop.
  // Must only be set on ReadShared snoops, as all others do not have a choice
  // as to the final state of the line.
  //  input           dcu_cr_migratory       valid dcu_cr_valid timing 25% wiring 45%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_cr_migratory X or Z")
  u_ovl_intf_x_dcu_cr_migratory (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_cr_valid),
    .test_expr (dcu_cr_migratory));


  //----------------------------------------------------------------------------
  // Misc signals
  //----------------------------------------------------------------------------

  // The SCU indicate which request buffers are busy with non-DVM sync
  // transactions. The DCU uses this to track when a DVM sync is complete.
  //  output [7:0]    scu_reqbufs_busy      valid always          timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_reqbufs_busy X or Z")
  u_ovl_intf_x_scu_reqbufs_busy (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_reqbufs_busy));


  // DVM completes are indicated using a separate one-shot signal to the SCU,
  // rather than by issuing ARSNOOP transactions.
  //  input           dcu_dvm_complete      valid always          timing 20% wiring 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dcu_dvm_complete X or Z")
  u_ovl_intf_x_dcu_dvm_complete (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dcu_dvm_complete));


  //----------------------------------------------------------------------------
  // AC Interface Properties
  //----------------------------------------------------------------------------

  // Not all encodings of ac_snoop are valid.
  // Note that DVM Completes will not be issued on the AC channel, as these are
  // indicated by the SCU directly to the STB.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid  => scu_ac_snoop in [`CA53_SNOOP_MAKEINVALID, `CA53_SNOOP_GETDIRTY, `CA53_SNOOP_MAKECLEANSHARED, `CA53_SNOOP_CLEANSHARED, `CA53_SNOOP_CLEANINVALID, `CA53_SNOOP_READONCE, `CA53_SNOOP_READSHARED, `CA53_SNOOP_READMAKESHARED, `CA53_SNOOP_DVM]")
  u_ovl_intf_assert_ffd09226182e5f6d3a7a76dd6258317bd4ad6508 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid ),
    .consequent_expr (((scu_ac_snoop == `CA53_SNOOP_MAKEINVALID) | (scu_ac_snoop ==  `CA53_SNOOP_GETDIRTY) | (scu_ac_snoop ==  `CA53_SNOOP_MAKECLEANSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_CLEANSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_CLEANINVALID) | (scu_ac_snoop ==  `CA53_SNOOP_READONCE) | (scu_ac_snoop ==  `CA53_SNOOP_READSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_READMAKESHARED) | (scu_ac_snoop ==  `CA53_SNOOP_DVM))));


  // The DCU cannot accept back to back snoop requests without a bubble between
  // them, apart from on the second packet of a DVM Message.
  assign ac_handshake  = scu_ac_valid & dcu_ac_ready;


  assert_implication #(`OVL_FATAL, INOPTIONS, "ac_handshake@1 & (scu_ac_snoop@1 != `CA53_SNOOP_DVM)  => ~ac_handshake")
  u_ovl_intf_assume_f3c898a376b5f4f3ba2ead39c344514b44f0d0d6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ac_handshake_reg & (scu_ac_snoop_reg != `CA53_SNOOP_DVM) ),
    .consequent_expr (~ac_handshake));


  // The SCU must hold a request until it is acked.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid@1 & ~dcu_ac_ready@1  => scu_ac_valid")
  u_ovl_intf_assert_334b6e2fd53c0f0fd612a1d9672483c629851f0d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid_reg & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_valid));


  // The AC information must be constant until the transaction is accepted.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid@1        & ~dcu_ac_ready@1  => scu_ac_snoop     == scu_ac_snoop@1")
  u_ovl_intf_assert_8a85817e64eade88ee1c82c6ffbd458435b1ab39 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid_reg        & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_snoop     == scu_ac_snoop_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid@1        & ~dcu_ac_ready@1  => scu_ac_addr      == scu_ac_addr@1")
  u_ovl_intf_assert_3de05956f3bbebf04eab90de5be1b74e98ec684a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid_reg        & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_addr      == scu_ac_addr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ac_valid_not_dvm@1    & ~dcu_ac_ready@1  => scu_ac_id        == scu_ac_id@1")
  u_ovl_intf_assert_92312299b8d19c4e1e3a8a1382b1c03534feb4e0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ac_valid_not_dvm_reg    & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_id        == scu_ac_id_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ac_valid_not_dvm@1    & ~dcu_ac_ready@1  => scu_ac_way       == scu_ac_way@1")
  u_ovl_intf_assert_b666b8d291efee2d1645edf926d1db2be22d4ad4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ac_valid_not_dvm_reg    & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_way       == scu_ac_way_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ac_valid_wants_data@1 & ~dcu_ac_ready@1  => scu_ac_l2db_id   == scu_ac_l2db_id@1")
  u_ovl_intf_assert_cd208e7b839abeffc4be4899af4a048757a74d3a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ac_valid_wants_data_reg & ~dcu_ac_ready_reg ),
    .consequent_expr (scu_ac_l2db_id   == scu_ac_l2db_id_reg));


  // The way must be onehot.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ac_valid_not_dvm  => scu_ac_way in [4'b0001, 4'b0010, 4'b0100, 4'b1000]")
  u_ovl_intf_assert_7fe8be1e5251d06154bec0d20bc2ad69a3d09b4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ac_valid_not_dvm ),
    .consequent_expr (((scu_ac_way == 4'b0001) | (scu_ac_way ==  4'b0010) | (scu_ac_way ==  4'b0100) | (scu_ac_way ==  4'b1000))));


  // The DCU can accept up to two outstanding snoop transactions, i.e. the DCU
  // can accept a second AC transaction before giving the response (and data if
  // required) for the first.
  // Therefore, a two entry FIFO is required to track the request for the
  // current response is being driven.

  assign push  = ac_handshake & (scu_ac_snoop != `CA53_SNOOP_DVM);
  assign pop   = dcu_cr_valid;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    addr_0 <= {41{1'b0}};
  else if (push)
    addr_0 <= push ? scu_ac_addr : addr_1;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    addr_1 <= {41{1'b0}};
  else if (push)
    addr_1 <= addr_0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop_0 <= 4'b0000;
  else if (push)
    snoop_0 <= push ? scu_ac_snoop : snoop_1;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop_1 <= 4'b0000;
  else if (push)
    snoop_1 <= snoop_0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    id_0 <= 3'b000;
  else if (push)
    id_0 <= push ? scu_ac_id : id_1;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    id_1 <= 3'b000;
  else if (push)
    id_1 <= id_0;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_resps <= 2'b00;
  else if (push | pop)
    outstanding_resps <= outstanding_resps + {1'b0, push} - {1'b0, pop};



  assert_always #(`OVL_FATAL, INOPTIONS, "outstanding_resps <= 2'b10")
  u_ovl_intf_assume_a3e69cb70d143cdd1a9d573744f1a50ffbf2f2c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (outstanding_resps <= 2'b10));


  // The SCU should never drive a new snoop request to the same address as an outstanding
  // request before it receives the response to the outstanding request.
  // The exception to this which is only possible at unit level is when the first
  // snoop is due to an ECC error in an invalid line, and hence the address is not real.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid@1 & ~dvm_req@1 & (outstanding_resps@1 >= 1) & ~((scu_ac_snoop@1 == `CA53_SNOOP_MAKEINVALID) & scu_ac_addr@1[0]) & ~((snoop_0@1 == `CA53_SNOOP_MAKEINVALID) & addr_0@1[0])  => scu_ac_addr@1[40:6] != addr_0@1[40:6]")
  u_ovl_intf_assert_ea565db6785eb6538733028759f11c0766fcf776 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid_reg & ~dvm_req_reg & (outstanding_resps_reg >= 1) & ~((scu_ac_snoop_reg == `CA53_SNOOP_MAKEINVALID) & scu_ac_addr_reg[0]) & ~((snoop_0_reg == `CA53_SNOOP_MAKEINVALID) & addr_0_reg[0]) ),
    .consequent_expr (scu_ac_addr_reg[40:6] != addr_0_reg[40:6]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid@1 & ~dvm_req@1 & (outstanding_resps@1 >= 2) & ~((scu_ac_snoop@1 == `CA53_SNOOP_MAKEINVALID) & scu_ac_addr@1[0]) & ~((snoop_1@1 == `CA53_SNOOP_MAKEINVALID) & addr_1@1[0])  => scu_ac_addr@1[40:6] != addr_1@1[40:6]")
  u_ovl_intf_assert_2a1eb5a7c5cd81b3a3cc608d4a660ad862c84150 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid_reg & ~dvm_req_reg & (outstanding_resps_reg >= 2) & ~((scu_ac_snoop_reg == `CA53_SNOOP_MAKEINVALID) & scu_ac_addr_reg[0]) & ~((snoop_1_reg == `CA53_SNOOP_MAKEINVALID) & addr_1_reg[0]) ),
    .consequent_expr (scu_ac_addr_reg[40:6] != addr_1_reg[40:6]));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_ac_ids <= {8{1'b0}};
  else
    outstanding_ac_ids <= (({8{ac_valid_not_dvm & dcu_ac_ready}} & (1'b1 << scu_ac_id)) | (outstanding_ac_ids & ~({8{dcu_cr_valid}} & (1'b1 << dcu_cr_id))));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid  => ~outstanding_ac_ids[scu_ac_id]")
  u_ovl_intf_assert_0a0798c9e74cc909c1dd734c35edffaae6c0f82d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid ),
    .consequent_expr (~outstanding_ac_ids[scu_ac_id]));


  //----------------------------------------------------------------------------
  // CR Interface Properties
  //----------------------------------------------------------------------------

  assign crnt_snoop      = (outstanding_resps == 2'b10) ? snoop_1     : snoop_0;
  assign crnt_id         = (outstanding_resps == 2'b10) ? id_1        : id_0;

  // The contents of the Dirty RAM are not valid during an ECC CLEAN due to a detected
  // ECC error.
  assign ecc_clean       = (outstanding_resps == 2'b10) ? addr_1[0]   : addr_0[0];

  // The response should only be driven if there is an outstanding transaction.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cr_valid  => outstanding_resps > 0")
  u_ovl_intf_assume_f78d32bdb9681453d39bee300eeb537c71ec3042 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cr_valid ),
    .consequent_expr (outstanding_resps > 0));


  // The DCU cannot drive back to back responses.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cr_valid@1  => ~dcu_cr_valid")
  u_ovl_intf_assume_a8ba6ee12399d9363cbaad1ee432cb5deb724339 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cr_valid_reg ),
    .consequent_expr (~dcu_cr_valid));


  // The ID returned on CR should match the one driven with the AC transaction.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cr_valid  => dcu_cr_id == crnt_id")
  u_ovl_intf_assume_3e57b3eef71d79cb40b0ca72475727f275fb01ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cr_valid ),
    .consequent_expr (dcu_cr_id == crnt_id));



  // Only ReadShared snoops can return a migratory line

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cr_valid & dcu_cr_migratory  => (crnt_snoop == `CA53_SNOOP_READSHARED)")
  u_ovl_intf_assume_9981c17cb88df8a9af56f041a67a9c848bde3084 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cr_valid & dcu_cr_migratory ),
    .consequent_expr ((crnt_snoop == `CA53_SNOOP_READSHARED)));


  // There cannot be a zero latency snoop response from the DCU.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_cr_valid  => ~(ac_valid_not_dvm@1 & dcu_ac_ready@1 & dcu_cr_id == scu_ac_id@1)")
  u_ovl_intf_assume_0275de4d3a34d818f92a26c49a09c03825d7137c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_cr_valid ),
    .consequent_expr (~(ac_valid_not_dvm_reg & dcu_ac_ready_reg & dcu_cr_id == scu_ac_id_reg)));


  //----------------------------------------------------------------------------
  // DVM Properties
  //----------------------------------------------------------------------------

  assign dvm_req  = scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM);

  // For two part DVM Messages, the next transaction sent by the SCU after the
  // first half must be the second half, and the DCU must be ready to accept it.
  // ac_addr[0] indicates two part message

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    expecting_second_dvm <= 1'b0;
  else if (ac_handshake)
    expecting_second_dvm <= ac_handshake & first_dvm_req & scu_ac_addr[0];



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "expecting_second_dvm & scu_ac_valid  => scu_ac_snoop == `CA53_SNOOP_DVM")
  u_ovl_intf_assert_ee2e121a9d281955f734ffc1b694543d47297576 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (expecting_second_dvm & scu_ac_valid ),
    .consequent_expr (scu_ac_snoop == `CA53_SNOOP_DVM));



  assert_implication #(`OVL_FATAL, INOPTIONS, "expecting_second_dvm  => dcu_ac_ready")
  u_ovl_intf_assume_ae26d0d41e65f73ad33fe069eac9177617d240a1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (expecting_second_dvm ),
    .consequent_expr (dcu_ac_ready));


  // The DVM transaction information is encoded on the address in the following
  // format. Note that this is similar to, but slightly different from the
  // standard ACE DVM format.
  //
  // First transaction:
  //    [40]  VA[45]
  // [39:32]  ASID[15:8]
  // [31:24]  VMID or virtual index [27:20], if [6] is set
  // [23:16]  ASID[7:0] or virtual index [19:12], if [5] is set
  //    [15]  VA[48]
  // [14:12]  Message type
  // [11:10]  Guest OS/Hypervisor type
  //   [9:8]  Secure/Non-secure information
  //     [7]  VA[47]
  //     [6]  Indicates [31:24] is valid
  //     [5]  Indicates [23:16] is valid
  //     [4]  Only leaf entries need to be invalidated
  //   [3:2]  Stage to invalidate
  //     [1]  VA[46]
  //     [0]  Indicates a second transaction is required
  //
  // Second transaction (IC):
  // [40]     SBZ
  // [39:4]   PA[39:4]
  // [3:0]    SBZ
  //
  // Second transaction (BP, TLB):
  // [40]     VA[41]
  // [39:4]   VA[39:4]
  // [3]      VA[40]
  // [2:0]    VA[44:42]

  assign first_dvm_req  = dvm_req & ~expecting_second_dvm;


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req  => (scu_ac_addr[14:12] in [`CA53_ACE_DVM_TLBINV, `CA53_ACE_DVM_BPINV, `CA53_ACE_DVM_PHYSICINV, `CA53_ACE_DVM_VIRTICINV, `CA53_ACE_DVM_SYNC, `CA53_ACE_DVM_HINT, `CA53_DVM_TLBINV, `CA53_DVM_ICINV])")
  u_ovl_intf_assert_11e43ec3ea66a2fb30e67b949e4e6cdcf0ef9ca7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req ),
    .consequent_expr ((((scu_ac_addr[14:12] == `CA53_ACE_DVM_TLBINV) | (scu_ac_addr[14:12] ==  `CA53_ACE_DVM_BPINV) | (scu_ac_addr[14:12] ==  `CA53_ACE_DVM_PHYSICINV) | (scu_ac_addr[14:12] ==  `CA53_ACE_DVM_VIRTICINV) | (scu_ac_addr[14:12] ==  `CA53_ACE_DVM_SYNC) | (scu_ac_addr[14:12] ==  `CA53_ACE_DVM_HINT) | (scu_ac_addr[14:12] ==  `CA53_DVM_TLBINV) | (scu_ac_addr[14:12] ==  `CA53_DVM_ICINV)))));


  // Not all DVM encodings are possible:
  assign dvm_cmd  = {scu_ac_addr[11:8], scu_ac_addr[6:2], scu_ac_addr[0]};


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (scu_ac_addr[14:12] in [`CA53_ACE_DVM_TLBINV, `CA53_DVM_TLBINV])  => dvm_cmd in [ 10'b01_10_0_0_0_00_0, 10'b01_10_0_0_0_00_1, 10'b01_10_0_0_1_00_1, 10'b10_10_0_0_0_00_0, 10'b10_10_0_0_0_00_1, 10'b10_10_0_0_1_00_1, 10'b10_10_0_1_0_00_0, 10'b10_10_0_1_0_00_1, 10'b10_10_0_1_1_00_1, 10'b10_11_0_0_0_00_0, 10'b10_11_1_0_0_00_0, 10'b10_11_1_0_0_00_1, 10'b10_11_1_0_1_00_1, 10'b10_11_1_1_0_00_0, 10'b10_11_1_1_0_00_1, 10'b10_11_1_1_1_00_1, 10'b10_11_1_0_0_01_0, 10'b10_11_1_0_0_10_1, 10'b10_11_1_0_1_10_1, 10'b11_11_0_0_0_00_0, 10'b11_11_0_0_0_00_1, 10'b11_11_0_0_1_00_1 ]")
  u_ovl_intf_assert_aea84e2e97a0cd459e4aa23a5852153b05cb440d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (((scu_ac_addr[14:12] == `CA53_ACE_DVM_TLBINV) | (scu_ac_addr[14:12] ==  `CA53_DVM_TLBINV))) ),
    .consequent_expr (((dvm_cmd ==  10'b01_10_0_0_0_00_0) | (dvm_cmd ==  10'b01_10_0_0_0_00_1) | (dvm_cmd ==  10'b01_10_0_0_1_00_1) | (dvm_cmd ==  10'b10_10_0_0_0_00_0) | (dvm_cmd ==  10'b10_10_0_0_0_00_1) | (dvm_cmd ==  10'b10_10_0_0_1_00_1) | (dvm_cmd ==  10'b10_10_0_1_0_00_0) | (dvm_cmd ==  10'b10_10_0_1_0_00_1) | (dvm_cmd ==  10'b10_10_0_1_1_00_1) | (dvm_cmd ==  10'b10_11_0_0_0_00_0) | (dvm_cmd ==  10'b10_11_1_0_0_00_0) | (dvm_cmd ==  10'b10_11_1_0_0_00_1) | (dvm_cmd ==  10'b10_11_1_0_1_00_1) | (dvm_cmd ==  10'b10_11_1_1_0_00_0) | (dvm_cmd ==  10'b10_11_1_1_0_00_1) | (dvm_cmd ==  10'b10_11_1_1_1_00_1) | (dvm_cmd ==  10'b10_11_1_0_0_01_0) | (dvm_cmd ==  10'b10_11_1_0_0_10_1) | (dvm_cmd ==  10'b10_11_1_0_1_10_1) | (dvm_cmd ==  10'b11_11_0_0_0_00_0) | (dvm_cmd ==  10'b11_11_0_0_0_00_1) | (dvm_cmd ==  10'b11_11_0_0_1_00_1 ))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (scu_ac_addr[14:12] in [`CA53_ACE_DVM_PHYSICINV])  => dvm_cmd in [ 10'b00_10_0_0_0_00_0, 10'b00_10_0_0_0_00_1, 10'b00_10_1_1_0_00_1, 10'b00_11_0_0_0_00_0, 10'b00_11_0_0_0_00_1, 10'b00_11_1_1_0_00_1 ]")
  u_ovl_intf_assert_6cb83a4d3528e01d3963b4596b545b000dce6c46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (((scu_ac_addr[14:12] == `CA53_ACE_DVM_PHYSICINV))) ),
    .consequent_expr (((dvm_cmd ==  10'b00_10_0_0_0_00_0) | (dvm_cmd ==  10'b00_10_0_0_0_00_1) | (dvm_cmd ==  10'b00_10_1_1_0_00_1) | (dvm_cmd ==  10'b00_11_0_0_0_00_0) | (dvm_cmd ==  10'b00_11_0_0_0_00_1) | (dvm_cmd ==  10'b00_11_1_1_0_00_1 ))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (scu_ac_addr[14:12] in [`CA53_ACE_DVM_VIRTICINV])  => dvm_cmd in [ 10'b00_00_0_0_0_00_0, 10'b00_11_0_0_0_00_0, 10'b10_10_0_1_0_00_1, 10'b10_11_1_0_0_00_0, 10'b10_11_1_1_0_00_1, 10'b11_11_0_0_0_00_1 ]")
  u_ovl_intf_assert_74bb933a308d46f01442c3f44dca171928fac455 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (((scu_ac_addr[14:12] == `CA53_ACE_DVM_VIRTICINV))) ),
    .consequent_expr (((dvm_cmd ==  10'b00_00_0_0_0_00_0) | (dvm_cmd ==  10'b00_11_0_0_0_00_0) | (dvm_cmd ==  10'b10_10_0_1_0_00_1) | (dvm_cmd ==  10'b10_11_1_0_0_00_0) | (dvm_cmd ==  10'b10_11_1_1_0_00_1) | (dvm_cmd ==  10'b11_11_0_0_0_00_1 ))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (scu_ac_addr[14:12] in [`CA53_DVM_ICINV])  => dvm_cmd in [ 10'b00_00_0_0_0_00_0, 10'b00_10_1_1_0_00_1, 10'b00_11_0_0_0_00_0, 10'b00_11_1_1_0_00_1 ]")
  u_ovl_intf_assert_6dc6beb9d294a9617026a874af415396fd7ae02e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ac_valid & (scu_ac_snoop == `CA53_SNOOP_DVM) & ~expecting_second_dvm & (((scu_ac_addr[14:12] == `CA53_DVM_ICINV))) ),
    .consequent_expr (((dvm_cmd ==  10'b00_00_0_0_0_00_0) | (dvm_cmd ==  10'b00_10_1_1_0_00_1) | (dvm_cmd ==  10'b00_11_0_0_0_00_0) | (dvm_cmd ==  10'b00_11_1_1_0_00_1 ))));


  // The DCU must issue the same number of DVM Completes as the number of DVM Syncs driven
  // by the SCU.

  assign scu_dvm_sync  = first_dvm_req & (scu_ac_addr[14:12] == `CA53_ACE_DVM_SYNC) & dcu_ac_ready;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_syncs <= {9{1'b0}};
  else if (scu_dvm_sync | dcu_dvm_complete)
    outstanding_syncs <= outstanding_syncs + {8'b00000000, scu_dvm_sync} - {8'b00000000, dcu_dvm_complete};



  assert_implication #(`OVL_FATAL, INOPTIONS, "dcu_dvm_complete  => outstanding_syncs > 0")
  u_ovl_intf_assume_f682c97b2eaef9c59be348040710cdd8e78033b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dcu_dvm_complete ),
    .consequent_expr (outstanding_syncs > 0));


  // The SCU should only ever have a maximium of 256 + (NUM_CPUS - 1) outstanding sync messages.
  // - As NUM_CPUS is not used by the DCU, this can more generally be stated as 256 + 3 (as the
  //   maximum number of CPUs in a cluster is 4).

  assert_always #(`OVL_FATAL, OUTOPTIONS, "outstanding_syncs <= 9'd259")
  u_ovl_intf_assert_e26662f2cf79cc960df97f3c6129a1b8d413fd3e (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (outstanding_syncs <= 9'd259));


  //----------------------------------------------------------------------------
  // Top level interface
  //----------------------------------------------------------------------------

  // The SCU registers the top level BROADCASTINNER config pin, and provides it
  // to the DCU.
  //  output scu_broadcastinner valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_broadcastinner X or Z")
  u_ovl_intf_x_scu_broadcastinner (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_broadcastinner));





endmodule

`define CA53_UNDEFINE
`include "ca53_biu_scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_scu_dcu_defs.v"
`undef CA53_UNDEFINE

`endif

