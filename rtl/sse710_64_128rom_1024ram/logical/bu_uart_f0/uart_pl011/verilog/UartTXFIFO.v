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
//  File Name              : UartTXFIFO.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose  : This block instantiates the UartTXFCntl (Transmit FIFO
//           control)  and the UartTXRegFile (Register File) blocks.
// --=========================================================================--

`timescale 1ns/1ps

module UartTXFIFO (
                   PCLK,
                   PRESETn,
                   UARTEN,
                   TXE,
                   UARTDRWrEn,
                   TXFRdPtrIncSync,
                   FEN,
                   BRK,
                   AbortSync,
                   TXBUSYSync,
                   PWDATAIn,
                   TESTFIFO,
                   TXIFLSEL,
                   TXFF,
                   TXFE,        
                   RdPtrIncDone,        
                   TXShiftData,
                   TXDataAvlbl,
                   BUSY,        
                   TXFIFOData,
                   TestTXFInc,
                   CharTxCompSync,
                   UARTTXIC,
                   UARTTXIClr,
                   TXIM,
                   UARTTXRIS,
                   UARTTXMIS,
                   TXFLTE31Full,
                   TXIntLevel
                  );

input        PCLK;                // APB Clock
input        PRESETn;             // APB Bus Reset
input        UARTEN;              // UART Enable
input        TXE;                 // TX Enable
input        UARTDRWrEn ;         // TX FIFO Write enable
input        TXFRdPtrIncSync;     // TX FIFO Rd Ptr Inc
input        FEN;                 // FIFO Enable
input        BRK;                 // Break request
input        AbortSync;           // Transmission aborted
input        TXBUSYSync ;         // Transmitter busy
input [7:0]  PWDATAIn;            // Data bus
input        TESTFIFO;            // Test signal
input [2:0]  TXIFLSEL;            // fifo interrupt level select
input        UARTTXIC;            // For Tx Interrupt clear
input        TXIM;                // Tx Interrupt Mask
input        TestTXFInc;          // tx fifo rdptr inc
input        CharTxCompSync;

output        TXFF;               // Transmit FIFO Full
output        TXFE;               // Transmit FIFO Empty
output        RdPtrIncDone;       // Rd Ptr Inc done
output [7:0]  TXShiftData;        // Xmit Data
output        TXDataAvlbl;        // TX Data Available
output        BUSY;               // UART BUSY
output [7:0]  TXFIFOData;         // TX fifo data
output        UARTTXIClr;         // Tx Interrupt clear
output        UARTTXRIS;          // Transmit Raw Interrupt
output        UARTTXMIS;          // Transmit Masked Interrupt
output        TXFLTE31Full;       // To DMA block
output        TXIntLevel;         // Programmable Interrupt Level

//------------------------------------------------------------------------------
//
//                                 UartTXFIFO
//                                 ==========
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
//   Writes to the transmit FIFO occur through the APB interface from
//   the PCLK domain. Reads from the transmit FIFO occur from the transm
//   it block which falls in the UARTCLK clock domain. The FIFO is 8-bit
//   wide and 16-deep.
//   The UartTXFCntl module contains the control logic for the FIFO. It
//   contains a write pointer, a read pointer and a transmit shift
//   register. Writes from the APB can occur as close as every two PCLK
//   periods. So as to ensure that no writes are missed, the write
//   pointer operates on PCLK. To facilitate FIFO fill level calculation
//   the read pointer is also operated on PCLK.
//   Write data from the APB is written into the location pointed to by
//   the current value of the write pointer. If a write occurs to the
//   FIFO when it is already full, the write is ignored.
//   The TXDataAvlbl output signal is asserted when there is data
//   available to be transmitted. Upon detecting this signal, the
//   transmitter commences transmission. At the end of transmission of
//   one data byte, the transmitter asserts the RdPtrInc signal.
//   The fifo can be set to be in TESTFIFO mode which allows data to
//   be read out of theTx fifo.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// wire declaration
//------------------------------------------------------------------------------
wire        PCLK;       
// APB Clock                                             (Module Input)

wire        PRESETn;    
// APB Bus Reset                                         (Module Input)

wire        UARTEN;     
// UART Enable                                           (Module Input)

wire        TXE;        
// TX Enable                                             (Module Input)

wire        UARTDRWrEn  ;
// TX FIFO Write enable                                  (Module Input)

wire        TXFRdPtrIncSync;
// TX FIFO Rd Ptr Inc                                    (Module Input)

wire        FEN;
// FIFO Enable                                           (Module Input)

wire        AbortSync;  
// Transmission aborted                                  (Module Input)

wire        TXBUSYSync  ;
// Transmitter busy                                      (Module Input)

wire [7:0]  PWDATAIn;           
// Data bus                                              (Module Input)

wire        TESTFIFO;
// Test signal                                           (Module Input)

wire [2:0]  TXIFLSEL;
// fifo interrupt level select                           (Module Input)

wire        UARTTXIC;
// For Tx Interrupt clear                                (Module Input)

wire        TXIM;
// Tx Interrupt Mask                                     (Module Input)

wire        TestTXFInc;
// tx fifo rdptr inc                                     (Module Input)

wire        CharTxCompSync;
wire [4:0]  WrPtr;
wire [4:0]  RdPtr;
wire        RegFileWrEn;
wire [7:0]  iTXFIFOData;


//------------------------------------------------------------------------------
// The UartTXRegFile is a data buffer implemented using D-types.
//------------------------------------------------------------------------------
 UartTXRegFile uUartTXRegFile (
                               .WrPtr       (WrPtr),
                               .PWDATAIn    (PWDATAIn),
                               .RegFileWrEn (RegFileWrEn),
                               .PCLK        (PCLK),
                               .RdPtr       (RdPtr),
                               .iTXFIFOData (iTXFIFOData),
                               .PRESETn     (PRESETn)
                               );


//------------------------------------------------------------------------------
// The UartTXFCntl block controls accesses to the FIFO register file.
//------------------------------------------------------------------------------
 UartTXFCntl uUartTXFCntl (
                           .WrPtr           (WrPtr),
                           .RegFileWrEn     (RegFileWrEn),
                           .RdPtr           (RdPtr),
                           .PCLK            (PCLK),
                           .PWDATAIn        (PWDATAIn),
                           .TXFF            (TXFF),
                           .TXFE            (TXFE),
                           .TXDataAvlbl     (TXDataAvlbl),
                           .PRESETn         (PRESETn),
                           .FEN             (FEN),
                           .BRK             (BRK),
                           .TXShiftData     (TXShiftData),
                           .UARTEN          (UARTEN),
                           .TXE             (TXE),
                           .UARTDRWrEn      (UARTDRWrEn),
                           .RdPtrIncDone    (RdPtrIncDone),
                           .AbortSync       (AbortSync),
                           .TXFRdPtrIncSync (TXFRdPtrIncSync),
                           .TXBUSYSync      (TXBUSYSync),
                           .BUSY            (BUSY),
                           .TESTFIFO        (TESTFIFO),
                           .TestTXFInc      (TestTXFInc),
                           .TXIFLSEL        (TXIFLSEL),
                           .iTXFIFOData     (iTXFIFOData),
                           .CharTxCompSync  (CharTxCompSync),
                           .TXIM             (TXIM),
                           .UARTTXIC         (UARTTXIC),
                           .UARTTXIClr       (UARTTXIClr),
                           .UARTTXRIS        (UARTTXRIS),
                           .UARTTXMIS        (UARTTXMIS),
                           .TXFLTE31Full     (TXFLTE31Full),
                           .TXIntLevel       (TXIntLevel)
                          );

assign TXFIFOData = iTXFIFOData;

endmodule

// --============================ End of UartTXFIFO ==========================--
