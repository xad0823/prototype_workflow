// --=========================================================================--
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited.
//    (C) COPYRIGHT 2000 ARM Limited
//        ALL RIGHTS RESERVED
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited.
//------------------------------------------------------------------------------
//
//  Version and Release Control Information:
//
//  File Name              : UartRXParShft.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block performs serial shifting of received data
//               and performs parity check on the received data
// --=========================================================================--

`timescale 1ns/1ps

module UartRXParShft (
                      UARTCLK,
                      nUARTRST,
                      RXDsampled,
                      ShiftEn,
                      SampleParity,
                      ClearShiftReg,
                      SPS,
                      EPS,
                      PEN,
                      WLEN,
                      PEIMSync,
                      UARTPEICSync,
                      RecdDATA,
                      DtPrZero,
                      ParityError,
                      UARTPERIS,
                      UARTPEMIS
                     );

input         UARTCLK;       //  Main UART Clock
input         nUARTRST;	     // Muxed reset (from nUARTRST)
input         RXDsampled;    // Sampled serial input
input         ShiftEn;       // Shift next bit
input         SampleParity;  // Enable Parity sample
input         ClearShiftReg; // Clear receive shifter
input         SPS;           // Stick Parity Select
input         EPS;           // Even Parity Select
input         PEN;           // Parity enable
input [1:0]   WLEN;          // Bits per word
input         PEIMSync;      //  Parity Error interrupt mask
input         UARTPEICSync;  // For Parity Error interrupt clear

output [7:0]  RecdDATA;      // Received Data
output        DtPrZero;	     // Data bits and Parity bit zero
output        ParityError;   // Parity Error detected
output        UARTPERIS;     // Parity Error Raw status
output        UARTPEMIS;     // Parity Error Masked status

//------------------------------------------------------------------------------
//
//                   UartRXParShft
//                   =============
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
//  This block performs shifting-in of the serial bit stream
// and parity error checking on the received data.
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire         UARTCLK;
//  Main UART Clock                                   (Module Input)

wire         nUARTRST;	
// Muxed reset (from nUARTRST)                        (Module Input)

wire         ShiftEn;
// Shift next bit                                     (Module Input)

wire         SampleParity;
// Enable Parity sample                               (Module Input)

wire         ClearShiftReg;
// Clear receive shifter                              (Module Input)

wire [1:0]   WLEN;
// Bits per word                                      (Module Input)

wire         EPS;
// Even Parity Select                                 (Module Input)

wire         PEN;
// Parity enable                                      (Module Input)

wire         PEIMSync;
//  Parity Error interrupt mask                       (Module Input)

wire         RXDsampled;
// Sampled serial input                               (Module Input)

wire         UARTPEICSync;
// For Parity Error interrupt clear                   (Module Input)

wire         DataZero;
// Indicates that all data bits in the received character are zero

wire         ParityEdge;
// Detects rising edge on parity error

wire         UARTPEIClr;
// Parity Error Interrupt Clear                     (Module Output)

wire         UARTPEMIS;
// Parity Error Masked status                       (Module Output)

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------

reg        iParityError;
// Parity Error detected                            (Module Output)

reg        iDtPrZero;
// Data bits and Parity bit zero                    (Module Output)

reg        iUARTPERIS;
// Parity Error Raw status                          (Module Output)
// Internal version of UARTPERIS signal

reg [7:0]  RXShiftReg;
// Receive Data shift register

reg [7:0]  NextRXShiftReg;
// D-input of Shift register

reg        NextParityError;
// D-input of iParityError

reg        DelParityError;
// Delayed version of iParityError

reg        NextUARTPERIS;
// D-input of iUARTPERIS

reg        DelUARTPEICSync;
// Delayed version of UARTPEICSync

reg        NextDtPrZero;
// D-input of iDtPrZero

//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_ShiftSeq
  if (nUARTRST == 1'b0)
    begin
      RXShiftReg      <= 8'b00000000;
      iParityError    <= 1'b0;
      iDtPrZero       <= 1'b0;
      DelParityError  <= 1'b0;
      DelUARTPEICSync <= 1'b0;
      iUARTPERIS      <= 1'b0;
    end
  else
    begin
      RXShiftReg      <= NextRXShiftReg;
      iParityError    <= NextParityError;
      iDtPrZero       <= NextDtPrZero;
      DelParityError  <= iParityError;
      DelUARTPEICSync <= UARTPEICSync;
      iUARTPERIS      <= NextUARTPERIS;
    end
end // p_ShiftSeq;

//------------------------------------------------------------------------------
// Error Checking
// If 'SampleParity' is asserted then the RXD bit is sampled to
// get the parity bit and the parity error value is calculated.
//------------------------------------------------------------------------------
always @ (EPS or RXDsampled or RXShiftReg or SampleParity
          or iParityError or ClearShiftReg or SPS)
begin : p_ErrCheck
  if (ClearShiftReg == 1'b1)
    NextParityError  = 1'b0;
  else if (SampleParity == 1'b1) begin
//------------------------------------------------------------------------------
// If Stick parity is selected then Xor the actual parity bit with
// the inverse of the Even Parity Select bit, otherwise Xor the expected parity
// bit with the actual parity bit received to calculate the parity error
//------------------------------------------------------------------------------
    if (SPS == 1'b1)
      NextParityError = RXDsampled ^ (!(EPS));
    else
      NextParityError =  RXDsampled ^ ( !(EPS)) ^ RXShiftReg[7]
                         ^ RXShiftReg[6] ^ RXShiftReg[5] ^ RXShiftReg[4]
                         ^ RXShiftReg[3] ^ RXShiftReg[2] ^ RXShiftReg[1]
                         ^ RXShiftReg[0];
  end else
    NextParityError = iParityError;
end // p_ErrCheck;

//------------------------------------------------------------------------------
// Shift register
//------------------------------------------------------------------------------
always @ (WLEN or ShiftEn or RXDsampled or RXShiftReg or ClearShiftReg)
begin : p_ShiftComb
  if (ClearShiftReg == 1'b1)
    NextRXShiftReg   = 8'b00000000;
  else if (ShiftEn == 1'b1)
    begin
      NextRXShiftReg = 8'b00000000;
      case (WLEN)
        2'b00 :
          // 5 bit data
          NextRXShiftReg = {3'b000, RXDsampled, RXShiftReg[4:1]};
        2'b01 :
          // 6 bit data
          NextRXShiftReg = {2'b00, RXDsampled, RXShiftReg[5:1]};
        2'b10 :
          // 7 bit data
          NextRXShiftReg = {1'b0, RXDsampled, RXShiftReg[6:1]};
        2'b11 :
          // 8 bit data
          NextRXShiftReg = {RXDsampled, RXShiftReg[7:1]};
      //  default :;
      endcase
    end
  else
      NextRXShiftReg = RXShiftReg;
end // p_ShiftComb;

//------------------------------------------------------------------------------
// 'Break' is said to have been detected when all bits in a frame -
//  start bit, data bits, parity bit and stop bits - are zeros.
// This section checks for the Data bits and the parity bit all being
// zeros. This condition is used in detecting the break condition which
// is done in the UartTXCntl block.
//------------------------------------------------------------------------------
assign DataZero = (RXShiftReg == 8'b00000000);

always @(ClearShiftReg or RXDsampled or PEN or DataZero or SampleParity
          or iDtPrZero)
begin : p_DtPrZero
  if(ClearShiftReg == 1'b1)
    NextDtPrZero = 1'b0;
  else if(PEN == 1'b1)
    begin
      if((SampleParity == 1'b1) && (RXDsampled == 1'b0))
        NextDtPrZero  = DataZero;
      else
        NextDtPrZero = iDtPrZero;
    end
  else
      NextDtPrZero = DataZero;
end // p_DtPrZero;

//------------------------------------------------------------------------------
// Detect rising edge in Parity Error
//------------------------------------------------------------------------------
assign  ParityEdge = iParityError &  !(DelParityError);

//------------------------------------------------------------------------------
// UARTPEIClr is a one PCLK-wide pulse used to clear the UARTPEINTR.
//------------------------------------------------------------------------------
assign  UARTPEIClr = UARTPEICSync &  !(DelUARTPEICSync);

//------------------------------------------------------------------------------
// Generate a parity  error interrupt when there is a rising edge
// on the framing error line. Clear the error when there is a write
// to bit 7 of the Interrupt clear register.
//------------------------------------------------------------------------------

always @ (iUARTPERIS or ParityEdge or UARTPEIClr)
begin : p_UARTPEINTR
  NextUARTPERIS = iUARTPERIS;
  if(ParityEdge == 1'b1)
    NextUARTPERIS = 1'b1;
  else if (UARTPEIClr == 1'b1)
    NextUARTPERIS = 1'b0;
end // p_UARTPEINTR;

assign UARTPEMIS = iUARTPERIS & PEIMSync;

//------------------------------------------------------------------------------
// Assign internal signals to Port
//------------------------------------------------------------------------------
assign  RecdDATA    = RXShiftReg;
assign  DtPrZero    = iDtPrZero;
assign  ParityError = iParityError;
assign  UARTPERIS   = iUARTPERIS;

endmodule

// --======================= End of UartRXParShft ====================--

