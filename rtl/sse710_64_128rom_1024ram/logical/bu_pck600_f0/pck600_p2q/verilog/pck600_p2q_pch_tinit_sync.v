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

module pck600_p2q_pch_tinit_sync
#(parameter CTRL_P_CH_SYNC = 0
) (
  input  wire                          clk,
  input  wire                          reset_n,
  input  wire                          ctrl_preq_i,
  input  wire [7:0]                    ctrl_pstate_i,

  output wire                          ctrl_preq_edge_o,
  output wire                          ctrl_preq_ss_o,
  output wire [7:0]                    ctrl_pstate_ss_o

);

  wire                          ctrl_preq_edge;
  wire                          ctrl_preq_ss;
  wire                          ctrl_preq_ss_d0;
  wire [7:0]                    ctrl_pstate_ss;
  wire                          pstate_en;
  reg                           pstate_rst_en;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
        pstate_rst_en    <= 1'b1;
    else
        pstate_rst_en    <= 1'b0;


generate
if(CTRL_P_CH_SYNC == 1)
begin:ctrl_preq_sync_inc
  pck600_cdc_capt_sync u_pck600_sync_ctrl_preq (
  .clk     (clk),
  .reset_n (reset_n),
  .async   (ctrl_preq_i),
  .sync    (ctrl_preq_ss_d0)
  );
  pck600_cdc_capt_nosync u_pck600_nosync_ctrl_preq (
  .clk     (clk),
  .reset_n (reset_n),
  .en      (1'b1),
  .async   (ctrl_preq_ss_d0),
  .sync    (ctrl_preq_ss)
  );
  pck600_std_xor2 u_pck600_xor2_preq_edge (
  .A (ctrl_preq_ss_d0),
  .B (ctrl_preq_ss),
  .Y (ctrl_preq_edge)
  );

end
else
begin:ctrl_preq_sync_excl
  pck600_cdc_capt_nosync u_pck600_nosync_ctrl_preq (
  .clk     (clk),
  .reset_n (reset_n),
  .en      (1'b1),
  .async   (ctrl_preq_i),
  .sync    (ctrl_preq_ss)
  );
  pck600_std_xor2 u_pck600_xor2_preq_edge (
  .A (ctrl_preq_i),
  .B (ctrl_preq_ss),
  .Y (ctrl_preq_edge)
  );

end
endgenerate

  assign pstate_en = ctrl_preq_edge | pstate_rst_en;

  pck600_cdc_capt_nosync
  #(.IH (7))
  u_pck600_nosync_ctrl_pstate (
  .clk     (clk),
  .reset_n (reset_n),
  .en      (pstate_en),
  .async   (ctrl_pstate_i),
  .sync    (ctrl_pstate_ss)
  );

  assign ctrl_preq_ss_o   = ctrl_preq_ss;
  assign ctrl_preq_edge_o = ctrl_preq_edge;
  assign ctrl_pstate_ss_o = ctrl_pstate_ss;

endmodule
