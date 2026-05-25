//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
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
// Abstract : Branch Target Instruction Cache
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_btic (
  // Inputs
  input wire         clk,
  input wire         reset_n,
  input wire         btic_disable_i,
  input wire         DFTSE,
  input wire         dpu_iq_full_i,
  input wire         dpu_iq_part_full_i,
  input wire         dpu_pred_br_wr_i,
  input wire         dpu_fe_valid_ret_i,
  input wire [48:1]  abuf_va_if3_i,
  input wire [48:3]  bbuf_va_if3_i,
  input wire [48:1]  va_instr1_if3_i,
  input wire         valid_if2_i,
  input wire         avalid_if3_i,
  input wire         bvalid_if3_i,
  input wire [ 1:0]  abuf_state_if3_i,
  input wire [ 3:0]  abuf_bkpt_if3_i,
  input wire [ 3:0]  bbuf_bkpt_if3_i,
  input wire [ 1:0]  abuf_vcr_if3_i,
  input wire [ 1:0]  bbuf_vcr_if3_i,
  input wire         abuf_abt_if3_i,
  input wire         bbuf_abt_if3_i,
  input wire         instr_sw_bkpt_if3_i,
  input wire [ 1:0]  instr_valid_if3_i,
  input wire         instr_is_a32_if3_i,
  input wire         instr_is_a64_if3_i,
  input wire         instr_is_thumb_if3_i,
  input wire [1:0]   instr_pty_if3_i,
  input wire [79:0]  abuf_if3_i,
  input wire [79:0]  bbuf_if3_i,
  input wire         icb_hit_if2_i,
  input wire         icb_lfb_hit_if2_i,
  input wire         tlb_hit_if2_i,
  input wire [ 1:0]  early_instr_taken_i,
  input wire [ 1:0]  instr_brn_btic_i,
  input wire         instr0_brn_i,
  input wire         instr0_opcode_err_i,
  input wire         instr1_opcode_err_i,
  input wire         instr1_possible_i,
  input wire         spec_instr0_t32_i,
  input wire         dpu_pfu_force_i,
  input wire         force_if0_i,
  input wire         icb_flush_btic_i,
  input wire         icb_cacheable_if2_i,
  input wire         dpu_flush_i_utlb_i,
  input wire         tlb_i_utlb_flush_i,
  input wire         hyp_mode_if1_i,
  input wire         hyp_mode_if2_i,
  input wire         in_debug_or_wfx_i,
  // Outputs
  output wire        btic_hit_if3_o,
  output wire [79:0] btic_abuf_if3_o,
  output wire [79:0] btic_bbuf_if3_o,
  output wire        btic_bbuf_valid_if3_o,
  output wire [48:1] btic_abuf_va_if3_o,
  output wire [48:3] btic_bbuf_va_if3_o,
  output wire [12:3] btic_cbuf_va_if3_o,
  output wire [48:3] btic_target_va_if2_o);

  //----------------------------------------------------------------------------
  // Constants
  //----------------------------------------------------------------------------

  localparam [1:0] CA53_BTIC_IDLE      = 2'b00;
  localparam [1:0] CA53_BTIC_A_PENDING = 2'b01;
  localparam [1:0] CA53_BTIC_B_PENDING = 2'b10;
  localparam [1:0] CA53_BTIC_FLUSH     = 2'b11;

  localparam integer SUPP_CNT   = 16;
  localparam integer SUPP_CNT_W = `CA53_LOG2(SUPP_CNT);


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  wire        nxt_btic_clock_sva_en;
  wire        nxt_btic_clock_tva_en;
  reg         btic_clock_sva_en;
  reg         btic_clock_tva_en;
  wire        clk_btic_sva;
  wire        clk_btic_tva;

  reg         btic_flush;
  reg   [1:0] btic_update_state;
  reg         hit_last_cycle;
  reg         pred_br_ret;
  wire        nxt_hit_last_cycle;
  wire        nxt_btic_flush;
  wire        start_alloc;
  reg   [1:0] nxt_btic_update_state;
  reg         nxt_btic_abuf_valid;
  reg         nxt_btic_bbuf_valid;
  reg         en_btic_abuf_valid;
  reg         en_btic_bbuf_valid;
  reg         en_btic_abuf;
  reg         en_btic_bbuf;
  reg         en_btic_va;
  wire [48:1] nxt_btic_va;
  wire [79:0] nxt_btic_bbuf;

  reg  [48:1] btic_source_va;
  reg         btic_abuf_valid;
  reg  [79:0] btic_abuf;
  reg  [48:1] btic_target_va;
  reg   [1:0] btic_isa_state;
  reg         btic_bbuf_valid;
  reg  [79:0] btic_bbuf;

  wire        i0_valid;
  wire        i1_valid;

  wire        btic_match_isa;
  wire        btic_match_abuf;
  wire        btic_match_bbuf;
  wire        btic_match_i0;
  wire        btic_source_va_00;
  wire        btic_source_va_01;
  wire        btic_source_va_10;
  wire        btic_source_va_11;
  reg   [2:0] btic_abuf_spec_match;
  reg   [2:0] btic_bbuf_spec_match;
  wire        btic_match_i1;
  wire        btic_match_if3;
  wire        btic_early_match_i0_if3;
  wire        btic_early_match_i1_if3;
  wire        btic_match_i0_if3;
  wire        btic_match_i1_if3;

  reg  [(SUPP_CNT_W-1):0] btic_supp_cnt;
  wire [(SUPP_CNT_W-1):0] nxt_btic_supp_cnt;
  wire                    btic_supp_cnt_we;
  wire                    btic_supp_start;
  reg                     supp_alloc;


  //----------------------------------------------------------------------------
  // Intermediate clock gate
  //----------------------------------------------------------------------------

  // The majority of the BTIC can be architecturally clock gated using an intermediate clock gate
  // o sva icg is used to clock the allocation of the source va
  // o tva ucg is used to clock the allocation of the target va,abuf and bbuf
  assign nxt_btic_clock_sva_en = (valid_if2_i | avalid_if3_i);
  assign nxt_btic_clock_tva_en = (btic_update_state[1:0] == CA53_BTIC_A_PENDING) |
                                 (btic_update_state[1:0] == CA53_BTIC_B_PENDING);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      btic_clock_sva_en <= 1'b0;
      btic_clock_tva_en <= 1'b0;
    end else begin
      btic_clock_sva_en <= nxt_btic_clock_sva_en;
      btic_clock_tva_en <= nxt_btic_clock_tva_en;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_btic_sva (.clk_i         (clk),
                                                    .clk_enable_i  (btic_clock_sva_en),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_btic_sva));

  ca53_cell_inter_clkgate u_inter_clkgate_btic_tva (.clk_i         (clk),
                                                    .clk_enable_i  (btic_clock_tva_en),
                                                    .clk_senable_i (DFTSE),
                                                    .clk_gated_o   (clk_btic_tva));


  //----------------------------------------------------------------------------
  // BTIC allocation state machine
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      btic_flush        <= 1'b0;
      btic_update_state <= 2'b00;
      hit_last_cycle    <= 1'b0;
      pred_br_ret       <= 1'b0;
    end else begin
      btic_flush        <= nxt_btic_flush;
      btic_update_state <= nxt_btic_update_state;
      hit_last_cycle    <= nxt_hit_last_cycle;
      pred_br_ret       <= dpu_pred_br_wr_i;
    end

  // The instruction cache hit signal comes late which makes it difficult to avoid critical paths
  // through the state machine.  So once the A-buffer is written enable the B-buffer and compute
  // valid based on a registered hit.
  assign nxt_hit_last_cycle = (icb_hit_if2_i & tlb_hit_if2_i) | icb_lfb_hit_if2_i;

  // The BTIC must be flushed under the following conditions:
  //   - Instruction cache maintenance operation in the ICU
  //   - DPU or TLB micro-TLB flush
  //   - Abort (any kind)
  //   - Breakpoint or vector catch
  //   - ISB/Exception Return
  //   - Entry/Exit from HYP mode
  //
  // The flush from the DPU/TLB not only copes with page mapping changes, but also security
  // state changes.
  //
  // Any kind of abort, breakpoint or vector catch will flush the BTIC once placed in to the FQ.
  // This is overkill (for abort), but it is easier than trying to factor the abort signal in to
  // individual entries and deal with corner cases.  Breakpoint and vector catch would clear the
  // BTIC anyway once they reached the end of the DPU pipeline and took an exception.
  //
  // The ISB/Exception Return case is needed in case there is a change to the debug permissions
  // as it could be that the virtual address contained in the BTIC should trigger a breakpoint
  // match, but won't because we skip that address when inserting the BTIC contents directly in
  // to the fetch queue.  Because of how this is signalled, a non-predicted branch that forces
  // from the Ret stage will also flush the BTIC (e.g. MOV r15 as we don't predict this).
  //
  // The HYP mode flush is required since the micro-TLB is not flushed on entry/exit from HYP
  // mode (since it can't incorrectly match on HYP mode).  As the VA-to-PA translation changes,
  // the target address will be different causing the BTIC to break if we don't flush it.
  //
  // Because any flush to the BTIC will either be imprecise or will flush the entire pipeline of
  // instructions we don't need to flush the BTIC immediately, but can wait a cycle as any new
  // fetches will take three cycles after the force become valid in Fe2.  The term imprecise
  // refers to an operation like an instruction cache maintenance operation or TLB flush which
  // will not acompany a force from the DPU that cleans out the entire pipeline.
  assign nxt_btic_flush = (icb_flush_btic_i    |
                           dpu_flush_i_utlb_i  |
                           tlb_i_utlb_flush_i  |
                           (|instr_pty_if3_i)  |
                           (((|abuf_bkpt_if3_i[3:0]) | (|abuf_vcr_if3_i[1:0]) | abuf_abt_if3_i | instr_sw_bkpt_if3_i) & avalid_if3_i) |
                           (((|bbuf_bkpt_if3_i[3:0]) | (|bbuf_vcr_if3_i[1:0]) | bbuf_abt_if3_i                      ) & bvalid_if3_i) |
                           (~pred_br_ret & dpu_fe_valid_ret_i) |
                           (hyp_mode_if1_i ^ hyp_mode_if2_i));


  // Start the allocation state machine.  An allocation is prevented if:
  // - The BTIC is disabled (for example if the MMU is off)
  // - There is a force in the same cycle as an allocation could occur
  // - The DPU IQ is part full so there is less performance/power benefit from allocating a new entry
  // - A BTIC entry has been hit
  // - There is a debug or Wait for Interrupt/Event condition
  // - There is an abort in the A-buffer
  //
  // If there is a direct branch in instr-1, but an indirect branch in instr-0 allocation must be
  // prevented.
  //
  // We hold off allocation if there is a pre-decode error.
  assign start_alloc = (~btic_disable_i & ~dpu_pfu_force_i & ~dpu_iq_part_full_i & ~in_debug_or_wfx_i & ~abuf_abt_if3_i &
                        ((instr_valid_if3_i[0] & instr_brn_btic_i[0] & early_instr_taken_i[0] & ~btic_early_match_i0_if3 & ~instr0_opcode_err_i) |
                         (instr_valid_if3_i[1] & instr_brn_btic_i[1] & early_instr_taken_i[1] & ~btic_early_match_i1_if3 & ~instr0_opcode_err_i &
                          ~instr0_brn_i & ~instr1_opcode_err_i & instr1_possible_i)) &
                        (btic_supp_cnt == {SUPP_CNT_W{1'b0}}));

  // Suppression.  We suppress an allocations to the BTIC if any allocation or
  // hit has occurred in the last 16 cycles.  This is to prevent close-together
  // branches (e.g. in tight loops) from causing the BTIC to constantly swap and
  // never hit.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      btic_supp_cnt <= {SUPP_CNT_W{1'b0}};
    else if (btic_supp_cnt_we)
      btic_supp_cnt <= nxt_btic_supp_cnt;

  assign btic_supp_start   = supp_alloc | btic_match_i0_if3 | btic_match_i1_if3;
  assign btic_supp_cnt_we  = btic_supp_start | (btic_supp_cnt != {SUPP_CNT_W{1'b0}});
  assign nxt_btic_supp_cnt = btic_supp_start ? {SUPP_CNT_W{1'b1}} : (btic_supp_cnt - 1'b1);


  // BTIC allocation state machine
  //
  // The transitions are self-explanatory.  However if there is a BTIC flush we move to the dedicated
  // BTIC flush state and clear the contents.
  //
  // If the fetch that comes back from the ICU is marked as non-cacheable then do not allocate the
  // fetch in to the BTIC entry buffer.  If the first fetch is non-cacheable then the entry won't
  // even become valid.  If the first fetch is cacheable, but the second entry is not then only the
  // first entry will be cacheable.
  always @*
    begin
      nxt_btic_update_state = CA53_BTIC_IDLE;
      nxt_btic_abuf_valid   = 1'b0;
      nxt_btic_bbuf_valid   = 1'b0;
      en_btic_abuf_valid    = 1'b0;
      en_btic_bbuf_valid    = 1'b0;
      en_btic_abuf          = 1'b0;
      en_btic_bbuf          = 1'b0;
      en_btic_va            = 1'b0;
      supp_alloc            = 1'b0;

      case (btic_update_state[1:0])
        CA53_BTIC_IDLE : begin
          nxt_btic_update_state = btic_flush  ? CA53_BTIC_FLUSH     :
                                  start_alloc ? CA53_BTIC_A_PENDING : CA53_BTIC_IDLE;
          nxt_btic_abuf_valid   = start_alloc ? 1'b0                : btic_abuf_valid;
          nxt_btic_bbuf_valid   = start_alloc ? 1'b0                : btic_bbuf_valid;
          en_btic_abuf_valid    = start_alloc;
          en_btic_bbuf_valid    = start_alloc;
          en_btic_va            = start_alloc;
          supp_alloc            = start_alloc & ~btic_flush;
        end

        CA53_BTIC_A_PENDING : begin
          nxt_btic_update_state = btic_flush                           ? CA53_BTIC_FLUSH     :
                                  (~icb_cacheable_if2_i | force_if0_i) ? CA53_BTIC_IDLE      :
                                  avalid_if3_i                         ? CA53_BTIC_B_PENDING : CA53_BTIC_A_PENDING;
          nxt_btic_abuf_valid   = avalid_if3_i;
          en_btic_abuf_valid    = avalid_if3_i;
          en_btic_abuf          = avalid_if3_i;
        end

        CA53_BTIC_B_PENDING : begin
          nxt_btic_update_state = btic_flush                                            ? CA53_BTIC_FLUSH :
                                  (~icb_cacheable_if2_i | force_if0_i | hit_last_cycle) ? CA53_BTIC_IDLE  : CA53_BTIC_B_PENDING;
          nxt_btic_bbuf_valid   = hit_last_cycle & avalid_if3_i;
          en_btic_bbuf_valid    = hit_last_cycle & avalid_if3_i;
          en_btic_bbuf          = hit_last_cycle & avalid_if3_i;
        end

        CA53_BTIC_FLUSH : begin
          nxt_btic_update_state = CA53_BTIC_IDLE;
          nxt_btic_abuf_valid   = 1'b0;
          nxt_btic_bbuf_valid   = 1'b0;
          en_btic_abuf_valid    = 1'b1;
          en_btic_bbuf_valid    = 1'b1;
        end

        default : begin
          nxt_btic_update_state = 2'bxx;
          nxt_btic_abuf_valid   = 1'bx;
          nxt_btic_bbuf_valid   = 1'bx;
          en_btic_abuf_valid    = 1'bx;
          en_btic_bbuf_valid    = 1'bx;
          en_btic_abuf          = 1'bx;
          en_btic_bbuf          = 1'bx;
          en_btic_va            = 1'bx;
        end
      endcase
    end

  assign nxt_btic_va = instr_brn_btic_i[0] ? abuf_va_if3_i : va_instr1_if3_i;

  // The source for the abuf entry of the BTIC always comes from the abuf entry
  // in the fetch queue.  The source for the bbuf entry in the BTIC may come
  // from the abuf or the bbuf.
  assign nxt_btic_bbuf = bvalid_if3_i ? bbuf_if3_i : abuf_if3_i;


  //----------------------------------------------------------------------------
  // BTIC entry state
  //----------------------------------------------------------------------------

  always @ (posedge clk_btic_sva)
    if (en_btic_va)
      btic_source_va <= nxt_btic_va;

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      btic_abuf_valid <= 1'b0;
    else if (en_btic_abuf_valid)
      btic_abuf_valid <= nxt_btic_abuf_valid;

  always @ (posedge clk_btic_tva)
    if (en_btic_abuf) begin
      btic_abuf      <= abuf_if3_i;
      btic_target_va <= abuf_va_if3_i;
      btic_isa_state <= abuf_state_if3_i;
    end

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      btic_bbuf_valid <= 1'b0;
    else if (en_btic_bbuf_valid)
      btic_bbuf_valid <= nxt_btic_bbuf_valid;

  always @ (posedge clk_btic_tva)
    if (en_btic_bbuf)
      btic_bbuf <= nxt_btic_bbuf;


  //----------------------------------------------------------------------------
  // Valid signals
  //----------------------------------------------------------------------------

  // Qualify instr-0 and instr-1 with the validity of the instruction.
  //
  // To ensure that code that is modified without a cache maintenace operation works in
  // the same way as it would without a BTIC, do not indicate a valid unless the
  // instruction at the address is considered to be a branch by the main decoder (which
  // operates on the opcodes stored in the buffers).
  //
  // If a btic_flush is set (which can happen since we try to catch a flush as early as possible) we also
  // prevent a hit
  assign i0_valid = (~btic_disable_i & ~dpu_iq_full_i & ~btic_flush & instr_valid_if3_i[0] & early_instr_taken_i[0] &
                     instr_brn_btic_i[0] & ~instr0_opcode_err_i);

  assign i1_valid = (~btic_disable_i & ~dpu_iq_full_i & ~btic_flush & instr_valid_if3_i[1] & early_instr_taken_i[1] &
                     instr_brn_btic_i[1] & ~instr0_opcode_err_i & ~instr0_brn_i & ~instr1_opcode_err_i & instr1_possible_i);



  //----------------------------------------------------------------------------
  // BTIC lookup
  //----------------------------------------------------------------------------

  // Match the instruction set state (ARM or Thumb).  While unlikely, architecturally the programmer is
  // allowed to proceed through the same memory location in both ARM state and Thumb state without doing
  // a maintenance operation to clean that location.  Because two back-to-back Thumb-16 B instructions
  // look like an ARM B instruction we could incorrectly hit in the BTIC in the opposite state to which
  // we allocated (e.g. allocate in Thumb state, hit in ARM state).  This would result in the processor
  // going to an incorrect memory address.
  //
  // To prevent this the BTIC does an instruction state match as well.
  //
  // Note that since the BTIC does not support BLX (imm) instructions it does not need to be concerned
  // with state differences between the source and desination addresses.  This helps as on a BTIC hit we
  // do not need to signal a different state to the Fetch-Queue.  Additionally, since all instructions in
  // the Fetch Queue will be in the same state there is no need to differentiate between an ABuf match
  // and a BBuf match.
  assign btic_match_isa = (btic_isa_state == abuf_state_if3_i);

  // Evaluate if there is a broad match between the address of the A-buffer and the BTIC entry
  assign btic_match_abuf = (btic_source_va[48:3] == abuf_va_if3_i[48:3]);

  // Evaluate if there is a broad match between the address of the B-buffer and the BTIC entry
  assign btic_match_bbuf = (btic_source_va[48:3] == bbuf_va_if3_i[48:3]);

  // Match instruction-0
  assign btic_match_i0 = btic_abuf_valid & btic_match_isa & btic_match_abuf & (btic_source_va[2:1] == abuf_va_if3_i[2:1]);

  // Match instruction-1
  //
  // To do this a check must be performed on both the A-buffer and the B-buffer.  Due to the time
  // required to generate a virtual address for instr-1 it is quicker to create speculative match
  // signals for each BTIC entry based on the virtual address and instruction set of instr-0 then
  // qualify the signals with the instr-0 size (16-bit/32-bit).
  //
  // Addtionally we must filter hits on instr-1 if there is also an adjacent hit on instr-0 as it is
  // not possible to deal with back-to-back direct branches.
  assign btic_source_va_00 = instr_is_thumb_if3_i & (btic_source_va[2:1] == 2'b00);
  assign btic_source_va_01 =                         btic_source_va[2:1] == 2'b01;
  assign btic_source_va_10 = instr_is_thumb_if3_i & (btic_source_va[2:1] == 2'b10);
  assign btic_source_va_11 =                         btic_source_va[2:1] == 2'b11;

  always @*
    case (abuf_va_if3_i[2:1])
      2'b00 : begin
        btic_abuf_spec_match = {((instr_is_a32_if3_i | instr_is_a64_if3_i) & btic_source_va[2]), btic_source_va_10, btic_source_va_01};
        btic_bbuf_spec_match = 3'b000;
      end
      2'b01 : begin
        btic_abuf_spec_match = {1'b0, btic_source_va_11, btic_source_va_10};
        btic_bbuf_spec_match = 3'b000;
      end
      2'b10 : begin
        btic_abuf_spec_match = {1'b0, 1'b0, btic_source_va_11};
        btic_bbuf_spec_match = {((instr_is_a32_if3_i | instr_is_a64_if3_i) & ~btic_source_va[2]), btic_source_va_00, 1'b0};
      end
      2'b11 : begin
        btic_abuf_spec_match = 3'b000;
        btic_bbuf_spec_match = {1'b0, btic_source_va_01, btic_source_va_00};
      end
      default : begin
        btic_abuf_spec_match = 3'bxxx;
        btic_bbuf_spec_match = 3'bxxx;
      end
    endcase

  assign btic_match_i1 = (btic_abuf_valid & btic_match_isa & btic_match_abuf &
                          (btic_abuf_spec_match[2] | (|(btic_abuf_spec_match[1:0] & {spec_instr0_t32_i, ~spec_instr0_t32_i})))) |
                         (btic_abuf_valid & btic_match_isa & btic_match_bbuf &
                          (btic_bbuf_spec_match[2] | (|(btic_bbuf_spec_match[1:0] & {spec_instr0_t32_i, ~spec_instr0_t32_i}))));

  assign btic_match_if3 = (btic_match_i0 & i0_valid) | (btic_match_i1 & i1_valid);

  assign btic_early_match_i0_if3 = btic_match_i0;
  assign btic_early_match_i1_if3 = btic_match_i1;

  assign btic_match_i0_if3 = btic_early_match_i0_if3 & i0_valid;
  assign btic_match_i1_if3 = btic_early_match_i1_if3 & i1_valid;


  //----------------------------------------------------------------------------
  // Output signals
  //----------------------------------------------------------------------------

  assign btic_hit_if3_o        = btic_match_i0_if3 | btic_match_i1_if3;

  assign btic_abuf_if3_o       = btic_abuf;
  assign btic_bbuf_if3_o       = btic_bbuf;
  assign btic_bbuf_valid_if3_o = btic_match_if3 & btic_bbuf_valid;
  assign btic_abuf_va_if3_o    = btic_target_va[48:1];
  assign btic_bbuf_va_if3_o    = btic_target_va[48:3] + 1'b1;
  assign btic_cbuf_va_if3_o    = btic_target_va[12:3] + 2'b10;
  assign btic_target_va_if2_o  = btic_target_va[48:3] + btic_bbuf_valid;


  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btic_supp_cnt_we")
  u_ovl_x_btic_supp_cnt_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (btic_supp_cnt_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btic_abuf")
  u_ovl_x_en_btic_abuf (.clk       (clk_btic_tva),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_btic_abuf));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btic_abuf_valid")
  u_ovl_x_en_btic_abuf_valid (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_btic_abuf_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btic_bbuf")
  u_ovl_x_en_btic_bbuf (.clk       (clk_btic_tva),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (en_btic_bbuf));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btic_bbuf_valid")
  u_ovl_x_en_btic_bbuf_valid (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_btic_bbuf_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_btic_va")
  u_ovl_x_en_btic_va (.clk       (clk_btic_sva),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (en_btic_va));

  // Check btic_update_state is a valid state
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "btic_update_state must be a valid state")
    u_ovl_btic_update_state
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       ((btic_update_state == CA53_BTIC_IDLE)      |
                         (btic_update_state == CA53_BTIC_A_PENDING) |
                         (btic_update_state == CA53_BTIC_B_PENDING) |
                         (btic_update_state == CA53_BTIC_FLUSH)));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
