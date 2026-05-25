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

module gray_encode 
  #(parameter
      COUNTER_WIDTH = 64
 )
  (
  input   wire                      nreset,
  input   wire                      clk,
  input   wire  [COUNTER_WIDTH-1:0] binary_count,
  output  reg   [COUNTER_WIDTH-1:0] gray_count

  );
 
  reg   [COUNTER_WIDTH-1:0] ibinary_count;
  wire  [COUNTER_WIDTH-1:0] igray_count;

  always @(posedge clk or negedge nreset)
  begin
    if (!nreset)
      ibinary_count <= {COUNTER_WIDTH{1'b0}};
    else
      ibinary_count <= binary_count;
  end

  assign igray_count = ibinary_count ^ (ibinary_count >> 1);

  always @(posedge clk or negedge nreset)
  begin
    if (!nreset)
      gray_count <= {COUNTER_WIDTH{1'b0}};
    else
      gray_count <= igray_count;
  end


endmodule
