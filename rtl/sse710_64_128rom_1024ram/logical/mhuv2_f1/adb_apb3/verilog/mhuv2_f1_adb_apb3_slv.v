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

module mhuv2_f1_adb_apb3_slv
(
  input wire                  pclk,
  input wire                  presetn,

  input wire                  dftcgen,

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
  input wire [32:0]           apb_async_resp_payload_i,
  input wire                  apb_async_ack_i,
  input wire                  recawake_async_i,

  output wire                 recawake_async_ss_o,
  output wire                 recawake_async_sss_o,
  output wire                 recawake_async_ssss_o,
  
  output wire                 clk_request_o,
  input wire                  en_clk_i,
  input wire                  pclks_clken_i

);


  wire                        pclk_gated;
  wire                        clken;

  wire                        apb_async_ack_ss;
  wire                        recawake_async_ss;
  reg                         recawake_async_sss;
  reg                         recawake_async_ssss;


  mhuv2_f1_adb_apb3_slv_core
  u_mhuv2_f1_adb_apb3_slv_core
  (
    .pclk                     (pclk_gated),
    .presetn                  (presetn),
    .psel_adb_i               (psel_adb_i),
    .penable_i                (penable_i),
    .paddr_i                  (paddr_i),
    .pwrite_i                 (pwrite_i),
    .pwdata_i                 (pwdata_i),
    .pstrb_i                  (pstrb_i),
    .prdata_o                 (prdata_o),
    .pready_o                 (pready_o),
    .pslverr_o                (pslverr_o),
    .apb_async_req_o          (apb_async_req_o),
    .apb_async_req_payload_o  (apb_async_req_payload_o),
    .apb_async_resp_payload_i (apb_async_resp_payload_i),
    .apb_async_ack_ss_i       (apb_async_ack_ss),
    .recawake_async_ss_i      (recawake_async_ss),
    .clken_o                  (clken),
    .pwakeup_i                (pwakeup_i),
    .clk_request_o            (clk_request_o),
    .en_clk_i                 (en_clk_i),
    .pclks_clken_i            (pclks_clken_i)
  );

      
  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      recawake_async_sss  <= 1'b0;
      recawake_async_ssss <= 1'b0;
    end
    else
    begin
      recawake_async_sss  <= recawake_async_ss;
      recawake_async_ssss <= recawake_async_sss;
    end
  end

  assign recawake_async_sss_o  = recawake_async_sss;
  assign recawake_async_ssss_o = recawake_async_ssss;


  mhuv2_f1_adb_cg
  u_mhuv2_f1_adb_cg
  (
    .clk_in (pclk),
    .enable (clken),
    .clk_out(pclk_gated),
    .dftcgen(dftcgen)
  );


  mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_apb_async_ack
  (
    .CLK    (pclk),
    .RESETn (presetn),
    .ASYNC  (apb_async_ack_i),
    .SYNC   (apb_async_ack_ss)
  );

  mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_recawake_async
  (
    .CLK    (pclk),
    .RESETn (presetn),
    .ASYNC  (recawake_async_i),
    .SYNC   (recawake_async_ss)
  );

  assign recawake_async_ss_o = recawake_async_ss;

endmodule
