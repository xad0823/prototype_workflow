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

//-----------------------------------------------------------------------------
// Abstract : TLB block internal definitions
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

//-----------------------------------------------------------------------------
// TLB RAM fields
//-----------------------------------------------------------------------------

`define CA53_TLB_RAM_NOPARITY_W          114

`define CA53_RAM_PARITY_W                3
`define CA53_RAM_S2LEVEL_W               2
`define CA53_RAM_S1SIZE_W                3
`define CA53_RAM_DOMAIN_W                4
`define CA53_RAM_MEMATTR_W               8
`define CA53_RAM_XS1NUSR_W               1
`define CA53_RAM_XS2_W                   1
`define CA53_RAM_XS1USR_W                1
`define CA53_RAM_PXN_W                   1
`define CA53_RAM_XN_W                    2
`define CA53_RAM_PA_W                    28
`define CA53_RAM_NS_DESC_W               1
`define CA53_RAM_HAP_W                   2
`define CA53_RAM_APHYP_W                 3
`define CA53_RAM_NG_W                    1
`define CA53_RAM_SIZE_W                  3
`define CA53_RAM_ASID_W                  16
`define CA53_RAM_VMID_W                  8
`define CA53_RAM_NS_WALK_W               1
`define CA53_RAM_VA_W                    29
`define CA53_RAM_VALID_W                 1
`define CA53_RAM_SIGN_W                  1

`define CA53_RAM_PARITY_BITS             116:114
`define CA53_RAM_S2LEVEL_BITS            113:112
`define CA53_RAM_S1SIZE_BITS             111:109
`define CA53_RAM_DOMAIN_BITS             108:105
`define CA53_RAM_A64_64K_CONTG_BITS      105
                                           
`define CA53_RAM_MEMATTR_BITS            104:97
`define CA53_RAM_XS2_BITS                96
`define CA53_RAM_XS1NUSR_BITS            95
`define CA53_RAM_XS1USR_BITS             94
`define CA53_RAM_PXN_BITS                96
`define CA53_RAM_XN_BITS                 95:94
`define CA53_RAM_PA_MIN_BITS             66
`define CA53_RAM_PA_BITS                 93:66
`define CA53_RAM_NS_DESC_BITS            65
`define CA53_RAM_HAP_BITS                64:63
`define CA53_RAM_HAP1_BITS               64
`define CA53_RAM_HAP0_BITS               63
`define CA53_RAM_APHYP_BITS              62:60
`define CA53_RAM_NG_BITS                 59
`define CA53_RAM_SIZE_BITS               58:56
`define CA53_RAM_ASID_BITS               55:40
`define CA53_RAM_VMID_BITS               39:32
`define CA53_RAM_NS_WALK_BITS            31
`define CA53_RAM_VA_MAX_BITS             30
`define CA53_RAM_VA_MIN_BITS             2
`define CA53_RAM_VA_BITS                 30:2
`define CA53_RAM_SIGN_BITS               1
`define CA53_RAM_VALID_BITS              0

//-----------------------------------------------------------------------------
// Walk RAM fields
//-----------------------------------------------------------------------------

`define CA53_RAM_WALK_PREFIX_ADDR        4'b1000

`define CA53_RAM_WALK_PARITY_BITS        116:114
`define CA53_RAM_WALK_PA_BITS            113:84
`define CA53_RAM_WALK_VA_BITS            83:60
`define CA53_RAM_WALK_VA_SIGN_BITS       59
`define CA53_RAM_WALK_VA_LS_BITS         60
 //unused                                58:56
`define CA53_RAM_WALK_ASID_BITS          55:40
`define CA53_RAM_WALK_VMID_BITS          39:32
`define CA53_RAM_WALK_NS_WALK_BITS       31
 //unused                                30:22
`define CA53_RAM_WALK_DOMAIN_BITS        21:18
`define CA53_RAM_WALK_ARCH_BITS          17:16
`define CA53_RAM_WALK_NSTABLE_BITS       15
`define CA53_RAM_WALK_PXNTABLE_BITS      14
`define CA53_RAM_WALK_XNTABLE_BITS       13
`define CA53_RAM_WALK_APTABLE_BITS       12:11
`define CA53_RAM_WALK_EL3_BITS           10
`define CA53_RAM_WALK_EL2_BITS           9
`define CA53_RAM_WALK_MEMATTR_BITS       8:1
`define CA53_RAM_WALK_VALID_BITS         0

`define CA53_RAM_WALK_PA_30_BITS         `CA53_RAM_WALK_PA_BITS
`define CA53_RAM_WALK_PA_28_BITS         113:86
`define CA53_RAM_WALK_MEMATTR_TYPE_BITS  8:7  // Top two bits of mem attrs

//-----------------------------------------------------------------------------
// IPA RAM fields
//-----------------------------------------------------------------------------

`define CA53_RAM_IPA_PREFIX_ADDR         4'b1001

`define CA53_RAM_IPA_PARITY_BITS         116:114
`define CA53_RAM_IPA_PA_BITS             113:86
`define CA53_RAM_IPA_IPA_BITS            85:62
 //unused                                61:59
`define CA53_RAM_IPA_SIZE_BITS           58:56
`define CA53_RAM_IPA_VMID_BITS           39:32
 //unused                                31:11
`define CA53_RAM_IPA_CONTG_BITS          10
`define CA53_RAM_IPA_MEMATTR_BITS        9:6
`define CA53_RAM_IPA_XN_BIT              5
`define CA53_RAM_IPA_HAP_BITS            4:3
`define CA53_RAM_IPA_SH_BITS             2:1
`define CA53_RAM_IPA_VALID_BITS          0

 // Physical Address indexes for different sizes
`define CA53_RAM_IPA_PA_512MB_BLOCK_BITS 113:103 // 10-bits equivalent to Block_descriptor[39:29]
`define CA53_RAM_IPA_PA_1G_BLOCK_BITS    113:104 // 10-bits equivalent to Block_descriptor[39:30]
`define CA53_RAM_IPA_PA_2M_BLOCK_BITS    113:95  // 19-bits equivalent to Block_descriptor[39:21]
`define CA53_RAM_IPA_PA_4K_PAGE_BITS     113:86  // 28-bits equivalent to Page_descriptor[39:12]

 // Index bits for possible sizes
`define CA53_RAM_IPA_4K_INDEX_BITS       15:12
`define CA53_RAM_IPA_64K_INDEX_BITS      19:16
`define CA53_RAM_IPA_2M_INDEX_BITS       24:21
`define CA53_RAM_IPA_512M_INDEX_BITS     32:29
`define CA53_RAM_IPA_1G_INDEX_BITS       33:30

//-----------------------------------------------------------------------------
// Page sizes at different levels
//-----------------------------------------------------------------------------

`define CA53_STAGE_4K     3'b000
`define CA53_STAGE_64K    3'b001
`define CA53_STAGE_1M     3'b010
`define CA53_STAGE_2M     3'b011
`define CA53_STAGE_16M    3'b100
`define CA53_STAGE_512M   3'b101
`define CA53_STAGE_1G     3'b110
`define CA53_STAGE_1M_OR_MORE(size) (|size[2:1])

`define  CA53_ASID_W 16

//-----------------------------------------------------------------------------
// DCU CP address defines
//-----------------------------------------------------------------------------

`define CA53_DCU_CP_ADDR_W               62
`define CA53_DCU_CP_OP_W                 5

`define CA53_DCU_CP_ADDR_VMID_BITS       61:54
`define CA53_DCU_CP_ADDR_VMID_VALID_BITS 53
`define CA53_DCU_CP_ADDR_ASID_BITS       52:37
`define CA53_DCU_CP_ADDR_MVA_SIGN_BITS   36    // VA[48]
`define CA53_DCU_CP_ADDR_MVA_BITS        35:0  // VA[47:12]

`define CA53_DCU_CP_ADDR_WAY_SEL_BITS    31:30

//-----------------------------------------------------------------------------
// Lookup state machine
//-----------------------------------------------------------------------------
`define CA53_LOOKUP_ST_WIDTH 4

`define CA53_LOOKUP_ST_IDLE          4'b0000
`define CA53_LOOKUP_ST_WAIT          4'b0001
`define CA53_LOOKUP_ST_DBG_RD_DATA   4'b0010
`define CA53_LOOKUP_ST_LOOKUP        4'b0100
`define CA53_LOOKUP_ST_DBG_RD_ADDR   4'b1000
`define CA53_LOOKUP_ST_CP_WRITE_ALL  4'b1001
`define CA53_LOOKUP_ST_CP_READ0      4'b1010
`define CA53_LOOKUP_ST_CP_READ1      4'b1011
`define CA53_LOOKUP_ST_CP_WRITE0     4'b1110
`define CA53_LOOKUP_ST_CP_WRITE1     4'b1111 
`define CA53_LOOKUP_ST_X             4'bxxxx

`define CA53_LOOKUP_LOOKUP(state)    (state[3:2] == 2'b01)
`define CA53_LOOKUP_CP(state)        (state[3] & (|state[2:0]))
`define CA53_LOOKUP_CP_DBG_RD(state) (state[3] & ~state[2])
`define CA53_LOOKUP_CP_WR(state)     (state[3] &  state[2])

//-----------------------------------------------------------------------------
// Pagewalk state machine
//-----------------------------------------------------------------------------

`define CA53_PAGEWALK_ST_WIDTH 5

`define CA53_PAGEWALK_ST_IDLE             5'b0_1111
`define CA53_PAGEWALK_ST_LOOKUP_M0        5'b0_0000
`define CA53_PAGEWALK_ST_LOOKUP_M1        5'b0_0001
`define CA53_PAGEWALK_ST_LOOKUP_M2        5'b0_0010
`define CA53_PAGEWALK_ST_LOOKUP_M3        5'b0_0011
`define CA53_PAGEWALK_ST_BIU_NC_REQ       5'b0_0100
`define CA53_PAGEWALK_ST_BIU_LF_REQ       5'b0_0101
`define CA53_PAGEWALK_ST_BIU_LF_HZ        5'b0_0110
`define CA53_PAGEWALK_ST_WALK_LOOKUP      5'b0_0111
`define CA53_PAGEWALK_ST_WALK_COMPARE     5'b0_1000
`define CA53_PAGEWALK_ST_WALK_WAIT        5'b0_1001
`define CA53_PAGEWALK_ST_IPA_LOOKUP       5'b0_1010
`define CA53_PAGEWALK_ST_IPA_COMPARE      5'b0_1011
`define CA53_PAGEWALK_ST_WALK_WRITE       5'b0_1100
`define CA53_PAGEWALK_ST_IPA_WRITE        5'b0_1101
`define CA53_PAGEWALK_ST_TLB_WRITE        5'b0_1110

`define CA53_PAGEWALK_ST_PROCESS          5'b1_0001
`define CA53_PAGEWALK_ST_TLB_WRITE0       5'b1_1110
`define CA53_PAGEWALK_ST_WALK_WRITE0      5'b1_0010
`define CA53_PAGEWALK_ST_IPA_WRITE0       5'b1_0100
`define CA53_PAGEWALK_ST_IPA_WAIT         5'b1_1000

`define CA53_PAGEWALK_ST_X                5'bx_xxxx

//-----------------------------------------------------------------------------
// D uTLB data
//-----------------------------------------------------------------------------

`define CA53_DUTLB_DATA_W                96

`define CA53_DUTLB_DOMAIN_BITS           95:92
`define CA53_DUTLB_FAULT_TYPE_BITS       91:85
`define CA53_DUTLB_FAULT_BITS            84:83
`define CA53_DUTLB_S2LEVEL_BITS          82:81
`define CA53_DUTLB_S1LEVEL_BITS          80:79
`define CA53_DUTLB_MEMATTR_BITS          78:71
`define CA53_DUTLB_HAP_BITS              70:69
`define CA53_DUTLB_APHYP_BITS            68:66
`define CA53_DUTLB_NS_BITS               65
`define CA53_DUTLB_PA_BITS               64:37
`define CA53_DUTLB_VA_BITS               36:0


//-----------------------------------------------------------------------------
// I uTLB data
//-----------------------------------------------------------------------------

`define CA53_IUTLB_DATA_W                97

`define CA53_IUTLB_SIZE_BITS             96
`define CA53_IUTLB_XS1NUSR_BITS          95
`define CA53_IUTLB_XS2_BITS              94
`define CA53_IUTLB_XS1USR_BITS           93
`define CA53_IUTLB_DOMAIN_BITS           92:89
`define CA53_IUTLB_FAULT_TYPE_BITS       88:82
`define CA53_IUTLB_FAULT_BITS            81:80
`define CA53_IUTLB_S2LEVEL_BITS          79:78
`define CA53_IUTLB_S1LEVEL_BITS          77:76
`define CA53_IUTLB_MEMATTR_BITS          75:68
`define CA53_IUTLB_EXCP_LEVEL_BITS       67:66
`define CA53_IUTLB_NS_BITS               65
`define CA53_IUTLB_PA_BITS               64:37
`define CA53_IUTLB_VA_BITS               36:0

//-----------------------------------------------------------------------------
// Undefines
//-----------------------------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_TLB_RAM_NOPARITY_W
`undef CA53_RAM_PARITY_W
`undef CA53_RAM_S2LEVEL_W
`undef CA53_RAM_S1SIZE_W
`undef CA53_RAM_DOMAIN_W
`undef CA53_RAM_MEMATTR_W
`undef CA53_RAM_XS1NUSR_W
`undef CA53_RAM_XS2_W
`undef CA53_RAM_XS1USR_W
`undef CA53_RAM_PXN_W
`undef CA53_RAM_XN_W
`undef CA53_RAM_PA_W
`undef CA53_RAM_NS_DESC_W
`undef CA53_RAM_HAP_W
`undef CA53_RAM_APHYP_W
`undef CA53_RAM_NG_W
`undef CA53_RAM_SIZE_W
`undef CA53_RAM_ASID_W
`undef CA53_RAM_VMID_W
`undef CA53_RAM_NS_WALK_W
`undef CA53_RAM_VA_W
`undef CA53_RAM_VALID_W
`undef CA53_RAM_SIGN_W
`undef CA53_RAM_PARITY_BITS
`undef CA53_RAM_S2LEVEL_BITS
`undef CA53_RAM_S1SIZE_BITS
`undef CA53_RAM_DOMAIN_BITS
`undef CA53_RAM_A64_64K_CONTG_BITS
`undef CA53_RAM_MEMATTR_BITS
`undef CA53_RAM_XS2_BITS
`undef CA53_RAM_XS1NUSR_BITS
`undef CA53_RAM_XS1USR_BITS
`undef CA53_RAM_PXN_BITS
`undef CA53_RAM_XN_BITS
`undef CA53_RAM_PA_MIN_BITS
`undef CA53_RAM_PA_BITS
`undef CA53_RAM_NS_DESC_BITS
`undef CA53_RAM_HAP_BITS
`undef CA53_RAM_HAP1_BITS
`undef CA53_RAM_HAP0_BITS
`undef CA53_RAM_APHYP_BITS
`undef CA53_RAM_NG_BITS
`undef CA53_RAM_SIZE_BITS
`undef CA53_RAM_ASID_BITS
`undef CA53_RAM_VMID_BITS
`undef CA53_RAM_NS_WALK_BITS
`undef CA53_RAM_VA_MAX_BITS
`undef CA53_RAM_VA_MIN_BITS
`undef CA53_RAM_VA_BITS
`undef CA53_RAM_SIGN_BITS
`undef CA53_RAM_VALID_BITS
`undef CA53_RAM_WALK_PREFIX_ADDR
`undef CA53_RAM_WALK_PARITY_BITS
`undef CA53_RAM_WALK_PA_BITS
`undef CA53_RAM_WALK_VA_BITS
`undef CA53_RAM_WALK_VA_SIGN_BITS
`undef CA53_RAM_WALK_VA_LS_BITS
`undef CA53_RAM_WALK_ASID_BITS
`undef CA53_RAM_WALK_VMID_BITS
`undef CA53_RAM_WALK_NS_WALK_BITS
`undef CA53_RAM_WALK_DOMAIN_BITS
`undef CA53_RAM_WALK_ARCH_BITS
`undef CA53_RAM_WALK_NSTABLE_BITS
`undef CA53_RAM_WALK_PXNTABLE_BITS
`undef CA53_RAM_WALK_XNTABLE_BITS
`undef CA53_RAM_WALK_APTABLE_BITS
`undef CA53_RAM_WALK_EL3_BITS
`undef CA53_RAM_WALK_EL2_BITS
`undef CA53_RAM_WALK_MEMATTR_BITS
`undef CA53_RAM_WALK_VALID_BITS
`undef CA53_RAM_WALK_PA_30_BITS
`undef CA53_RAM_WALK_PA_28_BITS
`undef CA53_RAM_WALK_MEMATTR_TYPE_BITS
`undef CA53_RAM_IPA_PREFIX_ADDR
`undef CA53_RAM_IPA_PARITY_BITS
`undef CA53_RAM_IPA_PA_BITS
`undef CA53_RAM_IPA_IPA_BITS
`undef CA53_RAM_IPA_SIZE_BITS
`undef CA53_RAM_IPA_VMID_BITS
`undef CA53_RAM_IPA_CONTG_BITS
`undef CA53_RAM_IPA_MEMATTR_BITS
`undef CA53_RAM_IPA_XN_BIT
`undef CA53_RAM_IPA_HAP_BITS
`undef CA53_RAM_IPA_SH_BITS
`undef CA53_RAM_IPA_VALID_BITS
`undef CA53_RAM_IPA_PA_512MB_BLOCK_BITS
`undef CA53_RAM_IPA_PA_1G_BLOCK_BITS
`undef CA53_RAM_IPA_PA_2M_BLOCK_BITS
`undef CA53_RAM_IPA_PA_4K_PAGE_BITS
`undef CA53_RAM_IPA_4K_INDEX_BITS
`undef CA53_RAM_IPA_64K_INDEX_BITS
`undef CA53_RAM_IPA_2M_INDEX_BITS
`undef CA53_RAM_IPA_512M_INDEX_BITS
`undef CA53_RAM_IPA_1G_INDEX_BITS
`undef CA53_STAGE_4K
`undef CA53_STAGE_64K
`undef CA53_STAGE_1M
`undef CA53_STAGE_2M
`undef CA53_STAGE_16M
`undef CA53_STAGE_512M
`undef CA53_STAGE_1G
`undef CA53_STAGE_1M_OR_MORE
`undef CA53_ASID_W
`undef CA53_DCU_CP_ADDR_W
`undef CA53_DCU_CP_OP_W
`undef CA53_DCU_CP_ADDR_VMID_BITS
`undef CA53_DCU_CP_ADDR_VMID_VALID_BITS
`undef CA53_DCU_CP_ADDR_ASID_BITS
`undef CA53_DCU_CP_ADDR_MVA_SIGN_BITS
`undef CA53_DCU_CP_ADDR_MVA_BITS
`undef CA53_DCU_CP_ADDR_WAY_SEL_BITS
`undef CA53_LOOKUP_ST_WIDTH
`undef CA53_LOOKUP_ST_IDLE
`undef CA53_LOOKUP_ST_WAIT
`undef CA53_LOOKUP_ST_DBG_RD_DATA
`undef CA53_LOOKUP_ST_LOOKUP
`undef CA53_LOOKUP_ST_DBG_RD_ADDR
`undef CA53_LOOKUP_ST_CP_WRITE_ALL
`undef CA53_LOOKUP_ST_CP_READ0
`undef CA53_LOOKUP_ST_CP_READ1
`undef CA53_LOOKUP_ST_CP_WRITE0
`undef CA53_LOOKUP_ST_CP_WRITE1
`undef CA53_LOOKUP_ST_X
`undef CA53_LOOKUP_LOOKUP
`undef CA53_LOOKUP_CP
`undef CA53_LOOKUP_CP_DBG_RD
`undef CA53_LOOKUP_CP_WR
`undef CA53_PAGEWALK_ST_WIDTH
`undef CA53_PAGEWALK_ST_IDLE
`undef CA53_PAGEWALK_ST_LOOKUP_M0
`undef CA53_PAGEWALK_ST_LOOKUP_M1
`undef CA53_PAGEWALK_ST_LOOKUP_M2
`undef CA53_PAGEWALK_ST_LOOKUP_M3
`undef CA53_PAGEWALK_ST_BIU_NC_REQ
`undef CA53_PAGEWALK_ST_BIU_LF_REQ
`undef CA53_PAGEWALK_ST_BIU_LF_HZ
`undef CA53_PAGEWALK_ST_WALK_LOOKUP
`undef CA53_PAGEWALK_ST_WALK_COMPARE
`undef CA53_PAGEWALK_ST_WALK_WAIT
`undef CA53_PAGEWALK_ST_IPA_LOOKUP
`undef CA53_PAGEWALK_ST_IPA_COMPARE
`undef CA53_PAGEWALK_ST_WALK_WRITE
`undef CA53_PAGEWALK_ST_IPA_WRITE
`undef CA53_PAGEWALK_ST_TLB_WRITE
`undef CA53_PAGEWALK_ST_PROCESS
`undef CA53_PAGEWALK_ST_TLB_WRITE0
`undef CA53_PAGEWALK_ST_WALK_WRITE0
`undef CA53_PAGEWALK_ST_IPA_WRITE0
`undef CA53_PAGEWALK_ST_IPA_WAIT
`undef CA53_PAGEWALK_ST_X
`undef CA53_DUTLB_DATA_W
`undef CA53_DUTLB_DOMAIN_BITS
`undef CA53_DUTLB_FAULT_TYPE_BITS
`undef CA53_DUTLB_FAULT_BITS
`undef CA53_DUTLB_S2LEVEL_BITS
`undef CA53_DUTLB_S1LEVEL_BITS
`undef CA53_DUTLB_MEMATTR_BITS
`undef CA53_DUTLB_HAP_BITS
`undef CA53_DUTLB_APHYP_BITS
`undef CA53_DUTLB_NS_BITS
`undef CA53_DUTLB_PA_BITS
`undef CA53_DUTLB_VA_BITS
`undef CA53_IUTLB_DATA_W
`undef CA53_IUTLB_SIZE_BITS
`undef CA53_IUTLB_XS1NUSR_BITS
`undef CA53_IUTLB_XS2_BITS
`undef CA53_IUTLB_XS1USR_BITS
`undef CA53_IUTLB_DOMAIN_BITS
`undef CA53_IUTLB_FAULT_TYPE_BITS
`undef CA53_IUTLB_FAULT_BITS
`undef CA53_IUTLB_S2LEVEL_BITS
`undef CA53_IUTLB_S1LEVEL_BITS
`undef CA53_IUTLB_MEMATTR_BITS
`undef CA53_IUTLB_EXCP_LEVEL_BITS
`undef CA53_IUTLB_NS_BITS
`undef CA53_IUTLB_PA_BITS
`undef CA53_IUTLB_VA_BITS
/*END*/

`endif
