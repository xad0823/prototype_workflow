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


module pck600_lpc_q
#(
  parameter NUM_CTRL_Q_CHL = 2,
  parameter NUM_DEV_Q_CHL  = 1,
  parameter CTRL_Q_CH_SYNC = 1,
  parameter DEV_Q_CH_SYNC  = 1
)
(

  input  wire                      clk,
  input  wire                      reset_n,

  input  wire                      dftcgen,

  input  wire [NUM_CTRL_Q_CHL-1:0] ctrl_qreqn_i,
  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qacceptn_o,
  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qdeny_o,
  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qactive_o,

  output wire [NUM_DEV_Q_CHL-1:0]  dev_qreqn_o,
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qacceptn_i,
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qdeny_i,
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qactive_i,

  output wire                      clk_qactive_o
);



  genvar                      I;

  wire                        clk_gated;

  wire                        int_clken;

  wire                        clk_qactive_syn;

  wire [NUM_CTRL_Q_CHL-1:0]   ctrl_qreqn_ss;
  wire [NUM_DEV_Q_CHL-1:0]    dev_qacceptn_ss;
  wire [NUM_DEV_Q_CHL-1:0]    dev_qdeny_ss;



  pck600_lpc_q_core
  #(
    .NUM_CTRL_Q_CHL (NUM_CTRL_Q_CHL),
    .NUM_DEV_Q_CHL  (NUM_DEV_Q_CHL)
  )
  u_lpc_core
  (
    .clk              (clk_gated),
    .reset_n          (reset_n),
    .ctrl_qreqn_i     (ctrl_qreqn_ss),
    .ctrl_qacceptn_o  (ctrl_qacceptn_o),
    .ctrl_qdeny_o     (ctrl_qdeny_o),
    .dev_qreqn_o      (dev_qreqn_o),
    .dev_qacceptn_i   (dev_qacceptn_ss),
    .dev_qdeny_i      (dev_qdeny_ss),
    .clk_qactive_syn_o(clk_qactive_syn),
    .int_clken_o      (int_clken)
  );


  pck600_lpc_q_active_async
  #(
    .NUM_CTRL_Q_CHL (NUM_CTRL_Q_CHL),
    .NUM_DEV_Q_CHL  (NUM_DEV_Q_CHL)
  )
  u_lpc_active_async
  (
    .dev_qactive_i    (dev_qactive_i),
    .ctrl_qreqn_i     (ctrl_qreqn_i),
    .ctrl_qacceptn_i  (ctrl_qacceptn_o),
    .clk_qactive_syn_i(clk_qactive_syn),
    .ctrl_qactive_o   (ctrl_qactive_o),
    .clk_qactive_o    (clk_qactive_o)
  );


  pck600_clock_gate
  u_pck600_clock_gate
  (
    .clk_in (clk),
    .enable (int_clken),
    .clk_out(clk_gated),
    .dftcgen(dftcgen)
  );


generate
if(CTRL_Q_CH_SYNC == 1)
begin:ctrl_sync_inc

  for(I=0; I<NUM_CTRL_Q_CHL; I=I+1)
  begin:ctrl_sync_loop

    pck600_cdc_capt_sync
    u_pck600_sync_qreqn
    (
      .clk     (clk),
      .reset_n (reset_n),
      .async   (ctrl_qreqn_i[I]),
      .sync    (ctrl_qreqn_ss[I])
    );

  end

end
else
begin:ctrl_sync_excl

  assign ctrl_qreqn_ss = ctrl_qreqn_i;

end
endgenerate

generate
if(DEV_Q_CH_SYNC == 1)
begin:dev_sync_inc

  for(I=0; I<NUM_DEV_Q_CHL; I=I+1)
  begin:dev_sync_loop
    pck600_cdc_capt_sync
    u_pck600_sync_qacceptn
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (dev_qacceptn_i[I]),
      .sync    (dev_qacceptn_ss[I])
    );

    pck600_cdc_capt_sync
    u_pck600_sync_qdeny
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (dev_qdeny_i[I]),
      .sync    (dev_qdeny_ss[I])
    );
  end

end
else
begin:dev_sync_excl

  assign dev_qacceptn_ss = dev_qacceptn_i;
  assign dev_qdeny_ss    = dev_qdeny_i;

end
endgenerate

endmodule

