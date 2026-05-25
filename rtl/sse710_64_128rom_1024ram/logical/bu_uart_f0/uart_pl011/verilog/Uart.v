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
//  File Name              : Uart.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose          : This block is the top level of the Uart.
// --=========================================================================--

`timescale 1ns/1ps

module Uart (
             PCLK,
             UARTCLK,
             PRESETn,
             nUARTRST,
             PSEL,
             PENABLE,
             PWRITE,
             PADDR,
             PWDATA,
             nUARTCTS,
             nUARTDCD,
             nUARTDSR,
             nUARTRI,
             UARTRXD,
             SIRIN,
             UARTTXDMACLR,
             UARTRXDMACLR,
             UARTMSINTR,
             UARTRXINTR,
             UARTTXINTR,
             UARTRTINTR,
             UARTEINTR,
             UARTINTR,
             PRDATA,
             UARTTXD,
             nSIROUT,
             nUARTOut2,
             nUARTOut1,
             nUARTRTS,
             nUARTDTR,
             UARTTXDMASREQ,
             UARTTXDMABREQ,
             UARTRXDMASREQ,
             UARTRXDMABREQ,
             SCANENABLE,
             SCANINPCLK,
             SCANINUCLK,
             SCANOUTPCLK,
             SCANOUTUCLK
           );

input        PCLK;            // APB Bus Clock
input        UARTCLK;         // Main UART Clock
input        PRESETn;         // AMBA Bus reset
input        nUARTRST;        // UART Reset
input        PSEL;            // APB Peripheral select
input        PENABLE;         // APB Peripheral enable
input        PWRITE;          // APB Peripheral write
input [11:2] PADDR;           // APB Addr bus
input [15:0] PWDATA;          // APB write databus
input        nUARTCTS;        // Modem CTS
input        nUARTDCD;        // Modem DCD
input        nUARTDSR;        // Modem DSR
input        nUARTRI;         // Modem RI
input        UARTRXD;         // UART Receive input
input        SIRIN;           // SiR receive input
input        SCANENABLE;      // Test Mode input
input        SCANINPCLK;      // Scan chain input
input        SCANINUCLK;      // Scan chain input
input        UARTTXDMACLR;    // Transmit DMA Clear
input        UARTRXDMACLR;    // Receive DMA Clear

output        UARTMSINTR;     // Modem status interrupt
output        UARTRXINTR;     // UART Receive interrupt
output        UARTTXINTR;     // UART Transmit interrupt
output        UARTRTINTR;     // Receive Timeout interrupt
output        UARTEINTR;      // Combined Error interrupt
output        UARTINTR;	      // Combined interrupt
output [15:0] PRDATA;	      // Read databus
output        UARTTXD;	      // UART Transmit line
output        nSIROUT;	      // SiR Transmit line
output        nUARTOut2;      // Modem Out2
output        nUARTOut1;      // Modem Out1
output        nUARTRTS;	      // Modem RTS
output        nUARTDTR;	      // Modem DTR
output        SCANOUTPCLK;    // Scan chain output
output        SCANOUTUCLK;    // Scan chain output
output        UARTTXDMASREQ;  // Transmit DMA single request
output        UARTTXDMABREQ;  // Transmit DMA burst request
output        UARTRXDMASREQ;  // Receive DMA single request
output        UARTRXDMABREQ;  // Receive DMA burst request


//------------------------------------------------------------------------------
//
//                                Uart
//                                ====
//
//------------------------------------------------------------------------------
//
//  Overview
//  ========
//
// This block is the top level of the UART. This block instantiates the
// functional sub-blocks in the UART.
//  The module UartRevAnd used as a place-holder cell to mark the
// Revision of the Uart. It contains a 2 input AND gate. The 2 input
// pins are tied-off at the top level of the hierarchy. These "TieOffs"
// can be identified during layout and re-wired to "VDD" or "VSS"
// if needed.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        PCLK;
// APB Bus Clock                                      (Module Input)

wire        UARTCLK;
// Main UART Clock                                    (Module Input)

wire        PRESETn;
// AMBA Bus reset                                     (Module Input)

wire        nUARTRST;
// UART Reset                                         (Module Input)

wire        PSEL;
// APB Peripheral select                              (Module Input)

wire        PENABLE;
// APB Peripheral enable                              (Module Input)

wire        PWRITE;
// APB Peripheral write                               (Module Input)

wire [11:2] PADDR;
// APB Addr bus                                       (Module Input)

wire [15:0] PWDATA;
// APB write databus                                  (Module Input)

wire        nUARTCTS;
// Modem CTS                                          (Module Input)

wire        nUARTDCD;
// Modem DCD                                          (Module Input)

wire        nUARTDSR;
// Modem DSR                                          (Module Input)

wire        nUARTRI;
// Modem RI                                           (Module Input)

wire        UARTRXD;
// UART Receive input                                 (Module Input)

wire        SIRIN;
// SiR receive input                                  (Module Input)

wire        SCANENABLE;
// Test Mode input                                    (Module Input)

wire        SCANINPCLK;
// Scan chain input                                   (Module Input)

wire        SCANINUCLK;
// Scan chain input                                   (Module Input)

wire        UARTTXDMACLR;
// Transmit DMA Clear                                 (Module Input)

wire        UARTRXDMACLR;
// Receive DMA Clear                                  (Module Input)

wire [15:0] PWDATAIn;
wire UARTTCRWrEn;
wire UARTLCRHnewWrEn;
wire UARTCRnewWrEn;
wire UARTICRWrEn;
wire UARTIBRDWrEn;
wire UARTFBRDWrEn;
wire UARTTDRWrEn;
wire UARTIMSCWrEn;
wire UARTTDRrd;
wire RXFRdPtrInc;
wire UARTECRWrEn;
wire UARTDRWrEn;
wire UARTRXDint;
wire SIRINint;
wire [7:0] UARTLCRH;
wire [7:0] UARTLCRM;
wire [7:0] UARTLCRL;
wire [5:0] UARTFBRD;
wire [10:0] RXFIFOData;
wire DataStp;
wire LCRUpdateSync;
wire ILPRUpdateSync;
wire FBRDUpdateSync;
wire Baud16;
wire UARTRXDSync;
wire RXFE;
wire RXFESync;
wire RXFWrDone;
wire RXFWrDoneSync;
wire RXD;
wire RXFWr;
wire RXFWrSync;
wire RXFF;
wire OverrunDet;
wire [6:1] LCRH;
wire TXFRdPtrIncSync;
wire TXFRdPtrInc;
wire RdPtrIncDone;
wire RdPtrIncDoneSync;
wire [7:0] TXShiftData;
wire TXFF;
wire TXFE;
wire Abort;
wire AbortSync;
wire TXDataAvlbl;
wire nDCDSyncUARTCLK;
wire nDSRSyncUARTCLK;
wire nCTSSyncUARTCLK;
wire nRISyncUARTCLK;
wire DCDIMSync;
wire DSRIMSync;
wire CTSIMSync;
wire RIIMSync;
wire RTIMSync;
wire FEIMSync;
wire PEIMSync;
wire BEIMSync;
wire IrLPBaud16;
wire UARTENSync;
wire TXESync;
wire RXESync;
wire SIRLPSync;
wire SIRINSync;
wire TXD;
wire MSINTR;
wire [11:0] RXFRdData;
wire nUARTDSRint;
wire nUARTCTSint;
wire nUARTDCDint;
wire nUARTRIint;
wire [2:0] RXSTATUS;
wire UARTILPRWrEn;
wire SIRENSync;
wire TXBUSY;
wire TXDataAvlblSync;
wire RXBUSY;
wire nDCDSyncPCLK;
wire nDSRSyncPCLK;
wire nCTSSyncPCLK;
wire nRISyncPCLK;
wire [2:0] UARTTCR;
wire TXBUSYSync;
wire BUSY;
wire UARTRTICSync;
wire UARTFEICSync;
wire UARTPEICSync;
wire UARTBEICSync;
wire UARTDCDICSync;
wire UARTDSRICSync;
wire UARTCTSICSync;
wire UARTRIICSync;
wire [10:0] UARTICR;
wire [7:0] UARTILPR;
wire ILPRUpdate;
wire LCRUpdate;
wire FBRDUpdate;
wire [15:0] UARTCR;
wire UARTTXDint;
wire iUARTTXD;
wire nSIROUTint;
wire inSIROUT;
wire nUARTOut2int;
wire inUARTOut2;
wire nUARTOut1int;
wire inUARTOut1;
wire nUARTRTSint;
wire inUARTRTS;
wire nUARTDTRint;
wire inUARTDTR;
wire [6:0] UARTLCRHInt;
wire [7:0] TXFIFOData;
wire TestTXFInc;
wire UARTIFLSWrEn;
wire [5:0] UARTIFLS;
wire UARTOEIClr;
wire CharTxComp;
wire CharRxComp;
wire StopBaudCnt;
wire RXEnable;
wire [2:0] UartRXCntlState;
wire [10:0] UARTIMSC;
wire [3:0] UARTRISmodSync;
wire [3:0] UARTMISmodSync;
wire [3:0] UARTRISmod;
wire [3:0] UARTMISmod;
wire [2:0] UARTRISerrSync;
wire [2:0] UARTMISerrSync;
wire [2:0] UARTRISerr;
wire [2:0] UARTMISerr;
wire UARTEINTRfbp;
wire UARTTXRIS;
wire UARTTXMIS;
wire EINTR;
wire UARTREINTR;
wire UARTTXIClr;
wire UARTRXRIS;
wire UARTRXMIS;
wire UARTRTRIS;
wire RTINTR;
wire UARTRXIClr;
wire UARTOERIS;
wire UARTOEMIS;
wire RXFGTE1Full;
wire RXIntLevel;
wire TXFLTE31Full;
wire TXIntLevel;
wire UARTDMACRWrEn;
wire [2:0] UARTDMACR;
wire inUARTRTScr;
wire [3:0] TieOff1;
wire [3:0] TieOff2;
wire [3:0] Revision;
wire IntUARTTXDMACLR;
wire IntUARTRXDMACLR;
wire UARTTXDMACLRSync;
wire UARTRXDMACLRSync; 
wire IntTXDMASREQ;
wire IntTXDMABREQ;
wire IntRXDMASREQ;
wire IntRXDMABREQ;
wire IntMSINTR;
wire IntUARTRXMIS;
wire IntUARTTXMIS;
wire IntUARTRTRIS;
wire IntUARTEINTR;
wire IntUARTINTR;
wire UARTITIPWrEn;
wire UARTITOPWrEn;
wire TXDMASREQ;
wire TXDMABREQ;
wire RXDMASREQ;
wire RXDMABREQ;
wire UARTMSINT;
wire UARTINT;
wire CTSEnSyncUCLK;
wire [5:0] UARTITOP;
wire Zerobaud;
wire BRKSync;
wire CharTxCompSync;
wire [15:0] LoadValue;

assign UARTMSINTR = IntMSINTR;
assign UARTTXD    = iUARTTXD;
assign nSIROUT    = inSIROUT;

// Assign internal versions of DTR, RTS, UARTOut1, UARTOut2
assign nUARTOut2int  = ! UARTCR[13];
assign nUARTOut1int  = ! UARTCR[12];
assign inUARTRTScr   = ! UARTCR[11];
assign nUARTDTRint   = ! UARTCR[10];

// Assign outputs from internal signals
assign nUARTOut2     = inUARTOut2;
assign nUARTOut1     = inUARTOut1;
assign nUARTRTS      = inUARTRTS;
assign nUARTDTR      = inUARTDTR;
assign UARTRTINTR    = IntUARTRTRIS;
assign UARTTXINTR    = IntUARTTXMIS;
assign UARTRXINTR    = IntUARTRXMIS;
assign UARTEINTR     = IntUARTEINTR;
assign UARTINTR      = IntUARTINTR;
assign UARTTXDMASREQ = IntTXDMASREQ;
assign UARTTXDMABREQ = IntTXDMABREQ;
assign UARTRXDMASREQ = IntRXDMASREQ;
assign UARTRXDMABREQ = IntRXDMABREQ;

//------------------------------------------------------------------------------
// Assign the Revision number
//------------------------------------------------------------------------------
assign TieOff1 = 4'b0011;
assign TieOff2 = 4'b1111;

// Register block for normal mode registers
UartRegBlock uUartRegBlock (
                            .PCLK              (PCLK),
                            .PRESETn           (PRESETn),
                            .RXFRdPtrInc       (RXFRdPtrInc),
                            .PWDATAIn          (PWDATAIn),
                            .RXFRdData         (RXFRdData[10:8]),
                            .UARTECRWrEn       (UARTECRWrEn),
                            .UARTLCRHnewWrEn   (UARTLCRHnewWrEn),
                            .UARTILPRWrEn      (UARTILPRWrEn),
                            .UARTCRnewWrEn     (UARTCRnewWrEn),
                            .UARTICRWrEn       (UARTICRWrEn),
                            .UARTIBRDWrEn      (UARTIBRDWrEn),
                            .UARTFBRDWrEn      (UARTFBRDWrEn),
                            .UARTIFLSWrEn      (UARTIFLSWrEn),
                            .UARTIMSCWrEn      (UARTIMSCWrEn),
                            .UARTDMACRWrEn     (UARTDMACRWrEn),
                            .UARTOEIClr        (UARTOEIClr),
                            .UARTRTRIS         (UARTRTRIS),
                            .UARTRISerrSync    (UARTRISerrSync),
                            .UARTRISmodSync    (UARTRISmodSync),
                            .UARTTXIClr        (UARTTXIClr),
                            .UARTRXIClr        (UARTRXIClr),
                            .LCRUpdate         (LCRUpdate),
                            .ILPRUpdate        (ILPRUpdate),
                            .FBRDUpdate        (FBRDUpdate),
                            .UARTICR           (UARTICR),
                            .RXSTATUS          (RXSTATUS),
                            .UARTLCRH          (UARTLCRH),
                            .UARTLCRM          (UARTLCRM),
                            .UARTLCRL          (UARTLCRL),
                            .UARTILPR          (UARTILPR),
                            .UARTCR            (UARTCR),
                            .UARTIFLS          (UARTIFLS),
                            .UARTDMACR         (UARTDMACR),
                            .UARTFBRD          (UARTFBRD),
                            .UARTIMSC          (UARTIMSC)
                          );

// This block provides the interface to the APB bus
UartApbif uUartApbif (
                      .PCLK            (PCLK),
                      .PRESETn         (PRESETn),
                      .PSEL            (PSEL),
                      .PWRITE          (PWRITE),
                      .PENABLE         (PENABLE),
                      .PADDR           (PADDR),
                      .PWDATA          (PWDATA),
                      .RXFF            (RXFF),
                      .TXFF            (TXFF),
                      .RXFE            (RXFE),
                      .TXFE            (TXFE),
                      .BUSY            (BUSY),
                      .UARTTXRIS       (UARTTXRIS),
                      .UARTTXMIS       (UARTTXMIS),
                      .UARTRXRIS       (UARTRXRIS),
                      .UARTRXMIS       (UARTRXMIS),
                      .UARTOERIS       (UARTOERIS),
                      .UARTOEMIS       (UARTOEMIS),
                      .UARTRTRIS       (UARTRTRIS),
                      .UARTRISmodSync  (UARTRISmodSync),
                      .UARTRISerrSync  (UARTRISerrSync),
                      .UARTMISerrSync  (UARTMISerrSync),
                      .UARTMISmodSync  (UARTMISmodSync),
                      .SIRIN           (SIRINint),
                      .UARTRXD         (UARTRXDint),
                      .RXFRdData       (RXFRdData),
                      .TXFIFOData      (TXFIFOData),
                      .RXSTATUS        (RXSTATUS),
                      .Revision        (Revision),
                      .OverrunDet      (OverrunDet),
                      .TESTFIFO        (UARTTCR[1]),
                      .UARTLCRH        (UARTLCRH),
                      .UARTLCRM        (UARTLCRM),
                      .UARTLCRL        (UARTLCRL),
                      .UARTFBRD        (UARTFBRD),
                      .UARTCR          (UARTCR),
                      .UARTILPR        (UARTILPR),
                      .UARTTCR         (UARTTCR),
                      .UARTIFLS        (UARTIFLS),
                      .UARTIMSC        (UARTIMSC),
                      .UARTDMACR       (UARTDMACR),
                      .UARTITOP        (UARTITOP),
                      .nDCDSyncPCLK    (nDCDSyncPCLK),
                      .nDSRSyncPCLK    (nDSRSyncPCLK),
                      .nCTSSyncPCLK    (nCTSSyncPCLK),
                      .nRISyncPCLK     (nRISyncPCLK),
		      .nUARTDCD        (nUARTDCD), 
		      .nUARTDSR        (nUARTDSR),
		      .nUARTCTS        (nUARTCTS),
		      .nUARTRI         (nUARTRI),		      
                      .UARTTXDMACLR    (IntUARTTXDMACLR),
                      .UARTRXDMACLR    (IntUARTRXDMACLR),
                      .IntTXDMASREQ    (IntTXDMASREQ),
                      .IntTXDMABREQ    (IntTXDMABREQ),
                      .IntRXDMASREQ    (IntRXDMASREQ),
                      .IntRXDMABREQ    (IntRXDMABREQ),
                      .IntMSINTR       (IntMSINTR),
                      .IntUARTRXMIS    (IntUARTRXMIS),
                      .IntUARTTXMIS    (IntUARTTXMIS),
                      .IntUARTRTRIS    (IntUARTRTRIS),
                      .IntUARTEINTR    (IntUARTEINTR),
                      .IntUARTINTR     (IntUARTINTR),
                      .UARTDRWrEn      (UARTDRWrEn),
                      .UARTECRWrEn     (UARTECRWrEn),
                      .UARTLCRHnewWrEn (UARTLCRHnewWrEn),
                      .PWDATAIn        (PWDATAIn),
                      .PRDATA          (PRDATA),
                      .UARTREINTR      (UARTREINTR),
                      .RXFRdPtrInc     (RXFRdPtrInc),
                      .UARTCRnewWrEn   (UARTCRnewWrEn),
                      .UARTICRWrEn     (UARTICRWrEn),
                      .UARTILPRWrEn    (UARTILPRWrEn),
                      .UARTTDRWrEn     (UARTTDRWrEn),
                      .UARTIBRDWrEn    (UARTIBRDWrEn),
                      .UARTFBRDWrEn    (UARTFBRDWrEn),
                      .UARTIFLSWrEn    (UARTIFLSWrEn),
                      .UARTIMSCWrEn    (UARTIMSCWrEn),
                      .UARTDMACRWrEn   (UARTDMACRWrEn),
                      .UARTTDRrd       (UARTTDRrd),
                      .UARTTCRWrEn     (UARTTCRWrEn),
                      .UARTITIPWrEn    (UARTITIPWrEn),
                      .UARTITOPWrEn    (UARTITOPWrEn)
                     );

// Synchronisers for signals crossing into PCLK domain
UartSynctoPCLK uUartSynctoPCLK (
                                .PCLK             (PCLK),
                                .PRESETn          (PRESETn),
                                .TXBUSY           (TXBUSY),
                                .TXFRdPtrInc      (TXFRdPtrInc),
                                .RXFWr            (RXFWr),
                                .Abort            (Abort),
                                .DataStp          (DataStp),
                                .nDCD             (nUARTDCDint),
                                .nDSR             (nUARTDSRint),
                                .nCTS             (nUARTCTSint),
                                .nRI              (nUARTRIint),
                                .UARTRISmod       (UARTRISmod),
                                .UARTMISmod       (UARTMISmod),
                                .UARTRISerr       (UARTRISerr),
                                .UARTMISerr       (UARTMISerr),
                                .IntUARTTXDMACLR  (IntUARTTXDMACLR),
                                .IntUARTRXDMACLR  (IntUARTRXDMACLR),
                                .CharTxComp       (CharTxComp),
                                .TXBUSYSync       (TXBUSYSync),
                                .TXFRdPtrIncSync  (TXFRdPtrIncSync),
                                .RXFWrSync        (RXFWrSync),
                                .AbortSync        (AbortSync),
                                .nDCDSyncPCLK     (nDCDSyncPCLK),
                                .nDSRSyncPCLK     (nDSRSyncPCLK),
                                .nCTSSyncPCLK     (nCTSSyncPCLK),
                                .nRISyncPCLK      (nRISyncPCLK),
                                .UARTRTRIS        (UARTRTRIS),
                                .UARTRISmodSync   (UARTRISmodSync),
                                .UARTMISmodSync   (UARTMISmodSync),
                                .UARTRISerrSync   (UARTRISerrSync),
                                .UARTMISerrSync   (UARTMISerrSync),
                                .UARTTXDMACLRSync (UARTTXDMACLRSync),
                                .UARTRXDMACLRSync (UARTRXDMACLRSync),
                                .CharTxCompSync   (CharTxCompSync)
);

// Synchronisers for signals crossing into UARTCLK domain
UartSynctoUCLK uUartSynctoUCLK (
                                .UARTCLK          (UARTCLK),
                                .nUARTRST         (nUARTRST),
                                .BRK              (UARTLCRH[0]),
                                .SIRLP            (UARTCR[2]),
                                .SIREN            (UARTCR[1]),
                                .UARTEN           (UARTCR[0]),
                                .TXE              (UARTCR[8]),
                                .RXE              (UARTCR[9]),
                                .TXDataAvlbl      (TXDataAvlbl),
                                .RXFE             (RXFE),
                                .CTSEn            (UARTCR[15]),
                                .LCRUpdate        (LCRUpdate),
                                .ILPRUpdate       (ILPRUpdate),
                                .FBRDUpdate       (FBRDUpdate),
                                .UARTRXD          (UARTRXDint),
                                .SIRIN            (SIRINint),
                                .RXFWrDone        (RXFWrDone),
                                .RdPtrIncDone     (RdPtrIncDone),
                                .DCDIM            (UARTIMSC[2]),
                                .DSRIM            (UARTIMSC[3]),
                                .CTSIM            (UARTIMSC[1]),
                                .RIIM             (UARTIMSC[0]),
                                .RTIM             (UARTIMSC[6]),
                                .FEIM             (UARTIMSC[7]),
                                .PEIM             (UARTIMSC[8]),
                                .BEIM             (UARTIMSC[9]),
                                .nDCD             (nUARTDCDint),
                                .nDSR             (nUARTDSRint),
                                .nCTS             (nUARTCTSint),
                                .nRI              (nUARTRIint),
                                .UARTDCDIC        (UARTICR[2]),
                                .UARTDSRIC        (UARTICR[3]),
                                .UARTCTSIC        (UARTICR[1]),
                                .UARTRIIC         (UARTICR[0]),
                                .UARTFEIC         (UARTICR[7]),
                                .UARTPEIC         (UARTICR[8]),
                                .UARTBEIC         (UARTICR[9]),
                                .UARTRTIC         (UARTICR[6]),
                                .SIRLPSync        (SIRLPSync),          
                                .SIRENSync        (SIRENSync),
                                .UARTENSync       (UARTENSync),
                                .TXESync          (TXESync),
                                .RXESync          (RXESync),
                                .TXDataAvlblSync  (TXDataAvlblSync),
                                .RXFESync         (RXFESync),
                                .CTSEnSyncUCLK    (CTSEnSyncUCLK),
                                .LCRUpdateSync    (LCRUpdateSync),
                                .ILPRUpdateSync   (ILPRUpdateSync),
                                .FBRDUpdateSync   (FBRDUpdateSync),
                                .UARTRXDSync      (UARTRXDSync),
                                .SIRINSync        (SIRINSync),
                                .RXFWrDoneSync    (RXFWrDoneSync),
                                .RdPtrIncDoneSync (RdPtrIncDoneSync),
                                .DCDIMSync        (DCDIMSync),
                                .DSRIMSync        (DSRIMSync),
                                .CTSIMSync        (CTSIMSync),
                                .RIIMSync         (RIIMSync),
                                .RTIMSync         (RTIMSync),
                                .FEIMSync         (FEIMSync),
                                .PEIMSync         (PEIMSync),
                                .BEIMSync         (BEIMSync),
                                .nDCDSyncUARTCLK  (nDCDSyncUARTCLK),
                                .nDSRSyncUARTCLK  (nDSRSyncUARTCLK),
                                .nCTSSyncUARTCLK  (nCTSSyncUARTCLK),
                                .nRISyncUARTCLK   (nRISyncUARTCLK),
                                .UARTDCDICSync    (UARTDCDICSync),
                                .UARTDSRICSync    (UARTDSRICSync),
                                .UARTCTSICSync    (UARTCTSICSync),
                                .UARTRIICSync     (UARTRIICSync),
                                .UARTFEICSync     (UARTFEICSync),
                                .UARTPEICSync     (UARTPEICSync),
                                .UARTBEICSync     (UARTBEICSync),
                                .UARTRTICSync     (UARTRTICSync),
                                .BRKSync          (BRKSync)
                               );

// Modem interrupt generation block
UartModem uUartModem (
                      .UARTCLK         (UARTCLK),
                      .nUARTRST        (nUARTRST),
                      .SIRENSync       (SIRENSync),
                      .nDCDSyncUARTCLK (nDCDSyncUARTCLK),
                      .nDSRSyncUARTCLK (nDSRSyncUARTCLK),
                      .nCTSSyncUARTCLK (nCTSSyncUARTCLK),
                      .nRISyncUARTCLK  (nRISyncUARTCLK),
                      .UARTDCDICSync   (UARTDCDICSync),
                      .UARTDSRICSync   (UARTDSRICSync),
                      .UARTCTSICSync   (UARTCTSICSync),
                      .UARTRIICSync    (UARTRIICSync),
                      .DCDIMSync       (DCDIMSync),
                      .DSRIMSync       (DSRIMSync),
                      .CTSIMSync       (CTSIMSync),
                      .RIIMSync        (RIIMSync),
                      .UARTMSINT       (UARTMSINT),
                      .UARTRISmod      (UARTRISmod),
                      .UARTMISmod      (UARTMISmod)
                     );

// UART Test logic
UartTest uUartTest (
                    .PCLK            (PCLK),
                    .PRESETn         (PRESETn),
                    .LBE             (UARTCR[7]),
                    .UARTTCRWrEn     (UARTTCRWrEn),
                    .UARTITIPWrEn    (UARTITIPWrEn),
                    .UARTITOPWrEn    (UARTITOPWrEn),
                    .UARTTDRrd       (UARTTDRrd),
                    .PWDATAIn        (PWDATAIn[15:0]),
                    .UARTRXD         (UARTRXD),
                    .SIRIN           (SIRIN),
                    .UARTTXDint      (UARTTXDint),
                    .nSIROUTint      (nSIROUTint),
                    .nUARTCTS        (nUARTCTS),
                    .nUARTDSR        (nUARTDSR),
                    .nUARTDCD        (nUARTDCD),
                    .nUARTRI         (nUARTRI),
                    .nUARTRTSint     (nUARTRTSint),
                    .nUARTDTRint     (nUARTDTRint),
                    .nUARTOut2int    (nUARTOut2int),
                    .nUARTOut1int    (nUARTOut1int),
                    .UARTTXDMACLR    (UARTTXDMACLR),
                    .UARTRXDMACLR    (UARTRXDMACLR),
                    .TXDMASREQ       (TXDMASREQ),
                    .TXDMABREQ       (TXDMABREQ),
                    .RXDMASREQ       (RXDMASREQ),
                    .RXDMABREQ       (RXDMABREQ),
                    .MSINTR          (MSINTR),
                    .UARTRXMIS       (UARTRXMIS),
                    .UARTTXMIS       (UARTTXMIS),
                    .RTINTR          (RTINTR),
                    .EINTR           (EINTR),
                    .UARTINT         (UARTINT),
                    .UARTRXDint      (UARTRXDint),
                    .SIRINint        (SIRINint),
                    .UARTTCR         (UARTTCR),
                    .UARTITOP        (UARTITOP),
                    .TestTXFInc      (TestTXFInc),
                    .nUARTDSRint     (nUARTDSRint),
                    .nUARTCTSint     (nUARTCTSint),
                    .nUARTDCDint     (nUARTDCDint),
                    .nUARTRIint      (nUARTRIint),
                    .IntUARTTXDMACLR (IntUARTTXDMACLR),
                    .IntUARTRXDMACLR (IntUARTRXDMACLR),
                    .IntTXDMASREQ    (IntTXDMASREQ),
                    .IntTXDMABREQ    (IntTXDMABREQ),
                    .IntRXDMASREQ    (IntRXDMASREQ),
                    .IntRXDMABREQ    (IntRXDMABREQ),
                    .IntMSINTR       (IntMSINTR),
                    .IntUARTRXMIS    (IntUARTRXMIS),
                    .IntUARTTXMIS    (IntUARTTXMIS),
                    .IntUARTRTRIS    (IntUARTRTRIS),
                    .IntUARTEINTR    (IntUARTEINTR),
                    .IntUARTINTR     (IntUARTINTR),
                    .nUARTOut2       (inUARTOut2),
                    .nUARTOut1       (inUARTOut1),
                    .nUARTRTS        (inUARTRTS),
                    .nUARTDTR        (inUARTDTR),
                    .nSIROUT         (inSIROUT),
                    .UARTTXD         (iUARTTXD)
                   );

// UART Receiver
UartReceive uUartReceive (
                          .UARTCLK         (UARTCLK),
                          .nUARTRST        (nUARTRST),
                          .UARTENSync      (UARTENSync),
			  .SIRENSync       (SIRENSync),
                          .RXESync         (RXESync),
                          .Baud16          (Baud16),
                          .WLEN            (LCRH[5:4]),
                          .STP2            (LCRH[3]),
                          .EPS             (LCRH[2]),
                          .PEN             (LCRH[1]),
                          .SPS             (LCRH[6]),
                          .RXFWrDoneSync   (RXFWrDoneSync),
                          .Zerobaud        (Zerobaud),
                          .RXFESync        (RXFESync),
                          .RXD             (RXD),
                          .RTIMSync        (RTIMSync),
                          .FEIMSync        (FEIMSync),
                          .PEIMSync        (PEIMSync),
                          .BEIMSync        (BEIMSync),
                          .UARTRTICSync    (UARTRTICSync),
                          .UARTFEICSync    (UARTFEICSync),
                          .UARTPEICSync    (UARTPEICSync),
                          .UARTBEICSync    (UARTBEICSync),
                          .RXFWr           (RXFWr),
                          .RXFIFOData      (RXFIFOData),
                          .DataStp         (DataStp),
                          .RXBUSY          (RXBUSY),
                          .RXEnable        (RXEnable),
                          .UartRXCntlState (UartRXCntlState),
                          .UARTRISerr      (UARTRISerr),
                          .UARTMISerr      (UARTMISerr),
                          .UARTEINTRfbp    (UARTEINTRfbp),
			  .CharRxComp      (CharRxComp)
                         );

// Receive FIFO
UartRXFIFO uUartRXFIFO (
                        .PCLK        (PCLK),
                        .PRESETn     (PRESETn),
                        .PWDATAIn    (PWDATAIn[11:0]),
                        .RXFWrSync   (RXFWrSync),
                        .RXFRdPtrInc (RXFRdPtrInc),
                        .RXFIFOData  (RXFIFOData),
                        .UARTECRWrEn (UARTECRWrEn),
                        .UARTTDRWrEn (UARTTDRWrEn),
                        .FEN         (UARTLCRH[4]),
                        .RTSEn       (UARTCR[14]),
                        .TESTFIFO    (UARTTCR[1]),
                        .nUARTRTScr  (inUARTRTScr),
                        .RXIFLSEL    (UARTIFLS[5:3]),
                        .UARTRXIC    (UARTICR[4]),
                        .UARTOEIC    (UARTICR[10]),
                        .RXIM        (UARTIMSC[4]),
                        .OEIM        (UARTIMSC[10]),
                        .RXFRdData   (RXFRdData),
                        .RXFWrDone   (RXFWrDone),
                        .RXFE        (RXFE),
                        .RXFF        (RXFF),
                        .OverrunDet  (OverrunDet),
                        .nUARTRTSint (nUARTRTSint),
                        .RXFGTE1Full (RXFGTE1Full),
                        .RXIntLevel  (RXIntLevel),
                        .UARTRXIClr  (UARTRXIClr),
                        .UARTOEIClr  (UARTOEIClr),
                        .UARTRXRIS   (UARTRXRIS),
                        .UARTRXMIS   (UARTRXMIS),
                        .UARTOERIS   (UARTOERIS),
                        .UARTOEMIS   (UARTOEMIS)
                       );

// Transmit FIFO
UartTXFIFO uUartTXFIFO (
                        .UARTDRWrEn      (UARTDRWrEn),
                        .PCLK            (PCLK),
                        .PWDATAIn        (PWDATAIn[7:0]),
                        .TXFRdPtrIncSync (TXFRdPtrIncSync),
                        .PRESETn         (PRESETn),
                        .FEN             (UARTLCRH[4]),
                        .BRK             (UARTLCRH[0]),
                        .TXFF            (TXFF),
                        .RdPtrIncDone    (RdPtrIncDone),
                        .TXShiftData     (TXShiftData),
                        .TXDataAvlbl     (TXDataAvlbl),
                        .UARTEN          (UARTCR[0]),
                        .TXE             (UARTCR[8]),
                        .AbortSync       (AbortSync),
                        .TXFE            (TXFE),
                        .TXBUSYSync      (TXBUSYSync),
                        .BUSY            (BUSY),
                        .TESTFIFO        (UARTTCR[1]),
                        .TXFIFOData      (TXFIFOData),
                        .TestTXFInc      (TestTXFInc),
                        .TXIFLSEL        (UARTIFLS[2:0]),
                        .CharTxCompSync  (CharTxCompSync),
                        .UARTTXIC        (UARTICR[5]),
                        .UARTTXIClr      (UARTTXIClr),
                        .TXIM            (UARTIMSC[5]),
                        .UARTTXRIS       (UARTTXRIS),
                        .UARTTXMIS       (UARTTXMIS),
                        .TXFLTE31Full    (TXFLTE31Full),
                        .TXIntLevel      (TXIntLevel)
                       );


// IrDA encoder/decoder
UartIrDA uUartIrDA (
                    .UARTCLK     (UARTCLK),
                    .nUARTRST    (nUARTRST),
                    .Baud16      (Baud16),
                    .IrLPBaud16  (IrLPBaud16),
                    .SIRLPSync   (SIRLPSync),
                    .SIRENSync   (SIRENSync),
                    .SIRTEST     (UARTTCR[2]),
                    .StopBaudCnt (StopBaudCnt),
                    .TXBUSY      (TXBUSY),
                    .RXBUSY      (RXBUSY),
                    .TXD         (TXD),
                    .SIRINSync   (SIRINSync),
                    .UARTRXDSync (UARTRXDSync),
                    .UARTTXDint  (UARTTXDint),
                    .RXD         (RXD),
                    .LoadValue   (LoadValue),
                    .LPLoadValue (UARTILPR),
                    .nSIROUTint  (nSIROUTint)
                   );


// Baud rate generator
UartBaudCntr uUartBaudCntr (
                            .UARTCLK        (UARTCLK),
                            .nUARTRST       (nUARTRST),
                            .LCRUpdateSync  (LCRUpdateSync),
                            .ILPRUpdateSync (ILPRUpdateSync),
                            .FBRDUpdateSync (FBRDUpdateSync),
			    .SIRENSync      (SIRENSync),
			    .SIRLPSync      (SIRLPSync),
			    .CharTxComp     (CharTxComp),
			    .CharRxComp     (CharRxComp),
                            .StopBaudCnt    (StopBaudCnt),
                            .FracValue      (UARTFBRD[5:0]),
                            .UARTLCRHInt    (UARTLCRHInt),
                            .UARTLCRM       (UARTLCRM),
                            .UARTLCRL       (UARTLCRL),
                            .UARTILPR       (UARTILPR),
                            .Baud16         (Baud16),
                            .IrLPBaud16     (IrLPBaud16),
                            .LCRH           (LCRH),
                            .Abort          (Abort),
                            .LoadValue      (LoadValue),
                            .Zerobaud       (Zerobaud)
                           );

assign  UARTLCRHInt = {UARTLCRH[7:5], UARTLCRH[3:0]};

// UART Transmitter
UartTXCntl uUartTXCntl (
                        .UARTCLK          (UARTCLK),
                        .nUARTRST         (nUARTRST),
                        .RXEnable         (RXEnable),
                        .UartRXCntlState  (UartRXCntlState),
                        .CTSEn            (CTSEnSyncUCLK),
                        .nCTSSyncUARTCLK  (nCTSSyncUARTCLK),
                        .Baud16           (Baud16),
                        .TXDataAvlblSync  (TXDataAvlblSync),
                        .RdPtrIncDoneSync (RdPtrIncDoneSync),
                        .UARTENSync       (UARTENSync),
                        .TXESync          (TXESync),
                        .TXShiftData      (TXShiftData),
                        .WLEN             (LCRH[5:4]),
                        .STP2             (LCRH[3]),
                        .PEN              (LCRH[1]),
                        .EPS              (LCRH[2]),
                        .BRK              (BRKSync),
                        .Zerobaud         (Zerobaud),
                        .SPS              (LCRH[6]),
                        .TXFRdPtrInc      (TXFRdPtrInc),
                        .TXD              (TXD),
                        .TXBUSY           (TXBUSY),
                        .CharTxComp       (CharTxComp),
                        .StopBaudCnt      (StopBaudCnt)
                       );

 // DMA Interface
UartDMA uUartDMA (
                  .PCLK             (PCLK),
                  .PRESETn          (PRESETn),
                  .UARTEN           (UARTCR[0]),
                  .TXDMAE           (UARTDMACR[1]),
                  .RXDMAE           (UARTDMACR[0]),
                  .DMAONERR         (UARTDMACR[2]),
                  .TXE              (UARTCR[8]),
                  .RXE              (UARTCR[9]),
                  .FEN              (UARTLCRH[4]),
                  .TESTFIFO         (UARTTCR[1]),
                  .TXIntLevel       (TXIntLevel),
                  .RXIntLevel       (RXIntLevel),
                  .TXFLTE31Full     (TXFLTE31Full),
                  .RXFGTE1Full      (RXFGTE1Full),
                  .UARTTXDMACLRSync (UARTTXDMACLRSync),
                  .UARTRXDMACLRSync (UARTRXDMACLRSync),
                  .UARTREINTR       (UARTREINTR),
                  .TXDMASREQ        (TXDMASREQ),
                  .TXDMABREQ        (TXDMABREQ),
                  .RXDMASREQ        (RXDMASREQ),
                  .RXDMABREQ        (RXDMABREQ)
                 );

// Interrupt block
UartInterrupt  uUartInterrupt 
                            (
                             .DataStp      (DataStp),
                             .UARTMSINT    (UARTMSINT),
                             .UARTEINTRfbp (UARTEINTRfbp),
                             .UARTTXMIS    (UARTTXMIS),
                             .UARTRXMIS    (UARTRXMIS),
                             .UARTOEMIS    (UARTOEMIS),
                             .UARTRTIC     (UARTICR[6]),
                             .UARTDSRIC    (UARTICR[3]),
                             .UARTDCDIC    (UARTICR[2]),
                             .UARTCTSIC    (UARTICR[1]),
                             .UARTRIIC     (UARTICR[0]),
                             .UARTOEIC     (UARTICR[10]),
                             .UARTBEIC     (UARTICR[9]),
                             .UARTPEIC     (UARTICR[8]),
                             .UARTFEIC     (UARTICR[7]),
                             .RTINTR       (RTINTR),
                             .MSINTR       (MSINTR),
                             .EINTR        (EINTR),
                             .UARTINT      (UARTINT)
                            );


//------------------------------------------------------------------------------
// 1st instantiation of UartRevAnd
//------------------------------------------------------------------------------
UartRevAnd u0UartRevAnd (
                         .TieOff1   (TieOff1[0]),
                         .TieOff2   (TieOff2[0]),
                         .Revision  (Revision[0])
                        );

//------------------------------------------------------------------------------
// 2nd instantiation of UartRevAnd
//------------------------------------------------------------------------------
UartRevAnd u1UartRevAnd (
                         .TieOff1  (TieOff1[1]),
                         .TieOff2  (TieOff2[1]),
                         .Revision (Revision[1])
                        );

//------------------------------------------------------------------------------
// 3rd instantiation of UartRevAnd
//------------------------------------------------------------------------------
UartRevAnd u2UartRevAnd (
                         .TieOff1  (TieOff1[2]),
                         .TieOff2  (TieOff2[2]),
                         .Revision (Revision[2])
                        );

//------------------------------------------------------------------------------
// 4th instantiation of UartRevAnd
//------------------------------------------------------------------------------
UartRevAnd u3UartRevAnd (
                         .TieOff1  (TieOff1[3]),
                         .TieOff2  (TieOff2[3]),
                         .Revision (Revision[3])
                        );

endmodule
// --========================== End of Uart ==========================--
