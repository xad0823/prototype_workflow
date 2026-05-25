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
 
module arm_element_latch_dgrnq (
  input   wire      D, G, RN, 
  output  wire      Q
 
);
 
  wire iQ;

  arm_latchrpqn u_arm_latchrpqn (
          .enable_i (G),        
          .d_i      (D),
          .reset_i  (~RN),  
          .qn_o     (iQ)       
  );

  arm_inverter u_inverter (
          .a_i (iQ),
          .y_o (Q)
  );

 
endmodule
