//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2004-2006, 2012, 2016-2018, 2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_trace_bridge
#(
  parameter ATB_DATA_WIDTH = 32
)
(
  traceclk_in,
  treset_n,


  trace_d_valid,
  trace_d,
  trace_d_ready,
  trace_d_stopped,
  trace_flush_req,
  trace_flush_ack,
  trace_idle,
  trace_idle_hsp,
  pab_tactive,

  fifo_empty,
  pop_fifo,
  fifo_r_data,

  gen_data,
  trace_pattern,
  trace_pattern_falling,
  trig_port_req,
  trig_port_done,
  trig_port_clken,
  pattern_complete,


  reg_update,
  curr_patt_mode,
  tprcr_pattcount,
  fscr_synccount,
  continuous_mode,
  formatter_enable,

  atb_syncreq
);


  input  wire                         traceclk_in;
  input  wire                         treset_n;


  output wire                         trace_d_valid;
  output wire  [31:0]                 trace_d;
  input  wire                         trace_d_ready;
  output wire                         trace_d_stopped;
  output reg                          trace_flush_req;
  input  wire                         trace_flush_ack;
  input  wire                         trace_idle;
  input  wire                         trace_idle_hsp;
  input  wire                         pab_tactive;

  input  wire                         fifo_empty;
  output wire                         pop_fifo;
  input  wire  [ATB_DATA_WIDTH+2-1:0] fifo_r_data;

  input  wire  [31:0]                 gen_data;
  input  wire                         trace_pattern;
  input  wire                         trace_pattern_falling;
  input  wire                         trig_port_req;
  output reg                          trig_port_done;
  output wire                         trig_port_clken;
  output wire                         pattern_complete;

  input  wire                         reg_update;
  input  wire   [1:0]                 curr_patt_mode;
  input  wire   [7:0]                 tprcr_pattcount;
  input  wire  [11:0]                 fscr_synccount;
  output wire                         continuous_mode;
  output wire                         formatter_enable;

  output wire                         atb_syncreq;


  wire             sync_insert_patt;
  wire             sync_insert_stop;
  wire             sync_insert_fscr;
  wire             sync_insert_ack;
  wire         nxt_sync_insert_pend;
  reg              sync_insert_pend;
  wire             sync_insert_active;
  reg              trace_pattern_falling_q;
  wire             nxt_trig_port_done;

  wire             dec_count_sync;
  wire             dec_count;
  wire [11:0]      reset_count;
  wire             restart_counter;
  wire             count_en;
  wire [11:0]      nxt_count;
  reg [11:0]       count;

  wire             fscr_synccount_disable;

  wire             fifo_stopped;
  reg              fifo_stopped_q;
  reg              fifo_stopped_q1;
  wire             fifo_stopped_falling;

  wire             nxt_atb_syncreq;
  reg              atb_syncreq_q;

  wire             fifo_data_available;
  wire             fifo_data_valid;

  wire         nxt_trace_last_word;
  wire             trace_last_word_ce;
  reg              trace_last_word;
  wire         nxt_trace_first_word;
  wire             trace_first_word_ce;
  reg              trace_first_word;
  wire             trace_flush_detect;
  wire         nxt_trace_flush_req;
  wire             trace_flush_req_ce;

  wire             fifo_data_flush_miss;
  wire             fifo_data_start;
  wire             fifo_data_stop;

  wire             fifo_r_data_start_bypass;
  wire             fifo_r_data_start_normal;
  wire             fifo_r_data_start_continuous;
  wire             fifo_r_data_start;
  wire             fifo_r_data_stop_on_fl;
  wire             fifo_r_data_stop_on_trig;
  wire             fifo_r_data_flush_nodata;
  wire             fifo_r_data_beacon;
  wire             fifo_r_data_flush_lastword;

  wire         nxt_fifo_stopped;
  wire         nxt_continuous_mode;
  reg              continuous_mode_q;
  wire         nxt_formatter_enable;
  reg              formatter_enable_q;

  assign fifo_r_data_stop_on_fl       =  fifo_r_data[ATB_DATA_WIDTH-1] & fifo_r_data_flush_lastword;
  assign fifo_r_data_stop_on_trig     = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH+0] == 2'b10)                    & ~fifo_empty;
  assign fifo_r_data_start_bypass     = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH-2] == 4'b1100)                  & ~fifo_empty;
  assign fifo_r_data_start_normal     = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH-2] == 4'b1110)                  & ~fifo_empty;
  assign fifo_r_data_start_continuous = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH-2] == 4'b1111)                  & ~fifo_empty;
  assign fifo_r_data_start            =  fifo_r_data_start_bypass | fifo_r_data_start_normal | fifo_r_data_start_continuous;
  assign fifo_r_data_flush_nodata     = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH-2] == 4'b1101)                  & ~fifo_empty;
  assign fifo_r_data_beacon           = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH+0] == 2'b01) & ~trace_last_word & ~fifo_empty;
  assign fifo_r_data_flush_lastword   = (fifo_r_data[ATB_DATA_WIDTH+1:ATB_DATA_WIDTH+0] == 2'b01) &  trace_last_word & ~fifo_empty;


  assign trace_last_word_ce  = pop_fifo;
  assign nxt_trace_last_word = pop_fifo ? fifo_r_data_beacon
                             :            trace_last_word
                             ;

  assign trace_flush_detect  = pop_fifo & fifo_r_data_flush_lastword                             ;

  assign trace_flush_req_ce  = pop_fifo
                             | ( trace_flush_req & trace_flush_ack)
                             | (~trace_flush_req & fifo_data_flush_miss & ~pab_tactive)
                             ;

  assign nxt_trace_flush_req = trace_flush_req ? ~trace_flush_ack
                             : trace_flush_detect
                             | fifo_data_flush_miss
                             ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_trace_flush_req
    if (!treset_n)
    begin
      trace_last_word          <= 1'b0;
      trace_flush_req          <= 1'b0;
    end
    else
    begin
      if (trace_last_word_ce)
        trace_last_word        <= nxt_trace_last_word;
      if (trace_flush_req_ce)
        trace_flush_req        <= nxt_trace_flush_req;
    end
  end


  assign trace_first_word_ce  = pop_fifo & ~fifo_data_start;
  assign nxt_trace_first_word = trace_first_word_ce ? trace_last_word
                              :                       trace_first_word
                              ;
  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_trace_first_word
    if (!treset_n)
    begin
      trace_first_word        <= 1'b1;
    end
    else
    begin
      if (trace_first_word_ce)
        trace_first_word      <= nxt_trace_first_word;
    end
  end


  assign nxt_formatter_enable = fifo_r_data_start ? fifo_r_data[ATB_DATA_WIDTH-1]
                              :                     formatter_enable_q
                              ;
  assign nxt_continuous_mode  = (fifo_r_data_start && ~(trace_pattern | trace_pattern_falling_q)) ? fifo_r_data[ATB_DATA_WIDTH-2]
                              :                     continuous_mode_q
                              ;
  assign nxt_fifo_stopped     = (fifo_r_data_start && ~trace_flush_req       ) ? 1'b0
                              : (fifo_r_data_stop_on_trig && trace_d_ready   ) ? 1'b1
                              : (fifo_r_data_stop_on_fl && trace_flush_detect) ? 1'b1
                              :                                                  fifo_stopped_q
                              ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_fifo_event
    if (!treset_n)
    begin
      formatter_enable_q      <= 1'b0;
      continuous_mode_q       <= 1'b0;
      fifo_stopped_q          <= 1'b1;
    end
    else
    begin
      formatter_enable_q      <= nxt_formatter_enable;
      continuous_mode_q       <= nxt_continuous_mode;
      fifo_stopped_q          <= nxt_fifo_stopped;
    end
  end

  assign continuous_mode      = nxt_continuous_mode;
  assign formatter_enable     = nxt_formatter_enable;
  assign fifo_stopped         = fifo_stopped_q;


  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_ftstopped_q
    if (!treset_n)
      fifo_stopped_q1          <= 1'b1;
    else
      fifo_stopped_q1          <= fifo_stopped;
  end
  assign fifo_stopped_falling = fifo_stopped_q1 & ~fifo_stopped;


  assign sync_insert_stop      = fifo_stopped_falling  & (formatter_enable|continuous_mode) & ~trace_pattern & ~trace_pattern_falling_q;
  assign sync_insert_patt      = trace_pattern_falling_q  & (formatter_enable|continuous_mode) & ~fifo_stopped  ;
  assign sync_insert_fscr      = ~fifo_empty & trace_last_word & (count==12'h001)
                               & ~fscr_synccount_disable       & (formatter_enable|continuous_mode) & (~trace_pattern | ~trace_pattern_falling | ~trace_pattern_falling_q);
  assign nxt_sync_insert_pend  = ( sync_insert_stop
                                 | sync_insert_patt
                                 | sync_insert_fscr
                                 | sync_insert_pend
                                 ) & ~sync_insert_ack
                                 ;
  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_sync_insert_pend
    if (!treset_n)
      sync_insert_pend <= 1'b0;
    else
      sync_insert_pend <= nxt_sync_insert_pend;
  end

  assign sync_insert_active    = (sync_insert_stop | sync_insert_pend) & trace_first_word
                                                                                          & ~fifo_stopped
                               ;
  assign sync_insert_ack       = (sync_insert_active & trace_d_valid & trace_d_ready)
                               | (sync_insert_pend                                        &  fifo_stopped)
                               ;


  assign fifo_data_available   = ~(trace_pattern | trace_pattern_falling_q | sync_insert_active | fifo_empty);
  assign fifo_data_flush_miss  = fifo_data_available & fifo_r_data_flush_nodata;
  assign fifo_data_stop        = fifo_data_available & fifo_r_data_stop_on_trig;
  assign fifo_data_start       = fifo_data_available & fifo_r_data_start;
  assign fifo_data_valid       = fifo_data_flush_miss ? 1'b0
                               : fifo_stopped         ? 1'b0
                               : fifo_data_start      ? 1'b0
                               :                        ~trace_flush_req & fifo_data_available
                               ;
  assign trace_d_valid         = trace_pattern
                               | sync_insert_active
                               | fifo_data_valid
                               ;
  assign trace_d               = trace_pattern      ? gen_data
                               : sync_insert_active ? 32'h7FFFFFFF
                               : fifo_data_valid    ? { ~fifo_r_data_flush_lastword
                                                      & fifo_r_data[31]
                                                      , fifo_r_data[30:0]
                                                      }
                               :                      {32{1'bx}}
                               ;
  assign trace_d_stopped       = ( fifo_empty
                                 | fifo_data_stop
                                 | fifo_data_start & trace_flush_req
                                 ) & ~trace_d_valid & fifo_stopped;


  assign pop_fifo              = (fifo_data_valid & trace_d_ready & ~fifo_data_stop)
                               | (fifo_data_flush_miss & trace_flush_ack & fifo_r_data_flush_nodata)
                               | (fifo_data_stop & trace_idle    )
                               | (fifo_data_stop & trace_idle_hsp)
                               | (fifo_data_start & ~trace_flush_req)
                               ;


  assign dec_count_sync = pop_fifo & trace_last_word & ~fscr_synccount_disable;

  assign dec_count = dec_count_sync
                   | trace_pattern & ~trace_pattern_falling
                   ;

  assign reset_count = (|(curr_patt_mode[1:0]) && ~trace_pattern_falling) ? {4'b0, tprcr_pattcount}
                     :                                                      fscr_synccount
                     ;
  assign fscr_synccount_disable = (fscr_synccount == 12'b0);

  assign restart_counter = (sync_insert_active & trace_d_ready                         )
                         | ((count == 12'b0) &  trace_pattern                          )
                         | (nxt_atb_syncreq  & ~trace_pattern & ~fscr_synccount_disable)
                         | (reg_update                                                 )
                         | (                   ~trace_pattern & fifo_stopped           )
                         | (sync_insert_patt & trace_first_word)
                         ;

  assign count_en = (restart_counter | dec_count);
  assign nxt_count = restart_counter ? reset_count : (count - 12'h001);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_dualfunccount
    if (!treset_n)
      count <= 12'b0;
    else if (count_en)
      count <= nxt_count;
  end

  assign nxt_atb_syncreq = (count == 12'b1) & dec_count_sync;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_atbsyncreq
    if (!treset_n)
      atb_syncreq_q <= 1'b0;
    else
      atb_syncreq_q <= nxt_atb_syncreq;
  end
  assign atb_syncreq = atb_syncreq_q & ~fifo_stopped;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_trace_data_fall
    if (!treset_n)
      trace_pattern_falling_q <= 1'b0;
    else
      trace_pattern_falling_q <= trace_pattern_falling;
  end

  assign nxt_trig_port_done = trig_port_req & ~(trace_pattern_falling_q | trace_pattern);
  assign trig_port_clken    = trig_port_req | trig_port_done;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_trig_port_done
    if (!treset_n)
      trig_port_done <= 1'b0;
    else
      trig_port_done <= nxt_trig_port_done;
  end


  assign pattern_complete = ((count == 12'h000) & trace_pattern);


endmodule

