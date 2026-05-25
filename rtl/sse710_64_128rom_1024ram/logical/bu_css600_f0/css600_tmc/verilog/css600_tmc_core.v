//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_tmc
//
//----------------------------------------------------------------------------


module css600_tmc_core
(
      clk,
      reset_n,
      atwakeup_m,
      atid_m,
      atbytes_m,
      atdata_m,
      atvalid_m,
      atready_m,
      afvalid_m,
      afready_m,
      syncreq_m,
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
      mem_ce_n,
      mem_we_n,
      mem_addr,
      mem_d,
      mem_q,
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
      twakeup_m,
      tdata_m,
      tvalid_m,
      tready_m,
      tlast_m,
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
      dftcgen,
      revand
);


`include "css600_tmc_localparams.v"
`include "css600_tmc_functions.v"


  parameter TMC_CONFIG     = 0;
  parameter WBUFFER_DEPTH  = (TMC_CONFIG == ETR) ? 4 : 1;
  parameter MEM_SIZE       = 31'h0000_0080;
  parameter ATB_DATA_WIDTH = 32;
  parameter AXI_ADDR_WIDTH = 40;
  parameter FF_SYNC_DEPTH  = 2;


  parameter ATBYTES_WIDTH  = (ATB_DATA_WIDTH == 8) ? 1 : tmc_clog2(ATB_DATA_WIDTH/8);

  parameter AXI_DATA_WIDTH = ATB_DATA_WIDTH;

  parameter MEM_DATA_WIDTH = (2*ATB_DATA_WIDTH);

  parameter MEM_ADDR_WIDTH = ((TMC_CONFIG == ETB) ||
                              (TMC_CONFIG == ETF)) ?  tmc_clog2(4*({1'b0,MEM_SIZE}/(MEM_DATA_WIDTH/8))) :
                                                     (AXI_ADDR_WIDTH - tmc_clog2(AXI_DATA_WIDTH/8));


  input  wire                          clk;
  input  wire                          reset_n;

  output wire                          atwakeup_m;
  output wire [6:0]                    atid_m;
  output wire [ATBYTES_WIDTH-1:0]      atbytes_m;
  output wire [ATB_DATA_WIDTH-1:0]     atdata_m;
  output wire                          atvalid_m;
  input  wire                          atready_m;
  input  wire                          afvalid_m;
  output wire                          afready_m;
  input  wire                          syncreq_m;

  input  wire                          atwakeup_s;
  input  wire [6:0]                    atid_s;
  input  wire [ATBYTES_WIDTH-1:0]      atbytes_s;
  input  wire [ATB_DATA_WIDTH-1:0]     atdata_s;
  input  wire                          atvalid_s;
  output wire                          atready_s;
  output wire                          afvalid_s;
  input  wire                          afready_s;
  output wire                          syncreq_s;

  input  wire                          pwakeup_s;
  input  wire                          psel_s;
  input  wire                          penable_s;
  input  wire                          pwrite_s;
  input  wire [11:0]                   paddr_s;
  input  wire [31:0]                   pwdata_s;
  output wire                          pready_s;
  output wire                          pslverr_s;
  output wire [31:0]                   prdata_s;

  output wire                          mem_ce_n;
  output wire                          mem_we_n;
  output wire [MEM_ADDR_WIDTH-1:0]     mem_addr;
  output wire [MEM_DATA_WIDTH-1:0]     mem_d;
  input  wire [MEM_DATA_WIDTH-1:0]     mem_q;

  output wire                          awakeup_m;
  output wire [AXI_ADDR_WIDTH-1:0]     araddr_m;
  output wire [7:0]                    arlen_m;
  output wire [2:0]                    arsize_m;
  output wire [1:0]                    arburst_m;
  output wire                          arlock_m;
  output wire [3:0]                    arcache_m;
  output wire [2:0]                    arprot_m;
  output wire                          arvalid_m;
  input  wire                          arready_m;
  input  wire [AXI_DATA_WIDTH-1:0]     rdata_m;
  input  wire [1:0]                    rresp_m;
  input  wire                          rlast_m;
  input  wire                          rvalid_m;
  output wire                          rready_m;
  output wire [AXI_ADDR_WIDTH-1:0]     awaddr_m;
  output wire [7:0]                    awlen_m;
  output wire [2:0]                    awsize_m;
  output wire [1:0]                    awburst_m;
  output wire                          awlock_m;
  output wire [3:0]                    awcache_m;
  output wire [2:0]                    awprot_m;
  output wire                          awvalid_m;
  input  wire                          awready_m;
  output wire [AXI_DATA_WIDTH-1:0]     wdata_m;
  output wire [(AXI_DATA_WIDTH/8)-1:0] wstrb_m;
  output wire                          wlast_m;
  output wire                          wvalid_m;
  input  wire                          wready_m;
  input  wire [1:0]                    bresp_m;
  input  wire                          bvalid_m;
  output wire                          bready_m;

  output wire                          twakeup_m;
  output wire [ATB_DATA_WIDTH-1:0]     tdata_m;
  output wire                          tvalid_m;
  input  wire                          tready_m;
  output wire                          tlast_m;

  input  wire                          dbgen;
  input  wire                          spiden;

  input  wire                          clk_qreq_n;
  output wire                          clk_qaccept_n;
  output wire                          clk_qdeny;
  output wire                          clk_qactive;

  input  wire                          trigin;
  input  wire                          flushin;
  output wire                          full;
  output wire                          acqcomp;
  output wire                          flushcomp;

  output wire                          bufintr;

  input  wire                          dftcgen;

  input  wire [3:0]                    revand;


  localparam MEM_BYTE_ADDR_WIDTH = (TMC_CONFIG == ETR) ? AXI_ADDR_WIDTH
                                                       : tmc_clog2({1'b0,MEM_SIZE}) + 2;

  localparam WB_DATA_WIDTH = ((TMC_CONFIG == ETR) ||
                              (TMC_CONFIG == ETS)) ? ATB_DATA_WIDTH : MEM_DATA_WIDTH;

  localparam WB_PTR_WIDTH = (WBUFFER_DEPTH == 1) ? 1 : tmc_clog2(WBUFFER_DEPTH);

  localparam TMC_TRG_WIDTH = ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS)) ? 32 : tmc_clog2({1'b0,MEM_SIZE});

  localparam ITATBDATA0_WIDTH = (ATB_DATA_WIDTH == 32) ? 5 :
                                (ATB_DATA_WIDTH == 64) ? 9 : 17;

  localparam FILL_LEVEL_WIDTH = (TMC_CONFIG == ETR) ? 31 : tmc_clog2({1'b0,MEM_SIZE}) + 1;


  wire                                   ffcr_flush_man;
  wire                                   ctl_trace_capt_en/*verilator clock_enable*/;
  wire                                   ctl_trace_capt_en_rise;
  wire                                   ft_running;
  wire                                   tmc_enabled;
  wire                                   apb_read_fifo_rrp_en;
  wire                                   unformatter_en;
  wire                                   unformatter_stop;
  wire                                   tmc_ready;
  wire                                   nxt_tmc_enabled;
  wire                                   ctl_trace_capt_en_rise_pre;
  wire                                   apbreadfifo_clr;
  wire                                   flush_man_clr;
  wire                                   trace_mem_empty;
  wire                                   sts_full;
  wire                                   sts_triggered;
  wire [31:0]                            rrd_rd_data;
  wire                                   rrd_rd_ack;
  wire [MEM_BYTE_ADDR_WIDTH-1:0]         rrp;
  wire [MEM_BYTE_ADDR_WIDTH-1:0]         rwp;
  wire                                   unformatter_empty;
  wire                                   l_buf_level_rd_done;
  wire [FILL_LEVEL_WIDTH-1:0]            l_buf_level;
  wire [FILL_LEVEL_WIDTH-1:0]            c_buf_level;
  wire                                   mem_err;
  wire                                   mem_err_clr;
  wire [30:0]                            rsz;
  wire                                   axi_intf_ready;
  wire                                   read_in_prog;
  wire [5:0]                             outstanding_wreq_cnt_p;
  wire                                   ft_stop_req;
  wire                                   ft_trig_req;
  wire                                   trg_zero;
  wire                               nxt_trg_evt_active;
  wire                                   ft_retrig_req;
  wire                                   atbs_flush_done;
  wire                                   nxt_flush_wait;
  wire                                   flush_wait;
  wire                                   hold_trig_req;
  wire                                   ft_flid_req;
  wire                               nxt_stop_pending;
  wire                                   stop_pending;
  wire                                   st_trig_pend;
  wire                                   ft_trig_pend;
  wire                                   st_fl_pend;
  wire                               nxt_t_on_trig_in_pend;
  wire                                   t_on_trig_in_pend;
  wire                                   itctrl_ime/*verilator clock_enable*/;
  wire                                   integ_mode_entry;
  wire                                   ft_data_valid;
  wire                                   ft_trig_ack;
  wire                                   ft_flid_ack;
  wire                                   trigin_rise;
  wire                                   trig_pkt_wait;
  wire                               nxt_trig_in_wait;
  wire                                   trig_in_wait;
  wire                                   trig_pkt_wait_done;
  wire                                   trig_in_wait_done;
  wire [1:0]                             ft_trig_size;
  wire [ATB_DATA_WIDTH-1:0]              ft_data;
  wire                                   rb_req_ready;
  wire                                   rb_rdata_valid;
  wire                                   rrd_rd_req;
  wire                                   rb_req_valid;
  wire [WB_DATA_WIDTH-1:0]               rb_data;
  wire                                   wb_req_ready;
  wire                                   wb_req_valid;
  wire                                   wb_ready;
  wire                                   sts_full_wr_en;
  wire                                   rurp_wr_en;
  wire                                   rrp_wr_en;
  wire                                   rwp_wr_en;
  wire                                   unprog_sts;
  wire                                   unprog_rrp;
  wire                                   unprog_rwp;
  wire                                   unprog_trg;
  wire                                   unprog_rrphi;
  wire                                   unprog_rwphi;
  wire                                   ptr_prog;
  wire                                   circ_buf_mode;
  wire                                   sw_fifo_mode2;
  wire                                   hw_fifo_mode;
  wire                                   stall_on_stop;
  wire                                   trg_wr_en;
  wire                                   ft_stopped;
  wire                                   ft_stopped_q2;
  wire [WB_DATA_WIDTH-1:0]               wb_data;
  wire [TMC_TRG_WIDTH-1:0]               trg;
  wire                                   nxt_wb_ready;
  wire [31:0]                            rwd_wr_data;
  wire                                   rwd_wr_req;
  wire                                   it_atb_ctr_2_wr_en;
  wire                                   it_atb_m_ctr_0_wr_en;
  wire                                   it_tr_fl_in_rd_en;
  wire [FILL_LEVEL_WIDTH-2:0]            buf_wm;
  wire [3:0]                             wr_burst_len;
  wire [ITATBDATA0_WIDTH-1:0]            it_atb_data_0;
  wire                                   it_evt_intr_wr_en;
  wire                                   it_atb_m_data_0_wr_en;
  wire                                   it_atb_m_ctr_1_wr_en;
  wire                                   rrp_hi_wr_en;
  wire                                   rwp_hi_wr_en;
  wire                                   trigin_q;
  wire                                   flushin_q;
  wire                                   it_trigin;
  wire                                   it_flushin;
  wire [3:0]                             axictl_wcache;
  wire [3:0]                             axictl_rcache;
  wire [1:0]                             axictl_prot_ctrl;
  wire [MEM_BYTE_ADDR_WIDTH-1:0]         dba;
  wire                                   pscr_embed_sync;
  wire [4:0]                             pscr_pscount;
  wire                                   frame_sync_req;
  wire                                   ft_fifo_beat;
  wire                                   wb_empty;
  wire                                   tmc_abort;
  wire [6:0]                             it_atids;
  wire                                   it_atvalids;
  wire [ATBYTES_WIDTH-1:0]               it_atbytess;
  wire                                   it_atwakeups;
  wire                                   it_afreadys;
  wire [31:0]                            apb_wdata_p;
  wire                                   ffcr_drain_buffer_en;
  wire                                   ffcr_embed_flush_masked;
  wire                                   ffcr_stop_on_trig_evt_masked;
  wire                                   ffcr_stop_on_fl;
  wire                                   ffcr_trig_on_fl_masked;
  wire                                   ffcr_trig_on_trig_evt_masked;
  wire                                   ffcr_trig_on_trigin_masked;
  wire                                   ffcr_flsh_on_trig_evt_masked;
  wire                                   ffcr_flsh_on_flshin;
  wire                                   ffcr_en_trig_ins;
  wire                                   ffcr_en_formatting_masked;
  wire                                   ft_flush_ack;
  wire                                   wb_flush_ack;
  wire                                   mem_flush_ack;
  wire                                   nxt_afreadym;
  wire                                   atbm_flush_valid;
  wire                                   ft_flush_req;
  wire                                   wb_flush_req;
  wire                                   mem_flush_req;
  wire                                   atbm_flush_ready;
  wire                                   flush_fsm_busy;
  wire                                   pscr_ctr_decr_pulse;
  wire                                   trg_ctr_decr_pulse;
  wire [ATBYTES_WIDTH:0]                 trg_ctr_decr_val;
  wire                                   trg_ctr_decr_fcb;
  wire [WB_PTR_WIDTH:0]                  wb_fill_level;
  wire [WB_PTR_WIDTH:0]                  wb_flush_cnt;
  wire                                   wb_flush_req_det;
  wire                                   clk_g;
  wire                                   clk_r;
  wire                                   int_clk_en/*verilator clock_enable*/;
  wire                                   cg_en/*verilator clock_enable*/;
  wire                                   mem_wr;
  wire                                   dbgen_q;
  wire                                   spiden_q;
  wire                                   trigin_mon;
  wire                                   flushin_mon;
  wire                                   trig_flush_wake;
  wire                                   atbm_flush_mon;
  wire                                   dev_active;
  wire                                   lp_request;
  wire                                   lp_done;
  wire                                   dev_run;
  wire                                   clk_qreq_n_sync;


  css600_clk_gate
    u_css600_tmc_clk_gate_run
    (
      .clk_i                           (clk_g),
      .clk_enable_i                    (cg_en|1'b0),
      .clk_o                           (clk_r),
      .dftcgen                         (dftcgen)
    );

  css600_clk_gate
    u_css600_tmc_clk_gate
    (
      .clk_i                           (clk),
      .clk_enable_i                    (int_clk_en),
      .clk_o                           (clk_g),
      .dftcgen                         (dftcgen)
    );

  css600_tmc_regfile
  #(
    .TMC_CONFIG                    (TMC_CONFIG),
    .MEM_SIZE                      (MEM_SIZE),
    .WBUFFER_DEPTH                 (WBUFFER_DEPTH),
    .WB_DATA_WIDTH                 (WB_DATA_WIDTH),
    .ATB_DATA_WIDTH                (ATB_DATA_WIDTH),
    .AXI_ADDR_WIDTH                (AXI_ADDR_WIDTH),
    .MEM_ADDR_WIDTH                (MEM_ADDR_WIDTH),
    .MEM_BYTE_ADDR_WIDTH           (MEM_BYTE_ADDR_WIDTH),
    .TMC_TRG_WIDTH                 (TMC_TRG_WIDTH),
    .ATBYTES_WIDTH                 (ATBYTES_WIDTH),
    .ITATBDATA0_WIDTH              (ITATBDATA0_WIDTH),
    .FILL_LEVEL_WIDTH              (FILL_LEVEL_WIDTH)
  )
  u_css600_tmc_regfile
  (
      .clk                           (clk_r),
      .cg_en                         (cg_en),
      .reset_n                       (reset_n),
      .psel_s                        (psel_s),
      .penable_s                     (penable_s),
      .paddr_s                       (paddr_s),
      .pwrite_s                      (pwrite_s),
      .pwdata_s                      (pwdata_s),
      .prdata_s                      (prdata_s),
      .pready_s                      (pready_s),
      .pslverr_s                     (pslverr_s),
      .dbgen                         (dbgen),
      .spiden                        (spiden),
      .dbgen_q                       (dbgen_q),
      .spiden_q                      (spiden_q),
      .rsz                           (rsz),
      .ctl_trace_capt_en             (ctl_trace_capt_en),
      .tmc_ready                     (tmc_ready),
      .circ_buf_mode                 (circ_buf_mode),
      .hw_fifo_mode                  (hw_fifo_mode),
      .sw_fifo_mode2                 (sw_fifo_mode2),
      .stall_on_stop                 (stall_on_stop),
      .buf_wm                        (buf_wm),
      .wr_burst_len                  (wr_burst_len),
      .axictl_wcache                 (axictl_wcache),
      .axictl_rcache                 (axictl_rcache),
      .axictl_prot_ctrl              (axictl_prot_ctrl),
      .dba                           (dba),
      .ffcr_drain_buffer_en          (ffcr_drain_buffer_en),
      .ffcr_embed_flush_masked       (ffcr_embed_flush_masked),
      .ffcr_stop_on_trig_evt_masked  (ffcr_stop_on_trig_evt_masked),
      .ffcr_stop_on_fl               (ffcr_stop_on_fl),
      .ffcr_trig_on_fl_masked        (ffcr_trig_on_fl_masked),
      .ffcr_trig_on_trig_evt_masked  (ffcr_trig_on_trig_evt_masked),
      .ffcr_trig_on_trigin_masked    (ffcr_trig_on_trigin_masked),
      .ffcr_flush_man                (ffcr_flush_man),
      .ffcr_flsh_on_trig_evt_masked  (ffcr_flsh_on_trig_evt_masked),
      .ffcr_flsh_on_flshin           (ffcr_flsh_on_flshin),
      .ffcr_en_trig_ins              (ffcr_en_trig_ins),
      .ffcr_en_formatting_masked     (ffcr_en_formatting_masked),
      .pscr_embed_sync               (pscr_embed_sync),
      .pscr_pscount                  (pscr_pscount),
      .sts_full_wr_en                (sts_full_wr_en),
      .rrp_wr_en                     (rrp_wr_en),
      .rwp_wr_en                     (rwp_wr_en),
      .trg_wr_en                     (trg_wr_en),
      .rrp_hi_wr_en                  (rrp_hi_wr_en),
      .rwp_hi_wr_en                  (rwp_hi_wr_en),
      .rurp_wr_en                    (rurp_wr_en),
      .apb_wdata_p                   (apb_wdata_p),
      .unprog_sts                    (unprog_sts),
      .unprog_rrp                    (unprog_rrp),
      .unprog_rwp                    (unprog_rwp),
      .unprog_trg                    (unprog_trg),
      .unprog_rrphi                  (unprog_rrphi),
      .unprog_rwphi                  (unprog_rwphi),
      .ptr_prog                      (ptr_prog),
      .mem_err                       (mem_err),
      .sts_triggered                 (sts_triggered),
      .trace_mem_empty               (trace_mem_empty),
      .sts_full                      (sts_full),
      .rrp                           (rrp),
      .rwp                           (rwp),
      .trg                           (trg),
      .l_buf_level                   (l_buf_level),
      .c_buf_level                   (c_buf_level),
      .ft_stopped                    (ft_stopped),
      .flush_fsm_busy                (flush_fsm_busy),
      .itctrl_ime                    (itctrl_ime),
      .integ_mode_entry              (integ_mode_entry),
      .it_atb_m_data_0_wr_en         (it_atb_m_data_0_wr_en),
      .it_atb_m_ctr_1_wr_en          (it_atb_m_ctr_1_wr_en),
      .it_atb_m_ctr_0_wr_en          (it_atb_m_ctr_0_wr_en),
      .it_evt_intr_wr_en             (it_evt_intr_wr_en),
      .it_tr_fl_in_rd_en             (it_tr_fl_in_rd_en),
      .it_atb_ctr_2_wr_en            (it_atb_ctr_2_wr_en),
      .syncreq_m                     (syncreq_m),
      .afvalid_m                     (afvalid_m),
      .atready_m                     (atready_m),
      .it_trigin                     (it_trigin),
      .it_flushin                    (it_flushin),
      .it_atb_data_0                 (it_atb_data_0),
      .it_atids                      (it_atids),
      .it_atbytess                   (it_atbytess),
      .it_atwakeups                  (it_atwakeups),
      .it_afreadys                   (it_afreadys),
      .it_atvalids                   (it_atvalids),
      .rrd_rd_req                    (rrd_rd_req),
      .rrd_rd_ack                    (rrd_rd_ack),
      .rrd_rd_data                   (rrd_rd_data),
      .rwd_wr_req                    (rwd_wr_req),
      .rwd_wr_data                   (rwd_wr_data),
      .wb_ready                      (wb_ready),
      .ctl_trace_capt_en_rise        (ctl_trace_capt_en_rise),
      .ctl_trace_capt_en_rise_pre    (ctl_trace_capt_en_rise_pre),
      .nxt_tmc_enabled               (nxt_tmc_enabled),
      .tmc_enabled                   (tmc_enabled),
      .tmc_abort                     (tmc_abort),
      .unformatter_en                (unformatter_en),
      .unformatter_stop              (unformatter_stop),
      .atbm_flush_mon                (atbm_flush_mon),
      .acqcomp                       (acqcomp),
      .l_buf_level_rd_done           (l_buf_level_rd_done),
      .apbreadfifo_clr               (apbreadfifo_clr),
      .mem_err_clr                   (mem_err_clr),
      .flush_man_clr                 (flush_man_clr),
      .wb_empty                      (wb_empty),
      .unformatter_empty             (unformatter_empty),
      .axi_intf_ready                (axi_intf_ready),
      .flushcomp                     (flushcomp),
      .nxt_afreadym                  (nxt_afreadym),
      .afready_m                     (afready_m),
      .dev_run                       (dev_run),
      .lp_done                       (lp_done),
      .int_clk_en                    (int_clk_en),
      .revand                        (revand)
  );

  assign it_afreadys  = afready_s;
  assign it_atwakeups = atwakeup_s;


  generate
    if (TMC_CONFIG != ETS)
    begin : u_css600_tmc_wrbuffer_block
      css600_tmc_wrbuffer
      #(
        .TMC_CONFIG                    (TMC_CONFIG),
        .ATB_DATA_WIDTH                (ATB_DATA_WIDTH),
        .WBUFFER_DEPTH                 (WBUFFER_DEPTH),
        .WB_PTR_WIDTH                  (WB_PTR_WIDTH),
        .WB_DATA_WIDTH                 (WB_DATA_WIDTH)
      )
      u_css600_tmc_wrbuffer
      (
        .clk                           (clk_r),
        .cg_en                         (cg_en),
        .reset_n                       (reset_n),
        .ctl_trace_capt_en_rise        (ctl_trace_capt_en_rise),
        .tmc_enabled                   (tmc_enabled),
        .wb_flush_req                  (wb_flush_req),
        .wb_flush_ack                  (wb_flush_ack),
        .ft_data                       (ft_data),
        .ft_data_valid                 (ft_data_valid),
        .nxt_wb_ready                  (nxt_wb_ready),
        .wb_ready                      (wb_ready),
        .rwd_wr_data                   (rwd_wr_data),
        .rwd_wr_req                    (rwd_wr_req),
        .wb_req_valid                  (wb_req_valid),
        .wb_req_ready                  (wb_req_ready),
        .wb_data                       (wb_data),
        .wb_empty                      (wb_empty),
        .wb_fill_level                 (wb_fill_level),
        .wb_flush_cnt                  (wb_flush_cnt),
        .wb_flush_req_det              (wb_flush_req_det)
      );
    end
  endgenerate


  generate
    if (TMC_CONFIG == ETS)
      begin : u_css600_tmc_axi_strm_block
        wire [3:0] apb_wdata_p_bits3to0;
        css600_tmc_axi_strm
        #(
          .ATB_DATA_WIDTH (ATB_DATA_WIDTH)
        )
        u_css600_tmc_axi_strm
        (
          .clk                 (clk_r),
          .cg_en               (cg_en),
          .reset_n             (reset_n),
          .dev_run             (dev_run),
          .lp_done             (lp_done),
          .tdata_m             (tdata_m),
          .tlast_m             (tlast_m),
          .tvalid_m            (tvalid_m),
          .tready_m            (tready_m),
          .ft_data             (ft_data),
          .ft_data_valid       (ft_data_valid),
          .wb_ready            (wb_ready),
          .nxt_wb_ready        (nxt_wb_ready),
          .nxt_tmc_enabled     (nxt_tmc_enabled),
          .sts_full_wr_en      (sts_full_wr_en),
          .apb_wdata_p_bits3to0(apb_wdata_p_bits3to0),
          .unprog_sts          (unprog_sts),
          .trace_mem_empty     (trace_mem_empty),
          .sts_full            (sts_full),
          .wb_flush_req        (wb_flush_req),
          .wb_flush_ack        (wb_flush_ack),
          .full                (full),
          .bufintr             (bufintr),
          .itctrl_ime          (itctrl_ime),
          .it_evt_intr_wr_en   (it_evt_intr_wr_en),
          .wb_empty            (wb_empty)
        );

        assign apb_wdata_p_bits3to0 = apb_wdata_p[3:0];

        assign mem_flush_ack = 1'b1;

        assign rrd_rd_ack      = 1'b0;
        assign rrd_rd_data     = 32'h0;

        assign rrp         = {MEM_BYTE_ADDR_WIDTH{1'b0}};
        assign rwp         = {MEM_BYTE_ADDR_WIDTH{1'b0}};
        assign l_buf_level = {FILL_LEVEL_WIDTH{1'b0}};
        assign c_buf_level = {FILL_LEVEL_WIDTH{1'b0}};
        assign twakeup_m   = tvalid_m;
      end
    else
      begin : dont_gen_axi_strm
        assign tdata_m   = {ATB_DATA_WIDTH{1'b0}};
        assign tvalid_m  = 1'b0;
        assign tlast_m   = 1'b0;
        assign twakeup_m = 1'b0;
      end
  endgenerate


  css600_trace_formatter
  #(
    .FORMATTER_CONFIG              (TMC_CONFIG),
    .ATB_DATA_WIDTH                (ATB_DATA_WIDTH),
    .ATBYTES_WIDTH                 (ATBYTES_WIDTH),
    .ITATBDATA0_WIDTH              (ITATBDATA0_WIDTH)
  )
  u_css600_trace_formatter
  (
      .clk                           (clk_r),
      .cg_en                         (cg_en),
      .clk_g                         (clk_g),
      .reset_n                       (reset_n),
      .atid_s                        (atid_s),
      .atbytes_s                     (atbytes_s),
      .atdata_s                      (atdata_s),
      .atvalid_s                     (atvalid_s),
      .atready_s                     (atready_s),
      .ffcr_en_formatting_masked     (ffcr_en_formatting_masked),
      .ffcr_trig_on_trig_evt_masked  (ffcr_trig_on_trig_evt_masked),
      .ffcr_trig_on_trigin_masked    (ffcr_trig_on_trigin_masked),
      .ffcr_flsh_on_trig_evt_masked  (ffcr_flsh_on_trig_evt_masked),
      .hw_fifo_mode                  (hw_fifo_mode),
      .stall_on_stop                 (stall_on_stop),
      .sts_triggered_clr             (ctl_trace_capt_en_rise),
      .ctl_trace_capt_en_rise        (ctl_trace_capt_en_rise),
      .frame_sync_req                (frame_sync_req),
      .trigin_rise                   (trigin_rise),
      .trig_pkt_wait                 (trig_pkt_wait),
      .nxt_trig_in_wait              (nxt_trig_in_wait),
      .trig_in_wait                  (trig_in_wait),
      .trig_pkt_wait_done            (trig_pkt_wait_done),
      .trig_in_wait_done             (trig_in_wait_done),
      .trg_ctr_decr_pulse            (trg_ctr_decr_pulse),
      .trg_ctr_decr_val              (trg_ctr_decr_val),
      .trg_ctr_decr_fcb              (trg_ctr_decr_fcb),
      .ft_running                    (ft_running),
      .ft_stopped_q2                 (ft_stopped_q2),
      .ft_starting                   (),
      .ft_stopped_done               (),
      .ft_fifo_beat                  (ft_fifo_beat),
      .trig_port_en                  (1'b0),
      .trig_port_cdc_t               (),
      .trig_port_done_sync           (1'b0),
      .trg_zero                      (trg_zero),
      .nxt_trg_evt_active            (nxt_trg_evt_active),
      .ft_retrig_req                 (ft_retrig_req),
      .ft_trig_req                   (ft_trig_req),
      .ft_trig_size                  (ft_trig_size),
      .ft_flush_req                  (ft_flush_req),
      .ft_flid_req                   (ft_flid_req),
      .ft_stop_req                   (ft_stop_req),
      .ft_trig_ack                   (ft_trig_ack),
      .ft_flush_ack                  (ft_flush_ack),
      .ft_flid_ack                   (ft_flid_ack),
      .ft_stopped                    (ft_stopped),
      .nxt_stop_pending              (nxt_stop_pending),
      .stop_pending                  (stop_pending),
      .st_fl_pend                    (st_fl_pend),
      .st_trig_pend                  (st_trig_pend),
      .ft_trig_pend                  (ft_trig_pend),
      .nxt_t_on_trig_in_pend         (nxt_t_on_trig_in_pend),
      .t_on_trig_in_pend             (t_on_trig_in_pend),
      .atbs_flush_done               (atbs_flush_done),
      .nxt_flush_wait                (nxt_flush_wait),
      .flush_wait                    (flush_wait),
      .hold_trig_req                 (hold_trig_req),
      .ft_data                       (ft_data),
      .ft_data_beacon                (),
      .ft_data_padded                (),
      .ft_data_valid                 (ft_data_valid),
      .wb_ready                      (wb_ready),
      .nxt_wb_ready                  (nxt_wb_ready),
      .itctrl_ime                    (itctrl_ime),
      .integ_mode_entry              (integ_mode_entry),
      .it_atb_ctr_2_wr_en            (it_atb_ctr_2_wr_en),
      .it_atb_ctr_2_wdata            (apb_wdata_p[0]),
      .it_atb_data_0                 (it_atb_data_0),
      .it_atids                      (it_atids),
      .it_atvalids                   (it_atvalids),
      .it_atbytess                   (it_atbytess),
      .dev_run                       (dev_run)
  );


  css600_trace_format_control
  #(
    .FORMATTER_CONFIG              (TMC_CONFIG),
    .FORMATTER_TRG_WIDTH           (TMC_TRG_WIDTH),
    .ATB_DATA_WIDTH                (ATB_DATA_WIDTH),
    .ATBYTES_WIDTH                 (ATBYTES_WIDTH)
  )
  u_css600_trace_format_control
  (
      .clk                              (clk_r),
      .cg_en                            (cg_en),
      .clk_g                            (clk_g),
      .reset_n                          (reset_n),
      .dev_run                          (dev_run),
      .ctl_trace_capt_en                (ctl_trace_capt_en),
      .ctl_trace_capt_en_rise           (ctl_trace_capt_en_rise),
      .circ_buf_mode                    (circ_buf_mode),
      .hw_fifo_mode                     (hw_fifo_mode),
      .ffcr_embed_flush_masked          (ffcr_embed_flush_masked),
      .ffcr_stop_on_trig_evt_masked     (ffcr_stop_on_trig_evt_masked),
      .ffcr_stop_on_trig_evt_masked_clr (ctl_trace_capt_en_rise),
      .ffcr_stop_on_fl                  (ffcr_stop_on_fl),
      .ffcr_stop_on_fl_clr              (ctl_trace_capt_en_rise),
      .ffcr_trig_on_fl_masked           (ffcr_trig_on_fl_masked),
      .ffcr_trig_on_trig_evt_masked     (ffcr_trig_on_trig_evt_masked),
      .ffcr_trig_on_trigin_masked       (ffcr_trig_on_trigin_masked),
      .ffcr_flsh_on_trig_evt_masked     (ffcr_flsh_on_trig_evt_masked),
      .ffcr_flsh_on_flshin              (ffcr_flsh_on_flshin),
      .ffcr_flush_man                   (ffcr_flush_man),
      .ffcr_en_trig_ins                 (ffcr_en_trig_ins),
      .ffcr_en_formatting_masked        (ffcr_en_formatting_masked),
      .trg_wr_en                        (trg_wr_en),
      .trg_wdata                        ({apb_wdata_p[TMC_TRG_WIDTH-1:2],2'b0}),
      .unprog_trg                       (unprog_trg),
      .trg                              (trg),
      .trg_done                         (),
      .sts_running                      (),
      .sts_triggered                    (sts_triggered),
      .sts_triggered_clr                (ctl_trace_capt_en_rise),
      .trigin                           (trigin),
      .flushin                          (flushin),
      .flushcomp                        (flushcomp),
      .trig_port_en                     (1'b0),
      .trg_zero                         (trg_zero),
      .nxt_trg_evt_active               (nxt_trg_evt_active),
      .ft_retrig_req                    (ft_retrig_req),
      .ft_trig_req                      (ft_trig_req),
      .ft_trig_size                     (ft_trig_size),
      .ft_flush_req                     (ft_flush_req),
      .ft_flid_req                      (ft_flid_req),
      .ft_stop_req                      (ft_stop_req),
      .ft_trig_ack                      (ft_trig_ack),
      .ft_flush_ack                     (ft_flush_ack),
      .ft_flid_ack                      (ft_flid_ack),
      .ft_stopped                       (ft_stopped),
      .nxt_stop_pending                 (nxt_stop_pending),
      .stop_pending                     (stop_pending),
      .st_on_trig_active                (),
      .st_on_fl_active                  (),
      .st_trig_pend                     (st_trig_pend),
      .ft_trig_pend                     (ft_trig_pend),
      .st_fl_pend                       (st_fl_pend),
      .nxt_t_on_trig_in_pend            (nxt_t_on_trig_in_pend),
      .t_on_trig_in_pend                (t_on_trig_in_pend),
      .atbs_flush_done                  (atbs_flush_done),
      .nxt_flush_wait                   (nxt_flush_wait),
      .flush_wait                       (flush_wait),
      .hold_trig_req                    (hold_trig_req),
      .atready_s                        (atready_s),
      .afvalid_s                        (afvalid_s),
      .afready_s                        (afready_s),
      .nxt_wb_flush_req                 (),
      .wb_flush_req                     (wb_flush_req),
      .wb_flush_ack                     (wb_flush_ack),
      .mem_flush_req                    (mem_flush_req),
      .mem_flush_ack                    (mem_flush_ack),
      .atbm_flush_valid                 (atbm_flush_valid),
      .atbm_flush_ready                 (atbm_flush_ready),
      .itctrl_ime                       (itctrl_ime),
      .it_evt_intr_wr_en                (it_evt_intr_wr_en),
      .it_evt_intr_wdata                (apb_wdata_p[2]),
      .it_tr_fl_in_rd_en                (it_tr_fl_in_rd_en),
      .it_atb_ctr_2_wr_en               (it_atb_ctr_2_wr_en),
      .it_atb_ctr_2_wdata               (apb_wdata_p[1]),
      .it_trigin                        (it_trigin),
      .it_flushin                       (it_flushin),
      .trigin_q                         (trigin_q),
      .flushin_q                        (flushin_q),
      .trigin_mon                       (trigin_mon),
      .flushin_mon                      (flushin_mon),
      .trigin_rise                      (trigin_rise),
      .trig_pkt_wait                    (trig_pkt_wait),
      .nxt_trig_in_wait                 (nxt_trig_in_wait),
      .trig_in_wait                     (trig_in_wait),
      .trig_pkt_wait_done               (trig_pkt_wait_done),
      .trig_in_wait_done                (trig_in_wait_done),
      .trg_ctr_decr_pulse               (trg_ctr_decr_pulse),
      .trg_ctr_decr_val                 (trg_ctr_decr_val),
      .trg_ctr_decr_fcb                 (trg_ctr_decr_fcb),
      .trace_mem_empty                  (trace_mem_empty),
      .flush_man_clr                    (flush_man_clr),
      .flush_fsm_busy                   (flush_fsm_busy),
      .flush_pend                       (),
      .mem_err                          (mem_err)
  );


  generate
    if ((TMC_CONFIG == ETB) || (TMC_CONFIG == ETF))
    begin : u_css600_tmc_mem_if_block
      css600_tmc_mem_if
      #(
        .TMC_CONFIG                    (TMC_CONFIG),
        .MEM_SIZE                      (MEM_SIZE),
        .ATB_DATA_WIDTH                (ATB_DATA_WIDTH),
        .MEM_ADDR_WIDTH                (MEM_ADDR_WIDTH),
        .MEM_BYTE_ADDR_WIDTH           (MEM_BYTE_ADDR_WIDTH),
        .WB_DATA_WIDTH                 (WB_DATA_WIDTH),
        .FILL_LEVEL_WIDTH              (FILL_LEVEL_WIDTH)
      )
      u_css600_tmc_mem_if
      (
        .clk                           (clk_r),
        .cg_en                         (cg_en),
        .reset_n                       (reset_n),
        .dev_run                       (dev_run),
        .lp_done                       (lp_done),
        .mem_ce_n                      (mem_ce_n),
        .mem_we_n                      (mem_we_n),
        .mem_addr                      (mem_addr),
        .mem_d                         (mem_d),
        .mem_q                         (mem_q),
        .wb_req_valid                  (wb_req_valid),
        .wb_req_ready                  (wb_req_ready),
        .wb_data                       (wb_data),
        .rb_req_valid                  (rb_req_valid),
        .rb_req_ready                  (rb_req_ready),
        .rb_rdata_valid                (rb_rdata_valid),
        .rb_data                       (rb_data),
        .apb_read_fifo_rrp_en          (apb_read_fifo_rrp_en),
        .ctl_trace_capt_en             (ctl_trace_capt_en),
        .ctl_trace_capt_en_rise        (ctl_trace_capt_en_rise),
        .tmc_enabled                   (tmc_enabled),
        .tmc_abort                     (tmc_abort),
        .unformatter_en                (unformatter_en),
        .circ_buf_mode                 (circ_buf_mode),
        .l_buf_level_rd_done           (l_buf_level_rd_done),
        .rrp_wr_en                     (rrp_wr_en),
        .rwp_wr_en                     (rwp_wr_en),
        .apb_wdata_p                   (apb_wdata_p),
        .unprog_rrp                    (unprog_rrp),
        .unprog_rwp                    (unprog_rwp),
        .ptr_prog                      (ptr_prog),
        .buf_wm                        (buf_wm),
        .rrp                           (rrp),
        .rwp                           (rwp),
        .l_buf_level                   (l_buf_level),
        .c_buf_level                   (c_buf_level),
        .trace_mem_empty               (trace_mem_empty),
        .sts_full                      (sts_full),
        .mem_flush_req                 (mem_flush_req),
        .mem_flush_ack                 (mem_flush_ack),
        .itctrl_ime                    (itctrl_ime),
        .it_evt_intr_wr_en             (it_evt_intr_wr_en),
        .unformatter_empty             (unformatter_empty),
        .mem_wr                        (mem_wr),
        .full                          (full)
      );
      assign bufintr=1'b0;
    end
  endgenerate


  generate
    if (TMC_CONFIG == ETR)
    begin : u_css600_tmc_axi_if_block
      css600_tmc_axi_if
      #(
        .AXI_DATA_WIDTH               (AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH               (AXI_ADDR_WIDTH),
        .MEM_BYTE_ADDR_WIDTH          (MEM_BYTE_ADDR_WIDTH),
        .WBUFFER_DEPTH                (WBUFFER_DEPTH),
        .WB_DATA_WIDTH                (WB_DATA_WIDTH),
        .WB_PTR_WIDTH                 (WB_PTR_WIDTH)
      )
      u_css600_tmc_axi_if
      (
        .clk                          (clk_r),
        .cg_en                        (cg_en),
        .reset_n                      (reset_n),
        .araddr_m                     (araddr_m),
        .arlen_m                      (arlen_m),
        .arsize_m                     (arsize_m),
        .arburst_m                    (arburst_m),
        .arlock_m                     (arlock_m),
        .arcache_m                    (arcache_m),
        .arprot_m                     (arprot_m),
        .arvalid_m                    (arvalid_m),
        .arready_m                    (arready_m),
        .rdata_m                      (rdata_m),
        .rresp_m                      (rresp_m),
        .rlast_m                      (rlast_m),
        .rvalid_m                     (rvalid_m),
        .rready_m                     (rready_m),
        .awaddr_m                     (awaddr_m),
        .awlen_m                      (awlen_m),
        .awsize_m                     (awsize_m),
        .awburst_m                    (awburst_m),
        .awlock_m                     (awlock_m),
        .awcache_m                    (awcache_m),
        .awprot_m                     (awprot_m),
        .awvalid_m                    (awvalid_m),
        .awready_m                    (awready_m),
        .wdata_m                      (wdata_m),
        .wstrb_m                      (wstrb_m),
        .wlast_m                      (wlast_m),
        .wvalid_m                     (wvalid_m),
        .wready_m                     (wready_m),
        .bresp_m                      (bresp_m),
        .bvalid_m                     (bvalid_m),
        .bready_m                     (bready_m),
        .dbgen_q                      (dbgen_q),
        .spiden_q                     (spiden_q),
        .wb_req_valid                 (wb_req_valid),
        .wb_req_ready                 (wb_req_ready),
        .wb_data                      (wb_data),
        .wb_fill_level                (wb_fill_level),
        .wb_flush_cnt                 (wb_flush_cnt),
        .wb_flush_req_det             (wb_flush_req_det),
        .rb_req_valid                 (rb_req_valid),
        .rb_req_ready                 (rb_req_ready),
        .rb_data                      (rb_data),
        .rb_rdata_valid               (rb_rdata_valid),
        .apb_read_fifo_rrp_en         (apb_read_fifo_rrp_en),
        .ctl_trace_capt_en_rise       (ctl_trace_capt_en_rise),
        .ctl_trace_capt_en_rise_pre   (ctl_trace_capt_en_rise_pre),
        .mem_err_clr                  (mem_err_clr),
        .nxt_tmc_enabled              (nxt_tmc_enabled),
        .tmc_enabled                  (tmc_enabled),
        .tmc_abort                    (tmc_abort),
        .circ_buf_mode                (circ_buf_mode),
        .sw_fifo_mode2                (sw_fifo_mode2),
        .l_buf_level_rd_done          (l_buf_level_rd_done),
        .sts_full_wr_en               (sts_full_wr_en),
        .rurp_wr_en                   (rurp_wr_en),
        .rrp_wr_en                    (rrp_wr_en),
        .rrp_hi_wr_en                 (rrp_hi_wr_en),
        .rwp_wr_en                    (rwp_wr_en),
        .rwp_hi_wr_en                 (rwp_hi_wr_en),
        .apb_wdata_p                  (apb_wdata_p),
        .unprog_sts                   (unprog_sts),
        .unprog_rrp                   (unprog_rrp),
        .unprog_rwp                   (unprog_rwp),
        .unprog_rrphi                 (unprog_rrphi),
        .unprog_rwphi                 (unprog_rwphi),
        .ptr_prog                     (ptr_prog),
        .rsz                          (rsz),
        .wr_burst_len                 (wr_burst_len),
        .axictl_wcache                (axictl_wcache),
        .axictl_rcache                (axictl_rcache),
        .axictl_prot_ctrl             (axictl_prot_ctrl),
        .dba                          (dba),
        .buf_wm                       (buf_wm),
        .rrp                          (rrp),
        .rwp                          (rwp),
        .l_buf_level                  (l_buf_level),
        .c_buf_level                  (c_buf_level),
        .trace_mem_empty              (trace_mem_empty),
        .sts_full                     (sts_full),
        .mem_err                      (mem_err),
        .ft_stopped_q2                (ft_stopped_q2),
        .wb_flush_req                 (wb_flush_req),
        .wb_flush_ack                 (wb_flush_ack),
        .mem_flush_req                (mem_flush_req),
        .mem_flush_ack                (mem_flush_ack),
        .itctrl_ime                   (itctrl_ime),
        .it_evt_intr_wr_en            (it_evt_intr_wr_en),
        .dev_run                      (dev_run),
        .lp_done                      (lp_done),
        .axi_intf_ready               (axi_intf_ready),
        .read_in_prog                 (read_in_prog),
        .outstanding_wreq_cnt_p       (outstanding_wreq_cnt_p),
        .full                         (full),
        .bufintr                      (bufintr)
      );
    end

    else
    begin : gen_no_axi_if
      assign axi_intf_ready = 1'b1;
      assign mem_err        = 1'b0;
      assign read_in_prog   = 1'b0;
      assign outstanding_wreq_cnt_p = 6'b0;
      assign araddr_m   = {AXI_ADDR_WIDTH{1'b0}};
      assign arlen_m    = 8'b0;
      assign arsize_m   = 3'b0;
      assign arburst_m  = 2'b0;
      assign arlock_m   = 1'b0;
      assign arcache_m  = 4'b0;
      assign arprot_m   = 3'b0;
      assign arvalid_m  = 1'b0;
      assign rready_m   = 1'b0;
      assign awaddr_m   = {AXI_ADDR_WIDTH{1'b0}};
      assign awlen_m    = 8'b0;
      assign awsize_m   = 3'b0;
      assign awburst_m  = 2'b0;
      assign awlock_m   = 1'b0;
      assign awcache_m  = 4'b0;
      assign awprot_m   = 3'b0;
      assign awvalid_m  = 1'b0;
      assign wdata_m    = {AXI_DATA_WIDTH{1'b0}};
      assign wstrb_m    = {AXI_DATA_WIDTH/8{1'b0}};
      assign wlast_m    = 1'b0;
      assign wvalid_m   = 1'b0;
      assign bready_m   = 1'b0;
    end
  endgenerate

  assign awakeup_m = (awvalid_m | arvalid_m | wvalid_m);


  generate
    if ((TMC_CONFIG == ETB) || (TMC_CONFIG == ETR))
    begin : u_css600_tmc_apbreadfifo_block
      css600_tmc_apbreadfifo
      #(
        .TMC_CONFIG            (TMC_CONFIG),
        .ATB_DATA_WIDTH        (ATB_DATA_WIDTH),
        .WB_DATA_WIDTH         (WB_DATA_WIDTH)
      )
      u_css600_tmc_apbreadfifo
      (
        .clk                   (clk_r),
        .cg_en                 (cg_en),
        .reset_n               (reset_n),
        .rrd_rd_req            (rrd_rd_req),
        .rrd_rd_ack            (rrd_rd_ack),
        .rrd_rd_data           (rrd_rd_data),
        .rb_req_valid          (rb_req_valid),
        .rb_req_ready          (rb_req_ready),
        .rb_rdata_valid        (rb_rdata_valid),
        .rb_data               (rb_data),
        .mem_err               (mem_err),
        .apbreadfifo_clr       (apbreadfifo_clr),
        .apb_read_fifo_rrp_en  (apb_read_fifo_rrp_en)
      );
    end
  endgenerate


  generate
    if (TMC_CONFIG == ETF)
    begin : u_css600_tmc_unformatter_block
      wire [16:0] apb_wdata_p_bits16to0;
      css600_tmc_unformatter
      #(
        .ATB_DATA_WIDTH        (ATB_DATA_WIDTH),
        .ATBYTES_WIDTH         (ATBYTES_WIDTH)
      )
      u_css600_tmc_unformatter
      (
        .clk                   (clk_r),
        .cg_en                 (cg_en),
        .clk_g                 (clk_g),
        .reset_n               (reset_n),
        .unformatter_en        (unformatter_en),
        .unformatter_stop      (unformatter_stop),
        .ctl_trace_capt_en     (ctl_trace_capt_en),
        .ctl_trace_capt_en_rise(ctl_trace_capt_en_rise),
        .tmc_ready             (tmc_ready),
        .hw_fifo_mode          (hw_fifo_mode),
        .apbreadfifo_clr       (apbreadfifo_clr),
        .apb_read_fifo_rrp_en  (apb_read_fifo_rrp_en),
        .unformatter_empty     (unformatter_empty),
        .rrd_rd_req            (rrd_rd_req),
        .rrd_rd_ack            (rrd_rd_ack),
        .rrd_rd_data           (rrd_rd_data),
        .rb_req_valid          (rb_req_valid),
        .rb_req_ready          (rb_req_ready),
        .rb_rdata_valid        (rb_rdata_valid),
        .rb_data               (rb_data),
        .atwakeup_m            (atwakeup_m),
        .atid_m                (atid_m),
        .atbytes_m             (atbytes_m),
        .atdata_m              (atdata_m),
        .atvalid_m             (atvalid_m),
        .atready_m             (atready_m),
        .afvalid_m             (afvalid_m),
        .afready_m             (afready_m),
        .nxt_afreadym          (nxt_afreadym),
        .atbm_flush_valid      (atbm_flush_valid),
        .atbm_flush_ready      (atbm_flush_ready),
        .dev_run               (dev_run),
        .lp_done               (lp_done),
        .itctrl_ime            (itctrl_ime),
        .it_atb_m_ctr_0_wr_en  (it_atb_m_ctr_0_wr_en),
        .it_atb_m_ctr_1_wr_en  (it_atb_m_ctr_1_wr_en),
        .it_atb_m_data_0_wr_en (it_atb_m_data_0_wr_en),
        .apb_wdata_p_bits16to0 (apb_wdata_p_bits16to0)
      );

      assign apb_wdata_p_bits16to0 = apb_wdata_p[16:0];
    end

    else
    begin : gen_no_unformatter
      assign unformatter_empty = 1'b1;
      assign atbm_flush_valid  = 1'b0;
      assign atid_m     = 7'b0;
      assign atdata_m   = {ATB_DATA_WIDTH{1'b0}};
      assign atbytes_m  = {ATBYTES_WIDTH{1'b0}};
      assign atvalid_m  = 1'b0;
      assign afready_m  = 1'b1;
      assign atwakeup_m = 1'b0;
      assign nxt_afreadym = 1'b0;
    end
  endgenerate


  generate
    if ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS))
      begin : gen_ctr_dec_etr_ets
        assign pscr_ctr_decr_pulse = ft_fifo_beat;
      end
    else
      begin : gen_ctr_dec_etb_etf
        assign pscr_ctr_decr_pulse = mem_wr;
      end
  endgenerate


  wire apb_wdata_p_bit2;
  css600_tmc_sync_req
  #(
    .ATB_DATA_WIDTH          (ATB_DATA_WIDTH),
    .TMC_CONFIG              (TMC_CONFIG))
  u_css600_tmc_sync_req
  (
      .clk                       (clk_r),
      .cg_en                     (cg_en),
      .clk_g                     (clk_g),
      .reset_n                   (reset_n),
      .ctl_trace_capt_en         (ctl_trace_capt_en),
      .ctl_trace_capt_en_rise    (ctl_trace_capt_en_rise),
      .ffcr_en_formatting_masked (ffcr_en_formatting_masked),
      .hw_fifo_mode              (hw_fifo_mode),
      .ft_running                (ft_running),
      .stop_pending              (stop_pending),
      .pscr_embed_sync           (pscr_embed_sync),
      .pscr_pscount              (pscr_pscount),
      .pscr_ctr_decr_pulse       (pscr_ctr_decr_pulse),
      .itctrl_ime                (itctrl_ime),
      .it_atb_ctr_2_wr_en        (it_atb_ctr_2_wr_en),
      .apb_wdata_p_bit2          (apb_wdata_p_bit2),
      .frame_sync_req            (frame_sync_req),
      .dev_run                   (dev_run),
      .lp_done                   (lp_done),
      .syncreq_m                 (syncreq_m),
      .syncreq_s                 (syncreq_s)
  );

  assign apb_wdata_p_bit2 = apb_wdata_p[2];


    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
    u_css600_cdc_capt_sync_clk_qreq(
                                     .clk       (clk),
                                     .reset_n   (reset_n),
                                     .d_async_i (clk_qreq_n),
                                     .q_sync_o  (clk_qreq_n_sync)
                                   );

  css600_lpislave
    u_css600_lpislave_clk
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
      .cg_en        (cg_en)
    );

  assign lp_done = lp_request;

  generate
    if (TMC_CONFIG == ETB)
      begin : gen_active_etb
        assign dev_active  = itctrl_ime | psel_s | atvalid_s | flush_fsm_busy | trig_flush_wake;
      end
    if (TMC_CONFIG == ETF)
      begin : gen_active_etf
        assign dev_active  = itctrl_ime | psel_s | atvalid_s | flush_fsm_busy | trig_flush_wake |
                             ffcr_drain_buffer_en | atvalid_m | (atbm_flush_mon & afvalid_m);
      end
    if (TMC_CONFIG == ETR)
      begin : gen_active_etr
        wire axi_intf_pend;

        assign axi_intf_pend = (awvalid_m | wvalid_m | read_in_prog | (|outstanding_wreq_cnt_p));
        assign dev_active  = itctrl_ime | psel_s | atvalid_s | flush_fsm_busy | trig_flush_wake | axi_intf_pend;
      end
    if (TMC_CONFIG == ETS)
      begin : gen_active_ets
        assign dev_active  = itctrl_ime | psel_s | atvalid_s | flush_fsm_busy | trig_flush_wake | tvalid_m;
      end
  endgenerate

  assign trig_flush_wake = ((trigin | trigin_q) & trigin_mon) | ((flushin | flushin_q) & flushin_mon);

  css600_tmc_async
   #(.TMC_CONFIG (TMC_CONFIG))
  u_css600_qactive_async
    (
      .itctrl_ime             (itctrl_ime),
      .pwakeup_s              (pwakeup_s),
      .atwakeup_s             (atwakeup_s),
      .flush_fsm_busy         (flush_fsm_busy),
      .trigin_mon             (trigin_mon),
      .trigin                 (trigin),
      .trigin_q               (trigin_q),
      .flushin_mon            (flushin_mon),
      .flushin                (flushin),
      .flushin_q              (flushin_q),
      .awvalid_m              (awvalid_m),
      .wvalid_m               (wvalid_m),
      .read_in_prog           (read_in_prog),
      .outstanding_wreq_cnt_p (outstanding_wreq_cnt_p),
      .twakeup_m              (twakeup_m),
      .ffcr_drain_buffer_en   (ffcr_drain_buffer_en),
      .atwakeup_m             (atwakeup_m),
      .atbm_flush_mon         (atbm_flush_mon),
      .afvalid_m              (afvalid_m),
      .clk_qactive            (clk_qactive)
    );


endmodule

