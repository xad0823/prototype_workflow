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
//  File Name              : UartTXRegFile.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the Register File for the
//               Transmit FIFO
// --=========================================================================--

`timescale 1ns/1ps

module UartTXRegFile (
                      PCLK,
                      PRESETn,
                      RegFileWrEn,
                      WrPtr,
                      RdPtr,
                      PWDATAIn,
                      iTXFIFOData
                     );

input          PCLK;           // APB Clock
input          PRESETn;        // APB Bus Reset
input          RegFileWrEn;    // Write Enable
input [4:0]    WrPtr;          // Write Pointer
input [4:0]    RdPtr;          // Read Pointer
input [7:0]    PWDATAIn;       // Data bus

output [7:0]   iTXFIFOData;    // Read data
//
//------------------------------------------------------------------------------
//
//                   UartTXRegFile
//                   =============
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
//  This block contains an array of flipflops that serve as the storage
//  register file for the transmit FIFO.
//
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// wire declaration
//------------------------------------------------------------------------------
wire          PCLK;
// APB Clock                                              (Module Input)

wire          PRESETn;
// APB Bus Reset					  (Module Input)

wire          RegFileWrEn;
// Write Enable                                           (Module Input)

wire [4:0]    WrPtr;
// Write Pointer                                          (Module Input)

wire [4:0]    RdPtr;
// Read Pointer                                           (Module Input)

wire [7:0]    PWDATAIn;
// Data bus                                               (Module Input)

//------------------------------------------------------------------------------
// register declaration
//------------------------------------------------------------------------------
  reg [7:0] TXRegFile0;
// Register File-0 8-bits wide

  reg [7:0] TXRegFile1;
// Register File-1 8-bits wide

  reg [7:0] TXRegFile2;
// Register File-2 8-bits wide

  reg [7:0] TXRegFile3;
// Register File-3 8-bits wide

  reg [7:0] TXRegFile4;
// Register File-4 8-bits wide

  reg [7:0] TXRegFile5;
// Register File-5 8-bits wide

  reg [7:0] TXRegFile6;
// Register File-6 8-bits wide

  reg [7:0] TXRegFile7;
// Register File-7 8-bits wide

  reg [7:0] TXRegFile8;
// Register File-8 8-bits wide

  reg [7:0] TXRegFile9;
// Register File-9 8-bits wide

  reg [7:0] TXRegFile10;
// Register File-10 8-bits wide

  reg [7:0] TXRegFile11;
// Register File-11 8-bits wide

  reg [7:0] TXRegFile12;
// Register File-12 8-bits wide

  reg [7:0] TXRegFile13;
// Register File-13 8-bits wide

  reg [7:0] TXRegFile14;
// Register File-14 8-bits wide

  reg [7:0] TXRegFile15;
// Register File-15 8-bits wide

  reg [7:0] TXRegFile16;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile17;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile18;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile19;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile20;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile21;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile22;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile23;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile24;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile25;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile26;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile27;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile28;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile29;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile30;
// Register File-16 8-bits wide

  reg [7:0] TXRegFile31;
// Register File-16 8-bits wide

  reg [7:0] NextTXRegFile0;
// D-inputs of Register File-1 8-bits wide

  reg [7:0] NextTXRegFile1;
// D-inputs of Register File-1 8-bits wide

  reg [7:0] NextTXRegFile2;
// D-inputs of Register File-2 8-bits wide

  reg [7:0] NextTXRegFile3;
// D-inputs of Register File-3 8-bits wide

  reg [7:0] NextTXRegFile4;
// D-inputs of Register File-4 8-bits wide

  reg [7:0] NextTXRegFile5;
// D-inputs of Register File-5 8-bits wide

  reg [7:0] NextTXRegFile6;
// D-inputs of Register File-6 8-bits wide

  reg [7:0] NextTXRegFile7;
// D-inputs of Register File-7 8-bits wide

  reg [7:0] NextTXRegFile8;
// D-inputs of Register File-8 8-bits wide

  reg [7:0] NextTXRegFile9;
// D-inputs of Register File-9 8-bits wide

  reg [7:0] NextTXRegFile10;
// D-inputs of Register File-10 8-bits wide

  reg [7:0] NextTXRegFile11;
// D-inputs of Register File-11 8-bits wide

  reg [7:0] NextTXRegFile12;
// D-inputs of Register File-12 8-bits wide

  reg [7:0] NextTXRegFile13;
// D-inputs of Register File-13 8-bits wide

  reg [7:0] NextTXRegFile14;
// D-inputs of Register File-14 8-bits wide

  reg [7:0] NextTXRegFile15;
// D-inputs of Register File-15 8-bits wide

  reg [7:0] NextTXRegFile16;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile17;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile18;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile19;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile20;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile21;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile22;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile23;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile24;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile25;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile26;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile27;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile28;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile29;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile30;
// D-inputs of Register File-16 8-bits wide

  reg [7:0] NextTXRegFile31;
// D-inputs of Register File-16 8-bits wide


//------------------------------------------------------------------------------
//
// Main Verilog code
// =================
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Register array
//------------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn)
  begin : p_Seq
    if (PRESETn == 1'b0)
      begin
        TXRegFile0  <= 8'b00000000;
        TXRegFile1  <= 8'b00000000;
        TXRegFile2  <= 8'b00000000;
        TXRegFile3  <= 8'b00000000;
        TXRegFile4  <= 8'b00000000;
        TXRegFile5  <= 8'b00000000;
        TXRegFile6  <= 8'b00000000;
        TXRegFile7  <= 8'b00000000;
        TXRegFile8  <= 8'b00000000;
        TXRegFile9  <= 8'b00000000;
        TXRegFile10 <= 8'b00000000;
        TXRegFile11 <= 8'b00000000;
        TXRegFile12 <= 8'b00000000;
        TXRegFile13 <= 8'b00000000;
        TXRegFile14 <= 8'b00000000;
        TXRegFile15 <= 8'b00000000;
        TXRegFile16 <= 8'b00000000;
        TXRegFile17 <= 8'b00000000;
        TXRegFile18 <= 8'b00000000;
        TXRegFile19 <= 8'b00000000;
        TXRegFile20 <= 8'b00000000;
        TXRegFile21 <= 8'b00000000;
        TXRegFile22 <= 8'b00000000;
        TXRegFile23 <= 8'b00000000;
        TXRegFile24 <= 8'b00000000;
        TXRegFile25 <= 8'b00000000;
        TXRegFile26 <= 8'b00000000;
        TXRegFile27 <= 8'b00000000;
        TXRegFile28 <= 8'b00000000;
        TXRegFile29 <= 8'b00000000;
        TXRegFile30 <= 8'b00000000;
        TXRegFile31 <= 8'b00000000;
      end
     else
      begin
        TXRegFile0  <= NextTXRegFile0;
        TXRegFile1  <= NextTXRegFile1;
        TXRegFile2  <= NextTXRegFile2;
        TXRegFile3  <= NextTXRegFile3;
        TXRegFile4  <= NextTXRegFile4;
        TXRegFile5  <= NextTXRegFile5;
        TXRegFile6  <= NextTXRegFile6;
        TXRegFile7  <= NextTXRegFile7;
        TXRegFile8  <= NextTXRegFile8;
        TXRegFile9  <= NextTXRegFile9;
        TXRegFile10 <= NextTXRegFile10;
        TXRegFile11 <= NextTXRegFile11;
        TXRegFile12 <= NextTXRegFile12;
        TXRegFile13 <= NextTXRegFile13;
        TXRegFile14 <= NextTXRegFile14;
        TXRegFile15 <= NextTXRegFile15;
        TXRegFile16 <= NextTXRegFile16;
        TXRegFile17 <= NextTXRegFile17;
        TXRegFile18 <= NextTXRegFile18;
        TXRegFile19 <= NextTXRegFile19;
        TXRegFile20 <= NextTXRegFile20;
        TXRegFile21 <= NextTXRegFile21;
        TXRegFile22 <= NextTXRegFile22;
        TXRegFile23 <= NextTXRegFile23;
        TXRegFile24 <= NextTXRegFile24;
        TXRegFile25 <= NextTXRegFile25;
        TXRegFile26 <= NextTXRegFile26;
        TXRegFile27 <= NextTXRegFile27;
        TXRegFile28 <= NextTXRegFile28;
        TXRegFile29 <= NextTXRegFile29;
        TXRegFile30 <= NextTXRegFile30;
        TXRegFile31 <= NextTXRegFile31;
      end
end // p_Seq;

//------------------------------------------------------------------------------
// Write logic
//------------------------------------------------------------------------------

always @(TXRegFile0 or TXRegFile1 or TXRegFile2 or TXRegFile3 or
         TXRegFile4 or TXRegFile5 or TXRegFile6 or TXRegFile7 or
         TXRegFile8 or TXRegFile9 or TXRegFile10 or TXRegFile11 or
         TXRegFile12 or TXRegFile13 or TXRegFile14 or TXRegFile15 or
         TXRegFile16 or TXRegFile17 or TXRegFile18 or TXRegFile19 or
         TXRegFile20 or TXRegFile21 or TXRegFile22 or TXRegFile23 or
         TXRegFile24 or TXRegFile25 or TXRegFile26 or TXRegFile27 or
         TXRegFile28 or TXRegFile29 or TXRegFile30 or TXRegFile31 or
         RegFileWrEn or PWDATAIn or WrPtr)
begin : p_WrPtrComb
  NextTXRegFile0  = TXRegFile0;
  NextTXRegFile1  = TXRegFile1;
  NextTXRegFile2  = TXRegFile2;
  NextTXRegFile3  = TXRegFile3;
  NextTXRegFile4  = TXRegFile4;
  NextTXRegFile5  = TXRegFile5;
  NextTXRegFile6  = TXRegFile6;
  NextTXRegFile7  = TXRegFile7;
  NextTXRegFile8  = TXRegFile8;
  NextTXRegFile9  = TXRegFile9;
  NextTXRegFile10 = TXRegFile10;
  NextTXRegFile11 = TXRegFile11;
  NextTXRegFile12 = TXRegFile12;
  NextTXRegFile13 = TXRegFile13;
  NextTXRegFile14 = TXRegFile14;
  NextTXRegFile15 = TXRegFile15;
  NextTXRegFile16 = TXRegFile16;
  NextTXRegFile17 = TXRegFile17;
  NextTXRegFile18 = TXRegFile18;
  NextTXRegFile19 = TXRegFile19;
  NextTXRegFile20 = TXRegFile20;
  NextTXRegFile21 = TXRegFile21;
  NextTXRegFile22 = TXRegFile22;
  NextTXRegFile23 = TXRegFile23;
  NextTXRegFile24 = TXRegFile24;
  NextTXRegFile25 = TXRegFile25;
  NextTXRegFile26 = TXRegFile26;
  NextTXRegFile27 = TXRegFile27;
  NextTXRegFile28 = TXRegFile28;
  NextTXRegFile29 = TXRegFile29;
  NextTXRegFile30 = TXRegFile30;
  NextTXRegFile31 = TXRegFile31;

  if(RegFileWrEn == 1'b1)
    case (WrPtr)
      5'b00000 : NextTXRegFile0  = PWDATAIn;
      5'b00001 : NextTXRegFile1  = PWDATAIn;
      5'b00010 : NextTXRegFile2  = PWDATAIn;
      5'b00011 : NextTXRegFile3  = PWDATAIn;
      5'b00100 : NextTXRegFile4  = PWDATAIn;
      5'b00101 : NextTXRegFile5  = PWDATAIn;
      5'b00110 : NextTXRegFile6  = PWDATAIn;
      5'b00111 : NextTXRegFile7  = PWDATAIn;
      5'b01000 : NextTXRegFile8  = PWDATAIn;
      5'b01001 : NextTXRegFile9  = PWDATAIn;
      5'b01010 : NextTXRegFile10 = PWDATAIn;
      5'b01011 : NextTXRegFile11 = PWDATAIn;
      5'b01100 : NextTXRegFile12 = PWDATAIn;
      5'b01101 : NextTXRegFile13 = PWDATAIn;
      5'b01110 : NextTXRegFile14 = PWDATAIn;
      5'b01111 : NextTXRegFile15 = PWDATAIn;
      5'b10000 : NextTXRegFile16 = PWDATAIn;
      5'b10001 : NextTXRegFile17 = PWDATAIn;
      5'b10010 : NextTXRegFile18 = PWDATAIn;
      5'b10011 : NextTXRegFile19 = PWDATAIn;
      5'b10100 : NextTXRegFile20 = PWDATAIn;
      5'b10101 : NextTXRegFile21 = PWDATAIn;
      5'b10110 : NextTXRegFile22 = PWDATAIn;
      5'b10111 : NextTXRegFile23 = PWDATAIn;
      5'b11000 : NextTXRegFile24 = PWDATAIn;
      5'b11001 : NextTXRegFile25 = PWDATAIn;
      5'b11010 : NextTXRegFile26 = PWDATAIn;
      5'b11011 : NextTXRegFile27 = PWDATAIn;
      5'b11100 : NextTXRegFile28 = PWDATAIn;
      5'b11101 : NextTXRegFile29 = PWDATAIn;
      5'b11110 : NextTXRegFile30 = PWDATAIn;
      5'b11111 : NextTXRegFile31 = PWDATAIn;
//      default :;
    endcase
end // p_WrPtrComb;

//------------------------------------------------------------------------------
// Read Mux
//------------------------------------------------------------------------------
assign iTXFIFOData = (RdPtr == 5'b00000) ? TXRegFile0
                   : (RdPtr == 5'b00001) ? TXRegFile1
                   : (RdPtr == 5'b00010) ? TXRegFile2
                   : (RdPtr == 5'b00011) ? TXRegFile3
                   : (RdPtr == 5'b00100) ? TXRegFile4
                   : (RdPtr == 5'b00101) ? TXRegFile5
                   : (RdPtr == 5'b00110) ? TXRegFile6
                   : (RdPtr == 5'b00111) ? TXRegFile7
                   : (RdPtr == 5'b01000) ? TXRegFile8
                   : (RdPtr == 5'b01001) ? TXRegFile9
                   : (RdPtr == 5'b01010) ? TXRegFile10
                   : (RdPtr == 5'b01011) ? TXRegFile11
                   : (RdPtr == 5'b01100) ? TXRegFile12
                   : (RdPtr == 5'b01101) ? TXRegFile13
                   : (RdPtr == 5'b01110) ? TXRegFile14
                   : (RdPtr == 5'b01111) ? TXRegFile15
		   : (RdPtr == 5'b10000) ? TXRegFile16
                   : (RdPtr == 5'b10001) ? TXRegFile17
                   : (RdPtr == 5'b10010) ? TXRegFile18
                   : (RdPtr == 5'b10011) ? TXRegFile19
                   : (RdPtr == 5'b10100) ? TXRegFile20
                   : (RdPtr == 5'b10101) ? TXRegFile21
                   : (RdPtr == 5'b10110) ? TXRegFile22
                   : (RdPtr == 5'b10111) ? TXRegFile23
                   : (RdPtr == 5'b11000) ? TXRegFile24
                   : (RdPtr == 5'b11001) ? TXRegFile25
                   : (RdPtr == 5'b11010) ? TXRegFile26
                   : (RdPtr == 5'b11011) ? TXRegFile27
                   : (RdPtr == 5'b11100) ? TXRegFile28
                   : (RdPtr == 5'b11101) ? TXRegFile29
                   : (RdPtr == 5'b11110) ? TXRegFile30
                   : (RdPtr == 5'b11111) ? TXRegFile31
                   :  8'b00000000;

endmodule

// --============================ End of UartTXRegFile =======================--

