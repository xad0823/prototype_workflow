//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009-2010, 2016-2017, 2020 Arm Limited or its affiliates.
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


module css600_tmc_unformatter
#(
  parameter ATB_DATA_WIDTH = 128,
  parameter ATBYTES_WIDTH  = 4
)
(
  input  wire                             clk,
  input  wire                             cg_en,
  input  wire                             clk_g,
  input  wire                             reset_n,

  input  wire                             unformatter_en,
  input  wire                             unformatter_stop,
  input  wire                             hw_fifo_mode,
  input  wire                             ctl_trace_capt_en,
  input  wire                             ctl_trace_capt_en_rise,
  input  wire                             tmc_ready,
  input  wire                             apbreadfifo_clr,
  output reg                              apb_read_fifo_rrp_en,
  output wire                             unformatter_empty,

  input  wire                             rrd_rd_req,
  output reg                              rrd_rd_ack,
  output wire                    [31:0]   rrd_rd_data,

  output wire                             rb_req_valid,
  input  wire                             rb_req_ready,
  input  wire                             rb_rdata_valid,
  input  wire      [2*ATB_DATA_WIDTH-1:0] rb_data,

  output reg                              atwakeup_m,
  output reg                        [6:0] atid_m,
  output reg          [ATBYTES_WIDTH-1:0] atbytes_m,
  output reg         [ATB_DATA_WIDTH-1:0] atdata_m,
  output reg                              atvalid_m,
  input  wire                             atready_m,
  input  wire                             afvalid_m,
  output reg                              afready_m,
  output wire                             nxt_afreadym,

  output reg                              atbm_flush_valid,
  input  wire                             atbm_flush_ready,

  input  wire                             dev_run,
  input  wire                             lp_done,

  input  wire                             itctrl_ime,
  input  wire                             it_atb_m_ctr_0_wr_en,
  input  wire                             it_atb_m_ctr_1_wr_en,
  input  wire                             it_atb_m_data_0_wr_en,
  input  wire [16:0]                      apb_wdata_p_bits16to0
);


  localparam RPTR_WIDTH               = (ATB_DATA_WIDTH == 128) ? 60 :
                                        (ATB_DATA_WIDTH == 64) ? 30 : 15;
  localparam RPTR_HALF                = (ATB_DATA_WIDTH == 128) ? 30 :
                                        (ATB_DATA_WIDTH == 64) ? 15 : 8;
  localparam RPTR_TOP_HALF            = (ATB_DATA_WIDTH == 128) ? 30 :
                                        (ATB_DATA_WIDTH == 64) ? 15 : 7;

  localparam SEL_WIDTH                = (ATB_DATA_WIDTH == 128) ?  6 :
                                        (ATB_DATA_WIDTH == 64) ? 5 : 4;

  localparam INPUT_BUFFER_WIDTH       = 2*ATB_DATA_WIDTH;

  localparam FRAME_WIDTH              = 128;

  localparam FRAME0_BUFFER_WIDTH      = (ATB_DATA_WIDTH == 32) ? 2*ATB_DATA_WIDTH :
                                        (ATB_DATA_WIDTH == 64) ? 2*ATB_DATA_WIDTH-8 :
                                                                 2*(ATB_DATA_WIDTH-8);

  localparam FRAME1_BUFFER_WIDTH      = (ATB_DATA_WIDTH == 128) ? 2*(ATB_DATA_WIDTH-8) :
                                                                  2*ATB_DATA_WIDTH-8;

  localparam FRAME_BUFFER_WIDTH       = FRAME0_BUFFER_WIDTH + FRAME1_BUFFER_WIDTH;

  localparam REQ_CNTR_WIDTH           = (ATB_DATA_WIDTH == 32) ? 3 : 2;

  localparam MAX_BUFFERS              = (ATB_DATA_WIDTH == 32) ? 4 : 3;

  localparam ATB_NUM_BYTES            = ATB_DATA_WIDTH/8;

  localparam FIFO_DEPTH               = (ATB_DATA_WIDTH == 128) ? 8 :
                                        (ATB_DATA_WIDTH == 64)  ? 4 : 2;

  localparam FIFO_DEPTH_MINUS_2       = (ATB_DATA_WIDTH == 128) ? 6 :
                                        (ATB_DATA_WIDTH == 64)  ? 2 : 0;

  localparam PTR_WIDTH                = (ATB_DATA_WIDTH == 128) ? 3 :
                                        (ATB_DATA_WIDTH == 64)  ? 2 : 1;

  localparam CONST_ONE                = 1;

  localparam FIFO_EMPTY               = 2'b00;
  localparam FIFO_REQ_RAISED          = 2'b01;
  localparam FIFO_NOT_EMPTY           = 2'b10;


  wire                                 unformatter_dis;
  wire                             nxt_unf_stop_in_prog;
  wire                                 unf_stop_in_prog;

  wire                             nxt_rb_req_valid_apb;
  reg                                  rb_req_valid_apb;
  reg                                  rb_req_set;
  reg              [PTR_WIDTH-1:0] nxt_apb_rptr;
  reg              [PTR_WIDTH-1:0]     apb_rptr;
  reg                              nxt_rrd_rd_ack;
  reg                              nxt_apb_read_fifo_rrp_en;
  reg                       [31:0]     apb_read_fifo[FIFO_DEPTH-1:0];
  reg                        [1:0] nxt_fifo_state;
  reg                        [1:0]     fifo_state;

  reg         [REQ_CNTR_WIDTH-1:0] nxt_req_cntr;
  reg         [REQ_CNTR_WIDTH-1:0]     req_cntr;
  wire                                 req_cntr_zero;
  wire                                 rb_req_valid_unf;

  wire                             nxt_input_buffer_stored;
  reg                                  input_buffer_stored;
  wire                                 input_buffer0_en;
  wire                                 input_buffer1_en;
  wire                                 input_buffer0_en_unf;
  wire                             nxt_input_buffer0_valid;
  wire                             nxt_input_buffer1_valid;
  reg                                  input_buffer0_valid;
  reg                                  input_buffer1_valid;
  reg     [INPUT_BUFFER_WIDTH-1:0]     input_buffer0;
  reg     [INPUT_BUFFER_WIDTH-1:0]     input_buffer1;
  wire                                 rdata_input_buf_valid;

  wire                                 frame_buffer0_en;
  wire                                 frame_buffer1_en;
  wire                                 frame_buffer0_clr;
  wire                                 frame_buffer1_clr;
  wire                             nxt_frame_buffer0_valid;
  wire                             nxt_frame_buffer1_valid;
  reg                                  frame_buffer0_valid;
  reg                                  frame_buffer1_valid;
  wire   [FRAME0_BUFFER_WIDTH-1:0] nxt_frame_buffer0;
  wire   [FRAME1_BUFFER_WIDTH-1:0] nxt_frame_buffer1;
  reg    [FRAME0_BUFFER_WIDTH-1:0]     frame_buffer0;
  reg    [FRAME1_BUFFER_WIDTH-1:0]     frame_buffer1;
  wire    [FRAME_BUFFER_WIDTH-1:0]     frame_buffer;

  wire        [REQ_CNTR_WIDTH-1:0]     total_valid_buffers;

  wire                                 rptr_clken;
  reg             [RPTR_WIDTH-1:0]     current_rptr;
  reg             [RPTR_WIDTH-1:0]     rptr_nxt_cycle;
  reg             [RPTR_WIDTH-1:0] nxt_rptr_nxt_cycle;
  reg            [ATB_NUM_BYTES:0]     rptr_nth_bit_id;
  reg              [SEL_WIDTH-1:0]     sel;
  reg              [SEL_WIDTH-1:0] nxt_sel;
  wire                                 f1_f0_bndry_crossing;
  wire                                 f1_f0_bndry_cross;

  wire                             nxt_rptr_in_frame0;
  wire                             nxt_wptr_in_frame0;
  reg                                  rptr_in_frame0;
  reg                                  wptr_in_frame0;

  wire                                 frame_id0_en;
  wire                                 frame_id1_en;
  wire             [RPTR_HALF-1:0]     temp_is_frame0_id;
  wire         [RPTR_TOP_HALF-1:0]     temp_is_frame1_id;
  wire             [RPTR_HALF-1:0] nxt_is_frame0_id;
  wire         [RPTR_TOP_HALF-1:0] nxt_is_frame1_id;
  reg              [RPTR_HALF-1:0]     is_frame0_id;
  reg          [RPTR_TOP_HALF-1:0]     is_frame1_id;

  wire            [RPTR_WIDTH-1:0] nxt_is_frame_id;

  wire            [RPTR_WIDTH-1:0] nxt_is_frame_id_fready;
  wire            [RPTR_WIDTH-1:0]     is_frame_id_fready;
  wire                                 atdata_for_1cycle_available_f0;
  wire                                 atdata_for_1cycle_available_f1;

  wire                             nxt_atb_data_avail;
  reg                                  atb_data_avail;
  reg                              nxt_atb_data_avail_stored;
  reg                                  atb_data_avail_stored;

  wire                             nxt_atvalidm_current;
  wire                       [6:0] nxt_atidm_current;
  wire         [ATBYTES_WIDTH-1:0] nxt_atbytesm_current;

  wire                                 atb_skid_ld;
  wire                             nxt_atb_skid_valid;
  reg                                  atb_skid_valid;
  reg                        [6:0]     atidm_skid;
  reg          [ATBYTES_WIDTH-1:0]     atbytesm_skid;
  reg         [ATB_DATA_WIDTH-1:0]     atdatam_skid;

  wire                                 atb_clken;
  wire                             nxt_atwakeupm;
  wire                       [6:0] nxt_atidm;
  wire         [ATBYTES_WIDTH-1:0] nxt_atbytesm;
  wire       [ATB_DATA_WIDTH-1:0]  nxt_atdatam;
  wire                                 atidm_skid_zero;
  wire                                 atidm_zero;
  wire                             nxt_atvalidm_detect;
  wire                             nxt_atvalidm_pend;
  reg                                  atvalidm_pend;
  wire                             nxt_atvalidm;

  wire                             nxt_atbm_flush_valid;
  wire                                 atbm_flush_done;
  reg         [REQ_CNTR_WIDTH-1:0]     flush_pending;
  reg                                  flush_done;
  wire        [REQ_CNTR_WIDTH-1:0] nxt_flush_pending;
  wire                             nxt_flush_done;

  wire                             nxt_last_frame_flush;
  wire                                 last_frame_flush;
  wire                             nxt_last_frame_flush0;
  wire                             nxt_last_frame_flush1;
  wire                                 last_frame_flush0;
  wire                                 last_frame_flush1;
  reg                              nxt_flush_frame0_last;
  reg                                  flush_frame0_last;

  integer i;
  integer j;
  integer k;
  integer m;
  integer n;
  integer l;

  wire  local_cg_en;


  assign local_cg_en = cg_en & dev_run;

  function automatic [15:0] frame_double_byte_mux;
    input [15:0] input_double_byte;
    input        aux_flag;
    reg   [15:0] output_double_byte;
  begin
    output_double_byte[0]    = input_double_byte[0] ? input_double_byte[8] : aux_flag;

    output_double_byte[7:1]  = (input_double_byte[0] && aux_flag) ?
                                  input_double_byte[15:9] : input_double_byte[7:1];
    output_double_byte[15:9] = (input_double_byte[0] && aux_flag) ?
                                  input_double_byte[7:1]  : input_double_byte[15:9];

    output_double_byte[8]    = input_double_byte[8];

    frame_double_byte_mux    = output_double_byte;
  end
  endfunction

  function automatic [119:0] input_frame_mux_fn;
    input [127:0] input_buffer;
    reg   [119:0] input_frame_mux;
    integer i;
  begin
    for (i=0; i<=6; i=i+1)
    begin
      input_frame_mux[i*16 +: 16] = frame_double_byte_mux(input_buffer[i*16 +: 16], input_buffer[120+i]);
    end

    input_frame_mux[119:113] = input_buffer[119:113];

    input_frame_mux[112]     = input_buffer[127];

    input_frame_mux_fn       = input_frame_mux;
  end
  endfunction

  function automatic [14:0] id_or_data_fn;
    input [127:0] input_buffer;
    reg    [14:0] id_or_data;
  begin
    id_or_data[0]  = input_buffer[0]  &  ~input_buffer[120];
    id_or_data[1]  = input_buffer[0]  &   input_buffer[120];
    id_or_data[2]  = input_buffer[16] &  ~input_buffer[121];
    id_or_data[3]  = input_buffer[16] &   input_buffer[121];
    id_or_data[4]  = input_buffer[32] &  ~input_buffer[122];
    id_or_data[5]  = input_buffer[32] &   input_buffer[122];
    id_or_data[6]  = input_buffer[48] &  ~input_buffer[123];
    id_or_data[7]  = input_buffer[48] &   input_buffer[123];
    id_or_data[8]  = input_buffer[64] &  ~input_buffer[124];
    id_or_data[9]  = input_buffer[64] &   input_buffer[124];
    id_or_data[10] = input_buffer[80] &  ~input_buffer[125];
    id_or_data[11] = input_buffer[80] &   input_buffer[125];
    id_or_data[12] = input_buffer[96] &  ~input_buffer[126];
    id_or_data[13] = input_buffer[96] &   input_buffer[126];
    id_or_data[14] = input_buffer[112];

    id_or_data_fn  = id_or_data;
  end
  endfunction


  always @*
  begin : c_apb_rd_fifo_fsm
    rb_req_set               = 1'b0;
    nxt_fifo_state           = fifo_state;
    nxt_rrd_rd_ack           = 1'b0;
    nxt_apb_rptr             = apb_rptr;
    nxt_apb_read_fifo_rrp_en = 1'b0;

    case (fifo_state)
      FIFO_EMPTY :
        begin
          nxt_apb_rptr             = apb_rptr;
          rb_req_set               = rrd_rd_req;
          nxt_fifo_state           = rrd_rd_req ? FIFO_REQ_RAISED : FIFO_EMPTY;
        end

      FIFO_REQ_RAISED :
        begin
          nxt_fifo_state           = rb_rdata_valid ? FIFO_NOT_EMPTY : FIFO_REQ_RAISED;
          nxt_rrd_rd_ack           = rb_rdata_valid;
          nxt_apb_rptr             = rb_rdata_valid ? {PTR_WIDTH{1'b0}} : apb_rptr;
        end

      FIFO_NOT_EMPTY :
        begin
          nxt_rrd_rd_ack           = rrd_rd_req;
          nxt_apb_rptr             = rrd_rd_req ? (apb_rptr + CONST_ONE[PTR_WIDTH-1:0]) : apb_rptr;
          nxt_fifo_state           = apbreadfifo_clr ||
                                    (rrd_rd_req && (apb_rptr == FIFO_DEPTH_MINUS_2[PTR_WIDTH-1:0])) ? FIFO_EMPTY
                                                                                                    : FIFO_NOT_EMPTY;
          nxt_apb_read_fifo_rrp_en = rrd_rd_req && (apb_rptr == FIFO_DEPTH_MINUS_2[PTR_WIDTH-1:0]);
        end

      default :
        begin
          nxt_rrd_rd_ack           = 1'bx;
          nxt_apb_rptr             = {PTR_WIDTH{1'bx}};
          nxt_fifo_state           = 2'bxx;
          rb_req_set               = 1'bx;
          nxt_apb_read_fifo_rrp_en = 1'bx;
        end
    endcase
  end

  assign nxt_rb_req_valid_apb = rb_req_set | (rb_req_valid_apb & ~rb_req_ready);

  assign rrd_rd_data = apb_read_fifo[apb_rptr];

  always @*
  begin : c_apb_read_fifo
    for (i=0; i<FIFO_DEPTH; i=i+1)
    begin
      apb_read_fifo[i] = input_buffer0[i*32 +: 32];
    end
  end

  always @(posedge clk or negedge reset_n)
  begin : s_apb_rd_fifo_ctl
    if (!reset_n)
      begin
        rrd_rd_ack            <= 1'b0;
        rb_req_valid_apb      <= 1'b0;
        fifo_state            <= FIFO_EMPTY;
        apb_rptr              <= {PTR_WIDTH{1'b0}};
        apb_read_fifo_rrp_en  <= 1'b0;
      end
    else if (local_cg_en && unformatter_dis)
      begin
        apb_read_fifo_rrp_en  <= nxt_apb_read_fifo_rrp_en;
        rrd_rd_ack            <= nxt_rrd_rd_ack;
        rb_req_valid_apb      <= nxt_rb_req_valid_apb;
        fifo_state            <= nxt_fifo_state;
        apb_rptr              <= nxt_apb_rptr;
      end
  end

  assign unformatter_dis = ~unformatter_en;


  assign rb_req_valid = rb_req_valid_unf | rb_req_valid_apb;


  assign req_cntr_zero = (req_cntr == {REQ_CNTR_WIDTH{1'b0}});
  assign unformatter_empty =  req_cntr_zero &
                             ~atvalid_m &
                             (unformatter_en ? ~(rb_req_valid_unf & rb_req_ready)
                                             :  (fifo_state == FIFO_EMPTY));


  assign atbm_flush_done = atbm_flush_valid & atbm_flush_ready;

  assign nxt_atbm_flush_valid = hw_fifo_mode &&
                                afvalid_m && dev_run && !atbm_flush_ready &&
                                !(|flush_pending || flush_done || afready_m)
                                                                   ? 1'b1 :
                                (afvalid_m && dev_run && atbm_flush_ready) ||
                                               !unformatter_en     ? 1'b0
                                                                   : atbm_flush_valid;

  assign nxt_flush_pending =  !unformatter_en  ? {REQ_CNTR_WIDTH{1'b0}} :
                               atbm_flush_done ? (total_valid_buffers - {{REQ_CNTR_WIDTH-1{1'b0}},f1_f0_bndry_cross}) :
                              (f1_f0_bndry_cross && |flush_pending) ? flush_pending - {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}
                                                                    : flush_pending;

  assign nxt_flush_done    =  (unformatter_en && ((last_frame_flush && f1_f0_bndry_cross) ||
                                                 (atbm_flush_done && (total_valid_buffers == {{REQ_CNTR_WIDTH-1{1'b0}},f1_f0_bndry_cross})))) ? 1'b1 :
                              (~unformatter_en && atbm_flush_done) ? 1'b1 :
                              nxt_afreadym ? 1'b0 : flush_done;

  always @(posedge clk or negedge reset_n)
  begin : s_atbm_flush_ctl
    if (!reset_n)
      begin
        flush_pending    <= {REQ_CNTR_WIDTH{1'b0}};
        flush_done       <= 1'b0;
        atbm_flush_valid <= 1'b0;
      end
    else if (local_cg_en)
      begin
        flush_pending    <= nxt_flush_pending;
        flush_done       <= nxt_flush_done;
        atbm_flush_valid <= nxt_atbm_flush_valid;
      end
  end


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : valid_buffs_atb_32
        assign total_valid_buffers = {{REQ_CNTR_WIDTH-1{1'b0}},rb_rdata_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},input_buffer0_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},input_buffer1_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},frame_buffer0_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},frame_buffer1_valid};
      end
    else
      begin : valid_buffs_atb_64_128
        assign total_valid_buffers = {{REQ_CNTR_WIDTH-1{1'b0}},rb_rdata_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},input_buffer0_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},frame_buffer0_valid} +
                                     {{REQ_CNTR_WIDTH-1{1'b0}},frame_buffer1_valid};
      end
  endgenerate


  always @*
  begin : c_nxt_req_cntr
    if (!unformatter_en)
      begin
        nxt_req_cntr = (req_cntr != {REQ_CNTR_WIDTH{1'b0}}) ? req_cntr - total_valid_buffers :
                                                              req_cntr;
      end
    else
      begin
        case ({(rb_req_valid & rb_req_ready), f1_f0_bndry_cross})
          2'b00, 2'b11 : nxt_req_cntr = req_cntr;
                 2'b01 : nxt_req_cntr = req_cntr - {{REQ_CNTR_WIDTH-1{1'b0}},1'b1};
                 2'b10 : nxt_req_cntr = req_cntr + {{REQ_CNTR_WIDTH-1{1'b0}},1'b1};
          default      : nxt_req_cntr = {REQ_CNTR_WIDTH{1'bx}};
        endcase
      end
  end

  always @(posedge clk or negedge reset_n)
  begin : s_req_cntr
    if (!reset_n)
      req_cntr <= {REQ_CNTR_WIDTH{1'b0}};
    else if (local_cg_en)
      req_cntr <= nxt_req_cntr;
  end

  assign rb_req_valid_unf = unformatter_en & ((req_cntr != MAX_BUFFERS[REQ_CNTR_WIDTH-1:0]) | f1_f0_bndry_cross);


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_input_buf_ctl_atb_32
        assign input_buffer0_en_unf = unformatter_en & (~input_buffer0_valid | frame_buffer0_en) & rb_rdata_valid;

        assign input_buffer1_en = unformatter_en & input_buffer0_valid & ~frame_buffer0_en & (~input_buffer1_valid | frame_buffer1_en) & rb_rdata_valid;

        assign nxt_input_buffer0_valid = input_buffer0_en_unf | (input_buffer0_valid & ~(frame_buffer0_en | ~unformatter_en));

        assign nxt_input_buffer1_valid = input_buffer1_en | (input_buffer1_valid & ~(frame_buffer1_en | ~unformatter_en));

        always @(posedge clk or negedge reset_n)
        begin : s_input_buffs_valid
          if (!reset_n)
            begin
              input_buffer0_valid <= 1'b0;
              input_buffer1_valid <= 1'b0;
            end
          else if (local_cg_en)
            begin
              input_buffer0_valid <= nxt_input_buffer0_valid;
              input_buffer1_valid <= nxt_input_buffer1_valid;
            end
        end

        always @(posedge clk_g)
        begin : s_input_buffer1
          if (~input_buffer_stored && input_buffer1_en)
            input_buffer1 <= rb_data;
        end

      end
    else
      begin : gen_input_buf_ctl_atb_64_128
        assign input_buffer0_en_unf = unformatter_en & (~input_buffer0_valid | frame_buffer0_en | frame_buffer1_en) & rb_rdata_valid;
        assign input_buffer1_en = 1'b0;

        assign nxt_input_buffer0_valid = input_buffer0_en_unf | (input_buffer0_valid & ~(frame_buffer0_en  | frame_buffer1_en | ~unformatter_en));

        always @(posedge clk or negedge reset_n)
        begin : s_input_buff_valid
          if (!reset_n)
            input_buffer0_valid <= 1'b0;
          else if (local_cg_en)
            input_buffer0_valid <= nxt_input_buffer0_valid;
        end
      end
  endgenerate

  assign input_buffer0_en = input_buffer0_en_unf | (~unformatter_en & rb_rdata_valid);

  always @(posedge clk_g)
  begin : s_input_buffer0
    if (~input_buffer_stored && input_buffer0_en)
      input_buffer0 <= rb_data;
  end

  assign nxt_input_buffer_stored = ((input_buffer0_en | input_buffer1_en) & ~dev_run)
                                 | ( input_buffer_stored                  & ~dev_run)
                                 ;
  always @(posedge clk_g)
  begin : s_input_buffer_stored
    input_buffer_stored <= nxt_input_buffer_stored;
  end

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_frame_buf_ctl_atb_32
        assign frame_buffer0_en = unformatter_en & input_buffer1_valid &
                                  (~frame_buffer0_valid |
                                   (wptr_in_frame0 & rptr_in_frame0 & f1_f0_bndry_cross));

        assign frame_buffer1_en = unformatter_en & input_buffer1_valid &
                                  (~frame_buffer1_valid |
                                   (~rptr_in_frame0 & f1_f0_bndry_cross));

        assign nxt_wptr_in_frame0 = ~unformatter_en | (wptr_in_frame0 ^ frame_buffer0_en ^ frame_buffer1_en);

        assign nxt_unf_stop_in_prog = unformatter_stop & nxt_frame_buffer1_valid & ~nxt_frame_buffer0_valid;
        assign unf_stop_in_prog = unformatter_stop & frame_buffer1_valid & ~frame_buffer0_valid;

        assign nxt_atb_data_avail = (nxt_frame_buffer0_valid & nxt_frame_buffer1_valid) |
                                    (~nxt_rptr_in_frame0 & nxt_frame_buffer1_valid &
                                      (atdata_for_1cycle_available_f1 | nxt_unf_stop_in_prog | nxt_last_frame_flush));

        wire dummy_net;
        assign dummy_net = atdata_for_1cycle_available_f0;
      end
    else
      begin : gen_frame_buf_ctl_atb_64_128
        assign frame_buffer0_en = unformatter_en & input_buffer0_valid & wptr_in_frame0 &
                                  (~frame_buffer0_valid | (rptr_in_frame0 & f1_f0_bndry_cross));

        assign frame_buffer1_en = unformatter_en & input_buffer0_valid & ~wptr_in_frame0 &
                                  (~frame_buffer1_valid | (~rptr_in_frame0 & f1_f0_bndry_cross));

        assign nxt_wptr_in_frame0 = ~unformatter_en | (wptr_in_frame0 ^ (frame_buffer0_en | frame_buffer1_en));

        assign nxt_unf_stop_in_prog = unformatter_stop & (nxt_frame_buffer1_valid ^ nxt_frame_buffer0_valid);
        assign unf_stop_in_prog = unformatter_stop & (frame_buffer1_valid ^ frame_buffer0_valid);

        assign nxt_atb_data_avail = (nxt_frame_buffer0_valid & nxt_frame_buffer1_valid) |
                                    (~nxt_rptr_in_frame0 & nxt_frame_buffer1_valid &
                                      (atdata_for_1cycle_available_f1 | nxt_unf_stop_in_prog | nxt_last_frame_flush1)) |
                                    (nxt_rptr_in_frame0 & nxt_frame_buffer0_valid &
                                      (atdata_for_1cycle_available_f0 | nxt_unf_stop_in_prog | nxt_last_frame_flush0));
      end
  endgenerate


  assign frame_buffer0_clr = frame_buffer0_valid & rptr_in_frame0 & f1_f0_bndry_cross;

  assign frame_buffer1_clr = frame_buffer1_valid & ~rptr_in_frame0 & f1_f0_bndry_cross;

  assign nxt_frame_buffer0_valid = unformatter_en & ((frame_buffer0_valid & ~frame_buffer0_clr) | frame_buffer0_en);
  assign nxt_frame_buffer1_valid = unformatter_en & ((frame_buffer1_valid & ~frame_buffer1_clr) | frame_buffer1_en);

  assign nxt_rptr_in_frame0 = ~unformatter_en | (rptr_in_frame0 ^ f1_f0_bndry_cross);


  always @(posedge clk or negedge reset_n)
  begin : s_frame_buf_ctl
    if (!reset_n)
      begin
        frame_buffer0_valid <= 1'b0;
        frame_buffer1_valid <= 1'b0;
        rptr_in_frame0      <= 1'b1;
        wptr_in_frame0      <= 1'b1;
        atb_data_avail      <= 1'b0;
      end
    else if (local_cg_en)
      begin
        frame_buffer0_valid <= nxt_frame_buffer0_valid;
        frame_buffer1_valid <= nxt_frame_buffer1_valid;
        rptr_in_frame0      <= nxt_rptr_in_frame0;
        wptr_in_frame0      <= nxt_wptr_in_frame0;
        atb_data_avail      <= nxt_atb_data_avail;
      end
  end


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_nxt_frame_buf_atb_32
        assign {temp_is_frame1_id,temp_is_frame0_id} = id_or_data_fn({input_buffer1,input_buffer0});

        assign {nxt_frame_buffer1,nxt_frame_buffer0} = input_frame_mux_fn({input_buffer1,input_buffer0});
      end

    else if (ATB_DATA_WIDTH == 64)
      begin : gen_nxt_frame_buf_atb_64
        assign temp_is_frame1_id = id_or_data_fn(input_buffer0);
        assign temp_is_frame0_id = id_or_data_fn(input_buffer0);

        assign nxt_frame_buffer0 = input_frame_mux_fn(input_buffer0);
        assign nxt_frame_buffer1 = input_frame_mux_fn(input_buffer0);
      end

    else
      begin : gen_nxt_frame_buf_atb_128
        wire  [14:0]  temp_id0;
        wire  [14:0]  temp_id1;
        wire  [119:0] temp_frame0;
        wire  [119:0] temp_frame1;

        assign temp_id1          = id_or_data_fn(input_buffer0[INPUT_BUFFER_WIDTH-1:FRAME_WIDTH]);
        assign temp_id0          = id_or_data_fn(input_buffer0[FRAME_WIDTH-1:0]);
        assign temp_is_frame1_id = {temp_id1,temp_id0};
        assign temp_is_frame0_id = {temp_id1,temp_id0};

        assign temp_frame1       = input_frame_mux_fn(input_buffer0[INPUT_BUFFER_WIDTH-1:FRAME_WIDTH]);
        assign temp_frame0       = input_frame_mux_fn(input_buffer0[FRAME_WIDTH-1:0]);
        assign nxt_frame_buffer1 = {temp_frame1,temp_frame0};
        assign nxt_frame_buffer0 = {temp_frame1,temp_frame0};
      end
  endgenerate

  always @(posedge clk)
  begin : s_frame_buffers
    if (local_cg_en && frame_buffer0_en)
      frame_buffer0 <= nxt_frame_buffer0;
    if (local_cg_en && frame_buffer1_en)
      frame_buffer1 <= nxt_frame_buffer1;
  end

  assign frame_buffer = {frame_buffer1,frame_buffer0};


  assign nxt_is_frame0_id =  frame_buffer0_en ? temp_is_frame0_id :
                            (frame_buffer0_clr || !unformatter_en) ? {RPTR_HALF{1'b0}} : is_frame0_id;

  assign nxt_is_frame1_id =  frame_buffer1_en ?  temp_is_frame1_id :
                            (frame_buffer1_clr || !unformatter_en) ? {RPTR_TOP_HALF{1'b0}} : is_frame1_id;

  assign frame_id0_en = frame_buffer0_en | frame_buffer0_clr | (~unformatter_en & ~unformatter_empty);
  assign frame_id1_en = frame_buffer1_en | frame_buffer1_clr | (~unformatter_en & ~unformatter_empty);

  always @(posedge clk or negedge reset_n)
  begin : s_is_frame0_id
    if (!reset_n)
      begin
        is_frame0_id <= {RPTR_HALF{1'b0}};
        is_frame1_id <= {RPTR_TOP_HALF{1'b0}};
      end
    else if (local_cg_en)
      begin
        if (frame_id0_en) is_frame0_id <= nxt_is_frame0_id;
        if (frame_id1_en) is_frame1_id <= nxt_is_frame1_id;
      end
  end

  assign nxt_is_frame_id = {nxt_is_frame1_id,nxt_is_frame0_id};


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_last_flush_atb_32
        assign nxt_last_frame_flush   = (nxt_flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) & nxt_frame_buffer1_valid;
        assign     last_frame_flush   = (    flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) &     frame_buffer1_valid;

        assign nxt_is_frame_id_fready = ({nxt_is_frame1_id,nxt_is_frame0_id} |
                                         {{RPTR_WIDTH-1{1'b0}},(nxt_last_frame_flush | nxt_unf_stop_in_prog)});

        assign     is_frame_id_fready = ({    is_frame1_id,    is_frame0_id} |
                                         {{RPTR_WIDTH-1{1'b0}},(    last_frame_flush |     unf_stop_in_prog)});
      end
    else
      begin : gen_last_flush_atb_64_128
        assign rdata_input_buf_valid  = rb_rdata_valid ^ input_buffer0_valid;

        always @*
        begin : c_nxt_flush_frame0_last
          if (atbm_flush_done)
            case ({rdata_input_buf_valid, frame_buffer0_valid, frame_buffer1_valid})
              3'b010, 3'b101 :
                               nxt_flush_frame0_last = 1'b1;
              3'b001, 3'b110 :
                               nxt_flush_frame0_last = 1'b0;
              3'b100, 3'b111 :
                               nxt_flush_frame0_last = wptr_in_frame0;
              3'b000, 3'b011 :
                               nxt_flush_frame0_last = ~wptr_in_frame0;
                     default : nxt_flush_frame0_last = 1'bx;
            endcase
          else
            nxt_flush_frame0_last = flush_frame0_last;
        end

        always @(posedge clk or negedge reset_n)
        begin : s_last_frame_flush
          if (!reset_n)
            flush_frame0_last <= 1'b0;
          else if (local_cg_en)
            flush_frame0_last <= nxt_flush_frame0_last;
        end

        assign nxt_last_frame_flush0  = (nxt_flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) &  nxt_flush_frame0_last;
        assign nxt_last_frame_flush1  = (nxt_flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) & ~nxt_flush_frame0_last;
        assign     last_frame_flush0  = (    flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) &      flush_frame0_last;
        assign     last_frame_flush1  = (    flush_pending == {{REQ_CNTR_WIDTH-1{1'b0}},1'b1}) &     ~flush_frame0_last;

        assign     last_frame_flush   =  last_frame_flush0 | last_frame_flush1;

        assign nxt_is_frame_id_fready = ({nxt_is_frame1_id, nxt_is_frame0_id} |
                                         {{{RPTR_TOP_HALF-1{1'b0}},(nxt_last_frame_flush0 | (nxt_unf_stop_in_prog &  nxt_rptr_in_frame0))},
                                          {{RPTR_HALF-1{1'b0}},    (nxt_last_frame_flush1 | (nxt_unf_stop_in_prog & ~nxt_rptr_in_frame0))}});

        assign     is_frame_id_fready = ({    is_frame1_id,     is_frame0_id} |
                                         {{{RPTR_TOP_HALF-1{1'b0}},(    last_frame_flush0 | (    unf_stop_in_prog &      rptr_in_frame0))},
                                          {{RPTR_HALF-1{1'b0}},    (    last_frame_flush1 | (    unf_stop_in_prog &     ~rptr_in_frame0))}});

      end
  endgenerate


  generate
    if (ATB_DATA_WIDTH == 128)
      begin : gen_unf_sel_atb_32
        always @*
        begin : c_nxt_sel
          case (rptr_nxt_cycle)
            60'h000_0000_0000_0001 : nxt_sel = nxt_is_frame_id[0]  ? 6'b000000 : 6'b000001;
            60'h000_0000_0000_0002 : nxt_sel = nxt_is_frame_id[1]  ? 6'b111011 : 6'b000000;
            60'h000_0000_0000_0004 : nxt_sel = nxt_is_frame_id[2]  ? 6'b111010 : 6'b111011;
            60'h000_0000_0000_0008 : nxt_sel = nxt_is_frame_id[3]  ? 6'b111001 : 6'b111010;
            60'h000_0000_0000_0010 : nxt_sel = nxt_is_frame_id[4]  ? 6'b111000 : 6'b111001;
            60'h000_0000_0000_0020 : nxt_sel = nxt_is_frame_id[5]  ? 6'b110111 : 6'b111000;
            60'h000_0000_0000_0040 : nxt_sel = nxt_is_frame_id[6]  ? 6'b110110 : 6'b110111;
            60'h000_0000_0000_0080 : nxt_sel = nxt_is_frame_id[7]  ? 6'b110101 : 6'b110110;
            60'h000_0000_0000_0100 : nxt_sel = nxt_is_frame_id[8]  ? 6'b110100 : 6'b110101;
            60'h000_0000_0000_0200 : nxt_sel = nxt_is_frame_id[9]  ? 6'b110011 : 6'b110100;
            60'h000_0000_0000_0400 : nxt_sel = nxt_is_frame_id[10] ? 6'b110010 : 6'b110011;
            60'h000_0000_0000_0800 : nxt_sel = nxt_is_frame_id[11] ? 6'b110001 : 6'b110010;
            60'h000_0000_0000_1000 : nxt_sel = nxt_is_frame_id[12] ? 6'b110000 : 6'b110001;
            60'h000_0000_0000_2000 : nxt_sel = nxt_is_frame_id[13] ? 6'b101111 : 6'b110000;
            60'h000_0000_0000_4000 : nxt_sel = nxt_is_frame_id[14] ? 6'b101110 : 6'b101111;
            60'h000_0000_0000_8000 : nxt_sel = nxt_is_frame_id[15] ? 6'b101101 : 6'b101110;
            60'h000_0000_0001_0000 : nxt_sel = nxt_is_frame_id[16] ? 6'b101100 : 6'b101101;
            60'h000_0000_0002_0000 : nxt_sel = nxt_is_frame_id[17] ? 6'b101011 : 6'b101100;
            60'h000_0000_0004_0000 : nxt_sel = nxt_is_frame_id[18] ? 6'b101010 : 6'b101011;
            60'h000_0000_0008_0000 : nxt_sel = nxt_is_frame_id[19] ? 6'b101001 : 6'b101010;
            60'h000_0000_0010_0000 : nxt_sel = nxt_is_frame_id[20] ? 6'b101000 : 6'b101001;
            60'h000_0000_0020_0000 : nxt_sel = nxt_is_frame_id[21] ? 6'b100111 : 6'b101000;
            60'h000_0000_0040_0000 : nxt_sel = nxt_is_frame_id[22] ? 6'b100110 : 6'b100111;
            60'h000_0000_0080_0000 : nxt_sel = nxt_is_frame_id[23] ? 6'b100101 : 6'b100110;
            60'h000_0000_0100_0000 : nxt_sel = nxt_is_frame_id[24] ? 6'b100100 : 6'b100101;
            60'h000_0000_0200_0000 : nxt_sel = nxt_is_frame_id[25] ? 6'b100011 : 6'b100100;
            60'h000_0000_0400_0000 : nxt_sel = nxt_is_frame_id[26] ? 6'b100010 : 6'b100011;
            60'h000_0000_0800_0000 : nxt_sel = nxt_is_frame_id[27] ? 6'b100001 : 6'b100010;
            60'h000_0000_1000_0000 : nxt_sel = nxt_is_frame_id[28] ? 6'b100000 : 6'b100001;
            60'h000_0000_2000_0000 : nxt_sel = nxt_is_frame_id[29] ? 6'b011111 : 6'b100000;
            60'h000_0000_4000_0000 : nxt_sel = nxt_is_frame_id[30] ? 6'b011110 : 6'b011111;
            60'h000_0000_8000_0000 : nxt_sel = nxt_is_frame_id[31] ? 6'b011101 : 6'b011110;
            60'h000_0001_0000_0000 : nxt_sel = nxt_is_frame_id[32] ? 6'b011100 : 6'b011101;
            60'h000_0002_0000_0000 : nxt_sel = nxt_is_frame_id[33] ? 6'b011011 : 6'b011100;
            60'h000_0004_0000_0000 : nxt_sel = nxt_is_frame_id[34] ? 6'b011010 : 6'b011011;
            60'h000_0008_0000_0000 : nxt_sel = nxt_is_frame_id[35] ? 6'b011001 : 6'b011010;
            60'h000_0010_0000_0000 : nxt_sel = nxt_is_frame_id[36] ? 6'b011000 : 6'b011001;
            60'h000_0020_0000_0000 : nxt_sel = nxt_is_frame_id[37] ? 6'b010111 : 6'b011000;
            60'h000_0040_0000_0000 : nxt_sel = nxt_is_frame_id[38] ? 6'b010110 : 6'b010111;
            60'h000_0080_0000_0000 : nxt_sel = nxt_is_frame_id[39] ? 6'b010101 : 6'b010110;
            60'h000_0100_0000_0000 : nxt_sel = nxt_is_frame_id[40] ? 6'b010100 : 6'b010101;
            60'h000_0200_0000_0000 : nxt_sel = nxt_is_frame_id[41] ? 6'b010011 : 6'b010100;
            60'h000_0400_0000_0000 : nxt_sel = nxt_is_frame_id[42] ? 6'b010010 : 6'b010011;
            60'h000_0800_0000_0000 : nxt_sel = nxt_is_frame_id[43] ? 6'b010001 : 6'b010010;
            60'h000_1000_0000_0000 : nxt_sel = nxt_is_frame_id[44] ? 6'b010000 : 6'b010001;
            60'h000_2000_0000_0000 : nxt_sel = nxt_is_frame_id[45] ? 6'b001111 : 6'b010000;
            60'h000_4000_0000_0000 : nxt_sel = nxt_is_frame_id[46] ? 6'b001110 : 6'b001111;
            60'h000_8000_0000_0000 : nxt_sel = nxt_is_frame_id[47] ? 6'b001101 : 6'b001110;
            60'h001_0000_0000_0000 : nxt_sel = nxt_is_frame_id[48] ? 6'b001100 : 6'b001101;
            60'h002_0000_0000_0000 : nxt_sel = nxt_is_frame_id[49] ? 6'b001011 : 6'b001100;
            60'h004_0000_0000_0000 : nxt_sel = nxt_is_frame_id[50] ? 6'b001010 : 6'b001011;
            60'h008_0000_0000_0000 : nxt_sel = nxt_is_frame_id[51] ? 6'b001001 : 6'b001010;
            60'h010_0000_0000_0000 : nxt_sel = nxt_is_frame_id[52] ? 6'b001000 : 6'b001001;
            60'h020_0000_0000_0000 : nxt_sel = nxt_is_frame_id[53] ? 6'b000111 : 6'b001000;
            60'h040_0000_0000_0000 : nxt_sel = nxt_is_frame_id[54] ? 6'b000110 : 6'b000111;
            60'h080_0000_0000_0000 : nxt_sel = nxt_is_frame_id[55] ? 6'b000101 : 6'b000110;
            60'h100_0000_0000_0000 : nxt_sel = nxt_is_frame_id[56] ? 6'b000100 : 6'b000101;
            60'h200_0000_0000_0000 : nxt_sel = nxt_is_frame_id[57] ? 6'b000011 : 6'b000100;
            60'h400_0000_0000_0000 : nxt_sel = nxt_is_frame_id[58] ? 6'b000010 : 6'b000011;
            60'h800_0000_0000_0000 : nxt_sel = nxt_is_frame_id[59] ? 6'b000001 : 6'b000010;
            default                : nxt_sel = 6'bxxxxxx;
          endcase
        end
      end
  else
    if (ATB_DATA_WIDTH == 64)
      begin : gen_unf_sel_atb_64
        always @*
        begin : c_nxt_sel
          case (rptr_nxt_cycle)
            30'h0000_0001 : nxt_sel = nxt_is_frame_id[0]  ? 5'b00000 : 5'b00001;
            30'h0000_0002 : nxt_sel = nxt_is_frame_id[1]  ? 5'b11101 : 5'b00000;
            30'h0000_0004 : nxt_sel = nxt_is_frame_id[2]  ? 5'b11100 : 5'b11101;
            30'h0000_0008 : nxt_sel = nxt_is_frame_id[3]  ? 5'b11011 : 5'b11100;
            30'h0000_0010 : nxt_sel = nxt_is_frame_id[4]  ? 5'b11010 : 5'b11011;
            30'h0000_0020 : nxt_sel = nxt_is_frame_id[5]  ? 5'b11001 : 5'b11010;
            30'h0000_0040 : nxt_sel = nxt_is_frame_id[6]  ? 5'b11000 : 5'b11001;
            30'h0000_0080 : nxt_sel = nxt_is_frame_id[7]  ? 5'b10111 : 5'b11000;
            30'h0000_0100 : nxt_sel = nxt_is_frame_id[8]  ? 5'b10110 : 5'b10111;
            30'h0000_0200 : nxt_sel = nxt_is_frame_id[9]  ? 5'b10101 : 5'b10110;
            30'h0000_0400 : nxt_sel = nxt_is_frame_id[10] ? 5'b10100 : 5'b10101;
            30'h0000_0800 : nxt_sel = nxt_is_frame_id[11] ? 5'b10011 : 5'b10100;
            30'h0000_1000 : nxt_sel = nxt_is_frame_id[12] ? 5'b10010 : 5'b10011;
            30'h0000_2000 : nxt_sel = nxt_is_frame_id[13] ? 5'b10001 : 5'b10010;
            30'h0000_4000 : nxt_sel = nxt_is_frame_id[14] ? 5'b10000 : 5'b10001;
            30'h0000_8000 : nxt_sel = nxt_is_frame_id[15] ? 5'b01111 : 5'b10000;
            30'h0001_0000 : nxt_sel = nxt_is_frame_id[16] ? 5'b01110 : 5'b01111;
            30'h0002_0000 : nxt_sel = nxt_is_frame_id[17] ? 5'b01101 : 5'b01110;
            30'h0004_0000 : nxt_sel = nxt_is_frame_id[18] ? 5'b01100 : 5'b01101;
            30'h0008_0000 : nxt_sel = nxt_is_frame_id[19] ? 5'b01011 : 5'b01100;
            30'h0010_0000 : nxt_sel = nxt_is_frame_id[20] ? 5'b01010 : 5'b01011;
            30'h0020_0000 : nxt_sel = nxt_is_frame_id[21] ? 5'b01001 : 5'b01010;
            30'h0040_0000 : nxt_sel = nxt_is_frame_id[22] ? 5'b01000 : 5'b01001;
            30'h0080_0000 : nxt_sel = nxt_is_frame_id[23] ? 5'b00111 : 5'b01000;
            30'h0100_0000 : nxt_sel = nxt_is_frame_id[24] ? 5'b00110 : 5'b00111;
            30'h0200_0000 : nxt_sel = nxt_is_frame_id[25] ? 5'b00101 : 5'b00110;
            30'h0400_0000 : nxt_sel = nxt_is_frame_id[26] ? 5'b00100 : 5'b00101;
            30'h0800_0000 : nxt_sel = nxt_is_frame_id[27] ? 5'b00011 : 5'b00100;
            30'h1000_0000 : nxt_sel = nxt_is_frame_id[28] ? 5'b00010 : 5'b00011;
            30'h2000_0000 : nxt_sel = nxt_is_frame_id[29] ? 5'b00001 : 5'b00010;
            default       : nxt_sel = 5'bxxxxx;
          endcase
        end
      end
    else
      begin : gen_unf_sel_atb_128
        always @*
        begin : c_nxt_sel
          case (rptr_nxt_cycle)
            15'h0001 : nxt_sel = nxt_is_frame_id[0]  ? 4'b0000 : 4'b0001;
            15'h0002 : nxt_sel = nxt_is_frame_id[1]  ? 4'b1110 : 4'b0000;
            15'h0004 : nxt_sel = nxt_is_frame_id[2]  ? 4'b1101 : 4'b1110;
            15'h0008 : nxt_sel = nxt_is_frame_id[3]  ? 4'b1100 : 4'b1101;
            15'h0010 : nxt_sel = nxt_is_frame_id[4]  ? 4'b1011 : 4'b1100;
            15'h0020 : nxt_sel = nxt_is_frame_id[5]  ? 4'b1010 : 4'b1011;
            15'h0040 : nxt_sel = nxt_is_frame_id[6]  ? 4'b1001 : 4'b1010;
            15'h0080 : nxt_sel = nxt_is_frame_id[7]  ? 4'b1000 : 4'b1001;
            15'h0100 : nxt_sel = nxt_is_frame_id[8]  ? 4'b0111 : 4'b1000;
            15'h0200 : nxt_sel = nxt_is_frame_id[9]  ? 4'b0110 : 4'b0111;
            15'h0400 : nxt_sel = nxt_is_frame_id[10] ? 4'b0101 : 4'b0110;
            15'h0800 : nxt_sel = nxt_is_frame_id[11] ? 4'b0100 : 4'b0101;
            15'h1000 : nxt_sel = nxt_is_frame_id[12] ? 4'b0011 : 4'b0100;
            15'h2000 : nxt_sel = nxt_is_frame_id[13] ? 4'b0010 : 4'b0011;
            15'h4000 : nxt_sel = nxt_is_frame_id[14] ? 4'b0001 : 4'b0010;
            default  : nxt_sel = 4'bxxxx;
          endcase
        end
      end
  endgenerate


  wire [2*RPTR_WIDTH-1:RPTR_WIDTH-ATB_NUM_BYTES-1] rptr_circ;
  wire [2*RPTR_WIDTH-1:RPTR_WIDTH-ATB_NUM_BYTES-1] frame_id_circ;
  wire [2*RPTR_WIDTH-1:0]                          current_rptr_circ;

  assign rptr_circ         = {rptr_nxt_cycle,
                              rptr_nxt_cycle[RPTR_WIDTH-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+1]};
  assign frame_id_circ     = {nxt_is_frame_id_fready,
                              nxt_is_frame_id_fready[RPTR_WIDTH-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+1]};
  assign current_rptr_circ = {current_rptr,current_rptr};

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_unf_rptr_32
        reg    [ATB_NUM_BYTES:0] rptr_32;
        reg  [ATB_NUM_BYTES+1:0] is_rptr_bit_id_32;

        always @*
        begin : c_rptr_calc
          if (!unformatter_en)
            begin
              nxt_rptr_nxt_cycle = {{RPTR_WIDTH-1{1'b0}},1'b1};
              rptr_32            = {ATB_NUM_BYTES+1{1'b0}};
              is_rptr_bit_id_32  = {ATB_NUM_BYTES+2{1'b0}};
            end
          else
            begin
              for (k=2*RPTR_WIDTH-1; k >= RPTR_WIDTH; k=k-1)
              begin : nxt_rptr_for_32
                rptr_32           = rptr_circ[k-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+1];
                is_rptr_bit_id_32 = frame_id_circ[k-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+2];
                nxt_rptr_nxt_cycle[k-RPTR_WIDTH] =
                            ((rptr_32[4] |
                             (rptr_32[3] & is_rptr_bit_id_32[4]   == 1'b0 )|
                             (rptr_32[2] & is_rptr_bit_id_32[4:3] == 2'b00) |
                             (rptr_32[1] & is_rptr_bit_id_32[4:2] == 3'b000))
                                                                & is_rptr_bit_id_32[5]) |
                            (((rptr_32[0] & is_rptr_bit_id_32[0]) | rptr_32[1])
                                                                & is_rptr_bit_id_32[4:1] == 4'b0000);
              end
            end
        end
      end

    else if (ATB_DATA_WIDTH == 64)
      begin : gen_unf_rptr_64
        reg    [ATB_NUM_BYTES:0] rptr_64;
        reg  [ATB_NUM_BYTES+1:0] is_rptr_bit_id_64;

        always @*
        begin : c_rptr_calc
          if (!unformatter_en)
            begin
              nxt_rptr_nxt_cycle = {{RPTR_WIDTH-1{1'b0}},1'b1};
              rptr_64            = {ATB_NUM_BYTES+1{1'b0}};
              is_rptr_bit_id_64  = {ATB_NUM_BYTES+2{1'b0}};
            end
          else
            begin
              for (m=2*RPTR_WIDTH-1; m >= RPTR_WIDTH; m=m-1)
              begin : nxt_rptr_for_64
                rptr_64           = rptr_circ[m-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+1];
                is_rptr_bit_id_64 = frame_id_circ[m-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+2];
                nxt_rptr_nxt_cycle[m-RPTR_WIDTH] =
                              ((rptr_64[8] |
                               (rptr_64[7] & is_rptr_bit_id_64[8]   == 1'b0 )|
                               (rptr_64[6] & is_rptr_bit_id_64[8:7] == 2'b00)      |
                               (rptr_64[5] & is_rptr_bit_id_64[8:6] == 3'b000)     |
                               (rptr_64[4] & is_rptr_bit_id_64[8:5] == 4'b0000)    |
                               (rptr_64[3] & is_rptr_bit_id_64[8:4] == 5'b00000)   |
                               (rptr_64[2] & is_rptr_bit_id_64[8:3] == 6'b000000)  |
                               (rptr_64[1] & is_rptr_bit_id_64[8:2] == 7'b0000000))
                                                                  & is_rptr_bit_id_64[9]) |
                              (((rptr_64[0] & is_rptr_bit_id_64[0]) | rptr_64[1])
                                                                  & is_rptr_bit_id_64[8:1] == 8'h00);
              end
            end
        end
      end

    else
      begin : gen_unf_rptr_128
        reg    [ATB_NUM_BYTES:0] rptr_128;
        reg  [ATB_NUM_BYTES+1:0] is_rptr_bit_id_128;

        always @*
        begin : c_rptr_calc
          if (!unformatter_en)
            begin
              nxt_rptr_nxt_cycle = {{RPTR_WIDTH-1{1'b0}},1'b1};
              rptr_128           = {ATB_NUM_BYTES+1{1'b0}};
              is_rptr_bit_id_128 = {ATB_NUM_BYTES+2{1'b0}};
            end
          else
            begin
              for (n=2*RPTR_WIDTH-1; n >= RPTR_WIDTH; n=n-1)
              begin : nxt_rptr_for_128
                rptr_128           = rptr_circ[n-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+1];
                is_rptr_bit_id_128 = frame_id_circ[n-ATB_NUM_BYTES-1 +: ATB_NUM_BYTES+2];
                nxt_rptr_nxt_cycle[n-RPTR_WIDTH] =
                               ((rptr_128[16] |
                                (rptr_128[15] & is_rptr_bit_id_128[16]    == 1'b0 )|
                                (rptr_128[14] & is_rptr_bit_id_128[16:15] == 2'b00)    |
                                (rptr_128[13] & is_rptr_bit_id_128[16:14] == 3'b000)   |
                                (rptr_128[12] & is_rptr_bit_id_128[16:13] == 4'h0)     |
                                (rptr_128[11] & is_rptr_bit_id_128[16:12] == 5'h00)    |
                                (rptr_128[10] & is_rptr_bit_id_128[16:11] == 6'h00)    |
                                (rptr_128[9] & is_rptr_bit_id_128[16:10]  == 7'h00)    |
                                (rptr_128[8] & is_rptr_bit_id_128[16:9]   == 8'h00)    |
                                (rptr_128[7] & is_rptr_bit_id_128[16:8]   == 9'h000)   |
                                (rptr_128[6] & is_rptr_bit_id_128[16:7]   == 10'h000)  |
                                (rptr_128[5] & is_rptr_bit_id_128[16:6]   == 11'h000)  |
                                (rptr_128[4] & is_rptr_bit_id_128[16:5]   == 12'h000)  |
                                (rptr_128[3] & is_rptr_bit_id_128[16:4]   == 13'h0000) |
                                (rptr_128[2] & is_rptr_bit_id_128[16:3]   == 14'h0000) |
                                (rptr_128[1] & is_rptr_bit_id_128[16:2]   == 15'h0000))
                                                                        & is_rptr_bit_id_128[17]) |
                               (((rptr_128[0] & is_rptr_bit_id_128[0]) | rptr_128[1])
                                                                        & is_rptr_bit_id_128[16:1] == 16'h0000);
              end
            end
        end
      end
  endgenerate

  assign rptr_clken = ~unformatter_en | (nxt_atb_data_avail
                                         & (~atb_skid_valid | ~(atb_data_avail | atb_data_avail_stored))
                                         );

  always @(posedge clk or negedge reset_n)
  begin : c_rptr_sel
    if (!reset_n)
      begin
        sel             <= {SEL_WIDTH{1'b0}};
        rptr_nxt_cycle  <= {{RPTR_WIDTH-1{1'b0}},1'b1};
        current_rptr    <= {{RPTR_WIDTH-1{1'b0}},1'b1};
      end
    else if (local_cg_en && rptr_clken)
      begin
        sel             <= nxt_sel;
        rptr_nxt_cycle  <= nxt_rptr_nxt_cycle;
        current_rptr    <= rptr_nxt_cycle;
      end
  end

  assign f1_f0_bndry_crossing = (atb_data_avail | atb_data_avail_stored) &
                             ((|current_rptr[RPTR_WIDTH-1:RPTR_HALF]) ^ (|rptr_nxt_cycle[RPTR_WIDTH-1:RPTR_HALF]));
  assign f1_f0_bndry_cross = ~atb_skid_valid & f1_f0_bndry_crossing;

  always @*
  begin : c_nxt_atb_data_avail_stored
    if (!atb_skid_valid)
      nxt_atb_data_avail_stored = 1'b0;
    else if (atb_data_avail && !nxt_atb_data_avail)
      nxt_atb_data_avail_stored = 1'b1;
    else
      nxt_atb_data_avail_stored = atb_data_avail_stored;
  end

  always @(posedge clk or negedge reset_n)
  begin : s_atb_data_avail_stored
    if (!reset_n)
      atb_data_avail_stored <= 1'b0;
    else if (local_cg_en)
      atb_data_avail_stored <= nxt_atb_data_avail_stored;
  end

  always @*
  begin : c_rptr_nth_bit_id
    for (j=0; j <= ATB_NUM_BYTES; j=j+1)
    begin : rptr_nth_id_for
      rptr_nth_bit_id[j] = |(current_rptr_circ[RPTR_WIDTH-j +: RPTR_WIDTH] & is_frame_id_fready);
    end
  end

  assign atdata_for_1cycle_available_f0 = |{nxt_rptr_nxt_cycle[RPTR_HALF:0]};

  assign atdata_for_1cycle_available_f1 = |{nxt_rptr_nxt_cycle[RPTR_WIDTH-1:RPTR_HALF],nxt_rptr_nxt_cycle[0]};


  wire [6:0]                unformatted_id;
  wire [ATB_DATA_WIDTH-1:0] unformatted_data;

  css600_tmc_unf_data_mux
   #(.FRAME_BUFFER_WIDTH   (FRAME_BUFFER_WIDTH),
     .ATB_DATA_WIDTH       (ATB_DATA_WIDTH),
     .SEL_WIDTH            (SEL_WIDTH))
    u_css600_tmc_unf_data_mux
    (.frame_buffer     (frame_buffer),
     .sel              (sel),
     .unformatted_id   (unformatted_id),
     .unformatted_data (unformatted_data));


  assign atb_skid_ld = ~atb_skid_valid & nxt_atvalidm_current & atvalid_m & ~atready_m;

  assign nxt_atb_skid_valid = (atb_skid_valid & ~atready_m) | atb_skid_ld;

  always @(posedge clk or negedge reset_n)
  begin : s_atb_skid_valid
    if (!reset_n)
      atb_skid_valid <= 1'b0;
    else if (local_cg_en)
      atb_skid_valid <= nxt_atb_skid_valid;
  end

  always @(posedge clk)
  begin : s_atbm_skid
    if (local_cg_en && atb_skid_ld)
      begin
        atbytesm_skid  <= nxt_atbytesm_current;
        atdatam_skid   <= unformatted_data;
        atidm_skid     <= nxt_atidm_current;
      end
  end


  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_nxt_atbytesm_atb_32
        assign nxt_atbytesm_current = rptr_nth_bit_id[1] ? 2'b00:
                                      rptr_nth_bit_id[2] ? (rptr_nth_bit_id[0] ? 2'b00 : 2'b01) :
                                      rptr_nth_bit_id[3] ? (rptr_nth_bit_id[0] ? 2'b01 : 2'b10) :
                                      (rptr_nth_bit_id[0] && rptr_nth_bit_id[4] ? 2'b10 : 2'b11);

        assign nxt_atbytesm = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[9:8] : atbytes_m) :
                                           (atb_skid_valid ? atbytesm_skid : nxt_atbytesm_current);
      end

    else if (ATB_DATA_WIDTH == 64)
      begin : gen_nxt_atbytesm_atb_64
        assign nxt_atbytesm_current = rptr_nth_bit_id[1]  ? 3'b000:
                                      rptr_nth_bit_id[2]  ? (rptr_nth_bit_id[0] ? 3'b000  : 3'b001):
                                      rptr_nth_bit_id[3]  ? (rptr_nth_bit_id[0] ? 3'b001  : 3'b010):
                                      rptr_nth_bit_id[4]  ? (rptr_nth_bit_id[0] ? 3'b010  : 3'b011):
                                      rptr_nth_bit_id[5]  ? (rptr_nth_bit_id[0] ? 3'b011  : 3'b100):
                                      rptr_nth_bit_id[6]  ? (rptr_nth_bit_id[0] ? 3'b100  : 3'b101):
                                      rptr_nth_bit_id[7]  ? (rptr_nth_bit_id[0] ? 3'b101  : 3'b110):
                                      (rptr_nth_bit_id[0] && rptr_nth_bit_id[8] ? 3'b110  : 3'b111);

        assign nxt_atbytesm = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[10:8] : atbytes_m) :
                                           (atb_skid_valid ? atbytesm_skid : nxt_atbytesm_current);
      end

    else
      begin : gen_nxt_atbytesm_atb_128
        assign nxt_atbytesm_current = rptr_nth_bit_id[1]  ? 4'b0000:
                                      rptr_nth_bit_id[2]  ? (rptr_nth_bit_id[0] ? 4'b0000 : 4'b0001):
                                      rptr_nth_bit_id[3]  ? (rptr_nth_bit_id[0] ? 4'b0001 : 4'b0010):
                                      rptr_nth_bit_id[4]  ? (rptr_nth_bit_id[0] ? 4'b0010 : 4'b0011):
                                      rptr_nth_bit_id[5]  ? (rptr_nth_bit_id[0] ? 4'b0011 : 4'b0100):
                                      rptr_nth_bit_id[6]  ? (rptr_nth_bit_id[0] ? 4'b0100 : 4'b0101):
                                      rptr_nth_bit_id[7]  ? (rptr_nth_bit_id[0] ? 4'b0101 : 4'b0110):
                                      rptr_nth_bit_id[8]  ? (rptr_nth_bit_id[0] ? 4'b0110 : 4'b0111):
                                      rptr_nth_bit_id[9]  ? (rptr_nth_bit_id[0] ? 4'b0111 : 4'b1000):
                                      rptr_nth_bit_id[10] ? (rptr_nth_bit_id[0] ? 4'b1000 : 4'b1001):
                                      rptr_nth_bit_id[11] ? (rptr_nth_bit_id[0] ? 4'b1001 : 4'b1010):
                                      rptr_nth_bit_id[12] ? (rptr_nth_bit_id[0] ? 4'b1010 : 4'b1011):
                                      rptr_nth_bit_id[13] ? (rptr_nth_bit_id[0] ? 4'b1011 : 4'b1100):
                                      rptr_nth_bit_id[14] ? (rptr_nth_bit_id[0] ? 4'b1100 : 4'b1101):
                                      rptr_nth_bit_id[15] ? (rptr_nth_bit_id[0] ? 4'b1101 : 4'b1110):
                                      (rptr_nth_bit_id[0] && rptr_nth_bit_id[16] ? 4'b1110 : 4'b1111);

        assign nxt_atbytesm = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[11:8] : atbytes_m) :
                                           (atb_skid_valid ? atbytesm_skid : nxt_atbytesm_current);
      end
  endgenerate


  assign nxt_atvalidm_current = (atb_data_avail | atb_data_avail_stored);

  assign nxt_atvalidm        = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[0] : atvalid_m)
                             : (nxt_atvalidm_detect & ~lp_done &  dev_run)
                             | (atvalidm_pend       & ~lp_done & ~dev_run)
                             ;
  assign nxt_atvalidm_pend   = nxt_atvalidm_detect & ( lp_done | ~dev_run)
                             |     atvalidm_pend   & ( lp_done | ~dev_run)
                             ;
  assign nxt_atvalidm_detect = (atb_skid_valid ? ~atidm_skid_zero : ~atidm_zero & nxt_atvalidm_current);
  assign atidm_skid_zero     = (       atidm_skid == 7'b000_0000);
  assign atidm_zero          = (nxt_atidm_current == 7'b000_0000);

  generate
    if (ATB_DATA_WIDTH == 32)
      begin : gen_nxt_atdatam_atb_32
        assign nxt_atdatam = itctrl_ime ? (it_atb_m_data_0_wr_en ?
                                            ({apb_wdata_p_bits16to0[4], {7{1'b0}},
                                              apb_wdata_p_bits16to0[3], {7{1'b0}},
                                              apb_wdata_p_bits16to0[2], {7{1'b0}},
                                              apb_wdata_p_bits16to0[1], {6{1'b0}}, apb_wdata_p_bits16to0[0]}) : atdata_m) :
                                          (atb_skid_valid ? atdatam_skid  : unformatted_data);
      end

    else if (ATB_DATA_WIDTH == 64)
      begin : gen_nxt_atdatam_atb_64
        assign nxt_atdatam = itctrl_ime ? (it_atb_m_data_0_wr_en ?
                                            ({apb_wdata_p_bits16to0[8], {7{1'b0}},
                                              apb_wdata_p_bits16to0[7], {7{1'b0}},
                                              apb_wdata_p_bits16to0[6], {7{1'b0}},
                                              apb_wdata_p_bits16to0[5], {7{1'b0}},
                                              apb_wdata_p_bits16to0[4], {7{1'b0}},
                                              apb_wdata_p_bits16to0[3], {7{1'b0}},
                                              apb_wdata_p_bits16to0[2], {7{1'b0}},
                                              apb_wdata_p_bits16to0[1], {6{1'b0}}, apb_wdata_p_bits16to0[0]}) : atdata_m) :
                                          (atb_skid_valid ? atdatam_skid  : unformatted_data);
      end
    else
      begin : gen_nxt_atdatam_atb_128
        assign nxt_atdatam = itctrl_ime ? (it_atb_m_data_0_wr_en ?
                                            ({apb_wdata_p_bits16to0[16], {7{1'b0}},
                                              apb_wdata_p_bits16to0[15], {7{1'b0}},
                                              apb_wdata_p_bits16to0[14], {7{1'b0}},
                                              apb_wdata_p_bits16to0[13], {7{1'b0}},
                                              apb_wdata_p_bits16to0[12], {7{1'b0}},
                                              apb_wdata_p_bits16to0[11], {7{1'b0}},
                                              apb_wdata_p_bits16to0[10], {7{1'b0}},
                                              apb_wdata_p_bits16to0[9], {7{1'b0}},
                                              apb_wdata_p_bits16to0[8], {7{1'b0}},
                                              apb_wdata_p_bits16to0[7], {7{1'b0}},
                                              apb_wdata_p_bits16to0[6], {7{1'b0}},
                                              apb_wdata_p_bits16to0[5], {7{1'b0}},
                                              apb_wdata_p_bits16to0[4], {7{1'b0}},
                                              apb_wdata_p_bits16to0[3], {7{1'b0}},
                                              apb_wdata_p_bits16to0[2], {7{1'b0}},
                                              apb_wdata_p_bits16to0[1], {6{1'b0}}, apb_wdata_p_bits16to0[0]}) : atdata_m) :
                                          (atb_skid_valid ? atdatam_skid  : unformatted_data);
      end
  endgenerate


  assign nxt_atidm_current = (rptr_nth_bit_id[0] &&
                               (atb_data_avail || atb_data_avail_stored)) ? unformatted_id : atid_m;

  assign nxt_atidm = itctrl_ime             ? (it_atb_m_ctr_1_wr_en ? apb_wdata_p_bits16to0[6:0] : atid_m)
                   : ctl_trace_capt_en_rise ? 7'b000_0000
                   :                          (atb_skid_valid ? atidm_skid : nxt_atidm_current);

  assign atb_clken = itctrl_ime | ~atvalid_m | atready_m;

  always @(posedge clk or negedge reset_n)
  begin : s_atb_master
    if (!reset_n)
      begin
        atbytes_m <= {ATBYTES_WIDTH{1'b0}};
        atdata_m  <= {ATB_DATA_WIDTH{1'b0}};
        atid_m    <= 7'b0000000;
      end
    else if (local_cg_en && atb_clken)
      begin
        atbytes_m <= nxt_atbytesm;
        atdata_m  <= nxt_atdatam;
        atid_m    <= nxt_atidm;
      end
  end
  always @(posedge clk or negedge reset_n)
  begin : s_atb_master_atvalid
    if (!reset_n)
    begin
      atvalidm_pend <= 1'b0;
      atvalid_m     <= 1'b0;
    end
    else if (cg_en && atb_clken)
    begin
      atvalidm_pend <= nxt_atvalidm_pend;
      atvalid_m     <= nxt_atvalidm;
    end
  end


   assign nxt_afreadym = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[1] : afready_m) :
                                      ( ~(unformatter_en
                                         | hw_fifo_mode
                                         )
                                      | (hw_fifo_mode & ~ctl_trace_capt_en & tmc_ready & ~lp_done & dev_run)
                                      | (flush_done & atready_m &  atb_skid_valid & f1_f0_bndry_crossing )
                                      | (flush_done & atready_m & ~atb_skid_valid
                                                                                                         )
                                      | (flush_done & ~atvalid_m & ~afready_m)
                                      );

  always @(posedge clk or negedge reset_n)
  begin : s_afready_m
    if (!reset_n)
      afready_m <= 1'b1;
    else if (local_cg_en)
      afready_m <= nxt_afreadym;
  end

  assign nxt_atwakeupm = itctrl_ime ? (it_atb_m_ctr_0_wr_en ? apb_wdata_p_bits16to0[2] : atwakeup_m)
                       : nxt_atvalidm;

  always @ (posedge clk or negedge reset_n)
  begin : s_atwakeup_m
    if (!reset_n)
      atwakeup_m <= 1'b0;
    else if (cg_en && atb_clken)
      atwakeup_m <= nxt_atwakeupm;
  end


endmodule

