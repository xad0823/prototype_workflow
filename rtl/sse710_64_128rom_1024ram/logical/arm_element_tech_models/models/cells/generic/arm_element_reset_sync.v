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

module arm_element_reset_sync(
  input  wire                           clk,            
  input  wire                           resetn_async,   
  output wire                           resetn_sync,    

  input  wire                           dftrstdisable   
 
);


wire i_nreset_sync; 
wire rst_n_sync1_dft_sync;  

arm_sdff2yrpq u_sdff2yrpq (
        .clk_i (clk),        
        .d_i (1'b1),
        .reset_i (~resetn_async),      
        .scan_enable_i (1'b0),
        .scan_i (1'b0),     
        .q_o (i_nreset_sync)       
);


  assign rst_n_sync1_dft_sync = i_nreset_sync | dftrstdisable;

  assign resetn_sync = rst_n_sync1_dft_sync;


endmodule
