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

localparam P_SYNC     = 4'b0000;
localparam P_INIT0    = 4'b0001;
localparam P_INIT1    = 4'b0011;
localparam P_INIT2    = 4'b0010;
localparam P_INIT3    = 4'b0110;
localparam P_INIT_END = 4'b0111;
localparam P_STABLE   = 4'b1111;
localparam P_REQUEST  = 4'b1001;
localparam P_ACCEPT   = 4'b1010;
localparam P_REQ_RTN  = 4'b1011; 
localparam P_COMPLETE = 4'b1100;
localparam P_DENIED   = 4'b1101;

reg [3:0]                   state;
reg [3:0]                   nxt_state;
reg                         state_en;

reg                         dev_preq_r;
reg [P_CH_PSTATE_LEN-1:0]   dev_pstate_r;
reg                         ctrl_paccept_r;
reg                         ctrl_pdeny_r;
reg                         ctrl_preq_en_r;
reg                         request_accepted_r;
reg                         return_flag_r;

reg [P_CH_PSTATE_LEN-1:0]   nxt_dev_pstate_r;
reg                         nxt_dev_preq_r;
reg                         nxt_ctrl_paccept_r;
reg                         nxt_ctrl_pdeny_r;
wire                        nxt_ctrl_preq_en_r;
reg                         nxt_request_accepted_r;
reg                         nxt_return_flag_r;


assign ctrl_paccept_o      = ctrl_paccept_r;
assign ctrl_pdeny_o        = ctrl_pdeny_r;
assign ctrl_preq_en_o      = ctrl_preq_en_r;

assign dev_preq_o          = dev_preq_r;
assign dev_pstate_o        = dev_pstate_r;

assign request_accepted_o  = request_accepted_r;
assign init_done_o         = (&state[2:0]) & (~state[3]);

assign nxt_ctrl_preq_en_r  = ~((state  == P_INIT0)    |
                               (state  == P_INIT1)    |
                               (state  == P_INIT2)    |
                               (state  == P_INIT3)    |
                               ((state == P_INIT_END) &
                                 (~all_init_done_i)));

assign int_clken_o = ((state == P_STABLE) & ~ctrl_preq_i) ? 1'b0: 1'b1;

wire [P_CH_PSTATE_LEN-1:0] mapped_ctrl_pstate;
wire [P_CH_PSTATE_LEN-1:0] mapped_prv_pstate;
wire [P_CH_PSTATE_LEN-1:0] mapped_new_pstate;

  pck600_lpd_p_pstatemap_sse710_extsys  #(
    .DEV_ID          (DEV_ID),
    .P_CH_PSTATE_LEN (P_CH_PSTATE_LEN)
  ) 
  u_pstatemap_ctrl
  (
    .pstate_in    (ctrl_pstate_i),
    .pstate_map   (mapped_ctrl_pstate)
  );
  pck600_lpd_p_pstatemap_sse710_extsys  #(
    .DEV_ID          (DEV_ID),
    .P_CH_PSTATE_LEN (P_CH_PSTATE_LEN)
  ) 
  u_pstatemap_prv 
  (
    .pstate_in    (prv_ctrl_pstate_i),
    .pstate_map   (mapped_prv_pstate)
  );
  pck600_lpd_p_pstatemap_sse710_extsys  #(
    .DEV_ID          (DEV_ID),
    .P_CH_PSTATE_LEN (P_CH_PSTATE_LEN)
  ) 
  u_pstatemap_new 
  (
    .pstate_in    (new_ctrl_pstate_i),
    .pstate_map   (mapped_new_pstate)
  );


wire dev_p_ch_same_en = (DEV_ID == 0) ? ((DEV_P_CH_0_SAME_EN == 0)  ? 1'b0 : 1'b1) 
                      : (DEV_ID == 1) ? ((DEV_P_CH_1_SAME_EN == 0)  ? 1'b0 : 1'b1)
                      : (DEV_ID == 2) ? ((DEV_P_CH_2_SAME_EN == 0)  ? 1'b0 : 1'b1) : 1'bx;


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dev_preq_r         <= 1'b0;
      dev_pstate_r       <= {P_CH_PSTATE_LEN{1'b0}};
      ctrl_paccept_r     <= 1'b0;
      ctrl_pdeny_r       <= 1'b0;
      ctrl_preq_en_r     <= 1'b1;
      request_accepted_r <= 1'b0;
      return_flag_r      <= 1'b0;
      state              <= P_SYNC;
    end
    else if(state_en)
    begin
      dev_preq_r         <= nxt_dev_preq_r;
      dev_pstate_r       <= nxt_dev_pstate_r;
      ctrl_paccept_r     <= nxt_ctrl_paccept_r;
      ctrl_pdeny_r       <= nxt_ctrl_pdeny_r;
      ctrl_preq_en_r     <= nxt_ctrl_preq_en_r;
      request_accepted_r <= nxt_request_accepted_r;
      return_flag_r      <= nxt_return_flag_r;
      state              <= nxt_state;
    end
  end
