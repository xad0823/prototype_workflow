// --=========================================================================--
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited.
//    (C) COPYRIGHT 2000, 2007 ARM Limited
//        ALL RIGHTS RESERVED
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited.
//------------------------------------------------------------------------------
//
//  Version and Release Control Information:
//
//  File Name              : UartRXFIFO.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose   : This block instantiates the UartRXFCntl (Receive FIFO
//              control)  and the UartRXRegFile (Register File) blocks.
// --=========================================================================--

`timescale 1ns/1ps

module UartRXFIFO (
                   PCLK,
                   PRESETn,
                   PWDATAIn,
                   RXFWrSync,
                   RXFRdPtrInc,
                   RXFIFOData,
                   UARTECRWrEn,
                   UARTTDRWrEn,
                   FEN,
                   RTSEn,
                   TESTFIFO,
                   nUARTRTScr,
                   RXIFLSEL,
                   UARTRXIC,
                   UARTOEIC,
                   RXIM,
                   OEIM,
                   RXFRdData,
                   RXFWrDone,
                   RXFE,
                   RXFF,
                   OverrunDet,
                   nUARTRTSint,
                   RXFGTE1Full,
                   RXIntLevel,
                   UARTRXIClr,
                   UARTOEIClr,
                   UARTRXRIS,
                   UARTRXMIS,
                   UARTOERIS,
                   UARTOEMIS
                   );

input        PCLK;          // APB Clock
input        PRESETn;       // APB Bus Reset
input [11:0] PWDATAIn;      // Write data bus
input        RXFWrSync;	    // RX FIFO Write Enable
input        RXFRdPtrInc;   // RX FIFO Read Pointer Incr
input [10:0] RXFIFOData;    // RX FIFO Write data
input        UARTECRWrEn;   // Overrun error Clear input
input        UARTTDRWrEn;   // Write enable for Rx fifo
input        FEN;           // FIFO Enable
input        TESTFIFO;      // Test signal
input        nUARTRTScr;    // from control register
input [2:0]  RXIFLSEL;      // fifo interrupt level select
input        UARTRXIC;      // For Rx Interrupt clear
input        UARTOEIC;      // For Overrun error Interrupt clear
input        RXIM;          // Tx Interrupt Mask
input        OEIM;          // Overrun error Interrupt Mask
input        RTSEn;         // RTS flow control enable

output [11:0] RXFRdData;    // RX FIFO Read Data
output        RXFWrDone;    // RX FIFO Write Done
output        RXFE;         // Receive FIFO Empty
output        RXFF;         // Receive FIFO Full
output        OverrunDet;   // Overrun Detected
output        nUARTRTSint;  // modem signal
output        RXFGTE1Full;  // To DMA block
output        RXIntLevel;   // Programable Interrupt Level
output        UARTRXIClr;   // Rx Interrupt clear
output        UARTOEIClr;   // Rx Interrupt clear
output        UARTRXRIS;    // Receive Raw Interrupt
output        UARTRXMIS;    // Receive Masked Interrupt
output        UARTOERIS;    // Overrun error Raw Interrupt
output        UARTOEMIS;    // Overrun error Masked Interrupt

//------------------------------------------------------------------------------
//                                 UartRXFIFO
//                                 ==========
// Overview
// ========
//
// The receive FIFO is a 11-bit wide 16-deep FIFO. It instantiates two
// submodules - UartRXFCntl (which performs the FIFO control function
// and the UartRXRegFile (which is the register file). The receive FIFO
// is implemented as a circular buffer with read and write pointers.
// The pointers operate on PCLK to facilitate APB accesses and
// calculation of FIFO fill level.
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire         PCLK;
// APB Clock                                           (Module Input)

wire         PRESETn;
//APB Bus Reset                                        (Module Input)

wire         RXFWrSync;
// RX FIFO Write Enable                                (Module Input)

wire         RXFRdPtrInc;
// RX FIFO Read Pointer Incr                           (Module Input)

wire  [10:0] RXFIFOData;
// RX FIFO Write data                                  (Module Input)

wire  [11:0] PWDATAIn;
// Write data bus                                      (Module Input)

wire         UARTECRWrEn;
// Overrun error Clear signal                          (Module Input)

wire         UARTTDRWrEn;
// Write enable for Rx fifo                            (Module Input)

wire         FEN;
// FIFO Enable                                         (Module Input)

wire         TESTFIFO;
// Test signal                                         (Module Input)

wire  [2:0]  RXIFLSEL;
// fifo interrupt level select                         (Module Input)

wire         UARTRXIC;
// For Rx Interrupt clear                              (Module Input)

wire         UARTOEIC;
// For Overrun error Interrupt clear                   (Module Input)

wire         RXIM;
// Tx Interrupt Mask                                   (Module Input)

wire         OEIM;
// Overrun error Interrupt Mask                        (Module Input)

wire         RTSEn;
// RTS flow control enable                             (Module Input)

wire         nUARTRTScr;
// from control register                               (Module Input)

wire          RegFileWrEn;
wire   [4:0]  WrPtr;
wire   [4:0]  RdPtr;
wire          FIFOOverrunDet;
reg   [11:0] muxRXFIFOData;

//------------------------------------------------------------------------------
// In TESTFIFO mode use testdata written straight to the fifo instead
// of waiting for it to be transmited and received.
//------------------------------------------------------------------------------
always @(PWDATAIn or TESTFIFO or  RXFIFOData or FIFOOverrunDet)
begin : p_RXTestdata
  if (TESTFIFO == 1'b1)
    muxRXFIFOData = PWDATAIn[11:0];
  else
    muxRXFIFOData = {FIFOOverrunDet, RXFIFOData };
end // p_RXTestdata;

//------------------------------------------------------------------------------
// The UartRXFCntl block controls accesses to the FIFO register file.
//------------------------------------------------------------------------------
 UartRXFCntl uUartRXFCntl (
                           .PCLK           (PCLK),
                           .PRESETn        (PRESETn),
                           .RXFWrSync      (RXFWrSync),
                           .RXFRdPtrInc    (RXFRdPtrInc),
                           .FEN            (FEN),
                           .TESTFIFO       (TESTFIFO),
                           .RTSEn          (RTSEn),
                           .nUARTRTScr     (nUARTRTScr),
                           .UARTECRWrEn    (UARTECRWrEn),
                           .UARTTDRWrEn    (UARTTDRWrEn),
                           .RXIFLSEL       (RXIFLSEL),
                           .RXIM           (RXIM),
                           .OEIM           (OEIM),
                           .UARTRXIC       (UARTRXIC),
                           .UARTOEIC       (UARTOEIC),
                           .WrPtr          (WrPtr),
                           .RdPtr          (RdPtr),
                           .RXFE           (RXFE),
                           .RXFF           (RXFF),
                           .RXFGTE1Full    (RXFGTE1Full),
                           .RXIntLevel     (RXIntLevel),
                           .RegFileWrEn    (RegFileWrEn),
                           .RXFWrDone      (RXFWrDone),
                           .OverrunDet     (OverrunDet),
                           .FIFOOverrunDet (FIFOOverrunDet),
                           .nUARTRTSint    (nUARTRTSint),
                           .UARTRXIClr     (UARTRXIClr),
                           .UARTOEIClr     (UARTOEIClr),
                           .UARTRXRIS      (UARTRXRIS),
                           .UARTRXMIS      (UARTRXMIS),
                           .UARTOERIS      (UARTOERIS),
                           .UARTOEMIS      (UARTOEMIS)
                          );

//------------------------------------------------------------------------------
// The UartRXRegFile is a data buffer implemented using D-types.
//------------------------------------------------------------------------------
 UartRXRegFile uUartRXRegFile (
                               .PCLK        (PCLK),
                               .PRESETn     (PRESETn),
                               .RegFileWrEn (RegFileWrEn),
                               .WrPtr       (WrPtr),
                               .RdPtr       (RdPtr),
                               .RXFIFOData  (muxRXFIFOData),
                               .RXFRdData   (RXFRdData)
                              );

endmodule
// --============================= End of UartTXFIFO ==========================-
