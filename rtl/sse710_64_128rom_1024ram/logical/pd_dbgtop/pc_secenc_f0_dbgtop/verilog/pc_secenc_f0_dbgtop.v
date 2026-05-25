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

module pc_secenc_f0_dbgtop (
    
    input  wire           dbgclk,

    input  wire           dbgtopwarmresetn,

    input  wire           psel_secenc_dbg,     
    input  wire           pwakeup_secenc_dbg,  
    input  wire           penable_secenc_dbg,  
    input  wire [12:0]    paddr_secenc_dbg,    
    input  wire           pwrite_secenc_dbg,   
    input  wire [31:0]    pwdata_secenc_dbg,
    input  wire [2:0]     pprot_secenc_dbg,    
    output wire [31:0]    prdata_secenc_dbg,   
    output wire           pready_secenc_dbg,   
    output wire           pslverr_secenc_dbg,  

    input  wire           dp_abort_secenc,
    
    input  wire [3:0]     cti_cha_to_secenc,
    
    output wire [3:0]     cti_secenc_to_cha,    
    
    input  wire [1:0]     qreqn_secenc_dbgclk,   
    output wire [1:0]     qacceptn_secenc_dbgclk,
    output wire [1:0]     qdeny_secenc_dbgclk,   
    output wire [1:0]     qactive_secenc_dbgclk, 
    output wire [2:0]     qactive_only_secenc_dbgclk,

    input  wire           qreqn_secenc_pwr,         
    output wire           qacceptn_secenc_pwr,     
    output wire           qdeny_secenc_pwr,      
    output wire           qactive_secenc_pwr,    
    
    output wire           apb_async_req_secenc_dbg,          
    output wire [48:0]    apb_async_req_payload_secenc_dbg,  
    input  wire [32:0]    apb_async_resp_payload_secenc_dbg, 
    input  wire           apb_async_ack_secenc_dbg,         

    output wire           dp_abort_secenc_pulse_req,          
    input  wire           dp_abort_secenc_pulse_ack,
    
    output wire [3:0]     cti_cha_to_secenc_pulse_req,      
    input  wire [3:0]     cti_cha_to_secenc_pulse_ack,
    output wire [3:0]     cti_secenc_to_cha_pulse_ack,
    input  wire [3:0]     cti_secenc_to_cha_pulse_req,
    
    input  wire           dftcgen
    );

  
  wire           qreqn_adb_pwr;         
  wire           qacceptn_adb_pwr;     
  wire           qdeny_adb_pwr;      
  wire           qactive_adb_pwr;    
  
  wire           qreqn_pulseasync_dp_pwr;         
  wire           qacceptn_pulseasync_dp_pwr;     
  wire           qdeny_pulseasync_dp_pwr;      
  wire           qactive_pulseasync_dp_pwr;
  
  wire           qreqn_pulseasync_cti_pwr;         
  wire           qacceptn_pulseasync_cti_pwr;     
  wire           qdeny_pulseasync_cti_pwr;      
  wire           qactive_pulseasync_cti_pwr;  
   
  
  wire           qactive_lpdq_clk;
  wire           qactive_pulseasync_dp_clk;
  wire           qactive_pulseasync_cti_clk_slv;
  wire           qactive_lpdq_pwr;
  

  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0),
    .APB_ADDR_WIDTH      (13),
    .FF_SYNC_DEPTH       (2)
  ) u_css600_apbasyncbridgeslv (
    .clk_s                      (dbgclk),
    .reset_s_n                  (dbgtopwarmresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_secenc_dbg),
    .penable_s                  (penable_secenc_dbg),
    .paddr_s                    (paddr_secenc_dbg),
    .pwrite_s                   (pwrite_secenc_dbg),
    .pwdata_s                   (pwdata_secenc_dbg),
    .pprot_s                    (pprot_secenc_dbg),
    .prdata_s                   (prdata_secenc_dbg),
    .pready_s                   (pready_secenc_dbg),
    .pslverr_s                  (pslverr_secenc_dbg),
    .pwakeup_s                  (pwakeup_secenc_dbg),
    
    .clk_s_qreq_n               (qreqn_secenc_dbgclk[1]),    
    .clk_s_qaccept_n            (qacceptn_secenc_dbgclk[1]), 
    .clk_s_qdeny                (qdeny_secenc_dbgclk[1]),    
    .clk_s_qactive              (qactive_secenc_dbgclk[1]),  
    
    .pwr_qreq_n                 (qreqn_adb_pwr),   
    .pwr_qaccept_n              (qacceptn_adb_pwr),
    .pwr_qdeny                  (qdeny_adb_pwr),   
    .pwr_qactive                (qactive_adb_pwr), 
    
    .apb_async_req              (apb_async_req_secenc_dbg),
    .apb_async_req_payload      (apb_async_req_payload_secenc_dbg),
    .apb_async_resp_payload     (apb_async_resp_payload_secenc_dbg),
    .apb_async_ack              (apb_async_ack_secenc_dbg)
  );

  css600_pulseasyncbridgeslv #(
    .WIDTH         (1),
    .WAKE_ON_PULSE (0),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgeslv_0 (
    .clk_s            (dbgclk),
    .reset_s_n        (dbgtopwarmresetn),
    
    .pulse_in         (dp_abort_secenc),
    
    .pulse_req        (dp_abort_secenc_pulse_req),
    .pulse_ack        (dp_abort_secenc_pulse_ack),
    
    .clk_s_qactive    (qactive_pulseasync_dp_clk),
    
    .pwr_qreq_n       (qreqn_pulseasync_dp_pwr),
    .pwr_qaccept_n    (qacceptn_pulseasync_dp_pwr),
    .pwr_qactive      (qactive_pulseasync_dp_pwr)
  );
  
  assign qdeny_pulseasync_dp_pwr = 1'b0;
  
  css600_pulseasyncbridgeslv #(
    .WIDTH         (4),
    .WAKE_ON_PULSE (0),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgeslv_1 (
    .clk_s            (dbgclk),
    .reset_s_n        (dbgtopwarmresetn),
    
    .pulse_in         (cti_cha_to_secenc),
    
    .pulse_req        (cti_cha_to_secenc_pulse_req),
    .pulse_ack        (cti_cha_to_secenc_pulse_ack),
    
    .clk_s_qactive    (qactive_pulseasync_cti_clk_slv),
    
    .pwr_qreq_n       (qreqn_pulseasync_cti_pwr),
    .pwr_qaccept_n    (qacceptn_pulseasync_cti_pwr),
    .pwr_qactive      (qactive_pulseasync_cti_pwr)
  );
  
  assign qdeny_pulseasync_cti_pwr = 1'b0;  
  
  css600_pulseasyncbridgemstr #(
    .WIDTH         (4),
    .FF_SYNC_DEPTH (2)
  ) u_css600_pulseasyncbridgemstr (
    .clk_m             (dbgclk),
    .reset_m_n         (dbgtopwarmresetn),
    
    .pulse_out         (cti_secenc_to_cha),
    
    .pulse_req         (cti_secenc_to_cha_pulse_req),
    .pulse_ack         (cti_secenc_to_cha_pulse_ack),
    
    .clk_m_qreq_n      (qreqn_secenc_dbgclk[0]),
    .clk_m_qaccept_n   (qacceptn_secenc_dbgclk[0]),
    .clk_m_qactive     (qactive_secenc_dbgclk[0])
    );
  
  assign qdeny_secenc_dbgclk[0] = 1'b0;  
  
  

  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (3),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q_pwr (
    .clk               (dbgclk),
    .reset_n           (dbgtopwarmresetn),

    .ctrl_qreqn_i      (qreqn_secenc_pwr),
    .ctrl_qacceptn_o   (qacceptn_secenc_pwr),
    .ctrl_qdeny_o      (qdeny_secenc_pwr),
    .ctrl_qactive_o    (qactive_secenc_pwr),
    
    .dev_qreqn_o       ({qreqn_pulseasync_cti_pwr   , qreqn_pulseasync_dp_pwr   , qreqn_adb_pwr   }),
    .dev_qacceptn_i    ({qacceptn_pulseasync_cti_pwr, qacceptn_pulseasync_dp_pwr, qacceptn_adb_pwr}),
    .dev_qdeny_i       ({qdeny_pulseasync_cti_pwr   , qdeny_pulseasync_dp_pwr   , qdeny_adb_pwr   }),
    .dev_qactive_i     ({qactive_pulseasync_cti_pwr , qactive_pulseasync_dp_pwr , qactive_adb_pwr }),

    .clk_qactive_o     (qactive_lpdq_pwr),

    .dftcgen           (dftcgen)
    );
    
       
  assign qactive_only_secenc_dbgclk = {qactive_pulseasync_dp_clk, qactive_pulseasync_cti_clk_slv, qactive_lpdq_pwr};
  
endmodule