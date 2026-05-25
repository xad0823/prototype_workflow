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

module arm_element_cdc_connect (clk_launch, clk_capture, d_in, d_out);

  parameter IH = 0;
  parameter IL = 0;
  
  
  input   wire              clk_launch; 
  input   wire              clk_capture;
  input   wire   [IH:IL]    d_in;    
  output  wire   [IH:IL]    d_out;



`ifdef ARM_CDC_CHECK

  reg      [IH:IL]    d_out_reg   = {IH-IL+1{1'bz}};
  reg      [IH:IL]    launch_unct = {IH-IL+1{1'bz}};
  reg      [IH:IL]    capture_unct= {IH-IL+1{1'bz}};
  wire     [IH:IL]    muxsel;

  integer             i;

  assign muxsel = (capture_unct^d_in) & (launch_unct^d_in);

  always @(d_in or muxsel)
    for (i = IL; i <= IH; i = i + 1)
      d_out_reg[i] = muxsel[i] ? 1'bz : d_in[i];
  
  always @ (posedge clk_launch)
    launch_unct <= d_in;

  always @ (posedge clk_capture)
    capture_unct <= d_in;

  assign d_out = d_out_reg;
`else 

assign d_out = d_in;

`endif 
  
endmodule
