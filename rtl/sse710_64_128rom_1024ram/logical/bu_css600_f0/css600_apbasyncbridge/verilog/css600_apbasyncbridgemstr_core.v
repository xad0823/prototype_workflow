//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2014-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_apbasyncbridge
//
//----------------------------------------------------------------------------


module css600_apbasyncbridgemstr_core #(parameter
  PAYLOAD_WIDTH = 48
)
(
  input  wire                      clk_m,
  input  wire                      reset_m_n,
  output wire                      psel_o,
  output wire                      penable_o,
  output wire [PAYLOAD_WIDTH-37:0] paddr_o,
  output wire                      pwrite_o,
  output wire [31:0]               pwdata_o,
  output wire [2:0]                pprot_o,
  input  wire [31:0]               prdata_i,
  input  wire                      pready_i,
  input  wire                      pslverr_i,
  output wire                      pwakeup_o,
  input  wire                      clkmqreqn_i,
  output wire                      clkmqacceptn_o,
  output wire                      clkmqdeny_o,
  input wire                       apb_async_req_i,
  input  wire [PAYLOAD_WIDTH-1:0]  apb_async_req_payload_i,
  output wire [32:0]               apb_async_resp_payload_o,
  output wire                      apb_async_ack_o,
  output wire                      clken_o
);

localparam IDLE          = 2'b00;
localparam REQ_ACK       = 2'b01;
localparam RESP_WAIT     = 2'b10;
localparam RESP_REQ_WAIT = 2'b11;


  reg         psel_r;
  reg         penable_r;
  reg         apb_async_ack_r;
  reg         nxt_psel_r;
  reg         nxt_penable_r;
  reg         nxt_apb_async_ack_r;
  reg         state_en;
  reg  [1:0]  state;
  reg  [1:0]  nxt_state;
  wire        pwrite_r;
  wire [2:0]  pprot_r;
  wire [PAYLOAD_WIDTH-37:0] paddr_r;
  wire [31:0] pwdata_r;
  reg         apb_en;
  reg  [32:0] apb_async_resp_payload_r;
  reg                          async_en;
  wire [32:0] nxt_apb_async_resp_payload_r;
  wire        clk_request;
  wire        en_clk;
  wire        int_clken;
  wire        clkm_clken;
  wire                     clkm_lp_request;


  always@(posedge clk_m or negedge reset_m_n)
  begin
    if(!reset_m_n)
    begin
      state           <= IDLE;
      psel_r          <= 1'b0;
      penable_r       <= 1'b0;
      apb_async_ack_r <= 1'b0;
    end
    else if(state_en)
    begin
      state           <= nxt_state[1:0];
      psel_r          <= nxt_psel_r;
      penable_r       <= nxt_penable_r;
      apb_async_ack_r <= nxt_apb_async_ack_r;
    end
  end

  css600_cdc_capt_nosync #(.IH(PAYLOAD_WIDTH-1),.IL(0)) u_cdc_capt_nosync_req_payload(
   .clk       (clk_m),
   .reset_n   (1'b1),
   .en        (apb_en),
   .d_async_i (apb_async_req_payload_i),
   .q_sync_o  ({paddr_r, pwrite_r, pwdata_r, pprot_r})
  );

  assign nxt_apb_async_resp_payload_r = {pslverr_i, prdata_i};

  always@(posedge clk_m)
  begin
    if(async_en)
    begin
      apb_async_resp_payload_r <= nxt_apb_async_resp_payload_r;
    end
  end

  always@*
  begin
    case(state)
    IDLE:
    begin
      nxt_state           = REQ_ACK;
      state_en            = apb_async_req_i & en_clk;
      nxt_psel_r          = 1'b1;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = 1'b1;
      apb_en              = apb_async_req_i & en_clk;
      async_en            = 1'b0;
    end
    REQ_ACK:
    begin
      nxt_state           = RESP_WAIT;
      state_en            = 1'b1;
      nxt_psel_r          = 1'b1;
      nxt_penable_r       = 1'b1;
      nxt_apb_async_ack_r = 1'b1;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    RESP_WAIT:
    begin
      nxt_state           = (apb_async_req_i)? RESP_REQ_WAIT:IDLE;
      state_en            = pready_i;
      nxt_psel_r          = 1'b0;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = apb_async_req_i;
      apb_en              = 1'b0;
      async_en            = pready_i;
    end
    RESP_REQ_WAIT:
    begin
      nxt_state           = IDLE;
      state_en            = ~apb_async_req_i;
      nxt_psel_r          = 1'b0;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    default:
    begin
      nxt_state           = 2'bxx;
      state_en            = 1'bx;
      nxt_psel_r          = 1'bx;
      nxt_penable_r       = 1'bx;
      nxt_apb_async_ack_r = 1'bx;
      apb_en              = 1'bx;
      async_en            = 1'bx;
    end
    endcase
  end


  assign int_clken = apb_async_req_i | (state != IDLE) | clkm_clken;


  assign clk_request = apb_async_req_i | (state != IDLE);

  css600_lpislave u_lpislave_clkm
  (
    .clk         (clk_m),
    .reset_n     (reset_m_n),
    .qreq_sync_n (clkmqreqn_i),
    .qaccept_n   (clkmqacceptn_o),
    .qdeny       (clkmqdeny_o),
    .lp_request  (clkm_lp_request),
    .dev_active  (clk_request),
    .lp_done     (clkm_lp_request),
    .dev_run     (en_clk),
    .cg_en       (clkm_clken)
  );


  assign psel_o    = psel_r;
  assign penable_o = penable_r;
  assign paddr_o   = paddr_r;
  assign pwrite_o  = pwrite_r;
  assign pwdata_o  = pwdata_r;
  assign pprot_o   = pprot_r;
  assign pwakeup_o = psel_r;

  assign apb_async_ack_o          = apb_async_ack_r;
  assign apb_async_resp_payload_o = apb_async_resp_payload_r;

  assign clken_o = int_clken;


endmodule

