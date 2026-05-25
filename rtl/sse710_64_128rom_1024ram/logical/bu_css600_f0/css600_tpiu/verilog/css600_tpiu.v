//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2020 Arm Limited or its affiliates.
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
//   Top level of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu #(parameter
  FF_SYNC_DEPTH  = 2,
  REVAND         = 4'h0
)
(
      clk,
      reset_n,
      pwakeup_s,
      psel_s,
      penable_s,
      pwrite_s,
      paddr_s,
      pwdata_s,
      prdata_s,
      pready_s,
      pslverr_s,
      atwakeup_s,
      atid_s,
      atdata_s,
      atbytes_s,
      atvalid_s,
      atready_s,
      afvalid_s,
      afready_s,
      syncreq_s,
      traceclk_in_qactive,
      traceclk_in,
      treset_n,
      traceclk,
      tracedata,
      tracectl,
      trigin,
      flushin,
      flushcomp,
      clk_qreq_n,
      clk_qaccept_n,
      clk_qdeny,
      clk_qactive,
      extctl_in,
      extctl_out,
      dftcgen,
      tpctl_valid,
      tp_maxdatasize
);

  localparam ATB_DATA_WIDTH_INT = 32;

  localparam FF_SYNC_DEPTH_INT  = (FF_SYNC_DEPTH == 3) ? 3 : 2;

  localparam ATBYTES_WIDTH      = (ATB_DATA_WIDTH_INT == 32) ? 2 : 1;

  localparam WORD_WIDTH         = (ATB_DATA_WIDTH_INT == 8)  ? 4
                                : (ATB_DATA_WIDTH_INT == 16) ? 3
                                :                              2
                                ;
  input  wire                          clk;
  input  wire                          reset_n;

  input  wire                          pwakeup_s;
  input  wire                          psel_s;
  input  wire                          penable_s;
  input  wire                          pwrite_s;
  input  wire [11:0]                   paddr_s;
  input  wire [31:0]                   pwdata_s;
  output wire [31:0]                   prdata_s;
  output wire                          pready_s;
  output wire                          pslverr_s;

  input  wire                          atwakeup_s;
  input  wire [6:0]                    atid_s;
  input  wire [ATB_DATA_WIDTH_INT-1:0] atdata_s;
  input  wire [ATBYTES_WIDTH-1:0]      atbytes_s;
  input  wire                          atvalid_s;
  output wire                          atready_s;
  output wire                          afvalid_s;
  input  wire                          afready_s;
  output wire                          syncreq_s;

  output wire                          traceclk_in_qactive;
  input  wire                          traceclk_in;
  input  wire                          treset_n;
  output wire                          traceclk;
  output wire [31:0]                   tracedata;
  output wire                          tracectl;

  input  wire                          trigin;
  input  wire                          flushin;
  output wire                          flushcomp;

  input  wire                          clk_qreq_n;
  output wire                          clk_qaccept_n;
  output wire                          clk_qdeny;
  output wire                          clk_qactive;

  input  wire [7:0]                    extctl_in;
  output wire [7:0]                    extctl_out;

  input  wire                          dftcgen;

  input  wire                          tpctl_valid;
  input  wire [4:0]                    tp_maxdatasize;


  `include "css600_tpiu_localparams.v"

  wire                              tp_xfer_req;
  wire                              tp_xfer_type;
  wire [1:0]                        tp_addr_enc;
  wire [31:0]                       tp_wdata;
  wire                              tp_xfer_ack;
  wire [31:0]                       tp_rdata;

  wire                              trg_wr_en;
  wire [38:0]                       trg_wdata;
  wire                              trg_done;
  wire                              sts_running;
  wire                              sts_triggered;
  wire                              sts_triggered_clr;
  wire                              flush_fsm_busy;
  wire                              flush_pend;

  wire                              ffcr_embed_flush_masked;
  wire                              ffcr_stop_trig;
  wire                              ffcr_stop_flush;
  wire                              ffcr_trig_on_fl;
  wire                              ffcr_trig_evt;
  wire                              ffcr_trig_in;
  wire                              ffcr_flush_man;
  wire                              ffcr_fl_on_trig;
  wire                              ffcr_flush_in;
  wire                              ffcr_en_fcont;
  wire                              ffcr_en_formatting_masked;

  wire  [3:0]                       w_revand;

  wire                              itctrl_ime;
  wire                              integ_mode_entry;
  wire                              ittrflin_rd_en;
  wire                              itatbctr2_wr_en;
  wire                              itoutctr_wr_en;
  wire [6:0]                        it_atid;
  wire [1:0]                        it_atbytes;
  wire [4:0]                        it_atdata;
  wire                              it_atvalid;
  wire                              it_afready;
  wire                              it_atwakeup;
  wire                              it_syncreq;
  wire                              it_trigin;
  wire                              it_flushin;

  wire                              trg_zero;
  wire                          nxt_trg_evt_active;
  wire                              ft_retrig_req;
  wire                              ft_trig_req;
  wire [1:0]                        ft_trig_size;
  wire                              ft_trig_ack;


  wire                              ft_flush_req;
  wire                              ft_flush_ack;
  wire                              ft_flid_req;
  wire                              ft_flid_ack;
  wire                          nxt_wb_flush_req;
  wire                              wb_flush_ack;
  wire                              ft_stop_req;
  wire                              ft_stopped;
  wire                              ft_starting;
  wire                              ft_stopped_done;
  wire                          nxt_stop_pending;
  wire                              stop_pending;
  wire [1:0]                        stop_state;
  wire                              st_on_trig_active;
  wire                              st_on_fl_active;
  wire                              st_trig_pend;
  wire                              ft_trig_pend;
  wire                              st_fl_pend;
  wire                              atbs_flush_done;
  wire                              nxt_flush_wait;
  wire                              flush_wait;
  wire                              hold_trig_req;
  wire                          nxt_t_on_trig_in_pend;
  wire                              t_on_trig_in_pend;
  wire                              trigin_rise;
  wire                              trig_pkt_wait;
  wire                              trig_pkt_wait_done;
  wire                          nxt_trig_in_wait;
  wire                              trig_in_wait;
  wire                              trig_in_wait_done;
  wire                              trg_ctr_decr_pulse;
  wire [ATBYTES_WIDTH:0]            trg_ctr_decr_val;
  wire                              trg_ctr_decr_fcb;

  wire                              trig_port_cdc_t;
  wire                              trig_port_done;
  wire                              ffcr_flush_man_clr;

  wire [ATB_DATA_WIDTH_INT-1:0]     ft_data;
  wire                              ft_data_padded;
  wire                              ft_data_beacon;
  wire                              ft_data_valid;
  wire                              wb_ready;
  wire                          nxt_wb_ready;

  wire [3:0]                        wr_ptr_gray;
  wire [3:0]                        rd_ptr_gray;
  wire [2*(FF_SYNC_DEPTH_INT+1)
       *(ATB_DATA_WIDTH_INT+2)-1:0] fifo_data;
  wire [(ATB_DATA_WIDTH_INT+2)-1:0] fifo_r_data;
  wire                              pop_fifo;
  wire                              fifo_empty;

  wire                              reg_update;
  wire                              curr_psize_update;
  wire [31:0]                       curr_psize_masked;
  wire [31:0]                       port_bit_mask;
  wire [1:0]                        curr_patt_mode;
  wire [3:0]                        curr_patt_sel;
  wire [7:0]                        tprcr_pattcount;
  wire [11:0]                       fscr_synccount;

  wire [31:0]                       gen_data;
  wire                              trace_pattern;
  wire                              trace_pattern_falling;
  wire                              pattern_complete;
  wire                              pattern_done;

  wire [31:0]                       trace_d;
  wire                              trace_d_valid;
  wire                              trace_d_ready;
  wire                              trace_d_stopped;

  wire                              trace_flush_req;
  wire                              trace_flush_ack;
  wire                              trace_idle;
  wire                              trace_idle_hsp;
  wire [1:0]                        trace_stop_state;

  wire                              tp_xfer_req_sync;
  wire                              tp_xfer_type_sync;
  wire [1:0]                        tp_addr_enc_sync;
  wire [31:0]                       tp_wdata_sync;
  wire                              tp_xfer_ack_sync;
  wire [31:0]                       tp_rdata_sync;

  wire [3:0]                        wr_ptr_gray_sync;
  wire [3:0]                        rd_ptr_gray_sync;

  wire                              trig_port_en;
  wire                              trig_port_sync;
  wire                              trig_port_done_sync;
  wire                              trig_port_clken;

  wire                              continuous_mode;

  wire                              atb_syncreq;
  wire                              atb_syncreq_sync;
  wire [1:0]                        pab_pulse_req;
  wire [1:0]                        pab_pulse_ack;
  wire                              pab_active;
  wire                              pab_tactive;
  wire [1:0]                        pstate;

  wire                              trigin_mon;
  wire                              trigin_q;
  wire                              flushin_mon;
  wire                              flushin_q;
  wire                              trig_flush_wake;

  wire                              clk_qreq_n_sync;
  wire                              dev_active;
  wire                              lp_request;
  wire                              lp_done;
  wire                              dev_run;
  wire                              cg_en/*verilator clock_enable*/;

  wire                              int_clk_en/*verilator clock_enable*/;
  wire                              clk_g;
  wire                              clk_r;
  wire                              traceclk_in_en_tdata;
  wire                              traceclk_in_en_tregs;
  wire                              traceclk_in_en/*verilator clock_enable*/;
  wire                              traceclk_in_g;


  css600_tpiu_apb_if
    u_css600_tpiu_apb_if
    (
      .clk                       (clk_r),
      .reset_n                   (reset_n),
      .psel_s                    (psel_s),
      .penable_s                 (penable_s),
      .pwrite_s                  (pwrite_s),
      .paddr_s                   (paddr_s),
      .pwdata_s                  (pwdata_s),
      .prdata_s                  (prdata_s),
      .pready_s                  (pready_s),
      .pslverr_s                 (pslverr_s),
      .pstate                    (pstate),

      .tp_xfer_req               (tp_xfer_req),
      .tp_xfer_type              (tp_xfer_type),
      .tp_addr_enc               (tp_addr_enc),
      .tp_wdata                  (tp_wdata),
      .tp_xfer_ack_sync          (tp_xfer_ack_sync),
      .tp_rdata_sync             (tp_rdata_sync),

      .dev_run                   (dev_run),

      .ft_stopped                (ft_stopped),
      .ft_stopped_done           (ft_stopped_done),
      .fl_in_prog                (flush_fsm_busy),
      .ffcr_flush_man_clr        (ffcr_flush_man_clr),
      .trg_wr_en                 (trg_wr_en),
      .trg_wdata                 (trg_wdata),
      .trg_done                  (trg_done),
      .sts_running               (sts_running),
      .sts_triggered             (sts_triggered),
      .sts_triggered_clr         (sts_triggered_clr),

      .tpctl_valid               (tpctl_valid),
      .tp_maxdatasize            (tp_maxdatasize),

      .extctl_out                (extctl_out),
      .extctl_in                 (extctl_in),

      .ffcr_embed_flush_masked   (ffcr_embed_flush_masked),
      .ffcr_stop_trig            (ffcr_stop_trig),
      .ffcr_stop_flush           (ffcr_stop_flush),
      .ffcr_trig_on_fl           (ffcr_trig_on_fl),
      .ffcr_trig_evt             (ffcr_trig_evt),
      .ffcr_trig_in              (ffcr_trig_in),
      .ffcr_flush_man            (ffcr_flush_man),
      .ffcr_fl_on_trig           (ffcr_fl_on_trig),
      .ffcr_flush_in             (ffcr_flush_in),
      .ffcr_en_fcont             (ffcr_en_fcont),
      .ffcr_en_formatting_masked (ffcr_en_formatting_masked),

      .itctrl_ime                (itctrl_ime),
      .integ_mode_entry          (integ_mode_entry),
      .ittrflin_rd_en            (ittrflin_rd_en),
      .it_trigin                 (it_trigin),
      .it_flushin                (it_flushin),
      .it_atdata                 (it_atdata),
      .it_syncreq                (it_syncreq),
      .itatbctr2_wr_en           (itatbctr2_wr_en),
      .itoutctr_wr_en            (itoutctr_wr_en),
      .it_atid                   (it_atid),
      .it_atbytes                (it_atbytes),
      .it_atwakeup               (it_atwakeup),
      .it_afready                (it_afready),
      .it_atvalid                (it_atvalid),

      .revand                    (w_revand)
    );

  css600_ecorevnum
  #(
     .WIDTH(4), .ECOREVVAL(REVAND)
  )
  u_css600_ecorevnum
  (
      .ecorevnum(w_revand)
  );


  assign trig_port_en = ~ffcr_en_fcont;
  css600_trace_formatter
  #(
    .FORMATTER_CONFIG              (4),
    .ATB_DATA_WIDTH                (ATB_DATA_WIDTH_INT),
    .ATBYTES_WIDTH                 (ATBYTES_WIDTH),
    .ITATBDATA0_WIDTH              (5)
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
      .ffcr_trig_on_trig_evt_masked  (ffcr_trig_evt),
      .ffcr_trig_on_trigin_masked    (ffcr_trig_in),
      .ffcr_flsh_on_trig_evt_masked  (ffcr_fl_on_trig),
      .hw_fifo_mode                  (1'b0),
      .stall_on_stop                 (1'b0),
      .sts_triggered_clr             (sts_triggered_clr),
      .ctl_trace_capt_en_rise        (ft_stopped_done),
      .frame_sync_req                (1'b0),
      .trigin_rise                   (trigin_rise),
      .trig_pkt_wait                 (trig_pkt_wait),
      .trig_pkt_wait_done            (trig_pkt_wait_done),
      .nxt_trig_in_wait              (nxt_trig_in_wait),
      .trig_in_wait                  (trig_in_wait),
      .trig_in_wait_done             (trig_in_wait_done),
      .trg_ctr_decr_pulse            (trg_ctr_decr_pulse),
      .trg_ctr_decr_val              (trg_ctr_decr_val),
      .trg_ctr_decr_fcb              (trg_ctr_decr_fcb),
      .ft_running                    (),
      .ft_stopped_q2                 (),
      .ft_fifo_beat                  (),
      .trig_port_en                  (trig_port_en),
      .trig_port_cdc_t               (trig_port_cdc_t),
      .trig_port_done_sync           (trig_port_done_sync),
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
      .ft_starting                   (ft_starting),
      .ft_stopped_done               (ft_stopped_done),
      .nxt_stop_pending              (nxt_stop_pending),
      .stop_pending                  (stop_pending),
      .st_fl_pend                    (st_fl_pend),
      .st_trig_pend                  (st_trig_pend),
      .ft_trig_pend                  (ft_trig_pend),
      .atbs_flush_done               (atbs_flush_done),
      .nxt_flush_wait                (nxt_flush_wait),
      .flush_wait                    (flush_wait),
      .hold_trig_req                 (hold_trig_req),
      .nxt_t_on_trig_in_pend         (nxt_t_on_trig_in_pend),
      .t_on_trig_in_pend             (t_on_trig_in_pend),
      .ft_data                       (ft_data),
      .ft_data_padded                (ft_data_padded),
      .ft_data_beacon                (ft_data_beacon),
      .ft_data_valid                 (ft_data_valid),
      .wb_ready                      (wb_ready),
      .nxt_wb_ready                  (nxt_wb_ready),
      .itctrl_ime                    (itctrl_ime),
      .integ_mode_entry              (integ_mode_entry),
      .it_atb_ctr_2_wr_en            (itatbctr2_wr_en),
      .it_atb_ctr_2_wdata            (pwdata_s[0]),
      .it_atb_data_0                 (it_atdata),
      .it_atids                      (it_atid),
      .it_atvalids                   (it_atvalid),
      .it_atbytess                   (it_atbytes),
      .dev_run                       (dev_run)
  );


  css600_trace_format_control
  #(
    .FORMATTER_CONFIG              (4),
    .FORMATTER_TRG_WIDTH           (39),
    .ATB_DATA_WIDTH                (32),
    .ATBYTES_WIDTH                 (ATBYTES_WIDTH)
  )
  u_css600_trace_format_control
  (
      .clk                              (clk_r),
      .cg_en                            (cg_en),
      .clk_g                            (clk_g),
      .reset_n                          (reset_n),
      .dev_run                          (dev_run),
      .ctl_trace_capt_en                (1'b1),
      .ctl_trace_capt_en_rise           (ft_stopped_done),
      .circ_buf_mode                    (1'b1),
      .hw_fifo_mode                     (1'b0),
      .ffcr_embed_flush_masked          (ffcr_embed_flush_masked),
      .ffcr_stop_on_trig_evt_masked     (ffcr_stop_trig),
      .ffcr_stop_on_trig_evt_masked_clr (~ffcr_stop_trig & ft_stopped),
      .ffcr_stop_on_fl                  (ffcr_stop_flush),
      .ffcr_stop_on_fl_clr              (~ffcr_stop_flush & ft_stopped),
      .ffcr_trig_on_fl_masked           (ffcr_trig_on_fl),
      .ffcr_trig_on_trig_evt_masked     (ffcr_trig_evt),
      .ffcr_trig_on_trigin_masked       (ffcr_trig_in),
      .ffcr_flsh_on_trig_evt_masked     (ffcr_fl_on_trig),
      .ffcr_flsh_on_flshin              (ffcr_flush_in),
      .ffcr_flush_man                   (ffcr_flush_man),
      .ffcr_en_trig_ins                 (1'b1),
      .ffcr_en_formatting_masked        (ffcr_en_formatting_masked),
      .trg_wr_en                        (trg_wr_en),
      .trg_wdata                        (trg_wdata),
      .unprog_trg                       (1'b0),
      .trg                              (),
      .trg_done                         (trg_done),
      .sts_running                      (sts_running),
      .sts_triggered                    (sts_triggered),
      .sts_triggered_clr                (sts_triggered_clr),
      .trigin                           (trigin),
      .flushin                          (flushin),
      .flushcomp                        (flushcomp),
      .trig_port_en                     (trig_port_en),
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
      .st_on_trig_active                (st_on_trig_active),
      .st_on_fl_active                  (st_on_fl_active),
      .st_trig_pend                     (st_trig_pend),
      .ft_trig_pend                     (ft_trig_pend),
      .st_fl_pend                       (st_fl_pend),
      .atbs_flush_done                  (atbs_flush_done),
      .nxt_flush_wait                   (nxt_flush_wait),
      .flush_wait                       (flush_wait),
      .hold_trig_req                    (hold_trig_req),
      .nxt_t_on_trig_in_pend            (nxt_t_on_trig_in_pend),
      .t_on_trig_in_pend                (t_on_trig_in_pend),
      .atready_s                        (atready_s),
      .afvalid_s                        (afvalid_s),
      .afready_s                        (afready_s),
      .nxt_wb_flush_req                 (nxt_wb_flush_req),
      .wb_flush_req                     (),
      .wb_flush_ack                     (wb_flush_ack),
      .mem_flush_req                    (),
      .mem_flush_ack                    (1'b1),
      .atbm_flush_valid                 (1'b0),
      .atbm_flush_ready                 (),
      .itctrl_ime                       (itctrl_ime),
      .it_evt_intr_wr_en                (itoutctr_wr_en),
      .it_evt_intr_wdata                (pwdata_s[0]),
      .it_tr_fl_in_rd_en                (ittrflin_rd_en),
      .it_atb_ctr_2_wr_en               (itatbctr2_wr_en),
      .it_atb_ctr_2_wdata               (pwdata_s[1]),
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
      .trace_mem_empty                  (1'b0),
      .flush_man_clr                    (ffcr_flush_man_clr),
      .flush_fsm_busy                   (flush_fsm_busy),
      .flush_pend                       (flush_pend),
      .mem_err                          (1'b0)
  );
  assign it_afready = afready_s;
  assign it_atwakeup = atwakeup_s;

  css600_tpiu_core_sync
    #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH_INT))
    u_css600_tpiu_core_sync
    (
      .clk                 (clk_r),
      .reset_n             (reset_n),
      .tp_xfer_ack         (tp_xfer_ack),
      .tp_xfer_ack_sync    (tp_xfer_ack_sync),
      .tp_rdata            (tp_rdata),
      .tp_rdata_sync       (tp_rdata_sync),

      .rd_ptr_gray         (rd_ptr_gray),
      .rd_ptr_gray_sync    (rd_ptr_gray_sync),

      .trig_port_done      (trig_port_done),
      .trig_port_done_sync (trig_port_done_sync)
    );


  css600_pulseasyncbridgeslv_qactive_only
  #(.WIDTH (2),
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT))
    u_css600_pulseasyncbridgeslv_sycnreq
    (
      .clk_s           (traceclk_in),
      .reset_s_n       (treset_n),

      .pulse_in        ({trace_flush_ack
                        ,atb_syncreq
                       }),

      .pulse_req       (pab_pulse_req),
      .pulse_ack       (pab_pulse_ack),

      .clk_s_qactive   (pab_tactive)
    );

  css600_pulseasyncbridgemstr_qactive_only
  #(.WIDTH (2),
    .FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT))
    u_css600_pulseasyncbridgemstr_syncreq
    (
      .clk_m           (clk),
      .reset_m_n       (reset_n),

      .pulse_out       ({wb_flush_ack
                        ,atb_syncreq_sync
                       }),

      .pulse_req       (pab_pulse_req),
      .pulse_ack       (pab_pulse_ack),

      .clk_m_qactive   (pab_active)
    );

  assign syncreq_s = itctrl_ime ? it_syncreq : atb_syncreq_sync;


  css600_tpiu_trace_sync
  #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH_INT))
    u_css600_tpiu_trace_sync
    (
      .traceclk_in           (traceclk_in),
      .treset_n              (treset_n),

      .trig_port_cdc_t       (trig_port_cdc_t),
      .trig_port_sync        (trig_port_sync),

      .tp_xfer_req           (tp_xfer_req),
      .tp_xfer_req_sync      (tp_xfer_req_sync),
      .tp_xfer_type          (tp_xfer_type),
      .tp_xfer_type_sync     (tp_xfer_type_sync),
      .tp_addr_enc           (tp_addr_enc),
      .tp_addr_enc_sync      (tp_addr_enc_sync),
      .tp_wdata              (tp_wdata),
      .tp_wdata_sync         (tp_wdata_sync),

      .wr_ptr_gray           (wr_ptr_gray),
      .wr_ptr_gray_sync      (wr_ptr_gray_sync)

    );


  css600_tpiu_reg_t
    u_css600_tpiu_reg_t
    (
      .traceclk_in           (traceclk_in_g),
      .treset_n              (treset_n),

      .tp_xfer_req_sync      (tp_xfer_req_sync),
      .tp_xfer_type_sync     (tp_xfer_type_sync),
      .tp_addr_enc_sync      (tp_addr_enc_sync),
      .tp_wdata_sync         (tp_wdata_sync),
      .tp_xfer_ack           (tp_xfer_ack),
      .tp_rdata              (tp_rdata),

      .pattern_done          (pattern_done),

      .reg_update            (reg_update),
      .curr_psize_update     (curr_psize_update),
      .curr_psize_masked     (curr_psize_masked),
      .port_bit_mask         (port_bit_mask),
      .curr_patt_mode        (curr_patt_mode),
      .curr_patt_sel         (curr_patt_sel),
      .tprcr_pattcount       (tprcr_pattcount),
      .fscr_synccount        (fscr_synccount)
    );


  css600_tpiu_atb_fifo
  #(.ATB_DATA_WIDTH(ATB_DATA_WIDTH_INT),
    .FF_SYNC_DEPTH(FF_SYNC_DEPTH_INT))
    u_css600_tpiu_atb_fifo
    (
      .clk                       (clk_r),
      .reset_n                   (reset_n),
      .dev_run                   (dev_run),
      .ffcr_en_formatting_masked (ffcr_en_formatting_masked),
      .ffcr_en_fcont             (ffcr_en_fcont),
      .ft_stopped                (ft_stopped),
      .ft_starting               (ft_starting),
      .ft_data                   (ft_data),
      .ft_data_padded            (ft_data_padded),
      .ft_data_beacon            (ft_data_beacon),
      .ft_data_valid             (ft_data_valid),
      .wb_ready                  (wb_ready),
      .nxt_wb_ready              (nxt_wb_ready),
      .stop_state                (stop_state),
      .st_on_trig_active         (st_on_trig_active),
      .st_on_fl_active           (st_on_fl_active),
      .st_trig_pend              (st_trig_pend),
      .ft_trig_pend              (ft_trig_pend),
      .st_fl_pend                (st_fl_pend),
      .nxt_wb_flush_req          (nxt_wb_flush_req),
      .wb_flush_ack              (wb_flush_ack),

      .rd_ptr_gray_sync          (rd_ptr_gray_sync),
      .wr_ptr_gray               (wr_ptr_gray),
      .fifo_data                 (fifo_data)
    );


  css600_tpiu_trace_fifo
  #(.ATB_DATA_WIDTH(ATB_DATA_WIDTH_INT),
    .FF_SYNC_DEPTH(FF_SYNC_DEPTH_INT))
    u_css600_tpiu_trace_fifo
    (
      .traceclk_in           (traceclk_in),
      .treset_n              (treset_n),
      .rd_ptr_gray           (rd_ptr_gray),
      .wr_ptr_gray_sync      (wr_ptr_gray_sync),
      .fifo_data             (fifo_data),
      .fifo_r_data           (fifo_r_data),
      .pop_fifo              (pop_fifo),
      .fifo_empty            (fifo_empty)
    );


  css600_tpiu_trace_bridge
  #(.ATB_DATA_WIDTH(ATB_DATA_WIDTH_INT))
    u_css600_tpiu_trace_bridge
    (
      .traceclk_in           (traceclk_in_g),
      .treset_n              (treset_n),
      .trace_d_valid         (trace_d_valid),
      .trace_d               (trace_d),
      .trace_d_stopped       (trace_d_stopped),
      .trace_d_ready         (trace_d_ready),
      .trace_flush_req       (trace_flush_req),
      .trace_flush_ack       (trace_flush_ack),
      .trace_idle            (trace_idle),
      .trace_idle_hsp        (trace_idle_hsp),
      .pab_tactive           (pab_tactive),
      .fifo_empty            (fifo_empty),
      .pop_fifo              (pop_fifo),
      .fifo_r_data           (fifo_r_data),
      .gen_data              (gen_data),
      .trace_pattern         (trace_pattern),
      .trace_pattern_falling (trace_pattern_falling),
      .trig_port_req         (trig_port_sync),
      .trig_port_done        (trig_port_done),
      .trig_port_clken       (trig_port_clken),
      .pattern_complete      (pattern_complete),
      .reg_update            (reg_update),
      .curr_patt_mode        (curr_patt_mode),
      .tprcr_pattcount       (tprcr_pattcount),
      .fscr_synccount        (fscr_synccount),
      .continuous_mode       (continuous_mode),
      .formatter_enable      (),
      .atb_syncreq           (atb_syncreq)
    );


  css600_tpiu_trace_pattern
    u_css600_tpiu_trace_pattern
    (
      .traceclk_in           (traceclk_in_g),
      .treset_n              (treset_n),
      .pattern_complete      (pattern_complete),
      .gen_data              (gen_data),
      .trace_pattern         (trace_pattern),
      .trace_pattern_falling (trace_pattern_falling),
      .reg_update            (reg_update),
      .curr_psize_masked     (curr_psize_masked),
      .curr_patt_sel         (curr_patt_sel),
      .curr_patt_mode        (curr_patt_mode),
      .pattern_done          (pattern_done)
    );


  css600_tpiu_trace_out
    u_css600_tpiu_trace_out
    (
      .traceclk_in           (traceclk_in_g),
      .treset_n              (treset_n),
      .tracedata             (tracedata),
      .tracectl              (tracectl),
      .trace_d_valid         (trace_d_valid),
      .trace_d               (trace_d),
      .trace_d_stopped       (trace_d_stopped),
      .trace_d_ready         (trace_d_ready),
      .trace_flush_req       (trace_flush_req),
      .trace_flush_ack       (trace_flush_ack),
      .trace_idle            (trace_idle),
      .trace_idle_hsp        (trace_idle_hsp),
      .trace_stop_state      (trace_stop_state),
      .continuous_mode       (continuous_mode),
      .trig_port_sync        (trig_port_done),
      .curr_psize_update     (curr_psize_update),
      .port_bit_mask         (port_bit_mask),
      .trace_pattern         (trace_pattern)
    );


  css600_tpiu_trace_clk
    u_css600_tpiu_trace_clk
    (
        .traceclk_in         (traceclk_in),
        .treset_n            (treset_n),
        .traceclk            (traceclk)
    );


    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH_INT))
      u_css600_cdc_capt_sync_clk_qreq
      (
        .clk                 (clk),
        .reset_n             (reset_n),
        .d_async_i           (clk_qreq_n),
        .q_sync_o            (clk_qreq_n_sync)
      );


  css600_lpislave
    u_css600_lpislave_clk
    (
      .clk                   (clk),
      .reset_n               (reset_n),
      .qreq_sync_n           (clk_qreq_n_sync),
      .qaccept_n             (clk_qaccept_n),
      .qdeny                 (clk_qdeny),
      .lp_request            (lp_request),
      .lp_done               (lp_done),
      .dev_active            (dev_active),
      .dev_run               (dev_run),
      .cg_en                 (cg_en)
    );

  assign lp_done = lp_request;

  assign dev_active  = (itctrl_ime | psel_s             | atvalid_s   | flush_fsm_busy|flush_pend | trig_flush_wake);
  assign int_clk_en  = (itctrl_ime | psel_s | (|pstate) | ~ft_stopped | flush_fsm_busy|flushcomp  | trig_flush_wake);


  css600_tpiu_async
  u_qactive_async
    (
      .trigin_mon            (trigin_mon),
      .trigin                (trigin),
      .trigin_q              (trigin_q),
      .flushin_mon           (flushin_mon),
      .flushin               (flushin),
      .flushin_q             (flushin_q),
      .trig_flush_wake       (trig_flush_wake
                             ),

      .itctrl_ime            (itctrl_ime),
      .pwakeup_s             (pwakeup_s),
      .atwakeup_s            (atwakeup_s),
      .flush_fsm_busy        (flush_fsm_busy),
      .flush_pend            (flush_pend),
      .pab_active            (pab_active),
      .clk_qactive           (clk_qactive
                             )
    );

  css600_or_tree #(.NUM_OR_INPUTS (8))
    u_traceclk_in_qactive_async
      (
        .or_inputs           ({tp_xfer_req
                             ,tp_xfer_ack

                             ,stop_state[1]
                             ,flush_fsm_busy
                             ,pab_active

                             ,~trace_stop_state[1]
                             ,~fifo_empty

                             ,~tracectl

                             }),
        .or_output           (traceclk_in_qactive)
      );


  css600_clk_gate
    u_css600_tpiu_clk_gate_run
    (
      .clk_i                 (clk_g),
      .clk_enable_i          (cg_en),
      .clk_o                 (clk_r),
      .dftcgen               (dftcgen)
    );

  css600_clk_gate
    u_css600_tpiu_clk_gate
    (
      .clk_i                 (clk),
      .clk_enable_i          (int_clk_en),
      .clk_o                 (clk_g),
      .dftcgen               (dftcgen)
    );

  css600_clk_gate
    u_css600_traceclk_in_gate
    (
      .clk_i                 (traceclk_in),
      .clk_enable_i          (traceclk_in_en),
      .clk_o                 (traceclk_in_g),
      .dftcgen               (dftcgen)
    );

  assign traceclk_in_en_tdata  = ~fifo_empty
                               | trace_d_valid
                               | ~trace_idle
                               ;
  assign traceclk_in_en_tregs  = tp_xfer_req_sync
                               | tp_xfer_ack
                               ;
  assign traceclk_in_en        = traceclk_in_en_tdata
                               | traceclk_in_en_tregs
                               | trig_port_clken
                               | pab_tactive
                               ;


endmodule

