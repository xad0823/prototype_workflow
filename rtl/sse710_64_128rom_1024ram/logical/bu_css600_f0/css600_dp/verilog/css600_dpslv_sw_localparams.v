//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2008-2017, 2019 Arm Limited or its affiliates.
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


localparam [7:0] SW_ST_DATAPARITY  = 8'b00000000;
localparam [7:0] SW_ST_ENDTRN0     = 8'b00000001;
localparam [7:0] SW_ST_ENDTRN1     = 8'b00000010;

localparam [7:0] SW_ST_ENDTRN2     = 8'b00000011;
localparam [7:0] SW_ST_ENDTRN3     = 8'b00000100;
localparam [7:0] SW_ST_ENDTRN4     = 8'b00000101;

localparam [7:0] SW_ST_START       = 8'b00000110;
localparam [7:0] SW_ST_AP_N_DP     = 8'b00000111;
localparam [7:0] SW_ST_R_N_W       = 8'b00001000;
localparam [7:0] SW_ST_A0          = 8'b00001001;
localparam [7:0] SW_ST_A1          = 8'b00001010;
localparam [7:0] SW_ST_PARITY      = 8'b00001011;
localparam [7:0] SW_ST_STOP        = 8'b00001100;
localparam [7:0] SW_ST_PARK        = 8'b00001101;

localparam [7:0] SW_ST_PACKET_TRN0 = 8'b00001110;
localparam [7:0] SW_ST_PACKET_TRN1 = 8'b00001111;
localparam [7:0] SW_ST_PACKET_TRN2 = 8'b00010000;

localparam [7:0] SW_ST_ACK0        = 8'b00010001;
localparam [7:0] SW_ST_ACK1        = 8'b00010010;
localparam [7:0] SW_ST_ACK2        = 8'b00010011;
localparam [7:0] SW_ST_ACKTRN0     = 8'b00010100;
localparam [7:0] SW_ST_ACKTRN1     = 8'b00010101;

localparam [7:0] SW_ST_ACKTRN2     = 8'b00010110;
localparam [7:0] SW_ST_ACKTRN3     = 8'b00010111;
localparam [7:0] SW_ST_ACKTRN4     = 8'b00011000;

localparam [7:0] SW_ST_UNUSED0     = 8'b00011001;
localparam [7:0] SW_ST_UNUSED1     = 8'b00011010;
localparam [7:0] SW_ST_UNUSED2     = 8'b00011011;
localparam [7:0] SW_ST_UNUSED3     = 8'b00011100;
localparam [7:0] SW_ST_UNUSED4     = 8'b00011101;
localparam [7:0] SW_ST_UNUSED5     = 8'b00011110;
localparam [7:0] SW_ST_UNUSED6     = 8'b00011111;
localparam [7:0] SW_ST_UNUSED7     = 8'b00100000;
localparam [7:0] SW_ST_UNUSED8     = 8'b00100001;
localparam [7:0] SW_ST_UNUSED9     = 8'b00100010;
localparam [7:0] SW_ST_UNUSED10    = 8'b00100011;
localparam [7:0] SW_ST_UNUSED11    = 8'b00100100;
localparam [7:0] SW_ST_UNUSED12    = 8'b00100101;
localparam [7:0] SW_ST_RST_START   = 8'b00100110;
localparam [7:0] SW_ST_RST_AP_N_DP = 8'b00100111;
localparam [7:0] SW_ST_RST_R_N_W   = 8'b00101000;
localparam [7:0] SW_ST_RST_A0      = 8'b00101001;
localparam [7:0] SW_ST_RST_A1      = 8'b00101010;
localparam [7:0] SW_ST_RST_PARITY  = 8'b00101011;

localparam [7:0] SW_ST_UNUSED13    = 8'b00101100;
localparam [7:0] SW_ST_UNUSED14    = 8'b00101101;
localparam [7:0] SW_ST_PACKET_TRN0_NODAT    = 8'b00101110;
localparam [7:0] SW_ST_PACKET_TRN1_NODAT    = 8'b00101111;
localparam [7:0] SW_ST_PACKET_TRN2_NODAT    = 8'b00110000;
localparam [7:0] SW_ST_ACK0_NODAT  = 8'b00110001;
localparam [7:0] SW_ST_ACK1_NODAT  = 8'b00110010;
localparam [7:0] SW_ST_ACK2_NODAT  = 8'b00110011;

localparam [7:0] SW_ST_UNUSED15    = 8'b00110100;
localparam [7:0] SW_ST_UNUSED16    = 8'b00110101;
localparam [7:0] SW_ST_UNUSED17    = 8'b00110110;
localparam [7:0] SW_ST_UNUSED18    = 8'b00110111;
localparam [7:0] SW_ST_UNUSED19    = 8'b00111000;
localparam [7:0] SW_ST_UNUSED20    = 8'b00111001;
localparam [7:0] SW_ST_UNUSED21    = 8'b00111010;
localparam [7:0] SW_ST_UNUSED22    = 8'b00111011;
localparam [7:0] SW_ST_UNUSED23    = 8'b00111100;
localparam [7:0] SW_ST_UNUSED24    = 8'b00111101;
localparam [7:0] SW_ST_UNUSED25    = 8'b00111110;
localparam [7:0] SW_ST_UNUSED26    = 8'b00111111;

localparam [7:0] SW_ST_UNUSED27    = 8'b01000000;
localparam [7:0] SW_ST_UNUSED28    = 8'b01000001;
localparam [7:0] SW_ST_UNUSED29    = 8'b01000010;
localparam [7:0] SW_ST_UNUSED30    = 8'b01000011;
localparam [7:0] SW_ST_UNUSED31    = 8'b01000100;
localparam [7:0] SW_ST_UNUSED32    = 8'b01000101;
localparam [7:0] SW_ST_UNUSED33    = 8'b01000110;
localparam [7:0] SW_ST_UNUSED34    = 8'b01000111;
localparam [7:0] SW_ST_UNUSED35    = 8'b01001000;
localparam [7:0] SW_ST_UNUSED36    = 8'b01001001;
localparam [7:0] SW_ST_UNUSED37    = 8'b01001010;
localparam [7:0] SW_ST_UNUSED38    = 8'b01001011;
localparam [7:0] SW_ST_UNUSED39    = 8'b01001100;
localparam [7:0] SW_ST_UNUSED40    = 8'b01001101;
localparam [7:0] SW_ST_UNUSED41    = 8'b01001110;
localparam [7:0] SW_ST_UNUSED42    = 8'b01001111;
localparam [7:0] SW_ST_UNUSED43    = 8'b01010000;
localparam [7:0] SW_ST_UNUSED44    = 8'b01010001;
localparam [7:0] SW_ST_UNUSED45    = 8'b01010010;
localparam [7:0] SW_ST_UNUSED46    = 8'b01010011;
localparam [7:0] SW_ST_UNUSED47    = 8'b01010100;
localparam [7:0] SW_ST_UNUSED48    = 8'b01010101;
localparam [7:0] SW_ST_UNUSED49    = 8'b01010110;
localparam [7:0] SW_ST_UNUSED50    = 8'b01010111;
localparam [7:0] SW_ST_UNUSED51    = 8'b01011000;
localparam [7:0] SW_ST_UNUSED52    = 8'b01011001;
localparam [7:0] SW_ST_UNUSED53    = 8'b01011010;
localparam [7:0] SW_ST_UNUSED54    = 8'b01011011;
localparam [7:0] SW_ST_UNUSED55    = 8'b01011100;
localparam [7:0] SW_ST_UNUSED56    = 8'b01011101;
localparam [7:0] SW_ST_UNUSED57    = 8'b01011110;
localparam [7:0] SW_ST_UNUSED58    = 8'b01011111;

localparam [7:0] SW_ST_DATA0       = 8'b01100000;
localparam [7:0] SW_ST_DATA1       = 8'b01100001;
localparam [7:0] SW_ST_DATA2       = 8'b01100010;
localparam [7:0] SW_ST_DATA3       = 8'b01100011;
localparam [7:0] SW_ST_DATA4       = 8'b01100100;
localparam [7:0] SW_ST_DATA5       = 8'b01100101;
localparam [7:0] SW_ST_DATA6       = 8'b01100110;
localparam [7:0] SW_ST_DATA7       = 8'b01100111;
localparam [7:0] SW_ST_DATA8       = 8'b01101000;
localparam [7:0] SW_ST_DATA9       = 8'b01101001;
localparam [7:0] SW_ST_DATA10      = 8'b01101010;
localparam [7:0] SW_ST_DATA11      = 8'b01101011;
localparam [7:0] SW_ST_DATA12      = 8'b01101100;
localparam [7:0] SW_ST_DATA13      = 8'b01101101;
localparam [7:0] SW_ST_DATA14      = 8'b01101110;
localparam [7:0] SW_ST_DATA15      = 8'b01101111;
localparam [7:0] SW_ST_DATA16      = 8'b01110000;
localparam [7:0] SW_ST_DATA17      = 8'b01110001;
localparam [7:0] SW_ST_DATA18      = 8'b01110010;
localparam [7:0] SW_ST_DATA19      = 8'b01110011;
localparam [7:0] SW_ST_DATA20      = 8'b01110100;
localparam [7:0] SW_ST_DATA21      = 8'b01110101;
localparam [7:0] SW_ST_DATA22      = 8'b01110110;
localparam [7:0] SW_ST_DATA23      = 8'b01110111;
localparam [7:0] SW_ST_DATA24      = 8'b01111000;
localparam [7:0] SW_ST_DATA25      = 8'b01111001;
localparam [7:0] SW_ST_DATA26      = 8'b01111010;
localparam [7:0] SW_ST_DATA27      = 8'b01111011;
localparam [7:0] SW_ST_DATA28      = 8'b01111100;
localparam [7:0] SW_ST_DATA29      = 8'b01111101;
localparam [7:0] SW_ST_DATA30      = 8'b01111110;
localparam [7:0] SW_ST_DATA31      = 8'b01111111;

localparam [7:0] SW_ST_RST_0       = 8'b10000000;
localparam [7:0] SW_ST_RST_1       = 8'b10000001;
localparam [7:0] SW_ST_RST_2       = 8'b10000010;
localparam [7:0] SW_ST_RST_3       = 8'b10000011;
localparam [7:0] SW_ST_RST_4       = 8'b10000100;
localparam [7:0] SW_ST_RST_5       = 8'b10000101;
localparam [7:0] SW_ST_RST_6       = 8'b10000110;
localparam [7:0] SW_ST_RST_7       = 8'b10000111;
localparam [7:0] SW_ST_RST_8       = 8'b10001000;
localparam [7:0] SW_ST_RST_9       = 8'b10001001;
localparam [7:0] SW_ST_RST_10      = 8'b10001010;
localparam [7:0] SW_ST_RST_11      = 8'b10001011;
localparam [7:0] SW_ST_RST_12      = 8'b10001100;
localparam [7:0] SW_ST_RST_13      = 8'b10001101;
localparam [7:0] SW_ST_RST_14      = 8'b10001110;
localparam [7:0] SW_ST_RST_15      = 8'b10001111;
localparam [7:0] SW_ST_RST_16      = 8'b10010000;
localparam [7:0] SW_ST_RST_17      = 8'b10010001;
localparam [7:0] SW_ST_RST_18      = 8'b10010010;
localparam [7:0] SW_ST_RST_19      = 8'b10010011;
localparam [7:0] SW_ST_RST_20      = 8'b10010100;
localparam [7:0] SW_ST_RST_21      = 8'b10010101;
localparam [7:0] SW_ST_RST_22      = 8'b10010110;
localparam [7:0] SW_ST_RST_23      = 8'b10010111;
localparam [7:0] SW_ST_RST_24      = 8'b10011000;
localparam [7:0] SW_ST_RST_25      = 8'b10011001;
localparam [7:0] SW_ST_RST_26      = 8'b10011010;
localparam [7:0] SW_ST_RST_27      = 8'b10011011;
localparam [7:0] SW_ST_RST_28      = 8'b10011100;
localparam [7:0] SW_ST_RST_29      = 8'b10011101;
localparam [7:0] SW_ST_RST_30      = 8'b10011110;
localparam [7:0] SW_ST_RST_31      = 8'b10011111;
localparam [7:0] SW_ST_RST_32      = 8'b10100000;
localparam [7:0] SW_ST_RST_33      = 8'b10100001;
localparam [7:0] SW_ST_RST_34      = 8'b10100010;
localparam [7:0] SW_ST_RST_35      = 8'b10100011;
localparam [7:0] SW_ST_RST_36      = 8'b10100100;
localparam [7:0] SW_ST_RST_37      = 8'b10100101;
localparam [7:0] SW_ST_RST_38      = 8'b10100110;
localparam [7:0] SW_ST_RST_39      = 8'b10100111;
localparam [7:0] SW_ST_RST_40      = 8'b10101000;
localparam [7:0] SW_ST_RST_41      = 8'b10101001;
localparam [7:0] SW_ST_RST_42      = 8'b10101010;
localparam [7:0] SW_ST_RST_43      = 8'b10101011;
localparam [7:0] SW_ST_RST_44      = 8'b10101100;
localparam [7:0] SW_ST_RST_45      = 8'b10101101;
localparam [7:0] SW_ST_RST_46      = 8'b10101110;
localparam [7:0] SW_ST_RST_47      = 8'b10101111;
localparam [7:0] SW_ST_RST_48      = 8'b10110000;
localparam [7:0] SW_ST_RST_49      = 8'b10110001;
localparam [7:0] SW_ST_RST_50      = 8'b10110010;

localparam [7:0] SW_ST_UNUSED59    = 8'b10110011;
localparam [7:0] SW_ST_UNUSED60    = 8'b10110100;
localparam [7:0] SW_ST_UNUSED61    = 8'b10110101;
localparam [7:0] SW_ST_UNUSED62    = 8'b10110110;
localparam [7:0] SW_ST_UNUSED63    = 8'b10110111;
localparam [7:0] SW_ST_UNUSED64    = 8'b10111000;
localparam [7:0] SW_ST_UNUSED65    = 8'b10111001;
localparam [7:0] SW_ST_UNUSED66    = 8'b10111010;
localparam [7:0] SW_ST_UNUSED67    = 8'b10111011;
localparam [7:0] SW_ST_UNUSED68    = 8'b10111100;
localparam [7:0] SW_ST_UNUSED69    = 8'b10111101;
localparam [7:0] SW_ST_UNUSED70    = 8'b10111110;
localparam [7:0] SW_ST_UNUSED71    = 8'b10111111;
localparam [7:0] SW_ST_UNUSED72    = 8'b11000000;
localparam [7:0] SW_ST_UNUSED73    = 8'b11000001;
localparam [7:0] SW_ST_UNUSED74    = 8'b11000010;
localparam [7:0] SW_ST_UNUSED75    = 8'b11000011;
localparam [7:0] SW_ST_UNUSED76    = 8'b11000100;
localparam [7:0] SW_ST_UNUSED77    = 8'b11000101;
localparam [7:0] SW_ST_UNUSED78    = 8'b11000110;
localparam [7:0] SW_ST_UNUSED79    = 8'b11000111;
localparam [7:0] SW_ST_UNUSED80    = 8'b11001000;
localparam [7:0] SW_ST_UNUSED81    = 8'b11001001;
localparam [7:0] SW_ST_UNUSED82    = 8'b11001010;
localparam [7:0] SW_ST_UNUSED83    = 8'b11001011;
localparam [7:0] SW_ST_UNUSED84    = 8'b11001100;
localparam [7:0] SW_ST_UNUSED85    = 8'b11001101;
localparam [7:0] SW_ST_UNUSED86    = 8'b11001110;
localparam [7:0] SW_ST_UNUSED87    = 8'b11001111;
localparam [7:0] SW_ST_UNUSED88    = 8'b11010000;
localparam [7:0] SW_ST_UNUSED89    = 8'b11010001;
localparam [7:0] SW_ST_UNUSED90    = 8'b11010010;
localparam [7:0] SW_ST_UNUSED91    = 8'b11010011;
localparam [7:0] SW_ST_UNUSED92    = 8'b11010100;
localparam [7:0] SW_ST_UNUSED93    = 8'b11010101;
localparam [7:0] SW_ST_UNUSED94    = 8'b11010110;
localparam [7:0] SW_ST_UNUSED95    = 8'b11010111;
localparam [7:0] SW_ST_UNUSED96    = 8'b11011000;
localparam [7:0] SW_ST_UNUSED97    = 8'b11011001;
localparam [7:0] SW_ST_UNUSED98    = 8'b11011010;
localparam [7:0] SW_ST_UNUSED99    = 8'b11011011;
localparam [7:0] SW_ST_UNUSED100   = 8'b11011100;
localparam [7:0] SW_ST_UNUSED101   = 8'b11011101;
localparam [7:0] SW_ST_UNUSED102   = 8'b11011110;
localparam [7:0] SW_ST_UNUSED103   = 8'b11011111;
localparam [7:0] SW_ST_UNUSED104   = 8'b11100000;
localparam [7:0] SW_ST_UNUSED105   = 8'b11100001;
localparam [7:0] SW_ST_UNUSED106   = 8'b11100010;
localparam [7:0] SW_ST_UNUSED107   = 8'b11100011;
localparam [7:0] SW_ST_UNUSED108   = 8'b11100100;
localparam [7:0] SW_ST_UNUSED109   = 8'b11100101;
localparam [7:0] SW_ST_UNUSED110   = 8'b11100110;
localparam [7:0] SW_ST_UNUSED111   = 8'b11100111;
localparam [7:0] SW_ST_UNUSED112   = 8'b11101000;
localparam [7:0] SW_ST_UNUSED113   = 8'b11101001;
localparam [7:0] SW_ST_UNUSED114   = 8'b11101010;
localparam [7:0] SW_ST_UNUSED115   = 8'b11101011;
localparam [7:0] SW_ST_UNUSED116   = 8'b11101100;
localparam [7:0] SW_ST_UNUSED117   = 8'b11101101;
localparam [7:0] SW_ST_UNUSED118   = 8'b11101110;
localparam [7:0] SW_ST_UNUSED119   = 8'b11101111;
localparam [7:0] SW_ST_UNUSED120   = 8'b11110000;
localparam [7:0] SW_ST_UNUSED121   = 8'b11110001;
localparam [7:0] SW_ST_UNUSED122   = 8'b11110010;
localparam [7:0] SW_ST_UNUSED123   = 8'b11110011;
localparam [7:0] SW_ST_UNUSED124   = 8'b11110100;
localparam [7:0] SW_ST_UNUSED125   = 8'b11110101;
localparam [7:0] SW_ST_UNUSED126   = 8'b11110110;
localparam [7:0] SW_ST_UNUSED127   = 8'b11110111;
localparam [7:0] SW_ST_UNUSED128   = 8'b11111000;
localparam [7:0] SW_ST_UNUSED129   = 8'b11111001;
localparam [7:0] SW_ST_UNUSED130   = 8'b11111010;
localparam [7:0] SW_ST_UNUSED131   = 8'b11111011;
localparam [7:0] SW_ST_UNUSED132   = 8'b11111100;
localparam [7:0] SW_ST_UNUSED133   = 8'b11111101;
localparam [7:0] SW_ST_UNUSED134   = 8'b11111110;
localparam [7:0] SW_ST_UNUSED135   = 8'b11111111;

localparam [7:0] SW_ST_ACK_MASK    = 8'b11011111;

localparam [7:0] SW_ST_HDR_MASK    = 8'b11011111;

localparam [1:0] SW_REGADDR_DPIDR     = 2'b00;
localparam [1:0] SW_REGADDR_DPIDR1    = 2'b00;
localparam [1:0] SW_REGADDR_ABORT     = 2'b00;
localparam [1:0] SW_REGADDR_CTRLSTAT  = 2'b01;
localparam [1:0] SW_REGADDR_RDBUFF    = 2'b11;
localparam [1:0] SW_REGADDR_TARGETSEL = 2'b11;

localparam [3:0] SW_DPBANK_DPIDR     = 4'b0000;
localparam [3:0] SW_DPBANK_DPIDR1    = 4'b0001;
localparam [3:0] SW_DPBANK_CTRLSTAT  = 4'b0000;

localparam [2:0] BUS_IDLE            = 3'd0;
localparam [2:0] BUS_UNUSED1         = 3'd1;
localparam [2:0] BUS_RREQ            = 3'd2;
localparam [2:0] BUS_RACK            = 3'd3;
localparam [2:0] BUS_UNUSED4         = 3'd4;
localparam [2:0] BUS_UNUSED5         = 3'd5;
localparam [2:0] BUS_WREQ            = 3'd6;
localparam [2:0] BUS_WACK            = 3'd7;

localparam [1:0] SWACK_OK      = 2'd1;
localparam [1:0] SWACK_WAIT    = 2'd2;
localparam [1:0] SWACK_FAULT   = 2'd3;

