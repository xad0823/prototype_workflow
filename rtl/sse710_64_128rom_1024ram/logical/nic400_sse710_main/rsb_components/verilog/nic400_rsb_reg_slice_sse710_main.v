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

module nic400_rsb_reg_slice_sse710_main
  (
   rresetn,
   rclk,

   rsb_data_s,
   rsb_valid_s,
   rsb_ready_s,

   rsb_data_m,
   rsb_valid_m,
   rsb_ready_m
   );

  parameter HNDSHK_MODE = `RS_STATIC_BYPASS;     
`ifdef ARM_ASSERT_ON
  wire [1:0] INT_HNDSHK_MODE = HNDSHK_MODE; 
`else
  parameter  INT_HNDSHK_MODE = HNDSHK_MODE; 
`endif

  parameter DATA_WIDTH = 8;
  parameter DATA_MAX   = (DATA_WIDTH - 1);

  input                 rresetn;          
  input                 rclk;             

  input [7:0]           rsb_data_s;       
  input                 rsb_valid_s;      
  output                rsb_ready_s;      

  output [7:0]          rsb_data_m;       
  output                rsb_valid_m;      
  input                 rsb_ready_m;      

  wire                  rresetn;          
  wire                  rclk;             

  wire [7:0]            rsb_data_s;       
  wire                  rsb_valid_s;      
  wire                  rsb_ready_s;      

  wire [7:0]            rsb_data_m;       
  wire                  rsb_valid_m;      
  wire                  rsb_ready_m;      

  wire [DATA_MAX:0]    data_regd;          
  wire [DATA_MAX:0]    data_fwd_regd;      
  wire [DATA_MAX:0]    data_rev_regd;      
  wire                 rsb_valid_regd;     
  wire                 rsb_valid_fwd_regd; 
  wire                 rsb_valid_rev_regd; 
  wire                 rsb_ready_regd;     
  wire                 rsb_ready_fwd_regd; 
  wire                 rsb_ready_rev_regd; 

  assign rsb_ready_s = ((INT_HNDSHK_MODE == `RS_REGD)        ? rsb_ready_regd
                        :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? rsb_ready_fwd_regd
                          :((INT_HNDSHK_MODE == `RS_REV_REG) ? rsb_ready_rev_regd
                            : rsb_ready_m)));

  assign rsb_data_m = ((INT_HNDSHK_MODE == `RS_REGD)        ? data_regd
                       :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? data_fwd_regd
                         :((INT_HNDSHK_MODE == `RS_REV_REG) ? data_rev_regd
                           : rsb_data_s)));

  assign rsb_valid_m = ((INT_HNDSHK_MODE == `RS_REGD)        ? rsb_valid_regd
                        :((INT_HNDSHK_MODE == `RS_FWD_REG)   ? rsb_valid_fwd_regd
                          :((INT_HNDSHK_MODE == `RS_REV_REG) ? rsb_valid_rev_regd
                            : rsb_valid_s)));

  nic400_ful_regd_slice_sse710_main #(DATA_WIDTH) u_ful_regd_slice
    (
     .aresetn        (rresetn),
     .aclk           (rclk),

     .valid_src       (rsb_valid_s),
     .ready_dst       (rsb_ready_m),
     .payload_src     (rsb_data_s),

     .ready_src       (rsb_ready_regd),
     .valid_dst       (rsb_valid_regd),
     .payload_dst     (data_regd)
     );

  nic400_fwd_regd_slice_sse710_main #(DATA_WIDTH) u_fwd_regd_slice
    (
     .aresetn        (rresetn),
     .aclk           (rclk),

     .valid_src       (rsb_valid_s),
     .ready_dst       (rsb_ready_m),
     .payload_src     (rsb_data_s),

     .ready_src       (rsb_ready_fwd_regd),
     .valid_dst       (rsb_valid_fwd_regd),
     .payload_dst     (data_fwd_regd)
     );

  nic400_rev_regd_slice_sse710_main #(DATA_WIDTH) u_rev_regd_slice
    (
     .aresetn        (rresetn),
     .aclk           (rclk),

     .valid_src       (rsb_valid_s),
     .ready_dst       (rsb_ready_m),
     .payload_src     (rsb_data_s),

     .ready_src       (rsb_ready_rev_regd),
     .valid_dst       (rsb_valid_rev_regd),
     .payload_dst     (data_rev_regd)
     );

`ifdef ARM_ASSERT_ON

  wire [1:0]            hndshk_mode_w;     

  assign hndshk_mode_w = INT_HNDSHK_MODE;

  assert_proposition
    #(0, 1, "Error: value of reg_slice hndshk_mode_w must be 0, 1, 2 or 3")
      illegal_aw_hndshk_mode_val
        (.reset_n (rresetn),
         .test_expr((hndshk_mode_w == `RS_REGD         ) |
                    (hndshk_mode_w == `RS_FWD_REG      ) |
                    (hndshk_mode_w == `RS_REV_REG      ) |
                    (hndshk_mode_w == `RS_STATIC_BYPASS)));

`endif

endmodule

`include "reg_slice_axi_undefs.v"


