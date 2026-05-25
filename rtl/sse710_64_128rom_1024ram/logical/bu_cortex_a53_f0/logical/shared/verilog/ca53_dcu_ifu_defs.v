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

// This is the specification for the interface between the DCU and IFU for CP15
// cache maintenance and debug operations, and MBIST data.
// The DCU accepts and arbitrates requests from the DPU and the SCU, and passes
// the relevant operations on to the IFU for execution.

`ifndef CA53_UNDEFINE

`define CA53_CP_ICACHE_INV_ALL   3'b100 // Invalidate entire instruction cache
`define CA53_CP_ICACHE_INV_VA    3'b101 // Invalidate instruction cache by VA
`define CA53_CP_ICACHE_INV_PA    3'b110 // Invalidate instruction cache by PA
`define CA53_CP_ICACHE_INV_MVA   3'b111 // Invalidate instruction cache by MVA
`define CA53_CP_ICACHE_DBG_TAG   3'b010 // Instruction cache debug tag read
`define CA53_CP_ICACHE_DBG_DATA  3'b011 // Instruction cache debug data read

`else

`undef CA53_CP_ICACHE_INV_ALL
`undef CA53_CP_ICACHE_INV_VA
`undef CA53_CP_ICACHE_INV_PA
`undef CA53_CP_ICACHE_INV_MVA
`undef CA53_CP_ICACHE_DBG_TAG
`undef CA53_CP_ICACHE_DBG_DATA

`endif
