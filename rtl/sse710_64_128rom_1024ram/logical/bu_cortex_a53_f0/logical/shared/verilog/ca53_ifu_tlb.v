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

// This is the specification for the interface between the IFU and TLB

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_ifu_tlb_defs.v"
`include "cortexa53params.v"

module ca53_ifu_tlb #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         tlb_i_utlb_enable_i,
  input         tlb_i_utlb_might_enable_i,
  input         tlb_i_utlb_valid_i,
  input         tlb_i_utlb_lpae_i,
  input  [96:0] tlb_i_utlb_data_i,
  input         tlb_i_utlb_flush_i,
  input         tlb_lpae_mode_i,
  input   [3:0] tlb_bkpt_hit_if2_i,
  input   [1:0] tlb_vcr_hit_if2_i,
  input   [1:0] tlb_d_tcr_el1_tbi_i,
  input         tlb_d_tcr_el2_tbi0_i,
  input         tlb_d_tcr_el3_tbi0_i,
  input         ifu_utlb_miss_req_i,
  input  [63:0] ifu_va_if2_i,
  input         ifu_cp_dbg_valid_i,
  input  [31:0] ifu_cp_dbg_0_i,
  input  [31:0] ifu_cp_dbg_1_i);


  wire         tlb_i_utlb_enable = tlb_i_utlb_enable_i;
  wire         tlb_i_utlb_might_enable = tlb_i_utlb_might_enable_i;
  wire         tlb_i_utlb_valid = tlb_i_utlb_valid_i;
  wire         tlb_i_utlb_lpae = tlb_i_utlb_lpae_i;
  wire  [96:0] tlb_i_utlb_data = tlb_i_utlb_data_i;
  wire         tlb_i_utlb_flush = tlb_i_utlb_flush_i;
  wire         tlb_lpae_mode = tlb_lpae_mode_i;
  wire   [3:0] tlb_bkpt_hit_if2 = tlb_bkpt_hit_if2_i;
  wire   [1:0] tlb_vcr_hit_if2 = tlb_vcr_hit_if2_i;
  wire   [1:0] tlb_d_tcr_el1_tbi = tlb_d_tcr_el1_tbi_i;
  wire         tlb_d_tcr_el2_tbi0 = tlb_d_tcr_el2_tbi0_i;
  wire         tlb_d_tcr_el3_tbi0 = tlb_d_tcr_el3_tbi0_i;
  wire         ifu_utlb_miss_req = ifu_utlb_miss_req_i;
  wire  [63:0] ifu_va_if2 = ifu_va_if2_i;
  wire         ifu_cp_dbg_valid = ifu_cp_dbg_valid_i;
  wire  [31:0] ifu_cp_dbg_0 = ifu_cp_dbg_0_i;
  wire  [31:0] ifu_cp_dbg_1 = ifu_cp_dbg_1_i;

  wire   [7:0] mem_attrs;

  reg         utlb_enabled;
  reg         out_of_reset;

  reg         tlb_i_utlb_enable_reg;
  reg  [63:0] ifu_va_if2_reg;
  reg         ifu_utlb_miss_req_reg;
  reg         out_of_reset_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    tlb_i_utlb_enable_reg <= 1'b0;
    ifu_va_if2_reg <= {64{1'b0}};
    ifu_utlb_miss_req_reg <= 1'b0;
    out_of_reset_reg <= 1'b0;
  end
  else
  begin
    tlb_i_utlb_enable_reg <= tlb_i_utlb_enable;
    ifu_utlb_miss_req_reg <= ifu_utlb_miss_req;
    ifu_va_if2_reg <= ifu_va_if2;
    out_of_reset_reg <= out_of_reset;
  end



  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Inputs to the IFU from the TLB
  //  input         tlb_i_utlb_enable       valid always                               timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_i_utlb_enable X or Z")
  u_ovl_intf_x_tlb_i_utlb_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_i_utlb_enable));

  //  input         tlb_i_utlb_might_enable valid always                               timing 65%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_i_utlb_might_enable X or Z")
  u_ovl_intf_x_tlb_i_utlb_might_enable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_i_utlb_might_enable));

  //  input         tlb_i_utlb_valid        valid tlb_i_utlb_enable                    timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_i_utlb_valid X or Z")
  u_ovl_intf_x_tlb_i_utlb_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_i_utlb_enable),
    .test_expr (tlb_i_utlb_valid));

  //  input         tlb_i_utlb_lpae         valid tlb_i_utlb_enable                    timing 85%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_i_utlb_lpae X or Z")
  u_ovl_intf_x_tlb_i_utlb_lpae (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_i_utlb_enable),
    .test_expr (tlb_i_utlb_lpae));

  //  input [96:0]  tlb_i_utlb_data         valid tlb_i_utlb_enable & tlb_i_utlb_valid timing 85%

  assert_never_unknown #(`OVL_FATAL, 97, INOPTIONS, "tlb_i_utlb_data X or Z")
  u_ovl_intf_x_tlb_i_utlb_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (tlb_i_utlb_enable & tlb_i_utlb_valid),
    .test_expr (tlb_i_utlb_data));

  //  input         tlb_i_utlb_flush        valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_i_utlb_flush X or Z")
  u_ovl_intf_x_tlb_i_utlb_flush (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_i_utlb_flush));

  //  input         tlb_lpae_mode           valid always                               timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_lpae_mode X or Z")
  u_ovl_intf_x_tlb_lpae_mode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_lpae_mode));

  //  input [3:0]   tlb_bkpt_hit_if2        valid always                               timing 80%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "tlb_bkpt_hit_if2 X or Z")
  u_ovl_intf_x_tlb_bkpt_hit_if2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_bkpt_hit_if2));

  //  input [1:0]   tlb_vcr_hit_if2         valid always                               timing 80%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_vcr_hit_if2 X or Z")
  u_ovl_intf_x_tlb_vcr_hit_if2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_vcr_hit_if2));

  //  input [1:0]   tlb_d_tcr_el1_tbi       valid always                               timing 40%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "tlb_d_tcr_el1_tbi X or Z")
  u_ovl_intf_x_tlb_d_tcr_el1_tbi (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el1_tbi));

  //  input         tlb_d_tcr_el2_tbi0      valid always                               timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el2_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el2_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el2_tbi0));

  //  input         tlb_d_tcr_el3_tbi0      valid always                               timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "tlb_d_tcr_el3_tbi0 X or Z")
  u_ovl_intf_x_tlb_d_tcr_el3_tbi0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (tlb_d_tcr_el3_tbi0));


  // Outputs from the IFU to the TLB
  //  output        ifu_utlb_miss_req       valid always                               timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ifu_utlb_miss_req X or Z")
  u_ovl_intf_x_ifu_utlb_miss_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_utlb_miss_req));

  //  output [63:0] ifu_va_if2              valid always                               timing 22%

  assert_never_unknown #(`OVL_FATAL, 64, OUTOPTIONS, "ifu_va_if2 X or Z")
  u_ovl_intf_x_ifu_va_if2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_va_if2));

  //  output        ifu_cp_dbg_valid        valid always                               timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ifu_cp_dbg_valid X or Z")
  u_ovl_intf_x_ifu_cp_dbg_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ifu_cp_dbg_valid));

  //  output [31:0] ifu_cp_dbg_0            valid ifu_cp_dbg_valid                     timing 75%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "ifu_cp_dbg_0 X or Z")
  u_ovl_intf_x_ifu_cp_dbg_0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_cp_dbg_valid),
    .test_expr (ifu_cp_dbg_0));

  //  output [31:0] ifu_cp_dbg_1            valid ifu_cp_dbg_valid                     timing 75%

  assert_never_unknown #(`OVL_FATAL, 32, OUTOPTIONS, "ifu_cp_dbg_1 X or Z")
  u_ovl_intf_x_ifu_cp_dbg_1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ifu_cp_dbg_valid),
    .test_expr (ifu_cp_dbg_1));


  // ------------------------------------------------------
  // Fetch interface description
  // ------------------------------------------------------

  // tlb_i_utlb_enable:
  // The enable signal is asserted to write a single entry to the instruction
  // micro-TLB.

  // tlb_i_utlb_might_enable:
  // The micro-TLB might be written this cycle, depending on whether the
  // RAM lookup hit or not. This speculative signal can be provided earlier
  // than the accurate version.

  // tlb_i_utlb_valid:
  // The valid bit to write to the uTLB entry that is enabled. Normally this
  // will be set, however on TLB aborts an entry will be written with the
  // valid bit cleared, to ensure that this entry is not reused for future
  // instructions.

  // tlb_i_utlb_lpae
  // The format of the uTLB entry being written. When set the format is LPAE,
  // otherwise it is VMSAv7.

  // tlb_i_utlb_data:
  // TLB data to be written to the micro-TLB.  The data includes the
  // tag, physical-address, page-size and attributes.

  // tlb_i_utlb_flush:
  // When asserted all micro-TLB entries should be marked as invalid.

  // tlb_lpae_mode:
  // The tlb_i_utlb_flush will be asserted if either the secure or non-secure TTBCR
  // (which contains the EAE bit) are written.  The dpu_flush_i_utlb signal will
  // be asserted if the security state changes and a different TTBCR EAE bit is
  // used.  However, if the processor moves to HYP mode then the tlb_lpae_mode
  // signal will be asserted without a micro-TLB flush.  This signal is only
  // valid for stage-1 translations and may not be set for stage-2 translations
  // which are inherently in LPAE mode.

  // tlb_bkpt_hit_if2:
  // Indicates a breakpoint address hit on a per 16-bit basis.  Note that if
  // there is a breakpoint address match indicated on the second portion of a
  // 32-bit Thumb instruction a breakpoint will not be triggered.

  // tlb_vcr_hit_if2:
  // Indicates a vector catch address hit on a per 32-bit basis.

  // ifu_utlb_miss_req:
  // When asserted this signals the TLB that a micro-TLB miss has
  // occurred.  This signal remains asserted for as long as the
  // micro-TLB is waiting on the correct page.  If the IFU no longer
  // needs the page as a force of program direction has been made then
  // the signal is deasserted and the main TLB must not send the
  // requested page.
  //
  // Once the page has been written into the micro-TLB from the
  // main-TLB the signal is deasserted.
  //
  // This signal comes directly from a register.

  // ifu_va_if2:
  // The virtual address bus in if2.  This bus comes directly from 
  // registers.

  // ifu_cp_dbg_valid
  // After a CP15 debug read request to the IFU, the resultant data will be
  // provided on this interface so that it can be stored in two 32-bit
  // registers in the TLB.

  // ------------------------------------------------------
  // Fields within tlb_i_utlb_data
  // ------------------------------------------------------
  // uTLB data encoding:
  // Size       [96]
  // XS1Nonusr  [95]
  // XS2        [94]
  // XS1Usr     [93]
  // Domain     [92:89]
  // Fault type [88:82]
  // Fault      [81:80]
  // S2Level    [79:78]
  // S1Level    [77:76]
  // MemAttrs   [75:68]
  // ExcpLevel  [67:66]
  // NS         [65]
  // PA         [64:37]
  // VA         [36:0]
  //
  // Size: The size of the entry being placed into the uTLB:
  //  0 - 4K
  //  1 - 1M OR More
  //
  // Executable:
  // These fields describe the executable conditions for stage-1, stage-2
  //  XS1Usr    - Executable at S1 user mode.  XS1Usr should not be relied on in EL3 or EL2 access
  //  XS1Nonusr - Executable at S1 Non user mode
  //  XS2       - Executable at S2 stage 
  //
  // Domain:
  // This field indicates which memory domain in the CP15 Domain Access Control
  // Register (DACR) the page belongs to.  For example an encoding of 0010
  // indicates that domain 2 of the DACR should be checked for a domain fault.
  //
  //
  // Fault:
  // The fault bits indicate if a fault occurred:
  // 00 - No fault.
  // 01 - Stage2 fault due to a stage1 pagewalk.
  // 10 - Stage1 fault.
  // 11 - Stage2 fault. Note that there could still be a stage1 fault
  //      (permission or domain) which is detected after this,
  //      and must take priority.
  //
  // The fault type encodes what type of fault occurred if bits [81:80] are
  // non-zero.
  // If bit [80] is set, indicating a stage2 fault, then bits [64:37] contain
  // the IPA of the faulting access instead of the PA. The level fields contain
  // the level the fault was, for either the first stage or second stage
  // depending on the fault type
  //
  // The fault signal needs to be qualified with the tlb_i_utlb_enable signal
  //
  //
  // S2Level:
  // The level field indicates how many levels of stage2 were needed
  // for the translation:
  //  00 - No stage2 translation was performed
  //  01 - first level
  //  10 - second level
  //  11 - third level
  //
  //
  // S1Level:
  //  S1Level is defined as the level at which translation completes. 
  //  In AArch64, even if there is a fault at L0, S1Level is reported as L1 (as
  //  AArch64 translation could never complete at L0). 
  //  S1 Level is valid only when FAULT field is 2'b00 (No fault) or 2'b11(stage2 
  //  fault when stage1 had completed).
  //  00 - first level, supersection (VMSAv7 only)
  //  01 - first level
  //  10 - second level
  //  11 - third level (AArch32-LPAE/AArch64)
  //
  //
  // MemAttrs:
  // See cortexa53params for the encoding

  // ExcpLevel (This signal is not an exact replica of DPU exception level)
  //  EL2 is always reported as 2'b10
  //  EL3-A64 is reported as 2'b11   
  //  All other exception level and architecture combinations are treated as 2'b00
  //   00
  //   01 - unused
  //   10
  //   11

  //
  // NS:
  // The NS bit indicates the non-secure state of the physical memory address, as
  // indicated in the page descriptor.

  // ------------------------------------------------------
  // Interface OVLs
  // ------------------------------------------------------

   // The speculative enable signal must be set if the entry is really enabled.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable  => tlb_i_utlb_might_enable")
  u_ovl_intf_assume_7e0993e9d989ef0a9076d6881acedd6ba4dfa31c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable ),
    .consequent_expr (tlb_i_utlb_might_enable));


   // Once enabled, might enable must remain low until the next lookup starts.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable@1  => ~tlb_i_utlb_might_enable")
  u_ovl_intf_assume_08caf8b81ac25ddfc437b1866b644e4f63d34f94 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable_reg ),
    .consequent_expr (~tlb_i_utlb_might_enable));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    utlb_enabled <= 1'b0;
  else
    utlb_enabled <= tlb_i_utlb_enable | (utlb_enabled & ~ifu_utlb_miss_req);



  assert_implication #(`OVL_FATAL, INOPTIONS, "utlb_enabled  => ~tlb_i_utlb_might_enable")
  u_ovl_intf_assume_a1bca9aec2ea0e04bab0f1fff14e6d44df0ce08e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (utlb_enabled ),
    .consequent_expr (~tlb_i_utlb_might_enable));


   // might_enable can only be set if we have a req or had a req in the previous cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_might_enable  => ifu_utlb_miss_req | ifu_utlb_miss_req@1")
  u_ovl_intf_assume_429193dd95c2741956c2b13504512af5f9b4b5d3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_might_enable ),
    .consequent_expr (ifu_utlb_miss_req | ifu_utlb_miss_req_reg));


   // The micro-TLB miss request can be deasserted at any time (due to flush etc) but if a microTLB
   // update occurs the request is guaranteed to be deasserted for one cycle.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "tlb_i_utlb_enable@1  => ~ifu_utlb_miss_req")
  u_ovl_intf_assert_0bf17a561673373b414ad14c9ccef7c5fb594b3d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable_reg ),
    .consequent_expr (~ifu_utlb_miss_req));


   // A valid micro-TLB update should only be asserted for a single cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable@1  => ~tlb_i_utlb_enable")
  u_ovl_intf_assume_0e82b01294fce822ff9818d37ba250d26250003f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable_reg ),
    .consequent_expr (~tlb_i_utlb_enable));


   // A micro-TLB update should only occur when the miss request signal is
   // asserted and it was asserted in the previous cycle

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable  => ifu_utlb_miss_req & ifu_utlb_miss_req@1")
  u_ovl_intf_assume_8aa2d044c1e8c317ecc16ae310cc88bec1d2d635 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable ),
    .consequent_expr (ifu_utlb_miss_req & ifu_utlb_miss_req_reg));


   // During a micro-TLB_miss the virtual address that is asserted should not change until req is dropped

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "ifu_utlb_miss_req@1 & ifu_utlb_miss_req  => (ifu_va_if2[63:0] == ifu_va_if2@1[63:0])")
  u_ovl_intf_assert_f562ce089cd734af613c34eb537896a5f54cca7b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ifu_utlb_miss_req_reg & ifu_utlb_miss_req ),
    .consequent_expr ((ifu_va_if2[63:0] == ifu_va_if2_reg[63:0])));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


   // A request must not be made on the first two cycles after reset (to ensure that
   // the TLB arbitrates the invalidate all on reset first)

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~out_of_reset@1  => ~ifu_utlb_miss_req")
  u_ovl_intf_assert_ac66a8ced6927764704219686190743998103507 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~out_of_reset_reg ),
    .consequent_expr (~ifu_utlb_miss_req));


   // Only the following s1level encodings are valid
   //  In VMSA, translation can complete at level L1 or L2. L0 is reported
   //  when translation completes at L1 with supersection

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & ~tlb_i_utlb_lpae  => tlb_i_utlb_data[77:76] in [2'b00, 2'b01, 2'b10]")
  u_ovl_intf_assume_366da705f6183f12fc8166c811a5abf65c269841 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & ~tlb_i_utlb_lpae ),
    .consequent_expr (((tlb_i_utlb_data[77:76] == 2'b00) | (tlb_i_utlb_data[77:76] ==  2'b01) | (tlb_i_utlb_data[77:76] ==  2'b10))));


   // In AArch32-LPAE/AArch64, reported levels can be L1/L2/L3

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable &  tlb_i_utlb_lpae  => tlb_i_utlb_data[77:76] in [2'b01, 2'b10, 2'b11]")
  u_ovl_intf_assume_57a5f597f091d73d6e7c873324a7760409c14c89 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable &  tlb_i_utlb_lpae ),
    .consequent_expr (((tlb_i_utlb_data[77:76] == 2'b01) | (tlb_i_utlb_data[77:76] ==  2'b10) | (tlb_i_utlb_data[77:76] ==  2'b11))));


   // The size can not be bigger than a particular level could generate
   // If S2 fault on a stage1 pagewalk then S1level is not checked
   //                         Size 1M OR More        VMSA              No fault OR S2 only fault          S1Level L1 supersection or L1

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & tlb_i_utlb_data[96] & ~tlb_i_utlb_lpae & (tlb_i_utlb_data[81:80] == 2'b00 | tlb_i_utlb_data[81:80] == 2'b11)  => tlb_i_utlb_data[77:76] in [2'b00, 2'b01]")
  u_ovl_intf_assume_57f22d57c1358703752d3fbdc47a27ccdca67702 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & tlb_i_utlb_data[96] & ~tlb_i_utlb_lpae & (tlb_i_utlb_data[81:80] == 2'b00 | tlb_i_utlb_data[81:80] == 2'b11) ),
    .consequent_expr (((tlb_i_utlb_data[77:76] == 2'b00) | (tlb_i_utlb_data[77:76] ==  2'b01))));


   //                         Size 1M OR More        A32-LPAE or A64   No fault OR S2 only fault            S1Level L1/L2/L3(A64-L3 for contiguous bit set)

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & tlb_i_utlb_data[96] &  tlb_i_utlb_lpae & (tlb_i_utlb_data[81:80] == 2'b00 |  tlb_i_utlb_data[81:80] == 2'b11)  => tlb_i_utlb_data[77:76] in [2'b01, 2'b10, 2'b11]")
  u_ovl_intf_assume_98476abcaf98c9de9ec716643b636759b3065698 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & tlb_i_utlb_data[96] &  tlb_i_utlb_lpae & (tlb_i_utlb_data[81:80] == 2'b00 |  tlb_i_utlb_data[81:80] == 2'b11) ),
    .consequent_expr (((tlb_i_utlb_data[77:76] == 2'b01) | (tlb_i_utlb_data[77:76] ==  2'b10) | (tlb_i_utlb_data[77:76] ==  2'b11))));



   // Default XS2 is executable for Stage 2 pagewalk  

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & tlb_i_utlb_data[79:78] == 2'b00  => tlb_i_utlb_data[94]")
  u_ovl_intf_assume_5be96c88ab96ec87164fbb9add024d3b1e163aeb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & tlb_i_utlb_data[79:78] == 2'b00 ),
    .consequent_expr (tlb_i_utlb_data[94]));


   // A non-faulting entry should always be valid

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & ~|tlb_i_utlb_data[81:80]  => tlb_i_utlb_valid")
  u_ovl_intf_assume_1b1448cbe2d0101840ffbfa5fbddbaf4d2cc3d40 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & ~|tlb_i_utlb_data[81:80] ),
    .consequent_expr (tlb_i_utlb_valid));


   // A faulting entry should never be valid

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & |tlb_i_utlb_data[81:80]  => ~tlb_i_utlb_valid")
  u_ovl_intf_assume_d94d5fd5c089c51b3f27e72d3c1bc3931e91eceb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & |tlb_i_utlb_data[81:80] ),
    .consequent_expr (~tlb_i_utlb_valid));


   // Only the following page fault encodings are valid for stage1 VMSA faults

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & (tlb_i_utlb_data[81:80] == 2'b10) & ~tlb_i_utlb_lpae  => tlb_i_utlb_data[88:82] in [`CA53_FAULT_LPAE_ADDR_SIZE_L0,         `CA53_FAULT_LPAE_ADDR_SIZE_L1,         `CA53_FAULT_LPAE_ADDR_SIZE_L2,         `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2]")
  u_ovl_intf_assume_ceddc12bbdf8baef9b25192c684e6b0fe684fd33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & (tlb_i_utlb_data[81:80] == 2'b10) & ~tlb_i_utlb_lpae ),
    .consequent_expr (((tlb_i_utlb_data[88:82] == `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L2))));


   // Only the following page fault encodings are valid for stage1 LPAE faults. Note that ADDR_SIZE fault is possible for AArch64 only

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & (tlb_i_utlb_data[81:80] == 2'b10) & tlb_i_utlb_lpae  => tlb_i_utlb_data[88:82] in [`CA53_FAULT_LPAE_ADDR_SIZE_L0,         `CA53_FAULT_LPAE_ADDR_SIZE_L1,         `CA53_FAULT_LPAE_ADDR_SIZE_L2,         `CA53_FAULT_LPAE_ADDR_SIZE_L3,         `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0,  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0,  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0,  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0,       `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0,            `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3]")
  u_ovl_intf_assume_c1a0a408a096b773be1b27759060fa309148abe6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & (tlb_i_utlb_data[81:80] == 2'b10) & tlb_i_utlb_lpae ),
    .consequent_expr (((tlb_i_utlb_data[88:82] == `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (tlb_i_utlb_data[88:82] ==   `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (tlb_i_utlb_data[88:82] ==   `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (tlb_i_utlb_data[88:82] ==   `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (tlb_i_utlb_data[88:82] ==        `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (tlb_i_utlb_data[88:82] ==             `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L3))));


   // Only the following page fault encodings are valid for stage2 faults

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & tlb_i_utlb_data[80]  => tlb_i_utlb_data[88:82] in [`CA53_FAULT_LPAE_ADDR_SIZE_L0,           `CA53_FAULT_LPAE_ADDR_SIZE_L1,           `CA53_FAULT_LPAE_ADDR_SIZE_L2,           `CA53_FAULT_LPAE_ADDR_SIZE_L3,           `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0,    `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0,    `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0,    `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2, `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3, `CA53_FAULT_LPAE_TRANSLATION_L0,         `CA53_FAULT_LPAE_TRANSLATION_L1, `CA53_FAULT_LPAE_TRANSLATION_L2, `CA53_FAULT_LPAE_TRANSLATION_L3, `CA53_FAULT_LPAE_ACCESS_L0,              `CA53_FAULT_LPAE_ACCESS_L1, `CA53_FAULT_LPAE_ACCESS_L2, `CA53_FAULT_LPAE_ACCESS_L3, `CA53_FAULT_LPAE_PERMISSION_L1,          `CA53_FAULT_LPAE_PERMISSION_L2, `CA53_FAULT_LPAE_PERMISSION_L3]")
  u_ovl_intf_assume_a8ed44f8e4adb77a7b4994e6f695f887a95bad47 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & tlb_i_utlb_data[80] ),
    .consequent_expr (((tlb_i_utlb_data[88:82] == `CA53_FAULT_LPAE_ADDR_SIZE_L0) | (tlb_i_utlb_data[88:82] ==            `CA53_FAULT_LPAE_ADDR_SIZE_L1) | (tlb_i_utlb_data[88:82] ==            `CA53_FAULT_LPAE_ADDR_SIZE_L2) | (tlb_i_utlb_data[88:82] ==            `CA53_FAULT_LPAE_ADDR_SIZE_L3) | (tlb_i_utlb_data[88:82] ==            `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0) | (tlb_i_utlb_data[88:82] ==     `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0) | (tlb_i_utlb_data[88:82] ==     `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0) | (tlb_i_utlb_data[88:82] ==     `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L0) | (tlb_i_utlb_data[88:82] ==          `CA53_FAULT_LPAE_TRANSLATION_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_TRANSLATION_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L0) | (tlb_i_utlb_data[88:82] ==               `CA53_FAULT_LPAE_ACCESS_L1) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_ACCESS_L3) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PERMISSION_L1) | (tlb_i_utlb_data[88:82] ==           `CA53_FAULT_LPAE_PERMISSION_L2) | (tlb_i_utlb_data[88:82] ==  `CA53_FAULT_LPAE_PERMISSION_L3))));


  // The stage2 should be enabled if a stage2 fault occurred.

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & tlb_i_utlb_data[80]  => tlb_i_utlb_data[79:78] != 2'b00")
  u_ovl_intf_assume_eb059e1f4a4440d22ebd599a2218aa841484c2cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & tlb_i_utlb_data[80] ),
    .consequent_expr (tlb_i_utlb_data[79:78] != 2'b00));



  assign mem_attrs  = tlb_i_utlb_data[75:68];

  // Only some page type encodings are valid, when there is a valid stage1 translation

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable & (tlb_i_utlb_data[81:80] in [2'b00, 2'b11])  => ~`CA53_MEM_UNUSED(mem_attrs)")
  u_ovl_intf_assume_8ecdccf26dea55b83fcae64d1c13d907cb0dde79 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable & (((tlb_i_utlb_data[81:80] == 2'b00) | (tlb_i_utlb_data[81:80] ==  2'b11))) ),
    .consequent_expr (~`CA53_MEM_UNUSED(mem_attrs)));


  // Exception level 2'b01 not used

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable  => tlb_i_utlb_data[67:66] != 2'b01")
  u_ovl_intf_assume_401844a8de375794ec7fa0e1c6e3bfcbeb0362c8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable ),
    .consequent_expr (tlb_i_utlb_data[67:66] != 2'b01));


  // va must match incoming va on valid requests (not aborting one)

  assert_implication #(`OVL_FATAL, INOPTIONS, "tlb_i_utlb_enable  => tlb_i_utlb_data[36:0] == ifu_va_if2[48:12]")
  u_ovl_intf_assume_6a0587fe335da6d20f0fc2928d7615131bed3d1d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (tlb_i_utlb_enable ),
    .consequent_expr (tlb_i_utlb_data[36:0] == ifu_va_if2[48:12]));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ifu_tlb_defs.v"
`undef CA53_UNDEFINE

`endif

