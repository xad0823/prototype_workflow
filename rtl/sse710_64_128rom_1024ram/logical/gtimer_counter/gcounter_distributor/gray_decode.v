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

module gray_decode 
  #(parameter
      COUNTER_WIDTH = 64
 )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire  [COUNTER_WIDTH-1:0] gray_count,
  output  reg   [COUNTER_WIDTH-1:0] binary_count

  );
 
  wire  [COUNTER_WIDTH-1:0] ibinary_count;
  reg   [COUNTER_WIDTH-1:0] igray_count;

  always @(posedge clk or negedge nreset)
  begin
    if (!nreset)
      igray_count <= {COUNTER_WIDTH{1'b0}};
    else
      igray_count <= gray_count;
  end

  genvar i;
  generate
   for (i=0; i<COUNTER_WIDTH; i=i+1)
   begin : ibinary
     assign ibinary_count[i] = ^igray_count[COUNTER_WIDTH-1:i];
   end
  endgenerate
  
  always @(posedge clk or negedge nreset)
  begin
    if (!nreset)
      binary_count <= {COUNTER_WIDTH{1'b0}};
    else
      binary_count <= ibinary_count;
  end

endmodule
