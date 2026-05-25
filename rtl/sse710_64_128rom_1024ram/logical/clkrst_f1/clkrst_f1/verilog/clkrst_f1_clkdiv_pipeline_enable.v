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

module clkrst_f1_clkdiv_pipeline_enable
  #(parameter
      COUNTER_WIDTH = 64
 )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire                      enable,
  input   wire  [COUNTER_WIDTH-1:0] data_in,
  output  wire  [COUNTER_WIDTH-1:0] data_out

  );
 
  reg   [COUNTER_WIDTH-1:0] i_data_out;


  always @(posedge clk or negedge nreset)
  begin
    if (!nreset)
      i_data_out <= {COUNTER_WIDTH{1'b0}};
    else if (enable)
      i_data_out <= data_in;
    else
      i_data_out <= i_data_out;
  end

  assign data_out = i_data_out;
  
endmodule
