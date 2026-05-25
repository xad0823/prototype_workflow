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




module nic400_asib_sysperi_axis_wr_spi_cdas_sse710_sys_apb
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
    input  [6:0] asel;     
    input        avalid;     
    input        aready;     
    input  [11:0] aid;
    input        wvalid;     
    input        wready;     
    input        wlast;     
    input        resp_valid;
    input        resp_ready;
    input  [11:0]      resp_id;
    input        aclk;
    input        aresetn;


  reg   [4:0]    next_last_cnt;    
  wire           next_valid_add;     
  reg   [4:0]    next_tt_cnt;    
  wire           t_pop;   
  wire           avalid_mask;   
  wire           next_t_push;   
  wire           hold_resp_match;   
  wire  [18:0]    slots;   
  wire  [18:0]    free_slot;   
  wire  [3:0]    free_slot0;   
  wire  [3:0]    free_slot1;   
  wire  [3:0]    free_slot2;   
  wire  [3:0]    free_slot3;   
  wire  [2:0]    free_slot4;   
  wire  [18:0]    resp_sel;   
  wire  [3:0]    resp_sel0;   
  wire  [3:0]    resp_sel1;   
  wire  [3:0]    resp_sel2;   
  wire  [3:0]    resp_sel3;   
  wire  [2:0]    resp_sel4;   
  wire  [18:0]    resp_mask;   
  wire  [18:0]    mask;   
  wire  [18:0]    id_match;   
  wire  [18:0]    dest_match;   
  wire  [18:0]    resp_match;   
  wire           cds_stall;    
  wire           t_push;     

  wire           add_push;   
  wire           resp_pop;   


  reg            valid_add;   
  reg   [4:0]    last_cnt;   
  reg            asel_reg;   
  reg            aready_reg;   
  reg   [4:0]    tt_cnt;   
  reg   [6:0]    spi_asel [18:0];   
  reg   [11:0]    spi_ids [18:0];   
  reg   [18:0]    spi_valid;   
  reg   [6:0]    hold_asel;   
  reg   [11:0]    hold_aid;   
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
   assign free_slot1[3] =  |slots[6:4] ? 1'b0 : slots[7];
   assign free_slot2[0] =  slots[8];
   assign free_slot2[1] =  slots[8] ? 1'b0 : slots[9];
   assign free_slot2[2] =  |slots[9:8] ? 1'b0 : slots[10];
   assign free_slot2[3] =  |slots[10:8] ? 1'b0 : slots[11];
   assign free_slot3[0] =  slots[12];
   assign free_slot3[1] =  slots[12] ? 1'b0 : slots[13];
   assign free_slot3[2] =  |slots[13:12] ? 1'b0 : slots[14];
   assign free_slot3[3] =  |slots[14:12] ? 1'b0 : slots[15];
   assign free_slot4[0] =  slots[16];
   assign free_slot4[1] =  slots[16] ? 1'b0 : slots[17];
   assign free_slot4[2] =  |slots[17:16] ? 1'b0 : slots[18];

   assign  mask[3:0] = {4{1'b0}}; 
   assign  mask[7:4] = {4{|(free_slot0)}}; 
   assign  mask[11:8] = {4{|(free_slot0|free_slot1)}}; 
   assign  mask[15:12] = {4{|(free_slot0|free_slot1|free_slot2)}}; 
   assign  mask[18:16] = {3{|(free_slot0|free_slot1|free_slot2|free_slot3)}}; 

   assign free_slot = {free_slot4,
                       free_slot3,
                       free_slot2,
                       free_slot1,
                       free_slot0} & ~mask;

   assign resp_match[0] = ((spi_ids[0]  == resp_id[11:0]) &&
                            spi_valid[0]);
   assign resp_match[1] = ((spi_ids[1]  == resp_id[11:0]) &&
                            spi_valid[1]);
   assign resp_match[2] = ((spi_ids[2]  == resp_id[11:0]) &&
                            spi_valid[2]);
   assign resp_match[3] = ((spi_ids[3]  == resp_id[11:0]) &&
                            spi_valid[3]);
   assign resp_match[4] = ((spi_ids[4]  == resp_id[11:0]) &&
                            spi_valid[4]);
   assign resp_match[5] = ((spi_ids[5]  == resp_id[11:0]) &&
                            spi_valid[5]);
   assign resp_match[6] = ((spi_ids[6]  == resp_id[11:0]) &&
                            spi_valid[6]);
   assign resp_match[7] = ((spi_ids[7]  == resp_id[11:0]) &&
                            spi_valid[7]);
   assign resp_match[8] = ((spi_ids[8]  == resp_id[11:0]) &&
                            spi_valid[8]);
   assign resp_match[9] = ((spi_ids[9]  == resp_id[11:0]) &&
                            spi_valid[9]);
   assign resp_match[10] = ((spi_ids[10]  == resp_id[11:0]) &&
                            spi_valid[10]);
   assign resp_match[11] = ((spi_ids[11]  == resp_id[11:0]) &&
                            spi_valid[11]);
   assign resp_match[12] = ((spi_ids[12]  == resp_id[11:0]) &&
                            spi_valid[12]);
   assign resp_match[13] = ((spi_ids[13]  == resp_id[11:0]) &&
                            spi_valid[13]);
   assign resp_match[14] = ((spi_ids[14]  == resp_id[11:0]) &&
                            spi_valid[14]);
   assign resp_match[15] = ((spi_ids[15]  == resp_id[11:0]) &&
                            spi_valid[15]);
   assign resp_match[16] = ((spi_ids[16]  == resp_id[11:0]) &&
                            spi_valid[16]);
   assign resp_match[17] = ((spi_ids[17]  == resp_id[11:0]) &&
                            spi_valid[17]);
   assign resp_match[18] = ((spi_ids[18]  == resp_id[11:0]) &&
                            spi_valid[18]);


   assign resp_sel0[0] =  resp_match[0];
   assign resp_sel0[1] =  resp_match[0] ? 1'b0 : resp_match[1];
   assign resp_sel0[2] =  |resp_match[1:0] ? 1'b0 : resp_match[2];
   assign resp_sel0[3] =  |resp_match[2:0] ? 1'b0 : resp_match[3];
   assign resp_sel1[0] =  resp_match[4];
   assign resp_sel1[1] =  resp_match[4] ? 1'b0 : resp_match[5];
   assign resp_sel1[2] =  |resp_match[5:4] ? 1'b0 : resp_match[6];
   assign resp_sel1[3] =  |resp_match[6:4] ? 1'b0 : resp_match[7];
   assign resp_sel2[0] =  resp_match[8];
   assign resp_sel2[1] =  resp_match[8] ? 1'b0 : resp_match[9];
   assign resp_sel2[2] =  |resp_match[9:8] ? 1'b0 : resp_match[10];
   assign resp_sel2[3] =  |resp_match[10:8] ? 1'b0 : resp_match[11];
   assign resp_sel3[0] =  resp_match[12];
   assign resp_sel3[1] =  resp_match[12] ? 1'b0 : resp_match[13];
   assign resp_sel3[2] =  |resp_match[13:12] ? 1'b0 : resp_match[14];
   assign resp_sel3[3] =  |resp_match[14:12] ? 1'b0 : resp_match[15];
   assign resp_sel4[0] =  resp_match[16];
   assign resp_sel4[1] =  resp_match[16] ? 1'b0 : resp_match[17];
   assign resp_sel4[2] =  |resp_match[17:16] ? 1'b0 : resp_match[18];

   assign  resp_mask[3:0] = {4{1'b0}}; 
   assign  resp_mask[7:4] = {4{|(resp_sel0)}}; 
   assign  resp_mask[11:8] = {4{|(resp_sel0|resp_sel1)}}; 
   assign  resp_mask[15:12] = {4{|(resp_sel0|resp_sel1|resp_sel2)}}; 
   assign  resp_mask[18:16] = {3{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3)}}; 

   assign resp_sel = {resp_sel4,
                       resp_sel3,
                       resp_sel2,
                       resp_sel1,
                       resp_sel0} & ~resp_mask;

   assign hold_resp_match = (hold_aid == resp_id[11:0]) & (~|resp_sel)
                            & hold_valid & resp_valid & resp_ready;

   assign t_push = t_ready & ~hold_resp_match & hold_valid;

   assign id_match[0] = (spi_ids[0] == aid[11:0]);
   assign id_match[1] = (spi_ids[1] == aid[11:0]);
   assign id_match[2] = (spi_ids[2] == aid[11:0]);
   assign id_match[3] = (spi_ids[3] == aid[11:0]);
   assign id_match[4] = (spi_ids[4] == aid[11:0]);
   assign id_match[5] = (spi_ids[5] == aid[11:0]);
   assign id_match[6] = (spi_ids[6] == aid[11:0]);
   assign id_match[7] = (spi_ids[7] == aid[11:0]);
   assign id_match[8] = (spi_ids[8] == aid[11:0]);
   assign id_match[9] = (spi_ids[9] == aid[11:0]);
   assign id_match[10] = (spi_ids[10] == aid[11:0]);
   assign id_match[11] = (spi_ids[11] == aid[11:0]);
   assign id_match[12] = (spi_ids[12] == aid[11:0]);
   assign id_match[13] = (spi_ids[13] == aid[11:0]);
   assign id_match[14] = (spi_ids[14] == aid[11:0]);
   assign id_match[15] = (spi_ids[15] == aid[11:0]);
   assign id_match[16] = (spi_ids[16] == aid[11:0]);
   assign id_match[17] = (spi_ids[17] == aid[11:0]);
   assign id_match[18] = (spi_ids[18] == aid[11:0]);
   assign dest_match[0] = (spi_asel[0] == asel);
   assign dest_match[1] = (spi_asel[1] == asel);
   assign dest_match[2] = (spi_asel[2] == asel);
   assign dest_match[3] = (spi_asel[3] == asel);
   assign dest_match[4] = (spi_asel[4] == asel);
   assign dest_match[5] = (spi_asel[5] == asel);
   assign dest_match[6] = (spi_asel[6] == asel);
   assign dest_match[7] = (spi_asel[7] == asel);
   assign dest_match[8] = (spi_asel[8] == asel);
   assign dest_match[9] = (spi_asel[9] == asel);
   assign dest_match[10] = (spi_asel[10] == asel);
   assign dest_match[11] = (spi_asel[11] == asel);
   assign dest_match[12] = (spi_asel[12] == asel);
   assign dest_match[13] = (spi_asel[13] == asel);
   assign dest_match[14] = (spi_asel[14] == asel);
   assign dest_match[15] = (spi_asel[15] == asel);
   assign dest_match[16] = (spi_asel[16] == asel);
   assign dest_match[17] = (spi_asel[17] == asel);
   assign dest_match[18] = (spi_asel[18] == asel);

   assign cds_stall = |(id_match & ~dest_match & spi_valid) |
                      ((hold_aid == aid[11:0]) & (hold_asel != asel) & hold_valid);




   assign next_valid_add = (next_tt_cnt > next_last_cnt);

   always @(posedge aclk or negedge aresetn)
     begin : p_tt_last_seq
       if (!aresetn) begin
                last_cnt <= {5{1'b0}};
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
             tt_cnt <= {5{1'b0}};
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
         spi_valid <= {19{1'b0}};
      end else
      begin
        if (t_push)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<19; tt_ptr_val=tt_ptr_val+1)
               if (free_slot[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b1;
               end
         end
        if (t_pop)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<19; tt_ptr_val=tt_ptr_val+1)
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
           hold_aid   <= aid[11:0];
        end
      end
   end 

   always @(posedge aclk)
    begin : p_tt_dat_seq
         integer tt_ptr;
         if (t_push)
          begin
                for (tt_ptr = 0; tt_ptr<19; tt_ptr=tt_ptr+1)
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
                       5,
                       0,
                       19,
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
                        5,
                        0,
                        19,
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

