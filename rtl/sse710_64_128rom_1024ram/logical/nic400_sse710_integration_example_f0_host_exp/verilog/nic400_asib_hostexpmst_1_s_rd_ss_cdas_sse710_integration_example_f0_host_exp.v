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



module nic400_asib_hostexpmst_1_s_rd_ss_cdas_sse710_integration_example_f0_host_exp
  (
    ar_enable,
    asel,
    avalid,
    aready,
    resp_valid,
    resp_last,
    resp_ready,

    aclk,
    aresetn
  );


    output       ar_enable;     
    input  [3:0] asel;     
    input        avalid;
    input        aready;
    input        resp_valid;
    input        resp_last;
    input        resp_ready;
    input        aclk;
    input        aresetn;


  reg   [1:0]    next_tt_cnt;    
  wire           resp_pop;
  wire           tt_reg_enable;
  wire           next_empty;    
  reg            dec_tt_cnt;    
  wire           asel_int;    
  wire  [3:0]    asel_mask;    
  wire  [3:0]    asel_masked;    
  wire  [3:0]    next_tt_reg;    




  reg   [1:0]    tt_cnt;    
  reg            empty;     
  reg   [3:0]    tt_reg;     
  reg   [3:0]    current_dest;     




   assign asel_mask = current_dest | {4{empty}};
   assign asel_masked = (asel & asel_mask);
   assign asel_int = |asel_masked & avalid;
   assign resp_pop = resp_valid & resp_ready & resp_last;


   always @(asel_int or aready or resp_pop or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        dec_tt_cnt = 1'b0;
        if ((asel_int && aready) && !resp_pop) begin
                next_tt_cnt = tt_cnt + 1'b1;
        end
        if (!(asel_int && aready) && resp_pop) begin
                next_tt_cnt = tt_cnt - 1'b1;
                dec_tt_cnt = 1'b1;
        end
     end 
   assign next_tt_reg = (|asel && aready) ? asel
                        : (tt_cnt == 2'b01 && dec_tt_cnt) ? {4{1'b0}}
                        : tt_reg;

   assign next_empty = (tt_cnt == 2'b01) && dec_tt_cnt;

   assign tt_reg_enable = ((asel_int && avalid && aready)
                           || (resp_valid && resp_last && resp_ready));



   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn)
         begin
                tt_cnt <= {2{1'b0}};
                empty <= 1'b1;
                tt_reg <= {4{1'b0}};
         end
       else if (tt_reg_enable)
         begin
                tt_reg <= next_tt_reg;
                tt_cnt <= next_tt_cnt;
                empty <= next_empty;
         end
     end 

   always @(posedge aclk)
     begin : p_dest_seq
       if (tt_reg_enable & empty)
         begin
                current_dest <= asel;
         end
     end 






   assign ar_enable = |asel_masked;




`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"

  assert_no_overflow #(
                       `OVL_FATAL,
                       2,
                       0,
                       3,
                       `OVL_ASSERT,
                       "CDS read transaction counter has overflowed"
                      )
  ovl_tt_cnt_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tt_cnt)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        2,
                        0,
                        3,
                        `OVL_ASSERT,
                        "CDS read transaction counter has underflowed"
                       )
  ovl_tt_cnt_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (tt_cnt)
  );

`endif

  endmodule

