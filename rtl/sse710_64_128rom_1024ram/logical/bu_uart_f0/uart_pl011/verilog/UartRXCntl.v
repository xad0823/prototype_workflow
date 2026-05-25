// --=========================================================================--
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited.
//    (C) COPYRIGHT 2000-2001, 2007 ARM Limited
//        ALL RIGHTS RESERVED
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited.
//------------------------------------------------------------------------------
//
//  Version and Release Control Information:
//
//  File Name              : UartRXCntl.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose      : This state machine is the main Receive state m/c.
// --=========================================================================--

`timescale 1ns/1ps


module UartRXCntl (
                   UARTCLK,
                   nUARTRST,
                   Baud16,
                   UARTENSync,
                   SIRENSync,
		   RXESync,
                   RXD,
                   WLEN,
                   STP2,
                   PEN,
                   Zerobaud,
                   RXFWrDoneSync,
                   DtPrZero,
                   UARTFEICSync,
                   UARTBEICSync,
                   FEIMSync,
                   BEIMSync,
                   ShiftEn,
                   SampleParity,
                   RXEnable,
                   UartRXCntlState,
                   RXDsampled,
                   ClearShiftReg,
                   RXFWr,
                   ReloadWD,
                   FramingError,
                   Break,
                   RXBUSY,
                   CharRxComp,
                   UARTFERIS,
                   UARTBERIS,
                   UARTFEMIS,
                   UARTBEMIS
                 );

input        UARTCLK;           // Main UART Clock
input        nUARTRST;          // Muxed reset (from nUARTRST)
input        Baud16;            // Bit Period Reference
input        UARTENSync;        // UART Enable
input        SIRENSync;         // SIR Enable
input        RXESync;           // RXE Enable
input        RXD;               // Receive serial input
input  [1:0] WLEN;              // Data bits per word
input        STP2;              // 2 stop bits
input        PEN;               // Parity enable
input        Zerobaud;          // Baud Divisor set to 0
input        RXFWrDoneSync;     // RX FIFO Write Done
input        DtPrZero;          // Data bits and Parity bit zero
input        UARTFEICSync;      // For Framing Error interrupt clear
input        UARTBEICSync;      // For Framing Error interrupt clear
input        FEIMSync;          //  Framing Error interrupt mask
input        BEIMSync;          //  Break Error Interrupt mask

output        ShiftEn;          // Shift next bit
output        SampleParity;     // Enable Parity sample
output        RXEnable;         // Rx enable
output  [2:0] UartRXCntlState;  // Rx state
output        RXDsampled;       // Sampled Rx data stream
output        ClearShiftReg;    // Clear receive shifter
output        RXFWr;            // Receive FIFO Write (level)
output        ReloadWD;	        // Restart watchdog counter
output        FramingError;     // Framing error detected
output        Break;            // Break detected                      
output        CharRxComp;       // Character Rx complete                      
output        RXBUSY;           // RX machine busy
output        UARTFERIS;        // Framing Error Raw status
output        UARTBERIS;        // Break Error Raw status
output        UARTFEMIS;        // Framing Error Masked status
output        UARTBEMIS;        // Break Error Masked status

//------------------------------------------------------------------------------
//                             UartRXCntl
//                             =========
//------------------------------------------------------------------------------
//
// Overview
// ========
// The receive state machine controls the timing of sampling the input
// receive bit stream. It detects framing, parity errors. The parameters
// programmed into the LCR_H register are used to interpret the
// receive bit stream.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                      (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                          (Module Input)

wire        Baud16;
// Bit Period Reference                                 (Module Input)

wire        UARTENSync;
// UART Enable                                          (Module Input)

wire        SIRENSync;
// SIR Enable                                           (Module Input)

wire        RXESync;
// RXE Enable                                           (Module Input)

wire  [1:0] WLEN;
// Data bits per word                                   (Module Input)

wire        STP2;
// 2 stop bits                                          (Module Input)

wire        PEN;
// Parity enable                                        (Module Input)

wire        Zerobaud;
// Baud Divisor set to 0                                (Module Input)

wire        RXFWrDoneSync;
// RX FIFO Write Done                                   (Module Input)

wire        RXD;
// Receive serial input                                 (Module Input)

wire        DtPrZero;
// Data bits and Parity bit zero                        (Module Input)

wire        UARTFEICSync;
// For Framing Error interrupt clear                    (Module Input)

wire        UARTBEICSync;
// For Framing Error interrupt clear                    (Module Input)

wire        FEIMSync;
//  Framing Error interrupt mask                        (Module Input)

wire        BEIMSync;
//  Break Error Interrupt mask                          (Module Input)

wire        iRXEnable;
// Internal version of RXEnable signal

wire        FramingEdge;
wire        BreakEdge;
wire        UARTFEIClr;
wire        UARTBEIClr;

// Aliases
wire        AbortReceive;
wire        BreakDetStop;
wire        BreakDetXStop;

// Comparators
wire        BitPeriodCmp;
wire        BitCmp;
wire        FrmErrCmp;
wire        BreakErrCmp;

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
//  Encoding style: Gray
reg [2:0]  iUartRXCntlState;
reg [2:0]  UartRXCntlNextState;
reg        SampleParity;
reg        RXFWr;
reg        ShiftEn;
reg        ReloadWD;
reg        ClearShiftReg;
reg        RXBUSY;
reg        iUARTBERIS;
reg        NextSampleParity;
reg        NextRXFWr;
reg        NextShiftEn;
reg        NextReloadWD;
reg        NextClearShiftReg;
reg        NextRXBUSY;
reg        NextUARTFERIS;
reg        NextUARTBERIS;
reg        RXD1;
reg        RXD2;
reg        RXD3;
reg        iRXDsampled;
reg        DelFramingError;
reg        DelBreakError;
reg        DelUARTFEICSync;
reg        DelUARTBEICSync;
reg        iUARTFERIS;

// Registers
reg   [3:0] BitPeriodCnt;
reg   [3:0] NextBitPeriodCnt;
reg   [2:0] BitCnt;
reg   [2:0] NextBitCnt;
reg         iBreak;
reg         NextiBreak;
reg         iFramingError;
reg         NextiFramingError;
reg         iCharRxComp;
reg         NextCharRxComp;
  

// Expose internal register(s)...
assign  Break           = iBreak;
assign  FramingError    = iFramingError;
assign  UartRXCntlState = iUartRXCntlState;
assign  RXDsampled      = iRXDsampled;
assign  UARTFERIS       = iUARTFERIS;
assign  CharRxComp      = iCharRxComp;  
assign  RXEnable        = iRXEnable;
assign  UARTBERIS       = iUARTBERIS;

// Expansion of aliases...
assign  AbortReceive = Zerobaud;
assign  iRXEnable    = (UARTENSync & RXESync);

assign  BreakDetStop  = !(iRXDsampled) & DtPrZero;
assign  BreakDetXStop = !(iRXDsampled) & FrmErrCmp & DtPrZero;

// Expansion of comparators...
assign  BitPeriodCmp = (BitPeriodCnt[3:0] == 4'b0000);
assign  BitCmp       = (BitCnt[2:0] == 3'b000);
assign  FrmErrCmp    = (iFramingError == 1'b1);
assign  BreakErrCmp  = (iBreak == 1'b1);

// State transition always @
always @(posedge UARTCLK or negedge nUARTRST)
begin : seq

  if (nUARTRST == 1'b0)
    begin
      iUartRXCntlState <= 3'b000;
      SampleParity     <= 1'b0;
      RXFWr            <= 1'b0;
      ShiftEn          <= 1'b0;
      ReloadWD         <= 1'b0;
      ClearShiftReg    <= 1'b1;
      RXBUSY           <= 1'b0;
      DelFramingError  <= 1'b0;
      DelUARTFEICSync  <= 1'b0;
      iUARTFERIS       <= 1'b0;
      DelBreakError    <= 1'b0;
      DelUARTBEICSync  <= 1'b0;
      iUARTBERIS       <= 1'b0;
      iCharRxComp      <= 1'b1;
    end
  else
    begin
        iUartRXCntlState <= UartRXCntlNextState;
        SampleParity     <= NextSampleParity;
        RXFWr            <= NextRXFWr;
        ShiftEn          <= NextShiftEn;
        ReloadWD         <= NextReloadWD;
        ClearShiftReg    <= NextClearShiftReg;
        RXBUSY           <= NextRXBUSY;
        DelFramingError  <= iFramingError;
        DelUARTFEICSync  <= UARTFEICSync;
        iUARTFERIS       <= NextUARTFERIS;
        DelBreakError    <= iBreak;
        DelUARTBEICSync  <= UARTBEICSync;
        iUARTBERIS       <= NextUARTBERIS;
        iCharRxComp      <= NextCharRxComp;
    end
 end // seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_SampleRXD
  if (nUARTRST == 1'b0)
    begin
      RXD1 <= 1'b1;
      RXD2 <= 1'b1;
      RXD3 <= 1'b1;
    end
  else if (Baud16 == 1'b1)
    begin
      RXD1 <= RXD;
      RXD2 <= RXD1;
      RXD3 <= RXD2;
    end
end // p_SampleRXD;

always @ (RXD1 or RXD2 or RXD3)
begin : p_vote
  if (((RXD1 == 1'b1) && (RXD2 == 1'b1)) || ((RXD1 == 1'b1)
       && (RXD3 == 1'b1)) || ((RXD2 == 1'b1) && (RXD3 == 1'b1)))
      iRXDsampled = 1'b1;
  else
    iRXDsampled = 1'b0;
end // p_vote;

//------------------------------------------------------------------------------
// Output and next state logic generation
//------------------------------------------------------------------------------
always @(iUartRXCntlState or PEN or STP2 or Baud16 or WLEN or RXFWrDoneSync 
         or AbortReceive or BreakDetStop or BreakDetXStop or 
         BitPeriodCnt or BitCnt or iBreak or iFramingError or BitPeriodCmp 
         or BitCmp or FrmErrCmp or BreakErrCmp or iRXEnable or iRXDsampled or 
         iCharRxComp or SIRENSync)
begin : combo
    // Default assignments
    UartRXCntlNextState = iUartRXCntlState;
    NextSampleParity    = 1'b0;
    NextRXFWr           = 1'b0;
    NextShiftEn         = 1'b0;
    NextReloadWD        = 1'b0;
    NextClearShiftReg   = 1'b0;
    NextRXBUSY          = 1'b0;
    NextBitPeriodCnt    = BitPeriodCnt;
    NextBitCnt          = BitCnt;
    NextiBreak          = iBreak;
    NextiFramingError   = iFramingError;
    NextCharRxComp      = iCharRxComp;
    case (iUartRXCntlState)

      3'b000 :
        //Detect RXD low 

        if ((!(iRXDsampled) & (!(AbortReceive)) & iRXEnable) == 1'b1)
          begin
	    if (SIRENSync == 1'b1)
		NextBitPeriodCnt[3:0] = 4'b0100; 
	    else
	      NextBitPeriodCnt[3:0] = 4'b1000;
      
            UartRXCntlNextState   = 3'b001;
            NextRXBUSY            = 1'b1;
            NextCharRxComp        = 1'b0;
          end
          else
            NextClearShiftReg = 1'b1;

      3'b001 :
        begin
          // If at any time the RXD line goes HIGH, invalidate  the start bit .
          if (((Baud16 & iRXDsampled) | AbortReceive) == 1'b1)
            begin
              UartRXCntlNextState = 3'b000;
              NextClearShiftReg   = 1'b1;
              NextCharRxComp      = 1'b1;
            end 
	  // Valid start bit detected
          else if ((Baud16 & BitPeriodCmp & !(AbortReceive) &
                  !(iRXDsampled)) == 1'b1)
            begin
              NextReloadWD        = 1'b1;
              NextBitPeriodCnt    = 4'b1111;
              NextBitCnt[2:0]     = {1'b1, WLEN[1:0]};
              UartRXCntlNextState = 3'b011;
              NextRXBUSY          = 1'b1;
              NextCharRxComp      = 1'b0;
            end
              // Count down from 7 to 0 with Baud16 as the count enable
              // to find the middle of the start bit
          else if ((Baud16 & !(BitPeriodCmp) & !(AbortReceive)) == 1'b1)
            begin
              NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
              UartRXCntlNextState = 3'b001;
              NextRXBUSY          = 1'b1;
            end
          else
            NextRXBUSY = 1'b1;
        end

      3'b011 :
        begin
          // Decrement BitPeriodCnt with Baud16 as the count enable
          if ((Baud16 & !(BitPeriodCmp) & !(AbortReceive)) == 1'b1)
            begin
              NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
              UartRXCntlNextState = 3'b011;
              NextRXBUSY          = 1'b1;
              NextCharRxComp      = 1'b0;
            end
              // Shift in next bit  
          else if ((Baud16 & BitPeriodCmp & !(BitCmp) & !(AbortReceive))
                    == 1'b1)
            begin
              NextShiftEn         = 1'b1;
              NextBitCnt          = BitCnt - 1'b1;
              NextBitPeriodCnt    = 4'b1111;
              UartRXCntlNextState = 3'b011;
              NextRXBUSY          = 1'b1;
              NextCharRxComp      = 1'b0;
            end
             // Parity enabled 
          else if ((Baud16 & BitCmp & BitPeriodCmp & PEN &
                    !(AbortReceive)) == 1'b1)
            begin
              NextShiftEn         = 1'b1;
              NextBitPeriodCnt    = 4'b1111;
              UartRXCntlNextState = 3'b010;
              NextRXBUSY          = 1'b1;
              NextCharRxComp      = 1'b0;
            end
              // Parity disabled 
          else if ((Baud16 & BitCmp & BitPeriodCmp & !(PEN) &
                    !(AbortReceive)) == 1'b1)
            begin
              NextShiftEn         = 1'b1;
              NextBitPeriodCnt    = 4'b1111;
              UartRXCntlNextState = 3'b101;
              NextRXBUSY          = 1'b1;
              NextCharRxComp      = 1'b0;
            end
  
          else if (AbortReceive == 1'b1)
            begin
              UartRXCntlNextState = 3'b000;
              NextClearShiftReg   = 1'b1;
              NextCharRxComp      = 1'b1;
            end
          else
            NextRXBUSY = 1'b1;
        end

      3'b010 :
        // Decrement BitperiodCnt counter to reach the middle of the
        // next bit

        if ((Baud16 & !(BitPeriodCmp) & !(AbortReceive)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartRXCntlNextState = 3'b010;
            NextRXBUSY          = 1'b1;
            NextCharRxComp      = 1'b0;
          end
            // Sample Parity bit
        else if ((Baud16 & BitPeriodCmp & !(AbortReceive)) == 1'b1)
          begin
            NextSampleParity    = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartRXCntlNextState = 3'b101;
            NextRXBUSY          = 1'b1;
            NextCharRxComp      = 1'b0;
          end

        else if (AbortReceive == 1'b1)
          begin
            UartRXCntlNextState = 3'b000;
            NextClearShiftReg   = 1'b1;
            NextCharRxComp      = 1'b1;
          end
        else
          NextRXBUSY = 1'b1;

      3'b110 :
        // Decrement BitPeriodCnt

        if ((Baud16 & !(BitPeriodCmp) & !(AbortReceive)) == 1'b1)
        begin
          NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
          UartRXCntlNextState = 3'b110;
          NextRXBUSY          = 1'b1;
          NextCharRxComp      = 1'b0;
        end

        else if (AbortReceive == 1'b1)
          begin
            UartRXCntlNextState = 3'b000;
            NextClearShiftReg   = 1'b1;
          end
            // Wait complete for additional stop bit time
        else if ((Baud16 & BitPeriodCmp & !(AbortReceive)) == 1'b1)
          begin
            NextReloadWD        = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            NextiBreak          = BreakDetXStop;
            UartRXCntlNextState = 3'b111;
            NextRXFWr           = 1'b1;
            NextRXBUSY          = 1'b1;
            NextCharRxComp      = 1'b1;
          end
        else
          NextRXBUSY = 1'b1;

      3'b111 :

        // If the FIFOWrDone signal is asserted and if there was no
        // framing error or Abort condition or if the RXD line went
        // HIGH then wait for the next start bits
        if ((!(BreakErrCmp) & RXFWrDoneSync & (!(FrmErrCmp)
             | iRXDsampled | AbortReceive)) == 1'b1)
        begin
          NextiBreak          = 1'b0;
          NextiFramingError   = 1'b0;
          UartRXCntlNextState = 3'b000;
          NextClearShiftReg   = 1'b1;
          NextCharRxComp      = 1'b1;
        end

        // If there was a framing error, then decrement the BitPeriodCnt
        // counter to detect the middle of the next start bit
        else if ((Baud16 & !(BitPeriodCmp) & FrmErrCmp & !(AbortReceive)
                & !(iRXDsampled) & !(BreakErrCmp)) == 1'b1)
        begin
          NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
          UartRXCntlNextState = 3'b111;
          NextRXFWr           = 1'b1;
          NextRXBUSY          = 1'b1;
          NextCharRxComp      = 1'b1;
        end

        // Framing error detected in previous byte; next bit
        // low - taken as start bit for next byte.
        else if ((RXFWrDoneSync & !(BreakErrCmp) & BitPeriodCmp
                & Baud16 & !(iRXDsampled) & !(AbortReceive) &
                FrmErrCmp & iRXEnable) == 1'b1)
        begin
          NextReloadWD        = 1'b1;
          NextClearShiftReg   = 1'b1;
          NextBitPeriodCnt    = 4'b1111;
          NextBitCnt[2:0]     = {1'b1, WLEN[1:0]};
          NextiBreak          = 1'b0;
          NextiFramingError   = 1'b0;
          UartRXCntlNextState = 3'b011;
          NextRXBUSY          = 1'b1;
          NextCharRxComp      = 1'b0;
        end

        else if ((BreakErrCmp & RXFWrDoneSync) == 1'b1)
        // Break detected
          begin
            UartRXCntlNextState = 3'b100;
            NextRXBUSY          = 1'b1;
          end
        else
          begin
            NextRXFWr  = 1'b1;
            NextRXBUSY = 1'b1;
          end

      3'b101 :
      // 2 stop bits programmed

        if ((Baud16 & BitPeriodCmp & STP2 & !(AbortReceive)) == 1'b1)
        begin
          NextBitPeriodCnt    = 4'b1111;
          NextiFramingError   = !(iRXDsampled);
          UartRXCntlNextState = 3'b110;
          NextRXBUSY          = 1'b1;
          NextCharRxComp      = 1'b0;
          // Decrement BitPeriodCnt counter to reach the middle of the
          // next bit
        end

        else if ((Baud16 & !(BitPeriodCmp) & !(AbortReceive)) == 1'b1)
        begin
          NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
          UartRXCntlNextState = 3'b101;
          NextRXBUSY          = 1'b1;
        end

        else if (AbortReceive == 1'b1)
        begin
          UartRXCntlNextState = 3'b000;
          NextClearShiftReg   = 1'b1;
        end
          // Only one stop bit
        else if ((Baud16 & BitPeriodCmp & !(STP2) & !(AbortReceive))
                  == 1'b1)
          begin
            NextReloadWD        = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            NextiBreak          = BreakDetStop;
            NextiFramingError   = !(iRXDsampled);
            UartRXCntlNextState = 3'b111;
            NextRXFWr           = 1'b1;
            NextRXBUSY          = 1'b1;
            NextCharRxComp      = 1'b1;
          end
        else
          NextRXBUSY = 1'b1;

      3'b100 :
        // Break released; RXD line high again

        if (iRXDsampled == 1'b1)
          begin
            UartRXCntlNextState = 3'b000;
            NextClearShiftReg   = 1'b1;
            NextCharRxComp      = 1'b1;
          end
        else
          NextRXBUSY = 1'b1;
//      default :
//        UartRXCntlNextState = 3'b000;
    endcase
end // combo;

//------------------------------------------------------------------------------
// Detect rising edge in Framing Error and Break Error
//------------------------------------------------------------------------------
assign  BreakEdge   = iBreak & !(DelBreakError);
assign  FramingEdge = iFramingError & !(DelFramingError);

//------------------------------------------------------------------------------
// UARTFEIClr is a one UART-wide pulse used to clear the UARTFEINTR.
// UARTBEIClr is a one UART-wide pulse used to clear the UARTBEINTR.
//------------------------------------------------------------------------------
assign  UARTFEIClr = UARTFEICSync & !(DelUARTFEICSync);
assign  UARTBEIClr = UARTBEICSync & !(DelUARTBEICSync);

//------------------------------------------------------------------------------
// Generate a framing error interrupt when there is a rising edge
// on the framing error line. Clear the error when there is a write
// to bit 7 of the Interrupt clear register.
//------------------------------------------------------------------------------
always @ (iUARTFERIS or FramingEdge or UARTFEIClr)
begin : p_UARTFEINTR
  NextUARTFERIS = iUARTFERIS;
  if(FramingEdge == 1'b1)
    NextUARTFERIS = 1'b1;
  else if (UARTFEIClr == 1'b1)
    NextUARTFERIS = 1'b0;
end // p_UARTFEINTR;

assign  UARTFEMIS = iUARTFERIS & FEIMSync;

//------------------------------------------------------------------------------
// Generate a break error interrupt when there is a rising edge
// on the break error line. Clear the error when there is a write
// to bit 7 of the Interrupt clear register.
//------------------------------------------------------------------------------
always @ (iUARTBERIS or BreakEdge or UARTBEIClr)
begin : p_UARTBEINTR
  NextUARTBERIS = iUARTBERIS;
  if(BreakEdge == 1'b1)
    NextUARTBERIS = 1'b1;
  else if (UARTBEIClr == 1'b1)
    NextUARTBERIS = 1'b0;
end // p_UARTBEINTR;

assign  UARTBEMIS = iUARTBERIS & BEIMSync;

always @(posedge UARTCLK or negedge nUARTRST)
begin : BitPeriodCnt_seq
  if (nUARTRST == 1'b0)
    BitPeriodCnt <= 4'b0000;
  else
    BitPeriodCnt <= NextBitPeriodCnt;
end // BitPeriodCnt_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : BitCnt_seq
  if (nUARTRST == 1'b0)
    BitCnt <= 3'b000;
  else
    BitCnt <= NextBitCnt;
end // BitCnt_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : iBreak_seq
  if (nUARTRST == 1'b0)
    iBreak <= 1'b0;
  else
      iBreak <= NextiBreak;
end // iBreak_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : iFramingError_seq
  if (nUARTRST == 1'b0)
    iFramingError <= 1'b0;
  else
    iFramingError <= NextiFramingError;
end // iFramingError_seq;

//  Signals: UartRXCntlState<2:0> UartRXCntlNextState<2:0>
//    ST_IDLE	000
//    ST_STARTBIT	001
//    ST_SHIFT	011
//    ST_PARITY	010
//    ST_XSTOP	110
//    ST_FIFOWRITE	111
//    ST_STOPBIT	101
//    ST_BREAK	100


endmodule

//--======================== End of UartRXCntl =======================--
