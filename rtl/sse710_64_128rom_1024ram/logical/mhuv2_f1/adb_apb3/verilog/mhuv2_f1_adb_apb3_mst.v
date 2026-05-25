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

module mhuv2_f1_adb_apb3_mst
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

  input wire                  pwakeup_i,
  input wire                  pwrrec_qrun_i,

  input wire                  apb_async_req_i,
  input wire  [48:0]          apb_async_req_payload_i,
  output wire [32:0]          apb_async_resp_payload_o,
  output wire                 apb_async_ack_o,
  output wire                 recawake_async_o,
  input wire                  recwakeup_async_i,
  output wire                 clk_request_o,
  input wire                  en_clk_i,
  input wire                  pclkm_clken_i,
  output wire                 pwr_request_o,
  output wire                 recwakeup_async_sss_o,
  input wire                  pwr_clken_i,

  input wire                  dftcgen
);


  wire                        pclk_gated;
  wire                        clken;

  wire                        apb_async_req_ss;

  wire                        recwakeup_async_ss;
  reg                         recwakeup_async_sss;
  wire                        pwr_clk_req;

  wire                        pwrrec_qrun;
  reg                         nxt_recawake_state;
  reg                         recawake_state_en;
  reg                         recawake_state;
  reg                         nxt_recawake_r;
  reg                         recawake_r;


  mhuv2_f1_adb_apb3_mst_core
  u_mhuv2_f1_adb_apb3_mst_core
  (
    .pclk                     (pclk_gated),
    .presetn                  (presetn),
    .psel_o                   (psel_o),
    .penable_o                (penable_o),
    .paddr_o                  (paddr_o),
    .pwrite_o                 (pwrite_o),
    .pwdata_o                 (pwdata_o),
    .pstrb_o                  (pstrb_o),
    .prdata_i                 (prdata_i),
    .pready_i                 (pready_i),
    .pslverr_i                (pslverr_i),
    .apb_async_req_ss_i       (apb_async_req_ss),
    .apb_async_req_payload_i  (apb_async_req_payload_i),
    .apb_async_resp_payload_o (apb_async_resp_payload_o),
    .apb_async_ack_o          (apb_async_ack_o),
    .recwakeup_async_ss_i     (recwakeup_async_ss),
    .pwr_request_o            (pwr_request_o),
    .pwrrec_qrun_i            (pwrrec_qrun),
    .pwr_clken_i              (pwr_clken_i),
    .clken_o                  (clken),
    .pwakeup_i                (pwakeup_i), 
    .clk_request_o            (clk_request_o),
    .en_clk_i                 (en_clk_i),
    .pclkm_clken_i            (pclkm_clken_i)

  );


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      recawake_state <= 1'b0;
      recawake_r <= 1'b0;
    end
    else if(recawake_state_en)
    begin
      recawake_state <= nxt_recawake_state;
      recawake_r <= nxt_recawake_r;
    end
  end

  always@*
  begin
    case(recawake_state)
    1'b0:
    begin
      nxt_recawake_state = 1'b1;
      recawake_state_en = (pwrrec_qrun & recwakeup_async_ss);
      nxt_recawake_r = 1'b1;
    end
    1'b1:
    begin
      nxt_recawake_state = 1'b0;
      recawake_state_en = ~pwrrec_qrun;
      nxt_recawake_r = 1'b0;
    end
    default:
    begin
      nxt_recawake_state = 1'bx;
      recawake_state_en = 1'bx;
      nxt_recawake_r = 1'bx;
    end
    endcase
  end

  assign recawake_async_o = recawake_r;

  assign pwrrec_qrun    = pwrrec_qrun_i;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
      recwakeup_async_sss <= 1'b0;
    else
      recwakeup_async_sss <= recwakeup_async_ss;
  end

  assign recwakeup_async_sss_o = recwakeup_async_sss;



  mhuv2_f1_adb_cg
  u_mhuv2_f1_adb_cg
  (
    .clk_in (pclk),
    .enable (clken),
    .clk_out(pclk_gated),
    .dftcgen(dftcgen)
  );


  mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_apb_async_req
  (
    .CLK    (pclk),
    .RESETn (presetn),
    .ASYNC  (apb_async_req_i),
    .SYNC  (apb_async_req_ss)
  );

  mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_recwakeup_async
  (
    .CLK    (pclk),
    .RESETn (presetn),
    .ASYNC  (recwakeup_async_i),
    .SYNC   (recwakeup_async_ss)
  );


endmodule
