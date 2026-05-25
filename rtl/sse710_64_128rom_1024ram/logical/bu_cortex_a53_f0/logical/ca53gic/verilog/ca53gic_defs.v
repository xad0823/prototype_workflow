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
// Abstract : CortexA53 GIC CPU Interface Defines
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

//-----------------------------------------------------------------------------
// GIC Implementation Identification
//-----------------------------------------------------------------------------

`define CA53_GIC_ARCH                     4'h4
`define CA53_GIC_IMP                      12'h43B
`define CA53_GIC_PRODUCT                  12'h003


//-----------------------------------------------------------------------------
// GIC Special Encodings
//-----------------------------------------------------------------------------

// Spurious Interrupt IDs
`define CA53_GIC_ID_SPURIOUS_NONE         16'd1023
`define CA53_GIC_ID_SPURIOUS_SECURITY     16'd1022
`define CA53_GIC_ID_SPURIOUS_NS_EL        16'd1021
`define CA53_GIC_ID_SPURIOUS_SECURE_EL    16'd1020


// ------------------------------------------------------
// Virtual interface
// ------------------------------------------------------

// The number of implemented list registers
`define CA53_GIC_LR_CNT                   4

// List register state
`define CA53_GIC_LR_S_W                   2
`define CA53_GIC_LR_S_INVALID             2'b00
`define CA53_GIC_LR_S_PENDING             2'b01
`define CA53_GIC_LR_S_ACTIVE              2'b10
`define CA53_GIC_LR_S_PACTIVE             2'b11

// List register physical ID
`define CA53_GIC_LR_PID_W                 10


//-----------------------------------------------------------------------------
// Packet constants
//-----------------------------------------------------------------------------

// SGIs
`define CA53_GIC_SGT_W                    2
`define CA53_GIC_SGT_ASGI1R               2'b10
`define CA53_GIC_SGT_SGI0R                2'b00
`define CA53_GIC_SGT_SGI1R                2'b01


//-----------------------------------------------------------------------------
// Addresses
//-----------------------------------------------------------------------------

// GIC 4K page select bits - address[12+:6]
`define CA53_GICC_PAGE_0                  6'b00_0000
`define CA53_GICC_PAGE_1                  6'b00_0001
`define CA53_GICH_PAGE_0                  6'b01_0000
`define CA53_GICV_PAGE_0                  6'b10_0000
`define CA53_GICV_PAGE_1                  6'b10_0001
`define CA53_GICV_PAGE_0_ALIAS            6'b10_1111
`define CA53_GICV_PAGE_1_ALIAS            6'b11_0000

// Physical CPU Interface address 4K offset [2+:10]
`define CA53_GICC_ADR_CTLR                10'b0000_0000_00
`define CA53_GICC_ADR_PMR                 10'b0000_0000_01
`define CA53_GICC_ADR_BPR                 10'b0000_0000_10
`define CA53_GICC_ADR_IAR                 10'b0000_0000_11
`define CA53_GICC_ADR_EOIR                10'b0000_0001_00
`define CA53_GICC_ADR_RPR                 10'b0000_0001_01
`define CA53_GICC_ADR_HPPIR               10'b0000_0001_10
`define CA53_GICC_ADR_ABPR                10'b0000_0001_11
`define CA53_GICC_ADR_AIAR                10'b0000_0010_00
`define CA53_GICC_ADR_AEOIR               10'b0000_0010_01
`define CA53_GICC_ADR_AHPPIR              10'b0000_0010_10
`define CA53_GICC_ADR_APR                 10'b0000_1101_00
`define CA53_GICC_ADR_NSAPR               10'b0000_1110_00
`define CA53_GICC_ADR_IIDR                10'b0000_1111_11
`define CA53_GICC_ADR_DIR                 10'b0000_0000_00

// Virtual CPU Interface address 4K offset [2+:10]
`define CA53_GICV_ADR_CTLR                10'b0000_0000_00
`define CA53_GICV_ADR_PMR                 10'b0000_0000_01
`define CA53_GICV_ADR_BPR                 10'b0000_0000_10
`define CA53_GICV_ADR_IAR                 10'b0000_0000_11
`define CA53_GICV_ADR_RPR                 10'b0000_0001_01
`define CA53_GICV_ADR_HPPIR               10'b0000_0001_10
`define CA53_GICV_ADR_ABPR                10'b0000_0001_11
`define CA53_GICV_ADR_AIAR                10'b0000_0010_00
`define CA53_GICV_ADR_AHPPIR              10'b0000_0010_10
`define CA53_GICV_ADR_APR                 10'b0000_1101_00
`define CA53_GICV_ADR_IIDR                10'b0000_1111_11
`define CA53_GICV_ADR_EOIR                10'b0000_0001_00
`define CA53_GICV_ADR_AEOIR               10'b0000_0010_01
`define CA53_GICV_ADR_DIR                 10'b0000_0000_00

// Virtual Interface Control address 4K offset [2+:10]
`define CA53_GICH_ADR_HCR                 10'b0000_0000_00
`define CA53_GICH_ADR_VTR                 10'b0000_0000_01
`define CA53_GICH_ADR_VMCR                10'b0000_0000_10
`define CA53_GICH_ADR_MISR                10'b0000_0001_00
`define CA53_GICH_ADR_EISR0               10'b0000_0010_00
`define CA53_GICH_ADR_ELSR0               10'b0000_0011_00
`define CA53_GICH_ADR_APR                 10'b0000_1111_00
`define CA53_GICH_ADR_LR0                 10'b0001_0000_00
`define CA53_GICH_ADR_LR1                 10'b0001_0000_01
`define CA53_GICH_ADR_LR2                 10'b0001_0000_10
`define CA53_GICH_ADR_LR3                 10'b0001_0000_11


//-----------------------------------------------------------------------------
// Programming Interface Opcodes
//-----------------------------------------------------------------------------

// Physical CPU Interface registers
`define CA53_GICC_OP_W                    4
`define CA53_GICC_OP_RESERVED             4'b0000
`define CA53_GICC_OP_CTLR                 4'b0001
`define CA53_GICC_OP_PMR                  4'b0010
`define CA53_GICC_OP_BPR                  4'b0011
`define CA53_GICC_OP_IAR                  4'b0100
`define CA53_GICC_OP_EOIR                 4'b0101
`define CA53_GICC_OP_RPR                  4'b0110
`define CA53_GICC_OP_HPPIR                4'b0111
`define CA53_GICC_OP_ABPR                 4'b1000
`define CA53_GICC_OP_AIAR                 4'b1001
`define CA53_GICC_OP_AEOIR                4'b1010
`define CA53_GICC_OP_AHPPIR               4'b1011
`define CA53_GICC_OP_APR                  4'b1100
`define CA53_GICC_OP_NSAPR                4'b1101
`define CA53_GICC_OP_IIDR                 4'b1110
`define CA53_GICC_OP_DIR                  4'b1111

// Virtual Control Interface registers
`define CA53_GICHV_OP_W                   5
`define CA53_GICHV_OP_RESERVED            5'b00000
`define CA53_GICH_OP_HCR                  5'b00001
`define CA53_GICH_OP_VTR                  5'b00010
`define CA53_GICH_OP_VMCR                 5'b00011
`define CA53_GICH_OP_MISR                 5'b00100
`define CA53_GICH_OP_EISR0                5'b00101
`define CA53_GICH_OP_ELSR0                5'b00110
`define CA53_GICH_OP_APR                  5'b01001
`define CA53_GICH_OP_LR0                  5'b01100
`define CA53_GICH_OP_LR1                  5'b01101
`define CA53_GICH_OP_LR2                  5'b01110
`define CA53_GICH_OP_LR3                  5'b01111

// Virtual CPU Interface registers
`define CA53_GICV_OP_CTLR                 5'b10001
`define CA53_GICV_OP_PMR                  5'b10010
`define CA53_GICV_OP_BPR                  5'b10011
`define CA53_GICV_OP_IAR                  5'b10100
`define CA53_GICV_OP_EOIR                 5'b10101
`define CA53_GICV_OP_RPR                  5'b10110
`define CA53_GICV_OP_HPPIR                5'b10111
`define CA53_GICV_OP_ABPR                 5'b11000
`define CA53_GICV_OP_AIAR                 5'b11001
`define CA53_GICV_OP_AEOIR                5'b11010
`define CA53_GICV_OP_AHPPIR               5'b11011
`define CA53_GICV_OP_APR                  5'b11100
`define CA53_GICV_OP_DIR                  5'b11110
`define CA53_GICV_OP_IIDR                 5'b11111


//-----------------------------------------------------------------------------
// Undefines
//-----------------------------------------------------------------------------

`else

`undef CA53_GIC_ARCH
`undef CA53_GIC_IMP
`undef CA53_GIC_PRODUCT
`undef CA53_GIC_ID_SPURIOUS_NONE
`undef CA53_GIC_ID_SPURIOUS_SECURITY
`undef CA53_GIC_ID_SPURIOUS_NS_EL
`undef CA53_GIC_ID_SPURIOUS_SECURE_EL
`undef CA53_GIC_LR_CNT
`undef CA53_GIC_LR_S_W
`undef CA53_GIC_LR_S_INVALID
`undef CA53_GIC_LR_S_PENDING
`undef CA53_GIC_LR_S_ACTIVE
`undef CA53_GIC_LR_S_PACTIVE
`undef CA53_GIC_LR_PID_W
`undef CA53_GIC_SGT_W
`undef CA53_GIC_SGT_ASGI1R
`undef CA53_GIC_SGT_SGI0R
`undef CA53_GIC_SGT_SGI1R
`undef CA53_GICC_PAGE_0
`undef CA53_GICC_PAGE_1
`undef CA53_GICH_PAGE_0
`undef CA53_GICV_PAGE_0
`undef CA53_GICV_PAGE_1
`undef CA53_GICV_PAGE_0_ALIAS
`undef CA53_GICV_PAGE_1_ALIAS
`undef CA53_GICC_ADR_CTLR
`undef CA53_GICC_ADR_PMR
`undef CA53_GICC_ADR_BPR
`undef CA53_GICC_ADR_IAR
`undef CA53_GICC_ADR_EOIR
`undef CA53_GICC_ADR_RPR
`undef CA53_GICC_ADR_HPPIR
`undef CA53_GICC_ADR_ABPR
`undef CA53_GICC_ADR_AIAR
`undef CA53_GICC_ADR_AEOIR
`undef CA53_GICC_ADR_AHPPIR
`undef CA53_GICC_ADR_APR
`undef CA53_GICC_ADR_NSAPR
`undef CA53_GICC_ADR_IIDR
`undef CA53_GICC_ADR_DIR
`undef CA53_GICV_ADR_CTLR
`undef CA53_GICV_ADR_PMR
`undef CA53_GICV_ADR_BPR
`undef CA53_GICV_ADR_IAR
`undef CA53_GICV_ADR_RPR
`undef CA53_GICV_ADR_HPPIR
`undef CA53_GICV_ADR_ABPR
`undef CA53_GICV_ADR_AIAR
`undef CA53_GICV_ADR_AHPPIR
`undef CA53_GICV_ADR_APR
`undef CA53_GICV_ADR_IIDR
`undef CA53_GICV_ADR_EOIR
`undef CA53_GICV_ADR_AEOIR
`undef CA53_GICV_ADR_DIR
`undef CA53_GICH_ADR_HCR
`undef CA53_GICH_ADR_VTR
`undef CA53_GICH_ADR_VMCR
`undef CA53_GICH_ADR_MISR
`undef CA53_GICH_ADR_EISR0
`undef CA53_GICH_ADR_ELSR0
`undef CA53_GICH_ADR_APR
`undef CA53_GICH_ADR_LR0
`undef CA53_GICH_ADR_LR1
`undef CA53_GICH_ADR_LR2
`undef CA53_GICH_ADR_LR3
`undef CA53_GICC_OP_W
`undef CA53_GICC_OP_RESERVED
`undef CA53_GICC_OP_CTLR
`undef CA53_GICC_OP_PMR
`undef CA53_GICC_OP_BPR
`undef CA53_GICC_OP_IAR
`undef CA53_GICC_OP_EOIR
`undef CA53_GICC_OP_RPR
`undef CA53_GICC_OP_HPPIR
`undef CA53_GICC_OP_ABPR
`undef CA53_GICC_OP_AIAR
`undef CA53_GICC_OP_AEOIR
`undef CA53_GICC_OP_AHPPIR
`undef CA53_GICC_OP_APR
`undef CA53_GICC_OP_NSAPR
`undef CA53_GICC_OP_IIDR
`undef CA53_GICC_OP_DIR
`undef CA53_GICHV_OP_W
`undef CA53_GICHV_OP_RESERVED
`undef CA53_GICH_OP_HCR
`undef CA53_GICH_OP_VTR
`undef CA53_GICH_OP_VMCR
`undef CA53_GICH_OP_MISR
`undef CA53_GICH_OP_EISR0
`undef CA53_GICH_OP_ELSR0
`undef CA53_GICH_OP_APR
`undef CA53_GICH_OP_LR0
`undef CA53_GICH_OP_LR1
`undef CA53_GICH_OP_LR2
`undef CA53_GICH_OP_LR3
`undef CA53_GICV_OP_CTLR
`undef CA53_GICV_OP_PMR
`undef CA53_GICV_OP_BPR
`undef CA53_GICV_OP_IAR
`undef CA53_GICV_OP_EOIR
`undef CA53_GICV_OP_RPR
`undef CA53_GICV_OP_HPPIR
`undef CA53_GICV_OP_ABPR
`undef CA53_GICV_OP_AIAR
`undef CA53_GICV_OP_AEOIR
`undef CA53_GICV_OP_AHPPIR
`undef CA53_GICV_OP_APR
`undef CA53_GICV_OP_DIR
`undef CA53_GICV_OP_IIDR

`endif

