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



`ifndef INT_RTR_PARAMS
`include "interrupt_router_f0_params.v"
`endif

`ifndef INT_RTR_UNIT_PARAMS
`include "interrupt_router_f0_unit_params.v"
`endif

module interrupt_router_f0_core_logic_async
#(
  parameter NUM_SHD_INT = 0,
  parameter NUM_ICI     = 0
)
(
  `SI_DEF_ICI_DST_inputs
  input  wire [NUM_SHD_INT-1:0]    shd_int_cfg_ici0_en_in,
  output wire  [NUM_SHD_INT-1:0]    interrupt_controller_output_0,
  input  wire [NUM_SHD_INT-1:0]    shd_int_cfg_ici1_en_in,
  output wire  [NUM_SHD_INT-1:0]    interrupt_controller_output_1,
  input  wire [NUM_SHD_INT-1:0]    shd_int_cfg_ici2_en_in,
  output wire  [NUM_SHD_INT-1:0]    interrupt_controller_output_2,
  input  wire [NUM_SHD_INT-1:0]    shd_int_cfg_ici3_en_in,
  output wire  [NUM_SHD_INT-1:0]    interrupt_controller_output_3,
  input  wire [NUM_SHD_INT-1:0]    shared_interrupt_input
);

  wire [NUM_SHD_INT-1:0]  shared_interrupt_enable_0_int;
  wire [NUM_SHD_INT-1:0]  shared_interrupt_enable_1_int;
  wire [NUM_SHD_INT-1:0]  shared_interrupt_enable_2_int;
  wire [NUM_SHD_INT-1:0]  shared_interrupt_enable_3_int;


  assign shared_interrupt_enable_0_int[0] = shd_int_cfg_ici0_en_in[0] & SI0_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_0_0 (
    .din1_async  (shared_interrupt_enable_0_int[0]),
    .din2_async  (shared_interrupt_input[0]),
    .dout_async  (interrupt_controller_output_0[0])
  );

  assign shared_interrupt_enable_1_int[0] = shd_int_cfg_ici1_en_in[0] & SI0_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_0_1 (
    .din1_async  (shared_interrupt_enable_1_int[0]),
    .din2_async  (shared_interrupt_input[0]),
    .dout_async  (interrupt_controller_output_1[0])
  );

  assign shared_interrupt_enable_2_int[0] = shd_int_cfg_ici2_en_in[0] & SI0_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_0_2 (
    .din1_async  (shared_interrupt_enable_2_int[0]),
    .din2_async  (shared_interrupt_input[0]),
    .dout_async  (interrupt_controller_output_2[0])
  );

  assign shared_interrupt_enable_3_int[0] = shd_int_cfg_ici3_en_in[0] & SI0_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_0_3 (
    .din1_async  (shared_interrupt_enable_3_int[0]),
    .din2_async  (shared_interrupt_input[0]),
    .dout_async  (interrupt_controller_output_3[0])
  );


  assign shared_interrupt_enable_0_int[1] = shd_int_cfg_ici0_en_in[1] & SI1_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_1_0 (
    .din1_async  (shared_interrupt_enable_0_int[1]),
    .din2_async  (shared_interrupt_input[1]),
    .dout_async  (interrupt_controller_output_0[1])
  );

  assign shared_interrupt_enable_1_int[1] = shd_int_cfg_ici1_en_in[1] & SI1_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_1_1 (
    .din1_async  (shared_interrupt_enable_1_int[1]),
    .din2_async  (shared_interrupt_input[1]),
    .dout_async  (interrupt_controller_output_1[1])
  );

  assign shared_interrupt_enable_2_int[1] = shd_int_cfg_ici2_en_in[1] & SI1_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_1_2 (
    .din1_async  (shared_interrupt_enable_2_int[1]),
    .din2_async  (shared_interrupt_input[1]),
    .dout_async  (interrupt_controller_output_2[1])
  );

  assign shared_interrupt_enable_3_int[1] = shd_int_cfg_ici3_en_in[1] & SI1_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_1_3 (
    .din1_async  (shared_interrupt_enable_3_int[1]),
    .din2_async  (shared_interrupt_input[1]),
    .dout_async  (interrupt_controller_output_3[1])
  );


  assign shared_interrupt_enable_0_int[2] = shd_int_cfg_ici0_en_in[2] & SI2_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_2_0 (
    .din1_async  (shared_interrupt_enable_0_int[2]),
    .din2_async  (shared_interrupt_input[2]),
    .dout_async  (interrupt_controller_output_0[2])
  );

  assign shared_interrupt_enable_1_int[2] = shd_int_cfg_ici1_en_in[2] & SI2_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_2_1 (
    .din1_async  (shared_interrupt_enable_1_int[2]),
    .din2_async  (shared_interrupt_input[2]),
    .dout_async  (interrupt_controller_output_1[2])
  );

  assign shared_interrupt_enable_2_int[2] = shd_int_cfg_ici2_en_in[2] & SI2_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_2_2 (
    .din1_async  (shared_interrupt_enable_2_int[2]),
    .din2_async  (shared_interrupt_input[2]),
    .dout_async  (interrupt_controller_output_2[2])
  );

  assign shared_interrupt_enable_3_int[2] = shd_int_cfg_ici3_en_in[2] & SI2_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_2_3 (
    .din1_async  (shared_interrupt_enable_3_int[2]),
    .din2_async  (shared_interrupt_input[2]),
    .dout_async  (interrupt_controller_output_3[2])
  );


  assign shared_interrupt_enable_0_int[3] = shd_int_cfg_ici0_en_in[3] & SI3_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_3_0 (
    .din1_async  (shared_interrupt_enable_0_int[3]),
    .din2_async  (shared_interrupt_input[3]),
    .dout_async  (interrupt_controller_output_0[3])
  );

  assign shared_interrupt_enable_1_int[3] = shd_int_cfg_ici1_en_in[3] & SI3_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_3_1 (
    .din1_async  (shared_interrupt_enable_1_int[3]),
    .din2_async  (shared_interrupt_input[3]),
    .dout_async  (interrupt_controller_output_1[3])
  );

  assign shared_interrupt_enable_2_int[3] = shd_int_cfg_ici2_en_in[3] & SI3_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_3_2 (
    .din1_async  (shared_interrupt_enable_2_int[3]),
    .din2_async  (shared_interrupt_input[3]),
    .dout_async  (interrupt_controller_output_2[3])
  );

  assign shared_interrupt_enable_3_int[3] = shd_int_cfg_ici3_en_in[3] & SI3_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_3_3 (
    .din1_async  (shared_interrupt_enable_3_int[3]),
    .din2_async  (shared_interrupt_input[3]),
    .dout_async  (interrupt_controller_output_3[3])
  );


  assign shared_interrupt_enable_0_int[4] = shd_int_cfg_ici0_en_in[4] & SI4_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_4_0 (
    .din1_async  (shared_interrupt_enable_0_int[4]),
    .din2_async  (shared_interrupt_input[4]),
    .dout_async  (interrupt_controller_output_0[4])
  );

  assign shared_interrupt_enable_1_int[4] = shd_int_cfg_ici1_en_in[4] & SI4_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_4_1 (
    .din1_async  (shared_interrupt_enable_1_int[4]),
    .din2_async  (shared_interrupt_input[4]),
    .dout_async  (interrupt_controller_output_1[4])
  );

  assign shared_interrupt_enable_2_int[4] = shd_int_cfg_ici2_en_in[4] & SI4_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_4_2 (
    .din1_async  (shared_interrupt_enable_2_int[4]),
    .din2_async  (shared_interrupt_input[4]),
    .dout_async  (interrupt_controller_output_2[4])
  );

  assign shared_interrupt_enable_3_int[4] = shd_int_cfg_ici3_en_in[4] & SI4_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_4_3 (
    .din1_async  (shared_interrupt_enable_3_int[4]),
    .din2_async  (shared_interrupt_input[4]),
    .dout_async  (interrupt_controller_output_3[4])
  );


  assign shared_interrupt_enable_0_int[5] = shd_int_cfg_ici0_en_in[5] & SI5_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_5_0 (
    .din1_async  (shared_interrupt_enable_0_int[5]),
    .din2_async  (shared_interrupt_input[5]),
    .dout_async  (interrupt_controller_output_0[5])
  );

  assign shared_interrupt_enable_1_int[5] = shd_int_cfg_ici1_en_in[5] & SI5_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_5_1 (
    .din1_async  (shared_interrupt_enable_1_int[5]),
    .din2_async  (shared_interrupt_input[5]),
    .dout_async  (interrupt_controller_output_1[5])
  );

  assign shared_interrupt_enable_2_int[5] = shd_int_cfg_ici2_en_in[5] & SI5_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_5_2 (
    .din1_async  (shared_interrupt_enable_2_int[5]),
    .din2_async  (shared_interrupt_input[5]),
    .dout_async  (interrupt_controller_output_2[5])
  );

  assign shared_interrupt_enable_3_int[5] = shd_int_cfg_ici3_en_in[5] & SI5_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_5_3 (
    .din1_async  (shared_interrupt_enable_3_int[5]),
    .din2_async  (shared_interrupt_input[5]),
    .dout_async  (interrupt_controller_output_3[5])
  );


  assign shared_interrupt_enable_0_int[6] = shd_int_cfg_ici0_en_in[6] & SI6_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_6_0 (
    .din1_async  (shared_interrupt_enable_0_int[6]),
    .din2_async  (shared_interrupt_input[6]),
    .dout_async  (interrupt_controller_output_0[6])
  );

  assign shared_interrupt_enable_1_int[6] = shd_int_cfg_ici1_en_in[6] & SI6_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_6_1 (
    .din1_async  (shared_interrupt_enable_1_int[6]),
    .din2_async  (shared_interrupt_input[6]),
    .dout_async  (interrupt_controller_output_1[6])
  );

  assign shared_interrupt_enable_2_int[6] = shd_int_cfg_ici2_en_in[6] & SI6_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_6_2 (
    .din1_async  (shared_interrupt_enable_2_int[6]),
    .din2_async  (shared_interrupt_input[6]),
    .dout_async  (interrupt_controller_output_2[6])
  );

  assign shared_interrupt_enable_3_int[6] = shd_int_cfg_ici3_en_in[6] & SI6_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_6_3 (
    .din1_async  (shared_interrupt_enable_3_int[6]),
    .din2_async  (shared_interrupt_input[6]),
    .dout_async  (interrupt_controller_output_3[6])
  );


  assign shared_interrupt_enable_0_int[7] = shd_int_cfg_ici0_en_in[7] & SI7_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_7_0 (
    .din1_async  (shared_interrupt_enable_0_int[7]),
    .din2_async  (shared_interrupt_input[7]),
    .dout_async  (interrupt_controller_output_0[7])
  );

  assign shared_interrupt_enable_1_int[7] = shd_int_cfg_ici1_en_in[7] & SI7_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_7_1 (
    .din1_async  (shared_interrupt_enable_1_int[7]),
    .din2_async  (shared_interrupt_input[7]),
    .dout_async  (interrupt_controller_output_1[7])
  );

  assign shared_interrupt_enable_2_int[7] = shd_int_cfg_ici2_en_in[7] & SI7_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_7_2 (
    .din1_async  (shared_interrupt_enable_2_int[7]),
    .din2_async  (shared_interrupt_input[7]),
    .dout_async  (interrupt_controller_output_2[7])
  );

  assign shared_interrupt_enable_3_int[7] = shd_int_cfg_ici3_en_in[7] & SI7_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_7_3 (
    .din1_async  (shared_interrupt_enable_3_int[7]),
    .din2_async  (shared_interrupt_input[7]),
    .dout_async  (interrupt_controller_output_3[7])
  );


  assign shared_interrupt_enable_0_int[8] = shd_int_cfg_ici0_en_in[8] & SI8_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_8_0 (
    .din1_async  (shared_interrupt_enable_0_int[8]),
    .din2_async  (shared_interrupt_input[8]),
    .dout_async  (interrupt_controller_output_0[8])
  );

  assign shared_interrupt_enable_1_int[8] = shd_int_cfg_ici1_en_in[8] & SI8_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_8_1 (
    .din1_async  (shared_interrupt_enable_1_int[8]),
    .din2_async  (shared_interrupt_input[8]),
    .dout_async  (interrupt_controller_output_1[8])
  );

  assign shared_interrupt_enable_2_int[8] = shd_int_cfg_ici2_en_in[8] & SI8_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_8_2 (
    .din1_async  (shared_interrupt_enable_2_int[8]),
    .din2_async  (shared_interrupt_input[8]),
    .dout_async  (interrupt_controller_output_2[8])
  );

  assign shared_interrupt_enable_3_int[8] = shd_int_cfg_ici3_en_in[8] & SI8_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_8_3 (
    .din1_async  (shared_interrupt_enable_3_int[8]),
    .din2_async  (shared_interrupt_input[8]),
    .dout_async  (interrupt_controller_output_3[8])
  );


  assign shared_interrupt_enable_0_int[9] = shd_int_cfg_ici0_en_in[9] & SI9_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_9_0 (
    .din1_async  (shared_interrupt_enable_0_int[9]),
    .din2_async  (shared_interrupt_input[9]),
    .dout_async  (interrupt_controller_output_0[9])
  );

  assign shared_interrupt_enable_1_int[9] = shd_int_cfg_ici1_en_in[9] & SI9_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_9_1 (
    .din1_async  (shared_interrupt_enable_1_int[9]),
    .din2_async  (shared_interrupt_input[9]),
    .dout_async  (interrupt_controller_output_1[9])
  );

  assign shared_interrupt_enable_2_int[9] = shd_int_cfg_ici2_en_in[9] & SI9_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_9_2 (
    .din1_async  (shared_interrupt_enable_2_int[9]),
    .din2_async  (shared_interrupt_input[9]),
    .dout_async  (interrupt_controller_output_2[9])
  );

  assign shared_interrupt_enable_3_int[9] = shd_int_cfg_ici3_en_in[9] & SI9_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_9_3 (
    .din1_async  (shared_interrupt_enable_3_int[9]),
    .din2_async  (shared_interrupt_input[9]),
    .dout_async  (interrupt_controller_output_3[9])
  );


  assign shared_interrupt_enable_0_int[10] = shd_int_cfg_ici0_en_in[10] & SI10_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_10_0 (
    .din1_async  (shared_interrupt_enable_0_int[10]),
    .din2_async  (shared_interrupt_input[10]),
    .dout_async  (interrupt_controller_output_0[10])
  );

  assign shared_interrupt_enable_1_int[10] = shd_int_cfg_ici1_en_in[10] & SI10_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_10_1 (
    .din1_async  (shared_interrupt_enable_1_int[10]),
    .din2_async  (shared_interrupt_input[10]),
    .dout_async  (interrupt_controller_output_1[10])
  );

  assign shared_interrupt_enable_2_int[10] = shd_int_cfg_ici2_en_in[10] & SI10_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_10_2 (
    .din1_async  (shared_interrupt_enable_2_int[10]),
    .din2_async  (shared_interrupt_input[10]),
    .dout_async  (interrupt_controller_output_2[10])
  );

  assign shared_interrupt_enable_3_int[10] = shd_int_cfg_ici3_en_in[10] & SI10_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_10_3 (
    .din1_async  (shared_interrupt_enable_3_int[10]),
    .din2_async  (shared_interrupt_input[10]),
    .dout_async  (interrupt_controller_output_3[10])
  );


  assign shared_interrupt_enable_0_int[11] = shd_int_cfg_ici0_en_in[11] & SI11_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_11_0 (
    .din1_async  (shared_interrupt_enable_0_int[11]),
    .din2_async  (shared_interrupt_input[11]),
    .dout_async  (interrupt_controller_output_0[11])
  );

  assign shared_interrupt_enable_1_int[11] = shd_int_cfg_ici1_en_in[11] & SI11_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_11_1 (
    .din1_async  (shared_interrupt_enable_1_int[11]),
    .din2_async  (shared_interrupt_input[11]),
    .dout_async  (interrupt_controller_output_1[11])
  );

  assign shared_interrupt_enable_2_int[11] = shd_int_cfg_ici2_en_in[11] & SI11_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_11_2 (
    .din1_async  (shared_interrupt_enable_2_int[11]),
    .din2_async  (shared_interrupt_input[11]),
    .dout_async  (interrupt_controller_output_2[11])
  );

  assign shared_interrupt_enable_3_int[11] = shd_int_cfg_ici3_en_in[11] & SI11_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_11_3 (
    .din1_async  (shared_interrupt_enable_3_int[11]),
    .din2_async  (shared_interrupt_input[11]),
    .dout_async  (interrupt_controller_output_3[11])
  );


  assign shared_interrupt_enable_0_int[12] = shd_int_cfg_ici0_en_in[12] & SI12_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_12_0 (
    .din1_async  (shared_interrupt_enable_0_int[12]),
    .din2_async  (shared_interrupt_input[12]),
    .dout_async  (interrupt_controller_output_0[12])
  );

  assign shared_interrupt_enable_1_int[12] = shd_int_cfg_ici1_en_in[12] & SI12_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_12_1 (
    .din1_async  (shared_interrupt_enable_1_int[12]),
    .din2_async  (shared_interrupt_input[12]),
    .dout_async  (interrupt_controller_output_1[12])
  );

  assign shared_interrupt_enable_2_int[12] = shd_int_cfg_ici2_en_in[12] & SI12_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_12_2 (
    .din1_async  (shared_interrupt_enable_2_int[12]),
    .din2_async  (shared_interrupt_input[12]),
    .dout_async  (interrupt_controller_output_2[12])
  );

  assign shared_interrupt_enable_3_int[12] = shd_int_cfg_ici3_en_in[12] & SI12_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_12_3 (
    .din1_async  (shared_interrupt_enable_3_int[12]),
    .din2_async  (shared_interrupt_input[12]),
    .dout_async  (interrupt_controller_output_3[12])
  );


  assign shared_interrupt_enable_0_int[13] = shd_int_cfg_ici0_en_in[13] & SI13_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_13_0 (
    .din1_async  (shared_interrupt_enable_0_int[13]),
    .din2_async  (shared_interrupt_input[13]),
    .dout_async  (interrupt_controller_output_0[13])
  );

  assign shared_interrupt_enable_1_int[13] = shd_int_cfg_ici1_en_in[13] & SI13_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_13_1 (
    .din1_async  (shared_interrupt_enable_1_int[13]),
    .din2_async  (shared_interrupt_input[13]),
    .dout_async  (interrupt_controller_output_1[13])
  );

  assign shared_interrupt_enable_2_int[13] = shd_int_cfg_ici2_en_in[13] & SI13_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_13_2 (
    .din1_async  (shared_interrupt_enable_2_int[13]),
    .din2_async  (shared_interrupt_input[13]),
    .dout_async  (interrupt_controller_output_2[13])
  );

  assign shared_interrupt_enable_3_int[13] = shd_int_cfg_ici3_en_in[13] & SI13_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_13_3 (
    .din1_async  (shared_interrupt_enable_3_int[13]),
    .din2_async  (shared_interrupt_input[13]),
    .dout_async  (interrupt_controller_output_3[13])
  );


  assign shared_interrupt_enable_0_int[14] = shd_int_cfg_ici0_en_in[14] & SI14_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_14_0 (
    .din1_async  (shared_interrupt_enable_0_int[14]),
    .din2_async  (shared_interrupt_input[14]),
    .dout_async  (interrupt_controller_output_0[14])
  );

  assign shared_interrupt_enable_1_int[14] = shd_int_cfg_ici1_en_in[14] & SI14_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_14_1 (
    .din1_async  (shared_interrupt_enable_1_int[14]),
    .din2_async  (shared_interrupt_input[14]),
    .dout_async  (interrupt_controller_output_1[14])
  );

  assign shared_interrupt_enable_2_int[14] = shd_int_cfg_ici2_en_in[14] & SI14_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_14_2 (
    .din1_async  (shared_interrupt_enable_2_int[14]),
    .din2_async  (shared_interrupt_input[14]),
    .dout_async  (interrupt_controller_output_2[14])
  );

  assign shared_interrupt_enable_3_int[14] = shd_int_cfg_ici3_en_in[14] & SI14_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_14_3 (
    .din1_async  (shared_interrupt_enable_3_int[14]),
    .din2_async  (shared_interrupt_input[14]),
    .dout_async  (interrupt_controller_output_3[14])
  );


  assign shared_interrupt_enable_0_int[15] = shd_int_cfg_ici0_en_in[15] & SI15_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_15_0 (
    .din1_async  (shared_interrupt_enable_0_int[15]),
    .din2_async  (shared_interrupt_input[15]),
    .dout_async  (interrupt_controller_output_0[15])
  );

  assign shared_interrupt_enable_1_int[15] = shd_int_cfg_ici1_en_in[15] & SI15_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_15_1 (
    .din1_async  (shared_interrupt_enable_1_int[15]),
    .din2_async  (shared_interrupt_input[15]),
    .dout_async  (interrupt_controller_output_1[15])
  );

  assign shared_interrupt_enable_2_int[15] = shd_int_cfg_ici2_en_in[15] & SI15_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_15_2 (
    .din1_async  (shared_interrupt_enable_2_int[15]),
    .din2_async  (shared_interrupt_input[15]),
    .dout_async  (interrupt_controller_output_2[15])
  );

  assign shared_interrupt_enable_3_int[15] = shd_int_cfg_ici3_en_in[15] & SI15_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_15_3 (
    .din1_async  (shared_interrupt_enable_3_int[15]),
    .din2_async  (shared_interrupt_input[15]),
    .dout_async  (interrupt_controller_output_3[15])
  );


  assign shared_interrupt_enable_0_int[16] = shd_int_cfg_ici0_en_in[16] & SI16_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_16_0 (
    .din1_async  (shared_interrupt_enable_0_int[16]),
    .din2_async  (shared_interrupt_input[16]),
    .dout_async  (interrupt_controller_output_0[16])
  );

  assign shared_interrupt_enable_1_int[16] = shd_int_cfg_ici1_en_in[16] & SI16_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_16_1 (
    .din1_async  (shared_interrupt_enable_1_int[16]),
    .din2_async  (shared_interrupt_input[16]),
    .dout_async  (interrupt_controller_output_1[16])
  );

  assign shared_interrupt_enable_2_int[16] = shd_int_cfg_ici2_en_in[16] & SI16_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_16_2 (
    .din1_async  (shared_interrupt_enable_2_int[16]),
    .din2_async  (shared_interrupt_input[16]),
    .dout_async  (interrupt_controller_output_2[16])
  );

  assign shared_interrupt_enable_3_int[16] = shd_int_cfg_ici3_en_in[16] & SI16_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_16_3 (
    .din1_async  (shared_interrupt_enable_3_int[16]),
    .din2_async  (shared_interrupt_input[16]),
    .dout_async  (interrupt_controller_output_3[16])
  );


  assign shared_interrupt_enable_0_int[17] = shd_int_cfg_ici0_en_in[17] & SI17_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_17_0 (
    .din1_async  (shared_interrupt_enable_0_int[17]),
    .din2_async  (shared_interrupt_input[17]),
    .dout_async  (interrupt_controller_output_0[17])
  );

  assign shared_interrupt_enable_1_int[17] = shd_int_cfg_ici1_en_in[17] & SI17_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_17_1 (
    .din1_async  (shared_interrupt_enable_1_int[17]),
    .din2_async  (shared_interrupt_input[17]),
    .dout_async  (interrupt_controller_output_1[17])
  );

  assign shared_interrupt_enable_2_int[17] = shd_int_cfg_ici2_en_in[17] & SI17_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_17_2 (
    .din1_async  (shared_interrupt_enable_2_int[17]),
    .din2_async  (shared_interrupt_input[17]),
    .dout_async  (interrupt_controller_output_2[17])
  );

  assign shared_interrupt_enable_3_int[17] = shd_int_cfg_ici3_en_in[17] & SI17_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_17_3 (
    .din1_async  (shared_interrupt_enable_3_int[17]),
    .din2_async  (shared_interrupt_input[17]),
    .dout_async  (interrupt_controller_output_3[17])
  );


  assign shared_interrupt_enable_0_int[18] = shd_int_cfg_ici0_en_in[18] & SI18_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_18_0 (
    .din1_async  (shared_interrupt_enable_0_int[18]),
    .din2_async  (shared_interrupt_input[18]),
    .dout_async  (interrupt_controller_output_0[18])
  );

  assign shared_interrupt_enable_1_int[18] = shd_int_cfg_ici1_en_in[18] & SI18_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_18_1 (
    .din1_async  (shared_interrupt_enable_1_int[18]),
    .din2_async  (shared_interrupt_input[18]),
    .dout_async  (interrupt_controller_output_1[18])
  );

  assign shared_interrupt_enable_2_int[18] = shd_int_cfg_ici2_en_in[18] & SI18_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_18_2 (
    .din1_async  (shared_interrupt_enable_2_int[18]),
    .din2_async  (shared_interrupt_input[18]),
    .dout_async  (interrupt_controller_output_2[18])
  );

  assign shared_interrupt_enable_3_int[18] = shd_int_cfg_ici3_en_in[18] & SI18_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_18_3 (
    .din1_async  (shared_interrupt_enable_3_int[18]),
    .din2_async  (shared_interrupt_input[18]),
    .dout_async  (interrupt_controller_output_3[18])
  );


  assign shared_interrupt_enable_0_int[19] = shd_int_cfg_ici0_en_in[19] & SI19_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_19_0 (
    .din1_async  (shared_interrupt_enable_0_int[19]),
    .din2_async  (shared_interrupt_input[19]),
    .dout_async  (interrupt_controller_output_0[19])
  );

  assign shared_interrupt_enable_1_int[19] = shd_int_cfg_ici1_en_in[19] & SI19_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_19_1 (
    .din1_async  (shared_interrupt_enable_1_int[19]),
    .din2_async  (shared_interrupt_input[19]),
    .dout_async  (interrupt_controller_output_1[19])
  );

  assign shared_interrupt_enable_2_int[19] = shd_int_cfg_ici2_en_in[19] & SI19_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_19_2 (
    .din1_async  (shared_interrupt_enable_2_int[19]),
    .din2_async  (shared_interrupt_input[19]),
    .dout_async  (interrupt_controller_output_2[19])
  );

  assign shared_interrupt_enable_3_int[19] = shd_int_cfg_ici3_en_in[19] & SI19_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_19_3 (
    .din1_async  (shared_interrupt_enable_3_int[19]),
    .din2_async  (shared_interrupt_input[19]),
    .dout_async  (interrupt_controller_output_3[19])
  );


  assign shared_interrupt_enable_0_int[20] = shd_int_cfg_ici0_en_in[20] & SI20_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_20_0 (
    .din1_async  (shared_interrupt_enable_0_int[20]),
    .din2_async  (shared_interrupt_input[20]),
    .dout_async  (interrupt_controller_output_0[20])
  );

  assign shared_interrupt_enable_1_int[20] = shd_int_cfg_ici1_en_in[20] & SI20_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_20_1 (
    .din1_async  (shared_interrupt_enable_1_int[20]),
    .din2_async  (shared_interrupt_input[20]),
    .dout_async  (interrupt_controller_output_1[20])
  );

  assign shared_interrupt_enable_2_int[20] = shd_int_cfg_ici2_en_in[20] & SI20_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_20_2 (
    .din1_async  (shared_interrupt_enable_2_int[20]),
    .din2_async  (shared_interrupt_input[20]),
    .dout_async  (interrupt_controller_output_2[20])
  );

  assign shared_interrupt_enable_3_int[20] = shd_int_cfg_ici3_en_in[20] & SI20_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_20_3 (
    .din1_async  (shared_interrupt_enable_3_int[20]),
    .din2_async  (shared_interrupt_input[20]),
    .dout_async  (interrupt_controller_output_3[20])
  );


  assign shared_interrupt_enable_0_int[21] = shd_int_cfg_ici0_en_in[21] & SI21_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_21_0 (
    .din1_async  (shared_interrupt_enable_0_int[21]),
    .din2_async  (shared_interrupt_input[21]),
    .dout_async  (interrupt_controller_output_0[21])
  );

  assign shared_interrupt_enable_1_int[21] = shd_int_cfg_ici1_en_in[21] & SI21_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_21_1 (
    .din1_async  (shared_interrupt_enable_1_int[21]),
    .din2_async  (shared_interrupt_input[21]),
    .dout_async  (interrupt_controller_output_1[21])
  );

  assign shared_interrupt_enable_2_int[21] = shd_int_cfg_ici2_en_in[21] & SI21_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_21_2 (
    .din1_async  (shared_interrupt_enable_2_int[21]),
    .din2_async  (shared_interrupt_input[21]),
    .dout_async  (interrupt_controller_output_2[21])
  );

  assign shared_interrupt_enable_3_int[21] = shd_int_cfg_ici3_en_in[21] & SI21_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_21_3 (
    .din1_async  (shared_interrupt_enable_3_int[21]),
    .din2_async  (shared_interrupt_input[21]),
    .dout_async  (interrupt_controller_output_3[21])
  );


  assign shared_interrupt_enable_0_int[22] = shd_int_cfg_ici0_en_in[22] & SI22_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_22_0 (
    .din1_async  (shared_interrupt_enable_0_int[22]),
    .din2_async  (shared_interrupt_input[22]),
    .dout_async  (interrupt_controller_output_0[22])
  );

  assign shared_interrupt_enable_1_int[22] = shd_int_cfg_ici1_en_in[22] & SI22_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_22_1 (
    .din1_async  (shared_interrupt_enable_1_int[22]),
    .din2_async  (shared_interrupt_input[22]),
    .dout_async  (interrupt_controller_output_1[22])
  );

  assign shared_interrupt_enable_2_int[22] = shd_int_cfg_ici2_en_in[22] & SI22_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_22_2 (
    .din1_async  (shared_interrupt_enable_2_int[22]),
    .din2_async  (shared_interrupt_input[22]),
    .dout_async  (interrupt_controller_output_2[22])
  );

  assign shared_interrupt_enable_3_int[22] = shd_int_cfg_ici3_en_in[22] & SI22_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_22_3 (
    .din1_async  (shared_interrupt_enable_3_int[22]),
    .din2_async  (shared_interrupt_input[22]),
    .dout_async  (interrupt_controller_output_3[22])
  );


  assign shared_interrupt_enable_0_int[23] = shd_int_cfg_ici0_en_in[23] & SI23_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_23_0 (
    .din1_async  (shared_interrupt_enable_0_int[23]),
    .din2_async  (shared_interrupt_input[23]),
    .dout_async  (interrupt_controller_output_0[23])
  );

  assign shared_interrupt_enable_1_int[23] = shd_int_cfg_ici1_en_in[23] & SI23_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_23_1 (
    .din1_async  (shared_interrupt_enable_1_int[23]),
    .din2_async  (shared_interrupt_input[23]),
    .dout_async  (interrupt_controller_output_1[23])
  );

  assign shared_interrupt_enable_2_int[23] = shd_int_cfg_ici2_en_in[23] & SI23_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_23_2 (
    .din1_async  (shared_interrupt_enable_2_int[23]),
    .din2_async  (shared_interrupt_input[23]),
    .dout_async  (interrupt_controller_output_2[23])
  );

  assign shared_interrupt_enable_3_int[23] = shd_int_cfg_ici3_en_in[23] & SI23_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_23_3 (
    .din1_async  (shared_interrupt_enable_3_int[23]),
    .din2_async  (shared_interrupt_input[23]),
    .dout_async  (interrupt_controller_output_3[23])
  );


  assign shared_interrupt_enable_0_int[24] = shd_int_cfg_ici0_en_in[24] & SI24_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_24_0 (
    .din1_async  (shared_interrupt_enable_0_int[24]),
    .din2_async  (shared_interrupt_input[24]),
    .dout_async  (interrupt_controller_output_0[24])
  );

  assign shared_interrupt_enable_1_int[24] = shd_int_cfg_ici1_en_in[24] & SI24_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_24_1 (
    .din1_async  (shared_interrupt_enable_1_int[24]),
    .din2_async  (shared_interrupt_input[24]),
    .dout_async  (interrupt_controller_output_1[24])
  );

  assign shared_interrupt_enable_2_int[24] = shd_int_cfg_ici2_en_in[24] & SI24_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_24_2 (
    .din1_async  (shared_interrupt_enable_2_int[24]),
    .din2_async  (shared_interrupt_input[24]),
    .dout_async  (interrupt_controller_output_2[24])
  );

  assign shared_interrupt_enable_3_int[24] = shd_int_cfg_ici3_en_in[24] & SI24_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_24_3 (
    .din1_async  (shared_interrupt_enable_3_int[24]),
    .din2_async  (shared_interrupt_input[24]),
    .dout_async  (interrupt_controller_output_3[24])
  );


  assign shared_interrupt_enable_0_int[25] = shd_int_cfg_ici0_en_in[25] & SI25_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_25_0 (
    .din1_async  (shared_interrupt_enable_0_int[25]),
    .din2_async  (shared_interrupt_input[25]),
    .dout_async  (interrupt_controller_output_0[25])
  );

  assign shared_interrupt_enable_1_int[25] = shd_int_cfg_ici1_en_in[25] & SI25_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_25_1 (
    .din1_async  (shared_interrupt_enable_1_int[25]),
    .din2_async  (shared_interrupt_input[25]),
    .dout_async  (interrupt_controller_output_1[25])
  );

  assign shared_interrupt_enable_2_int[25] = shd_int_cfg_ici2_en_in[25] & SI25_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_25_2 (
    .din1_async  (shared_interrupt_enable_2_int[25]),
    .din2_async  (shared_interrupt_input[25]),
    .dout_async  (interrupt_controller_output_2[25])
  );

  assign shared_interrupt_enable_3_int[25] = shd_int_cfg_ici3_en_in[25] & SI25_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_25_3 (
    .din1_async  (shared_interrupt_enable_3_int[25]),
    .din2_async  (shared_interrupt_input[25]),
    .dout_async  (interrupt_controller_output_3[25])
  );


  assign shared_interrupt_enable_0_int[26] = shd_int_cfg_ici0_en_in[26] & SI26_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_26_0 (
    .din1_async  (shared_interrupt_enable_0_int[26]),
    .din2_async  (shared_interrupt_input[26]),
    .dout_async  (interrupt_controller_output_0[26])
  );

  assign shared_interrupt_enable_1_int[26] = shd_int_cfg_ici1_en_in[26] & SI26_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_26_1 (
    .din1_async  (shared_interrupt_enable_1_int[26]),
    .din2_async  (shared_interrupt_input[26]),
    .dout_async  (interrupt_controller_output_1[26])
  );

  assign shared_interrupt_enable_2_int[26] = shd_int_cfg_ici2_en_in[26] & SI26_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_26_2 (
    .din1_async  (shared_interrupt_enable_2_int[26]),
    .din2_async  (shared_interrupt_input[26]),
    .dout_async  (interrupt_controller_output_2[26])
  );

  assign shared_interrupt_enable_3_int[26] = shd_int_cfg_ici3_en_in[26] & SI26_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_26_3 (
    .din1_async  (shared_interrupt_enable_3_int[26]),
    .din2_async  (shared_interrupt_input[26]),
    .dout_async  (interrupt_controller_output_3[26])
  );


  assign shared_interrupt_enable_0_int[27] = shd_int_cfg_ici0_en_in[27] & SI27_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_27_0 (
    .din1_async  (shared_interrupt_enable_0_int[27]),
    .din2_async  (shared_interrupt_input[27]),
    .dout_async  (interrupt_controller_output_0[27])
  );

  assign shared_interrupt_enable_1_int[27] = shd_int_cfg_ici1_en_in[27] & SI27_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_27_1 (
    .din1_async  (shared_interrupt_enable_1_int[27]),
    .din2_async  (shared_interrupt_input[27]),
    .dout_async  (interrupt_controller_output_1[27])
  );

  assign shared_interrupt_enable_2_int[27] = shd_int_cfg_ici2_en_in[27] & SI27_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_27_2 (
    .din1_async  (shared_interrupt_enable_2_int[27]),
    .din2_async  (shared_interrupt_input[27]),
    .dout_async  (interrupt_controller_output_2[27])
  );

  assign shared_interrupt_enable_3_int[27] = shd_int_cfg_ici3_en_in[27] & SI27_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_27_3 (
    .din1_async  (shared_interrupt_enable_3_int[27]),
    .din2_async  (shared_interrupt_input[27]),
    .dout_async  (interrupt_controller_output_3[27])
  );


  assign shared_interrupt_enable_0_int[28] = shd_int_cfg_ici0_en_in[28] & SI28_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_28_0 (
    .din1_async  (shared_interrupt_enable_0_int[28]),
    .din2_async  (shared_interrupt_input[28]),
    .dout_async  (interrupt_controller_output_0[28])
  );

  assign shared_interrupt_enable_1_int[28] = shd_int_cfg_ici1_en_in[28] & SI28_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_28_1 (
    .din1_async  (shared_interrupt_enable_1_int[28]),
    .din2_async  (shared_interrupt_input[28]),
    .dout_async  (interrupt_controller_output_1[28])
  );

  assign shared_interrupt_enable_2_int[28] = shd_int_cfg_ici2_en_in[28] & SI28_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_28_2 (
    .din1_async  (shared_interrupt_enable_2_int[28]),
    .din2_async  (shared_interrupt_input[28]),
    .dout_async  (interrupt_controller_output_2[28])
  );

  assign shared_interrupt_enable_3_int[28] = shd_int_cfg_ici3_en_in[28] & SI28_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_28_3 (
    .din1_async  (shared_interrupt_enable_3_int[28]),
    .din2_async  (shared_interrupt_input[28]),
    .dout_async  (interrupt_controller_output_3[28])
  );


  assign shared_interrupt_enable_0_int[29] = shd_int_cfg_ici0_en_in[29] & SI29_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_29_0 (
    .din1_async  (shared_interrupt_enable_0_int[29]),
    .din2_async  (shared_interrupt_input[29]),
    .dout_async  (interrupt_controller_output_0[29])
  );

  assign shared_interrupt_enable_1_int[29] = shd_int_cfg_ici1_en_in[29] & SI29_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_29_1 (
    .din1_async  (shared_interrupt_enable_1_int[29]),
    .din2_async  (shared_interrupt_input[29]),
    .dout_async  (interrupt_controller_output_1[29])
  );

  assign shared_interrupt_enable_2_int[29] = shd_int_cfg_ici2_en_in[29] & SI29_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_29_2 (
    .din1_async  (shared_interrupt_enable_2_int[29]),
    .din2_async  (shared_interrupt_input[29]),
    .dout_async  (interrupt_controller_output_2[29])
  );

  assign shared_interrupt_enable_3_int[29] = shd_int_cfg_ici3_en_in[29] & SI29_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_29_3 (
    .din1_async  (shared_interrupt_enable_3_int[29]),
    .din2_async  (shared_interrupt_input[29]),
    .dout_async  (interrupt_controller_output_3[29])
  );


  assign shared_interrupt_enable_0_int[30] = shd_int_cfg_ici0_en_in[30] & SI30_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_30_0 (
    .din1_async  (shared_interrupt_enable_0_int[30]),
    .din2_async  (shared_interrupt_input[30]),
    .dout_async  (interrupt_controller_output_0[30])
  );

  assign shared_interrupt_enable_1_int[30] = shd_int_cfg_ici1_en_in[30] & SI30_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_30_1 (
    .din1_async  (shared_interrupt_enable_1_int[30]),
    .din2_async  (shared_interrupt_input[30]),
    .dout_async  (interrupt_controller_output_1[30])
  );

  assign shared_interrupt_enable_2_int[30] = shd_int_cfg_ici2_en_in[30] & SI30_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_30_2 (
    .din1_async  (shared_interrupt_enable_2_int[30]),
    .din2_async  (shared_interrupt_input[30]),
    .dout_async  (interrupt_controller_output_2[30])
  );

  assign shared_interrupt_enable_3_int[30] = shd_int_cfg_ici3_en_in[30] & SI30_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_30_3 (
    .din1_async  (shared_interrupt_enable_3_int[30]),
    .din2_async  (shared_interrupt_input[30]),
    .dout_async  (interrupt_controller_output_3[30])
  );


  assign shared_interrupt_enable_0_int[31] = shd_int_cfg_ici0_en_in[31] & SI31_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_31_0 (
    .din1_async  (shared_interrupt_enable_0_int[31]),
    .din2_async  (shared_interrupt_input[31]),
    .dout_async  (interrupt_controller_output_0[31])
  );

  assign shared_interrupt_enable_1_int[31] = shd_int_cfg_ici1_en_in[31] & SI31_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_31_1 (
    .din1_async  (shared_interrupt_enable_1_int[31]),
    .din2_async  (shared_interrupt_input[31]),
    .dout_async  (interrupt_controller_output_1[31])
  );

  assign shared_interrupt_enable_2_int[31] = shd_int_cfg_ici2_en_in[31] & SI31_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_31_2 (
    .din1_async  (shared_interrupt_enable_2_int[31]),
    .din2_async  (shared_interrupt_input[31]),
    .dout_async  (interrupt_controller_output_2[31])
  );

  assign shared_interrupt_enable_3_int[31] = shd_int_cfg_ici3_en_in[31] & SI31_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_31_3 (
    .din1_async  (shared_interrupt_enable_3_int[31]),
    .din2_async  (shared_interrupt_input[31]),
    .dout_async  (interrupt_controller_output_3[31])
  );


  assign shared_interrupt_enable_0_int[32] = shd_int_cfg_ici0_en_in[32] & SI32_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_32_0 (
    .din1_async  (shared_interrupt_enable_0_int[32]),
    .din2_async  (shared_interrupt_input[32]),
    .dout_async  (interrupt_controller_output_0[32])
  );

  assign shared_interrupt_enable_1_int[32] = shd_int_cfg_ici1_en_in[32] & SI32_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_32_1 (
    .din1_async  (shared_interrupt_enable_1_int[32]),
    .din2_async  (shared_interrupt_input[32]),
    .dout_async  (interrupt_controller_output_1[32])
  );

  assign shared_interrupt_enable_2_int[32] = shd_int_cfg_ici2_en_in[32] & SI32_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_32_2 (
    .din1_async  (shared_interrupt_enable_2_int[32]),
    .din2_async  (shared_interrupt_input[32]),
    .dout_async  (interrupt_controller_output_2[32])
  );

  assign shared_interrupt_enable_3_int[32] = shd_int_cfg_ici3_en_in[32] & SI32_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_32_3 (
    .din1_async  (shared_interrupt_enable_3_int[32]),
    .din2_async  (shared_interrupt_input[32]),
    .dout_async  (interrupt_controller_output_3[32])
  );


  assign shared_interrupt_enable_0_int[33] = shd_int_cfg_ici0_en_in[33] & SI33_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_33_0 (
    .din1_async  (shared_interrupt_enable_0_int[33]),
    .din2_async  (shared_interrupt_input[33]),
    .dout_async  (interrupt_controller_output_0[33])
  );

  assign shared_interrupt_enable_1_int[33] = shd_int_cfg_ici1_en_in[33] & SI33_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_33_1 (
    .din1_async  (shared_interrupt_enable_1_int[33]),
    .din2_async  (shared_interrupt_input[33]),
    .dout_async  (interrupt_controller_output_1[33])
  );

  assign shared_interrupt_enable_2_int[33] = shd_int_cfg_ici2_en_in[33] & SI33_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_33_2 (
    .din1_async  (shared_interrupt_enable_2_int[33]),
    .din2_async  (shared_interrupt_input[33]),
    .dout_async  (interrupt_controller_output_2[33])
  );

  assign shared_interrupt_enable_3_int[33] = shd_int_cfg_ici3_en_in[33] & SI33_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_33_3 (
    .din1_async  (shared_interrupt_enable_3_int[33]),
    .din2_async  (shared_interrupt_input[33]),
    .dout_async  (interrupt_controller_output_3[33])
  );


  assign shared_interrupt_enable_0_int[34] = shd_int_cfg_ici0_en_in[34] & SI34_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_34_0 (
    .din1_async  (shared_interrupt_enable_0_int[34]),
    .din2_async  (shared_interrupt_input[34]),
    .dout_async  (interrupt_controller_output_0[34])
  );

  assign shared_interrupt_enable_1_int[34] = shd_int_cfg_ici1_en_in[34] & SI34_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_34_1 (
    .din1_async  (shared_interrupt_enable_1_int[34]),
    .din2_async  (shared_interrupt_input[34]),
    .dout_async  (interrupt_controller_output_1[34])
  );

  assign shared_interrupt_enable_2_int[34] = shd_int_cfg_ici2_en_in[34] & SI34_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_34_2 (
    .din1_async  (shared_interrupt_enable_2_int[34]),
    .din2_async  (shared_interrupt_input[34]),
    .dout_async  (interrupt_controller_output_2[34])
  );

  assign shared_interrupt_enable_3_int[34] = shd_int_cfg_ici3_en_in[34] & SI34_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_34_3 (
    .din1_async  (shared_interrupt_enable_3_int[34]),
    .din2_async  (shared_interrupt_input[34]),
    .dout_async  (interrupt_controller_output_3[34])
  );


  assign shared_interrupt_enable_0_int[35] = shd_int_cfg_ici0_en_in[35] & SI35_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_35_0 (
    .din1_async  (shared_interrupt_enable_0_int[35]),
    .din2_async  (shared_interrupt_input[35]),
    .dout_async  (interrupt_controller_output_0[35])
  );

  assign shared_interrupt_enable_1_int[35] = shd_int_cfg_ici1_en_in[35] & SI35_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_35_1 (
    .din1_async  (shared_interrupt_enable_1_int[35]),
    .din2_async  (shared_interrupt_input[35]),
    .dout_async  (interrupt_controller_output_1[35])
  );

  assign shared_interrupt_enable_2_int[35] = shd_int_cfg_ici2_en_in[35] & SI35_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_35_2 (
    .din1_async  (shared_interrupt_enable_2_int[35]),
    .din2_async  (shared_interrupt_input[35]),
    .dout_async  (interrupt_controller_output_2[35])
  );

  assign shared_interrupt_enable_3_int[35] = shd_int_cfg_ici3_en_in[35] & SI35_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_35_3 (
    .din1_async  (shared_interrupt_enable_3_int[35]),
    .din2_async  (shared_interrupt_input[35]),
    .dout_async  (interrupt_controller_output_3[35])
  );


  assign shared_interrupt_enable_0_int[36] = shd_int_cfg_ici0_en_in[36] & SI36_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_36_0 (
    .din1_async  (shared_interrupt_enable_0_int[36]),
    .din2_async  (shared_interrupt_input[36]),
    .dout_async  (interrupt_controller_output_0[36])
  );

  assign shared_interrupt_enable_1_int[36] = shd_int_cfg_ici1_en_in[36] & SI36_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_36_1 (
    .din1_async  (shared_interrupt_enable_1_int[36]),
    .din2_async  (shared_interrupt_input[36]),
    .dout_async  (interrupt_controller_output_1[36])
  );

  assign shared_interrupt_enable_2_int[36] = shd_int_cfg_ici2_en_in[36] & SI36_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_36_2 (
    .din1_async  (shared_interrupt_enable_2_int[36]),
    .din2_async  (shared_interrupt_input[36]),
    .dout_async  (interrupt_controller_output_2[36])
  );

  assign shared_interrupt_enable_3_int[36] = shd_int_cfg_ici3_en_in[36] & SI36_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_36_3 (
    .din1_async  (shared_interrupt_enable_3_int[36]),
    .din2_async  (shared_interrupt_input[36]),
    .dout_async  (interrupt_controller_output_3[36])
  );


  assign shared_interrupt_enable_0_int[37] = shd_int_cfg_ici0_en_in[37] & SI37_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_37_0 (
    .din1_async  (shared_interrupt_enable_0_int[37]),
    .din2_async  (shared_interrupt_input[37]),
    .dout_async  (interrupt_controller_output_0[37])
  );

  assign shared_interrupt_enable_1_int[37] = shd_int_cfg_ici1_en_in[37] & SI37_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_37_1 (
    .din1_async  (shared_interrupt_enable_1_int[37]),
    .din2_async  (shared_interrupt_input[37]),
    .dout_async  (interrupt_controller_output_1[37])
  );

  assign shared_interrupt_enable_2_int[37] = shd_int_cfg_ici2_en_in[37] & SI37_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_37_2 (
    .din1_async  (shared_interrupt_enable_2_int[37]),
    .din2_async  (shared_interrupt_input[37]),
    .dout_async  (interrupt_controller_output_2[37])
  );

  assign shared_interrupt_enable_3_int[37] = shd_int_cfg_ici3_en_in[37] & SI37_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_37_3 (
    .din1_async  (shared_interrupt_enable_3_int[37]),
    .din2_async  (shared_interrupt_input[37]),
    .dout_async  (interrupt_controller_output_3[37])
  );


  assign shared_interrupt_enable_0_int[38] = shd_int_cfg_ici0_en_in[38] & SI38_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_38_0 (
    .din1_async  (shared_interrupt_enable_0_int[38]),
    .din2_async  (shared_interrupt_input[38]),
    .dout_async  (interrupt_controller_output_0[38])
  );

  assign shared_interrupt_enable_1_int[38] = shd_int_cfg_ici1_en_in[38] & SI38_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_38_1 (
    .din1_async  (shared_interrupt_enable_1_int[38]),
    .din2_async  (shared_interrupt_input[38]),
    .dout_async  (interrupt_controller_output_1[38])
  );

  assign shared_interrupt_enable_2_int[38] = shd_int_cfg_ici2_en_in[38] & SI38_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_38_2 (
    .din1_async  (shared_interrupt_enable_2_int[38]),
    .din2_async  (shared_interrupt_input[38]),
    .dout_async  (interrupt_controller_output_2[38])
  );

  assign shared_interrupt_enable_3_int[38] = shd_int_cfg_ici3_en_in[38] & SI38_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_38_3 (
    .din1_async  (shared_interrupt_enable_3_int[38]),
    .din2_async  (shared_interrupt_input[38]),
    .dout_async  (interrupt_controller_output_3[38])
  );


  assign shared_interrupt_enable_0_int[39] = shd_int_cfg_ici0_en_in[39] & SI39_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_39_0 (
    .din1_async  (shared_interrupt_enable_0_int[39]),
    .din2_async  (shared_interrupt_input[39]),
    .dout_async  (interrupt_controller_output_0[39])
  );

  assign shared_interrupt_enable_1_int[39] = shd_int_cfg_ici1_en_in[39] & SI39_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_39_1 (
    .din1_async  (shared_interrupt_enable_1_int[39]),
    .din2_async  (shared_interrupt_input[39]),
    .dout_async  (interrupt_controller_output_1[39])
  );

  assign shared_interrupt_enable_2_int[39] = shd_int_cfg_ici2_en_in[39] & SI39_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_39_2 (
    .din1_async  (shared_interrupt_enable_2_int[39]),
    .din2_async  (shared_interrupt_input[39]),
    .dout_async  (interrupt_controller_output_2[39])
  );

  assign shared_interrupt_enable_3_int[39] = shd_int_cfg_ici3_en_in[39] & SI39_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_39_3 (
    .din1_async  (shared_interrupt_enable_3_int[39]),
    .din2_async  (shared_interrupt_input[39]),
    .dout_async  (interrupt_controller_output_3[39])
  );


  assign shared_interrupt_enable_0_int[40] = shd_int_cfg_ici0_en_in[40] & SI40_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_40_0 (
    .din1_async  (shared_interrupt_enable_0_int[40]),
    .din2_async  (shared_interrupt_input[40]),
    .dout_async  (interrupt_controller_output_0[40])
  );

  assign shared_interrupt_enable_1_int[40] = shd_int_cfg_ici1_en_in[40] & SI40_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_40_1 (
    .din1_async  (shared_interrupt_enable_1_int[40]),
    .din2_async  (shared_interrupt_input[40]),
    .dout_async  (interrupt_controller_output_1[40])
  );

  assign shared_interrupt_enable_2_int[40] = shd_int_cfg_ici2_en_in[40] & SI40_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_40_2 (
    .din1_async  (shared_interrupt_enable_2_int[40]),
    .din2_async  (shared_interrupt_input[40]),
    .dout_async  (interrupt_controller_output_2[40])
  );

  assign shared_interrupt_enable_3_int[40] = shd_int_cfg_ici3_en_in[40] & SI40_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_40_3 (
    .din1_async  (shared_interrupt_enable_3_int[40]),
    .din2_async  (shared_interrupt_input[40]),
    .dout_async  (interrupt_controller_output_3[40])
  );


  assign shared_interrupt_enable_0_int[41] = shd_int_cfg_ici0_en_in[41] & SI41_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_41_0 (
    .din1_async  (shared_interrupt_enable_0_int[41]),
    .din2_async  (shared_interrupt_input[41]),
    .dout_async  (interrupt_controller_output_0[41])
  );

  assign shared_interrupt_enable_1_int[41] = shd_int_cfg_ici1_en_in[41] & SI41_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_41_1 (
    .din1_async  (shared_interrupt_enable_1_int[41]),
    .din2_async  (shared_interrupt_input[41]),
    .dout_async  (interrupt_controller_output_1[41])
  );

  assign shared_interrupt_enable_2_int[41] = shd_int_cfg_ici2_en_in[41] & SI41_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_41_2 (
    .din1_async  (shared_interrupt_enable_2_int[41]),
    .din2_async  (shared_interrupt_input[41]),
    .dout_async  (interrupt_controller_output_2[41])
  );

  assign shared_interrupt_enable_3_int[41] = shd_int_cfg_ici3_en_in[41] & SI41_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_41_3 (
    .din1_async  (shared_interrupt_enable_3_int[41]),
    .din2_async  (shared_interrupt_input[41]),
    .dout_async  (interrupt_controller_output_3[41])
  );


  assign shared_interrupt_enable_0_int[42] = shd_int_cfg_ici0_en_in[42] & SI42_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_42_0 (
    .din1_async  (shared_interrupt_enable_0_int[42]),
    .din2_async  (shared_interrupt_input[42]),
    .dout_async  (interrupt_controller_output_0[42])
  );

  assign shared_interrupt_enable_1_int[42] = shd_int_cfg_ici1_en_in[42] & SI42_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_42_1 (
    .din1_async  (shared_interrupt_enable_1_int[42]),
    .din2_async  (shared_interrupt_input[42]),
    .dout_async  (interrupt_controller_output_1[42])
  );

  assign shared_interrupt_enable_2_int[42] = shd_int_cfg_ici2_en_in[42] & SI42_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_42_2 (
    .din1_async  (shared_interrupt_enable_2_int[42]),
    .din2_async  (shared_interrupt_input[42]),
    .dout_async  (interrupt_controller_output_2[42])
  );

  assign shared_interrupt_enable_3_int[42] = shd_int_cfg_ici3_en_in[42] & SI42_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_42_3 (
    .din1_async  (shared_interrupt_enable_3_int[42]),
    .din2_async  (shared_interrupt_input[42]),
    .dout_async  (interrupt_controller_output_3[42])
  );


  assign shared_interrupt_enable_0_int[43] = shd_int_cfg_ici0_en_in[43] & SI43_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_43_0 (
    .din1_async  (shared_interrupt_enable_0_int[43]),
    .din2_async  (shared_interrupt_input[43]),
    .dout_async  (interrupt_controller_output_0[43])
  );

  assign shared_interrupt_enable_1_int[43] = shd_int_cfg_ici1_en_in[43] & SI43_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_43_1 (
    .din1_async  (shared_interrupt_enable_1_int[43]),
    .din2_async  (shared_interrupt_input[43]),
    .dout_async  (interrupt_controller_output_1[43])
  );

  assign shared_interrupt_enable_2_int[43] = shd_int_cfg_ici2_en_in[43] & SI43_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_43_2 (
    .din1_async  (shared_interrupt_enable_2_int[43]),
    .din2_async  (shared_interrupt_input[43]),
    .dout_async  (interrupt_controller_output_2[43])
  );

  assign shared_interrupt_enable_3_int[43] = shd_int_cfg_ici3_en_in[43] & SI43_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_43_3 (
    .din1_async  (shared_interrupt_enable_3_int[43]),
    .din2_async  (shared_interrupt_input[43]),
    .dout_async  (interrupt_controller_output_3[43])
  );


  assign shared_interrupt_enable_0_int[44] = shd_int_cfg_ici0_en_in[44] & SI44_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_44_0 (
    .din1_async  (shared_interrupt_enable_0_int[44]),
    .din2_async  (shared_interrupt_input[44]),
    .dout_async  (interrupt_controller_output_0[44])
  );

  assign shared_interrupt_enable_1_int[44] = shd_int_cfg_ici1_en_in[44] & SI44_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_44_1 (
    .din1_async  (shared_interrupt_enable_1_int[44]),
    .din2_async  (shared_interrupt_input[44]),
    .dout_async  (interrupt_controller_output_1[44])
  );

  assign shared_interrupt_enable_2_int[44] = shd_int_cfg_ici2_en_in[44] & SI44_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_44_2 (
    .din1_async  (shared_interrupt_enable_2_int[44]),
    .din2_async  (shared_interrupt_input[44]),
    .dout_async  (interrupt_controller_output_2[44])
  );

  assign shared_interrupt_enable_3_int[44] = shd_int_cfg_ici3_en_in[44] & SI44_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_44_3 (
    .din1_async  (shared_interrupt_enable_3_int[44]),
    .din2_async  (shared_interrupt_input[44]),
    .dout_async  (interrupt_controller_output_3[44])
  );


  assign shared_interrupt_enable_0_int[45] = shd_int_cfg_ici0_en_in[45] & SI45_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_45_0 (
    .din1_async  (shared_interrupt_enable_0_int[45]),
    .din2_async  (shared_interrupt_input[45]),
    .dout_async  (interrupt_controller_output_0[45])
  );

  assign shared_interrupt_enable_1_int[45] = shd_int_cfg_ici1_en_in[45] & SI45_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_45_1 (
    .din1_async  (shared_interrupt_enable_1_int[45]),
    .din2_async  (shared_interrupt_input[45]),
    .dout_async  (interrupt_controller_output_1[45])
  );

  assign shared_interrupt_enable_2_int[45] = shd_int_cfg_ici2_en_in[45] & SI45_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_45_2 (
    .din1_async  (shared_interrupt_enable_2_int[45]),
    .din2_async  (shared_interrupt_input[45]),
    .dout_async  (interrupt_controller_output_2[45])
  );

  assign shared_interrupt_enable_3_int[45] = shd_int_cfg_ici3_en_in[45] & SI45_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_45_3 (
    .din1_async  (shared_interrupt_enable_3_int[45]),
    .din2_async  (shared_interrupt_input[45]),
    .dout_async  (interrupt_controller_output_3[45])
  );


  assign shared_interrupt_enable_0_int[46] = shd_int_cfg_ici0_en_in[46] & SI46_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_46_0 (
    .din1_async  (shared_interrupt_enable_0_int[46]),
    .din2_async  (shared_interrupt_input[46]),
    .dout_async  (interrupt_controller_output_0[46])
  );

  assign shared_interrupt_enable_1_int[46] = shd_int_cfg_ici1_en_in[46] & SI46_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_46_1 (
    .din1_async  (shared_interrupt_enable_1_int[46]),
    .din2_async  (shared_interrupt_input[46]),
    .dout_async  (interrupt_controller_output_1[46])
  );

  assign shared_interrupt_enable_2_int[46] = shd_int_cfg_ici2_en_in[46] & SI46_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_46_2 (
    .din1_async  (shared_interrupt_enable_2_int[46]),
    .din2_async  (shared_interrupt_input[46]),
    .dout_async  (interrupt_controller_output_2[46])
  );

  assign shared_interrupt_enable_3_int[46] = shd_int_cfg_ici3_en_in[46] & SI46_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_46_3 (
    .din1_async  (shared_interrupt_enable_3_int[46]),
    .din2_async  (shared_interrupt_input[46]),
    .dout_async  (interrupt_controller_output_3[46])
  );


  assign shared_interrupt_enable_0_int[47] = shd_int_cfg_ici0_en_in[47] & SI47_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_47_0 (
    .din1_async  (shared_interrupt_enable_0_int[47]),
    .din2_async  (shared_interrupt_input[47]),
    .dout_async  (interrupt_controller_output_0[47])
  );

  assign shared_interrupt_enable_1_int[47] = shd_int_cfg_ici1_en_in[47] & SI47_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_47_1 (
    .din1_async  (shared_interrupt_enable_1_int[47]),
    .din2_async  (shared_interrupt_input[47]),
    .dout_async  (interrupt_controller_output_1[47])
  );

  assign shared_interrupt_enable_2_int[47] = shd_int_cfg_ici2_en_in[47] & SI47_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_47_2 (
    .din1_async  (shared_interrupt_enable_2_int[47]),
    .din2_async  (shared_interrupt_input[47]),
    .dout_async  (interrupt_controller_output_2[47])
  );

  assign shared_interrupt_enable_3_int[47] = shd_int_cfg_ici3_en_in[47] & SI47_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_47_3 (
    .din1_async  (shared_interrupt_enable_3_int[47]),
    .din2_async  (shared_interrupt_input[47]),
    .dout_async  (interrupt_controller_output_3[47])
  );


  assign shared_interrupt_enable_0_int[48] = shd_int_cfg_ici0_en_in[48] & SI48_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_48_0 (
    .din1_async  (shared_interrupt_enable_0_int[48]),
    .din2_async  (shared_interrupt_input[48]),
    .dout_async  (interrupt_controller_output_0[48])
  );

  assign shared_interrupt_enable_1_int[48] = shd_int_cfg_ici1_en_in[48] & SI48_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_48_1 (
    .din1_async  (shared_interrupt_enable_1_int[48]),
    .din2_async  (shared_interrupt_input[48]),
    .dout_async  (interrupt_controller_output_1[48])
  );

  assign shared_interrupt_enable_2_int[48] = shd_int_cfg_ici2_en_in[48] & SI48_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_48_2 (
    .din1_async  (shared_interrupt_enable_2_int[48]),
    .din2_async  (shared_interrupt_input[48]),
    .dout_async  (interrupt_controller_output_2[48])
  );

  assign shared_interrupt_enable_3_int[48] = shd_int_cfg_ici3_en_in[48] & SI48_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_48_3 (
    .din1_async  (shared_interrupt_enable_3_int[48]),
    .din2_async  (shared_interrupt_input[48]),
    .dout_async  (interrupt_controller_output_3[48])
  );


  assign shared_interrupt_enable_0_int[49] = shd_int_cfg_ici0_en_in[49] & SI49_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_49_0 (
    .din1_async  (shared_interrupt_enable_0_int[49]),
    .din2_async  (shared_interrupt_input[49]),
    .dout_async  (interrupt_controller_output_0[49])
  );

  assign shared_interrupt_enable_1_int[49] = shd_int_cfg_ici1_en_in[49] & SI49_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_49_1 (
    .din1_async  (shared_interrupt_enable_1_int[49]),
    .din2_async  (shared_interrupt_input[49]),
    .dout_async  (interrupt_controller_output_1[49])
  );

  assign shared_interrupt_enable_2_int[49] = shd_int_cfg_ici2_en_in[49] & SI49_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_49_2 (
    .din1_async  (shared_interrupt_enable_2_int[49]),
    .din2_async  (shared_interrupt_input[49]),
    .dout_async  (interrupt_controller_output_2[49])
  );

  assign shared_interrupt_enable_3_int[49] = shd_int_cfg_ici3_en_in[49] & SI49_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_49_3 (
    .din1_async  (shared_interrupt_enable_3_int[49]),
    .din2_async  (shared_interrupt_input[49]),
    .dout_async  (interrupt_controller_output_3[49])
  );


  assign shared_interrupt_enable_0_int[50] = shd_int_cfg_ici0_en_in[50] & SI50_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_50_0 (
    .din1_async  (shared_interrupt_enable_0_int[50]),
    .din2_async  (shared_interrupt_input[50]),
    .dout_async  (interrupt_controller_output_0[50])
  );

  assign shared_interrupt_enable_1_int[50] = shd_int_cfg_ici1_en_in[50] & SI50_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_50_1 (
    .din1_async  (shared_interrupt_enable_1_int[50]),
    .din2_async  (shared_interrupt_input[50]),
    .dout_async  (interrupt_controller_output_1[50])
  );

  assign shared_interrupt_enable_2_int[50] = shd_int_cfg_ici2_en_in[50] & SI50_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_50_2 (
    .din1_async  (shared_interrupt_enable_2_int[50]),
    .din2_async  (shared_interrupt_input[50]),
    .dout_async  (interrupt_controller_output_2[50])
  );

  assign shared_interrupt_enable_3_int[50] = shd_int_cfg_ici3_en_in[50] & SI50_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_50_3 (
    .din1_async  (shared_interrupt_enable_3_int[50]),
    .din2_async  (shared_interrupt_input[50]),
    .dout_async  (interrupt_controller_output_3[50])
  );


  assign shared_interrupt_enable_0_int[51] = shd_int_cfg_ici0_en_in[51] & SI51_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_51_0 (
    .din1_async  (shared_interrupt_enable_0_int[51]),
    .din2_async  (shared_interrupt_input[51]),
    .dout_async  (interrupt_controller_output_0[51])
  );

  assign shared_interrupt_enable_1_int[51] = shd_int_cfg_ici1_en_in[51] & SI51_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_51_1 (
    .din1_async  (shared_interrupt_enable_1_int[51]),
    .din2_async  (shared_interrupt_input[51]),
    .dout_async  (interrupt_controller_output_1[51])
  );

  assign shared_interrupt_enable_2_int[51] = shd_int_cfg_ici2_en_in[51] & SI51_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_51_2 (
    .din1_async  (shared_interrupt_enable_2_int[51]),
    .din2_async  (shared_interrupt_input[51]),
    .dout_async  (interrupt_controller_output_2[51])
  );

  assign shared_interrupt_enable_3_int[51] = shd_int_cfg_ici3_en_in[51] & SI51_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_51_3 (
    .din1_async  (shared_interrupt_enable_3_int[51]),
    .din2_async  (shared_interrupt_input[51]),
    .dout_async  (interrupt_controller_output_3[51])
  );


  assign shared_interrupt_enable_0_int[52] = shd_int_cfg_ici0_en_in[52] & SI52_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_52_0 (
    .din1_async  (shared_interrupt_enable_0_int[52]),
    .din2_async  (shared_interrupt_input[52]),
    .dout_async  (interrupt_controller_output_0[52])
  );

  assign shared_interrupt_enable_1_int[52] = shd_int_cfg_ici1_en_in[52] & SI52_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_52_1 (
    .din1_async  (shared_interrupt_enable_1_int[52]),
    .din2_async  (shared_interrupt_input[52]),
    .dout_async  (interrupt_controller_output_1[52])
  );

  assign shared_interrupt_enable_2_int[52] = shd_int_cfg_ici2_en_in[52] & SI52_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_52_2 (
    .din1_async  (shared_interrupt_enable_2_int[52]),
    .din2_async  (shared_interrupt_input[52]),
    .dout_async  (interrupt_controller_output_2[52])
  );

  assign shared_interrupt_enable_3_int[52] = shd_int_cfg_ici3_en_in[52] & SI52_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_52_3 (
    .din1_async  (shared_interrupt_enable_3_int[52]),
    .din2_async  (shared_interrupt_input[52]),
    .dout_async  (interrupt_controller_output_3[52])
  );


  assign shared_interrupt_enable_0_int[53] = shd_int_cfg_ici0_en_in[53] & SI53_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_53_0 (
    .din1_async  (shared_interrupt_enable_0_int[53]),
    .din2_async  (shared_interrupt_input[53]),
    .dout_async  (interrupt_controller_output_0[53])
  );

  assign shared_interrupt_enable_1_int[53] = shd_int_cfg_ici1_en_in[53] & SI53_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_53_1 (
    .din1_async  (shared_interrupt_enable_1_int[53]),
    .din2_async  (shared_interrupt_input[53]),
    .dout_async  (interrupt_controller_output_1[53])
  );

  assign shared_interrupt_enable_2_int[53] = shd_int_cfg_ici2_en_in[53] & SI53_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_53_2 (
    .din1_async  (shared_interrupt_enable_2_int[53]),
    .din2_async  (shared_interrupt_input[53]),
    .dout_async  (interrupt_controller_output_2[53])
  );

  assign shared_interrupt_enable_3_int[53] = shd_int_cfg_ici3_en_in[53] & SI53_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_53_3 (
    .din1_async  (shared_interrupt_enable_3_int[53]),
    .din2_async  (shared_interrupt_input[53]),
    .dout_async  (interrupt_controller_output_3[53])
  );


  assign shared_interrupt_enable_0_int[54] = shd_int_cfg_ici0_en_in[54] & SI54_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_54_0 (
    .din1_async  (shared_interrupt_enable_0_int[54]),
    .din2_async  (shared_interrupt_input[54]),
    .dout_async  (interrupt_controller_output_0[54])
  );

  assign shared_interrupt_enable_1_int[54] = shd_int_cfg_ici1_en_in[54] & SI54_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_54_1 (
    .din1_async  (shared_interrupt_enable_1_int[54]),
    .din2_async  (shared_interrupt_input[54]),
    .dout_async  (interrupt_controller_output_1[54])
  );

  assign shared_interrupt_enable_2_int[54] = shd_int_cfg_ici2_en_in[54] & SI54_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_54_2 (
    .din1_async  (shared_interrupt_enable_2_int[54]),
    .din2_async  (shared_interrupt_input[54]),
    .dout_async  (interrupt_controller_output_2[54])
  );

  assign shared_interrupt_enable_3_int[54] = shd_int_cfg_ici3_en_in[54] & SI54_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_54_3 (
    .din1_async  (shared_interrupt_enable_3_int[54]),
    .din2_async  (shared_interrupt_input[54]),
    .dout_async  (interrupt_controller_output_3[54])
  );


  assign shared_interrupt_enable_0_int[55] = shd_int_cfg_ici0_en_in[55] & SI55_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_55_0 (
    .din1_async  (shared_interrupt_enable_0_int[55]),
    .din2_async  (shared_interrupt_input[55]),
    .dout_async  (interrupt_controller_output_0[55])
  );

  assign shared_interrupt_enable_1_int[55] = shd_int_cfg_ici1_en_in[55] & SI55_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_55_1 (
    .din1_async  (shared_interrupt_enable_1_int[55]),
    .din2_async  (shared_interrupt_input[55]),
    .dout_async  (interrupt_controller_output_1[55])
  );

  assign shared_interrupt_enable_2_int[55] = shd_int_cfg_ici2_en_in[55] & SI55_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_55_2 (
    .din1_async  (shared_interrupt_enable_2_int[55]),
    .din2_async  (shared_interrupt_input[55]),
    .dout_async  (interrupt_controller_output_2[55])
  );

  assign shared_interrupt_enable_3_int[55] = shd_int_cfg_ici3_en_in[55] & SI55_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_55_3 (
    .din1_async  (shared_interrupt_enable_3_int[55]),
    .din2_async  (shared_interrupt_input[55]),
    .dout_async  (interrupt_controller_output_3[55])
  );


  assign shared_interrupt_enable_0_int[56] = shd_int_cfg_ici0_en_in[56] & SI56_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_56_0 (
    .din1_async  (shared_interrupt_enable_0_int[56]),
    .din2_async  (shared_interrupt_input[56]),
    .dout_async  (interrupt_controller_output_0[56])
  );

  assign shared_interrupt_enable_1_int[56] = shd_int_cfg_ici1_en_in[56] & SI56_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_56_1 (
    .din1_async  (shared_interrupt_enable_1_int[56]),
    .din2_async  (shared_interrupt_input[56]),
    .dout_async  (interrupt_controller_output_1[56])
  );

  assign shared_interrupt_enable_2_int[56] = shd_int_cfg_ici2_en_in[56] & SI56_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_56_2 (
    .din1_async  (shared_interrupt_enable_2_int[56]),
    .din2_async  (shared_interrupt_input[56]),
    .dout_async  (interrupt_controller_output_2[56])
  );

  assign shared_interrupt_enable_3_int[56] = shd_int_cfg_ici3_en_in[56] & SI56_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_56_3 (
    .din1_async  (shared_interrupt_enable_3_int[56]),
    .din2_async  (shared_interrupt_input[56]),
    .dout_async  (interrupt_controller_output_3[56])
  );


  assign shared_interrupt_enable_0_int[57] = shd_int_cfg_ici0_en_in[57] & SI57_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_57_0 (
    .din1_async  (shared_interrupt_enable_0_int[57]),
    .din2_async  (shared_interrupt_input[57]),
    .dout_async  (interrupt_controller_output_0[57])
  );

  assign shared_interrupt_enable_1_int[57] = shd_int_cfg_ici1_en_in[57] & SI57_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_57_1 (
    .din1_async  (shared_interrupt_enable_1_int[57]),
    .din2_async  (shared_interrupt_input[57]),
    .dout_async  (interrupt_controller_output_1[57])
  );

  assign shared_interrupt_enable_2_int[57] = shd_int_cfg_ici2_en_in[57] & SI57_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_57_2 (
    .din1_async  (shared_interrupt_enable_2_int[57]),
    .din2_async  (shared_interrupt_input[57]),
    .dout_async  (interrupt_controller_output_2[57])
  );

  assign shared_interrupt_enable_3_int[57] = shd_int_cfg_ici3_en_in[57] & SI57_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_57_3 (
    .din1_async  (shared_interrupt_enable_3_int[57]),
    .din2_async  (shared_interrupt_input[57]),
    .dout_async  (interrupt_controller_output_3[57])
  );


  assign shared_interrupt_enable_0_int[58] = shd_int_cfg_ici0_en_in[58] & SI58_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_58_0 (
    .din1_async  (shared_interrupt_enable_0_int[58]),
    .din2_async  (shared_interrupt_input[58]),
    .dout_async  (interrupt_controller_output_0[58])
  );

  assign shared_interrupt_enable_1_int[58] = shd_int_cfg_ici1_en_in[58] & SI58_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_58_1 (
    .din1_async  (shared_interrupt_enable_1_int[58]),
    .din2_async  (shared_interrupt_input[58]),
    .dout_async  (interrupt_controller_output_1[58])
  );

  assign shared_interrupt_enable_2_int[58] = shd_int_cfg_ici2_en_in[58] & SI58_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_58_2 (
    .din1_async  (shared_interrupt_enable_2_int[58]),
    .din2_async  (shared_interrupt_input[58]),
    .dout_async  (interrupt_controller_output_2[58])
  );

  assign shared_interrupt_enable_3_int[58] = shd_int_cfg_ici3_en_in[58] & SI58_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_58_3 (
    .din1_async  (shared_interrupt_enable_3_int[58]),
    .din2_async  (shared_interrupt_input[58]),
    .dout_async  (interrupt_controller_output_3[58])
  );


  assign shared_interrupt_enable_0_int[59] = shd_int_cfg_ici0_en_in[59] & SI59_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_59_0 (
    .din1_async  (shared_interrupt_enable_0_int[59]),
    .din2_async  (shared_interrupt_input[59]),
    .dout_async  (interrupt_controller_output_0[59])
  );

  assign shared_interrupt_enable_1_int[59] = shd_int_cfg_ici1_en_in[59] & SI59_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_59_1 (
    .din1_async  (shared_interrupt_enable_1_int[59]),
    .din2_async  (shared_interrupt_input[59]),
    .dout_async  (interrupt_controller_output_1[59])
  );

  assign shared_interrupt_enable_2_int[59] = shd_int_cfg_ici2_en_in[59] & SI59_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_59_2 (
    .din1_async  (shared_interrupt_enable_2_int[59]),
    .din2_async  (shared_interrupt_input[59]),
    .dout_async  (interrupt_controller_output_2[59])
  );

  assign shared_interrupt_enable_3_int[59] = shd_int_cfg_ici3_en_in[59] & SI59_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_59_3 (
    .din1_async  (shared_interrupt_enable_3_int[59]),
    .din2_async  (shared_interrupt_input[59]),
    .dout_async  (interrupt_controller_output_3[59])
  );


  assign shared_interrupt_enable_0_int[60] = shd_int_cfg_ici0_en_in[60] & SI60_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_60_0 (
    .din1_async  (shared_interrupt_enable_0_int[60]),
    .din2_async  (shared_interrupt_input[60]),
    .dout_async  (interrupt_controller_output_0[60])
  );

  assign shared_interrupt_enable_1_int[60] = shd_int_cfg_ici1_en_in[60] & SI60_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_60_1 (
    .din1_async  (shared_interrupt_enable_1_int[60]),
    .din2_async  (shared_interrupt_input[60]),
    .dout_async  (interrupt_controller_output_1[60])
  );

  assign shared_interrupt_enable_2_int[60] = shd_int_cfg_ici2_en_in[60] & SI60_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_60_2 (
    .din1_async  (shared_interrupt_enable_2_int[60]),
    .din2_async  (shared_interrupt_input[60]),
    .dout_async  (interrupt_controller_output_2[60])
  );

  assign shared_interrupt_enable_3_int[60] = shd_int_cfg_ici3_en_in[60] & SI60_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_60_3 (
    .din1_async  (shared_interrupt_enable_3_int[60]),
    .din2_async  (shared_interrupt_input[60]),
    .dout_async  (interrupt_controller_output_3[60])
  );


  assign shared_interrupt_enable_0_int[61] = shd_int_cfg_ici0_en_in[61] & SI61_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_61_0 (
    .din1_async  (shared_interrupt_enable_0_int[61]),
    .din2_async  (shared_interrupt_input[61]),
    .dout_async  (interrupt_controller_output_0[61])
  );

  assign shared_interrupt_enable_1_int[61] = shd_int_cfg_ici1_en_in[61] & SI61_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_61_1 (
    .din1_async  (shared_interrupt_enable_1_int[61]),
    .din2_async  (shared_interrupt_input[61]),
    .dout_async  (interrupt_controller_output_1[61])
  );

  assign shared_interrupt_enable_2_int[61] = shd_int_cfg_ici2_en_in[61] & SI61_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_61_2 (
    .din1_async  (shared_interrupt_enable_2_int[61]),
    .din2_async  (shared_interrupt_input[61]),
    .dout_async  (interrupt_controller_output_2[61])
  );

  assign shared_interrupt_enable_3_int[61] = shd_int_cfg_ici3_en_in[61] & SI61_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_61_3 (
    .din1_async  (shared_interrupt_enable_3_int[61]),
    .din2_async  (shared_interrupt_input[61]),
    .dout_async  (interrupt_controller_output_3[61])
  );


  assign shared_interrupt_enable_0_int[62] = shd_int_cfg_ici0_en_in[62] & SI62_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_62_0 (
    .din1_async  (shared_interrupt_enable_0_int[62]),
    .din2_async  (shared_interrupt_input[62]),
    .dout_async  (interrupt_controller_output_0[62])
  );

  assign shared_interrupt_enable_1_int[62] = shd_int_cfg_ici1_en_in[62] & SI62_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_62_1 (
    .din1_async  (shared_interrupt_enable_1_int[62]),
    .din2_async  (shared_interrupt_input[62]),
    .dout_async  (interrupt_controller_output_1[62])
  );

  assign shared_interrupt_enable_2_int[62] = shd_int_cfg_ici2_en_in[62] & SI62_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_62_2 (
    .din1_async  (shared_interrupt_enable_2_int[62]),
    .din2_async  (shared_interrupt_input[62]),
    .dout_async  (interrupt_controller_output_2[62])
  );

  assign shared_interrupt_enable_3_int[62] = shd_int_cfg_ici3_en_in[62] & SI62_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_62_3 (
    .din1_async  (shared_interrupt_enable_3_int[62]),
    .din2_async  (shared_interrupt_input[62]),
    .dout_async  (interrupt_controller_output_3[62])
  );


  assign shared_interrupt_enable_0_int[63] = shd_int_cfg_ici0_en_in[63] & SI63_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_63_0 (
    .din1_async  (shared_interrupt_enable_0_int[63]),
    .din2_async  (shared_interrupt_input[63]),
    .dout_async  (interrupt_controller_output_0[63])
  );

  assign shared_interrupt_enable_1_int[63] = shd_int_cfg_ici1_en_in[63] & SI63_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_63_1 (
    .din1_async  (shared_interrupt_enable_1_int[63]),
    .din2_async  (shared_interrupt_input[63]),
    .dout_async  (interrupt_controller_output_1[63])
  );

  assign shared_interrupt_enable_2_int[63] = shd_int_cfg_ici2_en_in[63] & SI63_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_63_2 (
    .din1_async  (shared_interrupt_enable_2_int[63]),
    .din2_async  (shared_interrupt_input[63]),
    .dout_async  (interrupt_controller_output_2[63])
  );

  assign shared_interrupt_enable_3_int[63] = shd_int_cfg_ici3_en_in[63] & SI63_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_63_3 (
    .din1_async  (shared_interrupt_enable_3_int[63]),
    .din2_async  (shared_interrupt_input[63]),
    .dout_async  (interrupt_controller_output_3[63])
  );


  assign shared_interrupt_enable_0_int[64] = shd_int_cfg_ici0_en_in[64] & SI64_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_64_0 (
    .din1_async  (shared_interrupt_enable_0_int[64]),
    .din2_async  (shared_interrupt_input[64]),
    .dout_async  (interrupt_controller_output_0[64])
  );

  assign shared_interrupt_enable_1_int[64] = shd_int_cfg_ici1_en_in[64] & SI64_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_64_1 (
    .din1_async  (shared_interrupt_enable_1_int[64]),
    .din2_async  (shared_interrupt_input[64]),
    .dout_async  (interrupt_controller_output_1[64])
  );

  assign shared_interrupt_enable_2_int[64] = shd_int_cfg_ici2_en_in[64] & SI64_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_64_2 (
    .din1_async  (shared_interrupt_enable_2_int[64]),
    .din2_async  (shared_interrupt_input[64]),
    .dout_async  (interrupt_controller_output_2[64])
  );

  assign shared_interrupt_enable_3_int[64] = shd_int_cfg_ici3_en_in[64] & SI64_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_64_3 (
    .din1_async  (shared_interrupt_enable_3_int[64]),
    .din2_async  (shared_interrupt_input[64]),
    .dout_async  (interrupt_controller_output_3[64])
  );


  assign shared_interrupt_enable_0_int[65] = shd_int_cfg_ici0_en_in[65] & SI65_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_65_0 (
    .din1_async  (shared_interrupt_enable_0_int[65]),
    .din2_async  (shared_interrupt_input[65]),
    .dout_async  (interrupt_controller_output_0[65])
  );

  assign shared_interrupt_enable_1_int[65] = shd_int_cfg_ici1_en_in[65] & SI65_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_65_1 (
    .din1_async  (shared_interrupt_enable_1_int[65]),
    .din2_async  (shared_interrupt_input[65]),
    .dout_async  (interrupt_controller_output_1[65])
  );

  assign shared_interrupt_enable_2_int[65] = shd_int_cfg_ici2_en_in[65] & SI65_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_65_2 (
    .din1_async  (shared_interrupt_enable_2_int[65]),
    .din2_async  (shared_interrupt_input[65]),
    .dout_async  (interrupt_controller_output_2[65])
  );

  assign shared_interrupt_enable_3_int[65] = shd_int_cfg_ici3_en_in[65] & SI65_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_65_3 (
    .din1_async  (shared_interrupt_enable_3_int[65]),
    .din2_async  (shared_interrupt_input[65]),
    .dout_async  (interrupt_controller_output_3[65])
  );


  assign shared_interrupt_enable_0_int[66] = shd_int_cfg_ici0_en_in[66] & SI66_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_66_0 (
    .din1_async  (shared_interrupt_enable_0_int[66]),
    .din2_async  (shared_interrupt_input[66]),
    .dout_async  (interrupt_controller_output_0[66])
  );

  assign shared_interrupt_enable_1_int[66] = shd_int_cfg_ici1_en_in[66] & SI66_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_66_1 (
    .din1_async  (shared_interrupt_enable_1_int[66]),
    .din2_async  (shared_interrupt_input[66]),
    .dout_async  (interrupt_controller_output_1[66])
  );

  assign shared_interrupt_enable_2_int[66] = shd_int_cfg_ici2_en_in[66] & SI66_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_66_2 (
    .din1_async  (shared_interrupt_enable_2_int[66]),
    .din2_async  (shared_interrupt_input[66]),
    .dout_async  (interrupt_controller_output_2[66])
  );

  assign shared_interrupt_enable_3_int[66] = shd_int_cfg_ici3_en_in[66] & SI66_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_66_3 (
    .din1_async  (shared_interrupt_enable_3_int[66]),
    .din2_async  (shared_interrupt_input[66]),
    .dout_async  (interrupt_controller_output_3[66])
  );


  assign shared_interrupt_enable_0_int[67] = shd_int_cfg_ici0_en_in[67] & SI67_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_67_0 (
    .din1_async  (shared_interrupt_enable_0_int[67]),
    .din2_async  (shared_interrupt_input[67]),
    .dout_async  (interrupt_controller_output_0[67])
  );

  assign shared_interrupt_enable_1_int[67] = shd_int_cfg_ici1_en_in[67] & SI67_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_67_1 (
    .din1_async  (shared_interrupt_enable_1_int[67]),
    .din2_async  (shared_interrupt_input[67]),
    .dout_async  (interrupt_controller_output_1[67])
  );

  assign shared_interrupt_enable_2_int[67] = shd_int_cfg_ici2_en_in[67] & SI67_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_67_2 (
    .din1_async  (shared_interrupt_enable_2_int[67]),
    .din2_async  (shared_interrupt_input[67]),
    .dout_async  (interrupt_controller_output_2[67])
  );

  assign shared_interrupt_enable_3_int[67] = shd_int_cfg_ici3_en_in[67] & SI67_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_67_3 (
    .din1_async  (shared_interrupt_enable_3_int[67]),
    .din2_async  (shared_interrupt_input[67]),
    .dout_async  (interrupt_controller_output_3[67])
  );


  assign shared_interrupt_enable_0_int[68] = shd_int_cfg_ici0_en_in[68] & SI68_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_68_0 (
    .din1_async  (shared_interrupt_enable_0_int[68]),
    .din2_async  (shared_interrupt_input[68]),
    .dout_async  (interrupt_controller_output_0[68])
  );

  assign shared_interrupt_enable_1_int[68] = shd_int_cfg_ici1_en_in[68] & SI68_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_68_1 (
    .din1_async  (shared_interrupt_enable_1_int[68]),
    .din2_async  (shared_interrupt_input[68]),
    .dout_async  (interrupt_controller_output_1[68])
  );

  assign shared_interrupt_enable_2_int[68] = shd_int_cfg_ici2_en_in[68] & SI68_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_68_2 (
    .din1_async  (shared_interrupt_enable_2_int[68]),
    .din2_async  (shared_interrupt_input[68]),
    .dout_async  (interrupt_controller_output_2[68])
  );

  assign shared_interrupt_enable_3_int[68] = shd_int_cfg_ici3_en_in[68] & SI68_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_68_3 (
    .din1_async  (shared_interrupt_enable_3_int[68]),
    .din2_async  (shared_interrupt_input[68]),
    .dout_async  (interrupt_controller_output_3[68])
  );


  assign shared_interrupt_enable_0_int[69] = shd_int_cfg_ici0_en_in[69] & SI69_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_69_0 (
    .din1_async  (shared_interrupt_enable_0_int[69]),
    .din2_async  (shared_interrupt_input[69]),
    .dout_async  (interrupt_controller_output_0[69])
  );

  assign shared_interrupt_enable_1_int[69] = shd_int_cfg_ici1_en_in[69] & SI69_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_69_1 (
    .din1_async  (shared_interrupt_enable_1_int[69]),
    .din2_async  (shared_interrupt_input[69]),
    .dout_async  (interrupt_controller_output_1[69])
  );

  assign shared_interrupt_enable_2_int[69] = shd_int_cfg_ici2_en_in[69] & SI69_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_69_2 (
    .din1_async  (shared_interrupt_enable_2_int[69]),
    .din2_async  (shared_interrupt_input[69]),
    .dout_async  (interrupt_controller_output_2[69])
  );

  assign shared_interrupt_enable_3_int[69] = shd_int_cfg_ici3_en_in[69] & SI69_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_69_3 (
    .din1_async  (shared_interrupt_enable_3_int[69]),
    .din2_async  (shared_interrupt_input[69]),
    .dout_async  (interrupt_controller_output_3[69])
  );


  assign shared_interrupt_enable_0_int[70] = shd_int_cfg_ici0_en_in[70] & SI70_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_70_0 (
    .din1_async  (shared_interrupt_enable_0_int[70]),
    .din2_async  (shared_interrupt_input[70]),
    .dout_async  (interrupt_controller_output_0[70])
  );

  assign shared_interrupt_enable_1_int[70] = shd_int_cfg_ici1_en_in[70] & SI70_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_70_1 (
    .din1_async  (shared_interrupt_enable_1_int[70]),
    .din2_async  (shared_interrupt_input[70]),
    .dout_async  (interrupt_controller_output_1[70])
  );

  assign shared_interrupt_enable_2_int[70] = shd_int_cfg_ici2_en_in[70] & SI70_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_70_2 (
    .din1_async  (shared_interrupt_enable_2_int[70]),
    .din2_async  (shared_interrupt_input[70]),
    .dout_async  (interrupt_controller_output_2[70])
  );

  assign shared_interrupt_enable_3_int[70] = shd_int_cfg_ici3_en_in[70] & SI70_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_70_3 (
    .din1_async  (shared_interrupt_enable_3_int[70]),
    .din2_async  (shared_interrupt_input[70]),
    .dout_async  (interrupt_controller_output_3[70])
  );


  assign shared_interrupt_enable_0_int[71] = shd_int_cfg_ici0_en_in[71] & SI71_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_71_0 (
    .din1_async  (shared_interrupt_enable_0_int[71]),
    .din2_async  (shared_interrupt_input[71]),
    .dout_async  (interrupt_controller_output_0[71])
  );

  assign shared_interrupt_enable_1_int[71] = shd_int_cfg_ici1_en_in[71] & SI71_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_71_1 (
    .din1_async  (shared_interrupt_enable_1_int[71]),
    .din2_async  (shared_interrupt_input[71]),
    .dout_async  (interrupt_controller_output_1[71])
  );

  assign shared_interrupt_enable_2_int[71] = shd_int_cfg_ici2_en_in[71] & SI71_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_71_2 (
    .din1_async  (shared_interrupt_enable_2_int[71]),
    .din2_async  (shared_interrupt_input[71]),
    .dout_async  (interrupt_controller_output_2[71])
  );

  assign shared_interrupt_enable_3_int[71] = shd_int_cfg_ici3_en_in[71] & SI71_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_71_3 (
    .din1_async  (shared_interrupt_enable_3_int[71]),
    .din2_async  (shared_interrupt_input[71]),
    .dout_async  (interrupt_controller_output_3[71])
  );


  assign shared_interrupt_enable_0_int[72] = shd_int_cfg_ici0_en_in[72] & SI72_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_72_0 (
    .din1_async  (shared_interrupt_enable_0_int[72]),
    .din2_async  (shared_interrupt_input[72]),
    .dout_async  (interrupt_controller_output_0[72])
  );

  assign shared_interrupt_enable_1_int[72] = shd_int_cfg_ici1_en_in[72] & SI72_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_72_1 (
    .din1_async  (shared_interrupt_enable_1_int[72]),
    .din2_async  (shared_interrupt_input[72]),
    .dout_async  (interrupt_controller_output_1[72])
  );

  assign shared_interrupt_enable_2_int[72] = shd_int_cfg_ici2_en_in[72] & SI72_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_72_2 (
    .din1_async  (shared_interrupt_enable_2_int[72]),
    .din2_async  (shared_interrupt_input[72]),
    .dout_async  (interrupt_controller_output_2[72])
  );

  assign shared_interrupt_enable_3_int[72] = shd_int_cfg_ici3_en_in[72] & SI72_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_72_3 (
    .din1_async  (shared_interrupt_enable_3_int[72]),
    .din2_async  (shared_interrupt_input[72]),
    .dout_async  (interrupt_controller_output_3[72])
  );


  assign shared_interrupt_enable_0_int[73] = shd_int_cfg_ici0_en_in[73] & SI73_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_73_0 (
    .din1_async  (shared_interrupt_enable_0_int[73]),
    .din2_async  (shared_interrupt_input[73]),
    .dout_async  (interrupt_controller_output_0[73])
  );

  assign shared_interrupt_enable_1_int[73] = shd_int_cfg_ici1_en_in[73] & SI73_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_73_1 (
    .din1_async  (shared_interrupt_enable_1_int[73]),
    .din2_async  (shared_interrupt_input[73]),
    .dout_async  (interrupt_controller_output_1[73])
  );

  assign shared_interrupt_enable_2_int[73] = shd_int_cfg_ici2_en_in[73] & SI73_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_73_2 (
    .din1_async  (shared_interrupt_enable_2_int[73]),
    .din2_async  (shared_interrupt_input[73]),
    .dout_async  (interrupt_controller_output_2[73])
  );

  assign shared_interrupt_enable_3_int[73] = shd_int_cfg_ici3_en_in[73] & SI73_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_73_3 (
    .din1_async  (shared_interrupt_enable_3_int[73]),
    .din2_async  (shared_interrupt_input[73]),
    .dout_async  (interrupt_controller_output_3[73])
  );


  assign shared_interrupt_enable_0_int[74] = shd_int_cfg_ici0_en_in[74] & SI74_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_74_0 (
    .din1_async  (shared_interrupt_enable_0_int[74]),
    .din2_async  (shared_interrupt_input[74]),
    .dout_async  (interrupt_controller_output_0[74])
  );

  assign shared_interrupt_enable_1_int[74] = shd_int_cfg_ici1_en_in[74] & SI74_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_74_1 (
    .din1_async  (shared_interrupt_enable_1_int[74]),
    .din2_async  (shared_interrupt_input[74]),
    .dout_async  (interrupt_controller_output_1[74])
  );

  assign shared_interrupt_enable_2_int[74] = shd_int_cfg_ici2_en_in[74] & SI74_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_74_2 (
    .din1_async  (shared_interrupt_enable_2_int[74]),
    .din2_async  (shared_interrupt_input[74]),
    .dout_async  (interrupt_controller_output_2[74])
  );

  assign shared_interrupt_enable_3_int[74] = shd_int_cfg_ici3_en_in[74] & SI74_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_74_3 (
    .din1_async  (shared_interrupt_enable_3_int[74]),
    .din2_async  (shared_interrupt_input[74]),
    .dout_async  (interrupt_controller_output_3[74])
  );


  assign shared_interrupt_enable_0_int[75] = shd_int_cfg_ici0_en_in[75] & SI75_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_75_0 (
    .din1_async  (shared_interrupt_enable_0_int[75]),
    .din2_async  (shared_interrupt_input[75]),
    .dout_async  (interrupt_controller_output_0[75])
  );

  assign shared_interrupt_enable_1_int[75] = shd_int_cfg_ici1_en_in[75] & SI75_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_75_1 (
    .din1_async  (shared_interrupt_enable_1_int[75]),
    .din2_async  (shared_interrupt_input[75]),
    .dout_async  (interrupt_controller_output_1[75])
  );

  assign shared_interrupt_enable_2_int[75] = shd_int_cfg_ici2_en_in[75] & SI75_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_75_2 (
    .din1_async  (shared_interrupt_enable_2_int[75]),
    .din2_async  (shared_interrupt_input[75]),
    .dout_async  (interrupt_controller_output_2[75])
  );

  assign shared_interrupt_enable_3_int[75] = shd_int_cfg_ici3_en_in[75] & SI75_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_75_3 (
    .din1_async  (shared_interrupt_enable_3_int[75]),
    .din2_async  (shared_interrupt_input[75]),
    .dout_async  (interrupt_controller_output_3[75])
  );


  assign shared_interrupt_enable_0_int[76] = shd_int_cfg_ici0_en_in[76] & SI76_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_76_0 (
    .din1_async  (shared_interrupt_enable_0_int[76]),
    .din2_async  (shared_interrupt_input[76]),
    .dout_async  (interrupt_controller_output_0[76])
  );

  assign shared_interrupt_enable_1_int[76] = shd_int_cfg_ici1_en_in[76] & SI76_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_76_1 (
    .din1_async  (shared_interrupt_enable_1_int[76]),
    .din2_async  (shared_interrupt_input[76]),
    .dout_async  (interrupt_controller_output_1[76])
  );

  assign shared_interrupt_enable_2_int[76] = shd_int_cfg_ici2_en_in[76] & SI76_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_76_2 (
    .din1_async  (shared_interrupt_enable_2_int[76]),
    .din2_async  (shared_interrupt_input[76]),
    .dout_async  (interrupt_controller_output_2[76])
  );

  assign shared_interrupt_enable_3_int[76] = shd_int_cfg_ici3_en_in[76] & SI76_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_76_3 (
    .din1_async  (shared_interrupt_enable_3_int[76]),
    .din2_async  (shared_interrupt_input[76]),
    .dout_async  (interrupt_controller_output_3[76])
  );


  assign shared_interrupt_enable_0_int[77] = shd_int_cfg_ici0_en_in[77] & SI77_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_77_0 (
    .din1_async  (shared_interrupt_enable_0_int[77]),
    .din2_async  (shared_interrupt_input[77]),
    .dout_async  (interrupt_controller_output_0[77])
  );

  assign shared_interrupt_enable_1_int[77] = shd_int_cfg_ici1_en_in[77] & SI77_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_77_1 (
    .din1_async  (shared_interrupt_enable_1_int[77]),
    .din2_async  (shared_interrupt_input[77]),
    .dout_async  (interrupt_controller_output_1[77])
  );

  assign shared_interrupt_enable_2_int[77] = shd_int_cfg_ici2_en_in[77] & SI77_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_77_2 (
    .din1_async  (shared_interrupt_enable_2_int[77]),
    .din2_async  (shared_interrupt_input[77]),
    .dout_async  (interrupt_controller_output_2[77])
  );

  assign shared_interrupt_enable_3_int[77] = shd_int_cfg_ici3_en_in[77] & SI77_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_77_3 (
    .din1_async  (shared_interrupt_enable_3_int[77]),
    .din2_async  (shared_interrupt_input[77]),
    .dout_async  (interrupt_controller_output_3[77])
  );


  assign shared_interrupt_enable_0_int[78] = shd_int_cfg_ici0_en_in[78] & SI78_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_78_0 (
    .din1_async  (shared_interrupt_enable_0_int[78]),
    .din2_async  (shared_interrupt_input[78]),
    .dout_async  (interrupt_controller_output_0[78])
  );

  assign shared_interrupt_enable_1_int[78] = shd_int_cfg_ici1_en_in[78] & SI78_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_78_1 (
    .din1_async  (shared_interrupt_enable_1_int[78]),
    .din2_async  (shared_interrupt_input[78]),
    .dout_async  (interrupt_controller_output_1[78])
  );

  assign shared_interrupt_enable_2_int[78] = shd_int_cfg_ici2_en_in[78] & SI78_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_78_2 (
    .din1_async  (shared_interrupt_enable_2_int[78]),
    .din2_async  (shared_interrupt_input[78]),
    .dout_async  (interrupt_controller_output_2[78])
  );

  assign shared_interrupt_enable_3_int[78] = shd_int_cfg_ici3_en_in[78] & SI78_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_78_3 (
    .din1_async  (shared_interrupt_enable_3_int[78]),
    .din2_async  (shared_interrupt_input[78]),
    .dout_async  (interrupt_controller_output_3[78])
  );


  assign shared_interrupt_enable_0_int[79] = shd_int_cfg_ici0_en_in[79] & SI79_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_79_0 (
    .din1_async  (shared_interrupt_enable_0_int[79]),
    .din2_async  (shared_interrupt_input[79]),
    .dout_async  (interrupt_controller_output_0[79])
  );

  assign shared_interrupt_enable_1_int[79] = shd_int_cfg_ici1_en_in[79] & SI79_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_79_1 (
    .din1_async  (shared_interrupt_enable_1_int[79]),
    .din2_async  (shared_interrupt_input[79]),
    .dout_async  (interrupt_controller_output_1[79])
  );

  assign shared_interrupt_enable_2_int[79] = shd_int_cfg_ici2_en_in[79] & SI79_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_79_2 (
    .din1_async  (shared_interrupt_enable_2_int[79]),
    .din2_async  (shared_interrupt_input[79]),
    .dout_async  (interrupt_controller_output_2[79])
  );

  assign shared_interrupt_enable_3_int[79] = shd_int_cfg_ici3_en_in[79] & SI79_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_79_3 (
    .din1_async  (shared_interrupt_enable_3_int[79]),
    .din2_async  (shared_interrupt_input[79]),
    .dout_async  (interrupt_controller_output_3[79])
  );


  assign shared_interrupt_enable_0_int[80] = shd_int_cfg_ici0_en_in[80] & SI80_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_80_0 (
    .din1_async  (shared_interrupt_enable_0_int[80]),
    .din2_async  (shared_interrupt_input[80]),
    .dout_async  (interrupt_controller_output_0[80])
  );

  assign shared_interrupt_enable_1_int[80] = shd_int_cfg_ici1_en_in[80] & SI80_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_80_1 (
    .din1_async  (shared_interrupt_enable_1_int[80]),
    .din2_async  (shared_interrupt_input[80]),
    .dout_async  (interrupt_controller_output_1[80])
  );

  assign shared_interrupt_enable_2_int[80] = shd_int_cfg_ici2_en_in[80] & SI80_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_80_2 (
    .din1_async  (shared_interrupt_enable_2_int[80]),
    .din2_async  (shared_interrupt_input[80]),
    .dout_async  (interrupt_controller_output_2[80])
  );

  assign shared_interrupt_enable_3_int[80] = shd_int_cfg_ici3_en_in[80] & SI80_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_80_3 (
    .din1_async  (shared_interrupt_enable_3_int[80]),
    .din2_async  (shared_interrupt_input[80]),
    .dout_async  (interrupt_controller_output_3[80])
  );


  assign shared_interrupt_enable_0_int[81] = shd_int_cfg_ici0_en_in[81] & SI81_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_81_0 (
    .din1_async  (shared_interrupt_enable_0_int[81]),
    .din2_async  (shared_interrupt_input[81]),
    .dout_async  (interrupt_controller_output_0[81])
  );

  assign shared_interrupt_enable_1_int[81] = shd_int_cfg_ici1_en_in[81] & SI81_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_81_1 (
    .din1_async  (shared_interrupt_enable_1_int[81]),
    .din2_async  (shared_interrupt_input[81]),
    .dout_async  (interrupt_controller_output_1[81])
  );

  assign shared_interrupt_enable_2_int[81] = shd_int_cfg_ici2_en_in[81] & SI81_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_81_2 (
    .din1_async  (shared_interrupt_enable_2_int[81]),
    .din2_async  (shared_interrupt_input[81]),
    .dout_async  (interrupt_controller_output_2[81])
  );

  assign shared_interrupt_enable_3_int[81] = shd_int_cfg_ici3_en_in[81] & SI81_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_81_3 (
    .din1_async  (shared_interrupt_enable_3_int[81]),
    .din2_async  (shared_interrupt_input[81]),
    .dout_async  (interrupt_controller_output_3[81])
  );


  assign shared_interrupt_enable_0_int[82] = shd_int_cfg_ici0_en_in[82] & SI82_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_82_0 (
    .din1_async  (shared_interrupt_enable_0_int[82]),
    .din2_async  (shared_interrupt_input[82]),
    .dout_async  (interrupt_controller_output_0[82])
  );

  assign shared_interrupt_enable_1_int[82] = shd_int_cfg_ici1_en_in[82] & SI82_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_82_1 (
    .din1_async  (shared_interrupt_enable_1_int[82]),
    .din2_async  (shared_interrupt_input[82]),
    .dout_async  (interrupt_controller_output_1[82])
  );

  assign shared_interrupt_enable_2_int[82] = shd_int_cfg_ici2_en_in[82] & SI82_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_82_2 (
    .din1_async  (shared_interrupt_enable_2_int[82]),
    .din2_async  (shared_interrupt_input[82]),
    .dout_async  (interrupt_controller_output_2[82])
  );

  assign shared_interrupt_enable_3_int[82] = shd_int_cfg_ici3_en_in[82] & SI82_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_82_3 (
    .din1_async  (shared_interrupt_enable_3_int[82]),
    .din2_async  (shared_interrupt_input[82]),
    .dout_async  (interrupt_controller_output_3[82])
  );


  assign shared_interrupt_enable_0_int[83] = shd_int_cfg_ici0_en_in[83] & SI83_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_83_0 (
    .din1_async  (shared_interrupt_enable_0_int[83]),
    .din2_async  (shared_interrupt_input[83]),
    .dout_async  (interrupt_controller_output_0[83])
  );

  assign shared_interrupt_enable_1_int[83] = shd_int_cfg_ici1_en_in[83] & SI83_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_83_1 (
    .din1_async  (shared_interrupt_enable_1_int[83]),
    .din2_async  (shared_interrupt_input[83]),
    .dout_async  (interrupt_controller_output_1[83])
  );

  assign shared_interrupt_enable_2_int[83] = shd_int_cfg_ici2_en_in[83] & SI83_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_83_2 (
    .din1_async  (shared_interrupt_enable_2_int[83]),
    .din2_async  (shared_interrupt_input[83]),
    .dout_async  (interrupt_controller_output_2[83])
  );

  assign shared_interrupt_enable_3_int[83] = shd_int_cfg_ici3_en_in[83] & SI83_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_83_3 (
    .din1_async  (shared_interrupt_enable_3_int[83]),
    .din2_async  (shared_interrupt_input[83]),
    .dout_async  (interrupt_controller_output_3[83])
  );


  assign shared_interrupt_enable_0_int[84] = shd_int_cfg_ici0_en_in[84] & SI84_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_84_0 (
    .din1_async  (shared_interrupt_enable_0_int[84]),
    .din2_async  (shared_interrupt_input[84]),
    .dout_async  (interrupt_controller_output_0[84])
  );

  assign shared_interrupt_enable_1_int[84] = shd_int_cfg_ici1_en_in[84] & SI84_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_84_1 (
    .din1_async  (shared_interrupt_enable_1_int[84]),
    .din2_async  (shared_interrupt_input[84]),
    .dout_async  (interrupt_controller_output_1[84])
  );

  assign shared_interrupt_enable_2_int[84] = shd_int_cfg_ici2_en_in[84] & SI84_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_84_2 (
    .din1_async  (shared_interrupt_enable_2_int[84]),
    .din2_async  (shared_interrupt_input[84]),
    .dout_async  (interrupt_controller_output_2[84])
  );

  assign shared_interrupt_enable_3_int[84] = shd_int_cfg_ici3_en_in[84] & SI84_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_84_3 (
    .din1_async  (shared_interrupt_enable_3_int[84]),
    .din2_async  (shared_interrupt_input[84]),
    .dout_async  (interrupt_controller_output_3[84])
  );


  assign shared_interrupt_enable_0_int[85] = shd_int_cfg_ici0_en_in[85] & SI85_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_85_0 (
    .din1_async  (shared_interrupt_enable_0_int[85]),
    .din2_async  (shared_interrupt_input[85]),
    .dout_async  (interrupt_controller_output_0[85])
  );

  assign shared_interrupt_enable_1_int[85] = shd_int_cfg_ici1_en_in[85] & SI85_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_85_1 (
    .din1_async  (shared_interrupt_enable_1_int[85]),
    .din2_async  (shared_interrupt_input[85]),
    .dout_async  (interrupt_controller_output_1[85])
  );

  assign shared_interrupt_enable_2_int[85] = shd_int_cfg_ici2_en_in[85] & SI85_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_85_2 (
    .din1_async  (shared_interrupt_enable_2_int[85]),
    .din2_async  (shared_interrupt_input[85]),
    .dout_async  (interrupt_controller_output_2[85])
  );

  assign shared_interrupt_enable_3_int[85] = shd_int_cfg_ici3_en_in[85] & SI85_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_85_3 (
    .din1_async  (shared_interrupt_enable_3_int[85]),
    .din2_async  (shared_interrupt_input[85]),
    .dout_async  (interrupt_controller_output_3[85])
  );


  assign shared_interrupt_enable_0_int[86] = shd_int_cfg_ici0_en_in[86] & SI86_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_86_0 (
    .din1_async  (shared_interrupt_enable_0_int[86]),
    .din2_async  (shared_interrupt_input[86]),
    .dout_async  (interrupt_controller_output_0[86])
  );

  assign shared_interrupt_enable_1_int[86] = shd_int_cfg_ici1_en_in[86] & SI86_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_86_1 (
    .din1_async  (shared_interrupt_enable_1_int[86]),
    .din2_async  (shared_interrupt_input[86]),
    .dout_async  (interrupt_controller_output_1[86])
  );

  assign shared_interrupt_enable_2_int[86] = shd_int_cfg_ici2_en_in[86] & SI86_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_86_2 (
    .din1_async  (shared_interrupt_enable_2_int[86]),
    .din2_async  (shared_interrupt_input[86]),
    .dout_async  (interrupt_controller_output_2[86])
  );

  assign shared_interrupt_enable_3_int[86] = shd_int_cfg_ici3_en_in[86] & SI86_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_86_3 (
    .din1_async  (shared_interrupt_enable_3_int[86]),
    .din2_async  (shared_interrupt_input[86]),
    .dout_async  (interrupt_controller_output_3[86])
  );


  assign shared_interrupt_enable_0_int[87] = shd_int_cfg_ici0_en_in[87] & SI87_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_87_0 (
    .din1_async  (shared_interrupt_enable_0_int[87]),
    .din2_async  (shared_interrupt_input[87]),
    .dout_async  (interrupt_controller_output_0[87])
  );

  assign shared_interrupt_enable_1_int[87] = shd_int_cfg_ici1_en_in[87] & SI87_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_87_1 (
    .din1_async  (shared_interrupt_enable_1_int[87]),
    .din2_async  (shared_interrupt_input[87]),
    .dout_async  (interrupt_controller_output_1[87])
  );

  assign shared_interrupt_enable_2_int[87] = shd_int_cfg_ici2_en_in[87] & SI87_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_87_2 (
    .din1_async  (shared_interrupt_enable_2_int[87]),
    .din2_async  (shared_interrupt_input[87]),
    .dout_async  (interrupt_controller_output_2[87])
  );

  assign shared_interrupt_enable_3_int[87] = shd_int_cfg_ici3_en_in[87] & SI87_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_87_3 (
    .din1_async  (shared_interrupt_enable_3_int[87]),
    .din2_async  (shared_interrupt_input[87]),
    .dout_async  (interrupt_controller_output_3[87])
  );


  assign shared_interrupt_enable_0_int[88] = shd_int_cfg_ici0_en_in[88] & SI88_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_88_0 (
    .din1_async  (shared_interrupt_enable_0_int[88]),
    .din2_async  (shared_interrupt_input[88]),
    .dout_async  (interrupt_controller_output_0[88])
  );

  assign shared_interrupt_enable_1_int[88] = shd_int_cfg_ici1_en_in[88] & SI88_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_88_1 (
    .din1_async  (shared_interrupt_enable_1_int[88]),
    .din2_async  (shared_interrupt_input[88]),
    .dout_async  (interrupt_controller_output_1[88])
  );

  assign shared_interrupt_enable_2_int[88] = shd_int_cfg_ici2_en_in[88] & SI88_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_88_2 (
    .din1_async  (shared_interrupt_enable_2_int[88]),
    .din2_async  (shared_interrupt_input[88]),
    .dout_async  (interrupt_controller_output_2[88])
  );

  assign shared_interrupt_enable_3_int[88] = shd_int_cfg_ici3_en_in[88] & SI88_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_88_3 (
    .din1_async  (shared_interrupt_enable_3_int[88]),
    .din2_async  (shared_interrupt_input[88]),
    .dout_async  (interrupt_controller_output_3[88])
  );


  assign shared_interrupt_enable_0_int[89] = shd_int_cfg_ici0_en_in[89] & SI89_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_89_0 (
    .din1_async  (shared_interrupt_enable_0_int[89]),
    .din2_async  (shared_interrupt_input[89]),
    .dout_async  (interrupt_controller_output_0[89])
  );

  assign shared_interrupt_enable_1_int[89] = shd_int_cfg_ici1_en_in[89] & SI89_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_89_1 (
    .din1_async  (shared_interrupt_enable_1_int[89]),
    .din2_async  (shared_interrupt_input[89]),
    .dout_async  (interrupt_controller_output_1[89])
  );

  assign shared_interrupt_enable_2_int[89] = shd_int_cfg_ici2_en_in[89] & SI89_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_89_2 (
    .din1_async  (shared_interrupt_enable_2_int[89]),
    .din2_async  (shared_interrupt_input[89]),
    .dout_async  (interrupt_controller_output_2[89])
  );

  assign shared_interrupt_enable_3_int[89] = shd_int_cfg_ici3_en_in[89] & SI89_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_89_3 (
    .din1_async  (shared_interrupt_enable_3_int[89]),
    .din2_async  (shared_interrupt_input[89]),
    .dout_async  (interrupt_controller_output_3[89])
  );


  assign shared_interrupt_enable_0_int[90] = shd_int_cfg_ici0_en_in[90] & SI90_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_90_0 (
    .din1_async  (shared_interrupt_enable_0_int[90]),
    .din2_async  (shared_interrupt_input[90]),
    .dout_async  (interrupt_controller_output_0[90])
  );

  assign shared_interrupt_enable_1_int[90] = shd_int_cfg_ici1_en_in[90] & SI90_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_90_1 (
    .din1_async  (shared_interrupt_enable_1_int[90]),
    .din2_async  (shared_interrupt_input[90]),
    .dout_async  (interrupt_controller_output_1[90])
  );

  assign shared_interrupt_enable_2_int[90] = shd_int_cfg_ici2_en_in[90] & SI90_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_90_2 (
    .din1_async  (shared_interrupt_enable_2_int[90]),
    .din2_async  (shared_interrupt_input[90]),
    .dout_async  (interrupt_controller_output_2[90])
  );

  assign shared_interrupt_enable_3_int[90] = shd_int_cfg_ici3_en_in[90] & SI90_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_90_3 (
    .din1_async  (shared_interrupt_enable_3_int[90]),
    .din2_async  (shared_interrupt_input[90]),
    .dout_async  (interrupt_controller_output_3[90])
  );


  assign shared_interrupt_enable_0_int[91] = shd_int_cfg_ici0_en_in[91] & SI91_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_91_0 (
    .din1_async  (shared_interrupt_enable_0_int[91]),
    .din2_async  (shared_interrupt_input[91]),
    .dout_async  (interrupt_controller_output_0[91])
  );

  assign shared_interrupt_enable_1_int[91] = shd_int_cfg_ici1_en_in[91] & SI91_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_91_1 (
    .din1_async  (shared_interrupt_enable_1_int[91]),
    .din2_async  (shared_interrupt_input[91]),
    .dout_async  (interrupt_controller_output_1[91])
  );

  assign shared_interrupt_enable_2_int[91] = shd_int_cfg_ici2_en_in[91] & SI91_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_91_2 (
    .din1_async  (shared_interrupt_enable_2_int[91]),
    .din2_async  (shared_interrupt_input[91]),
    .dout_async  (interrupt_controller_output_2[91])
  );

  assign shared_interrupt_enable_3_int[91] = shd_int_cfg_ici3_en_in[91] & SI91_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_91_3 (
    .din1_async  (shared_interrupt_enable_3_int[91]),
    .din2_async  (shared_interrupt_input[91]),
    .dout_async  (interrupt_controller_output_3[91])
  );


  assign shared_interrupt_enable_0_int[92] = shd_int_cfg_ici0_en_in[92] & SI92_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_92_0 (
    .din1_async  (shared_interrupt_enable_0_int[92]),
    .din2_async  (shared_interrupt_input[92]),
    .dout_async  (interrupt_controller_output_0[92])
  );

  assign shared_interrupt_enable_1_int[92] = shd_int_cfg_ici1_en_in[92] & SI92_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_92_1 (
    .din1_async  (shared_interrupt_enable_1_int[92]),
    .din2_async  (shared_interrupt_input[92]),
    .dout_async  (interrupt_controller_output_1[92])
  );

  assign shared_interrupt_enable_2_int[92] = shd_int_cfg_ici2_en_in[92] & SI92_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_92_2 (
    .din1_async  (shared_interrupt_enable_2_int[92]),
    .din2_async  (shared_interrupt_input[92]),
    .dout_async  (interrupt_controller_output_2[92])
  );

  assign shared_interrupt_enable_3_int[92] = shd_int_cfg_ici3_en_in[92] & SI92_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_92_3 (
    .din1_async  (shared_interrupt_enable_3_int[92]),
    .din2_async  (shared_interrupt_input[92]),
    .dout_async  (interrupt_controller_output_3[92])
  );


  assign shared_interrupt_enable_0_int[93] = shd_int_cfg_ici0_en_in[93] & SI93_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_93_0 (
    .din1_async  (shared_interrupt_enable_0_int[93]),
    .din2_async  (shared_interrupt_input[93]),
    .dout_async  (interrupt_controller_output_0[93])
  );

  assign shared_interrupt_enable_1_int[93] = shd_int_cfg_ici1_en_in[93] & SI93_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_93_1 (
    .din1_async  (shared_interrupt_enable_1_int[93]),
    .din2_async  (shared_interrupt_input[93]),
    .dout_async  (interrupt_controller_output_1[93])
  );

  assign shared_interrupt_enable_2_int[93] = shd_int_cfg_ici2_en_in[93] & SI93_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_93_2 (
    .din1_async  (shared_interrupt_enable_2_int[93]),
    .din2_async  (shared_interrupt_input[93]),
    .dout_async  (interrupt_controller_output_2[93])
  );

  assign shared_interrupt_enable_3_int[93] = shd_int_cfg_ici3_en_in[93] & SI93_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_93_3 (
    .din1_async  (shared_interrupt_enable_3_int[93]),
    .din2_async  (shared_interrupt_input[93]),
    .dout_async  (interrupt_controller_output_3[93])
  );


  assign shared_interrupt_enable_0_int[94] = shd_int_cfg_ici0_en_in[94] & SI94_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_94_0 (
    .din1_async  (shared_interrupt_enable_0_int[94]),
    .din2_async  (shared_interrupt_input[94]),
    .dout_async  (interrupt_controller_output_0[94])
  );

  assign shared_interrupt_enable_1_int[94] = shd_int_cfg_ici1_en_in[94] & SI94_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_94_1 (
    .din1_async  (shared_interrupt_enable_1_int[94]),
    .din2_async  (shared_interrupt_input[94]),
    .dout_async  (interrupt_controller_output_1[94])
  );

  assign shared_interrupt_enable_2_int[94] = shd_int_cfg_ici2_en_in[94] & SI94_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_94_2 (
    .din1_async  (shared_interrupt_enable_2_int[94]),
    .din2_async  (shared_interrupt_input[94]),
    .dout_async  (interrupt_controller_output_2[94])
  );

  assign shared_interrupt_enable_3_int[94] = shd_int_cfg_ici3_en_in[94] & SI94_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_94_3 (
    .din1_async  (shared_interrupt_enable_3_int[94]),
    .din2_async  (shared_interrupt_input[94]),
    .dout_async  (interrupt_controller_output_3[94])
  );


  assign shared_interrupt_enable_0_int[95] = shd_int_cfg_ici0_en_in[95] & SI95_ICI_DST[0];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_95_0 (
    .din1_async  (shared_interrupt_enable_0_int[95]),
    .din2_async  (shared_interrupt_input[95]),
    .dout_async  (interrupt_controller_output_0[95])
  );

  assign shared_interrupt_enable_1_int[95] = shd_int_cfg_ici1_en_in[95] & SI95_ICI_DST[1];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_95_1 (
    .din1_async  (shared_interrupt_enable_1_int[95]),
    .din2_async  (shared_interrupt_input[95]),
    .dout_async  (interrupt_controller_output_1[95])
  );

  assign shared_interrupt_enable_2_int[95] = shd_int_cfg_ici2_en_in[95] & SI95_ICI_DST[2];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_95_2 (
    .din1_async  (shared_interrupt_enable_2_int[95]),
    .din2_async  (shared_interrupt_input[95]),
    .dout_async  (interrupt_controller_output_2[95])
  );

  assign shared_interrupt_enable_3_int[95] = shd_int_cfg_ici3_en_in[95] & SI95_ICI_DST[3];

  arm_element_cdc_comb_and2 u_shared_interrupt_comb_and2_95_3 (
    .din1_async  (shared_interrupt_enable_3_int[95]),
    .din2_async  (shared_interrupt_input[95]),
    .dout_async  (interrupt_controller_output_3[95])
  );


endmodule

`ifdef INT_RTR_PARAMS
`include "interrupt_router_f0_undefs.v"
`endif


