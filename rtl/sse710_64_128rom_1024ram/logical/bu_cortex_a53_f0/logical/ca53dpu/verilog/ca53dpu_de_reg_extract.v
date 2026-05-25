//------------------------------------------------------------------------------
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
//      Checked In          : $Date: 2010-08-18 11:05:53 +0100 (Wed, 18 Aug 2010) $
//
//      Revision            : $Revision: 146096 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Extract one-hot/encoded r0 and r1 addresses in the De stage
//------------------------------------------------------------------------------
//
// Generate the encoded and one-hot r0/r1 De stage register address for the AGU
// address ports.  This is purely a timing optimization to get the lower bits
// of the base and offset operands as early as possible.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de_reg_extract (
  // Inputs
  input  wire                       [4:0] vaddr_base_i,
  input  wire                       [4:0] vaddr_offset_i,
  input  wire                      [11:0] exp_cpsr_mode_de_i,
  input  wire                       [7:0] exp_srs_mode_de_i,
  input  wire                             srs_mode_ctl_de_i,
  // Outputs
  output wire                       [5:0] rf_r0_for_fwd_check_de_o,
  output wire                       [5:0] rf_r1_for_fwd_check_de_o,
  output wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r0_agu_de_o,
  output wire  [`CA53_LONG_RF_ADDR_W-1:0] rf_rd_addr_r1_agu_de_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [`CA53_LONG_RF_ADDR_W-1:8] mode_mask_aarch32;
  reg  [`CA53_LONG_RF_ADDR_W-1:8] mode_mask_aarch64;
  reg                       [7:0] long_addr_r0_raw_low;
  reg  [`CA53_LONG_RF_ADDR_W-1:8] long_addr_r0_raw_aarch32;
  reg  [`CA53_LONG_RF_ADDR_W-1:8] long_addr_r0_raw_aarch64;
  reg  [`CA53_LONG_RF_ADDR_W-1:0] long_addr_r0_srs;
  reg                       [7:0] long_addr_r1_raw_low;
  reg  [`CA53_LONG_RF_ADDR_W-1:8] long_addr_r1_raw_aarch32;
  reg  [`CA53_LONG_RF_ADDR_W-1:8] long_addr_r1_raw_aarch64;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                      [5:0] paddr_base_srs;
  wire                      [5:0] paddr_base_no_srs;
  wire                      [5:0] paddr_offset;
  wire [`CA53_LONG_RF_ADDR_W-1:0] long_addr_r0_nonsrs;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Encoded R0
  // ------------------------------------------------------

  // Logical to physical address translation
  ca53dpu_de_reg_trans u_regtrans_base_srs (
    .rf_rd_vaddr_de_i (`CA53_VADDR_R13),
    .exp_mode_de_i    ({4'b0000, exp_srs_mode_de_i[7:0]}),
    .rf_rd_addr_de_o  (paddr_base_srs[5:0])
  );

  ca53dpu_de_reg_trans u_regtrans_base_no_srs (
    .rf_rd_vaddr_de_i (vaddr_base_i[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (paddr_base_no_srs[5:0])
  );

  // Choose between the SRS and non-SRS path for the encoded physical register
  assign rf_r0_for_fwd_check_de_o[5:0] = srs_mode_ctl_de_i ? paddr_base_srs[5:0] : paddr_base_no_srs[5:0];

  // ------------------------------------------------------
  // Encoded R1
  // ------------------------------------------------------

  // Logical to physical address translation
  ca53dpu_de_reg_trans u_regtrans_offset (
    .rf_rd_vaddr_de_i (vaddr_offset_i[4:0]),
    .exp_mode_de_i    (exp_cpsr_mode_de_i[11:0]),
    .rf_rd_addr_de_o  (paddr_offset[5:0])
  );

  assign rf_r1_for_fwd_check_de_o[5:0] = paddr_offset[5:0];

  // ------------------------------------------------------
  // Mode mask for one-hot R0/R1
  // ------------------------------------------------------

  // Mask for one-hot non-SRS form
  always @* begin
    mode_mask_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};
    mode_mask_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};
    case (exp_cpsr_mode_de_i[11:0])
      `CA53_ONEHOT_MODE_USR_SYS : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14] = 1'b1;
      end
      `CA53_ONEHOT_MODE_IRQ : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_IRQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_IRQ] = 1'b1;
      end
      `CA53_ONEHOT_MODE_SVC : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_SVC] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_SVC] = 1'b1;
      end
      `CA53_ONEHOT_MODE_ABT : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_ABT] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_ABT] = 1'b1;
      end
      `CA53_ONEHOT_MODE_UND : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_UND] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_UND] = 1'b1;
      end
      `CA53_ONEHOT_MODE_FIQ : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_FIQ] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_FIQ] = 1'b1;
      end
      `CA53_ONEHOT_MODE_MON : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_MON] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14_MON] = 1'b1;
      end
      `CA53_ONEHOT_MODE_HYP : begin
        mode_mask_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R13_HYP] = 1'b1;
        mode_mask_aarch32[`CA53_ADDR_BIT_R14]     = 1'b1;
      end
      `CA53_ONEHOT_MODE_ELXT : begin
        mode_mask_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X15]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X16]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X17]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X18]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X19]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X20]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X21]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X22]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X23]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X24]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X25]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X26]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X27]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X28]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X29]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X30]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_SP_EL0]  = 1'b1;
      end
      `CA53_ONEHOT_MODE_EL1H : begin
        mode_mask_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X15]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X16]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X17]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X18]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X19]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X20]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X21]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X22]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X23]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X24]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X25]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X26]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X27]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X28]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X29]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X30]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_SP_EL1]  = 1'b1;
      end
      `CA53_ONEHOT_MODE_EL2H : begin
        mode_mask_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X15]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X16]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X17]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X18]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X19]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X20]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X21]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X22]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X23]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X24]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X25]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X26]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X27]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X28]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X29]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X30]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_SP_EL2]  = 1'b1;
      end
      `CA53_ONEHOT_MODE_EL3H : begin
        mode_mask_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X15]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X16]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X17]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X18]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X19]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X20]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X21]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X22]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X23]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X24]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X25]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X26]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X27]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X28]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X29]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_X30]     = 1'b1;
        mode_mask_aarch64[`CA53_ADDR_BIT_SP_EL3]  = 1'b1;
      end
      default : begin
        mode_mask_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
        mode_mask_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // One-hot R0
  // ------------------------------------------------------

  // Non-SRS path
  always @* begin
    long_addr_r0_raw_low     = {8{1'b0}};
    long_addr_r0_raw_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};
    long_addr_r0_raw_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};

    case (vaddr_base_i)
      `CA53_VADDR_R00 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R00] = 1'b1;
      `CA53_VADDR_R01 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R01] = 1'b1;
      `CA53_VADDR_R02 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R02] = 1'b1;
      `CA53_VADDR_R03 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R03] = 1'b1;
      `CA53_VADDR_R04 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R04] = 1'b1;
      `CA53_VADDR_R05 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R05] = 1'b1;
      `CA53_VADDR_R06 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R06] = 1'b1;
      `CA53_VADDR_R07 : long_addr_r0_raw_low[`CA53_ADDR_BIT_R07] = 1'b1;
      `CA53_VADDR_R08 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R08_FIQ] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
      end
      `CA53_VADDR_R09 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R09_FIQ] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
      end
      `CA53_VADDR_R10 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R10_FIQ] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
      end
      `CA53_VADDR_R11 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R11_FIQ] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
      end
      `CA53_VADDR_R12 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R12_FIQ] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
      end
      `CA53_VADDR_R13 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_FIQ] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_UND] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_ABT] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_SVC] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_IRQ] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_MON] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R13_HYP] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
      end
      `CA53_VADDR_R14 : begin
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14]     = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_FIQ] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_UND] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_ABT] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_SVC] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_IRQ] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_R14_MON] = 1'b1;
        long_addr_r0_raw_aarch32[`CA53_ADDR_BIT_ELR_HYP] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
      end
      `CA53_VADDR_R15 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X15] = 1'b1;
      `CA53_VADDR_R16 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X16] = 1'b1;
      `CA53_VADDR_R17 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X17] = 1'b1;
      `CA53_VADDR_R18 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X18] = 1'b1;
      `CA53_VADDR_R19 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X19] = 1'b1;
      `CA53_VADDR_R20 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X20] = 1'b1;
      `CA53_VADDR_R21 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X21] = 1'b1;
      `CA53_VADDR_R22 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X22] = 1'b1;
      `CA53_VADDR_R23 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X23] = 1'b1;
      `CA53_VADDR_R24 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X24] = 1'b1;
      `CA53_VADDR_R25 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X25] = 1'b1;
      `CA53_VADDR_R26 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X26] = 1'b1;
      `CA53_VADDR_R27 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X27] = 1'b1;
      `CA53_VADDR_R28 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X28] = 1'b1;
      `CA53_VADDR_R29 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X29] = 1'b1;
      `CA53_VADDR_R30 : long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_X30] = 1'b1;
      `CA53_VADDR_R31 : begin
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_SP_EL0] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_SP_EL1] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_SP_EL2] = 1'b1;
        long_addr_r0_raw_aarch64[`CA53_ADDR_BIT_SP_EL3] = 1'b1;
      end
      default : begin
        long_addr_r0_raw_low     = {8{1'bx}};
        long_addr_r0_raw_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
        long_addr_r0_raw_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
      end
    endcase
  end

  // Apply the mode mask to the non-SRS path
  assign long_addr_r0_nonsrs = {((mode_mask_aarch32 & long_addr_r0_raw_aarch32) |
                                 (mode_mask_aarch64 & long_addr_r0_raw_aarch64)),
                                long_addr_r0_raw_low};

  // SRS path
  always @* begin
    long_addr_r0_srs = {`CA53_LONG_RF_ADDR_W{1'b0}};
    case ({4'b0000, exp_srs_mode_de_i[7:0]})
      `CA53_ONEHOT_MODE_USR_SYS : long_addr_r0_srs[`CA53_ADDR_BIT_R13]     = 1'b1;
      `CA53_ONEHOT_MODE_IRQ     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_IRQ] = 1'b1;
      `CA53_ONEHOT_MODE_SVC     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_SVC] = 1'b1;
      `CA53_ONEHOT_MODE_ABT     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_ABT] = 1'b1;
      `CA53_ONEHOT_MODE_UND     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_UND] = 1'b1;
      `CA53_ONEHOT_MODE_FIQ     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_FIQ] = 1'b1;
      `CA53_ONEHOT_MODE_MON     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_MON] = 1'b1;
      `CA53_ONEHOT_MODE_HYP     : long_addr_r0_srs[`CA53_ADDR_BIT_R13_HYP] = 1'b1;
      default                   : long_addr_r0_srs = {`CA53_LONG_RF_ADDR_W{1'bx}};
    endcase
  end

  assign rf_rd_addr_r0_agu_de_o = srs_mode_ctl_de_i ? long_addr_r0_srs : long_addr_r0_nonsrs;

  // ------------------------------------------------------
  // One-hot R1
  // ------------------------------------------------------

  // R1 physical address (one_hot)
  always @* begin
    long_addr_r1_raw_low     = {8{1'b0}};
    long_addr_r1_raw_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};
    long_addr_r1_raw_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'b0}};

    case (vaddr_offset_i)
      `CA53_VADDR_R00 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R00] = 1'b1;
      `CA53_VADDR_R01 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R01] = 1'b1;
      `CA53_VADDR_R02 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R02] = 1'b1;
      `CA53_VADDR_R03 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R03] = 1'b1;
      `CA53_VADDR_R04 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R04] = 1'b1;
      `CA53_VADDR_R05 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R05] = 1'b1;
      `CA53_VADDR_R06 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R06] = 1'b1;
      `CA53_VADDR_R07 : long_addr_r1_raw_low[`CA53_ADDR_BIT_R07] = 1'b1;
      `CA53_VADDR_R08 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R08]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R08_FIQ] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X8]      = 1'b1;
      end
      `CA53_VADDR_R09 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R09]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R09_FIQ] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X9]      = 1'b1;
      end
      `CA53_VADDR_R10 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R10]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R10_FIQ] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X10]     = 1'b1;
      end
      `CA53_VADDR_R11 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R11]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R11_FIQ] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X11]     = 1'b1;
      end
      `CA53_VADDR_R12 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R12]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R12_FIQ] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X12]     = 1'b1;
      end
      `CA53_VADDR_R13 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_FIQ] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_UND] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_ABT] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_SVC] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_IRQ] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_MON] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R13_HYP] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X13]     = 1'b1;
      end
      `CA53_VADDR_R14 : begin
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14]     = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_FIQ] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_UND] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_ABT] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_SVC] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_IRQ] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_R14_MON] = 1'b1;
        long_addr_r1_raw_aarch32[`CA53_ADDR_BIT_ELR_HYP] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X14]     = 1'b1;
      end
      `CA53_VADDR_R15 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X15] = 1'b1;
      `CA53_VADDR_R16 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X16] = 1'b1;
      `CA53_VADDR_R17 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X17] = 1'b1;
      `CA53_VADDR_R18 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X18] = 1'b1;
      `CA53_VADDR_R19 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X19] = 1'b1;
      `CA53_VADDR_R20 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X20] = 1'b1;
      `CA53_VADDR_R21 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X21] = 1'b1;
      `CA53_VADDR_R22 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X22] = 1'b1;
      `CA53_VADDR_R23 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X23] = 1'b1;
      `CA53_VADDR_R24 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X24] = 1'b1;
      `CA53_VADDR_R25 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X25] = 1'b1;
      `CA53_VADDR_R26 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X26] = 1'b1;
      `CA53_VADDR_R27 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X27] = 1'b1;
      `CA53_VADDR_R28 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X28] = 1'b1;
      `CA53_VADDR_R29 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X29] = 1'b1;
      `CA53_VADDR_R30 : long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_X30] = 1'b1;
      `CA53_VADDR_R31 : begin
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_SP_EL0] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_SP_EL1] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_SP_EL2] = 1'b1;
        long_addr_r1_raw_aarch64[`CA53_ADDR_BIT_SP_EL3] = 1'b1;
      end
      default : begin
        long_addr_r1_raw_low     = {8{1'bx}};
        long_addr_r1_raw_aarch32 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
        long_addr_r1_raw_aarch64 = {`CA53_LONG_RF_ADDR_W-8{1'bx}};
      end
    endcase
  end

  assign rf_rd_addr_r1_agu_de_o = {((mode_mask_aarch32 & long_addr_r1_raw_aarch32) |
                                    (mode_mask_aarch64 & long_addr_r1_raw_aarch64)),
                                   long_addr_r1_raw_low};

endmodule // ca53dpu_de_reg_extract

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
