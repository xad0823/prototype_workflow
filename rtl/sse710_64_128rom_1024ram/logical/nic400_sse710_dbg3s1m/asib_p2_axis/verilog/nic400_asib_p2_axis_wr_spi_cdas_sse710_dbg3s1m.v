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




module nic400_asib_p2_axis_wr_spi_cdas_sse710_dbg3s1m
  (
    aw_enable,
    wr_enable,
    asel,
    avalid,
    aready,
    aid,
    wvalid,
    wready,
    wlast,
    resp_valid,
    resp_ready,
    resp_id,

    aclk,
    aresetn
  );


    output       aw_enable;     
    output       wr_enable;     
    input        asel;     
    input        avalid;     
    input        aready;     
    input  [1:0] aid;
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid;
    input        resp_ready;
    input  [1:0]      resp_id;
    input        aclk;
    input        aresetn;


  reg   [2:0]    next_last_cnt;    
  wire           next_valid_add;     
  reg   [2:0]    next_tt_cnt;    
  wire           t_pop;   
  wire           avalid_mask;   
  wire           next_t_push;   
  wire           hold_resp_match;   
  wire  [6:0]    slots;   
  wire  [6:0]    free_slot;   
  wire  [3:0]    free_slot0;   
  wire  [2:0]    free_slot1;   
  wire  [6:0]    resp_sel;   
  wire  [3:0]    resp_sel0;   
  wire  [2:0]    resp_sel1;   
  wire  [6:0]    resp_mask;   
  wire  [6:0]    mask;   
  wire  [6:0]    id_match;   
  wire  [6:0]    dest_match;   
  wire  [6:0]    resp_match;   
  wire           cds_stall;    
  wire           t_push;     

  wire           add_push;   
  wire           resp_pop;   


  reg            valid_add;   
  reg   [2:0]    last_cnt;   
  reg            asel_reg;   
  reg            aready_reg;   
  reg   [2:0]    tt_cnt;   
  reg            spi_asel [6:0];   
  reg   [1:0]    spi_ids [6:0];   
  reg   [6:0]    spi_valid;   
  reg            hold_asel;   
  reg   [1:0]    hold_aid;   
  reg            hold_valid;   
  reg            t_ready;   




   assign avalid_mask = avalid & ~cds_stall;
   always @(posedge aclk or negedge aresetn)
     begin : p_add_push_seq
       if (!aresetn)
         begin
           asel_reg   <= 1'b0;
           aready_reg <= 1'b0;
         end
       else
         begin
           asel_reg   <= avalid_mask;
           aready_reg <= aready;
         end
     end 

   assign add_push = avalid_mask & (~asel_reg | aready_reg);




   assign resp_pop = resp_valid & resp_ready;

   always @(add_push or resp_pop or tt_cnt)
     begin : p_next_tt_comb
        next_tt_cnt = tt_cnt;
        if (add_push && !resp_pop)
                next_tt_cnt = tt_cnt + 1'b1;
        if (!(add_push) && resp_pop)
          begin
                next_tt_cnt = tt_cnt - 1'b1;
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

   assign t_pop = resp_valid & resp_ready & ~hold_resp_match;

   assign next_t_push = avalid & aready;

   assign slots = ~spi_valid;

   assign free_slot0[0] =  slots[0];
   assign free_slot0[1] =  slots[0] ? 1'b0 : slots[1];
   assign free_slot0[2] =  |slots[1:0] ? 1'b0 : slots[2];
   assign free_slot0[3] =  |slots[2:0] ? 1'b0 : slots[3];
   assign free_slot1[0] =  slots[4];
   assign free_slot1[1] =  slots[4] ? 1'b0 : slots[5];
   assign free_slot1[2] =  |slots[5:4] ? 1'b0 : slots[6];

   assign  mask[3:0] = {4{1'b0}}; 
   assign  mask[6:4] = {3{|(free_slot0)}}; 

   assign free_slot = {free_slot1,
                       free_slot0} & ~mask;

   assign resp_match[0] = ((spi_ids[0]  == resp_id[1:0]) &&
                            spi_valid[0]);
   assign resp_match[1] = ((spi_ids[1]  == resp_id[1:0]) &&
                            spi_valid[1]);
   assign resp_match[2] = ((spi_ids[2]  == resp_id[1:0]) &&
                            spi_valid[2]);
   assign resp_match[3] = ((spi_ids[3]  == resp_id[1:0]) &&
                            spi_valid[3]);
   assign resp_match[4] = ((spi_ids[4]  == resp_id[1:0]) &&
                            spi_valid[4]);
   assign resp_match[5] = ((spi_ids[5]  == resp_id[1:0]) &&
                            spi_valid[5]);
   assign resp_match[6] = ((spi_ids[6]  == resp_id[1:0]) &&
                            spi_valid[6]);


   assign resp_sel0[0] =  resp_match[0];
   assign resp_sel0[1] =  resp_match[0] ? 1'b0 : resp_match[1];
   assign resp_sel0[2] =  |resp_match[1:0] ? 1'b0 : resp_match[2];
   assign resp_sel0[3] =  |resp_match[2:0] ? 1'b0 : resp_match[3];
   assign resp_sel1[0] =  resp_match[4];
   assign resp_sel1[1] =  resp_match[4] ? 1'b0 : resp_match[5];
   assign resp_sel1[2] =  |resp_match[5:4] ? 1'b0 : resp_match[6];

   assign  resp_mask[3:0] = {4{1'b0}}; 
   assign  resp_mask[6:4] = {3{|(resp_sel0)}}; 

   assign resp_sel = {resp_sel1,
                       resp_sel0} & ~resp_mask;

   assign hold_resp_match = (hold_aid == resp_id[1:0]) & (~|resp_sel)
                            & hold_valid & resp_valid & resp_ready;

   assign t_push = t_ready & ~hold_resp_match & hold_valid;

   assign id_match[0] = (spi_ids[0] == aid[1:0]);
   assign id_match[1] = (spi_ids[1] == aid[1:0]);
   assign id_match[2] = (spi_ids[2] == aid[1:0]);
   assign id_match[3] = (spi_ids[3] == aid[1:0]);
   assign id_match[4] = (spi_ids[4] == aid[1:0]);
   assign id_match[5] = (spi_ids[5] == aid[1:0]);
   assign id_match[6] = (spi_ids[6] == aid[1:0]);
   assign dest_match[0] = (spi_asel[0] == asel);
   assign dest_match[1] = (spi_asel[1] == asel);
   assign dest_match[2] = (spi_asel[2] == asel);
   assign dest_match[3] = (spi_asel[3] == asel);
   assign dest_match[4] = (spi_asel[4] == asel);
   assign dest_match[5] = (spi_asel[5] == asel);
   assign dest_match[6] = (spi_asel[6] == asel);

   assign cds_stall = |(id_match & ~dest_match & spi_valid) |
                      ((hold_aid == aid[1:0]) & (hold_asel != asel) & hold_valid);




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
         end
       else if ((add_push) || (resp_valid && resp_ready))
         begin
             tt_cnt <= next_tt_cnt;
         end
     end 



    always @(posedge aclk or negedge aresetn)
    begin : p_ptr_seq
      integer tt_ptr_val;
      if (!aresetn)
      begin
         spi_valid <= {7{1'b0}};
      end else
      begin
        if (t_push)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<7; tt_ptr_val=tt_ptr_val+1)
               if (free_slot[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b1;
               end
         end
        if (t_pop)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<7; tt_ptr_val=tt_ptr_val+1)
               if (resp_sel[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b0;
               end
         end
      end
    end 

   always @(posedge aclk or negedge aresetn)
    begin : p_stallr_seq
      if (!aresetn)
      begin
         t_ready <= 1'b0;
      end else
      begin
         t_ready <=  next_t_push;
      end
   end 

    always @(posedge aclk or negedge aresetn)
    begin : tt_hld_stl_seq
      if (!aresetn)
      begin
         hold_valid <= 1'b0;
      end else
      begin
        if (add_push)
        begin
           hold_valid <= 1'b1;
        end
        else if (t_ready | hold_resp_match)
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

   always @(posedge aclk)
    begin : p_tt_dat_seq
         integer tt_ptr;
         if (t_push)
          begin
                for (tt_ptr = 0; tt_ptr<7; tt_ptr=tt_ptr+1)
                if (free_slot[tt_ptr] == 1'b1)
                begin
                     spi_asel[tt_ptr] <= hold_asel;
                     spi_ids[tt_ptr] <= hold_aid;
                end
          end
   end 





   assign aw_enable = ~cds_stall;
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
                        7,
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

