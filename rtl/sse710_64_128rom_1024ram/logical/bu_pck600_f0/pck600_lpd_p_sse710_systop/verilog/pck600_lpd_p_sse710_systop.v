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


module pck600_lpd_p_sse710_systop 
#(
  parameter SEQUENCER          = 1,
  parameter DEV_P_CH_0_SAME_EN = 0,

  parameter DEV_P_CH_1_SAME_EN = 0,

  parameter DEV_P_CH_2_SAME_EN = 0,

  parameter DEV_P_CH_3_SAME_EN = 0,

  parameter CTRL_P_CH_SYNC     = 0,
  parameter DEV_P_CH_SYNC      = 0,
  parameter DEV_P_CH_PREQ_DLY  = 0) (
  input wire          clk,
  input wire          reset_n,

  input  wire         ctrl_preq_i,
  input  wire [3:0]   ctrl_pstate_i,
  output wire [10:0]   ctrl_pactive_o,
  output wire         ctrl_paccept_o,
  output wire         ctrl_pdeny_o,

  output wire         dev0_preq_o,
  output wire [3:0]   dev0_pstate_o,
  input  wire [10:0]   dev0_pactive_i,
  input  wire         dev0_paccept_i,
  input  wire         dev0_pdeny_i,

  output wire         dev1_preq_o,
  output wire [3:0]   dev1_pstate_o,
  input  wire [10:0]   dev1_pactive_i,
  input  wire         dev1_paccept_i,
  input  wire         dev1_pdeny_i,

  output wire         dev2_preq_o,
  output wire [3:0]   dev2_pstate_o,
  input  wire [10:0]   dev2_pactive_i,
  input  wire         dev2_paccept_i,
  input  wire         dev2_pdeny_i,

  output wire         dev3_preq_o,
  output wire [3:0]   dev3_pstate_o,
  input  wire [10:0]   dev3_pactive_i,
  input  wire         dev3_paccept_i,
  input  wire         dev3_pdeny_i,


  output wire         clk_qactive_o,

  input wire          dftcgen

);

wire       ctrl_preq_en;
wire       reset_edge;
wire       reset_sync;
wire [3:0] ctrl_pstate_ss;
wire [3:0] devpreq;
wire [3:0] dev0pstate;
wire [3:0] dev1pstate;
wire [3:0] dev2pstate;
wire [3:0] dev3pstate;
wire       clk_gated;
wire       int_clken;
wire       ctrl_preq_ss;
wire [3:0] dev_paccept_ss;
wire [3:0] dev_pdeny_ss;
wire       clk_enable;

pck600_lpd_p_diu_sse710_systop  #(
    .SEQUENCER          (SEQUENCER),
    .DEV_P_CH_NUM       (4),
    .DEV_P_CH_0_SAME_EN (DEV_P_CH_0_SAME_EN),

    .DEV_P_CH_1_SAME_EN (DEV_P_CH_1_SAME_EN),

    .DEV_P_CH_2_SAME_EN (DEV_P_CH_2_SAME_EN),

    .DEV_P_CH_3_SAME_EN (DEV_P_CH_3_SAME_EN),

    .DEV_P_CH_PREQ_DLY  (DEV_P_CH_PREQ_DLY)
  )
  u_lpd_p_diu
  (
    .clk              (clk_gated),
    .reset_n          (reset_n),
    .reset_edge_i     (reset_edge),
    .reset_sync_i     (reset_sync),
    .ctrl_pstate_i    (ctrl_pstate_ss),
    .ctrl_preq_i      (ctrl_preq_ss),
    .ctrl_paccept_o   (ctrl_paccept_o),
    .ctrl_pdeny_o     (ctrl_pdeny_o),
    .ctrl_preq_en_o   (ctrl_preq_en),
    .dev_preq_o       (devpreq),
    .dev0_pstate_o    (dev0pstate),
    .dev1_pstate_o    (dev1pstate),
    .dev2_pstate_o    (dev2pstate),
    .dev3_pstate_o    (dev3pstate),
    .dev_paccept_i    (dev_paccept_ss),
    .dev_pdeny_i      (dev_pdeny_ss),
    .int_clken_o      (int_clken)
  );

  pck600_std_or2 u_pck600_or2_clken
  (
    .A  (int_clken),
    .B  (ctrl_preq_ss),
    .Y  (clk_enable)
  );


pck600_clock_gate u_pck600_clock_gate (
  .clk_in     (clk),
  .enable     (clk_enable),
  .clk_out    (clk_gated),
  .dftcgen    (dftcgen)
  );


pck600_lpd_p_active_async_sse710_systop  u_lpd_p_active (
  .dev0_pactive_i  (dev0_pactive_i),
  .dev1_pactive_i  (dev1_pactive_i),
  .dev2_pactive_i  (dev2_pactive_i),
  .dev3_pactive_i  (dev3_pactive_i),
  .ctrl_pactive_o  (ctrl_pactive_o),
  .ctrl_preq_i     (ctrl_preq_i),
  .int_clken_i     (int_clken),
  .clk_qactive_o   (clk_qactive_o)
  );


pck600_lpd_p_pch_tinit_sync_sse710_systop 
 #(
    .CTRL_P_CH_SYNC (CTRL_P_CH_SYNC)
  )
  u_lpd_p_tinit_sync
  (
    .clk              (clk),
    .reset_n          (reset_n),
    .ctrl_preq_i      (ctrl_preq_i),
    .ctrl_preq_en_i   (ctrl_preq_en),
    .ctrl_preq_ss_o   (ctrl_preq_ss),
    .ctrl_pstate_i    (ctrl_pstate_i),
    .ctrl_pstate_ss_o (ctrl_pstate_ss),
    .reset_edge_o     (reset_edge),
    .reset_sync_o     (reset_sync)
  );


generate
if(DEV_P_CH_SYNC == 1)
begin:dev0_sync_inc
  pck600_cdc_capt_sync u_pck600_sync_dev0_paccept (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev0_paccept_i),
  .sync    (dev_paccept_ss[0])
  );

  pck600_cdc_capt_sync u_pck600_sync_dev0_pdeny (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev0_pdeny_i),
  .sync    (dev_pdeny_ss[0])
  );
end
else
begin:dev0_sync_excl
assign dev_paccept_ss[0] = dev0_paccept_i;
assign dev_pdeny_ss[0]   = dev0_pdeny_i;
end
endgenerate

assign dev0_preq_o   = devpreq[0];
assign dev0_pstate_o = dev0pstate;


generate
if(DEV_P_CH_SYNC == 1)
begin:dev1_sync_inc
  pck600_cdc_capt_sync u_pck600_sync_dev1_paccept (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev1_paccept_i),
  .sync    (dev_paccept_ss[1])
  );

  pck600_cdc_capt_sync u_pck600_sync_dev1_pdeny (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev1_pdeny_i),
  .sync    (dev_pdeny_ss[1])
  );
end
else
begin:dev1_sync_excl
assign dev_paccept_ss[1] = dev1_paccept_i;
assign dev_pdeny_ss[1]   = dev1_pdeny_i;
end
endgenerate

assign dev1_preq_o   = devpreq[1];
assign dev1_pstate_o = dev1pstate;


generate
if(DEV_P_CH_SYNC == 1)
begin:dev2_sync_inc
  pck600_cdc_capt_sync u_pck600_sync_dev2_paccept (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev2_paccept_i),
  .sync    (dev_paccept_ss[2])
  );

  pck600_cdc_capt_sync u_pck600_sync_dev2_pdeny (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev2_pdeny_i),
  .sync    (dev_pdeny_ss[2])
  );
end
else
begin:dev2_sync_excl
assign dev_paccept_ss[2] = dev2_paccept_i;
assign dev_pdeny_ss[2]   = dev2_pdeny_i;
end
endgenerate

assign dev2_preq_o   = devpreq[2];
assign dev2_pstate_o = dev2pstate;


generate
if(DEV_P_CH_SYNC == 1)
begin:dev3_sync_inc
  pck600_cdc_capt_sync u_pck600_sync_dev3_paccept (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev3_paccept_i),
  .sync    (dev_paccept_ss[3])
  );

  pck600_cdc_capt_sync u_pck600_sync_dev3_pdeny (
  .clk     (clk_gated),
  .reset_n (reset_n),
  .async   (dev3_pdeny_i),
  .sync    (dev_pdeny_ss[3])
  );
end
else
begin:dev3_sync_excl
assign dev_paccept_ss[3] = dev3_paccept_i;
assign dev_pdeny_ss[3]   = dev3_pdeny_i;
end
endgenerate

assign dev3_preq_o   = devpreq[3];
assign dev3_pstate_o = dev3pstate;




endmodule
