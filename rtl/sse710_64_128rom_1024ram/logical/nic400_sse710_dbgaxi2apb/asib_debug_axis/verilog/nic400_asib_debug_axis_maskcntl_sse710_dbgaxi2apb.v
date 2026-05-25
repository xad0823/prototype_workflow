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



module nic400_asib_debug_axis_maskcntl_sse710_dbgaxi2apb
  (
    awvalid_m,
    awready_m,
    arvalid_m,
    arready_m,
    bvalid_m,
    bready_m,
    rvalid_m,
    rready_m,
    wr_cnt_empty,
    tracker_busy,
    aclk,
    aresetn
  );



  input             awvalid_m;
  input             awready_m;
  input             arvalid_m;
  input             arready_m;
  input             bvalid_m;
  input             bready_m;
  input             rvalid_m;
  input             rready_m;
  output            wr_cnt_empty;
  output            tracker_busy;
  input             aclk;
  input             aresetn;


  wire              push_rd;         
  wire              push_wr;         
  wire              pop_rd;          
  wire              pop_wr;          
  wire              next_wr_cnt_empty;     
  wire              wr_cnt_en;
  wire              rd_cnt_en;
  wire  [3:0]       next_rd_cnt;     
  wire  [4:0]       next_wr_cnt;     
  wire              nxt_limit_wr;
  wire              nxt_limit_rd;
  wire              next_tracker_busy;


  reg   [3:0]       rd_cnt;          
  reg   [4:0]       wr_cnt;          
  reg               wr_cnt_empty;     
  reg               tracker_busy;


  assign nxt_limit_wr = 1'b0;
  assign nxt_limit_rd = 1'b0;


  assign push_rd = arvalid_m & arready_m;
  assign push_wr = awvalid_m & awready_m;

  assign pop_rd = rvalid_m & rready_m;
  assign pop_wr = bvalid_m & bready_m;

  assign next_rd_cnt = (push_rd & ~pop_rd) ? rd_cnt + 1'b1
                         : ((~push_rd & pop_rd) ? rd_cnt - 1'b1
                           : rd_cnt);

  assign next_wr_cnt = (push_wr & ~pop_wr) ? wr_cnt + 1'b1
                         : ((~push_wr & pop_wr) ? wr_cnt - 1'b1
                           : wr_cnt);





  assign wr_cnt_en = push_wr ^ pop_wr;
  assign rd_cnt_en = push_rd ^ pop_rd;
  assign next_wr_cnt_empty = (next_wr_cnt == 5'b0);

   always @(posedge aclk or negedge aresetn)
     begin : p_wr_cnt_seq
       if (!aresetn)
         begin
           wr_cnt <= {5{1'b0}};
           wr_cnt_empty <= 1'b1;
           rd_cnt <= {4{1'b0}};
         end
       else
         begin
           if (wr_cnt_en)
           begin
                wr_cnt <= next_wr_cnt;
                wr_cnt_empty <= next_wr_cnt_empty;
           end
           if (rd_cnt_en)
           begin
                rd_cnt <= next_rd_cnt;
           end
         end
     end 


  assign next_tracker_busy = (|next_wr_cnt) | (|next_rd_cnt);

  always @(posedge aclk or negedge aresetn)
     begin : p_busy_seq
       if (!aresetn)
         begin
           tracker_busy <= 1'b0;
         end
       else
         begin
           if (wr_cnt_en || rd_cnt_en)
             tracker_busy <= next_tracker_busy;
         end
     end 



`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"

  reg limit_wr_align;
  reg limit_rd_align;

  always @(posedge aclk or negedge aresetn)
     begin : p_limit_wr_align
        if (!aresetn) begin
           limit_wr_align <= 1'b0;
        end else if (~awvalid_m || push_wr) begin
           limit_wr_align <= nxt_limit_wr;
        end
     end

  always @(posedge aclk or negedge aresetn)
     begin : p_limit_rd_align
        if (!aresetn) begin
           limit_rd_align <= 1'b0;
        end else if (~arvalid_m || push_rd) begin
           limit_rd_align <= nxt_limit_rd;
        end
     end


  wire test_wr_limit;
  assign test_wr_limit = (|wr_cnt && (awvalid_m) && limit_wr_align);

   assert_never #(1,0,"ERROR, Wr issuing exceeded one when limited")
     ovl_wr_limit
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (test_wr_limit)
        );


  wire test_rd_limit;
  assign test_rd_limit = (|rd_cnt && (arvalid_m) && limit_rd_align);

   assert_never #(1,0,"ERROR, read issuing exceeded one when limited")
     ovl_rd_limit
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (test_rd_limit)
        );
  assert_no_overflow #(
                       `OVL_FATAL,
                       5,
                       0,
                       31,
                       `OVL_ASSERT,
                       "Mask control write transaction counter has overflowed"
                      )
  ovl_wr_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        5,
                        0,
                        31,
                        `OVL_ASSERT,
                        "Mask control write transaction counter has underflowed"
                       )
  ovl_wr_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_cnt)
  );

  assert_no_overflow #(
                       `OVL_FATAL,
                       4,
                       0,
                       15,
                       `OVL_ASSERT,
                       "Mask control read transaction counter has overflowed"
                      )
  ovl_rd_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (rd_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        4,
                        0,
                        15,
                        `OVL_ASSERT,
                        "Mask control read transaction counter has underflowed"
                       )
  ovl_rd_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (rd_cnt)
  );

`endif

  endmodule



