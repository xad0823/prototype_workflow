//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2014-2018 Arm Limited or its affiliates.
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


module css600_apbasyncbridgeslv_core #(parameter
  PAYLOAD_WIDTH       = 48,
  WAKE_ON_TRANSACTION = 1'b1
)
(
  input  wire                      clk_s,
  input  wire                      reset_s_n,
  input  wire                      psel_i,
  input  wire [PAYLOAD_WIDTH-37:0] paddr_i,
  input  wire                      pwrite_i,
  input  wire [31:0]               pwdata_i,
  input  wire [2:0]                pprot_i,
  output wire [31:0]               prdata_o,
  output wire                      pready_o,
  output wire                      pslverr_o,
  input  wire                      clksqreqn_i,
  output wire                      clksqacceptn_o,
  output wire                      clksqdeny_o,
  input  wire                      pwrqreqn_i,
  output wire                      pwrqacceptn_o,
  output wire                      pwrqdeny_o,
  output wire                      pwrqactive_o,
  output wire                      apb_async_req_o,
  output wire [PAYLOAD_WIDTH-1:0]  apb_async_req_payload_o,
  input  wire [32:0]               apb_async_resp_payload_i,
  input  wire                      apb_async_ack_i,
  output wire                      clken_o
);


localparam IDLE      = 3'b000;
localparam REQ_REQ   = 3'b001;
localparam RESP_REQ  = 3'b010;
localparam RESP      = 3'b011;
localparam STALL     = 3'b100;
localparam SLVERR    = 3'b101;
localparam WAKE_RESP = WAKE_ON_TRANSACTION ? STALL : SLVERR;


  reg                      pready_r;
  reg                      pwrqactive_r;
  reg                      nxt_pready_r;
  reg                      nxt_pwrqactive_r;
  reg                      state_en;
  reg  [2:0]               state;
  reg  [2:0]               nxt_state;
  reg                      async_en;
  wire                     pslverr_r;
  wire [31:0]              prdata_r;
  reg                      apb_en;
  reg                      apb_async_req_r;
  reg                      nxt_apb_async_req_r;
  reg  [PAYLOAD_WIDTH-1:0] apb_async_req_payload_r;
  wire [PAYLOAD_WIDTH-1:0] nxt_apb_async_req_payload_r;
  wire                     en_clk;
  wire                     en_pwr;
  wire                     int_clken /* verilator clock_enable */;
  wire                     clks_clken;
  wire                     clks_lp_request;
  wire                     pwr_lp_request;


  always@(posedge clk_s or negedge reset_s_n)
  begin
    if(!reset_s_n)
    begin
      state           <= IDLE;
      pready_r        <= 1'b0;
      pwrqactive_r    <= 1'b0;
      apb_async_req_r <= 1'b0;
    end
    else if(state_en)
    begin
      state           <= nxt_state;
      pready_r        <= nxt_pready_r;
      pwrqactive_r    <= nxt_pwrqactive_r;
      apb_async_req_r <= nxt_apb_async_req_r;
    end
  end

  css600_cdc_capt_nosync #(.IH(32), .IL(0)) u_cdc_capt_nosync_resp_payload(
   .clk       (clk_s),
   .reset_n   (1'b1),
   .en        (apb_en),
   .d_async_i (apb_async_resp_payload_i),
   .q_sync_o  ({pslverr_r, prdata_r})
  );

  assign nxt_apb_async_req_payload_r = {paddr_i, pwrite_i, pwdata_i, pprot_i};

  always@(posedge clk_s)
  begin
    if(async_en)
    begin
      apb_async_req_payload_r <= nxt_apb_async_req_payload_r;
    end
  end

  always@*
  begin
    case(state)
    IDLE:
    begin
      nxt_state           = en_pwr ? REQ_REQ : WAKE_RESP;
      state_en            = psel_i & en_clk;
      nxt_pready_r        = ~en_pwr & ~WAKE_ON_TRANSACTION;
      nxt_pwrqactive_r    = en_pwr | WAKE_ON_TRANSACTION;
      nxt_apb_async_req_r = en_pwr;
      apb_en              = 1'b0;
      async_en            = psel_i & en_clk & en_pwr;
    end
    REQ_REQ:
    begin
      nxt_state           = RESP_REQ;
      state_en            = apb_async_ack_i;
      nxt_pready_r        = 1'b0;
      nxt_pwrqactive_r    = 1'b1;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    RESP_REQ:
    begin
      nxt_state           = RESP;
      state_en            = ~apb_async_ack_i;
      nxt_pready_r        = 1'b1;
      nxt_pwrqactive_r    = 1'b1;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = ~apb_async_ack_i;
      async_en            = 1'b0;
    end
    RESP:
    begin
      nxt_state           = IDLE;
      state_en            = 1'b1;
      nxt_pwrqactive_r    = 1'b0;
      nxt_pready_r        = 1'b0;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    STALL:
    begin
      nxt_state           = REQ_REQ;
      state_en            = en_pwr;
      nxt_pready_r        = 1'b0;
      nxt_pwrqactive_r    = 1'b1;
      nxt_apb_async_req_r = 1'b1;
      apb_en              = 1'b0;
      async_en            = en_pwr;
    end
    SLVERR:
    begin
      nxt_state           = IDLE;
      state_en            = 1'b1;
      nxt_pready_r        = 1'b0;
      nxt_pwrqactive_r    = 1'b0;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    default:
    begin
      nxt_state           = 3'bxxx;
      state_en            = 1'bx;
      nxt_pready_r        = 1'bx;
      nxt_pwrqactive_r    = 1'bx;
      nxt_apb_async_req_r = 1'bx;
      apb_en              = 1'bx;
      async_en            = 1'bx;
    end
    endcase
  end


  assign int_clken = psel_i | clks_clken;


  css600_lpislave u_lpislave_clks
  (
    .clk         (clk_s),
    .reset_n     (reset_s_n),
    .qreq_sync_n (clksqreqn_i),
    .qaccept_n   (clksqacceptn_o),
    .qdeny       (clksqdeny_o),
    .lp_request  (clks_lp_request),
    .dev_active  (psel_i),
    .lp_done     (clks_lp_request),
    .dev_run     (en_clk),
    .cg_en       (clks_clken)
  );


  css600_lpislave u_lpislave_pwr
  (
    .clk         (clk_s),
    .reset_n     (reset_s_n),
    .qreq_sync_n (pwrqreqn_i),
    .qaccept_n   (pwrqacceptn_o),
    .qdeny       (pwrqdeny_o),
    .lp_request  (pwr_lp_request),
    .dev_active  (psel_i),
    .lp_done     (pwr_lp_request),
    .dev_run     (en_pwr),
    .cg_en       ()
  );


  assign pready_o  = pready_r;
  assign prdata_o  = (state == SLVERR) ? 32'h00000000 : prdata_r;
  assign pslverr_o = pready_r & ((state == SLVERR) ? 1'b1 : pslverr_r);

  assign apb_async_req_o         = apb_async_req_r;
  assign apb_async_req_payload_o = apb_async_req_payload_r;

  assign pwrqactive_o = pwrqactive_r;

  assign clken_o = int_clken;


endmodule
