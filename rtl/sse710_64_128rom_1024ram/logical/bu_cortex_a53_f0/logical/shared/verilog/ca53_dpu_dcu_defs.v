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
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

// This is the specification for the interface between the DPU and DCU
// Inputs and outputs are from the point of view of the DPU.

// Pull in the CPOP encodings

`ifndef CA53_UNDEFINE

`define CA53_ALIGN_NONE   3'b000
`define CA53_ALIGN_16BIT  3'b001
`define CA53_ALIGN_32BIT  3'b010
`define CA53_ALIGN_64BIT  3'b011
`define CA53_ALIGN_128BIT 3'b100
`define CA53_ALIGN_256BIT 3'b101
`define CA53_ALIGN_DCZVA  3'b111
`define CA53_VMSA_PAGE_SIZE_SSECTION 2'b00
`define CA53_VMSA_PAGE_SIZE_SECTION  2'b01
`define CA53_VMSA_PAGE_SIZE_PAGE     2'b10
`define CA53_LPAE_TRANSL_LEVEL_1     2'b01
`define CA53_LPAE_TRANSL_LEVEL_2     2'b10
`define CA53_LPAE_TRANSL_LEVEL_3     2'b11

`else

`undef CA53_ALIGN_NONE
`undef CA53_ALIGN_16BIT
`undef CA53_ALIGN_32BIT
`undef CA53_ALIGN_64BIT
`undef CA53_ALIGN_128BIT
`undef CA53_ALIGN_256BIT
`undef CA53_ALIGN_DCZVA
`undef CA53_VMSA_PAGE_SIZE_SSECTION
`undef CA53_VMSA_PAGE_SIZE_SECTION
`undef CA53_VMSA_PAGE_SIZE_PAGE
`undef CA53_LPAE_TRANSL_LEVEL_1
`undef CA53_LPAE_TRANSL_LEVEL_2
`undef CA53_LPAE_TRANSL_LEVEL_3

`endif
