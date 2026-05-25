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

module pcg # (
  parameter WIDTH = 1
  )
(
    input wire [WIDTH-1:0] clk_in,
    input wire [WIDTH-1:0] resetn,
    input wire [WIDTH-1:0] enable,
    
    output wire [WIDTH-1:0] clk_out,

    input wire dftrstdisable,
    input wire dftcgen    
    
);
  wire [WIDTH-1:0] enable_ss;
  wire [WIDTH-1:0] resetn_ss;
  
  genvar  i;
  for(i=0; i<WIDTH; i=i+1)
  begin: sync_loop    
    
    arm_element_reset_sync u_reset_sync (
        .clk             (clk_in[i]),            
        .resetn_async    (resetn[i]),
        .resetn_sync     (resetn_ss[i]),          
        .dftrstdisable   (dftrstdisable)  
    );

    arm_element_cdc_capt_sync u_enable_sync ( .clk(clk_in[i]), .nreset(resetn_ss[i]), .d_async(enable[i]), .q(enable_ss[i]) );
    
    arm_element_clock_gate u_clock_gate (
    .clk_in  (clk_in[i]),
    .enable  (enable_ss[i]),
    .clk_out (clk_out[i]),
    .dftcgen (dftcgen)
    );

  end
 


endmodule    
