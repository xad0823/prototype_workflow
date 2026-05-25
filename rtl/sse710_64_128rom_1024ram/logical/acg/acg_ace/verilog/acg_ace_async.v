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


module acg_ace_async 
  (
    input wire          awakeups_i,
    input wire          acvalidm_i,
    input wire          sn_ot_cntr_non_zero_i,
    input wire          rd_ot_cntr_non_zero_i,
    input wire          aw_ot_cntr_non_zero_i,
    input wire          w_ot_cntr_non_zero_i,
    input wire          pwr_qreqn_i,
    input wire          pwr_qacceptn_i,
    input wire          pwr_qdeny_i,
    
    output wire         clk_qactive_o,
    output wire         pwr_qactive_o
  );

  wire pwr_in_trans_int;
  wire pwr_reqclock_int;
  wire aw_w_ot_cntr_non_zero_int;
  wire rd_sn_ot_cntr_non_zero_int;
  wire incoming_trans_int;
  wire gate_busy_int;
  wire cntr_non_zero_int;

  acg_xor2
  u_acg_xor2
  (
    .A (pwr_qreqn_i),
    .B (pwr_qacceptn_i),
    .Y (pwr_in_trans_int)
  );

  acg_or2
  u_acg_or2_pwr_reqclock
  (
    .A (pwr_in_trans_int),
    .B (pwr_qdeny_i),
    .Y (pwr_reqclock_int)
  );

  acg_or2
  u_acg_or2_cntr_aw_w_non_zero
  (
    .A (aw_ot_cntr_non_zero_i),
    .B (w_ot_cntr_non_zero_i),
    .Y (aw_w_ot_cntr_non_zero_int)
  );
  
  acg_or2
  u_acg_or2_cntr_rd_sn_non_zero
  (
    .A (rd_ot_cntr_non_zero_i),
    .B (sn_ot_cntr_non_zero_i),
    .Y (rd_sn_ot_cntr_non_zero_int)
  );
  
  acg_or2
  u_acg_o_incoming_trans
  (
    .A (awakeups_i),
    .B (acvalidm_i),
    .Y (incoming_trans_int)
  );

  acg_or2
  u_acg_o_gate_busy
  (
    .A (pwr_reqclock_int),
    .B (incoming_trans_int),
    .Y (gate_busy_int)
  );
 
  acg_or2
  u_acg_o_cntr_non_zero
  (
    .A (aw_w_ot_cntr_non_zero_int),
    .B (rd_sn_ot_cntr_non_zero_int),
    .Y (cntr_non_zero_int)
  );

  acg_or2
  u_acg_o_cntr_clk_qactive
  (
    .A (gate_busy_int),
    .B (cntr_non_zero_int),
    .Y (clk_qactive_o)
  );

  acg_or2
  u_acg_or2_pwr_qactive
  (
    .A (incoming_trans_int),
    .B (cntr_non_zero_int),
    .Y (pwr_qactive_o)
  );


endmodule

