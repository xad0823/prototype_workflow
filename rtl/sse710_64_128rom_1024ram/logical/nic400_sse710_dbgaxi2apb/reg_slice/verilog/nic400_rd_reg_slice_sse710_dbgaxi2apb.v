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

module nic400_rd_reg_slice_sse710_dbgaxi2apb
  (
   aresetn,
   aclk,

   rids,
   rdatas,
   rresps,
   rusers,
   rlasts,
   rvalids,
   rreadys,

   ridm,
   rdatam,
   rrespm,
   ruserm,
   rlastm,
   rvalidm,
   rreadym
   );

  parameter ID_WIDTH    = 4;            
  parameter DATA_WIDTH  = 64;           
  parameter USER_WIDTH  = 32;           
  parameter HNDSHK_MODE = `RS_REGD;     

  parameter ID_MAX      = (ID_WIDTH - 1);
  parameter DATA_MAX    = (DATA_WIDTH - 1);
  parameter USER_MAX    = (USER_WIDTH - 1);
  parameter PAYLD_WIDTH = (ID_WIDTH + DATA_WIDTH + USER_WIDTH + 3);
  parameter PAYLD_MAX   = (PAYLD_WIDTH - 1);
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  input                 aresetn;          
  input                 aclk;             

  output [ID_MAX:0]     rids;             
  output [DATA_MAX:0]   rdatas;           
  output [1:0]          rresps;           
  output [USER_MAX:0]   rusers;           
  output                rlasts;           
  output                rvalids;          
  input                 rreadys;          

  input [ID_MAX:0]      ridm;             
  input [DATA_MAX:0]    rdatam;           
  input [1:0]           rrespm;           
  input [USER_MAX:0]    ruserm;           
  input                 rlastm;           
  input                 rvalidm;          
  output                rreadym;          

  wire                  aresetn;          
  wire                  aclk;             

  wire [ID_MAX:0]       rids;             
  wire [DATA_MAX:0]     rdatas;           
  wire [1:0]            rresps;           
  wire [USER_MAX:0]     rusers;           
  wire                  rlasts;           
  wire                  rvalids;          
  wire                  rreadys;          

  wire [ID_MAX:0]       ridm;             
  wire [DATA_MAX:0]     rdatam;           
  wire [1:0]            rrespm;           
  wire [USER_MAX:0]     ruserm;           
  wire                  rlastm;           
  wire                  rvalidm;          
  wire                  rreadym;          

  wire [PAYLD_MAX:0]    payld_src;      
  wire [PAYLD_MAX:0]    payld_regd;     
  wire [PAYLD_MAX:0]    payld_fwd_regd;  
  wire [PAYLD_MAX:0]    payld_rev_regd;  
  wire                  rvalid_regd;    
  wire                  rvalid_fwd_regd; 
  wire                  rvalid_rev_regd; 
  wire                  rready_regd;    
  wire                  rready_fwd_regd; 
  wire                  rready_rev_regd; 


  assign rvalids = ((INT_HNDSHK_MODE == `RS_REGD)        ? rvalid_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? rvalid_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? rvalid_rev_regd
                        : rvalidm)));

  assign {rids,
          rdatas,
          rresps,
          rusers,
          rlasts} = ((INT_HNDSHK_MODE == `RS_REGD)        ? payld_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? payld_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? payld_rev_regd
                         : {ridm,
                            rdatam,
                            rrespm,
                            ruserm,
                            rlastm})));

  assign rreadym = ((INT_HNDSHK_MODE == `RS_REGD)        ? rready_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? rready_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? rready_rev_regd
                        : rreadys)));

  assign payld_src = {ridm,
                     rdatam,
                     rrespm,
                     ruserm,
                     rlastm};

  nic400_ful_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_ful_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (rvalidm),
     .ready_dst       (rreadys),
     .payload_src     (payld_src),

     .ready_src       (rready_regd),
     .valid_dst       (rvalid_regd),
     .payload_dst     (payld_regd)
     );

  nic400_fwd_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (rvalidm),
     .ready_dst       (rreadys),
     .payload_src     (payld_src),

     .ready_src       (rready_fwd_regd),
     .valid_dst       (rvalid_fwd_regd),
     .payload_dst     (payld_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_rev_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (rvalidm),
     .ready_dst       (rreadys),
     .payload_src     (payld_src),

     .ready_src       (rready_rev_regd),
     .valid_dst       (rvalid_rev_regd),
     .payload_dst     (payld_rev_regd)
     );

endmodule

`include "reg_slice_axi_undefs.v"


