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


module pd_extsys0top_f0 #(
  
  parameter  MHU_HESX0_NUM_CH             = 7'd2,  
  parameter  MHU_ESXH0_NUM_CH             = 7'd2,  
  parameter  MHU_SEESX0_NUM_CH            = 7'd2, 
  parameter  MHU_ESXSE0_NUM_CH            = 7'd2, 
  
   
  parameter  MHU_HESX1_NUM_CH             = 7'd2,  
  parameter  MHU_ESXH1_NUM_CH             = 7'd2,  
  parameter  MHU_SEESX1_NUM_CH            = 7'd2, 
  parameter  MHU_ESXSE1_NUM_CH            = 7'd2, 
   
  
  parameter  EXT_SYSX_MEM_ADDR_WIDTH       = 32,
  parameter  EXT_SYSX_MEM_DATA_WIDTH       = 64,
  parameter  EXT_SYSX_MEM_AWID_WIDTH       = 8,
  parameter  EXT_SYSX_MEM_ARID_WIDTH       = 8,
  parameter  EXT_SYSX_MEM_AWUSER_WIDTH     = 0,
  parameter  EXT_SYSX_MEM_WUSER_WIDTH      = 0,
  parameter  EXT_SYSX_MEM_BUSER_WIDTH      = 0,
  parameter  EXT_SYSX_MEM_ARUSER_WIDTH     = 0,
  parameter  EXT_SYSX_MEM_RUSER_WIDTH      = 0,
  parameter  EXT_SYSX_MEM_AW_FIFO_DEPTH    = 4,
  parameter  EXT_SYSX_MEM_W_FIFO_DEPTH     = 6,
  parameter  EXT_SYSX_MEM_B_FIFO_DEPTH     = 2,
  parameter  EXT_SYSX_MEM_AR_FIFO_DEPTH    = 4,
  parameter  EXT_SYSX_MEM_R_FIFO_DEPTH     = 6,
  parameter  EXT_SYSX_MEM_AW_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYSX_MEM_W_PAYLOAD_WIDTH  = 222,
  parameter  EXT_SYSX_MEM_B_PAYLOAD_WIDTH  = 24,
  parameter  EXT_SYSX_MEM_AR_PAYLOAD_WIDTH = 236,
  parameter  EXT_SYSX_MEM_R_PAYLOAD_WIDTH  = 264

)(

    input  wire                          extsysx_dbgclks,
    input  wire                          extsysx_dbgclkm,
    input  wire                          extsysx_atclk,
    input  wire                          extsysx_cticlk,
    input  wire                          extsysx_aclk,
    input  wire                          extsysx_mhuclk,

    input  wire                          extsysx_dbgpresetsn,
    input  wire                          extsysx_dbgpresetmn,
    input  wire                          extsysx_atresetn,
    input  wire                          extsysx_ctiresetn,
    input  wire                          extsysx_aresetn,
    input  wire                          extsysx_mhuresetn,

    input  wire                                  awakeup_extsysx_mem,
    input  wire [EXT_SYSX_MEM_AWID_WIDTH-1:0]     awid_extsysx_mem,
    input  wire [31:0]                           awaddr_extsysx_mem,
    input  wire [7:0]                            awlen_extsysx_mem,
    input  wire [2:0]                            awsize_extsysx_mem,
    input  wire [1:0]                            awburst_extsysx_mem,
    input  wire                                  awlock_extsysx_mem,
    input  wire [3:0]                            awcache_extsysx_mem,
    input  wire [2:0]                            awprot_extsysx_mem,
    input  wire [3:0]                            awregion_extsysx_mem,
    input  wire                                  awvalid_extsysx_mem,
    output wire                                  awready_extsysx_mem,
    input  wire [(EXT_SYSX_MEM_DATA_WIDTH/8)-1:0] wstrb_extsysx_mem,
    input  wire                                  wlast_extsysx_mem,
    input  wire                                  wvalid_extsysx_mem,
    input  wire [EXT_SYSX_MEM_DATA_WIDTH-1:0]     wdata_extsysx_mem,
    output wire                                  wready_extsysx_mem,
    output wire [EXT_SYSX_MEM_AWID_WIDTH-1:0]     bid_extsysx_mem,
    output wire [1:0]                            bresp_extsysx_mem,
    output wire                                  bvalid_extsysx_mem,
    input  wire                                  bready_extsysx_mem,
    input  wire [EXT_SYSX_MEM_ARID_WIDTH-1:0]     arid_extsysx_mem,
    input  wire [31:0]                           araddr_extsysx_mem,
    input  wire [7:0]                            arlen_extsysx_mem,
    input  wire [2:0]                            arsize_extsysx_mem,
    input  wire [1:0]                            arburst_extsysx_mem,
    input  wire                                  arlock_extsysx_mem,
    input  wire [3:0]                            arcache_extsysx_mem,
    input  wire [2:0]                            arprot_extsysx_mem,
    input  wire [3:0]                            arregion_extsysx_mem,
    input  wire                                  arvalid_extsysx_mem,
    output wire                                  arready_extsysx_mem,
    output wire [EXT_SYSX_MEM_ARID_WIDTH-1:0]     rid_extsysx_mem,
    output wire [1:0]                            rresp_extsysx_mem,
    output wire                                  rlast_extsysx_mem,
    output wire                                  rvalid_extsysx_mem,
    output wire [EXT_SYSX_MEM_DATA_WIDTH-1:0]     rdata_extsysx_mem,
    input  wire                                  rready_extsysx_mem,

    input  wire                          pwakeup_extsysx_mhu,
    input  wire                          psel_extsysx_mhu,
    input  wire                          penable_extsysx_mhu,
    input  wire [18:0]                   paddr_extsysx_mhu,
    input  wire                          pwrite_extsysx_mhu,
    input  wire [31:0]                   pwdata_extsysx_mhu,
    input  wire [3:0]                    pstrb_extsysx_mhu,
    input  wire [2:0]                    pprot_extsysx_mhu,
    output wire [31:0]                   prdata_extsysx_mhu,
    output wire                          pready_extsysx_mhu,
    output wire                          pslverr_extsysx_mhu,

    output wire                          esh0_extsysx_mhuint,
    output wire                          hes0_extsysx_mhuint,
    output wire                          esse0_extsysx_mhuint,
    output wire                          sees0_extsysx_mhuint,
    
 
    output wire                          esh1_extsysx_mhuint,
    output wire                          hes1_extsysx_mhuint,
    output wire                          esse1_extsysx_mhuint,
    output wire                          sees1_extsysx_mhuint,    
 

    output wire                          atready_extsysx_traceexp,
    output wire                          afvalid_extsysx_traceexp,
    output wire                          syncreq_extsysx_traceexp,
    input  wire [6:0]                    atid_extsysx_traceexp,
    input  wire                          atvalid_extsysx_traceexp,
    input  wire [31:0]                   atdata_extsysx_traceexp,
    input  wire [1:0]                    atbytes_extsysx_traceexp,
    input  wire                          afready_extsysx_traceexp,
    input  wire                          atwakeup_extsysx_traceexp,

    output wire                          psel_extsysx_dbg,
    output wire                          pwakeup_extsysx_dbg,
    output wire                          penable_extsysx_dbg,
    output wire [31:0]                   paddr_extsysx_dbg,
    output wire                          pwrite_extsysx_dbg,
    output wire [31:0]                   pwdata_extsysx_dbg,
    output wire [3:0]                    pstrb_extsysx_dbg,
    output wire [2:0]                    pprot_extsysx_dbg,
    input  wire [31:0]                   prdata_extsysx_dbg,
    input  wire                          pready_extsysx_dbg,
    input  wire                          pslverr_extsysx_dbg,

    output wire                          dpabort_extsysx_dbg,

    input  wire                          psel_extsysx_extdbg,
    input  wire                          pwakeup_extsysx_extdbg,
    input  wire                          penable_extsysx_extdbg,
    input  wire [31:0]                   paddr_extsysx_extdbg,
    input  wire                          pwrite_extsysx_extdbg,
    input  wire [31:0]                   pwdata_extsysx_extdbg,
    input  wire [3:0]                    pstrb_extsysx_extdbg,
    input  wire [2:0]                    pprot_extsysx_extdbg,
    output wire [31:0]                   prdata_extsysx_extdbg,
    output wire                          pready_extsysx_extdbg,
    output wire                          pslverr_extsysx_extdbg,

    input  wire [3:0]                    extsysx_ctichin,

    output wire [3:0]                    extsysx_ctichout,

    input  wire                          qreqn_extsysx_aclk,
    output wire                          qacceptn_extsysx_aclk,
    output wire                          qdeny_extsysx_aclk,
    output wire                          qactive_extsysx_aclk,

    input  wire                          qreqn_extsysx_mhuclk,
    output wire                          qacceptn_extsysx_mhuclk,
    output wire                          qdeny_extsysx_mhuclk,
    output wire                          qactive_extsysx_mhuclk,

    input  wire                          qreqn_extsysx_atclk,
    output wire                          qacceptn_extsysx_atclk,
    output wire                          qdeny_extsysx_atclk,
    output wire                          qactive_extsysx_atclk,

    input  wire                          qreqn_extsysx_dbgclkm,
    output wire                          qacceptn_extsysx_dbgclkm,
    output wire                          qdeny_extsysx_dbgclkm,
    output wire                          qactive_extsysx_dbgclkm,

    input  wire                          qreqn_extsysx_dbgclks,
    output wire                          qacceptn_extsysx_dbgclks,
    output wire                          qdeny_extsysx_dbgclks,
    output wire                          qactive_extsysx_dbgclks,

    input  wire                          qreqn_extsysx_cticlk,
    output wire                          qacceptn_extsysx_cticlk,
    output wire                          qdeny_extsysx_cticlk,
    output wire                          qactive_extsysx_cticlk,

    input  wire                          qreqn_extsysx_mempwr,
    output wire                          qacceptn_extsysx_mempwr,
    output wire                          qdeny_extsysx_mempwr,
    output wire                          qactive_extsysx_mempwr,

    input  wire                          qreqn_extsysx_mhupwr,
    output wire                          qacceptn_extsysx_mhupwr,
    output wire                          qdeny_extsysx_mhupwr,

    input  wire                          qreqn_extsysx_traceexppwr,
    output wire                          qacceptn_extsysx_traceexppwr,
    output wire                          qdeny_extsysx_traceexppwr,
    output wire                          qactive_extsysx_traceexppwr,

    input  wire                          qreqn_extsysx_extdbgpwr,
    output wire                          qacceptn_extsysx_extdbgpwr,
    output wire                          qdeny_extsysx_extdbgpwr,
    output wire                          qactive_extsysx_extdbgpwr,

    input  wire                          qreqn_extsysx_ctiinpwr,
    output wire                          qacceptn_extsysx_ctiinpwr,
    output wire                          qdeny_extsysx_ctiinpwr,
    output wire                          qactive_extsysx_ctiinpwr,


    output wire                          apb_async_req_ehx_mhu_esh_0,
    output wire [48:0]                   apb_async_req_payload_ehx_mhu_esh_0,
    input  wire [32:0]                   apb_async_resp_payload_ehx_mhu_esh_0,
    input  wire                          apb_async_ack_ehx_mhu_esh_0,
    input  wire                          recawake_async_ehx_mhu_esh_0,
    output wire                          recwakeup_async_ehx_mhu_esh_0,
    input  wire [MHU_ESXH0_NUM_CH-1:0]   edge_async_req_ehx_mhu_esh_0,
    output wire [MHU_ESXH0_NUM_CH-1:0]   edge_async_ack_ehx_mhu_esh_0,

    input  wire                          apb_async_req_ehx_mhu_hes_0,
    input  wire [48:0]                   apb_async_req_payload_ehx_mhu_hes_0,
    output wire [32:0]                   apb_async_resp_payload_ehx_mhu_hes_0,
    output wire                          apb_async_ack_ehx_mhu_hes_0,
    output wire                          recawake_async_ehx_mhu_hes_0,
    input  wire                          recwakeup_async_ehx_mhu_hes_0,
    output wire [MHU_HESX0_NUM_CH-1:0]   edge_async_req_ehx_mhu_hes_0,
    input  wire [MHU_HESX0_NUM_CH-1:0]   edge_async_ack_ehx_mhu_hes_0,

 
    output wire                          apb_async_req_ehx_mhu_esh_1,
    output wire [48:0]                   apb_async_req_payload_ehx_mhu_esh_1,
    input  wire [32:0]                   apb_async_resp_payload_ehx_mhu_esh_1,
    input  wire                          apb_async_ack_ehx_mhu_esh_1,
    input  wire                          recawake_async_ehx_mhu_esh_1,
    output wire                          recwakeup_async_ehx_mhu_esh_1,
    input  wire [MHU_ESXH1_NUM_CH-1:0]   edge_async_req_ehx_mhu_esh_1,
    output wire [MHU_ESXH1_NUM_CH-1:0]   edge_async_ack_ehx_mhu_esh_1,

    input  wire                          apb_async_req_ehx_mhu_hes_1,
    input  wire [48:0]                   apb_async_req_payload_ehx_mhu_hes_1,
    output wire [32:0]                   apb_async_resp_payload_ehx_mhu_hes_1,
    output wire                          apb_async_ack_ehx_mhu_hes_1,
    output wire                          recawake_async_ehx_mhu_hes_1,
    input  wire                          recwakeup_async_ehx_mhu_hes_1,
    output wire [MHU_HESX1_NUM_CH-1:0]   edge_async_req_ehx_mhu_hes_1,
    input  wire [MHU_HESX1_NUM_CH-1:0]   edge_async_ack_ehx_mhu_hes_1,
 
    
    output wire                          apb_async_req_ehx_mhu_esse_0,
    output wire [48:0]                   apb_async_req_payload_ehx_mhu_esse_0,
    input  wire [32:0]                   apb_async_resp_payload_ehx_mhu_esse_0,
    input  wire                          apb_async_ack_ehx_mhu_esse_0,
    input  wire                          recawake_async_ehx_mhu_esse_0,
    output wire                          recwakeup_async_ehx_mhu_esse_0,
    input  wire [MHU_ESXSE0_NUM_CH-1:0]  edge_async_req_ehx_mhu_esse_0,
    output wire [MHU_ESXSE0_NUM_CH-1:0]  edge_async_ack_ehx_mhu_esse_0,

    input  wire                          apb_async_req_ehx_mhu_sees_0,
    input  wire [48:0]                   apb_async_req_payload_ehx_mhu_sees_0,
    output wire [32:0]                   apb_async_resp_payload_ehx_mhu_sees_0,
    output wire                          apb_async_ack_ehx_mhu_sees_0,
    output wire                          recawake_async_ehx_mhu_sees_0,
    input  wire                          recwakeup_async_ehx_mhu_sees_0,
    output wire [MHU_SEESX0_NUM_CH-1:0]  edge_async_req_ehx_mhu_sees_0,
    input  wire [MHU_SEESX0_NUM_CH-1:0]  edge_async_ack_ehx_mhu_sees_0,

 
    output wire                          apb_async_req_ehx_mhu_esse_1,
    output wire [48:0]                   apb_async_req_payload_ehx_mhu_esse_1,
    input  wire [32:0]                   apb_async_resp_payload_ehx_mhu_esse_1,
    input  wire                          apb_async_ack_ehx_mhu_esse_1,
    input  wire                          recawake_async_ehx_mhu_esse_1,
    output wire                          recwakeup_async_ehx_mhu_esse_1,
    input  wire [MHU_ESXSE1_NUM_CH-1:0]  edge_async_req_ehx_mhu_esse_1,
    output wire [MHU_ESXSE1_NUM_CH-1:0]  edge_async_ack_ehx_mhu_esse_1,

    input  wire                          apb_async_req_ehx_mhu_sees_1,
    input  wire [48:0]                   apb_async_req_payload_ehx_mhu_sees_1,
    output wire [32:0]                   apb_async_resp_payload_ehx_mhu_sees_1,
    output wire                          apb_async_ack_ehx_mhu_sees_1,
    output wire                          recawake_async_ehx_mhu_sees_1,
    input  wire                          recwakeup_async_ehx_mhu_sees_1,
    output wire [MHU_SEESX1_NUM_CH-1:0]  edge_async_req_ehx_mhu_sees_1,
    input  wire [MHU_SEESX1_NUM_CH-1:0]  edge_async_ack_ehx_mhu_sees_1,        
 

    output wire                                     slvmustacceptreqn_async_ehx,
    output wire                                     slvcandenyreqn_async_ehx,
    input  wire                                     slvacceptn_async_ehx,
    input  wire                                     slvdeny_async_ehx,
    output wire                                     si_to_mi_wakeup_async_ehx,
    input  wire                                     mi_to_si_wakeup_async_ehx,
    output wire [EXT_SYSX_MEM_AW_FIFO_DEPTH-1:0]     aw_wr_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_AW_FIFO_DEPTH-1:0]     aw_rd_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_AW_PAYLOAD_WIDTH-1:0]  aw_payld_async_ehx,
    output wire [EXT_SYSX_MEM_W_FIFO_DEPTH-1:0]      w_wr_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_W_FIFO_DEPTH-1:0]      w_rd_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_W_PAYLOAD_WIDTH-1:0]   w_payld_async_ehx,
    input  wire [EXT_SYSX_MEM_B_FIFO_DEPTH-1:0]      b_wr_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_B_FIFO_DEPTH-1:0]      b_rd_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_B_PAYLOAD_WIDTH-1:0]   b_payld_async_ehx,
    output wire [EXT_SYSX_MEM_AR_FIFO_DEPTH-1:0]     ar_wr_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_AR_FIFO_DEPTH-1:0]     ar_rd_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_AR_PAYLOAD_WIDTH-1:0]  ar_payld_async_ehx,
    input  wire [EXT_SYSX_MEM_R_FIFO_DEPTH-1:0]      r_wr_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_R_FIFO_DEPTH-1:0]      r_rd_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_R_PAYLOAD_WIDTH-1:0]   r_payld_async_ehx,


    input  wire [3:0]                    pulse_req_ehx_cti_out,
    output wire [3:0]                    pulse_ack_ehx_cti_out,

    input  wire [3:0]                    pulse_ack_ehx_cti_in,
    output wire [3:0]                    pulse_req_ehx_cti_in,

    input  wire [3:0]                    rd_pointer_gray_ehx,
    input  wire                          flush_req_ehx,
    input  wire                          sync_done_ehx,
    input  wire                          syncreq_async_req_ehx,
    output wire                          flush_done_ehx,
    output wire                          sync_clear_ehx,
    output wire [3:0]                    wr_pointer_gray_ehx,
    output wire [245:0]                  atb_fwd_data_ehx,
    output wire                          syncreq_async_ack_ehx,

    output wire                          apb_async_req_ehx_extdbg,
    output wire [67:0]                   apb_async_req_payload_ehx_extdbg,
    input  wire [32:0]                   apb_async_resp_payload_ehx_extdbg,
    input  wire                          apb_async_ack_ehx_extdbg,

    input  wire                          apb_async_req_ehx_dbg,
    input  wire [67:0]                   apb_async_req_payload_ehx_dbg,
    output wire [32:0]                   apb_async_resp_payload_ehx_dbg,
    output wire                          apb_async_ack_ehx_dbg,

    input  wire                          dpabort_pulse_req_ehx,
    output wire                          dpabort_pulse_ack_ehx,

    input  wire                          dftcgen,
    input  wire                          dftrstdisable
  );


  pc_eh_f0_extsysmhu #(
    .EXT_SYSX_TZ_SPT                       (1),
    .MHU_HESX0_NUM_CH                      (MHU_HESX0_NUM_CH),
    .MHU_ESXH0_NUM_CH                      (MHU_ESXH0_NUM_CH),
    .MHU_SEESX0_NUM_CH                     (MHU_SEESX0_NUM_CH),
    .MHU_ESXSE0_NUM_CH                     (MHU_ESXSE0_NUM_CH)
, 
    .MHU_HESX1_NUM_CH                      (MHU_HESX1_NUM_CH),
    .MHU_ESXH1_NUM_CH                      (MHU_ESXH1_NUM_CH),
    .MHU_SEESX1_NUM_CH                     (MHU_SEESX1_NUM_CH),
    .MHU_ESXSE1_NUM_CH                     (MHU_ESXSE1_NUM_CH)    
 
    
  ) u_pc_eh_f0_extsysmhu (
    .extsysx_mhuclk                        (extsysx_mhuclk),
    .extsysx_mhuresetn                     (extsysx_mhuresetn),

    .pwakeup_extsysx_mhu                   (pwakeup_extsysx_mhu),
    .psel_extsysx_mhu                      (psel_extsysx_mhu),
    .penable_extsysx_mhu                   (penable_extsysx_mhu),
    .paddr_extsysx_mhu                     (paddr_extsysx_mhu),
    .pwrite_extsysx_mhu                    (pwrite_extsysx_mhu),
    .pwdata_extsysx_mhu                    (pwdata_extsysx_mhu),
    .pstrb_extsysx_mhu                     (pstrb_extsysx_mhu),
    .pprot_extsysx_mhu                     (pprot_extsysx_mhu),
    .prdata_extsysx_mhu                    (prdata_extsysx_mhu),
    .pready_extsysx_mhu                    (pready_extsysx_mhu),
    .pslverr_extsysx_mhu                   (pslverr_extsysx_mhu),

    .esh0_extsysx_mhuint                   (esh0_extsysx_mhuint),
    .hes0_extsysx_mhuint                   (hes0_extsysx_mhuint),
    .esse0_extsysx_mhuint                  (esse0_extsysx_mhuint),
    .sees0_extsysx_mhuint                  (sees0_extsysx_mhuint),
 
    .esh1_extsysx_mhuint                   (esh1_extsysx_mhuint),
    .hes1_extsysx_mhuint                   (hes1_extsysx_mhuint),   
    .esse1_extsysx_mhuint                  (esse1_extsysx_mhuint),
    .sees1_extsysx_mhuint                  (sees1_extsysx_mhuint),    
  
    
    .qreqn_extsysx_mhuclk                  (qreqn_extsysx_mhuclk),
    .qacceptn_extsysx_mhuclk               (qacceptn_extsysx_mhuclk),
    .qdeny_extsysx_mhuclk                  (qdeny_extsysx_mhuclk),
    .qactive_extsysx_mhuclk                (qactive_extsysx_mhuclk),

    .qreqn_extsysx_mhupwr                  (qreqn_extsysx_mhupwr),
    .qacceptn_extsysx_mhupwr               (qacceptn_extsysx_mhupwr),
    .qdeny_extsysx_mhupwr                  (qdeny_extsysx_mhupwr),

    .apb_async_req_ehx_mhu_esh_0           (apb_async_req_ehx_mhu_esh_0),
    .apb_async_req_payload_ehx_mhu_esh_0   (apb_async_req_payload_ehx_mhu_esh_0),
    .apb_async_resp_payload_ehx_mhu_esh_0  (apb_async_resp_payload_ehx_mhu_esh_0),
    .apb_async_ack_ehx_mhu_esh_0           (apb_async_ack_ehx_mhu_esh_0),
    .recawake_async_ehx_mhu_esh_0          (recawake_async_ehx_mhu_esh_0),
    .recwakeup_async_ehx_mhu_esh_0         (recwakeup_async_ehx_mhu_esh_0),
    .edge_async_req_ehx_mhu_esh_0          (edge_async_req_ehx_mhu_esh_0),
    .edge_async_ack_ehx_mhu_esh_0          (edge_async_ack_ehx_mhu_esh_0),
    
    .apb_async_req_ehx_mhu_hes_0           (apb_async_req_ehx_mhu_hes_0),
    .apb_async_req_payload_ehx_mhu_hes_0   (apb_async_req_payload_ehx_mhu_hes_0),
    .apb_async_resp_payload_ehx_mhu_hes_0  (apb_async_resp_payload_ehx_mhu_hes_0),
    .apb_async_ack_ehx_mhu_hes_0           (apb_async_ack_ehx_mhu_hes_0),
    .recawake_async_ehx_mhu_hes_0          (recawake_async_ehx_mhu_hes_0),
    .recwakeup_async_ehx_mhu_hes_0         (recwakeup_async_ehx_mhu_hes_0),
    .edge_async_req_ehx_mhu_hes_0          (edge_async_req_ehx_mhu_hes_0),
    .edge_async_ack_ehx_mhu_hes_0          (edge_async_ack_ehx_mhu_hes_0),

     
    .apb_async_req_ehx_mhu_esh_1           (apb_async_req_ehx_mhu_esh_1),
    .apb_async_req_payload_ehx_mhu_esh_1   (apb_async_req_payload_ehx_mhu_esh_1),
    .apb_async_resp_payload_ehx_mhu_esh_1  (apb_async_resp_payload_ehx_mhu_esh_1),
    .apb_async_ack_ehx_mhu_esh_1           (apb_async_ack_ehx_mhu_esh_1),
    .recawake_async_ehx_mhu_esh_1          (recawake_async_ehx_mhu_esh_1),
    .recwakeup_async_ehx_mhu_esh_1         (recwakeup_async_ehx_mhu_esh_1),
    .edge_async_req_ehx_mhu_esh_1          (edge_async_req_ehx_mhu_esh_1),
    .edge_async_ack_ehx_mhu_esh_1          (edge_async_ack_ehx_mhu_esh_1),
    
    .apb_async_req_ehx_mhu_hes_1           (apb_async_req_ehx_mhu_hes_1),
    .apb_async_req_payload_ehx_mhu_hes_1   (apb_async_req_payload_ehx_mhu_hes_1),
    .apb_async_resp_payload_ehx_mhu_hes_1  (apb_async_resp_payload_ehx_mhu_hes_1),
    .apb_async_ack_ehx_mhu_hes_1           (apb_async_ack_ehx_mhu_hes_1),
    .recawake_async_ehx_mhu_hes_1          (recawake_async_ehx_mhu_hes_1),
    .recwakeup_async_ehx_mhu_hes_1         (recwakeup_async_ehx_mhu_hes_1),
    .edge_async_req_ehx_mhu_hes_1          (edge_async_req_ehx_mhu_hes_1),
    .edge_async_ack_ehx_mhu_hes_1          (edge_async_ack_ehx_mhu_hes_1),
  
    
    .apb_async_req_ehx_mhu_esse_0          (apb_async_req_ehx_mhu_esse_0),
    .apb_async_req_payload_ehx_mhu_esse_0  (apb_async_req_payload_ehx_mhu_esse_0),
    .apb_async_resp_payload_ehx_mhu_esse_0 (apb_async_resp_payload_ehx_mhu_esse_0),
    .apb_async_ack_ehx_mhu_esse_0          (apb_async_ack_ehx_mhu_esse_0),
    .recawake_async_ehx_mhu_esse_0         (recawake_async_ehx_mhu_esse_0),
    .recwakeup_async_ehx_mhu_esse_0        (recwakeup_async_ehx_mhu_esse_0),
    .edge_async_req_ehx_mhu_esse_0         (edge_async_req_ehx_mhu_esse_0),
    .edge_async_ack_ehx_mhu_esse_0         (edge_async_ack_ehx_mhu_esse_0),
    
    .apb_async_req_ehx_mhu_sees_0          (apb_async_req_ehx_mhu_sees_0),
    .apb_async_req_payload_ehx_mhu_sees_0  (apb_async_req_payload_ehx_mhu_sees_0),
    .apb_async_resp_payload_ehx_mhu_sees_0 (apb_async_resp_payload_ehx_mhu_sees_0),
    .apb_async_ack_ehx_mhu_sees_0          (apb_async_ack_ehx_mhu_sees_0),
    .recawake_async_ehx_mhu_sees_0         (recawake_async_ehx_mhu_sees_0),
    .recwakeup_async_ehx_mhu_sees_0        (recwakeup_async_ehx_mhu_sees_0),
    .edge_async_req_ehx_mhu_sees_0         (edge_async_req_ehx_mhu_sees_0),
    .edge_async_ack_ehx_mhu_sees_0         (edge_async_ack_ehx_mhu_sees_0),

        
    .apb_async_req_ehx_mhu_esse_1          (apb_async_req_ehx_mhu_esse_1),
    .apb_async_req_payload_ehx_mhu_esse_1  (apb_async_req_payload_ehx_mhu_esse_1),
    .apb_async_resp_payload_ehx_mhu_esse_1 (apb_async_resp_payload_ehx_mhu_esse_1),
    .apb_async_ack_ehx_mhu_esse_1          (apb_async_ack_ehx_mhu_esse_1),
    .recawake_async_ehx_mhu_esse_1         (recawake_async_ehx_mhu_esse_1),
    .recwakeup_async_ehx_mhu_esse_1        (recwakeup_async_ehx_mhu_esse_1),
    .edge_async_req_ehx_mhu_esse_1         (edge_async_req_ehx_mhu_esse_1),
    .edge_async_ack_ehx_mhu_esse_1         (edge_async_ack_ehx_mhu_esse_1),
    
    .apb_async_req_ehx_mhu_sees_1          (apb_async_req_ehx_mhu_sees_1),
    .apb_async_req_payload_ehx_mhu_sees_1  (apb_async_req_payload_ehx_mhu_sees_1),
    .apb_async_resp_payload_ehx_mhu_sees_1 (apb_async_resp_payload_ehx_mhu_sees_1),
    .apb_async_ack_ehx_mhu_sees_1          (apb_async_ack_ehx_mhu_sees_1),
    .recawake_async_ehx_mhu_sees_1         (recawake_async_ehx_mhu_sees_1),
    .recwakeup_async_ehx_mhu_sees_1        (recwakeup_async_ehx_mhu_sees_1),
    .edge_async_req_ehx_mhu_sees_1         (edge_async_req_ehx_mhu_sees_1),
    .edge_async_ack_ehx_mhu_sees_1         (edge_async_ack_ehx_mhu_sees_1),    
 
    .dftcgen                               (dftcgen)
  );

  pc_eh_f0_extsysmem #(
    .EXT_SYSX_MEM_ADDR_WIDTH            (EXT_SYSX_MEM_ADDR_WIDTH),
    .EXT_SYSX_MEM_DATA_WIDTH            (EXT_SYSX_MEM_DATA_WIDTH),
    .EXT_SYSX_MEM_AWID_WIDTH            (EXT_SYSX_MEM_AWID_WIDTH),
    .EXT_SYSX_MEM_ARID_WIDTH            (EXT_SYSX_MEM_ARID_WIDTH),
    .EXT_SYSX_MEM_AWUSER_WIDTH          (EXT_SYSX_MEM_AWUSER_WIDTH),
    .EXT_SYSX_MEM_WUSER_WIDTH           (EXT_SYSX_MEM_WUSER_WIDTH),
    .EXT_SYSX_MEM_BUSER_WIDTH           (EXT_SYSX_MEM_BUSER_WIDTH),
    .EXT_SYSX_MEM_ARUSER_WIDTH          (EXT_SYSX_MEM_ARUSER_WIDTH),
    .EXT_SYSX_MEM_RUSER_WIDTH           (EXT_SYSX_MEM_RUSER_WIDTH),
    .EXT_SYSX_MEM_AW_FIFO_DEPTH         (EXT_SYSX_MEM_AW_FIFO_DEPTH),
    .EXT_SYSX_MEM_W_FIFO_DEPTH          (EXT_SYSX_MEM_W_FIFO_DEPTH),
    .EXT_SYSX_MEM_B_FIFO_DEPTH          (EXT_SYSX_MEM_B_FIFO_DEPTH),
    .EXT_SYSX_MEM_AR_FIFO_DEPTH         (EXT_SYSX_MEM_AR_FIFO_DEPTH),
    .EXT_SYSX_MEM_R_FIFO_DEPTH          (EXT_SYSX_MEM_R_FIFO_DEPTH),
    .EXT_SYSX_MEM_AW_PAYLOAD_WIDTH      (EXT_SYSX_MEM_AW_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_W_PAYLOAD_WIDTH       (EXT_SYSX_MEM_W_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_B_PAYLOAD_WIDTH       (EXT_SYSX_MEM_B_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_AR_PAYLOAD_WIDTH      (EXT_SYSX_MEM_AR_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_R_PAYLOAD_WIDTH       (EXT_SYSX_MEM_R_PAYLOAD_WIDTH)

  ) u_pc_eh_f0_extsysmem (
    .extsysx_aclk                     (extsysx_aclk),
    .extsysx_aresetn                  (extsysx_aresetn),

    .awakeup_extsysx_mem              (awakeup_extsysx_mem),
    .awid_extsysx_mem                 (awid_extsysx_mem),
    .awaddr_extsysx_mem               (awaddr_extsysx_mem),
    .awlen_extsysx_mem                (awlen_extsysx_mem),
    .awsize_extsysx_mem               (awsize_extsysx_mem),
    .awburst_extsysx_mem              (awburst_extsysx_mem),
    .awlock_extsysx_mem               (awlock_extsysx_mem),
    .awcache_extsysx_mem              (awcache_extsysx_mem),
    .awprot_extsysx_mem               (awprot_extsysx_mem),
    .awregion_extsysx_mem             (awregion_extsysx_mem),
    .awvalid_extsysx_mem              (awvalid_extsysx_mem),
    .awready_extsysx_mem              (awready_extsysx_mem),
    .wstrb_extsysx_mem                (wstrb_extsysx_mem),
    .wlast_extsysx_mem                (wlast_extsysx_mem),
    .wvalid_extsysx_mem               (wvalid_extsysx_mem),
    .wdata_extsysx_mem                (wdata_extsysx_mem),
    .wready_extsysx_mem               (wready_extsysx_mem),
    .bid_extsysx_mem                  (bid_extsysx_mem),
    .bresp_extsysx_mem                (bresp_extsysx_mem),
    .bvalid_extsysx_mem               (bvalid_extsysx_mem),
    .bready_extsysx_mem               (bready_extsysx_mem),
    .arid_extsysx_mem                 (arid_extsysx_mem),
    .araddr_extsysx_mem               (araddr_extsysx_mem),
    .arlen_extsysx_mem                (arlen_extsysx_mem),
    .arsize_extsysx_mem               (arsize_extsysx_mem),
    .arburst_extsysx_mem              (arburst_extsysx_mem),
    .arlock_extsysx_mem               (arlock_extsysx_mem),
    .arcache_extsysx_mem              (arcache_extsysx_mem),
    .arprot_extsysx_mem               (arprot_extsysx_mem),
    .arregion_extsysx_mem             (arregion_extsysx_mem),
    .arvalid_extsysx_mem              (arvalid_extsysx_mem),
    .arready_extsysx_mem              (arready_extsysx_mem),
    .rid_extsysx_mem                  (rid_extsysx_mem),
    .rresp_extsysx_mem                (rresp_extsysx_mem),
    .rlast_extsysx_mem                (rlast_extsysx_mem),
    .rvalid_extsysx_mem               (rvalid_extsysx_mem),
    .rdata_extsysx_mem                (rdata_extsysx_mem),
    .rready_extsysx_mem               (rready_extsysx_mem),

    .qreqn_extsysx_aclk               (qreqn_extsysx_aclk),
    .qacceptn_extsysx_aclk            (qacceptn_extsysx_aclk),
    .qdeny_extsysx_aclk               (qdeny_extsysx_aclk),
    .qactive_extsysx_aclk             (qactive_extsysx_aclk),

    .qreqn_extsysx_mempwr             (qreqn_extsysx_mempwr),
    .qacceptn_extsysx_mempwr          (qacceptn_extsysx_mempwr),
    .qdeny_extsysx_mempwr             (qdeny_extsysx_mempwr),
    .qactive_extsysx_mempwr           (qactive_extsysx_mempwr),

    .slvmustacceptreqn_async_ehx      (slvmustacceptreqn_async_ehx),
    .slvcandenyreqn_async_ehx         (slvcandenyreqn_async_ehx),
    .slvacceptn_async_ehx             (slvacceptn_async_ehx),
    .slvdeny_async_ehx                (slvdeny_async_ehx),
    .si_to_mi_wakeup_async_ehx        (si_to_mi_wakeup_async_ehx),
    .mi_to_si_wakeup_async_ehx        (mi_to_si_wakeup_async_ehx),
    .aw_wr_ptr_async_ehx              (aw_wr_ptr_async_ehx),
    .aw_rd_ptr_async_ehx              (aw_rd_ptr_async_ehx),
    .aw_payld_async_ehx               (aw_payld_async_ehx),
    .w_wr_ptr_async_ehx               (w_wr_ptr_async_ehx),
    .w_rd_ptr_async_ehx               (w_rd_ptr_async_ehx),
    .w_payld_async_ehx                (w_payld_async_ehx),
    .b_wr_ptr_async_ehx               (b_wr_ptr_async_ehx),
    .b_rd_ptr_async_ehx               (b_rd_ptr_async_ehx),
    .b_payld_async_ehx                (b_payld_async_ehx),
    .ar_wr_ptr_async_ehx              (ar_wr_ptr_async_ehx),
    .ar_rd_ptr_async_ehx              (ar_rd_ptr_async_ehx),
    .ar_payld_async_ehx               (ar_payld_async_ehx),
    .r_wr_ptr_async_ehx               (r_wr_ptr_async_ehx),
    .r_rd_ptr_async_ehx               (r_rd_ptr_async_ehx),
    .r_payld_async_ehx                (r_payld_async_ehx),

    .dftrstdisable                    (dftrstdisable)
  );

  pc_eh_f0_extsyscti u_pc_eh_f0_extsyscti (
    .extsysx_cticlk                  (extsysx_cticlk),
    .extsysx_ctiresetn               (extsysx_ctiresetn),

    .extsysx_ctichin                 (extsysx_ctichin),
    .extsysx_ctichout                (extsysx_ctichout),

    .qreqn_extsysx_cticlk            (qreqn_extsysx_cticlk),
    .qacceptn_extsysx_cticlk         (qacceptn_extsysx_cticlk),
    .qdeny_extsysx_cticlk            (qdeny_extsysx_cticlk),
    .qactive_extsysx_cticlk          (qactive_extsysx_cticlk),

    .qreqn_extsysx_ctiinpwr          (qreqn_extsysx_ctiinpwr),
    .qacceptn_extsysx_ctiinpwr       (qacceptn_extsysx_ctiinpwr),
    .qdeny_extsysx_ctiinpwr          (qdeny_extsysx_ctiinpwr),
    .qactive_extsysx_ctiinpwr        (qactive_extsysx_ctiinpwr),

    .pulse_req_ehx_cti_out           (pulse_req_ehx_cti_out),
    .pulse_ack_ehx_cti_out           (pulse_ack_ehx_cti_out),

    .pulse_ack_ehx_cti_in            (pulse_ack_ehx_cti_in),
    .pulse_req_ehx_cti_in            (pulse_req_ehx_cti_in)

  );

  pc_eh_f0_extsystrace u_pc_eh_f0_extsystrace (
    .extsysx_atclk                   (extsysx_atclk),
    .extsysx_atresetn                (extsysx_atresetn),

    .atready_extsysx_traceexp        (atready_extsysx_traceexp),
    .afvalid_extsysx_traceexp        (afvalid_extsysx_traceexp),
    .syncreq_extsysx_traceexp        (syncreq_extsysx_traceexp),
    .atid_extsysx_traceexp           (atid_extsysx_traceexp),
    .atvalid_extsysx_traceexp        (atvalid_extsysx_traceexp),
    .atdata_extsysx_traceexp         (atdata_extsysx_traceexp),
    .atbytes_extsysx_traceexp        (atbytes_extsysx_traceexp),
    .afready_extsysx_traceexp        (afready_extsysx_traceexp),
    .atwakeup_extsysx_traceexp       (atwakeup_extsysx_traceexp),

    .qreqn_extsysx_atclk             (qreqn_extsysx_atclk),
    .qacceptn_extsysx_atclk          (qacceptn_extsysx_atclk),
    .qdeny_extsysx_atclk             (qdeny_extsysx_atclk),
    .qactive_extsysx_atclk           (qactive_extsysx_atclk),

    .qreqn_extsysx_traceexppwr       (qreqn_extsysx_traceexppwr),
    .qacceptn_extsysx_traceexppwr    (qacceptn_extsysx_traceexppwr),
    .qdeny_extsysx_traceexppwr       (qdeny_extsysx_traceexppwr),
    .qactive_extsysx_traceexppwr     (qactive_extsysx_traceexppwr),

    .rd_pointer_gray_ehx             (rd_pointer_gray_ehx),
    .flush_req_ehx                   (flush_req_ehx),
    .sync_done_ehx                   (sync_done_ehx),
    .syncreq_async_req_ehx           (syncreq_async_req_ehx),
    .flush_done_ehx                  (flush_done_ehx),
    .sync_clear_ehx                  (sync_clear_ehx),
    .wr_pointer_gray_ehx             (wr_pointer_gray_ehx),
    .atb_fwd_data_ehx                (atb_fwd_data_ehx),
    .syncreq_async_ack_ehx           (syncreq_async_ack_ehx)
  );

  pc_eh_f0_extsysextdbg u_pc_eh_f0_extsysextdbg (
    .extsysx_dbgclks                      (extsysx_dbgclks),
    .extsysx_dbgpresetsn                  (extsysx_dbgpresetsn),

    .psel_extsysx_extdbg                  (psel_extsysx_extdbg),
    .pwakeup_extsysx_extdbg               (pwakeup_extsysx_extdbg),
    .penable_extsysx_extdbg               (penable_extsysx_extdbg),
    .paddr_extsysx_extdbg                 (paddr_extsysx_extdbg),
    .pwrite_extsysx_extdbg                (pwrite_extsysx_extdbg),
    .pwdata_extsysx_extdbg                (pwdata_extsysx_extdbg),
    .pstrb_extsysx_extdbg                 (pstrb_extsysx_extdbg),
    .pprot_extsysx_extdbg                 (pprot_extsysx_extdbg),
    .prdata_extsysx_extdbg                (prdata_extsysx_extdbg),
    .pready_extsysx_extdbg                (pready_extsysx_extdbg),
    .pslverr_extsysx_extdbg               (pslverr_extsysx_extdbg),

    .qreqn_extsysx_dbgclks                (qreqn_extsysx_dbgclks),
    .qacceptn_extsysx_dbgclks             (qacceptn_extsysx_dbgclks),
    .qdeny_extsysx_dbgclks                (qdeny_extsysx_dbgclks),
    .qactive_extsysx_dbgclks              (qactive_extsysx_dbgclks),

    .qreqn_extsysx_extdbgpwr              (qreqn_extsysx_extdbgpwr),
    .qacceptn_extsysx_extdbgpwr           (qacceptn_extsysx_extdbgpwr),
    .qdeny_extsysx_extdbgpwr              (qdeny_extsysx_extdbgpwr),
    .qactive_extsysx_extdbgpwr            (qactive_extsysx_extdbgpwr),

    .apb_async_req_ehx_extdbg             (apb_async_req_ehx_extdbg),
    .apb_async_req_payload_ehx_extdbg     (apb_async_req_payload_ehx_extdbg),
    .apb_async_resp_payload_ehx_extdbg    (apb_async_resp_payload_ehx_extdbg),
    .apb_async_ack_ehx_extdbg             (apb_async_ack_ehx_extdbg),

    .dftcgen                              (dftcgen)
  );

  pc_eh_f0_extsysdbg  u_pc_eh_f0_extsysdbg (
    .extsysx_dbgclkm                   (extsysx_dbgclkm),
    .extsysx_dbgpresetmn               (extsysx_dbgpresetmn),

    .psel_extsysx_dbg                  (psel_extsysx_dbg),
    .pwakeup_extsysx_dbg               (pwakeup_extsysx_dbg),
    .penable_extsysx_dbg               (penable_extsysx_dbg),
    .paddr_extsysx_dbg                 (paddr_extsysx_dbg),
    .pwrite_extsysx_dbg                (pwrite_extsysx_dbg),
    .pwdata_extsysx_dbg                (pwdata_extsysx_dbg),
    .pstrb_extsysx_dbg                 (pstrb_extsysx_dbg),
    .pprot_extsysx_dbg                 (pprot_extsysx_dbg),
    .prdata_extsysx_dbg                (prdata_extsysx_dbg),
    .pready_extsysx_dbg                (pready_extsysx_dbg),
    .pslverr_extsysx_dbg               (pslverr_extsysx_dbg),

    .dpabort_extsysx_dbg               (dpabort_extsysx_dbg),

    .qreqn_extsysx_dbgclkm             (qreqn_extsysx_dbgclkm),
    .qacceptn_extsysx_dbgclkm          (qacceptn_extsysx_dbgclkm),
    .qdeny_extsysx_dbgclkm             (qdeny_extsysx_dbgclkm),
    .qactive_extsysx_dbgclkm           (qactive_extsysx_dbgclkm),

    .apb_async_req_ehx_dbg             (apb_async_req_ehx_dbg),
    .apb_async_req_payload_ehx_dbg     (apb_async_req_payload_ehx_dbg),
    .apb_async_resp_payload_ehx_dbg    (apb_async_resp_payload_ehx_dbg),
    .apb_async_ack_ehx_dbg             (apb_async_ack_ehx_dbg),

    .dpabort_pulse_req_ehx             (dpabort_pulse_req_ehx),
    .dpabort_pulse_ack_ehx             (dpabort_pulse_ack_ehx),

    .dftcgen                           (dftcgen)
  );

endmodule
