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
//  File Name              : UartTXFCntl.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the control logic for the transmit
//               FIFO
// --=========================================================================--

`timescale 1ns/1ps
//------------------------------------------------------------------------------

module UartTXFCntl (
                    PCLK,
                    PRESETn,
                    TXBUSYSync,
                    UARTDRWrEn,
                    iTXFIFOData,
                    PWDATAIn,
                    TXFRdPtrIncSync,
                    FEN,
                    BRK,
                    UARTEN,
                    TXE,
                    TESTFIFO,
                    TXIFLSEL,
                    TestTXFInc,
                    CharTxCompSync,
                    TXIM,
                    UARTTXIC,
                    AbortSync,
                    
                    TXDataAvlbl,
                    RdPtrIncDone,
                    RegFileWrEn,
                    WrPtr,
                    RdPtr,
                    TXShiftData,
                    TXFF,
                    TXFE,
                    BUSY,
                    UARTTXIClr,
                    UARTTXRIS,
                    UARTTXMIS,
                    TXFLTE31Full,
                    TXIntLevel
                   );

input        PCLK;              // APB Clock
input        PRESETn;           // APB Bus Reset
input        TXBUSYSync;        // Transmitter busy
input        UARTDRWrEn;        // TX FIFO Write enable
input [7:0]  iTXFIFOData;       // To Shft Reg
input [7:0]  PWDATAIn;          // Data bus.
input        TXFRdPtrIncSync;   // TX FIFO Rd Ptr Inc
input        FEN;               // FIFO Enable
input        BRK;               // Break request
input        UARTEN;            // UART Enable
input        TXE;               // TX Enable
input        TESTFIFO;          // Test signal
input [2:0]  TXIFLSEL;          //  Selected interrupt level
input        TestTXFInc;        // read pointer inc for Tx fifo
input        CharTxCompSync;        // Character Tx complete
input        TXIM;              //  TX Interrupt Mask
input        UARTTXIC;          // For TX Interrupt clear
input        AbortSync;         // Transmission aborted

output        TXDataAvlbl;      // TX Data Available
output        RdPtrIncDone;     // Rd Ptr Inc done
output        RegFileWrEn;      // Register file write enable
output [4:0]  WrPtr;            // Write pointer
output [4:0]  RdPtr;            // Read pointer
output [7:0]  TXShiftData;      // Xmit Data
output        TXFF;             // Transmit FIFO Full
output        TXFE;             // Transmit FIFO Empty
output        BUSY;             // UART BUSY
output        UARTTXIClr;       //  TX Interrupt clear
output        UARTTXRIS;        // Transmit Raw Interrupt
output        UARTTXMIS;        // Transmit Masked Interrupt
output        TXFLTE31Full;     // Transmit Masked Interrupt
output        TXIntLevel;       // Transmit Masked Interrupt

//------------------------------------------------------------------------------
//
//                   UartTXFCntl
//                   ===========
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
//  The control logic for the transmit FIFO uses two pointers - a write
//  pointer and a read pointer. The pointers are 4 bits wide. The write
//  pointer points to the location to which the next write data will be
//  written into. The read pointer points to the next location whose
//  contents will be read out. Both the pointers operate on PCLK so as
//  to not miss any writes from the APB and to conveniently calculate
//  the FIFO fill level by finding the difference between the pointers.
//  When the FIFO is disabled, the pointers do not change and the fill
//  status of the holding buffer is indicated by a separate
//  bit 'HldBufValid'.
//
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//  Wire declarations
//------------------------------------------------------------------------------
wire        PCLK;
// APB Clock                                            (Module Input)

wire        PRESETn;
// APB Bus Reset                                        (Module Input)

wire        TXBUSYSync;
// Transmitter busy                                     (Module Input)

wire        UARTDRWrEn;
// TX FIFO Write enable                                 (Module Input)

wire [7:0]  iTXFIFOData;
// To Shft Reg                                          (Module Input)

wire [7:0]  PWDATAIn;
// Data bus.                                            (Module Input)

wire        TXFRdPtrIncSync;
// TX FIFO Rd Ptr Inc                                   (Module Input)

wire        FEN;
// FIFO Enable                                          (Module Input)

wire        UARTEN;
// UART Enable                                          (Module Input)

wire        TXE;
// TX Enable                                            (Module Input)

wire        TESTFIFO;
// Test signal                                          (Module Input)

wire [2:0]  TXIFLSEL;
//  Selected interrupt level                            (Module Input)

wire        TestTXFInc;
// read pointer inc for Tx fifo                         (Module Input)

wire        CharTxCompSync;
// Character Tx complete                                (Module Input)

wire        TXIM;
//  TX Interrupt Mask                                   (Module Input)

wire        UARTTXIC;
// For TX Interrupt clear                               (Module Input)

wire        AbortSync;
// Transmission abort                                   (Module Input)

wire    LoadShiftReg;
// Shift register load trigge

wire    WrPtrIncValid;
// Valid Write pointer increment

wire    RdPtrIncValid;
// Valid Read pointer increment

wire TXEdge;
// Detects edge in iTXIntLevel

wire HldBufValidEdge;
// Detects edge in HldBufValid

wire [5:0]   TXFFillLevel;
// FIFO Fill level indication

wire    TXFNotE;
// Signal used to indicate whether any data is available in the FIFO
// when the FIFO is enabled

wire    FIFOLTEHalfFull;
// FIFO FillLevel compare result

wire    FIFOLTEQFull;
// FIFO Fill level compare result

wire    FIFOLTE3QFull;
// FIFO Fill level compare result

wire    TXFLTEHalfFull;
// Signal to indicate if the transmit FIFO is less than or equal to
// half full. Used to generate the transmit interrupt UARTTXINTR

wire TXFLTEQFull;
// Signal to indicate if the transmit FIFO is less than or equal to
// a quarter full. Used to generate the transmit interrupt UARTTXINTR

wire TXFLTE3QFull;
// Signal to indicate if the transmit FIFO is less than or equal to
// three quarters full. Used to generate the transmit interrupt
// UARTTXINTR

wire TXFLTE8Full;
// Signal to indicate if the transmit FIFO is less than or equal to
// an eighth full. Used to generate the transmit interrupt UARTTXINTR

wire TXFLTE78Full;
// Signal to indicate if the transmit FIFO is less than or equal to
// seven eighth full. Used to generate the transmit interrupt UARTTXINTR

wire FIFOLTE8Full;
// FIFO Fill level compare result

wire FIFOLTE78Full;
// FIFO Fill level compare result

wire FIFOLTE31Full;
// FIFO Fill level compare result

wire Enabled;
// Is the UART Enabled?

wire TXShiftRegEFE;
// Is there a falling edge on the TXShiftRegE?

wire [5:0] WrPtrLevel;
// Signal used to calculate the Tx Fifo fill level

wire [5:0] RdPtrLevel;
// Signal used to calculate the Tx Fifo fill level

wire TXShiftRegE;
//TXShiftRegE1 masked by the enable signals

wire FlushFifo;
// Used for Flush the data from the shift register data buffer

wire iTXFF;
// Internal version of TXFF signal

wire iTXFE;
// Internal version of TXFE signal

wire iTXDataAvlbl;
// Internal version of TXDataAvlbl signal

wire iRdPtrIncDone;
// Internal version of RdPtrIncDone signal

wire iUARTTXIClr;
// Internal version of UARTTXIClr signal

//------------------------------------------------------------------------------
//  Register declarations
//------------------------------------------------------------------------------

reg [4:0]   iRdPtr;
// Read pointer 
// Internal version of RdPtr signal

reg [4:0]   NextRdPtr;
// D-input of Read pointer vector

reg [4:0]   iWrPtr;
// write pointer                  
// Internal version of WrPtr signal

reg [4:0]   NextWrPtr;
// D-input of the write pointer vector

reg    DelRdPtrInc;
// Delayed version of TXFRdPtrIncSync - FIFO read pointer increment
// signal used to convert the level on the TXFRdPtrIncSync signal to
// a one-clock wide pulse

reg    Wrap;
// Store the condition when the write pointer has rolled over (from
// '1111' to '0000') but the read pointer hasn't. This signal is
// used in calculating the FIFOFillLevel

reg    NextWrap;
// D-input of Wrap bit

reg   iTXIntLevel;
// Programmable interrupt level
// Internal version of TXIntLevel signal

reg    HldBufValid;
// Fill status of the holding register. Used in the case when the
// FIFO is disabled

reg    DelHldBufValid;
// delayed version of HldBufValid

reg    NextHldBufValid;
// D-input of HldBufValid bit

reg  [7:0]  iTXShiftData;
// Internal version of TXShiftData vector

reg  [7:0]  NextTXShiftData;
// D-input of iTXShiftData vector

reg    TXShiftRegE1;
// Fill status of the transmit Shift register
// NOTE : The assertion of this signal does not directly mean that the
// shift register is empty. It only implies that the next write to the
// transmit FIFO should fill up the shift register directly instead
// of accumulating in the FIFO.

reg    NxtTXShiftRegE;
// D-input of TXShiftRegE bit

reg    TXShiftRegEDel;
// Delayed version of TXShiftRegE

reg    iUARTTXRIS;
// Transmit Raw input register
// Internal version of UARTTXRIS signal

reg    NextUARTTXRIS;
// D-input of iUARTTXRIS

reg    DelUARTEN;
// Delayed version of the UARTEN signal. Used to detect a rising edge
// on this signal

reg    DelTXE;
// Delayed version of the TXE signal. Used to detect a rising edge on
// this signal

reg    FIFOFull;
// FIFO full status indication when the FIFO is enabled

reg    NextFIFOFull;
// D-input of FIFOFull bit

reg    FIFONotE;
// FIFO empty status indication when the FIFO is enabled

reg    NextFIFONotE;
// D-input of FIFONotE bit

reg    DelAbort;
// Delayed version of Abort input signal

reg    ShiftDataAvlbl;
// Shift register contains valid data that is currently beingtransmitted

reg    NextShftDatAvlbl;
// D-input of ShftDataAvlbl signal

reg   NextTXIntLevel;
// D-input for Programmable interrupt level

reg   DelUARTTXIC;
// Delayed version of UARTTXIC signal

reg DelTXIntLevel;
// Delayed version of TxIntLevel

reg CharTxCompDel;
// Delayed version of CharTxCompSync    

reg DelFEN;
// Delayed version of FEN

//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Indicate the availability of data to transmit to  the transmit logic.
//  Data is said to be available if the FIFO contains valid data or if
//  the Shift Register contains valid data.
//------------------------------------------------------------------------------
assign iTXDataAvlbl = TXFNotE | ShiftDataAvlbl;

//------------------------------------------------------------------------------
// The UART is BUSY when there is valid data available in the Transmit
// FIFO or when the Transmitter is busy transmitting.
//------------------------------------------------------------------------------
assign BUSY = iTXDataAvlbl | TXBUSYSync;

//------------------------------------------------------------------------------
// Ignore writes to FIFO if FIFO is already full. Use WrPtrIncValid
// signal as the Write enable. The Write pointer increment operation
// occurs only if the FIFO is enabled, but the WrPtrIncValid signal is
// generated independent of whether the FIFO is enabled or not.
//------------------------------------------------------------------------------
assign RegFileWrEn   = WrPtrIncValid;

//------------------------------------------------------------------------------
// Assert and De-assert Done signal the next clock after TXFRdPtrIncSync
// is seen
//------------------------------------------------------------------------------
assign iRdPtrIncDone = DelRdPtrInc;

//------------------------------------------------------------------------------
//   Generate enabled signal for UARTEN and TXE
//------------------------------------------------------------------------------
assign Enabled = UARTEN & TXE;

//------------------------------------------------------------------------------
// FlushFifo signal is used for flusing the data from the shift-regieter buffer.
// Software has to disable the UART to flush the FIFO.
//------------------------------------------------------------------------------
assign FlushFifo   = !(UARTEN) & !(FEN) & (DelFEN);


//------------------------------------------------------------------------------
// Connect local copies of signals to ports
//------------------------------------------------------------------------------
assign WrPtr          = iWrPtr;
assign RdPtr          = iRdPtr;
assign TXFF           = iTXFF;
assign TXFE           = iTXFE;
assign TXShiftData    = iTXShiftData;
assign TXDataAvlbl    = iTXDataAvlbl;
assign RdPtrIncDone   = iRdPtrIncDone;
assign UARTTXRIS      = iUARTTXRIS;
assign UARTTXIClr     = iUARTTXIClr;
assign TXIntLevel     = iTXIntLevel;


//------------------------------------------------------------------------------
// Sequential always process for registers/flip-flops in this block
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
begin : p_PtrsSeq
  if (PRESETn == 1'b0)
    begin
      iWrPtr          <= 5'b00000;  
      iRdPtr          <= 5'b00000; 
      DelRdPtrInc     <= 1'b0;
      Wrap            <= 1'b0;
      HldBufValid     <= 1'b0;
      iTXShiftData    <= 8'b00000000;
      TXShiftRegE1    <= 1'b1;
      TXShiftRegEDel  <= 1'b1;
      iUARTTXRIS      <= 1'b0;
      DelUARTEN       <= 1'b0;
      DelTXE          <= 1'b1;
      FIFOFull        <= 1'b0;
      FIFONotE        <= 1'b0;
      DelAbort        <= 1'b0;
      ShiftDataAvlbl  <= 1'b0;
      iTXIntLevel     <= 1'b0;
      DelUARTTXIC     <= 1'b0;
      DelTXIntLevel   <= 1'b0;
      DelHldBufValid  <= 1'b0;
      CharTxCompDel   <= 1'b0;
      DelFEN          <= 1'b0;
    end
  else
    begin
      iWrPtr          <= NextWrPtr;
      iRdPtr          <= NextRdPtr;
      DelRdPtrInc     <= TXFRdPtrIncSync;
      Wrap            <= NextWrap;
      HldBufValid     <= NextHldBufValid;
      iTXShiftData    <= NextTXShiftData;
      TXShiftRegE1    <= NxtTXShiftRegE;
      TXShiftRegEDel  <= TXShiftRegE;
      iUARTTXRIS      <= NextUARTTXRIS;
      DelUARTEN       <= UARTEN;
      DelTXE          <= TXE;
      FIFOFull        <= NextFIFOFull;
      FIFONotE        <= NextFIFONotE;
      DelAbort        <= AbortSync;
      ShiftDataAvlbl  <= NextShftDatAvlbl;
      iTXIntLevel     <= NextTXIntLevel;
      DelUARTTXIC     <= UARTTXIC;
      DelTXIntLevel   <= iTXIntLevel;
      DelHldBufValid  <= HldBufValid;
      CharTxCompDel   <= CharTxCompSync;
      DelFEN          <= FEN;
    end
end // p_PtrsSeq;

//------------------------------------------------------------------------------
// Load the shift register with transmit data from the FIFO when either
//  of the following conditions occur:
// * The UART is just enabled, and there is no Abort condition
// * The Abort condition is just removed and the UART is already enabled
// * The Read pointer increment signal (TXFRdPtrIncSync) signal is just
//   asserted with the UART being enabled and there being no Abort
//   condition.
// Add BRK, to prevent action when break is about to be asserted.
//------------------------------------------------------------------------------

assign LoadShiftReg = (Enabled) & !(AbortSync) & !(BRK) &
                       ((((DelAbort) | (!DelUARTEN) | (!DelTXE)) &
                        !(ShiftDataAvlbl)) |
                        (TXFRdPtrIncSync & !(DelRdPtrInc)));   
//------------------------------------------------------------------------------
// Increment the write pointer when there is a write to the FIFO from
// the APB. The increment should be avoided if the transmit FIFO is
// already full or if the TXShiftRegE signal is asserted indicating
// that the next write should go to the shift register directly. If
// TXShiftRegE is not already asserted and if it is about to be
// asserted on the next PCLK (as indicated by the assertion of LoadShift
// Reg with the FIFO being empty), then the write data is to be written
// into the Shift register and not into the FIFO.
//------------------------------------------------------------------------------
assign WrPtrIncValid = UARTDRWrEn & ( !(TXShiftRegE |
   ( !(TXShiftRegE) & LoadShiftReg &  !(TXFNotE)))) & ( !(iTXFF)
                      | (iTXFF & LoadShiftReg));

//------------------------------------------------------------------------------
// Freeze the Write pointer at zero when the FIFO is disabled. When the
//  FIFO is enabled and when the WrPtrIncValid signal is asserted,
//  increment the Write pointer by 1.
//------------------------------------------------------------------------------
always @(iWrPtr or WrPtrIncValid or FEN)
begin : p_WrPtrComb
  if (FEN == 1'b0)
    NextWrPtr = 5'b00000; //To change  
  else if (WrPtrIncValid == 1'b1)
    NextWrPtr = ((iWrPtr) + 1'b1);
  else
    NextWrPtr = iWrPtr;
end // p_WrPtrComb;

//------------------------------------------------------------------------------
// Increment the read pointer when the FIFO is not already empty and
// either the Shift register is loaded with the next transmit data byte
//  or if the fifo is in testmode and there is a read from the fifo.
//------------------------------------------------------------------------------
assign  RdPtrIncValid = (TXFNotE & (LoadShiftReg |
                                            (TestTXFInc & TESTFIFO)));

//------------------------------------------------------------------------------
// Freeze the read pointer at zero when the FIFO is disabled. When the
// FIFO is enabled and the RdPtrIncValid signal is asserted, increment
// the Read pointer by 1.
//------------------------------------------------------------------------------
always @(iRdPtr or FEN or RdPtrIncValid)
begin : p_RdPtrComb
  if (FEN == 1'b0)
    NextRdPtr = 5'b00000; 
  else if (RdPtrIncValid == 1'b1)
    NextRdPtr = ((iRdPtr) + 1'b1);
  else
    NextRdPtr = iRdPtr;
end // p_RdPtrComb;

//------------------------------------------------------------------------------
// The 'Wrap' bit is used to keep track of the condition when the
// write pointer has wrapped around from '1111' to '0000', but
// the read pointer has not wrapped. This bit is used to calculate
// the FIFOFillLevel. As with the pointers, 'Wrap' is kept
// cleared when the FIFO is disabled.
//------------------------------------------------------------------------------
always @ (iWrPtr or iRdPtr or Wrap or FEN or RdPtrIncValid or
          WrPtrIncValid)
begin : p_WrapComb
  if (FEN == 1'b0)
    NextWrap = 1'b0;
  else if (((iWrPtr == 5'b11111) & (WrPtrIncValid == 1'b1)) ^
         ((iRdPtr == 5'b11111) & (RdPtrIncValid == 1'b1)))
    NextWrap =  !(Wrap);
  else
    NextWrap = Wrap;
end // p_WrapComb;

//------------------------------------------------------------------------------
// The FIFOFull signal indicates the status of the FIFO when it is
// enabled. When the FIFO is one less than full and there is
// another write to the FIFO, the FIFOFull signal is set. When
// the FIFO is already full and there is a read from the FIFO,
// the FIFOFull signal is de-asserted
//------------------------------------------------------------------------------
always @(TXFFillLevel or FIFOFull or FEN or WrPtrIncValid or
         RdPtrIncValid)
begin : p_FIFOFull
  if (FEN == 1'b0)
    NextFIFOFull = 1'b0;
  else if ((TXFFillLevel == 6'b011111) && (WrPtrIncValid == 1'b1) &&
           (RdPtrIncValid == 1'b0))
      NextFIFOFull = 1'b1;
  else if ((FIFOFull == 1'b1) && (RdPtrIncValid == 1'b1) &&
         (WrPtrIncValid == 1'b0))
    NextFIFOFull = 1'b0;
  else
    NextFIFOFull = FIFOFull;
  end // p_FIFOFull;

//------------------------------------------------------------------------------
// The FIFONotE signal indicates the status of the FIFO when it is
// enabled. If the FIFO is empty and there is a write to the FIFO,
// the FIFONotE signal is asserted. If one location in the FIFO
// is filled and there is a read from the FIFO, the FIFOE
// signal is asserted.
//------------------------------------------------------------------------------
always @(TXFFillLevel or FIFONotE or FEN or WrPtrIncValid or
         RdPtrIncValid)
begin : p_FIFONotE
  if (FEN == 1'b0)
    NextFIFONotE = 1'b0;
  else if ((FIFONotE == 1'b0) && (WrPtrIncValid == 1'b1))
    NextFIFONotE = 1'b1;
  else if ((TXFFillLevel == 6'b000001) && (RdPtrIncValid == 1'b1) &&
         (WrPtrIncValid == 1'b0))
    NextFIFONotE = 1'b0;
  else
    NextFIFONotE = FIFONotE;
end // p_FIFONotE;

//------------------------------------------------------------------------------
// When the FIFO is disabled, have a single bit to indicate fill status
// while the pointers are frozen at zero. The HldBufValid signal has a
// reset value of 0, toggles to 1 when there is a write and back to
// zero when there is a read. The write and read requests can occur
// simultaneously. The two cases to be considered are when HldBufValid
// is 1 and when it is 0. When a write and read occur simultaneously
// with a byte already in the holding buffer (HldBufValid == 1), the
// write is allowed and HldBufValid remains set (untoggled). When
// HldBufValid is 0 (holding buffer empty), a read cannot occur because
//  reads are from the Transmit section which reads data from the
// buffer only if valid data is available.
//------------------------------------------------------------------------------
always @(FEN or RdPtrIncValid or WrPtrIncValid or HldBufValid)
begin : p_BufValid
  if (FEN == 1'b1)
    NextHldBufValid = 1'b0;
  else if ((WrPtrIncValid == 1'b1) ^ (RdPtrIncValid == 1'b1))
    NextHldBufValid =  !(HldBufValid);
  else
    NextHldBufValid = HldBufValid;
end // p_BufValid;

//------------------------------------------------------------------------------
// Fill status of the transmit Shift register
// NOTE : The assertion of this signal does not directly mean that
// the shift register is empty. It only implies that the next write
// to the transmit FIFO should fill up the shift register directly,
// instead of accumulating in the FIFO
// TXShiftRegE1 is the register value, TXShiftRegE is that value enabled
// by the delayed enable and AbortSync signals
//------------------------------------------------------------------------------
always @(TXShiftRegE1 or UARTDRWrEn or
         LoadShiftReg or TXFNotE)
  begin : p_ShiftRegE1

//------------------------------------------------------------------------------
// If the FIFO is already empty and the shift register has to be loaded
//  with transmit data and there is no write occuring to the FIFO, the
// TXShiftRegE signal is set.
//------------------------------------------------------------------------------
    if ((LoadShiftReg == 1'b1) && (TXFNotE == 1'b0) &&
           (UARTDRWrEn == 1'b0))
      NxtTXShiftRegE = 1'b1;
//------------------------------------------------------------------------------
// Else, if there is a write to the FIFO, the shift register is no
// longer empty
//------------------------------------------------------------------------------
    else if (UARTDRWrEn == 1'b1)
      NxtTXShiftRegE = 1'b0;
    else
      NxtTXShiftRegE = TXShiftRegE1;
  end // p_ShiftRegE;

//------------------------------------------------------------------------------
// If the UART is disabled, then writes should accumulate in the FIFO
// without updating the transmit shift register
//------------------------------------------------------------------------------
assign TXShiftRegE = TXShiftRegE1 && (DelUARTEN == 1'b1) && 
                      (DelAbort == 1'b0) && (DelTXE == 1'b1);

  // TXShiftRegE Fallingedges are only signalled when the UART is enabled.
assign TXShiftRegEFE = (Enabled == 1'b1) && (TXShiftRegE == 1'b0) &&
                       (TXShiftRegEDel == 1'b1);

//------------------------------------------------------------------------------
// The TXShiftData register holds the transmit data byte.
//------------------------------------------------------------------------------
always @ (iTXShiftData or iTXFIFOData or UARTDRWrEn or TXShiftRegE
          or PWDATAIn or TXFNotE or LoadShiftReg)
  begin : p_TXShiftData
//------------------------------------------------------------------------------
// If the FIFO and the shift register are empty, then on the next write,
// move the write data straight into the shift register.
// If the TXShiftRegE signal is already set or if the Shift register
// has to be loaded with the next transmit byte with the transmit FIFO
// being empty, and, if there is a write to the FIFO at the same time,
// the write data bus contents are copied directly into the Shift
// register.
//------------------------------------------------------------------------------
    if ((UARTDRWrEn == 1'b1) && ((TXShiftRegE == 1'b1) ||
                    ((TXFNotE == 1'b0) && (LoadShiftReg == 1'b1))))
      NextTXShiftData = PWDATAIn;
//------------------------------------------------------------------------------
// If the Shift register has to be loaded with the next transmit data
// byte and the FIFO is not empty, then load the data in the FIFO
// pointed to by the current value of the read pointer, into the shift
// register.
//------------------------------------------------------------------------------
    else if ((LoadShiftReg == 1'b1) && (TXFNotE == 1'b1))
      NextTXShiftData = iTXFIFOData;
    else
      NextTXShiftData = iTXShiftData;
  end // p_TXShiftData;

//------------------------------------------------------------------------------
// The ShiftDataAvlbl signal indicates whether there is valid data
// present in the Transmit shift register. This signal is used to
// generate the TXDataAvlbl output signal.
//------------------------------------------------------------------------------
always @(ShiftDataAvlbl or LoadShiftReg or TXFNotE or UARTDRWrEn or
          TXShiftRegE or Enabled or TXE or CharTxCompSync or BRK
          or CharTxCompDel or FlushFifo)
begin : p_ShiftDataAvlbl
  if (FlushFifo == 1'b1)
      NextShftDatAvlbl = 1'b0;
  // If disabled, rising edge of TxCharComp indicates char has gone. 
  else if ((Enabled == 1'b0 || BRK ) &&
           (CharTxCompSync == 1'b1) && (CharTxCompDel == 1'b0))
      NextShftDatAvlbl = 1'b0;
  else if ((TXFNotE == 1'b0) && (UARTDRWrEn == 1'b0))
    begin // Fifo Empty, and no write to it but data read out
      if (LoadShiftReg == 1'b1) 
        NextShftDatAvlbl = 1'b0;
      else
        NextShftDatAvlbl = ShiftDataAvlbl;
    end  
  else if (((LoadShiftReg == 1'b1) && (TXFNotE == 1'b1) &&
          (TXE == 1'b1)) || ((LoadShiftReg == 1'b1) &&
          (TXFNotE == 1'b0) && (TXE == 1'b1) &&
          (UARTDRWrEn == 1'b1)) || ((TXShiftRegE == 1'b1) &&
          (UARTDRWrEn == 1'b1) && (TXE == 1'b1)))
     NextShftDatAvlbl = 1'b1;
  else
     NextShftDatAvlbl = ShiftDataAvlbl;
end // p_ShiftDataAvlbl;
  
//------------------------------------------------------------------------------
// The interrupt fifo level is programmable, it can be either at the
// one eighth, quarter, half, three quarter or seven eighth level.
//------------------------------------------------------------------------------

always @(iTXIntLevel or TXIFLSEL or TXFLTE8Full or TXFLTEQFull or
         TXFLTEHalfFull or TXFLTE3QFull or TXFLTE78Full )
  begin : p_TXIntLevel
    NextTXIntLevel = iTXIntLevel;

    case (TXIFLSEL)
      3'b000 : NextTXIntLevel = TXFLTE8Full;
      3'b001 : NextTXIntLevel = TXFLTEQFull;
      3'b010 : NextTXIntLevel = TXFLTEHalfFull;
      3'b011 : NextTXIntLevel = TXFLTE3QFull;
      3'b100 : NextTXIntLevel = TXFLTE78Full;
      default: NextTXIntLevel = 1'b0;
    endcase
  end // p_TXIntLevel;


//------------------------------------------------------------------------------
// UARTTXIClr is a one PCLK-wide pulse used to clear the UARTTXINTR.
//------------------------------------------------------------------------------
assign iUARTTXIClr = UARTTXIC &  !(DelUARTTXIC);


//------------------------------------------------------------------------------
// Detect an edge in the interrupt level line and HldBufValid line.
//------------------------------------------------------------------------------
assign TXEdge = iTXIntLevel ^ DelTXIntLevel;
assign HldBufValidEdge = HldBufValid ^ DelHldBufValid;


//------------------------------------------------------------------------------
// Assert the transmit interrupt when either of the following
// conditions are met :
// * The FIFO is enabled and is emptied such that its fill level
//   is equal to or below its programmed level
// * The FIFO is disabled and the holding register is empty
// The transmit interrupt is de-asserted when the condition which
// led to its assertion is no longer met.  It can also be cleared by
// a write to bit 5 of the Interrupt Clear register.
//------------------------------------------------------------------------------
always @(FEN or iTXIntLevel or HldBufValid or HldBufValidEdge or TXEdge or
         iUARTTXIClr or iUARTTXRIS or TXShiftRegEFE)
begin : p_UARTTXINTR
  NextUARTTXRIS = iUARTTXRIS;
  if ((FEN == 1'b1) && (iTXIntLevel == 1'b1) && (TXEdge == 1'b1))
    NextUARTTXRIS = 1'b1;
  else if ((FEN == 1'b0) && (HldBufValid == 1'b0) && (HldBufValidEdge == 1'b1))
    NextUARTTXRIS = 1'b1;
  else if ((FEN == 1'b0) && (HldBufValid == 1'b0) && (iUARTTXRIS == 1'b0) &&
           (TXShiftRegEFE == 1'b1))
    NextUARTTXRIS = 1'b1;
  else if(((FEN == 1'b1) && (iTXIntLevel == 1'b0) && (TXEdge == 1'b1)) ||
          ((FEN == 1'b0) && (HldBufValid == 1'b1) && (HldBufValidEdge == 1'b1)))
    NextUARTTXRIS = 1'b0;
  else if (iUARTTXIClr == 1'b1)
    NextUARTTXRIS = 1'b0;
end // p_UARTTXINTR

assign  UARTTXMIS = iUARTTXRIS & TXIM;

//------------------------------------------------------------------------------
// Subtract the read pointer from the write pointer to calculate
// the FIFO fill level. Use the Wrap bit to take into account
// whether the write pointer has wrapped without the read pointer
// not having wrapped
//------------------------------------------------------------------------------
assign WrPtrLevel     = {Wrap,iWrPtr};
assign RdPtrLevel     = {1'b0,iRdPtr};
assign TXFFillLevel   = (WrPtrLevel - RdPtrLevel);

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the FIFOFull signal to indicate
// FIFO fill status. When the FIFO is disabled, use the
// HldBufValid signal to indicate FIFO fill status.
//------------------------------------------------------------------------------
assign iTXFF =  (FEN == 1'b1) ? FIFOFull : HldBufValid;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the FIFONotE signal to indicate
// FIFO fill status. When the FIFO is disabled, use the
// HldBufValid signal to indicate FIFO fill status.
//------------------------------------------------------------------------------
assign TXFNotE = (FEN == 1'b1) ? FIFONotE : HldBufValid;
assign  iTXFE      = !TXFNotE;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the TXFFillLevel signal to
// find whether the FIFO is less than or equal to an eighth full,
// quarter full, half full, three quarter full or seven eighth full.
// If the FIFO is disabled, the HldBufValid signal will do the job.
//------------------------------------------------------------------------------
assign FIFOLTE8Full = (TXFFillLevel <= 6'b000100); ///To change

assign TXFLTE8Full = (FEN == 1'b1) ? FIFOLTE8Full : !HldBufValid;

assign FIFOLTEQFull = ((TXFFillLevel) <= 6'b001000);

assign TXFLTEQFull  =  (FEN == 1'b1) ? FIFOLTEQFull : !HldBufValid;

assign FIFOLTEHalfFull = (TXFFillLevel <= 6'b010000);

assign TXFLTEHalfFull  = (FEN == 1'b1) ? FIFOLTEHalfFull : !HldBufValid;

assign FIFOLTE3QFull = ((TXFFillLevel) <= 6'b011000);

assign TXFLTE3QFull  =  (FEN == 1'b1) ? FIFOLTE3QFull : !HldBufValid;

assign FIFOLTE78Full = (TXFFillLevel <= 6'b011100);

assign TXFLTE78Full = (FEN == 1'b1) ? FIFOLTE78Full : !HldBufValid;

//------------------------------------------------------------------------------
// When the FIFO is enabled, use the TXFFillLevel signal to find
// whether the Transmit FIFO has at least one empty location. If the
// FIFO is disabled, the HldBufValid signal will do the job. When the
// transmit FIFO has at least one empty location the TXFLE15Full
// signal is asserted.
//------------------------------------------------------------------------------
assign FIFOLTE31Full = (TXFFillLevel <= 6'b011111); //To change to 31 full

assign TXFLTE31Full  =  (FEN == 1'b1) ? FIFOLTE31Full : ~HldBufValid;


endmodule
// --=================== End of UartTXFCntl ==========================--
