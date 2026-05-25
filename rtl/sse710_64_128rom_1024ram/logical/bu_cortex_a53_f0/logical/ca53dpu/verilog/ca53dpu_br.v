//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
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
//Abstract: The branch execution pipeline in the DPU
//-----------------------------------------------------------------------------
// Description:
//       The branch pipeline is responsible for the majority of the IFU
//  interface. The branch pipeline
//  * calculates whether a mispredict has occurred during both
//    direct and indirect forms of branch;
//  * calculates the values of the address partial products associated with
//    direct branches that have mispredicted;
//  * exports branch prediction signals to the IFU;
//  * handles corner cases where branches are back to back in the pipeline,
//    and ensures that only the oldest branch causes a flush
//
// Direct, conditional branches and indirect branches which ccfail a taken
// prediction flush from the Wr stage.  This is because direct branches and
// indirect branches that should not have been taken can have their address
// determined at any point in the pipeline.
//
// All other indirect branches (and exceptions) flush from the Ret stage.
// This includes any unpredicted DP operations that write the PC and any load
// instructions to the PC.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_br (
  // Inputs
  input  wire                          clk,
  input  wire                          reset_n,
  input  wire                          DFTSE,
  input  wire                          aarch64_state_i,
  input  wire                          rtn_addr_valid_de_i,
  input  wire                   [27:1] br_offset_de_i,                  // Immediate branch offset
  input  wire [`CA53_BR_PIPECTL_W-1:0] br_pipectl_de_i,                 // Branch pipeline control
  input  wire                          br_valid_de_i,                   // Valid branch instr in pipeline
  input  wire                   [63:0] st0_data_wr_i,                   // Target address for register based branch (slot 0 branch)
  input  wire                   [63:0] st1_data_wr_i,                   // Target address for register based branch (slot 1 branch)
  input  wire                   [15:0] ld_data0_wr_i,                   // Load data from swizzler
  input  wire                   [63:0] fwd_ld_data_int_wr_i,            // Early load data, not sign extended
  input  wire                   [31:0] alu0_fwd_data_early_wr_i,        // Data from main datapath (indirect branch)
  input  wire                    [1:0] isa_instr0_ex2_i,                // ISA of instr in pipeline
  input  wire                          size_instr0_ex2_i,               // Size of slot-0 instruction
  input  wire                          size_instr1_ex2_i,               // Size of slot-1 instruction
  input  wire                          br_pred_takenness_de_i,          // Branch prediction from IFU
  input  wire                          cc_pass_instr0_cbz_ex2_i,        // Slot-0 condition code pass/fail
  input  wire                          cc_pass_instr1_cbz_ex2_i,        // Slot-1 condition code pass/fail
  input  wire                          cc_pass_instr0_wr_i,             // Slot-0 condition code pass/fail in wr stage
  input  wire                          cc_pass_instr1_wr_i,             // Slot-1 condition code pass/fail in wr stage
  input  wire                          dpu_pred_br_de_i,                // Branch was predicted by the IFU
  input  wire                          dpu_br_return_de_i,              // Branch is a return (affects CRS pointers)
  input  wire                          dpu_br_call_de_i,                // Branch is a call (affects CRS pointers)
  input  wire                          br_btac_de_i,                    // Branch is btac'able
  input  wire                          slot1_branch_ex2_i,              // Branch in Ex2 is in Slot 1
  input  wire                          slot1_branch_wr_i,               // Branch in Wr is in Slot 1
  input  wire                          issue_to_ex1_i,                  // Pipeline advancement
  input  wire                          issue_to_ex2_i,                  // Pipeline advancement
  input  wire                          issue_to_wr_i,                   // Pipeline advancement
  input  wire                          stall_wr_i,                      // Pipeline stall
  input  wire                          stall_iss_i,                     // Pipeline stall
  input  wire                          stall_br_iss_i,                  // Pipeline stall
  input  wire                          exception_valid_ex1_i,           // Early exception detected in Ex1
  input  wire                          isb_wr_i,                        // An ISB instruction is in Wr
  input  wire                          expt_rtn_wr_i,                   // An exception return is in Wr
  input  wire                          insert_forceop_wr_i,             // Forceop is being inserted by exception in Wr
  input  wire                          insert_forceop_ret_i,            // Forceop is being inserted by exception in Ret
  input  wire                   [63:0] forceop_pc_ret_i,                // Forceop PC component of address
  input  wire                   [17:1] forceop_pc_offset_ret_i,         // Offset for forceop PC address for indirect branches
  input  wire                          in_halt_i,                       // DPU in debug HALT mode
  input  wire                          quash_ex2_i,                     // Branch in Ex2 being quashed
  input  wire                          expt_quash_wr_i,                 // Expt is predicted to be flushing from Ret
  input  wire                   [48:1] pc_instr0_ex2_i,                 // Raw PC in the Ex2 (for return packet compare)
  input  wire                   [63:0] pc_instr0_wr_i,                  // PC in Wr
  input  wire                          flush_wr_i,                      // Flush from Wr
  input  wire                          flush_ret_i,                     // Flush from Ret
  input  wire                          advance_pipeline_i,              // Main pipeline advance from ctl block
  input  wire                          quash_wr_i,                      // Kill operation in WR
  input  wire                          nxt_wfx_ifu_halt_i,              // WFx in Wr (will be asserting halt to IFU)
  input  wire                          wfx_ifu_halt_i,                  // WFx requesting IFU to halt
  input  wire                          force_wfx_nop_i,                 // WFx instruction turned into a NOP
  input  wire                          isa_switch_br_ex2_i,             // BX/BLX (imm) in Ex2 (from CPSR)
  input  wire                          nxt_cpsr_tbit_ret_pre_i,         // T-bit from CPSR (unqualified)
  input  wire                          ongoing_ldm_wr_i,                // Load data from the top 32-bits
  input  wire                          sel_rf_wr_w0_wr_i,               // W0 port is being selected
  input  wire                   [48:0] ifu_pred_addr_if4_i,             // Predicted indirect branch address
  input  wire                          ifu_pred_addr_valid_if4_i,       // Predicted address valid
  input  wire                          branch_align_pc_wr_i,            // Branch from Ret should align target address
  input  wire                          debug_exit_aa32_i,               // Debug state exit targetting AArch32 is being performed
  input  wire                    [1:0] dpu_exception_level_i,           // Current exception level
  input  wire                    [1:0] tlb_d_tcr_el1_tbi_i,             // TCR_EL1.TBIx bits
  input  wire                          tlb_d_tcr_el2_tbi0_i,            // TCR_EL2.TBI bit
  input  wire                          tlb_d_tcr_el3_tbi0_i,            // TCR_EL3.TBI bit
  // Outputs
  output wire                   [48:1] rtn_addr_iss_o,                  // Predicted address for indirect branch in Iss stage
  output wire                   [27:1] br_offset_iss_o,                 // Target offset for direct branch in Iss stage
  output wire                          tbit_btac_rtn_instr_iss_o,       // New T-bit from btac/return instruction
  output wire                          dpu_pred_br_ex2_o,               // Branch was predicted by the IFU
  output wire                   [12:3] dpu_br_addr_ex2_o,               // Ex2 branch address
  output wire                          dpu_pred_br_wr_o,                // Branch was predicted by the IFU
  output wire                          dpu_br_return_wr_o,              // Branch is a return event
  output wire                          dpu_br_call_wr_o,                // Branch is a call
  output wire                          dpu_btac_ret_o,                  // Branch is BTAC'able
  output wire                          dpu_mispred_wr_o,                // Branch direction mispredicted by the IFU
  output wire                          dpu_br_taken_wr_o,               // Indicates *actual* outcome branch
  output wire                          dpu_fe_valid_ret_o,              // IFU flush force (indirect Br), start fetching from new addr
  output wire                   [63:0] dpu_fe_addr_opa_ret_o,           // Force address operand A from indirect branch
  output wire                   [17:1] dpu_fe_addr_opb_ret_o,           // Force address operand B from indirect branch
  output wire                          dpu_fe_context_sync_ret_o,       // Force from Ret is a context synchronisation operation
  output wire                          dpu_valid_branch_instr_wr_o,     // Valid branch in Wr
  output wire                          prefetch_flush_wr_o,             // IFU flush in Wr
  output wire                          br_direct_wr_o,                  // Branch in Wr is direct/indirect
  output wire                          br_pred_takenness_wr_o,          // Predicted takenness of branch in Wr
  output wire                          mis_predicted_branch_wr_o,       // Whether branch in Wr was mispredicted on takenness
  output wire                          br_call_wr_o,                    // Branch in Wr is a call instruction
  output wire                          evnt_br_valid_wr_o,              // Branch in Wr event
  output wire                          evnt_br_mispred_o,               // Branch was not or could not be predicted
  output wire                          evnt_br_direct_wr_o,             // Branch in Wr is a direct event
  output wire                          evnt_br_indirect_o,              // Branch is an indirect event
  output wire                          evnt_br_indirect_mispred_o,      // Branch is an indirect event that's been mispredicted
  output wire                          evnt_br_indirect_mispred_addr_o, // Branch is an indirect event that's been mispredicted on the address
  output wire                          evnt_sw_change_pc_o,             // Branch of any variant
  output wire                          br_flush_wr_o,                   // Branch flushing from Wr
  output wire                          slot0_br_flush_wr_o,             // Slot0 Branch flushing from Wr
  output wire                          br_flush_ret_o,                  // Branch flushing from Ret
  output wire                          btac_rtn_instr_iss_o,            // PT btac/return instruction in Iss (higher priority)
  output wire                          taken_br_instr_iss_o,            // PT branch instruction is Iss (lower priority)
  output wire                          ld_t_bit_wr_o,                   // Carries new T-Bit to CPSR pipe (indirect branches)
  output wire                          incr_pc_halt_mode_ret_o,         // Increment the PC in debug halt mode (DP->PC)
  output wire                          dpu_fe_valid_wr_o,               // IFU flush force (direct Br), start fetching from new addr
  output wire                   [48:1] dpu_fe_addr_opa_wr_o,            // Operand-A of Wr stage force
  output wire                   [27:1] dpu_fe_addr_opb_wr_o,            // Operand-B of Wr stage force
  output wire                          paq_full_o,                      // PAQ is full
  output wire                          paq_stall_iss_o                  // Empty PAQ should cause a stall
);

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar i;

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  localparam PAQ_ENTRIES = 4;
  localparam PAQ_PTR_W   = 4;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           [PAQ_PTR_W-1:0] paq_rd_ptr;
  reg           [PAQ_PTR_W-1:0] paq_wr_ptr;
  reg                           paq_full;
  reg                           paq_empty;
  reg  [`CA53_BR_PIPECTL_W-1:0] br_pipectl_iss;
  reg  [`CA53_BR_PIPECTL_W-1:0] br_pipectl_ex1;
  reg  [`CA53_BR_PIPECTL_W-1:0] br_pipectl_ex2;
  reg  [`CA53_BR_PIPECTL_W-1:0] br_pipectl_wr;
  reg                           dpu_pred_br_iss;
  reg                           dpu_br_return_iss;
  reg                           dpu_br_call_iss;
  reg                           br_btac_iss;
  reg                           br_valid_iss;
  reg                    [27:1] br_offset_iss;
  reg                           br_pred_takenness_iss;
  reg                           rtn_addr_valid_iss;
  reg                           dpu_pred_br_ex1;
  reg                           dpu_br_return_ex1;
  reg                           dpu_br_call_ex1;
  reg                           br_btac_ex1;
  reg                           br_valid_ex1;
  reg                    [27:1] br_offset_ex1;
  reg                           br_pred_takenness_ex1;
  reg                           dpu_pred_br_ex2;
  reg                           dpu_br_return_ex2;
  reg                           dpu_br_call_ex2;
  reg                           br_btac_ex2;
  reg                           br_valid_ex2;
  reg                    [27:1] br_offset_ex2;
  reg                           br_pred_takenness_ex2;
  reg                     [2:1] dpu_fe_twiddle_t_ex2;
  reg                     [4:1] dpu_fe_twiddle_nt_ex2;
  reg                           dpu_pred_br_wr;
  reg                           dpu_br_return_wr;
  reg                           dpu_br_call_wr;
  reg                           br_btac_wr;
  reg                    [27:1] br_direct_opb_wr;
  reg                           br_pred_takenness_wr;
  reg                           dpu_fe_valid_wr;
  reg                           slot0_br_flush_wr;
  reg                           dpu_br_taken_wr;
  reg                           dpu_mispred_wr;
  reg                           br_valid_wr;
  reg                           pc_instr0_1to0_wr;
  reg                    [63:0] operand_a_wr;
  reg                    [17:1] operand_b_wr;
  reg                           ld_t_bit_wr;
  reg                           correctly_pred_taken_ind_br_wr;
  reg                           mis_predicted_branch_wr;
  reg                           br_call_wr;
  reg                           incr_pc_halt_mode_ret;
  reg                    [63:0] dpu_fe_addr_opa_ret;
  reg                    [17:1] dpu_fe_addr_opb_ret;
  reg                           dpu_fe_context_sync_ret;
  reg                           dpu_fe_valid_ret;
  reg                           br_btac_ret;
  reg                    [48:0] rtn_addr_iss;
  reg                    [48:0] paq_entry [PAQ_ENTRIES-1:0];
  reg                           comparison_pass_ret;
  reg                           evnt_fe_valid_ind_br_ret;
  reg                           aarch64_state_rs;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                          clk_br_ex1;
  wire                          clk_br_ex2;
  wire                          clk_br_wr;
  wire                          en_clk_br_ex1;
  wire                          en_clk_br_ex2;
  wire                          en_clk_br_wr;
  wire                   [63:0] nxt_dpu_fe_addr_opa_ret;
  wire                   [17:1] nxt_dpu_fe_addr_opb_ret;
  wire                          nxt_dpu_fe_context_sync_ret;
  wire          [PAQ_PTR_W-1:0] nxt_paq_rd_ptr;
  wire          [PAQ_PTR_W-1:0] nxt_paq_wr_ptr;
  wire                          nxt_paq_full;
  wire                          nxt_paq_empty;
  wire                          paq_ptr_en;
  wire                          paq_push;
  wire                          paq_pop;
  wire                   [12:1] br_addr_ex2;
  wire                          nxt_br_valid_iss;
  wire                          nxt_br_valid_ex1;
  wire                          nxt_br_valid_ex2;
  wire                          nxt_br_valid_wr;
  wire                   [27:1] nxt_br_direct_opb_wr;
  wire                          nxt_dpu_fe_valid_ret;
  wire                          dpu_mispred_ex2;
  wire                          dpu_fe_valid_ex2;
  wire                          br_direct_wr;
  wire                          nxt_correctly_pred_taken_ind_br_wr;
  wire                          nxt_dpu_pred_br_wr;
  wire                          nxt_dpu_br_return_wr;
  wire                          nxt_dpu_br_call_wr;
  wire                          nxt_br_btac_wr;
  wire                          nxt_dpu_fe_valid_wr;
  wire                          nxt_dpu_mispred_wr;
  wire                          nxt_dpu_br_taken_wr;
  wire                          nxt_slot0_br_flush_wr;
  wire                          nxt_pc_instr0_1to0_wr;
  wire                          enable_prediction_signals_ex2;
  wire [`CA53_BR_PIPECTL_W-1:0] nxt_br_pipectl_wr;
  wire                          oneshot_en_wr;
  wire                          oneshot_en_ret;
  wire                          dpu_fe_addr_ret_en;
  wire                          dpu_fe_valid_ind_br_wr;
  wire                          ret_force_wr;
  wire                          ignore_top_byte;
  wire                          comparison_pass_wr;
  wire                   [48:1] instr0_addr_ex2;
  wire                    [3:1] arch_offset_wr;
  wire                          nxt_incr_pc_halt_mode_ret;
  wire                          nxt_br_btac_ret;
  wire                          pre_dpu_fe_valid_ind_br_wr;
  wire                          branch_in_slot1_ex2;
  wire                   [48:1] br_direct_opa_wr;
  wire                          dpu_valid_branch_instr_wr;
  wire                          prefetch_flush_wr;
  wire                          pc_bit1_mask;
  wire                   [63:0] br_st_data_wr;
  wire        [PAQ_ENTRIES-1:0] paq_entry_en;
  wire                          evnt_br_valid_wr;
  wire                          nxt_evnt_fe_valid_ind_br_ret;
  wire                          advance_br_pipeline_iss;
  wire                          br_offset_iss_en;
  wire                          br_offset_ex1_en;
  wire                          br_offset_ex2_en;
  wire                          br_direct_opb_wr_en;
  wire                          br_iss_en;
  wire                          br_ex1_en;
  wire                          br_ex2_en;
  wire                          br_wr_en;
  wire                          advance_br_pipeline;
  wire                          br_cc_pass_wr;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Predicted address queue
  // ------------------------------------------------------

  assign paq_push = ifu_pred_addr_valid_if4_i;
  assign paq_pop  = br_valid_iss & rtn_addr_valid_iss & ~stall_br_iss_i & ~flush_wr_i;

  generate for (i=0; i<PAQ_ENTRIES; i=i+1) begin : g_paq_entries

    assign paq_entry_en[i] = paq_wr_ptr[i] & paq_push;

    always @(posedge clk)
      if (paq_entry_en[i])
        paq_entry[i][48:0] <= ifu_pred_addr_if4_i[48:0];

  end endgenerate

  // Pointers
  assign nxt_paq_rd_ptr = flush_wr_i ? 4'b0001 : (paq_pop  ? {paq_rd_ptr[2:0], paq_rd_ptr[3]} : paq_rd_ptr);
  assign nxt_paq_wr_ptr = flush_wr_i ? 4'b0001 : (paq_push ? {paq_wr_ptr[2:0], paq_wr_ptr[3]} : paq_wr_ptr);
  assign nxt_paq_full   = ~flush_wr_i &   paq_push & ~paq_pop & (nxt_paq_wr_ptr == paq_rd_ptr);
  assign nxt_paq_empty  =  flush_wr_i | (~paq_push &  paq_pop & (nxt_paq_rd_ptr == paq_wr_ptr));

  assign paq_ptr_en     = flush_wr_i | paq_push | paq_pop;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      paq_rd_ptr <= 4'b0001;
      paq_wr_ptr <= 4'b0001;
      paq_full   <= 1'b0;
      paq_empty  <= 1'b1;
    end else if (paq_ptr_en) begin
      paq_rd_ptr <= nxt_paq_rd_ptr;
      paq_wr_ptr <= nxt_paq_wr_ptr;
      paq_full   <= nxt_paq_full;
      paq_empty  <= nxt_paq_empty;
    end

  // Head of FIFO
  always @* begin : g_paq_read_mux
    integer j;
    reg [48:0] tmp_rtn_addr_iss;
    tmp_rtn_addr_iss = {49{1'b0}};

    for (j=0; j<PAQ_ENTRIES; j=j+1)
      tmp_rtn_addr_iss[48:0] = tmp_rtn_addr_iss[48:0] | ({49{paq_rd_ptr[j]}} & paq_entry[j]);

    rtn_addr_iss = tmp_rtn_addr_iss;
  end

  assign paq_stall_iss_o = br_valid_iss & rtn_addr_valid_iss & paq_empty;

  // ------------------------------------------------------
  // Iss stage
  // ------------------------------------------------------

  assign advance_br_pipeline_iss  = ~stall_iss_i | flush_wr_i;
  assign nxt_br_valid_iss         = br_valid_de_i & ~flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      br_valid_iss  <= 1'b0;
    end else if (advance_br_pipeline_iss) begin
      br_valid_iss  <= nxt_br_valid_iss;
    end

  assign br_iss_en = advance_br_pipeline_iss & br_valid_de_i;

  always @(posedge clk)
    if (br_iss_en) begin
      rtn_addr_valid_iss    <= rtn_addr_valid_de_i;
      dpu_pred_br_iss       <= dpu_pred_br_de_i;
      dpu_br_return_iss     <= dpu_br_return_de_i;
      br_pred_takenness_iss <= br_pred_takenness_de_i;
      br_pipectl_iss        <= br_pipectl_de_i[`CA53_BR_PIPECTL_W-1:0];
      dpu_br_call_iss       <= dpu_br_call_de_i;
      br_btac_iss           <= br_btac_de_i;
    end

  // Only pipeline offset on direct branch (for De->Iss regardless of predicted
  // takenness, as use for updating PC in De)
  assign br_offset_iss_en = br_valid_de_i & ~stall_iss_i & (br_pipectl_de_i[2:0] == `CA53_BR_DIRECT);

  always @(posedge clk)
    if (br_offset_iss_en)
      br_offset_iss[27:1] <= br_offset_de_i[27:1];

  assign nxt_br_valid_ex1 = br_valid_iss & ~force_wfx_nop_i & ~flush_wr_i & ~stall_br_iss_i;

  // ------------------------------------------------------
  // Ex1 stage
  // ------------------------------------------------------

  // Regionally gate the Ex1 stage registers
  assign en_clk_br_ex1 = br_valid_iss | br_valid_ex1;

  ca53_cell_inter_clkgate u_inter_clkgate_br_ex1 (
    .clk_i         (clk),
    .clk_enable_i  (en_clk_br_ex1),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_br_ex1)
  );

  assign advance_br_pipeline = ~stall_wr_i | flush_wr_i;

  always @(posedge clk_br_ex1 or negedge reset_n)
    if (~reset_n) begin
      br_valid_ex1          <= 1'b0;
    end else if (advance_br_pipeline) begin
      br_valid_ex1          <= nxt_br_valid_ex1;
    end

  assign br_ex1_en = issue_to_ex1_i & br_valid_iss;

  always @(posedge clk_br_ex1)
    if (br_ex1_en) begin
      dpu_pred_br_ex1       <= dpu_pred_br_iss;
      dpu_br_return_ex1     <= dpu_br_return_iss;
      br_pred_takenness_ex1 <= br_pred_takenness_iss;
      br_pipectl_ex1        <= br_pipectl_iss[`CA53_BR_PIPECTL_W-1:0];
      dpu_br_call_ex1       <= dpu_br_call_iss;
      br_btac_ex1           <= br_btac_iss;
    end

  // Only pipeline offset on direct branch predicted not taken as only used on
  // mispredicted branch forcing to IFU when was predicted not taken
  assign br_offset_ex1_en = br_ex1_en & (br_pipectl_iss[2:0] == `CA53_BR_DIRECT) & ~br_pred_takenness_iss;

  always @(posedge clk_br_ex1)
    if (br_offset_ex1_en)
      br_offset_ex1[27:1]   <= br_offset_iss[27:1];

  // Suppress valid if branch will cause an exception, to prevent asynchronous
  // exceptions which would be taken before the branch being masked (this is
  // not required architecturally but makes the behaviour more consistent).
  assign nxt_br_valid_ex2 = br_valid_ex1 & ~exception_valid_ex1_i & ~flush_wr_i & ~force_wfx_nop_i;

  // ------------------------------------------------------
  // Ex2 stage
  // ------------------------------------------------------

  // Regionally gate the Ex2 stage registers
  assign en_clk_br_ex2 = br_valid_ex1 | br_valid_ex2;

  ca53_cell_inter_clkgate u_inter_clkgate_br_ex2 (
    .clk_i         (clk),
    .clk_enable_i  (en_clk_br_ex2),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_br_ex2)
  );

  always @(posedge clk_br_ex2 or negedge reset_n)
    if (~reset_n) begin
      br_valid_ex2          <= 1'b0;
    end else if (advance_br_pipeline) begin
      br_valid_ex2          <= nxt_br_valid_ex2;
    end

  assign br_ex2_en = issue_to_ex2_i & br_valid_ex1;

  always @(posedge clk_br_ex2)
    if (br_ex2_en) begin
      dpu_pred_br_ex2       <= dpu_pred_br_ex1;
      dpu_br_return_ex2     <= dpu_br_return_ex1;
      br_pred_takenness_ex2 <= br_pred_takenness_ex1;
      br_pipectl_ex2        <= br_pipectl_ex1[`CA53_BR_PIPECTL_W-1:0];
      dpu_br_call_ex2       <= dpu_br_call_ex1;
      br_btac_ex2           <= br_btac_ex1;
      aarch64_state_rs      <= aarch64_state_i;
    end

  // Only pipeline offset on direct branch predicted not taken as only used on
  // mispredicted branch forcing to IFU when was predicted not taken
  assign br_offset_ex2_en = br_ex2_en & (br_pipectl_ex1[2:0] == `CA53_BR_DIRECT) & ~br_pred_takenness_ex1;

  always @(posedge clk_br_ex2)
    if (br_offset_ex2_en)
      br_offset_ex2[27:1]   <= br_offset_ex1[27:1];

  // Generate a single bit representation of the instruction position of the branch.
  assign branch_in_slot1_ex2 = br_valid_ex2 & slot1_branch_ex2_i;

  // This mux calculates the twiddle values for both Taken and Not Taken
  // branches.
  always @* begin
    case ({isa_instr0_ex2_i, branch_in_slot1_ex2, size_instr0_ex2_i, size_instr1_ex2_i})
      `ca53dpu_sel_000xx: begin  // ARM branch in slot 0
        dpu_fe_twiddle_nt_ex2 = 4'b1110;  //-4
        dpu_fe_twiddle_t_ex2  = 2'b00;    // 0
      end
      `ca53dpu_sel_001xx: begin  // ARM branch in slot 1
        dpu_fe_twiddle_nt_ex2 = 4'b0000;  // 0
        dpu_fe_twiddle_t_ex2  = 2'b10;    //+4
      end
      `ca53dpu_sel_100xx: begin  // A64 branch in slot 0
        dpu_fe_twiddle_nt_ex2 = 4'b0010;  //+4
        dpu_fe_twiddle_t_ex2  = 2'b00;    // 0
      end
      `ca53dpu_sel_101xx: begin  // A64 branch in slot 1
        dpu_fe_twiddle_nt_ex2 = 4'b0100;  //+8
        dpu_fe_twiddle_t_ex2  = 2'b10;    //+4
      end
      `ca53dpu_sel_x100x: begin  // T16 branch in slot 0
        dpu_fe_twiddle_nt_ex2 = 4'b1111;  //-2
        dpu_fe_twiddle_t_ex2  = 2'b00;    // 0
      end
      `ca53dpu_sel_x101x: begin  // T32 branch in slot 0
        dpu_fe_twiddle_nt_ex2 = 4'b0000;  // 0
        dpu_fe_twiddle_t_ex2  = 2'b00;    // 0
      end
      `ca53dpu_sel_x1100: begin  // T16 branch in slot 1, slot 0 is T16
        dpu_fe_twiddle_nt_ex2 = 4'b0000;  // 0
        dpu_fe_twiddle_t_ex2  = 2'b01;    //+2
      end
      `ca53dpu_sel_x1101: begin  // T32 branch in slot 1, slot 0 is T16
        dpu_fe_twiddle_nt_ex2 = 4'b0001;  //+2
        // if the Branch is B or BL then +2
        // if the Branch is BLX +2 for unaligned targets 0 if aligned
        // BLX case: If we are here with a BLX in instr1 is because we have mispredicted not taken a BLX
        //           which is possible when the mmu is off. We will switch to ARM therefore we need to
        //           be word aligned but also add 2 for the T16 in instr0.
        //           If pc_instr0 is unaligned we then need to add 4.
        //           2 for the instr0 + 2 for the wrong pc word alignment
        //           If pc_instr0 is aligned then we should add 2 for the instr0 and then subtract 2 to word alignment (ie 0)
        dpu_fe_twiddle_t_ex2[2] = pc_instr0_ex2_i[1] & isa_switch_br_ex2_i;
        dpu_fe_twiddle_t_ex2[1] = ~isa_switch_br_ex2_i;
      end
      `ca53dpu_sel_x1110: begin  // T16 branch in slot 1, slot 0 is T32
        dpu_fe_twiddle_nt_ex2 = 4'b0001;  //+2
        dpu_fe_twiddle_t_ex2  = 2'b10;    //+4
      end
      `ca53dpu_sel_x1111: begin  // T32 branch in slot 1, slot 0 is T32
        dpu_fe_twiddle_nt_ex2 = 4'b0010;  //+4
        dpu_fe_twiddle_t_ex2  = 2'b10;    //+4
      end
      default           : begin
        dpu_fe_twiddle_nt_ex2 = 4'bxxxx;
        dpu_fe_twiddle_t_ex2  = 2'bxx;
      end
    endcase
  end

  // Do the qualification of the ifu 'valid' type signals in ex2 before
  // they reach wr so that the wr signals are early to the IFU
  assign enable_prediction_signals_ex2 = br_valid_ex2             & // Must be a valid branch instruction
                                         ~stall_wr_i              & // Not stalling in Wr
                                         ~dpu_fe_valid_ind_br_wr  & // Not behind an indirect branch
                                         ~dpu_fe_valid_wr         & // Not behind a direct branch
                                         ~insert_forceop_wr_i     & // Not behind an instruction exception
                                         ~quash_ex2_i             & // This pipeline stage must not be quashed
                                         ~expt_quash_wr_i;         // Mustn't be predicted to be flushed by an exception

  // Fetch address valid signal for the Wr stage. The valid is asserted
  // whenever we have a predictable branch in EX2 that mispredicted.
  assign dpu_fe_valid_ex2 = br_valid_ex2 & dpu_mispred_ex2 & ((br_pipectl_ex2[2:0] == `CA53_BR_DIRECT) | br_pred_takenness_ex2);

  // These signals will not go high if the pipeline has computed that there
  // will be a flush from RET in the next cycle. This catches the case where we
  // may have an indirect branch in Wr (that will be flushing in 1 cycles time from
  // Ret) followed by a direct branch in Ex2 (that may or may not be producing
  // stimulus to the IFU when it reaches Wr).
  assign nxt_dpu_pred_br_wr       = dpu_pred_br_ex2       & enable_prediction_signals_ex2;
  assign nxt_dpu_br_return_wr     = dpu_br_return_ex2     & enable_prediction_signals_ex2;
  assign nxt_dpu_br_call_wr       = dpu_br_call_ex2       & enable_prediction_signals_ex2;
  assign nxt_br_btac_wr           = br_btac_ex2           & enable_prediction_signals_ex2;

  // WFx instruction in Wr stage.
  // Will be asserting ifu_halt to stop the IFU from making any fetch requests to i-side.
  // Need to assert dpu_fe_valid_wr to validate the ifu_halt signal.
  assign nxt_dpu_fe_valid_wr      = ((dpu_fe_valid_ex2 & enable_prediction_signals_ex2) |
                                     nxt_wfx_ifu_halt_i) & ~in_halt_i;

  assign nxt_slot0_br_flush_wr    = br_valid_ex2 & ~slot1_branch_ex2_i &
                                    (cc_pass_instr0_cbz_ex2_i ^ br_pred_takenness_ex2) & (br_pipectl_ex2[2:0] == `CA53_BR_DIRECT) &
                                    enable_prediction_signals_ex2;

  assign dpu_mispred_ex2       = slot1_branch_ex2_i ? (cc_pass_instr1_cbz_ex2_i ^ br_pred_takenness_ex2)
                                                    : (cc_pass_instr0_cbz_ex2_i ^ br_pred_takenness_ex2);

  assign nxt_dpu_mispred_wr    = dpu_mispred_ex2 & enable_prediction_signals_ex2;

  assign nxt_dpu_br_taken_wr   = slot1_branch_ex2_i ? cc_pass_instr1_cbz_ex2_i : cc_pass_instr0_cbz_ex2_i;

  // Calculate opb for forcing to the IFU on a mispredicted direct branch
  assign nxt_br_direct_opb_wr[27:1] =                       // For a predicted-taken branch, extend the not-taken twiddle
                                      br_pred_takenness_ex2 ? {{24{dpu_fe_twiddle_nt_ex2[4]}}, dpu_fe_twiddle_nt_ex2[3:1]}
                                                            // For a predicted-not-taken branch, add the taken twiddle to the offset
                                                            : (br_offset_ex2[27:1] + dpu_fe_twiddle_t_ex2);

  assign nxt_br_valid_wr = br_valid_ex2 & ~flush_wr_i;

  // A mispredicted BLX# in thumb state that was predicted not taken (PNT) needs to word
  // align the PC for a return toARM state.
  assign nxt_pc_instr0_1to0_wr = pc_instr0_ex2_i[1] &
                                 // If the instruction is half word aligned
                                 // Then we word align it if the following condition is met:
                                 ~(isa_instr0_ex2_i[0] &    // The branch is Thumb
                                   isa_switch_br_ex2_i &    // The branch is a BLX # (guaranteed switch to ARM if taken)
                                   ~br_pred_takenness_ex2 & // The branch was PNT (predicted to stay in Thumb)
                                   dpu_mispred_ex2);       // The branch mispredicts (will actually be jumping to ARM)

  // Need to inhibit the ret_force pipe control if the instruction CC fails.
  assign nxt_br_pipectl_wr = {cc_pass_instr0_cbz_ex2_i & br_pipectl_ex2[3],
                              br_pipectl_ex2[2:0]};

  // When an indirect branch is correctly predicted as taken, but the target
  // address mispredicts we need to remember that fact for the entire time
  // the instruction is in writeback.  In the case of LDM {pc} this can be
  // several cycles (DCU stall). The reason this state needs to be held is
  // because it will be needed to perform the force to the IFU from the Ret
  // stage when, for example,  the load has completed. The signals that go
  // to the IFU are single shot so we need this seperate state to remember
  // that we have a mispredicted indirect branch in Wr, separate to the flops
  // in the Wr IFU interface.
  assign nxt_correctly_pred_taken_ind_br_wr = (nxt_dpu_br_return_wr | nxt_br_btac_wr) & ~nxt_dpu_mispred_wr & br_pred_takenness_ex2;

  // ------------------------------------------------------
  // Wr stage registers
  // ------------------------------------------------------

  // Regionally gate the Wr stage registers
  assign en_clk_br_wr = br_valid_ex2 | br_valid_wr;

  ca53_cell_inter_clkgate u_inter_clkgate_br_wr (
    .clk_i         (clk),
    .clk_enable_i  (en_clk_br_wr),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_br_wr)
  );

  always @(posedge clk_br_wr or negedge reset_n)
    if (~reset_n) begin
      br_valid_wr       <= 1'b0;
      pc_instr0_1to0_wr <= 1'b1;
    end else if (advance_pipeline_i) begin
      br_valid_wr       <= nxt_br_valid_wr;
      pc_instr0_1to0_wr <= nxt_pc_instr0_1to0_wr;
    end

  assign br_wr_en = br_valid_ex2 & issue_to_wr_i & ~dpu_fe_valid_wr;

  always @(posedge clk_br_wr)
    if (br_wr_en) begin
      br_pred_takenness_wr            <= br_pred_takenness_ex2;
      br_pipectl_wr                   <= nxt_br_pipectl_wr[`CA53_BR_PIPECTL_W-1:0];
      correctly_pred_taken_ind_br_wr  <= nxt_correctly_pred_taken_ind_br_wr;
      mis_predicted_branch_wr         <= nxt_dpu_mispred_wr;
      br_call_wr                      <= dpu_br_call_ex2;
      br_btac_wr                      <= nxt_br_btac_wr;
    end

  // Pipeline opb on any mispredicted branch
  assign br_direct_opb_wr_en  = br_wr_en  & dpu_mispred_ex2;

  always @(posedge clk_br_wr)
    if (br_direct_opb_wr_en)
      br_direct_opb_wr[27:1]  <= nxt_br_direct_opb_wr[27:1];

  // Because the signals to the IFU are single shot (i.e. the IFU should see these signals
  // for only one cycle, even if the branch stalls in Wr due to being dual issued with a load),
  // the register must be able to clear itself if it's output has been set in the first cycle
  // of a stall in Wr.
  assign oneshot_en_wr = advance_br_pipeline | dpu_pred_br_wr | dpu_fe_valid_wr | dpu_br_taken_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_pred_br_wr    <= 1'b0;
      dpu_br_return_wr  <= 1'b0;
      dpu_br_call_wr    <= 1'b0;
      dpu_fe_valid_wr   <= 1'b0;
      slot0_br_flush_wr <= 1'b0;
      dpu_mispred_wr    <= 1'b0;
      dpu_br_taken_wr   <= 1'b0;
    end else if (oneshot_en_wr) begin
      dpu_pred_br_wr    <= nxt_dpu_pred_br_wr;
      dpu_br_return_wr  <= nxt_dpu_br_return_wr;
      dpu_br_call_wr    <= nxt_dpu_br_call_wr;
      dpu_fe_valid_wr   <= nxt_dpu_fe_valid_wr;
      slot0_br_flush_wr <= nxt_slot0_br_flush_wr;
      dpu_mispred_wr    <= nxt_dpu_mispred_wr;
      dpu_br_taken_wr   <= nxt_dpu_br_taken_wr;
    end

  // ------------------------------------------------------
  // Direct branch operand generation
  // ------------------------------------------------------

  assign br_direct_wr           = br_pipectl_wr[2:0] == `CA53_BR_DIRECT;

  assign br_direct_opa_wr[48:1] = {pc_instr0_wr_i[48:2], pc_instr0_1to0_wr} & {48{dpu_fe_valid_wr}};  // Data-gate when not forcing to save power

  // ------------------------------------------------------
  // Indirect branch operand generation
  // ------------------------------------------------------

  assign pc_bit1_mask  = nxt_cpsr_tbit_ret_pre_i | ~branch_align_pc_wr_i;
  assign br_st_data_wr = slot1_branch_wr_i ? st1_data_wr_i : st0_data_wr_i;

  always @* begin
    case (br_pipectl_wr[2:0])
      `CA53_BR_NO_BRANCH,
      `CA53_BR_DIRECT: begin          // Zero operands
        operand_a_wr[63:0] = {64{1'b0}};
        operand_b_wr[17:1] = {17{1'b0}};
        ld_t_bit_wr        =  1'b0;
      end
      `CA53_BR_PREFETCH_FLUSH: begin   // Branch to instruction after current
        operand_a_wr[63:0] = pc_instr0_wr_i[63:0];
        operand_b_wr[17:1] = in_halt_i           ? 17'h00000 : //  0
                             isa_instr0_ex2_i[1] ? 17'h00002 : // +4
                             isa_instr0_ex2_i[0] ? 17'h00000 : //  0 (ISB is 4byte in Thumb, and PC is +4)
                                                   17'h1FFFE;  // -4
        ld_t_bit_wr        = 1'b0;
      end
      `CA53_BR_WFX_RESTART: begin      // Branch to current instruction
        operand_a_wr[63:0] = { {15{pc_instr0_wr_i[48]}}, pc_instr0_wr_i[48:1], 1'b0};
        operand_b_wr[17:1] = isa_instr0_ex2_i[1] ? 17'h00000 : //  0
                             isa_instr0_ex2_i[0] ? 17'h1FFFE : // -4
                                                   17'h1FFFC;  // -8
        ld_t_bit_wr        = 1'b0;
      end
      `CA53_BR_INDIRECT_DP: begin      // Select the ALU pipeline
        operand_a_wr[63:0] = {32'h0000_0000, alu0_fwd_data_early_wr_i[31:2], alu0_fwd_data_early_wr_i[1] & pc_bit1_mask, 1'b0};
        operand_b_wr[17:1] = {17{1'b0}};
        ld_t_bit_wr        =  alu0_fwd_data_early_wr_i[0];
      end
      `CA53_BR_INDIRECT_ST: begin      // Select the store pipeline
        operand_a_wr[63:0] = {br_st_data_wr[63:32] & {32{~branch_align_pc_wr_i & aarch64_state_rs}}, br_st_data_wr[31:2], br_st_data_wr[1] & pc_bit1_mask,
                                                                                                     br_st_data_wr[0] & ((~branch_align_pc_wr_i & aarch64_state_rs) | in_halt_i)};
        operand_b_wr[17:1] = {17{1'b0}};
        ld_t_bit_wr        =  br_st_data_wr[0];
      end
      `CA53_BR_INDIRECT_LD: begin      // Select the load pipeline
        operand_a_wr[63:0] = (ongoing_ldm_wr_i & sel_rf_wr_w0_wr_i) ? {32'h0000_0000, fwd_ld_data_int_wr_i[63:34], fwd_ld_data_int_wr_i[33] & pc_bit1_mask, 1'b0}
                                                                    : {32'h0000_0000, fwd_ld_data_int_wr_i[31: 2], fwd_ld_data_int_wr_i[ 1] & pc_bit1_mask, 1'b0};
        operand_b_wr[17:1] = {17{1'b0}};
        ld_t_bit_wr        = (ongoing_ldm_wr_i & sel_rf_wr_w0_wr_i) ? fwd_ld_data_int_wr_i[32]
                                                                    : fwd_ld_data_int_wr_i[0];
      end
      `CA53_BR_INDIRECT_TBB: begin     // Table branch offset from PC
        operand_a_wr[63:0] = {32'h0000_0000, pc_instr0_wr_i[31:1], 1'b0};
        operand_b_wr[17:1] = {1'b0, ld_data0_wr_i[15:0]};
        ld_t_bit_wr        = 1'b1;
      end
      default: begin
        operand_a_wr[63:0] = {64{1'bx}};
        operand_b_wr[17:1] = {17{1'bx}};
        ld_t_bit_wr        = 1'bx;
      end
    endcase
  end

  // Subtract the architectural offset of the PC in ex2 to get the instruction
  // address of the instruction following the branch. Since the branches that
  // use this mechanism are always single issued, then we should only need to
  // subtract the architectural offset only, without having to worry about the
  // twiddle.
  assign arch_offset_wr[3:1] = aarch64_state_rs    ? 3'b000 :
                               isa_instr0_ex2_i[0] ? 3'b010 :
                                                     3'b100;

  // Need to subtract 8, 4 or 0 (depending on ISA) from the predicted PC
  // for the next instruction, which follows the branch instruction with a
  // lag of 1 cycle. This lag is caused by having to either feed the RTN2
  // packet back into the PC logic when the branch instruction is in Iss,
  // or simply because the branch is predicted NT and the sequential PC is
  // that of the next instruction after the branch. The subtraction is done
  // in order to make the comparison with the calculated PC meaningful (so
  // that we are comparing an instruction address with an instruction address,
  // as opposed to an instruction address with an architectural PC).
  assign instr0_addr_ex2[48:1] = pc_instr0_ex2_i[48:1] - arch_offset_wr[3:1];

  // The branch address that is communicated to the IFU must be adjusted if the
  // branch instruction is in instr-1.  If instruction-0 is a T16 we add 2-bytes
  // else we add 4-bytes.
  assign br_addr_ex2[12:1] = instr0_addr_ex2[12:1] + {(slot1_branch_ex2_i &  size_instr0_ex2_i),
                                                      (slot1_branch_ex2_i & ~size_instr0_ex2_i)};

  // Ret force is either from De (from decode of an ADD PC, Rm, Rn) OR
  // it can come from whether there is a correctly predicted return instruction
  // that, for some reason, may not force its address out due to the
  // address comparison passing.
  assign ret_force_wr = br_pipectl_wr[3];

  // Evaluate whether tagged addresses are in use, and the top PC byte should
  // be ignored
  assign ignore_top_byte = ~aarch64_state_i                                                                    |
                           ((dpu_exception_level_i[1] == 1'b0)  & tlb_d_tcr_el1_tbi_i[0] & ~br_st_data_wr[55]) |
                           ((dpu_exception_level_i[1] == 1'b0)  & tlb_d_tcr_el1_tbi_i[1] &  br_st_data_wr[55]) |
                           ((dpu_exception_level_i    == 2'b10) & tlb_d_tcr_el2_tbi0_i)                        |
                           ((dpu_exception_level_i    == 2'b11) & tlb_d_tcr_el3_tbi0_i);

  // This calculates whether or not the instruction following a return is
  // the correct one (as predicted by the IFU)
  //
  // We have to concatenate the comparison PC with ld_t_bit_wr because the
  // PC data from the indirect branch has the Tbit for the instruction at the
  // branch destination as it's bottom bit. The PC that is carried in the
  // pipeline does not include a T-bit, and thus the predicted destination T-bit
  // (speculatively updated in the ISS stage of the ISA pipeline in the CTL pipe)
  // needs concatenating in order for this comparison to have any meaning.

  assign comparison_pass_wr = (br_pipectl_wr[2:0] == `CA53_BR_INDIRECT_TBB)
                                ? ({alu0_fwd_data_early_wr_i[31:1], isa_instr0_ex2_i[0]} == {{15{1'b0}}, ld_data0_wr_i[15:0], 1'b1})
                                : (({instr0_addr_ex2[31:1], isa_instr0_ex2_i[0]} == {operand_a_wr[31:1],ld_t_bit_wr}) &
                                   (~aarch64_state_rs | ({ {8{instr0_addr_ex2[48]}}, instr0_addr_ex2[47:32]} == operand_a_wr[55:32])) &
                                   (ignore_top_byte   | (  {8{instr0_addr_ex2[48]}}                          == operand_a_wr[63:56])));

  // The fetch address valid, from branches, for the Ret stage.
  assign pre_dpu_fe_valid_ind_br_wr  =
         //Mispredicted branches that were predicted NT (qualified as indirect below
         // in this expression)
         ((mis_predicted_branch_wr & ~br_pred_takenness_wr) |
         //Correctly predicted taken returns whose address predictions failed.
          (correctly_pred_taken_ind_br_wr & ~comparison_pass_wr) |
         //[DP/LDR/LDM to PC] | [BLX Rm (uncond|PT CCPass)] that force without comparison
          ret_force_wr) &
         // Must be a valid branch
         br_valid_wr &
         // Must not be direct
         ~br_direct_wr;

  assign dpu_fe_valid_ind_br_wr = pre_dpu_fe_valid_ind_br_wr;

  assign nxt_incr_pc_halt_mode_ret = // Must have calculated a flush from the Ret stage
                                     pre_dpu_fe_valid_ind_br_wr &
                                     // Must be in halt mode.
                                     in_halt_i &
                                     // Any DP to the PC
                                     (((br_pipectl_wr[2:0] == `CA53_BR_INDIRECT_DP)  |
                                      //Any branch instruction using the store pipe to
                                      //deliver the address that has to provide ret_force_wr
                                      //to perform a flush (i.e. simple MOV PC, Rx), so long
                                      //as it isn't a BLX Rm
                                      (br_pipectl_wr[2:0] == `CA53_BR_INDIRECT_ST)) &
                                       ret_force_wr);

  // Indicate to the ETM interface that a branch is in Wr. Exclude IFU flushes.
  assign dpu_valid_branch_instr_wr = br_valid_wr & (br_pipectl_wr[2:0] != `CA53_BR_PREFETCH_FLUSH)
                                                 & (br_pipectl_wr[2:0] != `CA53_BR_WFX_RESTART);

  // Indicate to the CPSR pipeline that an IFU flush has occurred.
  assign prefetch_flush_wr = br_valid_wr & (br_pipectl_wr[2:0] == `CA53_BR_PREFETCH_FLUSH);

  // ------------------------------------------------------
  // Exception force
  // ------------------------------------------------------

  // Calculate "nxt" values for the registers into the following pipeline stage
  // Mask mux control signals to create priority - the control terms are non-critical
  // but do have a required priority so this apporach speeds up the data in the mux
  assign nxt_dpu_fe_valid_ret = insert_forceop_ret_i | (dpu_fe_valid_ind_br_wr & ~quash_wr_i & ~stall_wr_i);

  // A half-word or byte aligned PC can only be sent to the IFU if the processor is in
  // Thumb state or moving from ARM state while not in debug.
  assign nxt_dpu_fe_addr_opa_ret[63:0] = insert_forceop_ret_i ? (forceop_pc_ret_i[63:0] & { {32{~debug_exit_aa32_i}}, {31{1'b1}}, ~debug_exit_aa32_i})
                                                              : operand_a_wr[63:0];

  assign nxt_dpu_fe_addr_opb_ret[17:1] = insert_forceop_ret_i ? forceop_pc_offset_ret_i[17:1]
                                                              : operand_b_wr[17:1];

  // Indicate to the IFU when the force corresponds to a context synchronisation operation
  assign nxt_dpu_fe_context_sync_ret   = insert_forceop_ret_i | isb_wr_i | expt_rtn_wr_i;


  // br_btac_ret should only go high for one cycle
  assign nxt_br_btac_ret = br_valid_wr & br_btac_wr & advance_pipeline_i & ~quash_wr_i;

  // Create event signal for indirect branches in Wr that are flushing
  assign nxt_evnt_fe_valid_ind_br_ret = dpu_fe_valid_ind_br_wr & ~quash_wr_i & ~stall_wr_i;

  // ------------------------------------------------------
  // Ret stage
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dpu_fe_valid_ret          <= 1'b0;
      incr_pc_halt_mode_ret     <= 1'b0;
      evnt_fe_valid_ind_br_ret  <= 1'b0;
    end else begin
      dpu_fe_valid_ret          <= nxt_dpu_fe_valid_ret;
      incr_pc_halt_mode_ret     <= nxt_incr_pc_halt_mode_ret;
      evnt_fe_valid_ind_br_ret  <= nxt_evnt_fe_valid_ind_br_ret;
    end

  assign oneshot_en_ret = advance_pipeline_i | br_btac_ret;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      br_btac_ret         <= 1'b0;
      comparison_pass_ret <= 1'b0;
    end else if (oneshot_en_ret) begin
      br_btac_ret         <= nxt_br_btac_ret;
      comparison_pass_ret <= comparison_pass_wr;
    end

  assign dpu_fe_addr_ret_en = nxt_incr_pc_halt_mode_ret | nxt_dpu_fe_valid_ret;

  always @(posedge clk)
    if (dpu_fe_addr_ret_en) begin
      dpu_fe_addr_opa_ret[63:0] <= nxt_dpu_fe_addr_opa_ret[63:0];
      dpu_fe_addr_opb_ret[17:1] <= nxt_dpu_fe_addr_opb_ret[17:1];
      dpu_fe_context_sync_ret   <= nxt_dpu_fe_context_sync_ret;
    end

  // ------------------------------------------------------
  // Event Generation
  // ------------------------------------------------------

  assign br_cc_pass_wr = slot1_branch_wr_i ? cc_pass_instr1_wr_i : cc_pass_instr0_wr_i;

  assign evnt_br_valid_wr = br_valid_wr & ~dpu_fe_valid_ret & ~stall_wr_i;

  assign evnt_br_valid_wr_o              = evnt_br_valid_wr;
  assign evnt_br_mispred_o               = dpu_fe_valid_wr | evnt_fe_valid_ind_br_ret; // Note that this considers branches which are not predictable
  assign evnt_br_direct_wr_o             = br_direct_wr & evnt_br_valid_wr;
  assign evnt_br_indirect_o              = br_btac_ret;
  assign evnt_br_indirect_mispred_o      = br_btac_ret & dpu_fe_valid_ret;
  assign evnt_br_indirect_mispred_addr_o = br_btac_ret & dpu_fe_valid_ret & ~comparison_pass_ret;
  assign evnt_sw_change_pc_o             = br_valid_wr & br_cc_pass_wr & ~flush_ret_i & ~stall_wr_i & (~dpu_pred_br_wr | dpu_br_taken_wr);

  // ------------------------------------------------------
  // Alias internal signals onto their outputs
  // ------------------------------------------------------

  // Flush logic outputs
  //
  //When a WFx instr reaches Wr stage, the IFU is requested to enter halt
  //state. This requires the assertion of dpu_fe_valid_wr to validate this
  //entry into halt mode. However, we do not want to generate a pipeline
  //flush, since there is no actual branch in the Wr stage at this moment of
  //time. Thus we qualify by wfx_ifu_halt_i.
  assign br_flush_wr_o               = dpu_fe_valid_wr & ~wfx_ifu_halt_i;
  assign slot0_br_flush_wr_o         = slot0_br_flush_wr;
  assign br_flush_ret_o              = dpu_fe_valid_ret;
  assign dpu_pred_br_ex2_o           = dpu_pred_br_ex2 & br_valid_ex2;
  assign dpu_br_addr_ex2_o           = br_addr_ex2[12:3];
  assign dpu_pred_br_wr_o            = dpu_pred_br_wr;
  assign dpu_br_return_wr_o          = dpu_br_return_wr;
  assign dpu_br_call_wr_o            = dpu_br_call_wr;
  assign dpu_btac_ret_o              = br_btac_ret;
  assign dpu_valid_branch_instr_wr_o = dpu_valid_branch_instr_wr;
  assign prefetch_flush_wr_o         = prefetch_flush_wr;
  assign dpu_fe_valid_wr_o           = dpu_fe_valid_wr;
  assign dpu_fe_addr_opa_wr_o[48:1]  = br_direct_opa_wr[48:1];
  assign dpu_fe_addr_opb_wr_o[27:1]  = br_direct_opb_wr[27:1];
  assign dpu_mispred_wr_o            = dpu_mispred_wr;
  assign dpu_br_taken_wr_o           = dpu_br_taken_wr;
  assign br_direct_wr_o              = br_direct_wr;
  assign br_pred_takenness_wr_o      = br_pred_takenness_wr & br_valid_wr;
  assign mis_predicted_branch_wr_o   = mis_predicted_branch_wr & br_valid_wr;
  assign br_call_wr_o                = br_call_wr & br_valid_wr;
  assign dpu_fe_valid_ret_o          = dpu_fe_valid_ret;
  assign dpu_fe_addr_opa_ret_o[63:0] = dpu_fe_addr_opa_ret[63:0];
  assign dpu_fe_addr_opb_ret_o       = dpu_fe_addr_opb_ret[17:1];
  assign dpu_fe_context_sync_ret_o   = dpu_fe_context_sync_ret;
  assign rtn_addr_iss_o              = rtn_addr_iss[48:1];
  assign br_offset_iss_o             = br_offset_iss[27:1];
  assign tbit_btac_rtn_instr_iss_o   = rtn_addr_iss[0];
  assign taken_br_instr_iss_o        = br_pred_takenness_iss & br_valid_iss;
  assign btac_rtn_instr_iss_o        = rtn_addr_valid_iss & br_valid_iss;
  assign incr_pc_halt_mode_ret_o     = incr_pc_halt_mode_ret;
  assign ld_t_bit_wr_o               = ld_t_bit_wr;
  assign paq_full_o                  = paq_full;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Should not push into PAQ when full")
  u_ovl_paq_full_no_push (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (paq_full),
    .consequent_expr (~paq_push)
  );

  // As there are does not need to be a power of 2 number of entries in the PAQ, the read and write pointers
  // should never point to a non-existing entry
  assert_one_hot #(`OVL_FATAL,4,`OVL_ASSERT, "PAQ read pointer should only be one-hot")
    u_ovl_paq_rd_ptr_too_big (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (paq_rd_ptr[3:0]));

  assert_one_hot #(`OVL_FATAL,4,`OVL_ASSERT, "PAQ write pointer should only be one-hot")
    u_ovl_paq_wr_ptr_too_big (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (paq_wr_ptr[3:0]));

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_direct_opb_wr_en")
  u_ovl_x_br_direct_opb_wr_en (.clk       (clk_br_wr),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (br_direct_opb_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_iss_en")
  u_ovl_x_br_iss_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (br_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_offset_ex1_en")
  u_ovl_x_br_offset_ex1_en (.clk       (clk_br_ex1),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (br_offset_ex1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_offset_ex2_en")
  u_ovl_x_br_offset_ex2_en (.clk       (clk_br_ex2),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (br_offset_ex2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_br_pipeline")
  u_ovl_x_advance_br_pipeline (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (advance_br_pipeline));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (advance_pipeline_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_br_pipeline_iss")
  u_ovl_x_advance_br_pipeline_iss (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (advance_br_pipeline_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_ex1_en")
  u_ovl_x_br_ex1_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (br_ex1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_ex2_en")
  u_ovl_x_br_ex2_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (br_ex2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_offset_iss_en")
  u_ovl_x_br_offset_iss_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (br_offset_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: br_wr_en")
  u_ovl_x_br_wr_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (br_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_fe_addr_ret_en")
  u_ovl_x_dpu_fe_addr_ret_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dpu_fe_addr_ret_en));

  assert_never_unknown #(`OVL_FATAL, PAQ_ENTRIES, `OVL_ASSERT, "Register enable x-check: paq_entry_en")
  u_ovl_x_paq_entry_en  (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (paq_entry_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: paq_ptr_en")
  u_ovl_x_paq_ptr_en (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (paq_ptr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: oneshot_en_ret")
  u_ovl_x_oneshot_en_ret (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (oneshot_en_ret));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: oneshot_en_wr")
  u_ovl_x_oneshot_en_wr (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (oneshot_en_wr));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_direct_br_ret_flush
  // Never have a direct branch in Wr that tries to flush from Ret
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT, "Ret stage IFU force calculated in Wr at the same time as retirement of a direct branch")
    u_ovl_direct_br_ret_flush(.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (br_valid_wr & br_direct_wr & dpu_fe_valid_ind_br_wr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: ovl_no_correct_pred_flush
  // Never perform a flush for a correctly predicted direct branch
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT, "A direct branch flushed from Wr that did NOT mispredict!")
    u_ovl_no_correct_pred_flush(.clk       (clk),
                                .reset_n   (reset_n),
                                .test_expr (br_valid_wr & ~dpu_mispred_wr & dpu_fe_valid_wr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Should only flush because of slot 0 branch when flushing
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Should only flush on slot 0 branch when flushing")
  u_ovl_slot0_br_flush   (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (slot0_br_flush_wr_o),
    .consequent_expr (br_flush_wr_o)
  );
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_br

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
