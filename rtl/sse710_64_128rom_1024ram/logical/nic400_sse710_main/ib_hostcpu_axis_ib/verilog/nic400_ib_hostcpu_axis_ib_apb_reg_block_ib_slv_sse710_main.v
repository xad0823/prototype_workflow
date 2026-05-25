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

`include "nic400_ib_hostcpu_axis_ib_defs_sse710_main.v"

module nic400_ib_hostcpu_axis_ib_apb_reg_block_ib_slv_sse710_main (
      aclk,
      aresetn,
      pclken,
      addr,
      enable,
      write,
      wr_strb,
      data_in,
      
      bypass_merge_reg,
      fn_mod_lb_reg,
      data_out,
      decode_match
   );

input        aclk;   
input        aresetn;   
input        pclken;   
input [12:2] addr;   
input        enable;   
input        write;   
input        wr_strb;   
input  [31:0] data_in;   

output       bypass_merge_reg;   
output       fn_mod_lb_reg;   
output [31:0] data_out;   

output  decode_match;


wire         rd_ib_slv;  
wire         rd_fn_mod2;  
wire         wr_fn_mod2;  
wire         rd_fn_mod_lb;  
wire         wr_fn_mod_lb;  
 
wire         decode_match;

wire  [31:0] data_out_ib_slv;  
wire  [31:0] data_out_id;  

wire         bypass_merge_int; 
wire         fn_mod_lb_int; 




nic400_ib_hostcpu_axis_ib_reg_ib_slv_sse710_main u_reg_ib_slv(
      .aclk (aclk),
      .aresetn  (aresetn),
      .pclken  (pclken),
      .data_in  (data_in),
      .rd_fn_mod2   (rd_fn_mod2),
      .wr_fn_mod2   (wr_fn_mod2),
      .bypass_merge   (bypass_merge_int),
      .rd_fn_mod_lb   (rd_fn_mod_lb),
      .wr_fn_mod_lb   (wr_fn_mod_lb),
      .fn_mod_lb   (fn_mod_lb_int),
       
      .bypass_merge_int   (bypass_merge_int),
      .fn_mod_lb_int   (fn_mod_lb_int),
      .data_out_ib_slv   (data_out_ib_slv)
   );

assign bypass_merge_reg = bypass_merge_int;
assign fn_mod_lb_reg = fn_mod_lb_int;
nic400_ib_hostcpu_axis_ib_apb_decode_ib_slv_sse710_main u_ib_hostcpu_axis_ib_apb_decode (
      .addr   (addr),
      .enable   (enable),
      .write   (write),
      .wr_strb  (wr_strb),

      .rd_ib_slv   (rd_ib_slv),.rd_fn_mod2   (rd_fn_mod2),
      .wr_fn_mod2   (wr_fn_mod2),
      .rd_fn_mod_lb   (rd_fn_mod_lb),
      .wr_fn_mod_lb   (wr_fn_mod_lb),
       
      .decode_match    (decode_match)
   );

nic400_ib_hostcpu_axis_ib_data_out_mux_ib_slv_sse710_main u_ib_hostcpu_axis_ib_data_out_mux (
      .rd_ib_slv   (rd_ib_slv),
      .data_out_ib_slv   (data_out_ib_slv),
      
      .data_out   (data_out)
   );




`ifdef ARM_ASSERT_ON
 


wire test_valid;
assign test_valid = (
        rd_fn_mod2 | 
        wr_fn_mod2 | 
        rd_fn_mod_lb | 
        wr_fn_mod_lb
        );
      
      


assert_implication #(1,0,"WARNING, Register Read Access Outside Valid Region")
ovl_assert_invalid_rd_region
   (
    .clk              (aclk),
    .reset_n          (aresetn),
    .antecedent_expr  (test_valid && !write),
    .consequent_expr  (enable));

assert_implication #(1,0,"WARNING, Register Write Access Outside Valid Region")
ovl_assert_invalid_wr_region
   (
    .clk              (aclk),
    .reset_n          (aresetn),
    .antecedent_expr  (test_valid && write),
    .consequent_expr  (enable));



wire [11:0] test_regs;
assign test_regs = {
        rd_fn_mod2, 
        wr_fn_mod2, 
        rd_fn_mod_lb, 
        wr_fn_mod_lb
      };
      
      
      

   assert_zero_one_hot #(0,12,0,"More than one reg access being carried out")
   ovl_multi_reg_access
      (
       .clk       (aclk),
       .reset_n   (aresetn),
       .test_expr (test_regs));


  wire ovl_wrong_value = (
 (wr_fn_mod2 & (
      (1'b0)
 ))
| 
 (wr_fn_mod_lb & (
      (1'b0)
 ))
|  (1'b0));

   assert_never #(2,1,"Illegal value written to register")
   ovl_wrong_value_reg
      (
       .clk       (aclk),
       .reset_n   (aresetn),
       .test_expr (ovl_wrong_value));

`endif 

endmodule
`include "nic400_ib_hostcpu_axis_ib_undefs_sse710_main.v"

