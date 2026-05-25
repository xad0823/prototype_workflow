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
//  File Name              : UartIrDA.v.rca
//  File Revision          : 23277
//
//  Release Information    :  PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block is the IrDA encoder/decoder
// --=========================================================================--

`timescale 1ns/1ps

module UartIrDA(
                UARTCLK,
                nUARTRST,
                Baud16,
                IrLPBaud16,
                SIRLPSync,
                SIRENSync,
                SIRTEST,
                StopBaudCnt,
                TXBUSY,
                RXBUSY,
                TXD,
                SIRINSync,
                UARTRXDSync,
                UARTTXDint,
                RXD,
                LoadValue,
                LPLoadValue,
                nSIROUTint
               );

input        UARTCLK;       // Main UART Clock
input        nUARTRST;      // Muxed reset (from nUARTRST)
input        Baud16;        // Bit Period reference
input        IrLPBaud16;    // Low Power pulse width ref
input        SIRLPSync;     // Low power mode enable
input        SIRENSync;     // SIR Enable
input        SIRTEST;       // SIR duplex enabled
input        StopBaudCnt;   // Stop baud counter
input        TXBUSY;        // UART Transmitter busy
input        RXBUSY;        // UART Receiver busy
input        TXD;           // From UART Transmitter
input        SIRINSync;     // Sync'ed SIR serial input
input        UARTRXDSync;   // Synced serial receive input
input [15:0] LoadValue;     // Baud16 divisor value
input [ 7:0] LPLoadValue;   // LPBaud16 divisor value    

output        UARTTXDint;   // Made inactive if SIR enabled
output        RXD;          // Decoded signal to UART Receiver
output        nSIROUTint;   // SIR Encoded transmit bit stream

//------------------------------------------------------------------------------
//
//                     UartIrDA
//                     ========
//
//------------------------------------------------------------------------------
// Overview
// ========
//  This block contains the encoder and decoder required to encode
// and decode the bit stream into a stream compatible with IrDA
// standards. A 1'b0 is transmitted as a pulse while a 1'b1 is
// encoded as no pulse. In the normal mode, the pulse is 3 Baud16
// periods wide. In the low-power mode, the pulse is 3 IrLPBaud16
// periods wide. Glitches on the SIRIN line are rejected by oversampling
// Both in Normal and Low-Power modes, start bits which are less than
// one period of IrLPBaud16 are rejected by the glitch rejection logic.
// IrDA is a half-duplex protocol by specification. Although this
// implementation prevents simultaneous transmission and reception in
// normal mode, software has to ensure that no transmit data is present
// in the transmit FIFO when IrDA reception is in progress. This is
// because the UART receive state machine goes to the idle state at the
// end of every byte of data and there is no way of being sure that
// there is no further data to be received.
//
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire        UARTCLK;
// Main UART Clock                                    (Module Input)

wire        nUARTRST;
// Muxed reset (from nUARTRST)                        (Module Input)

wire        Baud16;
// Bit Period reference                               (Module Input)

wire        IrLPBaud16;
// Low Power pulse width ref                          (Module Input)

wire        SIRLPSync;  
// Low power mode enable                              (Module Input)

wire        SIRENSync;  
// SIR Enable                                         (Module Input)

wire        TXBUSY;     
// UART Transmitter busy                              (Module Input)

wire        RXBUSY; 
// UART Receiver busy                                 (Module Input)

wire        SIRTEST; 
// SIR duplex enabled                                 (Module Input)

wire        TXD; 
// From UART Transmitter                              (Module Input)

wire        SIRINSync; 
// Sync'ed SIR serial input                           (Module Input)

wire        UARTRXDSync;
// Synced serial receive input                        (Module Input)

wire        StopBaudCnt;
// Stop baud counter                                  (Module Input)

wire   TCStartEn;
// Used to generate the TCStart signal

wire   IrRXBUSY;
wire   IrTXBUSY;
// Used to decide full or half duplex mode

wire Rload;
// enable signal for the counter Rcount

wire       SIRINSyncHigh;
// Reset signal for ClkCnt & Baud16Cnt

wire       SIRINStagIrDAFinal;
// SIRINSync signal sampled on baud16

wire       SIRINStagLPIrDAFinal;
// SIRINSync signal sampled on LPBaud16

wire       SIRINStagFinal;
// Muxed signal of SIRINStagIrDAFinal & SIRINStagLPIrDAFinal
//------------------------------------------------------------------------------
// Register declaration
//------------------------------------------------------------------------------
reg        UARTTXDint; 
// Made inactive if SIR enabled                       (Module Output)

reg        iRXD; 
// Decoded signal to UART Receiver                    (Module Output)

reg        nSIROUTint; 
// SIR Encoded transmit bit stream                    (Module Output)

reg        NextSIROUT;
// D-input for Sirout

reg        NmSirout;
// normal mode output

reg        NextNmSirout;
// D-input for normal mode output

reg        PdSirout;
// low power mode output

reg        NextPdSirout;
// D-input for low power mode output

reg        NextUARTTXD;
// D-input for UARTTXDint

reg        NextRXD;
// D-input for iRXD

reg        PdTCload;
// Enable reg for the counter PdTcount

reg        NextPdTCload;
// D-input for the  PdTcount reg

reg       TCStart;
// Enable reg for the counter Tcount

reg       NextTCStart;
// D-input for the Tcount signal

reg       Flag;
// Used to prevent more than one pulse in one bit time in low power mode

reg       NextFlag;
// D-input for the Flag signal

reg   [3:0] Tcount;
// Used in transmitter module to determine one bit period

reg   [3:0] Rcount;
// Used in the receiver module to determine one bit period

reg   [3:0] NextTcount;
// D-input for the counter Tcount

reg   [3:0] NextRcount;
// D-input for the counter Rcount

reg   [1:0] PdTcount;
// Used in low power mode to determine pulse width

reg   [1:0] NextPdTcount;
// D-input for the counter PdTcount

reg         SIRENSyncEoc;
// SIR enable signal for end of Character

wire        RegRload;
// Rload registered signal

reg         NextRegRload;
// D-input for iRegRload signal

reg         iRegRload;
// Delayed version of NextRegRload signal

reg         DelBaud16;
// Delayed version of Baud16

reg [15:0] ClkCnt;
// Clock count to ensure proper pulse width of SIRINSync
// on reception with respect to Baud16

reg [1:0]  Baud16Cnt;
// Baud16 count to ensure proper pulse width of SIRINSync
// on reception

reg [15:0] NextClkCnt;
// D-input for ClkCnt signal

reg [1:0]  NextBaud16Cnt;
// D-input for Baud16Cnt signal

reg        DelSIRINSync;
// Delayed version of SIRINSync signal

reg        DelSIRINStagFinal;
// Delayed version of SIRINStagFinal

reg  [7:0] LPClkCnt;
// Clock count to ensure proper pulse width of SIRINSync
// on reception with respect to LPBaud16

reg  [7:0] NextLPClkCnt;
// D-input for LPCalkCnt signal

reg  [1:0] LPBaud16Cnt;
// LPBaud16 count to ensure proper pulse width of SIRINSync
// on reception

reg  [1:0] NextLPBaud16Cnt;
// D-input for LPBaud16Cnt signal

//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Output synchronising with UARTCLK
//------------------------------------------------------------------------------
always @(posedge UARTCLK or negedge nUARTRST)
begin : p_SyncOut
  if (nUARTRST == 1'b0)
    begin
      UARTTXDint    <= 1'b1;
      nSIROUTint    <= 1'b0;
      iRXD          <= 1'b1;
    end
  else
    begin
      UARTTXDint  <= NextUARTTXD;
      nSIROUTint  <= NextSIROUT;
      iRXD        <= NextRXD;
    end
end // p_SyncOut;


always @(posedge UARTCLK or negedge nUARTRST)
begin : p_SIRENSyncEoc
  if (nUARTRST == 1'b0)
    SIRENSyncEoc <= 1'b0;
  else if (StopBaudCnt == 1'b1)
      SIRENSyncEoc <= SIRENSync;
end // p_SIRENSyncEoc;

//------------------------------------------------------------------------------
// Output module // combining normal and powerdown modes
//------------------------------------------------------------------------------
always @ (SIRENSyncEoc or SIRLPSync or PdSirout or TXD or  NmSirout)
begin : p_Out
  if (SIRENSyncEoc == 1'b0)
    begin
      NextUARTTXD  = TXD;
      NextSIROUT   = 1'b0;
    end
  else
    begin
      NextUARTTXD  = 1'b1;
      NextSIROUT   =  (((!SIRLPSync) & (NmSirout)) | ((SIRLPSync) &
                         (PdSirout)));
    end
end // p_Out;

assign TCStartEn =  ( !((Tcount == 4'b1111) && (TXD == 1'b1)));

//------------------------------------------------------------------------------
// This always @ primarily implements the transmitter counter. It is a
// 4-bit counter enabled by the Baud16 and TCStart signals. When a low
// level is detected on the TXD line, the counter is loaded with 15 and
// the TCStart bit is set. As long as this bit is set, the counter
// decrements by 1 on sampling a Baud16 pulse. At the end of the bit
// period (counter == 15), if the TXD line is sampled low, the TCStart
// bit is maintained high. The counter decrements by 1 and the whole
// always @ repeats for the next bit. If the TXD line is sampled high,
// the TCStart bit is cleared. To support half duplex mode operation,
// the TCStart bit and the counter are reset when the IrRXBUSY signal
// becomes active.
//------------------------------------------------------------------------------
always @(SIRENSyncEoc or Tcount or TCStart or TXD or Baud16 or
          IrRXBUSY or  TCStartEn)
begin : p_TransCountLoad
  NextTcount     = Tcount;
  NextTCStart    = TCStart;
  if (SIRENSyncEoc == 1'b0)
    begin
      NextTcount   = 4'b0000;
      NextTCStart  = 1'b0;
    end
  else if (IrRXBUSY == 1'b1)
    begin
      NextTcount   = 4'b0000;
      NextTCStart  = 1'b0;
    end
  else if ((TXD == 1'b0) && (TCStart == 1'b0))
    begin
      NextTcount   = 4'b1111;
      NextTCStart  = 1'b1;
    end
  else if ((TCStart == 1'b1) && (Baud16 == 1'b1))
    begin
      NextTcount   = ((Tcount) - 1'b1);
      NextTCStart  = TCStartEn;
    end
end // p_TransCountLoad;

//------------------------------------------------------------------------------
// Set the transmitter output high for 3 Baud16 periods in normal mode
//------------------------------------------------------------------------------
always @ (Tcount or SIRENSyncEoc or SIRLPSync or NmSirout)
begin : p_TransmitterOut1
  if (SIRENSyncEoc == 1'b0)
    NextNmSirout = 1'b0;
  else if ((SIRLPSync == 1'b0) &&
           ((Tcount == 4'b1010) || (Tcount == 4'b1001)
            || (Tcount == 4'b1000)))
    NextNmSirout = 1'b1;
  else if (SIRLPSync == 1'b0)
    NextNmSirout = 1'b0;
  else
    NextNmSirout = NmSirout;
end // p_TransmitterOut1;

always @ (posedge UARTCLK  or negedge nUARTRST)
begin : p_Transmitter_clk
  if (nUARTRST == 1'b0)
    begin
      Tcount        <= 4'b0000;
      NmSirout      <= 1'b0;
      TCStart       <= 1'b0;
    end
  else
     begin
        NmSirout    <= NextNmSirout;
        TCStart     <= NextTCStart;
        Tcount      <= NextTcount;
      end
  end // p_Transmitter_clk;

//------------------------------------------------------------------------------
// This always @ implements the low power section of the transmitter.
// In the low power mode, bit period timing commences when the Tcount
// counter reaches a value of 10. At this count, the PdTCload is set
// high. When the next IrLPBaud16 pulse is sampled, the PdTcount counter
// is loaded with 3. The transmitter output is driven high and
// maintained for 3 IrLPBaud16 periods. The PdTCload bit is cleared
// along with the transmitter output. Simultaneously, a Flag bit is set
// to prevent reassertion of the transmitter output within the same bit
// period, in cases where the Baud16 frequency is much lower than the
// IrLPBaud16 frequency.
//------------------------------------------------------------------------------
always @ ( SIRENSyncEoc or Tcount or SIRLPSync or PdTcount or
           IrLPBaud16 or Flag or  PdSirout or PdTCload)
begin : p_LowPtransCountLoad
  NextFlag         = Flag;
  NextPdSirout     = PdSirout;
  NextPdTcount     = PdTcount;
  NextPdTCload     = PdTCload;
  if (SIRENSyncEoc == 1'b0)
    begin
      NextPdTcount   = 2'b00;
      NextPdSirout   = 1'b0;
      NextFlag       = 1'b0;
      NextPdTCload   = 1'b0;
    end
  else if ((Tcount == 4'b1010) && (SIRLPSync == 1'b1) &&
         (PdTCload == 1'b0) && (Flag == 1'b0))
    NextPdTCload = 1'b1;
  else if ((PdTCload == 1'b1) && (IrLPBaud16 == 1'b1)
         && (PdSirout == 1'b0))
    begin
      NextPdTcount   = 2'b11;
      NextPdSirout   = 1'b1;
    end
  else if ((PdTCload == 1'b1) && (IrLPBaud16 == 1'b1)) begin
    if (PdTcount == 2'b01)
      begin
        NextPdSirout = 1'b0;
        NextFlag     = 1'b1;
        NextPdTCload = 1'b0;
      end
    else
      NextPdTcount = ((PdTcount) - 1'b1);
  end else if (Tcount == 4'b1111)
    NextFlag       = 1'b0;
end // p_LowPtransCountLoad;

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_Transmitter_2mclk
  if (nUARTRST == 1'b0)
    begin
      PdTcount      <= 2'b00;
      PdSirout      <= 1'b0;
      PdTCload      <= 1'b0;
      Flag          <= 1'b0;
    end
  else
    begin
        PdSirout    <= NextPdSirout;
        PdTcount    <= NextPdTcount;
        PdTCload    <= NextPdTCload;
        Flag        <= NextFlag;
    end
end // p_Transmitter_2mclk;

//------------------------------------------------------------------------------
// Pulse generated to detect the rising edge on SIRINSync
//------------------------------------------------------------------------------
assign SIRINSyncHigh = SIRINSync & ~DelSIRINSync; 

//------------------------------------------------------------------------------
// Below two always @ implement the glitch rejection logic in the receiver section 
// when the UART is in IrDA low power mode. Glitches of width less that 3 LPBaud16 
// periods are rejected using this method. Signals of width more that 3 LPBaud16 
// periods are considered as valid signals.
// 
// The idea behind the logic is to ensure the SIRIN stays low for a period of
// (3 LPBaud16 * LPLoadValue) uart clocks. The logic constitutes two counters viz.  
// LPClkcnt and LPBaud16Cnt. The LPClkCnt counter counts up to the LPLoadValue and the 
// LPBaud16Cnt counter counts the number of LPBaud16's. The LPClkCnt starts counting
// when SIRINSync goes low and counts till LPClkCnt reaches LPLoadValue. Once ClkCnt 
// reaches LPLoadValue, LPBaud16Cnt counter increments.  
//
// LPBaud16Cnt counter counts the number of times LPClkCnt reached LPLoadValue when 
// SIRINSync is low. Once this reaches 3 and LPClkCnt reaches the LPLoadValue then the 
// counter resets to 0. When LPLoadValue is programmed with 1, LPBaud16Cnt doesn't 
// depend on LPClkCnt value and gets incremented whenever SIRINSync is low 
// (LPClkCnt doesn't have much of the significance when LPLoadValue = 1).
//------------------------------------------------------------------------------
always @(SIRINSyncHigh or LPClkCnt or LPLoadValue or SIRINSync)
begin : p_UartLPClkCnt
  if ((SIRINSyncHigh == 1'b1))
  begin 
    NextLPClkCnt = 8'h00;
  end
  else if (LPClkCnt == LPLoadValue)
  begin 
    NextLPClkCnt = 8'h01;
  end
  else if (SIRINSync == 1'b0)
  begin
    NextLPClkCnt = LPClkCnt + 1'b1;
  end
  else
  begin
    NextLPClkCnt = LPClkCnt;
  end
end //p_UartLPClkCnt

always @(SIRINSyncHigh or LPBaud16Cnt or LPClkCnt or LPLoadValue or SIRINSync)
begin : p_LPBaud16Cnt
  if ((SIRINSyncHigh == 1'b1) || ((LPBaud16Cnt == 2'b11) && (LPClkCnt == LPLoadValue)))
  begin 
    NextLPBaud16Cnt = 2'b00;
  end
  else if ((LPClkCnt == LPLoadValue - 1'b1) && (LPLoadValue != 8'h01))
  begin
    NextLPBaud16Cnt = LPBaud16Cnt + 1'b1;
  end
  else if ((LPLoadValue == 8'h01) && (SIRINSync == 1'b0))
  begin
    NextLPBaud16Cnt = LPBaud16Cnt + 1'b1;
  end
  else
  begin
    NextLPBaud16Cnt = LPBaud16Cnt;
  end
end //p_LPBaud16Cnt

//------------------------------------------------------------------------------
//The final SIRIN while in IrDA Low Power mode
// SIRINStagLPIrDAFinal will be de asserted for a clock when SIRINSync is low for
// (LPLoadValue*3) clocks ie 3, LPBaud16Clks. 
//------------------------------------------------------------------------------
assign SIRINStagLPIrDAFinal = ~((LPBaud16Cnt == 2'b11) && (LPClkCnt == LPLoadValue)); 

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_LPCntSync
  if (nUARTRST == 1'b0)
    begin
      LPBaud16Cnt      <= 2'b00;
      LPClkCnt         <= 8'h00;
    end
  else
    begin
      LPBaud16Cnt      <= NextLPBaud16Cnt;
      LPClkCnt         <= NextLPClkCnt;
    end
end // p_LPCntSync;

//------------------------------------------------------------------------------
// Below two always @ implement the glitch rejection logic in the receiver section 
// when the UART is in IrDA normal mode. Glitches of width less that 3 Baud16 
// periods are rejected using this method. Signals of width more that 3 Baud16 
// periods are considered as valid signals.
// 
// The idea behind the logic is to ensure the SIRIN stays low for a period of
// (3 Baud16 * LoadValue) uart clocks. The logic constitutes two counters viz.  
// Clkcnt and Baud16Cnt. The ClkCnt counter counts up to the LoadValue and the 
// Baud16Cnt counter counts the number of Baud16's. The ClkCnt starts counting when
// SIRINSync goes low and counts till ClkCnt reaches LoadValue. Once ClkCnt 
// reaches LoadValue, Baud16Cnt counter increments.  
//
// Baud16Cnt counter counts the number of times ClkCnt reached LoadValue when 
// SIRINSync is low. Once this reaches 3 and ClkCnt reaches the LoadValue then the 
// counter resets to 0. When LoadValue is programmed with 1, Baud16Cnt doesn't 
// depend on ClkCnt value and gets incremented whenever SIRINSync is low 
// (ClkCnt doesn't have much of the significance when LoadValue = 1).
//------------------------------------------------------------------------------
always @(SIRINSyncHigh or ClkCnt or LoadValue or SIRINSync)
begin : p_UartClkCnt
  if ((SIRINSyncHigh == 1'b1))
  begin 
    NextClkCnt = 16'h0000;
  end
  else if (ClkCnt == LoadValue)
  begin 
    NextClkCnt = 16'h0001;
  end
  else if (SIRINSync == 1'b0)
  begin
    NextClkCnt = ClkCnt + 1'b1;
  end
  else
  begin
    NextClkCnt = ClkCnt;
  end
end //p_UartClkCnt

always @(SIRINSyncHigh or Baud16Cnt or ClkCnt or LoadValue or SIRINSync)
begin : p_Baud16Cnt
  if ((SIRINSyncHigh == 1'b1) || ((Baud16Cnt == 2'b11) && (ClkCnt == LoadValue)))
  begin 
    NextBaud16Cnt = 0;
  end
  else if ((ClkCnt == LoadValue - 1'b1) && (LoadValue != 16'h0001))
  begin
    NextBaud16Cnt = Baud16Cnt + 1'b1;
  end
  else if ((LoadValue == 16'h0001) && (SIRINSync == 1'b0))
  begin
    NextBaud16Cnt = Baud16Cnt + 1'b1;
  end
  else
  begin
    NextBaud16Cnt = Baud16Cnt;
  end
end //p_Baud16Cnt

//------------------------------------------------------------------------------
//The final SIRIN
// SIRINStagIrDAFinal will be de asserted for a clock when SIRINSync is low for
// (LoadValue*3) clocks ie 3, Baud16Clks. 
//------------------------------------------------------------------------------
assign SIRINStagIrDAFinal = ~((Baud16Cnt == 2'b11) && (ClkCnt == LoadValue)); 

always @(posedge UARTCLK or negedge nUARTRST)
begin : p_CntSync
  if (nUARTRST == 1'b0)
    begin
      Baud16Cnt      <= 2'b00;
      ClkCnt         <= 16'h0000;
      DelSIRINSync   <= 1'b1;
    end
  else
    begin
      Baud16Cnt      <= NextBaud16Cnt;
      ClkCnt         <= NextClkCnt;
      DelSIRINSync   <= SIRINSync;
    end
end // p_CntSync;

//------------------------------------------------------------------------------
// This assignment routs either SIRINStagFinal or SIRINStagIrDAFinal based on the
// IrDA mode (Low Power or Normal mode)
//------------------------------------------------------------------------------
assign SIRINStagFinal = ((SIRENSync == 1'b1) && (SIRLPSync == 1'b1)) ?
                              SIRINStagLPIrDAFinal : SIRINStagIrDAFinal;

//------------------------------------------------------------------------------
// Pulse generated to detect the falling edge on SIRINStagFinal
//------------------------------------------------------------------------------
assign Rload = (!SIRINStagFinal & DelSIRINStagFinal & SIRENSyncEoc & !IrTXBUSY); 

always @(posedge UARTCLK or negedge nUARTRST)
begin: p_iRegRload
  if (nUARTRST == 1'b0)
    iRegRload <= 1'b0;
  else
    iRegRload <= NextRegRload;
end //p_iRegRload

//------------------------------------------------------------------------------
// This process generates a signal NextRegRload which is used to detect the 
// first Baud16 pulse after SIRINStagFinal has gone low. NextRegRload is then
// assigned to RegRload which is used to load Rcount to get the decoded RXD signal
//------------------------------------------------------------------------------

always @(iRegRload or Rload or DelBaud16)
begin: p_NextRegRload
    NextRegRload = iRegRload;
    if (Rload == 1'b1)
      NextRegRload = 1'b1;
    else if(DelBaud16 == 1'b1)
      NextRegRload = 1'b0;
end //p_NextRegRload

assign RegRload = NextRegRload;

//------------------------------------------------------------------------------
// This always @ converts the valid input bit stream into a stream
// compatible with IrDA standards. The default value of SIRINStagFinal is 1.
// When a low is detected on this line, a 4 bit counter Rcount is
// loaded with a value of 16 and the RXD line is pulled low on the next
// Baud16 clock. The RXD line is held low until the counter rolls over
// from 1 to 0. To support half duplex mode of operation, the counters
// and control signals are reset on sampling the IrTXBUSY line high.
// The RXD line is also restored to its default value of high.
//------------------------------------------------------------------------------

always @ (SIRENSyncEoc or Baud16 or  Rcount or RegRload or
          iRXD or IrTXBUSY or UARTRXDSync ) 
begin : p_Receiver
  NextRXD              = iRXD;
  NextRcount           = Rcount;
  if (SIRENSyncEoc == 1'b0)
    begin
      NextRXD          = UARTRXDSync;
      NextRcount       = 4'b0000;
    end
  else if (IrTXBUSY == 1'b1)
    begin
      NextRXD          = 1'b1;
      NextRcount       = 4'b0000;
    end
  else if (Baud16 == 1'b1) begin 
    if (RegRload == 1'b1) 
      begin
        NextRcount   = 4'b1111;
        NextRXD      = 1'b0;
      end
    else if (Rcount == 4'b0000)
      begin
        NextRcount   = 4'b0000;
        NextRXD      = 1'b1;
      end
    else
      NextRcount   = ((Rcount) - 1'b1);
  end
end // p_Receiver;

//------------------------------------------------------------------------------
// The use of the SIRTEST signal in the following two
// equations enables full duplex operation in test mode.
//------------------------------------------------------------------------------

assign  IrRXBUSY  = ( !(SIRTEST)) & (RXBUSY);
assign  IrTXBUSY  = ( !(SIRTEST)) & (TXBUSY);


always @(posedge UARTCLK or negedge nUARTRST)
begin : p_Receiver_clk
  if (nUARTRST == 1'b0)
    begin
      Rcount             <= 4'b0000;
      DelBaud16          <= 1'b0;
      DelSIRINStagFinal  <= 1'b0; 
    end
  else
    begin
      Rcount             <= NextRcount;
      DelBaud16          <= Baud16;
      DelSIRINStagFinal  <= SIRINStagFinal;
    end
end // p_Receiver_clk;

//------------------------------------------------------------------------------
// Assignment of the local copy to port
//------------------------------------------------------------------------------
assign RXD = iRXD;


endmodule

// -=========================== End of UartIrDA ==============================--

