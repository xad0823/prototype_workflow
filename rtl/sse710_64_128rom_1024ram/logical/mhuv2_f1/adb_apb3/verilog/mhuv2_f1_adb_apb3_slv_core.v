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

module mhuv2_f1_adb_apb3_slv_core
(
  input wire                  pclk,
  input wire                  presetn,

  input wire                  psel_adb_i,
  input wire                  penable_i,
  input wire [11:0]           paddr_i,
  input wire                  pwrite_i,
  input wire [31:0]           pwdata_i,
  input wire [3:0]            pstrb_i,
  output wire [31:0]          prdata_o,
  output wire                 pready_o,
  output wire                 pslverr_o,

  input  wire                 pwakeup_i,

  output wire                 apb_async_req_o,
  output wire [48:0]          apb_async_req_payload_o,
  input wire  [32:0]          apb_async_resp_payload_i,
  input wire                  apb_async_ack_ss_i,
  input wire                  recawake_async_ss_i,

  output wire                 clken_o,
  output wire                 clk_request_o,
  input wire                  en_clk_i,
  input wire                  pclks_clken_i
);


  localparam IDLE     = 2'b00;
  localparam REQ_REQ  = 2'b01;
  localparam RESP_REQ = 2'b10;
  localparam RESP     = 2'b11;


  reg [1:0]                   state;
  reg                         pready_r;

  reg [1:0]                   nxt_state;
  reg                         nxt_pready_r;

  reg                         state_en;

  wire [31:0]                 prdata_r;
  wire                        pslverr_r;

  reg                         apb_en;

  reg                         apb_async_req_r;
  reg [48:0]                  apb_async_req_payload_r;

  reg                         nxt_apb_async_req_r;
  wire [48:0]                 nxt_apb_async_req_payload_r;
  wire [48:0]                 nxt_apb_async_req_payload_enabled;  

  reg                         async_en;

  wire                        clk_request;

  wire                        en_clk;

  wire                        int_clken;
  wire                        pclks_clken;


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      state[1:0]      <= IDLE;
      pready_r        <= 1'b0;
      apb_async_req_r <= 1'b0;
    end
    else if(state_en)
    begin
      state[1:0]      <= nxt_state[1:0];
      pready_r        <= nxt_pready_r;
      apb_async_req_r <= nxt_apb_async_req_r;
    end
  end

  mhuv2_f1_adb_cdc_capt_nosync
  #(
    .IH        (32),
    .IL        (0)
  )
  u_mhuv2_f1_adb_cdc_capt_nosync (
    .clk          (pclk),
    .reset_n      (presetn),
    .en           (apb_en),
    .d_async_i    (apb_async_resp_payload_i),
    .q_sync_o     ({pslverr_r, prdata_r[31:0]})
  );
  
  always@(posedge pclk)
  begin
    if (async_en) 
      apb_async_req_payload_r[48:0] <= nxt_apb_async_req_payload_enabled[48:0];
  end
  
  mhuv2_f1_adb_mux2 
  #(
    .WIDTH(49)
  ) 
  u_mhuv2_f1_adb_mux2_1 (
    .din1_async   (apb_async_req_payload_r),
    .din2_async   (nxt_apb_async_req_payload_r),
    .sel          (async_en),
    .dout_async   (nxt_apb_async_req_payload_enabled)
  );  

  assign nxt_apb_async_req_payload_r[48:0] = {paddr_i[11:0],
                                              pwrite_i,
                                              pwdata_i[31:0],
                                              pstrb_i[3:0]};

  always@*
  begin
    case(state[1:0])
    IDLE:
    begin
      nxt_state[1:0]      = apb_async_ack_ss_i ? IDLE : REQ_REQ;
      state_en            = psel_adb_i & en_clk_i;
      nxt_pready_r        = 1'b0;
      nxt_apb_async_req_r = ~apb_async_ack_ss_i;
      apb_en              = 1'b0;
      async_en            = psel_adb_i & en_clk_i;
    end
    REQ_REQ:
    begin
      nxt_state[1:0]      = (recawake_async_ss_i) ? RESP_REQ : IDLE;
      state_en            = apb_async_ack_ss_i | (~recawake_async_ss_i);
      nxt_pready_r        = 1'b0;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    RESP_REQ:
    begin
      nxt_state[1:0]      = RESP;
      state_en            = ~apb_async_ack_ss_i;
      nxt_pready_r        = 1'b1;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = ~apb_async_ack_ss_i;
      async_en            = 1'b0;
    end
    RESP:
    begin
      nxt_state[1:0]      = IDLE;
      state_en            = 1'b1;
      nxt_pready_r        = 1'b0;
      nxt_apb_async_req_r = 1'b0;
      apb_en              = 1'b0;
      async_en            = 1'b0;
    end
    default:
    begin
      nxt_state[1:0]      = 2'bxx;
      state_en            = 1'bx;
      nxt_pready_r        = 1'bx;
      nxt_apb_async_req_r = 1'bx;
      apb_en              = 1'bx;
      async_en            = 1'bx;
    end
    endcase
  end


  assign int_clken = psel_adb_i | (state[1:0] != IDLE) | pclks_clken_i;


  assign clk_request_o = pwakeup_i | (state[1:0] != IDLE);


  assign pready_o       = pready_r & penable_i;
  assign prdata_o[31:0] = prdata_r[31:0];
  assign pslverr_o      = pready_r & pslverr_r;

  assign apb_async_req_o               = apb_async_req_r;
  assign apb_async_req_payload_o[48:0] = apb_async_req_payload_r[48:0];

  assign clken_o = int_clken;

endmodule
