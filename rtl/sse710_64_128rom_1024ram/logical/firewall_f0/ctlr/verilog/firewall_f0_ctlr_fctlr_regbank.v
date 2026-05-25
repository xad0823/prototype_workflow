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

module firewall_f0_ctlr_fctlr_regbank #(
  parameter CFG_AGENT_MST_ID                              = 0,
  parameter FC_ID                                         = 0,
  parameter FC_PE_LVL                                     = 1,
  parameter PE_CTRL_WIDTH                                 = 7,
  parameter PE_ST_WIDTH                                   = 7,
  parameter RWE_CTRL_WIDTH                                = 8,
  parameter FC_NUM_RGN                                    = 4,
  parameter LOG2_FC_NUM_RGN                               = 2,
  parameter RGN_CTRL0_WIDTH                               = 1,
  parameter RGN_CTRL1_WIDTH                               = 4,
  parameter FC_NUM_MPE                                    = 4,
  parameter RGN_LCTRL_WIDTH                               = 1,
  parameter FW_LDE_LVL                                    = 0,
  parameter RGN_ST_WIDTH                                  = 5,
  parameter FC_MXRS                                       = 21,
  parameter FC_MNRS                                       = 7,
  parameter RGN_CFG0_WIDTH                                = 27,
  parameter PE_BPS_WIDTH                                  = 3,
  parameter FC_RGN_BASE_ADDR                              = {FC_NUM_RGN*FC_MXRS{1'b0}},
  parameter RGN_CFG1_WIDTH                                = 32,
  parameter FC_RGN_UPR_ADDR                               = {FC_NUM_RGN*FC_MXRS{1'b1}},
  parameter FC_RSE_LVL                                    = 1,
  parameter RGN_SIZE_WIDTH                                = 16,
  parameter FC_RGN_MULNPO2                                = {FC_NUM_RGN{1'b0}},
  parameter FC_RGN_SIZE                                   = {FC_NUM_RGN*8{1'b0}},
  parameter PROT_SIZE_WIDTH                               = 8,
  parameter RGN_TCFG0_WIDTH                               = 27,
  parameter FC_TE_LVL                                     = 0,
  parameter RGN_TCFG1_WIDTH                               = 32,
  parameter RGN_TCFG2_WIDTH                               = 18,
  parameter FC_MA_SPT                                     = 1,
  parameter FC_SH_SPT                                     = 0,
  parameter FC_INST_SPT                                   = 1,
  parameter FC_PRIV_SPT                                   = 1,
  parameter FC_SEC_SPT                                    = 1,
  parameter FC_SINGLE_MST                                 = 1,
  parameter FC_MST_ID_WIDTH                               = 8,
  parameter RGN_MPL0_WIDTH                                = 13,
  parameter RGN_MPL1_WIDTH                                = 13,
  parameter RGN_MPL2_WIDTH                                = 13,
  parameter RGN_MPL3_WIDTH                                = 13,
  parameter FE_TAL_WIDTH                                  = 32,
  parameter FE_TAU_WIDTH                                  = 32,
  parameter FE_TP_WIDTH                                   = 4,
  parameter FE_CTRL_WIDTH                                 = 6,
  parameter IRQ_TYPE_WIDTH                                = 5,
  parameter ME_CTRL_WIDTH                                 = 3,
  parameter ME_ST_WIDTH                                   = 3,
  parameter EDR_TAL_WIDTH                                 = 32,
  parameter EDR_TAU_WIDTH                                 = 32,
  parameter EDR_TP_WIDTH                                  = 4,
  parameter EDR_CTRL_WIDTH                                = 3,
  parameter FC_ME_LVL                                     = 0,
  parameter LD_CTRL_WIDTH                                 = 3,
  parameter FC_MST_ID_SINGLE_MST                          = 0,
  parameter FW_NUM_FC                                     = 13,
  parameter FW_CTRL_WIDTH                                 = 2,
  parameter FW_ST_WIDTH                                   = 2,
  parameter FW_SR_CTRL_WIDTH                              = 2,
  parameter FC_INT_ST_WIDTH                               = 5,
  parameter FC_INT_MSK_WIDTH                              = 5,
  parameter LOG2_FW_NUM_FC                                = 4,
  parameter PID0_WIDTH                                    = 8,
  parameter PID1_WIDTH                                    = 8,
  parameter PID2_WIDTH                                    = 8,
  parameter PID3_WIDTH                                    = 8,
  parameter PID4_WIDTH                                    = 8,
  parameter CID0_WIDTH                                    = 8,
  parameter CID1_WIDTH                                    = 8,
  parameter CID2_WIDTH                                    = 8,
  parameter CID3_WIDTH                                    = 8,
  parameter IIDR_WIDTH                                    = 32,
  parameter AIDR_WIDTH                                    = 8,
  parameter FW_SRE_LVL                                    = 1,
  parameter [(32*FW_NUM_FC)-1:0] FC_MST_ID_WIDTH_EXT      = {32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8, 32'd8}, 
  parameter [FW_NUM_FC*5-1:0] FC_ID_EXT                   = {5'hD, 5'hC, 5'hB, 5'hA, 5'h9, 5'h8, 5'h7, 5'h6, 5'h5, 5'h4, 5'h3, 5'h2, 5'h1}, 
  parameter [FW_NUM_FC-1:0] FC_SINGLE_MST_EXT             = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0}, 
  parameter [(2*FW_NUM_FC)-1:0] FC_PE_LVL_EXT             = {2'h2, 2'h1, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h2, 2'h2, 2'h1, 2'h1}, 
  parameter [(2*FW_NUM_FC)-1:0] FC_TE_LVL_EXT             = {2'h0, 2'h0, 2'h0, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0}, 
  parameter [FW_NUM_FC-1:0] FC_RSE_LVL_EXT                = {1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0}, 
  parameter [(2*FW_NUM_FC)-1:0] FC_ME_LVL_EXT             = {2'h0, 2'h0, 2'h0, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0}, 
  parameter [(7*FW_NUM_FC)-1:0] FC_NUM_RGN_EXT            = {7'h40, 7'h40, 7'h20, 7'h20, 7'h20, 7'h10, 7'h10, 7'h8, 7'h1, 7'h40, 7'h40, 7'h28, 7'h1E}, 
  parameter [(7*FW_NUM_FC)-1:0] FC_MNRS_EXT               = {7'h7, 7'h3, 7'h7, 7'h7, 7'h7, 7'h7, 7'h7, 7'h7, 7'h3, 7'h3, 7'h7, 7'h7, 7'h7}, 
  parameter [(7*FW_NUM_FC)-1:0] FC_MXRS_EXT               = {7'h1F, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h20, 7'h19, 7'h1C, 7'h17, 7'h1D}, 
  parameter [(3*FW_NUM_FC)-1:0] FC_NUM_MPE_EXT            = {3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h1, 3'h1, 3'h2, 3'h1, 3'h4, 3'h4, 3'h1, 3'h1}, 
  parameter [FW_NUM_FC-1:0] FC_SEC_SPT_EXT                = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1}, 
  parameter [FW_NUM_FC-1:0] FC_MA_SPT_EXT                 = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1}, 
  parameter [FW_NUM_FC-1:0] FC_SH_SPT_EXT                 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}, 
  parameter [FW_NUM_FC-1:0] FC_INST_SPT_EXT               = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1}, 
  parameter [FW_NUM_FC-1:0] FC_PRIV_SPT_EXT               = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1}, 
  parameter [(32*FW_NUM_FC)-1:0] FC_MST_ID_SINGLE_MST_EXT = {32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0},  
  parameter FW_SE_LVL                                     = 1,
  parameter FC_ADDR_WIDTH                                 = 21,
  parameter FW_TMP_TA_WIDTH                               = 19,
  parameter FW_TMP_TP_WIDTH                               = 3,
  parameter FW_TMP_CTRL_WIDTH                             = 3,
  parameter FW_TMP_TA_ADDR                                = 12'hE90,
  parameter FW_TMP_TP_ADDR                                = 12'hE98,
  parameter FW_TMP_MID_ADDR                               = 12'hE9C,
  parameter FW_TMP_CTRL_ADDR                              = 12'hEA0

) (
  input  wire                                        clk,
  input  wire                                        reset_n,

  input  wire                                        arvalid_i,
  input  wire                                        arready_i,
  input  wire                                        awvalid_i,
  input  wire                                        awready_i,
  input  wire                                        wvalid_i,
  input  wire                                        wready_i,
  input  wire                                        rvalid_i,
  input  wire                                        rready_i,
  input  wire                                        bvalid_i,
  input  wire                                        bready_i,

  input  wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_i,
  input  wire                                        pe_ctrl_en,
  output wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_o,

  output wire [PE_ST_WIDTH-1:0]                      pe_st_o,

  input  wire                                        pe_bps_i,
  output wire [PE_BPS_WIDTH-1:0]                     pe_bps_o,

  input  wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_i,
  input  wire                                        rwe_ctrl_en,
  output wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_o,

  input  wire [FC_NUM_RGN*RGN_CTRL0_WIDTH-1:0]       rgn_ctrl0_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_ctrl0_en,
  output wire [FC_NUM_RGN*RGN_CTRL0_WIDTH-1:0]       rgn_ctrl0_o,
  output wire [RGN_CTRL0_WIDTH-1:0]                  rgn_ctrl0_rgn_o,

  input  wire [FC_NUM_RGN*RGN_CTRL1_WIDTH-1:0]       rgn_ctrl1_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_ctrl1_en,
  output wire [FC_NUM_RGN*RGN_CTRL1_WIDTH-1:0]       rgn_ctrl1_o,
  output wire [RGN_CTRL1_WIDTH-1:0]                  rgn_ctrl1_rgn_o,

  input  wire [FC_NUM_RGN*RGN_LCTRL_WIDTH-1:0]       rgn_lctrl_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_lctrl_en,
  output wire [FC_NUM_RGN*RGN_LCTRL_WIDTH-1:0]       rgn_lctrl_o,
  output wire [RGN_LCTRL_WIDTH-1:0]                  rgn_lctrl_rgn_o,

  output wire [FC_NUM_RGN*RGN_ST_WIDTH-1:0]          rgn_st_o,
  output wire [RGN_ST_WIDTH-1:0]                     rgn_st_rgn_o,

  input  wire [FC_NUM_RGN*RGN_CFG0_WIDTH-1:0]        rgn_cfg0_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_cfg0_en,
  output wire [FC_NUM_RGN*RGN_CFG0_WIDTH-1:0]        rgn_cfg0_o,
  output wire [RGN_CFG0_WIDTH-1:0]                   rgn_cfg0_rgn_o,

  input  wire [FC_NUM_RGN*RGN_CFG1_WIDTH-1:0]        rgn_cfg1_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_cfg1_en,
  output wire [FC_NUM_RGN*RGN_CFG1_WIDTH-1:0]        rgn_cfg1_o,
  output wire [RGN_CFG1_WIDTH-1:0]                   rgn_cfg1_rgn_o,

  input  wire [FC_NUM_RGN*RGN_SIZE_WIDTH-1:0]        rgn_size_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_size_en,
  output wire [FC_NUM_RGN*RGN_SIZE_WIDTH-1:0]        rgn_size_o,
  output wire [RGN_SIZE_WIDTH-1:0]                   rgn_size_rgn_o,

  input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_tcfg0_en,
  output wire [RGN_TCFG0_WIDTH-1:0]                  rgn_tcfg0_rgn_o,
  output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_o,

  input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_tcfg1_en,
  output wire [RGN_TCFG1_WIDTH-1:0]                  rgn_tcfg1_rgn_o,
  output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_o,

  input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_tcfg2_en,
  output wire [RGN_TCFG2_WIDTH-1:0]                  rgn_tcfg2_rgn_o,
  output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_o,

  input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid0_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mid0_en,
  output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid0_o,
  output wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid0_rgn_o,

  input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]        rgn_mid1_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mid1_en,
  output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]        rgn_mid1_o,
  output wire [FC_MST_ID_WIDTH-1:0]                   rgn_mid1_rgn_o,

  input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid2_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mid2_en,
  output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid2_o,
  output wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid2_rgn_o,

  input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid3_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mid3_en,
  output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]       rgn_mid3_o,
  output wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid3_rgn_o,

  input  wire [FC_NUM_RGN*RGN_MPL0_WIDTH-1:0]        rgn_mpl0_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mpl0_en,
  output wire [FC_NUM_RGN*RGN_MPL0_WIDTH-1:0]        rgn_mpl0_o,
  output wire [RGN_MPL0_WIDTH-1:0]                   rgn_mpl0_rgn_o,

  input  wire [FC_NUM_RGN*RGN_MPL1_WIDTH-1:0]        rgn_mpl1_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mpl1_en,
  output wire [FC_NUM_RGN*RGN_MPL1_WIDTH-1:0]        rgn_mpl1_o,
  output wire [RGN_MPL1_WIDTH-1:0]                   rgn_mpl1_rgn_o,

  input  wire [FC_NUM_RGN*RGN_MPL2_WIDTH-1:0]        rgn_mpl2_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mpl2_en,
  output wire [FC_NUM_RGN*RGN_MPL2_WIDTH-1:0]        rgn_mpl2_o,
  output wire [RGN_MPL2_WIDTH-1:0]                   rgn_mpl2_rgn_o,

  input  wire [FC_NUM_RGN*RGN_MPL3_WIDTH-1:0]        rgn_mpl3_i,
  input  wire [FC_NUM_RGN-1:0]                       rgn_mpl3_en,
  output wire [FC_NUM_RGN*RGN_MPL3_WIDTH-1:0]        rgn_mpl3_o,
  output wire [RGN_MPL3_WIDTH-1:0]                   rgn_mpl3_rgn_o,

  input  wire [FW_NUM_FC-1:0]                        comp_pwr_st_i,
  input  wire [FW_NUM_FC-1:0]                        comp_pwr_st_en,
  output wire [FW_NUM_FC-1:0]                        comp_pwr_st_o,
  output wire [FW_NUM_FC-1:0]                        comp_pwr_st_ctrl_o,

  input  wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_i,
  input  wire                                        me_ctrl_en,
  output wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_o,

  output wire [ME_ST_WIDTH-1:0]                      me_st_o,

  input  wire [FE_TAL_WIDTH-1:0]                     fe_tal_rdch_i,
  input  wire [FE_TAU_WIDTH-1:0]                     fe_tau_rdch_i,
  input  wire [FE_TP_WIDTH-1:0]                      fe_tp_rdch_i,
  input  wire [FC_MST_ID_WIDTH-1:0]                  fe_mid_rdch_i,
  input  wire                                        fe_rdch_en,
  input  wire                                        fe_type_rdch_i,
  input  wire                                        rb_tmp_reg_err_rd_i,

  input  wire [FE_TAL_WIDTH-1:0]                     fe_tal_wrch_i,
  input  wire [FE_TAU_WIDTH-1:0]                     fe_tau_wrch_i,
  input  wire [FE_TP_WIDTH-1:0]                      fe_tp_wrch_i,
  input  wire [FC_MST_ID_WIDTH-1:0]                  fe_mid_wrch_i,
  input  wire                                        fe_wrch_en,
  input  wire                                        fe_type_wrch_i,
  input  wire                                        rb_tmp_reg_err_wr_i,

  output reg  [FE_TAL_WIDTH-1:0]                     fe_tal_o,
  output reg  [FE_TAU_WIDTH-1:0]                     fe_tau_o,
  output reg  [FE_TP_WIDTH-1:0]                      fe_tp_o,
  output reg  [FC_MST_ID_WIDTH-1:0]                  fe_mid_o,

  input  wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_i,
  input  wire                                        fe_ctrl_en,
  output wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_o,

  input  wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_i,
  input  wire                                        fw_ctrl_en,
  output wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_o,

  output wire [FW_ST_WIDTH-1:0]                      fw_st_o,

  input  wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_i,
  input  wire                                        fw_sr_ctrl_en,
  output wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_o,

  output wire [31:0]                                 fw_int_st_o,

  output reg                                         fw_global_int_st,

  input  wire                                        ldi_st_i,

  input  wire [32*FC_INT_ST_WIDTH-1:0]               fc_int_st_i,
  input  wire [31:0]                                 fc_int_st_en,
  output wire [32*FC_INT_ST_WIDTH-1:0]               fc_int_st_o,

  input  wire [32*FC_INT_MSK_WIDTH-1:0]              fc_int_msk_i,
  input  wire [31:0]                                 fc_int_msk_en,
  output wire [32*FC_INT_MSK_WIDTH-1:0]              fc_int_msk_o,

  input wire                                         restore_done,
  input wire                                         sram_init_done_i,

  input  wire [FW_NUM_FC*PROT_SIZE_WIDTH-1:0]        fw_prot_size_i,
  output wire [FW_NUM_FC*PROT_SIZE_WIDTH-1:0]        fw_prot_size_o,

  input  wire                                        cfg_irq_req_i,
  input  wire [IRQ_TYPE_WIDTH-1:0]                   cfg_irq_type_i,
  input  wire [LOG2_FW_NUM_FC-1:0]                   cfg_irq_fw_id_i,

  output wire                                        fctlr_rb_lpi_discon_deny_o,

  output wire [PID0_WIDTH-1:0]                       fw_pid0_o,
  output wire [PID1_WIDTH-1:0]                       fw_pid1_o,
  output wire [PID2_WIDTH-1:0]                       fw_pid2_o,
  output wire [PID3_WIDTH-1:0]                       fw_pid3_o,
  output wire [PID4_WIDTH-1:0]                       fw_pid4_o,

  output wire [CID0_WIDTH-1:0]                       fw_cid0_o,
  output wire [CID1_WIDTH-1:0]                       fw_cid1_o,
  output wire [CID2_WIDTH-1:0]                       fw_cid2_o,
  output wire [CID3_WIDTH-1:0]                       fw_cid3_o,

  input  wire                                        lpi_prot_size_sample_i,

  output wire [IIDR_WIDTH-1:0]                       iidr_o,
  output wire [AIDR_WIDTH-1:0]                       aidr_o,

  input  wire [((FW_NUM_FC+1)*LD_CTRL_WIDTH)-1:0]    ld_ctrl_i,
  input  wire [FW_NUM_FC:0]                          ld_ctrl_en,
  output wire [((FW_NUM_FC+1)*LD_CTRL_WIDTH)-1:0]    ld_ctrl_o ,

  output wire                                        fw_tamper_irq,

  input  wire [2:0]                                  arprot_i,
  input  wire [FC_MST_ID_WIDTH-1:0]                  armmusid_i,
  input  wire [FC_ADDR_WIDTH-1:0]                    araddr_i,
  input  wire [2:0]                                  awprot_i,
  input  wire [FC_MST_ID_WIDTH-1:0]                  awmmusid_i,
  input  wire [FC_ADDR_WIDTH-1:0]                    awaddr_i,
  input  wire                                        tamper_cfg,
  input  wire                                        tamper_cfg_w,

  output wire [FW_TMP_TA_WIDTH-1:0]                  fw_tmp_ta_o,

  output wire [FW_TMP_TP_WIDTH-1:0]                  fw_tmp_tp_o,

  output wire [FC_MST_ID_WIDTH-1:0]                  fw_tmp_mid_o,

  input  wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_i,
  input  wire                                        fw_tmp_ctrl_en,
  output wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_o ,

  output wire [FC_NUM_RGN*FC_MXRS-1:0]               fctlr_base_addr_o,
  output wire [FC_NUM_RGN*FC_MXRS-1:0]               fctlr_upr_addr_o,
  output wire                                        ctrl_st_xfer_req,
  input  wire                                        ctrl_st_xfer_ack,

  input  wire                                        default_state_i,

  input wire                                         dp_write_tamp_i,
  input wire                                         dp_read_tamp_i

);


`include "firewall_f0_reset_values.vh"


wire status_enable;
genvar i, j; 



generate
  if (FC_PE_LVL > 0) begin: PE_CTRL_PE_LVL_NOT_ZERO 
    reg [PE_CTRL_WIDTH-1:0] pe_ctrl_r;

    always @ (posedge clk or negedge reset_n) begin: PE_CTRL_REG
      if (!reset_n) begin
        pe_ctrl_r <= PE_CTRL_RST_VAL;
      end else begin
        if (default_state_i) begin
          pe_ctrl_r <= PE_CTRL_RST_VAL;
        end
        else if (pe_ctrl_en) begin
          pe_ctrl_r <= pe_ctrl_i;
        end
      end
    end

    assign pe_ctrl_o = pe_ctrl_r;

  end else begin: PE_CTRL_PE_LVL_ZERO 
    assign pe_ctrl_o = {PE_CTRL_WIDTH{1'b0}};
  end
endgenerate



generate
  if (FC_PE_LVL > 0) begin: PE_BPS_PE_LVL_NOT_ZERO
    wire pe_bps_bypass_if_st; 
    wire pe_bps_bypass_st;    
    wire pe_bps_bypass_vld;   
    reg  pe_bps_bypass_st_reg;

    wire pe_st_bypass_msk;   

    assign pe_st_bypass_msk = pe_st_o[5];

    assign pe_bps_bypass_if_st = pe_bps_i;

    assign pe_bps_bypass_st =
      (pe_bps_i) ? (pe_bps_i & (~pe_st_bypass_msk)) : 1'b0;

    assign pe_bps_bypass_vld = 1'b1;

    assign pe_bps_o = {pe_bps_bypass_vld,
                       pe_bps_bypass_st_reg,  
                       pe_bps_bypass_if_st};


    always @(posedge clk or negedge reset_n) begin: UPDATE_STATUS_REGS
      if (!reset_n) begin
        pe_bps_bypass_st_reg <= 1'b0;
      end else begin
        if (default_state_i) begin
          pe_bps_bypass_st_reg <= 1'b0;
        end
        else if (!status_enable) begin
          pe_bps_bypass_st_reg <= pe_bps_bypass_st;
        end
      end
    end


  end else begin:PE_BPS_PE_LVL_ZERO

    assign pe_bps_o = {PE_BPS_WIDTH{1'b0}};

  end
endgenerate


localparam ACT_RWE_CTRL_WIDTH = LOG2_FC_NUM_RGN;

generate
  if (FC_PE_LVL > 0) begin: RWE_CTRL_PE_LVL_NOT_ZERO 
    reg [ACT_RWE_CTRL_WIDTH-1:0] rwe_ctrl_r;

    always @(posedge clk or negedge reset_n) begin: RWE_CTRL_REG
      if (!reset_n) begin
        rwe_ctrl_r <= {ACT_RWE_CTRL_WIDTH{1'b0}};
      end else begin
        if (default_state_i) begin
          rwe_ctrl_r <= {ACT_RWE_CTRL_WIDTH{1'b0}};
        end
        else if (rwe_ctrl_en) begin
          rwe_ctrl_r <= rwe_ctrl_i[ACT_RWE_CTRL_WIDTH-1:0];
        end
      end
    end

    if (RWE_CTRL_WIDTH > ACT_RWE_CTRL_WIDTH) begin: RWE_CTRL_APPEND_ZEROS
      assign rwe_ctrl_o =
        {{(RWE_CTRL_WIDTH-ACT_RWE_CTRL_WIDTH){1'b0}}, rwe_ctrl_r};
    end else begin: NOT_APPEND_ZEROS
      assign rwe_ctrl_o = rwe_ctrl_r;
    end

  end else begin: RWE_CTRL_PE_LVL_ZERO
    assign rwe_ctrl_o = {RWE_CTRL_WIDTH{1'b0}};
  end
endgenerate


generate
  if (FC_PE_LVL > 0) begin: RGN_CTRL0_PE_LVL_NOT_ZERO 

    assign rgn_ctrl0_o[0] = 1'b1; 

    if (FC_NUM_RGN > 1) begin: RGN_CTRL0_PE_LVL_NOT_0_NUM_RGN_NOT_1 

      reg [(FC_NUM_RGN-1)*RGN_CTRL0_WIDTH-1:0] rgn_ctrl0_r;

      always @(posedge clk or negedge reset_n) begin: RGN_CTRL0_REG
        integer i; 
        if (!reset_n) begin
          rgn_ctrl0_r <= {(FC_NUM_RGN-1)*RGN_CTRL0_WIDTH{1'b0}};
        end else begin
          for (i=1; i<FC_NUM_RGN; i=i+1) begin 
            if (default_state_i) begin
              rgn_ctrl0_r[(i)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH] <= {RGN_CTRL0_WIDTH{1'b0}};
            end
            else if (rgn_ctrl0_en[i]) begin
              rgn_ctrl0_r[(i)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH] <=
                rgn_ctrl0_i[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH];
            end
          end
        end
      end

      assign rgn_ctrl0_o[FC_NUM_RGN*RGN_CTRL0_WIDTH-1:1] = rgn_ctrl0_r;

    end

    reg [RGN_CTRL0_WIDTH-1:0] rgn_ctrl0_curr_rgn;

    always @(*) begin: RGN_CTRL0_CURRENT_RGN
      integer i;
      rgn_ctrl0_curr_rgn = {RGN_CTRL0_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_ctrl0_curr_rgn =
            rgn_ctrl0_o[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH];
        end
      end
    end

    assign rgn_ctrl0_rgn_o = rgn_ctrl0_curr_rgn;

  end else begin: RGN_CTRL0_PE_LVL_ZERO 
    assign rgn_ctrl0_o     = {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};
    assign rgn_ctrl0_rgn_o = {RGN_CTRL0_WIDTH{1'b0}}           ;
  end
endgenerate


localparam ACT_RGN_CTRL1_WIDTH = FC_NUM_MPE;
localparam RGN_CTRL1_DIFF      = RGN_CTRL1_WIDTH - ACT_RGN_CTRL1_WIDTH;

generate
  if (FC_PE_LVL > 0) begin: RGN_CTRL1_PE_LVL_NOT_ZERO 

    reg [RGN_CTRL1_WIDTH-1:0]                rgn_ctrl1_curr_rgn;

    assign rgn_ctrl1_o[RGN_CTRL1_WIDTH-1:1] = {(RGN_CTRL1_WIDTH-1){1'b0}};
    assign rgn_ctrl1_o[0] = 1'b1;

    if (FC_NUM_RGN > 1) begin: RGB_CTRL1_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1
      reg [(FC_NUM_RGN-1)*ACT_RGN_CTRL1_WIDTH-1:0] rgn_ctrl1_r;

      always @(posedge clk or negedge reset_n) begin: RGN_CTRL1_REG
        integer i;
        if (!reset_n) begin
          rgn_ctrl1_r <= {(FC_NUM_RGN-1)*ACT_RGN_CTRL1_WIDTH{1'b0}};
        end else begin
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_ctrl1_r[((i)*ACT_RGN_CTRL1_WIDTH)-1-:ACT_RGN_CTRL1_WIDTH] <= {ACT_RGN_CTRL1_WIDTH{1'b0}};
            end
            else if (rgn_ctrl1_en[i]) begin
              rgn_ctrl1_r[((i)*ACT_RGN_CTRL1_WIDTH)-1-:ACT_RGN_CTRL1_WIDTH] <=
                rgn_ctrl1_i[((i+1)*RGN_CTRL1_WIDTH)-RGN_CTRL1_DIFF-1-:ACT_RGN_CTRL1_WIDTH];
            end
          end
        end
      end

      if (RGN_CTRL1_DIFF==0) begin: RGN_CTRL1_ZERO_PAD_NO_NEED

        assign rgn_ctrl1_o[FC_NUM_RGN*RGN_CTRL1_WIDTH-1:RGN_CTRL1_WIDTH] =
          rgn_ctrl1_r;

      end else begin: RGN_CTRL1_ZERO_PAD_NEED
        reg [(FC_NUM_RGN-1)*RGN_CTRL1_WIDTH-1:0] rgn_ctrl1_int;
        always @(*) begin: RGN_CTRL1_ZERO_PADDING
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            rgn_ctrl1_int[i*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH] =
              {{RGN_CTRL1_DIFF{1'b0}},
               rgn_ctrl1_r[i*ACT_RGN_CTRL1_WIDTH-1-:ACT_RGN_CTRL1_WIDTH]};
          end
        end
        assign rgn_ctrl1_o[FC_NUM_RGN*RGN_CTRL1_WIDTH-1:RGN_CTRL1_WIDTH] =
          rgn_ctrl1_int;
      end

    end

    always @(*) begin: RGN_CTRL1_CURRENT_RGN
      integer i; 
      rgn_ctrl1_curr_rgn = {RGN_CTRL1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_ctrl1_curr_rgn =
            rgn_ctrl1_o[(i+1)*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH];
        end
      end
    end

    assign rgn_ctrl1_rgn_o = rgn_ctrl1_curr_rgn;

  end else begin: RGN_CTRL1_PE_LVL_ZERO 
    assign rgn_ctrl1_o     = {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};
    assign rgn_ctrl1_rgn_o = {RGN_CTRL1_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if (FC_PE_LVL > 0 && FW_LDE_LVL == 2) begin: RGN_LCTRL_PE_LVL_NOT_ZERO_LDE_LVL_TWO 
    reg [RGN_LCTRL_WIDTH-1:0]            rgn_lctrl_curr_rgn;

    assign rgn_lctrl_o[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_LCTRL_PE_LVL_NOT_ZERO_LDE_LVL_TWO_NUM_RGN_NOT_1
      reg [(FC_NUM_RGN-1)*RGN_LCTRL_WIDTH-1:0] rgn_lctrl_r   ;

      always @(posedge clk or negedge reset_n) begin:RGN_LCTRL_REG
        integer i; 
        if (!reset_n) begin
          rgn_lctrl_r <= {(FC_NUM_RGN-1)*RGN_LCTRL_WIDTH{1'b0}};
        end else begin
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_lctrl_r[i*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH] <= {RGN_LCTRL_WIDTH{1'b0}};
            end
            else if (rgn_lctrl_en[i]) begin
              rgn_lctrl_r[i*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH] <=
                rgn_lctrl_i[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH];
            end
          end
        end
      end

      assign rgn_lctrl_o[FC_NUM_RGN*RGN_LCTRL_WIDTH-1:RGN_LCTRL_WIDTH] =
        rgn_lctrl_r;

    end

    always @(*) begin: RGN_LCTRL_CURRENT_RGN
      integer i; 
      rgn_lctrl_curr_rgn = {RGN_LCTRL_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_LCTRL_CURR_RGN
        if (i==rwe_ctrl_o) begin
          rgn_lctrl_curr_rgn =
            rgn_lctrl_o[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH];
        end
      end
    end

    assign rgn_lctrl_rgn_o = rgn_lctrl_curr_rgn;

  end else begin: RGN_LCTRL_PE_LVL_ZERO_LDE_LVL_NOT_TWO 
    assign rgn_lctrl_o     = {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};
    assign rgn_lctrl_rgn_o = {RGN_LCTRL_WIDTH{1'b0}};
  end
endgenerate


wire [FC_NUM_RGN*RGN_ST_WIDTH-1:0] rgn_st_int;

generate
  for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_ST_ASSEMBLE
    assign rgn_st_int [(i+1)*RGN_ST_WIDTH-1-:RGN_ST_WIDTH] =
      {rgn_ctrl1_o[(i+1)*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH],
       rgn_ctrl0_o[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH]};
  end
endgenerate


reg [RGN_ST_WIDTH-1:0]            rgn_st_curr_rgn;
reg [FC_NUM_RGN*RGN_ST_WIDTH-1:0] rgn_st_reg;

always @(*) begin: RGN_ST_CURRENT_REGION
  integer i;
  rgn_st_curr_rgn = {RGN_ST_WIDTH{1'b0}};
  for (i=0; i<FC_NUM_RGN; i=i+1) begin
    if (i == rwe_ctrl_o) begin
      rgn_st_curr_rgn = rgn_st_reg[(i+1)*RGN_ST_WIDTH-1-:RGN_ST_WIDTH];
    end
  end
end


localparam ACT_RGN_CFG0_WIDTH = (FC_MXRS <= 32) ?
  (FC_MXRS - (FC_MNRS+5)) :
  (32 - (FC_MNRS+5));

localparam RGN_CFG0_DIFF = RGN_CFG0_WIDTH - ACT_RGN_CFG0_WIDTH;

reg [RGN_CFG0_WIDTH-1:0] rgn_cfg0_curr_rgn;


localparam RGN_CFG0_DIFF_FLAG = (FC_MXRS<=32) ? 0 : 1;

localparam RGN01_LWR_ADDR = 0;
localparam RGN23_LWR_ADDR = 65536;
localparam [(4*32)-1:0] FIXED_LWR_ADDR = {RGN23_LWR_ADDR[31:0],
  RGN23_LWR_ADDR[31:0], RGN01_LWR_ADDR[31:0], RGN01_LWR_ADDR[31:0]};

generate if (FC_NUM_RGN < 4) begin: FC_NUM_RGN_LWR_ADDR_LESS_THAN_4_CFG0
  for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_FIXED_LESS_THAN_4
    assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
      FIXED_LWR_ADDR[((i+1)*32)-1-:RGN_CFG0_WIDTH];
  end
end else begin: FC_NUM_RGN_LWR_ADDR_MORE_THAN_4_CFG0
  for (i=0; i<4; i=i+1) begin: RGN_CFG0_FIXED_MORE_THAN_4
    assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
      FIXED_LWR_ADDR[((i+1)*32)-1-:RGN_CFG0_WIDTH];
  end
end
endgenerate

generate if (RGN_CFG0_DIFF_FLAG == 0) begin: RGN_CFG0_MXRS_LESS_THAN_32

  if (RGN_CFG0_DIFF == 0) begin: RGN_CFG0_DO_NOT_ZERO_PAD
    for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
      assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
        FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH];
    end
  end else begin: RGN_CFG0_DO_ZERO_PAD
    if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {{RGN_CFG0_DIFF{1'b0}},
           FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH]};
      end
    end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH],
          {RGN_CFG0_DIFF{1'b0}}
          };
      end
    end else begin: RGN_CFG0_ZERO_PAD_BOTH
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
           FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH],
           {FC_MNRS{1'b0}}};
      end
    end
  end
end else begin: RGN_CFG0_MXRS_GREATER_THAN_32

  if (RGN_CFG0_DIFF == 0) begin: RGN_CFG0_DO_NOT_ZERO_PAD
    for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
      assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
        FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH];
    end
  end else begin: RGN_CFG0_DO_ZERO_PAD

    if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {{RGN_CFG0_DIFF{1'b0}},
           FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH]};
      end
    end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH],
          {RGN_CFG0_DIFF{1'b0}}
          };
      end
    end else begin: RGN_CFG0_ZERO_PAD_BOTH
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
        assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
          {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
           FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH],
           {FC_MNRS{1'b0}}};
      end
    end
  end
end
endgenerate

always @(*) begin: RGN_CFG0_CURRENT_RGN
  integer i; 
  rgn_cfg0_curr_rgn = {RGN_CFG0_WIDTH{1'b0}};
  for (i=0; i<FC_NUM_RGN; i=i+1) begin
    if (i==rwe_ctrl_o) begin
      rgn_cfg0_curr_rgn =
        rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH];
    end
  end
end

assign rgn_cfg0_rgn_o = rgn_cfg0_curr_rgn;


localparam ACT_RGN_CFG1_WIDTH = (FC_MXRS > 32) ? (FC_MXRS - 32) : 0;

localparam RGN_CFG1_DIFF = RGN_CFG1_WIDTH - ACT_RGN_CFG1_WIDTH;

generate

  if (ACT_RGN_CFG1_WIDTH > 0) begin: RGN_CFG1_EXISTS
    reg [RGN_CFG1_WIDTH-1:0] rgn_cfg1_curr_rgn;

    if (FC_NUM_RGN < 4) begin: FC_NUM_RGN_LWR_ADDR_LESS_THAN_4_CFG1
      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG1_FIXED_LESS_THAN_4
        assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
          {RGN_CFG1_WIDTH{1'b0}};
      end
    end else begin: FC_NUM_RGN_LWR_ADDR_MORE_THAN_4_CFG1
      for (i=0; i<4; i=i+1) begin: RGN_CFG1_FIXED_MORE_THAN_4
        assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
          {RGN_CFG1_WIDTH{1'b0}};
      end
    end

    if (RGN_CFG1_DIFF == 0) begin: RGN_CFG1_ZERO_PAD_NOT_NEEDED
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG1_OUTPUT_PARAM_NO_ZERO_PAD
        assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
          FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG1_WIDTH];
      end
    end else begin: RGN_CFG1_ZERO_PAD_NEEDED
      for (i=4; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG1_OUTPUT_PARAM_ZERO_PAD
        assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
          {{RGN_CFG1_DIFF{1'b0}},
           FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG1_WIDTH]};
      end
    end

    always @(*) begin: RGN_CFG1_CURRENT_RGN
      integer i; 
      rgn_cfg1_curr_rgn = {RGN_CFG1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_cfg1_curr_rgn =
            rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH];
        end
      end
    end

    assign rgn_cfg1_rgn_o = rgn_cfg1_curr_rgn;

  end else begin: RGN_CFG1_DOES_NOT_EXIST

    assign rgn_cfg1_o     = {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};
    assign rgn_cfg1_rgn_o = {RGN_CFG1_WIDTH{1'b0}}           ;

  end
endgenerate


localparam ACT_RGN_SIZE_WIDTH = 9;

localparam RGN_SIZE_DIFF = RGN_SIZE_WIDTH - ACT_RGN_SIZE_WIDTH;

localparam RGN_SIZE_SIZE_WIDTH = 8;

generate
  if (FC_PE_LVL > 0) begin: RGN_SIZE_PE_LVL_NOT_ZERO 


    wire [FC_NUM_RGN-1:0] rgn_size_mulnpo2_int;

    if (FC_RSE_LVL == 0) begin: RGN_SIZE_MULNPO2_PE_LVL_NOT_ZERO_RSE_LVL_ZERO

      assign rgn_size_mulnpo2_int = {FC_NUM_RGN{1'b0}};

    end else begin: RGN_SIZE_MULNPO2_PE_LVL_NOT_ZERO_RSE_LVL_NOT_ZERO

      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_MULNPO2_OUTPUT_PARAM_VAL

        if (i < 4) begin : RGN_SIZE_MULNPO2_OUTPUT_FIXED_VAL
          assign rgn_size_mulnpo2_int[i] = 1'b1;
        end else begin : RGN_SIZE_MULNPO2_OUTPUT_NON_FIXED_VAL
          assign rgn_size_mulnpo2_int[i] = FC_RGN_MULNPO2[i];
        end

      end
    end


    wire [FC_NUM_RGN*RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_size_int;

    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_SIZE_OUTPUT_PARAM_VAL
      assign rgn_size_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH] =
        FC_RGN_SIZE[(i+1)*8-1-:8];
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_ASSEMBLE_OUTPUT
      assign rgn_size_o[(i+1)*RGN_SIZE_WIDTH-1-:RGN_SIZE_WIDTH] =
        {{RGN_SIZE_DIFF{1'b0}},
         rgn_size_mulnpo2_int[i],
         rgn_size_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH]};
    end


    reg [RGN_SIZE_WIDTH-1:0] rgn_size_curr_rgn;

    always @(*) begin: RGN_SIZE_CURRENT_RGN
      integer i;
      rgn_size_curr_rgn = {RGN_SIZE_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_size_curr_rgn =
            rgn_size_o[(i+1)*RGN_SIZE_WIDTH-1-:RGN_SIZE_WIDTH];
        end
      end
    end

    assign rgn_size_rgn_o = rgn_size_curr_rgn;

  end else begin: RGN_SIZE_PE_LVL_ZERO 
    assign rgn_size_o     = {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};
    assign rgn_size_rgn_o = {RGN_SIZE_WIDTH{1'b0}}           ;
  end
endgenerate


localparam ACT_RGN_TCFG0_WIDTH = (FC_MXRS <= 32) ?
  (FC_MXRS - (FC_MNRS+5)) :
  (32 - (FC_MNRS+5));

localparam RGN_TCFG0_DIFF = RGN_TCFG0_WIDTH - ACT_RGN_TCFG0_WIDTH;

localparam RGN_TCFG0_TOP = (FC_MXRS <= 32) ?
  32 - FC_MXRS :
  0;

localparam RGN01_UPR_ADDR = 65536 - (1<<(FC_MNRS+5));
localparam RGN23_UPR_ADDR = 65536 + ((65536*FW_NUM_FC) - (1<<(FC_MNRS+5)));
localparam [(4*32)-1:0] FIXED_UPR_ADDR = {RGN23_UPR_ADDR[31:0],
  RGN23_UPR_ADDR[31:0], RGN01_UPR_ADDR[31:0], RGN01_UPR_ADDR[31:0]};

localparam RGN_TCFG0_PE1_RW_REG_EXISTS =
  (FC_TE_LVL == 2) && (|(~FC_RGN_MULNPO2));

generate
  if (FC_PE_LVL > 0) begin: RGN_TCFG0_PE_LVL_NOT_ZERO

    reg [RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_curr_rgn;

    wire [FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_int;

    if (RGN_TCFG0_PE1_RW_REG_EXISTS == 1) begin: RGN_TCFG0_BUILD_REG
      reg [FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_r;
      always @(posedge clk) begin: RGN_TCFG0_REG
        integer i;
        for (i=4; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_tcfg0_en[i] && !FC_RGN_MULNPO2[i]) begin
            rgn_tcfg0_r[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH] <=
              rgn_tcfg0_i[(i+1)*RGN_TCFG0_WIDTH-RGN_TCFG0_TOP-1-:ACT_RGN_TCFG0_WIDTH];
          end else if (rgn_tcfg0_en[i] && FC_RGN_MULNPO2[i]) begin
            rgn_tcfg0_r[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH] <=
              {ACT_RGN_TCFG0_WIDTH{1'b0}};
          end
        end
      end
      assign rgn_tcfg0_int = rgn_tcfg0_r;
    end else begin: RGN_TCFG0_DO_NOT_BUILD_REG
      assign rgn_tcfg0_int = {FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH{1'b0}};
    end


    assign rgn_tcfg0_o[RGN_TCFG0_WIDTH-1:0] = FIXED_UPR_ADDR[31:5];

    for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG0_ASSEMBLE_OUTPUT

      if (i < 4) begin: RGN_TCFG0_FIXED_RGNS

        assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
          FIXED_UPR_ADDR[((i+1)*32)-1-:RGN_TCFG0_WIDTH];

      end else if (FC_RGN_MULNPO2[i]) begin: RGN_TCFG0_PE_1_MULNPO2_1

        if (RGN_TCFG0_DIFF == 0) begin: RGN_TCFG0_DO_NOT_ZERO_PAD

          assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
            FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH];

        end else begin:RGN_TCFG0_DO_ZERO_PAD

          if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              {{RGN_TCFG0_DIFF{1'b0}},
               FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH]};

          end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              {FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH],
              {RGN_TCFG0_DIFF{1'b0}}};

          end else begin: RGN_CFG0_ZERO_PAD_BOTH
            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              {{(RGN_TCFG0_DIFF-FC_MNRS){1'b0}},
               FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH],
               {FC_MNRS{1'b0}}};
          end
        end

      end else begin: RGN_TCFG0_PE_1_MULNPO2_0

        if (FC_TE_LVL < 2) begin: RGN_TCFG0_OUTPUTS_ZEROS

          assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
            {RGN_TCFG0_WIDTH{1'b0}};

        end else begin:RGN_TCFG0_OUTPUTS_FLOP_CONTENT


          if (RGN_TCFG0_DIFF == 0) begin: RGN_TCFG0_DO_NOT_ZERO_PAD

            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH];

          end else begin:RGN_TCFG0_DO_ZERO_PAD

            if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {{RGN_TCFG0_DIFF{1'b0}},
                 rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH]};

            end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                {RGN_TCFG0_DIFF{1'b0}}};

            end else begin: RGN_CFG0_ZERO_PAD_BOTH
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {{(RGN_TCFG0_DIFF-FC_MNRS){1'b0}},
                 rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                 {FC_MNRS{1'b0}}};
            end
          end
        end
      end
    end

    always @(*) begin: RGN_TCFG0_CURRENT_RGN
      integer i;
      rgn_tcfg0_curr_rgn = {RGN_TCFG0_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_tcfg0_curr_rgn =
            rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH];
        end
      end
    end

    assign rgn_tcfg0_rgn_o = rgn_tcfg0_curr_rgn;

  end else begin: RGN_TCFG0_PE_LVL_ZERO
    assign rgn_tcfg0_o     = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};
    assign rgn_tcfg0_rgn_o = {RGN_TCFG0_WIDTH{1'b0}};
  end
endgenerate


localparam ACT_RGN_TCFG1_WIDTH = FC_MXRS - 32;

localparam RGN_TCFG1_DIFF = RGN_TCFG1_WIDTH - ACT_RGN_TCFG1_WIDTH;

localparam RGN_TCFG1_TOP = 64 - FC_MXRS;

localparam RGN_TCFG1_PE1_RW_REG_EXISTS =
  (FC_TE_LVL == 2) && (|(~FC_RGN_MULNPO2));

generate
  if ((FC_PE_LVL > 0) && (FC_MXRS > 32)) begin: RGN_TCFG1_PE_LVL_NOT_ZERO

    reg [RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_curr_rgn;

    wire [FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_int;

    if (RGN_TCFG1_PE1_RW_REG_EXISTS == 1) begin: RGN_TCFG1_BUILD_REG
      reg [FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_r;
      always @(posedge clk) begin: RGN_TCFG1_REG
        integer i;
        for (i=4; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_tcfg1_en[i] && !FC_RGN_MULNPO2[i]) begin
            rgn_tcfg1_r[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH] <=
              rgn_tcfg1_i[(i+1)*RGN_TCFG1_WIDTH-RGN_TCFG1_TOP-1-:ACT_RGN_TCFG1_WIDTH];
          end else if (rgn_tcfg1_en[i] && FC_RGN_MULNPO2[i]) begin
            rgn_tcfg1_r[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH] <=
              {ACT_RGN_TCFG1_WIDTH{1'b0}};
          end
        end
      end
      assign rgn_tcfg1_int = rgn_tcfg1_r;
    end else begin: RGN_TCFG1_DO_NOT_BUILD_REG
      assign rgn_tcfg1_int = {FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH{1'b0}};
    end


    assign rgn_tcfg1_o[RGN_TCFG1_WIDTH-1:0] = {RGN_TCFG1_WIDTH{1'b0}};

    for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG1_ASSEMBLE_OUTPUT

      if (i < 4) begin: RGN_TCFG1_FIXED_RGNS

        assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
          {RGN_TCFG1_WIDTH{1'b0}};

      end else if (FC_RGN_MULNPO2[i]) begin: RGN_TCFG1_PE_1_MULNPO2_1

        if (RGN_TCFG1_DIFF == 0) begin: RGN_TCFG1_DO_NOT_ZERO_PAD

          assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
            FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG1_WIDTH];

        end else begin:RGN_TCFG1_DO_ZERO_PAD

          assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
            {{RGN_TCFG1_DIFF{1'b0}},
             FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG1_WIDTH]};

        end

      end else begin: RGN_TCFG1_PE_1_MULNPO2_0

        if (FC_TE_LVL < 2) begin: RGN_TCFG1_OUTPUTS_ZEROS

          assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
            {RGN_TCFG1_WIDTH{1'b0}};

        end else begin:RGN_TCFG1_OUTPUTS_FLOP_CONTENT

          if (RGN_TCFG1_DIFF == 0) begin: RGN_TCFG1_DO_NOT_ZERO_PAD

            assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
              rgn_tcfg1_int[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH];

          end else begin:RGN_TCFG1_DO_ZERO_PAD

            assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
              {{RGN_TCFG1_DIFF{1'b0}},
               rgn_tcfg1_int[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH]};

          end
        end
      end
    end

    always @(*) begin: RGN_TCFG1_CURRENT_RGN
      integer i;
      rgn_tcfg1_curr_rgn = {RGN_TCFG1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_tcfg1_curr_rgn =
            rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH];
        end
      end
    end

    assign rgn_tcfg1_rgn_o = rgn_tcfg1_curr_rgn;

  end else begin: RGN_TCFG1_PE_LVL_ZERO
    assign rgn_tcfg1_o     = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};
    assign rgn_tcfg1_rgn_o = {RGN_TCFG1_WIDTH{1'b0}};
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_TE_LVL > 0)) begin: RGN_TCFG2_PE_LVL_NOT_0_TE_LVL_NOT_0
    wire [FC_NUM_RGN-1:0] rgn_tcfg2_addr_trans_en_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_RGN_LESS_THAN_4
      assign rgn_tcfg2_addr_trans_en_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_TCFG2_RGN_MORE_THAN_4
      assign rgn_tcfg2_addr_trans_en_int[3:0] = {4{1'b0}};
    end


    if (FC_TE_LVL == 2) begin: RGN_TCFG2_ADDR_TRANS_EN_PE_LVL_NOT_0_TE_LVL_NOT_2_PE_LVL_2


      if (FC_NUM_RGN > 4) begin: RGN_TCFG2_ADDR_TRANS_EN_FC_NUM_RGN_NOT_1

        reg [(FC_NUM_RGN-4)-1:0] rgn_tcfg2_addr_trans_en_non_def_r;
        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_ADDR_TRANS_EN_NON_DEF_RGN_REG
          integer i; 
          if (!reset_n) begin
            rgn_tcfg2_addr_trans_en_non_def_r <= {(FC_NUM_RGN-4){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin 
              if (default_state_i) begin
                rgn_tcfg2_addr_trans_en_non_def_r[i-4] <= 1'b0;
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_addr_trans_en_non_def_r[i-4] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-1];
              end
            end
          end
        end

      assign rgn_tcfg2_addr_trans_en_int[FC_NUM_RGN-1:3] =
        rgn_tcfg2_addr_trans_en_non_def_r;

      end 

    end else begin: RGN_TCFG2_ADDR_TRANS_EN_PE_LVL_NOT_0_TE_LVL_NOT_2
      assign rgn_tcfg2_addr_trans_en_int = {FC_NUM_RGN{1'b0}};
    end


    wire [FC_NUM_RGN-1:0] rgn_tcfg2_ma_trans_en_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_MA_TRANS_EN_RGN_LESS_THAN_4
      assign rgn_tcfg2_ma_trans_en_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MA_TRANS_EN_TCFG2_RGN_MORE_THAN_4
      assign rgn_tcfg2_ma_trans_en_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_MA_TRANS_SPT_FC_NUM_RGN_NOT_4

      if (FC_MA_SPT == 0) begin: RGN_TCFG2_MA_TRANS_SPT_FC_MA_EN_0

        assign rgn_tcfg2_ma_trans_en_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_TCFG2_MA_TRANS_EN_FC_MA_SPT_1

        reg [FC_NUM_RGN-5:0] rgn_tcfg2_ma_trans_en_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_MA_TRANS_EN_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_ma_trans_en_r <= {(FC_NUM_RGN-4){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_ma_trans_en_r[i-4] <= 1'b0;
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_ma_trans_en_r[i-4] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-1];
              end
            end
          end
        end

        assign rgn_tcfg2_ma_trans_en_int[FC_NUM_RGN-1:4] =
          rgn_tcfg2_ma_trans_en_r;

      end

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_inst_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_INST_RGN_LESS_THAN_4
      assign rgn_tcfg2_inst_int[2*FC_NUM_RGN-1:0] = {2*FC_NUM_RGN{1'b0}};
    end else begin : RGN_TCFG2_INST_RGN_MORE_THAN_4
      assign rgn_tcfg2_inst_int[7:0] = {8{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_INST_FC_NUM_RGN_NOT_4

      if (FC_INST_SPT == 0) begin: RGN_TCFG2_INST_FC_INST_SPT_0

        assign rgn_tcfg2_inst_int = {(FC_NUM_RGN-4)*2{1'b0}};

      end else begin: RGN_TCFG2_INST_FC_INST_SPT_1
        reg [(FC_NUM_RGN-4)*2-1:0] rgn_tcfg2_inst_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_INST_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_inst_r <= {((FC_NUM_RGN-4)*2){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_inst_r[i*2-7-:2] <= {2{1'b0}};
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_inst_r[i*2-7-:2] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-3-:2];
              end
            end
          end
        end

        assign rgn_tcfg2_inst_int[FC_NUM_RGN*2-1:8] = rgn_tcfg2_inst_r;

      end

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_priv_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_PRIV_RGN_LESS_THAN_4
      assign rgn_tcfg2_priv_int[2*FC_NUM_RGN-1:0] = {2*FC_NUM_RGN{1'b0}};
    end else begin : RGN_TCFG2_PRIV_RGN_MORE_THAN_4
      assign rgn_tcfg2_priv_int[7:0] = {8{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_PRIV_FC_NUM_RGN_NOT_4

      if (FC_PRIV_SPT == 0) begin: RGN_TCFG2_PRIV_FC_PRIV_SPT_0

        assign rgn_tcfg2_priv_int = {(FC_NUM_RGN-4)*2{1'b0}};

      end else begin: RGN_TCFG2_PRIV_FC_PRIV_SPT_1
        reg [(FC_NUM_RGN-4)*2-1:0] rgn_tcfg2_priv_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_PRIV_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_priv_r <= {((FC_NUM_RGN-4)*2){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_priv_r[i*2-7-:2] <= {2{1'b0}};
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_priv_r[i*2-7-:2] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-5-:2];
              end
            end
          end
        end

        assign rgn_tcfg2_priv_int[FC_NUM_RGN*2-1:8] = rgn_tcfg2_priv_r;

      end
    end


    wire [FC_NUM_RGN*8-1:0] rgn_tcfg2_ma_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_MA_RGN_LESS_THAN_4
      assign rgn_tcfg2_ma_int[8*FC_NUM_RGN-1:0] = {8*FC_NUM_RGN{1'b0}};
    end else begin : RGN_TCFG2_MA_RGN_MORE_THAN_4
      assign rgn_tcfg2_ma_int[31:0] = {32{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_MA_FC_NUM_RGN_NOT_4

      if (FC_MA_SPT == 0) begin: RGN_TCFG2_MA_FC_MA_SPT_0

        assign rgn_tcfg2_ma_int = {(FC_NUM_RGN-4)*8{1'b0}};

      end else begin: RGN_TCFG2_MA_FC_MA_SPT_1
        reg [(FC_NUM_RGN-4)*8-1:0] rgn_tcfg2_ma_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_MA_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_ma_r <= {((FC_NUM_RGN-4)*8){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_ma_r[i*8-25-:8] <= {8{1'b0}};
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_ma_r[i*8-25-:8] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-7-:8];
              end
            end
          end
        end

        assign rgn_tcfg2_ma_int[FC_NUM_RGN*8-1:32] = rgn_tcfg2_ma_r;

      end
    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_sh_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_SH_RGN_LESS_THAN_4
      assign rgn_tcfg2_sh_int[2*FC_NUM_RGN-1:0] = {FC_NUM_RGN{2'b01}};
    end else begin : RGN_TCFG2_SH_RGN_MORE_THAN_4
      assign rgn_tcfg2_sh_int[7:0] = {4{2'b01}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_SH_FC_NUM_RGN_NOT_4

      if (FC_SH_SPT == 0) begin: RGN_TCFG2_SH_FC_SH_SPT_0

        assign rgn_tcfg2_sh_int = {(FC_NUM_RGN-4){2'b01}};

      end else begin: RGN_TCFG2_SH_FC_SH_SPT_1
        reg [(FC_NUM_RGN-4)*2-1:0] rgn_tcfg2_sh_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_SH_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_sh_r <= {((FC_NUM_RGN-4)*2){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_sh_r[i*2-7-:2] <= {2{1'b0}};
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_sh_r[i*2-7-:2] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-15-:2];
              end
            end
          end
        end

        assign rgn_tcfg2_sh_int[FC_NUM_RGN*2-1:8] = rgn_tcfg2_sh_r;

      end
    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_ns_int;

    if (FC_NUM_RGN < 4) begin : RGN_TCFG2_NS_RGN_LESS_THAN_4
      assign rgn_tcfg2_ns_int[2*FC_NUM_RGN-1:0] = {FC_NUM_RGN{2'b00}};
    end else begin : RGN_TCFG2_NS_RGN_MORE_THAN_4
      assign rgn_tcfg2_ns_int[7:0] = {4{2'b00}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_TCFG2_NS_FC_NUM_RGN_NOT_4

      if (FC_SEC_SPT == 0) begin: RGN_TCFG2_NS_FC_SEC_SPT_0

        assign rgn_tcfg2_ns_int = {(FC_NUM_RGN-4)*2{1'b0}};

      end else begin: RGN_TCFG2_NS_FC_SEC_SPT_1
        reg [(FC_NUM_RGN-4)*2-1:0] rgn_tcfg2_ns_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_NS_REG
          integer i;
          if (!reset_n) begin
            rgn_tcfg2_ns_r <= {((FC_NUM_RGN-4)*2){1'b0}};
          end else begin
            for (i=4; i<FC_NUM_RGN; i=i+1) begin
              if (default_state_i) begin
                rgn_tcfg2_ns_r[i*2-7-:2] <= {2{1'b0}};
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_ns_r[i*2-7-:2] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-17-:2];
              end
            end
          end
        end

        assign rgn_tcfg2_ns_int[FC_NUM_RGN*2-1:8] = rgn_tcfg2_ns_r;

      end
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG2_ASSEMBLE_OUTPUT

      assign rgn_tcfg2_o[(i+1)*RGN_TCFG2_WIDTH-1-:RGN_TCFG2_WIDTH] =
        {rgn_tcfg2_addr_trans_en_int[i],
         rgn_tcfg2_ma_trans_en_int[i],
         rgn_tcfg2_inst_int[(i+1)*2-1-:2],
         rgn_tcfg2_priv_int[(i+1)*2-1-:2],
         rgn_tcfg2_ma_int[(i+1)*8-1-:8],
         rgn_tcfg2_sh_int[(i+1)*2-1-:2],
         rgn_tcfg2_ns_int[(i+1)*2-1-:2]};

    end


    reg [RGN_TCFG2_WIDTH-1:0] rgn_tcfg2_curr_rgn;

    always @(*) begin:RGN_TCFG2_CURRENT_RGN
      integer i;
      rgn_tcfg2_curr_rgn = {RGN_TCFG2_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_tcfg2_curr_rgn =
            rgn_tcfg2_o[(i+1)*RGN_TCFG2_WIDTH-1-:RGN_TCFG2_WIDTH];
        end
      end
    end

    assign rgn_tcfg2_rgn_o = rgn_tcfg2_curr_rgn;

  end else begin: RGN_TCFG2_PE_LVL_0_OR_TE_LVL_0 
    assign rgn_tcfg2_o     = {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};
    assign rgn_tcfg2_rgn_o = {RGN_TCFG2_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if (FC_PE_LVL > 0) begin: RGN_MID0_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid0_int;
    wire [FC_MST_ID_WIDTH-1:0] rgn_mid0_aux;

    assign rgn_mid0_int[FC_MST_ID_WIDTH-1:0] = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];
    assign rgn_mid0_aux = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];

    if (FC_NUM_RGN > 1) begin: RGN_MID0_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (FC_SINGLE_MST == 1) begin: RGN_MID0_FC_SINGLE_MST_1

        assign rgn_mid0_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] = {FC_NUM_RGN-1{rgn_mid0_aux}};  


      end else begin: RGN_MID0_FC_SINGLE_MST_0

        reg [(FC_NUM_RGN-1)*FC_MST_ID_WIDTH-1:0] rgn_mid0_r;

        always @(posedge clk) begin: RGN_MID0_REG
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mid0_en[i]) begin
              rgn_mid0_r[i*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
                rgn_mid0_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
            end
          end
        end

        assign rgn_mid0_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] = rgn_mid0_r;

      end

    end

    assign rgn_mid0_o = rgn_mid0_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid0_curr_rgn;
    always @(*) begin: RGN_MID0_CURRENT_RGN
      integer i;
      rgn_mid0_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid0_curr_rgn =
            rgn_mid0_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid0_rgn_o = rgn_mid0_curr_rgn;

  end else begin: RGN_MID0_PE_LVL_0
    assign rgn_mid0_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid0_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 2)) begin: RGN_MID1_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid1_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid1_aux;
    assign rgn_mid1_aux = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];

    assign rgn_mid1_int[FC_MST_ID_WIDTH-1:0] = {FC_MST_ID_WIDTH{1'b0}};

    if (FC_NUM_RGN > 1) begin: RGN_MID1_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (FC_SINGLE_MST == 1) begin: RGN_MID1_FC_SINGLE_MST_1

        assign rgn_mid1_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          {(FC_NUM_RGN-1){rgn_mid1_aux}};

      end else begin: RGN_MID1_FC_SINGLE_MST_0

        reg [(FC_NUM_RGN-1)*FC_MST_ID_WIDTH-1:0] rgn_mid1_r;

        always @(posedge clk) begin: RGN_MID1_REG
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mid1_en[i]) begin
              rgn_mid1_r[i*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
                rgn_mid1_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
            end
          end
        end

        assign rgn_mid1_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          rgn_mid1_r;

      end
    end

    assign rgn_mid1_o = rgn_mid1_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid1_curr_rgn;
    always @(*) begin: RGN_MID1_CURRENT_RGN
      integer i;
      rgn_mid1_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid1_curr_rgn =
            rgn_mid1_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid1_rgn_o = rgn_mid1_curr_rgn;

  end else begin: RGN_MID1_PE_LVL_0
    assign rgn_mid1_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid1_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 3)) begin: RGN_MID2_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid2_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid2_aux;
    assign rgn_mid2_aux = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];

    assign rgn_mid2_int[FC_MST_ID_WIDTH-1:0] = {FC_MST_ID_WIDTH{1'b0}};

    if (FC_NUM_RGN > 1) begin: RGN_MID2_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (FC_SINGLE_MST == 1) begin: RGN_MID2_FC_SINGLE_MST_1

        assign rgn_mid2_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          {(FC_NUM_RGN-1){rgn_mid2_aux}};

      end else begin: RGN_MID2_FC_SINGLE_MST_0

        reg [(FC_NUM_RGN-1)*FC_MST_ID_WIDTH-1:0] rgn_mid2_r;

        always @(posedge clk) begin: RGN_MID2_REG
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mid2_en[i]) begin
              rgn_mid2_r[i*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
                rgn_mid2_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
            end
          end
        end

        assign rgn_mid2_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          rgn_mid2_r;

      end
    end


    assign rgn_mid2_o = rgn_mid2_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid2_curr_rgn;
    always @(*) begin: RGN_MID2_CURRENT_RGN
      integer i;
      rgn_mid2_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid2_curr_rgn =
            rgn_mid2_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid2_rgn_o = rgn_mid2_curr_rgn;

  end else begin: RGN_MID2_PE_LVL_0
    assign rgn_mid2_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid2_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 4)) begin: RGN_MID3_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid3_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid3_aux;
    assign rgn_mid3_aux = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];

    assign rgn_mid3_int[FC_MST_ID_WIDTH-1:0] = {FC_MST_ID_WIDTH{1'b0}};

    if (FC_NUM_RGN > 1) begin: RGN_MID3_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (FC_SINGLE_MST == 1) begin: RGN_MID3_FC_SINGLE_MST_1

        assign rgn_mid3_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          {(FC_NUM_RGN-1){rgn_mid3_aux}};

      end else begin: RGN_MID3_FC_SINGLE_MST_0

        reg [(FC_NUM_RGN-1)*FC_MST_ID_WIDTH-1:0] rgn_mid3_r;

        always @(posedge clk) begin: RGN_MID3_REG
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mid3_en[i]) begin
              rgn_mid3_r[i*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
                rgn_mid3_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
            end
          end
        end

        assign rgn_mid3_int[FC_NUM_RGN*FC_MST_ID_WIDTH-1:FC_MST_ID_WIDTH] =
          rgn_mid3_r;

      end
    end

    assign rgn_mid3_o = rgn_mid3_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid3_curr_rgn;
    always @(*) begin: RGN_MID3_CURRENT_RGN
      integer i;
      rgn_mid3_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid3_curr_rgn =
            rgn_mid3_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid3_rgn_o = rgn_mid3_curr_rgn;

  end else begin: RGN_MID3_PE_LVL_0
    assign rgn_mid3_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid3_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL0_SPX_RO = (FC_SEC_SPT == 0)  ||
                               (FC_PRIV_SPT == 0) ||
                               (FC_INST_SPT == 0);

localparam P_RGN_MPL0_SPW_RO = (FC_SEC_SPT == 0)  ||
                               (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL0_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL0_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL0_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL0_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_NSUX_RO = (FC_INST_SPT == 0);

generate
  if (FC_PE_LVL > 0) begin: RGN_MPL0_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl0_any_mst_int;

    assign rgn_mpl0_any_mst_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_ANY_MST_FC_NUM_RGN_NOT_1

      if (FC_SINGLE_MST == 1) begin: RGN_MPL0_ANY_MST_RO

        assign rgn_mpl0_any_mst_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_ANY_MST_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_any_mst_r;

        always @(posedge clk) begin: RGN_MPL0_ANY_MST_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_any_mst_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-1];
            end
          end
        end
        assign rgn_mpl0_any_mst_int[FC_NUM_RGN-1:1] = rgn_mpl0_any_mst_r;
      end
    end




    wire [FC_NUM_RGN-1:0] rgn_mpl0_spx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL0_SPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl0_spx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL0_SPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl0_spx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL0_SPX_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL0_SPX_RO == 1) begin: RGN_MPL0_SPX_RO
        assign rgn_mpl0_spx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL0_SPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl0_spx_r;

        always @(posedge clk) begin: RGN_MPL0_SPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_spx_r[i-4] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-2];
            end
          end
        end
        assign rgn_mpl0_spx_int[FC_NUM_RGN-1:4] = rgn_mpl0_spx_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_spw_int;

    assign rgn_mpl0_spw_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 0)) ? 1'b0 : 1'b1;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_SPW_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_SPW_RO == 1) begin: RGN_MPL0_SPW_RO
        assign rgn_mpl0_spw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_SPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_spw_r;

        always @(posedge clk) begin: RGN_MPL0_SPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_spw_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-3];
            end
          end
        end
        assign rgn_mpl0_spw_int[FC_NUM_RGN-1:1]= rgn_mpl0_spw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_spr_int;

    assign rgn_mpl0_spr_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 0)) ? 1'b0 : 1'b1;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_SPR_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_SPR_RO == 1) begin: RGN_MPL0_SPR_RO
        assign rgn_mpl0_spr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_SPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_spr_r;

        always @(posedge clk) begin: RGN_MPL0_SPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_spr_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-4];
            end
          end
        end
        assign rgn_mpl0_spr_int[FC_NUM_RGN-1:1] = rgn_mpl0_spr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_sux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL0_SUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl0_sux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL0_SUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl0_sux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL0_SUX_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL0_SUX_RO == 1) begin: RGN_MPL0_SUX_RO
        assign rgn_mpl0_sux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL0_SUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl0_sux_r;

        always @(posedge clk) begin: RGN_MPL0_SUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_sux_r[i-4] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-5];
            end
          end
        end
        assign rgn_mpl0_sux_int[FC_NUM_RGN-1:4] = rgn_mpl0_sux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_suw_int;

    assign rgn_mpl0_suw_int[0] =
      ((FC_SEC_SPT == 1) && (FC_PRIV_SPT == 0)) ? 1'b1 : 1'b0 ;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_SUW_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_SUW_RO == 1) begin: RGN_MPL0_SUW_RO
        assign rgn_mpl0_suw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_SUW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_suw_r;

        always @(posedge clk) begin: RGN_MPL0_SUW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_suw_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-6];
            end
          end
        end
        assign rgn_mpl0_suw_int[FC_NUM_RGN-1:1] = rgn_mpl0_suw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_sur_int;

    assign rgn_mpl0_sur_int[0] =
      ((FC_SEC_SPT == 1) && (FC_PRIV_SPT == 0)) ? 1'b1 : 1'b0 ;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_SUR_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_SUR_RO == 1) begin: RGN_MPL0_SUR_RO
        assign rgn_mpl0_sur_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_SUR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_sur_r;

        always @(posedge clk) begin: RGN_MPL0_SUR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_sur_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-7];
            end
          end
        end
        assign rgn_mpl0_sur_int[FC_NUM_RGN-1:1] = rgn_mpl0_sur_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL0_NSPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl0_nspx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL0_NSPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl0_nspx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL0_NSPX_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL0_NSPX_RO == 1) begin: RGN_MPL0_NSPX_RO
        assign rgn_mpl0_nspx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL0_NSPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl0_nspx_r;

        always @(posedge clk) begin: RGN_MPL0_NSPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_nspx_r[i-4] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-8];
            end
          end
        end
        assign rgn_mpl0_nspx_int[FC_NUM_RGN-1:4] = rgn_mpl0_nspx_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspw_int;

    assign rgn_mpl0_nspw_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 1)) ? 1'b1 : 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_NSPW_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_NSPW_RO == 1) begin: RGN_MPL0_NSPW_RO
        assign rgn_mpl0_nspw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_NSPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_nspw_r;

        always @(posedge clk) begin: RGN_MPL0_NSPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_nspw_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-9];
            end
          end
        end
        assign rgn_mpl0_nspw_int[FC_NUM_RGN-1:1] = rgn_mpl0_nspw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspr_int;

    assign rgn_mpl0_nspr_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 1)) ? 1'b1 : 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_NSPR_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_NSPR_RO == 1) begin: RGN_MPL0_NSPR_RO
        assign rgn_mpl0_nspr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL0_NSPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl0_nspr_r;

        always @(posedge clk) begin: RGN_MPL0_NSPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_nspr_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-10];
            end
          end
        end
        assign rgn_mpl0_nspr_int[FC_NUM_RGN-1:1] = rgn_mpl0_nspr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL0_NSUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl0_nsux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL0_NSUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl0_nsux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL0_NSUX_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL0_NSUX_RO == 1) begin: RGN_MPL0_NSUX_RO
        assign rgn_mpl0_nsux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL0_NSUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl0_nsux_r;

        always @(posedge clk) begin: RGN_MPL0_NSUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl0_en[i]) begin
              rgn_mpl0_nsux_r[i-4] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-11];
            end
          end
        end
        assign rgn_mpl0_nsux_int[FC_NUM_RGN-1:4] = rgn_mpl0_nsux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsuw_int;

    assign rgn_mpl0_nsuw_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 0)) ? 1'b1 : 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_NSUW_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl0_nsuw_r;

      always @(posedge clk) begin: RGN_MPL0_NSUW_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nsuw_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-12];
          end
        end
      end
      assign rgn_mpl0_nsuw_int[FC_NUM_RGN-1:1] = rgn_mpl0_nsuw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsur_int;

    assign rgn_mpl0_nsur_int[0] =
      ((FC_SEC_SPT == 0) && (FC_PRIV_SPT == 0)) ? 1'b1 : 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL0_NSUR_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl0_nsur_r;

      always @(posedge clk) begin: RGN_MPL0_NSUR_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nsur_r[i-1] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-13];
          end
        end
      end
      assign rgn_mpl0_nsur_int[FC_NUM_RGN-1:1] = rgn_mpl0_nsur_r;
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL0_ASSEMBLE_OUTPUT
      assign rgn_mpl0_o[(i+1)*RGN_MPL0_WIDTH-1-:RGN_MPL0_WIDTH] =
        {rgn_mpl0_any_mst_int[i],
         rgn_mpl0_spx_int[i],
         rgn_mpl0_spw_int[i],
         rgn_mpl0_spr_int[i],
         rgn_mpl0_sux_int[i],
         rgn_mpl0_suw_int[i],
         rgn_mpl0_sur_int[i],
         rgn_mpl0_nspx_int[i],
         rgn_mpl0_nspw_int[i],
         rgn_mpl0_nspr_int[i],
         rgn_mpl0_nsux_int[i],
         rgn_mpl0_nsuw_int[i],
         rgn_mpl0_nsur_int[i]};
    end


    reg [RGN_MPL0_WIDTH-1:0] rgn_mpl0_curr_rgn;

    always @(*) begin: RGN_MPL0_CURRENT_RGN
      integer i;
      rgn_mpl0_curr_rgn = {RGN_MPL0_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl0_curr_rgn =
            rgn_mpl0_o[(i+1)*RGN_MPL0_WIDTH-1-:RGN_MPL0_WIDTH];
        end
      end
    end

    assign rgn_mpl0_rgn_o = rgn_mpl0_curr_rgn;

  end else begin: RGN_MPL0_PE_LVL_0
    assign rgn_mpl0_o     = {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};
    assign rgn_mpl0_rgn_o = {RGN_MPL0_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL1_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL1_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL1_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL1_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL1_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL1_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 2)) begin: RGN_MPL1_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl1_any_mst_int;

    assign rgn_mpl1_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL1_SPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl1_spx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL1_SPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl1_spx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL1_SPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL1_SPX_RO == 1) begin: RGN_MPL1_SPX_RO
        assign rgn_mpl1_spx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL1_SPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl1_spx_r;

        always @(posedge clk) begin: RGN_MPL1_SPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_spx_r[i-4] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-2];
            end
          end
        end
        assign rgn_mpl1_spx_int[FC_NUM_RGN-1:4] = rgn_mpl1_spx_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spw_int;

    assign rgn_mpl1_spw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_SPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_SPW_RO == 1) begin: RGN_MPL1_SPW_RO
        assign rgn_mpl1_spw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_SPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_spw_r;

        always @(posedge clk) begin: RGN_MPL1_SPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_spw_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-3];
            end
          end
        end
        assign rgn_mpl1_spw_int[FC_NUM_RGN-1:1] = rgn_mpl1_spw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spr_int;

    assign rgn_mpl1_spr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_SPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_SPR_RO == 1) begin: RGN_MPL1_SPR_RO
        assign rgn_mpl1_spr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_SPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_spr_r;

        always @(posedge clk) begin: RGN_MPL1_SPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_spr_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-4];
            end
          end
        end
        assign rgn_mpl1_spr_int[FC_NUM_RGN-1:1] = rgn_mpl1_spr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_sux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL1_SUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl1_sux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL1_SUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl1_sux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL1_SUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL1_SUX_RO == 1) begin: RGN_MPL1_SUX_RO
        assign rgn_mpl1_sux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL1_SUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl1_sux_r;

        always @(posedge clk) begin: RGN_MPL1_SUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_sux_r[i-4] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-5];
            end
          end
        end
        assign rgn_mpl1_sux_int[FC_NUM_RGN-1:4] = rgn_mpl1_sux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_suw_int;

    assign rgn_mpl1_suw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_SUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_SUW_RO == 1) begin: RGN_MPL1_SUW_RO
        assign rgn_mpl1_suw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_SUW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_suw_r;

        always @(posedge clk) begin: RGN_MPL1_SUW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_suw_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-6];
            end
          end
        end
        assign rgn_mpl1_suw_int[FC_NUM_RGN-1:1] = rgn_mpl1_suw_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_sur_int;

    assign rgn_mpl1_sur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_SUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_SUR_RO == 1) begin: RGN_MPL1_SUR_RO
        assign rgn_mpl1_sur_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_SUR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_sur_r;

        always @(posedge clk) begin: RGN_MPL1_SUR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_sur_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-7];
            end
          end
        end
        assign rgn_mpl1_sur_int[FC_NUM_RGN-1:1] = rgn_mpl1_sur_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL1_NSPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl1_nspx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL1_NSPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl1_nspx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL1_NSPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL1_NSPX_RO == 1) begin: RGN_MPL1_NSPX_RO
        assign rgn_mpl1_nspx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL1_NSPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl1_nspx_r;

        always @(posedge clk) begin: RGN_MPL1_NSPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_nspx_r[i-4] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-8];
            end
          end
        end
        assign rgn_mpl1_nspx_int[FC_NUM_RGN-1:4] = rgn_mpl1_nspx_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspw_int;

    assign rgn_mpl1_nspw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_NSPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_NSPW_RO == 1) begin: RGN_MPL1_NSPW_RO
        assign rgn_mpl1_nspw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_NSPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_nspw_r;

        always @(posedge clk) begin: RGN_MPL1_NSPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_nspw_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-9];
            end
          end
        end
        assign rgn_mpl1_nspw_int[FC_NUM_RGN-1:1] = rgn_mpl1_nspw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspr_int;

    assign rgn_mpl1_nspr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_NSPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL1_NSPR_RO == 1) begin: RGN_MPL1_NSPR_RO
        assign rgn_mpl1_nspr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL1_NSPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl1_nspr_r;

        always @(posedge clk) begin: RGN_MPL1_NSPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_nspr_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-10];
            end
          end
        end
        assign rgn_mpl1_nspr_int[FC_NUM_RGN-1:1] = rgn_mpl1_nspr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL1_NSUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl1_nsux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL1_NSUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl1_nsux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL1_NSUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4
      if (P_RGN_MPL1_NSUX_RO == 1) begin: RGN_MPL1_NSUX_RO
        assign rgn_mpl1_nsux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL1_NSUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl1_nsux_r;

        always @(posedge clk) begin: RGN_MPL1_NSUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl1_en[i]) begin
              rgn_mpl1_nsux_r[i-4] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-11];
            end
          end
        end
        assign rgn_mpl1_nsux_int[FC_NUM_RGN-1:4] = rgn_mpl1_nsux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsuw_int;

    assign rgn_mpl1_nsuw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_NSUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl1_nsuw_r;

      always @(posedge clk) begin: RGN_MPL1_NSUW_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nsuw_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-12];
          end
        end
      end
      assign rgn_mpl1_nsuw_int[FC_NUM_RGN-1:1] = rgn_mpl1_nsuw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsur_int;

    assign rgn_mpl1_nsur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL1_NSUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl1_nsur_r;

      always @(posedge clk) begin: RGN_MPL1_NSUR_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nsur_r[i-1] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-13];
          end
        end
      end
      assign rgn_mpl1_nsur_int[FC_NUM_RGN-1:1] = rgn_mpl1_nsur_r;
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL1_ASSEMBLE_OUTPUT
      assign rgn_mpl1_o[(i+1)*RGN_MPL1_WIDTH-1-:RGN_MPL1_WIDTH] =
        {rgn_mpl1_any_mst_int[i],
         rgn_mpl1_spx_int[i],
         rgn_mpl1_spw_int[i],
         rgn_mpl1_spr_int[i],
         rgn_mpl1_sux_int[i],
         rgn_mpl1_suw_int[i],
         rgn_mpl1_sur_int[i],
         rgn_mpl1_nspx_int[i],
         rgn_mpl1_nspw_int[i],
         rgn_mpl1_nspr_int[i],
         rgn_mpl1_nsux_int[i],
         rgn_mpl1_nsuw_int[i],
         rgn_mpl1_nsur_int[i]};
    end


    reg [RGN_MPL1_WIDTH-1:0] rgn_mpl1_curr_rgn;

    always @(*) begin: RGN_MPL1_CURRENT_RGN
      integer i;
      rgn_mpl1_curr_rgn = {RGN_MPL1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl1_curr_rgn =
            rgn_mpl1_o[(i+1)*RGN_MPL1_WIDTH-1-:RGN_MPL1_WIDTH];
        end
      end
    end

    assign rgn_mpl1_rgn_o = rgn_mpl1_curr_rgn;

  end else begin: RGN_MPL1_PE_LVL_0
    assign rgn_mpl1_o     = {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};
    assign rgn_mpl1_rgn_o = {RGN_MPL1_WIDTH{1'b0}}           ;
  end
endgenerate



localparam P_RGN_MPL2_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL2_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL2_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL2_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL2_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL2_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 3)) begin: RGN_MPL2_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl2_any_mst_int;

    assign rgn_mpl2_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL2_SPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl2_spx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL2_SPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl2_spx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL2_SPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL2_SPX_RO == 1) begin: RGN_MPL2_SPX_RO
        assign rgn_mpl2_spx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL2_SPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl2_spx_r;

        always @(posedge clk) begin: RGN_MPL2_SPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_spx_r[i-4] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-2];
            end
          end
        end
        assign rgn_mpl2_spx_int[FC_NUM_RGN-1:4] = rgn_mpl2_spx_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spw_int;

    assign rgn_mpl2_spw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_SPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_SPW_RO == 1) begin: RGN_MPL2_SPW_RO
        assign rgn_mpl2_spw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_SPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_spw_r;

        always @(posedge clk) begin: RGN_MPL2_SPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_spw_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-3];
            end
          end
        end
        assign rgn_mpl2_spw_int[FC_NUM_RGN-1:1] = rgn_mpl2_spw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spr_int;

    assign rgn_mpl2_spr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_SPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_SPR_RO == 1) begin: RGN_MPL2_SPR_RO
        assign rgn_mpl2_spr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_SPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_spr_r;

        always @(posedge clk) begin: RGN_MPL2_SPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_spr_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-4];
            end
          end
        end
        assign rgn_mpl2_spr_int[FC_NUM_RGN-1:1] = rgn_mpl2_spr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_sux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL2_SUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl2_sux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL2_SUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl2_sux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL2_SUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL2_SUX_RO == 1) begin: RGN_MPL2_SUX_RO
        assign rgn_mpl2_sux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL2_SUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl2_sux_r;

        always @(posedge clk) begin: RGN_MPL2_SUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_sux_r[i-4] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-5];
            end
          end
        end
        assign rgn_mpl2_sux_int[FC_NUM_RGN-1:4] = rgn_mpl2_sux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_suw_int;

    assign rgn_mpl2_suw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_SUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_SUW_RO == 1) begin: RGN_MPL2_SUW_RO
        assign rgn_mpl2_suw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_SUW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_suw_r;

        always @(posedge clk) begin: RGN_MPL2_SUW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_suw_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-6];
            end
          end
        end
        assign rgn_mpl2_suw_int[FC_NUM_RGN-1:1] = rgn_mpl2_suw_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_sur_int;

    assign rgn_mpl2_sur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_SUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_SUR_RO == 1) begin: RGN_MPL2_SUR_RO
        assign rgn_mpl2_sur_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_SUR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_sur_r;

        always @(posedge clk) begin: RGN_MPL2_SUR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_sur_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-7];
            end
          end
        end
        assign rgn_mpl2_sur_int[FC_NUM_RGN-1:1] = rgn_mpl2_sur_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL2_NSPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl2_nspx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL2_NSPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl2_nspx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL2_NSPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL2_NSPX_RO == 1) begin: RGN_MPL2_NSPX_RO
        assign rgn_mpl2_nspx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL2_NSPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl2_nspx_r;

        always @(posedge clk) begin: RGN_MPL2_NSPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_nspx_r[i-4] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-8];
            end
          end
        end
        assign rgn_mpl2_nspx_int[FC_NUM_RGN-1:4] = rgn_mpl2_nspx_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspw_int;

    assign rgn_mpl2_nspw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_NSPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_NSPW_RO == 1) begin: RGN_MPL2_NSPW_RO
        assign rgn_mpl2_nspw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_NSPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_nspw_r;

        always @(posedge clk) begin: RGN_MPL2_NSPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_nspw_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-9];
            end
          end
        end
        assign rgn_mpl2_nspw_int[FC_NUM_RGN-1:1] = rgn_mpl2_nspw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspr_int;

    assign rgn_mpl2_nspr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_NSPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL2_NSPR_RO == 1) begin: RGN_MPL2_NSPR_RO
        assign rgn_mpl2_nspr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL2_NSPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl2_nspr_r;

        always @(posedge clk) begin: RGN_MPL2_NSPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_nspr_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-10];
            end
          end
        end
        assign rgn_mpl2_nspr_int[FC_NUM_RGN-1:1] = rgn_mpl2_nspr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL2_NSUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl2_nsux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL2_NSUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl2_nsux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_NSUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1
      if (P_RGN_MPL2_NSUX_RO == 1) begin: RGN_MPL2_NSUX_RO
        assign rgn_mpl2_nsux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL2_NSUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl2_nsux_r;

        always @(posedge clk) begin: RGN_MPL2_NSUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl2_en[i]) begin
              rgn_mpl2_nsux_r[i-4] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-11];
            end
          end
        end
        assign rgn_mpl2_nsux_int[FC_NUM_RGN-1:4] = rgn_mpl2_nsux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsuw_int;

    assign rgn_mpl2_nsuw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_NSUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl2_nsuw_r;

      always @(posedge clk) begin: RGN_MPL2_NSUW_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nsuw_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-12];
          end
        end
      end
      assign rgn_mpl2_nsuw_int[FC_NUM_RGN-1:1] = rgn_mpl2_nsuw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsur_int;

    assign rgn_mpl2_nsur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL2_NSUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl2_nsur_r;

      always @(posedge clk) begin: RGN_MPL2_NSUR_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nsur_r[i-1] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-13];
          end
        end
      end
      assign rgn_mpl2_nsur_int[FC_NUM_RGN-1:1] = rgn_mpl2_nsur_r;
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL2_ASSEMBLE_OUTPUT
      assign rgn_mpl2_o[(i+1)*RGN_MPL2_WIDTH-1-:RGN_MPL2_WIDTH] =
        {rgn_mpl2_any_mst_int[i],
         rgn_mpl2_spx_int[i],
         rgn_mpl2_spw_int[i],
         rgn_mpl2_spr_int[i],
         rgn_mpl2_sux_int[i],
         rgn_mpl2_suw_int[i],
         rgn_mpl2_sur_int[i],
         rgn_mpl2_nspx_int[i],
         rgn_mpl2_nspw_int[i],
         rgn_mpl2_nspr_int[i],
         rgn_mpl2_nsux_int[i],
         rgn_mpl2_nsuw_int[i],
         rgn_mpl2_nsur_int[i]};
    end


    reg [RGN_MPL2_WIDTH-1:0] rgn_mpl2_curr_rgn;

    always @(*) begin: RGN_MPL2_CURRENT_RGN
      integer i;
      rgn_mpl2_curr_rgn = {RGN_MPL2_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl2_curr_rgn =
            rgn_mpl2_o[(i+1)*RGN_MPL2_WIDTH-1-:RGN_MPL2_WIDTH];
        end
      end
    end

    assign rgn_mpl2_rgn_o = rgn_mpl2_curr_rgn;

  end else begin: RGN_MPL2_PE_LVL_0
    assign rgn_mpl2_o     = {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};
    assign rgn_mpl2_rgn_o = {RGN_MPL2_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL3_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL3_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL3_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL3_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL3_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL3_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 4)) begin: RGN_MPL3_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl3_any_mst_int;

    assign rgn_mpl3_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL3_SPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl3_spx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL3_SPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl3_spx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL3_SPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL3_SPX_RO == 1) begin: RGN_MPL3_SPX_RO
        assign rgn_mpl3_spx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL3_SPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl3_spx_r;

        always @(posedge clk) begin: RGN_MPL3_SPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_spx_r[i-4] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-2];
            end
          end
        end
        assign rgn_mpl3_spx_int[FC_NUM_RGN-1:4] = rgn_mpl3_spx_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spw_int;

    assign rgn_mpl3_spw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_SPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_SPW_RO == 1) begin: RGN_MPL3_SPW_RO
        assign rgn_mpl3_spw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_SPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_spw_r;

        always @(posedge clk) begin: RGN_MPL3_SPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_spw_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-3];
            end
          end
        end
        assign rgn_mpl3_spw_int[FC_NUM_RGN-1:1] = rgn_mpl3_spw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spr_int;

    assign rgn_mpl3_spr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_SPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_SPR_RO == 1) begin: RGN_MPL3_SPR_RO
        assign rgn_mpl3_spr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_SPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_spr_r;

        always @(posedge clk) begin: RGN_MPL3_SPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_spr_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-4];
            end
          end
        end
        assign rgn_mpl3_spr_int[FC_NUM_RGN-1:1] = rgn_mpl3_spr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_sux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL3_SUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl3_sux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL3_SUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl3_sux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL3_SUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL3_SUX_RO == 1) begin: RGN_MPL3_SUX_RO
        assign rgn_mpl3_sux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL3_SUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl3_sux_r;

        always @(posedge clk) begin: RGN_MPL3_SUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_sux_r[i-4] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-5];
            end
          end
        end
        assign rgn_mpl3_sux_int[FC_NUM_RGN-1:4] = rgn_mpl3_sux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_suw_int;

    assign rgn_mpl3_suw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_SUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_SUW_RO == 1) begin: RGN_MPL3_SUW_RO
        assign rgn_mpl3_suw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_SUW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_suw_r;

        always @(posedge clk) begin: RGN_MPL3_SUW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_suw_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-6];
            end
          end
        end
        assign rgn_mpl3_suw_int[FC_NUM_RGN-1:1] = rgn_mpl3_suw_r;
      end

    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_sur_int;

    assign rgn_mpl3_sur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_SUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_SUR_RO == 1) begin: RGN_MPL3_SUR_RO
        assign rgn_mpl3_sur_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_SUR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_sur_r;

        always @(posedge clk) begin: RGN_MPL3_SUR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_sur_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-7];
            end
          end
        end
        assign rgn_mpl3_sur_int[FC_NUM_RGN-1:1] = rgn_mpl3_sur_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspx_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL3_NSPX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl3_nspx_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL3_NSPX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl3_nspx_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL3_NSPX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4

      if (P_RGN_MPL3_NSPX_RO == 1) begin: RGN_MPL3_NSPX_RO
        assign rgn_mpl3_nspx_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL3_NSPX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl3_nspx_r;

        always @(posedge clk) begin: RGN_MPL3_NSPX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_nspx_r[i-4] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-8];
            end
          end
        end
        assign rgn_mpl3_nspx_int[FC_NUM_RGN-1:4] = rgn_mpl3_nspx_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspw_int;

    assign rgn_mpl3_nspw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_NSPW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_NSPW_RO == 1) begin: RGN_MPL3_NSPW_RO
        assign rgn_mpl3_nspw_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_NSPW_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_nspw_r;

        always @(posedge clk) begin: RGN_MPL3_NSPW_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_nspw_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-9];
            end
          end
        end
        assign rgn_mpl3_nspw_int[FC_NUM_RGN-1:1] = rgn_mpl3_nspw_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspr_int;

    assign rgn_mpl3_nspr_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_NSPR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      if (P_RGN_MPL3_NSPR_RO == 1) begin: RGN_MPL3_NSPR_RO
        assign rgn_mpl3_nspr_int[FC_NUM_RGN-1:1] = {(FC_NUM_RGN-1){1'b0}};

      end else begin: RGN_MPL3_NSPR_RW
        reg [FC_NUM_RGN-2:0] rgn_mpl3_nspr_r;

        always @(posedge clk) begin: RGN_MPL3_NSPR_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_nspr_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-10];
            end
          end
        end
        assign rgn_mpl3_nspr_int[FC_NUM_RGN-1:1] = rgn_mpl3_nspr_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsux_int;

    if (FC_NUM_RGN < 4) begin : RGN_MPL3_NSUX_FC_NUM_RGN_LESS_THAN_4
      assign rgn_mpl3_nsux_int[FC_NUM_RGN-1:0] = {FC_NUM_RGN{1'b0}};
    end else begin : RGN_MPL3_NSUX_FC_NUM_RGN_MORE_THAN_4
      assign rgn_mpl3_nsux_int[3:0] = {4{1'b0}};
    end

    if (FC_NUM_RGN > 4) begin: RGN_MPL3_NSUX_PE_LVL_NOT_0_FC_NUM_RGN_NOT_4
      if (P_RGN_MPL3_NSUX_RO == 1) begin: RGN_MPL3_NSUX_RO
        assign rgn_mpl3_nsux_int[FC_NUM_RGN-1:4] = {(FC_NUM_RGN-4){1'b0}};

      end else begin: RGN_MPL3_NSUX_RW
        reg [FC_NUM_RGN-5:0] rgn_mpl3_nsux_r;

        always @(posedge clk) begin: RGN_MPL3_NSUX_REG
          integer i;
          for (i=4; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_mpl3_en[i]) begin
              rgn_mpl3_nsux_r[i-4] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-11];
            end
          end
        end
        assign rgn_mpl3_nsux_int[FC_NUM_RGN-1:4] = rgn_mpl3_nsux_r;
      end
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsuw_int;

    assign rgn_mpl3_nsuw_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_NSUW_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl3_nsuw_r;

      always @(posedge clk) begin: RGN_MPL3_NSUW_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nsuw_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-12];
          end
        end
      end
      assign rgn_mpl3_nsuw_int[FC_NUM_RGN-1:1] = rgn_mpl3_nsuw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsur_int;

    assign rgn_mpl3_nsur_int[0] = 1'b0;

    if (FC_NUM_RGN > 1) begin: RGN_MPL3_NSUR_PE_LVL_NOT_0_FC_NUM_RGN_NOT_1

      reg [FC_NUM_RGN-2:0] rgn_mpl3_nsur_r;

      always @(posedge clk) begin: RGN_MPL3_NSUR_REG
        integer i;
        for (i=1; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nsur_r[i-1] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-13];
          end
        end
      end
      assign rgn_mpl3_nsur_int[FC_NUM_RGN-1:1] = rgn_mpl3_nsur_r;
    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL3_ASSEMBLE_OUTPUT
      assign rgn_mpl3_o[(i+1)*RGN_MPL3_WIDTH-1-:RGN_MPL3_WIDTH] =
        {rgn_mpl3_any_mst_int[i],
         rgn_mpl3_spx_int[i],
         rgn_mpl3_spw_int[i],
         rgn_mpl3_spr_int[i],
         rgn_mpl3_sux_int[i],
         rgn_mpl3_suw_int[i],
         rgn_mpl3_sur_int[i],
         rgn_mpl3_nspx_int[i],
         rgn_mpl3_nspw_int[i],
         rgn_mpl3_nspr_int[i],
         rgn_mpl3_nsux_int[i],
         rgn_mpl3_nsuw_int[i],
         rgn_mpl3_nsur_int[i]};
    end


    reg [RGN_MPL3_WIDTH-1:0] rgn_mpl3_curr_rgn;

    always @(*) begin: RGN_MPL3_CURRENT_RGN
      integer i;
      rgn_mpl3_curr_rgn = {RGN_MPL3_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl3_curr_rgn =
            rgn_mpl3_o[(i+1)*RGN_MPL3_WIDTH-1-:RGN_MPL3_WIDTH];
        end
      end
    end

    assign rgn_mpl3_rgn_o = rgn_mpl3_curr_rgn;

  end else begin: RGN_MPL3_PE_LVL_0
    assign rgn_mpl3_o     = {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};
    assign rgn_mpl3_rgn_o = {RGN_MPL3_WIDTH{1'b0}}           ;
  end
endgenerate

reg [2:0] fe_ctrl_int;

reg [2:0] fe_irq_int;
reg       fe_irq_valid_int;

wire [2:0] fe_irq;
wire       fe_irq_valid;

reg  last_fe_rd;
wire fe_rd_wr;
wire fe_rd_priority;

assign fe_rd_wr = fe_rdch_en && fe_wrch_en;

always @ (posedge clk or negedge reset_n) begin: rd_wr_fe_trkr
  if (!reset_n) begin
    last_fe_rd <= 1'b0;
  end
  else begin
    if (default_state_i) begin
      last_fe_rd <= 1'b0;
    end
    else if (fe_rd_wr) begin
      last_fe_rd <= ~last_fe_rd;
    end
  end
end 

assign fe_rd_priority = !fe_rd_wr || (fe_rd_wr && !last_fe_rd);

always @(posedge clk or negedge reset_n)
begin: fe_mux
  if (!reset_n) begin
    fe_tal_o         <= {FE_TAL_WIDTH{1'b0}};
    fe_tau_o         <= {FE_TAU_WIDTH{1'b0}};
    fe_tp_o          <= {FE_TP_WIDTH{1'b0}};
    fe_ctrl_int[2:0] <= 3'b000;
  end
  else if (default_state_i) begin
    fe_tal_o         <= {FE_TAL_WIDTH{1'b0}};
    fe_tau_o         <= {FE_TAU_WIDTH{1'b0}};
    fe_tp_o          <= {FE_TP_WIDTH{1'b0}};
    fe_ctrl_int[2:0] <= 3'b000;
  end
  else if (fe_rdch_en && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_tal_o         <= fe_tal_rdch_i;
    fe_tau_o         <= fe_tau_rdch_i;
    fe_tp_o          <= fe_tp_rdch_i;
    fe_ctrl_int[2:1] <= 2'b11;
    fe_ctrl_int[0]   <= fe_type_rdch_i;
  end
  else if (fe_wrch_en && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_tal_o         <= fe_tal_wrch_i;
    fe_tau_o         <= fe_tau_wrch_i;
    fe_tp_o          <= fe_tp_wrch_i;
    fe_ctrl_int[2:1] <= 2'b11;
    fe_ctrl_int[0]   <= fe_type_wrch_i;
  end
  else if (fe_ctrl_i[0] && fe_ctrl_en) begin
    fe_tal_o       <= {FE_TAL_WIDTH{1'b0}};
    fe_tau_o       <= {FE_TAU_WIDTH{1'b0}};
    fe_tp_o        <= {FE_TP_WIDTH{1'b0}};
    fe_ctrl_int[2] <= 1'b0;
    fe_ctrl_int[1] <= 1'b0;
  end
  else if (!fe_ctrl_o[4]) begin
    fe_tal_o       <= {FE_TAL_WIDTH{1'b0}};
    fe_tau_o       <= {FE_TAU_WIDTH{1'b0}};
    fe_tp_o        <= {FE_TP_WIDTH{1'b0}};
    fe_ctrl_int[2] <= 1'b0;
    fe_ctrl_int[0] <= 1'b0;
  end
end 

generate
  if (FC_SINGLE_MST == 0) begin : FE_REG_MST_MID

    reg [FC_MST_ID_WIDTH-1:0] fe_mid_aux;

    always @(posedge clk or negedge reset_n)
    begin: fe_mux_mid
      if (!reset_n) begin
        fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
      end
      else if (default_state_i) begin
        fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
      end
      else if (fe_rdch_en && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_mid_aux <= fe_mid_rdch_i;
      end
      else if (fe_wrch_en && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_mid_aux <= fe_mid_wrch_i;
      end
      else if (fe_ctrl_i[0] && fe_ctrl_en) begin
        fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
      end
      else if (!fe_ctrl_o[4]) begin
        fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
      end
    end 

    always @* begin
      fe_mid_o = fe_mid_aux;
    end

  end
  else begin: FE_SINGLE_MST_MID
    always @* begin
      fe_mid_o = fe_ctrl_o[4] ? CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0] : {FC_MST_ID_WIDTH{1'b0}};
    end
  end
endgenerate

assign fe_ctrl_o = {fe_ctrl_int, {3{1'b0}}};

always @* begin: fe_irq_comb
  fe_irq_int       = {3{1'b0}};
  fe_irq_valid_int = 1'b0;

  if (fe_rdch_en && !fe_type_rdch_i && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_irq_int[0]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end
  else if (fe_wrch_en && !fe_type_wrch_i && !(fe_rdch_en && fe_type_rdch_i && fe_rd_priority) && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_irq_int[0]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end

  if (fe_rdch_en && fe_type_rdch_i && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_irq_int[1]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end
  else if (fe_wrch_en && fe_type_wrch_i && !(fe_rdch_en && !fe_type_rdch_i && fe_rd_priority) && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
    fe_irq_int[1]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end

  if (fe_wrch_en && fe_rdch_en) begin
    fe_irq_int[2]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end
  else if ((fe_wrch_en || fe_rdch_en) && fe_ctrl_o[4] && !(fe_ctrl_i[0] && fe_ctrl_en)) begin
    fe_irq_int[2]    = 1'b1;
    fe_irq_valid_int = 1'b1;
  end

end 

assign fe_irq       = fe_irq_int;
assign fe_irq_valid = fe_irq_valid_int;


generate
  if (FC_ME_LVL > 0) begin: ME_CTRL_ME_LVL_NOT_0

    reg [ME_CTRL_WIDTH-1:0]                me_ctrl_r  ;

    always @(posedge clk or negedge reset_n) begin: ME_CTRL_REG
      if (!reset_n) begin
        me_ctrl_r <= ME_CTRL_RST_VAL;
      end else begin
        if (default_state_i) begin
          me_ctrl_r <= ME_CTRL_RST_VAL;
        end
        else if (me_ctrl_en) begin
          me_ctrl_r <= me_ctrl_i;
        end
      end
    end

    assign me_ctrl_o = me_ctrl_r;

  end else begin: ME_CTRL_ME_LVL_0

    assign me_ctrl_o = {ME_CTRL_WIDTH{1'b0}};

  end
endgenerate


reg [FW_NUM_FC-1:0] comp_pwr_st_r;

always @(posedge clk or negedge reset_n) begin: CMP_PWR_ST_REG
  integer i;
  if (!reset_n) begin
    comp_pwr_st_r <= {FW_NUM_FC{1'b0}};
  end else begin
    for (i=0; i<FW_NUM_FC; i=i+1) begin
      if (comp_pwr_st_en[i]) begin
        comp_pwr_st_r[i] <= comp_pwr_st_i[i];
      end
    end
  end
end

assign comp_pwr_st_ctrl_o = comp_pwr_st_r;


reg [1:0] fw_ctrl_r;

always @(posedge clk or negedge reset_n) begin: FW_CTRL_REG
  if (!reset_n) begin
    fw_ctrl_r <= {1'b0, 1'b1};
  end else begin
    if (default_state_i) begin
      fw_ctrl_r <= {1'b0, 1'b1};
    end
    else if (fw_ctrl_en) begin
      fw_ctrl_r <= fw_ctrl_i;
    end
  end
end

assign fw_ctrl_o = fw_ctrl_r;


generate
  if (FW_SRE_LVL > 0) begin: FW_SR_CTRL_FW_SRE_LVL_NOT_0

    reg [1:0] fw_sr_ctrl_r;
    reg  fw_sr_ctrl_reg;

    always @(posedge clk or negedge reset_n)
    begin: REG_FW_SR_CTRL
      if (!reset_n) begin
        fw_sr_ctrl_r <= 2'b00;
      end else begin

        if (default_state_i) begin
          fw_sr_ctrl_r[0] <= 1'b0;
        end
        else if (fw_sr_ctrl_en) begin
            fw_sr_ctrl_r[0] <= fw_sr_ctrl_i[0];
        end

        if (default_state_i) begin
          fw_sr_ctrl_r[1] <= 1'b0;
        end
        else if (sram_init_done_i) begin
          fw_sr_ctrl_r[1] <= 1'b1;
        end

      end
    end

    assign fw_sr_ctrl_o = {fw_sr_ctrl_reg, fw_sr_ctrl_r[0]};


    always @(posedge clk or negedge reset_n) begin: UPDATE_STATUS_REGS
      if (!reset_n) begin
        fw_sr_ctrl_reg <= 1'b0;
      end else begin
        if (default_state_i) begin
          fw_sr_ctrl_reg <= 1'b0;
        end
        else if (!status_enable) begin
          fw_sr_ctrl_reg <= fw_sr_ctrl_r[1] ;
        end
      end
    end


  end else begin: FW_SR_CTRL_FW_SRE_LVL_0

    assign fw_sr_ctrl_o = 2'b10;

  end
endgenerate

reg [(FW_NUM_FC+1)*FC_INT_ST_WIDTH-1:0] fc_int_st_r;
reg [FW_NUM_FC*FC_INT_ST_WIDTH-1:0] fc_ext_int_st_en;

integer ext_int;
integer ext_int_set;

always @* begin
  fc_ext_int_st_en = {FW_NUM_FC*FC_INT_ST_WIDTH{1'b0}};
  for (ext_int=0; ext_int<FW_NUM_FC; ext_int=ext_int+1) begin
    if (ext_int == cfg_irq_fw_id_i) begin
      if (cfg_irq_type_i[0]) begin
        fc_ext_int_st_en[FC_INT_ST_WIDTH*ext_int] = 1'b1;
      end
      if (cfg_irq_type_i[1]) begin
        fc_ext_int_st_en[FC_INT_ST_WIDTH*ext_int + 1] = 1'b1;
      end
      if (cfg_irq_type_i[2]) begin
        fc_ext_int_st_en[FC_INT_ST_WIDTH*ext_int + 2] = 1'b1;
      end
      if (cfg_irq_type_i[3]) begin
        fc_ext_int_st_en[FC_INT_ST_WIDTH*ext_int + 3] = 1'b1;
      end
      if (cfg_irq_type_i[4]) begin
        fc_ext_int_st_en[FC_INT_ST_WIDTH*ext_int + 4] = 1'b1;
      end
    end
  end
end

always @(posedge clk or negedge reset_n)
begin: REG_FC_INT_ST
  if (!reset_n) begin

    fc_int_st_r <= {((FW_NUM_FC+1)*FC_INT_ST_WIDTH){1'b0}};

  end else begin

    if (fe_irq_valid) begin

      fc_int_st_r[FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH] <=
        fc_int_st_r[FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH] |
        ({2'b0, fe_irq} & ~fc_int_msk_o[FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH]);

    end else begin

      if (default_state_i) begin
        fc_int_st_r[FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] <= {FC_INT_ST_WIDTH{1'b0}};
      end
      else if (fc_int_st_en[0]) begin
        fc_int_st_r[FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] <=
          fc_int_st_r[FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] &
          ~fc_int_st_i[FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH];
      end

    end
    for (ext_int_set=0; ext_int_set<FW_NUM_FC; ext_int_set=ext_int_set+1) begin

      if (default_state_i) begin
        fc_int_st_r[(ext_int_set+2)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] <= {FC_INT_ST_WIDTH{1'b0}};
      end
      else if (|fc_ext_int_st_en[(ext_int_set+1)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] && cfg_irq_req_i) begin

        fc_int_st_r[(ext_int_set+2)*FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH] <=
          fc_int_st_r[(ext_int_set+2)*FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH] |
          (fc_ext_int_st_en[(ext_int_set+1)*FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH] &
          ~fc_int_msk_o[(ext_int_set+2)*FC_INT_ST_WIDTH-1 -: FC_INT_ST_WIDTH]);

      end else begin

        if (fc_int_st_en[ext_int_set+1]) begin

          fc_int_st_r[(ext_int_set+2)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] <=
            fc_int_st_r[(ext_int_set+2)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH] &
            ~fc_int_st_i[(ext_int_set+2)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH];

        end

      end

    end

  end
end

generate
  if (FW_NUM_FC == 31) begin : FC_31_INT_ST_O
    assign fc_int_st_o = fc_int_st_r;
  end
  else begin : FC_NOT_31_INT_ST_O
    assign fc_int_st_o = {{((32-(FW_NUM_FC+1))*5){1'b0}}, fc_int_st_r};
    assign fw_int_st_o[31-:(32-(FW_NUM_FC+1))] = {(32-(FW_NUM_FC+1)){1'b0}};
  end

  for (i=0; i<FW_NUM_FC+1; i=i+1) begin: R_FW_ST
    assign fw_int_st_o[i] = |fc_int_st_o[(i+1)*FC_INT_ST_WIDTH-1-:FC_INT_ST_WIDTH];
  end

endgenerate


always @(posedge clk or negedge reset_n)
begin: intrpt
  if (!reset_n) begin
    fw_global_int_st <= 1'b0;
  end else begin
    if (default_state_i) begin
      fw_global_int_st <= 1'b0;
    end
    else begin
      fw_global_int_st <= |fw_int_st_o;
    end
  end
end 


reg [(FW_NUM_FC+1)*FC_INT_ST_WIDTH-1:0] fc_int_msk_r ;

always @(posedge clk or negedge reset_n)
begin: REG_FC_INT_MSK
  integer i;

  if (!reset_n) begin

    fc_int_msk_r <= {((FW_NUM_FC+1)*FC_INT_ST_WIDTH){1'b0}};

  end else begin

    if (FC_ME_LVL>0) begin
      if (default_state_i) begin
        fc_int_msk_r[4:3] <= {2{1'b0}};
      end
      else if (fc_int_msk_en[0]) begin
        fc_int_msk_r[4:3] <= fc_int_msk_i[4:3];
      end
    end else begin
      fc_int_msk_r[4:3] <= {2{1'b0}};
    end

    if (FC_PE_LVL>0) begin
      if (default_state_i) begin
        fc_int_msk_r[2:0] <= {3{1'b0}};
      end
      else if (fc_int_msk_en[0]) begin
        fc_int_msk_r[2:0] <= fc_int_msk_i[2:0];
      end
    end else begin
      fc_int_msk_r[2:0] <= {3{1'b0}};
    end

    for (i=0; i<FW_NUM_FC; i=i+1) begin

      if (FC_ME_LVL_EXT[(i+1)*2-1-:2]>0) begin
        if (default_state_i) begin
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-1-:2] <= {2{1'b0}};
        end
        else if (fc_int_msk_en[i+1]) begin
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-1-:2] <=
            fc_int_msk_i[(i+2)*FC_INT_ST_WIDTH-1-:2];
        end
      end else begin
        fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-1-:2] <= {2{1'b0}};
      end

      if (FC_PE_LVL_EXT[(i+1)*2-1-:2]>0) begin
        if (default_state_i) begin
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-3-:3] <= {3{1'b0}};
        end
        else if (fc_int_msk_en[i+1]) begin
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-3-:3] <=
            fc_int_msk_i[(i+2)*FC_INT_ST_WIDTH-3-:3];
        end
      end else begin
        fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-3-:3] <= {3{1'b0}};
      end

    end

  end
end

generate
  if (FC_ME_LVL>0 || FC_TE_LVL>0 || |FC_ME_LVL_EXT || |FC_PE_LVL_EXT) begin: R_INT_MSK

    if (FC_ME_LVL>0) begin: WR_R_0
      assign fc_int_msk_o[4:3] = fc_int_msk_r[4:3];
    end else begin: WR_0_0
      assign fc_int_msk_o[4:3] = 2'b00;
    end

    if (FC_PE_LVL>0) begin: WR_R_1
      assign fc_int_msk_o[2:0] = fc_int_msk_r[2:0];
    end else begin: WR_0_1
      assign fc_int_msk_o[2:0] = 3'b000;
    end

    for (i=0; i<FW_NUM_FC; i=i+1) begin: ID_GRT_0

      if (FC_ME_LVL_EXT[(i+1)*2-1-:2]>0) begin: WR_R_2
        assign fc_int_msk_o[(i+2)*FC_INT_ST_WIDTH-1-:2] =
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-1-:2];
      end else begin: WR_0_2
        assign fc_int_msk_o[(i+2)*FC_INT_ST_WIDTH-1-:2] = 2'b00;
      end

      if (FC_PE_LVL_EXT[(i+1)*2-1-:2]>0) begin: WR_R_3
        assign fc_int_msk_o[(i+2)*FC_INT_ST_WIDTH-3-:3] =
          fc_int_msk_r[(i+2)*FC_INT_ST_WIDTH-3-:3];
      end else begin: WR_0_3
        assign fc_int_msk_o[(i+2)*FC_INT_ST_WIDTH-3-:3] = 3'b000;
      end
    end

  end

  if (FW_NUM_FC != 31) begin : FC_NOT_31_INT_MSK
    assign fc_int_msk_o[32*5-1-:(32-FW_NUM_FC-1)*5] ={((32-FW_NUM_FC-1)*5){1'b0}};
  end
endgenerate


generate
  if (FW_LDE_LVL > 0) begin: LD_CTRL_LDE_LVL_NOT_0 

    reg [(FW_NUM_FC+1)*(LD_CTRL_WIDTH-1)-1:0] ld_ctrl_r;

    always @(posedge clk or negedge reset_n) begin: LD_CTRL_REG
      integer i;
      if (!reset_n) begin
        ld_ctrl_r <= {(FW_NUM_FC+1)*(LD_CTRL_WIDTH-1){1'b0}};
      end else begin
        for (i=0; i<FW_NUM_FC+1; i=i+1) begin
          if (default_state_i) begin
            ld_ctrl_r[(i+1)*2-1-:2] <= {2{1'b0}};
          end
          else if (ld_ctrl_en[i]) begin
            ld_ctrl_r[(i+1)*2-1-:2] <=
              ld_ctrl_i[(i+1)*LD_CTRL_WIDTH-2-:2];
          end
        end
      end
    end

    assign ld_ctrl_o[LD_CTRL_WIDTH-1:0] = {ldi_st_i, ld_ctrl_r[1:0]};

    for (i=1; i<FW_NUM_FC+1; i=i+1) begin: LD_CTRL_LDE_LVL_NOT_0_ASSEMBLE_OUTPUT
      assign ld_ctrl_o[(i+1)*LD_CTRL_WIDTH-1-:LD_CTRL_WIDTH] =
        {1'b0, ld_ctrl_r[(i+1)*2-1-:2]};
    end

  end else begin: LD_CTRL_LDE_LVL_0 

    assign ld_ctrl_o = {(FW_NUM_FC+1)*LD_CTRL_WIDTH{1'b0}};

  end
endgenerate


reg [FW_NUM_FC*PROT_SIZE_WIDTH-1:0] prot_size_r;
reg [FW_NUM_FC*PROT_SIZE_WIDTH-1:0] prot_size_int;


always @* begin: PROT_SIZE_FORMATTING
  integer i;
  prot_size_int = fw_prot_size_i;
  for (i=0; i<FW_NUM_FC; i=i+1) begin
    if (FC_PE_LVL_EXT[(i+1)*2-1-:2]==2'h2) begin
      if (fw_prot_size_i[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] > FC_MXRS_EXT[i*7 +: 7]) begin
        prot_size_int[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] = {1'b0, FC_MXRS_EXT[i*7 +: 7]};
      end
      else if (fw_prot_size_i[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] == {PROT_SIZE_WIDTH{1'b0}}) begin
        prot_size_int[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] = {PROT_SIZE_WIDTH{1'b0}};
      end
      else if (fw_prot_size_i[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] < (FC_MNRS_EXT[i*7 +: 7]+5)) begin
        prot_size_int[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] = {1'b0, (FC_MNRS_EXT[i*7 +: 7]+7'h5)};
      end
    end else if (FC_PE_LVL_EXT[(i+1)*2-1-:2]==2'h1) begin 
      prot_size_int[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] = {1'b0, FC_MXRS_EXT[i*7 +: 7]};
    end else if (FC_PE_LVL_EXT[(i+1)*2-1-:2]==2'h0) begin 
      prot_size_int[i*PROT_SIZE_WIDTH +: PROT_SIZE_WIDTH] = {PROT_SIZE_WIDTH{1'b0}};
    end
  end
end

always @(posedge clk) begin: PROT_SIZE_REG
  if (lpi_prot_size_sample_i) begin
    prot_size_r <= prot_size_int;
  end
end

assign fw_prot_size_o = prot_size_r;


wire [FW_TMP_TA_WIDTH-1:0]              fw_tmp_ta_int  ;
wire [FC_MST_ID_WIDTH-1:0]              fw_tmp_mid_int ;
wire [1:0]                 prot_sel;
wire [FC_MST_ID_WIDTH-1:0] mmusid_sel;
wire [FW_TMP_TA_WIDTH-1:0] addr_sel;

wire tamper_event;
wire tamper_overflow;
wire tamper_ack;
wire tamper_update;
wire tamper_report_valid;

wire fw_tmp_tp_tmp_stream_sec_int;
wire fw_tmp_tp_priv_int;
wire fw_tmp_tp_ns_int;
wire fw_tmp_ctrl_tr_vld_int;
wire fw_tmp_ctrl_tr_overflw_int;

wire dp_two_tamp;


assign dp_two_tamp = 1'b0;

assign prot_sel   = tamper_cfg ? (tamper_cfg_w ? awprot_i[1:0] : arprot_i[1:0]) :
  dp_write_tamp_i ?
  awprot_i[1:0] : arprot_i[1:0];
assign mmusid_sel = tamper_cfg ? (tamper_cfg_w ? awmmusid_i : armmusid_i) :
  dp_write_tamp_i ?
  awmmusid_i : armmusid_i;
assign addr_sel   = tamper_cfg ? (tamper_cfg_w ? awaddr_i[20:2] : araddr_i[20:2]) :
  dp_write_tamp_i ?
  awaddr_i[20:2] : araddr_i[20:2];

assign tamper_event = tamper_cfg;

assign tamper_report_valid = fw_tmp_ctrl_tr_vld_int;

assign tamper_ack = fw_tmp_ctrl_en & fw_tmp_ctrl_i[0];

assign tamper_overflow = tamper_event & ((tamper_report_valid & !tamper_ack) |
  (dp_two_tamp));

assign tamper_update = tamper_event & (!tamper_overflow |
  (tamper_overflow & tamper_report_valid & tamper_ack) |
  (tamper_overflow & dp_two_tamp & !tamper_report_valid ) );


generate
  if (FW_LDE_LVL > 0) begin : LDE_FW_TMP_TA

    reg [FW_TMP_TA_WIDTH-1:0] fw_tmp_ta_r;

    always @(posedge clk)
    begin: REG_FW_TMP_TA
      if (tamper_update) begin
        fw_tmp_ta_r <= addr_sel;
      end
    end

    assign fw_tmp_ta_int = fw_tmp_ta_r;

  end
  else begin: NO_LDE_FW_TMP_TA
    assign fw_tmp_ta_int = {FW_TMP_TA_WIDTH{1'b0}};
  end
endgenerate

assign fw_tmp_ta_o = tamper_report_valid ?
  fw_tmp_ta_int : {FW_TMP_TA_WIDTH{1'b0}};


generate
  if (FW_LDE_LVL > 0 && FW_SE_LVL == 2) begin : FW_TMP_TP_STREAM_SEC

    reg fw_tmp_tp_tmp_stream_sec_r;

    always @(posedge clk)
    begin: REG_FW_TMP_TP_STREAM_SEC
      if (tamper_update) begin
        fw_tmp_tp_tmp_stream_sec_r <= 1'b0;
      end
    end

    assign fw_tmp_tp_tmp_stream_sec_int = fw_tmp_tp_tmp_stream_sec_r;

  end
  else begin: FW_TMP_TP_NO_STREAM_SEC
    assign fw_tmp_tp_tmp_stream_sec_int = 1'b0;
  end
endgenerate

generate
  if (FW_LDE_LVL > 0 && FC_PRIV_SPT == 1) begin : FW_TMP_TP_PRIV

    reg fw_tmp_tp_priv_r;

    always @(posedge clk)
    begin: REG_FW_TMP_TP_PRIV
      if (tamper_update) begin
        fw_tmp_tp_priv_r <= prot_sel[0];
      end
    end

  assign fw_tmp_tp_priv_int = fw_tmp_tp_priv_r;

  end
  else begin: FW_TMP_TP_NO_PRIV
    assign fw_tmp_tp_priv_int = 1'b0;
  end
endgenerate

generate
  if (FW_LDE_LVL > 0 && FW_SE_LVL > 0) begin : FW_TMP_TP_NS

    reg fw_tmp_tp_ns_r;

    always @(posedge clk)
    begin: REG_FW_TMP_TP_NS
      if (tamper_update) begin
        fw_tmp_tp_ns_r <= prot_sel[1];
      end
    end

  assign fw_tmp_tp_ns_int = fw_tmp_tp_ns_r;

  end
  else begin: FW_TMP_TP_NO_NS
    assign fw_tmp_tp_ns_int = 1'b1;
  end
endgenerate

assign fw_tmp_tp_o = tamper_report_valid ? {fw_tmp_tp_tmp_stream_sec_int,
  fw_tmp_tp_priv_int, fw_tmp_tp_ns_int} : {FW_TMP_TP_WIDTH{1'b0}};


generate
  if (FW_LDE_LVL > 0 && FC_SINGLE_MST == 0) begin : FW_TMP_MID

    reg [FC_MST_ID_WIDTH-1:0] fw_tmp_mid_r;

    always @(posedge clk)
    begin: REG_FW_TMP_MID
      if (tamper_update) begin
        fw_tmp_mid_r <= mmusid_sel;
      end
    end

    assign fw_tmp_mid_int = fw_tmp_mid_r;

  end
  else begin: FW_TMP_NO_MID
    assign fw_tmp_mid_int = CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0];
  end
endgenerate

assign fw_tmp_mid_o = tamper_report_valid ? fw_tmp_mid_int :
  {FC_MST_ID_WIDTH{1'b0}};


generate
  if (FW_LDE_LVL > 0) begin : FW_TMP_CTRL_LDE

    reg fw_tmp_ctrl_tr_vld_r;
    reg fw_tmp_ctrl_tr_overflw_r;

    always @(posedge clk or negedge reset_n)
    begin: REG_FW_TMP_CTRL
      if (!reset_n) begin
        fw_tmp_ctrl_tr_vld_r     <= 1'b0;
        fw_tmp_ctrl_tr_overflw_r <= 1'b0;
      end else begin
        if (default_state_i) begin
          fw_tmp_ctrl_tr_vld_r     <= 1'b0;
        end
        else if (tamper_event | tamper_ack) begin
          fw_tmp_ctrl_tr_vld_r <= tamper_event ? 1'b1 : !tamper_ack;
        end

        if (default_state_i) begin
          fw_tmp_ctrl_tr_overflw_r <= 1'b0;
        end
        else if (tamper_overflow | tamper_ack) begin
          fw_tmp_ctrl_tr_overflw_r <= tamper_overflow ? 1'b1 : !tamper_ack;
        end

      end
    end

    assign fw_tmp_ctrl_tr_vld_int = fw_tmp_ctrl_tr_vld_r;
    assign fw_tmp_ctrl_tr_overflw_int = fw_tmp_ctrl_tr_overflw_r;

  end
  else begin: FW_TMP_CTRL_NO_LDE
    assign fw_tmp_ctrl_tr_vld_int = 1'b0;
    assign fw_tmp_ctrl_tr_overflw_int = 1'b0;
  end
endgenerate

assign fw_tmp_ctrl_o = {fw_tmp_ctrl_tr_vld_int, fw_tmp_ctrl_tr_overflw_int,
  1'b0};

assign fw_tamper_irq = fw_tmp_ctrl_tr_vld_int;


wire [3:0] aidr_major_rev;
wire [3:0] aidr_minor_rev;
wire [3:0] pid2_revision;
wire [3:0] pid3_revand;

assign fw_pid0_o = 8'h75;
assign fw_pid1_o = 8'hB0;
assign fw_pid2_o = {4'b0000, 4'hB}; 
assign fw_pid3_o = {pid3_revand, 4'h0};   
assign fw_pid4_o = 8'h04;

assign fw_cid0_o = 8'h0D;
assign fw_cid1_o = 8'hF0;
assign fw_cid2_o = 8'h05;
assign fw_cid3_o = 8'hB1;

firewall_f0_ecorevnum #(.WIDTH(4),
  .ECOREVVAL(4'b0001))
u_ecorevnum_pid3_revand (.ecorevnum(pid3_revand)
 );

assign aidr_o = {4'b0000, 4'b0000};

wire [11:0] product_id;
assign product_id = {fw_pid1_o[3:0], fw_pid0_o};

wire [3:0] variant;
assign variant = fw_pid2_o[7:4];

wire [3:0] revision;
assign revision = fw_pid3_o[7:4];  

wire [11:0] implementer;
assign implementer = 12'h43B;

assign iidr_o = {product_id, variant, revision, implementer};


generate
  if (FC_MXRS <= (FC_MNRS + 5)) begin: BASE_UPR_ADDR_FC_PE_LVL_0 

    assign fctlr_base_addr_o = {FC_NUM_RGN*FC_MXRS{1'b0}};
    assign fctlr_upr_addr_o  = {FC_NUM_RGN*FC_MXRS{1'b0}};

  end else if (FC_PE_LVL == 1) begin: BASE_UPR_ADDR_FC_PE_LVL_1 


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: LWR_ADDR_OUTPUT_VALUE
      if (i<4) begin : LWR_ADDR_FIXED_OUTPUT_VALUE
        assign fctlr_base_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FIXED_LWR_ADDR[i*32+:FC_MXRS];
      end else begin : LWR_ADDR_NON_FIXED_OUTPUT_VALUE
        assign fctlr_base_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS];
      end
    end

    wire [FC_NUM_RGN*FC_MXRS-1:0] curr_rgn_size;

    for (i=0; i<FC_NUM_RGN; i=i+1) begin: UPPR_ADDR_PE_LVL_1_UPR_ADDR
      for (j=0; j<FC_MXRS; j=j+1) begin: UPPR_ADDR_PE_LVL_1_CURRENT_RGN
        if (j < FC_RGN_SIZE[(i+1)*8-1-:8]) begin: UPPR_ADDR_PE_LVL_1_ADD
          assign curr_rgn_size[i*FC_MXRS + j] = 1'b1;
        end else begin: UPPR_ADDR_PE_LVL_1_DO_NOT_ADD
          assign curr_rgn_size[i*FC_MXRS + j] = 1'b0;
        end
      end
    end

    for (i=0; i<FC_NUM_RGN; i=i+1) begin: UPR_ADDR_OUTPUT_VALUE
      if (i<4) begin : UPR_ADDR_FIXED_OUTPUT_VALUE
        assign fctlr_upr_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FIXED_UPR_ADDR[i*32+:FC_MXRS];
      end else if ((FC_RSE_LVL == 1) && (FC_RGN_MULNPO2[i])) begin: UPR_ADDR_FROM_PARAM

        assign fctlr_upr_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS];

      end else begin: UPR_ADDR_SUM

        assign fctlr_upr_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS] + curr_rgn_size[(i+1)*FC_MXRS-1-:FC_MXRS];

      end
    end
  end
endgenerate


assign fctlr_rb_lpi_discon_deny_o = (pe_st_o[4] && fe_ctrl_o[4]);


reg [PE_ST_WIDTH-1:0] pe_st_reg;
reg [ME_ST_WIDTH-1:0] me_st_reg;
reg [FW_ST_WIDTH-1:0] fw_st_reg;
reg [FW_NUM_FC-1:0]   comp_pwr_st_reg;

assign ctrl_st_xfer_req = 1'b0;
assign status_enable = arvalid_i ||
                     awvalid_i ||
                     rvalid_i  ||
                     wvalid_i  ||
                     bvalid_i;


always @(posedge clk or negedge reset_n) begin: UPDATE_STATUS_REGS
  if (!reset_n) begin
    pe_st_reg       <= PE_CTRL_RST_VAL;
    rgn_st_reg      <= {FC_NUM_RGN*RGN_ST_WIDTH{1'b0}};
    me_st_reg       <= {ME_ST_WIDTH{1'b0}};
    fw_st_reg       <= {1'b0, 1'b1};
    comp_pwr_st_reg <= {FW_NUM_FC{1'b0}};
  end else begin
    if (default_state_i) begin
      pe_st_reg       <= PE_CTRL_RST_VAL;
      rgn_st_reg      <= {FC_NUM_RGN*RGN_ST_WIDTH{1'b0}};
      me_st_reg       <= {ME_ST_WIDTH{1'b0}};
      fw_st_reg       <= {1'b0, 1'b1};
      comp_pwr_st_reg <= {FW_NUM_FC{1'b0}};
    end
    else if (!status_enable) begin
      pe_st_reg       <= pe_ctrl_o;
      rgn_st_reg      <= rgn_st_int;
      me_st_reg       <= me_ctrl_o;
      fw_st_reg       <= fw_ctrl_o;
      comp_pwr_st_reg <= comp_pwr_st_r;
    end
  end
end

assign pe_st_o      = pe_st_reg;
assign rgn_st_o     = rgn_st_reg;
assign rgn_st_rgn_o = rgn_st_curr_rgn;
assign me_st_o      = me_st_reg;
assign fw_st_o      = fw_st_reg;
assign comp_pwr_st_o = comp_pwr_st_reg;

endmodule
