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

module sse710_boot_reg_f0_systop (
    
    input  wire          aclk,
    
    input  wire          aresetn,
        
    input  wire [9:0]    awid_bootreg_axim,       
    input  wire [39:0]   awaddr_bootreg_axim,    
    input  wire [7:0]    awlen_bootreg_axim,     
    input  wire [2:0]    awsize_bootreg_axim,     
    input  wire [1:0]    awburst_bootreg_axim,  
    input  wire          awlock_bootreg_axim,
    input  wire [3:0]    awcache_bootreg_axim,
    input  wire [2:0]    awprot_bootreg_axim,
    input  wire          awvalid_bootreg_axim,    
    output wire          awready_bootreg_axim,    
    input  wire [9:0]    awuser_bootreg_axim,
    input  wire [31:0]   wdata_bootreg_axim,      
    input  wire [3:0]    wstrb_bootreg_axim,     
    input  wire          wlast_bootreg_axim,      
    input  wire          wvalid_bootreg_axim,     
    output wire          wready_bootreg_axim,    
    output wire [9:0]    bid_bootreg_axim,        
    output wire [1:0]    bresp_bootreg_axim,      
    output wire          bvalid_bootreg_axim,     
    input  wire          bready_bootreg_axim,    
    input  wire [9:0]    arid_bootreg_axim,       
    input  wire [39:0]   araddr_bootreg_axim,     
    input  wire [7:0]    arlen_bootreg_axim,      
    input  wire [2:0]    arsize_bootreg_axim,     
    input  wire [1:0]    arburst_bootreg_axim, 
    input  wire          arlock_bootreg_axim,
    input  wire [3:0]    arcache_bootreg_axim,
    input  wire [2:0]    arprot_bootreg_axim,
    input  wire          arvalid_bootreg_axim,   
    output wire          arready_bootreg_axim,
    input  wire [9:0]    aruser_bootreg_axim,
    output wire [9:0]    rid_bootreg_axim, 
    output wire [31:0]   rdata_bootreg_axim,  
    output wire [1:0]    rresp_bootreg_axim,      
    output wire          rlast_bootreg_axim,      
    output wire          rvalid_bootreg_axim,     
    input  wire          rready_bootreg_axim,

    input wire            qreqn_bootreg_aclk_nic,
    output wire           qacceptn_bootreg_aclk_nic,
    output wire           qdeny_bootreg_aclk_nic,
    output wire           qactive_bootreg_aclk_nic, 
    
    input wire            qreqn_bootreg_aclk_adb,
    output wire           qacceptn_bootreg_aclk_adb,
    output wire           qdeny_bootreg_aclk_adb,
    output wire           qactive_bootreg_aclk_adb,     

    input wire            qreqn_bootreg_pwr,
    output wire           qacceptn_bootreg_pwr,
    output wire           qdeny_bootreg_pwr,
    output wire           qactive_bootreg_pwr,    
    
    output wire           apb_async_req_bootreg,
    output wire [61:0]    apb_async_req_payload_bootreg,
    input  wire [32:0]    apb_async_resp_payload_bootreg,
    input  wire           apb_async_ack_bootreg,
    
    input  wire           dftcgen
  );

  
  wire [25:0]    paddr;
  wire [31:0]    pwdata;
  wire           pwrite;
  wire           psel;
  wire           penable;
  wire [2:0]     pprot;
  wire [3:0]     pstrb;
  wire [31:0]    prdata;
  wire           pready;    
  wire           pslverr; 
  
  wire [31:0]    awaddr_bootreg_int;  
  wire [31:0]    araddr_bootreg_int;  
  
  wire           unused;
  wire [9:0]     unused_paddr;
  

  assign awaddr_bootreg_int = {12'h000, awuser_bootreg_axim[9:2], awaddr_bootreg_axim[11:0]};
 
  assign araddr_bootreg_int = {10'h000, arsize_bootreg_axim[1:0] , 8'h00, araddr_bootreg_axim[11:0]};
 
  nic400_sse710_boot_reg u_nic400_sse710_boot_reg (

    .paddr_master_if0            ({unused_paddr, paddr[21:0]}),
    .pwdata_master_if0           (pwdata),
    .pprot_master_if0            (pprot),
    .pstrb_master_if0            (pstrb),
    .pwrite_master_if0           (pwrite),
    .penable_master_if0          (penable),
    .pselx_master_if0            (psel),
    .prdata_master_if0           (prdata),
    .pslverr_master_if0          (pslverr),
    .pready_master_if0           (pready),
  
    .awid_slave_if0_0_m_s        (awid_bootreg_axim),
    .awaddr_slave_if0_0_m_s      (awaddr_bootreg_int),
    .awlen_slave_if0_0_m_s       (awlen_bootreg_axim),
    .awsize_slave_if0_0_m_s      (awsize_bootreg_axim),
    .awburst_slave_if0_0_m_s     (awburst_bootreg_axim),
    .awlock_slave_if0_0_m_s      (awlock_bootreg_axim),
    .awcache_slave_if0_0_m_s     (awcache_bootreg_axim),
    .awprot_slave_if0_0_m_s      (awprot_bootreg_axim),
    .awvalid_slave_if0_0_m_s     (awvalid_bootreg_axim),
    .awready_slave_if0_0_m_s     (awready_bootreg_axim),
    .wdata_slave_if0_0_m_s       (wdata_bootreg_axim),
    .wstrb_slave_if0_0_m_s       (wstrb_bootreg_axim),
    .wlast_slave_if0_0_m_s       (wlast_bootreg_axim),
    .wvalid_slave_if0_0_m_s      (wvalid_bootreg_axim),
    .wready_slave_if0_0_m_s      (wready_bootreg_axim),
    .bid_slave_if0_0_m_s         (bid_bootreg_axim),
    .bresp_slave_if0_0_m_s       (bresp_bootreg_axim),
    .bvalid_slave_if0_0_m_s      (bvalid_bootreg_axim),
    .bready_slave_if0_0_m_s      (bready_bootreg_axim),
    .arid_slave_if0_0_m_s        (arid_bootreg_axim),
    .araddr_slave_if0_0_m_s      (araddr_bootreg_int),
    .arlen_slave_if0_0_m_s       (arlen_bootreg_axim),
    .arsize_slave_if0_0_m_s      (arsize_bootreg_axim),
    .arburst_slave_if0_0_m_s     (arburst_bootreg_axim),
    .arlock_slave_if0_0_m_s      (arlock_bootreg_axim),
    .arcache_slave_if0_0_m_s     (arcache_bootreg_axim),
    .arprot_slave_if0_0_m_s      (arprot_bootreg_axim),
    .arvalid_slave_if0_0_m_s     (arvalid_bootreg_axim),
    .arready_slave_if0_0_m_s     (arready_bootreg_axim),
    .rid_slave_if0_0_m_s         (rid_bootreg_axim),
    .rdata_slave_if0_0_m_s       (rdata_bootreg_axim),
    .rresp_slave_if0_0_m_s       (rresp_bootreg_axim),
    .rlast_slave_if0_0_m_s       (rlast_bootreg_axim),
    .rvalid_slave_if0_0_m_s      (rvalid_bootreg_axim),
    .rready_slave_if0_0_m_s      (rready_bootreg_axim),

    .csysreq_cd_clk1             (qreqn_bootreg_aclk_nic),
    .csysack_cd_clk1             (qacceptn_bootreg_aclk_nic),
    .cactive_cd_clk1             (qactive_bootreg_aclk_nic),

    .clk0clk                     (aclk),
    .clk0resetn                  (aresetn),
    .clk1clk                     (aclk),
    .clk1clken                   (1'b1),
    .clk1resetn                  (aresetn)
    );
  
  assign qdeny_bootreg_aclk_nic = 1'b0;
  

  assign paddr[25:22] = pstrb;
  
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (26),
    .FF_SYNC_DEPTH       (2)
  ) u_css600_apbasyncbridgeslv (
    .clk_s                      (aclk),
    .reset_s_n                  (aresetn),
    .dftcgen                    (dftcgen),
    .psel_s                     (psel),
    .penable_s                  (penable),
    .paddr_s                    (paddr),
    .pwrite_s                   (pwrite),
    .pwdata_s                   (pwdata),
    .pprot_s                    (pprot),
    .prdata_s                   (prdata),
    .pready_s                   (pready),
    .pslverr_s                  (pslverr),
    .pwakeup_s                  (psel),                   
    .clk_s_qreq_n               (qreqn_bootreg_aclk_adb), 
    .clk_s_qaccept_n            (qacceptn_bootreg_aclk_adb),                                                                                                            
    .clk_s_qdeny                (qdeny_bootreg_aclk_adb),                                                                                                             
    .clk_s_qactive              (qactive_bootreg_aclk_adb),                                                                                                             
    .pwr_qreq_n                 (qreqn_bootreg_pwr),
    .pwr_qaccept_n              (qacceptn_bootreg_pwr),
    .pwr_qdeny                  (qdeny_bootreg_pwr),
    .pwr_qactive                (qactive_bootreg_pwr),
    .apb_async_req              (apb_async_req_bootreg),
    .apb_async_req_payload      (apb_async_req_payload_bootreg), 
    .apb_async_resp_payload     (apb_async_resp_payload_bootreg),
    .apb_async_ack              (apb_async_ack_bootreg)          
  );  
  

  assign unused = (|aruser_bootreg_axim)        |
                  (|awuser_bootreg_axim[1:0])   |
                  (|awaddr_bootreg_axim[39:12]) |
                  (|araddr_bootreg_axim[39:12]);
  
endmodule
