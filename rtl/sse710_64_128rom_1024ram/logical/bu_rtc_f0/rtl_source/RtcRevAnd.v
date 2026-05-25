//  -=========================================================================--
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2001, 2017 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//  ----------------------------------------------------------------------------
//
//  Version and Release Control Information :
//
//
//  Filename            : RtcRevAnd.v.rca
//
//  File Revision       : 1.3
//
//  Release Information : ARM PrimeCell RTC - PL031 - r1p3-00rel0
//
//  ----------------------------------------------------------------------------
//  Purpose               : Revision Designator Module
//
//  --========================================================================--

`timescale 1ns/1ps


module RtcRevAnd (
                   TieOff1,
                   TieOff2,
                   Revision
                  );

input        TieOff1;      // AND gate input 1
input        TieOff2;      // AND gate input 2

output       Revision;     // AND gate output

// -----------------------------------------------------------------------------
//
//                              RtcRevAnd
//                              =========
//
// -----------------------------------------------------------------------------
//
// Overview
// ========
//   This module contains a single AND gate to be used as a
// place-holder cell to mark the Revision of the Rtc.
// The 2 input pins will be tied-off at the top level of the
// hierarchy. These "TieOffs" can be identified during layout
// and re-wired to "VDD" or "VSS" if needed.
//
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Wire declaration
// -----------------------------------------------------------------------------
wire        TieOff1;
// AND gate input 1                                        (Module Input)

wire        TieOff2;
// AND gate input 2                                        (Module Input)

wire        Revision;
// AND gate output                                         (Module Output)

// -----------------------------------------------------------------------------
//
// Main body of code
// =================
//
// -----------------------------------------------------------------------------

assign Revision         = TieOff1 & TieOff2;

endmodule

// --========================= End of RtcRevAnd =============================--
