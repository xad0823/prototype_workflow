//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2013-01-03 17:03:25 +0000 (Thu, 03 Jan 2013) $
//
//      Revision            : $Revision: 232622 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Translates AArch32 virtual register number into AArch64 view
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// This module takes a four-bit AA32 register number as an input, along with
// the current mode. It produces the number of the AA64 register mapped on to
// that register. This is used for reporting the correct register number in the
// ESR for exceptions taken from AA32 to AA64.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_ctl_reg_aa32_aa64 (
  input  wire [3:0] aa32_addr_i,
  input  wire [4:0] cpsr_mode_ret_i,
  output reg  [4:0] aa64_addr_o
);

  always @*
    case (aa32_addr_i)
      // R0-7 are not banked so map straight through
      4'b0000: aa64_addr_o = `CA53_VADDR_R00;
      4'b0001: aa64_addr_o = `CA53_VADDR_R01;
      4'b0010: aa64_addr_o = `CA53_VADDR_R02;
      4'b0011: aa64_addr_o = `CA53_VADDR_R03;
      4'b0100: aa64_addr_o = `CA53_VADDR_R04;
      4'b0101: aa64_addr_o = `CA53_VADDR_R05;
      4'b0110: aa64_addr_o = `CA53_VADDR_R06;
      4'b0111: aa64_addr_o = `CA53_VADDR_R07;
      // R8-12 banked in FIQ mode
      4'b1000: aa64_addr_o = (cpsr_mode_ret_i == `CA53_FULL_MODE_FIQ) ? `CA53_VADDR_R24 : `CA53_VADDR_R08;
      4'b1001: aa64_addr_o = (cpsr_mode_ret_i == `CA53_FULL_MODE_FIQ) ? `CA53_VADDR_R25 : `CA53_VADDR_R09;
      4'b1010: aa64_addr_o = (cpsr_mode_ret_i == `CA53_FULL_MODE_FIQ) ? `CA53_VADDR_R26 : `CA53_VADDR_R10;
      4'b1011: aa64_addr_o = (cpsr_mode_ret_i == `CA53_FULL_MODE_FIQ) ? `CA53_VADDR_R27 : `CA53_VADDR_R11;
      4'b1100: aa64_addr_o = (cpsr_mode_ret_i == `CA53_FULL_MODE_FIQ) ? `CA53_VADDR_R28 : `CA53_VADDR_R12;
      // R13 banked in all modes
      // - Note monitor mode does not need to be dealt with, as can't be in monitor mode and taking
      // an exception to AA64
      4'b1101:
        case (cpsr_mode_ret_i)
          `CA53_FULL_MODE_USR,
          `CA53_FULL_MODE_SYS : aa64_addr_o = `CA53_VADDR_R13;
          `CA53_FULL_MODE_HYP : aa64_addr_o = `CA53_VADDR_R15;
          `CA53_FULL_MODE_SVC : aa64_addr_o = `CA53_VADDR_R19;
          `CA53_FULL_MODE_ABT : aa64_addr_o = `CA53_VADDR_R21;
          `CA53_FULL_MODE_UND : aa64_addr_o = `CA53_VADDR_R23;
          `CA53_FULL_MODE_IRQ : aa64_addr_o = `CA53_VADDR_R17;
          `CA53_FULL_MODE_FIQ : aa64_addr_o = `CA53_VADDR_R29;
          default             : aa64_addr_o = 5'bxxxxx;
        endcase
      // R14 banked in all modes except Hyp
      // - Note monitor mode does not need to be dealt with, as can't be in monitor mode and taking
      // an exception to AA64
      4'b1110:
        case (cpsr_mode_ret_i)
          `CA53_FULL_MODE_USR,
          `CA53_FULL_MODE_SYS,
          `CA53_FULL_MODE_HYP : aa64_addr_o = `CA53_VADDR_R14;
          `CA53_FULL_MODE_SVC : aa64_addr_o = `CA53_VADDR_R18;
          `CA53_FULL_MODE_ABT : aa64_addr_o = `CA53_VADDR_R20;
          `CA53_FULL_MODE_UND : aa64_addr_o = `CA53_VADDR_R22;
          `CA53_FULL_MODE_IRQ : aa64_addr_o = `CA53_VADDR_R16;
          `CA53_FULL_MODE_FIQ : aa64_addr_o = `CA53_VADDR_R30;
          default             : aa64_addr_o = 5'bxxxxx;
        endcase
      // No mapping for R15, but architecture defines register field in ESR should be 5'b11111 in
      // this case
      4'b1111: aa64_addr_o = 5'b11111;
      default: aa64_addr_o = 5'bxxxxx;
    endcase

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
