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

module pck600_lpd_p_pch_tinit_sync_sse710_cpu_expander 
#(
  parameter CTRL_P_CH_SYNC = 0)(
  input  wire       clk,
  input  wire       reset_n,
  input  wire       ctrl_preq_i,
  input  wire       ctrl_preq_en_i,
  output wire       ctrl_preq_ss_o,
  input  wire [3:0] ctrl_pstate_i,
  output wire [3:0] ctrl_pstate_ss_o,
  output wire       reset_edge_o,
  output wire       reset_sync_o
);

reg        ctrl_preq_ss;
wire       ctrl_preq_edge;
reg        out_of_rst_en;
wire       pstate_en;
wire [3:0] ctrl_pstate_ss;
wire       reset_edge;
wire       reset_sync;


assign ctrl_preq_ss_o   = ctrl_preq_ss;
assign ctrl_pstate_ss_o = ctrl_pstate_ss;
assign reset_edge_o     = reset_edge;
assign reset_sync_o     = reset_sync;


generate
if(CTRL_P_CH_SYNC == 1)
begin:ctrl_preq_sync_inc
wire       reset_sync_d0;

  pck600_cdc_capt_sync u_cdc_capt_sync_reset (
  .clk     (clk),
  .reset_n (reset_n),
  .async   (1'b1),
  .sync    (reset_sync_d0)
  );

  always @(posedge clk or negedge reset_n)
  if (!reset_n)
      out_of_rst_en    <= 1'b0;
  else
      out_of_rst_en    <= reset_sync_d0;

  assign reset_edge = out_of_rst_en ^ reset_sync_d0;
  assign reset_sync = out_of_rst_en;
wire       ctrl_preq_ss_d0;

  pck600_cdc_capt_sync u_cdc_capt_sync_ctrl_preq (
  .clk     (clk),
  .reset_n (reset_n),
  .async   (ctrl_preq_i),
  .sync    (ctrl_preq_ss_d0)
  );
  always @(posedge clk or negedge reset_n)
  if (!reset_n)
      ctrl_preq_ss    <= 1'b0;
  else if (ctrl_preq_en_i)
      ctrl_preq_ss    <= ctrl_preq_ss_d0;

  pck600_std_xor2 u_xor_preq_edge (
  .A (ctrl_preq_ss_d0),
  .B (ctrl_preq_ss),
  .Y (ctrl_preq_edge)
  );  
end
else
begin:ctrl_preq_sync_excl
  always @(posedge clk or negedge reset_n)
  if (!reset_n)
      out_of_rst_en    <= 1'b1;
  else
      out_of_rst_en    <= 1'b0;

  assign reset_edge = out_of_rst_en;
  assign reset_sync = 1'b1;
  always @(posedge clk or negedge reset_n)
  if (!reset_n)
      ctrl_preq_ss    <= 1'b0;
  else if (ctrl_preq_en_i)
      ctrl_preq_ss    <= ctrl_preq_i;

  pck600_std_xor2 u_xor_preq_edge (
  .A (ctrl_preq_i),
  .B (ctrl_preq_ss),
  .Y (ctrl_preq_edge)
  );
end
endgenerate

assign pstate_en = (ctrl_preq_edge & ctrl_preq_en_i) | reset_edge;

  pck600_cdc_capt_nosync 
  #(
    .IH (3)
  )
  u_cdc_capt_nosync_ctrl_pstate (
  .clk     (clk),
  .reset_n (reset_n),
  .en      (pstate_en),
  .async   (ctrl_pstate_i),
  .sync    (ctrl_pstate_ss)
  );

endmodule
