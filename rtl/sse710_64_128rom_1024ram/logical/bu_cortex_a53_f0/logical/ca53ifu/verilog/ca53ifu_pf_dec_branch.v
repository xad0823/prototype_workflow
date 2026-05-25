//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : Branch decoder
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_dec_branch (
  // Inputs
  input wire [39:0]  instr0_if3_i,
  input wire [39:0]  instr1_if3_i,
  input wire [39:0]  instr0_32_if3_i,
  input wire [39:0]  instr1_32_if3_i,
  input wire [1:0]   instr_valid_if3_i,
  input wire [1:0]   cpsr_state_i,
  input wire         instr_is_a32_if3_i,
  input wire         instr_is_a64_if3_i,
  input wire         instr_is_thumb_if3_i,
  input wire         taken_i0_if3_i,
  input wire         taken_i1_if3_i,
  input wire [3:1]   it_cc_0_i,
  input wire [3:1]   it_cc_1_i,
  input wire [1:0]   it_block_i,
  input wire [1:0]   instr_abt_if3_i,
  input wire [1:0]   instr_pty_if3_i,
  input wire [1:0]   instr_vcr_if3_i,
  input wire [1:0]   instr_hw_bkpt_if3_i,
  input wire         instr_expt_catch_if3_i,
  input wire         instr_rst_catch_if3_i,
  input wire         branch_never_taken_i,
  // Outputs
  output wire [27:1] instr0_brn_offset_if3_o,
  output wire        instr0_brn_imm_if3_o,
  output wire        instr0_brn_o,
  output wire [27:1] instr1_brn_offset_if3_o,
  output wire        instr1_brn_imm_if3_o,
  output wire        instr1_possible_o,
  output wire        early_instr1_possible_o,
  output wire [1:0]  early_instr_taken_o,
  output wire [1:0]  brn_predicted_if3_o,
  output wire [1:0]  instr_dual_slot0_o,
  output wire [1:0]  instr_dual_slot1_o,
  output wire [1:0]  instr_brn_taken_if3_o,
  output wire [1:0]  instr_brn_btic_o,
  output wire [1:0]  instr_brn_t_cond_if3_o,
  output wire [1:0]  instr_brn_t3_if3_o,
  output wire [1:0]  instr_brn_link_if3_o,
  output wire [1:0]  instr_brn_exchange_a_if3_o,
  output wire [1:0]  instr_brn_exchange_t_if3_o,
  output wire [1:0]  instr_it_if3_o,
  output wire        instr_sw_bkpt_if3_o,
  output wire [1:0]  s32_btac_if3_o,
  output wire [1:0]  s32_return_if3_o,
  output wire [1:0]  t16_btac_if3_o,
  output wire [1:0]  t16_return_if3_o,
  output wire [1:0]  spec_btac_if3_o
);

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  localparam [5:0] SB_B_IMM       = 6'b100000;
  localparam [5:0] SB_CBZ         = 6'b101011;
  localparam [5:0] SB_BKPT        = 6'b100001;
  localparam [5:0] SB_CBZ_DIR     = 6'b101010;
  localparam [5:0] SB_LDR_BTAC    = 6'b010101;
  localparam [5:0] SB_LDR_PC_BTAC = 6'b011000;
  localparam [5:0] SB_BLX_BTAC    = 6'b100101;
  localparam [5:0] SB_TB_BTAC     = 6'b101101;
  localparam [5:0] SB_POP         = 6'b010111;
  localparam [5:0] SB_BX          = 6'b100100;

  // Branch decode control signals
  wire [39:0]    pfb_instr    [1:0];
  wire [39:0]    pfb_instr_32 [1:0];
  wire [3:1]     it_cc        [1:0];
  wire [1:0]     taken_if3;
  wire [1:0]     instr_a32_conditional;
  wire [1:0]     instr_a64_conditional;
  wire [1:0]     instr_thumb_conditional;
  wire [1:0]     instr_a32_taken;
  wire [1:0]     instr_thumb_taken;
  wire [1:0]     instr_thumb_taken_no_it;
  wire [1:0]     instr_a64_taken;
  wire [1:0]     early_instr_taken;

  // Sideband bits decode (32-bit instructions)
  wire [1:0]     s32_branch;
  wire [1:0]     s32_br_direct;
  wire [1:0]     s32_br_btac;
  wire [1:0]     s32_br_return;
  wire [1:0]     s32_dual_slot0;

  // Qualified 32-bit sideband decode
  wire [1:0]     i32_branch;
  wire [1:0]     i32_dual_slot0;

  // A64 ARM decode
  wire           a64_cpsr_state;
  wire [1:0]     a64_br_direct;
  wire [1:0]     a64_br_predicted;
  wire [1:0]     a64_br_btic;
  wire [1:0]     a64_br_imm;
  wire [1:0]     a64_br_taken;
  wire [1:0]     a64_br_link;
  wire [1:0]     a64_brk;
  wire [3:0]     a64_br_offset_sel [1:0];

  // A32 ARM decode
  wire           a32_cpsr_state;
  wire [1:0]     a32_br_predicted;
  wire [1:0]     a32_br_call;
  wire [1:0]     a32_br_btic;
  wire [1:0]     a32_br_imm;
  wire [1:0]     a32_br_taken;
  wire [1:0]     a32_br_link;
  wire [1:0]     a32_br_blx;
  wire [1:0]     a32_bkpt;
  wire [3:0]     a32_br_offset_sel [1:0];

  // A32 Thumb (32-bit) decode
  wire [1:0]     t32_cpsr_state;
  wire [1:0]     t32_br_direct_t3;
  wire [1:0]     t32_br_direct_not3;
  wire [1:0]     t32_br_btac_return;
  wire [1:0]     t32_br_b_bl_blx;
  wire [1:0]     t32_br_t3;
  wire [1:0]     t32_br_t_cond;
  wire [1:0]     t32_br_predicted;
  wire [1:0]     t32_br_call;
  wire [1:0]     t32_br_btic;
  wire [1:0]     t32_br_imm;
  wire [1:0]     t32_br_taken;
  wire [1:0]     t32_br_link;
  wire [1:0]     t32_br_blx;
  wire [3:0]     t32_br_offset_sel [1:0];

  // A32 Thumb (16-bit) decode
  wire [1:0]     t16_cpsr_state;
  wire [1:0]     instr_is_it;
  wire [1:0]     t16_branch;
  wire [1:0]     t16_br_imm;
  wire [1:0]     t16_br_return;
  wire [1:0]     t16_br_btac;
  wire [1:0]     t16_br_predicted;
  wire [1:0]     t16_br_btic;
  wire [1:0]     t16_br_link;
  wire [1:0]     t16_dual_slot0;
  wire [1:0]     t16_br_taken;
  wire [1:0]     t16_br_t_cond;
  wire [1:0]     t16_bkpt;
  wire [3:0]     t16_br_offset_sel [1:0];

  // Combined decoders (Instr-0 and Instr-1)
  wire [1:0]     instr_brn;
  wire [1:0]     instr_brn_imm_if3;
  wire [1:0]     instr_brn_predicted_if3;
  wire [1:0]     instr_brn_taken_if3;
  wire [1:0]     instr_brn_link_if3;
  wire [1:0]     instr_sw_bkpt;
  wire [1:0]     instr_dual_slot0;
  wire [1:0]     instr_dual_slot1;
  reg  [27:1]    instr_br_offset   [1:0];

  genvar i;


  //----------------------------------------------------------------------------
  // Branch decode control signals
  //----------------------------------------------------------------------------

  // Create ARM ARM view of instructions for A32 and A64 instruction types
  assign pfb_instr_32[0][39:0] = {instr0_32_if3_i[19:0], instr0_32_if3_i[39:20]};
  assign pfb_instr_32[1][39:0] = {instr1_32_if3_i[19:0], instr1_32_if3_i[39:20]};

  // Create ARM ARM view of instructions for all instruction types
  assign pfb_instr[0][39:0] = {instr0_if3_i[19:0], instr0_if3_i[39:20]};
  assign pfb_instr[1][39:0] = {instr1_if3_i[19:0], instr1_if3_i[39:20]};

  // Get some inputs into an array-based form.  This makes it easier to use them
  // in the generate blocks.
  assign it_cc[0]     = it_cc_0_i;      assign it_cc[1]     = it_cc_1_i;
  assign taken_if3[0] = taken_i0_if3_i; assign taken_if3[1] = taken_i1_if3_i;

  generate for (i=0; i<=1; i=i+1) begin : gen_instr

    // A32:         indicated conditional if CC is not 'always' and prediction is on
    // A64:         indicated conditional if the conditional branch is not B.AL, and prediction is on
    // Thumb in IT: indicated conditional if CC is not 'always' and prediction is on
    assign instr_a32_conditional[i]   = ~branch_never_taken_i & (pfb_instr_32[i][19:17] != 3'b111);
    assign instr_a64_conditional[i]   = ~branch_never_taken_i &  pfb_instr_32[i][39] & ~((pfb_instr_32[i][29:28] == 2'b10) & (pfb_instr_32[i][15:13] == 3'b111));
    assign instr_thumb_conditional[i] = ~branch_never_taken_i & it_block_i[i] & (it_cc[i][3:1] != 3'b111);

  end endgenerate

  // A32: uncond/predicted taken indicated taken prediction enabled
  assign instr_a32_taken[0]   = (~branch_never_taken_i & instr_is_a32_if3_i &
                                 ((pfb_instr_32[0][19:17] == 3'b111) | taken_if3[0]));
  assign instr_a32_taken[1]   = (~branch_never_taken_i &
                                 ((pfb_instr_32[1][19:17] == 3'b111) | taken_if3[1]));

  // Thumb: in unconditional IT, not in IT or predicted taken and prediction enabled
  assign instr_thumb_taken[0] = (~branch_never_taken_i & instr_is_thumb_if3_i &
                                 ((it_block_i[0] & (it_cc[0][3:1] == 3'b111)) | ~it_block_i[0] | taken_if3[0]));
  assign instr_thumb_taken[1] = (~branch_never_taken_i &
                                 ((it_block_i[1] & (it_cc[1][3:1] == 3'b111)) | ~it_block_i[1] | taken_if3[1]));

  // Thumb (not IT'able): predicion enabled and indicated taken
  assign instr_thumb_taken_no_it[0] = ~branch_never_taken_i & taken_if3[0];
  assign instr_thumb_taken_no_it[1] = ~branch_never_taken_i & taken_if3[1];

  // A64: prediction enabled and indicated taken for unconditional brach.  The
  // conditional branches are those that are not marked A64-only except
  // specifically B.AL.
  assign instr_a64_taken[0] = ~branch_never_taken_i & instr_is_a64_if3_i &
                              (~pfb_instr_32[0][39] | ((pfb_instr_32[0][29:28] == 2'b10) & (pfb_instr_32[0][15:13] == 3'b111)) | taken_if3[0]);
  assign instr_a64_taken[1] = ~branch_never_taken_i &
                              (~pfb_instr_32[1][39] | ((pfb_instr_32[1][29:28] == 2'b10) & (pfb_instr_32[1][15:13] == 3'b111)) | taken_if3[1]);

  // Early branch evaluation for use in the BTIC
  assign early_instr_taken[0] = (instr_a32_taken[0] | instr_a64_taken[0] |
                                (instr_is_thumb_if3_i & ~pfb_instr[0][39] &  pfb_instr[0][32]                      & instr_thumb_taken_no_it[0]) |
                                (instr_is_thumb_if3_i &  pfb_instr[0][39] & ~pfb_instr[0][14] & ~pfb_instr[0][12]  & instr_thumb_taken_no_it[0]) |
                                (                       ~pfb_instr[0][39] & ~pfb_instr[0][32]                      & instr_thumb_taken[0]      ) |
                                (                        pfb_instr[0][39] & (pfb_instr[0][14] |  pfb_instr[0][12]) & instr_thumb_taken[0]      ));
  assign early_instr_taken[1] = ((instr_is_a32_if3_i  &                                                              instr_a32_taken[1]        ) |
                                 (instr_is_a64_if3_i  &                                                              instr_a64_taken[1]        ) |
                                 (instr_is_thumb_if3_i & ~pfb_instr[1][39] &  pfb_instr[1][32]                      & instr_thumb_taken_no_it[1]) |
                                 (instr_is_thumb_if3_i &  pfb_instr[1][39] & ~pfb_instr[1][14] & ~pfb_instr[1][12]  & instr_thumb_taken_no_it[1]) |
                                 (instr_is_thumb_if3_i & ~pfb_instr[1][39] & ~pfb_instr[1][32]                      & instr_thumb_taken[1]      ) |
                                 (instr_is_thumb_if3_i &  pfb_instr[1][39] & (pfb_instr[1][14] |  pfb_instr[1][12]) & instr_thumb_taken[1]      ));

  // CPSR state
  assign a64_cpsr_state = cpsr_state_i == 2'b10;
  assign a32_cpsr_state = cpsr_state_i == 2'b00;

  //----------------------------------------------------------------------------
  // Sideband-only decode
  //----------------------------------------------------------------------------

  generate for (i=0; i<=1; i=i+1) begin : gen_sband_dec

    ca53ifu_pf_dec_branch_s32
      u_ca53ifu_pf_dec_branch_s32
        (// Inputs
         .pfb_instr_i             (pfb_instr[i][38:33]),
         // Outputs
         .s32_branch_o            (s32_branch[i]),
         .s32_br_direct_o         (s32_br_direct[i]),
         .s32_br_btac_o           (s32_br_btac[i]),
         .s32_br_return_o         (s32_br_return[i]),
         .s32_dual_slot0_o        (s32_dual_slot0[i])
        );

    // Generate branch and dual_slot0 signals that are qualified with the
    // instruction being a 32-bit instruction
    assign i32_branch[i]     = s32_branch[i]     & ~((cpsr_state_i == 2'b01) & ~pfb_instr[i][39]);
    assign i32_dual_slot0[i] = s32_dual_slot0[i] & ~((cpsr_state_i == 2'b01) & ~pfb_instr[i][39]);

  end endgenerate

  //----------------------------------------------------------------------------
  // A64 decode
  //----------------------------------------------------------------------------

  generate for (i=0; i<=1; i=i+1) begin: gen_dec_a64

    // A64 Branch direct decode:
    assign a64_br_direct[i] = (pfb_instr_32[i][38:33] == SB_B_IMM) |
                              (pfb_instr_32[i][38:33] == SB_CBZ);

    // Predicted branch indicated for any type of branch when conditional.  The
    // only conditional branches in A64 are from the direct branch group:
    //   B (cond), CB{N}Z, TBZ, TBNZ
    // However the B (cond) instruction is considered unconditional when the
    // condition code is AL.
    assign a64_br_predicted[i] = a64_cpsr_state & a64_br_direct[i] & instr_a64_conditional[i];

    // B, BL (imm) [direct branch group]
    // CBZ, CBNZ, TBZ, TBNZ [direct branch group]
    assign a64_br_btic[i]      = a64_cpsr_state & a64_br_direct[i];

    // B, BL (imm) [direct branch group]
    // CBZ, CBNZ, TBZ, TBNZ [direct branch group]
    // Indicated only when taken
    assign a64_br_imm[i]       = a64_cpsr_state & a64_br_direct[i] & instr_a64_taken[i];

    // Any branch type, indicated if taken
    assign a64_br_taken[i]     = a64_cpsr_state & s32_branch[i] & instr_a64_taken[i];

    // BL (imm) [direct branch group]
    // BLR [BTACable branch group]
    // Indicated only when taken
    assign a64_br_link[i]      = a64_cpsr_state &
                                 instr_a64_taken[i] &
                                 ((a64_br_direct[i] & ~pfb_instr_32[i][39] & pfb_instr_32[i][14]) |  // Direct branches
                                  (s32_br_btac[i]   &  pfb_instr_32[i][1]));                         // BTACable branches

    // B (cond), CB{N}Z: 4'b1010
    // TBZ, TBNZ:        4'b1011
    // B (uncond), BL:   4'b1001
    assign a64_br_offset_sel[i] = {4{a64_cpsr_state}} &
                                  (({4{( pfb_instr_32[i][39] &  pfb_instr_32[i][29])}} & 4'b1010) |  // B (cond), CB{N}Z : A64 only
                                   ({4{( pfb_instr_32[i][39] & ~pfb_instr_32[i][29])}} & 4'b1011) |  // TB{N}Z   : A64 only
                                   ({4{ ~pfb_instr_32[i][39]                        }} & 4'b1001));  // B, BL    : Not A64 only

    // BRK - decode by unique opcode when not undefined
    assign a64_brk[i]           = a64_cpsr_state                    & // A64 state
                                  ~pfb_instr_32[i][39]              & // Not a64_only
                                  (|pfb_instr_32[i][38:33])         & // Not undef
                                  (pfb_instr_32[i][32:31] == 2'b00) & // opcode[28:27] == 2'b00
                                  (pfb_instr_32[i][15: 8] == 8'hBE | (pfb_instr_32[i][15: 8] == 8'hBA & pfb_instr_32[i][7:6] == 2'b10));  // opcode BRK or HLT

  end endgenerate


  //----------------------------------------------------------------------------
  // A32 decode
  //----------------------------------------------------------------------------

  generate for (i=0; i<=1; i=i+1) begin: gen_dec_a32

    // Predicted branch indicated for any type of branch when conditional
    assign a32_br_predicted[i]  = a32_cpsr_state & instr_a32_conditional[i] & s32_branch[i];

    // BL, BLX (imm) [direct branch group]
    // BLX (reg) [BTACable branch group]
    assign a32_br_call[i]       = a32_cpsr_state &
                                  ((s32_br_direct[i] & (pfb_instr_32[i][39] |  pfb_instr_32[i][14])) |
                                   (s32_br_btac[i]   & ~pfb_instr_32[i][39] & ~pfb_instr_32[i][31]));

    // B, BL (imm) [direct branch group]
    assign a32_br_btic[i]       = a32_cpsr_state & s32_br_direct[i] & ~pfb_instr_32[i][39];

    // B, BL (imm), BLX (imm) [direct branch group]: indicated only if taken
    assign a32_br_imm[i]        = a32_cpsr_state & s32_br_direct[i] & instr_a32_taken[i];

    // Any branch (direct, BTAC, return), LS or DP type: indicated if taken
    assign a32_br_taken[i]      = a32_cpsr_state & s32_branch[i]    & instr_a32_taken[i];

    // As a32_br_call but only indicated if taken
    assign a32_br_link[i]       = a32_br_call[i] & instr_a32_taken[i];

    // BLX (imm) [direct branch group], only indicated if taken
    assign a32_br_blx[i]        = a32_cpsr_state & s32_br_direct[i] & instr_a32_taken[i] & pfb_instr_32[i][39];

    // B, BL (imm): 4'b0101
    // BLX (imm)  : 4'b0111
    // others     : 4'b0000
    assign a32_br_offset_sel[i] = {4{a32_cpsr_state}} &
                                  (pfb_instr_32[i][39] ? 4'b0111 : 4'b0101);

    // BKPT
    assign a32_bkpt[i]          = a32_cpsr_state                      &
                                  ~pfb_instr_32[i][39]                &
                                  (pfb_instr_32[i][38:33] == SB_BKPT) &
                                  ~pfb_instr_32[i][31]                &
                                  ~pfb_instr_32[i][14]                &
                                   pfb_instr_32[i][12]                &
                                   pfb_instr_32[i][11];

  end endgenerate


  //----------------------------------------------------------------------------
  // T32 decode
  //----------------------------------------------------------------------------

  generate for (i=0; i<=1; i=i+1) begin : gen_dec_t32

    // CPSR state
    assign t32_cpsr_state[i]     = cpsr_state_i == 2'b01 & pfb_instr[i][39];

    // B (T3 encoding)
    assign t32_br_direct_t3[i]   = (pfb_instr[i][38:33] == SB_B_IMM) & ~pfb_instr[i][14] & ~pfb_instr[i][12];
    assign t32_br_t3[i]          = t32_cpsr_state[i] & t32_br_direct_t3[i];
    assign t32_br_t_cond[i]      = t32_br_t3[i];

    // B, BL, BL, BLX, CB{N}Z direct (non-T3 encoding)
    assign t32_br_direct_not3[i] = ((pfb_instr[i][38:33] == SB_B_IMM) & (pfb_instr[i][14] |  pfb_instr[i][12])) |
                                   ( pfb_instr[i][38:33] == SB_CBZ_DIR);

    // BTAC or Return branch
    assign t32_br_btac_return[i] = (// BTAC : LDR
                                    (pfb_instr[i][38:33] == SB_LDR_BTAC)    |
                                    // BTAC : LDR (PC)
                                    (pfb_instr[i][38:33] == SB_LDR_PC_BTAC) |
                                    // BLX (reg)
                                    (pfb_instr[i][38:33] == SB_BLX_BTAC)    |
                                    // TBB / TBH
                                    (pfb_instr[i][38:33] == SB_TB_BTAC)     |
                                    // Pop PC
                                    (pfb_instr[i][38:33] == SB_POP)         |
                                    // BX
                                    (pfb_instr[i][38:33] == SB_BX));

    // B, BL, BLX
    assign t32_br_b_bl_blx[i]    = (pfb_instr[i][38:33] == SB_B_IMM);

    // B (T3) [direct branch group]: indicated except when never taken
    // B (T4) [direct branch group]: indicated when conditional
    // BTAC/Return: indicated when conditional
    assign t32_br_predicted[i]   = (// Direct group:
                                    //   - B(T3) which is always predicted
                                    (t32_cpsr_state[i] & t32_br_direct_t3[i]   & ~branch_never_taken_i) |
                                    // Direct group:
                                    //   - B (T4), BL (imm), BLX (imm), CB{N}Z
                                    (t32_cpsr_state[i] & t32_br_direct_not3[i] & instr_thumb_conditional[i]) |
                                    // BTAC/return group
                                    (t32_cpsr_state[i] & t32_br_btac_return[i] & instr_thumb_conditional[i]));

    // BL, BLX (imm) [direct branch group]
    assign t32_br_call[i]        = t32_cpsr_state[i] & t32_br_b_bl_blx[i] & pfb_instr[i][14];

    // B (T3/T4), BL (imm) [direct branch group]
    assign t32_br_btic[i]        = t32_cpsr_state[i] & t32_br_b_bl_blx[i] & ~(pfb_instr[i][14] & ~pfb_instr[i][12]);

    // B (T4), BL (imm), BLX (imm) [direct branch group]: indicated only if taken
    // B (T3) [direct branch group]: indicated if not in IT and branches are being predicted
    assign t32_br_imm[i]         = ((t32_cpsr_state[i] & t32_br_direct_t3[i]   & instr_thumb_taken_no_it[i]) |
                                    (t32_cpsr_state[i] & t32_br_direct_not3[i] & instr_thumb_taken[i]));

    // B (T4), BL (imm), BLX (imm) [direct branch group]: indicated only if taken
    // B (T3) [direct branch group]: indicated if not in IT and branches are being predicted
    // BTAC/Return: indicated only if taken
    assign t32_br_taken[i]       = (// Direct group:
                                    //   - B(T3) which is always predicted
                                    (t32_cpsr_state[i] & t32_br_direct_t3[i]   & instr_thumb_taken_no_it[i]) |
                                    // Direct group:
                                    //   - B (T4), BL (imm), BLX (imm), CB{N}Z
                                    (t32_cpsr_state[i] & t32_br_direct_not3[i] & instr_thumb_taken[i]) |
                                    // BTAC/return group
                                    (t32_cpsr_state[i] & t32_br_btac_return[i] & instr_thumb_taken[i]));

    // As t32_br_call but only indicated if taken
    assign t32_br_link[i]        = t32_br_call[i] & instr_thumb_taken[i];

    // BLX (imm) [direct branch group], indicated only if taken
    assign t32_br_blx[i]         = t32_cpsr_state[i] &
                                   t32_br_b_bl_blx[i] & instr_thumb_taken[i] &
                                   pfb_instr[i][14] & ~pfb_instr[i][12];

    // B (T3)    : 4'b0011
    // B (T4), BL: 4'b0100
    // BLX (imm) : 4'b0110
    assign t32_br_offset_sel[i] = {4{t32_cpsr_state[i]}} &
                                  (({4{(~pfb_instr[i][14] & ~pfb_instr[i][12])}} & 4'b0011) |
                                   ({4{(~pfb_instr[i][14] &  pfb_instr[i][12])}} & 4'b0100) |
                                   ({4{( pfb_instr[i][14] & ~pfb_instr[i][12])}} & 4'b0110) |
                                   ({4{( pfb_instr[i][14] &  pfb_instr[i][12])}} & 4'b0100));

  end endgenerate


  //----------------------------------------------------------------------------
  // T16 decode
  //----------------------------------------------------------------------------

  generate for (i=0; i<=1; i=i+1) begin : gen_dec_t16

    // CPSR state
    assign t16_cpsr_state[i]     = cpsr_state_i == 2'b01 & ~pfb_instr[i][39];

    // B (cond), B (imm), CBZ [direct branch group]
    // BX (reg), BLX (reg), POP PC [indirect branch group]
    assign t16_branch[i]         = t16_cpsr_state[i] & (pfb_instr[i][38:37] == 2'b01);

    // BLX (reg) [indirect branch group]
    assign t16_br_btac[i]        = t16_cpsr_state[i] &
                                   (pfb_instr[i][38:36] == 3'b011)             &
                                   ~pfb_instr[i][35] & pfb_instr[i][27]; // Exclude BX (reg) and POP PC

    // BX (reg), POP PC [indirect branch group]
    assign t16_br_return[i]      = t16_cpsr_state[i] &
                                    (pfb_instr[i][38:36] == 3'b011)               &
                                    instr_thumb_taken[i]                          &
                                    (pfb_instr[i][33] | ~pfb_instr[i][27]);

    // B (cond), CBZ   [direct branch group]   : (never in IT), indicated except when never taken
    // B (imm)         [direct branch group]   : indicated when conditional
    // BLX, BX, POP PC [indirect branch group] : indicated when conditional
    assign t16_br_predicted[i]   = t16_branch[i] &
                                   (// Direct branch group
                                    (~pfb_instr[i][36] & (( pfb_instr[i][32] & ~branch_never_taken_i)        |  // B (cond), CBZ always predicted
                                                          (~pfb_instr[i][32] & instr_thumb_conditional[i]))) |  // B (imm) if in IT
                                    // Indirect branch group
                                    ( pfb_instr[i][36] & instr_thumb_conditional[i]));

    // B (cond), B (imm), CBZ/CBNZ [all direct branches]
    assign t16_br_btic[i]        = t16_cpsr_state[i] & (pfb_instr[i][38:36] == 3'b010);

    // B (cond), CBZ   [direct branch group]   : (never in IT), indicated when pred enabled and pred taken
    // B (imm)         [direct branch group]   : indicated when pred enabled, in IT, pred taken
    // BLX, BX, POP PC [indirect branch group] : indicated when pred enabled, in IT, pred taken
    assign t16_br_taken[i]       = t16_branch[i] &
                                   (// Direct branch group
                                    (~pfb_instr[i][36] & (( pfb_instr[i][32] & instr_thumb_taken_no_it[i])  | // B (cond), CBZ
                                                          (~pfb_instr[i][32] & instr_thumb_taken[i])))      | // B (imm)
                                    // Indirect branch group
                                    ( pfb_instr[i][36] & instr_thumb_taken[i]));

    // BLX (reg) [indirect branch group]
    assign t16_br_link[i]        = t16_br_btac[i] & instr_thumb_taken[i];

    // IT instruction, directly from sideband
    assign instr_is_it[i]        = t16_cpsr_state[i] & (pfb_instr[i][38:36] == 3'b100);

    // Dual-issue slot 0, directly from sideband
    assign t16_dual_slot0[i]     = t16_cpsr_state[i] & ((pfb_instr[i][38:36] == 3'b001) | // Normal, D0 dual issuable
                                                        (pfb_instr[i][38:36] == 3'b010)); // Direct branch (implicitly D0)

    // Direct branches are all immediate, indicated when branch taken
    assign t16_br_imm[i]         = t16_branch[i] & ~pfb_instr[i][36] &
                                   (( pfb_instr[i][32] & instr_thumb_taken_no_it[i]) | // B (cond), CBZ
                                    (~pfb_instr[i][32] & instr_thumb_taken[i]));       // B (imm)

    // B<cond> (T1), CBNZ/CBZ
    assign t16_br_t_cond[i]      = t16_cpsr_state[i] & (pfb_instr[i][38:36] == 3'b010) & pfb_instr[i][32];

    // BKPT, decoded from sideband bits
    assign t16_bkpt[i]           = t16_cpsr_state[i] & (pfb_instr[i][38:36] == 3'b101);

    // B (T1)    : 4'b0001
    // B (T2), BL: 4'b0010
    // CBZ/CBNZ  : 4'b1000
    //
    // NB. only perform minimum decode required for listed instructions as this
    // is qualified with instrX_brn_imm where used
    assign t16_br_offset_sel[i] = {4{t16_cpsr_state[i]}} &
                                  (({4{( pfb_instr[i][34] & ~pfb_instr[i][33])}} & 4'b0001) |
                                   ({4{( pfb_instr[i][34] &  pfb_instr[i][33])}} & 4'b0010) |
                                   ({4{(~pfb_instr[i][34] &  pfb_instr[i][33])}} & 4'b1000));

  end endgenerate


  //----------------------------------------------------------------------------
  // Dual-issue from slot 1
  //----------------------------------------------------------------------------

  // Instr-0
  ca53ifu_pf_dec_d1
    u_ca53ifu_pf_dec_d1_instr0
      (// Inputs
       .instr_if3_i                   (instr0_if3_i[39:0]),
       .cpsr_state_i                  (cpsr_state_i),
       // Outputs
       .instr_is_d1_o                 (instr_dual_slot1[0])
      );

  // Instr-1
  ca53ifu_pf_dec_d1
    u_ca53ifu_pf_dec_d1_instr1
      (// Inputs
       .instr_if3_i                   (instr1_if3_i[39:0]),
       .cpsr_state_i                  (cpsr_state_i),
       // Outputs
       .instr_is_d1_o                 (instr_dual_slot1[1])
      );


  //----------------------------------------------------------------------------
  // Combined decoder outputs
  //----------------------------------------------------------------------------

  // Suppress the Instr-1 predicted branch indication when Instr-1 is not valid.
  // Otherwise the Instr-0 and Instr-1 decoder outputs can be combined in the
  // same way.
  generate for (i=0; i<=1; i=i+1) begin : gen_comb_dec
    wire [3:0] br_offset_sel;

    // Overall decoder outputs, combined from decoders for each ISA
    assign instr_brn_predicted_if3[i] = a64_br_predicted[i] | a32_br_predicted[i] | t32_br_predicted[i] | t16_br_predicted[i];
    assign instr_brn_taken_if3[i]     = a64_br_taken[i]     | a32_br_taken[i]     | t32_br_taken[i]     | t16_br_taken[i];
    assign instr_brn_imm_if3[i]       = a64_br_imm[i]       | a32_br_imm[i]       | t32_br_imm[i]       | t16_br_imm[i];
    assign instr_brn_link_if3[i]      = a64_br_link[i]      | a32_br_link[i]      | t32_br_link[i]      | t16_br_link[i];
    assign instr_brn[i]               = i32_branch[i]                                                   | t16_branch[i];
    assign instr_dual_slot0[i]        = i32_dual_slot0[i]                                               | t16_dual_slot0[i];
    assign instr_sw_bkpt[i]           = a64_brk[i]          | a32_bkpt[i]                               | t16_bkpt[i];

    // Combine offset selects
    assign br_offset_sel = a64_br_offset_sel[i] | a32_br_offset_sel[i] | t32_br_offset_sel[i] | t16_br_offset_sel[i];

    // Extract immediate branch offsets from instruction encoding
    always @*
      case (br_offset_sel[3:0])
        4'b0000 : instr_br_offset[i] = {27{1'b0}};
        // B, T1 Variant
        4'b0001 : instr_br_offset[i] = {{19{pfb_instr[i][27]}}, pfb_instr[i][27:20]};
        // B, T2 Variant
        4'b0010 : instr_br_offset[i] = {{16{pfb_instr[i][30]}}, pfb_instr[i][30:20]};
        // B, T3 Variant
        4'b0011 : instr_br_offset[i] = {{8{pfb_instr[i][30]}},
                                           pfb_instr[i][11],
                                           pfb_instr[i][13],
                                           pfb_instr[i][25:20],
                                           pfb_instr[i][10:0]};
        // B, T4 Variant & BL (imm) T1 Variant
        4'b0100 : instr_br_offset[i] = {{4{pfb_instr[i][30]}},
                                        ~(pfb_instr[i][13] ^ pfb_instr[i][30]),
                                        ~(pfb_instr[i][11] ^ pfb_instr[i][30]),
                                        pfb_instr[i][29:20],
                                        pfb_instr[i][10:0]};
        // B, A1 Variant & BL (imm) A1 Variant
        4'b0101 : instr_br_offset[i] = {{3{pfb_instr_32[i][30]}},
                                        ~(pfb_instr_32[i][13] ^ pfb_instr_32[i][30]),
                                        ~(pfb_instr_32[i][11] ^ pfb_instr_32[i][30]),
                                        pfb_instr_32[i][29:20],
                                        pfb_instr_32[i][10:0],
                                        1'b0};
        // BLX (imm), T2 Variant
        4'b0110 : instr_br_offset[i] = {{4{pfb_instr[i][30]}},
                                        ~(pfb_instr[i][13] ^ pfb_instr[i][30]),
                                        ~(pfb_instr[i][11] ^ pfb_instr[i][30]),
                                        pfb_instr[i][29:20],
                                        pfb_instr[i][10:1],
                                        1'b0};
        // BLX (imm), A2 Variant
        4'b0111 : instr_br_offset[i] = {{2{pfb_instr_32[i][27]}}, pfb_instr_32[i][27:20], pfb_instr_32[i][15:0], pfb_instr_32[i][28]};
        // CBZ/CBNZ, T1 Variant
        4'b1000 : instr_br_offset[i] = {{21{1'b0}}, pfb_instr[i][29], pfb_instr[i][27:23]};
        // A64 B (unconditional) & BL.
        4'b1001 : instr_br_offset[i] = {pfb_instr_32[i][18:17],  // Re-use CC bits
                                        pfb_instr_32[i][30],     // S
                                        pfb_instr_32[i][13],     // J1
                                        pfb_instr_32[i][11],     // J2
                                        pfb_instr_32[i][29:20],  // imm10
                                        pfb_instr_32[i][10:0],   // imm11
                                        1'b0};
        // B (cond), CBZ/CBNZ, A64 variant
        4'b1010 : instr_br_offset[i] = {{7{pfb_instr[i][26]}}, pfb_instr[i][26:20], pfb_instr[i][11:0], 1'b0};
        // TBZ/TBNZ, A64
        4'b1011 : instr_br_offset[i] = {{12{pfb_instr_32[i][21]}}, pfb_instr_32[i][21:20], pfb_instr_32[i][11:0], 1'b0};
        default : instr_br_offset[i] = {27{1'bx}};
      endcase
  end endgenerate


  //----------------------------------------------------------------------------
  // Instruction 0/1 check
  //----------------------------------------------------------------------------

  // Instruction 1 is allowed to be pushed into the DPU IQ with instruction 0 when:
  // - Instruction 0 is not an enterx, leavex or IT
  // - Instruction 0 or 1 is not an abort, vector catch or a hardware/software breakpoint
  // - Instruction 0 is not a taken branch (by definition this includes all non-branch instructions)
  // - Instructions 0 and 1 are not both branches (because the branch predictor
  //   can only predict one branch in a cycle.)
  assign instr1_possible_o = (~instr_is_it[0] &
                              ~instr_sw_bkpt[0] &
                              ~instr_sw_bkpt[1] &
                              ~instr_abt_if3_i[0] &
                              ~instr_abt_if3_i[1] &
                              ~instr_pty_if3_i[0] &
                              ~instr_pty_if3_i[1] &
                              ~instr_vcr_if3_i[0] &
                              ~instr_vcr_if3_i[1] &
                              ~instr_hw_bkpt_if3_i[0] &
                              ~instr_hw_bkpt_if3_i[1] &
                              ~instr_expt_catch_if3_i &
                              ~instr_rst_catch_if3_i &
                              // Branch terms
                              ~instr_brn_taken_if3[0] &
                              ~(instr_brn[0] & instr_brn[1]));

  // Early indication that Instruction 1 is allowed to be pushed to the DPU.  This is the same
  // as the more complete signal above, with the branch determination logic removed.
  assign early_instr1_possible_o = (~instr_is_it[0] &
                                    ~instr_sw_bkpt[0] &
                                    ~instr_sw_bkpt[1] &
                                    ~instr_abt_if3_i[0] &
                                    ~instr_abt_if3_i[1] &
                                    ~instr_pty_if3_i[0] &
                                    ~instr_pty_if3_i[1] &
                                    ~instr_vcr_if3_i[0] &
                                    ~instr_vcr_if3_i[1] &
                                    ~instr_hw_bkpt_if3_i[0] &
                                    ~instr_hw_bkpt_if3_i[1] &
                                    ~instr_expt_catch_if3_i &
                                    ~instr_rst_catch_if3_i);

  //----------------------------------------------------------------------------
  // Output signals
  //----------------------------------------------------------------------------

  // Outputs qualified with valid instruction indicator
  assign instr0_brn_o               = instr_brn[0];
  assign instr0_brn_imm_if3_o       = instr_valid_if3_i[0] & instr_brn_imm_if3[0];
  assign instr0_brn_offset_if3_o    = instr_br_offset[0];
  assign instr1_brn_imm_if3_o       = instr_valid_if3_i[1] & instr_brn_imm_if3[1];
  assign instr1_brn_offset_if3_o    = instr_br_offset[1];
  assign instr_brn_exchange_a_if3_o = instr_valid_if3_i[1:0] & a32_br_blx[1:0];
  assign instr_brn_exchange_t_if3_o = instr_valid_if3_i[1:0] & t32_br_blx[1:0];

  // Unqualified outputs
  assign early_instr_taken_o        = early_instr_taken[1:0];
  assign brn_predicted_if3_o        = instr_brn_predicted_if3[1:0];
  assign instr_brn_taken_if3_o      = instr_brn_taken_if3[1:0];
  assign instr_brn_btic_o           = a64_br_btic[1:0] | a32_br_btic[1:0] | t32_br_btic[1:0] | t16_br_btic[1:0];
  assign instr_brn_t_cond_if3_o     = t32_br_t_cond[1:0] | t16_br_t_cond[1:0];
  assign instr_brn_t3_if3_o         = t32_br_t3[1:0];
  assign instr_brn_link_if3_o       = instr_brn_link_if3[1:0];
  assign instr_dual_slot0_o         = instr_dual_slot0[1:0];
  assign instr_dual_slot1_o         = instr_dual_slot1[1:0];
  assign instr_it_if3_o             = instr_is_it[1:0];
  assign instr_sw_bkpt_if3_o        = instr_sw_bkpt[0];

  assign s32_btac_if3_o             = s32_br_btac[1:0];
  assign s32_return_if3_o           = s32_br_return[1:0];
  assign t16_btac_if3_o             = t16_br_btac[1:0];
  assign t16_return_if3_o           = t16_br_return[1:0];
  assign spec_btac_if3_o            = t16_br_btac[1:0] | (~t16_cpsr_state[1:0] & s32_br_btac[1:0]);

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/

