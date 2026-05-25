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

module pc_eh_f0_dbgtop (

    input  wire           dbgclk, 
    
    input  wire           dbgtopwarmresetn, 
    
    input  wire           atready_ehx,
    input  wire           afvalid_ehx,
    input  wire           syncreq_ehx,
    output wire [6:0]     atid_ehx,
    output wire           atvalid_ehx,
    output wire [31:0]    atdata_ehx,
    output wire [1:0]     atbytes_ehx,
    output wire           afready_ehx,
    output wire           atwakeup_ehx,
    
    input  wire           psel_ehx_dbg,
    input  wire           penable_ehx_dbg,
    input  wire [31:0]    paddr_ehx_dbg,
    input  wire           pwrite_ehx_dbg,
    input  wire [31:0]    pwdata_ehx_dbg,
    input  wire [2:0]     pprot_ehx_dbg,
    output wire [31:0]    prdata_ehx_dbg,
    output wire           pready_ehx_dbg,
    output wire           pslverr_ehx_dbg,
    input  wire           pwakeup_ehx_dbg,    
    
    input  wire [3:0]     channel_out_ehx_cti,

    output  wire [3:0]    channel_in_ehx_cti,
    
    input  wire           dpabort_ehx,
    
    input  wire           flush_done_ehx,
    input  wire           sync_clear_ehx,
    input  wire [3:0]     wr_pointer_gray_ehx,
    input  wire [245:0]   atb_fwd_data_ehx,
    input  wire           syncreq_async_ack_ehx,    
    output wire [3:0]     rd_pointer_gray_ehx,
    output wire           flush_req_ehx,
    output wire           sync_done_ehx,
    output wire           syncreq_async_req_ehx,

    output wire           apb_async_req_ehx_dbg,
    output wire [67:0]    apb_async_req_payload_ehx_dbg,
    input  wire [32:0]    apb_async_resp_payload_ehx_dbg,
    input  wire           apb_async_ack_ehx_dbg,
    
    output wire [3:0]     pulse_req_ehx_cti_out,
    input  wire [3:0]     pulse_ack_ehx_cti_out,
    
    output wire [3:0]     pulse_ack_ehx_cti_in,
    input  wire [3:0]     pulse_req_ehx_cti_in,   
    
    output wire           dpabort_pulse_req_ehx,
    input  wire           dpabort_pulse_ack_ehx,
    
    input  wire           qreqn_extsysx_ctioutpwr,        
    output wire           qacceptn_extsysx_ctioutpwr,    
    output wire           qdeny_extsysx_ctioutpwr,     
    output wire           qactive_extsysx_ctioutpwr, 
    
    input  wire           qreqn_extsysx_dbgpwr,        
    output wire           qacceptn_extsysx_dbgpwr,    
    output wire           qdeny_extsysx_dbgpwr,     
    output wire           qactive_extsysx_dbgpwr, 
    
    input  wire  [2:0]    qreqn_ehx_dbgclk,
    output wire  [2:0]    qacceptn_ehx_dbgclk,
    output wire  [2:0]    qdeny_ehx_dbgclk,
    output wire  [2:0]    qactive_ehx_dbgclk,
    output wire  [2:0]    qactive_only_ehx_dbgclk,
    
    input  wire           dftcgen
);

  
  wire           qreqn_cti_mst_clk; 
  wire           qacceptn_cti_mst_clk;
  wire           qactive_cti_mst_clk;
  wire           qdeny_cti_mst_clk;  
  
  wire           qactive_cti_slv_clk;  

  wire           qreqn_atb_clk;
  wire           qacceptn_atb_clk;
  wire           qdeny_atb_clk;
  wire           qactive_atb_clk;
  
  wire           qreqn_dbg_apb_pwr;
  wire           qacceptn_dbg_apb_pwr;
  wire           qdeny_dbg_apb_pwr;
  wire           qactive_dbg_apb_pwr;

  wire           qreqn_dbg_apb_clk; 
  wire           qacceptn_dbg_apb_clk;
  wire           qdeny_dbg_apb_clk;
  wire           qactive_dbg_apb_clk;
  
  wire           qreqn_dpabort_pwr;  
  wire           qacceptn_dpabort_pwr;
  wire           qdeny_dpabort_pwr;
  wire           qactive_dpabort_pwr;
  
  wire           qactive_dpabort_clk;
  
  
  wire [1:0]     qreqn_lpdq_pwr;
  wire [1:0]     qacceptn_lpdq_pwr;
  wire [1:0]     qdeny_lpdq_pwr;
  wire [1:0]     qactive_lpdq_pwr;
  
  wire           qactive_lpdq_pwr_clk;
  


  css600_pulseasyncbridgemstr #(
    .WIDTH         (4),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr (
    .clk_m             (dbgclk),
    .reset_m_n         (dbgtopwarmresetn),
    .pulse_out         (channel_in_ehx_cti),
    .pulse_req         (pulse_req_ehx_cti_in),
    .pulse_ack         (pulse_ack_ehx_cti_in),
    .clk_m_qreq_n      (qreqn_cti_mst_clk),
    .clk_m_qaccept_n   (qacceptn_cti_mst_clk),
    .clk_m_qactive     (qactive_cti_mst_clk)
    );
  
  assign qdeny_cti_mst_clk   = 1'b0;


  css600_pulseasyncbridgeslv #(
    .WIDTH         (4),
    .WAKE_ON_PULSE (0), 
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgeslv_cti  (
    .clk_s            (dbgclk),
    .reset_s_n        (dbgtopwarmresetn),
    .pulse_in         (channel_out_ehx_cti),
    .pulse_req        (pulse_req_ehx_cti_out),
    .pulse_ack        (pulse_ack_ehx_cti_out),
    .clk_s_qactive    (qactive_cti_slv_clk),
    .pwr_qreq_n       (qreqn_extsysx_ctioutpwr),
    .pwr_qaccept_n    (qacceptn_extsysx_ctioutpwr),
    .pwr_qactive      (qactive_extsysx_ctioutpwr)
    );
  
  assign qdeny_extsysx_ctioutpwr = 1'b0;
  

  css600_atbasyncbridgemstr #(
    .ATB_DATA_WIDTH (32),
    .FF_SYNC_DEPTH  (2)
  ) u_css600_atbasyncbridgemstr (
    .clk_m               (dbgclk),
    .reset_m_n           (dbgtopwarmresetn),
    .atready_m           (atready_ehx),
    .afvalid_m           (afvalid_ehx),
    .atb_fwd_data        (atb_fwd_data_ehx),
    .atvalid_m           (atvalid_ehx),
    .atbytes_m           (atbytes_ehx),
    .atid_m              (atid_ehx),
    .atdata_m            (atdata_ehx),
    .afready_m           (afready_ehx),
    .atwakeup_m          (atwakeup_ehx),
    .wr_pointer_gray     (wr_pointer_gray_ehx),
    .rd_pointer_gray     (rd_pointer_gray_ehx),
    .flush_done          (flush_done_ehx),
    .flush_req           (flush_req_ehx),
    .sync_clear          (sync_clear_ehx),
    .sync_done           (sync_done_ehx),
    .syncreq_async_req   (syncreq_async_req_ehx),
    .syncreq_async_ack   (syncreq_async_ack_ehx),
    .syncreq_m           (syncreq_ehx),
    .clk_m_qreq_n        (qreqn_atb_clk),
    .clk_m_qaccept_n     (qacceptn_atb_clk),
    .clk_m_qdeny         (qdeny_atb_clk),
    .clk_m_qactive       (qactive_atb_clk)
);


  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_css600_apbasyncbridgeslv (
    .clk_s                      (dbgclk),
    .reset_s_n                  (dbgtopwarmresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_ehx_dbg),
    .penable_s                  (penable_ehx_dbg),
    .paddr_s                    (paddr_ehx_dbg),
    .pwrite_s                   (pwrite_ehx_dbg),
    .pwdata_s                   (pwdata_ehx_dbg),
    .pprot_s                    (pprot_ehx_dbg),
    .prdata_s                   (prdata_ehx_dbg),
    .pready_s                   (pready_ehx_dbg),
    .pslverr_s                  (pslverr_ehx_dbg),
    .pwakeup_s                  (pwakeup_ehx_dbg),
    
    .clk_s_qreq_n               (qreqn_dbg_apb_clk),
    .clk_s_qaccept_n            (qacceptn_dbg_apb_clk),
    .clk_s_qdeny                (qdeny_dbg_apb_clk),
    .clk_s_qactive              (qactive_dbg_apb_clk), 
    
    .pwr_qreq_n                 (qreqn_dbg_apb_pwr),
    .pwr_qaccept_n              (qacceptn_dbg_apb_pwr),
    .pwr_qdeny                  (qdeny_dbg_apb_pwr),
    .pwr_qactive                (qactive_dbg_apb_pwr),
    
    .apb_async_req              (apb_async_req_ehx_dbg),
    .apb_async_req_payload      (apb_async_req_payload_ehx_dbg),
    .apb_async_resp_payload     (apb_async_resp_payload_ehx_dbg),
    .apb_async_ack              (apb_async_ack_ehx_dbg)
  );

  
  css600_pulseasyncbridgeslv #(
    .WIDTH         (1),
    .WAKE_ON_PULSE (0), 
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgeslv_dpabort  (
    .clk_s            (dbgclk),
    .reset_s_n        (dbgtopwarmresetn),
    .pulse_in         (dpabort_ehx),
    .pulse_req        (dpabort_pulse_req_ehx),
    .pulse_ack        (dpabort_pulse_ack_ehx),
    .clk_s_qactive    (qactive_dpabort_clk),
    .pwr_qreq_n       (qreqn_dpabort_pwr),
    .pwr_qaccept_n    (qacceptn_dpabort_pwr),
    .pwr_qactive      (qactive_dpabort_pwr)
    );
  
  assign qdeny_dpabort_pwr = 1'b0;
  

  

  assign qreqn_cti_mst_clk = qreqn_ehx_dbgclk[0];
  assign qreqn_atb_clk     = qreqn_ehx_dbgclk[1];
  assign qreqn_dbg_apb_clk = qreqn_ehx_dbgclk[2];
  
  assign qacceptn_ehx_dbgclk = {qacceptn_dbg_apb_clk, qacceptn_atb_clk, qacceptn_cti_mst_clk};
  assign qdeny_ehx_dbgclk    = {qdeny_dbg_apb_clk   , qdeny_atb_clk   , qdeny_cti_mst_clk   };
  assign qactive_ehx_dbgclk  = {qactive_dbg_apb_clk , qactive_atb_clk , qactive_cti_mst_clk };

  assign qactive_only_ehx_dbgclk = {qactive_cti_slv_clk,qactive_lpdq_pwr_clk,qactive_dpabort_clk};
  
  

  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (2),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q_pwr (
    .clk               (dbgclk),
    .reset_n           (dbgtopwarmresetn),

    .ctrl_qreqn_i      (qreqn_extsysx_dbgpwr),
    .ctrl_qacceptn_o   (qacceptn_extsysx_dbgpwr),
    .ctrl_qdeny_o      (qdeny_extsysx_dbgpwr),
    .ctrl_qactive_o    (qactive_extsysx_dbgpwr),

    .dev_qreqn_o       (qreqn_lpdq_pwr),
    .dev_qacceptn_i    (qacceptn_lpdq_pwr),
    .dev_qdeny_i       (qdeny_lpdq_pwr),
    .dev_qactive_i     (qactive_lpdq_pwr),

    .clk_qactive_o     (qactive_lpdq_pwr_clk),

    .dftcgen           (dftcgen)
    );
  
  assign qreqn_dbg_apb_pwr = qreqn_lpdq_pwr[0];
  assign qreqn_dpabort_pwr = qreqn_lpdq_pwr[1];
  
  assign qacceptn_lpdq_pwr = {qacceptn_dpabort_pwr, qacceptn_dbg_apb_pwr};
  assign qdeny_lpdq_pwr    = {qdeny_dpabort_pwr   , qdeny_dbg_apb_pwr   };
  assign qactive_lpdq_pwr  = {qactive_dpabort_pwr , qactive_dbg_apb_pwr };
  
endmodule
