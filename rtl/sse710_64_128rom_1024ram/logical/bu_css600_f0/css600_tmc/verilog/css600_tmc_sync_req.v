//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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


module css600_tmc_sync_req
#(
  parameter TMC_CONFIG     = 1,
  parameter ATB_DATA_WIDTH = 32
)
(
  input  wire       clk,
  input  wire       cg_en,
  input  wire       clk_g,
  input  wire       reset_n,

  input  wire       ctl_trace_capt_en,
  input  wire       ctl_trace_capt_en_rise,
  input  wire       ffcr_en_formatting_masked,
  input  wire       hw_fifo_mode,
  input  wire       ft_running,
  input  wire       stop_pending,
  input  wire       pscr_embed_sync,
  input  wire [4:0] pscr_pscount,
  input  wire       pscr_ctr_decr_pulse,

  input  wire       itctrl_ime,
  input  wire       it_atb_ctr_2_wr_en,
  input  wire       apb_wdata_p_bit2,

  output wire       frame_sync_req,

  input  wire       dev_run,
  input  wire       lp_done,

  input  wire       syncreq_m,
  output wire       syncreq_s
);

  `include "css600_tmc_localparams.v"
  `include "css600_tmc_functions.v"

  localparam PSCR_PAD = ((TMC_CONFIG == ETR) ||
                         (TMC_CONFIG == ETS)) ? tmc_clog2(ATB_DATA_WIDTH/8)
                                              : tmc_clog2(ATB_DATA_WIDTH/8) + 1;

  localparam PSCR_WIDTH = (28 - PSCR_PAD);


  wire [27:0]           pscr_ctr;
  reg  [27:0]           nxt_pscr_ctr;
  wire [PSCR_WIDTH-1:0] nxt_pscr_ctr_int;
  reg  [PSCR_WIDTH-1:0] pscr_ctr_int;

  wire                  pscr_en;
  wire                  pscr_ctr_decr;
  wire                  pscr_ctr_reload;
  wire [27:0]           pscr_decr_value;
  wire [27:0]           pscr_reload_value;
  wire                  ctr_zero_pre;

  wire                  int_sync_req_forced;
  wire                  nxt_int_sync_detect;
  wire                  nxt_int_sync_req;
  reg                   int_sync_req;
  wire                  nxt_int_sync_req_pend;
  reg                   int_sync_req_pend;
  wire                  ext_sync_req;

  wire                  int_sync_req_en;

  reg                   ctl_trace_capt_en_rise_q;


  assign pscr_reload_value = {28{pscr_pscount == 5'h07}} & 28'h0000080 |
                             {28{pscr_pscount == 5'h08}} & 28'h0000100 |
                             {28{pscr_pscount == 5'h09}} & 28'h0000200 |
                             {28{pscr_pscount == 5'h0A}} & 28'h0000400 |
                             {28{pscr_pscount == 5'h0B}} & 28'h0000800 |
                             {28{pscr_pscount == 5'h0C}} & 28'h0001000 |
                             {28{pscr_pscount == 5'h0D}} & 28'h0002000 |
                             {28{pscr_pscount == 5'h0E}} & 28'h0004000 |
                             {28{pscr_pscount == 5'h0F}} & 28'h0008000 |
                             {28{pscr_pscount == 5'h10}} & 28'h0010000 |
                             {28{pscr_pscount == 5'h11}} & 28'h0020000 |
                             {28{pscr_pscount == 5'h12}} & 28'h0040000 |
                             {28{pscr_pscount == 5'h13}} & 28'h0080000 |
                             {28{pscr_pscount == 5'h14}} & 28'h0100000 |
                             {28{pscr_pscount == 5'h15}} & 28'h0200000 |
                             {28{pscr_pscount == 5'h16}} & 28'h0400000 |
                             {28{pscr_pscount == 5'h17}} & 28'h0800000 |
                             {28{pscr_pscount == 5'h18}} & 28'h1000000 |
                             {28{pscr_pscount == 5'h19}} & 28'h2000000 |
                             {28{pscr_pscount == 5'h1A}} & 28'h4000000 |
                             {28{pscr_pscount == 5'h1B}} & 28'h8000000;

  assign pscr_decr_value = (28'h000_0001 << PSCR_PAD);

  assign pscr_en = (|pscr_pscount) & ctl_trace_capt_en;

  assign pscr_ctr_reload = pscr_en & (ctl_trace_capt_en_rise | ctr_zero_pre);
  assign pscr_ctr_decr = pscr_ctr_decr_pulse & (|pscr_ctr);

  always @*
  begin : c_nxt_pscr_ctr
    case ({pscr_ctr_reload, pscr_ctr_decr})
      2'b00 : nxt_pscr_ctr =  pscr_ctr;
      2'b01 : nxt_pscr_ctr = (pscr_ctr - pscr_decr_value);
      2'b10,
      2'b11 : nxt_pscr_ctr =  pscr_reload_value;
    endcase
  end

  assign nxt_pscr_ctr_int = nxt_pscr_ctr[27:PSCR_PAD];

  always @ (posedge clk or negedge reset_n)
  begin : s_pscr_ctr_int
    if (!reset_n)
      pscr_ctr_int <= {28-PSCR_PAD{1'b0}};
    else if (cg_en)
      pscr_ctr_int <= nxt_pscr_ctr_int;
  end

  assign pscr_ctr = {pscr_ctr_int, {PSCR_PAD{1'b0}}};

  assign ctr_zero_pre =  pscr_en & pscr_ctr_decr &
                        (pscr_ctr_int == {{28-PSCR_PAD-1{1'b0}},1'b1});

  assign int_sync_req_forced = ffcr_en_formatting_masked & pscr_en & ctl_trace_capt_en_rise_q;

  always @ (posedge clk or negedge reset_n)
  begin : s_ctl_trace_capt_en_rise_q
    if (!reset_n)
      ctl_trace_capt_en_rise_q <= 1'b0;
    else if (cg_en)
      ctl_trace_capt_en_rise_q <= ctl_trace_capt_en_rise;
  end

  assign frame_sync_req =  ffcr_en_formatting_masked &
                           pscr_embed_sync &
                           nxt_int_sync_detect;

  assign int_sync_req_en = ~itctrl_ime | it_atb_ctr_2_wr_en;

  assign nxt_int_sync_detect   = (ctr_zero_pre | int_sync_req_forced);
  assign nxt_int_sync_req      = itctrl_ime ? apb_wdata_p_bit2
                               : nxt_int_sync_detect & ( dev_run & ~lp_done)
                               | int_sync_req_pend &  dev_run;
  assign nxt_int_sync_req_pend = int_sync_req_pend & ~dev_run
                               | nxt_int_sync_detect & ( dev_run &  lp_done)
                               | nxt_int_sync_detect & (~dev_run & ~lp_done)
                               ;

  always @ (posedge clk_g or negedge reset_n)
  begin : s_intsyncreq
    if (!reset_n)
    begin
      int_sync_req      <= 1'b0;
      int_sync_req_pend <= 1'b0;
    end
    else if (int_sync_req_en)
    begin
      int_sync_req      <= nxt_int_sync_req;
      int_sync_req_pend <= nxt_int_sync_req_pend;
    end
  end

  generate
    if (TMC_CONFIG == ETF)
    begin : gen_ext_syncreq
      assign ext_sync_req = syncreq_m & ft_running & ~stop_pending & hw_fifo_mode;
    end

    else
    begin : dont_gen_ext_syncreq
      assign ext_sync_req = 1'b0;
    end
  endgenerate

  assign syncreq_s = itctrl_ime ? int_sync_req : (ext_sync_req | int_sync_req);

endmodule

