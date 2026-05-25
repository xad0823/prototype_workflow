//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53cti
#(
  parameter ECT_TR_WIDTH = 8,
  parameter ECT_CH_WIDTH = 4,
  parameter ECT_GATE_CHIN = 0,
  parameter ECT_CLAIM_CNT = 4,
  parameter TIHSBYPASS   = 8'b11110010,

  parameter INTRIG_USED  = 8'b11110011,
  parameter OUTTRIG_USED = 8'b11110111
)
 (
  input                         clk,
  input                         reset_n,

  input                         DFTSE,

  input                         pseldbg_i,
  input                         penabledbg_i,
  input                         pwritedbg_i,
  input                         paddrdbg31_i,
  input                  [11:2] paddrdbg_i,
  input                  [31:0] pwdatadbg_i,

  input      [ECT_CH_WIDTH-1:0] ctichin_i,
  input      [ECT_TR_WIDTH-1:0] ctitrigin_i,
  input      [ECT_TR_WIDTH-1:0] ctitrigoutack_i,

  output                        preadydbg_o,
  output                 [31:0] prdatadbg_o,

  output     [ECT_TR_WIDTH-1:0] ctitrigout_o,
  output     [ECT_CH_WIDTH-1:0] ctichout_o,
  output                        cti_active_o
);


  wire [ECT_CH_WIDTH-1:0] apptrigpulse;         // From u_cti_apbif of ca53cti_apbif.v
  wire [ECT_CH_WIDTH-1:0] ctichin_gated;        // From u_cti_ci of ca53cti_ci.v
  wire [ECT_CH_WIDTH-1:0] ctichinstatus;        // From u_cti_ci of ca53cti_ci.v
  wire [ECT_CH_WIDTH-1:0] ctichoutstatus;       // From u_cti_ci of ca53cti_ci.v
  wire [ECT_CH_WIDTH-1:0] ctigate;              // From u_cti_apbif of ca53cti_apbif.v
  wire                    bus_read;             // From u_cti_apbif of ca53cti_apbif.v
  wire                    bus_write_unlocked;   // From u_cti_apbif of ca53cti_apbif.v
  wire [ECT_TR_WIDTH-1:0] ctitrigin_rs;         // From u_cti_ti of ca53cti_ti.v
  wire [ECT_TR_WIDTH-1:0] ctitriginstatus;      // From u_cti_ti of ca53cti_ti.v
  wire [ECT_TR_WIDTH-1:0] ctitrigoutstatus;     // From u_cti_ti of ca53cti_ti.v
  wire                    ctitrigout_act;       // From u_cti_ti of ca53cti_ti.v
  wire                    glben;                // From u_cti_apbif of ca53cti_apbif.v
  wire                    bus_act_early;        // From u_cti_apbif of ca53cti_apbif.v
  wire [ECT_TR_WIDTH-1:0] intack;               // From u_cti_apbif of ca53cti_apbif.v
  wire [ECT_CH_WIDTH-1:0] map_out_ch;           // From u_cti_mapper of ca53cti_mapper.v
  wire [ECT_TR_WIDTH-1:0] map_out_trig;         // From u_cti_mapper of ca53cti_mapper.v
  wire [31:0]             map_rdata;            // From u_cti_mapper of ca53cti_mapper.v
  wire                    map_rdata_valid;      // From u_cti_mapper of ca53cti_mapper.v

  wire                    clk_cti;


  ca53cti_clkgate u_cti_clkgate
    (
     // Outputs
     .cti_active_o                      (cti_active_o),
     .clk_cti_o                         (clk_cti),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .DFTSE                             (DFTSE),
     .glben_i                           (glben),
     .bus_act_early_i                   (bus_act_early),
     .ctitrigout_act_i                  (ctitrigout_act));


  ca53cti_apbif #(
     .ECT_TR_WIDTH (ECT_TR_WIDTH ),
     .ECT_CH_WIDTH (ECT_CH_WIDTH ),
     .ECT_GATE_CHIN(ECT_GATE_CHIN),
     .ECT_CLAIM_CNT(ECT_CLAIM_CNT)
  ) u_cti_apbif
    (
     // Outputs
     .preadydbg_o                       (preadydbg_o),
     .prdatadbg_o                       (prdatadbg_o[31:0]),
     .glben_o                           (glben),
     .apptrigpulse_o                    (apptrigpulse[ECT_CH_WIDTH-1:0]),
     .ctigate_o                         (ctigate[ECT_CH_WIDTH-1:0]),
     .intack_o                          (intack[ECT_TR_WIDTH-1:0]),
     .bus_read_o                        (bus_read),
     .bus_write_unlocked_o              (bus_write_unlocked),
     .bus_act_early_o                   (bus_act_early),
     // Inputs
     .clk                               (clk),
     .clk_cti                           (clk_cti),
     .reset_n                           (reset_n),
     .pseldbg_i                         (pseldbg_i),
     .penabledbg_i                      (penabledbg_i),
     .pwritedbg_i                       (pwritedbg_i),
     .paddrdbg31_i                      (paddrdbg31_i),
     .paddrdbg_i                        (paddrdbg_i[11:2]),
     .pwdatadbg_i                       (pwdatadbg_i[31:0]),
     .ctitriginstatus_i                 (ctitriginstatus[ECT_TR_WIDTH-1:0]),
     .ctitrigoutstatus_i                (ctitrigoutstatus[ECT_TR_WIDTH-1:0]),
     .ctichinstatus_i                   (ctichinstatus[ECT_CH_WIDTH-1:0]),
     .ctichoutstatus_i                  (ctichoutstatus[ECT_CH_WIDTH-1:0]),
     .map_rdata_valid_i                 (map_rdata_valid),
     .map_rdata_i                       (map_rdata[31:0]));


  ca53cti_mapper #(
     .ECT_TR_WIDTH (ECT_TR_WIDTH ),
     .ECT_CH_WIDTH (ECT_CH_WIDTH ),
     .ECT_GATE_CHIN(ECT_GATE_CHIN)
  ) u_cti_mapper
    (
     // Outputs
     .map_rdata_valid_o                 (map_rdata_valid),
     .map_rdata_o                       (map_rdata[31:0]),
     .map_out_trig_o                    (map_out_trig[ECT_TR_WIDTH-1:0]),
     .map_out_ch_o                      (map_out_ch[ECT_CH_WIDTH-1:0]),
     // Inputs
     .clk_cti                           (clk_cti),
     .reset_n                           (reset_n),
     .paddrdbg_i                        (paddrdbg_i[11:2]),
     .pwdatadbg_i                       (pwdatadbg_i[ECT_CH_WIDTH-1:0]),
     .bus_read_i                        (bus_read),
     .bus_write_unlocked_i              (bus_write_unlocked),
     .glben_i                           (glben),
     .apptrigpulse_i                    (apptrigpulse[ECT_CH_WIDTH-1:0]),
     .ctitrigin_rs_i                    (ctitrigin_rs[ECT_TR_WIDTH-1:0]),
     .ctichin_gated_i                   (ctichin_gated[ECT_CH_WIDTH-1:0]));



  ca53cti_ti #(
     .ECT_TR_WIDTH (ECT_TR_WIDTH ),
     .ECT_CH_WIDTH (ECT_CH_WIDTH ),
     .ECT_GATE_CHIN(ECT_GATE_CHIN),
     .TIHSBYPASS   (TIHSBYPASS   ),
     .INTRIG_USED  (INTRIG_USED  ),
     .OUTTRIG_USED (OUTTRIG_USED )
  ) u_cti_ti
    (
     // Outputs
     .ctitrigin_rs_o                    (ctitrigin_rs[ECT_TR_WIDTH-1:0]),
     .ctitriginstatus_o                 (ctitriginstatus[ECT_TR_WIDTH-1:0]),
     .ctitrigoutstatus_o                (ctitrigoutstatus[ECT_TR_WIDTH-1:0]),
     .ctitrigout_o                      (ctitrigout_o[ECT_TR_WIDTH-1:0]),
     .ctitrigout_act_o                  (ctitrigout_act),
     // Inputs
     .clk_cti                           (clk_cti),
     .reset_n                           (reset_n),
     .ctitrigin_i                       (ctitrigin_i[ECT_TR_WIDTH-1:0]),
     .ctitrigoutack_i                   (ctitrigoutack_i[ECT_TR_WIDTH-1:0]),
     .intack_i                          (intack[ECT_TR_WIDTH-1:0]),
     .map_out_trig_i                    (map_out_trig[ECT_TR_WIDTH-1:0]));


  ca53cti_ci #(
     .ECT_TR_WIDTH (ECT_TR_WIDTH ),
     .ECT_CH_WIDTH (ECT_CH_WIDTH ),
     .ECT_GATE_CHIN(ECT_GATE_CHIN)
  ) u_cti_ci
    (
     // Outputs
     .ctichinstatus_o                   (ctichinstatus[ECT_CH_WIDTH-1:0]),
     .ctichoutstatus_o                  (ctichoutstatus[ECT_CH_WIDTH-1:0]),
     .ctichin_gated_o                   (ctichin_gated[ECT_CH_WIDTH-1:0]),
     .ctichout_o                        (ctichout_o[ECT_CH_WIDTH-1:0]),
     // Inputs
     .clk_cti                           (clk_cti),
     .reset_n                           (reset_n),
     .ctichin_i                         (ctichin_i[ECT_CH_WIDTH-1:0]),
     .ctigate_i                         (ctigate[ECT_CH_WIDTH-1:0]),
     .glben_i                           (glben),
     .map_out_ch_i                      (map_out_ch[ECT_CH_WIDTH-1:0]));


endmodule // ca53cti

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
