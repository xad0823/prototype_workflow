//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_axiap
//
//----------------------------------------------------------------------------


module css600_axiap_core #(parameter
  AXI_ADDR_WIDTH        = 32,
  AXI_DATA_WIDTH        = 32,
  AXI_WSTRB_WIDTH       = 4,
  MTE_PRESENT           = 0,
  MTE_TAG_WIDTH         = 4,
  MTE_TAG_GRANULE       = 4,
  FF_SYNC_DEPTH         = 2
)
(
  clk,
  reset_n,
  dftcgen,
  revand,
  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  pready_s,
  pslverr_s,
  prdata_s,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qactive,
  clk_qdeny,
  ap_en,
  ap_secure_en,
  baseaddr_valid,
  baseaddr,
  dp_abort,
  arlock_m,
  arvalid_m,
  arready_m,
  rlast_m,
  rvalid_m,
  rready_m,
  awlock_m,
  awvalid_m,
  awready_m,
  wlast_m,
  wvalid_m,
  wready_m,
  bvalid_m,
  bready_m,
  arlen_m,
  arburst_m,
  arcache_m,
  arprot_m,
  rresp_m,
  awlen_m,
  awburst_m,
  awcache_m,
  awprot_m,
  bresp_m,
  awdomain_m,
  awsnoop_m,
  ardomain_m,
  arsnoop_m,
  araddr_m,
  arsize_m,
  rdata_m,
  awaddr_m,
  awsize_m,
  wdata_m,
  wstrb_m,
  awakeup_m,
  awtagop_m,
  wtagupdate_m,
  wtag_m,
  artagop_m,
  rtag_m
);

  input  wire                            clk;
  input  wire                            reset_n;
  input  wire                            dftcgen;
  input  wire [3:0]                      revand;
  input  wire                            psel_s;
  input  wire                            penable_s;
  input  wire                            pwrite_s;
  output wire                            pready_s;
  output wire                            pslverr_s;
  input  wire [12:0]                     paddr_s;
  input  wire [31:0]                     pwdata_s;
  output wire [31:0]                     prdata_s;
  input  wire                            pwakeup_s;
  input  wire                            clk_qreq_n;
  output wire                            clk_qaccept_n;
  output wire                            clk_qactive;
  output wire                            clk_qdeny;
  input  wire                            ap_en;
  input  wire                            ap_secure_en;
  input  wire                            baseaddr_valid;
  input  wire [AXI_ADDR_WIDTH-1:0]       baseaddr;
  input  wire                            dp_abort;
  output wire                            arlock_m;
  output wire                            arvalid_m;
  input  wire                            arready_m;
  input  wire                            rlast_m;
  input  wire                            rvalid_m;
  output wire                            rready_m;
  output wire                            awlock_m;
  output wire                            awvalid_m;
  input  wire                            awready_m;
  output wire                            wlast_m;
  output wire                            wvalid_m;
  input  wire                            wready_m;
  input  wire                            bvalid_m;
  output wire                            bready_m;
  output wire [7:0]                      arlen_m;
  output wire [1:0]                      arburst_m;
  output wire [3:0]                      arcache_m;
  output wire [2:0]                      arprot_m;
  input  wire [1:0]                      rresp_m;
  output wire [7:0]                      awlen_m;
  output wire [1:0]                      awburst_m;
  output wire [3:0]                      awcache_m;
  output wire [2:0]                      awprot_m;
  input  wire [1:0]                      bresp_m;
  output wire [1:0]                      awdomain_m;
  output wire [2:0]                      awsnoop_m;
  output wire [1:0]                      ardomain_m;
  output wire [3:0]                      arsnoop_m;
  output wire [AXI_ADDR_WIDTH - 1:0]     araddr_m;
  output wire [2:0]                      arsize_m;
  input  wire [AXI_DATA_WIDTH - 1:0]     rdata_m;
  output wire [AXI_ADDR_WIDTH - 1:0]     awaddr_m;
  output wire [2:0]                      awsize_m;
  output wire [AXI_DATA_WIDTH - 1:0]     wdata_m;
  output wire [AXI_WSTRB_WIDTH-1:0]      wstrb_m;
  output wire                            awakeup_m;
  output wire [1:0]                      awtagop_m;
  output wire [(MTE_TAG_WIDTH/4)-1:0]    wtagupdate_m;
  output wire [MTE_TAG_WIDTH-1:0]        wtag_m;
  output wire [1:0]                      artagop_m;
  input  wire [MTE_TAG_WIDTH-1:0]        rtag_m;


  wire                        dev_run;
  wire                        mstr_tr_in_prog;
  wire                        itctrl_ime;
  wire                        mstr_tr_done;
  wire                        mstr_err;
  wire                        bd_sel;
  wire                        drw_sel;
  wire                        dar_sel;
  wire                        bd_dar_access;
  wire                        mstr_mte;
  wire [3:0]                  mstr_wtag;
  wire [3:0]                  mstr_rtag;
  wire                        mstr_rtag_transfer;
  wire                        mstr_tr_req;
  wire [1:0]                  mstr_csw_req;
  wire                        mstr_nrd_wr;
  wire                        boss_twin;
  wire                        dev_active;
  wire                        int_clk_en /* verilator clock_enable */;
  wire [AXI_ADDR_WIDTH-1:0]   mstr_addr;
  wire [1:0]                  mstr_size;
  wire [3:0]                  mstr_cache;
  wire [2:0]                  mstr_prot;
  wire [1:0]                  mstr_ace_domain;
  wire                        ap0_dword_inc;
  wire                        ap1_dword_inc;
  wire [31:0]                 mstr_rd_data;
  wire                        abort_req;
  wire                        lp_request;
  wire                        lp_done;
  wire                        clk_qreq_n_sync;
  wire                        clk_g;

css600_axiap_apbslv #(
  .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
  .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
  .MTE_PRESENT     (MTE_PRESENT),
  .MTE_TAG_WIDTH   (MTE_TAG_WIDTH),
  .MTE_TAG_GRANULE (MTE_TAG_GRANULE)
) u_apbslv
(
  .clk                 (clk_g),
  .reset_n             (reset_n),
  .psel_s              (psel_s),
  .penable_s           (penable_s),
  .pwrite_s            (pwrite_s),
  .paddr_s             (paddr_s),
  .pwdata_s            (pwdata_s),
  .pready_s            (pready_s),
  .pslverr_s           (pslverr_s),
  .prdata_s            (prdata_s),
  .ap_en               (ap_en),
  .ap_secure_en        (ap_secure_en),
  .dp_abort            (dp_abort),
  .dev_run             (dev_run),
  .itctrl_ime          (itctrl_ime),
  .baseaddr            (baseaddr),
  .baseaddr_valid      (baseaddr_valid),
  .mstr_mte            (mstr_mte),
  .mstr_wtag           (mstr_wtag),
  .mstr_rtag           (mstr_rtag),
  .mstr_rtag_transfer  (mstr_rtag_transfer),
  .mstr_tr_req         (mstr_tr_req),
  .mstr_csw_req        (mstr_csw_req),
  .mstr_nrd_wr         (mstr_nrd_wr),
  .mstr_addr           (mstr_addr),
  .mstr_prot           (mstr_prot),
  .mstr_cache          (mstr_cache),
  .mstr_ace_domain     (mstr_ace_domain),
  .mstr_size           (mstr_size),
  .mstr_tr_in_prog     (mstr_tr_in_prog),
  .mstr_tr_done        (mstr_tr_done),
  .mstr_err            (mstr_err),
  .ap0_dword_inc       (ap0_dword_inc),
  .ap1_dword_inc       (ap1_dword_inc),
  .drw_sel             (drw_sel),
  .bd_sel              (bd_sel),
  .dar_sel             (dar_sel),
  .bd_dar_access       (bd_dar_access),
  .mstr_rd_data        (mstr_rd_data),
  .abort_req           (abort_req),
  .boss_twin           (boss_twin),
  .revand              (revand)
);


css600_axiap_aximstr #(
  .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
  .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
  .AXI_WSTRB_WIDTH (AXI_WSTRB_WIDTH),
  .MTE_PRESENT     (MTE_PRESENT),
  .MTE_TAG_WIDTH   (MTE_TAG_WIDTH),
  .MTE_TAG_GRANULE (MTE_TAG_GRANULE)
) u_axi_master
(
  .clk                (clk_g),
  .reset_n            (reset_n),
  .awtagop            (awtagop_m),
  .awaddr             (awaddr_m),
  .awlen              (awlen_m),
  .awsize             (awsize_m),
  .awburst            (awburst_m),
  .awlock             (awlock_m),
  .awcache            (awcache_m),
  .awprot             (awprot_m),
  .awvalid            (awvalid_m),
  .awready            (awready_m),
  .wtagupdate         (wtagupdate_m),
  .wtag               (wtag_m),
  .wdata              (wdata_m),
  .wstrb              (wstrb_m),
  .wlast              (wlast_m),
  .wvalid             (wvalid_m),
  .wready             (wready_m),
  .bready             (bready_m),
  .bresp              (bresp_m),
  .bvalid             (bvalid_m),
  .artagop            (artagop_m),
  .araddr             (araddr_m),
  .arlen              (arlen_m),
  .arsize             (arsize_m),
  .arburst            (arburst_m),
  .arlock             (arlock_m),
  .arcache            (arcache_m),
  .arprot             (arprot_m),
  .arvalid            (arvalid_m),
  .arready            (arready_m),
  .rready             (rready_m),
  .rtag               (rtag_m),
  .rdata              (rdata_m),
  .rresp              (rresp_m),
  .rlast              (rlast_m),
  .rvalid             (rvalid_m),
  .awdomain           (awdomain_m),
  .awsnoop            (awsnoop_m),
  .ardomain           (ardomain_m),
  .arsnoop            (arsnoop_m),

  .mstr_addr          (mstr_addr),
  .mstr_size          (mstr_size),
  .mstr_cache         (mstr_cache),
  .mstr_prot          (mstr_prot),
  .mstr_ace_domain    (mstr_ace_domain),

  .mstr_tr_in_prog    (mstr_tr_in_prog),
  .mstr_tr_done       (mstr_tr_done),
  .mstr_err           (mstr_err),
  .ap0_dword_inc      (ap0_dword_inc),
  .ap1_dword_inc      (ap1_dword_inc),
  .bd_sel             (bd_sel),
  .drw_sel            (drw_sel),
  .dar_sel            (dar_sel),
  .bd_dar_access      (bd_dar_access),
  .mstr_mte           (mstr_mte),
  .mstr_wtag          (mstr_wtag),
  .mstr_rtag          (mstr_rtag),
  .mstr_rtag_transfer (mstr_rtag_transfer),
  .mstr_tr_req        (mstr_tr_req),
  .mstr_csw_req       (mstr_csw_req),
  .mstr_nrd_wr        (mstr_nrd_wr),
  .boss_twin          (boss_twin),

  .mstr_rd_data       (mstr_rd_data),
  .abort_req          (abort_req),
  .pwdata             (pwdata_s),
  .paddr_12           (paddr_s[12])
  );


  css600_clk_gate
    u_css600_clk_gate (
     .clk_i         (clk),
     .clk_enable_i  (int_clk_en),
     .clk_o         (clk_g),
     .dftcgen       (dftcgen)
    );

  assign int_clk_en = dev_active & dev_run;

    css600_cdc_capt_sync
      #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
    u_css600_cdc_capt_sync_qreq(
                                .clk       (clk),
                                .reset_n   (reset_n),
                                .d_async_i (clk_qreq_n),
                                .q_sync_o  (clk_qreq_n_sync)
                               );

  css600_lpislave
    u_css600_lpislave
    (
      .clk          (clk),
      .reset_n      (reset_n),
      .qreq_sync_n  (clk_qreq_n_sync),
      .qaccept_n    (clk_qaccept_n),
      .qdeny        (clk_qdeny),
      .lp_request   (lp_request),
      .dev_active   (dev_active),
      .lp_done      (lp_done),
      .dev_run      (dev_run),
      .cg_en        ()
    );

  assign dev_active = (psel_s | mstr_tr_in_prog | itctrl_ime);

  assign lp_done = lp_request;

  css600_axiap_async u_qactive_async (
    .pwakeup         (pwakeup_s        ),
    .mstr_tr_in_prog (mstr_tr_in_prog  ),
    .itctrl_ime      (itctrl_ime       ),
    .clk_qactive     (      clk_qactive
                                       ),
    .awvalid         (awvalid_m        ),
    .arvalid         (arvalid_m        ),
    .wvalid          (wvalid_m         ),
    .awakeup         (        awakeup_m
                                       )
  );


endmodule
