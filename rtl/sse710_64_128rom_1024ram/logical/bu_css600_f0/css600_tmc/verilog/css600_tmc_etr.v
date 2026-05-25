//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_tmc
//
//----------------------------------------------------------------------------


module css600_tmc_etr #(parameter
  WBUFFER_DEPTH  = 4,
  ATB_DATA_WIDTH = 32,
  AXI_ADDR_WIDTH = 40,
  FF_SYNC_DEPTH  = 2,
  REVAND         = 4'h0
)
(
  clk,
  reset_n,

  atwakeup_s,
  atid_s,
  atbytes_s,
  atdata_s,
  atvalid_s,
  atready_s,
  afvalid_s,
  afready_s,
  syncreq_s,

  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  pready_s,
  pslverr_s,
  prdata_s,

  awakeup_m,
  araddr_m,
  arlen_m,
  arsize_m,
  arburst_m,
  arlock_m,
  arcache_m,
  arprot_m,
  arvalid_m,
  arready_m,
  rdata_m,
  rresp_m,
  rlast_m,
  rvalid_m,
  rready_m,
  awaddr_m,
  awlen_m,
  awsize_m,
  awburst_m,
  awlock_m,
  awcache_m,
  awprot_m,
  awvalid_m,
  awready_m,
  wdata_m,
  wstrb_m,
  wlast_m,
  wvalid_m,
  wready_m,
  bresp_m,
  bvalid_m,
  bready_m,

  dbgen,
  spiden,

  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,
  clk_qactive,

  trigin,
  flushin,
  full,
  acqcomp,
  flushcomp,

  bufintr,

  dftcgen
);

`include "css600_tmc_localparams.v"
`include "css600_tmc_functions.v"


localparam WBUFFER_DEPTH_QUAL  = ((WBUFFER_DEPTH != 4) &&
                                  (WBUFFER_DEPTH != 8) &&
                                  (WBUFFER_DEPTH != 16) &&
                                  (WBUFFER_DEPTH != 32)) ?
                                     4 : WBUFFER_DEPTH;

localparam ATB_DATA_WIDTH_QUAL = ((ATB_DATA_WIDTH != 32) &&
                                  (ATB_DATA_WIDTH != 64) &&
                                  (ATB_DATA_WIDTH != 128)) ?
                                     32 : ATB_DATA_WIDTH;

localparam AXI_ADDR_WIDTH_QUAL = ((AXI_ADDR_WIDTH != 32) &&
                                  (AXI_ADDR_WIDTH != 40) &&
                                  (AXI_ADDR_WIDTH != 44) &&
                                  (AXI_ADDR_WIDTH != 48) &&
                                  (AXI_ADDR_WIDTH != 52)) ?
                                     40 : AXI_ADDR_WIDTH;

localparam FF_SYNC_DEPTH_QUAL  = ((FF_SYNC_DEPTH != 2) &&
                                  (FF_SYNC_DEPTH != 3)) ?
                                     2 : FF_SYNC_DEPTH;

localparam TMC_CONFIG     = ETR;

localparam ATBYTES_WIDTH  = (ATB_DATA_WIDTH_QUAL == 8) ?
                               1 : tmc_clog2(ATB_DATA_WIDTH_QUAL/8);

localparam AXI_DATA_WIDTH = ATB_DATA_WIDTH_QUAL;


  input  wire                             clk;
  input  wire                             reset_n;

  input  wire                             atwakeup_s;
  input  wire [6:0]                       atid_s;
  input  wire [ATBYTES_WIDTH-1:0]         atbytes_s;
  input  wire [ATB_DATA_WIDTH_QUAL-1:0]   atdata_s;
  input  wire                             atvalid_s;
  output wire                             atready_s;
  output wire                             afvalid_s;
  input  wire                             afready_s;
  output wire                             syncreq_s;

  input  wire                             pwakeup_s;
  input  wire                             psel_s;
  input  wire                             penable_s;
  input  wire                             pwrite_s;
  input  wire [11:0]                      paddr_s;
  input  wire [31:0]                      pwdata_s;
  output wire                             pready_s;
  output wire                             pslverr_s;
  output wire [31:0]                      prdata_s;

  output wire                             awakeup_m;
  output wire [AXI_ADDR_WIDTH_QUAL-1:0]   araddr_m;
  output wire [7:0]                       arlen_m;
  output wire [2:0]                       arsize_m;
  output wire [1:0]                       arburst_m;
  output wire                             arlock_m;
  output wire [3:0]                       arcache_m;
  output wire [2:0]                       arprot_m;
  output wire                             arvalid_m;
  input  wire                             arready_m;
  input wire [AXI_DATA_WIDTH-1:0]         rdata_m;
  input wire [1:0]                        rresp_m;
  input wire                              rlast_m;
  input wire                              rvalid_m;
  output wire                             rready_m;
  output wire [AXI_ADDR_WIDTH_QUAL-1:0]   awaddr_m;
  output wire [7:0]                       awlen_m;
  output wire [2:0]                       awsize_m;
  output wire [1:0]                       awburst_m;
  output wire                             awlock_m;
  output wire [3:0]                       awcache_m;
  output wire [2:0]                       awprot_m;
  output wire                             awvalid_m;
  input  wire                             awready_m;
  output wire [AXI_DATA_WIDTH-1:0]        wdata_m;
  output wire [(AXI_DATA_WIDTH/8)-1:0]    wstrb_m;
  output wire                             wlast_m;
  output wire                             wvalid_m;
  input  wire                             wready_m;
  input  wire [1:0]                       bresp_m;
  input  wire                             bvalid_m;
  output wire                             bready_m;

  input  wire                             dbgen;
  input  wire                             spiden;

  input  wire                             clk_qreq_n;
  output wire                             clk_qaccept_n;
  output wire                             clk_qdeny;
  output wire                             clk_qactive;

  input  wire                             trigin;
  input  wire                             flushin;
  output wire                             full;
  output wire                             acqcomp;
  output wire                             flushcomp/*verilator clock_enable*/;

  output wire                             bufintr;

  input  wire                             dftcgen;


  wire [3:0] w_revand;

  css600_tmc_core
  #(
    .TMC_CONFIG      (TMC_CONFIG),
    .WBUFFER_DEPTH   (WBUFFER_DEPTH_QUAL),
    .ATB_DATA_WIDTH  (ATB_DATA_WIDTH_QUAL),
    .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH_QUAL),
    .FF_SYNC_DEPTH   (FF_SYNC_DEPTH_QUAL)
  )
  u_css600_tmc_core
  (
    .clk           (clk),
    .reset_n       (reset_n),

    .atwakeup_m    (),
    .atid_m        (),
    .atbytes_m     (),
    .atdata_m      (),
    .atvalid_m     (),
    .atready_m     (1'b0),
    .afvalid_m     (1'b0),
    .afready_m     (),
    .syncreq_m     (1'b0),

    .atwakeup_s    (atwakeup_s),
    .atid_s        (atid_s),
    .atbytes_s     (atbytes_s),
    .atdata_s      (atdata_s),
    .atvalid_s     (atvalid_s),
    .atready_s     (atready_s),
    .afvalid_s     (afvalid_s),
    .afready_s     (afready_s),
    .syncreq_s     (syncreq_s),

    .pwakeup_s     (pwakeup_s),
    .psel_s        (psel_s),
    .penable_s     (penable_s),
    .pwrite_s      (pwrite_s),
    .paddr_s       (paddr_s),
    .pwdata_s      (pwdata_s),
    .pready_s      (pready_s),
    .pslverr_s     (pslverr_s),
    .prdata_s      (prdata_s),

    .mem_ce_n      (),
    .mem_we_n      (),
    .mem_addr      (),
    .mem_d         (),
    .mem_q         ({2*ATB_DATA_WIDTH_QUAL{1'b0}}),

    .awakeup_m     (awakeup_m),
    .araddr_m      (araddr_m),
    .arlen_m       (arlen_m),
    .arsize_m      (arsize_m),
    .arburst_m     (arburst_m),
    .arlock_m      (arlock_m),
    .arcache_m     (arcache_m),
    .arprot_m      (arprot_m),
    .arvalid_m     (arvalid_m),
    .arready_m     (arready_m),
    .rdata_m       (rdata_m),
    .rresp_m       (rresp_m),
    .rlast_m       (rlast_m),
    .rvalid_m      (rvalid_m),
    .rready_m      (rready_m),
    .awaddr_m      (awaddr_m),
    .awlen_m       (awlen_m),
    .awsize_m      (awsize_m),
    .awburst_m     (awburst_m),
    .awlock_m      (awlock_m),
    .awcache_m     (awcache_m),
    .awprot_m      (awprot_m),
    .awvalid_m     (awvalid_m),
    .awready_m     (awready_m),
    .wdata_m       (wdata_m),
    .wstrb_m       (wstrb_m),
    .wlast_m       (wlast_m),
    .wvalid_m      (wvalid_m),
    .wready_m      (wready_m),
    .bresp_m       (bresp_m),
    .bvalid_m      (bvalid_m),
    .bready_m      (bready_m),

    .twakeup_m     (),
    .tdata_m       (),
    .tvalid_m      (),
    .tready_m      (1'b0),
    .tlast_m       (),

    .dbgen         (dbgen),
    .spiden        (spiden),

    .clk_qreq_n    (clk_qreq_n),
    .clk_qaccept_n (clk_qaccept_n),
    .clk_qdeny     (clk_qdeny),
    .clk_qactive   (clk_qactive),

    .trigin        (trigin),
    .flushin       (flushin),
    .full          (full),
    .acqcomp       (acqcomp),
    .flushcomp     (flushcomp),

    .bufintr       (bufintr),

    .dftcgen       (dftcgen),

    .revand        (w_revand)
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));

endmodule

