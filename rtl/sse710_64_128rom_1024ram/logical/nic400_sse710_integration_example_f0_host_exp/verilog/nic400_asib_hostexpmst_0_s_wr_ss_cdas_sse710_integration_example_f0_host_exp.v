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




module nic400_asib_hostexpmst_0_s_wr_ss_cdas_sse710_integration_example_f0_host_exp
  (
    aw_enable,
    wr_enable,
    asel,
    avalid,
    aready,
    wvalid,
    wready,
    wlast,
    resp_valid,
    resp_ready,

    aclk,
    aresetn
  );


    output       aw_enable;     
    output       wr_enable;     
    input  [4:0] asel;     
    input        avalid;     
    input        aready;     
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid;
    input        resp_ready;
    input        aclk;
    input        aresetn;


  reg   [2:0]    next_last_cnt;    
  wire           next_valid_add;     
  reg   [2:0]    next_tt_cnt;    
  wire           next_empty;    
  reg            dec_tt_cnt;    
  wire  [4:0]    asel_mask;   
  wire  [4:0]    asel_masked;    
  wire           asel_int;    

  wire           add_push;   
  wire           resp_pop;   


  reg            valid_add;   
  reg   [2:0]    last_cnt;   
  reg            asel_reg;   
  reg            aready_reg;   
  reg   [2:0]    tt_cnt;   

  reg            empty;     
  reg   [4:0]    current_dest;   





   assign asel_mask = current_dest | {5{empty}};
   assign asel_masked = (asel & asel_mask);
   assign asel_int = |asel_masked & avalid;

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




   assign resp_pop = resp_valid & resp_ready;

   always @(add_push or resp_pop or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        dec_tt_cnt = 1'b0;
        if (add_push && !resp_pop)
                next_tt_cnt = tt_cnt + 1'b1;
        if (!(add_push) && resp_pop)
          begin
                next_tt_cnt = tt_cnt - 1'b1;
                dec_tt_cnt = 1'b1;
          end
     end 

   always @(wvalid or wready or wlast or resp_valid or resp_ready or last_cnt)
     begin : p_next_last_comb
        next_last_cnt = last_cnt;
        if ((wvalid && wready && wlast) && !(resp_valid && resp_ready))
                next_last_cnt = last_cnt + 1'b1;
        if (!(wvalid && wready && wlast) && (resp_valid && resp_ready))
                next_last_cnt = last_cnt - 1'b1;
     end 
  assign next_empty = (tt_cnt == 3'b001) && dec_tt_cnt;


   assign next_valid_add = (next_tt_cnt > next_last_cnt);

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_last_seq
       if (!aresetn) begin
                last_cnt <= {3{1'b0}};
                valid_add <= 1'b0;
       end
       else  begin
                last_cnt <= next_last_cnt;
                valid_add <= next_valid_add;
       end
     end 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn)
         begin
             tt_cnt <= {3{1'b0}};
             empty <= 1'b1;
         end
       else if ((add_push) || (resp_valid && resp_ready))
         begin
             tt_cnt <= next_tt_cnt;
             empty <= next_empty;
         end
     end 

   always @(posedge aclk)
     begin : p_dest_seq
       if (((add_push) || (resp_valid && resp_ready)) && empty)
         begin
             current_dest <= asel;
         end
     end 






   assign aw_enable = |asel_masked;
   assign wr_enable = valid_add;




`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"

  assert_no_overflow #(
                       `OVL_FATAL,
                       3,
                       0,
                       4,
                       `OVL_ASSERT,
                       "CDS write transaction counter has overflowed"
                      )
  ovl_tt_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tt_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        3,
                        0,
                        4,
                        `OVL_ASSERT,
                        "CDS write transaction counter has underflowed"
                       )
  ovl_tt_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tt_cnt)
  );

`endif

  endmodule

