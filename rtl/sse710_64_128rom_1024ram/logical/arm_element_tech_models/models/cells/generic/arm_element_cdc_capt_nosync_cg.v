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

module arm_element_cdc_capt_nosync_cg (clk, nreset, en, d_async, q, dftcgen);

  parameter IH = 0; 
  parameter IL = 0; 

  input   wire          clk;
  input   wire          nreset;
  input   wire          en;
  input   wire  [IH:IL] d_async;     
  output  wire  [IH:IL] q;
  input   wire          dftcgen;

  wire         iclk_g;


     arm_preclockgate u_preclockgate (
         .clk_i (clk),
         .enable_i (en),
         .clk_o (iclk_g),
         .scan_enable_i (dftcgen)
     );

  generate
    genvar i;
    for(i=IL ; i<=IH ; i=i+1) begin : BK_CDC_CAPT_NOSYNC_CG
        arm_sdffrpq u_sdffrpq (
            .clk_i (iclk_g),        
            .d_i (d_async[i]),
            .reset_i (~nreset),    
            .scan_enable_i (1'b0),
            .scan_i (1'b0),     
            .q_o (q[i])
        );
    end
  endgenerate

`ifdef ARM_CDC_CHECK

  integer   j;

`ifdef ARM_ASSERT_ON
  reg       z_detect;

  initial
    z_detect = 1'b0;
`endif

  always @(posedge clk)
    if (en)
      for (j = IL; j <= IH; j = j + 1)
        if (d_async[j] === 1'bz)
          begin
`ifdef ARM_ASSERT_ON
            z_detect = 1'b1;
`else
            $display("Unsafe operation detected across CDC boundary");
            $stop;
`endif
          end

`ifdef ARM_ASSERT_ON
    assert_never: assert property (@(posedge clk) disable iff(~nreset) (z_detect == 1'b0) )
      else $fatal ("Unsafe operation detected across CDC boundary");
`endif

`else 
`endif 

endmodule
