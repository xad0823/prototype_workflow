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
//  File Name              : UartDMA.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose    :  This block contains the logic for the DMA Interface.
// --=========================================================================--

`timescale 1ns/1ps
//------------------------------------------------------------------------------

module UartDMA (
                PCLK,
                PRESETn,
                UARTEN,
                TXDMAE,
                RXDMAE,
                DMAONERR,
                TXE,
                RXE,
                FEN,
                TESTFIFO,
                TXIntLevel,
                RXIntLevel,
                TXFLTE31Full,
                RXFGTE1Full,
                UARTTXDMACLRSync,
                UARTRXDMACLRSync,
                UARTREINTR,
                TXDMASREQ,
                TXDMABREQ,
                RXDMASREQ,
                RXDMABREQ
               );

input   PCLK;	            // APB Clock
input   PRESETn;            // APB Bus Reset 
input   UARTEN;             // Uart Enable
input   TXDMAE;             // Transmit DMA Enable
input   RXDMAE;             // Receive DMA Enable
input   DMAONERR;           // DMA on Error signal
input   TXE;                // Transmit Enable
input   RXE;                // Receive Enable
input   FEN;                // Fifo enable bit
input   TESTFIFO;           // Test FIFO mode
input   TXIntLevel;         // Transmit burst length
input   RXIntLevel;         // Receive burst length
input   TXFLTE31Full;       // TX FIFO has 1 or more spaces
input   RXFGTE1Full;        // RX FIFO contains data
input   UARTTXDMACLRSync;   // DMA clear signal
input   UARTRXDMACLRSync;   // DMA clear signal
input   UARTREINTR;         // Raw Uart Error Interrupt

output  TXDMASREQ;          // Transmit single request
output  TXDMABREQ;          // Transmit burst request
output  RXDMASREQ;          // Receive single request
output  RXDMABREQ;          // Receive burst request

//------------------------------------------------------------------------------
//                          UartDMA
//                          =======
//------------------------------------------------------------------------------
// Overview
// ========
// This block conatins the logic for the DMA interface. It generates the
// 4 DMA request signals, UARTTXDMASREQ, UARTRXDMASREQ,  and UARTRXDMABREQ
// depending on the amount of data in the FIFO's.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//  Wire declarations
//------------------------------------------------------------------------------
wire    PCLK;	
// APB Clock                                        (Module Input)

wire    PRESETn;	
// Muxed Reset (from BPRESETn)                         (Module Input)

wire    UARTEN;
// Uart Enable                                      (Module Input)

wire    TXDMAE;
// Transmit DMA Enable                              (Module Input)

wire    RXDMAE;
// Receive DMA Enable                               (Module Input)

wire    DMAONERR;
// DMA on Error signal                              (Module Input)

wire    TXFLTE31Full;
// TX FIFO has 1 or more spaces                     (Module Input)

wire    RXFGTE1Full;
// RX FIFO contains data                            (Module Input)

wire    UARTTXDMACLRSync;
// DMA clear signal                                 (Module Input)

wire    UARTRXDMACLRSync;
// DMA clear signal                                 (Module Input)

wire    TXIntLevel;
// Transmit burst length                            (Module Input)

wire    RXIntLevel;
// Receive burst length                             (Module Input)

wire    UARTREINTR;
// Raw Uart Error Interrupt                         (Module Input)

wire    TESTFIFO;
// Test FIFO mode                                   (Module Input)

wire    TXE;
// Transmit Enable                                  (Module Input)

wire    RXE;
// Receive Enable                                   (Module Input)

wire    FEN;
// Fifo enable bit                                  (Module Input)

wire DMATXEn;
//  DMA Transmit enable

wire DMARXEn;
//  DMA Receive enable

//------------------------------------------------------------------------------
//  Register declarations
//------------------------------------------------------------------------------
reg  iTXDMASREQ;
// Transmit single request

reg  iTXDMABREQ;
// Transmit burst request

reg  iRXDMASREQ;
// Receive single request

reg  iRXDMABREQ;
// Receive burst request

reg nextTXDMASREQ;
// D-input of iTXDMASREQ

reg nextTXDMABREQ;
// D-input of iTXDMABREQ

reg nextRXDMASREQ;
// D-input of iRXDMASREQ

reg nextRXDMABREQ;
// D-input of iRXDMABREQ

//------------------------------------------------------------------------------
// Main VERILOG code
// =================
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Connect local copies of signals to ports
//------------------------------------------------------------------------------
assign  TXDMABREQ = iTXDMABREQ;
assign  RXDMABREQ = iRXDMABREQ;
assign  TXDMASREQ = iTXDMASREQ;
assign  RXDMASREQ = iRXDMASREQ;

//------------------------------------------------------------------------------
// Sequential process for registers/flip-flops in this block
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_Seq
  if (PRESETn == 1'b0)
    begin
      iTXDMASREQ <= 1'b0;
      iTXDMABREQ <= 1'b0;
      iRXDMASREQ <= 1'b0;
      iRXDMABREQ <= 1'b0;
    end
  else
    begin
      iTXDMASREQ <= nextTXDMASREQ;
      iTXDMABREQ <= nextTXDMABREQ;
      iRXDMASREQ <= nextRXDMASREQ;
      iRXDMABREQ <= nextRXDMABREQ;
    end
end // p_Seq

//------------------------------------------------------------------------------
// The DMATXEn is asserted when the UART is enabled and the Transmit
// enable  bit is set, and the Transmit DMA bit is set in the
// UARTDMACR register. This can also be aserted when the FIFOs need to be
// tested with DMA.
//------------------------------------------------------------------------------
assign DMATXEn = (((UARTEN == 1'b1 && TXE == 1'b1) ||
                 (TESTFIFO == 1'b1)) && (TXDMAE == 1'b1)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
// The transmit single request is set when there is atleast one space
// in the transmit FIFO. It is cleared when either there is a
// UARTTXDMACLRSync signal or when the DMATXEn is not asserted.
//------------------------------------------------------------------------------
always @(DMATXEn or UARTTXDMACLRSync or TXFLTE31Full or iTXDMASREQ)
begin : p_TXDMASREQ
 if ((DMATXEn == 1'b0) || (UARTTXDMACLRSync == 1'b1))
   nextTXDMASREQ = 1'b0;
 else if(TXFLTE31Full == 1'b1)
   nextTXDMASREQ = 1'b1;
 else
    nextTXDMASREQ = iTXDMASREQ;
end // p_TXDMASREQ

//------------------------------------------------------------------------------
// The transmit burst request is set when there are more spaces than
// the watermark level in the transmit FIFO. It is cleared when
// either there is a UARTTXDMACLRSync signal or when the DMATXEn is not
// asserted.
//------------------------------------------------------------------------------
always @(DMATXEn or UARTTXDMACLRSync or FEN or TXIntLevel or iTXDMABREQ)
begin : p_TXDMABREQ
  if ((DMATXEn == 1'b0) ||  (UARTTXDMACLRSync == 1'b1) || (FEN == 1'b0))
    nextTXDMABREQ = 1'b0;
  else if(TXIntLevel == 1'b1)
    nextTXDMABREQ = 1'b1;
  else
    nextTXDMABREQ = iTXDMABREQ;
end // p_TXDMABREQ


//------------------------------------------------------------------------------
// The DMARXEn is asserted when the UART is enabled and the Receive
// enable  bit is set, and the Receive DMA bit is set in the
// UARTDMACR register.
//------------------------------------------------------------------------------
assign DMARXEn = (((UARTEN == 1'b1 && RXE == 1'b1) ||
                 (TESTFIFO == 1'b1)) && (RXDMAE == 1'b1)) ? 1'b1 : 1'b0;

//------------------------------------------------------------------------------
// The receive single request is set when there is atleast one character
// in the receive FIFO. It is cleared when either there is a UARTRXDMACL
// signal or when the DMARXEn is not asserted.
//------------------------------------------------------------------------------
always @(DMARXEn or UARTRXDMACLRSync or DMAONERR or UARTREINTR or RXFGTE1Full
         or iRXDMASREQ)
begin :p_RXDMASREQ
  if ((DMARXEn == 1'b0) ||  (UARTRXDMACLRSync == 1'b1) ||
      ((DMAONERR == 1'b1) && (UARTREINTR == 1'b1)))
    nextRXDMASREQ = 1'b0;
  else if(RXFGTE1Full == 1'b1)
    nextRXDMASREQ = 1'b1;
  else
    nextRXDMASREQ = iRXDMASREQ;
end // p_RXDMASREQ;

//------------------------------------------------------------------------------
// The receive burst request is set when there are more characters than
// the watermark level in the receive FIFO. It is cleared when
// either:
//   - there is a UARTRXDMACLRSync signal
//   - the DMARXEn is not asserted or
//   - the DMAONERR bit is set and the error interrupt line is asserted.
//------------------------------------------------------------------------------
always @(DMARXEn or UARTRXDMACLRSync or RXIntLevel or DMAONERR or UARTREINTR or
         FEN or iRXDMABREQ)
begin : p_RXDMABREQ
  if ((DMARXEn == 1'b0) ||  (UARTRXDMACLRSync == 1'b1) ||
      ((DMAONERR == 1'b1) && (UARTREINTR == 1'b1)) || (FEN == 1'b0))
    nextRXDMABREQ = 1'b0;
  else if(RXIntLevel == 1'b1)
    nextRXDMABREQ = 1'b1;
  else
    nextRXDMABREQ = iRXDMABREQ;
end // p_RXDMABREQ;

endmodule

// --========================== End of UartDMA ===============================--
