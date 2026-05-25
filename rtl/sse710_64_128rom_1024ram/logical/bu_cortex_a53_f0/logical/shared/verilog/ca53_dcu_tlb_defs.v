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

// This is the specification for the interface between the DCU and TLB
// Inputs and outputs are from the point of view of the DCU.

`ifndef CA53_UNDEFINE

  `define CA53_TRANSL_NORMAL      3'b000
  `define CA53_TRANSL_V2P_S1_EL0  3'b010
  `define CA53_TRANSL_V2P_S1_EL1  3'b011
  `define CA53_TRANSL_V2P_S12_EL0 3'b100
  `define CA53_TRANSL_V2P_S12_EL1 3'b101
  `define CA53_TRANSL_V2P_S1_EL2  3'b110
  `define CA53_TRANSL_V2P_S1_EL3  3'b111
  `define CA53_CP_TLBI_ALL_ON_RST  5'b00000
  `define CA53_CP_TLB_INV_ALL      5'b00001
  `define CA53_CP_TLBI_VMALLE1     5'b00001
  `define CA53_CP_TLBI_VAE1        5'b00011  // Equivalent to CA53_CP_TLB_INV_MVA
  `define CA53_CP_TLBI_ASIDE1      5'b00100  // Equivalent to CA53_CP_TLB_INV_ASID
  `define CA53_CP_TLBI_VAAE1       5'b00101  // Equivalent to CA53_CP_TLB_INV_MVA_ASID
  `define CA53_CP_TLBI_VAE2        5'b00110  // Equivalent to CA53_CP_TLB_INV_MVA_HYP
  `define CA53_CP_TLBI_ALLE2       5'b00111  // Equivalent to CA53_CP_TLB_INV_ALL_HYP
  `define CA53_CP_TLB_INV_ALL_NSNH 5'b01000
  `define CA53_CP_TLBI_ALLE1       5'b01001
  `define CA53_CP_TLBI_VALE1       5'b01010
  `define CA53_CP_TLBI_VAALE1      5'b01011
  `define CA53_CP_TLBI_IPAS2LE1    5'b01100
  `define CA53_CP_TLBI_IPAS2E1     5'b01100
  `define CA53_CP_TLBI_VALE2       5'b01110
  `define CA53_CP_TLBI_VMALLS12E1  5'b01111
  `define CA53_CP_TLBI_VAE3        5'b10000
  `define CA53_CP_TLBI_VALE3       5'b10001
  `define CA53_CP_TLBI_ALLE3       5'b10010
  `define CA53_CP_TLB_DBG          5'b10011

`else

`undef CA53_TRANSL_NORMAL
`undef CA53_TRANSL_V2P_S1_EL0
`undef CA53_TRANSL_V2P_S1_EL1
`undef CA53_TRANSL_V2P_S12_EL0
`undef CA53_TRANSL_V2P_S12_EL1
`undef CA53_TRANSL_V2P_S1_EL2
`undef CA53_TRANSL_V2P_S1_EL3
`undef CA53_CP_TLBI_ALL_ON_RST
`undef CA53_CP_TLB_INV_ALL
`undef CA53_CP_TLBI_VMALLE1
`undef CA53_CP_TLBI_VAE1
`undef CA53_CP_TLBI_ASIDE1
`undef CA53_CP_TLBI_VAAE1
`undef CA53_CP_TLBI_VAE2
`undef CA53_CP_TLBI_ALLE2
`undef CA53_CP_TLB_INV_ALL_NSNH
`undef CA53_CP_TLBI_ALLE1
`undef CA53_CP_TLBI_VALE1
`undef CA53_CP_TLBI_VAALE1
`undef CA53_CP_TLBI_IPAS2LE1
`undef CA53_CP_TLBI_IPAS2E1
`undef CA53_CP_TLBI_VALE2
`undef CA53_CP_TLBI_VMALLS12E1
`undef CA53_CP_TLBI_VAE3
`undef CA53_CP_TLBI_VALE3
`undef CA53_CP_TLBI_ALLE3
`undef CA53_CP_TLB_DBG

`endif
