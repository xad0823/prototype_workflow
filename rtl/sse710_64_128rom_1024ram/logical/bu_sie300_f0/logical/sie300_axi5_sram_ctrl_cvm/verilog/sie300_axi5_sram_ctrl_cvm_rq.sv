//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Jul 12 18:41:24 2019 +0100
//
//      Revision            : 19d3ce6c
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_rq
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  output      logic                                           rvalid,
  input  wire logic                                           rready,
  output      logic [12-1       :0]                           rid,
  output      logic [64-1     :0]                             rdata,
  output      logic [1                        :0]             rresp,
  output      logic                                           rlast,
  output      logic [1-1     :0]                              rpoison,

  input  wire logic                                           rq_vld,
  input  wire logic [64-1     :0]                             rq_data,
  input  wire logic [12-1       :0]                           rq_id,
  input  wire logic [1                        :0]             rq_resp,
  input  wire logic                                           rq_last,
  output      logic                                           rq_empty
);

  typedef struct packed {
    logic [64-1:0]                    rdata;
    logic [12-1  :0]                  rid;
    logic [1                   :0]    rresp;
    logic                             rlast;
  } rq_fields_t;

  localparam RQ_WIDTH = $bits(rq_fields_t);

  rq_fields_t rq_payload_in, rpayload_out;


  assign rq_payload_in = {rq_data, rq_id, rq_resp, rq_last };

  sie300_axi5_sram_ctrl_cvm_fifo  #(
    .WIDTH          ( RQ_WIDTH              ),
    .DEPTH          ( 1                     ),
    .FT_AT_DEPTH_1  ( 1                     ),
    .CNT_WIDTH      ( 1                     )
  ) u_fifo (
    .clk            ( clk                   ),
    .resetn         ( resetn                ),
    .ingress_data   ( rq_payload_in         ),
    .ingress_vld    ( rq_vld                ),
    .ingress_rdy    (                       ),
    .egress_data    ( rpayload_out          ),
    .egress_vld     ( rvalid                ),
    .egress_rdy     ( rready                ),
    .level          (                       ),
    .empty          ( rq_empty              ),
    .full           (                       ),
    .fall_thru_en   ( 1'b1                  ),
    .peek_data_vld  (                       ),
    .peek_data      (                       )
  );


  assign {rdata, rid, rresp, rlast}           = rpayload_out;
  assign rpoison = 'b0;

endmodule

