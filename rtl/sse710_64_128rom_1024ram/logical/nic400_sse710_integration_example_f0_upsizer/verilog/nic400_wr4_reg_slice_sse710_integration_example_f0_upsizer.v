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

module nic400_wr4_reg_slice_sse710_integration_example_f0_upsizer
  (
   aresetn,
   aclk,

   wdatas,
   wstrbs,
   wusers,
   wlasts,
   wvalids,
   wreadys,

   wdatam,
   wstrbm,
   wuserm,
   wlastm,
   wvalidm,
   wreadym
   );

  parameter DATA_WIDTH  = 64;           
  parameter USER_WIDTH  = 32;           
  parameter HNDSHK_MODE = `RS_REGD;     

  parameter DATA_MAX      = (DATA_WIDTH - 1);
  parameter STRB_WIDTH    = (DATA_WIDTH / 8);
  parameter STRB_MAX      = (STRB_WIDTH - 1);
  parameter USER_MAX      = (USER_WIDTH - 1);
  parameter PAYLD_WIDTH = (DATA_WIDTH + STRB_WIDTH + USER_WIDTH + 1);
  parameter PAYLD_MAX   = (PAYLD_WIDTH - 1);
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  input                 aresetn;          
  input                 aclk;             

  input [DATA_MAX:0]    wdatas;           
  input [STRB_MAX:0]    wstrbs;           
  input [USER_MAX:0]    wusers;           
  input                 wlasts;           
  input                 wvalids;          
  output                wreadys;          

  output [DATA_MAX:0]   wdatam;           
  output [STRB_MAX:0]   wstrbm;           
  output [USER_MAX:0]   wuserm;           
  output                wlastm;           
  output                wvalidm;          
  input                 wreadym;          

  wire                  aresetn;          
  wire                  aclk;             

  wire [DATA_MAX:0]     wdatas;           
  wire [STRB_MAX:0]     wstrbs;           
  wire [USER_MAX:0]     wusers;           
  wire                  wlasts;           
  wire                  wvalids;          
  wire                  wreadys;          

  wire [DATA_MAX:0]     wdatam;           
  wire [STRB_MAX:0]     wstrbm;           
  wire [USER_MAX:0]     wuserm;           
  wire                  wlastm;           
  wire                  wvalidm;          
  wire                  wreadym;          

  wire [PAYLD_MAX:0]    payld_src;      
  wire [PAYLD_MAX:0]    payld_regd;     
  wire [PAYLD_MAX:0]    payld_fwd_regd;  
  wire [PAYLD_MAX:0]    payld_rev_regd;  
  wire                  wvalid_regd;    
  wire                  wvalid_fwd_regd; 
  wire                  wvalid_rev_regd; 
  wire                  wready_regd;    
  wire                  wready_fwd_regd; 
  wire                  wready_rev_regd; 


  assign wreadys = ((INT_HNDSHK_MODE == `RS_REGD)        ? wready_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? wready_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? wready_rev_regd
                        : wreadym)));

  assign {wdatam,
          wstrbm,
          wuserm,
          wlastm} = ((INT_HNDSHK_MODE == `RS_REGD)        ? payld_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? payld_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? payld_rev_regd
                         : {wdatas,
                            wstrbs,
                            wusers,
                            wlasts})));

  assign wvalidm = ((INT_HNDSHK_MODE == `RS_REGD)        ? wvalid_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? wvalid_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? wvalid_rev_regd
                        : wvalids)));

  assign payld_src = {wdatas,
                     wstrbs,
                     wusers,
                     wlasts};

  nic400_ful_regd_slice_sse710_integration_example_f0_upsizer #(PAYLD_WIDTH) u_ful_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (wvalids),
     .ready_dst       (wreadym),
     .payload_src     (payld_src),

     .ready_src       (wready_regd),
     .valid_dst       (wvalid_regd),
     .payload_dst     (payld_regd)
     );

  nic400_fwd_regd_slice_sse710_integration_example_f0_upsizer #(PAYLD_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (wvalids),
     .ready_dst       (wreadym),
     .payload_src     (payld_src),

     .ready_src       (wready_fwd_regd),
     .valid_dst       (wvalid_fwd_regd),
     .payload_dst     (payld_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_integration_example_f0_upsizer #(PAYLD_WIDTH) u_rev_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (wvalids),
     .ready_dst       (wreadym),
     .payload_src     (payld_src),

     .ready_src       (wready_rev_regd),
     .valid_dst       (wvalid_rev_regd),
     .payload_dst     (payld_rev_regd)
     );

endmodule

`include "reg_slice_axi_undefs.v"


