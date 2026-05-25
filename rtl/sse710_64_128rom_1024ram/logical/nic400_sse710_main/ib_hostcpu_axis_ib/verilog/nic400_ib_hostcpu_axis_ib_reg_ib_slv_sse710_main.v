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



  

module nic400_ib_hostcpu_axis_ib_reg_ib_slv_sse710_main
  (
      aclk,
      aresetn,
      pclken,
      data_in,
      rd_fn_mod2,
      wr_fn_mod2,bypass_merge,
      rd_fn_mod_lb,
      wr_fn_mod_lb,fn_mod_lb,
       
      bypass_merge_int,
      fn_mod_lb_int,
      data_out_ib_slv
   );

input         aclk;   
input         aresetn;   
input         pclken;   
input  [31:0] data_in;   
input         rd_fn_mod2;   
input         wr_fn_mod2;   
input         bypass_merge;   
input         rd_fn_mod_lb;   
input         wr_fn_mod_lb;   
input         fn_mod_lb;   

output       bypass_merge_int;   
output       fn_mod_lb_int;   
output [31:0] data_out_ib_slv;  




wire [31:0] data_out_fn_mod2;  
wire [31:0] register_fn_mod2;  
wire [31:0] data_out_fn_mod_lb;  
wire [31:0] register_fn_mod_lb;  
wire [31:0] data_out_ib_slv; 



reg         bypass_merge_int;  
reg         fn_mod_lb_int;  





       always@(posedge aclk or negedge aresetn)
       begin
       if(aresetn == 1'b0)
       begin
         bypass_merge_int <= 1'b0;
         end
       else if (wr_fn_mod2 == 1'b1 && pclken == 1'b1)
       begin
         bypass_merge_int <= data_in[0] ;
         end
       end 
       
       assign register_fn_mod2[0]  = bypass_merge;
       assign register_fn_mod2[31:1]  = {31{1'b0}};

       always@(posedge aclk or negedge aresetn)
       begin
       if(aresetn == 1'b0)
       begin
         fn_mod_lb_int <= 1'b0;
         end
       else if (wr_fn_mod_lb == 1'b1 && pclken == 1'b1)
       begin
         fn_mod_lb_int <= data_in[0] ;
         end
       end 
       
       assign register_fn_mod_lb[0]  = fn_mod_lb;
       assign register_fn_mod_lb[31:1]  = {31{1'b0}};
 



assign data_out_fn_mod2 = {32{rd_fn_mod2}} & register_fn_mod2;
    
assign data_out_fn_mod_lb = {32{rd_fn_mod_lb}} & register_fn_mod_lb;
     



assign data_out_ib_slv = (
       data_out_fn_mod2 | 
       data_out_fn_mod_lb );


endmodule



