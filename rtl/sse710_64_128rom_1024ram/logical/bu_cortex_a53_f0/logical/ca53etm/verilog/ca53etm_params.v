//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
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
//
// Overview
// ========
//
// local defines for ETM
//



`ifndef CA53_UNDEFINE

//
// ETM Packet Header
// ------------------------
`define CA53_ETM_PKT_ADDR_EACT_MATCH0      8'b1001_0000
`define CA53_ETM_PKT_ADDR_EACT_MATCH1      8'b1001_0001
`define CA53_ETM_PKT_ADDR_EACT_MATCH2      8'b1001_0010
`define CA53_ETM_PKT_ADDR_IS0_SHORT        8'b1001_0101
`define CA53_ETM_PKT_ADDR_IS1_SHORT        8'b1001_0110
`define CA53_ETM_PKT_ADDR_IS2_SHORT        8'b1001_0111
`define CA53_ETM_PKT_ADDR_IS0_32           8'b1001_1010
`define CA53_ETM_PKT_ADDR_IS1_2_32         8'b1001_1011
`define CA53_ETM_PKT_ADDR_IS0_64           8'b1001_1101
`define CA53_ETM_PKT_ADDR_IS1_2_64         8'b1001_1110
`define CA53_ETM_PKT_ADDR_IS0_32_LONG      8'b1000_0010
`define CA53_ETM_PKT_ADDR_IS1_2_32_LONG    8'b1000_0011
`define CA53_ETM_PKT_ADDR_IS0_64_LONG      8'b1000_0101
`define CA53_ETM_PKT_ADDR_IS1_2_64_LONG    8'b1000_0110
`define CA53_ETM_PKT_EXCEPT                8'b0000_0110


//
// case selects
// ------------------------
`define ca53etm_sel_00xxx  5'b00111,5'b00110,5'b00101,5'b00100,5'b00011,5'b00010,5'b00001,5'b00000
`define ca53etm_sel_10xxx  5'b10111,5'b10110,5'b10101,5'b10100,5'b10011,5'b10010,5'b10001,5'b10000
`define ca53etm_sel_x0xxx  `ca53etm_sel_10xxx,`ca53etm_sel_00xxx
`define ca53etm_sel_01000  5'b01000
`define ca53etm_sel_01001  5'b01001
`define ca53etm_sel_0101x  5'b01011,5'b01010
`define ca53etm_sel_01100  5'b01100
`define ca53etm_sel_01101  5'b01101
`define ca53etm_sel_0111x  5'b01111,5'b01110
`define ca53etm_sel_1100x  5'b11001,5'b11000
`define ca53etm_sel_1101x  5'b11011,5'b11010
`define ca53etm_sel_1110x  5'b11101,5'b11100
`define ca53etm_sel_1111x  5'b11111,5'b11110

`define ca53etm_sel_00000  5'b00000
`define ca53etm_sel_00001  5'b00001
`define ca53etm_sel_10000  5'b10000
`define ca53etm_sel_10001  5'b10001
`define ca53etm_sel_01010  5'b01010
`define ca53etm_sel_01011  5'b01011
`define ca53etm_sel_011x0  5'b01110,5'b01100
`define ca53etm_sel_01110  5'b01110
`define ca53etm_sel_011x1  5'b01111,5'b01101


//----------------------------------------------------------------------------
// Undefines
//----------------------------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_ETM_PKT_ADDR_EACT_MATCH0
`undef CA53_ETM_PKT_ADDR_EACT_MATCH1
`undef CA53_ETM_PKT_ADDR_EACT_MATCH2
`undef CA53_ETM_PKT_ADDR_IS0_SHORT
`undef CA53_ETM_PKT_ADDR_IS1_SHORT
`undef CA53_ETM_PKT_ADDR_IS2_SHORT
`undef CA53_ETM_PKT_ADDR_IS0_32
`undef CA53_ETM_PKT_ADDR_IS1_2_32
`undef CA53_ETM_PKT_ADDR_IS0_64
`undef CA53_ETM_PKT_ADDR_IS1_2_64
`undef CA53_ETM_PKT_ADDR_IS0_32_LONG
`undef CA53_ETM_PKT_ADDR_IS1_2_32_LONG
`undef CA53_ETM_PKT_ADDR_IS0_64_LONG
`undef CA53_ETM_PKT_ADDR_IS1_2_64_LONG
`undef CA53_ETM_PKT_EXCEPT
`undef ca53etm_sel_00xxx
`undef ca53etm_sel_10xxx
`undef ca53etm_sel_x0xxx
`undef ca53etm_sel_01000
`undef ca53etm_sel_01001
`undef ca53etm_sel_0101x
`undef ca53etm_sel_01100
`undef ca53etm_sel_01101
`undef ca53etm_sel_0111x
`undef ca53etm_sel_1100x
`undef ca53etm_sel_1101x
`undef ca53etm_sel_1110x
`undef ca53etm_sel_1111x
`undef ca53etm_sel_00000
`undef ca53etm_sel_00001
`undef ca53etm_sel_10000
`undef ca53etm_sel_10001
`undef ca53etm_sel_01010
`undef ca53etm_sel_01011
`undef ca53etm_sel_011x0
`undef ca53etm_sel_01110
`undef ca53etm_sel_011x1
/*END*/

`endif
