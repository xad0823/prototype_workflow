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

module pc_eh_f0_extsysextdbg (
    input  wire           extsysx_dbgclks,

    input  wire           extsysx_dbgpresetsn,

    input  wire           psel_extsysx_extdbg,     
    input  wire           pwakeup_extsysx_extdbg,  
    input  wire           penable_extsysx_extdbg,  
    input  wire [31:0]    paddr_extsysx_extdbg,    
    input  wire           pwrite_extsysx_extdbg,   
    input  wire [31:0]    pwdata_extsysx_extdbg,
    input  wire [3:0]     pstrb_extsysx_extdbg,
    input  wire [2:0]     pprot_extsysx_extdbg,    
    output wire [31:0]    prdata_extsysx_extdbg,   
    output wire           pready_extsysx_extdbg,   
    output wire           pslverr_extsysx_extdbg,  

    input  wire           qreqn_extsysx_dbgclks,   
    output wire           qacceptn_extsysx_dbgclks,
    output wire           qdeny_extsysx_dbgclks,   
    output wire           qactive_extsysx_dbgclks, 

    input  wire           qreqn_extsysx_extdbgpwr,         
    output wire           qacceptn_extsysx_extdbgpwr,     
    output wire           qdeny_extsysx_extdbgpwr,      
    output wire           qactive_extsysx_extdbgpwr,    
    
    output wire           apb_async_req_ehx_extdbg,          
    output wire [67:0]    apb_async_req_payload_ehx_extdbg,  
    input  wire [32:0]    apb_async_resp_payload_ehx_extdbg, 
    input  wire           apb_async_ack_ehx_extdbg,          
    
    input  wire           dftcgen
    );


  wire unused;


  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0),
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_css600_apbasyncbridgeslv (
    .clk_s                      (extsysx_dbgclks),
    .reset_s_n                  (extsysx_dbgpresetsn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_extsysx_extdbg),
    .penable_s                  (penable_extsysx_extdbg),
    .paddr_s                    (paddr_extsysx_extdbg),
    .pwrite_s                   (pwrite_extsysx_extdbg),
    .pwdata_s                   (pwdata_extsysx_extdbg),
    .pprot_s                    (pprot_extsysx_extdbg),
    .prdata_s                   (prdata_extsysx_extdbg),
    .pready_s                   (pready_extsysx_extdbg),
    .pslverr_s                  (pslverr_extsysx_extdbg),
    .pwakeup_s                  (pwakeup_extsysx_extdbg),
    
    .clk_s_qreq_n               (qreqn_extsysx_dbgclks),    
    .clk_s_qaccept_n            (qacceptn_extsysx_dbgclks), 
    .clk_s_qdeny                (qdeny_extsysx_dbgclks),    
    .clk_s_qactive              (qactive_extsysx_dbgclks),  
    
    .pwr_qreq_n                 (qreqn_extsysx_extdbgpwr),   
    .pwr_qaccept_n              (qacceptn_extsysx_extdbgpwr),
    .pwr_qdeny                  (qdeny_extsysx_extdbgpwr),   
    .pwr_qactive                (qactive_extsysx_extdbgpwr), 
    
    .apb_async_req              (apb_async_req_ehx_extdbg),
    .apb_async_req_payload      (apb_async_req_payload_ehx_extdbg),
    .apb_async_resp_payload     (apb_async_resp_payload_ehx_extdbg),
    .apb_async_ack              (apb_async_ack_ehx_extdbg)
  );


  assign unused = |pstrb_extsysx_extdbg;

endmodule
