//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017 Arm Limited or its affiliates.
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


module css600_tmc_async
#(
  parameter TMC_CONFIG = 0
)
(
  input  wire       itctrl_ime,
  input  wire       pwakeup_s,
  input  wire       atwakeup_s,
  input  wire       flush_fsm_busy,

  input  wire       trigin,
  input  wire       trigin_q,
  input  wire       trigin_mon,

  input  wire       flushin,
  input  wire       flushin_q,
  input  wire       flushin_mon,

  input  wire       awvalid_m,
  input  wire       wvalid_m,
  input  wire       read_in_prog,
  input  wire [5:0] outstanding_wreq_cnt_p,

  input  wire       twakeup_m,

  input  wire       ffcr_drain_buffer_en,
  input  wire       atwakeup_m,

  input  wire       atbm_flush_mon,
  input  wire       afvalid_m,

  output wire       clk_qactive
);

  `include "css600_tmc_localparams.v"

  wire or_trigin;
  wire or_flushin;
  wire and_trigin;
  wire and_flushin;
  wire trig_flush_wake;
  wire or1;
  wire or2;
  wire or3;


  css600_or
    u_css600_or_trigin (.out_y (or_trigin),
                        .in_a  (trigin),
                        .in_b  (trigin_q));

  css600_or
    u_css600_or_flushin (.out_y (or_flushin),
                         .in_a  (flushin),
                         .in_b  (flushin_q));

  css600_and #(.OP_W(1))
    u_css600_and_trigin (.dataout (and_trigin),
                         .maskn   (trigin_mon),
                         .datain  (or_trigin));

  css600_and #(.OP_W(1))
    u_css600_and_flushin (.dataout (and_flushin),
                          .maskn   (flushin_mon),
                          .datain  (or_flushin));

  css600_or
    u_css600_or_trig_flush (.out_y (trig_flush_wake),
                            .in_a  (and_flushin),
                            .in_b  (and_trigin));

  css600_or
    u_css600_or1 (.out_y (or1),
                  .in_a  (itctrl_ime),
                  .in_b  (pwakeup_s));

  css600_or
    u_css600_or2 (.out_y (or2),
                  .in_a  (atwakeup_s),
                  .in_b  (flush_fsm_busy));


  css600_or
    u_css600_or3 (.out_y (or3),
                  .in_a  (or1),
                  .in_b  (or2));

  generate
    if (TMC_CONFIG == ETB)
      begin : gen_qactive_etb

        css600_or
          u_css600_or_qactive (.out_y (clk_qactive),
                               .in_a  (or3),
                               .in_b  (trig_flush_wake));
      end

    if (TMC_CONFIG == ETF)
      begin : gen_qactive_etf
        wire or4;
        wire or5;
        wire or6;
        wire and_afvalidm;

        css600_or
          u_css600_or_qactive (.out_y (clk_qactive),
                               .in_a  (or5),
                               .in_b  (trig_flush_wake));

        css600_or
          u_css600_or6 (.out_y (or6),
                        .in_a  (atwakeup_m),
                        .in_b  (ffcr_drain_buffer_en));

        css600_or
          u_css600_or5 (.out_y (or5),
                        .in_a  (or4),
                        .in_b  (and_afvalidm));

        css600_or
          u_css600_or4 (.out_y (or4),
                        .in_a  (or3),
                        .in_b  (or6));

        css600_and #(.OP_W(1))
          u_css600_and_afvalidm (.dataout (and_afvalidm),
                                 .maskn   (atbm_flush_mon),
                                 .datain  (afvalid_m));

      end

    if (TMC_CONFIG == ETR)
      begin : gen_qactive_etr
        wire axi_wr_in_prog;
        wire or4;
        wire or5;
        wire or6;
        wire or7;
        wire or8;
        wire or9;
        wire or10;
        wire axi_intf_pend;

        css600_or
          u_css600_or_axi_wr_in_prog (.out_y (axi_wr_in_prog),
                                      .in_a  (awvalid_m),
                                      .in_b  (wvalid_m));

        css600_or
          u_css600_or4 (.out_y (or4),
                        .in_a  (outstanding_wreq_cnt_p[5]),
                        .in_b  (outstanding_wreq_cnt_p[4]));

        css600_or
          u_css600_or5 (.out_y (or5),
                        .in_a  (outstanding_wreq_cnt_p[3]),
                        .in_b  (outstanding_wreq_cnt_p[2]));

        css600_or
          u_css600_or6 (.out_y (or6),
                        .in_a  (outstanding_wreq_cnt_p[1]),
                        .in_b  (outstanding_wreq_cnt_p[0]));

        css600_or
          u_css600_or7 (.out_y (or7),
                        .in_a  (read_in_prog),
                        .in_b  (or4));

        css600_or
          u_css600_or8 (.out_y (or8),
                        .in_a  (or5),
                        .in_b  (or6));

        css600_or
          u_css600_or9 (.out_y (or9),
                        .in_a  (or7),
                        .in_b  (or8));

        css600_or
          u_css600_or_axi_intf_pend (.out_y (axi_intf_pend),
                                     .in_a  (axi_wr_in_prog),
                                     .in_b  (or9));

        css600_or
          u_css600_or10 (.out_y (or10),
                         .in_a  (or3),
                         .in_b  (trig_flush_wake));

        css600_or
          u_css600_or_qactive (.out_y (clk_qactive),
                               .in_a  (or10),
                               .in_b  (axi_intf_pend));

      end

    if (TMC_CONFIG == ETS)
      begin : gen_qactive_ets
        wire or4;

        css600_or
          u_css600_or_qactive (.out_y (clk_qactive),
                               .in_a  (or4),
                               .in_b  (trig_flush_wake));

        css600_or
          u_css600_or4 (.out_y (or4),
                        .in_a  (or3),
                        .in_b  (twakeup_m));
      end
  endgenerate

endmodule

