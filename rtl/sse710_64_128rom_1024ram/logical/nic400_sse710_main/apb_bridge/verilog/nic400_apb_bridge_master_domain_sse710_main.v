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



  `define    APBAS_ST_IDLE         2'b00
  `define    APBAS_ST_SETUP        2'b01
  `define    APBAS_ST_ACCESS       2'b10
  `define    APBAS_ST_ACK          2'b11


module nic400_apb_bridge_master_domain_sse710_main
(

    paddrm,
    pwdatam,
    pwritem,
    pprotm,
    pstrbm,
    penablem,
    pselm,
    prdatam,
    pslverrm,
    preadym,

    apbs_req_async,
    apbs_ack_async,
    apbs_fwd_data_async,
    apbs_rev_data_async,

    pclkenm,
    pclkm,
    presetmn

);


  output  [31:0]      paddrm;                   
  output  [31:0]      pwdatam;                  
  output              pwritem;                  
  output  [2:0]       pprotm;                   
  output  [3:0]       pstrbm;                   
  output              penablem;                 
  output              pselm;                    
  input   [31:0]      prdatam;                  
  input               pslverrm;                 
  input               preadym;                  

  input               apbs_req_async;           
  output              apbs_ack_async;           
  input   [71:0]      apbs_fwd_data_async;      
  output  [32:0]      apbs_rev_data_async;      

  input               pclkenm;                  
  input               pclkm;                    
  input               presetmn;                 



  reg        [1:0]  current_state_q;
  reg        [1:0]  next_state;
  wire              clk_en;
  reg               psel_q;
  
  wire              psel_q_nxt;

  wire              apbs_req_corrupt_async;
  wire              apbs_req_sync;

  wire              capt_en;

  wire      [71:0]  apbs_fwd_data_corrupt_async;
  wire      [71:0]  apbs_fwd_data_sync;

  wire              apbs_ack_sync;

  wire              clk_rev_en;
  wire      [32:0]  apbs_rev_data_sync;


  assign clk_en = pclkenm & 
                  ((apbs_req_sync | (current_state_q == `APBAS_ST_ACK)));

  always @ (posedge pclkm or negedge presetmn)
    if (~presetmn)
      current_state_q <= `APBAS_ST_IDLE;
    else if (clk_en)
      current_state_q <= next_state;

  always @(current_state_q or apbs_req_sync or preadym)
  begin
    case (current_state_q)
      `APBAS_ST_IDLE:
        next_state = apbs_req_sync ? `APBAS_ST_SETUP : `APBAS_ST_IDLE;
      `APBAS_ST_SETUP:
        next_state = `APBAS_ST_ACCESS;
      `APBAS_ST_ACCESS:
        next_state = preadym ? `APBAS_ST_ACK : `APBAS_ST_ACCESS;
      `APBAS_ST_ACK:
        next_state = ~apbs_req_sync ? `APBAS_ST_IDLE : `APBAS_ST_ACK;
    endcase
  end

  assign penablem = (current_state_q == `APBAS_ST_ACCESS);
  
  assign psel_q_nxt = apbs_req_sync & (current_state_q == `APBAS_ST_IDLE) | 
                     (current_state_q == `APBAS_ST_SETUP) | 
                     ~preadym & (current_state_q == `APBAS_ST_ACCESS);

  always @ (posedge pclkm or negedge presetmn)
    if (~presetmn)
      psel_q <= 1'b0;
    else if (clk_en)
      psel_q <= psel_q_nxt;

  assign pselm = psel_q;




  nic400_cdc_corrupt_gry_sse710_main #(1) u_cdc_corrupt_req
  (
      .clk       (pclkm), 
      .resetn    (presetmn), 
      .sync      (1'b0),
      .d_async   (apbs_req_async),
      .q_async   (apbs_req_corrupt_async)
  );

  nic400_cdc_capt_sync_sse710_main #(1) u_cdc_sync_req
  (
      .clk       (pclkm),
      .resetn    (presetmn),
      .sync_en   (1'b1),
      .d_async   (apbs_req_corrupt_async),
      .q         (apbs_req_sync)
  );


  nic400_cdc_corrupt_sse710_main #(72) u_cdc_corrupt_fwd_data
  (
      .clk       (pclkm), 
      .sync      (1'b0),
      .d         (apbs_fwd_data_async),
      .q         (apbs_fwd_data_corrupt_async)
  );

  nic400_cdc_capt_nosync_sse710_main #(72) u_cdc_nosync_rev_data
  (
      .valid     (capt_en),
      .d_async   (apbs_fwd_data_corrupt_async),
      .q         (apbs_fwd_data_sync)
  );


  assign capt_en = apbs_req_sync & (~apbs_ack_sync);

  assign {paddrm, pwdatam, pwritem, pprotm, pstrbm} = apbs_fwd_data_sync;


  nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_ack
  (
      .clk       (pclkm),
      .resetn    (presetmn),
      .enable    (1'b1),
      .in_cdc    (apbs_ack_sync),
      .out_async (apbs_ack_async)
  );

  assign apbs_ack_sync = (current_state_q == `APBAS_ST_ACK);


  nic400_cdc_launch_data_sse710_main #(33) u_cdc_launch_rev_data
  (
     .clk       (pclkm),
     .resetn    (presetmn),
     .enable    (clk_rev_en),
     .in_cdc    (apbs_rev_data_sync),
     .out_async (apbs_rev_data_async));

  assign clk_rev_en = pclkenm & (current_state_q == `APBAS_ST_ACCESS) & preadym;

  assign apbs_rev_data_sync = {prdatam, pslverrm};

 

endmodule


  `undef     APBAS_ST_IDLE
  `undef     APBAS_ST_SETUP
  `undef     APBAS_ST_ACCESS
  `undef     APBAS_ST_ACK

