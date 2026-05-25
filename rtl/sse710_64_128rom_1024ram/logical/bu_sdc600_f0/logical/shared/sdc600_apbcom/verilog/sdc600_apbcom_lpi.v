//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Jun 11 17:40:35 2018 +0200
//
//      Revision            : 73e8cd4
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_apbcom_lpi #(
  parameter APBCOM_VAR  = 0
)
(
input   wire  pclk,
input   wire  presetn,
input   wire  pwr_qreq_n,

input   wire  pwr_qreq_sync_n,
output  wire  pwr_qdeny,
output  wire  pwr_qaccept_n,
output  wire  pwr_qactive,

input   wire  clk_qreq_sync_n,
output  wire  clk_qdeny,
output  wire  clk_qaccept_n,
output  wire  clk_qactive,

input   wire  psel,
input   wire  pwakeup,
input   wire  rempur,
input   wire  rempua,
input   wire  remrr,
input   wire  remra,
input   wire  tx_linkest,
input   wire  rx_linkest,
input   wire  rx_linkest_reg,
input   wire  tx_valid,
input   wire  rx_valid,
input   wire  rxfifo_full,
input   wire  irq,
output  wire  clk_lp_request,
output  wire  pwr_lp_request,
output  wire  clk_dev_run,
output  wire  pwr_dev_run
);

`include "sdc600_apbcom_variants.v"

wire  clk_dev_active_nowake;
wire  clk_dev_active_wake;
wire  clk_dev_active;

generate
if (APBCOM_VAR == APBCOM_INT) begin : GENCLKDEVACTIVE_INT
  assign  clk_dev_active_nowake  =  psel | tx_valid | (pwr_qreq_sync_n ^ pwr_qaccept_n) | pwr_qdeny;
end
else begin : GENCLKDEVACTIVE_NON_INT
  assign  clk_dev_active_nowake  =  psel | tx_valid | (pwr_qreq_sync_n ^ pwr_qaccept_n) | pwr_qdeny | remrr | remra | (rempur ^ rempua);
end
endgenerate

assign  clk_dev_active_wake  = rx_valid | (rx_linkest ^ rx_linkest_reg);

assign  clk_dev_active = clk_dev_active_nowake | clk_dev_active_wake;


reg clk_active_internal_reg;

always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    clk_active_internal_reg <= 1'b0;
  end
  else begin
    clk_active_internal_reg <= clk_dev_active;
  end
end

sdc600_lpislave u_clk_lpislave
(
  .clk            (pclk),
  .reset_n        (presetn),
  .qreq_sync_n    (clk_qreq_sync_n),
  .qaccept_n      (clk_qaccept_n),
  .qdeny          (clk_qdeny),
  .int_dev_active (clk_dev_active),
  .ext_dev_active (1'b0),
  .lp_done        (clk_lp_request),
  .lp_request     (clk_lp_request),
  .dev_run        (clk_dev_run),
  .cg_en          ()
);

wire  pwr_lpreq;
sdc600_xor u_xor_pwr_lpreq_for_pwrlpi(.in_a(pwr_qreq_n), .in_b(pwr_qaccept_n), .out_y(pwr_lpreq));
sdc600_or4 u_or4_clk_qactive(.in_a(pwakeup), .in_b(pwr_lpreq), .in_c(clk_dev_active_wake), .in_d(clk_active_internal_reg), .out_y(clk_qactive));


generate
if (APBCOM_VAR == APBCOM_INT) begin : GEN_PWR_LPI

wire  pwr_dev_active;
assign  pwr_dev_active = psel | rx_valid | tx_valid | tx_linkest;

wire pwr_showing_active = rx_linkest | rxfifo_full | irq;
wire pwr_active_internal = pwr_showing_active | pwr_dev_active;

reg pwr_active_internal_reg;

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      pwr_active_internal_reg <= 1'b0;
    end
    else begin
      pwr_active_internal_reg <= pwr_active_internal;
    end
  end

assign pwr_qactive = pwr_active_internal_reg;

wire pwr_lp_done = pwr_lp_request & clk_dev_run;

sdc600_lpislave u_pwr_lpislave
(
  .clk            (pclk),
  .reset_n        (presetn),
  .qreq_sync_n    (pwr_qreq_sync_n),
  .qaccept_n      (pwr_qaccept_n),
  .qdeny          (pwr_qdeny),
  .int_dev_active (pwr_dev_active),
  .ext_dev_active (pwr_dev_active),
  .lp_done        (pwr_lp_done),
  .lp_request     (pwr_lp_request),
  .dev_run        (pwr_dev_run),
  .cg_en          ()
);

end
else begin : GEN_NO_PWR_LPI
  assign  pwr_dev_run    = 1'b1;
  assign  pwr_lp_request = 1'b0;
  assign  pwr_qdeny      = 1'b0;
  assign  pwr_qaccept_n  = 1'b0;
  assign  pwr_qactive    = 1'b1;
end
endgenerate


endmodule
