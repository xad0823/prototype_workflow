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



module nic400_rsb_s_arbiter_sse710_main
  (
   rsb_data_pass,
   rsb_valid_pass,
   rsb_ready_pass,

   rsb_data_done,
   rsb_valid_done,
   rsb_ready_done,

   rsb_data_m,
   rsb_valid_m,
   rsb_ready_m
   );

  input             [7:0] rsb_data_pass;
  input                   rsb_valid_pass;
  output                  rsb_ready_pass;
  
  input             [7:0] rsb_data_done;
  input                   rsb_valid_done;
  output                  rsb_ready_done;
  
  output            [7:0] rsb_data_m;
  output                  rsb_valid_m;
  input                   rsb_ready_m;


  assign rsb_valid_m = rsb_valid_done | rsb_valid_pass;
  assign rsb_data_m = rsb_valid_done ? rsb_data_done : rsb_data_pass;
  assign rsb_ready_done = rsb_ready_m;
  assign rsb_ready_pass = rsb_ready_m & ~rsb_valid_done;


endmodule 


