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



module nic400_asib_expslv0_axis_rd_spi_cdas_sse710_main
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
    input  [9:0] asel;     
    input        avalid;
    input        aready;
    input  [7:0] aid;
    input        resp_valid;
    input        resp_last;
    input        resp_ready;
    input  [7:0] resp_id;
    input        aclk;
    input        aresetn;


  reg   [5:0]    next_tt_cnt;    
  wire           resp_pop;
  wire           tt_reg_enable;

  wire           add_push;   
  wire           t_pop;   
  wire           t_push;   
  wire           mask_push_pop;   
  wire  [47:0]   slots;   
  wire  [47:0]   free_slot;   
  wire  [3:0]    free_slot0;   
  wire  [3:0]    free_slot1;   
  wire  [3:0]    free_slot2;   
  wire  [3:0]    free_slot3;   
  wire  [3:0]    free_slot4;   
  wire  [3:0]    free_slot5;   
  wire  [3:0]    free_slot6;   
  wire  [3:0]    free_slot7;   
  wire  [3:0]    free_slot8;   
  wire  [3:0]    free_slot9;   
  wire  [3:0]    free_slot10;   
  wire  [3:0]    free_slot11;   
  wire  [47:0]    resp_sel;   
  wire  [3:0]    resp_sel0;   
  wire  [3:0]    resp_sel1;   
  wire  [3:0]    resp_sel2;   
  wire  [3:0]    resp_sel3;   
  wire  [3:0]    resp_sel4;   
  wire  [3:0]    resp_sel5;   
  wire  [3:0]    resp_sel6;   
  wire  [3:0]    resp_sel7;   
  wire  [3:0]    resp_sel8;   
  wire  [3:0]    resp_sel9;   
  wire  [3:0]    resp_sel10;   
  wire  [3:0]    resp_sel11;   
  wire  [47:0]    resp_mask;   
  wire  [47:0]    mask;   
  wire  [47:0]    id_match;    
  wire  [47:0]    dest_match;    
  wire  [47:0]    resp_match;    
  wire           cds_stall;    




  reg   [5:0]    tt_cnt;    
  reg   [9:0]    spi_asel [47:0];     
  reg   [7:0]    spi_ids [47:0];     
  reg   [47:0]    spi_valid;     
  reg   [9:0]    hold_asel;     
  reg            hold_valid;     
  reg   [7:0]    hold_aid;     
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

   assign next_full = (next_tt_cnt == 6'd48) ? 1'b1 : 1'b0;

   assign add_push = avalid & aready;
   assign t_pop = resp_valid & resp_ready & resp_last & ~mask_push_pop;

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
   assign free_slot4[3] =  |slots[18:16] ? 1'b0 : slots[19];
   assign free_slot5[0] =  slots[20];
   assign free_slot5[1] =  slots[20] ? 1'b0 : slots[21];
   assign free_slot5[2] =  |slots[21:20] ? 1'b0 : slots[22];
   assign free_slot5[3] =  |slots[22:20] ? 1'b0 : slots[23];
   assign free_slot6[0] =  slots[24];
   assign free_slot6[1] =  slots[24] ? 1'b0 : slots[25];
   assign free_slot6[2] =  |slots[25:24] ? 1'b0 : slots[26];
   assign free_slot6[3] =  |slots[26:24] ? 1'b0 : slots[27];
   assign free_slot7[0] =  slots[28];
   assign free_slot7[1] =  slots[28] ? 1'b0 : slots[29];
   assign free_slot7[2] =  |slots[29:28] ? 1'b0 : slots[30];
   assign free_slot7[3] =  |slots[30:28] ? 1'b0 : slots[31];
   assign free_slot8[0] =  slots[32];
   assign free_slot8[1] =  slots[32] ? 1'b0 : slots[33];
   assign free_slot8[2] =  |slots[33:32] ? 1'b0 : slots[34];
   assign free_slot8[3] =  |slots[34:32] ? 1'b0 : slots[35];
   assign free_slot9[0] =  slots[36];
   assign free_slot9[1] =  slots[36] ? 1'b0 : slots[37];
   assign free_slot9[2] =  |slots[37:36] ? 1'b0 : slots[38];
   assign free_slot9[3] =  |slots[38:36] ? 1'b0 : slots[39];
   assign free_slot10[0] =  slots[40];
   assign free_slot10[1] =  slots[40] ? 1'b0 : slots[41];
   assign free_slot10[2] =  |slots[41:40] ? 1'b0 : slots[42];
   assign free_slot10[3] =  |slots[42:40] ? 1'b0 : slots[43];
   assign free_slot11[0] =  slots[44];
   assign free_slot11[1] =  slots[44] ? 1'b0 : slots[45];
   assign free_slot11[2] =  |slots[45:44] ? 1'b0 : slots[46];
   assign free_slot11[3] =  |slots[46:44] ? 1'b0 : slots[47];

   assign  mask[3:0] = {4{1'b0}}; 
   assign  mask[7:4] = {4{|(free_slot0)}}; 
   assign  mask[11:8] = {4{|(free_slot0|free_slot1)}}; 
   assign  mask[15:12] = {4{|(free_slot0|free_slot1|free_slot2)}}; 
   assign  mask[19:16] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3)}}; 
   assign  mask[23:20] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4)}}; 
   assign  mask[27:24] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5)}}; 
   assign  mask[31:28] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5|free_slot6)}}; 
   assign  mask[35:32] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5|free_slot6|free_slot7)}}; 
   assign  mask[39:36] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5|free_slot6|free_slot7|free_slot8)}}; 
   assign  mask[43:40] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5|free_slot6|free_slot7|free_slot8|free_slot9)}}; 
   assign  mask[47:44] = {4{|(free_slot0|free_slot1|free_slot2|free_slot3|free_slot4|free_slot5|free_slot6|free_slot7|free_slot8|free_slot9|free_slot10)}}; 

   assign free_slot = {free_slot11,
                       free_slot10,
                       free_slot9,
                       free_slot8,
                       free_slot7,
                       free_slot6,
                       free_slot5,
                       free_slot4,
                       free_slot3,
                       free_slot2,
                       free_slot1,
                       free_slot0} & ~mask;

   assign resp_match[0] = ((spi_ids[0]  == resp_id[7:0]) &&
                            spi_valid[0]);
   assign resp_match[1] = ((spi_ids[1]  == resp_id[7:0]) &&
                            spi_valid[1]);
   assign resp_match[2] = ((spi_ids[2]  == resp_id[7:0]) &&
                            spi_valid[2]);
   assign resp_match[3] = ((spi_ids[3]  == resp_id[7:0]) &&
                            spi_valid[3]);
   assign resp_match[4] = ((spi_ids[4]  == resp_id[7:0]) &&
                            spi_valid[4]);
   assign resp_match[5] = ((spi_ids[5]  == resp_id[7:0]) &&
                            spi_valid[5]);
   assign resp_match[6] = ((spi_ids[6]  == resp_id[7:0]) &&
                            spi_valid[6]);
   assign resp_match[7] = ((spi_ids[7]  == resp_id[7:0]) &&
                            spi_valid[7]);
   assign resp_match[8] = ((spi_ids[8]  == resp_id[7:0]) &&
                            spi_valid[8]);
   assign resp_match[9] = ((spi_ids[9]  == resp_id[7:0]) &&
                            spi_valid[9]);
   assign resp_match[10] = ((spi_ids[10]  == resp_id[7:0]) &&
                            spi_valid[10]);
   assign resp_match[11] = ((spi_ids[11]  == resp_id[7:0]) &&
                            spi_valid[11]);
   assign resp_match[12] = ((spi_ids[12]  == resp_id[7:0]) &&
                            spi_valid[12]);
   assign resp_match[13] = ((spi_ids[13]  == resp_id[7:0]) &&
                            spi_valid[13]);
   assign resp_match[14] = ((spi_ids[14]  == resp_id[7:0]) &&
                            spi_valid[14]);
   assign resp_match[15] = ((spi_ids[15]  == resp_id[7:0]) &&
                            spi_valid[15]);
   assign resp_match[16] = ((spi_ids[16]  == resp_id[7:0]) &&
                            spi_valid[16]);
   assign resp_match[17] = ((spi_ids[17]  == resp_id[7:0]) &&
                            spi_valid[17]);
   assign resp_match[18] = ((spi_ids[18]  == resp_id[7:0]) &&
                            spi_valid[18]);
   assign resp_match[19] = ((spi_ids[19]  == resp_id[7:0]) &&
                            spi_valid[19]);
   assign resp_match[20] = ((spi_ids[20]  == resp_id[7:0]) &&
                            spi_valid[20]);
   assign resp_match[21] = ((spi_ids[21]  == resp_id[7:0]) &&
                            spi_valid[21]);
   assign resp_match[22] = ((spi_ids[22]  == resp_id[7:0]) &&
                            spi_valid[22]);
   assign resp_match[23] = ((spi_ids[23]  == resp_id[7:0]) &&
                            spi_valid[23]);
   assign resp_match[24] = ((spi_ids[24]  == resp_id[7:0]) &&
                            spi_valid[24]);
   assign resp_match[25] = ((spi_ids[25]  == resp_id[7:0]) &&
                            spi_valid[25]);
   assign resp_match[26] = ((spi_ids[26]  == resp_id[7:0]) &&
                            spi_valid[26]);
   assign resp_match[27] = ((spi_ids[27]  == resp_id[7:0]) &&
                            spi_valid[27]);
   assign resp_match[28] = ((spi_ids[28]  == resp_id[7:0]) &&
                            spi_valid[28]);
   assign resp_match[29] = ((spi_ids[29]  == resp_id[7:0]) &&
                            spi_valid[29]);
   assign resp_match[30] = ((spi_ids[30]  == resp_id[7:0]) &&
                            spi_valid[30]);
   assign resp_match[31] = ((spi_ids[31]  == resp_id[7:0]) &&
                            spi_valid[31]);
   assign resp_match[32] = ((spi_ids[32]  == resp_id[7:0]) &&
                            spi_valid[32]);
   assign resp_match[33] = ((spi_ids[33]  == resp_id[7:0]) &&
                            spi_valid[33]);
   assign resp_match[34] = ((spi_ids[34]  == resp_id[7:0]) &&
                            spi_valid[34]);
   assign resp_match[35] = ((spi_ids[35]  == resp_id[7:0]) &&
                            spi_valid[35]);
   assign resp_match[36] = ((spi_ids[36]  == resp_id[7:0]) &&
                            spi_valid[36]);
   assign resp_match[37] = ((spi_ids[37]  == resp_id[7:0]) &&
                            spi_valid[37]);
   assign resp_match[38] = ((spi_ids[38]  == resp_id[7:0]) &&
                            spi_valid[38]);
   assign resp_match[39] = ((spi_ids[39]  == resp_id[7:0]) &&
                            spi_valid[39]);
   assign resp_match[40] = ((spi_ids[40]  == resp_id[7:0]) &&
                            spi_valid[40]);
   assign resp_match[41] = ((spi_ids[41]  == resp_id[7:0]) &&
                            spi_valid[41]);
   assign resp_match[42] = ((spi_ids[42]  == resp_id[7:0]) &&
                            spi_valid[42]);
   assign resp_match[43] = ((spi_ids[43]  == resp_id[7:0]) &&
                            spi_valid[43]);
   assign resp_match[44] = ((spi_ids[44]  == resp_id[7:0]) &&
                            spi_valid[44]);
   assign resp_match[45] = ((spi_ids[45]  == resp_id[7:0]) &&
                            spi_valid[45]);
   assign resp_match[46] = ((spi_ids[46]  == resp_id[7:0]) &&
                            spi_valid[46]);
   assign resp_match[47] = ((spi_ids[47]  == resp_id[7:0]) &&
                            spi_valid[47]);


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
   assign resp_sel4[3] =  |resp_match[18:16] ? 1'b0 : resp_match[19];
   assign resp_sel5[0] =  resp_match[20];
   assign resp_sel5[1] =  resp_match[20] ? 1'b0 : resp_match[21];
   assign resp_sel5[2] =  |resp_match[21:20] ? 1'b0 : resp_match[22];
   assign resp_sel5[3] =  |resp_match[22:20] ? 1'b0 : resp_match[23];
   assign resp_sel6[0] =  resp_match[24];
   assign resp_sel6[1] =  resp_match[24] ? 1'b0 : resp_match[25];
   assign resp_sel6[2] =  |resp_match[25:24] ? 1'b0 : resp_match[26];
   assign resp_sel6[3] =  |resp_match[26:24] ? 1'b0 : resp_match[27];
   assign resp_sel7[0] =  resp_match[28];
   assign resp_sel7[1] =  resp_match[28] ? 1'b0 : resp_match[29];
   assign resp_sel7[2] =  |resp_match[29:28] ? 1'b0 : resp_match[30];
   assign resp_sel7[3] =  |resp_match[30:28] ? 1'b0 : resp_match[31];
   assign resp_sel8[0] =  resp_match[32];
   assign resp_sel8[1] =  resp_match[32] ? 1'b0 : resp_match[33];
   assign resp_sel8[2] =  |resp_match[33:32] ? 1'b0 : resp_match[34];
   assign resp_sel8[3] =  |resp_match[34:32] ? 1'b0 : resp_match[35];
   assign resp_sel9[0] =  resp_match[36];
   assign resp_sel9[1] =  resp_match[36] ? 1'b0 : resp_match[37];
   assign resp_sel9[2] =  |resp_match[37:36] ? 1'b0 : resp_match[38];
   assign resp_sel9[3] =  |resp_match[38:36] ? 1'b0 : resp_match[39];
   assign resp_sel10[0] =  resp_match[40];
   assign resp_sel10[1] =  resp_match[40] ? 1'b0 : resp_match[41];
   assign resp_sel10[2] =  |resp_match[41:40] ? 1'b0 : resp_match[42];
   assign resp_sel10[3] =  |resp_match[42:40] ? 1'b0 : resp_match[43];
   assign resp_sel11[0] =  resp_match[44];
   assign resp_sel11[1] =  resp_match[44] ? 1'b0 : resp_match[45];
   assign resp_sel11[2] =  |resp_match[45:44] ? 1'b0 : resp_match[46];
   assign resp_sel11[3] =  |resp_match[46:44] ? 1'b0 : resp_match[47];

   assign  resp_mask[3:0] = {4{1'b0}}; 
   assign  resp_mask[7:4] = {4{|(resp_sel0)}}; 
   assign  resp_mask[11:8] = {4{|(resp_sel0|resp_sel1)}}; 
   assign  resp_mask[15:12] = {4{|(resp_sel0|resp_sel1|resp_sel2)}}; 
   assign  resp_mask[19:16] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3)}}; 
   assign  resp_mask[23:20] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4)}}; 
   assign  resp_mask[27:24] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5)}}; 
   assign  resp_mask[31:28] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5|resp_sel6)}}; 
   assign  resp_mask[35:32] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5|resp_sel6|resp_sel7)}}; 
   assign  resp_mask[39:36] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5|resp_sel6|resp_sel7|resp_sel8)}}; 
   assign  resp_mask[43:40] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5|resp_sel6|resp_sel7|resp_sel8|resp_sel9)}}; 
   assign  resp_mask[47:44] = {4{|(resp_sel0|resp_sel1|resp_sel2|resp_sel3|resp_sel4|resp_sel5|resp_sel6|resp_sel7|resp_sel8|resp_sel9|resp_sel10)}}; 

   assign resp_sel = {resp_sel11,
                       resp_sel10,
                       resp_sel9,
                       resp_sel8,
                       resp_sel7,
                       resp_sel6,
                       resp_sel5,
                       resp_sel4,
                       resp_sel3,
                       resp_sel2,
                       resp_sel1,
                       resp_sel0} & ~resp_mask;

   assign mask_push_pop = (hold_aid == resp_id) & t_ready
                       & resp_valid & resp_ready & resp_last;
   assign t_push = t_ready & ~mask_push_pop;



   assign id_match[0] = (spi_ids[0] == aid[7:0]);
   assign id_match[1] = (spi_ids[1] == aid[7:0]);
   assign id_match[2] = (spi_ids[2] == aid[7:0]);
   assign id_match[3] = (spi_ids[3] == aid[7:0]);
   assign id_match[4] = (spi_ids[4] == aid[7:0]);
   assign id_match[5] = (spi_ids[5] == aid[7:0]);
   assign id_match[6] = (spi_ids[6] == aid[7:0]);
   assign id_match[7] = (spi_ids[7] == aid[7:0]);
   assign id_match[8] = (spi_ids[8] == aid[7:0]);
   assign id_match[9] = (spi_ids[9] == aid[7:0]);
   assign id_match[10] = (spi_ids[10] == aid[7:0]);
   assign id_match[11] = (spi_ids[11] == aid[7:0]);
   assign id_match[12] = (spi_ids[12] == aid[7:0]);
   assign id_match[13] = (spi_ids[13] == aid[7:0]);
   assign id_match[14] = (spi_ids[14] == aid[7:0]);
   assign id_match[15] = (spi_ids[15] == aid[7:0]);
   assign id_match[16] = (spi_ids[16] == aid[7:0]);
   assign id_match[17] = (spi_ids[17] == aid[7:0]);
   assign id_match[18] = (spi_ids[18] == aid[7:0]);
   assign id_match[19] = (spi_ids[19] == aid[7:0]);
   assign id_match[20] = (spi_ids[20] == aid[7:0]);
   assign id_match[21] = (spi_ids[21] == aid[7:0]);
   assign id_match[22] = (spi_ids[22] == aid[7:0]);
   assign id_match[23] = (spi_ids[23] == aid[7:0]);
   assign id_match[24] = (spi_ids[24] == aid[7:0]);
   assign id_match[25] = (spi_ids[25] == aid[7:0]);
   assign id_match[26] = (spi_ids[26] == aid[7:0]);
   assign id_match[27] = (spi_ids[27] == aid[7:0]);
   assign id_match[28] = (spi_ids[28] == aid[7:0]);
   assign id_match[29] = (spi_ids[29] == aid[7:0]);
   assign id_match[30] = (spi_ids[30] == aid[7:0]);
   assign id_match[31] = (spi_ids[31] == aid[7:0]);
   assign id_match[32] = (spi_ids[32] == aid[7:0]);
   assign id_match[33] = (spi_ids[33] == aid[7:0]);
   assign id_match[34] = (spi_ids[34] == aid[7:0]);
   assign id_match[35] = (spi_ids[35] == aid[7:0]);
   assign id_match[36] = (spi_ids[36] == aid[7:0]);
   assign id_match[37] = (spi_ids[37] == aid[7:0]);
   assign id_match[38] = (spi_ids[38] == aid[7:0]);
   assign id_match[39] = (spi_ids[39] == aid[7:0]);
   assign id_match[40] = (spi_ids[40] == aid[7:0]);
   assign id_match[41] = (spi_ids[41] == aid[7:0]);
   assign id_match[42] = (spi_ids[42] == aid[7:0]);
   assign id_match[43] = (spi_ids[43] == aid[7:0]);
   assign id_match[44] = (spi_ids[44] == aid[7:0]);
   assign id_match[45] = (spi_ids[45] == aid[7:0]);
   assign id_match[46] = (spi_ids[46] == aid[7:0]);
   assign id_match[47] = (spi_ids[47] == aid[7:0]);
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
   assign dest_match[19] = (spi_asel[19] == asel);
   assign dest_match[20] = (spi_asel[20] == asel);
   assign dest_match[21] = (spi_asel[21] == asel);
   assign dest_match[22] = (spi_asel[22] == asel);
   assign dest_match[23] = (spi_asel[23] == asel);
   assign dest_match[24] = (spi_asel[24] == asel);
   assign dest_match[25] = (spi_asel[25] == asel);
   assign dest_match[26] = (spi_asel[26] == asel);
   assign dest_match[27] = (spi_asel[27] == asel);
   assign dest_match[28] = (spi_asel[28] == asel);
   assign dest_match[29] = (spi_asel[29] == asel);
   assign dest_match[30] = (spi_asel[30] == asel);
   assign dest_match[31] = (spi_asel[31] == asel);
   assign dest_match[32] = (spi_asel[32] == asel);
   assign dest_match[33] = (spi_asel[33] == asel);
   assign dest_match[34] = (spi_asel[34] == asel);
   assign dest_match[35] = (spi_asel[35] == asel);
   assign dest_match[36] = (spi_asel[36] == asel);
   assign dest_match[37] = (spi_asel[37] == asel);
   assign dest_match[38] = (spi_asel[38] == asel);
   assign dest_match[39] = (spi_asel[39] == asel);
   assign dest_match[40] = (spi_asel[40] == asel);
   assign dest_match[41] = (spi_asel[41] == asel);
   assign dest_match[42] = (spi_asel[42] == asel);
   assign dest_match[43] = (spi_asel[43] == asel);
   assign dest_match[44] = (spi_asel[44] == asel);
   assign dest_match[45] = (spi_asel[45] == asel);
   assign dest_match[46] = (spi_asel[46] == asel);
   assign dest_match[47] = (spi_asel[47] == asel);

   assign cds_stall =  (|(id_match & ~dest_match & spi_valid) |
                       ((hold_aid == aid[7:0]) & ~(hold_asel == asel) & hold_valid));



   assign tt_reg_enable = ((|asel && avalid && aready)
                           || (resp_valid && resp_last && resp_ready));



   always @(posedge aclk or negedge aresetn)
     begin : p_tt_seq
       if (!aresetn)
         begin
             tt_cnt <= {6{1'b0}};
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
           spi_valid <= {48{1'b0}};
      end else
      begin
       if (t_push)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<48; tt_ptr_val=tt_ptr_val+1)
               if (free_slot[tt_ptr_val] == 1'b1)
               begin
                  spi_valid[tt_ptr_val] <= 1'b1;
               end
         end
        if (t_pop)
         begin
             for (tt_ptr_val = 0; tt_ptr_val<48; tt_ptr_val=tt_ptr_val+1)
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
                for (tt_ptr = 0; tt_ptr<48; tt_ptr=tt_ptr+1)
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
           hold_aid   <= aid[7:0];
        end
      end
   end 






   assign ar_enable = ~cds_stall & ~full;




`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"

  assert_no_overflow #(
                       `OVL_FATAL,
                       6,
                       0,
                       48,
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
                        6,
                        0,
                        48,
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

