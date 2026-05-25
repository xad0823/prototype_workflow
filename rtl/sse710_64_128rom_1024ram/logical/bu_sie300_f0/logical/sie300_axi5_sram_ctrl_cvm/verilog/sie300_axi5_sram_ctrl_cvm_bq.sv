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

module sie300_axi5_sram_ctrl_cvm_bq
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           awvalid,
  input  wire logic                                           awready,
  input  wire logic [12-1       :0]                           awid,
  input  wire logic                                           awlock,

  input  wire logic                                           wvalid,
  input  wire logic                                           wready,
  input  wire logic                                           wlast,

  output      logic                                           bvalid,
  input  wire logic                                           bready,
  output      logic [12-1       :0]                           bid,
  output      logic [1                        :0]             bresp,

  input  wire logic                                           wbeat_chk_exok,
  input  wire logic                                           eam_exok,
  output      logic                                           bq_lock,
  output      logic                                           bq_exok_saved,
  output      logic                                           bq_exfail,
  output      logic                                           awready_bq,
  output      logic                                           bq_full,
  output      logic                                           bq_empty
);

  localparam EXOK = 2'b01;
  localparam OKAY = 2'b00;

  typedef struct packed {
    logic [12-1:0]        id;
    logic                           lock;
  } bq_fields_t;

  localparam BQ_WIDTH = $bits(bq_fields_t);

  typedef logic [2 : 0]                     cnt_t;

  bq_fields_t bpayload_in, bq_payload_out;
  logic bvalid_fifo;
  logic b_oe;
  cnt_t tr_cnt_aw;
  cnt_t tr_cnt_w;
  cnt_t tr_cnt_aw_next;
  cnt_t tr_cnt_w_next;
  logic bq_exok;
  logic wr_trn_done;
  logic bvalid_int;

  assign bpayload_in = {awid, awlock};

  sie300_axi5_sram_ctrl_cvm_fifo  #(
    .WIDTH          ( BQ_WIDTH              ),
    .DEPTH          ( 2   ),
    .RDY_AT_DEPTH_1 ( 1                     ),
    .FT_AT_DEPTH_1  ( 0                     ),
    .CNT_WIDTH      ( 2 )
  ) u_fifo (
    .clk            ( clk                   ),
    .resetn         ( resetn                ),
    .ingress_data   ( bpayload_in           ),
    .ingress_vld    ( awvalid & awready     ),
    .ingress_rdy    ( awready_bq            ),
    .egress_data    ( bq_payload_out        ),
    .egress_vld     ( bvalid_fifo           ),
    .egress_rdy     ( bready & bvalid       ),
    .level          (                       ),
    .empty          ( bq_empty              ),
    .full           ( bq_full               ),
    .fall_thru_en   ( 1'b1                  ),
    .peek_data_vld  (                       ),
    .peek_data      (                       )
  );


  always_comb begin
    case ({awvalid & awready, bvalid & bready})
      2'b00,
      2'b11  : tr_cnt_aw_next = tr_cnt_aw;
      2'b01  : tr_cnt_aw_next = tr_cnt_aw - cnt_t'(1);
      2'b10  : tr_cnt_aw_next = tr_cnt_aw + cnt_t'(1);
      default : tr_cnt_aw_next = 'x;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn)
    if(~resetn)
      tr_cnt_aw <= '0;
    else
      tr_cnt_aw <= tr_cnt_aw_next;

  always_comb begin
    case ({wvalid & wready & wlast, bvalid & bready})
      2'b00,
      2'b11  : tr_cnt_w_next = tr_cnt_w;
      2'b01  : tr_cnt_w_next = tr_cnt_w - cnt_t'(1);
      2'b10  : tr_cnt_w_next = tr_cnt_w + cnt_t'(1);
      default : tr_cnt_w_next = 'x;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn)
    if(~resetn)
      tr_cnt_w <= '0;
    else
      tr_cnt_w <= tr_cnt_w_next;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      bq_exok_saved <= 1'b0;
      bq_exok       <= 1'b0;
    end
    else if (wbeat_chk_exok) begin
      bq_exok_saved <= 1'b1;
      bq_exok       <= eam_exok;
    end
    else if (bvalid & bready & bq_payload_out.lock) begin
      bq_exok_saved <= 1'b0;
    end
  end

  assign wr_trn_done  = (  tr_cnt_aw_next > cnt_t'(0)                               )
                      & ( (tr_cnt_w_next  > cnt_t'(0) ) | (wlast & wvalid & wready) ) ;

  assign b_oe = (  ~bq_payload_out.lock
                | ( bq_payload_out.lock & bq_exok_saved ) );

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      bvalid_int <= 1'b0;
    end
    else if ((bvalid & bready) | ~bvalid) begin
      bvalid_int <= bvalid_fifo & wr_trn_done;
    end
  end

  assign bvalid = bvalid_int & b_oe;

  assign bid    = bq_payload_out.id;

  assign bresp  = bq_payload_out.lock & bq_exok_saved & bq_exok
                ? EXOK
                : OKAY;

  assign bq_exfail = bq_payload_out.lock & bq_exok_saved & ~bq_exok;

  assign bq_lock = bq_payload_out.lock & bvalid_fifo;

endmodule

