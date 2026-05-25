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


// This is the specification for the interface between the BIU and the SCU for
// the read and write channels. The signals closely follow their equivalents in
// ACE.

// Inputs and outputs are from the point of view of the BIU.
// Note that the SCU has up to four copies of this interface, so the actual
// signal names will be modified based on the CPU they refer to.

`ifndef CA53_UNDEFINE

  `define CA53_REQ_READNOSNOOP     5'b00000
  `define CA53_REQ_READONCE        5'b00001
  `define CA53_REQ_READSHARED      5'b00010
  `define CA53_REQ_READUNIQUE      5'b00011
  `define CA53_REQ_CLEANUNIQUE     5'b00100
  `define CA53_REQ_CLEANSHARED     5'b00101
  `define CA53_REQ_CLEANINVALID    5'b00110
  `define CA53_REQ_MAKEINVALID     5'b00111
  `define CA53_REQ_READNONE        5'b01000
  `define CA53_REQ_DMB             5'b01010
  `define CA53_REQ_DSB             5'b01011
  `define CA53_REQ_CLEANSETWAY     5'b01100
  `define CA53_REQ_CLEANINVSETWAY  5'b01101
  `define CA53_REQ_ECCCLEAN        5'b01111
  `define CA53_REQ_WRITENOSNOOP    5'b10000
  `define CA53_REQ_WRITEUNIQUE     5'b10001
  `define CA53_REQ_DVM             5'b11000
  `define CA53_RID_DCU0      5'b00000
  `define CA53_RID_DCU1      5'b00001
  `define CA53_RID_DCU2      5'b00010
  `define CA53_RID_DCU3      5'b00011
  `define CA53_RID_LFB0      5'b01000
  `define CA53_RID_LFB1      5'b01001
  `define CA53_RID_LFB2      5'b01010
  `define CA53_RID_LFB3      5'b01011
  `define CA53_RID_LFB4      5'b01100
  `define CA53_RID_LFB5      5'b01101
  `define CA53_RID_LFB6      5'b01110
  `define CA53_RID_LFB7      5'b01111
  `define CA53_RID_ICU0      5'b10000
  `define CA53_RID_ICU1      5'b10001
  `define CA53_RID_ICU2      5'b10010
  `define CA53_RID_TLB       5'b10100
  `define CA53_RID_ECC       5'b10110
  `define CA53_RID_RNONE     5'b10111
  `define CA53_RID_STB0      5'b11000
  `define CA53_RID_STB1      5'b11001
  `define CA53_RID_STB2      5'b11010
  `define CA53_RID_STB3      5'b11011
  `define CA53_RID_STB4      5'b11100
  `define CA53_RID_L2FLUSH   5'b11111
`define CA53_DVM_TLBINVIS `CA53_ACE_DVM_TLBINV
`define CA53_DVM_BPINVIS  `CA53_ACE_DVM_BPINV
`define CA53_DVM_ICPINVIS `CA53_ACE_DVM_PHYSICINV
`define CA53_DVM_ICVINVIS `CA53_ACE_DVM_VIRTICINV
`define CA53_DVM_SYNC     `CA53_ACE_DVM_SYNC
`define CA53_DVM_TLBINV   3'b101
`define CA53_DVM_ICINV    3'b111

`else

`undef CA53_REQ_READNOSNOOP
`undef CA53_REQ_READONCE
`undef CA53_REQ_READSHARED
`undef CA53_REQ_READUNIQUE
`undef CA53_REQ_CLEANUNIQUE
`undef CA53_REQ_CLEANSHARED
`undef CA53_REQ_CLEANINVALID
`undef CA53_REQ_MAKEINVALID
`undef CA53_REQ_READNONE
`undef CA53_REQ_DMB
`undef CA53_REQ_DSB
`undef CA53_REQ_CLEANSETWAY
`undef CA53_REQ_CLEANINVSETWAY
`undef CA53_REQ_ECCCLEAN
`undef CA53_REQ_WRITENOSNOOP
`undef CA53_REQ_WRITEUNIQUE
`undef CA53_REQ_DVM
`undef CA53_RID_DCU0
`undef CA53_RID_DCU1
`undef CA53_RID_DCU2
`undef CA53_RID_DCU3
`undef CA53_RID_LFB0
`undef CA53_RID_LFB1
`undef CA53_RID_LFB2
`undef CA53_RID_LFB3
`undef CA53_RID_LFB4
`undef CA53_RID_LFB5
`undef CA53_RID_LFB6
`undef CA53_RID_LFB7
`undef CA53_RID_ICU0
`undef CA53_RID_ICU1
`undef CA53_RID_ICU2
`undef CA53_RID_TLB
`undef CA53_RID_ECC
`undef CA53_RID_RNONE
`undef CA53_RID_STB0
`undef CA53_RID_STB1
`undef CA53_RID_STB2
`undef CA53_RID_STB3
`undef CA53_RID_STB4
`undef CA53_RID_L2FLUSH
`undef CA53_DVM_TLBINVIS
`undef CA53_DVM_BPINVIS
`undef CA53_DVM_ICPINVIS
`undef CA53_DVM_ICVINVIS
`undef CA53_DVM_SYNC
`undef CA53_DVM_TLBINV
`undef CA53_DVM_ICINV

`endif
