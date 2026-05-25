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

module eh_f0_aontop (

    input  wire           refclk, 
    
    input  wire           refclk_resetn, 
    
    output wire           psel_ehx_extdbg,
    output wire           penable_ehx_extdbg,
    output wire [31:0]    paddr_ehx_extdbg,
    output wire           pwrite_ehx_extdbg,
    output wire [31:0]    pwdata_ehx_extdbg,
    output wire [2:0]     pprot_ehx_extdbg,
    input  wire [31:0]    prdata_ehx_extdbg,
    input  wire           pready_ehx_extdbg,
    input  wire           pslverr_ehx_extdbg,
    output  wire          pwakeup_ehx_extdbg,     
    
    input  wire           apb_async_req_ehx_extdbg,
    input  wire [67:0]    apb_async_req_payload_ehx_extdbg,
    output wire [32:0]    apb_async_resp_payload_ehx_extdbg,
    output wire           apb_async_ack_ehx_extdbg,
    
    input  wire           qreqn_ehx_refclk,        
    output wire           qacceptn_ehx_refclk,    
    output wire           qdeny_ehx_refclk,     
    output wire           qactive_ehx_refclk, 
       
    input  wire           dftcgen
  );
  
  
  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH  (32),
    .FF_SYNC_DEPTH   (2)
  ) u_css600_apbasyncbridgemstr (
    .clk_m                      (refclk),
    .reset_m_n                  (refclk_resetn),
    .dftcgen                    (dftcgen),
    .psel_m                     (psel_ehx_extdbg),
    .penable_m                  (penable_ehx_extdbg),
    .paddr_m                    (paddr_ehx_extdbg),
    .pwrite_m                   (pwrite_ehx_extdbg),
    .pwdata_m                   (pwdata_ehx_extdbg),
    .pprot_m                    (pprot_ehx_extdbg),
    .prdata_m                   (prdata_ehx_extdbg),
    .pready_m                   (pready_ehx_extdbg),
    .pslverr_m                  (pslverr_ehx_extdbg),
    .pwakeup_m                  (pwakeup_ehx_extdbg),
    .clk_m_qreq_n               (qreqn_ehx_refclk),
    .clk_m_qaccept_n            (qacceptn_ehx_refclk),
    .clk_m_qdeny                (qdeny_ehx_refclk),
    .clk_m_qactive              (qactive_ehx_refclk),
    .apb_async_req              (apb_async_req_ehx_extdbg),
    .apb_async_req_payload      (apb_async_req_payload_ehx_extdbg),
    .apb_async_resp_payload     (apb_async_resp_payload_ehx_extdbg),
    .apb_async_ack              (apb_async_ack_ehx_extdbg)
  );

endmodule
