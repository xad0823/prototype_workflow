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
//      Checked In          : Tue May 8 15:44:55 2018 +0200
//
//      Revision            : e27ce4b
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------

module sdc600_comasyncbridge_indirect_clk_lpislave #(
    parameter FF_SYNC_DEPTH = 2
   )
   (
   input  wire           reset_n,
   input  wire           clk,
   input  wire           clk_qreq_n,
   output wire           clk_qaccept_n,
   output wire           clk_qdeny,
   output wire           clk_qactive,
   output wire           clk_dev_run,
   input  wire           async_rx_req,
   input  wire           sync_rx_req,
   input  wire           async_rx_ack,
   input  wire           async_tx_req,
   input  wire           sync_tx_ack,
   input  wire           async_rx_linkest,
   input  wire           tx_linkest,
   input  wire           rx_linkest,
   input  wire           async_tx_linkest,
   input  wire           rx_valid,
   input  wire           tx_valid,
   input  wire           async_tx_linkup,
   input  wire           rx_linkup,
   input  wire           tx_linkup,
   input  wire           pwr_qreq_n,
   input  wire           pwr_qaccept_n,
   input  wire           pwr_qdeny,
   input  wire           sync_pwr_qreq_n,
   input  wire           async_rx_linkup
);


wire         qactive_sync;
wire         int_dev_active;
wire         sync_clk_qreq_n;
wire         lp_request;
wire         asrxlest_xor_txlest;
wire         astxlest_xor_rxlest;
wire         asrxlup_xor_txlup;
wire         astxlup_xor_rxlup;
wire         pqreq_xor_pqacc;
wire         linkphase_change;
wire         cwi_wake;
reg          qactive_sync_reg;


sdc600_lpislave u_clk_lpislave (
   .clk            (clk),
   .reset_n        (reset_n),
   .qreq_sync_n    (sync_clk_qreq_n),
   .qaccept_n      (clk_qaccept_n),
   .qdeny          (clk_qdeny),
   .lp_request     (lp_request),
   .int_dev_active (int_dev_active),
   .ext_dev_active (1'b0),
   .lp_done        (lp_request),
   .dev_run        (clk_dev_run),
   .cg_en          ()
);

assign qactive_sync = sync_rx_req | sync_tx_ack | (sync_pwr_qreq_n ^ pwr_qaccept_n) | tx_valid | rx_valid | async_tx_req | async_rx_ack | pwr_qdeny;

assign int_dev_active = qactive_sync;

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    qactive_sync_reg <= 1'b0;
  end
  else begin
    qactive_sync_reg <= qactive_sync;
  end
end

sdc600_xor u_xor_qactive_asrxlest_xor_txlest (.in_a(async_rx_linkest   ), .in_b(tx_linkest         ), .out_y(asrxlest_xor_txlest));
sdc600_xor u_xor_qactive_astxlest_xor_rxlest (.in_a(async_tx_linkest   ), .in_b(rx_linkest         ), .out_y(astxlest_xor_rxlest));
sdc600_xor u_xor_qactive_asrxlup_xor_txlup   (.in_a(async_rx_linkup    ), .in_b(tx_linkup          ), .out_y(asrxlup_xor_txlup  ));
sdc600_xor u_xor_qactive_astxlup_xor_rxlup   (.in_a(async_tx_linkup    ), .in_b(rx_linkup          ), .out_y(astxlup_xor_rxlup  ));
sdc600_xor u_xor_qactive_pqreq_xor_pqacc     (.in_a(pwr_qreq_n         ), .in_b(pwr_qaccept_n      ), .out_y(pqreq_xor_pqacc    ));
sdc600_or4  u_or4_qactive_linkphase_change   (.in_a(asrxlest_xor_txlest), .in_b(astxlest_xor_rxlest), .in_c(asrxlup_xor_txlup), .in_d(astxlup_xor_rxlup), .out_y(linkphase_change));
sdc600_or  u_or_qactive_cwi_wake             (.in_a(async_rx_req), .in_b(rx_valid), .out_y(cwi_wake));

sdc600_or4  u_or4_qactive                    (.in_a(qactive_sync_reg), .in_b(cwi_wake), .in_c(pqreq_xor_pqacc), .in_d(linkphase_change), .out_y(clk_qactive));


sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_clk_qreq_n (.clk(clk), .reset_n(reset_n), .d(clk_qreq_n), .q(sync_clk_qreq_n));

endmodule
