// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_lpd_p_sequencer_sse710_extsys#(
  parameter DEV_ID             = 0,
  parameter DEV_P_CH_0_SAME_EN = 0,

  parameter DEV_P_CH_1_SAME_EN = 0,

  parameter DEV_P_CH_2_SAME_EN = 0,

  parameter P_CH_PSTATE_LEN    = 4
)(
  input wire                        clk,
  input wire                        reset_n,

  input  wire [P_CH_PSTATE_LEN-1:0] prv_ctrl_pstate_i,
  input  wire [P_CH_PSTATE_LEN-1:0] new_ctrl_pstate_i,
  input  wire [P_CH_PSTATE_LEN-1:0] ctrl_pstate_i,
  input  wire                       ctrl_preq_i,
  output wire                       ctrl_paccept_o,
  output wire                       ctrl_pdeny_o,

  output wire [P_CH_PSTATE_LEN-1:0] dev_pstate_o,
  output wire                       dev_preq_o,
  input  wire                       dev_paccept_i,
  input  wire                       dev_pdeny_i,

  input wire                        request_denied_i,
  input wire                        prv_return_flag_i,
  input wire                        nxt_return_flag_i,
  output wire                       return_flag_o,
  input wire                        all_init_done_i,
  input wire                        all_dev_accepted_i,
  input wire                        prv_dev_accepted_i,
  input wire                        nxt_dev_accepted_i,
  input wire                        ctrl_accepted_i,
  input  wire                       reset_sync_i,
  output wire                       ctrl_preq_en_o,
  output wire                       request_accepted_o,
  output wire                       init_done_o,
  output wire                       int_clken_o
);

`include "pck600_lpd_p_shared_sse710_extsys.v"
  
  always@*
  begin
    case(state)
`include "pck600_lpd_p_init_sse710_extsys.v"
    P_STABLE:
    begin
      state_en               = (ctrl_preq_i | request_accepted_r | return_flag_r);
      nxt_state              = (request_denied_i | ~ctrl_preq_i) ? P_STABLE

                             : (ctrl_pstate_i[3:0] < prv_ctrl_pstate_i[3:0]) ? (nxt_dev_accepted_i ? (dev_p_ch_same_en ? P_REQUEST
                                                                                                 : ((mapped_ctrl_pstate != mapped_prv_pstate) ? P_REQUEST : P_ACCEPT))
                                                                            : P_STABLE)
                             : prv_dev_accepted_i ? (dev_p_ch_same_en ? P_REQUEST
                                                  : ((mapped_ctrl_pstate != mapped_prv_pstate) ? P_REQUEST : P_ACCEPT))
                             : P_STABLE;

      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = dev_pstate_r;
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = 1'b0;
      nxt_return_flag_r      = request_denied_i;
    end
    P_REQUEST:
    begin
      state_en               = (dev_paccept_i | dev_pdeny_i | ~dev_preq_r);
      nxt_state              = (dev_paccept_i) ? P_ACCEPT : (dev_pdeny_i) ? P_DENIED : P_REQUEST;
      nxt_dev_preq_r         = 1'b1;
      nxt_dev_pstate_r       = mapped_ctrl_pstate;
      nxt_ctrl_paccept_r     = dev_paccept_i;
      nxt_ctrl_pdeny_r       = dev_pdeny_i;
      nxt_request_accepted_r = request_accepted_r;
      nxt_return_flag_r      = return_flag_r;
    end
    P_REQ_RTN:
    begin
      state_en               = 1'b1;
      nxt_state = (new_ctrl_pstate_i[3:0] < prv_ctrl_pstate_i[3:0]) ? (prv_return_flag_i ? (dev_p_ch_same_en ? (dev_paccept_i ? P_ACCEPT : P_REQ_RTN)
                                                                                         : ((mapped_new_pstate != mapped_prv_pstate) ? (dev_paccept_i ? P_ACCEPT : P_REQ_RTN) : (nxt_return_flag_i ? P_ACCEPT : P_REQ_RTN)))
                                                                    : P_REQ_RTN)
                : nxt_return_flag_i ? (dev_p_ch_same_en ? (dev_paccept_i ? P_ACCEPT : P_REQ_RTN)
                                    : ((mapped_new_pstate != mapped_prv_pstate) ? (dev_paccept_i ? P_ACCEPT : P_REQ_RTN) : (prv_return_flag_i ? P_ACCEPT : P_REQ_RTN)))
                : P_REQ_RTN;



      nxt_dev_preq_r = (new_ctrl_pstate_i[3:0] < prv_ctrl_pstate_i[3:0]) ? (prv_return_flag_i ? (dev_p_ch_same_en ? ~(dev_paccept_i | dev_pdeny_i)
                                                                                              : ((mapped_new_pstate != mapped_prv_pstate) ? ~(dev_paccept_i | dev_pdeny_i) : 1'b0))
                                                                         : 1'b0)
                     : nxt_return_flag_i ? (dev_p_ch_same_en ? ~(dev_paccept_i | dev_pdeny_i)
                                         : ((mapped_new_pstate != mapped_prv_pstate) ? ~(dev_paccept_i | dev_pdeny_i) : 1'b0))
                     : 1'b0;
      nxt_dev_pstate_r       = dev_pdeny_i ? mapped_new_pstate
                             : (new_ctrl_pstate_i[3:0] >= prv_ctrl_pstate_i[3:0]) ? (nxt_return_flag_i ? mapped_prv_pstate : dev_pstate_r)
                             : prv_return_flag_i ? mapped_prv_pstate
                             : dev_pstate_r;

      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b1;
      nxt_request_accepted_r = 1'b0;
      nxt_return_flag_r      = dev_paccept_i | ((mapped_new_pstate == mapped_prv_pstate) ? (~dev_p_ch_same_en & (nxt_return_flag_i | prv_return_flag_i)) : 1'b0);
    end
    P_ACCEPT:
    begin
      state_en               = 1'b1;
      nxt_state              = P_COMPLETE;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = dev_pstate_r;
      nxt_ctrl_paccept_r     = ~return_flag_r;
      nxt_ctrl_pdeny_r       = return_flag_r;
      nxt_request_accepted_r = request_accepted_r;
      nxt_return_flag_r      = return_flag_r;
    end
    P_DENIED:
    begin
      state_en               = 1'b1;
      nxt_state              = P_COMPLETE;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = mapped_prv_pstate;
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b1;
      nxt_request_accepted_r = 1'b0;
      nxt_return_flag_r      = 1'b1;
    end
    P_COMPLETE:
    begin
      state_en               = 1'b1;
      nxt_state              = (dev_paccept_i | dev_pdeny_i) ? P_COMPLETE
                             : (return_flag_r  & ~ctrl_preq_i)     ? P_STABLE
                             : (all_dev_accepted_i & ~ctrl_preq_i) ? P_STABLE
                             : (request_denied_i & ~return_flag_r) ? P_REQ_RTN
                             : P_COMPLETE;
      nxt_dev_pstate_r       = dev_pstate_r;
      nxt_dev_preq_r         = 1'b0;
      nxt_ctrl_paccept_r     = ~(request_denied_i | return_flag_r);
      nxt_ctrl_pdeny_r       =  (request_denied_i | return_flag_r);
      nxt_request_accepted_r = ~(return_flag_r | dev_paccept_i);
      nxt_return_flag_r      =  return_flag_r;
    end
    default:
    begin
      state_en               = 1'bx;
      nxt_state              = 4'bxxxx;
      nxt_dev_preq_r         = 1'bx;
      nxt_dev_pstate_r       = {P_CH_PSTATE_LEN{1'bx}};
      nxt_ctrl_paccept_r     = 1'bx;
      nxt_ctrl_pdeny_r       = 1'bx;
      nxt_request_accepted_r = 1'bx;
      nxt_return_flag_r      = 1'bx;
    end
    endcase
  end

assign return_flag_o = return_flag_r;



endmodule
