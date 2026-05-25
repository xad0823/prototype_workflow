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



module nic400_ib_secenc_axis_ib_apb_decode_mask_sse710_main (
      addr,
      enable,
      write,
      wr_strb,

      rd_mask,
      rd_read_qos,
      wr_read_qos,
      rd_write_qos,
      wr_write_qos,
      rd_fn_mod,
      wr_fn_mod,
             
      decode_match
   );

input [12:2] addr;   
input        enable;   
input        write;   
input        wr_strb;   


output       rd_mask;   
output       rd_read_qos;   
output       wr_read_qos;   
output       rd_write_qos;   
output       wr_write_qos;   
output       rd_fn_mod;   
output       wr_fn_mod;   
 
output       decode_match;


wire [12:0] i_addr;   


reg    rd_mask;   
reg    rd_read_qos;   
reg    rd_write_qos;   
reg    rd_fn_mod;   
reg    wr_reg_read_qos;   
wire   wr_read_qos;       
reg    wr_reg_write_qos;   
wire   wr_write_qos;       
reg    wr_reg_fn_mod;   
wire   wr_fn_mod;       


assign i_addr = {addr[12:2], 2'b00};


always@(enable or write or i_addr ) begin


  if (enable == 1'b1 && write == 1'b0 && i_addr[11:8]  == 4'h1)
       rd_mask = 1'b1;
  else
       rd_mask = 1'b0;
 
end



always@(enable or write or i_addr ) begin

    rd_read_qos = 1'b0;
    rd_write_qos = 1'b0;
    rd_fn_mod = 1'b0; 

  if (enable == 1'b1 && write == 1'b0) begin
    case (i_addr)
      13'h100 : rd_read_qos = 1'b1;
      13'h104 : rd_write_qos = 1'b1;
      13'h108 : rd_fn_mod = 1'b1;
      default : ;
    endcase
  end
end



always@(enable or write or i_addr) begin

    wr_reg_read_qos = 1'b0;
    wr_reg_write_qos = 1'b0;
    wr_reg_fn_mod = 1'b0; 

  if (enable == 1'b1 && write == 1'b1) begin
    case (i_addr)
      13'h100  : wr_reg_read_qos = 1'b1;
      13'h104  : wr_reg_write_qos = 1'b1;
      13'h108  : wr_reg_fn_mod = 1'b1;
      default : ;
    endcase
  end
end


assign  wr_read_qos = wr_reg_read_qos & wr_strb;       
assign  wr_write_qos = wr_reg_write_qos & wr_strb;       
assign  wr_fn_mod = wr_reg_fn_mod & wr_strb;        


assign decode_match = rd_read_qos
    | rd_write_qos
    | rd_fn_mod
    | wr_reg_read_qos
    | wr_reg_write_qos
    | wr_reg_fn_mod;


endmodule
