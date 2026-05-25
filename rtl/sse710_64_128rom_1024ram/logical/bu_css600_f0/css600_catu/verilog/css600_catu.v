//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
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
//   Top level of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu #(parameter
  AXI_ADDR_WIDTH = 48,
  AXI_DATA_WIDTH = 64,
  FF_SYNC_DEPTH  = 2,
  REVAND         = 4'h0
)
(
  clk,
  reset_n,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,
  clk_qactive,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  pwakeup_s,
  prdata_s,
  pready_s,
  pslverr_s,
  awakeup_m,
  araddr_m,
  arlen_m,
  arsize_m,
  arburst_m,
  arlock_m,
  arcache_m,
  arprot_m,
  arid_m,
  arvalid_m,
  arready_m,
  rdata_m,
  rresp_m,
  rlast_m,
  rid_m,
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
  awakeup_s,
  araddr_s,
  arlen_s,
  arsize_s,
  arburst_s,
  arlock_s,
  arcache_s,
  arprot_s,
  arvalid_s,
  arready_s,
  rdata_s,
  rresp_s,
  rlast_s,
  rvalid_s,
  rready_s,
  awaddr_s,
  awlen_s,
  awsize_s,
  awburst_s,
  awlock_s,
  awcache_s,
  awprot_s,
  awvalid_s,
  awready_s,
  wdata_s,
  wstrb_s,
  wlast_s,
  wvalid_s,
  wready_s,
  bresp_s,
  bvalid_s,
  bready_s,
  dbgen,
  spiden,
  addrerr,
  dftcgen
);

  localparam L_AXI_DATA_WIDTH = ( (AXI_DATA_WIDTH ==  32)  ||
                                  (AXI_DATA_WIDTH ==  64)  ||
                                  (AXI_DATA_WIDTH == 128)     ) ?
                                AXI_DATA_WIDTH : 64;

  localparam L_AXI_ADDR_WIDTH = ( (AXI_ADDR_WIDTH ==  32)  ||
                                  (AXI_ADDR_WIDTH ==  40)  ||
                                  (AXI_ADDR_WIDTH ==  44)  ||
                                  (AXI_ADDR_WIDTH ==  48)  ||
                                  (AXI_ADDR_WIDTH ==  52)  ||
                                  (AXI_ADDR_WIDTH ==  56)  ||
                                  (AXI_ADDR_WIDTH ==  64)     ) ?
                                AXI_ADDR_WIDTH : 40;

  localparam L_FF_SYNC_DEPTH  = ( (FF_SYNC_DEPTH  ==   2)  ||
                                  (FF_SYNC_DEPTH  ==   3)     ) ?
                                FF_SYNC_DEPTH  : 2;

  localparam L_APB_ADDR_WIDTH  = 12;
  localparam L_APB_DATA_WIDTH  = 32;
  localparam L_AXI_LEN_WIDTH   = 8;
  localparam L_AXI_SIZE_WIDTH  = 3;
  localparam L_AXI_BURST_WIDTH = 2;
  localparam L_AXI_CACHE_WIDTH = 4;
  localparam L_AXI_PROT_WIDTH  = 3;
  localparam L_AXI_RESP_WIDTH  = 2;
  localparam L_AXI_WSTRB_WIDTH = (L_AXI_DATA_WIDTH / 8);
  localparam L_VA_WIDTH        = L_AXI_ADDR_WIDTH;
  localparam L_PA_WIDTH        = L_AXI_ADDR_WIDTH;
  localparam L_PS_WIDTH        = 12;
  localparam TLB_RD_DEPTH    = 1;
  localparam TLB_WR_DEPTH    = 2;
  localparam TLB_DEPTH  = (TLB_RD_DEPTH > TLB_WR_DEPTH) ? TLB_RD_DEPTH : TLB_WR_DEPTH;
  localparam INIT_BITS = 1;
  localparam L_PROT_WIDTH  = 2;


  input  wire                          clk;
  input  wire                          reset_n;
  input  wire                          clk_qreq_n;
  output wire                          clk_qaccept_n;
  output wire                          clk_qdeny;
  output wire                          clk_qactive;
  input  wire                          psel_s;
  input  wire                          penable_s;
  input  wire                          pwrite_s;
  input  wire [L_APB_ADDR_WIDTH-1:0]   paddr_s;
  input  wire [L_APB_DATA_WIDTH-1:0]   pwdata_s;
  input  wire                          pwakeup_s;
  output wire [L_APB_DATA_WIDTH-1:0]   prdata_s;
  output wire                          pready_s;
  output wire                          pslverr_s;
  output wire                          awakeup_m;
  input  wire                          arready_m;
  output wire [1:0]                    arid_m;
  output wire [L_AXI_ADDR_WIDTH-1:0]   araddr_m;
  output wire [L_AXI_LEN_WIDTH-1:0]    arlen_m;
  output wire [L_AXI_SIZE_WIDTH-1:0]   arsize_m;
  output wire [L_AXI_BURST_WIDTH-1:0]  arburst_m;
  output wire                          arlock_m;
  output wire [L_AXI_CACHE_WIDTH-1:0]  arcache_m;
  output wire [L_AXI_PROT_WIDTH-1:0]   arprot_m;
  output wire                          arvalid_m;
  input  wire [L_AXI_DATA_WIDTH-1:0]   rdata_m;
  input  wire [L_AXI_RESP_WIDTH-1:0]   rresp_m;
  input  wire                          rlast_m;
  input  wire [1:0]                    rid_m;
  input  wire                          rvalid_m;
  output wire                          rready_m;
  input  wire                          awready_m;
  output wire [L_AXI_ADDR_WIDTH-1:0]   awaddr_m;
  output wire [L_AXI_LEN_WIDTH-1:0]    awlen_m;
  output wire [L_AXI_SIZE_WIDTH-1:0]   awsize_m;
  output wire [L_AXI_BURST_WIDTH-1:0]  awburst_m;
  output wire                          awlock_m;
  output wire [L_AXI_CACHE_WIDTH-1:0]  awcache_m;
  output wire [L_AXI_PROT_WIDTH-1:0]   awprot_m;
  output wire                          awvalid_m;
  input  wire                          wready_m;
  output wire [L_AXI_DATA_WIDTH-1:0]   wdata_m;
  output wire [L_AXI_WSTRB_WIDTH-1:0]  wstrb_m;
  output wire                          wlast_m;
  output wire                          wvalid_m;
  input  wire [L_AXI_RESP_WIDTH-1:0]   bresp_m;
  input  wire                          bvalid_m;
  output wire                          bready_m;
  input  wire                          awakeup_s;
  input  wire [L_AXI_ADDR_WIDTH-1:0]   araddr_s;
  input  wire [L_AXI_LEN_WIDTH-1:0]    arlen_s;
  input  wire [L_AXI_SIZE_WIDTH-1:0]   arsize_s;
  input  wire [L_AXI_BURST_WIDTH-1:0]  arburst_s;
  input  wire                          arlock_s;
  input  wire [L_AXI_CACHE_WIDTH-1:0]  arcache_s;
  input  wire [L_AXI_PROT_WIDTH-1:0]   arprot_s;
  input  wire                          arvalid_s;
  output wire                          arready_s;
  input  wire                          rready_s;
  output wire [L_AXI_DATA_WIDTH-1:0]   rdata_s;
  output wire [L_AXI_RESP_WIDTH-1:0]   rresp_s;
  output wire                          rlast_s;
  output wire                          rvalid_s;
  input  wire [L_AXI_ADDR_WIDTH-1:0]   awaddr_s;
  input  wire [L_AXI_LEN_WIDTH-1:0]    awlen_s;
  input  wire [L_AXI_SIZE_WIDTH-1:0]   awsize_s;
  input  wire [L_AXI_BURST_WIDTH-1:0]  awburst_s;
  input  wire                          awlock_s;
  input  wire [L_AXI_CACHE_WIDTH-1:0]  awcache_s;
  input  wire [L_AXI_PROT_WIDTH-1:0]   awprot_s;
  input  wire                          awvalid_s;
  output wire                          awready_s;
  input  wire [L_AXI_DATA_WIDTH-1:0]   wdata_s;
  input  wire [L_AXI_WSTRB_WIDTH-1:0]  wstrb_s;
  input  wire                          wlast_s;
  input  wire                          wvalid_s;
  output wire                          wready_s;
  input  wire                          bready_s;
  output wire [L_AXI_RESP_WIDTH-1:0]   bresp_s;
  output wire                          bvalid_s;
  input  wire                          dbgen;
  input  wire                          spiden;
  output wire                          addrerr;
  input  wire                          dftcgen;


  localparam DSIZE = 3;
  localparam SLW_DATA_WIDTH = L_PA_WIDTH-L_PS_WIDTH+INIT_BITS;

  wire                            int_clk_en /* verilator clock_enable */;
  wire                            clk_g;
  wire                            dev_run;
  wire                            clk_qreq_n_sync;
  wire                            catu_lp_done;
  wire                            catu_lp_request;
  wire                            catu_active;
  wire                            catu_active_s;
  wire                            catu_wake_up;
  wire [L_APB_DATA_WIDTH-1:0]     apbslv_reg_rdata;
  wire                            apbslv_reg_write;
  wire                            apbslv_reg_read;
  wire [L_APB_ADDR_WIDTH-1:0]     apbslv_reg_addr;
  wire [L_APB_DATA_WIDTH-1:0]     apbslv_reg_wdata;
  wire                            ctrl_enable;
  wire                            ctrl_mode;
  wire [L_AXI_CACHE_WIDTH-1:0]    axictrl_arcache;
  wire [L_PROT_WIDTH-1:0]         axictrl_arprot;
  wire [L_AXI_ADDR_WIDTH-1:0]     ctrl_sladdr;
  wire [L_AXI_ADDR_WIDTH-1:0]     ctrl_inaddr;
  wire [L_VA_WIDTH-1:0]           axislv_araddr;
  wire [L_AXI_LEN_WIDTH-1:0]      axislv_arlen;
  wire [L_AXI_SIZE_WIDTH-1:0]     axislv_arsize;
  wire [L_AXI_BURST_WIDTH-1:0]    axislv_arburst;
  wire                            axislv_arlock;
  wire [L_AXI_CACHE_WIDTH-1:0]    axislv_arcache;
  wire [L_PROT_WIDTH-1:0]         axislv_arprot;
  wire                            bypass_arvalid;
  wire                            bypass_arready;
  wire                            ds_arvalid;
  wire                            ds_arready;
  wire [L_AXI_DATA_WIDTH-1:0]     int_rdata;
  wire [L_AXI_RESP_WIDTH-1:0]     int_rresp;
  wire                            int_rlast;
  wire                            axislv_rvalid;
  wire                            axislv_rready;
  wire [L_AXI_RESP_WIDTH-1:0]     ds_rresp;
  wire                            ds_rlast;
  wire                            ds_rvalid;
  wire                            ds_rready;
  wire                            wr_auth_err;
  wire                            wr_oor_va;
  wire                            invalid_wr;
  wire                            wr_trans_busy;
  wire                            rd_auth_err;
  wire                            rd_oor_va;
  wire                            invalid_rd;
  wire                            rd_trans_busy;
  wire [L_VA_WIDTH-1:0]           axislv_awaddr;
  wire [L_AXI_LEN_WIDTH-1:0]      axislv_awlen;
  wire [L_AXI_SIZE_WIDTH-1:0]     axislv_awsize;
  wire [L_AXI_BURST_WIDTH-1:0]    axislv_awburst;
  wire                            axislv_awlock;
  wire [L_AXI_CACHE_WIDTH-1:0]    axislv_awcache;
  wire [L_PROT_WIDTH-1:0]         axislv_awprot;
  wire                            bypass_awvalid;
  wire                            bypass_awready;
  wire                            ds_awvalid;
  wire                            ds_awready;
  wire [L_AXI_DATA_WIDTH-1:0]     axislv_wdata;
  wire [L_AXI_WSTRB_WIDTH-1:0]    axislv_wstrb;
  wire                            axislv_wlast;
  wire                            axislv_wvalid;
  wire                            axislv_wready;
  wire                            ds_wvalid;
  wire                            ds_wready;
  wire [L_AXI_RESP_WIDTH-1:0]     axislv_bresp;
  wire                            axislv_bvalid;
  wire                            axislv_bready;
  wire [L_AXI_RESP_WIDTH-1:0]     ds_bresp;
  wire                            ds_bvalid;
  wire                            ds_bready;
/* verilator lint_off UNOPTFLAT */
  wire                            axislv_busy;
/* verilator lint_on UNOPTFLAT */
  wire                            enable_busy;
  wire                            outs_wr_cntr_noteq0;
  wire                            outs_rd_cntr_noteq0;
  wire                            reg_arvalid;
  wire                            reg_awvalid;
  wire                            axislv_axi_autherr;
  wire                            rd_ds_select;
  wire                            wr_ds_select;
  wire                            rds_drained;
  wire                            wrs_drained;
  wire                            aximstr_resperr;
  wire                            slw_err;
  wire                            rd_resperr;
  wire                            wr_resperr;
  wire [L_PA_WIDTH-L_PS_WIDTH:0]  tlb_rd_result;
  wire [L_PA_WIDTH-L_PS_WIDTH:0]  tlb_wr_result;
  wire                            w_prefetch;
  wire                            fetch_busy;
  wire                            slw_busy;
  wire                            slw_addrerr;
  wire                            translate_arvalid;
  wire                            translate_arready;
  wire                            translated_arvalid;
  wire                            translated_arready;
  wire [L_PA_WIDTH-1:0]           translated_araddr;
  wire                            arvalid_t;
  wire                            arready_t;
  wire                            translate_awvalid;
  wire                            translate_awready;
  wire                            translated_awvalid;
  wire                            translated_awready;
  wire [L_PA_WIDTH-1:0]           translated_awaddr;
  wire                            awvalid_t;
  wire                            awready_t;
  wire                            init_slw;
  wire                            tlb_initialised;
  wire                            init_tlbs;
  wire                            clr_tlbs;
  wire                            slw_arvalid;
  wire                            slw_arready;
  wire [1:0]                      slw_aid;
  wire [L_PA_WIDTH-1:0]           slw_araddr;
  wire [3:0]                      slw_arlen;
  wire [L_AXI_SIZE_WIDTH-1:0]     slw_arsize;
  wire [1:0]                      slw_rid;
  wire                            slw_rvalid;
  wire                            slw_rready;
  wire                            slw_rlast;
  wire                            slw_rd_tlb_valid;
  wire                            slw_wr_tlb_valid;
  wire                            slw_wr_tlb_upd;
  wire                            slw_wr_tlb_inv;
  wire                            slw_invalid_tlb_pftch;
  wire [SLW_DATA_WIDTH-1:0]       slw_tlb_data;
  wire                            trans_slw_arvalid;
  wire                            trans_slw_arready;
  wire                            upd_awaddr_en;
  wire                            trans_slw_awvalid;
  wire                            trans_slw_awready;
  wire                            wr_prefetch;
  wire                            wr_pre_addr_inc_ndec;
  wire [L_VA_WIDTH-L_PS_WIDTH-1:0]wr_pre_addr;
  wire [3:0]                      w_revand;


  css600_clk_gate
  u_css600_catu_clk_gate
  (
    .clk_i        ( clk        ),
    .clk_enable_i ( int_clk_en ),
    .clk_o        ( clk_g      ),
    .dftcgen      ( dftcgen    )
  );


  css600_catu_apb_slave_if
  #(
    .APB_ADDR_WIDTH  ( L_APB_ADDR_WIDTH ),
    .APB_DATA_WIDTH  ( L_APB_DATA_WIDTH )
  )
  u_css600_catu_apb_slave_if
  (
    .clk                   ( clk_g            ),
    .reset_n               ( reset_n          ),
    .dev_run               ( dev_run          ),
    .apbslv_if_psel        ( psel_s           ),
    .apbslv_if_penable     ( penable_s        ),
    .apbslv_if_pwrite      ( pwrite_s         ),
    .apbslv_if_paddr       ( paddr_s          ),
    .apbslv_if_pwdata      ( pwdata_s         ),
    .apbslv_if_prdata      ( prdata_s         ),
    .apbslv_if_pready      ( pready_s         ),
    .apbslv_if_pslverr     ( pslverr_s        ),
    .reg_rdata             ( apbslv_reg_rdata ),
    .reg_write             ( apbslv_reg_write ),
    .reg_read              ( apbslv_reg_read  ),
    .reg_addr              ( apbslv_reg_addr  ),
    .reg_wdata             ( apbslv_reg_wdata )
  );

  css600_catu_reg_block
  #(
    .APB_ADDR_WIDTH  ( L_APB_ADDR_WIDTH ),
    .APB_DATA_WIDTH  ( L_APB_DATA_WIDTH ),
    .AXI_ADDR_WIDTH  ( L_AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH  ( L_AXI_DATA_WIDTH )
  )
  u_css600_catu_reg_block
  (
    .clk                   ( clk_g              ),
    .reset_n               ( reset_n            ),
    .reg_write             ( apbslv_reg_write   ),
    .reg_read              ( apbslv_reg_read    ),
    .reg_addr              ( apbslv_reg_addr    ),
    .reg_wdata             ( apbslv_reg_wdata   ),
    .reg_rdata             ( apbslv_reg_rdata   ),
    .status_spiden         ( spiden             ),
    .status_dbgen          ( dbgen              ),
    .status_axislv_busy    ( axislv_busy        ),
    .status_slw_busy       ( slw_busy           ),
    .status_axi_autherr    ( axislv_axi_autherr ),
    .status_axi_resperr    ( aximstr_resperr    ),
    .status_addrerr        ( slw_addrerr        ),
    .ctrl_enable           ( ctrl_enable        ),
    .ctrl_mode             ( ctrl_mode          ),
    .ctrl_addrerr          ( addrerr            ),
    .ctrl_arcache          ( axictrl_arcache    ),
    .ctrl_arprot           ( axictrl_arprot     ),
    .ctrl_sladdr           ( ctrl_sladdr        ),
    .ctrl_inaddr           ( ctrl_inaddr        ),
    .clr_tlbs              ( clr_tlbs           ),
    .revand                (w_revand            )
  );

  assign slw_addrerr = (wr_oor_va | rd_oor_va);
  assign axislv_axi_autherr = wr_auth_err | rd_auth_err;

  assign translate_awready = (translated_awready & ~invalid_wr)
                           | (ds_bvalid & ds_bready & invalid_wr);
  assign translate_arready = (translated_arready & ~invalid_rd)
                           | (ds_rvalid & ds_rready & ds_rlast & invalid_rd);

  css600_catu_axi_slave_if
  #(
    .ADDR_WIDTH   ( L_AXI_ADDR_WIDTH  ),
    .VA_WIDTH     ( L_VA_WIDTH        ),
    .PS_WIDTH     ( L_PS_WIDTH        ),
    .DATA_WIDTH   ( L_AXI_DATA_WIDTH  ),
    .LEN_WIDTH    ( L_AXI_LEN_WIDTH   ),
    .SIZE_WIDTH   ( L_AXI_SIZE_WIDTH  ),
    .BURST_WIDTH  ( L_AXI_BURST_WIDTH ),
    .CACHE_WIDTH  ( L_AXI_CACHE_WIDTH ),
    .PROT_WIDTH   ( L_PROT_WIDTH      ),
    .RESP_WIDTH   ( L_AXI_RESP_WIDTH  ),
    .WSTRB_WIDTH  ( L_AXI_WSTRB_WIDTH )
  )
  u_css600_catu_axi_slave_if
  (
    .clk                   ( clk_g              ),
    .reset_n               ( reset_n            ),
    .dev_run               ( dev_run            ),
    .araddr_s              ( araddr_s           ),
    .arlen_s               ( arlen_s            ),
    .arsize_s              ( arsize_s           ),
    .arburst_s             ( arburst_s          ),
    .arlock_s              ( arlock_s           ),
    .arcache_s             ( arcache_s          ),
    .arprot_s              ( arprot_s[1:0]      ),
    .arvalid_s             ( arvalid_s          ),
    .arready_s             ( arready_s          ),
    .rdata_s               ( rdata_s            ),
    .rresp_s               ( rresp_s            ),
    .rlast_s               ( rlast_s            ),
    .rvalid_s              ( rvalid_s           ),
    .rready_s              ( rready_s           ),
    .awaddr_s              ( awaddr_s           ),
    .awlen_s               ( awlen_s            ),
    .awsize_s              ( awsize_s           ),
    .awburst_s             ( awburst_s          ),
    .awlock_s              ( awlock_s           ),
    .awcache_s             ( awcache_s          ),
    .awprot_s              ( awprot_s[1:0]      ),
    .awvalid_s             ( awvalid_s          ),
    .awready_s             ( awready_s          ),
    .wdata_s               ( wdata_s            ),
    .wstrb_s               ( wstrb_s            ),
    .wlast_s               ( wlast_s            ),
    .wvalid_s              ( wvalid_s           ),
    .wready_s              ( wready_s           ),
    .bresp_s               ( bresp_s            ),
    .bvalid_s              ( bvalid_s           ),
    .bready_s              ( bready_s           ),
    .axislv_araddr         ( axislv_araddr      ),
    .axislv_arlen          ( axislv_arlen       ),
    .axislv_arsize         ( axislv_arsize      ),
    .axislv_arburst        ( axislv_arburst     ),
    .axislv_arlock         ( axislv_arlock      ),
    .axislv_arcache        ( axislv_arcache     ),
    .axislv_arprot         ( axislv_arprot      ),
    .translate_arvalid     ( translate_arvalid  ),
    .translate_arready     ( translate_arready  ),
    .bypass_arvalid        ( bypass_arvalid     ),
    .bypass_arready        ( bypass_arready     ),
    .ds_arvalid            ( ds_arvalid         ),
    .ds_arready            ( ds_arready         ),
    .int_rdata             ( int_rdata          ),
    .int_rresp             ( int_rresp          ),
    .int_rlast             ( int_rlast          ),
    .int_rvalid            ( axislv_rvalid      ),
    .int_rready            ( axislv_rready      ),
    .ds_rresp              ( ds_rresp           ),
    .ds_rlast              ( ds_rlast           ),
    .ds_rvalid             ( ds_rvalid          ),
    .ds_rready             ( ds_rready          ),
    .axislv_awaddr         ( axislv_awaddr      ),
    .axislv_awlen          ( axislv_awlen       ),
    .axislv_awsize         ( axislv_awsize      ),
    .axislv_awburst        ( axislv_awburst     ),
    .axislv_awlock         ( axislv_awlock      ),
    .axislv_awcache        ( axislv_awcache     ),
    .axislv_awprot         ( axislv_awprot      ),
    .translate_awvalid     ( translate_awvalid  ),
    .translate_awready     ( translate_awready  ),
    .bypass_awvalid        ( bypass_awvalid     ),
    .bypass_awready        ( bypass_awready     ),
    .ds_awvalid            ( ds_awvalid         ),
    .ds_awready            ( ds_awready         ),
    .int_wdata             ( axislv_wdata       ),
    .int_wstrb             ( axislv_wstrb       ),
    .int_wlast             ( axislv_wlast       ),
    .axislv_wvalid         ( axislv_wvalid      ),
    .axislv_wready         ( axislv_wready      ),
    .ds_wvalid             ( ds_wvalid),
    .ds_wready             ( ds_wready),
    .int_bresp             ( axislv_bresp       ),
    .int_bvalid            ( axislv_bvalid      ),
    .int_bready            ( axislv_bready      ),
    .ds_bresp              ( ds_bresp           ),
    .ds_bvalid             ( ds_bvalid          ),
    .ds_bready             ( ds_bready          ),
    .spiden                ( spiden             ),
    .dbgen                 ( dbgen              ),
    .ctrl_enable           ( ctrl_enable        ),
    .ctrl_mode             ( ctrl_mode          ),
    .tlb_initialised       ( tlb_initialised    ),
    .init_slw              ( init_slw           ),
    .init_tlbs             ( init_tlbs          ),
    .rd_ds_select          ( rd_ds_select       ),
    .wr_ds_select          ( wr_ds_select       ),
    .rds_drained           ( rds_drained        ),
    .wrs_drained           ( wrs_drained        ),
    .invalid_wr            ( invalid_wr         ),
    .invalid_rd            ( invalid_rd         ),
    .rd_trans_busy         ( rd_trans_busy      ),
    .wr_trans_busy         ( wr_trans_busy      ),
    .rd_auth_err           ( rd_auth_err        ),
    .wr_auth_err           ( wr_auth_err        ),
    .reg_arvalid           ( reg_arvalid        ),
    .outs_rd_cntr_noteq0   ( outs_rd_cntr_noteq0),
    .reg_awvalid           ( reg_awvalid        ),
    .outs_wr_cntr_noteq0   ( outs_wr_cntr_noteq0),
    .enable_busy           ( enable_busy        ),
    .status_busy           ( axislv_busy        )
  );


  css600_catu_axi_master_if
  #(
    .ADDR_WIDTH   ( L_AXI_ADDR_WIDTH  ),
    .VA_WIDTH     ( L_VA_WIDTH        ),
    .PA_WIDTH     ( L_PA_WIDTH        ),
    .DATA_WIDTH   ( L_AXI_DATA_WIDTH  ),
    .LEN_WIDTH    ( L_AXI_LEN_WIDTH   ),
    .SIZE_WIDTH   ( L_AXI_SIZE_WIDTH  ),
    .BURST_WIDTH  ( L_AXI_BURST_WIDTH ),
    .CACHE_WIDTH  ( L_AXI_CACHE_WIDTH ),
    .PROT_WIDTH   ( L_PROT_WIDTH      ),
    .RESP_WIDTH   ( L_AXI_RESP_WIDTH  ),
    .WSTRB_WIDTH  ( L_AXI_WSTRB_WIDTH )
  )
  u_css600_catu_axi_master_if
  (
    .clk                   ( clk_g        ),
    .reset_n               ( reset_n      ),
    .awakeup_m             ( awakeup_m    ),
    .araddr_m              ( araddr_m     ),
    .arid_m                ( arid_m       ),
    .arlen_m               ( arlen_m      ),
    .arsize_m              ( arsize_m     ),
    .arburst_m             ( arburst_m    ),
    .arlock_m              ( arlock_m     ),
    .arcache_m             ( arcache_m    ),
    .arprot_m              ( arprot_m[1:0]),
    .arvalid_m             ( arvalid_m    ),
    .arready_m             ( arready_m    ),
    .rdata_m               ( rdata_m      ),
    .rresp_m               ( rresp_m      ),
    .rlast_m               ( rlast_m      ),
    .rid_m                 ( rid_m        ),
    .rvalid_m              ( rvalid_m     ),
    .rready_m              ( rready_m     ),
    .awaddr_m              ( awaddr_m     ),
    .awlen_m               ( awlen_m      ),
    .awsize_m              ( awsize_m     ),
    .awburst_m             ( awburst_m    ),
    .awlock_m              ( awlock_m     ),
    .awcache_m             ( awcache_m    ),
    .awprot_m              ( awprot_m[1:0]),
    .awvalid_m             ( awvalid_m    ),
    .awready_m             ( awready_m    ),
    .wdata_m               ( wdata_m      ),
    .wstrb_m               ( wstrb_m      ),
    .wlast_m               ( wlast_m      ),
    .wvalid_m              ( wvalid_m     ),
    .wready_m              ( wready_m     ),
    .bresp_m               ( bresp_m      ),
    .bvalid_m              ( bvalid_m     ),
    .bready_m              ( bready_m     ),
    .axislv_araddr         ( axislv_araddr ),
    .axislv_arlen          ( axislv_arlen  ),
    .axislv_arsize         ( axislv_arsize ),
    .axislv_arburst        ( axislv_arburst),
    .axislv_arlock         ( axislv_arlock ),
    .axislv_arcache        ( axislv_arcache),
    .axislv_arprot         ( axislv_arprot ),
    .bypass_arvalid        ( bypass_arvalid),
    .bypass_arready        ( bypass_arready),
    .int_rdata             ( int_rdata     ),
    .int_rresp             ( int_rresp     ),
    .int_rlast             ( int_rlast     ),
    .axislv_rvalid         ( axislv_rvalid ),
    .axislv_rready         ( axislv_rready ),
    .axislv_awaddr         ( axislv_awaddr ),
    .axislv_awlen          ( axislv_awlen  ),
    .axislv_awsize         ( axislv_awsize ),
    .axislv_awburst        ( axislv_awburst),
    .axislv_awlock         ( axislv_awlock ),
    .axislv_awcache        ( axislv_awcache),
    .axislv_awprot         ( axislv_awprot ),
    .bypass_awvalid        ( bypass_awvalid),
    .bypass_awready        ( bypass_awready),
    .int_wdata             ( axislv_wdata  ),
    .int_wstrb             ( axislv_wstrb  ),
    .int_wlast             ( axislv_wlast  ),
    .int_wvalid            ( axislv_wvalid ),
    .int_wready            ( axislv_wready ),
    .int_bresp             ( axislv_bresp  ),
    .int_bvalid            ( axislv_bvalid ),
    .int_bready            ( axislv_bready ),
    .translated_arvalid    ( translated_arvalid ),
    .translated_arready    ( translated_arready),
    .translated_araddr     ( translated_araddr  ),
    .translated_awvalid    ( translated_awvalid),
    .translated_awready    ( translated_awready),
    .translated_awaddr     ( translated_awaddr  ),
    .slw_arvalid           ( slw_arvalid),
    .slw_arready           ( slw_arready),
    .slw_aid               ( slw_aid),
    .slw_araddr            ( slw_araddr ),
    .slw_arlen             ( slw_arlen ),
    .slw_arsize            ( slw_arsize ),
    .slw_rid               ( slw_rid   ),
    .slw_rvalid            ( slw_rvalid ),
    .slw_rready            ( slw_rready ),
    .slw_rlast             ( slw_rlast ),
    .ctrl_mode             ( ctrl_mode          ),
    .axictrl_arcache       ( axictrl_arcache ),
    .axictrl_arprot        ( axictrl_arprot  ),
    .slw_err               ( slw_err   ),
    .status_resp_err       ( aximstr_resperr   )
  );

  assign awprot_m[2] = 1'b0;
  assign arprot_m[2] = 1'b0;

  assign rd_resperr = slw_rvalid & slw_err & (&slw_rid);
  assign wr_resperr = slw_rvalid & slw_err & (slw_rid[0] & ~slw_rid[1]);

  css600_catu_tlb
  #(
    .DSIZE           ( DSIZE  ),
    .AXI_ADDR_WIDTH  ( L_AXI_ADDR_WIDTH ),
    .VA_WIDTH        ( L_VA_WIDTH      ),
    .PA_WIDTH        ( L_PA_WIDTH      ),
    .PS_WIDTH        ( L_PS_WIDTH      ),
    .TLB_RD_DEPTH    ( TLB_RD_DEPTH    ),
    .TLB_WR_DEPTH    ( TLB_WR_DEPTH    ),
    .INIT_BITS       ( INIT_BITS  )
  )
  u_css600_catu_tlb
  (
    .clk                   ( clk_g ),
    .reset_n               ( reset_n ),
    .ctrl_inaddr           ( ctrl_inaddr ),
    .init_tlbs             ( init_tlbs ),
    .clr_tlbs              ( clr_tlbs ),
    .translate_arvalid     ( translate_arvalid),
    .axislv_araddr         ( axislv_araddr ),
    .translate_awvalid     ( translate_awvalid),
    .axislv_awaddr         ( axislv_awaddr ),
    .translated_awready    ( translated_awready),
    .upd_awaddr_en         ( upd_awaddr_en ),
    .trans_slw_awvalid     ( trans_slw_awvalid ),
    .tlb_rd_result         ( tlb_rd_result ),
    .tlb_wr_result         ( tlb_wr_result ),
    .slw_rd_tlb_valid      ( slw_rd_tlb_valid ),
    .slw_wr_tlb_valid      ( slw_wr_tlb_valid ),
    .slw_wr_tlb_upd        ( slw_wr_tlb_upd ),
    .slw_wr_tlb_inv        ( slw_wr_tlb_inv ),
    .slw_invalid_tlb_pftch ( slw_invalid_tlb_pftch),
    .slw_tlb_data          ( slw_tlb_data ),
    .wr_prefetch           ( wr_prefetch ),
    .wr_pre_addr_inc_ndec  ( wr_pre_addr_inc_ndec ),
    .wr_pre_addr           ( wr_pre_addr )
  );

  css600_catu_translation_ctrl
  #(
    .VA_WIDTH   ( L_VA_WIDTH  ),
    .PA_WIDTH   ( L_PA_WIDTH  ),
    .PS_WIDTH   ( L_PS_WIDTH  ),
    .ADDR_WIDTH   ( L_AXI_ADDR_WIDTH  ),
    .DATA_WIDTH   ( L_AXI_DATA_WIDTH  ),
    .LEN_WIDTH    ( L_AXI_LEN_WIDTH   ),
    .SIZE_WIDTH   ( L_AXI_SIZE_WIDTH  ),
    .BURST_WIDTH  ( L_AXI_BURST_WIDTH ),
    .CACHE_WIDTH  ( L_AXI_CACHE_WIDTH ),
    .PROT_WIDTH   ( L_AXI_PROT_WIDTH  ),
    .RESP_WIDTH   ( L_AXI_RESP_WIDTH  ),
    .WSTRB_WIDTH  ( L_AXI_WSTRB_WIDTH )
  )
  u_css600_catu_rd_translation_ctrl
  (
    .clk                   ( clk_g ),
    .reset_n               ( reset_n ),
    .ctrl_inaddr           ( ctrl_inaddr ),
    .prefetch              ( 1'b0 ),
    .translate_avalid      ( translate_arvalid ),
    .tlb_result            ( tlb_rd_result   ),
    .axislv_addr           ( axislv_araddr ),
    .translated_avalid     ( translated_arvalid),
    .translated_aready     ( translated_arready),
    .translated_addr       ( translated_araddr ),
    .avalid_t              ( arvalid_t),
    .aready_t              ( arready_t),
    .resp_valid_t          ( ds_rvalid & ds_rlast ),
    .resp_ready_t          ( ds_rready ),
    .trans_drained         ( rds_drained ),
    .trans_resperr         ( rd_resperr ),
    .invalid_trans         ( invalid_rd ),
    .trans_busy            ( rd_trans_busy ),
    .oor_va                ( rd_oor_va ),
    .upd_addr_en           ( ),
    .trans_slw_avalid      ( trans_slw_arvalid ),
    .trans_slw_aready      ( trans_slw_arready )

  );

  css600_catu_translation_ctrl
  #(
    .VA_WIDTH   ( L_VA_WIDTH  ),
    .PA_WIDTH   ( L_PA_WIDTH  ),
    .PS_WIDTH   ( L_PS_WIDTH  ),
    .ADDR_WIDTH   ( L_AXI_ADDR_WIDTH  ),
    .DATA_WIDTH   ( L_AXI_DATA_WIDTH  ),
    .LEN_WIDTH    ( L_AXI_LEN_WIDTH   ),
    .SIZE_WIDTH   ( L_AXI_SIZE_WIDTH  ),
    .BURST_WIDTH  ( L_AXI_BURST_WIDTH ),
    .CACHE_WIDTH  ( L_AXI_CACHE_WIDTH ),
    .PROT_WIDTH   ( L_AXI_PROT_WIDTH  ),
    .RESP_WIDTH   ( L_AXI_RESP_WIDTH  ),
    .WSTRB_WIDTH  ( L_AXI_WSTRB_WIDTH )
  )
  u_css600_catu_wr_translation_ctrl
  (
    .clk                   ( clk_g ),
    .reset_n               ( reset_n ),
    .ctrl_inaddr           ( ctrl_inaddr ),
    .prefetch              ( wr_prefetch ),
    .translate_avalid      ( translate_awvalid ),
    .tlb_result            ( tlb_wr_result ),
    .axislv_addr           ( axislv_awaddr ),
    .translated_avalid     ( translated_awvalid ),
    .translated_aready     ( translated_awready ),
    .translated_addr       ( translated_awaddr ),
    .avalid_t              ( awvalid_t ),
    .aready_t              ( awready_t ),
    .resp_valid_t          ( ds_bvalid ),
    .resp_ready_t          ( ds_bready ),
    .trans_drained         ( wrs_drained ),
    .trans_resperr         ( wr_resperr ),
    .invalid_trans         ( invalid_wr ),
    .trans_busy            ( wr_trans_busy ),
    .oor_va                ( wr_oor_va ),
    .upd_addr_en           ( upd_awaddr_en ),
    .trans_slw_avalid      ( trans_slw_awvalid ),
    .trans_slw_aready      ( trans_slw_awready )

  );

  css600_catu_scatter_list_walker
  #(
    .ADDR_WIDTH   ( L_AXI_ADDR_WIDTH  ),
    .VA_WIDTH     ( L_VA_WIDTH  ),
    .PA_WIDTH     ( L_PA_WIDTH  ),
    .DATA_WIDTH   ( L_AXI_DATA_WIDTH  ),
    .DSIZE        ( DSIZE  ),
    .PS_WIDTH     ( L_PS_WIDTH  ),
    .SIZE_WIDTH   ( L_AXI_SIZE_WIDTH  ),
    .TLB_RD_DEPTH ( TLB_RD_DEPTH  ),
    .TLB_WR_DEPTH ( TLB_WR_DEPTH  ),
    .TLB_DEPTH    ( TLB_DEPTH  ),
    .INIT_BITS    ( INIT_BITS  )
  )
  u_css600_catu_scatter_list_walker
  (
    .clk                   ( clk_g                ),
    .reset_n               ( reset_n              ),
    .init_slw              ( init_slw             ),
    .clr_tlbs              ( clr_tlbs             ),
    .tlb_initialised       ( tlb_initialised      ),
    .ctrl_mode             ( ctrl_mode            ),
    .ctrl_sladdr           ( ctrl_sladdr          ),
    .ctrl_inaddr           ( ctrl_inaddr          ),
    .init_tlbs             ( init_tlbs            ),
    .slw_arvalid           ( slw_arvalid          ),
    .slw_arready           ( slw_arready          ),
    .slw_aid               ( slw_aid              ),
    .slw_araddr            ( slw_araddr           ),
    .slw_arlen             ( slw_arlen            ),
    .slw_arsize            ( slw_arsize           ),
    .slw_rid               ( slw_rid              ),
    .slw_rvalid            ( slw_rvalid           ),
    .slw_rready            ( slw_rready           ),
    .slw_rlast             ( slw_rlast            ),
    .int_rdata             ( int_rdata            ),
    .slw_err               ( slw_err              ),
    .slw_rd_tlb_valid      ( slw_rd_tlb_valid     ),
    .slw_wr_tlb_valid      ( slw_wr_tlb_valid     ),
    .slw_wr_tlb_upd        ( slw_wr_tlb_upd       ),
    .slw_wr_tlb_inv        ( slw_wr_tlb_inv       ),
    .slw_tlb_data          ( slw_tlb_data         ),
    .trans_slw_arvalid     ( trans_slw_arvalid    ),
    .trans_slw_arready     ( trans_slw_arready    ),
    .axislv_araddr         ( axislv_araddr        ),
    .trans_slw_awvalid     ( trans_slw_awvalid    ),
    .trans_slw_awready     ( trans_slw_awready    ),
    .wr_prefetch           ( wr_prefetch          ),
    .wr_pre_addr_inc_ndec  ( wr_pre_addr_inc_ndec ),
    .wr_pre_addr           ( wr_pre_addr          ),
    .axislv_awaddr         ( axislv_awaddr        ),
    .fetch_busy            ( fetch_busy           ),
    .w_prefetch            ( w_prefetch           ),
    .slw_busy              ( slw_busy             ),
    .slw_invalid_tlb_pftch (slw_invalid_tlb_pftch )
  );

  css600_catu_ds
  #(
    .LEN_WIDTH    ( L_AXI_LEN_WIDTH   ),
    .RESP_WIDTH   ( L_AXI_RESP_WIDTH  )
  )
  u_css600_catu_ds
  (
    .clk                   ( clk_g ),
    .reset_n               ( reset_n ),
    .rd_ds_select          ( rd_ds_select ),
    .wr_ds_select          ( wr_ds_select ),
    .arlen_s               ( axislv_arlen ),
    .arvalid_s             ( ds_arvalid ),
    .arready_s             ( ds_arready ),
    .rresp_s               ( ds_rresp ),
    .rlast_s               ( ds_rlast ),
    .rvalid_s              ( ds_rvalid ),
    .rready_s              ( ds_rready ),
    .awvalid_s             ( ds_awvalid ),
    .awready_s             ( ds_awready ),
    .wlast_s               ( axislv_wlast ),
    .wvalid_s              ( ds_wvalid ),
    .wready_s              ( ds_wready ),
    .bresp_s               ( ds_bresp ),
    .bvalid_s              ( ds_bvalid ),
    .bready_s              ( ds_bready ),
    .arvalid_t             ( arvalid_t ),
    .arready_t             ( arready_t ),
    .awvalid_t             ( awvalid_t ),
    .awready_t             ( awready_t )

  );


  assign catu_lp_done = catu_lp_request;

  css600_or_tree
  #(
    .NUM_OR_INPUTS (7)
  )
  u_active_or
  (
    .or_inputs({reg_arvalid, outs_rd_cntr_noteq0, reg_awvalid, outs_wr_cntr_noteq0,
                enable_busy, fetch_busy, w_prefetch}),
    .or_output(catu_active)
  );

  css600_or
  u_wake_up_or
  (
    .in_a  ( awakeup_s  ),
    .in_b  ( pwakeup_s ),
    .out_y ( catu_wake_up  )
  );

  assign catu_active_s = catu_active | awvalid_s | arvalid_s | wvalid_s | psel_s;

  css600_lpislave
  u_css600_lpislave
  (
    .clk                   ( clk             ),
    .reset_n               ( reset_n         ),
    .qreq_sync_n           ( clk_qreq_n_sync ),
    .qaccept_n             ( clk_qaccept_n   ),
    .qdeny                 ( clk_qdeny       ),
    .lp_request            ( catu_lp_request ),
    .dev_active            ( catu_active_s   ),
    .lp_done               ( catu_lp_done    ),
    .dev_run               ( dev_run         ),
    .cg_en                 ( int_clk_en      )
  );

    css600_cdc_capt_sync
    #(
      .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
    )
    u_css600_cdc_capt_sync_clk_qreq
    (
      .clk       ( clk             ),
      .reset_n   ( reset_n         ),
      .d_async_i ( clk_qreq_n      ),
      .q_sync_o  ( clk_qreq_n_sync )
    );

  css600_or
  u_qactive_async
  (
    .in_a  ( catu_active  ),
    .in_b  ( catu_wake_up ),
    .out_y ( clk_qactive  )
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));


endmodule

