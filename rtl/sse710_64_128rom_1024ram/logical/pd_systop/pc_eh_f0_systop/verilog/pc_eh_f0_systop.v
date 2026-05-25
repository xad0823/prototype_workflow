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

module pc_eh_f0_systop #(
  parameter  EXT_SYSX_TZ_SPT              = 0,    
  parameter  MHU_HESX0_NUM_CH             = 7'd2,    
  parameter  MHU_ESXH0_NUM_CH             = 7'd2,    
  parameter  MHU_HESX1_NUM_CH             = 7'd2,    
  parameter  MHU_ESXH1_NUM_CH             = 7'd2,    
  parameter  EXT_SYS_NUM                  = 8'h0, 

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
    input  wire                                    aclk,

    input  wire                                    systopwarmresetn,

    output wire                                    qactive_extsysx_mhupwrreq,

    output wire                                    awakeup_extsysx_axis,
    output wire [EXT_SYSX_MEM_AWID_WIDTH-1:0]       awid_extsysx_axis,
    output wire [31:0]                             awaddr_extsysx_axis,
    output wire [3:0]                              awregion_extsysx_axis,
    output wire [7:0]                              awlen_extsysx_axis,
    output wire [2:0]                              awsize_extsysx_axis,
    output wire [1:0]                              awburst_extsysx_axis,
    output wire                                    awlock_extsysx_axis,
    output wire [3:0]                              awcache_extsysx_axis,
    output wire [2:0]                              awprot_extsysx_axis,
    output wire                                    awvalid_extsysx_axis,
    output wire [9:0]                              awuser_extsysx_axis,
    input  wire                                    awready_extsysx_axis,
    output wire [(EXT_SYSX_MEM_DATA_WIDTH/8)-1:0]   wstrb_extsysx_axis,
    output wire                                    wlast_extsysx_axis,
    output wire                                    wvalid_extsysx_axis,
    output wire [EXT_SYSX_MEM_DATA_WIDTH-1:0]       wdata_extsysx_axis,
    input  wire                                    wready_extsysx_axis,
    input  wire [EXT_SYSX_MEM_AWID_WIDTH-1:0]       bid_extsysx_axis,
    input  wire [1:0]                              bresp_extsysx_axis,
    input  wire                                    bvalid_extsysx_axis,
    output wire                                    bready_extsysx_axis,
    output wire [EXT_SYSX_MEM_ARID_WIDTH-1:0]       arid_extsysx_axis,
    output wire [31:0]                             araddr_extsysx_axis,
    output wire [3:0]                              arregion_extsysx_axis,
    output wire [7:0]                              arlen_extsysx_axis,
    output wire [2:0]                              arsize_extsysx_axis,
    output wire [1:0]                              arburst_extsysx_axis,
    output wire                                    arlock_extsysx_axis,
    output wire [3:0]                              arcache_extsysx_axis,
    output wire [2:0]                              arprot_extsysx_axis,
    output wire                                    arvalid_extsysx_axis,
    output wire [9:0]                              aruser_extsysx_axis,
    input  wire                                    arready_extsysx_axis,
    input  wire [EXT_SYSX_MEM_ARID_WIDTH-1:0]       rid_extsysx_axis,
    input  wire [1:0]                              rresp_extsysx_axis,
    input  wire                                    rlast_extsysx_axis,
    input  wire                                    rvalid_extsysx_axis,
    input  wire [EXT_SYSX_MEM_DATA_WIDTH-1:0]       rdata_extsysx_axis,
    output wire                                    rready_extsysx_axis,

    input  wire                                    slvmustacceptreqn_async_ehx,
    input  wire                                    slvcandenyreqn_async_ehx,
    output wire                                    slvacceptn_async_ehx,
    output wire                                    slvdeny_async_ehx,
    input  wire                                    si_to_mi_wakeup_async_ehx,
    output wire                                    mi_to_si_wakeup_async_ehx,
    input  wire [EXT_SYSX_MEM_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_ehx,
    input  wire [EXT_SYSX_MEM_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_W_PAYLOAD_WIDTH-1:0]  w_payld_async_ehx,
    output wire [EXT_SYSX_MEM_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_B_PAYLOAD_WIDTH-1:0]  b_payld_async_ehx,
    input  wire [EXT_SYSX_MEM_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_ehx,
    output wire [EXT_SYSX_MEM_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_ehx,
    input  wire [EXT_SYSX_MEM_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_ehx,
    output wire [EXT_SYSX_MEM_R_PAYLOAD_WIDTH-1:0]  r_payld_async_ehx,

    input  wire                                    psel_esh_mhu0,
    input  wire                                    penable_esh_mhu0,
    input  wire [31:0]                             paddr_esh_mhu0,
    input  wire                                    pwrite_esh_mhu0,
    input  wire [31:0]                             pwdata_esh_mhu0,
    input  wire [3:0]                              pstrb_esh_mhu0,
    input  wire [2:0]                              pprot_esh_mhu0,
    output wire [31:0]                             prdata_esh_mhu0,
    output wire                                    pready_esh_mhu0,
    output wire                                    pslverr_esh_mhu0,

    input  wire                                    psel_esh_mhu1,
    input  wire                                    penable_esh_mhu1,
    input  wire [31:0]                             paddr_esh_mhu1,
    input  wire                                    pwrite_esh_mhu1,
    input  wire [31:0]                             pwdata_esh_mhu1,
    input  wire [3:0]                              pstrb_esh_mhu1,
    input  wire [2:0]                              pprot_esh_mhu1,
    output wire [31:0]                             prdata_esh_mhu1,
    output wire                                    pready_esh_mhu1,
    output wire                                    pslverr_esh_mhu1,

    input  wire                                    psel_hes_mhu0,
    input  wire                                    penable_hes_mhu0,
    input  wire [31:0]                             paddr_hes_mhu0,
    input  wire                                    pwrite_hes_mhu0,
    input  wire [31:0]                             pwdata_hes_mhu0,
    input  wire [3:0]                              pstrb_hes_mhu0,
    input  wire [2:0]                              pprot_hes_mhu0,
    output wire [31:0]                             prdata_hes_mhu0,
    output wire                                    pready_hes_mhu0,
    output wire                                    pslverr_hes_mhu0,

    input  wire                                    psel_hes_mhu1,
    input  wire                                    penable_hes_mhu1,
    input  wire [31:0]                             paddr_hes_mhu1,
    input  wire                                    pwrite_hes_mhu1,
    input  wire [31:0]                             pwdata_hes_mhu1,
    input  wire [3:0]                              pstrb_hes_mhu1,
    input  wire [2:0]                              pprot_hes_mhu1,
    output wire [31:0]                             prdata_hes_mhu1,
    output wire                                    pready_hes_mhu1,
    output wire                                    pslverr_hes_mhu1,

    output wire                                    hes_0_ehx_mhuint,
    output wire                                    esh_0_ehx_mhuint,
    output wire                                    hes_1_ehx_mhuint,
    output wire                                    esh_1_ehx_mhuint,

    input  wire                                    apb_async_req_ehx_mhu_esh_0,
    input  wire [48:0]                             apb_async_req_payload_ehx_mhu_esh_0,
    output wire [32:0]                             apb_async_resp_payload_ehx_mhu_esh_0,
    output wire                                    apb_async_ack_ehx_mhu_esh_0,
    output wire                                    recawake_async_ehx_mhu_esh_0,
    input  wire                                    recwakeup_async_ehx_mhu_esh_0,
    output wire [MHU_ESXH0_NUM_CH-1:0]             edge_async_req_ehx_mhu_esh_0,
    input  wire [MHU_ESXH0_NUM_CH-1:0]             edge_async_ack_ehx_mhu_esh_0,

    output wire                                    apb_async_req_ehx_mhu_hes_0,
    output wire [48:0]                             apb_async_req_payload_ehx_mhu_hes_0,
    input  wire [32:0]                             apb_async_resp_payload_ehx_mhu_hes_0,
    input  wire                                    apb_async_ack_ehx_mhu_hes_0,
    input  wire                                    recawake_async_ehx_mhu_hes_0,
    output wire                                    recwakeup_async_ehx_mhu_hes_0,
    input  wire [MHU_HESX0_NUM_CH-1:0]             edge_async_req_ehx_mhu_hes_0,
    output wire [MHU_HESX0_NUM_CH-1:0]             edge_async_ack_ehx_mhu_hes_0,

    input  wire                                    apb_async_req_ehx_mhu_esh_1,
    input  wire [48:0]                             apb_async_req_payload_ehx_mhu_esh_1,
    output wire [32:0]                             apb_async_resp_payload_ehx_mhu_esh_1,
    output wire                                    apb_async_ack_ehx_mhu_esh_1,
    output wire                                    recawake_async_ehx_mhu_esh_1,
    input  wire                                    recwakeup_async_ehx_mhu_esh_1,
    output wire [MHU_ESXH1_NUM_CH-1:0]             edge_async_req_ehx_mhu_esh_1,
    input  wire [MHU_ESXH1_NUM_CH-1:0]             edge_async_ack_ehx_mhu_esh_1,

    output wire                                    apb_async_req_ehx_mhu_hes_1,
    output wire [48:0]                             apb_async_req_payload_ehx_mhu_hes_1,
    input  wire [32:0]                             apb_async_resp_payload_ehx_mhu_hes_1,
    input  wire                                    apb_async_ack_ehx_mhu_hes_1,
    input  wire                                    recawake_async_ehx_mhu_hes_1,
    output wire                                    recwakeup_async_ehx_mhu_hes_1,
    input  wire [MHU_HESX1_NUM_CH-1:0]             edge_async_req_ehx_mhu_hes_1,
    output wire [MHU_HESX1_NUM_CH-1:0]             edge_async_ack_ehx_mhu_hes_1,
    
    input  wire                                    qreqn_ehx_aclk,
    output wire                                    qacceptn_ehx_aclk,
    output wire                                    qdeny_ehx_aclk,
    output wire                                    qactive_ehx_aclk,

    input  wire                                    qreqn_esh_mhu0_pwr,
    output wire                                    qacceptn_esh_mhu0_pwr,
    output wire                                    qdeny_esh_mhu0_pwr,

    input  wire                                    qreqn_esh_mhu1_pwr,
    output wire                                    qacceptn_esh_mhu1_pwr,
    output wire                                    qdeny_esh_mhu1_pwr,

    input  wire                                    dftcgen,
    input  wire                                    dftrstdisable
    );


  localparam     NUM_CLK_QCH = (EXT_SYSX_TZ_SPT == 0) ? 3 : 5;


  wire                       qreqn_esxh_mhu0_aclk;
  wire                       qacceptn_esxh_mhu0_aclk;
  wire                       qdeny_esxh_mhu0_aclk;
  wire                       qactive_esxh_mhu0_aclk;

  wire                       qreqn_esxh_mhu1_aclk;
  wire                       qacceptn_esxh_mhu1_aclk;
  wire                       qdeny_esxh_mhu1_aclk;
  wire                       qactive_esxh_mhu1_aclk;

  wire                       qreqn_hesx_mhu0_aclk;
  wire                       qacceptn_hesx_mhu0_aclk;
  wire                       qdeny_hesx_mhu0_aclk;
  wire                       qactive_hesx_mhu0_aclk;

  wire                       qreqn_hesx_mhu1_aclk;
  wire                       qacceptn_hesx_mhu1_aclk;
  wire                       qdeny_hesx_mhu1_aclk;
  wire                       qactive_hesx_mhu1_aclk;

  wire                       qreqn_axi_adb_aclk;
  wire                       qacceptn_axi_adb_aclk;
  wire                       qdeny_axi_adb_aclk;
  wire                       qactive_axi_adb_aclk;

  wire [NUM_CLK_QCH - 1 : 0] qreqn_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qacceptn_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qdeny_lpdq_clk;
  wire [NUM_CLK_QCH - 1 : 0] qactive_lpdq_clk;
  
  wire                       i_recwakeup_async_ehx_mhu_hes_0;
  wire                       i_recwakeup_async_ehx_mhu_hes_1;  
  
  reg                        hes_0_ehx_mhuint_r;
  reg                        esh_0_ehx_mhuint_r;
  reg                        hes_1_ehx_mhuint_r;
  reg                        esh_1_ehx_mhuint_r;
  wire                       hes_0_ehx_mhuint_int;
  wire                       esh_0_ehx_mhuint_int;
  wire                       hes_1_ehx_mhuint_int;
  wire                       esh_1_ehx_mhuint_int;
  
  wire                       unused_mhu_esxh;
  wire                       unused_mhu_hesx;
  wire                       unused_clk_ctrl;
  wire                       unused;


  mhuv2_f1_receiver #(
    .MHU_NUM_CH (MHU_ESXH0_NUM_CH)

  ) u_mhuv2_f1_receiver_esxh_0 (
    .pclk_rec                             (aclk),
    .presetn_rec                          (systopwarmresetn),
    .pwakeup_rec                          (psel_esh_mhu0), 
    .paddr_rec                            (paddr_esh_mhu0),
    .pwrite_rec                           (pwrite_esh_mhu0),
    .pwdata_rec                           (pwdata_esh_mhu0),
    .penable_rec                          (penable_esh_mhu0),
    .pselx_rec                            (psel_esh_mhu0),
    .prdata_rec                           (prdata_esh_mhu0),
    .pready_rec                           (pready_esh_mhu0),
    .pslverr_rec                          (pslverr_esh_mhu0),
    .qreqn_pclk_rec                       (qreqn_esxh_mhu0_aclk),
    .qacceptn_pclk_rec                    (qacceptn_esxh_mhu0_aclk),
    .qdeny_pclk_rec                       (qdeny_esxh_mhu0_aclk),
    .qactive_pclk_rec                     (qactive_esxh_mhu0_aclk),
    .qreqn_pwr_rec                        (qreqn_esh_mhu0_pwr),
    .qacceptn_pwr_rec                     (qacceptn_esh_mhu0_pwr),
    .qdeny_pwr_rec                        (qdeny_esh_mhu0_pwr),
    .mhu_irqcomb                          (esh_0_ehx_mhuint_int),
    .mhu_irq_reg                          (),
    .apb_async_req                        (apb_async_req_ehx_mhu_esh_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esh_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esh_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_esh_0),
    .recawake_async                       (recawake_async_ehx_mhu_esh_0),
    .recwakeup_async                      (recwakeup_async_ehx_mhu_esh_0),
    .edge_async_req                       (edge_async_req_ehx_mhu_esh_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_esh_0),
    .dftcgen                              (dftcgen)
  );


  mhuv2_f1_sender #(
    .MHU_NUM_CH (MHU_HESX0_NUM_CH)
  ) u_mhuv2_f1_sender_hesx_0 (
    .pclk_snd                             (aclk),
    .presetn_snd                          (systopwarmresetn),
    .pwakeup_snd                          (psel_hes_mhu0), 
    .paddr_snd                            (paddr_hes_mhu0),
    .pwrite_snd                           (pwrite_hes_mhu0),
    .pwdata_snd                           (pwdata_hes_mhu0),
    .penable_snd                          (penable_hes_mhu0),
    .pselx_snd                            (psel_hes_mhu0),
    .prdata_snd                           (prdata_hes_mhu0),
    .pready_snd                           (pready_hes_mhu0),
    .pslverr_snd                          (pslverr_hes_mhu0),
    .qreqn_pclk_snd                       (qreqn_hesx_mhu0_aclk),
    .qacceptn_pclk_snd                    (qacceptn_hesx_mhu0_aclk),
    .qdeny_pclk_snd                       (qdeny_hesx_mhu0_aclk),
    .qactive_pclk_snd                     (qactive_hesx_mhu0_aclk),
    .apb_async_req                        (apb_async_req_ehx_mhu_hes_0),
    .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_hes_0),
    .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_hes_0),
    .apb_async_ack                        (apb_async_ack_ehx_mhu_hes_0),
    .recawake_async                       (recawake_async_ehx_mhu_hes_0),
    .recwakeup_async                      (i_recwakeup_async_ehx_mhu_hes_0),
    .int_access_nr2r                      (),
    .int_access_r2nr                      (),
    .int_irqcomb                          (hes_0_ehx_mhuint_int),
    .edge_async_req                       (edge_async_req_ehx_mhu_hes_0),
    .edge_async_ack                       (edge_async_ack_ehx_mhu_hes_0),
    .dftcgen                              (dftcgen)
  );


  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_esxh_1

    mhuv2_f1_receiver #(
      .MHU_NUM_CH (MHU_ESXH1_NUM_CH)

    ) u_mhuv2_f1_receiver_esxh_1 (
      .pclk_rec                             (aclk),
      .presetn_rec                          (systopwarmresetn),
      .pwakeup_rec                          (psel_esh_mhu1), 
      .paddr_rec                            (paddr_esh_mhu1),
      .pwrite_rec                           (pwrite_esh_mhu1),
      .pwdata_rec                           (pwdata_esh_mhu1),
      .penable_rec                          (penable_esh_mhu1),
      .pselx_rec                            (psel_esh_mhu1),
      .prdata_rec                           (prdata_esh_mhu1),
      .pready_rec                           (pready_esh_mhu1),
      .pslverr_rec                          (pslverr_esh_mhu1),
      .qreqn_pclk_rec                       (qreqn_esxh_mhu1_aclk),
      .qacceptn_pclk_rec                    (qacceptn_esxh_mhu1_aclk),
      .qdeny_pclk_rec                       (qdeny_esxh_mhu1_aclk),
      .qactive_pclk_rec                     (qactive_esxh_mhu1_aclk),
      .qreqn_pwr_rec                        (qreqn_esh_mhu1_pwr),
      .qacceptn_pwr_rec                     (qacceptn_esh_mhu1_pwr),
      .qdeny_pwr_rec                        (qdeny_esh_mhu1_pwr),
      .mhu_irqcomb                          (esh_1_ehx_mhuint_int),
      .mhu_irq_reg                          (),
      .apb_async_req                        (apb_async_req_ehx_mhu_esh_1),
      .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_esh_1),
      .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_esh_1),
      .apb_async_ack                        (apb_async_ack_ehx_mhu_esh_1),
      .recawake_async                       (recawake_async_ehx_mhu_esh_1),
      .recwakeup_async                      (recwakeup_async_ehx_mhu_esh_1),
      .edge_async_req                       (edge_async_req_ehx_mhu_esh_1),
      .edge_async_ack                       (edge_async_ack_ehx_mhu_esh_1),
      .dftcgen                              (dftcgen)
      );

    end else begin: gen_mhu_esxh_1_tieoff

      assign prdata_esh_mhu1                       = 32'h0000_0000;
      assign pready_esh_mhu1                       = 1'b1;
      assign pslverr_esh_mhu1                      = 1'b1;

      assign qacceptn_esh_mhu1_pwr                 = qreqn_esh_mhu1_pwr;
      assign qdeny_esh_mhu1_pwr                    = 1'b0;

      assign apb_async_ack_ehx_mhu_esh_1           = 1'h0;
      assign apb_async_resp_payload_ehx_mhu_esh_1  = 33'h0;
      assign recawake_async_ehx_mhu_esh_1          = 1'b0;
      assign edge_async_req_ehx_mhu_esh_1          = {MHU_ESXH1_NUM_CH{1'b0}};

      assign esh_1_ehx_mhuint_int                  = 1'b0;

      assign qacceptn_esxh_mhu1_aclk               = 1'b0;
      assign qdeny_esxh_mhu1_aclk                  = 1'b0;
      assign qactive_esxh_mhu1_aclk                = 1'b0;
      
      assign unused_mhu_esxh = ( apb_async_req_ehx_mhu_esh_1)          |
                               (|apb_async_req_payload_ehx_mhu_esh_1)  |
                               ( recwakeup_async_ehx_mhu_esh_1)        |
                               (|edge_async_ack_ehx_mhu_esh_1)         |
                               ( psel_esh_mhu1)                        |
                               ( penable_esh_mhu1)                     |
                               (|pwdata_esh_mhu1)                      |
                               ( pwrite_esh_mhu1)                      |
                               (|paddr_esh_mhu1)                       |
                               ( qacceptn_esxh_mhu1_aclk)              |
                               ( qdeny_esxh_mhu1_aclk)                 |
                               ( qactive_esxh_mhu1_aclk);
    end
  endgenerate

  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_mhu_hesx_1

      mhuv2_f1_sender #(
        .MHU_NUM_CH (MHU_HESX1_NUM_CH)
      ) u_mhuv2_f1_sender_hesx_1 (
        .pclk_snd                             (aclk),
        .presetn_snd                          (systopwarmresetn),
        .pwakeup_snd                          (psel_hes_mhu1),
        .paddr_snd                            (paddr_hes_mhu1),
        .pwrite_snd                           (pwrite_hes_mhu1),
        .pwdata_snd                           (pwdata_hes_mhu1),
        .penable_snd                          (penable_hes_mhu1),
        .pselx_snd                            (psel_hes_mhu1),
        .prdata_snd                           (prdata_hes_mhu1),
        .pready_snd                           (pready_hes_mhu1),
        .pslverr_snd                          (pslverr_hes_mhu1),
        .qreqn_pclk_snd                       (qreqn_hesx_mhu1_aclk),
        .qacceptn_pclk_snd                    (qacceptn_hesx_mhu1_aclk),
        .qdeny_pclk_snd                       (qdeny_hesx_mhu1_aclk),
        .qactive_pclk_snd                     (qactive_hesx_mhu1_aclk),
        .apb_async_req                        (apb_async_req_ehx_mhu_hes_1),
        .apb_async_req_payload                (apb_async_req_payload_ehx_mhu_hes_1),
        .apb_async_resp_payload               (apb_async_resp_payload_ehx_mhu_hes_1),
        .apb_async_ack                        (apb_async_ack_ehx_mhu_hes_1),
        .recawake_async                       (recawake_async_ehx_mhu_hes_1),
        .recwakeup_async                      (i_recwakeup_async_ehx_mhu_hes_1),
        .int_access_nr2r                      (),
        .int_access_r2nr                      (),
        .int_irqcomb                          (hes_1_ehx_mhuint_int),
        .edge_async_req                       (edge_async_req_ehx_mhu_hes_1),
        .edge_async_ack                       (edge_async_ack_ehx_mhu_hes_1),
        .dftcgen                              (dftcgen)
        );

    end else begin: gen_mhu_hesx_1_tieoff

      assign prdata_hes_mhu1                      = 32'h0000_0000;
      assign pready_hes_mhu1                      = 1'b1;
      assign pslverr_hes_mhu1                     = 1'b1;

      assign apb_async_req_ehx_mhu_hes_1          = 1'h0;
      assign apb_async_req_payload_ehx_mhu_hes_1  = 49'h0;
      assign i_recwakeup_async_ehx_mhu_hes_1      = 1'b0;
      assign edge_async_ack_ehx_mhu_hes_1         = {MHU_HESX1_NUM_CH{1'b0}};

      assign hes_1_ehx_mhuint_int                 = 1'b0;

      assign qacceptn_hesx_mhu1_aclk              = 1'b0;
      assign qdeny_hesx_mhu1_aclk                 = 1'b0;
      assign qactive_hesx_mhu1_aclk               = 1'b0;
      
      assign unused_mhu_hesx = ( apb_async_ack_ehx_mhu_hes_1)          |
                               (|apb_async_resp_payload_ehx_mhu_hes_1) |
                               ( recawake_async_ehx_mhu_hes_1)         |
                               (|edge_async_req_ehx_mhu_hes_1)         |
                               ( psel_hes_mhu1)                        |
                               ( penable_hes_mhu1)                     |
                               (|pwdata_hes_mhu1)                      |
                               ( pwrite_hes_mhu1)                      |
                               (|paddr_hes_mhu1)                       |
                               ( qacceptn_hesx_mhu1_aclk)              |
                               ( qdeny_hesx_mhu1_aclk)                 |
                               ( qactive_hesx_mhu1_aclk);

    end
  endgenerate



  sse710_adb400_r3_axi4_mst_wrapper #(
    .ADDR_WIDTH             (EXT_SYSX_MEM_ADDR_WIDTH),
    .DATA_WIDTH             (EXT_SYSX_MEM_DATA_WIDTH),
    .AWID_WIDTH             (EXT_SYSX_MEM_AWID_WIDTH),
    .ARID_WIDTH             (EXT_SYSX_MEM_ARID_WIDTH),
    .AWUSER_WIDTH           (EXT_SYSX_MEM_AWUSER_WIDTH),
    .WUSER_WIDTH            (EXT_SYSX_MEM_WUSER_WIDTH),
    .BUSER_WIDTH            (EXT_SYSX_MEM_BUSER_WIDTH),
    .ARUSER_WIDTH           (EXT_SYSX_MEM_ARUSER_WIDTH),
    .RUSER_WIDTH            (EXT_SYSX_MEM_RUSER_WIDTH),
    .AW_FIFO_DEPTH          (EXT_SYSX_MEM_AW_FIFO_DEPTH),
    .W_FIFO_DEPTH           (EXT_SYSX_MEM_W_FIFO_DEPTH),
    .B_FIFO_DEPTH           (EXT_SYSX_MEM_B_FIFO_DEPTH),
    .AR_FIFO_DEPTH          (EXT_SYSX_MEM_AR_FIFO_DEPTH),
    .R_FIFO_DEPTH           (EXT_SYSX_MEM_R_FIFO_DEPTH),
    .AW_OPREG               (1),
    .W_OPREG                (1),
    .AR_OPREG               (1),
    .MI_SYNC_LEVELS         (2),
    .AW_PAYLOAD_WIDTH       (EXT_SYSX_MEM_AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH        (EXT_SYSX_MEM_W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH        (EXT_SYSX_MEM_B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH       (EXT_SYSX_MEM_AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH        (EXT_SYSX_MEM_R_PAYLOAD_WIDTH)
  ) u_sse710_adb400_r3_axi4_mst_wrapper (
    .aclkm                          (aclk),
    .aresetnm                       (systopwarmresetn),

    .clkqreqnm_i                    (qreqn_axi_adb_aclk),
    .clkqacceptnm_o                 (qacceptn_axi_adb_aclk),
    .clkqdenym_o                    (qdeny_axi_adb_aclk),
    .clkqactivem_o                  (qactive_axi_adb_aclk),

    .wakeupm_o                      (awakeup_extsysx_axis),
    .awvalidm                       (awvalid_extsysx_axis),
    .awreadym                       (awready_extsysx_axis),
    .awuserm                        (),
    .awidm                          (awid_extsysx_axis),
    .awaddrm                        (awaddr_extsysx_axis),
    .awregionm                      (awregion_extsysx_axis),
    .awlenm                         (awlen_extsysx_axis),
    .awsizem                        (awsize_extsysx_axis),
    .awburstm                       (awburst_extsysx_axis),
    .awlockm                        (awlock_extsysx_axis),
    .awcachem                       (awcache_extsysx_axis),
    .awprotm                        (awprot_extsysx_axis),
    .awqosm                         (),

    .wvalidm                        (wvalid_extsysx_axis),
    .wreadym                        (wready_extsysx_axis),
    .wuserm                         (),
    .wdatam                         (wdata_extsysx_axis),
    .wstrbm                         (wstrb_extsysx_axis),
    .wlastm                         (wlast_extsysx_axis),

    .bvalidm                        (bvalid_extsysx_axis),
    .breadym                        (bready_extsysx_axis),
    .buserm                         (1'b0),
    .bidm                           (bid_extsysx_axis),
    .brespm                         (bresp_extsysx_axis),

    .arvalidm                       (arvalid_extsysx_axis),
    .arreadym                       (arready_extsysx_axis),
    .aruserm                        (),
    .aridm                          (arid_extsysx_axis),
    .araddrm                        (araddr_extsysx_axis),
    .arregionm                      (arregion_extsysx_axis),
    .arlenm                         (arlen_extsysx_axis),
    .arsizem                        (arsize_extsysx_axis),
    .arburstm                       (arburst_extsysx_axis),
    .arlockm                        (arlock_extsysx_axis),
    .arcachem                       (arcache_extsysx_axis),
    .arprotm                        (arprot_extsysx_axis),
    .arqosm                         (),

    .rvalidm                        (rvalid_extsysx_axis),
    .rreadym                        (rready_extsysx_axis),
    .ruserm                         (1'b0),
    .ridm                           (rid_extsysx_axis),
    .rdatam                         (rdata_extsysx_axis),
    .rrespm                         (rresp_extsysx_axis),
    .rlastm                         (rlast_extsysx_axis),

    .slvmustacceptreqn_async        (slvmustacceptreqn_async_ehx),
    .slvcandenyreqn_async           (slvcandenyreqn_async_ehx),
    .slvacceptn_async               (slvacceptn_async_ehx),
    .slvdeny_async                  (slvdeny_async_ehx),

    .si_to_mi_wakeup_async          (si_to_mi_wakeup_async_ehx),
    .mi_to_si_wakeup_async          (mi_to_si_wakeup_async_ehx),

    .aw_wr_ptr_async                (aw_wr_ptr_async_ehx),
    .aw_rd_ptr_async                (aw_rd_ptr_async_ehx),
    .aw_payld_async                 (aw_payld_async_ehx),

    .w_wr_ptr_async                 (w_wr_ptr_async_ehx),
    .w_rd_ptr_async                 (w_rd_ptr_async_ehx),
    .w_payld_async                  (w_payld_async_ehx),

    .b_wr_ptr_async                 (b_wr_ptr_async_ehx),
    .b_rd_ptr_async                 (b_rd_ptr_async_ehx),
    .b_payld_async                  (b_payld_async_ehx),

    .ar_wr_ptr_async                (ar_wr_ptr_async_ehx),
    .ar_rd_ptr_async                (ar_rd_ptr_async_ehx),
    .ar_payld_async                 (ar_payld_async_ehx),

    .r_wr_ptr_async                 (r_wr_ptr_async_ehx),
    .r_rd_ptr_async                 (r_rd_ptr_async_ehx),
    .r_payld_async                  (r_payld_async_ehx),

    .dftrstdisablem                 (dftrstdisable)
  );



  assign aruser_extsysx_axis[9:2] = EXT_SYS_NUM + 8'h10;
  assign aruser_extsysx_axis[1:0] = 2'b00;
  assign awuser_extsysx_axis[9:2] = EXT_SYS_NUM + 8'h10;
  assign awuser_extsysx_axis[1:0] = 2'b00;


  arm_element_std_or2 u_arm_element_std_or2_1 (
    .A  (i_recwakeup_async_ehx_mhu_hes_0),
    .B  (i_recwakeup_async_ehx_mhu_hes_1),
    .Y  (qactive_extsysx_mhupwrreq)
    );
    
  assign recwakeup_async_ehx_mhu_hes_0 = i_recwakeup_async_ehx_mhu_hes_0;
  assign recwakeup_async_ehx_mhu_hes_1 = i_recwakeup_async_ehx_mhu_hes_1;


  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (NUM_CLK_QCH),
    .CTRL_Q_CH_SYNC    (1),  
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q_clk (
    .clk               (aclk),
    .reset_n           (systopwarmresetn),

    .ctrl_qreqn_i      (qreqn_ehx_aclk),
    .ctrl_qacceptn_o   (qacceptn_ehx_aclk),
    .ctrl_qdeny_o      (qdeny_ehx_aclk),
    .ctrl_qactive_o    (qactive_ehx_aclk),

    .dev_qreqn_o       (qreqn_lpdq_clk),
    .dev_qacceptn_i    (qacceptn_lpdq_clk),
    .dev_qdeny_i       (qdeny_lpdq_clk),
    .dev_qactive_i     (qactive_lpdq_clk),

    .clk_qactive_o     (),

    .dftcgen           (dftcgen)
    );

  assign qreqn_axi_adb_aclk   = qreqn_lpdq_clk[0];
  assign qreqn_esxh_mhu0_aclk = qreqn_lpdq_clk[1];
  assign qreqn_hesx_mhu0_aclk = qreqn_lpdq_clk[2];

  assign qacceptn_lpdq_clk[0] = qacceptn_axi_adb_aclk;
  assign qacceptn_lpdq_clk[1] = qacceptn_esxh_mhu0_aclk;
  assign qacceptn_lpdq_clk[2] = qacceptn_hesx_mhu0_aclk;

  assign qdeny_lpdq_clk[0]    = qdeny_axi_adb_aclk;
  assign qdeny_lpdq_clk[1]    = qdeny_esxh_mhu0_aclk;
  assign qdeny_lpdq_clk[2]    = qdeny_hesx_mhu0_aclk;

  assign qactive_lpdq_clk[0]  = qactive_axi_adb_aclk;
  assign qactive_lpdq_clk[1]  = qactive_esxh_mhu0_aclk;
  assign qactive_lpdq_clk[2]  = qactive_hesx_mhu0_aclk;

  generate
    if (EXT_SYSX_TZ_SPT == 1) begin: gen_clk_ctrl_tz_spt

      assign qreqn_esxh_mhu1_aclk = qreqn_lpdq_clk[3];
      assign qreqn_hesx_mhu1_aclk = qreqn_lpdq_clk[4];

      assign qacceptn_lpdq_clk[3] = qacceptn_esxh_mhu1_aclk;
      assign qacceptn_lpdq_clk[4] = qacceptn_hesx_mhu1_aclk;

      assign qdeny_lpdq_clk[3]    = qdeny_esxh_mhu1_aclk;
      assign qdeny_lpdq_clk[4]    = qdeny_hesx_mhu1_aclk;

      assign qactive_lpdq_clk[3]  = qactive_esxh_mhu1_aclk;
      assign qactive_lpdq_clk[4]  = qactive_hesx_mhu1_aclk;

    end
  endgenerate

  always @(posedge aclk or negedge systopwarmresetn)
  begin
    if(!systopwarmresetn)
    begin
      hes_0_ehx_mhuint_r <= 1'b0;
      esh_0_ehx_mhuint_r <= 1'b0;
      hes_1_ehx_mhuint_r <= 1'b0;
      esh_1_ehx_mhuint_r <= 1'b0;
    end
    else
    begin
      hes_0_ehx_mhuint_r <= hes_0_ehx_mhuint_int;
      esh_0_ehx_mhuint_r <= esh_0_ehx_mhuint_int;
      hes_1_ehx_mhuint_r <= hes_1_ehx_mhuint_int;
      esh_1_ehx_mhuint_r <= esh_1_ehx_mhuint_int;
    end
  end

  assign hes_0_ehx_mhuint = hes_0_ehx_mhuint_r;
  assign esh_0_ehx_mhuint = esh_0_ehx_mhuint_r;
  assign hes_1_ehx_mhuint = hes_1_ehx_mhuint_r;
  assign esh_1_ehx_mhuint = esh_1_ehx_mhuint_r;


  assign unused = |{pstrb_esh_mhu0,
                    pprot_esh_mhu0,
                    pstrb_esh_mhu1,
                    pprot_esh_mhu1,
                    pstrb_hes_mhu0,
                    pprot_hes_mhu0,
                    pstrb_hes_mhu1,
                    pprot_hes_mhu1};

endmodule
