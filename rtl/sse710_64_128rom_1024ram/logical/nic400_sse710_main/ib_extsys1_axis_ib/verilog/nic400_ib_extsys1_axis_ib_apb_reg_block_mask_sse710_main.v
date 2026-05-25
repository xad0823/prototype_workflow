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

`include "nic400_ib_extsys1_axis_ib_defs_sse710_main.v"

module nic400_ib_extsys1_axis_ib_apb_reg_block_mask_sse710_main (
      aclk,
      aresetn,
      pclken,
      addr,
      enable,
      write,
      wr_strb,
      data_in,
      
      ar_qos_reg,
      aw_qos_reg,
      fn_mod_reg,
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

output [3:0] ar_qos_reg;   
output [3:0] aw_qos_reg;   
output [1:0] fn_mod_reg;   
output [31:0] data_out;   

output  decode_match;


wire         rd_mask;  
wire         rd_read_qos;  
wire         wr_read_qos;  
wire         rd_write_qos;  
wire         wr_write_qos;  
wire         rd_fn_mod;  
wire         wr_fn_mod;  
 
wire         decode_match;

wire  [31:0] data_out_mask;  
wire  [31:0] data_out_id;  

wire   [3:0] ar_qos_int; 
wire   [3:0] aw_qos_int; 
wire   [1:0] fn_mod_int; 




nic400_ib_extsys1_axis_ib_reg_mask_sse710_main u_reg_mask(
      .aclk (aclk),
      .aresetn  (aresetn),
      .pclken  (pclken),
      .data_in  (data_in),
      .rd_read_qos   (rd_read_qos),
      .wr_read_qos   (wr_read_qos),
      .ar_qos   (ar_qos_int),
      .rd_write_qos   (rd_write_qos),
      .wr_write_qos   (wr_write_qos),
      .aw_qos   (aw_qos_int),
      .rd_fn_mod   (rd_fn_mod),
      .wr_fn_mod   (wr_fn_mod),
      .fn_mod   (fn_mod_int),
       
      .ar_qos_int   (ar_qos_int),
      .aw_qos_int   (aw_qos_int),
      .fn_mod_int   (fn_mod_int),
      .data_out_mask   (data_out_mask)
   );

assign ar_qos_reg = ar_qos_int;
assign aw_qos_reg = aw_qos_int;
assign fn_mod_reg = fn_mod_int;
nic400_ib_extsys1_axis_ib_apb_decode_mask_sse710_main u_ib_extsys1_axis_ib_apb_decode (
      .addr   (addr),
      .enable   (enable),
      .write   (write),
      .wr_strb  (wr_strb),

      .rd_mask   (rd_mask),.rd_read_qos   (rd_read_qos),
      .wr_read_qos   (wr_read_qos),
      .rd_write_qos   (rd_write_qos),
      .wr_write_qos   (wr_write_qos),
      .rd_fn_mod   (rd_fn_mod),
      .wr_fn_mod   (wr_fn_mod),
       
      .decode_match    (decode_match)
   );

nic400_ib_extsys1_axis_ib_data_out_mux_mask_sse710_main u_ib_extsys1_axis_ib_data_out_mux (
      .rd_mask   (rd_mask),
      .data_out_mask   (data_out_mask),
      
      .data_out   (data_out)
   );




`ifdef ARM_ASSERT_ON
 


wire test_valid;
assign test_valid = (
        rd_read_qos | 
        wr_read_qos | 
        rd_write_qos | 
        wr_write_qos | 
        rd_fn_mod | 
        wr_fn_mod
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



wire [13:0] test_regs;
assign test_regs = {
        rd_read_qos, 
        wr_read_qos, 
        rd_write_qos, 
        wr_write_qos, 
        rd_fn_mod, 
        wr_fn_mod
      };
      
      
      

   assert_zero_one_hot #(0,14,0,"More than one reg access being carried out")
   ovl_multi_reg_access
      (
       .clk       (aclk),
       .reset_n   (aresetn),
       .test_expr (test_regs));


  wire ovl_wrong_value = (
 (wr_read_qos & (
      (1'b0)
 ))
| 
 (wr_write_qos & (
      (1'b0)
 ))
| 
 (wr_fn_mod & (
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
`include "nic400_ib_extsys1_axis_ib_undefs_sse710_main.v"

