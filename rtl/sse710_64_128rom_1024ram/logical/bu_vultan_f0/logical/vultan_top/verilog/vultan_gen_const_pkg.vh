// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Sep 7 10:31:46 2017 +0100
//
//      Revision            : 7406604
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------


localparam IRQ_ENABLE_SET_REG_OFFSET_PARAM = 12'b000000000000;


localparam IRQ_ENABLE_CLR_REG_OFFSET_PARAM = 12'b000000000100;


localparam IRQ_STATUS_SET_REG_OFFSET_PARAM = 12'b000000001000;


localparam IRQ_STATUS_CLR_REG_OFFSET_PARAM = 12'b000000001100;


localparam IRQ_MASKED_STATUS_REG_OFFSET_PARAM = 12'b000000010000;

localparam CTRL_REG_OFFSET_PARAM = 12'b000000010100;

localparam STATUS_REG_OFFSET_PARAM = 12'b000000011000;


localparam ADDR_REG_OFFSET_PARAM = 12'b000000011100;


localparam DATA0_REG_OFFSET_PARAM = 12'b000000100000;


localparam DATA1_REG_OFFSET_PARAM = 12'b000000100100;

localparam DATA2_REG_OFFSET_PARAM = 12'b000000101000;


localparam DATA3_REG_OFFSET_PARAM = 12'b000000101100;


localparam PIDR4_REG_OFFSET_PARAM = 12'b111111010000;
localparam PIDR4_SIZE_BIT_RESET_PARAM = 4'h0;
localparam PIDR4_DES_2_BIT_RESET_PARAM = 4'h4;

localparam PIDR0_REG_OFFSET_PARAM = 12'b111111100000;
localparam PIDR0_PART_0_BIT_RESET_PARAM = 8'h32;

localparam PIDR1_REG_OFFSET_PARAM = 12'b111111100100;
localparam PIDR1_DES_0_BIT_RESET_PARAM = 4'hb;
localparam PIDR1_PART_1_BIT_RESET_PARAM = 4'h8;

localparam PIDR2_REG_OFFSET_PARAM = 12'b111111101000;
localparam PIDR2_REVISION_BIT_RESET_PARAM = 4'h0;
localparam PIDR2_JEDEC_BIT_RESET_PARAM = 1'b1;
localparam PIDR2_DES_1_BIT_RESET_PARAM = 3'h3;

localparam PIDR3_REG_OFFSET_PARAM = 12'b111111101100;
localparam PIDR3_REVAND_BIT_RESET_PARAM = 4'b0000;
localparam PIDR3_CMOD_BIT_RESET_PARAM = 4'b0000;

localparam CIDR0_REG_OFFSET_PARAM = 12'b111111110000;
localparam CIDR0_PRMBL_0_BIT_RESET_PARAM = 8'h0d;

localparam CIDR1_REG_OFFSET_PARAM = 12'b111111110100;
localparam CIDR1_CLASS_BIT_RESET_PARAM = 4'hf;
localparam CIDR1_PRMBL_1_BIT_RESET_PARAM = 4'b0000;

localparam CIDR2_REG_OFFSET_PARAM = 12'b111111111000;
localparam CIDR2_PRMBL_2_BIT_RESET_PARAM = 8'h5;

localparam CIDR3_REG_OFFSET_PARAM = 12'b111111111100;
localparam CIDR3_PRMBL_3_BIT_RESET_PARAM = 8'hb1;
