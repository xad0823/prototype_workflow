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
// Abstract : Instruction micro TLB including hit and fault logic
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_utlb (
  // Inputs
  input wire          clk,
  input wire          reset_n,
  input wire          DFTSE,
  input wire [48:12]  agu_a_operand_if1_i,
  input wire [48:12]  agu_b_operand_if1_i,
  input wire [63:12]  va_if1_i,
  input wire          carry_out_4k_i,
  input wire          carry_out_1m_i,
  input wire          aarch64_state_i,
  input wire          dpu_mmu_on_i,
  input wire          dpu_flush_i_utlb_i,
  input wire [31:0]   dpu_dacr_i,
  input wire          sif_only_i,
  input wire          ns_state_i,
  input wire          default_cacheable_i,
  input wire          exception_level_0_i,
  input wire          exception_level_2_i,
  input wire          exception_level_3_i,
  input wire          pfb_aarch64_at_el3_i,
  input wire [96:0]   tlb_i_utlb_data_i,
  input wire          tlb_i_utlb_enable_i,
  input wire          tlb_i_utlb_might_enable_i,
  input wire          tlb_i_utlb_valid_i,
  input wire          tlb_i_utlb_flush_i,
  input wire          tlb_i_utlb_lpae_i,
  input wire          tlb_lpae_mode_i,
  input wire          force_if0_i,
  input wire          abort_inbound_i,
  input wire          stop_pfb_i,
  input wire          pfb_valid_if1_i,
  // Outputs
  output wire         tlb_hit_if1_o,
  output wire         main_tlb_abort_if1_o,
  output wire         micro_tlb_abort_if1_o,
  output wire [6:0]   tlb_abort_type_if1_o,
  output wire [1:0]   stage2_abort_if1_o,
  output wire         lpae_abort_if1_o,
  output wire [39:12] pa_if1_o,
  output wire         ns_dsc_if1_o,
  output wire [7:0]   attributes_if1_o,
  output wire [27:0]  abort_ipa_if1_o);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [3:0]      round_robin_count;
  reg [8:0]      round_robin;
  reg            utlb_write_if1;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire           clk_iutlb;
  wire [7:0]     entry0_attr_if1;
  wire [7:0]     entry1_attr_if1;
  wire [7:0]     entry2_attr_if1;
  wire [7:0]     entry3_attr_if1;
  wire [7:0]     entry4_attr_if1;
  wire [7:0]     entry5_attr_if1;
  wire [7:0]     entry6_attr_if1;
  wire [7:0]     entry7_attr_if1;
  wire [7:0]     entry8_attr_if1;
  wire [7:0]     entry9_attr_if1;
  wire [39:12]   entry0_pa_if1;
  wire [39:12]   entry1_pa_if1;
  wire [39:12]   entry2_pa_if1;
  wire [39:12]   entry3_pa_if1;
  wire [39:12]   entry4_pa_if1;
  wire [39:12]   entry5_pa_if1;
  wire [39:12]   entry6_pa_if1;
  wire [39:12]   entry7_pa_if1;
  wire [39:12]   entry8_pa_if1;
  wire [39:12]   entry9_pa_if1;
  wire [6:0]     entry0_abort_type_if1;
  wire [6:0]     entry1_abort_type_if1;
  wire [6:0]     entry2_abort_type_if1;
  wire [6:0]     entry3_abort_type_if1;
  wire [6:0]     entry4_abort_type_if1;
  wire [6:0]     entry5_abort_type_if1;
  wire [6:0]     entry6_abort_type_if1;
  wire [6:0]     entry7_abort_type_if1;
  wire [6:0]     entry8_abort_type_if1;
  wire [6:0]     entry9_abort_type_if1;
  wire [1:0]     entry0_stage2_abort;
  wire           entry0_lpae_abort;
  wire [9:0]     hit_if1;
  wire           main_tlb_abort;
  wire [9:0]     micro_tlb_abort;
  wire [9:0]     ns_dsc_if1;
  wire [9:0]     utlb_entry_valid;
  wire [9:0]     nxt_utlb_entry_valid;
  wire [9:0]     utlb_entry_enable;
  wire           utlb_valid_enable;
  wire [80:0]    intf_entry_data;
  wire           round_robin_en;
  wire [3:0]     next_round_robin_count;
  wire           nxt_utlb_write_if1;
  wire [48:12]   agu_a_xor_agu_b;
  wire [47:12]   agu_a_and_agu_b;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // All but the valid registers in the micro-TLB can be architecturally gated
  // using an intermediate clock gate.  The enable signal is register bound
  // from the TLB.
  ca53_cell_inter_clkgate u_inter_clkgate_iutlb (.clk_i         (clk),
                                                 .clk_enable_i  (tlb_i_utlb_might_enable_i),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (clk_iutlb));

  // ------------------------------------------------------
  // Entry control logic
  // ------------------------------------------------------

  // Round robin logic for updating utlb entries.
  assign round_robin_en = tlb_i_utlb_might_enable_i & utlb_entry_valid[0] & ~micro_tlb_abort[0];

  assign next_round_robin_count = round_robin[8] ? 4'b0000 : (round_robin_count + 4'b0001);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      round_robin_count <= 4'b0000;
    else if (round_robin_en)
      round_robin_count <= next_round_robin_count;

  always @*
    case (round_robin_count)
      4'b0000 : round_robin = 9'b000000001;
      4'b0001 : round_robin = 9'b000000010;
      4'b0010 : round_robin = 9'b000000100;
      4'b0011 : round_robin = 9'b000001000;
      4'b0100 : round_robin = 9'b000010000;
      4'b0101 : round_robin = 9'b000100000;
      4'b0110 : round_robin = 9'b001000000;
      4'b0111 : round_robin = 9'b010000000;
      4'b1000 : round_robin = 9'b100000000;
      default : round_robin = 9'bxxxxxxxxx;
    endcase

  // Always enable entry 0 when the main TLB may be writing a new entry, and if
  // entry 0 is currently valid then pick a different entry to move it to based on
  // the round robin counter.
  //
  // If there is an abort in the interface entry then do not move it to one of the
  // main entries.  This approach is pessmistic as there will be privileged aborts
  // which may go away after a flush.  However the main-TLB will still keep a copy
  // of the page so the extra micro-TLB miss delay in these cases will be small and
  // it both reduces the amount of control signals that need to be transferred and
  // prevents us from losing information which was needed to trigger an abort.
  assign utlb_entry_enable = {10{tlb_i_utlb_might_enable_i}} & {{9{utlb_entry_valid[0] & ~micro_tlb_abort[0]}} & round_robin, 1'b1};

  // Enable all the main valid bits whenever at least one of them changes. This
  // allows them to share the same clock gate.
  assign utlb_valid_enable = tlb_i_utlb_might_enable_i | tlb_i_utlb_flush_i | dpu_flush_i_utlb_i;

  assign nxt_utlb_entry_valid[0] =     tlb_i_utlb_valid_i & tlb_i_utlb_enable_i        & ~(  tlb_i_utlb_flush_i | dpu_flush_i_utlb_i);
  assign nxt_utlb_entry_valid[9:1] = ((utlb_entry_valid[9:1] | utlb_entry_enable[9:1]) & ~{9{tlb_i_utlb_flush_i | dpu_flush_i_utlb_i}});

  // Part of the A+B=K calculation which is common to all entries
  assign agu_a_xor_agu_b[48:12] = agu_a_operand_if1_i[48:12] ^ agu_b_operand_if1_i[48:12];
  assign agu_a_and_agu_b[47:12] = agu_a_operand_if1_i[47:12] & agu_b_operand_if1_i[47:12];

  // ------------------------------------------------------
  // Interface micro TLB entry (entry 0)
  // ------------------------------------------------------

  // The interface entry stores more (fault related) information than the main entries
  ca53ifu_pf_utlb_intf_entry
    u_entry0
      (// Inputs
       .clk                     (clk),
       .clk_iutlb               (clk_iutlb),
       .reset_n                 (reset_n),
       .va_if1_i                (va_if1_i[19:12]),
       .agu_a_operand_if1_i     (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i     (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i       (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i       (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i          (carry_out_4k_i),
       .carry_out_1m_i          (carry_out_1m_i),
       .aarch64_state_i         (aarch64_state_i),
       .tlb_i_utlb_data_i       (tlb_i_utlb_data_i[96:0]),
       .utlb_entry_enable_i     (utlb_entry_enable[0]),
       .utlb_valid_enable_i     (utlb_valid_enable),
       .nxt_utlb_entry_valid_i  (nxt_utlb_entry_valid[0]),
       .tlb_i_utlb_lpae_i       (tlb_i_utlb_lpae_i),
       .tlb_i_utlb_flush_i      (tlb_i_utlb_flush_i),
       .dpu_mmu_on_i            (dpu_mmu_on_i),
       .dpu_dacr_i              (dpu_dacr_i[31:0]),
       .dpu_flush_i_utlb_i      (dpu_flush_i_utlb_i),
       .sif_only_i              (sif_only_i),
       .ns_state_i              (ns_state_i),
       .default_cacheable_i     (default_cacheable_i),
       .exception_level_0_i     (exception_level_0_i),
       .exception_level_2_i     (exception_level_2_i),
       .exception_level_3_i     (exception_level_3_i),
       .pfb_aarch64_at_el3_i    (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o      (utlb_entry_valid[0]),
       .intf_entry_data_o       (intf_entry_data[80:0]),
       .hit_if1_o               (hit_if1[0]),
       .main_tlb_abort_o        (main_tlb_abort),
       .micro_tlb_abort_o       (micro_tlb_abort[0]),
       .abort_type_o            (entry0_abort_type_if1[6:0]),
       .stage2_abort_o          (entry0_stage2_abort[1:0]),
       .lpae_abort_o            (entry0_lpae_abort),
       .ns_dsc_if1_o            (ns_dsc_if1[0]),
       .pa_if1_o                (entry0_pa_if1[39:12]),
       .attr_if1_o              (entry0_attr_if1[7:0]),
       .abort_ipa_if1_o         (abort_ipa_if1_o)
      );

  // ------------------------------------------------------
  // Main micro TLB entries
  // ------------------------------------------------------

  // Entry 1
  ca53ifu_pf_utlb_main_entry
    u_entry1
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[1]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[1]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[1]),
       .hit_if1_o              (hit_if1[1]),
       .micro_tlb_abort_o      (micro_tlb_abort[1]),
       .abort_type_o           (entry1_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[1]),
       .pa_if1_o               (entry1_pa_if1[39:12]),
       .attr_if1_o             (entry1_attr_if1[7:0])
      );

  // Entry 2
  ca53ifu_pf_utlb_main_entry
    u_entry2
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[2]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[2]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[2]),
       .hit_if1_o              (hit_if1[2]),
       .micro_tlb_abort_o      (micro_tlb_abort[2]),
       .abort_type_o           (entry2_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[2]),
       .pa_if1_o               (entry2_pa_if1[39:12]),
       .attr_if1_o             (entry2_attr_if1[7:0])
      );

  // Entry 3
  ca53ifu_pf_utlb_main_entry
    u_entry3
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[3]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[3]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[3]),
       .hit_if1_o              (hit_if1[3]),
       .micro_tlb_abort_o      (micro_tlb_abort[3]),
       .abort_type_o           (entry3_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[3]),
       .pa_if1_o               (entry3_pa_if1[39:12]),
       .attr_if1_o             (entry3_attr_if1[7:0])
      );

  // Entry 4
  ca53ifu_pf_utlb_main_entry
    u_entry4
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[4]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[4]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[4]),
       .hit_if1_o              (hit_if1[4]),
       .micro_tlb_abort_o      (micro_tlb_abort[4]),
       .abort_type_o           (entry4_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[4]),
       .pa_if1_o               (entry4_pa_if1[39:12]),
       .attr_if1_o             (entry4_attr_if1[7:0])
      );

  // Entry 5
  ca53ifu_pf_utlb_main_entry
    u_entry5
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[5]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[5]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[5]),
       .hit_if1_o              (hit_if1[5]),
       .micro_tlb_abort_o      (micro_tlb_abort[5]),
       .abort_type_o           (entry5_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[5]),
       .pa_if1_o               (entry5_pa_if1[39:12]),
       .attr_if1_o             (entry5_attr_if1[7:0])
      );

  // Entry 6
  ca53ifu_pf_utlb_main_entry
    u_entry6
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[6]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[6]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[6]),
       .hit_if1_o              (hit_if1[6]),
       .micro_tlb_abort_o      (micro_tlb_abort[6]),
       .abort_type_o           (entry6_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[6]),
       .pa_if1_o               (entry6_pa_if1[39:12]),
       .attr_if1_o             (entry6_attr_if1[7:0])
      );

  // Entry 7
  ca53ifu_pf_utlb_main_entry
    u_entry7
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[7]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[7]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[7]),
       .hit_if1_o              (hit_if1[7]),
       .micro_tlb_abort_o      (micro_tlb_abort[7]),
       .abort_type_o           (entry7_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[7]),
       .pa_if1_o               (entry7_pa_if1[39:12]),
       .attr_if1_o             (entry7_attr_if1[7:0])
      );

  // Entry 8
  ca53ifu_pf_utlb_main_entry
    u_entry8
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[8]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[8]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[8]),
       .hit_if1_o              (hit_if1[8]),
       .micro_tlb_abort_o      (micro_tlb_abort[8]),
       .abort_type_o           (entry8_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[8]),
       .pa_if1_o               (entry8_pa_if1[39:12]),
       .attr_if1_o             (entry8_attr_if1[7:0])
      );

  // Entry 9
  ca53ifu_pf_utlb_main_entry
    u_entry9
      (// Inputs
       .clk                    (clk),
       .clk_iutlb              (clk_iutlb),
       .reset_n                (reset_n),
       .va_if1_i               (va_if1_i[19:12]),
       .agu_a_operand_if1_i    (agu_a_operand_if1_i[47:12]),
       .agu_b_operand_if1_i    (agu_b_operand_if1_i[47:12]),
       .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
       .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
       .carry_out_4k_i         (carry_out_4k_i),
       .carry_out_1m_i         (carry_out_1m_i),
       .aarch64_state_i        (aarch64_state_i),
       .intf_entry_data_i      (intf_entry_data[80:0]),
       .utlb_entry_enable_i    (utlb_entry_enable[9]),
       .utlb_valid_enable_i    (utlb_valid_enable),
       .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[9]),
       .tlb_i_utlb_flush_i     (tlb_i_utlb_flush_i),
       .dpu_flush_i_utlb_i     (dpu_flush_i_utlb_i),
       .exception_level_0_i    (exception_level_0_i),
       .exception_level_2_i    (exception_level_2_i),
       .exception_level_3_i    (exception_level_3_i),
       .pfb_aarch64_at_el3_i   (pfb_aarch64_at_el3_i),
       // Outputs
       .utlb_entry_valid_o     (utlb_entry_valid[9]),
       .hit_if1_o              (hit_if1[9]),
       .micro_tlb_abort_o      (micro_tlb_abort[9]),
       .abort_type_o           (entry9_abort_type_if1[6:0]),
       .ns_dsc_if1_o           (ns_dsc_if1[9]),
       .pa_if1_o               (entry9_pa_if1[39:12]),
       .attr_if1_o             (entry9_attr_if1[7:0])
      );

  // ------------------------------------------------------
  // Detection
  // ------------------------------------------------------

  // Record if the micro-TLB was written by the main TLB.  The valid signal will not
  // be set if there is an abort so this logic ensures that the abort signals are
  // propagated correctly.  While this is a little more complicated than it needs to
  // be there is consistency in the way the main-TLB treats the instruction side and
  // data side.
  assign nxt_utlb_write_if1 = ~force_if0_i & ~abort_inbound_i & ~stop_pfb_i & ~tlb_i_utlb_flush_i & ~dpu_flush_i_utlb_i & tlb_i_utlb_enable_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      utlb_write_if1 <= 1'b0;
    else
      utlb_write_if1 <= nxt_utlb_write_if1;

  // Other than hit dectection, all of the muxes are written in priority form so that if
  // two pages overlap in the micro-TLB - which is the responsibility of the software to
  // manage rather than the hardware - only one entry will be hit.  If these are written
  // in a one-hot form then if two overlapping entries were hit they would be OR'ed
  // together which would create spurious signals and potentially compromise security.
  // Note that this is only an issue on the instruction side micro-TLB because it stores
  // both 1MB sections and 4KB pages, whereas the data side only stores 4KB pages.

  // Hit signal.  If the DPU or TLB is flushing the micro-TLB then suppress as the
  // DACR or LPAE mode may change.
  assign tlb_hit_if1_o = (utlb_write_if1 & ~dpu_flush_i_utlb_i & ~tlb_i_utlb_flush_i) | (|hit_if1[9:0]);

  // TLB Abort signals
  assign main_tlb_abort_if1_o  = pfb_valid_if1_i & ~force_if0_i & utlb_write_if1 & main_tlb_abort;
  assign micro_tlb_abort_if1_o = pfb_valid_if1_i & ~force_if0_i & (hit_if1[0] ? micro_tlb_abort[0] :
                                                                   hit_if1[1] ? micro_tlb_abort[1] :
                                                                   hit_if1[2] ? micro_tlb_abort[2] :
                                                                   hit_if1[3] ? micro_tlb_abort[3] :
                                                                   hit_if1[4] ? micro_tlb_abort[4] :
                                                                   hit_if1[5] ? micro_tlb_abort[5] :
                                                                   hit_if1[6] ? micro_tlb_abort[6] :
                                                                   hit_if1[7] ? micro_tlb_abort[7] :
                                                                   hit_if1[8] ? micro_tlb_abort[8] :
                                                                   hit_if1[9] ? micro_tlb_abort[9] : 1'b0);

  // Stage-2 abort indicator
  assign stage2_abort_if1_o = {2{(hit_if1[0] | utlb_write_if1)}} & entry0_stage2_abort[1:0];

  // LPAE abort indicator
  // The main entries only need to look at the TLB LPAE mode signal
  assign lpae_abort_if1_o = (( (hit_if1[0] | utlb_write_if1) & entry0_lpae_abort) |
                             (~(hit_if1[0] | utlb_write_if1) & tlb_lpae_mode_i));

  // Abort type
  assign tlb_abort_type_if1_o[6:0] = ((hit_if1[0] | utlb_write_if1) ? entry0_abort_type_if1[6:0] :
                                      hit_if1[1]                    ? entry1_abort_type_if1[6:0] :
                                      hit_if1[2]                    ? entry2_abort_type_if1[6:0] :
                                      hit_if1[3]                    ? entry3_abort_type_if1[6:0] :
                                      hit_if1[4]                    ? entry4_abort_type_if1[6:0] :
                                      hit_if1[5]                    ? entry5_abort_type_if1[6:0] :
                                      hit_if1[6]                    ? entry6_abort_type_if1[6:0] :
                                      hit_if1[7]                    ? entry7_abort_type_if1[6:0] :
                                      hit_if1[8]                    ? entry8_abort_type_if1[6:0] :
                                      hit_if1[9]                    ? entry9_abort_type_if1[6:0] : {7{1'b0}});

  // Non-secure selection
  assign ns_dsc_if1_o = (hit_if1[0] ? ns_dsc_if1[0] :
                         hit_if1[1] ? ns_dsc_if1[1] :
                         hit_if1[2] ? ns_dsc_if1[2] :
                         hit_if1[3] ? ns_dsc_if1[3] :
                         hit_if1[4] ? ns_dsc_if1[4] :
                         hit_if1[5] ? ns_dsc_if1[5] :
                         hit_if1[6] ? ns_dsc_if1[6] :
                         hit_if1[7] ? ns_dsc_if1[7] :
                         hit_if1[8] ? ns_dsc_if1[8] :
                         hit_if1[9] ? ns_dsc_if1[9] : 1'b0);

  // Physical address selection
  assign pa_if1_o[39:12] = (hit_if1[0] ? entry0_pa_if1[39:12] :
                            hit_if1[1] ? entry1_pa_if1[39:12] :
                            hit_if1[2] ? entry2_pa_if1[39:12] :
                            hit_if1[3] ? entry3_pa_if1[39:12] :
                            hit_if1[4] ? entry4_pa_if1[39:12] :
                            hit_if1[5] ? entry5_pa_if1[39:12] :
                            hit_if1[6] ? entry6_pa_if1[39:12] :
                            hit_if1[7] ? entry7_pa_if1[39:12] :
                            hit_if1[8] ? entry8_pa_if1[39:12] :
                            hit_if1[9] ? entry9_pa_if1[39:12] : {28{1'b0}});

  // Attribute selection
  assign attributes_if1_o[7:0] = (hit_if1[0] ? entry0_attr_if1[7:0] :
                                  hit_if1[1] ? entry1_attr_if1[7:0] :
                                  hit_if1[2] ? entry2_attr_if1[7:0] :
                                  hit_if1[3] ? entry3_attr_if1[7:0] :
                                  hit_if1[4] ? entry4_attr_if1[7:0] :
                                  hit_if1[5] ? entry5_attr_if1[7:0] :
                                  hit_if1[6] ? entry6_attr_if1[7:0] :
                                  hit_if1[7] ? entry7_attr_if1[7:0] :
                                  hit_if1[8] ? entry8_attr_if1[7:0] :
                                  hit_if1[9] ? entry9_attr_if1[7:0] : {8{1'b0}});

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: round_robin_en")
  u_ovl_x_round_robin_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (round_robin_en));


  // ----------------------------------------------------------------------------
  // Check that any TLB page has AP of 3'b100 if the processor is in Hyp mode
  // ----------------------------------------------------------------------------
  reg            hyp_mode;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      hyp_mode <= 1'b0;
    else
      hyp_mode <= exception_level_2_i;

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"TLB page being written in Hyp Mode, but EL is not 2'b10")
    tlb_ap_in_hyp (.clk             (clk),
                   .reset_n         (reset_n),
                   .antecedent_expr (hyp_mode & utlb_entry_enable[0] & nxt_utlb_entry_valid[0]),
                   .consequent_expr (tlb_i_utlb_data_i[67:66] == `CA53_EL2));
  // OVL_ASSERT_END

  // ----------------------------------------------------------------------------
  // Check for valid values of round robin counter
  // ----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Next value of round robin counter in PFU utlb logic has an illegal value")
    u_ovl_round_robin_legal(.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (round_robin_en),
                            .consequent_expr (next_round_robin_count == 4'b0000 ||
                                              next_round_robin_count == 4'b0001 ||
                                              next_round_robin_count == 4'b0010 ||
                                              next_round_robin_count == 4'b0011 ||
                                              next_round_robin_count == 4'b0100 ||
                                              next_round_robin_count == 4'b0101 ||
                                              next_round_robin_count == 4'b0110 ||
                                              next_round_robin_count == 4'b0111 ||
                                              next_round_robin_count == 4'b1000 ));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Round robin counter in PFU utlb logic has an illegal value")
    u_ovl_round_robin_current_val_legal(.clk             (clk),
                                        .reset_n         (reset_n),
                                        .test_expr (round_robin_count == 4'b0000 ||
                                                    round_robin_count == 4'b0001 ||
                                                    round_robin_count == 4'b0010 ||
                                                    round_robin_count == 4'b0011 ||
                                                    round_robin_count == 4'b0100 ||
                                                    round_robin_count == 4'b0101 ||
                                                    round_robin_count == 4'b0110 ||
                                                    round_robin_count == 4'b0111 ||
                                                    round_robin_count == 4'b1000 ));
  // OVL_ASSERT_END

`endif //  `ifdef ARM_ASSERT_ON

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
