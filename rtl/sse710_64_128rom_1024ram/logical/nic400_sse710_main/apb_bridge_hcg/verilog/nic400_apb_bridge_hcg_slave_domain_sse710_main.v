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



module nic400_apb_bridge_hcg_slave_domain_sse710_main
(

    paddrs,
    pwdatas,
    pwrites,
    pprots,
    pstrbs,
    penables,
    psels,
    prdatas,
    pslverrs,
    preadys,

    apbm_req_async,
    apbm_ack_async,
    apbm_fwd_data_async,
    apbm_rev_data_async,
    empty_apb_async,

    pclkens,
    pclks,
    presetsn

);


  input   [31:0]      paddrs;                        
  input   [31:0]      pwdatas;                       
  input               pwrites;                       
  input   [2:0]       pprots;                        
  input   [3:0]       pstrbs;                        
  input               penables;                      
  input               psels;                         
  output  [31:0]      prdatas;                       
  output              pslverrs;                      
  output              preadys;                       

  output              apbm_req_async;                
  input               apbm_ack_async;                
  output  [71:0]      apbm_fwd_data_async;           
  input   [32:0]      apbm_rev_data_async;           
  output              empty_apb_async;               

  input               pclkens;                       
  input               pclks;                         
  input               presetsn;                      




  wire              pending_req;
  reg               hs_req_q;
  wire              nxt_hs_req;
  wire              hs_req_en;
  reg               pready_q;
  wire              clk_ready_en;

  wire              pready_q_nxt;

  wire              apbm_ack_corrupt_async;
  wire              apbm_ack_sync;

  wire              apbm_req_sync;

  wire      [32:0]  apbm_rev_data_corrupt_async;
  wire      [32:0]  apbm_rev_data_sync;

  wire              clk_fwd_en;
  wire      [71:0]  apbm_fwd_data_sync;

  reg       [32:0]  apbm_rev_data_capt;



  assign pending_req = penables & psels;

  assign hs_req_en  = pclkens &
                    ((~hs_req_q & ~pready_q & pending_req) |
                     (hs_req_q & apbm_ack_sync));
  assign nxt_hs_req = ~hs_req_q & ~apbm_ack_sync & pending_req;

  always @ (posedge pclks or negedge presetsn)
    if (~presetsn)
      hs_req_q <= 1'b0;
    else if (hs_req_en)
      hs_req_q <= nxt_hs_req;


  assign clk_ready_en = pclkens & (apbm_ack_sync & hs_req_q | pready_q);

  assign pready_q_nxt = apbm_ack_sync & hs_req_q;

  always @ (posedge pclks or negedge presetsn)
    if (~presetsn)
      pready_q <= 1'b0;
    else if (clk_ready_en)
      pready_q <= pready_q_nxt;

  assign preadys = pready_q;


  nic400_cdc_corrupt_gry_sse710_main #(1) u_cdc_corrupt_ack
  (
      .clk       (pclks),
      .resetn    (presetsn),
      .sync      (1'b0),
      .d_async   (apbm_ack_async),
      .q_async   (apbm_ack_corrupt_async)
  );

  nic400_cdc_capt_sync_sse710_main #(1) u_cdc_sync_ack
  (
      .clk       (pclks),
      .resetn    (presetsn),
      .sync_en   (1'b1),
      .d_async   (apbm_ack_corrupt_async),
      .q         (apbm_ack_sync)
  );


  nic400_cdc_corrupt_sse710_main #(33) u_cdc_corrupt_rev_data
  (
      .clk       (pclks),
      .sync      (1'b0),
      .d         (apbm_rev_data_async),
      .q         (apbm_rev_data_corrupt_async)
  );

  nic400_cdc_capt_nosync_sse710_main #(33) u_cdc_nosync_rev_data
  (
      .valid     (apbm_ack_sync),
      .d_async   (apbm_rev_data_corrupt_async),
      .q         (apbm_rev_data_sync)
  );

  always @(posedge pclks)
    if(hs_req_q)
      begin
       apbm_rev_data_capt <= apbm_rev_data_sync;
      end

  assign {prdatas, pslverrs} = apbm_rev_data_capt;


  nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_req
  (
      .clk       (pclks),
      .resetn    (presetsn),
      .enable    (hs_req_en),
      .in_cdc    (apbm_req_sync),
      .out_async (apbm_req_async)
  );

  assign apbm_req_sync = nxt_hs_req;


  nic400_cdc_launch_data_sse710_main #(72) u_cdc_launch_fwd_data
  (
     .clk       (pclks),
     .resetn    (presetsn),
     .enable    (clk_fwd_en),
     .in_cdc    (apbm_fwd_data_sync),
     .out_async (apbm_fwd_data_async));

  assign clk_fwd_en = ~hs_req_q & ~pready_q & pending_req & pclkens;

  assign apbm_fwd_data_sync = {paddrs, pwdatas, pwrites, pprots, pstrbs};


   nic400_cdc_launch_gry_sse710_main #(1) u_cdc_launch_empty_apb_ptr_gry
   (
      .clk       (pclks),
      .resetn    (presetsn),
      .enable    (1'b1),
      .in_cdc    (pending_req),
      .out_async (empty_apb_async));
 


endmodule


