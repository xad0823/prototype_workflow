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


// This is the specification for the interface between the BIU and the SCU for
// the read and write channels. The signals closely follow their equivalents in
// ACE.

// Inputs and outputs are from the point of view of the BIU.
// Note that the SCU has up to four copies of this interface, so the actual
// signal names will be modified based on the CPU they refer to.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_biu_scu_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_scu_dcu_defs.v"

module ca53_biu_scu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         scu_ar_credit_i,
  input         scu_ar_block_i,
  input         scu_dr_valid_i,
  input   [4:0] scu_dr_id_i,
  input   [5:0] scu_dr_resp_i,
  input   [1:0] scu_dr_chunk_i,
  input [127:0] scu_dr_data_i,
  input         scu_rr_valid_i,
  input   [4:0] scu_rr_id_i,
  input   [1:0] scu_rr_resp_i,
  input   [3:0] scu_rr_l2db_id_i,
  input   [7:0] scu_ev_done_i,
  input         scu_db_excl_valid_i,
  input   [1:0] scu_db_excl_resp_i,
  input         scu_db_decerr_i,
  input         scu_db_slverr_i,
  input         scu_leave_ramode_i,
  input         scu_ac_valid_i,
  input         dcu_ac_ready_i,
  input   [2:0] scu_ac_snoop_i,
  input   [2:0] scu_ac_id_i,
  input   [3:0] scu_ac_l2db_id_i,
  input         dcu_cr_valid_i,
  input   [2:0] dcu_cr_id_i,
  input         biu_ar_active_i,
  input         biu_ar_valid_i,
  input   [4:0] biu_ar_id_i,
  input   [4:0] biu_ar_type_i,
  input   [7:0] biu_ar_attrs_i,
  input   [4:0] biu_ar_way_i,
  input  [40:0] biu_ar_addr_i,
  input   [1:0] biu_ar_len_i,
  input   [2:0] biu_ar_size_i,
  input         biu_ar_lock_i,
  input         biu_ar_priv_i,
  input         biu_dr_credit_i,
  input         biu_dw_valid_i,
  input   [3:0] biu_dw_l2db_id_i,
  input   [3:0] biu_dw_chunks_valid_i,
  input         biu_dw_last_i,
  input [255:0] biu_dw_data_i,
  input  [31:0] biu_dw_strb_i,
  input         biu_dw_err_i,
  input         biu_dw_fatal_i);


  wire         scu_ar_credit = scu_ar_credit_i;
  wire         scu_ar_block = scu_ar_block_i;
  wire         scu_dr_valid = scu_dr_valid_i;
  wire   [4:0] scu_dr_id = scu_dr_id_i;
  wire   [5:0] scu_dr_resp = scu_dr_resp_i;
  wire   [1:0] scu_dr_chunk = scu_dr_chunk_i;
  wire [127:0] scu_dr_data = scu_dr_data_i;
  wire         scu_rr_valid = scu_rr_valid_i;
  wire   [4:0] scu_rr_id = scu_rr_id_i;
  wire   [1:0] scu_rr_resp = scu_rr_resp_i;
  wire   [3:0] scu_rr_l2db_id = scu_rr_l2db_id_i;
  wire   [7:0] scu_ev_done = scu_ev_done_i;
  wire         scu_db_excl_valid = scu_db_excl_valid_i;
  wire   [1:0] scu_db_excl_resp = scu_db_excl_resp_i;
  wire         scu_db_decerr = scu_db_decerr_i;
  wire         scu_db_slverr = scu_db_slverr_i;
  wire         scu_leave_ramode = scu_leave_ramode_i;
  wire         scu_ac_valid = scu_ac_valid_i;
  wire         dcu_ac_ready = dcu_ac_ready_i;
  wire   [2:0] scu_ac_snoop = scu_ac_snoop_i;
  wire   [2:0] scu_ac_id = scu_ac_id_i;
  wire   [3:0] scu_ac_l2db_id = scu_ac_l2db_id_i;
  wire         dcu_cr_valid = dcu_cr_valid_i;
  wire   [2:0] dcu_cr_id = dcu_cr_id_i;
  wire         biu_ar_active = biu_ar_active_i;
  wire         biu_ar_valid = biu_ar_valid_i;
  wire   [4:0] biu_ar_id = biu_ar_id_i;
  wire   [4:0] biu_ar_type = biu_ar_type_i;
  wire   [7:0] biu_ar_attrs = biu_ar_attrs_i;
  wire   [4:0] biu_ar_way = biu_ar_way_i;
  wire  [40:0] biu_ar_addr = biu_ar_addr_i;
  wire   [1:0] biu_ar_len = biu_ar_len_i;
  wire   [2:0] biu_ar_size = biu_ar_size_i;
  wire         biu_ar_lock = biu_ar_lock_i;
  wire         biu_ar_priv = biu_ar_priv_i;
  wire         biu_dr_credit = biu_dr_credit_i;
  wire         biu_dw_valid = biu_dw_valid_i;
  wire   [3:0] biu_dw_l2db_id = biu_dw_l2db_id_i;
  wire   [3:0] biu_dw_chunks_valid = biu_dw_chunks_valid_i;
  wire         biu_dw_last = biu_dw_last_i;
  wire [255:0] biu_dw_data = biu_dw_data_i;
  wire  [31:0] biu_dw_strb = biu_dw_strb_i;
  wire         biu_dw_err = biu_dw_err_i;
  wire         biu_dw_fatal = biu_dw_fatal_i;

  wire         read_icu1_completed;
  wire         outstanding_lock;
  wire         strict_alignment;
  wire   [3:0] next_remaining_icu1_beats;
  wire         read_stb2_completed;
  wire         read_tlb_completed;
  wire   [3:0] next_remaining_icu0_beats;
  wire         data_is_dvm;
  wire   [4:0] dr_type;
  wire         snoop_resp_has_data;
  wire   [7:0] expect_ev_done;
  wire         read_lfb5_completed;
  wire         read_lfb6_completed;
  wire         read_lfb0_completed;
  wire         read_lfb3_completed;
  wire         read_dcu2_completed;
  wire   [9:0] dvm_request_type;
  wire   [3:0] next_remaining_lfb1_beats;
  wire         read_ecc_completed;
  wire         read_stb0_completed;
  wire         read_icu0_completed;
  wire         new_snoop;
  wire         read_lfb1_completed;
  wire   [3:0] next_remaining_tlb_beats;
  wire   [3:0] initial_beats_remaining;
  wire         biu_ar_wrap;
  wire   [3:0] next_remaining_lfb4_beats;
  wire   [3:0] next_remaining_lfb5_beats;
  wire         data_is_snoop;
  wire   [3:0] snoop_resp_l2db_id;
  wire   [3:0] next_remaining_icu2_beats;
  wire   [3:0] next_remaining_dcu1_beats;
  wire         read_stb3_completed;
  wire   [3:0] next_remaining_dcu2_beats;
  wire [255:0] biu_dw_expanded_strobes;
  wire   [3:0] next_remaining_lfb2_beats;
  wire   [4:0] rr_type;
  wire         dr_lock;
  wire   [3:0] next_remaining_lfb7_beats;
  wire   [3:0] next_remaining_lfb6_beats;
  wire   [3:0] next_remaining_dcu0_beats;
  wire         second_dvm_req;
  wire         read_lfb2_completed;
  wire  [15:0] next_outstanding_snoop_resp_l2db_ids;
  wire         read_stb4_completed;
  wire         read_stb1_completed;
  wire         read_lfb7_completed;
  wire   [3:0] next_remaining_lfb0_beats;
  wire         ar_credit_used;
  wire         read_lfb4_completed;
  wire         read_icu2_completed;
  wire   [3:0] next_remaining_dcu3_beats;
  wire   [3:0] next_remaining_lfb3_beats;
  wire         new_write;
  wire   [3:0] remaining_beats;
  wire         read_rnone_completed;
  wire         read_dcu3_completed;
  wire         first_dvm_req;
  wire [4*16-1:0] new_beats;
  wire         read_dcu0_completed;
  wire         read_dcu1_completed;
  wire         snoop_has_data;

  reg   [3:0] snoop2_l2db_id;
  reg   [3:0] remaining_lfb0_beats;
  reg         outstanding_dcu0_lock;
  reg   [3:0] remaining_icu2_beats;
  reg         outstanding_stb3_lock;
  reg         outstanding_dcu3_lock;
  reg   [3:0] remaining_tlb_beats;
  reg         first_lfb1_beat_seen;
  reg         outstanding_lfb4_lock;
  reg         snoop5_has_data;
  reg         lfb0_isshared;
  reg   [3:0] snoop1_l2db_id;
  reg   [4:0] outstanding_stb0_type;
  reg         first_lfb4_beat_seen;
  reg   [4:0] outstanding_tlb_type;
  reg   [4:0] outstanding_dcu0_type;
  reg         read_stb2_outstanding;
  reg   [3:0] remaining_lfb4_beats;
  reg         read_dcu3_outstanding;
  reg   [4:0] outstanding_lfb6_type;
  reg   [4:0] outstanding_lfb2_type;
  reg   [4:0] outstanding_lfb1_type;
  reg         outstanding_stb4_lock;
  reg   [4:0] outstanding_dcu1_type;
  reg         outstanding_stb2_lock;
  reg         read_stb3_outstanding;
  reg         read_lfb2_outstanding;
  reg         snoop0_has_data;
  reg   [2:0] dr_credits_used;
  reg         outstanding_lfb5_lock;
  reg         read_stb0_outstanding;
  reg         lfb0_passdirty;
  reg         lfb4_isshared;
  reg         outstanding_dcu1_lock;
  reg         first_lfb7_beat_seen;
  reg         first_lfb2_beat_seen;
  reg         first_lfb0_beat_seen;
  reg         read_lfb0_outstanding;
  reg   [3:0] remaining_lfb7_beats;
  reg         read_icu2_outstanding;
  reg   [3:0] snoop5_l2db_id;
  reg         read_lfb5_outstanding;
  reg         lfb2_passdirty;
  reg   [3:0] snoop7_l2db_id;
  reg         first_lfb3_beat_seen;
  reg         read_dcu1_outstanding;
  reg  [15:0] outstanding_dvm_l2db_ids;
  reg   [3:0] remaining_lfb5_beats;
  reg   [3:0] remaining_dcu1_beats;
  reg         first_lfb6_beat_seen;
  reg         lfb1_passdirty;
  reg         lfb3_isshared;
  reg         outstanding_lfb1_lock;
  reg         outstanding_excl;
  reg         lfb5_passdirty;
  reg         dvm_second_part_expected;
  reg         lfb4_passdirty;
  reg   [4:0] outstanding_stb3_type;
  reg         lfb5_isshared;
  reg         read_lfb7_outstanding;
  reg   [4:0] outstanding_lfb4_type;
  reg  [15:0] outstanding_snoop_l2db_ids;
  reg   [4:0] outstanding_stb1_type;
  reg         snoop4_has_data;
  reg   [4:0] outstanding_lfb3_type;
  reg   [7:0] ev_done_required;
  reg   [4:0] outstanding_lfb7_type;
  reg         read_ecc_outstanding;
  reg         read_stb1_outstanding;
  reg  [15:0] first_beat_seen;
  reg   [3:0] remaining_icu1_beats;
  reg         read_tlb_outstanding;
  reg   [4:0] outstanding_stb4_type;
  reg   [3:0] remaining_lfb3_beats;
  reg         read_dcu0_outstanding;
  reg         read_lfb6_outstanding;
  reg         lfb1_isshared;
  reg         snoop7_has_data;
  reg         outstanding_stb1_lock;
  reg         read_lfb4_outstanding;
  reg         lfb3_passdirty;
  reg   [3:0] snoop4_l2db_id;
  reg   [4:0] outstanding_icu0_type;
  reg         first_lfb5_beat_seen;
  reg         snoop3_has_data;
  reg   [3:0] remaining_dcu0_beats;
  reg   [3:0] remaining_lfb2_beats;
  reg [4*16-1:0] beats_seen;
  reg         lfb6_passdirty;
  reg         read_stb4_outstanding;
  reg         outstanding_lfb0_lock;
  reg         snoop1_has_data;
  reg   [3:0] remaining_dcu3_beats;
  reg         lfb7_isshared;
  reg         outstanding_lfb6_lock;
  reg         lfb7_passdirty;
  reg   [3:0] ar_credits_used;
  reg         lfb6_isshared;
  reg   [3:0] snoop3_l2db_id;
  reg   [4:0] outstanding_lfb0_type;
  reg   [3:0] remaining_lfb1_beats;
  reg   [4:0] outstanding_dcu2_type;
  reg   [3:0] remaining_lfb6_beats;
  reg         lfb2_isshared;
  reg   [4:0] outstanding_icu2_type;
  reg   [3:0] snoop6_l2db_id;
  reg  [15:0] outstanding_write_l2db_ids;
  reg         read_rnone_outstanding;
  reg         read_lfb1_outstanding;
  reg         outstanding_stb0_lock;
  reg   [4:0] outstanding_stb2_type;
  reg         read_icu1_outstanding;
  reg         outstanding_dcu2_lock;
  reg  [15:0] outstanding_snoop_resp_l2db_ids;
  reg         read_icu0_outstanding;
  reg         outstanding_lfb3_lock;
  reg   [4:0] outstanding_dcu3_type;
  reg   [3:0] remaining_dcu2_beats;
  reg   [4:0] outstanding_lfb5_type;
  reg         snoop2_has_data;
  reg         outstanding_lfb2_lock;
  reg   [4:0] outstanding_icu1_type;
  reg         snoop6_has_data;
  reg   [3:0] snoop0_l2db_id;
  reg   [3:0] remaining_icu0_beats;
  reg         read_lfb3_outstanding;
  reg         read_dcu2_outstanding;
  reg         outstanding_lfb7_lock;

  reg         biu_dw_valid_reg;
  reg         biu_ar_active_reg;
  reg         scu_ar_block_reg;
  reg         scu_ar_block_reg_reg;
  reg         scu_ar_block_reg_reg_reg;
  reg         scu_ar_block_reg_reg_reg_reg;
  reg         new_write_reg;
  reg         biu_dw_err_reg;
  reg         new_snoop_reg;
  reg   [3:0] scu_rr_l2db_id_reg;
  reg   [3:0] scu_ac_l2db_id_reg;
  reg   [4:0] biu_ar_id_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    biu_dw_valid_reg <= 1'b0;
    biu_ar_active_reg <= 1'b0;
    scu_ar_block_reg <= 1'b0;
    scu_ar_block_reg_reg <= 1'b0;
    scu_ar_block_reg_reg_reg <= 1'b0;
    scu_ar_block_reg_reg_reg_reg <= 1'b0;
    new_write_reg <= 1'b0;
    biu_dw_err_reg <= 1'b0;
    new_snoop_reg <= 1'b0;
    scu_rr_l2db_id_reg <= 4'b0000;
    scu_ac_l2db_id_reg <= 4'b0000;
    biu_ar_id_reg <= {5{1'b0}};
  end
  else
  begin
    scu_ar_block_reg <= scu_ar_block;
    scu_ar_block_reg_reg <= scu_ar_block_reg;
    scu_ar_block_reg_reg_reg <= scu_ar_block_reg_reg;
    scu_ar_block_reg_reg_reg_reg <= scu_ar_block_reg_reg_reg;
    scu_rr_l2db_id_reg <= scu_rr_l2db_id;
    scu_ac_l2db_id_reg <= scu_ac_l2db_id;
    biu_ar_active_reg <= biu_ar_active;
    biu_ar_id_reg <= biu_ar_id;
    biu_dw_valid_reg <= biu_dw_valid;
    biu_dw_err_reg <= biu_dw_err;
    new_write_reg <= new_write;
    new_snoop_reg <= new_snoop;
  end




  //----------------------------------------------------------------------------
  // Address Request channel
  //----------------------------------------------------------------------------

  // Request types
  // These are encoded so that bit[4] can distinguish requests that will
  // provide write data, and bit[3] indicates those that cannot make a tagctl
  // request on their first cycle.

  // Request IDs
  // The L2FLUSH ID is not used by the BIU, but is inserted by the SCU.


  // The SCU has completed a request and hence now has space for a new request.
  //  input scu_ar_credit valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ar_credit X or Z")
  u_ovl_intf_x_scu_ar_credit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ar_credit));


  // The SCU is busy and does not want to receive any new requests from the BIU.
  // This is only used when a tag invalidation is pending, or when an L2 flush
  // request is in progress, both cases when a CPU is unlikely to be wanting to
  // send requests anyway. Once this is asserted, the BIU must not send any new
  // requests except for the first cycle after the block is asserted.
  //  input scu_ar_block valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ar_block X or Z")
  u_ovl_intf_x_scu_ar_block (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ar_block));


  // The BIU may present a request in the next cycle
  //  output biu_ar_active valid always timing 60% wiring 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_ar_active X or Z")
  u_ovl_intf_x_biu_ar_active (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_ar_active));


  // The BIU has a new request.
  //  output biu_ar_valid valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_ar_valid X or Z")
  u_ovl_intf_x_biu_ar_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_ar_valid));


  // The AXI ID to use for the request, or a slot identifier for MakeUnique, Write*
  // and cache maintenance requests.
  //  output [4:0] biu_ar_id valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "biu_ar_id X or Z")
  u_ovl_intf_x_biu_ar_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_id));


  // Type of snoop activity required for the transaction (including barriers)
  //  output [4:0] biu_ar_type valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "biu_ar_type X or Z")
  u_ovl_intf_x_biu_ar_type (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_type));


  // Memory type and shareability attributes
  //  output [7:0] biu_ar_attrs valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "biu_ar_attrs X or Z")
  u_ovl_intf_x_biu_ar_attrs (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_attrs));


  // The way that the linefill is going to be allocated to (for ReadClean,
  // ReadShared, and ReadUnique), or the way that is already allocated
  // (for CleanUnique), or all ways set for requests that must lookup in the
  // requestor as well (ReadOnce, ReadNone, CleanShared, CleanInvalid,
  // MakeInvalid). The top bit indicates if other CPUs and L2 should be
  // looked up.
  //  output [4:0] biu_ar_way valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "biu_ar_way X or Z")
  u_ovl_intf_x_biu_ar_way (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_way));


  // The physical address of the request, including the NS bit.
  // For CLEANSETWAY, CLEANINVSETWAY, and ECCCLEAN, bits [3:1] represents the
  // Level (0 - L1, 1 - L2 and so on) and bits [13:6] the Set. Bits [31:30] or
  // [31:28] indicate the way for L1 or L2 operations respectively. Other bits
  // are ignored.
  //  output [40:0] biu_ar_addr valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 41, OUTOPTIONS, "biu_ar_addr X or Z")
  u_ovl_intf_x_biu_ar_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_addr));


  // The number of beats in the burst, minus one.
  //  output [1:0] biu_ar_len valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "biu_ar_len X or Z")
  u_ovl_intf_x_biu_ar_len (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_len));


  // The size (bytes) of each beat.
  //  output [2:0] biu_ar_size valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "biu_ar_size X or Z")
  u_ovl_intf_x_biu_ar_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_size));


  // Exclusive access and lock control
  //  output biu_ar_lock valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_ar_lock X or Z")
  u_ovl_intf_x_biu_ar_lock (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_lock));


  // The privileged state, and access type.
  //  output biu_ar_priv valid biu_ar_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_ar_priv X or Z")
  u_ovl_intf_x_biu_ar_priv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_ar_valid),
    .test_expr (biu_ar_priv));




  // Assertions - address handshake
  // ------------------------------

  // There are a total of 8 credits, and on reset the BIU holds them all.
  // Every time the BIU sends an address request, it uses a credit (except
  // for the second half of 2 part DVMs, which don't need a credit). When all
  // credits are used, it must not send any more requests. The SCU will return
  // credits when it has freed up a request buffer.
  assign ar_credit_used  = biu_ar_valid & ~dvm_second_part_expected;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ar_credits_used <= 4'b0000;
  else
    ar_credits_used <= ar_credits_used + {3'b000, ar_credit_used} - {3'b000, scu_ar_credit};


  // Only 8 credits may be used.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "ar_credits_used <= 4'b1000")
  u_ovl_intf_assert_b9c2d0aa72079fbf5d762cda03737006d6e8cdbf (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (ar_credits_used <= 4'b1000));


  // When all credits are used, no new data beats may be sent.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ar_credits_used == 4'b1000  => (~biu_ar_valid  | dvm_second_part_expected)")
  u_ovl_intf_assert_eb5562cb25614c913a3742898d9e6d9ee12fd727 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ar_credits_used == 4'b1000 ),
    .consequent_expr ((~biu_ar_valid  | dvm_second_part_expected)));


  // The SCU must only return credits that it received.

  assert_implication #(`OVL_FATAL, INOPTIONS, "ar_credits_used == 4'b0000  => ~scu_ar_credit")
  u_ovl_intf_assume_0dd2f024d768efeb9a84e9feb68f034ed4380c0f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ar_credits_used == 4'b0000 ),
    .consequent_expr (~scu_ar_credit));


  // If the valid signal is asserted this cycle, active must have been
  // asserted last cycle

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid  => biu_ar_active@1")
  u_ovl_intf_assert_b8550f6bc6c061f77fc88072c95f97c303ea1de4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid ),
    .consequent_expr (biu_ar_active_reg));


  // When blocked, the BIU must stop sending requests. The worst case is if the
  // BIU sends the first half of a two part DVM in the cycle after scu_ar_block
  // is asserted.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ar_block@2 & scu_ar_block@3  => ~ar_credit_used")
  u_ovl_intf_assert_cb3286e9c4291766d4a5e985784e421bbe90bf11 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ar_block_reg_reg & scu_ar_block_reg_reg_reg ),
    .consequent_expr (~ar_credit_used));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ar_block@2 & scu_ar_block@3 & scu_ar_block@4  => ~biu_ar_valid")
  u_ovl_intf_assert_39dbb524cfff3abb51aa74290d20730a7e98145d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ar_block_reg_reg & scu_ar_block_reg_reg_reg & scu_ar_block_reg_reg_reg_reg ),
    .consequent_expr (~biu_ar_valid));


  // Assertions - IDs
  // ----------------


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid  => biu_ar_id in [`CA53_RID_DCU0, `CA53_RID_DCU1, `CA53_RID_DCU2, `CA53_RID_DCU3, `CA53_RID_LFB0, `CA53_RID_LFB1, `CA53_RID_LFB2, `CA53_RID_LFB3, `CA53_RID_LFB4, `CA53_RID_LFB5, `CA53_RID_LFB6, `CA53_RID_LFB7, `CA53_RID_ICU0, `CA53_RID_ICU1, `CA53_RID_ICU2, `CA53_RID_TLB, `CA53_RID_ECC, `CA53_RID_RNONE, `CA53_RID_STB0, `CA53_RID_STB1, `CA53_RID_STB2, `CA53_RID_STB3, `CA53_RID_STB4]")
  u_ovl_intf_assert_e79b49454462dd89948fd98d9662b02a92a6bd7d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid ),
    .consequent_expr (((biu_ar_id == `CA53_RID_DCU0) | (biu_ar_id ==  `CA53_RID_DCU1) | (biu_ar_id ==  `CA53_RID_DCU2) | (biu_ar_id ==  `CA53_RID_DCU3) | (biu_ar_id ==  `CA53_RID_LFB0) | (biu_ar_id ==  `CA53_RID_LFB1) | (biu_ar_id ==  `CA53_RID_LFB2) | (biu_ar_id ==  `CA53_RID_LFB3) | (biu_ar_id ==  `CA53_RID_LFB4) | (biu_ar_id ==  `CA53_RID_LFB5) | (biu_ar_id ==  `CA53_RID_LFB6) | (biu_ar_id ==  `CA53_RID_LFB7) | (biu_ar_id ==  `CA53_RID_ICU0) | (biu_ar_id ==  `CA53_RID_ICU1) | (biu_ar_id ==  `CA53_RID_ICU2) | (biu_ar_id ==  `CA53_RID_TLB) | (biu_ar_id ==  `CA53_RID_ECC) | (biu_ar_id ==  `CA53_RID_RNONE) | (biu_ar_id ==  `CA53_RID_STB0) | (biu_ar_id ==  `CA53_RID_STB1) | (biu_ar_id ==  `CA53_RID_STB2) | (biu_ar_id ==  `CA53_RID_STB3) | (biu_ar_id ==  `CA53_RID_STB4))));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_dcu0_outstanding <= 1'b0;
  else
    read_dcu0_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0)) | (read_dcu0_outstanding & ~read_dcu0_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_dcu1_outstanding <= 1'b0;
  else
    read_dcu1_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1)) | (read_dcu1_outstanding & ~read_dcu1_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_dcu2_outstanding <= 1'b0;
  else
    read_dcu2_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2)) | (read_dcu2_outstanding & ~read_dcu2_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_dcu3_outstanding <= 1'b0;
  else
    read_dcu3_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3)) | (read_dcu3_outstanding & ~read_dcu3_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb0_outstanding <= 1'b0;
  else
    read_lfb0_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0)) | (read_lfb0_outstanding & ~read_lfb0_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb1_outstanding <= 1'b0;
  else
    read_lfb1_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1)) | (read_lfb1_outstanding & ~read_lfb1_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb2_outstanding <= 1'b0;
  else
    read_lfb2_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2)) | (read_lfb2_outstanding & ~read_lfb2_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb3_outstanding <= 1'b0;
  else
    read_lfb3_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3)) | (read_lfb3_outstanding & ~read_lfb3_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb4_outstanding <= 1'b0;
  else
    read_lfb4_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4)) | (read_lfb4_outstanding & ~read_lfb4_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb5_outstanding <= 1'b0;
  else
    read_lfb5_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5)) | (read_lfb5_outstanding & ~read_lfb5_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb6_outstanding <= 1'b0;
  else
    read_lfb6_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6)) | (read_lfb6_outstanding & ~read_lfb6_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_lfb7_outstanding <= 1'b0;
  else
    read_lfb7_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7)) | (read_lfb7_outstanding & ~read_lfb7_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_icu0_outstanding <= 1'b0;
  else
    read_icu0_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU0)) | (read_icu0_outstanding & ~read_icu0_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_icu1_outstanding <= 1'b0;
  else
    read_icu1_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU1)) | (read_icu1_outstanding & ~read_icu1_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_icu2_outstanding <= 1'b0;
  else
    read_icu2_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU2)) | (read_icu2_outstanding & ~read_icu2_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_tlb_outstanding <= 1'b0;
  else
    read_tlb_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_TLB))  | (read_tlb_outstanding & ~read_tlb_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_ecc_outstanding <= 1'b0;
  else
    read_ecc_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ECC))  | (read_ecc_outstanding & ~read_ecc_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_rnone_outstanding <= 1'b0;
  else
    read_rnone_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_RNONE))| (read_rnone_outstanding & ~read_rnone_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_stb0_outstanding <= 1'b0;
  else
    read_stb0_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_STB0)) | (read_stb0_outstanding & ~read_stb0_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_stb1_outstanding <= 1'b0;
  else
    read_stb1_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_STB1)) | (read_stb1_outstanding & ~read_stb1_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_stb2_outstanding <= 1'b0;
  else
    read_stb2_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_STB2)) | (read_stb2_outstanding & ~read_stb2_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_stb3_outstanding <= 1'b0;
  else
    read_stb3_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_STB3)) | (read_stb3_outstanding & ~read_stb3_completed));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    read_stb4_outstanding <= 1'b0;
  else
    read_stb4_outstanding <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_STB4)) | (read_stb4_outstanding & ~read_stb4_completed));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu0_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0))
    outstanding_dcu0_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu1_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1))
    outstanding_dcu1_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu2_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2))
    outstanding_dcu2_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu3_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3))
    outstanding_dcu3_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb0_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0))
    outstanding_lfb0_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb1_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1))
    outstanding_lfb1_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb2_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2))
    outstanding_lfb2_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb3_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3))
    outstanding_lfb3_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb4_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4))
    outstanding_lfb4_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb5_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5))
    outstanding_lfb5_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb6_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6))
    outstanding_lfb6_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb7_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7))
    outstanding_lfb7_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb0_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB0))
    outstanding_stb0_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb1_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB1))
    outstanding_stb1_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb2_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB2))
    outstanding_stb2_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb3_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB3))
    outstanding_stb3_lock <= biu_ar_lock;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb4_lock <= 1'b0;
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB4))
    outstanding_stb4_lock <= biu_ar_lock;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu0_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0))
    outstanding_dcu0_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu1_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1))
    outstanding_dcu1_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu2_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2))
    outstanding_dcu2_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dcu3_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3))
    outstanding_dcu3_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb0_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0))
    outstanding_lfb0_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb1_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1))
    outstanding_lfb1_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb2_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2))
    outstanding_lfb2_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb3_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3))
    outstanding_lfb3_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb4_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4))
    outstanding_lfb4_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb5_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5))
    outstanding_lfb5_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb6_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6))
    outstanding_lfb6_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_lfb7_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7))
    outstanding_lfb7_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb0_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB0))
    outstanding_stb0_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb1_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB1))
    outstanding_stb1_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb2_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB2))
    outstanding_stb2_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb3_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB3))
    outstanding_stb3_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_stb4_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_STB4))
    outstanding_stb4_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_tlb_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_TLB))
    outstanding_tlb_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_icu0_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU0))
    outstanding_icu0_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_icu1_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU1))
    outstanding_icu1_type <= biu_ar_type;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_icu2_type <= {5{1'b0}};
  else if (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU2))
    outstanding_icu2_type <= biu_ar_type;




  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0)  => ~read_dcu0_outstanding")
  u_ovl_intf_assert_eb72c3180038e887bcc6c336583d90bb1e850e84 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0) ),
    .consequent_expr (~read_dcu0_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1)  => ~read_dcu1_outstanding")
  u_ovl_intf_assert_f10b5b5ec9b095d8b2b1410729178b5d5364e0c2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1) ),
    .consequent_expr (~read_dcu1_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2)  => ~read_dcu2_outstanding")
  u_ovl_intf_assert_53d076e1e86587ba2402055491ea153233c16c0b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2) ),
    .consequent_expr (~read_dcu2_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3)  => ~read_dcu3_outstanding")
  u_ovl_intf_assert_bb0eb661d0c9d2b3b8d56e8fc03fa943f211dafe (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3) ),
    .consequent_expr (~read_dcu3_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0)  => ~read_lfb0_outstanding")
  u_ovl_intf_assert_f55acbecec304066466e31e07d4961286b347c6d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0) ),
    .consequent_expr (~read_lfb0_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1)  => ~read_lfb1_outstanding")
  u_ovl_intf_assert_d15845d322951ab196e9e18e563f13cf09d2d9fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1) ),
    .consequent_expr (~read_lfb1_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2)  => ~read_lfb2_outstanding")
  u_ovl_intf_assert_3ce3510c34561f661006b853f1b9b13e7b18a96a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2) ),
    .consequent_expr (~read_lfb2_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3)  => ~read_lfb3_outstanding")
  u_ovl_intf_assert_1b7986b9e1b85e2b41e25261b04f1256773dc61d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3) ),
    .consequent_expr (~read_lfb3_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4)  => ~read_lfb4_outstanding")
  u_ovl_intf_assert_e382281b3251da04ac2310897a7fe226a1381075 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4) ),
    .consequent_expr (~read_lfb4_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5)  => ~read_lfb5_outstanding")
  u_ovl_intf_assert_f5735ebe31a8a7adfddab41f9aa4a7ebf04e1369 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5) ),
    .consequent_expr (~read_lfb5_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6)  => ~read_lfb6_outstanding")
  u_ovl_intf_assert_c318d26d1e4414cfd060d5be70a423671dadfb3b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6) ),
    .consequent_expr (~read_lfb6_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7)  => ~read_lfb7_outstanding")
  u_ovl_intf_assert_c1279dcfc9ca74f8ec23d96597b6ee72eaa6a692 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7) ),
    .consequent_expr (~read_lfb7_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_ICU0)  => ~read_icu0_outstanding")
  u_ovl_intf_assert_67b7cf586285dc840dec8eb60edadfc95dcec098 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU0) ),
    .consequent_expr (~read_icu0_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_ICU1)  => ~read_icu1_outstanding")
  u_ovl_intf_assert_3283faab9a639ddbac2657f2288d1471f6f65773 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU1) ),
    .consequent_expr (~read_icu1_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_ICU2)  => ~read_icu2_outstanding")
  u_ovl_intf_assert_57d409c0ab4b0b29225e829f9c9967b08b1031a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_ICU2) ),
    .consequent_expr (~read_icu2_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_TLB)   => ~read_tlb_outstanding")
  u_ovl_intf_assert_0a99bd75c048a7930b892313d153e3de3d029fab (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_TLB)  ),
    .consequent_expr (~read_tlb_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_ECC)   => ~read_ecc_outstanding")
  u_ovl_intf_assert_fd8fd80468201c96999cbd5165e7191f4a0c835e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_ECC)  ),
    .consequent_expr (~read_ecc_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_RNONE) => ~read_rnone_outstanding")
  u_ovl_intf_assert_91ddd0302bce3ffeab02facfbbfc282f0b8d4605 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_RNONE)),
    .consequent_expr (~read_rnone_outstanding));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_STB0)  => ~read_stb0_outstanding | dvm_second_part_expected")
  u_ovl_intf_assert_6906ddbd30482f898a6aed75ee5513ee26aaebee (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_STB0) ),
    .consequent_expr (~read_stb0_outstanding | dvm_second_part_expected));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_STB1)  => ~read_stb1_outstanding | dvm_second_part_expected")
  u_ovl_intf_assert_559500a1c014d1bd277a84895dbbf8a08019f41c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_STB1) ),
    .consequent_expr (~read_stb1_outstanding | dvm_second_part_expected));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_STB2)  => ~read_stb2_outstanding | dvm_second_part_expected")
  u_ovl_intf_assert_9c4da4cc7ec1586835762111c2cd0f07ab371297 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_STB2) ),
    .consequent_expr (~read_stb2_outstanding | dvm_second_part_expected));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_STB3)  => ~read_stb3_outstanding | dvm_second_part_expected")
  u_ovl_intf_assert_7ba3526a5534e719e01234bc9df52af6d98c2070 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_STB3) ),
    .consequent_expr (~read_stb3_outstanding | dvm_second_part_expected));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_STB4)  => ~read_stb4_outstanding | dvm_second_part_expected")
  u_ovl_intf_assert_5e147a9e9f7180cb82ff4b7f2e63eb2b7e43b751 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_STB4) ),
    .consequent_expr (~read_stb4_outstanding | dvm_second_part_expected));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dvm_second_part_expected <= 1'b0;
  else
    dvm_second_part_expected <= biu_ar_valid ? ((biu_ar_type == `CA53_REQ_DVM) & biu_ar_addr[0] & ~dvm_second_part_expected) : dvm_second_part_expected;


  // The parts of a 2 part DVM must be sent on consecutive cycles.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dvm_second_part_expected  => biu_ar_valid")
  u_ovl_intf_assert_1e4fb3eed7de70d9b8d1cbbd17852eb4069133f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dvm_second_part_expected ),
    .consequent_expr (biu_ar_valid));


  // The second part of a DVM must be a DVM message.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dvm_second_part_expected  => (biu_ar_type == `CA53_REQ_DVM)")
  u_ovl_intf_assert_e8e665f4d8056844f41a6fb9f29becb8c3cf8f07 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dvm_second_part_expected ),
    .consequent_expr ((biu_ar_type == `CA53_REQ_DVM)));


  // The second part of a DVM must be from the same source as the first part.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dvm_second_part_expected  => (biu_ar_id == biu_ar_id@1)")
  u_ovl_intf_assert_dcf80af1cd2ca858ddcc419d74522f3b444a176b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dvm_second_part_expected ),
    .consequent_expr ((biu_ar_id == biu_ar_id_reg)));



  // Assertions - biu_ar_type
  // ------------------------

  // Some sources can only generate a subset of request types.


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_id in [`CA53_RID_DCU0, `CA53_RID_DCU1, `CA53_RID_DCU2, `CA53_RID_DCU3, `CA53_RID_ICU0, `CA53_RID_ICU1, `CA53_RID_ICU2, `CA53_RID_TLB]  => biu_ar_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_READONCE]")
  u_ovl_intf_assert_3dd8c41f1b4f5ebe03d496e3904cbefd18930b16 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_id == `CA53_RID_DCU0) | (biu_ar_id ==  `CA53_RID_DCU1) | (biu_ar_id ==  `CA53_RID_DCU2) | (biu_ar_id ==  `CA53_RID_DCU3) | (biu_ar_id ==  `CA53_RID_ICU0) | (biu_ar_id ==  `CA53_RID_ICU1) | (biu_ar_id ==  `CA53_RID_ICU2) | (biu_ar_id ==  `CA53_RID_TLB)) ),
    .consequent_expr (((biu_ar_type == `CA53_REQ_READNOSNOOP) | (biu_ar_type ==  `CA53_REQ_READONCE))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_id in [`CA53_RID_LFB0, `CA53_RID_LFB1, `CA53_RID_LFB2, `CA53_RID_LFB3, `CA53_RID_LFB4, `CA53_RID_LFB5, `CA53_RID_LFB6, `CA53_RID_LFB7]  => biu_ar_type in [`CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE]")
  u_ovl_intf_assert_6864d3ee9084ea386d581dceb57be80c196092ec (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_id == `CA53_RID_LFB0) | (biu_ar_id ==  `CA53_RID_LFB1) | (biu_ar_id ==  `CA53_RID_LFB2) | (biu_ar_id ==  `CA53_RID_LFB3) | (biu_ar_id ==  `CA53_RID_LFB4) | (biu_ar_id ==  `CA53_RID_LFB5) | (biu_ar_id ==  `CA53_RID_LFB6) | (biu_ar_id ==  `CA53_RID_LFB7)) ),
    .consequent_expr (((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_id in [`CA53_RID_STB0, `CA53_RID_STB1, `CA53_RID_STB2, `CA53_RID_STB3, `CA53_RID_STB4]  => biu_ar_type in [`CA53_REQ_WRITEUNIQUE, `CA53_REQ_WRITENOSNOOP, `CA53_REQ_CLEANUNIQUE, `CA53_REQ_CLEANSHARED, `CA53_REQ_CLEANINVALID, `CA53_REQ_MAKEINVALID, `CA53_REQ_DVM, `CA53_REQ_DMB, `CA53_REQ_DSB, `CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY]")
  u_ovl_intf_assert_2b7c8f85395078f710fdc30933c5240d1053fec9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_id == `CA53_RID_STB0) | (biu_ar_id ==  `CA53_RID_STB1) | (biu_ar_id ==  `CA53_RID_STB2) | (biu_ar_id ==  `CA53_RID_STB3) | (biu_ar_id ==  `CA53_RID_STB4)) ),
    .consequent_expr (((biu_ar_type == `CA53_REQ_WRITEUNIQUE) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_CLEANUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANSHARED) | (biu_ar_type ==  `CA53_REQ_CLEANINVALID) | (biu_ar_type ==  `CA53_REQ_MAKEINVALID) | (biu_ar_type ==  `CA53_REQ_DVM) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB) | (biu_ar_type ==  `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_id in [`CA53_RID_ECC]  => biu_ar_type in [`CA53_REQ_ECCCLEAN]")
  u_ovl_intf_assert_8899f8d68c62eed35ee1da6a67b46c380446a62d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_id == `CA53_RID_ECC)) ),
    .consequent_expr (((biu_ar_type == `CA53_REQ_ECCCLEAN))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_id in [`CA53_RID_RNONE]  => biu_ar_type in [`CA53_REQ_READNONE]")
  u_ovl_intf_assert_221ae35d1cae71f010709ba74d9fa4c0ac1db268 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_id == `CA53_RID_RNONE)) ),
    .consequent_expr (((biu_ar_type == `CA53_REQ_READNONE))));



  // Assertions - biu_ar_attrs
  // -------------------------


  // One shareability value is unused, except for barriers which use it to
  // encode a full system barrier. Attributes are not valid for DVMs so no
  // checking is required.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_type in [`CA53_REQ_DVM, `CA53_REQ_DMB, `CA53_REQ_DSB])  => ~`CA53_MEM_UNUSED(biu_ar_attrs)")
  u_ovl_intf_assert_c090c7213373ae8ead6c98e035d93b57d2cdaa43 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_type == `CA53_REQ_DVM) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB))) ),
    .consequent_expr (~`CA53_MEM_UNUSED(biu_ar_attrs)));


  // All coherent requests must be to memory that is inner and outer cacheable.
  // Barriers are set to a fixed memory type, but the shareability may be varied
  // to encode the barrier's shareability.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE, `CA53_REQ_CLEANUNIQUE, `CA53_REQ_READONCE, `CA53_REQ_READNONE, `CA53_REQ_WRITEUNIQUE, `CA53_REQ_CLEANINVALID, `CA53_REQ_MAKEINVALID, `CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN, `CA53_REQ_DMB, `CA53_REQ_DSB]  => `CA53_MEM_COHERENT(biu_ar_attrs)")
  u_ovl_intf_assert_7b05a0562eda9fec09e40288cbbb9fb6552b860d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANUNIQUE) | (biu_ar_type ==  `CA53_REQ_READONCE) | (biu_ar_type ==  `CA53_REQ_READNONE) | (biu_ar_type ==  `CA53_REQ_WRITEUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANINVALID) | (biu_ar_type ==  `CA53_REQ_MAKEINVALID) | (biu_ar_type ==  `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB)) ),
    .consequent_expr (`CA53_MEM_COHERENT(biu_ar_attrs)));


  // All non-coherent requests must be to memory that is not cached.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_WRITENOSNOOP]  => ~`CA53_MEM_COHERENT(biu_ar_attrs)")
  u_ovl_intf_assert_9281584aa66663ec6219a47ebd7a8de46fbf0a7a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READNOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP)) ),
    .consequent_expr (~`CA53_MEM_COHERENT(biu_ar_attrs)));


  // Bursts that cross a cache line boundary must be wrapping bursts, and so must be cacheable.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011)  => (`CA53_MEM_WB(biu_ar_attrs) | `CA53_MEM_WT(biu_ar_attrs))")
  u_ovl_intf_assert_671cf800bea76bf9db3729e185ac5809eaa34960 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011) ),
    .consequent_expr ((`CA53_MEM_WB(biu_ar_attrs) | `CA53_MEM_WT(biu_ar_attrs))));


  // CP15 cleans encode in the memory type if the op is to the PoU (NC) or PoC (cacheable).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_type == `CA53_REQ_CLEANSHARED)  => (`CA53_MEM_OUTER_WB(biu_ar_attrs) | `CA53_MEM_OUTER_NC(biu_ar_attrs))")
  u_ovl_intf_assert_d2b64ac166697540211afe9922428f0783299757 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_type == `CA53_REQ_CLEANSHARED) ),
    .consequent_expr ((`CA53_MEM_OUTER_WB(biu_ar_attrs) | `CA53_MEM_OUTER_NC(biu_ar_attrs))));



  // Assertions - biu_ar_way
  // -----------------------

  // Some request types must specify the exact L1 way to access.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE, `CA53_REQ_CLEANUNIQUE]  => biu_ar_way in [5'b10001, 5'b10010, 5'b10100, 5'b11000]")
  u_ovl_intf_assert_d8932982bde4be676ff411ea6a3982fe11c29857 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANUNIQUE)) ),
    .consequent_expr (((biu_ar_way == 5'b10001) | (biu_ar_way ==  5'b10010) | (biu_ar_way ==  5'b10100) | (biu_ar_way ==  5'b11000))));



  // Other coherent accesses must specify all ways as they do not know which way
  // is relevant.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READONCE, `CA53_REQ_READNONE, `CA53_REQ_CLEANSHARED, `CA53_REQ_CLEANINVALID, `CA53_REQ_MAKEINVALID]  => biu_ar_way == 5'b11111")
  u_ovl_intf_assert_02e03c493cc97063b7bf9fe58522eaac1b6f62ea (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READONCE) | (biu_ar_type ==  `CA53_REQ_READNONE) | (biu_ar_type ==  `CA53_REQ_CLEANSHARED) | (biu_ar_type ==  `CA53_REQ_CLEANINVALID) | (biu_ar_type ==  `CA53_REQ_MAKEINVALID)) ),
    .consequent_expr (biu_ar_way == 5'b11111));


  // All requests that do not need to look up in any cache on their initial pass
  // must specify no ways.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_WRITENOSNOOP, `CA53_REQ_WRITEUNIQUE, `CA53_REQ_DMB, `CA53_REQ_DSB, `CA53_REQ_DVM, `CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN]  => biu_ar_way == 5'b00000")
  u_ovl_intf_assert_11583a08f3f18aafa53fef3f11ab5cb8e1121b5c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READNOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITEUNIQUE) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB) | (biu_ar_type ==  `CA53_REQ_DVM) | (biu_ar_type ==  `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN)) ),
    .consequent_expr (biu_ar_way == 5'b00000));


  // Assertions - biu_ar_addr
  // ------------------------

  // A barrier transaction should have a fixed address

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_type in [`CA53_REQ_DMB, `CA53_REQ_DSB])  => biu_ar_addr == {41{1'b0}}")
  u_ovl_intf_assert_c9a1dbdc3725e9cc16720455a72491fff436262e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (((biu_ar_type == `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB))) ),
    .consequent_expr (biu_ar_addr == {41{1'b0}}));



  // Read accesses to device memory, and exclusives, must be aligned to the access size.
  assign strict_alignment  = biu_ar_valid & (biu_ar_type == `CA53_REQ_READNOSNOOP) & (`CA53_MEM_DEVICE(biu_ar_attrs) | biu_ar_lock);


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_16BIT)   => biu_ar_addr[0]   == 1'b0")
  u_ovl_intf_assert_6dad5b6c23e0b8267d8c2468e5adf02b3b54cefa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_16BIT)  ),
    .consequent_expr (biu_ar_addr[0]   == 1'b0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_32BIT)   => biu_ar_addr[1:0] == 2'b00")
  u_ovl_intf_assert_4865d8ec0ad6d6f13c28ca34f597c04a14ddfb22 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_32BIT)  ),
    .consequent_expr (biu_ar_addr[1:0] == 2'b00));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_64BIT)   => biu_ar_addr[2:0] == 3'b000")
  u_ovl_intf_assert_fe9ff5f001aec0ef86c7231ec49da7a704a0b9bd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_64BIT)  ),
    .consequent_expr (biu_ar_addr[2:0] == 3'b000));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_128BIT)  => biu_ar_addr[3:0] == 4'b0000")
  u_ovl_intf_assert_2e2b4311af880b337eb8b3f308b8916265da7df8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (strict_alignment & (biu_ar_size == `CA53_ACE_SIZE_128BIT) ),
    .consequent_expr (biu_ar_addr[3:0] == 4'b0000));


  // Writes must be aligned to the bus size.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_WRITENOSNOOP, `CA53_REQ_WRITEUNIQUE]  => biu_ar_addr[3:0] == 4'b0000")
  u_ovl_intf_assert_6db95e520297afc3fb620c0e507d12f81dabf585 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITEUNIQUE)) ),
    .consequent_expr (biu_ar_addr[3:0] == 4'b0000));


  // Bursts that cross a cache line boundary must be wrapping bursts, and so must be aligned.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_type in [`CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN, `CA53_REQ_DMB, `CA53_REQ_DSB, `CA53_REQ_DVM]) & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011)  => biu_ar_addr[3:0] == 4'b0000")
  u_ovl_intf_assert_c172bae57bd89a5be65d4de766ecb13eddfd3f37 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_type == `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB) | (biu_ar_type ==  `CA53_REQ_DVM))) & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011) ),
    .consequent_expr (biu_ar_addr[3:0] == 4'b0000));


  // All transfers of more than one beat must be aligned, except for the CLEANSETWAY, CLEANINVSETWAY and ECCCLEAN ops

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_len != 2'b00) & ~(biu_ar_type in [`CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN])  => biu_ar_addr[3:0] == 4'b0000")
  u_ovl_intf_assert_d8e722022d18d7e4117d3613bde1c4c2bfc46dae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_len != 2'b00) & ~(((biu_ar_type == `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN))) ),
    .consequent_expr (biu_ar_addr[3:0] == 4'b0000));


  // The set/way ops (including ECC clean) put the set in bits [n:6] of the
  // address, where n is between 8 and 16 depending on the cache size.

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

  assign first_dvm_req   = biu_ar_valid & (biu_ar_type == `CA53_REQ_DVM) & ~dvm_second_part_expected;
  assign second_dvm_req  = biu_ar_valid & (biu_ar_type == `CA53_REQ_DVM) &  dvm_second_part_expected;

  // Message types indicate if the request has to be sent to all CPUs or just
  // the requestor, as well as the type of operation.


  // Not all message type encodings are valid.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req  => biu_ar_addr[14:12] in [`CA53_DVM_TLBINVIS, `CA53_DVM_BPINVIS, `CA53_DVM_ICPINVIS, `CA53_DVM_ICVINVIS, `CA53_DVM_SYNC, `CA53_DVM_TLBINV, `CA53_DVM_ICINV]")
  u_ovl_intf_assert_fa4e0a2786584339ebe6e31ddb57e315d1a784b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req ),
    .consequent_expr (((biu_ar_addr[14:12] == `CA53_DVM_TLBINVIS) | (biu_ar_addr[14:12] ==  `CA53_DVM_BPINVIS) | (biu_ar_addr[14:12] ==  `CA53_DVM_ICPINVIS) | (biu_ar_addr[14:12] ==  `CA53_DVM_ICVINVIS) | (biu_ar_addr[14:12] ==  `CA53_DVM_SYNC) | (biu_ar_addr[14:12] ==  `CA53_DVM_TLBINV) | (biu_ar_addr[14:12] ==  `CA53_DVM_ICINV))));



  // Concatenate the various bits specifying the type of request into a single signal.
  assign dvm_request_type  = {biu_ar_addr[11:10], biu_ar_addr[9:8], biu_ar_addr[6], biu_ar_addr[5], biu_ar_addr[4], biu_ar_addr[3:2], biu_ar_addr[0]};

  // The valid request type encodings depend on the request type

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] in [`CA53_DVM_TLBINVIS, `CA53_DVM_TLBINV])  => dvm_request_type in [10'b01_10_0_0_0_00_0,    10'b01_10_0_0_0_00_1,    10'b01_10_0_0_1_00_1,    10'b10_10_0_0_0_00_0,    10'b10_10_0_0_0_00_1,    10'b10_10_0_0_1_00_1,    10'b10_10_0_1_0_00_0,    10'b10_10_0_1_0_00_1,    10'b10_10_0_1_1_00_1,    10'b10_11_0_0_0_00_0,    10'b10_11_1_0_0_00_0,    10'b10_11_1_0_0_00_1,    10'b10_11_1_0_1_00_1,    10'b10_11_1_1_0_00_0,    10'b10_11_1_1_0_00_1,    10'b10_11_1_1_1_00_1,    10'b10_11_1_0_0_01_0,    10'b10_11_1_0_0_10_1,    10'b10_11_1_0_1_10_1,    10'b11_11_0_0_0_00_0,    10'b11_11_0_0_0_00_1,    10'b11_11_0_0_1_00_1]")
  u_ovl_intf_assert_387d4412f90a1aa68f7630767cb17e16b0ffb3f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (((biu_ar_addr[14:12] == `CA53_DVM_TLBINVIS) | (biu_ar_addr[14:12] ==  `CA53_DVM_TLBINV))) ),
    .consequent_expr (((dvm_request_type == 10'b01_10_0_0_0_00_0) | (dvm_request_type ==     10'b01_10_0_0_0_00_1) | (dvm_request_type ==     10'b01_10_0_0_1_00_1) | (dvm_request_type ==     10'b10_10_0_0_0_00_0) | (dvm_request_type ==     10'b10_10_0_0_0_00_1) | (dvm_request_type ==     10'b10_10_0_0_1_00_1) | (dvm_request_type ==     10'b10_10_0_1_0_00_0) | (dvm_request_type ==     10'b10_10_0_1_0_00_1) | (dvm_request_type ==     10'b10_10_0_1_1_00_1) | (dvm_request_type ==     10'b10_11_0_0_0_00_0) | (dvm_request_type ==     10'b10_11_1_0_0_00_0) | (dvm_request_type ==     10'b10_11_1_0_0_00_1) | (dvm_request_type ==     10'b10_11_1_0_1_00_1) | (dvm_request_type ==     10'b10_11_1_1_0_00_0) | (dvm_request_type ==     10'b10_11_1_1_0_00_1) | (dvm_request_type ==     10'b10_11_1_1_1_00_1) | (dvm_request_type ==     10'b10_11_1_0_0_01_0) | (dvm_request_type ==     10'b10_11_1_0_0_10_1) | (dvm_request_type ==     10'b10_11_1_0_1_10_1) | (dvm_request_type ==     10'b11_11_0_0_0_00_0) | (dvm_request_type ==     10'b11_11_0_0_0_00_1) | (dvm_request_type ==     10'b11_11_0_0_1_00_1))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] == `CA53_DVM_BPINVIS)  => dvm_request_type in [10'b00_00_0_0_0_00_0,    10'b00_00_0_0_0_00_1]")
  u_ovl_intf_assert_1248ba76817904b3df86f6b0d86aaf9081fde299 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (biu_ar_addr[14:12] == `CA53_DVM_BPINVIS) ),
    .consequent_expr (((dvm_request_type == 10'b00_00_0_0_0_00_0) | (dvm_request_type ==     10'b00_00_0_0_0_00_1))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] in [`CA53_DVM_ICPINVIS])  => dvm_request_type in [10'b00_10_1_1_0_00_1,    10'b00_11_1_1_0_00_1]")
  u_ovl_intf_assert_800808add0f6cf8e859e425544c640a00d6b6c42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (((biu_ar_addr[14:12] == `CA53_DVM_ICPINVIS))) ),
    .consequent_expr (((dvm_request_type == 10'b00_10_1_1_0_00_1) | (dvm_request_type ==     10'b00_11_1_1_0_00_1))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] in [`CA53_DVM_ICVINVIS])  => dvm_request_type in [10'b00_00_0_0_0_00_0,    10'b00_11_0_0_0_00_0]")
  u_ovl_intf_assert_dbde3fb82b945b552ede507cefc5a6babf441d1d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (((biu_ar_addr[14:12] == `CA53_DVM_ICVINVIS))) ),
    .consequent_expr (((dvm_request_type == 10'b00_00_0_0_0_00_0) | (dvm_request_type ==     10'b00_11_0_0_0_00_0))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] in [`CA53_DVM_ICINV])  => dvm_request_type in [10'b00_00_0_0_0_00_0,    10'b00_10_1_1_0_00_1,    10'b00_11_0_0_0_00_0,    10'b00_11_1_1_0_00_1]")
  u_ovl_intf_assert_b0652c833283e65dd4d4b2c8cc60816437a3e7d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (((biu_ar_addr[14:12] == `CA53_DVM_ICINV))) ),
    .consequent_expr (((dvm_request_type == 10'b00_00_0_0_0_00_0) | (dvm_request_type ==     10'b00_10_1_1_0_00_1) | (dvm_request_type ==     10'b00_11_0_0_0_00_0) | (dvm_request_type ==     10'b00_11_1_1_0_00_1))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & (biu_ar_addr[14:12] == `CA53_DVM_SYNC)  => dvm_request_type == 10'b00_00_0_0_0_00_0")
  u_ovl_intf_assert_1f63e7cc5f2716e7a38ff34ddd948ff53fbd660a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & (biu_ar_addr[14:12] == `CA53_DVM_SYNC) ),
    .consequent_expr (dvm_request_type == 10'b00_00_0_0_0_00_0));


  // If the ASID is not valid it must be driven to zero

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & ~biu_ar_addr[5]  => ~|{biu_ar_addr[39:32], biu_ar_addr[23:16]}")
  u_ovl_intf_assert_6fdf22fa6597337d4a394e14672d5c60ad4bb0fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & ~biu_ar_addr[5] ),
    .consequent_expr (~|{biu_ar_addr[39:32], biu_ar_addr[23:16]}));


  // If the VMID is not valid it must be driven to zero

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "first_dvm_req & ~biu_ar_addr[6]  => ~|biu_ar_addr[31:24]")
  u_ovl_intf_assert_31f716c2b3495d1c399cb02fa6fb192ddc00ca47 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (first_dvm_req & ~biu_ar_addr[6] ),
    .consequent_expr (~|biu_ar_addr[31:24]));



  // Assertions - biu_ar_wrap
  // ------------------------

  // Wrap can be implicity calculated from the transaction.
  assign biu_ar_wrap  = (((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type == `CA53_REQ_READUNIQUE) | (biu_ar_type == `CA53_REQ_READONCE) | (biu_ar_type == `CA53_REQ_READNONE) | ((biu_ar_type == `CA53_REQ_READNOSNOOP) & (`CA53_MEM_WB(biu_ar_attrs) | `CA53_MEM_WT(biu_ar_attrs)))) & (&biu_ar_len));

  // DSide linefills must be wrapping. ISide linefills may be wrapping or
  // incrementing. Everything else must be incrementing.


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE]  => biu_ar_wrap")
  u_ovl_intf_assert_9075a6e17aeefa8409a88ca02b77bf2f577d1f91 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE)) ),
    .consequent_expr (biu_ar_wrap));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_type in [`CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE, `CA53_REQ_READONCE, `CA53_REQ_READNONE, `CA53_REQ_READNOSNOOP])  => ~biu_ar_wrap")
  u_ovl_intf_assert_4240ca1c01c9d47b68c3cdab7a96b55406d433fd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_type == `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE) | (biu_ar_type ==  `CA53_REQ_READONCE) | (biu_ar_type ==  `CA53_REQ_READNONE) | (biu_ar_type ==  `CA53_REQ_READNOSNOOP))) ),
    .consequent_expr (~biu_ar_wrap));



  // Assertions - biu_ar_len
  // -----------------------

  // Most coherent transactions must be a full cacheline.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_READONCE, `CA53_REQ_READNONE, `CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE, `CA53_REQ_CLEANUNIQUE, `CA53_REQ_CLEANSHARED, `CA53_REQ_CLEANINVALID, `CA53_REQ_MAKEINVALID, `CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN]  => biu_ar_len == 2'b11")
  u_ovl_intf_assert_780d25ba97c32ae34620953ceb98df4632b5211a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_READONCE) | (biu_ar_type ==  `CA53_REQ_READNONE) | (biu_ar_type ==  `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_READUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANUNIQUE) | (biu_ar_type ==  `CA53_REQ_CLEANSHARED) | (biu_ar_type ==  `CA53_REQ_CLEANINVALID) | (biu_ar_type ==  `CA53_REQ_MAKEINVALID) | (biu_ar_type ==  `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN)) ),
    .consequent_expr (biu_ar_len == 2'b11));


  // Wrapping bursts must always be a full cache line.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_wrap  => biu_ar_len == 2'b11")
  u_ovl_intf_assert_8032e5a759abc6530b17954c77001bc9c29a8f98 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & biu_ar_wrap ),
    .consequent_expr (biu_ar_len == 2'b11));


  // Bursts that cross a cache line boundary must be wrapping bursts, and so must be a full cache line.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011)  => biu_ar_len == 2'b11")
  u_ovl_intf_assert_096b946e96bfc99404c937a4109da6747b322b71 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_addr[5:4] + biu_ar_len) > 3'b011) ),
    .consequent_expr (biu_ar_len == 2'b11));


  // Some requests cannot have multiple beats (writes work out the length from
  // the number of data beats sent later).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_type in [`CA53_REQ_DMB, `CA53_REQ_DSB, `CA53_REQ_DVM, `CA53_REQ_WRITENOSNOOP, `CA53_REQ_WRITEUNIQUE]  => biu_ar_len == 2'b00")
  u_ovl_intf_assert_92dba3a0a75e49ddc4f636e3744d550ed12b649e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ((biu_ar_type == `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB) | (biu_ar_type ==  `CA53_REQ_DVM) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITEUNIQUE)) ),
    .consequent_expr (biu_ar_len == 2'b00));


  // Incrementing bursts should never cross a 64 byte boundary except for the D-cache set-way maintenance ops.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~biu_ar_wrap & ~(biu_ar_type in [`CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY])  => (biu_ar_addr[5:0] + {biu_ar_len, 4'b0000}) < 7'b100_0000")
  u_ovl_intf_assert_d583b3a95429b0f0b1b5f1991c1a481e8196acfa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~biu_ar_wrap & ~(((biu_ar_type == `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY))) ),
    .consequent_expr ((biu_ar_addr[5:0] + {biu_ar_len, 4'b0000}) < 7'b100_0000));


  // Non-coherent exclusive accesses must be a single beat.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_lock & ~(biu_ar_type in [`CA53_REQ_CLEANUNIQUE, `CA53_REQ_READSHARED])  => biu_ar_len == 2'b00")
  u_ovl_intf_assert_02a8fb606846816b6d6e94bf401fe9c9e1e2a3ba (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & biu_ar_lock & ~(((biu_ar_type == `CA53_REQ_CLEANUNIQUE) | (biu_ar_type ==  `CA53_REQ_READSHARED))) ),
    .consequent_expr (biu_ar_len == 2'b00));


  // Bursts should never be three beats.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid  => biu_ar_len != 2'b10")
  u_ovl_intf_assert_5a8438a0e61d364fb3c7a5bde1e68dc46f422692 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid ),
    .consequent_expr (biu_ar_len != 2'b10));


  // Incrementing bursts cannot cross a halfline boundary unless they are reading the full line.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~biu_ar_wrap & (biu_ar_addr[5:4] == 2'b01)& ~(biu_ar_type in [`CA53_REQ_CLEANSETWAY, `CA53_REQ_CLEANINVSETWAY, `CA53_REQ_ECCCLEAN])  => biu_ar_len == 2'b00")
  u_ovl_intf_assert_7a6b045ed6e5cc045c8d1b1d685ce8051379b967 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~biu_ar_wrap & (biu_ar_addr[5:4] == 2'b01)& ~(((biu_ar_type == `CA53_REQ_CLEANSETWAY) | (biu_ar_type ==  `CA53_REQ_CLEANINVSETWAY) | (biu_ar_type ==  `CA53_REQ_ECCCLEAN))) ),
    .consequent_expr (biu_ar_len == 2'b00));



  // Assertions - biu_ar_size
  // ------------------------

  // The size of each transfer is always 128 bits or less.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid  => biu_ar_size in [`CA53_ACE_SIZE_8BIT, `CA53_ACE_SIZE_16BIT, `CA53_ACE_SIZE_32BIT, `CA53_ACE_SIZE_64BIT, `CA53_ACE_SIZE_128BIT]")
  u_ovl_intf_assert_5ba906ecd22963dbe4717d5005211c340b2339e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid ),
    .consequent_expr (((biu_ar_size == `CA53_ACE_SIZE_8BIT) | (biu_ar_size ==  `CA53_ACE_SIZE_16BIT) | (biu_ar_size ==  `CA53_ACE_SIZE_32BIT) | (biu_ar_size ==  `CA53_ACE_SIZE_64BIT) | (biu_ar_size ==  `CA53_ACE_SIZE_128BIT))));


  // All coherent accesses, and all writes, must be 128 bits.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_type != `CA53_REQ_READNOSNOOP)  => biu_ar_size == `CA53_ACE_SIZE_128BIT")
  u_ovl_intf_assert_cba3aab83bdbcbd23c9d49883ac093e8b80e0aa4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_type != `CA53_REQ_READNOSNOOP) ),
    .consequent_expr (biu_ar_size == `CA53_ACE_SIZE_128BIT));


  // All linefills must be 128 bits.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & biu_ar_wrap  => biu_ar_size == `CA53_ACE_SIZE_128BIT")
  u_ovl_intf_assert_104fe79205102b19f81a728998b33e967e6441e3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & biu_ar_wrap ),
    .consequent_expr (biu_ar_size == `CA53_ACE_SIZE_128BIT));


  // All transfers of more than one beat must be 128 bits.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_len != 2'b00)  => biu_ar_size == `CA53_ACE_SIZE_128BIT")
  u_ovl_intf_assert_e95fe0dc91b6630d924d3d6d40714bbad5d49f1b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_len != 2'b00) ),
    .consequent_expr (biu_ar_size == `CA53_ACE_SIZE_128BIT));



  // Assertions - biu_ar_lock
  // ------------------------

  // The only coherent accesses that may be exclusive are ReadShared and CleanUnique.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_WRITENOSNOOP, `CA53_REQ_READSHARED, `CA53_REQ_CLEANUNIQUE])  => ~biu_ar_lock")
  u_ovl_intf_assert_8621a437bbcd4ba8af5c3bbf6a4a3735e4876d09 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_type == `CA53_REQ_READNOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_READSHARED) | (biu_ar_type ==  `CA53_REQ_CLEANUNIQUE))) ),
    .consequent_expr (~biu_ar_lock));


  // Only some request sources can generate exclusives.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_id in [`CA53_RID_DCU0, `CA53_RID_DCU1, `CA53_RID_DCU2, `CA53_RID_DCU3, `CA53_RID_LFB0, `CA53_RID_LFB1, `CA53_RID_LFB2, `CA53_RID_LFB3, `CA53_RID_LFB4, `CA53_RID_LFB5, `CA53_RID_LFB6, `CA53_RID_LFB7, `CA53_RID_STB0, `CA53_RID_STB1, `CA53_RID_STB2, `CA53_RID_STB3, `CA53_RID_STB4])  => ~biu_ar_lock")
  u_ovl_intf_assert_670f081b950758ae81cc135f5cbe50fa22d2279a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_id == `CA53_RID_DCU0) | (biu_ar_id ==  `CA53_RID_DCU1) | (biu_ar_id ==  `CA53_RID_DCU2) | (biu_ar_id ==  `CA53_RID_DCU3) | (biu_ar_id ==  `CA53_RID_LFB0) | (biu_ar_id ==  `CA53_RID_LFB1) | (biu_ar_id ==  `CA53_RID_LFB2) | (biu_ar_id ==  `CA53_RID_LFB3) | (biu_ar_id ==  `CA53_RID_LFB4) | (biu_ar_id ==  `CA53_RID_LFB5) | (biu_ar_id ==  `CA53_RID_LFB6) | (biu_ar_id ==  `CA53_RID_LFB7) | (biu_ar_id ==  `CA53_RID_STB0) | (biu_ar_id ==  `CA53_RID_STB1) | (biu_ar_id ==  `CA53_RID_STB2) | (biu_ar_id ==  `CA53_RID_STB3) | (biu_ar_id ==  `CA53_RID_STB4))) ),
    .consequent_expr (~biu_ar_lock));


  assign outstanding_lock  = ((outstanding_dcu0_lock & read_dcu0_outstanding) | (outstanding_dcu1_lock & read_dcu1_outstanding) | (outstanding_dcu2_lock & read_dcu2_outstanding) | (outstanding_dcu3_lock & read_dcu3_outstanding));

  // Only one non-coherent LDREX can be outstanding at a time.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id in [`CA53_RID_DCU0, `CA53_RID_DCU1, `CA53_RID_DCU2, `CA53_RID_DCU3]) & outstanding_lock  => ~biu_ar_lock")
  u_ovl_intf_assert_b1a2aade5f4aae43c2d3983a2e71334a15ff0fb8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (((biu_ar_id == `CA53_RID_DCU0) | (biu_ar_id ==  `CA53_RID_DCU1) | (biu_ar_id ==  `CA53_RID_DCU2) | (biu_ar_id ==  `CA53_RID_DCU3))) & outstanding_lock ),
    .consequent_expr (~biu_ar_lock));


  // Assertions - biu_ar_priv
  // ------------------------

  // Cacheable accesses should always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & ~(biu_ar_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_WRITENOSNOOP, `CA53_REQ_DMB, `CA53_REQ_DSB, `CA53_REQ_DVM])  => biu_ar_priv")
  u_ovl_intf_assert_322880ff5cce899fe3a3053f4a1f616d44403361 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & ~(((biu_ar_type == `CA53_REQ_READNOSNOOP) | (biu_ar_type ==  `CA53_REQ_WRITENOSNOOP) | (biu_ar_type ==  `CA53_REQ_DMB) | (biu_ar_type ==  `CA53_REQ_DSB) | (biu_ar_type ==  `CA53_REQ_DVM))) ),
    .consequent_expr (biu_ar_priv));


  // Mergeable non-exlusive writes should always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_type == `CA53_REQ_WRITENOSNOOP) & `CA53_MEM_MERGEABLE(biu_ar_attrs) & ~biu_ar_lock  => biu_ar_priv")
  u_ovl_intf_assert_0302d5ed41108cfe709da1d30c170a8889fb2b7c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_type == `CA53_REQ_WRITENOSNOOP) & `CA53_MEM_MERGEABLE(biu_ar_attrs) & ~biu_ar_lock ),
    .consequent_expr (biu_ar_priv));


  // TLB pagewalks should always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_TLB)  => biu_ar_priv")
  u_ovl_intf_assert_489ed4d0038088eae6a78e985ad0024898e4e9f4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_TLB) ),
    .consequent_expr (biu_ar_priv));


  // ECC evictions should always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_ECC)  => biu_ar_priv")
  u_ovl_intf_assert_d49fdce2ed3cca68c68d0b874e92725fbac7944f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_ECC) ),
    .consequent_expr (biu_ar_priv));


  // ReadNone requests should always be marked as privileged.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_id == `CA53_RID_RNONE)  => biu_ar_priv")
  u_ovl_intf_assert_c395aa34d4349e90e645014f0d8b1a0b0dea7c12 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_id == `CA53_RID_RNONE) ),
    .consequent_expr (biu_ar_priv));






  //----------------------------------------------------------------------------
  // Read data and address response channel
  //----------------------------------------------------------------------------

  // The BIU has space to accept new read data.
  //  output biu_dr_credit valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_dr_credit X or Z")
  u_ovl_intf_x_biu_dr_credit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_dr_credit));


  // The SCU is supplying new read data this cycle.
  //  input scu_dr_valid valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_dr_valid X or Z")
  u_ovl_intf_x_scu_dr_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_dr_valid));


  // The ID the data relates to.
  //  input [4:0] scu_dr_id valid scu_dr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "scu_dr_id X or Z")
  u_ovl_intf_x_scu_dr_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_dr_valid),
    .test_expr (scu_dr_id));


  // The response.
  // Bits [1:0] are the status (OK, EXOK, SLVERR, DECERR).
  // Bit [2] is PassDirty
  // Bit [3] is IsShared
  // Bit [4] is ECC error
  // Bit [5] is the 'age' of the line (0 if the line came from outside the cluster, 1 from inside)
  //  input [5:0] scu_dr_resp valid scu_dr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 6, INOPTIONS, "scu_dr_resp X or Z")
  u_ovl_intf_x_scu_dr_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_dr_valid),
    .test_expr (scu_dr_resp));


  // The chunk within the burst, i.e. bits [5:4] of the address.
  //  input [1:0] scu_dr_chunk valid scu_dr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "scu_dr_chunk X or Z")
  u_ovl_intf_x_scu_dr_chunk (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_dr_valid),
    .test_expr (scu_dr_chunk));


  // The read data.
  //  input [127:0] scu_dr_data valid scu_dr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 128, INOPTIONS, "scu_dr_data X or Z")
  u_ovl_intf_x_scu_dr_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_dr_valid),
    .test_expr (scu_dr_data));



  // The SCU is supplying a new response without data this cycle.
  //  input scu_rr_valid valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_rr_valid X or Z")
  u_ovl_intf_x_scu_rr_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_rr_valid));


  // The ID the response relates to.
  //  input [4:0] scu_rr_id valid scu_rr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "scu_rr_id X or Z")
  u_ovl_intf_x_scu_rr_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_rr_valid),
    .test_expr (scu_rr_id));


  // The response (OK, EXOK, SLVERR, DECERR).
  //  input [1:0] scu_rr_resp valid scu_rr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "scu_rr_resp X or Z")
  u_ovl_intf_x_scu_rr_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_rr_valid),
    .test_expr (scu_rr_resp));


  // The L2 data buffer that is allocated for this access, if this is a write.
  //  input [3:0] scu_rr_l2db_id valid scu_rr_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "scu_rr_l2db_id X or Z")
  u_ovl_intf_x_scu_rr_l2db_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_rr_valid),
    .test_expr (scu_rr_l2db_id));



  // The eviction for a ReadShared/ReadUnique has been done or is not required.
  // There is one bit per LFB ID, which will be asserted for a single cycle.
  // The BIU must not start a new request on that ID until the eviction has
  // been done.
  //  input [7:0] scu_ev_done valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "scu_ev_done X or Z")
  u_ovl_intf_x_scu_ev_done (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ev_done));



  // Assertions - handshake
  // ----------------------

  // There are a total of 4 credits, and on reset the SCU holds them all.
  // Every time the SCU sends a data beat, it uses a credit. When all credits
  // are used, it must not send any more data. The BIU will return credits when
  // it has freed up a read buffer.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dr_credits_used <= 3'b000;
  else
    dr_credits_used <= dr_credits_used + {2'b00, scu_dr_valid} - {2'b00, biu_dr_credit};


  // Only 4 credits may be used.

  assert_always #(`OVL_FATAL, INOPTIONS, "dr_credits_used <= 3'b100")
  u_ovl_intf_assume_6310dd7bf404a4a6f72d199871017a136b91df59 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (dr_credits_used <= 3'b100));


  // When all credits are used, no new data beats may be sent.

  assert_implication #(`OVL_FATAL, INOPTIONS, "dr_credits_used == 3'b100  => ~scu_dr_valid")
  u_ovl_intf_assume_0fd72d268d316418ae00af7e71467ef5c96688af (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dr_credits_used == 3'b100 ),
    .consequent_expr (~scu_dr_valid));


  // The BIU must only return credits that it received.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "dr_credits_used == 3'b000  => ~biu_dr_credit")
  u_ovl_intf_assert_3a3b033ec569ddc750906cda70beb4a5252fee32 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dr_credits_used == 3'b000 ),
    .consequent_expr (~biu_dr_credit));



  // Assertions - scu_dr_id
  // ----------------------

  // A valid ID must be used.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid  => scu_dr_id in [`CA53_RID_DCU0, `CA53_RID_DCU1, `CA53_RID_DCU2, `CA53_RID_DCU3, `CA53_RID_LFB0, `CA53_RID_LFB1, `CA53_RID_LFB2, `CA53_RID_LFB3, `CA53_RID_LFB4, `CA53_RID_LFB5, `CA53_RID_LFB6, `CA53_RID_LFB7, `CA53_RID_TLB, `CA53_RID_ICU0, `CA53_RID_ICU1, `CA53_RID_ICU2]")
  u_ovl_intf_assume_2e9e7b01ab83a16f904ee086175a4eb2ae7e46a0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid ),
    .consequent_expr (((scu_dr_id == `CA53_RID_DCU0) | (scu_dr_id ==  `CA53_RID_DCU1) | (scu_dr_id ==  `CA53_RID_DCU2) | (scu_dr_id ==  `CA53_RID_DCU3) | (scu_dr_id ==  `CA53_RID_LFB0) | (scu_dr_id ==  `CA53_RID_LFB1) | (scu_dr_id ==  `CA53_RID_LFB2) | (scu_dr_id ==  `CA53_RID_LFB3) | (scu_dr_id ==  `CA53_RID_LFB4) | (scu_dr_id ==  `CA53_RID_LFB5) | (scu_dr_id ==  `CA53_RID_LFB6) | (scu_dr_id ==  `CA53_RID_LFB7) | (scu_dr_id ==  `CA53_RID_TLB) | (scu_dr_id ==  `CA53_RID_ICU0) | (scu_dr_id ==  `CA53_RID_ICU1) | (scu_dr_id ==  `CA53_RID_ICU2))));


  // A response must only be returned if there is an outstanding request on that ID.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_DCU0)  => read_dcu0_outstanding")
  u_ovl_intf_assume_48f92c9e7b2b9628a7412d9947548e77b05f6996 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_DCU0) ),
    .consequent_expr (read_dcu0_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_DCU1)  => read_dcu1_outstanding")
  u_ovl_intf_assume_41e9a048a6d23b2d535f5fc3f6a44149a90796f1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_DCU1) ),
    .consequent_expr (read_dcu1_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_DCU2)  => read_dcu2_outstanding")
  u_ovl_intf_assume_7405ae806f72211bb3f1dbc311894b4a566d4027 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_DCU2) ),
    .consequent_expr (read_dcu2_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_DCU3)  => read_dcu3_outstanding")
  u_ovl_intf_assume_94c2d1a65ac68092c6ba78ed11184cf60eb794c2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_DCU3) ),
    .consequent_expr (read_dcu3_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0)  => read_lfb0_outstanding")
  u_ovl_intf_assume_c95348f6503773b3ff7f868b572d3870064476ab (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) ),
    .consequent_expr (read_lfb0_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1)  => read_lfb1_outstanding")
  u_ovl_intf_assume_d8a9c4459c1b94a3d704375fdb9cdf0863a2d3c1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) ),
    .consequent_expr (read_lfb1_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2)  => read_lfb2_outstanding")
  u_ovl_intf_assume_4517c7344d12b29ee78e6143c6eb9be00767f350 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) ),
    .consequent_expr (read_lfb2_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3)  => read_lfb3_outstanding")
  u_ovl_intf_assume_8156ba5060a3f049a92924519d7a2421ffec020f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) ),
    .consequent_expr (read_lfb3_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4)  => read_lfb4_outstanding")
  u_ovl_intf_assume_1f66d36147670a5d2e6ef0e42118fd7fe9e870ad (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) ),
    .consequent_expr (read_lfb4_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5)  => read_lfb5_outstanding")
  u_ovl_intf_assume_e89d4c04a77f79096b01b154c167143334ff8329 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) ),
    .consequent_expr (read_lfb5_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6)  => read_lfb6_outstanding")
  u_ovl_intf_assume_59f5caefbb6065cc11ab449c761782fb47d55f23 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) ),
    .consequent_expr (read_lfb6_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7)  => read_lfb7_outstanding")
  u_ovl_intf_assume_79805c5420e7fee95b6092a8b75b100fa71ca07d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) ),
    .consequent_expr (read_lfb7_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_TLB)   => read_tlb_outstanding")
  u_ovl_intf_assume_514910d64ebb1b9a60fa1288a6b6221f3061fb37 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_TLB)  ),
    .consequent_expr (read_tlb_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_ICU0)  => read_icu0_outstanding")
  u_ovl_intf_assume_1fa6aec9e977cf822580f339ffad1e5af339e9ed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_ICU0) ),
    .consequent_expr (read_icu0_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_ICU1)  => read_icu1_outstanding")
  u_ovl_intf_assume_702b5a0812e0581cb6c84032a3f26e072f0ad18f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_ICU1) ),
    .consequent_expr (read_icu1_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_ICU2)  => read_icu2_outstanding")
  u_ovl_intf_assume_01554bda5d02ce78cad607d3f1d564f9428ebecb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_ICU2) ),
    .consequent_expr (read_icu2_outstanding));



  assign read_dcu0_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_DCU0) & ~|next_remaining_dcu0_beats;
  assign read_dcu1_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_DCU1) & ~|next_remaining_dcu1_beats;
  assign read_dcu2_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_DCU2) & ~|next_remaining_dcu2_beats;
  assign read_dcu3_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_DCU3) & ~|next_remaining_dcu3_beats;
  assign read_lfb0_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) & ~|next_remaining_lfb0_beats;
  assign read_lfb1_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) & ~|next_remaining_lfb1_beats;
  assign read_lfb2_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) & ~|next_remaining_lfb2_beats;
  assign read_lfb3_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) & ~|next_remaining_lfb3_beats;
  assign read_lfb4_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) & ~|next_remaining_lfb4_beats;
  assign read_lfb5_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) & ~|next_remaining_lfb5_beats;
  assign read_lfb6_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) & ~|next_remaining_lfb6_beats;
  assign read_lfb7_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) & ~|next_remaining_lfb7_beats;
  assign read_tlb_completed    = scu_dr_valid & (scu_dr_id == `CA53_RID_TLB)  & ~|next_remaining_tlb_beats;
  assign read_icu0_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_ICU0) & ~|next_remaining_icu0_beats;
  assign read_icu1_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_ICU1) & ~|next_remaining_icu1_beats;
  assign read_icu2_completed   = scu_dr_valid & (scu_dr_id == `CA53_RID_ICU2) & ~|next_remaining_icu2_beats;


  // Assertions - scu_dr_resp
  // ------------------------

  assign dr_type  = ((scu_dr_id == `CA53_RID_DCU0) ? outstanding_dcu0_type : (scu_dr_id == `CA53_RID_DCU1) ? outstanding_dcu1_type : (scu_dr_id == `CA53_RID_DCU2) ? outstanding_dcu2_type : (scu_dr_id == `CA53_RID_DCU3) ? outstanding_dcu3_type : (scu_dr_id == `CA53_RID_LFB0) ? outstanding_lfb0_type : (scu_dr_id == `CA53_RID_LFB1) ? outstanding_lfb1_type : (scu_dr_id == `CA53_RID_LFB2) ? outstanding_lfb2_type : (scu_dr_id == `CA53_RID_LFB3) ? outstanding_lfb3_type : (scu_dr_id == `CA53_RID_LFB4) ? outstanding_lfb4_type : (scu_dr_id == `CA53_RID_LFB5) ? outstanding_lfb5_type : (scu_dr_id == `CA53_RID_LFB6) ? outstanding_lfb6_type : (scu_dr_id == `CA53_RID_LFB7) ? outstanding_lfb7_type : (scu_dr_id == `CA53_RID_TLB)  ? outstanding_tlb_type : (scu_dr_id == `CA53_RID_ICU0) ? outstanding_icu0_type : (scu_dr_id == `CA53_RID_ICU1) ? outstanding_icu1_type : (scu_dr_id == `CA53_RID_ICU2) ? outstanding_icu2_type : `CA53_REQ_READNOSNOOP);

  assign dr_lock  = ((scu_dr_id == `CA53_RID_DCU0) ? outstanding_dcu0_lock : (scu_dr_id == `CA53_RID_DCU1) ? outstanding_dcu1_lock : (scu_dr_id == `CA53_RID_DCU2) ? outstanding_dcu2_lock : (scu_dr_id == `CA53_RID_DCU3) ? outstanding_dcu3_lock : (scu_dr_id == `CA53_RID_LFB0) ? outstanding_lfb0_lock : (scu_dr_id == `CA53_RID_LFB1) ? outstanding_lfb1_lock : (scu_dr_id == `CA53_RID_LFB2) ? outstanding_lfb2_lock : (scu_dr_id == `CA53_RID_LFB3) ? outstanding_lfb3_lock : (scu_dr_id == `CA53_RID_LFB4) ? outstanding_lfb4_lock : (scu_dr_id == `CA53_RID_LFB5) ? outstanding_lfb5_lock : (scu_dr_id == `CA53_RID_LFB6) ? outstanding_lfb6_lock : (scu_dr_id == `CA53_RID_LFB7) ? outstanding_lfb7_lock : 1'b0);

  // An exclusive response may only be returned for an exclusive request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & ~dr_lock  => (scu_dr_resp[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_EXOKAY)")
  u_ovl_intf_assume_131ba3c2262369535fd06f7b58df91d01d103480 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & ~dr_lock ),
    .consequent_expr ((scu_dr_resp[`CA53_ACE_RRESP_RESP_B] != `CA53_RESP_EXOKAY)));


  // The IsShared response must not be asserted for some transaction types.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & dr_type in [`CA53_REQ_READNOSNOOP, `CA53_REQ_READUNIQUE] & scu_dr_resp[`CA53_ACE_RRESP_RESP_B] in [`CA53_RESP_OKAY, `CA53_RESP_EXOKAY]  => ~scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B]")
  u_ovl_intf_assume_6612ddb558deb1d6987144fa3f8988a4fc5a5ddb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & ((dr_type == `CA53_REQ_READNOSNOOP) | (dr_type ==  `CA53_REQ_READUNIQUE)) & ((scu_dr_resp[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_OKAY) | (scu_dr_resp[`CA53_ACE_RRESP_RESP_B] ==  `CA53_RESP_EXOKAY)) ),
    .consequent_expr (~scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B]));


  // The PassDirty response must not be asserted for some transaction types.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & dr_type in [`CA53_REQ_READNOSNOOP] & scu_dr_resp[`CA53_ACE_RRESP_RESP_B] in [`CA53_RESP_OKAY, `CA53_RESP_EXOKAY]  => ~scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_ece5fc0a1f1370918547075a4058b1e1e271d69c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & ((dr_type == `CA53_REQ_READNOSNOOP)) & ((scu_dr_resp[`CA53_ACE_RRESP_RESP_B] == `CA53_RESP_OKAY) | (scu_dr_resp[`CA53_ACE_RRESP_RESP_B] ==  `CA53_RESP_EXOKAY)) ),
    .consequent_expr (~scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  // The ECC error bit can only be asserted for transactions that can hit in other caches.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & ~(dr_type in [`CA53_REQ_READONCE, `CA53_REQ_READSHARED, `CA53_REQ_READUNIQUE])  => ~scu_dr_resp[4]")
  u_ovl_intf_assume_e9e8dc7973956538a0c61220a92cb32d6f0697d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & ~(((dr_type == `CA53_REQ_READONCE) | (dr_type ==  `CA53_REQ_READSHARED) | (dr_type ==  `CA53_REQ_READUNIQUE))) ),
    .consequent_expr (~scu_dr_resp[4]));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb0_beat_seen <= 1'b0;
  else
    first_lfb0_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0)) ? 1'b0 : (first_lfb0_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb1_beat_seen <= 1'b0;
  else
    first_lfb1_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1)) ? 1'b0 : (first_lfb1_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb2_beat_seen <= 1'b0;
  else
    first_lfb2_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2)) ? 1'b0 : (first_lfb2_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb3_beat_seen <= 1'b0;
  else
    first_lfb3_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3)) ? 1'b0 : (first_lfb3_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb4_beat_seen <= 1'b0;
  else
    first_lfb4_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4)) ? 1'b0 : (first_lfb4_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb5_beat_seen <= 1'b0;
  else
    first_lfb5_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5)) ? 1'b0 : (first_lfb5_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb6_beat_seen <= 1'b0;
  else
    first_lfb6_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6)) ? 1'b0 : (first_lfb6_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6))));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_lfb7_beat_seen <= 1'b0;
  else
    first_lfb7_beat_seen <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7)) ? 1'b0 : (first_lfb7_beat_seen | (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7))));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb0_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0))
    lfb0_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb1_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1))
    lfb1_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb2_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2))
    lfb2_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb3_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3))
    lfb3_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb4_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4))
    lfb4_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb5_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5))
    lfb5_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb6_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6))
    lfb6_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb7_isshared <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7))
    lfb7_isshared <= scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B];



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb0_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0))
    lfb0_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb1_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1))
    lfb1_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb2_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2))
    lfb2_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb3_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3))
    lfb3_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb4_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4))
    lfb4_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb5_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5))
    lfb5_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb6_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6))
    lfb6_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    lfb7_passdirty <= 1'b0;
  else if (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7))
    lfb7_passdirty <= scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B];


  // IsShared must be consistent for each beat in a linefill.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) & first_lfb0_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb0_isshared")
  u_ovl_intf_assume_da02e4685968bd4fa2bcb6e7517230ce1205de3d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) & first_lfb0_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb0_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) & first_lfb1_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb1_isshared")
  u_ovl_intf_assume_9b9af3a4dd2700ca5df66a6c6c42c9ca565b323e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) & first_lfb1_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb1_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) & first_lfb2_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb2_isshared")
  u_ovl_intf_assume_cb351a36d1383fa883ad4a43d896d78253dda052 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) & first_lfb2_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb2_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) & first_lfb3_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb3_isshared")
  u_ovl_intf_assume_fa0c50735f0436326389cbd3c1bd3e1b37212bed (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) & first_lfb3_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb3_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) & first_lfb4_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb4_isshared")
  u_ovl_intf_assume_b0692919c63baaa4388d5e49377a0318ab69838a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) & first_lfb4_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb4_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) & first_lfb5_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb5_isshared")
  u_ovl_intf_assume_b76a8abbee8de46c141d67de189e9d62faddc808 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) & first_lfb5_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb5_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) & first_lfb6_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb6_isshared")
  u_ovl_intf_assume_db61f8bdfeb6e1a68249dca3b1624b38dadd83eb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) & first_lfb6_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb6_isshared));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) & first_lfb7_beat_seen  => scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb7_isshared")
  u_ovl_intf_assume_137d814b89336fe5349e7c87e1a9eb27b1ee6376 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) & first_lfb7_beat_seen ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_ISSHARED_B] == lfb7_isshared));



  // Once one beat in the burst has been marked as dirty the rest must also be.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) & first_lfb0_beat_seen & lfb0_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_719631f77c932ec18450f7840d5d340ed1cf8b8f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0) & first_lfb0_beat_seen & lfb0_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) & first_lfb1_beat_seen & lfb1_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_5df5ea6232b397358a571d7920e47fce25b37f61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1) & first_lfb1_beat_seen & lfb1_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) & first_lfb2_beat_seen & lfb2_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_dbe1bfe003a3360999c550cd86524e3f71249d88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2) & first_lfb2_beat_seen & lfb2_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) & first_lfb3_beat_seen & lfb3_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_03214f8a912d8e7b5df52e7efbadb1032e5a0cd0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3) & first_lfb3_beat_seen & lfb3_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) & first_lfb4_beat_seen & lfb4_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_89c388761f69caf259e8fa8b999824d0ee7027c0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4) & first_lfb4_beat_seen & lfb4_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) & first_lfb5_beat_seen & lfb5_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_82ac2c29afe8cf923696f21d67473760f535e65b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5) & first_lfb5_beat_seen & lfb5_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) & first_lfb6_beat_seen & lfb6_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_045a6d163423e2ccbcb6f1fed0c3aa561bf523d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6) & first_lfb6_beat_seen & lfb6_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) & first_lfb7_beat_seen & lfb7_passdirty  => scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]")
  u_ovl_intf_assume_3822ab6d1a94d484592f43ee6c0b5a5a5b0cb245 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7) & first_lfb7_beat_seen & lfb7_passdirty ),
    .consequent_expr (scu_dr_resp[`CA53_ACE_RRESP_PASSDIRTY_B]));



  // Assertions - scu_dr_chunk
  // -------------------------

  assign initial_beats_remaining  = biu_ar_wrap ? 4'b1111 : ((4'b1111 >> (4'b0011 - biu_ar_len)) << biu_ar_addr[5:4]);


  assign next_remaining_dcu0_beats  = (remaining_dcu0_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_DCU0)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_dcu1_beats  = (remaining_dcu1_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_DCU1)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_dcu2_beats  = (remaining_dcu2_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_DCU2)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_dcu3_beats  = (remaining_dcu3_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_DCU3)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb0_beats  = (remaining_lfb0_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB0)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb1_beats  = (remaining_lfb1_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB1)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb2_beats  = (remaining_lfb2_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB2)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb3_beats  = (remaining_lfb3_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB3)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb4_beats  = (remaining_lfb4_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB4)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb5_beats  = (remaining_lfb5_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB5)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb6_beats  = (remaining_lfb6_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB6)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_lfb7_beats  = (remaining_lfb7_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_LFB7)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_tlb_beats   = (remaining_tlb_beats  & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_TLB)}}  & (1'b1 << scu_dr_chunk)));
  assign next_remaining_icu0_beats  = (remaining_icu0_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_ICU0)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_icu1_beats  = (remaining_icu1_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_ICU1)}} & (1'b1 << scu_dr_chunk)));
  assign next_remaining_icu2_beats  = (remaining_icu2_beats & ~({4{scu_dr_valid & (scu_dr_id == `CA53_RID_ICU2)}} & (1'b1 << scu_dr_chunk)));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_dcu0_beats <= 4'b0000;
  else
    remaining_dcu0_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU0)) ? initial_beats_remaining : next_remaining_dcu0_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_dcu1_beats <= 4'b0000;
  else
    remaining_dcu1_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU1)) ? initial_beats_remaining : next_remaining_dcu1_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_dcu2_beats <= 4'b0000;
  else
    remaining_dcu2_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU2)) ? initial_beats_remaining : next_remaining_dcu2_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_dcu3_beats <= 4'b0000;
  else
    remaining_dcu3_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_DCU3)) ? initial_beats_remaining : next_remaining_dcu3_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb0_beats <= 4'b0000;
  else
    remaining_lfb0_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB0)) ? initial_beats_remaining : next_remaining_lfb0_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb1_beats <= 4'b0000;
  else
    remaining_lfb1_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB1)) ? initial_beats_remaining : next_remaining_lfb1_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb2_beats <= 4'b0000;
  else
    remaining_lfb2_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB2)) ? initial_beats_remaining : next_remaining_lfb2_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb3_beats <= 4'b0000;
  else
    remaining_lfb3_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB3)) ? initial_beats_remaining : next_remaining_lfb3_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb4_beats <= 4'b0000;
  else
    remaining_lfb4_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB4)) ? initial_beats_remaining : next_remaining_lfb4_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb5_beats <= 4'b0000;
  else
    remaining_lfb5_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB5)) ? initial_beats_remaining : next_remaining_lfb5_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb6_beats <= 4'b0000;
  else
    remaining_lfb6_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB6)) ? initial_beats_remaining : next_remaining_lfb6_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_lfb7_beats <= 4'b0000;
  else
    remaining_lfb7_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_LFB7)) ? initial_beats_remaining : next_remaining_lfb7_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_tlb_beats <= 4'b0000;
  else
    remaining_tlb_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_TLB))  ? initial_beats_remaining : next_remaining_tlb_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_icu0_beats <= 4'b0000;
  else
    remaining_icu0_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU0)) ? initial_beats_remaining : next_remaining_icu0_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_icu1_beats <= 4'b0000;
  else
    remaining_icu1_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU1)) ? initial_beats_remaining : next_remaining_icu1_beats);


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    remaining_icu2_beats <= 4'b0000;
  else
    remaining_icu2_beats <= ((biu_ar_valid & (biu_ar_id == `CA53_RID_ICU2)) ? initial_beats_remaining : next_remaining_icu2_beats);


  assign remaining_beats  = ((scu_dr_id == `CA53_RID_DCU0) ? remaining_dcu0_beats : (scu_dr_id == `CA53_RID_DCU1) ? remaining_dcu1_beats : (scu_dr_id == `CA53_RID_DCU2) ? remaining_dcu2_beats : (scu_dr_id == `CA53_RID_DCU3) ? remaining_dcu3_beats : (scu_dr_id == `CA53_RID_LFB0) ? remaining_lfb0_beats : (scu_dr_id == `CA53_RID_LFB1) ? remaining_lfb1_beats : (scu_dr_id == `CA53_RID_LFB2) ? remaining_lfb2_beats : (scu_dr_id == `CA53_RID_LFB3) ? remaining_lfb3_beats : (scu_dr_id == `CA53_RID_LFB4) ? remaining_lfb4_beats : (scu_dr_id == `CA53_RID_LFB5) ? remaining_lfb5_beats : (scu_dr_id == `CA53_RID_LFB6) ? remaining_lfb6_beats : (scu_dr_id == `CA53_RID_LFB7) ? remaining_lfb7_beats : (scu_dr_id == `CA53_RID_TLB)  ? remaining_tlb_beats : (scu_dr_id == `CA53_RID_ICU0) ? remaining_icu0_beats : (scu_dr_id == `CA53_RID_ICU1) ? remaining_icu1_beats : (scu_dr_id == `CA53_RID_ICU2) ? remaining_icu2_beats : 4'b0000);

  // The same chunk must not be sent more than once in a burst, and chunks outside the burst range must not be sent.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_dr_valid  => |((4'b0001 << scu_dr_chunk) & remaining_beats)")
  u_ovl_intf_assume_779df8cfeeba89b4daecbdb589deaf72f0c62ee9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_dr_valid ),
    .consequent_expr (|((4'b0001 << scu_dr_chunk) & remaining_beats)));



  // Assertions - scu_rr_id
  // ----------------------

  // A valid ID must be used.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid  => scu_rr_id in [`CA53_RID_STB0, `CA53_RID_STB1, `CA53_RID_STB2, `CA53_RID_STB3, `CA53_RID_STB4, `CA53_RID_ECC, `CA53_RID_RNONE]")
  u_ovl_intf_assume_ae6175743ae6bd71552cc235ae5dc0ac9983c252 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid ),
    .consequent_expr (((scu_rr_id == `CA53_RID_STB0) | (scu_rr_id ==  `CA53_RID_STB1) | (scu_rr_id ==  `CA53_RID_STB2) | (scu_rr_id ==  `CA53_RID_STB3) | (scu_rr_id ==  `CA53_RID_STB4) | (scu_rr_id ==  `CA53_RID_ECC) | (scu_rr_id ==  `CA53_RID_RNONE))));


  // A response must only be returned if there is an outstanding request on that ID.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_STB0)  => read_stb0_outstanding")
  u_ovl_intf_assume_b5a119b7e1e23433cdd5071d47b9330e6bf024ca (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_STB0) ),
    .consequent_expr (read_stb0_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_STB1)  => read_stb1_outstanding")
  u_ovl_intf_assume_ddca983e28742e942f95e3edddbb5871d6a75aeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_STB1) ),
    .consequent_expr (read_stb1_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_STB2)  => read_stb2_outstanding")
  u_ovl_intf_assume_788d535d679ed5280542d16acf6d9aca37353033 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_STB2) ),
    .consequent_expr (read_stb2_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_STB3)  => read_stb3_outstanding")
  u_ovl_intf_assume_c576f7c760fbecae87e5378e326217081e504c2b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_STB3) ),
    .consequent_expr (read_stb3_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_STB4)  => read_stb4_outstanding")
  u_ovl_intf_assume_ad5f52ab0822bf1270d5ea5df5d91388e38f61b0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_STB4) ),
    .consequent_expr (read_stb4_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_ECC)   => read_ecc_outstanding")
  u_ovl_intf_assume_cfb9787e22bbcf953fb2898cd8ddcf8fcec8d411 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_ECC)  ),
    .consequent_expr (read_ecc_outstanding));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (scu_rr_id == `CA53_RID_RNONE) => read_rnone_outstanding")
  u_ovl_intf_assume_5fb3728e5a310a4f8172730ccca1697aa7c44595 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (scu_rr_id == `CA53_RID_RNONE)),
    .consequent_expr (read_rnone_outstanding));



  assign read_stb0_completed   = scu_rr_valid & (scu_rr_id == `CA53_RID_STB0);
  assign read_stb1_completed   = scu_rr_valid & (scu_rr_id == `CA53_RID_STB1);
  assign read_stb2_completed   = scu_rr_valid & (scu_rr_id == `CA53_RID_STB2);
  assign read_stb3_completed   = scu_rr_valid & (scu_rr_id == `CA53_RID_STB3);
  assign read_stb4_completed   = scu_rr_valid & (scu_rr_id == `CA53_RID_STB4);
  assign read_ecc_completed    = scu_rr_valid & (scu_rr_id == `CA53_RID_ECC);
  assign read_rnone_completed  = scu_rr_valid & (scu_rr_id == `CA53_RID_RNONE);


  // Assertions - scu_rr_resp
  // ------------------------

  assign rr_type  = ((scu_rr_id == `CA53_RID_STB0) ? outstanding_stb0_type : (scu_rr_id == `CA53_RID_STB1) ? outstanding_stb1_type : (scu_rr_id == `CA53_RID_STB2) ? outstanding_stb2_type : (scu_rr_id == `CA53_RID_STB3) ? outstanding_stb3_type : (scu_rr_id == `CA53_RID_STB4) ? outstanding_stb4_type : (scu_rr_id == `CA53_RID_ECC)  ? `CA53_REQ_ECCCLEAN : (scu_rr_id == `CA53_RID_RNONE)? `CA53_REQ_READNONE : `CA53_REQ_READNOSNOOP);

  // An exclusive response may only be returned for a CleanUnique request.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_rr_valid & (rr_type != `CA53_REQ_CLEANUNIQUE)  => (scu_rr_resp != `CA53_RESP_EXOKAY)")
  u_ovl_intf_assume_7f728c1d03ed3f3df6a8107cdf26094b3016eecd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rr_valid & (rr_type != `CA53_REQ_CLEANUNIQUE) ),
    .consequent_expr ((scu_rr_resp != `CA53_RESP_EXOKAY)));



  assign new_write  = scu_rr_valid & ((rr_type == `CA53_REQ_WRITENOSNOOP) | (rr_type ==  `CA53_REQ_WRITEUNIQUE) | (rr_type ==  `CA53_REQ_DVM));

  // Writes should always have OKAY response

  assert_implication #(`OVL_FATAL, INOPTIONS, "new_write  => scu_rr_resp == `CA53_RESP_OKAY")
  u_ovl_intf_assume_a8b3c685ae294a85366f14782459c22d0a5ab656 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (new_write ),
    .consequent_expr (scu_rr_resp == `CA53_RESP_OKAY));



  // Assertions - scu_rr_l2db_id
  // ---------------------------


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_write_l2db_ids <= {16{1'b0}};
  else
    outstanding_write_l2db_ids <= ((outstanding_write_l2db_ids | ({16{new_write}} & (1'b1 << scu_rr_l2db_id))) & ~({16{biu_dw_valid & biu_dw_last}} & (1'b1 << biu_dw_l2db_id)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_dvm_l2db_ids <= {16{1'b0}};
  else
    outstanding_dvm_l2db_ids <= ((outstanding_dvm_l2db_ids | ({16{scu_rr_valid & (rr_type == `CA53_REQ_DVM)}} & (1'b1 << scu_rr_l2db_id))) & ~({16{biu_dw_valid & biu_dw_last}} & (1'b1 << biu_dw_l2db_id)));


  // A new write must not allocate an L2DB already in use.

  assert_implication #(`OVL_FATAL, INOPTIONS, "new_write  => ~|((1'b1 << scu_rr_l2db_id) & outstanding_write_l2db_ids)")
  u_ovl_intf_assume_bc29a6c39d69dae6d84bbba01df7dbf64bc8e827 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (new_write ),
    .consequent_expr (~|((1'b1 << scu_rr_l2db_id) & outstanding_write_l2db_ids)));



  // Assertions - scu_ev_done
  // ------------------------

  assign expect_ev_done  = {8{biu_ar_valid}} & {biu_ar_id == `CA53_RID_LFB7, biu_ar_id == `CA53_RID_LFB6, biu_ar_id == `CA53_RID_LFB5, biu_ar_id == `CA53_RID_LFB4, biu_ar_id == `CA53_RID_LFB3, biu_ar_id == `CA53_RID_LFB2, biu_ar_id == `CA53_RID_LFB1, biu_ar_id == `CA53_RID_LFB0};


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ev_done_required <= {8{1'b0}};
  else
    ev_done_required <= (ev_done_required | expect_ev_done) & ~scu_ev_done;


  // Only one ev done must be sent per request.

  assert_always #(`OVL_FATAL, INOPTIONS, "~|(scu_ev_done & ~ev_done_required)")
  u_ovl_intf_assume_ee8cb7574a4c6cf5324cef38fd15b2dae809ebfc (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(scu_ev_done & ~ev_done_required)));


  // A new request must not be sent while there is an ev done outstanding.

  assert_always #(`OVL_FATAL, OUTOPTIONS, "~|(expect_ev_done & ev_done_required)")
  u_ovl_intf_assert_4fa7b09de99122a70f016fb2b970e987db182a6a (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~|(expect_ev_done & ev_done_required)));




  //----------------------------------------------------------------------------
  // Write data channel
  //----------------------------------------------------------------------------

  // The BIU is supplying new write data this cycle. The SCU will always accept it.
  //  output biu_dw_valid valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_dw_valid X or Z")
  u_ovl_intf_x_biu_dw_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_dw_valid));


  // The L2 data buffer that this write is for. This must have been previously
  // allocated by an address request or a snoop.
  //  output [3:0] biu_dw_l2db_id valid biu_dw_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "biu_dw_l2db_id X or Z")
  u_ovl_intf_x_biu_dw_l2db_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid),
    .test_expr (biu_dw_l2db_id));


  // The 128bit chunks of the line that are valid in this transfer. Only 1 or 2
  // chunks may be valid, and they must be both in the same halfline.
  //  output [3:0] biu_dw_chunks_valid valid biu_dw_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "biu_dw_chunks_valid X or Z")
  u_ovl_intf_x_biu_dw_chunks_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid),
    .test_expr (biu_dw_chunks_valid));


  // This beat is the last in the burst. Note that for some types of writes the
  // number of beats is not known and so this signal is the only way of telling
  // when all the data has been sent.
  //  output biu_dw_last valid biu_dw_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_dw_last X or Z")
  u_ovl_intf_x_biu_dw_last (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid),
    .test_expr (biu_dw_last));


  // The write data.
  //  output [255:0] biu_dw_data valid mask biu_dw_expanded_strobes timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 256, OUTOPTIONS, "biu_dw_data & (biu_dw_expanded_strobes) X or Z")
  u_ovl_intf_x_18959b5049bbab4b27a4791432aac25b903926d5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_dw_data & (biu_dw_expanded_strobes)));


  // The byte strobes for the data.
  //  output [31:0] biu_dw_strb valid biu_dw_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "biu_dw_strb X or Z")
  u_ovl_intf_x_biu_dw_strb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid),
    .test_expr (biu_dw_strb));


  // The data contains an ECC error, which may or may not be correctable.
  // The SCU should look at biu_dw_fatal int he following cycle to determine if
  // it was uncorrectable.
  //  output biu_dw_err valid biu_dw_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_dw_err X or Z")
  u_ovl_intf_x_biu_dw_err (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid),
    .test_expr (biu_dw_err));


  // The data sent int he previous cycle contained an uncorrectable ECC error.
  //  output biu_dw_fatal valid biu_dw_valid@1 timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_dw_fatal X or Z")
  u_ovl_intf_x_biu_dw_fatal (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_dw_valid_reg),
    .test_expr (biu_dw_fatal));



  assign biu_dw_expanded_strobes  = {{8{biu_dw_strb[31] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[30] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[29] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[28] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[27] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[26] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[25] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[24] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[23] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[22] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[21] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[20] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[19] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[18] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[17] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[16] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[15] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[14] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[13] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[12] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[11] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[10] & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[9]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[8]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[7]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[6]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[5]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[4]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[3]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[2]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[1]  & biu_dw_valid & ~biu_dw_err}}, {8{biu_dw_strb[0]  & biu_dw_valid & ~biu_dw_err}}};

  // Assertions - biu_dw_l2db_id
  // ---------------------------

`ifndef CA53_BIU_ONLY


  assign snoop_has_data  = ((scu_ac_snoop == `CA53_SNOOP_CLEANSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_CLEANINVALID) | (scu_ac_snoop ==  `CA53_SNOOP_READONCE) | (scu_ac_snoop ==  `CA53_SNOOP_READSHARED) | (scu_ac_snoop ==  `CA53_SNOOP_READMAKESHARED));

  assign new_snoop  = scu_ac_valid & dcu_ac_ready & snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop0_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b000))
    snoop0_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop1_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b001))
    snoop1_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop2_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b010))
    snoop2_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop3_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b011))
    snoop3_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop4_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b100))
    snoop4_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop5_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b101))
    snoop5_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop6_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b110))
    snoop6_l2db_id <= scu_ac_l2db_id;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop7_l2db_id <= 4'b0000;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b111))
    snoop7_l2db_id <= scu_ac_l2db_id;



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop0_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b000))
    snoop0_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop1_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b001))
    snoop1_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop2_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b010))
    snoop2_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop3_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b011))
    snoop3_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop4_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b100))
    snoop4_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop5_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b101))
    snoop5_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop6_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b110))
    snoop6_has_data <= snoop_has_data;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    snoop7_has_data <= 1'b0;
  else if (scu_ac_valid & dcu_ac_ready & (scu_ac_id == 3'b111))
    snoop7_has_data <= snoop_has_data;


  assign snoop_resp_has_data  = dcu_cr_valid & (((dcu_cr_id == 3'b000) & snoop0_has_data) | ((dcu_cr_id == 3'b001) & snoop1_has_data) | ((dcu_cr_id == 3'b010) & snoop2_has_data) | ((dcu_cr_id == 3'b011) & snoop3_has_data) | ((dcu_cr_id == 3'b100) & snoop4_has_data) | ((dcu_cr_id == 3'b101) & snoop5_has_data) | ((dcu_cr_id == 3'b110) & snoop6_has_data) | ((dcu_cr_id == 3'b111) & snoop7_has_data));

  assign snoop_resp_l2db_id  = (({4{dcu_cr_id == 3'b000}} & snoop0_l2db_id) | ({4{dcu_cr_id == 3'b001}} & snoop1_l2db_id) | ({4{dcu_cr_id == 3'b010}} & snoop2_l2db_id) | ({4{dcu_cr_id == 3'b011}} & snoop3_l2db_id) | ({4{dcu_cr_id == 3'b100}} & snoop4_l2db_id) | ({4{dcu_cr_id == 3'b101}} & snoop5_l2db_id) | ({4{dcu_cr_id == 3'b110}} & snoop6_l2db_id) | ({4{dcu_cr_id == 3'b111}} & snoop7_l2db_id));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_snoop_l2db_ids <= {16{1'b0}};
  else
    outstanding_snoop_l2db_ids <= ((outstanding_snoop_l2db_ids | ({16{new_snoop_reg}} & (16'h0001 << scu_ac_l2db_id_reg))) & ~({16{biu_dw_valid & biu_dw_last}} & (16'h0001 << biu_dw_l2db_id)));


  assign next_outstanding_snoop_resp_l2db_ids  = ((outstanding_snoop_resp_l2db_ids | ({16{new_snoop_reg}} & (16'h0001 << scu_ac_l2db_id_reg))) & ~({16{snoop_resp_has_data}} & (16'h0001 << snoop_resp_l2db_id)));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_snoop_resp_l2db_ids <= {16{1'b0}};
  else
    outstanding_snoop_resp_l2db_ids <= next_outstanding_snoop_resp_l2db_ids;


  // A snoop must not allocate an L2DB already in use.

  assert_implication #(`OVL_FATAL, INOPTIONS, "new_snoop@1  => ~|((1'b1 << scu_ac_l2db_id@1) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))")
  u_ovl_intf_assume_abc2aab5708f9bd4296522b7bc7f3d146c49b2f0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (new_snoop_reg ),
    .consequent_expr (~|((1'b1 << scu_ac_l2db_id_reg) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))));


  // A new write must not allocate an L2DB already in use.

  assert_implication #(`OVL_FATAL, INOPTIONS, "new_write  => ~|((16'h0001 << scu_rr_l2db_id) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))")
  u_ovl_intf_assume_bf917a524288f7aaf6cf2790fcecaa609ec93e40 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (new_write ),
    .consequent_expr (~|((16'h0001 << scu_rr_l2db_id) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))));


  // A write must use a previously allocated L2DB ID.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid  => |((16'h0001 << biu_dw_l2db_id) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))")
  u_ovl_intf_assert_7d8048c682c621dcdfacb8b83ba2816a9a60fcd2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid ),
    .consequent_expr (|((16'h0001 << biu_dw_l2db_id) & (outstanding_write_l2db_ids | outstanding_snoop_l2db_ids))));


  // A snoop write must not send the data before the snoop response (but can send them on the same cycle).

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid  => ~|((16'h0001 << biu_dw_l2db_id) & next_outstanding_snoop_resp_l2db_ids)")
  u_ovl_intf_assert_899b505cd8a5996dab8174abc588751d5cd9c18a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid ),
    .consequent_expr (~|((16'h0001 << biu_dw_l2db_id) & next_outstanding_snoop_resp_l2db_ids)));


  // Write data cannot use an L2DB that it received on the RR channel the previous cycle, there is a delay
  // of at least one additional cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid  => (~new_write@1 | (scu_rr_l2db_id@1 != biu_dw_l2db_id))")
  u_ovl_intf_assert_0bd11c249435561690f187a0370c7a4c83306a49 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid ),
    .consequent_expr ((~new_write_reg | (scu_rr_l2db_id_reg != biu_dw_l2db_id))));

`endif


  // Assertions - biu_dw_chunks_valid
  // --------------------------------

  // Data must have at least one chunk valid.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid  => |biu_dw_chunks_valid")
  u_ovl_intf_assert_9c59cc8fc7fac8903cdf326b604d3707933578cf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid ),
    .consequent_expr (|biu_dw_chunks_valid));


  // Data cannot be valid for both the upper and lower halves of the line at the same time.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid  => ~(|biu_dw_chunks_valid[3:2] & |biu_dw_chunks_valid[1:0])")
  u_ovl_intf_assert_a4edf9e8846e3327c3377d841797ba56f96df7b2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid ),
    .consequent_expr (~(|biu_dw_chunks_valid[3:2] & |biu_dw_chunks_valid[1:0])));



  assign data_is_dvm  = biu_dw_valid & |((1'b1 << biu_dw_l2db_id) & outstanding_dvm_l2db_ids);

  // DVMs must provide only one chunk of data.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_dvm  => biu_dw_chunks_valid == 4'b0001")
  u_ovl_intf_assert_9a07086cdc4d8de829cd5b874efd467b4d6d88d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_dvm ),
    .consequent_expr (biu_dw_chunks_valid == 4'b0001));


  assign data_is_snoop  = biu_dw_valid & |((1'b1 << biu_dw_l2db_id) & ~outstanding_write_l2db_ids);

  assign new_beats  = {64{biu_dw_valid}} & (biu_dw_chunks_valid << (4*biu_dw_l2db_id));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    beats_seen <= {((4*16-1) - (0) + 1){1'b0}};
  else
    beats_seen <= ((beats_seen | new_beats) & ~({64{biu_dw_valid & biu_dw_last}} & (4'b1111 << (4*biu_dw_l2db_id))));


  // Snoop data must provide a halfline of data.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_snoop  => biu_dw_chunks_valid in [4'b0011, 4'b1100]")
  u_ovl_intf_assert_90b6aaf4b62e28363c3444a6c302d7d046d18b71 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_snoop ),
    .consequent_expr (((biu_dw_chunks_valid == 4'b0011) | (biu_dw_chunks_valid ==  4'b1100))));


  // Snoop data must provide each chunk exactly once.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_snoop  => ~|(new_beats & beats_seen)")
  u_ovl_intf_assert_36720e0dcdb3c15cb9f247a4379025d175f3a24b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_snoop ),
    .consequent_expr (~|(new_beats & beats_seen)));



  // Assertions - biu_dw_last
  // ------------------------


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    first_beat_seen <= {16{1'b0}};
  else
    first_beat_seen <= ((first_beat_seen | ({16{biu_dw_valid}} & (1'b1 << biu_dw_l2db_id))) & ~({16{biu_dw_valid & biu_dw_last}} & (1'b1 << biu_dw_l2db_id)));


  // Snoop data must provide exactly two 256 bit beats.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_snoop  => biu_dw_last == first_beat_seen[biu_dw_l2db_id]")
  u_ovl_intf_assert_46e2011182a3259568175e7c7eefd1548c1070bf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_snoop ),
    .consequent_expr (biu_dw_last == first_beat_seen[biu_dw_l2db_id]));


  // DVMs must provide only one chunk of data.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_dvm  => biu_dw_last")
  u_ovl_intf_assert_a1e8b30ce68d58e488f23d585bd746a93b51f91f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_dvm ),
    .consequent_expr (biu_dw_last));


  // Assertions - biu_dw_data
  // ------------------------

  // For DVM operations, one beat of data must be provided and
  // bits [46:4] contain the VA[48:6] (for TLB or BP ops) or
  // bits [41:4] contain PA[43:6] (for IC ops).

  // Assertions - biu_dw_strb
  // ------------------------

  // Snoops must provide all bytes of data.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_snoop  => &biu_dw_strb")
  u_ovl_intf_assert_875ce3023aecce4312200e6f1bab9ed49aa588e6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_snoop ),
    .consequent_expr (&biu_dw_strb));


  // DVMs must provide 8 bytes of data.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "data_is_dvm  => (biu_dw_strb == 16'h00ff)")
  u_ovl_intf_assert_abc032e5efb7fdce7691d5e01581cd20b21b476b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (data_is_dvm ),
    .consequent_expr ((biu_dw_strb == 16'h00ff)));


  // Some bytes must be valid for each chunk that is marked as valid or
  // all bytes are not valid.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & |biu_dw_chunks_valid[0]  => (|biu_dw_strb[15:0])  | ~|biu_dw_strb[31:0]")
  u_ovl_intf_assert_a310abbaa3475d93429e0da1812ba6e36b3ee198 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & |biu_dw_chunks_valid[0] ),
    .consequent_expr ((|biu_dw_strb[15:0])  | ~|biu_dw_strb[31:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & |biu_dw_chunks_valid[1]  => (|biu_dw_strb[31:16]) | ~|biu_dw_strb[31:0]")
  u_ovl_intf_assert_c682082c06ff746e2639fc898e20f1f993cbe6e2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & |biu_dw_chunks_valid[1] ),
    .consequent_expr ((|biu_dw_strb[31:16]) | ~|biu_dw_strb[31:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & |biu_dw_chunks_valid[2]  => (|biu_dw_strb[15:0])  | ~|biu_dw_strb[31:0]")
  u_ovl_intf_assert_a2b6de0bb1b297b6ff3adde2b6f25d2150db283f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & |biu_dw_chunks_valid[2] ),
    .consequent_expr ((|biu_dw_strb[15:0])  | ~|biu_dw_strb[31:0]));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & |biu_dw_chunks_valid[3]  => (|biu_dw_strb[31:16]) | ~|biu_dw_strb[31:0]")
  u_ovl_intf_assert_3d1e6fd2c859116dd74527beff2c060f4e896519 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & |biu_dw_chunks_valid[3] ),
    .consequent_expr ((|biu_dw_strb[31:16]) | ~|biu_dw_strb[31:0]));


  // If two chunks are provided, then all bytes of data must be valid in them.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & (&biu_dw_chunks_valid[1:0] | &biu_dw_chunks_valid[3:2])  => &biu_dw_strb")
  u_ovl_intf_assert_afc4641a3f5a56ecc93967d05f18c45a75a561f2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & (&biu_dw_chunks_valid[1:0] | &biu_dw_chunks_valid[3:2]) ),
    .consequent_expr (&biu_dw_strb));


  // Assertions - biu_dw_err
  // -----------------------

  // ECC errors can only occur on data read from the cache.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid & ~data_is_snoop  => ~biu_dw_err")
  u_ovl_intf_assert_8483db0e48f3dfd97b0867e80d7e6e8db906ba4f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid & ~data_is_snoop ),
    .consequent_expr (~biu_dw_err));


  // Assertions - biu_dw_fatal
  // -------------------------

  // If the data has a fatal error the BIU must have signaled an error in the
  // previous cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_dw_valid@1 & biu_dw_fatal  => biu_dw_err@1")
  u_ovl_intf_assert_afacf8084c7bdb34ec8fa039ef15ac55bad43de4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_dw_valid_reg & biu_dw_fatal ),
    .consequent_expr (biu_dw_err_reg));



  //----------------------------------------------------------------------------
  // Write response channel
  //----------------------------------------------------------------------------

  // There is a valid write response for a non-coherent store exclusive instruction.
  //  input scu_db_excl_valid valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_db_excl_valid X or Z")
  u_ovl_intf_x_scu_db_excl_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_db_excl_valid));


  // The response to the store exclusive.
  //  input [1:0] scu_db_excl_resp valid scu_db_excl_valid timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "scu_db_excl_resp X or Z")
  u_ovl_intf_x_scu_db_excl_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_db_excl_valid),
    .test_expr (scu_db_excl_resp));


  // There was a decode error on any non-exclusive write from this processor.
  // This can arrive at any time and cannot be matched up to the transaction
  // that caused the error.
  //  input scu_db_decerr valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_db_decerr X or Z")
  u_ovl_intf_x_scu_db_decerr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_db_decerr));


  // There was a slave error on any non-exclusive write from this processor.
  // This can arrive at any time and cannot be matched up to the transaction
  // that caused the error.
  //  input scu_db_slverr valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_db_slverr X or Z")
  u_ovl_intf_x_scu_db_slverr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_db_slverr));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    outstanding_excl <= 1'b0;
  else
    outstanding_excl <= ((biu_ar_valid & (biu_ar_type == `CA53_REQ_WRITENOSNOOP) & biu_ar_lock) | (outstanding_excl & ~scu_db_excl_valid));


  // Can only get a response if there is an exclusive in progress.

  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_db_excl_valid  => outstanding_excl")
  u_ovl_intf_assume_7a532bed30cdf28c1ae6c78a99bc11128c5728dc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_db_excl_valid ),
    .consequent_expr (outstanding_excl));


  // There must only be one exclusive in progress at any one time.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "biu_ar_valid & (biu_ar_type == `CA53_REQ_WRITENOSNOOP) & biu_ar_lock  => ~outstanding_excl")
  u_ovl_intf_assert_a336963adc4b9fa96e7a25cc54cf1c2da28f32fa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (biu_ar_valid & (biu_ar_type == `CA53_REQ_WRITENOSNOOP) & biu_ar_lock ),
    .consequent_expr (~outstanding_excl));




  //----------------------------------------------------------------------------
  // Misc
  //----------------------------------------------------------------------------

  // The SCU has detected a hazard or a WriteUnique of less than a full line,
  // and therefore the CPU should leave read allocate mode (if it is still in
  // ramode).
  //  input scu_leave_ramode valid always timing 30% wiring 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_leave_ramode X or Z")
  u_ovl_intf_x_scu_leave_ramode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_leave_ramode));



endmodule

`define CA53_UNDEFINE
`include "ca53_scu_dcu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_biu_scu_defs.v"
`undef CA53_UNDEFINE

`endif

