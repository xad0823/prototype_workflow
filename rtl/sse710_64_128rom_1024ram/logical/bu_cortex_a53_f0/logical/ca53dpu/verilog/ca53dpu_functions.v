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
// Abstract : DPU functions
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Condition code evaluation - returns true if condition holds
//-----------------------------------------------------------------------------
function  cc_eval;
  input [3:0] cond_code;
  input [3:0] ccflags;

  reg         nflag;
  reg         zflag;
  reg         cflag;
  reg         vflag;

  begin

    // Assign N,C,Z,V flags
    nflag = ccflags[3];
    zflag = ccflags[2];
    cflag = ccflags[1];
    vflag = ccflags[0];

    case (cond_code[3:0])
      `CA53_CC_EQ : cc_eval = zflag;
      `CA53_CC_NE : cc_eval = ~zflag;
      `CA53_CC_CS : cc_eval = cflag;
      `CA53_CC_CC : cc_eval = ~cflag;
      `CA53_CC_MI : cc_eval = nflag;
      `CA53_CC_PL : cc_eval = ~nflag;
      `CA53_CC_VS : cc_eval = vflag;
      `CA53_CC_VC : cc_eval = ~vflag;
      `CA53_CC_HI : cc_eval = cflag & ~zflag;
      `CA53_CC_LS : cc_eval = ~cflag | zflag;
      `CA53_CC_GE : cc_eval = (nflag == vflag);
      `CA53_CC_LT : cc_eval = (nflag != vflag);
      `CA53_CC_GT : cc_eval = ~zflag & (nflag == vflag);
      `CA53_CC_LE : cc_eval = zflag | (nflag != vflag);
      `CA53_CC_AL,
      `CA53_CC_NV : cc_eval = 1'b1;
      default     : cc_eval = 1'bx;
    endcase

  end
endfunction

