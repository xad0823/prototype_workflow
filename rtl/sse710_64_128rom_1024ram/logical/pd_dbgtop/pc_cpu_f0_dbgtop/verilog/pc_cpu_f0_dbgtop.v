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

module pc_cpu_f0_dbgtop (

    input  wire           dbgclk, 
    
    input  wire           dbgclk_resetn, 
    
    input  wire           atready_hostcpu,
    input  wire           afvalid_hostcpu,
    input  wire           syncreq_hostcpu,
    output wire [6:0]     atid_hostcpu,
    output wire           atvalid_hostcpu,
    output wire [31:0]    atdata_hostcpu,
    output wire [1:0]     atbytes_hostcpu,
    output wire           afready_hostcpu,
    output wire           atwakeup_hostcpu,
    
    input  wire           psel_hostcpu,
    input  wire           penable_hostcpu,
    input  wire [31:0]    paddr_hostcpu,
    input  wire           pwrite_hostcpu,
    input  wire [31:0]    pwdata_hostcpu,
    input  wire [2:0]     pprot_hostcpu,
    output wire [31:0]    prdata_hostcpu,
    output wire           pready_hostcpu,
    output wire           pslverr_hostcpu,
    input  wire           pwakeup_hostcpu,    
    
    
    input  wire           flush_done_hostcpu,
    input  wire           sync_clear_hostcpu,
    input  wire [3:0]     wr_pointer_gray_hostcpu,
    input  wire [245:0]   atb_fwd_data_hostcpu,
    input  wire           syncreq_async_ack_hostcpu,    
    output wire [3:0]     rd_pointer_gray_hostcpu,
    output wire           flush_req_hostcpu,
    output wire           sync_done_hostcpu,
    output wire           syncreq_async_req_hostcpu,

    output wire           apb_async_req_hostcpu,
    output wire [67:0]    apb_async_req_payload_hostcpu,
    input  wire [32:0]    apb_async_resp_payload_hostcpu,
    input  wire           apb_async_ack_hostcpu,
    
    input wire  [2:0]     qreqn_clustop_ingress_dbgtop,
    output wire [2:0]     qacceptn_clustop_ingress_dbgtop,
    output wire [2:0]     qdeny_clustop_ingress_dbgtop,
    output wire [2:0]     qactive_clustop_ingress_dbgtop,

    
    input wire [2:0]       qreqn_clk,
    output  wire [2:0]     qacceptn_clk,
    output  wire [2:0]     qdeny_clk,
    output  wire [2:0]     qactive_clk,

    input  wire  [2:0]      irq_pulse_in,
    output  wire  [2:0]      irq_pulse_req,  
    input  wire [2:0]      irq_pulse_ack, 
    
    input  wire [3:0]    hostcpuctichin,  
    output wire [3:0]    hostcpuctichout,
    
    output wire [3:0]                       hostcpuctichin_pulse_req,  
    input  wire [3:0]                       hostcpuctichin_pulse_ack,  
                        
    input  wire [3:0]                       hostcpuctichout_pulse_req,
    output wire [3:0]                       hostcpuctichout_pulse_ack,

    input  wire           dftcgen
);
 
 
 wire pulseasyncbridgeslv_hostcpuctichin_qactive;
 wire pulseasyncbridgeslv_hostcpuctichout_qactive;
 wire irq_pulseasyncbridgeslv_qactive;
 
 
 assign qdeny_clk[2] = 1'b0;
 
 arm_element_std_or3 u_qactive_clk_bit2_or3 (.A (pulseasyncbridgeslv_hostcpuctichout_qactive), .B (pulseasyncbridgeslv_hostcpuctichin_qactive), .C (irq_pulseasyncbridgeslv_qactive), .Y (qactive_clk[2]) );
 
 css600_pulseasyncbridgeslv 
 #(
    .WIDTH(4),
    .WAKE_ON_PULSE(0)
 )
 u_css600_pulseasyncbridgeslv_hostcpuctichin
 (
   .clk_s         (dbgclk),
   .reset_s_n     (dbgclk_resetn),
   .pulse_in      (hostcpuctichin),
   .pulse_req     (hostcpuctichin_pulse_req),
   .pulse_ack     (hostcpuctichin_pulse_ack),
   .clk_s_qactive (pulseasyncbridgeslv_hostcpuctichin_qactive),
   .pwr_qreq_n    (qreqn_clustop_ingress_dbgtop[1]),
   .pwr_qaccept_n (qacceptn_clustop_ingress_dbgtop[1]),
   .pwr_qactive   (qactive_clustop_ingress_dbgtop[1])
 );
 
 assign qdeny_clustop_ingress_dbgtop[1] = 1'b0;
  
 css600_pulseasyncbridgemstr 
 #(
    .WIDTH(4)
 )
 u_css600_pulseasyncbridgeslv_hostcpuctichout
 (
   .clk_m            (dbgclk),
   .reset_m_n        (dbgclk_resetn),
   .pulse_out        (hostcpuctichout),
   .pulse_req        (hostcpuctichout_pulse_req),
   .pulse_ack        (hostcpuctichout_pulse_ack),
   .clk_m_qreq_n     (qreqn_clk[2]),
   .clk_m_qaccept_n  (qacceptn_clk[2]),
   .clk_m_qactive    (pulseasyncbridgeslv_hostcpuctichout_qactive)
 );                  
   



 
 


  css600_atbasyncbridgemstr #(
    .ATB_DATA_WIDTH (32),
    .FF_SYNC_DEPTH  (2)
  ) u_css600_atbasyncbridgemstr (
    .clk_m               (dbgclk),
    .reset_m_n           (dbgclk_resetn),
    .atready_m           (atready_hostcpu),
    .afvalid_m           (afvalid_hostcpu),
    .atb_fwd_data        (atb_fwd_data_hostcpu),
    .atvalid_m           (atvalid_hostcpu),
    .atbytes_m           (atbytes_hostcpu),
    .atid_m              (atid_hostcpu),
    .atdata_m            (atdata_hostcpu),
    .afready_m           (afready_hostcpu),
    .atwakeup_m          (atwakeup_hostcpu),
    .wr_pointer_gray     (wr_pointer_gray_hostcpu),
    .rd_pointer_gray     (rd_pointer_gray_hostcpu),
    .flush_done          (flush_done_hostcpu),
    .flush_req           (flush_req_hostcpu),
    .sync_clear          (sync_clear_hostcpu),
    .sync_done           (sync_done_hostcpu),
    .syncreq_async_req   (syncreq_async_req_hostcpu),
    .syncreq_async_ack   (syncreq_async_ack_hostcpu),
    .syncreq_m           (syncreq_hostcpu),
    .clk_m_qreq_n        (qreqn_clk[0]),
    .clk_m_qaccept_n     (qacceptn_clk[0]),
    .clk_m_qdeny         (qdeny_clk[0]),
    .clk_m_qactive       (qactive_clk[0])
);

    
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_css600_apbasyncbridgeslv (
    .clk_s                      (dbgclk),
    .reset_s_n                  (dbgclk_resetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_hostcpu),
    .penable_s                  (penable_hostcpu),
    .paddr_s                    (paddr_hostcpu),
    .pwrite_s                   (pwrite_hostcpu),
    .pwdata_s                   (pwdata_hostcpu),
    .pprot_s                    (pprot_hostcpu),
    .prdata_s                   (prdata_hostcpu),
    .pready_s                   (pready_hostcpu),
    .pslverr_s                  (pslverr_hostcpu),
    .pwakeup_s                  (pwakeup_hostcpu),
    
    .clk_s_qreq_n               (qreqn_clk[1]),
    .clk_s_qaccept_n            (qacceptn_clk[1]),
    .clk_s_qdeny                (qdeny_clk[1]),
    .clk_s_qactive              (qactive_clk[1]), 
    
    .pwr_qreq_n                 (qreqn_clustop_ingress_dbgtop[0]),
    .pwr_qaccept_n              (qacceptn_clustop_ingress_dbgtop[0]),
    .pwr_qdeny                  (qdeny_clustop_ingress_dbgtop[0]),
    .pwr_qactive                (qactive_clustop_ingress_dbgtop[0]),
    
    .apb_async_req              (apb_async_req_hostcpu),
    .apb_async_req_payload      (apb_async_req_payload_hostcpu),
    .apb_async_resp_payload     (apb_async_resp_payload_hostcpu),
    .apb_async_ack              (apb_async_ack_hostcpu)
  );

  
css600_pulseasyncbridgeslv #(
            .WIDTH(3),
            .WAKE_ON_PULSE(0)
  )
  u_css600_irq_pulseasyncbridgeslv
  (
      .clk_s          (dbgclk),
      .reset_s_n      (dbgclk_resetn),
      .pulse_in       (irq_pulse_in  ),
      .pulse_req      (irq_pulse_req ),
      .pulse_ack      (irq_pulse_ack ),
      .clk_s_qactive  (irq_pulseasyncbridgeslv_qactive),
      .pwr_qreq_n     (qreqn_clustop_ingress_dbgtop[2]),
      .pwr_qaccept_n  (qacceptn_clustop_ingress_dbgtop[2]),
      .pwr_qactive    (qactive_clustop_ingress_dbgtop[2])
  );
  assign qdeny_clustop_ingress_dbgtop[2] = 1'b0;

endmodule
