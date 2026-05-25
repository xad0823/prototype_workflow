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
//  File Name              : UartRXFCntl.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the control logic for the receive
//               FIFO
// --=========================================================================--

`timescale 1ns/1ps

module UartRXFCntl (
                    PCLK,
                    PRESETn,
                    RXFWrSync,
                    RXFRdPtrInc,
                    FEN,
                    TESTFIFO,
                    RTSEn,
                    nUARTRTScr,
                    UARTECRWrEn,
                    UARTTDRWrEn,
                    RXIFLSEL,
                    RXIM,
                    OEIM,
                    UARTRXIC,
                    UARTOEIC,
                    WrPtr,
                    RdPtr,
                    RXFE,
                    RXFF,
                    RXFGTE1Full,
                    RXIntLevel,
                    RegFileWrEn,
                    RXFWrDone,
                    OverrunDet,
                    FIFOOverrunDet,
                    nUARTRTSint,
                    UARTRXIClr,
                    UARTOEIClr,
                    UARTRXRIS,
                    UARTRXMIS,
                    UARTOERIS,
                    UARTOEMIS
                   );

input        PCLK;	        // APB Clock
input        PRESETn;	        // APB Bus Reset 
input        RXFWrSync;	        // RX FIFO Write Enable
input        RXFRdPtrInc;	// RX FIFO Read Pointer Incr.
input        FEN;	        // FIFO Enable
input        TESTFIFO;          // Test signal
input        RTSEn;             // RTS flow control enable
input        nUARTRTScr;        // from UARTCR
input        UARTECRWrEn;	// Overrun error Clear input
input        UARTTDRWrEn;	// TDR write enable
input [2:0]  RXIFLSEL;          // Selected interrupt level
input        RXIM;              // RX Interrupt Mask
input        OEIM;              // Overrun Error Interrupt Mask
input        UARTRXIC;          // For RX Interrupt clear
input        UARTOEIC;          // For Overrun errot Interrupt clear

output       OverrunDet;        // Overrun Detected
output        RegFileWrEn;	// Write Enable to Register File
output        RXFWrDone;	// RX FIFO Write Done
output       FIFOOverrunDet;	// Overrun Detected
output        UARTRXIClr;       //  RX Interrupt clear
output [4:0]  WrPtr;	        // Write Pointer
output [4:0]  RdPtr;	        // Read Pointer
output        RXFE;	        // Receive FIFO Empty
output        RXFF;	        // Receive FIFO Full
output        UARTOEIClr;       // Overrun Error Interrupt Clear
output        UARTRXMIS;	// Receive Masked Interrupt
output        UARTOEMIS;        // Overrun Error Masked Int status
output        UARTRXRIS;	// Receive Raw Interrupt
output        UARTOERIS;        // Overrun Error Raw Int status
output        RXFGTE1Full;      // To DMA block
output        RXIntLevel;       // Programable Interrupt Level
output        nUARTRTSint;      // modem signal

//
//------------------------------------------------------------------------------
//
//                   UartRXFCntl
//                   ===========
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//  The control logic for the receive FIFO uses two pointers - a write
// pointer and a read pointer. The pointers are 4 bits wide. The write
// pointer points to the location to which the next write data will be
// written into. The read pointer points to the next location whose
// contents will be read out. Both the pointers operate on PCLK so as to
// serve data consistently to APB accesses and to conveniently calculate
// the FIFO fill level by finding the difference between the pointers.
// When the FIFO is disabled, the pointers do not change and the fill
// status of the holding buffer is indicated by a separate bit
// 'HldBufValid'.
// The overrun condition is met when the receive logic attempts to
// write into the FIFO  when the FIFO is already full (if the FIFO is
// enabled) or if the holding buffer is already full (if the FIFO is
// disabled). Once the overrun condition is met, further writes to the
// FIFO are ignored.  Two separate overrun signals are generated
// OverrunDet(which is copied into the status register) and
// FIFOOverrunDet(which is copied into the RXFIFO).
// When the UARTECRWrEn input is set, the overrun OverrunDet
// condition is cleared,  the FIFOOverrunDet is cleared on the next
// successful write to the RXFIFO.
// The fifo can be set to be in TESTFIFO mode which allows data to
// be written directly into the Rx fifo.
//
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire         PCLK;	
// APB Clock                                              (Module Input)

wire         PRESETn;	
// Muxed Reset (from BPRESETn)                               (Module Input)

wire         RXFWrSync;	
// RX FIFO Write Enable                                   (Module Input)

wire         RXFRdPtrInc;	
// RX FIFO Read Pointer Incr.                             (Module Input)

wire         FEN;	
// FIFO Enable                                            (Module Input)

wire         UARTECRWrEn;	
// Overrun error Clear input                              (Module Input)

wire         UARTTDRWrEn;	
// TDR write enable                                       (Module Input)

wire         TESTFIFO;
//  Test signal                                           (Module Input)

wire  [2:0]  RXIFLSEL;
//  Selected interrupt level                              (Module Input)

wire         RXIM;
//  RX Interrupt Mask                                     (Module Input)

wire         OEIM;
//  Overrun Error Interrupt Mask                          (Module Input)

wire         UARTRXIC;
// For RX Interrupt clear                                 (Module Input)

wire         UARTOEIC;
// For Overrun errot Interrupt clear                      (Module Input)

wire         RegFileWrEn;	
// Write Enable to Register File                         (Module Output)

wire         RXFWrDone;	
// RX FIFO Write Done                                    (Module Output)

wire         RTSEn;
// RTS flow control enable                               (Module Output)

wire         nUARTRTScr;
// from UARTCR                                           (Module Output)

wire WrPtrIncValid;
// Valid Write Pointer Increment condition detected

wire RdPtrIncValid;
// Valid Read Pointer Increment condition detected

wire OverrunEdge;
// Detects edge in Overrun

wire RXEdge;
// Detects edge in iRXIntLevel

wire HldBufValidEdge;
// Detects edge in HldBufValid

wire RXFGTEHalfFull;
// Receive FIFO Greater Than or Equal to Half Full

wire RXFGTEQFull;
// Receive FIFO Greater Than or Equal to Quarter Full

wire RXFGTE3QFull;
// Receive FIFO Greater Than or Equal to Three Quarters Full

wire  [5:0] RXFFillLevel;
// Receive FIFO Fill level - can take values from 00000 to 10000

wire FIFOGTEHalfFull;
// FIFO Fill level compare result

wire FIFOGTE3QFull;
// FIFO Fill level compare result

wire FIFOGTEQFull;
// FIFO Fill level compare result

wire RXFGTE8Full;
// Receive FIFO Greater Than or Equal to One Eighth Full

wire RXFGTE78Full;
// Receive FIFO Greater Than or Equal to Seven Eighth Full

wire FIFOGTE8Full;
// FIFO Fill level compare result

wire FIFOGTE78Full;
// FIFO Fill level compare result

wire FIFOGTE1Full;
// FIFO Fill level compare result

wire [5:0] WrPtrLevel;
// Signal used to calculate the Rx Fifo fill level

wire [5:0] RdPtrLevel;
// Signal used to calculate the Rx Fifo fill level

wire iRXFF;
// Internal version of RXFF signal

wire iRXFE;
// Internal version of RXFE signal

wire iUARTRXIClr;
// Internal version of UARTRXIClr signal

wire iUARTOEIClr;
// Internal version of UARTOEIClr signal

//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------

reg  [4:0]  iWrPtr;	
// Write Pointer                                       (Module Output)

reg  [4:0]  iRdPtr;	
// Read Pointer                                        (Module Output)

reg        inUARTRTSint;
// modem signal                                        (Module Output)

reg  [4:0] NextRdPtr;
// D-input for Read pointer vector

reg  [4:0] NextWrPtr;
// D-input for Write pointer vector

reg Wrap;
// Store the condition when the write pointer has rolled over (from '1111' to 
// '0000') but the read pointer hasn't. This signal is used in calculating 
// the FIFOFillLevel

reg NextWrap;
// D-input of Wrap bit

reg NextOverrunDet;
// D-input of iOverrunDet bit

reg       iOverrunDet;
// Overrun Detected

reg       iFIFOOverrunDet;	
// Overrun Detected

reg DelOverrunDet;
// Delayed version of OverrunDet bit

reg NextFIFOOverrunDet;
// D-input of iFIFOOverrunDet bit

reg DelRXFWrSync;
// Delayed version of RXFWrSync - FIFO write enable signal
// Used to convert the level on the RXFWrEn signal to a one-clock
// wide pulse

reg HldBufValid;
// Fill status of the receive holding buffer when the FIFO is
// disabled

reg DelHldBufValid;
// delayed version of HldBufValid

reg NextHldBufValid;
// D-input of HldBufValid bit

reg    NextUARTRXRIS;
// D-input of iUARTRXRIS

reg    NextUARTOERIS;
// D-input of iUARTOERIS

reg FIFOFull;
// Receive FIFO Full when the FIFO is enabled

reg NextFIFOFull;
// D-input of FIFOFull bit

reg FIFOEmpty;
// Receive FIFO empty when the FIFO is enabled

reg NextFIFOEmpty;
// D-input of FIFOEmpty bit

reg iRXIntLevel;
// Programmable interrupt level
// Internal version of RXIntLevel signal

reg   DelUARTRXIC;
// Delayed version of UARTRXIC signal

reg   DelUARTOEIC;
// Delayed version of UARTRIC signal

reg DelRXIntLevel;
// Delayed version of iRXIntLevel

reg           iUARTRXRIS;	
// Receive Raw Interrupt

reg           iUARTOERIS;
// Overrun Error Raw Int status

reg           NextRXIntLevel;
// D-input for Programmable interrupt level

reg           NextnUARTRTSint;
// D-input for inUARTRTSint

//------------------------------------------------------------------------------
//
// Main verilog code
// =================
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Generate a one-PCLK wide write enable pulse for the Register File on
// every rising edge on the RXFWrSync signal or when in TESTFIFO mode
// and there is a write to the fifo. Mask writes to the Register File
// if FIFO is full
//------------------------------------------------------------------------------
assign RegFileWrEn = (((RXFWrSync &  !(DelRXFWrSync)) |
                   (UARTTDRWrEn & TESTFIFO)) &  (!(iRXFF) | (iRXFF & RXFRdPtrInc)));

//------------------------------------------------------------------------------
// Assert and De-assert RXFWrDone signal the next clock after
// RXFRdPtrInc is asserted or de-asserted.
//------------------------------------------------------------------------------
assign RXFWrDone = DelRXFWrSync;

//------------------------------------------------------------------------------
// Connect local copies of signals to ports
//------------------------------------------------------------------------------
assign RXFF           = iRXFF;
assign RXFE           = iRXFE;
assign WrPtr          = iWrPtr;
assign RdPtr          = iRdPtr;
assign OverrunDet     = iOverrunDet;
assign FIFOOverrunDet = iFIFOOverrunDet; 
assign UARTRXRIS      = iUARTRXRIS;
assign UARTRXIClr     = iUARTRXIClr;
assign UARTOERIS      = iUARTOERIS;
assign UARTOEIClr     = iUARTOEIClr;
assign RXIntLevel     = iRXIntLevel;
assign nUARTRTSint    = inUARTRTSint;

//------------------------------------------------------------------------------
// Sequential always @to infer registers in this block
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_PtrsSeq
  if (PRESETn == 1'b0)
    begin
      iWrPtr           <= 5'b00000; //change
      iRdPtr           <= 5'b00000; //change
      Wrap             <= 1'b0;
      HldBufValid      <= 1'b0;
      iOverrunDet      <= 1'b0;
      iFIFOOverrunDet  <= 1'b0;
      DelRXFWrSync     <= 1'b0;
      iUARTRXRIS       <= 1'b0;
      iUARTOERIS       <= 1'b0;
      FIFOFull         <= 1'b0;
      FIFOEmpty        <= 1'b1;
      DelUARTRXIC      <= 1'b0;
      DelUARTOEIC      <= 1'b0;
      DelRXIntLevel    <= 1'b0;
      DelHldBufValid   <= 1'b0;
      DelOverrunDet    <= 1'b0;
      inUARTRTSint     <= 1'b1;
      iRXIntLevel      <= 1'b0;
    end
  else
    begin
      iWrPtr           <= NextWrPtr;
      iRdPtr           <= NextRdPtr;
      Wrap             <= NextWrap;
      HldBufValid      <= NextHldBufValid;
      iOverrunDet      <= NextOverrunDet;
      iFIFOOverrunDet  <= NextFIFOOverrunDet;
      DelRXFWrSync     <= RXFWrSync;
      iUARTRXRIS       <= NextUARTRXRIS;
      iUARTOERIS       <= NextUARTOERIS;
      FIFOFull         <= NextFIFOFull;
      FIFOEmpty        <= NextFIFOEmpty;
      DelUARTRXIC      <= UARTRXIC;
      DelUARTOEIC      <= UARTOEIC;
      iRXIntLevel      <= NextRXIntLevel;
      DelRXIntLevel    <= iRXIntLevel;
      DelHldBufValid   <= HldBufValid;
      DelOverrunDet    <= iOverrunDet;
      inUARTRTSint     <= NextnUARTRTSint;
    end
end // p_PtrsSeq;

//------------------------------------------------------------------------------
// Increment the write pointer when there is a rising edge on RXFWrSync
// (FIFO write enable) signal. Don't allow write pointer to increment if
// the FIFO is already Full.
// If the FIFO is full and there is a simultaneous write and read, the
// write pointer should be incremented.
// In TESTFIFO mode the write pointer should be incremented when
// there is a write to the test data register.
//------------------------------------------------------------------------------
assign  WrPtrIncValid = (RXFWrSync &  !(DelRXFWrSync) & ( !(FIFOFull) | 
                         (FIFOFull & RXFRdPtrInc))) | (UARTTDRWrEn & TESTFIFO);

//------------------------------------------------------------------------------
// Freeze the Write pointer at Zero when the FIFO is disabled. When the
// FIFO is enabled and when the WrPtrIncValid signal is asserted,
// increment the Write pointer by 1.
//------------------------------------------------------------------------------
always @(iWrPtr or FEN or WrPtrIncValid)
begin : p_WrPtrComb
  if (FEN == 1'b0)
    NextWrPtr = 5'b00000; //change
  else if (WrPtrIncValid == 1'b1)
    NextWrPtr = ((iWrPtr) + 1'b1);
  else
    NextWrPtr = iWrPtr;
end // p_WrPtrComb;

//------------------------------------------------------------------------------
// Increment the read pointer when there is a read from the APB
// interface. For safety, inhibit reads from having any effect if the
// FIFO is already empty.
//------------------------------------------------------------------------------
assign RdPtrIncValid = RXFRdPtrInc &  !(FIFOEmpty);

//------------------------------------------------------------------------------
// Freeze the Read pointer at Zero when the FIFO is disabled. When the
// FIFO is enabled and when the RdPtrIncValid signal is asserted,
// increment the Read pointer by 1.
//------------------------------------------------------------------------------
always @(iRdPtr or FEN or RdPtrIncValid)
begin : p_RdPtrComb
  if (FEN == 1'b0)
    NextRdPtr = 5'b00000; //change
  else if (RdPtrIncValid == 1'b1)
    NextRdPtr = ((iRdPtr) + 1'b1);
  else
    NextRdPtr = iRdPtr;
end // p_RdPtrComb;

//------------------------------------------------------------------------------
// The 'Wrap' bit is used to keep track of the condition when the write
// pointer has wrapped around from '1111' to '0000', but the read
// pointer has not wrapped. This bit is used to calculate the
// FIFOFillLevel. As with the pointers, the wrap is kept cleared when
// the FIFO is disabled. When both the pointers wrap around from '1111'
// to '0000' simultaneously, the Wrap bit remains unchanged.
//------------------------------------------------------------------------------
always @(iWrPtr or iRdPtr or Wrap or FEN or WrPtrIncValid or
         RdPtrIncValid)
begin : p_WrapComb
  if (FEN == 1'b0)
      NextWrap = 1'b0;
    else if (((iWrPtr == 5'b11111) & (WrPtrIncValid == 1'b1)) ^ //change
           ((iRdPtr == 5'b11111) & (RdPtrIncValid == 1'b1)))
      NextWrap = ! (Wrap);
    else
      NextWrap = Wrap;
  end // p_WrapComb;

//------------------------------------------------------------------------------
// The FIFOFull signal indicates the status of the FIFO when it is
// enabled.
// When the FIFO is one less than full and there is another write to the
// FIFO, the FIFOFull signal is set. When the FIFO is already full and
// there is a read from the FIFO without a simultaneous write, the
// FIFOFull signal is de-asserted
//------------------------------------------------------------------------------
always @(FEN or RXFFillLevel or RXFWrSync or DelRXFWrSync or FIFOFull
         or RXFRdPtrInc or UARTTDRWrEn or TESTFIFO)
begin : p_FIFOFull
  if (FEN == 1'b0)
    NextFIFOFull = 1'b0;
  else if ((RXFFillLevel == 6'b011111) && (((RXFWrSync == 1'b1) && //change
          (DelRXFWrSync == 1'b0)) || (UARTTDRWrEn == 1'b1 &&
          TESTFIFO == 1'b1)) && (RXFRdPtrInc == 1'b0))
    NextFIFOFull = 1'b1;
  else if ((FIFOFull == 1'b1) && (RXFRdPtrInc == 1'b1) &&
           !((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0)))
    NextFIFOFull = 1'b0;
  else
    NextFIFOFull = FIFOFull;
end // p_FIFOFull;

//------------------------------------------------------------------------------
// The FIFOEmpty signal indicates the status of the FIFO when it is
// enabled. If the FIFO is empty and there is a write to the FIFO, the
// FIFOEmpty signal is deasserted. If one location in the FIFO is filled
// and there is a read from the FIFO, the FIFOEmpty signal is asserted.
//------------------------------------------------------------------------------
always @(FEN or RXFFillLevel or RXFWrSync or DelRXFWrSync or FIFOEmpty
          or RXFRdPtrInc or UARTTDRWrEn or TESTFIFO)
begin : p_FIFOEmpty
  if (FEN == 1'b0)
    NextFIFOEmpty = 1'b1;
  else if ((FIFOEmpty == 1'b1) &&
         (((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0)) ||
          (UARTTDRWrEn == 1'b1 && TESTFIFO == 1'b1)))
    NextFIFOEmpty = 1'b0;
  else if ((RXFFillLevel == 6'b000001) && (RXFRdPtrInc == 1'b1) &&
         ! (((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0)) ||
              (UARTTDRWrEn == 1'b1 && TESTFIFO == 1'b1)))
    NextFIFOEmpty = 1'b1;
  else
    NextFIFOEmpty = FIFOEmpty;
end // p_FIFOEmpty;

//------------------------------------------------------------------------------
// When the FIFO is disabled, have a single bit to indicate fill status
// while the pointers are frozen at zero. Set the HldBufValid signal
// when a rising edge is detected on the RXFWrSync signal. Clear the
// HldBufValid signal when there is a write and a simultaneous read.
//------------------------------------------------------------------------------
always @(FEN or RXFWrSync or RXFRdPtrInc or HldBufValid or DelRXFWrSync)
begin : p_BufValid
  if (FEN == 1'b1)
    NextHldBufValid = 1'b0;
  else if ((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0))
    NextHldBufValid = 1'b1;
  else if ((RXFRdPtrInc == 1'b1) &&
          !((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0)))
    NextHldBufValid = 1'b0;
  else
    NextHldBufValid = HldBufValid;
end // p_BufValid;

//------------------------------------------------------------------------------
// Overrun is set when the FIFO is full and there is another attempt to
// write and there is no simultaneous read from the FIFO. OverrunDet is
// cleared when there is a write to the UARTECR register and
// FIFOOverrunDet is cleared on the next successful write to the RXFIFO.
//------------------------------------------------------------------------------
always @(iRXFF or RXFWrSync or RXFRdPtrInc or iOverrunDet or
         iFIFOOverrunDet or DelRXFWrSync or UARTECRWrEn)
begin : p_Overrun
  if ((iRXFF == 1'b1) && (RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0)
      && (RXFRdPtrInc == 1'b0))
    begin
      NextOverrunDet = 1'b1;
      NextFIFOOverrunDet = 1'b1;
    end
  else if (UARTECRWrEn == 1'b1)
    begin
      NextOverrunDet = 1'b0;
      NextFIFOOverrunDet = iFIFOOverrunDet;
    end
  else if ((RXFWrSync == 1'b1) && (DelRXFWrSync == 1'b0) &&
           (iRXFF == 1'b0))
    begin
      NextFIFOOverrunDet = 1'b0;
      NextOverrunDet = iOverrunDet;
    end
  else
    begin
      NextOverrunDet = iOverrunDet;
      NextFIFOOverrunDet = iFIFOOverrunDet;
    end
end // p_Overrun;


//------------------------------------------------------------------------------
// Generate an Overrun Interrupt (UARTOEINTR) when there is a rising
// edge on the OverrunDet line.  Clear the interrupt on a write to
// bit 10 of the interrupt clear register, using the UARTOEIClr
// signal.  The rising edge is detected using the OverrunEdge signal.
//------------------------------------------------------------------------------
assign OverrunEdge = iOverrunDet &  !(DelOverrunDet);

//------------------------------------------------------------------------------
// UARTOEIClr is a one PCLK-wide pulse used to clear the UARTOEINTR.
//------------------------------------------------------------------------------
assign  iUARTOEIClr = UARTOEIC &  !(DelUARTOEIC);


always @(iUARTOERIS or OverrunEdge or iUARTOEIClr)
begin : p_UARTOEINTR
  NextUARTOERIS = iUARTOERIS;
  if(OverrunEdge == 1'b1)
    NextUARTOERIS = 1'b1;
  else if (iUARTOEIClr == 1'b1)
    NextUARTOERIS = 1'b0;
end // p_UARTOEINTR;

assign UARTOEMIS = iUARTOERIS & OEIM;


//------------------------------------------------------------------------------
// The interrupt fifo level is programmable, it can be either at the
// quarter, half, three quarter level aswell as empty or full.
//------------------------------------------------------------------------------
always @(iRXIntLevel or RXIFLSEL or RXFGTE8Full or RXFGTEQFull or
        RXFGTEHalfFull or  RXFGTE3QFull or RXFGTE78Full)
begin : p_RXIntLevel
  NextRXIntLevel = iRXIntLevel;

  case (RXIFLSEL)
    3'b000  : NextRXIntLevel = RXFGTE8Full;
    3'b001  : NextRXIntLevel = RXFGTEQFull;
    3'b010  : NextRXIntLevel = RXFGTEHalfFull;
    3'b011  : NextRXIntLevel = RXFGTE3QFull;
    3'b100  : NextRXIntLevel = RXFGTE78Full;
    default : NextRXIntLevel = 1'b0;
  endcase
end // p_RXIntLevel;

//------------------------------------------------------------------------------
// UARTRXIClr is a one PCLK-wide pulse used to clear the UARTRXINTR.
//------------------------------------------------------------------------------
assign iUARTRXIClr = UARTRXIC &  !(DelUARTRXIC);

//------------------------------------------------------------------------------
// Detect an edge in the interrupt level line and HldBufValid line.
//------------------------------------------------------------------------------
assign  RXEdge = iRXIntLevel ^ DelRXIntLevel;
assign  HldBufValidEdge = HldBufValid ^ DelHldBufValid;

//------------------------------------------------------------------------------
// The UARTRXINTR receive interrupt is set if one of the following
// conditions is met :
// * FIFO enabled and FIFO filled to the programmed level
// * FIFO disabled and the holding register is full
// The interrupt is cleared when either the contents of the Receive FIFO
//  are read out such that there are the programmed level or more valid
// entries in the FIFO, or when bit 4 of the Interrupt Clear register
// is written to.
//------------------------------------------------------------------------------
always @(FEN or iRXIntLevel or HldBufValid or HldBufValidEdge or RXEdge
          or iUARTRXIClr or iUARTRXRIS)
  begin : p_UARTRXINTR
  NextUARTRXRIS = iUARTRXRIS;
  if (((FEN == 1'b1) && (iRXIntLevel == 1'b1) && (RXEdge == 1'b1)) ||
      ((FEN == 1'b0) && (HldBufValid == 1'b1) &&
       (HldBufValidEdge == 1'b1)))
    NextUARTRXRIS = 1'b1;
  else if(((FEN == 1'b1) && (iRXIntLevel == 1'b0) && (RXEdge == 1'b1)) ||
        ((FEN == 1'b0) && (HldBufValid == 1'b0) &&
         (HldBufValidEdge == 1'b1)))
    NextUARTRXRIS = 1'b0;
  else if (iUARTRXIClr == 1'b1)
    NextUARTRXRIS = 1'b0;
end // p_UARTRXINTR;

assign UARTRXMIS = iUARTRXRIS & RXIM;

//------------------------------------------------------------------------------
// The multiplexor determines the assignment of nUARTRTSint.  When RTS
// flow control is enabled nUARTRTSint is asserted, (logic 0), when there
// is space in the fifo indicated by RXIntLevel,
// otherwise nUARTRTSint takes the value of bit 11 in the UARTCR.
//------------------------------------------------------------------------------

always @(inUARTRTSint or RTSEn or iRXIntLevel or nUARTRTScr)
begin : p_nUARTRTSint
  NextnUARTRTSint = inUARTRTSint;
  if ((RTSEn == 1'b1) && (iRXIntLevel == 1'b0))
    NextnUARTRTSint = 1'b0;
  else if((RTSEn == 1'b1) && (iRXIntLevel == 1'b1))
    NextnUARTRTSint = 1'b1;
  else if (RTSEn == 1'b0)
    NextnUARTRTSint = nUARTRTScr;
end // p_nUARTRTSint

//------------------------------------------------------------------------------
// Subtract the read pointer from the write pointer to calculate the
// FIFO fill level. Use the Wrap bit to take into account whether the
// write pointer has wrapped without the read pointer not having wrapped
//------------------------------------------------------------------------------
assign WrPtrLevel     = {Wrap,iWrPtr};
assign RdPtrLevel     = {1'b0,iRdPtr};
assign RXFFillLevel   = WrPtrLevel - RdPtrLevel;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the FIFOFull signal to indicate FIFO
// fill status. When the FIFO is disabled, use the HldBufValid signal to
//  indicate FIFO fill status.
//------------------------------------------------------------------------------
assign iRXFF = (FEN == 1'b1) ? FIFOFull : HldBufValid;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the FIFOEmpty signal to indicate FIFO
// fill status. When the FIFO is disabled, use the HldBufValid signal to
// indicate FIFO fill status.
//------------------------------------------------------------------------------
assign  iRXFE = (FEN == 1'b1) ? FIFOEmpty : !(HldBufValid);

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the RXFFillLevel signal to find whether
// the FIFO is greater than or equal to a one eighth, quarter, half,
// three quarter or seven eighth level. If the FIFO is disabled,
// the HldBufValid signal will indicate whether the FIFO is filled.
//------------------------------------------------------------------------------
assign FIFOGTE8Full    = (RXFFillLevel >= 6'b000100); //change

assign RXFGTE8Full     = (FEN == 1'b1) ? FIFOGTE8Full : HldBufValid;

assign FIFOGTEQFull    = ((RXFFillLevel) >= 6'b001000);

assign RXFGTEQFull     =  (FEN == 1'b1) ? FIFOGTEQFull : HldBufValid;

assign FIFOGTEHalfFull = ((RXFFillLevel) >= 6'b010000);

assign RXFGTEHalfFull  =  (FEN == 1'b1) ? FIFOGTEHalfFull : HldBufValid;

assign FIFOGTE3QFull   = ((RXFFillLevel) >= 6'b011000);

assign RXFGTE3QFull    =  (FEN == 1'b1) ? FIFOGTE3QFull : HldBufValid;

assign FIFOGTE78Full   = (RXFFillLevel >= 6'b011100);

assign RXFGTE78Full    = (FEN == 1'b1) ? FIFOGTE78Full : HldBufValid;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the RXFFillLevel signal to find
// whether the Receive FIFO contains at least one word. If the
// FIFO is disabled, the HldBufValid signal will do the job. When the
// receive FIFO contains at least one word the RXFGTE1Full
// signal is asserted.
//------------------------------------------------------------------------------
assign FIFOGTE1Full = (RXFFillLevel >= 6'b000001); //change 1 full

assign RXFGTE1Full  =  (FEN == 1'b1) ? FIFOGTE1Full : HldBufValid;

endmodule

// -============================= End of UartRXFCntl ========================---
