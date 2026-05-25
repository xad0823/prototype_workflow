//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Apr 26 08:35:45 2018 +0100
//
//      Revision            : 4ee188d
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_apbcom_int  # (
  parameter FF_SYNC_DEPTH =  2
)(

input   wire          pclk,
input   wire          preset_n,

input   wire  [11:0]  paddr_s,
input   wire          pwrite_s,
input   wire          psel_s,
input   wire          pwakeup_s,
input   wire          penable_s,
input   wire  [31:0]  pwdata_s,
output  wire  [31:0]  prdata_s,
output  wire          pready_s,

input   wire  [ 7:0]  rx_data,
input   wire          rx_valid,
input   wire          rx_linkest,
output  wire          rx_ready,
output  wire          rx_linkup,

input   wire          tx_ready,
input   wire          tx_linkup,
output  wire  [ 7:0]  tx_data,
output  wire          tx_valid,
output  wire          tx_linkest,

output  wire          irq,

input   wire          pwr_qreq_n,
output  wire          pwr_qaccept_n,
output  wire          pwr_qdeny,
output  wire          pwr_qactive,

input   wire          clk_qreq_n,
output  wire          clk_qaccept_n,
output  wire          clk_qdeny,
output  wire          clk_qactive

);

`include "sdc600_apbcom_variants.v"

wire  tie_low  = 1'b0;
wire  tie_high = 1'b1;

wire  rempu_fb;


sdc600_apbcom  # (
  .FF_SYNC_DEPTH (FF_SYNC_DEPTH),
  .APBCOM_VAR    (APBCOM_INT)
)  u_apbcom  (

  .pclk          (pclk),
  .preset_n      (preset_n),
  .cfg_rrdis     (tie_high),
  .cfg_pen       (tie_high),

  .paddr_s       (paddr_s),
  .pwrite_s      (pwrite_s),
  .psel_s        (psel_s),
  .pwakeup_s     (pwakeup_s),
  .penable_s     (penable_s),
  .pwdata_s      (pwdata_s),
  .prdata_s      (prdata_s),
  .pready_s      (pready_s),
  .pslverr_s     (),

  .dp_abort      (tie_low),

  .rx_data       (rx_data),
  .rx_valid      (rx_valid),
  .rx_ready      (rx_ready),
  .rx_linkup     (rx_linkup),
  .rx_linkest    (rx_linkest),

  .tx_data       (tx_data),
  .tx_valid      (tx_valid),
  .tx_ready      (tx_ready),
  .tx_linkup     (tx_linkup),
  .tx_linkest    (tx_linkest),

  .rempur        (rempu_fb),
  .rempua        (rempu_fb),
  .remrr         (),
  .remra         (tie_low),

  .spniden       (tie_low),
  .spiden        (tie_low),
  .niden         (tie_low),
  .dbgen         (tie_low),

  .pwr_qreq_n    (pwr_qreq_n),
  .pwr_qaccept_n (pwr_qaccept_n),
  .pwr_qdeny     (pwr_qdeny),
  .pwr_qactive   (pwr_qactive),

  .clk_qreq_n    (clk_qreq_n),
  .clk_qaccept_n (clk_qaccept_n),
  .clk_qdeny     (clk_qdeny),
  .clk_qactive   (clk_qactive),

  .irq           (irq)

);

endmodule
