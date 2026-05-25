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

module nic400_cdc_capt_nosync_sse710_dbg3s1m (d_async, q, valid);

  parameter WIDTH = 4; 

  input              valid;
  input  [WIDTH-1:0] d_async;     
  output [WIDTH-1:0] q;

 genvar d;
 generate
    for (d=0;d<WIDTH;d=d+1)
      begin : d_mask

  nic400_cdc_comb_and2_sse710_dbg3s1m  u_cdc_and2 (
   .din1_async (d_async[d]),   
   .din2       (valid),
   .dout       (q[d])
  );
 
      end

 endgenerate

`ifdef ARM_CDC_CHECK

  integer   i;

  wire [WIDTH-1:0]  q_d;
  reg               z_detect;

  initial
    z_detect = 1'b0;

  assign #1 q_d = q;

  always @(q_d)
    if (valid)
      for (i = 0; i <= WIDTH; i = i + 1)
        if (d_async[i] === 1'bz)
          begin
            z_detect <= 1'b1;
          end

  always @(posedge z_detect)
     begin
          $display("FATAL : Unsafe operation detected across CDC boundary");
          $stop;
     end

`endif

endmodule

