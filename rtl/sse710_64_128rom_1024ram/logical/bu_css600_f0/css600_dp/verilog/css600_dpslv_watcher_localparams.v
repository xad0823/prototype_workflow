//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2008-2017 Arm Limited or its affiliates.
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


localparam [9:0] SWJ_ST_JTAG_SEL     = 10'b1000000000;
localparam [9:0] SWJ_ST_UNUSED0      = 10'b1000000001;
localparam [9:0] SWJ_ST_UNUSED1      = 10'b1000000010;
localparam [9:0] SWJ_ST_UNUSED2      = 10'b1000000011;
localparam [9:0] SWJ_ST_UNUSED3      = 10'b1000000100;
localparam [9:0] SWJ_ST_UNUSED4      = 10'b1000000101;
localparam [9:0] SWJ_ST_UNUSED5      = 10'b1000000110;
localparam [9:0] SWJ_ST_UNUSED6      = 10'b1000000111;
localparam [9:0] SWJ_ST_UNUSED7      = 10'b1000001000;
localparam [9:0] SWJ_ST_UNUSED8      = 10'b1000001001;
localparam [9:0] SWJ_ST_UNUSED9      = 10'b1000001010;
localparam [9:0] SWJ_ST_UNUSED10     = 10'b1000001011;
localparam [9:0] SWJ_ST_UNUSED11     = 10'b1000001100;
localparam [9:0] SWJ_ST_UNUSED12     = 10'b1000001101;
localparam [9:0] SWJ_ST_UNUSED13     = 10'b1000001110;
localparam [9:0] SWJ_ST_UNUSED14     = 10'b1000001111;
localparam [9:0] SWJ_ST_UNUSED15     = 10'b1000010000;
localparam [9:0] SWJ_ST_UNUSED16     = 10'b1000010001;
localparam [9:0] SWJ_ST_UNUSED17     = 10'b1000010010;
localparam [9:0] SWJ_ST_UNUSED18     = 10'b1000010011;
localparam [9:0] SWJ_ST_UNUSED19     = 10'b1000010100;
localparam [9:0] SWJ_ST_UNUSED20     = 10'b1000010101;
localparam [9:0] SWJ_ST_UNUSED21     = 10'b1000010110;
localparam [9:0] SWJ_ST_UNUSED22     = 10'b1000010111;
localparam [9:0] SWJ_ST_UNUSED23     = 10'b1000011000;
localparam [9:0] SWJ_ST_UNUSED24     = 10'b1000011001;
localparam [9:0] SWJ_ST_UNUSED25     = 10'b1000011010;
localparam [9:0] SWJ_ST_UNUSED26     = 10'b1000011011;
localparam [9:0] SWJ_ST_UNUSED27     = 10'b1000011100;
localparam [9:0] SWJ_ST_UNUSED28     = 10'b1000011101;
localparam [9:0] SWJ_ST_UNUSED29     = 10'b1000011110;
localparam [9:0] SWJ_ST_UNUSED30     = 10'b1000011111;

localparam [9:0] SWJ_ST_SW_SYNC      = 10'b0100000000;
localparam [9:0] SWJ_ST_SW_SEL       = 10'b0100000001;
localparam [9:0] SWJ_ST_STOD0        = 10'b0100000010;
localparam [9:0] SWJ_ST_STOD1        = 10'b0100000011;
localparam [9:0] SWJ_ST_STOD2        = 10'b0100000100;
localparam [9:0] SWJ_ST_STOD3        = 10'b0100000101;
localparam [9:0] SWJ_ST_STOD4        = 10'b0100000110;
localparam [9:0] SWJ_ST_STOD5        = 10'b0100000111;
localparam [9:0] SWJ_ST_STOD6        = 10'b0100001000;
localparam [9:0] SWJ_ST_STOD7        = 10'b0100001001;
localparam [9:0] SWJ_ST_STOD8        = 10'b0100001010;
localparam [9:0] SWJ_ST_STOD9        = 10'b0100001011;
localparam [9:0] SWJ_ST_STOD10       = 10'b0100001100;
localparam [9:0] SWJ_ST_STOD11       = 10'b0100001101;
localparam [9:0] SWJ_ST_STOD12       = 10'b0100001110;
localparam [9:0] SWJ_ST_STOD13       = 10'b0100001111;

localparam [9:0] SWJ_ST_UNUSED31     = 10'b0100010000;
localparam [9:0] SWJ_ST_UNUSED32     = 10'b0100010001;
localparam [9:0] SWJ_ST_UNUSED33     = 10'b0100010010;
localparam [9:0] SWJ_ST_UNUSED34     = 10'b0100010011;
localparam [9:0] SWJ_ST_UNUSED35     = 10'b0100010100;
localparam [9:0] SWJ_ST_UNUSED36     = 10'b0100010101;
localparam [9:0] SWJ_ST_UNUSED37     = 10'b0100010110;
localparam [9:0] SWJ_ST_UNUSED38     = 10'b0100010111;
localparam [9:0] SWJ_ST_UNUSED39     = 10'b0100011000;
localparam [9:0] SWJ_ST_UNUSED40     = 10'b0100011001;
localparam [9:0] SWJ_ST_UNUSED41     = 10'b0100011010;
localparam [9:0] SWJ_ST_UNUSED42     = 10'b0100011011;
localparam [9:0] SWJ_ST_UNUSED43     = 10'b0100011100;
localparam [9:0] SWJ_ST_UNUSED44     = 10'b0100011101;
localparam [9:0] SWJ_ST_UNUSED45     = 10'b0100011110;
localparam [9:0] SWJ_ST_UNUSED46     = 10'b0100011111;

localparam [9:0] SWJ_ST_DORM_SYNC0   = 10'b0000000000;
localparam [9:0] SWJ_ST_DORM_SYNC1   = 10'b0000000001;
localparam [9:0] SWJ_ST_DORM_SYNC2   = 10'b0000000010;

localparam [9:0] SWJ_ST_ALRT0        = 10'b0000000011;
localparam [9:0] SWJ_ST_ALRT1        = 10'b0000000100;
localparam [9:0] SWJ_ST_ALRT2        = 10'b0000000101;
localparam [9:0] SWJ_ST_ACT0         = 10'b0000000110;
localparam [9:0] SWJ_ST_ACT1         = 10'b0000000111;
localparam [9:0] SWJ_ST_ACT2_JS      = 10'b0000001000;
localparam [9:0] SWJ_ST_ACT3_JS      = 10'b0000001001;
localparam [9:0] SWJ_ST_ACT4_JS      = 10'b0000001010;
localparam [9:0] SWJ_ST_ACT5_J       = 10'b0000001011;
localparam [9:0] SWJ_ST_ACT6_J       = 10'b0000001100;

localparam [9:0] SWJ_ST_ACT5_S       = 10'b0000001101;
localparam [9:0] SWJ_ST_ACT6_S       = 10'b0000001110;

localparam [9:0] SWJ_ST_ACT2_Z       = 10'b0000001111;
localparam [9:0] SWJ_ST_ACT3_Z       = 10'b0000010000;
localparam [9:0] SWJ_ST_ACT4_Z       = 10'b0000010001;
localparam [9:0] SWJ_ST_ACT5_Z       = 10'b0000010010;
localparam [9:0] SWJ_ST_ACT6_Z       = 10'b0000010011;
localparam [9:0] SWJ_ST_ACT7_Z       = 10'b0000010100;
localparam [9:0] SWJ_ST_ACT8_Z       = 10'b0000010101;
localparam [9:0] SWJ_ST_DSKIP0       = 10'b0000010110;
localparam [9:0] SWJ_ST_DSKIP1       = 10'b0000010111;
localparam [9:0] SWJ_ST_DSKIP2       = 10'b0000011000;
localparam [9:0] SWJ_ST_DSKIP3       = 10'b0000011001;
localparam [9:0] SWJ_ST_DSKIP4       = 10'b0000011010;
localparam [9:0] SWJ_ST_DSKIP5       = 10'b0000011011;
localparam [9:0] SWJ_ST_DSKIP6       = 10'b0000011100;
localparam [9:0] SWJ_ST_DSKIP7       = 10'b0000011101;
localparam [9:0] SWJ_ST_DSKIP8       = 10'b0000011110;
localparam [9:0] SWJ_ST_DSKIP9       = 10'b0000011111;
localparam [9:0] SWJ_ST_DSKIP10      = 10'b0000100000;
localparam [9:0] SWJ_ST_DSKIP11      = 10'b0000100001;
localparam [9:0] SWJ_ST_DSKIP12      = 10'b0000100010;
localparam [9:0] SWJ_ST_DSKIP13      = 10'b0000100011;
localparam [9:0] SWJ_ST_DSKIP14      = 10'b0000100100;
localparam [9:0] SWJ_ST_DSKIP15      = 10'b0000100101;
localparam [9:0] SWJ_ST_DSKIP16      = 10'b0000100110;
localparam [9:0] SWJ_ST_DSKIP17      = 10'b0000100111;
localparam [9:0] SWJ_ST_DSKIP18      = 10'b0000101000;
localparam [9:0] SWJ_ST_DSKIP19      = 10'b0000101001;
localparam [9:0] SWJ_ST_DSKIP20      = 10'b0000101010;
localparam [9:0] SWJ_ST_DSKIP21      = 10'b0000101011;
localparam [9:0] SWJ_ST_DSKIP22      = 10'b0000101100;
localparam [9:0] SWJ_ST_DSKIP23      = 10'b0000101101;
localparam [9:0] SWJ_ST_DSKIP24      = 10'b0000101110;
localparam [9:0] SWJ_ST_DZEB         = 10'b0000101111;
localparam [9:0] SWJ_ST_DZEB0        = 10'b0000110000;
localparam [9:0] SWJ_ST_DZEB1        = 10'b0000110001;
localparam [9:0] SWJ_ST_DZEBX1       = 10'b0000110010;

localparam [9:0] SWJ_ST_UNUSED47     = 10'b0000110011;
localparam [9:0] SWJ_ST_UNUSED48     = 10'b0000110100;
localparam [9:0] SWJ_ST_UNUSED49     = 10'b0000110101;
localparam [9:0] SWJ_ST_UNUSED50     = 10'b0000110110;
localparam [9:0] SWJ_ST_UNUSED51     = 10'b0000110111;
localparam [9:0] SWJ_ST_UNUSED52     = 10'b0000111000;
localparam [9:0] SWJ_ST_UNUSED53     = 10'b0000111001;
localparam [9:0] SWJ_ST_UNUSED54     = 10'b0000111010;
localparam [9:0] SWJ_ST_UNUSED55     = 10'b0000111011;
localparam [9:0] SWJ_ST_UNUSED56     = 10'b0000111100;
localparam [9:0] SWJ_ST_UNUSED57     = 10'b0000111101;
localparam [9:0] SWJ_ST_UNUSED58     = 10'b0000111110;
localparam [9:0] SWJ_ST_UNUSED59     = 10'b0000111111;

localparam [9:0] SWJ_ST_DLFSR_WAIT   = 10'b0010000000;
localparam [9:0] SWJ_ST_DLFSR_START  = 10'b0011001001;
localparam [9:0] SWJ_ST_DLFSR_END    = 10'b0010010010;

localparam [3:0] ZBS_WAIT    = 4'b0000;
localparam [3:0] ZBS0        = 4'b0001;
localparam [3:0] ZBS1        = 4'b0010;
localparam [3:0] ZBS2        = 4'b0011;
localparam [3:0] ZBS3        = 4'b0100;
localparam [3:0] ZBS4        = 4'b0101;
localparam [3:0] ZBS5        = 4'b0110;
localparam [3:0] ZBS6        = 4'b0111;
localparam [3:0] ZBS_LOCKN   = 4'b1000;
localparam [3:0] ZBS_LOCK6   = 4'b1001;
localparam [3:0] ZBS_UNUSED0 = 4'b1010;
localparam [3:0] ZBS_UNUSED1 = 4'b1100;
localparam [3:0] ZBS_UNUSED2 = 4'b1101;
localparam [3:0] ZBS_UNUSED3 = 4'b1110;
localparam [3:0] ZBS_UNUSED4 = 4'b1111;


