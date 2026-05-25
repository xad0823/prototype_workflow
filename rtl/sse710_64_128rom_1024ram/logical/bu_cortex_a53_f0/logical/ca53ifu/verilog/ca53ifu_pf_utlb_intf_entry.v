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
// Abstract : Interface instruction micro TLB entry including hit logic
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_utlb_intf_entry (
  // Inputs
  input wire          clk,
  input wire          clk_iutlb,
  input wire          reset_n,
  input wire [19:12]  va_if1_i,
  input wire [47:12]  agu_a_operand_if1_i,
  input wire [47:12]  agu_b_operand_if1_i,
  input wire [48:12]  agu_a_xor_agu_b_i,
  input wire [47:12]  agu_a_and_agu_b_i,
  input wire          carry_out_4k_i,
  input wire          carry_out_1m_i,
  input wire          aarch64_state_i,
  input wire [96:0]   tlb_i_utlb_data_i,
  input wire          nxt_utlb_entry_valid_i,
  input wire          utlb_valid_enable_i,
  input wire          utlb_entry_enable_i,
  input wire          tlb_i_utlb_lpae_i,
  input wire          tlb_i_utlb_flush_i,
  input wire          dpu_mmu_on_i,
  input wire [31:0]   dpu_dacr_i,
  input wire          dpu_flush_i_utlb_i,
  input wire          sif_only_i,
  input wire          ns_state_i,
  input wire          default_cacheable_i,
  input wire          exception_level_0_i,
  input wire          exception_level_2_i,
  input wire          exception_level_3_i,
  input wire          pfb_aarch64_at_el3_i,
  // Outputs
  output wire         utlb_entry_valid_o,
  output wire [80:0]  intf_entry_data_o,
  output wire         hit_if1_o,
  output wire         main_tlb_abort_o,
  output wire         micro_tlb_abort_o,
  output wire [6:0]   abort_type_o,
  output wire [1:0]   stage2_abort_o,
  output wire         lpae_abort_o,
  output wire         ns_dsc_if1_o,
  output wire [39:12] pa_if1_o,
  output wire [7:0]   attr_if1_o,
  output wire [27:0]  abort_ipa_if1_o);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg            mmu_on;
  reg            abort_lpae_mode;
  reg [96:0]     utlb_entry;
  reg            utlb_entry_valid;
  reg [1:0]      domain;
  reg [31:0]     dacr;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [48:12]   csa_sum;
  wire [47:12]   csa_carry;
  wire [19:12]   combine_4k;
  wire [48:20]   combine_1m;
  wire           domain_is_client;
  wire           hit_4k;
  wire           hit_1m;
  wire           domain_abort;
  wire [1:0]     main_tlb_abort;
  wire           sif_abort;
  wire           el_match;
  wire           permission_abort_s2;
  wire           permission_abort_s1;
  wire [1:0]     xs1;
  wire           vmsa_page_4knot1m;
  wire [1:0]     s1level;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Micro TLB register
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      utlb_entry_valid <= 1'b0;
    else if (utlb_valid_enable_i)
      utlb_entry_valid <= nxt_utlb_entry_valid_i;

  // Register the micro-TLB data
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
  // Also take a copy of the LPAE mode signal in the cycle the page was written
  always @(posedge clk_iutlb)
    if (utlb_entry_enable_i) begin
      utlb_entry      <= tlb_i_utlb_data_i;
      abort_lpae_mode <= tlb_i_utlb_lpae_i;
      mmu_on          <= dpu_mmu_on_i;
      dacr            <= dpu_dacr_i[31:0];
    end

  // ------------------------------------------------------
  // Full adder for a+b=k calculation
  // ------------------------------------------------------

  assign csa_sum[48:12]   = agu_a_xor_agu_b_i[48:12] ^ ~utlb_entry[36:0];
  assign csa_carry[47:12] = ( agu_a_and_agu_b_i[47:12] |
                             (agu_a_operand_if1_i[47:12] & ~utlb_entry[35:0]) |
                             (agu_b_operand_if1_i[47:12] & ~utlb_entry[35:0]));

  // ------------------------------------------------------
  // Hit detection
  // ------------------------------------------------------

  // Compute hit for 1-MByte page sizes
  assign combine_1m[48:20] = csa_sum[48:20] ^ {csa_carry[47:32], csa_carry[31] & aarch64_state_i, csa_carry[30:20], carry_out_1m_i};
  assign hit_1m            = &combine_1m[48:20];

  // Compute hit for 4-KByte page sizes, but do not do the compare on the
  // 1-MByte bits again since this has already been done.
  assign combine_4k[19:12] = csa_sum[19:12] ^ {csa_carry[18:12], carry_out_4k_i};
  assign hit_4k            = &combine_4k[19:12];

  // a uTLB match must look at the Exception level EL as well because in two occasions it will not flush the
  // uTLB on an Exception level change.
  // o if in AARCH64 and in EL3 we could go to secure EL1 without a flush
  // o we could enter or exit hypervisor without a flush
  assign el_match = exception_level_3_i & pfb_aarch64_at_el3_i ? utlb_entry[67:66] == `CA53_EL3 :
                    exception_level_2_i                        ? utlb_entry[67:66] == `CA53_EL2 :
                                                                 utlb_entry[67:66] == `CA53_EL0; // EL1 not used by TLB

  // Mux between page sizes to produce a final hit signal.  The page size is stored in the
  // TLB entry for simplicity.  When a DPU flush is signalled the DACR or LPAE mode can
  // change and when a TLB flush is signalled the LPAE mode can change so we don't
  // want to incorrectly abort (or not abort) on the new value with the old page table.
  assign hit_if1_o = ((utlb_entry_valid & el_match & ~dpu_flush_i_utlb_i & ~tlb_i_utlb_flush_i &  utlb_entry[96] & hit_1m) |
                      (utlb_entry_valid & el_match & ~dpu_flush_i_utlb_i & ~tlb_i_utlb_flush_i & ~utlb_entry[96] & hit_1m & hit_4k));

  // ------------------------------------------------------
  // Abort resolution
  // ------------------------------------------------------
  //
  // This section resolves all micro-TLB related aborts.  Apart from creating the
  // abort type, it does nothing with main-TLB related aborts.  The logic differs
  // from the abort detection in the main micro-TLB entries in that it also covers
  // aborts in the domain, XN1 and XN2 fields which are not transferred to the
  // main micro-TLB entries.

  // Domain abort detection (note that this is VMSAv7 only)
  //  DACR = 00 Domain Abort
  //  DACR = 01 Client (check the access permission bits)
  //  DACR = 10 UNPREDICTABLE, Domain Abort
  //  DACR = 11 Manager (do not check the access permission bits)
  always @*
    case (utlb_entry[92:89])
      4'b0000 : domain[1:0] = dacr[ 1: 0];
      4'b0001 : domain[1:0] = dacr[ 3: 2];
      4'b0010 : domain[1:0] = dacr[ 5: 4];
      4'b0011 : domain[1:0] = dacr[ 7: 6];
      4'b0100 : domain[1:0] = dacr[ 9: 8];
      4'b0101 : domain[1:0] = dacr[11:10];
      4'b0110 : domain[1:0] = dacr[13:12];
      4'b0111 : domain[1:0] = dacr[15:14];
      4'b1000 : domain[1:0] = dacr[17:16];
      4'b1001 : domain[1:0] = dacr[19:18];
      4'b1010 : domain[1:0] = dacr[21:20];
      4'b1011 : domain[1:0] = dacr[23:22];
      4'b1100 : domain[1:0] = dacr[25:24];
      4'b1101 : domain[1:0] = dacr[27:26];
      4'b1110 : domain[1:0] = dacr[29:28];
      4'b1111 : domain[1:0] = dacr[31:30];
      default : domain[1:0] = 2'bxx;
    endcase

  assign domain_abort = ~abort_lpae_mode & mmu_on & ~domain[0] & ~(ns_state_i & default_cacheable_i);

  // Access Permission abort detection assuming that there is not a domain abort.
  // If the processor is in VMSAv7 the domain field must be checked to see if a client
  // domain is indicated.  If the processor is in LPAE mode the domain field is ignored
  // and the processor is essentially always in a client domain. If the field is 3'b100
  // then the Hypervisor access permissions must be checked since the page was fetched
  // in HYP mode.
  //  000 Abort
  //  001 Privileged access only
  //  010 Full access (on the instruction side)
  //  011 Full access
  //  100 Hypervisor Access Permission field
  //       00 Abort
  //       01 Full access
  //       10 Abort
  //       11 Full access
  //  101 Privileged access only
  //  110 Full access
  //  111 Full access
  //
  // Another consideration is the executable (XSn) bits.
  //  utlb_entry[93] : XS1Usr    = Executable at S1 user mode
  //  utlb_entry[94] : XS2       = Executable at S2 stage
  //  utlb_entry[95] : XS1Nonusr = Executable at S1 non-user mode
  //
  // A final consideration is the secure instruction fetch signal from the DPU which
  // applies to the client domain in VMSAv7 mode and LPAE mode.  If this signal is
  // set and the page is non-secure then a permissions abort must be indicated.
  assign domain_is_client = ~abort_lpae_mode & mmu_on & domain[1:0] == 2'b01;
  assign sif_abort        = sif_only_i & utlb_entry[65];

  // Stage-1 Permission Abort
  assign permission_abort_s1 = ((abort_lpae_mode | domain_is_client) &
                                (sif_abort | (exception_level_0_i ? ~utlb_entry[93] : ~utlb_entry[95])));

  // S1Level must not be 0 for stage 1 permission abort.  Level 0 is converted
  // to level 1.
  assign s1level[1] = utlb_entry[77];
  assign s1level[0] = utlb_entry[77:76] != 2'b10;

  // Stage-2 Permission Abort
  assign permission_abort_s2 = ~utlb_entry[94];

  // Main TLB abort indicator
  assign main_tlb_abort = utlb_entry[81:80];

  // ------------------------------------------------------
  // Output generation
  // ------------------------------------------------------

  // Entry valid signal
  assign utlb_entry_valid_o = utlb_entry_valid;

  // Form the entry that is transferred to the main micro-TLB entries. This does
  // not include the domain, XS2 or level-2 fields.  abort will always be
  // triggered in the interface micro-TLB entry.  However the LPAE mode must be
  // passed to ensure that aborts work correctly.
  //
  // If the domain is manager we force the user bit to always so that even if
  // the exception level changes we will not report an abort since manager
  // domain cannot produce faults. If the DACR changes then the uTLB is
  // flushed so no issues there.
  assign xs1 = {2{~abort_lpae_mode & domain[1:0] == 2'b11}} | {utlb_entry[95], utlb_entry[93]};
  assign intf_entry_data_o = {utlb_entry[96], xs1, s1level, utlb_entry[75:0]};

  // Abort indicators
  assign main_tlb_abort_o  = |main_tlb_abort;
  assign micro_tlb_abort_o = domain_abort | permission_abort_s1 | permission_abort_s2;

  // Determine if the VMSA page size is 4K or 1M from the level (the size bit in the entry
  // does not inidicate the actual page as fetched, just what has been stored)
  assign vmsa_page_4knot1m = utlb_entry[77];

  // Abort type bus
  // Stage 1 priority over stage 2. Main TLB priority over uTLB. Stage priority TLB/uTLB
  assign abort_type_o[6:0] = (main_tlb_abort == 2'b10 | main_tlb_abort == 2'b01) ? utlb_entry[88:82]                                : // stage 1 main TLB or stage 2 due to stage1 pagewalk
                             (domain_abort             & ~vmsa_page_4knot1m)     ?  `CA53_FAULT_LPAE_DOMAIN_L1                      : // stage 1 uTLB
                             (domain_abort             &  vmsa_page_4knot1m)     ?  `CA53_FAULT_LPAE_DOMAIN_L2                      : //
                             (permission_abort_s1                          )     ? {`CA53_FAULT_LPAE_PERMISSION, s1level}           : //
                             (main_tlb_abort == 2'b11                      )     ? utlb_entry[88:82]                                : // stage 2 main TLB
                             (permission_abort_s2                          )     ? {`CA53_FAULT_LPAE_PERMISSION, utlb_entry[79:78]} : // stage 2 uTLB
                             {7{1'b0}};

  // Stage-2 abort indicator
  // The upper bit is set if there is any kind of stage-2 abort (following the correct priority)
  // and the lower bit is set if the stage-2 abort was caused by a first stage pagewalk.
  assign stage2_abort_o[0] =  main_tlb_abort == 2'b01;
  assign stage2_abort_o[1] = (main_tlb_abort == 2'b01                                     ) ? 1'b1 : // stage 2 due to stage1 pagewalk
                             (main_tlb_abort == 2'b10 | domain_abort | permission_abort_s1) ? 1'b0 : // stage 1
                             (main_tlb_abort == 2'b11 | permission_abort_s2               ) ? 1'b1 : // stage 2
                             1'b0;

  // LPAE abort indicator
  // This signal is set if at the time of the data arriving we were in lpae mode
  assign lpae_abort_o = abort_lpae_mode;

  // Non-secure bit
  assign ns_dsc_if1_o = utlb_entry[65];

  // Physical address
  assign pa_if1_o[39:12] = {utlb_entry[64:45], (utlb_entry[96] ? va_if1_i[19:12] : utlb_entry[44:37])};

  // Attributes
  assign attr_if1_o[7:0] = utlb_entry[75:68];

  // Intermediate Physical Address (IPA) for stage-2 aborts
  assign abort_ipa_if1_o[27:0] = utlb_entry[64:37];

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_entry_enable_i")
  u_ovl_x_utlb_entry_enable_i (.clk       (clk_iutlb),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_entry_enable_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_valid_enable_i")
  u_ovl_x_utlb_valid_enable_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_valid_enable_i));


`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
