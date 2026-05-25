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
//   Top level of css600_trace_formatter
//
//----------------------------------------------------------------------------


module css600_trace_formatter
#(
  parameter FORMATTER_CONFIG = 0,
  parameter ATB_DATA_WIDTH   = 32,
  parameter ATBYTES_WIDTH    = 2,
  parameter ITATBDATA0_WIDTH = 5
)
(
  input  wire                        clk,
  input  wire                        cg_en,
  input  wire                        clk_g,
  input  wire                        reset_n,


  input  wire [6:0]                  atid_s,
  input  wire [ATBYTES_WIDTH-1:0]    atbytes_s,
  input  wire [ATB_DATA_WIDTH-1:0]   atdata_s,
  input  wire                        atvalid_s,
  output wire                        atready_s,

  input  wire                        ffcr_en_formatting_masked,
  input  wire                        ffcr_trig_on_trig_evt_masked,
  input  wire                        ffcr_trig_on_trigin_masked,
  input  wire                        ffcr_flsh_on_trig_evt_masked,
  input  wire                        hw_fifo_mode,
  input  wire                        stall_on_stop,
  input  wire                        sts_triggered_clr,

  input  wire                        ctl_trace_capt_en_rise,
  input  wire                        frame_sync_req,
  input  wire                        trigin_rise,
  output  reg                        trig_pkt_wait,
  output wire                        trig_pkt_wait_done,
  output wire                    nxt_trig_in_wait,
  output  reg                        trig_in_wait,
  output wire                        trig_in_wait_done,
  output wire                        trg_ctr_decr_pulse,
  output wire [ATBYTES_WIDTH:0]      trg_ctr_decr_val,
  output wire                        trg_ctr_decr_fcb,
  output wire                        ft_running,
  output wire                        ft_stopped_q2,
  output wire                        ft_fifo_beat,

  input  wire                        trig_port_en,
  output wire                        trig_port_cdc_t,
  input  wire                        trig_port_done_sync,

  input  wire                        trg_zero,
  input  wire                    nxt_trg_evt_active,
  input  wire                        ft_retrig_req,
  input  wire                        ft_trig_req,
  input  wire [1:0]                  ft_trig_size,
  input  wire                        ft_flush_req,
  input  wire                        ft_flid_req,
  input  wire                        ft_stop_req,
  output wire                        ft_trig_ack,
  output wire                        ft_flush_ack,
  output wire                        ft_flid_ack,
  output wire                        ft_stopped,
  output wire                        ft_starting,
  output reg                         ft_stopped_done,
  input  wire                    nxt_stop_pending,
  input  wire                        stop_pending,
  input  wire                        st_fl_pend,
  input  wire                        st_trig_pend,
  input  wire                        ft_trig_pend,
  input  wire                        atbs_flush_done,
  output wire                    nxt_flush_wait,
  output reg                         flush_wait,
  input  wire                        hold_trig_req,
  input  wire                    nxt_t_on_trig_in_pend,
  input  wire                        t_on_trig_in_pend,

  output  reg [ATB_DATA_WIDTH-1:0]   ft_data,
  output wire                        ft_data_beacon,
  output wire                        ft_data_padded,
  output wire                        ft_data_valid,
  input  wire                        wb_ready,
  input  wire                    nxt_wb_ready,

  input  wire                        itctrl_ime,
  input  wire                        integ_mode_entry,
  input  wire                        it_atb_ctr_2_wr_en,
  input  wire                        it_atb_ctr_2_wdata,
  output wire [ITATBDATA0_WIDTH-1:0] it_atb_data_0,
  output wire [6:0]                  it_atids,
  output wire [ATBYTES_WIDTH-1:0]    it_atbytess,
  output wire                        it_atvalids,

  input  wire                        dev_run
);

  localparam ETB  = 0;
  localparam ETR  = 1;
  localparam ETF  = 2;
  localparam ETS  = 3;
  localparam TPIU = 4;

  localparam CTR_WIDTH           = (ATB_DATA_WIDTH == 32) ? 2 : 1;
  localparam LBS_WIDTH           = (ATB_DATA_WIDTH == 32) ? 6 : 4;

  localparam MAX_INPUT_BYTES     = (ATB_DATA_WIDTH == 32) ? 5 :
                                   (ATB_DATA_WIDTH == 64) ? 9 : 17;

  localparam WRITESIZE_WIDTH     = (ATB_DATA_WIDTH == 32) ? 3 :
                                   (ATB_DATA_WIDTH == 64) ? 4 : 5;

  localparam FIFOSIZE            = (ATB_DATA_WIDTH == 32) ? 8 :
                                   (ATB_DATA_WIDTH == 64) ? 16 : 32;

  localparam FIFOSIZE_WIDTH      = (ATB_DATA_WIDTH == 32) ? 4 :
                                   (ATB_DATA_WIDTH == 64) ? 5 : 6;

  localparam ROTATOR_WIDTH       = (ATB_DATA_WIDTH == 32) ? 72 :
                                   (ATB_DATA_WIDTH == 64) ? 144 : 288;

  localparam HALFROTATOR_WIDTH   = (ATB_DATA_WIDTH == 32) ? 36 :
                                   (ATB_DATA_WIDTH == 64) ? 72 : 144;

  localparam FIFOREG8_WIDTH      = (ATB_DATA_WIDTH == 32) ? 8 : 9;
  localparam FIFOREG16_WIDTH     = (ATB_DATA_WIDTH == 64) ? 8 : 9;

  localparam WRITESIZE_MAX_VALUE = {1'b1,{WRITESIZE_WIDTH-1{1'b0}}};
  localparam WRITESIZE_NONE      = {WRITESIZE_WIDTH{1'b0}};
  localparam WRITESIZE_ONE       = ({{WRITESIZE_WIDTH-1{1'b0}},1'b1});
  localparam WRITESIZE_TWO       = WRITESIZE_ONE + WRITESIZE_ONE;
  localparam WRITESIZE_THREE     = WRITESIZE_TWO + WRITESIZE_ONE;
  localparam WRITESIZE_FOUR      = WRITESIZE_TWO + WRITESIZE_TWO;

  localparam GT_32               = (ATB_DATA_WIDTH == 32) ? 0 : 1;

  localparam FORM_STOP_STATE_STOPPED     = 6'b000001;
  localparam FORM_STOP_STATE_RUNNING     = 6'b000010;
  localparam FORM_STOP_STATE_IBUF_DRAIN  = 6'b000100;
  localparam FORM_STOP_STATE_FINAL_ONE   = 6'b001000;
  localparam FORM_STOP_STATE_FRAME_ALIGN = 6'b010000;
  localparam FORM_STOP_STATE_FRAME_PAD   = 6'b100000;
  localparam FORM_STOP_STATE_DEFAULT     = 6'bxxxxxx;


  wire                           atreadys_func;
  wire                           atb_slv_stall;

  wire                           drop_pkt;
  wire                           trig_pkt_detect;
  wire                           trig_pkt_detect_masked;
  wire                       nxt_trig_pkt_wait;
  wire                           trigin_rise_masked;
  wire                       nxt_trigin_rise_ignore;

  wire                           ibuf_ignore_trg;
  wire                           ibuf_empty;
  wire                       nxt_ibuf_valid;
  reg                            ibuf_valid;
  wire                       nxt_ibuf_rd_en;
  reg                            ibuf_rd_en;
  wire                       nxt_ibuf_ready;
  wire                           ibuf_wr_en;
  reg                            ibuf_ready;
  wire                           ibuf_rd_done;
  wire                       nxt_ibuf_wait;
  wire                           ibuf_wait;

  reg  [6:0]                     ibuf_atid;
  reg  [ATBYTES_WIDTH-1:0]       ibuf_atbytes;
  reg  [ATB_DATA_WIDTH-1:0]      ibuf_atdata;
  reg                            ibuf_atvalid;

  wire                           insert_special;
  wire                           insert_flush;
  wire                           insert_trig;
  wire                           insert_notrig;
  wire                           insert_nullpad;
  wire                           insert_null;
  wire                           insert_one;
  wire                           insert_noone;
  wire                           double_padding;
  wire [6:0]                     special_pkt_id;
  wire [ATB_DATA_WIDTH-1:0]      special_pkt_data;
  wire [WRITESIZE_WIDTH-1:0]     null_pkt_size;
  wire                           dummy_net1;
  wire                           dummy_net2;

  wire                       nxt_first_id;
  reg                            first_id;
  wire                           repeat_id;
  wire [7:0]                 nxt_id_repeat_cnt;
  reg  [7:0]                     id_repeat_cnt;
  wire                           insert_id;

  wire [WRITESIZE_WIDTH-1:0]     atb_size;
  wire [WRITESIZE_WIDTH-1:0]     write_size_no_id;
  wire [WRITESIZE_WIDTH-1:0]     write_size;

  wire [6:0]                 nxt_ftin_id;
  reg  [6:0]                     ftin_id;
  wire [ATB_DATA_WIDTH-1:0]  nxt_ftin_data;

  wire [FIFOSIZE_WIDTH-1:0]  nxt_fifo_level_post_rd;
  wire [FIFOSIZE_WIDTH-1:0]  nxt_fifo_level_post_rd_wr;
  wire [FIFOSIZE_WIDTH-1:0]  nxt_fifo_level;
  reg  [FIFOSIZE_WIDTH-1:0]      fifo_level;

  wire                           ftin_accept;
  wire                       nxt_fifo_ready;
  wire                           fifo_ready;

  wire                       nxt_read_not_frame_end;
  wire                       nxt_read_frame_end;
  wire                           read_not_frame_end;
  wire                           read_frame_end;
  wire                       nxt_read_nothing;
  wire                           read_nothing;
  wire [WRITESIZE_WIDTH-1:0] nxt_read_size;
  wire [WRITESIZE_WIDTH-1:0]     read_size;
  wire                       nxt_fifo_rd_req;
  wire                           fifo_rd_req;
  wire [CTR_WIDTH-1:0]       nxt_frame_pos_ctr;
  wire [CTR_WIDTH-1:0]           frame_pos_ctr;

  wire [ATB_DATA_WIDTH-1:0]      fifo_rdata;
  wire                           fifo_rdata_valid;

  reg  [5:0]                 nxt_form_stop_state;
  wire [5:0]                     form_stop_state;
  wire [5:0]                     form_stop_state_reset;
  reg  [4:0]                     form_stop_state_tmc;
  wire                           form_stop_state5_tpiu;
  reg                            form_stop_state_en;
  wire                           stop_position;
  wire                           stop_seq_ended;

  wire                           pipe_flushed;
  wire                           pipe_empty;
  reg                            pipe_empty_pre;
  wire                           ft_drain_done;
  wire                           last_ft_data;
  wire                           frame_align_entry;
  wire                           frame_pad_entry;

  wire [4:0]                     frame_size;
  reg  [4:0]                     curr_frame_intake;
  reg  [5:0]                     curr_frame_pair_intake;
  wire [FIFOSIZE_WIDTH-1:0]      bytes_to_drain;
  wire [FIFOSIZE_WIDTH-1:0]      auto_drain_ctr_init_val;
  wire                           init_auto_drain_ctr;
  wire                           decr_auto_drain_ctr;
  wire                           auto_drain_ctr_we;
  wire [FIFOSIZE_WIDTH-1:0]  nxt_auto_drain_ctr;
  reg  [FIFOSIZE_WIDTH-1:0]      auto_drain_ctr;
  wire                           skid_drain_actv;
  wire                           sync_insert;
  wire                           ft_flush_req_norm;
  wire                           ft_flush_req_byp;
  wire                           ft_flush_ack_norm;
  wire                           ft_flush_ack_byp;
  wire                           init_flush_ctr_byp;
  wire                           decr_flush_ctr_byp;
  wire                           flush_ctr_byp_we;
  wire [1:0]                 nxt_flush_ctr_byp;
  reg  [1:0]                     flush_ctr_byp;
  reg                            ft_flush_req_q;
  wire                           ft_data_stopped;
  wire                           ft_flush_stop_pending;

  wire [LBS_WIDTH-1:0]       nxt_lbs;
  reg  [LBS_WIDTH-1:0]           lbs;
  wire [LBS_WIDTH-1:0]           lbs_mask;

  wire [FIFOSIZE_WIDTH-1:0]      rotation;
  wire [ROTATOR_WIDTH-1:0]       rotator_out;
  wire [HALFROTATOR_WIDTH-1:0]   rotate1;
  wire [HALFROTATOR_WIDTH-1:0]   rotate2;
  wire [HALFROTATOR_WIDTH-1:0]   rotate4;
  wire [HALFROTATOR_WIDTH-1:0]   rotate8;
  wire [HALFROTATOR_WIDTH-1:0]   rotate16;

  wire                           fifo_reg1_en;
  wire                           fifo_reg2_en;
  wire                           fifo_reg3_en;
  wire                           fifo_reg4_en;
  wire                           fifo_reg5_en;
  wire                           fifo_reg6_en;
  wire                           fifo_reg7_en;
  wire                           fifo_reg8_en;

  wire [8:0]                 nxt_fifo_reg1;
  wire [8:0]                 nxt_fifo_reg2;
  wire [8:0]                 nxt_fifo_reg3;
  wire [8:0]                 nxt_fifo_reg4;
  wire [8:0]                 nxt_fifo_reg5;
  wire [8:0]                 nxt_fifo_reg6;
  wire [8:0]                 nxt_fifo_reg7;
  wire [FIFOREG8_WIDTH-1:0]  nxt_fifo_reg8;

  reg  [8:0]                     fifo_reg1;
  reg  [8:0]                     fifo_reg2;
  reg  [8:0]                     fifo_reg3;
  reg  [8:0]                     fifo_reg4;
  reg  [8:0]                     fifo_reg5;
  reg  [8:0]                     fifo_reg6;
  reg  [8:0]                     fifo_reg7;
  reg  [FIFOREG8_WIDTH-1:0]      fifo_reg8;
  reg  [8:0]                     fifo_reg9;
  reg  [8:0]                     fifo_reg10;
  reg  [8:0]                     fifo_reg11;
  reg  [8:0]                     fifo_reg12;
  reg  [8:0]                     fifo_reg13;
  reg  [8:0]                     fifo_reg14;
  reg  [8:0]                     fifo_reg15;
  reg  [FIFOREG16_WIDTH-1:0]     fifo_reg16;
  reg  [8:0]                     fifo_reg17;
  reg  [8:0]                     fifo_reg18;
  reg  [8:0]                     fifo_reg19;
  reg  [8:0]                     fifo_reg20;
  reg  [8:0]                     fifo_reg21;
  reg  [8:0]                     fifo_reg22;
  reg  [8:0]                     fifo_reg23;
  reg  [8:0]                     fifo_reg24;
  reg  [8:0]                     fifo_reg25;
  reg  [8:0]                     fifo_reg26;
  reg  [8:0]                     fifo_reg27;
  reg  [8:0]                     fifo_reg28;
  reg  [8:0]                     fifo_reg29;
  reg  [8:0]                     fifo_reg30;
  reg  [8:0]                     fifo_reg31;
  reg  [7:0]                     fifo_reg32;

  wire                           equal_0;
  wire                           le_eq_1;
  wire                       nxt_le_eq_2;
  wire                           le_eq_2;
  wire                       nxt_le_eq_3;
  wire                           le_eq_3;
  wire                           le_eq_4;
  wire                           le_eq_5;
  wire                       nxt_le_eq_6;
  wire                           le_eq_6;
  wire                       nxt_le_eq_7;
  wire                           le_eq_7;

  wire                           le_eq_8;
  wire                           le_eq_9;
  wire                           le_eq_10;
  wire                           le_eq_11;
  wire                           le_eq_12;
  wire                           le_eq_13;
  wire                       nxt_le_eq_14;
  wire                           le_eq_14;
  wire                           le_eq_15;
  wire                       nxt_le_eq_15;

  wire                           le_eq_16;
  wire                           le_eq_17;
  wire                           le_eq_18;
  wire                           le_eq_19;
  wire                           le_eq_20;
  wire                           le_eq_21;
  wire                           le_eq_22;
  wire                           le_eq_23;
  wire                           le_eq_24;
  wire                           le_eq_25;
  wire                           le_eq_26;
  wire                           le_eq_27;
  wire                           le_eq_28;
  wire                           le_eq_29;
  wire                           le_eq_30;
  wire                           le_eq_31;

  wire                           trig_port;

  wire                           trg_ctr_nodecr_fcb;

  wire         tpiu_config;
  wire         frame_pos_ctr_is2;
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

  generate
    if (ATB_DATA_WIDTH == 32)
    begin : gen_itatbdata_32
      assign it_atb_data_0 = {ibuf_atdata[31], ibuf_atdata[23], ibuf_atdata[15],
                              ibuf_atdata[7],  ibuf_atdata[0]};
    end

    else if (ATB_DATA_WIDTH == 64)
    begin : gen_itatbdata_64
      assign it_atb_data_0 = {ibuf_atdata[63], ibuf_atdata[55], ibuf_atdata[47],
                              ibuf_atdata[39], ibuf_atdata[31], ibuf_atdata[23],
                              ibuf_atdata[15], ibuf_atdata[7],  ibuf_atdata[0]};
    end

    else
    begin : gen_itatbdata_128
      assign it_atb_data_0 = {ibuf_atdata[127], ibuf_atdata[119], ibuf_atdata[111],
                              ibuf_atdata[103], ibuf_atdata[95],  ibuf_atdata[87],
                              ibuf_atdata[79],  ibuf_atdata[71],  ibuf_atdata[63],
                              ibuf_atdata[55],  ibuf_atdata[47],  ibuf_atdata[39],
                              ibuf_atdata[31],  ibuf_atdata[23],  ibuf_atdata[15],
                              ibuf_atdata[7],   ibuf_atdata[0]};
    end
  endgenerate

  assign it_atids    = ibuf_atid;
  assign it_atbytess = ibuf_atbytes;
  assign it_atvalids = ibuf_atvalid;


  assign atready_s = itctrl_ime ? ibuf_ready : atreadys_func;

  assign atreadys_func     = (!dev_run                                                                     ) ? 1'b0
                           : (!ft_running                                                                  ) ? (~stall_on_stop)
                           : (atb_slv_stall                                                                ) ? 1'b0
                           :                                                                                   ibuf_ready
                           ;
  assign atb_slv_stall = (ft_flid_req | ft_flush_req | ft_stop_req | flush_wait) |
                         (trig_port_en & ((trig_pkt_wait_done & ~ffcr_flsh_on_trig_evt_masked) | ft_trig_req)) |
                         (ft_trig_req & (hold_trig_req | ibuf_valid | stop_pending));

  assign nxt_ibuf_ready =       itctrl_ime ? (it_atb_ctr_2_wr_en ? it_atb_ctr_2_wdata : ibuf_ready) :
                          integ_mode_entry ?  1'b0 : (~nxt_ibuf_valid | nxt_ibuf_rd_en);

  always @ (posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      ibuf_ready <= 1'b0;
    else if (cg_en)
      ibuf_ready <= nxt_ibuf_ready;
  end


  always @ (posedge clk)
  begin
    if (cg_en && ibuf_wr_en) begin
      ibuf_atid    <= atid_s;
      ibuf_atbytes <= atbytes_s;
      ibuf_atdata  <= atdata_s;
      ibuf_atvalid <= atvalid_s;
    end
  end

  always @ (posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        ibuf_valid <= 1'b0;
        ibuf_rd_en <= 1'b0;
      end
    else if (cg_en)
      begin
        ibuf_valid <= nxt_ibuf_valid;
        ibuf_rd_en <= nxt_ibuf_rd_en;
      end
  end

 generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_ibuf_ignore_trg
        wire nxt_ibuf_ignore_trg;
        reg      ibuf_ignore_trg_int;
        assign nxt_ibuf_ignore_trg = sts_triggered_clr & ibuf_valid
                                   | ibuf_ignore_trg & ~ibuf_rd_done
                                   ;
        always @ (posedge clk or negedge reset_n)
        begin : s_ibuf_ignore_trg
          if (!reset_n)
            ibuf_ignore_trg_int <= 1'b0;
          else if (cg_en)
            ibuf_ignore_trg_int <= nxt_ibuf_ignore_trg;
        end
        assign ibuf_ignore_trg  = ibuf_ignore_trg_int;
      end
    else
      begin : dont_gen_ibuf_ignore_trg
        assign ibuf_ignore_trg     = 1'b0;
      end
  endgenerate

  assign ibuf_wr_en = itctrl_ime | (ft_running & atvalid_s & atreadys_func & ~drop_pkt);

  assign drop_pkt = ~ffcr_en_formatting_masked & (atid_s[6:4] == 3'h7);

  assign nxt_ibuf_valid = (ibuf_wr_en | ~ibuf_empty) & ~itctrl_ime;

  assign nxt_ibuf_rd_en = ~nxt_ibuf_wait & nxt_ibuf_valid & nxt_fifo_ready;

  assign ibuf_rd_done = (ibuf_rd_en & ~insert_special) & (~tpiu_config | dev_run);
  assign ibuf_empty     = ~ibuf_valid | ibuf_rd_done;

  assign atb_size = ibuf_valid ? {1'b0,ibuf_atbytes} + WRITESIZE_ONE
                               : WRITESIZE_NONE;

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_ibuf_wait
        reg       ibuf_wait_int;
        assign nxt_ibuf_wait = ( (trig_in_wait & ~trig_in_wait_done & ~ibuf_valid)
                               | (ibuf_wait & ~ftin_accept)
                               )
                               & ((ffcr_trig_on_trig_evt_masked & trg_zero) | ffcr_trig_on_trigin_masked)
                             ;
        always @ (posedge clk or negedge reset_n)
        begin : s_ibuf_wait
          if (!reset_n) begin
            ibuf_wait_int <= 1'b0;
          end else if (cg_en) begin
            ibuf_wait_int <= nxt_ibuf_wait;
          end
        end
        assign ibuf_wait      = ibuf_wait_int;

      end
    else
      begin : dont_gen_ibuf_wait
        assign nxt_ibuf_wait  = 1'b0;
        assign ibuf_wait      = 1'b0;
      end
  endgenerate


  assign insert_special = insert_flush | insert_trig | insert_notrig | insert_nullpad | insert_null | insert_one;

  assign special_pkt_id   = ({7{insert_flush}}   & 7'h7B  ) |
                            ({7{insert_trig}}    & 7'h7D  ) |
                            ({7{insert_notrig}}  & ftin_id) |
                            ({7{insert_nullpad}} & 7'h00  ) |
                            ({7{insert_null}}    & 7'h00  );

  assign special_pkt_data = {{ATB_DATA_WIDTH-1{1'b0}}, insert_one & ~insert_noone}
                          ;

  assign {dummy_net1,null_pkt_size} = (insert_nullpad && ~wb_ready                                            ) ? {1'b0,WRITESIZE_NONE}
                                    : (insert_nullpad && stop_position                                        ) ? {1'b0,WRITESIZE_NONE}
                                    : (insert_nullpad && (  frame_pos_ctr_is2   ) && ffcr_en_formatting_masked) ? {1'b0,WRITESIZE_THREE}
                                    : (insert_nullpad && insert_id                                            ) ? {1'b0,WRITESIZE_THREE}
                                    : (insert_nullpad                                                         ) ? {1'b0,WRITESIZE_FOUR}
                                    : ((auto_drain_ctr > {1'b0,WRITESIZE_MAX_VALUE})                          ) ? {1'b0,WRITESIZE_MAX_VALUE}
                                    : (insert_id                                                              ) ? (auto_drain_ctr - {1'b0,WRITESIZE_ONE})
                                    :                                                                              auto_drain_ctr
                                    ;

  assign nxt_flush_wait = (flush_wait     && insert_notrig && ibuf_empty && ft_trig_ack ) ? 1'b0
                        : (atbs_flush_done                 & ~ibuf_empty                        )
                        | (flush_wait                      & ~ibuf_rd_done                      )
                        | (atbs_flush_done & insert_notrig                & ~ft_trig_ack        )
                        | (flush_wait      & insert_notrig                                      )
                        ;

  always @ (posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      flush_wait <= 1'b0;
    else if (cg_en)
      flush_wait <= nxt_flush_wait;
  end

  assign insert_flush  = ft_flid_req;
  assign ft_flid_ack   = insert_flush & ftin_accept;

  wire insert_notrig_then_trig = 1'b0;
  assign insert_trig   = ft_trig_req & ~trig_port_en
                       | insert_notrig_then_trig   & trig_port & trig_port_done_sync
                       ;
  assign insert_notrig = ft_trig_req &  trig_port_en
                       & ~(insert_notrig_then_trig & trig_port & trig_port_done_sync)
                       ;
  assign ft_trig_ack   = (insert_trig  & ftin_accept)
                       | (~insert_notrig_then_trig & trig_port & trig_port_done_sync)
                       ;


  assign nxt_fifo_level_post_rd = (fifo_level - {1'b0,read_size});
  assign nxt_fifo_level_post_rd_wr = (nxt_fifo_level_post_rd + {1'b0,write_size});

  assign nxt_fifo_level = ftin_accept ? nxt_fifo_level_post_rd_wr :
                                        nxt_fifo_level_post_rd;

  assign write_size_no_id = ({WRITESIZE_WIDTH{insert_trig}     } & {{WRITESIZE_WIDTH-2{1'b0}},ft_trig_size})
                          | ({WRITESIZE_WIDTH{insert_notrig}   } & WRITESIZE_NONE)
                          | ({WRITESIZE_WIDTH{insert_flush}    } & WRITESIZE_ONE)
                          | ({WRITESIZE_WIDTH{insert_one}      } & WRITESIZE_ONE)
                          | ({WRITESIZE_WIDTH{insert_nullpad}  } & null_pkt_size)
                          | ({WRITESIZE_WIDTH{insert_null}     } & null_pkt_size)
                          | ({WRITESIZE_WIDTH{~insert_special} } & atb_size)
                          ;

  assign write_size = (insert_id && (ibuf_valid || insert_special)) ? write_size_no_id + WRITESIZE_ONE :
                                                                      write_size_no_id;

  assign ftin_accept = (insert_special & fifo_ready
                        & (~insert_nullpad | wb_ready)
                       ) | ibuf_rd_done;

  assign fifo_ready     = (nxt_fifo_level_post_rd_wr <= FIFOSIZE[FIFOSIZE_WIDTH-1:0]);

  assign nxt_fifo_ready = ((nxt_fifo_level - {1'b0,nxt_read_size} + MAX_INPUT_BYTES[FIFOSIZE_WIDTH-1:0])
                             <= FIFOSIZE[FIFOSIZE_WIDTH-1:0]);

  assign nxt_ftin_id   = insert_special ? special_pkt_id : ibuf_atid;
  assign nxt_ftin_data = insert_special ? special_pkt_data : ibuf_atdata;


  assign insert_id = ffcr_en_formatting_masked & (first_id | repeat_id | (nxt_ftin_id != ftin_id)) & ~insert_notrig;

  assign nxt_first_id =  ctl_trace_capt_en_rise |
                        (first_id & (insert_notrig | ~(insert_id & ftin_accept)));

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      first_id <= 1'b0;
    else if (cg_en)
      first_id <= nxt_first_id;
  end

  always @ (posedge clk or negedge reset_n)
  begin : s_id_repeat_cnt
    if (!reset_n)
      id_repeat_cnt <= 8'h00;
    else if (cg_en)
      id_repeat_cnt <= nxt_id_repeat_cnt;
  end

  assign nxt_id_repeat_cnt = (ft_stopped || hw_fifo_mode) ?  8'h00 :
                                             ftin_accept  ? (insert_id ? {{(8-WRITESIZE_WIDTH){1'b0}},write_size_no_id}
                                                                       : (id_repeat_cnt + {{(8-WRITESIZE_WIDTH){1'b0}},write_size}))
                                                          :  id_repeat_cnt;

  assign repeat_id = id_repeat_cnt[7];


  always @ (posedge clk or negedge reset_n)
  begin : s_ft_ctl
    if (!reset_n)
      begin
        ftin_id    <= 7'b0;
        fifo_level <= {FIFOSIZE_WIDTH{1'b0}};
      end
    else if (cg_en)
      begin
        if (ftin_accept)
          ftin_id  <= nxt_ftin_id;
        fifo_level <= nxt_fifo_level;
      end
  end


  assign trig_pkt_detect = ft_running & atvalid_s & atreadys_func & (atid_s == 7'h7D);
  assign trig_pkt_detect_masked = trig_pkt_detect & (~tpiu_config | ~nxt_trg_evt_active);

  assign nxt_trig_pkt_wait  = trig_pkt_detect_masked | (trig_pkt_wait & ~trig_pkt_wait_done);
  assign nxt_trig_in_wait   = trigin_rise_masked     | (trig_in_wait  & ~trig_in_wait_done);
  assign trigin_rise_masked =  (tpiu_config && nxt_stop_pending      ) ? 1'b0
                            :  (tpiu_config && stop_pending          ) ? 1'b0
                            :  (tpiu_config && ft_stop_req           ) ? 1'b0
                            : ~(tpiu_config && nxt_trigin_rise_ignore) & trigin_rise
                            ;

  always @(posedge clk or negedge reset_n)
  begin : s_trig_pkt_wait
    if (!reset_n)
      trig_pkt_wait <= 1'b0;
    else if (cg_en)
      trig_pkt_wait <= nxt_trig_pkt_wait;
  end

  always @(posedge clk_g or negedge reset_n)
  begin : s_trig_in_wait
    if (!reset_n)
      trig_in_wait  <= 1'b0;
    else
      trig_in_wait  <= nxt_trig_in_wait;
  end

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trigin_rise_ignore
        wire ibuf_ready_masked;
        reg  trigin_rise_ignore_int;
        wire trigin_rise_ignore;

        assign ibuf_ready_masked = (!dev_run                                                                     ) ? 1'b0
                                 : (!ft_running                                                                  ) ? (~stall_on_stop)
                                 : ( trig_port_en && trig_pkt_wait_done                                          ) ? 1'b0
                                 : ( trig_port_en && ft_trig_req                                                 ) ? 1'b0
                                 : (~trig_port_en && ft_trig_req && (hold_trig_req || ibuf_valid || stop_pending)) ? 1'b0
                                 :                                                                                   ibuf_ready
                                 ;
        assign nxt_trigin_rise_ignore = (trig_pkt_wait_done & ~ibuf_ready_masked & ~nxt_trg_evt_active
                                                                                 & ffcr_trig_on_trig_evt_masked)
                                      | (trig_in_wait_done  & ~ibuf_ready_masked                               )
                                      | (trigin_rise_ignore & ~ibuf_ready_masked                               )
                                      | (nxt_t_on_trig_in_pend | t_on_trig_in_pend                             )
                                      ;
        always @(posedge clk or negedge reset_n)
        begin : s_trigin_rise_ignore
          if (!reset_n)
            trigin_rise_ignore_int <= 1'b0;
          else if (cg_en)
            trigin_rise_ignore_int <= nxt_trigin_rise_ignore;
        end
        assign trigin_rise_ignore = trigin_rise_ignore_int;
      end
    else
      begin : dont_gen_trigin_rise_ignore
        assign nxt_trigin_rise_ignore = 1'b0;
      end
  endgenerate

  assign trig_pkt_wait_done = trig_pkt_wait & ibuf_empty
                            & (~trig_port_en                             | (~ft_trig_req | ft_trig_ack))
                            ;
  assign trig_in_wait_done  = (!dev_run                                   ) ? 1'b0
                            : (trig_port_en && ft_trig_req && ~ft_trig_ack) ? 1'b0
                            : (tpiu_config  && ft_trig_req && ~ft_trig_ack) ? 1'b0
                            :                                                 trig_in_wait & (ibuf_empty | ibuf_wait)
                            ;

  assign trg_ctr_decr_pulse  = ~ibuf_ignore_trg & ftin_accept & ~insert_notrig;
  assign trg_ctr_decr_val    = (ft_retrig_req && ~trg_ctr_decr_fcb &&  ffcr_trig_on_trigin_masked                       ) ? WRITESIZE_ONE
                             : (ft_retrig_req &&  trg_ctr_decr_fcb &&  ffcr_trig_on_trigin_masked &&  trg_ctr_nodecr_fcb) ? WRITESIZE_NONE
                             : (ft_retrig_req &&  trg_ctr_decr_fcb &&  ffcr_trig_on_trigin_masked && ~trg_ctr_nodecr_fcb) ? WRITESIZE_ONE
                             : (ft_retrig_req                      && ~ffcr_trig_on_trigin_masked                       ) ? WRITESIZE_NONE
                             :                                                                                              write_size
                             ;

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trg_ctr_decr_fcb
        wire [FIFOSIZE_WIDTH:0] ftin_wcount;
        wire [FIFOSIZE_WIDTH:0] ftin_wcount_post_wr;

        assign ftin_wcount         = {1'b0,frame_pos_ctr,{(FIFOSIZE_WIDTH-CTR_WIDTH){1'b0}}}
                                   + {1'b0,fifo_level}
                                   ;
        assign ftin_wcount_post_wr = ftin_wcount
                                   + {2'b0,write_size}
                                   ;
        assign trg_ctr_decr_fcb    = ffcr_en_formatting_masked
                                   & (ftin_wcount_post_wr >= 5'd15)
                                   & (ftin_wcount         <= 5'd14)
                                   & trg_ctr_decr_pulse
                                   ;
        assign trg_ctr_nodecr_fcb  = trg_ctr_decr_fcb & (ftin_wcount == 5'd14);
      end
    else
      begin : dont_gen_trg_ctr_decr_fcb
        assign trg_ctr_decr_fcb    = 1'b0;
        assign trg_ctr_nodecr_fcb  = 1'b0;
      end
  endgenerate


  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_stop_pending_cond_with_fl
        assign ft_flush_stop_pending = st_fl_pend;
      end
    else
      begin : gen_stop_pending_cond
        assign ft_flush_stop_pending = stop_pending;
      end
  endgenerate


  always @ *
  begin : c_nxtformstopstate
    ft_stopped_done = 1'b0;
    case (form_stop_state)
      FORM_STOP_STATE_STOPPED :
        begin
          form_stop_state_en  = ~( ft_stop_req
                                 | ft_flush_req & ft_flush_stop_pending
                                 | tpiu_config & st_fl_pend & ~st_trig_pend
                                 | tpiu_config & st_fl_pend & ~st_trig_pend & ~(ft_trig_pend|ft_trig_req)
                                 | ft_flush_req & ~ft_flush_ack
                                 );
          nxt_form_stop_state = FORM_STOP_STATE_RUNNING;
          ft_stopped_done = form_stop_state_en & ft_data_stopped;
        end

      FORM_STOP_STATE_RUNNING :
        begin
          form_stop_state_en  = ft_stop_req | ft_flush_req_norm | (ft_flush_req_byp & ft_flush_stop_pending);
          nxt_form_stop_state = (!ibuf_empty) ? FORM_STOP_STATE_IBUF_DRAIN :
                                   !ffcr_en_formatting_masked ? FORM_STOP_STATE_FINAL_ONE :
                                                                FORM_STOP_STATE_FRAME_ALIGN;
        end

      FORM_STOP_STATE_IBUF_DRAIN :
        begin
          form_stop_state_en  = ibuf_empty;
          nxt_form_stop_state =    !ffcr_en_formatting_masked ? FORM_STOP_STATE_FINAL_ONE :
                                                                FORM_STOP_STATE_FRAME_ALIGN;
        end

      FORM_STOP_STATE_FINAL_ONE :
        begin
          form_stop_state_en  = ftin_accept;
          nxt_form_stop_state = FORM_STOP_STATE_FRAME_ALIGN;
        end

      FORM_STOP_STATE_FRAME_ALIGN :
        begin
          form_stop_state_en  = ft_drain_done;
          nxt_form_stop_state = {6{ tpiu_config}} & FORM_STOP_STATE_FRAME_PAD
                              | {6{~tpiu_config}} & FORM_STOP_STATE_STOPPED
                              ;
        end

      FORM_STOP_STATE_FRAME_PAD :
        begin
          form_stop_state_en  = (~tpiu_config & 1'bx)
                              | ( tpiu_config & fifo_rd_req & stop_position)
                              ;
          nxt_form_stop_state = {6{~tpiu_config}} & FORM_STOP_STATE_DEFAULT
                              | {6{ tpiu_config}} & FORM_STOP_STATE_STOPPED
                              ;
        end

      default :
        begin
          form_stop_state_en  = 1'bx;
          nxt_form_stop_state = FORM_STOP_STATE_DEFAULT;
        end
    endcase
  end

  always @ (posedge clk or negedge reset_n)
  begin : s_formstopstate
    if (!reset_n)
      form_stop_state_tmc <= form_stop_state_reset[4:0];
    else if (cg_en && form_stop_state_en)
      form_stop_state_tmc <= nxt_form_stop_state[4:0];
  end

  assign form_stop_state_reset = FORM_STOP_STATE_STOPPED;
  assign form_stop_state = {form_stop_state5_tpiu,form_stop_state_tmc};

  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_formstopstate_tpiu
        reg formstopstate5_tpiu_int;
        always @ (posedge clk or negedge reset_n)
        begin : s_formstopstate_tpiu
          if (!reset_n)
            formstopstate5_tpiu_int <= form_stop_state_reset[5];
          else if (cg_en && form_stop_state_en)
            formstopstate5_tpiu_int <= nxt_form_stop_state[5];
        end
        assign form_stop_state5_tpiu   = formstopstate5_tpiu_int;
      end
    else
      begin : dont_gen_formstopstate_tpiu
        assign form_stop_state5_tpiu   = 1'b0;
      end
  endgenerate


  assign insert_one = form_stop_state[3];
  assign insert_noone = tpiu_config & insert_id
                      | tpiu_config & insert_one & double_padding
                      ;
  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_double_padding
        wire nxt_double_padding;
        reg      double_padding_int;
        assign nxt_double_padding = (st_trig_pend & st_fl_pend & ft_trig_req)
                                  | (double_padding & ft_stop_req & ~ft_stopped)
                                  ;
        always @ (posedge clk or negedge reset_n)
        begin : s_double_padding
          if (!reset_n)
            double_padding_int <= 1'b0;
          else if (cg_en)
            double_padding_int <= nxt_double_padding;
        end
        assign double_padding  = double_padding_int;
      end
    else
      begin : dont_gen_double_padding
        assign double_padding     = 1'b0;
      end
  endgenerate

  assign insert_null = form_stop_state[4] & (|auto_drain_ctr);

  assign insert_nullpad = (tpiu_config & form_stop_state[5]);

  assign ft_running     = form_stop_state[1] | ~ft_stop_req;
  assign stop_seq_ended = form_stop_state[0];
  assign ft_stopped     = form_stop_state[0] & ft_stop_req & ~skid_drain_actv;
  assign last_ft_data   = (frame_align_entry | form_stop_state[4]) & ft_drain_done;

  generate
    if (((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETS) || (FORMATTER_CONFIG == TPIU)) && (ATB_DATA_WIDTH == 32))
      begin : gen_ft_flush_ack_norm_a
        assign ft_flush_ack_norm = form_stop_state[0] & ft_flush_req_norm & ~skid_drain_actv & ~sync_insert;
      end
    else
      begin : gen_ft_flush_ack_norm_b
        assign ft_flush_ack_norm = form_stop_state[0] & ft_flush_req_norm & ~skid_drain_actv;
      end
  endgenerate

  assign ft_flush_ack_byp   = ft_flush_stop_pending ? ft_flush_req_byp & form_stop_state[0]
                            :                         ft_flush_req_byp & ft_flush_req_q & ~(|flush_ctr_byp);

  assign ft_flush_req_norm  =  ffcr_en_formatting_masked & ft_flush_req;
  assign ft_flush_req_byp   = ~ffcr_en_formatting_masked & ft_flush_req;

  assign ft_flush_ack       = (ft_flush_ack_norm | ft_flush_ack_byp);

  always @ (posedge clk or negedge reset_n)
  begin : s_ft_flush_req_q
    if (!reset_n)
      ft_flush_req_q <= 1'b0;
    else if (cg_en)
      ft_flush_req_q <= ft_flush_req;
  end

  generate
    if (FORMATTER_CONFIG == ETR)
      begin : gen_ft_stopped_q2
        reg ft_stopped_q1_int;
        reg ft_stopped_q2_int;
        always @ (posedge clk or negedge reset_n)
        begin : s_ft_stopped_q
          if (!reset_n) begin
            ft_stopped_q1_int <= 1'b0;
            ft_stopped_q2_int <= 1'b0;
          end else if (cg_en) begin
            ft_stopped_q1_int <= ft_stopped;
            ft_stopped_q2_int <= ft_stopped_q1_int;
          end
        end

        assign ft_stopped_q2 = ft_stopped_q2_int;
      end
    else
      begin : dont_gen_ft_stopped_q2
        assign ft_stopped_q2 = 1'b0;
      end
  endgenerate


  assign frame_size = ffcr_en_formatting_masked ? 5'h0F : 5'h10;

  generate
    if (ATB_DATA_WIDTH == 32)
    begin : gen_curr_frame_intake_a
      always @*
      begin : c_curr_frame_intake
        case ({nxt_read_nothing, nxt_frame_pos_ctr})
          3'b100, 3'b011 : curr_frame_intake = frame_size;
          3'b101, 3'b000 : curr_frame_intake = frame_size - 5'h04;
          3'b110, 3'b001 : curr_frame_intake = frame_size - 5'h08;
          3'b111, 3'b010 : curr_frame_intake = frame_size - 5'h0C;
        endcase
      end
    end

    else if (ATB_DATA_WIDTH == 64)
    begin : gen_curr_frame_intake_b
      always @*
      begin : c_curr_frame_intake
        case ({nxt_read_nothing, nxt_frame_pos_ctr})
          2'b10, 2'b01 : curr_frame_intake = frame_size;
          2'b11, 2'b00 : curr_frame_intake = frame_size - 5'h08;
        endcase
      end
    end

    else if (((FORMATTER_CONFIG == ETB) || (FORMATTER_CONFIG == ETF)) && (ATB_DATA_WIDTH == 128))
    begin : gen_curr_frame_pair_intake
      always @*
        begin : c_curr_frame_pair_intake
          case ({nxt_read_nothing, nxt_frame_pos_ctr})
            2'b10, 2'b01 : curr_frame_pair_intake = {frame_size,1'b0};
            2'b11, 2'b00 : curr_frame_pair_intake = {1'b0, frame_size};
          endcase
        end
    end
  endgenerate

  assign bytes_to_drain = (nxt_fifo_level - {1'b0,nxt_read_size});

  generate
    if (ATB_DATA_WIDTH == 32)
    begin : gen_auto_drain_ctr_init_val_a
      assign {dummy_net2,
              auto_drain_ctr_init_val} = ({1'b0,bytes_to_drain} <= curr_frame_intake) ?
                                            (curr_frame_intake - {1'b0,bytes_to_drain}) :
                                            (frame_size - ({1'b0,bytes_to_drain} - curr_frame_intake));
    end

    else if (ATB_DATA_WIDTH == 64)
    begin : gen_auto_drain_ctr_init_val_b
      assign auto_drain_ctr_init_val = (bytes_to_drain <= curr_frame_intake) ?
                                          (curr_frame_intake - bytes_to_drain) :
                                          (frame_size - (bytes_to_drain - curr_frame_intake));
    end

    else
    begin : gen_auto_drain_ctr_init_val_c

      if ((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETS))
      begin : gen_auto_drain_ctr_init_val_c1
        assign auto_drain_ctr_init_val = (bytes_to_drain <= {1'b0,frame_size}) ? ({1'b0,frame_size} -  bytes_to_drain) :
                                         (bytes_to_drain <= {frame_size,1'b0}) ? ({frame_size,1'b0} -  bytes_to_drain)
                                                                               : ({1'b0,frame_size} - (bytes_to_drain - {frame_size,1'b0}));
      end

      else
      begin : gen_auto_drain_ctr_init_val_c2
        assign auto_drain_ctr_init_val = (bytes_to_drain <= curr_frame_pair_intake) ?
                                            (curr_frame_pair_intake - bytes_to_drain) :
                                            ({frame_size,1'b0} - (bytes_to_drain - curr_frame_pair_intake));
      end
    end
  endgenerate


  assign frame_align_entry   = ((form_stop_state[1] & ibuf_empty & ffcr_en_formatting_masked & (ft_stop_req | ft_flush_req)) |
                                (form_stop_state[2] & ibuf_empty & ffcr_en_formatting_masked) |
                                (form_stop_state[3] &  ftin_accept));

  assign init_auto_drain_ctr = (frame_align_entry & ~pipe_empty_pre)
                             | frame_pad_entry
                             ;
  assign frame_pad_entry     =   form_stop_state[4] & form_stop_state_en & tpiu_config;

  assign decr_auto_drain_ctr = form_stop_state[4] & ftin_accept
                             | form_stop_state[5] & ftin_accept & tpiu_config
                             ;

  assign auto_drain_ctr_we   = (init_auto_drain_ctr | decr_auto_drain_ctr);

  assign nxt_auto_drain_ctr  =  init_auto_drain_ctr ?  auto_drain_ctr_init_val
                                                    : (auto_drain_ctr - {1'b0,write_size});

  always @ (posedge clk or negedge reset_n)
  begin : s_auto_drain_ctr
    if (!reset_n)
      auto_drain_ctr <= {FIFOSIZE_WIDTH{1'b0}};
    else if (cg_en && auto_drain_ctr_we)
      auto_drain_ctr <= nxt_auto_drain_ctr;
  end


  assign init_flush_ctr_byp = ft_flush_req_byp & ~ft_flush_req_q;

  assign decr_flush_ctr_byp = ft_flush_req_byp & ft_fifo_beat & (|flush_ctr_byp);

  assign flush_ctr_byp_we   = init_flush_ctr_byp
                            | (frame_pad_entry & ~ffcr_en_formatting_masked)
                            | decr_flush_ctr_byp
                            ;

  assign nxt_flush_ctr_byp  = init_flush_ctr_byp                              ? nxt_fifo_level_post_rd_wr[(FIFOSIZE_WIDTH-1) -:2]
                            : (frame_pad_entry && ~ffcr_en_formatting_masked) ? 2'd3
                            :                                                   flush_ctr_byp - 2'b01
                            ;

  always @ (posedge clk or negedge reset_n)
  begin : s_flush_ctr_byp
    if (!reset_n)
      flush_ctr_byp <= 2'b00;
    else if (cg_en && flush_ctr_byp_we)
      flush_ctr_byp <= nxt_flush_ctr_byp;
  end


  assign rotation = (fifo_level +
                       {{FIFOSIZE_WIDTH-1{1'b0}}, insert_id} -
                       {1'b0,read_size});

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_nxt_frameposctr_a
        assign nxt_frame_pos_ctr = stop_seq_ended ? {CTR_WIDTH{1'b0}} :
                                  (fifo_rdata_valid ? frame_pos_ctr + {{(CTR_WIDTH-1){1'b0}},{1'b1}} :
                                                      frame_pos_ctr);
      end
  endgenerate

  generate
    if (GT_32 == 1)
      begin : c_nxt_frameposctr_b
        assign nxt_frame_pos_ctr =  stop_seq_ended ? 1'b0 :
                                   (fifo_rdata_valid ? ~frame_pos_ctr :
                                                        frame_pos_ctr);
      end
  endgenerate

  generate
    if (((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETS || (FORMATTER_CONFIG == TPIU))) && (ATB_DATA_WIDTH == 128))
      begin : gen_pipe_empty_a
        always @*
        begin : c_pipe_empty_pre
          case (form_stop_state)
            FORM_STOP_STATE_STOPPED :
              begin
                pipe_empty_pre = 1'b1;
              end
            FORM_STOP_STATE_RUNNING :
              begin
                pipe_empty_pre = ffcr_en_formatting_masked & (ft_stop_req | ft_flush_req) &
                                 (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}});
              end
            FORM_STOP_STATE_IBUF_DRAIN :
              begin
                pipe_empty_pre = ffcr_en_formatting_masked & ibuf_empty &
                                 (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}});
              end
            FORM_STOP_STATE_FINAL_ONE :
              begin
                pipe_empty_pre = (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}});
              end
            FORM_STOP_STATE_FRAME_ALIGN :
              begin
                pipe_empty_pre = 1'b1;
              end
            FORM_STOP_STATE_FRAME_PAD :
              begin
                pipe_empty_pre = 1'bx;
              end
            default :
              begin
                pipe_empty_pre = 1'bx;
              end
          endcase
        end

        assign pipe_empty = (tpiu_config & form_stop_state[5]) | form_stop_state[0] | (form_stop_state[4] & equal_0);

      end

    else
      begin : gen_pipe_empty_b
        always @*
        begin : c_pipe_empty_pre
          case (form_stop_state)
            FORM_STOP_STATE_STOPPED :
              begin
                pipe_empty_pre = 1'b1;
              end
            FORM_STOP_STATE_RUNNING :
              begin
                pipe_empty_pre = ffcr_en_formatting_masked & (ft_stop_req | ft_flush_req) &
                                 (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}}) &
                                 (nxt_read_nothing ? (nxt_frame_pos_ctr == {CTR_WIDTH{1'b0}})
                                                   : (nxt_frame_pos_ctr == {CTR_WIDTH{1'b1}}));
              end
            FORM_STOP_STATE_IBUF_DRAIN :
              begin
                pipe_empty_pre = ffcr_en_formatting_masked & ibuf_empty &
                                 (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}}) &
                                 (nxt_read_nothing ? (nxt_frame_pos_ctr == {CTR_WIDTH{1'b0}})
                                                   : (nxt_frame_pos_ctr == {CTR_WIDTH{1'b1}}));
              end
            FORM_STOP_STATE_FINAL_ONE :
              begin
                pipe_empty_pre = (bytes_to_drain == {FIFOSIZE_WIDTH{1'b0}}) &
                                 (nxt_read_nothing ? (nxt_frame_pos_ctr == {CTR_WIDTH{1'b0}})
                                                   : (nxt_frame_pos_ctr == {CTR_WIDTH{1'b1}}));
              end
            FORM_STOP_STATE_FRAME_ALIGN :
              begin
                pipe_empty_pre = 1'b1;
              end
            FORM_STOP_STATE_FRAME_PAD :
              begin
                pipe_empty_pre = (~tpiu_config & 1'bx)
                               | ( tpiu_config & 1'b0)
                               ;
              end
            default :
              begin
                pipe_empty_pre = 1'bx;
              end
          endcase
        end

        assign pipe_empty = (tpiu_config & form_stop_state[5]) | form_stop_state[0] | (form_stop_state[4] & equal_0 & (frame_pos_ctr == {CTR_WIDTH{1'b0}}));

      end
  endgenerate

  assign pipe_flushed = stop_position & fifo_rdata_valid & ~|nxt_fifo_level;
  assign ft_drain_done = pipe_empty | pipe_flushed;


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : rotate_atb32
        assign rotate1[35:0] =  rotation[0] ?
                              { 1'b0,nxt_ftin_data[23:16], 1'b0,nxt_ftin_data[15:8],
                                1'b0,nxt_ftin_data[7:0],   1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[31:24], 1'b0,nxt_ftin_data[23:16],
                                1'b0,nxt_ftin_data[15:8],  1'b0,nxt_ftin_data[7:0] };

        assign rotate2[35:0] =  rotation[1] ?
                              { rotate1[26:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[31:24], rotate1[35:9] };

        assign rotate4[35:0] =  rotation[2] ?
                              { rotate2[17:0], rotate1[8:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[31:24], rotate1[35:27],
                                rotate2[35:18] };

        assign rotator_out[71:0] = { rotate2[26:18], rotate4[35:0],
                                     rotate2[17:0],  rotate1[8:0] };
      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 64)
      begin : rotate_atb64
        assign rotate1[71:0] =  rotation[0] ?
                              { 1'b0,nxt_ftin_data[55:48], 1'b0,nxt_ftin_data[47:40],
                                1'b0,nxt_ftin_data[39:32], 1'b0,nxt_ftin_data[31:24],
                                1'b0,nxt_ftin_data[23:16], 1'b0,nxt_ftin_data[15:8],
                                1'b0,nxt_ftin_data[7:0],   1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[63:56], 1'b0,nxt_ftin_data[55:48],
                                1'b0,nxt_ftin_data[47:40], 1'b0,nxt_ftin_data[39:32],
                                1'b0,nxt_ftin_data[31:24], 1'b0,nxt_ftin_data[23:16],
                                1'b0,nxt_ftin_data[15:8],  1'b0,nxt_ftin_data[7:0] };

        assign rotate2[71:0] =  rotation[1] ?
                              { rotate1[62:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[63:56], rotate1[71:9] };

        assign rotate4[71:0] =  rotation[2] ?
                              { rotate2[53:0], rotate1[8:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[63:56], rotate1[71:63],
                                rotate2[71:18] };

        assign rotate8[71:0] =  rotation[3] ?
                              { rotate4[35:0], rotate2[17:0],
                                rotate1[8:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                              { 1'b0,nxt_ftin_data[63:56], rotate1[71:63],
                                rotate2[71:54], rotate4[71:36]};

        assign rotator_out[143:0] = { rotate4[44:36], rotate8[71:0],
                                      rotate4[35:0],  rotate2[17:0], rotate1[8:0] };
      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 128)
      begin : rotate_atb128
        assign rotate1[143:0] =  rotation[0] ?
                               { 1'b0,nxt_ftin_data[119:112],1'b0,nxt_ftin_data[111:104],
                                 1'b0,nxt_ftin_data[103:96], 1'b0,nxt_ftin_data[95:88],
                                 1'b0,nxt_ftin_data[87:80],  1'b0,nxt_ftin_data[79:72],
                                 1'b0,nxt_ftin_data[71:64],  1'b0,nxt_ftin_data[63:56],
                                 1'b0,nxt_ftin_data[55:48],  1'b0,nxt_ftin_data[47:40],
                                 1'b0,nxt_ftin_data[39:32],  1'b0,nxt_ftin_data[31:24],
                                 1'b0,nxt_ftin_data[23:16],  1'b0,nxt_ftin_data[15:8],
                                 1'b0,nxt_ftin_data[7:0],    1'b1,nxt_ftin_id[6:0],1'b0 } :
                               { 1'b0,nxt_ftin_data[127:120],1'b0,nxt_ftin_data[119:112],
                                 1'b0,nxt_ftin_data[111:104],1'b0,nxt_ftin_data[103:96],
                                 1'b0,nxt_ftin_data[95:88]  ,1'b0,nxt_ftin_data[87:80],
                                 1'b0,nxt_ftin_data[79:72]  ,1'b0,nxt_ftin_data[71:64],
                                 1'b0,nxt_ftin_data[63:56]  ,1'b0,nxt_ftin_data[55:48],
                                 1'b0,nxt_ftin_data[47:40]  ,1'b0,nxt_ftin_data[39:32],
                                 1'b0,nxt_ftin_data[31:24]  ,1'b0,nxt_ftin_data[23:16],
                                 1'b0,nxt_ftin_data[15:8]   ,1'b0,nxt_ftin_data[7:0] };

        assign rotate2[143:0] =  rotation[1] ?
                               { rotate1[134:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                               { 1'b0,nxt_ftin_data[127:120],rotate1[143:9] };

        assign rotate4[143:0] =  rotation[2] ?
                               { rotate2[125:0], rotate1[8:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                               { 1'b0,nxt_ftin_data[127:120], rotate1[143:135],
                                 rotate2[143:18] };

        assign rotate8[143:0] =  rotation[3] ?
                               { rotate4[107:0], rotate2[17:0],
                                 rotate1[8:0],   1'b1,nxt_ftin_id[6:0],1'b0 } :
                               { 1'b0,nxt_ftin_data[127:120], rotate1[143:135],
                                 rotate2[143:126], rotate4[143:36] };

        assign rotate16[143:0] =  rotation[4] ?
                                { rotate8[71:0], rotate4[35:0], rotate2[17:0],
                                  rotate1[8:0], 1'b1,nxt_ftin_id[6:0],1'b0 } :
                                { 1'b0,nxt_ftin_data[127:120], rotate1[143:135],
                                  rotate2[143:126], rotate4[143:108],
                                  rotate8[143:72] };

        assign rotator_out[287:0] = { rotate8[80:72], rotate16[143:0],
                                      rotate8[71:0],  rotate4[35:0],  rotate2[17:0],
                                      rotate1[8:0] };
      end
  endgenerate


  assign     equal_0 =     (fifo_level == {{FIFOSIZE_WIDTH-2{1'b0}},2'b00});
  assign     le_eq_1 =     (fifo_level <= {{FIFOSIZE_WIDTH-2{1'b0}},2'b01});
  assign     le_eq_2 =     (fifo_level <= {{FIFOSIZE_WIDTH-2{1'b0}},2'b10});
  assign nxt_le_eq_2 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-2{1'b0}},2'b10});
  assign     le_eq_3 =     (fifo_level <= {{FIFOSIZE_WIDTH-2{1'b0}},2'b11});
  assign nxt_le_eq_3 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-2{1'b0}},2'b11});
  assign     le_eq_4 =     (fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b100});
  assign     le_eq_5 =     (fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b101});
  assign     le_eq_6 =     (fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b110});
  assign     le_eq_7 =     (fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b111});

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fifocmp_atb64
        assign nxt_le_eq_6 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b110});
        assign nxt_le_eq_7 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-3{1'b0}},3'b111});
      end
  endgenerate

  generate
    if (GT_32 == 1)
      begin : c_fifocmp_atb64_atb128
        assign     le_eq_8  =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1000});
        assign     le_eq_9  =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1001});
        assign     le_eq_10 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1010});
        assign     le_eq_11 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1011});
        assign     le_eq_12 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1100});
        assign     le_eq_13 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1101});
        assign     le_eq_14 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1110});
        assign nxt_le_eq_14 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1110});
        assign     le_eq_15 =     (fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1111});
        assign nxt_le_eq_15 = (nxt_fifo_level <= {{FIFOSIZE_WIDTH-4{1'b0}},4'b1111});
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fifocmp_atb128
        assign     le_eq_16 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10000});
        assign     le_eq_17 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10001});
        assign     le_eq_18 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10010});
        assign     le_eq_19 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10011});
        assign     le_eq_20 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10100});
        assign     le_eq_21 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10101});
        assign     le_eq_22 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10110});
        assign     le_eq_23 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b10111});
        assign     le_eq_24 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11000});
        assign     le_eq_25 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11001});
        assign     le_eq_26 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11010});
        assign     le_eq_27 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11011});
        assign     le_eq_28 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11100});
        assign     le_eq_29 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11101});
        assign     le_eq_30 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11110});
        assign     le_eq_31 = (fifo_level <= {{FIFOSIZE_WIDTH-5{1'b0}},5'b11111});
      end
  endgenerate


  assign fifo_reg1_en = (equal_0 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg1_atb32
        assign nxt_fifo_reg1 = ((equal_0 && read_nothing) ||
                                (le_eq_3 && read_frame_end) ||
                                (le_eq_4 && read_not_frame_end)) ?
                                   rotator_out[8:0] :
                                (!le_eq_3 && read_frame_end) ?
                                   fifo_reg4 : fifo_reg5;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg1_atb64
        assign nxt_fifo_reg1 = ((equal_0 && read_nothing) ||
                                (le_eq_7 && read_frame_end) ||
                                (le_eq_8 && read_not_frame_end)) ?
                                   rotator_out[8:0] :
                                (!le_eq_7 && read_frame_end) ?
                                   fifo_reg8 : fifo_reg9;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg1_atb128
        assign nxt_fifo_reg1 = ((equal_0 && read_nothing)  ||
                                (le_eq_15 && read_frame_end) ||
                                (le_eq_16 && read_not_frame_end)) ?
                                   rotator_out[8:0] :
                                (!le_eq_15 && read_frame_end) ?
                                   fifo_reg16 : fifo_reg17;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg1
    if (cg_en && fifo_reg1_en)
      fifo_reg1 <= nxt_fifo_reg1;
  end


  assign fifo_reg2_en = (le_eq_1 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg2_atb32
        assign nxt_fifo_reg2 = ((le_eq_1 && read_nothing) ||
                                (le_eq_4 && read_frame_end)  ||
                                (le_eq_5 && read_not_frame_end)) ?
                                   rotator_out[17:9] :
                                (!le_eq_4 && read_frame_end) ?
                                   fifo_reg5 : fifo_reg6;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg2_atb64
        assign nxt_fifo_reg2 = ((le_eq_1 && read_nothing) ||
                                (le_eq_8 && read_frame_end) ||
                                (le_eq_9 && read_not_frame_end)) ?
                                   rotator_out[17:9] :
                                (!le_eq_8 && read_frame_end) ?
                                   fifo_reg9 : fifo_reg10;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg2_atb128
        assign nxt_fifo_reg2 = ((le_eq_1 && read_nothing)   ||
                                (le_eq_16 && read_frame_end) ||
                                (le_eq_17 && read_not_frame_end)) ?
                                   rotator_out[17:9] :
                                (!le_eq_16 && read_frame_end) ?
                                   fifo_reg17 : fifo_reg18;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg2
    if (cg_en && fifo_reg2_en)
      fifo_reg2 <= nxt_fifo_reg2;
  end


  assign fifo_reg3_en = (le_eq_2 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg3_atb32
        assign nxt_fifo_reg3 = ((le_eq_2 && read_nothing) ||
                                (le_eq_5 && read_frame_end) ||
                                (le_eq_6 && read_not_frame_end)) ?
                                   rotator_out[26:18] :
                                (!le_eq_5 && read_frame_end) ?
                                   fifo_reg6 : fifo_reg7;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg3_atb64
        assign nxt_fifo_reg3 = ((le_eq_2  && read_nothing) ||
                                (le_eq_9  && read_frame_end) ||
                                (le_eq_10 && read_not_frame_end)) ?
                                   rotator_out[26:18] :
                                (!le_eq_9 && read_frame_end) ?
                                   fifo_reg10 : fifo_reg11;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg3_atb128
        assign nxt_fifo_reg3 = ((le_eq_2  && read_nothing)  ||
                                (le_eq_17 && read_frame_end) ||
                                (le_eq_18 && read_not_frame_end)) ?
                                   rotator_out[26:18] :
                                (!le_eq_17 && read_frame_end) ?
                                   fifo_reg18 : fifo_reg19;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg3
    if (cg_en && fifo_reg3_en)
      fifo_reg3 <= nxt_fifo_reg3;
  end


  assign fifo_reg4_en = (le_eq_3 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg4_atb32
        assign nxt_fifo_reg4 = ((le_eq_3 && read_nothing) ||
                                (le_eq_6 && read_frame_end) ||
                                (le_eq_7 && read_not_frame_end)) ?
                                   rotator_out[35:27] :
                                (!le_eq_6 && read_frame_end) ?
                                   fifo_reg7 : {1'b0,fifo_reg8};
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg4_atb64
        assign nxt_fifo_reg4 = ((le_eq_3  && read_nothing) ||
                                (le_eq_10 && read_frame_end) ||
                                (le_eq_11 && read_not_frame_end)) ?
                                   rotator_out[35:27] :
                                (!le_eq_10 && read_frame_end) ?
                                   fifo_reg11 : fifo_reg12;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg4_atb128
        assign nxt_fifo_reg4 = ((le_eq_3  && read_nothing)  ||
                                (le_eq_18 && read_frame_end) ||
                                (le_eq_19 && read_not_frame_end)) ?
                                   rotator_out[35:27] :
                                (!le_eq_18 && read_frame_end) ?
                                   fifo_reg19 : fifo_reg20;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg4
    if (cg_en && fifo_reg4_en)
      fifo_reg4 <= nxt_fifo_reg4;
  end


  assign fifo_reg5_en = (le_eq_4 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg5_atb32
        assign nxt_fifo_reg5 = ((le_eq_4 && read_nothing) ||
                                (le_eq_7 & read_frame_end) ||
                                (read_not_frame_end)) ?
                                   rotator_out[44:36] : {1'b0,fifo_reg8};
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg5_atb64
        assign nxt_fifo_reg5 = ((le_eq_4 && read_nothing) ||
                                (le_eq_11 && read_frame_end) ||
                                (le_eq_12 && read_not_frame_end)) ?
                                   rotator_out[44:36] :
                                (!le_eq_11 && read_frame_end) ?
                                   fifo_reg12 : fifo_reg13;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg5_atb128
        assign nxt_fifo_reg5 = ((le_eq_4  && read_nothing)  ||
                                (le_eq_19 && read_frame_end) ||
                                (le_eq_20 && read_not_frame_end)) ?
                                   rotator_out[44:36] :
                                (!le_eq_19 && read_frame_end) ?
                                   fifo_reg20 : fifo_reg21;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg5
    if (cg_en && fifo_reg5_en)
      fifo_reg5 <= nxt_fifo_reg5;
  end


  assign fifo_reg6_en = (le_eq_5 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg6_atb32
        assign nxt_fifo_reg6 = rotator_out[53:45];
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg6_atb64
        assign nxt_fifo_reg6 = ((le_eq_5 && read_nothing)  ||
                                (le_eq_12 && read_frame_end) ||
                                (le_eq_13 && read_not_frame_end)) ?
                                   rotator_out[53:45] :
                                (!le_eq_12 && read_frame_end) ?
                                   fifo_reg13 : fifo_reg14;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg6_atb128
        assign nxt_fifo_reg6 = ((le_eq_5  && read_nothing)  ||
                                (le_eq_20 && read_frame_end) ||
                                (le_eq_21 && read_not_frame_end)) ?
                                   rotator_out[53:45] :
                                (!le_eq_20 && read_frame_end) ?
                                   fifo_reg21 : fifo_reg22;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg6
    if (cg_en && fifo_reg6_en)
      fifo_reg6 <= nxt_fifo_reg6;
  end


  assign fifo_reg7_en = (le_eq_6 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg7_atb32
        assign nxt_fifo_reg7 = rotator_out[62:54];
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg7_atb64
        assign nxt_fifo_reg7 = ((le_eq_6  && read_nothing) ||
                                (le_eq_13 && read_frame_end) ||
                                (le_eq_14 && read_not_frame_end)) ?
                                   rotator_out[62:54] :
                                (!le_eq_13 && read_frame_end) ?
                                   fifo_reg14 : fifo_reg15;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg7_atb128
        assign nxt_fifo_reg7 = ((le_eq_6  && read_nothing)  ||
                                (le_eq_21 && read_frame_end) ||
                                (le_eq_22 && read_not_frame_end)) ?
                                   rotator_out[62:54] :
                                (!le_eq_21 && read_frame_end) ?
                                   fifo_reg22 : fifo_reg23;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg7
    if (cg_en && fifo_reg7_en)
      fifo_reg7 <= nxt_fifo_reg7;
  end


  assign fifo_reg8_en = (le_eq_7 & read_nothing) |
                         read_frame_end |
                         read_not_frame_end;

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fiforeg8_atb32
        assign nxt_fifo_reg8 = rotator_out[70:63];
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fiforeg8_atb64
        assign nxt_fifo_reg8 = ((le_eq_7 && read_nothing)  ||
                                (le_eq_14 && read_frame_end) ||
                                (le_eq_15 && read_not_frame_end)) ?
                                   rotator_out[71:63] :
                                (!le_eq_14 && read_frame_end) ?
                                   fifo_reg15 : {1'b0,fifo_reg16};
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fiforeg8_atb128
        assign nxt_fifo_reg8 = ((le_eq_7  && read_nothing)  ||
                                (le_eq_22 && read_frame_end) ||
                                (le_eq_23 && read_not_frame_end)) ?
                                   rotator_out[71:63] :
                                (!le_eq_22 && read_frame_end) ?
                                   fifo_reg23 : fifo_reg24;
      end
  endgenerate

  always @ (posedge clk)
  begin : s_fiforeg8
    if (cg_en && fifo_reg8_en)
      fifo_reg8 <= nxt_fifo_reg8;
  end


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg9

        wire       fifo_reg9_en;
        wire [8:0] nxt_fifo_reg9;

        assign fifo_reg9_en = (le_eq_8 & read_nothing) |
                               read_frame_end |
                               read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg9_atb64
            assign nxt_fifo_reg9 = ((le_eq_8 && read_nothing)  ||
                                    (le_eq_15 && read_frame_end) ||
                                    (read_not_frame_end)) ?
                                       rotator_out[80:72] : {1'b0,fifo_reg16};
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg9_atb128
            assign nxt_fifo_reg9 = ((le_eq_8  && read_nothing)  ||
                                    (le_eq_23 && read_frame_end) ||
                                    (le_eq_24 && read_not_frame_end)) ?
                                       rotator_out[80:72] :
                                    (!le_eq_23 && read_frame_end) ?
                                       fifo_reg24 : fifo_reg25;
          end

        always @ (posedge clk)
        begin : s_fiforeg9
          if (cg_en && fifo_reg9_en)
            fifo_reg9 <= nxt_fifo_reg9;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg10

        wire       fifo_reg10_en;
        wire [8:0] nxt_fifo_reg10;

        assign fifo_reg10_en = (le_eq_9 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg10_atb64
            assign nxt_fifo_reg10 = rotator_out[89:81];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg10_atb128
            assign nxt_fifo_reg10 = ((le_eq_9  && read_nothing)  ||
                                     (le_eq_24 && read_frame_end) ||
                                     (le_eq_25 && read_not_frame_end)) ?
                                        rotator_out[89:81] :
                                     (!le_eq_24 && read_frame_end) ?
                                        fifo_reg25 : fifo_reg26;
          end

        always @ (posedge clk)
        begin : s_fiforeg10
          if (cg_en && fifo_reg10_en)
            fifo_reg10 <= nxt_fifo_reg10;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg11

        wire       fifo_reg11_en;
        wire [8:0] nxt_fifo_reg11;

        assign fifo_reg11_en = (le_eq_10 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg11_atb64
            assign nxt_fifo_reg11 = rotator_out[98:90];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg11_atb128
            assign nxt_fifo_reg11 = ((le_eq_10 && read_nothing)  ||
                                     (le_eq_25 && read_frame_end) ||
                                     (le_eq_26 && read_not_frame_end)) ?
                                        rotator_out[98:90] :
                                     (!le_eq_25 && read_frame_end) ?
                                        fifo_reg26 : fifo_reg27;
          end

        always @ (posedge clk)
        begin : s_fiforeg11
          if (cg_en && fifo_reg11_en)
            fifo_reg11 <= nxt_fifo_reg11;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg12

        wire       fifo_reg12_en;
        wire [8:0] nxt_fifo_reg12;

        assign fifo_reg12_en = (le_eq_11 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg12_atb64
            assign nxt_fifo_reg12 = rotator_out[107:99];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg12_atb128
            assign nxt_fifo_reg12 = ((le_eq_11 && read_nothing)  ||
                                     (le_eq_26 && read_frame_end) ||
                                     (le_eq_27 && read_not_frame_end)) ?
                                        rotator_out[107:99] :
                                     (!le_eq_26 && read_frame_end) ?
                                        fifo_reg27 : fifo_reg28;
          end

        always @ (posedge clk)
        begin : s_fiforeg12
          if (cg_en && fifo_reg12_en)
            fifo_reg12 <= nxt_fifo_reg12;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg13

        wire       fifo_reg13_en;
        wire [8:0] nxt_fifo_reg13;

        assign fifo_reg13_en = (le_eq_12 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg13_atb64
            assign nxt_fifo_reg13 = rotator_out[116:108];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg13_atb128
            assign nxt_fifo_reg13 = ((le_eq_12 && read_nothing)  ||
                                     (le_eq_27 && read_frame_end) ||
                                     (le_eq_28 && read_not_frame_end)) ?
                                        rotator_out[116:108] :
                                     (!le_eq_27 && read_frame_end) ?
                                        fifo_reg28 : fifo_reg29;
          end

        always @ (posedge clk)
        begin : s_fiforeg13
          if (cg_en && fifo_reg13_en)
            fifo_reg13 <= nxt_fifo_reg13;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg14

        wire       fifo_reg14_en;
        wire [8:0] nxt_fifo_reg14;

        assign fifo_reg14_en = (le_eq_13 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg14_atb64
            assign nxt_fifo_reg14 = rotator_out[125:117];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg14_atb128
            assign nxt_fifo_reg14 = ((le_eq_13 && read_nothing)  ||
                                     (le_eq_28 && read_frame_end) ||
                                     (le_eq_29 && read_not_frame_end)) ?
                                        rotator_out[125:117] :
                                     (!le_eq_28 && read_frame_end) ?
                                        fifo_reg29 : fifo_reg30;
          end

        always @ (posedge clk)
        begin : s_fiforeg14
          if (cg_en && fifo_reg14_en)
            fifo_reg14 <= nxt_fifo_reg14;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg15

        wire        fifo_reg15_en;
        wire [8:0]  nxt_fifo_reg15;

        assign fifo_reg15_en = (le_eq_14 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg15_atb64
            assign nxt_fifo_reg15 = rotator_out[134:126];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg15_atb128
            assign nxt_fifo_reg15 = ((le_eq_14 && read_nothing)  ||
                                     (le_eq_29 && read_frame_end) ||
                                     (le_eq_30 && read_not_frame_end)) ?
                                        rotator_out[134:126] :
                                     (!le_eq_29 && read_frame_end) ?
                                        fifo_reg30 : fifo_reg31;
          end

        always @ (posedge clk)
        begin : s_fiforeg15
          if (cg_en && fifo_reg15_en)
            fifo_reg15 <= nxt_fifo_reg15;
        end

      end
  endgenerate


  generate
    if (GT_32 == 1)
      begin : gen_fiforeg16

        wire                       fifo_reg16_en;
        wire [FIFOREG16_WIDTH-1:0] nxt_fifo_reg16;

        assign fifo_reg16_en = (le_eq_15 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        if (ATB_DATA_WIDTH == 64)
          begin : c_fiforeg16_atb64
            assign nxt_fifo_reg16 = rotator_out[142:135];
          end

        if (ATB_DATA_WIDTH == 128)
          begin : c_fiforeg16_atb128
            assign nxt_fifo_reg16 = ((le_eq_15 && read_nothing)  ||
                                     (le_eq_30 && read_frame_end) ||
                                     (le_eq_31 && read_not_frame_end)) ?
                                        rotator_out[143:135] :
                                     (!le_eq_30 && read_frame_end) ?
                                        fifo_reg31 : {1'b0,fifo_reg32};
          end

        always @ (posedge clk)
        begin : s_fiforeg16
          if (cg_en && fifo_reg16_en)
            fifo_reg16 <= nxt_fifo_reg16;
        end

      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 128)
      begin : gen_fiforeg_17to32
        wire           fifo_reg17_en;
        wire           fifo_reg18_en;
        wire           fifo_reg19_en;
        wire           fifo_reg20_en;
        wire           fifo_reg21_en;
        wire           fifo_reg22_en;
        wire           fifo_reg23_en;
        wire           fifo_reg24_en;
        wire           fifo_reg25_en;
        wire           fifo_reg26_en;
        wire           fifo_reg27_en;
        wire           fifo_reg28_en;
        wire           fifo_reg29_en;
        wire           fifo_reg30_en;
        wire           fifo_reg31_en;
        wire           fifo_reg32_en;
        wire [8:0] nxt_fifo_reg17;
        wire [8:0] nxt_fifo_reg18;
        wire [8:0] nxt_fifo_reg19;
        wire [8:0] nxt_fifo_reg20;
        wire [8:0] nxt_fifo_reg21;
        wire [8:0] nxt_fifo_reg22;
        wire [8:0] nxt_fifo_reg23;
        wire [8:0] nxt_fifo_reg24;
        wire [8:0] nxt_fifo_reg25;
        wire [8:0] nxt_fifo_reg26;
        wire [8:0] nxt_fifo_reg27;
        wire [8:0] nxt_fifo_reg28;
        wire [8:0] nxt_fifo_reg29;
        wire [8:0] nxt_fifo_reg30;
        wire [8:0] nxt_fifo_reg31;
        wire [7:0] nxt_fifo_reg32;

        assign fifo_reg17_en = (le_eq_16 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg18_en = (le_eq_17 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg19_en = (le_eq_18 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg20_en = (le_eq_19 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg21_en = (le_eq_20 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg22_en = (le_eq_21 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg23_en = (le_eq_22 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg24_en = (le_eq_23 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg25_en = (le_eq_24 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg26_en = (le_eq_25 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg27_en = (le_eq_26 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg28_en = (le_eq_27 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg29_en = (le_eq_28 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg30_en = (le_eq_29 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg31_en = (le_eq_30 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign fifo_reg32_en = (le_eq_31 & read_nothing) |
                                read_frame_end |
                                read_not_frame_end;

        assign nxt_fifo_reg17 = ((le_eq_16 && read_nothing)  ||
                                 (le_eq_31 && read_frame_end) ||
                                  read_not_frame_end) ?
                                    rotator_out[152:144] : {1'b0,fifo_reg32};

        assign nxt_fifo_reg18 = rotator_out[161:153];
        assign nxt_fifo_reg19 = rotator_out[170:162];
        assign nxt_fifo_reg20 = rotator_out[179:171];
        assign nxt_fifo_reg21 = rotator_out[188:180];
        assign nxt_fifo_reg22 = rotator_out[197:189];
        assign nxt_fifo_reg23 = rotator_out[206:198];
        assign nxt_fifo_reg24 = rotator_out[215:207];
        assign nxt_fifo_reg25 = rotator_out[224:216];
        assign nxt_fifo_reg26 = rotator_out[233:225];
        assign nxt_fifo_reg27 = rotator_out[242:234];
        assign nxt_fifo_reg28 = rotator_out[251:243];
        assign nxt_fifo_reg29 = rotator_out[260:252];
        assign nxt_fifo_reg30 = rotator_out[269:261];
        assign nxt_fifo_reg31 = rotator_out[278:270];
        assign nxt_fifo_reg32 = rotator_out[286:279];

        always @ (posedge clk)
        begin : s_fiforeg_17to32
          if (cg_en && fifo_reg17_en)
            fifo_reg17 <= nxt_fifo_reg17;
          if (cg_en && fifo_reg18_en)
            fifo_reg18 <= nxt_fifo_reg18;
          if (cg_en && fifo_reg19_en)
            fifo_reg19 <= nxt_fifo_reg19;
          if (cg_en && fifo_reg20_en)
            fifo_reg20 <= nxt_fifo_reg20;
          if (cg_en && fifo_reg21_en)
            fifo_reg21 <= nxt_fifo_reg21;
          if (cg_en && fifo_reg22_en)
            fifo_reg22 <= nxt_fifo_reg22;
          if (cg_en && fifo_reg23_en)
            fifo_reg23 <= nxt_fifo_reg23;
          if (cg_en && fifo_reg24_en)
            fifo_reg24 <= nxt_fifo_reg24;
          if (cg_en && fifo_reg25_en)
            fifo_reg25 <= nxt_fifo_reg25;
          if (cg_en && fifo_reg26_en)
            fifo_reg26 <= nxt_fifo_reg26;
          if (cg_en && fifo_reg27_en)
            fifo_reg27 <= nxt_fifo_reg27;
          if (cg_en && fifo_reg28_en)
            fifo_reg28 <= nxt_fifo_reg28;
          if (cg_en && fifo_reg29_en)
            fifo_reg29 <= nxt_fifo_reg29;
          if (cg_en && fifo_reg30_en)
            fifo_reg30 <= nxt_fifo_reg30;
          if (cg_en && fifo_reg31_en)
            fifo_reg31 <= nxt_fifo_reg31;
          if (cg_en && fifo_reg32_en)
            fifo_reg32 <= nxt_fifo_reg32;
        end

      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : p2fifo_rdctrl_atb32
        wire nxt_stop_position;
        assign stop_position      = (frame_pos_ctr == 2'b11);

        assign read_not_frame_end = fifo_rd_req & ~le_eq_3 & ~stop_seq_ended &
                                    ~(ffcr_en_formatting_masked & stop_position);

        assign read_frame_end     = fifo_rd_req & ~le_eq_2 & stop_position &
                                    ffcr_en_formatting_masked;

        assign read_size          = ({3{read_not_frame_end}} & 3'b100) |
                                    ({3{read_frame_end}}     & 3'b011);

        assign nxt_stop_position      = (nxt_frame_pos_ctr == 2'b11);

        assign nxt_read_not_frame_end = nxt_fifo_rd_req & ~nxt_le_eq_3 &
                                        ~(ffcr_en_formatting_masked & nxt_stop_position);

        assign nxt_read_frame_end     = nxt_fifo_rd_req & ffcr_en_formatting_masked &
                                        ~nxt_le_eq_2 & nxt_stop_position;

        assign nxt_read_size          = ({3{nxt_read_not_frame_end}} & 3'b100) |
                                        ({3{nxt_read_frame_end}}     & 3'b011);

      end
    else if (ATB_DATA_WIDTH == 64)
      begin : p2fifo_rdctrl_atb64
        wire nxt_stop_position;
        assign stop_position      = (frame_pos_ctr == 1'b1);

        assign read_not_frame_end = fifo_rd_req & ~le_eq_7 & ~stop_seq_ended &
                                    ~(ffcr_en_formatting_masked & stop_position);

        assign read_frame_end     = fifo_rd_req & ~le_eq_6 & stop_position &
                                    ffcr_en_formatting_masked;

        assign read_size          = ({4{read_not_frame_end}} & 4'b1000) |
                                    ({4{read_frame_end}}     & 4'b0111);

        assign nxt_stop_position      = (nxt_frame_pos_ctr == 1'b1);

        assign nxt_read_not_frame_end = nxt_fifo_rd_req & ~nxt_le_eq_7 &
                                        ~(ffcr_en_formatting_masked & nxt_stop_position);

        assign nxt_read_frame_end     = nxt_fifo_rd_req & ~nxt_le_eq_6 & nxt_stop_position &
                                        ffcr_en_formatting_masked;

        assign nxt_read_size          = ({4{nxt_read_not_frame_end}} & 4'b1000) |
                                        ({4{nxt_read_frame_end}}     & 4'b0111);

      end
    else if (ATB_DATA_WIDTH == 128)
      begin : p2fifo_rdctrl_atb128
        assign stop_position      = (FORMATTER_CONFIG == ETR) | (FORMATTER_CONFIG == ETS) | (frame_pos_ctr == 1'b1);

        assign read_not_frame_end = fifo_rd_req & ~le_eq_15 & ~stop_seq_ended &
                                    ~ffcr_en_formatting_masked;

        assign read_frame_end     = fifo_rd_req & ~le_eq_14 & ~stop_seq_ended &
                                    ffcr_en_formatting_masked;

        assign read_size          = ({5{read_not_frame_end}} & 5'b10000) |
                                    ({5{read_frame_end}}     & 5'b01111);


        assign nxt_read_not_frame_end = nxt_fifo_rd_req & ~nxt_le_eq_15 &
                                        ~ffcr_en_formatting_masked;

        assign nxt_read_frame_end     = nxt_fifo_rd_req & ~nxt_le_eq_14 &
                                        ffcr_en_formatting_masked;

        assign nxt_read_size          = ({5{nxt_read_not_frame_end}} & 5'b10000) |
                                        ({5{nxt_read_frame_end}}     & 5'b01111);

      end
  endgenerate


  assign nxt_read_nothing = ~nxt_read_frame_end & ~nxt_read_not_frame_end;
  assign read_nothing     = ~read_frame_end     & ~read_not_frame_end;

  assign fifo_rdata_valid =  ~read_nothing & ~(stop_seq_ended & ft_stop_req);


  assign fifo_rdata[15:0] = ffcr_en_formatting_masked ?
                              fifo_reg2[8] ?
                                {fifo_reg1[7:0],fifo_reg2[7:1],fifo_reg2[8]} :
                                {fifo_reg2[7:0],fifo_reg1[7:1],fifo_reg1[8]} :
                              {fifo_reg2[7:0],fifo_reg1[7:0]};

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : c_fifo_rdata_part_a
        assign fifo_rdata[23:16] = ffcr_en_formatting_masked ?
                                    (read_not_frame_end ?
                                      (fifo_reg4[8] ?
                                        {fifo_reg4[7:1],fifo_reg4[8]} :
                                        {fifo_reg3[7:1],fifo_reg3[8]}) :
                                      (read_frame_end ?
                                        {fifo_reg3[7:1],fifo_reg3[8]} :
                                         fifo_reg3[7:0])) :
                                     fifo_reg3[7:0];

        assign fifo_rdata[29:24] = (ffcr_en_formatting_masked ?
                                     (read_not_frame_end ?
                                       (fifo_reg4[8] ? fifo_reg3[5:0] : fifo_reg4[5:0]) :
                                        lbs[5:0]) :
                                      fifo_reg4[5:0]);

        assign fifo_rdata[30] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg4[8] ? fifo_reg3[6] : fifo_reg4[6]) :
                                    (fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0])) :
                                   fifo_reg4[6]);

        assign fifo_rdata[31] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg4[8] ? fifo_reg3[7] : fifo_reg4[7]) :
                                     fifo_reg3[0]) :
                                   fifo_reg4[7]);
      end
  endgenerate


  generate
    if ((ATB_DATA_WIDTH == 64) || (ATB_DATA_WIDTH == 128))
      begin : c_fifo_rdata_part_b
        assign fifo_rdata[31:16] = ffcr_en_formatting_masked ?
                                     fifo_reg4[8] ?
                                      {fifo_reg3[7:0],fifo_reg4[7:1],fifo_reg4[8]} :
                                      {fifo_reg4[7:0],fifo_reg3[7:1],fifo_reg3[8]} :
                                    {fifo_reg4[7:0],fifo_reg3[7:0]};

        assign fifo_rdata[47:32] = ffcr_en_formatting_masked ?
                                     fifo_reg6[8] ?
                                      {fifo_reg5[7:0],fifo_reg6[7:1],fifo_reg6[8]} :
                                      {fifo_reg6[7:0],fifo_reg5[7:1],fifo_reg5[8]} :
                                    {fifo_reg6[7:0],fifo_reg5[7:0]};
      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 64)
      begin : c_fifo_rdata_part_c
        assign fifo_rdata[55:48] = ffcr_en_formatting_masked ?
                                    (read_not_frame_end ?
                                      (fifo_reg8[8] ?
                                        {fifo_reg8[7:1],fifo_reg8[8]} :
                                        {fifo_reg7[7:1],fifo_reg7[8]}) :
                                      (read_frame_end ?
                                        {fifo_reg7[7:1],fifo_reg7[8]} :
                                         fifo_reg7[7:0])) :
                                     fifo_reg7[7:0];

        assign fifo_rdata[59:56] = (ffcr_en_formatting_masked ?
                                     (read_not_frame_end ?
                                       (fifo_reg8[8] ? fifo_reg7[3:0] : fifo_reg8[3:0]) :
                                        lbs[3:0]) :
                                      fifo_reg8[3:0]);

        assign fifo_rdata[60] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg8[8] ? fifo_reg7[4] : fifo_reg8[4]) :
                                    (fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0])) :
                                 fifo_reg8[4]);

        assign fifo_rdata[61] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg8[8] ? fifo_reg7[5] : fifo_reg8[5]) :
                                    (fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0])) :
                                   fifo_reg8[5]);

        assign fifo_rdata[62] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg8[8] ? fifo_reg7[6] : fifo_reg8[6]) :
                                    (fifo_reg6[8] ? ~fifo_reg6[0] : fifo_reg5[0])) :
                                   fifo_reg8[6]);

        assign fifo_rdata[63] = (ffcr_en_formatting_masked ?
                                  (read_not_frame_end ?
                                    (fifo_reg8[8] ? fifo_reg7[7] : fifo_reg8[7]) :
                                     fifo_reg7[0]) :
                                   fifo_reg8[7]);
      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 128)
      begin : c_fifo_rdata_part_d
        assign fifo_rdata[63:48] = ffcr_en_formatting_masked ?
                                     fifo_reg8[8] ?
                                      {fifo_reg7[7:0],fifo_reg8[7:1],fifo_reg8[8]} :
                                      {fifo_reg8[7:0],fifo_reg7[7:1],fifo_reg7[8]} :
                                    {fifo_reg8[7:0],fifo_reg7[7:0]};

        assign fifo_rdata[79:64] = ffcr_en_formatting_masked ?
                                     fifo_reg10[8] ?
                                      {fifo_reg9[7:0],fifo_reg10[7:1],fifo_reg10[8]} :
                                      {fifo_reg10[7:0], fifo_reg9[7:1],fifo_reg9[8]} :
                                    {fifo_reg10[7:0],fifo_reg9[7:0]};

        assign fifo_rdata[95:80] = ffcr_en_formatting_masked ?
                                     fifo_reg12[8] ?
                                      {fifo_reg11[7:0],fifo_reg12[7:1],fifo_reg12[8]} :
                                      {fifo_reg12[7:0],fifo_reg11[7:1],fifo_reg11[8]} :
                                    {fifo_reg12[7:0],fifo_reg11[7:0]};

        assign fifo_rdata[111:96] = ffcr_en_formatting_masked ?
                                      fifo_reg14[8] ?
                                       {fifo_reg13[7:0],fifo_reg14[7:1],fifo_reg14[8]} :
                                       {fifo_reg14[7:0],fifo_reg13[7:1],fifo_reg13[8]} :
                                     {fifo_reg14[7:0],fifo_reg13[7:0]};

        assign fifo_rdata[119:112] = ffcr_en_formatting_masked ?
                                      {fifo_reg15[7:1],fifo_reg15[8]} :
                                      {fifo_reg15[7:0]};

        assign fifo_rdata[120] = (ffcr_en_formatting_masked ?
                                   (fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0]) :
                                    fifo_reg16[0]);

        assign fifo_rdata[121] = (ffcr_en_formatting_masked ?
                                   (fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0]) :
                                    fifo_reg16[1]);

        assign fifo_rdata[122] = (ffcr_en_formatting_masked ?
                                   (fifo_reg6[8] ? ~fifo_reg6[0] : fifo_reg5[0]) :
                                    fifo_reg16[2]);

        assign fifo_rdata[123] = (ffcr_en_formatting_masked ?
                                   (fifo_reg8[8] ? ~fifo_reg8[0] : fifo_reg7[0]) :
                                    fifo_reg16[3]);

        assign fifo_rdata[124] = (ffcr_en_formatting_masked ?
                                   (fifo_reg10[8] ?
                                     ~fifo_reg10[0] : fifo_reg9[0]) :
                                    fifo_reg16[4]);

        assign fifo_rdata[125] = (ffcr_en_formatting_masked ?
                                   (fifo_reg12[8] ?
                                     ~fifo_reg12[0] : fifo_reg11[0]) :
                                    fifo_reg16[5]);

        assign fifo_rdata[126] = (ffcr_en_formatting_masked ?
                                   (fifo_reg14[8] ?
                                     ~fifo_reg14[0] : fifo_reg13[0]) :
                                    fifo_reg16[6]);

        assign fifo_rdata[127] = ffcr_en_formatting_masked ?
                                   fifo_reg15[0] :
                                   fifo_reg16[7];
      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH != 128)
      begin : gen_lbs

        if (ATB_DATA_WIDTH == 32)
          begin : gen_lbs_mask_1

            assign lbs_mask[0] = (frame_pos_ctr == 2'b00);
            assign lbs_mask[1] = (frame_pos_ctr == 2'b00);
            assign lbs_mask[2] = (frame_pos_ctr == 2'b01);
            assign lbs_mask[3] = (frame_pos_ctr == 2'b01);
            assign lbs_mask[4] = (frame_pos_ctr == 2'b10);
            assign lbs_mask[5] = (frame_pos_ctr == 2'b10);

            assign nxt_lbs[5:0] = (read_not_frame_end && ffcr_en_formatting_masked) ?
                                   ((lbs_mask[5:0] &
                                      {fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0],
                                       fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0],
                                       fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0],
                                       fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0],
                                       fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0],
                                       fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0]}) | lbs[5:0]) :
                                    (read_not_frame_end && !ffcr_en_formatting_masked) ?
                                      {6{1'b0}} :
                                    ((read_frame_end && ffcr_en_formatting_masked) || stop_seq_ended) ?
                                      {6{1'b0}} : lbs[5:0];
          end
        else if (ATB_DATA_WIDTH == 64)
          begin : gen_lbs_mask_2

            assign lbs_mask[0] = (frame_pos_ctr == 1'b0);
            assign lbs_mask[1] = (frame_pos_ctr == 1'b0);
            assign lbs_mask[2] = (frame_pos_ctr == 1'b0);
            assign lbs_mask[3] = (frame_pos_ctr == 1'b0);

            assign nxt_lbs[3:0] = (read_not_frame_end && ffcr_en_formatting_masked) ?
                                    (lbs_mask[3:0] &
                                      {fifo_reg8[8] ? ~fifo_reg8[0] : fifo_reg7[0],
                                       fifo_reg6[8] ? ~fifo_reg6[0] : fifo_reg5[0],
                                       fifo_reg4[8] ? ~fifo_reg4[0] : fifo_reg3[0],
                                       fifo_reg2[8] ? ~fifo_reg2[0] : fifo_reg1[0]}) | lbs[3:0] :
                                    ((read_frame_end && ffcr_en_formatting_masked) || stop_seq_ended) ?
                                       {4{1'b0}} :
                                    (read_frame_end && !ffcr_en_formatting_masked) ?
                                       {4{1'b0}} : lbs[3:0];
          end

        always @ (posedge clk or negedge reset_n)
        begin : s_lbs
          if (!reset_n)
            lbs <= {LBS_WIDTH{1'b0}};
          else if (cg_en)
            lbs <= nxt_lbs;
        end

      end
  endgenerate

  generate
    if ((FORMATTER_CONFIG == ETB) || (FORMATTER_CONFIG == ETF) || (ATB_DATA_WIDTH != 128))
      begin : gen_frame_pos_ctr
        reg [CTR_WIDTH-1:0] frame_pos_ctr_int;

        always @ (posedge clk or negedge reset_n)
        begin : s_frameposctr
          if (!reset_n)
            frame_pos_ctr_int <= {CTR_WIDTH{1'b0}};
          else if (cg_en && fifo_rdata_valid)
            frame_pos_ctr_int <= nxt_frame_pos_ctr;
        end

        assign frame_pos_ctr = frame_pos_ctr_int;
      end
    else
      begin : dont_gen_frame_pos_ctr
        assign frame_pos_ctr = {CTR_WIDTH{1'b0}};
      end
  endgenerate


  assign ft_fifo_beat = fifo_rdata_valid & fifo_rd_req;

  generate
    if ((FORMATTER_CONFIG == ETR) || (FORMATTER_CONFIG == ETS))
      begin : gen_sync_insert_stage
        reg                       sync_insert_int;
        wire                      nxt_sync_insert;
        wire                      sync_insert_done;
        wire                      sync_aligned;
        wire                      sync_skid_buf_we;
        wire                      nxt_skid_drain_actv;

        assign nxt_sync_insert = (frame_sync_req & ~(last_ft_data & (ft_stop_req | stop_pending))) |
                                 (sync_insert & ~(sync_insert_done | ft_stopped));

        always @ (posedge clk or negedge reset_n)
        begin : s_sync_ins
          if (!reset_n)
            sync_insert_int <= 1'b0;
          else if (cg_en)
            sync_insert_int <= nxt_sync_insert;
        end

        assign sync_insert = sync_insert_int;

        assign sync_insert_done = sync_insert & ft_data_valid & wb_ready;


        if ((ATB_DATA_WIDTH == 64) || (ATB_DATA_WIDTH == 128))
          begin : gen_skid_buf_drain
            reg skid_drain_actv_int;

            assign nxt_skid_drain_actv = (form_stop_state[4] & ft_drain_done & ~sync_aligned) |
                                         (skid_drain_actv_int & ~wb_ready);

            always @ (posedge clk or negedge reset_n)
            begin : s_skid_drain_actv_int
              if (!reset_n)
                skid_drain_actv_int <= 1'b0;
              else if (cg_en)
                skid_drain_actv_int <= nxt_skid_drain_actv;
            end

            assign skid_drain_actv = skid_drain_actv_int;
          end
        else if (ATB_DATA_WIDTH == 32)
          begin : dont_gen_skid_buf_drain
            assign skid_drain_actv = 1'b0;
          end


        if (ATB_DATA_WIDTH == 32)
        begin : gen_fsp_data_32
          always @*
          begin : c_ft_data
            ft_data = sync_insert ? 32'h7FFF_FFFF : fifo_rdata;
          end

          assign ft_data_valid = fifo_rdata_valid | (sync_insert & wb_ready);

          assign fifo_rd_req = sync_insert ? 1'b0 : wb_ready;
          assign nxt_fifo_rd_req = nxt_sync_insert ? 1'b0 : nxt_wb_ready;
        end


        if (ATB_DATA_WIDTH == 64)
        begin : gen_fsp_data_64
          wire        nxt_sync_ctr;
          reg         sync_ctr;
          wire [31:0] nxt_sync_skid_buf;
          reg  [31:0] sync_skid_buf;
          wire        sync_stage_full;
          wire        nxt_sync_stage_full;

          assign nxt_sync_ctr =  ctl_trace_capt_en_rise ||
                                (skid_drain_actv && wb_ready) ? 1'b0 :
                                            sync_insert_done  ? ~sync_ctr : sync_ctr;

          always @ (posedge clk or negedge reset_n)
          begin : s_sync_ctr
            if (!reset_n)
              sync_ctr <= 1'b0;
            else if (cg_en)
              sync_ctr <= nxt_sync_ctr;
          end

          assign sync_skid_buf_we = fifo_rdata_valid & wb_ready & ~sync_aligned;
          assign sync_aligned = (sync_insert == sync_ctr);

          assign nxt_sync_skid_buf = fifo_rdata[63:32];

          always @ (posedge clk)
          begin : s_sync_skid_buf
            if (cg_en && sync_skid_buf_we)
              sync_skid_buf <= nxt_sync_skid_buf;
          end

          always @*
          begin : c_ft_data
            case ({skid_drain_actv, sync_insert, sync_ctr})
              3'b000,
              3'b100 : ft_data = fifo_rdata;
              3'b001 : ft_data = {fifo_rdata[31:0], sync_skid_buf[31:0]};
              3'b011,
              3'b101,
              3'b111 : ft_data = {32'h7FFF_FFFF, sync_skid_buf[31:0]};
              3'b010,
              3'b110 : ft_data = {fifo_rdata[31:0], 32'h7FFF_FFFF};
            endcase
          end

          assign sync_stage_full = (skid_drain_actv | sync_insert) & sync_ctr;
          assign nxt_sync_stage_full = (nxt_skid_drain_actv | nxt_sync_insert) & nxt_sync_ctr;

          assign ft_data_valid = fifo_rdata_valid | (sync_stage_full & wb_ready);

          assign fifo_rd_req = sync_stage_full ? 1'b0 : wb_ready;
          assign nxt_fifo_rd_req = nxt_sync_stage_full ? 1'b0 : nxt_wb_ready;

        end


        if (ATB_DATA_WIDTH == 128)
        begin : gen_fsp_data_128
          wire [1:0]  nxt_sync_ctr;
          reg  [1:0]  sync_ctr;
          reg  [95:0] nxt_sync_skid_buf;
          reg  [95:0] sync_skid_buf;
          wire        sync_stage_full;
          wire        nxt_sync_stage_full;

          assign nxt_sync_ctr =  ctl_trace_capt_en_rise ||
                                (skid_drain_actv && wb_ready) ?  2'b00 :
                                            sync_insert_done  ? (sync_ctr + 2'b01) : sync_ctr;

          always @ (posedge clk or negedge reset_n)
          begin : s_sync_ctr
            if (!reset_n)
              sync_ctr <= 2'b00;
            else if (cg_en)
              sync_ctr <= nxt_sync_ctr;
          end

          assign sync_skid_buf_we = fifo_rdata_valid & wb_ready & ~sync_aligned;
          assign sync_aligned = ({2{sync_insert}} == sync_ctr);

          always @*
          begin : c_nxt_sync_skid_buf
            case ({sync_insert, sync_ctr})
              3'b100,
              3'b001 : nxt_sync_skid_buf = {sync_skid_buf[95:32], fifo_rdata[127:96]};
              3'b101,
              3'b010 : nxt_sync_skid_buf = {sync_skid_buf[95:64], fifo_rdata[127:64]};
              3'b110,
              3'b011 : nxt_sync_skid_buf = fifo_rdata[127:32];
              3'b111,
              3'b000 : nxt_sync_skid_buf = sync_skid_buf;
            endcase
          end

          always @ (posedge clk)
          begin : s_sync_skid_buf
            if (cg_en && sync_skid_buf_we)
              sync_skid_buf <= nxt_sync_skid_buf;
          end

          always @*
          begin : c_ft_data
            case ({skid_drain_actv, sync_insert, sync_ctr})
              4'b0000,
              4'b1000 : ft_data = fifo_rdata[127:0];
              4'b0001 : ft_data = {fifo_rdata[95:0], sync_skid_buf[31:0]};
              4'b0010 : ft_data = {fifo_rdata[63:0], sync_skid_buf[63:0]};
              4'b0011 : ft_data = {fifo_rdata[31:0], sync_skid_buf[95:0]};
              4'b0100,
              4'b1100 : ft_data = {fifo_rdata[95:0], 32'h7FFF_FFFF};
              4'b0101 : ft_data = {fifo_rdata[63:0], 32'h7FFF_FFFF, sync_skid_buf[31:0]};
              4'b0110 : ft_data = {fifo_rdata[31:0], 32'h7FFF_FFFF, sync_skid_buf[63:0]};
              4'b1001,
              4'b1101 : ft_data = {{3{32'h7FFF_FFFF}}, sync_skid_buf[31:0]};
              4'b1010,
              4'b1110 : ft_data = {{2{32'h7FFF_FFFF}}, sync_skid_buf[63:0]};
              4'b0111,
              4'b1011,
              4'b1111 : ft_data = {32'h7FFF_FFFF, sync_skid_buf[95:0]};
            endcase
          end

          assign sync_stage_full = skid_drain_actv ? (sync_ctr != 2'b00)
                                                   : (sync_ctr == 2'b11) & sync_insert;
          assign nxt_sync_stage_full = nxt_skid_drain_actv ? (nxt_sync_ctr != 2'b00)
                                                           : (nxt_sync_ctr == 2'b11) & nxt_sync_insert;

          assign ft_data_valid = fifo_rdata_valid | (sync_stage_full & wb_ready);

          assign fifo_rd_req = sync_stage_full ? 1'b0 : wb_ready;
          assign nxt_fifo_rd_req = nxt_sync_stage_full ? 1'b0 : nxt_wb_ready;

        end
      end

    else
      begin : dont_gen_sync_insert_stage
        always @* ft_data          = fifo_rdata;
        assign ft_data_valid       = fifo_rdata_valid;
        assign fifo_rd_req         = wb_ready;
        assign nxt_fifo_rd_req     = nxt_wb_ready;
        assign skid_drain_actv     = 1'b0;
        assign sync_insert         = 1'b0;
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_dummy_net_a
        wire [1:0] dummy_net;
        assign dummy_net = {rotation[3],rotator_out[71]};
      end
    else if (ATB_DATA_WIDTH == 64)
      begin : gen_dummy_net_b
        wire [1:0] dummy_net;
        assign dummy_net = {rotation[4],rotator_out[143]};
      end
    else if (ATB_DATA_WIDTH == 128)
      begin : gen_dummy_net_c
        wire [1:0] dummy_net;
        assign dummy_net = {rotation[5],rotator_out[287]};
      end
  endgenerate

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_dummy_net3_a
        wire [0:0] dummy_net3;
        assign dummy_net3 = {1'b0};
      end
    else if (ATB_DATA_WIDTH == 64)
      begin : gen_dummy_net3_b
        wire [3:0] dummy_net3;
        assign dummy_net3 = {nxt_le_eq_15,nxt_le_eq_14,nxt_le_eq_3,nxt_le_eq_2};
      end
    else if (ATB_DATA_WIDTH == 128)
      begin : gen_dummy_net3_c
        wire [3:0] dummy_net3;
        assign dummy_net3 = {nxt_read_nothing,nxt_frame_pos_ctr,nxt_le_eq_3,nxt_le_eq_2};
      end
  endgenerate


  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_trig_port
        wire nxt_trig_port;
        reg      trig_port_int;
        assign nxt_trig_port = insert_notrig & ~trig_port_done_sync;
        always @ (posedge clk or negedge reset_n)
        begin : s_trig_port
          if (!reset_n)
            trig_port_int <= 1'b0;
          else if (cg_en)
            trig_port_int <= nxt_trig_port;
        end
        assign trig_port  = trig_port_int;
      end
    else
      begin : dont_gen_trig_port
        assign trig_port     = 1'b0;
      end
  endgenerate


    generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_flush_req
        assign ft_data_padded = form_stop_state[5] & stop_position & ft_data_valid;
        assign frame_pos_ctr_is2 = (frame_pos_ctr == 2'b10);
        assign ft_data_beacon = ~le_eq_3 & frame_pos_ctr_is2 & ft_data_valid;
        assign ft_starting    = form_stop_state[0] & form_stop_state_en;
      end
    else
      begin : dont_gen_flush_req
        assign ft_data_padded = 1'b0;
        assign frame_pos_ctr_is2 = 1'b0;
        assign ft_data_beacon = 1'b0;
        assign ft_starting    = 1'b0;
      end
  endgenerate


  generate
    if (FORMATTER_CONFIG == TPIU)
      begin : gen_ft_data_stopped
        wire nxt_ft_data_stopped;
        reg ft_data_stopped_int;
        assign nxt_ft_data_stopped = ft_stopped & ~ft_data_valid;
        always @ (posedge clk or negedge reset_n)
        begin : s_ft_data_stopped
          if (!reset_n) begin
            ft_data_stopped_int <= 1'b1;
          end else if (cg_en) begin
            ft_data_stopped_int <= nxt_ft_data_stopped;
          end
        end

        assign ft_data_stopped = ft_data_stopped_int;
      end
    else
      begin : dont_gen_ft_data_stopped
        assign ft_data_stopped = 1'b0;
      end
  endgenerate

    assign trig_port_cdc_t = trig_port;


endmodule
