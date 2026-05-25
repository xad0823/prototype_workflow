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



module nic400_ib_gpv_0_ib1_itb_trans_counter_sse710_main
  (
    avalid_m,
    aready_m,
    dvalid_m,
    dready_m,
    dbnr_m,
    dlast_m,
    tracker_busy,
    tracker_full,
    tracker_empty,
    aclk,
    aresetn
  );



  input             avalid_m;
  input             aready_m;
  input             dvalid_m;
  input             dbnr_m;
  input             dlast_m;
  input             dready_m;
  output            tracker_busy;
  output            tracker_full;
  output            tracker_empty;
  input             aclk;
  input             aresetn;


  wire              push_tx;         
  wire              pop_tx;          
  wire              tx_cnt_en;
  wire  [1:0]    next_tx_cnt;     
  wire              tracker_busy;


  reg   [1:0]    tx_cnt;          
  
  

  assign push_tx = avalid_m & aready_m;

  assign pop_tx = (dvalid_m & dready_m) & (dbnr_m | dlast_m);

  assign next_tx_cnt = (push_tx & ~pop_tx) ? tx_cnt + 1'b1
                         : ((~push_tx & pop_tx) ? tx_cnt - 1'b1
                           : tx_cnt);

  assign tracker_busy = |tx_cnt;

  
  assign tracker_full = &tx_cnt;

  assign tracker_empty = ~|tx_cnt;
  
  
  assign tx_cnt_en = push_tx ^ pop_tx;

   always @(posedge aclk or negedge aresetn)
     begin : p_tx_cnt_seq
       if (!aresetn)
         begin
           tx_cnt <= 2'b0;
         end
       else
         begin
           if (tx_cnt_en)
             begin
                tx_cnt <= next_tx_cnt;
             end
         end
     end 


`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  assert_no_overflow #(
                       `OVL_FATAL,
                       2,
                       0,
                       3,
                       `OVL_ASSERT,
                       "ITB transaction counter has overflowed"
                      )
  ovl_comb_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tx_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        2,
                        0,
                        3,
                        `OVL_ASSERT,
                        "ITB transaction counter has underflowed"
                       )
  ovl_comb_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tx_cnt)
  );


`endif

  endmodule



