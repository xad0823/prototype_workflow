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


module nic400_id_regs_apb_cond_sse710_main
(
  pclk,
  presetn,
  pclken,
  psel,
  paddr,
  penable,
  pwrite,
  pwdata,
  data_out,

  prdata,
  pready,
  addr,
  enable,
  wdata_reg,
  write_reg
);



  input                 pclk;               
  input                 presetn;            
  input                 pclken;             
  input         [11:2]  paddr;              
  input                 psel;               
  input                 penable;            
  input                 pwrite;             
  input         [31:0]  pwdata;             
  input         [31:0]  data_out;           

  output        [31:0]  prdata;             
  output                pready;             
  output        [11:2]  addr;               
  output                enable;             
  output        [31:0]  wdata_reg;          
  output                write_reg;          



  wire                  pclk;               
  wire                  presetn;            
  wire                  pclken;             
  wire          [11:2]  paddr;              
  wire                  psel;               
  wire                  penable;            
  wire                  pwrite;             
  wire          [31:0]  pwdata;             
  wire          [31:0]  data_out;           



  wire                  next_first_penable; 
  wire                  next_pready;        
  wire                  apb_enable;         



  reg           [31:0]  prdata;             
  reg                   pready;             
  reg           [11:2]  addr;               
  reg                   enable;             
  reg                   write_reg;          
  reg           [31:0]  wdata_reg;          



  assign apb_enable = pclken & psel;

  always @ (posedge pclk or negedge presetn)
  begin : p_reg_apb_io_seq
    if (!presetn) begin
      addr      <= {10{1'b0}};
      write_reg <= 1'b0;
      wdata_reg <= {32{1'b0}};
      prdata    <= {32{1'b0}};
      pready    <= 1'b0;
    end else if (apb_enable) begin
      addr      <= paddr;
      write_reg <= pwrite;
      wdata_reg <= pwdata;
      prdata    <= data_out;
      pready    <= next_pready;
    end
  end 

  assign next_first_penable = psel & ~penable;
  assign next_pready        = ~next_first_penable;

  always @ (posedge pclk or negedge presetn)
  begin : p_reg_psel_seq
    if (!presetn) begin
      enable <= 1'b0;
    end else if (pclken) begin
      enable <= psel;
    end
  end 


endmodule 

