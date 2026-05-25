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
//  File Name              : UartSynctoPCLK.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block synchronises signals crossing over from
//               the UARTCLK domain into the PCLK domain.
// --=========================================================================--

`timescale 1ns/1ps

module UartSynctoPCLK (
                       PCLK,
                       PRESETn,
                       TXBUSY,
                       TXFRdPtrInc,
                       RXFWr,
                       Abort,
                       DataStp,
                       nDCD,
                       nDSR,
                       nCTS,
                       nRI,
                       UARTRISmod,
                       UARTMISmod,
                       UARTRISerr,
                       UARTMISerr,
                       IntUARTTXDMACLR,
                       IntUARTRXDMACLR,
                       CharTxComp,
                       TXBUSYSync,
                       TXFRdPtrIncSync,
                       RXFWrSync,
                       AbortSync,
                       nDCDSyncPCLK,
                       nDSRSyncPCLK,
                       nCTSSyncPCLK,
                       nRISyncPCLK,
                       UARTRTRIS,
                       UARTRISmodSync,
                       UARTMISmodSync,
                       UARTRISerrSync,
                       UARTMISerrSync,
                       UARTTXDMACLRSync, 
                       UARTRXDMACLRSync,
                       CharTxCompSync
                     );

input        PCLK;               // APB Bus Clock
input        PRESETn;            // APB Bus Reset 
input        TXBUSY;             // Transmitter Busy
input        TXFRdPtrInc;        // TX FIFO Read pointer Incr.
input        RXFWr;              // RX FIFO Write enable
input        Abort;              // Abort transmission
input        DataStp;            // Receive line Idle
input        nDCD;               // Modem signal
input        nDSR;               // Modem Signal
input        nCTS;               // Modem Signal
input        nRI;                // Modem Signal
input  [3:0] UARTRISmod;         // Raw interrupt status
input  [3:0] UARTMISmod;         // Masked interrupt status
input  [2:0] UARTRISerr;         // Raw error interrupts
input  [2:0] UARTMISerr;         // Masked error interrupts
input        IntUARTTXDMACLR;    // DMA Tx Clear
input        IntUARTRXDMACLR;    // DMA Rx Clear
input        CharTxComp;

output        TXBUSYSync;        // To TX FIFO
output        TXFRdPtrIncSync;   // To TX FIFO
output        RXFWrSync;         // To RX FIFO
output        AbortSync;         // To TX FIFO
output        nDCDSyncPCLK;      // Sync'ed DCD
output        nDSRSyncPCLK;      // Sync'ed DSR
output        nCTSSyncPCLK;      // Sync'ed CTS
output        nRISyncPCLK;       // Sync'ed RI
output        UARTRTRIS;         // Receive Timeout interrupt
output  [3:0] UARTRISmodSync;    // Synchro Raw int status
output  [3:0] UARTMISmodSync;    // Synchro Masked int status
output  [2:0] UARTRISerrSync;    // Synchro raw error interrupts
output  [2:0] UARTMISerrSync;    // SynchroMasked error interrupts
output        UARTTXDMACLRSync;  // Synchro DMA TX Clear
output        UARTRXDMACLRSync;  // Synchro DMA TX Clear
output        CharTxCompSync;    // Synchro Char transmit complete
//------------------------------------------------------------------------------
//
//                   UartSynctoPCLK
//                   ==============
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
// This module synchronises signals crossing over from the UARTCLK
// domain into the PCLK domain.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        PCLK;
// APB Bus Clock                                      (Module Input)

wire        PRESETn;
// APB Bus Reset                                      (Module Input)

wire        nDCD;
// Modem signal                                       (Module Input)

wire        nDSR;
// Modem Signal                                       (Module Input)

wire        nCTS;
// Modem Signal                                       (Module Input)

wire        nRI;
// Modem Signal                                       (Module Input)

wire        TXBUSY;
// Transmitter Busy                                   (Module Input)

wire        TXFRdPtrInc;
// TX FIFO Read pointer Incr.                         (Module Input)

wire        RXFWr;
// RX FIFO Write enable                               (Module Input)

wire        Abort;
// Abort transmission                                 (Module Input)

wire        DataStp;
// Receive line Idle                                  (Module Input)

wire  [3:0] UARTRISmod;
// Raw interrupt status                               (Module Input)

wire  [3:0] UARTMISmod;
// Masked interrupt status                            (Module Input)

wire  [2:0] UARTRISerr;
// Raw error interrupts                               (Module Input)

wire  [2:0] UARTMISerr;
// Masked error interrupts                            (Module Input)

wire        IntUARTTXDMACLR;  
// DMA Transmit Clear                                 (Module Input)

wire        IntUARTRXDMACLR;  
// DMA Receive Clear                                  (Module Input)

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
reg        nDCDSyncPCLK;
// Sync'ed DCD                                          (Module Output)

reg        nDSRSyncPCLK;
// Sync'ed DSR                                          (Module Output)

reg        nCTSSyncPCLK;
// Sync'ed CTS                                          (Module Output)

reg        nRISyncPCLK;
// Sync'ed RI                                           (Module Output)

reg        TXBUSYSync;
// To TX FIFO                                           (Module Output)

reg        UARTRTRIS;
// Receive Timereg interrupt                            (Module Output)

reg        TXFRdPtrIncSync;
// To TX FIFO                                           (Module Output)

reg        RXFWrSync;
// To RX FIFO                                           (Module Output)

reg        AbortSync;
// To TX FIFO                                           (Module Output)

reg        CharTxCompSync;  
// To TX FIFO                                           (Module Output)

reg  [3:0] UARTRISmodSync;
//  Synchro Raw int status                              (Module Output)

reg  [3:0] UARTMISmodSync;
//  Synchro Masked int status                           (Module Output)

reg  [2:0] UARTRISerrSync;
// Synchro raw error interrupts                         (Module Output)

reg  [2:0] UARTMISerrSync;
// SynchroMasked error interrupts                       (Module Output)

reg        UARTTXDMACLRSync;  
// Synchro DMA Transmit clear                           (Module Output)

reg        UARTRXDMACLRSync; 
// Synchro DMA Receive clear                            (Module Output)

//------------------------------------------------------------------------------
// Intermediate first stage and second stage synchronised signals
// corresponding to each input
//------------------------------------------------------------------------------
reg DataStpSy1;
// 1st stage synchronised version of DataStp input

reg RXFWrSy1;
// 1st stage synchronised version of RXFWr input

reg TXBUSYSy1;
// 1st stage synchronised version of TXBUSY input

reg TXFRPtrIncSy1;
// 1st stage synchronised version of TXFRdPtrInc input

reg AbortSy1;
// 1st stage synchronised version of Abort input

reg nDCDSy1;
// 1st stage synchronised version of nDCD input

reg nDSRSy1;
// 1st stage synchronised version of nDSR input

reg nCTSSy1;
// 1st stage synchronised version of nCTS input

reg nRISy1;
// 1st stage synchronised version of nRI input

reg [3:0]  UARTRISmodSy1;
// 1st stage synchronised version of UARTRISmod

reg  [3:0]   UARTMISmodSy1;
// 1st stage synchronised version of UARTMISmod

reg [2:0]   UARTRISerrSy1;
// 1st stage synchronised version of UARTRISerrSync

reg [2:0]   UARTMISerrSy1;
// 1st stage synchronised version of UARTMISerrSync

reg        UARTTXDMACLRSy1;  
// 1st stage synchronised version of UARTTXDMACLRSync

reg        UARTRXDMACLRSy1; 
// 1st stage synchronised version of UARTRXDMACLRSync

reg        CharTxCompSy1;
// 1st stage synchronised version of CharTxCompSync


//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Synchronisers for FIFO-related signals, interrupts and DMA signals 
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_FIFOs
  if (PRESETn == 1'b0)
    begin
      DataStpSy1         <= 1'b0;
      UARTRTRIS            <= 1'b0;
      RXFWrSy1           <= 1'b0;
      RXFWrSync            <= 1'b0;
      TXFRPtrIncSy1      <= 1'b0;
      TXFRdPtrIncSync      <= 1'b0;
      AbortSy1           <= 1'b0;
      AbortSync            <= 1'b0;
      UARTRISmodSync       <= 4'b0000;
      UARTRISmodSy1      <= 4'b0000;
      UARTMISmodSync       <= 4'b0000;
      UARTMISmodSy1      <= 4'b0000;
      UARTRISerrSync       <= 3'b000;
      UARTRISerrSy1      <= 3'b000;
      UARTMISerrSync       <= 3'b000;
      UARTMISerrSy1      <= 3'b000;
      UARTTXDMACLRSy1    <= 1'b0;
      UARTTXDMACLRSync     <= 1'b0;
      UARTRXDMACLRSy1    <= 1'b0;
      UARTRXDMACLRSync     <= 1'b0;
      CharTxCompSy1       <= 1'b0;
      CharTxCompSync     <=1'b0;
    end
  else
    begin
        DataStpSy1        <= DataStp;
        UARTRTRIS           <= DataStpSy1;
        RXFWrSy1          <= RXFWr;
        RXFWrSync           <= RXFWrSy1;
        TXFRPtrIncSy1     <= TXFRdPtrInc;
        TXFRdPtrIncSync     <= TXFRPtrIncSy1;
        AbortSy1          <= Abort;
        AbortSync           <= AbortSy1;
        UARTRISmodSy1     <= UARTRISmod;
        UARTRISmodSync      <= UARTRISmodSy1;
        UARTMISmodSy1     <= UARTMISmod;
        UARTMISmodSync      <= UARTMISmodSy1;
        UARTRISerrSy1     <= UARTRISerr;
        UARTRISerrSync      <= UARTRISerrSy1;
        UARTMISerrSy1     <= UARTMISerr;
        UARTMISerrSync      <= UARTMISerrSy1;
        UARTTXDMACLRSy1   <= IntUARTTXDMACLR;
        UARTTXDMACLRSync    <= UARTTXDMACLRSy1;    
        UARTRXDMACLRSy1   <= IntUARTRXDMACLR;
        UARTRXDMACLRSync    <= UARTRXDMACLRSy1;      
        CharTxCompSy1      <= CharTxComp;
        CharTxCompSync    <=CharTxCompSy1;
    end
end // p_FIFOs;

//------------------------------------------------------------------------------
// Synchroniser for TXBUSY signal.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_TXBUSY
  if (PRESETn == 1'b0)
    begin
      TXBUSYSy1 <= 1'b0;
      TXBUSYSync  <= 1'b0;
    end
  else
    begin
        TXBUSYSy1 <= TXBUSY;
        TXBUSYSync  <= TXBUSYSy1;
    end
end // p_TXBUSY;

//------------------------------------------------------------------------------
// Synchronisers for Modem-related signals.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_Modem
  if (PRESETn == 1'b0)
    begin
      nDCDSyncPCLK  <= 1'b0;
      nDCDSy1     <= 1'b0;
      nDSRSyncPCLK  <= 1'b0;
      nDSRSy1     <= 1'b0;
      nCTSSyncPCLK  <= 1'b0;
      nCTSSy1     <= 1'b0;
      nRISyncPCLK   <= 1'b0;
      nRISy1      <= 1'b0;
    end
  else
    begin
        nDCDSy1     <= nDCD;
        nDCDSyncPCLK  <= nDCDSy1;
        nDSRSy1     <= nDSR;
        nDSRSyncPCLK  <= nDSRSy1;
        nCTSSy1     <= nCTS;
        nCTSSyncPCLK  <= nCTSSy1;
        nRISy1      <= nRI;
        nRISyncPCLK   <= nRISy1;
    end
  end // p_Modem;

endmodule

// --============================ End of UartSynctoPCLK ======================--

