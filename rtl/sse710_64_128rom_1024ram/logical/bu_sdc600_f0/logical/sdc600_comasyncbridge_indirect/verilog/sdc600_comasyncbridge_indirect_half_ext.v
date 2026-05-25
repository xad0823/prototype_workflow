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
//      Checked In          : Fri May 18 13:48:14 2018 +0200
//
//      Revision            : 7f646ae
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------


module sdc600_comasyncbridge_indirect_half_ext #(
   parameter FF_SYNC_DEPTH = 2
  )
  (
   input  wire           resetn_ext,
   input  wire           clk_ext,
   input  wire   [7:0]   ext_rx_data,
   input  wire           ext_rx_valid,
   output wire           ext_rx_ready,
   output wire           ext_rx_linkup,
   input  wire           ext_rx_linkest,
   output wire   [7:0]   ext_async_ei_data,
   output wire           ext_async_ei_req,
   input  wire           ext_async_ei_ack,
   input  wire           ext_async_ei_linkup,
   output wire           ext_async_ei_linkest,
   input  wire   [7:0]   ext_async_ie_data,
   input  wire           ext_async_ie_req,
   output wire           ext_async_ie_ack,
   output wire           ext_async_ie_linkup,
   input  wire           ext_async_ie_linkest,
   output wire   [7:0]   ext_tx_data,
   output wire           ext_tx_valid,
   input  wire           ext_tx_ready,
   input  wire           ext_tx_linkup,
   output wire           ext_tx_linkest,
   input  wire           ext_clk_qreq_n,
   output wire           ext_clk_qaccept_n,
   output wire           ext_clk_qdeny,
   output wire           ext_clk_qactive,
   input  wire           ext_pwr_qreq_n,
   output wire           ext_pwr_qaccept_n,
   output wire           ext_pwr_qdeny,
   output wire           ext_pwr_qactive,
   output wire           ext_pwr_wake
);


sdc600_comasyncbridge_indirect_half # (
   .FF_SYNC_DEPTH     (FF_SYNC_DEPTH),
   .EXT_DOMAIN        (1))
  u_sdc600_comasyncbridge_indirect_half (
   .reset_n           (resetn_ext           ),
   .clk               (clk_ext              ),
   .rx_data           (ext_rx_data          ),
   .rx_valid          (ext_rx_valid         ),
   .rx_ready          (ext_rx_ready         ),
   .rx_linkup         (ext_rx_linkup        ),
   .rx_linkest        (ext_rx_linkest       ),
   .async_tx_data     (ext_async_ei_data    ),
   .async_tx_req      (ext_async_ei_req     ),
   .async_tx_ack      (ext_async_ei_ack     ),
   .async_tx_linkup   (ext_async_ei_linkup  ),
   .async_tx_linkest  (ext_async_ei_linkest ),
   .async_rx_data     (ext_async_ie_data    ),
   .async_rx_req      (ext_async_ie_req     ),
   .async_rx_ack      (ext_async_ie_ack     ),
   .async_rx_linkup   (ext_async_ie_linkup  ),
   .async_rx_linkest  (ext_async_ie_linkest ),
   .tx_data           (ext_tx_data          ),
   .tx_valid          (ext_tx_valid         ),
   .tx_ready          (ext_tx_ready         ),
   .tx_linkup         (ext_tx_linkup        ),
   .tx_linkest        (ext_tx_linkest       ),
   .clk_qreq_n        (ext_clk_qreq_n       ),
   .clk_qaccept_n     (ext_clk_qaccept_n    ),
   .clk_qdeny         (ext_clk_qdeny        ),
   .clk_qactive       (ext_clk_qactive      ),
   .pwr_qreq_n        (ext_pwr_qreq_n       ),
   .pwr_qaccept_n     (ext_pwr_qaccept_n    ),
   .pwr_qdeny         (ext_pwr_qdeny        ),
   .pwr_qactive       (ext_pwr_qactive      ),
   .pwr_wake          (ext_pwr_wake         ));


endmodule


