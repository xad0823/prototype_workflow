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


module css600_tmc_mem_if
#(
  parameter TMC_CONFIG          = 0,
  parameter ATB_DATA_WIDTH      = 32,
  parameter MEM_SIZE            = 31'h0000_0080,
  parameter MEM_ADDR_WIDTH      = 7,
  parameter MEM_BYTE_ADDR_WIDTH = 9,
  parameter WB_DATA_WIDTH       = 64,
  parameter FILL_LEVEL_WIDTH    = 8
)
(
  input  wire                                     clk,
  input  wire                                     cg_en,
  input  wire                                     reset_n,

  input  wire                                     dev_run,
  input  wire                                     lp_done,

  output reg                                      mem_ce_n,
  output reg                                      mem_we_n,
  output reg                 [MEM_ADDR_WIDTH-1:0] mem_addr,
  output wire                 [WB_DATA_WIDTH-1:0] mem_d,
  input  wire             [2*ATB_DATA_WIDTH -1:0] mem_q,

  input  wire                                     wb_req_valid,
  output wire                                     wb_req_ready,
  input  wire                 [WB_DATA_WIDTH-1:0] wb_data,

  input  wire                                     rb_req_valid,
  output wire                                     rb_req_ready,
  output reg                                      rb_rdata_valid,
  output wire                 [WB_DATA_WIDTH-1:0] rb_data,
  input wire                                      apb_read_fifo_rrp_en,

  input wire                                      ctl_trace_capt_en,
  input wire                                      ctl_trace_capt_en_rise,
  input wire                                      tmc_enabled,
  input wire                                      tmc_abort,
  input wire                                      unformatter_en,
  input wire                                      circ_buf_mode,
  input wire                                      l_buf_level_rd_done,
  input wire                                      rrp_wr_en,
  input wire                                      rwp_wr_en,
  input wire                               [31:0] apb_wdata_p,
  input wire                                      unprog_rrp,
  input wire                                      unprog_rwp,
  input wire                                      ptr_prog,

  input wire               [FILL_LEVEL_WIDTH-2:0] buf_wm,

  output wire           [MEM_BYTE_ADDR_WIDTH-1:0] rrp,
  output wire           [MEM_BYTE_ADDR_WIDTH-1:0] rwp,
  output wire              [FILL_LEVEL_WIDTH-1:0] l_buf_level,
  output wire              [FILL_LEVEL_WIDTH-1:0] c_buf_level,
  output reg                                      trace_mem_empty,
  output reg                                      sts_full,

  input wire                                      mem_flush_req,
  output wire                                     mem_flush_ack,

  input wire                                      itctrl_ime,
  input wire                                      it_evt_intr_wr_en,

  input wire                                      unformatter_empty,
  output wire                                     mem_wr,
  output reg                                      full
);


  `include "css600_tmc_localparams.v"

  localparam PTR_PAD = MEM_BYTE_ADDR_WIDTH - MEM_ADDR_WIDTH;

  localparam PTR_WR_ALIGN = (ATB_DATA_WIDTH == 128) ? 5 : 4;

  localparam BUF_LEVEL_WIDTH = (WB_DATA_WIDTH == 64)  ? FILL_LEVEL_WIDTH-1 :
                               (WB_DATA_WIDTH == 128) ? FILL_LEVEL_WIDTH-2 :
                                                        FILL_LEVEL_WIDTH-3;

  localparam BUF_LEVEL_PAD = (WB_DATA_WIDTH == 64)  ? 1 :
                             (WB_DATA_WIDTH == 128) ? 2 : 3;

  localparam BUF_LEVEL_CMP_MASK = (WB_DATA_WIDTH == 64)  ? {{FILL_LEVEL_WIDTH-1{1'b1}}, 1'b0}  :
                                  (WB_DATA_WIDTH == 128) ? {{FILL_LEVEL_WIDTH-2{1'b1}}, 2'b00} :
                                                           {{FILL_LEVEL_WIDTH-3{1'b1}}, 3'b000};

  wire                           rrp_we;
  wire                           rwp_we;
  wire                           rrp_incr;
  wire                           rwp_incr;
  reg  [MEM_ADDR_WIDTH-1:0]      nxt_rwp_word_addr;
  reg  [MEM_ADDR_WIDTH-1:0]      nxt_rrp_word_addr;
  wire [MEM_ADDR_WIDTH-1:0]      nxt_rrp_word_addr_int;
  reg  [MEM_ADDR_WIDTH-1:0]      rrp_word_addr;
  reg  [MEM_ADDR_WIDTH-1:0]      rwp_word_addr;
  wire [MEM_ADDR_WIDTH-1:0]      rrp_word_addr_int;
  wire [MEM_ADDR_WIDTH-1:0]      rwp_word_addr_int;
  wire [MEM_BYTE_ADDR_WIDTH-1:0] apb_wdata_p_masked;

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

  wire                           mem_rd_en;
  wire                           mem_wr_en;
  wire                           memaddr_we;
  wire      [MEM_ADDR_WIDTH-1:0] nxt_memaddr;
  wire                           nxt_memcen;
  wire                           nxt_memwen;
  wire                           nxt_mem_rd_skd;
  reg                            mem_rd_skd;

  wire                           nxt_rb_req_ready;
  reg                                rb_req_ready_func;
  wire                           nxt_wb_req_ready;
  reg                                wb_req_ready_int;
  wire                           nxt_rb_rdata_valid;

  wire [FILL_LEVEL_WIDTH-1:0]    trace_mem_space_thrshold;
  wire                           nxt_c_buf_level_eq_thrshold;
  wire                           c_buf_level_eq_thrshold;

  wire                           trace_mem_empty_we;
  wire                           nxt_trace_mem_empty;
  wire                           nxt_trace_mem_full;
  wire                           trace_mem_full;

  wire                           sts_full_set;
  wire                           sts_full_clr;
  wire                           sts_full_update;
  wire                           nxt_sts_full;
  wire                           nxt_full;


  assign mem_wr_en = wb_req_valid & wb_req_ready;

  assign nxt_memwen = ~mem_wr_en;

  assign nxt_wb_req_ready = circ_buf_mode | tmc_abort |
                           ~tmc_enabled | ~nxt_trace_mem_full;

  assign mem_d = wb_data;


  assign mem_rd_en = ((rb_req_valid & rb_req_ready) | mem_rd_skd) & ~mem_wr_en;

  assign nxt_memcen = ~cg_en | ~(mem_rd_en | mem_wr_en);

  assign nxt_rb_req_ready = ~(tmc_enabled & nxt_trace_mem_empty) & ~nxt_mem_rd_skd
                          | (rb_req_ready_func & (lp_done | ~dev_run))
                          ;
  assign rb_req_ready     = rb_req_ready_func & ~lp_done & dev_run;

  assign rb_data = mem_q;

  assign nxt_rb_rdata_valid = ~mem_ce_n & mem_we_n;

  always @(posedge clk or negedge reset_n)
  begin : s_mem_rdwr
    if (!reset_n)
      begin
        mem_ce_n       <= 1'b1;
        mem_we_n       <= 1'b1;
        wb_req_ready_int <= 1'b0;
        rb_req_ready_func <= 1'b0;
        rb_rdata_valid <= 1'b0;
      end
    else if (cg_en)
      begin
        mem_ce_n       <= nxt_memcen;
        mem_we_n       <= nxt_memwen;
        wb_req_ready_int <= nxt_wb_req_ready;
        rb_req_ready_func <= nxt_rb_req_ready;
        if (dev_run)
          rb_rdata_valid <= nxt_rb_rdata_valid;
      end
  end
  assign wb_req_ready = wb_req_ready_int
                      & dev_run & ~lp_done;

  assign nxt_mem_rd_skd = (rb_req_valid & rb_req_ready & mem_wr_en) |
                          (mem_rd_skd & mem_wr_en);

  always @(posedge clk or negedge reset_n)
  begin : s_mem_rd_skd
    if (!reset_n)
      mem_rd_skd <= 1'b0;
    else if (cg_en)
      mem_rd_skd <= nxt_mem_rd_skd;
  end


  assign nxt_memaddr = mem_wr_en ? rwp_word_addr_int : rrp_word_addr_int;

  assign memaddr_we = ~nxt_memcen;

  always @(posedge clk or negedge reset_n)
  begin : s_mem_addr
    if (!reset_n)
      mem_addr <= {MEM_ADDR_WIDTH{1'b0}};
    else if (memaddr_we)
      mem_addr <=  nxt_memaddr;
  end


  generate
    if (TMC_CONFIG == ETB)
    begin : gen_rrp_incr_etb
      assign rrp_incr =  apb_read_fifo_rrp_en |
                        (tmc_enabled & circ_buf_mode & (rwp_word_addr_int == rrp_word_addr_int) & full & rwp_incr) |
                        (tmc_enabled & ~ctl_trace_capt_en & trace_mem_full & rwp_incr);
    end

    else
    begin : gen_rrp_incr_etf

      wire unf_empty_in_prog;
      reg  unf_empty_in_prog_q;
      reg  unformatter_en_q;

      assign rrp_incr =  apb_read_fifo_rrp_en |
                        (tmc_enabled & circ_buf_mode & (rwp_word_addr_int == rrp_word_addr_int) & full & rwp_incr) |
                        (tmc_enabled & ~ctl_trace_capt_en & trace_mem_full & rwp_incr) |
                        ((unformatter_en | unf_empty_in_prog) & ~nxt_memcen & nxt_memwen);

      assign unf_empty_in_prog = (~unformatter_en & unformatter_en_q) |
                                 (unf_empty_in_prog_q & ~unformatter_empty);

      always @(posedge clk or negedge reset_n)
      begin : s_unf_status
        if (!reset_n)
          begin
            unformatter_en_q    <= 1'b0;
            unf_empty_in_prog_q <= 1'b0;
          end
        else if (cg_en)
          begin
            unformatter_en_q    <= unformatter_en;
            unf_empty_in_prog_q <= unf_empty_in_prog;
          end
      end
    end
  endgenerate

  assign rrp_we = cg_en & (ctl_trace_capt_en_rise | rrp_incr | rrp_wr_en);

  always @*
  begin : c_nxt_rrp_word_addr
    if (ctl_trace_capt_en_rise)
      nxt_rrp_word_addr = rrp_word_addr_int;
    else
      case ({rrp_wr_en, rrp_incr})
        2'b10,
        2'b11 : nxt_rrp_word_addr = apb_wdata_p_masked[MEM_BYTE_ADDR_WIDTH-1:PTR_PAD];
        2'b01 : nxt_rrp_word_addr = rrp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1};
        2'b00 : nxt_rrp_word_addr = rrp_word_addr;
      endcase
  end

  always @(posedge clk)
  begin : s_rrp_word_addr
    if (rrp_we)
      rrp_word_addr <= nxt_rrp_word_addr;
  end

  assign rrp_word_addr_int = rrp_word_addr & {MEM_ADDR_WIDTH{~unprog_rrp}};
  assign nxt_rrp_word_addr_int = nxt_rrp_word_addr & {MEM_ADDR_WIDTH{~unprog_rrp}};

  assign rrp = {rrp_word_addr,{PTR_PAD{1'b0}}};


  assign rwp_incr = ~nxt_memcen & ~nxt_memwen;

  assign rwp_we = cg_en & (ctl_trace_capt_en_rise | rwp_incr | rwp_wr_en);

  always @*
  begin : c_nxt_rwp_word_addr
    if (ctl_trace_capt_en_rise)
      nxt_rwp_word_addr = rwp_word_addr_int;
    else
      case ({rwp_wr_en, rwp_incr})
        2'b10,
        2'b11 : nxt_rwp_word_addr = apb_wdata_p_masked[MEM_BYTE_ADDR_WIDTH-1:PTR_PAD];
        2'b01 : nxt_rwp_word_addr = rwp_word_addr + {{MEM_ADDR_WIDTH-1{1'b0}}, 1'b1};
        2'b00 : nxt_rwp_word_addr = rwp_word_addr;
      endcase
  end

  always @(posedge clk)
  begin : s_rwp_word_addr
    if (rwp_we)
      rwp_word_addr <= nxt_rwp_word_addr;
  end

  assign rwp_word_addr_int = rwp_word_addr & {MEM_ADDR_WIDTH{~unprog_rwp}};

  assign rwp = {rwp_word_addr,{PTR_PAD{1'b0}}};

  assign apb_wdata_p_masked = {apb_wdata_p[MEM_BYTE_ADDR_WIDTH-1:PTR_WR_ALIGN], {PTR_WR_ALIGN{1'b0}}};


  assign trace_mem_space_thrshold = MEM_SIZE[FILL_LEVEL_WIDTH-1:0] - ({1'b0, buf_wm} & BUF_LEVEL_CMP_MASK);

  assign nxt_c_buf_level_eq_thrshold = ({nxt_c_buf_level_r,{BUF_LEVEL_PAD{1'b0}}} == trace_mem_space_thrshold);
  assign c_buf_level_eq_thrshold = (c_buf_level == trace_mem_space_thrshold);


  assign sts_full_set = tmc_enabled & (circ_buf_mode ? (rwp_incr & (rwp_word_addr_int == {MEM_ADDR_WIDTH{1'b1}}))
                                                     :  nxt_c_buf_level_eq_thrshold);

  assign sts_full_clr = ctl_trace_capt_en_rise | (tmc_enabled & ~circ_buf_mode &
                                                  rrp_incr & ~rwp_incr & c_buf_level_eq_thrshold);

  assign sts_full_update = cg_en & (sts_full_set | sts_full_clr);
  assign nxt_sts_full = (sts_full_set & ~sts_full_clr);

  always @(posedge clk)
  begin : s_sts_full
    if (sts_full_update)
      sts_full <= nxt_sts_full;
  end

  assign nxt_full = itctrl_ime ? (it_evt_intr_wr_en ? apb_wdata_p[1] : full)
                               : (tmc_enabled & (sts_full_set | (sts_full & ~sts_full_clr)));

  always @(posedge clk or negedge reset_n)
  begin : s_full
    if (!reset_n)
      full <= 1'b0;
    else if (cg_en)
      full <= nxt_full;
  end

  assign nxt_trace_mem_full = (nxt_c_buf_level_r == {1'b1, {BUF_LEVEL_WIDTH-1{1'b0}}});
  assign trace_mem_full = (c_buf_level_r_int == {1'b1, {BUF_LEVEL_WIDTH-1{1'b0}}});

  assign trace_mem_empty_we = cg_en & c_buf_level_we;
  assign nxt_trace_mem_empty = (nxt_c_buf_level_r == {BUF_LEVEL_WIDTH{1'b0}});

  always @ (posedge clk or negedge reset_n)
  begin : s_trace_mem_empty
    if (!reset_n)
      trace_mem_empty <= 1'b1;
    else if (trace_mem_empty_we)
      trace_mem_empty <= nxt_trace_mem_empty;
  end


  assign c_buf_level_we = cg_en & (rwp_incr | rrp_incr | ctl_trace_capt_en_rise | ptr_prog);

  always @*
  begin : c_nxt_cbuflevel_r
    if (ctl_trace_capt_en_rise || ptr_prog)
      nxt_c_buf_level_r = {BUF_LEVEL_WIDTH{1'b0}};
    else
      case ({rwp_incr, rrp_incr})
        2'b00,
        2'b11 :
                nxt_c_buf_level_r = c_buf_level_r_int;
        2'b01 :
                nxt_c_buf_level_r = trace_mem_empty ? c_buf_level_r_int :
                                                      c_buf_level_r_int - {{BUF_LEVEL_WIDTH-1{1'b0}}, 1'b1};
        2'b10 :
                nxt_c_buf_level_r = trace_mem_full  ? c_buf_level_r_int :
                                                      c_buf_level_r_int + {{BUF_LEVEL_WIDTH-1{1'b0}}, 1'b1};
      endcase
  end

  always @(posedge clk)
  begin : s_cbuflevel_r
    if (c_buf_level_we)
      c_buf_level_r <= nxt_c_buf_level_r;
  end

  assign c_buf_level_r_int = c_buf_level_r & ~{BUF_LEVEL_WIDTH{unprog_rrp & unprog_rwp}};

  assign c_buf_level = {c_buf_level_r,{BUF_LEVEL_PAD{1'b0}}};

  assign l_buf_level_we = cg_en & (ctl_trace_capt_en_rise | ptr_prog | l_buf_level_upd | (l_buf_level_rd_done & ~l_buf_level_upd_q));

  assign l_buf_level_upd = tmc_enabled & rwp_incr & (nxt_c_buf_level_r > l_buf_level_r_int);

  assign nxt_l_buf_level_r = nxt_c_buf_level_r;

  always @(posedge clk)
  begin : s_lbuflevel_r
    if (l_buf_level_we)
      l_buf_level_r <=  nxt_l_buf_level_r;
  end

  assign l_buf_level_r_int = l_buf_level_r & ~{BUF_LEVEL_WIDTH{unprog_rrp | unprog_rwp}};

  assign l_buf_level = {l_buf_level_r,{BUF_LEVEL_PAD{1'b0}}};

  always @(posedge clk or negedge reset_n)
  begin : s_lbuflevel_upd_q
    if (!reset_n)
      l_buf_level_upd_q <= 1'b0;
    else if (cg_en)
      l_buf_level_upd_q <= l_buf_level_upd;
  end


  generate
    if (TMC_CONFIG == ETF)
    begin : gen_mem_flush_etf
      wire                      nxt_mem_flush_req_det;
      reg                       mem_flush_req_det;
      wire                      rwp_waddr_flush_marker_we;
      wire [MEM_ADDR_WIDTH-1:0] nxt_rwp_waddr_flush_marker;
      reg  [MEM_ADDR_WIDTH-1:0] rwp_waddr_flush_marker;
      wire                      nxt_mem_fl_ack_non_empty;
      reg                       mem_fl_ack_non_empty;

      assign nxt_mem_flush_req_det = ctl_trace_capt_en & ((mem_flush_req & ~mem_flush_ack) |
                                                          (mem_flush_req_det & ~mem_flush_ack));

      always @(posedge clk or negedge reset_n)
      begin : s_mem_flush_req_det
        if (!reset_n)
          mem_flush_req_det <= 1'b0;
        else if (cg_en)
          mem_flush_req_det <= nxt_mem_flush_req_det;
      end

      assign rwp_waddr_flush_marker_we = cg_en & mem_flush_req & ~trace_mem_empty & ~mem_flush_req_det;
      assign nxt_rwp_waddr_flush_marker = rwp_waddr_flush_marker_we ? rwp_word_addr_int : rwp_waddr_flush_marker;

      always @(posedge clk or negedge reset_n)
      begin : s_rwp_flush_marker
        if (!reset_n)
          rwp_waddr_flush_marker <= {MEM_ADDR_WIDTH{1'b0}};
        else if (rwp_waddr_flush_marker_we)
          rwp_waddr_flush_marker <= nxt_rwp_waddr_flush_marker;
      end

      assign nxt_mem_fl_ack_non_empty =  mem_flush_req &
                                        (nxt_rrp_word_addr_int == nxt_rwp_waddr_flush_marker) &
                                        (rrp_word_addr_int != nxt_rwp_waddr_flush_marker);

      always @(posedge clk or negedge reset_n)
      begin : s_flush_non_empty
        if (!reset_n)
          mem_fl_ack_non_empty <= 1'b0;
        else if(cg_en)
          mem_fl_ack_non_empty <= nxt_mem_fl_ack_non_empty;
      end

      assign mem_flush_ack = ~ctl_trace_capt_en | trace_mem_empty | mem_fl_ack_non_empty;
    end

    else
    begin : mem_flush_etb
      assign mem_flush_ack = 1'b1;
    end
  endgenerate


  assign mem_wr = ~mem_we_n & ~mem_ce_n;


endmodule
