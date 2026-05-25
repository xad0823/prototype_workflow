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

module arm_element_cdc_comb_and2 (din1_async, din2_async, dout_async);

  parameter WIDTH = 1; 

  input   wire [WIDTH-1:0] din1_async; 
  input   wire [WIDTH-1:0] din2_async; 
  output  wire [WIDTH-1:0] dout_async;

  wire [WIDTH-1:0] idout_async;
  reg  [WIDTH-1:0] dout_z;

  generate
    genvar i;
    for(i=0 ; i<WIDTH ; i=i+1) begin : BK_COMB_AND
      arm_mux2 u_and2 (
              .a_i   (1'b0),
              .b_i   (din2_async[i]),
              .sel_i (din1_async[i]),
              .y_o   (idout_async[i])
      );
    end
  endgenerate


`ifdef ARM_CDC_CHECK
generate
genvar j;
  for (j=0; j<WIDTH; j=j+1)
  begin : async_dout_gen
  always @(din1_async[j] or din2_async[j])
    begin
      begin : async_dout
      case ({din1_async[j], din2_async[j]})
        2'b1z : dout_z[j] = 1'bz;
        2'bxz : dout_z[j] = 1'bz;
        2'bz1 : dout_z[j] = 1'bz;
        2'bzx : dout_z[j] = 1'bz;
        default : dout_z[j] = idout_async[j];
      endcase
      end
   end
  end
endgenerate

  assign dout_async = dout_z;
`else 
  assign dout_async = idout_async;
`endif 


endmodule
