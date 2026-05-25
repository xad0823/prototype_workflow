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



`include "nic400_ib_slave_if0_0_m_ib_defs_sse710_boot_reg.v"

module nic400_ib_slave_if0_0_m_ib_chan_slice_sse710_boot_reg
  (
   aresetn,
   aclk,

   src_data,
   src_valid,
   src_ready,

   dst_data,
   dst_valid,
   dst_ready
   );

  parameter HNDSHK_MODE = `RS_REV_REG;     
  parameter PAYLD_WIDTH = 12;
  
  parameter PAYLD_MAX   = (PAYLD_WIDTH - 1);
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  input                 aresetn;          
  input                 aclk;             

  input  [PAYLD_MAX:0]  src_data;         
  output [PAYLD_MAX:0]  dst_data;         


  input                 src_valid;        
  output                src_ready;        

  output                dst_valid;        
  input                 dst_ready;        


  wire [PAYLD_MAX:0]    payld_src;      
  wire [PAYLD_MAX:0]    payld_regd;     
  wire [PAYLD_MAX:0]    payld_fwd_regd;  
  wire [PAYLD_MAX:0]    payld_rev_regd;  
  wire                  valid_regd;     
  wire                  valid_fwd_regd;  
  wire                  valid_rev_regd;  
  wire                  ready_regd;     
  wire                  ready_fwd_regd;  
  wire                  ready_rev_regd;  


  assign src_ready = ((INT_HNDSHK_MODE == `RS_REGD)       ? ready_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? ready_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? ready_rev_regd
                         : dst_ready)));

  assign dst_data = ((INT_HNDSHK_MODE == `RS_REGD)         ? payld_regd
                      :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? payld_fwd_regd
                        :((INT_HNDSHK_MODE == `RS_REV_REG) ? payld_rev_regd
                          : src_data)));

  assign dst_valid = ((INT_HNDSHK_MODE == `RS_REGD)       ? valid_regd
                     :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? valid_fwd_regd
                       :((INT_HNDSHK_MODE == `RS_REV_REG) ? valid_rev_regd
                         : src_valid)));

  assign payld_src = src_data;

  nic400_ful_regd_slice_sse710_boot_reg #(PAYLD_WIDTH) u_ful_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (src_valid),
     .ready_dst       (dst_ready),
     .payload_src     (payld_src),

     .ready_src       (ready_regd),
     .valid_dst       (valid_regd),
     .payload_dst     (payld_regd)
     );

  nic400_fwd_regd_slice_sse710_boot_reg #(PAYLD_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (src_valid),
     .ready_dst       (dst_ready),
     .payload_src     (payld_src),

     .ready_src       (ready_fwd_regd),
     .valid_dst       (valid_fwd_regd),
     .payload_dst     (payld_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_boot_reg #(PAYLD_WIDTH) u_rev_regd_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .valid_src       (src_valid),
     .ready_dst       (dst_ready),
     .payload_src     (payld_src),

     .ready_src       (ready_rev_regd),
     .valid_dst       (valid_rev_regd),
     .payload_dst     (payld_rev_regd)
     );

  
  
`ifdef ARM_ASSERT_ON

  wire [1:0]            hndshk_mode_w;     

  assign hndshk_mode_w = INT_HNDSHK_MODE;

  assert_proposition
    #(0, 1, "Error: value of reg_slice HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_aw_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((hndshk_mode_w == `RS_REGD         ) |
                    (hndshk_mode_w == `RS_FWD_REG      ) |
                    (hndshk_mode_w == `RS_REV_REG      ) |
                    (hndshk_mode_w == `RS_STATIC_BYPASS)));

`endif


endmodule

`include "nic400_ib_slave_if0_0_m_ib_undefs_sse710_boot_reg.v"


