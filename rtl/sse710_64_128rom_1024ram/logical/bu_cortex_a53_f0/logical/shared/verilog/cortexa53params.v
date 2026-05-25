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
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Global defines for Cortex-A53
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

// ------------------------------------------------------
// ID Values
// ------------------------------------------------------

`define CA53_REVISION       4'b0100      // The "p" part of eg. r0p0 (may need incrementing on revisions)
`define CA53_VARIANT        4'b0000      // The "r" part of eg. r0p0 (may need incrementing on revisions)
`define CA53_PERPH_REVISION 4'b0100      // A number incremented on every revision/patch (may need incrementing on revisions)
`define CA53_PERPH_REV_AND  4'b0000      // ID incremented by manufacturer on ECO fixes (may need incrementing on revisions)

`define CA53_IMPLEMENTOR     8'h41       // ARM
`define CA53_ARCH_REVISED    4'hf        // Uses CPUID scheme
`define CA53_PART_NUM_11_8   4'hd        // v8
`define CA53_PART_NUM_7_0    8'h03       // Cortex-A53
`define CA53_VFP_SUBARCH     7'b000_0011 // v3+ architecture with null subarchitecture
`define CA53_VFP_PART_NUM    8'h40       // Cortex-A50 Family
`define CA53_VFP_VARIANT     4'h3        // Cortex-A53 Processor

// ------------------------------------------------------
// Values for Read only "ID" style CP registers
// ------------------------------------------------------

//ID Code Register (MIDR)
`define CA53_IDCR_READ_VALUE {`CA53_IMPLEMENTOR,`CA53_VARIANT,`CA53_ARCH_REVISED,`CA53_PART_NUM_11_8,`CA53_PART_NUM_7_0,`CA53_REVISION}

//Debug ID Register
// for DIDR_READ_VALUE see below - DIDR defined there

//Cache Type Register
`define CA53_CTR_CWG        4'h4  // 64 bytes
`define CA53_CTR_ERG        4'h4  // 64 bytes
`define CA53_CTR_DMINLINE   4'h4  // 64 bytes
`define CA53_CTR_L1IP       2'h2  // VIPT
`define CA53_CTR_IMINLINE   4'h4  // 64 bytes

//MPU Type Register - MPUTR_READ_VALUE defined in ca53dpu_cp_registers.v

// Multi Processor ID Register
// For a uniprocessor, the cluster and cpu ids will be zero,
// but including them in the ID removes a lint warning
`define CA53_MPIDR_READ_VALUE(aff2,aff1,cpu_id)  {8'h80, aff2[7:0], aff1[7:0], 6'h00, cpu_id[1:0]}

`define CA53_CLIDR_READ_VALUE (L2_CACHE ? 32'h0a200023 : 32'h09200003)

//                                        WT    WB    RA    WA    NumSets                            Associativity  LineSize
`define CA53_CCSIDR_L2_READ_VALUE(size)  {1'b0, 1'b1, 1'b1, 1'b1, {4'b0000,  size[3:0], 7'b1111111}, 10'h00F,       3'h2}
`define CA53_CCSIDR_L1D_READ_VALUE(size) {1'b0, 1'b1, 1'b1, 1'b1, {7'b0000000, size[2:0], 5'b11111}, 10'h003,       3'h2}
`define CA53_CCSIDR_L1I_READ_VALUE(size) {1'b0, 1'b0, 1'b1, 1'b0, {6'b000000, size[2:0], 6'b111111}, 10'h001,       3'h2}

`define CA53_COMP0ID_RD_VAL 32'h0000000D
`define CA53_COMP1ID_RD_VAL 32'h00000090
`define CA53_COMP2ID_RD_VAL 32'h00000005
`define CA53_COMP3ID_RD_VAL 32'h000000B1

`define CA53_PMU_PART_NUM 12'h9D3

`define CA53_ETM_PART_NUM 12'h95D

`define CA53_CTI_PART_NUM 12'h9A8

`define CA53_CTI_COMPONID0_VAL   32'h0000000D // Component ID0 reg
`define CA53_CTI_COMPONID1_VAL   32'h00000090 // Component ID1 reg (CS Class)
`define CA53_CTI_COMPONID2_VAL   32'h00000005 // Component ID2 reg
`define CA53_CTI_COMPONID3_VAL   32'h000000B1 // Component ID3 reg
`define CA53_CTI_DEVTYPE_VAL     8'h14        // Device Type reg
`define CA53_CTI_DEVARCH_VAL     32'h47701A14 // Device Arch reg

// Extended ID register set values
`define CA53_ID_PFR0_READ_VALUE             32'h00000131
`define CA53_ID_PFR1_READ_VALUE(giccdis)    ((giccdis) ? 32'h00011011 : 32'h10011011)
`define CA53_ID_DFR0_READ_VALUE             32'h03010066
`define CA53_ID_AFR0_READ_VALUE             32'h00000000

`define CA53_ID_MMFR0_READ_VALUE            32'h10201105
`define CA53_ID_MMFR1_READ_VALUE            32'h40000000
`define CA53_ID_MMFR2_READ_VALUE            32'h01260000
`define CA53_ID_MMFR3_READ_VALUE            32'h02102211
`define CA53_ID_ISAR0_READ_VALUE            32'h02101110
`define CA53_ID_ISAR1_READ_VALUE            32'h13112111
`define CA53_ID_ISAR2_READ_VALUE            32'h21232042
`define CA53_ID_ISAR3_READ_VALUE            32'h01112131
`define CA53_ID_ISAR4_READ_VALUE            32'h00011142
`define CA53_ID_ISAR5_READ_VALUE(cryptodis) ((cryptodis) ? 32'h00010001 : 32'h00011121)

`define CA53_FPSID_READ_VALUE {`CA53_IMPLEMENTOR,1'b0,`CA53_VFP_SUBARCH,`CA53_VFP_PART_NUM,`CA53_VFP_VARIANT,`CA53_PERPH_REVISION}
`define CA53_MVFR0_READ_VALUE (NEON_FP ? 32'h10110222 : 32'h00000000)
`define CA53_MVFR1_READ_VALUE (NEON_FP ? 32'h12111111 : 32'h00000000)
`define CA53_MVFR2_READ_VALUE (NEON_FP ? 32'h00000043 : 32'h00000000)

`define CA53_AA64PFR0_READ_VALUE(giccdis)     ({36'h00000000_0, ((giccdis) ? 4'h0 : 4'h1), (NEON_FP ? 8'h00 : 8'hFF), 16'h2222})
`define CA53_AA64PFR1_READ_VALUE              64'h00000000_00000000
`define CA53_AA64DFR0_READ_VALUE              {32'h00000000, `CA53_NUM_BRP_CID, 4'h0, `CA53_NUM_WRP, 4'h0, `CA53_NUM_BRP, 12'h106}
`define CA53_AA64DFR1_READ_VALUE              64'h00000000_00000000
`define CA53_AA64AFR0_READ_VALUE              64'h00000000_00000000
`define CA53_AA64AFR1_READ_VALUE              64'h00000000_00000000
`define CA53_AA64ISAR0_READ_VALUE(cryptodis)  ((cryptodis) ? 64'h00000000_00010000 : 64'h00000000_00011120)
`define CA53_AA64ISAR1_READ_VALUE             64'h00000000_00000000
`define CA53_AA64MMFR0_READ_VALUE             64'h00000000_00001122
`define CA53_AA64MMFR1_READ_VALUE             64'h00000000_00000000

`define CA53_NUM_PMN  6
//                                RES0     UEN   WT    NA    EX    CCD   CC    SIZE   N
`define CA53_PMCFGR_READ_VALUE   {12'h000, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 6'd63, 8'd`CA53_NUM_PMN}
`define CA53_PMCEID0_READ_VALUE  (L2_CACHE ? 32'h67ffbfff : 32'h663fbfff)

`define CA53_PMDEVARCH_READ_VALUE 32'h47702a16
`define CA53_PMDEVTYPE_READ_VALUE 32'h00000016

// ------------------------------------------------------
// Debug Register offsets
// ------------------------------------------------------

`define CA53_DBG_EDESR          10'h008 //(12'h020>>2) // External Debug Event Status Register
`define CA53_DBG_EDECR          10'h009 //(12'h024>>2) // Event Catch Register
`define CA53_DBG_EDWAR_LO       10'h00C //(12'h030>>2) // External Debug Watchpoint Register Low
`define CA53_DBG_EDWAR_HI       10'h00D //(12'h034>>2) // External Debug Watchpoint Register High
`define CA53_DBG_DTRRX          10'h020 //(12'h080>>2) // Host -> Target Data Transfer Register
`define CA53_DBG_EDITR          10'h021 //(12'h084>>2) // Instruction Transfer Register
`define CA53_DBG_EDSCR          10'h022 //(12'h088>>2) // Debug Status and Control Register
`define CA53_DBG_DTRTX          10'h023 //(12'h08C>>2) // Target -> Host Data Transfer Register
`define CA53_DBG_EDRCR          10'h024 //(12'h090>>2) // Debug Run Control Register
`define CA53_DBG_EDACR          10'h025 //(12'h094>>2) // External Debug Auxiliary Control Register
`define CA53_DBG_EDECCR         10'h026 //(12'h098>>2) // External Debug Exception Catch Control Register
`define CA53_DBG_EDPCSRlo       10'h028 //(12'h0A0>>2) // External Debug Program Counter Sampling Register Low
`define CA53_DBG_EDCIDSR        10'h029 //(12'h0A4>>2) // External Debug Context ID Sampling Register
`define CA53_DBG_EDVIDSR        10'h02A //(12'h0A8>>2) // External Debug Virtual Context Sample Register
`define CA53_DBG_EDPCSRhi       10'h02B //(12'h0AC>>2) // External Debug Program Counter Sampling Register High
`define CA53_DBG_OSLAR          10'h0C0 //(12'h300>>2) // OS Lock Access Register
`define CA53_DBG_EDPRCR         10'h0C4 //(12'h310>>2) // Device Power-down & Reset Control Register
`define CA53_DBG_EDPRSR         10'h0C5 //(12'h314>>2) // Device Power-down & Reset Status Register
`define CA53_DBG_BVR0lo         10'h100 //(12'h400>>2) // Breakpoint Value Register 0
`define CA53_DBG_BVR0hi         10'h101 //(12'h404>>2) // Breakpoint Value Register 0
`define CA53_DBG_BCR0           10'h102 //(12'h408>>2) // Breakpoint Control Register 0
`define CA53_DBG_BVR1lo         10'h104 //(12'h410>>2) // Breakpoint Value Register 1
`define CA53_DBG_BVR1hi         10'h105 //(12'h414>>2) // Breakpoint Value Register 1
`define CA53_DBG_BCR1           10'h106 //(12'h418>>2) // Breakpoint Control Register 1
`define CA53_DBG_BVR2lo         10'h108 //(12'h420>>2) // Breakpoint Value Register 2
`define CA53_DBG_BVR2hi         10'h109 //(12'h424>>2) // Breakpoint Value Register 2
`define CA53_DBG_BCR2           10'h10A //(12'h428>>2) // Breakpoint Control Register 2
`define CA53_DBG_BVR3lo         10'h10C //(12'h430>>2) // Breakpoint Value Register 3
`define CA53_DBG_BVR3hi         10'h10D //(12'h434>>2) // Breakpoint Value Register 3
`define CA53_DBG_BCR3           10'h10E //(12'h438>>2) // Breakpoint Control Register 3
`define CA53_DBG_BVR4lo         10'h110 //(12'h440>>2) // Breakpoint Value Register 4
`define CA53_DBG_BVR4hi         10'h111 //(12'h444>>2) // Breakpoint Value Register 4
`define CA53_DBG_BCR4           10'h112 //(12'h448>>2) // Breakpoint Control Register 4
`define CA53_DBG_BVR5lo         10'h114 //(12'h450>>2) // Breakpoint Value Register 5
`define CA53_DBG_BVR5hi         10'h115 //(12'h454>>2) // Breakpoint Value Register 5
`define CA53_DBG_BCR5           10'h116 //(12'h458>>2) // Breakpoint Control Register 5
`define CA53_DBG_WVR0lo         10'h200 //(12'h800>>2) // Watchpoint Value Register 0
`define CA53_DBG_WVR0hi         10'h201 //(12'h804>>2) // Watchpoint Value Register 0
`define CA53_DBG_WCR0           10'h202 //(12'h808>>2) // Watchpoint Control Register 0
`define CA53_DBG_WVR1lo         10'h204 //(12'h810>>2) // Watchpoint Value Register 1
`define CA53_DBG_WVR1hi         10'h205 //(12'h814>>2) // Watchpoint Value Register 1
`define CA53_DBG_WCR1           10'h206 //(12'h818>>2) // Watchpoint Control Register 1
`define CA53_DBG_WVR2lo         10'h208 //(12'h820>>2) // Watchpoint Value Register 2
`define CA53_DBG_WVR2hi         10'h209 //(12'h824>>2) // Watchpoint Value Register 2
`define CA53_DBG_WCR2           10'h20A //(12'h828>>2) // Watchpoint Control Register 2
`define CA53_DBG_WVR3lo         10'h20C //(12'h830>>2) // Watchpoint Value Register 3
`define CA53_DBG_WVR3hi         10'h20D //(12'h834>>2) // Watchpoint Value Register 3
`define CA53_DBG_WCR3           10'h20E //(12'h838>>2) // Watchpoint Control Register 3
`define CA53_DBG_MIDR           10'h340 //(12'hD00>>2) // Main ID Register
`define CA53_DBG_ID_AA64PFR0lo  10'h348 //(12'hD20>>2) // Processor Feature Register 0 (low word)
`define CA53_DBG_ID_AA64PFR0hi  10'h349 //(12'hD24>>2) // Processor Feature Register 0 (high word)
`define CA53_DBG_ID_AA64DFR0lo  10'h34A //(12'hD28>>2) // Debug Feature Register 0 (low word)
`define CA53_DBG_ID_AA64DFR0hi  10'h34B //(12'hD2C>>2) // Debug Feature Register 0 (high word)
`define CA53_DBG_ID_AA64ISAR0lo 10'h34C //(12'hD30>>2) // Instruction Set Attribute Register 0 (low word)
`define CA53_DBG_ID_AA64ISAR0hi 10'h34D //(12'hD34>>2) // Instruction Set Attribute Register 0 (high word)
`define CA53_DBG_ID_AA64MMFR0lo 10'h34E //(12'hD38>>2) // Memory Model Feature Register 0 (low word)
`define CA53_DBG_ID_AA64MMFR0hi 10'h34F //(12'hD3C>>2) // Memory Model Feature Register 0 (high word)
`define CA53_DBG_ID_AA64PFR1lo  10'h350 //(12'hD40>>2) // Processor Feature Register 1 (low word)
`define CA53_DBG_ID_AA64PFR1hi  10'h351 //(12'hD44>>2) // Processor Feature Register 1 (high word)
`define CA53_DBG_ID_AA64DFR1lo  10'h352 //(12'hD48>>2) // Debug Feature Register 1 (low word)
`define CA53_DBG_ID_AA64DFR1hi  10'h353 //(12'hD4C>>2) // Debug Feature Register 1 (high word)
`define CA53_DBG_ID_AA64ISAR1lo 10'h354 //(12'hD50>>2) // Instruction Set Attribute Register 1 (low word)
`define CA53_DBG_ID_AA64ISAR1hi 10'h355 //(12'hD54>>2) // Instruction Set Attribute Register 1 (high word)
`define CA53_DBG_ID_AA64MMFR1lo 10'h356 //(12'hD58>>2) // Memory Model Feature Register 1 (low word)
`define CA53_DBG_ID_AA64MMFR1hi 10'h356 //(12'hD58>>2) // Memory Model Feature Register 1 (low word)
`define CA53_DBG_CLAIMSET       10'h3E8 //(12'hFA0>>2) // Claim Tag Set Register
`define CA53_DBG_CLAIMCLR       10'h3E9 //(12'hFA4>>2) // Claim Tag Clear Register
`define CA53_DBG_DEVAFF0        10'h3EA //(12'hFA8>>2) // Device Affinity Register
`define CA53_DBG_DEVAFF1        10'h3EB //(12'hFAC>>2) // Device Affinity Register
`define CA53_DBG_LAR            10'h3EC //(12'hFB0>>2) // Lock Access Register
`define CA53_DBG_LSR            10'h3ED //(12'hFB4>>2) // Lock Status Register
`define CA53_DBG_AUTHSTATUS     10'h3EE //(12'hFB8>>2) // Authentication Status Register
`define CA53_DBG_DEVARCH        10'h3EF //(12'hFBC>>2) // Device Architecture Register
`define CA53_DBG_DEVID2         10'h3F0 //(12'hFC0>>2) // Debug Device ID2 Register
`define CA53_DBG_DEVID1         10'h3F1 //(12'hFC4>>2) // Debug Device ID1 Register
`define CA53_DBG_DEVID          10'h3F2 //(12'hFC8>>2) // Debug Device ID Register
`define CA53_DBG_DEVTYPE        10'h3F3 //(12'hFCC>>2) // Device Type Register
`define CA53_DBG_PID4           10'h3F4 //(12'hFD0>>2) // Peripheral ID4 register
`define CA53_DBG_PID0           10'h3F8 //(12'hFE0>>2) // Peripheral ID0 register
`define CA53_DBG_PID1           10'h3F9 //(12'hFE4>>2) // Peripheral ID1 register
`define CA53_DBG_PID2           10'h3FA //(12'hFE8>>2) // Peripheral ID2 register
`define CA53_DBG_PID3           10'h3FB //(12'hFEC>>2) // Peripheral ID3 register
`define CA53_DBG_CID0           10'h3FC //(12'hFF0>>2) // Component ID0 register
`define CA53_DBG_CID1           10'h3FD //(12'hFF4>>2) // Component ID1 register
`define CA53_DBG_CID2           10'h3FE //(12'hFF8>>2) // Component ID2 register
`define CA53_DBG_CID3           10'h3FF //(12'hFFC>>2) // Component ID3 register

`define CA53_DBG_BVR             4'h4   //(12'h400>>8) // DBG BVR Registers
`define CA53_DBG_WVR             4'h8   //(12'h800>>8) // DBG WVR Registers

// ------------------------------------------------------
// PMU Register offsets
// ------------------------------------------------------

`define CA53_PMU_PMEVCNTRn_EL0(n)   {4'b0000, n[4:0], 1'b0} // (12'h000+8n) Event Counter Registers
`define CA53_PMU_PMCCNTR_EL0_lo     10'h03E                 //  12'h0F8     Performance Monitors Cycle Counter
`define CA53_PMU_PMCCNTR_EL0_hi     10'h03F                 //  12'h0FC     Performance Monitors Cycle Counter
`define CA53_PMU_PMEVTYPER0_EL0     10'h100                 //  12'h400     Event Type and Filter Register 0
`define CA53_PMU_PMEVTYPERn_EL0(n)  {5'b01000, n[4:0]}      // (12'h400+4n) Event Type and Filter Registers
`define CA53_PMU_PMCCFILTR_EL0      10'h11F                 //  12'h47C     Cycle Counter Filter Register
`define CA53_PMU_PMCNTENSET_EL0     10'h300                 //  12'hC00     Count Enable Set Register
`define CA53_PMU_PMCNTENCLR_EL0     10'h308                 //  12'hC20     Count Enable Clear Register
`define CA53_PMU_PMINTENSET_EL1     10'h310                 //  12'hC40     Interrupt Enable Set Register
`define CA53_PMU_PMINTENCLR_EL1     10'h318                 //  12'hC60     Interrupt Enable Clear Register
`define CA53_PMU_PMOVSCLR_EL0       10'h320                 //  12'hC80     Overflow Flag Status Clear Register
`define CA53_PMU_PMSWINC_EL0        10'h328                 //  12'hCA0     Software Increment Register
`define CA53_PMU_PMOVSSET_EL0       10'h330                 //  12'hCC0     Overflow Status Set register
`define CA53_PMU_PMCFGR             10'h380                 //  12'hE00     Performance Monitors Configuration Register
`define CA53_PMU_PMCR_EL0           10'h381                 //  12'hE04     Performance Monitors Control Register
`define CA53_PMU_PMCEID0_EL0        10'h388                 //  12'hE20     Common Event Identification Register 0
`define CA53_PMU_PMCEID1_EL0        10'h389                 //  12'hE24     Common Event Identification Register 1
`define CA53_PMU_DEVAFF0            10'h3EA                 //  12'hFA8     Device Affinity Register 0
`define CA53_PMU_DEVAFF1            10'h3EB                 //  12'hFAC     Device Affinity Register 1
`define CA53_PMU_LAR                10'h3EC                 //  12'hFB0     Lock Access Register
`define CA53_PMU_LSR                10'h3ED                 //  12'hFB4     Lock Status Register
`define CA53_PMU_AUTHSTATUS         10'h3EE                 //  12'hFB8     Authentication Status Register
`define CA53_PMU_DEVARCH            10'h3EF                 //  12'hFBC     Device Architecture Register
`define CA53_PMU_DEVTYPE            10'h3F3                 //  12'hFCC     Device Type Register
`define CA53_PMU_PID4               10'h3F4                 //  12'hFD0     Peripheral ID4 register
`define CA53_PMU_PID0               10'h3F8                 //  12'hFE0     Peripheral ID0 register
`define CA53_PMU_PID1               10'h3F9                 //  12'hFE4     Peripheral ID1 register
`define CA53_PMU_PID2               10'h3FA                 //  12'hFE8     Peripheral ID2 register
`define CA53_PMU_PID3               10'h3FB                 //  12'hFEC     Peripheral ID3 register
`define CA53_PMU_CID0               10'h3FC                 //  12'hFF0     Component ID0 register
`define CA53_PMU_CID1               10'h3FD                 //  12'hFF4     Component ID1 register
`define CA53_PMU_CID2               10'h3FE                 //  12'hFF8     Component ID2 register
`define CA53_PMU_CID3               10'h3FF                 //  12'hFFC     Component ID3 register

// ------------------------------------------------------
// ETM Register offsets
// ------------------------------------------------------
`define CA53_ETM_OSLAR       10'h0C0 //(12'h300>>2) // OS Lock Access Register
`define CA53_ETM_OSLSR       10'h0C1 //(12'h304>>2) // OS Lock Status Register
`define CA53_ETM_PDCR        10'h0C4 //(12'h310>>2) // Power Down Control Register
`define CA53_ETM_PDSR        10'h0C5 //(12'h314>>2) // Power Down Status Register
`define CA53_ETM_DEVAFF0     10'h3EA //(12'hFA8>>2) // Device Affinity Register
`define CA53_ETM_DEVAFF1     10'h3EB //(12'hFAC>>2) // Device Affinity Register
`define CA53_ETM_LAR         10'h3EC //(12'hFB0>>2) // Lock Access Register
`define CA53_ETM_LSR         10'h3ED //(12'hFB4>>2) // Lock Status Register
`define CA53_ETM_AUTHSTATUS  10'h3EE //(12'hFB8>>2) // Authentication Status Register
`define CA53_ETM_DEVARCH     10'h3EF //(12'hFBC>>2) // Device Architecture Register
`define CA53_ETM_DEVTYPE     10'h3F3 //(12'hFCC>>2) // Device Type Register
`define CA53_ETM_PID4        10'h3F4 //(12'hFD0>>2) // Peripheral ID4 register
`define CA53_ETM_PID0        10'h3F8 //(12'hFE0>>2) // Peripheral ID0 register
`define CA53_ETM_PID1        10'h3F9 //(12'hFE4>>2) // Peripheral ID1 register
`define CA53_ETM_PID2        10'h3FA //(12'hFE8>>2) // Peripheral ID2 register
`define CA53_ETM_PID3        10'h3FB //(12'hFEC>>2) // Peripheral ID3 register
`define CA53_ETM_CID0        10'h3FC //(12'hFF0>>2) // Component ID0 register
`define CA53_ETM_CID1        10'h3FD //(12'hFF4>>2) // Component ID1 register
`define CA53_ETM_CID2        10'h3FE //(12'hFF8>>2) // Component ID2 register
`define CA53_ETM_CID3        10'h3FF //(12'hFFC>>2) // Component ID3 register

// ------------------------------------------------------
// CTI Register offsets
// ------------------------------------------------------
`define CA53_CTI_CONTROL_ADD       10'h000
`define CA53_CTI_INTACK_ADD        10'h004
`define CA53_CTI_APPSET_ADD        10'h005
`define CA53_CTI_APPCLR_ADD        10'h006
`define CA53_CTI_APPPULSE_ADD      10'h007

`define CA53_CTI_TRIGINSTATUS_ADD  10'h04C
`define CA53_CTI_TRIGOUTSTATUS_ADD 10'h04D
`define CA53_CTI_CHINSTATUS_ADD    10'h04E
`define CA53_CTI_CHOUTSTATUS_ADD   10'h04F

`define CA53_CTI_ITCONTROL_ADD     10'b1111_0000_00 // 0xF00

`define CA53_CTI_CHANNELGATE_ADD   10'b0001_0100_00

`define CA53_CTI_CLAIMSET_ADD    10'h3E8    // Claim Tag Bit Set reg     (0xFA0)
`define CA53_CTI_CLAIMCLR_ADD    10'h3E9    // Claim Tag Bit Clear reg   (0xFA4)
`define CA53_CTI_DEVAFF0         10'h3EA    // Device Affinity Register  (0xFA8)
`define CA53_CTI_DEVAFF1         10'h3EB    // Device Affinity Register  (0xFAC)
`define CA53_CTI_LOCKACCESS_ADD  10'h3EC    // Lock Access reg           (0xFB0)
`define CA53_CTI_LOCKSTATUS_ADD  10'h3ED    // Lock Status reg           (0xFB4)
`define CA53_CTI_AUTHSTATUS_ADD  10'h3EE    // Authentication Status reg (0xFB8)
`define CA53_CTI_DEVARCH_ADD     10'h3EF    // Device Arch reg           (0xFBC)
`define CA53_CTI_DEVID2_ADD      10'h3F0    // Device ID 2 reg           (0xFC0)
`define CA53_CTI_DEVID1_ADD      10'h3F1    // Device ID 1 reg           (0xFC4)
`define CA53_CTI_DEVID_ADD       10'h3F2    // Device ID reg             (0xFC8)
`define CA53_CTI_DEVTYPE_ADD     10'h3F3    // Device Type reg           (0xFCC)

`define CA53_CTI_PERIPHID4_ADD   10'h3F4    // Peripheral ID4 reg        (0xFD0)
`define CA53_CTI_PERIPHID5_ADD   10'h3F5    // Peripheral ID5 reg        (0xFD4)
`define CA53_CTI_PERIPHID6_ADD   10'h3F6    // Peripheral ID6 reg        (0xFD8)
`define CA53_CTI_PERIPHID7_ADD   10'h3F7    // Peripheral ID7 reg        (0xFDC)
`define CA53_CTI_PERIPHID0_ADD   10'h3F8    // Peripheral ID0 reg        (0xFE0)
`define CA53_CTI_PERIPHID1_ADD   10'h3F9    // Peripheral ID1 reg        (0xFE4)
`define CA53_CTI_PERIPHID2_ADD   10'h3FA    // Peripheral ID2 reg        (0xFE8)
`define CA53_CTI_PERIPHID3_ADD   10'h3FB    // Peripheral ID3 reg        (0xFEC)
`define CA53_CTI_COMPONID0_ADD   10'h3FC    // Component ID0 reg         (0xFF0)
`define CA53_CTI_COMPONID1_ADD   10'h3FD    // Component ID1 reg         (0xFF4)
`define CA53_CTI_COMPONID2_ADD   10'h3FE    // Component ID2 reg         (0xFF8)
`define CA53_CTI_COMPONID3_ADD   10'h3FF    // Component ID3 reg         (0xFFC)


// ------------------------------------------------------
// Debug Identification Register DIDR
// ------------------------------------------------------

`define CA53_DBG_VER     4'b0110 // Debug architecture version v8
`define CA53_NUM_BRP_CID 4'h1    // Number of Break point Register Pairs with context ID comparison capability -1
                                 // Note: 4'b0000 => 1 register pair. For details
                                 // please refer to the v7debug architecture spec.

`define CA53_NUM_BRP     4'h5        // Number of implemented Breakpoint Pairs -1
`define CA53_NUM_WRP     4'h3        // Number of implemented Watchpoint Register Pair -1

//                                                           [11:0]  - reserved (RAZ)-----------------------------
//                                                           [12]    - Security extensions implemented------      |
//                                                           [13]    - PCSR implemented----------------     |     |
//                                                           [14]    - Not implemented bit,it returns  |    |     |
//                                                                     the same value as bit 12 --     |    |     |
//                                                           [15]    - DBGDEVID bit RAO -----     |    |    |     |
//                                                                                           |    |    |    |     |
`define CA53_DIDR_READ_VALUE {`CA53_NUM_WRP,`CA53_NUM_BRP,`CA53_NUM_BRP_CID,`CA53_DBG_VER,1'b1,1'b1,1'b0,1'b1,12'h000}

`define CA53_DBGDEVID_READ_VALUE  32'h00110F13
`define CA53_DBGDEVID1_READ_VALUE 32'h00000002
`define CA53_DBGDEVID2_READ_VALUE 32'h00000000

`define CA53_EDDEVID_READ_VALUE  32'h00000003
`define CA53_EDDEVID1_READ_VALUE 32'h00000002
`define CA53_EDDEVID2_READ_VALUE 32'h00000000

`define CA53_EDDEVARCH_READ_VALUE 32'h47706a15
`define CA53_EDDEVTYPE_READ_VALUE 32'h00000015

// ------------------------------------------------------
// Include header for OVL assertions
// ------------------------------------------------------

`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"
`endif

// ----------------
// ECC parity sense
// ----------------

`define CA53_ECC_ODD  1'b1
`define CA53_ECC_EVEN 1'b0

// ------------------------------------------------------
// D-side and I-side Fault Encodings
// ------------------------------------------------------

// VMSA Format
// {Ext, 1'b0, FS[4:0]}
`define CA53_FAULT_VMSA_ALIGNMENT            7'b0000001  // Alignment fault (D-side only)
`define CA53_FAULT_VMSA_PAGEWALK_EXT1_DEC    7'b0001100  // External abort on 1st level descriptor (Decode)
`define CA53_FAULT_VMSA_PAGEWALK_EXT1_SLV    7'b1001100  // External abort on 1st level descriptor (Slave)
`define CA53_FAULT_VMSA_PAGEWALK_EXT1_ECC    7'b0011100  // ECC error on 1st level descriptor
`define CA53_FAULT_VMSA_PAGEWALK_EXT2_DEC    7'b0001110  // External abort on 2nd level descriptor (Decode)
`define CA53_FAULT_VMSA_PAGEWALK_EXT2_SLV    7'b1001110  // External abort on 2nd level descriptor (Slave)
`define CA53_FAULT_VMSA_PAGEWALK_EXT2_ECC    7'b0011110  // ECC error on 2nd level descriptor
`define CA53_FAULT_VMSA_TRANSLATION_SEC      7'b0000101  // Translation fault on a section
`define CA53_FAULT_VMSA_TRANSLATION_PAGE     7'b0000111  // Translation fault on a page
`define CA53_FAULT_VMSA_ACCESS_SEC           7'b0000011  // Access flag fault on a section
`define CA53_FAULT_VMSA_ACCESS_PAGE          7'b0000110  // Access flag fault on a page
`define CA53_FAULT_VMSA_DOMAIN_SEC           7'b0001001  // Domain fault on a section
`define CA53_FAULT_VMSA_DOMAIN_PAGE          7'b0001011  // Domain fault on a page
`define CA53_FAULT_VMSA_PERMISSION_SEC       7'b0001101  // Permission fault on a section
`define CA53_FAULT_VMSA_PERMISSION_PAGE      7'b0001111  // Permission fault on a page
`define CA53_FAULT_VMSA_EXT_DEC              7'b0001000  // External AXI decode error
`define CA53_FAULT_VMSA_EXT_SLV              7'b1001000  // External AXI slave error
`define CA53_FAULT_VMSA_ECC                  7'b0011001  // ECC error
`define CA53_FAULT_VMSA_LDREX                7'b0010101  // Unsupported exclusive

// LPAE Format
// - The 5-bit encodings need to have the 2-bit level value appended as bits
// [1:0] to form the full 7-bit encoding
// {Ext, FS[5:0]}
// Note that these encodings are also used to represent VMSA faults internally
// and so include domain faults which LPAE cannot generate
`define CA53_FAULT_LPAE_ALIGNMENT            7'b0100001
`define CA53_FAULT_LPAE_PAGEWALK_EXT_DEC     5'b00101
`define CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0  7'b0010100
`define CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1  7'b0010101
`define CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2  7'b0010110
`define CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3  7'b0010111
`define CA53_FAULT_LPAE_PAGEWALK_EXT_SLV     5'b10101
`define CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0  7'b1010100
`define CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1  7'b1010101
`define CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2  7'b1010110
`define CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3  7'b1010111
`define CA53_FAULT_LPAE_PAGEWALK_EXT_ECC     5'b00111
`define CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0  7'b0011100
`define CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1  7'b0011101
`define CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2  7'b0011110
`define CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3  7'b0011111
`define CA53_FAULT_LPAE_TRANSLATION          5'b00001
`define CA53_FAULT_LPAE_TRANSLATION_L0       7'b0000100
`define CA53_FAULT_LPAE_TRANSLATION_L1       7'b0000101
`define CA53_FAULT_LPAE_TRANSLATION_L2       7'b0000110
`define CA53_FAULT_LPAE_TRANSLATION_L3       7'b0000111
`define CA53_FAULT_LPAE_ACCESS               5'b00010
`define CA53_FAULT_LPAE_ACCESS_L0            7'b0001000
`define CA53_FAULT_LPAE_ACCESS_L1            7'b0001001
`define CA53_FAULT_LPAE_ACCESS_L2            7'b0001010
`define CA53_FAULT_LPAE_ACCESS_L3            7'b0001011
`define CA53_FAULT_LPAE_PERMISSION           5'b00011
`define CA53_FAULT_LPAE_PERMISSION_L0        7'b0001100
`define CA53_FAULT_LPAE_PERMISSION_L1        7'b0001101
`define CA53_FAULT_LPAE_PERMISSION_L2        7'b0001110
`define CA53_FAULT_LPAE_PERMISSION_L3        7'b0001111
`define CA53_FAULT_LPAE_DOMAIN               5'b01111
`define CA53_FAULT_LPAE_DOMAIN_L1            7'b0111101
`define CA53_FAULT_LPAE_DOMAIN_L2            7'b0111110
`define CA53_FAULT_LPAE_ADDR_SIZE            5'b00000
`define CA53_FAULT_LPAE_ADDR_SIZE_L0         7'b0000000
`define CA53_FAULT_LPAE_ADDR_SIZE_L1         7'b0000001
`define CA53_FAULT_LPAE_ADDR_SIZE_L2         7'b0000010
`define CA53_FAULT_LPAE_ADDR_SIZE_L3         7'b0000011
`define CA53_FAULT_LPAE_EXT_DEC              7'b0010000
`define CA53_FAULT_LPAE_EXT_SLV              7'b1010000
`define CA53_FAULT_LPAE_LDREX                7'b0110101
`define CA53_FAULT_LPAE_ECC                  7'b0011000

// The following encoding is used to return stack alignment exceptions
// from the DCU to the DPU, even though they are not LPAE/VMSA faults
`define CA53_FAULT_LPAE_STACK_ALIGN          7'b1111111

// Fault decode macros
`define CA53_FAULT_PAGEWALK_EXT(fault)     ((fault[5:4] == 2'b01) & fault[2])
`define CA53_FAULT_DOMAIN(fault)           (fault[6:3] == 4'b0111)
`define CA53_FAULT_ECC(fault)              (fault[5:3] == 3'b011)
`define CA53_FAULT_ALIGNMENT(fault)        (fault[5:4] == 2'b10)
`define CA53_FAULT_EXT(fault)              (fault[4] & ~fault[2])
`define CA53_FAULT_GEN_EXT(fault)          (fault[5:4] == 2'b01)
`define CA53_FAULT_STACK_ALIGN(fault)      (fault[6:4] == 3'b111)

// ------------------------------------------------------
// Memory attribute decoding
// ------------------------------------------------------

//
// Device   000VDD10
// Outer WB 001IHHSS
// Outer WT 01YYHHSS
// Outer NC 0111YYSS
// Coherent 1TAAHHSS
//
// SS is Shareability
// 00 non-shareable
// 01 unused
// 10 outer shareable
// 11 inner shareable
//
// V is stage1 overridden to device by stage2
//
// DD is device type
// 00 nGnRnE
// 01 nGnRE
// 10 nGRE
// 11 GRE
//
// I is inner type
// 0 NC
// 1 WT
//
// HH is outer allocation hint
// 00 no alloc
// 01 write alloc
// 10 read alloc
// 11 read and write alloc
//
// YY is inner type
// 00 NC
// 01 WB
// 10 WT
// 11 unused
//
// T is transient hint
// 0 non-transient
// 1 transient
//
// AA is inner allocation hint
// 00 no alloc
// 01 write alloc
// 10 read alloc
// 11 read and write alloc

// Unless specified, these refer to inner attributes

`define CA53_MEM_NORMAL(attrs)             (|attrs[7:5])
`define CA53_MEM_DEVICE(attrs)             (~|attrs[7:5])
`define CA53_MEM_DEVICE_nG(attrs)          (~|attrs[7:5] & ~&attrs[3:2])
`define CA53_MEM_nGnRnE(attrs)             ((~|attrs[7:5]) & (attrs[3:2] == 2'b00))
`define CA53_MEM_nGnRE(attrs)              ((~|attrs[7:5]) & (attrs[3:2] == 2'b01))
`define CA53_MEM_nGRE(attrs)               ((~|attrs[7:5]) & (attrs[3:2] == 2'b10))
`define CA53_MEM_GRE(attrs)                ((~|attrs[7:5]) & (attrs[3:2] == 2'b11))
`define CA53_MEM_WB(attrs)                 (attrs[7] | (attrs[6] & ((attrs[5:2] == 4'b1101) | (attrs[5:4] == 2'b01))))
`define CA53_MEM_WBWA(attrs)               (attrs[7] & attrs[4])
`define CA53_MEM_WBRA(attrs)               (attrs[7] & attrs[5])
`define CA53_MEM_WT(attrs)                 (~attrs[7] & ((attrs[6:4] == 3'b011) | (attrs[6:4] == 3'b110) | (attrs[6:2] == 5'b11110)))
`define CA53_MEM_NC(attrs)                 (~attrs[7] & ((attrs[6:4] == 3'b010) | (attrs[6:4] == 3'b100) | (attrs[6:2] == 5'b11100)))
`define CA53_MEM_OUTER_WB(attrs)           (attrs[7] | (attrs[6:5] == 2'b01))
`define CA53_MEM_OUTER_WT(attrs)           ((attrs[7:6] == 2'b01) & ~&attrs[5:4])
`define CA53_MEM_OUTER_NC(attrs)           (attrs[7:4] == 4'b0111)
`define CA53_MEM_OUTER_RA(attrs)           ((attrs[7] | (attrs[6] & ~&attrs[5:4]) | attrs[5]) & attrs[3])
`define CA53_MEM_OUTER_WA(attrs)           ((attrs[7] | (attrs[6] & ~&attrs[5:4]) | attrs[5]) & attrs[2])
`define CA53_MEM_SHAREABLE(attrs)          (attrs[1])
`define CA53_MEM_O_SHAREABLE(attrs)        (attrs[1:0] == 2'b10)
`define CA53_MEM_COHERENT(attrs)           (attrs[7])
`define CA53_MEM_COHERENT_SHAREABLE(attrs) (attrs[7] & attrs[1])
`define CA53_MEM_MERGEABLE(attrs)          (`CA53_MEM_NORMAL(attrs) | `CA53_MEM_GRE(attrs))
`define CA53_MEM_REORDERABLE(attrs)        (`CA53_MEM_NORMAL(attrs) | `CA53_MEM_GRE(attrs) | `CA53_MEM_nGRE(attrs))
`define CA53_MEM_DEV_OVERRIDE(attrs)       (attrs[4])
`define CA53_MEM_TRANSIENT(attrs)          (&attrs[7:6])
`define CA53_MEM_UNUSED(attrs)             ((attrs[1:0] == 2'b01) | (attrs[7:2] == 6'b011111) | (((attrs[7:5] == 3'b000) | (attrs[7:2] == 6'b011100)) & (attrs[1:0] != 2'b10)))

`define CA53_MEM_ICACHE_DISABLED   8'b01110010
`define CA53_MEM_DCACHE_DISABLED   8'b01110010
`define CA53_MEM_DEFAULT_CACHEABLE 8'b10111100
`define CA53_MEM_MMUOFF_ION        8'b01101000
`define CA53_MEM_MMUOFF_IOFF       8'b01110010
`define CA53_MEM_MMUOFF_D          8'b00000010

// Defines for some memory types. This is not all possible encodings, only the
// ones that are needed as explict values.
`define CA53_PAGE_DEV_STAGE1_NGNRNE_SHARE_OS       8'b00000010
`define CA53_PAGE_DEV_STAGE1_NGNRE_SHARE_OS        8'b00000110
`define CA53_PAGE_DEV_STAGE1_NGRE_SHARE_OS         8'b00001010
`define CA53_PAGE_DEV_STAGE1_GRE_SHARE_OS          8'b00001110
`define CA53_PAGE_DEV_STAGE2_NGNRNE_SHARE_OS       8'b00010010
`define CA53_PAGE_DEV_STAGE2_NGNRE_SHARE_OS        8'b00010110
`define CA53_PAGE_DEV_STAGE2_NGRE_SHARE_OS         8'b00011010
`define CA53_PAGE_DEV_STAGE2_GRE_SHARE_OS          8'b00011110
`define CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS       8'b01110010
`define CA53_PAGE_INNER_NC_OUTER_WT_SHARE_NS       8'b01001000
`define CA53_PAGE_INNER_NC_OUTER_WT_SHARE_OS       8'b01001010
`define CA53_PAGE_INNER_NC_OUTER_WB_SHARE_NS       8'b00101100
`define CA53_PAGE_INNER_NC_OUTER_WB_SHARE_OS       8'b00101110
`define CA53_PAGE_INNER_WT_OUTER_NC_SHARE_NS       8'b01111000
`define CA53_PAGE_INNER_WT_OUTER_NC_SHARE_OS       8'b01111010
`define CA53_PAGE_INNER_WT_OUTER_WT_SHARE_NS       8'b01101000
`define CA53_PAGE_INNER_WT_OUTER_WT_SHARE_OS       8'b01101010
`define CA53_PAGE_INNER_WT_OUTER_WB_SHARE_NS       8'b00111100
`define CA53_PAGE_INNER_WT_OUTER_WB_SHARE_OS       8'b00111110
`define CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_NS   8'b10101000
`define CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_OS   8'b10101010
`define CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_NS 8'b10111100
`define CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_OS 8'b10111110
`define CA53_PAGE_INNER_WBWA_OUTER_WBWA_SHARE_NS   8'b10010100
`define CA53_PAGE_INNER_WBRA_OUTER_WBRWA_SHARE_NS  8'b10101100
`define CA53_PAGE_INNER_WBRA_OUTER_WBRWA_SHARE_OS  8'b10101110
`define CA53_PAGE_INNER_WBRWA_OUTER_WBRA_SHARE_NS  8'b10111000
`define CA53_PAGE_INNER_WBRWA_OUTER_WBRA_SHARE_OS  8'b10111010


// DPU/DCU interface defines
`define CA53_LDST_SIZE_BYTE    2'b00 // Byte        (8-bits)  - LDRB/STRB etc
`define CA53_LDST_SIZE_HWORD   2'b01 // Half word   (16-bits) - LDRH/STRH etc
`define CA53_LDST_SIZE_WORD    2'b10 // Word        (32-bits) - LDR/STR, LDM/STM, LDREX/STREX all Floating-Point and Neon Load-Stores
`define CA53_LDST_SIZE_DWORD   2'b11 // Double word (64-bits) - LDRD/STRD, LDREXD/STREXD, RFE/SRS

// Cache line state encodings
`define CA53_MOESI_INVALID         2'b00
`define CA53_MOESI_SHARED          2'b01
`define CA53_MOESI_UNIQUE_NOT_MIG  2'b10
`define CA53_MOESI_UNIQUE_MIG      2'b11

// Decode cache line MOESI state
`define CA53_TAG_INVALID(moesi)    (~|moesi[1:0])
`define CA53_TAG_VALID(moesi)      (|moesi[1:0])
`define CA53_TAG_SHARED(moesi)     (moesi == `CA53_MOESI_SHARED)
`define CA53_TAG_UNIQUE(moesi)     (moesi[1])
`define CA53_TAG_MIGRATORY(moesi)  (&moesi[1:0])

// ------------------------------------------------------
// DCU/TLB CP operation encodings
// ------------------------------------------------------
// Note that the PAR has two encodings, one for software reads and writes of
// the register, and one for writes from V2P instructions (the only
// difference is whether to use ns state or ns scr for selecting the correct
// banked register).
//
// AArch32 Address For    Equivalent AArch64 Addresses
// -------------------    ----------------------------
// TTBR0                     TTBR0_EL1
// TTBR1                     TTBR1_EL1
// HTTBR                     TTBR0_EL2
// VTTBR                     VTTBR_EL2
//                           TTBR0_EL3
// TTBCR                     TCR_EL1
// HTCR                      TCR_EL2
// VTCR                      VTCR_EL2
//                           TCR_EL3
// MAIR0                     MAIR_EL1
// MAIR1                     Unused
// HMAIR0                    MAIR_EL2
// HMAIR1                    Unused
//                           MAIR_EL3
//                           CDBGDR3
//
`define CA53_CP15_REG_CDBGDR0        6'b000100
`define CA53_CP15_REG_CDBGDR1        6'b000101
`define CA53_CP15_REG_CDBGDR2        6'b000110
`define CA53_CP15_REG_CDBGDR3        6'b000111  // new address
`define CA53_CP15_V2P_PAR            6'b001000
`define CA53_CP15_REG_TTBR0          6'b010000
`define CA53_CP15_REG_TTBR1          6'b010001
`define CA53_CP15_REG_TTBR0_EL1      6'b010000  // duplicate new definition for AArch64
`define CA53_CP15_REG_TTBR1_EL1      6'b010001  // duplicate new definition for AArch64
`define CA53_CP15_REG_TTBCR          6'b010010
`define CA53_CP15_REG_TCR_EL1        6'b010010  // duplicate new definition for AArch64
`define CA53_CP15_REG_HTTBR          6'b010011
`define CA53_CP15_REG_VTTBR          6'b010100
`define CA53_CP15_REG_TTBR0_EL2      6'b010011  // duplicate new definition for AArch64
`define CA53_CP15_REG_VTTBR_EL2      6'b010100  // duplicate new definition for AArch64
`define CA53_CP15_REG_HTCR           6'b010101
`define CA53_CP15_REG_VTCR           6'b010110
`define CA53_CP15_REG_TCR_EL2        6'b010101  // duplicate new definition for AArch64
`define CA53_CP15_REG_VTCR_EL2       6'b010110  // duplicate new definition for AArch64
`define CA53_CP15_REG_PAR            6'b011000
`define CA53_CP15_REG_PAR_EL1        6'b011000  // duplicate new definition for AArch64
`define CA53_CP15_REG_MAIR0          6'b011001
`define CA53_CP15_REG_MAIR_EL1       6'b011001  // duplicate new definition for AArch64
`define CA53_CP15_REG_MAIR1          6'b011010
`define CA53_CP15_REG_HMAIR0         6'b011011
`define CA53_CP15_REG_MAIR_EL2       6'b011011  // duplicate new definition for AArch64
`define CA53_CP15_REG_HMAIR1         6'b011100
`define CA53_CP15_REG_CTXTID         6'b011101
`define CA53_CP15_REG_CTXTID_EL1     6'b011101  // duplicate new definition for AArch64
`define CA53_CP15_REG_TTBR0_EL3      6'b010111  // new address
`define CA53_CP15_REG_TCR_EL3        6'b011110  // new address
`define CA53_CP15_REG_MAIR_EL3       6'b011111  // new address
`define CA53_CP15_REG_DBGBVR0        6'b100000
`define CA53_CP15_REG_DBGBVR1        6'b100001
`define CA53_CP15_REG_DBGBVR2        6'b100010
`define CA53_CP15_REG_DBGBVR3        6'b100011
`define CA53_CP15_REG_DBGBVR4        6'b100100
`define CA53_CP15_REG_DBGBVR5        6'b100101
`define CA53_CP15_REG_DBGBCR0        6'b101000
`define CA53_CP15_REG_DBGBCR1        6'b101001
`define CA53_CP15_REG_DBGBCR2        6'b101010
`define CA53_CP15_REG_DBGBCR3        6'b101011
`define CA53_CP15_REG_DBGBCR4        6'b101100
`define CA53_CP15_REG_DBGBCR5        6'b101101
`define CA53_CP15_REG_DBGWVR0        6'b110000
`define CA53_CP15_REG_DBGWVR1        6'b110001
`define CA53_CP15_REG_DBGWVR2        6'b110010
`define CA53_CP15_REG_DBGWVR3        6'b110011
`define CA53_CP15_REG_DBGWCR0        6'b111000
`define CA53_CP15_REG_DBGWCR1        6'b111001
`define CA53_CP15_REG_DBGWCR2        6'b111010
`define CA53_CP15_REG_DBGWCR3        6'b111011
`define CA53_CP15_REG_DBGVCR         6'b111111
`define CA53_CP15_REG_DBGBXVR4       6'b111100
`define CA53_CP15_REG_DBGBXVR5       6'b111101


// ------------------------------------------------------
// GIC CPU Interface CP encodings
// ------------------------------------------------------

// Physical CPU Interface registers
// NOTE: Physical and Virtual CPU Interface register addresses are symmetric
`define CA53_GICREG_PCPU              1'b0
`define CA53_GICREG_PCPU_W            5
`define CA53_GICREG_PCPU_RESERVED     5'b0_00_00  // Reserved - No Op
`define CA53_GICREG_GICC_IAR1_EL1     5'b0_00_01
`define CA53_GICREG_GICC_IAR0_EL1     5'b0_00_10
`define CA53_GICREG_GICC_EOIR1_EL1    5'b0_00_11
`define CA53_GICREG_GICC_EOIR0_EL1    5'b0_01_00
`define CA53_GICREG_GICC_HPPIR1_EL1   5'b0_01_01
`define CA53_GICREG_GICC_HPPIR0_EL1   5'b0_01_10
`define CA53_GICREG_GICC_BPR1_EL1     5'b0_10_00
`define CA53_GICREG_GICC_BPR0_EL1     5'b0_10_01
`define CA53_GICREG_GICC_DIR_EL1      5'b0_10_10
`define CA53_GICREG_GICC_PMR_EL1      5'b0_10_11
`define CA53_GICREG_GICC_RPR          5'b0_11_00
`define CA53_GICREG_GICC_AP0R0_EL1    5'b0_11_01
`define CA53_GICREG_GICC_AP1R0_EL1    5'b0_11_10
`define CA53_GICREG_GICC_IGRPEN0_EL1  5'b0_11_11
`define CA53_GICREG_GICC_IGRPEN1_EL1  5'b1_00_00
`define CA53_GICREG_GICC_IGRPEN1_EL3  5'b1_00_01
`define CA53_GICREG_GICC_SRE_EL1      5'b1_00_11
`define CA53_GICREG_GICC_SRE_EL2      5'b1_01_00
`define CA53_GICREG_GICC_SRE_EL3      5'b1_01_01
`define CA53_GICREG_GICC_CTLR_EL1     5'b1_01_10
`define CA53_GICREG_GICC_CTLR_EL3     5'b1_01_11
`define CA53_GICREG_GICC_SGI0R_EL1    5'b1_10_00
`define CA53_GICREG_GICC_SGI1R_EL1    5'b1_10_01
`define CA53_GICREG_GICC_ASGI1R_EL1   5'b1_10_10

// Hypervisor Control Virtual CPU Interface registers
// NOTE: Physical and Virtual CPU Interface register addresses are symmetric
`define CA53_GICREG_VCPU              1'b1
`define CA53_GICREG_VCPU_W            6
`define CA53_GICREG_VCPU_RESERVED     6'b00_00_00 // Reserved - No Op
`define CA53_GICREG_GICV_AIAR         {1'b0,`CA53_GICREG_GICC_IAR1_EL1}
`define CA53_GICREG_GICV_IAR          {1'b0,`CA53_GICREG_GICC_IAR0_EL1}
`define CA53_GICREG_GICV_AEOIR        {1'b0,`CA53_GICREG_GICC_EOIR1_EL1}
`define CA53_GICREG_GICV_EOIR         {1'b0,`CA53_GICREG_GICC_EOIR0_EL1}
`define CA53_GICREG_GICV_AHPPIR       {1'b0,`CA53_GICREG_GICC_HPPIR1_EL1}
`define CA53_GICREG_GICV_HPPIR        {1'b0,`CA53_GICREG_GICC_HPPIR0_EL1}
`define CA53_GICREG_GICH_VMCR_BPR1    {1'b0,`CA53_GICREG_GICC_BPR1_EL1}
`define CA53_GICREG_GICH_VMCR_BPR0    {1'b0,`CA53_GICREG_GICC_BPR0_EL1}
`define CA53_GICREG_GICV_DIR          {1'b0,`CA53_GICREG_GICC_DIR_EL1}
`define CA53_GICREG_GICH_VMCR_PMR     {1'b0,`CA53_GICREG_GICC_PMR_EL1}
`define CA53_GICREG_GICV_RPR          {1'b0,`CA53_GICREG_GICC_RPR}
`define CA53_GICREG_GICV_CTLR         {1'b0,`CA53_GICREG_GICC_CTLR_EL1}
`define CA53_GICREG_GICH_APR0         {1'b0,`CA53_GICREG_GICC_AP0R0_EL1}
`define CA53_GICREG_GICH_APR1         {1'b0,`CA53_GICREG_GICC_AP1R0_EL1}
`define CA53_GICREG_GICH_VMCR_VENG0   {1'b0,`CA53_GICREG_GICC_IGRPEN0_EL1}
`define CA53_GICREG_GICH_VMCR_VENG1   {1'b0,`CA53_GICREG_GICC_IGRPEN1_EL1}
`define CA53_GICREG_GICH_HCR_SRE      {1'b0,`CA53_GICREG_GICC_SRE_EL1}
`define CA53_GICREG_GICH_HCR          6'b10_00_00
`define CA53_GICREG_GICH_VTR          6'b10_00_01
`define CA53_GICREG_GICH_VMCR         6'b10_00_10
`define CA53_GICREG_GICH_MISR         6'b10_01_00
`define CA53_GICREG_GICH_EISR         6'b10_01_01
`define CA53_GICREG_GICH_ELSR         6'b10_01_10
`define CA53_GICREG_GICH_LR0          6'b11_00_00 // ICH_LR0_EL2
`define CA53_GICREG_GICH_LR1          6'b11_01_00 // ICH_LR1_EL2
`define CA53_GICREG_GICH_LR2          6'b11_10_00 // ICH_LR2_EL2
`define CA53_GICREG_GICH_LR3          6'b11_11_00 // ICH_LR4_EL2
`define CA53_GICREG_GICH_LR0_L        6'b11_00_01 // ICH_LR0
`define CA53_GICREG_GICH_LR1_L        6'b11_01_01 // ICH_LR1
`define CA53_GICREG_GICH_LR2_L        6'b11_10_01 // ICH_LR2
`define CA53_GICREG_GICH_LR3_L        6'b11_11_01 // ICH_LR3
`define CA53_GICREG_GICH_LR0_H        6'b11_00_10 // ICH_LRC0
`define CA53_GICREG_GICH_LR1_H        6'b11_01_10 // ICH_LRC1
`define CA53_GICREG_GICH_LR2_H        6'b11_10_10 // ICH_LRC2
`define CA53_GICREG_GICH_LR3_H        6'b11_11_10 // ICH_LRC3

// GIC CPU Interface system register encodings
`define CA53_GICCP_W                  7
`define CA53_GICCP_GICC_IAR1_EL1      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_IAR1_EL1}
`define CA53_GICCP_GICC_IAR0_EL1      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_IAR0_EL1}
`define CA53_GICCP_GICC_EOIR1_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_EOIR1_EL1}
`define CA53_GICCP_GICC_EOIR0_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_EOIR0_EL1}
`define CA53_GICCP_GICC_HPPIR1_EL1    {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_HPPIR1_EL1}
`define CA53_GICCP_GICC_HPPIR0_EL1    {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_HPPIR0_EL1}
`define CA53_GICCP_GICC_BPR1_EL1      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_BPR1_EL1}
`define CA53_GICCP_GICC_BPR0_EL1      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_BPR0_EL1}
`define CA53_GICCP_GICC_DIR_EL1       {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_DIR_EL1}
`define CA53_GICCP_GICC_PMR_EL1       {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_PMR_EL1}
`define CA53_GICCP_GICC_RPR           {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_RPR}
`define CA53_GICCP_GICC_AP0R0_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_AP0R0_EL1}
`define CA53_GICCP_GICC_AP1R0_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_AP1R0_EL1}
`define CA53_GICCP_GICC_IGRPEN0_EL1   {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_IGRPEN0_EL1}
`define CA53_GICCP_GICC_IGRPEN1_EL1   {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_IGRPEN1_EL1}
`define CA53_GICCP_GICC_IGRPEN1_EL3   {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_IGRPEN1_EL3}
`define CA53_GICCP_GICC_SRE_EL1       {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_SRE_EL1}
`define CA53_GICCP_GICC_SRE_EL2       {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_SRE_EL2}
`define CA53_GICCP_GICC_SRE_EL3       {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_SRE_EL3}
`define CA53_GICCP_GICC_CTLR_EL1      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_CTLR_EL1}
`define CA53_GICCP_GICC_CTLR_EL3      {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_CTLR_EL3}
`define CA53_GICCP_GICC_SGI0R_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_SGI0R_EL1}
`define CA53_GICCP_GICC_SGI1R_EL1     {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_SGI1R_EL1}
`define CA53_GICCP_GICC_ASGI1R_EL1    {`CA53_GICREG_PCPU, 1'b0, `CA53_GICREG_GICC_ASGI1R_EL1}
`define CA53_GICCP_GICV_AIAR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_AIAR}
`define CA53_GICCP_GICV_IAR           {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_IAR}
`define CA53_GICCP_GICV_AEOIR         {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_AEOIR}
`define CA53_GICCP_GICV_EOIR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_EOIR}
`define CA53_GICCP_GICV_AHPPIR        {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_AHPPIR}
`define CA53_GICCP_GICV_HPPIR         {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_HPPIR}
`define CA53_GICCP_GICH_VMCR_BPR1     {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR_BPR1}
`define CA53_GICCP_GICH_VMCR_BPR0     {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR_BPR0}
`define CA53_GICCP_GICV_DIR           {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_DIR}
`define CA53_GICCP_GICH_VMCR_PMR      {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR_PMR}
`define CA53_GICCP_GICV_RPR           {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_RPR}
`define CA53_GICCP_GICH_APR0          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_APR0}
`define CA53_GICCP_GICH_APR1          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_APR1}
`define CA53_GICCP_GICH_VMCR_VENG0    {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR_VENG0}
`define CA53_GICCP_GICH_VMCR_VENG1    {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR_VENG1}
`define CA53_GICCP_GICH_HCR_SRE       {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_HCR_SRE}
`define CA53_GICCP_GICV_CTLR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICV_CTLR}
`define CA53_GICCP_GICH_HCR           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_HCR}
`define CA53_GICCP_GICH_VTR           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VTR}
`define CA53_GICCP_GICH_VMCR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_VMCR}
`define CA53_GICCP_GICH_MISR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_MISR}
`define CA53_GICCP_GICH_EISR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_EISR}
`define CA53_GICCP_GICH_ELSR          {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_ELSR}
`define CA53_GICCP_GICH_LR0           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR0}   // ICH_LR0_EL2
`define CA53_GICCP_GICH_LR0_L         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR0_L} // ICH_LR0
`define CA53_GICCP_GICH_LR0_H         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR0_H} // ICH_LRC0
`define CA53_GICCP_GICH_LR1           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR1}   // ICH_LR1_EL2
`define CA53_GICCP_GICH_LR1_L         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR1_L} // ICH_LR1
`define CA53_GICCP_GICH_LR1_H         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR1_H} // ICH_LRC1
`define CA53_GICCP_GICH_LR2           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR2}   // ICH_LR2_EL2
`define CA53_GICCP_GICH_LR2_L         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR2_L} // ICH_LR2
`define CA53_GICCP_GICH_LR2_H         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR2_H} // ICH_LRC2
`define CA53_GICCP_GICH_LR3           {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR3}   // ICH_LR3_EL2
`define CA53_GICCP_GICH_LR3_L         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR3_L} // ICH_LR3
`define CA53_GICCP_GICH_LR3_H         {`CA53_GICREG_VCPU, `CA53_GICREG_GICH_LR3_H} // ICH_LRC3


// ------------------------------------------------------
// DPU/DCU CP operation encodings
// ------------------------------------------------------

`define CA53_CPOP_W 9

// [8] 1 Gov    => [7:5] 100 => L2
//                       101 => Timers
//                       0xx => GIC
//     0 Others => [7:6] 00 => TLB reg/V2P
//                       01 => TLB Maintenance: [5]   AA64 (1'b1)/AA32(1'b0)
//                                              [4]   Operation
//                                              [3]   Operation (1'b1 for -IS)
//                                              [2:0] Operation
//                       11 => [5:4] 1x => Barrier: [4]   Operation DMBLD(1'b0)/Other(1'b1)
//                                                  [3]   Operation DMB(1'b1)/DSB(1'b0)
//                                                  [2]   Operation DMBST(1'b0)/Other(1'b1)
//                                                  [1:0] Operation
//                                   01 => D$ maintenance: [3] Operation PoC (1'b1)/PoU (1'b0)
//                                                         [2] Operation Invalidate
//                                                         [1] Operation Clean
//                                                         [0] Operation MVA(1'b1)/SW(1'b0)
//                                   00 => [3:2] x1 => I$ maintenance: [3,1] Operation
//                                                                     [0]   Operation (1'b1 for MVA)
//                                               10 => BP maintenance
//                                               00 => [1:0] 00 => CLREX
//                                                           01 => <Unused>
//                                                           10 => DVM Sync
//                                                           11 => NOP

// CP op decoding using full 9-bit cp op
`define CA53_CPOP_IS_GOV(cpop_type)       (cpop_type[8])
`define CA53_CPOP_IS_GIC(cpop_type)       (cpop_type[8:7] == 2'b10)
`define CA53_CPOP_IS_V2P(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & (cpop_type[6:2] == 5'b00010))
`define CA53_CPOP_IS_TLBM(cpop_type)      (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_TLBM(cpop_type))
`define CA53_CPOP_IS_DCM(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_DCM(cpop_type))
`define CA53_CPOP_IS_ICM(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_ICM(cpop_type))
`define CA53_CPOP_IS_BPM(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_BPM(cpop_type))
`define CA53_CPOP_IS_BAR(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_BAR(cpop_type))
`define CA53_CPOP_IS_DSB(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_DSB(cpop_type))
`define CA53_CPOP_IS_DMB(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_DMB(cpop_type))
`define CA53_CPOP_IS_DMBLD(cpop_type)     (`CA53_CPOP_IS_BAR(cpop_type) & ~cpop_type[4])
`define CA53_CPOP_IS_DCM_MVA(cpop_type)   (`CA53_CPOP_IS_DCM(cpop_type) & cpop_type[0])
`define CA53_CPOP_IS_DCM_SW(cpop_type)    (`CA53_CPOP_IS_DCM(cpop_type) & ~cpop_type[0])
`define CA53_CPOP_IS_ICM_MVA(cpop_type)   (~`CA53_CPOP_IS_GOV(cpop_type) & `CA53_CPOP_8_IS_ICM_MVA(cpop_type))
`define CA53_CPOP_IS_CLREX(cpop_type)     (~`CA53_CPOP_IS_GOV(cpop_type) & cpop_type[7] & (cpop_type[5:1] == 5'b00000))
`define CA53_CPOP_IS_CLREX_NOP(cpop_type) (~`CA53_CPOP_IS_GOV(cpop_type) & cpop_type[7] & (cpop_type[5:2] == 4'b0000))
`define CA53_CPOP_IS_CDBG(cpop_type)      (~`CA53_CPOP_IS_GOV(cpop_type) & (cpop_type[6:4] == 3'b000) & (cpop_type[3:2] != 2'b10))
`define CA53_CPOP_IS_CDBG_DC(cpop_type)   (`CA53_CPOP_IS_CDBG(cpop_type) & cpop_type[2:1] == 2'b00)
`define CA53_CPOP_IS_CDBG_IC(cpop_type)   (`CA53_CPOP_IS_CDBG(cpop_type) & cpop_type[2:1] == 2'b01)
`define CA53_CPOP_IS_CDBG_TLB(cpop_type)  (`CA53_CPOP_IS_CDBG(cpop_type) & cpop_type[3:2] == 2'b11)
`define CA53_CPOP_IS_REG(cpop_type)       (~`CA53_CPOP_IS_GOV(cpop_type) & ~cpop_type[6] & ((cpop_type[5:4] != 2'b00) | (cpop_type[5:2] == 4'b0001)))

// CP op decoding using fewer cp op bits
`define CA53_CPOP_8_IS_TLBM(cpop_type)            (cpop_type[7:6] == 2'b01)
`define CA53_CPOP_8_IS_DCM(cpop_type)             (cpop_type[7] & (cpop_type[5:4] == 2'b01))
`define CA53_CPOP_8_IS_ICM(cpop_type)             (cpop_type[7] & (cpop_type[5:4] == 2'b00) & cpop_type[2])
`define CA53_CPOP_8_IS_BPM(cpop_type)             (cpop_type[7] & (cpop_type[5:4] == 2'b00) & (cpop_type[3:2] == 2'b10))
`define CA53_CPOP_8_IS_BAR(cpop_type)             (cpop_type[7] & cpop_type[5])
`define CA53_CPOP_8_IS_DSB(cpop_type)             (`CA53_CPOP_8_IS_BAR(cpop_type) & ~cpop_type[3])
`define CA53_CPOP_8_IS_DMB(cpop_type)             (`CA53_CPOP_8_IS_BAR(cpop_type) & cpop_type[3])
`define CA53_CPOP_8_IS_DMBST(cpop_type)           (`CA53_CPOP_8_IS_BAR(cpop_type) & ~cpop_type[2])
`define CA53_CPOP_8_IS_DCM_SW(cpop_type)          (`CA53_CPOP_8_IS_DCM(cpop_type) & ~cpop_type[0])
`define CA53_CPOP_8_IS_ICM_MVA(cpop_type)         (`CA53_CPOP_8_IS_ICM(cpop_type) & cpop_type[0])
`define CA53_CPOP_8_TLBM_IS_AA64(cpop_type_tlb)   (cpop_type_tlb[5])
`define CA53_CPOP_8_TLBM_AS_AA64(cpop_type_tlb)   ({cpop_type_tlb[7:6], 1'b1, cpop_type_tlb[4:0]})
`define CA53_CPOP_5_TLBM_AS_NON_IS(cpop_type_tlb) ({cpop_type_tlb[4], 1'b0, cpop_type_tlb[2:0]})

                                                                          //    CRn op1 CRm op2
`define CA53_CPOP_CDBGDCT           9'b000000000                          // p15 15  3   2   0   Cache Debug Data Cache Tag Read
`define CA53_CPOP_CDBGDCD           9'b000000001                          // p15 15  3   4   0   Cache Debug Data Cache Data Read
`define CA53_CPOP_CDBGICT           9'b000000010                          // p15 15  3   2   1   Cache Debug Instruction Tag Read
`define CA53_CPOP_CDBGICD           9'b000000011                          // p15 15  3   4   1   Cache Debug Instruction Cache Data Read
`define CA53_CPOP_CDBGTD            9'b000001100                          // p15 15  3   4   2   Cache Debug TLB Data Read
`define CA53_CPOP_CDBGDR0           {3'b000, `CA53_CP15_REG_CDBGDR0}      // p15 15  3   0   0   Cache Debug Data Reg 0
`define CA53_CPOP_CDBGDR1           {3'b000, `CA53_CP15_REG_CDBGDR1}      // p15 15  3   0   1   Cache Debug Data Reg 1
`define CA53_CPOP_CDBGDR2           {3'b000, `CA53_CP15_REG_CDBGDR2}      // p15 15  3   0   2   Cache Debug Data Reg 2
`define CA53_CPOP_CDBGDR3           {3'b000, `CA53_CP15_REG_CDBGDR3}      // p15 15  3   0   3   Cache Debug Data Reg 3
`define CA53_CPOP_TTBR0             {3'b000, `CA53_CP15_REG_TTBR0}        // p15 2   0   0   0   TTBR0
`define CA53_CPOP_TTBR0_EL1         {3'b000, `CA53_CP15_REG_TTBR0_EL1}    // duplicate new definition for AArch64
`define CA53_CPOP_TTBR1             {3'b000, `CA53_CP15_REG_TTBR1}        // p15 2   0   0   1   TTBR1
`define CA53_CPOP_TTBR1_EL1         {3'b000, `CA53_CP15_REG_TTBR1_EL1}    // duplicate new definition for AArch64
`define CA53_CPOP_TTBCR             {3'b000, `CA53_CP15_REG_TTBCR}        // p15 2   0   0   2   TTBCR
`define CA53_CPOP_TCR_EL1           {3'b000, `CA53_CP15_REG_TCR_EL1}      // duplicate new definition for AArch64
`define CA53_CPOP_HTTBR             {3'b000, `CA53_CP15_REG_HTTBR}        // p15 -   4   2   -   HTTBR
`define CA53_CPOP_TTBR0_EL2         {3'b000, `CA53_CP15_REG_TTBR0_EL2}    // duplicate new definition for AArch64
`define CA53_CPOP_VTTBR             {3'b000, `CA53_CP15_REG_VTTBR}        // p15 -   6   2   -   VTTBR
`define CA53_CPOP_VTTBR_EL2         {3'b000, `CA53_CP15_REG_VTTBR_EL2}   // duplicate new definition for AArch64
`define CA53_CPOP_HTCR              {3'b000, `CA53_CP15_REG_HTCR}         // p15 2   4   0   2   HTCR
`define CA53_CPOP_TCR_EL2           {3'b000, `CA53_CP15_REG_TCR_EL2}      // duplicate new definition for AArch64
`define CA53_CPOP_VTCR              {3'b000, `CA53_CP15_REG_VTCR}         // p15 2   4   1   2   VTCR
`define CA53_CPOP_VTCR_EL2          {3'b000, `CA53_CP15_REG_VTCR_EL2}     // duplicate new definition for AArch64
`define CA53_CPOP_PAR               {3'b000, `CA53_CP15_REG_PAR}          // p15 7   0   4   0   PAR
`define CA53_CPOP_PAR_EL1           {3'b000, `CA53_CP15_REG_PAR_EL1}      // duplicate new definition for AArch64
`define CA53_CPOP_MAIR0             {3'b000, `CA53_CP15_REG_MAIR0}        // p15 10  0   2   0   MAIR0 (formerly PRRR)
`define CA53_CPOP_MAIR_EL1          {3'b000, `CA53_CP15_REG_MAIR_EL1}     // duplicate new definition for AArch64
`define CA53_CPOP_MAIR1             {3'b000, `CA53_CP15_REG_MAIR1}        // p15 10  0   2   1   MAIR1 (formerly NMRR)
`define CA53_CPOP_HMAIR0            {3'b000, `CA53_CP15_REG_HMAIR0}       // p15 10  4   2   0   HMAIR0
`define CA53_CPOP_MAIR_EL2          {3'b000, `CA53_CP15_REG_MAIR_EL2}     // duplicate new definition for AArch64
`define CA53_CPOP_HMAIR1            {3'b000, `CA53_CP15_REG_HMAIR1}       // p15 10  4   2   1   HMAIR1
`define CA53_CPOP_CONTEXTIDR        {3'b000, `CA53_CP15_REG_CTXTID}       // p15 13  0   0   1   CONTEXTIDR
`define CA53_CPOP_CONTEXTIDR_EL1    {3'b000, `CA53_CP15_REG_CTXTID_EL1}   // duplicate new definition for AArch64
`define CA53_CPOP_TTBR0_EL3         {3'b000, `CA53_CP15_REG_TTBR0_EL3}    // new address
`define CA53_CPOP_TCR_EL3           {3'b000, `CA53_CP15_REG_TCR_EL3}      // new address
`define CA53_CPOP_MAIR_EL3          {3'b000, `CA53_CP15_REG_MAIR_EL3}     // new address
`define CA53_CPOP_DBGBVR0           {3'b000, `CA53_CP15_REG_DBGBVR0}      // p14 0   0   0   4   DBGBVR0
`define CA53_CPOP_DBGBVR1           {3'b000, `CA53_CP15_REG_DBGBVR1}      // p14 0   0   1   4   DBGBVR1
`define CA53_CPOP_DBGBVR2           {3'b000, `CA53_CP15_REG_DBGBVR2}      // p14 0   0   2   4   DBGBVR2
`define CA53_CPOP_DBGBVR3           {3'b000, `CA53_CP15_REG_DBGBVR3}      // p14 0   0   3   4   DBGBVR3
`define CA53_CPOP_DBGBVR4           {3'b000, `CA53_CP15_REG_DBGBVR4}      // p14 0   0   4   4   DBGBVR4
`define CA53_CPOP_DBGBVR5           {3'b000, `CA53_CP15_REG_DBGBVR5}      // p14 0   0   5   4   DBGBVR5
`define CA53_CPOP_DBGBCR0           {3'b000, `CA53_CP15_REG_DBGBCR0}      // p14 0   0   0   5   DBGBCR0
`define CA53_CPOP_DBGBCR1           {3'b000, `CA53_CP15_REG_DBGBCR1}      // p14 0   0   1   5   DBGBCR1
`define CA53_CPOP_DBGBCR2           {3'b000, `CA53_CP15_REG_DBGBCR2}      // p14 0   0   2   5   DBGBCR2
`define CA53_CPOP_DBGBCR3           {3'b000, `CA53_CP15_REG_DBGBCR3}      // p14 0   0   3   5   DBGBCR3
`define CA53_CPOP_DBGBCR4           {3'b000, `CA53_CP15_REG_DBGBCR4}      // p14 0   0   4   5   DBGBCR4
`define CA53_CPOP_DBGBCR5           {3'b000, `CA53_CP15_REG_DBGBCR5}      // p14 0   0   5   5   DBGBCR5
`define CA53_CPOP_DBGBXVR4          {3'b000, `CA53_CP15_REG_DBGBXVR4}     // p14 1   0   4   1   DBGBXVR4
`define CA53_CPOP_DBGBXVR5          {3'b000, `CA53_CP15_REG_DBGBXVR5}     // p14 1   0   5   1   DBGBXVR5
`define CA53_CPOP_DBGWVR0           {3'b000, `CA53_CP15_REG_DBGWVR0}      // p14 0   0   0   6   DBGWVR0
`define CA53_CPOP_DBGWVR1           {3'b000, `CA53_CP15_REG_DBGWVR1}      // p14 0   0   1   6   DBGWVR1
`define CA53_CPOP_DBGWVR2           {3'b000, `CA53_CP15_REG_DBGWVR2}      // p14 0   0   2   6   DBGWVR2
`define CA53_CPOP_DBGWVR3           {3'b000, `CA53_CP15_REG_DBGWVR3}      // p14 0   0   3   6   DBGWVR3
`define CA53_CPOP_DBGWCR0           {3'b000, `CA53_CP15_REG_DBGWCR0}      // p14 0   0   0   7   DBGWCR0
`define CA53_CPOP_DBGWCR1           {3'b000, `CA53_CP15_REG_DBGWCR1}      // p14 0   0   1   7   DBGWCR1
`define CA53_CPOP_DBGWCR2           {3'b000, `CA53_CP15_REG_DBGWCR2}      // p14 0   0   2   7   DBGWCR2
`define CA53_CPOP_DBGWCR3           {3'b000, `CA53_CP15_REG_DBGWCR3}      // p14 0   0   3   7   DBGWCR3
`define CA53_CPOP_DBGVCR            {3'b000, `CA53_CP15_REG_DBGVCR}       // p14 0   0   0   4   DBGVCR

`define CA53_CPOP_ATS1C             9'b000001000  // p15 7   0   8   0-3 ATS1C* (formerly V2PC*)
`define CA53_CPOP_ATS12NSO          9'b000001001  // p15 7   0   8   4-7 ATS1NSO* (formerly V2PO*)
`define CA53_CPOP_ATS1H             9'b000001010  // p15 7   4   8   0-1 ATS1H
`define CA53_CPOP_ATS1E01           9'b000001000
`define CA53_CPOP_ATS12E01          9'b000001001
`define CA53_CPOP_ATS1E2            9'b000001010
`define CA53_CPOP_ATS1E3            9'b000001011

// AA32 TLB Ops

// 5-bit encodings (operation only including -IS bit)
`define CA53_CPOP_5_W                 5
`define CA53_CPOP_5_TLBIALL           5'b00000  // p15 8   0   5-7 0   *TLBIALL
`define CA53_CPOP_5_TLBIALLIS         5'b01000  // p15 8   0   3   0   TLBIALLIS
`define CA53_CPOP_5_TLBIMVA           5'b00001  // p15 8   0   5-7 1   *TLBIMVA
`define CA53_CPOP_5_TLBIMVAIS         5'b01001  // p15 8   0   3   1   TLBIMVAIS
`define CA53_CPOP_5_TLBIASID          5'b00010  // p15 8   0   5-7 2   *TLBIASID
`define CA53_CPOP_5_TLBIASIDIS        5'b01010  // p15 8   0   3   2   TLBIASIDIS
`define CA53_CPOP_5_TLBIMVAA          5'b00011  // p15 8   0   7   3   TLBIMVAA
`define CA53_CPOP_5_TLBIMVAAIS        5'b01011  // p15 8   0   3   3   TLBIMVAAIS
`define CA53_CPOP_5_TLBIMVAH          5'b00100  // p15 8   4   7   1   TLBIMVAH
`define CA53_CPOP_5_TLBIMVAHIS        5'b01100  // p15 8   4   3   1   TLBIMVAHIS
`define CA53_CPOP_5_TLBIALLH          5'b00101  // p15 8   4   7   0   TLBIALLH
`define CA53_CPOP_5_TLBIALLHIS        5'b01101  // p15 8   4   3   0   TLBIALLHIS
`define CA53_CPOP_5_TLBIALLNSNH       5'b00110  // p15 8   4   7   4   TLBIALLNSNH
`define CA53_CPOP_5_TLBIALLNSNHIS     5'b01110  // p15 8   4   3   4   TLBIALLNSNHIS
`define CA53_CPOP_5_TLBIMVAL          5'b00111  // p15 8   0   7   5   TLBIMVAL
`define CA53_CPOP_5_TLBIMVALIS        5'b01111  // p15 8   0   3   5   TLBIMVALIS
`define CA53_CPOP_5_TLBIMVAAL         5'b10000  // p15 8   0   7   7   TLBIMVAAL
`define CA53_CPOP_5_TLBIMVAALIS       5'b11000  // p15 8   0   3   7   TLBIMVAALIS
`define CA53_CPOP_5_TLBIMVALH         5'b10001  // p15 8   4   7   5   TLBIMVALH
`define CA53_CPOP_5_TLBIMVALHIS       5'b11001  // p15 8   4   3   5   TLBIMVALHIS
`define CA53_CPOP_5_TLBIIPAS2         5'b10010  // p15 8   4   4   1   TLBIIPAS2
`define CA53_CPOP_5_TLBIIPAS2IS       5'b11010  // p15 8   4   0   1   TLBIIPAS2IS
`define CA53_CPOP_5_TLBIIPAS2L        5'b10011  // p15 8   4   4   5   TLBIIPAS2L
`define CA53_CPOP_5_TLBIIPAS2LIS      5'b11011  // p15 8   4   0   5   TLBIIPAS2LIS

// 8-bit encodings (TLB and AA32 specifiers included)
`define CA53_CPOP_8_W                 8
`define CA53_CPOP_8_TLBIALL           {3'b010, `CA53_CPOP_5_TLBIALL}
`define CA53_CPOP_8_TLBIALLIS         {3'b010, `CA53_CPOP_5_TLBIALLIS}
`define CA53_CPOP_8_TLBIMVA           {3'b010, `CA53_CPOP_5_TLBIMVA}
`define CA53_CPOP_8_TLBIMVAIS         {3'b010, `CA53_CPOP_5_TLBIMVAIS}
`define CA53_CPOP_8_TLBIASID          {3'b010, `CA53_CPOP_5_TLBIASID}
`define CA53_CPOP_8_TLBIASIDIS        {3'b010, `CA53_CPOP_5_TLBIASIDIS}
`define CA53_CPOP_8_TLBIMVAA          {3'b010, `CA53_CPOP_5_TLBIMVAA}
`define CA53_CPOP_8_TLBIMVAAIS        {3'b010, `CA53_CPOP_5_TLBIMVAAIS}
`define CA53_CPOP_8_TLBIMVAH          {3'b010, `CA53_CPOP_5_TLBIMVAH}
`define CA53_CPOP_8_TLBIMVAHIS        {3'b010, `CA53_CPOP_5_TLBIMVAHIS}
`define CA53_CPOP_8_TLBIALLH          {3'b010, `CA53_CPOP_5_TLBIALLH}
`define CA53_CPOP_8_TLBIALLHIS        {3'b010, `CA53_CPOP_5_TLBIALLHIS}
`define CA53_CPOP_8_TLBIALLNSNH       {3'b010, `CA53_CPOP_5_TLBIALLNSNH}
`define CA53_CPOP_8_TLBIALLNSNHIS     {3'b010, `CA53_CPOP_5_TLBIALLNSNHIS}
`define CA53_CPOP_8_TLBIMVAL          {3'b010, `CA53_CPOP_5_TLBIMVAL}
`define CA53_CPOP_8_TLBIMVALIS        {3'b010, `CA53_CPOP_5_TLBIMVALIS}
`define CA53_CPOP_8_TLBIMVAAL         {3'b010, `CA53_CPOP_5_TLBIMVAAL}
`define CA53_CPOP_8_TLBIMVAALIS       {3'b010, `CA53_CPOP_5_TLBIMVAALIS}
`define CA53_CPOP_8_TLBIMVALH         {3'b010, `CA53_CPOP_5_TLBIMVALH}
`define CA53_CPOP_8_TLBIMVALHIS       {3'b010, `CA53_CPOP_5_TLBIMVALHIS}
`define CA53_CPOP_8_TLBIIPAS2         {3'b010, `CA53_CPOP_5_TLBIIPAS2}
`define CA53_CPOP_8_TLBIIPAS2IS       {3'b010, `CA53_CPOP_5_TLBIIPAS2IS}
`define CA53_CPOP_8_TLBIIPAS2L        {3'b010, `CA53_CPOP_5_TLBIIPAS2L}
`define CA53_CPOP_8_TLBIIPAS2LIS      {3'b010, `CA53_CPOP_5_TLBIIPAS2LIS}

// 9-bit encodings (non-Gov specifier included)
`define CA53_CPOP_TLBIALL           {1'b0, `CA53_CPOP_8_TLBIALL}
`define CA53_CPOP_TLBIALLIS         {1'b0, `CA53_CPOP_8_TLBIALLIS}
`define CA53_CPOP_TLBIMVA           {1'b0, `CA53_CPOP_8_TLBIMVA}
`define CA53_CPOP_TLBIMVAIS         {1'b0, `CA53_CPOP_8_TLBIMVAIS}
`define CA53_CPOP_TLBIASID          {1'b0, `CA53_CPOP_8_TLBIASID}
`define CA53_CPOP_TLBIASIDIS        {1'b0, `CA53_CPOP_8_TLBIASIDIS}
`define CA53_CPOP_TLBIMVAA          {1'b0, `CA53_CPOP_8_TLBIMVAA}
`define CA53_CPOP_TLBIMVAAIS        {1'b0, `CA53_CPOP_8_TLBIMVAAIS}
`define CA53_CPOP_TLBIMVAH          {1'b0, `CA53_CPOP_8_TLBIMVAH}
`define CA53_CPOP_TLBIMVAHIS        {1'b0, `CA53_CPOP_8_TLBIMVAHIS}
`define CA53_CPOP_TLBIALLH          {1'b0, `CA53_CPOP_8_TLBIALLH}
`define CA53_CPOP_TLBIALLHIS        {1'b0, `CA53_CPOP_8_TLBIALLHIS}
`define CA53_CPOP_TLBIALLNSNH       {1'b0, `CA53_CPOP_8_TLBIALLNSNH}
`define CA53_CPOP_TLBIALLNSNHIS     {1'b0, `CA53_CPOP_8_TLBIALLNSNHIS}
`define CA53_CPOP_TLBIMVAL          {1'b0, `CA53_CPOP_8_TLBIMVAL}
`define CA53_CPOP_TLBIMVALIS        {1'b0, `CA53_CPOP_8_TLBIMVALIS}
`define CA53_CPOP_TLBIMVAAL         {1'b0, `CA53_CPOP_8_TLBIMVAAL}
`define CA53_CPOP_TLBIMVAALIS       {1'b0, `CA53_CPOP_8_TLBIMVAALIS}
`define CA53_CPOP_TLBIMVALH         {1'b0, `CA53_CPOP_8_TLBIMVALH}
`define CA53_CPOP_TLBIMVALHIS       {1'b0, `CA53_CPOP_8_TLBIMVALHIS}
`define CA53_CPOP_TLBIIPAS2         {1'b0, `CA53_CPOP_8_TLBIIPAS2}
`define CA53_CPOP_TLBIIPAS2IS       {1'b0, `CA53_CPOP_8_TLBIIPAS2IS}
`define CA53_CPOP_TLBIIPAS2L        {1'b0, `CA53_CPOP_8_TLBIIPAS2L}
`define CA53_CPOP_TLBIIPAS2LIS      {1'b0, `CA53_CPOP_8_TLBIIPAS2LIS}

// AA64 TLB Ops

// 5-bit encodings (operation only including -IS bit)
// AA32 encodings re-used where a direct mapping exists           // AA32 Equivalent:
`define CA53_CPOP_5_TLBIVAE1          `CA53_CPOP_5_TLBIMVA        // TLBIMVA
`define CA53_CPOP_5_TLBIVAE1IS        `CA53_CPOP_5_TLBIMVAIS      // TLBIMVAIS
`define CA53_CPOP_5_TLBIVALE1         `CA53_CPOP_5_TLBIMVAL       // TLBIMVAL
`define CA53_CPOP_5_TLBIVALE1IS       `CA53_CPOP_5_TLBIMVALIS     // TLBIMVALIS
`define CA53_CPOP_5_TLBIVAAE1         `CA53_CPOP_5_TLBIMVAA       // TLBIMVAA
`define CA53_CPOP_5_TLBIVAAE1IS       `CA53_CPOP_5_TLBIMVAAIS     // TLBIMVAAIS
`define CA53_CPOP_5_TLBIVAALE1        `CA53_CPOP_5_TLBIMVAAL      // TLBIMVAAL
`define CA53_CPOP_5_TLBIVAALE1IS      `CA53_CPOP_5_TLBIMVAALIS    // TLBIMVAALIS
`define CA53_CPOP_5_TLBIIPAS2E1       `CA53_CPOP_5_TLBIIPAS2      // TLBIIPAS2
`define CA53_CPOP_5_TLBIIPAS2E1IS     `CA53_CPOP_5_TLBIIPAS2IS    // TLBIIPAS2IS
`define CA53_CPOP_5_TLBIIPAS2LE1      `CA53_CPOP_5_TLBIIPAS2L     // TLBIIPAS2L
`define CA53_CPOP_5_TLBIIPAS2LE1IS    `CA53_CPOP_5_TLBIIPAS2LIS   // TLBIIPAS2LIS
`define CA53_CPOP_5_TLBIVAE2          `CA53_CPOP_5_TLBIMVAH       // TLBIMVAH
`define CA53_CPOP_5_TLBIVAE2IS        `CA53_CPOP_5_TLBIMVAHIS     // TLBIMVAHIS
`define CA53_CPOP_5_TLBIVALE2         `CA53_CPOP_5_TLBIMVALH      // TLBIMVALH
`define CA53_CPOP_5_TLBIVALE2IS       `CA53_CPOP_5_TLBIMVALHIS    // TLBIMVALHIS
`define CA53_CPOP_5_TLBIVAE3          5'b10100
`define CA53_CPOP_5_TLBIVAE3IS        5'b11100
`define CA53_CPOP_5_TLBIVALE3         5'b10101
`define CA53_CPOP_5_TLBIVALE3IS       5'b11101
`define CA53_CPOP_5_TLBIASIDE1        `CA53_CPOP_5_TLBIASID       // TLBIASID
`define CA53_CPOP_5_TLBIASIDE1IS      `CA53_CPOP_5_TLBIASIDIS     // TLBIASIDIS
`define CA53_CPOP_5_TLBIVMALLE1       `CA53_CPOP_5_TLBIALL        // TLBIALL
`define CA53_CPOP_5_TLBIVMALLE1IS     `CA53_CPOP_5_TLBIALLIS      // TLBIALLIS
`define CA53_CPOP_5_TLBIVMALLS12E1    5'b10110
`define CA53_CPOP_5_TLBIVMALLS12E1IS  5'b11110
`define CA53_CPOP_5_TLBIALLE1         `CA53_CPOP_5_TLBIALLNSNH    // TLBIALLNSNH
`define CA53_CPOP_5_TLBIALLE1IS       `CA53_CPOP_5_TLBIALLNSNHIS  // TLBIALLNSNHIS
`define CA53_CPOP_5_TLBIALLE2         `CA53_CPOP_5_TLBIALLH       // TLBIALLH
`define CA53_CPOP_5_TLBIALLE2IS       `CA53_CPOP_5_TLBIALLHIS     // TLBIALLHIS
`define CA53_CPOP_5_TLBIALLE3         5'b10111
`define CA53_CPOP_5_TLBIALLE3IS       5'b11111

// 8-bit encodings (TLB and AA64 specifiers included)
`define CA53_CPOP_8_TLBIVAE1          {3'b011, `CA53_CPOP_5_TLBIVAE1}
`define CA53_CPOP_8_TLBIVAE1IS        {3'b011, `CA53_CPOP_5_TLBIVAE1IS}
`define CA53_CPOP_8_TLBIVALE1         {3'b011, `CA53_CPOP_5_TLBIVALE1}
`define CA53_CPOP_8_TLBIVALE1IS       {3'b011, `CA53_CPOP_5_TLBIVALE1IS}
`define CA53_CPOP_8_TLBIVAAE1         {3'b011, `CA53_CPOP_5_TLBIVAAE1}
`define CA53_CPOP_8_TLBIVAAE1IS       {3'b011, `CA53_CPOP_5_TLBIVAAE1IS}
`define CA53_CPOP_8_TLBIVAALE1        {3'b011, `CA53_CPOP_5_TLBIVAALE1}
`define CA53_CPOP_8_TLBIVAALE1IS      {3'b011, `CA53_CPOP_5_TLBIVAALE1IS}
`define CA53_CPOP_8_TLBIIPAS2E1       {3'b011, `CA53_CPOP_5_TLBIIPAS2E1}
`define CA53_CPOP_8_TLBIIPAS2E1IS     {3'b011, `CA53_CPOP_5_TLBIIPAS2E1IS}
`define CA53_CPOP_8_TLBIIPAS2LE1      {3'b011, `CA53_CPOP_5_TLBIIPAS2LE1}
`define CA53_CPOP_8_TLBIIPAS2LE1IS    {3'b011, `CA53_CPOP_5_TLBIIPAS2LE1IS}
`define CA53_CPOP_8_TLBIVAE2          {3'b011, `CA53_CPOP_5_TLBIVAE2}
`define CA53_CPOP_8_TLBIVAE2IS        {3'b011, `CA53_CPOP_5_TLBIVAE2IS}
`define CA53_CPOP_8_TLBIVALE2         {3'b011, `CA53_CPOP_5_TLBIVALE2}
`define CA53_CPOP_8_TLBIVALE2IS       {3'b011, `CA53_CPOP_5_TLBIVALE2IS}
`define CA53_CPOP_8_TLBIVAE3          {3'b011, `CA53_CPOP_5_TLBIVAE3}
`define CA53_CPOP_8_TLBIVAE3IS        {3'b011, `CA53_CPOP_5_TLBIVAE3IS}
`define CA53_CPOP_8_TLBIVALE3         {3'b011, `CA53_CPOP_5_TLBIVALE3}
`define CA53_CPOP_8_TLBIVALE3IS       {3'b011, `CA53_CPOP_5_TLBIVALE3IS}
`define CA53_CPOP_8_TLBIASIDE1        {3'b011, `CA53_CPOP_5_TLBIASIDE1}
`define CA53_CPOP_8_TLBIASIDE1IS      {3'b011, `CA53_CPOP_5_TLBIASIDE1IS}
`define CA53_CPOP_8_TLBIVMALLE1       {3'b011, `CA53_CPOP_5_TLBIVMALLE1}
`define CA53_CPOP_8_TLBIVMALLE1IS     {3'b011, `CA53_CPOP_5_TLBIVMALLE1IS}
`define CA53_CPOP_8_TLBIVMALLS12E1    {3'b011, `CA53_CPOP_5_TLBIVMALLS12E1}
`define CA53_CPOP_8_TLBIVMALLS12E1IS  {3'b011, `CA53_CPOP_5_TLBIVMALLS12E1IS}
`define CA53_CPOP_8_TLBIALLE1         {3'b011, `CA53_CPOP_5_TLBIALLE1}
`define CA53_CPOP_8_TLBIALLE1IS       {3'b011, `CA53_CPOP_5_TLBIALLE1IS}
`define CA53_CPOP_8_TLBIALLE2         {3'b011, `CA53_CPOP_5_TLBIALLE2}
`define CA53_CPOP_8_TLBIALLE2IS       {3'b011, `CA53_CPOP_5_TLBIALLE2IS}
`define CA53_CPOP_8_TLBIALLE3         {3'b011, `CA53_CPOP_5_TLBIALLE3}
`define CA53_CPOP_8_TLBIALLE3IS       {3'b011, `CA53_CPOP_5_TLBIALLE3IS}

// 9-bit encodings (non-Gov specifier included)
`define CA53_CPOP_TLBIVAE1          {1'b0, `CA53_CPOP_8_TLBIVAE1}
`define CA53_CPOP_TLBIVAE1IS        {1'b0, `CA53_CPOP_8_TLBIVAE1IS}
`define CA53_CPOP_TLBIVALE1         {1'b0, `CA53_CPOP_8_TLBIVALE1}
`define CA53_CPOP_TLBIVALE1IS       {1'b0, `CA53_CPOP_8_TLBIVALE1IS}
`define CA53_CPOP_TLBIVAAE1         {1'b0, `CA53_CPOP_8_TLBIVAAE1}
`define CA53_CPOP_TLBIVAAE1IS       {1'b0, `CA53_CPOP_8_TLBIVAAE1IS}
`define CA53_CPOP_TLBIVAALE1        {1'b0, `CA53_CPOP_8_TLBIVAALE1}
`define CA53_CPOP_TLBIVAALE1IS      {1'b0, `CA53_CPOP_8_TLBIVAALE1IS}
`define CA53_CPOP_TLBIIPAS2E1       {1'b0, `CA53_CPOP_8_TLBIIPAS2E1}
`define CA53_CPOP_TLBIIPAS2E1IS     {1'b0, `CA53_CPOP_8_TLBIIPAS2E1IS}
`define CA53_CPOP_TLBIIPAS2LE1      {1'b0, `CA53_CPOP_8_TLBIIPAS2LE1}
`define CA53_CPOP_TLBIIPAS2LE1IS    {1'b0, `CA53_CPOP_8_TLBIIPAS2LE1IS}
`define CA53_CPOP_TLBIVAE2          {1'b0, `CA53_CPOP_8_TLBIVAE2}
`define CA53_CPOP_TLBIVAE2IS        {1'b0, `CA53_CPOP_8_TLBIVAE2IS}
`define CA53_CPOP_TLBIVALE2         {1'b0, `CA53_CPOP_8_TLBIVALE2}
`define CA53_CPOP_TLBIVALE2IS       {1'b0, `CA53_CPOP_8_TLBIVALE2IS}
`define CA53_CPOP_TLBIVAE3          {1'b0, `CA53_CPOP_8_TLBIVAE3}
`define CA53_CPOP_TLBIVAE3IS        {1'b0, `CA53_CPOP_8_TLBIVAE3IS}
`define CA53_CPOP_TLBIVALE3         {1'b0, `CA53_CPOP_8_TLBIVALE3}
`define CA53_CPOP_TLBIVALE3IS       {1'b0, `CA53_CPOP_8_TLBIVALE3IS}
`define CA53_CPOP_TLBIASIDE1        {1'b0, `CA53_CPOP_8_TLBIASIDE1}
`define CA53_CPOP_TLBIASIDE1IS      {1'b0, `CA53_CPOP_8_TLBIASIDE1IS}
`define CA53_CPOP_TLBIVMALLE1       {1'b0, `CA53_CPOP_8_TLBIVMALLE1}
`define CA53_CPOP_TLBIVMALLE1IS     {1'b0, `CA53_CPOP_8_TLBIVMALLE1IS}
`define CA53_CPOP_TLBIVMALLS12E1    {1'b0, `CA53_CPOP_8_TLBIVMALLS12E1}
`define CA53_CPOP_TLBIVMALLS12E1IS  {1'b0, `CA53_CPOP_8_TLBIVMALLS12E1IS}
`define CA53_CPOP_TLBIALLE1         {1'b0, `CA53_CPOP_8_TLBIALLE1}
`define CA53_CPOP_TLBIALLE1IS       {1'b0, `CA53_CPOP_8_TLBIALLE1IS}
`define CA53_CPOP_TLBIALLE2         {1'b0, `CA53_CPOP_8_TLBIALLE2}
`define CA53_CPOP_TLBIALLE2IS       {1'b0, `CA53_CPOP_8_TLBIALLE2IS}
`define CA53_CPOP_TLBIALLE3         {1'b0, `CA53_CPOP_8_TLBIALLE3}
`define CA53_CPOP_TLBIALLE3IS       {1'b0, `CA53_CPOP_8_TLBIALLE3IS}

// 9-bit CLREX/NOP encodings
`define CA53_CPOP_CLREX             9'b011000000  // CLREX
`define CA53_CPOP_NOP               9'b011000011  // Never issued by DPU, but used internally by DCU to convert
                                                  // DCCMVAU to NOP when BROADCASTINNER not set

// 8-bit I$, BP, D$, and barrier encodings
`define CA53_CPOP_8_ICIALLUIS       8'b11001100  // p15 7   0   1   0   ICIALLUIS
`define CA53_CPOP_8_ICIALLU         8'b11000100  // p15 7   0   5   0   ICIALLU
`define CA53_CPOP_8_ICIMVAU         8'b11001111  // p15 7   0   5   1   ICIMVAU
`define CA53_CPOP_8_ICIVAU          `CA53_CPOP_8_ICIMVAU

`define CA53_CPOP_8_BPIALLIS        8'b11001010  // p15 7   0   1   6   BPIALLIS
`define CA53_CPOP_8_BPIMVA          8'b11001011  // p15 7   0   5   7   BPIMVA

`define CA53_CPOP_8_DCIMVAC         8'b11011101  // p15 7   0   6   1   DCIMVAC
`define CA53_CPOP_8_DCISW           8'b11011100  // p15 7   0   6   2   DCISW
`define CA53_CPOP_8_DCCMVAC         8'b11011011  // p15 7   0   10  1   DCCMVAC
`define CA53_CPOP_8_DCCSW           8'b11011010  // p15 7   0   10  2   DCCSW
`define CA53_CPOP_8_DCCMVAU         8'b11010011  // p15 7   0   11  1   DCCMVAU
`define CA53_CPOP_8_DCCIMVAC        8'b11011111  // p15 7   0   14  1   DCCIMVAC
`define CA53_CPOP_8_DCCISW          8'b11011110  // p15 7   0   14  2   DCCISW

`define CA53_CPOP_8_DMBNSHLD        8'b11101100  // DMBNSHLD
`define CA53_CPOP_8_DMBISHLD        8'b11101101  // DMBISHLD
`define CA53_CPOP_8_DMBOSHLD        8'b11101110  // DMBOSHLD
`define CA53_CPOP_8_DMBLD           8'b11101111  // DMBLD
`define CA53_CPOP_8_DSBNS           8'b11110100  // DSBNS, DSBNSST
`define CA53_CPOP_8_DSBIS           8'b11110101  // DSBIS, DSBISST
`define CA53_CPOP_8_DSBOS           8'b11110110  // DSBOS, DSBOSST
`define CA53_CPOP_8_DSBSY           8'b11110111  // DSBSY, DSBSYST
`define CA53_CPOP_8_DMBNS           8'b11111100  // DMBNS
`define CA53_CPOP_8_DMBIS           8'b11111101  // DMBIS
`define CA53_CPOP_8_DMBOS           8'b11111110  // DMBOS
`define CA53_CPOP_8_DMBSY           8'b11111111  // DMBSY
`define CA53_CPOP_8_DMBNSST         8'b11111000  // DMBNSST
`define CA53_CPOP_8_DMBISST         8'b11111001  // DMBISST
`define CA53_CPOP_8_DMBOSST         8'b11111010  // DMBOSST
`define CA53_CPOP_8_DMBSYST         8'b11111011  // DMBSYST

// 9-bit I$, BP, D$, and barrier encodings (non-Gov specifier included)
`define CA53_CPOP_ICIALLUIS         ({1'b0, `CA53_CPOP_8_ICIALLUIS})
`define CA53_CPOP_ICIALLU           {1'b0, `CA53_CPOP_8_ICIALLU}
`define CA53_CPOP_ICIMVAU           {1'b0, `CA53_CPOP_8_ICIMVAU}
`define CA53_CPOP_ICIVAU            {1'b0, `CA53_CPOP_8_ICIVAU}

`define CA53_CPOP_BPIALLIS          {1'b0, `CA53_CPOP_8_BPIALLIS}
`define CA53_CPOP_BPIMVA            {1'b0, `CA53_CPOP_8_BPIMVA}

`define CA53_CPOP_DCIMVAC           {1'b0, `CA53_CPOP_8_DCIMVAC}
`define CA53_CPOP_DCISW             {1'b0, `CA53_CPOP_8_DCISW}
`define CA53_CPOP_DCCMVAC           {1'b0, `CA53_CPOP_8_DCCMVAC}
`define CA53_CPOP_DCCSW             {1'b0, `CA53_CPOP_8_DCCSW}
`define CA53_CPOP_DCCMVAU           {1'b0, `CA53_CPOP_8_DCCMVAU}
`define CA53_CPOP_DCCIMVAC          {1'b0, `CA53_CPOP_8_DCCIMVAC}
`define CA53_CPOP_DCCISW            {1'b0, `CA53_CPOP_8_DCCISW}

`define CA53_CPOP_DMBNSHLD          {1'b0, `CA53_CPOP_8_DMBNSHLD}
`define CA53_CPOP_DMBISHLD          {1'b0, `CA53_CPOP_8_DMBISHLD}
`define CA53_CPOP_DMBOSHLD          {1'b0, `CA53_CPOP_8_DMBOSHLD}
`define CA53_CPOP_DMBLD             {1'b0, `CA53_CPOP_8_DMBLD}
`define CA53_CPOP_DSBNS             {1'b0, `CA53_CPOP_8_DSBNS}
`define CA53_CPOP_DSBIS             {1'b0, `CA53_CPOP_8_DSBIS}
`define CA53_CPOP_DSBOS             {1'b0, `CA53_CPOP_8_DSBOS}
`define CA53_CPOP_DSBSY             {1'b0, `CA53_CPOP_8_DSBSY}
`define CA53_CPOP_DMBNS             {1'b0, `CA53_CPOP_8_DMBNS}
`define CA53_CPOP_DMBIS             {1'b0, `CA53_CPOP_8_DMBIS}
`define CA53_CPOP_DMBOS             {1'b0, `CA53_CPOP_8_DMBOS}
`define CA53_CPOP_DMBSY             {1'b0, `CA53_CPOP_8_DMBSY}
`define CA53_CPOP_DMBNSST           {1'b0, `CA53_CPOP_8_DMBNSST}
`define CA53_CPOP_DMBISST           {1'b0, `CA53_CPOP_8_DMBISST}
`define CA53_CPOP_DMBOSST           {1'b0, `CA53_CPOP_8_DMBOSST}
`define CA53_CPOP_DMBSYST           {1'b0, `CA53_CPOP_8_DMBSYST}

`define CA53_CPOP_CNTFRQ_EL0        9'b110100000
`define CA53_CPOP_CNTPCT_EL0        9'b110100001
`define CA53_CPOP_CNTKCTL_EL1       9'b110100010
`define CA53_CPOP_CNTP_TVAL_EL0     9'b110100011
`define CA53_CPOP_CNTP_CTL_EL0      9'b110100100
`define CA53_CPOP_CNTV_TVAL_EL0     9'b110100101
`define CA53_CPOP_CNTV_CTL_EL0      9'b110100110
`define CA53_CPOP_CNTVCT_EL0        9'b110100111
`define CA53_CPOP_CNTP_CVAL_EL0     9'b110101000
`define CA53_CPOP_CNTV_CVAL_EL0     9'b110101001
`define CA53_CPOP_CNTVOFF_EL2       9'b110101010
`define CA53_CPOP_CNTHCTL_EL2       9'b110101011
`define CA53_CPOP_CNTHP_TVAL_EL2    9'b110101100
`define CA53_CPOP_CNTHP_CTL_EL2     9'b110101101
`define CA53_CPOP_CNTHP_CVAL_EL2    9'b110101110
`define CA53_CPOP_CNTPS_CTL_EL1     9'b110101111
`define CA53_CPOP_CNTPS_CVAL_EL1    9'b110110000
`define CA53_CPOP_CNTPS_TVAL_EL1    9'b110110001

`define CA53_CPOP_L2_ACTLR          9'b110000000
`define CA53_CPOP_L2_ECTLR          9'b110000001
`define CA53_CPOP_L2_CTLR           9'b110000010
`define CA53_CPOP_L2_MEM_ERR_SR     9'b110000011

`define CA53_CPOP_GICC_IAR1_EL1     {2'b10, `CA53_GICCP_GICC_IAR1_EL1}
`define CA53_CPOP_GICC_IAR0_EL1     {2'b10, `CA53_GICCP_GICC_IAR0_EL1}
`define CA53_CPOP_GICC_EOIR1_EL1    {2'b10, `CA53_GICCP_GICC_EOIR1_EL1}
`define CA53_CPOP_GICC_EOIR0_EL1    {2'b10, `CA53_GICCP_GICC_EOIR0_EL1}
`define CA53_CPOP_GICC_HPPIR1_EL1   {2'b10, `CA53_GICCP_GICC_HPPIR1_EL1}
`define CA53_CPOP_GICC_HPPIR0_EL1   {2'b10, `CA53_GICCP_GICC_HPPIR0_EL1}
`define CA53_CPOP_GICC_BPR1_EL1     {2'b10, `CA53_GICCP_GICC_BPR1_EL1}
`define CA53_CPOP_GICC_BPR0_EL1     {2'b10, `CA53_GICCP_GICC_BPR0_EL1}
`define CA53_CPOP_GICC_DIR_EL1      {2'b10, `CA53_GICCP_GICC_DIR_EL1}
`define CA53_CPOP_GICC_PMR_EL1      {2'b10, `CA53_GICCP_GICC_PMR_EL1}
`define CA53_CPOP_GICC_RPR_EL1      {2'b10, `CA53_GICCP_GICC_RPR}
`define CA53_CPOP_GICC_AP0R0_EL1    {2'b10, `CA53_GICCP_GICC_AP0R0_EL1}
`define CA53_CPOP_GICC_AP1R0_EL1    {2'b10, `CA53_GICCP_GICC_AP1R0_EL1}
`define CA53_CPOP_GICC_IGRPEN0_EL1  {2'b10, `CA53_GICCP_GICC_IGRPEN0_EL1}
`define CA53_CPOP_GICC_IGRPEN1_EL1  {2'b10, `CA53_GICCP_GICC_IGRPEN1_EL1}
`define CA53_CPOP_GICC_IGRPEN1_EL3  {2'b10, `CA53_GICCP_GICC_IGRPEN1_EL3}
`define CA53_CPOP_GICC_SRE_EL1      {2'b10, `CA53_GICCP_GICC_SRE_EL1}
`define CA53_CPOP_GICC_SRE_EL2      {2'b10, `CA53_GICCP_GICC_SRE_EL2}
`define CA53_CPOP_GICC_SRE_EL3      {2'b10, `CA53_GICCP_GICC_SRE_EL3}
`define CA53_CPOP_GICC_CTLR_EL1     {2'b10, `CA53_GICCP_GICC_CTLR_EL1}
`define CA53_CPOP_GICC_CTLR_EL3     {2'b10, `CA53_GICCP_GICC_CTLR_EL3}
`define CA53_CPOP_GICC_SGI0R_EL1    {2'b10, `CA53_GICCP_GICC_SGI0R_EL1}
`define CA53_CPOP_GICC_SGI1R_EL1    {2'b10, `CA53_GICCP_GICC_SGI1R_EL1}
`define CA53_CPOP_GICC_ASGI1R_EL1   {2'b10, `CA53_GICCP_GICC_ASGI1R_EL1}
`define CA53_CPOP_GICV_IAR1         {2'b10, `CA53_GICCP_GICV_AIAR}
`define CA53_CPOP_GICV_IAR0         {2'b10, `CA53_GICCP_GICV_IAR}
`define CA53_CPOP_GICV_EOIR1        {2'b10, `CA53_GICCP_GICV_AEOIR}
`define CA53_CPOP_GICV_EOIR0        {2'b10, `CA53_GICCP_GICV_EOIR}
`define CA53_CPOP_GICV_HPPIR1       {2'b10, `CA53_GICCP_GICV_AHPPIR}
`define CA53_CPOP_GICV_HPPIR0       {2'b10, `CA53_GICCP_GICV_HPPIR}
`define CA53_CPOP_GICH_VMCR_BPR1    {2'b10, `CA53_GICCP_GICH_VMCR_BPR1}
`define CA53_CPOP_GICH_VMCR_BPR0    {2'b10, `CA53_GICCP_GICH_VMCR_BPR0}
`define CA53_CPOP_GICV_DIR          {2'b10, `CA53_GICCP_GICV_DIR}
`define CA53_CPOP_GICH_VMCR_PMR     {2'b10, `CA53_GICCP_GICH_VMCR_PMR}
`define CA53_CPOP_GICV_RPR          {2'b10, `CA53_GICCP_GICV_RPR}
`define CA53_CPOP_GICH_AP0R0        {2'b10, `CA53_GICCP_GICH_APR0}
`define CA53_CPOP_GICH_AP1R0        {2'b10, `CA53_GICCP_GICH_APR1}
`define CA53_CPOP_GICH_VMCR_VENG0   {2'b10, `CA53_GICCP_GICH_VMCR_VENG0}
`define CA53_CPOP_GICH_VMCR_VENG1   {2'b10, `CA53_GICCP_GICH_VMCR_VENG1}
`define CA53_CPOP_GICH_HCR_SRE      {2'b10, `CA53_GICCP_GICH_HCR_SRE}
`define CA53_CPOP_GICV_CTLR         {2'b10, `CA53_GICCP_GICV_CTLR}
`define CA53_CPOP_GICH_HCR          {2'b10, `CA53_GICCP_GICH_HCR}
`define CA53_CPOP_GICH_VTR          {2'b10, `CA53_GICCP_GICH_VTR}
`define CA53_CPOP_GICH_VMCR         {2'b10, `CA53_GICCP_GICH_VMCR}
`define CA53_CPOP_GICH_MISR         {2'b10, `CA53_GICCP_GICH_MISR}
`define CA53_CPOP_GICH_EISR         {2'b10, `CA53_GICCP_GICH_EISR}
`define CA53_CPOP_GICH_ELSR         {2'b10, `CA53_GICCP_GICH_ELSR}
`define CA53_CPOP_GICH_LR0          {2'b10, `CA53_GICCP_GICH_LR0}
`define CA53_CPOP_GICH_LR0_L        {2'b10, `CA53_GICCP_GICH_LR0_L}
`define CA53_CPOP_GICH_LR0_H        {2'b10, `CA53_GICCP_GICH_LR0_H}
`define CA53_CPOP_GICH_LR1          {2'b10, `CA53_GICCP_GICH_LR1}
`define CA53_CPOP_GICH_LR1_L        {2'b10, `CA53_GICCP_GICH_LR1_L}
`define CA53_CPOP_GICH_LR1_H        {2'b10, `CA53_GICCP_GICH_LR1_H}
`define CA53_CPOP_GICH_LR2          {2'b10, `CA53_GICCP_GICH_LR2}
`define CA53_CPOP_GICH_LR2_L        {2'b10, `CA53_GICCP_GICH_LR2_L}
`define CA53_CPOP_GICH_LR2_H        {2'b10, `CA53_GICCP_GICH_LR2_H}
`define CA53_CPOP_GICH_LR3          {2'b10, `CA53_GICCP_GICH_LR3}
`define CA53_CPOP_GICH_LR3_L        {2'b10, `CA53_GICCP_GICH_LR3_L}
`define CA53_CPOP_GICH_LR3_H        {2'b10, `CA53_GICCP_GICH_LR3_H}

// ------------------------------------------------------
// STB/BIU operation encodings
// ------------------------------------------------------

// 8-bit encodings for operations not issued by the DPU but which
// share the CPOP encoding space downstream from the STB.
`define CA53_CPOP_8_SYNC            8'b11000010   // Near I$/BP space to simplify DVM decoding
`define CA53_CPOP_8_CLEANUNIQUE     8'b00110001   // Re-uses TLB reg/V2P space
`define CA53_CPOP_8_WRITE           8'b00110010   // Re-uses TLB reg/V2P space

// ------------------------------------------------------
// Instruction size encodings
// ------------------------------------------------------

`define CA53_SIZE_BYTE  2'b00
`define CA53_SIZE_HWORD 2'b01
`define CA53_SIZE_WORD  2'b10
`define CA53_SIZE_DWORD 2'b11

// ------------------------------------------------------
// RAM widths
// ------------------------------------------------------

// Instruction Cache
`define CA53_IDATA_RAM_W  ((CPU_CACHE_PROTECTION > 0) ? 84:80)
`define CA53_IDATA_WEN_W  4
`define CA53_IDATA_STRB_W ((CPU_CACHE_PROTECTION > 0) ? 21:20)
`define CA53_ITAG_RAM_W   ((CPU_CACHE_PROTECTION > 0) ? 32:31)

// Data Cache
`define CA53_DDATA_RAM_W  ((CPU_CACHE_PROTECTION > 0) ? 39:32)
`define CA53_DDATA_WEN_W  4
`define CA53_DTAG_RAM_W   ((CPU_CACHE_PROTECTION > 0) ? 33:32)
`define CA53_DDIRTY_RAM_W ((CPU_CACHE_PROTECTION > 0) ? 12:8)

// TLB
`define CA53_TLB_RAM_ADDR_W   8
`define CA53_TLB_RAM_W    ((CPU_CACHE_PROTECTION > 0) ? 117:114)

// BTAC
`define CA53_BTAC_RAM_ADDR_W 7
`define CA53_BTAC_RAM_S0D_W  50
`define CA53_BTAC_RAM_S1D_W  59

// ------------------------------------------------------
// MBIST interface widths
// ------------------------------------------------------

`define CA53_MBIST0_DATA_W ((CPU_CACHE_PROTECTION > 0) ? 117:114)
`define CA53_MBIST1_DATA_W ((SCU_CACHE_PROTECTION > 0) ? 144:128)
`define CA53_MBIST0_ADDR_W 12
`define CA53_MBIST1_ADDR_W 15
`define CA53_MBIST0_RAMARRAY_W 9
`define CA53_MBIST1_RAMARRAY_W 2
`define CA53_MBIST0_BE_W 16
`define CA53_MBIST1_BE_W 2

// ------------------------------------------------------
// GIC interface widths
// ------------------------------------------------------

`define CA53_GIC_ID_W     16  // 16-bits wide
`define CA53_GIC_PRI_W    5   // 5-bits wide

// ------------------------------------------------------
// Packed buses for top-level
// ------------------------------------------------------

`define CA53_RVBARADDR_W    38  // 38-bits wide
`define CA53_PADDRDBG_W     10  // 10-bits wide
`define CA53_PWDATADBG_W    32  // 32-bits wide
`define CA53_PRDATADBG_W    32  // 32-bits wide
`define CA53_ATREADYM_W     1   // 1-bit wide
`define CA53_AFVALIDM_W     1   // 1-bit wide
`define CA53_ATDATAM_W      32  // 32-bits wide
`define CA53_ATVALIDM_W     1   // 1-bit wide
`define CA53_ATBYTESM_W     2   // 2-bits wide
`define CA53_AFREADYM_W     1   // 1-bit wide
`define CA53_ATIDM_W        7   // 7-bits wide
`define CA53_SYNCREQM_W     1   // 1-bit wide
`define CA53_PMUEVNT_W      30  // 30-bits wide
`define CA53_PMUEVNT_CPU_W  26  // 26-bits wide
`define CA53_CTICH_W        4   // 4-bits wide
`define CA53_ARACTIVE_W     1   // 1-bit wide
`define CA53_ARVALID_W      1   // 1-bit wide
`define CA53_ARID_W         5   // 5-bits wide
`define CA53_ARTYPE_W       5   // 5-bits wide
`define CA53_ARATTRS_W      8   // 8-bits wide
`define CA53_ARWAY_W        5   // 5-bits wide
`define CA53_ARADDR_W       41  // 41-bits wide
`define CA53_ARWRAP_W       1   // 1-bit wide
`define CA53_ARLEN_W        2   // 2-bits wide
`define CA53_ARSIZE_W       3   // 3-bits wide
`define CA53_ARLOCK_W       1   // 1-bit wide
`define CA53_ARPRIV_W       1   // 1-bit wide
`define CA53_DRCREDIT_W     1   // 1-bit wide
`define CA53_DWVALID_W      1   // 1-bit wide
`define CA53_DWL2DB_W       4   // 4-bits wide
`define CA53_DWCHUNKS_W     4   // 4-bits wide
`define CA53_DWLAST_W       1   // 1-bit wide
`define CA53_DWSTRB_W       32  // 32-bits wide
`define CA53_DWDATA_W       256 // 256-bits wide
`define CA53_DWERR_W        1   // 1-bit wide
`define CA53_DWFATAL_W      1   // 1-bit wide
`define CA53_ACREADY_W      1   // 1-bit wide
`define CA53_CRVALID_W      1   // 1-bit wide
`define CA53_CRID_W         3   // 2-bits wide
`define CA53_CRDIRTY_W      1   // 1-bit wide
`define CA53_CRAGE_W        1   // 1-bit wide
`define CA53_CRALLOC_W      1   // 1-bit wide
`define CA53_CRMIG_W        1   // 1-bit wide
`define CA53_INV_ALL_W      1   // 1-bit wide
`define CA53_DVM_COMP_W     1   // 1-bit wide
`define CA53_REQBUFS_BUSY_W 8   // 8-bit wide
`define CA53_DRAIN_STB_W    1   // 1-bit wide
`define CA53_ARCREDIT_W     1   // 1-bit wide
`define CA53_ARBLOCK_W      1   // 1-bit wide
`define CA53_DRVALID_W      1   // 1-bit wide
`define CA53_DRID_W         5   // 5-bits wide
`define CA53_DRRESP_W       6   // 6-bits wide
`define CA53_DRCHUNK_W      2   // 2-bits wide
`define CA53_DRDATA_W       128 // 128-bits wide
`define CA53_RRVALID_W      1   // 1-bit wide
`define CA53_RRID_W         5   // 5-bits wide
`define CA53_RRRESP_W       2   // 2-bits wide
`define CA53_RRL2DB_W       4   // 4-bits wide
`define CA53_EVDONE_W       8   // 8-bits wide
`define CA53_DBEXCLVAL_W    1   // 1-bit wide
`define CA53_DBEXCLRSP_W    2   // 2-bits wide
`define CA53_DBDECERR_W     1   // 1-bit wide
`define CA53_DBSLVERR_W     1   // 1-bit wide
`define CA53_LEAVERAM_W     1   // 1-bit wide
`define CA53_CPUBISTEN_W    1   // 1-bit wide
`define CA53_CPUSEV_W       1   // 1-bit wide
`define CA53_ACVALID_W      1   // 1-bit wide
`define CA53_ACID_W         3   // 2-bits wide
`define CA53_ACL2DB_W       4   // 4-bits wide
`define CA53_ACSNOOP_W      4   // 4-bits wide
`define CA53_ACADDR_W       41  // 41-bits wide
`define CA53_ACWAY_W        4   // 4-bits wide
`define CA53_ETMEXT_W       4   // 4-bits wide
`define CA53_L1DC_SIZE_W    3   // 3-bits wide
`define CA53_EXCP_LEV_W     2   // 2-bits wide
`define CA53_CPDATA_W       64  // 64-bits wide
`define CA53_CPADDR_W       18  // 18-bits wide
`define CA53_CPSEL_W        3   // 3-bits wide
`define CA53_TDATA_W        16  // 16-bits wide
`define CA53_RET_CTL_W      3   // 3-bits wide
`define CA53_GOV_CPDATA_W   64  // 64-bits wide
`define CA53_GOV_CPADDR_W   9   // 9-bits wide

`define CA53_RVBARADDR_PKDED_W    (`CA53_RVBARADDR_W    * NUM_CPUS)
`define CA53_PADDRDBG_PKDED_W     (`CA53_PADDRDBG_W     * NUM_CPUS)
`define CA53_PWDATADBG_PKDED_W    (`CA53_PWDATADBG_W    * NUM_CPUS)
`define CA53_PRDATADBG_PKDED_W    (`CA53_PRDATADBG_W    * NUM_CPUS)
`define CA53_ATREADYM_PKDED_W     (`CA53_ATREADYM_W     * NUM_CPUS)
`define CA53_AFVALIDM_PKDED_W     (`CA53_AFVALIDM_W     * NUM_CPUS)
`define CA53_ATDATAM_PKDED_W      (`CA53_ATDATAM_W      * NUM_CPUS)
`define CA53_ATVALIDM_PKDED_W     (`CA53_ATVALIDM_W     * NUM_CPUS)
`define CA53_ATBYTESM_PKDED_W     (`CA53_ATBYTESM_W     * NUM_CPUS)
`define CA53_AFREADYM_PKDED_W     (`CA53_AFREADYM_W     * NUM_CPUS)
`define CA53_ATIDM_PKDED_W        (`CA53_ATIDM_W        * NUM_CPUS)
`define CA53_SYNCREQM_PKDED_W     (`CA53_SYNCREQM_W     * NUM_CPUS)
`define CA53_PMUEVNT_PKDED_W      (`CA53_PMUEVNT_W      * NUM_CPUS)
`define CA53_PMUEVNT_CPU_PKDED_W  (`CA53_PMUEVNT_CPU_W  * NUM_CPUS)
`define CA53_CTICH_PKDED_W        (`CA53_CTICH_W        * NUM_CPUS)
`define CA53_ARACTIVE_PKDED_W     (`CA53_ARACTIVE_W     * NUM_CPUS)
`define CA53_ARVALID_PKDED_W      (`CA53_ARVALID_W      * NUM_CPUS)
`define CA53_ARID_PKDED_W         (`CA53_ARID_W         * NUM_CPUS)
`define CA53_ARTYPE_PKDED_W       (`CA53_ARTYPE_W       * NUM_CPUS)
`define CA53_ARATTRS_PKDED_W      (`CA53_ARATTRS_W      * NUM_CPUS)
`define CA53_ARWAY_PKDED_W        (`CA53_ARWAY_W        * NUM_CPUS)
`define CA53_ARADDR_PKDED_W       (`CA53_ARADDR_W       * NUM_CPUS)
`define CA53_ARWRAP_PKDED_W       (`CA53_ARWRAP_W       * NUM_CPUS)
`define CA53_ARLEN_PKDED_W        (`CA53_ARLEN_W        * NUM_CPUS)
`define CA53_ARSIZE_PKDED_W       (`CA53_ARSIZE_W       * NUM_CPUS)
`define CA53_ARLOCK_PKDED_W       (`CA53_ARLOCK_W       * NUM_CPUS)
`define CA53_ARPRIV_PKDED_W       (`CA53_ARPRIV_W       * NUM_CPUS)
`define CA53_DRCREDIT_PKDED_W     (`CA53_DRCREDIT_W     * NUM_CPUS)
`define CA53_DWVALID_PKDED_W      (`CA53_DWVALID_W      * NUM_CPUS)
`define CA53_DWL2DB_PKDED_W       (`CA53_DWL2DB_W       * NUM_CPUS)
`define CA53_DWCHUNKS_PKDED_W     (`CA53_DWCHUNKS_W     * NUM_CPUS)
`define CA53_DWLAST_PKDED_W       (`CA53_DWLAST_W       * NUM_CPUS)
`define CA53_DWSTRB_PKDED_W       (`CA53_DWSTRB_W       * NUM_CPUS)
`define CA53_DWDATA_PKDED_W       (`CA53_DWDATA_W       * NUM_CPUS)
`define CA53_DWERR_PKDED_W        (`CA53_DWERR_W        * NUM_CPUS)
`define CA53_DWFATAL_PKDED_W      (`CA53_DWFATAL_W      * NUM_CPUS)
`define CA53_ACREADY_PKDED_W      (`CA53_ACREADY_W      * NUM_CPUS)
`define CA53_CRVALID_PKDED_W      (`CA53_CRVALID_W      * NUM_CPUS)
`define CA53_CRID_PKDED_W         (`CA53_CRID_W         * NUM_CPUS)
`define CA53_CRDIRTY_PKDED_W      (`CA53_CRDIRTY_W      * NUM_CPUS)
`define CA53_CRAGE_PKDED_W        (`CA53_CRAGE_W        * NUM_CPUS)
`define CA53_CRALLOC_PKDED_W      (`CA53_CRALLOC_W      * NUM_CPUS)
`define CA53_CRMIG_PKDED_W        (`CA53_CRMIG_W        * NUM_CPUS)
`define CA53_INV_ALL_PKDED_W      (`CA53_INV_ALL_W      * NUM_CPUS)
`define CA53_DVM_COMP_PKDED_W     (`CA53_DVM_COMP_W     * NUM_CPUS)
`define CA53_REQBUFS_BUSY_PKDED_W (`CA53_REQBUFS_BUSY_W * NUM_CPUS)
`define CA53_DRAIN_STB_PKDED_W    (`CA53_DRAIN_STB_W    * NUM_CPUS)
`define CA53_ARCREDIT_PKDED_W     (`CA53_ARCREDIT_W     * NUM_CPUS)
`define CA53_ARBLOCK_PKDED_W      (`CA53_ARBLOCK_W      * NUM_CPUS)
`define CA53_DRVALID_PKDED_W      (`CA53_DRVALID_W      * NUM_CPUS)
`define CA53_DRID_PKDED_W         (`CA53_DRID_W         * NUM_CPUS)
`define CA53_DRRESP_PKDED_W       (`CA53_DRRESP_W       * NUM_CPUS)
`define CA53_DRCHUNK_PKDED_W      (`CA53_DRCHUNK_W      * NUM_CPUS)
`define CA53_DRDATA_PKDED_W       (`CA53_DRDATA_W       * NUM_CPUS)
`define CA53_RRVALID_PKDED_W      (`CA53_RRVALID_W      * NUM_CPUS)
`define CA53_RRID_PKDED_W         (`CA53_RRID_W         * NUM_CPUS)
`define CA53_RRRESP_PKDED_W       (`CA53_RRRESP_W       * NUM_CPUS)
`define CA53_RRL2DB_PKDED_W       (`CA53_RRL2DB_W       * NUM_CPUS)
`define CA53_EVDONE_PKDED_W       (`CA53_EVDONE_W       * NUM_CPUS)
`define CA53_DBEXCLVAL_PKDED_W    (`CA53_DBEXCLVAL_W    * NUM_CPUS)
`define CA53_DBEXCLRSP_PKDED_W    (`CA53_DBEXCLRSP_W    * NUM_CPUS)
`define CA53_DBDECERR_PKDED_W     (`CA53_DBDECERR_W     * NUM_CPUS)
`define CA53_DBSLVERR_PKDED_W     (`CA53_DBSLVERR_W     * NUM_CPUS)
`define CA53_LEAVERAM_PKDED_W     (`CA53_LEAVERAM_W     * NUM_CPUS)
`define CA53_CPUBISTEN_PKDED_W    (`CA53_CPUBISTEN_W    * NUM_CPUS)
`define CA53_CPUSEV_PKDED_W       (`CA53_CPUSEV_W       * NUM_CPUS)
`define CA53_ACVALID_PKDED_W      (`CA53_ACVALID_W      * NUM_CPUS)
`define CA53_ACID_PKDED_W         (`CA53_ACID_W         * NUM_CPUS)
`define CA53_ACL2DB_PKDED_W       (`CA53_ACL2DB_W       * NUM_CPUS)
`define CA53_ACSNOOP_PKDED_W      (`CA53_ACSNOOP_W      * NUM_CPUS)
`define CA53_ACADDR_PKDED_W       (`CA53_ACADDR_W       * NUM_CPUS)
`define CA53_ACWAY_PKDED_W        (`CA53_ACWAY_W        * NUM_CPUS)
`define CA53_ETMEXT_PKDED_W       (`CA53_ETMEXT_W       * NUM_CPUS)
`define CA53_EXCP_LEV_PKDED_W     (`CA53_EXCP_LEV_W     * NUM_CPUS)
`define CA53_CPDATA_PKDED_W       (`CA53_CPDATA_W       * NUM_CPUS)
`define CA53_CPADDR_PKDED_W       (`CA53_CPADDR_W       * NUM_CPUS)
`define CA53_CPSEL_PKDED_W        (`CA53_CPSEL_W        * NUM_CPUS)
`define CA53_TDATA_PKDED_W        (`CA53_TDATA_W        * NUM_CPUS)
`define CA53_RET_CTL_PKDED_W      (`CA53_RET_CTL_W      * NUM_CPUS)
`define CA53_GOV_CPDATA_PKDED_W   (`CA53_GOV_CPDATA_W   * NUM_CPUS)
`define CA53_GOV_CPADDR_PKDED_W   (`CA53_GOV_CPADDR_W   * NUM_CPUS)

// ------------------------------------------------------
// Cache sizes
// ------------------------------------------------------

`define CA53_SIZE_8K  3'b000 // 8KB
`define CA53_SIZE_16K 3'b001 // 16KB
`define CA53_SIZE_32K 3'b011 // 32KB
`define CA53_SIZE_64K 3'b111 // 64KB

// ------------------------------------------------------
// Maximum core count
// ------------------------------------------------------

`define CA53_MAX_NUM_CPUS 4

// ------------------------------------------------------
// AXI encodings
// ------------------------------------------------------

`define CA53_RESP_OKAY   2'b00
`define CA53_RESP_EXOKAY 2'b01
`define CA53_RESP_SLVERR 2'b10
`define CA53_RESP_DECERR 2'b11

// ------------------------------------------------------
// DPU defines for the architectural modes
// ------------------------------------------------------

`define CA53_EL0 2'b00
`define CA53_EL1 2'b01
`define CA53_EL2 2'b10
`define CA53_EL3 2'b11

`define CA53_ONE_HOT_EL0 4'b0001
`define CA53_ONE_HOT_EL1 4'b0010
`define CA53_ONE_HOT_EL2 4'b0100
`define CA53_ONE_HOT_EL3 4'b1000

`define CA53_MODE_USR    4'b0000
`define CA53_MODE_FIQ    4'b0001
`define CA53_MODE_IRQ    4'b0010
`define CA53_MODE_SVC    4'b0011
`define CA53_MODE_ABT    4'b0111
`define CA53_MODE_UND    4'b1011
`define CA53_MODE_SYS    4'b1111
`define CA53_MODE_MON    4'b0110
`define CA53_MODE_HYP    4'b1010
`define CA53_MODE_NONUSE 4'b0100, 4'b0101, 4'b1000, 4'b1001, 4'b1100, 4'b1101, 4'b1110

`define CA53_FULL_MODE_USR    5'b10000
`define CA53_FULL_MODE_FIQ    5'b10001
`define CA53_FULL_MODE_IRQ    5'b10010
`define CA53_FULL_MODE_SVC    5'b10011
`define CA53_FULL_MODE_ABT    5'b10111
`define CA53_FULL_MODE_UND    5'b11011
`define CA53_FULL_MODE_SYS    5'b11111
`define CA53_FULL_MODE_MON    5'b10110
`define CA53_FULL_MODE_HYP    5'b11010

`define CA53_FULL_MODE_EL0T   5'b00000
`define CA53_FULL_MODE_EL1T   5'b00100
`define CA53_FULL_MODE_EL1H   5'b00101
`define CA53_FULL_MODE_EL2T   5'b01000
`define CA53_FULL_MODE_EL2H   5'b01001
`define CA53_FULL_MODE_EL3T   5'b01100
`define CA53_FULL_MODE_EL3H   5'b01101

`define CA53_FULL_MODE_NONUSE 5'b00001, 5'b00010, 5'b00011, 5'b00110, \
                              5'b00111, 5'b01010, 5'b01011, 5'b01110, \
                              5'b01111, 5'b10100, 5'b10101, 5'b11000, \
                              5'b11001, 5'b11100, 5'b11101, 5'b11110

`define CA53_ONEHOT_MODE_USR_SYS 12'b0000_0000_0001
`define CA53_ONEHOT_MODE_FIQ     12'b0000_0000_0010
`define CA53_ONEHOT_MODE_IRQ     12'b0000_0000_0100
`define CA53_ONEHOT_MODE_SVC     12'b0000_0000_1000
`define CA53_ONEHOT_MODE_ABT     12'b0000_0001_0000
`define CA53_ONEHOT_MODE_UND     12'b0000_0010_0000
`define CA53_ONEHOT_MODE_MON     12'b0000_0100_0000
`define CA53_ONEHOT_MODE_HYP     12'b0000_1000_0000
`define CA53_ONEHOT_MODE_ELXT    12'b0001_0000_0000
`define CA53_ONEHOT_MODE_EL1H    12'b0010_0000_0000
`define CA53_ONEHOT_MODE_EL2H    12'b0100_0000_0000
`define CA53_ONEHOT_MODE_EL3H    12'b1000_0000_0000

`define CA53_ONEHOT_MODE_USR_SYS_BIT 0
`define CA53_ONEHOT_MODE_FIQ_BIT     1
`define CA53_ONEHOT_MODE_IRQ_BIT     2
`define CA53_ONEHOT_MODE_SVC_BIT     3
`define CA53_ONEHOT_MODE_ABT_BIT     4
`define CA53_ONEHOT_MODE_UND_BIT     5
`define CA53_ONEHOT_MODE_MON_BIT     6
`define CA53_ONEHOT_MODE_HYP_BIT     7
`define CA53_ONEHOT_MODE_ELXT_BIT    8
`define CA53_ONEHOT_MODE_EL1H_BIT    9
`define CA53_ONEHOT_MODE_EL2H_BIT    10
`define CA53_ONEHOT_MODE_EL3H_BIT    11

// ------------------------------------------------------
// Helper defines for RTL configuration parameters
// ------------------------------------------------------

// log2 function for integers from 2 to 3096 (inclusive).  Results are rounded up.
// Returns 1 for inputs less than 2 and -1 for inputs greater than 4096.
`define CA53_LOG2(a) (((a)<=2)     ? 1  : \
                      ((a)<=4)     ? 2  : \
                      ((a)<=8)     ? 3  : \
                      ((a)<=16)    ? 4  : \
                      ((a)<=32)    ? 5  : \
                      ((a)<=64)    ? 6  : \
                      ((a)<=128)   ? 7  : \
                      ((a)<=256)   ? 8  : \
                      ((a)<=512)   ? 9  : \
                      ((a)<=1024)  ? 10 : \
                      ((a)<=2048)  ? 11 : \
                      ((a)<=4096)  ? 12 : \
                      ((a)<=8192)  ? 13 : \
                      ((a)<=16384) ? 14 : \
                      ((a)<=32768) ? 15 : \
                      ((a)<=65536) ? 16 : \
                      ((a)<=131072)? 17 : \
                                     -1)
// ------------------------------------------------------
// RTL configuration parameters for different units
// ------------------------------------------------------

`define CA53_NORAM_PARAM_DECL #(parameter L2_CACHE             = 1'b0, \
                                parameter NEON_FP              = 1'b0, \
                                parameter CRYPTO               = 1'b0, \
                                parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_NORAM_PARAM_INST #(.L2_CACHE             (L2_CACHE), \
                                .NEON_FP              (NEON_FP),  \
                                .CRYPTO               (CRYPTO),   \
                                .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_CPU_PARAM_DECL #(parameter L2_CACHE             = 1'b0,   \
                              parameter NEON_FP              = 1'b0,   \
                              parameter CRYPTO               = 1'b0,   \
                              parameter CPU_CACHE_PROTECTION = 1'b0,   \
                              parameter L1_ICACHE_SIZE       = 3'b011, \
                              parameter L1_DCACHE_SIZE       = 3'b011)
`define CA53_CPU_PARAM_INST #(.L2_CACHE             (L2_CACHE),             \
                              .NEON_FP              (NEON_FP),              \
                              .CRYPTO               (CRYPTO),               \
                              .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                              .L1_ICACHE_SIZE       (L1_ICACHE_SIZE),       \
                              .L1_DCACHE_SIZE       (L1_DCACHE_SIZE))

`define CA53_BIU_PARAM_DECL #(parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_BIU_PARAM_INST #(.CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_DPU_PARAM_DECL #(parameter CPU_CACHE_PROTECTION = 1'b0, \
                              parameter L2_CACHE = 1'b0, \
                              parameter NEON_FP  = 1'b0, \
                              parameter CRYPTO   = 1'b0)
`define CA53_DPU_PARAM_INST #(.CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                              .L2_CACHE(L2_CACHE), \
                              .NEON_FP (NEON_FP),  \
                              .CRYPTO  (CRYPTO))

`define CA53_DCU_PARAM_DECL #(parameter L2_CACHE             = 1'b0, \
                              parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_DCU_PARAM_INST #(.L2_CACHE             (L2_CACHE), \
                              .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_TLB_PARAM_DECL #(parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_TLB_PARAM_INST #(.CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_IFU_PARAM_DECL #(parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_IFU_PARAM_INST #(.CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_SCU_PARAM_DECL #(parameter NUM_CPUS             = 4,    \
                              parameter L2_CACHE             = 1'b0, \
                              parameter SCU_CACHE_PROTECTION = 1'b0, \
                              parameter CPU_CACHE_PROTECTION = 1'b0, \
                              parameter L2_INPUT_LATENCY     = 1'b0, \
                              parameter L2_OUTPUT_LATENCY    = 1'b0, \
                              parameter ACE                  = 1'b1, \
                              parameter ACP                  = 1'b0)
`define CA53_SCU_PARAM_INST #(.NUM_CPUS             (NUM_CPUS),             \
                              .L2_CACHE             (L2_CACHE),             \
                              .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                              .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                              .L2_INPUT_LATENCY     (L2_INPUT_LATENCY),     \
                              .L2_OUTPUT_LATENCY    (L2_OUTPUT_LATENCY),    \
                              .ACE                  (ACE),                  \
                              .ACP                  (ACP))

`define CA53_STB_PARAM_DECL #(parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_STB_PARAM_INST #(.CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_L2_PARAM_DECL #(parameter NUM_CPUS             = 4,       \
                             parameter NEON_FP              = 1'b0,    \
                             parameter CRYPTO               = 1'b0,    \
                             parameter L2_CACHE             = 1'b0,    \
                             parameter L1_DCACHE_SIZE       = 3'b011,  \
                             parameter L2_CACHE_SIZE        = 4'b0001, \
                             parameter L2_INPUT_LATENCY     = 1'b0,    \
                             parameter L2_OUTPUT_LATENCY    = 1'b0,    \
                             parameter SCU_CACHE_PROTECTION = 1'b0,    \
                             parameter CPU_CACHE_PROTECTION = 1'b0,    \
                             parameter ACE                  = 1'b1,    \
                             parameter ACP                  = 1'b0,    \
                             parameter LEGACY_V7_DEBUG_MAP  = 1'b0)
`define CA53_L2_PARAM_INST #(.NUM_CPUS             (NUM_CPUS),             \
                             .NEON_FP              (NEON_FP),              \
                             .CRYPTO               (CRYPTO),               \
                             .L2_CACHE             (L2_CACHE),             \
                             .L1_DCACHE_SIZE       (L1_DCACHE_SIZE),       \
                             .L2_CACHE_SIZE        (L2_CACHE_SIZE),        \
                             .L2_INPUT_LATENCY     (L2_INPUT_LATENCY),     \
                             .L2_OUTPUT_LATENCY    (L2_OUTPUT_LATENCY),    \
                             .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                             .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                             .ACE                  (ACE),                  \
                             .ACP                  (ACP),                  \
                             .LEGACY_V7_DEBUG_MAP  (LEGACY_V7_DEBUG_MAP))

`define CA53_L1_RAM_PARAM_DECL #(parameter L1_ICACHE_SIZE       = 3'b011, \
                                 parameter L1_DCACHE_SIZE       = 3'b011, \
                                 parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_L1_RAM_PARAM_INST #(.L1_ICACHE_SIZE       (L1_ICACHE_SIZE), \
                                 .L1_DCACHE_SIZE       (L1_DCACHE_SIZE), \
                                 .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_L1D_RAM_PARAM_DECL #(parameter NUM_CPUS             = 4,      \
                                  parameter L1_DCACHE_SIZE       = 3'b011, \
                                  parameter SCU_CACHE_PROTECTION = 1'b0,   \
                                  parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_L1D_RAM_PARAM_INST #(.NUM_CPUS             (NUM_CPUS),             \
                                  .L1_DCACHE_SIZE       (L1_DCACHE_SIZE),       \
                                  .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                                  .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_L2_RAM_PARAM_DECL #(parameter L2_CACHE_SIZE        = 4'b0001, \
                                 parameter L2_INPUT_LATENCY     = 1'b0,    \
                                 parameter L2_OUTPUT_LATENCY    = 1'b0,    \
                                 parameter SCU_CACHE_PROTECTION = 1'b0,    \
                                 parameter CPU_CACHE_PROTECTION = 1'b0)
`define CA53_L2_RAM_PARAM_INST #(.L2_CACHE_SIZE        (L2_CACHE_SIZE),        \
                                 .L2_INPUT_LATENCY     (L2_INPUT_LATENCY),     \
                                 .L2_OUTPUT_LATENCY    (L2_OUTPUT_LATENCY),    \
                                 .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                                 .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION))

`define CA53_GOVERNOR_PARAM_DECL #(parameter NUM_CPUS             = 4,    \
                                   parameter NEON_FP              = 1'b0, \
                                   parameter CRYPTO               = 1'b0, \
                                   parameter SCU_CACHE_PROTECTION = 1'b0, \
                                   parameter CPU_CACHE_PROTECTION = 1'b0, \
                                   parameter L2_INPUT_LATENCY     = 1'b0, \
                                   parameter L2_OUTPUT_LATENCY    = 1'b0, \
                                   parameter ACE                  = 1'b1, \
                                   parameter LEGACY_V7_DEBUG_MAP  = 1'b0)
`define CA53_GOVERNOR_PARAM_INST #(.NUM_CPUS             (NUM_CPUS),             \
                                   .NEON_FP              (NEON_FP),              \
                                   .CRYPTO               (CRYPTO),               \
                                   .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                                   .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                                   .L2_INPUT_LATENCY     (L2_INPUT_LATENCY),     \
                                   .L2_OUTPUT_LATENCY    (L2_OUTPUT_LATENCY),    \
                                   .ACE                  (ACE),                  \
                                   .LEGACY_V7_DEBUG_MAP  (LEGACY_V7_DEBUG_MAP))

`define CA53_GIC_PARAM_DECL #(parameter NUM_CPUS = 4)
`define CA53_GIC_PARAM_INST #(.NUM_CPUS(NUM_CPUS))

`define CA53_SCU_RAMS_PARAM_DECL parameter L2_CACHE             = 0,    \
                                 parameter CPU_CACHE_PROTECTION = 1'b0, \
                                 parameter SCU_CACHE_PROTECTION = 1'b0, \
                                 parameter L2_INPUT_LATENCY     = 1'b0, \
                                 parameter L2_OUTPUT_LATENCY    = 1'b0
`define CA53_SCU_RAMS_PARAM_INST #(.L2_CACHE             (L2_CACHE),             \
                                   .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                                   .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION), \
                                   .L2_INPUT_LATENCY     (L2_INPUT_LATENCY),     \
                                   .L2_OUTPUT_LATENCY    (L2_OUTPUT_LATENCY))

`define CA53_GOV_SCU_PARAM_DECL parameter NUM_CPUS             = 1,    \
                                parameter CPU_CACHE_PROTECTION = 1'b0, \
                                parameter SCU_CACHE_PROTECTION = 1'b0
`define CA53_GOV_SCU_PARAM_INST #(.NUM_CPUS(NUM_CPUS),                          \
                                  .CPU_CACHE_PROTECTION (CPU_CACHE_PROTECTION), \
                                  .SCU_CACHE_PROTECTION (SCU_CACHE_PROTECTION))

// ------------------------------------------------------
// Undefines
// ------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_REVISION
`undef CA53_VARIANT
`undef CA53_PERPH_REVISION
`undef CA53_PERPH_REV_AND
`undef CA53_IMPLEMENTOR
`undef CA53_ARCH_REVISED
`undef CA53_PART_NUM_11_8
`undef CA53_PART_NUM_7_0
`undef CA53_VFP_SUBARCH
`undef CA53_VFP_PART_NUM
`undef CA53_VFP_VARIANT
`undef CA53_IDCR_READ_VALUE
`undef CA53_CTR_CWG
`undef CA53_CTR_ERG
`undef CA53_CTR_DMINLINE
`undef CA53_CTR_L1IP
`undef CA53_CTR_IMINLINE
`undef CA53_MPIDR_READ_VALUE
`undef CA53_CLIDR_READ_VALUE
`undef CA53_CCSIDR_L2_READ_VALUE
`undef CA53_CCSIDR_L1D_READ_VALUE
`undef CA53_CCSIDR_L1I_READ_VALUE
`undef CA53_COMP0ID_RD_VAL
`undef CA53_COMP1ID_RD_VAL
`undef CA53_COMP2ID_RD_VAL
`undef CA53_COMP3ID_RD_VAL
`undef CA53_PMU_PART_NUM
`undef CA53_ETM_PART_NUM
`undef CA53_CTI_PART_NUM
`undef CA53_CTI_COMPONID0_VAL
`undef CA53_CTI_COMPONID1_VAL
`undef CA53_CTI_COMPONID2_VAL
`undef CA53_CTI_COMPONID3_VAL
`undef CA53_CTI_DEVTYPE_VAL
`undef CA53_CTI_DEVARCH_VAL
`undef CA53_ID_PFR0_READ_VALUE
`undef CA53_ID_PFR1_READ_VALUE
`undef CA53_ID_DFR0_READ_VALUE
`undef CA53_ID_AFR0_READ_VALUE
`undef CA53_ID_MMFR0_READ_VALUE
`undef CA53_ID_MMFR1_READ_VALUE
`undef CA53_ID_MMFR2_READ_VALUE
`undef CA53_ID_MMFR3_READ_VALUE
`undef CA53_ID_ISAR0_READ_VALUE
`undef CA53_ID_ISAR1_READ_VALUE
`undef CA53_ID_ISAR2_READ_VALUE
`undef CA53_ID_ISAR3_READ_VALUE
`undef CA53_ID_ISAR4_READ_VALUE
`undef CA53_ID_ISAR5_READ_VALUE
`undef CA53_FPSID_READ_VALUE
`undef CA53_MVFR0_READ_VALUE
`undef CA53_MVFR1_READ_VALUE
`undef CA53_MVFR2_READ_VALUE
`undef CA53_AA64PFR0_READ_VALUE
`undef CA53_AA64PFR1_READ_VALUE
`undef CA53_AA64DFR0_READ_VALUE
`undef CA53_AA64DFR1_READ_VALUE
`undef CA53_AA64AFR0_READ_VALUE
`undef CA53_AA64AFR1_READ_VALUE
`undef CA53_AA64ISAR0_READ_VALUE
`undef CA53_AA64ISAR1_READ_VALUE
`undef CA53_AA64MMFR0_READ_VALUE
`undef CA53_AA64MMFR1_READ_VALUE
`undef CA53_NUM_PMN
`undef CA53_PMCFGR_READ_VALUE
`undef CA53_PMCEID0_READ_VALUE
`undef CA53_PMDEVARCH_READ_VALUE
`undef CA53_PMDEVTYPE_READ_VALUE
`undef CA53_DBG_EDESR
`undef CA53_DBG_EDECR
`undef CA53_DBG_EDWAR_LO
`undef CA53_DBG_EDWAR_HI
`undef CA53_DBG_DTRRX
`undef CA53_DBG_EDITR
`undef CA53_DBG_EDSCR
`undef CA53_DBG_DTRTX
`undef CA53_DBG_EDRCR
`undef CA53_DBG_EDACR
`undef CA53_DBG_EDECCR
`undef CA53_DBG_EDPCSRlo
`undef CA53_DBG_EDCIDSR
`undef CA53_DBG_EDVIDSR
`undef CA53_DBG_EDPCSRhi
`undef CA53_DBG_OSLAR
`undef CA53_DBG_EDPRCR
`undef CA53_DBG_EDPRSR
`undef CA53_DBG_BVR0lo
`undef CA53_DBG_BVR0hi
`undef CA53_DBG_BCR0
`undef CA53_DBG_BVR1lo
`undef CA53_DBG_BVR1hi
`undef CA53_DBG_BCR1
`undef CA53_DBG_BVR2lo
`undef CA53_DBG_BVR2hi
`undef CA53_DBG_BCR2
`undef CA53_DBG_BVR3lo
`undef CA53_DBG_BVR3hi
`undef CA53_DBG_BCR3
`undef CA53_DBG_BVR4lo
`undef CA53_DBG_BVR4hi
`undef CA53_DBG_BCR4
`undef CA53_DBG_BVR5lo
`undef CA53_DBG_BVR5hi
`undef CA53_DBG_BCR5
`undef CA53_DBG_WVR0lo
`undef CA53_DBG_WVR0hi
`undef CA53_DBG_WCR0
`undef CA53_DBG_WVR1lo
`undef CA53_DBG_WVR1hi
`undef CA53_DBG_WCR1
`undef CA53_DBG_WVR2lo
`undef CA53_DBG_WVR2hi
`undef CA53_DBG_WCR2
`undef CA53_DBG_WVR3lo
`undef CA53_DBG_WVR3hi
`undef CA53_DBG_WCR3
`undef CA53_DBG_MIDR
`undef CA53_DBG_ID_AA64PFR0lo
`undef CA53_DBG_ID_AA64PFR0hi
`undef CA53_DBG_ID_AA64DFR0lo
`undef CA53_DBG_ID_AA64DFR0hi
`undef CA53_DBG_ID_AA64ISAR0lo
`undef CA53_DBG_ID_AA64ISAR0hi
`undef CA53_DBG_ID_AA64MMFR0lo
`undef CA53_DBG_ID_AA64MMFR0hi
`undef CA53_DBG_ID_AA64PFR1lo
`undef CA53_DBG_ID_AA64PFR1hi
`undef CA53_DBG_ID_AA64DFR1lo
`undef CA53_DBG_ID_AA64DFR1hi
`undef CA53_DBG_ID_AA64ISAR1lo
`undef CA53_DBG_ID_AA64ISAR1hi
`undef CA53_DBG_ID_AA64MMFR1lo
`undef CA53_DBG_ID_AA64MMFR1hi
`undef CA53_DBG_CLAIMSET
`undef CA53_DBG_CLAIMCLR
`undef CA53_DBG_DEVAFF0
`undef CA53_DBG_DEVAFF1
`undef CA53_DBG_LAR
`undef CA53_DBG_LSR
`undef CA53_DBG_AUTHSTATUS
`undef CA53_DBG_DEVARCH
`undef CA53_DBG_DEVID2
`undef CA53_DBG_DEVID1
`undef CA53_DBG_DEVID
`undef CA53_DBG_DEVTYPE
`undef CA53_DBG_PID4
`undef CA53_DBG_PID0
`undef CA53_DBG_PID1
`undef CA53_DBG_PID2
`undef CA53_DBG_PID3
`undef CA53_DBG_CID0
`undef CA53_DBG_CID1
`undef CA53_DBG_CID2
`undef CA53_DBG_CID3
`undef CA53_DBG_BVR
`undef CA53_DBG_WVR
`undef CA53_PMU_PMEVCNTRn_EL0
`undef CA53_PMU_PMCCNTR_EL0_lo
`undef CA53_PMU_PMCCNTR_EL0_hi
`undef CA53_PMU_PMEVTYPER0_EL0
`undef CA53_PMU_PMEVTYPERn_EL0
`undef CA53_PMU_PMCCFILTR_EL0
`undef CA53_PMU_PMCNTENSET_EL0
`undef CA53_PMU_PMCNTENCLR_EL0
`undef CA53_PMU_PMINTENSET_EL1
`undef CA53_PMU_PMINTENCLR_EL1
`undef CA53_PMU_PMOVSCLR_EL0
`undef CA53_PMU_PMSWINC_EL0
`undef CA53_PMU_PMOVSSET_EL0
`undef CA53_PMU_PMCFGR
`undef CA53_PMU_PMCR_EL0
`undef CA53_PMU_PMCEID0_EL0
`undef CA53_PMU_PMCEID1_EL0
`undef CA53_PMU_DEVAFF0
`undef CA53_PMU_DEVAFF1
`undef CA53_PMU_LAR
`undef CA53_PMU_LSR
`undef CA53_PMU_AUTHSTATUS
`undef CA53_PMU_DEVARCH
`undef CA53_PMU_DEVTYPE
`undef CA53_PMU_PID4
`undef CA53_PMU_PID0
`undef CA53_PMU_PID1
`undef CA53_PMU_PID2
`undef CA53_PMU_PID3
`undef CA53_PMU_CID0
`undef CA53_PMU_CID1
`undef CA53_PMU_CID2
`undef CA53_PMU_CID3
`undef CA53_ETM_OSLAR
`undef CA53_ETM_OSLSR
`undef CA53_ETM_PDCR
`undef CA53_ETM_PDSR
`undef CA53_ETM_DEVAFF0
`undef CA53_ETM_DEVAFF1
`undef CA53_ETM_LAR
`undef CA53_ETM_LSR
`undef CA53_ETM_AUTHSTATUS
`undef CA53_ETM_DEVARCH
`undef CA53_ETM_DEVTYPE
`undef CA53_ETM_PID4
`undef CA53_ETM_PID0
`undef CA53_ETM_PID1
`undef CA53_ETM_PID2
`undef CA53_ETM_PID3
`undef CA53_ETM_CID0
`undef CA53_ETM_CID1
`undef CA53_ETM_CID2
`undef CA53_ETM_CID3
`undef CA53_CTI_CONTROL_ADD
`undef CA53_CTI_INTACK_ADD
`undef CA53_CTI_APPSET_ADD
`undef CA53_CTI_APPCLR_ADD
`undef CA53_CTI_APPPULSE_ADD
`undef CA53_CTI_TRIGINSTATUS_ADD
`undef CA53_CTI_TRIGOUTSTATUS_ADD
`undef CA53_CTI_CHINSTATUS_ADD
`undef CA53_CTI_CHOUTSTATUS_ADD
`undef CA53_CTI_ITCONTROL_ADD
`undef CA53_CTI_CHANNELGATE_ADD
`undef CA53_CTI_CLAIMSET_ADD
`undef CA53_CTI_CLAIMCLR_ADD
`undef CA53_CTI_DEVAFF0
`undef CA53_CTI_DEVAFF1
`undef CA53_CTI_LOCKACCESS_ADD
`undef CA53_CTI_LOCKSTATUS_ADD
`undef CA53_CTI_AUTHSTATUS_ADD
`undef CA53_CTI_DEVARCH_ADD
`undef CA53_CTI_DEVID2_ADD
`undef CA53_CTI_DEVID1_ADD
`undef CA53_CTI_DEVID_ADD
`undef CA53_CTI_DEVTYPE_ADD
`undef CA53_CTI_PERIPHID4_ADD
`undef CA53_CTI_PERIPHID5_ADD
`undef CA53_CTI_PERIPHID6_ADD
`undef CA53_CTI_PERIPHID7_ADD
`undef CA53_CTI_PERIPHID0_ADD
`undef CA53_CTI_PERIPHID1_ADD
`undef CA53_CTI_PERIPHID2_ADD
`undef CA53_CTI_PERIPHID3_ADD
`undef CA53_CTI_COMPONID0_ADD
`undef CA53_CTI_COMPONID1_ADD
`undef CA53_CTI_COMPONID2_ADD
`undef CA53_CTI_COMPONID3_ADD
`undef CA53_DBG_VER
`undef CA53_NUM_BRP_CID
`undef CA53_NUM_BRP
`undef CA53_NUM_WRP
`undef CA53_DIDR_READ_VALUE
`undef CA53_DBGDEVID_READ_VALUE
`undef CA53_DBGDEVID1_READ_VALUE
`undef CA53_DBGDEVID2_READ_VALUE
`undef CA53_EDDEVID_READ_VALUE
`undef CA53_EDDEVID1_READ_VALUE
`undef CA53_EDDEVID2_READ_VALUE
`undef CA53_EDDEVARCH_READ_VALUE
`undef CA53_EDDEVTYPE_READ_VALUE
`undef CA53_ECC_ODD
`undef CA53_ECC_EVEN
`undef CA53_FAULT_VMSA_ALIGNMENT
`undef CA53_FAULT_VMSA_PAGEWALK_EXT1_DEC
`undef CA53_FAULT_VMSA_PAGEWALK_EXT1_SLV
`undef CA53_FAULT_VMSA_PAGEWALK_EXT1_ECC
`undef CA53_FAULT_VMSA_PAGEWALK_EXT2_DEC
`undef CA53_FAULT_VMSA_PAGEWALK_EXT2_SLV
`undef CA53_FAULT_VMSA_PAGEWALK_EXT2_ECC
`undef CA53_FAULT_VMSA_TRANSLATION_SEC
`undef CA53_FAULT_VMSA_TRANSLATION_PAGE
`undef CA53_FAULT_VMSA_ACCESS_SEC
`undef CA53_FAULT_VMSA_ACCESS_PAGE
`undef CA53_FAULT_VMSA_DOMAIN_SEC
`undef CA53_FAULT_VMSA_DOMAIN_PAGE
`undef CA53_FAULT_VMSA_PERMISSION_SEC
`undef CA53_FAULT_VMSA_PERMISSION_PAGE
`undef CA53_FAULT_VMSA_EXT_DEC
`undef CA53_FAULT_VMSA_EXT_SLV
`undef CA53_FAULT_VMSA_ECC
`undef CA53_FAULT_VMSA_LDREX
`undef CA53_FAULT_LPAE_ALIGNMENT
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_DEC
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L0
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L1
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L2
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_DEC_L3
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_SLV
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L0
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L1
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L2
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_SLV_L3
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_ECC
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L0
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L1
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L2
`undef CA53_FAULT_LPAE_PAGEWALK_EXT_ECC_L3
`undef CA53_FAULT_LPAE_TRANSLATION
`undef CA53_FAULT_LPAE_TRANSLATION_L0
`undef CA53_FAULT_LPAE_TRANSLATION_L1
`undef CA53_FAULT_LPAE_TRANSLATION_L2
`undef CA53_FAULT_LPAE_TRANSLATION_L3
`undef CA53_FAULT_LPAE_ACCESS
`undef CA53_FAULT_LPAE_ACCESS_L0
`undef CA53_FAULT_LPAE_ACCESS_L1
`undef CA53_FAULT_LPAE_ACCESS_L2
`undef CA53_FAULT_LPAE_ACCESS_L3
`undef CA53_FAULT_LPAE_PERMISSION
`undef CA53_FAULT_LPAE_PERMISSION_L0
`undef CA53_FAULT_LPAE_PERMISSION_L1
`undef CA53_FAULT_LPAE_PERMISSION_L2
`undef CA53_FAULT_LPAE_PERMISSION_L3
`undef CA53_FAULT_LPAE_DOMAIN
`undef CA53_FAULT_LPAE_DOMAIN_L1
`undef CA53_FAULT_LPAE_DOMAIN_L2
`undef CA53_FAULT_LPAE_ADDR_SIZE
`undef CA53_FAULT_LPAE_ADDR_SIZE_L0
`undef CA53_FAULT_LPAE_ADDR_SIZE_L1
`undef CA53_FAULT_LPAE_ADDR_SIZE_L2
`undef CA53_FAULT_LPAE_ADDR_SIZE_L3
`undef CA53_FAULT_LPAE_EXT_DEC
`undef CA53_FAULT_LPAE_EXT_SLV
`undef CA53_FAULT_LPAE_LDREX
`undef CA53_FAULT_LPAE_ECC
`undef CA53_FAULT_LPAE_STACK_ALIGN
`undef CA53_FAULT_PAGEWALK_EXT
`undef CA53_FAULT_DOMAIN
`undef CA53_FAULT_ECC
`undef CA53_FAULT_ALIGNMENT
`undef CA53_FAULT_EXT
`undef CA53_FAULT_GEN_EXT
`undef CA53_FAULT_STACK_ALIGN
`undef CA53_MEM_NORMAL
`undef CA53_MEM_DEVICE
`undef CA53_MEM_DEVICE_nG
`undef CA53_MEM_nGnRnE
`undef CA53_MEM_nGnRE
`undef CA53_MEM_nGRE
`undef CA53_MEM_GRE
`undef CA53_MEM_WB
`undef CA53_MEM_WBWA
`undef CA53_MEM_WBRA
`undef CA53_MEM_WT
`undef CA53_MEM_NC
`undef CA53_MEM_OUTER_WB
`undef CA53_MEM_OUTER_WT
`undef CA53_MEM_OUTER_NC
`undef CA53_MEM_OUTER_RA
`undef CA53_MEM_OUTER_WA
`undef CA53_MEM_SHAREABLE
`undef CA53_MEM_O_SHAREABLE
`undef CA53_MEM_COHERENT
`undef CA53_MEM_COHERENT_SHAREABLE
`undef CA53_MEM_MERGEABLE
`undef CA53_MEM_REORDERABLE
`undef CA53_MEM_DEV_OVERRIDE
`undef CA53_MEM_TRANSIENT
`undef CA53_MEM_UNUSED
`undef CA53_MEM_ICACHE_DISABLED
`undef CA53_MEM_DCACHE_DISABLED
`undef CA53_MEM_DEFAULT_CACHEABLE
`undef CA53_MEM_MMUOFF_ION
`undef CA53_MEM_MMUOFF_IOFF
`undef CA53_MEM_MMUOFF_D
`undef CA53_PAGE_DEV_STAGE1_NGNRNE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE1_NGNRE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE1_NGRE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE1_GRE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE2_NGNRNE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE2_NGNRE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE2_NGRE_SHARE_OS
`undef CA53_PAGE_DEV_STAGE2_GRE_SHARE_OS
`undef CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS
`undef CA53_PAGE_INNER_NC_OUTER_WT_SHARE_NS
`undef CA53_PAGE_INNER_NC_OUTER_WT_SHARE_OS
`undef CA53_PAGE_INNER_NC_OUTER_WB_SHARE_NS
`undef CA53_PAGE_INNER_NC_OUTER_WB_SHARE_OS
`undef CA53_PAGE_INNER_WT_OUTER_NC_SHARE_NS
`undef CA53_PAGE_INNER_WT_OUTER_NC_SHARE_OS
`undef CA53_PAGE_INNER_WT_OUTER_WT_SHARE_NS
`undef CA53_PAGE_INNER_WT_OUTER_WT_SHARE_OS
`undef CA53_PAGE_INNER_WT_OUTER_WB_SHARE_NS
`undef CA53_PAGE_INNER_WT_OUTER_WB_SHARE_OS
`undef CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_NS
`undef CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_OS
`undef CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_NS
`undef CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_OS
`undef CA53_PAGE_INNER_WBWA_OUTER_WBWA_SHARE_NS
`undef CA53_PAGE_INNER_WBRA_OUTER_WBRWA_SHARE_NS
`undef CA53_PAGE_INNER_WBRA_OUTER_WBRWA_SHARE_OS
`undef CA53_PAGE_INNER_WBRWA_OUTER_WBRA_SHARE_NS
`undef CA53_PAGE_INNER_WBRWA_OUTER_WBRA_SHARE_OS
`undef CA53_LDST_SIZE_BYTE
`undef CA53_LDST_SIZE_HWORD
`undef CA53_LDST_SIZE_WORD
`undef CA53_LDST_SIZE_DWORD
`undef CA53_MOESI_INVALID
`undef CA53_MOESI_SHARED
`undef CA53_MOESI_UNIQUE_NOT_MIG
`undef CA53_MOESI_UNIQUE_MIG
`undef CA53_TAG_INVALID
`undef CA53_TAG_VALID
`undef CA53_TAG_SHARED
`undef CA53_TAG_UNIQUE
`undef CA53_TAG_MIGRATORY
`undef CA53_CP15_REG_CDBGDR0
`undef CA53_CP15_REG_CDBGDR1
`undef CA53_CP15_REG_CDBGDR2
`undef CA53_CP15_REG_CDBGDR3
`undef CA53_CP15_V2P_PAR
`undef CA53_CP15_REG_TTBR0
`undef CA53_CP15_REG_TTBR1
`undef CA53_CP15_REG_TTBR0_EL1
`undef CA53_CP15_REG_TTBR1_EL1
`undef CA53_CP15_REG_TTBCR
`undef CA53_CP15_REG_TCR_EL1
`undef CA53_CP15_REG_HTTBR
`undef CA53_CP15_REG_VTTBR
`undef CA53_CP15_REG_TTBR0_EL2
`undef CA53_CP15_REG_VTTBR_EL2
`undef CA53_CP15_REG_HTCR
`undef CA53_CP15_REG_VTCR
`undef CA53_CP15_REG_TCR_EL2
`undef CA53_CP15_REG_VTCR_EL2
`undef CA53_CP15_REG_PAR
`undef CA53_CP15_REG_PAR_EL1
`undef CA53_CP15_REG_MAIR0
`undef CA53_CP15_REG_MAIR_EL1
`undef CA53_CP15_REG_MAIR1
`undef CA53_CP15_REG_HMAIR0
`undef CA53_CP15_REG_MAIR_EL2
`undef CA53_CP15_REG_HMAIR1
`undef CA53_CP15_REG_CTXTID
`undef CA53_CP15_REG_CTXTID_EL1
`undef CA53_CP15_REG_TTBR0_EL3
`undef CA53_CP15_REG_TCR_EL3
`undef CA53_CP15_REG_MAIR_EL3
`undef CA53_CP15_REG_DBGBVR0
`undef CA53_CP15_REG_DBGBVR1
`undef CA53_CP15_REG_DBGBVR2
`undef CA53_CP15_REG_DBGBVR3
`undef CA53_CP15_REG_DBGBVR4
`undef CA53_CP15_REG_DBGBVR5
`undef CA53_CP15_REG_DBGBCR0
`undef CA53_CP15_REG_DBGBCR1
`undef CA53_CP15_REG_DBGBCR2
`undef CA53_CP15_REG_DBGBCR3
`undef CA53_CP15_REG_DBGBCR4
`undef CA53_CP15_REG_DBGBCR5
`undef CA53_CP15_REG_DBGWVR0
`undef CA53_CP15_REG_DBGWVR1
`undef CA53_CP15_REG_DBGWVR2
`undef CA53_CP15_REG_DBGWVR3
`undef CA53_CP15_REG_DBGWCR0
`undef CA53_CP15_REG_DBGWCR1
`undef CA53_CP15_REG_DBGWCR2
`undef CA53_CP15_REG_DBGWCR3
`undef CA53_CP15_REG_DBGVCR
`undef CA53_CP15_REG_DBGBXVR4
`undef CA53_CP15_REG_DBGBXVR5
`undef CA53_GICREG_PCPU
`undef CA53_GICREG_PCPU_W
`undef CA53_GICREG_PCPU_RESERVED
`undef CA53_GICREG_GICC_IAR1_EL1
`undef CA53_GICREG_GICC_IAR0_EL1
`undef CA53_GICREG_GICC_EOIR1_EL1
`undef CA53_GICREG_GICC_EOIR0_EL1
`undef CA53_GICREG_GICC_HPPIR1_EL1
`undef CA53_GICREG_GICC_HPPIR0_EL1
`undef CA53_GICREG_GICC_BPR1_EL1
`undef CA53_GICREG_GICC_BPR0_EL1
`undef CA53_GICREG_GICC_DIR_EL1
`undef CA53_GICREG_GICC_PMR_EL1
`undef CA53_GICREG_GICC_RPR
`undef CA53_GICREG_GICC_AP0R0_EL1
`undef CA53_GICREG_GICC_AP1R0_EL1
`undef CA53_GICREG_GICC_IGRPEN0_EL1
`undef CA53_GICREG_GICC_IGRPEN1_EL1
`undef CA53_GICREG_GICC_IGRPEN1_EL3
`undef CA53_GICREG_GICC_SRE_EL1
`undef CA53_GICREG_GICC_SRE_EL2
`undef CA53_GICREG_GICC_SRE_EL3
`undef CA53_GICREG_GICC_CTLR_EL1
`undef CA53_GICREG_GICC_CTLR_EL3
`undef CA53_GICREG_GICC_SGI0R_EL1
`undef CA53_GICREG_GICC_SGI1R_EL1
`undef CA53_GICREG_GICC_ASGI1R_EL1
`undef CA53_GICREG_VCPU
`undef CA53_GICREG_VCPU_W
`undef CA53_GICREG_VCPU_RESERVED
`undef CA53_GICREG_GICV_AIAR
`undef CA53_GICREG_GICV_IAR
`undef CA53_GICREG_GICV_AEOIR
`undef CA53_GICREG_GICV_EOIR
`undef CA53_GICREG_GICV_AHPPIR
`undef CA53_GICREG_GICV_HPPIR
`undef CA53_GICREG_GICH_VMCR_BPR1
`undef CA53_GICREG_GICH_VMCR_BPR0
`undef CA53_GICREG_GICV_DIR
`undef CA53_GICREG_GICH_VMCR_PMR
`undef CA53_GICREG_GICV_RPR
`undef CA53_GICREG_GICV_CTLR
`undef CA53_GICREG_GICH_APR0
`undef CA53_GICREG_GICH_APR1
`undef CA53_GICREG_GICH_VMCR_VENG0
`undef CA53_GICREG_GICH_VMCR_VENG1
`undef CA53_GICREG_GICH_HCR_SRE
`undef CA53_GICREG_GICH_HCR
`undef CA53_GICREG_GICH_VTR
`undef CA53_GICREG_GICH_VMCR
`undef CA53_GICREG_GICH_MISR
`undef CA53_GICREG_GICH_EISR
`undef CA53_GICREG_GICH_ELSR
`undef CA53_GICREG_GICH_LR0
`undef CA53_GICREG_GICH_LR1
`undef CA53_GICREG_GICH_LR2
`undef CA53_GICREG_GICH_LR3
`undef CA53_GICREG_GICH_LR0_L
`undef CA53_GICREG_GICH_LR1_L
`undef CA53_GICREG_GICH_LR2_L
`undef CA53_GICREG_GICH_LR3_L
`undef CA53_GICREG_GICH_LR0_H
`undef CA53_GICREG_GICH_LR1_H
`undef CA53_GICREG_GICH_LR2_H
`undef CA53_GICREG_GICH_LR3_H
`undef CA53_GICCP_W
`undef CA53_GICCP_GICC_IAR1_EL1
`undef CA53_GICCP_GICC_IAR0_EL1
`undef CA53_GICCP_GICC_EOIR1_EL1
`undef CA53_GICCP_GICC_EOIR0_EL1
`undef CA53_GICCP_GICC_HPPIR1_EL1
`undef CA53_GICCP_GICC_HPPIR0_EL1
`undef CA53_GICCP_GICC_BPR1_EL1
`undef CA53_GICCP_GICC_BPR0_EL1
`undef CA53_GICCP_GICC_DIR_EL1
`undef CA53_GICCP_GICC_PMR_EL1
`undef CA53_GICCP_GICC_RPR
`undef CA53_GICCP_GICC_AP0R0_EL1
`undef CA53_GICCP_GICC_AP1R0_EL1
`undef CA53_GICCP_GICC_IGRPEN0_EL1
`undef CA53_GICCP_GICC_IGRPEN1_EL1
`undef CA53_GICCP_GICC_IGRPEN1_EL3
`undef CA53_GICCP_GICC_SRE_EL1
`undef CA53_GICCP_GICC_SRE_EL2
`undef CA53_GICCP_GICC_SRE_EL3
`undef CA53_GICCP_GICC_CTLR_EL1
`undef CA53_GICCP_GICC_CTLR_EL3
`undef CA53_GICCP_GICC_SGI0R_EL1
`undef CA53_GICCP_GICC_SGI1R_EL1
`undef CA53_GICCP_GICC_ASGI1R_EL1
`undef CA53_GICCP_GICV_AIAR
`undef CA53_GICCP_GICV_IAR
`undef CA53_GICCP_GICV_AEOIR
`undef CA53_GICCP_GICV_EOIR
`undef CA53_GICCP_GICV_AHPPIR
`undef CA53_GICCP_GICV_HPPIR
`undef CA53_GICCP_GICH_VMCR_BPR1
`undef CA53_GICCP_GICH_VMCR_BPR0
`undef CA53_GICCP_GICV_DIR
`undef CA53_GICCP_GICH_VMCR_PMR
`undef CA53_GICCP_GICV_RPR
`undef CA53_GICCP_GICH_APR0
`undef CA53_GICCP_GICH_APR1
`undef CA53_GICCP_GICH_VMCR_VENG0
`undef CA53_GICCP_GICH_VMCR_VENG1
`undef CA53_GICCP_GICH_HCR_SRE
`undef CA53_GICCP_GICV_CTLR
`undef CA53_GICCP_GICH_HCR
`undef CA53_GICCP_GICH_VTR
`undef CA53_GICCP_GICH_VMCR
`undef CA53_GICCP_GICH_MISR
`undef CA53_GICCP_GICH_EISR
`undef CA53_GICCP_GICH_ELSR
`undef CA53_GICCP_GICH_LR0
`undef CA53_GICCP_GICH_LR0_L
`undef CA53_GICCP_GICH_LR0_H
`undef CA53_GICCP_GICH_LR1
`undef CA53_GICCP_GICH_LR1_L
`undef CA53_GICCP_GICH_LR1_H
`undef CA53_GICCP_GICH_LR2
`undef CA53_GICCP_GICH_LR2_L
`undef CA53_GICCP_GICH_LR2_H
`undef CA53_GICCP_GICH_LR3
`undef CA53_GICCP_GICH_LR3_L
`undef CA53_GICCP_GICH_LR3_H
`undef CA53_CPOP_W
`undef CA53_CPOP_IS_GOV
`undef CA53_CPOP_IS_GIC
`undef CA53_CPOP_IS_V2P
`undef CA53_CPOP_IS_TLBM
`undef CA53_CPOP_IS_DCM
`undef CA53_CPOP_IS_ICM
`undef CA53_CPOP_IS_BPM
`undef CA53_CPOP_IS_BAR
`undef CA53_CPOP_IS_DSB
`undef CA53_CPOP_IS_DMB
`undef CA53_CPOP_IS_DMBLD
`undef CA53_CPOP_IS_DCM_MVA
`undef CA53_CPOP_IS_DCM_SW
`undef CA53_CPOP_IS_ICM_MVA
`undef CA53_CPOP_IS_CLREX
`undef CA53_CPOP_IS_CLREX_NOP
`undef CA53_CPOP_IS_CDBG
`undef CA53_CPOP_IS_CDBG_DC
`undef CA53_CPOP_IS_CDBG_IC
`undef CA53_CPOP_IS_CDBG_TLB
`undef CA53_CPOP_IS_REG
`undef CA53_CPOP_8_IS_TLBM
`undef CA53_CPOP_8_IS_DCM
`undef CA53_CPOP_8_IS_ICM
`undef CA53_CPOP_8_IS_BPM
`undef CA53_CPOP_8_IS_BAR
`undef CA53_CPOP_8_IS_DSB
`undef CA53_CPOP_8_IS_DMB
`undef CA53_CPOP_8_IS_DMBST
`undef CA53_CPOP_8_IS_DCM_SW
`undef CA53_CPOP_8_IS_ICM_MVA
`undef CA53_CPOP_8_TLBM_IS_AA64
`undef CA53_CPOP_8_TLBM_AS_AA64
`undef CA53_CPOP_5_TLBM_AS_NON_IS
`undef CA53_CPOP_CDBGDCT
`undef CA53_CPOP_CDBGDCD
`undef CA53_CPOP_CDBGICT
`undef CA53_CPOP_CDBGICD
`undef CA53_CPOP_CDBGTD
`undef CA53_CPOP_CDBGDR0
`undef CA53_CPOP_CDBGDR1
`undef CA53_CPOP_CDBGDR2
`undef CA53_CPOP_CDBGDR3
`undef CA53_CPOP_TTBR0
`undef CA53_CPOP_TTBR0_EL1
`undef CA53_CPOP_TTBR1
`undef CA53_CPOP_TTBR1_EL1
`undef CA53_CPOP_TTBCR
`undef CA53_CPOP_TCR_EL1
`undef CA53_CPOP_HTTBR
`undef CA53_CPOP_TTBR0_EL2
`undef CA53_CPOP_VTTBR
`undef CA53_CPOP_VTTBR_EL2
`undef CA53_CPOP_HTCR
`undef CA53_CPOP_TCR_EL2
`undef CA53_CPOP_VTCR
`undef CA53_CPOP_VTCR_EL2
`undef CA53_CPOP_PAR
`undef CA53_CPOP_PAR_EL1
`undef CA53_CPOP_MAIR0
`undef CA53_CPOP_MAIR_EL1
`undef CA53_CPOP_MAIR1
`undef CA53_CPOP_HMAIR0
`undef CA53_CPOP_MAIR_EL2
`undef CA53_CPOP_HMAIR1
`undef CA53_CPOP_CONTEXTIDR
`undef CA53_CPOP_CONTEXTIDR_EL1
`undef CA53_CPOP_TTBR0_EL3
`undef CA53_CPOP_TCR_EL3
`undef CA53_CPOP_MAIR_EL3
`undef CA53_CPOP_DBGBVR0
`undef CA53_CPOP_DBGBVR1
`undef CA53_CPOP_DBGBVR2
`undef CA53_CPOP_DBGBVR3
`undef CA53_CPOP_DBGBVR4
`undef CA53_CPOP_DBGBVR5
`undef CA53_CPOP_DBGBCR0
`undef CA53_CPOP_DBGBCR1
`undef CA53_CPOP_DBGBCR2
`undef CA53_CPOP_DBGBCR3
`undef CA53_CPOP_DBGBCR4
`undef CA53_CPOP_DBGBCR5
`undef CA53_CPOP_DBGBXVR4
`undef CA53_CPOP_DBGBXVR5
`undef CA53_CPOP_DBGWVR0
`undef CA53_CPOP_DBGWVR1
`undef CA53_CPOP_DBGWVR2
`undef CA53_CPOP_DBGWVR3
`undef CA53_CPOP_DBGWCR0
`undef CA53_CPOP_DBGWCR1
`undef CA53_CPOP_DBGWCR2
`undef CA53_CPOP_DBGWCR3
`undef CA53_CPOP_DBGVCR
`undef CA53_CPOP_ATS1C
`undef CA53_CPOP_ATS12NSO
`undef CA53_CPOP_ATS1H
`undef CA53_CPOP_ATS1E01
`undef CA53_CPOP_ATS12E01
`undef CA53_CPOP_ATS1E2
`undef CA53_CPOP_ATS1E3
`undef CA53_CPOP_5_W
`undef CA53_CPOP_5_TLBIALL
`undef CA53_CPOP_5_TLBIALLIS
`undef CA53_CPOP_5_TLBIMVA
`undef CA53_CPOP_5_TLBIMVAIS
`undef CA53_CPOP_5_TLBIASID
`undef CA53_CPOP_5_TLBIASIDIS
`undef CA53_CPOP_5_TLBIMVAA
`undef CA53_CPOP_5_TLBIMVAAIS
`undef CA53_CPOP_5_TLBIMVAH
`undef CA53_CPOP_5_TLBIMVAHIS
`undef CA53_CPOP_5_TLBIALLH
`undef CA53_CPOP_5_TLBIALLHIS
`undef CA53_CPOP_5_TLBIALLNSNH
`undef CA53_CPOP_5_TLBIALLNSNHIS
`undef CA53_CPOP_5_TLBIMVAL
`undef CA53_CPOP_5_TLBIMVALIS
`undef CA53_CPOP_5_TLBIMVAAL
`undef CA53_CPOP_5_TLBIMVAALIS
`undef CA53_CPOP_5_TLBIMVALH
`undef CA53_CPOP_5_TLBIMVALHIS
`undef CA53_CPOP_5_TLBIIPAS2
`undef CA53_CPOP_5_TLBIIPAS2IS
`undef CA53_CPOP_5_TLBIIPAS2L
`undef CA53_CPOP_5_TLBIIPAS2LIS
`undef CA53_CPOP_8_W
`undef CA53_CPOP_8_TLBIALL
`undef CA53_CPOP_8_TLBIALLIS
`undef CA53_CPOP_8_TLBIMVA
`undef CA53_CPOP_8_TLBIMVAIS
`undef CA53_CPOP_8_TLBIASID
`undef CA53_CPOP_8_TLBIASIDIS
`undef CA53_CPOP_8_TLBIMVAA
`undef CA53_CPOP_8_TLBIMVAAIS
`undef CA53_CPOP_8_TLBIMVAH
`undef CA53_CPOP_8_TLBIMVAHIS
`undef CA53_CPOP_8_TLBIALLH
`undef CA53_CPOP_8_TLBIALLHIS
`undef CA53_CPOP_8_TLBIALLNSNH
`undef CA53_CPOP_8_TLBIALLNSNHIS
`undef CA53_CPOP_8_TLBIMVAL
`undef CA53_CPOP_8_TLBIMVALIS
`undef CA53_CPOP_8_TLBIMVAAL
`undef CA53_CPOP_8_TLBIMVAALIS
`undef CA53_CPOP_8_TLBIMVALH
`undef CA53_CPOP_8_TLBIMVALHIS
`undef CA53_CPOP_8_TLBIIPAS2
`undef CA53_CPOP_8_TLBIIPAS2IS
`undef CA53_CPOP_8_TLBIIPAS2L
`undef CA53_CPOP_8_TLBIIPAS2LIS
`undef CA53_CPOP_TLBIALL
`undef CA53_CPOP_TLBIALLIS
`undef CA53_CPOP_TLBIMVA
`undef CA53_CPOP_TLBIMVAIS
`undef CA53_CPOP_TLBIASID
`undef CA53_CPOP_TLBIASIDIS
`undef CA53_CPOP_TLBIMVAA
`undef CA53_CPOP_TLBIMVAAIS
`undef CA53_CPOP_TLBIMVAH
`undef CA53_CPOP_TLBIMVAHIS
`undef CA53_CPOP_TLBIALLH
`undef CA53_CPOP_TLBIALLHIS
`undef CA53_CPOP_TLBIALLNSNH
`undef CA53_CPOP_TLBIALLNSNHIS
`undef CA53_CPOP_TLBIMVAL
`undef CA53_CPOP_TLBIMVALIS
`undef CA53_CPOP_TLBIMVAAL
`undef CA53_CPOP_TLBIMVAALIS
`undef CA53_CPOP_TLBIMVALH
`undef CA53_CPOP_TLBIMVALHIS
`undef CA53_CPOP_TLBIIPAS2
`undef CA53_CPOP_TLBIIPAS2IS
`undef CA53_CPOP_TLBIIPAS2L
`undef CA53_CPOP_TLBIIPAS2LIS
`undef CA53_CPOP_5_TLBIVAE1
`undef CA53_CPOP_5_TLBIVAE1IS
`undef CA53_CPOP_5_TLBIVALE1
`undef CA53_CPOP_5_TLBIVALE1IS
`undef CA53_CPOP_5_TLBIVAAE1
`undef CA53_CPOP_5_TLBIVAAE1IS
`undef CA53_CPOP_5_TLBIVAALE1
`undef CA53_CPOP_5_TLBIVAALE1IS
`undef CA53_CPOP_5_TLBIIPAS2E1
`undef CA53_CPOP_5_TLBIIPAS2E1IS
`undef CA53_CPOP_5_TLBIIPAS2LE1
`undef CA53_CPOP_5_TLBIIPAS2LE1IS
`undef CA53_CPOP_5_TLBIVAE2
`undef CA53_CPOP_5_TLBIVAE2IS
`undef CA53_CPOP_5_TLBIVALE2
`undef CA53_CPOP_5_TLBIVALE2IS
`undef CA53_CPOP_5_TLBIVAE3
`undef CA53_CPOP_5_TLBIVAE3IS
`undef CA53_CPOP_5_TLBIVALE3
`undef CA53_CPOP_5_TLBIVALE3IS
`undef CA53_CPOP_5_TLBIASIDE1
`undef CA53_CPOP_5_TLBIASIDE1IS
`undef CA53_CPOP_5_TLBIVMALLE1
`undef CA53_CPOP_5_TLBIVMALLE1IS
`undef CA53_CPOP_5_TLBIVMALLS12E1
`undef CA53_CPOP_5_TLBIVMALLS12E1IS
`undef CA53_CPOP_5_TLBIALLE1
`undef CA53_CPOP_5_TLBIALLE1IS
`undef CA53_CPOP_5_TLBIALLE2
`undef CA53_CPOP_5_TLBIALLE2IS
`undef CA53_CPOP_5_TLBIALLE3
`undef CA53_CPOP_5_TLBIALLE3IS
`undef CA53_CPOP_8_TLBIVAE1
`undef CA53_CPOP_8_TLBIVAE1IS
`undef CA53_CPOP_8_TLBIVALE1
`undef CA53_CPOP_8_TLBIVALE1IS
`undef CA53_CPOP_8_TLBIVAAE1
`undef CA53_CPOP_8_TLBIVAAE1IS
`undef CA53_CPOP_8_TLBIVAALE1
`undef CA53_CPOP_8_TLBIVAALE1IS
`undef CA53_CPOP_8_TLBIIPAS2E1
`undef CA53_CPOP_8_TLBIIPAS2E1IS
`undef CA53_CPOP_8_TLBIIPAS2LE1
`undef CA53_CPOP_8_TLBIIPAS2LE1IS
`undef CA53_CPOP_8_TLBIVAE2
`undef CA53_CPOP_8_TLBIVAE2IS
`undef CA53_CPOP_8_TLBIVALE2
`undef CA53_CPOP_8_TLBIVALE2IS
`undef CA53_CPOP_8_TLBIVAE3
`undef CA53_CPOP_8_TLBIVAE3IS
`undef CA53_CPOP_8_TLBIVALE3
`undef CA53_CPOP_8_TLBIVALE3IS
`undef CA53_CPOP_8_TLBIASIDE1
`undef CA53_CPOP_8_TLBIASIDE1IS
`undef CA53_CPOP_8_TLBIVMALLE1
`undef CA53_CPOP_8_TLBIVMALLE1IS
`undef CA53_CPOP_8_TLBIVMALLS12E1
`undef CA53_CPOP_8_TLBIVMALLS12E1IS
`undef CA53_CPOP_8_TLBIALLE1
`undef CA53_CPOP_8_TLBIALLE1IS
`undef CA53_CPOP_8_TLBIALLE2
`undef CA53_CPOP_8_TLBIALLE2IS
`undef CA53_CPOP_8_TLBIALLE3
`undef CA53_CPOP_8_TLBIALLE3IS
`undef CA53_CPOP_TLBIVAE1
`undef CA53_CPOP_TLBIVAE1IS
`undef CA53_CPOP_TLBIVALE1
`undef CA53_CPOP_TLBIVALE1IS
`undef CA53_CPOP_TLBIVAAE1
`undef CA53_CPOP_TLBIVAAE1IS
`undef CA53_CPOP_TLBIVAALE1
`undef CA53_CPOP_TLBIVAALE1IS
`undef CA53_CPOP_TLBIIPAS2E1
`undef CA53_CPOP_TLBIIPAS2E1IS
`undef CA53_CPOP_TLBIIPAS2LE1
`undef CA53_CPOP_TLBIIPAS2LE1IS
`undef CA53_CPOP_TLBIVAE2
`undef CA53_CPOP_TLBIVAE2IS
`undef CA53_CPOP_TLBIVALE2
`undef CA53_CPOP_TLBIVALE2IS
`undef CA53_CPOP_TLBIVAE3
`undef CA53_CPOP_TLBIVAE3IS
`undef CA53_CPOP_TLBIVALE3
`undef CA53_CPOP_TLBIVALE3IS
`undef CA53_CPOP_TLBIASIDE1
`undef CA53_CPOP_TLBIASIDE1IS
`undef CA53_CPOP_TLBIVMALLE1
`undef CA53_CPOP_TLBIVMALLE1IS
`undef CA53_CPOP_TLBIVMALLS12E1
`undef CA53_CPOP_TLBIVMALLS12E1IS
`undef CA53_CPOP_TLBIALLE1
`undef CA53_CPOP_TLBIALLE1IS
`undef CA53_CPOP_TLBIALLE2
`undef CA53_CPOP_TLBIALLE2IS
`undef CA53_CPOP_TLBIALLE3
`undef CA53_CPOP_TLBIALLE3IS
`undef CA53_CPOP_CLREX
`undef CA53_CPOP_NOP
`undef CA53_CPOP_8_ICIALLUIS
`undef CA53_CPOP_8_ICIALLU
`undef CA53_CPOP_8_ICIMVAU
`undef CA53_CPOP_8_ICIVAU
`undef CA53_CPOP_8_BPIALLIS
`undef CA53_CPOP_8_BPIMVA
`undef CA53_CPOP_8_DCIMVAC
`undef CA53_CPOP_8_DCISW
`undef CA53_CPOP_8_DCCMVAC
`undef CA53_CPOP_8_DCCSW
`undef CA53_CPOP_8_DCCMVAU
`undef CA53_CPOP_8_DCCIMVAC
`undef CA53_CPOP_8_DCCISW
`undef CA53_CPOP_8_DMBNSHLD
`undef CA53_CPOP_8_DMBISHLD
`undef CA53_CPOP_8_DMBOSHLD
`undef CA53_CPOP_8_DMBLD
`undef CA53_CPOP_8_DSBNS
`undef CA53_CPOP_8_DSBIS
`undef CA53_CPOP_8_DSBOS
`undef CA53_CPOP_8_DSBSY
`undef CA53_CPOP_8_DMBNS
`undef CA53_CPOP_8_DMBIS
`undef CA53_CPOP_8_DMBOS
`undef CA53_CPOP_8_DMBSY
`undef CA53_CPOP_8_DMBNSST
`undef CA53_CPOP_8_DMBISST
`undef CA53_CPOP_8_DMBOSST
`undef CA53_CPOP_8_DMBSYST
`undef CA53_CPOP_ICIALLUIS
`undef CA53_CPOP_ICIALLU
`undef CA53_CPOP_ICIMVAU
`undef CA53_CPOP_ICIVAU
`undef CA53_CPOP_BPIALLIS
`undef CA53_CPOP_BPIMVA
`undef CA53_CPOP_DCIMVAC
`undef CA53_CPOP_DCISW
`undef CA53_CPOP_DCCMVAC
`undef CA53_CPOP_DCCSW
`undef CA53_CPOP_DCCMVAU
`undef CA53_CPOP_DCCIMVAC
`undef CA53_CPOP_DCCISW
`undef CA53_CPOP_DMBNSHLD
`undef CA53_CPOP_DMBISHLD
`undef CA53_CPOP_DMBOSHLD
`undef CA53_CPOP_DMBLD
`undef CA53_CPOP_DSBNS
`undef CA53_CPOP_DSBIS
`undef CA53_CPOP_DSBOS
`undef CA53_CPOP_DSBSY
`undef CA53_CPOP_DMBNS
`undef CA53_CPOP_DMBIS
`undef CA53_CPOP_DMBOS
`undef CA53_CPOP_DMBSY
`undef CA53_CPOP_DMBNSST
`undef CA53_CPOP_DMBISST
`undef CA53_CPOP_DMBOSST
`undef CA53_CPOP_DMBSYST
`undef CA53_CPOP_CNTFRQ_EL0
`undef CA53_CPOP_CNTPCT_EL0
`undef CA53_CPOP_CNTKCTL_EL1
`undef CA53_CPOP_CNTP_TVAL_EL0
`undef CA53_CPOP_CNTP_CTL_EL0
`undef CA53_CPOP_CNTV_TVAL_EL0
`undef CA53_CPOP_CNTV_CTL_EL0
`undef CA53_CPOP_CNTVCT_EL0
`undef CA53_CPOP_CNTP_CVAL_EL0
`undef CA53_CPOP_CNTV_CVAL_EL0
`undef CA53_CPOP_CNTVOFF_EL2
`undef CA53_CPOP_CNTHCTL_EL2
`undef CA53_CPOP_CNTHP_TVAL_EL2
`undef CA53_CPOP_CNTHP_CTL_EL2
`undef CA53_CPOP_CNTHP_CVAL_EL2
`undef CA53_CPOP_CNTPS_CTL_EL1
`undef CA53_CPOP_CNTPS_CVAL_EL1
`undef CA53_CPOP_CNTPS_TVAL_EL1
`undef CA53_CPOP_L2_ACTLR
`undef CA53_CPOP_L2_ECTLR
`undef CA53_CPOP_L2_CTLR
`undef CA53_CPOP_L2_MEM_ERR_SR
`undef CA53_CPOP_GICC_IAR1_EL1
`undef CA53_CPOP_GICC_IAR0_EL1
`undef CA53_CPOP_GICC_EOIR1_EL1
`undef CA53_CPOP_GICC_EOIR0_EL1
`undef CA53_CPOP_GICC_HPPIR1_EL1
`undef CA53_CPOP_GICC_HPPIR0_EL1
`undef CA53_CPOP_GICC_BPR1_EL1
`undef CA53_CPOP_GICC_BPR0_EL1
`undef CA53_CPOP_GICC_DIR_EL1
`undef CA53_CPOP_GICC_PMR_EL1
`undef CA53_CPOP_GICC_RPR_EL1
`undef CA53_CPOP_GICC_AP0R0_EL1
`undef CA53_CPOP_GICC_AP1R0_EL1
`undef CA53_CPOP_GICC_IGRPEN0_EL1
`undef CA53_CPOP_GICC_IGRPEN1_EL1
`undef CA53_CPOP_GICC_IGRPEN1_EL3
`undef CA53_CPOP_GICC_SRE_EL1
`undef CA53_CPOP_GICC_SRE_EL2
`undef CA53_CPOP_GICC_SRE_EL3
`undef CA53_CPOP_GICC_CTLR_EL1
`undef CA53_CPOP_GICC_CTLR_EL3
`undef CA53_CPOP_GICC_SGI0R_EL1
`undef CA53_CPOP_GICC_SGI1R_EL1
`undef CA53_CPOP_GICC_ASGI1R_EL1
`undef CA53_CPOP_GICV_IAR1
`undef CA53_CPOP_GICV_IAR0
`undef CA53_CPOP_GICV_EOIR1
`undef CA53_CPOP_GICV_EOIR0
`undef CA53_CPOP_GICV_HPPIR1
`undef CA53_CPOP_GICV_HPPIR0
`undef CA53_CPOP_GICH_VMCR_BPR1
`undef CA53_CPOP_GICH_VMCR_BPR0
`undef CA53_CPOP_GICV_DIR
`undef CA53_CPOP_GICH_VMCR_PMR
`undef CA53_CPOP_GICV_RPR
`undef CA53_CPOP_GICH_AP0R0
`undef CA53_CPOP_GICH_AP1R0
`undef CA53_CPOP_GICH_VMCR_VENG0
`undef CA53_CPOP_GICH_VMCR_VENG1
`undef CA53_CPOP_GICH_HCR_SRE
`undef CA53_CPOP_GICV_CTLR
`undef CA53_CPOP_GICH_HCR
`undef CA53_CPOP_GICH_VTR
`undef CA53_CPOP_GICH_VMCR
`undef CA53_CPOP_GICH_MISR
`undef CA53_CPOP_GICH_EISR
`undef CA53_CPOP_GICH_ELSR
`undef CA53_CPOP_GICH_LR0
`undef CA53_CPOP_GICH_LR0_L
`undef CA53_CPOP_GICH_LR0_H
`undef CA53_CPOP_GICH_LR1
`undef CA53_CPOP_GICH_LR1_L
`undef CA53_CPOP_GICH_LR1_H
`undef CA53_CPOP_GICH_LR2
`undef CA53_CPOP_GICH_LR2_L
`undef CA53_CPOP_GICH_LR2_H
`undef CA53_CPOP_GICH_LR3
`undef CA53_CPOP_GICH_LR3_L
`undef CA53_CPOP_GICH_LR3_H
`undef CA53_CPOP_8_SYNC
`undef CA53_CPOP_8_CLEANUNIQUE
`undef CA53_CPOP_8_WRITE
`undef CA53_SIZE_BYTE
`undef CA53_SIZE_HWORD
`undef CA53_SIZE_WORD
`undef CA53_SIZE_DWORD
`undef CA53_IDATA_RAM_W
`undef CA53_IDATA_WEN_W
`undef CA53_IDATA_STRB_W
`undef CA53_ITAG_RAM_W
`undef CA53_DDATA_RAM_W
`undef CA53_DDATA_WEN_W
`undef CA53_DTAG_RAM_W
`undef CA53_DDIRTY_RAM_W
`undef CA53_TLB_RAM_ADDR_W
`undef CA53_TLB_RAM_W
`undef CA53_BTAC_RAM_ADDR_W
`undef CA53_BTAC_RAM_S0D_W
`undef CA53_BTAC_RAM_S1D_W
`undef CA53_MBIST0_DATA_W
`undef CA53_MBIST1_DATA_W
`undef CA53_MBIST0_ADDR_W
`undef CA53_MBIST1_ADDR_W
`undef CA53_MBIST0_RAMARRAY_W
`undef CA53_MBIST1_RAMARRAY_W
`undef CA53_MBIST0_BE_W
`undef CA53_MBIST1_BE_W
`undef CA53_GIC_ID_W
`undef CA53_GIC_PRI_W
`undef CA53_RVBARADDR_W
`undef CA53_PADDRDBG_W
`undef CA53_PWDATADBG_W
`undef CA53_PRDATADBG_W
`undef CA53_ATREADYM_W
`undef CA53_AFVALIDM_W
`undef CA53_ATDATAM_W
`undef CA53_ATVALIDM_W
`undef CA53_ATBYTESM_W
`undef CA53_AFREADYM_W
`undef CA53_ATIDM_W
`undef CA53_SYNCREQM_W
`undef CA53_PMUEVNT_W
`undef CA53_PMUEVNT_CPU_W
`undef CA53_CTICH_W
`undef CA53_ARACTIVE_W
`undef CA53_ARVALID_W
`undef CA53_ARID_W
`undef CA53_ARTYPE_W
`undef CA53_ARATTRS_W
`undef CA53_ARWAY_W
`undef CA53_ARADDR_W
`undef CA53_ARWRAP_W
`undef CA53_ARLEN_W
`undef CA53_ARSIZE_W
`undef CA53_ARLOCK_W
`undef CA53_ARPRIV_W
`undef CA53_DRCREDIT_W
`undef CA53_DWVALID_W
`undef CA53_DWL2DB_W
`undef CA53_DWCHUNKS_W
`undef CA53_DWLAST_W
`undef CA53_DWSTRB_W
`undef CA53_DWDATA_W
`undef CA53_DWERR_W
`undef CA53_DWFATAL_W
`undef CA53_ACREADY_W
`undef CA53_CRVALID_W
`undef CA53_CRID_W
`undef CA53_CRDIRTY_W
`undef CA53_CRAGE_W
`undef CA53_CRALLOC_W
`undef CA53_CRMIG_W
`undef CA53_INV_ALL_W
`undef CA53_DVM_COMP_W
`undef CA53_REQBUFS_BUSY_W
`undef CA53_DRAIN_STB_W
`undef CA53_ARCREDIT_W
`undef CA53_ARBLOCK_W
`undef CA53_DRVALID_W
`undef CA53_DRID_W
`undef CA53_DRRESP_W
`undef CA53_DRCHUNK_W
`undef CA53_DRDATA_W
`undef CA53_RRVALID_W
`undef CA53_RRID_W
`undef CA53_RRRESP_W
`undef CA53_RRL2DB_W
`undef CA53_EVDONE_W
`undef CA53_DBEXCLVAL_W
`undef CA53_DBEXCLRSP_W
`undef CA53_DBDECERR_W
`undef CA53_DBSLVERR_W
`undef CA53_LEAVERAM_W
`undef CA53_CPUBISTEN_W
`undef CA53_CPUSEV_W
`undef CA53_ACVALID_W
`undef CA53_ACID_W
`undef CA53_ACL2DB_W
`undef CA53_ACSNOOP_W
`undef CA53_ACADDR_W
`undef CA53_ACWAY_W
`undef CA53_ETMEXT_W
`undef CA53_L1DC_SIZE_W
`undef CA53_EXCP_LEV_W
`undef CA53_CPDATA_W
`undef CA53_CPADDR_W
`undef CA53_CPSEL_W
`undef CA53_TDATA_W
`undef CA53_RET_CTL_W
`undef CA53_GOV_CPDATA_W
`undef CA53_GOV_CPADDR_W
`undef CA53_RVBARADDR_PKDED_W
`undef CA53_PADDRDBG_PKDED_W
`undef CA53_PWDATADBG_PKDED_W
`undef CA53_PRDATADBG_PKDED_W
`undef CA53_ATREADYM_PKDED_W
`undef CA53_AFVALIDM_PKDED_W
`undef CA53_ATDATAM_PKDED_W
`undef CA53_ATVALIDM_PKDED_W
`undef CA53_ATBYTESM_PKDED_W
`undef CA53_AFREADYM_PKDED_W
`undef CA53_ATIDM_PKDED_W
`undef CA53_SYNCREQM_PKDED_W
`undef CA53_PMUEVNT_PKDED_W
`undef CA53_PMUEVNT_CPU_PKDED_W
`undef CA53_CTICH_PKDED_W
`undef CA53_ARACTIVE_PKDED_W
`undef CA53_ARVALID_PKDED_W
`undef CA53_ARID_PKDED_W
`undef CA53_ARTYPE_PKDED_W
`undef CA53_ARATTRS_PKDED_W
`undef CA53_ARWAY_PKDED_W
`undef CA53_ARADDR_PKDED_W
`undef CA53_ARWRAP_PKDED_W
`undef CA53_ARLEN_PKDED_W
`undef CA53_ARSIZE_PKDED_W
`undef CA53_ARLOCK_PKDED_W
`undef CA53_ARPRIV_PKDED_W
`undef CA53_DRCREDIT_PKDED_W
`undef CA53_DWVALID_PKDED_W
`undef CA53_DWL2DB_PKDED_W
`undef CA53_DWCHUNKS_PKDED_W
`undef CA53_DWLAST_PKDED_W
`undef CA53_DWSTRB_PKDED_W
`undef CA53_DWDATA_PKDED_W
`undef CA53_DWERR_PKDED_W
`undef CA53_DWFATAL_PKDED_W
`undef CA53_ACREADY_PKDED_W
`undef CA53_CRVALID_PKDED_W
`undef CA53_CRID_PKDED_W
`undef CA53_CRDIRTY_PKDED_W
`undef CA53_CRAGE_PKDED_W
`undef CA53_CRALLOC_PKDED_W
`undef CA53_CRMIG_PKDED_W
`undef CA53_INV_ALL_PKDED_W
`undef CA53_DVM_COMP_PKDED_W
`undef CA53_REQBUFS_BUSY_PKDED_W
`undef CA53_DRAIN_STB_PKDED_W
`undef CA53_ARCREDIT_PKDED_W
`undef CA53_ARBLOCK_PKDED_W
`undef CA53_DRVALID_PKDED_W
`undef CA53_DRID_PKDED_W
`undef CA53_DRRESP_PKDED_W
`undef CA53_DRCHUNK_PKDED_W
`undef CA53_DRDATA_PKDED_W
`undef CA53_RRVALID_PKDED_W
`undef CA53_RRID_PKDED_W
`undef CA53_RRRESP_PKDED_W
`undef CA53_RRL2DB_PKDED_W
`undef CA53_EVDONE_PKDED_W
`undef CA53_DBEXCLVAL_PKDED_W
`undef CA53_DBEXCLRSP_PKDED_W
`undef CA53_DBDECERR_PKDED_W
`undef CA53_DBSLVERR_PKDED_W
`undef CA53_LEAVERAM_PKDED_W
`undef CA53_CPUBISTEN_PKDED_W
`undef CA53_CPUSEV_PKDED_W
`undef CA53_ACVALID_PKDED_W
`undef CA53_ACID_PKDED_W
`undef CA53_ACL2DB_PKDED_W
`undef CA53_ACSNOOP_PKDED_W
`undef CA53_ACADDR_PKDED_W
`undef CA53_ACWAY_PKDED_W
`undef CA53_ETMEXT_PKDED_W
`undef CA53_EXCP_LEV_PKDED_W
`undef CA53_CPDATA_PKDED_W
`undef CA53_CPADDR_PKDED_W
`undef CA53_CPSEL_PKDED_W
`undef CA53_TDATA_PKDED_W
`undef CA53_RET_CTL_PKDED_W
`undef CA53_GOV_CPDATA_PKDED_W
`undef CA53_GOV_CPADDR_PKDED_W
`undef CA53_SIZE_8K
`undef CA53_SIZE_16K
`undef CA53_SIZE_32K
`undef CA53_SIZE_64K
`undef CA53_MAX_NUM_CPUS
`undef CA53_RESP_OKAY
`undef CA53_RESP_EXOKAY
`undef CA53_RESP_SLVERR
`undef CA53_RESP_DECERR
`undef CA53_EL0
`undef CA53_EL1
`undef CA53_EL2
`undef CA53_EL3
`undef CA53_ONE_HOT_EL0
`undef CA53_ONE_HOT_EL1
`undef CA53_ONE_HOT_EL2
`undef CA53_ONE_HOT_EL3
`undef CA53_MODE_USR
`undef CA53_MODE_FIQ
`undef CA53_MODE_IRQ
`undef CA53_MODE_SVC
`undef CA53_MODE_ABT
`undef CA53_MODE_UND
`undef CA53_MODE_SYS
`undef CA53_MODE_MON
`undef CA53_MODE_HYP
`undef CA53_MODE_NONUSE
`undef CA53_FULL_MODE_USR
`undef CA53_FULL_MODE_FIQ
`undef CA53_FULL_MODE_IRQ
`undef CA53_FULL_MODE_SVC
`undef CA53_FULL_MODE_ABT
`undef CA53_FULL_MODE_UND
`undef CA53_FULL_MODE_SYS
`undef CA53_FULL_MODE_MON
`undef CA53_FULL_MODE_HYP
`undef CA53_FULL_MODE_EL0T
`undef CA53_FULL_MODE_EL1T
`undef CA53_FULL_MODE_EL1H
`undef CA53_FULL_MODE_EL2T
`undef CA53_FULL_MODE_EL2H
`undef CA53_FULL_MODE_EL3T
`undef CA53_FULL_MODE_EL3H
`undef CA53_FULL_MODE_NONUSE
`undef CA53_ONEHOT_MODE_USR_SYS
`undef CA53_ONEHOT_MODE_FIQ
`undef CA53_ONEHOT_MODE_IRQ
`undef CA53_ONEHOT_MODE_SVC
`undef CA53_ONEHOT_MODE_ABT
`undef CA53_ONEHOT_MODE_UND
`undef CA53_ONEHOT_MODE_MON
`undef CA53_ONEHOT_MODE_HYP
`undef CA53_ONEHOT_MODE_ELXT
`undef CA53_ONEHOT_MODE_EL1H
`undef CA53_ONEHOT_MODE_EL2H
`undef CA53_ONEHOT_MODE_EL3H
`undef CA53_ONEHOT_MODE_USR_SYS_BIT
`undef CA53_ONEHOT_MODE_FIQ_BIT
`undef CA53_ONEHOT_MODE_IRQ_BIT
`undef CA53_ONEHOT_MODE_SVC_BIT
`undef CA53_ONEHOT_MODE_ABT_BIT
`undef CA53_ONEHOT_MODE_UND_BIT
`undef CA53_ONEHOT_MODE_MON_BIT
`undef CA53_ONEHOT_MODE_HYP_BIT
`undef CA53_ONEHOT_MODE_ELXT_BIT
`undef CA53_ONEHOT_MODE_EL1H_BIT
`undef CA53_ONEHOT_MODE_EL2H_BIT
`undef CA53_ONEHOT_MODE_EL3H_BIT
`undef CA53_LOG2
`undef CA53_NORAM_PARAM_DECL
`undef CA53_NORAM_PARAM_INST
`undef CA53_CPU_PARAM_DECL
`undef CA53_CPU_PARAM_INST
`undef CA53_BIU_PARAM_DECL
`undef CA53_BIU_PARAM_INST
`undef CA53_DPU_PARAM_DECL
`undef CA53_DPU_PARAM_INST
`undef CA53_DCU_PARAM_DECL
`undef CA53_DCU_PARAM_INST
`undef CA53_TLB_PARAM_DECL
`undef CA53_TLB_PARAM_INST
`undef CA53_IFU_PARAM_DECL
`undef CA53_IFU_PARAM_INST
`undef CA53_SCU_PARAM_DECL
`undef CA53_SCU_PARAM_INST
`undef CA53_STB_PARAM_DECL
`undef CA53_STB_PARAM_INST
`undef CA53_L2_PARAM_DECL
`undef CA53_L2_PARAM_INST
`undef CA53_L1_RAM_PARAM_DECL
`undef CA53_L1_RAM_PARAM_INST
`undef CA53_L1D_RAM_PARAM_DECL
`undef CA53_L1D_RAM_PARAM_INST
`undef CA53_L2_RAM_PARAM_DECL
`undef CA53_L2_RAM_PARAM_INST
`undef CA53_GOVERNOR_PARAM_DECL
`undef CA53_GOVERNOR_PARAM_INST
`undef CA53_GIC_PARAM_DECL
`undef CA53_GIC_PARAM_INST
`undef CA53_SCU_RAMS_PARAM_DECL
`undef CA53_SCU_RAMS_PARAM_INST
`undef CA53_GOV_SCU_PARAM_DECL
`undef CA53_GOV_SCU_PARAM_INST
/*END*/

`endif
