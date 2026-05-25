//  --========================================================================--
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
//  Filename            : RtcControl.v.rca
//
//  File Revision       : 1.9
//
//  Release Information : ARM PrimeCell RTC - PL031 - r1p3-00rel0
//
// -----------------------------------------------------------------------------
// Purpose               : This block contains the control logic for the Rtc
//
// --=========================================================================--

`timescale 1ns/1ps


module RtcControl(
                // Inputs
                  PCLK,
                  PRESETn,
                  RTCIntClr,
                  RawIntSync,
                // Outputs
                  IntClear
                  );


input       PCLK;            // APB clock
input       PRESETn;         // APB Bus Reset
input       RTCIntClr;       // RTC Interrupt Clear signal
input       RawIntSync;      // Synchronised raw interrupt

output      IntClear;        // Interrupt clear signal gated to RTCRIS


//------------------------------------------------------------------------------
//
//                            RtcControl
//                            ==========
//
//------------------------------------------------------------------------------
//
// Overview
// =======
//
// This block performs the following functions
//
// Generation of the interrupt clear signal which is gated to the Synchronised
// raw interrupt status
//
//==============================================================================
//

//------------------------------------------------------------------------------
// Wire declarations
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Register Declarations
//-----------------------------------------------------------------------------
reg IntClear;       // Gated interrupt clear
reg NextIntClear;   // D-input for IntClear

//------------------------------------------------------------------------------
// Wire declarations
//------------------------------------------------------------------------------


//==============================================================================
// Main Verilog code
// -----------------
//==============================================================================


// -----------------------------------------------------------------------------
// Implementation of interrupt clear signal (IntClear) - Combinational
//
// IntClear is asserted when there is a write to the RTC Interrupt Clear
// register while there is an interrupt.
// -----------------------------------------------------------------------------
always @(RawIntSync or RTCIntClr or IntClear)
  begin : p_combIntClear
    if(RawIntSync == 1'b0)
      NextIntClear = 1'b0;
    else
      NextIntClear = RTCIntClr || IntClear;
  end //  p_combIntClear

// -----------------------------------------------------------------------------
// Implementation of interrupt clear signal (IntClear) - Sequential
// -----------------------------------------------------------------------------
always @ (posedge PCLK or negedge PRESETn)
  begin : p_seqIntClear
    if(PRESETn == 1'b0)
      IntClear <= 1'b0;
    else
      IntClear <= NextIntClear;
    end //  p_seqIntClear



endmodule

//====================End of RtcControl=========================================
