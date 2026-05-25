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
// Abstract : Branch predictor
//-----------------------------------------------------------------------------
//
// Overview
// --------
// A 2bc GSkew predictor with two 2bc GShare tables, one 2bc Bimodal table and
// one 2bc Meta table (2bc refers to 2-bit confidence).  All tables are the same
// size and the Meta table chooses between the Bimodal predictor and the GShare
// predictors.  All predictor tables are updated when branches are committed.
//
// The two GShare predictors are indexed using separate hashes of the fetch
// address queue buffer and the current speculative global history.  The Meta
// and Bimodal predictors are indexed using the address of the fetch queue buffer.
//
// If the Meta predictor selects the Bimodal predictor only the bimodal prediction
// is used.  If the Meta predictor selects the GShare-0, GShare-1 and Bimodal
// tables then a majority vote prediction is created.
//
// The Meta predictor update is updated using a correlation history register
// that correlates between the majority vote prediction and the bimodal
// prediction.
//
// There are 2 copies of the global history register.  One is speculative and is
// updated using the current speculative branch prediction outcome.  The other
// copy is non-speculative and is updated with the committed branch outcome at
// the end of the Wr stage.
//
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_bpd (
  // Inputs
  input  wire        clk,
  input  wire        reset_n,
  input  wire        DFTSE,
  input  wire        dpu_pred_br_wr_i,
  input  wire        cm_branch_i,
  input  wire        cm_taken_i,
  input  wire        cm_mispredicted_i,
  input  wire        cm_flush_no_br_i,
  input  wire  [1:0] instr_valid_if3_i,
  input  wire        valid_if2_i,
  input  wire        avalid_if3_i,
  input  wire        next64_if3_i,
  input  wire        btic_hit_if3_i,
  input  wire [ 2:1] nxt_ip_if3_i,
  input  wire [12:3] va_if2_i,
  input  wire [12:3] abuf_va_if3_i,
  input  wire [12:3] abuf_va_plus1_if3_i,
  input  wire [12:3] abuf_va_plus2_if3_i,
  input  wire [11:3] btic_abuf_va_if3_i,
  input  wire [11:3] btic_bbuf_va_if3_i,
  input  wire [12:3] dpu_br_addr_ex2_i,
  input  wire        dpu_pred_br_ex2_i,
  input  wire [ 1:0] brn_predicted_if3_i,
  input  wire [ 1:0] pfb_push_i,
  input  wire        instr_abt_if3_i,
  input  wire        instr0_opcode_err_i,
  input  wire        instr1_possible_i,
  input  wire        instr_is_thumb_bpd_if3_i,
  input  wire        instr0_pdec_err_i,
  input  wire        abuf_mid_poss_t32_i,
  input  wire        dbg_valid_if2_i,
  input  wire        dpu_iq_full_i,
  // Outputs
  output wire        taken_i0_if3_o,
  output wire        taken_i1_if3_o);

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  // Semantic of Meta predictor entries [1:0]
  localparam SBI = 2'b10; // 10 Strongly Bimodal
  localparam WBI = 2'b11; // 11 Weakly Bimodal  <- initial value
  localparam WMA = 2'b00; // 00 Weakly Majority
  localparam SMA = 2'b01; // 01 Strongly Majority

  // Semantic of GShare & Bimodal predictor entries [1:0]
  localparam SNT = 2'b10; // 10 Strongly Not Taken
  localparam WNT = 2'b11; // 11 Weakly Not Taken
  localparam WT  = 2'b00; // 00 Weakly Taken  <- initial value
  localparam ST  = 2'b01; // 01 Strongly Taken

  // Prediction structure sizes
  localparam META_SIZE = 512;  // Meta predictor is a 512-entry table
  localparam BIM_SIZE  = 512;  // Bimodal predictor is a 512-entry table
  localparam GS0_SIZE  = 1024; // GShare-0 predictor is a 1024-entry table
  localparam GS1_SIZE  = 1024; // GShare-1 predictor is a 1024-entry table

  // Correlation history size
  localparam COR_HIST_NUM  = 12; // 12 entries
  localparam COR_HIST_ENT  = 5;  // Entry size: one correlation bit, 1 prediction bit per predictor (meta,bimodal,gsahre1,gshare0)
  localparam COR_HIST_BITS = COR_HIST_NUM * COR_HIST_ENT; // Total bits in history

  // History register sizes
  localparam HISTORY_SIZE = 8; // 8 entry history

  // Autogenerated bit sizes for the prediction structures
  localparam META_BITS = `CA53_LOG2(META_SIZE);
  localparam BIM_BITS  = `CA53_LOG2(BIM_SIZE);
  localparam GS0_BITS  = `CA53_LOG2(GS0_SIZE);
  localparam GS1_BITS  = `CA53_LOG2(GS1_SIZE);

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar i;
  genvar j;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                         bimodal_pred_i0;
  reg                         bimodal_pred_i1_xbuf;
  reg [1:0]                   bimodal_predictor [(1<<BIM_BITS)-1:0];
  reg [(GS0_BITS-1):0]        br_addr_gshare0_wr;
  reg [(GS0_BITS-2):0]        br_addr_gshare0_lo_wr;
  reg [(GS0_BITS-2):0]        br_addr_gshare0_hi_wr;
  reg [(GS1_BITS-1):0]        br_addr_gshare1_wr;
  reg [(GS1_BITS-2):0]        br_addr_gshare1_lo_wr;
  reg [(GS1_BITS-2):0]        br_addr_gshare1_hi_wr;
  reg [(META_BITS+2):3]       br_addr_wr;
  reg [(HISTORY_SIZE-1):0]    cm_gh_reg;
  reg [(COR_HIST_BITS-1):0]   correlation_history;
  reg [3:0]                   correlation_read_ptr;
  reg                         gshare0_pred_i0;
  reg                         gshare0_pred_i1_xbuf;
  reg [1:0]                   gshare0_predictor [(1<<GS0_BITS)-1:0];
  reg                         gshare1_pred_i0;
  reg                         gshare1_pred_i1_xbuf;
  reg [1:0]                   gshare1_predictor [(1<<GS1_BITS)-1:0];
  reg [2:1]                   ip_if3;
  reg                         last_btic_hit;
  reg                         last_empty_fq_or_update;
  reg                         meta_pred_i0;
  reg                         meta_pred_i1_xbuf;
  reg [1:0]                   meta_predictor [(1<<META_BITS)-1:0];
  reg [3:0]                   nxt_prediction_perturb_ctr;
  reg [3:0]                   prediction_perturb_ctr;
  reg [(HISTORY_SIZE-1):0]    sp_gh_reg;
  reg [4:0]                   sp_gh_gs1_reg;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(GS1_BITS-1):0]       abuf_va_if3_hash;
  wire [(GS1_BITS-1):0]       abuf_va_plus1_if3_hash;
  wire [(GS1_BITS-1):0]       abuf_va_plus2_if3_hash;
  wire [((META_SIZE/16)-1):0] bimodal_en;
  wire                        bimodal_pred_abuf;
  wire                        bimodal_pred_abuf_btic;
  wire                        bimodal_pred_bbuf;
  wire                        bimodal_pred_bbuf_btic;
  wire                        bimodal_pred_cbuf;
  wire                        br_addr_gshare0_hi_wr_en;
  wire                        br_addr_gshare0_lo_wr_en;
  wire                        br_addr_gshare1_hi_wr_en;
  wire                        br_addr_gshare1_lo_wr_en;
  wire                        clk_bpd;
  wire [1:0]                  cm_bimodal;
  wire [(BIM_BITS-1):0]       cm_bimodal_index;
  wire [(HISTORY_SIZE-1):0]   cm_gh_nxt;
  wire                        cm_gh_we;
  wire [1:0]                  cm_gshare0;
  wire [1:0]                  cm_gshare0_hi;
  wire [(GS0_BITS-1):0]       cm_gshare0_index;
  wire [(GS0_BITS-1):0]       cm_gshare0_index_hi;
  wire [(GS0_BITS-1):0]       cm_gshare0_index_lo;
  wire [1:0]                  cm_gshare0_lo;
  wire [1:0]                  cm_gshare1;
  wire [1:0]                  cm_gshare1_hi;
  wire [(GS1_BITS-1):0]       cm_gshare1_index;
  wire [(GS1_BITS-1):0]       cm_gshare1_index_hi;
  wire [(GS1_BITS-1):0]       cm_gshare1_index_lo;
  wire [1:0]                  cm_gshare1_lo;
  wire [1:0]                  cm_meta;
  wire [(META_BITS-1):0]      cm_meta_index;
  wire                        correlate_pred_bimodal;
  wire                        correlate_pred_majority;
  wire                        correlation_flush;
  wire                        correlation_read_ptr_en;
  wire                        correlation_update_bimodal;
  wire                        correlation_update_gshare0;
  wire                        correlation_update_gshare1;
  wire [(COR_HIST_BITS-1):0]  correlation_value_shifted;
  wire                        empty_fq_or_update;
  wire [((GS0_SIZE/16)-1):0]  gshare0_en;
  wire [(GS0_BITS-1):0]       gshare0_hist_br_wr;
  wire [(GS0_BITS-1):0]       gshare0_hist_no_br_wr;
  wire                        gshare0_pred_abuf;
  wire                        gshare0_pred_bbuf;
  wire                        gshare0_pred_cbuf;
  wire [((GS1_SIZE/16)-1):0]  gshare1_en;
  wire [(GS1_BITS-1):0]       gshare1_hist_br_wr;
  wire [(GS1_BITS-1):0]       gshare1_hist_no_br_wr;
  wire                        gshare1_pred_abuf;
  wire                        gshare1_pred_bbuf;
  wire                        gshare1_pred_cbuf;
  wire                        majority_vote_i0;
  wire                        majority_vote_i1_xbuf;
  wire [((META_SIZE/16)-1):0] meta_bimodal_en;
  wire [((META_SIZE/16)-1):0] meta_en;
  wire                        meta_pred_abuf;
  wire                        meta_pred_bbuf;
  wire                        meta_pred_cbuf;
  wire [(GS0_BITS-1):0]       muxed_abuf_va_if3;
  wire [(GS1_BITS-1):0]       muxed_abuf_va_if3_hash;
  wire [1:0]                  new_bimodal_cm;
  wire [3:0]                  new_correlation_read_ptr;
  wire [3:0]                  new_correlation_read_ptr_pop;
  wire [3:0]                  new_correlation_read_ptr_push;
  wire [(COR_HIST_ENT-1):0]   new_correlation_value;
  wire [1:0]                  new_gshare0_cm;
  wire [1:0]                  new_gshare1_cm;
  wire [1:0]                  new_meta_cm;
  wire                        nxt_bimodal_pred_i0;
  wire                        nxt_bimodal_pred_i1_xbuf;
  wire [1:0]                  nxt_bimodal_predictor [(1<<BIM_BITS)-1:0];
  wire [(GS0_BITS-1):0]       nxt_br_addr_gshare0_wr;
  wire [(GS1_BITS-1):0]       nxt_br_addr_gshare1_wr;
  wire                        nxt_gshare0_pred_i0;
  wire                        nxt_gshare0_pred_i1_xbuf;
  wire [1:0]                  nxt_gshare0_predictor [(1<<GS0_BITS)-1:0];
  wire                        nxt_gshare1_pred_i0;
  wire                        nxt_gshare1_pred_i1_xbuf;
  wire [1:0]                  nxt_gshare1_predictor [(1<<GS1_BITS)-1:0];
  wire                        nxt_meta_pred_i0;
  wire                        nxt_meta_pred_i1_xbuf;
  wire [1:0]                  nxt_meta_predictor [(1<<META_BITS)-1:0];
  wire                        pred_bimodal;
  wire                        pred_gshare0;
  wire                        pred_gshare1;
  wire                        pred_meta;
  wire                        prediction_perturb;
  wire                        prediction_perturb_13;
  wire [(COR_HIST_ENT-1):0]   prediction_correlation;
  wire                        select_i1_xbuf;
  wire [(BIM_BITS+2):3]       sp_bimodal_index_abuf;
  wire [(BIM_BITS+2):3]       sp_bimodal_index_abuf_btic;
  wire [(BIM_BITS+2):3]       sp_bimodal_index_bbuf;
  wire [(BIM_BITS+2):3]       sp_bimodal_index_bbuf_btic;
  wire [(BIM_BITS+2):3]       sp_bimodal_index_cbuf;
  wire [(HISTORY_SIZE-1):0]   sp_gh_nxt;
  wire                        sp_gh_we;
  wire                        sp_gshare0_abuf_npred;
  wire                        sp_gshare0_abuf_pred;
  wire                        sp_gshare0_bbuf_npred;
  wire                        sp_gshare0_bbuf_pred;
  wire                        sp_gshare0_cbuf_npred;
  wire                        sp_gshare0_cbuf_pred;
  wire [(GS0_BITS-1):0]       sp_gshare0_hist_npred;
  wire [(GS0_BITS-1):0]       sp_gshare0_hist_pred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_abuf_npred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_abuf_pred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_bbuf_npred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_bbuf_pred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_cbuf_npred;
  wire [(GS0_BITS+2):3]       sp_gshare0_index_cbuf_pred;
  wire                        sp_gshare1_abuf_npred;
  wire                        sp_gshare1_abuf_pred;
  wire                        sp_gshare1_bbuf_npred;
  wire                        sp_gshare1_bbuf_pred;
  wire                        sp_gshare1_cbuf_npred;
  wire                        sp_gshare1_cbuf_pred;
  wire [(GS1_BITS-1):0]       sp_gshare1_hist_npred;
  wire [(GS1_BITS-1):0]       sp_gshare1_hist_pred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_abuf_npred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_abuf_pred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_bbuf_npred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_bbuf_pred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_cbuf_npred;
  wire [(GS1_BITS+2):3]       sp_gshare1_index_cbuf_pred;
  wire [(META_BITS+2):3]      sp_meta_index_abuf;
  wire [(META_BITS+2):3]      sp_meta_index_bbuf;
  wire [(META_BITS+2):3]      sp_meta_index_cbuf;
  wire                        sp_branch_if3;
  wire                        sp_branch_i0_if3;
  wire                        sp_branch_i0_raw_if3;
  wire                        sp_branch_i1_if3;
  wire                        sp_branch_i1_raw_if3;
  wire                        sp_branch_raw_if3;
  wire                        sp_pred_en;
  wire                        taken;
  wire                        taken_i0;
  wire                        taken_i1;
  wire                        taken_i1_xbuf;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  // All tables in the branch predictor can be architecturally gated using a regional clock
  // gate and clocked only when there is a predictable branch in the writeback stage.
  ca53_cell_inter_clkgate u_inter_clkgate_bpd (.clk_i         (clk),
                                               .clk_enable_i  (dpu_pred_br_wr_i),
                                               .clk_senable_i (DFTSE),
                                               .clk_gated_o   (clk_bpd));

  // ------------------------------------------------------
  // State Transition Function for GShare/Bimodal Predictor
  // ------------------------------------------------------

  // This function takes the current state of the GShare tables and whether the current branch is
  // taken and returns the next state.
  //
  // If the majority vote and bimodal predictions correlate and it is a misprediction cycle where
  // the prediction is perturbed then move to weakly correct prediction.
  function [1:0] f_nxt_state;
    // Returns new history
    input [1:0] bh;                 // Current history
    input       tn;                 // Taken indication
    input       prediction_perturb; // Perturb prediction

    reg [2:0] sel;
    begin
      sel = {tn, bh};
      case (sel)
        {1'b0, SNT} : f_nxt_state =                            SNT;
        {1'b1, SNT} : f_nxt_state = prediction_perturb ? ST  : WNT;
        {1'b0, WNT} : f_nxt_state =                            SNT;
        {1'b1, WNT} : f_nxt_state = prediction_perturb ? ST  : WT;
        {1'b0, WT } : f_nxt_state = prediction_perturb ? SNT : WNT;
        {1'b1, WT } : f_nxt_state =                            ST;
        {1'b0, ST } : f_nxt_state = prediction_perturb ? SNT : WT;
        {1'b1, ST } : f_nxt_state =                            ST;
        default     : f_nxt_state = 2'bxx;
      endcase
    end
  endfunction

  // ------------------------------------------------------
  // State Transition Function for Meta Predictor
  // ------------------------------------------------------

  // This function takes the current state of the meta predictor the misprediction indicator and
  // the correlation between predictors and returns the next state.
  //
  // If the majority vote and bimodal predictions do not correlate and it is a misprediction cycle
  // where the prediction is perturbed then move towards the correct table.
  function [1:0] f_nxt_state_meta;
    // Returns new history
    input [1:0] meta_state;         // Current meta state
    input       pred_cor;           // Prediction correlation
    input       miss_pred;          // Misprediction indication
    input       prediction_perturb; // Perturb prediction

    reg [3:0] sel;
    begin
      sel = {miss_pred, pred_cor, meta_state};
      case (sel)
        // Current State = Strongly Bimodal
        {1'b1, 1'b1, SBI} : f_nxt_state_meta =                            WBI; // Both predictors got it wrong, but move to WBI as we may be training
        {1'b1, 1'b0, SBI} : f_nxt_state_meta = prediction_perturb ? SMA : WBI; // Majority would have been right so move to WBI unless perturbing prediction
        {1'b0, 1'b1, SBI} : f_nxt_state_meta =                            SBI; // Both predictors got it right so don't change from SBI
        {1'b0, 1'b0, SBI} : f_nxt_state_meta =                            SBI; // Bimodal was right and Majority wrong so don't change from SBI
        // Current State = Weakly Bimodal
        {1'b1, 1'b1, WBI} : f_nxt_state_meta =                            WBI; // Both predictors got it wrong, leave in WBI
        {1'b1, 1'b0, WBI} : f_nxt_state_meta = prediction_perturb ? SMA : WMA; // Majority would have been right so move to WMA
        {1'b0, 1'b1, WBI} : f_nxt_state_meta =                            WBI; // Both predictors got it right, so don't change from WBI
        {1'b0, 1'b0, WBI} : f_nxt_state_meta =                            SBI; // Bimodal was right and Majority wrong so move to SBI
        // Current State = Weakly Majority
        {1'b1, 1'b1, WMA} : f_nxt_state_meta =                            WMA; // Both predictors got it wrong, leave in WMA
        {1'b1, 1'b0, WMA} : f_nxt_state_meta = prediction_perturb ? SBI : WBI; // Bimodal would have been right so move to WBI
        {1'b0, 1'b1, WMA} : f_nxt_state_meta =                            WMA; // Both predictors got it right, so don't change from WMA
        {1'b0, 1'b0, WMA} : f_nxt_state_meta =                            SMA; // Majority was right and Bimodal wrong so move to SMA
        // Current State = Strongly Majority
        {1'b1, 1'b1, SMA} : f_nxt_state_meta =                            WMA; // Both predictors got it wrong, but move to WMA as we may be training
        {1'b1, 1'b0, SMA} : f_nxt_state_meta = prediction_perturb ? SBI : WMA; // Bimodal would have been right so move to WMA unless perturbing prediction
        {1'b0, 1'b1, SMA} : f_nxt_state_meta =                            SMA; // Both predictors got it right so don't change from SMA
        {1'b0, 1'b0, SMA} : f_nxt_state_meta =                            SMA; // Majority was right and Bimodal wrong so don't change from SMA
        default           : f_nxt_state_meta = 2'bxx;
      endcase
    end
  endfunction

  // ------------------------------------------------------
  // Speculative branch indicator
  // ------------------------------------------------------
  //
  // The speculative branch history is updated when a "predictable" branch is pushed to the IQ
  //
  // The raw versions remove the pfb_push indicators so that they can be used earlier.  This
  // allows control paths to be setup according to the branch that is present, with register
  // enables using the fully qualified version to prevent propagation until the branch is pushed
  // to the DPU.

  assign sp_branch_i0_raw_if3 = brn_predicted_if3_i[0] & instr_valid_if3_i[0] & ~dpu_iq_full_i & ~instr0_opcode_err_i & ~instr_abt_if3_i;
  assign sp_branch_i1_raw_if3 = brn_predicted_if3_i[1] & instr_valid_if3_i[1] & ~dpu_iq_full_i & ~instr0_opcode_err_i & instr1_possible_i;
  assign sp_branch_raw_if3    = sp_branch_i0_raw_if3 | sp_branch_i1_raw_if3;

  assign sp_branch_i0_if3 = brn_predicted_if3_i[0] & pfb_push_i[0] & ~instr_abt_if3_i & ~instr0_opcode_err_i;
  assign sp_branch_i1_if3 = brn_predicted_if3_i[1] & pfb_push_i[1];
  assign sp_branch_if3    = sp_branch_i0_if3 | sp_branch_i1_if3;

  // ------------------------------------------------------
  // Global History Update
  // ------------------------------------------------------

  // Generate next committed history value
  assign cm_gh_nxt = {cm_gh_reg[(HISTORY_SIZE-2):0], cm_taken_i};

  // The functionality is the same as above except for the extra mux term needed when the DPU
  // commits on a mispredicted branch.
  assign sp_gh_nxt = (cm_flush_no_br_i                  ? cm_gh_reg                            :  // Copy current cm_gh_reg
                      (cm_branch_i & cm_mispredicted_i) ? cm_gh_nxt                            :  // Force commited value
                                                         {sp_gh_reg[(HISTORY_SIZE-2):0], taken}); // Updated history

  // ------------------------------------------------------
  // Predictor Correlation History
  // ------------------------------------------------------
  //
  // The correlation logic is used in the commit stage to update the predictors.  The rules are:
  //
  // - On an incorrect prediction the Bimodal, GShare-0 and GShare-1 tables are updated
  // - On a correct prediction only the table(s) that predicted correctly are updated
  //   e.g. if the prediction came from the Bimodal table only the Bimodal table is updated
  //   e.g. if the prediction came from the GShare-0/1 tables only the table that was correct is updated
  // - The Meta predictor is only updated when the predictions disagree

  // Flush the correlation read pointer on a mispredicted branch or force from the DPU (no need
  // to flush the correlation history as it is just a shift register)
  assign correlation_flush = (cm_branch_i & cm_mispredicted_i) | cm_flush_no_br_i;

  // Construct the correlation value:
  // [4] Correlation
  // [3] Meta
  // [2] Bimodal
  // [1] GShare-1
  // [0] GShare-0
  assign new_correlation_value = {~(correlate_pred_majority ^ correlate_pred_bimodal), pred_meta, pred_bimodal, pred_gshare1, pred_gshare0};

  // Generate a new correlation read pointer depending on a speculative branch being pushed or a
  // branch being committed by the DPU.
  //
  // A fully qualified, precise version of the speculative branch indicator must be used in this
  // logic cone since an updated read pointer will be generated on a commit and we don't want a
  // branch in IF3 that isn't being pushed (due to a full IQ, pre-decode error, etc) corrupting
  // the read_pointer by moving it on incorrectly.
  //
  // On a flush the read pointer resets to 4'h1111 so that the first prediction points to [0].
  assign new_correlation_read_ptr_pop  = correlation_read_ptr[3:0] + {4{correlation_read_ptr[3:0] != 4'hf}};         // Subtract 1 (i.e. add 4'hf) if no underflow
  assign new_correlation_read_ptr_push = correlation_read_ptr[3:0] + {{3{1'b0}}, correlation_read_ptr[3:0] != 4'hb}; // Add 1 if no overflow

  assign new_correlation_read_ptr = (correlation_flush               ? 4'hf                          :
                                     ( cm_branch_i & ~sp_branch_if3) ? new_correlation_read_ptr_pop  :
                                     (~cm_branch_i &  sp_branch_if3) ? new_correlation_read_ptr_push : correlation_read_ptr[3:0]);

  // Generate a new correlation history based on a speculative branch being pushed.  The history
  // does not need to consider branch commits since it is constantly shifting left and so only
  // the read pointer matters.
  assign correlation_value_shifted = {correlation_history[0+:(COR_HIST_ENT * (COR_HIST_NUM-1))], new_correlation_value};

  generate for (i = 0 ; i < COR_HIST_NUM ; i = i+1) begin : cor_hist

    // Each loop of the generate block updates a portion of the correlation
    // history register corresponding to one entry, which contains four
    // prediction values plus a prediction correlation.
    always @(posedge clk or negedge reset_n)
      if (!reset_n)
        correlation_history[(COR_HIST_ENT*i)+:COR_HIST_ENT] <= {COR_HIST_ENT{1'b0}};
      else if (sp_branch_if3)
        correlation_history[(COR_HIST_ENT*i)+:COR_HIST_ENT] <= correlation_value_shifted[(COR_HIST_ENT*i)+:COR_HIST_ENT];
  end
  endgenerate

  // Enable generation
  assign correlation_read_ptr_en = sp_branch_if3 | cm_branch_i | cm_flush_no_br_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      correlation_read_ptr <= 4'hf;
    else if (correlation_read_ptr_en)
      correlation_read_ptr <= new_correlation_read_ptr;

  // Extract the prediction correlation value
  assign prediction_correlation = (({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h0}} & correlation_history[              0 +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h1}} & correlation_history[ 1*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h2}} & correlation_history[ 2*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h3}} & correlation_history[ 3*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h4}} & correlation_history[ 4*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h5}} & correlation_history[ 5*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h6}} & correlation_history[ 6*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h7}} & correlation_history[ 7*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h8}} & correlation_history[ 8*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'h9}} & correlation_history[ 9*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'ha}} & correlation_history[10*COR_HIST_ENT +: COR_HIST_ENT]) |
                                   ({COR_HIST_ENT{correlation_read_ptr[3:0] == 4'hb}} & correlation_history[11*COR_HIST_ENT +: COR_HIST_ENT]) |
                                    {COR_HIST_ENT{correlation_read_ptr[3:0] == 4'hf}}); // prediction was never made

  // Generate the bimodal, GShare-0 and GShare-1 enables
  assign correlation_update_bimodal = (cm_mispredicted_i |                                        // Mispredict, OR
                                       prediction_correlation[COR_HIST_ENT-2] |                   // Meta points at the bimodal table, OR
                                       (~prediction_correlation[COR_HIST_ENT-2] &                 // Meta points at the GS+BIM tabls AND
                                        ~(cm_taken_i ^ prediction_correlation[COR_HIST_ENT-3]))); // BIM takeness correlates with DPU

  assign correlation_update_gshare1 = (cm_mispredicted_i |                                        // Mispredict, OR
                                       (~prediction_correlation[COR_HIST_ENT-2] &                 // Meta points at the GS+BIM tabls AND
                                        ~(cm_taken_i ^ prediction_correlation[COR_HIST_ENT-4]))); // GS1 takeness correlates with DPU

  assign correlation_update_gshare0 = (cm_mispredicted_i |                                        // Mispredict, OR
                                       (~prediction_correlation[COR_HIST_ENT-2] &                 // Meta points at the GS+BIM tabls AND
                                        ~(cm_taken_i ^ prediction_correlation[COR_HIST_ENT-5]))); // GS0 takeness correlates with DPU

  // ------------------------------------------------------
  // Global History Registers
  // ------------------------------------------------------

  // Speculative
  //
  // Speculative WE true when current instr is branch OR we have mispredicted and DPU is forcing
  // commit state OR the DPU is flushing the pipeline not due to a branch
  assign sp_gh_we = sp_branch_if3 | (cm_branch_i & cm_mispredicted_i) | cm_flush_no_br_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      sp_gh_reg     <= {HISTORY_SIZE{1'b0}};
      sp_gh_gs1_reg <= {5{1'b0}};
    end
    else if (sp_gh_we) begin
      sp_gh_reg     <= sp_gh_nxt;
      sp_gh_gs1_reg <= sp_gh_nxt[4:0];
    end

  // Committed
  assign cm_gh_we = cm_branch_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cm_gh_reg <= {HISTORY_SIZE{1'b0}};
    else if (cm_gh_we)
      cm_gh_reg <= cm_gh_nxt;

  // ------------------------------------------------------
  // Prediction update address
  // ------------------------------------------------------

  // Form the history patterns that will be hashed with the address.  As this logic relates to a branch
  // in Ex2, if there is currently a branch being committed in Wr we must use the next committed global
  // history value.
  assign gshare0_hist_br_wr    = {{2{1'b0}}, cm_gh_nxt[0], cm_gh_nxt[1], cm_gh_nxt[2], cm_gh_nxt[3], cm_gh_nxt[4], cm_gh_nxt[5], cm_gh_nxt[6], cm_gh_nxt[7]};
  assign gshare0_hist_no_br_wr = {{2{1'b0}}, cm_gh_reg[0], cm_gh_reg[1], cm_gh_reg[2], cm_gh_reg[3], cm_gh_reg[4], cm_gh_reg[5], cm_gh_reg[6], cm_gh_reg[7]};

  assign gshare1_hist_br_wr    = {{5{1'b0}}, cm_gh_nxt[0], cm_gh_nxt[1], cm_gh_nxt[2], cm_gh_nxt[3], cm_gh_nxt[4]};
  assign gshare1_hist_no_br_wr = {{5{1'b0}}, cm_gh_reg[0], cm_gh_reg[1], cm_gh_reg[2], cm_gh_reg[3], cm_gh_reg[4]};

  // Create the next GShare indexes by XORing the Ex2 DPU branch address with what will be the next
  // committed global history register
  assign nxt_br_addr_gshare0_wr  = dpu_br_addr_ex2_i[(GS0_BITS+2):3] ^ (cm_branch_i ? gshare0_hist_br_wr : gshare0_hist_no_br_wr);
  assign nxt_br_addr_gshare1_wr  = {dpu_br_addr_ex2_i[ 3],
                                    dpu_br_addr_ex2_i[ 4],
                                    dpu_br_addr_ex2_i[ 5],
                                    dpu_br_addr_ex2_i[ 6],
                                    dpu_br_addr_ex2_i[ 7],
                                    dpu_br_addr_ex2_i[ 8],
                                    dpu_br_addr_ex2_i[ 9],
                                    dpu_br_addr_ex2_i[10],
                                    dpu_br_addr_ex2_i[11],
                                    dpu_br_addr_ex2_i[12]}           ^ (cm_branch_i ? gshare1_hist_br_wr : gshare1_hist_no_br_wr);

  // Register the DPU branch address in Ex2.  If the DPU is stalled in Wr and there is a branch in Ex2
  // this register will continue to be enabled, but this is OK functionally (though will consume a bit
  // more power then we'd like).  Also form the next gshare index at the same time.
  always @(posedge clk)
    if (dpu_pred_br_ex2_i) begin
      br_addr_wr         <= dpu_br_addr_ex2_i[(META_BITS+2):3];
      br_addr_gshare0_wr <= nxt_br_addr_gshare0_wr;
      br_addr_gshare1_wr <= nxt_br_addr_gshare1_wr;
    end

  // Register GShare-0 partial indexes for lookup
  assign br_addr_gshare0_hi_wr_en = dpu_pred_br_ex2_i &  nxt_br_addr_gshare0_wr[(GS0_BITS-1)];
  assign br_addr_gshare0_lo_wr_en = dpu_pred_br_ex2_i & ~nxt_br_addr_gshare0_wr[(GS0_BITS-1)];

  always @(posedge clk)
    if (br_addr_gshare0_hi_wr_en)
      br_addr_gshare0_hi_wr <= nxt_br_addr_gshare0_wr[(GS0_BITS-2):0];

  always @(posedge clk)
    if (br_addr_gshare0_lo_wr_en)
      br_addr_gshare0_lo_wr <= nxt_br_addr_gshare0_wr[(GS0_BITS-2):0];

  // Register GShare-1 partial indexes for lookup
  assign br_addr_gshare1_hi_wr_en = dpu_pred_br_ex2_i &  nxt_br_addr_gshare1_wr[(GS1_BITS-1)];
  assign br_addr_gshare1_lo_wr_en = dpu_pred_br_ex2_i & ~nxt_br_addr_gshare1_wr[(GS1_BITS-1)];

  always @(posedge clk)
    if (br_addr_gshare1_hi_wr_en)
      br_addr_gshare1_hi_wr <= nxt_br_addr_gshare1_wr[(GS1_BITS-2):0];

  always @(posedge clk)
    if (br_addr_gshare1_lo_wr_en)
      br_addr_gshare1_lo_wr <= nxt_br_addr_gshare1_wr[(GS1_BITS-2):0];

  // ------------------------------------------------------
  // Prediction perturbation
  // ------------------------------------------------------
  //
  // The initialisation state of the predictor (either after reset or during operation when a new
  // thread with a different prediction pattern starts) can result in the predictor working itself
  // in to a corner where the Meta won't switch from Bimodal to GShare or the Majority vote is wrong.
  // To overcome this the following circuit forces the Meta or Bimodal+Gshare tables to either a weak
  // prediction (but still pointing towards the same table) or to a weak prediction of the other table.

  // Perturbation counter that increments on each mis-predict
  always @*
    case (prediction_perturb_ctr[3:0])
      4'b0000 : nxt_prediction_perturb_ctr = 4'b0001;
      4'b0001 : nxt_prediction_perturb_ctr = 4'b0010;
      4'b0010 : nxt_prediction_perturb_ctr = 4'b0011;
      4'b0011 : nxt_prediction_perturb_ctr = 4'b0100;
      4'b0100 : nxt_prediction_perturb_ctr = 4'b0101;
      4'b0101 : nxt_prediction_perturb_ctr = 4'b0110;
      4'b0110 : nxt_prediction_perturb_ctr = 4'b0111;
      4'b0111 : nxt_prediction_perturb_ctr = 4'b1000;
      4'b1000 : nxt_prediction_perturb_ctr = 4'b1001;
      4'b1001 : nxt_prediction_perturb_ctr = 4'b1010;
      4'b1010 : nxt_prediction_perturb_ctr = 4'b1011;
      4'b1011 : nxt_prediction_perturb_ctr = 4'b1100;
      4'b1100 : nxt_prediction_perturb_ctr = 4'b0000;
      default : nxt_prediction_perturb_ctr = 4'bxxxx;
    endcase

  always @(posedge clk_bpd or negedge reset_n)
    if (!reset_n)
      prediction_perturb_ctr[3:0] <= 4'b0000;
    else if (cm_mispredicted_i)
      prediction_perturb_ctr[3:0] <= nxt_prediction_perturb_ctr[3:0];

  // Preturb prediction every 13-cycles.  We use a prime number to prevent sequences of difficult to
  // perturb branches dividing in to the perturb counter.
  assign prediction_perturb_13 = prediction_perturb_ctr[3:0] == 4'b1100;

  // For the Bimodal/GShare tables ensure the misprediction is real (can't just rely on the fact
  // the signals don't correlate)
  assign prediction_perturb = prediction_perturb_13 & prediction_correlation[COR_HIST_ENT-1] & cm_mispredicted_i;

  // ------------------------------------------------------
  // Meta and Bimodal Predictor Update
  // ------------------------------------------------------

  // Create an enable for each 16-register portion.  This is used for both Meta and Bimodal tables.
  generate for (i = 0; i< (META_SIZE/16); i = i+1) begin : enable_loop
    assign meta_bimodal_en[i] = cm_branch_i & (cm_meta_index[(META_BITS-1):4] == i[(META_BITS-5):0]);
  end
  endgenerate

  // ------------------------------------------------------
  // Meta Predictor Update
  // ------------------------------------------------------

  // Meta history index calculation
  assign cm_meta_index = br_addr_wr[(META_BITS+2):3];

  // Lookup in the bimodal array to get the current prediction
  assign cm_meta = meta_predictor[cm_meta_index];

  // Calculate the next branch history table value
  assign new_meta_cm[1:0] = f_nxt_state_meta(cm_meta, prediction_correlation[COR_HIST_ENT-1], cm_mispredicted_i, prediction_perturb_13);

  // Partition the Meta Table (using two "for" loops) in to groups of 16-registers and
  // only enable each portion on an update rather than the entire table
  generate for (i = 0; i< (META_SIZE/16); i = i+1) begin : meta_outer_loop

    // Create an enable for each 16-register portion
    assign meta_en[i] = meta_bimodal_en[i];

    for (j = 0; j<16; j = j+1) begin : meta_inner_loop

      assign nxt_meta_predictor[{i[(META_BITS-5):0], j[3:0]}] = (cm_meta_index[3:0] == j[3:0]) ? new_meta_cm[1:0] : meta_predictor[{i[(META_BITS-5):0], j[3:0]}];

      always @(posedge clk_bpd or negedge reset_n)
        if (!reset_n)
          meta_predictor[{i[(META_BITS-5):0], j[3:0]}] <= 2'b11;
        else if (meta_en[i])
          meta_predictor[{i[(META_BITS-5):0], j[3:0]}] <= nxt_meta_predictor[{i[(META_BITS-5):0], j[3:0]}];
    end
  end
  endgenerate

  // ------------------------------------------------------
  // Bimodal Predictor Update
  // ------------------------------------------------------

  // Bimodal history index calculation
  assign cm_bimodal_index = br_addr_wr[(BIM_BITS+2):3];

  // Lookup in the bimodal array to get the current prediction
  assign cm_bimodal = bimodal_predictor[cm_bimodal_index];

  // Calculate the next branch history table value
  assign new_bimodal_cm[1:0] = f_nxt_state(cm_bimodal, cm_taken_i, prediction_perturb);

  // Partition the Bimodal Table (using two "for" loops) in to groups of 16-registers
  // and only enable each portion on an update rather than the entire table
  generate for (i = 0; i< (BIM_SIZE/16); i = i+1) begin : bimodal_outer_loop

    // Create an enable for each 16-register portion
    assign bimodal_en[i] = correlation_update_bimodal & meta_bimodal_en[i];

    for (j = 0; j<16; j = j+1) begin : bimodal_inner_loop

      assign nxt_bimodal_predictor[{i[(BIM_BITS-5):0], j[3:0]}] = (cm_bimodal_index[3:0] == j[3:0]) ? new_bimodal_cm[1:0] : bimodal_predictor[{i[(BIM_BITS-5):0], j[3:0]}];

      always @(posedge clk_bpd or negedge reset_n)
        if (!reset_n)
          bimodal_predictor[{i[(BIM_BITS-5):0], j[3:0]}] <= 2'b00;
        else if (bimodal_en[i])
          bimodal_predictor[{i[(BIM_BITS-5):0], j[3:0]}] <= nxt_bimodal_predictor[{i[(BIM_BITS-5):0], j[3:0]}];
    end
  end
  endgenerate

  // ------------------------------------------------------
  // GShare-0 Predictor Update
  // ------------------------------------------------------

  // GShare-0 index was constructed in the previous cycle.  Create three different signals
  // depending on whether we're reading the high portion, low portion or selecting the entry
  // to write.
  assign cm_gshare0_index_hi = {1'b1, br_addr_gshare0_hi_wr[(GS0_BITS-2):0]};
  assign cm_gshare0_index_lo = {1'b0, br_addr_gshare0_lo_wr[(GS0_BITS-2):0]};
  assign cm_gshare0_index    =        br_addr_gshare0_wr[(GS0_BITS-1):0];

  // Lookup in the hi portion of the array at the same time as the lo portion then mux
  // between to get the current prediction.  This optimisation is for power and timing.
  assign cm_gshare0_hi = gshare0_predictor[cm_gshare0_index_hi];
  assign cm_gshare0_lo = gshare0_predictor[cm_gshare0_index_lo];
  assign cm_gshare0    = cm_gshare0_index[(GS0_BITS-1)] ? cm_gshare0_hi : cm_gshare0_lo;

  // Calculate the next branch history table value
  assign new_gshare0_cm[1:0] = f_nxt_state(cm_gshare0, cm_taken_i, prediction_perturb);

  // Partition the GShare-0 Table (using two "for" loops) in to groups of 16-registers and
  // only enable each portion on an update rather than the entire table
  generate for (i = 0; i< (GS0_SIZE/16); i = i+1) begin : gshare0_outer_loop

    // Create an enable for each 16-register portion
    assign gshare0_en[i] = correlation_update_gshare0 & (cm_gshare0_index[(GS0_BITS-1):4] == i[(GS0_BITS-5):0]);

    for (j = 0; j<16; j = j+1) begin : gshare0_inner_loop

      assign nxt_gshare0_predictor[{i[(GS0_BITS-5):0], j[3:0]}] = (cm_gshare0_index[3:0] == j[3:0]) ? new_gshare0_cm[1:0] : gshare0_predictor[{i[(GS0_BITS-5):0], j[3:0]}];

      always @(posedge clk_bpd or negedge reset_n)
        if (!reset_n)
          gshare0_predictor[{i[(GS0_BITS-5):0], j[3:0]}] <= 2'b00;
        else if (gshare0_en[i])
          gshare0_predictor[{i[(GS0_BITS-5):0], j[3:0]}] <= nxt_gshare0_predictor[{i[(GS0_BITS-5):0], j[3:0]}];
    end
  end
  endgenerate

  // ------------------------------------------------------
  // GShare-1 Predictor Update
  // ------------------------------------------------------

  // GShare-1 index was constructed in the previous cycle.  Create three different signals
  // depending on whether we're reading the high portion, low portion or selecting the entry
  // to write.
  assign cm_gshare1_index_hi = {1'b1, br_addr_gshare1_hi_wr[(GS1_BITS-2):0]};
  assign cm_gshare1_index_lo = {1'b0, br_addr_gshare1_lo_wr[(GS1_BITS-2):0]};
  assign cm_gshare1_index    =        br_addr_gshare1_wr[(GS1_BITS-1):0];

  // Lookup in the hi portion of the array at the same time as the lo portion then mux
  // between to get the current prediction.  This optimisation is for power and timing.
  assign cm_gshare1_hi = gshare1_predictor[cm_gshare1_index_hi];
  assign cm_gshare1_lo = gshare1_predictor[cm_gshare1_index_lo];
  assign cm_gshare1    = cm_gshare1_index[(GS1_BITS-1)] ? cm_gshare1_hi : cm_gshare1_lo;

  // Calculate the next branch history table value
  assign new_gshare1_cm[1:0] = f_nxt_state(cm_gshare1, cm_taken_i, prediction_perturb);

  // Partition the GShare-1 table (using two "for" loops) in to groups of 16-registers and
  // only enable each portion on an update rather than the entire table
  generate for (i = 0; i< (GS1_SIZE/16); i = i+1) begin : gshare1_outer_loop

    // Create an enable for each 16-register portion
    assign gshare1_en[i] = correlation_update_gshare1 & (cm_gshare1_index[(GS1_BITS-1):4] == i[(GS1_BITS-5):0]);

    for (j = 0; j<16; j = j+1) begin : gshare1_inner_loop

      assign nxt_gshare1_predictor[{i[(GS1_BITS-5):0], j[3:0]}] = (cm_gshare1_index[3:0] == j[3:0]) ? new_gshare1_cm[1:0] : gshare1_predictor[{i[(GS1_BITS-5):0], j[3:0]}];

      always @(posedge clk_bpd or negedge reset_n)
        if (!reset_n)
          gshare1_predictor[{i[(GS1_BITS-5):0], j[3:0]}] <= 2'b00;
        else if (gshare1_en[i])
          gshare1_predictor[{i[(GS1_BITS-5):0], j[3:0]}] <= nxt_gshare1_predictor[{i[(GS1_BITS-5):0], j[3:0]}];
    end
  end
  endgenerate

  // ------------------------------------------------------
  // Speculative Meta Predictor Lookup
  // ------------------------------------------------------

  // If there was not a prediction in the last cycle the virtual address is either from IF3
  // if the buffer has not cleared or IF2 if a new entry will be added.
  assign muxed_abuf_va_if3 = avalid_if3_i ? abuf_va_if3_i[(GS0_BITS+2):3] : va_if2_i[(GS0_BITS+2):3];

  assign sp_meta_index_abuf = muxed_abuf_va_if3[(META_BITS-1):0];
  assign sp_meta_index_bbuf = abuf_va_plus1_if3_i[(META_BITS+2):3];
  assign sp_meta_index_cbuf = abuf_va_plus2_if3_i[(META_BITS+2):3];

  assign meta_pred_abuf = meta_predictor[sp_meta_index_abuf][1];
  assign meta_pred_bbuf = meta_predictor[sp_meta_index_bbuf][1];
  assign meta_pred_cbuf = meta_predictor[sp_meta_index_cbuf][1];

  // ------------------------------------------------------
  // Speculative Bimodal Predictor Lookup
  // ------------------------------------------------------

  assign sp_bimodal_index_abuf      = muxed_abuf_va_if3[(BIM_BITS-1):0];
  assign sp_bimodal_index_bbuf      = abuf_va_plus1_if3_i[(BIM_BITS+2):3];
  assign sp_bimodal_index_cbuf      = abuf_va_plus2_if3_i[(BIM_BITS+2):3];
  assign sp_bimodal_index_abuf_btic = btic_abuf_va_if3_i[(BIM_BITS+2):3];
  assign sp_bimodal_index_bbuf_btic = btic_bbuf_va_if3_i[(BIM_BITS+2):3];

  assign bimodal_pred_abuf      = bimodal_predictor[sp_bimodal_index_abuf][1];
  assign bimodal_pred_bbuf      = bimodal_predictor[sp_bimodal_index_bbuf][1];
  assign bimodal_pred_cbuf      = bimodal_predictor[sp_bimodal_index_cbuf][1];
  assign bimodal_pred_abuf_btic = bimodal_predictor[sp_bimodal_index_abuf_btic][1];
  assign bimodal_pred_bbuf_btic = bimodal_predictor[sp_bimodal_index_bbuf_btic][1];

  // ------------------------------------------------------
  // Speculative GShare-0 Predictor Lookup
  // ------------------------------------------------------
  //
  // GShare register packing in to if3 for use in the next cycle:
  //
  // - ABuffer, no-prediction current cycle OR Abuf is empty and the address comes from if2
  // - ABuffer, prediction current cycle (NT)
  // - BBuffer, no-prediction current cycle
  // - BBuffer, prediction current cycle (NT)
  // - CBuffer, no-prediction current cycle
  // - CBuffer, prediction current cycle (NT)
  //
  // The calculation must operate every cycle to cope with the case where there are multiple
  // branches within buffers that are sequentially predicted.

  // Construct the hash:
  // {2'b00, History[0:7]} XOR VA[12:3]
  assign sp_gshare0_hist_npred = {{2{1'b0}}, sp_gh_reg[0], sp_gh_reg[1], sp_gh_reg[2], sp_gh_reg[3], sp_gh_reg[4], sp_gh_reg[5], sp_gh_reg[6], sp_gh_reg[7]};
  assign sp_gshare0_hist_pred  = {{2{1'b0}}, 1'b0,         sp_gh_reg[0], sp_gh_reg[1], sp_gh_reg[2], sp_gh_reg[3], sp_gh_reg[4], sp_gh_reg[5], sp_gh_reg[6]};

  // Generate speculative indexes in to the GShare-0 predictor
  assign sp_gshare0_index_abuf_npred = sp_gshare0_hist_npred[(GS0_BITS-1):0] ^ muxed_abuf_va_if3[9:0];
  assign sp_gshare0_index_abuf_pred  = sp_gshare0_hist_pred[(GS0_BITS-1):0]  ^ abuf_va_if3_i[(GS0_BITS+2):3];
  assign sp_gshare0_index_bbuf_npred = sp_gshare0_hist_npred[(GS0_BITS-1):0] ^ abuf_va_plus1_if3_i[(GS0_BITS+2):3];
  assign sp_gshare0_index_bbuf_pred  = sp_gshare0_hist_pred[(GS0_BITS-1):0]  ^ abuf_va_plus1_if3_i[(GS0_BITS+2):3];
  assign sp_gshare0_index_cbuf_npred = sp_gshare0_hist_npred[(GS0_BITS-1):0] ^ abuf_va_plus2_if3_i[(GS0_BITS+2):3];
  assign sp_gshare0_index_cbuf_pred  = sp_gshare0_hist_pred[(GS0_BITS-1):0]  ^ abuf_va_plus2_if3_i[(GS0_BITS+2):3];

  // Lookup using the speculative indexes
  assign sp_gshare0_abuf_npred = gshare0_predictor[sp_gshare0_index_abuf_npred][1];
  assign sp_gshare0_abuf_pred  = gshare0_predictor[sp_gshare0_index_abuf_pred][1];
  assign sp_gshare0_bbuf_npred = gshare0_predictor[sp_gshare0_index_bbuf_npred][1];
  assign sp_gshare0_bbuf_pred  = gshare0_predictor[sp_gshare0_index_bbuf_pred][1];
  assign sp_gshare0_cbuf_npred = gshare0_predictor[sp_gshare0_index_cbuf_npred][1];
  assign sp_gshare0_cbuf_pred  = gshare0_predictor[sp_gshare0_index_cbuf_pred][1];

  // Select between the predicted versions
  assign gshare0_pred_abuf = sp_branch_raw_if3 ? sp_gshare0_abuf_pred : sp_gshare0_abuf_npred;
  assign gshare0_pred_bbuf = sp_branch_raw_if3 ? sp_gshare0_bbuf_pred : sp_gshare0_bbuf_npred;
  assign gshare0_pred_cbuf = sp_branch_raw_if3 ? sp_gshare0_cbuf_pred : sp_gshare0_cbuf_npred;

  // ------------------------------------------------------
  // Speculative GShare-1 Predictor Lookup
  // ------------------------------------------------------
  //
  // Same methodology as the GShare-0 lookup

  // Construct the hash:
  // {5'b00000, History[0:4]} XOR VA[3:12]
  assign sp_gshare1_hist_npred = {{5{1'b0}}, sp_gh_gs1_reg[0], sp_gh_gs1_reg[1], sp_gh_gs1_reg[2], sp_gh_gs1_reg[3], sp_gh_gs1_reg[4]};
  assign sp_gshare1_hist_pred  = {{5{1'b0}}, 1'b0,             sp_gh_gs1_reg[0], sp_gh_gs1_reg[1], sp_gh_gs1_reg[2], sp_gh_gs1_reg[3]};

  assign muxed_abuf_va_if3_hash = {muxed_abuf_va_if3[0],   muxed_abuf_va_if3[1],   muxed_abuf_va_if3[2],    muxed_abuf_va_if3[3],    muxed_abuf_va_if3[4],
                                   muxed_abuf_va_if3[5],   muxed_abuf_va_if3[6],   muxed_abuf_va_if3[7],    muxed_abuf_va_if3[8],    muxed_abuf_va_if3[9]};
  assign abuf_va_if3_hash       = {abuf_va_if3_i[3],       abuf_va_if3_i[4],       abuf_va_if3_i[ 5],       abuf_va_if3_i[ 6],       abuf_va_if3_i[ 7],
                                   abuf_va_if3_i[8],       abuf_va_if3_i[9],       abuf_va_if3_i[10],       abuf_va_if3_i[11],       abuf_va_if3_i[12]};
  assign abuf_va_plus1_if3_hash = {abuf_va_plus1_if3_i[3], abuf_va_plus1_if3_i[4], abuf_va_plus1_if3_i[ 5], abuf_va_plus1_if3_i[ 6], abuf_va_plus1_if3_i[ 7],
                                   abuf_va_plus1_if3_i[8], abuf_va_plus1_if3_i[9], abuf_va_plus1_if3_i[10], abuf_va_plus1_if3_i[11], abuf_va_plus1_if3_i[12]};
  assign abuf_va_plus2_if3_hash = {abuf_va_plus2_if3_i[3], abuf_va_plus2_if3_i[4], abuf_va_plus2_if3_i[ 5], abuf_va_plus2_if3_i[ 6], abuf_va_plus2_if3_i[ 7],
                                   abuf_va_plus2_if3_i[8], abuf_va_plus2_if3_i[9], abuf_va_plus2_if3_i[10], abuf_va_plus2_if3_i[11], abuf_va_plus2_if3_i[12]};

  // Generate speculative indexes in to the GShare-0 predictor
  assign sp_gshare1_index_abuf_npred = sp_gshare1_hist_npred[(GS1_BITS-1):0] ^ muxed_abuf_va_if3_hash;
  assign sp_gshare1_index_abuf_pred  = sp_gshare1_hist_pred[(GS1_BITS-1):0]  ^ abuf_va_if3_hash;
  assign sp_gshare1_index_bbuf_npred = sp_gshare1_hist_npred[(GS1_BITS-1):0] ^ abuf_va_plus1_if3_hash;
  assign sp_gshare1_index_bbuf_pred  = sp_gshare1_hist_pred[(GS1_BITS-1):0]  ^ abuf_va_plus1_if3_hash;
  assign sp_gshare1_index_cbuf_npred = sp_gshare1_hist_npred[(GS1_BITS-1):0] ^ abuf_va_plus2_if3_hash;
  assign sp_gshare1_index_cbuf_pred  = sp_gshare1_hist_pred[(GS1_BITS-1):0]  ^ abuf_va_plus2_if3_hash;

  // Lookup using the speculative indexes
  assign sp_gshare1_abuf_npred = gshare1_predictor[sp_gshare1_index_abuf_npred][1];
  assign sp_gshare1_abuf_pred  = gshare1_predictor[sp_gshare1_index_abuf_pred][1];
  assign sp_gshare1_bbuf_npred = gshare1_predictor[sp_gshare1_index_bbuf_npred][1];
  assign sp_gshare1_bbuf_pred  = gshare1_predictor[sp_gshare1_index_bbuf_pred][1];
  assign sp_gshare1_cbuf_npred = gshare1_predictor[sp_gshare1_index_cbuf_npred][1];
  assign sp_gshare1_cbuf_pred  = gshare1_predictor[sp_gshare1_index_cbuf_pred][1];

  // Select between the predicted versions
  assign gshare1_pred_abuf = sp_branch_raw_if3 ? sp_gshare1_abuf_pred : sp_gshare1_abuf_npred;
  assign gshare1_pred_bbuf = sp_branch_raw_if3 ? sp_gshare1_bbuf_pred : sp_gshare1_bbuf_npred;
  assign gshare1_pred_cbuf = sp_branch_raw_if3 ? sp_gshare1_cbuf_pred : sp_gshare1_cbuf_npred;

  // ------------------------------------------------------
  // Resolve and register predictions
  // ------------------------------------------------------
  //
  // Resolve the Meta, Bimodal and GShare predictions for the next cycle in this cycle.
  //
  // The approach we take is to lookup in the Meta, Bimodal, GShare-0 and GShare-1 tables for
  // all possible combinations of ABuf, BBuf and CBuf in the following cycle.  We have to be
  // able to propagate predictions in to the next cycle when we've crossed buffers.  We also
  // have to deal with the rare case where we cross buffers this cycle and instruction-1 is in
  // what is the CBuffer in this cycle.  This is possible if we pushed two 32-bit instructions
  // in this cycle from what is the ABuf + BBuf and in the next we'll be dealing with two 32-bit
  // instructions from what is the BBuf + CBuf in this cycle.
  //
  // If there is a BTIC hit in this cycle then force Meta prediction for the following prediction
  // cycle as there isn't enough time to create a speculative GShare based prediction.

  // Meta buffer resolution
  assign nxt_meta_pred_i0      = btic_hit_if3_i | (next64_if3_i ? meta_pred_bbuf : meta_pred_abuf);
  assign nxt_meta_pred_i1_xbuf = btic_hit_if3_i | (next64_if3_i ? meta_pred_cbuf : meta_pred_bbuf);

  // Bimodal prediction resolution
  assign nxt_bimodal_pred_i0      = btic_hit_if3_i ? bimodal_pred_abuf_btic : next64_if3_i ? bimodal_pred_bbuf : bimodal_pred_abuf;
  assign nxt_bimodal_pred_i1_xbuf = btic_hit_if3_i ? bimodal_pred_bbuf_btic : next64_if3_i ? bimodal_pred_cbuf : bimodal_pred_bbuf;

  // GShare-0 prediction resolution
  assign nxt_gshare0_pred_i0      = next64_if3_i ? gshare0_pred_bbuf : gshare0_pred_abuf;
  assign nxt_gshare0_pred_i1_xbuf = next64_if3_i ? gshare0_pred_cbuf : gshare0_pred_bbuf;

  // GShare-1 prediction resolution
  assign nxt_gshare1_pred_i0      = next64_if3_i ? gshare1_pred_bbuf : gshare1_pred_abuf;
  assign nxt_gshare1_pred_i1_xbuf = next64_if3_i ? gshare1_pred_cbuf : gshare1_pred_bbuf;

  // Create enable:
  // - When we push instructions to the DPU
  // - We are not pushing an instruction just because such instruction carried a PDC
  // - If there was an empty FQ in the current cycle or a prediction update was made.
  // - If there was an empty FQ in the last cycle or if a prediction update was made then enable
  //   again as we need to update predictions based on the va_abuf_if3+1 and va_abuf_if3+2 addresses
  //   which aren't available in the cycle where the FQ is empty and va_if2 is the only address
  //   available to us.
  // - BTIC hit
  // - When a debug instruction is seen a prediction needs to be propagated because it will
  //   influence the result of the meta structure.
  assign empty_fq_or_update = (~avalid_if3_i & valid_if2_i) | cm_branch_i;

  assign sp_pred_en = pfb_push_i[0] | instr0_pdec_err_i | empty_fq_or_update | last_empty_fq_or_update | last_btic_hit | dbg_valid_if2_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      meta_pred_i0            <= 1'b0;
      meta_pred_i1_xbuf       <= 1'b0;
      bimodal_pred_i0         <= 1'b0;
      bimodal_pred_i1_xbuf    <= 1'b0;
      gshare0_pred_i0         <= 1'b0;
      gshare0_pred_i1_xbuf    <= 1'b0;
      gshare1_pred_i0         <= 1'b0;
      gshare1_pred_i1_xbuf    <= 1'b0;
      ip_if3                  <= 2'b00;
      last_btic_hit           <= 1'b0;
      last_empty_fq_or_update <= 1'b0;
    end
    else if (sp_pred_en) begin
      meta_pred_i0            <= nxt_meta_pred_i0;
      meta_pred_i1_xbuf       <= nxt_meta_pred_i1_xbuf;
      bimodal_pred_i0         <= nxt_bimodal_pred_i0;
      bimodal_pred_i1_xbuf    <= nxt_bimodal_pred_i1_xbuf;
      gshare0_pred_i0         <= nxt_gshare0_pred_i0;
      gshare0_pred_i1_xbuf    <= nxt_gshare0_pred_i1_xbuf;
      gshare1_pred_i0         <= nxt_gshare1_pred_i0;
      gshare1_pred_i1_xbuf    <= nxt_gshare1_pred_i1_xbuf;
      ip_if3                  <= nxt_ip_if3_i[2:1];
      last_btic_hit           <= btic_hit_if3_i;
      last_empty_fq_or_update <= empty_fq_or_update;
    end

  // ------------------------------------------------------
  // Prediction Resolution
  // ------------------------------------------------------
  //
  // Choose between bimodal predictor and the majority vote of the GShare and Bimodal
  // predictors.

  // Majority vote of GShare and Bimodal predictors
  assign majority_vote_i0      = (gshare0_pred_i0      & gshare1_pred_i0)      | (gshare0_pred_i0      & bimodal_pred_i0)      | (gshare1_pred_i0      & bimodal_pred_i0     );
  assign majority_vote_i1_xbuf = (gshare0_pred_i1_xbuf & gshare1_pred_i1_xbuf) | (gshare0_pred_i1_xbuf & bimodal_pred_i1_xbuf) | (gshare1_pred_i1_xbuf & bimodal_pred_i1_xbuf);

  // Resolve instruction-0 and buffer crossing prediction
  assign taken_i0      = meta_pred_i0      ? ~bimodal_pred_i0      : ~majority_vote_i0;
  assign taken_i1_xbuf = meta_pred_i1_xbuf ? ~bimodal_pred_i1_xbuf : ~majority_vote_i1_xbuf;

  // Determine if instruction-1 is in the buffer above instruction-0 which would force the
  // buffer crossing prediction to be used
  assign select_i1_xbuf = ((~instr_is_thumb_bpd_if3_i & ip_if3[2]                      ) |
                           ( instr_is_thumb_bpd_if3_i & ip_if3[2] & abuf_mid_poss_t32_i) |
                           (                            ip_if3[2] & ip_if3[1]));

  assign taken_i1 = select_i1_xbuf ? taken_i1_xbuf : taken_i0;

  assign taken = (brn_predicted_if3_i[0] & ~instr_abt_if3_i & taken_i0) | (brn_predicted_if3_i[1] & instr_valid_if3_i[1] & instr1_possible_i & taken_i1);

  // Create correlation indicators for the majority vote and bimodal.  To do this we must know
  // whether the branch instruction was in instr-0 or instr-1.  The correlation indicators are
  // used to update the predictors in the commit stage so we must know which entry we are
  // predicting against.
  //
  // Force correlation indicator if there was a BTIC hit in the last cycle.
  assign correlate_pred_bimodal  = last_btic_hit | (sp_branch_i0_raw_if3 & ~bimodal_pred_i0)  | (sp_branch_i1_raw_if3 & (select_i1_xbuf ? ~bimodal_pred_i1_xbuf  : ~bimodal_pred_i0));
  assign correlate_pred_majority = last_btic_hit | (sp_branch_i0_raw_if3 & ~majority_vote_i0) | (sp_branch_i1_raw_if3 & (select_i1_xbuf ? ~majority_vote_i1_xbuf : ~majority_vote_i0));

  assign pred_meta    =  last_btic_hit | (sp_branch_i0_raw_if3 ?     meta_pred_i0 : (select_i1_xbuf ?     meta_pred_i1_xbuf :     meta_pred_i0));
  assign pred_bimodal =                  (sp_branch_i0_raw_if3 ? ~bimodal_pred_i0 : (select_i1_xbuf ? ~bimodal_pred_i1_xbuf : ~bimodal_pred_i0));
  assign pred_gshare0 = ~last_btic_hit & (sp_branch_i0_raw_if3 ? ~gshare0_pred_i0 : (select_i1_xbuf ? ~gshare0_pred_i1_xbuf : ~gshare0_pred_i0));
  assign pred_gshare1 = ~last_btic_hit & (sp_branch_i0_raw_if3 ? ~gshare1_pred_i0 : (select_i1_xbuf ? ~gshare1_pred_i1_xbuf : ~gshare1_pred_i0));

  // Output assignments
  assign taken_i0_if3_o = taken_i0;
  assign taken_i1_if3_o = taken_i1;

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_addr_gshare0_hi_wr_en")
  u_ovl_x_br_addr_gshare0_hi_wr_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (br_addr_gshare0_hi_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_addr_gshare0_lo_wr_en")
  u_ovl_x_br_addr_gshare0_lo_wr_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (br_addr_gshare0_lo_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_addr_gshare1_hi_wr_en")
  u_ovl_x_br_addr_gshare1_hi_wr_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (br_addr_gshare1_hi_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_addr_gshare1_lo_wr_en")
  u_ovl_x_br_addr_gshare1_lo_wr_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (br_addr_gshare1_lo_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cm_mispredicted_i")
  u_ovl_x_cm_mispredicted_i (.clk       (clk_bpd),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (cm_mispredicted_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_pred_br_ex2_i")
  u_ovl_x_dpu_pred_br_ex2_i (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (dpu_pred_br_ex2_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: correlation_read_ptr_en")
  u_ovl_x_correlation_read_ptr_en (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (correlation_read_ptr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sp_branch_if3")
  u_ovl_x_sp_branch_if3 (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (sp_branch_if3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sp_pred_en")
  u_ovl_x_sp_pred_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (sp_pred_en));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Register enable x-check: meta_en")
  u_ovl_x_meta_en (.clk       (clk_bpd),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (meta_en));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Register enable x-check: bimodal_en")
  u_ovl_x_bimodal_en (.clk       (clk_bpd),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (bimodal_en));

  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "Register enable x-check: gshare0_en")
  u_ovl_x_gshare0_en (.clk       (clk_bpd),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (gshare0_en));

  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "Register enable x-check: gshare1_en")
  u_ovl_x_gshare1_en (.clk       (clk_bpd),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (gshare1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cm_gh_we")
  u_ovl_x_cm_gh_we (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (cm_gh_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sp_gh_we")
  u_ovl_x_sp_gh_we (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (sp_gh_we));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "correlation_read_ptr Illegal value")
    ovl_read_ptr (.clk       (clk),
                  .reset_n   (reset_n),
                  .test_expr (correlation_read_ptr[3:0] == 4'hc |
                              correlation_read_ptr[3:0] == 4'hd |
                              correlation_read_ptr[3:0] == 4'he));
`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
