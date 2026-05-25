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


                
module sec_pactive (
  input  wire  [10:0] p2q_pactive,
  input  wire  [15:0] ppu_hwstat,
  input  wire         pwr_gate_en,
  input  wire         mhu0_recwakeup,
  input  wire         mhu1_recwakeup,
  input  wire         mhu2_recwakeup,
    input  wire         mhu3_recwakeup,
    input  wire         mhu4_recwakeup,
    input  wire         mhu5_recwakeup,
    input  wire         irq_wakeup,

  output wire  [10:0] ppu_pactive
);

  wire        pactive_8;
  wire [8:0] or_tree_i;

  wire        unused;

  assign unused = &ppu_hwstat | &p2q_pactive; 

  assign ppu_pactive = {2'b00, pactive_8, 5'b00000,  p2q_pactive[2], 2'b01};

  assign or_tree_i = {~pwr_gate_en    ,
                      mhu0_recwakeup  ,
                      mhu1_recwakeup  ,
 
                      mhu2_recwakeup  ,
                        mhu3_recwakeup  , 
   
 
                      mhu4_recwakeup  ,
                        mhu5_recwakeup  , 
   
 
                      irq_wakeup      ,
                      p2q_pactive[8]};

  sec_or_tree #(
    .NUM_OR_TREE_INPUTS (9)
  ) u_sec_or_tree(
    .or_tree_i          (or_tree_i),
    .or_tree_o          (pactive_8)
  );                      

endmodule
