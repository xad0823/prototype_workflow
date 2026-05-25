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



`include "Axi.v"


module nic400_amib_slave_8_a_gen_sse710_sys_apb
(
  addr_in,
  alen,
  asize,
  aburst,
  addr_out
);



  parameter ADDR_WIDTH = 12;                

  localparam ADDR_MSB   = (ADDR_WIDTH-1);    
  localparam ADDR_WM2   = (ADDR_WIDTH-2);    
  localparam ADDR_WM3   = (ADDR_WIDTH-3);    
  localparam ADDR_WM4   = (ADDR_WIDTH-4);    
  localparam ADDR_WM5   = (ADDR_WIDTH-5);    
  localparam ADDR_WM6   = (ADDR_WIDTH-6);    



  input   [ADDR_MSB:0]  addr_in;            
  input          [3:0]  alen;               
  input          [2:0]  asize;              
  input          [1:0]  aburst;             

  output  [ADDR_MSB:0]  addr_out;           

  wire    [ADDR_MSB:0]  addr_in;            
  wire           [3:0]  alen;               
  wire           [2:0]  asize;              
  wire           [1:0]  aburst;             
  wire    [ADDR_MSB:0]  addr_out;           



  reg     [ADDR_MSB:0]  offset_addr;        
  wire    [ADDR_MSB:0]  incr_addr;          
  wire    [ADDR_MSB:0]  wrap_addr;          
  wire    [ADDR_MSB:0]  mux_addr;           
  reg     [ADDR_MSB:0]  calc_addr;          



  always @* 
  begin : p_offset_addr_comb
    case (asize)
      `AXI_ASIZE_8    : offset_addr = addr_in[ADDR_MSB:0];
      `AXI_ASIZE_16   : offset_addr = {1'b0,     addr_in[ADDR_MSB:1]};
      `AXI_ASIZE_32   : offset_addr = {2'b00,    addr_in[ADDR_MSB:2]};
      `AXI_ASIZE_64   : offset_addr = {3'b000,   addr_in[ADDR_MSB:3]};
      `AXI_ASIZE_128  : offset_addr = {4'b0000,  addr_in[ADDR_MSB:4]};
      `AXI_ASIZE_256  : offset_addr = {5'b00000, addr_in[ADDR_MSB:5]};
      `AXI_ASIZE_512  : offset_addr = addr_in[ADDR_MSB:0];  
      `AXI_ASIZE_1024 : offset_addr = addr_in[ADDR_MSB:0];  
      default         : offset_addr = {ADDR_WIDTH{1'bx}};
    endcase
  end 

  assign incr_addr = offset_addr + 1'b1;


  assign wrap_addr[ADDR_MSB:4] = offset_addr[ADDR_MSB:4];

  assign wrap_addr[3:0] = ( alen &   incr_addr[3:0]) |
                          (~alen & offset_addr[3:0]);



  assign mux_addr = (aburst == `AXI_ABURST_WRAP) ? wrap_addr : incr_addr;


  always @* 
  begin : p_calc_addr_comb
    case (asize)
      `AXI_ASIZE_8    : calc_addr =  mux_addr[ADDR_MSB:0];
      `AXI_ASIZE_16   : calc_addr = {mux_addr[ADDR_WM2:0], 1'b0};
      `AXI_ASIZE_32   : calc_addr = {mux_addr[ADDR_WM3:0], 2'b00};
      `AXI_ASIZE_64   : calc_addr = {mux_addr[ADDR_WM4:0], 3'b000};
      `AXI_ASIZE_128  : calc_addr = {mux_addr[ADDR_WM5:0], 4'b0000};
      `AXI_ASIZE_256  : calc_addr = {mux_addr[ADDR_WM6:0], 5'b00000};
      `AXI_ASIZE_512  : calc_addr =  mux_addr[ADDR_MSB:0];  
      `AXI_ASIZE_1024 : calc_addr =  mux_addr[ADDR_MSB:0];  
      default         : calc_addr = {ADDR_WIDTH{1'bx}};
    endcase
  end 

  assign addr_out = (aburst == `AXI_ABURST_FIXED) ? addr_in : calc_addr;


endmodule 


`include "Axi_undefs.v"



