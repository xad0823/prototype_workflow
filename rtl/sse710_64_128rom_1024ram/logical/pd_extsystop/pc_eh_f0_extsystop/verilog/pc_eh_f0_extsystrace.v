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

module pc_eh_f0_extsystrace (

    input  wire           extsysx_atclk,

    input  wire           extsysx_atresetn,

    output wire           atready_extsysx_traceexp, 
    output wire           afvalid_extsysx_traceexp, 
    output wire           syncreq_extsysx_traceexp, 
    input  wire [6:0]     atid_extsysx_traceexp,    
    input  wire           atvalid_extsysx_traceexp, 
    input  wire [31:0]    atdata_extsysx_traceexp,  
    input  wire [1:0]     atbytes_extsysx_traceexp, 
    input  wire           afready_extsysx_traceexp, 
    input  wire           atwakeup_extsysx_traceexp,

    input  wire           qreqn_extsysx_atclk,   
    output wire           qacceptn_extsysx_atclk,
    output wire           qdeny_extsysx_atclk,   
    output wire           qactive_extsysx_atclk, 
    
    input  wire           qreqn_extsysx_traceexppwr,         
    output wire           qacceptn_extsysx_traceexppwr,     
    output wire           qdeny_extsysx_traceexppwr,      
    output wire           qactive_extsysx_traceexppwr,  
  
    input  wire [3:0]     rd_pointer_gray_ehx,
    input  wire           flush_req_ehx,
    input  wire           sync_done_ehx,
    input  wire           syncreq_async_req_ehx,
    output wire           flush_done_ehx,
    output wire           sync_clear_ehx,
    output wire [3:0]     wr_pointer_gray_ehx,
    output wire [245:0]   atb_fwd_data_ehx,
    output wire           syncreq_async_ack_ehx
);
  

  css600_atbasyncbridgeslv #(
    .ATB_DATA_WIDTH (32),
    .FF_SYNC_DEPTH  (2)
    ) u_css600_atbasyncbridgeslv (
    .clk_s                 (extsysx_atclk),
    .reset_s_n             (extsysx_atresetn),
    .atvalid_s             (atvalid_extsysx_traceexp),
    .atid_s                (atid_extsysx_traceexp),
    .atbytes_s             (atbytes_extsysx_traceexp),
    .atdata_s              (atdata_extsysx_traceexp),
    .afready_s             (afready_extsysx_traceexp),
    .atwakeup_s            (atwakeup_extsysx_traceexp),
    .atb_fwd_data          (atb_fwd_data_ehx),
    .flush_done            (flush_done_ehx),
    .flush_req             (flush_req_ehx),
    .sync_clear            (sync_clear_ehx),
    .sync_done             (sync_done_ehx),
    .syncreq_async_req     (syncreq_async_req_ehx),
    .syncreq_async_ack     (syncreq_async_ack_ehx),
    .wr_pointer_gray       (wr_pointer_gray_ehx),
    .rd_pointer_gray       (rd_pointer_gray_ehx),
    .syncreq_s             (syncreq_extsysx_traceexp),
    .atready_s             (atready_extsysx_traceexp),
    .afvalid_s             (afvalid_extsysx_traceexp),
    .clk_s_qreq_n          (qreqn_extsysx_atclk),    
    .clk_s_qaccept_n       (qacceptn_extsysx_atclk), 
    .clk_s_qactive         (qactive_extsysx_atclk),    
    .clk_s_qdeny           (qdeny_extsysx_atclk),  
    .pwr_qreq_n            (qreqn_extsysx_traceexppwr),   
    .pwr_qaccept_n         (qacceptn_extsysx_traceexppwr),
    .pwr_qdeny             (qdeny_extsysx_traceexppwr),   
    .pwr_qactive           (qactive_extsysx_traceexppwr) 
  );

endmodule
