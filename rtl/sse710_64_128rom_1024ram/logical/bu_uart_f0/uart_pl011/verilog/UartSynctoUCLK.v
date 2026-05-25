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
//  File Name              : UartSynctoUCLK.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block synchronises signals crossing over from
//               the PCLK domain into the UARTCLK domain.
// --=========================================================================--

`timescale 1ns/1ps

module UartSynctoUCLK (
                       UARTCLK,
                       nUARTRST,
                       BRK,
                       SIRLP,
                       SIREN,
                       UARTEN,
                       TXE,
                       RXE,
                       TXDataAvlbl,
                       RXFE,
                       CTSEn,
                       LCRUpdate,
                       ILPRUpdate,
                       FBRDUpdate,
                       UARTRXD,
                       SIRIN,
                       RXFWrDone,
                       RdPtrIncDone,
                       DCDIM,
                       DSRIM,
                       CTSIM,
                       RIIM,
                       RTIM,
                       FEIM,
                       PEIM,
                       BEIM,
                       nDCD,
                       nDSR,
                       nCTS,
                       nRI,
                       UARTDCDIC,
                       UARTDSRIC,
                       UARTCTSIC,
                       UARTRIIC,
                       UARTFEIC,
                       UARTPEIC,
                       UARTBEIC,
                       UARTRTIC,
                       SIRLPSync,
                       SIRENSync,
                       UARTENSync,
                       TXESync,
                       RXESync,
                       TXDataAvlblSync,
                       RXFESync,	
                       CTSEnSyncUCLK,
                       LCRUpdateSync,
                       ILPRUpdateSync,
                       FBRDUpdateSync,
                       UARTRXDSync,
                       SIRINSync,
                       RXFWrDoneSync,
                       RdPtrIncDoneSync,
                       DCDIMSync,
                       DSRIMSync,
                       CTSIMSync,
                       RIIMSync,	
                       RTIMSync,	
                       FEIMSync,	
                       PEIMSync,	
                       BEIMSync,	
                       nDCDSyncUARTCLK,
                       nDSRSyncUARTCLK,
                       nCTSSyncUARTCLK,
                       nRISyncUARTCLK,
                       UARTDCDICSync,
                       UARTDSRICSync,
                       UARTCTSICSync,
                       UARTRIICSync,
                       UARTFEICSync,
                       UARTPEICSync,
                       UARTBEICSync,
                       UARTRTICSync,
                       BRKSync
                     );

input        UARTCLK;             // Main UART Clock
input        nUARTRST;            // Muxed reset (from nUARTRST)
input        BRK;                 // UART break signal
input        SIRLP;               // SIR Low power mode
input        SIREN;               // SIR Enabled
input        UARTEN;              // UART Enabled
input        TXE;                 // TX Enabled
input        RXE;                 // RX Enabled
input        TXDataAvlbl;         // TX Data available
input        RXFE;                // RX FIFO Empty
input        CTSEn;               //
input        LCRUpdate;	          // Sync control signal for LCR
input        ILPRUpdate;          // Sync ctrl signal for ILPR
input        FBRDUpdate;          // Sync ctrl signal for ILPR
input        UARTRXD;             // UART Receive input
input        SIRIN;               // SIR Receive input
input        RXFWrDone;	          // RX FIFO Wr Done
input        RdPtrIncDone;        // Read Pointer Inc Done
input        DCDIM;               // UARTDCDINTR Interrupt Enable
input        DSRIM;               // UARTDSRINTR Interrupt Enable
input        CTSIM;               // UARTCTSINTR Interrupt Enable
input        RIIM;                // UARTRIINTR Interrupt Enable
input        RTIM;                // UARTRTINTR Interrupt Enable
input        FEIM;                // UARTFEINTR Interrupt Enable
input        PEIM;                // UARTPEINTR Interrupt Enable
input        BEIM;                // UARTBEINTR Interrupt Enable
input        nDCD;                // Modem signal
input        nDSR;                // Modem signal
input        nCTS;                // Modem signal
input        nRI;                 // Modem signal
input        UARTDCDIC;	          // Modem DCD Intr Clear
input        UARTDSRIC;	          // Modem DSR Intr Clear
input        UARTCTSIC;	          // Modem CTS Intr Clear
input        UARTRIIC;            // Modem RI Intr Clear
input        UARTFEIC;            // For Framing Error Intr Clear
input        UARTPEIC;            // For Parity Error Intr Clear
input        UARTBEIC;            // For Break Error Intr Clear
input        UARTRTIC;            // For Receive Timeout Intr Clear

output        SIRLPSync;          // To IrDA block
output        SIRENSync;          // To IrDA block
output        UARTENSync;         // Sync'ed UART Eable
output        TXESync;            // Sync'ed TX Eable
output        RXESync;            // Sync'ed RX Enable
output        TXDataAvlblSync;    // To Transmit block
output        RXFESync;	          // To Receive block
output        CTSEnSyncUCLK;      // To Transmit Block
output        LCRUpdateSync;      // To BaudGen
output        ILPRUpdateSync;     // To BaudGen block
output        FBRDUpdateSync;     // To BaudGen block
output        UARTRXDSync;        // To Receiver
output        SIRINSync;          // To IrDA block
output        RXFWrDoneSync;      // To Receiver
output        RdPtrIncDoneSync;   // To Transmitter
output        DCDIMSync;          // To Modem block
output        DSRIMSync;          // To Modem block
output        CTSIMSync;          // To Modem block
output        RIIMSync;	          // To Modem block
output        RTIMSync;	          // To Receive block
output        FEIMSync;	          // To Receive block
output        PEIMSync;	          // To Receive block
output        BEIMSync;	          // To Receive block
output        nDCDSyncUARTCLK;    // To Modem block
output        nDSRSyncUARTCLK;    // To Modem block
output        nCTSSyncUARTCLK;    // To Modem block
output        nRISyncUARTCLK;     // To Modem block
output        UARTDCDICSync;      // To Modem block
output        UARTDSRICSync;      // To Modem block
output        UARTCTSICSync;      // To Modem block
output        UARTRIICSync;       // To Modem block
output        UARTFEICSync;       // To UART Receiver
output        UARTPEICSync;       // To UART Receiver
output        UARTBEICSync;       // To UART Receiver
output        UARTRTICSync;       // To UART Receiver
output        BRKSync;            // To UART Transmiter

//------------------------------------------------------------------------------
//                   UartSynctoUCLK
//                   ==============
//------------------------------------------------------------------------------
// Overview
// ========
// This module synchronises signals crossing over from the PCLK
// domain into the UARTCLK domain.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                      (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                          (Module Input)

wire        UARTRXD;
// UART Receive wire                                    (Module Input)

wire        SIRIN;
// SIR Receive input                                    (Module Input)

wire        RXFWrDone;	
// RX FIFO Wr Done                                      (Module Input)

wire        RdPtrIncDone;
// Read Pointer Inc Done                                (Module Input)

wire        nDCD;
// Modem signal                                         (Module Input)

wire        nDSR;
// Modem signal                                         (Module Input)

wire        nCTS;
// Modem signal                                         (Module Input)

wire        nRI;
// Modem signal                                         (Module Input)

wire        DCDIM;
// UARTDCDINTR Interrupt Enable                         (Module Input)

wire        DSRIM;
// UARTDSRINTR Interrupt Enable                         (Module Input)

wire        CTSIM;
// UARTCTSINTR Interrupt Enable                         (Module Input)

wire        RIIM;
// UARTRIINTR Interrupt Enable                          (Module Input)

wire        RTIM;
// UARTRTINTR Interrupt Enable                          (Module Input)

wire        FEIM;
// UARTFEINTR Interrupt Enable                          (Module Input)

wire        PEIM;
// UARTPEINTR Interrupt Enable                          (Module Input)

wire        BEIM;
// UARTBEINTR Interrupt Enable                          (Module Input)

wire        UARTFEIC;
// For Framing Error Intr Clear                         (Module Input)

wire        UARTPEIC;
// For Parity Error Intr Clear                          (Module Input)

wire        UARTBEIC;
// For Break Error Intr Clear                           (Module Input)

wire        UARTRTIC;
// For Receive Timeout Intr Clear                       (Module Input)
wire        UARTDCDIC;	
// Modem DCD Intr Clear                                 (Module Input)

wire        UARTDSRIC;	
// Modem DSR Intr Clear                                 (Module Input)

wire        UARTCTSIC;	
// Modem CTS Intr Clear                                 (Module Input)

wire        UARTRIIC;
// Modem RI Intr Clear                                  (Module Input)

wire        SIRLP;
// SIR Low power mode                                   (Module Input)

wire        SIREN;
// SIR Enabled                                          (Module Input)

wire        UARTEN;
// UART Enabled                                         (Module Input)

wire        TXE;
// TX Enabled                                           (Module Input)

wire        RXE;
// RX Enabled                                           (Module Input)

wire        TXDataAvlbl;
// TX Data available                                    (Module Input)

wire        RXFE;
// RX FIFO Empty                                        (Module Input)

wire        LCRUpdate;	
// Sync control signal for LCR                          (Module Input)

wire        ILPRUpdate;
// Sync ctrl signal for ILPR                            (Module Input)

wire        FBRDUpdate;
// Sync ctrl signal for FBRD                            (Module Input)

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------

reg        DCDIMSync;
// To Modem block                                       (Module Output)

reg        DSRIMSync;
// To Modem block                                       (Module Output)

reg        CTSIMSync;
// To Modem block                                       (Module Output)

reg        RIIMSync;	
// To Modem block                                       (Module Output)

reg        RTIMSync;	
// To Receive block                                     (Module Output)

reg        FEIMSync;	
// To Receive block                                     (Module Output)
reg        PEIMSync;	
// To Receive block                                     (Module Output)

reg        BEIMSync;	
// To Receive block                                     (Module Output)

reg        UARTFEICSync;
// To UART Receiver                                     (Module Output)

reg        UARTPEICSync;
// To UART Receiver                                     (Module Output)

reg        UARTBEICSync;
// To UART Receiver                                     (Module Output)

reg        UARTRTICSync;
// To UART Receiver                                     (Module Output)

reg        UARTDCDICSync;
// To Modem block                                       (Module Output)

reg        UARTDSRICSync;
// To Modem block                                       (Module Output)

reg        UARTCTSICSync;
// To Modem block                                       (Module Output)

reg        UARTRIICSync;
// To Modem block                                       (Module Output)

reg        SIRLPSync;
// To IrDA block                                        (Module Output)

reg        SIRENSync;
// To IrDA block                                        (Module Output)

reg        UARTENSync;
// Sync'ed UART Eable                                   (Module Output)

reg        TXESync;
// Sync'ed TX Eable                                     (Module Output)

reg        RXESync;
// Sync'ed RX Enable                                    (Module Output)

reg        TXDataAvlblSync;
// To Transmit block                                    (Module Output)

reg        RXFESync;	
// To Receive block                                     (Module Output)

reg        LCRUpdateSync;
// To BaudGen                                           (Module Output)

reg        UARTRXDSync;
// To Receiver                                          (Module Output)

reg        SIRINSync;
// To IrDA block                                        (Module Output)

reg        RXFWrDoneSync;
// To Receiver                                          (Module Output)

reg        RdPtrIncDoneSync;
// To Transmitter                                       (Module Output)

reg        nDCDSyncUARTCLK;
// To Modem block                                       (Module Output)

reg        nDSRSyncUARTCLK;
// To Modem block                                       (Module Output)

reg        nCTSSyncUARTCLK;
// To Modem block                                       (Module Output)

reg        nRISyncUARTCLK;
// To Modem block                                       (Module Output)

reg        ILPRUpdateSync;
// To BaudGen block                                     (Module Output)

reg        FBRDUpdateSync;
// To BaudGen block                                     (Module Output)

reg        CTSEnSyncUCLK;

//------------------------------------------------------------------------------
// Intermediate first stage and second stage synchronised signals
// corresponding to each input
//------------------------------------------------------------------------------
reg UARTRXDSync1;
// 1st stage synchronised version of UARTRXD input

reg SIRINSync1;
// 1st stage synchronised version of SIRIN input

reg RXFWrDoneSync1;
// 1st stage synchronised version of RXFWrDone input

reg RPtrInDnSync1;
// 1st stage synchronised version of RdPtrIncDone input

reg nDCDSync1;
// 1st stage synchronised version of nDCD input

reg nDSRSync1;
// 1st stage synchronised version of nDSR input

reg nCTSSync1;
// 1st stage synchronised version of nCTS input

reg nRISync1;
// 1st stage synchronised version of nRI input

reg TXDataAvlblSync1;
// 1st stage synchronised version of TXDataAvlbl input

reg CTSEnSync1;
// 1st stage synchronised version of CTSEn

reg RXFESync1;
// 1st stage synchronised version of RXFE input

reg DCDIMSync1;
// 1st stage synchronised version of DCDIM input

reg DSRIMSync1;
// 1st stage synchronised version of DSRIM input

reg CTSIMSync1;
// 1st stage synchronised version of CTSIM input

reg RIIMSync1;
// 1st stage synchronised version of RIIM input

reg RTIMSync1;
// 1st stage synchronised version of RTIM input

reg FEIMSync1;
// 1st stage synchronised version of FEIM input

reg PEIMSync1;
// 1st stage synchronised version of PEIM input

reg BEIMSync1;
// 1st stage synchronised version of BEIM input

reg SIRLPSync1;
// 1st stage synchronised version of SIRLP input

reg SIRENSync1;
// 1st stage synchronised version of SIREN input

reg UARTENSync1;
// 1st stage synchronised version of UARTEN input

reg  TXESync1;
// 1st stage synchronised version of TXE input

reg  RXESync1;
// 1st stage synchronised version of RXE input

reg LCRUpdateSync1;
// 1st stage synchronised version of LCRUpdate input

reg ILPRUpdateSync1;
// 1st stage synchronised version of ILPRUpdate input

reg FBRDUpdateSync1;
// 1st stage synchronised version of FBRDUpdate input

reg UARTFEICSync1;
// 1st stage synchronised version of UARTFEIC input

reg UARTPEICSync1;
// 1st stage synchronised version of UARTPEIC input

reg UARTBEICSync1;
// 1st stage synchronised version of UARTBEIC input

reg UARTRTICSync1;
// 1st stage synchronised version of UARTRTIC input

reg UARTDCDICSync1;
// 1st stage synchronised version of DCDIC input

reg UARTDSRICSync1;
// 1st stage synchronised version of DSRIC input

reg UARTCTSICSync1;
// 1st stage synchronised version of CTSIC input

reg UARTRIICSync1;
// 1st stage synchronised version of RIIC input

reg BRKSync1;
// 1st stage synchronised version of BRK input

reg BRKSync;
// 2nd stage synchronised version of BRK input


//------------------------------------------------------------------------------
// Main Verilog code
// =================
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Synchronisers for Modem-related signals.
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_Modem
  if (nUARTRST == 1'b0)
    begin
      nDCDSync1       <= 1'b0;
      nDCDSyncUARTCLK <= 1'b0;
      nDSRSync1       <= 1'b0;
      nDSRSyncUARTCLK <= 1'b0;
      nCTSSync1       <= 1'b0;
      nCTSSyncUARTCLK <= 1'b0;
      nRISync1        <= 1'b0;
      nRISyncUARTCLK  <= 1'b0;
    end
  else
    begin
        nDCDSync1       <= nDCD;
        nDCDSyncUARTCLK <= nDCDSync1;

        nDSRSync1       <= nDSR;
        nDSRSyncUARTCLK <= nDSRSync1;

        nCTSSync1       <= nCTS;
        nCTSSyncUARTCLK <= nCTSSync1;

        nRISync1        <= nRI;
        nRISyncUARTCLK  <= nRISync1;
    end
end // p_Modem;

//------------------------------------------------------------------------------
// Synchronisers for Serial data input signals
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_Receive
  if (nUARTRST == 1'b0)
    begin
      SIRINSync1   <= 1'b0;
      SIRINSync    <= 1'b0;
      UARTRXDSync1 <= 1'b0;
      UARTRXDSync  <= 1'b0;
    end
  else
    begin
        SIRINSync1   <= SIRIN;
        SIRINSync    <= SIRINSync1;

        UARTRXDSync1 <= UARTRXD;
        UARTRXDSync  <= UARTRXDSync1;
    end
end // p_Receive;

//------------------------------------------------------------------------------
// Synchronisers for FIFO-related signals
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_FIFOs
  if (nUARTRST == 1'b0)
    begin
      RXFWrDoneSync1   <= 1'b0;
      RXFWrDoneSync    <= 1'b0;
      RPtrInDnSync1    <= 1'b0;
      RdPtrIncDoneSync <= 1'b0;
      RXFESync1        <= 1'b0;
      RXFESync         <= 1'b0;
      CTSEnSync1       <= 1'b0;
      CTSEnSyncUCLK    <= 1'b0;
    end
  else
    begin
        RXFWrDoneSync1   <= RXFWrDone;
        RXFWrDoneSync    <= RXFWrDoneSync1;
        RPtrInDnSync1    <= RdPtrIncDone;
        RdPtrIncDoneSync <= RPtrInDnSync1;
        RXFESync1        <= RXFE;
        RXFESync         <= RXFESync1;
        CTSEnSync1       <= CTSEn;
        CTSEnSyncUCLK    <= CTSEnSync1;
    end
end // p_FIFOs;

//------------------------------------------------------------------------------
// Synchronisers for the LCRUpdate signal and the ILPRUpdate
// signal.
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_Update
  if (nUARTRST == 1'b0)
    begin
      LCRUpdateSync1  <= 1'b0;
      LCRUpdateSync   <= 1'b0;
      ILPRUpdateSync1 <= 1'b0;
      ILPRUpdateSync  <= 1'b0;
      FBRDUpdateSync1 <= 1'b0;
      FBRDUpdateSync  <= 1'b0;
    end
  else
    begin
        LCRUpdateSync1  <= LCRUpdate;
        LCRUpdateSync   <= LCRUpdateSync1;

        ILPRUpdateSync1 <= ILPRUpdate;
        ILPRUpdateSync  <= ILPRUpdateSync1;
        FBRDUpdateSync1 <= FBRDUpdate;
        FBRDUpdateSync  <= FBRDUpdateSync1;
    end
end // p_Update;

//------------------------------------------------------------------------------
// Synchroniser for the TXDataAvlbl signal.
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_TXDataAvlbl
  if (nUARTRST == 1'b0)
    begin
      TXDataAvlblSync1 <= 1'b0;
      TXDataAvlblSync  <= 1'b0;
    end
  else
    begin
        TXDataAvlblSync1 <= TXDataAvlbl;
        TXDataAvlblSync  <= TXDataAvlblSync1;
    end
end // p_TXDataAvlbl;

//------------------------------------------------------------------------------
// Synchronisers for 'Enable' signals and other related signals.
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_CntlSig
  if (nUARTRST == 1'b0)
    begin
      BRKSync1       <= 1'b0;
      BRKSync        <= 1'b0;

      DCDIMSync1     <= 1'b0;
      DCDIMSync      <= 1'b0;

      DSRIMSync1     <= 1'b0;
      DSRIMSync      <= 1'b0;

      CTSIMSync1     <= 1'b0;
      CTSIMSync      <= 1'b0;

      RIIMSync1      <= 1'b0;
      RIIMSync       <= 1'b0;

      RTIMSync1      <= 1'b0;
      RTIMSync       <= 1'b0;

      FEIMSync1      <= 1'b0;
      FEIMSync       <= 1'b0;

      PEIMSync1      <= 1'b0;
      PEIMSync       <= 1'b0;

      BEIMSync1      <= 1'b0;
      BEIMSync       <= 1'b0;

      SIRLPSync1     <= 1'b0;
      SIRLPSync      <= 1'b0;

      SIRENSync1     <= 1'b0;
      SIRENSync      <= 1'b0;

      UARTENSync1    <= 1'b0;
      UARTENSync     <= 1'b0;

      TXESync1       <= 1'b1;
      TXESync        <= 1'b1;

      RXESync1       <= 1'b1;
      RXESync        <= 1'b1;

      UARTFEICSync1  <= 1'b0;
      UARTFEICSync   <= 1'b0;

      UARTPEICSync1  <= 1'b0;
      UARTPEICSync   <= 1'b0;

      UARTBEICSync1  <= 1'b0;
      UARTBEICSync   <= 1'b0;

      UARTRTICSync1  <= 1'b0;
      UARTRTICSync   <= 1'b0;

      UARTDCDICSync1 <= 1'b0;
      UARTDCDICSync  <= 1'b0;

      UARTDSRICSync1 <= 1'b0;
      UARTDSRICSync  <= 1'b0;

      UARTCTSICSync1 <= 1'b0;
      UARTCTSICSync  <= 1'b0;

      UARTRIICSync1  <= 1'b0;
      UARTRIICSync   <= 1'b0;
    end
  else
      begin
      
        BRKSync1       <= BRK;
        BRKSync        <= BRKSync1;

        DCDIMSync1     <= DCDIM;
        DCDIMSync      <= DCDIMSync1;

        DSRIMSync1     <= DSRIM;
        DSRIMSync      <= DSRIMSync1;

        CTSIMSync1     <= CTSIM;
        CTSIMSync      <= CTSIMSync1;

        RIIMSync1      <= RIIM;
        RIIMSync       <= RIIMSync1;

        RTIMSync1      <= RTIM;
        RTIMSync       <= RTIMSync1;

        FEIMSync1      <= FEIM;
        FEIMSync       <= FEIMSync1;

        PEIMSync1      <= PEIM;
        PEIMSync       <= PEIMSync1;

        BEIMSync1      <= BEIM;
        BEIMSync       <= BEIMSync1;

        SIRLPSync1     <= SIRLP;
        SIRLPSync      <= SIRLPSync1;

        SIRENSync1     <= SIREN;
        SIRENSync      <= SIRENSync1;
 
        UARTENSync1    <= UARTEN;
        UARTENSync     <= UARTENSync1;

        TXESync1       <= TXE;
        TXESync        <= TXESync1;

        RXESync1       <= RXE;
        RXESync        <= RXESync1;

        UARTFEICSync1  <= UARTFEIC;
        UARTFEICSync   <= UARTFEICSync1;

        UARTPEICSync1  <= UARTPEIC;
        UARTPEICSync   <= UARTPEICSync1;

        UARTBEICSync1  <= UARTBEIC;
        UARTBEICSync   <= UARTBEICSync1;

        UARTDCDICSync1 <= UARTDCDIC;
        UARTDCDICSync  <= UARTDCDICSync1;

        UARTDSRICSync1 <= UARTDSRIC;
        UARTDSRICSync  <= UARTDSRICSync1;

        UARTCTSICSync1 <= UARTCTSIC;
        UARTCTSICSync  <= UARTCTSICSync1;

        UARTRIICSync1  <= UARTRIIC;
        UARTRIICSync   <= UARTRIICSync1;

        UARTRTICSync1  <= UARTRTIC;
        UARTRTICSync   <= UARTRTICSync1;
     end
end // p_CntlSig;

endmodule

// --======================== End of UartSynctoUCLK ==========================--

