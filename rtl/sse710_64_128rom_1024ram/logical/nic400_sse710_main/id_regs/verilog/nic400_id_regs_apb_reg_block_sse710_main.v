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


module nic400_id_regs_apb_reg_block_sse710_main
(
  pclk,
  presetn,
  pclken,
  addr,
  enable,
  apb_write,
  data_in,
  periph_id_4,
  periph_id_5,
  periph_id_6,
  periph_id_7,
  periph_id_0,
  periph_id_1,
  periph_id_2,
  cust_mod_num,
  rev_and,
  comp_id_0,
  comp_id_1,
  comp_id_2,
  comp_id_3,
  
  data_out
);



  input                 pclk;               
  input                 presetn;            
  input                 pclken;             
  input         [11:2]  addr;               
  input                 enable;             
  input                 apb_write;          
  input         [31:0]  data_in;            

  input          [7:0]  periph_id_4;
  input          [7:0]  periph_id_5;
  input          [7:0]  periph_id_6;
  input          [7:0]  periph_id_7;
  input          [7:0]  periph_id_0;
  input          [7:0]  periph_id_1;
  input          [7:0]  periph_id_2;
  input          [3:0]  cust_mod_num;
  input          [3:0]  rev_and;
  input          [7:0]  comp_id_0;
  input          [7:0]  comp_id_1;
  input          [7:0]  comp_id_2;
  input          [7:0]  comp_id_3;

  output        [31:0]  data_out;           




  wire                  rd_periph_id;  
wire         rd_periph_id_4;  
wire         rd_periph_id_5;  
wire         rd_periph_id_6;  
wire         rd_periph_id_7;  
wire         rd_periph_id_0;  
wire         rd_periph_id_1;  
wire         rd_periph_id_2;  
wire         rd_periph_id_3;  
wire         rd_comp_id_0;  
wire         rd_comp_id_1;  
wire         rd_comp_id_2;  
wire         rd_comp_id_3;  

wire  [31:0] data_out_periph_id;  




nic400_id_regs_reg_periph_id_sse710_main u_reg_periph_id(
      .aclk (pclk),
      .aresetn  (presetn),
      .pclken  (pclken),
      .data_in  (data_in),
      .rd_periph_id_4   (rd_periph_id_4),
      .periph_id_4   (periph_id_4),
      .rd_periph_id_5   (rd_periph_id_5),
      .periph_id_5   (periph_id_5),
      .rd_periph_id_6   (rd_periph_id_6),
      .periph_id_6   (periph_id_6),
      .rd_periph_id_7   (rd_periph_id_7),
      .periph_id_7   (periph_id_7),
      .rd_periph_id_0   (rd_periph_id_0),
      .periph_id_0   (periph_id_0),
      .rd_periph_id_1   (rd_periph_id_1),
      .periph_id_1   (periph_id_1),
      .rd_periph_id_2   (rd_periph_id_2),
      .periph_id_2   (periph_id_2),
      .rd_periph_id_3   (rd_periph_id_3),
      .cust_mod_num   (cust_mod_num),
      .rev_and   (rev_and),
      .rd_comp_id_0   (rd_comp_id_0),
      .comp_id_0   (comp_id_0),
      .rd_comp_id_1   (rd_comp_id_1),
      .comp_id_1   (comp_id_1),
      .rd_comp_id_2   (rd_comp_id_2),
      .comp_id_2   (comp_id_2),
      .rd_comp_id_3   (rd_comp_id_3),
      .comp_id_3   (comp_id_3),
       
      .data_out_periph_id   (data_out_periph_id)
   );

nic400_id_regs_apb_decode_sse710_main u_id_regs_apb_decode (
      .addr   (addr),
      .enable   (enable),
      .apb_write   (apb_write),

      .rd_periph_id   (rd_periph_id),
      .rd_periph_id_4   (rd_periph_id_4),
      .rd_periph_id_5   (rd_periph_id_5),
      .rd_periph_id_6   (rd_periph_id_6),
      .rd_periph_id_7   (rd_periph_id_7),
      .rd_periph_id_0   (rd_periph_id_0),
      .rd_periph_id_1   (rd_periph_id_1),
      .rd_periph_id_2   (rd_periph_id_2),
      .rd_periph_id_3   (rd_periph_id_3),
      .rd_comp_id_0   (rd_comp_id_0),
      .rd_comp_id_1   (rd_comp_id_1),
      .rd_comp_id_2   (rd_comp_id_2),
      .rd_comp_id_3   (rd_comp_id_3) 
   );


   assign data_out = data_out_periph_id;



`ifdef ARM_ASSERT_ON

   reg enable_reg;
   wire test_strb;

   always @(posedge pclk or negedge presetn)
     if (!presetn) begin
        enable_reg <= 1'b0;
     end else begin
        enable_reg <= enable;
     end
   assign test_strb = enable & ~enable_reg;


wire test_ro_periph_id;
assign test_ro_periph_id = (enable & apb_write & pclken) && ( 
{addr, 2'b00} == 12'hFD0 || 
{addr, 2'b00} == 12'hFD4 || 
{addr, 2'b00} == 12'hFD8 || 
{addr, 2'b00} == 12'hFDC || 
{addr, 2'b00} == 12'hFE0 || 
{addr, 2'b00} == 12'hFE4 || 
{addr, 2'b00} == 12'hFE8 || 
{addr, 2'b00} == 12'hFEC || 
{addr, 2'b00} == 12'hFF0 || 
{addr, 2'b00} == 12'hFF4 || 
{addr, 2'b00} == 12'hFF8 || 
{addr, 2'b00} == 12'hFFC 
);

assert_never #(1,0,"WARNING, Write to Read Only Register")
ovl_assert_ro_periph_id
   (
    .clk       (pclk),
    .reset_n   (presetn),
    .test_expr (test_ro_periph_id & test_strb));
 


wire test_valid;
assign test_valid = (rd_periph_id_4 |
      rd_periph_id_5 |
      rd_periph_id_6 |
      rd_periph_id_7 |
      rd_periph_id_0 |
      rd_periph_id_1 |
      rd_periph_id_2 |
      rd_periph_id_3 |
      rd_comp_id_0 |
      rd_comp_id_1 |
      rd_comp_id_2 |
      rd_comp_id_3);


assert_implication #(1,0,"WARNING, Register Read Access Outside Valid Region")
ovl_assert_invalid_rd_region
   (
    .clk              (pclk),
    .reset_n          (presetn),
    .antecedent_expr  (enable && !apb_write),
    .consequent_expr  (test_valid));


wire [19:0] test_regs;
assign test_regs = {rd_periph_id_4,
      rd_periph_id_5,
      rd_periph_id_6,
      rd_periph_id_7,
      rd_periph_id_0,
      rd_periph_id_1,
      rd_periph_id_2,
      rd_periph_id_3,
      rd_comp_id_0,
      rd_comp_id_1,
      rd_comp_id_2,
      rd_comp_id_3};

   assert_zero_one_hot #(0,20,0,"More than one reg access being carried out")
   ovl_multi_reg_access
      (
       .clk       (pclk),
       .reset_n   (presetn),
       .test_expr (test_regs));


  wire ovl_wrong_value = ( (1'b0));

   assert_never #(2,1,"Illegal value written to register")
   ovl_wrong_value_reg
      (
       .clk       (pclk),
       .reset_n   (presetn),
       .test_expr (ovl_wrong_value));

`endif 

endmodule

