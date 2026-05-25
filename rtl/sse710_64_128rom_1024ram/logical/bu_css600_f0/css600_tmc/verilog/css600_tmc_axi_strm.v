//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017, 2019 Arm Limited or its affiliates.
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


module css600_tmc_axi_strm
#(
  parameter ATB_DATA_WIDTH = 32
)
(
  input  wire                            clk,
  input  wire                            cg_en,
  input  wire                            reset_n,

  input  wire                            dev_run,
  input  wire                            lp_done,

  output wire [ATB_DATA_WIDTH-1:0]       tdata_m,
  output wire                            tlast_m,
  output reg                             tvalid_m,
  input  wire                            tready_m,

  input  wire [ATB_DATA_WIDTH-1:0]       ft_data,
  input  wire                            ft_data_valid,
  output reg                             wb_ready,
  output wire                            nxt_wb_ready,

  input  wire                        nxt_tmc_enabled,
  input  wire                            sts_full_wr_en,
  input  wire [3:0]                      apb_wdata_p_bits3to0,
  input  wire                            unprog_sts,
  output reg                             trace_mem_empty,
  output reg                             sts_full,

  input  wire                            wb_flush_req,
  output wire                            wb_flush_ack,

  output reg                             full,
  output reg                             bufintr,

  input  wire                            itctrl_ime,
  input  wire                            it_evt_intr_wr_en,

  output wire                            wb_empty
);


  wire                      ft_wr_req_valid;
  wire                      axis_xfer_done;
  wire [1:0]                nxt_wptr;
  wire [1:0]                nxt_rptr;
  reg  [1:0]                wptr;
  reg  [1:0]                rptr;
  wire                      data_buf_full;
  wire                      data_buf_empty;
  wire                      nxt_data_buf_full;
  wire                      nxt_data_buf_empty;

  wire                      tvalid_detect;
  wire                      nxt_tvalid_pend;
  reg                       tvalid_pend;

  reg  [ATB_DATA_WIDTH-1:0] data_buf [0:1];

  wire                      nxt_tvalid;

  wire                      sts_full_we;
  wire                      full_we;
  wire                      bufintr_we;
  wire                      trace_mem_empty_we;
  wire                      nxt_sts_full;
  wire                      nxt_full;
  wire                      nxt_bufintr;
  wire                      nxt_trace_mem_empty;


  assign ft_wr_req_valid = ft_data_valid & wb_ready;
  assign axis_xfer_done  = tvalid_m & tready_m;

  assign nxt_wb_ready    = ~nxt_data_buf_full
                         & ~wb_flush_req
                         & dev_run & ~lp_done;

  always @ (posedge clk or negedge reset_n)
  begin : s_wb_ready
    if (!reset_n)
      wb_ready <= 1'b0;
    else if (cg_en)
      wb_ready <= nxt_wb_ready;
  end


  assign wb_flush_ack = wb_flush_req & nxt_data_buf_empty;

  assign wb_empty = data_buf_empty;


  assign nxt_wptr = wptr + 2'b01;

  always @ (posedge clk or negedge reset_n)
  begin : s_wptr
    if (!reset_n)
      wptr <= 2'b00;
    else if (cg_en && ft_wr_req_valid)
      wptr <= nxt_wptr;
  end

  assign nxt_rptr = rptr + 2'b01;

  always @ (posedge clk or negedge reset_n)
  begin : s_rptr
    if (!reset_n)
      rptr <= 2'b00;
    else if (cg_en && axis_xfer_done)
      rptr <= nxt_rptr;
  end

  assign data_buf_full = (wptr[1] != rptr[1]) & (wptr[0] == rptr[0]);
  assign data_buf_empty = (wptr == rptr);

  assign nxt_data_buf_full = (ft_wr_req_valid == axis_xfer_done) ?  data_buf_full :
                                                !axis_xfer_done  ? (nxt_wptr[1] != rptr[1]) & (nxt_wptr[0] == rptr[0]) :
                                                                    1'b0;

  assign nxt_data_buf_empty = ft_wr_req_valid ?  1'b0 :
                               axis_xfer_done ? (wptr == nxt_rptr) :
                                                 data_buf_empty;


  assign tvalid_detect   = ft_wr_req_valid | ~nxt_data_buf_empty ;
  assign nxt_tvalid      = (tvalid_detect & ~(lp_done | ~dev_run)) | (tvalid_pend &  dev_run) | (tvalid_m & ~tready_m);
  assign nxt_tvalid_pend = (tvalid_detect &  (lp_done | ~dev_run)) | (tvalid_pend & ~dev_run);

  always @ (posedge clk or negedge reset_n)
  begin : s_tvalid_m
    if (!reset_n) begin
      tvalid_m    <= 1'b0;
      tvalid_pend  <= 1'b0;
    end else
      if (cg_en)
      begin
        tvalid_m    <= nxt_tvalid;
        tvalid_pend <= nxt_tvalid_pend;
      end
  end

  always @ (posedge clk)
  begin : s_data_buf
    if (cg_en && ft_wr_req_valid)
      data_buf[wptr[0]] <= ft_data;
  end

  assign tdata_m = data_buf[rptr[0]];

  assign tlast_m = 1'b1;


  assign sts_full_we = cg_en & (nxt_tmc_enabled ? ((~sts_full & axis_xfer_done) | unprog_sts) : sts_full_wr_en);
  assign nxt_sts_full = (!sts_full_we) ? sts_full
                      : (nxt_tmc_enabled) ? (axis_xfer_done & ~unprog_sts) : apb_wdata_p_bits3to0[0];

  always @(posedge clk)
  begin : s_sts_full
    if (sts_full_we)
      sts_full <= nxt_sts_full;
  end

  assign full_we = cg_en & (~itctrl_ime | it_evt_intr_wr_en);
  assign nxt_full = itctrl_ime ? apb_wdata_p_bits3to0[1] : (nxt_tmc_enabled & ~unprog_sts & sts_full);

  always @(posedge clk or negedge reset_n)
  begin : s_full
    if (!reset_n)
      full <= 1'b0;
    else if (full_we)
      full <= nxt_full;
  end

  assign bufintr_we = cg_en & (~itctrl_ime | it_evt_intr_wr_en);
  assign nxt_bufintr = itctrl_ime ? apb_wdata_p_bits3to0[3] : (nxt_tmc_enabled & ~unprog_sts & sts_full);

  always @(posedge clk or negedge reset_n)
  begin : s_bufintr
    if (!reset_n)
      bufintr <= 1'b0;
    else if (bufintr_we)
      bufintr <= nxt_bufintr;
  end

  assign trace_mem_empty_we = cg_en & nxt_tmc_enabled;
  assign nxt_trace_mem_empty = ~nxt_sts_full | unprog_sts;

  always @ (posedge clk or negedge reset_n)
  begin : s_trace_mem_empty
    if (!reset_n)
      trace_mem_empty <= 1'b1;
    else if (trace_mem_empty_we)
      trace_mem_empty <= nxt_trace_mem_empty;
  end

endmodule

