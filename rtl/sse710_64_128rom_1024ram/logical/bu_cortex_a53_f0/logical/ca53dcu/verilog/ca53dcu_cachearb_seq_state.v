//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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

//-----------------------------------------------------------------------------
// Abstract : Cache arbiter sequential load state machine entry
//
// Each entry stores the address the entry is allocated to, the way in which
// the address is allocated in, and a state machine to control the entry.
//
// The state machine has three states:
// - In Idle, the entry is not valid, and all the outputs are masked. The
//   state machine is started when the cache arbiter asserts start_seq_m1,
//   when the load is leaving M1, which causes it to register the current
//   load address and enter First-seq.
// - In First-seq, the load is in M2, so the result of load tag lookup is
//   registered. This means that no further tag lookups are required, but the
//   tag result is too late to factor into the Data RAM enables, so a load
//   which hits in an entry in First-seq must still enable all banks of the
//   Data RAM. The state machine then moves immediately into Subsequent-seq.
// - In Subsequent-seq, the registered tag result is available, so only the
//   bank-pair of the data RAMs corresponding to the address and way of the
//   new load needs to be enabled. If all entries are valid and there is
//   a new load which does not hit in any, then an entry will be overwritten.
//   In this case, the state machine moves from Subsequent-seq back to
//   First-seq.
//
//-----------------------------------------------------------------------------

`include "ca53dcu_defs.v"

module ca53dcu_cachearb_seq_state
  (
   input    wire            clk,
   input    wire            reset_n,

   input    wire            entering_dcu_i,
   input    wire     [2:0]  back_to_back_hit_iss_i,
   input    wire            dpu_aarch64_state_i,
   input    wire    [47:6]  dpu_agu_a_operand_iss_i,
   input    wire    [47:6]  dpu_agu_b_operand_iss_i,
   input    wire    [48:6]  dpu_agu_a_xor_b_iss_i,
   input    wire    [47:6]  dpu_agu_a_and_b_iss_i,
   input    wire            dpu_agu_carry_out_64b_iss_i,
   input    wire    [48:6]  dpu_va_dc1_i,
   input    wire            start_seq_m1_i,
   input    wire            force_non_seq_i,
   input    wire     [3:0]  tag_way_comp_m2_i,

   output   wire            seq_suppress_tag_m1_o,
   output   wire            seq_suppress_data_m1_o,
   output   wire     [3:0]  seq_way_m1_o

  );


  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------

  reg   [48: 6]  seq_addr;
  reg   [ 3: 0]  seq_way;
  wire           seq_way_en;
  wire           seq_suppress_data_m1;
  wire  [48: 6]  csa_sum;
  wire  [47: 6]  csa_carry;
  wire  [48: 6]  csa_combine;
  wire  [ 2: 0]  csa_hit;
  wire  [ 2: 0]  addr_hit_iss;
  reg   [ 2: 0]  addr_hit_dc1;
  wire  [ 1: 0]  next_state;
  reg   [ 1: 0]  state;

  // The state machine states are encoded such that it is possible to decode
  // whether to suppress data and/or tag requests by looking at a single bit
  localparam [1:0] ST_IDLE    = 2'b00;
  localparam [1:0] ST_FIRST   = 2'b01;
  localparam [1:0] ST_SUBSEQ  = 2'b11;


  //---------------------------------------------------------------------------
  // Sequential state machine logic
  //---------------------------------------------------------------------------

  assign next_state = start_seq_m1_i  ? ST_FIRST  :
                      force_non_seq_i ? ST_IDLE   :
                      state[0]        ? ST_SUBSEQ :
                                        ST_IDLE;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      state <= ST_IDLE;
    else
      state <= next_state;


  //---------------------------------------------------------------------------
  // Request lookup
  //---------------------------------------------------------------------------
  // The lookup happens in two stages:
  // - The address is looked up in Iss and the hit registered
  // - The uTLB hit entry is checked in DC1 and the final hit signal created

  // Register new address whenever state machine started (when the load is in
  // M1).
  always @(posedge clk)
    if (start_seq_m1_i)
      seq_addr <= dpu_va_dc1_i;

  // Do address lookup in Iss using CSA based comparator
  assign csa_sum      = dpu_agu_a_xor_b_iss_i[48:6] ^ ~seq_addr[48:6];
  assign csa_carry    = dpu_agu_a_and_b_iss_i[47:6]                       |
                        (dpu_agu_a_operand_iss_i[47:6] & ~seq_addr[47:6]) |
                        (dpu_agu_b_operand_iss_i[47:6] & ~seq_addr[47:6]);
  assign csa_combine  = (csa_sum[48:6] ^ {csa_carry[47:6], dpu_agu_carry_out_64b_iss_i}) | { {17{~dpu_aarch64_state_i}}, {26{1'b0}} };

  // - Split reduction of csa_combine between Iss and DC1 for timing reasons
  assign csa_hit[2]   = &csa_combine[48:34];
  assign csa_hit[1]   = &csa_combine[33:20];
  assign csa_hit[0]   = &csa_combine[19: 6];

  // Because the address lookup is done a cycle before the uTLB lookup, misses are
  // only detected in DC1, which means a new entry can only be allocated for a miss
  // once the access is in DC1.
  // To allow a subsequent load to the same line as a miss currently allocating an
  // entry in DC1 to hit, the cachearb top level compares the address in Iss with
  // the address in DC1; if they match and there is a miss in DC1, the access
  // currently in Iss will hit in the current victim entry on the next cycle.
  assign addr_hit_iss = start_seq_m1_i ? back_to_back_hit_iss_i
                                       : csa_hit;

  always @(posedge clk)
    if (entering_dcu_i)
      addr_hit_dc1 <= addr_hit_iss;

  // Suppress if address and uTLB entry match. Stored uTLB entry is created such
  // that guarantee will miss if entry is not valid
  assign seq_suppress_tag_m1_o  = &{addr_hit_dc1, state[0]};
  assign seq_suppress_data_m1   = &{addr_hit_dc1, state[1]};
  assign seq_suppress_data_m1_o = seq_suppress_data_m1;


  //---------------------------------------------------------------------------
  // Hit Way
  //---------------------------------------------------------------------------
  // Register hit way when in suppress tag state, as this is the cycle after
  // the state machine was started (when the load lookup was in M1), and so
  // the load lookup will be in M2 on that cycle.
  assign seq_way_en = (state == ST_FIRST);

  always @(posedge clk)
    if (seq_way_en)
      seq_way <= tag_way_comp_m2_i;

  // Mask the way output, so that the outputs from each entry can just be
  // ANDed together in the cache arbiter to mux between them.
  assign seq_way_m1_o = {4{~seq_suppress_data_m1}} | seq_way; // Force to 4'b1111 (i.e. non-sequential) when not valid


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // As seq_way registers a cache lookup, it should only ever be zero (for
  // misses) or one-hot (for hits).
  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "seq_way one-hot or zero")
  u_ovl_seq_way_onehot (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ({4{(state == ST_SUBSEQ) & ~(u_cachearb.dcu_ecc_tag_err_m2_o | u_cachearb.dcu_ecc_tag_err_m3_o)}} & seq_way));

  // Not all state transitions are possible
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid sequential state machine transition: Idle to Sub-seq")
  u_ovl_non_seq_transition   (.clk         (clk),
                              .reset_n     (reset_n),
                              .start_event ((state == ST_IDLE)),
                              .test_expr   ((state == ST_FIRST) | (state == ST_IDLE)));

  // - Cannot go from first to first, as that would require two back to back
  // loads to different addresses which both miss and have this as the victim
  // entry, which is not possible because of the round-robin victim selection
  // arbitration in the cache arbiter.
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid sequential state machine transition: First-seq to First-seq")
  u_ovl_first_seq_transition (.clk         (clk),
                              .reset_n     (reset_n),
                              .start_event ((state == ST_FIRST)),
                              .test_expr   ((state != ST_FIRST)));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: seq_way_en")
  u_ovl_x_seq_way_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (seq_way_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: entering_dcu_i")
  u_ovl_x_entering_dcu_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (entering_dcu_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: start_seq_m1_i")
  u_ovl_x_start_seq_m1_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (start_seq_m1_i));

`endif

endmodule // ca53dcu_cachearb_seq_state

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53dcu_defs.v"
`undef CA53_UNDEFINE
/*END*/
