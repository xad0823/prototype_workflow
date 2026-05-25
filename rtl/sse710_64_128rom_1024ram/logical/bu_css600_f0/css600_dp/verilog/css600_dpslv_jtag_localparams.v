//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2008-2019 Arm Limited or its affiliates.
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
//   Parameters for css600_dp
//
//----------------------------------------------------------------------------


localparam JTAGDP_DEVICEID_IR4 = 32'h4BA06477;
localparam JTAGDP_DEVICEID_IR8 = 32'h4BA07477;

localparam [3:0] JTAG_TLR  = 4'b1111;
localparam [3:0] JTAG_RTI  = 4'b1100;
localparam [3:0] JTAG_SDS  = 4'b0111;
localparam [3:0] JTAG_CDR  = 4'b0110;
localparam [3:0] JTAG_SDR  = 4'b0010;
localparam [3:0] JTAG_E1D  = 4'b0001;
localparam [3:0] JTAG_PDR  = 4'b0011;
localparam [3:0] JTAG_E2D  = 4'b0000;
localparam [3:0] JTAG_UDR  = 4'b0101;
localparam [3:0] JTAG_SIS  = 4'b0100;
localparam [3:0] JTAG_CIR  = 4'b1110;
localparam [3:0] JTAG_SIR  = 4'b1010;
localparam [3:0] JTAG_E1I  = 4'b1001;
localparam [3:0] JTAG_PIR  = 4'b1011;
localparam [3:0] JTAG_E2I  = 4'b1000;
localparam [3:0] JTAG_UIR  = 4'b1101;

localparam [2:0] JTAG_3_ABORT  = 3'b000;
localparam [2:0] JTAG_3_DPACC  = 3'b010;
localparam [2:0] JTAG_3_APACC  = 3'b011;
localparam [2:0] JTAG_3_IDCODE = 3'b110;
localparam [2:0] JTAG_3_BYPASS = 3'b111;


localparam [JTAGDP_IRLEN-1:0] JTAG_ABORT  = {{JTAGDP_IRLEN-3{1'b1}},3'b000};
localparam [JTAGDP_IRLEN-1:0] JTAG_DPACC  = {{JTAGDP_IRLEN-3{1'b1}},3'b010};
localparam [JTAGDP_IRLEN-1:0] JTAG_APACC  = {{JTAGDP_IRLEN-3{1'b1}},3'b011};
localparam [JTAGDP_IRLEN-1:0] JTAG_IDCODE = {{JTAGDP_IRLEN-3{1'b1}},3'b110};
localparam [JTAGDP_IRLEN-1:0] JTAG_BYPASS = {{JTAGDP_IRLEN-3{1'b1}},3'b111};

    localparam [3:0] JTAG_UNSUP0 = 4'b0000;
    localparam [3:0] JTAG_UNSUP1 = 4'b0001;
    localparam [3:0] JTAG_UNSUP2 = 4'b0010;
    localparam [3:0] JTAG_UNSUP3 = 4'b0011;
    localparam [3:0] JTAG_UNSUP4 = 4'b0100;
    localparam [3:0] JTAG_UNSUP5 = 4'b0101;
    localparam [3:0] JTAG_UNSUP6 = 4'b0110;
    localparam [3:0] JTAG_UNSUP7 = 4'b0111;
    localparam [3:0] JTAG_UNSUP9 = 4'b1001;
    localparam [3:0] JTAG_UNSUPC = 4'b1100;
    localparam [3:0] JTAG_UNSUPD = 4'b1101;
    localparam [7:0] JTAG_UNSUP0_0 = 8'b0000_0000;
    localparam [7:0] JTAG_UNSUP1_0 = 8'b0000_0001;
    localparam [7:0] JTAG_UNSUP2_0 = 8'b0000_0010;
    localparam [7:0] JTAG_UNSUP3_0 = 8'b0000_0011;
    localparam [7:0] JTAG_UNSUP4_0 = 8'b0000_0100;
    localparam [7:0] JTAG_UNSUP5_0 = 8'b0000_0101;
    localparam [7:0] JTAG_UNSUP6_0 = 8'b0000_0110;
    localparam [7:0] JTAG_UNSUP7_0 = 8'b0000_0111;
    localparam [7:0] JTAG_UNSUP8_0 = 8'b0000_1000;
    localparam [7:0] JTAG_UNSUP9_0 = 8'b0000_1001;
    localparam [7:0] JTAG_UNSUPA_0 = 8'b0000_1010;
    localparam [7:0] JTAG_UNSUPB_0 = 8'b0000_1011;
    localparam [7:0] JTAG_UNSUPC_0 = 8'b0000_1100;
    localparam [7:0] JTAG_UNSUPD_0 = 8'b0000_1101;
    localparam [7:0] JTAG_UNSUPE_0 = 8'b0000_1110;
    localparam [7:0] JTAG_UNSUPF_0 = 8'b0000_1111;

    localparam [7:0] JTAG_UNSUP0_1 = 8'b0001_0000;
    localparam [7:0] JTAG_UNSUP1_1 = 8'b0001_0001;
    localparam [7:0] JTAG_UNSUP2_1 = 8'b0001_0010;
    localparam [7:0] JTAG_UNSUP3_1 = 8'b0001_0011;
    localparam [7:0] JTAG_UNSUP4_1 = 8'b0001_0100;
    localparam [7:0] JTAG_UNSUP5_1 = 8'b0001_0101;
    localparam [7:0] JTAG_UNSUP6_1 = 8'b0001_0110;
    localparam [7:0] JTAG_UNSUP7_1 = 8'b0001_0111;
    localparam [7:0] JTAG_UNSUP8_1 = 8'b0001_1000;
    localparam [7:0] JTAG_UNSUP9_1 = 8'b0001_1001;
    localparam [7:0] JTAG_UNSUPA_1 = 8'b0001_1010;
    localparam [7:0] JTAG_UNSUPB_1 = 8'b0001_1011;
    localparam [7:0] JTAG_UNSUPC_1 = 8'b0001_1100;
    localparam [7:0] JTAG_UNSUPD_1 = 8'b0001_1101;
    localparam [7:0] JTAG_UNSUPE_1 = 8'b0001_1110;
    localparam [7:0] JTAG_UNSUPF_1 = 8'b0001_1111;

    localparam [7:0] JTAG_UNSUP0_2 = 8'b0010_0000;
    localparam [7:0] JTAG_UNSUP1_2 = 8'b0010_0001;
    localparam [7:0] JTAG_UNSUP2_2 = 8'b0010_0010;
    localparam [7:0] JTAG_UNSUP3_2 = 8'b0010_0011;
    localparam [7:0] JTAG_UNSUP4_2 = 8'b0010_0100;
    localparam [7:0] JTAG_UNSUP5_2 = 8'b0010_0101;
    localparam [7:0] JTAG_UNSUP6_2 = 8'b0010_0110;
    localparam [7:0] JTAG_UNSUP7_2 = 8'b0010_0111;
    localparam [7:0] JTAG_UNSUP8_2 = 8'b0010_1000;
    localparam [7:0] JTAG_UNSUP9_2 = 8'b0010_1001;
    localparam [7:0] JTAG_UNSUPA_2 = 8'b0010_1010;
    localparam [7:0] JTAG_UNSUPB_2 = 8'b0010_1011;
    localparam [7:0] JTAG_UNSUPC_2 = 8'b0010_1100;
    localparam [7:0] JTAG_UNSUPD_2 = 8'b0010_1101;
    localparam [7:0] JTAG_UNSUPE_2 = 8'b0010_1110;
    localparam [7:0] JTAG_UNSUPF_2 = 8'b0010_1111;

    localparam [7:0] JTAG_UNSUP0_3 = 8'b0011_0000;
    localparam [7:0] JTAG_UNSUP1_3 = 8'b0011_0001;
    localparam [7:0] JTAG_UNSUP2_3 = 8'b0011_0010;
    localparam [7:0] JTAG_UNSUP3_3 = 8'b0011_0011;
    localparam [7:0] JTAG_UNSUP4_3 = 8'b0011_0100;
    localparam [7:0] JTAG_UNSUP5_3 = 8'b0011_0101;
    localparam [7:0] JTAG_UNSUP6_3 = 8'b0011_0110;
    localparam [7:0] JTAG_UNSUP7_3 = 8'b0011_0111;
    localparam [7:0] JTAG_UNSUP8_3 = 8'b0011_1000;
    localparam [7:0] JTAG_UNSUP9_3 = 8'b0011_1001;
    localparam [7:0] JTAG_UNSUPA_3 = 8'b0011_1010;
    localparam [7:0] JTAG_UNSUPB_3 = 8'b0011_1011;
    localparam [7:0] JTAG_UNSUPC_3 = 8'b0011_1100;
    localparam [7:0] JTAG_UNSUPD_3 = 8'b0011_1101;
    localparam [7:0] JTAG_UNSUPE_3 = 8'b0011_1110;
    localparam [7:0] JTAG_UNSUPF_3 = 8'b0011_1111;

    localparam [7:0] JTAG_UNSUP0_4 = 8'b0100_0000;
    localparam [7:0] JTAG_UNSUP1_4 = 8'b0100_0001;
    localparam [7:0] JTAG_UNSUP2_4 = 8'b0100_0010;
    localparam [7:0] JTAG_UNSUP3_4 = 8'b0100_0011;
    localparam [7:0] JTAG_UNSUP4_4 = 8'b0100_0100;
    localparam [7:0] JTAG_UNSUP5_4 = 8'b0100_0101;
    localparam [7:0] JTAG_UNSUP6_4 = 8'b0100_0110;
    localparam [7:0] JTAG_UNSUP7_4 = 8'b0100_0111;
    localparam [7:0] JTAG_UNSUP8_4 = 8'b0100_1000;
    localparam [7:0] JTAG_UNSUP9_4 = 8'b0100_1001;
    localparam [7:0] JTAG_UNSUPA_4 = 8'b0100_1010;
    localparam [7:0] JTAG_UNSUPB_4 = 8'b0100_1011;
    localparam [7:0] JTAG_UNSUPC_4 = 8'b0100_1100;
    localparam [7:0] JTAG_UNSUPD_4 = 8'b0100_1101;
    localparam [7:0] JTAG_UNSUPE_4 = 8'b0100_1110;
    localparam [7:0] JTAG_UNSUPF_4 = 8'b0100_1111;

    localparam [7:0] JTAG_UNSUP0_5 = 8'b0101_0000;
    localparam [7:0] JTAG_UNSUP1_5 = 8'b0101_0001;
    localparam [7:0] JTAG_UNSUP2_5 = 8'b0101_0010;
    localparam [7:0] JTAG_UNSUP3_5 = 8'b0101_0011;
    localparam [7:0] JTAG_UNSUP4_5 = 8'b0101_0100;
    localparam [7:0] JTAG_UNSUP5_5 = 8'b0101_0101;
    localparam [7:0] JTAG_UNSUP6_5 = 8'b0101_0110;
    localparam [7:0] JTAG_UNSUP7_5 = 8'b0101_0111;
    localparam [7:0] JTAG_UNSUP8_5 = 8'b0101_1000;
    localparam [7:0] JTAG_UNSUP9_5 = 8'b0101_1001;
    localparam [7:0] JTAG_UNSUPA_5 = 8'b0101_1010;
    localparam [7:0] JTAG_UNSUPB_5 = 8'b0101_1011;
    localparam [7:0] JTAG_UNSUPC_5 = 8'b0101_1100;
    localparam [7:0] JTAG_UNSUPD_5 = 8'b0101_1101;
    localparam [7:0] JTAG_UNSUPE_5 = 8'b0101_1110;
    localparam [7:0] JTAG_UNSUPF_5 = 8'b0101_1111;

    localparam [7:0] JTAG_UNSUP0_6 = 8'b0110_0000;
    localparam [7:0] JTAG_UNSUP1_6 = 8'b0110_0001;
    localparam [7:0] JTAG_UNSUP2_6 = 8'b0110_0010;
    localparam [7:0] JTAG_UNSUP3_6 = 8'b0110_0011;
    localparam [7:0] JTAG_UNSUP4_6 = 8'b0110_0100;
    localparam [7:0] JTAG_UNSUP5_6 = 8'b0110_0101;
    localparam [7:0] JTAG_UNSUP6_6 = 8'b0110_0110;
    localparam [7:0] JTAG_UNSUP7_6 = 8'b0110_0111;
    localparam [7:0] JTAG_UNSUP8_6 = 8'b0110_1000;
    localparam [7:0] JTAG_UNSUP9_6 = 8'b0110_1001;
    localparam [7:0] JTAG_UNSUPA_6 = 8'b0110_1010;
    localparam [7:0] JTAG_UNSUPB_6 = 8'b0110_1011;
    localparam [7:0] JTAG_UNSUPC_6 = 8'b0110_1100;
    localparam [7:0] JTAG_UNSUPD_6 = 8'b0110_1101;
    localparam [7:0] JTAG_UNSUPE_6 = 8'b0110_1110;
    localparam [7:0] JTAG_UNSUPF_6 = 8'b0110_1111;

    localparam [7:0] JTAG_UNSUP0_7 = 8'b0111_0000;
    localparam [7:0] JTAG_UNSUP1_7 = 8'b0111_0001;
    localparam [7:0] JTAG_UNSUP2_7 = 8'b0111_0010;
    localparam [7:0] JTAG_UNSUP3_7 = 8'b0111_0011;
    localparam [7:0] JTAG_UNSUP4_7 = 8'b0111_0100;
    localparam [7:0] JTAG_UNSUP5_7 = 8'b0111_0101;
    localparam [7:0] JTAG_UNSUP6_7 = 8'b0111_0110;
    localparam [7:0] JTAG_UNSUP7_7 = 8'b0111_0111;
    localparam [7:0] JTAG_UNSUP8_7 = 8'b0111_1000;
    localparam [7:0] JTAG_UNSUP9_7 = 8'b0111_1001;
    localparam [7:0] JTAG_UNSUPA_7 = 8'b0111_1010;
    localparam [7:0] JTAG_UNSUPB_7 = 8'b0111_1011;
    localparam [7:0] JTAG_UNSUPC_7 = 8'b0111_1100;
    localparam [7:0] JTAG_UNSUPD_7 = 8'b0111_1101;
    localparam [7:0] JTAG_UNSUPE_7 = 8'b0111_1110;
    localparam [7:0] JTAG_UNSUPF_7 = 8'b0111_1111;

    localparam [7:0] JTAG_UNSUP0_8 = 8'b1000_0000;
    localparam [7:0] JTAG_UNSUP1_8 = 8'b1000_0001;
    localparam [7:0] JTAG_UNSUP2_8 = 8'b1000_0010;
    localparam [7:0] JTAG_UNSUP3_8 = 8'b1000_0011;
    localparam [7:0] JTAG_UNSUP4_8 = 8'b1000_0100;
    localparam [7:0] JTAG_UNSUP5_8 = 8'b1000_0101;
    localparam [7:0] JTAG_UNSUP6_8 = 8'b1000_0110;
    localparam [7:0] JTAG_UNSUP7_8 = 8'b1000_0111;
    localparam [7:0] JTAG_UNSUP8_8 = 8'b1000_1000;
    localparam [7:0] JTAG_UNSUP9_8 = 8'b1000_1001;
    localparam [7:0] JTAG_UNSUPA_8 = 8'b1000_1010;
    localparam [7:0] JTAG_UNSUPB_8 = 8'b1000_1011;
    localparam [7:0] JTAG_UNSUPC_8 = 8'b1000_1100;
    localparam [7:0] JTAG_UNSUPD_8 = 8'b1000_1101;
    localparam [7:0] JTAG_UNSUPE_8 = 8'b1000_1110;
    localparam [7:0] JTAG_UNSUPF_8 = 8'b1000_1111;

    localparam [7:0] JTAG_UNSUP0_9 = 8'b1001_0000;
    localparam [7:0] JTAG_UNSUP1_9 = 8'b1001_0001;
    localparam [7:0] JTAG_UNSUP2_9 = 8'b1001_0010;
    localparam [7:0] JTAG_UNSUP3_9 = 8'b1001_0011;
    localparam [7:0] JTAG_UNSUP4_9 = 8'b1001_0100;
    localparam [7:0] JTAG_UNSUP5_9 = 8'b1001_0101;
    localparam [7:0] JTAG_UNSUP6_9 = 8'b1001_0110;
    localparam [7:0] JTAG_UNSUP7_9 = 8'b1001_0111;
    localparam [7:0] JTAG_UNSUP8_9 = 8'b1001_1000;
    localparam [7:0] JTAG_UNSUP9_9 = 8'b1001_1001;
    localparam [7:0] JTAG_UNSUPA_9 = 8'b1001_1010;
    localparam [7:0] JTAG_UNSUPB_9 = 8'b1001_1011;
    localparam [7:0] JTAG_UNSUPC_9 = 8'b1001_1100;
    localparam [7:0] JTAG_UNSUPD_9 = 8'b1001_1101;
    localparam [7:0] JTAG_UNSUPE_9 = 8'b1001_1110;
    localparam [7:0] JTAG_UNSUPF_9 = 8'b1001_1111;

    localparam [7:0] JTAG_UNSUP0_A = 8'b1010_0000;
    localparam [7:0] JTAG_UNSUP1_A = 8'b1010_0001;
    localparam [7:0] JTAG_UNSUP2_A = 8'b1010_0010;
    localparam [7:0] JTAG_UNSUP3_A = 8'b1010_0011;
    localparam [7:0] JTAG_UNSUP4_A = 8'b1010_0100;
    localparam [7:0] JTAG_UNSUP5_A = 8'b1010_0101;
    localparam [7:0] JTAG_UNSUP6_A = 8'b1010_0110;
    localparam [7:0] JTAG_UNSUP7_A = 8'b1010_0111;
    localparam [7:0] JTAG_UNSUP8_A = 8'b1010_1000;
    localparam [7:0] JTAG_UNSUP9_A = 8'b1010_1001;
    localparam [7:0] JTAG_UNSUPA_A = 8'b1010_1010;
    localparam [7:0] JTAG_UNSUPB_A = 8'b1010_1011;
    localparam [7:0] JTAG_UNSUPC_A = 8'b1010_1100;
    localparam [7:0] JTAG_UNSUPD_A = 8'b1010_1101;
    localparam [7:0] JTAG_UNSUPE_A = 8'b1010_1110;
    localparam [7:0] JTAG_UNSUPF_A = 8'b1010_1111;

    localparam [7:0] JTAG_UNSUP0_B = 8'b1011_0000;
    localparam [7:0] JTAG_UNSUP1_B = 8'b1011_0001;
    localparam [7:0] JTAG_UNSUP2_B = 8'b1011_0010;
    localparam [7:0] JTAG_UNSUP3_B = 8'b1011_0011;
    localparam [7:0] JTAG_UNSUP4_B = 8'b1011_0100;
    localparam [7:0] JTAG_UNSUP5_B = 8'b1011_0101;
    localparam [7:0] JTAG_UNSUP6_B = 8'b1011_0110;
    localparam [7:0] JTAG_UNSUP7_B = 8'b1011_0111;
    localparam [7:0] JTAG_UNSUP8_B = 8'b1011_1000;
    localparam [7:0] JTAG_UNSUP9_B = 8'b1011_1001;
    localparam [7:0] JTAG_UNSUPA_B = 8'b1011_1010;
    localparam [7:0] JTAG_UNSUPB_B = 8'b1011_1011;
    localparam [7:0] JTAG_UNSUPC_B = 8'b1011_1100;
    localparam [7:0] JTAG_UNSUPD_B = 8'b1011_1101;
    localparam [7:0] JTAG_UNSUPE_B = 8'b1011_1110;
    localparam [7:0] JTAG_UNSUPF_B = 8'b1011_1111;

    localparam [7:0] JTAG_UNSUP0_C = 8'b1100_0000;
    localparam [7:0] JTAG_UNSUP1_C = 8'b1100_0001;
    localparam [7:0] JTAG_UNSUP2_C = 8'b1100_0010;
    localparam [7:0] JTAG_UNSUP3_C = 8'b1100_0011;
    localparam [7:0] JTAG_UNSUP4_C = 8'b1100_0100;
    localparam [7:0] JTAG_UNSUP5_C = 8'b1100_0101;
    localparam [7:0] JTAG_UNSUP6_C = 8'b1100_0110;
    localparam [7:0] JTAG_UNSUP7_C = 8'b1100_0111;
    localparam [7:0] JTAG_UNSUP8_C = 8'b1100_1000;
    localparam [7:0] JTAG_UNSUP9_C = 8'b1100_1001;
    localparam [7:0] JTAG_UNSUPA_C = 8'b1100_1010;
    localparam [7:0] JTAG_UNSUPB_C = 8'b1100_1011;
    localparam [7:0] JTAG_UNSUPC_C = 8'b1100_1100;
    localparam [7:0] JTAG_UNSUPD_C = 8'b1100_1101;
    localparam [7:0] JTAG_UNSUPE_C = 8'b1100_1110;
    localparam [7:0] JTAG_UNSUPF_C = 8'b1100_1111;

    localparam [7:0] JTAG_UNSUP0_D = 8'b1101_0000;
    localparam [7:0] JTAG_UNSUP1_D = 8'b1101_0001;
    localparam [7:0] JTAG_UNSUP2_D = 8'b1101_0010;
    localparam [7:0] JTAG_UNSUP3_D = 8'b1101_0011;
    localparam [7:0] JTAG_UNSUP4_D = 8'b1101_0100;
    localparam [7:0] JTAG_UNSUP5_D = 8'b1101_0101;
    localparam [7:0] JTAG_UNSUP6_D = 8'b1101_0110;
    localparam [7:0] JTAG_UNSUP7_D = 8'b1101_0111;
    localparam [7:0] JTAG_UNSUP8_D = 8'b1101_1000;
    localparam [7:0] JTAG_UNSUP9_D = 8'b1101_1001;
    localparam [7:0] JTAG_UNSUPA_D = 8'b1101_1010;
    localparam [7:0] JTAG_UNSUPB_D = 8'b1101_1011;
    localparam [7:0] JTAG_UNSUPC_D = 8'b1101_1100;
    localparam [7:0] JTAG_UNSUPD_D = 8'b1101_1101;
    localparam [7:0] JTAG_UNSUPE_D = 8'b1101_1110;
    localparam [7:0] JTAG_UNSUPF_D = 8'b1101_1111;

    localparam [7:0] JTAG_UNSUP0_E = 8'b1110_0000;
    localparam [7:0] JTAG_UNSUP1_E = 8'b1110_0001;
    localparam [7:0] JTAG_UNSUP2_E = 8'b1110_0010;
    localparam [7:0] JTAG_UNSUP3_E = 8'b1110_0011;
    localparam [7:0] JTAG_UNSUP4_E = 8'b1110_0100;
    localparam [7:0] JTAG_UNSUP5_E = 8'b1110_0101;
    localparam [7:0] JTAG_UNSUP6_E = 8'b1110_0110;
    localparam [7:0] JTAG_UNSUP7_E = 8'b1110_0111;
    localparam [7:0] JTAG_UNSUP8_E = 8'b1110_1000;
    localparam [7:0] JTAG_UNSUP9_E = 8'b1110_1001;
    localparam [7:0] JTAG_UNSUPA_E = 8'b1110_1010;
    localparam [7:0] JTAG_UNSUPB_E = 8'b1110_1011;
    localparam [7:0] JTAG_UNSUPC_E = 8'b1110_1100;
    localparam [7:0] JTAG_UNSUPD_E = 8'b1110_1101;
    localparam [7:0] JTAG_UNSUPE_E = 8'b1110_1110;
    localparam [7:0] JTAG_UNSUPF_E = 8'b1110_1111;

    localparam [7:0] JTAG_UNSUP0_F = 8'b1111_0000;
    localparam [7:0] JTAG_UNSUP1_F = 8'b1111_0001;
    localparam [7:0] JTAG_UNSUP2_F = 8'b1111_0010;
    localparam [7:0] JTAG_UNSUP3_F = 8'b1111_0011;
    localparam [7:0] JTAG_UNSUP4_F = 8'b1111_0100;
    localparam [7:0] JTAG_UNSUP5_F = 8'b1111_0101;
    localparam [7:0] JTAG_UNSUP6_F = 8'b1111_0110;
    localparam [7:0] JTAG_UNSUP7_F = 8'b1111_0111;
    localparam [7:0] JTAG_UNSUP9_F = 8'b1111_1001;
    localparam [7:0] JTAG_UNSUPC_F = 8'b1111_1100;
    localparam [7:0] JTAG_UNSUPD_F = 8'b1111_1101;


