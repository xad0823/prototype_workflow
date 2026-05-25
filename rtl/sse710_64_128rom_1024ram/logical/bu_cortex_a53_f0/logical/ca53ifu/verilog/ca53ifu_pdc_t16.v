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
//      Checked In          : $Date: 2011-08-03 10:46:54 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180354 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : T16 predecoder. It transforms a 16 raw encoding into a 20 bit
// encoding which includes 16 bit of the original encoding, 3-sideband bits
// and identification bit
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_pdc_t16
  (input [15:0]  raw_encoding_i,
   output [2:0]  sideband_o
   );

  // -----------------------------
  // Wire declarations
  // -----------------------------
  wire [2:0]     defined_sideband;
  wire           t16_unpred_undef;

   // ------------------------------------------------------
  // Undef instruction decoder
  // ------------------------------------------------------

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19, net_0_20, net_0_21, net_0_22, net_0_23, net_0_24, net_0_25, net_0_26,
         net_0_27, net_0_28, net_0_29, net_0_30, net_0_31, net_0_32, net_0_33, net_0_34,
         net_0_35, net_0_36, net_0_37, net_0_38, net_0_39, net_0_40;

  assign t16_unpred_undef = ~(net_0_1 & net_0_2);
  assign net_0_2 = ~(net_0_3 & net_0_4);
  assign net_0_4 = ~(net_0_5 & net_0_6);
  assign net_0_6 = (raw_encoding_i[9] | net_0_7);
  assign net_0_7 = ~(net_0_8 | net_0_9);
  assign net_0_9 = (raw_encoding_i[7] & net_0_10);
  assign net_0_10 = (raw_encoding_i[1] & net_0_11);
  assign net_0_11 = (raw_encoding_i[0] & raw_encoding_i[2]);
  assign net_0_5 = ~(raw_encoding_i[7] & net_0_8);
  assign net_0_8 = (net_0_12 & net_0_13);
  assign net_0_13 = (raw_encoding_i[5] & raw_encoding_i[3]);
  assign net_0_12 = (raw_encoding_i[6] & raw_encoding_i[4]);
  assign net_0_3 = ~(raw_encoding_i[11] | net_0_14);
  assign net_0_14 = ~(net_0_15 & net_0_16);
  assign net_0_16 = (raw_encoding_i[10] & raw_encoding_i[8]);
  assign net_0_15 = ~(raw_encoding_i[13] | net_0_17);
  assign net_0_17 = ~(raw_encoding_i[14] & net_0_18);
  assign net_0_18 = ~(raw_encoding_i[15] | raw_encoding_i[12]);
  assign net_0_1 = ~(net_0_19 & raw_encoding_i[15]);
  assign net_0_19 = (raw_encoding_i[12] & net_0_20);
  assign net_0_20 = (net_0_21 | net_0_22);
  assign net_0_22 = (net_0_23 & net_0_24);
  assign net_0_24 = (net_0_25 | net_0_26);
  assign net_0_26 = ~(raw_encoding_i[8] | net_0_27);
  assign net_0_27 = (raw_encoding_i[13] | net_0_28);
  assign net_0_28 = ~(raw_encoding_i[11] & raw_encoding_i[14]);
  assign net_0_25 = ~(raw_encoding_i[14] | net_0_29);
  assign net_0_29 = (raw_encoding_i[11] | net_0_30);
  assign net_0_30 = ~(raw_encoding_i[13] & net_0_31);
  assign net_0_31 = (raw_encoding_i[7] | net_0_32);
  assign net_0_32 = ~(raw_encoding_i[6] & net_0_33);
  assign net_0_33 = ~(net_0_34 | raw_encoding_i[8]);
  assign net_0_34 = ~(raw_encoding_i[0] | net_0_35);
  assign net_0_35 = ~(raw_encoding_i[5] & net_0_36);
  assign net_0_36 = ~(raw_encoding_i[1] | raw_encoding_i[2]);
  assign net_0_23 = (raw_encoding_i[10] & raw_encoding_i[9]);
  assign net_0_21 = (net_0_37 & net_0_38);
  assign net_0_38 = ~(raw_encoding_i[9] | raw_encoding_i[10]);
  assign net_0_37 = ~(raw_encoding_i[14] | net_0_39);
  assign net_0_39 = (raw_encoding_i[8] | net_0_40);
  assign net_0_40 = ~(raw_encoding_i[11] & raw_encoding_i[13]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Defined instruction sideband encoder
  // ------------------------------------------------------

  wire   net_1_1, net_1_2, net_1_3, net_1_4, net_1_5, net_1_6, net_1_7, net_1_8, net_1_9, net_1_10,
         net_1_11, net_1_12, net_1_13, net_1_14, net_1_15, net_1_16, net_1_17, net_1_18,
         net_1_19, net_1_20, net_1_21, net_1_22, net_1_23, net_1_24, net_1_25, net_1_26,
         net_1_27, net_1_28, net_1_29, net_1_30, net_1_31, net_1_32, net_1_33, net_1_34,
         net_1_35, net_1_36, net_1_37, net_1_38, net_1_39, net_1_40, net_1_41, net_1_42,
         net_1_43, net_1_44, net_1_45, net_1_46, net_1_47, net_1_48, net_1_49, net_1_50,
         net_1_51, net_1_52, net_1_53, net_1_54, net_1_55, net_1_56, net_1_57;

  assign net_1_1 = ~raw_encoding_i[11];
  assign defined_sideband[2] = ~(net_1_2 | net_1_3);
  assign net_1_3 = ~(net_1_4 & net_1_5);
  assign net_1_5 = ~(net_1_6 & net_1_7);
  assign net_1_7 = ~(raw_encoding_i[10] & net_1_8);
  assign net_1_8 = ~(raw_encoding_i[8] & net_1_9);
  assign net_1_9 = (net_1_10 & net_1_11);
  assign net_1_6 = ~(raw_encoding_i[7] & net_1_12);
  assign net_1_12 = ~(raw_encoding_i[8] | raw_encoding_i[6]);
  assign net_1_4 = ~(raw_encoding_i[14] | net_1_13);
  assign net_1_13 = ~(raw_encoding_i[15] & net_1_14);
  assign net_1_14 = (raw_encoding_i[9] & raw_encoding_i[11]);
  assign defined_sideband[1] = (net_1_15 | net_1_16);
  assign net_1_16 = ~(net_1_17 | net_1_18);
  assign net_1_18 = ~(net_1_19 & net_1_20);
  assign net_1_20 = ~(raw_encoding_i[13] ^ raw_encoding_i[15]);
  assign net_1_19 = (raw_encoding_i[14] & net_1_21);
  assign net_1_21 = (raw_encoding_i[13] | net_1_22);
  assign net_1_22 = (raw_encoding_i[8] & net_1_23);
  assign net_1_15 = (net_1_24 & net_1_25);
  assign net_1_25 = (raw_encoding_i[12] & raw_encoding_i[15]);
  assign net_1_24 = (net_1_26 | net_1_27);
  assign net_1_27 = ~(raw_encoding_i[13] | net_1_28);
  assign net_1_28 = ~(raw_encoding_i[14] & net_1_29);
  assign net_1_29 = ~(net_1_23 & raw_encoding_i[11]);
  assign net_1_23 = (raw_encoding_i[9] & raw_encoding_i[10]);
  assign net_1_26 = ~(raw_encoding_i[14] | net_1_30);
  assign net_1_30 = ~(raw_encoding_i[13] & net_1_31);
  assign net_1_31 = (raw_encoding_i[8] & net_1_32);
  assign net_1_32 = ~(raw_encoding_i[10] & net_1_33);
  assign net_1_33 = (net_1_1 | raw_encoding_i[9]);
  assign defined_sideband[0] = (net_1_34 | net_1_35);
  assign net_1_35 = ~(raw_encoding_i[15] | net_1_36);
  assign net_1_36 = ~(net_1_37 | net_1_38);
  assign net_1_38 = (raw_encoding_i[13] | net_1_39);
  assign net_1_39 = (raw_encoding_i[8] | net_1_40);
  assign net_1_40 = ~(raw_encoding_i[7] & raw_encoding_i[1]);
  assign net_1_37 = (net_1_17 | net_1_41);
  assign net_1_41 = ~(raw_encoding_i[0] & net_1_42);
  assign net_1_42 = (raw_encoding_i[2] & raw_encoding_i[10]);
  assign net_1_17 = (raw_encoding_i[12] | raw_encoding_i[11]);
  assign net_1_34 = ~(raw_encoding_i[14] | net_1_43);
  assign net_1_43 = ~(net_1_2 | net_1_44);
  assign net_1_44 = ~(net_1_45 & net_1_46);
  assign net_1_46 = (raw_encoding_i[8] | net_1_47);
  assign net_1_47 = ~(raw_encoding_i[11] & raw_encoding_i[9]);
  assign net_1_45 = ~(net_1_48 & net_1_49);
  assign net_1_49 = ~(raw_encoding_i[8] ^ raw_encoding_i[10]);
  assign net_1_48 = (net_1_50 & net_1_51);
  assign net_1_51 = (raw_encoding_i[8] ^ net_1_1);
  assign net_1_50 = ~(raw_encoding_i[8] & net_1_52);
  assign net_1_52 = (raw_encoding_i[9] & net_1_53);
  assign net_1_53 = (net_1_54 | net_1_55);
  assign net_1_55 = ~(net_1_10 & net_1_11);
  assign net_1_11 = ~(raw_encoding_i[1] | raw_encoding_i[0]);
  assign net_1_10 = ~(raw_encoding_i[3] | raw_encoding_i[2]);
  assign net_1_54 = (raw_encoding_i[5] | net_1_56);
  assign net_1_56 = (raw_encoding_i[4] | net_1_57);
  assign net_1_57 = (raw_encoding_i[7] | raw_encoding_i[6]);
  assign net_1_2 = ~(raw_encoding_i[12] & raw_encoding_i[13]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------
  assign sideband_o    = {3{t16_unpred_undef}} | defined_sideband;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
