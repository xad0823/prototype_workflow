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

module nic400_a_slave_reg_nodes_sse710_main
 (
  
    rsb_data_m_async,
    rsb_wptr_b_async,
    rsb_rptr_b_async,
    rsb_rptr_b_bin,

    rsb_data_s_async,
    rsb_wptr_s_async,
    rsb_rptr_s_async,
    rsb_rptr_s_bin,

    paddr_debug_axis_ib,
    pwdata_debug_axis_ib,
    pwrite_debug_axis_ib,
    penable_debug_axis_ib,
    psel_debug_axis_ib,
    prdata_debug_axis_ib,
    pslverr_debug_axis_ib,
    pready_debug_axis_ib,

    paddr_extsys0_axis_ib,
    pwdata_extsys0_axis_ib,
    pwrite_extsys0_axis_ib,
    penable_extsys0_axis_ib,
    psel_extsys0_axis_ib,
    prdata_extsys0_axis_ib,
    pslverr_extsys0_axis_ib,
    pready_extsys0_axis_ib,

    paddr_extsys1_axis_ib,
    pwdata_extsys1_axis_ib,
    pwrite_extsys1_axis_ib,
    penable_extsys1_axis_ib,
    psel_extsys1_axis_ib,
    prdata_extsys1_axis_ib,
    pslverr_extsys1_axis_ib,
    pready_extsys1_axis_ib,

    paddr_secenc_axis_ib,
    pwdata_secenc_axis_ib,
    pwrite_secenc_axis_ib,
    penable_secenc_axis_ib,
    psel_secenc_axis_ib,
    prdata_secenc_axis_ib,
    pslverr_secenc_axis_ib,
    pready_secenc_axis_ib,

    paddr_hostcpu_axis_ib,
    pwdata_hostcpu_axis_ib,
    pwrite_hostcpu_axis_ib,
    penable_hostcpu_axis_ib,
    psel_hostcpu_axis_ib,
    prdata_hostcpu_axis_ib,
    pslverr_hostcpu_axis_ib,
    pready_hostcpu_axis_ib,

    paddr_regs,
    pwdata_regs,
    pwrite_regs,
    penable_regs,
    psel_regs,
    prdata_regs,
    pslverr_regs,
    pready_regs,

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

  output  [31:0]      paddr_debug_axis_ib;          
  output  [31:0]      pwdata_debug_axis_ib;         
  output              pwrite_debug_axis_ib;         
  output              penable_debug_axis_ib;        
  output              psel_debug_axis_ib;           
  input   [31:0]      prdata_debug_axis_ib;         
  input               pslverr_debug_axis_ib;        
  input               pready_debug_axis_ib;         

  output  [31:0]      paddr_extsys0_axis_ib;        
  output  [31:0]      pwdata_extsys0_axis_ib;       
  output              pwrite_extsys0_axis_ib;       
  output              penable_extsys0_axis_ib;      
  output              psel_extsys0_axis_ib;         
  input   [31:0]      prdata_extsys0_axis_ib;       
  input               pslverr_extsys0_axis_ib;      
  input               pready_extsys0_axis_ib;       

  output  [31:0]      paddr_extsys1_axis_ib;        
  output  [31:0]      pwdata_extsys1_axis_ib;       
  output              pwrite_extsys1_axis_ib;       
  output              penable_extsys1_axis_ib;      
  output              psel_extsys1_axis_ib;         
  input   [31:0]      prdata_extsys1_axis_ib;       
  input               pslverr_extsys1_axis_ib;      
  input               pready_extsys1_axis_ib;       

  output  [31:0]      paddr_secenc_axis_ib;         
  output  [31:0]      pwdata_secenc_axis_ib;        
  output              pwrite_secenc_axis_ib;        
  output              penable_secenc_axis_ib;       
  output              psel_secenc_axis_ib;          
  input   [31:0]      prdata_secenc_axis_ib;        
  input               pslverr_secenc_axis_ib;       
  input               pready_secenc_axis_ib;        

  output  [31:0]      paddr_hostcpu_axis_ib;        
  output  [31:0]      pwdata_hostcpu_axis_ib;       
  output              pwrite_hostcpu_axis_ib;       
  output              penable_hostcpu_axis_ib;      
  output              psel_hostcpu_axis_ib;         
  input   [31:0]      prdata_hostcpu_axis_ib;       
  input               pslverr_hostcpu_axis_ib;      
  input               pready_hostcpu_axis_ib;       

  output  [31:0]      paddr_regs;                   
  output  [31:0]      pwdata_regs;                  
  output              pwrite_regs;                  
  output              penable_regs;                 
  output              psel_regs;                    
  input   [31:0]      prdata_regs;                  
  input               pslverr_regs;                 
  input               pready_regs;                  

  input               rclk;                         
  input               rresetn;                      



  wire [7:0]                            mdata;
  wire                                  mvalid;
  wire                                  mready;


  wire [7:0]                            i_rsb_data_m_debug_axis_ib;
  wire                                  i_rsb_valid_m_debug_axis_ib;
  wire                                  i_rsb_ready_m_debug_axis_ib;
  wire [7:0]                            rsb_data_m_debug_axis_ib;
  wire                                  rsb_valid_m_debug_axis_ib;
  wire                                  rsb_ready_m_debug_axis_ib;


  wire [7:0]                            i_rsb_data_m_extsys0_axis_ib;
  wire                                  i_rsb_valid_m_extsys0_axis_ib;
  wire                                  i_rsb_ready_m_extsys0_axis_ib;
  wire [7:0]                            rsb_data_m_extsys0_axis_ib;
  wire                                  rsb_valid_m_extsys0_axis_ib;
  wire                                  rsb_ready_m_extsys0_axis_ib;


  wire [7:0]                            i_rsb_data_m_extsys1_axis_ib;
  wire                                  i_rsb_valid_m_extsys1_axis_ib;
  wire                                  i_rsb_ready_m_extsys1_axis_ib;
  wire [7:0]                            rsb_data_m_extsys1_axis_ib;
  wire                                  rsb_valid_m_extsys1_axis_ib;
  wire                                  rsb_ready_m_extsys1_axis_ib;


  wire [7:0]                            i_rsb_data_m_secenc_axis_ib;
  wire                                  i_rsb_valid_m_secenc_axis_ib;
  wire                                  i_rsb_ready_m_secenc_axis_ib;
  wire [7:0]                            rsb_data_m_secenc_axis_ib;
  wire                                  rsb_valid_m_secenc_axis_ib;
  wire                                  rsb_ready_m_secenc_axis_ib;


  wire [7:0]                            i_rsb_data_m_hostcpu_axis_ib;
  wire                                  i_rsb_valid_m_hostcpu_axis_ib;
  wire                                  i_rsb_ready_m_hostcpu_axis_ib;
  wire [7:0]                            rsb_data_m_hostcpu_axis_ib;
  wire                                  rsb_valid_m_hostcpu_axis_ib;
  wire                                  rsb_ready_m_hostcpu_axis_ib;


  wire [7:0]                            i_rsb_data_m_regs;
  wire                                  i_rsb_valid_m_regs;
  wire                                  i_rsb_ready_m_regs;
  wire [7:0]                            rsb_data_m_regs;
  wire                                  rsb_valid_m_regs;
  wire                                  rsb_ready_m_regs;





`ifdef RSB_A_SLAVE_S_SYNC
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





  nic400_rsb_slave_sse710_main #(66, 1)
  u_rsb_slave_debug_axis_ib
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_DEBUG_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_debug_axis_ib),
     .penable                           (penable_debug_axis_ib),
     .pwrite                            (pwrite_debug_axis_ib),
     .paddr                             (paddr_debug_axis_ib),
     .pwdata                            (pwdata_debug_axis_ib),
     .prdata                            (prdata_debug_axis_ib),
     .pready                            (pready_debug_axis_ib),
     .pslverr                           (pslverr_debug_axis_ib),
     .rsb_data_m                        (i_rsb_data_m_debug_axis_ib),
     .rsb_valid_m                       (i_rsb_valid_m_debug_axis_ib),
     .rsb_ready_m                       (i_rsb_ready_m_debug_axis_ib));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_DEBUG_AXIS_IB_A_SLAVE)
  u_rsb_slave_reg_debug_axis_ib
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_debug_axis_ib),
     .rsb_valid_s                       (i_rsb_valid_m_debug_axis_ib),
     .rsb_ready_s                       (i_rsb_ready_m_debug_axis_ib),
     .rsb_data_m                        (rsb_data_m_debug_axis_ib),
     .rsb_valid_m                       (rsb_valid_m_debug_axis_ib),
     .rsb_ready_m                       (rsb_ready_m_debug_axis_ib)
     );




  nic400_rsb_slave_sse710_main #(67, 1)
  u_rsb_slave_extsys0_axis_ib
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_EXTSYS0_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_extsys0_axis_ib),
     .penable                           (penable_extsys0_axis_ib),
     .pwrite                            (pwrite_extsys0_axis_ib),
     .paddr                             (paddr_extsys0_axis_ib),
     .pwdata                            (pwdata_extsys0_axis_ib),
     .prdata                            (prdata_extsys0_axis_ib),
     .pready                            (pready_extsys0_axis_ib),
     .pslverr                           (pslverr_extsys0_axis_ib),
     .rsb_data_m                        (i_rsb_data_m_extsys0_axis_ib),
     .rsb_valid_m                       (i_rsb_valid_m_extsys0_axis_ib),
     .rsb_ready_m                       (i_rsb_ready_m_extsys0_axis_ib));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_EXTSYS0_AXIS_IB_A_SLAVE)
  u_rsb_slave_reg_extsys0_axis_ib
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_extsys0_axis_ib),
     .rsb_valid_s                       (i_rsb_valid_m_extsys0_axis_ib),
     .rsb_ready_s                       (i_rsb_ready_m_extsys0_axis_ib),
     .rsb_data_m                        (rsb_data_m_extsys0_axis_ib),
     .rsb_valid_m                       (rsb_valid_m_extsys0_axis_ib),
     .rsb_ready_m                       (rsb_ready_m_extsys0_axis_ib)
     );




  nic400_rsb_slave_sse710_main #(68, 1)
  u_rsb_slave_extsys1_axis_ib
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_EXTSYS1_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_extsys1_axis_ib),
     .penable                           (penable_extsys1_axis_ib),
     .pwrite                            (pwrite_extsys1_axis_ib),
     .paddr                             (paddr_extsys1_axis_ib),
     .pwdata                            (pwdata_extsys1_axis_ib),
     .prdata                            (prdata_extsys1_axis_ib),
     .pready                            (pready_extsys1_axis_ib),
     .pslverr                           (pslverr_extsys1_axis_ib),
     .rsb_data_m                        (i_rsb_data_m_extsys1_axis_ib),
     .rsb_valid_m                       (i_rsb_valid_m_extsys1_axis_ib),
     .rsb_ready_m                       (i_rsb_ready_m_extsys1_axis_ib));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_EXTSYS1_AXIS_IB_A_SLAVE)
  u_rsb_slave_reg_extsys1_axis_ib
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_extsys1_axis_ib),
     .rsb_valid_s                       (i_rsb_valid_m_extsys1_axis_ib),
     .rsb_ready_s                       (i_rsb_ready_m_extsys1_axis_ib),
     .rsb_data_m                        (rsb_data_m_extsys1_axis_ib),
     .rsb_valid_m                       (rsb_valid_m_extsys1_axis_ib),
     .rsb_ready_m                       (rsb_ready_m_extsys1_axis_ib)
     );




  nic400_rsb_slave_sse710_main #(69, 1)
  u_rsb_slave_secenc_axis_ib
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_SECENC_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_secenc_axis_ib),
     .penable                           (penable_secenc_axis_ib),
     .pwrite                            (pwrite_secenc_axis_ib),
     .paddr                             (paddr_secenc_axis_ib),
     .pwdata                            (pwdata_secenc_axis_ib),
     .prdata                            (prdata_secenc_axis_ib),
     .pready                            (pready_secenc_axis_ib),
     .pslverr                           (pslverr_secenc_axis_ib),
     .rsb_data_m                        (i_rsb_data_m_secenc_axis_ib),
     .rsb_valid_m                       (i_rsb_valid_m_secenc_axis_ib),
     .rsb_ready_m                       (i_rsb_ready_m_secenc_axis_ib));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_SECENC_AXIS_IB_A_SLAVE)
  u_rsb_slave_reg_secenc_axis_ib
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_secenc_axis_ib),
     .rsb_valid_s                       (i_rsb_valid_m_secenc_axis_ib),
     .rsb_ready_s                       (i_rsb_ready_m_secenc_axis_ib),
     .rsb_data_m                        (rsb_data_m_secenc_axis_ib),
     .rsb_valid_m                       (rsb_valid_m_secenc_axis_ib),
     .rsb_ready_m                       (rsb_ready_m_secenc_axis_ib)
     );




  nic400_rsb_slave_sse710_main #(70, 1)
  u_rsb_slave_hostcpu_axis_ib
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_HOSTCPU_AXIS_IB_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_hostcpu_axis_ib),
     .penable                           (penable_hostcpu_axis_ib),
     .pwrite                            (pwrite_hostcpu_axis_ib),
     .paddr                             (paddr_hostcpu_axis_ib),
     .pwdata                            (pwdata_hostcpu_axis_ib),
     .prdata                            (prdata_hostcpu_axis_ib),
     .pready                            (pready_hostcpu_axis_ib),
     .pslverr                           (pslverr_hostcpu_axis_ib),
     .rsb_data_m                        (i_rsb_data_m_hostcpu_axis_ib),
     .rsb_valid_m                       (i_rsb_valid_m_hostcpu_axis_ib),
     .rsb_ready_m                       (i_rsb_ready_m_hostcpu_axis_ib));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_HOSTCPU_AXIS_IB_A_SLAVE)
  u_rsb_slave_reg_hostcpu_axis_ib
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_hostcpu_axis_ib),
     .rsb_valid_s                       (i_rsb_valid_m_hostcpu_axis_ib),
     .rsb_ready_s                       (i_rsb_ready_m_hostcpu_axis_ib),
     .rsb_data_m                        (rsb_data_m_hostcpu_axis_ib),
     .rsb_valid_m                       (rsb_valid_m_hostcpu_axis_ib),
     .rsb_ready_m                       (rsb_ready_m_hostcpu_axis_ib)
     );




  nic400_rsb_slave_sse710_main #(1, 1)
  u_rsb_slave_regs
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (`RSB_DATA_S_REGS_A_SLAVE_SSE710_MAIN),
     .rsb_valid_s                       (`RSB_VALID_S_REGS_A_SLAVE_SSE710_MAIN),
     .rsb_ready_s                       (`RSB_READY_S_REGS_A_SLAVE_SSE710_MAIN),
     .psel                              (psel_regs),
     .penable                           (penable_regs),
     .pwrite                            (pwrite_regs),
     .paddr                             (paddr_regs),
     .pwdata                            (pwdata_regs),
     .prdata                            (prdata_regs),
     .pready                            (pready_regs),
     .pslverr                           (pslverr_regs),
     .rsb_data_m                        (i_rsb_data_m_regs),
     .rsb_valid_m                       (i_rsb_valid_m_regs),
     .rsb_ready_m                       (i_rsb_ready_m_regs));

  nic400_rsb_reg_slice_sse710_main
    #(`RSB_REG_REGS_A_SLAVE)
  u_rsb_slave_reg_regs
    (
     .rresetn                           (rresetn),
     .rclk                              (rclk),
     .rsb_data_s                        (i_rsb_data_m_regs),
     .rsb_valid_s                       (i_rsb_valid_m_regs),
     .rsb_ready_s                       (i_rsb_ready_m_regs),
     .rsb_data_m                        (rsb_data_m_regs),
     .rsb_valid_m                       (rsb_valid_m_regs),
     .rsb_ready_m                       (rsb_ready_m_regs)
     );

`ifdef RSB_A_SLAVE_M_SYNC
  assign rsb_wptr_b_async[0] = `RSB_VALID_S_LAST_A_SLAVE_SSE710_MAIN;
  assign rsb_data_m_async = `RSB_DATA_S_LAST_A_SLAVE_SSE710_MAIN;
  assign `RSB_READY_S_LAST_A_SLAVE_SSE710_MAIN = rsb_rptr_b_async[0];

  assign rsb_wptr_b_async[2:1] = 2'b0;

`else

 `ifdef RSB_L4_ASYNC

  nic400_rsb_async4_s_sse710_main #("a_slave") u_rsb_async4_s
    (
     .wclk                              (rclk),
     .wresetn                           (rresetn),
     .src_data                          (`RSB_DATA_S_LAST_A_SLAVE_SSE710_MAIN),
     .src_valid                         (`RSB_VALID_S_LAST_A_SLAVE_SSE710_MAIN),
     .src_ready                         (`RSB_READY_S_LAST_A_SLAVE_SSE710_MAIN),

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
     .sdata                             (`RSB_DATA_S_LAST_A_SLAVE_SSE710_MAIN),
     .svalid                            (`RSB_VALID_S_LAST_A_SLAVE_SSE710_MAIN),
     .sready                            (`RSB_READY_S_LAST_A_SLAVE_SSE710_MAIN),
     .rd_ptr_g_async                    (rsb_rptr_b_async[0]),
     .wr_ptr_g_async                    (rsb_wptr_b_async[0]),
     .sreg_0_async                      (rsb_data_m_async)
    );

    assign rsb_wptr_b_async[2:1] = 2'b0;

  `endif  
`endif

  `include "nic400_closure_sse710_main_undefs.v"

endmodule

`include "reg_slice_axi_undefs.v"


