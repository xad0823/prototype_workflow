//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

`ifndef CA53_EXECTB_UNDEFINE

// log2 function for integers from 2 to 3096 (inclusive).  Results are rounded up.
// Returns 1 for inputs less than 2 and -1 for inputs greater than 4096.
`define CA53_EXECTB_LOG2(a) (((a)<=2)     ? 1  : \
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

`else

`undef CA53_EXECTB_LOG2

`endif

