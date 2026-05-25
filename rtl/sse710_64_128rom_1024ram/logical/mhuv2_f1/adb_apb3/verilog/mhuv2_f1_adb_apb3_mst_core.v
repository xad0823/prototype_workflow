//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module mhuv2_f1_adb_apb3_mst_core
(
  input wire                  pclk,
  input wire                  presetn,

  output wire                 psel_o,
  output wire                 penable_o,
  output wire [11:0]          paddr_o,
  output wire                 pwrite_o,
  output wire [31:0]          pwdata_o,
  output wire [3:0]           pstrb_o,
  input wire  [31:0]          prdata_i,
  input wire                  pready_i,
  input wire                  pslverr_i,

  input  wire                 pwakeup_i,

  input wire                  apb_async_req_ss_i,
  input wire  [48:0]          apb_async_req_payload_i,
  output wire [32:0]          apb_async_resp_payload_o,
  output wire                 apb_async_ack_o,
  input  wire                 recwakeup_async_ss_i,

  input wire                  pwrrec_qrun_i,
  output wire                 pwr_request_o,
  input wire                  pwr_clken_i,
  output wire                 clken_o,
  output wire                 clk_request_o,
  input wire                  en_clk_i,
  input wire                  pclkm_clken_i


);


localparam IDLE = 2'b00;
localparam REQ_ACK = 2'b01;
localparam RESP_WAIT = 2'b10;
localparam RESP_REQ_WAIT = 2'b11;


  reg [1:0]                   state;
  reg                         psel_r;
  reg                         penable_r;
  reg                         apb_async_ack_r;

  reg [1:0]                   nxt_state;
  reg                         nxt_psel_r;
  reg                         nxt_penable_r;
  reg                         nxt_apb_async_ack_r;

  reg                         state_en;

  wire [11:0]                 paddr_r;
  wire                        pwrite_r;
  wire [31:0]                 pwdata_r;
  wire [3:0]                  pstrb_r;

  reg                         apb_en;

  reg [32:0]                  apb_async_resp_payload_r;

  wire                        pwrrec_qrun;

  reg                         async_en;

  wire [32:0]                 nxt_apb_async_resp_payload_r;
  wire [32:0]                 nxt_apb_async_resp_payload_enabled; 

  wire                        clk_request;

  wire                        pwr_request;

  wire                        en_clk;

  wire                        int_clken;
  wire                        pclkm_clken;
  wire                        pwr_clken;


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      state[1:0]      <= IDLE;
      psel_r          <= 1'b0;
      penable_r       <= 1'b0;
      apb_async_ack_r <= 1'b0;
    end
    else if(state_en)
    begin
      state[1:0]      <= nxt_state[1:0];
      psel_r          <= nxt_psel_r;
      penable_r       <= nxt_penable_r;
      apb_async_ack_r <= nxt_apb_async_ack_r;
    end
  end

  mhuv2_f1_adb_cdc_capt_nosync
  #(
    .IH        (48),
    .IL        (0)
  )
  u_mhuv2_f1_adb_cdc_capt_nosync  (
    .clk          (pclk),
    .reset_n      (presetn),
    .en           (apb_en),
    .d_async_i    (apb_async_req_payload_i),
    .q_sync_o     ({paddr_r[11:0], pwrite_r, pwdata_r[31:0] ,pstrb_r[3:0]})
  );
  
  always@(posedge pclk)
  begin
    if (async_en) 
      apb_async_resp_payload_r[32:0] <= nxt_apb_async_resp_payload_enabled[32:0];
  end
  
  mhuv2_f1_adb_mux2 
  #(
    .WIDTH(33)
  ) 
  u_mhuv2_f1_adb_mux2_1 (
    .din1_async   (apb_async_resp_payload_r),
    .din2_async   (nxt_apb_async_resp_payload_r),
    .sel          (async_en),
    .dout_async   (nxt_apb_async_resp_payload_enabled)
  );

  assign nxt_apb_async_resp_payload_r[32:0] = {pslverr_i,prdata_i[31:0]};

  always@*
  begin
    case(state[1:0])
    IDLE:
    begin
      nxt_state[1:0]      = REQ_ACK;
      state_en            = apb_async_req_ss_i & en_clk_i & pwrrec_qrun; 
      nxt_psel_r          = 1'b1;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = 1'b1;
      apb_en              = apb_async_req_ss_i & en_clk_i & pwrrec_qrun;
      async_en            = 1'b0;
    end
    REQ_ACK:
    begin
      nxt_state[1:0]      = RESP_WAIT;
      state_en            = 1'b1;
      nxt_psel_r          = 1'b1;
      nxt_penable_r       = 1'b1;
      nxt_apb_async_ack_r = 1'b1;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    RESP_WAIT:
    begin
      nxt_state[1:0]      = (apb_async_req_ss_i)? RESP_REQ_WAIT:IDLE;
      state_en            = pready_i;
      nxt_psel_r          = 1'b0;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = apb_async_req_ss_i;
      apb_en              = 1'b0;
      async_en            = pready_i;
    end
    RESP_REQ_WAIT:
    begin
      nxt_state[1:0]      = IDLE;
      state_en            = ~apb_async_req_ss_i;
      nxt_psel_r          = 1'b0;
      nxt_penable_r       = 1'b0;
      nxt_apb_async_ack_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    default:
    begin
      nxt_state[1:0]      = 2'bxx;
      state_en            = 1'bx;
      nxt_psel_r          = 1'bx;
      nxt_penable_r       = 1'bx;
      nxt_apb_async_ack_r = 1'bx;
      apb_en              = 1'bx;
      async_en            = 1'bx;
    end
    endcase
  end


  assign int_clken = apb_async_req_ss_i | (state[1:0] != IDLE) | pclkm_clken_i | pwr_clken;

  assign clk_request_o = apb_async_req_ss_i | pwakeup_i | (state != IDLE) | pwr_clken;

  assign pwr_request_o = pwakeup_i | recwakeup_async_ss_i;


  assign psel_o         = psel_r;
  assign penable_o      = penable_r;
  assign paddr_o[11:0]  = paddr_r[11:0];
  assign pwrite_o       = pwrite_r;
  assign pwdata_o[31:0] = pwdata_r[31:0];
  assign pstrb_o[3:0]   = pstrb_r[3:0];

  assign apb_async_ack_o                = apb_async_ack_r;
  assign apb_async_resp_payload_o[32:0] = apb_async_resp_payload_r[32:0];
  assign pwrrec_qrun                    = pwrrec_qrun_i;
  assign pwr_clken                      = pwr_clken_i;
  assign clken_o = int_clken;

endmodule
