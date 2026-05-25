//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


localparam FW_CTRL_ONE_HOT      = 0;
localparam FW_ST_ONE_HOT        = 1;
localparam FW_SR_CTRL_ONE_HOT   = 2;
localparam LD_CTRL_ONE_HOT      = 3;
localparam PE_CTRL_ONE_HOT      = 4;
localparam PE_ST_ONE_HOT        = 5;
localparam PE_BPS_ONE_HOT       = 6;
localparam RWE_CTRL_ONE_HOT     = 7;
localparam RGN_CTRL0_ONE_HOT    = 8;
localparam RGN_CTRL1_ONE_HOT    = 9;
localparam RGN_LCTRL_ONE_HOT    = 10;
localparam RGN_ST_ONE_HOT       = 11;
localparam RGN_CFG0_ONE_HOT     = 12;
localparam RGN_CFG1_ONE_HOT     = 13;
localparam RGN_SIZE_ONE_HOT     = 14;
localparam RGN_TCFG0_ONE_HOT    = 15;
localparam RGN_TCFG1_ONE_HOT    = 16;
localparam RGN_TCFG2_ONE_HOT    = 17;
localparam RGN_MID0_ONE_HOT     = 18;
localparam RGN_MPL0_ONE_HOT     = 19;
localparam RGN_MID1_ONE_HOT     = 20;
localparam RGN_MPL1_ONE_HOT     = 21;
localparam RGN_MID2_ONE_HOT     = 22;
localparam RGN_MPL2_ONE_HOT     = 23;
localparam RGN_MID3_ONE_HOT     = 24;
localparam RGN_MPL3_ONE_HOT     = 25;
localparam FE_TAL_ONE_HOT       = 26;
localparam FE_TAU_ONE_HOT       = 27;
localparam FE_TP_ONE_HOT        = 28;
localparam FE_MID_ONE_HOT       = 29;
localparam FE_CTRL_ONE_HOT      = 30;
localparam ME_CTRL_ONE_HOT      = 31;
localparam ME_ST_ONE_HOT        = 32;
localparam EDR_TAL_ONE_HOT      = 33;
localparam EDR_TAU_ONE_HOT      = 34;
localparam EDR_TP_ONE_HOT       = 35;
localparam EDR_MID_ONE_HOT      = 36;
localparam EDR_CTRL_ONE_HOT     = 37;
localparam FC0_INT_ST_ONE_HOT   = 38;
localparam FC1_INT_ST_ONE_HOT   = 39;
localparam FC2_INT_ST_ONE_HOT   = 40;
localparam FC3_INT_ST_ONE_HOT   = 41;
localparam FC4_INT_ST_ONE_HOT   = 42;
localparam FC5_INT_ST_ONE_HOT   = 43;
localparam FC6_INT_ST_ONE_HOT   = 44;
localparam FC7_INT_ST_ONE_HOT   = 45;
localparam FC8_INT_ST_ONE_HOT   = 46;
localparam FC9_INT_ST_ONE_HOT   = 47;
localparam FC10_INT_ST_ONE_HOT  = 48;
localparam FC11_INT_ST_ONE_HOT  = 49;
localparam FC12_INT_ST_ONE_HOT  = 50;
localparam FC13_INT_ST_ONE_HOT  = 51;
localparam FC14_INT_ST_ONE_HOT  = 52;
localparam FC15_INT_ST_ONE_HOT  = 53;
localparam FC16_INT_ST_ONE_HOT  = 54;
localparam FC17_INT_ST_ONE_HOT  = 55;
localparam FC18_INT_ST_ONE_HOT  = 56;
localparam FC19_INT_ST_ONE_HOT  = 57;
localparam FC20_INT_ST_ONE_HOT  = 58;
localparam FC21_INT_ST_ONE_HOT  = 59;
localparam FC22_INT_ST_ONE_HOT  = 60;
localparam FC23_INT_ST_ONE_HOT  = 61;
localparam FC24_INT_ST_ONE_HOT  = 62;
localparam FC25_INT_ST_ONE_HOT  = 63;
localparam FC26_INT_ST_ONE_HOT  = 64;
localparam FC27_INT_ST_ONE_HOT  = 65;
localparam FC28_INT_ST_ONE_HOT  = 66;
localparam FC29_INT_ST_ONE_HOT  = 67;
localparam FC30_INT_ST_ONE_HOT  = 68;
localparam FC31_INT_ST_ONE_HOT  = 69;
localparam FW_INT_ST_ONE_HOT    = 70;
localparam FC0_INT_MSK_ONE_HOT  = 71;
localparam FC1_INT_MSK_ONE_HOT  = 72;
localparam FC2_INT_MSK_ONE_HOT  = 73;
localparam FC3_INT_MSK_ONE_HOT  = 74;
localparam FC4_INT_MSK_ONE_HOT  = 75;
localparam FC5_INT_MSK_ONE_HOT  = 76;
localparam FC6_INT_MSK_ONE_HOT  = 77;
localparam FC7_INT_MSK_ONE_HOT  = 78;
localparam FC8_INT_MSK_ONE_HOT  = 79;
localparam FC9_INT_MSK_ONE_HOT  = 80;
localparam FC10_INT_MSK_ONE_HOT = 81;
localparam FC11_INT_MSK_ONE_HOT = 82;
localparam FC12_INT_MSK_ONE_HOT = 83;
localparam FC13_INT_MSK_ONE_HOT = 84;
localparam FC14_INT_MSK_ONE_HOT = 85;
localparam FC15_INT_MSK_ONE_HOT = 86;
localparam FC16_INT_MSK_ONE_HOT = 87;
localparam FC17_INT_MSK_ONE_HOT = 88;
localparam FC18_INT_MSK_ONE_HOT = 89;
localparam FC19_INT_MSK_ONE_HOT = 90;
localparam FC20_INT_MSK_ONE_HOT = 91;
localparam FC21_INT_MSK_ONE_HOT = 92;
localparam FC22_INT_MSK_ONE_HOT = 93;
localparam FC23_INT_MSK_ONE_HOT = 94;
localparam FC24_INT_MSK_ONE_HOT = 95;
localparam FC25_INT_MSK_ONE_HOT = 96;
localparam FC26_INT_MSK_ONE_HOT = 97;
localparam FC27_INT_MSK_ONE_HOT = 98;
localparam FC28_INT_MSK_ONE_HOT = 99;
localparam FC29_INT_MSK_ONE_HOT = 100;
localparam FC30_INT_MSK_ONE_HOT = 101;
localparam FC31_INT_MSK_ONE_HOT = 102;
localparam FW_TMP_TA_ONE_HOT    = 103;
localparam FW_TMP_TP_ONE_HOT    = 104;
localparam FW_TMP_MID_ONE_HOT   = 105;
localparam FW_TMP_CTRL_ONE_HOT  = 106;
localparam FC_CAP0_ONE_HOT      = 107;
localparam FC_CAP1_ONE_HOT      = 108;
localparam FC_CAP2_ONE_HOT      = 109;
localparam FC_CAP3_ONE_HOT      = 110;
localparam FC_CFG0_ONE_HOT      = 111;
localparam FC_CFG1_ONE_HOT      = 112;
localparam FC_CFG2_ONE_HOT      = 113;
localparam FC_CFG3_ONE_HOT      = 114;
localparam IIDR_ONE_HOT         = 115;
localparam AIDR_ONE_HOT         = 116;
localparam PID4_ONE_HOT         = 117;
localparam PID0_ONE_HOT         = 118;
localparam PID1_ONE_HOT         = 119;
localparam PID2_ONE_HOT         = 120;
localparam PID3_ONE_HOT         = 121;
localparam CID0_ONE_HOT         = 122;
localparam CID1_ONE_HOT         = 123;
localparam CID2_ONE_HOT         = 124;
localparam CID3_ONE_HOT         = 125;
