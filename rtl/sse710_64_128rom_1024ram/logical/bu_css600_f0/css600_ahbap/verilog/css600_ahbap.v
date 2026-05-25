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
//   Top level of css600_ahbap
//
//----------------------------------------------------------------------------


module css600_ahbap #(
  parameter FF_SYNC_DEPTH  = 2,
            REVAND         = 4'h0
)
(
  clk,
  reset_n,
  dftcgen,
  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  prdata_s,
  pready_s,
  pslverr_s,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qactive,
  clk_qdeny,
  ap_en,
  ap_secure_en,
  baseaddr_valid,
  baseaddr,
  dp_abort,
  haddr_m,
  hwrite_m,
  htrans_m,
  hsize_m,
  hburst_m,
  hprot_m,
  hnonsec_m,
  hlock_m,
  hwdata_m,
  hready_m,
  hresp_m,
  hrdata_m
);

  localparam L_AHB_ADDR_WIDTH =  32;
  localparam L_AHB_DATA_WIDTH =  32;
  localparam NUM_LAPS = 2;
  localparam INT_FF_SYNC_DEPTH =  (FF_SYNC_DEPTH == 2)
                               || (FF_SYNC_DEPTH == 3)
                                 ? FF_SYNC_DEPTH
                                 : 2;


  input  wire                         clk;
  input  wire                         reset_n;
  input  wire                         dftcgen;
  input  wire                         pwakeup_s;
  input  wire                         psel_s;
  input  wire                         penable_s;
  input  wire                         pwrite_s;
  input  wire [12:0]                  paddr_s;
  input  wire [31:0]                  pwdata_s;
  output wire [31:0]                  prdata_s;
  output wire                         pready_s;
  output wire                         pslverr_s;
  input  wire                         clk_qreq_n;
  output wire                         clk_qaccept_n;
  output wire                         clk_qactive;
  output wire                         clk_qdeny;
  input  wire                         ap_en;
  input  wire                         ap_secure_en;
  input  wire                         baseaddr_valid;
  input  wire [31:0]                  baseaddr;
  input  wire                         dp_abort;
  output wire [L_AHB_ADDR_WIDTH-1:0]  haddr_m;
  output wire                         hwrite_m;
  output wire [1:0]                   htrans_m;
  output wire [2:0]                   hsize_m;
  output wire [2:0]                   hburst_m;
  output wire [6:0]                   hprot_m;
  output wire                         hnonsec_m;
  output wire                         hlock_m;
  output wire [L_AHB_DATA_WIDTH-1:0]  hwdata_m;
  input  wire                         hready_m;
  input  wire                         hresp_m;
  input  wire [L_AHB_DATA_WIDTH-1:0]  hrdata_m;

  wire                  mstr_tr_req;
  wire                  mstr_rd_wr;
  wire           [31:0] mstr_addr;
  wire            [6:0] mstr_prot;
  wire            [2:0] mstr_size;
  wire                  mstr_nonsec;
  wire                  mstr_tr_in_prog;
  wire                  mstr_tr_done;
  wire           [31:0] mstr_wr_data;
  wire           [31:0] mstr_rd_data;
  wire                  mstr_err;
  wire           [1:0]  mstr_state;

  wire                  clk_g;
  wire                  int_clk_en /* verilator clock_enable */;
  wire                  lp_request;
  wire                  dev_active;
  wire                  lp_done;
  wire                  dev_run;
  wire                  itctrl_ime;
  wire                  clk_qreq_n_sync;

  wire            [3:0] w_revand;


css600_ahbap_apbslv
  u_css600_ahbap_apbslv
(
  .clk                               (clk_g),
  .reset_n                           (reset_n),
  .psel_s                            (psel_s),
  .penable_s                         (penable_s),
  .pwrite_s                          (pwrite_s),
  .paddr_s                           (paddr_s[12:0]),
  .pwdata_s                          (pwdata_s[31:0]),
  .pready_s                          (pready_s),
  .pslverr_s                         (pslverr_s),
  .prdata_s                          (prdata_s[31:0]),
  .ap_en                             (ap_en),
  .ap_secure_en                      (ap_secure_en),
  .dp_abort                          (dp_abort),
  .dev_run                           (dev_run),
  .itctrl_ime                        (itctrl_ime),
  .baseaddr                          (baseaddr[31:0]),
  .baseaddr_valid                    (baseaddr_valid),
  .mstr_tr_req                       (mstr_tr_req),
  .mstr_rd_wr                        (mstr_rd_wr),
  .mstr_addr                         (mstr_addr[31:0]),
  .mstr_prot                         (mstr_prot),
  .mstr_size                         (mstr_size[2:0]),
  .mstr_nonsec                       (mstr_nonsec),
  .mstr_tr_in_prog                   (mstr_tr_in_prog),
  .mstr_tr_done                      (mstr_tr_done),
  .mstr_rd_data                      (mstr_rd_data[31:0]),
  .mstr_err                          (mstr_err),
  .revand                            (w_revand)
);

  assign mstr_wr_data = pwdata_s[31:0];

  assign haddr_m = mstr_addr[31:0];

  assign hprot_m = mstr_prot;
  assign hsize_m = mstr_size;
  assign hnonsec_m = mstr_nonsec;
  assign hburst_m = 3'b000;
  assign hlock_m = 1'b0;
  assign htrans_m[0] = 1'b0;

  assign mstr_err = hresp_m;
  assign mstr_rd_data = hrdata_m;


css600_ahbap_ahbmstr
   u_css600_ahbap_ahbmstr
(
  .clk                               (clk_g),
  .reset_n                           (reset_n),
  .htrans                            (htrans_m[1]),
  .hwrite_m                          (hwrite_m),
  .hwdata_m                          (hwdata_m),
  .hready_m                          (hready_m),
  .mstr_tr_req                       (mstr_tr_req),
  .mstr_rd_wr                        (mstr_rd_wr),
  .mstr_wr_data                      (mstr_wr_data[31:0]),
  .mstr_tr_in_prog                   (mstr_tr_in_prog),
  .mstr_tr_done                      (mstr_tr_done),
  .mstr_state                        (mstr_state)
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
      #(.FF_SYNC_DEPTH (INT_FF_SYNC_DEPTH))
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

  css600_ahbap_async u_qactive_async (
    .clk_qactive (clk_qactive),
    .pwakeup_s (pwakeup_s),
    .mstr_state (mstr_state),
    .itctrl_ime (itctrl_ime)
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));


 endmodule
