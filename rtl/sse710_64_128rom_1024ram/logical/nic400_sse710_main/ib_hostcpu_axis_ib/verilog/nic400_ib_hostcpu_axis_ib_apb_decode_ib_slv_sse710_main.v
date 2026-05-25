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



module nic400_ib_hostcpu_axis_ib_apb_decode_ib_slv_sse710_main (
      addr,
      enable,
      write,
      wr_strb,

      rd_ib_slv,
      rd_fn_mod2,
      wr_fn_mod2,
      rd_fn_mod_lb,
      wr_fn_mod_lb,
             
      decode_match
   );

input [12:2] addr;   
input        enable;   
input        write;   
input        wr_strb;   


output       rd_ib_slv;   
output       rd_fn_mod2;   
output       wr_fn_mod2;   
output       rd_fn_mod_lb;   
output       wr_fn_mod_lb;   
 
output       decode_match;


wire [12:0] i_addr;   


reg    rd_ib_slv;   
reg    rd_fn_mod2;   
reg    rd_fn_mod_lb;   
reg    wr_reg_fn_mod2;   
wire   wr_fn_mod2;       
reg    wr_reg_fn_mod_lb;   
wire   wr_fn_mod_lb;       


assign i_addr = {addr[12:2], 2'b00};


always@(enable or write or i_addr ) begin


  if (enable == 1'b1 && write == 1'b0 && i_addr[11:9]  == 3'h0)
       rd_ib_slv = 1'b1;
  else
       rd_ib_slv = 1'b0;
 
end



always@(enable or write or i_addr ) begin

    rd_fn_mod2 = 1'b0;
    rd_fn_mod_lb = 1'b0; 

  if (enable == 1'b1 && write == 1'b0) begin
    case (i_addr)
      13'h24 : rd_fn_mod2 = 1'b1;
      13'h2C : rd_fn_mod_lb = 1'b1;
      default : ;
    endcase
  end
end



always@(enable or write or i_addr) begin

    wr_reg_fn_mod2 = 1'b0;
    wr_reg_fn_mod_lb = 1'b0; 

  if (enable == 1'b1 && write == 1'b1) begin
    case (i_addr)
      13'h24  : wr_reg_fn_mod2 = 1'b1;
      13'h2C  : wr_reg_fn_mod_lb = 1'b1;
      default : ;
    endcase
  end
end


assign  wr_fn_mod2 = wr_reg_fn_mod2 & wr_strb;       
assign  wr_fn_mod_lb = wr_reg_fn_mod_lb & wr_strb;        


assign decode_match = rd_fn_mod2
    | rd_fn_mod_lb
    | wr_reg_fn_mod2
    | wr_reg_fn_mod_lb;


endmodule
