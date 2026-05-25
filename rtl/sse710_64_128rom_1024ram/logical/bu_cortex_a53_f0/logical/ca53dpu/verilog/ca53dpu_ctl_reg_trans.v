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
// Abstract : Translates virtual register numbers into physical ones
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// This module takes a five-bit register number as an input (normally
// extracted from an instruction encoding), along with the mode of the
// current instruction (speculatively produced in the decode stage).  It
// produces a six bit register number which can address all the physical
// registers.
//
// Additionally, a signal can force the translation to behave as if it were
// happening in USR mode, regardless of the actual mode.
//
// If the virtual address is R15 the physical address output defaults to R0.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_ctl_reg_trans (
  input  wire [4:0] vaddr_i,
  input  wire [4:0] rf_wr_mode_iss_i,
  input  wire [5:0] msr_mrs_data_i,
  input  wire       msr_mrs_reg_i,
  input  wire       force_usr_mode_i,
  output wire [5:0] addr_o
);

  reg  [11:0] mode;
  reg   [5:0] paddress;

  // Create one-hot control signals for the CPSR mode bits
  always @*
    case (rf_wr_mode_iss_i)
      `CA53_FULL_MODE_NONUSE,
      `CA53_FULL_MODE_SYS,
      `CA53_FULL_MODE_USR  : mode = 12'b0000_0000_0001;
      `CA53_FULL_MODE_FIQ  : mode = 12'b0000_0000_0010;
      `CA53_FULL_MODE_IRQ  : mode = 12'b0000_0000_0100;
      `CA53_FULL_MODE_SVC  : mode = 12'b0000_0000_1000;
      `CA53_FULL_MODE_ABT  : mode = 12'b0000_0001_0000;
      `CA53_FULL_MODE_UND  : mode = 12'b0000_0010_0000;
      `CA53_FULL_MODE_MON  : mode = 12'b0000_0100_0000;
      `CA53_FULL_MODE_HYP  : mode = 12'b0000_1000_0000;
      `CA53_FULL_MODE_EL0T : mode = 12'b0001_0000_0000;
      `CA53_FULL_MODE_EL1T : mode = 12'b0001_0000_0000;
      `CA53_FULL_MODE_EL2T : mode = 12'b0001_0000_0000;
      `CA53_FULL_MODE_EL3T : mode = 12'b0001_0000_0000;
      `CA53_FULL_MODE_EL1H : mode = 12'b0010_0000_0000;
      `CA53_FULL_MODE_EL2H : mode = 12'b0100_0000_0000;
      `CA53_FULL_MODE_EL3H : mode = 12'b1000_0000_0000;
      default              : mode = 12'bxxxx_xxxx_xxxx;
    endcase

  always @*
    case (vaddr_i)
      `CA53_VADDR_R00: paddress = `CA53_ADDR_X0;
      `CA53_VADDR_R01: paddress = `CA53_ADDR_X1;
      `CA53_VADDR_R02: paddress = `CA53_ADDR_X2;
      `CA53_VADDR_R03: paddress = `CA53_ADDR_X3;
      `CA53_VADDR_R04: paddress = `CA53_ADDR_X4;
      `CA53_VADDR_R05: paddress = `CA53_ADDR_X5;
      `CA53_VADDR_R06: paddress = `CA53_ADDR_X6;
      `CA53_VADDR_R07: paddress = `CA53_ADDR_X7;
      `CA53_VADDR_R08: paddress = (mode[1] & ~force_usr_mode_i) ? `CA53_ADDR_R08_FIQ : `CA53_ADDR_X8;
      `CA53_VADDR_R09: paddress = (mode[1] & ~force_usr_mode_i) ? `CA53_ADDR_R09_FIQ : `CA53_ADDR_X9;
      `CA53_VADDR_R10: paddress = (mode[1] & ~force_usr_mode_i) ? `CA53_ADDR_R10_FIQ : `CA53_ADDR_X10;
      `CA53_VADDR_R11: paddress = (mode[1] & ~force_usr_mode_i) ? `CA53_ADDR_R11_FIQ : `CA53_ADDR_X11;
      `CA53_VADDR_R12: paddress = (mode[1] & ~force_usr_mode_i) ? `CA53_ADDR_R12_FIQ : `CA53_ADDR_X12;
      `CA53_VADDR_R13: paddress = ({6{ mode[0]      |  force_usr_mode_i}} & `CA53_ADDR_R13)       |
                                  ({6{ mode[1]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_FIQ)   |
                                  ({6{ mode[2]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_IRQ)   |
                                  ({6{ mode[3]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_SVC)   |
                                  ({6{ mode[4]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_ABT)   |
                                  ({6{ mode[5]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_UND)   |
                                  ({6{ mode[6]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_MON)   |
                                  ({6{ mode[7]      & ~force_usr_mode_i}} & `CA53_ADDR_R13_HYP)   |
                                  ({6{(|mode[11:8]) & ~force_usr_mode_i}} & `CA53_ADDR_X13);
      `CA53_VADDR_R14: paddress = ({6{ mode[0]      |  force_usr_mode_i}} & `CA53_ADDR_R14)       |
                                  ({6{ mode[1]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_FIQ)   |
                                  ({6{ mode[2]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_IRQ)   |
                                  ({6{ mode[3]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_SVC)   |
                                  ({6{ mode[4]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_ABT)   |
                                  ({6{ mode[5]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_UND)   |
                                  ({6{ mode[6]      & ~force_usr_mode_i}} & `CA53_ADDR_R14_MON)   |
                                  ({6{ mode[7]      & ~force_usr_mode_i}} & `CA53_ADDR_R14)       |
                                  ({6{(|mode[11:8]) & ~force_usr_mode_i}} & `CA53_ADDR_X14);
      `CA53_VADDR_R15: paddress = `CA53_ADDR_X15;
      `CA53_VADDR_R16: paddress = `CA53_ADDR_X16;
      `CA53_VADDR_R17: paddress = `CA53_ADDR_X17;
      `CA53_VADDR_R18: paddress = `CA53_ADDR_X18;
      `CA53_VADDR_R19: paddress = `CA53_ADDR_X19;
      `CA53_VADDR_R20: paddress = `CA53_ADDR_X20;
      `CA53_VADDR_R21: paddress = `CA53_ADDR_X21;
      `CA53_VADDR_R22: paddress = `CA53_ADDR_X22;
      `CA53_VADDR_R23: paddress = `CA53_ADDR_X23;
      `CA53_VADDR_R24: paddress = `CA53_ADDR_X24;
      `CA53_VADDR_R25: paddress = `CA53_ADDR_X25;
      `CA53_VADDR_R26: paddress = `CA53_ADDR_X26;
      `CA53_VADDR_R27: paddress = `CA53_ADDR_X27;
      `CA53_VADDR_R28: paddress = `CA53_ADDR_X28;
      `CA53_VADDR_R29: paddress = `CA53_ADDR_X29;
      `CA53_VADDR_R30: paddress = `CA53_ADDR_X30;
      `CA53_VADDR_R31: paddress = ({6{ mode[ 8]}} & `CA53_ADDR_SP_EL0)  |
                                  ({6{ mode[ 9]}} & `CA53_ADDR_SP_EL1)  |
                                  ({6{ mode[10]}} & `CA53_ADDR_SP_EL2)  |
                                  ({6{ mode[11]}} & `CA53_ADDR_SP_EL3);
      default:         paddress = {6{1'bx}};
    endcase

  assign addr_o = msr_mrs_reg_i ? msr_mrs_data_i : paddress;

endmodule // ca53dpu_ctl_reg_trans

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
