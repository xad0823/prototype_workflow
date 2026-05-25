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
//  File Name              : UartApbif.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block generates decodes for Register accesses
// --=========================================================================--

`timescale 1ns/1ps
//------------------------------------------------------------------------------

module UartApbif (
                  PCLK,
                  PRESETn,
                  PSEL,
                  PWRITE,
                  PENABLE,
                  PADDR,
                  PWDATA,
                  RXFF,
                  TXFF,
                  RXFE,
                  TXFE,
                  BUSY,
                  UARTTXRIS,
                  UARTTXMIS,
                  UARTRXRIS,
                  UARTRXMIS,
                  UARTOERIS,
                  UARTOEMIS,
                  UARTRTRIS,
                  UARTRISmodSync,
                  UARTRISerrSync,
                  UARTMISerrSync,
                  UARTMISmodSync,
                  SIRIN,
                  UARTRXD,
                  RXFRdData,
                  TXFIFOData,
                  RXSTATUS,
                  Revision,
                  OverrunDet,
                  TESTFIFO,
                  UARTLCRH,
                  UARTLCRM,
                  UARTLCRL,
                  UARTFBRD,
                  UARTCR,
                  UARTILPR,
                  UARTTCR,
                  UARTIFLS,
                  UARTIMSC,
                  UARTDMACR,
                  UARTITOP,
                  nDCDSyncPCLK,
                  nDSRSyncPCLK,
                  nCTSSyncPCLK,
                  nRISyncPCLK,
                  nUARTDCD,
                  nUARTDSR,
                  nUARTCTS,
                  nUARTRI,
                  UARTTXDMACLR,
                  UARTRXDMACLR,
                  IntTXDMASREQ,
                  IntTXDMABREQ,
                  IntRXDMASREQ,
                  IntRXDMABREQ,
                  IntMSINTR,
                  IntUARTRXMIS,
                  IntUARTTXMIS,
                  IntUARTRTRIS,
                  IntUARTEINTR,
                  IntUARTINTR,
                  UARTDRWrEn,
                  UARTECRWrEn,
                  UARTLCRHnewWrEn,
                  PWDATAIn,
                  PRDATA,
                  UARTREINTR,
                  RXFRdPtrInc,
                  UARTCRnewWrEn,
                  UARTICRWrEn,
                  UARTILPRWrEn,
                  UARTTDRWrEn,
                  UARTIBRDWrEn,
                  UARTFBRDWrEn,
                  UARTIFLSWrEn,
                  UARTIMSCWrEn,
                  UARTDMACRWrEn,
                  UARTTDRrd,
                  UARTTCRWrEn,
                  UARTITIPWrEn,
                  UARTITOPWrEn
                 );

input        PCLK;             // APB Bus clock
input        PRESETn;          // APB Bus reset 
input        PSEL;             // APB Peripheral select
input        PWRITE;           // APB Write
input        PENABLE;          // APB Peripheral enable
input [11:2] PADDR;            // APB Addr bus
input [15:0] PWDATA;           // Wr databus
input        RXFF;             // RX FIFO Full
input        TXFF;             // TX FIFO Full
input        RXFE;             // RX FIFO Empty
input        TXFE;             // TX FIFO Empty
input        BUSY;             // UART Busy
input        UARTTXRIS;        // Transmit Raw Interrupt
input        UARTTXMIS;        // Transmit Masked Interrupt
input        UARTRXRIS;        // Receive Raw Interrupt
input        UARTRXMIS;        // Receive Masked Interrupt
input        UARTOERIS;        // Overrun error Raw Interrupt
input        UARTOEMIS;        // Overrun error Masked Interrupt
input        UARTRTRIS;        // Receive Timeout interrupt
input  [3:0] UARTRISmodSync;   // Raw  modem status
input  [2:0] UARTRISerrSync;   // Raw error interupts
input  [2:0] UARTMISerrSync;   // MAsked error interupts
input  [3:0] UARTMISmodSync;   // Masked modem status
input        SIRIN;            // SIR serial input
input        UARTRXD;          // Receive serial input
input [11:0] RXFRdData;        // RX data
input  [7:0] TXFIFOData;       // TX data
input  [2:0] RXSTATUS;         // RX status
input  [3:0] Revision;         // Revision number
input        OverrunDet;       // Overrun detected
input        TESTFIFO;         // Test signal
input  [7:0] UARTLCRH;         // LCRH
input  [7:0] UARTLCRM;         // LCRM
input  [7:0] UARTLCRL;         // LCRL
input  [5:0] UARTFBRD;         // FBRD
input [15:0] UARTCR;           // CR
input  [7:0] UARTILPR;         // ILPR
input  [2:0] UARTTCR;          // TCR
input  [5:0] UARTIFLS;         // IFLS
input [10:0] UARTIMSC;         // IMSC
input  [2:0] UARTDMACR;        // DMA
input  [5:0] UARTITOP;         // Primary o/p for int test
input        nDCDSyncPCLK;     // Sync'ed DCD
input        nDSRSyncPCLK;     // Sync'ed DSR
input        nCTSSyncPCLK;     // Sync'ed CTS
input        nRISyncPCLK;      // Sync'ed RI
input        nUARTDCD;         // Modem DCD
input        nUARTDSR;         // Modem DSR
input        nUARTCTS;         // Modem CTS
input        nUARTRI;          // Modem RI
input        UARTTXDMACLR;     // Transmit DMACLR
input        UARTRXDMACLR;     // Transmit DMACLR
input        IntTXDMASREQ;     // Transmit DMA single request
input        IntTXDMABREQ;     // Transmit DMA single request
input        IntRXDMASREQ;     // Receive DMA single request
input        IntRXDMABREQ;     // Receive DMA burst request
input        IntMSINTR;        // Modem interrupt for int test
input        IntUARTRXMIS;     // Rx Interrupt for int test
input        IntUARTTXMIS;     // Tx Interrupt for int test
input        IntUARTRTRIS;     // RT Interrupt for int test
input        IntUARTEINTR;     // Error interrupt for int test
input        IntUARTINTR;      // Uart interrupt for int test

output        UARTDRWrEn;      // FIFO Write Enable
output        UARTECRWrEn;     // Write Enable for ECR
output        UARTLCRHnewWrEn; // Write Enable for LCRH
output [15:0] PWDATAIn;        // Int PWDATA
output [15:0] PRDATA;          // Read databus
output        UARTREINTR;      // Combined Raw Error interrupt
output        RXFRdPtrInc;     // RX FIFO read
output        UARTCRnewWrEn;   // Write Enable for UARTCR_new
output        UARTICRWrEn;     // Write Enable for ICR
output        UARTILPRWrEn;    // Write Enable for ILPR
output        UARTTDRWrEn;     // Write Enable for TDR
output        UARTIBRDWrEn;    // Write Enable for IBRD
output        UARTFBRDWrEn;    // Write Enable for FBRD
output        UARTIFLSWrEn;    // Write Enable for IFLS
output        UARTIMSCWrEn;    // Write Enable for IMSC
output        UARTDMACRWrEn;   // Write Enable for DMA
output        UARTTDRrd;       // Test data register read
output        UARTTCRWrEn;     // Write Enable for TCR
output        UARTITIPWrEn;    // Write Enable for UARTITIP
output        UARTITOPWrEn;    // Write Enable for UARTITOP

//------------------------------------------------------------------------------
//                           UartApbif
//                           =========
//------------------------------------------------------------------------------
//
// Overview
// ========
// This module decodes APB accesses and generates the read/write
// strobes to the appropriate registers.
//
//------------------------------------------------------------------------------
//                    Uart Register Map
//------------------------------------------------------------------------------
// Offset Read (Width)         Write (Width)          Description
//------------------------------------------------------------------------------
// 0x00   UARTDR (12bit)       UARTDR (8-bit)         UART Data register
// 0x04   UARTRSR(4bit)        UARTECR                Receive Status (Rd)
//                                                    Error Clr (Wr)
// 0x08   UARTLCR_H(7bit)      UARTLCR_H(7bit)        Line Control register, 
//                                                    High byte
// 0x0C   UARTLCR_M(8bit)      UARTLCR_M(8bit)        Line Control register, 
//                                                    Middle byte
// 0x10   UARTLCR_L(8bit)      UARTLCR_L(8bit)        Line Control register,
//                                                    Low byte
// 0x14   UARTCR (16bit)       UARTCR (16bit)         UART Control Register
// 0x18   UARTFR (9bit)        -                      UART Flag register
// 0x1C   RESERVED
//                                                    Interrupt Clear register
//                                                    (Write)
// 0x20   UARTILPR(8bit)       UARTILPR(8bit)         UART low power counter 
//                                                    register
// 0x24   UARTIBRD(16bit)      UARTBRD(16bit)         Integer Baud Rate Divisor
//                                                    Register
// 0x28   UARTFBRD(6bit)       UARTFBRD(6bit)         Fractional Baud Rate
//                                                    Divisor Register
// 0x2C   UARTLCR_H_new(12bit) UARTLCR_H_new(12bit)   Line Control register,
//                                                    High byte
// 0x30   UARTCR_new(16bit)    UARTCR_new(16bit)      Control register(new)
// 0x34   UARTIFLS(6 bit)      UARTIFLS(6 bit)        Interrupt fifo level
//                                                    select register
// 0x38   UARTIMSC(11bit)      UARTIMSC(11bit)        Interrupt Mask Set/Clear
// 0x3C   UARTRIS(11bit)       -                      Raw Interrupt Status
// 0x40   UARTMIS(11bit)       -                      Masked Interrupt Status
// 0x44     -                  UARTICR(11bit)         Interrupt Clear Register
// 0x48   UARTDMACR(3bit)      UARTDMACR(3bit)        DMA Control Register

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//                Uart Test Register Map - This section is still
//                under development
//------------------------------------------------------------------------------
// Offset Read (Width)    Write (Width)     Description
//------------------------------------------------------------------------------
// 0x80   UARTTCR[3bit)   UARTTCR [3bit)    Test control register
// 0x84   UARTITIP[8bit)  UARTITIP [8bit)   Integration Test input register
// 0x88   UARTITOP[14bit) UARTITOP [14bit)  Integration Test output register
// 0x8C   UARTTDR[11bit)  UARTTDR[11bit)    Test data register

//------------------------------------------------------------------------------
// Identification Registers
//------------------------------------------------------------------------------
// 0xFE0  UARTPeriphID0[8 bits)                          PID0 register
// 0xFE4  UARTPeriphID1[8 bits)                          PID1 register
// 0xFE8  UARTPeriphID2[8 bits)                          PID2 register
// 0xFEC  UARTPeriphID3[8 bits)                          PID3 register
// 0xFF0  UARTPCellID0[8 bits)                           PCID0 register
// 0xFF4  UARTPCellID1[8 bits)                           PCID1 register
// 0xFF8  UARTPCellID2[8 bits)                           PCID2 register
// 0xFFC  UARTPCellID3[8 bits)                           PCID3 register

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Internal Constants
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Normal mode registers address `defines.Address decode is for
// bits 2 to 7 [6 bits)
//------------------------------------------------------------------------------
  `define PADDR_UARTDR       10'b0000000000
  // UARTDR at offset 0x00

  `define PADDR_UARTRSR      10'b0000000001
  // UARTRSR at offset 0x04

  `define PADDR_UARTECR      10'b0000000001
  // UARTECR at offset 0x04

  `define PADDR_UARTFR       10'b0000000110
  // UARTFR at offset 0x18

  `define PADDR_UARTILPR     10'b0000001000
  // UARTILPR at offset 0x20

  `define PADDR_UARTIBRD     10'b0000001001
  // UARTIBRD at offset 0x24

  `define PADDR_UARTFBRD     10'b0000001010
  // UARTFBRD at offset 0x28

  `define PADDR_UARTLCRH_new 10'b0000001011
  // UARTLCRH_new at offset 0x2C

  `define PADDR_UARTCR_new   10'b0000001100
  // UARTCR_new at offset 0x30

  `define PADDR_UARTIFLS     10'b0000001101
  // UARTIFLS at offset 0x34

  `define PADDR_UARTIMSC     10'b0000001110
  // UARTIMSC at offset 0x38

  `define PADDR_UARTRIS      10'b0000001111
  // UARTRIS at offset 0x3C

  `define PADDR_UARTMIS      10'b0000010000
  // UARTMIS at offset 0x40

  `define PADDR_UARTICR      10'b0000010001
  // UARTICR at offset 0x44

  `define PADDR_UARTDMACR    10'b0000010010
  // UARTDMACR at offset 0x48


//------------------------------------------------------------------------------
// Test register's address `defines
//------------------------------------------------------------------------------
  `define PADDR_UARTTCR      10'b0000100000
  // UARTTCR at offset 0x80

  `define PADDR_UARTITIP     10'b0000100001
  // UARTITIP at offset 0x84

  `define PADDR_UARTITOP     10'b0000100010
  // UARTITOP at offset 0x88

  `define PADDR_UARTTDR      10'b0000100011
  // UARTTDR at offset 0x8C

  `define PADDR_PERIPHID0    10'b1111111000
  // PERIPHERALID0 at offset 0xFE0

  `define PADDR_PERIPHID1    10'b1111111001
  // PERIPHERALID1 at offset 0xFE4

  `define PADDR_PERIPHID2    10'b1111111010
  // PERIPHERALID2 at offset 0xFE8

  `define PADDR_PERIPHID3    10'b1111111011
  // PERIPHERALID3 at offset 0xFEC

  `define PADDR_PRIMECELLID0 10'b1111111100
  // PRIMECELLID0 at offset 0xFF0

  `define PADDR_PRIMECELLID1 10'b1111111101
  // PRIMECELLID1 at offset 0xFF4

  `define PADDR_PRIMECELLID2 10'b1111111110
  // PRIMECELLID2 at offset 0xFF8

  `define PADDR_PRIMECELLID3 10'b1111111111
  // PRIMECELLID3 at offset 0xFFC
//------------------------------------------------------------------------------
// Internal wires
//------------------------------------------------------------------------------
wire        PCLK;
// APB Bus clock                                        (Module Input)

wire        PRESETn;
// APB Bus Reset                                        (Module Input)

wire        PSEL;
// APB Peripheral select                                (Module Input)

wire        PENABLE;
// APB Peripheral enable                                (Module Input)

wire        PWRITE;
// APB Write                                            (Module Input)

wire [11:2] PADDR;
// APB Addr bus                                         (Module Input)

wire [15:0] PWDATA;
// Wr databus                                           (Module Input)

wire [11:0] RXFRdData;
// RX data                                              (Module Input)

wire  [7:0] TXFIFOData;
// TX dat                                               (Module Input)

wire        OverrunDet;
// Overrun detecte                                      (Module Input)

wire  [2:0] RXSTATUS;
// RX status                                            (Module Input)

// wire [15:0] CountBaud16;
// Baud count                                           (Module Input)

wire  [7:0] UARTLCRH;
// LCR                                                  (Module Input)

wire  [7:0] UARTLCRM;
// LCR                                                  (Module Input)

wire  [7:0] UARTLCRL;
// LCR                                                  (Module Input)

wire  [5:0] UARTFBRD;
// FBR                                                  (Module Input)

wire        TXFE;
// TX FIFO Empty                                        (Module Input)

wire [15:0] UARTCR;
// CR                                                   (Module Input)

wire        RXFF;
// RX FIFO Full                                         (Module Input)

wire        TXFF;
// TX FIFO Full                                         (Module Input)

wire        RXFE;
// RX FIFO Empty                                        (Module Input)

wire        BUSY;
// UART Busy                                            (Module Input)

wire        nDCDSyncPCLK;
// Sync'ed DC                                           (Module Input)

wire        nDSRSyncPCLK;
// Sync'ed DS                                           (Module Input)

wire        nCTSSyncPCLK;
// Sync'ed CT                                           (Module Input)

wire        nRISyncPCLK;
// Sync'ed R                                            (Module Input)

wire  [7:0] UARTILPR;
// ILP                                                  (Module Input)

wire  [2:0] UARTTCR;
// TC                                                   (Module Input)

wire  [5:0] UARTIFLS;
// IFL                                                  (Module Input)

wire [10:0] UARTIMSC;
// IMS                                                  (Module Input)

wire  [2:0] UARTDMACR;
// DM                                                   (Module Input)

wire        TESTFIFO;
//  Test signal                                         (Module Input)

wire        UARTTXRIS;
// Transmit Raw Interrupt                               (Module Input)

wire        UARTTXMIS;
// Transmit Masked Interrupt                            (Module Input)

wire        UARTRXRIS;
// Receive Raw Interrupt                                (Module Input)

wire        UARTRXMIS;
// Receive Masked Interrupt                             (Module Input)

wire        UARTOERIS;
// Overrun error Raw Interrupt                          (Module Input)

wire        UARTOEMIS;
// Overrun error Masked Interrupt                       (Module Input)

wire        UARTRTRIS;
// Receive Timeout interrupt                            (Module Input)

wire  [3:0] UARTRISmodSync;
// Raw  modem status                                    (Module Input)

wire  [2:0] UARTRISerrSync;
// Raw error interupts                                  (Module Input)

wire  [2:0] UARTMISerrSync;
// MAsked error interupts                               (Module Input)

wire  [3:0] UARTMISmodSync;
// Masked modem status                                  (Module Input)

wire  [3:0] Revision;
// Revision number                                      (Module Input)

wire        SIRIN;
// SIR serial input                                     (Module Input)

wire        UARTRXD;
// Receive serial input                                 (Module Input)

wire        UARTTXDMACLR;
// Transmit DMACL                                       (Module Input)

wire        UARTRXDMACLR;
// Transmit DMACL                                       (Module Input)

wire        IntTXDMASREQ;
// Transmit DMA single request                          (Module Input)

wire        IntTXDMABREQ;
// Transmit DMA single request                          (Module Input)

wire        IntRXDMASREQ;
// Receive DMA single request                           (Module Input)

wire        IntRXDMABREQ;
// Receive DMA burst request                            (Module Input)

wire        IntMSINTR;
// Modem interrupt for int test                         (Module Input)

wire        IntUARTRXMIS;
// Rx Interrupt for int test                            (Module Input)

wire        IntUARTTXMIS;
// Tx Interrupt for int test                            (Module Input)

wire        IntUARTRTRIS;
// RT Interrupt for int test                            (Module Input)

wire        IntUARTEINTR;
// Error interrupt for int test                         (Module Input)

wire        IntUARTINTR;
// Uart interrupt for int test                          (Module Input)

wire  [5:0] UARTITOP;
// Primary o/p for int test                             (Module Input)

wire [11:2] GatedPADDR;
// Save power by gating PADDR internally with PSEL

//------------------------------------------------------------------------------
// Read Decodes for Register reads
//------------------------------------------------------------------------------
wire        UARTDRrd;
// UARTDR Read

wire        UARTRSRrd;
// UARTSR Read

wire        UARTLCRHnewrd;
// LCRH_new Read

wire        UARTCRnewrd;
// UARTCR_new Read

wire        UARTFRrd;
// UARTFR Read

wire        UARTILPRrd;
// ILPR Read

wire        UARTIBRDrd;
// UARTIBRD Read

wire        UARTFBRDrd;
// UARTFBRD Read

wire        UARTTCRrd;
// TCR Read

wire        UARTITIPrd;
// UARTITIP Read

wire        UARTITOPrd;
// UARTITOP Read

wire        UARTIFLSrd;
// IFLS Read

wire        UARTIMSCrd;
// IMSC Read

wire        UARTRISrd;
// RIS Read

wire        UARTMISrd;
// MIS Read

wire        UARTDMACRrd;
// DMA Read

wire        iUARTTDRrd;
// TDR Read

wire        PERIPHID0rd;
// PeripheralID0 read

wire        PERIPHID1rd;
// PeripheralID1 read

wire        PERIPHID2rd;
// PeripheralID2 read

wire        PERIPHID3rd;
// PeripheralID3 read

wire        PRIMECELLID0rd;
// PrimeCellID0 read

wire        PRIMECELLID1rd;
// PrimeCellID1 read

wire        PRIMECELLID2rd;
// PrimeCellID2 read

wire        PRIMECELLID3rd;
// PrimeCellID3 read

wire [15:0] NextPRDATA;
// D-input of iPRDATA

wire        NextUARTREINTR;
// D-input of UARTREINTR

wire  [3:0] UARTRSR;
// RSR concatenation of bits

wire  [8:0] UARTFR;
// Flag register concatenation of bits

wire [10:0] UARTRIS;
// Raw interrupt status register concatenation of modem bits

wire [10:0] UARTMIS;
// Masked interrupt status register concatenation of bits

wire  [1:0] IntraIP;
// Intra chip input

wire  [5:0] PrimaryIP;
// Primary Input

wire  [9:0] IntraOP;
// Intra chip Output

wire  [5:0] PrimaryOP;
// Primary Output

wire        WrEn;
// Write enable signal common to all addresses in the APB interface

wire        RdEn;
// Read enable signal common to all addresses in the APB interface

//------------------------------------------------------------------------------
//  register declaration
//------------------------------------------------------------------------------
reg [15:0] PRDATA;
// Read databus                                         (Module Output)

reg        UARTREINTR;
// Combined Raw Error interrupt                         (Module Output)

//------------------------------------------------------------------------------
//
// Main verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Write Interface
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Save power by preventing change in internal data bus and
// address bus when the device is not selected
//------------------------------------------------------------------------------
assign PWDATAIn         = (PSEL & PWRITE) ? PWDATA : 16'b0000000000000000;

assign GatedPADDR       = (PSEL) ? PADDR : 10'b0000000000;

assign WrEn             = PENABLE & PSEL & PWRITE;

// UARTLCR

assign UARTLCRHnewWrEn  = ((WrEn == 1'b1) && (GatedPADDR == 
                                                         `PADDR_UARTLCRH_new));

// UARTDR
assign UARTDRWrEn       = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTDR));

// UARTECR
assign UARTECRWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTECR));

assign UARTCRnewWrEn    = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTCR_new));

// UARTILPR
assign UARTILPRWrEn     = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTILPR));

// UARTIBRD
assign UARTIBRDWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTIBRD));

// UARTFBRD  
assign UARTFBRDWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTFBRD));

// UARTIMSC
assign UARTIMSCWrEn     = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTIMSC));

// UARTICR
assign UARTICRWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTICR));

// UARTDMACR
assign UARTDMACRWrEn    = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTDMACR));


// UARTTCR
assign UARTTCRWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTTCR));

// UARTITIP
assign UARTITIPWrEn     = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTITIP));

// UARTITOP
assign UARTITOPWrEn     = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTITOP));

// UARTTDR
assign UARTTDRWrEn      = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTTDR));


// UARTIFLS
assign UARTIFLSWrEn     = ((WrEn == 1'b1) && (GatedPADDR == `PADDR_UARTIFLS));

//------------------------------------------------------------------------------
// Read interface
//------------------------------------------------------------------------------
assign RdEn           = PSEL & (! PWRITE);

assign UARTLCRHnewrd  = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTLCRH_new));

assign UARTDRrd       = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTDR));

assign UARTRSRrd      = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTRSR));

assign UARTCRnewrd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTCR_new));

assign UARTFRrd       = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTFR));

assign UARTILPRrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTILPR));

assign UARTIBRDrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTIBRD));

assign UARTFBRDrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTFBRD));

assign UARTIMSCrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTIMSC));

assign UARTRISrd      = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTRIS));

assign UARTMISrd      = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTMIS));

assign UARTDMACRrd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTDMACR));

assign UARTTCRrd      = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTTCR));

assign UARTITIPrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTITIP));

assign UARTITOPrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTITOP));

assign PERIPHID0rd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PERIPHID0));

assign PERIPHID1rd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PERIPHID1));

assign PERIPHID2rd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PERIPHID2));

assign PERIPHID3rd    = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PERIPHID3));

assign UARTIFLSrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTIFLS));

assign iUARTTDRrd     = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_UARTTDR));

assign PRIMECELLID0rd = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PRIMECELLID0));

assign PRIMECELLID1rd = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PRIMECELLID1));

assign PRIMECELLID2rd = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PRIMECELLID2));

assign PRIMECELLID3rd = ((RdEn == 1'b1) && (GatedPADDR == `PADDR_PRIMECELLID3));

assign UARTRSR        = {OverrunDet,RXSTATUS};

assign UARTFR         = {(!nRISyncPCLK), TXFE, RXFF, TXFF, RXFE,
                         BUSY, (! nDCDSyncPCLK), (! nDSRSyncPCLK),
                         (! nCTSSyncPCLK)};

assign UARTRIS        = {UARTOERIS, UARTRISerrSync, UARTRTRIS,
                         UARTTXRIS, UARTRXRIS, UARTRISmodSync};

// The Receive timeout masked and raw interrupts are the same

assign  UARTMIS       = {UARTOEMIS,  UARTMISerrSync, UARTRTRIS,
                         UARTTXMIS, UARTRXMIS, UARTMISmodSync};

assign  PrimaryIP     = {nUARTRI, nUARTDCD, nUARTCTS, nUARTDSR,
                         SIRIN, UARTRXD};

assign  PrimaryOP     = UARTITOP[5:0];

assign  IntraIP       = {UARTTXDMACLR, UARTRXDMACLR};

assign  IntraOP       = {IntTXDMASREQ, IntTXDMABREQ, IntRXDMASREQ, IntRXDMABREQ,
                         IntMSINTR, IntUARTRXMIS, IntUARTTXMIS,
                         IntUARTRTRIS, IntUARTEINTR, IntUARTINTR};

//------------------------------------------------------------------------------
// Increment the Read pointer in the RX FIFO after every read from
// the UARTDR register i.e.  after every read from the Receive FIFO
//------------------------------------------------------------------------------
assign  RXFRdPtrInc = PENABLE & UARTDRrd;

// Output Mux
assign NextPRDATA = (UARTDRrd == 1'b1)         ? {4'b0000, RXFRdData}
                   : (UARTRSRrd == 1'b1)       ? {12'b000000000000, UARTRSR}
                   : (UARTLCRHnewrd == 1'b1)   ? {8'b00000000, UARTLCRH}
                   : (UARTCRnewrd == 1'b1)     ? UARTCR
                   : (UARTFRrd == 1'b1)        ? {7'b0000000, UARTFR}
                   : (UARTILPRrd == 1'b1)      ? {8'b00000000, UARTILPR}
                   : (UARTIBRDrd == 1'b1)      ? {UARTLCRM, UARTLCRL}
                   : (UARTFBRDrd == 1'b1)      ? {10'b0000000000,UARTFBRD}
                   : (UARTIMSCrd == 1'b1)      ? {5'b00000, UARTIMSC}
                   : (UARTRISrd == 1'b1)       ? {5'b00000, UARTRIS}
                   : (UARTMISrd == 1'b1)       ? {5'b00000, UARTMIS}
                   : (UARTDMACRrd == 1'b1)     ? {13'b0000000000000, UARTDMACR}
                   : (UARTTCRrd == 1'b1)       ? {13'b0000000000000, UARTTCR}
                   : (UARTITIPrd == 1'b1)      ? 
                                            {8'b00000000, IntraIP, PrimaryIP}
                   : (UARTITOPrd == 1'b1)      ? {IntraOP, PrimaryOP}
                   : ((iUARTTDRrd == 1'b1) &&
                      (TESTFIFO == 1'b1))      ? {8'b00000000, TXFIFOData}
                   : (UARTIFLSrd == 1'b1)      ? {10'b0000000000, UARTIFLS}
                   : (PERIPHID0rd == 1'b1)     ? {8'b00000000, 8'b00010001}
                   : (PERIPHID1rd == 1'b1)     ? {8'b00000000, 8'b00010000}
                   : (PERIPHID2rd == 1'b1)     ? 
                                             {8'b00000000, Revision, 4'b0100}
                   : (PERIPHID3rd == 1'b1)     ? {8'b00000000, 8'b00000000}
                   : (PRIMECELLID0rd == 1'b1)  ? {8'b00000000, 8'b00001101}
                   : (PRIMECELLID1rd == 1'b1)  ? {8'b00000000, 8'b11110000}
                   : (PRIMECELLID2rd == 1'b1)  ? {8'b00000000, 8'b00000101}
                   : (PRIMECELLID3rd == 1'b1)  ? {8'b00000000, 8'b10110001}
                   : 16'b0000000000000000;

//------------------------------------------------------------------------------
// When the peripheral is not being accessed, 0's are driven
// on the Read Databus (PRDATA) so as not to place any restrictions
// on the method of external bus connection. The external data buses of
// the peripherals on the APB may then be connected to the ASB-to-APB
// bridge using Muxed or ORed bus connection method.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Output register. This register is not reset by the TESTRST bit in the
// UARTTCR register. If it were, it would not be possible to read the
// internal registers with the TESTRST bit set.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_RdSeq
  if (PRESETn == 1'b0)
    PRDATA  <= 16'b0000000000000000;
  else
    PRDATA  <= NextPRDATA;
end // p_RdSeq;

//------------------------------------------------------------------------------
// Combine all raw error interrupts to generate UARTREINTR
//------------------------------------------------------------------------------
assign  NextUARTREINTR = UARTRISerrSync[0] | UARTRISerrSync[1] |
                          UARTRISerrSync[2] | UARTOERIS;

always @(posedge PCLK or negedge PRESETn)
begin : p_REIntSeq 
    if(PRESETn == 1'b0) 
      UARTREINTR <= 1'b0;
    else
      UARTREINTR <= NextUARTREINTR;
end // p_REIntSeq;

//assign the local copy to external port
assign  UARTTDRrd = iUARTTDRrd ;

endmodule

// --============================== End of UartApbif ==========================-
