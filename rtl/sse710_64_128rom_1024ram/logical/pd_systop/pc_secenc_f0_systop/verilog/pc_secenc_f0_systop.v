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

module pc_secenc_f0_systop #(

  parameter  MHU_HSE0_NUM_CH         = 7'd2, 
  parameter  MHU_SEH0_NUM_CH         = 7'd2, 
  parameter  MHU_HSE1_NUM_CH         = 7'd2, 
  parameter  MHU_SEH1_NUM_CH         = 7'd2, 

  parameter  SECENC_ADDR_WIDTH       = 32,
  parameter  SECENC_DATA_WIDTH       = 32,
  parameter  SECENC_AWID_WIDTH       = 8,
  parameter  SECENC_ARID_WIDTH       = 8,
  parameter  SECENC_AWUSER_WIDTH     = 0,
  parameter  SECENC_WUSER_WIDTH      = 0,
  parameter  SECENC_BUSER_WIDTH      = 0,
  parameter  SECENC_ARUSER_WIDTH     = 0,
  parameter  SECENC_RUSER_WIDTH      = 0,
  parameter  SECENC_AW_FIFO_DEPTH    = 4,
  parameter  SECENC_W_FIFO_DEPTH     = 6,
  parameter  SECENC_B_FIFO_DEPTH     = 2,
  parameter  SECENC_AR_FIFO_DEPTH    = 4,
  parameter  SECENC_R_FIFO_DEPTH     = 6,
  parameter  SECENC_AW_PAYLOAD_WIDTH = 236,
  parameter  SECENC_W_PAYLOAD_WIDTH  = 222,
  parameter  SECENC_B_PAYLOAD_WIDTH  = 24,
  parameter  SECENC_AR_PAYLOAD_WIDTH = 236,
  parameter  SECENC_R_PAYLOAD_WIDTH  = 264

  )(
    input  wire                               aclk,

    input  wire                               systopwarmresetn,

    output wire                               awakeup_secenc_axis,
    output wire                               awid_secenc_axis,
    output wire [31:0]                        awaddr_secenc_axis,
    output wire [3:0]                         awregion_secenc_axis,
    output wire [7:0]                         awlen_secenc_axis,
    output wire [2:0]                         awsize_secenc_axis,
    output wire [1:0]                         awburst_secenc_axis,
    output wire                               awlock_secenc_axis,
    output wire [3:0]                         awcache_secenc_axis,
    output wire [2:0]                         awprot_secenc_axis,
    output wire                               awvalid_secenc_axis,
    output wire [9:0]                         awuser_secenc_axis,
    output wire [3:0]                         awqos_secenc_axis,
    input  wire                               awready_secenc_axis,
    output wire [3:0]                         wstrb_secenc_axis,
    output wire                               wlast_secenc_axis,
    output wire                               wvalid_secenc_axis,
    output wire [31:0]                        wdata_secenc_axis,
    input  wire                               wready_secenc_axis,
    input  wire                               bid_secenc_axis,
    input  wire [1:0]                         bresp_secenc_axis,
    input  wire                               bvalid_secenc_axis,
    output wire                               bready_secenc_axis,
    input  wire                               buser_secenc_axis,
    output wire                               arid_secenc_axis,
    output wire [31:0]                        araddr_secenc_axis,
    output wire [3:0]                         arregion_secenc_axis,
    output wire [7:0]                         arlen_secenc_axis,
    output wire [2:0]                         arsize_secenc_axis,
    output wire [1:0]                         arburst_secenc_axis,
    output wire                               arlock_secenc_axis,
    output wire [3:0]                         arcache_secenc_axis,
    output wire [2:0]                         arprot_secenc_axis,
    output wire                               arvalid_secenc_axis,
    output wire [9:0]                         aruser_secenc_axis,
    output wire [3:0]                         arqos_secenc_axis,
    input  wire                               arready_secenc_axis,
    input  wire                               rid_secenc_axis,
    input  wire [1:0]                         rresp_secenc_axis,
    input  wire                               rlast_secenc_axis,
    input  wire                               rvalid_secenc_axis,
    input  wire [31:0]                        rdata_secenc_axis,
    output wire                               rready_secenc_axis,
    input  wire                               ruser_secenc_axis,

    input  wire                               slvmustacceptreqn_async_secenc,
    input  wire                               slvcandenyreqn_async_secenc,
    output wire                               slvacceptn_async_secenc,
    output wire                               slvdeny_async_secenc,
    input  wire                               si_to_mi_wakeup_async_secenc,
    output wire                               mi_to_si_wakeup_async_secenc,
    input  wire [SECENC_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_secenc,
    output wire [SECENC_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_secenc,
    input  wire [SECENC_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_secenc,
    input  wire [SECENC_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_secenc,
    output wire [SECENC_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_secenc,
    input  wire [SECENC_W_PAYLOAD_WIDTH-1:0]  w_payld_async_secenc,
    output wire [SECENC_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_secenc,
    input  wire [SECENC_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_secenc,
    output wire [SECENC_B_PAYLOAD_WIDTH-1:0]  b_payld_async_secenc,
    input  wire [SECENC_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_secenc,
    output wire [SECENC_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_secenc,
    input  wire [SECENC_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_secenc,
    output wire [SECENC_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_secenc,
    input  wire [SECENC_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_secenc,
    output wire [SECENC_R_PAYLOAD_WIDTH-1:0]  r_payld_async_secenc,

    input  wire                               psel_hse0_mhu_apb,
    input  wire                               penable_hse0_mhu_apb,
    input  wire [31:0]                        paddr_hse0_mhu_apb,
    input  wire                               pwrite_hse0_mhu_apb,
    input  wire [31:0]                        pwdata_hse0_mhu_apb,
    input  wire [3:0]                         pstrb_hse0_mhu_apb,
    input  wire [2:0]                         pprot_hse0_mhu_apb,
    output wire [31:0]                        prdata_hse0_mhu_apb,
    output wire                               pready_hse0_mhu_apb,
    output wire                               pslverr_hse0_mhu_apb,

    input  wire                               psel_seh0_mhu_apb,
    input  wire                               penable_seh0_mhu_apb,
    input  wire [31:0]                        paddr_seh0_mhu_apb,
    input  wire                               pwrite_seh0_mhu_apb,
    input  wire [31:0]                        pwdata_seh0_mhu_apb,
    input  wire [3:0]                         pstrb_seh0_mhu_apb,
    input  wire [2:0]                         pprot_seh0_mhu_apb,
    output wire [31:0]                        prdata_seh0_mhu_apb,
    output wire                               pready_seh0_mhu_apb,
    output wire                               pslverr_seh0_mhu_apb,

    input  wire                               psel_hse1_mhu_apb,
    input  wire                               penable_hse1_mhu_apb,
    input  wire [31:0]                        paddr_hse1_mhu_apb,
    input  wire                               pwrite_hse1_mhu_apb,
    input  wire [31:0]                        pwdata_hse1_mhu_apb,
    input  wire [3:0]                         pstrb_hse1_mhu_apb,
    input  wire [2:0]                         pprot_hse1_mhu_apb,
    output wire [31:0]                        prdata_hse1_mhu_apb,
    output wire                               pready_hse1_mhu_apb,
    output wire                               pslverr_hse1_mhu_apb,

    input  wire                               psel_seh1_mhu_apb,
    input  wire                               penable_seh1_mhu_apb,
    input  wire [31:0]                        paddr_seh1_mhu_apb,
    input  wire                               pwrite_seh1_mhu_apb,
    input  wire [31:0]                        pwdata_seh1_mhu_apb,
    input  wire [3:0]                         pstrb_seh1_mhu_apb,
    input  wire [2:0]                         pprot_seh1_mhu_apb,
    output wire [31:0]                        prdata_seh1_mhu_apb,
    output wire                               pready_seh1_mhu_apb,
    output wire                               pslverr_seh1_mhu_apb,

    output wire                               hse0_mhuint,
    output wire                               seh0_mhuint,
    output wire                               hse1_mhuint,
    output wire                               seh1_mhuint,

    input  wire                               apb_async_req_seh0_mhu,
    input  wire [48:0]                        apb_async_req_payload_seh0_mhu,
    output wire [32:0]                        apb_async_resp_payload_seh0_mhu,
    output wire                               apb_async_ack_seh0_mhu,
    output wire                               recawake_async_seh0_mhu,
    input  wire                               recwakeup_async_seh0_mhu,
    output wire [MHU_SEH0_NUM_CH-1:0]         edge_async_req_seh0_mhu,
    input  wire [MHU_SEH0_NUM_CH-1:0]         edge_async_ack_seh0_mhu,

    output wire                               apb_async_req_hse0_mhu,
    output wire [48:0]                        apb_async_req_payload_hse0_mhu,
    input  wire [32:0]                        apb_async_resp_payload_hse0_mhu,
    input  wire                               apb_async_ack_hse0_mhu,
    input  wire                               recawake_async_hse0_mhu,
    output wire                               recwakeup_async_hse0_mhu,
    input  wire [MHU_HSE0_NUM_CH-1:0]         edge_async_req_hse0_mhu,
    output wire [MHU_HSE0_NUM_CH-1:0]         edge_async_ack_hse0_mhu,

    input  wire                               apb_async_req_seh1_mhu,
    input  wire [48:0]                        apb_async_req_payload_seh1_mhu,
    output wire [32:0]                        apb_async_resp_payload_seh1_mhu,
    output wire                               apb_async_ack_seh1_mhu,
    output wire                               recawake_async_seh1_mhu,
    input  wire                               recwakeup_async_seh1_mhu,
    output wire [MHU_SEH1_NUM_CH-1:0]         edge_async_req_seh1_mhu,
    input  wire [MHU_SEH1_NUM_CH-1:0]         edge_async_ack_seh1_mhu,

    output wire                               apb_async_req_hse1_mhu,
    output wire [48:0]                        apb_async_req_payload_hse1_mhu,
    input  wire [32:0]                        apb_async_resp_payload_hse1_mhu,
    input  wire                               apb_async_ack_hse1_mhu,
    input  wire                               recawake_async_hse1_mhu,
    output wire                               recwakeup_async_hse1_mhu,
    input  wire [MHU_HSE1_NUM_CH-1:0]         edge_async_req_hse1_mhu,
    output wire [MHU_HSE1_NUM_CH-1:0]         edge_async_ack_hse1_mhu,

    input  wire                               qreqn_se_aclk,
    output wire                               qacceptn_se_aclk,
    output wire                               qdeny_se_aclk,
    output wire                               qactive_se_aclk,

    input  wire                               qreqn_seh0_mhu_pwr,
    output wire                               qacceptn_seh0_mhu_pwr,
    output wire                               qdeny_seh0_mhu_pwr,

    input  wire                               qreqn_seh1_mhu_pwr,
    output wire                               qacceptn_seh1_mhu_pwr,
    output wire                               qdeny_seh1_mhu_pwr,

    input  wire                               dftcgen,
    input  wire                               dftrstdisable
    );


  wire           qreqn_se_axi_aclk;
  wire           qacceptn_se_axi_aclk;
  wire           qdeny_se_axi_aclk;
  wire           qactive_se_axi_aclk;

  wire           qreqn_seh0_aclk;
  wire           qacceptn_seh0_aclk;
  wire           qdeny_seh0_aclk;
  wire           qactive_seh0_aclk;

  wire           qreqn_hse0_aclk;
  wire           qacceptn_hse0_aclk;
  wire           qdeny_hse0_aclk;
  wire           qactive_hse0_aclk;

  wire           qreqn_seh1_aclk;
  wire           qacceptn_seh1_aclk;
  wire           qdeny_seh1_aclk;
  wire           qactive_seh1_aclk;

  wire           qreqn_hse1_aclk;
  wire           qacceptn_hse1_aclk;
  wire           qdeny_hse1_aclk;
  wire           qactive_hse1_aclk;

  wire [4:0]     qreqn_lpdq_clk;
  wire [4:0]     qacceptn_lpdq_clk;
  wire [4:0]     qdeny_lpdq_clk;
  wire [4:0]     qactive_lpdq_clk;

  reg            hse0_mhuint_r;
  reg            seh0_mhuint_r;
  reg            hse1_mhuint_r;
  reg            seh1_mhuint_r;
  wire           hse0_mhuint_int;
  wire           seh0_mhuint_int;
  wire           hse1_mhuint_int;
  wire           seh1_mhuint_int;

  wire           unused;


  mhuv2_f1_receiver #(
    .MHU_NUM_CH (MHU_SEH0_NUM_CH)

  ) u_mhuv2_f1_receiver_seh_0 (
    .pclk_rec                             (aclk),
    .presetn_rec                          (systopwarmresetn),
    .pwakeup_rec                          (psel_seh0_mhu_apb), 
    .paddr_rec                            (paddr_seh0_mhu_apb),
    .pwrite_rec                           (pwrite_seh0_mhu_apb),
    .pwdata_rec                           (pwdata_seh0_mhu_apb),
    .penable_rec                          (penable_seh0_mhu_apb),
    .pselx_rec                            (psel_seh0_mhu_apb),
    .prdata_rec                           (prdata_seh0_mhu_apb),
    .pready_rec                           (pready_seh0_mhu_apb),
    .pslverr_rec                          (pslverr_seh0_mhu_apb),
    .qreqn_pclk_rec                       (qreqn_seh0_aclk),
    .qacceptn_pclk_rec                    (qacceptn_seh0_aclk),
    .qdeny_pclk_rec                       (qdeny_seh0_aclk),
    .qactive_pclk_rec                     (qactive_seh0_aclk),
    .qreqn_pwr_rec                        (qreqn_seh0_mhu_pwr),
    .qacceptn_pwr_rec                     (qacceptn_seh0_mhu_pwr),
    .qdeny_pwr_rec                        (qdeny_seh0_mhu_pwr),
    .mhu_irqcomb                          (seh0_mhuint_int),
    .mhu_irq_reg                          (),
    .apb_async_req                        (apb_async_req_seh0_mhu),
    .apb_async_req_payload                (apb_async_req_payload_seh0_mhu),
    .apb_async_resp_payload               (apb_async_resp_payload_seh0_mhu),
    .apb_async_ack                        (apb_async_ack_seh0_mhu),
    .recawake_async                       (recawake_async_seh0_mhu),
    .recwakeup_async                      (recwakeup_async_seh0_mhu),
    .edge_async_req                       (edge_async_req_seh0_mhu),
    .edge_async_ack                       (edge_async_ack_seh0_mhu),
    .dftcgen                              (dftcgen)
  );


  mhuv2_f1_sender #(
    .MHU_NUM_CH (MHU_HSE0_NUM_CH)
  ) u_mhuv2_f1_sender_hse_0 (
    .pclk_snd                             (aclk),
    .presetn_snd                          (systopwarmresetn),
    .pwakeup_snd                          (psel_hse0_mhu_apb), 
    .paddr_snd                            (paddr_hse0_mhu_apb),
    .pwrite_snd                           (pwrite_hse0_mhu_apb),
    .pwdata_snd                           (pwdata_hse0_mhu_apb),
    .penable_snd                          (penable_hse0_mhu_apb),
    .pselx_snd                            (psel_hse0_mhu_apb),
    .prdata_snd                           (prdata_hse0_mhu_apb),
    .pready_snd                           (pready_hse0_mhu_apb),
    .pslverr_snd                          (pslverr_hse0_mhu_apb),
    .qreqn_pclk_snd                       (qreqn_hse0_aclk),
    .qacceptn_pclk_snd                    (qacceptn_hse0_aclk),
    .qdeny_pclk_snd                       (qdeny_hse0_aclk),
    .qactive_pclk_snd                     (qactive_hse0_aclk),
    .apb_async_req                        (apb_async_req_hse0_mhu),
    .apb_async_req_payload                (apb_async_req_payload_hse0_mhu),
    .apb_async_resp_payload               (apb_async_resp_payload_hse0_mhu),
    .apb_async_ack                        (apb_async_ack_hse0_mhu),
    .recawake_async                       (recawake_async_hse0_mhu),
    .recwakeup_async                      (recwakeup_async_hse0_mhu),
    .int_access_nr2r                      (),
    .int_access_r2nr                      (),
    .int_irqcomb                          (hse0_mhuint_int),
    .edge_async_req                       (edge_async_req_hse0_mhu),
    .edge_async_ack                       (edge_async_ack_hse0_mhu),
    .dftcgen                              (dftcgen)
  );


    mhuv2_f1_receiver #(
      .MHU_NUM_CH (MHU_SEH1_NUM_CH)

    ) u_mhuv2_f1_receiver_seh_1 (
      .pclk_rec                             (aclk),
      .presetn_rec                          (systopwarmresetn),
      .pwakeup_rec                          (psel_seh1_mhu_apb),  
      .paddr_rec                            (paddr_seh1_mhu_apb),
      .pwrite_rec                           (pwrite_seh1_mhu_apb),
      .pwdata_rec                           (pwdata_seh1_mhu_apb),
      .penable_rec                          (penable_seh1_mhu_apb),
      .pselx_rec                            (psel_seh1_mhu_apb),
      .prdata_rec                           (prdata_seh1_mhu_apb),
      .pready_rec                           (pready_seh1_mhu_apb),
      .pslverr_rec                          (pslverr_seh1_mhu_apb),
      .qreqn_pclk_rec                       (qreqn_seh1_aclk),
      .qacceptn_pclk_rec                    (qacceptn_seh1_aclk),
      .qdeny_pclk_rec                       (qdeny_seh1_aclk),
      .qactive_pclk_rec                     (qactive_seh1_aclk),
      .qreqn_pwr_rec                        (qreqn_seh1_mhu_pwr),
      .qacceptn_pwr_rec                     (qacceptn_seh1_mhu_pwr),
      .qdeny_pwr_rec                        (qdeny_seh1_mhu_pwr),
      .mhu_irqcomb                          (seh1_mhuint_int),
      .mhu_irq_reg                          (),
      .apb_async_req                        (apb_async_req_seh1_mhu),
      .apb_async_req_payload                (apb_async_req_payload_seh1_mhu),
      .apb_async_resp_payload               (apb_async_resp_payload_seh1_mhu),
      .apb_async_ack                        (apb_async_ack_seh1_mhu),
      .recawake_async                       (recawake_async_seh1_mhu),
      .recwakeup_async                      (recwakeup_async_seh1_mhu),
      .edge_async_req                       (edge_async_req_seh1_mhu),
      .edge_async_ack                       (edge_async_ack_seh1_mhu),
      .dftcgen                              (dftcgen)
      );


      mhuv2_f1_sender #(
        .MHU_NUM_CH (MHU_HSE1_NUM_CH)
      ) u_mhuv2_f1_sender_hse_1 (
        .pclk_snd                             (aclk),
        .presetn_snd                          (systopwarmresetn),
        .pwakeup_snd                          (psel_hse1_mhu_apb), 
        .paddr_snd                            (paddr_hse1_mhu_apb),
        .pwrite_snd                           (pwrite_hse1_mhu_apb),
        .pwdata_snd                           (pwdata_hse1_mhu_apb),
        .penable_snd                          (penable_hse1_mhu_apb),
        .pselx_snd                            (psel_hse1_mhu_apb),
        .prdata_snd                           (prdata_hse1_mhu_apb),
        .pready_snd                           (pready_hse1_mhu_apb),
        .pslverr_snd                          (pslverr_hse1_mhu_apb),
        .qreqn_pclk_snd                       (qreqn_hse1_aclk),
        .qacceptn_pclk_snd                    (qacceptn_hse1_aclk),
        .qdeny_pclk_snd                       (qdeny_hse1_aclk),
        .qactive_pclk_snd                     (qactive_hse1_aclk),
        .apb_async_req                        (apb_async_req_hse1_mhu),
        .apb_async_req_payload                (apb_async_req_payload_hse1_mhu),
        .apb_async_resp_payload               (apb_async_resp_payload_hse1_mhu),
        .apb_async_ack                        (apb_async_ack_hse1_mhu),
        .recawake_async                       (recawake_async_hse1_mhu),
        .recwakeup_async                      (recwakeup_async_hse1_mhu),
        .int_access_nr2r                      (),
        .int_access_r2nr                      (),
        .int_irqcomb                          (hse1_mhuint_int),
        .edge_async_req                       (edge_async_req_hse1_mhu),
        .edge_async_ack                       (edge_async_ack_hse1_mhu),
        .dftcgen                              (dftcgen)
        );


  sse710_adb400_r3_axi4_mst_wrapper #(
    .ADDR_WIDTH              (SECENC_ADDR_WIDTH),
    .DATA_WIDTH              (SECENC_DATA_WIDTH),
    .AWID_WIDTH              (SECENC_AWID_WIDTH),
    .ARID_WIDTH              (SECENC_ARID_WIDTH),
    .AWUSER_WIDTH            (SECENC_AWUSER_WIDTH),
    .WUSER_WIDTH             (SECENC_WUSER_WIDTH),
    .BUSER_WIDTH             (SECENC_BUSER_WIDTH),
    .ARUSER_WIDTH            (SECENC_ARUSER_WIDTH),
    .RUSER_WIDTH             (SECENC_RUSER_WIDTH),
    .AW_FIFO_DEPTH           (SECENC_AW_FIFO_DEPTH),
    .W_FIFO_DEPTH            (SECENC_W_FIFO_DEPTH),
    .B_FIFO_DEPTH            (SECENC_B_FIFO_DEPTH),
    .AR_FIFO_DEPTH           (SECENC_AR_FIFO_DEPTH),
    .R_FIFO_DEPTH            (SECENC_R_FIFO_DEPTH),
    .AW_OPREG                (1),
    .W_OPREG                 (1),
    .AR_OPREG                (1),
    .MI_SYNC_LEVELS          (2),
    .AW_PAYLOAD_WIDTH        (SECENC_AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH         (SECENC_W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH         (SECENC_B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH        (SECENC_AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH         (SECENC_R_PAYLOAD_WIDTH)
  ) u_sse710_adb400_r3_axi4_mst_wrapper (   
    .aclkm                          (aclk),
    .aresetnm                       (systopwarmresetn),

    .clkqreqnm_i                    (qreqn_se_axi_aclk),
    .clkqacceptnm_o                 (qacceptn_se_axi_aclk),
    .clkqdenym_o                    (qdeny_se_axi_aclk),
    .clkqactivem_o                  (qactive_se_axi_aclk),

    .wakeupm_o                      (awakeup_secenc_axis),
    .awvalidm                       (awvalid_secenc_axis),
    .awreadym                       (awready_secenc_axis),
    .awuserm                        (),
    .awidm                          (awid_secenc_axis),
    .awaddrm                        (awaddr_secenc_axis),
    .awregionm                      (awregion_secenc_axis),
    .awlenm                         (awlen_secenc_axis),
    .awsizem                        (awsize_secenc_axis),
    .awburstm                       (awburst_secenc_axis),
    .awlockm                        (awlock_secenc_axis),
    .awcachem                       (awcache_secenc_axis),
    .awprotm                        (awprot_secenc_axis),
    .awqosm                         (awqos_secenc_axis),

    .wvalidm                        (wvalid_secenc_axis),
    .wreadym                        (wready_secenc_axis),
    .wuserm                         (),
    .wdatam                         (wdata_secenc_axis),
    .wstrbm                         (wstrb_secenc_axis),
    .wlastm                         (wlast_secenc_axis),

    .bvalidm                        (bvalid_secenc_axis),
    .breadym                        (bready_secenc_axis),
    .buserm                         (buser_secenc_axis),
    .bidm                           (bid_secenc_axis),
    .brespm                         (bresp_secenc_axis),

    .arvalidm                       (arvalid_secenc_axis),
    .arreadym                       (arready_secenc_axis),
    .aruserm                        (),
    .aridm                          (arid_secenc_axis),
    .araddrm                        (araddr_secenc_axis),
    .arregionm                      (arregion_secenc_axis),
    .arlenm                         (arlen_secenc_axis),
    .arsizem                        (arsize_secenc_axis),
    .arburstm                       (arburst_secenc_axis),
    .arlockm                        (arlock_secenc_axis),
    .arcachem                       (arcache_secenc_axis),
    .arprotm                        (arprot_secenc_axis),
    .arqosm                         (arqos_secenc_axis),

    .rvalidm                        (rvalid_secenc_axis),
    .rreadym                        (rready_secenc_axis),
    .ruserm                         (ruser_secenc_axis),
    .ridm                           (rid_secenc_axis),
    .rdatam                         (rdata_secenc_axis),
    .rrespm                         (rresp_secenc_axis),
    .rlastm                         (rlast_secenc_axis),

    .slvmustacceptreqn_async        (slvmustacceptreqn_async_secenc),
    .slvcandenyreqn_async           (slvcandenyreqn_async_secenc),
    .slvacceptn_async               (slvacceptn_async_secenc),
    .slvdeny_async                  (slvdeny_async_secenc),

    .si_to_mi_wakeup_async          (si_to_mi_wakeup_async_secenc),
    .mi_to_si_wakeup_async          (mi_to_si_wakeup_async_secenc),

    .aw_wr_ptr_async                (aw_wr_ptr_async_secenc),
    .aw_rd_ptr_async                (aw_rd_ptr_async_secenc),
    .aw_payld_async                 (aw_payld_async_secenc),

    .w_wr_ptr_async                 (w_wr_ptr_async_secenc),
    .w_rd_ptr_async                 (w_rd_ptr_async_secenc),
    .w_payld_async                  (w_payld_async_secenc),

    .b_wr_ptr_async                 (b_wr_ptr_async_secenc),
    .b_rd_ptr_async                 (b_rd_ptr_async_secenc),
    .b_payld_async                  (b_payld_async_secenc),

    .ar_wr_ptr_async                (ar_wr_ptr_async_secenc),
    .ar_rd_ptr_async                (ar_rd_ptr_async_secenc),
    .ar_payld_async                 (ar_payld_async_secenc),

    .r_wr_ptr_async                 (r_wr_ptr_async_secenc),
    .r_rd_ptr_async                 (r_rd_ptr_async_secenc),
    .r_payld_async                  (r_payld_async_secenc),

    .dftrstdisablem                 (dftrstdisable)
  );


  assign aruser_secenc_axis[9:2] = 8'h00;
  assign aruser_secenc_axis[1:0] = 2'b00;
  assign awuser_secenc_axis[9:2] = 8'h00;
  assign awuser_secenc_axis[1:0] = 2'b00;

  pck600_lpd_q #(
    .SEQUENCER         (0),
    .NUM_QCHL          (5),
    .CTRL_Q_CH_SYNC    (1), 
    .DEV_Q_CH_SYNC     (0),
    .ACTIVE_DENY       (0)
  ) u_pck600_lpd_q (
    .clk               (aclk),
    .reset_n           (systopwarmresetn),

    .ctrl_qreqn_i      (qreqn_se_aclk),
    .ctrl_qacceptn_o   (qacceptn_se_aclk),
    .ctrl_qdeny_o      (qdeny_se_aclk),
    .ctrl_qactive_o    (qactive_se_aclk),

    .dev_qreqn_o       (qreqn_lpdq_clk),
    .dev_qacceptn_i    (qacceptn_lpdq_clk),
    .dev_qdeny_i       (qdeny_lpdq_clk),
    .dev_qactive_i     (qactive_lpdq_clk),

    .clk_qactive_o     (),

    .dftcgen           (dftcgen)
    );

  assign qreqn_se_axi_aclk     = qreqn_lpdq_clk[0];
  assign qreqn_seh0_aclk       = qreqn_lpdq_clk[1];
  assign qreqn_hse0_aclk       = qreqn_lpdq_clk[2];
  assign qreqn_seh1_aclk       = qreqn_lpdq_clk[3];
  assign qreqn_hse1_aclk       = qreqn_lpdq_clk[4];

  assign qacceptn_lpdq_clk[0]  = qacceptn_se_axi_aclk;
  assign qacceptn_lpdq_clk[1]  = qacceptn_seh0_aclk;
  assign qacceptn_lpdq_clk[2]  = qacceptn_hse0_aclk;
  assign qacceptn_lpdq_clk[3]  = qacceptn_seh1_aclk;
  assign qacceptn_lpdq_clk[4]  = qacceptn_hse1_aclk;

  assign qdeny_lpdq_clk[0]     = qdeny_se_axi_aclk;
  assign qdeny_lpdq_clk[1]     = qdeny_seh0_aclk;
  assign qdeny_lpdq_clk[2]     = qdeny_hse0_aclk;
  assign qdeny_lpdq_clk[3]     = qdeny_seh1_aclk;
  assign qdeny_lpdq_clk[4]     = qdeny_hse1_aclk;

  assign qactive_lpdq_clk[0]   = qactive_se_axi_aclk;
  assign qactive_lpdq_clk[1]   = qactive_seh0_aclk;
  assign qactive_lpdq_clk[2]   = qactive_hse0_aclk;
  assign qactive_lpdq_clk[3]   = qactive_seh1_aclk;
  assign qactive_lpdq_clk[4]   = qactive_hse1_aclk;

  always @(posedge aclk or negedge systopwarmresetn)
  begin
    if(!systopwarmresetn)
    begin
      hse0_mhuint_r <= 1'b0;
      seh0_mhuint_r <= 1'b0;
      hse1_mhuint_r <= 1'b0;
      seh1_mhuint_r <= 1'b0;
    end
    else
    begin
      hse0_mhuint_r <= hse0_mhuint_int;
      seh0_mhuint_r <= seh0_mhuint_int;
      hse1_mhuint_r <= hse1_mhuint_int;
      seh1_mhuint_r <= seh1_mhuint_int;
    end
  end

  assign hse0_mhuint = hse0_mhuint_r;
  assign seh0_mhuint = seh0_mhuint_r;
  assign hse1_mhuint = hse1_mhuint_r;
  assign seh1_mhuint = seh1_mhuint_r;

  assign unused = |{pstrb_hse0_mhu_apb,
                    pprot_hse0_mhu_apb,
                    pstrb_seh0_mhu_apb,
                    pprot_seh0_mhu_apb,
                    pstrb_hse1_mhu_apb,
                    pprot_hse1_mhu_apb,
                    pstrb_seh1_mhu_apb,
                    pprot_seh1_mhu_apb};

endmodule