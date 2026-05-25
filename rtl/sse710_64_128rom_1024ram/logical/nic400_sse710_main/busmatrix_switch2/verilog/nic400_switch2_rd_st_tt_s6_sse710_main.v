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




module nic400_switch2_rd_st_tt_s6_sse710_main
  (
    tt_enable,

    asel,
    aready,
    resp_valid,
    resp_last,
    resp_ready,

    aclk,
    aresetn
  );


    output [6:0]    tt_enable;     

    input  [6:0]    asel;     
    input        aready;
    input        resp_valid;
    input        resp_last;
    input        resp_ready;
    input        aclk;
    input        aresetn;


  reg            next_tt_cnt;    
  wire           tt_reg_enable;    
  wire           next_resp_stall;    
  reg   [6:0]    reg_tt_en;     
  wire  [6:0]    next_tt_reg;    
  wire  [6:0]    int_tt_en;     



  reg            resp_stall;    
  reg   [6:0]    tt_reg;    
  reg            tt_cnt;    





   always @(asel or aready or resp_valid or resp_last or resp_ready or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        if ((|asel && aready) && !(resp_valid && resp_last && resp_ready)) begin
                next_tt_cnt = tt_cnt + 1'b1;
        end
        if (!(|asel && aready) && (resp_valid && resp_last && resp_ready)) begin
                next_tt_cnt = tt_cnt - 1'b1;
        end
     end 


   assign next_tt_reg = (|asel && aready) ? asel 
                        : (next_tt_cnt == 1'b0) ? {7{1'b0}}
                        : tt_reg;

   assign tt_reg_enable = ((|asel && aready)
                           || (resp_valid && resp_last && resp_ready));



   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn) 
         begin
                tt_reg <= {7{1'b0}};
                tt_cnt <= 1'b0;
         end
       else if (tt_reg_enable)
         begin
                tt_reg <= next_tt_reg;
                tt_cnt <= next_tt_cnt;
         end
     end 

   assign next_resp_stall = (resp_valid & ~resp_ready);

   always @(posedge aclk or negedge aresetn)
     begin : p_stall_seq
       if (!aresetn)
         begin
          resp_stall <= 1'b0;
        end
       else
         begin
          resp_stall <= next_resp_stall;
        end
     end 

 
   assign int_tt_en = tt_reg;
 

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_en_seq
       if (!aresetn)
         begin
          reg_tt_en <= {7{1'b0}};
        end
       else if (next_resp_stall && !resp_stall)
         begin
          reg_tt_en <= int_tt_en;
        end
     end 
 
   assign tt_enable = resp_stall ? reg_tt_en : int_tt_en;


`ifdef ARM_ASSERT_ON


assign dec_from_zero = (tt_cnt==2'b00) & resp_valid & resp_ready;

assert_never #(1,0,"ERROR, Transaction Counter decrementing from 0")
ovl_assert_dec_empty
   (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (dec_from_zero));

assign inc_from_full = (tt_cnt==1'b1) & |asel & aready;

assert_never #(1,0,"ERROR, Transaction Counter incrementing when full")
ovl_assert_inc_full
   (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (inc_from_full));


`endif

  endmodule

