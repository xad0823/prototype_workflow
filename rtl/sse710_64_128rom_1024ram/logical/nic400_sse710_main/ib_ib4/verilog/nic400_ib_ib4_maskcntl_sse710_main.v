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



module nic400_ib_ib4_maskcntl_sse710_main
  (
    awvalid_m,
    awready_m,
    arvalid_m,
    arready_m,
    aw_qos_s,
    ar_qos_s,
    bvalid_m,
    bready_m,
    rvalid_m,
    rready_m,
    wr_cnt_empty,
    mask_w,
    mask_r,
    aw_qos_m,
    ar_qos_m,
    tracker_busy,
    aclk,
    aresetn
  );



  input             awvalid_m;
  input             awready_m;
  input             arvalid_m;
  input             arready_m;
  input [3:0]       aw_qos_s;
  input [3:0]       ar_qos_s;
  input             bvalid_m;
  input             bready_m;
  input             rvalid_m;
  input             rready_m;
  output            wr_cnt_empty;
  output            mask_w;
  output            mask_r;
  output [3:0]      aw_qos_m;
  output [3:0]      ar_qos_m;
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
  wire              wr_mask_en;
  wire              rd_mask_en;
  wire  [4:0]       next_rd_cnt;     
  wire  [4:0]       next_wr_cnt;     
  reg   [4:0]       wr_iss;
  reg   [4:0]       rd_iss;
  reg               next_mask_w;
  reg               next_mask_r;
  wire [3:0]        aw_qos_s;
  wire [3:0]        ar_qos_s;
  
  wire              nxt_limit_wr;
  wire              nxt_limit_rd;
  wire              next_tracker_busy;


  reg   [4:0]       rd_cnt;          
  reg   [4:0]       wr_cnt;          
  reg               wr_cnt_empty;     
  reg               reg_mask_w;
  reg               reg_mask_r;
  reg               tracker_busy;


  assign nxt_limit_wr = 1'b0;
  assign nxt_limit_rd = 1'b0;


  assign aw_qos_m = aw_qos_s;
  assign ar_qos_m = ar_qos_s;
  


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
           rd_cnt <= {5{1'b0}};
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

  always @(next_wr_cnt or next_rd_cnt or nxt_limit_wr or nxt_limit_rd)
   begin : p_mask_comb
     wr_iss = 5'b10010;
     rd_iss = 5'b10010;

     next_mask_w = 1'b0;
     next_mask_r = 1'b0;

     if (next_wr_cnt == wr_iss ||
              (|next_wr_cnt && nxt_limit_wr == 1'b1))
        next_mask_w = 1'b1;
     if (next_rd_cnt ==  rd_iss ||
              (|next_rd_cnt && nxt_limit_rd == 1'b1))
        next_mask_r = 1'b1;
  end 



  assign wr_mask_en =push_wr | pop_wr;
  assign rd_mask_en = push_rd | pop_rd;

   always @(posedge aclk or negedge aresetn)
     begin : p_wr_mask_seq
       if (!aresetn)
         begin
           reg_mask_w <= 1'b0;
         end
       else if (wr_mask_en)
         begin
           reg_mask_w <= next_mask_w;
         end
     end 

  assign mask_w = reg_mask_w;

   always @(posedge aclk or negedge aresetn)
     begin : p_rd_mask_seq
       if (!aresetn)
         begin
           reg_mask_r <= 1'b0;
         end
       else if (rd_mask_en)
         begin
           reg_mask_r <= next_mask_r;
         end
     end 

  assign mask_r = reg_mask_r;


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
  assign test_wr_limit = (|wr_cnt && (awvalid_m & !mask_w) && limit_wr_align);

   assert_never #(1,0,"ERROR, Wr issuing exceeded one when limited")
     ovl_wr_limit
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (test_wr_limit)
        );


  wire test_rd_limit;
  assign test_rd_limit = (|rd_cnt && (arvalid_m & !mask_r) && limit_rd_align);

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
                       5,
                       0,
                       31,
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
                        5,
                        0,
                        31,
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



