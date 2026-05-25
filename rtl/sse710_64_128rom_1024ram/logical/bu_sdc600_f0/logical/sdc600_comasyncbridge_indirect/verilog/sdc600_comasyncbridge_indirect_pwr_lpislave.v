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
//----------------------------------------------------------------------------
//      Version Information
//
//      Checked In          : Thu May 24 13:16:26 2018 +0100
//
//      Revision            : b339e32
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------

module sdc600_comasyncbridge_indirect_pwr_lpislave #(
   parameter FF_SYNC_DEPTH = 2,
   parameter EXT_DOMAIN    = 0
   )
   (
   input  wire           reset_n,
   input  wire           clk,
   input  wire           pwr_qreq_n,
   output wire           pwr_qaccept_n,
   output wire           pwr_qdeny,
   output wire           pwr_qactive,
   output wire           pwr_wake,
   output wire           sync_pwr_qreq_n,
   input  wire           clk_dev_run,
   output wire           pwr_dev_run,
   input  wire           tx_linkest,
   input  wire           rx_linkest,
   input  wire           sync_rx_req,
   input  wire           async_rx_req,
   input  wire           async_rx_ack,
   input  wire           async_tx_req,
   input  wire           sync_tx_ack,
   input  wire           rx_valid,
   input  wire           tx_valid
);

wire         lp_request;
wire         lp_done;
wire         dev_active;
reg          dev_active_reg;

sdc600_lpislave u_pwr_lpislave (
   .clk            (clk),
   .reset_n        (reset_n),
   .qreq_sync_n    (sync_pwr_qreq_n),
   .qaccept_n      (pwr_qaccept_n),
   .qdeny          (pwr_qdeny),
   .lp_request     (lp_request),
   .int_dev_active (dev_active),
   .ext_dev_active (dev_active),
   .lp_done        (lp_done),
   .dev_run        (pwr_dev_run),
   .cg_en          ()
);


assign lp_done = lp_request & clk_dev_run;

generate
if (EXT_DOMAIN == 1) begin : GENDEVACTIVE_EXT_DOMAIN
  assign dev_active = sync_rx_req | sync_tx_ack | tx_valid | rx_valid | async_tx_req | async_rx_ack | tx_linkest;
end
else begin : GENDEVACTIVE_INT_DOMAIN
  assign dev_active = sync_rx_req | sync_tx_ack | tx_valid | rx_valid | async_tx_req | async_rx_ack | rx_linkest;
end
endgenerate

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    dev_active_reg <= 1'b0;
  end
  else begin
    dev_active_reg <= dev_active;
  end
end


generate
if (EXT_DOMAIN == 1) begin : GENQACTIVE_EXT_DOMAIN
  sdc600_or4 u_or4_qactive (.in_a(dev_active_reg), .in_b(async_rx_req), .in_c(rx_linkest), .in_d(1'b0), .out_y(pwr_qactive));
end
else begin : GENQACTIVE_INT_DOMAIN
  sdc600_or4 u_or4_qactive (.in_a(dev_active_reg), .in_b(async_rx_req), .in_c(tx_linkest), .in_d(1'b0), .out_y(pwr_qactive));
end
endgenerate

assign pwr_wake = pwr_qactive;

sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_pwr_qreq_n    (.clk(clk), .reset_n(reset_n),  .d(pwr_qreq_n),  .q(sync_pwr_qreq_n));

endmodule
