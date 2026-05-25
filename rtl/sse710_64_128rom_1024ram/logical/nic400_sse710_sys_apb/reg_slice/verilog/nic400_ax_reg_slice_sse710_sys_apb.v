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




`include "reg_slice_axi_defs.v"

module nic400_ax_reg_slice_sse710_sys_apb
  (
   aresetn,
   aclk,

   axids,
   axaddrs,
   axlens,
   axsizes,
   axbursts,
   axlocks,
   axcaches,
   axprots,
   axusers,
   axvalids,
   axreadys,

   axidm,
   axaddrm,
   axlenm,
   axsizem,
   axburstm,
   axlockm,
   axcachem,
   axprotm,
   axuserm,
   axvalidm,
   axreadym
   );

  parameter ID_WIDTH = 4;               
  parameter USER_WIDTH = 32;            
  parameter HNDSHK_MODE = `RS_REGD;     
  parameter ADDR_WIDTH  = 32;           
   
  parameter ID_MAX      = (ID_WIDTH - 1);
  parameter USER_MAX    = (USER_WIDTH-1);
  parameter PAYLD_WIDTH = (ID_WIDTH + USER_WIDTH + ADDR_WIDTH + 18);
  parameter PAYLD_MAX   = (PAYLD_WIDTH - 1);
  parameter ADDR_MAX    = (ADDR_WIDTH - 1);
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  input                 aresetn;          
  input                 aclk;             

  input [ID_MAX:0]      axids;            
  input [ADDR_MAX:0]    axaddrs;          
  input [3:0]           axlens;           
  input [2:0]           axsizes;          
  input [1:0]           axbursts;         
  input [1:0]           axlocks;          
  input [3:0]           axcaches;         
  input [2:0]           axprots;          
  input [USER_MAX:0]    axusers;          
  input                 axvalids;         
  output                axreadys;         

  output [ID_MAX:0]     axidm;            
  output [ADDR_MAX:0]   axaddrm;          
  output [3:0]          axlenm;           
  output [2:0]          axsizem;          
  output [1:0]          axburstm;         
  output [1:0]          axlockm;          
  output [3:0]          axcachem;         
  output [2:0]          axprotm;          
  output [USER_MAX:0]   axuserm;          
  output                axvalidm;         
  input                 axreadym;         

  wire                  aresetn;          
  wire                  aclk;             

  wire [ID_MAX:0]       axids;            
  wire [ADDR_MAX:0]     axaddrs;          
  wire [3:0]            axlens;           
  wire [2:0]            axsizes;          
  wire [1:0]            axbursts;         
  wire [1:0]            axlocks;          
  wire [3:0]            axcaches;         
  wire [2:0]            axprots;          
  wire [USER_MAX:0]     axusers;          
  wire                  axvalids;         
  wire                  axreadys;         

  wire [ID_MAX:0]       axidm;            
  wire [ADDR_MAX:0]     axaddrm;          
  wire [3:0]            axlenm;           
  wire [2:0]            axsizem;          
  wire [1:0]            axburstm;         
  wire [1:0]            axlockm;          
  wire [3:0]            axcachem;         
  wire [2:0]            axprotm;          
  wire [USER_MAX:0]     axuserm;          
  wire                  axvalidm;         
  wire                  axreadym;         

  wire [PAYLD_MAX:0]    payld_src;      
  wire [PAYLD_MAX:0]    payld_regd;     
  wire [PAYLD_MAX:0]    payld_fwd_regd;  
  wire [PAYLD_MAX:0]    payld_rev_regd;  
  wire                  ax_valid_regd;   
  wire                  ax_valid_fwd_regd;
  wire                  ax_valid_rev_regd;
  wire                  ax_ready_regd;   
  wire                  ax_ready_fwd_regd;
  wire                  ax_ready_rev_regd;



  assign axreadys = ((INT_HNDSHK_MODE == `RS_REGD)        ? ax_ready_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? ax_ready_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? ax_ready_rev_regd
                         : axreadym)));

  assign {axidm,
          axaddrm,
          axlenm,
          axsizem,
          axburstm,
          axlockm,
          axcachem,
          axprotm,
          axuserm} = ((INT_HNDSHK_MODE == `RS_REGD)        ? payld_regd
                      :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? payld_fwd_regd
                        :((INT_HNDSHK_MODE == `RS_REV_REG) ? payld_rev_regd
                          : {axids,
                             axaddrs,
                             axlens,
                             axsizes,
                             axbursts,
                             axlocks,
                             axcaches,
                             axprots,
                             axusers})));

  assign axvalidm = ((INT_HNDSHK_MODE == `RS_REGD)        ? ax_valid_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? ax_valid_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? ax_valid_rev_regd
                         : axvalids)));

  assign payld_src = {axids,
                     axaddrs,
                     axlens,
                     axsizes,
                     axbursts,
                     axlocks,
                     axcaches,
                     axprots,
                     axusers};

  nic400_ful_regd_slice_sse710_sys_apb #(PAYLD_WIDTH) u_ful_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (axvalids),
     .ready_dst       (axreadym),
     .payload_src     (payld_src),

     .ready_src       (ax_ready_regd),
     .valid_dst       (ax_valid_regd),
     .payload_dst     (payld_regd)
     );

  nic400_fwd_regd_slice_sse710_sys_apb #(PAYLD_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (axvalids),
     .ready_dst       (axreadym),
     .payload_src     (payld_src),

     .ready_src       (ax_ready_fwd_regd),
     .valid_dst       (ax_valid_fwd_regd),
     .payload_dst     (payld_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_sys_apb #(PAYLD_WIDTH) u_rev_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (axvalids),
     .ready_dst       (axreadym),
     .payload_src     (payld_src),

     .ready_src       (ax_ready_rev_regd),
     .valid_dst       (ax_valid_rev_regd),
     .payload_dst     (payld_rev_regd)
     );

endmodule

`include "reg_slice_axi_undefs.v"


