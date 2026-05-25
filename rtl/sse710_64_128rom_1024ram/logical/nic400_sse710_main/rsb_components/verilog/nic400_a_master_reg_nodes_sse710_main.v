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




 `include "reg_slice_axi_defs.v"

module nic400_a_master_reg_nodes_sse710_main
 (
  
    rsb_data_m_async,
    rsb_wptr_b_async,
    rsb_rptr_b_async,
    rsb_rptr_b_bin,

    rsb_data_s_async,
    rsb_wptr_s_async,
    rsb_rptr_s_async,
    rsb_rptr_s_bin,


    aid_gpv_0,
    aaddr_gpv_0,
    alen_gpv_0,
    asize_gpv_0,
    aburst_gpv_0,
    alock_gpv_0,
    acache_gpv_0,
    aprot_gpv_0,
    avalid_gpv_0,
    aready_gpv_0,
    awrite_gpv_0,

    wdata_gpv_0,
    wstrb_gpv_0,
    wlast_gpv_0,
    wvalid_gpv_0,
    wready_gpv_0,

    did_gpv_0,
    ddata_gpv_0,
    dresp_gpv_0,
    dlast_gpv_0,
    dbnr_gpv_0,
    dvalid_gpv_0,
    dready_gpv_0,

    rclk,
    rresetn

 );


  `include "nic400_closure_sse710_main_defs.v"

  

  output  [7:0]       rsb_data_m_async;      
  output  [2:0]       rsb_wptr_b_async;      
  input   [2:0]       rsb_rptr_b_async;      
  input   [1:0]       rsb_rptr_b_bin;        


  input   [7:0]       rsb_data_s_async;      
  input   [2:0]       rsb_wptr_s_async;      
  output  [2:0]       rsb_rptr_s_async;      
  output  [1:0]       rsb_rptr_s_bin;        



  input   [11:0]      aid_gpv_0;             
  input   [39:0]      aaddr_gpv_0;           
  input   [7:0]       alen_gpv_0;            
  input   [2:0]       asize_gpv_0;           
  input   [1:0]       aburst_gpv_0;          
  input               alock_gpv_0;           
  input   [3:0]       acache_gpv_0;          
  input   [2:0]       aprot_gpv_0;           
  input               avalid_gpv_0;          
  output              aready_gpv_0;          
  input               awrite_gpv_0;          

  input   [31:0]      wdata_gpv_0;           
  input   [3:0]       wstrb_gpv_0;           
  input               wlast_gpv_0;           
  input               wvalid_gpv_0;          
  output              wready_gpv_0;          

  output  [11:0]      did_gpv_0;             
  output  [31:0]      ddata_gpv_0;           
  output  [1:0]       dresp_gpv_0;           
  output              dlast_gpv_0;           
  output              dbnr_gpv_0;            
  output              dvalid_gpv_0;          
  input               dready_gpv_0;          

  input               rclk;                  
  input               rresetn;               



  wire [7:0]                            mdata;
  wire                                  mvalid;
  wire                                  mready;



  wire [7:0]                            i_rsb_data_m_gpv_0;
  wire                                  i_rsb_valid_m_gpv_0;
  wire                                  i_rsb_ready_m_gpv_0;
  wire [7:0]                            rsb_data_m_gpv_0;
  wire                                  rsb_valid_m_gpv_0;
  wire                                  rsb_ready_m_gpv_0;





`ifdef RSB_A_MASTER_S_SYNC
  assign mvalid = rsb_wptr_s_async[0];
  assign mdata = rsb_data_s_async;
  assign rsb_rptr_s_async[0] = mready;

  assign rsb_rptr_s_async[2:1] = 2'b00;
  assign rsb_rptr_s_bin = 2'b00;


`else
  
  `ifdef RSB_L4_ASYNC

  nic400_rsb_async4_m_sse710_main u_rsb_async4_m
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .dst_data                          (mdata),
     .dst_valid                         (mvalid),
     .dst_ready                         (mready),
     .rpntr_gry_async                   (rsb_rptr_s_async),
     .wpntr_gry_async                   (rsb_wptr_s_async),
     .src_data                          (rsb_data_s_async),
     .rpntr_bin                         (rsb_rptr_s_bin)

    );

  `else

  nic400_rsb_async_m_sse710_main u_rsb_async_m
    (
     .mclk                              (rclk),
     .mresetn                           (rresetn),
     .mdata                             (mdata),
     .mvalid                            (mvalid),
     .mready                            (mready),
     .rd_ptr_g_async                    (rsb_rptr_s_async[0]),
     .wr_ptr_g_async                    (rsb_wptr_s_async[0]),
     .sreg_0_async                      (rsb_data_s_async)
    );

   assign rsb_rptr_s_async[2:1] = 2'b00;
   assign rsb_rptr_s_bin = 2'b00;

  `endif
`endif

nic400_rsb_master_gpv_0_sse710_main
    #(0,    
      12)        
  u_rsb_master_gpv_0
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_GPV_0_A_MASTER_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_GPV_0_A_MASTER_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_GPV_0_A_MASTER_SSE710_MAIN),
   
     .awrite                            (awrite_gpv_0),
     .aid                               (aid_gpv_0),
     .aaddr                             (aaddr_gpv_0[31:0]),
     .alen                              (alen_gpv_0),
     .asize                             (asize_gpv_0),
     .aburst                            (aburst_gpv_0),
     .alock                             (alock_gpv_0),
     .acache                            (acache_gpv_0),
     .aprot                             (aprot_gpv_0),
     .avalid                            (avalid_gpv_0),
     .aready                            (aready_gpv_0),
     .dbnr                              (dbnr_gpv_0),
     .did                               (did_gpv_0),
     .ddata                             (ddata_gpv_0),
     .dresp                             (dresp_gpv_0),
     .dlast                             (dlast_gpv_0),
     .dvalid                            (dvalid_gpv_0),
     .dready                            (dready_gpv_0),
   
     .wdata                             (wdata_gpv_0),
     .wstrb                             (wstrb_gpv_0),
     .wlast                             (wlast_gpv_0),
     .wvalid                            (wvalid_gpv_0),
     .wready                            (wready_gpv_0),
     .rsb_data_m                        (i_rsb_data_m_gpv_0),
     .rsb_valid_m                       (i_rsb_valid_m_gpv_0),
     .rsb_ready_m                       (i_rsb_ready_m_gpv_0));

  nic400_rsb_reg_slice_sse710_main
    #(`RS_REGD)
  u_rsb_master_reg_gpv_0
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_gpv_0),
     .rsb_valid_s                       (i_rsb_valid_m_gpv_0),
     .rsb_ready_s                       (i_rsb_ready_m_gpv_0),
     .rsb_data_m                        (rsb_data_m_gpv_0),
     .rsb_valid_m                       (rsb_valid_m_gpv_0),
     .rsb_ready_m                       (rsb_ready_m_gpv_0)
     );

`ifdef RSB_A_MASTER_M_SYNC

  assign rsb_wptr_b_async[0] = `RSB_VALID_S_LAST_A_MASTER_SSE710_MAIN;
  assign rsb_data_m_async = `RSB_DATA_S_LAST_A_MASTER_SSE710_MAIN;
  assign `RSB_READY_S_LAST_A_MASTER_SSE710_MAIN = rsb_rptr_b_async[0];

  assign rsb_wptr_b_async[2:1] = 2'b0;

  
`else

  `ifdef RSB_L4_ASYNC

  nic400_rsb_async4_s_sse710_main #("a_master") u_rsb_async4_s
    (
     .wclk                              (rclk),
     .wresetn                           (rresetn),

     .src_data                          (`RSB_DATA_S_LAST_A_MASTER_SSE710_MAIN),
     .src_valid                         (`RSB_VALID_S_LAST_A_MASTER_SSE710_MAIN),
     .src_ready                         (`RSB_READY_S_LAST_A_MASTER_SSE710_MAIN),

     .rpntr_gry_async                   (rsb_rptr_b_async),
     .wpntr_gry_async                   (rsb_wptr_b_async),
     .dst_data                          (rsb_data_m_async),
     .rpntr_bin                         (rsb_rptr_b_bin)

    );

  `else

  nic400_rsb_async_s_sse710_main u_rsb_async_s
    (
     .sclk                              (rclk),
     .sresetn                           (rresetn),
     .sdata                             (`RSB_DATA_S_LAST_A_MASTER_SSE710_MAIN),
     .svalid                            (`RSB_VALID_S_LAST_A_MASTER_SSE710_MAIN),
     .sready                            (`RSB_READY_S_LAST_A_MASTER_SSE710_MAIN),
     .rd_ptr_g_async                    (rsb_rptr_b_async[0]),
     .wr_ptr_g_async                    (rsb_wptr_b_async[0]),
     .sreg_0_async                      (rsb_data_m_async)
    );

   assign rsb_wptr_b_async[2:1] = 2'b00;

  `endif
`endif

  `include "nic400_closure_sse710_main_undefs.v"

endmodule

`include "reg_slice_axi_undefs.v"


