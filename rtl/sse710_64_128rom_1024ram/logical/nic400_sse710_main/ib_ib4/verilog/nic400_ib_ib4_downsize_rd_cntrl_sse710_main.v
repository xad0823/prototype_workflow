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


`include "nic400_ib_ib4_defs_sse710_main.v"
`include "Axi.v"

module nic400_ib_ib4_downsize_rd_cntrl_sse710_main
  (
    rvalid_s,
    rlast_s,
    
    rready_m,
    
    aclk, 
    aresetn,
    
    rready_s,
    
    rbeats,
    rvalid_m,
    rlast_m
    
  );



  input           aclk;
  input           aresetn;
  
  input [1:0]     rbeats;
  
  input           rready_s;
  input           rvalid_m;
  
  input           rlast_m;
    
  output          rvalid_s;
  output          rready_m;
  
  output          rlast_s;
 
          
  
  wire            rbeat_reg_wr_en;
  wire [1:0]      next_rbeat_reg;
  wire [1:0]      rbeat_in;  

  wire            busy_reg_wr_en;
  wire            busy_reg_next;
  wire            rready_m_i;
     
  reg  [1:0]      rbeat_reg;

  reg             busy_reg;



  
  assign rvalid_s = rvalid_m;
  
  assign busy_reg_wr_en = (rvalid_m & (rready_s || rready_m_i));
  
  assign busy_reg_next = (rvalid_m & rready_m_i) ? 1'b0 : 
                         (((rvalid_m & rready_s) & (|rbeats)) ? 1'b1 : busy_reg);
  
  always @(posedge aclk or negedge aresetn)
   begin : beat_reg_seq
     if (!aresetn) 
         busy_reg <= 1'b0;
     else if (busy_reg_wr_en)
         busy_reg <= busy_reg_next;
   end 
                       
                         
  
  assign rbeat_in = |rbeats ? (rbeats - {{1{1'b0}},1'b1}) : 
                                          {2{1'b0}};

  assign next_rbeat_reg = ((busy_reg_next) & (~|rbeat_reg)) ? rbeat_in : 
                          (((busy_reg_next) & (rvalid_m & rready_s)) ? (rbeat_reg - {{1{1'b0}},1'b1}) : (rbeat_reg));

  assign rbeat_reg_wr_en =  (rvalid_m & rready_s);

  always @(posedge aclk or negedge aresetn)
   begin : rbeat_reg_seq
     if (!aresetn) 
         rbeat_reg <= 2'b0;
     else if (rbeat_reg_wr_en)
         rbeat_reg <= next_rbeat_reg;
   end 
   
  assign rready_m_i = rready_s & ((~|rbeats) || (busy_reg & (~|rbeat_reg)));
  assign rready_m   = rready_m_i;
  assign rlast_s = rlast_m & ((~|rbeats) || (busy_reg & (~|rbeat_reg)));   


endmodule

`include "nic400_ib_ib4_undefs_sse710_main.v"
`include "Axi_undefs.v"

