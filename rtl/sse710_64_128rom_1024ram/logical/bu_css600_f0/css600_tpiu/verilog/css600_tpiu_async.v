//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
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


module css600_tpiu_async
(
  input  wire       itctrl_ime,
  input  wire       pwakeup_s,
  input  wire       atwakeup_s,
  input  wire       flush_fsm_busy,
  input  wire       flush_pend,

  input  wire       trigin,
  input  wire       trigin_q,
  input  wire       trigin_mon,

  input  wire       flushin,
  input  wire       flushin_q,
  input  wire       flushin_mon,

  input  wire       pab_active,

  output wire       trig_flush_wake,
  output wire       clk_qactive
);


  wire       or_trigin;
  wire       or_flushin;
  wire       and_trigin;
  wire       and_flushin;


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

  css600_or_tree #(.NUM_OR_INPUTS (7))
    u_css600_or_qactive (.or_inputs ({itctrl_ime
                                     ,pwakeup_s
                                     ,atwakeup_s
                                     ,flush_fsm_busy
                                     ,trig_flush_wake
                                     ,flush_pend
                                     ,pab_active
                                     }),
                        .or_output (clk_qactive));

endmodule

