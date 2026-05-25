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
//  File Name              : UartModem.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block generates the Modem status interrupt
// --=========================================================================--

`timescale 1ns/1ps

module UartModem (
                   UARTCLK,
                   nUARTRST,
                   SIRENSync,
                   nDCDSyncUARTCLK,
                   nDSRSyncUARTCLK,
                   nCTSSyncUARTCLK,
                   nRISyncUARTCLK,
                   UARTDCDICSync,
                   UARTDSRICSync,
                   UARTCTSICSync,
                   UARTRIICSync,
                   DCDIMSync,
                   DSRIMSync,
                   CTSIMSync,
                   RIIMSync,
                   UARTMSINT,
                   UARTRISmod,
                   UARTMISmod
                 );

input        UARTCLK;           // Main UART Clock
input        nUARTRST;          // Muxed reset (from nUARTRST)
input        SIRENSync;	        // Inhibit MSINT if SIR enabled
input        nDCDSyncUARTCLK;   // Sync'ed DCD
input        nDSRSyncUARTCLK;   // Sync'ed DSR
input        nCTSSyncUARTCLK;   // Sync'ed CTS
input        nRISyncUARTCLK;    // Sync'ed RI
input        UARTDCDICSync;     // For UARTDCDINTR Clear
input        UARTDSRICSync;     // For UARTDSRINTR Clear
input        UARTCTSICSync;     // For UARTCTSINTR Clear
input        UARTRIICSync;      // For UARTRIINTR Clear
input        DCDIMSync;         // DCD Interrupt enable
input        DSRIMSync;	        // DSR Interrupt enable
input        CTSIMSync;	        // CTS Interrupt enable
input        RIIMSync;	        // RI Interrupt enable

output       UARTMSINT;         // UART Modem Status interrupt
output [3:0] UARTRISmod;        // Raw modem interrupt status
output [3:0] UARTMISmod;        // Masked modem interrupt status

//------------------------------------------------------------------------------
//
//                     UartModem
//                     =========
//
//------------------------------------------------------------------------------
// Overview
// ========
//
// This block asserts the Modem Status Interrupt (UARTMSINT) when any
// change in the modem input lines nDCDSyncUARTCLK, nDSRSyncUARTCLK,
// nCTSSyncUARTCLK and nRISyncUARTCLK is detected.
// The interrupt is cleared when a 1'b1 is written to bit 1 of the
// UARTICR register.
// The UARTMSINTRClr signal is asserted for one UARTCLK period
// whenever a 1'b1 is written to bit 1 of the UARTICR register.
// Change in the modem lines is detected by xoring the signal with
// its delayed version. Once the interrupt is asserted, any further
// changes in the modem lines have no effect on the interrupt status.
// If an edge-detect and UARTMSINTRClr occur at the same time, the
// interrupt is de-asserted for one UARTCLK clock period and then
// asserted again. This helps in systems with edge-triggered
// interrupt controllers.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                      (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                          (Module Input)

wire        UARTDCDICSync;
// For UARTDCDINTR Clear                                (Module Input)

wire        UARTDSRICSync;
// For UARTDSRINTR Clear                                (Module Input)

wire        UARTCTSICSync;
// For UARTCTSINTR Clear                                (Module Input)

wire        UARTRIICSync;
// For UARTRIINTR Clear                                 (Module Input)

wire        DCDIMSync;
// DCD Interrupt enable                                 (Module Input)

wire        DSRIMSync;	
// DSR Interrupt enable                                 (Module Input)

wire        CTSIMSync;	
// CTS Interrupt enable                                 (Module Input)

wire        RIIMSync;	
// RI Interrupt enable                                  (Module Input)

wire        SIRENSync;	
// Inhibit MSINT if SIR enabled                         (Module Input)

wire        nDCDSyncUARTCLK;
// Sync'ed DCD                                          (Module Input)

wire        nDSRSyncUARTCLK;
// Sync'ed DSR                                          (Module Input)

wire        nCTSSyncUARTCLK;
// Sync'ed CTS                                          (Module Input)

wire        nRISyncUARTCLK;
// Sync'ed RI                                           (Module Input)

wire DCDEdge;
// Indicates that an edge has been detected in the DCD Modem signal

wire DSREdge;
// Indicates that an edge has been detected in the DSR Modem signal

wire CTSEdge;
// Indicates that an edge has been detected in the CTS Modem signal

wire RIEdge;
// Indicates that an edge has been detected in the RI Modem signal

wire iUARTDCDMIS;
// Internal copy of DCD masked status

wire iUARTDSRMIS;
// Internal copy of DSR masked status

wire iUARTCTSMIS;
// Internal copy of CTS masked status

wire UARTDCDIClr;
// Clear signal for UARTDCDINTR interrupt

wire UARTDSRIClr;
// Clear signal for UARTDSRINTR interrupt

wire UARTCTSIClr;
// Clear signal for UARTCTSINTR interrupt

wire UARTRIIClr;
// Clear signal for UARTRIINTR interrupt

wire iUARTRIMIS;
// Internal copy of RI  masked status

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
reg nDCDd1;
// Delayed version of nDCDSyncUARTCLK

reg nDSRd1;
// Delayed version of nDSRSyncUARTCLK

reg nCTSd1;
// Delayed version of nCTSSyncUARTCLK

reg nRId1;
// Delayed version of nRISyncUARTCLK

reg NextUARTDCDRIS;
// D-input of raw iUARTDCDINTR

reg NextUARTDSRRIS;
// D-input of raw iUARTDSRINTR

reg NextUARTCTSRIS;
// D-input of raw iUARTCTSINTR

reg NextUARTRIRIS;
// D-input of raw iUARTRIINTR

reg iUARTRIRIS;
// Internal copy of RI raw status

reg iUARTDCDRIS;
// Internal copy of DCD raw status

reg iUARTDSRRIS;
// Internal copy of DSR raw status

reg iUARTCTSRIS;
// Internal copy of CTS raw status

reg DSREdged1;
// Delayed version of DSREdge

reg DCDEdged1;
// Delayed version of DCDEdge

reg CTSEdged1;
// Delayed version of CTSEdge

reg RIEdged1;
// Delayed version of RIEdge

reg DelUARTDCDICSync;
// Delayed version of UARTDCDICSync.Used to detect edge on UARTDCDICSync

reg DelUARTDSRICSync;
// Delayed version of UARTDSRICSync.Used to detect edge on UARTDSRICSync

reg DelUARTCTSICSync;
// Delayed version of UARTCTSICSync.Used to detect edge on UARTCTSICSync

reg DelUARTRIICSync;
// Delayed version of UARTRIICSync. Used to detect edge on UARTRIICSync

//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Detect an edge in any of the modem control lines
//------------------------------------------------------------------------------
assign DCDEdge = nDCDd1 ^ nDCDSyncUARTCLK;
assign DSREdge = nDSRd1 ^ nDSRSyncUARTCLK;
assign CTSEdge = nCTSd1 ^ nCTSSyncUARTCLK;
assign RIEdge  = nRId1  ^ nRISyncUARTCLK;

//------------------------------------------------------------------------------
// The UARTDCDIC, UARTDSRIC, UARTCTSIC and UARTRIIC signals are one
// UARTCLK-wide pulses used to clear the UARTDCDINTR, UARTDSRINTR,
// UARTCTSINTR and the UARTRIINTR interrupts.
//------------------------------------------------------------------------------
assign UARTDCDIClr = UARTDCDICSync & (! DelUARTDCDICSync);
assign UARTDSRIClr = UARTDSRICSync & (!DelUARTDSRICSync);
assign UARTCTSIClr = UARTCTSICSync & (!DelUARTCTSICSync);
assign UARTRIIClr  = UARTRIICSync  & (!DelUARTRIICSync);

//------------------------------------------------------------------------------
// Clear the relevant interrupt on a write to that bit in the
// UARTICR register.  If there is another edge detected at the same
//  clock, then latch this information in the relevant Edged1 flip-flop
//  and assert the interrupt after one UARTCLK clock so as to support
//  edge-triggered interrupt controllers.
//------------------------------------------------------------------------------
always @(UARTDCDIClr or DCDEdge or DCDEdged1 or SIRENSync or
         iUARTDCDRIS)
begin : p_UARTDCDINTR
  NextUARTDCDRIS     = iUARTDCDRIS;
  if (((DCDEdge == 1'b1) || (DCDEdged1 == 1'b1)) && (SIRENSync == 1'b0))
      NextUARTDCDRIS = 1'b1;
  else if ((UARTDCDIClr == 1'b1) || (SIRENSync == 1'b1))
    NextUARTDCDRIS = 1'b0;
end // p_UARTDCDINTR;

assign iUARTDCDMIS = (iUARTDCDRIS & DCDIMSync);

always @(UARTDSRIClr or DSREdge or DSREdged1 or SIRENSync or
         iUARTDSRRIS)
begin : p_UARTDSRINTR
  NextUARTDSRRIS     = iUARTDSRRIS;
  if (((DSREdge == 1'b1) || (DSREdged1 == 1'b1)) && (SIRENSync == 1'b0))
    NextUARTDSRRIS = 1'b1;
  else if ((UARTDSRIClr == 1'b1) || (SIRENSync == 1'b1))
    NextUARTDSRRIS = 1'b0;
end // p_UARTDSRINTR;

assign iUARTDSRMIS = iUARTDSRRIS & DSRIMSync;

always @(UARTCTSIClr or CTSEdge or CTSEdged1 or SIRENSync or
         iUARTCTSRIS)
begin : p_UARTCTSINTR
  NextUARTCTSRIS     = iUARTCTSRIS;
  if (((CTSEdge == 1'b1) || (CTSEdged1 == 1'b1)) && (SIRENSync == 1'b0))
      NextUARTCTSRIS = 1'b1;
  else if ((UARTCTSIClr == 1'b1) || (SIRENSync == 1'b1))
      NextUARTCTSRIS = 1'b0;
end // p_UARTCTSINTR;

assign iUARTCTSMIS = iUARTCTSRIS & CTSIMSync;

always @(UARTRIIClr or RIEdge or RIEdged1 or SIRENSync or iUARTRIRIS)
begin : p_UARTRIINTR
  NextUARTRIRIS     = iUARTRIRIS;
  if (((RIEdge == 1'b1) || (RIEdged1 == 1'b1)) && (SIRENSync == 1'b0))
    NextUARTRIRIS = 1'b1;
  else if ((UARTRIIClr == 1'b1) || (SIRENSync == 1'b1))
    NextUARTRIRIS = 1'b0;
end // p_UARTRIINTR;

assign  iUARTRIMIS = iUARTRIRIS & RIIMSync;

assign  UARTRISmod[3] = iUARTDSRRIS;
assign  UARTRISmod[2] = iUARTDCDRIS;
assign  UARTRISmod[1] = iUARTCTSRIS;
assign  UARTRISmod[0] = iUARTRIRIS;

assign  UARTMISmod[3] = iUARTDSRMIS;
assign  UARTMISmod[2] = iUARTDCDMIS;
assign  UARTMISmod[1] = iUARTCTSMIS;
assign  UARTMISmod[0] = iUARTRIMIS;

//------------------------------------------------------------------------------
// The combined Modem interrupt UARTMSINT is asserted when any if
// the individual modem interrupts are asserted.
//------------------------------------------------------------------------------
assign  UARTMSINT = iUARTDCDMIS | iUARTDSRMIS | iUARTCTSMIS | iUARTRIMIS;

always @(posedge UARTCLK or negedge nUARTRST)
  begin : p_MSIntReg
    if (nUARTRST == 1'b0)
      begin
        nDCDd1           <= 1'b0;
        nDSRd1           <= 1'b0;
        nCTSd1           <= 1'b0;
        nRId1            <= 1'b0;
        iUARTRIRIS       <= 1'b0;
        iUARTDCDRIS      <= 1'b0;
        iUARTDSRRIS      <= 1'b0;
        iUARTCTSRIS      <= 1'b0;
        DSREdged1        <= 1'b0;
        DCDEdged1        <= 1'b0;
        CTSEdged1        <= 1'b0;
        RIEdged1         <= 1'b0;
        DelUARTRIICSync  <= 1'b0;
        DelUARTDCDICSync <= 1'b0;
        DelUARTDSRICSync <= 1'b0;
        DelUARTCTSICSync <= 1'b0;
      end
    else
      begin
        nDCDd1           <= nDCDSyncUARTCLK;
        nDSRd1           <= nDSRSyncUARTCLK;
        nCTSd1           <= nCTSSyncUARTCLK;
        nRId1            <= nRISyncUARTCLK;
        iUARTRIRIS       <= NextUARTRIRIS;
        iUARTDCDRIS      <= NextUARTDCDRIS;
        iUARTDSRRIS      <= NextUARTDSRRIS;
        iUARTCTSRIS      <= NextUARTCTSRIS;
        DSREdged1        <= DSREdge;
        DCDEdged1        <= DCDEdge;
        CTSEdged1        <= CTSEdge;
        RIEdged1         <= RIEdge;
        DelUARTRIICSync  <= UARTRIICSync;
        DelUARTDCDICSync <= UARTDCDICSync;
        DelUARTDSRICSync <= UARTDSRICSync;
        DelUARTCTSICSync <= UARTCTSICSync;
      end
end // p_MSIntReg;

endmodule

// --========================== End of UartModem =============================--

