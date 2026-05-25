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

module acg_axi_core_async 
  (
    input wire          awakeups_i,
    input wire          rd_ot_cntr_non_zero_i,
    input wire          aw_ot_cntr_non_zero_i,
    input wire          w_ot_cntr_non_zero_i,
    input wire          pwr_qreqn_i,
    input wire          pwr_qacceptn_i,
    input wire          pwr_qdeny_i,
    input wire          ds_read_busy_i,
    input wire          ds_write_busy_i,
    output wire         clk_qactive_o,
    output wire         pwr_qactive_o
  );

  wire pwr_in_trans_int;
  wire pwr_reqclock_int;
  wire aw_w_ot_cntr_non_zero_int;
  wire cntr_non_zero_int;
  wire ds_busy_int;
  wire gate_busy_int;
  wire core_clk_qactive_int;
  wire partial_pwr_qactive_int;


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
  u_acg_o_cntr_non_zero
  (
    .A (aw_w_ot_cntr_non_zero_int),
    .B (rd_ot_cntr_non_zero_i),
    .Y (cntr_non_zero_int)
  );

  acg_or2
  u_acg_o_gate_busy
  (
    .A (pwr_reqclock_int),
    .B (awakeups_i),
    .Y (gate_busy_int)
  );

  acg_or2
  u_acg_o_default_slave_busy
  (
    .A (ds_read_busy_i),
    .B (ds_write_busy_i),
    .Y (ds_busy_int)
  );


  acg_or2
  u_acg_o_core_clk_qactive
  (
    .A (gate_busy_int),
    .B (cntr_non_zero_int),
    .Y (core_clk_qactive_int)
  );

  acg_or2
  u_acg_o_full_clk_qactive
  (
    .A (core_clk_qactive_int),
    .B (ds_busy_int),
    .Y (clk_qactive_o)
  );

  acg_or2
  u_acg_o_partial_pwr_qactive
  (
    .A (rd_ot_cntr_non_zero_i),
    .B (awakeups_i),
    .Y (partial_pwr_qactive_int)    
  );

  acg_or2
  u_acg_o_full_pwr_qactive
  (
    .A (aw_w_ot_cntr_non_zero_int),
    .B (partial_pwr_qactive_int),
    .Y (pwr_qactive_o)    
  );


endmodule


