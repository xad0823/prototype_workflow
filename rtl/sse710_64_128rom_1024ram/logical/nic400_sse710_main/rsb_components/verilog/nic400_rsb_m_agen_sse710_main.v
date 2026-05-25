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

module nic400_rsb_m_agen_sse710_main
  (
   reg_addr,
   reg_len,
   reg_size,
   reg_burst,
   reg_addr_incr
   );

  input            [11:0] reg_addr;       
  input             [3:0] reg_len;        
  input             [2:0] reg_size;       
  input             [1:0] reg_burst;      

  output           [11:0] reg_addr_incr;      

  wire             [11:0] reg_addr;
  wire              [3:0] reg_len;
  wire              [2:0] reg_size;
  wire              [1:0] reg_burst;
  wire             [11:0] reg_addr_incr;


  reg [11:0]              offset_addr; 
  wire [11:0]             incr_addr;   
  wire [11:0]             wrap_addr;   
  reg [11:0]              calc_addr;   
  wire             [11:0] mux_addr;




  always @ (reg_size or reg_addr)
  begin : p_offset_addr
    case (reg_size)
      `AXI_ASIZE_8  : offset_addr = reg_addr[11:0];
      `AXI_ASIZE_16 : offset_addr = { 1'b0 ,  reg_addr[11:1] };
      `AXI_ASIZE_32 : offset_addr = { 2'b00,  reg_addr[11:2] };

      `AXI_ASIZE_64,
        `AXI_ASIZE_128,
        `AXI_ASIZE_256,
        `AXI_ASIZE_512,
        `AXI_ASIZE_1024 : offset_addr = reg_addr[11:0];

      default       : offset_addr = {12{1'bx}};
    endcase
  end

  assign incr_addr = offset_addr + 1'b1;


  assign wrap_addr[11:4] = offset_addr[11:4];

  assign wrap_addr[3:0]  = (reg_len & incr_addr[3:0]) | (~reg_len & offset_addr[3:0]);



  assign mux_addr = (reg_burst == `AXI_ABURST_WRAP) ? wrap_addr : incr_addr;
  

  always @ (reg_size or mux_addr)
  begin : p_calc_addr
    case (reg_size)
      `AXI_ASIZE_8  : calc_addr = mux_addr;
      `AXI_ASIZE_16 : calc_addr = {mux_addr [10:0],1'b0 };
      `AXI_ASIZE_32 : calc_addr = {mux_addr [ 9:0],2'b00};

      `AXI_ASIZE_64,
        `AXI_ASIZE_128,
        `AXI_ASIZE_256,
        `AXI_ASIZE_512,
        `AXI_ASIZE_1024 : calc_addr = mux_addr;

      default       : calc_addr = {12{1'bx}}; 
    endcase
  end

  assign reg_addr_incr = (reg_burst == `AXI_ABURST_FIXED) ? reg_addr : calc_addr;


endmodule 


`include "Axi_undefs.v"

