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

module acg_ace #
(
  parameter INACT_CD_CONFIG = 3'b000,
  parameter AW_CNTR_SIZE = 8,
  parameter W_CNTR_SIZE = AW_CNTR_SIZE+1,
  parameter AR_CNTR_SIZE = 8,
  parameter SN_CNTR_SIZE = 8
)(
  input   wire                          ACLK,
  input   wire                          ARESETn,

  input   wire                          ARVALIDS,
  input   wire                          AWVALIDS,
  input   wire                          WVALIDS,
  input   wire                          WLASTS,

  input   wire  [2:0]                   AWSNOOPS, 
  input   wire                          AWBARS0, 

  input   wire                          ACREADYS,
  input   wire                          CRVALIDS,
  input   wire                          CRREADYS,
  input   wire                          CRRESPS0, 
  input   wire                          CDVALIDS,
  input   wire                          CDREADYS,
  input   wire                          CDLASTS,
  

  input   wire                          ACVALIDM,

  input   wire                          ARREADYM,
  input   wire                          AWREADYM,
  input   wire                          WREADYM,

  input   wire                          AWAKEUPS,
  input   wire                          RACKS,
  input   wire                          WACKS,
  
  output   wire                         ARVALIDM,
  output   wire                         AWVALIDM,
  output   wire                         WVALIDM,


  output  wire                          ACREADYM,

  output  wire                          ACVALIDS,

  output  wire                          ARREADYS,
  output  wire                          AWREADYS,
  output  wire                          WREADYS,

  
  output  wire                          INACT,


  input   wire                          PWRQREQn,
  output  wire                          PWRQACCEPTn,
  output  wire                          PWRQDENY,
  output  wire                          PWRQACTIVE,

  input   wire                          CLKQREQn,
  output  wire                          CLKQACCEPTn,
  output  wire                          CLKQDENY,
  output  wire                          CLKQACTIVE

);


acg_ace_core #(
  .INACT_CD_CONFIG      (INACT_CD_CONFIG),
  .AW_CNTR_SIZE         (AW_CNTR_SIZE),
  .W_CNTR_SIZE          (W_CNTR_SIZE),
  .AR_CNTR_SIZE         (AR_CNTR_SIZE),
  .SN_CNTR_SIZE         (SN_CNTR_SIZE)
) u_acg_ace_core(
    .aclk               (ACLK),
    .aresetn            (ARESETn),
    .arvalids           (ARVALIDS),
    .awvalids           (AWVALIDS),
    .wvalids            (WVALIDS),
    .wlasts             (WLASTS),
    .awsnoops           (AWSNOOPS), 
    .awbars_0           (AWBARS0), 
    .acreadys           (ACREADYS),
    .crvalids           (CRVALIDS),
    .crreadys           (CRREADYS),
    .crresps_0          (CRRESPS0), 
    .cdvalids           (CDVALIDS),
    .cdreadys           (CDREADYS),
    .cdlasts            (CDLASTS),
    .acvalidm           (ACVALIDM),
    .arreadym           (ARREADYM),
    .awreadym           (AWREADYM),
    .wreadym            (WREADYM),
    .awakeups           (AWAKEUPS),
    .racks              (RACKS),
    .wacks              (WACKS),
    .arvalidm           (ARVALIDM),
    .awvalidm           (AWVALIDM),
    .wvalidm            (WVALIDM),
    .acreadym           (ACREADYM),
    .acvalids           (ACVALIDS),
    .arreadys           (ARREADYS),
    .awreadys           (AWREADYS),
    .wreadys            (WREADYS),
    .inact              (INACT),
    .pwr_qreqn          (PWRQREQn),
    .pwr_qacceptn       (PWRQACCEPTn),
    .pwr_qdeny          (PWRQDENY),
    .pwr_qactive        (PWRQACTIVE),
    .clk_qreqn          (CLKQREQn),
    .clk_qacceptn       (CLKQACCEPTn),
    .clk_qdeny          (CLKQDENY),
    .clk_qactive        (CLKQACTIVE)
  );  
  


endmodule
