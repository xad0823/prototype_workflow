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



module nic400_asib_p2_axis_rd_spi_cdas_sse710_dbg3s1m
  (
    ar_enable,
    asel,
    avalid,
    aready,
    aid,
    resp_valid,
    resp_last,
    resp_ready,
    resp_id,

    aclk,
    aresetn
  );


    output       ar_enable;     
    input        asel;     
    input        avalid;
    input        aready;
    input  [1:0] aid;
    input        resp_valid;
    input        resp_last;
    input        resp_ready;
    input  [1:0] resp_id;
    input        aclk;
    input        aresetn;


  reg   [1:0]    next_tt_cnt;    
  wire           resp_pop;
  wire           tt_reg_enable;

  wire           add_push;   
  wire           t_pop;   
  wire           t_push;   
  wire           mask_push_pop;   
  wire  [2:0]   slots;   
  wire  [2:0]   free_slot;   
  wire  [2:0]    free_slot0;   
  wire  [2:0]    resp_sel;   
  wire  [2:0]    resp_sel0;   
  wire  [2:0]    id_match;    
  wire  [2:0]    dest_match;    
  wire  [2:0]    resp_match;    
  wire           cds_stall;    




  reg   [1:0]    tt_cnt;    
  reg            spi_asel [2:0];     
  reg   [1:0]    spi_ids [2:0];     
  reg   [2:0]    spi_valid;     
  reg            hold_asel;     
  reg            hold_valid;     
  reg   [1:0]    hold_aid;     
  reg            t_ready;     
  reg            full;     
  wire           next_full;     






   assign resp_pop = resp_valid & resp_ready & resp_last;

   always @(avalid or aready or resp_pop or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        if ((avalid && aready) && !(resp_pop)) begin
                next_tt_cnt = tt_cnt + 1'b1;
        end
        if (!(avalid && aready) && resp_pop) begin
                next_tt_cnt = tt_cnt - 1'b1;
        end
     end 

   assign next_full = (next_tt_cnt == 2'd3) ? 1'b1 : 1'b0;

   assign add_push = avalid & aready;
   assign t_pop = resp_valid & resp_ready & resp_last & ~mask_push_pop;

   assign slots = ~spi_valid;

   assign free_slot0[0] =  slots[0];
   assign free_slot0[1] =  slots[0] ? 1'b0 : slots[1];
   assign free_slot0[2] =  |slots[1:0] ? 1'b0 : slots[2];

   assign free_slot = free_slot0;

   assign resp_match[0] = ((spi_ids[0]  == resp_id[1:0]) &&
                            spi_valid[0]);
   assign resp_match[1] = ((spi_ids[1]  == resp_id[1:0]) &&
                            spi_valid[1]);
   assign resp_match[2] = ((spi_ids[2]  == resp_id[1:0]) &&
                            spi_valid[2]);


   assign resp_sel0[0] =  resp_match[0];
   assign resp_sel0[1] =  resp_match[0] ? 1'b0 : resp_match[1];
   assign resp_sel0[2] =  |resp_match[1:0] ? 1'b0 : resp_match[2];

   assign resp_sel = resp_sel0;

   assign mask_push_pop = (hold_aid == resp_id) & t_ready
                       & resp_valid & resp_ready & resp_last;
   assign t_push = t_ready & ~mask_push_pop;



   assign id_match[0] = (spi_ids[0] == aid[1:0]);
   assign id_match[1] = (spi_ids[1] == aid[1:0]);
   assign id_match[2] = (spi_ids[2] == aid[1:0]);
   assign dest_match[0] = (spi_asel[0] == asel);
   assign dest_match[1] = (spi_asel[1] == asel);
   assign dest_match[2] = (spi_asel[2] == asel);

   assign cds_stall =  (|(id_match & ~dest_match & spi_valid) |
                       ((hold_aid == aid[1:0]) & ~(hold_asel == asel) & hold_valid));



   assign tt_reg_enable = ((asel && avalid && aready)
                           || (resp_valid && resp_last && resp_ready));



   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn)
         begin
             tt_cnt <= {2{1'b0}};
             full   <= 1'b0;
         end
       else if (tt_reg_enable)
         begin
                tt_cnt <= next_tt_cnt;
                full   <= next_full;
         end
     end 


    always @(posedge aclk or negedge aresetn)
    begin : p_ptr_seq
      integer tt_ptr_val;
      if (!aresetn)
      begin
           spi_valid <= {3{1'b0}};
      end else
      begin
       if (t_push)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<3; tt_ptr_val=tt_ptr_val+1)
               if (free_slot[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b1;
               end
         end
        if (t_pop)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<3; tt_ptr_val=tt_ptr_val+1)
               if (resp_sel[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b0;
               end
         end
      end
    end 


   always @(posedge aclk)
    begin : p_tt_dat_seq
         integer tt_ptr;
         if (t_push)
          begin
                for (tt_ptr = 0; tt_ptr<3; tt_ptr=tt_ptr+1)
                if (free_slot[tt_ptr] == 1'b1)
                begin
                     spi_asel[tt_ptr] <= hold_asel;
                     spi_ids[tt_ptr] <= hold_aid;
                end
          end
   end 

   always @(posedge aclk or negedge aresetn)
    begin : p_t_push_seq
      if (!aresetn)
      begin
         t_ready <= 1'b0;
      end else
      begin
         t_ready <= (add_push);
      end
   end 

   always @(posedge aclk or negedge aresetn)
    begin : p_holdv_seq
      if (!aresetn)
         hold_valid <= 1'b0;
      else
      begin
        if(add_push)
        begin
           hold_valid <= 1'b1;
        end else
        begin
           hold_valid <= 1'b0;
        end
      end
   end 

   always @(posedge aclk)
    begin : p_hold_seq
      begin
        if(add_push)
        begin
           hold_asel  <= asel;
           hold_aid   <= aid[1:0];
        end
      end
   end 






   assign ar_enable = ~cds_stall & ~full;




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

