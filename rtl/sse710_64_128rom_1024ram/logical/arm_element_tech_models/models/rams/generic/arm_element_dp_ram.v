//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module arm_element_dp_ram #(
  parameter DATA_WIDTH = 8,
  parameter MEMORY_DEPTH = 8,
  
  parameter ADDR_WIDTH = $clog2(MEMORY_DEPTH)

)(
  input   wire                          CLK, 

  input   wire  [ADDR_WIDTH-1:0]        AA,
  input   wire                          CENA,
  output  reg   [DATA_WIDTH-1:0]        QA,
 
  input   wire  [ADDR_WIDTH-1:0]        AB,   
  input   wire                          CENB, 
  input   wire  [DATA_WIDTH-1:0]        DB
  
);

reg [DATA_WIDTH-1:0] mem [MEMORY_DEPTH-1:0];

always @(posedge CLK) if(!CENA) QA <= mem[AA]; 

always @(posedge CLK) if(!CENB) mem[AB] <= DB; 
        
endmodule
