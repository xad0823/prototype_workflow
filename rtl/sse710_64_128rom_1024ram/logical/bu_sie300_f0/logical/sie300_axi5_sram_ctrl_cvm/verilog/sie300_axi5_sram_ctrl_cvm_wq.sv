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
//      Checked In          : Tue Jul 16 16:12:54 2019 +0100
//
//      Revision            : 3fd92913
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_wq
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           wvalid,
  output      logic                                           wready,
  input  wire logic [64-1     :0]                             wdata,
  input  wire logic [8-1     :0]                              wstrb,
  input  wire logic                                           wlast,

  output      logic                                           wq_vld,
  input  wire logic                                           wq_rdy,
  output      logic [64-1     :0]                             wq_data,
  output      logic [8-1     :0]                              wq_strb,
  output      logic                                           wq_full,
  output      logic                                           wq_empty,


  input  wire logic [2-1  :0]                                 awq_cnt,
  output      logic [2-1  :0]                                 wlast_cnt,
  input  wire logic                                           awq_vld,
  input  wire logic                                           awq_rdy,
  input  wire logic                                           ext_stall

);
  typedef logic [2-1  :0]                     wcnt_t;


  typedef struct packed {
    logic [64-1:0]                    wdata;
    logic [8-1:0]                     wstrb;
    } wq_fields_t;

  localparam WQ_WIDTH = $bits(wq_fields_t);

  wq_fields_t wpayload_in, wq_payload_out;
  logic wready_fifo;
  logic wvalid_fifo;
  logic wq_ongoing;

  assign wpayload_in = {wdata, wstrb};

  sie300_axi5_sram_ctrl_cvm_fifo  #(
    .WIDTH          ( WQ_WIDTH              ),
    .DEPTH          ( 1    ),
    .RDY_AT_DEPTH_1 ( 1                     ),
    .CNT_WIDTH      ( 2 )
  ) u_fifo (
    .clk            ( clk                   ),
    .resetn         ( resetn                ),
    .ingress_data   ( wpayload_in           ),
    .ingress_vld    ( wvalid_fifo           ),
    .ingress_rdy    ( wready_fifo           ),
    .egress_data    ( wq_payload_out        ),
    .egress_vld     ( wq_vld                ),
    .egress_rdy     ( wq_rdy                ),
    .level          (                       ),
    .empty          ( wq_empty              ),
    .fall_thru_en   ( 1'b0                  ),
    .full           ( wq_full               ),
    .peek_data_vld  (                       ),
    .peek_data      (                       )
  );

  assign {wq_data, wq_strb} = wq_payload_out;

  logic incr_cnt;
  logic decr_cnt;
  logic [2-1:0] wlast_cnt_nxt;

  assign incr_cnt   = wlast & wvalid & wready;

  assign decr_cnt   = awq_vld & awq_rdy;

  always_comb begin
    wlast_cnt_nxt = wlast_cnt;
    if (decr_cnt & incr_cnt) begin
      wlast_cnt_nxt = wlast_cnt;
    end
    else if (decr_cnt) begin
      if (wlast_cnt != wcnt_t'(0) ) begin
        wlast_cnt_nxt = wcnt_t'(wlast_cnt - wcnt_t'(1));
      end
    end
    else if (incr_cnt) begin
      wlast_cnt_nxt = wcnt_t'(wlast_cnt + wcnt_t'(1));
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      wlast_cnt       <= '0;
    end
    else begin
      wlast_cnt       <= wlast_cnt_nxt;
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      wq_ongoing <= 1'b0;
    end
    else if (wvalid & wready) begin
      if (~wlast) begin
        wq_ongoing <= 1'b1;
      end
      else begin
        wq_ongoing <= 1'b0;
      end
    end
  end

  assign wready         = ext_stall
                        ? wready_fifo & (wq_ongoing | (awq_cnt > wlast_cnt))
                        : wready_fifo;

  assign wvalid_fifo    = ext_stall
                        ? wvalid & (wq_ongoing | (awq_cnt > wlast_cnt))
                        : wvalid;

endmodule

