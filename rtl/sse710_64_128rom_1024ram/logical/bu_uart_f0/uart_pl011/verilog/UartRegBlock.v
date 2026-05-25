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
//  File Name              : UartRegBlock.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the normal mode registers for the Uart.
// --=========================================================================--

`timescale 1ns/1ps

module UartRegBlock (
                     PCLK,
                     PRESETn,
                     RXFRdPtrInc,
                     PWDATAIn,
                     RXFRdData,
                     UARTECRWrEn,
                     UARTLCRHnewWrEn,
                     UARTILPRWrEn,
                     UARTCRnewWrEn,
                     UARTICRWrEn,
                     UARTIBRDWrEn,
                     UARTFBRDWrEn,
                     UARTIFLSWrEn,
                     UARTIMSCWrEn,
                     UARTDMACRWrEn,
                     UARTOEIClr,
                     UARTRTRIS,
                     UARTRISerrSync,
                     UARTRISmodSync,
                     UARTTXIClr,
                     UARTRXIClr,
                     LCRUpdate,
                     ILPRUpdate,
                     FBRDUpdate,
                     UARTICR,
                     RXSTATUS,
                     UARTLCRH,
                     UARTLCRM,
                     UARTLCRL,
                     UARTILPR,
                     UARTCR,
                     UARTIFLS,
                     UARTDMACR,
                     UARTFBRD,
                     UARTIMSC
                    );

input          PCLK;              // APB Bus Clock
input          PRESETn;           // APB Bus Reset
input          RXFRdPtrInc;       // RX FIFO Read pointer Incr.
input [15:0]   PWDATAIn;          // Data bus
input [10:8]   RXFRdData;         //  RX Stat bit
input          UARTECRWrEn;       // Write Enable for UARTECR
input          UARTLCRHnewWrEn;   // Write Enable for LCRH_new
input          UARTILPRWrEn;      // Write Enable for ILPR
input          UARTCRnewWrEn;     // Write Enable for UARTCR_new
input          UARTICRWrEn;       // Write Enable for UARTICR
input          UARTIBRDWrEn;      // Write Enable for UARTIBRD
input          UARTFBRDWrEn;      // Write Enable for UARTFBRD
input          UARTIFLSWrEn;      // Write Enable for UARTIFLS
input          UARTIMSCWrEn;      // Write Enable for UARTIMSC
input          UARTDMACRWrEn;     //  Write Enable for UARTDMACR
input          UARTOEIClr;        // Overrun Error Int. Clr
input          UARTRTRIS;         // Receive Timeout Interrupt
input  [2:0]   UARTRISerrSync;    // Raw error interrupts
input  [3:0]   UARTRISmodSync;    // Raw modem interrupt status
input          UARTTXIClr;        // UARTICR Tx int. Clr
input          UARTRXIClr;        // UARTICR Rx int. Clr input [10:8]

output         LCRUpdate;         // LCR update trigger
output         ILPRUpdate;        // ILPR update trigger
output         FBRDUpdate;        // ILPR update trigger
output  [10:0] UARTICR;           // For Interrupt Clears
output  [2:0]  RXSTATUS;          // RX Stat bits output [6:0]
output  [7:0]  UARTLCRH;          // 1st buffer
output  [7:0]  UARTLCRM;          // 1st buffer
output  [7:0]  UARTLCRL;          // 1st buffer
output  [7:0]  UARTILPR;          // 1st buffer
output  [15:0] UARTCR;            // CR bits
output  [5:0]  UARTIFLS;          // IFLS bits
output  [2:0]  UARTDMACR;         // CR bits
output  [5:0]  UARTFBRD;          // FBRD bits
output  [10:0] UARTIMSC;          // modem mask bits


//------------------------------------------------------------------------------
//                   UartRegBlock
//                   ============
//------------------------------------------------------------------------------
// Overview
// ========
//  This block contains the normal mode registers for the UART. Write
//  data from the PWDATAIn bus is clocked in when the appropriate write
//  enable signal is asserted.
//  This block contains the first buffer in the 2-buffer synchronisation
//  mechanism for the LCR. It also contains the first buffer for the
//  2-buffer synchronisation mechanism for the ILPR.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declarations
//------------------------------------------------------------------------------
wire           PCLK;
// APB Bus Clock                                  (Module Input)

wire           PRESETn;
// APB Bus Reset                                  (Module Input)

wire           RXFRdPtrInc;
// RX FIFO Read pointer Incr.                     (Module Input)

wire           UARTECRWrEn;
// Write Enable for UARTECR                       (Module Input)

wire           UARTLCRHnewWrEn;
// Write Enable for LCRH_new                      (Module Input)

wire           UARTILPRWrEn;
// Write Enable for ILPR                          (Module Input)

wire           UARTCRnewWrEn;
// Write Enable for UARTCR_new                    (Module Input)

wire           UARTICRWrEn;
// Write Enable for UARTICR                       (Module Input)

wire           UARTIBRDWrEn;
// Write Enable for UARTIBRD                      (Module Input)

wire           UARTFBRDWrEn;
// Write Enable for UARTFBRD                      (Module Input)

wire           UARTIFLSWrEn;
// Write Enable for UARTIFLS                      (Module Input)

wire           UARTIMSCWrEn;
// Write Enable for UARTIMSC                      (Module Input)

wire           UARTDMACRWrEn;
//  Write Enable for UARTDMACR                    (Module Input)

wire  [15:0]   PWDATAIn;
// Data bus                                       (Module Input)

wire           UARTOEIClr;
// Overrun Error Int. Clr                         (Module Input)

wire           UARTTXIClr;
// UARTICR Tx int. Clr                            (Module Input)

wire           UARTRXIClr;
// UARTICR Rx int. Clr input [10:8]               (Module Input)
// RXFRdDatRX Stat bits

wire  [10:8]   RXFRdData;
//  RX Stat bit                                   (Module Input)

//------------------------------------------------------------------------------
// Register declarations
//------------------------------------------------------------------------------
reg  [7:0]  iUARTLCRH;
// 1st stage buffer for UARTLCRH.

reg  [7:0]  NextLCRH;
// D-input of iUARTLCRH

reg  [7:0]  iUARTLCRM;
// 1st stage buffer for UARTLCRM

reg  [7:0]  NextLCRM;
// D-input of iUARTLCRM

reg  [7:0]  iUARTLCRL;
// 1st stage buffer for UARTLCRL

reg  [7:0]  NextLCRL;
// D-input of iUARTLCRL

reg iLCRUpdate;
// Internal copy of Update trigger for LCR registers

reg NextLCRUpdate;
// D-input of iUpdateLCR

reg   [5:0] NextUARTFBRD;
// D-input of iUARTFBRD

reg   [5:0] iUARTFBRD;
// Internal copy of UARTFBRD

reg  [2:0]  iRXSTATUS;
// Receive Status bits

reg  [2:0]  NextRXSTATUS;
// D-input of iRXSTATUS

reg  [7:0]  iUARTILPR;
// 1st stage buffer for UARTILPR

reg  [7:0]  NextILPR;
// D-input of iUARTILPR

reg iILPRUpdate;
// Internal copy of update trigger for the UARTILPR register

reg iFBRDUpdate;
// Internal copy of update trigger for the FBRD register

reg NextILPRUpdate;
// D-input of iUpdateILPR

reg NextFBRDUpdate;
// D-input of iUpdateILPR

reg  [15:0]  iUARTCR;
// UARTCR

reg  [15:0]  NextUARTCR;
// D-input of UARTCR

reg  [2:0]   iUARTDMACR;
// UARTDMACR

reg  [2:0]   NextUARTDMACR;
//  D-input of UARTDMACR

reg  [5:0]  iUARTIFLS;
// UARTIFLS

reg  [5:0]  NextUARTIFLS;
// D-input of UARTIFLS

reg iUARTOEIC;
// UARTOEIC  (UARTICR(10))

reg iUARTBEIC;
// UARTBEIC  (UARTICR(9))

reg iUARTPEIC;
// UARTBEIC  (UARTICR(8))

reg iUARTFEIC;
// UARTFEIC  (UARTICR(7))

reg iUARTRTIC;
// UARTRTIC  (UARTICR(6))

reg iUARTTXIC;
// UARTTXIC  (UARTICR(5))

reg iUARTRXIC;
// UARTRXIC  (UARTICR(4))

reg iUARTDCDIC;
// UARTDCDIC (UARTICR(2)

reg iUARTDSRIC;
// UARTDSRIC (UARTICR(3)

reg iUARTCTSIC;
// UARTCTSIC (UARTICR(1)

reg iUARTRIIC;
// UARTRIIC (UARTICR(0)

reg NextUARTOEIC;
// D-input of UARTOEIC

reg NextUARTBEIC;
// D-input of UARTBEIC

reg NextUARTPEIC;
// D-input of UARTPEIC

reg NextUARTFEIC;
// D-input of UARTFEIC

reg NextUARTRTIC;
// D-input of UARTRTIC

reg NextUARTDCDIC;
// D-input of UARTDCDIC

reg NextUARTDSRIC;
// D-input of UARTDSRIC

reg NextUARTCTSIC;
// D-input of UARTCTSIC

reg NextUARTRIIC;
// D-input of UARTRIIC

reg NextUARTTXIC;
// D-input of UARTTXIC

reg NextUARTRXIC;
// D-input of UARTRXIC

reg [10:0] UARTIMSC;
// Modem mask bit

//------------------------------------------------------------------------------
// Main Verilog code
// =================
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Copy the upper 3 bits of data read from the Receive FIFO into
// the RXSTATUS register.
//------------------------------------------------------------------------------
always @(RXFRdPtrInc or UARTECRWrEn or RXFRdData or iRXSTATUS)
begin : p_RFStatComb
  NextRXSTATUS = iRXSTATUS;
  if(UARTECRWrEn == 1'b1)
    NextRXSTATUS = 3'b000;
  else if(RXFRdPtrInc == 1'b1)
    NextRXSTATUS = RXFRdData;
end // p_RFStatComb

//------------------------------------------------------------------------------
// Sequential always for Receive FIFO status.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_RFStatSeq
  if(PRESETn == 1'b0)
    iRXSTATUS <= 3'b000;
  else
    iRXSTATUS <= NextRXSTATUS;
end // p_RFStatSeq

//------------------------------------------------------------------------------
// Combinational always for 1st stage buffers for LCR. When the
// respective write enable input is asserted or copy the contents of
// the PWDATAIn bus into the corresponding 1st stage buffer.
//------------------------------------------------------------------------------
always @(PWDATAIn or iUARTLCRH or iUARTLCRM or iUARTLCRL or UARTIBRDWrEn or
         UARTLCRHnewWrEn )
begin : p_LCRComb
  NextLCRH     = iUARTLCRH;
  NextLCRM     = iUARTLCRM;
  NextLCRL     = iUARTLCRL;

  if (UARTLCRHnewWrEn == 1'b1)
    NextLCRH     = PWDATAIn[7:0];

  if (UARTIBRDWrEn == 1'b1)
    NextLCRM   = PWDATAIn[15:8];
  else
    NextLCRM   = iUARTLCRM;

  if (UARTIBRDWrEn == 1'b1)
    NextLCRL   = PWDATAIn[7:0];
end // p_LCRComb

//------------------------------------------------------------------------------
// Sequential always for first stage buffers for LCR
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_LCRSeq
  if(PRESETn == 1'b0)
    begin
      iUARTLCRH    <= 8'b00000000;
      iUARTLCRM    <= 8'b00000000;
      iUARTLCRL    <= 8'b00000000;
    end
  else
    begin
      iUARTLCRH    <= NextLCRH;
      iUARTLCRM    <= NextLCRM;
      iUARTLCRL    <= NextLCRL;
    end
end // p_LCRSeq

//------------------------------------------------------------------------------
// The iLCRUpdate reg toggles with every write into UARTLCRH.
//------------------------------------------------------------------------------
always @(iLCRUpdate or UARTLCRHnewWrEn)
begin : p_UpdtLCRComb
  NextLCRUpdate = iLCRUpdate;
  if (UARTLCRHnewWrEn == 1'b1)
    NextLCRUpdate = !(iLCRUpdate);
end // p_UpdtLCRComb;

//------------------------------------------------------------------------------
// Sequential always for iLCRUpdate.
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_UpdtLCRSeq
  if (PRESETn == 1'b0)
    iLCRUpdate <= 1'b0;
  else
      iLCRUpdate <= NextLCRUpdate;
end // p_UpdtLCRSeq

//------------------------------------------------------------------------------
// The iFBRDUpdate signal toggles with every write into UARTFBRD.
//------------------------------------------------------------------------------
always @(iFBRDUpdate or UARTFBRDWrEn)
begin : p_UpdtFBRDComb
  NextFBRDUpdate = iFBRDUpdate;
  if(UARTFBRDWrEn == 1'b1)
    NextFBRDUpdate = ~iFBRDUpdate;
end // p_UpdtFBRDComb

//------------------------------------------------------------------------------
// Sequential process for iFBRDUpdate
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_UpdtFBRDSeq
  if(PRESETn == 1'b0)
    iFBRDUpdate <= 1'b0;
  else
    iFBRDUpdate <= NextFBRDUpdate;
end // p_UpdtFBRDSeq


//------------------------------------------------------------------------------
// Clock PWDATAIn into UARTFBRD when UARTFBRDWrEn is asserted.
//------------------------------------------------------------------------------
always @(UARTFBRDWrEn or iUARTFBRD or PWDATAIn)
begin : p_FBRDComb
  NextUARTFBRD = iUARTFBRD;
  if(UARTFBRDWrEn == 1'b1)
    NextUARTFBRD = PWDATAIn[5:0];
end // p_FBRDComb

//------------------------------------------------------------------------------
// Sequential process for UARTFBRD
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_FBRDSeq
  if(PRESETn == 1'b0)
    iUARTFBRD <= 6'b000000;
  else
    iUARTFBRD <= NextUARTFBRD;
end // p_FBRDSeq

//------------------------------------------------------------------------------
// Clock in PWDATAIn into ILPR when UARTILPRWrEn is asserted.
//------------------------------------------------------------------------------
always @(UARTILPRWrEn or iUARTILPR or PWDATAIn)
begin : p_ILPRComb
  NextILPR   = iUARTILPR;
  if(UARTILPRWrEn == 1'b1)
    NextILPR = PWDATAIn[7:0];
end // p_ILPRComb

//------------------------------------------------------------------------------
// Sequential always for ILPR first stage buffer
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_ILPSeq
  if(PRESETn == 1'b0)
    iUARTILPR    <= 8'b00000000;
  else
      iUARTILPR  <= NextILPR;
end // p_ILPSeq

//------------------------------------------------------------------------------
// The iILPRUpdate reg toggles with every write to the UARTILPR register
//------------------------------------------------------------------------------
always @(iILPRUpdate or UARTILPRWrEn)
begin : p_UpdtILPRComb
  NextILPRUpdate = iILPRUpdate;
  if (UARTILPRWrEn == 1'b1)
    NextILPRUpdate = !(iILPRUpdate);
end // p_UpdtILPRComb

//------------------------------------------------------------------------------
// Sequential always for iILPRUpdate
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_UpdtILPRSeq
  if (PRESETn == 1'b0)
    iILPRUpdate <= 1'b0;
  else
      iILPRUpdate <= NextILPRUpdate;
end // p_UpdtILPRSeq

//------------------------------------------------------------------------------
// Clock PWDATAIn into UARTCR when UARTCRnewWrEn is asserted.
//------------------------------------------------------------------------------
always @(UARTCRnewWrEn or iUARTCR or PWDATAIn)
begin : p_CRComb
  NextUARTCR = iUARTCR;

  if(UARTCRnewWrEn == 1'b1)
    NextUARTCR = PWDATAIn[15:0];
  else
    NextUARTCR = iUARTCR;
end // p_CRComb

//------------------------------------------------------------------------------
// Clock PWDATAIn into UARTDMACR when UARTDMACRWrEn is asserted.
//------------------------------------------------------------------------------
always @(UARTDMACRWrEn or iUARTDMACR or PWDATAIn)
begin : p_DMACRComb
  NextUARTDMACR = iUARTDMACR;

  if(UARTDMACRWrEn == 1'b1)
    NextUARTDMACR = PWDATAIn[2:0];
end // p_DMACRComb;

//------------------------------------------------------------------------------
// Sequential process for UARTDMACR
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_DMACRSeq
  if(PRESETn == 1'b0)
    iUARTDMACR <= 3'b000;
  else
      iUARTDMACR <= NextUARTDMACR;
end // p_DMACRSeq;


//------------------------------------------------------------------------------
// Sequential always for UARTCR
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_CRSeq
  if(PRESETn == 1'b0)
    iUARTCR <= 10'b1100000000;
  else
      iUARTCR <= NextUARTCR;
end // p_CRSeq


//------------------------------------------------------------------------------
// Clock PWDATAIn into UARTIFLS when UARTIFLSWrEn is asserted.
//------------------------------------------------------------------------------
always @(UARTIFLSWrEn or iUARTIFLS or PWDATAIn)
begin : p_IFLSComb
  NextUARTIFLS = iUARTIFLS;
  if(UARTIFLSWrEn == 1'b1)
    NextUARTIFLS = PWDATAIn[5:0];
end // p_IFLSComb


//------------------------------------------------------------------------------
// Sequential always for UARTIFLS
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_IFLSSeq
  if(PRESETn == 1'b0)
    iUARTIFLS <= 6'b010010;
  else
      iUARTIFLS <= NextUARTIFLS;
end // p_IFLSSeq


//------------------------------------------------------------------------------
// UARTICR Register : Overrun Error
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTOEIC or UARTOEIClr or PWDATAIn)
begin : p_OEINTComb
  NextUARTOEIC = iUARTOEIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTOEIC = PWDATAIn[10];
  else if(UARTOEIClr == 1'b1)
    NextUARTOEIC = 1'b0;
end // p_OEINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_OEINTSeq
  if(PRESETn == 1'b0)
    iUARTOEIC <= 1'b0;
  else
      iUARTOEIC <= NextUARTOEIC;
end // p_OEINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Break Error
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTBEIC or UARTRISerrSync or PWDATAIn)
begin : p_BEINTComb
  NextUARTBEIC = iUARTBEIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTBEIC = PWDATAIn[9];
  else if(UARTRISerrSync[2] == 1'b0)
    NextUARTBEIC = 1'b0;
end // p_BEINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_BEINTSeq
  if(PRESETn == 1'b0)
    iUARTBEIC <= 1'b0;
  else
      iUARTBEIC <= NextUARTBEIC;
end // p_BEINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Parity Error
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTPEIC or UARTRISerrSync or PWDATAIn)
begin : p_PEINTComb
  NextUARTPEIC = iUARTPEIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTPEIC = PWDATAIn[8];
  else if (UARTRISerrSync[1] == 1'b0)
    NextUARTPEIC = 1'b0;
end // p_PEINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_PEINTSeq
  if(PRESETn == 1'b0)
    iUARTPEIC <= 1'b0;
  else
    iUARTPEIC <= NextUARTPEIC;
end // p_PEINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Framing Error
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTFEIC or UARTRISerrSync or PWDATAIn)
begin : p_FEINTComb
  NextUARTFEIC = iUARTFEIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTFEIC = PWDATAIn[7];
  else if(UARTRISerrSync[0] == 1'b0)
    NextUARTFEIC = 1'b0;
end // p_FEINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_FEINTSeq
  if(PRESETn == 1'b0)
    iUARTFEIC <= 1'b0;
  else
    iUARTFEIC <= NextUARTFEIC;
end // p_FEINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Receive Timeout
//------------------------------------------------------------------------------

always @(UARTICRWrEn or iUARTRTIC or UARTRTRIS or PWDATAIn)
begin : p_RTINTComb
  NextUARTRTIC = iUARTRTIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTRTIC = PWDATAIn[6];
  else if (UARTRTRIS == 1'b0)
    NextUARTRTIC = 1'b0;
end // p_RTINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_RTINTSeq
  if(PRESETn == 1'b0)
    iUARTRTIC <= 1'b0;
  else
    iUARTRTIC <= NextUARTRTIC;
end // p_RTINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Rx Interrupt
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTRXIC or UARTRXIClr or PWDATAIn)
begin : p_RXINTComb
  NextUARTRXIC = iUARTRXIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTRXIC = PWDATAIn[4];
  else if (UARTRXIClr == 1'b1)
    NextUARTRXIC = 1'b0;
end // p_RXINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_RXINTSeq
  if(PRESETn == 1'b0)
    iUARTRXIC <= 1'b0;
  else
      iUARTRXIC <= NextUARTRXIC;
end // p_RXINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Tx Interrupt
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTTXIC or UARTTXIClr or PWDATAIn)
begin : p_TXINTComb
  NextUARTTXIC = iUARTTXIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTTXIC = PWDATAIn[5];
  else if (UARTTXIClr == 1'b1)
    NextUARTTXIC = 1'b0;
end // p_TXINTComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_TXINTSeq
  if(PRESETn == 1'b0)
    iUARTTXIC <= 1'b0;
  else
      iUARTTXIC <= NextUARTTXIC;
end // p_TXINTSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Modem DSR Line
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTDSRIC or UARTRISmodSync or PWDATAIn)
begin : p_DSRComb
  NextUARTDSRIC = iUARTDSRIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTDSRIC = PWDATAIn[3];
  else if (UARTRISmodSync[3] == 1'b0)
    NextUARTDSRIC = 1'b0;
end // p_DSRComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_DSRSeq
  if(PRESETn == 1'b0)
    iUARTDSRIC <= 1'b0;
  else
      iUARTDSRIC <= NextUARTDSRIC;
end // p_DSRSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Modem DCD Line
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTDCDIC or UARTRISmodSync or PWDATAIn)
begin : p_DCDComb
  NextUARTDCDIC = iUARTDCDIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTDCDIC = PWDATAIn[2];
  else if(UARTRISmodSync[2] == 1'b0)
    NextUARTDCDIC = 1'b0;
end // p_DCDComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_DCDSeq
  if(PRESETn == 1'b0)
    iUARTDCDIC <= 1'b0;
  else
    iUARTDCDIC <= NextUARTDCDIC;
end // p_DCDSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Modem CTS Line
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTCTSIC or UARTRISmodSync or PWDATAIn)
begin : p_CTSComb
  NextUARTCTSIC = iUARTCTSIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTCTSIC = PWDATAIn[1];
  else if(UARTRISmodSync[1] == 1'b0)
    NextUARTCTSIC = 1'b0;
end // p_CTSComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_CTSSeq
  if(PRESETn == 1'b0)
    iUARTCTSIC <= 1'b0;
  else
      iUARTCTSIC <= NextUARTCTSIC;
end // p_CTSSeq;

//------------------------------------------------------------------------------
// UARTICR Register : Modem RI Line
//------------------------------------------------------------------------------
always @(UARTICRWrEn or iUARTRIIC or UARTRISmodSync or PWDATAIn)
begin : p_RIComb
  NextUARTRIIC = iUARTRIIC;

  if(UARTICRWrEn == 1'b1)
    NextUARTRIIC = PWDATAIn[0];
  else if(UARTRISmodSync[0] == 1'b0)
    NextUARTRIIC = 1'b0;
end // p_RIComb;

always @(posedge PCLK or negedge PRESETn)
begin : p_RISeq
  if(PRESETn == 1'b0)
    iUARTRIIC <= 1'b0;
  else
    iUARTRIIC <= NextUARTRIIC;
end // p_RISeq;

assign UARTICR[10] = iUARTOEIC;
assign UARTICR[9]  = iUARTBEIC;
assign UARTICR[8]  = iUARTPEIC;
assign UARTICR[7]  = iUARTFEIC;
assign UARTICR[6]  = iUARTRTIC;
assign UARTICR[5]  = iUARTTXIC;
assign UARTICR[4]  = iUARTRXIC;
assign UARTICR[3]  = iUARTDSRIC;
assign UARTICR[2]  = iUARTDCDIC;
assign UARTICR[1]  = iUARTCTSIC;
assign UARTICR[0]  = iUARTRIIC;

//------------------------------------------------------------------------------
// UARTIMSC Register
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_Mask
  if(PRESETn == 1'b0)
    UARTIMSC <= 11'b00000000000;
  else if(UARTIMSCWrEn == 1'b1)
      UARTIMSC <= PWDATAIn[10:0];
end // p_Mask;

//------------------------------------------------------------------------------
// Connect local copies to outputs
//------------------------------------------------------------------------------
assign RXSTATUS    = iRXSTATUS;
assign UARTLCRH    = iUARTLCRH;
assign UARTLCRM    = iUARTLCRM;
assign UARTLCRL    = iUARTLCRL;
assign UARTFBRD    = iUARTFBRD;
assign UARTCR      = iUARTCR;
assign UARTILPR    = iUARTILPR;
assign LCRUpdate   = iLCRUpdate;
assign ILPRUpdate  = iILPRUpdate;
assign FBRDUpdate  = iFBRDUpdate;
assign UARTIFLS    = iUARTIFLS;
assign UARTDMACR   = iUARTDMACR;

endmodule

// --============================== End of UartRegBlock ======================--
