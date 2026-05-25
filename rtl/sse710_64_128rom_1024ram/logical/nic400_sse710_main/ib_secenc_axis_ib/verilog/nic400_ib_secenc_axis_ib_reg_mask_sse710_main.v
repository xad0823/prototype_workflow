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




module nic400_ib_secenc_axis_ib_reg_mask_sse710_main
  (
      aclk,
      aresetn,
      pclken,
      data_in,
      rd_read_qos,
      wr_read_qos,ar_qos,
      rd_write_qos,
      wr_write_qos,aw_qos,
      rd_fn_mod,
      wr_fn_mod,fn_mod,
       
      ar_qos_int,
      aw_qos_int,
      fn_mod_int,
      data_out_mask
   );

input         aclk;   
input         aresetn;   
input         pclken;   
input  [31:0] data_in;   
input         rd_read_qos;   
input         wr_read_qos;   
input   [3:0] ar_qos;   
input         rd_write_qos;   
input         wr_write_qos;   
input   [3:0] aw_qos;   
input         rd_fn_mod;   
input         wr_fn_mod;   
input   [1:0] fn_mod;   

output [3:0] ar_qos_int;   
output [3:0] aw_qos_int;   
output [1:0] fn_mod_int;   
output [31:0] data_out_mask;  




wire [31:0] data_out_read_qos;  
wire [31:0] register_read_qos;  
wire [31:0] data_out_write_qos;  
wire [31:0] register_write_qos;  
wire [31:0] data_out_fn_mod;  
wire [31:0] register_fn_mod;  
wire [31:0] data_out_mask; 



reg   [3:0] ar_qos_int;  
reg   [3:0] aw_qos_int;  
reg   [1:0] fn_mod_int;  





       always@(posedge aclk or negedge aresetn)
       begin
       if(aresetn == 1'b0)
       begin
         ar_qos_int <= 4'h0;
         end
       else if (wr_read_qos == 1'b1 && pclken == 1'b1)
       begin
         ar_qos_int <= data_in[3:0] ;
         end
       end 
       
       assign register_read_qos[3:0]  = ar_qos;
       assign register_read_qos[31:4]  = {28{1'b0}};

       always@(posedge aclk or negedge aresetn)
       begin
       if(aresetn == 1'b0)
       begin
         aw_qos_int <= 4'h0;
         end
       else if (wr_write_qos == 1'b1 && pclken == 1'b1)
       begin
         aw_qos_int <= data_in[3:0] ;
         end
       end 
       
       assign register_write_qos[3:0]  = aw_qos;
       assign register_write_qos[31:4]  = {28{1'b0}};

       always@(posedge aclk or negedge aresetn)
       begin
       if(aresetn == 1'b0)
       begin
         fn_mod_int <= 2'h0;
         end
       else if (wr_fn_mod == 1'b1 && pclken == 1'b1)
       begin
         fn_mod_int <= data_in[1:0] ;
         end
       end 
       
       assign register_fn_mod[1:0]  = fn_mod;
       assign register_fn_mod[31:2]  = {30{1'b0}};
 



assign data_out_read_qos = {32{rd_read_qos}} & register_read_qos;
    
assign data_out_write_qos = {32{rd_write_qos}} & register_write_qos;
    
assign data_out_fn_mod = {32{rd_fn_mod}} & register_fn_mod;
     



assign data_out_mask = (
       data_out_read_qos | 
       data_out_write_qos | 
       data_out_fn_mod );


endmodule



