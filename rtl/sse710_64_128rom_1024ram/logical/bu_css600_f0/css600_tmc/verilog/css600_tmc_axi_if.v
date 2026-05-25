//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009-2010, 2016-2020 Arm Limited or its affiliates.
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


module css600_tmc_axi_if
#(
  parameter AXI_DATA_WIDTH      = 32,
  parameter AXI_ADDR_WIDTH      = 40,
  parameter MEM_BYTE_ADDR_WIDTH = 40,
  parameter WB_DATA_WIDTH       = 32,
  parameter WBUFFER_DEPTH       = 4,
  parameter WB_PTR_WIDTH        = 2
)
(
  input  wire                                    clk,
  input  wire                                    cg_en,
  input  wire                                    reset_n,

  output wire [AXI_ADDR_WIDTH-1:0]               araddr_m,
  output wire [7:0]                              arlen_m,
  output wire [2:0]                              arsize_m,
  output wire [1:0]                              arburst_m,
  output wire                                    arlock_m,
  output wire [3:0]                              arcache_m,
  output wire [2:0]                              arprot_m,
  output reg                                     arvalid_m,
  input  wire                                    arready_m,
  input  wire [AXI_DATA_WIDTH-1:0]               rdata_m,
  input  wire [1:0]                              rresp_m,
  input  wire                                    rlast_m,
  input  wire                                    rvalid_m,
  output wire                                    rready_m,
  output wire [AXI_ADDR_WIDTH-1:0]               awaddr_m,
  output wire [7:0]                              awlen_m,
  output wire [2:0]                              awsize_m,
  output wire [1:0]                              awburst_m,
  output wire                                    awlock_m,
  output wire [3:0]                              awcache_m,
  output wire [2:0]                              awprot_m,
  output reg                                     awvalid_m,
  input  wire                                    awready_m,
  output reg  [AXI_DATA_WIDTH-1:0]               wdata_m,
  output wire [(AXI_DATA_WIDTH/8)-1:0]           wstrb_m,
  output reg                                     wlast_m,
  output reg                                     wvalid_m,
  input  wire                                    wready_m,
  input  wire [1:0]                              bresp_m,
  input  wire                                    bvalid_m,
  output wire                                    bready_m,

  input  wire                                    dbgen_q,
  input  wire                                    spiden_q,

  input  wire                                    wb_req_valid,
  output wire                                    wb_req_ready,
  input  wire [WB_DATA_WIDTH-1:0]                wb_data,
  input  wire [WB_PTR_WIDTH:0]                   wb_fill_level,
  input  wire                                    wb_flush_req_det,
  input  wire [WB_PTR_WIDTH:0]                   wb_flush_cnt,

  input  wire                                    rb_req_valid,
  output reg                                     rb_req_ready,
  output reg  [WB_DATA_WIDTH-1:0]                rb_data,
  output reg                                     rb_rdata_valid,
  input  wire                                    apb_read_fifo_rrp_en,

  input  wire                                    ctl_trace_capt_en_rise,
  input  wire                                    ctl_trace_capt_en_rise_pre,
  input  wire                                    mem_err_clr,
  input  wire                                    nxt_tmc_enabled,
  input  wire                                    tmc_enabled,
  input  wire                                    tmc_abort,
  input  wire                                    circ_buf_mode,
  input  wire                                    sw_fifo_mode2,
  input  wire                                    l_buf_level_rd_done,
  input  wire                                    sts_full_wr_en,
  input  wire                                    rurp_wr_en,
  input  wire                                    rrp_wr_en,
  input  wire                                    rrp_hi_wr_en,
  input  wire                                    rwp_wr_en,
  input  wire                                    rwp_hi_wr_en,
  input  wire [31:0]                             apb_wdata_p,
  input  wire                                    unprog_sts,
  input  wire                                    unprog_rrp,
  input  wire                                    unprog_rwp,
  input  wire                                    unprog_rrphi,
  input  wire                                    unprog_rwphi,
  input  wire                                    ptr_prog,

  input  wire [30:0]                             rsz,
  input  wire [3:0]                              wr_burst_len,
  input  wire [3:0]                              axictl_wcache,
  input  wire [3:0]                              axictl_rcache,
  input  wire [1:0]                              axictl_prot_ctrl,
  input  wire [MEM_BYTE_ADDR_WIDTH-1:0]          dba,
  input  wire [29:0]                             buf_wm,

  output wire [MEM_BYTE_ADDR_WIDTH-1:0]          rrp,
  output wire [MEM_BYTE_ADDR_WIDTH-1:0]          rwp,
  output wire [30:0]                             l_buf_level,
  output wire [30:0]                             c_buf_level,
  output reg                                     trace_mem_empty,
  output reg                                     sts_full,
  output reg                                     mem_err,

  input  wire                                    ft_stopped_q2,
  input  wire                                    wb_flush_req,
  input  wire                                    wb_flush_ack,
  input  wire                                    mem_flush_req,
  output reg                                     mem_flush_ack,

  input  wire                                    itctrl_ime,
  input  wire                                    it_evt_intr_wr_en,

  input  wire                                    dev_run,
  input  wire                                    lp_done,

  output wire                                    axi_intf_ready,
  output reg                                     read_in_prog,
  output reg  [5:0]                              outstanding_wreq_cnt_p,
  output reg                                     full,
  output reg                                     bufintr
);

  `include "css600_tmc_localparams.v"
  `include "css600_tmc_functions.v"

  localparam MEM_ADDR_WIDTH = (AXI_ADDR_WIDTH - tmc_clog2(AXI_DATA_WIDTH/8));

  localparam HI_ADDR_WIDTH = (AXI_ADDR_WIDTH - 32);

  localparam WCNT_WIDTH = (WBUFFER_DEPTH == 4) ? 2 :
                          (WBUFFER_DEPTH == 8) ? 3 : 4;

  localparam AXI_SIZE_32  = 3'b010;
  localparam AXI_SIZE_64  = 3'b011;
  localparam AXI_SIZE_128 = 3'b100;
  localparam AXI_BURST_LEN_1 = 8'h00;
  localparam AXI_LOCK_NORMAL = 1'b0;
  localparam AXI_BURST_TYPE_FIXED = 2'b00;
  localparam AXI_BURST_TYPE_INCR  = 2'b01;

  localparam PTR_PAD = (MEM_BYTE_ADDR_WIDTH - MEM_ADDR_WIDTH);

  localparam BUF_LEVEL_CMP_MASK = (WB_DATA_WIDTH == 32) ? {{31{1'b1}}} :
                                  (WB_DATA_WIDTH == 64) ? {{30{1'b1}}, 1'b0} :
                                                          {{29{1'b1}}, 2'b00};

  localparam AXI_SIZE_VAL = (AXI_DATA_WIDTH == 32) ? AXI_SIZE_32 :
                            (AXI_DATA_WIDTH == 64) ? AXI_SIZE_64 :
                                                     AXI_SIZE_128;

  localparam BUF_LEVEL_WIDTH = (WB_DATA_WIDTH == 32) ? 31 :
                               (WB_DATA_WIDTH == 64) ? 30 :
                                                       29;

  localparam BUF_LEVEL_PAD = (WB_DATA_WIDTH == 32) ? 0 :
                             (WB_DATA_WIDTH == 64) ? 1 : 2;


  wire                           aw_ch_we;
  wire                           ar_ch_we;
  wire                           wdatam_we;
  reg                            w_ch_busy;

  wire                           nxt_awvalidm;
  wire [1:0]                     nxt_awprotm;
  wire [3:0]                     nxt_awcachem;
  wire [MEM_ADDR_WIDTH-1:0]      nxt_awaddrm;
  wire [3:0]                     nxt_awlenm;
  wire                           nxt_wvalidm;
  wire                           nxt_wlastm;
  wire [AXI_DATA_WIDTH-1:0]      nxt_wdatam;
  wire                           nxt_arvalidm;
  wire [1:0]                     nxt_arprotm;
  wire [3:0]                     nxt_arcachem;
  wire [MEM_ADDR_WIDTH-1:0]      nxt_araddrm;
  reg                            bvalidm_q;
  reg  [1:0]                     awprot_m_int;
  reg  [3:0]                     awcache_m_int;
  reg  [MEM_ADDR_WIDTH-1:0]      awaddr_m_int;
  reg  [3:0]                     awlen_m_int;
  reg  [1:0]                     arprot_m_int;
  reg  [3:0]                     arcache_m_int;
  reg  [MEM_ADDR_WIDTH-1:0]      araddr_m_int;

  wire                           rrp_incr_fol;
  wire                           rrp_incr;
  wire                           rwp_incr;
  wire                           rrp_we;
  wire                           rwp_we;
  wire                           rrp_full_wr_en;
  wire                           rwp_full_wr_en;
  wire                           rurp_wr_valid;
  wire                           rrp_wrap_around;

  wire [20:0]                    rurp_wdata_bytes;
  wire [20-PTR_PAD:0]            rurp_wdata_words;

  wire [MEM_ADDR_WIDTH-1:0]      dba_min;
  wire [MEM_BYTE_ADDR_WIDTH-1:0] nxt_dba_max_byte_addr;
  wire [MEM_ADDR_WIDTH-1:0]      nxt_dba_max;
  reg  [MEM_ADDR_WIDTH-1:0]      dba_max;
  reg  [MEM_ADDR_WIDTH-1:0]      nxt_rwp_word_addr;
  reg  [MEM_ADDR_WIDTH-1:0]      nxt_rrp_word_addr;
  reg  [MEM_ADDR_WIDTH-1:0]      rwp_word_addr;
  reg  [MEM_ADDR_WIDTH-1:0]      rrp_word_addr;
  wire [MEM_ADDR_WIDTH-1:0]      rwp_word_addr_int;
  wire [MEM_ADDR_WIDTH-1:0]      rrp_word_addr_int;
  wire [MEM_ADDR_WIDTH-1:0]      dba_max_minus_rrp_word_addr_int;
  wire                           rwp_word_addr_p1_we;
  wire [MEM_ADDR_WIDTH-1:0]      nxt_rwp_word_addr_p1;
  reg  [MEM_ADDR_WIDTH-1:0]      rwp_word_addr_p1;
  wire [MEM_ADDR_WIDTH-1:0]      rwp_word_addr_p;

  wire                           wr_skid_buf_full_set;
  wire                           wr_skid_buf_full_clr;
  wire                           nxt_wr_skid_buf_full;
  reg                            wr_skid_buf_full;
  wire                           wr_skid_buf_we;
  wire [WB_DATA_WIDTH-1:0]       nxt_wr_skid_buf;
  reg  [WB_DATA_WIDTH-1:0]       wr_skid_buf;
  wire                           nxt_skid_fl_pend;
  reg                            skid_fl_pend;

  wire                           write_start_detect;
  wire                           write_start;
  wire                           new_write_xfer;
  reg                            new_write_xfer_q;
  wire                           write_init_req;
  wire                           write_init_deny;
  wire                           write_in_prog;
  wire                           write_data_avlbl;
  reg                            write_last;

  wire                           wcnt_we;
  wire [WCNT_WIDTH-1:0]          nxt_wcnt;
  reg  [WCNT_WIDTH-1:0]          wcnt;

  wire [5:0]                     outstanding_wreq_cnt;
  reg  [5:0]                     nxt_outstanding_wreq_cnt_p;
  wire                           outstanding_wreq_cnt_p_we;
  wire                           max_outstndg_wr_reached;
  wire                           outstanding_wreq_cnt_eq0;
  wire                           trace_mem_empty_compl;
  reg  [30:0]                    pend_level;

  wire                           fl_wreq_cnt_load_en;
  wire                           fl_wreq_cnt_decr;
  wire                           fl_outstanding_wreq_cnt_we;
  wire [5:0]                     fl_wreq_cnt_load_val;
  wire [5:0]                     nxt_fl_outstanding_wreq_cnt;
  reg  [5:0]                     fl_outstanding_wreq_cnt;

  wire                           mem_rd_en;
  wire                           mem_rd_init_req;
  wire                           mem_rd_init_err;
  wire                           mem_err_auth;
  wire                           nxt_mem_err;
  wire                           nxt_mem_flush_ack;
  wire                           rd_auth_err;
  wire                           nxt_read_in_prog;
  wire                           nxt_rb_rdata_valid;
  wire                           nxt_rb_req_ready;

  wire [3:0]                     wb_thrshold_min3;
  wire [3:0]                     wb_thrshold_min4;
  wire [3:0]                     wlen_wb_fill_level;
  wire [3:0]                     wlen_4kb;
  wire [3:0]                     wlen_dba_max;
  wire [4:0]                     wlen_rwp_dist_to_rrp;
  wire                           wr_burst_spc_avlbl;
  wire                           trace_mem_wr_thrshold_met;

  wire                           wb_thrshold_met;
  wire                           wb_req_ready_mask_trace_mem_full;
  wire [WB_PTR_WIDTH:0]          wb_fill_level_masked;

  wire                           rrp_rwp_diff_4kb_page;
  wire [11-PTR_PAD:0]            rwp_dist_to_rrp_same_page;
  wire [11-PTR_PAD:0]            rwp_p_dist_to_4kb;
  wire [MEM_ADDR_WIDTH-1:0]      rwp_dist_to_dba_max;

  wire [30:0]                    trace_mem_space_thrshold;
  reg                            sts_full_set;
  reg                            sts_full_clr;
  wire                           sts_full_update;
  wire                           sts_full_int;
  wire                           nxt_sts_full;
  wire                           nxt_full;
  wire                           nxt_bufintr;

  wire                           nxt_rsz_single_word;
  reg                            rsz_single_word;
  wire                           rwp_eq_dba_max;
  wire                           rwp_p1_eq_dba_max;
  wire                           rwp_gt_rrp;
  wire                           rwp_eq_rrp;
  wire                           rwp_lt_rrp;
  wire                           nxt_c_buf_level_gr_eq_thrshold;
  wire [MEM_ADDR_WIDTH-1:0]      rsz_ptr_cmp;
  wire [MEM_ADDR_WIDTH:0]        init_buf_level_expanded;

  wire                           l_buf_level_upd;
  reg                            l_buf_level_upd_q;
  wire                           l_buf_level_we;
  wire                           c_buf_level_we;
  wire [BUF_LEVEL_WIDTH-1:0]     nxt_l_buf_level_r;
  reg  [BUF_LEVEL_WIDTH-1:0]     nxt_c_buf_level_r;
  reg  [BUF_LEVEL_WIDTH-1:0]     l_buf_level_r;
  reg  [BUF_LEVEL_WIDTH-1:0]     c_buf_level_r;
  wire [BUF_LEVEL_WIDTH-1:0]     l_buf_level_r_int;
  wire [BUF_LEVEL_WIDTH-1:0]     c_buf_level_r_int;
  wire                           trace_mem_empty_we;
  wire                           nxt_trace_mem_empty;


  assign new_write_xfer = write_start & (~write_in_prog | write_last);

  assign write_start_detect = ~(nxt_mem_err | mem_err_auth) & write_init_req;
  assign write_start = cg_en & write_start_detect & ~lp_done & dev_run;

  assign write_init_req = nxt_tmc_enabled ?
                            (write_data_avlbl & ~write_init_deny) :
                            (wb_req_valid & ~write_in_prog & outstanding_wreq_cnt_eq0);

  assign write_data_avlbl = wb_req_valid | wr_skid_buf_full;

  assign write_init_deny =  wb_req_ready_mask_trace_mem_full |
                           ~wb_thrshold_met |
                            max_outstndg_wr_reached;

  always @(posedge clk or negedge reset_n)
  begin : s_new_write_xfer_q
    if (!reset_n)
      new_write_xfer_q <= 1'b0;
    else if (cg_en)
      new_write_xfer_q <= new_write_xfer;
  end


  generate
    if (WB_PTR_WIDTH == 2)
    begin : gen_wlen_wb_fill_level_4
      assign wlen_wb_fill_level = wb_req_valid ?
                                    (wr_skid_buf_full ?
                                      ({1'b0, wb_fill_level_masked[2:0]}) :
                                      ({1'b0, wb_fill_level_masked[2:0]} - 4'h1)) :
                                    4'h0;
    end

    else if (WB_PTR_WIDTH == 3)
    begin : gen_wlen_wb_fill_level_8
      assign wlen_wb_fill_level = wb_req_valid ?
                                    (wr_skid_buf_full ?
                                      (wb_fill_level_masked[3:0]) :
                                      (wb_fill_level_masked[3:0] - 4'h1)) :
                                    4'h0;
    end

    else
    begin : gen_wlen_wb_fill_level_16_32
      assign wlen_wb_fill_level = (wb_fill_level_masked > {{WB_PTR_WIDTH+1-4{1'b0}}, 4'hF}) ?
                                     4'hF :
                                   wb_req_valid ?
                                     (wr_skid_buf_full ?
                                       (wb_fill_level_masked[3:0]) :
                                       (wb_fill_level_masked[3:0] - 4'h1)) :
                                     4'h0;
    end
  endgenerate

  assign wb_fill_level_masked = wb_flush_req_det ||
                               (skid_fl_pend && wr_skid_buf_full) ? wb_flush_cnt : wb_fill_level;


  assign wb_thrshold_met = !nxt_tmc_enabled ?  wb_req_valid :
                                         ((wlen_wb_fill_level >= wr_burst_len) |
                                          (wlen_wb_fill_level >= wb_thrshold_min3) |
                                           ft_stopped_q2 | wb_flush_req |
                                          (skid_fl_pend & wr_skid_buf_full));

  assign wb_thrshold_min3 = ((wr_burst_len <= wlen_4kb) &&
                             (wr_burst_len <= wlen_dba_max)) ? wr_burst_len :
                            ((wlen_4kb <= wlen_dba_max) &&
                             (wlen_4kb <= wr_burst_len)) ? wlen_4kb : wlen_dba_max;

  assign wb_thrshold_min4 = (wb_thrshold_min3 < wlen_wb_fill_level) ?
                             wb_thrshold_min3 : wlen_wb_fill_level;

  assign rwp_p_dist_to_4kb = {(12-PTR_PAD){1'b1}} - rwp_word_addr_p[11-PTR_PAD:0];

  assign wlen_4kb = (rwp_p_dist_to_4kb > {{(12-PTR_PAD-4){1'b0}}, 4'hF}) ?
                       4'hF : rwp_p_dist_to_4kb[3:0];

  assign rwp_dist_to_dba_max = dba_max - rwp_word_addr_p;

  assign wlen_dba_max = (rwp_dist_to_dba_max > {{(MEM_ADDR_WIDTH-4){1'b0}}, 4'hF}) ?
                           4'hF : rwp_dist_to_dba_max[3:0];

  assign write_in_prog = awvalid_m | wvalid_m;

  always @*
  begin : c_write_last
    case ({awvalid_m, wvalid_m})
      2'b00 :
        write_last = 1'b0;
      2'b01 :
        write_last = wlast_m & wready_m;
      2'b10 :
        write_last = awready_m;
      2'b11 :
        write_last = awready_m & wlast_m & wready_m;
    endcase
  end


  assign nxt_awvalidm = new_write_xfer | (awvalid_m & ~awready_m);

  always @(posedge clk or negedge reset_n)
  begin: s_awvalid_m
    if (!reset_n)
      awvalid_m <= 1'b0;
    else if (cg_en)
      awvalid_m <= nxt_awvalidm;
  end

  assign nxt_awprotm = axictl_prot_ctrl;

  assign nxt_awcachem = axictl_wcache;

  assign nxt_awaddrm = rwp_word_addr_p;

  assign nxt_awlenm = nxt_tmc_enabled ? wb_thrshold_min4 : 4'h0;

  assign aw_ch_we = new_write_xfer;

  always @(posedge clk)
  begin : s_aw
    if (aw_ch_we)
      begin
        awaddr_m_int  <= nxt_awaddrm;
        awlen_m_int   <= nxt_awlenm;
        awcache_m_int <= nxt_awcachem;
        awprot_m_int  <= nxt_awprotm;
      end
  end

  assign awaddr_m  = {awaddr_m_int,{PTR_PAD{1'b0}}};
  assign awlen_m   = {{4{1'b0}},awlen_m_int};
  assign awcache_m =  awcache_m_int;
  assign awprot_m  = {1'b0,awprot_m_int};

  assign awburst_m = AXI_BURST_TYPE_INCR;
  assign awlock_m = AXI_LOCK_NORMAL;
  assign awsize_m = AXI_SIZE_VAL;


  assign nxt_wlastm = (~|(nxt_wcnt));

  always @(posedge clk)
  begin : s_wlast_m
    if (wdatam_we)
      wlast_m <= nxt_wlastm;
  end

  assign nxt_wcnt = new_write_xfer ? (nxt_awlenm[WCNT_WIDTH-1:0]) :
                        (!wlast_m) ? (wcnt - {{(WCNT_WIDTH-1){1'b0}}, 1'b1}) :
                                      wcnt;

  assign wcnt_we = cg_en & (new_write_xfer | (wvalid_m && wready_m));

  always @(posedge clk or negedge reset_n)
  begin : s_wcnt
    if (!reset_n)
      wcnt <= {WCNT_WIDTH{1'b0}};
    else if (wcnt_we)
      wcnt <= nxt_wcnt;
  end

  assign nxt_wvalidm = new_write_xfer | (wvalid_m & ~(wlast_m & wready_m));

  always @(posedge clk or negedge reset_n)
  begin : s_wvalid_m
    if (!reset_n)
      wvalid_m <= 1'b0;
    else if (cg_en)
      wvalid_m <= nxt_wvalidm;
  end

  assign nxt_wdatam = wr_skid_buf_full ? wr_skid_buf : wb_data;

  assign wdatam_we = cg_en & (new_write_xfer | (wvalid_m & wready_m));

  always @(posedge clk)
  begin : s_wdata
    if (wdatam_we)
      wdata_m <= nxt_wdatam;
  end

  assign wstrb_m = {(AXI_DATA_WIDTH/8){1'b1}};


  assign bready_m = dev_run;

  always @(posedge clk or negedge reset_n)
  begin : s_bvalidm_q
    if (!reset_n)
      bvalidm_q <= 1'b0;
    else if (cg_en)
      bvalidm_q <= bvalid_m;
  end


  assign wb_req_ready = (nxt_mem_err && !wvalid_m) ?  1'b1 :
                                      nxt_tmc_enabled  ? ~wr_skid_buf_full
                                                   :  bvalidm_q;

  assign wb_req_ready_mask_trace_mem_full = ~circ_buf_mode &
                                            ~trace_mem_wr_thrshold_met &
                                            ~tmc_abort;

  assign trace_mem_wr_thrshold_met = rrp_rwp_diff_4kb_page | wr_burst_spc_avlbl
                                   | ( ft_stopped_q2
                                     & ({2'b00,wlen_rwp_dist_to_rrp} > {{6-WB_PTR_WIDTH{1'b0}},wb_fill_level})
                                     );

  assign rrp_rwp_diff_4kb_page = (rwp_word_addr_p[MEM_ADDR_WIDTH-1 : 12-PTR_PAD] !=
                                    rrp_word_addr_int[MEM_ADDR_WIDTH-1 : 12-PTR_PAD]);

  assign rwp_dist_to_rrp_same_page = (rrp_word_addr_int[11-PTR_PAD:0] - rwp_word_addr_p[11-PTR_PAD:0]);

  assign wlen_rwp_dist_to_rrp = (rwp_dist_to_rrp_same_page >= {{(12-PTR_PAD-5){1'b0}}, 5'd16}) ?
                                   5'd16 : {1'b0, rwp_dist_to_rrp_same_page[3:0]};

  assign wr_burst_spc_avlbl = (wlen_rwp_dist_to_rrp > {1'b0, wr_burst_len}) |
                              (rwp_word_addr_p[11-PTR_PAD:0] > rrp_word_addr_int[11-PTR_PAD:0]) |
                              (trace_mem_empty & ~write_in_prog);

  assign max_outstndg_wr_reached = (outstanding_wreq_cnt == 6'd32);


  assign wr_skid_buf_full_set = nxt_tmc_enabled & wb_req_valid & ~wr_skid_buf_full &
                                (( w_ch_busy) |
                                 ( write_last & ~write_start) |
                                 (~new_write_xfer & ~nxt_mem_err & ~wvalid_m));

  always @*
  begin : c_w_ch_busy
    case ({wvalid_m, awvalid_m})
      2'b00 :
        w_ch_busy = 1'b0;
      2'b01 :
        w_ch_busy = ~awready_m;
      2'b10 :
        w_ch_busy = ~wready_m;
      2'b11 :
        w_ch_busy = wlast_m ? (~wready_m | ~awready_m) : ~wready_m;
    endcase
  end

  assign wr_skid_buf_full_clr =  new_write_xfer |
                                (wvalid_m & wready_m & ~wlast_m) |
                                (nxt_mem_err & ~wvalid_m);

  assign nxt_wr_skid_buf_full =  wr_skid_buf_full_set |
                                (wr_skid_buf_full & ~wr_skid_buf_full_clr);

  assign wr_skid_buf_we = cg_en & wr_skid_buf_full_set;
  assign nxt_wr_skid_buf = wb_data;

  always @(posedge clk)
  begin : s_wr_skid_buf
    if (wr_skid_buf_we)
      wr_skid_buf <= nxt_wr_skid_buf;
  end

  always @(posedge clk or negedge reset_n)
  begin : s_wr_skid_buf_full
    if (!reset_n)
      wr_skid_buf_full <= 1'b0;
    else if (cg_en)
      wr_skid_buf_full <= nxt_wr_skid_buf_full;
  end


  assign outstanding_wreq_cnt_p_we = cg_en & (new_write_xfer_q | bvalidm_q);

  assign outstanding_wreq_cnt = (new_write_xfer_q && !bvalidm_q) ? (outstanding_wreq_cnt_p + 6'b1)
                                                                 :  outstanding_wreq_cnt_p;

  always @*
  begin : c_nxt_outstanding_wreq_cnt_p
    case ({new_write_xfer_q, bvalidm_q})
      2'b10 :
        nxt_outstanding_wreq_cnt_p = (outstanding_wreq_cnt_p + 6'b1);

      2'b01 :
        nxt_outstanding_wreq_cnt_p = (outstanding_wreq_cnt_p - 6'b1);

      2'b11,
      2'b00 :
        nxt_outstanding_wreq_cnt_p = outstanding_wreq_cnt_p;
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : s_outstanding_wreq_cnt_p
    if (!reset_n)
      outstanding_wreq_cnt_p <= 6'b0;
    else if (outstanding_wreq_cnt_p_we)
      outstanding_wreq_cnt_p <= nxt_outstanding_wreq_cnt_p;
  end

  assign outstanding_wreq_cnt_eq0 = ~|outstanding_wreq_cnt;

  assign axi_intf_ready =  ~tmc_enabled | (  outstanding_wreq_cnt_eq0 &
                                           ~(write_data_avlbl | write_in_prog) &
                                           ~(rb_req_valid | read_in_prog));

  assign nxt_mem_err = ~mem_err_clr &
                       (mem_err | (nxt_rb_rdata_valid & rresp_m[1]) |
                                  (bvalid_m & bresp_m[1]) |
                                  ((write_init_req | mem_rd_init_req) & mem_err_auth));

  assign mem_err_auth = ~(dbgen_q & (spiden_q | axictl_prot_ctrl[1]));

  always @(posedge clk or negedge reset_n)
  begin : s_mem_err
    if (!reset_n)
      mem_err <= 1'b0;
    else if (cg_en)
      mem_err <= nxt_mem_err;
  end


  assign dba_min = dba[MEM_BYTE_ADDR_WIDTH-1:PTR_PAD];

  generate
    if (AXI_ADDR_WIDTH > 32)
    begin : dba_max_axiaw_gt32
      assign nxt_dba_max_byte_addr = dba +
                                     {{(HI_ADDR_WIDTH-1){1'b0}}, rsz, 2'b00} -
                                     {{(MEM_BYTE_ADDR_WIDTH-1){1'b0}}, 1'b1};
    end

    else
    begin : dba_max_axiaw_eq32
      wire dummy_net;
      assign {dummy_net,
              nxt_dba_max_byte_addr} = {1'b0, dba} +
                                       {rsz, 2'b00} -
                                       {{(1+MEM_BYTE_ADDR_WIDTH-1){1'b0}}, 1'b1};
    end
  endgenerate

  assign nxt_dba_max = nxt_dba_max_byte_addr[MEM_BYTE_ADDR_WIDTH-1:PTR_PAD];

  always @(posedge clk or negedge reset_n)
  begin : s_dba_max
    if (!reset_n)
      dba_max  <= {MEM_ADDR_WIDTH{1'b0}};
    else if (ctl_trace_capt_en_rise_pre)
      dba_max <= nxt_dba_max;
  end


  assign mem_rd_init_req = rb_req_valid & rb_req_ready;
  assign mem_rd_en = cg_en & mem_rd_init_req & ~mem_err_auth & ~mem_err;

  assign nxt_rb_req_ready = ~(nxt_tmc_enabled & ~ctl_trace_capt_en_rise & trace_mem_empty_compl);

  assign trace_mem_empty_compl = (c_buf_level <= pend_level);

  always @(posedge clk or negedge reset_n)
  begin : s_rb_req_ready
    if (!reset_n)
      rb_req_ready <= 1'b0;
    else if (cg_en)
      rb_req_ready <= nxt_rb_req_ready;
  end

  assign nxt_arvalidm = mem_rd_en | (arvalid_m & ~arready_m);

  always @(posedge clk or negedge reset_n)
  begin : s_arvalidm
    if (!reset_n)
      arvalid_m <= 1'b0;
    else if (cg_en)
      arvalid_m <= nxt_arvalidm;
  end

  assign nxt_araddrm = rrp_word_addr_int;

  assign nxt_arcachem = axictl_rcache;

  assign nxt_arprotm = axictl_prot_ctrl;

  assign ar_ch_we = mem_rd_en;

  always @(posedge clk)
  begin : s_ar
    if (ar_ch_we)
      begin
        araddr_m_int  <= nxt_araddrm;
        arcache_m_int <= nxt_arcachem;
        arprot_m_int  <= nxt_arprotm;
      end
  end

  assign araddr_m  = {araddr_m_int,{PTR_PAD{1'b0}}};
  assign arcache_m =  arcache_m_int;
  assign arprot_m  = {1'b0,arprot_m_int};


  assign arlock_m = AXI_LOCK_NORMAL;
  assign arlen_m = AXI_BURST_LEN_1;
  assign arsize_m = AXI_SIZE_VAL;
  assign arburst_m = AXI_BURST_TYPE_INCR;


  assign rready_m = dev_run;


  assign nxt_read_in_prog = mem_rd_en | (read_in_prog & ~rvalid_m);

  always @(posedge clk or negedge reset_n)
  begin : s_rd_in_prog
    if (!reset_n)
      read_in_prog <= 1'b0;
    else if (cg_en)
      read_in_prog <= nxt_read_in_prog;
  end

  assign nxt_rb_rdata_valid = (read_in_prog & rvalid_m) |
                               rd_auth_err |
                               mem_rd_init_err;

  assign rd_auth_err = rb_req_valid & rb_req_ready & mem_err_auth;
  assign mem_rd_init_err = mem_rd_init_req & mem_err;

  always @(posedge clk or negedge reset_n)
  begin : s_rb_rdata_valid
    if (!reset_n)
      rb_rdata_valid <= 1'b0;
    else if (cg_en)
      rb_rdata_valid <=  nxt_rb_rdata_valid;
  end

  always @(posedge clk or negedge reset_n)
  begin : s_rb_rdata
    if (!reset_n)
      rb_data <= {WB_DATA_WIDTH{1'b0}};
    else if (cg_en && nxt_rb_rdata_valid)
      rb_data <= rdata_m;
  end


  assign rrp_incr_fol = nxt_tmc_enabled & (circ_buf_mode | tmc_abort) &
                        full & (rwp_word_addr_int == rrp_word_addr_int) & rwp_incr;

  generate
    if (AXI_DATA_WIDTH == 32)
    begin : gen_rrp_incr_axi_a
      wire [1:0] dummy_net;
      assign dummy_net = {apb_wdata_p[2],apb_read_fifo_rrp_en};

      assign rrp_incr = (rb_rdata_valid & ~mem_err) | rrp_incr_fol;
    end

    else if (AXI_DATA_WIDTH == 64)
    begin : gen_rrp_incr_axi_b
      wire [1+PTR_PAD-1:0] dummy_net;
      assign dummy_net = {apb_wdata_p[2],nxt_dba_max_byte_addr[PTR_PAD-1:0]};

      assign rrp_incr = apb_read_fifo_rrp_en | rrp_incr_fol;
    end

    else if (AXI_DATA_WIDTH == 128)
    begin : gen_rrp_incr_axi_c
      wire [1+PTR_PAD-1:0] dummy_net;
      assign dummy_net = {apb_wdata_p[2],nxt_dba_max_byte_addr[PTR_PAD-1:0]};

      assign rrp_incr = apb_read_fifo_rrp_en | rrp_incr_fol;
    end

  endgenerate

  generate
    if (AXI_ADDR_WIDTH > 32)
    begin : gen_nxt_rrp_gt32
      always @*
      begin : c_nxt_rrp_word_addr_a
        if (ctl_trace_capt_en_rise)
          nxt_rrp_word_addr = rrp_word_addr_int;
        else
          case ({(sw_fifo_mode2 & nxt_tmc_enabled & ~tmc_abort),rrp_full_wr_en})
            2'b00 :
              nxt_rrp_word_addr = (rrp_word_addr == dba_max) ? dba_min :
                                    (rrp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1});
            2'b01 :
              nxt_rrp_word_addr = rrp_hi_wr_en ?
                                    {apb_wdata_p[HI_ADDR_WIDTH-1:0],
                                     rrp_word_addr[(MEM_ADDR_WIDTH-HI_ADDR_WIDTH)-1:0]} :
                                    {rrp_word_addr[MEM_ADDR_WIDTH-1 : (MEM_ADDR_WIDTH-HI_ADDR_WIDTH)],
                                     apb_wdata_p[31:PTR_PAD]};
            2'b10,
            2'b11 :
              nxt_rrp_word_addr = rurp_wr_valid ?
                                    rrp_word_addr
                                    - ({MEM_ADDR_WIDTH{rrp_wrap_around}} & rsz_ptr_cmp)
                                    + ({{(MEM_ADDR_WIDTH+PTR_PAD-21){1'b0}}, rurp_wdata_words}) :
                                    rrp_word_addr;
          endcase
      end
    end

    else
    begin : gen_nxt_rrp_eq32
      always @*
      begin : c_nxt_rrp_word_addr_b
        if (ctl_trace_capt_en_rise)
          nxt_rrp_word_addr = rrp_word_addr_int;
        else
          case ({(sw_fifo_mode2 & nxt_tmc_enabled & ~tmc_abort), rrp_full_wr_en})
            2'b00 :
              nxt_rrp_word_addr = (rrp_word_addr == dba_max) ? dba_min :
                                    (rrp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1});
            2'b01 :
              nxt_rrp_word_addr = apb_wdata_p[31:PTR_PAD];
            2'b10,
            2'b11 :
              nxt_rrp_word_addr = rurp_wr_valid ?
                                    rrp_word_addr
                                    - ({MEM_ADDR_WIDTH{rrp_wrap_around}} & rsz_ptr_cmp)
                                    + ({{(MEM_ADDR_WIDTH+PTR_PAD-21){1'b0}}, rurp_wdata_words}) :
                                    rrp_word_addr;
          endcase
      end
    end
  endgenerate

  assign rurp_wdata_bytes = {apb_wdata_p[20:4],4'h0};

  assign rurp_wdata_words = rurp_wdata_bytes[20:PTR_PAD];

  assign rurp_wr_valid = (sw_fifo_mode2 & rurp_wr_en) &
                         (rurp_wdata_bytes[20] ^ (|rurp_wdata_bytes[19:4])) &
                         ({12'b0,rurp_wdata_bytes[20:0]} <= {rsz,2'b00});

  assign rrp_wrap_around = dba_max_minus_rrp_word_addr_int <
                           {{(MEM_ADDR_WIDTH+PTR_PAD-21){1'b0}}, rurp_wdata_words};
  assign dba_max_minus_rrp_word_addr_int = (dba_max - rrp_word_addr_int);
  assign rrp_we = cg_en & (ctl_trace_capt_en_rise | rrp_incr | rrp_full_wr_en | rurp_wr_valid);

  assign rrp_full_wr_en = rrp_wr_en | ((AXI_ADDR_WIDTH > 32) && rrp_hi_wr_en);

  always @(posedge clk)
  begin : s_rrp_word_addr
    if (rrp_we)
      rrp_word_addr <= nxt_rrp_word_addr;
  end

  assign rrp_word_addr_int = rrp_word_addr & {MEM_ADDR_WIDTH{~unprog_rrphi & ~unprog_rrp}};

  assign rrp = {rrp_word_addr, {PTR_PAD{1'b0}}};


  generate
    if (AXI_ADDR_WIDTH > 32)
    begin : gen_nxt_rwp_gt32
      always @*
      begin : c_nxt_rwp_word_addr_a
        if (ctl_trace_capt_en_rise)
          nxt_rwp_word_addr = rwp_word_addr_int;
        else
          case (rwp_full_wr_en)
            1'b0 :
              nxt_rwp_word_addr = rwp_eq_dba_max ? dba_min :
                                   (rwp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1});
            1'b1 :
              nxt_rwp_word_addr = rwp_hi_wr_en ?
                                    {apb_wdata_p[HI_ADDR_WIDTH-1:0],
                                     rwp_word_addr[(MEM_ADDR_WIDTH-HI_ADDR_WIDTH)-1:0]} :
                                    {rwp_word_addr[MEM_ADDR_WIDTH-1 : (MEM_ADDR_WIDTH-HI_ADDR_WIDTH)],
                                     apb_wdata_p[31:PTR_PAD]};
          endcase
      end
    end

    else
    begin : gen_nxt_rwp_eq32
      always @*
      begin : c_nxt_rwp_word_addr_b
        if (ctl_trace_capt_en_rise)
          nxt_rwp_word_addr = rwp_word_addr_int;
        else
          case (rwp_full_wr_en)
            1'b0 :
              nxt_rwp_word_addr = rwp_eq_dba_max ? dba_min :
                                   (rwp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1});
            1'b1 :
              nxt_rwp_word_addr = apb_wdata_p[31:PTR_PAD];
          endcase
      end
    end
  endgenerate

  assign rwp_we = cg_en & (ctl_trace_capt_en_rise | rwp_incr | rwp_full_wr_en);

  assign rwp_incr = wvalid_m & wready_m;

  assign rwp_full_wr_en = rwp_wr_en | ((AXI_ADDR_WIDTH > 32) && rwp_hi_wr_en);

  always @(posedge clk)
  begin : s_rwp_word_addr
    if (rwp_we)
      rwp_word_addr <= nxt_rwp_word_addr;
  end

  assign rwp_word_addr_int = rwp_word_addr & {MEM_ADDR_WIDTH{~unprog_rwphi & ~unprog_rwp}};

  assign rwp = {rwp_word_addr,{PTR_PAD{1'b0}}};


  assign nxt_rwp_word_addr_p1 = ctl_trace_capt_en_rise ? (rwp_eq_dba_max ? dba_min : (rwp_word_addr_int + {{(MEM_ADDR_WIDTH-1){1'b0}}, 1'b1})) :
                                                         (rwp_p1_eq_dba_max ?  dba_min : (rwp_word_addr_p1 + {{(MEM_ADDR_WIDTH-1){1'b0}}, 1'b1}));

  assign rwp_word_addr_p1_we = cg_en & (rwp_incr | ctl_trace_capt_en_rise);

  always @(posedge clk or negedge reset_n)
  begin : s_rwp_word_addr_p1
    if (!reset_n)
      rwp_word_addr_p1 <= {MEM_ADDR_WIDTH{1'b0}};
    else if (rwp_word_addr_p1_we)
      rwp_word_addr_p1 <= nxt_rwp_word_addr_p1;
  end

  assign rwp_word_addr_p = (rsz_single_word || !wvalid_m) ?
                              rwp_word_addr_int : rwp_word_addr_p1;


  generate
    if (AXI_DATA_WIDTH == 32)
    begin : gen_rsz_one_32
      assign nxt_rsz_single_word = nxt_tmc_enabled & (rsz == 31'h0000_0001);
    end

    else if (AXI_DATA_WIDTH == 64)
    begin : gen_rsz_one_64
      assign nxt_rsz_single_word = nxt_tmc_enabled & (rsz == 31'h0000_0002);
    end

    else
    begin : gen_rsz_one_128
      assign nxt_rsz_single_word = nxt_tmc_enabled & (rsz == 31'h0000_0004);
    end
  endgenerate

  always @(posedge clk or negedge reset_n)
  begin : s_rsz_one
    if (!reset_n)
      rsz_single_word <= 1'b0;
    else if (cg_en && ctl_trace_capt_en_rise)
      rsz_single_word <= nxt_rsz_single_word;
  end

  generate
    if (AXI_ADDR_WIDTH == 32) begin : gen_rsz_cmp_axiaw_32
      assign rsz_ptr_cmp = {rsz[29:(PTR_PAD-2)]};
    end else begin : gen_rsz_cmp_axiaw_gt32
      assign rsz_ptr_cmp = {{MEM_ADDR_WIDTH+PTR_PAD-33{1'b0}}, {rsz[30:(PTR_PAD-2)]}};
    end
  endgenerate


  assign trace_mem_space_thrshold = rsz - ({1'b0, buf_wm} & BUF_LEVEL_CMP_MASK);

  generate
    if (AXI_DATA_WIDTH == 32)
    begin : gen_cbuflevel_compare_a
      assign nxt_c_buf_level_gr_eq_thrshold = (nxt_c_buf_level_r >= trace_mem_space_thrshold);
    end

    else
    begin : gen_cbuflevel_compare_b
      assign nxt_c_buf_level_gr_eq_thrshold = ({nxt_c_buf_level_r,{BUF_LEVEL_PAD{1'b0}}} >= trace_mem_space_thrshold);
    end
  endgenerate

  assign rwp_eq_dba_max    = (rwp_word_addr_int == dba_max);
  assign rwp_p1_eq_dba_max = (rwp_word_addr_p1  == dba_max);
  assign rwp_gt_rrp        = (rwp_word_addr_int >  rrp_word_addr_int);
  assign rwp_eq_rrp        = (rwp_word_addr_int == rrp_word_addr_int);
  assign rwp_lt_rrp        = ~rwp_gt_rrp & ~rwp_eq_rrp;


  always @*
  begin : c_sts_full_set_clr
    case ({tmc_enabled, circ_buf_mode})
      2'b00, 2'b01 :
        begin
          sts_full_set = sts_full_wr_en ?  apb_wdata_p[0] : 1'b0      ;
          sts_full_clr = sts_full_wr_en ? ~apb_wdata_p[0] : unprog_sts;
        end
      2'b10 :
        begin
          sts_full_set =  nxt_c_buf_level_gr_eq_thrshold & ~unprog_sts;
          sts_full_clr = ~nxt_c_buf_level_gr_eq_thrshold | unprog_sts;
        end
      2'b11 :
        begin
          sts_full_set = rwp_incr & rwp_eq_dba_max & ~unprog_sts;
          sts_full_clr = unprog_sts;
        end
    endcase
  end

  assign sts_full_update = cg_en & (sts_full_set | sts_full_clr);
  assign nxt_sts_full = sts_full_set & ~sts_full_clr;

  always @(posedge clk)
  begin : s_sts_full
    if (sts_full_update)
      sts_full <= nxt_sts_full;
  end

  assign sts_full_int = sts_full & ~unprog_sts;

  assign nxt_full = itctrl_ime ? (it_evt_intr_wr_en ? apb_wdata_p[1] : full)
                               : (nxt_tmc_enabled & (sts_full_set | (sts_full & ~sts_full_clr)));

  always @(posedge clk or negedge reset_n)
  begin : s_full
    if (!reset_n)
      full <= 1'b0;
    else if (cg_en)
      full <= nxt_full;
  end

  assign nxt_bufintr = itctrl_ime ? (it_evt_intr_wr_en ? apb_wdata_p[3] : bufintr)
                                  : (nxt_tmc_enabled & (sts_full_set | (sts_full & ~sts_full_clr)));

  always @(posedge clk or negedge reset_n)
  begin : s_bufintr
    if (!reset_n)
      bufintr <= 1'b0;
    else if (cg_en)
      bufintr <= nxt_bufintr;
  end

  assign trace_mem_empty_we = cg_en & c_buf_level_we;
  assign nxt_trace_mem_empty = (nxt_c_buf_level_r == {BUF_LEVEL_WIDTH{1'b0}});

  always @ (posedge clk or negedge reset_n)
  begin : s_trace_mem_empty
    if (!reset_n)
      trace_mem_empty <= 1'b1;
    else if (trace_mem_empty_we)
      trace_mem_empty <= nxt_trace_mem_empty;
  end


  assign c_buf_level_we = cg_en & (rurp_wr_valid | rrp_incr | rwp_incr | ctl_trace_capt_en_rise | ptr_prog);

  assign init_buf_level_expanded = rwp_gt_rrp ? {1'b0,rwp_word_addr_int} - {1'b0,rrp_word_addr_int} :
                                   rwp_lt_rrp ? {1'b0,rsz_ptr_cmp}       - {1'b0,rrp_word_addr_int} + {1'b0,rwp_word_addr_int}
                                              : {MEM_ADDR_WIDTH+1{sts_full_int}} & {1'b0,rsz_ptr_cmp};

  always @*
  begin : c_nxt_cbuflevel_r
    if (ctl_trace_capt_en_rise || ptr_prog)
      nxt_c_buf_level_r = init_buf_level_expanded[BUF_LEVEL_WIDTH-1:0];
    else
      case ({rurp_wr_valid, rrp_incr, rwp_incr})
        3'b000,
        3'b011 :
                 nxt_c_buf_level_r = c_buf_level_r_int;
        3'b001 :
                 nxt_c_buf_level_r = c_buf_level_r_int + {{BUF_LEVEL_WIDTH-1{1'b0}},1'b1};
        3'b010 :
                 nxt_c_buf_level_r = trace_mem_empty ? c_buf_level_r_int
                                   :                   c_buf_level_r_int - {{BUF_LEVEL_WIDTH-1{1'b0}},1'b1};
        3'b100,3'b110 :
                 nxt_c_buf_level_r = c_buf_level_r - {{BUF_LEVEL_WIDTH+PTR_PAD-21{1'b0}}, rurp_wdata_words};
        3'b101,3'b111 :
                 nxt_c_buf_level_r = c_buf_level_r - {{BUF_LEVEL_WIDTH+PTR_PAD-21{1'b0}}, rurp_wdata_words}
                                                   + {{BUF_LEVEL_WIDTH-1{1'b0}},1'b1};
       default :
                 nxt_c_buf_level_r = {BUF_LEVEL_WIDTH{1'bx}};
      endcase
  end

  always @(posedge clk)
  begin : s_cbuflevel_r
    if (c_buf_level_we)
      c_buf_level_r <= nxt_c_buf_level_r;
  end

  assign c_buf_level_r_int = c_buf_level_r & ~{BUF_LEVEL_WIDTH{unprog_rrp & unprog_rwp}};

  generate
    if (AXI_DATA_WIDTH == 32)
    begin : gen_cbuflevel_a
      assign c_buf_level = c_buf_level_r;
    end

    else
    begin : gen_cbuflevel_b
      assign c_buf_level = {c_buf_level_r,{BUF_LEVEL_PAD{1'b0}}};
    end
  endgenerate

  assign l_buf_level_we = cg_en & (ctl_trace_capt_en_rise | ptr_prog | l_buf_level_upd | (l_buf_level_rd_done & ~l_buf_level_upd_q));

  assign l_buf_level_upd = nxt_tmc_enabled & rwp_incr & (nxt_c_buf_level_r > l_buf_level_r_int);

  assign nxt_l_buf_level_r = nxt_c_buf_level_r;

  always @(posedge clk)
  begin : s_lbuflevel_r
    if (l_buf_level_we)
      l_buf_level_r <=  nxt_l_buf_level_r;
  end

  assign l_buf_level_r_int = l_buf_level_r & ~{BUF_LEVEL_WIDTH{unprog_rrp | unprog_rwp | unprog_rrphi | unprog_rwphi}};

  generate
    if (AXI_DATA_WIDTH == 32)
    begin : gen_lbuflevel_a
      assign l_buf_level = l_buf_level_r;
    end

    else
    begin : gen_lbuflevel_b
      assign l_buf_level = {l_buf_level_r,{BUF_LEVEL_PAD{1'b0}}};
    end
  endgenerate

  always @(posedge clk or negedge reset_n)
  begin : s_lbuflevel_upd_q
    if (!reset_n)
      l_buf_level_upd_q <= 1'b0;
    else if (cg_en)
      l_buf_level_upd_q <= l_buf_level_upd;
  end

  generate
    if (AXI_DATA_WIDTH == 32)
    begin : pend_level_a
      always @*
      begin : c_pend_level
        case (wr_burst_len)
          4'b0000 : pend_level = {25'b0, outstanding_wreq_cnt};
          4'b0001 : pend_level = {24'b0, outstanding_wreq_cnt, 1'b0};

          4'b0010,
          4'b0011 : pend_level = {23'b0, outstanding_wreq_cnt, 2'b0};

          4'b0100,
          4'b0101,
          4'b0110,
          4'b0111 : pend_level = {22'b0, outstanding_wreq_cnt, 3'b0};

          4'b1000,
          4'b1001,
          4'b1010,
          4'b1011,
          4'b1100,
          4'b1101,
          4'b1110,
          4'b1111 : pend_level = {21'b0, outstanding_wreq_cnt, 4'b0};
        endcase
      end
    end

    else if (AXI_DATA_WIDTH == 64)
    begin : pend_level_b
      always @*
      begin : c_pend_level
        case (wr_burst_len)
          4'b0000 : pend_level = {24'b0, outstanding_wreq_cnt, 1'b0};
          4'b0001 : pend_level = {23'b0, outstanding_wreq_cnt, 2'b0};

          4'b0010,
          4'b0011 : pend_level = {22'b0, outstanding_wreq_cnt, 3'b0};

          4'b0100,
          4'b0101,
          4'b0110,
          4'b0111 : pend_level = {21'b0, outstanding_wreq_cnt, 4'b0};

          4'b1000,
          4'b1001,
          4'b1010,
          4'b1011,
          4'b1100,
          4'b1101,
          4'b1110,
          4'b1111 : pend_level = {20'b0, outstanding_wreq_cnt, 5'b0};
        endcase
      end
    end

    else
    begin : pend_level_c
      always @*
      begin : c_pend_level
        case (wr_burst_len)
          4'b0000 : pend_level = {23'b0, outstanding_wreq_cnt, 2'b0};
          4'b0001 : pend_level = {22'b0, outstanding_wreq_cnt, 3'b0};

          4'b0010,
          4'b0011 : pend_level = {21'b0, outstanding_wreq_cnt, 4'b0};

          4'b0100,
          4'b0101,
          4'b0110,
          4'b0111 : pend_level = {20'b0, outstanding_wreq_cnt, 5'b0};

          4'b1000,
          4'b1001,
          4'b1010,
          4'b1011,
          4'b1100,
          4'b1101,
          4'b1110,
          4'b1111 : pend_level = {19'b0, outstanding_wreq_cnt, 6'b0};
        endcase
      end
    end
  endgenerate

  assign nxt_fl_outstanding_wreq_cnt = nxt_mem_err         ?  6'b0 :
                                       fl_wreq_cnt_load_en ?  fl_wreq_cnt_load_val :
                                       fl_wreq_cnt_decr    ? (fl_outstanding_wreq_cnt - 6'b1) :
                                                              fl_outstanding_wreq_cnt;

  assign fl_wreq_cnt_load_en = (wb_flush_req & wb_flush_ack & ~nxt_wr_skid_buf_full) |
                               (mem_flush_req & skid_fl_pend & ~nxt_wr_skid_buf_full);

  assign fl_wreq_cnt_decr = bvalidm_q & (|fl_outstanding_wreq_cnt);

  assign fl_wreq_cnt_load_val = new_write_xfer ? nxt_outstanding_wreq_cnt_p + 6'b1
                                               : nxt_outstanding_wreq_cnt_p;

  assign fl_outstanding_wreq_cnt_we = cg_en & (fl_wreq_cnt_load_en | bvalidm_q | nxt_mem_err);

  always @(posedge clk or negedge reset_n)
  begin : s_fl_outstnd
    if (!reset_n)
      fl_outstanding_wreq_cnt <= 6'b0;
    else if (fl_outstanding_wreq_cnt_we)
      fl_outstanding_wreq_cnt <= nxt_fl_outstanding_wreq_cnt;
  end

  assign nxt_skid_fl_pend = (wb_flush_req & wb_flush_ack & nxt_wr_skid_buf_full) |
                            (skid_fl_pend & nxt_wr_skid_buf_full);

  assign nxt_mem_flush_ack =  mem_flush_req & ~mem_flush_ack &
                             ~skid_fl_pend &
                             ~|fl_outstanding_wreq_cnt;

  always @(posedge clk or negedge reset_n)
  begin : s_mem_flush
    if (!reset_n)
      begin
        mem_flush_ack <= 1'b0;
        skid_fl_pend  <= 1'b0;
      end
    else if (cg_en)
      begin
        mem_flush_ack <= nxt_mem_flush_ack;
        skid_fl_pend  <= nxt_skid_fl_pend;
      end
  end


endmodule
