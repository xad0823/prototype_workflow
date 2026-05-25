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
//      Checked In          : Thu Apr 5 12:52:00 2018 +0100
//
//      Revision            : be9415f
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------


module sdc600_comasyncbridge_direct_half_int #(
   parameter FF_SYNC_DEPTH = 2
  )
  (
   input  wire           resetn_int,
   input  wire           clk_int,
   input  wire   [7:0]   int_rx_data,
   input  wire           int_rx_valid,
   output wire           int_rx_ready,
   output wire           int_rx_linkup,
   input  wire           int_rx_linkest,
   output wire   [7:0]   int_async_ie_data,
   output wire           int_async_ie_req,
   input  wire           int_async_ie_ack,
   input  wire           int_async_ie_linkup,
   output wire           int_async_ie_linkest,
   input  wire   [7:0]   int_async_ei_data,
   input  wire           int_async_ei_req,
   output wire           int_async_ei_ack,
   output wire           int_async_ei_linkup,
   input  wire           int_async_ei_linkest,
   output wire   [7:0]   int_tx_data,
   output wire           int_tx_valid,
   input  wire           int_tx_ready,
   input  wire           int_tx_linkup,
   output wire           int_tx_linkest,

   input  wire           int_clk_qreq_n,
   output wire           int_clk_qaccept_n,
   output wire           int_clk_qdeny,
   output wire           int_clk_qactive
);


sdc600_comasyncbridge_direct_half # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH  ))
  u_sdc600_comasyncbridge_direct_half (
   .reset_n           (resetn_int           ),
   .clk               (clk_int              ),
   .rx_data           (int_rx_data          ),
   .rx_valid          (int_rx_valid         ),
   .rx_ready          (int_rx_ready         ),
   .rx_linkup         (int_rx_linkup        ),
   .rx_linkest        (int_rx_linkest       ),
   .async_tx_data     (int_async_ie_data    ),
   .async_tx_req      (int_async_ie_req     ),
   .async_tx_ack      (int_async_ie_ack     ),
   .async_tx_linkup   (int_async_ie_linkup  ),
   .async_tx_linkest  (int_async_ie_linkest ),
   .async_rx_data     (int_async_ei_data    ),
   .async_rx_req      (int_async_ei_req     ),
   .async_rx_ack      (int_async_ei_ack     ),
   .async_rx_linkup   (int_async_ei_linkup  ),
   .async_rx_linkest  (int_async_ei_linkest ),
   .tx_data           (int_tx_data          ),
   .tx_valid          (int_tx_valid         ),
   .tx_ready          (int_tx_ready         ),
   .tx_linkup         (int_tx_linkup        ),
   .tx_linkest        (int_tx_linkest       ),
   .clk_qreq_n        (int_clk_qreq_n       ),
   .clk_qaccept_n     (int_clk_qaccept_n    ),
   .clk_qdeny         (int_clk_qdeny        ),
   .clk_qactive       (int_clk_qactive      ));


endmodule

