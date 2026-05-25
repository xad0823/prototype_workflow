// =============================================================================
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited.
//    (C) COPYRIGHT 1999-2000 ARM Limited
//        ALL RIGHTS RESERVED
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited.
//------------------------------------------------------------------------------
//
//  Version and Release Control Information:
//
//  File Name              : UartTest.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the test logic for the UART.
//==============================================================================

`timescale 1ns/1ps
module UartTest (
                 PCLK,
                 PRESETn,
                 LBE,
                 UARTTCRWrEn,
                 UARTITIPWrEn,
                 UARTITOPWrEn,
                 UARTTDRrd,
                 PWDATAIn,
                 UARTRXD,
                 SIRIN,
                 UARTTXDint,
                 nSIROUTint,
                 nUARTCTS,
                 nUARTDSR,
                 nUARTDCD,
                 nUARTRI,
                 nUARTRTSint,
                 nUARTDTRint,
                 nUARTOut2int,
                 nUARTOut1int,
                 UARTTXDMACLR,
                 UARTRXDMACLR,
                 TXDMASREQ,
                 TXDMABREQ,
                 RXDMASREQ,
                 RXDMABREQ,
                 MSINTR,
                 UARTRXMIS,
                 UARTTXMIS,
                 RTINTR,
                 EINTR,
                 UARTINT,
                 UARTRXDint,
                 SIRINint,
                 UARTTCR,
                 UARTITOP,
                 TestTXFInc,
                 nUARTDSRint,
                 nUARTCTSint,
                 nUARTDCDint,
                 nUARTRIint,
                 IntUARTTXDMACLR,
                 IntUARTRXDMACLR,
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
                 nUARTOut2,
                 nUARTOut1,
                 nUARTRTS,
                 nUARTDTR,
                 nSIROUT,
                 UARTTXD
                );

input        PCLK;              // APB Clock
input        PRESETn;           // APB Bus Reset
input        LBE;               // Loop Back Enable
input        UARTTCRWrEn;       // Write enable for TCR
input        UARTITIPWrEn;      // Write enable for iUARTITIP
input        UARTITOPWrEn;      // Write enable for UARTITOP
input        UARTTDRrd;         // Read enable for TDR
input [15:0] PWDATAIn;          // Wr DataBus
input        UARTRXD;           // Receive serial input
input        SIRIN;             // SIR serial input
input        UARTTXDint;        // TXD output read back
input        nSIROUTint;        // SIR output read back
input        nUARTCTS;          // Modem signal
input        nUARTDSR;          // Modem signal
input        nUARTDCD;          // Modem signal
input        nUARTRI;           // Modem signal
input        nUARTRTSint;       // Modem signal
input        nUARTDTRint;       // Modem signal
input        nUARTOut2int;      // Modem signal
input        nUARTOut1int;      // Modem signal
input        UARTTXDMACLR;      // Transmit DMACLR
input        UARTRXDMACLR;      // Receive DMACLR
input        TXDMASREQ;         // Transmit DMA single request
input        TXDMABREQ;         // Transmit DMA burst request
input        RXDMASREQ;         // Receive DMA single request
input        RXDMABREQ;         // Receive DMA burst request
input        MSINTR;            // modem interrupt
input        UARTRXMIS;         // RX interrupt
input        UARTTXMIS;         // TX interrupt
input        RTINTR;            // RT interrupt
input        EINTR;             // Error interrupt
input        UARTINT;           // Uart interrupt

output       UARTRXDint;        // To IrDA module
output       SIRINint;          // Ti IrDA block
output [2:0] UARTTCR;           // TCR
output [5:0] UARTITOP;          // ITOP
output       TestTXFInc;        //  Read pointer increment signal for Tx fifo
output       nUARTDSRint;       // To synchronisers
output       nUARTCTSint;       // To synchronisers
output       nUARTDCDint;       // To synchronisers
output       nUARTRIint;        // To synchronisers
output       IntUARTTXDMACLR;   // Transmit DMACLR
output       IntUARTRXDMACLR;   // Receive DMACLR
output       IntTXDMASREQ;      // Transmit DMA single request
output       IntTXDMABREQ;      // Transmit DMA burst request
output       IntRXDMASREQ;      // Receive DMA single request
output       IntRXDMABREQ;      // Receive DMA burst request
output       IntMSINTR;         // Modem status interrupt
output       IntUARTRXMIS;      // RX Interrupt for int test
output       IntUARTTXMIS;      // TX Interrupt for int test
output       IntUARTRTRIS;      // RT Interrupt for int test
output       IntUARTEINTR;      // Error Interrupt for int test
output       IntUARTINTR;       // Uart Interrupt for int test
output       nUARTOut2;         // Modem signal primary O/P
output       nUARTOut1;         // Modem signal primary O/P
output       nUARTRTS;          // Modem signal primary O/P
output       nUARTDTR;          // Modem signal primary O/P
output       nSIROUT;           // SIR primary O/P
output       UARTTXD;           // UART primary O/P

//------------------------------------------------------------------------------
//
//                   UartTest
//                   ========
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//  This block contains the Test registers in the UART. It includes
//  the  logic for the loopback function, and the logic for the
//  integration tests.
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        PCLK;
// APB Clock                                            (Module Input)

wire        PRESETn;
// APB Bus Reset                                        (Module Input)

wire        UARTTCRWrEn;
// Write enable for TCR                                 (Module Input)

wire        UARTITIPWrEn;
// Write enable for iUARTITIP                           (Module Input)

wire        UARTITOPWrEn;
// Write enable for UARTITOP                            (Module Input)

wire        UARTTDRrd;
// Read enable for TDR                                  (Module Input)

wire        LBE;
// Loop Back Enable                                     (Module Input)

wire        UARTRXD;
// Receive serial input                                 (Module Input)

wire        SIRIN;
// SIR serial input                                     (Module Input)

wire        nUARTCTS;
// Modem signal                                         (Module Input)

wire        nUARTDSR;
// Modem signal                                         (Module Input)

wire        nUARTDCD;
// Modem signal                                         (Module Input)

wire        nUARTRI;
// Modem signal                                         (Module Input)

wire        UARTTXDint;
// TXD output read back                                 (Module Input)

wire        nSIROUTint;
// SIR output read back                                 (Module Input)

wire        nUARTRTSint;
// Modem signal                                         (Module Input)

wire        nUARTDTRint;
// Modem signal                                         (Module Input)

wire        nUARTOut2int;
// Modem signal                                         (Module Input)

wire        nUARTOut1int;
// Modem signal                                         (Module Input)

wire [15:0] PWDATAIn;
// Wr DataBus                                           (Module Input)

wire        UARTTXDMACLR;
// Transmit DMACLR                                      (Module Input)

wire        UARTRXDMACLR;
// Receive DMACLR                                       (Module Input)

wire        TXDMASREQ;
// Transmit DMA single request                          (Module Input)

wire        TXDMABREQ;
// Transmit DMA burst request                           (Module Input)

wire        RXDMASREQ;
// Receive DMA single request                           (Module Input)

wire        RXDMABREQ;
// Receive DMA burst request                            (Module Input)

wire       MSINTR;
// modem interrupt                                      (Module Input)

wire        UARTRXMIS;
// RX interrupt                                         (Module Input)

wire        UARTTXMIS;
// TX interrupt                                         (Module Input)

wire        RTINTR;
// RT interrupt                                         (Module Input)

wire        EINTR;
// Error interrupt                                      (Module Input)

wire        UARTINT;
// Uart interrupt                                       (Module Input)

wire        iTESTFIFO;
// Test Signal to enable writing into Rx fifo and read from Tx fifo
// Test Fifo signal allows data to be written to the Rx fifo and
// read  from the Tx fifo.  When set to 0 the Tx fifo can only be
// written to and the Rx fifo read from.

//------------------------------------------------------------------------------
// Test control signals
//------------------------------------------------------------------------------
wire        ITEN;
// Integration test enable. When set to 1, the iUARTITIP and
// iUARTITOP registers are used to read/write values to the inputs
// and outputs.

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
reg  [2:0] iUARTTCR;
// UART Test Control Register

reg [15:0] iUARTITOP;
// UART Integration test output Register

reg  [7:6] iUARTITIP;
// UART Integration test input Register

reg  [2:0] NextUARTTCR;
// D-input of iUARTTCR

reg  [7:6] NextUARTITIP;
// D-input of iUARTITIP

reg  [15:0] NextUARTITOP;
// D-input of iUARTITOP

reg         delUARTTDRrd;
// delayed version of UARTTDRrd

//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Test Registers
//------------------------------------------------------------------------------
always @(UARTTCRWrEn or UARTITIPWrEn or UARTITOPWrEn or iUARTTCR or iUARTITIP or
         iUARTITOP or PWDATAIn)
begin : p_TestRegComb
  NextUARTTCR   = iUARTTCR;
  NextUARTITIP  = iUARTITIP;
  NextUARTITOP  = iUARTITOP;

  if(UARTTCRWrEn == 1'b1)
    NextUARTTCR = PWDATAIn[2:0];

  if(UARTITIPWrEn == 1'b1)
    NextUARTITIP = PWDATAIn[7:6];

  if(UARTITOPWrEn == 1'b1)
    NextUARTITOP = PWDATAIn[15:0];

end // p_TestRegComb

always @(posedge PCLK or negedge PRESETn)
begin : p_TestRegSeq
  if(PRESETn == 1'b0)
    begin
      iUARTTCR   <= 1'b0;
      iUARTITIP  <= 1'b0;
      iUARTITOP  <= 1'b0;
    end
  else
    begin
      iUARTTCR   <= NextUARTTCR;
      iUARTITIP  <= NextUARTITIP;
      iUARTITOP  <= NextUARTITOP;
    end
end // p_TestRegSeq

//------------------------------------------------------------------------------
// Generate Read pointer Increment signals for TestFifo
// mode when  reading from the Tx fifo.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_RXTestFptrInc
  if(PRESETn == 1'b0)
    delUARTTDRrd <= 1'b0;
  else if(iTESTFIFO == 1'b1)
    delUARTTDRrd <= UARTTDRrd;
end // p_RXTestFptrInc;

assign TestTXFInc = (UARTTDRrd) & delUARTTDRrd;

// Local copy to external port
assign  UARTTCR   = iUARTTCR;
assign  UARTITOP  = iUARTITOP[5:0];
assign  ITEN      = iUARTTCR[0];
assign  iTESTFIFO = iUARTTCR[1];

//------------------------------------------------------------------------------
// If the LBE input is asserted, UARTTXDint is connected to UARTRXDInt and
// nSIROUTint is connected through an inverter to SIRINInt to implement
// loopback.  The modem signals are also connected nUARTRTSint to
// nUARTCTSint, nUARTDTRint to nUARTDSRint, nUARTOut2int to  nUARTRIint
// and nUARTOut1int to nUARTDCDint to implement loopback.
//------------------------------------------------------------------------------

assign  UARTRXDint    = (LBE == 1'b1)   ? UARTTXDint     : UARTRXD;

assign  SIRINint      = (LBE == 1'b1)   ? !(nSIROUTint)  : SIRIN;

assign  nUARTCTSint   = (LBE == 1'b1)   ? nUARTRTSint    : nUARTCTS;

assign  nUARTDSRint   = (LBE == 1'b1)   ? nUARTDTRint    : nUARTDSR;

assign  nUARTRIint    = (LBE == 1'b1)   ? nUARTOut2int   : nUARTRI;

assign  nUARTDCDint   = (LBE == 1'b1)   ? nUARTOut1int   : nUARTDCD;

//------------------------------------------------------------------------------
// Intra chip inputs.
// If ITEN (Integration test enable bit) is high, the iUARTITIP
// register value is used; else the functional mode input is driven on
// the DMACLR signals.
//------------------------------------------------------------------------------
assign IntUARTTXDMACLR  = (ITEN == 1'b1) ? iUARTITIP[7] : UARTTXDMACLR;

assign IntUARTRXDMACLR  = (ITEN == 1'b1) ? iUARTITIP[6] : UARTRXDMACLR;

//------------------------------------------------------------------------------
// Intra chip outputs.
// If ITEN (Integration test enable bit) is high, the iUARTITOP
// register value is used; else the functional mode value is driven
// on to the port.
//------------------------------------------------------------------------------
assign IntTXDMASREQ   = (ITEN == 1'b1) ? iUARTITOP[15] : TXDMASREQ;

assign IntTXDMABREQ   = (ITEN == 1'b1) ? iUARTITOP[14] : TXDMABREQ;

assign IntRXDMASREQ   = (ITEN == 1'b1) ? iUARTITOP[13] : RXDMASREQ;

assign IntRXDMABREQ   = (ITEN == 1'b1) ? iUARTITOP[12] : RXDMABREQ;

assign IntMSINTR      = (ITEN == 1'b1) ? iUARTITOP[11] : MSINTR;

assign IntUARTRXMIS   = (ITEN == 1'b1) ? iUARTITOP[10] : UARTRXMIS;

assign IntUARTTXMIS   = (ITEN == 1'b1) ? iUARTITOP[9]  : UARTTXMIS;

assign IntUARTRTRIS   = (ITEN == 1'b1) ? iUARTITOP[8]  : RTINTR;

assign IntUARTEINTR   = (ITEN == 1'b1) ? iUARTITOP[7]  : EINTR;

assign IntUARTINTR    = (ITEN == 1'b1) ? iUARTITOP[6]  : UARTINT;

//------------------------------------------------------------------------------
// Primary Output Mux
// If ITEN (Integration test enable bit) is high, the iUARTITOP
// register value is used; else the functional mode value is driven
// on to the pin.
//------------------------------------------------------------------------------
assign nUARTOut2   = (ITEN == 1'b1) ? iUARTITOP[5] : nUARTOut2int;

assign nUARTOut1   = (ITEN == 1'b1) ? iUARTITOP[4] : nUARTOut1int;

assign nUARTRTS    = (ITEN == 1'b1) ? iUARTITOP[3] : nUARTRTSint;

assign nUARTDTR    = (ITEN == 1'b1) ? iUARTITOP[2] : nUARTDTRint;

assign nSIROUT     = (ITEN == 1'b1) ? iUARTITOP[1] : nSIROUTint;

assign UARTTXD     = (ITEN == 1'b1) ? iUARTITOP[0] : UARTTXDint;

endmodule

//========================== End of UartTest =================================--
