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

module arm_element_cdc_capt_sync_latch (clk, nreset, d_async, q);

  input   wire  clk;
  input   wire  nreset;
  input   wire  d_async;
  output  wire  q;

  wire      d_noz;

`ifdef ARM_CDC_CHECK

  arm_element_cdc_random u_arm_element_cdc_random(
                         .din (d_async),
                         .dout (d_noz)
                         );

`else 

  assign d_noz = d_async;

`endif 

  wire      iq;

  arm_latchrpqn u_arm_latchrpqn (
          .enable_i       (clk),        
          .d_i            (d_noz),
          .reset_i        (~nreset),  
          .qn_o           (iq)       
  );

  arm_sdffrpq u_arm_sdffrpq (
          .clk_i          (clk),        
          .d_i            (~iq),
          .reset_i        (~nreset),  
          .scan_enable_i  (1'b0),  
          .scan_i         (1'b0),  
          .q_o            (q)       
  );

endmodule
