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
//  File Name              : UartTXCntl.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
//  Purpose   : This state machine is the main TX state machine.
// --=========================================================================--

`timescale 1ns/1ps

module UartTXCntl (
                   UARTCLK,
                   nUARTRST,
                   RXEnable,
                   UartRXCntlState,
                   CTSEn,
                   nCTSSyncUARTCLK,
                   Baud16,
                   TXDataAvlblSync,
                   RdPtrIncDoneSync,
                   UARTENSync,
                   TXESync,
                   TXShiftData,
                   WLEN,
                   STP2,
                   PEN,
                   EPS,
                   BRK,
                   Zerobaud,
                   SPS,
                   
                   TXFRdPtrInc,
                   TXD,
                   TXBUSY,
                   CharTxComp,
                   StopBaudCnt
                  );

input        UARTCLK;           // Main UART Clock
input        nUARTRST;          // Muxed reset (from nUARTRST)
input        RXEnable;          // Rx Enable
input [2:0]  UartRXCntlState;   // RX state
input        CTSEn;             // CTS flow control enable
input        nCTSSyncUARTCLK;   // modem signal
input        Baud16;            // Bit Period ref
input        TXDataAvlblSync;   // TX Data Available
input        RdPtrIncDoneSync;  // TX FIFO Rd pointer Inc done
input        UARTENSync;        // UART Enable
input        TXESync;           // TX Enable
input [7:0]  TXShiftData;       // TX Data
input [1:0]  WLEN;              // Bits per word
input        STP2;              // 2 stop bits
input        PEN;               // Parity enabled
input        EPS;               // Even Parity Select
input        BRK;               // Transmit Break
input        Zerobaud;          // Baud divisor set to 0
input        SPS;               // Stick Parity Select bit

output        TXFRdPtrInc;      // TX FIFO Rd Ptr Inc
output        TXD;              // Internal Transmit line
output        TXBUSY;           // Transmitter busy
output        CharTxComp;       // Character Tx complete
output        StopBaudCnt;      // Stop Baud Counter

//------------------------------------------------------------------------------
//                             UartTXCntl
//                             =========
//------------------------------------------------------------------------------
//
// Overview
// ========
//  The transmit state machine shifts out transmit data according to the
// parameters programmed in the LCR_H register. When a Break is to be
// transmitted, the transmit line is pulled LOW. The duration for which
// the TXD line remains low is directly dependent on the duration for
// which the Break bit is set. After break bit is set to 1, the TX line
// is pulled high and for 1 bit time, data transmission is stopped
// to avoid potential glitches in the SIROUT line.  If the Uart is
// disabled during transmision the current word will be transmitted and
// then transmission will stop.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                   (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                       (Module Input)

wire        Baud16;
// Bit Period ref                                    (Module Input)

wire        TXDataAvlblSync;
// TX Data Available                                 (Module Input)

wire        RdPtrIncDoneSync;
// TX FIFO Rd pointer Inc done                       (Module Input)

wire        UARTENSync;
// UART Enable                                       (Module Input)

wire        TXESync;
// TX Enable                                         (Module Input)

wire [1:0]  WLEN;
// Bits per word                                      (Module Input)

wire        STP2;
// 2 stop bits                                        (Module Input)

wire        PEN;
// Parity enabled                                     (Module Input)

wire        EPS;
// Even Parity Select                                 (Module Input)

wire        BRK;
// Transmit Break                                     (Module Input)

wire        Zerobaud;
// Baud divisor set to 0                              (Module Input)

wire [7:0]  TXShiftData;
// TX Data                                            (Module Input)

wire        RXEnable;
// Rx Enable                                          (Module Input)

wire [2:0]  UartRXCntlState;
// RX state                                           (Module Input)

wire        CTSEn;
// CTS flow control enable                            (Module Input)

wire        nCTSSyncUARTCLK;
// modem signal                                       (Module Input)

wire        SPS;
// Stick Parity Select bit                            (Module Input)

// Aliases
wire       AbortTransmit;
wire       TXEnable;
wire       nBreak;
wire       LEN5;
wire       LEN6;
wire       LEN7;
wire       LEN8;
wire       Parity;

// Comparators
wire BitCountComp;
wire BitPeriodCmp;


//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
reg        TXFRdPtrInc;
// TX FIFO Rd Ptr Inc                                 (Module Output)

reg        TXBUSY;
// Transmitter busy                                   (Module Output)

reg        StopBaudCnt;
// Stop Baud Counter                                  (Module Output)

reg        iCharTxComp;
// Character Tx complete               
// Internal version of CharTxComp signal


//  Encoding style: Gray
reg  [3:0]  UartTXCntlState;
reg  [3:0]   UartTXCntlNext;
reg          NextTXFRdPtrInc;
reg          NextTXBUSY;

// Registers
reg          TXDReg;
reg          NextTXDReg;
reg   [2:0]  BitCount;
reg   [2:0]  NextBitCount;
reg   [3:0]  BitPeriodCnt;
reg   [3:0]  NextBitPeriodCnt;
reg   [6:0]  TXShiftReg;
reg   [6:0]  NextTXShiftReg;
reg          NextCharTxComp;

//------------------------------------------------------------------------------
// Expose internal register(s)...
//------------------------------------------------------------------------------
assign  TXD        = TXDReg;
assign  CharTxComp = iCharTxComp;

//------------------------------------------------------------------------------
// Expansion of aliases...
//------------------------------------------------------------------------------
assign AbortTransmit =  BRK | Zerobaud;

assign TXEnable      = (UARTENSync & TXESync);

assign nBreak        = !(BRK);

assign LEN5          = !(WLEN[1]) & !(WLEN[0]) & (!(EPS) ^ TXShiftData[4]
                        ^ TXShiftData[3] ^ TXShiftData[2] ^ TXShiftData[1] 
                        ^ TXShiftData[0]);

assign LEN6          = !(WLEN[1]) & WLEN[0] & (!(EPS) ^ TXShiftData[5] 
                        ^ TXShiftData[4] ^ TXShiftData[3] ^ TXShiftData[2]
                        ^ TXShiftData[1] ^ TXShiftData[0]);

assign LEN7          = WLEN[1] & !(WLEN[0]) & (!(EPS) ^ TXShiftData[6] ^ 
                        TXShiftData[5] ^ TXShiftData[4] ^ TXShiftData[3] ^ 
                        TXShiftData[2] ^ TXShiftData[1] ^ TXShiftData[0]);

assign LEN8          = WLEN[1] & WLEN[0] & (!(EPS) ^ TXShiftData[7] ^
                       TXShiftData[6] ^ TXShiftData[5] ^ TXShiftData[4] ^
                       TXShiftData[3] ^ TXShiftData[2] ^ TXShiftData[1] ^
                       TXShiftData[0]);

assign Parity        = LEN5 | LEN6 | LEN7 | LEN8;

//------------------------------------------------------------------------------
// Expansion of comparators...
//------------------------------------------------------------------------------
assign  BitCountComp = (BitCount[2:0] == 3'b000);
assign  BitPeriodCmp = (BitPeriodCnt[3:0] == 4'b0000);

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_StopBaudCnt
  if (nUARTRST == 1'b0)
    StopBaudCnt <= 1'b1;
  else if (((UartTXCntlState == 4'b0000) && (TXEnable == 1'b0)) &&
        ((UartRXCntlState == 3'b000) && (RXEnable == 1'b0)))
        StopBaudCnt <= 1'b1;
  else
        StopBaudCnt <= 1'b0;
end // p_StopBaudCnt;

//------------------------------------------------------------------------------
// State transition process
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : seq

  if (nUARTRST == 1'b0)
    begin
      UartTXCntlState <= 4'b0000;
      TXFRdPtrInc     <= 1'b0;
      TXBUSY          <= 1'b0;
      iCharTxComp     <= 1'b1;
    end
  else
    begin
      UartTXCntlState <= UartTXCntlNext;
      TXFRdPtrInc     <= NextTXFRdPtrInc;
      TXBUSY          <= NextTXBUSY;
      iCharTxComp     <= NextCharTxComp;
    end
  end // seq;

//------------------------------------------------------------------------------
// Output and next state logic generation
//------------------------------------------------------------------------------
always @(UartTXCntlState or TXShiftData or WLEN or BRK or PEN or STP2 or
         RdPtrIncDoneSync or TXDataAvlblSync or Baud16 or AbortTransmit or
         nBreak or Parity or TXDReg or BitCount or BitPeriodCnt or TXShiftReg
         or BitCountComp or BitPeriodCmp or iCharTxComp or TXEnable or CTSEn
         or nCTSSyncUARTCLK or EPS or SPS)
begin : combo
  // Default assignments
  UartTXCntlNext      = UartTXCntlState;
  NextTXFRdPtrInc     = 1'b0;
  NextTXBUSY          = 1'b0;
  NextTXDReg          = TXDReg;
  NextBitCount        = BitCount;
  NextBitPeriodCnt    = BitPeriodCnt;
  NextTXShiftReg      = TXShiftReg;
  NextCharTxComp      = iCharTxComp;

  case (UartTXCntlState)

    4'b0000 :
      begin
        // Transmit data is available and Baud16 is also asserted,
        // so shift out the start bit

        if ((TXDataAvlblSync & Baud16 & TXEnable & !(AbortTransmit))
             == 1'b1)
          begin
          //  Transmit data available in the FIFO, so wait for the next
          //  Baud16 before shifting out the start bit.
          //
          // The following has a priority for CTS. If CTS is enabled
          // then transmission can only proceed when nUARTCTS is low.
          // Else wait for it to be low before proceeding.
          //
          // If CTS is not enabled, then proceed as normal.
            if (CTSEn == 1'b1)
              begin
                if (nCTSSyncUARTCLK == 1'b0)
                  begin
                    NextTXDReg          = 1'b0;
                    NextBitPeriodCnt    = 4'b1111;
                    NextBitCount[2:0]   = {1'b1, WLEN[1:0]};
                    UartTXCntlNext      = 4'b0001;
                    NextCharTxComp      = 1'b0;
                    NextTXBUSY          = 1'b1;
                  end
                else
                  UartTXCntlNext      = 4'b0000;
              end
            else
              begin
                NextTXDReg          = 1'b0;
                NextBitPeriodCnt    = 4'b1111;
                NextBitCount[2:0]   = {1'b1, WLEN[1:0]};
                UartTXCntlNext      = 4'b0001;
                NextCharTxComp      = 1'b0;
                NextTXBUSY          = 1'b1;
             end
         end

       else if ((!(AbortTransmit) & !(Baud16) & TXEnable &
                 TXDataAvlblSync) == 1'b1)
         begin
          // Priority for CTS included below. If enabled then
          // nUARTCTS has to be asserted to proceed. Else continue as
          // normal.
          if (CTSEn == 1'b1)
            begin
              if (nCTSSyncUARTCLK == 1'b0)
                begin
                  UartTXCntlNext      = 4'b0101;
                  NextTXBUSY          = 1'b1;
                end
              else
                UartTXCntlNext      = 4'b0000;
            end
          else
            begin
              UartTXCntlNext      = 4'b0101;
              NextTXBUSY          = 1'b1;
            end
         end

        else if (!(TXEnable) == 1'b1)
          begin
            NextTXDReg          = TXDReg;
            NextBitPeriodCnt    = 4'b1111;
            NextBitCount        = 3'b000;
            UartTXCntlNext      = UartTXCntlState;
            NextTXShiftReg      = 7'b0000000;
            NextTXFRdPtrInc     = 1'b0;
            NextTXBUSY          = 1'b0;
          end

        else if ((BRK) == 1'b1)
          begin
            NextTXDReg          = 1'b0;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0100;
            NextCharTxComp      = 1'b1;
            NextTXBUSY          = 1'b1;
          end

        else
          begin
            NextTXFRdPtrInc = 1'b0;
            NextTXBUSY      = 1'b0;
          end
       end
      4'b0001 :
        begin
        //  Shift out the first data bit , increment BitCnt, reload the
        //  BitPeriodCnt counter and load the transmit shift
        // register.
        // Need TxCharComp set on entry to this state to pass break test
        if ((Baud16 & BitPeriodCmp) == 1'b1)
          begin
            NextTXDReg          = TXShiftData[0];
            NextBitPeriodCnt    = 4'b1111;
            NextTXShiftReg[6:0] = TXShiftData[7:1];
            UartTXCntlNext      = 4'b0011;
            NextCharTxComp      = 1'b0;
            NextTXBUSY          = 1'b1;
            //  Decrement the BitPeriodCnt counter with Baud16 as the
            //  count enable to time the start bit.
          end

        else if ((Baud16 & !(BitPeriodCmp)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartTXCntlNext      = 4'b0001;
            NextTXBUSY          = 1'b1;
          end
        else
          NextTXBUSY = 1'b1;
       end

      4'b0011 :
        begin
        //  At the end of a bit period, shift in the next bit and reload
        //  the BitPeriodCnt counter

        if ((!(BitCountComp) & BitPeriodCmp & Baud16) == 1'b1)
          begin
            NextTXDReg          = TXShiftReg[0];
            NextBitCount        = BitCount - 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            NextTXShiftReg[5:0] = TXShiftReg[6:1];
            NextTXShiftReg[6]   = 1'b0;
            UartTXCntlNext      = 4'b0011;
            NextTXBUSY          = 1'b1;
          // With Baud16 as the count enable, decrement the
          // BitPeriodCnt
          end

        else if ((Baud16 & !(BitPeriodCmp)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartTXCntlNext      = 4'b0011;
            NextTXBUSY          = 1'b1;
            // All data bits transmitted, parity bit next.
          end

        else if
          ((Baud16 & BitPeriodCmp & PEN & BitCountComp) == 1'b1)
          begin
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0010;
            NextCharTxComp      = 1'b0;
            NextTXBUSY          = 1'b1;
            if ((SPS & EPS) == 1'b1)
              NextTXDReg = 1'b0;
            else if ((SPS & !(EPS)) == 1'b1)
              NextTXDReg = 1'b1;
            else
              NextTXDReg = Parity;
            // All data bits transmitted. No parity bit
            // programmed, but extra stop bit required.
          end
        else if
          ((Baud16 & BitPeriodCmp & BitCountComp & !(PEN) &
            STP2 ) == 1'b1)
          begin
            NextTXDReg          = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0110;
            NextCharTxComp      = 1'b1;
            NextTXBUSY          = 1'b1;
            // All data bits transmitted. No parity bit
            // programmed, one stop bit programmed.
          end

        else if
          ((Baud16 & BitPeriodCmp & BitCountComp & !(PEN) &
            !(STP2) ) == 1'b1)
          begin
            NextTXDReg          = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0111;
            NextCharTxComp      = 1'b1;
            NextTXFRdPtrInc     = 1'b1;
            NextTXBUSY          = 1'b1;
          end
        else
          NextTXBUSY = 1'b1;

       end
      4'b0010 :
        begin
        // 2 stop bits programmed, so transmit additional stop bit first

        if ((Baud16 & BitPeriodCmp & STP2 ) == 1'b1)
          begin
            NextTXDReg          = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0110;
            NextCharTxComp      = 1'b1;
            NextTXBUSY          = 1'b1;
          end

        else if ((Baud16 & !(BitPeriodCmp)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartTXCntlNext      = 4'b0010;
            NextTXBUSY          = 1'b1;
          // Only one stop bit
          end

        else if ((Baud16 & BitPeriodCmp & !(STP2))
                 == 1'b1)
          begin
            NextTXDReg          = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0111;
            NextCharTxComp      = 1'b1;
            NextTXFRdPtrInc     = 1'b1;
            NextTXBUSY          = 1'b1;
          end
        else
          NextTXBUSY = 1'b1;

       end
      4'b0110 :
        begin

        if ((Baud16 & !(BitPeriodCmp)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartTXCntlNext      = 4'b0110;
            NextTXBUSY          = 1'b1;
          // One stop bit shifted out, now move to the stop state to
          // shift out the next stop bit
          end

        else if ((Baud16 & BitPeriodCmp ) == 1'b1)
          begin
            NextTXDReg          = 1'b1;
            NextBitPeriodCnt    = 4'b1111;
            UartTXCntlNext      = 4'b0111;
            NextCharTxComp      = 1'b1;
            NextTXFRdPtrInc     = 1'b1;
            NextTXBUSY          = 1'b1;
          end
        else
          NextTXBUSY = 1'b1;

       end
      4'b0111 :
        begin
        //  If the FIFO has completed the write and there is no more
        //  data available to be transmitted, then wait for transmit
        //  data

        if ((((AbortTransmit & BitPeriodCmp & Baud16) |
              (BitPeriodCmp & Baud16 &
             !(TXDataAvlblSync))) & RdPtrIncDoneSync) == 1'b1)
          begin
            NextTXDReg          = nBreak;
            NextBitCount        = 3'b000;
            NextBitPeriodCnt    = 4'b1111;
            NextTXShiftReg      = 7'b0000000;
            UartTXCntlNext      = 4'b0000;
            NextCharTxComp      = 1'b1;
            NextTXFRdPtrInc     = 1'b0;
            NextTXBUSY          = 1'b0;

          // If the FIFO has completed the write and the last stop
          // bit is complete and there is more data available for
          // transmission, then if Transmit is enabled proceed with the
          // transmission of the next data, otherwise go to the idle
          // state and wait for an enable signal
          end

        else if ((!(AbortTransmit) & TXDataAvlblSync & Baud16 &
                BitPeriodCmp & RdPtrIncDoneSync) == 1'b1)
          begin
            NextBitCount[2:0] = {1'b1, WLEN[1:0]};
            NextBitPeriodCnt  = 4'b1111;
            NextCharTxComp    = 1'b1;
            NextTXBUSY        = 1'b1;
//------------------------------------------------------------------------------
            // For Flow Control need to check whether it is still okay to send
            // further data (CTSEn = '1' and nCTSSyncUARTCLK = '0'), provided
            // that TXEnable is still true
            // Otherwise normal operation resumes.
//------------------------------------------------------------------------------
            if (CTSEn == 1'b1) begin
              if ((nCTSSyncUARTCLK == 1'b0) && (TXEnable == 1'b1))
                begin
                  UartTXCntlNext      = 4'b0001;
                  NextTXDReg          = 1'b0;
                  NextCharTxComp      = 1'b0;
                end
              else
                begin
                  UartTXCntlNext      = 4'b0000;
                  NextTXDReg          = 1'b1;
                end
            end else if (TXEnable == 1'b1)
              begin
                UartTXCntlNext      = 4'b0001;
                NextTXDReg          = 1'b0;
                NextCharTxComp      = 1'b0;
              end
            else
              begin
                UartTXCntlNext      = 4'b0000;
                NextTXDReg          = 1'b1;
              end
          end

        else if ((Baud16 & !(BitPeriodCmp)) == 1'b1)
          begin
            NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
            UartTXCntlNext      = 4'b0111;
            NextTXFRdPtrInc     = 1'b1;
            NextTXBUSY          = 1'b1;
          end
        else
          begin
            NextTXFRdPtrInc = 1'b1;
            NextTXBUSY      = 1'b1;
          end
        end

      4'b0101 :
        begin
        // Transmit the start bit when the next Baud16 pulse is seen.
        // Load BitPeriodCnt with '1111' to count 16 Baud16  pulses
        // before
        // the next bit. Also clear the BitCnt counter (which indicates
        // the number of bits currently shifted out)
         if ((Baud16 & !(AbortTransmit)) == 1'b1)
           begin
             NextTXDReg          = 1'b0;
             NextBitCount[2:0]   = {1'b1, WLEN[1:0]};
             NextBitPeriodCnt    = 4'b1111;
             UartTXCntlNext      = 4'b0001;
             NextCharTxComp      = 1'b0;
             NextTXBUSY          = 1'b1;
          //  If an illegal value is written in the
          //  bit rate divisor  then pull the transmit output line HIGH.
          end

          else if ((AbortTransmit) == 1'b1)
            begin
              NextTXDReg          = nBreak;
              NextBitCount        = 3'b000;
              NextBitPeriodCnt    = 4'b1111;
              UartTXCntlNext      = 4'b0000;
              NextTXFRdPtrInc     = 1'b0;
              NextTXBUSY          = 1'b0;
            end
          else
            NextTXBUSY = 1'b1;
        end
      4'b0100 :
        begin
        // Break cleared, wait for a bit time, to avoid potential
        // glitches on nSIROUT line

         if ((!(BRK)) == 1'b1)
           begin
             NextBitPeriodCnt    = 4'b1111;
             NextTXDReg          = 1'b1;
             UartTXCntlNext      = 4'b1100;
             NextCharTxComp      = 1'b1;
           end
         else
           NextTXBUSY = 1'b1;
        end


      4'b1100 :
        begin
         if ((Baud16 & BitPeriodCmp & !(BRK)) == 1'b1)
           begin
             NextTXDReg          = 1'b1;
             NextBitCount        = 3'b000;
             NextBitPeriodCnt    = 4'b1111;
             NextTXShiftReg      = 7'b0000000;
             UartTXCntlNext      = 4'b0000;
             NextCharTxComp      = 1'b1;
             NextTXFRdPtrInc     = 1'b0;
             NextTXBUSY          = 1'b0;
           end

         else if ((Baud16 & !(BitPeriodCmp) & !(BRK)) == 1'b1)
           begin
             NextBitPeriodCnt    = BitPeriodCnt - 1'b1;
             UartTXCntlNext      = 4'b1100;
           end

        else if ((BRK) == 1'b1)
          begin
            UartTXCntlNext      = 4'b0100;
            NextTXBUSY          = 1'b1;
            NextCharTxComp      = 1'b1;   
          end
        end
      default :
        UartTXCntlNext      = 4'b0000;
    endcase
  end // combo;

always @(posedge UARTCLK or negedge nUARTRST)
begin : TXDReg_seq

  if (nUARTRST == 1'b0)
    TXDReg <= 1'b1;
  else
    TXDReg <= NextTXDReg;
end // TXDReg_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : BitCount_seq

  if (nUARTRST == 1'b0)
    BitCount <= 3'b000;
  else
    BitCount <= NextBitCount;
end // BitCount_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : BitPeriodCnt_seq

  if (nUARTRST == 1'b0)
    BitPeriodCnt <= 4'b1111;
  else
    BitPeriodCnt <= NextBitPeriodCnt;
end // BitPeriodCnt_seq;

always @(posedge UARTCLK or negedge nUARTRST)
begin : TXShiftReg_seq
  if (nUARTRST == 1'b0)
    TXShiftReg <= 7'b0000000;
  else
    TXShiftReg <= NextTXShiftReg;
end // TXShiftReg_seq;

endmodule

//  Signals: UartTXCntlState<3:0> UartTXCntlNext<3:0>
//    ST_IDLE           0000
//    ST_STARTBIT       0001
//    ST_SHIFT          0011
//    ST_PARITY         0010
//    ST_XSTOP          0110
//    ST_STPRDPTRINC    0111
//    ST_DATAAVLBL      0101
//    ST_BREAK          0100
//    ST_EXITBREAK      1100
// -============================ End of UartRXCntl ===========================--
