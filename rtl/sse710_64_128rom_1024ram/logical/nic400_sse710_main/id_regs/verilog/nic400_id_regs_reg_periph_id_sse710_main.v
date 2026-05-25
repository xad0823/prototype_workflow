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



module nic400_id_regs_reg_periph_id_sse710_main
  (
      aclk,
      aresetn,
      pclken,
      data_in,
      rd_periph_id_4,
      periph_id_4,
      rd_periph_id_5,
      periph_id_5,
      rd_periph_id_6,
      periph_id_6,
      rd_periph_id_7,
      periph_id_7,
      rd_periph_id_0,
      periph_id_0,
      rd_periph_id_1,
      periph_id_1,
      rd_periph_id_2,
      periph_id_2,
      rd_periph_id_3,
      cust_mod_num,
      rev_and,
      rd_comp_id_0,
      comp_id_0,
      rd_comp_id_1,
      comp_id_1,
      rd_comp_id_2,
      comp_id_2,
      rd_comp_id_3,
      comp_id_3,
       
      data_out_periph_id
   );

input         aclk;   
input         aresetn;   
input         pclken;   
input  [31:0] data_in;   
input         rd_periph_id_4;   
input   [7:0] periph_id_4;   
input         rd_periph_id_5;   
input   [7:0] periph_id_5;   
input         rd_periph_id_6;   
input   [7:0] periph_id_6;   
input         rd_periph_id_7;   
input   [7:0] periph_id_7;   
input         rd_periph_id_0;   
input   [7:0] periph_id_0;   
input         rd_periph_id_1;   
input   [7:0] periph_id_1;   
input         rd_periph_id_2;   
input   [7:0] periph_id_2;   
input         rd_periph_id_3;   
input   [3:0] cust_mod_num;   
input   [3:0] rev_and;   
input         rd_comp_id_0;   
input   [7:0] comp_id_0;   
input         rd_comp_id_1;   
input   [7:0] comp_id_1;   
input         rd_comp_id_2;   
input   [7:0] comp_id_2;   
input         rd_comp_id_3;   
input   [7:0] comp_id_3;   

output [31:0] data_out_periph_id;  




wire [31:0] data_out_periph_id_4;  
wire [31:0] register_periph_id_4;  
wire [31:0] data_out_periph_id_5;  
wire [31:0] register_periph_id_5;  
wire [31:0] data_out_periph_id_6;  
wire [31:0] register_periph_id_6;  
wire [31:0] data_out_periph_id_7;  
wire [31:0] register_periph_id_7;  
wire [31:0] data_out_periph_id_0;  
wire [31:0] register_periph_id_0;  
wire [31:0] data_out_periph_id_1;  
wire [31:0] register_periph_id_1;  
wire [31:0] data_out_periph_id_2;  
wire [31:0] register_periph_id_2;  
wire [31:0] data_out_periph_id_3;  
wire [31:0] register_periph_id_3;  
wire [31:0] data_out_comp_id_0;  
wire [31:0] register_comp_id_0;  
wire [31:0] data_out_comp_id_1;  
wire [31:0] register_comp_id_1;  
wire [31:0] data_out_comp_id_2;  
wire [31:0] register_comp_id_2;  
wire [31:0] data_out_comp_id_3;  
wire [31:0] register_comp_id_3;  
wire [31:0] data_out_periph_id; 


 





       assign register_periph_id_4[7:0]  = periph_id_4;
       assign register_periph_id_4[31:8]  = {24{1'b0}};

       assign register_periph_id_5[7:0]  = periph_id_5;
       assign register_periph_id_5[31:8]  = {24{1'b0}};

       assign register_periph_id_6[7:0]  = periph_id_6;
       assign register_periph_id_6[31:8]  = {24{1'b0}};

       assign register_periph_id_7[7:0]  = periph_id_7;
       assign register_periph_id_7[31:8]  = {24{1'b0}};

       assign register_periph_id_0[7:0]  = periph_id_0;
       assign register_periph_id_0[31:8]  = {24{1'b0}};

       assign register_periph_id_1[7:0]  = periph_id_1;
       assign register_periph_id_1[31:8]  = {24{1'b0}};

       assign register_periph_id_2[7:0]  = periph_id_2;
       assign register_periph_id_2[31:8]  = {24{1'b0}};

       assign register_periph_id_3[3:0]  = cust_mod_num;
       assign register_periph_id_3[7:4]  = rev_and;
       assign register_periph_id_3[31:8]  = {24{1'b0}};

       assign register_comp_id_0[7:0]  = comp_id_0;
       assign register_comp_id_0[31:8]  = {24{1'b0}};

       assign register_comp_id_1[7:0]  = comp_id_1;
       assign register_comp_id_1[31:8]  = {24{1'b0}};

       assign register_comp_id_2[7:0]  = comp_id_2;
       assign register_comp_id_2[31:8]  = {24{1'b0}};

       assign register_comp_id_3[7:0]  = comp_id_3;
       assign register_comp_id_3[31:8]  = {24{1'b0}};
 



assign data_out_periph_id_4 = {32{rd_periph_id_4}} & register_periph_id_4;
    
assign data_out_periph_id_5 = {32{rd_periph_id_5}} & register_periph_id_5;
    
assign data_out_periph_id_6 = {32{rd_periph_id_6}} & register_periph_id_6;
    
assign data_out_periph_id_7 = {32{rd_periph_id_7}} & register_periph_id_7;
    
assign data_out_periph_id_0 = {32{rd_periph_id_0}} & register_periph_id_0;
    
assign data_out_periph_id_1 = {32{rd_periph_id_1}} & register_periph_id_1;
    
assign data_out_periph_id_2 = {32{rd_periph_id_2}} & register_periph_id_2;
    
assign data_out_periph_id_3 = {32{rd_periph_id_3}} & register_periph_id_3;
    
assign data_out_comp_id_0 = {32{rd_comp_id_0}} & register_comp_id_0;
    
assign data_out_comp_id_1 = {32{rd_comp_id_1}} & register_comp_id_1;
    
assign data_out_comp_id_2 = {32{rd_comp_id_2}} & register_comp_id_2;
    
assign data_out_comp_id_3 = {32{rd_comp_id_3}} & register_comp_id_3;
     



assign data_out_periph_id = (
       data_out_periph_id_4 | 
       data_out_periph_id_5 | 
       data_out_periph_id_6 | 
       data_out_periph_id_7 | 
       data_out_periph_id_0 | 
       data_out_periph_id_1 | 
       data_out_periph_id_2 | 
       data_out_periph_id_3 | 
       data_out_comp_id_0 | 
       data_out_comp_id_1 | 
       data_out_comp_id_2 | 
       data_out_comp_id_3 );


endmodule


