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

module pc_eh_f0_extsysmhu #(
  parameter  EXT_SYSX_TZ_SPT       = 0, 
  
  parameter  MHU_HESX0_NUM_CH      = 7'd2, 
  parameter  MHU_ESXH0_NUM_CH      = 7'd2, 
  parameter  MHU_HESX1_NUM_CH      = 7'd2, 
  parameter  MHU_ESXH1_NUM_CH      = 7'd2, 
  
  parameter  MHU_SEESX0_NUM_CH     = 7'd2, 
  parameter  MHU_ESXSE0_NUM_CH     = 7'd2, 
  parameter  MHU_SEESX1_NUM_CH     = 7'd2, 
  parameter  MHU_ESXSE1_NUM_CH     = 7'd2  
  )(
    input  wire                          extsysx_mhuclk,

    input  wire                          extsysx_mhuresetn,

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
    output wire                          esh1_extsysx_mhuint,
    output wire                          hes1_extsysx_mhuint,
    
    output wire                          esse0_extsysx_mhuint,
    output wire                          sees0_extsysx_mhuint,
    output wire                          esse1_extsysx_mhuint,
    output wire                          sees1_extsysx_mhuint,    

    input  wire                          qreqn_extsysx_mhuclk,
    output wire                          qacceptn_extsysx_mhuclk,
    output wire                          qdeny_extsysx_mhuclk,
    output wire                          qactive_extsysx_mhuclk,

    input  wire                          qreqn_extsysx_mhupwr,
    output wire                          qacceptn_extsysx_mhupwr,
    output wire                          qdeny_extsysx_mhupwr,

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

    input  wire                          dftcgen
    );

  wire [1:1]     config_checker_ext_sys_tz_spt;

  assign config_checker_ext_sys_tz_spt[((EXT_SYSX_TZ_SPT == 0) | (EXT_SYSX_TZ_SPT == 1))] = 1'b1;


  localparam     NONSEC_MASK = (EXT_SYSX_TZ_SPT == 0) ? 16'h0033 : 16'h00CC;
  localparam     CFG_NONSEC  = 16'h0000;

  localparam     NUM_CLK_QCH = (EXT_SYSX_TZ_SPT == 0) ? 5 : 9;
  
  localparam     NUM_PWR_QCH = (EXT_SYSX_TZ_SPT == 0) ? 2 : 4;  


  wire                       psel_ppc;
  wire                       penable_ppc;
  wire [18:0]                paddr_ppc;
  wire                       pwrite_ppc;
  wire [2:0]                 pprot_ppc;
  wire [31:0]                pwdata_ppc;
  wire [31:0]                prdata_ppc;
  wire                       pready_ppc;
  wire                       pslverr_ppc;

  wire                       psel_mhu_esxh_0;
  wire                       penable_mhu_esxh_0;
  wire [11:0]                paddr_mhu_esxh_0;
  wire                       pwrite_mhu_esxh_0;
  wire [31:0]                pwdata_mhu_esxh_0;
  wire [31:0]                prdata_mhu_esxh_0;
  wire                       pready_mhu_esxh_0;
  wire                       pslverr_mhu_esxh_0;

  wire                       psel_mhu_hesx_0;
  wire                       penable_mhu_hesx_0;
  wire [11:0]                paddr_mhu_hesx_0;
  wire                       pwrite_mhu_hesx_0;
  wire [31:0]                pwdata_mhu_hesx_0;
  wire [31:0]                prdata_mhu_hesx_0;
  wire                       pready_mhu_hesx_0;
  wire                       pslverr_mhu_hesx_0;

  wire                       psel_mhu_esxh_1;
  wire                       penable_mhu_esxh_1;
  wire [11:0]                paddr_mhu_esxh_1;
  wire                       pwrite_mhu_esxh_1;
  wire [31:0]                pwdata_mhu_esxh_1;
  wire [31:0]                prdata_mhu_esxh_1;
  wire                       pready_mhu_esxh_1;
  wire                       pslverr_mhu_esxh_1;

  wire                       psel_mhu_hesx_1;
  wire                       penable_mhu_hesx_1;
  wire [11:0]                paddr_mhu_hesx_1;
  wire                       pwrite_mhu_hesx_1;
  wire [31:0]                pwdata_mhu_hesx_1;
  wire [31:0]                prdata_mhu_hesx_1;
  wire                       pready_mhu_hesx_1;
  wire                       pslverr_mhu_hesx_1;
  
  wire                       psel_mhu_esxse_0;
  wire                       penable_mhu_esxse_0;
  wire [11:0]                paddr_mhu_esxse_0;
  wire                       pwrite_mhu_esxse_0;
  wire [31:0]                pwdata_mhu_esxse_0;
  wire [31:0]                prdata_mhu_esxse_0;
  wire                       pready_mhu_esxse_0;
  wire                       pslverr_mhu_esxse_0;

  wire                       psel_mhu_seesx_0;
  wire                       penable_mhu_seesx_0;
  wire [11:0]                paddr_mhu_seesx_0;
  wire                       pwrite_mhu_seesx_0;
  wire [31:0]                pwdata_mhu_seesx_0;
  wire [31:0]                prdata_mhu_seesx_0;
  wire                       pready_mhu_seesx_0;
  wire                       pslverr_mhu_seesx_0;

  wire                       psel_mhu_esxse_1;
  wire                       penable_mhu_esxse_1;
  wire [11:0]                paddr_mhu_esxse_1;
  wire                       pwrite_mhu_esxse_1;
  wire [31:0]                pwdata_mhu_esxse_1;
  wire [31:0]                prdata_mhu_esxse_1;
  wire                       pready_mhu_esxse_1;
  wire                       pslverr_mhu_esxse_1;

  wire                       psel_mhu_seesx_1;
  wire                       penable_mhu_seesx_1;
  wire [11:0]                paddr_mhu_seesx_1;
  wire                       pwrite_mhu_seesx_1;
  wire [31:0]                pwdata_mhu_seesx_1;
  wire [31:0]                prdata_mhu_seesx_1;
  wire                       pready_mhu_seesx_1;
  wire                       pslverr_mhu_seesx_1;

  wire                       qreqn_mhu_esxh_0_pclk_snd;
  wire                       qacceptn_mhu_esxh_0_pclk_snd;
  wire                       qdeny_mhu_esxh_0_pclk_snd;
  wire                       qactive_mhu_esxh_0_pclk_snd;

  wire                       qreqn_mhu_hesx_0_pclk_rec;
  wire                       qacceptn_mhu_hesx_0_pclk_rec;
  wire                       qdeny_mhu_hesx_0_pclk_rec;
  wire                       qactive_mhu_hesx_0_pclk_rec;

  wire                       qreqn_mhu_esxh_1_pclk_snd;
  wire                       qacceptn_mhu_esxh_1_pclk_snd;
  wire                       qdeny_mhu_esxh_1_pclk_snd;
  wire                       qactive_mhu_esxh_1_pclk_snd;

  wire                       qreqn_mhu_hesx_1_pclk_rec;
  wire                       qacceptn_mhu_hesx_1_pclk_rec;
  wire                       qdeny_mhu_hesx_1_pclk_rec;
  wire                       qactive_mhu_hesx_1_pclk_rec;
  
  wire                       qreqn_mhu_esxse_0_pclk_snd;
  wire                       qacceptn_mhu_esxse_0_pclk_snd;
  wire                       qdeny_mhu_esxse_0_pclk_snd;
  wire                       qactive_mhu_esxse_0_pclk_snd;

  wire                       qreqn_mhu_seesx_0_pclk_rec;
  wire                       qacceptn_mhu_seesx_0_pclk_rec;
  wire                       qdeny_mhu_seesx_0_pclk_rec;
  wire                       qactive_mhu_seesx_0_pclk_rec;
  
  wire                       qreqn_mhu_esxse_1_pclk_snd;
  wire                       qacceptn_mhu_esxse_1_pclk_snd;
  wire                       qdeny_mhu_esxse_1_pclk_snd;
  wire                       qactive_mhu_esxse_1_pclk_snd;

  wire                       qreqn_mhu_seesx_1_pclk_rec;
  wire                       qacceptn_mhu_seesx_1_pclk_rec;
  wire                       qdeny_mhu_seesx_1_pclk_rec;
  wire                       qactive_mhu_seesx_1_pclk_rec;  

  wire                       qreqn_apbic;
  wire                       qacceptn_apbic;
  wire                       qdeny_apbic;
  wire                       qactive_apbic;

  wire                       qreqn_mhu_hesx_0_pwr_rec;
  wire                       qacceptn_mhu_hesx_0_pwr_rec;
  wire                       qdeny_mhu_hesx_0_pwr_rec;

  wire                       qreqn_mhu_hesx_1_pwr_rec;
  wire                       qacceptn_mhu_hesx_1_pwr_rec;
  wire                       qdeny_mhu_hesx_1_pwr_rec;
  
  wire                       qreqn_mhu_seesx_0_pwr_rec;
  wire                       qacceptn_mhu_seesx_0_pwr_rec;
  wire                       qdeny_mhu_seesx_0_pwr_rec;

  wire                       qreqn_mhu_seesx_1_pwr_rec;
  wire                       qacceptn_mhu_seesx_1_pwr_rec;
  wire                       qdeny_mhu_seesx_1_pwr_rec;  

  wire [NUM_CLK_QCH - 1 : 0] qreqn_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qacceptn_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qdeny_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qactive_lpdq_clk;

  wire [NUM_PWR_QCH - 1 : 0] qreqn_lpdq_pwr;
  wire [NUM_PWR_QCH - 1 : 0] qacceptn_lpdq_pwr;
  wire [NUM_PWR_QCH - 1 : 0] qdeny_lpdq_pwr;
  wire [NUM_PWR_QCH - 1 : 0] qactive_lpdq_pwr;

  wire                       qactive_clk_lpdq_ctrl;
  wire                       qactive_pwr_lpdq_clk;

  wire [15:0]                psel_decode;

  wire                       unused;
  wire                       unused_mhu_esxh;
  wire                       unused_mhu_hesx;
  wire                       unused_mhu_esxse;
  wire                       unused_mhu_seesx;  



  css600_apbicdecoder #(
    .NUM_APB_SLAVES (1),
    .APB_SLAVE_ADDR_WIDTH (19),
    .NUM_APB_MASTERS(1),
    .NUM_EXPANDERS(1),
    .M0_ADDR_WIDTH(19)
    ) u_css600_apbicdecoder
  (
    .clk              (extsysx_mhuclk),
    .reset_n          (extsysx_mhuresetn),
    .pwakeup_s        (pwakeup_extsysx_mhu),
    .psel_s           (psel_extsysx_mhu   ),
    .penable_s        (penable_extsysx_mhu),
    .pwrite_s         (pwrite_extsysx_mhu ),
    .pprot_s          (pprot_extsysx_mhu  ),
    .paddr_s          (paddr_extsysx_mhu  ),
    .pwdata_s         (pwdata_extsysx_mhu ),
    .pready_s         (pready_extsysx_mhu ),
    .pslverr_s        (pslverr_extsysx_mhu),
    .prdata_s         (prdata_extsysx_mhu ),
    .pwakeup_e        (),
    .psel_e           (psel_ppc   ),
    .penable_e        (penable_ppc),
    .pwrite_e         (pwrite_ppc ),
    .pprot_e          (pprot_ppc  ),
    .paddr_e          (paddr_ppc  ),
    .pwdata_e         (pwdata_ppc ),
    .pready_e         (pready_ppc ),
    .pslverr_e        (pslverr_ppc),
    .prdata_e         (prdata_ppc ),
    .clk_qreq_n       (qreqn_apbic),
    .clk_qaccept_n    (qacceptn_apbic),
    .clk_qdeny        (qdeny_apbic),
    .clk_qactive      (qactive_apbic)
  );


  assign psel_decode = ((paddr_ppc[18:16] == 3'b000) & (paddr_ppc[15:12] == 4'h0)) ? {15'h0000, psel_ppc       } : 
                       ((paddr_ppc[18:16] == 3'b001) & (paddr_ppc[15:12] == 4'h0)) ? {14'h0000, psel_ppc, 1'h0 } : 
                       ((paddr_ppc[18:16] == 3'b010) & (paddr_ppc[15:12] == 4'h0)) ? {13'h0000, psel_ppc, 2'h0 } : 
                       ((paddr_ppc[18:16] == 3'b011) & (paddr_ppc[15:12] == 4'h0)) ? {12'h000 , psel_ppc, 3'h0 } : 
                       ((paddr_ppc[18:16] == 3'b100) & (paddr_ppc[15:12] == 4'h0)) ? {11'h000 , psel_ppc, 4'h0 } : 
                       ((paddr_ppc[18:16] == 3'b101) & (paddr_ppc[15:12] == 4'h0)) ? {10'h000 , psel_ppc, 5'h00} : 
                       ((paddr_ppc[18:16] == 3'b110) & (paddr_ppc[15:12] == 4'h0)) ? {9'h000  , psel_ppc, 6'h00} : 
                       ((paddr_ppc[18:16] == 3'b111) & (paddr_ppc[15:12] == 4'h0)) ? {8'h00   , psel_ppc, 7'h00} : 
                       16'h0100;                                                                                   

  sie200_apb_periph_prot #(
    .PORT0_ENABLE  (1),
    .PORT1_ENABLE  (1),
    .PORT2_ENABLE  (1),
    .PORT3_ENABLE  (1),
    .PORT4_ENABLE  (1),
    .PORT5_ENABLE  (1),
    .PORT6_ENABLE  (1),
    .PORT7_ENABLE  (1),
    .PORT8_ENABLE  (1),
    .PORT9_ENABLE  (0),
    .PORT10_ENABLE (0),
    .PORT11_ENABLE (0),
    .PORT12_ENABLE (0),
    .PORT13_ENABLE (0),
    .PORT14_ENABLE (0),
    .PORT15_ENABLE (0),
    .ADDR_WIDTH    (12),
    .DATA_WIDTH    (32),
    .NONSEC_MASK   (NONSEC_MASK)
    ) u_sie200_apb_periph_prot (
    .pclk                (extsysx_mhuclk),
    .presetn             (extsysx_mhuresetn),

    .cfg_ap              (16'hFFFF),
    .cfg_nonsec          (CFG_NONSEC),
    .cfg_sec_resp        (1'b1), 

    .apb_ppc_irq         (),
    .apb_ppc_irq_clear   (1'b0),
    .apb_ppc_irq_enable  (1'b0),

    .psel_s              (psel_decode),
    .paddr_s             (paddr_ppc[11:0]),
    .pstrb_s             (4'hF),
    .pwrite_s            (pwrite_ppc),
    .penable_s           (penable_ppc),
    .pprot_s             (pprot_ppc),
    .pwdata_s            (pwdata_ppc),
    .prdata_s            (prdata_ppc),
    .pready_s            (pready_ppc),
    .pslverr_s           (pslverr_ppc),

    .psel_m0             (psel_mhu_hesx_0),
    .paddr_m0            (paddr_mhu_hesx_0),
    .pstrb_m0            (),
    .pwrite_m0           (pwrite_mhu_hesx_0),
    .penable_m0          (penable_mhu_hesx_0),
    .pprot_m0            (),
    .pwdata_m0           (pwdata_mhu_hesx_0),
    .prdata_m0           (prdata_mhu_hesx_0),
    .pready_m0           (pready_mhu_hesx_0),
    .pslverr_m0          (pslverr_mhu_hesx_0),

    .psel_m1             (psel_mhu_esxh_0),
    .paddr_m1            (paddr_mhu_esxh_0),
    .pstrb_m1            (),
    .pwrite_m1           (pwrite_mhu_esxh_0),
    .penable_m1          (penable_mhu_esxh_0),
    .pprot_m1            (),
    .pwdata_m1           (pwdata_mhu_esxh_0),
    .prdata_m1           (prdata_mhu_esxh_0),
    .pready_m1           (pready_mhu_esxh_0),
    .pslverr_m1          (pslverr_mhu_esxh_0),

    .psel_m2             (psel_mhu_hesx_1),
    .paddr_m2            (paddr_mhu_hesx_1),
    .pstrb_m2            (),
    .pwrite_m2           (pwrite_mhu_hesx_1),
    .penable_m2          (penable_mhu_hesx_1),
    .pprot_m2            (),
    .pwdata_m2           (pwdata_mhu_hesx_1),
    .prdata_m2           (prdata_mhu_hesx_1),
    .pready_m2           (pready_mhu_hesx_1),
    .pslverr_m2          (pslverr_mhu_hesx_1),

    .psel_m3             (psel_mhu_esxh_1),
    .paddr_m3            (paddr_mhu_esxh_1),
    .pstrb_m3            (),
    .pwrite_m3           (pwrite_mhu_esxh_1),
    .penable_m3          (penable_mhu_esxh_1),
    .pprot_m3            (),
    .pwdata_m3           (pwdata_mhu_esxh_1),
    .prdata_m3           (prdata_mhu_esxh_1),
    .pready_m3           (pready_mhu_esxh_1),
    .pslverr_m3          (pslverr_mhu_esxh_1),

    .psel_m4             (psel_mhu_seesx_0),
    .paddr_m4            (paddr_mhu_seesx_0),
    .pstrb_m4            (),
    .pwrite_m4           (pwrite_mhu_seesx_0),
    .penable_m4          (penable_mhu_seesx_0),
    .pprot_m4            (),
    .pwdata_m4           (pwdata_mhu_seesx_0),
    .prdata_m4           (prdata_mhu_seesx_0),
    .pready_m4           (pready_mhu_seesx_0),
    .pslverr_m4          (pslverr_mhu_seesx_0),
                         
    .psel_m5             (psel_mhu_esxse_0),
    .paddr_m5            (paddr_mhu_esxse_0),
    .pstrb_m5            (),
    .pwrite_m5           (pwrite_mhu_esxse_0),
    .penable_m5          (penable_mhu_esxse_0),
    .pprot_m5            (),
    .pwdata_m5           (pwdata_mhu_esxse_0),
    .prdata_m5           (prdata_mhu_esxse_0),
    .pready_m5           (pready_mhu_esxse_0),
    .pslverr_m5          (pslverr_mhu_esxse_0),

    .psel_m6             (psel_mhu_seesx_1),
    .paddr_m6            (paddr_mhu_seesx_1),
    .pstrb_m6            (),
    .pwrite_m6           (pwrite_mhu_seesx_1),
    .penable_m6          (penable_mhu_seesx_1),
    .pprot_m6            (),
    .pwdata_m6           (pwdata_mhu_seesx_1),
    .prdata_m6           (prdata_mhu_seesx_1),
    .pready_m6           (pready_mhu_seesx_1),
    .pslverr_m6          (pslverr_mhu_seesx_1),
                         
    .psel_m7             (psel_mhu_esxse_1),
    .paddr_m7            (paddr_mhu_esxse_1),
    .pstrb_m7            (),
    .pwrite_m7           (pwrite_mhu_esxse_1),
    .penable_m7          (penable_mhu_esxse_1),
    .pprot_m7            (),
    .pwdata_m7           (pwdata_mhu_esxse_1),
    .prdata_m7           (prdata_mhu_esxse_1),
    .pready_m7           (pready_mhu_esxse_1),
    .pslverr_m7          (pslverr_mhu_esxse_1),

    .psel_m8             (), 
    .paddr_m8            (),
    .pstrb_m8            (),
    .pwrite_m8           (),
    .penable_m8          (),
    .pprot_m8            (),
    .pwdata_m8           (),
    .prdata_m8           (32'h0000_0000),
    .pready_m8           (1'b1),
    .pslverr_m8          (1'b1),

    .psel_m9             (),
    .paddr_m9            (),
    .pstrb_m9            (),
    .pwrite_m9           (),
    .penable_m9          (),
    .pprot_m9            (),
    .pwdata_m9           (),
    .prdata_m9           (32'h0000_0000),
    .pready_m9           (1'b0),
    .pslverr_m9          (1'b0),

    .psel_m10            (),
    .paddr_m10           (),
    .pstrb_m10           (),
    .pwrite_m10          (),
    .penable_m10         (),
    .pprot_m10           (),
    .pwdata_m10          (),
    .prdata_m10          (32'h0000_0000),
    .pready_m10          (1'b0),
    .pslverr_m10         (1'b0),

    .psel_m11            (),
    .paddr_m11           (),
    .pstrb_m11           (),
    .pwrite_m11          (),
    .penable_m11         (),
    .pprot_m11           (),
    .pwdata_m11          (),
    .prdata_m11          (32'h0000_0000),
    .pready_m11          (1'b0),
    .pslverr_m11         (1'b0),

    .psel_m12            (),
    .paddr_m12           (),
    .pstrb_m12           (),
    .pwrite_m12          (),
    .penable_m12         (),
    .pprot_m12           (),
    .pwdata_m12          (),
    .prdata_m12          (32'h0000_0000),
    .pready_m12          (1'b0),
    .pslverr_m12         (1'b0),

    .psel_m13            (),
    .paddr_m13           (),
    .pstrb_m13           (),
    .pwrite_m13          (),
    .penable_m13         (),
    .pprot_m13           (),
    .pwdata_m13          (),
    .prdata_m13          (32'h0000_0000),
    .pready_m13          (1'b0),
    .pslverr_m13         (1'b0),

    .psel_m14            (),
    .paddr_m14           (),
    .pstrb_m14           (),
    .pwrite_m14          (),
    .penable_m14         (),
    .pprot_m14           (),
    .pwdata_m14          (),
    .prdata_m14          (32'h0000_0000),
    .pready_m14          (1'b0),
    .pslverr_m14         (1'b0),

    .psel_m15            (),
    .paddr_m15           (),
    .pstrb_m15           (),
    .pwrite_m15          (),
    .penable_m15         (),
    .pprot_m15           (),
    .pwdata_m15          (),
    .prdata_m15          (32'h0000_0000),
    .pready_m15          (1'b0),
    .pslverr_m15         (1'b0)
  );


  mhuv2_f1_sender #(
    .MHU_NUM_CH (MHU_ESXH0_NUM_CH)
  ) u_mhuv2_f1_sender_esxh_0 (
    .pclk_snd                             (extsysx_mhuclk),
    .presetn_snd                          (extsysx_mhuresetn),
    .pwakeup_snd                          (1'b0), 
    .paddr_snd                            ({20'h00000, paddr_mhu_esxh_0}),
    .pwrite_snd                           (pwrite_mhu_esxh_0),
    .pwdata_snd                           (pwdata_mhu_esxh_0),
    .penable_snd                          (penable_mhu_esxh_0),
    .pselx_snd                            (psel_mhu_esxh_0),
    .prdata_snd                           (prdata_mhu_esxh_0),
    .pready_snd                           (pready_mhu_esxh_0),
    .pslverr_snd                          (pslverr_mhu_esxh_0),
    .qreqn_pclk_snd                       (qreqn_mhu_esxh_0_pclk_snd),
    .qacceptn_pclk_snd                    (qacceptn_mhu_esxh_0_pclk_snd),
    .qdeny_pclk_snd                       (qdeny_mhu_esxh_0_pclk_snd),
    .qactive_pclk_snd                     (qactive_mhu_esxh_0_pclk_snd),
    .apb_async_req                        (apb_async_req_ehx_mhu_esh_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esh_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esh_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_esh_0),
    .recawake_async                       (recawake_async_ehx_mhu_esh_0),
    .recwakeup_async                      (recwakeup_async_ehx_mhu_esh_0),
    .int_access_nr2r                      (),
    .int_access_r2nr                      (),
    .int_irqcomb                          (esh0_extsysx_mhuint),
    .edge_async_req                       (edge_async_req_ehx_mhu_esh_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_esh_0),
    .dftcgen                              (dftcgen)
  );


  mhuv2_f1_receiver #(
    .MHU_NUM_CH (MHU_HESX0_NUM_CH)

  ) u_mhuv2_f1_receiver_hesx_0 (
    .pclk_rec                             (extsysx_mhuclk),
    .presetn_rec                          (extsysx_mhuresetn),
    .pwakeup_rec                          (1'b0), 
    .paddr_rec                            ({20'h00000, paddr_mhu_hesx_0}),
    .pwrite_rec                           (pwrite_mhu_hesx_0),
    .pwdata_rec                           (pwdata_mhu_hesx_0),
    .penable_rec                          (penable_mhu_hesx_0),
    .pselx_rec                            (psel_mhu_hesx_0),
    .prdata_rec                           (prdata_mhu_hesx_0),
    .pready_rec                           (pready_mhu_hesx_0),
    .pslverr_rec                          (pslverr_mhu_hesx_0),
    .qreqn_pclk_rec                       (qreqn_mhu_hesx_0_pclk_rec),
    .qacceptn_pclk_rec                    (qacceptn_mhu_hesx_0_pclk_rec),
    .qdeny_pclk_rec                       (qdeny_mhu_hesx_0_pclk_rec),
    .qactive_pclk_rec                     (qactive_mhu_hesx_0_pclk_rec),
    .qreqn_pwr_rec                        (qreqn_mhu_hesx_0_pwr_rec),
    .qacceptn_pwr_rec                     (qacceptn_mhu_hesx_0_pwr_rec),
    .qdeny_pwr_rec                        (qdeny_mhu_hesx_0_pwr_rec),
    .mhu_irqcomb                          (hes0_extsysx_mhuint),
    .mhu_irq_reg                          (),
    .apb_async_req                        (apb_async_req_ehx_mhu_hes_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_hes_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_hes_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_hes_0),
    .recawake_async                       (recawake_async_ehx_mhu_hes_0),
    .recwakeup_async                      (recwakeup_async_ehx_mhu_hes_0),
    .edge_async_req                       (edge_async_req_ehx_mhu_hes_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_hes_0),
    .dftcgen                              (dftcgen)
  );

  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_esxh_1

      mhuv2_f1_sender #(
        .MHU_NUM_CH (MHU_ESXH1_NUM_CH)
      ) u_mhuv2_f1_sender_esxh_1 (
        .pclk_snd                             (extsysx_mhuclk),
        .presetn_snd                          (extsysx_mhuresetn),
        .pwakeup_snd                          (1'b0), 
        .paddr_snd                            ({20'h00000, paddr_mhu_esxh_1}),
        .pwrite_snd                           (pwrite_mhu_esxh_1),
        .pwdata_snd                           (pwdata_mhu_esxh_1),
        .penable_snd                          (penable_mhu_esxh_1),
        .pselx_snd                            (psel_mhu_esxh_1),
        .prdata_snd                           (prdata_mhu_esxh_1),
        .pready_snd                           (pready_mhu_esxh_1),
        .pslverr_snd                          (pslverr_mhu_esxh_1),
        .qreqn_pclk_snd                       (qreqn_mhu_esxh_1_pclk_snd),
        .qacceptn_pclk_snd                    (qacceptn_mhu_esxh_1_pclk_snd),
        .qdeny_pclk_snd                       (qdeny_mhu_esxh_1_pclk_snd),
        .qactive_pclk_snd                     (qactive_mhu_esxh_1_pclk_snd),
        .apb_async_req                        (apb_async_req_ehx_mhu_esh_1),
        .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esh_1),
        .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esh_1),
        .apb_async_ack                        (apb_async_ack_ehx_mhu_esh_1),
        .recawake_async                       (recawake_async_ehx_mhu_esh_1),
        .recwakeup_async                      (recwakeup_async_ehx_mhu_esh_1),
        .int_access_nr2r                      (),
        .int_access_r2nr                      (),
        .int_irqcomb                          (esh1_extsysx_mhuint),
        .edge_async_req                       (edge_async_req_ehx_mhu_esh_1),
        .edge_async_ack                       (edge_async_ack_ehx_mhu_esh_1),
        .dftcgen                              (dftcgen)
      );

    end else begin: gen_mhu_esxh_1_tieoff

      assign prdata_mhu_esxh_1                   = 32'h0000_0000;
      assign pready_mhu_esxh_1                   = 1'b1;
      assign pslverr_mhu_esxh_1                  = 1'b1;

      assign apb_async_req_ehx_mhu_esh_1         = 1'h0;
      assign apb_async_req_payload_ehx_mhu_esh_1 = 49'h0;
      assign recwakeup_async_ehx_mhu_esh_1       = 1'b0;
      assign edge_async_ack_ehx_mhu_esh_1        = {MHU_ESXH1_NUM_CH{1'b0}};

      assign esh1_extsysx_mhuint                 = 1'b0;
      
      assign qacceptn_mhu_esxh_1_pclk_snd        = 1'b0;
      assign qdeny_mhu_esxh_1_pclk_snd           = 1'b0;
      assign qactive_mhu_esxh_1_pclk_snd         = 1'b0;

      assign unused_mhu_esxh = ( apb_async_ack_ehx_mhu_esh_1)          |
                               (|apb_async_resp_payload_ehx_mhu_esh_1) |
                               ( recawake_async_ehx_mhu_esh_1)         |
                               (|edge_async_req_ehx_mhu_esh_1)         |
                               ( psel_mhu_esxh_1)                      |
                               ( penable_mhu_esxh_1)                   |
                               (|pwdata_mhu_esxh_1)                    |
                               ( pwrite_mhu_esxh_1)                    |
                               ( qacceptn_mhu_esxh_1_pclk_snd)         |
                               ( qdeny_mhu_esxh_1_pclk_snd)            |
                               ( qactive_mhu_esxh_1_pclk_snd)          |
                               (|paddr_mhu_esxh_1);

    end
  endgenerate


  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_hesx_1

      mhuv2_f1_receiver #(
        .MHU_NUM_CH (MHU_HESX1_NUM_CH)
      ) u_mhuv2_f1_receiver_hesx_1 (
        .pclk_rec                             (extsysx_mhuclk),
        .presetn_rec                          (extsysx_mhuresetn),
        .pwakeup_rec                          (1'b0), 
        .paddr_rec                            ({20'h00000, paddr_mhu_hesx_1}),
        .pwrite_rec                           (pwrite_mhu_hesx_1),
        .pwdata_rec                           (pwdata_mhu_hesx_1),
        .penable_rec                          (penable_mhu_hesx_1),
        .pselx_rec                            (psel_mhu_hesx_1),
        .prdata_rec                           (prdata_mhu_hesx_1),
        .pready_rec                           (pready_mhu_hesx_1),
        .pslverr_rec                          (pslverr_mhu_hesx_1),
        .qreqn_pclk_rec                       (qreqn_mhu_hesx_1_pclk_rec),
        .qacceptn_pclk_rec                    (qacceptn_mhu_hesx_1_pclk_rec),
        .qdeny_pclk_rec                       (qdeny_mhu_hesx_1_pclk_rec),
        .qactive_pclk_rec                     (qactive_mhu_hesx_1_pclk_rec),
        .qreqn_pwr_rec                        (qreqn_mhu_hesx_1_pwr_rec),
        .qacceptn_pwr_rec                     (qacceptn_mhu_hesx_1_pwr_rec),
        .qdeny_pwr_rec                        (qdeny_mhu_hesx_1_pwr_rec),
        .mhu_irqcomb                          (hes1_extsysx_mhuint),
        .mhu_irq_reg                          (),
        .apb_async_req                        (apb_async_req_ehx_mhu_hes_1),
        .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_hes_1),
        .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_hes_1),
        .apb_async_ack                        (apb_async_ack_ehx_mhu_hes_1),
        .recawake_async                       (recawake_async_ehx_mhu_hes_1),
        .recwakeup_async                      (recwakeup_async_ehx_mhu_hes_1),
        .edge_async_req                       (edge_async_req_ehx_mhu_hes_1),
        .edge_async_ack                       (edge_async_ack_ehx_mhu_hes_1),
        .dftcgen                              (dftcgen)
      );

    end else begin: gen_mhu_hesx_1_tieoff

      assign prdata_mhu_hesx_1                     = 32'h0000_0000;
      assign pready_mhu_hesx_1                     = 1'b1;
      assign pslverr_mhu_hesx_1                    = 1'b1;

      assign apb_async_ack_ehx_mhu_hes_1           = 1'h0;
      assign apb_async_resp_payload_ehx_mhu_hes_1  = 33'h0;
      assign recawake_async_ehx_mhu_hes_1          = 1'b0;
      assign edge_async_req_ehx_mhu_hes_1          = {MHU_HESX1_NUM_CH{1'b0}};

      assign hes1_extsysx_mhuint                   = 1'b0;

      assign qacceptn_mhu_hesx_1_pclk_rec          = 1'b0;
      assign qdeny_mhu_hesx_1_pclk_rec             = 1'b0;
      assign qactive_mhu_hesx_1_pclk_rec           = 1'b0;
      assign qacceptn_mhu_hesx_1_pwr_rec           = 1'b0;
      assign qdeny_mhu_hesx_1_pwr_rec              = 1'b0;

      assign unused_mhu_hesx = ( apb_async_req_ehx_mhu_hes_1)          |
                               (|apb_async_req_payload_ehx_mhu_hes_1)  |
                               ( recwakeup_async_ehx_mhu_hes_1)        |
                               (|edge_async_ack_ehx_mhu_hes_1)         |
                               ( psel_mhu_hesx_1)                      |
                               ( penable_mhu_hesx_1)                   |
                               (|pwdata_mhu_hesx_1)                    |
                               ( pwrite_mhu_hesx_1)                    |
                               ( qacceptn_mhu_hesx_1_pclk_rec)         |
                               ( qdeny_mhu_hesx_1_pclk_rec)            |
                               ( qactive_mhu_hesx_1_pclk_rec)          |
                               ( qacceptn_mhu_hesx_1_pwr_rec)          |
                               ( qdeny_mhu_hesx_1_pwr_rec)             |
                               (|paddr_mhu_hesx_1);
    end
  endgenerate
  

  mhuv2_f1_sender #(
    .MHU_NUM_CH (MHU_ESXSE0_NUM_CH)
  ) u_mhuv2_f1_sender_esxse_0 (
    .pclk_snd                             (extsysx_mhuclk),
    .presetn_snd                          (extsysx_mhuresetn),
    .pwakeup_snd                          (1'b0), 
    .paddr_snd                            ({20'h00000, paddr_mhu_esxse_0}),
    .pwrite_snd                           (pwrite_mhu_esxse_0),
    .pwdata_snd                           (pwdata_mhu_esxse_0),
    .penable_snd                          (penable_mhu_esxse_0),
    .pselx_snd                            (psel_mhu_esxse_0),
    .prdata_snd                           (prdata_mhu_esxse_0),
    .pready_snd                           (pready_mhu_esxse_0),
    .pslverr_snd                          (pslverr_mhu_esxse_0),
    .qreqn_pclk_snd                       (qreqn_mhu_esxse_0_pclk_snd),
    .qacceptn_pclk_snd                    (qacceptn_mhu_esxse_0_pclk_snd),
    .qdeny_pclk_snd                       (qdeny_mhu_esxse_0_pclk_snd),
    .qactive_pclk_snd                     (qactive_mhu_esxse_0_pclk_snd),
    .apb_async_req                        (apb_async_req_ehx_mhu_esse_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esse_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esse_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_esse_0),
    .recawake_async                       (recawake_async_ehx_mhu_esse_0),
    .recwakeup_async                      (recwakeup_async_ehx_mhu_esse_0),
    .int_access_nr2r                      (),
    .int_access_r2nr                      (),
    .int_irqcomb                          (esse0_extsysx_mhuint),
    .edge_async_req                       (edge_async_req_ehx_mhu_esse_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_esse_0),
    .dftcgen                              (dftcgen)
  );


  mhuv2_f1_receiver #(
    .MHU_NUM_CH (MHU_SEESX0_NUM_CH)

  ) u_mhuv2_f1_receiver_seesx_0 (
    .pclk_rec                             (extsysx_mhuclk),
    .presetn_rec                          (extsysx_mhuresetn),
    .pwakeup_rec                          (1'b0), 
    .paddr_rec                            ({20'h00000, paddr_mhu_seesx_0}),
    .pwrite_rec                           (pwrite_mhu_seesx_0),
    .pwdata_rec                           (pwdata_mhu_seesx_0),
    .penable_rec                          (penable_mhu_seesx_0),
    .pselx_rec                            (psel_mhu_seesx_0),
    .prdata_rec                           (prdata_mhu_seesx_0),
    .pready_rec                           (pready_mhu_seesx_0),
    .pslverr_rec                          (pslverr_mhu_seesx_0),
    .qreqn_pclk_rec                       (qreqn_mhu_seesx_0_pclk_rec),
    .qacceptn_pclk_rec                    (qacceptn_mhu_seesx_0_pclk_rec),
    .qdeny_pclk_rec                       (qdeny_mhu_seesx_0_pclk_rec),
    .qactive_pclk_rec                     (qactive_mhu_seesx_0_pclk_rec),
    .qreqn_pwr_rec                        (qreqn_mhu_seesx_0_pwr_rec),
    .qacceptn_pwr_rec                     (qacceptn_mhu_seesx_0_pwr_rec),
    .qdeny_pwr_rec                        (qdeny_mhu_seesx_0_pwr_rec),
    .mhu_irqcomb                          (sees0_extsysx_mhuint),
    .mhu_irq_reg                          (),
    .apb_async_req                        (apb_async_req_ehx_mhu_sees_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_sees_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_sees_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_sees_0),
    .recawake_async                       (recawake_async_ehx_mhu_sees_0),
    .recwakeup_async                      (recwakeup_async_ehx_mhu_sees_0),
    .edge_async_req                       (edge_async_req_ehx_mhu_sees_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_sees_0),
    .dftcgen                              (dftcgen)
  );  

  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_esxse_1

      mhuv2_f1_sender #(
        .MHU_NUM_CH (MHU_ESXSE1_NUM_CH)
      ) u_mhuv2_f1_sender_esxse_1 (
        .pclk_snd                             (extsysx_mhuclk),
        .presetn_snd                          (extsysx_mhuresetn),
        .pwakeup_snd                          (1'b0), 
        .paddr_snd                            ({20'h00000, paddr_mhu_esxse_1}),
        .pwrite_snd                           (pwrite_mhu_esxse_1),
        .pwdata_snd                           (pwdata_mhu_esxse_1),
        .penable_snd                          (penable_mhu_esxse_1),
        .pselx_snd                            (psel_mhu_esxse_1),
        .prdata_snd                           (prdata_mhu_esxse_1),
        .pready_snd                           (pready_mhu_esxse_1),
        .pslverr_snd                          (pslverr_mhu_esxse_1),
        .qreqn_pclk_snd                       (qreqn_mhu_esxse_1_pclk_snd),
        .qacceptn_pclk_snd                    (qacceptn_mhu_esxse_1_pclk_snd),
        .qdeny_pclk_snd                       (qdeny_mhu_esxse_1_pclk_snd),
        .qactive_pclk_snd                     (qactive_mhu_esxse_1_pclk_snd),
        .apb_async_req                        (apb_async_req_ehx_mhu_esse_1),
        .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esse_1),
        .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esse_1),
        .apb_async_ack                        (apb_async_ack_ehx_mhu_esse_1),
        .recawake_async                       (recawake_async_ehx_mhu_esse_1),
        .recwakeup_async                      (recwakeup_async_ehx_mhu_esse_1),
        .int_access_nr2r                      (),
        .int_access_r2nr                      (),
        .int_irqcomb                          (esse1_extsysx_mhuint),
        .edge_async_req                       (edge_async_req_ehx_mhu_esse_1),
        .edge_async_ack                       (edge_async_ack_ehx_mhu_esse_1),
        .dftcgen                              (dftcgen)
      );

    end else begin: gen_mhu_esxse_1_tieoff

      assign prdata_mhu_esxse_1                   = 32'h0000_0000;
      assign pready_mhu_esxse_1                   = 1'b1;
      assign pslverr_mhu_esxse_1                  = 1'b1;

      assign apb_async_req_ehx_mhu_esse_1         = 1'h0;
      assign apb_async_req_payload_ehx_mhu_esse_1 = 49'h0;
      assign recwakeup_async_ehx_mhu_esse_1       = 1'b0;
      assign edge_async_ack_ehx_mhu_esse_1        = {MHU_ESXSE1_NUM_CH{1'b0}};

      assign esse1_extsysx_mhuint                 = 1'b0;

      assign qacceptn_mhu_esxse_1_pclk_snd        = 1'b0;
      assign qdeny_mhu_esxse_1_pclk_snd           = 1'b0;
      assign qactive_mhu_esxse_1_pclk_snd         = 1'b0;
      
      assign unused_mhu_esxse = ( apb_async_ack_ehx_mhu_esse_1)          |
                                (|apb_async_resp_payload_ehx_mhu_esse_1) |
                                ( recawake_async_ehx_mhu_esse_1)         |
                                (|edge_async_req_ehx_mhu_esse_1)         |
                                ( psel_mhu_esxse_1)                      |
                                ( penable_mhu_esxse_1)                   |
                                (|pwdata_mhu_esxse_1)                    |
                                ( pwrite_mhu_esxse_1)                    |
                                ( qacceptn_mhu_esxse_1_pclk_snd)         |
                                ( qdeny_mhu_esxse_1_pclk_snd)            |
                                ( qactive_mhu_esxse_1_pclk_snd)          |
                                (|paddr_mhu_esxse_1);

    end
  endgenerate


  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_seesx_1

      mhuv2_f1_receiver #(
        .MHU_NUM_CH (MHU_SEESX1_NUM_CH)
      ) u_mhuv2_f1_receiver_seesx_1 (
        .pclk_rec                             (extsysx_mhuclk),
        .presetn_rec                          (extsysx_mhuresetn),
        .pwakeup_rec                          (1'b0), 
        .paddr_rec                            ({20'h00000, paddr_mhu_seesx_1}),
        .pwrite_rec                           (pwrite_mhu_seesx_1),
        .pwdata_rec                           (pwdata_mhu_seesx_1),
        .penable_rec                          (penable_mhu_seesx_1),
        .pselx_rec                            (psel_mhu_seesx_1),
        .prdata_rec                           (prdata_mhu_seesx_1),
        .pready_rec                           (pready_mhu_seesx_1),
        .pslverr_rec                          (pslverr_mhu_seesx_1),
        .qreqn_pclk_rec                       (qreqn_mhu_seesx_1_pclk_rec),
        .qacceptn_pclk_rec                    (qacceptn_mhu_seesx_1_pclk_rec),
        .qdeny_pclk_rec                       (qdeny_mhu_seesx_1_pclk_rec),
        .qactive_pclk_rec                     (qactive_mhu_seesx_1_pclk_rec),
        .qreqn_pwr_rec                        (qreqn_mhu_seesx_1_pwr_rec),
        .qacceptn_pwr_rec                     (qacceptn_mhu_seesx_1_pwr_rec),
        .qdeny_pwr_rec                        (qdeny_mhu_seesx_1_pwr_rec),
        .mhu_irqcomb                          (sees1_extsysx_mhuint),
        .mhu_irq_reg                          (),
        .apb_async_req                        (apb_async_req_ehx_mhu_sees_1),
        .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_sees_1),
        .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_sees_1),
        .apb_async_ack                        (apb_async_ack_ehx_mhu_sees_1),
        .recawake_async                       (recawake_async_ehx_mhu_sees_1),
        .recwakeup_async                      (recwakeup_async_ehx_mhu_sees_1),
        .edge_async_req                       (edge_async_req_ehx_mhu_sees_1),
        .edge_async_ack                       (edge_async_ack_ehx_mhu_sees_1),
        .dftcgen                              (dftcgen)
      );

    end else begin: gen_mhu_seesx_1_tieoff

      assign prdata_mhu_seesx_1                     = 32'h0000_0000;
      assign pready_mhu_seesx_1                     = 1'b1;
      assign pslverr_mhu_seesx_1                    = 1'b1;

      assign apb_async_ack_ehx_mhu_sees_1           = 1'h0;
      assign apb_async_resp_payload_ehx_mhu_sees_1  = 33'h0;
      assign recawake_async_ehx_mhu_sees_1          = 1'b0;
      assign edge_async_req_ehx_mhu_sees_1          = {MHU_SEESX1_NUM_CH{1'b0}};

      assign sees1_extsysx_mhuint                   = 1'b0;

      assign qacceptn_mhu_seesx_1_pclk_rec          = 1'b0;
      assign qdeny_mhu_seesx_1_pclk_rec             = 1'b0;
      assign qactive_mhu_seesx_1_pclk_rec           = 1'b0;
      assign qacceptn_mhu_seesx_1_pwr_rec           = 1'b0;
      assign qdeny_mhu_seesx_1_pwr_rec              = 1'b0;
      
      assign unused_mhu_seesx = ( apb_async_req_ehx_mhu_sees_1)          |
                                (|apb_async_req_payload_ehx_mhu_sees_1)  |
                                ( recwakeup_async_ehx_mhu_sees_1)        |
                                (|edge_async_ack_ehx_mhu_sees_1)         |
                                ( psel_mhu_seesx_1)                      |
                                ( penable_mhu_seesx_1)                   |
                                (|pwdata_mhu_seesx_1)                    |
                                ( pwrite_mhu_seesx_1)                    |
                                ( qacceptn_mhu_seesx_1_pclk_rec)         |
                                ( qdeny_mhu_seesx_1_pclk_rec)            |
                                ( qactive_mhu_seesx_1_pclk_rec)          |
                                ( qacceptn_mhu_seesx_1_pwr_rec)          |
                                ( qdeny_mhu_seesx_1_pwr_rec)             |
                                (|paddr_mhu_seesx_1);
    end
  endgenerate  
  

  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (NUM_CLK_QCH),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q_clk (
    .clk               (extsysx_mhuclk),
    .reset_n           (extsysx_mhuresetn),

    .ctrl_qreqn_i      (qreqn_extsysx_mhuclk),
    .ctrl_qacceptn_o   (qacceptn_extsysx_mhuclk),
    .ctrl_qdeny_o      (qdeny_extsysx_mhuclk),
    .ctrl_qactive_o    (qactive_clk_lpdq_ctrl),

    .dev_qreqn_o       (qreqn_lpdq_clk),
    .dev_qacceptn_i    (qacceptn_lpdq_clk),
    .dev_qdeny_i       (qdeny_lpdq_clk),
    .dev_qactive_i     (qactive_lpdq_clk),

    .clk_qactive_o     (),

    .dftcgen           (dftcgen)
    );

  assign qreqn_apbic                = qreqn_lpdq_clk[0];
  assign qreqn_mhu_esxh_0_pclk_snd  = qreqn_lpdq_clk[1];
  assign qreqn_mhu_hesx_0_pclk_rec  = qreqn_lpdq_clk[2];
  assign qreqn_mhu_esxse_0_pclk_snd = qreqn_lpdq_clk[3];
  assign qreqn_mhu_seesx_0_pclk_rec = qreqn_lpdq_clk[4];  

  assign qacceptn_lpdq_clk[0]       = qacceptn_apbic;
  assign qacceptn_lpdq_clk[1]       = qacceptn_mhu_esxh_0_pclk_snd;
  assign qacceptn_lpdq_clk[2]       = qacceptn_mhu_hesx_0_pclk_rec;
  assign qacceptn_lpdq_clk[3]       = qacceptn_mhu_esxse_0_pclk_snd;
  assign qacceptn_lpdq_clk[4]       = qacceptn_mhu_seesx_0_pclk_rec;  
                                    
  assign qdeny_lpdq_clk[0]          = qdeny_apbic;
  assign qdeny_lpdq_clk[1]          = qdeny_mhu_esxh_0_pclk_snd;
  assign qdeny_lpdq_clk[2]          = qdeny_mhu_hesx_0_pclk_rec;
  assign qdeny_lpdq_clk[3]          = qdeny_mhu_esxse_0_pclk_snd;
  assign qdeny_lpdq_clk[4]          = qdeny_mhu_seesx_0_pclk_rec;  
                                    
  assign qactive_lpdq_clk[0]        = qactive_apbic;
  assign qactive_lpdq_clk[1]        = qactive_mhu_esxh_0_pclk_snd;
  assign qactive_lpdq_clk[2]        = qactive_mhu_hesx_0_pclk_rec;
  assign qactive_lpdq_clk[3]        = qactive_mhu_esxse_0_pclk_snd;
  assign qactive_lpdq_clk[4]        = qactive_mhu_seesx_0_pclk_rec;  

  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_clk_ctrl_tz_spt

      assign qreqn_mhu_esxh_1_pclk_snd  = qreqn_lpdq_clk[5];
      assign qreqn_mhu_hesx_1_pclk_rec  = qreqn_lpdq_clk[6];
      assign qreqn_mhu_esxse_1_pclk_snd = qreqn_lpdq_clk[7];
      assign qreqn_mhu_seesx_1_pclk_rec = qreqn_lpdq_clk[8];
      
      assign qacceptn_lpdq_clk[5]       = qacceptn_mhu_esxh_1_pclk_snd;
      assign qacceptn_lpdq_clk[6]       = qacceptn_mhu_hesx_1_pclk_rec;
      assign qacceptn_lpdq_clk[7]       = qacceptn_mhu_esxse_1_pclk_snd;
      assign qacceptn_lpdq_clk[8]       = qacceptn_mhu_seesx_1_pclk_rec;

      assign qdeny_lpdq_clk[5]          = qdeny_mhu_esxh_1_pclk_snd;
      assign qdeny_lpdq_clk[6]          = qdeny_mhu_hesx_1_pclk_rec;      
      assign qdeny_lpdq_clk[7]          = qdeny_mhu_esxse_1_pclk_snd;
      assign qdeny_lpdq_clk[8]          = qdeny_mhu_seesx_1_pclk_rec;

      assign qactive_lpdq_clk[5]        = qactive_mhu_esxh_1_pclk_snd;
      assign qactive_lpdq_clk[6]        = qactive_mhu_hesx_1_pclk_rec;      
      assign qactive_lpdq_clk[7]        = qactive_mhu_esxse_1_pclk_snd;
      assign qactive_lpdq_clk[8]        = qactive_mhu_seesx_1_pclk_rec;

    end
  endgenerate

  arm_element_std_or2 u_arm_element_std_or2_0 (
    .A  (qactive_clk_lpdq_ctrl),
    .B  (qactive_pwr_lpdq_clk),
    .Y  (qactive_extsysx_mhuclk)
  );


  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (NUM_PWR_QCH),
    .CTRL_Q_CH_SYNC    (1),
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q_pwr (
    .clk               (extsysx_mhuclk),
    .reset_n           (extsysx_mhuresetn),

    .ctrl_qreqn_i      (qreqn_extsysx_mhupwr),
    .ctrl_qacceptn_o   (qacceptn_extsysx_mhupwr),
    .ctrl_qdeny_o      (qdeny_extsysx_mhupwr),
    .ctrl_qactive_o    (),

    .dev_qreqn_o       (qreqn_lpdq_pwr),
    .dev_qacceptn_i    (qacceptn_lpdq_pwr),
    .dev_qdeny_i       (qdeny_lpdq_pwr),
    .dev_qactive_i     (qactive_lpdq_pwr),

    .clk_qactive_o     (qactive_pwr_lpdq_clk),

    .dftcgen           (dftcgen)
    );

  assign qreqn_mhu_hesx_0_pwr_rec  = qreqn_lpdq_pwr[0];
  assign qreqn_mhu_seesx_0_pwr_rec = qreqn_lpdq_pwr[1];

  assign qacceptn_lpdq_pwr[0]      = qacceptn_mhu_hesx_0_pwr_rec;
  assign qacceptn_lpdq_pwr[1]      = qacceptn_mhu_seesx_0_pwr_rec;

  assign qdeny_lpdq_pwr[0]         = qdeny_mhu_hesx_0_pwr_rec;
  assign qdeny_lpdq_pwr[1]         = qdeny_mhu_seesx_0_pwr_rec;

  assign qactive_lpdq_pwr[0]       = 1'b0;
  assign qactive_lpdq_pwr[1]       = 1'b0;

  generate
  if (EXT_SYSX_TZ_SPT == 1) begin: gen_lpd_q_pwr_tz_spt
  
      assign qreqn_mhu_hesx_1_pwr_rec  = qreqn_lpdq_pwr[2];
      assign qreqn_mhu_seesx_1_pwr_rec = qreqn_lpdq_pwr[3];

      assign qacceptn_lpdq_pwr[2]      = qacceptn_mhu_hesx_1_pwr_rec;
      assign qacceptn_lpdq_pwr[3]      = qacceptn_mhu_seesx_1_pwr_rec;

      assign qdeny_lpdq_pwr[2]         = qdeny_mhu_hesx_1_pwr_rec;
      assign qdeny_lpdq_pwr[3]         = qdeny_mhu_seesx_1_pwr_rec;

      assign qactive_lpdq_pwr[2]       = 1'b0;
      assign qactive_lpdq_pwr[3]       = 1'b0;      

  end
  endgenerate


  assign unused = |pstrb_extsysx_mhu;

endmodule
