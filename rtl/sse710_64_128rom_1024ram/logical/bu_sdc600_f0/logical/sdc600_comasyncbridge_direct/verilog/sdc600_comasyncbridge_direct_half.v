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
//      Checked In          : Mon Feb 19 16:31:26 2018 +0100
//
//      Revision            : 19b2149
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------


module sdc600_comasyncbridge_direct_half #(
   parameter FF_SYNC_DEPTH = 2
  )
  (
   input  wire           reset_n,
   input  wire           clk,
   input  wire   [7:0]   rx_data,
   input  wire           rx_valid,
   output wire           rx_ready,
   output wire           rx_linkup,
   input  wire           rx_linkest,
   output wire   [7:0]   async_tx_data,
   output wire           async_tx_req,
   input  wire           async_tx_ack,
   input  wire           async_tx_linkup,
   output wire           async_tx_linkest,
   input  wire   [7:0]   async_rx_data,
   input  wire           async_rx_req,
   output wire           async_rx_ack,
   output wire           async_rx_linkup,
   input  wire           async_rx_linkest,
   output wire   [7:0]   tx_data,
   output wire           tx_valid,
   input  wire           tx_ready,
   input  wire           tx_linkup,
   output wire           tx_linkest,

   input  wire           clk_qreq_n,
   output wire           clk_qaccept_n,
   output wire           clk_qdeny,
   output wire           clk_qactive
);

wire       sync_rx_req;
wire       dev_run;

sdc600_comasyncbridge_direct_com2async # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH  ))
  u_sdc600_comasyncbridge_direct_com2async (
   .reset_n           (reset_n         ),
   .clk               (clk             ),
   .rx_data           (rx_data         ),
   .rx_valid          (rx_valid        ),
   .rx_ready          (rx_ready        ),
   .rx_linkup         (rx_linkup       ),
   .rx_linkest        (rx_linkest      ),
   .async_tx_data     (async_tx_data   ),
   .async_tx_req      (async_tx_req    ),
   .async_tx_ack      (async_tx_ack    ),
   .async_tx_linkup   (async_tx_linkup ),
   .async_tx_linkest  (async_tx_linkest),
   .clk_on            (dev_run         ));


sdc600_comasyncbridge_direct_async2com # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH   ))
  u_sdc600_comasyncbridge_direct_async2com (
   .reset_n           (reset_n         ),
   .clk               (clk             ),
   .tx_data           (tx_data         ),
   .tx_valid          (tx_valid        ),
   .tx_ready          (tx_ready        ),
   .tx_linkup         (tx_linkup       ),
   .tx_linkest        (tx_linkest      ),
   .async_rx_data     (async_rx_data   ),
   .async_rx_req      (async_rx_req    ),
   .async_rx_ack      (async_rx_ack    ),
   .async_rx_linkup   (async_rx_linkup ),
   .async_rx_linkest  (async_rx_linkest),
   .clk_on            (dev_run         ),
   .sync_rx_req       (sync_rx_req     ));


sdc600_comasyncbridge_direct_lpislave # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH  ))
  u_sdc600_comasyncbridge_direct_lpislave (
   .reset_n           (reset_n         ),
   .clk               (clk             ),
   .clk_qreq_n        (clk_qreq_n      ),
   .clk_qaccept_n     (clk_qaccept_n   ),
   .clk_qdeny         (clk_qdeny       ),
   .clk_qactive       (clk_qactive     ),
   .clk_dev_run       (dev_run         ),
   .async_rx_req      (async_rx_req    ),
   .sync_rx_req       (sync_rx_req     ),
   .async_rx_ack      (async_rx_ack    ),
   .async_rx_linkest  (async_rx_linkest),
   .tx_linkest        (tx_linkest      ),
   .rx_valid          (rx_valid        ),
   .async_tx_linkup   (async_tx_linkup ),
   .rx_linkup         (rx_linkup       ));


endmodule

