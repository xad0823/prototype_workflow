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


module nic400_id_regs_sse710_main
(
  
    paddr,
    pwdata,
    pwrite,
    penable,
    psel,
    prdata,
    pslverr,
    pready,

    pclk,
    presetn

); 


  
  input   [31:0]      paddr;        
  input   [31:0]      pwdata;       
  input               pwrite;       
  input               penable;      
  input               psel;         
  output  [31:0]      prdata;       
  output              pslverr;      
  output              pready;       

  input               pclk;         
  input               presetn;      

  wire                  pclken;             



  wire           [3:0]  rev_ands;           
  wire           [3:0]  tie_off1;           
  wire           [3:0]  tie_off2;           



  assign pclken = 1'b1;
    
  nic400_id_regs_apb_sse710_main
  u_id_regs_apb
  (
    .pclk                             (pclk),
    .pclken                           (pclken),
    .presetn                          (presetn),
    .paddr                            (paddr),
    .psel                             (psel),
    .penable                          (penable),
    .pwrite                           (pwrite),
    .pwdata                           (pwdata),
    .rev_ands                         (rev_ands),

    .pready                           (pready),
    .prdata                           (prdata),
    .pslverr                          (pslverr)
  ); 

  nic400_id_regs_rev_and_sse710_main
  u_rev_and_bit0
  (
    .tie_off1                         (tie_off1[0]),
    .tie_off2                         (tie_off2[0]),

    .revision                         (rev_ands[0])
  ); 

  nic400_id_regs_rev_and_sse710_main
  u_rev_and_bit1
  (
    .tie_off1                         (tie_off1[1]),
    .tie_off2                         (tie_off2[1]),

    .revision                         (rev_ands[1])
  ); 

  nic400_id_regs_rev_and_sse710_main
  u_rev_and_bit2
  (
    .tie_off1                         (tie_off1[2]),
    .tie_off2                         (tie_off2[2]),

    .revision                         (rev_ands[2])
  ); 

  nic400_id_regs_rev_and_sse710_main
  u_rev_and_bit3
  (
    .tie_off1                         (tie_off1[3]),
    .tie_off2                         (tie_off2[3]),

    .revision                         (rev_ands[3])
  ); 

  assign tie_off1 = 4'b0000;
  assign tie_off2 = 4'b0000;

endmodule 


