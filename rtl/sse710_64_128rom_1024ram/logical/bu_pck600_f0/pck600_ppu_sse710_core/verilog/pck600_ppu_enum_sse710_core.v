// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


localparam P_UNUSED_15 = 4'b1111;
localparam P_UNUSED_14 = 4'b1110;
localparam P_UNUSED_13 = 4'b1101;
localparam P_UNUSED_12 = 4'b1100;
localparam P_UNUSED_11 = 4'b1011;
localparam P_DBG_RECOV = 4'b1010;
localparam P_WRM_RST = 4'b1001;
localparam P_ON = 4'b1000;
localparam P_FUNC_RET = 4'b0111;
localparam P_MEM_OFF = 4'b0110;
localparam P_FULL_RET = 4'b0101;
localparam P_LGC_RET = 4'b0100;
localparam P_MEM_RET_EMU = 4'b0011;
localparam P_MEM_RET = 4'b0010;
localparam P_OFF_EMU = 4'b0001;
localparam P_OFF = 4'b0000;

localparam PPUHWSTAT_DBG_RECOV = 16'h0400;
localparam PPUHWSTAT_WRM_RST = 16'h0200;
localparam PPUHWSTAT_ON = 16'h0100;
localparam PPUHWSTAT_FUNC_RET = 16'h0080;
localparam PPUHWSTAT_MEM_OFF = 16'h0040;
localparam PPUHWSTAT_FULL_RET = 16'h0020;
localparam PPUHWSTAT_LGC_RET = 16'h0010;
localparam PPUHWSTAT_MEM_RET_EMU = 16'h0008;
localparam PPUHWSTAT_MEM_RET = 16'h0004;
localparam PPUHWSTAT_OFF_EMU = 16'h0002;
localparam PPUHWSTAT_OFF = 16'h0001;

localparam EMU2NON_EMU = 5'h00;
localparam H2L_DCIRP = 5'h01;
localparam H2L_DCIR = 5'h02;
localparam H2L_DP = 5'h03;
localparam L2H_PICDD = 5'h04;
localparam L2H_PICRD = 5'h05;
localparam L2H_ICRD = 5'h06;
localparam L2H_PD = 5'h07;
localparam ON_WARM_NO_DEV = 5'h08;
localparam ON_WARM_DEV = 5'h09;
localparam WARM_ON_NO_DEV = 5'h0A;
localparam WARM_ON_DEV = 5'h0B;
localparam PCSM_ONLY = 5'h0C;
localparam OFF_EMU_MEM_RET_EMU = 5'h0D;
localparam DBG_RECOV_PICD = 5'h0E;
localparam DBG_RECOV_ICD = 5'h0F;
localparam DBG_RECOV_PICDR = 5'h10;
localparam DBG_RECOV_PDR = 5'h11;
localparam DBG_RECOV_DR = 5'h12;
localparam DBG_RECOV_D = 5'h13;
localparam DBG_RECOV_POR_PIC = 5'h14;
localparam DBG_RECOV_POR_ICR = 5'h15;
localparam DBG_RECOV_POR_PICR = 5'h16;
localparam DBG_RECOV_POR_PR = 5'h17;
localparam DBG_RECOV_POR_R = 5'h18;
localparam DBG_RECOV_ON = 5'h19;
localparam DBG_RECOV_POR_ON = 5'h1A;
localparam UPDATE_ST = 5'h1B;
