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

module sdc600_apbcom  # (
  parameter         FF_SYNC_DEPTH   = 2,
  parameter         APBCOM_VAR      = 0,
  parameter [ 3:0]  REVISION        = 4'h0,
  parameter [11:0]  PART_NUMBER     = 12'h0,
  parameter [10:0]  JEP106_ID       = 11'h0,
  parameter [ 3:0]  ECO_REV_AND     = 4'h0,
  parameter [31:0]  ROM_ENTRY0      = 32'hE00F_F000
)(

input wire            pclk,
input wire            preset_n,
input wire            cfg_rrdis,
input wire            cfg_pen,

input   wire  [11:0]  paddr_s,
input   wire          pwrite_s,
input   wire          psel_s,
input   wire          pwakeup_s,
input   wire          penable_s,
input   wire  [31:0]  pwdata_s,
output  wire  [31:0]  prdata_s,
output  wire          pready_s,
output  wire          pslverr_s,

input   wire          dp_abort,

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

input   wire          pwr_qreq_n,
output  wire          pwr_qaccept_n,
output  wire          pwr_qdeny,
output  wire          pwr_qactive,

input   wire          clk_qreq_n,
output  wire          clk_qaccept_n,
output  wire          clk_qdeny,
output  wire          clk_qactive,

output  wire          irq

);

`include "sdc600_apbcom_variants.v"

wire  [11:0]  paddr_r;
wire          trinprog;
wire          wen;
wire          ren;
wire          clk_qreq_sync_n;
wire          pwr_qreq_sync_n;
wire          rempua_sync;
wire          cfg_rrdis_sync;
wire          remra_sync;
wire          wr_str_dr;
wire          wr_str_dbr;
wire          delay_pready;
wire          set_txoe;
wire          txfifo_empty;
wire          set_txlerr;
wire          wr_str_lph1rl;
wire          wr_str_lph1ra;
wire          rx_linkest_reg;
wire  [ 7:0]  rdata_dr;
wire          rxfifo_full;
wire          pwr_dev_run;
wire          clk_dev_run;
wire          dbr_addr_str;
wire          dr_addr_str;
wire          dev_run;
wire          rd_str_dr;
wire          txle;
wire          txoe;


assign dev_run      = pwr_dev_run & clk_dev_run;
assign rd_str_dr    = (dr_addr_str | dbr_addr_str) & ren;

sdc600_apbcom_reg #(
  .APBCOM_VAR       (APBCOM_VAR),
  .REVISION         (REVISION),
  .PART_NUMBER      (PART_NUMBER),
  .JEP106_ID        (JEP106_ID),
  .ECO_REV_AND      (ECO_REV_AND),
  .ROM_ENTRY0       (ROM_ENTRY0)
) u_apbcom_reg (

  .clk                (pclk),
  .resetn             (preset_n),
  .addr               (paddr_r),
  .wdata              (pwdata_s),
  .rdata              (prdata_s),
  .spniden            (spniden),
  .spiden             (spiden),
  .niden              (niden),
  .dbgen              (dbgen),
  .dp_abort           (dp_abort),
  .rrdis              (cfg_rrdis_sync),
  .pen                (cfg_pen),
  .tx_ready           (tx_ready),
  .tx_linkup          (tx_linkup),

  .irq                (irq),

  .wen                (wen),
  .ren                (ren),
  .sr_trinprog        (trinprog),
  .dbr_addr_str       (dbr_addr_str),
  .dr_addr_str        (dr_addr_str),
  .txle               (txle),
  .txoe               (txoe),

  .rxfifo_full        (rxfifo_full),
  .rdata_dr           (rdata_dr),

  .txfifo_empty       (txfifo_empty),
  .set_txoe           (set_txoe),
  .set_txlerr         (set_txlerr),
  .wr_str_dr          (wr_str_dr),
  .wr_str_dbr         (wr_str_dbr),
  .delay_pready       (delay_pready),

  .pwr_dev_run        (pwr_dev_run)

);


sdc600_apbcom_apbif #(
  .APBCOM_VAR         (APBCOM_VAR)
) u_apbif (

  .pclk               (pclk),
  .presetn            (preset_n),
  .paddr              (paddr_s),
  .pwrite             (pwrite_s),
  .psel               (psel_s),
  .penable            (penable_s),
  .pready             (pready_s),
  .pslverr            (pslverr_s),

  .sr_trinprog        (trinprog),
  .dbr_addr_str       (dbr_addr_str),
  .dr_addr_str        (dr_addr_str),
  .wen                (wen),
  .ren                (ren),
  .txle               (txle),
  .txoe               (txoe),
  .paddr_r            (paddr_r),
  .delay_pready       (delay_pready),

  .dev_run            (dev_run)

);


sdc600_apbcom_lpi #(
  .APBCOM_VAR       (APBCOM_VAR)
) u_lpi (

  .pclk             (pclk),
  .presetn          (preset_n),

  .clk_qreq_sync_n  (clk_qreq_sync_n),
  .clk_qdeny        (clk_qdeny),
  .clk_qaccept_n    (clk_qaccept_n),
  .clk_qactive      (clk_qactive),
  .clk_dev_run      (clk_dev_run),

  .pwr_qreq_n       (pwr_qreq_n),
  .pwr_qreq_sync_n  (pwr_qreq_sync_n),
  .pwr_qdeny        (pwr_qdeny),
  .pwr_qaccept_n    (pwr_qaccept_n),
  .pwr_qactive      (pwr_qactive),
  .pwr_dev_run      (pwr_dev_run),

  .psel             (psel_s),
  .pwakeup          (pwakeup_s),

  .rempur           (rempur),
  .rempua           (rempua_sync),
  .remrr            (remrr),
  .remra            (remra_sync),

  .tx_linkest       (tx_linkest),
  .rx_linkest       (rx_linkest),
  .rx_linkest_reg   (rx_linkest_reg),
  .tx_valid         (tx_valid),

  .rx_valid         (rx_valid),
  .rxfifo_full      (rxfifo_full),

  .irq              (irq),

  .clk_lp_request   (),
  .pwr_lp_request   ()

);

sdc600_apbcom_txengine #(
  .APBCOM_VAR         (APBCOM_VAR)
) u_txengine (

  .clk            (pclk),
  .reset_n        (preset_n),
  .remra_sync     (remra_sync),
  .wdata          (pwdata_s[7:0]),
  .rempur         (rempur),
  .remrr          (remrr),
  .rrdis          (cfg_rrdis_sync),

  .tx_ready       (tx_ready),
  .tx_linkup      (tx_linkup),
  .tx_data        (tx_data),
  .tx_valid       (tx_valid),
  .tx_linkest     (tx_linkest),

  .delay_pready   (delay_pready),

  .wr_str_dr      (wr_str_dr),
  .wr_str_dbr     (wr_str_dbr),
  .set_txoe       (set_txoe),
  .txfifo_empty   (txfifo_empty),
  .set_txlerr     (set_txlerr),

  .wr_str_lph1ra  (wr_str_lph1ra),
  .wr_str_lph1rl  (wr_str_lph1rl),
  .pwr_dev_run    (pwr_dev_run)
);


sdc600_apbcom_rxengine u_rxengine (

  .clk            (pclk),
  .reset_n        (preset_n),
  .rempua_sync    (rempua_sync),

  .rx_data        (rx_data),
  .rx_valid       (rx_valid),
  .rx_linkest     (rx_linkest),
  .rx_ready       (rx_ready),
  .rx_linkup      (rx_linkup),

  .rdata_dr       (rdata_dr),
  .rxfifo_full    (rxfifo_full),

  .rd_str_dr      (rd_str_dr),

  .wr_str_lph1rl  (wr_str_lph1rl),
  .wr_str_lph1ra  (wr_str_lph1ra),
  .rempur         (rempur),
  .set_txlerr     (set_txlerr),

  .pwr_dev_run    (pwr_dev_run),
  .clk_dev_run    (clk_dev_run),
  .rx_linkest_reg (rx_linkest_reg)

);


sdc600_sync #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
  u_clk_qreq_sync (.clk (pclk), .reset_n (preset_n), .d (clk_qreq_n), .q (clk_qreq_sync_n));


generate
  if (APBCOM_VAR != APBCOM_INT) begin : GENTOP_SYNC_EXT

    sdc600_sync #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_rempua (.clk (pclk), .reset_n (preset_n), .d (rempua   ),  .q (rempua_sync   ));
    sdc600_sync #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_remra  (.clk (pclk), .reset_n (preset_n), .d (remra    ),  .q (remra_sync    ));
    sdc600_sync #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_rrdis  (.clk (pclk), .reset_n (preset_n), .d (cfg_rrdis),  .q (cfg_rrdis_sync));

    assign pwr_qreq_sync_n = pwr_qreq_n;

  end
  else begin  : GENTOP_SYNC_INT
    assign rempua_sync    = rempua;
    assign remra_sync     = remra;
    assign cfg_rrdis_sync = cfg_rrdis;

    sdc600_sync #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_pwr_qreq_sync (.clk (pclk), .reset_n (preset_n), .d (pwr_qreq_n), .q (pwr_qreq_sync_n));

  end
endgenerate


endmodule
