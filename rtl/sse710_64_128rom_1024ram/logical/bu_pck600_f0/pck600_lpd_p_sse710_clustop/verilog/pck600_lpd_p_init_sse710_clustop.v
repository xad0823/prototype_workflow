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


    P_SYNC:
    begin
      nxt_state              = reset_sync_i               ? P_INIT0 : P_SYNC;
      state_en               = 1'b1;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = {P_CH_PSTATE_LEN{1'b0}};
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = 1'b0;
      nxt_return_flag_r      = 1'b0;
    end
    P_INIT0:
    begin
      nxt_state              = (dev_paccept_i)            ? P_INIT1 : P_INIT0;
      state_en               = 1'b1;
      nxt_dev_preq_r         = ~(dev_paccept_i | dev_pdeny_i);
      nxt_dev_pstate_r       = {P_CH_PSTATE_LEN{1'b0}};
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = dev_paccept_i;
      nxt_return_flag_r      = 1'b0;
    end
    P_INIT1:
    begin
      nxt_state              = dev_paccept_i              ? P_INIT1 :
                              ((mapped_ctrl_pstate ==
                                {P_CH_PSTATE_LEN{1'b0}})  ? (ctrl_preq_i ? P_INIT3 : P_INIT_END) :
                              P_INIT2);
      state_en               = 1'b1;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = {P_CH_PSTATE_LEN{1'b0}};
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = ((ctrl_pstate_i[3:0]== 4'h0)  && ~ctrl_preq_i) ? 1'b1 : 1'b0;
      nxt_return_flag_r      = 1'b0;
    end
    P_INIT2:
    begin
      nxt_state              = (dev_paccept_i)            ? P_INIT3 : P_INIT2;
      state_en               = 1'b1;
      nxt_dev_preq_r         = ~(dev_paccept_i | dev_pdeny_i);
      nxt_dev_pstate_r       = dev_pdeny_i ? {P_CH_PSTATE_LEN{1'b0}} : mapped_ctrl_pstate;
      nxt_ctrl_paccept_r     = 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = request_accepted_r;
      nxt_return_flag_r      = 1'b0;
    end
    P_INIT3:
    begin
      nxt_state              = dev_paccept_i              ? P_INIT3 :
                               (((ctrl_accepted_i | ~ctrl_preq_i) && all_dev_accepted_i) ? P_INIT_END :
                               P_INIT3);
      state_en               = 1'b1;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = dev_pstate_r;
      nxt_ctrl_paccept_r     = ctrl_preq_i;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = 1'b1;
      nxt_return_flag_r      = 1'b0;
    end
    P_INIT_END:
    begin
      nxt_state              = ctrl_accepted_i            ? P_INIT_END :
                               (all_init_done_i           ? P_STABLE   :
                               P_INIT_END);
      state_en               = 1'b1;
      nxt_dev_preq_r         = 1'b0;
      nxt_dev_pstate_r       = dev_pstate_r;
      nxt_ctrl_paccept_r     = ctrl_preq_i ? (~all_init_done_i || ctrl_preq_i) : 1'b0;
      nxt_ctrl_pdeny_r       = 1'b0;
      nxt_request_accepted_r = ~all_init_done_i;
      nxt_return_flag_r      = 1'b0;
    end
