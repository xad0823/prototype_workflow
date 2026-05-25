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
// Abstract : Instruction Queue.
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Instruction Queue. Two, one or none instructions can be pushed and/or popped
// per cycle.  For timing reasons, the IQ is implemented in three parts.
//
// The decoders must be driven directly by registers known as the 'head' registers.
// For instruction-0 there is a set of output registers for each of the main
// decoders (Data-processing, Load-store, Other, NEON-FP).  The instruction-1
// decoders is also driven from another set of registers.
//
// If the 'head' registers are full then a set of 'holding' registers is used
// which decouples the IFU from most of the queue.  These registers will only
// contain instructions for more than a cycle if the IQ if full.
//
// Instructions are moved from the 'holding' registers in to the main body of the
// IQ.  The body is implemented as a pointer based queue.
//
// Additionally, the IQ contains the dual-issue hazard checking decoder.
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_iq `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         clk,
  input  wire         reset_n,
  input  wire         DFTSE,
  input  wire  [47:0] ifu_instr0_if3_i,           // IFU Instruction input
  input  wire  [47:0] ifu_instr1_if3_i,           // IFU Instruction input
  input  wire   [1:0] ifu_instr_valid_if3_i,      // IFU FIFO push
  input  wire         ifu_early_two_valid_if3_i,
  input  wire         paq_full_i,
  input  wire         aarch64_state_i,            // Processor in AArch64 state
  input  wire         stall_de_i,
  input  wire         flush_wr_i,
  input  wire         finish_instr_de_i,          // Finished decode - new instructions required
  input  wire         disable_dual_issue_i,
  input  wire         disable_fp_dual_issue_i,
  input  wire         cp_trap_fp_i,
  input  wire         cp_trap_neon_i,
  input  wire         rf_wr_en_w0_iss_i,
  input  wire         rf_wr_en_w1_iss_i,
  input  wire         rf_wr_en_w2_iss_i,
  input  wire   [1:0] rf_wr_when_w0_iss_i,
  input  wire   [1:0] rf_wr_when_w1_iss_i,
  input  wire   [1:0] rf_wr_when_w2_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w0_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w1_iss_i,
  input  wire   [4:0] rf_wr_vaddr_w2_iss_i,
  input  wire         rf_wr_en_w0_ex1_i,
  input  wire         rf_wr_en_w1_ex1_i,
  input  wire         rf_wr_en_w2_ex1_i,
  input  wire   [1:0] rf_wr_when_w0_ex1_i,
  input  wire   [1:0] rf_wr_when_w1_ex1_i,
  input  wire   [1:0] rf_wr_when_w2_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w0_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w1_ex1_i,
  input  wire   [4:0] rf_wr_vaddr_w2_ex1_i,
  input  wire   [3:0] rf_wr_en_fw0_iss_i,
  input  wire   [3:0] rf_wr_en_fw1_iss_i,
  input  wire   [3:0] rf_wr_en_fw0_f1_i,
  input  wire   [3:0] rf_wr_en_fw1_f1_i,
  input  wire   [3:0] rf_wr_en_fw0_f2_i,
  input  wire   [3:0] rf_wr_en_fw1_f2_i,
  input  wire   [1:0] rf_wr_when_fw0_iss_i,
  input  wire   [1:0] rf_wr_when_fw1_iss_i,
  input  wire   [1:0] rf_wr_when_fw0_f1_i,
  input  wire   [1:0] rf_wr_when_fw1_f1_i,
  input  wire   [1:0] rf_wr_when_fw0_f2_i,
  input  wire   [1:0] rf_wr_when_fw1_f2_i,
  input  wire   [5:0] rf_wr_addr_fw0_iss_i,
  input  wire   [5:0] rf_wr_addr_fw1_iss_i,
  input  wire   [5:0] rf_wr_addr_fw0_f1_i,
  input  wire   [5:0] rf_wr_addr_fw1_f1_i,
  input  wire   [5:0] rf_wr_addr_fw0_f2_i,
  input  wire   [5:0] rf_wr_addr_fw1_f2_i,
  input  wire   [1:0] adrp_valid_iss_i,
  input  wire         taken_br_instr_iss_i,
  input  wire   [1:0] iss_pc_in_same_page_i,
  // Outputs
  output wire         dpu_iq_full_o,              // Instruction queue FIFO full
  output wire         dpu_iq_part_full_o,         // Instruction queue FIFO part full
  output reg          aarch64_state_ext_o,
  output wire   [5:0] iq_instr0_sideband_o,
  output wire  [32:0] iq_instr0_common_o,
  output wire         iq_instr0_common_aarch64_o,
  output wire  [32:0] iq_instr0_dp_o,
  output wire   [1:0] iq_instr0_dp_pdtype_o,
  output wire  [32:0] iq_instr0_ls_o,
  output wire   [1:0] iq_instr0_ls_pdtype_o,
  output wire         iq_instr0_ls_br_taken_o,
  output wire  [32:0] iq_instr0_other_o,
  output wire   [1:0] iq_instr0_other_pdtype_o,
  output wire         iq_instr0_other_br_taken_o,
  output wire         iq_instr0_common_br_taken_o,
  output wire  [32:0] iq_instr0_fn_o,
  output wire   [1:0] iq_instr0_fn_pdtype_o,
  output wire         iq_instr0_dp_aarch64_o,
  output wire         iq_instr0_ls_aarch64_o,
  output wire         iq_instr0_other_aarch64_o,
  output wire         iq_instr0_fn_aarch64_o,
  output wire         iq_instr0_en_other_o,
  output wire         iq_instr0_is_dp_o,
  output wire         iq_instr0_is_ls_o,
  output wire         iq_instr0_is_other_o,
  output wire         iq_instr0_is_fn_o,
  output wire         iq_instr0_val_o,
  output wire         iq_instr0_d0_o,
  output wire         iq_instr1_d1_o,
  output wire   [1:0] iq_instr0_pdtype_o,
  output wire   [5:0] iq_instr1_sideband_o,
  output wire  [32:0] iq_instr1_main_o,
  output wire         iq_instr1_br_taken_o,
  output wire         iq_instr1_main_aarch64_o,
  output wire  [32:0] iq_instr1_ls_o,
  output wire         iq_instr1_ls_aarch64_o,
  output wire  [32:0] iq_instr1_fn_o,
  output wire         iq_instr1_fn_aarch64_o,
  output wire  [32:0] iq_instr1_common_o,
  output wire         iq_instr1_common_aarch64_o,
  output wire   [1:0] iq_instr1_pdtype_o,
  output wire         iq_instr1_is_dp_o,
  output wire         iq_instr1_is_ls_o,
  output wire         iq_instr1_is_other_o,
  output wire         iq_instr1_is_fn_o,
  output wire         iq_instr1_is_dec1_o,
  output wire         iq_instr1_val_o,
  output wire         iq_instr0_r2_enabled_o,
  output wire         iq_instr0_w0_enabled_o,
  output wire         iq_instr1_br_valid_o,
  output wire         iq_instr1_datapath_resource_hazard_o,
  output wire         iq_instr1_fn_dcu_valid_o,
  output wire         iq_instr0_sets_ccflags_o,
  output wire         iq_instr0_d0_uses_dcu_o,
  output wire         iq_instr1_dih_o,
  output wire         iq_instr1_is_aesimc_aesmc_o,
  output wire         iq_skew_instr0_o,
  output wire         iq_skew_instr0_r0_o,
  output wire         iq_skew_instr0_r1_o,
  output wire         iq_skew_instr1_o,
  output wire         iq_skew_instr1_r0_o,
  output wire         iq_skew_instr1_r1_o,
  output wire         iq_instr0_adrp_fwd_o,
  output wire   [2:1] iq_instr0_adrp_fwd_src_o,
  output wire         iq_instr1_adrp_fwd_o,
  output wire   [2:0] iq_instr1_adrp_fwd_src_o,
  output wire         iq_neon_present_o,
  output wire         evnt_iq_empty_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam IQ_BODY_ENTRIES = 10;

  localparam D1 = 34;
  localparam D0 = 33;
  localparam DP = 38;
  localparam LS = 39;
  localparam OT = 40;
  localparam FN = 41;

  localparam IQ_HEAD_ENTRY0_EN_W = NEON_FP ? 5 : 4;
  localparam IQ_HEAD_ENTRY1_EN_W = 4;

  // -----------------------------
  // Genvar declarations
  // -----------------------------

  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                             iq_body_enable;
  reg                      [47:0] iq_body_entry[(IQ_BODY_ENTRIES-1):0];
  reg                             iq_full;
  reg                      [47:0] iq_holding0;
  reg                      [47:0] iq_holding1;
  reg                             iq_holding_enable;
  reg                      [32:0] iq_instr0_common_de;
  reg                       [1:0] iq_instr0_common_pdtype_de;
  reg                             iq_instr0_d0_de;
  reg                      [32:0] iq_instr0_dp_de;
  reg                       [1:0] iq_instr0_dp_pdtype_de;
  reg                      [32:0] iq_instr0_ls_de;
  reg                       [1:0] iq_instr0_ls_pdtype_de;
  reg                             iq_instr0_ls_br_taken_de;
  reg                      [32:0] iq_instr0_other_de;
  reg                       [1:0] iq_instr0_other_pdtype_de;
  reg                             iq_instr0_other_br_taken_de;
  reg                             iq_instr0_common_br_taken_de;
  reg                             iq_instr0_common_aarch64_de;
  reg                             iq_instr1_common_aarch64_de;
  reg                             iq_instr0_ctl_aarch64_de;
  reg                             iq_instr1_ctl_aarch64_de;
  reg                             iq_instr0_dp_aarch64_de;
  reg                             iq_instr0_ls_aarch64_de;
  reg                             iq_instr1_main_aarch64_de;
  reg                             iq_instr1_ls_aarch64_de;
  reg                             iq_instr0_other_aarch64_de;
  reg                             iq_instr0_is_dp_de;
  reg                             iq_instr0_is_fn_de;
  reg                             iq_instr0_is_ls_de;
  reg                             iq_instr0_is_ot_de;
  reg                       [5:0] iq_instr0_sideband_de;
  reg                      [47:0] iq_instr1_common_de;
  reg                      [32:0] iq_instr1_main_de;
  reg                      [32:0] iq_instr1_ls_de;
  reg                             last_flush;
  reg                             last_iq_holding_instr0_d1;
  reg                       [1:0] last_iq_holding_valid;
  reg                             last_iq_body_instr0_d1;
  reg                             last_iq_body_instr1_d1;
  reg                             last_iq_body_status_empty;
  reg                             last_iq_body_status_one_instr;
  reg                             last_iq_full;
  reg                       [1:0] last_iq_head_valid;
  reg                       [1:0] last_pop;
  reg                       [1:0] last_push;
  reg         [IQ_BODY_ENTRIES:0] new_valid;
  reg       [IQ_BODY_ENTRIES-1:0] read_ptr;
  reg         [IQ_BODY_ENTRIES:0] valid;
  reg       [IQ_BODY_ENTRIES-1:0] write_ptr;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                     [29:0] iq_instr1_fn_dih_de;
  wire                            iq_instr1_fn_dih_pdtype0_de;
  wire                            iq_instr1_fn_dih_aarch64_de;
  wire                            iq_instr0_is_ot_dih;
  wire                            iq_instr1_is_ot_dih;
  wire                            iq_instr1_fn_aarch64_de;
  wire                     [32:0] iq_instr1_fn_de;
  wire                            can_dual_issue;
  wire                            can_dual_issue_if_no_dih;
  wire                            clk_iq_body;
  wire                            clk_iq_holding;
  wire                      [2:0] inc_read_ptr;
  wire                      [7:0] inc_read_ptr_ctrl;
  wire                      [2:0] inc_write_ptr;
  wire                     [10:0] inc_write_ptr_ctrl;
  wire                            iq_instr1_dih;
  wire                            fn_dcu_valid_instr1;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] instr1_class_ifu1;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] instr1_class_holding1;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] instr1_class_holding0;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] instr1_class_body1;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] instr1_class_body0;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] instr0_class_ifu0;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] instr0_class_iq_body0;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] instr0_class_iq_entry1;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] instr0_class_iq_holding0;
  wire                     [47:0] iq_body0;
  wire                     [47:0] iq_body1;
  wire      [IQ_BODY_ENTRIES-1:0] iq_body_en;
  wire                            iq_body_status_empty;
  wire                            iq_body_status_one_instr;
  wire                            iq_body_status_two_instr;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] iq_head_entry0_en;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] iq_head_entry0_nostall_en;
  wire                      [6:0] iq_head_entry0_nostall_en_ctrl;
  wire  [IQ_HEAD_ENTRY0_EN_W-1:0] iq_head_entry0_stall_en;
  wire                            iq_head_entry0_stall_raw_en;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] iq_head_entry1_nostall_en;
  wire                            iq_head_entry1_nostall_raw_en;
  wire                     [11:0] iq_head_entry1_nostall_en_ctrl;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] iq_head_entry1_en;
  wire                            iq_head_entry1_stall_raw_en;
  wire  [IQ_HEAD_ENTRY1_EN_W-1:0] iq_head_entry1_stall_en;
  wire                      [1:0] iq_head_valid;
  wire                      [7:0] iq_head_valid0_ctrl;
  wire                     [12:0] iq_head_valid1_ctrl;
  wire                            iq_holding_entry0_en;
  wire                            iq_holding_entry0_nostall_en;
  wire                      [6:0] iq_holding_entry0_nostall_en_ctrl;
  wire                            iq_holding_entry0_stall_en;
  wire                            iq_holding_entry1_en;
  wire                            iq_holding_entry1_nostall_en;
  wire                      [6:0] iq_holding_entry1_nostall_en_ctrl;
  wire                            iq_holding_entry1_stall_en;
  wire                      [1:0] iq_holding_valid;
  wire                      [8:0] iq_holding_valid0_ctrl;
  wire                      [9:0] iq_holding_valid1_ctrl;
  wire                     [32:0] iq_instr0_fn_de;
  wire                     [29:0] iq_instr0_fn_dih_de;
  wire                            iq_instr0_fn_dih_32_de;
  wire                            iq_instr0_fn_dih_pdtype0_de;
  wire                            iq_instr0_fn_dih_aarch64_de;
  wire                      [1:0] iq_instr0_fn_pdtype_de;
  wire                            iq_might_push_two;
  wire                            iq_neon_present;
  wire                            iq_part_full;
  wire                      [1:0] iq_pop;
  wire                      [1:0] iq_pop_valid;
  wire                      [1:0] iq_push;
  wire                            last_enable;
  wire      [IQ_BODY_ENTRIES-1:0] new_read_ptr;
  wire      [IQ_BODY_ENTRIES-1:0] new_write_ptr;
  wire                            nxt_iq_body_enable;
  wire                     [47:0] nxt_iq_body_entry[(IQ_BODY_ENTRIES-1):0];
  wire                            nxt_iq_full;
  wire                            nxt_iq_full_nostall;
  wire                            nxt_iq_full_stall;
  wire                     [11:0] nxt_iq_full_nostall_ctrl;
  wire                      [7:0] nxt_iq_full_stall_ctrl;
  wire                            nxt_iq_holding_enable;
  wire                     [47:0] nxt_iq_instr0;
  wire                     [47:0] nxt_iq_instr1;
  wire      [IQ_BODY_ENTRIES-1:0] nxt_read_ptr;
  wire      [IQ_BODY_ENTRIES-1:0] nxt_write_ptr;
  wire                            read_ptr_en;
  wire      [IQ_BODY_ENTRIES-1:0] read_ptr_plus0;
  wire      [IQ_BODY_ENTRIES-1:0] read_ptr_plus1;
  wire                      [3:0] sel_iq_instr0;
  wire                      [3:0] sel_iq_instr0_dih;
  wire                      [3:0] sel_iq_instr0_nodih;
  wire                      [4:0] sel_iq_instr1;
  wire                      [4:0] sel_iq_instr1_dih;
  wire                      [4:0] sel_iq_instr1_nodih;
  wire                      [3:0] sel_iq_instr0_ctrl;
  wire                      [5:0] sel_iq_instr1_ctrl;
  wire                            write_ptr_en;
  wire      [IQ_BODY_ENTRIES-1:0] write_ptr_plus0;
  wire      [IQ_BODY_ENTRIES-1:0] write_ptr_plus1;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Note that there are some standard IQ rules to avoid timing paths.
  //
  // 1) Instructions destined for the 'Head' registers can not mix the source  between 'Body',
  //    'Holding' or IFU.  That is, head entry-0 can not come from the 'Body' and head entry-1
  //    from the 'Holding' or IFU.
  //
  //    The only exception to this is when there is one instruction in the 'Body' and one in the
  //    'Holding' registers.  In this case they can be combined in to the 'Head' registers.
  //
  // 2) Instructions in the 'Holding' registers can either be sunk in the 'Head' or the 'Body'.
  //    That is, we can not send holding entry-0 to head entry-0 while sending 'Holding'
  //     entry-1 to the 'Body'.
  //
  // These simple rules vastly simplify the control logic for the queue and allow timing to be
  // met.

  // ------------------------------------------------------
  // Regional clock gates
  // ------------------------------------------------------

  // The IQ holding registers can be gated if the IQ head registers are empty.
  assign nxt_iq_holding_enable = iq_head_valid[0] | iq_push[0];

  // The IQ body can be gated when there the holding registers are empty.  There is a seperate
  // gating term for the upper portion of the IQ versus lower to improve power.
  assign nxt_iq_body_enable = iq_holding_entry0_en | (iq_holding_valid[0] & iq_full);

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      iq_holding_enable <= 1'b0;
      iq_body_enable    <= 1'b0;
    end else begin
      iq_holding_enable <= nxt_iq_holding_enable;
      iq_body_enable    <= nxt_iq_body_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_iq_holding (
    .clk_i         (clk),
    .clk_enable_i  (iq_holding_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_iq_holding)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_iq_body (
    .clk_i         (clk),
    .clk_enable_i  (iq_body_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_iq_body)
  );

  // ------------------------------------------------------
  // IFU push indicators
  // ------------------------------------------------------

  // IFU is definately pushing one or two instructions to the DPU
  assign iq_push[1:0] = ifu_instr_valid_if3_i[1:0];

  // IFU might be pushing two instructions to the DPU with the following constraints:
  // iq_push[1:0] = 2'b00 -> ifu_early_two_valid_if3_i will never be set
  // iq_push[1:0] = 2'b01 -> ifu_early_two_valid_if3_i will be set providing there is an instruction in
  //                         IF3.  However the instruction in IF3 may not always be pushed.
  // iq_push[1:0] = 2'b11 -> ifu_early_two_valid_if3_i will always be set
  assign iq_might_push_two = ifu_early_two_valid_if3_i;

  // ------------------------------------------------------
  // IQ full indicator
  // ------------------------------------------------------

  // Create a valid bit that moves up and down the body depending on how many entries were pushed/popped
  always @*
    case (last_flush)
      1'b1: new_valid = {{IQ_BODY_ENTRIES{1'b0}}, 1'b1};
      1'b0:
        case (inc_write_ptr[2:1])
          2'b00:
            case (inc_read_ptr[2:1])                                   // write_ptr - read_ptr:
              2'b00: new_valid = valid[IQ_BODY_ENTRIES:0];             // 0
              2'b01: new_valid = {1'b0,  valid[IQ_BODY_ENTRIES:1]};    // -1
              2'b10: new_valid = {2'b00, valid[IQ_BODY_ENTRIES:2]};    // -2
              default: new_valid = {(IQ_BODY_ENTRIES+1){1'bx}};
            endcase
          2'b01:
            case (inc_read_ptr[2:1])
              2'b00: new_valid = {valid[IQ_BODY_ENTRIES-1:0], 1'b0 };  // +1
              2'b01: new_valid = valid[IQ_BODY_ENTRIES:0];             // 0
              2'b10: new_valid = {1'b0,  valid[IQ_BODY_ENTRIES:1]};    // -1
              default: new_valid = {(IQ_BODY_ENTRIES+1){1'bx}};
            endcase
          2'b10:
            case (inc_read_ptr[2:1])
              2'b00: new_valid = {valid[IQ_BODY_ENTRIES-2:0], 2'b00};  // +2
              2'b01: new_valid = {valid[IQ_BODY_ENTRIES-1:0], 1'b0 };  // +1
              2'b10: new_valid = valid[IQ_BODY_ENTRIES:0];             // 0
              default: new_valid = {(IQ_BODY_ENTRIES+1){1'bx}};
            endcase
          default: new_valid = {(IQ_BODY_ENTRIES+1){1'bx}};
        endcase
      default: new_valid = {(IQ_BODY_ENTRIES+1){1'bx}};
    endcase

  // IQ body status
  assign iq_body_status_empty     = new_valid[0];
  assign iq_body_status_one_instr = new_valid[1];
  assign iq_body_status_two_instr = new_valid[2];

  // Create the IQ full indicator for the next cycle assuming no stall.  Simplify by only looking at
  // push=0/1 and not 2 - in other words any push is always assumed to be 2 instructions.
  //
  //  No Empty Entries  |                 1 Empty Entry            |              2 Empty Entries                 |                3 Empty Entries           |
  //               Next |                                     Next |                                         Next |                                     Next |
  //      Holding   IQ  |      Can         Head Body Holding  IQ   |      Can         Head Body Body Holding  IQ  |      Can         Head Body Holding  IQ   |
  // Push  Valid   Full | Push Dual Finish  [1]  0D1  Valid   Full | Push Dual Finish  [1]  0D1  1D1  Valid  Full | Push Dual Finish  [1]  0D1  Valid   Full |
  //                    |                                          |                                              |                                          |
  // 1/2     x      1   |  1/2   ?    0      ?    ?      0      1  |  1/2   ?    0      ?   ?    ?      1      1  |  1/2   ?    0      ?   ?      2      1   |
  //  x      1      1   |  1/2   0    1      1    0      0      1  |  1/2   0    1      1   0    ?      1      1  |  1/2   0    1      1   0      2      1   |
  //  x      2      1   |  1/2   ?    ?      ?    ?     1/2     1  |  1/2   ?    ?      ?   ?    ?      2      1  |
  //                    |   0    ?    ?      ?    ?      1      0  |
  //                    |   0    ?    0      ?    ?      2      1  |
  //                    |   0    0    1      1    0      2      1  |

  assign nxt_iq_full_nostall_ctrl[11:0] = {flush_wr_i,                      // [ 11]
                                           iq_body0[D1],                    // [ 10]
                                           iq_head_valid[1],                // [  9]
                                           can_dual_issue,                  // [  8]
                                           finish_instr_de_i,               // [  7]
                                           iq_push[0],                      // [  6]
                                           iq_holding_valid[1:0],           // [5:4]
                                           new_valid[(IQ_BODY_ENTRIES-3)],  // [  3]
                                           new_valid[(IQ_BODY_ENTRIES-2)],  // [  2]
                                           new_valid[(IQ_BODY_ENTRIES-1)],  // [  1]
                                           new_valid[ IQ_BODY_ENTRIES   ]}; // [  0]

//  always @*
//    casez (nxt_iq_full_nostall_ctrl[11:0])
//      //  1 1
//      //  1 0 9 8 7 6 54 3210 - No Empty Entries
//      12'b0_?_?_?_?_1_??_???1 : nxt_iq_full_nostall = 1'b1;
//      12'b0_?_?_?_?_?_?1_???1 : nxt_iq_full_nostall = 1'b1;
//      //  1 1
//      //  1 0 9 8 7 6 54 3210 - 1 Empty Entry
//      12'b0_?_?_?_0_1_?0_??1? : nxt_iq_full_nostall = 1'b1;
//      12'b0_0_1_0_1_1_?0_??1? : nxt_iq_full_nostall = 1'b1;
//      12'b0_?_?_?_?_1_?1_??1? : nxt_iq_full_nostall = 1'b1;
//      12'b0_?_?_?_0_0_1?_??1? : nxt_iq_full_nostall = 1'b1;
//      12'b0_0_1_0_1_0_1?_??1? : nxt_iq_full_nostall = 1'b1;
//      //  1 1
//      //  1 0 9 8 7 6 54 3210 - 2 Empty Entries
//      12'b0_?_?_?_0_1_?1_?1?? : nxt_iq_full_nostall = 1'b1;
//      12'b0_0_1_0_1_1_?1_?1?? : nxt_iq_full_nostall = 1'b1;
//      12'b0_?_?_?_?_1_1?_?1?? : nxt_iq_full_nostall = 1'b1;
//      //  1 1
//      //  1 0 9 8 7 6 54 3210 - 3 Empty Entries
//      12'b0_?_?_?_0_1_1?_1??? : nxt_iq_full_nostall = 1'b1;
//      12'b0_0_1_0_1_1_1?_1??? : nxt_iq_full_nostall = 1'b1;
//      default                 : nxt_iq_full_nostall = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19;

  assign nxt_iq_full_nostall = ~(nxt_iq_full_nostall_ctrl[11] | net_0_1);
  assign net_0_1 = ~(net_0_2 | net_0_3);
  assign net_0_3 = (net_0_4 & net_0_5);
  assign net_0_5 = ~(nxt_iq_full_nostall_ctrl[7] & net_0_6);
  assign net_0_6 = ~(nxt_iq_full_nostall_ctrl[9] & net_0_7);
  assign net_0_7 = ~(nxt_iq_full_nostall_ctrl[8] | nxt_iq_full_nostall_ctrl[10]);
  assign net_0_4 = ~(net_0_8 & net_0_9);
  assign net_0_9 = ~(nxt_iq_full_nostall_ctrl[1] & net_0_10);
  assign net_0_10 = (nxt_iq_full_nostall_ctrl[6] | nxt_iq_full_nostall_ctrl[5]);
  assign net_0_8 = ~(nxt_iq_full_nostall_ctrl[6] & net_0_11);
  assign net_0_11 = ~(net_0_12 & net_0_13);
  assign net_0_13 = ~(nxt_iq_full_nostall_ctrl[5] & nxt_iq_full_nostall_ctrl[3]);
  assign net_0_12 = ~(nxt_iq_full_nostall_ctrl[4] & nxt_iq_full_nostall_ctrl[2]);
  assign net_0_2 = ~(net_0_14 & net_0_15);
  assign net_0_15 = ~(nxt_iq_full_nostall_ctrl[0] & net_0_16);
  assign net_0_16 = (nxt_iq_full_nostall_ctrl[6] | nxt_iq_full_nostall_ctrl[4]);
  assign net_0_14 = ~(nxt_iq_full_nostall_ctrl[6] & net_0_17);
  assign net_0_17 = ~(net_0_18 & net_0_19);
  assign net_0_19 = ~(nxt_iq_full_nostall_ctrl[2] & nxt_iq_full_nostall_ctrl[5]);
  assign net_0_18 = ~(nxt_iq_full_nostall_ctrl[4] & nxt_iq_full_nostall_ctrl[1]);

// End automatically generated logic

  // Create the IQ full indicator for the next cycle assuming a stall
  //
  //  No Empty Entries |  1 Empty Entries  |  2 Empty Entries  |  3 Empty Entries  |
  //                   |                   |                   |                   |
  //      Holding  IQ  |      Holding  IQ  |      Holding  IQ  |      Holding  IQ  |
  // Push  Valid  Full | Push  Valid  Full | Push  Valid  Full | Push  Valid  Full |
  //                   |                   |                   |                   |
  //  1/2    x      1  |  1/2    x      1  |  1/2    1      1  |  1/2    2      1  |
  //   x     1      1  |   0     1      0  |  1/2    2      1  |
  //   x     2      1  |   0     2      1  |

  assign nxt_iq_full_stall_ctrl[7:0] = {flush_wr_i,                      // [  7]
                                        iq_push[0],                      // [  6]
                                        iq_holding_valid[1:0],           // [5:4]
                                        new_valid[(IQ_BODY_ENTRIES-3)],  // [  3]
                                        new_valid[(IQ_BODY_ENTRIES-2)],  // [  2]
                                        new_valid[(IQ_BODY_ENTRIES-1)],  // [  1]
                                        new_valid[ IQ_BODY_ENTRIES   ]}; // [  0]

//  always @*
//    casez (nxt_iq_full_stall_ctrl[7:0])
//      // 7 6 54 3210 - New Write Ptr is 0 behind
//      8'b0_1_??_???1 : nxt_iq_full_stall = 1'b1;
//      8'b0_?_?1_???1 : nxt_iq_full_stall = 1'b1;
//      // 7 6 54 3210 - New Write Ptr is 1 behind
//      8'b0_1_??_??1? : nxt_iq_full_stall = 1'b1;
//      8'b0_?_1?_??1? : nxt_iq_full_stall = 1'b1;
//      // 7 6 54 3210 - New Write Ptr is 2 behind
//      8'b0_1_?1_?1?? : nxt_iq_full_stall = 1'b1;
//      // 7 6 54 3210 - New Write Ptr is 3 behind
//      8'b0_1_1?_1??? : nxt_iq_full_stall = 1'b1;
//      default        : nxt_iq_full_stall = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_7, net_1_8, net_1_9, net_1_10
;
  assign nxt_iq_full_stall = ~(nxt_iq_full_stall_ctrl[7] | net_1_1);
  assign net_1_1 = ~(net_1_2 | net_1_3);
  assign net_1_3 = (nxt_iq_full_stall_ctrl[5] & nxt_iq_full_stall_ctrl[1]);
  assign net_1_2 = ~(net_1_4 & net_1_5);
  assign net_1_5 = ~(nxt_iq_full_stall_ctrl[0] & net_1_6);
  assign net_1_6 = (nxt_iq_full_stall_ctrl[6] | nxt_iq_full_stall_ctrl[4]);
  assign net_1_4 = ~(nxt_iq_full_stall_ctrl[6] & net_1_7);
  assign net_1_7 = (nxt_iq_full_stall_ctrl[1] | net_1_8);
  assign net_1_8 = ~(net_1_9 & net_1_10);
  assign net_1_10 = ~(nxt_iq_full_stall_ctrl[4] & nxt_iq_full_stall_ctrl[2]);
  assign net_1_9 = ~(nxt_iq_full_stall_ctrl[5] & nxt_iq_full_stall_ctrl[3]);

// End automatically generated logic

  // IQ full resolution
  assign nxt_iq_full = stall_de_i ? nxt_iq_full_stall : nxt_iq_full_nostall;

  // ------------------------------------------------------
  // DPU IQ part full indicator
  // ------------------------------------------------------

  // Indicate part full once there are more than four instructions in the total IQ or the
  // Predicted-Address-Queue is full.
  assign iq_part_full = ((~iq_body_status_empty     & ~iq_body_status_one_instr & ~iq_body_status_two_instr) |
                         ( iq_body_status_one_instr &  iq_holding_valid[1]) |
                         ( iq_body_status_two_instr &  iq_holding_valid[0]) |
                         paq_full_i);

  // ------------------------------------------------------
  // Register control signals
  // ------------------------------------------------------
  // To ease timing on critical signals such as iq_push[1:0] from the IFU and iq_pop[1:0]
  // signals from the De stage we register them and then figure out the read/write pointers
  // in the next stage when there is plenty of time.  In order to simplify the generation of
  // the read pointer the bottom three valid signals from the previous cycle are also
  // registered.

  // To make sure we don't increment a pointer when the iq_pop[1:0] signal is asserted but
  // the DPU is stalling we qualify the iq_pop[1:0] signals before registering them.
  assign iq_pop_valid[1:0] = {2{~stall_de_i}} & iq_pop[1:0];

  assign last_enable = iq_push[0] | iq_pop[0] | flush_wr_i | last_push[0] | last_pop[0] | last_iq_holding_valid[0] | last_flush;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      last_iq_holding_instr0_d1     <= 1'b0;
      last_iq_holding_valid[1:0]    <= {2{1'b0}};
      last_iq_body_status_empty     <= 1'b1;
      last_iq_body_status_one_instr <= 1'b0;
      last_iq_body_instr1_d1        <= 1'b0;
      last_iq_body_instr0_d1        <= 1'b0;
      last_iq_head_valid[1:0]       <= {2{1'b0}};
      last_push[1:0]                <= {2{1'b0}};
      last_pop[1:0]                 <= {2{1'b0}};
      last_flush                    <= 1'b0;
      last_iq_full                  <= 1'b0;
      valid                         <= {{IQ_BODY_ENTRIES{1'b0}}, 1'b1};
      iq_full                       <= 1'b0;
    end else if (last_enable) begin
      last_iq_holding_instr0_d1     <= iq_holding0[D1];
      last_iq_holding_valid[1:0]    <= iq_holding_valid[1:0];
      last_iq_body_status_empty     <= iq_body_status_empty;
      last_iq_body_status_one_instr <= iq_body_status_one_instr;
      last_iq_body_instr1_d1        <= iq_body1[D1];
      last_iq_body_instr0_d1        <= iq_body0[D1];
      last_iq_head_valid[1:0]       <= iq_head_valid[1:0];
      last_push[1:0]                <= iq_push[1:0];
      last_pop[1:0]                 <= iq_pop_valid[1:0];
      last_flush                    <= flush_wr_i;
      last_iq_full                  <= iq_full;
      valid                         <= new_valid;
      iq_full                       <= nxt_iq_full;
    end

  // ------------------------------------------------------
  // IQ holding entry-1 enable
  // ------------------------------------------------------
  //
  //  Head [0] = 1  |     Head [1] = 1    | Body = 1+ | Holding = 1+ |
  //                |                     |           |              |
  //                |      Can            |           |              |
  // Push Finish En | Push Dual Finish En |  Push En  |   Push En    |
  //                |                     |           |              |
  //  1     0    1  |  1    x     0    1  |   1   1   |    1   1     |
  //  1     0    1  |  1    0     1    1  |

  assign iq_holding_entry1_nostall_en_ctrl[6:0] = {iq_holding_valid[0],
                                                   iq_body_status_empty,
                                                   iq_head_valid[1:0],
                                                   iq_might_push_two,
                                                   finish_instr_de_i,
                                                   can_dual_issue};

//  always @*
//    casez (iq_holding_entry1_nostall_en_ctrl[6:0])
//      // 6 5 43 2 1 0 - Head Entry[0] = 1
//      7'b?_1_01_1_0_? : iq_holding_entry1_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Head Entry[1] = 1
//      7'b?_1_1?_1_0_? : iq_holding_entry1_nostall_en = 1'b1;
//      7'b?_1_1?_1_1_0 : iq_holding_entry1_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Body = 1
//      7'b?_0_??_1_?_? : iq_holding_entry1_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Holding = 1+
//      7'b1_?_??_1_?_? : iq_holding_entry1_nostall_en = 1'b1;
//      default         : iq_holding_entry1_nostall_en = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_2_1, net_2_2, net_2_3, net_2_4, net_2_5, net_2_6, net_2_7;

  assign net_2_1 = ~iq_holding_entry1_nostall_en_ctrl[4];
  assign iq_holding_entry1_nostall_en = (iq_holding_entry1_nostall_en_ctrl[2] & net_2_2);
  assign net_2_2 = ~(iq_holding_entry1_nostall_en_ctrl[5] & net_2_3);
  assign net_2_3 = ~(net_2_4 | iq_holding_entry1_nostall_en_ctrl[6]);
  assign net_2_4 = ~(net_2_5 & net_2_6);
  assign net_2_6 = (iq_holding_entry1_nostall_en_ctrl[1] | net_2_7);
  assign net_2_7 = ~(iq_holding_entry1_nostall_en_ctrl[4] | iq_holding_entry1_nostall_en_ctrl[3]);
  assign net_2_5 = (iq_holding_entry1_nostall_en_ctrl[0] | net_2_1);

// End automatically generated logic

  // IQ holding entry-1 enable assuming a stall
  assign iq_holding_entry1_stall_en = iq_might_push_two & iq_head_valid[0];

  // IQ holding entry-1 enable resolution
  assign iq_holding_entry1_en = stall_de_i ? iq_holding_entry1_stall_en : iq_holding_entry1_nostall_en;

  // ------------------------------------------------------
  // IQ holding entry-1 valid
  // ------------------------------------------------------
  //
  //   Last          |   Last          | Last       | Last         |     Last      |
  //   Head [0] = 1  |   Head [1] = 1  | Body = 1+  | Holding = 1+ |  DPU IQ Full  |
  //                 |                 |            |              |               |
  // Last Last       | Last Last       | Last       |  Last        |  Last         |
  // Pop  Push Valid | Pop  Push Valid | Push Valid |  Push Valid  | Holding Valid |
  //                 |                 |            |              |               |
  //  0    2     1   |  0    2     1   |  2     1   |   2     1    |    2      1   |
  //                 |  1    2     1   |            |

  assign iq_holding_valid1_ctrl[9:0] = {last_flush,                 // [  9]
                                        last_iq_full,               // [  8]
                                        last_iq_holding_valid[1:0], // [7:6]
                                        last_iq_body_status_empty,  // [  5]
                                        last_iq_head_valid[1:0],    // [4:3]
                                        last_push[1],               // [  2]
                                        last_pop[1:0]};             // [1:0]

//  always @*
//    casez (iq_holding_valid1_ctrl[9:0])
//      //  9 8 76 5 43 2 10 - Head Entry[0] = 1
//      10'b0_?_??_1_01_1_?0 : iq_holding_valid[1] = 1'b1;
//      //  9 8 76 5 43 2 10 - Head Entry[1] = 1
//      10'b0_?_??_1_1?_1_0? : iq_holding_valid[1] = 1'b1;
//      //  9 8 76 5 43 2 10 - Body = 1+
//      10'b0_?_??_0_??_1_?? : iq_holding_valid[1] = 1'b1;
//      //  9 8 76 5 43 2 10 - Holding = 1+
//      10'b0_?_?1_?_??_1_?? : iq_holding_valid[1] = 1'b1;
//      //  9 8 76 5 43 2 10 - Last DPU IQ Full
//      10'b0_1_1?_?_??_?_?? : iq_holding_valid[1] = 1'b1;
//      default              : iq_holding_valid[1] = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_3_1, net_3_2, net_3_3, net_3_4, net_3_5, net_3_6, net_3_7, net_3_8, net_3_9, net_3_10
;
  assign net_3_1 = ~iq_holding_valid1_ctrl[4];
  assign iq_holding_valid[1] = ~(iq_holding_valid1_ctrl[9] | net_3_2);
  assign net_3_2 = ~(net_3_3 | net_3_4);
  assign net_3_4 = (iq_holding_valid1_ctrl[2] & net_3_5);
  assign net_3_5 = ~(net_3_6 & net_3_7);
  assign net_3_7 = (net_3_1 | iq_holding_valid1_ctrl[1]);
  assign net_3_6 = ~(iq_holding_valid1_ctrl[6] | net_3_8);
  assign net_3_8 = ~(iq_holding_valid1_ctrl[5] & net_3_9);
  assign net_3_9 = ~(iq_holding_valid1_ctrl[3] & net_3_10);
  assign net_3_10 = ~(iq_holding_valid1_ctrl[4] | iq_holding_valid1_ctrl[0]);
  assign net_3_3 = (iq_holding_valid1_ctrl[8] & iq_holding_valid1_ctrl[7]);

// End automatically generated logic

  // ------------------------------------------------------
  // IQ holding entry-1 data
  // ------------------------------------------------------

  always @(posedge clk_iq_holding)
    if (iq_holding_entry1_en)
      iq_holding1[47:0] <= ifu_instr1_if3_i[47:0];

  // ------------------------------------------------------
  // IQ holding entry-0 enable
  // ------------------------------------------------------
  //
  //  Head [0] = 1  |     Head [1] = 1    | Body = 1+ | Holding = 1+ |
  //                |                     |           |              |
  //                |      Can            |           |              |
  // Push Finish En | Push Dual Finish En |  Push En  |   Push En    |
  //                |                     |           |              |
  //  1     0    1  |  1    x     0    1  |   1   1   |    1   1     |
  //  1     0    1  |  1    0     1    1  |
  //  1     x    1  |

  assign iq_holding_entry0_nostall_en_ctrl[6:0] = {iq_holding_valid[0],
                                                   iq_body_status_empty,
                                                   iq_head_valid[1:0],
                                                   iq_push[0],
                                                   finish_instr_de_i,
                                                   can_dual_issue};

//  always @*
//    casez (iq_holding_entry0_nostall_en_ctrl[6:0])
//      // 6 5 43 2 1 0 - Head Entry[0] = 1
//      7'b?_1_01_1_0_? : iq_holding_entry0_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Head Entry[1] = 1
//      7'b?_1_1?_1_0_? : iq_holding_entry0_nostall_en = 1'b1;
//      7'b?_1_1?_1_1_0 : iq_holding_entry0_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Body = 1+
//      7'b?_0_??_1_?_? : iq_holding_entry0_nostall_en = 1'b1;
//      // 6 5 43 2 1 0 - Holding = 1+
//      7'b1_?_??_1_?_? : iq_holding_entry0_nostall_en = 1'b1;
//      default         : iq_holding_entry0_nostall_en = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_4_1, net_4_2, net_4_3, net_4_4, net_4_5, net_4_6, net_4_7;

  assign net_4_1 = ~iq_holding_entry0_nostall_en_ctrl[4];
  assign iq_holding_entry0_nostall_en = (iq_holding_entry0_nostall_en_ctrl[2] & net_4_2);
  assign net_4_2 = ~(iq_holding_entry0_nostall_en_ctrl[5] & net_4_3);
  assign net_4_3 = ~(net_4_4 | iq_holding_entry0_nostall_en_ctrl[6]);
  assign net_4_4 = ~(net_4_5 & net_4_6);
  assign net_4_6 = (iq_holding_entry0_nostall_en_ctrl[1] | net_4_7);
  assign net_4_7 = ~(iq_holding_entry0_nostall_en_ctrl[4] | iq_holding_entry0_nostall_en_ctrl[3]);
  assign net_4_5 = (iq_holding_entry0_nostall_en_ctrl[0] | net_4_1);

// End automatically generated logic

  // IQ holding entry-0 enable assuming a stall
  assign iq_holding_entry0_stall_en = iq_push[0] & iq_head_valid[0];

  // IQ holding entry-0 enable resolution
  assign iq_holding_entry0_en = stall_de_i ? iq_holding_entry0_stall_en : iq_holding_entry0_nostall_en;

  // ------------------------------------------------------
  // IQ holding entry-0 valid
  // ------------------------------------------------------
  //
  //   Last          |   Last          | Last       | Last         |       Last    |
  //   Head [0] = 1  |   Head [1] = 1  | Body = 1+  | Holding = 1+ |  DPU IQ Full  |
  //                 |                 |            |              |               |
  // Last Last       | Last Last       | Last       |  Last        |  Last         |
  // Pop  Push Valid | Pop  Push Valid | Push Valid |  Push Valid  | Holding Valid |
  //                 |                 |            |              |               |
  //  0    1     1   |  0    1     1   |  1     1   |   1     1    |    1      1   |
  //  0    2     1   |  0    2     1   |  2     1   |   2     1    |    2      1   |
  //                 |  1    1     1   |
  //                 |  1    2     1   |

  assign iq_holding_valid0_ctrl[8:0] = {last_flush,                // [  8]
                                        last_iq_full,              // [  7]
                                        last_iq_holding_valid[0],  // [  6]
                                        last_iq_body_status_empty, // [  5]
                                        last_iq_head_valid[1:0],   // [4:3]
                                        last_push[0],              // [  2]
                                        last_pop[1:0]};            // [1:0]

//  always @*
//    casez (iq_holding_valid0_ctrl[8:0])
//      // 8 76 5 43 2 10 - Head Entry[0] = 1
//      9'b0_??_1_01_1_?0 : iq_holding_valid[0] = 1'b1;
//      // 8 76 5 43 2 10 - Head Entry[1] = 1
//      9'b0_??_1_1?_1_0? : iq_holding_valid[0] = 1'b1;
//      // 8 76 5 43 2 10 - Body = 1+
//      9'b0_??_0_??_1_?? : iq_holding_valid[0] = 1'b1;
//      // 8 76 5 43 2 10 - Holding = 1+
//      9'b0_?1_?_??_1_?? : iq_holding_valid[0] = 1'b1;
//      // 8 76 5 43 2 10 - Last DPU IQ Full
//      9'b0_11_?_??_?_?? : iq_holding_valid[0] = 1'b1;
//      default           : iq_holding_valid[0] = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_5_1, net_5_2, net_5_3, net_5_4, net_5_5, net_5_6, net_5_7, net_5_8, net_5_9, net_5_10
;
  assign net_5_1 = ~iq_holding_valid0_ctrl[4];
  assign iq_holding_valid[0] = ~(iq_holding_valid0_ctrl[8] | net_5_2);
  assign net_5_2 = ~(net_5_3 | net_5_4);
  assign net_5_4 = (iq_holding_valid0_ctrl[7] & iq_holding_valid0_ctrl[6]);
  assign net_5_3 = (iq_holding_valid0_ctrl[2] & net_5_5);
  assign net_5_5 = ~(net_5_6 & net_5_7);
  assign net_5_7 = (net_5_1 | iq_holding_valid0_ctrl[1]);
  assign net_5_6 = ~(iq_holding_valid0_ctrl[6] | net_5_8);
  assign net_5_8 = ~(iq_holding_valid0_ctrl[5] & net_5_9);
  assign net_5_9 = ~(iq_holding_valid0_ctrl[3] & net_5_10);
  assign net_5_10 = ~(iq_holding_valid0_ctrl[4] | iq_holding_valid0_ctrl[0]);

// End automatically generated logic

  // ------------------------------------------------------
  // IQ holding entry-0 data
  // ------------------------------------------------------

  // Holding data
  always @(posedge clk_iq_holding)
    if (iq_holding_entry0_en)
      iq_holding0[47:0] <= ifu_instr0_if3_i[47:0];

  // ------------------------------------------------------
  // IQ body write pointer
  // ------------------------------------------------------
  //
  //   Last          |      Last             |       Last            |       Last           |
  //   Head [0] = 1  |      Head [1] = 1     |       Body = 1 only   |       Body = 2+      |
  //                 |                       |                       |                      |
  //                 |             Last      |             Last      |                      |
  // Last  Last  Inc | Last  Last  Hold0 Inc | Last  Last  Hold0 Inc |  IQ  Last  Last  Inc |
  // Pop   Hold  Ptr | Pop   Hold   D1   Ptr | Pop   Hold   D1   Ptr | Full Pop   Hold  Ptr |
  //                 |                       |                       |                      |
  //  0     1     1  |  0     1     x     1  |  0     1     x     1  |  0    0     1     1  |
  //  0     2     2  |  0     2     x     2  |  0     2     x     2  |  0    0     2     2  |
  //  1     1     0  |  1     1     1     0  |  1     1     x     1  |  0    1     1     1  |
  //  1     2     0  |  1     1     0     1  |  1     2     x     2  |  0    1     2     2  |
  //                 |  1     2     x     2  |  2     1     0     1  |  0    2     1     1  |
  //                 |  2     1     x     0  |  2     1     1     0  |  0    2     2     2  |
  //                 |  2     2     x     0  |  2     2     x     2  |

  assign inc_write_ptr_ctrl[10:0] = {last_flush,                    // [ 10]
                                     last_iq_full,                  // [  9]
                                     last_iq_body_status_one_instr, // [  8]
                                     last_iq_body_status_empty,     // [  7]
                                     last_iq_holding_instr0_d1,     // [  6]
                                     last_iq_holding_valid[1:0],    // [5:4]
                                     last_iq_head_valid[1:0],       // [3:2]
                                     last_pop[1:0]};                // [1:0]

//  always @*
//    casez (inc_write_ptr_ctrl[10:0])
//      //  1
//      //  0 9 87 6 54 32 10 - Last Head [0] = 1
//      11'b0_?_?1_?_01_01_?0 : inc_write_ptr[2:0] = 3'b010;
//      11'b0_?_?1_?_1?_01_?0 : inc_write_ptr[2:0] = 3'b100;
//      //  1
//      //  0 9 87 6 54 32 10 - Last Head [1] = 1
//      11'b0_?_?1_?_01_1?_?0 : inc_write_ptr[2:0] = 3'b010;
//      11'b0_?_?1_0_01_1?_01 : inc_write_ptr[2:0] = 3'b010;
//      11'b0_?_?1_?_1?_1?_0? : inc_write_ptr[2:0] = 3'b100;
//      //  1
//      //  0 9 87 6 54 32 10 - Last Body = 1 only
//      11'b0_?_1?_?_01_??_0? : inc_write_ptr[2:0] = 3'b010;
//      11'b0_?_1?_?_1?_??_0? : inc_write_ptr[2:0] = 3'b100;
//      11'b0_?_1?_0_01_??_1? : inc_write_ptr[2:0] = 3'b010;
//      11'b0_?_1?_?_1?_??_1? : inc_write_ptr[2:0] = 3'b100;
//      //  1
//      //  0 9 87 6 54 32 10 - Last Body = 2+
//      11'b0_0_00_?_01_??_?? : inc_write_ptr[2:0] = 3'b010;
//      11'b0_0_00_?_1?_??_?? : inc_write_ptr[2:0] = 3'b100;
//      default               : inc_write_ptr[2:0] = 3'b001;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_6_1, net_6_2, net_6_3, net_6_4, net_6_5, net_6_6, net_6_7, net_6_8, net_6_9, net_6_10,
         net_6_11, net_6_12, net_6_13, net_6_14, net_6_15, net_6_16, net_6_17, net_6_18,
         net_6_19, net_6_20, net_6_21, net_6_22, net_6_23, net_6_24, net_6_25, net_6_26,
         net_6_27, net_6_28, net_6_29, net_6_30, net_6_31, net_6_32, net_6_33, net_6_34,
         net_6_35, net_6_36, net_6_37, net_6_38, net_6_39, net_6_40, net_6_41, net_6_42,
         net_6_43;

  assign net_6_1 = ~inc_write_ptr_ctrl[7];
  assign net_6_2 = ~inc_write_ptr_ctrl[5];
  assign net_6_3 = ~inc_write_ptr_ctrl[1];
  assign inc_write_ptr[2] = ~(inc_write_ptr_ctrl[10] | net_6_4);
  assign net_6_4 = ~(inc_write_ptr_ctrl[5] & net_6_5);
  assign net_6_5 = ~(net_6_6 & net_6_7);
  assign net_6_6 = (net_6_8 & net_6_9);
  assign net_6_9 = ~(inc_write_ptr_ctrl[2] & net_6_10);
  assign net_6_10 = ~(net_6_11 | inc_write_ptr_ctrl[3]);
  assign inc_write_ptr[1] = (net_6_12 & net_6_2);
  assign net_6_12 = ~(inc_write_ptr_ctrl[10] | net_6_13);
  assign net_6_13 = ~(inc_write_ptr_ctrl[4] & net_6_14);
  assign net_6_14 = (net_6_15 | net_6_16);
  assign net_6_16 = ~(net_6_17 & net_6_18);
  assign net_6_18 = ~(inc_write_ptr_ctrl[8] & net_6_3);
  assign net_6_17 = (inc_write_ptr_ctrl[6] | net_6_8);
  assign net_6_8 = ~(inc_write_ptr_ctrl[8] | net_6_19);
  assign net_6_19 = ~(net_6_1 | net_6_20);
  assign net_6_15 = ~(net_6_21 & net_6_22);
  assign net_6_22 = (net_6_7 | inc_write_ptr_ctrl[8]);
  assign net_6_7 = (inc_write_ptr_ctrl[7] | inc_write_ptr_ctrl[9]);
  assign net_6_21 = (net_6_11 | net_6_23);
  assign net_6_11 = (inc_write_ptr_ctrl[0] | net_6_1);
  assign inc_write_ptr[0] = (net_6_24 | net_6_25);
  assign net_6_25 = ~(net_6_26 & net_6_27);
  assign net_6_27 = (inc_write_ptr_ctrl[5] | inc_write_ptr_ctrl[4]);
  assign net_6_26 = ~(inc_write_ptr_ctrl[10] | net_6_28);
  assign net_6_28 = ~(inc_write_ptr_ctrl[8] | net_6_29);
  assign net_6_29 = ~(net_6_30 | net_6_31);
  assign net_6_31 = (inc_write_ptr_ctrl[7] & net_6_32);
  assign net_6_32 = (net_6_33 | net_6_34);
  assign net_6_34 = (net_6_35 | net_6_23);
  assign net_6_35 = (inc_write_ptr_ctrl[1] & net_6_36);
  assign net_6_36 = (inc_write_ptr_ctrl[5] & inc_write_ptr_ctrl[3]);
  assign net_6_33 = (inc_write_ptr_ctrl[0] & net_6_37);
  assign net_6_37 = (net_6_20 | net_6_38);
  assign net_6_20 = ~(inc_write_ptr_ctrl[3] & net_6_3);
  assign net_6_30 = (inc_write_ptr_ctrl[9] & net_6_1);
  assign net_6_24 = (net_6_39 & net_6_40);
  assign net_6_40 = (net_6_38 & inc_write_ptr_ctrl[1]);
  assign net_6_38 = (inc_write_ptr_ctrl[6] & net_6_2);
  assign net_6_39 = (net_6_41 | net_6_42);
  assign net_6_42 = (inc_write_ptr_ctrl[8] & net_6_1);
  assign net_6_41 = (inc_write_ptr_ctrl[7] & net_6_43);
  assign net_6_43 = (net_6_23 | inc_write_ptr_ctrl[0]);
  assign net_6_23 = ~(inc_write_ptr_ctrl[3] | inc_write_ptr_ctrl[2]);

// End automatically generated logic

  // Generate the new write pointer
  assign new_write_ptr = (({IQ_BODY_ENTRIES{inc_write_ptr[0]}} &  write_ptr[(IQ_BODY_ENTRIES-1):0]) |
                          ({IQ_BODY_ENTRIES{inc_write_ptr[1]}} & {write_ptr[(IQ_BODY_ENTRIES-2):0], write_ptr[(IQ_BODY_ENTRIES-1)]}) |
                          ({IQ_BODY_ENTRIES{inc_write_ptr[2]}} & {write_ptr[(IQ_BODY_ENTRIES-3):0], write_ptr[(IQ_BODY_ENTRIES-1):(IQ_BODY_ENTRIES-2)]}));

  assign write_ptr_plus0 =  new_write_ptr[(IQ_BODY_ENTRIES-1):0];
  assign write_ptr_plus1 = {new_write_ptr[(IQ_BODY_ENTRIES-2):0], new_write_ptr[(IQ_BODY_ENTRIES-1)]};

  // If a flush occurs then the write pointer is forced to the reset position
  assign nxt_write_ptr = flush_wr_i ? {{(IQ_BODY_ENTRIES-1){1'b0}}, 1'b1} : new_write_ptr[(IQ_BODY_ENTRIES-1):0];

  // Generate write pointer clock enable
  assign write_ptr_en = flush_wr_i | inc_write_ptr[1] | inc_write_ptr[2];

  // Register the new write pointer
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      write_ptr[(IQ_BODY_ENTRIES-1):0] <= {{(IQ_BODY_ENTRIES-1){1'b0}}, 1'b1};
    else if (write_ptr_en)
      write_ptr[(IQ_BODY_ENTRIES-1):0] <= nxt_write_ptr[(IQ_BODY_ENTRIES-1):0];

  // IQ body clock enable
  assign iq_body_en = ({IQ_BODY_ENTRIES{iq_head_valid[0]}} &
                       ((write_ptr_plus0[(IQ_BODY_ENTRIES-1):0] & {IQ_BODY_ENTRIES{iq_holding_valid[0] & ~iq_full & ~new_valid[IQ_BODY_ENTRIES]}}) |
                        (write_ptr_plus1[(IQ_BODY_ENTRIES-1):0] & {IQ_BODY_ENTRIES{iq_holding_valid[1] & ~iq_full & ~new_valid[IQ_BODY_ENTRIES] & ~new_valid[IQ_BODY_ENTRIES-1]}})));

  // ------------------------------------------------------
  // IQ Body
  // ------------------------------------------------------

  generate for (i = 0; i < IQ_BODY_ENTRIES; i = i + 1) begin : g_iq_body

    assign nxt_iq_body_entry[i] = (({48{write_ptr_plus0[i]}} & iq_holding0[47:0]) |
                                   ({48{write_ptr_plus1[i]}} & iq_holding1[47:0]));

    always @(posedge clk_iq_body)
      if (iq_body_en[i])
        iq_body_entry[i] <= nxt_iq_body_entry[i];

  end endgenerate

  // ------------------------------------------------------
  // IQ body read pointer
  // ------------------------------------------------------
  //
  //  Last Body = 0  |     Last Body = 1     |        Last Body = 2+       |
  //                 |                       |                             |
  //       Last      |       Last  Last      |       Last  Last  Last      |
  // Last  Head  Inc | Last  Head  Body0 Inc | Last  Head  Body0 Body1 Inc |
  // Pop   [1]   Ptr | Pop   [1]    D1   Ptr | Pop   [1]    D1    D1   Ptr |
  //                 |                       |                             |
  //  x     x     0  |  0     x      x    0  |  0     x      x     x    0  |
  //                 |  1     0      x    1  |  1     0      x     0    1  |
  //                 |  1     1      0    0  |  1     0      x     1    2  |
  //                 |  1     1      1    1  |  1     1      0     x    0  |
  //                 |  2     x      x    1  |  1     1      1     x    1  |
  //                                         |  2     1      x     0    1  |
  //                                         |  2     1      x     1    2  |

  assign inc_read_ptr_ctrl[7:0] = {last_flush,                    // [  7]
                                   last_iq_body_instr1_d1,        // [  6]
                                   last_iq_body_instr0_d1,        // [  5]
                                   last_iq_body_status_one_instr, // [  4]
                                   last_iq_body_status_empty,     // [  3]
                                   last_iq_head_valid[1],         // [  2]
                                   last_pop[1:0]};                // [1:0]

//  always @*
//    casez (inc_read_ptr_ctrl[7:0])
//      // 7 65 43 2 10 - Increment pointer by 2
//      8'b0_1?_00_1_11 : inc_read_ptr[2:0] = 3'b100;
//      8'b0_1?_00_0_01 : inc_read_ptr[2:0] = 3'b100;
//      // 7 65 43 2 10 - Increment pointer by 1, Body 2+
//      8'b0_0?_00_1_11 : inc_read_ptr[2:0] = 3'b010;
//      8'b0_0?_00_0_01 : inc_read_ptr[2:0] = 3'b010;
//      8'b0_?1_00_1_01 : inc_read_ptr[2:0] = 3'b010;
//      // 7 65 43 2 10 - Increment pointer by 1, Body 1
//      8'b0_??_1?_?_1? : inc_read_ptr[2:0] = 3'b010;
//      8'b0_?1_1?_1_?1 : inc_read_ptr[2:0] = 3'b010;
//      8'b0_??_1?_0_?1 : inc_read_ptr[2:0] = 3'b010;
//      default         : inc_read_ptr[2:0] = 3'b001;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_7_1, net_7_2, net_7_3, net_7_4, net_7_5, net_7_6, net_7_7, net_7_8, net_7_9, net_7_10,
         net_7_11, net_7_12, net_7_13, net_7_14, net_7_15, net_7_16, net_7_17, net_7_18,
         net_7_19, net_7_20, net_7_21, net_7_22, net_7_23, net_7_24, net_7_25;

  assign net_7_1 = ~inc_read_ptr_ctrl[2];
  assign net_7_2 = ~inc_read_ptr_ctrl[1];
  assign inc_read_ptr[2] = ~(net_7_3 | net_7_4);
  assign net_7_4 = ~(inc_read_ptr_ctrl[6] & net_7_5);
  assign net_7_5 = ~(inc_read_ptr_ctrl[7] | net_7_6);
  assign net_7_6 = ~(inc_read_ptr_ctrl[0] & net_7_7);
  assign net_7_7 = ~(inc_read_ptr_ctrl[3] | inc_read_ptr_ctrl[4]);
  assign inc_read_ptr[1] = ~(inc_read_ptr_ctrl[7] | net_7_8);
  assign net_7_8 = ~(net_7_9 | net_7_10);
  assign net_7_10 = (inc_read_ptr_ctrl[0] & net_7_11);
  assign net_7_11 = (net_7_12 | net_7_13);
  assign net_7_13 = ~(inc_read_ptr_ctrl[3] | net_7_14);
  assign net_7_14 = ~(net_7_15 | net_7_16);
  assign net_7_16 = (net_7_17 & inc_read_ptr_ctrl[5]);
  assign net_7_17 = (inc_read_ptr_ctrl[2] & net_7_2);
  assign net_7_15 = ~(net_7_3 | inc_read_ptr_ctrl[6]);
  assign net_7_3 = (inc_read_ptr_ctrl[2] ^ inc_read_ptr_ctrl[1]);
  assign net_7_12 = (inc_read_ptr_ctrl[4] & net_7_18);
  assign net_7_9 = (inc_read_ptr_ctrl[1] & inc_read_ptr_ctrl[4]);
  assign inc_read_ptr[0] = ~(net_7_19 & net_7_20);
  assign net_7_20 = (inc_read_ptr_ctrl[4] | net_7_21);
  assign net_7_21 = ~(inc_read_ptr_ctrl[3] | net_7_22);
  assign net_7_22 = ~(inc_read_ptr_ctrl[0] & net_7_23);
  assign net_7_23 = (net_7_2 | inc_read_ptr_ctrl[2]);
  assign net_7_19 = ~(inc_read_ptr_ctrl[7] | net_7_24);
  assign net_7_24 = (net_7_2 & net_7_25);
  assign net_7_25 = ~(inc_read_ptr_ctrl[0] & net_7_18);
  assign net_7_18 = (net_7_1 | inc_read_ptr_ctrl[5]);

// End automatically generated logic

  // Generate the new read pointer
  assign new_read_ptr = (({IQ_BODY_ENTRIES{inc_read_ptr[0]}} &  read_ptr[(IQ_BODY_ENTRIES-1):0]) |
                         ({IQ_BODY_ENTRIES{inc_read_ptr[1]}} & {read_ptr[(IQ_BODY_ENTRIES-2):0], read_ptr[(IQ_BODY_ENTRIES-1)]}) |
                         ({IQ_BODY_ENTRIES{inc_read_ptr[2]}} & {read_ptr[(IQ_BODY_ENTRIES-3):0], read_ptr[(IQ_BODY_ENTRIES-1):(IQ_BODY_ENTRIES-2)]}));

  assign read_ptr_plus0 =  new_read_ptr[(IQ_BODY_ENTRIES-1):0];
  assign read_ptr_plus1 = {new_read_ptr[(IQ_BODY_ENTRIES-2):0], new_read_ptr[(IQ_BODY_ENTRIES-1)]};

  // If a flush occurs then the read pointer is forced to the reset position
  assign nxt_read_ptr = flush_wr_i ? {{(IQ_BODY_ENTRIES-1){1'b0}}, 1'b1} : new_read_ptr[(IQ_BODY_ENTRIES-1):0];

  // Generate read pointer clock enable
  assign read_ptr_en = flush_wr_i | inc_read_ptr[1] | inc_read_ptr[2];

  // Register the new read pointer
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      read_ptr[(IQ_BODY_ENTRIES-1):0] <= {{(IQ_BODY_ENTRIES-1){1'b0}}, 1'b1};
    else if (read_ptr_en)
      read_ptr[(IQ_BODY_ENTRIES-1):0] <= nxt_read_ptr[(IQ_BODY_ENTRIES-1):0];

  // ------------------------------------------------------
  // IQ body instruction extraction
  // ------------------------------------------------------

  assign iq_body0[47:0] = (({48{read_ptr_plus0[0]}} & iq_body_entry[0][47:0]) |
                           ({48{read_ptr_plus0[1]}} & iq_body_entry[1][47:0]) |
                           ({48{read_ptr_plus0[2]}} & iq_body_entry[2][47:0]) |
                           ({48{read_ptr_plus0[3]}} & iq_body_entry[3][47:0]) |
                           ({48{read_ptr_plus0[4]}} & iq_body_entry[4][47:0]) |
                           ({48{read_ptr_plus0[5]}} & iq_body_entry[5][47:0]) |
                           ({48{read_ptr_plus0[6]}} & iq_body_entry[6][47:0]) |
                           ({48{read_ptr_plus0[7]}} & iq_body_entry[7][47:0]) |
                           ({48{read_ptr_plus0[8]}} & iq_body_entry[8][47:0]) |
                           ({48{read_ptr_plus0[9]}} & iq_body_entry[9][47:0]));

  assign iq_body1[47:0] = (({48{read_ptr_plus1[0]}} & iq_body_entry[0][47:0]) |
                           ({48{read_ptr_plus1[1]}} & iq_body_entry[1][47:0]) |
                           ({48{read_ptr_plus1[2]}} & iq_body_entry[2][47:0]) |
                           ({48{read_ptr_plus1[3]}} & iq_body_entry[3][47:0]) |
                           ({48{read_ptr_plus1[4]}} & iq_body_entry[4][47:0]) |
                           ({48{read_ptr_plus1[5]}} & iq_body_entry[5][47:0]) |
                           ({48{read_ptr_plus1[6]}} & iq_body_entry[6][47:0]) |
                           ({48{read_ptr_plus1[7]}} & iq_body_entry[7][47:0]) |
                           ({48{read_ptr_plus1[8]}} & iq_body_entry[8][47:0]) |
                           ({48{read_ptr_plus1[9]}} & iq_body_entry[9][47:0]));

  // ------------------------------------------------------
  // IQ head entry-0 instruction class
  // ------------------------------------------------------

  assign instr1_class_ifu1      = {(ifu_instr_valid_if3_i[1] &  ifu_instr1_if3_i[FN]),
                                   (ifu_instr_valid_if3_i[1] &  ifu_instr1_if3_i[LS]),
                                   (ifu_instr_valid_if3_i[1] & (ifu_instr1_if3_i[OT] | ifu_instr1_if3_i[DP])),
                                   1'b1};

  assign instr1_class_holding1  = {iq_holding1[FN], iq_holding1[LS], (iq_holding1[OT] | iq_holding1[DP]), 1'b1};
  assign instr1_class_holding0  = {iq_holding0[FN], iq_holding0[LS], (iq_holding0[OT] | iq_holding0[DP]), 1'b1};
  assign instr1_class_body1     = {iq_body1[FN],    iq_body1[LS],    (iq_body1[OT]    | iq_body1[DP]),    1'b1};
  assign instr1_class_body0     = {iq_body0[FN],    iq_body0[LS],    (iq_body0[OT]    | iq_body0[DP]),    1'b1};

  // ------------------------------------------------------
  // IQ head entry-1 enable
  // ------------------------------------------------------

  // IQ head entry-1 enable assuming no stall
  //
  // Head          | Head           |     Head             |          Holding Valid         |              Body Valid              |    Body    = 1 only           |
  // Entry [0] = 0 | Entry [0] = 1  |     Entry [1] = 1    |          Body Empty            |              Holding Empty           |    Holding = 1 only           |
  //               |                |                      |                                |                                      |                               |
  //   IFU         | IFU            | IFU         Can      |            Hold0       Can     |            Body0 Body1       Can     |           Hold0       Can     |
  //   Push  En    | Push Finish En | Push Finish Dual En  | Hold Head1  D1  Finish Dual En | Body Head1  D1    D1  Finish Dual En | Hold Body  D1  Finish Dual En |
  //               |                |                      |                                |                                      |                               |
  //    1    1     |   1    1    1  |   1    1     1   1   |  1    1     1     1     0   1  |  1     1     1     x     1    0   1  |  1    1    1     1     1   1  |
  //                                                       |  2    0     x     1     x   1  |  2     0     x     1     1    x   1  |
  //                                                       |  2    1     x     1     1   1  |  2     1     1     x     1    0   1  |
  //                                                                                        |  2     1     x     1     1    1   1  |

  assign iq_head_entry1_nostall_en_ctrl[11:0] = {iq_holding0[D1],               // [   11] IQ holding entry-0 dual issue
                                                 iq_holding_valid[1:0],         // [10: 9] IQ holding entry-1/0 is valid
                                                 iq_body1[D1],                  // [    8] IQ body1 dual issue
                                                 iq_body0[D1],                  // [    7] IQ body0 dual issue
                                                 iq_body_status_one_instr,      // [    6] IQ body has one instruction to supply
                                                 iq_body_status_empty,          // [    5] IQ body is empty
                                                 iq_head_valid[1:0],            // [ 4: 3] IQ head entry1/0 is valid
                                                 iq_might_push_two,             // [    2] IFU is pushing at least one instruction
                                                 finish_instr_de_i,             // [    1] Instruction has finished with decode
                                                 can_dual_issue};               // [    0] Dual-issue possible

//  always @*
//    casez (iq_head_entry1_nostall_en_ctrl[11:0])
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Head Entry[0] = 0
//      12'b?_??_??_??_?0_1_?_? : iq_head_entry1_nostall_raw_en = 1'b1;
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Head Entry[0] = 1
//      12'b?_?0_??_?1_01_1_1_? : iq_head_entry1_nostall_raw_en = 1'b1;
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Head Entry[1] = 1
//      12'b?_?0_??_?1_1?_1_1_1 : iq_head_entry1_nostall_raw_en = 1'b1;
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Holding Valid
//      12'b1_01_??_?1_1?_?_1_0 : iq_head_entry1_nostall_raw_en = 1'b1;
//      12'b?_1?_??_?1_0?_?_1_? : iq_head_entry1_nostall_raw_en = 1'b1;
//      12'b?_1?_??_?1_1?_?_1_1 : iq_head_entry1_nostall_raw_en = 1'b1;
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Body Valid
//      12'b?_??_?1_10_1?_?_1_? : iq_head_entry1_nostall_raw_en = 1'b1;
//      12'b?_??_1?_00_0?_?_1_? : iq_head_entry1_nostall_raw_en = 1'b1;
//      12'b?_??_?1_00_1?_?_1_0 : iq_head_entry1_nostall_raw_en = 1'b1;
//      12'b?_??_1?_00_1?_?_1_1 : iq_head_entry1_nostall_raw_en = 1'b1;
//      //  1 1
//      //  1 09 87 65 43 2 1 0 - Body = 1, Hold = 1
//      12'b1_01_??_1?_??_?_1_1 : iq_head_entry1_nostall_raw_en = 1'b1;
//      default                 : iq_head_entry1_nostall_raw_en = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_8_1, net_8_2, net_8_3, net_8_4, net_8_5, net_8_6, net_8_7, net_8_8, net_8_9, net_8_10,
         net_8_11, net_8_12, net_8_13, net_8_14, net_8_15, net_8_16, net_8_17, net_8_18,
         net_8_19, net_8_20, net_8_21, net_8_22, net_8_23, net_8_24, net_8_25;

  assign net_8_1 = ~iq_head_entry1_nostall_en_ctrl[2];
  assign net_8_2 = ~iq_head_entry1_nostall_en_ctrl[0];
  assign iq_head_entry1_nostall_raw_en = (net_8_3 | net_8_4);
  assign net_8_4 = ~(iq_head_entry1_nostall_en_ctrl[3] | net_8_1);
  assign net_8_3 = (iq_head_entry1_nostall_en_ctrl[1] & net_8_5);
  assign net_8_5 = (net_8_6 | net_8_7);
  assign net_8_7 = ~(iq_head_entry1_nostall_en_ctrl[10] | net_8_8);
  assign net_8_8 = ~(iq_head_entry1_nostall_en_ctrl[9] & net_8_9);
  assign net_8_9 = (iq_head_entry1_nostall_en_ctrl[11] & net_8_10);
  assign net_8_10 = (net_8_11 | net_8_12);
  assign net_8_12 = (iq_head_entry1_nostall_en_ctrl[6] & iq_head_entry1_nostall_en_ctrl[0]);
  assign net_8_11 = ~(iq_head_entry1_nostall_en_ctrl[0] | net_8_13);
  assign net_8_13 = ~(iq_head_entry1_nostall_en_ctrl[5] & iq_head_entry1_nostall_en_ctrl[4]);
  assign net_8_6 = ~(net_8_14 & net_8_15);
  assign net_8_15 = ~(net_8_16 & net_8_17);
  assign net_8_17 = ~(iq_head_entry1_nostall_en_ctrl[4] & net_8_2);
  assign net_8_16 = (net_8_18 | net_8_19);
  assign net_8_19 = (iq_head_entry1_nostall_en_ctrl[5] & net_8_20);
  assign net_8_20 = (iq_head_entry1_nostall_en_ctrl[10] | net_8_21);
  assign net_8_21 = ~(net_8_1 | iq_head_entry1_nostall_en_ctrl[9]);
  assign net_8_18 = (iq_head_entry1_nostall_en_ctrl[8] & net_8_22);
  assign net_8_22 = ~(iq_head_entry1_nostall_en_ctrl[5] | iq_head_entry1_nostall_en_ctrl[6]);
  assign net_8_14 = ~(iq_head_entry1_nostall_en_ctrl[4] & net_8_23);
  assign net_8_23 = ~(iq_head_entry1_nostall_en_ctrl[5] | net_8_24);
  assign net_8_24 = ~(iq_head_entry1_nostall_en_ctrl[7] & net_8_25);
  assign net_8_25 = (net_8_2 | iq_head_entry1_nostall_en_ctrl[6]);

// End automatically generated logic

  assign iq_head_entry1_nostall_en    = {IQ_HEAD_ENTRY1_EN_W{iq_head_entry1_nostall_raw_en}} &
                                        (({IQ_HEAD_ENTRY1_EN_W{sel_iq_instr1[4]}} & instr1_class_ifu1)      |
                                         ({IQ_HEAD_ENTRY1_EN_W{sel_iq_instr1[3]}} & instr1_class_holding1)  |
                                         ({IQ_HEAD_ENTRY1_EN_W{sel_iq_instr1[2]}} & instr1_class_holding0)  |
                                         ({IQ_HEAD_ENTRY1_EN_W{sel_iq_instr1[1]}} & instr1_class_body1)     |
                                         ({IQ_HEAD_ENTRY1_EN_W{sel_iq_instr1[0]}} & instr1_class_body0));


  // IQ head entry-1 enable assuming a stall (note that iq_push[1] is too late)
  assign iq_head_entry1_stall_raw_en  = iq_might_push_two & ~iq_head_valid[0];

  assign iq_head_entry1_stall_en      = {IQ_HEAD_ENTRY1_EN_W{iq_head_entry1_stall_raw_en}} & instr1_class_ifu1;

  // IQ head entry-1 enable resolution
  assign iq_head_entry1_en = stall_de_i ? iq_head_entry1_stall_en : iq_head_entry1_nostall_en;

  // ------------------------------------------------------
  // IQ head entry-1 valid
  // ------------------------------------------------------
  //
  // Last Head     |     Last Head         |   Last Head      |        Holding Valid        |            Body Valid             |      Body    = 1 only     |
  // Entry [0] = 0 |     Entry [0] = 1     |   Entry [1] = 1  |        Body Empty           |                                   |      Holding = 1 only     |
  //               |                       |                  |                             |                                   |                           |
  //               |                       |                  |                  Last       |                  Last  Last       |                Last       |
  //  Last         |  Last Last Last       |  Last Last       |  Last Last Last  Hold0      |  Last Last Last  Body0 Body1      | Last Last Last Hold0      |
  //  Push  Valid  |  Push Hold Pop Valid  |  Push Pop Valid  |  Hold Pop  Head1  D1  Valid |  Body Pop  Head1  D1    D1  Valid | Hold Body Pop   D1  Valid |
  //               |                       |                  |                             |                                   |                           |
  //   2      1    |   2    0    1    1    |   0    0    1    |   1    0     0     x    0   |   1    0     0     x     x    0   |  1    1    2     1    1   |
  //                                       |   0    1    0    |   1    0     1     x    1   |   1    0     1     x     x    1   |
  //                                       |   0    2    0    |   1    1     0     x    0   |   1    1     0     x     x    0   |
  //                                       |   1    0    1    |   1    1     1     0    0   |   1    1     1     0     x    0   |
  //                                       |   1    1    0    |   1    1     1     1    1   |   1    1     1     1     x    1   |
  //                                       |   1    2    0    |   1    2     x     x    0   |   1    2     x     x     x    0   |
  //                                       |   2    0    1    |   2    0     0     x    0   |   2    0     0     x     x    0   |
  //                                       |   2    1    0    |   2    0     1     x    1   |   2    0     1     x     x    1   |
  //                                       |   2    2    1    |   2    1     0     x    1   |   2    1     0     x     0    0   |
  //                                                          |   2    1     1     x    0   |   2    1     0     x     1    1   |
  //                                                          |   2    2     x     x    1   |   2    1     1     0     x    0   |
  //                                                                                        |   2    1     1     1     x    1   |
  //                                                                                        |   2    2     x     x     0    0   |
  //                                                                                        |   2    2     x     x     1    1   |

  assign iq_head_valid1_ctrl[12:0] = {last_flush,                    // [   12]
                                      last_iq_holding_instr0_d1,     // [   11]
                                      last_iq_holding_valid[1:0],    // [10: 9]
                                      last_iq_body_instr1_d1,        // [    8]
                                      last_iq_body_instr0_d1,        // [    7]
                                      last_iq_body_status_one_instr, // [    6]
                                      last_iq_body_status_empty,     // [    5]
                                      last_iq_head_valid[1:0],       // [ 4: 3]
                                      last_pop[1:0],                 // [ 2: 1]
                                      last_push[1]};                 // [    0]

//  always @*
//    casez (iq_head_valid1_ctrl[12:0])
//      //  1 1 1
//      //  2 1_09 87 65 43 21 0 - Head Entry[0] = 0
//      13'b0_?_??_??_??_?0_??_1 : iq_head_valid[1] = 1'b1;
//      //  1 1 1
//      //  2 1 09 87 65 43 21 0 - Head Entry[0] = 1
//      13'b0_?_?0_??_?1_01_?1_1 : iq_head_valid[1] = 1'b1;
//      //  1 1 1
//      //  2 1 09 87 65 43 21 0 - Head Entry[1] = 1
//      13'b0_?_?0_??_?1_1?_?0_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_?0_??_?1_1?_1?_1 : iq_head_valid[1] = 1'b1;
//      //  1 1 1
//      //  2 1 09 87 65 43 21 0 - Holding Valid
//      13'b0_?_01_??_?1_1?_?0_? : iq_head_valid[1] = 1'b1;
//      13'b0_1_01_??_?1_1?_01_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_1?_??_?1_1?_?0_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_1?_??_?1_0?_01_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_1?_??_?1_??_1?_? : iq_head_valid[1] = 1'b1;
//      //  1 1 1
//      //  2 1 09 87 65 43 21 0 - Body Valid
//      13'b0_?_??_??_1?_1?_?0_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_??_?1_1?_1?_01_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_??_??_00_1?_?0_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_??_1?_00_0?_01_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_??_?1_00_1?_01_? : iq_head_valid[1] = 1'b1;
//      13'b0_?_??_1?_00_??_1?_? : iq_head_valid[1] = 1'b1;
//      //  1 1 1
//      //  2 1 09 87 65 43 21 0 - Body = 1, Hold = 1
//      13'b0_1_01_??_10_??_1?_? : iq_head_valid[1] = 1'b1;
//      default                  : iq_head_valid[1] = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_9_1, net_9_2, net_9_3, net_9_4, net_9_5, net_9_6, net_9_7, net_9_8, net_9_9, net_9_10,
         net_9_11, net_9_12, net_9_13, net_9_14, net_9_15, net_9_16, net_9_17, net_9_18,
         net_9_19, net_9_20, net_9_21, net_9_22, net_9_23, net_9_24, net_9_25, net_9_26,
         net_9_27, net_9_28, net_9_29, net_9_30;

  assign net_9_1 = ~iq_head_valid1_ctrl[6];
  assign net_9_2 = ~iq_head_valid1_ctrl[4];
  assign iq_head_valid[1] = ~(iq_head_valid1_ctrl[12] | net_9_3);
  assign net_9_3 = (net_9_4 & net_9_5);
  assign net_9_5 = (net_9_6 | net_9_7);
  assign net_9_6 = (net_9_8 & net_9_9);
  assign net_9_9 = ~(iq_head_valid1_ctrl[7] & net_9_10);
  assign net_9_10 = ~(net_9_1 & iq_head_valid1_ctrl[5]);
  assign net_9_8 = ~(net_9_11 & iq_head_valid1_ctrl[5]);
  assign net_9_4 = (net_9_12 & net_9_13);
  assign net_9_13 = (iq_head_valid1_ctrl[1] | net_9_2);
  assign net_9_12 = (net_9_14 & net_9_15);
  assign net_9_15 = ~(iq_head_valid1_ctrl[0] & net_9_16);
  assign net_9_16 = ~(iq_head_valid1_ctrl[3] & net_9_17);
  assign net_9_17 = (iq_head_valid1_ctrl[9] | net_9_18);
  assign net_9_18 = ~(iq_head_valid1_ctrl[5] & net_9_19);
  assign net_9_19 = (iq_head_valid1_ctrl[1] & net_9_7);
  assign net_9_7 = (net_9_2 | iq_head_valid1_ctrl[2]);
  assign net_9_14 = (net_9_20 & net_9_21);
  assign net_9_21 = (net_9_22 | iq_head_valid1_ctrl[5]);
  assign net_9_22 = ~(iq_head_valid1_ctrl[6] & net_9_23);
  assign net_9_23 = (iq_head_valid1_ctrl[2] & net_9_11);
  assign net_9_11 = ~(iq_head_valid1_ctrl[10] | net_9_24);
  assign net_9_24 = ~(iq_head_valid1_ctrl[9] & iq_head_valid1_ctrl[11]);
  assign net_9_20 = ~(net_9_25 & net_9_26);
  assign net_9_26 = ~(net_9_27 & net_9_28);
  assign net_9_28 = ~(iq_head_valid1_ctrl[8] & net_9_29);
  assign net_9_29 = ~(iq_head_valid1_ctrl[5] | iq_head_valid1_ctrl[6]);
  assign net_9_27 = ~(iq_head_valid1_ctrl[5] & iq_head_valid1_ctrl[10]);
  assign net_9_25 = (iq_head_valid1_ctrl[2] | net_9_30);
  assign net_9_30 = (iq_head_valid1_ctrl[1] & net_9_2);

// End automatically generated logic

  // ------------------------------------------------------
  // IQ head entry-1 data selection
  // ------------------------------------------------------
  //
  // Valid               Can   Source
  //                  Dual-Issue
  //
  // head[0]=0            x    ifu_instr1
  //
  // head[0]=1            1    ifu_instr1
  //
  // head[1]=1            1    Don't Care
  // head[1]=1            2    ifu_instr1
  //
  // Holding[1:0]=1       1    Holding[0] (note that this is only used for head[1]=1, Hold0-D1=1, the other cases are Don't Care)
  // Holding[1:0]=1       2    Don't Care
  //
  // Holding[1:0]=2       1    Holding[1]
  // Holding[1:0]=2       2    Holding[1]
  //
  // Body=1+              1    Body[0] if head[1]=1, Body[1] if head[1]=0
  // Body=1+              2    Body[1] Unless...
  // Body=1, Holding=1    2    Holding[0] (note that this is only used for hold0-D1=1, the other cases are don't care)

  assign sel_iq_instr1_ctrl[5:0] = {iq_holding_valid[1:0],    // [5:4]
                                    iq_body_status_one_instr, // [  3]
                                    iq_body_status_empty,     // [  2]
                                    iq_head_valid[1],         // [  1] IQ head entry-1 is valid
                                    can_dual_issue};          // [  0]

//  always @*
//    casez (sel_iq_instr1_ctrl[5:0])
//      // 43 21 1 0 - Body 0
//      6'b??_?0_1_0 : sel_iq_instr1_nodih[4:0] = 5'b00001;
//      // 43 21 1 0 - Body 1
//      6'b??_00_0_? : sel_iq_instr1_nodih[4:0] = 5'b00010;
//      6'b??_00_?_1 : sel_iq_instr1_nodih[4:0] = 5'b00010;
//      // 43 21 1 0 - Holding 0
//      6'b01_?1_?_? : sel_iq_instr1_nodih[4:0] = 5'b00100;
//      6'b01_1?_?_1 : sel_iq_instr1_nodih[4:0] = 5'b00100;
//      // 43 21 1 0 - Holding 1
//      6'b1?_?1_?_? : sel_iq_instr1_nodih[4:0] = 5'b01000;
//      // Default   - IFU
//      default      : sel_iq_instr1_nodih[4:0] = 5'b10000;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_10_1, net_10_2, net_10_3, net_10_4, net_10_5, net_10_6, net_10_7, net_10_8, net_10_9, net_10_10,
         net_10_11, net_10_12, net_10_13, net_10_14, net_10_15;

  assign net_10_1 = ~sel_iq_instr1_ctrl[5];
  assign net_10_2 = ~sel_iq_instr1_ctrl[0];
  assign sel_iq_instr1_nodih[4] = (net_10_3 | net_10_4);
  assign net_10_4 = ~(sel_iq_instr1_ctrl[2] | net_10_5);
  assign net_10_5 = ~(sel_iq_instr1_ctrl[3] & net_10_6);
  assign net_10_6 = (net_10_7 | net_10_8);
  assign net_10_8 = ~(sel_iq_instr1_ctrl[0] | sel_iq_instr1_ctrl[1]);
  assign net_10_7 = (sel_iq_instr1_ctrl[0] & net_10_9);
  assign net_10_9 = ~(sel_iq_instr1_ctrl[4] & net_10_1);
  assign net_10_3 = (sel_iq_instr1_ctrl[2] & net_10_10);
  assign net_10_10 = ~(sel_iq_instr1_ctrl[5] | sel_iq_instr1_ctrl[4]);
  assign sel_iq_instr1_nodih[3] = (sel_iq_instr1_ctrl[5] & sel_iq_instr1_ctrl[2]);
  assign sel_iq_instr1_nodih[2] = (net_10_11 & net_10_1);
  assign net_10_11 = (sel_iq_instr1_ctrl[4] & net_10_12);
  assign net_10_12 = (sel_iq_instr1_ctrl[2] | net_10_13);
  assign net_10_13 = (sel_iq_instr1_ctrl[3] & sel_iq_instr1_ctrl[0]);
  assign sel_iq_instr1_nodih[1] = (net_10_14 & net_10_15);
  assign net_10_14 = ~(sel_iq_instr1_ctrl[2] | sel_iq_instr1_ctrl[3]);
  assign sel_iq_instr1_nodih[0] = ~(sel_iq_instr1_ctrl[2] | net_10_15);
  assign net_10_15 = ~(sel_iq_instr1_ctrl[1] & net_10_2);

// End automatically generated logic

//  always @*
//    casez (sel_iq_instr1_ctrl[5:0])
//      // 43 21 1 0 - Body 0
//      6'b??_?0_1_? : sel_iq_instr1_dih[4:0] = 5'b00001;
//      // 43 21 1 0 - Body 1
//      6'b??_00_0_? : sel_iq_instr1_dih[4:0] = 5'b00010;
//      // 43 21 1 0 - Holding 0
//      6'b01_?1_?_? : sel_iq_instr1_dih[4:0] = 5'b00100;
//      // 43 21 1 0 - Holding 1
//      6'b1?_?1_?_? : sel_iq_instr1_dih[4:0] = 5'b01000;
//      // Default   - IFU
//      default      : sel_iq_instr1_dih[4:0] = 5'b10000;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_11_1, net_11_2, net_11_3, net_11_4, net_11_5, net_11_6, net_11_7;

  assign net_11_1 = ~net_11_7;
  assign net_11_2 = ~sel_iq_instr1_ctrl[3];
  assign net_11_3 = ~sel_iq_instr1_ctrl[2];
  assign sel_iq_instr1_dih[4] = ~(net_11_4 & net_11_5);
  assign net_11_5 = (net_11_2 | net_11_6);
  assign net_11_4 = (net_11_1 | sel_iq_instr1_ctrl[4]);
  assign sel_iq_instr1_dih[3] = (sel_iq_instr1_ctrl[2] & sel_iq_instr1_ctrl[5]);
  assign sel_iq_instr1_dih[2] = (sel_iq_instr1_ctrl[4] & net_11_7);
  assign net_11_7 = ~(sel_iq_instr1_ctrl[5] | net_11_3);
  assign sel_iq_instr1_dih[1] = ~(net_11_6 | sel_iq_instr1_ctrl[3]);
  assign net_11_6 = (sel_iq_instr1_ctrl[2] | sel_iq_instr1_ctrl[1]);
  assign sel_iq_instr1_dih[0] = (sel_iq_instr1_ctrl[1] & net_11_3);

// End automatically generated logic

  assign sel_iq_instr1 = iq_instr1_dih ? sel_iq_instr1_dih : sel_iq_instr1_nodih;

  assign nxt_iq_instr1[47:0] = (({48{sel_iq_instr1[4]}} & ifu_instr1_if3_i[47:0]) | // IFU instruction-1
                                ({48{sel_iq_instr1[3]}} & iq_holding1[47:0])      | // IQ holiding instruction-1
                                ({48{sel_iq_instr1[2]}} & iq_holding0[47:0])      | // IQ holiding instruction-0
                                ({48{sel_iq_instr1[1]}} & iq_body1[47:0])         | // IQ body instruction-1
                                ({48{sel_iq_instr1[0]}} & iq_body0[47:0]));         // IQ body instruction-0

  // ------------------------------------------------------
  // IQ head entry-1 registers
  // ------------------------------------------------------

  always @(posedge clk)
    if (iq_head_entry1_en[0]) begin
      iq_instr1_common_de[47:0]   <= nxt_iq_instr1[47:0];
      iq_instr1_common_aarch64_de <= aarch64_state_i;
    end

  // AArch64 version for DIH control (not decode)
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      iq_instr1_ctl_aarch64_de <= 1'b0;
    else if (iq_head_entry1_en[0])
      iq_instr1_ctl_aarch64_de <= aarch64_state_i;

  // DP/Other (main) Instruction registers
  always @(posedge clk)
    if (iq_head_entry1_en[1]) begin
      iq_instr1_main_de[32:0]     <= nxt_iq_instr1[32:0];
      iq_instr1_main_aarch64_de   <= aarch64_state_i;
    end

  // LS Instruction registers
  always @(posedge clk)
    if (iq_head_entry1_en[2]) begin
      iq_instr1_ls_de[32:0]       <= nxt_iq_instr1[32:0];
      iq_instr1_ls_aarch64_de     <= aarch64_state_i;
    end

  generate if (NEON_FP) begin : g_instr1_fn_neon
    // FPU/Neon registers
    reg [32:0] iq_instr1_fn_de_reg;
    reg [29:0] iq_instr1_fn_dih_de_reg;
    reg        iq_instr1_fn_dih_pdtype0_de_reg;
    reg        iq_instr1_fn_aarch64_de_reg;
    reg        iq_instr1_fn_dih_aarch64_de_reg;
    wire       iq_instr1_fn_dih_en;

    always @(posedge clk)
      if (iq_head_entry1_en[3]) begin
        iq_instr1_fn_de_reg[32:0]       <= nxt_iq_instr1[32:0];
        iq_instr1_fn_aarch64_de_reg     <= aarch64_state_i;
      end

    // Only enable DIH head registers if dual issuable
    assign iq_instr1_fn_dih_en = iq_head_entry1_en[3] & nxt_iq_instr1[D1];

    always @(posedge clk)
      if (iq_instr1_fn_dih_en) begin
        iq_instr1_fn_dih_de_reg[29:0]   <= nxt_iq_instr1[29:0];
        iq_instr1_fn_dih_pdtype0_de_reg <= nxt_iq_instr1[35];
        iq_instr1_fn_dih_aarch64_de_reg <= aarch64_state_i;
      end

    assign iq_instr1_fn_de              = iq_instr1_fn_de_reg;
    assign iq_instr1_fn_aarch64_de      = iq_instr1_fn_aarch64_de_reg;
    assign iq_instr1_fn_dih_de          = iq_instr1_fn_dih_de_reg;
    assign iq_instr1_fn_dih_pdtype0_de  = iq_instr1_fn_dih_pdtype0_de_reg;
    assign iq_instr1_fn_dih_aarch64_de  = iq_instr1_fn_dih_aarch64_de_reg;

  end else begin : g_instr1_fn_no_neon

    assign iq_instr1_fn_de              = {33{1'b0}};
    assign iq_instr1_fn_aarch64_de      = 1'b0;
    assign iq_instr1_fn_dih_de          = {30{1'b0}};
    assign iq_instr1_fn_dih_pdtype0_de  = 1'b0;
    assign iq_instr1_fn_dih_aarch64_de  = 1'b0;

  end endgenerate

  // ------------------------------------------------------
  // IQ head entry-0 instruction class
  // ------------------------------------------------------
  //
  // Extract DP, LS, OT or FN instruction class from possible sources taking into account
  // the RTL configuration

  generate if (NEON_FP) begin : NEON_AND_FPU_0
    assign instr0_class_ifu0[4:0]        = {ifu_instr0_if3_i[FN],    ifu_instr0_if3_i[OT],                                 ifu_instr0_if3_i[LS],     ifu_instr0_if3_i[DP],     1'b1};
    assign instr0_class_iq_entry1[4:0]   = {iq_instr1_common_de[FN], iq_instr1_common_de[OT],                              iq_instr1_common_de[LS],  iq_instr1_common_de[DP],  1'b1};
    assign instr0_class_iq_body0[4:0]    = {iq_body0[FN],            iq_body0[OT],                                         iq_body0[LS],             iq_body0[DP],             1'b1};
    assign instr0_class_iq_holding0[4:0] = {iq_holding0[FN],         iq_holding0[OT],                                      iq_holding0[LS],          iq_holding0[DP],          1'b1};
  end else begin : NO_NEON_AND_FPU_0
    assign instr0_class_ifu0[3:0]        = {                         (ifu_instr0_if3_i[OT]     | ifu_instr0_if3_i[FN]),    ifu_instr0_if3_i[LS],     ifu_instr0_if3_i[DP],     1'b1};
    assign instr0_class_iq_entry1[3:0]   = {                         (iq_instr1_common_de[OT]  | iq_instr1_common_de[FN]), iq_instr1_common_de[LS],  iq_instr1_common_de[DP],  1'b1};
    assign instr0_class_iq_body0[3:0]    = {                         (iq_body0[OT]             | iq_body0[FN]),            iq_body0[LS],             iq_body0[DP],             1'b1};
    assign instr0_class_iq_holding0[3:0] = {                         (iq_holding0[OT]          | iq_holding0[FN]),         iq_holding0[LS],          iq_holding0[DP],          1'b1};
  end endgenerate

  // ------------------------------------------------------
  // IQ head entry-0 enable
  // ------------------------------------------------------

  assign iq_head_entry0_nostall_en_ctrl[6:0] = {iq_holding_valid[0],  // [6] IQ holding entry-0 is valid
                                                iq_body_status_empty, // [5] IQ body is empty
                                                iq_head_valid[1],     // [4] IQ head entry-1 is valid
                                                iq_head_valid[0],     // [3] IQ head entry-0 is valid
                                                iq_push[0],           // [2] IFU is pushing at least one instruction
                                                finish_instr_de_i,    // [1] Instruction has finished with decode
                                                can_dual_issue};      // [0] Dual-issue possible

//  always @*
//    case (iq_head_entry0_nostall_en_ctrl[6:0])
//      // 6 5 43 2 1 0 - Head entry empty, IFU pushing
//      7'b0_1_?0_1_?_? : iq_head_entry0_nostall_en = instr0_class_ifu0;
//      // 6 5 43 2 1 0 - Head entry-0 valid, decode finished, IFU pushing
//      7'b0_1_01_1_1_? : iq_head_entry0_nostall_en = instr0_class_ifu0;
//      // 6 5 43 2 1 0 - Head entry-1 valid, decode finished, IFU pushing, can dual-issue
//      7'b0_1_11_1_1_1 : iq_head_entry0_nostall_en = instr0_class_ifu0;
//      // 6 5 43 2 1 0 - Head entry-1 valid, decode finished, not dual-issue
//      7'b?_?_11_?_1_0 : iq_head_entry0_nostall_en = instr0_class_iq_entry1;
//      // 6 5 43 2 1 0 - IQ body valid, decode finished
//      7'b?_0_??_?_1_? : iq_head_entry0_nostall_en = instr0_class_iq_body0;
//      // 6 5 43 2 1 0 - IQ holding valid, body invalid, decode finished
//      7'b1_1_??_?_1_1 : iq_head_entry0_nostall_en = instr0_class_iq_holding0;
//      7'b1_1_0?_?_1_? : iq_head_entry0_nostall_en = instr0_class_iq_holding0;
//      default         : iq_head_entry0_nostall_en = {IQ_HEAD_ENTRY0_EN_W{1'b0}};
//    endcase

  assign iq_head_entry0_nostall_en = (({IQ_HEAD_ENTRY0_EN_W{({iq_head_entry0_nostall_en_ctrl[6],
                                                              iq_head_entry0_nostall_en_ctrl[5],
                                                              iq_head_entry0_nostall_en_ctrl[3],
                                                              iq_head_entry0_nostall_en_ctrl[2]}  == 4'b0101   )}} & instr0_class_ifu0) |
                                      ({IQ_HEAD_ENTRY0_EN_W{( iq_head_entry0_nostall_en_ctrl[6:1] == 6'b010111 )}} & instr0_class_ifu0) |
                                      ({IQ_HEAD_ENTRY0_EN_W{( iq_head_entry0_nostall_en_ctrl[6:0] == 7'b0111111)}} & instr0_class_ifu0) |
                                      ({IQ_HEAD_ENTRY0_EN_W{({iq_head_entry0_nostall_en_ctrl[4],
                                                              iq_head_entry0_nostall_en_ctrl[3],
                                                              iq_head_entry0_nostall_en_ctrl[1],
                                                              iq_head_entry0_nostall_en_ctrl[0]}  == 4'b1110   )}} & instr0_class_iq_entry1) |
                                      ({IQ_HEAD_ENTRY0_EN_W{({iq_head_entry0_nostall_en_ctrl[5],
                                                              iq_head_entry0_nostall_en_ctrl[1]}  == 2'b01     )}} & instr0_class_iq_body0) |
                                      ({IQ_HEAD_ENTRY0_EN_W{({iq_head_entry0_nostall_en_ctrl[6],
                                                              iq_head_entry0_nostall_en_ctrl[5],
                                                              iq_head_entry0_nostall_en_ctrl[1],
                                                              iq_head_entry0_nostall_en_ctrl[0]}  == 4'b1111   )}} & instr0_class_iq_holding0) |
                                      ({IQ_HEAD_ENTRY0_EN_W{({iq_head_entry0_nostall_en_ctrl[6],
                                                              iq_head_entry0_nostall_en_ctrl[5],
                                                              iq_head_entry0_nostall_en_ctrl[4],
                                                              iq_head_entry0_nostall_en_ctrl[1]}  == 4'b1101   )}} & instr0_class_iq_holding0));

  // IQ head entry-0 enable assuming a stall
  assign iq_head_entry0_stall_raw_en = ~iq_head_valid[0] & iq_push[0];

  generate if (NEON_FP) begin : NEON_AND_FPU_1
    assign iq_head_entry0_stall_en[4:0] = {(iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[FN]),
                                           (iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[OT]),
                                           (iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[LS]),
                                           (iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[DP]),
                                           (iq_head_entry0_stall_raw_en)};
  end else begin : NO_NEON_AND_FPU_1
    assign iq_head_entry0_stall_en[3:0] = {(iq_head_entry0_stall_raw_en & (ifu_instr0_if3_i[OT] | ifu_instr0_if3_i[FN])),
                                           (iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[LS]),
                                           (iq_head_entry0_stall_raw_en &  ifu_instr0_if3_i[DP]),
                                           (iq_head_entry0_stall_raw_en)};
  end endgenerate

  // IQ head entry-0 enable resolution
  assign iq_head_entry0_en = stall_de_i ? iq_head_entry0_stall_en : iq_head_entry0_nostall_en;

  // ------------------------------------------------------
  // IQ head entry-0 valid
  // ------------------------------------------------------
  //
  // Head Entry[0] = 0 | Head Entry [0] = 1 | Head Entry [1] = 1 | Holding / Body = 1+
  //                   |                    |                    |
  //  last  last       |  last  last        |  last  last        |  last  last
  //  push  pop  valid |  push  pop  valid  |  push  pop  valid  |  push  pop  valid
  //                   |                    |                    |
  //   0    n/a    0   |   0     0     1    |   0     0     1    |  n/a   n/a    1
  //   1    n/a    1   |   0     1     0    |   0     1     1    |
  //   2    n/a    1   |   1     0     1    |   0     2     0    |
  //                   |   1     1     1    |   1     0     1    |
  //                   |   2     0     1    |   1     1     1    |
  //                   |   2     1     1    |   1     2     1    |
  //                                        |   2     0     1    |
  //                                        |   2     1     1    |
  //                                        |   2     2     1    |

  assign iq_head_valid0_ctrl[7:0] = {last_flush,                // [  7]
                                     last_iq_holding_valid[0],  // [  6]
                                     last_iq_body_status_empty, // [  5]
                                     last_iq_head_valid[1:0],   // [4:3]
                                     last_pop[1],               // [  2]
                                     last_pop[0],               // [  1]
                                     last_push[0]};             // [  0]

//  always @*
//    casez (iq_head_valid0_ctrl[7:0])
//      // 7 6 5 43 21 0 - Head Entry[0] = 0
//      8'b0_?_?_??_??_1 : iq_head_valid[0] = 1'b1;
//      // 7 6 5 43 21 0 - Head Entry[0] = 1
//      8'b0_?_?_?1_?0_0 : iq_head_valid[0] = 1'b1;
//      // 7 6 5 43 21 0 - Head Entry[1] = 1
//      8'b0_?_?_1?_0?_? : iq_head_valid[0] = 1'b1;
//      // 7 6 5 43 21 0 - Body or Holding
//      8'b0_?_0_??_??_? : iq_head_valid[0] = 1'b1;
//      8'b0_1_?_??_??_? : iq_head_valid[0] = 1'b1;
//      default          : iq_head_valid[0] = 1'b0;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_12_1, net_12_2, net_12_3, net_12_4, net_12_5, net_12_6, net_12_7, net_12_8;

  assign net_12_1 = ~iq_head_valid0_ctrl[4];
  assign iq_head_valid[0] = ~(net_12_2 & net_12_3);
  assign net_12_3 = (iq_head_valid0_ctrl[7] | net_12_4);
  assign net_12_4 = (iq_head_valid0_ctrl[5] & net_12_5);
  assign net_12_5 = (net_12_6 & net_12_7);
  assign net_12_7 = (net_12_1 | iq_head_valid0_ctrl[2]);
  assign net_12_6 = ~(iq_head_valid0_ctrl[0] | iq_head_valid0_ctrl[6]);
  assign net_12_2 = ~(iq_head_valid0_ctrl[3] & net_12_8);
  assign net_12_8 = ~(iq_head_valid0_ctrl[7] | iq_head_valid0_ctrl[1]);

// End automatically generated logic

  // ------------------------------------------------------
  // IQ head entry-0 data selection
  // ------------------------------------------------------
  //
  // The next data source for the IQ entry 0 registers depends on the number of valid
  // registers already in the instruction registers/fifo and the number of instructions that
  // are going to pop from the instruction registers/fifo in this cycle.
  //
  // valid             iq_pop  source
  // [x:0]              [1:0]
  //
  // head[0]=0            x    ifu_instr0
  //
  // head[0]=1            1    ifu_instr0
  //
  // head[1]=1            1    head[1]
  // head[1]=1            2    ifu_instr0
  //
  // body=1               1    body0 if head[1]=0, head[1] if head[1]=1
  // body=1               2    body0 if head[1]=0, head[1] if head[1]=1
  //
  // body=0, holding=1    0    n/a (hold)
  // body=0, holding=1    1    holding0 if head[1]=0, head[1] if head[1]=1
  // body=0, holding=1    2    holding0 if head[1]=0, head[1] if head[1]=1

  assign sel_iq_instr0_ctrl[3:0] = {iq_holding_valid[0],        // [3]
                                    iq_body_status_empty,       // [2]
                                    iq_head_valid[1],           // [1]
                                    can_dual_issue_if_no_dih};  // [0]

//  always @*
//    casez (sel_iq_instr0_ctrl[3:0])
//      // 3 2 1 0 - IQ Head Entry 1
//      4'b?_?_1_0 : sel_iq_instr0_nodih[3:0] = 4'b0001;
//      // 3 2 1 0 - Body
//      4'b?_0_0_? : sel_iq_instr0_nodih[3:0] = 4'b0010;
//      4'b?_0_?_1 : sel_iq_instr0_nodih[3:0] = 4'b0010;
//      // 3 2 1 0 - Holding
//      4'b1_1_0_? : sel_iq_instr0_nodih[3:0] = 4'b0100;
//      4'b1_1_?_1 : sel_iq_instr0_nodih[3:0] = 4'b0100;
//      // Default - IFU
//      default    : sel_iq_instr0_nodih[3:0] = 4'b1000;
//    endcase
// Automatically generated netlist to implement casez function:

  wire   net_13_1, net_13_2, net_13_3, net_13_4;

  assign net_13_1 = ~sel_iq_instr0_ctrl[3];
  assign net_13_2 = ~sel_iq_instr0_nodih[0];
  assign net_13_3 = ~sel_iq_instr0_ctrl[0];
  assign sel_iq_instr0_nodih[3] = (net_13_4 & net_13_1);
  assign sel_iq_instr0_nodih[2] = (sel_iq_instr0_ctrl[3] & net_13_4);
  assign net_13_4 = (sel_iq_instr0_ctrl[2] & net_13_2);
  assign sel_iq_instr0_nodih[1] = ~(sel_iq_instr0_nodih[0] | sel_iq_instr0_ctrl[2]);
  assign sel_iq_instr0_nodih[0] = (sel_iq_instr0_ctrl[1] & net_13_3);

// End automatically generated logic

//  always @*
//    casez (sel_iq_instr0_ctrl[3:0])
//      // 3 2 1 0 - IQ Head Entry 1
//      4'b?_?_1_? : sel_iq_instr0_dih[3:0] = 4'b0001;
//      // 3 2 1 0 - Body
//      4'b?_0_0_? : sel_iq_instr0_dih[3:0] = 4'b0010;
//      // 3 2 1 0 - Holding
//      4'b1_1_0_? : sel_iq_instr0_dih[3:0] = 4'b0100;
//      // Default - IFU
//      default    : sel_iq_instr0_dih[3:0] = 4'b1000;
//    endcase
// Automatically generated netlist to implement casez function:

  wire    net_14_1, net_14_2, net_14_3;

  assign sel_iq_instr0_dih[0] = sel_iq_instr0_ctrl[1];
  assign net_14_1 = ~sel_iq_instr0_ctrl[3];
  assign net_14_2 = ~sel_iq_instr0_dih[0];
  assign sel_iq_instr0_dih[3] = (net_14_3 & net_14_1);
  assign sel_iq_instr0_dih[2] = (sel_iq_instr0_ctrl[3] & net_14_3);
  assign net_14_3 = (sel_iq_instr0_ctrl[2] & net_14_2);
  assign sel_iq_instr0_dih[1] = ~(sel_iq_instr0_ctrl[2] | sel_iq_instr0_dih[0]);

// End automatically generated logic

  assign sel_iq_instr0 = iq_instr1_dih ? sel_iq_instr0_dih : sel_iq_instr0_nodih;

  assign nxt_iq_instr0[47:0] = (({48{sel_iq_instr0[3]}} & ifu_instr0_if3_i[47:0]) |     // IFU instruction-0
                                ({48{sel_iq_instr0[2]}} & iq_holding0[47:0])      |     // IQ holiding instruction-0
                                ({48{sel_iq_instr0[1]}} & iq_body0[47:0])         |     // IQ body instruction-0
                                ({48{sel_iq_instr0[0]}} & iq_instr1_common_de[47:0]));  // IQ head entry 1

  // ------------------------------------------------------
  // IQ head entry-0 registers
  // ------------------------------------------------------

  // DP/LS/Other/FPU-NEON control registers
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      iq_instr0_is_dp_de <= 1'b0;
      iq_instr0_is_ls_de <= 1'b0;
      iq_instr0_is_ot_de <= 1'b0;
      iq_instr0_is_fn_de <= 1'b0;
    end else if (iq_head_entry0_en[0]) begin
      iq_instr0_is_dp_de <= nxt_iq_instr0[DP];
      iq_instr0_is_ls_de <= nxt_iq_instr0[LS];
      iq_instr0_is_ot_de <= nxt_iq_instr0[OT];
      iq_instr0_is_fn_de <= nxt_iq_instr0[FN];
    end

  // Registers common between all entry 0 decoders
  always @(posedge clk)
    if (iq_head_entry0_en[0]) begin
      iq_instr0_sideband_de[5:0]      <= nxt_iq_instr0[47:42];  // Sideband
      iq_instr0_common_de[32:0]       <= nxt_iq_instr0[32:0];
      iq_instr0_common_aarch64_de     <= aarch64_state_i;
      iq_instr0_common_pdtype_de[1:0] <= nxt_iq_instr0[36:35];
      iq_instr0_d0_de                 <= nxt_iq_instr0[D0];
      iq_instr0_common_br_taken_de    <= nxt_iq_instr0[37]; // Used by branch decoder, which uses common head register
    end

  // AArch64 version for DIH control (not decode), and for other blocks
  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      iq_instr0_ctl_aarch64_de <= 1'b0;
      aarch64_state_ext_o      <= 1'b1;  // Reset to opposite value so not removed by synthesis
    end else if (iq_head_entry0_en[0]) begin
      iq_instr0_ctl_aarch64_de <= aarch64_state_i;
      aarch64_state_ext_o      <= aarch64_state_i;
    end

  // DP Instruction registers
  always @(posedge clk)
    if (iq_head_entry0_en[1]) begin
      iq_instr0_dp_pdtype_de[1:0] <= nxt_iq_instr0[36:35];
      iq_instr0_dp_de[32:0]       <= nxt_iq_instr0[32:0];
      iq_instr0_dp_aarch64_de     <= aarch64_state_i;
    end

  // LS Instruction registers
  always @(posedge clk)
    if (iq_head_entry0_en[2]) begin
      iq_instr0_ls_br_taken_de    <= nxt_iq_instr0[37];
      iq_instr0_ls_pdtype_de[1:0] <= nxt_iq_instr0[36:35];
      iq_instr0_ls_de[32:0]       <= nxt_iq_instr0[32:0];
      iq_instr0_ls_aarch64_de     <= aarch64_state_i;
    end

  // Other Instruction registers
  always @(posedge clk)
    if (iq_head_entry0_en[3]) begin
      iq_instr0_other_br_taken_de     <= nxt_iq_instr0[37];
      iq_instr0_other_pdtype_de[1:0]  <= nxt_iq_instr0[36:35];
      iq_instr0_other_de[32:0]        <= nxt_iq_instr0[32:0];
      iq_instr0_other_aarch64_de      <= aarch64_state_i;
    end

  generate if (NEON_FP) begin : NEON_AND_FPU_2
    // FPU/Neon registers
    reg [32:0]  iq_instr0_fn_de_reg;
    reg  [1:0]  iq_instr0_fn_pdtype_de_reg;
    reg         iq_instr0_fn_aarch64_reg;
    reg [29:0]  iq_instr0_fn_dih_de_reg;
    reg         iq_instr0_fn_dih_32_de_reg;
    reg         iq_instr0_fn_dih_pdtype0_de_reg;
    reg         iq_instr0_fn_dih_aarch64_de_reg;
    wire        iq_instr0_fn_dih_en;

    always @(posedge clk)
      if (iq_head_entry0_en[4]) begin
        iq_instr0_fn_pdtype_de_reg  <= nxt_iq_instr0[36:35];
        iq_instr0_fn_de_reg[32:0]   <= nxt_iq_instr0[32:0];
        iq_instr0_fn_aarch64_reg    <= aarch64_state_i;
      end

    // Only enable DIH head registers if dual issuable
    assign iq_instr0_fn_dih_en = iq_head_entry0_en[4] & nxt_iq_instr0[D0];

    always @(posedge clk)
      if (iq_instr0_fn_dih_en) begin
        iq_instr0_fn_dih_de_reg         <= nxt_iq_instr0[29:0];
        iq_instr0_fn_dih_32_de_reg      <= nxt_iq_instr0[32];
        iq_instr0_fn_dih_pdtype0_de_reg <= nxt_iq_instr0[35];
        iq_instr0_fn_dih_aarch64_de_reg <= aarch64_state_i;
      end

    assign iq_instr0_fn_de              = iq_instr0_fn_de_reg[32:0];
    assign iq_instr0_fn_pdtype_de       = iq_instr0_fn_pdtype_de_reg[1:0];
    assign iq_instr0_fn_aarch64_o       = iq_instr0_fn_aarch64_reg;
    assign iq_instr0_fn_dih_de          = iq_instr0_fn_dih_de_reg[29:0];
    assign iq_instr0_fn_dih_32_de       = iq_instr0_fn_dih_32_de_reg;
    assign iq_instr0_fn_dih_pdtype0_de  = iq_instr0_fn_dih_pdtype0_de_reg;
    assign iq_instr0_fn_dih_aarch64_de  = iq_instr0_fn_dih_aarch64_de_reg;

  end else begin : NO_NEON_AND_FPU_2
    // If no FPU/Neon, then FPU/Neon instructions come from the Other register
    assign iq_instr0_fn_pdtype_de       = iq_instr0_other_pdtype_de[1:0];
    assign iq_instr0_fn_de              = iq_instr0_other_de[32:0];
    assign iq_instr0_fn_dih_de          = {30{1'b0}};
    assign iq_instr0_fn_dih_32_de       = 1'b0;
    assign iq_instr0_fn_dih_pdtype0_de  = 1'b0;
    assign iq_instr0_fn_dih_aarch64_de  = 1'b0;
    assign iq_instr0_fn_aarch64_o       = 1'b0;
  end endgenerate

  // ------------------------------------------------------
  // Dual issue hazard checking
  // ------------------------------------------------------

  // For the purposes of dual issue hazarding, branch instructions (i.e. where
  // class is all zero) are treated as other instructions.
  assign iq_instr1_is_ot_dih = iq_instr1_common_de[OT] | ~(iq_instr1_common_de[DP] | iq_instr1_common_de[LS] | iq_instr1_common_de[FN]);
  assign iq_instr0_is_ot_dih = iq_instr0_is_ot_de      | ~(iq_instr0_is_dp_de      | iq_instr0_is_ls_de      | iq_instr0_is_fn_de);

  // Calculations for dual issue hazarding
  ca53dpu_iq_dih `CA53_DPU_PARAM_INST u_iq_dih (
    // Inputs
    .iq_instr0_aarch64_i                  (iq_instr0_common_aarch64_de),
    .iq_instr1_aarch64_i                  (iq_instr1_common_aarch64_de),
    .iq_instr0_ctl_aarch64_i              (iq_instr0_ctl_aarch64_de),
    .iq_instr1_ctl_aarch64_i              (iq_instr1_ctl_aarch64_de),
    .iq_instr1_sideband_i                 (iq_instr1_common_de[47:42]),
    .iq_instr1_i                          (iq_instr1_common_de[32:0]),
    .iq_instr1_pdtype_i                   (iq_instr1_common_de[36:35]),
    .iq_instr1_is_dp_i                    (iq_instr1_common_de[DP]),
    .iq_instr1_is_ls_i                    (iq_instr1_common_de[LS]),
    .iq_instr1_is_ot_i                    (iq_instr1_is_ot_dih),
    .iq_instr1_is_fn_i                    (iq_instr1_common_de[FN]),
    .iq_instr0_i                          (iq_instr0_common_de),
    .iq_instr0_fn_dih_i                   (iq_instr0_fn_dih_de[29:0]),
    .iq_instr0_fn_dih_32_i                (iq_instr0_fn_dih_32_de),
    .iq_instr0_fn_dih_pdtype0_i           (iq_instr0_fn_dih_pdtype0_de),
    .iq_instr0_fn_dih_aarch64_i           (iq_instr0_fn_dih_aarch64_de),
    .iq_instr1_fn_dih_i                   (iq_instr1_fn_dih_de[29:0]),
    .iq_instr1_fn_dih_pdtype0_i           (iq_instr1_fn_dih_pdtype0_de),
    .iq_instr1_fn_dih_aarch64_i           (iq_instr1_fn_dih_aarch64_de),
    .iq_instr0_is_dp_i                    (iq_instr0_is_dp_de),
    .iq_instr0_is_ls_i                    (iq_instr0_is_ls_de),
    .iq_instr0_is_ot_i                    (iq_instr0_is_ot_dih),
    .iq_instr0_is_fn_i                    (iq_instr0_is_fn_de),
    .iq_instr0_pdtype_i                   (iq_instr0_common_pdtype_de[1:0]),
    .iq_instr0_sideband_i                 (iq_instr0_sideband_de[5:0]),
    .rf_wr_en_w0_iss_i                    (rf_wr_en_w0_iss_i),
    .rf_wr_en_w1_iss_i                    (rf_wr_en_w1_iss_i),
    .rf_wr_en_w2_iss_i                    (rf_wr_en_w2_iss_i),
    .rf_wr_when_w0_iss_i                  (rf_wr_when_w0_iss_i),
    .rf_wr_when_w1_iss_i                  (rf_wr_when_w1_iss_i),
    .rf_wr_when_w2_iss_i                  (rf_wr_when_w2_iss_i),
    .rf_wr_vaddr_w0_iss_i                 (rf_wr_vaddr_w0_iss_i[4:0]),
    .rf_wr_vaddr_w1_iss_i                 (rf_wr_vaddr_w1_iss_i[4:0]),
    .rf_wr_vaddr_w2_iss_i                 (rf_wr_vaddr_w2_iss_i[4:0]),
    .rf_wr_en_w0_ex1_i                    (rf_wr_en_w0_ex1_i),
    .rf_wr_en_w1_ex1_i                    (rf_wr_en_w1_ex1_i),
    .rf_wr_en_w2_ex1_i                    (rf_wr_en_w2_ex1_i),
    .rf_wr_when_w0_ex1_i                  (rf_wr_when_w0_ex1_i),
    .rf_wr_when_w1_ex1_i                  (rf_wr_when_w1_ex1_i),
    .rf_wr_when_w2_ex1_i                  (rf_wr_when_w2_ex1_i),
    .rf_wr_vaddr_w0_ex1_i                 (rf_wr_vaddr_w0_ex1_i[4:0]),
    .rf_wr_vaddr_w1_ex1_i                 (rf_wr_vaddr_w1_ex1_i[4:0]),
    .rf_wr_vaddr_w2_ex1_i                 (rf_wr_vaddr_w2_ex1_i[4:0]),
    .rf_wr_en_fw0_iss_i                   (rf_wr_en_fw0_iss_i),
    .rf_wr_en_fw1_iss_i                   (rf_wr_en_fw1_iss_i),
    .rf_wr_en_fw0_f1_i                    (rf_wr_en_fw0_f1_i),
    .rf_wr_en_fw1_f1_i                    (rf_wr_en_fw1_f1_i),
    .rf_wr_en_fw0_f2_i                    (rf_wr_en_fw0_f2_i),
    .rf_wr_en_fw1_f2_i                    (rf_wr_en_fw1_f2_i),
    .rf_wr_when_fw0_iss_i                 (rf_wr_when_fw0_iss_i),
    .rf_wr_when_fw1_iss_i                 (rf_wr_when_fw1_iss_i),
    .rf_wr_when_fw0_f1_i                  (rf_wr_when_fw0_f1_i),
    .rf_wr_when_fw1_f1_i                  (rf_wr_when_fw1_f1_i),
    .rf_wr_when_fw0_f2_i                  (rf_wr_when_fw0_f2_i),
    .rf_wr_when_fw1_f2_i                  (rf_wr_when_fw1_f2_i),
    .rf_wr_addr_fw0_iss_i                 (rf_wr_addr_fw0_iss_i),
    .rf_wr_addr_fw1_iss_i                 (rf_wr_addr_fw1_iss_i),
    .rf_wr_addr_fw0_f1_i                  (rf_wr_addr_fw0_f1_i),
    .rf_wr_addr_fw1_f1_i                  (rf_wr_addr_fw1_f1_i),
    .rf_wr_addr_fw0_f2_i                  (rf_wr_addr_fw0_f2_i),
    .rf_wr_addr_fw1_f2_i                  (rf_wr_addr_fw1_f2_i),
    .adrp_valid_iss_i                     (adrp_valid_iss_i[1:0]),
    .taken_br_instr_iss_i                 (taken_br_instr_iss_i),
    .iss_pc_in_same_page_i                (iss_pc_in_same_page_i[1:0]),
    .cp_trap_fp_i                         (cp_trap_fp_i),
    .cp_trap_neon_i                       (cp_trap_neon_i),
    // Outputs                           
    .fn_dcu_valid_instr1_o                (fn_dcu_valid_instr1),
    .iq_instr0_r2_enabled_o               (iq_instr0_r2_enabled_o),
    .iq_instr0_w0_enabled_o               (iq_instr0_w0_enabled_o),
    .iq_instr1_br_valid_o                 (iq_instr1_br_valid_o),
    .iq_instr1_datapath_resource_hazard_o (iq_instr1_datapath_resource_hazard_o),
    .iq_instr0_sets_ccflags_o             (iq_instr0_sets_ccflags_o),
    .iq_instr0_d0_uses_dcu_o              (iq_instr0_d0_uses_dcu_o),
    .iq_instr1_dih_o                      (iq_instr1_dih),
    .iq_instr1_is_aesimc_aesmc_o          (iq_instr1_is_aesimc_aesmc_o),
    .iq_skew_instr0_o                     (iq_skew_instr0_o),
    .iq_skew_instr0_r0_o                  (iq_skew_instr0_r0_o),
    .iq_skew_instr0_r1_o                  (iq_skew_instr0_r1_o),
    .iq_skew_instr1_o                     (iq_skew_instr1_o),
    .iq_skew_instr1_r0_o                  (iq_skew_instr1_r0_o),
    .iq_skew_instr1_r1_o                  (iq_skew_instr1_r1_o),
    .iq_instr0_adrp_fwd_o                 (iq_instr0_adrp_fwd_o),
    .iq_instr0_adrp_fwd_src_o             (iq_instr0_adrp_fwd_src_o[2:1]),
    .iq_instr1_adrp_fwd_o                 (iq_instr1_adrp_fwd_o),
    .iq_instr1_adrp_fwd_src_o             (iq_instr1_adrp_fwd_src_o[2:0])
  );

  // Qualify fn_dcu_valid as not valid when not D1 FN instruction
  assign iq_instr1_fn_dcu_valid_o = fn_dcu_valid_instr1 & iq_instr1_common_de[FN] & iq_instr1_common_de[D1];

  // ------------------------------------------------------
  // Pop control
  // ------------------------------------------------------

  // The instr1_dih signal is very late, so to improve timing it is factored in
  // as late as possible in several places
  // - calculate if can dual issue assuming no DIH
  assign can_dual_issue_if_no_dih = iq_head_valid[1] &
                                    ~disable_dual_issue_i &
                                    ~(disable_fp_dual_issue_i & iq_instr1_common_de[FN]) &
                                    iq_instr0_d0_de & iq_instr1_common_de[D1];

  assign can_dual_issue = can_dual_issue_if_no_dih & ~iq_instr1_dih;

  // pop_two  -> Dual issue opportunity or valid return in slot-0
  // pop_one  -> Last cycle
  // pop_zero -> Not finish_instr_de or flush
  assign iq_pop = {2{(~flush_wr_i & finish_instr_de_i)}} & {can_dual_issue, iq_head_valid[0]};

  // ------------------------------------------------------
  // Floating-Point / NEON instruction detection
  // ------------------------------------------------------

  // Detect FP/NEON instructions in the holding or head instruction-1 registers.  FP/NEON instructions
  // that pass through the holding registers while there are instructions in the body of the queue will
  // result in the iq_neon_present signal dropping low again, but the wakeup process will still have
  // begun.
  //
  // The calculation is registered before being used in the control logic to decouple timing paths.
  // For this reason the head instruction-0 registers are not looked at because the De stage detection
  // logic will cover this.
  generate if (NEON_FP) begin : NEON_AND_FPU_3
    wire nxt_fn_in_holding_or_head;
    reg  fn_in_holding_or_head;

    assign nxt_fn_in_holding_or_head = ~flush_wr_i & ((iq_holding1[FN]          & iq_holding_valid[1]) |
                                                      (iq_holding0[FN]          & iq_holding_valid[0]) |
                                                      (iq_instr1_common_de[FN]  & iq_head_valid[1]));

    always @(posedge clk or negedge reset_n)
      if (~reset_n)
        fn_in_holding_or_head <= 1'b0;
      else
        fn_in_holding_or_head <= nxt_fn_in_holding_or_head;

    assign iq_neon_present = fn_in_holding_or_head;
  end else begin : NO_NEON_AND_FPU_3
    assign iq_neon_present = 1'b0;
  end endgenerate

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  // Factor in whether the PAQ is full into the fullness indicators to the IFU
  assign dpu_iq_full_o               = iq_full | paq_full_i;
  assign dpu_iq_part_full_o          = iq_part_full;
  assign iq_instr0_sideband_o        = iq_instr0_sideband_de[5:0];
  assign iq_instr0_common_o          = iq_instr0_common_de[32:0];
  assign iq_instr0_common_aarch64_o  = iq_instr0_common_aarch64_de;
  assign iq_instr0_dp_o              = iq_instr0_dp_de[32:0];
  assign iq_instr0_dp_pdtype_o       = iq_instr0_dp_pdtype_de[1:0];
  assign iq_instr0_ls_o              = iq_instr0_ls_de[32:0];
  assign iq_instr0_ls_pdtype_o       = iq_instr0_ls_pdtype_de[1:0];
  assign iq_instr0_ls_br_taken_o     = iq_instr0_ls_br_taken_de;
  assign iq_instr0_other_o           = iq_instr0_other_de[32:0];
  assign iq_instr0_other_pdtype_o    = iq_instr0_other_pdtype_de[1:0];
  assign iq_instr0_other_br_taken_o  = iq_instr0_other_br_taken_de;
  assign iq_instr0_common_br_taken_o = iq_instr0_common_br_taken_de;
  assign iq_instr0_fn_o              = iq_instr0_fn_de[32:0];
  assign iq_instr0_fn_pdtype_o       = iq_instr0_fn_pdtype_de[1:0];
  assign iq_instr0_dp_aarch64_o      = iq_instr0_dp_aarch64_de;
  assign iq_instr0_ls_aarch64_o      = iq_instr0_ls_aarch64_de;
  assign iq_instr0_other_aarch64_o   = iq_instr0_other_aarch64_de;
  assign iq_instr0_en_other_o        = iq_head_entry0_en[3];
  assign iq_instr0_is_dp_o           = iq_instr0_is_dp_de;
  assign iq_instr0_is_ls_o           = iq_instr0_is_ls_de;
  assign iq_instr0_is_other_o        = iq_instr0_is_ot_de;
  assign iq_instr0_is_fn_o           = iq_instr0_is_fn_de;
  assign iq_instr0_val_o             = iq_head_valid[0];
  assign iq_instr0_pdtype_o          = iq_instr0_common_pdtype_de;
  assign iq_instr0_d0_o              = iq_instr0_d0_de;
  assign iq_instr1_d1_o              = iq_instr1_common_de[D1];
  assign iq_instr1_sideband_o        = iq_instr1_common_de[47:42];
  assign iq_instr1_is_dp_o           = iq_instr1_common_de[DP];
  assign iq_instr1_is_ls_o           = iq_instr1_common_de[LS];
  assign iq_instr1_is_other_o        = iq_instr1_common_de[OT];
  assign iq_instr1_is_fn_o           = iq_instr1_common_de[FN];
  assign iq_instr1_is_dec1_o         = iq_instr1_common_de[DP] | iq_instr1_common_de[OT];  // Dec1 is DP + Other
  assign iq_instr1_pdtype_o          = iq_instr1_common_de[36:35];
  assign iq_instr1_main_o            = iq_instr1_main_de[32:0];
  assign iq_instr1_main_aarch64_o    = iq_instr1_main_aarch64_de;
  assign iq_instr1_br_taken_o        = iq_instr1_common_de[37];
  assign iq_instr1_ls_o              = iq_instr1_ls_de[32:0];
  assign iq_instr1_ls_aarch64_o      = iq_instr1_ls_aarch64_de;
  assign iq_instr1_fn_o              = iq_instr1_fn_de[32:0];
  assign iq_instr1_fn_aarch64_o      = iq_instr1_fn_aarch64_de;
  assign iq_instr1_common_o          = iq_instr1_common_de[32:0];
  assign iq_instr1_common_aarch64_o  = iq_instr1_common_aarch64_de;
  assign iq_instr1_val_o             = iq_head_valid[1];
  assign iq_instr1_dih_o             = iq_instr1_dih;
  assign iq_neon_present_o           = iq_neon_present;
  assign evnt_iq_empty_o             = ~iq_head_valid[0];

  // ------------------------------------------------------
  // OVL_ASSERTs for IQ
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, IQ_BODY_ENTRIES, `OVL_ASSERT, "Register enable x-check: iq_body_en[(IQ_BODY_ENTRIES-1):0]")
  u_ovl_x_iq_body_en (.clk       (clk_iq_body),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (iq_body_en[(IQ_BODY_ENTRIES-1):0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_head_entry0_en[0]")
  u_ovl_x_iq_head_entry0_en0 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (iq_head_entry0_en[0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_head_entry0_en[1]")
  u_ovl_x_iq_head_entry0_en1 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (iq_head_entry0_en[1]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_head_entry0_en[3]")
  u_ovl_x_iq_head_entry0_en3 (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (iq_head_entry0_en[3]));

  generate if (NEON_FP) begin : NEON_AND_FPU_4
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_head_entry0_en[4]")
    u_ovl_x_iq_head_entry0_en4 (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (iq_head_entry0_en[4]));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_instr1_fn_dih_en")
    u_ovl_x_iq_instr1_fn_dih_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (g_instr1_fn_neon.iq_instr1_fn_dih_en));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_instr0_fn_dih_en")
    u_ovl_x_iq_instr0_fn_dih_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (NEON_AND_FPU_2.iq_instr0_fn_dih_en));
  end endgenerate

  assert_never_unknown #(`OVL_FATAL, IQ_HEAD_ENTRY1_EN_W, `OVL_ASSERT, "Register enable x-check: iq_head_entry1_en")
  u_ovl_x_iq_head_entry1_en (.clk       (clk),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (iq_head_entry1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_holding_entry0_en")
  u_ovl_x_iq_holding_entry0_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (iq_holding_entry0_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: iq_holding_entry1_en")
  u_ovl_x_iq_holding_entry1_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (iq_holding_entry1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: last_enable")
  u_ovl_x_last_enable (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (last_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: read_ptr_en")
  u_ovl_x_read_ptr_en (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (read_ptr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_ptr_en")
  u_ovl_x_write_ptr_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (write_ptr_en));

  //----------------------------------------------------------------------------
  // FP instructions should only set A32/A64 only bit in A64
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Saw A32 only D0 FP instruction")
    ovl_a32_fp_d0    (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (iq_head_valid[0] & iq_instr0_d0_de & iq_instr0_is_fn_de & iq_instr0_fn_dih_pdtype0_de),
                      .consequent_expr (iq_instr0_common_pdtype_de == 2'b01 & iq_instr0_fn_dih_aarch64_de));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Saw A32 only D1 FP instruction")
    ovl_a32_fp_d1    (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (iq_head_valid[1] & iq_instr1_common_de[D1] & iq_instr1_common_de[FN] & iq_instr1_fn_dih_pdtype0_de),
                      .consequent_expr (iq_instr1_common_de[36:35] == 2'b01 & iq_instr1_fn_dih_aarch64_de));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ was pushed when it was full!
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The IQ was pushed when it was full!")
    ovl_iq_push_full (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (dpu_iq_full_o),
                      .consequent_expr (~iq_push[0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ was popped when it was empty!
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The IQ was popped when it was empty!")
    ovl_iq_pop_empty (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (~iq_head_valid[0]),
                      .consequent_expr (~iq_pop[0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ was popped when it was nearly empty!
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"The IQ was popped when it was nearly empty")
    ovl_iq_pop_near_empty (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (~iq_head_valid[1]),
                           .consequent_expr (~iq_pop[1]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ pop signal is illegal
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"The IQ pop signal was illegal")
    ovl_iq_pop_illegal (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (iq_pop[1:0] == 2'b10));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ fifo read pointer is not one hot!
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL,IQ_BODY_ENTRIES,`OVL_ASSERT,"The IQ fifo read pointer is not one hot")
    ovl_read_ptr_one_hot (.clk       (clk),
                          .reset_n   (reset_n),
                          .test_expr (read_ptr[(IQ_BODY_ENTRIES-1):0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // The IQ fifo write pointer is not one hot
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL,IQ_BODY_ENTRIES,`OVL_ASSERT,"The IQ fifo write pointer is not one hot")
    ovl_write_ptr_one_hot (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr (write_ptr[(IQ_BODY_ENTRIES-1):0]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // There are too many IQ fifo enables - only 2 should be enabled at once!
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg [IQ_BODY_ENTRIES-1:0] ovl_en_count;
  integer   j;

  always @*
    begin
      ovl_en_count = {IQ_BODY_ENTRIES{1'b0}};
      for(j=0;j<IQ_BODY_ENTRIES;j=j+1)
        ovl_en_count = ovl_en_count + {{(IQ_BODY_ENTRIES-1){1'b0}}, iq_body_en[j]};
    end

  assert_always #(`OVL_FATAL,`OVL_ASSERT,"There are too many IQ body enables - only 2 should be enabled at once!")
    ovl_iq_fifo_en (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ovl_en_count <= 2));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // One-hot check on decoder selects
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"IQ Head Entry-0 instruction can only be one of: DP, LS, Other, Float-NEON")
    ovl_iq_instr_type (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr ({{3{iq_head_valid[0]}} & {iq_instr0_is_dp_de, iq_instr0_is_ls_de, iq_instr0_is_ot_de}}));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // IQ head entry-0 valid check
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"If IQ head entry-1 is valid then IQ head entry-0 must also be valid")
    ovl_iq_head_valid0 (.clk             (clk),
                        .reset_n         (reset_n),
                        .antecedent_expr (iq_head_valid[1]),
                        .consequent_expr (iq_head_valid[0]));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_iq

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
