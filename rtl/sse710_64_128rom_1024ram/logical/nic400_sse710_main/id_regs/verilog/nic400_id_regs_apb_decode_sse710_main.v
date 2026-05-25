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


module nic400_id_regs_apb_decode_sse710_main
(
  addr,
  enable,
  apb_write,

  rd_periph_id,
  rd_periph_id_4,
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
  rd_comp_id_3 
); 



  input         [11:2]  addr;        
  input                 enable;      
  input                 apb_write;   

  output                rd_periph_id;

  output                rd_periph_id_4;
  output                rd_periph_id_5;
  output                rd_periph_id_6;
  output                rd_periph_id_7;
  output                rd_periph_id_0;
  output                rd_periph_id_1;
  output                rd_periph_id_2;
  output                rd_periph_id_3;
  output                rd_comp_id_0;
  output                rd_comp_id_1;
  output                rd_comp_id_2;
  output                rd_comp_id_3; 


  wire          [11:0]  i_addr;      



  reg                   rd_periph_id;

  reg                   rd_periph_id_4;
  reg                   rd_periph_id_5;
  reg                   rd_periph_id_6;
  reg                   rd_periph_id_7;
  reg                   rd_periph_id_0;
  reg                   rd_periph_id_1;
  reg                   rd_periph_id_2;
  reg                   rd_periph_id_3;
  reg                   rd_comp_id_0;
  reg                   rd_comp_id_1;
  reg                   rd_comp_id_2;
  reg                   rd_comp_id_3; 



  assign i_addr = {addr[11:2], 2'b00};

  always @ (enable or apb_write)
  begin : p_gen_reg_blk_rd_strobes_comb
    if (enable == 1'b1 && apb_write == 1'b0)
      rd_periph_id = 1'b1;
    else
      rd_periph_id = 1'b0; 
  end 

  always @ (enable or apb_write or i_addr )
  begin : p_gen_reg_strobes_comb
    rd_periph_id_4 = 1'b0;
    rd_periph_id_5 = 1'b0;
    rd_periph_id_6 = 1'b0;
    rd_periph_id_7 = 1'b0;
    rd_periph_id_0 = 1'b0;
    rd_periph_id_1 = 1'b0;
    rd_periph_id_2 = 1'b0;
    rd_periph_id_3 = 1'b0;
    rd_comp_id_0 = 1'b0;
    rd_comp_id_1 = 1'b0;
    rd_comp_id_2 = 1'b0;
    rd_comp_id_3 = 1'b0; 

    if (enable == 1'b1 && apb_write == 1'b0) begin
      case (i_addr)
        12'hFD0 : rd_periph_id_4 = 1'b1;
        12'hFD4 : rd_periph_id_5 = 1'b1;
        12'hFD8 : rd_periph_id_6 = 1'b1;
        12'hFDC : rd_periph_id_7 = 1'b1;
        12'hFE0 : rd_periph_id_0 = 1'b1;
        12'hFE4 : rd_periph_id_1 = 1'b1;
        12'hFE8 : rd_periph_id_2 = 1'b1;
        12'hFEC : rd_periph_id_3 = 1'b1;
        12'hFF0 : rd_comp_id_0 = 1'b1;
        12'hFF4 : rd_comp_id_1 = 1'b1;
        12'hFF8 : rd_comp_id_2 = 1'b1;
        12'hFFC : rd_comp_id_3 = 1'b1;
      default : ;
      endcase
    end
  end 



endmodule 

