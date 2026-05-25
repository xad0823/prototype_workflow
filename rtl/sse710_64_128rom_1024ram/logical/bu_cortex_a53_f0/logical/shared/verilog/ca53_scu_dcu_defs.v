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


// This is the specification for the interface between the SCU and the DCU for
// snoop requests.
// Inputs and outputs are from the point of view of the SCU.

`ifndef CA53_UNDEFINE

`define CA53_SNOOP_MAKEINVALID     4'b0000
`define CA53_SNOOP_GETDIRTY        4'b0001
`define CA53_SNOOP_MAKECLEANSHARED 4'b0010
`define CA53_SNOOP_CLEANSHARED     4'b0011
`define CA53_SNOOP_CLEANINVALID    4'b0100
`define CA53_SNOOP_READONCE        4'b0101
`define CA53_SNOOP_READSHARED      4'b0110
`define CA53_SNOOP_READMAKESHARED  4'b0111
`define CA53_SNOOP_DVM             4'b1000

`else

`undef CA53_SNOOP_MAKEINVALID
`undef CA53_SNOOP_GETDIRTY
`undef CA53_SNOOP_MAKECLEANSHARED
`undef CA53_SNOOP_CLEANSHARED
`undef CA53_SNOOP_CLEANINVALID
`undef CA53_SNOOP_READONCE
`undef CA53_SNOOP_READSHARED
`undef CA53_SNOOP_READMAKESHARED
`undef CA53_SNOOP_DVM

`endif
