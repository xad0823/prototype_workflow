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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Translates a virtual register into a physical register
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// This module takes a four-bit register number as an input along with the mode of
// the current instruction (speculatively produced in the decode stage).  A six bit
// physical register number is produced.
//
// If the virtual address is R15 the physical address output defaults to R0.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de_reg_trans (
  // Inputs
  input  wire   [4:0] rf_rd_vaddr_de_i,
  input  wire  [11:0] exp_mode_de_i,
  // Outputs
  output reg    [5:0] rf_rd_addr_de_o
);

  // Translate the virtual register address into a physical register address
  always @*
    case (rf_rd_vaddr_de_i)
      `CA53_VADDR_R00: rf_rd_addr_de_o = `CA53_ADDR_X0;
      `CA53_VADDR_R01: rf_rd_addr_de_o = `CA53_ADDR_X1;
      `CA53_VADDR_R02: rf_rd_addr_de_o = `CA53_ADDR_X2;
      `CA53_VADDR_R03: rf_rd_addr_de_o = `CA53_ADDR_X3;
      `CA53_VADDR_R04: rf_rd_addr_de_o = `CA53_ADDR_X4;
      `CA53_VADDR_R05: rf_rd_addr_de_o = `CA53_ADDR_X5;
      `CA53_VADDR_R06: rf_rd_addr_de_o = `CA53_ADDR_X6;
      `CA53_VADDR_R07: rf_rd_addr_de_o = `CA53_ADDR_X7;
      `CA53_VADDR_R08: rf_rd_addr_de_o = exp_mode_de_i[1] ? `CA53_ADDR_R08_FIQ : `CA53_ADDR_X8;
      `CA53_VADDR_R09: rf_rd_addr_de_o = exp_mode_de_i[1] ? `CA53_ADDR_R09_FIQ : `CA53_ADDR_X9;
      `CA53_VADDR_R10: rf_rd_addr_de_o = exp_mode_de_i[1] ? `CA53_ADDR_R10_FIQ : `CA53_ADDR_X10;
      `CA53_VADDR_R11: rf_rd_addr_de_o = exp_mode_de_i[1] ? `CA53_ADDR_R11_FIQ : `CA53_ADDR_X11;
      `CA53_VADDR_R12: rf_rd_addr_de_o = exp_mode_de_i[1] ? `CA53_ADDR_R12_FIQ : `CA53_ADDR_X12;
      `CA53_VADDR_R13: rf_rd_addr_de_o = ({6{ exp_mode_de_i[0]}}    & `CA53_ADDR_R13)     |
                                         ({6{ exp_mode_de_i[1]}}    & `CA53_ADDR_R13_FIQ) |
                                         ({6{ exp_mode_de_i[2]}}    & `CA53_ADDR_R13_IRQ) |
                                         ({6{ exp_mode_de_i[3]}}    & `CA53_ADDR_R13_SVC) |
                                         ({6{ exp_mode_de_i[4]}}    & `CA53_ADDR_R13_ABT) |
                                         ({6{ exp_mode_de_i[5]}}    & `CA53_ADDR_R13_UND) |
                                         ({6{ exp_mode_de_i[6]}}    & `CA53_ADDR_R13_MON) |
                                         ({6{ exp_mode_de_i[7]}}    & `CA53_ADDR_R13_HYP) |
                                         ({6{|exp_mode_de_i[11:8]}} & `CA53_ADDR_X13);
      `CA53_VADDR_R14: rf_rd_addr_de_o = ({6{ exp_mode_de_i[0]}}    & `CA53_ADDR_R14)     |
                                         ({6{ exp_mode_de_i[1]}}    & `CA53_ADDR_R14_FIQ) |
                                         ({6{ exp_mode_de_i[2]}}    & `CA53_ADDR_R14_IRQ) |
                                         ({6{ exp_mode_de_i[3]}}    & `CA53_ADDR_R14_SVC) |
                                         ({6{ exp_mode_de_i[4]}}    & `CA53_ADDR_R14_ABT) |
                                         ({6{ exp_mode_de_i[5]}}    & `CA53_ADDR_R14_UND) |
                                         ({6{ exp_mode_de_i[6]}}    & `CA53_ADDR_R14_MON) |
                                         ({6{ exp_mode_de_i[7]}}    & `CA53_ADDR_R14)     |
                                         ({6{|exp_mode_de_i[11:8]}} & `CA53_ADDR_X14);
      // AArch64 only below
      `CA53_VADDR_R15: rf_rd_addr_de_o = `CA53_ADDR_X15;
      `CA53_VADDR_R16: rf_rd_addr_de_o = `CA53_ADDR_X16;
      `CA53_VADDR_R17: rf_rd_addr_de_o = `CA53_ADDR_X17;
      `CA53_VADDR_R18: rf_rd_addr_de_o = `CA53_ADDR_X18;
      `CA53_VADDR_R19: rf_rd_addr_de_o = `CA53_ADDR_X19;
      `CA53_VADDR_R20: rf_rd_addr_de_o = `CA53_ADDR_X20;
      `CA53_VADDR_R21: rf_rd_addr_de_o = `CA53_ADDR_X21;
      `CA53_VADDR_R22: rf_rd_addr_de_o = `CA53_ADDR_X22;
      `CA53_VADDR_R23: rf_rd_addr_de_o = `CA53_ADDR_X23;
      `CA53_VADDR_R24: rf_rd_addr_de_o = `CA53_ADDR_X24;
      `CA53_VADDR_R25: rf_rd_addr_de_o = `CA53_ADDR_X25;
      `CA53_VADDR_R26: rf_rd_addr_de_o = `CA53_ADDR_X26;
      `CA53_VADDR_R27: rf_rd_addr_de_o = `CA53_ADDR_X27;
      `CA53_VADDR_R28: rf_rd_addr_de_o = `CA53_ADDR_X28;
      `CA53_VADDR_R29: rf_rd_addr_de_o = `CA53_ADDR_X29;
      `CA53_VADDR_R30: rf_rd_addr_de_o = `CA53_ADDR_X30;
      `CA53_VADDR_R31: rf_rd_addr_de_o = ({6{ exp_mode_de_i[ 8]}}    & `CA53_ADDR_SP_EL0) |
                                         ({6{ exp_mode_de_i[ 9]}}    & `CA53_ADDR_SP_EL1) |
                                         ({6{ exp_mode_de_i[10]}}    & `CA53_ADDR_SP_EL2) |
                                         ({6{ exp_mode_de_i[11]}}    & `CA53_ADDR_SP_EL3);
      default:         rf_rd_addr_de_o = {6{1'bx}};
    endcase

endmodule // ca53dpu_de_reg_trans

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
