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
// Abstract : Interface data micro TLB entry including domain fault logic
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_utlb_intf_entry (
  // Inputs
  input  wire         clk,
  input  wire         clk_dutlb,
  input  wire         reset_n,
  input  wire         aarch64_state_iss_i,
  input  wire [47:12] agu_a_operand_i,
  input  wire [47:12] agu_b_operand_i,
  input  wire [48:12] agu_a_xor_agu_b_i,
  input  wire [47:12] agu_a_and_agu_b_i,
  input  wire         nxt_utlb_entry_valid_i,
  input  wire         utlb_valid_enable_i,
  input  wire         utlb_entry_enable_i,
  input  wire [95:0]  utlb_data_i,
  input  wire         tlb_d_utlb_lpae_i,
  input  wire [31:0]  transl_dacr_i,
  input  wire         transl_mmu_on_i,
  input  wire         carry_out_4k_i,
  input  wire         domain_fault_en_i,
  input  wire  [1:0]  dpu_exception_level_i,
  // Outputs
  output wire         utlb_entry_valid_o,
  output wire [82:0]  utlb_entry_o,
  output wire         hit_iss_o,
  output wire [39:12] pa_dc1_o,
  output wire [12:0]  attr_dc1_o,
  output wire  [8:0]  fault_dc1_o,
  output wire         ns_dsc_dc1_o,
  output wire  [3:0]  domain_dc1_o,
  output wire         abort_dc1_o,
  output wire  [3:0]  level_dc1_o,
  output wire         lpae_dc1_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg           transl_mmu_on;
  reg   [95:0]  utlb_entry;
  reg           utlb_entry_valid;
  reg    [1:0]  dacr_bits;
  reg           utlb_lpae;
  reg    [1:0]  fault_stage;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [48:12] csa_sum;
  wire  [47:12] csa_carry;
  wire  [48:12] combine_4k;
  wire          hit_4k;
  wire          excp_level_match;
  wire          domain_is_manager;
  wire          domain_fault;
  wire   [6:0]  domain_fault_type;
  wire   [6:0]  utlb_fault_type;
  wire   [2:0]  utlb_ap_dacr_remapped;
  wire          utlb_abort;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Micro TLB register
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      utlb_entry_valid <= 1'b0;
    else if (utlb_valid_enable_i)
      utlb_entry_valid <= nxt_utlb_entry_valid_i;

  // Register the micro-TLB data.
  // Domain     [95:92]
  // Fault type [91:85]
  // Fault      [84:83]
  // S2Level    [82:81]
  // S1Level    [80:79]
  // MemAttrs   [78:71]
  // HAP        [70:69]
  // AP/HYP     [68:66]
  // NS         [65]   
  // PA         [64:37]
  // VA         [36:0] 
  always @(posedge clk_dutlb)
    if (utlb_entry_enable_i) begin
      utlb_entry    <= utlb_data_i[95:0];
      utlb_lpae     <= tlb_d_utlb_lpae_i;
      transl_mmu_on <= transl_mmu_on_i;
    end

  // ------------------------------------------------------
  // Full adder for a+b=k calculation
  // ------------------------------------------------------

  assign csa_sum[48:12]   = agu_a_xor_agu_b_i[48:12] ^ ~utlb_entry[36:0];
  assign csa_carry[47:12] = agu_a_and_agu_b_i[47:12]                      |
                            (agu_a_operand_i[47:12] & ~utlb_entry[35:0])  |
                            (agu_b_operand_i[47:12] & ~utlb_entry[35:0]);

  // ------------------------------------------------------
  // Hit (final part of a+b=k calculation)
  // ------------------------------------------------------

  // Compute hit for 4-KByte page sizes
  // Carry calculation for bit 31 is special, as in AArch32 the address
  // addition should not cause a carry out of bit 31
  assign combine_4k[48:12] = csa_sum[48:12] ^ {csa_carry[47:32], csa_carry[31] & aarch64_state_iss_i, csa_carry[30:12], carry_out_4k_i};
  assign hit_4k            = &combine_4k;

  // EL2 and AArch64 EL3 use separate page tables
  assign excp_level_match  = ((dpu_exception_level_i == `CA53_EL3) & aarch64_state_iss_i) ? (utlb_entry[69:66] == 4'b1_100) :
                              (dpu_exception_level_i == `CA53_EL2)                        ? (utlb_entry[69:66] == 4'b0_100) :
                                                                                            (utlb_entry[68:66] !=   3'b100);

  // ------------------------------------------------------
  // Domain Fault
  // ------------------------------------------------------

  // The domain field from the first level descriptor indicates which part of
  // the DACR we should look at.
  always @*
  case (utlb_entry[95:92])
    4'b1111: dacr_bits = transl_dacr_i[31:30];
    4'b1110: dacr_bits = transl_dacr_i[29:28];
    4'b1101: dacr_bits = transl_dacr_i[27:26];
    4'b1100: dacr_bits = transl_dacr_i[25:24];
    4'b1011: dacr_bits = transl_dacr_i[23:22];
    4'b1010: dacr_bits = transl_dacr_i[21:20];
    4'b1001: dacr_bits = transl_dacr_i[19:18];
    4'b1000: dacr_bits = transl_dacr_i[17:16];
    4'b0111: dacr_bits = transl_dacr_i[15:14];
    4'b0110: dacr_bits = transl_dacr_i[13:12];
    4'b0101: dacr_bits = transl_dacr_i[11:10];
    4'b0100: dacr_bits = transl_dacr_i[9:8];
    4'b0011: dacr_bits = transl_dacr_i[7:6];
    4'b0010: dacr_bits = transl_dacr_i[5:4];
    4'b0001: dacr_bits = transl_dacr_i[3:2];
    4'b0000: dacr_bits = transl_dacr_i[1:0];
    default: dacr_bits = 2'bxx;
  endcase

  // The domain is a manager domain.
  assign domain_is_manager = (dacr_bits == 2'b11) & transl_mmu_on & ~utlb_lpae;

  // Generate a domain fault for No Access and Reserved domains but not if there is
  // a CP15 operation (for the load-store pipeline) other than V2P*
  assign domain_fault = ~dacr_bits[0] & transl_mmu_on & ~utlb_lpae & domain_fault_en_i;

  // Generate the domain fault type depending on section or page size
  assign domain_fault_type = utlb_entry[80] ? `CA53_FAULT_LPAE_DOMAIN_L2 : `CA53_FAULT_LPAE_DOMAIN_L1;

  // If there is a domain fault and there is no other fault, or a lower
  // priority stage2 fault, then update the fault field
  assign utlb_fault_type = (domain_fault & ~^utlb_entry[84:83]) ? domain_fault_type : utlb_entry[91:85];

  // Update abort bit
  assign utlb_abort = (|utlb_entry[84:83]) | domain_fault;

  // For client domains, just pass through the AP bits from the entry.
  // Force full access for manager domains.
  assign utlb_ap_dacr_remapped = domain_is_manager ? 3'b011 : utlb_entry[68:66];

  // ------------------------------------------------------
  // Output generation
  // ------------------------------------------------------

  // Valid entry when there is no domain fault
  assign utlb_entry_valid_o = utlb_entry_valid & ~(~dacr_bits[0] & transl_mmu_on & ~utlb_lpae);

  assign utlb_entry_o = {utlb_entry[82:69], utlb_ap_dacr_remapped, utlb_entry[65:0]};

  // Qualify the raw address match to form the final hit signal
  assign hit_iss_o = utlb_entry_valid & excp_level_match & hit_4k;

  // Signal physical address
  assign pa_dc1_o[39:12] = utlb_entry[64:37];

  // Attributes
  assign attr_dc1_o[12:0] = {utlb_entry[78:69], utlb_ap_dacr_remapped};

  // Fault information
  always @*
  case (utlb_entry[84:83])
    2'b00:   fault_stage = 2'b00;
    2'b01:   fault_stage = 2'b11;
    2'b10:   fault_stage = 2'b00;
    2'b11:   fault_stage = domain_fault ? 2'b00 : 2'b10;
    default: fault_stage = 2'bxx;
  endcase

  assign fault_dc1_o[8:0] = {fault_stage, utlb_fault_type};

  // Non-secure bit
  assign ns_dsc_dc1_o = utlb_entry[65];

  // Domain
  assign domain_dc1_o = utlb_entry[95:92];

  // Abort
  assign abort_dc1_o = utlb_abort;

  // Level
  assign level_dc1_o = utlb_entry[82:79];

  // LPAE
  assign lpae_dc1_o = utlb_lpae;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_entry_enable_i")
  u_ovl_x_utlb_entry_enable_i (.clk       (clk_dutlb),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_entry_enable_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: utlb_valid_enable_i")
  u_ovl_x_utlb_valid_enable_i (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (utlb_valid_enable_i));
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_utlb_intf_entry

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
