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


module sdc600_comasyncbridge_indirect_half #(
   parameter FF_SYNC_DEPTH = 2,
   parameter EXT_DOMAIN    = 0
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
   output wire           clk_qactive,
   input  wire           pwr_qreq_n,
   output wire           pwr_qaccept_n,
   output wire           pwr_qdeny,
   output wire           pwr_qactive,
   output wire           pwr_wake
);

wire       sync_rx_req;
wire       sync_tx_ack;
wire       clk_dev_run;
wire       pwr_dev_run;
wire       sync_pwr_qreq_n;

sdc600_comasyncbridge_indirect_com2async # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH  ))
  u_sdc600_comasyncbridge_indirect_com2async (
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
   .clk_on            (clk_dev_run     ),
   .pwr_on            (pwr_dev_run     ),
   .sync_tx_ack       (sync_tx_ack     ));


sdc600_comasyncbridge_indirect_async2com # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH   ))
  u_sdc600_comasyncbridge_indirect_async2com (
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
   .clk_on            (clk_dev_run     ),
   .pwr_on            (pwr_dev_run     ),
   .sync_rx_req       (sync_rx_req     ));


sdc600_comasyncbridge_indirect_clk_lpislave # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH  ))
  u_sdc600_comasyncbridge_indirect_clk_lpislave (
   .reset_n           (reset_n         ),
   .clk               (clk             ),
   .clk_qreq_n        (clk_qreq_n      ),
   .clk_qaccept_n     (clk_qaccept_n   ),
   .clk_qdeny         (clk_qdeny       ),
   .clk_qactive       (clk_qactive     ),
   .clk_dev_run       (clk_dev_run     ),
   .async_rx_req      (async_rx_req    ),
   .sync_rx_req       (sync_rx_req     ),
   .async_rx_ack      (async_rx_ack    ),
   .async_tx_req      (async_tx_req    ),
   .sync_tx_ack       (sync_tx_ack     ),
   .async_rx_linkest  (async_rx_linkest),
   .tx_linkest        (tx_linkest      ),
   .rx_linkest        (rx_linkest      ),
   .async_tx_linkest  (async_tx_linkest),
   .rx_valid          (rx_valid        ),
   .tx_valid          (tx_valid        ),
   .async_tx_linkup   (async_tx_linkup ),
   .rx_linkup         (rx_linkup       ),
   .tx_linkup         (tx_linkup       ),
   .pwr_qreq_n        (pwr_qreq_n      ),
   .pwr_qaccept_n     (pwr_qaccept_n   ),
   .pwr_qdeny         (pwr_qdeny       ),
   .sync_pwr_qreq_n   (sync_pwr_qreq_n ),
   .async_rx_linkup   (async_rx_linkup ));


sdc600_comasyncbridge_indirect_pwr_lpislave # (
   .FF_SYNC_DEPTH       (FF_SYNC_DEPTH   ),
   .EXT_DOMAIN          (EXT_DOMAIN      ))
  u_sdc600_comasyncbridge_indirect_pwr_lpislave (
   .reset_n             (reset_n         ),
   .clk                 (clk             ),
   .pwr_qreq_n          (pwr_qreq_n      ),
   .pwr_qaccept_n       (pwr_qaccept_n   ),
   .pwr_qdeny           (pwr_qdeny       ),
   .pwr_qactive         (pwr_qactive     ),
   .pwr_wake            (pwr_wake        ),
   .sync_pwr_qreq_n     (sync_pwr_qreq_n ),
   .clk_dev_run         (clk_dev_run     ),
   .pwr_dev_run         (pwr_dev_run     ),
   .rx_linkest          (rx_linkest      ),
   .tx_linkest          (tx_linkest      ),
   .sync_rx_req         (sync_rx_req     ),
   .async_rx_req        (async_rx_req    ),
   .async_rx_ack        (async_rx_ack    ),
   .async_tx_req        (async_tx_req    ),
   .sync_tx_ack         (sync_tx_ack     ),
   .rx_valid            (rx_valid        ),
   .tx_valid            (tx_valid        ));


endmodule
