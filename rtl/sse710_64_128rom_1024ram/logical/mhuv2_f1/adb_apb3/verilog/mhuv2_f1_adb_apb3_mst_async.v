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

module mhuv2_f1_adb_apb3_mst_async
(
  input wire                  apb_async_req_i,
  input wire                  recwakeup_async_i,
  input wire                  pwrqreqn_i,

  input wire                  apb_async_ack_i,
  input wire                  recwakeup_async_sss_i,
  input wire                  pwrqacceptn_i,

  input wire                  pwakeup_i,

  output wire                 pclkmqactive_o
);

  wire adb_transfer;
  wire pwr_transfer;
  wire recwakeup_sync;
  wire adb_or_pwr_transfer;
  wire recwakeup_or_abd_or_pwr;


  mhuv2_f1_adb_or2
  u_mhuv2_f1_adb_or2_adb
  (
    .A  (apb_async_req_i),
    .B  (apb_async_ack_i),
    .Y  (adb_transfer)
  );

  mhuv2_f1_adb_xor2
  u_mhuv2_f1_adb_xor2_pwr
  (
    .A  (pwrqreqn_i),
    .B  (pwrqacceptn_i),
    .Y  (pwr_transfer)
  );

  mhuv2_f1_adb_xor2
  u_mhuv2_f1_adb_xor2_recwakeup
  (
    .A  (recwakeup_async_i),
    .B  (recwakeup_async_sss_i),
    .Y  (recwakeup_sync)
  );

  mhuv2_f1_adb_or2
  u_mhuv2_f1_adb_or2_adb_or_pwr
  (
    .A  (adb_transfer),
    .B  (pwr_transfer),
    .Y  (adb_or_pwr_transfer)
  );

  mhuv2_f1_adb_or2
  u_mhuv2_f1_adb_or2_recwakeup_or_abd_or_pwr
  (
    .A  (adb_or_pwr_transfer),
    .B  (recwakeup_sync),
    .Y  (recwakeup_or_abd_or_pwr)
  );

  mhuv2_f1_adb_or2
  u_mhuv2_f1_adb_or2_qactive
  (
    .A  (recwakeup_or_abd_or_pwr),
    .B  (pwakeup_i),
    .Y  (pclkmqactive_o)
  );


endmodule
