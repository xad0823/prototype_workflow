//  ----------------------------------------------------------------------------
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
//  Filename            : RtcInterrupt.v.rca
//
//  File Revision       : 1.9
//
//  Release Information : ARM PrimeCell RTC - PL031 - r1p3-00rel0
//
//  ----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// Purpose : This block generates an interrupt when the match value is equal to
//           the count value.
// -----------------------------------------------------------------------------

`timescale 1ns/1ps


module RtcInterrupt (
                   // Inputs
                     PCLK,
                     PRESETn,
                     MatchData,
                     Count,
                     IntClear,
                     RTCIMSC,
                     RTCIntClr,
                     RawIntEdge,
                   // Outputs
                     RawInt,
                     MaskInt,
                     RawIntStatus
                     );


input          PCLK;         // APB clock
input          PRESETn;      // AMBA reset
input  [31:0]  MatchData;    // Equivalent match value
input  [31:0]  Count;        // Counter
input          IntClear;     //
input          RTCIMSC;      // RTC Interrupt Mask Set/Clear register
input          RTCIntClr;    // Write enable for RTCICR
input          RawIntEdge;   // Asserted on low-high transition of synchronised
                             // raw interrupt.
output         RawInt;       // Raw interrupt
output         MaskInt;      // RTC interrupt
output         RawIntStatus; // Synchronised raw interrupt status



//------------------------------------------------------------------------------
//
//                             RtcInterrupt
//                             ============
//
//------------------------------------------------------------------------------
//
//==============================================================================

// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire     RawIntData;  // Raw interrupt signal gated to IntClear
wire     IntData;     // Combination interrupt signal
wire     RawIntEdge;  // Asserted on a low-high transition of synchronised raw
                      // interrupt
wire     RTCIntClr;   // Write enable for RTCICR

//------------------------------------------------------------------------------
// Register Declarations
//------------------------------------------------------------------------------
reg     RawInt;           // Raw interrupt
reg     RawIntStatus;     // synchronised raw interrupt status
reg     NextRawIntStatus; // D-input of RawIntStatus


//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// The Raw Interrupt is generated when the Count value and the MatchData value
// are equal.
// -----------------------------------------------------------------------------
always @(MatchData or Count)
  begin : p_CombRawInt
    if(MatchData == Count)
      RawInt = 1'b1;
    else
      RawInt = 1'b0;
  end // p_CombRawInt

//------------------------------------------------------------------------------
// Generate synchronised Raw Interrupt Status signal - Combinational
//------------------------------------------------------------------------------
always @(RTCIntClr or RawIntEdge or RawIntStatus)
  begin : p_CombRawIntStatus
    if (RTCIntClr == 1'b1)
      NextRawIntStatus = 1'b0;
    else if (RawIntEdge == 1'b1)
      NextRawIntStatus = 1'b1;
    else
      NextRawIntStatus = RawIntStatus;
  end  // p_CombRawIntStatus

//------------------------------------------------------------------------------
// Generate synchronised Raw Interrupt Status signal - Sequential
//------------------------------------------------------------------------------
always @ (posedge PCLK or negedge PRESETn)
  begin : p_SeqRawIntStatus
    if(PRESETn == 1'b0)
      RawIntStatus <= 1'b0;
    else
      RawIntStatus <= NextRawIntStatus;
  end // p_SeqRawIntStatus

// The raw interrupt is gated with the interrupt clear signal
assign RawIntData = RawInt && (!IntClear);

assign IntData = RawIntData || RawIntStatus;

assign MaskInt = IntData && RTCIMSC;


endmodule

//==========================End of RtcInterrupt=================================
