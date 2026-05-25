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


module nic400_ib_debug_axis_ib_data_out_mux_mask_sse710_main (
      rd_mask,
      data_out_mask,
      
      data_out
);

input         rd_mask;  
input  [31:0] data_out_mask;  

output [31:0] data_out;   



wire  reg_blk_sel;   



reg [31:0] data_out;   


assign reg_blk_sel = {rd_mask};

   always @(reg_blk_sel 
       or data_out_mask)
   begin
     case(reg_blk_sel)
       1'b1 : data_out =  data_out_mask;
       1'b0 : data_out =  {32{1'b0}};
       default : data_out = {32{1'bx}};
     endcase
   end



endmodule
