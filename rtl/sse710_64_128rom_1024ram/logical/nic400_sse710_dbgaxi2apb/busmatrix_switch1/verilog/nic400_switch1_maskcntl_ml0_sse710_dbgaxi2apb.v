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



module nic400_switch1_maskcntl_ml0_sse710_dbgaxi2apb
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
    mask_w,
    mask_r,
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
  output            mask_w;
  output            mask_r;
  input             aclk;
  input             aresetn;




  wire              push_wr;         
  wire              push_rd;         
  wire              pop_rd;          
  wire              pop_wr;          
  wire              next_wr_cnt_empty;     
  wire              next_rd_cnt;     
  wire              next_wr_cnt;     
  reg               next_mask_w;     
  reg               next_mask_r;     



  reg               wr_cnt_empty;     
  reg               rd_cnt;          
  reg               wr_cnt;          
  reg               mask_w;          
  reg               mask_r;          




  assign push_wr = awvalid_m & awready_m;
  assign push_rd = arvalid_m & arready_m;

  assign pop_rd = rvalid_m & rready_m;
  assign pop_wr = bvalid_m & bready_m;

  assign next_rd_cnt = (push_rd & ~pop_rd) ? rd_cnt + 'b1 :
                       ((~push_rd & pop_rd) ? rd_cnt - 'b1 :
                       rd_cnt);

  assign next_wr_cnt = (push_wr & ~pop_wr) ? wr_cnt + 'b1 :
                       ((~push_wr & pop_wr) ? wr_cnt - 'b1 :
                       wr_cnt);

  assign next_wr_cnt_empty = (next_wr_cnt == 1'd0);


   always @(posedge aclk or negedge aresetn)
     begin : p_wr_cnt_seq
       if (!aresetn)
         begin
           wr_cnt <= {1{1'b0}};
           wr_cnt_empty <= 1'b1;
           rd_cnt <= {1{1'b0}};
         end
       else 
         begin
           if (push_wr ^ pop_wr)
           begin
                wr_cnt <= next_wr_cnt;
                wr_cnt_empty <= next_wr_cnt_empty;
           end
           if (push_rd ^ pop_rd)
           begin
                rd_cnt <= next_rd_cnt;
           end
         end
     end 



  always @(next_wr_cnt or next_rd_cnt) 
   begin : p_mask_comb
     next_mask_w = {1{1'b0}};
     next_mask_r = {1{1'b0}};
     if (next_wr_cnt == 1'b1)
        next_mask_w = {1{1'b1}};
     if (next_rd_cnt ==  1'b1)
        next_mask_r = {1{1'b1}};
  end 


   always @(posedge aclk or negedge aresetn)
     begin : p_mask_seq
       if (!aresetn)
         begin
           mask_w <= {1{1'b0}};
           mask_r <= {1{1'b0}};
         end
       else begin 
         if (push_wr  | pop_wr
             | push_rd  | pop_rd)
           begin
              mask_w <= next_mask_w;
              mask_r <= next_mask_r;
           end
       end    
     end 



`ifdef ARM_ASSERT_ON



`endif

  endmodule


