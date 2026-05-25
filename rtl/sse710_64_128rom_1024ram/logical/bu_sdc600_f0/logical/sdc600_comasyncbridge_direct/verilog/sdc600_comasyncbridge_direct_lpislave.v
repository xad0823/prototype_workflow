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
//      Checked In          : Tue Apr 24 15:16:59 2018 +0100
//
//      Revision            : c7ce7fc
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------


module sdc600_comasyncbridge_direct_lpislave #(
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
   input  wire           async_rx_linkest,
   input  wire           tx_linkest,
   input  wire           rx_valid,
   input  wire           async_tx_linkup,
   input  wire           rx_linkup
);


wire         qactive_sync;
wire         int_dev_active;
wire         qreq_sync_n;
wire         lp_request;

sdc600_lpislave u_sdc600_lpislave (
   .clk            (clk),
   .reset_n        (reset_n),
   .qreq_sync_n    (qreq_sync_n),
   .qaccept_n      (clk_qaccept_n),
   .qdeny          (clk_qdeny),
   .lp_request     (lp_request),
   .int_dev_active (int_dev_active),
   .ext_dev_active (1'b0),
   .lp_done        (lp_request),
   .dev_run        (clk_dev_run),
   .cg_en          ()
);

assign qactive_sync  = rx_valid | async_rx_ack;
reg qactive_sync_reg;

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    qactive_sync_reg <= 1'b0;
  end
  else begin
    qactive_sync_reg <= qactive_sync;
  end
end

wire asrxliest_xor_txlest;
wire astxlup_xor_rxlup;
sdc600_xor u_xor_qactive_asrxliest_xor_txlest  (.in_a(async_rx_linkest    ), .in_b(tx_linkest       ), .out_y(asrxliest_xor_txlest));
sdc600_xor u_xor_qactive_astxlup_xor_rxlup     (.in_a(async_tx_linkup     ), .in_b(rx_linkup        ), .out_y(astxlup_xor_rxlup   ));

sdc600_or4 u_or4_qactive  (.in_a(qactive_sync_reg), .in_b(async_rx_req), .in_c(asrxliest_xor_txlest), .in_d(astxlup_xor_rxlup), .out_y(clk_qactive));

assign int_dev_active = sync_rx_req | qactive_sync;

sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_clk_qreq_n (.clk(clk), .reset_n(reset_n), .d(clk_qreq_n), .q(qreq_sync_n));

endmodule
