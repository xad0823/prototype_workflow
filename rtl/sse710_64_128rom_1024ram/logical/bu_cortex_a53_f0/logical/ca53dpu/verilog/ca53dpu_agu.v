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
// Abstract : Address Generation Unit (AGU) for load and store operations
//-----------------------------------------------------------------------------
//
// Overview
// --------
// The AGU calculates the memory address for a load and store operation. As
// well as calculating the VA from the address operands, the AGU contains the
// 10-entry micro TLB.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_agu (
  // Inputs
  input  wire                             clk,                        // Clock
  input  wire                             reset_n,                    // Reset
  input  wire                             DFTSE,                     
  input  wire                             aarch64_state_iss_i,        // Operating in AArch64
  input  wire                             agu_aa64_addr_iss_i,
  input  wire    [`CA53_SEL_DCU_A_W-1:0]  agu_data_a_sel_iss_i,       // DCU A data mux select
  input  wire    [`CA53_SEL_DCU_A_W-1:0]  agu_data_a_hi_sel_iss_i,    // DCU A data mux select (high 64 bits)
  input  wire  [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_a_iss_i,        // DCU A forwarding mux select
  input  wire                             sel_fwd_addr_dcu_a_iss_i,   // DCU A addr forwarding
  input  wire                     [63:0]  rf_rd_data_r0_agu_iss_i,    // RF read port A data
  input  wire                     [63:0]  rf_rd_data_r1_agu_iss_i,    // RF read port B data
  input  wire                     [63:1]  pc_instr0_iss_i,            // PC for instruction in slot 0 in iss
  input  wire                     [48:1]  pc_instr1_iss_i,            // PC for instruction in slot 1 in iss
  input  wire                             wd_align_pc_ls_iss_i,       // Force word align for PC base
  input  wire                             pg_align_pc_ls_iss_i,       // Force page align for PC base
  input  wire    [`CA53_SEL_DCU_B_W-1:0]  agu_data_b_sel_iss_i,       // DCU B data mux select
  input  wire  [`CA53_SEL_FWD_DCU_W-1:0]  sel_fwd_dcu_b_iss_i,        // DCU B forwarding mux select
  input  wire                     [32:0]  imm_data_ls_iss_i,          // Immediate offset
  input  wire                             slot1_ls_iss_i,             // Instruction is in Slot 1
  input  wire                     [63:0]  fwd_ld_data_agu_wr_i,       // Forward data - Load
  input  wire                     [63:0]  alu0_fwd_data_early_ex2_i,  // Forward data - ALU0
  input  wire                     [63:0]  alu1_fwd_data_early_ex2_i,  // Forward data - ALU1
  input  wire                     [63:0]  alu0_fwd_data_early_wr_i,   // Forward data - ALU0
  input  wire                     [63:0]  alu1_fwd_data_early_wr_i,   // Forward data - ALU1
  input  wire                      [2:0]  agu_shf_value_iss_i,        // Shift amount
  input  wire                             agu_sub_b_iss_i,            // Add or subtract B operand
  input  wire                             ls_valid_iss_i,             // Valid load/store request
  input  wire                             ls_valid_fwd_iss_i,         // Valid load/store request
  input  wire                             ls_store_iss_i,             // Valid store request
  input  wire                      [2:0]  ls_size_iss_i,              // Size of current transaction
  input  wire                      [2:0]  ls_elem_size_iss_i,         // Element size within current transaction
  input  wire                             check_x64_iss_i,            // Check for x64
  input  wire                     [63:0]  fwd_addr_i,                 // Recirculated address
  input  wire                             ls_multiple_iss_i,          // Instruction is part of a multiple
  input  wire                      [5:0]  ls_length_iss_i,            // LSM length
  input  wire                             lsm_skidding_i,             // LSM skidding
  input  wire                             dczva_iss_i,               
  input  wire                             dpu_valid_iss_i,            // DPU can transmit a transaction
  input  wire                             flush_ls_wr_i,             
  input  wire                             dcu_ready_iss_i,            // DCU can receive a transaction
  input  wire                             clean_dcu_ready_iss_i,      // DCU can receive a transaction (Qualified)
  input  wire                             subseq_x64_iss_i,
  input  wire                             last_x64_iss_i,
  input  wire                             ls_check_stack_iss_i,       // Check for misaligned base register
  input  wire                             head_instr_ls_iss_i,       
  input  wire                             ldar_stlr_iss_i,
  input  wire                             cp_op_ats1_iss_i,           // CP15 operation accessing secure state
  input  wire                             cp_iss_i,                   // CP15 operation for the ldst pipeline
  input  wire                             cp_other_sec_iss_i,         // CP15 operation accessing other security state
  input  wire                             tlb_d_utlb_enable_i,        // Enable from the main TLB to the uTLB
  input  wire                             tlb_d_utlb_might_enable_i,  // Speculative enable from the main TLB to the uTLB
  input  wire                             tlb_d_utlb_valid_i,         // Indicate that the TLB entry is valid
  input  wire                             tlb_d_utlb_lpae_i,          // The format of the entry being written is LPAE.
  input  wire                     [95:0]  tlb_d_utlb_data_i,          // Page from the main TLB to the uTLB
  input  wire                             tlb_d_utlb_flush_i,         // Flush all uTLB entries (from TLB)
  input  wire                             tlb_lpae_mode_i,            // LPAE format of uTLB entries
  input  wire                     [31:0]  dpu_dacr_i,                 // CP15 DACR register (current security state)
  input  wire                     [31:0]  dpu_dacr_ns_i,              // CP15 DACR register (non-secure state)
  input  wire                             dpu_default_cacheable_i,    // Default Cacheable
  input  wire                             dpu_dacr_mmu_on_i,          // SCTLR.M bit associated with the current DACR
  input  wire                             dpu_mmu_on_el1_i,           // Non-secure SCTLR.M bit
  input  wire                             flush_d_utlb_i,
  input  wire                             ns_state_i,
  input  wire                      [1:0]  dpu_exception_level_i,
  // Outputs
  output wire                     [48:6]  dpu_agu_a_operand_iss_o,
  output wire                     [48:6]  dpu_agu_b_operand_iss_o,
  output wire                             dpu_agu_carry_out_64b_iss_o,
  output wire                     [63:0]  va_iss_o,
  output wire                             align_64_iss_o,
  output wire                             align_128_iss_o,
  output reg                              first_x64_iss_o,            // Transaction crosses a 64-bit boundary
  output wire                             lsm_unaligned64_iss_o,      // Transaction is an unaligned LSM
  output wire                             ldr_no_early_fwd_iss_o,     // Transaction is an unaligned LDR, which can't use the Early Wr path
  output wire                             on_64b_boundary_iss_o,      // Address is the start of a new cache line
  output reg                      [15:0]  dpu_strobe_iss_o,           // Read/Write strobes
  output wire                             dpu_utlb_hit_dc1_o,         // Micro TLB hit signal
  output wire                      [3:0]  dpu_utlb_hit_entry_dc1_o,   // Micro TLB entry hit
  output wire                     [39:12] dpu_pa_dc1_o,               // Physical address
  output wire                     [12:0]  dpu_attributes_dc1_o,       // Micro TLB attributes
  output wire                      [8:0]  dpu_fault_dc1_o,            // Micro TLB fault information
  output wire                             dpu_ns_dsc_dc1_o,           // Micro TLB non-secure signal
  output wire                      [3:0]  dpu_domain_dc1_o,           // Micro TLB domain
  output wire                             dpu_abort_dc1_o,            // Micro TLB abort
  output wire                      [3:0]  dpu_level_dc1_o,            // Micro TLB level
  output wire                             dpu_lpae_dc1_o,             // Micro TLB lpae mode
  output reg                              dpu_stack_align_expt_dc1_o  // Stack pointer check caused exception
);

  // -------------------------------
  // Variables
  // -------------------------------

  genvar n; // entry number used in generate loops

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg    [4:0]  agu_shf_ctl_iss;
  reg           cp_other_sec_dc1;
  reg           domain_fault_en_dc1;
  reg    [9:0]  entry_hit_dc1;
  reg    [3:0]  round_robin_count;
  reg    [8:0]  round_robin;
  reg   [15:0]  spec_strobe_second_x64;
  reg   [15:0]  spec_strobe_addr0;
  reg   [15:0]  spec_strobe_addr1;
  reg   [15:0]  spec_strobe_addr2;
  reg   [15:0]  spec_strobe_addr3;
  reg   [15:0]  spec_strobe_addr4;
  reg   [15:0]  spec_strobe_addr5;
  reg   [15:0]  spec_strobe_addr6;
  reg   [15:0]  spec_strobe_addr7;
  reg   [15:0]  spec_strobe_addr8;
  reg   [15:0]  spec_strobe_addr9;
  reg   [15:0]  spec_strobe_addr10;
  reg   [15:0]  spec_strobe_addr11;
  reg   [15:0]  spec_strobe_addr12;
  reg   [15:0]  spec_strobe_addr13;
  reg   [15:0]  spec_strobe_addr14;
  reg   [15:0]  spec_strobe_addr15;
  reg           utlb_write_iss;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire          clk_dutlb;
  wire          va_low_carry_in;
  wire  [63:0]  pc_align_mask;
  wire  [63:0]  pc0_base_iss;
  wire  [63:0]  pc1_base_iss;
  wire          sel_instr1_pc;
  wire  [63:0]  agu_b_imm;
  wire  [63:0]  agu_a_operand;
  wire  [63:0]  agu_b_operand;
  wire  [48:12] agu_a_xor_agu_b;
  wire  [47:12] agu_a_and_agu_b;
  wire  [63:0]  agu_b_mux_operand;
  wire          agu_b_mux_sxt;
  wire  [66:0]  agu_a_operand_adder;
  wire  [66:0]  agu_b_operand_adder;
  wire  [63:0]  agu_result_adder;
  wire          store_128bit;
  wire          store_128bit_load_64bit;
  wire          store_128bit_load_64bit_32bit;
  wire          store_128bit_load_64bit_32bit_16bit;
  wire          access_128bit_64bit;
  wire          access_128bit_64bit_32bit;
  wire          access_128bit_64bit_32bit_16bit;
  wire  [63:0]  agu_b_add4;
  wire  [63:0]  agu_b_add8;
  wire          ncarry_4k;
  wire          ncarry_aa32; // Unused but required for breaking AA32 carry out from adder
  wire          ncarry_64b;
  wire          carry_out_4k;
  wire          domain_fault_en_iss;
  wire          enable_hit_entry_dc1;
  wire  [39:12] entry_pa_dc1    [9:0];  // Physical address for uTLB entry
  wire  [12:0]  entry_attr_dc1  [9:0];  // Attributes for uTLB entry
  wire   [3:0]  entry_level_dc1 [9:0];  // Level for uTLB entry0
  wire   [9:0]  entry_ns_dsc_dc1;       // Non-secure for uTLB entry0
  wire   [9:0]  raw_entry_hit_iss;      // Hit signal for uTLB entry0-9
  wire   [9:0]  entry_hit_iss;          // - qualified with flush etc.
  wire   [3:0]  entry0_domain_dc1;      // Domain for uTLB entry0
  wire          entry0_abort_dc1;       // Abort for uTLB entry0
  wire   [8:0]  entry0_fault_dc1;       // Fault information for uTLB entry0
  wire          entry0_lpae_dc1;        // LPAE mode for uTLB entry0
  wire   [9:0]  sel_entry_dc1;          // Select uTLB entry
  wire          agu_wants_rf_on_port_a_lo;
  wire          agu_wants_rf_on_port_a_hi;
  wire          agu_wants_fwd_on_port_a_lo;
  wire          agu_wants_fwd_on_port_a_hi;
  wire          agu_wants_rf_on_port_b;
  wire          agu_wants_rf_on_port_b_64b;
  wire          agu_wants_rf_on_port_b_sxt;
  wire  [15:0]  final_spec_strobe_second_x64;
  wire          next_utlb_write_iss;
  wire   [9:0]  entry_valid;
  wire   [9:0]  nxt_utlb_entry_valid;
  wire   [9:0]  utlb_entry_enable;
  wire          utlb_valid_enable;
  wire  [82:0]  entry0_data;
  wire          round_robin_en;
  wire   [3:0]  next_round_robin_count;
  wire  [31:0]  transl_dacr;
  wire          transl_mmu_on;
  wire          valid_x64;
  wire   [3:0]  agu_b_operand_shf;
  wire   [3:0]  x64_calc;
  wire   [2:0]  unaligned_calc;
  wire          valid_might_enable;
  wire          align_128_iss;
  wire          align_64_iss;
  wire          stack_align_expt_iss;

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
  ca53_cell_inter_clkgate u_inter_clkgate_dutlb (
    .clk_i         (clk),
    .clk_enable_i  (tlb_d_utlb_might_enable_i),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_dutlb)
  );

  // ------------------------------------------------------
  // Generate the A-operand for the AGU calculation
  // ------------------------------------------------------

  // Force PC value to be word/page aligned if required
  assign pc_align_mask = { {52{1'b1}}, {10{~pg_align_pc_ls_iss_i}}, {2{~wd_align_pc_ls_iss_i}} };
  
  assign pc0_base_iss = {                            pc_instr0_iss_i[63:1], 1'b0} & pc_align_mask;
  assign pc1_base_iss = { {15{pc_instr1_iss_i[48]}}, pc_instr1_iss_i[48:1], 1'b0} & pc_align_mask;

  // Normally a slot 0 LS will use the instr0 PC and a slot 1 LS will use the instr1 PC
  // However, if the LS is receiving ADRP forwarding, then use the instr0 PC regardless,
  // as cannot detect if a dual-issued ADRP/LS pair straddle a page boundary in decode
  assign sel_instr1_pc = slot1_ls_iss_i & ~pg_align_pc_ls_iss_i;

  // Indicate that the AGU wants to use the register file (or forwarding path) on port-A.
  // The ls_valid qualification is purely to reduce power in the AGU due to the main adder
  // and a+b=k adders toggling when the register file value changes.
  assign agu_wants_rf_on_port_a_lo = (ls_valid_fwd_iss_i &
                                      (agu_data_a_sel_iss_i    == `CA53_SEL_DCU_A_R0) & ~sel_fwd_addr_dcu_a_iss_i);

  assign agu_wants_rf_on_port_a_hi = (ls_valid_fwd_iss_i &
                                      (agu_data_a_hi_sel_iss_i == `CA53_SEL_DCU_A_R0) & ~sel_fwd_addr_dcu_a_iss_i);

  assign agu_wants_fwd_on_port_a_lo = (agu_data_a_sel_iss_i    == `CA53_SEL_DCU_A_MUL) | sel_fwd_addr_dcu_a_iss_i;

  assign agu_wants_fwd_on_port_a_hi = (agu_data_a_hi_sel_iss_i == `CA53_SEL_DCU_A_MUL) | sel_fwd_addr_dcu_a_iss_i;

  // Main operand a mux
  assign agu_a_operand[31: 0] = // RF source data after forwarding - RF source data
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_NOF    ] & agu_wants_rf_on_port_a_lo)}} & rf_rd_data_r0_agu_iss_i[31: 0])   |
                                // RF source data after forwarding - ALU1
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_WR ] & agu_wants_rf_on_port_a_lo)}} & alu1_fwd_data_early_wr_i[31: 0])  |
                                // RF source data after forwarding - ALU0              
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_WR ] & agu_wants_rf_on_port_a_lo)}} & alu0_fwd_data_early_wr_i[31: 0])  |
                                // RF source data after forwarding - Load data Wr stage
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W0F_WR ] & agu_wants_rf_on_port_a_lo)}} & fwd_ld_data_agu_wr_i[31: 0])      |
                                // RF source data after forwarding - ALU1 early Ex2
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_EX2] & agu_wants_rf_on_port_a_lo)}} & alu1_fwd_data_early_ex2_i[31: 0]) |
                                // RF source data after forwarding - ALU0 early Ex2
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_EX2] & agu_wants_rf_on_port_a_lo)}} & alu0_fwd_data_early_ex2_i[31: 0]) |
                                // Use previous address for single misaligned or load/store multiple
                                ({32{                                                      agu_wants_fwd_on_port_a_lo}} & fwd_addr_i[31: 0])                |
                                // Word aligned PC
                                // - slot 0
                                ({32{(agu_data_a_sel_iss_i    == `CA53_SEL_DCU_A_PC) & ~sel_instr1_pc                }} & pc0_base_iss[31: 0])              |
                                // - slot 1
                                ({32{(agu_data_a_sel_iss_i    == `CA53_SEL_DCU_A_PC) &  sel_instr1_pc                }} & pc1_base_iss[31: 0]);

  assign agu_a_operand[63:32] = // RF source data after forwarding - RF source data
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_NOF    ] & agu_wants_rf_on_port_a_hi)}} & rf_rd_data_r0_agu_iss_i[63:32])   |
                                // RF source data after forwarding - ALU1
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_WR ] & agu_wants_rf_on_port_a_hi)}} & alu1_fwd_data_early_wr_i[63:32])  |
                                // RF source data after forwarding - ALU0
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_WR ] & agu_wants_rf_on_port_a_hi)}} & alu0_fwd_data_early_wr_i[63:32])  |
                                // RF source data after forwarding - Load data Wr stage
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W0F_WR ] & agu_wants_rf_on_port_a_hi)}} & fwd_ld_data_agu_wr_i[63:32])      |
                                // RF source data after forwarding - ALU1 early ex2
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_EX2] & agu_wants_rf_on_port_a_hi)}} & alu1_fwd_data_early_ex2_i[63:32]) |
                                // RF source data after forwarding - ALU0 early ex2
                                ({32{(sel_fwd_dcu_a_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_EX2] & agu_wants_rf_on_port_a_hi)}} & alu0_fwd_data_early_ex2_i[63:32]) |
                                // Use previous address for single misaligned or load/store multiple
                                ({32{                                                      agu_wants_fwd_on_port_a_hi}} & fwd_addr_i[63:32])                |
                                // Word aligned PC
                                // - slot 0
                                ({32{(agu_data_a_hi_sel_iss_i == `CA53_SEL_DCU_A_PC) & ~sel_instr1_pc                }} & pc0_base_iss[63:32])              |
                                // - slot 1
                                ({32{(agu_data_a_hi_sel_iss_i == `CA53_SEL_DCU_A_PC) &  sel_instr1_pc                }} & pc1_base_iss[63:32]);

  // ------------------------------------------------------
  // Generate the B-operand for the AGU calculation
  // ------------------------------------------------------

  // The B-operand can specify that the register offset is shifted and
  // used in the calculations for the memory address.
  // Currently if the shift specified is {0,1,2,3,4} to the left, then is done
  // within the AGU in the same cycle as the memory address being
  // generated. Any other value of shift is done in the ALU pipeline first
  // and the results forwarded from the SH forwarding point to the AGU.
  always @*
    case (agu_shf_value_iss_i[2:0])
      3'b000:  agu_shf_ctl_iss[4:0] = 5'b00001; // no shift
      3'b001:  agu_shf_ctl_iss[4:0] = 5'b00010; // shift one bit
      3'b010:  agu_shf_ctl_iss[4:0] = 5'b00100; // shift two bits
      3'b011:  agu_shf_ctl_iss[4:0] = 5'b01000; // shift three bits
      3'b100:  agu_shf_ctl_iss[4:0] = 5'b10000; // shift four bits
      default: agu_shf_ctl_iss[4:0] = 5'bxxxxx;
    endcase

  // If the memory address generation requires the immediate offset to be
  // subtracted from the base address, then form a 1's complement of the
  // immediate value and set the carry_input to the lower adder to be one.
  // Note: this subtraction can only be done for immediate offsets
  // Treat immediate as signed for A64 - subtract should not be set in
  // this case
  assign agu_b_imm = { {32{agu_sub_b_iss_i | imm_data_ls_iss_i[32]}},
                       (agu_sub_b_iss_i ? ~imm_data_ls_iss_i[31:0] : imm_data_ls_iss_i[31:0])};

  assign va_low_carry_in = agu_sub_b_iss_i ? 1'b1 : 1'b0;

  // Add 4 for next address - used for the first cycle of some variants of Load-Store multiples and SRS/RFE
  assign agu_b_add4[63:0] = agu_sub_b_iss_i ? {{60{1'b1}}, 4'b1011} : {{60{1'b0}}, 4'b0100};

  // Add 8 for the next address - used for subsequent cycles of load-store multiples
  assign agu_b_add8[63:0] = agu_sub_b_iss_i                     ? {{60{1'b1}}, 4'b0111} :
                            (ls_store_iss_i & subseq_x64_iss_i) ? {{59{1'b0}}, 5'b10000}  // x128 store => +16
                                                                : {{59{1'b0}}, 5'b01000}; // x64  load/LSM  => +8

  // Indicate that the AGU wants to use the register file (or forwarding path) on port-B.
  // The ls_valid qualification is purely to reduce power in the AGU due to the main adder
  // and a+b=k adders toggling when the register file value changes.
  assign agu_wants_rf_on_port_b = ls_valid_fwd_iss_i & agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_R1];

  // In A64, the register offset operand can be 64-bit, or zero or sign extended from 32-bit
  assign agu_wants_rf_on_port_b_64b = agu_wants_rf_on_port_b &  agu_data_b_sel_iss_i[4];
  assign agu_wants_rf_on_port_b_sxt = agu_wants_rf_on_port_b & (agu_data_b_sel_iss_i[5:4] == 2'b10);

  // Main operand b mux
  assign agu_b_mux_operand[31: 0] = // RF source data after forwarding - RF source data
                                    ({32{ sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_NOF    ] & agu_wants_rf_on_port_b}}    & rf_rd_data_r1_agu_iss_i[31:0])       |
                                    // RF source data after forwarding - ALU1 early Wr                                 
                                    ({32{ sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_WR ] & agu_wants_rf_on_port_b}}    & alu1_fwd_data_early_wr_i[31:0])      |
                                    // RF source data after forwarding - ALU0 early Wr                                 
                                    ({32{ sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_WR ] & agu_wants_rf_on_port_b}}    & alu0_fwd_data_early_wr_i[31:0])      |
                                    // RF source data after forwarding - Load data Wr stage                           
                                    ({32{ sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W0F_WR ] & agu_wants_rf_on_port_b}}    & fwd_ld_data_agu_wr_i[31:0])          |
                                    // RF source data after forwarding - ALU1 early Ex2
                                    ({32{ sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_EX2] & agu_wants_rf_on_port_b}}    & alu1_fwd_data_early_ex2_i[31:0])     |
                                    // RF source data after forwarding - ALU0 early Ex2
                                    ({32{(sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_EX2] & agu_wants_rf_on_port_b) |
                                    // Shifter forwarding path
                                         agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_SH]}}                                    & alu0_fwd_data_early_ex2_i[31:0])     |
                                    // 32-bit immediate (actually imm_dp)
                                    ({32{agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_IMM_LS]}}                                & agu_b_imm[31:0])                     |
                                    // Load-Store multiple & cross-64 - add/subtract 8 for next address
                                    ({32{agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_PM_8] |
                                         (agu_data_b_sel_iss_i[6:4] == 3'b111)}}                                           & agu_b_add8[31:0])                    |
                                    // Load-Store multiple & SRS/RFE - add/subtract 4 for next address
                                    ({32{agu_data_b_sel_iss_i[6:4] == 3'b110}}                                             & agu_b_add4[31:0])                    |
                                    // Neon 16-bit load/store - add 2
                                    ({32{agu_data_b_sel_iss_i[6:4] == 3'b101}}                                             & 32'h0000_0002)                       |
                                    // 128-bit multiples - add 16
                                    ({32{agu_data_b_sel_iss_i[6:4] == 3'b100}}                                             & 32'h0000_0010);

  assign agu_b_mux_operand[63:32] = // RF source data after forwarding - RF source data
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_NOF    ] & agu_wants_rf_on_port_b_64b}} & rf_rd_data_r1_agu_iss_i[63:32])      |
                                    // RF source data after forwarding - ALU1
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_WR ] & agu_wants_rf_on_port_b_64b}} & alu1_fwd_data_early_wr_i[63:32])     |
                                    // RF source data after forwarding - ALU0             
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_WR ] & agu_wants_rf_on_port_b_64b}} & alu0_fwd_data_early_wr_i[63:32])     |
                                    // RF source data after forwarding - Load data Wr stage
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W0F_WR ] & agu_wants_rf_on_port_b_64b}} & fwd_ld_data_agu_wr_i[63:32])         |
                                    // RF source data after forwarding - ALU1 early Ex2
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_EX2] & agu_wants_rf_on_port_b_64b}} & alu1_fwd_data_early_ex2_i[63:32])    |
                                    // RF source data after forwarding - ALU0 early Ex2
                                    ({32{sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_EX2] & agu_wants_rf_on_port_b_64b}} & alu0_fwd_data_early_ex2_i[63:32])    |
                                    // 32-bit immediate (actually imm_dp)
                                    ({32{agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_IMM_LS] & aarch64_state_iss_i}}          & agu_b_imm[63:32])                    |
                                    // Load-Store multiple & cross-64 - add/subtract 8 for next address
                                    ({32{(agu_data_b_sel_iss_i[`CA53_SEL_DCU_B_BIT_PM_8] |
                                          (agu_data_b_sel_iss_i[6:4] == 3'b111)) & aarch64_state_iss_i}}                   & agu_b_add8[63:32])                   |
                                    // Load-Store multiple & SRS/RFE - add/subtract 4 for next address
                                    ({32{(agu_data_b_sel_iss_i[6:4] == 3'b110) & aarch64_state_iss_i}}                     & agu_b_add4[63:32])                   |
                                    // Sign-extension for 32b read - only use four bits here, apply the others post-shift
                                    ({ {28{1'b0}}, {4{agu_b_mux_sxt}} });

  assign agu_b_mux_sxt            = // RF source data after forwarding - RF source data
                                    (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_NOF    ] & agu_wants_rf_on_port_b_sxt & rf_rd_data_r1_agu_iss_i[31])   |
                                    // RF source data after forwarding - ALU1
                                    (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_WR ] & agu_wants_rf_on_port_b_sxt & alu1_fwd_data_early_wr_i[31])  |
                                    // RF source data after forwarding - ALU0             
                                    (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_WR ] & agu_wants_rf_on_port_b_sxt & alu0_fwd_data_early_wr_i[31])  |
                                    // RF source data after forwarding - ALU1 early Ex2
                                    (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W2F_EX2] & agu_wants_rf_on_port_b_sxt & alu1_fwd_data_early_ex2_i[31]) |
                                    // RF source data after forwarding - ALU0 early Ex2
                                    (sel_fwd_dcu_b_iss_i[`CA53_SEL_FWD_DCU_BIT_W1F_EX2] & agu_wants_rf_on_port_b_sxt & alu0_fwd_data_early_ex2_i[31]);

  // Shift the B operand
  assign agu_b_operand[31: 0] = ({32{agu_shf_ctl_iss[0]}} &  agu_b_mux_operand[31:0])          |  // no shift required
                                ({32{agu_shf_ctl_iss[1]}} & {agu_b_mux_operand[30:0], 1'b0})   |  // left shift, one bit
                                ({32{agu_shf_ctl_iss[2]}} & {agu_b_mux_operand[29:0], 2'b00})  |  // left shift, two bits
                                ({32{agu_shf_ctl_iss[3]}} & {agu_b_mux_operand[28:0], 3'b000}) |  // left shift, three bits
                                ({32{agu_shf_ctl_iss[4]}} & {agu_b_mux_operand[27:0], 4'b0000});  // left shift, four bits

  // Only need to mask those bits which shift over the 32bit boundary
  assign agu_b_operand[63:32] = (  {32{agu_shf_ctl_iss[0]}}                                                  & agu_b_mux_operand[63:32]) | // no shift required
                                ({ {31{agu_shf_ctl_iss[1]}},    aarch64_state_iss_i & agu_shf_ctl_iss[1]   } & agu_b_mux_operand[62:31]) | // left shift, one bit
                                ({ {30{agu_shf_ctl_iss[2]}}, {2{aarch64_state_iss_i & agu_shf_ctl_iss[2]}} } & agu_b_mux_operand[61:30]) | // left shift, two bits
                                ({ {29{agu_shf_ctl_iss[3]}}, {3{aarch64_state_iss_i & agu_shf_ctl_iss[3]}} } & agu_b_mux_operand[60:29]) | // left shift, three bits
                                ({ {28{agu_shf_ctl_iss[4]}}, {4{aarch64_state_iss_i & agu_shf_ctl_iss[4]}} } & agu_b_mux_operand[59:28]) | // left shift, four bits
                                ({ {28{agu_b_mux_sxt}}, {4{1'b0}} });                                                                      // Sign-extension, upper bits

  // ------------------------------------------------------
  // Cache line determination
  // ------------------------------------------------------

  assign on_64b_boundary_iss_o = (agu_result_adder[5:3] & {2'b11, ~align_128_iss}) == 3'b000;

  // ------------------------------------------------------
  // Cross-64 and unaligned determination
  // ------------------------------------------------------
  //
  // When the address and size of an access mean it crosses a
  // naturally aligned 64-/128-bit boundary (for loads and
  // stores respectively), the access must be split up and
  // sent to the DCU in multiple parts.

  // Identify instructions for which a x64 check is valid
  assign valid_x64 = ls_valid_iss_i & check_x64_iss_i & ~subseq_x64_iss_i;

  assign store_128bit                         = ls_size_iss_i[2];
  assign store_128bit_load_64bit              = (ls_size_iss_i[1:0] == `CA53_LDST_SIZE_DWORD) & (~ls_store_iss_i | ls_size_iss_i[2]);
  assign store_128bit_load_64bit_32bit        =  ls_size_iss_i[1]                           & (~ls_store_iss_i | ls_size_iss_i[2]);
  assign store_128bit_load_64bit_32bit_16bit  = (ls_size_iss_i[1:0] != `CA53_LDST_SIZE_BYTE)  & (~ls_store_iss_i | ls_size_iss_i[2]);
  assign access_128bit_64bit                  = (ls_size_iss_i[1:0] == `CA53_LDST_SIZE_DWORD);
  assign access_128bit_64bit_32bit            =  ls_size_iss_i[1];
  assign access_128bit_64bit_32bit_16bit      = (ls_size_iss_i[1:0] != `CA53_LDST_SIZE_BYTE);

  assign agu_b_operand_shf[3:0] = ({4{agu_shf_ctl_iss[0]}} &  agu_b_mux_operand[3:0])         |
                                  ({4{agu_shf_ctl_iss[1]}} & {agu_b_mux_operand[2:0], 1'b0})  |
                                  ({4{agu_shf_ctl_iss[2]}} & {agu_b_mux_operand[1:0], 2'b00}) |
                                  ({4{agu_shf_ctl_iss[3]}} & {agu_b_mux_operand[  0], 3'b000});

  assign x64_calc[3:0] = agu_a_operand[3:0] + agu_b_operand_shf[3:0];

  always @*
    case (x64_calc[3:0])
      // In lower DWord of QWord, loads can go x64 and 128-bit stores can go x128
      4'b0000  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? store_128bit_load_64bit             : 1'b0);
      4'b0001  : first_x64_iss_o = valid_x64 & (                                                        store_128bit_load_64bit);
      4'b0010  : first_x64_iss_o = valid_x64 & (                                                        store_128bit_load_64bit);
      4'b0011  : first_x64_iss_o = valid_x64 & (                                                        store_128bit_load_64bit);
      4'b0100  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? store_128bit_load_64bit_32bit       : store_128bit_load_64bit);
      4'b0101  : first_x64_iss_o = valid_x64 & (                                                        store_128bit_load_64bit_32bit);
      4'b0110  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? store_128bit_load_64bit_32bit_16bit : store_128bit_load_64bit_32bit);
      4'b0111  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? store_128bit                        : store_128bit_load_64bit_32bit_16bit);
      // In upper DWord, loads and stores can go x128
      4'b1000  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? access_128bit_64bit                 : store_128bit);
      4'b1001  : first_x64_iss_o = valid_x64 & (                                                        access_128bit_64bit);
      4'b1010  : first_x64_iss_o = valid_x64 & (                                                        access_128bit_64bit);
      4'b1011  : first_x64_iss_o = valid_x64 & (                                                        access_128bit_64bit);
      4'b1100  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? access_128bit_64bit_32bit           : access_128bit_64bit);
      4'b1101  : first_x64_iss_o = valid_x64 & (                                                        access_128bit_64bit_32bit);
      4'b1110  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? access_128bit_64bit_32bit_16bit     : access_128bit_64bit_32bit);
      4'b1111  : first_x64_iss_o = valid_x64 & (va_low_carry_in ? 1'b0                                : access_128bit_64bit_32bit_16bit);
      default  : first_x64_iss_o = 1'bx;
  endcase

  // Indicate that the address is possibly word aligned, but definately not double word-aligned.
  // No need look for byte or half-word alignment since this will take a data-abort.  Since the
  // LSM instructions won't shift the pre-shift B-operand can be used since it is faster.
  assign unaligned_calc[2:0] = agu_a_operand[2:0] + agu_b_mux_operand[2:0] + va_low_carry_in;

  assign lsm_unaligned64_iss_o = ls_multiple_iss_i & unaligned_calc[2];

  // If the instruction is a load and is not 32-bit and word aligned (in AArch32) or 64-bit
  // and doubleword aligned (in AArch64) then the "when" signals in the interlocking logic
  // must be adjusted from Early-Wr (which can forward to the AGU) to Late-Wr (which can not
  // forward to the AGU).  This approach allows a faster load swizzling path to be 
  // implemented that only supports aligned pointer chasing.
  assign ldr_no_early_fwd_iss_o = ls_valid_iss_i & ~ls_store_iss_i & 
                                  (aarch64_state_iss_i ? ((ls_elem_size_iss_i[1:0] != `CA53_LDST_SIZE_DWORD) | (|agu_result_adder[2:0]))
                                                       : ((ls_size_iss_i[1:0]      != `CA53_LDST_SIZE_WORD)  | (|agu_result_adder[1:0])));

  // ------------------------------------------------------
  // Stack pointer alignment check
  // ------------------------------------------------------
  // The SCTLR stack pointer alignment checking enable bits, execution state, and whether an
  // instruction is using the stack pointer, is checked in De and pipelined on ls_check_stack.
  // Therefore here just need to check whether the base address for an AGU calculation (i.e.
  // the stack pointer) is not quad-word aligned.
  // On subsequent beats of x64/x128s and multiples, the address of the previous beat is
  // looped back to calculate the next address, so agu_a_operand is not the SP in this case
  // (it sufficient just to calculate the alignment on the first beat).
  assign stack_align_expt_iss = ls_valid_iss_i & ls_check_stack_iss_i & head_instr_ls_iss_i &
                                (agu_a_operand[3:0] != 4'b0000);

  // ------------------------------------------------------
  // Store byte strobe determination
  // ------------------------------------------------------

  // Speculative strobes that can be chosen by the AGU result
  always @*
    begin
      spec_strobe_addr0   = {16{1'b0}};
      spec_strobe_addr1   = {16{1'b0}};
      spec_strobe_addr2   = {16{1'b0}};
      spec_strobe_addr3   = {16{1'b0}};
      spec_strobe_addr4   = {16{1'b0}};
      spec_strobe_addr5   = {16{1'b0}};
      spec_strobe_addr6   = {16{1'b0}};
      spec_strobe_addr7   = {16{1'b0}};
      spec_strobe_addr8   = {16{1'b0}};
      spec_strobe_addr9   = {16{1'b0}};
      spec_strobe_addr10  = {16{1'b0}};
      spec_strobe_addr11  = {16{1'b0}};
      spec_strobe_addr12  = {16{1'b0}};
      spec_strobe_addr13  = {16{1'b0}};
      spec_strobe_addr14  = {16{1'b0}};
      spec_strobe_addr15  = {16{1'b0}};

      case (ls_size_iss_i[1:0])
        `CA53_LDST_SIZE_BYTE : begin
          spec_strobe_addr0   = 16'b0000_0000_0000_0001;
          spec_strobe_addr1   = 16'b0000_0000_0000_0010;
          spec_strobe_addr2   = 16'b0000_0000_0000_0100;
          spec_strobe_addr3   = 16'b0000_0000_0000_1000;
          spec_strobe_addr4   = 16'b0000_0000_0001_0000;
          spec_strobe_addr5   = 16'b0000_0000_0010_0000;
          spec_strobe_addr6   = 16'b0000_0000_0100_0000;
          spec_strobe_addr7   = 16'b0000_0000_1000_0000;
          spec_strobe_addr8   = 16'b0000_0001_0000_0000;
          spec_strobe_addr9   = 16'b0000_0010_0000_0000;
          spec_strobe_addr10  = 16'b0000_0100_0000_0000;
          spec_strobe_addr11  = 16'b0000_1000_0000_0000;
          spec_strobe_addr12  = 16'b0001_0000_0000_0000;
          spec_strobe_addr13  = 16'b0010_0000_0000_0000;
          spec_strobe_addr14  = 16'b0100_0000_0000_0000;
          spec_strobe_addr15  = 16'b1000_0000_0000_0000;
        end
        `CA53_LDST_SIZE_HWORD : begin
          spec_strobe_addr0   = 16'b0000_0000_0000_0011;
          spec_strobe_addr1   = 16'b0000_0000_0000_0110;
          spec_strobe_addr2   = 16'b0000_0000_0000_1100;
          spec_strobe_addr3   = 16'b0000_0000_0001_1000;
          spec_strobe_addr4   = 16'b0000_0000_0011_0000;
          spec_strobe_addr5   = 16'b0000_0000_0110_0000;
          spec_strobe_addr6   = 16'b0000_0000_1100_0000;
          spec_strobe_addr7   = 16'b0000_0001_1000_0000 & {7'b1111111, ls_store_iss_i, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr8   = 16'b0000_0011_0000_0000;
          spec_strobe_addr9   = 16'b0000_0110_0000_0000;
          spec_strobe_addr10  = 16'b0000_1100_0000_0000;
          spec_strobe_addr11  = 16'b0001_1000_0000_0000;
          spec_strobe_addr12  = 16'b0011_0000_0000_0000;
          spec_strobe_addr13  = 16'b0110_0000_0000_0000;
          spec_strobe_addr14  = 16'b1100_0000_0000_0000;
          spec_strobe_addr15  = 16'b1000_0000_0000_0000;
        end
        `CA53_LDST_SIZE_WORD : begin
          spec_strobe_addr0   = ((ls_multiple_iss_i & (ls_length_iss_i[5:1] != 5'b00000)) |
                                 (lsm_skidding_i & ls_length_iss_i[0])) ? 16'b0000_0000_1111_1111 :
                                                                          16'b0000_0000_0000_1111;
          spec_strobe_addr1   = 16'b0000_0000_0001_1110;
          spec_strobe_addr2   = 16'b0000_0000_0011_1100;
          spec_strobe_addr3   = 16'b0000_0000_0111_1000;
          spec_strobe_addr4   = 16'b0000_0000_1111_0000;
          spec_strobe_addr5   = 16'b0000_0001_1110_0000 & {7'b1111111,    ls_store_iss_i  , 8'b1111_1111};  // Load will go x64
          spec_strobe_addr6   = 16'b0000_0011_1100_0000 & {6'b111111 , {2{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr7   = 16'b0000_0111_1000_0000 & {5'b11111  , {3{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr8   = ((ls_multiple_iss_i & (ls_length_iss_i[5:1] != 5'b00000)) |
                                 (lsm_skidding_i & ls_length_iss_i[0])) ? 16'b1111_1111_0000_0000 :
                                                                          16'b0000_1111_0000_0000;
          spec_strobe_addr9   = 16'b0001_1110_0000_0000;
          spec_strobe_addr10  = 16'b0011_1100_0000_0000;
          spec_strobe_addr11  = 16'b0111_1000_0000_0000;
          spec_strobe_addr12  = 16'b1111_0000_0000_0000;
          spec_strobe_addr13  = 16'b1110_0000_0000_0000;
          spec_strobe_addr14  = 16'b1100_0000_0000_0000;
          spec_strobe_addr15  = 16'b1000_0000_0000_0000;
        end
        `CA53_LDST_SIZE_DWORD : begin
          // Dword also used for 128-bit stores, so set strobes accordingly and mask off
          // upper strobes if only 64-bit access
          spec_strobe_addr0   = 16'b1111_1111_1111_1111 & {{8{ls_size_iss_i[2]}},                      8'b1111_1111};
          spec_strobe_addr1   = 16'b1111_1111_1111_1110 & {{7{ls_size_iss_i[2]}},    ls_store_iss_i  , 8'b1111_1111};  // Load will go x64
          spec_strobe_addr2   = 16'b1111_1111_1111_1100 & {{6{ls_size_iss_i[2]}}, {2{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr3   = 16'b1111_1111_1111_1000 & {{5{ls_size_iss_i[2]}}, {3{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr4   = 16'b1111_1111_1111_0000 & {{4{ls_size_iss_i[2]}}, {4{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr5   = 16'b1111_1111_1110_0000 & {{3{ls_size_iss_i[2]}}, {5{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr6   = 16'b1111_1111_1100_0000 & {{2{ls_size_iss_i[2]}}, {6{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr7   = 16'b1111_1111_1000_0000 & {   ls_size_iss_i[2]  , {7{ls_store_iss_i}}, 8'b1111_1111};  // Load will go x64
          spec_strobe_addr8   = 16'b1111_1111_0000_0000;
          spec_strobe_addr9   = 16'b1111_1110_0000_0000;
          spec_strobe_addr10  = 16'b1111_1100_0000_0000;
          spec_strobe_addr11  = 16'b1111_1000_0000_0000;
          spec_strobe_addr12  = 16'b1111_0000_0000_0000;
          spec_strobe_addr13  = 16'b1110_0000_0000_0000;
          spec_strobe_addr14  = 16'b1100_0000_0000_0000;
          spec_strobe_addr15  = 16'b1000_0000_0000_0000;
        end
        default : begin
          spec_strobe_addr0   = {16{1'bx}};
          spec_strobe_addr1   = {16{1'bx}};
          spec_strobe_addr2   = {16{1'bx}};
          spec_strobe_addr3   = {16{1'bx}};
          spec_strobe_addr4   = {16{1'bx}};
          spec_strobe_addr5   = {16{1'bx}};
          spec_strobe_addr6   = {16{1'bx}};
          spec_strobe_addr7   = {16{1'bx}};
          spec_strobe_addr8   = {16{1'bx}};
          spec_strobe_addr9   = {16{1'bx}};
          spec_strobe_addr10  = {16{1'bx}};
          spec_strobe_addr11  = {16{1'bx}};
          spec_strobe_addr12  = {16{1'bx}};
          spec_strobe_addr13  = {16{1'bx}};
          spec_strobe_addr14  = {16{1'bx}};
          spec_strobe_addr15  = {16{1'bx}};
        end
      endcase
    end

  // Strobes for second half of x64 load/x128 store
  always @*
    case (ls_size_iss_i[1:0])
      `CA53_LDST_SIZE_HWORD : spec_strobe_second_x64 = 16'b0000_0000_0000_0001;
      `CA53_LDST_SIZE_WORD: begin
        case (fwd_addr_i[1:0])
          2'b01: spec_strobe_second_x64 = 16'b0000_0000_0000_0001;
          2'b10: spec_strobe_second_x64 = 16'b0000_0000_0000_0011;
          2'b11: spec_strobe_second_x64 = 16'b0000_0000_0000_0111;
          default: spec_strobe_second_x64 = {16{1'bx}};
        endcase
      end
      `CA53_LDST_SIZE_DWORD: begin
        case ({(ls_size_iss_i[2] & fwd_addr_i[3]), fwd_addr_i[2:0]})
          4'b0_001: spec_strobe_second_x64 = 16'b0000_0000_0000_0001;
          4'b0_010: spec_strobe_second_x64 = 16'b0000_0000_0000_0011;
          4'b0_011: spec_strobe_second_x64 = 16'b0000_0000_0000_0111;
          4'b0_100: spec_strobe_second_x64 = 16'b0000_0000_0000_1111;
          4'b0_101: spec_strobe_second_x64 = 16'b0000_0000_0001_1111;
          4'b0_110: spec_strobe_second_x64 = 16'b0000_0000_0011_1111;
          4'b0_111: spec_strobe_second_x64 = 16'b0000_0000_0111_1111;
          4'b1_000: spec_strobe_second_x64 = 16'b0000_0000_1111_1111;
          4'b1_001: spec_strobe_second_x64 = 16'b0000_0001_1111_1111;
          4'b1_010: spec_strobe_second_x64 = 16'b0000_0011_1111_1111;
          4'b1_011: spec_strobe_second_x64 = 16'b0000_0111_1111_1111;
          4'b1_100: spec_strobe_second_x64 = 16'b0000_1111_1111_1111;
          4'b1_101: spec_strobe_second_x64 = 16'b0001_1111_1111_1111;
          4'b1_110: spec_strobe_second_x64 = 16'b0011_1111_1111_1111;
          4'b1_111: spec_strobe_second_x64 = 16'b0111_1111_1111_1111;
          default: spec_strobe_second_x64 = {16{1'bx}};
        endcase
      end
      default: spec_strobe_second_x64 = {16{1'bx}};
    endcase

  // - Load to lower DWord crosses into upper DWord
  // - Load to upper DWord and all stores cross 128-bit boundary into next QWord
  assign final_spec_strobe_second_x64 = (~ls_store_iss_i & ~fwd_addr_i[3]) ? {spec_strobe_second_x64[7:0], 8'b0000_0000}
                                                                           : spec_strobe_second_x64;

  // Select speculative strobe
  // - on DCZVA need strobes to be aligned even if using unaligned address, as
  // DCU will align when sending to STB
  always @*
    begin
      case ({4{~subseq_x64_iss_i & ~dczva_iss_i}} & agu_result_adder[3:0])
        4'b0000  : dpu_strobe_iss_o = last_x64_iss_i          ? final_spec_strobe_second_x64 :
                                      (agu_result_adder[3] &
                                       ~ls_store_iss_i)       ? spec_strobe_addr8            :
                                                                spec_strobe_addr0;
        4'b0001  : dpu_strobe_iss_o = spec_strobe_addr1;
        4'b0010  : dpu_strobe_iss_o = spec_strobe_addr2;
        4'b0011  : dpu_strobe_iss_o = spec_strobe_addr3;
        4'b0100  : dpu_strobe_iss_o = spec_strobe_addr4;
        4'b0101  : dpu_strobe_iss_o = spec_strobe_addr5;
        4'b0110  : dpu_strobe_iss_o = spec_strobe_addr6;
        4'b0111  : dpu_strobe_iss_o = spec_strobe_addr7;
        4'b1000  : dpu_strobe_iss_o = spec_strobe_addr8;
        4'b1001  : dpu_strobe_iss_o = spec_strobe_addr9;
        4'b1010  : dpu_strobe_iss_o = spec_strobe_addr10;
        4'b1011  : dpu_strobe_iss_o = spec_strobe_addr11;
        4'b1100  : dpu_strobe_iss_o = spec_strobe_addr12;
        4'b1101  : dpu_strobe_iss_o = spec_strobe_addr13;
        4'b1110  : dpu_strobe_iss_o = spec_strobe_addr14;
        4'b1111  : dpu_strobe_iss_o = spec_strobe_addr15;
        default  : dpu_strobe_iss_o = {16{1'bx}};
      endcase
    end

  // ------------------------------------------------------
  // ATS12NSO* instructions use the Non-secure DACR and SCTLR.M
  // Other translations use the current PL1/EL1 state
  // ------------------------------------------------------

  assign transl_dacr   = (cp_other_sec_dc1 & utlb_write_iss)      ? dpu_dacr_ns_i    : dpu_dacr_i;
  assign transl_mmu_on = (cp_other_sec_dc1 & next_utlb_write_iss) ? dpu_mmu_on_el1_i : dpu_dacr_mmu_on_i;

  // ------------------------------------------------------
  // AGU and carry in generation for micro-TLB compare
  // ------------------------------------------------------

  // Adder that generates carry-in for 4-KByte page sizes (12-bit add).
  // The 64-bit addition result is used to generate the virtual address
  assign agu_a_operand_adder = {agu_a_operand[63:32], 
                                1'b0,
                                agu_a_operand[31:12],
                                1'b0,
                                agu_a_operand[11: 6],
                                1'b0,
                                agu_a_operand[ 5: 0]};

  assign agu_b_operand_adder = {agu_b_operand[63:32], 
                                agu_aa64_addr_iss_i,
                                agu_b_operand[31:12],
                                1'b1,
                                agu_b_operand[11: 6],
                                1'b1,
                                agu_b_operand[ 5: 0]};

  assign {agu_result_adder[63:32],
          ncarry_aa32,
          agu_result_adder[31:12],
          ncarry_4k, 
          agu_result_adder[11: 6],
          ncarry_64b,
          agu_result_adder[ 5: 0]} =  (agu_a_operand_adder + agu_b_operand_adder + va_low_carry_in);

  assign carry_out_4k = ~ncarry_4k;

  assign dpu_agu_a_operand_iss_o = agu_a_operand[48:6];
  assign dpu_agu_b_operand_iss_o = agu_b_operand[48:6];
  assign dpu_agu_carry_out_64b_iss_o = ~ncarry_64b;

  // ------------------------------------------------------
  // 10 Entry micro TLB
  // ------------------------------------------------------

  // The might enable signal should be qualified with the DCU ready Iss signal to
  // ensure that the DCU communicates that there is a micro-TLB miss in progress
  // and there is an instruction stalled in DC1 which is preventing a subsequent
  // load-store from being issued from Iss.
  //
  // This prevents the DCU accepting an instruction from Iss when the stalled DC1
  // instruction is CC-failed at the same time as the micro-TLB update.  If this
  // behaviour was allowed it could result in the instruction in Iss hitting the
  // interface entry which is then over-written due to the might enable resulting
  // in incorrect data being read from said interface entry in DC1.
  assign valid_might_enable = tlb_d_utlb_might_enable_i & ~dcu_ready_iss_i;

  // Round robin logic for updating micro-TLBs
  assign round_robin_en = valid_might_enable & entry_valid[0] & ~entry0_abort_dc1;

  assign next_round_robin_count = round_robin[8] ? 4'b0000 : (round_robin_count + 4'b0001);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      round_robin_count <= 4'b0000;
    else if (round_robin_en)
      round_robin_count <= next_round_robin_count;

  always @*
    case (round_robin_count)
      4'b0000: round_robin = 9'b000000001;
      4'b0001: round_robin = 9'b000000010;
      4'b0010: round_robin = 9'b000000100;
      4'b0011: round_robin = 9'b000001000;
      4'b0100: round_robin = 9'b000010000;
      4'b0101: round_robin = 9'b000100000;
      4'b0110: round_robin = 9'b001000000;
      4'b0111: round_robin = 9'b010000000;
      4'b1000: round_robin = 9'b100000000;
      default: round_robin = 9'bxxxxxxxxx;
    endcase

  // Always enable entry 0 when the main TLB may be writing a new entry, and if
  // entry 0 is currently valid then pick a different entry to move it to based
  // on the round robin counter.
  assign utlb_entry_enable = {10{valid_might_enable}} & {{9{entry_valid[0] & ~entry0_abort_dc1}} & round_robin, 1'b1};

  // Enable all the valid bits whenever at least one of them changes. This
  // allows them to share the same clock gate.
  assign utlb_valid_enable = valid_might_enable | tlb_d_utlb_flush_i | flush_d_utlb_i;

  // Do not set the valid bit on a flush, or when a CP15 operation is in the
  // pipeline that uses the micro-TLB to translate to a physical address in the 'other'
  // security state.  These are the CRn-7, CRm-8, Opc2-4,5,6,7 encodings.  The correct
  // behvaviour is a micro-TLB miss to be forced and when the page is returned the
  // valid suppressed, but the data written.  The nature of the micro-TLB is such that
  // the correct data will still be picked up by the hit logic, but there is no need
  // to flush the micro-TLB afterwards because the new page from the 'other' security
  // state is not marked as valid (note that the micro-TLB is always flushed when the
  // security state changes).
  assign nxt_utlb_entry_valid[0]   = tlb_d_utlb_valid_i & tlb_d_utlb_enable_i &    ~(  tlb_d_utlb_flush_i | flush_d_utlb_i);
  assign nxt_utlb_entry_valid[9:1] = (entry_valid[9:1] | utlb_entry_enable[9:1]) & ~{9{tlb_d_utlb_flush_i | flush_d_utlb_i}};

  // Part of the A+B=K calculation which is common to all entries
  assign agu_a_xor_agu_b[48:12] = agu_a_operand[48:12] ^ agu_b_operand[48:12];
  assign agu_a_and_agu_b[47:12] = agu_a_operand[47:12] & agu_b_operand[47:12];

  // Entry 0
  ca53dpu_utlb_intf_entry u_entry0 (
    // Inputs
    .clk                    (clk),
    .clk_dutlb              (clk_dutlb),
    .reset_n                (reset_n),
    .aarch64_state_iss_i    (aarch64_state_iss_i),
    .agu_a_operand_i        (agu_a_operand[47:12]),
    .agu_b_operand_i        (agu_b_operand[47:12]),
    .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
    .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
    .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[0]),
    .utlb_valid_enable_i    (utlb_valid_enable),
    .utlb_entry_enable_i    (utlb_entry_enable[0]),
    .utlb_data_i            (tlb_d_utlb_data_i[95:0]),
    .tlb_d_utlb_lpae_i      (tlb_d_utlb_lpae_i),
    .transl_dacr_i          (transl_dacr),
    .transl_mmu_on_i        (transl_mmu_on),
    .carry_out_4k_i         (carry_out_4k),
    .domain_fault_en_i      (domain_fault_en_dc1),
    .dpu_exception_level_i  (dpu_exception_level_i[1:0]),
    // Outputs
    .utlb_entry_valid_o     (entry_valid[0]),
    .utlb_entry_o           (entry0_data[82:0]),
    .hit_iss_o              (raw_entry_hit_iss[0]),
    .pa_dc1_o               (entry_pa_dc1[0]),
    .attr_dc1_o             (entry_attr_dc1[0]),
    .fault_dc1_o            (entry0_fault_dc1),
    .ns_dsc_dc1_o           (entry_ns_dsc_dc1[0]),
    .domain_dc1_o           (entry0_domain_dc1),
    .abort_dc1_o            (entry0_abort_dc1),
    .level_dc1_o            (entry_level_dc1[0]),
    .lpae_dc1_o             (entry0_lpae_dc1)
  );

  generate for (n=1; n<=9; n=n+1) begin : g_utlb
    // Entry 1-9
    ca53dpu_utlb_main_entry u_entry (
      // Inputs
      .clk                    (clk),
      .clk_dutlb              (clk_dutlb),
      .reset_n                (reset_n),
      .aarch64_state_iss_i    (aarch64_state_iss_i),
      .agu_a_operand_i        (agu_a_operand[47:12]),
      .agu_b_operand_i        (agu_b_operand[47:12]),
      .agu_a_xor_agu_b_i      (agu_a_xor_agu_b[48:12]),
      .agu_a_and_agu_b_i      (agu_a_and_agu_b[47:12]),
      .nxt_utlb_entry_valid_i (nxt_utlb_entry_valid[n]),
      .utlb_valid_enable_i    (utlb_valid_enable),
      .utlb_entry_enable_i    (utlb_entry_enable[n]),
      .utlb_data_i            (entry0_data[82:0]),
      .carry_out_4k_i         (carry_out_4k),
      .dpu_exception_level_i  (dpu_exception_level_i[1:0]),
      // Outputs
      .utlb_entry_valid_o     (entry_valid[n]),
      .hit_iss_o              (raw_entry_hit_iss[n]),
      .pa_dc1_o               (entry_pa_dc1[n]),
      .attr_dc1_o             (entry_attr_dc1[n]),
      .ns_dsc_dc1_o           (entry_ns_dsc_dc1[n]),
      .level_dc1_o            (entry_level_dc1[n])
    );
  end endgenerate

  // ------------------------------------------------------
  // Hit generation
  // ------------------------------------------------------

  // Qualify raw hit from uTLB entries with signals which should globally suppress all hits.
  assign entry_hit_iss = raw_entry_hit_iss & ~{10{tlb_d_utlb_flush_i | cp_other_sec_iss_i | cp_op_ats1_iss_i}};

  // Domain fault quash signal when a CP15 operation (for the load-store pipeline)
  // other than V2P*
  assign domain_fault_en_iss = (~cp_iss_i | cp_other_sec_iss_i | cp_op_ats1_iss_i | ldar_stlr_iss_i) & ~((ns_state_i | cp_other_sec_iss_i) & dpu_default_cacheable_i);

  // Enable these registers when the DPU has a transaction in Iss and the DCU is ready to
  // accept the transaction.  If the micro-TLB misses the transaction will move into DC1,
  // but the values will be held in these registers as clean_dcu_ready_iss will deassert until
  // the transaction has been accepted by the DCU.
  assign enable_hit_entry_dc1 = dpu_valid_iss_i & ~flush_ls_wr_i & clean_dcu_ready_iss_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      entry_hit_dc1               <= {10{1'b0}};
      cp_other_sec_dc1            <= 1'b0;
      domain_fault_en_dc1         <= 1'b0;
      dpu_stack_align_expt_dc1_o  <= 1'b0;
    end
    else if (enable_hit_entry_dc1) begin
      entry_hit_dc1               <= entry_hit_iss;
      cp_other_sec_dc1            <= cp_other_sec_iss_i;
      domain_fault_en_dc1         <= domain_fault_en_iss;
      dpu_stack_align_expt_dc1_o  <= stack_align_expt_iss;
    end
  // Record if the uTLB was written by the main TLB
  assign next_utlb_write_iss = tlb_d_utlb_enable_i | (utlb_write_iss & ~enable_hit_entry_dc1);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      utlb_write_iss <= 1'b0;
    else
      utlb_write_iss <= next_utlb_write_iss;

  // If a micro-TLB hit occurs then we select the physical address and attributes
  // from which ever entry has hit.  However, if a micro-TLB miss occurs we select
  // the entry that is written by the main TLB on the previous cycle (which will
  // always be entry 0).
  assign sel_entry_dc1 = entry_hit_dc1 | {9'b000000000, utlb_write_iss};

  // Generate hit signal for the DCU
  assign dpu_utlb_hit_dc1_o = (|entry_hit_dc1) | utlb_write_iss;

  // Physical address selection
  assign dpu_pa_dc1_o[39:12] = ({28{sel_entry_dc1[0]}} & {entry_pa_dc1[0][39:12]}) |
                               ({28{sel_entry_dc1[1]}} & {entry_pa_dc1[1][39:12]}) |
                               ({28{sel_entry_dc1[2]}} & {entry_pa_dc1[2][39:12]}) |
                               ({28{sel_entry_dc1[3]}} & {entry_pa_dc1[3][39:12]}) |
                               ({28{sel_entry_dc1[4]}} & {entry_pa_dc1[4][39:12]}) |
                               ({28{sel_entry_dc1[5]}} & {entry_pa_dc1[5][39:12]}) |
                               ({28{sel_entry_dc1[6]}} & {entry_pa_dc1[6][39:12]}) |
                               ({28{sel_entry_dc1[7]}} & {entry_pa_dc1[7][39:12]}) |
                               ({28{sel_entry_dc1[8]}} & {entry_pa_dc1[8][39:12]}) |
                               ({28{sel_entry_dc1[9]}} & {entry_pa_dc1[9][39:12]});

  // Attribute selection
  assign dpu_attributes_dc1_o[12:0] = (({13{sel_entry_dc1[0]}} & entry_attr_dc1[0]) |
                                       ({13{sel_entry_dc1[1]}} & entry_attr_dc1[1]) |
                                       ({13{sel_entry_dc1[2]}} & entry_attr_dc1[2]) |
                                       ({13{sel_entry_dc1[3]}} & entry_attr_dc1[3]) |
                                       ({13{sel_entry_dc1[4]}} & entry_attr_dc1[4]) |
                                       ({13{sel_entry_dc1[5]}} & entry_attr_dc1[5]) |
                                       ({13{sel_entry_dc1[6]}} & entry_attr_dc1[6]) |
                                       ({13{sel_entry_dc1[7]}} & entry_attr_dc1[7]) |
                                       ({13{sel_entry_dc1[8]}} & entry_attr_dc1[8]) |
                                       ({13{sel_entry_dc1[9]}} & entry_attr_dc1[9]));

  // Fault information. Only entry 0 can generate a fault.
  assign dpu_fault_dc1_o = entry0_fault_dc1;

  // Non-secure selection
  assign dpu_ns_dsc_dc1_o = ((sel_entry_dc1[0] & entry_ns_dsc_dc1[0]) |
                             (sel_entry_dc1[1] & entry_ns_dsc_dc1[1]) |
                             (sel_entry_dc1[2] & entry_ns_dsc_dc1[2]) |
                             (sel_entry_dc1[3] & entry_ns_dsc_dc1[3]) |
                             (sel_entry_dc1[4] & entry_ns_dsc_dc1[4]) |
                             (sel_entry_dc1[5] & entry_ns_dsc_dc1[5]) |
                             (sel_entry_dc1[6] & entry_ns_dsc_dc1[6]) |
                             (sel_entry_dc1[7] & entry_ns_dsc_dc1[7]) |
                             (sel_entry_dc1[8] & entry_ns_dsc_dc1[8]) |
                             (sel_entry_dc1[9] & entry_ns_dsc_dc1[9]));

  // Domain selection
  assign dpu_domain_dc1_o[3:0] = entry0_domain_dc1;

  // Abort selection
  assign dpu_abort_dc1_o = sel_entry_dc1[0] & entry0_abort_dc1;

  // Level selection
  assign dpu_level_dc1_o[3:0] = (({4{sel_entry_dc1[0]}} & entry_level_dc1[0]) |
                                 ({4{sel_entry_dc1[1]}} & entry_level_dc1[1]) |
                                 ({4{sel_entry_dc1[2]}} & entry_level_dc1[2]) |
                                 ({4{sel_entry_dc1[3]}} & entry_level_dc1[3]) |
                                 ({4{sel_entry_dc1[4]}} & entry_level_dc1[4]) |
                                 ({4{sel_entry_dc1[5]}} & entry_level_dc1[5]) |
                                 ({4{sel_entry_dc1[6]}} & entry_level_dc1[6]) |
                                 ({4{sel_entry_dc1[7]}} & entry_level_dc1[7]) |
                                 ({4{sel_entry_dc1[8]}} & entry_level_dc1[8]) |
                                 ({4{sel_entry_dc1[9]}} & entry_level_dc1[9]));

  // LPAE Mode selection
  assign dpu_lpae_dc1_o = sel_entry_dc1[0] ? entry0_lpae_dc1 : tlb_lpae_mode_i;

  // Indicate which uTLB entry has hit to the DCU (used for power optimisations
  // in lspipe)
  // - Value on miss does not matter as that resets the tracking logic in the
  // DCU
  assign dpu_utlb_hit_entry_dc1_o = ({4{entry_hit_dc1[0]}} & 4'b0000) |
                                    ({4{entry_hit_dc1[1]}} & 4'b0001) |
                                    ({4{entry_hit_dc1[2]}} & 4'b0010) |
                                    ({4{entry_hit_dc1[3]}} & 4'b0011) |
                                    ({4{entry_hit_dc1[4]}} & 4'b0100) |
                                    ({4{entry_hit_dc1[5]}} & 4'b0101) |
                                    ({4{entry_hit_dc1[6]}} & 4'b0110) |
                                    ({4{entry_hit_dc1[7]}} & 4'b0111) |
                                    ({4{entry_hit_dc1[8]}} & 4'b1000) |
                                    ({4{entry_hit_dc1[9]}} & 4'b1001);

  // ------------------------------------------------------
  // Virtual address for multiples
  // ------------------------------------------------------

  // Zero the bottom bits if we are doing the second half of a cross-64
  assign align_64_iss  =  subseq_x64_iss_i;
  assign align_128_iss = (subseq_x64_iss_i & ls_store_iss_i);

  assign align_64_iss_o  = align_64_iss;
  assign align_128_iss_o = align_128_iss;

  // Create Iss stage virtual address (note aligned in DC1 if cross-64)
  assign va_iss_o[63:0] = agu_result_adder[63:0];

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: round_robin_en")
  u_ovl_x_round_robin_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (round_robin_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_hit_entry_dc1")
  u_ovl_x_enable_hit_entry_dc1 (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (enable_hit_entry_dc1));

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Should only hit in one uTLB entry
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,10,`OVL_ASSERT,"entry_hit_iss must be one-hot/zero")
    ovl_entry_hit_iss_oneh (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ({10{enable_hit_entry_dc1}} & entry_hit_iss));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,10,`OVL_ASSERT,"entry_hit_dc1 must be one-hot/zero")
    ovl_entry_hit_dc1_oneh (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (entry_hit_dc1));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_zero_one_hot #(`OVL_FATAL,10,`OVL_ASSERT,"sel_entry_dc1 must be one-hot/zero")
    ovl_sel_entry_dc1_oneh (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (sel_entry_dc1));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: TLB should never turn a valid uTLB entry for an ATS* operation
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  reg ovl_cp_op_ats_dc1;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_cp_op_ats_dc1 <= 1'b0;
    else if (dpu_valid_iss_i & ~flush_ls_wr_i & clean_dcu_ready_iss_i)
      ovl_cp_op_ats_dc1 <= cp_op_ats1_iss_i | cp_other_sec_iss_i;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"ATS* operation should not result in tlb_d_utlb_valid")
    ovl_tlb_d_utlb_valid (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (tlb_d_utlb_enable_i & ovl_cp_op_ats_dc1),
                         .consequent_expr (~tlb_d_utlb_valid_i));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: 128-bit encoding of ls_size should only be used on stores,
  //             and [1:0] should indicate size of Dword in that case
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"128-bit encoding for ls_size should only be used on stores")
    ovl_128_size_store  (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (ls_valid_iss_i & ls_size_iss_i[2]),
                         .consequent_expr (ls_store_iss_i));
  // OVL_ASSERT_END

  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"128-bit encoding for ls_size have ls_size[1:0]==Dword")
    ovl_128_size_dword  (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (ls_valid_iss_i & ls_size_iss_i[2]),
                         .consequent_expr (ls_size_iss_i[1:0] == `CA53_LDST_SIZE_DWORD));
  // OVL_ASSERT_END

  //---------------------------------------------------------------------------
  // OVL_ASSERT: Illegal next value of round robin counter in AGU utlb logic
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Next value of round robin counter in AGU utlb logic has an illegal value")
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

  //---------------------------------------------------------------------------
  // OVL_ASSERT: Illegal current value of round robin counter in AGU utlb logic
  //---------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Round robin counter current value in AGU utlb logic has an illegal value")
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
`endif

endmodule // ca53dpu_agu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
