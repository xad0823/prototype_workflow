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




module nic400_asib_gpvmain_ahb_itb_ss_cdas_sse710_main
  (
    a_enable,
    wr_enable,
    asel,
    avalid,
    aready,
    awrite,
    wvalid,
    wready,
    wlast,
    resp_valid,
    resp_ready,
    resp_last,
    resp_dbnr,

    aclk,
    aresetn
  );


    output       a_enable;     
    output       wr_enable;     
    input  [1:0] asel;     
    input        avalid;     
    input        aready;     
    input        awrite;     
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid;
    input        resp_ready;
    input        resp_last;
    input        resp_dbnr;
    input        aclk;
    input        aresetn;




  reg   [2:0]    next_last_cnt;    
  reg   [2:0]    next_rd_tt_cnt;    
  reg   [2:0]    next_wr_tt_cnt;    
  reg            dec_wr_tt_cnt;    
  reg            dec_rd_tt_cnt;    
  wire  [1:0]    wr_asel_mask;   
  wire  [1:0]    wr_asel_masked;    
  wire  [1:0]    rd_asel_mask;   
  wire  [1:0]    rd_asel_masked;    
  wire           asel_int;    
  wire           next_wr_empty;    
  wire           next_rd_empty;    

  wire           next_valid_add;     
  wire           add_push;   


  reg            valid_add;   
  reg   [2:0]    last_cnt;   
  reg   [2:0]    rd_tt_cnt;   
  reg   [2:0]    wr_tt_cnt;   
  reg            asel_reg;   
  reg            aready_reg;   

  reg            wr_empty;     
  reg            rd_empty;     
  reg   [1:0]    current_rd_dest;   
  reg   [1:0]    current_wr_dest;   





   assign wr_asel_mask = current_wr_dest | {2{wr_empty}};
   assign rd_asel_mask = current_rd_dest | {2{rd_empty}};
   assign wr_asel_masked = (asel & wr_asel_mask);
   assign rd_asel_masked = (asel & rd_asel_mask);
   assign asel_int = ((|wr_asel_masked & awrite) | (|rd_asel_masked & ~awrite)) & avalid;

   always @(posedge aclk or negedge aresetn)
     begin : p_add_push_seq
       if (!aresetn)
         begin
           asel_reg   <= 1'b0;
           aready_reg <= 1'b0;
         end
       else
         begin
           asel_reg   <= asel_int;
           aready_reg <= aready;
         end
     end 

   assign add_push = asel_int & (~asel_reg | aready_reg);



   always @(add_push or awrite or resp_valid or resp_ready or
            wr_tt_cnt or rd_tt_cnt or resp_dbnr or resp_last)
     begin : p_next_tt_comb
        next_wr_tt_cnt = wr_tt_cnt;
        next_rd_tt_cnt = rd_tt_cnt;
        dec_wr_tt_cnt = 1'b0;
        dec_rd_tt_cnt = 1'b0;
        if (add_push && awrite && !(resp_valid && resp_ready && resp_dbnr))
                next_wr_tt_cnt = wr_tt_cnt + 1'b1;
        if (!(add_push && awrite) && (resp_valid && resp_ready && resp_dbnr))
          begin
                next_wr_tt_cnt = wr_tt_cnt - 1'b1;
                dec_wr_tt_cnt = 1'b1;
          end
        if (add_push && !awrite && !(resp_valid && resp_ready && resp_last  && !resp_dbnr))
                next_rd_tt_cnt = rd_tt_cnt + 1'b1;
        if (!(add_push && !awrite) && (resp_valid && resp_ready && resp_last && !resp_dbnr))
          begin
                next_rd_tt_cnt = rd_tt_cnt - 1'b1;
                dec_rd_tt_cnt = 1'b1;
          end
     end 

   always @(wvalid or wready or wlast or resp_valid or resp_ready or resp_dbnr or last_cnt)
     begin : p_next_last_comb
        next_last_cnt = last_cnt;
        if ((wvalid && wready && wlast) && !(resp_valid && resp_ready && resp_dbnr))
                next_last_cnt = last_cnt + 1'b1;
        if (!(wvalid && wready && wlast) && (resp_valid && resp_ready && resp_dbnr))
                next_last_cnt = last_cnt - 1'b1;
     end 

  assign next_wr_empty = (wr_tt_cnt == 3'b001) && dec_wr_tt_cnt;
  assign next_rd_empty = (rd_tt_cnt == 3'b001) && dec_rd_tt_cnt;


   assign next_valid_add = (next_wr_tt_cnt > next_last_cnt);

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_last_seq
       if (!aresetn)
       begin
         last_cnt <= {3{1'b0}};
         valid_add <= 1'b0;
       end
       else
       begin
         last_cnt <= next_last_cnt;
         valid_add <= next_valid_add;
       end
     end 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn)
         begin
                wr_tt_cnt <= {3{1'b0}};
                rd_tt_cnt <= {3{1'b0}};
                wr_empty <= 1'b1;
                rd_empty <= 1'b1;
         end
       else
       begin
         if ((add_push && awrite) || (resp_valid && resp_ready && resp_dbnr))
         begin
                wr_tt_cnt <= next_wr_tt_cnt;
                wr_empty <= next_wr_empty;
         end
         if ((add_push && !awrite) || (resp_valid && resp_ready && resp_last && !resp_dbnr))
         begin
                rd_tt_cnt <= next_rd_tt_cnt;
                rd_empty <= next_rd_empty;
         end
       end
     end 

   always @(posedge aclk)
     begin : p_dest_seq
       if (((add_push && awrite) || (resp_valid && resp_ready && resp_dbnr)) && wr_empty)
         begin
                current_wr_dest <= asel;
         end
       if (((add_push && !awrite) || (resp_valid && resp_ready && resp_last && !resp_dbnr)) && rd_empty)
         begin
                current_rd_dest <= asel;
         end
     end 






   assign a_enable  = asel_int;
   assign wr_enable = valid_add;




`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"

  assert_no_overflow #(
                       `OVL_FATAL,
                       3,
                       0,
                       7,
                       `OVL_ASSERT,
                       "CDS write transaction counter has overflowed"
                      )
  ovl_wr_tt_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_tt_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        3,
                        0,
                        7,
                        `OVL_ASSERT,
                        "CDS write transaction counter has underflowed"
                       )
  ovl_wr_tt_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_tt_cnt)
  );

  assert_no_overflow #(
                       `OVL_FATAL,
                       3,
                       0,
                       7,
                       `OVL_ASSERT,
                       "CDS read transaction counter has overflowed"
                      )
  ovl_rd_tt_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (rd_tt_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        3,
                        0,
                        7,
                        `OVL_ASSERT,
                        "CDS read transaction counter has underflowed"
                       )
  ovl_rd_tt_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (rd_tt_cnt)
  );

`endif

  endmodule

