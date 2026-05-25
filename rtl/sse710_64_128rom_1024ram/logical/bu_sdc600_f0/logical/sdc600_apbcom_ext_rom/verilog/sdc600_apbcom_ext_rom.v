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
//      Checked In          : Thu May 10 12:37:48 2018 +0200
//
//      Revision            : a2dc0a9
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_apbcom_ext_rom  # (
  parameter         FF_SYNC_DEPTH   = 2,
  parameter [ 3:0]  REVISION        = 4'h0,
  parameter [11:0]  PART_NUMBER     = 12'h0,
  parameter [10:0]  JEP106_ID       = 11'h0,
  parameter [ 3:0]  ECO_REV_AND     = 4'h0,
  parameter [31:0]  ROM_ENTRY0      = 32'hE00F_F000
)(

input   wire          pclk,
input   wire          preset_n,
input   wire          cfg_rrdis,
input   wire          cfg_pen,

input   wire  [11:0]  paddr_s,
input   wire          pwrite_s,
input   wire          psel_s,
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

input   wire          rempua,
input   wire          remra,
output  wire          rempur,
output  wire          remrr,

input   wire          spniden,
input   wire          spiden,
input   wire          niden,
input   wire          dbgen,

input   wire          clk_qreq_n,
output  wire          clk_qaccept_n,
output  wire          clk_qdeny,
output  wire          clk_qactive

);


`include "sdc600_apbcom_variants.v"

wire  tie_low = 1'b0;

sdc600_apbcom  # (
  .FF_SYNC_DEPTH    (FF_SYNC_DEPTH),
  .APBCOM_VAR       (APBCOM_EXT_ROM),
  .REVISION         (REVISION),
  .PART_NUMBER      (PART_NUMBER),
  .JEP106_ID        (JEP106_ID),
  .ECO_REV_AND      (ECO_REV_AND),
  .ROM_ENTRY0       (ROM_ENTRY0)
)  u_apbcom  (

  .pclk          (pclk),
  .preset_n      (preset_n),
  .cfg_rrdis     (cfg_rrdis),
  .cfg_pen       (cfg_pen),

  .paddr_s       (paddr_s),
  .pwrite_s      (pwrite_s),
  .psel_s        (psel_s),
  .pwakeup_s     (tie_low),
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

  .rempur        (rempur),
  .rempua        (rempua),
  .remrr         (remrr),
  .remra         (remra),

  .spniden       (spniden),
  .spiden        (spiden),
  .niden         (niden),
  .dbgen         (dbgen),

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
