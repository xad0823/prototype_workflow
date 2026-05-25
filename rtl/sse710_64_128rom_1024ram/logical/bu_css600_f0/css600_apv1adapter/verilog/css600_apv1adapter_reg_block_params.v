//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Parameters for css600_apv1adapter
//
//----------------------------------------------------------------------------


localparam REGA_ITSTATUS          = 12'hEFC;
localparam REGA_ITCONTROL          = 12'hF00;
localparam REGA_CLAIMSET          = 12'hFA0;
localparam REGA_CLAIMCLR          = 12'hFA4;
localparam REGA_DEVARCH          = 12'hFBC;
localparam REGA_DEVTYPE          = 12'hFCC;
localparam REGA_PIDR0          = 12'hFE0;
localparam REGA_PIDR1          = 12'hFE4;
localparam REGA_PIDR2          = 12'hFE8;
localparam REGA_PIDR3          = 12'hFEC;
localparam REGA_PIDR4          = 12'hFD0;
localparam REGA_PIDR5          = 12'hFD4;
localparam REGA_PIDR6          = 12'hFD8;
localparam REGA_PIDR7          = 12'hFDC;
localparam REGA_CIDR0          = 12'hFF0;
localparam REGA_CIDR1          = 12'hFF4;
localparam REGA_CIDR2          = 12'hFF8;
localparam REGA_CIDR3          = 12'hFFC;


localparam REG_ITDPABORT_MSB       = 0;
localparam REG_ITDPABORT_SLICE_LSB = 0;
localparam REG_ITDPABORT_SLICE_MSB = 0;


localparam REG_IME_MSB       = 0;
localparam REG_IME_SLICE_LSB = 0;
localparam REG_IME_SLICE_MSB = 0;
localparam REG_IME_INIT      = 1'b0;


localparam REG_CLAIM_SET_MSB       = 1;
localparam REG_CLAIM_SET_SLICE_LSB = 0;
localparam REG_CLAIM_SET_SLICE_MSB = 1;


localparam REG_CLAIM_CLR_MSB       = 1;
localparam REG_CLAIM_CLR_SLICE_LSB = 0;
localparam REG_CLAIM_CLR_SLICE_MSB = 1;


localparam REG_ARCHID_MSB       = 15;
localparam REG_ARCHID_SLICE_LSB = 0;
localparam REG_ARCHID_SLICE_MSB = 15;
localparam REG_ARCHID_INIT      = 16'h0A47;


localparam REG_ARCH_REVISION_MSB       = 3;
localparam REG_ARCH_REVISION_SLICE_LSB = 16;
localparam REG_ARCH_REVISION_SLICE_MSB = 19;
localparam REG_ARCH_REVISION_INIT      = 4'h0;


localparam REG_PRESENT_MSB       = 0;
localparam REG_PRESENT_SLICE_LSB = 20;
localparam REG_PRESENT_SLICE_MSB = 20;
localparam REG_PRESENT_INIT      = 1'b1;


localparam REG_ARCHITECT_MSB       = 10;
localparam REG_ARCHITECT_SLICE_LSB = 21;
localparam REG_ARCHITECT_SLICE_MSB = 31;
localparam REG_ARCHITECT_INIT      = 11'h23B;


localparam REG_MAJOR_MSB       = 3;
localparam REG_MAJOR_SLICE_LSB = 0;
localparam REG_MAJOR_SLICE_MSB = 3;
localparam REG_MAJOR_INIT      = 4'h0;


localparam REG_SUB_MSB       = 3;
localparam REG_SUB_SLICE_LSB = 4;
localparam REG_SUB_SLICE_MSB = 7;
localparam REG_SUB_INIT      = 4'h0;


localparam REG_PART_0_MSB       = 7;
localparam REG_PART_0_SLICE_LSB = 0;
localparam REG_PART_0_SLICE_MSB = 7;
localparam REG_PART_0_INIT      = 8'hE5;


localparam REG_PART_1_MSB       = 3;
localparam REG_PART_1_SLICE_LSB = 0;
localparam REG_PART_1_SLICE_MSB = 3;
localparam REG_PART_1_INIT      = 4'h9;


localparam REG_DES_0_MSB       = 3;
localparam REG_DES_0_SLICE_LSB = 4;
localparam REG_DES_0_SLICE_MSB = 7;
localparam REG_DES_0_INIT      = 4'hB;


localparam REG_DES_1_MSB       = 2;
localparam REG_DES_1_SLICE_LSB = 0;
localparam REG_DES_1_SLICE_MSB = 2;
localparam REG_DES_1_INIT      = 3'h3;


localparam REG_JEDEC_MSB       = 0;
localparam REG_JEDEC_SLICE_LSB = 3;
localparam REG_JEDEC_SLICE_MSB = 3;
localparam REG_JEDEC_INIT      = 1'b1;


localparam REG_REVISION_MSB       = 3;
localparam REG_REVISION_SLICE_LSB = 4;
localparam REG_REVISION_SLICE_MSB = 7;
localparam REG_REVISION_INIT      = 4'h0;


localparam REG_CMOD_MSB       = 3;
localparam REG_CMOD_SLICE_LSB = 0;
localparam REG_CMOD_SLICE_MSB = 3;
localparam REG_CMOD_INIT      = 4'h0;


localparam REG_REVAND_SLICE_LSB = 4;
localparam REG_REVAND_SLICE_MSB = 7;


localparam REG_DES_2_MSB       = 3;
localparam REG_DES_2_SLICE_LSB = 0;
localparam REG_DES_2_SLICE_MSB = 3;
localparam REG_DES_2_INIT      = 4'h4;


localparam REG_SIZE_MSB       = 3;
localparam REG_SIZE_SLICE_LSB = 4;
localparam REG_SIZE_SLICE_MSB = 7;
localparam REG_SIZE_INIT      = 4'h0;


localparam REG_PIDR5_MSB       = 7;
localparam REG_PIDR5_SLICE_LSB = 0;
localparam REG_PIDR5_SLICE_MSB = 7;
localparam REG_PIDR5_INIT      = 8'h00;


localparam REG_PIDR6_MSB       = 7;
localparam REG_PIDR6_SLICE_LSB = 0;
localparam REG_PIDR6_SLICE_MSB = 7;
localparam REG_PIDR6_INIT      = 8'h00;


localparam REG_PIDR7_MSB       = 7;
localparam REG_PIDR7_SLICE_LSB = 0;
localparam REG_PIDR7_SLICE_MSB = 7;
localparam REG_PIDR7_INIT      = 8'h00;


localparam REG_PRMBL_0_MSB       = 7;
localparam REG_PRMBL_0_SLICE_LSB = 0;
localparam REG_PRMBL_0_SLICE_MSB = 7;
localparam REG_PRMBL_0_INIT      = 8'h0D;


localparam REG_PRMBL_1_MSB       = 3;
localparam REG_PRMBL_1_SLICE_LSB = 0;
localparam REG_PRMBL_1_SLICE_MSB = 3;
localparam REG_PRMBL_1_INIT      = 4'h0;


localparam REG_COMP_CLASS_MSB       = 3;
localparam REG_COMP_CLASS_SLICE_LSB = 4;
localparam REG_COMP_CLASS_SLICE_MSB = 7;
localparam REG_COMP_CLASS_INIT      = 4'h9;


localparam REG_PRMBL_2_MSB       = 7;
localparam REG_PRMBL_2_SLICE_LSB = 0;
localparam REG_PRMBL_2_SLICE_MSB = 7;
localparam REG_PRMBL_2_INIT      = 8'h05;


localparam REG_PRMBL_3_MSB       = 7;
localparam REG_PRMBL_3_SLICE_LSB = 0;
localparam REG_PRMBL_3_SLICE_MSB = 7;
localparam REG_PRMBL_3_INIT      = 8'hB1;


