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
//  File Name              : UartReceive.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose   : This block instantiates the UartRXCntl state machine,
//              the UartRXParity block and the UartDataStp state m/c.
//------------------------------------------------------------------------------

`timescale 1ns/1ps
module UartReceive (
                    UARTCLK,
                    nUARTRST,
                    UARTENSync,
                    SIRENSync,
		    RXESync,
                    Baud16,
                    WLEN,
                    STP2,
                    EPS,
                    PEN,
                    SPS,
                    RXFWrDoneSync,
                    Zerobaud,
                    RXFESync,
                    RXD,
                    RTIMSync,
                    FEIMSync,
                    PEIMSync,
                    BEIMSync,
                    UARTRTICSync,
                    UARTFEICSync,
                    UARTPEICSync,
                    UARTBEICSync,
                    RXFWr,
                    RXFIFOData,
                    DataStp,
                    RXBUSY,
                    RXEnable,
                    UartRXCntlState,
                    UARTRISerr,
                    UARTMISerr,
                    UARTEINTRfbp,
                    CharRxComp
                   );

input        UARTCLK;          // Main UART Clock
input        nUARTRST;         // Muxed reset (from nUARTRST)
input        UARTENSync;       // UART Enable
input        SIRENSync;        // SIR Enable
input        RXESync;          // RX Enable
input        Baud16;           // Bit Period Reference
input [1:0]  WLEN;             // Data bits per word
input        STP2;             // 2 stop bits
input        EPS;              // Even Parity Select
input        PEN;              // Parity enable
input        SPS;              // Stick Parity Select
input        RXFWrDoneSync;    // RX FIFO Write Done
input        Zerobaud;         // Baud Divisor set to 0
input        RXFESync;         // Receive FIFO Empty
input        RXD;              // Receive serial input
input        RTIMSync;         // RX Timeout interrupt Mask
input        FEIMSync;         // Framing Error interrupt Mask
input        PEIMSync;         // Parity Error Interrupt Mask
input        BEIMSync;         // Break Error Interrupt Mask
input        UARTRTICSync;     // For RX Timeout interrupt Clear
input        UARTFEICSync;     // For Framing Error interrupt Clear
input        UARTPEICSync;     // For Parity Error interrupt Clear
input        UARTBEICSync;     // For Break Error interrupt Clear

output        RXFWr;           // Receive FIFO Write (level)
output [10:0] RXFIFOData;      // Received Data
output        DataStp;         // Receive line Idle
output        RXBUSY;          // Receiver Busy
output        RXEnable;        // Rx Enable
output [2:0]  UartRXCntlState; // Rx state
output [2:0]  UARTRISerr;      // Raw interrupt status, error signals
output [2:0]  UARTMISerr;      // Masked Interrupt status, error signals
output        UARTEINTRfbp;    // Combined int for break, frame,parity
output        CharRxComp;      // Char Rx complete
  

//------------------------------------------------------------------------------
//
//                                  UartReceive
//                                  ===========
//------------------------------------------------------------------------------
// Overview
// ========
//
// The receive section instantiates three sub-modules - UartRXParShft,
// UartRXCntl and UartDataStp. The UartRXCntl block is the main control
// state machine. The UartRXParshft block contains the receive shift
// register and performs parity error checking and frame error checking
// on the received data bit stream.
// The UartDataStp block detects the condition when there is some data
// in the receive FIFO but there has been no activity on the receive
// line for a 32-bit period.
//  When the RXD input line goes low, the receive state machine  starts
// synchronising to the middle of the start bit. Thereafter, the RXD
// line is sampled at the middle of every bit period. The ShiftEn signal
// from the Control state machine to the UartRXParShft block shifts data
// into a shift register in the UartRXParShft block. The SampleStopBit,
// SampleParity and ClearShiftReg signals indicate when the stop bit is
// to be sampled, when the Parity bit is to be sampled and when the
// Shift register is to be cleared to the UartRXParShft block.
// The contents of the shift register in the UartRXParShft block is made
// available as the FIFOData signal. The control state machine also puts
// out a ReloadWD signal whenever a start bit is detected or whenever
// the last stop bit is detected for the UartDataStp state machine to
// reload its internal watchdog counter. This counter is a 9 bit counter
// which counts down on every Baud16. The Zerobaud input signal is
// asserted if the illegal divisor value of 0 is written to the Bit
// rate divisor
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                  (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                      (Module Input)

wire        UARTENSync;
// UART Enable                                      (Module Input)

wire        SIRENSync;
// SIR Enable                                       (Module Input)

wire        RXESync;
// RX Enable                                        (Module Input)

wire        Baud16;
// Bit Period Reference                             (Module Input)

wire [1:0]  WLEN;
// Data bits per word                               (Module Input)

wire        STP2;
// 2 stop bits                                      (Module Input)

wire        EPS;
// Even Parity Select                               (Module Input)

wire        PEN;
// Parity enable                                    (Module Input)

wire        RXFWrDoneSync;
// RX FIFO Write Done                               (Module Input)

wire        Zerobaud;
// Baud Divisor set to 0                            (Module Input)

wire        RXFESync;
// Receive FIFO Empty                               (Module Input)

wire        RXD;
// Receive serial input                             (Module Input)

wire        RTIMSync;
// RX Timeout interrupt Mask                        (Module Input)

wire        FEIMSync;
// Framing Error interrupt Mask                     (Module Input)

wire        PEIMSync;
// Parity Error Interrupt Mask                      (Module Input)

wire        BEIMSync;
// Break Error Interrupt Mask                       (Module Input)

wire        UARTRTICSync;
// For RX Timeout interrupt Clear                   (Module Input)

wire        UARTFEICSync;
// For Framing Error interrupt Clear                (Module Input)

wire        UARTPEICSync;
// For Parity Error interrupt Clear                 (Module Input)

wire        UARTBEICSync;
// For Break Error interrupt Clear                  (Module Input)

wire        SPS;
// Stick Parity Select                              (Module Input)

wire SampleParity;
wire ShiftEn;
wire ReloadWD;
wire ClearShiftReg;
wire DtPrZero;
wire RXDsampled;
wire UARTBERIS;
wire UARTPERIS;
wire UARTFERIS;
wire UARTBEMIS;
wire UARTPEMIS;
wire UARTFEMIS;

//------------------------------------------------------------------------------
// Combine the 3 error related signals generated in this block
//------------------------------------------------------------------------------
assign  UARTRISerr =  {UARTBERIS, UARTPERIS, UARTFERIS};
assign  UARTMISerr =  {UARTBEMIS, UARTPEMIS, UARTFEMIS};

//------------------------------------------------------------------------------
// Combine the 3 error interrupts to form the combined error
// interrupt for frame, break and parity. The overrun error interrupt
// will be added to form the UARTEINTR signal.
//------------------------------------------------------------------------------
assign  UARTEINTRfbp = UARTBEMIS | UARTPEMIS | UARTFEMIS;


// The Receive control state machine						
UartRXCntl
     uUartRXCntl (
                  .UARTCLK         (UARTCLK),
                  .nUARTRST        (nUARTRST),
                  .Baud16          (Baud16),
                  .UARTENSync      (UARTENSync),
		  .SIRENSync       (SIRENSync),
                  .RXESync         (RXESync),
                  .RXD             (RXD),
                  .WLEN            (WLEN),
                  .STP2            (STP2),
                  .PEN             (PEN),
                  .Zerobaud        (Zerobaud),
                  .RXFWrDoneSync   (RXFWrDoneSync),
                  .DtPrZero        (DtPrZero),
                  .UARTFEICSync    (UARTFEICSync),
                  .UARTBEICSync    (UARTBEICSync),
                  .FEIMSync        (FEIMSync),
                  .BEIMSync        (BEIMSync),
                  .ShiftEn         (ShiftEn),
                  .SampleParity    (SampleParity),
                  .RXEnable        (RXEnable),
                  .UartRXCntlState (UartRXCntlState),
                  .RXDsampled      (RXDsampled),
                  .ClearShiftReg   (ClearShiftReg),
                  .RXFWr           (RXFWr),
                  .ReloadWD        (ReloadWD),
                  .FramingError    (RXFIFOData[8]),
                  .Break           (RXFIFOData[10]),
                  .RXBUSY          (RXBUSY),
		  .CharRxComp      (CharRxComp),
                  .UARTFERIS       (UARTFERIS),
                  .UARTBERIS       (UARTBERIS),
                  .UARTFEMIS       (UARTFEMIS),
                  .UARTBEMIS       (UARTBEMIS)
                 );


// This block contains the receive shift register.
UartRXParShft
    uUartRXParShft (
                    .UARTCLK       (UARTCLK),
                    .nUARTRST      (nUARTRST),
                    .RXDsampled    (RXDsampled),
                    .ShiftEn       (ShiftEn),
                    .SampleParity  (SampleParity),
                    .ClearShiftReg (ClearShiftReg),
                    .SPS           (SPS),
                    .EPS           (EPS),
                    .PEN           (PEN),
                    .WLEN          (WLEN),
                    .PEIMSync      (PEIMSync),
                    .UARTPEICSync  (UARTPEICSync),
                    .RecdDATA      (RXFIFOData[7:0]),
                    .DtPrZero      (DtPrZero),
                    .ParityError   (RXFIFOData[9]),
                    .UARTPERIS     (UARTPERIS),
                    .UARTPEMIS     (UARTPEMIS)
                   );


// This state mcahine detects idle on the receive line
UartDataStp
    uUartDataStp (
                  .UARTCLK      (UARTCLK),
                  .nUARTRST     (nUARTRST),
                  .Baud16       (Baud16),
                  .ReloadWD     (ReloadWD),
                  .RXFESync     (RXFESync),
                  .RTIMSync     (RTIMSync),
                  .UARTRTICSync (UARTRTICSync),
                  .DataStp      (DataStp)
                 );
endmodule

// --============================== End of UartTest ==========================--
