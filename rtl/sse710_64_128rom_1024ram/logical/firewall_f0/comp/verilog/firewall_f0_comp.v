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

module firewall_f0_comp #(
    `include "firewall_f0_comp_params.vh"
    ,
    `include "firewall_f0_reg_width_params.vh"
) (
    input  wire                                   clk         ,
    input  wire                                   reset_n     ,

    input  wire [FC_AXIID_WIDTH-1:0]              arid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               araddr_s_i  ,
    input  wire [7:0]                             arlen_s_i   ,
    input  wire [2:0]                             arsize_s_i  ,
    input  wire [1:0]                             arburst_s_i ,
    input  wire                                   arlock_s_i  ,
    input  wire [3:0]                             arcache_s_i ,
    input  wire [2:0]                             arprot_s_i  ,
    input  wire [3:0]                             arqos_s_i   ,
    input  wire [3:0]                             arregion_s_i,
    input  wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_s_i  ,
    input  wire                                   arvalid_s_i ,
    output wire                                   arready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_s_i,

    input  wire [FC_AXIID_WIDTH-1:0]              awid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               awaddr_s_i  ,
    input  wire [7:0]                             awlen_s_i   ,
    input  wire [2:0]                             awsize_s_i  ,
    input  wire [1:0]                             awburst_s_i ,
    input  wire                                   awlock_s_i  ,
    input  wire [3:0]                             awcache_s_i ,
    input  wire [2:0]                             awprot_s_i  ,
    input  wire [3:0]                             awqos_s_i   ,
    input  wire [3:0]                             awregion_s_i,
    input  wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_s_i  ,
    input  wire                                   awvalid_s_i ,
    output wire                                   awready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output wire                                   wready_s_o  ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_s_o     ,
    output wire [1:0]                             bresp_s_o   ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]          buser_s_o   ,
    output wire                                   bvalid_s_o  ,
    input  wire                                   bready_s_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              rid_s_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]            rdata_s_o   ,
    output wire [1:0]                             rresp_s_o   ,
    output wire                                   rlast_s_o   ,
    output wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_s_o   ,
    output wire                                   rvalid_s_o  ,
    input  wire                                   rready_s_i  ,

    input  wire                                   awakeup_s_i ,

    output wire [FC_AXIID_WIDTH-1:0]              arid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               araddr_m_o  ,
    output wire [7:0]                             arlen_m_o   ,
    output wire [2:0]                             arsize_m_o  ,
    output wire [1:0]                             arburst_m_o ,
    output wire                                   arlock_m_o  ,
    output wire [3:0]                             arcache_m_o ,
    output wire [2:0]                             arprot_m_o  ,
    output wire [3:0]                             arqos_m_o   ,
    output wire [3:0]                             arregion_m_o,
    output wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_m_o  ,
    output wire                                   arvalid_m_o ,
    input  wire                                   arready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             armmusid_m_o,

    output wire [FC_AXIID_WIDTH-1:0]              awid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               awaddr_m_o  ,
    output wire [7:0]                             awlen_m_o   ,
    output wire [2:0]                             awsize_m_o  ,
    output wire [1:0]                             awburst_m_o ,
    output wire                                   awlock_m_o  ,
    output wire [3:0]                             awcache_m_o ,
    output wire [2:0]                             awprot_m_o  ,
    output wire [3:0]                             awqos_m_o   ,
    output wire [3:0]                             awregion_m_o,
    output wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_m_o  ,
    output wire                                   awvalid_m_o ,
    input  wire                                   awready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             awmmusid_m_o,

    output wire [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_m_o   ,
    output wire                                   wlast_m_o   ,
    output wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_m_o   ,
    output wire                                   wvalid_m_o  ,
    input  wire                                   wready_m_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]              bid_m_i     ,
    input  wire [1:0]                             bresp_m_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]          buser_m_i   ,
    input  wire                                   bvalid_m_i  ,
    output wire                                   bready_m_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]              rid_m_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]            rdata_m_i   ,
    input  wire [1:0]                             rresp_m_i   ,
    input  wire                                   rlast_m_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_m_i   ,
    input  wire                                   rvalid_m_i  ,
    output wire                                   rready_m_o  ,

    output wire                                   awakeup_m_o ,

    output wire                                   tvalid_ds_o ,
    input  wire                                   tready_ds_i ,
    output wire [FC_CFG_DATA_W-1:0]               tdata_ds_o  ,
    output wire [(FC_CFG_DATA_W/8)-1:0]           tkeep_ds_o  ,
    output wire                                   tlast_ds_o  ,
    output wire [LOG2_FW_NUM_FC-1:0]              tid_ds_o    ,
    output wire                                   twakeup_ds_o,

    input  wire                                   tvalid_us_i ,
    output wire                                   tready_us_o ,
    input  wire [FC_CFG_DATA_W-1:0]               tdata_us_i  ,
    input  wire [(FC_CFG_DATA_W/8)-1:0]           tkeep_us_i  ,
    input  wire                                   tlast_us_i  ,
    input  wire [LOG2_FW_NUM_FC-1:0]              tdest_us_i  ,
    input  wire                                   twakeup_us_i,

    input  wire                                   clk_qreqn_i   ,
    output wire                                   clk_qacceptn_o,
    output wire                                   clk_qdeny_o   ,
    output wire                                   clk_qactive_o ,

    input  wire                                   pwr_qreqn_i   ,
    output wire                                   pwr_qacceptn_o,
    output wire                                   pwr_qdeny_o   ,
    output wire                                   pwr_qactive_o ,

    input  wire                                   bypass_i      ,

    input  wire                                   dftcgen
);


`include "firewall_f0_comp_localparams.vh"
`include "firewall_f0_msg_prot_types.vh"


wire [FC_AXIID_WIDTH-1:0]               arid_m_wire;
wire [FC_ADDR_WIDTH-1:0]                araddr_m_wire;
wire [7:0]                              arlen_m_wire;
wire [2:0]                              arsize_m_wire;
wire [1:0]                              arburst_m_wire;
wire                                    arlock_m_wire;
wire [3:0]                              arcache_m_wire;
wire [2:0]                              arprot_m_wire;
wire [3:0]                              arqos_m_wire;
wire [3:0]                              arregion_m_wire;
wire [FC_AXIUSER_AR_WIDTH-1:0]          aruser_m_wire;
wire                                    arvalid_m_wire;
wire                                    arready_m_wire;
wire [FC_MST_ID_WIDTH-1:0]              armmusid_m_wire;

wire [FC_AXIID_WIDTH-1:0]               awid_m_wire;
wire [FC_ADDR_WIDTH-1:0]                awaddr_m_wire;
wire [7:0]                              awlen_m_wire;
wire [2:0]                              awsize_m_wire;
wire [1:0]                              awburst_m_wire;
wire                                    awlock_m_wire;
wire [3:0]                              awcache_m_wire;
wire [2:0]                              awprot_m_wire;
wire [3:0]                              awqos_m_wire;
wire [3:0]                              awregion_m_wire;
wire [FC_AXIUSER_AW_WIDTH-1:0]          awuser_m_wire;
wire                                    awvalid_m_wire;
wire                                    awready_m_wire;
wire [FC_MST_ID_WIDTH-1:0]              awmmusid_m_wire;

wire [FC_AXIDATA_WIDTH-1:0]             wdata_m_wire;
wire [FC_AXIDATA_WIDTH/8-1:0]           wstrb_m_wire;
wire                                    wlast_m_wire;
wire [FC_AXIUSER_W_WIDTH-1:0]           wuser_m_wire;
wire                                    wvalid_m_wire;
wire                                    wready_m_wire;

wire [FC_AXIID_WIDTH-1:0]               bid_m_wire;
wire [1:0]                              bresp_m_wire;
wire [FC_AXIUSER_B_WIDTH-1:0]           buser_m_wire;
wire                                    bvalid_m_wire;
wire                                    bready_m_wire;

wire [FC_AXIID_WIDTH-1:0]               rid_m_wire;
wire [FC_AXIDATA_WIDTH-1:0]             rdata_m_wire;
wire [1:0]                              rresp_m_wire;
wire                                    rlast_m_wire;
wire [FC_AXIUSER_R_WIDTH-1:0]           ruser_m_wire;
wire                                    rvalid_m_wire;
wire                                    rready_m_wire;

wire                                    awakeup_m_wire;

wire                                    lpi_gate_hold_req_wire;
wire                                    gate_hold_ack_wire;
wire                                    gate_busy_wire;
wire                                    axi_slc_busy_s_wire;

wire                                    tracker_al_empty_rd_wire;
wire                                    tracker_al_empty_wr_wire;
wire                                    tracker_empty_rd_wire;
wire                                    tracker_empty_wr_wire;
wire [FC_AXIID_WIDTH-1:0]               tracker_id_rd_ch_wire;
wire [FC_AXIID_WIDTH-1:0]               tracker_id_wr_ch_wire;
wire                                    tracker_read_rd_ch_wire;
wire                                    tracker_read_wr_ch_wire;
wire [TRACKER_PAYLOAD_WIDTH_AR-1:0]     tracker_dout_rd_ch_wire;
wire [TRACKER_PAYLOAD_WIDTH_AW-1:0]     tracker_dout_wr_ch_wire;

wire [1:0]                              cfg_lpi_con_req_wire;
wire                                    cfg_lpi_discon_req_wire;
wire                                    cfg_lpi_clk_hold_wire;
wire                                    cfg_lpi_pwr_accept_wire;
wire                                    cfg_lpi_busy_wire;

wire                                    cfg_gate_bas_wire;

wire [IRQ_TYPE_WIDTH-1:0]               cfg_irq_req_wire;
wire                                    cfg_irq_valid_wire;

wire [PE_CTRL_WIDTH-1:0]                cfg_pe_ctrl_i_wire;
wire                                    cfg_pe_ctrl_en_wire;
wire [PE_CTRL_WIDTH-1:0]                cfg_pe_ctrl_o_wire;

wire [PE_ST_WIDTH-1:0]                  cfg_pe_st_i_wire;

wire [RWE_CTRL_WIDTH-1:0]               cfg_rwe_ctrl_i_wire;
wire                                    cfg_rwe_ctrl_en_wire;
wire [RWE_CTRL_WIDTH-1:0]               cfg_rwe_ctrl_o_wire;

wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] cfg_rgn_ctrl0_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_ctrl0_en_wire;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] cfg_rgn_ctrl0_o_wire;
wire [RGN_CTRL0_WIDTH-1:0]              cfg_rgn_ctrl0_rgn_i_wire;

wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] cfg_rgn_ctrl1_i_wire;
wire [RGN_CTRL1_WIDTH-1:0]              cfg_rgn_ctrl1_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_ctrl1_en_wire;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] cfg_rgn_ctrl1_o_wire;

wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] cfg_rgn_lctrl_i_wire;
wire [RGN_LCTRL_WIDTH-1:0]              cfg_rgn_lctrl_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_lctrl_en_wire;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] cfg_rgn_lctrl_o_wire;

wire [(FC_NUM_RGN*RGN_ST_WIDTH)-1:0]    cfg_rgn_st_i_wire;
wire [RGN_ST_WIDTH-1:0]                 cfg_rgn_st_rgn_i_wire;

wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]  cfg_rgn_cfg0_i_wire;
wire [RGN_CFG0_WIDTH-1:0]               cfg_rgn_cfg0_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_cfg0_en_wire;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]  cfg_rgn_cfg0_o_wire;

wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]  cfg_rgn_cfg1_i_wire;
wire [RGN_CFG1_WIDTH-1:0]               cfg_rgn_cfg1_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_cfg1_en_wire;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]  cfg_rgn_cfg1_o_wire;

wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  cfg_rgn_size_i_wire;
wire [RGN_SIZE_WIDTH-1:0]               cfg_rgn_size_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_size_en_wire;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  cfg_rgn_size_o_wire;

wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] cfg_rgn_tcfg0_i_wire;
wire [RGN_TCFG0_WIDTH-1:0]              cfg_rgn_tcfg0_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg0_en_wire;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] cfg_rgn_tcfg0_o_wire;

wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] cfg_rgn_tcfg1_i_wire;
wire [RGN_TCFG1_WIDTH-1:0]              cfg_rgn_tcfg1_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg1_en_wire;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] cfg_rgn_tcfg1_o_wire;

wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] cfg_rgn_tcfg2_i_wire;
wire [RGN_TCFG2_WIDTH-1:0]              cfg_rgn_tcfg2_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg2_en_wire;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] cfg_rgn_tcfg2_o_wire;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid0_i_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid0_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid0_en_wire;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid0_o_wire;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid1_i_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid1_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid1_en_wire;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid1_o_wire;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid2_i_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid2_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid2_en_wire;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid2_o_wire;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid3_i_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid3_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid3_en_wire;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid3_o_wire;

wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  cfg_rgn_mpl0_i_wire;
wire [RGN_MPL0_WIDTH-1:0]               cfg_rgn_mpl0_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl0_en_wire;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  cfg_rgn_mpl0_o_wire;

wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  cfg_rgn_mpl1_i_wire;
wire [RGN_MPL1_WIDTH-1:0]               cfg_rgn_mpl1_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl1_en_wire;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  cfg_rgn_mpl1_o_wire;

wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  cfg_rgn_mpl2_i_wire;
wire [RGN_MPL2_WIDTH-1:0]               cfg_rgn_mpl2_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl2_en_wire;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  cfg_rgn_mpl2_o_wire;

wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  cfg_rgn_mpl3_i_wire;
wire [RGN_MPL3_WIDTH-1:0]               cfg_rgn_mpl3_rgn_i_wire;
wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl3_en_wire;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  cfg_rgn_mpl3_o_wire;

wire [FE_TAL_WIDTH-1:0]                 cfg_fe_tal_i_wire;

wire [FE_TAU_WIDTH-1:0]                 cfg_fe_tau_i_wire;

wire [FE_TP_WIDTH-1:0]                  cfg_fe_tp_i_wire;

wire [FC_MST_ID_WIDTH-1:0]              cfg_fe_mid_i_wire;

wire [FE_CTRL_WIDTH-1:0]                cfg_fe_ctrl_i_wire;
wire                                    cfg_fe_ctrl_en_wire;
wire [FE_CTRL_WIDTH-1:0]                cfg_fe_ctrl_o_wire;

wire [ME_CTRL_WIDTH-1:0]                cfg_me_ctrl_i_wire;
wire                                    cfg_me_ctrl_en_wire;
wire [ME_CTRL_WIDTH-1:0]                cfg_me_ctrl_o_wire;

wire [ME_ST_WIDTH-1:0]                  cfg_me_st_i_wire;
wire                                    cfg_me_st_en_wire;
wire [ME_ST_WIDTH-1:0]                  cfg_me_st_o_wire;

wire [EDR_TAL_WIDTH-1:0]                cfg_edr_tal_i_wire;
wire                                    cfg_edr_tal_en_wire;
wire [EDR_TAL_WIDTH-1:0]                cfg_edr_tal_o_wire;

wire [EDR_TAU_WIDTH-1:0]                cfg_edr_tau_i_wire;
wire                                    cfg_edr_tau_en_wire;
wire [EDR_TAU_WIDTH-1:0]                cfg_edr_tau_o_wire;

wire [EDR_TP_WIDTH-1:0]                 cfg_edr_tp_i_wire;
wire                                    cfg_edr_tp_en_wire;
wire [EDR_TP_WIDTH-1:0]                 cfg_edr_tp_o_wire;

wire [FC_MST_ID_WIDTH-1:0]              cfg_edr_mid_i_wire;
wire                                    cfg_edr_mid_en_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_edr_mid_o_wire;

wire [EDR_CTRL_WIDTH-1:0]               cfg_edr_ctrl_i_wire;
wire                                    cfg_edr_ctrl_en_wire;
wire [EDR_CTRL_WIDTH-1:0]               cfg_edr_ctrl_o_wire;

wire [LD_CTRL_WIDTH-1:0]                cfg_ld_ctrl_i_wire;
wire                                    cfg_ld_ctrl_en_wire;
wire [LD_CTRL_WIDTH-1:0]                cfg_ld_ctrl_o_wire;

wire [PROT_SIZE_WIDTH-1:0]              cfg_prot_size_i_wire;
wire                                    cfg_prot_size_en_wire;
wire [PROT_SIZE_WIDTH-1:0]              cfg_prot_size_o_wire;

wire [PE_BPS_WIDTH-1:0]                 cfg_bypass_i_wire;
wire                                    cfg_bypass_en_wire;
wire [BYPASS_WIDTH-1:0]                 cfg_bypass_o_wire;

wire [FC_MST_ID_WIDTH-1:0]              cfg_mmusid_o_wire;

wire                                    rb_pwr_deny_wire;

wire [FE_TAL_WIDTH-1:0]                 cfg_fe_tal_rd_o_wire;
wire [FE_TAU_WIDTH-1:0]                 cfg_fe_tau_rd_o_wire;
wire [FE_TP_WIDTH-1:0]                  cfg_fe_tp_rd_o_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_fe_mid_rd_o_wire;
wire                                    cfg_fe_rd_en_wire;
wire                                    cfg_fe_type_rd_o_wire;

wire [FE_TAL_WIDTH-1:0]                 cfg_fe_tal_wr_o_wire;
wire [FE_TAU_WIDTH-1:0]                 cfg_fe_tau_wr_o_wire;
wire [FE_TP_WIDTH-1:0]                  cfg_fe_tp_wr_o_wire;
wire [FC_MST_ID_WIDTH-1:0]              cfg_fe_mid_wr_o_wire;
wire                                    cfg_fe_wr_en_wire;
wire                                    cfg_fe_type_wr_o_wire;
wire [FC_NUM_RGN*FC_MXRS-1:0]           cfg_rb_base_addr_wire;
wire [FC_NUM_RGN*FC_MXRS-1:0]           cfg_rb_upr_addr_wire;

wire                                    default_state_wire;

wire [FC_AXIID_WIDTH-1:0]               s_regslc_arid_o;
wire [FC_ADDR_WIDTH-1:0]                s_regslc_araddr_o;
wire [7:0]                              s_regslc_arlen_o;
wire [2:0]                              s_regslc_arsize_o;
wire [1:0]                              s_regslc_arburst_o;
wire                                    s_regslc_arlock_o;
wire [3:0]                              s_regslc_arcache_o;
wire [2:0]                              s_regslc_arprot_o;
wire [3:0]                              s_regslc_arqos_o;
wire [3:0]                              s_regslc_arregion_o;
wire [FC_AXIUSER_AR_WIDTH-1:0]          s_regslc_aruser_o;
wire                                    s_regslc_arvalid_o;
wire                                    s_regslc_arready_i;
wire [FC_MST_ID_WIDTH-1:0]              s_regslc_armmusid_o;
wire [FC_AXIID_WIDTH-1:0]               s_regslc_awid_o;
wire [FC_ADDR_WIDTH-1:0]                s_regslc_awaddr_o;
wire [7:0]                              s_regslc_awlen_o;
wire [2:0]                              s_regslc_awsize_o;
wire [1:0]                              s_regslc_awburst_o;
wire                                    s_regslc_awlock_o;
wire [3:0]                              s_regslc_awcache_o;
wire [2:0]                              s_regslc_awprot_o;
wire [3:0]                              s_regslc_awqos_o;
wire [3:0]                              s_regslc_awregion_o;
wire [FC_AXIUSER_AW_WIDTH-1:0]          s_regslc_awuser_o;
wire                                    s_regslc_awvalid_o;
wire                                    s_regslc_awready_i;
wire [FC_MST_ID_WIDTH-1:0]              s_regslc_awmmusid_o;
wire [FC_AXIDATA_WIDTH-1:0]             s_regslc_wdata_o;
wire [FC_AXIDATA_WIDTH/8-1:0]           s_regslc_wstrb_o;
wire                                    s_regslc_wlast_o;
wire [FC_AXIUSER_W_WIDTH-1:0]           s_regslc_wuser_o;
wire                                    s_regslc_wvalid_o;
wire                                    s_regslc_wready_i;
wire [FC_AXIID_WIDTH-1:0]               s_regslc_bid_i;
wire [1:0]                              s_regslc_bresp_i;
wire [FC_AXIUSER_B_WIDTH-1:0]           s_regslc_buser_i;
wire                                    s_regslc_bvalid_i;
wire                                    s_regslc_bready_o;
wire [FC_AXIID_WIDTH-1:0]               s_regslc_rid_i;
wire [FC_AXIDATA_WIDTH-1:0]             s_regslc_rdata_i;
wire [1:0]                              s_regslc_rresp_i;
wire                                    s_regslc_rlast_i;
wire [FC_AXIUSER_R_WIDTH-1:0]           s_regslc_ruser_i;
wire                                    s_regslc_rvalid_i;
wire                                    s_regslc_rready_o;
wire                                    s_regslc_awakeup_o;

wire [FC_AXIID_WIDTH-1:0]               m_regslc_arid_i;
wire [FC_ADDR_WIDTH-1:0]                m_regslc_araddr_i;
wire [7:0]                              m_regslc_arlen_i;
wire [2:0]                              m_regslc_arsize_i;
wire [1:0]                              m_regslc_arburst_i;
wire                                    m_regslc_arlock_i;
wire [3:0]                              m_regslc_arcache_i;
wire [2:0]                              m_regslc_arprot_i;
wire [3:0]                              m_regslc_arqos_i;
wire [3:0]                              m_regslc_arregion_i;
wire [FC_AXIUSER_AR_WIDTH-1:0]          m_regslc_aruser_i;
wire                                    m_regslc_arvalid_i;
wire                                    m_regslc_arready_o;
wire [FC_MST_ID_WIDTH-1:0]              m_regslc_armmusid_i;

wire [FC_AXIID_WIDTH-1:0]               m_regslc_awid_i;
wire [FC_ADDR_WIDTH-1:0]                m_regslc_awaddr_i;
wire [7:0]                              m_regslc_awlen_i;
wire [2:0]                              m_regslc_awsize_i;
wire [1:0]                              m_regslc_awburst_i;
wire                                    m_regslc_awlock_i;
wire [3:0]                              m_regslc_awcache_i;
wire [2:0]                              m_regslc_awprot_i;
wire [3:0]                              m_regslc_awqos_i;
wire [3:0]                              m_regslc_awregion_i;
wire [FC_AXIUSER_AW_WIDTH-1:0]          m_regslc_awuser_i;
wire                                    m_regslc_awvalid_i;
wire                                    m_regslc_awready_o;
wire [FC_MST_ID_WIDTH-1:0]              m_regslc_awmmusid_i;

wire [FC_AXIDATA_WIDTH-1:0]             m_regslc_wdata_i;
wire [FC_AXIDATA_WIDTH/8-1:0]           m_regslc_wstrb_i;
wire                                    m_regslc_wlast_i;
wire [FC_AXIUSER_W_WIDTH-1:0]           m_regslc_wuser_i;
wire                                    m_regslc_wvalid_i;
wire                                    m_regslc_wready_o;

wire [FC_AXIID_WIDTH-1:0]               m_regslc_bid_o;
wire [1:0]                              m_regslc_bresp_o;
wire [FC_AXIUSER_B_WIDTH-1:0]           m_regslc_buser_o;
wire                                    m_regslc_bvalid_o;
wire                                    m_regslc_bready_i;

wire [FC_AXIID_WIDTH-1:0]               m_regslc_rid_o;
wire [FC_AXIDATA_WIDTH-1:0]             m_regslc_rdata_o;
wire [1:0]                              m_regslc_rresp_o;
wire                                    m_regslc_rlast_o;
wire [FC_AXIUSER_R_WIDTH-1:0]           m_regslc_ruser_o;
wire                                    m_regslc_rvalid_o;
wire                                    m_regslc_rready_i;

wire                                    m_regslc_awakeup_i;

wire                                    rd_edr_wen;
wire [31:0]                             rd_edr_addr_lwr;
wire [31:0]                             rd_edr_addr_uppr;
wire [FC_MST_ID_WIDTH+4-1:0]            rd_edr_prop;
wire                                    wr_edr_wen;
wire [31:0]                             wr_edr_addr_lwr;
wire [31:0]                             wr_edr_addr_uppr;
wire [FC_MST_ID_WIDTH+4-1:0]            wr_edr_prop;
wire                                    tracker_dout_rd_ch_vld_wire;
wire                                    tracker_dout_wr_ch_vld_wire;

wire                                    tvalid_ds_int;
wire                                    tready_ds_int;
wire [FC_CFG_DATA_W-1:0]                tdata_ds_int;
wire [(FC_CFG_DATA_W/8)-1:0]            tkeep_ds_int;
wire                                    tlast_ds_int;
wire [LOG2_FW_NUM_FC-1:0]               tid_ds_int;
wire                                    twakeup_ds_int;
wire                                    tvalid_us_int;
wire                                    tready_us_int;
wire [FC_CFG_DATA_W-1:0]                tdata_us_int;
wire [(FC_CFG_DATA_W/8)-1:0]            tkeep_us_int;
wire                                    tlast_us_int;
wire [LOG2_FW_NUM_FC-1:0]               tdest_us_int;
wire                                    twakeup_us_int;
wire                                    bas_qactive;

wire                                    clk_gate_en;
wire                                    clk_gated;
wire                                    i_pwr_req;
wire                                    i_bps_req;
wire                                    int_qactive;
wire                                    i_qactive_0;
wire                                    i_qactive_1;
wire                                    i_qactive_2;

wire                                    bypass_syncd;
wire                                    clk_qreqn_syncd;
wire                                    pwr_qreqn_syncd;


firewall_f0_cdc_capt_sync u_bypass_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (bypass_i),
    .q       (bypass_syncd)
);

firewall_f0_cdc_capt_sync u_clkqreqn_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (clk_qreqn_i),
    .q       (clk_qreqn_syncd)
);

firewall_f0_cdc_capt_sync u_pwrqreqn_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (pwr_qreqn_i),
    .q       (pwr_qreqn_syncd)
);

firewall_f0_clock_gate u_comp_cg (
    .clk_in  (clk          ),
    .enable  (clk_gate_en  ),
    .clk_out (clk_gated    ),
    .dftcgen (dftcgen      )
);

firewall_f0_axi_reg_slc #(
    .AW_DIR             (FC_AW_REG_SLC_S    ),
    .W_DIR              (FC_W_REG_SLC_S     ),
    .B_DIR              (FC_B_REG_SLC_S     ),
    .AR_DIR             (FC_AR_REG_SLC_S    ),
    .R_DIR              (FC_R_REG_SLC_S     ),
    .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
    .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
    .FC_AXIUSER_AR_WIDTH(FC_AXIUSER_AR_WIDTH),
    .FC_AXIUSER_AW_WIDTH(FC_AXIUSER_AW_WIDTH),
    .FC_AXIUSER_W_WIDTH (FC_AXIUSER_W_WIDTH ),
    .FC_AXIUSER_B_WIDTH (FC_AXIUSER_B_WIDTH ),
    .FC_AXIUSER_R_WIDTH (FC_AXIUSER_R_WIDTH ),
    .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
    .FC_AXIDATA_WIDTH   (FC_AXIDATA_WIDTH   )
) u_regslice_s (
    .clk       (clk_gated   ),
    .reset_n   (reset_n     ),

    .arid_i    (arid_s_i    ),
    .araddr_i  (araddr_s_i  ),
    .arlen_i   (arlen_s_i   ),
    .arsize_i  (arsize_s_i  ),
    .arburst_i (arburst_s_i ),
    .arlock_i  (arlock_s_i  ),
    .arcache_i (arcache_s_i ),
    .arprot_i  (arprot_s_i  ),
    .arqos_i   (arqos_s_i   ),
    .arregion_i(arregion_s_i),
    .aruser_i  (aruser_s_i  ),
    .arvalid_i (arvalid_s_i ),
    .arready_o (arready_s_o ),
    .armmusid_i(armmusid_s_i),

    .awid_i    (awid_s_i    ),
    .awaddr_i  (awaddr_s_i  ),
    .awlen_i   (awlen_s_i   ),
    .awsize_i  (awsize_s_i  ),
    .awburst_i (awburst_s_i ),
    .awlock_i  (awlock_s_i  ),
    .awcache_i (awcache_s_i ),
    .awprot_i  (awprot_s_i  ),
    .awqos_i   (awqos_s_i   ),
    .awregion_i(awregion_s_i),
    .awuser_i  (awuser_s_i  ),
    .awvalid_i (awvalid_s_i ),
    .awready_o (awready_s_o ),
    .awmmusid_i(awmmusid_s_i),

    .wdata_i   (wdata_s_i ),
    .wstrb_i   (wstrb_s_i ),
    .wlast_i   (wlast_s_i ),
    .wuser_i   (wuser_s_i ),
    .wvalid_i  (wvalid_s_i),
    .wready_o  (wready_s_o),

    .bid_o     (bid_s_o   ),
    .bresp_o   (bresp_s_o ),
    .buser_o   (buser_s_o ),
    .bvalid_o  (bvalid_s_o),
    .bready_i  (bready_s_i),

    .rid_o     (rid_s_o   ),
    .rdata_o   (rdata_s_o ),
    .rresp_o   (rresp_s_o ),
    .rlast_o   (rlast_s_o ),
    .ruser_o   (ruser_s_o ),
    .rvalid_o  (rvalid_s_o),
    .rready_i  (rready_s_i),

    .awakeup_i (awakeup_s_i),

    .arid_o    (s_regslc_arid_o    ),
    .araddr_o  (s_regslc_araddr_o  ),
    .arlen_o   (s_regslc_arlen_o   ),
    .arsize_o  (s_regslc_arsize_o  ),
    .arburst_o (s_regslc_arburst_o ),
    .arlock_o  (s_regslc_arlock_o  ),
    .arcache_o (s_regslc_arcache_o ),
    .arprot_o  (s_regslc_arprot_o  ),
    .arqos_o   (s_regslc_arqos_o   ),
    .arregion_o(s_regslc_arregion_o),
    .aruser_o  (s_regslc_aruser_o  ),
    .arvalid_o (s_regslc_arvalid_o ),
    .arready_i (s_regslc_arready_i ),
    .armmusid_o(s_regslc_armmusid_o),

    .awid_o    (s_regslc_awid_o    ),
    .awaddr_o  (s_regslc_awaddr_o  ),
    .awlen_o   (s_regslc_awlen_o   ),
    .awsize_o  (s_regslc_awsize_o  ),
    .awburst_o (s_regslc_awburst_o ),
    .awlock_o  (s_regslc_awlock_o  ),
    .awcache_o (s_regslc_awcache_o ),
    .awprot_o  (s_regslc_awprot_o  ),
    .awqos_o   (s_regslc_awqos_o   ),
    .awregion_o(s_regslc_awregion_o),
    .awuser_o  (s_regslc_awuser_o  ),
    .awvalid_o (s_regslc_awvalid_o ),
    .awready_i (s_regslc_awready_i ),
    .awmmusid_o(s_regslc_awmmusid_o),

    .wdata_o   (s_regslc_wdata_o ),
    .wstrb_o   (s_regslc_wstrb_o ),
    .wlast_o   (s_regslc_wlast_o ),
    .wuser_o   (s_regslc_wuser_o ),
    .wvalid_o  (s_regslc_wvalid_o),
    .wready_i  (s_regslc_wready_i),

    .bid_i     (s_regslc_bid_i   ),
    .bresp_i   (s_regslc_bresp_i ),
    .buser_i   (s_regslc_buser_i ),
    .bvalid_i  (s_regslc_bvalid_i),
    .bready_o  (s_regslc_bready_o),

    .rid_i     (s_regslc_rid_i   ),
    .rdata_i   (s_regslc_rdata_i ),
    .rresp_i   (s_regslc_rresp_i ),
    .rlast_i   (s_regslc_rlast_i ),
    .ruser_i   (s_regslc_ruser_i ),
    .rvalid_i  (s_regslc_rvalid_i),
    .rready_o  (s_regslc_rready_o),

    .awakeup_o       (s_regslc_awakeup_o),
    .axi_slc_busy_o  (axi_slc_busy_s_wire),
    .gate_hold_req_i (lpi_gate_hold_req_wire)
);


firewall_f0_comp_gate #(
  .FC_SINGLE_MST            (FC_SINGLE_MST           ),
  .FC_ME_LVL                (FC_ME_LVL               ),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH           ),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH        ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH          ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH         ),
  .FC_NUM_READ_OS           (FC_NUM_READ_OS          ),
  .FC_NUM_WRITE_OS          (FC_NUM_WRITE_OS         ),
  .FC_AXIUSER_AR_WIDTH      (FC_AXIUSER_AR_WIDTH     ),
  .FC_AXIUSER_AW_WIDTH      (FC_AXIUSER_AW_WIDTH     ),
  .FC_AXIUSER_W_WIDTH       (FC_AXIUSER_W_WIDTH      ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH      ),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH      ),
  .TRACKER_PAYLOAD_WIDTH_AR (TRACKER_PAYLOAD_WIDTH_AR),
  .TRACKER_PAYLOAD_WIDTH_AW (TRACKER_PAYLOAD_WIDTH_AW)
)
u_comp_gate(
    .clk          (clk_gated    ),
    .reset_n      (reset_n      ),

    .arid_s_i     (s_regslc_arid_o    ),
    .araddr_s_i   (s_regslc_araddr_o  ),
    .arlen_s_i    (s_regslc_arlen_o   ),
    .arsize_s_i   (s_regslc_arsize_o  ),
    .arburst_s_i  (s_regslc_arburst_o ),
    .arlock_s_i   (s_regslc_arlock_o  ),
    .arcache_s_i  (s_regslc_arcache_o ),
    .arprot_s_i   (s_regslc_arprot_o  ),
    .arqos_s_i    (s_regslc_arqos_o   ),
    .arregion_s_i (s_regslc_arregion_o),
    .aruser_s_i   (s_regslc_aruser_o  ),
    .arvalid_s_i  (s_regslc_arvalid_o ),
    .arready_s_o  (s_regslc_arready_i ),
    .armmusid_s_i (s_regslc_armmusid_o),

    .awid_s_i     (s_regslc_awid_o    ),
    .awaddr_s_i   (s_regslc_awaddr_o  ),
    .awlen_s_i    (s_regslc_awlen_o   ),
    .awsize_s_i   (s_regslc_awsize_o  ),
    .awburst_s_i  (s_regslc_awburst_o ),
    .awlock_s_i   (s_regslc_awlock_o  ),
    .awcache_s_i  (s_regslc_awcache_o ),
    .awprot_s_i   (s_regslc_awprot_o  ),
    .awqos_s_i    (s_regslc_awqos_o   ),
    .awregion_s_i (s_regslc_awregion_o),
    .awuser_s_i   (s_regslc_awuser_o  ),
    .awvalid_s_i  (s_regslc_awvalid_o ),
    .awready_s_o  (s_regslc_awready_i ),
    .awmmusid_s_i (s_regslc_awmmusid_o),

    .wdata_s_i    (s_regslc_wdata_o ),
    .wstrb_s_i    (s_regslc_wstrb_o ),
    .wlast_s_i    (s_regslc_wlast_o ),
    .wuser_s_i    (s_regslc_wuser_o ),
    .wvalid_s_i   (s_regslc_wvalid_o),
    .wready_s_o   (s_regslc_wready_i),

    .bid_s_o      (s_regslc_bid_i   ),
    .bresp_s_o    (s_regslc_bresp_i ),
    .buser_s_o    (s_regslc_buser_i ),
    .bvalid_s_o   (s_regslc_bvalid_i),
    .bready_s_i   (s_regslc_bready_o),

    .rid_s_o      (s_regslc_rid_i   ),
    .rdata_s_o    (s_regslc_rdata_i ),
    .rresp_s_o    (s_regslc_rresp_i ),
    .rlast_s_o    (s_regslc_rlast_i ),
    .ruser_s_o    (s_regslc_ruser_i ),
    .rvalid_s_o   (s_regslc_rvalid_i),
    .rready_s_i   (s_regslc_rready_o),

    .awakeup_s_i  (s_regslc_awakeup_o),

    .arid_m_o     (arid_m_wire    ),
    .araddr_m_o   (araddr_m_wire  ),
    .arlen_m_o    (arlen_m_wire   ),
    .arsize_m_o   (arsize_m_wire  ),
    .arburst_m_o  (arburst_m_wire ),
    .arlock_m_o   (arlock_m_wire  ),
    .arcache_m_o  (arcache_m_wire ),
    .arprot_m_o   (arprot_m_wire  ),
    .arqos_m_o    (arqos_m_wire   ),
    .arregion_m_o (arregion_m_wire),
    .aruser_m_o   (aruser_m_wire  ),
    .arvalid_m_o  (arvalid_m_wire ),
    .arready_m_i  (arready_m_wire ),
    .armmusid_m_o (armmusid_m_wire),

    .awid_m_o     (awid_m_wire    ),
    .awaddr_m_o   (awaddr_m_wire  ),
    .awlen_m_o    (awlen_m_wire   ),
    .awsize_m_o   (awsize_m_wire  ),
    .awburst_m_o  (awburst_m_wire ),
    .awlock_m_o   (awlock_m_wire  ),
    .awcache_m_o  (awcache_m_wire ),
    .awprot_m_o   (awprot_m_wire  ),
    .awqos_m_o    (awqos_m_wire   ),
    .awregion_m_o (awregion_m_wire),
    .awuser_m_o   (awuser_m_wire  ),
    .awvalid_m_o  (awvalid_m_wire ),
    .awready_m_i  (awready_m_wire ),
    .awmmusid_m_o (awmmusid_m_wire),

    .wdata_m_o    (wdata_m_wire   ),
    .wstrb_m_o    (wstrb_m_wire   ),
    .wlast_m_o    (wlast_m_wire   ),
    .wuser_m_o    (wuser_m_wire   ),
    .wvalid_m_o   (wvalid_m_wire  ),
    .wready_m_i   (wready_m_wire  ),

    .bid_m_i      (bid_m_wire     ),
    .bresp_m_i    (bresp_m_wire   ),
    .buser_m_i    (buser_m_wire   ),
    .bvalid_m_i   (bvalid_m_wire  ),
    .bready_m_o   (bready_m_wire  ),

    .rid_m_i      (rid_m_wire     ),
    .rdata_m_i    (rdata_m_wire   ),
    .rresp_m_i    (rresp_m_wire   ),
    .rlast_m_i    (rlast_m_wire   ),
    .ruser_m_i    (ruser_m_wire   ),
    .rvalid_m_i   (rvalid_m_wire  ),
    .rready_m_o   (rready_m_wire  ),

    .awakeup_m_o  (awakeup_m_wire ),

    .gate_hold_req_i       (lpi_gate_hold_req_wire  ),
    .gate_hold_ack_o       (gate_hold_ack_wire      ),
    .gate_busy_o           (gate_busy_wire          ),

    .tracker_al_empty_rd_o (tracker_al_empty_rd_wire),
    .tracker_al_empty_wr_o (tracker_al_empty_wr_wire),
    .tracker_empty_rd_o    (tracker_empty_rd_wire),
    .tracker_empty_wr_o    (tracker_empty_wr_wire),
    .tracker_id_rd_ch_i    (tracker_id_rd_ch_wire   ),
    .tracker_id_wr_ch_i    (tracker_id_wr_ch_wire   ),
    .tracker_read_rd_ch_i  (tracker_read_rd_ch_wire ),
    .tracker_read_wr_ch_i  (tracker_read_wr_ch_wire ),
    .tracker_dout_rd_ch_o  (tracker_dout_rd_ch_wire ),
    .tracker_dout_wr_ch_o  (tracker_dout_wr_ch_wire ),
    .tracker_dout_rd_ch_vld_o (tracker_dout_rd_ch_vld_wire),
    .tracker_dout_wr_ch_vld_o (tracker_dout_wr_ch_vld_wire)

);

firewall_f0_comp_dp #(
  .FC_MST_ID_SINGLE_MST     (FC_MST_ID_SINGLE_MST),
  .FC_ME_LVL                (FC_ME_LVL               ),
  .FW_SE_LVL                (FW_SE_LVL               ),
  .FC_PE_LVL                (FC_PE_LVL               ),
  .FC_TE_LVL                (FC_TE_LVL               ),
  .FC_RSE_LVL               (FC_RSE_LVL              ),
  .FC_INST_SPT              (FC_INST_SPT             ),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH           ),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH        ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH          ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH         ),
  .FC_AXIUSER_AR_WIDTH      (FC_AXIUSER_AR_WIDTH     ),
  .FC_AXIUSER_AW_WIDTH      (FC_AXIUSER_AW_WIDTH     ),
  .FC_AXIUSER_W_WIDTH       (FC_AXIUSER_W_WIDTH      ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH      ),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH      ),
  .TRACKER_PAYLOAD_WIDTH_AR (TRACKER_PAYLOAD_WIDTH_AR),
  .TRACKER_PAYLOAD_WIDTH_AW (TRACKER_PAYLOAD_WIDTH_AW),
  .FC_NUM_RGN               (FC_NUM_RGN              ),
  .LOG2_FC_NUM_RGN          (LOG2_FC_NUM_RGN         ),
  .FC_NUM_MPE               (FC_NUM_MPE              ),
  .FC_MNRS                  (FC_MNRS                 ),
  .FC_MXRS                  (FC_MXRS                 ),
  .FC_SINGLE_MST            (FC_SINGLE_MST           ),
  .FC_NUM_MST_ID            (FC_NUM_MST_ID           ),
  .FC_ID                    (FC_ID                   ),
  .FC_MST_ID_VAL            (FC_MST_ID_VAL           ),
  .FC_ERR_RESP_PER_MST_ID   (FC_ERR_RESP_PER_MST_ID  ),
  .FC_ERR_RESP_DEF          (FC_ERR_RESP_DEF         ),
  .FC_PRIV_SPT              (FC_PRIV_SPT             ),
  .FC_SEC_SPT               (FC_SEC_SPT              ),
  .FC_NUM_READ_OS           (FC_NUM_READ_OS),
  .FC_NUM_WRITE_OS          (FC_NUM_WRITE_OS),
  .FC_AXI_READ_RESP_INTRLV  (FC_AXI_READ_RESP_INTRLV)

)
u_fc_dp(
    .clk          (clk_gated   ),
    .reset_n      (reset_n     ),

    .arid_s_i     (arid_m_wire    ),
    .araddr_s_i   (araddr_m_wire  ),
    .arlen_s_i    (arlen_m_wire   ),
    .arsize_s_i   (arsize_m_wire  ),
    .arburst_s_i  (arburst_m_wire ),
    .arlock_s_i   (arlock_m_wire  ),
    .arcache_s_i  (arcache_m_wire ),
    .arprot_s_i   (arprot_m_wire  ),
    .arqos_s_i    (arqos_m_wire   ),
    .arregion_s_i (arregion_m_wire),
    .aruser_s_i   (aruser_m_wire  ),
    .arvalid_s_i  (arvalid_m_wire ),
    .arready_s_o  (arready_m_wire ),
    .armmusid_s_i (armmusid_m_wire),

    .awid_s_i     (awid_m_wire    ),
    .awaddr_s_i   (awaddr_m_wire  ),
    .awlen_s_i    (awlen_m_wire   ),
    .awsize_s_i   (awsize_m_wire  ),
    .awburst_s_i  (awburst_m_wire ),
    .awlock_s_i   (awlock_m_wire  ),
    .awcache_s_i  (awcache_m_wire ),
    .awprot_s_i   (awprot_m_wire  ),
    .awqos_s_i    (awqos_m_wire   ),
    .awregion_s_i (awregion_m_wire),
    .awuser_s_i   (awuser_m_wire  ),
    .awvalid_s_i  (awvalid_m_wire ),
    .awready_s_o  (awready_m_wire ),
    .awmmusid_s_i (awmmusid_m_wire),

    .wdata_s_i    (wdata_m_wire   ),
    .wstrb_s_i    (wstrb_m_wire   ),
    .wlast_s_i    (wlast_m_wire   ),
    .wuser_s_i    (wuser_m_wire   ),
    .wvalid_s_i   (wvalid_m_wire  ),
    .wready_s_o   (wready_m_wire  ),

    .bid_s_o      (bid_m_wire     ),
    .bresp_s_o    (bresp_m_wire   ),
    .buser_s_o    (buser_m_wire   ),
    .bvalid_s_o   (bvalid_m_wire  ),
    .bready_s_i   (bready_m_wire  ),

    .rid_s_o      (rid_m_wire     ),
    .rdata_s_o    (rdata_m_wire   ),
    .rresp_s_o    (rresp_m_wire   ),
    .rlast_s_o    (rlast_m_wire   ),
    .ruser_s_o    (ruser_m_wire   ),
    .rvalid_s_o   (rvalid_m_wire  ),
    .rready_s_i   (rready_m_wire  ),

    .awakeup_s_i  (awakeup_m_wire),

    .arid_m_o     (m_regslc_arid_i    ),
    .araddr_m_o   (m_regslc_araddr_i  ),
    .arlen_m_o    (m_regslc_arlen_i   ),
    .arsize_m_o   (m_regslc_arsize_i  ),
    .arburst_m_o  (m_regslc_arburst_i ),
    .arlock_m_o   (m_regslc_arlock_i  ),
    .arcache_m_o  (m_regslc_arcache_i ),
    .arprot_m_o   (m_regslc_arprot_i  ),
    .arqos_m_o    (m_regslc_arqos_i   ),
    .arregion_m_o (m_regslc_arregion_i),
    .aruser_m_o   (m_regslc_aruser_i  ),
    .arvalid_m_o  (m_regslc_arvalid_i ),
    .arready_m_i  (m_regslc_arready_o ),
    .armmusid_m_o (m_regslc_armmusid_i),

    .awid_m_o     (m_regslc_awid_i    ),
    .awaddr_m_o   (m_regslc_awaddr_i  ),
    .awlen_m_o    (m_regslc_awlen_i   ),
    .awsize_m_o   (m_regslc_awsize_i  ),
    .awburst_m_o  (m_regslc_awburst_i ),
    .awlock_m_o   (m_regslc_awlock_i  ),
    .awcache_m_o  (m_regslc_awcache_i ),
    .awprot_m_o   (m_regslc_awprot_i  ),
    .awqos_m_o    (m_regslc_awqos_i   ),
    .awregion_m_o (m_regslc_awregion_i),
    .awuser_m_o   (m_regslc_awuser_i  ),
    .awvalid_m_o  (m_regslc_awvalid_i ),
    .awready_m_i  (m_regslc_awready_o ),
    .awmmusid_m_o (m_regslc_awmmusid_i),

    .wdata_m_o    (m_regslc_wdata_i   ),
    .wstrb_m_o    (m_regslc_wstrb_i   ),
    .wlast_m_o    (m_regslc_wlast_i   ),
    .wuser_m_o    (m_regslc_wuser_i   ),
    .wvalid_m_o   (m_regslc_wvalid_i  ),
    .wready_m_i   (m_regslc_wready_o  ),

    .bid_m_i      (m_regslc_bid_o     ),
    .bresp_m_i    (m_regslc_bresp_o   ),
    .buser_m_i    (m_regslc_buser_o   ),
    .bvalid_m_i   (m_regslc_bvalid_o  ),
    .bready_m_o   (m_regslc_bready_i  ),

    .rid_m_i      (m_regslc_rid_o     ),
    .rdata_m_i    (m_regslc_rdata_o   ),
    .rresp_m_i    (m_regslc_rresp_o   ),
    .rlast_m_i    (m_regslc_rlast_o   ),
    .ruser_m_i    (m_regslc_ruser_o   ),
    .rvalid_m_i   (m_regslc_rvalid_o  ),
    .rready_m_o   (m_regslc_rready_i  ),

    .awakeup_m_o  (m_regslc_awakeup_i ),

    .tracker_al_empty_rd_i (tracker_al_empty_rd_wire),
    .tracker_al_empty_wr_i (tracker_al_empty_wr_wire),
    .tracker_empty_rd_i    (tracker_empty_rd_wire),
    .tracker_empty_wr_i    (tracker_empty_wr_wire),

    .tracker_id_rd_ch_o    (tracker_id_rd_ch_wire   ),
    .tracker_id_wr_ch_o    (tracker_id_wr_ch_wire   ),
    .tracker_read_rd_ch_o  (tracker_read_rd_ch_wire ),
    .tracker_read_wr_ch_o  (tracker_read_wr_ch_wire ),
    .tracker_dout_rd_ch_i  (tracker_dout_rd_ch_wire ),
    .tracker_dout_wr_ch_i  (tracker_dout_wr_ch_wire ),
    .tracker_dout_rd_ch_vld_i (tracker_dout_rd_ch_vld_wire),
    .tracker_dout_wr_ch_vld_i (tracker_dout_wr_ch_vld_wire),

    .rb_me_st_rdum_i       ( cfg_me_st_i_wire[0] ),
    .rb_pe_st_err_i        ( cfg_pe_st_i_wire[0]),
    .rb_pe_st_err_raz_i    ( cfg_pe_st_i_wire[1:0]),
    .rb_pe_st_flt_cfg_i    ( cfg_pe_st_i_wire[3:2]),
    .rb_pe_st_en_i         ( cfg_pe_st_i_wire[6]),

    .rb_fe_rd_tal_o        (cfg_fe_tal_rd_o_wire ),
    .rb_fe_rd_tau_o        (cfg_fe_tau_rd_o_wire ),
    .rb_fe_rd_tp_o         (cfg_fe_tp_rd_o_wire ),
    .rb_fe_rd_mid_o        (cfg_fe_mid_rd_o_wire ),
    .rb_fe_rd_valid_o      (cfg_fe_rd_en_wire ),
    .rb_fe_rd_type_o       (cfg_fe_type_rd_o_wire ),
    .rb_tmp_reg_err_rd     ( ), 

    .rb_fe_wr_tal_o        (cfg_fe_tal_wr_o_wire ),
    .rb_fe_wr_tau_o        (cfg_fe_tau_wr_o_wire ),
    .rb_fe_wr_tp_o         (cfg_fe_tp_wr_o_wire ),
    .rb_fe_wr_mid_o        (cfg_fe_mid_wr_o_wire ),
    .rb_fe_wr_valid_o      (cfg_fe_wr_en_wire ),
    .rb_fe_wr_type_o       (cfg_fe_type_wr_o_wire ),
    .rb_tmp_reg_err_wr     ( ), 

    .rb_prot_size_i        (cfg_prot_size_i_wire ),
    .rb_bypass_i           (cfg_bypass_i_wire[1] ),
    .rb_sram_rdy_i         (1'b1 ),  
    .rb_fw_st_i            (2'b00 ), 
    .rb_st_me_en_i         (cfg_me_st_i_wire[2]),

    .rb_cfg_rgn_tcfg0_i    (cfg_rgn_tcfg0_i_wire),
    .rb_cfg_rgn_tcfg1_i    (cfg_rgn_tcfg1_i_wire),
    .rb_cfg_rgn_tcfg2_i    (cfg_rgn_tcfg2_i_wire),

    .rb_rgn_st_i           (cfg_rgn_st_i_wire ),
    .rb_rgn_size_i         (cfg_rgn_size_i_wire ),
    .rb_rgn_base_addr_i    (cfg_rb_base_addr_wire ),
    .rb_rgn_upper_addr_i   (cfg_rb_upr_addr_wire ),

    .rb_rgn_mid0_i         (cfg_rgn_mid0_i_wire ),
    .rb_rgn_mid1_i         (cfg_rgn_mid1_i_wire ),
    .rb_rgn_mid2_i         (cfg_rgn_mid2_i_wire ),
    .rb_rgn_mid3_i         (cfg_rgn_mid3_i_wire ),

    .rb_rgn_mpl0_i         (cfg_rgn_mpl0_i_wire ),
    .rb_rgn_mpl1_i         (cfg_rgn_mpl1_i_wire ),
    .rb_rgn_mpl2_i         (cfg_rgn_mpl2_i_wire ),
    .rb_rgn_mpl3_i         (cfg_rgn_mpl3_i_wire ),

    .rd_edr_wen_o          (rd_edr_wen),
    .rd_edr_addr_lwr_o     (rd_edr_addr_lwr),
    .rd_edr_addr_uppr_o    (rd_edr_addr_uppr),
    .rd_edr_prop_o         (rd_edr_prop),
    .wr_edr_wen_o          (wr_edr_wen),
    .wr_edr_addr_lwr_o     (wr_edr_addr_lwr),
    .wr_edr_addr_uppr_o    (wr_edr_addr_uppr),
    .wr_edr_prop_o         (wr_edr_prop),

    .bid_pchk_i            ({FC_AXIID_WIDTH{1'b0}}),
    .bresp_pchk_i          (2'b00),
    .buser_pchk_i          ({FC_AXIUSER_B_WIDTH{1'b0}}),
    .bvalid_pchk_i         (1'b0),
    .bready_pchk_o         (),   

    .bid_cfg_i             ({FC_AXIID_WIDTH{1'b0}}),
    .bresp_cfg_i           (2'b00),
    .buser_cfg_i           ({FC_AXIUSER_B_WIDTH{1'b0}}),
    .bvalid_cfg_i          (1'b0),
    .bready_cfg_o          (),   

    .rid_pchk_i            ({FC_AXIID_WIDTH{1'b0}}),
    .rdata_pchk_i          ({FC_AXIDATA_WIDTH{1'b0}}),
    .rresp_pchk_i          (2'b00),
    .rlast_pchk_i          (1'b0),
    .ruser_pchk_i          ({FC_AXIUSER_R_WIDTH{1'b0}}),
    .rvalid_pchk_i         (1'b0),
    .mst_id_pchk_i         ({FC_MST_ID_WIDTH{1'b0}}),
    .rready_pchk_o         (),   

    .rid_cfg_i             ({FC_AXIID_WIDTH{1'b0}}),
    .rdata_cfg_i           ({FC_AXIDATA_WIDTH{1'b0}}),
    .rresp_cfg_i           (2'b00),
    .rlast_cfg_i           (1'b0),
    .ruser_cfg_i           ({FC_AXIUSER_R_WIDTH{1'b0}}),
    .rvalid_cfg_i          (1'b0),
    .mst_id_cfg_i          ({FC_MST_ID_WIDTH{1'b0}}),
    .rready_cfg_o          ()   

);

firewall_f0_comp_fc_regbank #(
  .FC_ID               (FC_ID               ),
  .FC_PE_LVL           (FC_PE_LVL           ),
  .PE_CTRL_WIDTH       (PE_CTRL_WIDTH       ),
  .PE_ST_WIDTH         (PE_ST_WIDTH         ),
  .RWE_CTRL_WIDTH      (RWE_CTRL_WIDTH      ),
  .FC_NUM_RGN          (FC_NUM_RGN          ),
  .LOG2_FC_NUM_RGN     (LOG2_FC_NUM_RGN     ),
  .RGN_CTRL0_WIDTH     (RGN_CTRL0_WIDTH     ),
  .RGN_CTRL1_WIDTH     (RGN_CTRL1_WIDTH     ),
  .FC_NUM_MPE          (FC_NUM_MPE          ),
  .RGN_LCTRL_WIDTH     (RGN_LCTRL_WIDTH     ),
  .FW_LDE_LVL          (FW_LDE_LVL          ),
  .RGN_ST_WIDTH        (RGN_ST_WIDTH        ),
  .FC_MXRS             (FC_MXRS             ),
  .FC_MNRS             (FC_MNRS             ),
  .RGN_CFG0_WIDTH      (RGN_CFG0_WIDTH      ),
  .PE_BPS_WIDTH        (PE_BPS_WIDTH        ),
  .FC_RGN_BASE_ADDR    (FC_RGN_BASE_ADDR    ),
  .RGN_CFG1_WIDTH      (RGN_CFG1_WIDTH      ),
  .FC_RGN_UPR_ADDR     (FC_RGN_UPR_ADDR     ),
  .FC_RSE_LVL          (FC_RSE_LVL          ),
  .RGN_SIZE_WIDTH      (RGN_SIZE_WIDTH      ),
  .FC_RGN_MULNPO2      (FC_RGN_MULNPO2      ),
  .FC_RGN_SIZE         (FC_RGN_SIZE         ),
  .PROT_SIZE_WIDTH     (PROT_SIZE_WIDTH     ),
  .RGN_TCFG0_WIDTH     (RGN_TCFG0_WIDTH     ),
  .FC_TE_LVL           (FC_TE_LVL           ),
  .RGN_TCFG1_WIDTH     (RGN_TCFG1_WIDTH     ),
  .RGN_TCFG2_WIDTH     (RGN_TCFG2_WIDTH     ),
  .FC_MA_SPT           (FC_MA_SPT           ),
  .FC_SH_SPT           (FC_SH_SPT           ),
  .FC_INST_SPT         (FC_INST_SPT         ),
  .FC_PRIV_SPT         (FC_PRIV_SPT         ),
  .FC_SEC_SPT          (FC_SEC_SPT          ),
  .FC_SINGLE_MST       (FC_SINGLE_MST       ),
  .FC_MST_ID_WIDTH     (FC_MST_ID_WIDTH     ),
  .RGN_MPL0_WIDTH      (RGN_MPL0_WIDTH      ),
  .RGN_MPL1_WIDTH      (RGN_MPL1_WIDTH      ),
  .RGN_MPL2_WIDTH      (RGN_MPL2_WIDTH      ),
  .RGN_MPL3_WIDTH      (RGN_MPL3_WIDTH      ),
  .FE_TAL_WIDTH        (FE_TAL_WIDTH        ),
  .FE_TAU_WIDTH        (FE_TAU_WIDTH        ),
  .FE_TP_WIDTH         (FE_TP_WIDTH         ),
  .FE_CTRL_WIDTH       (FE_CTRL_WIDTH       ),
  .IRQ_TYPE_WIDTH      (IRQ_TYPE_WIDTH      ),
  .ME_CTRL_WIDTH       (ME_CTRL_WIDTH       ),
  .ME_ST_WIDTH         (ME_ST_WIDTH         ),
  .EDR_TAL_WIDTH       (EDR_TAL_WIDTH       ),
  .EDR_TAU_WIDTH       (EDR_TAU_WIDTH       ),
  .EDR_TP_WIDTH        (EDR_TP_WIDTH        ),
  .EDR_CTRL_WIDTH      (EDR_CTRL_WIDTH      ),
  .FC_ME_LVL           (FC_ME_LVL           ),
  .LD_CTRL_WIDTH       (LD_CTRL_WIDTH       ),
  .FC_MST_ID_SINGLE_MST(FC_MST_ID_SINGLE_MST),
  .FW_SRE_LVL          (FW_SRE_LVL          )
)u_fc_regbank
    (
    .clk                   (clk_gated               ),
    .reset_n               (reset_n                 ),
    .arvalid_i             (s_regslc_arvalid_o),
    .awvalid_i             (s_regslc_awvalid_o),
    .wvalid_i              (s_regslc_wvalid_o),

    .rvalid_i              (s_regslc_rvalid_i),
    .bvalid_i              (s_regslc_bvalid_i),
    .pe_ctrl_i             (cfg_pe_ctrl_o_wire      ),
    .pe_ctrl_en            (cfg_pe_ctrl_en_wire     ),
    .pe_ctrl_o             (cfg_pe_ctrl_i_wire      ),
    .pe_st_o               (cfg_pe_st_i_wire        ),
    .rwe_ctrl_i            (cfg_rwe_ctrl_o_wire     ),
    .rwe_ctrl_en           (cfg_rwe_ctrl_en_wire    ),
    .rwe_ctrl_o            (cfg_rwe_ctrl_i_wire     ),
    .rgn_ctrl0_i           (cfg_rgn_ctrl0_o_wire    ),
    .rgn_ctrl0_en          (cfg_rgn_ctrl0_en_wire   ),
    .rgn_ctrl0_o           (cfg_rgn_ctrl0_i_wire    ),
    .rgn_ctrl0_rgn_o       (cfg_rgn_ctrl0_rgn_i_wire),
    .rgn_ctrl1_i           (cfg_rgn_ctrl1_o_wire    ),
    .rgn_ctrl1_rgn_o       (cfg_rgn_ctrl1_rgn_i_wire),
    .rgn_ctrl1_en          (cfg_rgn_ctrl1_en_wire   ),
    .rgn_ctrl1_o           (cfg_rgn_ctrl1_i_wire    ),
    .rgn_lctrl_i           (cfg_rgn_lctrl_o_wire    ),
    .rgn_lctrl_rgn_o       (cfg_rgn_lctrl_rgn_i_wire),
    .rgn_lctrl_en          (cfg_rgn_lctrl_en_wire   ),
    .rgn_lctrl_o           (cfg_rgn_lctrl_i_wire    ),
    .rgn_st_rgn_o          (cfg_rgn_st_rgn_i_wire   ),
    .rgn_st_o              (cfg_rgn_st_i_wire       ),
    .rgn_cfg0_i            (cfg_rgn_cfg0_o_wire     ),
    .rgn_cfg0_rgn_o        (cfg_rgn_cfg0_rgn_i_wire ),
    .rgn_cfg0_en           (cfg_rgn_cfg0_en_wire    ),
    .rgn_cfg0_o            (cfg_rgn_cfg0_i_wire     ),
    .rgn_cfg1_i            (cfg_rgn_cfg1_o_wire     ),
    .rgn_cfg1_rgn_o        (cfg_rgn_cfg1_rgn_i_wire ),
    .rgn_cfg1_en           (cfg_rgn_cfg1_en_wire    ),
    .rgn_cfg1_o            (cfg_rgn_cfg1_i_wire     ),
    .rgn_size_i            (cfg_rgn_size_o_wire     ),
    .rgn_size_rgn_o        (cfg_rgn_size_rgn_i_wire ),
    .rgn_size_en           (cfg_rgn_size_en_wire    ),
    .rgn_size_o            (cfg_rgn_size_i_wire     ),
    .rgn_tcfg0_i           (cfg_rgn_tcfg0_o_wire    ),
    .rgn_tcfg0_rgn_o       (cfg_rgn_tcfg0_rgn_i_wire),
    .rgn_tcfg0_en          (cfg_rgn_tcfg0_en_wire   ),
    .rgn_tcfg0_o           (cfg_rgn_tcfg0_i_wire    ),
    .rgn_tcfg1_i           (cfg_rgn_tcfg1_o_wire    ),
    .rgn_tcfg1_rgn_o       (cfg_rgn_tcfg1_rgn_i_wire),
    .rgn_tcfg1_en          (cfg_rgn_tcfg1_en_wire   ),
    .rgn_tcfg1_o           (cfg_rgn_tcfg1_i_wire    ),
    .rgn_tcfg2_i           (cfg_rgn_tcfg2_o_wire    ),
    .rgn_tcfg2_rgn_o       (cfg_rgn_tcfg2_rgn_i_wire),
    .rgn_tcfg2_en          (cfg_rgn_tcfg2_en_wire   ),
    .rgn_tcfg2_o           (cfg_rgn_tcfg2_i_wire    ),
    .rgn_mid0_i            (cfg_rgn_mid0_o_wire     ),
    .rgn_mid0_rgn_o        (cfg_rgn_mid0_rgn_i_wire ),
    .rgn_mid0_en           (cfg_rgn_mid0_en_wire    ),
    .rgn_mid0_o            (cfg_rgn_mid0_i_wire     ),
    .rgn_mid1_i            (cfg_rgn_mid1_o_wire     ),
    .rgn_mid1_rgn_o        (cfg_rgn_mid1_rgn_i_wire ),
    .rgn_mid1_en           (cfg_rgn_mid1_en_wire    ),
    .rgn_mid1_o            (cfg_rgn_mid1_i_wire     ),
    .rgn_mid2_i            (cfg_rgn_mid2_o_wire     ),
    .rgn_mid2_rgn_o        (cfg_rgn_mid2_rgn_i_wire ),
    .rgn_mid2_en           (cfg_rgn_mid2_en_wire    ),
    .rgn_mid2_o            (cfg_rgn_mid2_i_wire     ),
    .rgn_mid3_i            (cfg_rgn_mid3_o_wire     ),
    .rgn_mid3_rgn_o        (cfg_rgn_mid3_rgn_i_wire ),
    .rgn_mid3_en           (cfg_rgn_mid3_en_wire    ),
    .rgn_mid3_o            (cfg_rgn_mid3_i_wire     ),
    .rgn_mpl0_i            (cfg_rgn_mpl0_o_wire     ),
    .rgn_mpl0_rgn_o        (cfg_rgn_mpl0_rgn_i_wire ),
    .rgn_mpl0_en           (cfg_rgn_mpl0_en_wire    ),
    .rgn_mpl0_o            (cfg_rgn_mpl0_i_wire     ),
    .rgn_mpl1_i            (cfg_rgn_mpl1_o_wire     ),
    .rgn_mpl1_rgn_o        (cfg_rgn_mpl1_rgn_i_wire ),
    .rgn_mpl1_en           (cfg_rgn_mpl1_en_wire    ),
    .rgn_mpl1_o            (cfg_rgn_mpl1_i_wire     ),
    .rgn_mpl2_i            (cfg_rgn_mpl2_o_wire     ),
    .rgn_mpl2_rgn_o        (cfg_rgn_mpl2_rgn_i_wire ),
    .rgn_mpl2_en           (cfg_rgn_mpl2_en_wire    ),
    .rgn_mpl2_o            (cfg_rgn_mpl2_i_wire     ),
    .rgn_mpl3_i            (cfg_rgn_mpl3_o_wire     ),
    .rgn_mpl3_rgn_o        (cfg_rgn_mpl3_rgn_i_wire ),
    .rgn_mpl3_en           (cfg_rgn_mpl3_en_wire    ),
    .rgn_mpl3_o            (cfg_rgn_mpl3_i_wire     ),

    .fe_tal_o              (cfg_fe_tal_i_wire       ),
    .fe_tau_o              (cfg_fe_tau_i_wire       ),
    .fe_tp_o               (cfg_fe_tp_i_wire        ),
    .fe_mid_o              (cfg_fe_mid_i_wire       ),

    .fe_tal_rdch_i         (cfg_fe_tal_rd_o_wire       ),
    .fe_tau_rdch_i         (cfg_fe_tau_rd_o_wire       ),
    .fe_tp_rdch_i          (cfg_fe_tp_rd_o_wire        ),
    .fe_mid_rdch_i         (cfg_fe_mid_rd_o_wire       ),
    .fe_type_rdch_i        (cfg_fe_type_rd_o_wire      ),
    .fe_rdch_en            (cfg_fe_rd_en_wire          ),

    .fe_tal_wrch_i         (cfg_fe_tal_wr_o_wire       ),
    .fe_tau_wrch_i         (cfg_fe_tau_wr_o_wire       ),
    .fe_tp_wrch_i          (cfg_fe_tp_wr_o_wire        ),
    .fe_mid_wrch_i         (cfg_fe_mid_wr_o_wire       ),
    .fe_type_wrch_i        (cfg_fe_type_wr_o_wire      ),
    .fe_wrch_en            (cfg_fe_wr_en_wire          ),

    .fe_ctrl_i             (cfg_fe_ctrl_o_wire      ),
    .fe_ctrl_en            (cfg_fe_ctrl_en_wire     ),
    .fe_ctrl_o             (cfg_fe_ctrl_i_wire      ),
    .me_ctrl_i             (cfg_me_ctrl_o_wire      ),
    .me_ctrl_en            (cfg_me_ctrl_en_wire     ),
    .me_ctrl_o             (cfg_me_ctrl_i_wire      ),
    .me_st_o               (cfg_me_st_i_wire        ),
    .edr_tal_i             (cfg_edr_tal_o_wire      ),
    .edr_tal_en            (cfg_edr_tal_en_wire     ),
    .edr_tal_o             (cfg_edr_tal_i_wire      ),
    .edr_tau_i             (cfg_edr_tau_o_wire      ),
    .edr_tau_en            (cfg_edr_tau_en_wire     ),
    .edr_tau_o             (cfg_edr_tau_i_wire      ),
    .edr_tp_i              (cfg_edr_tp_o_wire       ),
    .edr_tp_en             (cfg_edr_tp_en_wire      ),
    .edr_tp_o              (cfg_edr_tp_i_wire       ),
    .edr_mid_i             (cfg_edr_mid_o_wire      ),
    .edr_mid_en            (cfg_edr_mid_en_wire     ),
    .edr_mid_o             (cfg_edr_mid_i_wire      ),
    .edr_ctrl_i            (cfg_edr_ctrl_o_wire     ),
    .edr_ctrl_en           (cfg_edr_ctrl_en_wire    ),
    .edr_ctrl_o            (cfg_edr_ctrl_i_wire     ),
    .ld_ctrl_i             (cfg_ld_ctrl_o_wire      ),
    .ld_ctrl_en            (cfg_ld_ctrl_en_wire     ),
    .ld_ctrl_o             (cfg_ld_ctrl_i_wire      ),
    .prot_size_i           (cfg_prot_size_o_wire    ),
    .prot_size_en          (cfg_prot_size_en_wire   ),
    .prot_size_o           (cfg_prot_size_i_wire    ),

    .pe_bps_i (bypass_syncd),
    .pe_bps_o (cfg_bypass_i_wire),

    .fc_rb_lpi_discon_deny_o (rb_pwr_deny_wire      ),
    .fc_base_addr_o          (cfg_rb_base_addr_wire ),
    .fc_upr_addr_o           (cfg_rb_upr_addr_wire  ),
    .cfg_irq_o               (cfg_irq_req_wire      ),
    .cfg_irq_valid_o         (cfg_irq_valid_wire    ),
    .rd_edr_wen_i            (rd_edr_wen            ),
    .rd_edr_addr_lwr_i       (rd_edr_addr_lwr       ),
    .rd_edr_addr_uppr_i      (rd_edr_addr_uppr      ),
    .rd_edr_prop_i           (rd_edr_prop           ),
    .wr_edr_wen_i            (wr_edr_wen            ),
    .wr_edr_addr_lwr_i       (wr_edr_addr_lwr       ),
    .wr_edr_addr_uppr_i      (wr_edr_addr_uppr      ),
    .wr_edr_prop_i           (wr_edr_prop           ),
    .ax_tracker_empty        (tracker_empty_rd_wire & tracker_empty_wr_wire),
    .default_state_i         (default_state_wire)
);

firewall_f0_bas_reg_slice #(
  .DATA_WIDTH       (FC_CFG_DATA_W),
  .ID_WIDTH         (LOG2_FW_NUM_FC),
  .MODE             (FC_BAS_REG_SLC)
)
u_bas_reg_regslice
(
  .aresetn          (reset_n),
  .aclk             (clk_gated),

  .tvalid_dti_dn_s  (tvalid_ds_int),
  .tready_dti_dn_s  (tready_ds_int),
  .tdata_dti_dn_s   (tdata_ds_int),
  .tkeep_dti_dn_s   (tkeep_ds_int),
  .tid_dti_dn_s     (tid_ds_int),
  .tlast_dti_dn_s   (tlast_ds_int),

  .tvalid_dti_up_s  (tvalid_us_int),
  .tready_dti_up_s  (tready_us_int),
  .tdata_dti_up_s   (tdata_us_int),
  .tkeep_dti_up_s   (tkeep_us_int),
  .tdest_dti_up_s   (tdest_us_int),
  .tlast_dti_up_s   (tlast_us_int),

  .tvalid_dti_up_m  (tvalid_us_i),
  .tready_dti_up_m  (tready_us_o),
  .tdata_dti_up_m   (tdata_us_i),
  .tkeep_dti_up_m   (tkeep_us_i),
  .tdest_dti_up_m   (tdest_us_i),
  .tlast_dti_up_m   (tlast_us_i),

  .tvalid_dti_dn_m  (tvalid_ds_o),
  .tready_dti_dn_m  (tready_ds_i),
  .tdata_dti_dn_m   (tdata_ds_o),
  .tkeep_dti_dn_m   (tkeep_ds_o),
  .tid_dti_dn_m     (tid_ds_o),
  .tlast_dti_dn_m   (tlast_ds_o),

  .twakeup_dti_dn_s (twakeup_ds_int),
  .twakeup_dti_up_s (twakeup_us_int),
  .twakeup_dti_up_m (twakeup_us_i),
  .twakeup_dti_dn_m (twakeup_ds_o),

  .qactive_cg       (bas_qactive),

  .bas_gate         (cfg_gate_bas_wire)
);

firewall_f0_comp_cfg #(
  .FC_CFG_DATA_W            (FC_CFG_DATA_W      ),
  .LOG2_FW_NUM_FC           (LOG2_FW_NUM_FC     ),
  .FC_NUM_RGN               (FC_NUM_RGN         ),
  .LOG2_FC_NUM_RGN          (LOG2_FC_NUM_RGN    ),
  .REG_ADDR_WIDTH           (REG_ADDR_WIDTH     ),
  .REG_DATA_WIDTH           (REG_DATA_WIDTH     ),
  .FW_SRE_LVL               (FW_SRE_LVL         ),
  .READ_DATA_SIZE           (READ_DATA_SIZE     ),
  .IRQ_TYPE_WIDTH           (IRQ_TYPE_WIDTH     ),
  .MSG_TYPE_WIDTH           (MSG_TYPE_WIDTH     ),
  .MSG_NOFRMT_SIZE          (MSG_NOFRMT_SIZE    ),
  .MSG_TYPE_READ            (MSG_TYPE_READ      ),
  .MSG_TYPE_WRITE           (MSG_TYPE_WRITE     ),
  .MSG_TYPE_CONNECT         (MSG_TYPE_CONNECT   ),
  .MSG_TYPE_DISCONNECT      (MSG_TYPE_DISCONNECT),
  .MSG_TYPE_IRQ             (MSG_TYPE_IRQ       ),
  .FC_ME_LVL                (FC_ME_LVL         ),
  .MSG_SIZE                 (MSG_SIZE          ),
  .READ_MSG_HDR_SIZE        (READ_MSG_HDR_SIZE ),
  .CFG_READ_RSP_T           (CFG_READ_RSP_T    ),
  .CFG_WRITE_RSP_T          (CFG_WRITE_RSP_T   ),
  .CFG_RSP_T                (CFG_RSP_T         ),
  .HNDSHK_REQ_T             (HNDSHK_REQ_T      ),
  .IRQ_REQ_T                (IRQ_REQ_T         ),
  .FC_ID                    (FC_ID             ),
  .FC_PE_LVL                (FC_PE_LVL         ),
  .FW_LDE_LVL               (FW_LDE_LVL        ),
  .FC_MXRS                  (FC_MXRS           ),
  .FC_RSE_LVL               (FC_RSE_LVL        ),
  .FC_TE_LVL                (FC_TE_LVL         ),
  .FC_NUM_MPE               (FC_NUM_MPE        ),
  .FC_SINGLE_MST            (FC_SINGLE_MST     ),
  .FC_INST_SPT              (FC_INST_SPT       ),
  .FC_MA_SPT                (FC_MA_SPT        ),
  .FC_SEC_SPT               (FC_SEC_SPT       ),
  .FC_PRIV_SPT              (FC_PRIV_SPT      ),
  .FC_SH_SPT                (FC_SH_SPT        ),
  .SRAM_WIDTH               (SRAM_WIDTH       ),
  .MAX_NUM_OF_PKTS          (MAX_NUM_OF_PKTS  ),
  .MSG_SIZE_WIDTH           (MSG_SIZE_WIDTH   ),
  .LD_CTRL_WIDTH            (LD_CTRL_WIDTH    ),
  .PE_CTRL_WIDTH            (PE_CTRL_WIDTH    ),
  .PE_ST_WIDTH              (PE_ST_WIDTH      ),
  .RWE_CTRL_WIDTH           (RWE_CTRL_WIDTH   ),
  .RGN_CTRL0_WIDTH          (RGN_CTRL0_WIDTH  ),
  .RGN_CTRL1_WIDTH          (RGN_CTRL1_WIDTH  ),
  .RGN_LCTRL_WIDTH          (RGN_LCTRL_WIDTH  ),
  .RGN_ST_WIDTH             (RGN_ST_WIDTH     ),
  .RGN_CFG0_WIDTH           (RGN_CFG0_WIDTH   ),
  .RGN_CFG1_WIDTH           (RGN_CFG1_WIDTH   ),
  .RGN_SIZE_WIDTH           (RGN_SIZE_WIDTH   ),
  .RGN_TCFG0_WIDTH          (RGN_TCFG0_WIDTH  ),
  .RGN_TCFG1_WIDTH          (RGN_TCFG1_WIDTH  ),
  .RGN_TCFG2_WIDTH          (RGN_TCFG2_WIDTH  ),
  .RGN_MPL0_WIDTH           (RGN_MPL0_WIDTH   ),
  .RGN_MPL1_WIDTH           (RGN_MPL1_WIDTH   ),
  .RGN_MPL2_WIDTH           (RGN_MPL2_WIDTH   ),
  .RGN_MPL3_WIDTH           (RGN_MPL3_WIDTH   ),
  .FE_TAL_WIDTH             (FE_TAL_WIDTH     ),
  .FE_TAU_WIDTH             (FE_TAU_WIDTH     ),
  .FE_TP_WIDTH              (FE_TP_WIDTH      ),
  .FE_CTRL_WIDTH            (FE_CTRL_WIDTH    ),
  .ME_CTRL_WIDTH            (ME_CTRL_WIDTH    ),
  .ME_ST_WIDTH              (ME_ST_WIDTH      ),
  .EDR_TAL_WIDTH            (EDR_TAL_WIDTH    ),
  .EDR_TAU_WIDTH            (EDR_TAU_WIDTH    ),
  .EDR_TP_WIDTH             (EDR_TP_WIDTH     ),
  .EDR_CTRL_WIDTH           (EDR_CTRL_WIDTH   ),
  .FC_CAP0_WIDTH            (FC_CAP0_WIDTH    ),
  .FC_CAP1_WIDTH            (FC_CAP1_WIDTH    ),
  .FC_CAP2_WIDTH            (FC_CAP2_WIDTH    ),
  .FC_CAP3_WIDTH            (FC_CAP3_WIDTH    ),
  .FC_CFG0_WIDTH            (FC_CFG0_WIDTH    ),
  .FC_CFG1_WIDTH            (FC_CFG1_WIDTH    ),
  .FC_CFG2_WIDTH            (FC_CFG2_WIDTH    ),
  .FC_CFG3_WIDTH            (FC_CFG3_WIDTH    ),
  .FC_BAS_REG_SLC           (FC_BAS_REG_SLC   ),
  .FW_MAX_MST_ID_WIDTH      (FW_MAX_MST_ID_WIDTH ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH )
)
u_comp_cfg(
    .clk                     (clk_gated           ),
    .reset_n                 (reset_n             ),

    .cfg_tvalid_us_i         (tvalid_us_int    ),
    .cfg_tready_us_o         (tready_us_int    ),
    .cfg_tdata_us_i          (tdata_us_int     ),
    .cfg_tkeep_us_i          (tkeep_us_int     ),
    .cfg_tlast_us_i          (tlast_us_int     ),
    .cfg_tdest_us_i          (tdest_us_int     ),
    .cfg_twakeup_us_i        (twakeup_us_int   ),

    .cfg_tvalid_ds_o         (tvalid_ds_int    ),
    .cfg_tready_ds_i         (tready_ds_int    ),
    .cfg_tdata_ds_o          (tdata_ds_int     ),
    .cfg_tkeep_ds_o          (tkeep_ds_int     ),
    .cfg_tlast_ds_o          (tlast_ds_int     ),
    .cfg_tid_ds_o            (tid_ds_int       ),
    .cfg_twakeup_ds_o        (twakeup_ds_int   ),

    .cfg_lpi_con_req_i       (cfg_lpi_con_req_wire   ),
    .cfg_lpi_discon_req_i    (cfg_lpi_discon_req_wire),
    .cfg_lpi_clk_hold_i      (cfg_lpi_clk_hold_wire  ),
    .cfg_lpi_pwr_accept_o    (cfg_lpi_pwr_accept_wire),
    .cfg_lpi_busy_o          (cfg_lpi_busy_wire      ),

    .cfg_gate_bas_o          (cfg_gate_bas_wire      ),

    .cfg_irq_req_i           (cfg_irq_req_wire ),
    .cfg_irq_valid_i         (cfg_irq_valid_wire     ),

    .cfg_pe_ctrl_i           (cfg_pe_ctrl_i_wire       ),
    .cfg_pe_ctrl_en          (cfg_pe_ctrl_en_wire       ),
    .cfg_pe_ctrl_o           (cfg_pe_ctrl_o_wire       ),
    .cfg_pe_st_i             (cfg_pe_st_i_wire         ),
    .cfg_rwe_ctrl_i          (cfg_rwe_ctrl_i_wire      ),
    .cfg_rwe_ctrl_en         (cfg_rwe_ctrl_en_wire      ),
    .cfg_rwe_ctrl_o          (cfg_rwe_ctrl_o_wire      ),
    .cfg_rgn_ctrl0_en        (cfg_rgn_ctrl0_en_wire     ),
    .cfg_rgn_ctrl0_o         (cfg_rgn_ctrl0_o_wire     ),
    .cfg_rgn_ctrl0_rgn_i     (cfg_rgn_ctrl0_rgn_i_wire ),
    .cfg_rgn_ctrl1_rgn_i     (cfg_rgn_ctrl1_rgn_i_wire),
    .cfg_rgn_ctrl1_en        (cfg_rgn_ctrl1_en_wire),
    .cfg_rgn_ctrl1_o         (cfg_rgn_ctrl1_o_wire),
    .cfg_rgn_lctrl_rgn_i     (cfg_rgn_lctrl_rgn_i_wire),
    .cfg_rgn_lctrl_en        (cfg_rgn_lctrl_en_wire),
    .cfg_rgn_lctrl_o         (cfg_rgn_lctrl_o_wire),
    .cfg_rgn_st_rgn_i        (cfg_rgn_st_rgn_i_wire),
    .cfg_rgn_cfg0_rgn_i      (cfg_rgn_cfg0_rgn_i_wire),
    .cfg_rgn_cfg0_en         (cfg_rgn_cfg0_en_wire),
    .cfg_rgn_cfg0_o          (cfg_rgn_cfg0_o_wire),
    .cfg_rgn_cfg1_rgn_i      (cfg_rgn_cfg1_rgn_i_wire),
    .cfg_rgn_cfg1_en         (cfg_rgn_cfg1_en_wire),
    .cfg_rgn_cfg1_o          (cfg_rgn_cfg1_o_wire),
    .cfg_rgn_size_rgn_i      (cfg_rgn_size_rgn_i_wire),
    .cfg_rgn_size_en         (cfg_rgn_size_en_wire),
    .cfg_rgn_size_o          (cfg_rgn_size_o_wire),
    .cfg_rgn_tcfg0_rgn_i     (cfg_rgn_tcfg0_rgn_i_wire),
    .cfg_rgn_tcfg0_en        (cfg_rgn_tcfg0_en_wire),
    .cfg_rgn_tcfg0_o         (cfg_rgn_tcfg0_o_wire),
    .cfg_rgn_tcfg1_rgn_i     (cfg_rgn_tcfg1_rgn_i_wire),
    .cfg_rgn_tcfg1_en        (cfg_rgn_tcfg1_en_wire),
    .cfg_rgn_tcfg1_o         (cfg_rgn_tcfg1_o_wire),
    .cfg_rgn_tcfg2_rgn_i     (cfg_rgn_tcfg2_rgn_i_wire),
    .cfg_rgn_tcfg2_en        (cfg_rgn_tcfg2_en_wire),
    .cfg_rgn_tcfg2_o         (cfg_rgn_tcfg2_o_wire),
    .cfg_rgn_mid0_rgn_i      (cfg_rgn_mid0_rgn_i_wire),
    .cfg_rgn_mid0_en         (cfg_rgn_mid0_en_wire),
    .cfg_rgn_mid0_o          (cfg_rgn_mid0_o_wire),
    .cfg_rgn_mid1_rgn_i      (cfg_rgn_mid1_rgn_i_wire),
    .cfg_rgn_mid1_en         (cfg_rgn_mid1_en_wire),
    .cfg_rgn_mid1_o          (cfg_rgn_mid1_o_wire),
    .cfg_rgn_mid2_rgn_i      (cfg_rgn_mid2_rgn_i_wire),
    .cfg_rgn_mid2_en         (cfg_rgn_mid2_en_wire),
    .cfg_rgn_mid2_o          (cfg_rgn_mid2_o_wire),
    .cfg_rgn_mid3_rgn_i      (cfg_rgn_mid3_rgn_i_wire),
    .cfg_rgn_mid3_en         (cfg_rgn_mid3_en_wire),
    .cfg_rgn_mid3_o          (cfg_rgn_mid3_o_wire),
    .cfg_rgn_mpl0_rgn_i      (cfg_rgn_mpl0_rgn_i_wire),
    .cfg_rgn_mpl0_en         (cfg_rgn_mpl0_en_wire),
    .cfg_rgn_mpl0_o          (cfg_rgn_mpl0_o_wire),
    .cfg_rgn_mpl1_rgn_i      (cfg_rgn_mpl1_rgn_i_wire),
    .cfg_rgn_mpl1_en         (cfg_rgn_mpl1_en_wire),
    .cfg_rgn_mpl1_o          (cfg_rgn_mpl1_o_wire),
    .cfg_rgn_mpl2_rgn_i      (cfg_rgn_mpl2_rgn_i_wire),
    .cfg_rgn_mpl2_en         (cfg_rgn_mpl2_en_wire),
    .cfg_rgn_mpl2_o          (cfg_rgn_mpl2_o_wire),
    .cfg_rgn_mpl3_rgn_i      (cfg_rgn_mpl3_rgn_i_wire),
    .cfg_rgn_mpl3_en         (cfg_rgn_mpl3_en_wire),
    .cfg_rgn_mpl3_o          (cfg_rgn_mpl3_o_wire),
    .cfg_fe_tal_i            (cfg_fe_tal_i_wire),
    .cfg_fe_tau_i            (cfg_fe_tau_i_wire),
    .cfg_fe_tp_i             (cfg_fe_tp_i_wire),
    .cfg_fe_mid_i            (cfg_fe_mid_i_wire),
    .cfg_fe_ctrl_i           (cfg_fe_ctrl_i_wire),
    .cfg_fe_ctrl_en          (cfg_fe_ctrl_en_wire),
    .cfg_fe_ctrl_o           (cfg_fe_ctrl_o_wire),
    .cfg_me_ctrl_i           (cfg_me_ctrl_i_wire),
    .cfg_me_ctrl_en          (cfg_me_ctrl_en_wire),
    .cfg_me_ctrl_o           (cfg_me_ctrl_o_wire),
    .cfg_me_st_i             (cfg_me_st_i_wire),
    .cfg_me_st_en            (cfg_me_st_en_wire),
    .cfg_me_st_o             (cfg_me_st_o_wire),
    .cfg_edr_tal_i           (cfg_edr_tal_i_wire),
    .cfg_edr_tal_en          (cfg_edr_tal_en_wire),
    .cfg_edr_tal_o           (cfg_edr_tal_o_wire),
    .cfg_edr_tau_i           (cfg_edr_tau_i_wire),
    .cfg_edr_tau_en          (cfg_edr_tau_en_wire),
    .cfg_edr_tau_o           (cfg_edr_tau_o_wire),
    .cfg_edr_tp_i            (cfg_edr_tp_i_wire),
    .cfg_edr_tp_en           (cfg_edr_tp_en_wire),
    .cfg_edr_tp_o            (cfg_edr_tp_o_wire),
    .cfg_edr_mid_i           (cfg_edr_mid_i_wire),
    .cfg_edr_mid_en          (cfg_edr_mid_en_wire),
    .cfg_edr_mid_o           (cfg_edr_mid_o_wire),
    .cfg_edr_ctrl_i          (cfg_edr_ctrl_i_wire),
    .cfg_edr_ctrl_en         (cfg_edr_ctrl_en_wire),
    .cfg_edr_ctrl_o          (cfg_edr_ctrl_o_wire),
    .cfg_ld_ctrl_i           (cfg_ld_ctrl_i_wire),
    .cfg_ld_ctrl_en          (cfg_ld_ctrl_en_wire),
    .cfg_ld_ctrl_o           (cfg_ld_ctrl_o_wire),
    .cfg_prot_size_en        (cfg_prot_size_en_wire),
    .cfg_prot_size_o         (cfg_prot_size_o_wire),
    .cfg_bypass_i            (cfg_bypass_i_wire)
);

firewall_f0_comp_lpi u_lpi(

  .clk                      (clk),
  .clk_gated                (clk_gated),
  .reset_n                  (reset_n),
  .bypass_syncd             (bypass_syncd),

  .clk_qreqn_i              (clk_qreqn_syncd),
  .clk_qacceptn_o           (clk_qacceptn_o),
  .clk_qdeny_o              (clk_qdeny_o   ),
  .clk_qactive_o            (int_qactive   ),

  .pwr_qreqn_i              (pwr_qreqn_syncd),
  .pwr_qacceptn_o           (pwr_qacceptn_o),
  .pwr_qdeny_o              (pwr_qdeny_o   ),
  .pwr_qactive_o            (pwr_qactive_o ),

  .gate_hold_req_o          (lpi_gate_hold_req_wire),
  .gate_hold_ack_i          (gate_hold_ack_wire),
  .gate_busy_i              (gate_busy_wire | axi_slc_busy_s_wire),

  .rb_pwr_deny_i            (rb_pwr_deny_wire),
  .default_state_o          (default_state_wire),

  .cfg_con_o                (cfg_lpi_con_req_wire),
  .cfg_dis_o                (cfg_lpi_discon_req_wire),
  .cfg_clk_hold_o           (cfg_lpi_clk_hold_wire),
  .cfg_busy_i               (cfg_lpi_busy_wire | bas_qactive),
  .cfg_accept_i             (cfg_lpi_pwr_accept_wire),

  .clk_gate_en              (clk_gate_en),

  .dftcgen                  (dftcgen)
);

firewall_f0_xor2 u_pwr_req (
  .din0 (pwr_qreqn_i),
  .din1 (pwr_qacceptn_o),
  .dout (i_pwr_req)
);

firewall_f0_xor2 u_bps_req (
  .din0 (bypass_i),
  .din1 (bypass_syncd),
  .dout (i_bps_req)
);

firewall_f0_or2 u_qactive_or2_0 (
  .din0 (i_bps_req),
  .din1 (i_pwr_req),
  .dout (i_qactive_0)
);

firewall_f0_or2 u_qactive_or2_1 (
  .din0 (int_qactive),
  .din1 (i_qactive_0),
  .dout (i_qactive_1)
);

firewall_f0_or2 u_qactive_or2_2 (
  .din0 (awakeup_s_i),
  .din1 (twakeup_us_i),
  .dout (i_qactive_2)
);

firewall_f0_or2 u_qactive_or2_3 (
  .din0 (i_qactive_1),
  .din1 (i_qactive_2),
  .dout (clk_qactive_o)
);

firewall_f0_axi_reg_slc #(
    .AW_DIR             (FC_AW_REG_SLC_M    ),
    .W_DIR              (FC_W_REG_SLC_M     ),
    .B_DIR              (FC_B_REG_SLC_M     ),
    .AR_DIR             (FC_AR_REG_SLC_M    ),
    .R_DIR              (FC_R_REG_SLC_M     ),
    .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
    .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
    .FC_AXIUSER_AR_WIDTH(FC_AXIUSER_AR_WIDTH),
    .FC_AXIUSER_AW_WIDTH(FC_AXIUSER_AW_WIDTH),
    .FC_AXIUSER_W_WIDTH (FC_AXIUSER_W_WIDTH ),
    .FC_AXIUSER_B_WIDTH (FC_AXIUSER_B_WIDTH ),
    .FC_AXIUSER_R_WIDTH (FC_AXIUSER_R_WIDTH ),
    .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
    .FC_AXIDATA_WIDTH   (FC_AXIDATA_WIDTH   )
) u_regslice_m (
    .clk       (clk_gated   ),
    .reset_n   (reset_n     ),

    .arid_i    (m_regslc_arid_i    ),
    .araddr_i  (m_regslc_araddr_i  ),
    .arlen_i   (m_regslc_arlen_i   ),
    .arsize_i  (m_regslc_arsize_i  ),
    .arburst_i (m_regslc_arburst_i ),
    .arlock_i  (m_regslc_arlock_i  ),
    .arcache_i (m_regslc_arcache_i ),
    .arprot_i  (m_regslc_arprot_i  ),
    .arqos_i   (m_regslc_arqos_i   ),
    .arregion_i(m_regslc_arregion_i),
    .aruser_i  (m_regslc_aruser_i  ),
    .arvalid_i (m_regslc_arvalid_i ),
    .arready_o (m_regslc_arready_o ),
    .armmusid_i(m_regslc_armmusid_i),

    .awid_i    (m_regslc_awid_i    ),
    .awaddr_i  (m_regslc_awaddr_i  ),
    .awlen_i   (m_regslc_awlen_i   ),
    .awsize_i  (m_regslc_awsize_i  ),
    .awburst_i (m_regslc_awburst_i ),
    .awlock_i  (m_regslc_awlock_i  ),
    .awcache_i (m_regslc_awcache_i ),
    .awprot_i  (m_regslc_awprot_i  ),
    .awqos_i   (m_regslc_awqos_i   ),
    .awregion_i(m_regslc_awregion_i),
    .awuser_i  (m_regslc_awuser_i  ),
    .awvalid_i (m_regslc_awvalid_i ),
    .awready_o (m_regslc_awready_o ),
    .awmmusid_i(m_regslc_awmmusid_i),

    .wdata_i   (m_regslc_wdata_i ),
    .wstrb_i   (m_regslc_wstrb_i ),
    .wlast_i   (m_regslc_wlast_i ),
    .wuser_i   (m_regslc_wuser_i ),
    .wvalid_i  (m_regslc_wvalid_i),
    .wready_o  (m_regslc_wready_o),

    .bid_o     (m_regslc_bid_o   ),
    .bresp_o   (m_regslc_bresp_o ),
    .buser_o   (m_regslc_buser_o ),
    .bvalid_o  (m_regslc_bvalid_o),
    .bready_i  (m_regslc_bready_i),

    .rid_o     (m_regslc_rid_o   ),
    .rdata_o   (m_regslc_rdata_o ),
    .rresp_o   (m_regslc_rresp_o ),
    .rlast_o   (m_regslc_rlast_o ),
    .ruser_o   (m_regslc_ruser_o ),
    .rvalid_o  (m_regslc_rvalid_o),
    .rready_i  (m_regslc_rready_i),

    .awakeup_i (m_regslc_awakeup_i),

    .arid_o    (arid_m_o    ),
    .araddr_o  (araddr_m_o  ),
    .arlen_o   (arlen_m_o   ),
    .arsize_o  (arsize_m_o  ),
    .arburst_o (arburst_m_o ),
    .arlock_o  (arlock_m_o  ),
    .arcache_o (arcache_m_o ),
    .arprot_o  (arprot_m_o  ),
    .arqos_o   (arqos_m_o   ),
    .arregion_o(arregion_m_o),
    .aruser_o  (aruser_m_o  ),
    .arvalid_o (arvalid_m_o ),
    .arready_i (arready_m_i ),
    .armmusid_o(armmusid_m_o),

    .awid_o    (awid_m_o    ),
    .awaddr_o  (awaddr_m_o  ),
    .awlen_o   (awlen_m_o   ),
    .awsize_o  (awsize_m_o  ),
    .awburst_o (awburst_m_o ),
    .awlock_o  (awlock_m_o  ),
    .awcache_o (awcache_m_o ),
    .awprot_o  (awprot_m_o  ),
    .awqos_o   (awqos_m_o   ),
    .awregion_o(awregion_m_o),
    .awuser_o  (awuser_m_o  ),
    .awvalid_o (awvalid_m_o ),
    .awready_i (awready_m_i ),
    .awmmusid_o(awmmusid_m_o),

    .wdata_o   (wdata_m_o   ),
    .wstrb_o   (wstrb_m_o   ),
    .wlast_o   (wlast_m_o   ),
    .wuser_o   (wuser_m_o   ),
    .wvalid_o  (wvalid_m_o  ),
    .wready_i  (wready_m_i  ),

    .bid_i     (bid_m_i     ),
    .bresp_i   (bresp_m_i   ),
    .buser_i   (buser_m_i   ),
    .bvalid_i  (bvalid_m_i  ),
    .bready_o  (bready_m_o  ),

    .rid_i     (rid_m_i     ),
    .rdata_i   (rdata_m_i   ),
    .rresp_i   (rresp_m_i   ),
    .rlast_i   (rlast_m_i   ),
    .ruser_i   (ruser_m_i   ),
    .rvalid_i  (rvalid_m_i  ),
    .rready_o  (rready_m_o  ),

    .awakeup_o (awakeup_m_o ),

    .axi_slc_busy_o (), 
    .gate_hold_req_i (1'b0) 
);

endmodule
