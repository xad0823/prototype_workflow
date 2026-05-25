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


module pck600_clk_ctrl
#(
  parameter NUM_Q_CHL            = 1,
  parameter NUM_QACTIVE_ONLY     = 1,
  parameter HC_Q_CH_SYNC         = 1,
  parameter PWR_Q_CH_SYNC        = 1,
  parameter CLK_Q_CH_SYNC        = 1,
  parameter CLK_QACTIVE_SYNC     = 1,
  parameter ACTIVE_DENY_EN       = 1
)
(
  input  wire                                   clk,
  input  wire                                   reset_n,

  input  wire                                   dftcgen,

  input  wire                                   hc_qreqn_i,
  output wire                                   hc_qacceptn_o,
  output wire                                   hc_qdeny_o,
  output wire                                   hc_qactive_o,

  input  wire                                   pwr_qreqn_i,
  output wire                                   pwr_qacceptn_o,
  output wire                                   pwr_qdeny_o,
  output wire                                   pwr_qactive_o,

  output wire [NUM_Q_CHL-1:0]                   clk_qreqn_o,
  input  wire [NUM_Q_CHL-1:0]                   clk_qacceptn_i,
  input  wire [NUM_Q_CHL+NUM_QACTIVE_ONLY-1:0]  clk_qactive_i,
  input  wire [NUM_Q_CHL-1:0]                   clk_qdeny_i,

  input  wire                                   clk_force_i,

  input  wire [7:0]                             entry_delay_i,

  output wire                                   clken_o

);

localparam NUM_QACTIVE = NUM_Q_CHL + NUM_QACTIVE_ONLY;


  genvar                      I;

  wire                        clk_gated;
  wire                        int_clk_en;

  wire                        clk_force_ss;
  wire [7:0]                  entry_delay_ss;
  wire                        hc_qreqn_ss;
  wire                        pwr_qreqn_ss;
  wire [NUM_QACTIVE-1:0]      clk_qactive_ss;
  wire [NUM_Q_CHL-1:0]        clk_qacceptn_ss;
  wire [NUM_Q_CHL-1:0]        clk_qdeny_ss;


  pck600_clk_ctrl_core
  #(
    .NUM_Q_CHL          (NUM_Q_CHL),
    .NUM_QACTIVE        (NUM_QACTIVE),
    .ACTIVE_DENY_EN     (ACTIVE_DENY_EN)
  )
  u_pck600_clk_ctrl_core
  (
    .clk                (clk_gated),
    .reset_n            (reset_n),
    .dftcgen            (dftcgen),
    .hc_qreqn_i         (hc_qreqn_ss),
    .hc_qacceptn_o      (hc_qacceptn_o),
    .hc_qdeny_o         (hc_qdeny_o),
    .pwr_qreqn_i        (pwr_qreqn_ss),
    .pwr_qacceptn_o     (pwr_qacceptn_o),
    .pwr_qdeny_o        (pwr_qdeny_o),
    .clk_qreqn_o        (clk_qreqn_o),
    .clk_qacceptn_i     (clk_qacceptn_ss),
    .clk_qactive_i      (clk_qactive_ss),
    .clk_qdeny_i        (clk_qdeny_ss),
    .clk_force_i        (clk_force_ss),
    .entry_delay_i      (entry_delay_ss),
    .clk_en_o           (clken_o),
    .int_clk_en_o       (int_clk_en)
  );


  pck600_clk_ctrl_active_async
  #(
    .NUM_QACTIVE          (NUM_QACTIVE)
  )
  u_pck600_clk_ctrl_active_async
  (
    .clk_qactive_async_i  (clk_qactive_i),
    .pwr_qreqn_async_i    (pwr_qreqn_i),
    .pwr_qacceptn_i       (pwr_qacceptn_o),
    .pwr_qdeny_i          (pwr_qdeny_o),
    .hc_qactive_o         (hc_qactive_o),
    .pwr_qactive_o        (pwr_qactive_o)
  );


  pck600_clock_gate
  u_pck600_clock_gate
  (
    .clk_in     (clk),
    .enable     (int_clk_en),
    .clk_out    (clk_gated),
    .dftcgen    (dftcgen)
  );


  pck600_cdc_capt_sync
  u_pck600_sync_clkforce
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (clk_force_i),
    .sync    (clk_force_ss)
  );

generate
for (I = 0; I < 8; I = I + 1)
begin: gen_entrydelay
  pck600_cdc_capt_sync
  u_pck600_sync_entrydelay
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (entry_delay_i[I]),
    .sync    (entry_delay_ss[I])
  );
end
endgenerate

generate if(HC_Q_CH_SYNC == 1)
begin:hc_sync_inc

  pck600_cdc_capt_sync
  u_pck600_sync_hcqreqn
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (hc_qreqn_i),
    .sync    (hc_qreqn_ss)
  );

end
else
begin:hc_sync_omit

  assign hc_qreqn_ss = hc_qreqn_i;

end
endgenerate

generate
if(PWR_Q_CH_SYNC == 1)
begin:pwr_sync_inc

  pck600_cdc_capt_sync
  u_pck600_sync_pwrqreqn
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (pwr_qreqn_i),
    .sync    (pwr_qreqn_ss)
  );

end
else
begin:pwr_sync_omit

  assign pwr_qreqn_ss = pwr_qreqn_i;

end
endgenerate

generate
if(CLK_Q_CH_SYNC == 1)
begin:qaccept_deny_sync_inc

  for(I=0; I<NUM_Q_CHL; I=I+1)
  begin:qaccept_qdeny_sync_loop

    pck600_cdc_capt_sync
    u_pck600_sync_qacceptn
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (clk_qacceptn_i[I]),
      .sync    (clk_qacceptn_ss[I])
    );

    pck600_cdc_capt_sync
    u_pck600_sync_qdeny
    (
      .clk     (clk_gated),
      .reset_n (reset_n),
      .async   (clk_qdeny_i[I]),
      .sync    (clk_qdeny_ss[I])
    );

  end

end
else
begin:qaccept_deny_sync_omit

  assign clk_qacceptn_ss = clk_qacceptn_i;
  assign clk_qdeny_ss    = clk_qdeny_i;

end
endgenerate

generate if(CLK_QACTIVE_SYNC == 1)
begin :clkqactive_sync_inc
   for(I=0; I<NUM_QACTIVE; I=I+1)
   begin:clkqactive_sync_loop

     pck600_cdc_capt_sync
     u_pck600_sync_qactive
     (
       .clk     (clk),
       .reset_n (reset_n),
       .async   (clk_qactive_i[I]),
       .sync    (clk_qactive_ss[I])
     );

   end
end
else
begin:clkqactive_sync_omit

   assign clk_qactive_ss = clk_qactive_i;

end
endgenerate

endmodule
