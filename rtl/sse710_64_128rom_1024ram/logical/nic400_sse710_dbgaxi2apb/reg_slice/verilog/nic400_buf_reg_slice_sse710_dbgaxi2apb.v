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

module nic400_buf_reg_slice_sse710_dbgaxi2apb
  (
   aresetn,
   aclk,

   bids,
   bresps,
   busers,
   bvalids,
   breadys,

   bidm,
   brespm,
   buserm,
   bvalidm,
   breadym
   );

  parameter ID_WIDTH    = 4;            
  parameter USER_WIDTH  = 32;           
  parameter HNDSHK_MODE = `RS_REGD;     

  parameter ID_MAX      = (ID_WIDTH - 1);
  parameter USER_MAX    = (USER_WIDTH - 1);
  parameter PAYLD_WIDTH = (ID_WIDTH + USER_WIDTH + 2);
  parameter PAYLD_MAX   = (PAYLD_WIDTH - 1);
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  input                 aresetn;          
  input                 aclk;             

  output [ID_MAX:0]     bids;             
  output [1:0]          bresps;           
  output [USER_MAX:0]   busers;           
  output                bvalids;          
  input                 breadys;          

  input [ID_MAX:0]      bidm;             
  input [1:0]           brespm;           
  input [USER_MAX:0]    buserm;           
  input                 bvalidm;          
  output                breadym;          

  wire                  aresetn;          
  wire                  aclk;             

  wire [ID_MAX:0]       bids;             
  wire [1:0]            bresps;           
  wire [USER_MAX:0]     busers;           
  wire                  bvalids;          
  wire                  breadys;          

  wire [ID_MAX:0]       bidm;             
  wire [1:0]            brespm;           
  wire [USER_MAX:0]     buserm;           
  wire                  bvalidm;          
  wire                  breadym;          

  wire [PAYLD_MAX:0]    payld_src;      
  wire [PAYLD_MAX:0]    payld_regd;     
  wire [PAYLD_MAX:0]    payld_fwd_regd;  
  wire [PAYLD_MAX:0]    payld_rev_regd;  
  wire                  bvalid_regd;    
  wire                  bvalid_fwd_regd; 
  wire                  bvalid_rev_regd; 
  wire                  bready_regd;    
  wire                  bready_fwd_regd; 
  wire                  bready_rev_regd; 


  assign bvalids = ((INT_HNDSHK_MODE == `RS_REGD)        ? bvalid_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? bvalid_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? bvalid_rev_regd
                        : bvalidm)));

  assign {bids,
          bresps,
          busers} = ((INT_HNDSHK_MODE == `RS_REGD)        ? payld_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? payld_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? payld_rev_regd
                         : {bidm,
                            brespm,
                            buserm})));

  assign breadym = ((INT_HNDSHK_MODE == `RS_REGD)        ? bready_regd
                    :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? bready_fwd_regd
                      :((INT_HNDSHK_MODE == `RS_REV_REG) ? bready_rev_regd
                        : breadys)));

  assign payld_src = {bidm,
                     brespm,
                     buserm};

  nic400_ful_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_ful_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (bvalidm),
     .ready_dst       (breadys),
     .payload_src     (payld_src),

     .ready_src       (bready_regd),
     .valid_dst       (bvalid_regd),
     .payload_dst     (payld_regd)
     );

  nic400_fwd_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (bvalidm),
     .ready_dst       (breadys),
     .payload_src     (payld_src),

     .ready_src       (bready_fwd_regd),
     .valid_dst       (bvalid_fwd_regd),
     .payload_dst     (payld_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_dbgaxi2apb #(PAYLD_WIDTH) u_rev_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (bvalidm),
     .ready_dst       (breadys),
     .payload_src     (payld_src),

     .ready_src       (bready_rev_regd),
     .valid_dst       (bvalid_rev_regd),
     .payload_dst     (payld_rev_regd)
     );

endmodule

`include "reg_slice_axi_undefs.v"


