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
//   Shared sub-module of css600_trace_formatter
//
//----------------------------------------------------------------------------


module css600_trace_format_control
#(
  parameter FORMATTER_CONFIG    = 0,
  parameter FORMATTER_TRG_WIDTH = 32,
  parameter ATB_DATA_WIDTH      = 32,
  parameter ATBYTES_WIDTH       = 2
)
(
  input wire                      clk,
  input wire                      cg_en,
  input wire                      clk_g,
  input wire                      reset_n,

  input  wire                     dev_run,

  input wire                      ctl_trace_capt_en,
  input wire                      ctl_trace_capt_en_rise,
  input wire                      circ_buf_mode,
  input wire                      hw_fifo_mode,
  input wire                      ffcr_embed_flush_masked,
  input wire                      ffcr_stop_on_trig_evt_masked,
  input wire                      ffcr_stop_on_trig_evt_masked_clr,
  input wire                      ffcr_stop_on_fl,
  input wire                      ffcr_stop_on_fl_clr,
  input wire                      ffcr_trig_on_fl_masked,
  input wire                      ffcr_trig_on_trig_evt_masked,
  input wire                      ffcr_trig_on_trigin_masked,
  input wire                      ffcr_flsh_on_trig_evt_masked,
  input wire                      ffcr_flsh_on_flshin,
  input wire                      ffcr_flush_man,
  input wire                      ffcr_en_trig_ins,
  input wire                      ffcr_en_formatting_masked,
  input wire                      trg_wr_en,
  input wire [FORMATTER_TRG_WIDTH-1:0] trg_wdata,
  input wire                      unprog_trg,
  output wire [FORMATTER_TRG_WIDTH-1:0]trg,
  output wire                     trg_done,
  output wire                     sts_running,
  output reg                      sts_triggered,
  input  wire                     sts_triggered_clr,
  input wire                      trigin,
  input wire                      flushin,
  output reg                      flushcomp,
  input wire                      trig_port_en,
  output wire                     trg_zero,
  output wire                 nxt_trg_evt_active,
  output wire                     ft_retrig_req,
  output reg                      ft_trig_req,
  output reg [1:0]                ft_trig_size,
  output reg                      ft_flush_req,
  output reg                      ft_flid_req,
  output reg                      ft_stop_req,
  input wire                      ft_trig_ack,
  input wire                      ft_flush_ack,
  input wire                      ft_flid_ack,
  input wire                      ft_stopped,
  /* verilator lint_off UNOPTFLAT */
  output wire                 nxt_stop_pending,
  /* verilator lint_on UNOPTFLAT */
  output wire                     stop_pending,
  output reg                      st_fl_pend,
  output reg                      st_on_fl_active,
  output reg                      st_trig_pend,
  output wire                     ft_trig_pend,
  output reg                      st_on_trig_active,
  output wire                     atbs_flush_done,
  input wire                      nxt_flush_wait,
  input wire                      flush_wait,
  output wire                     hold_trig_req,
  output wire                 nxt_t_on_trig_in_pend,
  output reg                      t_on_trig_in_pend,
  input wire                      atready_s,
  output wire                     afvalid_s,
  input wire                      afready_s,
  /* verilator lint_off UNOPTFLAT */
  output reg                  nxt_wb_flush_req,
  /* verilator lint_on UNOPTFLAT */
  output wire                     wb_flush_req,
  input wire                      wb_flush_ack,
  output wire                     mem_flush_req,
  input wire                      mem_flush_ack,
  input wire                      atbm_flush_valid,
  output wire                     atbm_flush_ready,
  input wire                      itctrl_ime,
  input wire                      it_evt_intr_wr_en,
  input wire                      it_evt_intr_wdata,
  input wire                      it_tr_fl_in_rd_en,
  input wire                      it_atb_ctr_2_wr_en,
  input wire                      it_atb_ctr_2_wdata,
  output reg                      it_trigin,
  output reg                      it_flushin,
  output reg                      trigin_q,
  output reg                      flushin_q,
  output reg                      trigin_mon,
  output reg                      flushin_mon,
  output wire                     trigin_rise,
  input wire                      trig_pkt_wait,
  input wire                  nxt_trig_in_wait,
  input wire                      trig_in_wait,
  input wire                      trig_pkt_wait_done,
  input wire                      trig_in_wait_done,
  input wire                      trg_ctr_decr_pulse,
  input wire [ATBYTES_WIDTH:0]    trg_ctr_decr_val,
  input wire                      trg_ctr_decr_fcb,
  input wire                      trace_mem_empty,
  output reg                      flush_man_clr,
  output reg                      flush_fsm_busy,
  output reg                      flush_pend,
  input wire                      mem_err
);

  localparam ETB  = 0;
  localparam ETR  = 1;
  localparam ETF  = 2;
  localparam ETS  = 3;
  localparam TPIU = 4;

  localparam TRG_CTR_WIDTH       = FORMATTER_TRG_WIDTH-2;

  localparam ST_FLUSH_IDLE       = 4'b0000;
  localparam ST_EXTERNAL_FLUSH   = 4'b0001;
  localparam ST_TRIG_WAIT        = 4'b0010;
  localparam ST_TRIG_PKT_WAIT    = 4'b0011;
  localparam ST_FLUSH_WAIT       = 4'b0100;
  localparam ST_EMBED_TRIG       = 4'b0101;
  localparam ST_EMBED_FLUSH      = 4'b0110;
  localparam ST_TRIG_ON_FLUSH    = 4'b0111;
  localparam ST_FORMATTER_FLUSH  = 4'b1000;
  localparam ST_WBUFFER_FLUSH    = 4'b1001;
  localparam ST_MEM_FLUSH        = 4'b1010;
  localparam ST_UNKNOWN_B        = 4'b1011;
  localparam ST_UNKNOWN_C        = 4'b1100;
  localparam ST_UNKNOWN_D        = 4'b1101;
  localparam ST_UNKNOWN_E        = 4'b1110;
  localparam ST_UNKNOWN_F        = 4'b1111;
  localparam ST_FLUSH_UNKNOWN    = 4'bxxxx;


  reg           t_on_flush_detect;
  wire          t_on_trig_evt_detect;
  wire          t_on_trigon_evt_detect;
  wire          t_on_trigoff_evt_detect;
  wire          t_on_trig_in_detect;
  wire          flushin_rise;
  wire          flushin_rise_masked;
  wire          f_on_man_detect;
  wire          f_on_trig_detect;
  wire          f_on_fl_in_detect;
  wire          f_on_atbm_detect;
  wire          flush_source;
  reg           ffcr_flush_man_q;
  wire          st_on_tc_en_detect;
  wire          st_on_trig_detect;
  wire          st_on_mem_err_detect;
  wire          st_on_fl_detect;
  wire          trig_in_evt_detect;
  wire          trig_pkt_evt_detect;
  wire          trg_evt_detect;
  reg           trg_evt_active;
  wire      nxt_trg_evt_active_set;
  wire      nxt_trg_evt_active_clr;
  wire          trg_evt_inactive;
  reg           trg_evt_pend;
  wire      nxt_trg_evt_pend;
  wire      nxt_ft_trig_req;
  wire [1:0]nxt_ft_trig_size;
  wire      nxt_ft_trig_pend;
  wire      nxt_t_on_trig_evt_pend;
  reg           t_on_trig_evt_pend;
  wire      nxt_t_on_trig_in_evt_pend;
  reg           t_on_trig_in_evt_pend;
  reg           f_on_man_actv;
  wire          f_on_fl_in_actv;
  wire          f_on_trig_actv;
  wire          f_on_atbm_actv;
  reg           f_on_man_pend;
  wire          f_on_fl_in_pend;
  wire          f_on_trig_pend;
  wire          f_on_atbm_pend;
  reg       nxt_f_on_man_actv;
  reg       nxt_f_on_fl_in_actv;
  reg       nxt_f_on_trig_actv;
  reg       nxt_f_on_atbm_actv;
  reg       nxt_f_on_man_pend;
  reg       nxt_f_on_atbm_pend;
  reg       nxt_f_on_fl_in_pend;
  reg       nxt_f_on_trig_pend;
  reg       nxt_flush_pend;
  wire      nxt_flush_pend_masked;
  wire          f_on_atbm_serv_in_prog;
  reg       nxt_ft_flid_req;
  reg       nxt_ft_flush_req;
  reg       nxt_mem_flush_req;
  reg       nxt_atbm_flush_ready;
  reg       nxt_flush_man_clr;
  wire      nxt_flush_fsm_busy;
  wire          st_tc_en_pend;
  wire      nxt_st_on_tc_en_active;
  wire      nxt_st_on_trig_active;
  wire      nxt_st_on_fl_active;
  /* verilator lint_off UNOPTFLAT */
  wire      nxt_st_tc_en_pend;
  /* verilator lint_on UNOPTFLAT */
  /* verilator lint_off UNOPTFLAT */
  wire      nxt_st_trig_pend;
  /* verilator lint_on UNOPTFLAT */
  /* verilator lint_off UNOPTFLAT */
  wire      nxt_st_fl_pend;
  /* verilator lint_on UNOPTFLAT */
  /* verilator lint_off UNOPTFLAT */
  wire      nxt_ft_stop_req;
  /* verilator lint_on UNOPTFLAT */
  reg           ft_stopped_q;
  wire          ft_stopped_rising;
  wire          hold_stop_req;
  wire          trg_frm_init_en;
  wire          trg_frm_ctr_tc;
  wire          trg_frm_ctr_en;
  wire          trg_frm_ctr_dec;
  wire          trg_byt_ctr_en;
  wire          trg_byt_ctr_init_en;
  wire [3:0]    trg_byt_ctr_init;
  wire          trg_byt_ctr_inc;
  wire [4:0]    trg_byt_ctr_decr_val;
  wire [TRG_CTR_WIDTH-1:0] nxt_trg_frm_ctr;
  reg  [TRG_CTR_WIDTH-1:0]     trg_frm_ctr;
  wire [3:0]               nxt_trg_byt_ctr_temp;
  wire [3:0]               nxt_trg_byt_ctr;
  reg  [3:0]                   trg_byt_ctr;
  wire          trg_byt_ctr_ovrfl_1;
  wire          trg_byt_ctr_ovrfl_2;
  wire          trigger_event;
  wire          triggeron_event;
  wire          triggeroff_event;
  wire      nxt_sts_triggered;
  wire          sts_triggered_en;
  reg [3:0] nxt_flush_state;
  reg [3:0]     flush_state;
  wire      nxt_ft_flush_in_prog;
  reg           ft_flush_in_prog;
  wire         tpiu_config;
  wire          etr_config;
  reg       nxt_afvalids_func;
  reg           afvalids_func;
  wire      nxt_it_afvalids;
  reg           it_afvalids;
  wire      nxt_flushcomp;
  reg       nxt_flushcomp_func;
  wire      nxt_it_trigin;
  wire      nxt_it_flushin;
  wire      nxt_trigin_mon;
  wire      nxt_flushin_mon;
  reg       force_trig_req;


  generate
    if (FORMATTER_CONFIG != ETR)
      begin : cfg_non_etr
        assign etr_config = 1'b0;
      end
    else
      begin : cfg_etr
        assign etr_config = 1'b1;
      end
  endgenerate

  generate
    if (FORMATTER_CONFIG != TPIU)
      begin : cfg_non_tpiu
        assign tpiu_config = 1'b0;
      end
    else
      begin : cfg_tpiu
        assign tpiu_config = 1'b1;
      end
  endgenerate

  assign atbs_flush_done = afvalid_s & afready_s;

  assign nxt_trigin_mon  = ~nxt_ft_stop_req & (ffcr_stop_on_trig_evt_masked |
                                               ffcr_flsh_on_trig_evt_masked |
                                               ffcr_trig_on_trig_evt_masked |
                                               ffcr_trig_on_trigin_masked)
                         & (~tpiu_config | ~nxt_stop_pending)
                         ;

  assign nxt_flushin_mon = ~nxt_ft_stop_req & ffcr_flsh_on_flshin
                         & (~tpiu_config | ~nxt_stop_pending)
                         ;

  always @(posedge clk or negedge reset_n)
  begin : s_trig_fl_mon
    if (!reset_n)
      begin
        trigin_mon  <= 1'b0;
        flushin_mon <= 1'b0;
      end
    else if (cg_en)
      begin
        trigin_mon  <= nxt_trigin_mon;
        flushin_mon <= nxt_flushin_mon;
      end
  end


  assign trg_byt_ctr_inc =  trg_evt_active &
                           ~trg_zero &
                            circ_buf_mode &
                           ~ft_stopped &
                            trg_ctr_decr_pulse;

  generate
    wire [ATBYTES_WIDTH:0] trg_ctr_decr_val_plus_trg_ctr_decr_fcb;
    assign trg_ctr_decr_val_plus_trg_ctr_decr_fcb = trg_ctr_decr_val + {{ATBYTES_WIDTH{1'b0}},trg_ctr_decr_fcb & tpiu_config};
    if (ATB_DATA_WIDTH == 128)
      begin : gen_padding_atb128
        assign trg_byt_ctr_decr_val =                            trg_ctr_decr_val_plus_trg_ctr_decr_fcb;
      end
    else
      begin : gen_padding_atb32_atb64
        assign trg_byt_ctr_decr_val = {{5-ATBYTES_WIDTH-1{1'b0}},trg_ctr_decr_val_plus_trg_ctr_decr_fcb};
      end
  endgenerate

  assign {trg_byt_ctr_ovrfl_1,nxt_trg_byt_ctr_temp} = trg_byt_ctr_inc ? {1'b0,trg_byt_ctr} + trg_byt_ctr_decr_val
                                                                      : {1'b0,trg_byt_ctr};
  assign trg_byt_ctr_ovrfl_2 = ffcr_en_formatting_masked & ~trg_frm_init_en & ( { nxt_trg_byt_ctr_temp[3:1]
                                                                                , nxt_trg_byt_ctr_temp[  0] | trg_byt_ctr_ovrfl_1
                                                                                } == 4'd15 ) & ~tpiu_config;
  assign nxt_trg_byt_ctr = {4{ trg_byt_ctr_init_en}} & trg_byt_ctr_init
                         | {4{~trg_byt_ctr_init_en}} & (
                             (trg_done || ft_stopped_rising) ? 4'h0
                           : (ffcr_en_formatting_masked && ~trg_frm_init_en) ? ( nxt_trg_byt_ctr_temp
                                                                                 + {3'b0,trg_byt_ctr_ovrfl_1 & ~tpiu_config}
                                                                                 + {3'b0,trg_byt_ctr_ovrfl_2 & ~tpiu_config}
                                                                               )
                                                                             :  nxt_trg_byt_ctr_temp
                         );
  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trg_byt_ctr_init
        reg       trg_frm_init_en_int;
        wire  nxt_trg_frm_init_en;

        assign trg_byt_ctr_init_en = trg_wr_en;

        assign trg_byt_ctr_init = (trg_wdata[1:0] == 2'd1) ? 4'd12
                                : (trg_wdata[1:0] == 2'd2) ? 4'd8
                                : (trg_wdata[1:0] == 2'd3) ? 4'd4
                                :                            4'd0
                                ;

        assign nxt_trg_frm_init_en = (trg_wr_en && (trg_wdata[1:0] > 2'd0)) | (trg_frm_init_en & ~trg_frm_ctr_tc);

        always @(posedge clk or negedge reset_n)
        begin : s_trg_frm_init_en
          if (!reset_n)
            trg_frm_init_en_int <= 1'b0;
          else if (cg_en)
            trg_frm_init_en_int <= nxt_trg_frm_init_en;
        end
        assign trg_frm_init_en = trg_frm_init_en_int;

      end
    else
      begin : dont_gen_trg_byt_ctr_init
        assign trg_byt_ctr_init_en = 1'b0;
        assign trg_byt_ctr_init    = 4'd0;
        assign trg_frm_init_en     = 1'd0;
      end
  endgenerate


  assign trg_byt_ctr_en = ( (trg_wr_en & tpiu_config) | trg_byt_ctr_inc | trg_done | ft_stopped_rising);

  always @(posedge clk or negedge reset_n)
  begin : s_trg_byt_ctr
    if (!reset_n)
      trg_byt_ctr <= 4'h0;
    else if (cg_en && trg_byt_ctr_en)
      trg_byt_ctr <= nxt_trg_byt_ctr;
  end

  assign trg_frm_ctr_tc =  (trg_wr_en | ctl_trace_capt_en_rise | trg_frm_ctr_dec | ft_stopped_rising);
  assign trg_frm_ctr_en = trg_byt_ctr_init_en | ~trg_frm_init_en & trg_frm_ctr_tc;

  assign trg_frm_ctr_dec = (trg_byt_ctr_ovrfl_1 | trg_byt_ctr_ovrfl_2);

  assign nxt_trg_frm_ctr =  trg_wr_en ? trg_wdata[FORMATTER_TRG_WIDTH-1:2] :
                           (trg_done || ft_stopped_rising)
                                      ? {TRG_CTR_WIDTH{1'b0}}
                                      : (trg_frm_ctr - {{TRG_CTR_WIDTH-1{1'b0}},trg_byt_ctr_ovrfl_1}
                                                     - {{TRG_CTR_WIDTH-1{1'b0}},trg_byt_ctr_ovrfl_2});

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trg_frm_ctr_with_reset
        always @(posedge clk or negedge reset_n)
        begin : s_trg_frm_ctr_with_reset
          if (!reset_n)
            trg_frm_ctr <= {TRG_CTR_WIDTH{1'b0}};
          else if (cg_en && trg_frm_ctr_en)
            trg_frm_ctr <= nxt_trg_frm_ctr;
        end
      end
    else
      begin : gen_trg_frm_ctr_without_reset
        always @(posedge clk)
        begin : s_trg_frm_ctr_without_reset
          if (cg_en && trg_frm_ctr_en)
            trg_frm_ctr <= nxt_trg_frm_ctr;
        end
      end
  endgenerate

  assign trg_zero = ({trg_frm_ctr,trg_byt_ctr} == {TRG_CTR_WIDTH+4{1'b0}}) | unprog_trg;

  assign trg_done = unprog_trg | (trg_frm_ctr_dec & (trg_frm_ctr[TRG_CTR_WIDTH-1:2] == {TRG_CTR_WIDTH-2{1'b0}})
                                                  & ~(|trg_frm_ctr[1:0] & trg_frm_init_en)
                                                  & (trg_frm_ctr[1:0] <= {1'b0,trg_byt_ctr_ovrfl_1} + {1'b0,trg_byt_ctr_ovrfl_2}));

  assign trg = {trg_frm_ctr,2'd0};
  assign trig_in_evt_detect     = (tpiu_config && ~trig_port_en && trg_evt_active && trig_in_wait_done && trg_done) ? trig_in_wait_done & ~trg_evt_inactive
                                : (tpiu_config                  && trg_evt_active && nxt_trg_evt_active_clr       ) ? 1'b0
                                :                                                                                     trig_in_wait_done & ~trg_evt_inactive
                                ;
  assign trig_pkt_evt_detect    = (tpiu_config                  && trg_evt_active && nxt_trg_evt_active_clr       ) ? 1'b0
                                :                                                                                     trig_pkt_wait_done
                                ;
  assign trg_evt_detect         = (trig_in_evt_detect | trig_pkt_evt_detect | trg_evt_pend);
  assign nxt_trg_evt_pend       = trg_evt_detect &  hold_trig_req;
  assign nxt_trg_evt_active_set = trg_evt_detect & ~hold_trig_req & (~tpiu_config | ~ft_stop_req) & ~ft_stopped & ~trg_zero;
  assign nxt_trg_evt_active_clr = trg_evt_active & ( ft_stopped |  trg_zero | (tpiu_config & trg_done));
  assign nxt_trg_evt_active     =  nxt_trg_evt_active_set
                                | ~nxt_trg_evt_active_clr & trg_evt_active
                                ;

  always @(posedge clk or negedge reset_n)
  begin : s_trg_evt_active
    if (!reset_n) begin
      trg_evt_active   <= 1'b0;
      trg_evt_pend     <= 1'b0;
    end else if (cg_en) begin
      trg_evt_active   <= nxt_trg_evt_active;
      trg_evt_pend     <= nxt_trg_evt_pend;
    end
  end

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trg_evt_inactive
        reg  trg_evt_inactive_int;
        wire nxt_trg_evt_inactive;

        assign nxt_trg_evt_inactive   = (~trig_port_en &&  trg_evt_active   && ~trg_evt_inactive      ) ? trig_in_wait & ~trig_in_wait_done
                                      : (~trig_port_en && ~trg_evt_active   &&  trg_evt_inactive      ) ? 1'b0
                                      : (~trig_port_en                      &&  trg_evt_inactive      ) ? ~atready_s
                                      : ( trig_port_en && trg_evt_active    &&  nxt_trg_evt_active_clr) ? nxt_trig_in_wait
                                      : ( trig_port_en && triggeroff_event  && ~trg_evt_inactive      ) ? ~atready_s
                                      : ( trig_port_en && trig_in_wait_done &&  trg_evt_inactive      ) ? 1'b0
                                      : ( trig_port_en && ~nxt_trig_in_wait &&  trg_evt_inactive      ) ? ~atready_s
                                      :                                                                 nxt_trig_in_wait & trg_evt_inactive
                                      ;
        always @(posedge clk or negedge reset_n)
        begin : s_trg_evt_inactive
          if (!reset_n) begin
            trg_evt_inactive_int <= 1'b0;
          end else if (cg_en) begin
            trg_evt_inactive_int <= nxt_trg_evt_inactive;
          end
        end
        assign trg_evt_inactive = trg_evt_inactive_int;

      end
    else
      begin : dont_gen_trg_evt_inactive
        assign trg_evt_inactive = 1'b0;
      end
  endgenerate

  always @(posedge clk_g or negedge reset_n)
  begin : s_trigin_del
    if (!reset_n)
      trigin_q <= 1'b0;
    else
      trigin_q <= trigin;
  end

  assign trigin_rise = trigin & ~trigin_q;

  assign nxt_it_trigin = itctrl_ime & ~it_tr_fl_in_rd_en & (trigin_rise | it_trigin);

  always @(posedge clk_g or negedge reset_n)
  begin : s_it_trigin
    if (!reset_n)
      it_trigin <= 1'b0;
    else
      it_trigin <= nxt_it_trigin;
  end

  wire wait_done; assign wait_done = ((trig_in_wait_done & ~trg_evt_inactive) | trig_pkt_wait_done);
  wire  on_event; assign  on_event =                                      trg_done  ;
  wire off_event; assign off_event =  wait_done & trg_zero  | wait_done & on_event  | (tpiu_config & trg_evt_active & trg_zero);
  wire   t_event; assign   t_event =  wait_done & trg_zero  |             on_event  | (tpiu_config & trg_evt_active & trg_zero);
  assign triggeron_event  =  on_event & ~ft_stop_req & ~ft_stopped & (~stop_pending | flush_wait);
  assign triggeroff_event = off_event & ~ft_stop_req & ~ft_stopped & (~stop_pending | flush_wait);
  assign trigger_event    =   t_event & ~ft_stop_req & ~ft_stopped & (~stop_pending | flush_wait);
  assign t_on_trig_evt_detect = ffcr_trig_on_trig_evt_masked & trigger_event;
  assign t_on_trigon_evt_detect = ffcr_trig_on_trig_evt_masked & triggeron_event;
  assign t_on_trigoff_evt_detect = ffcr_trig_on_trig_evt_masked & triggeroff_event;

  assign t_on_trig_in_detect = ffcr_trig_on_trigin_masked & trig_in_wait_done &
                               ~ft_stop_req & (~stop_pending | flush_wait);

  assign nxt_ft_trig_req = ( ffcr_en_trig_ins & ~ft_stop_req
                           & (  t_on_flush_detect
                             |((t_on_trig_in_detect | t_on_trig_evt_detect) & (~nxt_ft_trig_pend
                                                                              |( tpiu_config & force_trig_req)
                                                                              |(~tpiu_config & force_trig_req)
                                                                              )
                              )
                             | (~tpiu_config                                &       ft_trig_pend & ~hold_trig_req )
                             | ( tpiu_config & ~st_fl_pend                  &       ft_trig_pend & ~hold_trig_req )
                             | ( tpiu_config &  st_fl_pend & st_trig_pend   &       ft_trig_pend & ~hold_trig_req )
                             )
                           )
                           | (ft_trig_req & ~ft_trig_ack)
                           ;

  always @(posedge clk or negedge reset_n)
  begin : s_trig_req
    if (!reset_n)
      begin
        ft_trig_req           <= 1'b0;
        t_on_trig_in_pend     <= 1'b0;
        t_on_trig_evt_pend    <= 1'b0;
        t_on_trig_in_evt_pend <= 1'b0;
        ft_trig_size          <= 2'd0;
      end
    else if (cg_en)
      begin
        ft_trig_req           <= nxt_ft_trig_req;
        t_on_trig_in_pend     <= nxt_t_on_trig_in_pend;
        t_on_trig_evt_pend    <= nxt_t_on_trig_evt_pend;
        t_on_trig_in_evt_pend <= nxt_t_on_trig_in_evt_pend;
        ft_trig_size          <= nxt_ft_trig_size;
      end
  end

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_ft_retrig_req
        reg       ft_retrig_req_int;
        wire  nxt_ft_retrig_req_int;

        assign nxt_ft_retrig_req_int = (nxt_ft_trig_req & nxt_trg_evt_active_set & nxt_trg_evt_active_clr)
                                     | (ft_retrig_req_int & ~ft_trig_ack)
                                     ;
        always @(posedge clk or negedge reset_n)
        begin : s_ft_retrig_req
          if (!reset_n)
            ft_retrig_req_int <= 1'b0;
          else if (cg_en)
            ft_retrig_req_int <= nxt_ft_retrig_req_int;
        end
        assign ft_retrig_req = ft_retrig_req_int;
      end
    else
      begin : dont_gen_ft_retrig_req
        assign ft_retrig_req = 1'b0;
      end
  endgenerate

  assign nxt_t_on_trig_in_pend     = (ffcr_trig_on_trigin_masked & trig_in_wait_done & (flush_state == ST_TRIG_PKT_WAIT))
                                   | (t_on_trig_in_detect     | t_on_trig_in_pend    ) & hold_trig_req;
  assign nxt_t_on_trig_evt_pend    = (t_on_trigon_evt_detect  | t_on_trig_evt_pend   ) & hold_trig_req;
  assign nxt_t_on_trig_in_evt_pend = (t_on_trigoff_evt_detect | t_on_trig_in_evt_pend) & hold_trig_req
                                   ;

  assign nxt_ft_trig_pend          = nxt_t_on_trig_in_pend | nxt_t_on_trig_evt_pend | nxt_t_on_trig_in_evt_pend;
  assign ft_trig_pend              =     t_on_trig_in_pend |     t_on_trig_evt_pend |     t_on_trig_in_evt_pend;

  assign nxt_ft_trig_size          = (ft_trig_req && !ft_trig_ack)    ? ft_trig_size
                                   : (ft_trig_pend && !hold_trig_req) ? {1'b0,t_on_trig_in_pend     | t_on_trig_in_detect }
                                                                      + {1'b0,t_on_trig_evt_pend                          }
                                                                      + {1'b0,t_on_trig_in_evt_pend | t_on_trig_evt_detect}
                                   : (t_on_flush_detect)              ? 2'b01
                                   :                                    {1'b0,t_on_trig_in_detect
                                                                        }
                                                                      + {1'b0,t_on_trig_evt_detect}
                                   ;

  assign sts_triggered_en = trigger_event | sts_triggered_clr;
  assign nxt_sts_triggered = trigger_event & circ_buf_mode & (~tpiu_config | ~sts_triggered_clr);

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_sts_triggred_with_reset
        always @(posedge clk or negedge reset_n)
        begin : s_sts_triggered
          if (!reset_n)
            sts_triggered <= 1'b0;
          else if (cg_en && sts_triggered_en)
            sts_triggered <= nxt_sts_triggered;
        end
      end
    else
      begin : gen_sts_triggred_without_reset
        always @(posedge clk)
        begin : s_sts_triggered_without_reset
          if (cg_en && sts_triggered_en)
            sts_triggered <= nxt_sts_triggered;
        end
      end
  endgenerate

  assign sts_running = trg_evt_active;


  assign f_on_man_detect = ffcr_flush_man & ~ffcr_flush_man_q & ~ft_stop_req;

  always @(posedge clk or negedge reset_n)
  begin : s_ffcr_flush_man_q
    if (!reset_n)
      ffcr_flush_man_q <= 1'b0;
    else if (cg_en)
      ffcr_flush_man_q <= ffcr_flush_man;
  end

  assign f_on_trig_detect = ffcr_flsh_on_trig_evt_masked &
                            trigger_event &
                           ~ffcr_stop_on_trig_evt_masked &
                            circ_buf_mode &
                           ~ft_stop_req;

  assign f_on_fl_in_detect =  ffcr_flsh_on_flshin & flushin_rise_masked & ~ft_stop_req;
  assign flushin_rise_masked = (tpiu_config && stop_pending) ? 1'b0 : flushin_rise;

  generate
    if (FORMATTER_CONFIG == ETF)
      begin : gen_f_on_atbm
        reg atbm_flush_valid_q;
        reg atbm_flush_ready_etf;
        reg f_on_atbm_actv_etf;
        reg f_on_atbm_pend_etf;
        reg f_on_fl_in_pend_etf;
        reg f_on_fl_in_actv_etf;
        reg f_on_trig_pend_etf;
        reg f_on_trig_actv_etf;

        always @ (posedge clk or negedge reset_n)
        begin : s_atbm_flush
          if (!reset_n) begin
            atbm_flush_valid_q   <= 1'b0;
            atbm_flush_ready_etf <= 1'b0;
            f_on_atbm_actv_etf   <= 1'b0;
            f_on_atbm_pend_etf   <= 1'b0;
            f_on_fl_in_pend_etf  <= 1'b0;
            f_on_fl_in_actv_etf  <= 1'b0;
            f_on_trig_pend_etf   <= 1'b0;
            f_on_trig_actv_etf   <= 1'b0;
          end else if (cg_en) begin
            atbm_flush_valid_q   <= atbm_flush_valid;
            atbm_flush_ready_etf <= nxt_atbm_flush_ready;
            f_on_atbm_actv_etf   <= nxt_f_on_atbm_actv;
            f_on_atbm_pend_etf   <= nxt_f_on_atbm_pend;
            f_on_fl_in_pend_etf  <= nxt_f_on_fl_in_pend;
            f_on_fl_in_actv_etf  <= nxt_f_on_fl_in_actv;
            f_on_trig_pend_etf   <= nxt_f_on_trig_pend;
            f_on_trig_actv_etf   <= nxt_f_on_trig_actv;
          end
        end

        assign f_on_atbm_detect = atbm_flush_valid & ~atbm_flush_valid_q & ~ft_stop_req;
        assign f_on_atbm_actv   = f_on_atbm_actv_etf;
        assign f_on_atbm_pend   = f_on_atbm_pend_etf;
        assign atbm_flush_ready = atbm_flush_ready_etf;
        assign f_on_fl_in_pend  = f_on_fl_in_pend_etf;
        assign f_on_fl_in_actv  = f_on_fl_in_actv_etf;
        assign f_on_trig_pend   = f_on_trig_pend_etf;
        assign f_on_trig_actv   = f_on_trig_actv_etf;

        assign f_on_atbm_serv_in_prog = f_on_atbm_actv & ~(f_on_man_actv | f_on_trig_actv | f_on_fl_in_actv);
      end
    else
      begin : dont_gen_f_on_atbm
        assign f_on_atbm_detect       = 1'b0;
        assign f_on_atbm_actv         = 1'b0;
        assign f_on_atbm_pend         = 1'b0;
        assign atbm_flush_ready       = 1'b0;
        assign f_on_atbm_serv_in_prog = 1'b0;
        assign f_on_fl_in_pend        = 1'b0;
        assign f_on_fl_in_actv        = 1'b0;
        assign f_on_trig_pend         = 1'b0;
        assign f_on_trig_actv         = 1'b0;
      end
  endgenerate

  always @(posedge clk_g or negedge reset_n)
  begin : s_flushin_del
    if (!reset_n)
      flushin_q <= 1'b0;
    else
      flushin_q <= flushin;
  end

  assign flushin_rise = flushin & ~flushin_q;

  assign nxt_it_flushin = itctrl_ime & ~it_tr_fl_in_rd_en & (flushin_rise | it_flushin);

  always @(posedge clk_g or negedge reset_n)
  begin : p_it_flushin
    if (!reset_n)
      it_flushin <= 1'b0;
    else
      it_flushin <= nxt_it_flushin;
  end

  assign flush_source = f_on_man_detect | f_on_trig_detect | f_on_fl_in_detect | f_on_atbm_detect;


  always @*
    begin : c_flush_control
      nxt_flush_pend           = (~flush_pend & flush_source) | flush_pend;
      nxt_flush_state          = flush_state;
      nxt_afvalids_func        = afvalids_func;
      nxt_f_on_man_pend        = (                 ~f_on_man_pend   & f_on_man_detect  ) | f_on_man_pend;
      nxt_f_on_man_actv        = f_on_man_actv;
      nxt_f_on_fl_in_pend      = (                 ~f_on_fl_in_pend & f_on_fl_in_detect) | f_on_fl_in_pend;
      nxt_f_on_fl_in_actv      = f_on_fl_in_actv;
      nxt_f_on_atbm_pend       = (nxt_flush_pend & ~f_on_atbm_pend  & f_on_atbm_detect ) | f_on_atbm_pend;
      nxt_f_on_atbm_actv       = f_on_atbm_actv;
      nxt_f_on_trig_pend       = (                 ~f_on_trig_pend  & f_on_trig_detect ) | f_on_trig_pend;
      nxt_f_on_trig_actv       = f_on_trig_actv;
      nxt_ft_flid_req          = ft_flid_req;
      nxt_ft_flush_req         = ft_flush_req;
      nxt_mem_flush_req        = mem_flush_req;
      nxt_wb_flush_req         = wb_flush_req;
      nxt_atbm_flush_ready     = atbm_flush_valid & ~f_on_atbm_pend &
                                  ft_stop_req &
                                  ft_stopped &
                                  trace_mem_empty &
                                 ~atbm_flush_ready;
      nxt_flushcomp_func       = 1'b0;
      nxt_flush_man_clr        = 1'b0;

      t_on_flush_detect        = 1'b0;
      force_trig_req           = 1'b0;

      case (flush_state)
        ST_FLUSH_IDLE :
          begin
            nxt_flush_pend             = 1'b0;
            nxt_f_on_fl_in_pend        = 1'b0;
            nxt_f_on_atbm_pend         = 1'b0;
            nxt_f_on_trig_pend         = 1'b0;
            nxt_f_on_man_pend          = 1'b0;
            nxt_flush_man_clr          = (~tpiu_config &     ft_stop_req)
                                       | ( tpiu_config & nxt_ft_stop_req)
                                       ;

            if ((flush_source || flush_pend) &&
                ctl_trace_capt_en &&
                !nxt_ft_stop_req &&
                !nxt_stop_pending)
              begin
                nxt_flush_state   = ST_EXTERNAL_FLUSH;
                nxt_afvalids_func = 1'b1;

                nxt_f_on_man_actv   = f_on_man_detect | f_on_man_pend;
                nxt_f_on_fl_in_actv = (~flush_pend & f_on_fl_in_detect) | f_on_fl_in_pend;
                nxt_f_on_trig_actv  = (~flush_pend & f_on_trig_detect) | f_on_trig_pend;
                nxt_f_on_atbm_actv  = f_on_atbm_detect | f_on_atbm_pend;
              end
          end

        ST_EXTERNAL_FLUSH :
          begin
            if (atbs_flush_done)
              begin
                nxt_afvalids_func = 1'b0;

                if (trig_in_wait && !trig_in_wait_done)
                  begin
                    nxt_flush_state   = (~trig_in_wait &&  trig_pkt_wait) ? ST_TRIG_PKT_WAIT
                                      : ( trig_in_wait && ~trig_pkt_wait) ? ST_TRIG_WAIT
                                      : ( trig_in_wait &&  trig_pkt_wait) ? ST_TRIG_WAIT
                                      :                                     ST_FLUSH_UNKNOWN
                                      ;
                    t_on_flush_detect =  ~((trg_zero & ffcr_trig_on_trig_evt_masked) | ffcr_trig_on_trigin_masked)
                                      &  ~(t_on_trig_in_detect | t_on_trig_evt_detect | (ft_trig_req & ~ft_trig_ack))
                                      &  ~nxt_flush_wait
                                      &  ~ffcr_embed_flush_masked
                                      &   ffcr_trig_on_fl_masked & ~f_on_atbm_serv_in_prog
                                      ;
                  end

                else if (trig_pkt_wait && !trig_pkt_wait_done)
                  begin
                    nxt_flush_state   = (~trig_in_wait &&  trig_pkt_wait) ? ST_TRIG_PKT_WAIT
                                      : ( trig_in_wait && ~trig_pkt_wait) ? ST_TRIG_WAIT
                                      : ( trig_in_wait &&  trig_pkt_wait) ? ST_TRIG_WAIT
                                      :                                     ST_FLUSH_UNKNOWN
                                      ;
                    t_on_flush_detect =  ~(trg_zero & ffcr_trig_on_trig_evt_masked)
                                      &  ~(t_on_trig_in_detect | t_on_trig_evt_detect | (ft_trig_req & ~ft_trig_ack))
                                      &  ~nxt_flush_wait
                                      &  ~ffcr_embed_flush_masked
                                      &   ffcr_trig_on_fl_masked & ~f_on_atbm_serv_in_prog
                                      ;
                  end

                else if (nxt_flush_wait)
                  begin
                    nxt_flush_state   = ST_FLUSH_WAIT;
                  end

                else if ((t_on_trig_in_detect || t_on_trig_evt_detect) ||
                         (ft_trig_req && !ft_trig_ack))
                  begin
                    nxt_flush_state   = ST_EMBED_TRIG;
                    force_trig_req    = 1'b1;
                  end

                else if (ffcr_embed_flush_masked)
                  begin
                    nxt_ft_flid_req   = 1'b1;
                    nxt_flush_state   = ST_EMBED_FLUSH;
                  end

                else if (ffcr_trig_on_fl_masked && !f_on_atbm_serv_in_prog)
                  begin
                    nxt_flush_state   = ST_TRIG_ON_FLUSH;
                    t_on_flush_detect = 1'b1;
                  end

                else
                  begin
                    nxt_ft_flush_req  = 1'b1;
                    nxt_flush_state   = ST_FORMATTER_FLUSH;
                  end
              end

          end

        ST_TRIG_WAIT,ST_TRIG_PKT_WAIT :
          begin
            if (!nxt_flush_wait)
              begin
                if ((trig_in_wait_done && (t_on_trig_in_detect || t_on_trig_evt_detect) && ~nxt_t_on_trig_in_pend) ||
                    (trig_pkt_wait_done && t_on_trig_evt_detect))
                  begin
                    nxt_flush_state = ST_EMBED_TRIG;
                    force_trig_req    = 1'b1;
                  end

                else if (ffcr_embed_flush_masked)
                  begin
                    nxt_ft_flid_req = 1'b1;
                    nxt_flush_state = ST_EMBED_FLUSH;
                  end

                else if (ffcr_trig_on_fl_masked && !f_on_atbm_serv_in_prog)
                  begin
                    nxt_flush_state = ST_TRIG_ON_FLUSH;
                    t_on_flush_detect = 1'b1;
                  end

                else
                  begin
                    nxt_ft_flush_req = 1'b1;
                    nxt_flush_state  = ST_FORMATTER_FLUSH;
                  end
              end
          end

        ST_FLUSH_WAIT :
          begin
            if (!nxt_flush_wait)
              begin
                if (ffcr_embed_flush_masked)
                  begin
                    nxt_ft_flid_req = 1'b1;
                    nxt_flush_state = ST_EMBED_FLUSH;
                  end

                else if (ffcr_trig_on_fl_masked && !f_on_atbm_serv_in_prog)
                  begin
                    nxt_flush_state = ST_TRIG_ON_FLUSH;
                    t_on_flush_detect = ~ffcr_embed_flush_masked;
                  end

                else
                  begin
                    nxt_ft_flush_req = 1'b1;
                    nxt_flush_state  = ST_FORMATTER_FLUSH;
                  end
              end
          end

        ST_EMBED_TRIG :
          begin
            force_trig_req          = 1'b1;

            if (ft_trig_ack)
              begin
                force_trig_req      = 1'b0;

                if (ffcr_embed_flush_masked)
                  begin
                    nxt_ft_flid_req = 1'b1;
                    nxt_flush_state = ST_EMBED_FLUSH;
                  end

                else if (ffcr_trig_on_fl_masked && !f_on_atbm_serv_in_prog)
                  begin
                    nxt_flush_state = ST_TRIG_ON_FLUSH;
                    t_on_flush_detect = ~ffcr_embed_flush_masked;
                  end

                else
                  begin
                    nxt_ft_flush_req = 1'b1;
                    nxt_flush_state  = ST_FORMATTER_FLUSH;
                  end
              end
          end

        ST_EMBED_FLUSH :
          begin
            if (ft_flid_ack)
              begin
                nxt_ft_flid_req = 1'b0;

                if (ffcr_trig_on_fl_masked && !f_on_atbm_serv_in_prog)
                  begin
                    nxt_flush_state  = ST_TRIG_ON_FLUSH;
                    t_on_flush_detect = 1'b1;
                  end

                else
                  begin
                    nxt_ft_flush_req = 1'b1;
                    nxt_flush_state  = ST_FORMATTER_FLUSH;
                  end
              end
          end

        ST_TRIG_ON_FLUSH :
          begin
            if (ft_trig_ack)
              begin
                nxt_flush_state  = ST_FORMATTER_FLUSH;
                nxt_ft_flush_req = 1'b1;
              end
          end

        ST_FORMATTER_FLUSH :
          begin
            if (ft_flush_ack)
              begin
                nxt_ft_flush_req = 1'b0;
                nxt_flush_state  = ST_WBUFFER_FLUSH;
                nxt_wb_flush_req = 1'b1;
              end
          end

        ST_WBUFFER_FLUSH :
          begin
            if (!etr_config)
              begin
                if (wb_flush_ack)
                  begin
                    nxt_wb_flush_req    = 1'b0;
                    nxt_flushcomp_func  = 1'b1;
                    nxt_flush_man_clr   = f_on_man_actv;

                    if (hw_fifo_mode && atbm_flush_valid)
                      begin
                        nxt_flush_state   = ST_MEM_FLUSH;
                        nxt_mem_flush_req = 1'b1;
                      end
                    else
                      begin
                        nxt_flush_state   = ST_FLUSH_IDLE;

                        nxt_f_on_man_actv   = 1'b0;
                        nxt_f_on_fl_in_actv = 1'b0;
                        nxt_f_on_trig_actv  = 1'b0;
                        nxt_f_on_atbm_actv  = 1'b0;
                      end
                  end
              end
            else
              begin
                if (wb_flush_ack)
                  begin
                    nxt_wb_flush_req = 1'b0;
                    nxt_flush_state  = ST_MEM_FLUSH;
                    nxt_mem_flush_req = 1'b1;
                  end
              end
          end

        ST_MEM_FLUSH :
          begin
            if (mem_flush_ack)
              begin
                nxt_flush_state      = ST_FLUSH_IDLE;
                nxt_atbm_flush_ready = ~nxt_f_on_atbm_pend;
                nxt_mem_flush_req    = 1'b0;

                nxt_f_on_man_actv   = 1'b0;
                nxt_f_on_fl_in_actv = 1'b0;
                nxt_f_on_trig_actv  = 1'b0;
                nxt_f_on_atbm_actv  = 1'b0;

                nxt_flush_man_clr   = f_on_man_actv;
                nxt_flushcomp_func  = ~hw_fifo_mode;
              end
          end

        default :
          begin
            nxt_f_on_atbm_pend = f_on_atbm_pend;
            nxt_flush_pend     = flush_pend;

            nxt_flush_state   = ST_FLUSH_UNKNOWN;
            nxt_flush_man_clr = 1'bx;
          end
      endcase
    end

  always @(posedge clk or negedge reset_n)
  begin : s_flush_control
    if (!reset_n)
      begin
        ft_flid_req        <= 1'b0;
        ft_flush_req       <= 1'b0;
        flush_man_clr      <= 1'b1;
        f_on_man_pend      <= 1'b0;
      end
    else if (cg_en)
      begin
        ft_flid_req        <= nxt_ft_flid_req;
        ft_flush_req       <= nxt_ft_flush_req;
        flush_man_clr      <= nxt_flush_man_clr;
        f_on_man_pend      <= nxt_f_on_man_pend;
      end
  end

  always @(posedge clk_g or negedge reset_n)
  begin : s_flush_control_g
    if (!reset_n)
      begin
        flush_state        <= ST_FLUSH_IDLE;
        f_on_man_actv      <= 1'b0;
        flush_pend         <= 1'b0;
        afvalids_func      <= 1'b0;
      end
    else
      begin
        flush_state        <= nxt_flush_state;
        f_on_man_actv      <= nxt_f_on_man_actv;
        flush_pend         <= nxt_flush_pend_masked;
        afvalids_func      <= nxt_afvalids_func;
      end
  end
  assign nxt_flush_pend_masked = nxt_flush_pend & (~tpiu_config | ~ft_stop_req);

  generate
    if ((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETS) || (FORMATTER_CONFIG == TPIU))
      begin : gen_wb_flush_req
        reg wb_flush_req_int;

        always @ (posedge clk or negedge reset_n)
        begin : s_wb_flush_req
          if (!reset_n)
            wb_flush_req_int <= 1'b0;
          else if (cg_en)
            wb_flush_req_int <= nxt_wb_flush_req;
        end

        assign wb_flush_req = wb_flush_req_int;
      end
    else
      begin : dont_gen_wb_flush_req
        assign wb_flush_req = 1'b0;
      end
  endgenerate

  generate
    if ((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETF))
      begin : gen_mem_flush_req
        reg mem_flush_req_int;

        always @ (posedge clk or negedge reset_n)
        begin : s_mem_flush_req
          if (!reset_n)
            mem_flush_req_int <= 1'b0;
          else if (cg_en)
            mem_flush_req_int <= nxt_mem_flush_req;
        end

        assign mem_flush_req = mem_flush_req_int;
      end
    else
      begin : dont_gen_mem_flush_req
        assign mem_flush_req = 1'b0;
      end
  endgenerate

  assign afvalid_s = itctrl_ime ? it_afvalids : afvalids_func & dev_run;

  assign nxt_it_afvalids = itctrl_ime & (it_atb_ctr_2_wr_en ? it_atb_ctr_2_wdata : afvalid_s);

  always @(posedge clk or negedge reset_n)
  begin : s_it_afvalids
    if (!reset_n)
      it_afvalids <= 1'b0;
    else if (cg_en)
      it_afvalids <= nxt_it_afvalids;
  end

  assign nxt_flushcomp = itctrl_ime ? (it_evt_intr_wr_en ? it_evt_intr_wdata : flushcomp)
                                    :  nxt_flushcomp_func;

  always @(posedge clk or negedge reset_n)
  begin : s_flushcomp
    if (!reset_n)
      flushcomp <= 1'b0;
    else if (cg_en)
      flushcomp <= nxt_flushcomp;
  end

  assign nxt_flush_fsm_busy = (nxt_flush_state != ST_FLUSH_IDLE);

  always @(posedge clk_g or negedge reset_n)
  begin : s_flush_fsm_busy
    if (!reset_n)
      flush_fsm_busy <= 1'b0;
    else
      flush_fsm_busy <= nxt_flush_fsm_busy;
  end

  assign hold_stop_req = (flush_state == ST_EXTERNAL_FLUSH) |
                         (flush_state == ST_TRIG_WAIT) |
                         (flush_state == ST_TRIG_PKT_WAIT) |
                         (flush_state == ST_FLUSH_WAIT) |
                         (flush_state == ST_EMBED_TRIG) |
                         (flush_state == ST_EMBED_FLUSH) |
                         (flush_state == ST_TRIG_ON_FLUSH) |
                         ((flush_state == ST_FORMATTER_FLUSH) & ~ft_flush_ack);

  assign hold_trig_req = ft_flush_in_prog & ~ft_flush_ack;

  assign nxt_ft_flush_in_prog = (nxt_flush_state == ST_FLUSH_WAIT) |
                                (nxt_flush_state == ST_EMBED_TRIG) |
                                (nxt_flush_state == ST_EMBED_FLUSH) |
                                (nxt_flush_state == ST_TRIG_ON_FLUSH) |
                                (nxt_flush_state == ST_FORMATTER_FLUSH);

  always @ (posedge clk_g or negedge reset_n)
  begin : s_ft_flush_in_prog
    if (!reset_n)
      ft_flush_in_prog <= 1'b0;
    else
      ft_flush_in_prog <= nxt_ft_flush_in_prog;
  end

  assign st_on_tc_en_detect = ~ctl_trace_capt_en;

  assign st_on_trig_detect = ffcr_stop_on_trig_evt_masked & trigger_event;

  assign st_on_fl_detect = ffcr_stop_on_fl & atbs_flush_done & ~f_on_atbm_serv_in_prog;

  generate
    if (FORMATTER_CONFIG == ETR)
      begin : gen_st_on_mem_err
        reg mem_err_q;
        assign st_on_mem_err_detect = mem_err & ~mem_err_q;

        always @(posedge clk)
        begin : p_mem_err_q
          if (cg_en)
            mem_err_q <= mem_err;
        end
      end
    else
      begin : dont_gen_st_on_mem_err
        assign st_on_mem_err_detect = 1'b0;
      end
  endgenerate

  assign nxt_st_on_tc_en_active = (st_on_tc_en_detect &
                                   ~(nxt_ft_trig_req | hold_stop_req)) |
                                  (st_tc_en_pend & ~hold_stop_req & ~nxt_ft_trig_req);

  assign nxt_st_on_trig_active = ((st_on_trig_detect | st_on_mem_err_detect) &
                                  ~(nxt_ft_trig_req | hold_stop_req)) |
                                 (st_on_trig_active & ~ffcr_stop_on_trig_evt_masked_clr) |
                                 (st_trig_pend & ~hold_stop_req & ~nxt_ft_trig_req);

  assign nxt_st_on_fl_active = (st_on_fl_detect &
                                ~(nxt_ft_trig_req | hold_stop_req)) |
                               (st_on_fl_active & ~ffcr_stop_on_fl_clr) |
                               (st_fl_pend & ~hold_stop_req & ~nxt_ft_trig_req);

  always @(posedge clk or negedge reset_n)
  begin : s_st_on_trg_flsh_actv
    if (!reset_n)
      begin
        st_on_trig_active <= 1'b0;
        st_on_fl_active   <= (FORMATTER_CONFIG == TPIU);
      end
    else if (cg_en)
      begin
        st_on_trig_active <= nxt_st_on_trig_active;
        st_on_fl_active   <= nxt_st_on_fl_active;
      end
  end

  assign nxt_st_tc_en_pend = (st_on_tc_en_detect &
                              (nxt_ft_trig_req | hold_stop_req)) |
                             (st_tc_en_pend & ~nxt_ft_stop_req);

  assign nxt_st_trig_pend = ((st_on_trig_detect | st_on_mem_err_detect) &
                             (nxt_ft_trig_req | hold_stop_req)) |
                            (st_trig_pend & ~nxt_ft_stop_req);

  assign nxt_st_fl_pend = (st_on_fl_detect &
                           (nxt_ft_trig_req | hold_stop_req)) |
                          (st_fl_pend & ~nxt_ft_stop_req);

  always @(posedge clk or negedge reset_n)
  begin : s_st_pend
    if (!reset_n)
      begin
        st_trig_pend  <= 1'b0;
        st_fl_pend    <= 1'b0;
      end
    else if (cg_en)
      begin
        st_trig_pend  <= nxt_st_trig_pend;
        st_fl_pend    <= nxt_st_fl_pend;
      end
  end

  generate
    if (FORMATTER_CONFIG != TPIU)
      begin : gen_st_tc_en_pend
        reg       st_tc_en_pend_int;
        always @(posedge clk or negedge reset_n)
        begin : s_st_tc_en_pend
          if (!reset_n)
            st_tc_en_pend_int <= 1'b0;
          else if (cg_en)
            st_tc_en_pend_int <= nxt_st_tc_en_pend;
        end
        assign st_tc_en_pend = st_tc_en_pend_int;
      end
    else
      begin : dont_gen_st_tc_en_pend
        assign st_tc_en_pend = 1'b0;
      end
  endgenerate

  assign nxt_stop_pending        = (nxt_st_tc_en_pend | nxt_st_trig_pend | nxt_st_fl_pend);
  assign     stop_pending        = (    st_tc_en_pend |     st_trig_pend |     st_fl_pend);

  assign nxt_ft_stop_req = nxt_st_on_tc_en_active |
                           nxt_st_on_trig_active |
                           nxt_st_on_fl_active;

  assign ft_stopped_rising = ft_stopped & ~ft_stopped_q;

  always @(posedge clk or negedge reset_n)
  begin : s_ft_stop_req
    if (!reset_n) begin
      ft_stop_req  <= 1'b1;
      ft_stopped_q <= 1'b1;
    end else if (cg_en) begin
      ft_stop_req  <= nxt_ft_stop_req;
      ft_stopped_q <= ft_stopped;
    end
  end


endmodule

