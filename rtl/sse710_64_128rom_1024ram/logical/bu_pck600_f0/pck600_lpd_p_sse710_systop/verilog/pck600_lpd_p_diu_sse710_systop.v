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


module pck600_lpd_p_diu_sse710_systop 
#(
  parameter SEQUENCER          = 1,
  parameter DEV_P_CH_NUM       = 4,
  parameter DEV_P_CH_0_SAME_EN = 0,

  parameter DEV_P_CH_1_SAME_EN = 0,

  parameter DEV_P_CH_2_SAME_EN = 0,

  parameter DEV_P_CH_3_SAME_EN = 0,

  parameter DEV_P_CH_PREQ_DLY  = 0)(
  input wire                     clk,
  input wire                     reset_n,

  input  wire                    reset_edge_i,
  input  wire                    reset_sync_i,
  input  wire [3:0]              ctrl_pstate_i,
  input  wire                    ctrl_preq_i,
  output wire                    ctrl_paccept_o,
  output wire                    ctrl_pdeny_o,
  output wire                    ctrl_preq_en_o,

  output wire [3:0]              dev0_pstate_o,
  output wire [3:0]              dev1_pstate_o,
  output wire [3:0]              dev2_pstate_o,
  output wire [3:0]              dev3_pstate_o,
  output wire [DEV_P_CH_NUM-1:0] dev_preq_o,
  input  wire [DEV_P_CH_NUM-1:0] dev_paccept_i,
  input  wire [DEV_P_CH_NUM-1:0] dev_pdeny_i,

  output wire                    int_clken_o
);

wire                    all_dev_accepted;
reg                     all_dev_accepted_r;
wire all_dev_accepted_pe  = (all_dev_accepted | all_dev_accepted_r);

wire [DEV_P_CH_NUM-1:0] init_done;
wire                    all_init_done = &init_done;

wire                    request_denied;

wire [3:0] dev_pstate   [0:DEV_P_CH_NUM-1];
reg  [3:0] dev_pstate_r [0:DEV_P_CH_NUM-1];
wire [DEV_P_CH_NUM-1:0] dev_preq;
wire [DEV_P_CH_NUM-1:0] ctrl_paccept;
wire [DEV_P_CH_NUM-1:0] ctrl_pdeny;
wire [DEV_P_CH_NUM-1:0] ctrl_preq_en;
reg                     ctrl_paccept_r;
reg                     ctrl_pdeny_r;

wire [DEV_P_CH_NUM-1:0] int_clken;
reg                     int_clken_r;



wire [3:0] nxt_prv_ctrl_pstate;
wire       prv_ctrl_pstate_en;

reg  [3:0] prv_ctrl_pstate_r;

assign prv_ctrl_pstate_en = all_init_done  |
                            ctrl_paccept_r |
                            reset_edge_i;

assign nxt_prv_ctrl_pstate = ctrl_pstate_i;

always@(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    prv_ctrl_pstate_r <= {4{1'b0}};
  else if (prv_ctrl_pstate_en)
    prv_ctrl_pstate_r <= nxt_prv_ctrl_pstate;
end  

always@(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    begin
      all_dev_accepted_r   <= 1'b0;
    end
  else
    begin
      all_dev_accepted_r   <= all_dev_accepted;
    end
end

reg [3:0] new_ctrl_pstate_r;

always@(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    new_ctrl_pstate_r <= {4{1'b0}};
  else if (ctrl_preq_i)
    new_ctrl_pstate_r <= ctrl_pstate_i;
end

genvar g;
generate if(SEQUENCER == 0)
begin : gen_expander
wire [DEV_P_CH_NUM-1:0] dev_accepted;
assign all_dev_accepted = &dev_accepted;

wire [DEV_P_CH_NUM-1:0] stable;
wire all_stable     =  &stable;

  for (g = 0; g < DEV_P_CH_NUM; g = g + 1)
  begin: g_exp_sm_inst
    pck600_lpd_p_expander_sse710_systop 
    #(
      .DEV_ID             (g),
      .DEV_P_CH_0_SAME_EN (DEV_P_CH_0_SAME_EN),

      .DEV_P_CH_1_SAME_EN (DEV_P_CH_1_SAME_EN),

      .DEV_P_CH_2_SAME_EN (DEV_P_CH_2_SAME_EN),

      .DEV_P_CH_3_SAME_EN (DEV_P_CH_3_SAME_EN),

      .P_CH_PSTATE_LEN    (4)
    ) u_exp_sm (
      .clk                (clk),
      .reset_n            (reset_n),
      .prv_ctrl_pstate_i  (prv_ctrl_pstate_r),
      .new_ctrl_pstate_i  (new_ctrl_pstate_r),
      .ctrl_pstate_i      (ctrl_pstate_i),
      .ctrl_preq_i        (ctrl_preq_i),
      .ctrl_paccept_o     (ctrl_paccept[g]),
      .ctrl_pdeny_o       (ctrl_pdeny[g]),

      .dev_pstate_o       (dev_pstate[g]),
      .dev_preq_o         (dev_preq[g]),
      .dev_paccept_i      (dev_paccept_i[g]),
      .dev_pdeny_i        (dev_pdeny_i[g]),

      .request_denied_i   (request_denied),
      .all_dev_accepted_i (all_dev_accepted_pe),
      .request_accepted_o (dev_accepted[g]),

      .all_init_done_i    (all_init_done),
      .all_stable_i       (all_stable),
      .init_done_o        (init_done[g]),
      .reset_sync_i       (reset_sync_i),

      .stable_o           (stable[g]),
      .ctrl_accepted_i    (ctrl_paccept_r),
      .ctrl_preq_en_o     (ctrl_preq_en[g]),
      .int_clken_o        (int_clken[g])
    );
  end
end
else
begin : gen_sequencer
wire [DEV_P_CH_NUM+1:0] dev_accepted;
wire [DEV_P_CH_NUM+1:0] dev_return_flag;

assign all_dev_accepted                = &dev_accepted;
assign dev_accepted[0]                 = 1'b1;
assign dev_return_flag[0]              = 1'b1;
assign dev_accepted[DEV_P_CH_NUM+1]    = 1'b1;
assign dev_return_flag[DEV_P_CH_NUM+1] = 1'b1;

  for (g = 0; g < DEV_P_CH_NUM; g = g + 1)
      begin: g_seq_sm
        pck600_lpd_p_sequencer_sse710_systop 
        #(
          .DEV_ID             (g),
          .DEV_P_CH_0_SAME_EN (DEV_P_CH_0_SAME_EN),

          .DEV_P_CH_1_SAME_EN (DEV_P_CH_1_SAME_EN),

          .DEV_P_CH_2_SAME_EN (DEV_P_CH_2_SAME_EN),

          .DEV_P_CH_3_SAME_EN (DEV_P_CH_3_SAME_EN),

          .P_CH_PSTATE_LEN    (4)
        ) u_seq_sm (
          .clk                (clk),
          .reset_n            (reset_n),
          .prv_ctrl_pstate_i  (prv_ctrl_pstate_r),
          .new_ctrl_pstate_i  (new_ctrl_pstate_r),
          .ctrl_pstate_i      (ctrl_pstate_i),
          .ctrl_preq_i        (ctrl_preq_i),
          .ctrl_paccept_o     (ctrl_paccept[g]),
          .ctrl_pdeny_o       (ctrl_pdeny[g]),
          .dev_pstate_o       (dev_pstate[g]),
          .dev_preq_o         (dev_preq[g]),
          .dev_paccept_i      (dev_paccept_i[g]),
          .dev_pdeny_i        (dev_pdeny_i[g]),

          .all_init_done_i    (all_init_done),
          .init_done_o        (init_done[g]),
          .reset_sync_i       (reset_sync_i),

          .all_dev_accepted_i (all_dev_accepted_pe),
          .ctrl_accepted_i    (ctrl_paccept_r),
          .request_denied_i   (request_denied),
          .ctrl_preq_en_o     (ctrl_preq_en[g]),

          .prv_return_flag_i  (dev_return_flag[g]),
          .return_flag_o      (dev_return_flag[g+1]),
          .nxt_return_flag_i  (dev_return_flag[g+2]),

          .prv_dev_accepted_i (dev_accepted[g]),
          .request_accepted_o (dev_accepted[g+1]),
          .nxt_dev_accepted_i (dev_accepted[g+2]),

          .int_clken_o        (int_clken[g])
        );
      end
end
endgenerate

  assign request_denied = (|dev_pdeny_i) | (|ctrl_pdeny) | ctrl_pdeny_r;


generate if(DEV_P_CH_PREQ_DLY == 1)
begin:dev_preq_inc
reg  [DEV_P_CH_NUM-1:0] dev_preq_r;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
      dev_preq_r      <= {DEV_P_CH_NUM{1'b0}};
    else
      dev_preq_r      <= dev_preq; 
  end

assign dev_preq_o     = dev_preq_r;

end
else begin:dev_preq_excl
assign dev_preq_o     = dev_preq;
end
endgenerate

always@(posedge clk or negedge reset_n)
  if (!reset_n)
    begin
      ctrl_paccept_r  <= 1'b0;
      ctrl_pdeny_r    <= 1'b0;
    end
  else
    begin
      ctrl_paccept_r  <= &ctrl_paccept;
      ctrl_pdeny_r    <= |ctrl_pdeny;
    end

assign ctrl_paccept_o = ctrl_paccept_r;
assign ctrl_pdeny_o   = ctrl_pdeny_r;
assign ctrl_preq_en_o = (&ctrl_preq_en);

assign dev0_pstate_o  = dev_pstate[0];
assign dev1_pstate_o  = dev_pstate[1];
assign dev2_pstate_o  = dev_pstate[2];
assign dev3_pstate_o  = dev_pstate[3];



always@(posedge clk or negedge reset_n)
  if (!reset_n)
    int_clken_r <= 1'b1;
  else
    int_clken_r <= |int_clken | ctrl_paccept_r | ctrl_pdeny_r;

assign int_clken_o = int_clken_r;


endmodule
