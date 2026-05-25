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

module pc_eh_f0_extsysdbg (
    input  wire           extsysx_dbgclkm,

    input  wire           extsysx_dbgpresetmn,

    output wire           psel_extsysx_dbg,      
    output wire           pwakeup_extsysx_dbg,   
    output wire           penable_extsysx_dbg,   
    output wire [31:0]    paddr_extsysx_dbg,     
    output wire           pwrite_extsysx_dbg,    
    output wire [31:0]    pwdata_extsysx_dbg,    
    output wire [3:0]     pstrb_extsysx_dbg,     
    output wire [2:0]     pprot_extsysx_dbg,     
    input  wire [31:0]    prdata_extsysx_dbg,    
    input  wire           pready_extsysx_dbg,    
    input  wire           pslverr_extsysx_dbg,   

    output wire           dpabort_extsysx_dbg,
    
    input  wire           qreqn_extsysx_dbgclkm,      
    output wire           qacceptn_extsysx_dbgclkm,   
    output wire           qdeny_extsysx_dbgclkm,      
    output wire           qactive_extsysx_dbgclkm,    
    
    input  wire           apb_async_req_ehx_dbg,               
    input  wire [67:0]    apb_async_req_payload_ehx_dbg,       
    output wire [32:0]    apb_async_resp_payload_ehx_dbg,      
    output wire           apb_async_ack_ehx_dbg,               
    
    input  wire           dpabort_pulse_req_ehx,
    output wire           dpabort_pulse_ack_ehx,
    
    input  wire           dftcgen
  );
  

  wire           qreqn_dpabort_clk; 
  wire           qacceptn_dpabort_clk;
  wire           qactive_dpabort_clk;
  wire           qdeny_dpabort_clk; 
  
  wire           qreqn_dbg_apb_clk; 
  wire           qacceptn_dbg_apb_clk;
  wire           qactive_dbg_apb_clk;
  wire           qdeny_dbg_apb_clk;  
  
  wire [1:0]     qreqn_lpdq_dev;
  wire [1:0]     qacceptn_lpdq_dev;
  wire [1:0]     qdeny_lpdq_dev;
  wire [1:0]     qactive_lpdq_dev;
  
  wire           pwrite_extsysx_dbg_int;
  

  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(32),
    .FF_SYNC_DEPTH(2)
  ) u_css600_apbasyncbridgemstr (
    .clk_m                      (extsysx_dbgclkm),
    .reset_m_n                  (extsysx_dbgpresetmn),
    .dftcgen                    (dftcgen),
    .psel_m                     (psel_extsysx_dbg),
    .penable_m                  (penable_extsysx_dbg),
    .paddr_m                    (paddr_extsysx_dbg),
    .pwrite_m                   (pwrite_extsysx_dbg_int),
    .pwdata_m                   (pwdata_extsysx_dbg),
    .pprot_m                    (pprot_extsysx_dbg),
    .prdata_m                   (prdata_extsysx_dbg),
    .pready_m                   (pready_extsysx_dbg),
    .pslverr_m                  (pslverr_extsysx_dbg),
    .pwakeup_m                  (pwakeup_extsysx_dbg),
    .clk_m_qreq_n               (qreqn_dbg_apb_clk),
    .clk_m_qaccept_n            (qacceptn_dbg_apb_clk),
    .clk_m_qdeny                (qdeny_dbg_apb_clk),
    .clk_m_qactive              (qactive_dbg_apb_clk),
    .apb_async_req              (apb_async_req_ehx_dbg),
    .apb_async_req_payload      (apb_async_req_payload_ehx_dbg),
    .apb_async_resp_payload     (apb_async_resp_payload_ehx_dbg),
    .apb_async_ack              (apb_async_ack_ehx_dbg)
    );
  
  assign pstrb_extsysx_dbg = {4{pwrite_extsysx_dbg_int}};
  
  assign pwrite_extsysx_dbg = pwrite_extsysx_dbg_int;


  css600_pulseasyncbridgemstr #(
    .WIDTH         (1),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr (
    .clk_m             (extsysx_dbgclkm),
    .reset_m_n         (extsysx_dbgpresetmn),
    .pulse_out         (dpabort_extsysx_dbg),
    .pulse_req         (dpabort_pulse_req_ehx),
    .pulse_ack         (dpabort_pulse_ack_ehx),
    .clk_m_qreq_n      (qreqn_dpabort_clk),
    .clk_m_qaccept_n   (qacceptn_dpabort_clk),
    .clk_m_qactive     (qactive_dpabort_clk)
    );
  
  assign qdeny_dpabort_clk = 1'b0;

  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (2),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q (
    .clk               (extsysx_dbgclkm),
    .reset_n           (extsysx_dbgpresetmn),

    .ctrl_qreqn_i      (qreqn_extsysx_dbgclkm),
    .ctrl_qacceptn_o   (qacceptn_extsysx_dbgclkm),
    .ctrl_qdeny_o      (qdeny_extsysx_dbgclkm),
    .ctrl_qactive_o    (qactive_extsysx_dbgclkm),

    .dev_qreqn_o       (qreqn_lpdq_dev),
    .dev_qacceptn_i    (qacceptn_lpdq_dev),
    .dev_qdeny_i       (qdeny_lpdq_dev),
    .dev_qactive_i     (qactive_lpdq_dev),

    .clk_qactive_o     (),

    .dftcgen           (dftcgen)
    );
  
  assign qreqn_dpabort_clk = qreqn_lpdq_dev[0];
  assign qreqn_dbg_apb_clk = qreqn_lpdq_dev[1];
  
  assign qacceptn_lpdq_dev = {qacceptn_dbg_apb_clk, qacceptn_dpabort_clk};
  assign qdeny_lpdq_dev    = {qdeny_dbg_apb_clk   , qdeny_dpabort_clk   };
  assign qactive_lpdq_dev  = {qactive_dbg_apb_clk , qactive_dpabort_clk };

endmodule
