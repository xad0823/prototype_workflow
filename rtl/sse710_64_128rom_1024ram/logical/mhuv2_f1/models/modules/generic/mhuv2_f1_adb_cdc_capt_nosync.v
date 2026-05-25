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

module mhuv2_f1_adb_cdc_capt_nosync (clk, reset_n, en, d_async_i, q_sync_o);

  parameter IH = 0; 
  parameter IL = 0; 

  input          clk;
  input          reset_n;
  input          en;
  input  [IH:IL] d_async_i;     
  output [IH:IL] q_sync_o;


  arm_element_cdc_capt_nosync #(.IH(IH),.IL(IL)) u_arm_element_cdc_capt_nosync(
   .clk       (clk),
   .nreset    (reset_n),
   .en        (en),
   .d_async   (d_async_i),
   .q         (q_sync_o)
  );


endmodule
