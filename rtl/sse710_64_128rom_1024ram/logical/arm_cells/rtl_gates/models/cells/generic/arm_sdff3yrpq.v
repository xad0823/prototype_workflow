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

module arm_sdff3yrpq  (
  input  wire                           clk_i,           
  input  wire                           d_i,
  input  wire                           reset_i,        
  input  wire                           scan_enable_i,   
  input  wire                           scan_i ,         
  output wire                           q_o              
 
);


  reg                                   rst_n_sync2;
  reg                                   rst_n_sync1;
  reg                                   rst_n_sync;


  always @(posedge clk_i or posedge reset_i) begin
    if (reset_i)
      begin
        rst_n_sync2 <= 1'b0;
        rst_n_sync1 <= 1'b0;
        rst_n_sync  <= 1'b0;
      end
    else
      begin        
        if ( scan_enable_i ) 
          begin
            rst_n_sync2 <= scan_i;
         end
        else
          begin
           rst_n_sync2  <= d_i;
          end

        rst_n_sync1 <= rst_n_sync2;
        rst_n_sync  <= rst_n_sync1;
      end
  end


  assign q_o = rst_n_sync;
endmodule

