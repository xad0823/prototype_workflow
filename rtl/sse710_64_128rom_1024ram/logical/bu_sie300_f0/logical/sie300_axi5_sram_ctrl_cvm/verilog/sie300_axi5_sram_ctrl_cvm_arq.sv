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

module sie300_axi5_sram_ctrl_cvm_arq
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           arvalid,
  output      logic                                           arready,
  input  wire logic [12-1       :0]                           arid,
  input  wire logic [22-1     :0]                             araddr,
  input  wire logic [7                        :0]             arlen,
  input  wire logic [2                        :0]             arsize,
  input  wire logic [1                        :0]             arburst,
  input  wire logic [3                        :0]             arqos,
  input  wire logic                                           arprot,
  input  wire logic                                           arlock,

  input  wire logic                                           raw_match,
  output      logic                                           arq_last,
  input  wire logic                                           awq_empty,

  output      logic                                           arq_vld,
  input  wire logic                                           arq_rdy,
  output      logic [12-1       :0]                           arq_id,
  output      logic [22-1     :0]                             arq_addr,
  output      logic [7                        :0]             arq_len,
  output      logic [2                        :0]             arq_size,
  output      logic [1                        :0]             arq_burst,
  output      logic [3                        :0]             arq_qos,
  output      logic                                           arq_prot,
  output      logic                                           arq_lock,
  output      logic                                           arq_empty,

  input  wire logic                                           ext_stall

);


  typedef struct packed {
    logic [12-1  :0]                  id;
    logic [22-1:0]                    addr;
    logic [7                   :0]    len;
    logic [2                   :0]    size;
    logic [1                   :0]    burst;
    logic [3                   :0]    qos;
    logic                             prot;
    logic                             lock;
  } ax_fields_t;

  localparam AX_Q_WIDTH = $bits(ax_fields_t);
  localparam AR_BUF_SIZE_BITS = $clog2(2 + 1);

  typedef logic [AR_BUF_SIZE_BITS-1:0] cnt_t;

  ax_fields_t arpayload_in, arq_payload_out;
  logic arready_fifo;
  logic arvalid_fifo;
  cnt_t arq_level;

  assign arpayload_in = {arid, araddr, arlen, arsize, arburst, arqos, arprot, arlock};

  sie300_axi5_sram_ctrl_cvm_fifo  #(
    .WIDTH          ( AX_Q_WIDTH            ),
    .DEPTH          ( 2   ),
    .FT_AT_DEPTH_1  ( 1                     ),
    .CNT_WIDTH      ( AR_BUF_SIZE_BITS      )
  ) u_fifo (
    .clk            ( clk                   ),
    .resetn         ( resetn                ),
    .ingress_data   ( arpayload_in          ),
    .ingress_vld    ( arvalid_fifo          ),
    .ingress_rdy    ( arready_fifo          ),
    .egress_data    ( arq_payload_out       ),
    .egress_vld     ( arq_vld               ),
    .egress_rdy     ( arq_rdy               ),
    .level          ( arq_level             ),
    .empty          ( arq_empty             ),
    .full           (                       ),
    .fall_thru_en   ( awq_empty             ),
    .peek_data_vld  (                       ),
    .peek_data      (                       )
  );

  assign {arq_id, arq_addr, arq_len, arq_size, arq_burst, arq_qos, arq_prot, arq_lock} = arq_payload_out;

  assign arq_last = (arq_level <= cnt_t'(1));


  assign arready        = ext_stall
                        ? 1'b0
                        : arready_fifo & ~raw_match ;

  assign arvalid_fifo   = ext_stall
                        ? 1'b0
                        : arvalid & ~raw_match ;

endmodule
