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
//      Checked In          : Fri May 4 16:37:14 2018 +0100
//
//      Revision            : 0bc240c
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_comap  # (
  parameter FF_SYNC_DEPTH =  2
)(

input   wire          dapclk,
input   wire          dapreset_n,
input   wire          cfg_rrdis,
input   wire          cfg_pen,

input   wire  [ 7:0]  dapcaddr_s,
input   wire          dapwrite_s,
input   wire          dapsel_s,
input   wire          dapenable_s,
input   wire  [31:0]  dapwdata_s,

output  wire  [31:0]  daprdata_s,
output  wire          dapready_s,
output  wire          dapslverr_s,

input   wire          dapabort_s,

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

input   wire          rempua,
input   wire          remra,
output  wire          rempur,
output  wire          remrr,

input   wire          clk_qreq_n,
output  wire          clk_qaccept_n,
output  wire          clk_qdeny,
output  wire          clk_qactive

);

`include "sdc600_apbcom_variants.v"

wire  tie_low = 1'b0;

sdc600_apbcom  # (
  .FF_SYNC_DEPTH (FF_SYNC_DEPTH),
  .APBCOM_VAR    (COMAP)
)  u_apbcom  (

  .pclk          (dapclk),
  .preset_n      (dapreset_n),
  .cfg_rrdis     (cfg_rrdis),
  .cfg_pen       (cfg_pen),

  .paddr_s       ({{4{tie_low}},dapcaddr_s}),
  .pwrite_s      (dapwrite_s),
  .psel_s        (dapsel_s),
  .pwakeup_s     (tie_low),
  .penable_s     (dapenable_s),
  .pwdata_s      (dapwdata_s),
  .prdata_s      (daprdata_s),
  .pready_s      (dapready_s),
  .pslverr_s     (dapslverr_s),

  .dp_abort      (dapabort_s),

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

  .rempur        (rempur),
  .rempua        (rempua),
  .remrr         (remrr),
  .remra         (remra),

  .spniden       (tie_low),
  .spiden        (tie_low),
  .niden         (tie_low),
  .dbgen         (tie_low),

  .pwr_qreq_n    (tie_low),
  .pwr_qaccept_n (),
  .pwr_qdeny     (),
  .pwr_qactive   (),

  .clk_qreq_n    (clk_qreq_n),
  .clk_qaccept_n (clk_qaccept_n),
  .clk_qdeny     (clk_qdeny),
  .clk_qactive   (clk_qactive),

  .irq           ()
);


endmodule
