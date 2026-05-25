//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Determine if an error is fatal
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// Uses the syndrome to identify all two bit errors, and some multi-bit errors.

module ca53_ecc_fatal64 (
  input  [7:0]  syndrome_i,
  output        fatal_o
);

  wire [7:0] s = syndrome_i;

  assign fatal_o = ((         s[6] & ~s[5] & ~s[4]                 & ~s[1] &  s[0] ) |
                    ( s[7]         & ~s[5] & ~s[4]         &  s[2] & ~s[1]         ) |
                    (                ~s[5] & ~s[4]         &  s[2] & ~s[1] &  s[0] ) |
                    (         s[6] & ~s[5] & ~s[4]         &  s[2] & ~s[1]         ) |
                    ( s[7] &  s[6]                         & ~s[2] & ~s[1] & ~s[0] ) |
                    ( s[7]         &  s[5] & ~s[4] & ~s[3] & ~s[2] & ~s[1]         ) |
                    (         s[6] &  s[5] & ~s[4] & ~s[3] & ~s[2] & ~s[1]         ) |
                    ( s[7]         & ~s[5] &  s[4] & ~s[3] & ~s[2] & ~s[1]         ) |
                    (         s[6] & ~s[5] &  s[4] & ~s[3] & ~s[2] & ~s[1]         ) |
                    (~s[7] & ~s[6] &  s[5] &  s[4]         & ~s[2]         & ~s[0] ) |
                    ( s[7]         & ~s[5] & ~s[4] &  s[3]         & ~s[1]         ) |
                    (         s[6] & ~s[5] & ~s[4] &  s[3]         & ~s[1]         ) |
                    (~s[7] & ~s[6] &  s[5]         &  s[3] & ~s[2] & ~s[1] & ~s[0] ) |
                    (~s[7] & ~s[6]         &  s[4] &  s[3] & ~s[2] & ~s[1] & ~s[0] ) |
                    (~s[7] & ~s[6] &  s[5] & ~s[4] & ~s[3] &  s[2] & ~s[1] & ~s[0] ) |
                    (~s[7] & ~s[6] & ~s[5] &  s[4] & ~s[3] &  s[2] & ~s[1] & ~s[0] ) |
                    (                ~s[5] & ~s[4] &  s[3] &  s[2] & ~s[1]         ) |
                    ( s[7]         & ~s[5] & ~s[4] & ~s[3]         &  s[1]         ) |
                    (         s[6] & ~s[5] & ~s[4] & ~s[3]         &  s[1]         ) |
                    (~s[7] & ~s[6] &  s[5]         & ~s[3] & ~s[2] &  s[1] & ~s[0] ) |
                    (~s[7] & ~s[6]         &  s[4] & ~s[3] & ~s[2] &  s[1] & ~s[0] ) |
                    (~s[7] & ~s[6] & ~s[5] & ~s[4] &  s[3] & ~s[2] &  s[1] & ~s[0] ) |
                    (                ~s[5] & ~s[4] & ~s[3] &  s[2] &  s[1]         ) |
                    (~s[7] &  s[6]                         & ~s[2] & ~s[1] &  s[0] ) |
                    (                 s[5] & ~s[4] & ~s[3] & ~s[2] & ~s[1] &  s[0] ) |
                    (                ~s[5] &  s[4] & ~s[3] & ~s[2] & ~s[1] &  s[0] ) |
                    (                ~s[5] & ~s[4] &  s[3]         & ~s[1] &  s[0] ) |
                    (                ~s[5] & ~s[4] & ~s[3]         &  s[1] &  s[0] ) |
                    (                 s[5] &  s[4] &  s[3]                         ) |
                    ( s[7] &  s[6]         & ~s[4] & ~s[3]         & ~s[1] & ~s[0] ) |
                    ( s[7] &  s[6] & ~s[5]         & ~s[3]         & ~s[1] & ~s[0] ) |
                    ( s[7] & ~s[6] &  s[5] &  s[4]         &  s[2]         & ~s[0] ) |
                    (~s[7] &  s[6] &  s[5] &  s[4]         &  s[2]         & ~s[0] ) |
                    ( s[7] & ~s[6]                 &  s[3] &  s[2]         & ~s[0] ) |
                    (~s[7] &  s[6]                 &  s[3] &  s[2]         & ~s[0] ) |
                    ( s[7] &  s[6]                 & ~s[3] & ~s[2]         & ~s[0] ) |
                    (                 s[5] &  s[4]                 &  s[1]         ) |
                    ( s[7] &  s[6] & ~s[5] & ~s[4]         & ~s[2]         & ~s[0] ) |
                    ( s[7] & ~s[6] &  s[5]         &  s[3]         &  s[1] & ~s[0] ) |
                    (~s[7] &  s[6] &  s[5]         &  s[3]         &  s[1] & ~s[0] ) |
                    ( s[7] & ~s[6]         &  s[4] &  s[3]         &  s[1] & ~s[0] ) |
                    (~s[7] &  s[6]         &  s[4] &  s[3]         &  s[1] & ~s[0] ) |
                    ( s[7] & ~s[6]                         &  s[2] &  s[1] & ~s[0] ) |
                    (~s[7] &  s[6]                         &  s[2] &  s[1] & ~s[0] ) |
                    (                 s[5]         &  s[3] &  s[2] &  s[1]         ) |
                    (                         s[4] &  s[3] &  s[2] &  s[1]         ) |
                    ( s[7] & ~s[6]                         & ~s[2] & ~s[1] &  s[0] ) |
                    ( s[7] & ~s[6]         & ~s[4] & ~s[3]         & ~s[1] &  s[0] ) |
                    (~s[7] &  s[6]         & ~s[4] & ~s[3]         & ~s[1] &  s[0] ) |
                    ( s[7] & ~s[6] & ~s[5]         & ~s[3]         & ~s[1] &  s[0] ) |
                    (~s[7] &  s[6] & ~s[5]         & ~s[3]         & ~s[1] &  s[0] ) |
                    (~s[7] & ~s[6] &  s[5] &  s[4]         &  s[2]         &  s[0] ) |
                    (~s[7] & ~s[6]                 &  s[3] &  s[2]         &  s[0] ) |
                    ( s[7] & ~s[6]                 & ~s[3] & ~s[2]         &  s[0] ) |
                    (~s[7] &  s[6]                 & ~s[3] & ~s[2]         &  s[0] ) |
                    ( s[7] & ~s[6] & ~s[5] & ~s[4]         & ~s[2]         &  s[0] ) |
                    (~s[7] &  s[6] & ~s[5] & ~s[4]         & ~s[2]         &  s[0] ) |
                    (~s[7] & ~s[6] &  s[5]         &  s[3]         &  s[1] &  s[0] ) |
                    (~s[7] & ~s[6]         &  s[4] &  s[3]         &  s[1] &  s[0] ) |
                    (~s[7] & ~s[6]                         &  s[2] &  s[1] &  s[0] ) |
                    ( s[7] &  s[6] &  s[5] &  s[4]         &  s[2]         &  s[0] ) |
                    ( s[7] &  s[6]                 &  s[3] &  s[2]         &  s[0] ) |
                    ( s[7] &  s[6] &  s[5]         &  s[3]         &  s[1] &  s[0] ) |
                    ( s[7] &  s[6]         &  s[4] &  s[3]         &  s[1] &  s[0] ) |
                    ( s[7] &  s[6]                         &  s[2] &  s[1] &  s[0] ));




endmodule


