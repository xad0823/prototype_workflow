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

module arm_element_sp_ram_wstrb #(
  parameter DATA_WIDTH = 8,
  parameter MEMORY_DEPTH = 8,
  
  parameter ADDR_WIDTH = $clog2(MEMORY_DEPTH)

)(
  input   wire                          CLK, 

  input   wire  [ADDR_WIDTH-1:0]        A,
  input   wire                          CEN,
  input   wire  [DATA_WIDTH/8-1:0]      WEN,
  output  reg   [DATA_WIDTH-1:0]        Q, 
  input   wire  [DATA_WIDTH-1:0]        D
  
);

reg [DATA_WIDTH-1:0] mem [MEMORY_DEPTH-1:0];

always @(posedge CLK)
  if(!CEN)
    Q <= mem[A]; 

wire [DATA_WIDTH-1:0] mask_d;

generate
        genvar i;
        for(i = 0; i < DATA_WIDTH/8; i = i+1) begin: MEM
                assign mask_d[i*8 +: 8] = WEN[i]? mem[A][i*8 +: 8]: D[i*8 +: 8]; 
        end
endgenerate

always @(posedge CLK)
  if(!CEN && !(&WEN))
    mem[A] <= mask_d; 
        
endmodule
