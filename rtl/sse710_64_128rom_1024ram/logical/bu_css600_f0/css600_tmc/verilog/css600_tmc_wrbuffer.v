//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009-2010, 2016-2017 Arm Limited or its affiliates.
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


module css600_tmc_wrbuffer
#(
  parameter TMC_CONFIG     = 1,
  parameter ATB_DATA_WIDTH = 64,
  parameter WBUFFER_DEPTH  = 4,
  parameter WB_PTR_WIDTH   = 1,
  parameter WB_DATA_WIDTH  = 64
)
(
  input  wire                      clk,
  input  wire                      cg_en,
  input  wire                      reset_n,

  input wire                       ctl_trace_capt_en_rise,
  input wire                       tmc_enabled,

  input  wire                      wb_flush_req,
  output wire                      wb_flush_ack,

  input  wire [ATB_DATA_WIDTH-1:0] ft_data,
  input  wire                      ft_data_valid,
  output reg                       wb_ready,
  output wire                      nxt_wb_ready,

  input  wire                      rwd_wr_req,
  input  wire [31:0]               rwd_wr_data,

  output reg  [WB_DATA_WIDTH-1:0]  wb_data,
  output reg                       wb_req_valid,
  input  wire                      wb_req_ready,
  output wire [WB_PTR_WIDTH:0]     wb_fill_level,
  output wire [WB_PTR_WIDTH:0]     wb_flush_cnt,
  output wire                      wb_flush_req_det,
  output reg                       wb_empty
);


  `include "css600_tmc_localparams.v"


  localparam APB_WB_RATIO = WB_DATA_WIDTH/32;

  localparam FIFO_DEPTH_EQ_1 = ((TMC_CONFIG == ETB) || (TMC_CONFIG == ETF) ||
                                (WBUFFER_DEPTH == 1)) ? 1'b1 : 1'b0;

  localparam FIFO_READ_IDLE   = 1'b0;
  localparam FIFO_READ_DRAIN  = 1'b1;


  reg  [APB_WB_RATIO-1:0]  apb_wren;
  wire [APB_WB_RATIO-1:0]  nxt_apb_wren;
  wire                     apb_wren_update;

  reg  [1:0]               ft_data_wren;
  reg  [1:0]               nxt_ft_data_wren;

  reg  [APB_WB_RATIO-1:0]  wb_data_we;
  reg  [APB_WB_RATIO-1:0]  fifo_data_we;
  reg                      wb_req_valid_q;
  reg                      nxt_wb_req_valid;
  wire [WB_DATA_WIDTH-1:0] nxt_fifo_data;
  reg  [WB_PTR_WIDTH-1:0]  wptr;
  reg  [WB_PTR_WIDTH-1:0]  rptr;
  reg  [WB_PTR_WIDTH-1:0]  nxt_wptr;
  reg  [WB_PTR_WIDTH-1:0]  nxt_rptr;
  reg  [WB_DATA_WIDTH-1:0] fifo [WBUFFER_DEPTH-1:0];
  reg  [WB_PTR_WIDTH:0]    wb_fill_level_int;
  reg  [WB_PTR_WIDTH:0]    fifo_fill_level;
  wire [WB_PTR_WIDTH:0]    nxt_wb_fill_level;
  reg  [WB_PTR_WIDTH:0]    nxt_fifo_fill_level;
  reg                      full;
  reg                      nxt_full;
  reg                      nxt_not_empty;
  reg                      not_empty;
  reg                      fifo_read_state;
  reg                      nxt_fifo_read_state;
  wire                     fifo_wptr_incr;
  reg                      wb_data_wren;

  wire [WB_DATA_WIDTH-1:0] nxt_wb_ft_data;
  wire [WB_DATA_WIDTH-1:0] nxt_wb_data;
  wire                     nxt_wb_empty;
  wire                     apb_wr_req_valid;
  wire                     ft_wr_req_valid;
  wire                     axi_write_en;

  integer i;
  integer j;
  integer k;
  integer l;
  integer m;


  generate
    if ((TMC_CONFIG == ETB) || (TMC_CONFIG == ETF))
    begin : gen_wrbuffer_etb_etf
      assign wb_fill_level    = {WB_PTR_WIDTH+1{1'b0}};
      assign wb_flush_cnt     = {WB_PTR_WIDTH+1{1'b0}};
      assign wb_flush_req_det = 1'b0;

      assign apb_wr_req_valid = rwd_wr_req & wb_ready;
      assign ft_wr_req_valid  = ft_data_valid & wb_ready;

      always @*
      begin : c_wb_ctl
        case ({apb_wr_req_valid,ft_wr_req_valid})
          2'b00 : begin
            wb_req_valid = wb_ready ? 1'b0 : wb_req_valid_q;
            nxt_ft_data_wren = ft_data_wren;
          end
          2'b01 : begin
            wb_req_valid = ft_data_wren[1];
            nxt_ft_data_wren = {ft_data_wren[0], ft_data_wren[1]};
          end
          2'b10 : begin
            wb_req_valid = apb_wren[APB_WB_RATIO-1];
            nxt_ft_data_wren = ft_data_wren;
          end
          default : begin
            wb_req_valid = 1'bx;
            nxt_ft_data_wren = 2'bxx;
          end
        endcase
      end

      assign nxt_apb_wren = apb_wr_req_valid       ? {apb_wren[APB_WB_RATIO-2:0], apb_wren[APB_WB_RATIO-1]} :
                            ctl_trace_capt_en_rise ? {{APB_WB_RATIO-1{1'b0}},1'b1} :
                                                     apb_wren;

      assign nxt_wb_empty =  (wb_req_valid && wb_req_ready)               ? 1'b1 :
                             ((rwd_wr_req && apb_wren[APB_WB_RATIO-1]) ||
                              (ft_data_valid && ft_data_wren[1]))         ? 1'b0 : wb_empty;

      assign nxt_wb_ready = ~wb_req_valid | wb_req_ready;

      assign nxt_wb_ft_data = {2{ft_data}};

      assign nxt_wb_data = ft_wr_req_valid  ? nxt_wb_ft_data :
                           apb_wr_req_valid ? {APB_WB_RATIO{rwd_wr_data}} : wb_data;

      always @*
      begin : c_wb_data_we
        for (i=0; i<APB_WB_RATIO/2; i=i+1)
          wb_data_we[i] = ft_wr_req_valid  ? ft_data_wren[0] :
                          apb_wr_req_valid ? apb_wren[i] : 1'b0;

        for (j=APB_WB_RATIO/2; j<APB_WB_RATIO; j=j+1)
          wb_data_we[j] = ft_wr_req_valid  ? ft_data_wren[1] :
                          apb_wr_req_valid ? apb_wren[j] : 1'b0;
      end

      always @(posedge clk)
      begin : s_wb_data
        for (k=0; k<APB_WB_RATIO; k=k+1)
          if (cg_en && wb_data_we[k])
            wb_data[k*32 +: 32] <= nxt_wb_data[k*32 +: 32];
      end

      always @(posedge clk or negedge reset_n)
      begin : s_wb_ctl
        if (!reset_n)
          begin
            ft_data_wren   <= 2'b01;
            wb_ready       <= 1'b0;
            wb_req_valid_q <= 1'b0;
            wb_empty       <= 1'b1;
          end
        else if (cg_en)
          begin
            ft_data_wren   <= nxt_ft_data_wren;
            wb_ready       <= nxt_wb_ready;
            wb_req_valid_q <= wb_req_valid;
            wb_empty       <= nxt_wb_empty;
          end
      end

      assign apb_wren_update = cg_en & (apb_wr_req_valid | ctl_trace_capt_en_rise);

      always @(posedge clk or negedge reset_n)
      begin : s_apb_wren
        if (!reset_n)
          apb_wren <= {{APB_WB_RATIO-1{1'b0}},1'b1};
        else if (apb_wren_update)
          apb_wren <= nxt_apb_wren;
      end

    end
  endgenerate

  generate
    if ((TMC_CONFIG == ETR) && (WB_DATA_WIDTH !=32))
    begin : gen_wrbuffer_etr_64_128

      assign fifo_wptr_incr = ft_data_valid | (apb_wr_req_valid & apb_wren[APB_WB_RATIO-1]);

      assign nxt_apb_wren = apb_wr_req_valid       ? {apb_wren[APB_WB_RATIO-2:0], apb_wren[APB_WB_RATIO-1]} :
                            ctl_trace_capt_en_rise ? {{APB_WB_RATIO-1{1'b0}},1'b1} :
                                                     apb_wren;

      always @*
      begin : c_fifo_data_we
        for (l= 0; l<APB_WB_RATIO; l=l+1)
          fifo_data_we[l] = ft_data_valid | (apb_wr_req_valid & apb_wren[l]);
      end

      assign nxt_fifo_data = apb_wr_req_valid ? {APB_WB_RATIO{rwd_wr_data}} : ft_data;

      assign apb_wren_update = cg_en & (apb_wr_req_valid | ctl_trace_capt_en_rise);

      always @(posedge clk or negedge reset_n)
      begin : s_apb_wren
        if (!reset_n)
          apb_wren <= {{APB_WB_RATIO-1{1'b0}},1'b1};
        else if (apb_wren_update)
          apb_wren <= nxt_apb_wren;
      end

      always @(posedge clk)
      begin : s_fifo
        for (m=0; m<APB_WB_RATIO; m=m+1)
          if (cg_en && fifo_data_we[m])
            fifo[wptr][m*32 +: 32] <= nxt_fifo_data[m*32 +: 32];
      end

      assign nxt_wb_ready = tmc_enabled ?  ~nxt_full :
                                          (~apb_wren[APB_WB_RATIO-1] &
                                            fifo_read_state == FIFO_READ_IDLE &
                                           ~axi_write_en) |
                                          (wb_req_valid & wb_req_ready);
    end

    else if ((TMC_CONFIG == ETR) && (WB_DATA_WIDTH == 32))
    begin : gen_wrbuffer_etr_32
      wire dummy_net;
      assign dummy_net = ctl_trace_capt_en_rise;

      assign fifo_wptr_incr = cg_en & (apb_wr_req_valid | ft_data_valid);
      assign nxt_fifo_data = apb_wr_req_valid ? rwd_wr_data : ft_data;

      always @(posedge clk)
      begin : s_fifo
        if (fifo_wptr_incr)
          fifo[wptr] <= nxt_fifo_data;
      end

      assign nxt_wb_ready = tmc_enabled ? ~nxt_full :
                                          (wb_req_valid & wb_req_ready);
    end
  endgenerate

  generate
    if (TMC_CONFIG == ETR)
    begin : gen_wrbuffer_etr_common
      wire ptr_en;

      assign apb_wr_req_valid = rwd_wr_req & (wb_ready | ~tmc_enabled);

      always @*
      begin : c_fifo_ctl
        case ({fifo_wptr_incr,wb_data_wren})
          2'b00: begin
            nxt_wptr            = wptr;
            nxt_rptr            = rptr;
            nxt_not_empty       = not_empty;
            nxt_full            = full;
            nxt_fifo_fill_level = fifo_fill_level;
          end
          2'b01 : begin
            nxt_wptr            = wptr;
            nxt_rptr            = rptr + {{WB_PTR_WIDTH-1{1'b0}},1'b1};
            nxt_not_empty       = (nxt_rptr != wptr);
            nxt_full            = 1'b0;
            nxt_fifo_fill_level = fifo_fill_level - {{WB_PTR_WIDTH{1'b0}},1'b1};
          end
          2'b10 : begin
            nxt_wptr            = wptr + {{WB_PTR_WIDTH-1{1'b0}},1'b1};
            nxt_rptr            = rptr;
            nxt_not_empty       = 1'b1;
            nxt_full            = (nxt_wptr == rptr);
            nxt_fifo_fill_level = fifo_fill_level + {{WB_PTR_WIDTH{1'b0}},1'b1};
          end
          2'b11 : begin
            nxt_wptr            = wptr + {{WB_PTR_WIDTH-1{1'b0}},1'b1};
            nxt_rptr            = rptr + {{WB_PTR_WIDTH-1{1'b0}},1'b1};
            nxt_not_empty       = not_empty;
            nxt_full            = full;
            nxt_fifo_fill_level = fifo_fill_level;
          end
          default : begin
            nxt_wptr            = {WB_PTR_WIDTH{1'bx}};
            nxt_rptr            = {WB_PTR_WIDTH{1'bx}};
            nxt_not_empty       = 1'bx;
            nxt_full            = 1'bx;
            nxt_fifo_fill_level = {WB_PTR_WIDTH+1{1'bx}};
          end
        endcase
      end

      assign ptr_en = cg_en & (fifo_wptr_incr | wb_data_wren);

      assign axi_write_en = |fifo_fill_level;

      assign nxt_wb_fill_level = (!wb_req_valid || wb_req_ready) ? fifo_fill_level
                                                                 : fifo_fill_level + {{WB_PTR_WIDTH{1'b0}},1'b1};

      always @*
      begin : c_fifo_fsm
        case (fifo_read_state)
          FIFO_READ_IDLE : begin
            nxt_wb_req_valid    = axi_write_en;
            nxt_fifo_read_state = axi_write_en ?  FIFO_READ_DRAIN : FIFO_READ_IDLE;
            wb_data_wren        = cg_en & axi_write_en;
          end
          FIFO_READ_DRAIN : begin
            nxt_fifo_read_state = (wb_req_ready && !axi_write_en) ? FIFO_READ_IDLE : FIFO_READ_DRAIN;
            nxt_wb_req_valid    = (wb_req_ready && !axi_write_en) ? 1'b0 : 1'b1;
            wb_data_wren        = (wb_req_ready && !axi_write_en) ? 1'b0 : (cg_en & wb_req_ready & not_empty);
          end
          default : begin
            nxt_fifo_read_state = 1'bx;
            nxt_wb_req_valid    = 1'bx;
            wb_data_wren        = 1'bx;
          end
        endcase
      end

      always @*
      begin : c_fifo_fsm_no_sensloop
        case (fifo_read_state)
          FIFO_READ_IDLE :
            wb_req_valid        = 1'b0;
          FIFO_READ_DRAIN :
            wb_req_valid        = 1'b1;
          default :
            wb_req_valid        = 1'bx;
        endcase
      end

      assign nxt_wb_empty = ~nxt_not_empty & ~nxt_wb_req_valid;

      always @(posedge clk or negedge reset_n)
      begin : s_fifo_fsm
        if (!reset_n)
          begin
            wb_ready          <= 1'b0;
            fifo_read_state   <= FIFO_READ_IDLE;
            wb_fill_level_int <= {WB_PTR_WIDTH+1{1'b0}};
            wb_empty          <= 1'b1;
          end
        else if (cg_en)
          begin
            wb_ready          <= nxt_wb_ready;
            fifo_read_state   <= nxt_fifo_read_state;
            wb_fill_level_int <= nxt_wb_fill_level;
            wb_empty          <= nxt_wb_empty;
          end
      end

      always @(posedge clk or negedge reset_n)
      begin : s_fifo_ctl
        if (!reset_n)
          begin
            wptr            <= {WB_PTR_WIDTH{1'b0}};
            rptr            <= {WB_PTR_WIDTH{1'b0}};
            not_empty       <= 1'b0;
            fifo_fill_level <= {WB_PTR_WIDTH+1{1'b0}};
            full            <= 1'b0;
          end
        else if (ptr_en)
          begin
            wptr            <= nxt_wptr;
            rptr            <= nxt_rptr;
            not_empty       <= nxt_not_empty;
            fifo_fill_level <= nxt_fifo_fill_level;
            full            <= nxt_full;
          end
      end

      assign nxt_wb_data = fifo[rptr];

      always @(posedge clk)
      begin : s_wb_data
        if (wb_data_wren)
          wb_data <= nxt_wb_data;
      end

      assign wb_fill_level = wb_fill_level_int;

    end
  endgenerate


  generate
    if ((TMC_CONFIG == ETB) || (TMC_CONFIG == ETF))
    begin : gen_wb_flush_etb_etf
      assign wb_flush_ack = wb_empty;
    end

    else
    begin : gen_wb_flush_etr
      reg  [WB_PTR_WIDTH:0]     wb_flush_cnt_int;
      wire [WB_PTR_WIDTH:0] nxt_wb_flush_cnt;
      reg                       wb_flush_req_det_int;
      wire                  nxt_wb_flush_req_det;
      wire                      wb_fl_ack_non_empty;
      wire                  nxt_wb_fill_level_eq0;
      wire                  nxt_wb_flush_cnt_eq0;
      wire                      flush_cnt_load_en;
      wire                      flush_cnt_decr;

      assign wb_flush_ack = nxt_wb_fill_level_eq0 | wb_fl_ack_non_empty;

      assign wb_fl_ack_non_empty = wb_flush_req_det_int & nxt_wb_flush_cnt_eq0;

      assign nxt_wb_fill_level_eq0 = ~|nxt_wb_fill_level;
      assign nxt_wb_flush_cnt_eq0  = ~|nxt_wb_flush_cnt;

      assign nxt_wb_flush_req_det = (wb_flush_req & ~wb_flush_req_det_int & ~nxt_wb_fill_level_eq0) |
                                    (wb_flush_req_det_int & ~nxt_wb_flush_cnt_eq0);

      always @(posedge clk or negedge reset_n)
      begin : s_wb_flush_det
        if (!reset_n)
          wb_flush_req_det_int <= 1'b0;
        else if (cg_en)
          wb_flush_req_det_int <= nxt_wb_flush_req_det;
      end

      assign flush_cnt_load_en = wb_flush_req & ~wb_flush_req_det_int & ~nxt_wb_fill_level_eq0;
      assign flush_cnt_decr = wb_flush_req_det_int & wb_req_valid & wb_req_ready;

      assign nxt_wb_flush_cnt = flush_cnt_load_en ?  nxt_wb_fill_level :
                                flush_cnt_decr    ? (wb_flush_cnt_int - {{WB_PTR_WIDTH{1'b0}}, 1'b1})
                                                  :  wb_flush_cnt_int;

      always @(posedge clk or negedge reset_n)
      begin : s_wb_flush_cnt
        if (!reset_n)
          wb_flush_cnt_int <= {WB_PTR_WIDTH+1{1'b0}};
        else if (cg_en)
          wb_flush_cnt_int <= nxt_wb_flush_cnt;
      end

      assign wb_flush_cnt     = wb_flush_cnt_int;
      assign wb_flush_req_det = wb_flush_req_det_int;

    end
  endgenerate


endmodule

