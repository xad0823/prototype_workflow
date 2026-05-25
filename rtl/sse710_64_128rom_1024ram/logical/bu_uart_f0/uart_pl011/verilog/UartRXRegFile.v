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
//  File Name              : UartRXRegFile.v.rca
//  File Revision          : 23277
//
//  Release Information    : PL011-r1p5-00rel0
//
//------------------------------------------------------------------------------
// Purpose     : This block contains the Register File for the
//               Receive FIFO
// --=========================================================================--
`timescale 1ns/1ps

module UartRXRegFile (
                      PCLK,
                      PRESETn,
                      RegFileWrEn,
                      WrPtr,
                      RdPtr,
                      RXFIFOData,
                      RXFRdData
                     );

input         PCLK;           // APB Clock
input         PRESETn;        // APB Bus Reset
input         RegFileWrEn;    // Write Enable
input  [4:0]  WrPtr;          // Write Pointer
input  [4:0]  RdPtr;          // Read Pointer
input [11:0]  RXFIFOData;     // Write data

output [11:0] RXFRdData;      // Read data
//
//------------------------------------------------------------------------------
//
//                   UartRXRegFile
//                   =============
//
//------------------------------------------------------------------------------
//
// Overview
// ========
//
//  This block contains an array of flipflops that serve as the storage
//  register file for the receive FIFO.
//
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Wire declaration
//------------------------------------------------------------------------------
wire          PCLK;
// APB Clock                                            (Module Input)

wire          PRESETn;
// APB Bus REset                                        (Module Input)

wire          RegFileWrEn;
// Write Enable                                         (Module Input)

wire [4:0]    WrPtr;
// Write Pointer                                        (Module Input)

wire [4:0]    RdPtr;
// Read Pointer                                         (Module Input)

wire [11:0]   RXFIFOData;
// Write data                                           (Module Input)

wire [11:0]  RXFRdData;
// Read data                                            (Module Output)


//------------------------------------------------------------------------------
// register declaration
//------------------------------------------------------------------------------
  reg [11:0] RXRegFile0;
// Register File-0 12-bits wide

  reg [11:0] RXRegFile1;
// Register File-1 12-bits wide

  reg [11:0] RXRegFile2;
// Register File-2 12-bits wide

  reg [11:0] RXRegFile3;
// Register File-3 12-bits wide

  reg [11:0] RXRegFile4;
// Register File-4 12-bits wide

  reg [11:0] RXRegFile5;
// Register File-5 12-bits wide

  reg [11:0] RXRegFile6;
// Register File-6 12-bits wide

  reg [11:0] RXRegFile7;
// Register File-7 12-bits wide

  reg [11:0] RXRegFile8;
// Register File-8 12-bits wide

  reg [11:0] RXRegFile9;
// Register File-9 12-bits wide

  reg [11:0] RXRegFile10;
// Register File-10 12-bits wide

  reg [11:0] RXRegFile11;
// Register File-11 12-bits wide

  reg [11:0] RXRegFile12;
// Register File-12 12-bits wide

  reg [11:0] RXRegFile13;
// Register File-13 12-bits wide

  reg [11:0] RXRegFile14;
// Register File-14 12-bits wide

  reg [11:0] RXRegFile15;
// Register File-15 12-bits wide

  reg [11:0] RXRegFile16;
// Register File-16 12-bits wide

  reg [11:0] RXRegFile17;
// Register File-0 12-bits wide

  reg [11:0] RXRegFile18;
// Register File-1 12-bits wide

  reg [11:0] RXRegFile19;
// Register File-2 12-bits wide

  reg [11:0] RXRegFile20;
// Register File-3 12-bits wide

  reg [11:0] RXRegFile21;
// Register File-4 12-bits wide

  reg [11:0] RXRegFile22;
// Register File-5 12-bits wide

  reg [11:0] RXRegFile23;
// Register File-6 12-bits wide

  reg [11:0] RXRegFile24;
// Register File-7 12-bits wide

  reg [11:0] RXRegFile25;
// Register File-8 12-bits wide

  reg [11:0] RXRegFile26;
// Register File-9 12-bits wide

  reg [11:0] RXRegFile27;
// Register File-10 12-bits wide

  reg [11:0] RXRegFile28;
// Register File-11 12-bits wide

  reg [11:0] RXRegFile29;
// Register File-12 12-bits wide

  reg [11:0] RXRegFile30;
// Register File-13 12-bits wide

  reg [11:0] RXRegFile31;
// Register File-14 12-bits wide

  reg [11:0] NextRXRegFile0;
// D-inputs of Register File-1 12-bits wide

  reg [11:0] NextRXRegFile1;
// D-inputs of Register File-1 12-bits wide

  reg [11:0] NextRXRegFile2;
// D-inputs of Register File-2 12-bits wide

  reg [11:0] NextRXRegFile3;
// D-inputs of Register File-3 12-bits wide

  reg [11:0] NextRXRegFile4;
// D-inputs of Register File-4 12-bits wide

  reg [11:0] NextRXRegFile5;
// D-inputs of Register File-5 12-bits wide

  reg [11:0] NextRXRegFile6;
// D-inputs of Register File-6 12-bits wide

  reg [11:0] NextRXRegFile7;
// D-inputs of Register File-7 12-bits wide

  reg [11:0] NextRXRegFile8;
// D-inputs of Register File-8 12-bits wide

  reg [11:0] NextRXRegFile9;
// D-inputs of Register File-9 12-bits wide

  reg [11:0] NextRXRegFile10;
// D-inputs of Register File-10 12-bits wide

  reg [11:0] NextRXRegFile11;
// D-inputs of Register File-11 12-bits wide

  reg [11:0] NextRXRegFile12;
// D-inputs of Register File-12 12-bits wide

  reg [11:0] NextRXRegFile13;
// D-inputs of Register File-13 12-bits wide

  reg [11:0] NextRXRegFile14;
// D-inputs of Register File-14 12-bits wide

  reg [11:0] NextRXRegFile15;
// D-inputs of Register File-15 12-bits wide

  reg [11:0] NextRXRegFile16;
// D-inputs of Register File-1 12-bits wide

  reg [11:0] NextRXRegFile17;
// D-inputs of Register File-1 12-bits wide

  reg [11:0] NextRXRegFile18;
// D-inputs of Register File-2 12-bits wide

  reg [11:0] NextRXRegFile19;
// D-inputs of Register File-3 12-bits wide

  reg [11:0] NextRXRegFile20;
// D-inputs of Register File-4 12-bits wide

  reg [11:0] NextRXRegFile21;
// D-inputs of Register File-5 12-bits wide

  reg [11:0] NextRXRegFile22;
// D-inputs of Register File-6 12-bits wide

  reg [11:0] NextRXRegFile23;
// D-inputs of Register File-7 12-bits wide

  reg [11:0] NextRXRegFile24;
// D-inputs of Register File-8 12-bits wide

  reg [11:0] NextRXRegFile25;
// D-inputs of Register File-9 12-bits wide

  reg [11:0] NextRXRegFile26;
// D-inputs of Register File-10 12-bits wide

  reg [11:0] NextRXRegFile27;
// D-inputs of Register File-11 12-bits wide

  reg [11:0] NextRXRegFile28;
// D-inputs of Register File-12 12-bits wide

  reg [11:0] NextRXRegFile29;
// D-inputs of Register File-13 12-bits wide

  reg [11:0] NextRXRegFile30;
// D-inputs of Register File-14 12-bits wide

  reg [11:0] NextRXRegFile31;
// D-inputs of Register File-15 12-bits wide
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
        RXRegFile0  <= 12'b000000000000;
        RXRegFile1  <= 12'b000000000000;
        RXRegFile2  <= 12'b000000000000;
        RXRegFile3  <= 12'b000000000000;
        RXRegFile4  <= 12'b000000000000;
        RXRegFile5  <= 12'b000000000000;
        RXRegFile6  <= 12'b000000000000;
        RXRegFile7  <= 12'b000000000000;
        RXRegFile8  <= 12'b000000000000;
        RXRegFile9  <= 12'b000000000000;
        RXRegFile10 <= 12'b000000000000;
        RXRegFile11 <= 12'b000000000000;
        RXRegFile12 <= 12'b000000000000;
        RXRegFile13 <= 12'b000000000000;
        RXRegFile14 <= 12'b000000000000;
        RXRegFile15 <= 12'b000000000000;
        RXRegFile16 <= 12'b000000000000;
        RXRegFile17 <= 12'b000000000000;
        RXRegFile18 <= 12'b000000000000;
        RXRegFile19 <= 12'b000000000000;
        RXRegFile20 <= 12'b000000000000;
        RXRegFile21 <= 12'b000000000000;
        RXRegFile22 <= 12'b000000000000;
        RXRegFile23 <= 12'b000000000000;
        RXRegFile24 <= 12'b000000000000;
        RXRegFile25 <= 12'b000000000000;
        RXRegFile26 <= 12'b000000000000;
        RXRegFile27 <= 12'b000000000000;
        RXRegFile28 <= 12'b000000000000;
        RXRegFile29 <= 12'b000000000000;
        RXRegFile30 <= 12'b000000000000;
        RXRegFile31 <= 12'b000000000000;
      end
     else
      begin
        RXRegFile0  <= NextRXRegFile0;
        RXRegFile1  <= NextRXRegFile1;
        RXRegFile2  <= NextRXRegFile2;
        RXRegFile3  <= NextRXRegFile3;
        RXRegFile4  <= NextRXRegFile4;
        RXRegFile5  <= NextRXRegFile5;
        RXRegFile6  <= NextRXRegFile6;
        RXRegFile7  <= NextRXRegFile7;
        RXRegFile8  <= NextRXRegFile8;
        RXRegFile9  <= NextRXRegFile9;
        RXRegFile10 <= NextRXRegFile10;
        RXRegFile11 <= NextRXRegFile11;
        RXRegFile12 <= NextRXRegFile12;
        RXRegFile13 <= NextRXRegFile13;
        RXRegFile14 <= NextRXRegFile14;
        RXRegFile15 <= NextRXRegFile15;
        RXRegFile16 <= NextRXRegFile16;
        RXRegFile17 <= NextRXRegFile17;
        RXRegFile18 <= NextRXRegFile18;
        RXRegFile19 <= NextRXRegFile19;
        RXRegFile20 <= NextRXRegFile20;
        RXRegFile21 <= NextRXRegFile21;
        RXRegFile22 <= NextRXRegFile22;
        RXRegFile23 <= NextRXRegFile23;
        RXRegFile24 <= NextRXRegFile24;
        RXRegFile25 <= NextRXRegFile25;
        RXRegFile26 <= NextRXRegFile26;
        RXRegFile27 <= NextRXRegFile27;
        RXRegFile28 <= NextRXRegFile28;
        RXRegFile29 <= NextRXRegFile29;
        RXRegFile30 <= NextRXRegFile30;
        RXRegFile31 <= NextRXRegFile31;
      end
end // p_Seq;

//------------------------------------------------------------------------------
// Write logic
//------------------------------------------------------------------------------
always @(RXRegFile0 or RXRegFile1 or RXRegFile2 or RXRegFile3 or
         RXRegFile4 or RXRegFile5 or RXRegFile6 or RXRegFile7 or
         RXRegFile8 or RXRegFile9 or RXRegFile10 or RXRegFile11 or
         RXRegFile12 or RXRegFile13 or RXRegFile14 or RXRegFile15 or
         RXRegFile16 or RXRegFile17 or RXRegFile18 or RXRegFile19 or
         RXRegFile20 or RXRegFile21 or RXRegFile22 or RXRegFile23 or
         RXRegFile24 or RXRegFile25 or RXRegFile26 or RXRegFile27 or
         RXRegFile28 or RXRegFile29 or RXRegFile30 or RXRegFile31 or
         RegFileWrEn or RXFIFOData or WrPtr)
begin : p_WrComb
  NextRXRegFile0  = RXRegFile0;
  NextRXRegFile1  = RXRegFile1;
  NextRXRegFile2  = RXRegFile2;
  NextRXRegFile3  = RXRegFile3;
  NextRXRegFile4  = RXRegFile4;
  NextRXRegFile5  = RXRegFile5;
  NextRXRegFile6  = RXRegFile6;
  NextRXRegFile7  = RXRegFile7;
  NextRXRegFile8  = RXRegFile8;
  NextRXRegFile9  = RXRegFile9;
  NextRXRegFile10 = RXRegFile10;
  NextRXRegFile11 = RXRegFile11;
  NextRXRegFile12 = RXRegFile12;
  NextRXRegFile13 = RXRegFile13;
  NextRXRegFile14 = RXRegFile14;
  NextRXRegFile15 = RXRegFile15;
  NextRXRegFile16 = RXRegFile16;
  NextRXRegFile17 = RXRegFile17;
  NextRXRegFile18 = RXRegFile18;
  NextRXRegFile19 = RXRegFile19;
  NextRXRegFile20 = RXRegFile20;
  NextRXRegFile21 = RXRegFile21;
  NextRXRegFile22 = RXRegFile22;
  NextRXRegFile23 = RXRegFile23;
  NextRXRegFile24 = RXRegFile24;
  NextRXRegFile25 = RXRegFile25;
  NextRXRegFile26 = RXRegFile26;
  NextRXRegFile27 = RXRegFile27;
  NextRXRegFile28 = RXRegFile28;
  NextRXRegFile29 = RXRegFile29;
  NextRXRegFile30 = RXRegFile30;
  NextRXRegFile31 = RXRegFile31;

  if(RegFileWrEn == 1'b1)
    case (WrPtr)
      5'b00000 : NextRXRegFile0  = RXFIFOData;
      5'b00001 : NextRXRegFile1  = RXFIFOData;
      5'b00010 : NextRXRegFile2  = RXFIFOData;
      5'b00011 : NextRXRegFile3  = RXFIFOData;
      5'b00100 : NextRXRegFile4  = RXFIFOData;
      5'b00101 : NextRXRegFile5  = RXFIFOData;
      5'b00110 : NextRXRegFile6  = RXFIFOData;
      5'b00111 : NextRXRegFile7  = RXFIFOData;
      5'b01000 : NextRXRegFile8  = RXFIFOData;
      5'b01001 : NextRXRegFile9  = RXFIFOData;
      5'b01010 : NextRXRegFile10 = RXFIFOData;
      5'b01011 : NextRXRegFile11 = RXFIFOData;
      5'b01100 : NextRXRegFile12 = RXFIFOData;
      5'b01101 : NextRXRegFile13 = RXFIFOData;
      5'b01110 : NextRXRegFile14 = RXFIFOData;
      5'b01111 : NextRXRegFile15 = RXFIFOData;
      5'b10000 : NextRXRegFile16 = RXFIFOData;
      5'b10001 : NextRXRegFile17 = RXFIFOData;
      5'b10010 : NextRXRegFile18 = RXFIFOData;
      5'b10011 : NextRXRegFile19 = RXFIFOData;
      5'b10100 : NextRXRegFile20 = RXFIFOData;
      5'b10101 : NextRXRegFile21 = RXFIFOData;
      5'b10110 : NextRXRegFile22 = RXFIFOData;
      5'b10111 : NextRXRegFile23 = RXFIFOData;
      5'b11000 : NextRXRegFile24 = RXFIFOData;
      5'b11001 : NextRXRegFile25 = RXFIFOData;
      5'b11010 : NextRXRegFile26 = RXFIFOData;
      5'b11011 : NextRXRegFile27 = RXFIFOData;
      5'b11100 : NextRXRegFile28 = RXFIFOData;
      5'b11101 : NextRXRegFile29 = RXFIFOData;
      5'b11110 : NextRXRegFile30 = RXFIFOData;
      5'b11111 : NextRXRegFile31 = RXFIFOData;
//      default :;
    endcase
end // p_WrComb;

//------------------------------------------------------------------------------
// Read Mux
//------------------------------------------------------------------------------
assign RXFRdData =   (RdPtr == 5'b00000) ? RXRegFile0
                   : (RdPtr == 5'b00001) ? RXRegFile1
                   : (RdPtr == 5'b00010) ? RXRegFile2
                   : (RdPtr == 5'b00011) ? RXRegFile3
                   : (RdPtr == 5'b00100) ? RXRegFile4
                   : (RdPtr == 5'b00101) ? RXRegFile5
                   : (RdPtr == 5'b00110) ? RXRegFile6
                   : (RdPtr == 5'b00111) ? RXRegFile7
                   : (RdPtr == 5'b01000) ? RXRegFile8
                   : (RdPtr == 5'b01001) ? RXRegFile9
                   : (RdPtr == 5'b01010) ? RXRegFile10
                   : (RdPtr == 5'b01011) ? RXRegFile11
                   : (RdPtr == 5'b01100) ? RXRegFile12
                   : (RdPtr == 5'b01101) ? RXRegFile13
                   : (RdPtr == 5'b01110) ? RXRegFile14
                   : (RdPtr == 5'b01111) ? RXRegFile15
		   : (RdPtr == 5'b10000) ? RXRegFile16
                   : (RdPtr == 5'b10001) ? RXRegFile17
                   : (RdPtr == 5'b10010) ? RXRegFile18
                   : (RdPtr == 5'b10011) ? RXRegFile19
                   : (RdPtr == 5'b10100) ? RXRegFile20
                   : (RdPtr == 5'b10101) ? RXRegFile21
                   : (RdPtr == 5'b10110) ? RXRegFile22
                   : (RdPtr == 5'b10111) ? RXRegFile23
                   : (RdPtr == 5'b11000) ? RXRegFile24
                   : (RdPtr == 5'b11001) ? RXRegFile25
                   : (RdPtr == 5'b11010) ? RXRegFile26
                   : (RdPtr == 5'b11011) ? RXRegFile27
                   : (RdPtr == 5'b11100) ? RXRegFile28
                   : (RdPtr == 5'b11101) ? RXRegFile29
                   : (RdPtr == 5'b11110) ? RXRegFile30
                   : (RdPtr == 5'b11111) ? RXRegFile31
                   :  12'b000000000000;

endmodule

// -============================ End of UartRXRegFile ========================--

