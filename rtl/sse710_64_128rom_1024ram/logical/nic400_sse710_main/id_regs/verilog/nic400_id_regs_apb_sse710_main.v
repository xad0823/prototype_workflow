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


module nic400_id_regs_apb_sse710_main
(
  pclk,
  presetn,
  pclken,
  psel,
  paddr,
  penable,
  pwrite,
  pwdata,
  rev_ands,

  prdata,
  pready,
  pslverr
); 



  input                 pclk;               
  input                 presetn;            
  input                 pclken;             
  input         [31:0]  paddr;              
  input                 psel;               
  input                 penable;            
  input                 pwrite;             
  input         [31:0]  pwdata;             
  input          [3:0]  rev_ands;           

  output        [31:0]  prdata;             
  output                pready;             
  output                pslverr;            



  wire                  pclk;               
  wire                  presetn;            
  wire                  pclken;             
  wire          [31:0]  paddr;              
  wire                  psel;               
  wire                  penable;            
  wire                  pwrite;             
  wire          [31:0]  pwdata;             
  wire           [3:0]  rev_ands;           

  wire          [31:0]  prdata;             
  wire                  pready;             
  wire                  pslverr;            



  wire          [11:2]  addr;               
  wire                  enable;             
  wire          [31:0]  data_out;           
  wire          [31:0]  wdata_reg;          
  wire                  write_reg;          

  wire           [7:0]  periph_id_4;
  wire           [7:0]  periph_id_5;
  wire           [7:0]  periph_id_6;
  wire           [7:0]  periph_id_7;
  wire           [7:0]  periph_id_0;
  wire           [7:0]  periph_id_1;
  wire           [7:0]  periph_id_2;
  wire           [3:0]  cust_mod_num;
  wire           [3:0]  rev_and;
  wire           [7:0]  comp_id_0;
  wire           [7:0]  comp_id_1;
  wire           [7:0]  comp_id_2;
  wire           [7:0]  comp_id_3;



  assign pslverr = 1'b0;

  nic400_id_regs_apb_cond_sse710_main
  u_id_regs_apb_cond
  (
    .pclk               (pclk),
    .presetn            (presetn),
    .pclken             (pclken),
    .psel               (psel),
    .paddr              (paddr[11:2]),
    .penable            (penable),
    .pwrite             (pwrite),
    .pwdata             (pwdata),
    .data_out           (data_out),

    .prdata             (prdata),
    .pready             (pready),
    .addr               (addr),
    .enable             (enable),
    .wdata_reg          (wdata_reg),
    .write_reg          (write_reg)
  ); 

  nic400_id_regs_apb_reg_block_sse710_main
  u_id_regs_apb_reg_block
  (
    .pclk                 (pclk),
    .presetn              (presetn),
    .pclken               (pclken),
    .addr                 (addr),
    .enable               (enable),
    .apb_write            (write_reg),
    .data_in              (wdata_reg),
    .periph_id_4          (periph_id_4),
    .periph_id_5          (periph_id_5),
    .periph_id_6          (periph_id_6),
    .periph_id_7          (periph_id_7),
    .periph_id_0          (periph_id_0),
    .periph_id_1          (periph_id_1),
    .periph_id_2          (periph_id_2),
    .cust_mod_num          (cust_mod_num),
    .rev_and          (rev_and),
    .comp_id_0          (comp_id_0),
    .comp_id_1          (comp_id_1),
    .comp_id_2          (comp_id_2),
    .comp_id_3          (comp_id_3),
    
    .data_out             (data_out)
  ); 

  assign periph_id_4 = 8'h04;
  assign periph_id_5 = 8'h00;
  assign periph_id_6 = 8'h00;
  assign periph_id_7 = 8'h00;
  assign periph_id_0 = 8'h00;
  assign periph_id_1 = 8'hB4;
  assign periph_id_2 = 8'h6B;
  assign cust_mod_num = 4'h0;
  assign rev_and = rev_ands;
  assign comp_id_0 = 8'h0D;
  assign comp_id_1 = 8'hF0;
  assign comp_id_2 = 8'h05;
  assign comp_id_3 = 8'hB1;


endmodule 

