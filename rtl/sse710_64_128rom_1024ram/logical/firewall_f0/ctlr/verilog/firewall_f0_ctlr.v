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

module firewall_f0_ctlr #(
    `include "firewall_f0_ctlr_params.vh"
    ,
    `include "firewall_f0_ctlr_reg_width_params.vh"
    `include "firewall_f0_reg_width_params.vh"
) (
    input  wire                                   clk             ,
    input  wire                                   reset_n         ,

    input  wire                                   dftcgen         ,
    input  wire                                   dftrambyp       ,
    input  wire                                   dftramhold      ,

    input  wire [FC_AXIID_WIDTH-1:0]              arid_s_i        ,
    input  wire [FC_ADDR_WIDTH-1:0]               araddr_s_i      ,
    input  wire [7:0]                             arlen_s_i       ,
    input  wire [2:0]                             arsize_s_i      ,
    input  wire [1:0]                             arburst_s_i     ,
    input  wire                                   arlock_s_i      ,
    input  wire [3:0]                             arcache_s_i     ,
    input  wire [2:0]                             arprot_s_i      ,
    input  wire                                   arvalid_s_i     ,
    output wire                                   arready_s_o     ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_s_i    ,

    input  wire [FC_AXIID_WIDTH-1:0]              awid_s_i        ,
    input  wire [FC_ADDR_WIDTH-1:0]               awaddr_s_i      ,
    input  wire [7:0]                             awlen_s_i       ,
    input  wire [2:0]                             awsize_s_i      ,
    input  wire [1:0]                             awburst_s_i     ,
    input  wire                                   awlock_s_i      ,
    input  wire [3:0]                             awcache_s_i     ,
    input  wire [2:0]                             awprot_s_i      ,
    input  wire                                   awvalid_s_i     ,
    output wire                                   awready_s_o     ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i    ,

    input  wire [31:0]                            wdata_s_i       ,
    input  wire [3:0]                             wstrb_s_i       ,
    input  wire                                   wlast_s_i       ,
    input  wire                                   wvalid_s_i      ,
    output wire                                   wready_s_o      ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_s_o         ,
    output wire [1:0]                             bresp_s_o       ,
    output wire                                   buser_s_o       ,
    output wire                                   bvalid_s_o      ,
    input  wire                                   bready_s_i      ,

    output wire [FC_AXIID_WIDTH-1:0]              rid_s_o         ,
    output wire [31:0]                            rdata_s_o       ,
    output wire [1:0]                             rresp_s_o       ,
    output wire                                   rlast_s_o       ,
    output wire                                   ruser_s_o       ,
    output wire                                   rvalid_s_o      ,
    input  wire                                   rready_s_i      ,

    input  wire                                   awakeup_s_i     ,

    input  wire                                   tvalid_ds_i     ,
    output wire                                   tready_ds_o     ,
    input  wire [31:0]                            tdata_ds_i      ,
    input  wire [3:0]                             tkeep_ds_i      ,
    input  wire                                   tlast_ds_i      ,
    input  wire [LOG2_FW_NUM_FC-1:0]              tid_ds_i        ,
    input  wire                                   twakeup_ds_i    ,

    output wire                                   tvalid_us_o     ,
    input  wire                                   tready_us_i     ,
    output wire [31:0]                            tdata_us_o      ,
    output wire [3:0]                             tkeep_us_o      ,
    output wire                                   tlast_us_o      ,
    output wire [LOG2_FW_NUM_FC-1:0]              tdest_us_o      ,
    output wire                                   twakeup_us_o    ,

    input  wire                                   clk_qreqn_i     ,
    output wire                                   clk_qacceptn_o  ,
    output wire                                   clk_qdeny_o     ,
    output wire                                   clk_qactive_o   ,

    input  wire                                   pwr_preq_i      ,
    output wire                                   pwr_paccept_o   ,
    output wire                                   pwr_pdeny_o     ,
    output wire [10:0]                            pwr_pactive_o   ,
    input  wire [3:0]                             pwr_pstate_i    ,

    input  wire                                   lockdown_i        ,
    output wire                                   interrupt_o       ,
    output wire                                   tamper_interrupt_o,
    input  wire  [FW_NUM_FC*8-1:0]                protsize_i,
    input  wire                                   bypass_i
);


`include "firewall_f0_ctlr_localparams.vh"

localparam FC_PE_LVL_RSTR     = FC_PE_LVL_EXT;
localparam FC_MXRS_RSTR       = FC_MXRS_EXT;
localparam FC_RSE_LVL_RSTR    = FC_RSE_LVL_EXT;
localparam FC_TE_LVL_RSTR     = FC_TE_LVL_EXT;
localparam FC_NUM_MPE_RSTR    = FC_NUM_MPE_EXT;
localparam FC_SINGLE_MST_RSTR = FC_SINGLE_MST_EXT;
localparam FC_ME_LVL_RSTR     = FC_ME_LVL_EXT;
localparam FC_INST_SPT_RSTR   = FC_INST_SPT_EXT;
localparam FC_MA_SPT_RSTR     = FC_MA_SPT_EXT;
localparam FC_SEC_SPT_RSTR    = FC_SEC_SPT_EXT;
localparam FC_PRIV_SPT_RSTR   = FC_PRIV_SPT_EXT;
localparam FC_SH_SPT_RSTR     = FC_SH_SPT_EXT;
localparam FC_NUM_RGN_RSTR    = FC_NUM_RGN_EXT;
localparam FC_ID_RSTR         = FC_ID;
localparam RGN_MID0_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID1_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID2_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID3_WIDTH     = FW_MAX_MST_ID_WIDTH;

`include "firewall_f0_reg_exists_localparams.vh"
`include "firewall_f0_sram_reg_lut_localparams.vh"

localparam LOG2_SRAM_SIZE = LOG2_RESTORE_SIZE;

localparam FW_ID_WIDTH = firewall_f0_log2(FW_NUM_FC+1);

localparam FW_TMP_TA_ADDR   = 12'hE90;
localparam FW_TMP_TP_ADDR   = 12'hE98;
localparam FW_TMP_MID_ADDR  = 12'hE9C;
localparam FW_TMP_CTRL_ADDR = 12'hEA0;


wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_i_int;
wire                                        fw_ctrl_en_int;
wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_o_int;

wire [FW_ST_WIDTH-1:0]                      fw_st_o_int;

wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_i_int;
wire                                        fw_sr_ctrl_en_int;
wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_o_int;

wire [PE_BPS_WIDTH-1:0]                     pe_bps_o_int;

wire [((FW_NUM_FC+1)*LD_CTRL_WIDTH)-1:0]    ld_ctrl_i_int;
wire [FW_NUM_FC:0]                          ld_ctrl_en_int;
wire [((FW_NUM_FC+1)*LD_CTRL_WIDTH)-1:0]    ld_ctrl_o_int;

wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_i_int;
wire                                        pe_ctrl_en_int;
wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_o_int;

wire [PE_ST_WIDTH-1:0]                      pe_st_o_int;

wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_i_int;
wire                                        rwe_ctrl_en_int;
wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_o_int;

wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     rgn_ctrl0_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_ctrl0_en_int;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     rgn_ctrl0_o_int;
wire [RGN_CTRL0_WIDTH-1:0]                  rgn_ctrl0_rgn_o_int;

wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     rgn_ctrl1_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_ctrl1_en_int;
wire [RGN_CTRL1_WIDTH-1:0]                  rgn_ctrl1_rgn_o_int;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     rgn_ctrl1_o_int;

wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     rgn_lctrl_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_lctrl_en_int;
wire [RGN_LCTRL_WIDTH-1:0]                  rgn_lctrl_rgn_o_int;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     rgn_lctrl_o_int;

wire [RGN_ST_WIDTH-1:0]                     rgn_st_rgn_o_int;
wire [(FC_NUM_RGN*RGN_ST_WIDTH)-1:0]        rgn_st_o_int;

wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      rgn_cfg0_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_cfg0_en_int;
wire [RGN_CFG0_WIDTH-1:0]                   rgn_cfg0_rgn_o_int;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      rgn_cfg0_o_int;

wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      rgn_cfg1_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_cfg1_en_int;
wire [RGN_CFG1_WIDTH-1:0]                   rgn_cfg1_rgn_o_int;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      rgn_cfg1_o_int;

wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      rgn_size_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_size_en_int;
wire [RGN_SIZE_WIDTH-1:0]                   rgn_size_rgn_o_int;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      rgn_size_o_int;

wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg0_en_int;
wire [RGN_TCFG0_WIDTH-1:0]                  rgn_tcfg0_rgn_o_int;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_o_int;

wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg1_en_int;
wire [RGN_TCFG1_WIDTH-1:0]                  rgn_tcfg1_rgn_o_int;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_o_int;

wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg2_en_int;
wire [RGN_TCFG2_WIDTH-1:0]                  rgn_tcfg2_rgn_o_int;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_o_int;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid0_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mid0_en_int;
wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid0_rgn_o_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid0_o_int;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid1_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mid1_en_int;
wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid1_rgn_o_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid1_o_int;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid2_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mid2_en_int;
wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid2_rgn_o_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid2_o_int;

wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid3_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mid3_en_int;
wire [FC_MST_ID_WIDTH-1:0]                  rgn_mid3_rgn_o_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid3_o_int;

wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      rgn_mpl0_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mpl0_en_int;
wire [RGN_MPL0_WIDTH-1:0]                   rgn_mpl0_rgn_o_int;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      rgn_mpl0_o_int;

wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      rgn_mpl1_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mpl1_en_int;
wire [RGN_MPL1_WIDTH-1:0]                   rgn_mpl1_rgn_o_int;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      rgn_mpl1_o_int;

wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      rgn_mpl2_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mpl2_en_int;
wire [RGN_MPL2_WIDTH-1:0]                   rgn_mpl2_rgn_o_int;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      rgn_mpl2_o_int;

wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      rgn_mpl3_i_int;
wire [FC_NUM_RGN-1:0]                       rgn_mpl3_en_int;
wire [RGN_MPL3_WIDTH-1:0]                   rgn_mpl3_rgn_o_int;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      rgn_mpl3_o_int;

wire [FE_TAL_WIDTH-1:0]                     fe_tal_o_int;

wire [FE_TAU_WIDTH-1:0]                     fe_tau_o_int;

wire [FE_TP_WIDTH-1:0]                      fe_tp_o_int;

wire [FC_MST_ID_WIDTH-1:0]                  fe_mid_o_int;

wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_i_int;
wire                                        fe_ctrl_en_int;
wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_o_int;

wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_i_int;
wire                                        me_ctrl_en_int;
wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_o_int;

wire [ME_ST_WIDTH-1:0]                      me_st_o_int;

wire [EDR_TAL_WIDTH-1:0]                    edr_tal_o_int;

wire [EDR_TAU_WIDTH-1:0]                    edr_tau_o_int;

wire [EDR_TP_WIDTH-1:0]                     edr_tp_o_int;

wire [FC_MST_ID_WIDTH-1:0]                  edr_mid_o_int;

wire [EDR_CTRL_WIDTH-1:0]                   edr_ctrl_i_int;
wire                                        edr_ctrl_en_int;
wire [EDR_CTRL_WIDTH-1:0]                   edr_ctrl_o_int;

wire [(32*FC_INT_ST_WIDTH)-1:0]             fc_int_st_i_int;
wire [31:0]                                 fc_int_st_en_int;
wire [(32*FC_INT_ST_WIDTH)-1:0]             fc_int_st_o_int;

wire [(32*FC_INT_MSK_WIDTH)-1:0]            fc_int_msk_i_int;
wire [31:0]                                 fc_int_msk_en_int;
wire [(32*FC_INT_MSK_WIDTH)-1:0]            fc_int_msk_o_int;

wire [FW_TMP_TA_WIDTH-1:0]                  fw_tmp_ta_o_int;

wire [FW_TMP_TP_WIDTH-1:0]                  fw_tmp_tp_o_int;

wire [FC_MST_ID_WIDTH-1:0]                  fw_tmp_mid_o_int;

wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_i_int;
wire                                        fw_tmp_ctrl_en_int;
wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_o_int;

wire [FW_INT_ST_WIDTH-1:0]                  fw_int_st_o_int;

wire [((FW_NUM_FC+1)*FC_CAP0_WIDTH)-1:0]    fc_cap0_o_int;

wire [((FW_NUM_FC+1)*FC_CFG0_WIDTH)-1:0]    fc_cfg0_o_int;

wire [((FW_NUM_FC+1)*FC_CFG1_WIDTH)-1:0]    fc_cfg1_o_int;

wire [((FW_NUM_FC+1)*FC_CFG2_WIDTH)-1:0]    fc_cfg2_o_int;

wire [(FC_CFG3_WIDTH)-1:0]                  fc_cfg3_o_int;

wire [IIDR_WIDTH-1:0]                       iidr_o_int;

wire [AIDR_WIDTH-1:0]                       aidr_o_int;

wire                                        cfg_restore_done_int;
wire                                        cfg_sram_init_done_int;

wire [FW_NUM_FC-1:0]                        cfg_pwr_st_o_int;
wire [FW_NUM_FC-1:0]                        cfg_pwr_st_ctrl_o_int;
wire [FW_NUM_FC-1:0]                        cfg_pwr_st_en_o_int;
wire [FW_NUM_FC-1:0]                        cfg_pwr_st_i_int;

wire                                        cfg_irq_req_int;
wire [IRQ_TYPE_WIDTH-1:0]                   cfg_irq_type_int;
wire [LOG2_FW_NUM_FC-1:0]                   cfg_irq_fw_id_int;

wire [LOG2_SRAM_SIZE-1:0]                   sram_addr_int;
wire                                        sram_cenn_int;
wire                                        sram_wenn_int;
wire [SRAM_WIDTH-1:0]                       sram_data_i_int;
wire [SRAM_WIDTH-1:0]                       sram_data_o_int;

wire [FC_MST_ID_WIDTH-1:0]                  pe_cfg_r_mst_id_i_wire;
wire [FC_MST_ID_WIDTH-1:0]                  pe_cfg_w_mst_id_i_wire;
wire [FC_MST_ID_WIDTH-1:0]                  pe_cfg_r_mst_id_o_wire;
wire [FE_TAL_WIDTH-1:0]                     fe_tal_rdch_int;
wire [FE_TAU_WIDTH-1:0]                     fe_tau_rdch_int;
wire [FE_TP_WIDTH-1:0]                      fe_tp_rdch_int ;
wire [FC_MST_ID_WIDTH-1:0]                  fe_mid_rdch_int;
wire [FE_TAL_WIDTH-1:0]                     fe_tal_wrch_int;
wire [FE_TAU_WIDTH-1:0]                     fe_tau_wrch_int;
wire [FE_TP_WIDTH-1:0]                      fe_tp_wrch_int ;
wire [FC_MST_ID_WIDTH-1:0]                  fe_mid_wrch_int;
wire [(FC_NUM_RGN*FC_MXRS)-1:0]             fctlr_base_addr_o_int;
wire [(FC_NUM_RGN*FC_MXRS)-1:0]             fctlr_upr_addr_o_int ;
wire                                        tamper_cfg_o_int   ;
wire                                        tamper_cfg_w_o_int   ;
wire [FW_NUM_FC*8-1:0]                      fw_prot_size_o_int   ; 
wire [IRQ_TYPE_WIDTH-1:0]                   cfg_irq_o_int;

wire fe_type_wrch_int;
wire fe_wrch_en_int;
wire fe_type_rdch_int;
wire fe_rdch_en_int;
wire rb_tmp_reg_err_rd_int;
wire rb_tmp_reg_err_wr_int;
wire [PID0_WIDTH-1:0] fw_pid0_o_int;
wire [PID1_WIDTH-1:0] fw_pid1_o_int;
wire [PID2_WIDTH-1:0] fw_pid2_o_int;
wire [PID3_WIDTH-1:0] fw_pid3_o_int;
wire [PID4_WIDTH-1:0] fw_pid4_o_int;

wire [CID0_WIDTH-1:0] fw_cid0_o_int;
wire [CID1_WIDTH-1:0] fw_cid1_o_int;
wire [CID2_WIDTH-1:0] fw_cid2_o_int;
wire [CID3_WIDTH-1:0] fw_cid3_o_int;

wire rb_prot_en_o_int;
wire rb_pwr_deny_int;

wire default_state_wire;

wire cfg_lpi_hold_o_int;
wire cfg_lpi_ram_req_o_int;
wire cfg_lpi_ram_ack_int;
wire cfg_lpi_ram_init_int;

wire cfg_gate_bas_int;

wire cfg_lpi_clk_busy_i_int;
wire pe_cfg_awakeup_wire;
wire bas_qactive;

wire cfg_busy_int = cfg_lpi_clk_busy_i_int || pe_cfg_awakeup_wire ||
   bas_qactive;

wire                           axi_slc_busy_s_wire;
wire [FC_AXIID_WIDTH-1:0]      pe_cfg_arid_wire;
wire [REG_ADDR_WIDTH-1:0]      pe_cfg_araddr_wire;
wire                           pe_cfg_arvalid_wire;
wire                           pe_cfg_arready_wire;
wire [FC_AXIID_WIDTH-1:0]      pe_cfg_awid_wire;
wire [REG_ADDR_WIDTH-1:0]      pe_cfg_awaddr_wire;
wire                           pe_cfg_awvalid_wire;
wire                           pe_cfg_awready_wire;
wire [REG_DATA_WIDTH-1:0]      pe_cfg_wdata_wire;
wire                           pe_cfg_wvalid_wire;
wire                           pe_cfg_wready_wire;
wire [FC_AXIID_WIDTH-1:0]      pe_cfg_bid_wire;
wire [1:0]                     pe_cfg_bresp_wire;
wire [FC_AXIUSER_B_WIDTH-1:0]  pe_cfg_buser_wire;
wire                           pe_cfg_bvalid_wire;
wire                           pe_cfg_bready_wire;
wire [FC_AXIID_WIDTH-1:0]      pe_cfg_rid_wire;
wire [REG_DATA_WIDTH-1:0]      pe_cfg_rdata_wire;
wire [1:0]                     pe_cfg_rresp_wire;
wire                           pe_cfg_rlast_wire;
wire [FC_AXIUSER_R_WIDTH-1:0]  pe_cfg_ruser_wire;
wire                           pe_cfg_rvalid_wire;
wire                           pe_cfg_rready_wire;
wire [FW_ID_WIDTH-1:0]         pe_cfg_w_fw_id_wire;
wire [FW_ID_WIDTH-1:0]         pe_cfg_r_fw_id_wire;
wire [REG_ENUM_WIDTH-1:0]      pe_cfg_enum_w_addr;
wire [REG_ENUM_WIDTH-1:0]      pe_cfg_enum_r_addr;

wire [FC_AXIID_WIDTH-1:0]        gate_dp_arid_wire;
wire [FC_ADDR_WIDTH-1:0]         gate_dp_araddr_wire;
wire [7:0]                       gate_dp_arlen_wire;
wire [2:0]                       gate_dp_arsize_wire;
wire [1:0]                       gate_dp_arburst_wire;
wire                             gate_dp_arlock_wire;
wire [3:0]                       gate_dp_arcache_wire;
wire [2:0]                       gate_dp_arprot_wire;
wire [3:0]                       gate_dp_arqos_wire;
wire [3:0]                       gate_dp_arregion_wire;
wire                             gate_dp_arvalid_wire;
wire                             gate_dp_arready_wire;
wire [FC_MST_ID_WIDTH-1:0]       gate_dp_armmusid_wire;

wire [FC_AXIID_WIDTH-1:0]        gate_dp_awid_wire;
wire [FC_ADDR_WIDTH-1:0]         gate_dp_awaddr_wire;
wire [7:0]                       gate_dp_awlen_wire;
wire [2:0]                       gate_dp_awsize_wire;
wire [1:0]                       gate_dp_awburst_wire;
wire                             gate_dp_awlock_wire;
wire [3:0]                       gate_dp_awcache_wire;
wire [2:0]                       gate_dp_awprot_wire;
wire [3:0]                       gate_dp_awqos_wire;
wire [3:0]                       gate_dp_awregion_wire;
wire                             gate_dp_awvalid_wire;
wire                             gate_dp_awready_wire;
wire [FC_MST_ID_WIDTH-1:0]       gate_dp_awmmusid_wire;

wire [FC_AXIDATA_WIDTH-1:0]      gate_dp_wdata_wire;
wire [FC_AXIDATA_WIDTH/8-1:0]    gate_dp_wstrb_wire;
wire                             gate_dp_wlast_wire;
wire                             gate_dp_wvalid_wire;
wire                             gate_dp_wready_wire;

wire [FC_AXIID_WIDTH-1:0]        gate_dp_bid_wire;
wire [1:0]                       gate_dp_bresp_wire;
wire [FC_AXIUSER_B_WIDTH-1:0]    gate_dp_buser_wire;
wire                             gate_dp_bvalid_wire;
wire                             gate_dp_bready_wire;

wire [FC_AXIID_WIDTH-1:0]        gate_dp_rid_wire;
wire [FC_AXIDATA_WIDTH-1:0]      gate_dp_rdata_wire;
wire [1:0]                       gate_dp_rresp_wire;
wire                             gate_dp_rlast_wire;
wire [FC_AXIUSER_R_WIDTH-1:0]    gate_dp_ruser_wire;
wire                             gate_dp_rvalid_wire;
wire                             gate_dp_rready_wire;

wire                             gate_dp_awakeup_wire;

wire                             rb_dp_write_tamp_i;
wire                             rb_dp_read_tamp_i;

wire [FC_AXIID_WIDTH-1:0]     s_regslc_arid_o;
wire [FC_ADDR_WIDTH-1:0]      s_regslc_araddr_o;
wire [7:0]                    s_regslc_arlen_o;
wire [2:0]                    s_regslc_arsize_o;
wire [1:0]                    s_regslc_arburst_o;
wire                          s_regslc_arlock_o;
wire [3:0]                    s_regslc_arcache_o;
wire [2:0]                    s_regslc_arprot_o;
wire [3:0]                    s_regslc_arqos_o;
wire [3:0]                    s_regslc_arregion_o;
wire                          s_regslc_arvalid_o;
wire                          s_regslc_arready_i;
wire [FC_MST_ID_WIDTH-1:0]    s_regslc_armmusid_o;
wire [FC_AXIID_WIDTH-1:0]     s_regslc_awid_o;
wire [FC_ADDR_WIDTH-1:0]      s_regslc_awaddr_o;
wire [7:0]                    s_regslc_awlen_o;
wire [2:0]                    s_regslc_awsize_o;
wire [1:0]                    s_regslc_awburst_o;
wire                          s_regslc_awlock_o;
wire [3:0]                    s_regslc_awcache_o;
wire [2:0]                    s_regslc_awprot_o;
wire [3:0]                    s_regslc_awqos_o;
wire [3:0]                    s_regslc_awregion_o;
wire                          s_regslc_awvalid_o;
wire                          s_regslc_awready_i;
wire [FC_MST_ID_WIDTH-1:0]    s_regslc_awmmusid_o;
wire [FC_AXIDATA_WIDTH-1:0]   s_regslc_wdata_o;
wire [FC_AXIDATA_WIDTH/8-1:0] s_regslc_wstrb_o;
wire                          s_regslc_wlast_o;
wire                          s_regslc_wvalid_o;
wire                          s_regslc_wready_i;
wire [FC_AXIID_WIDTH-1:0]     s_regslc_bid_i;
wire [1:0]                    s_regslc_bresp_i;
wire [FC_AXIUSER_B_WIDTH-1:0] s_regslc_buser_i;
wire                          s_regslc_bvalid_i;
wire                          s_regslc_bready_o;
wire [FC_AXIID_WIDTH-1:0]     s_regslc_rid_i;
wire [FC_AXIDATA_WIDTH-1:0]   s_regslc_rdata_i;
wire [1:0]                    s_regslc_rresp_i;
wire                          s_regslc_rlast_i;
wire [FC_AXIUSER_R_WIDTH-1:0] s_regslc_ruser_i;
wire                          s_regslc_rvalid_i;
wire                          s_regslc_rready_o;
wire                          s_regslc_awakeup_o;

wire                         tvalid_ds_int;
wire                         tready_ds_int;
wire [FC_CFG_DATA_W-1:0]     tdata_ds_int;
wire [(FC_CFG_DATA_W/8)-1:0] tkeep_ds_int;
wire                         tlast_ds_int;
wire [LOG2_FW_NUM_FC-1:0]    tid_ds_int;
wire                         twakeup_ds_int;
wire                         tvalid_us_int;
wire                         tready_us_int;
wire [FC_CFG_DATA_W-1:0]     tdata_us_int;
wire [(FC_CFG_DATA_W/8)-1:0] tkeep_us_int;
wire                         tlast_us_int;
wire [LOG2_FW_NUM_FC-1:0]    tdest_us_int;
wire                         twakeup_us_int;

wire       bypass_syncd;
wire       lockdown_syncd;
wire       clk_qreqn_syncd;
wire       pwr_preq_syncd;
wire [3:0] pwr_pstate_syncd;

 wire gate_hold_req_lpi_wire;
 wire gate_hold_ack_wire;
 wire gate_busy_wire;

 wire gate_hold_req_wire;

 wire clk_gated;
 wire clk_gate_en;
 wire ctrl_st_xfer_req_wire;

 wire i_bps_req;
 wire int_qactive;
 wire i_qactive_0;
 wire i_qactive_1;
 wire i_qactive_2;

 wire tinit_delay;
 reg  pwr_preq_ss_r;

genvar i;

 assign gate_hold_req_wire = gate_hold_req_lpi_wire;

wire [(FW_NUM_FC+1)*8-1:0] dp_prot_size_wire;
assign dp_prot_size_wire = {fw_prot_size_o_int, {8{1'b0}}};


firewall_f0_cdc_capt_sync u_bypass_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (bypass_i),
    .q       (bypass_syncd)
);

firewall_f0_cdc_capt_sync u_lockdown_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (lockdown_i),
    .q       (lockdown_syncd)
);

firewall_f0_cdc_capt_sync u_qreqn_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (clk_qreqn_i),
    .q       (clk_qreqn_syncd)
);

firewall_f0_cdc_capt_sync u_preq_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (pwr_preq_i),
    .q       (pwr_preq_syncd)
);

firewall_f0_cdc_capt_sync u_tinit_cdc_capt_sync (
    .clk     (clk),
    .nreset  (reset_n),
    .d_async (1'b1),
    .q       (tinit_delay)
);

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n)
    pwr_preq_ss_r <= 1'b0;
  else
    pwr_preq_ss_r <= pwr_preq_syncd;
end

firewall_f0_cdc_capt_nosync_cg #(
    .IH (3),
    .IL (0)
) u_pstate_cdc_capt_nosync (
    .clk     (clk),
    .nreset  (reset_n),
    .en      (pwr_preq_syncd | ~tinit_delay),
    .d_async (pwr_pstate_i),
    .q       (pwr_pstate_syncd),
    .dftcgen (dftcgen)
);

firewall_f0_clock_gate u_ctlr_cg (
    .clk_in  (clk          ),
    .enable  (clk_gate_en  ),
    .clk_out (clk_gated    ),
    .dftcgen (dftcgen      )
);

firewall_f0_axi_reg_slc #(
    .AW_DIR              (FC_AW_REG_SLC_S    ),
    .W_DIR               (FC_W_REG_SLC_S     ),
    .B_DIR               (FC_B_REG_SLC_S     ),
    .AR_DIR              (FC_AR_REG_SLC_S    ),
    .R_DIR               (FC_R_REG_SLC_S     ),
    .FC_AXIID_WIDTH      (FC_AXIID_WIDTH     ),
    .FC_ADDR_WIDTH       (FC_ADDR_WIDTH      ),
    .FC_AXIUSER_AR_WIDTH (1                  ),
    .FC_AXIUSER_AW_WIDTH (1                  ),
    .FC_AXIUSER_W_WIDTH  (1                  ),
    .FC_AXIUSER_B_WIDTH  (FC_AXIUSER_B_WIDTH ),
    .FC_AXIUSER_R_WIDTH  (FC_AXIUSER_R_WIDTH ),
    .FC_MST_ID_WIDTH     (FC_MST_ID_WIDTH    ),
    .FC_AXIDATA_WIDTH    (FC_AXIDATA_WIDTH   )
) u_regslice_s (
    .clk             (clk_gated   ),
    .reset_n         (reset_n     ),

    .arid_i          (arid_s_i    ),
    .araddr_i        (araddr_s_i  ),
    .arlen_i         (arlen_s_i   ),
    .arsize_i        (arsize_s_i  ),
    .arburst_i       (arburst_s_i ),
    .arlock_i        (arlock_s_i  ),
    .arcache_i       (arcache_s_i ),
    .arprot_i        (arprot_s_i  ),
    .arqos_i         (4'b0000     ),
    .arregion_i      (4'b0000     ),
    .aruser_i        (1'b0        ),
    .arvalid_i       (arvalid_s_i ),
    .arready_o       (arready_s_o ),
    .armmusid_i      (armmusid_s_i),

    .awid_i          (awid_s_i    ),
    .awaddr_i        (awaddr_s_i  ),
    .awlen_i         (awlen_s_i   ),
    .awsize_i        (awsize_s_i  ),
    .awburst_i       (awburst_s_i ),
    .awlock_i        (awlock_s_i  ),
    .awcache_i       (awcache_s_i ),
    .awprot_i        (awprot_s_i  ),
    .awqos_i         (4'b0000     ),
    .awregion_i      (4'b0000     ),
    .awuser_i        (1'b0        ),
    .awvalid_i       (awvalid_s_i ),
    .awready_o       (awready_s_o ),
    .awmmusid_i      (awmmusid_s_i),

    .wdata_i         (wdata_s_i ),
    .wstrb_i         (wstrb_s_i ),
    .wlast_i         (wlast_s_i ),
    .wuser_i         (1'b0      ),
    .wvalid_i        (wvalid_s_i),
    .wready_o        (wready_s_o),

    .bid_o           (bid_s_o   ),
    .bresp_o         (bresp_s_o ),
    .buser_o         (buser_s_o ),
    .bvalid_o        (bvalid_s_o),
    .bready_i        (bready_s_i),

    .rid_o           (rid_s_o   ),
    .rdata_o         (rdata_s_o ),
    .rresp_o         (rresp_s_o ),
    .rlast_o         (rlast_s_o ),
    .ruser_o         (ruser_s_o ),
    .rvalid_o        (rvalid_s_o),
    .rready_i        (rready_s_i),

    .awakeup_i       (awakeup_s_i),

    .arid_o          (s_regslc_arid_o    ),
    .araddr_o        (s_regslc_araddr_o  ),
    .arlen_o         (s_regslc_arlen_o   ),
    .arsize_o        (s_regslc_arsize_o  ),
    .arburst_o       (s_regslc_arburst_o ),
    .arlock_o        (s_regslc_arlock_o  ),
    .arcache_o       (s_regslc_arcache_o ),
    .arprot_o        (s_regslc_arprot_o  ),
    .arqos_o         (                   ), 
    .arregion_o      (                   ), 
    .aruser_o        (                   ), 
    .arvalid_o       (s_regslc_arvalid_o ),
    .arready_i       (s_regslc_arready_i ),
    .armmusid_o      (s_regslc_armmusid_o),

    .awid_o          (s_regslc_awid_o    ),
    .awaddr_o        (s_regslc_awaddr_o  ),
    .awlen_o         (s_regslc_awlen_o   ),
    .awsize_o        (s_regslc_awsize_o  ),
    .awburst_o       (s_regslc_awburst_o ),
    .awlock_o        (s_regslc_awlock_o  ),
    .awcache_o       (s_regslc_awcache_o ),
    .awprot_o        (s_regslc_awprot_o  ),
    .awqos_o         (                   ), 
    .awregion_o      (                   ), 
    .awuser_o        (                   ), 
    .awvalid_o       (s_regslc_awvalid_o ),
    .awready_i       (s_regslc_awready_i ),
    .awmmusid_o      (s_regslc_awmmusid_o),

    .wdata_o         (s_regslc_wdata_o ),
    .wstrb_o         (s_regslc_wstrb_o ),
    .wlast_o         (s_regslc_wlast_o ),
    .wuser_o         (                 ), 
    .wvalid_o        (s_regslc_wvalid_o),
    .wready_i        (s_regslc_wready_i),

    .bid_i           (s_regslc_bid_i   ),
    .bresp_i         (s_regslc_bresp_i ),
    .buser_i         (s_regslc_buser_i ),
    .bvalid_i        (s_regslc_bvalid_i),
    .bready_o        (s_regslc_bready_o),

    .rid_i           (s_regslc_rid_i   ),
    .rdata_i         (s_regslc_rdata_i ),
    .rresp_i         (s_regslc_rresp_i ),
    .rlast_i         (s_regslc_rlast_i ),
    .ruser_i         (s_regslc_ruser_i ),
    .rvalid_i        (s_regslc_rvalid_i),
    .rready_o        (s_regslc_rready_o),

    .awakeup_o       (s_regslc_awakeup_o),
    .axi_slc_busy_o  (axi_slc_busy_s_wire),
    .gate_hold_req_i (gate_hold_req_wire)
);


firewall_f0_comp_gate #(
  .FC_ME_LVL                (FC_ME_LVL[1:0]     ),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH      ),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH   ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH    ),
  .FC_NUM_READ_OS           (FC_NUM_READ_OS     ),
  .FC_NUM_WRITE_OS          (FC_NUM_WRITE_OS    ),
  .FC_AXIUSER_AR_WIDTH      (1                  ),
  .FC_AXIUSER_AW_WIDTH      (1                  ),
  .FC_AXIUSER_W_WIDTH       (1                  ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH ),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH ),
  .TRACKER_PAYLOAD_WIDTH_AR (1                  ),
  .TRACKER_PAYLOAD_WIDTH_AW (1                  )
) u_ctlr_gate (
    .clk                      (clk_gated            ),
    .reset_n                  (reset_n              ),

    .arid_s_i                 (s_regslc_arid_o      ),
    .araddr_s_i               (s_regslc_araddr_o    ),
    .arlen_s_i                (s_regslc_arlen_o     ),
    .arsize_s_i               (s_regslc_arsize_o    ),
    .arburst_s_i              (s_regslc_arburst_o   ),
    .arlock_s_i               (s_regslc_arlock_o    ),
    .arcache_s_i              (s_regslc_arcache_o   ),
    .arprot_s_i               (s_regslc_arprot_o    ),
    .arqos_s_i                (4'b0000              ),
    .arregion_s_i             (4'b0000              ),
    .aruser_s_i               (1'b0                 ),
    .arvalid_s_i              (s_regslc_arvalid_o   ),
    .arready_s_o              (s_regslc_arready_i   ),
    .armmusid_s_i             (s_regslc_armmusid_o  ),

    .awid_s_i                 (s_regslc_awid_o      ),
    .awaddr_s_i               (s_regslc_awaddr_o    ),
    .awlen_s_i                (s_regslc_awlen_o     ),
    .awsize_s_i               (s_regslc_awsize_o    ),
    .awburst_s_i              (s_regslc_awburst_o   ),
    .awlock_s_i               (s_regslc_awlock_o    ),
    .awcache_s_i              (s_regslc_awcache_o   ),
    .awprot_s_i               (s_regslc_awprot_o    ),
    .awqos_s_i                (4'b0000              ),
    .awregion_s_i             (4'b0000              ),
    .awuser_s_i               (1'b0                 ),
    .awvalid_s_i              (s_regslc_awvalid_o   ),
    .awready_s_o              (s_regslc_awready_i   ),
    .awmmusid_s_i             (s_regslc_awmmusid_o  ),

    .wdata_s_i                (s_regslc_wdata_o     ),
    .wstrb_s_i                (s_regslc_wstrb_o     ),
    .wlast_s_i                (s_regslc_wlast_o     ),
    .wuser_s_i                (1'b0                 ),
    .wvalid_s_i               (s_regslc_wvalid_o    ),
    .wready_s_o               (s_regslc_wready_i    ),

    .bid_s_o                  (s_regslc_bid_i       ),
    .bresp_s_o                (s_regslc_bresp_i     ),
    .buser_s_o                (s_regslc_buser_i     ),
    .bvalid_s_o               (s_regslc_bvalid_i    ),
    .bready_s_i               (s_regslc_bready_o    ),

    .rid_s_o                  (s_regslc_rid_i       ),
    .rdata_s_o                (s_regslc_rdata_i     ),
    .rresp_s_o                (s_regslc_rresp_i     ),
    .rlast_s_o                (s_regslc_rlast_i     ),
    .ruser_s_o                (s_regslc_ruser_i     ),
    .rvalid_s_o               (s_regslc_rvalid_i    ),
    .rready_s_i               (s_regslc_rready_o    ),

    .awakeup_s_i              (s_regslc_awakeup_o   ),

    .arid_m_o                 (gate_dp_arid_wire    ),
    .araddr_m_o               (gate_dp_araddr_wire  ),
    .arlen_m_o                (gate_dp_arlen_wire   ),
    .arsize_m_o               (gate_dp_arsize_wire  ),
    .arburst_m_o              (gate_dp_arburst_wire ),
    .arlock_m_o               (gate_dp_arlock_wire  ),
    .arcache_m_o              (gate_dp_arcache_wire ),
    .arprot_m_o               (gate_dp_arprot_wire  ),
    .arqos_m_o                (gate_dp_arqos_wire   ),
    .arregion_m_o             (gate_dp_arregion_wire),
    .aruser_m_o               (                     ),
    .arvalid_m_o              (gate_dp_arvalid_wire ),
    .arready_m_i              (gate_dp_arready_wire ),
    .armmusid_m_o             (gate_dp_armmusid_wire),

    .awid_m_o                 (gate_dp_awid_wire    ),
    .awaddr_m_o               (gate_dp_awaddr_wire  ),
    .awlen_m_o                (gate_dp_awlen_wire   ),
    .awsize_m_o               (gate_dp_awsize_wire  ),
    .awburst_m_o              (gate_dp_awburst_wire ),
    .awlock_m_o               (gate_dp_awlock_wire  ),
    .awcache_m_o              (gate_dp_awcache_wire ),
    .awprot_m_o               (gate_dp_awprot_wire  ),
    .awqos_m_o                (gate_dp_awqos_wire   ),
    .awregion_m_o             (gate_dp_awregion_wire),
    .awuser_m_o               (                     ),
    .awvalid_m_o              (gate_dp_awvalid_wire ),
    .awready_m_i              (gate_dp_awready_wire ),
    .awmmusid_m_o             (gate_dp_awmmusid_wire),

    .wdata_m_o                (gate_dp_wdata_wire   ),
    .wstrb_m_o                (gate_dp_wstrb_wire   ),
    .wlast_m_o                (gate_dp_wlast_wire   ),
    .wuser_m_o                (                     ),
    .wvalid_m_o               (gate_dp_wvalid_wire  ),
    .wready_m_i               (gate_dp_wready_wire  ),

    .bid_m_i                  (gate_dp_bid_wire     ),
    .bresp_m_i                (gate_dp_bresp_wire   ),
    .buser_m_i                (gate_dp_buser_wire   ),
    .bvalid_m_i               (gate_dp_bvalid_wire  ),
    .bready_m_o               (gate_dp_bready_wire  ),

    .rid_m_i                  (gate_dp_rid_wire     ),
    .rdata_m_i                (gate_dp_rdata_wire   ),
    .rresp_m_i                (gate_dp_rresp_wire   ),
    .rlast_m_i                (gate_dp_rlast_wire   ),
    .ruser_m_i                (gate_dp_ruser_wire   ),
    .rvalid_m_i               (gate_dp_rvalid_wire  ),
    .rready_m_o               (gate_dp_rready_wire  ),

    .awakeup_m_o              (gate_dp_awakeup_wire ),

    .gate_hold_req_i          (gate_hold_req_wire | ctrl_st_xfer_req_wire ),
    .gate_hold_ack_o          (gate_hold_ack_wire   ),
    .gate_busy_o              (gate_busy_wire       ),

    .tracker_empty_rd_o       (                     ), 
    .tracker_empty_wr_o       (                     ), 
    .tracker_al_empty_rd_o    (                     ), 
    .tracker_al_empty_wr_o    (                     ), 
    .tracker_id_rd_ch_i       ({FC_AXIID_WIDTH{1'b0}}),
    .tracker_id_wr_ch_i       ({FC_AXIID_WIDTH{1'b0}}),
    .tracker_read_rd_ch_i     ({TRACKER_PAYLOAD_WIDTH_AR{1'b0}}),
    .tracker_read_wr_ch_i     ({TRACKER_PAYLOAD_WIDTH_AW{1'b0}}),
    .tracker_dout_rd_ch_o     (                     ), 
    .tracker_dout_wr_ch_o     (                     ),  
    .tracker_dout_rd_ch_vld_o (                     ),  
    .tracker_dout_wr_ch_vld_o (                     )
);

firewall_f0_ctlr_dp #(
  .REG_ADDR_WIDTH      (REG_ADDR_WIDTH ),
  .REG_ENUM_WIDTH      (REG_ENUM_WIDTH ),
  .LOG2_FC_NUM_RGN     (LOG2_FC_NUM_RGN),
  .PID0_WIDTH          (PID0_WIDTH)     ,
  .PID1_WIDTH          (PID1_WIDTH)     ,
  .PID2_WIDTH          (PID2_WIDTH)     ,
  .PID3_WIDTH          (PID3_WIDTH)     ,
  .PID4_WIDTH          (PID4_WIDTH)     ,
  .CID0_WIDTH          (CID0_WIDTH)     ,
  .CID1_WIDTH          (CID1_WIDTH)     ,
  .CID2_WIDTH          (CID2_WIDTH)     ,
  .CID3_WIDTH          (CID3_WIDTH)     ,
  .IIDR_WIDTH          (IIDR_WIDTH)     ,
  .AIDR_WIDTH          (AIDR_WIDTH)     ,
  .FW_ID_WIDTH         (FW_ID_WIDTH)     ,
  `include "firewall_f0_ctlr_params_inst.vh"
) u_ctlr_dp (

    .clk              (clk_gated       ),
    .reset_n          (reset_n         ),

    .arid_s_i         (gate_dp_arid_wire        ),
    .araddr_s_i       (gate_dp_araddr_wire      ),
    .arlen_s_i        (gate_dp_arlen_wire       ),
    .arsize_s_i       (gate_dp_arsize_wire      ),
    .arburst_s_i      (gate_dp_arburst_wire     ),
    .arlock_s_i       (gate_dp_arlock_wire      ),
    .arcache_s_i      (gate_dp_arcache_wire     ),
    .arprot_s_i       (gate_dp_arprot_wire      ),
    .arqos_s_i        (gate_dp_arqos_wire       ),
    .arregion_s_i     (gate_dp_arregion_wire    ),
    .arvalid_s_i      (gate_dp_arvalid_wire     ),
    .arready_s_o      (gate_dp_arready_wire     ),
    .armmusid_s_i     (gate_dp_armmusid_wire    ),

    .awid_s_i         (gate_dp_awid_wire        ),
    .awaddr_s_i       (gate_dp_awaddr_wire      ),
    .awlen_s_i        (gate_dp_awlen_wire       ),
    .awsize_s_i       (gate_dp_awsize_wire      ),
    .awburst_s_i      (gate_dp_awburst_wire     ),
    .awlock_s_i       (gate_dp_awlock_wire      ),
    .awcache_s_i      (gate_dp_awcache_wire     ),
    .awprot_s_i       (gate_dp_awprot_wire      ),
    .awqos_s_i        (gate_dp_awqos_wire       ),
    .awregion_s_i     (gate_dp_awregion_wire    ),
    .awvalid_s_i      (gate_dp_awvalid_wire     ),
    .awready_s_o      (gate_dp_awready_wire     ),
    .awmmusid_s_i     (gate_dp_awmmusid_wire    ),

    .wdata_s_i        (gate_dp_wdata_wire       ),
    .wstrb_s_i        (gate_dp_wstrb_wire       ),
    .wlast_s_i        (gate_dp_wlast_wire       ),
    .wvalid_s_i       (gate_dp_wvalid_wire      ),
    .wready_s_o       (gate_dp_wready_wire      ),

    .bid_s_o          (gate_dp_bid_wire         ),
    .bresp_s_o        (gate_dp_bresp_wire       ),
    .buser_s_o        (gate_dp_buser_wire       ),
    .bvalid_s_o       (gate_dp_bvalid_wire      ),
    .bready_s_i       (gate_dp_bready_wire      ),

    .rid_s_o          (gate_dp_rid_wire         ),
    .rdata_s_o        (gate_dp_rdata_wire       ),
    .rresp_s_o        (gate_dp_rresp_wire       ),
    .rlast_s_o        (gate_dp_rlast_wire       ),
    .ruser_s_o        (gate_dp_ruser_wire       ),
    .rvalid_s_o       (gate_dp_rvalid_wire      ),
    .rready_s_i       (gate_dp_rready_wire      ),

    .awakeup_s_i      (gate_dp_awakeup_wire     ),

    .arid_m_o         (pe_cfg_arid_wire        ),
    .araddr_m_o       (pe_cfg_araddr_wire      ),
    .arvalid_m_o      (pe_cfg_arvalid_wire     ),
    .armmusid_m_o     (pe_cfg_r_mst_id_i_wire  ),
    .arready_m_i      (pe_cfg_arready_wire     ),

    .awid_m_o         (pe_cfg_awid_wire        ),
    .awaddr_m_o       (pe_cfg_awaddr_wire      ),
    .awvalid_m_o      (pe_cfg_awvalid_wire     ),
    .awmmusid_m_o     (pe_cfg_w_mst_id_i_wire  ),
    .awready_m_i      (pe_cfg_awready_wire     ),

    .wdata_m_o        (pe_cfg_wdata_wire       ),
    .wvalid_m_o       (pe_cfg_wvalid_wire      ),
    .wlast_m_o        (), 
    .wready_m_i       (pe_cfg_wready_wire      ),

    .bid_m_i          (pe_cfg_bid_wire         ),
    .bresp_m_i        (pe_cfg_bresp_wire       ),
    .buser_m_i        (pe_cfg_buser_wire       ),
    .bvalid_m_i       (pe_cfg_bvalid_wire      ),
    .bready_m_o       (pe_cfg_bready_wire      ),

    .rid_m_i          (pe_cfg_rid_wire         ),
    .rdata_m_i        (pe_cfg_rdata_wire       ),
    .rresp_m_i        (pe_cfg_rresp_wire       ),
    .rlast_m_i        (pe_cfg_rlast_wire       ),
    .ruser_m_i        (pe_cfg_ruser_wire       ),
    .rvalid_m_i       (pe_cfg_rvalid_wire      ),
    .rready_m_o       (pe_cfg_rready_wire      ),

    .mst_id_m_i       (pe_cfg_r_mst_id_o_wire  ), 

    .awakeup_m_o      (pe_cfg_awakeup_wire     ),

    .cfg_w_fw_id_o    (pe_cfg_w_fw_id_wire     ),
    .cfg_r_fw_id_o    (pe_cfg_r_fw_id_wire     ),


    .rb_me_st_rdum_i         (me_st_o_int[0]   ),
    .rb_pe_st_err_i          (pe_st_o_int[0]   ), 
    .rb_pe_st_err_raz_i      (pe_st_o_int[1:0] ), 
    .rb_pe_st_flt_cfg_i      (pe_st_o_int[3:2] ), 
    .rb_pe_st_en_i           (pe_st_o_int[6]   ),

    .rb_fe_rd_tal_o          (fe_tal_rdch_int  ),
    .rb_fe_rd_tau_o          (fe_tau_rdch_int  ),
    .rb_fe_rd_tp_o           (fe_tp_rdch_int   ),
    .rb_fe_rd_mid_o          (fe_mid_rdch_int  ),
    .rb_fe_rd_valid_o        (fe_rdch_en_int   ),
    .rb_fe_rd_type_o         (fe_type_rdch_int ),  
    .rb_tmp_reg_err_rd       (rb_tmp_reg_err_rd_int),

    .rb_fe_wr_tal_o          (fe_tal_wrch_int  ),
    .rb_fe_wr_tau_o          (fe_tau_wrch_int  ),
    .rb_fe_wr_tp_o           (fe_tp_wrch_int   ),
    .rb_fe_wr_mid_o          (fe_mid_wrch_int  ),
    .rb_fe_wr_valid_o        (fe_wrch_en_int   ),
    .rb_fe_wr_type_o         (fe_type_wrch_int ),  
    .rb_tmp_reg_err_wr       (rb_tmp_reg_err_wr_int),

    .rb_prot_size_i          (dp_prot_size_wire),
    .rb_bypass_i             (pe_bps_o_int[1]  ),
    .rb_comp_pwr_st_i        (cfg_pwr_st_o_int ),
    .rb_rgn_st_i             (rgn_st_o_int          ),
    .rb_rgn_size_i           (rgn_size_o_int        ),
    .rb_rgn_base_addr_i      (fctlr_base_addr_o_int ),
    .rb_rgn_upper_addr_i     (fctlr_upr_addr_o_int  ),

    .rb_rgn_mid0_i           (rgn_mid0_o_int),
    .rb_rgn_mid1_i           (rgn_mid1_o_int),
    .rb_rgn_mid2_i           (rgn_mid2_o_int),
    .rb_rgn_mid3_i           (rgn_mid3_o_int),

    .rb_rgn_mpl0_i           (rgn_mpl0_o_int),
    .rb_rgn_mpl1_i           (rgn_mpl1_o_int),
    .rb_rgn_mpl2_i           (rgn_mpl2_o_int),
    .rb_rgn_mpl3_i           (rgn_mpl3_o_int),

    .rb_pid0_i               (fw_pid0_o_int),
    .rb_pid1_i               (fw_pid1_o_int),
    .rb_pid2_i               (fw_pid2_o_int),
    .rb_pid3_i               (fw_pid3_o_int),
    .rb_pid4_i               (fw_pid4_o_int),

    .rb_cid0_i               (fw_cid0_o_int),
    .rb_cid1_i               (fw_cid1_o_int),
    .rb_cid2_i               (fw_cid2_o_int),
    .rb_cid3_i               (fw_cid3_o_int),
    .rb_aidr_i               (aidr_o_int   ),
    .rb_iidr_i               (iidr_o_int   ),
    .rb_fw_sr_ctrl_i         (fw_sr_ctrl_o_int),
    .rb_sr_rdy_i             (fw_sr_ctrl_o_int[1]),
    .rb_fw_st_i              (fw_st_o_int[1:0]),
    .rb_write_tamp_o         (rb_dp_write_tamp_i),
    .rb_read_tamp_o          (rb_dp_read_tamp_i),
    .reg_addr_dec_rd_o       (pe_cfg_enum_r_addr),
    .reg_addr_dec_wr_o       (pe_cfg_enum_w_addr)

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

  .tvalid_dti_dn_s  (tvalid_ds_i),
  .tready_dti_dn_s  (tready_ds_o),
  .tdata_dti_dn_s   (tdata_ds_i),
  .tkeep_dti_dn_s   (tkeep_ds_i),
  .tid_dti_dn_s     (tid_ds_i),
  .tlast_dti_dn_s   (tlast_ds_i),

  .tvalid_dti_up_s  (tvalid_us_o),
  .tready_dti_up_s  (tready_us_i),
  .tdata_dti_up_s   (tdata_us_o),
  .tkeep_dti_up_s   (tkeep_us_o),
  .tdest_dti_up_s   (tdest_us_o),
  .tlast_dti_up_s   (tlast_us_o),

  .tvalid_dti_up_m  (tvalid_us_int),
  .tready_dti_up_m  (tready_us_int),
  .tdata_dti_up_m   (tdata_us_int),
  .tkeep_dti_up_m   (tkeep_us_int),
  .tdest_dti_up_m   (tdest_us_int),
  .tlast_dti_up_m   (tlast_us_int),

  .tvalid_dti_dn_m  (tvalid_ds_int),
  .tready_dti_dn_m  (tready_ds_int),
  .tdata_dti_dn_m   (tdata_ds_int),
  .tkeep_dti_dn_m   (tkeep_ds_int),
  .tid_dti_dn_m     (tid_ds_int),
  .tlast_dti_dn_m   (tlast_ds_int),

  .twakeup_dti_dn_s (twakeup_ds_i),
  .twakeup_dti_up_s (twakeup_us_o),
  .twakeup_dti_up_m (twakeup_us_int),
  .twakeup_dti_dn_m (twakeup_ds_int),

  .qactive_cg       (bas_qactive),

  .bas_gate         (cfg_gate_bas_int)

);


firewall_f0_ctlr_cfg #(
  .MSG_SIZE                 (MSG_SIZE            ),
  .LOG2_MSG_SIZE            (LOG2_MSG_SIZE       ),
  .LOG2_REG_DATA_WIDTH      (LOG2_REG_DATA_WIDTH ),
  .READ_DATA_SIZE           (READ_DATA_SIZE      ),
  .IRQ_TYPE_WIDTH           (IRQ_TYPE_WIDTH      ),
  .REG_ADDR_WIDTH           (REG_ADDR_WIDTH      ),
  .REG_DATA_WIDTH           (REG_DATA_WIDTH      ),
  .REG_ENUM_WIDTH           (REG_ENUM_WIDTH      ),
  .FW_LDE_LVL               (FW_LDE_LVL          ),
  .FW_SRE_LVL               (FW_SRE_LVL          ),
  .TOTAL_FC                 (TOTAL_FC            ),
  .SRAM_WIDTH               (SRAM_WIDTH          ),
  .LOG2_SRAM_WIDTH          (LOG2_SRAM_WIDTH     ),
  .LOG2_SRAM_SIZE           (LOG2_SRAM_SIZE      ),
  .FC_CFG_DATA_W            (FC_CFG_DATA_W       ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH      ),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH  ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH  ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH     ),
  .FW_NUM_FC                (FW_NUM_FC           ),
  .LOG2_FW_NUM_FC           (LOG2_FW_NUM_FC      ),
  .FC_NUM_RGN               (FC_NUM_RGN          ),
  .LOG2_FC_NUM_RGN          (LOG2_FC_NUM_RGN     ),
  .FC_PE_LVL                (FC_PE_LVL           ),
  .FC_MXRS                  (FC_MXRS             ),
  .FC_MNRS                  (FC_MNRS             ),
  .FC_RSE_LVL               (FC_RSE_LVL          ),
  .FC_TE_LVL                (FC_TE_LVL           ),
  .FC_NUM_MPE               (FC_NUM_MPE          ),
  .FC_SINGLE_MST            (FC_SINGLE_MST       ),
  .FC_ME_LVL                (FC_ME_LVL           ),
  .FC_INST_SPT              (FC_INST_SPT         ),
  .FC_MA_SPT                (FC_MA_SPT           ),
  .FC_SEC_SPT               (FC_SEC_SPT          ),
  .FC_PRIV_SPT              (FC_PRIV_SPT         ),
  .FC_SH_SPT                (FC_SH_SPT           ),
  .FC_ID                    (FC_ID               ),
  .FC_SEC_SPT_EXT           (FC_SEC_SPT_EXT      ),
  .FC_MA_SPT_EXT            (FC_MA_SPT_EXT       ),
  .FC_SH_SPT_EXT            (FC_SH_SPT_EXT       ),
  .FC_INST_SPT_EXT          (FC_INST_SPT_EXT     ),
  .FC_PRIV_SPT_EXT          (FC_PRIV_SPT_EXT     ),
  .FC_NUM_RGN_EXT           (FC_NUM_RGN_EXT      ),
  .FC_MNRS_EXT              (FC_MNRS_EXT         ),
  .FC_MXRS_EXT              (FC_MXRS_EXT         ),
  .FC_NUM_MPE_EXT           (FC_NUM_MPE_EXT      ),
  .FC_ME_LVL_EXT            (FC_ME_LVL_EXT       ),
  .FC_RSE_LVL_EXT           (FC_RSE_LVL_EXT      ),
  .FC_PE_LVL_EXT            (FC_PE_LVL_EXT       ),
  .FC_TE_LVL_EXT            (FC_TE_LVL_EXT       ),
  .FC_SINGLE_MST_EXT        (FC_SINGLE_MST_EXT   ),
  .FW_ID_WIDTH              (FW_ID_WIDTH         ),
  .FC_RGN_BASE_ADDR_EXT     (FC_RGN_BASE_ADDR_EXT),
  .FC_RGN_UPR_ADDR_EXT      (FC_RGN_UPR_ADDR_EXT ),
  .FC_RGN_SIZE_EXT          (FC_RGN_SIZE_EXT     ),
  .FC_RGN_MULNPO2_EXT       (FC_RGN_MULNPO2_EXT  ),
  .FC_MST_ID_SINGLE_MST_EXT (FC_MST_ID_SINGLE_MST_EXT  ),
  .FW_CFG_AGENT_MST_ID      (FW_CFG_AGENT_MST_ID),
  .FC_BAS_REG_SLC           (FC_BAS_REG_SLC),
  .FW_MAX_MST_ID_WIDTH      (FW_MAX_MST_ID_WIDTH),
  .FC_MST_ID_WIDTH_EXT      (FC_MST_ID_WIDTH_EXT),
  .MAX_NUM_OF_PKTS          (MAX_NUM_OF_PKTS),
  .MSG_SIZE_WIDTH           (MSG_SIZE_WIDTH)
)
u_ctlr_cfg
(
    .clk                              (clk_gated              ),
    .reset_n                          (reset_n                ),

    .cfg_tvalid_ds_i                  (tvalid_ds_int       ),
    .cfg_tready_ds_o                  (tready_ds_int       ),
    .cfg_tdata_ds_i                   (tdata_ds_int        ),
    .cfg_tkeep_ds_i                   (tkeep_ds_int        ),
    .cfg_tlast_ds_i                   (tlast_ds_int        ),
    .cfg_tid_ds_i                     (tid_ds_int          ),
    .cfg_twakeup_ds_i                 (twakeup_ds_int      ),

    .cfg_tvalid_us_o                  (tvalid_us_int       ),
    .cfg_tready_us_i                  (tready_us_int       ),
    .cfg_tdata_us_o                   (tdata_us_int        ),
    .cfg_tkeep_us_o                   (tkeep_us_int        ),
    .cfg_tlast_us_o                   (tlast_us_int        ),
    .cfg_tdest_us_o                   (tdest_us_int        ),
    .cfg_twakeup_us_o                 (twakeup_us_int      ),

    .cfg_arid_i                       (pe_cfg_arid_wire ),
    .cfg_araddr_i                     (pe_cfg_araddr_wire ),
    .cfg_arvalid_i                    (pe_cfg_arvalid_wire ),
    .cfg_arready_o                    (pe_cfg_arready_wire ),
    .cfg_awid_i                       (pe_cfg_awid_wire ),
    .cfg_awaddr_i                     (pe_cfg_awaddr_wire ),
    .cfg_awvalid_i                    (pe_cfg_awvalid_wire ),
    .cfg_awready_o                    (pe_cfg_awready_wire ),
    .cfg_wdata_i                      (pe_cfg_wdata_wire ),
    .cfg_wvalid_i                     (pe_cfg_wvalid_wire ),
    .cfg_wready_o                     (pe_cfg_wready_wire ),
    .cfg_bid_o                        (pe_cfg_bid_wire ),
    .cfg_bresp_o                      (pe_cfg_bresp_wire ),
    .cfg_buser_o                      (pe_cfg_buser_wire ),
    .cfg_bvalid_o                     (pe_cfg_bvalid_wire ),
    .cfg_bready_i                     (pe_cfg_bready_wire ),
    .cfg_rid_o                        (pe_cfg_rid_wire ),
    .cfg_rdata_o                      (pe_cfg_rdata_wire ),
    .cfg_rresp_o                      (pe_cfg_rresp_wire ),
    .cfg_rlast_o                      (pe_cfg_rlast_wire ),
    .cfg_ruser_o                      (pe_cfg_ruser_wire ),
    .cfg_rvalid_o                     (pe_cfg_rvalid_wire ),
    .cfg_rready_i                     (pe_cfg_rready_wire ),
    .cfg_w_fw_id_i                    (pe_cfg_w_fw_id_wire ),
    .cfg_r_fw_id_i                    (pe_cfg_r_fw_id_wire ),
    .cfg_w_mst_id_i                   (pe_cfg_w_mst_id_i_wire ),
    .cfg_r_mst_id_i                   (pe_cfg_r_mst_id_i_wire ),
    .cfg_r_mst_id_o                   (pe_cfg_r_mst_id_o_wire ),
    .cfg_enum_w_addr_i                (pe_cfg_enum_w_addr ),
    .cfg_enum_r_addr_i                (pe_cfg_enum_r_addr ),
    .cfg_awprot_i                     (gate_dp_awprot_wire ),
    .cfg_arprot_i                     (gate_dp_arprot_wire ),

    .cfg_reg_tamp_o                   (tamper_cfg_o_int)  ,
    .cfg_reg_tamp_w_o                 (tamper_cfg_w_o_int),
    .cfg_prot_size_i                  (fw_prot_size_o_int),

    .cfg_fw_ctrl_i                    (fw_ctrl_o_int),
    .cfg_fw_ctrl_en                   (fw_ctrl_en_int),
    .cfg_fw_ctrl_o                    (fw_ctrl_i_int),
    .cfg_fw_sr_ctrl_i                 (fw_sr_ctrl_o_int),
    .cfg_fw_sr_ctrl_en                (fw_sr_ctrl_en_int),
    .cfg_fw_sr_ctrl_o                 (fw_sr_ctrl_i_int),
    .cfg_fw_st_i                      (fw_st_o_int),
    .cfg_pe_bps_i                     (pe_bps_o_int),
    .cfg_ld_ctrl_i                    (ld_ctrl_o_int),
    .cfg_ld_ctrl_en                   (ld_ctrl_en_int),
    .cfg_ld_ctrl_o                    (ld_ctrl_i_int),
    .cfg_pe_ctrl_i                    (pe_ctrl_o_int),
    .cfg_pe_ctrl_en                   (pe_ctrl_en_int),
    .cfg_pe_ctrl_o                    (pe_ctrl_i_int),
    .cfg_pe_st_i                      (pe_st_o_int),
    .cfg_rwe_ctrl_i                   (rwe_ctrl_o_int),
    .cfg_rwe_ctrl_en                  (rwe_ctrl_en_int),
    .cfg_rwe_ctrl_o                   (rwe_ctrl_i_int),
    .cfg_rgn_ctrl0_i                  (rgn_ctrl0_o_int),
    .cfg_rgn_ctrl0_en                 (rgn_ctrl0_en_int),
    .cfg_rgn_ctrl0_o                  (rgn_ctrl0_i_int),
    .cfg_rgn_ctrl0_rgn_i              (rgn_ctrl0_rgn_o_int),
    .cfg_rgn_ctrl1_i                  (rgn_ctrl1_o_int),
    .cfg_rgn_ctrl1_en                 (rgn_ctrl1_en_int),
    .cfg_rgn_ctrl1_rgn_i              (rgn_ctrl1_rgn_o_int),
    .cfg_rgn_ctrl1_o                  (rgn_ctrl1_i_int),
    .cfg_rgn_lctrl_i                  (rgn_lctrl_o_int),
    .cfg_rgn_lctrl_en                 (rgn_lctrl_en_int),
    .cfg_rgn_lctrl_rgn_i              (rgn_lctrl_rgn_o_int),
    .cfg_rgn_lctrl_o                  (rgn_lctrl_i_int),
    .cfg_rgn_st_rgn_i                 (rgn_st_rgn_o_int),
    .cfg_rgn_cfg0_i                   (rgn_cfg0_o_int),
    .cfg_rgn_cfg0_en                  (rgn_cfg0_en_int),
    .cfg_rgn_cfg0_rgn_i               (rgn_cfg0_rgn_o_int),
    .cfg_rgn_cfg0_o                   (rgn_cfg0_i_int),
    .cfg_rgn_cfg1_i                   (rgn_cfg1_o_int),
    .cfg_rgn_cfg1_en                  (rgn_cfg1_en_int),
    .cfg_rgn_cfg1_rgn_i               (rgn_cfg1_rgn_o_int),
    .cfg_rgn_cfg1_o                   (rgn_cfg1_i_int),
    .cfg_rgn_size_i                   (rgn_size_o_int),
    .cfg_rgn_size_en                  (rgn_size_en_int),
    .cfg_rgn_size_rgn_i               (rgn_size_rgn_o_int),
    .cfg_rgn_size_o                   (rgn_size_i_int),
    .cfg_rgn_tcfg0_i                  (rgn_tcfg0_o_int),
    .cfg_rgn_tcfg0_en                 (rgn_tcfg0_en_int),
    .cfg_rgn_tcfg0_rgn_i              (rgn_tcfg0_rgn_o_int),
    .cfg_rgn_tcfg0_o                  (rgn_tcfg0_i_int),
    .cfg_rgn_tcfg1_i                  (rgn_tcfg1_o_int),
    .cfg_rgn_tcfg1_en                 (rgn_tcfg1_en_int),
    .cfg_rgn_tcfg1_rgn_i              (rgn_tcfg1_rgn_o_int),
    .cfg_rgn_tcfg1_o                  (rgn_tcfg1_i_int),
    .cfg_rgn_tcfg2_i                  (rgn_tcfg2_o_int),
    .cfg_rgn_tcfg2_en                 (rgn_tcfg2_en_int),
    .cfg_rgn_tcfg2_rgn_i              (rgn_tcfg2_rgn_o_int),
    .cfg_rgn_tcfg2_o                  (rgn_tcfg2_i_int),
    .cfg_rgn_mid0_i                   (rgn_mid0_o_int),
    .cfg_rgn_mid0_en                  (rgn_mid0_en_int),
    .cfg_rgn_mid0_rgn_i               (rgn_mid0_rgn_o_int),
    .cfg_rgn_mid0_o                   (rgn_mid0_i_int),
    .cfg_rgn_mid1_i                   (rgn_mid1_o_int),
    .cfg_rgn_mid1_en                  (rgn_mid1_en_int),
    .cfg_rgn_mid1_rgn_i               (rgn_mid1_rgn_o_int),
    .cfg_rgn_mid1_o                   (rgn_mid1_i_int),
    .cfg_rgn_mid2_i                   (rgn_mid2_o_int),
    .cfg_rgn_mid2_en                  (rgn_mid2_en_int),
    .cfg_rgn_mid2_rgn_i               (rgn_mid2_rgn_o_int),
    .cfg_rgn_mid2_o                   (rgn_mid2_i_int),
    .cfg_rgn_mid3_i                   (rgn_mid3_o_int),
    .cfg_rgn_mid3_en                  (rgn_mid3_en_int),
    .cfg_rgn_mid3_rgn_i               (rgn_mid3_rgn_o_int),
    .cfg_rgn_mid3_o                   (rgn_mid3_i_int),
    .cfg_rgn_mpl0_i                   (rgn_mpl0_o_int),
    .cfg_rgn_mpl0_en                  (rgn_mpl0_en_int),
    .cfg_rgn_mpl0_rgn_i               (rgn_mpl0_rgn_o_int),
    .cfg_rgn_mpl0_o                   (rgn_mpl0_i_int),
    .cfg_rgn_mpl1_i                   (rgn_mpl1_o_int),
    .cfg_rgn_mpl1_en                  (rgn_mpl1_en_int),
    .cfg_rgn_mpl1_rgn_i               (rgn_mpl1_rgn_o_int),
    .cfg_rgn_mpl1_o                   (rgn_mpl1_i_int),
    .cfg_rgn_mpl2_i                   (rgn_mpl2_o_int),
    .cfg_rgn_mpl2_en                  (rgn_mpl2_en_int),
    .cfg_rgn_mpl2_rgn_i               (rgn_mpl2_rgn_o_int),
    .cfg_rgn_mpl2_o                   (rgn_mpl2_i_int),
    .cfg_rgn_mpl3_i                   (rgn_mpl3_o_int),
    .cfg_rgn_mpl3_en                  (rgn_mpl3_en_int),
    .cfg_rgn_mpl3_rgn_i               (rgn_mpl3_rgn_o_int),
    .cfg_rgn_mpl3_o                   (rgn_mpl3_i_int),
    .cfg_fe_tal_i                     (fe_tal_o_int),
    .cfg_fe_tau_i                     (fe_tau_o_int),
    .cfg_fe_tp_i                      (fe_tp_o_int),
    .cfg_fe_mid_i                     (fe_mid_o_int),
    .cfg_fe_ctrl_i                    (fe_ctrl_o_int),
    .cfg_fe_ctrl_en                   (fe_ctrl_en_int),
    .cfg_fe_ctrl_o                    (fe_ctrl_i_int),
    .cfg_me_ctrl_i                    (me_ctrl_o_int),
    .cfg_me_ctrl_en                   (me_ctrl_en_int),
    .cfg_me_ctrl_o                    (me_ctrl_i_int),
    .cfg_me_st_i                      (me_st_o_int),
    .cfg_edr_tal_i                    (32'b0),
    .cfg_edr_tau_i                    (32'b0),
    .cfg_edr_tp_i                     (4'b0),
    .cfg_edr_mid_i                    ({FC_MST_ID_WIDTH{1'b0}}),
    .cfg_edr_ctrl_i                   (3'b0),
    .cfg_edr_ctrl_en                  (edr_ctrl_en_int),
    .cfg_edr_ctrl_o                   (edr_ctrl_i_int),
    .cfg_fc_int_st_i                  (fc_int_st_o_int),
    .cfg_fc_int_st_en                 (fc_int_st_en_int),
    .cfg_fc_int_st_o                  (fc_int_st_i_int),
    .cfg_fc_int_msk_i                 (fc_int_msk_o_int),
    .cfg_fc_int_msk_en                (fc_int_msk_en_int),
    .cfg_fc_int_msk_o                 (fc_int_msk_i_int),
    .cfg_fw_tmp_ta_i                  (fw_tmp_ta_o_int),
    .cfg_fw_tmp_tp_i                  (fw_tmp_tp_o_int),
    .cfg_fw_tmp_mid_i                 (fw_tmp_mid_o_int),
    .cfg_fw_tmp_ctrl_i                (fw_tmp_ctrl_o_int),
    .cfg_fw_tmp_ctrl_en               (fw_tmp_ctrl_en_int),
    .cfg_fw_tmp_ctrl_o                (fw_tmp_ctrl_i_int),
    .cfg_fw_int_st_i                  (fw_int_st_o_int),
    .cfg_iidr_i                       (iidr_o_int),
    .cfg_aidr_i                       (aidr_o_int),
    .cfg_pwr_st_o                     (cfg_pwr_st_i_int),
    .cfg_pwr_st_en_o                  (cfg_pwr_st_en_o_int),
    .cfg_pwr_st_i                     (cfg_pwr_st_ctrl_o_int),
    .cfg_restore_done_o               (cfg_restore_done_int),
    .cfg_sram_init_done_o             (cfg_sram_init_done_int),
    .cfg_irq_req_o                    (cfg_irq_req_int),
    .cfg_irq_type_o                   (cfg_irq_type_int),
    .cfg_irq_fw_id_o                  (cfg_irq_fw_id_int),
    .cfg_sram_addr_o                  (sram_addr_int),
    .cfg_sram_cenn_o                  (sram_cenn_int),
    .cfg_sram_wenn_o                  (sram_wenn_int),
    .cfg_sram_data_o                  (sram_data_i_int),
    .cfg_sram_data_i                  (sram_data_o_int),
    .cfg_lpi_hold_i                   (cfg_lpi_hold_o_int),
    .cfg_lpi_clk_busy_o               (cfg_lpi_clk_busy_i_int),
    .cfg_lpi_ram_req_o                (cfg_lpi_ram_req_o_int),
    .cfg_lpi_ram_ack_i                (cfg_lpi_ram_ack_int),
    .cfg_lpi_ram_init_i               (cfg_lpi_ram_init_int),
    .cfg_default_state_i              (default_state_wire),
    .cfg_gate_bas_o                   (cfg_gate_bas_int)

);

firewall_f0_ctlr_lpi #(
    .FW_SRE_LVL        (FW_SRE_LVL)
) u_firewall_f0_ctlr_lpi (
    .clk               (clk    ),
    .clk_gated         (clk_gated ),
    .reset_n           (reset_n),
    .bypass_syncd      (bypass_syncd ),
    .tinit_delay       (tinit_delay),
    .clk_qreqn_i       (clk_qreqn_syncd),
    .clk_qacceptn_o    (clk_qacceptn_o),
    .clk_qdeny_o       (clk_qdeny_o   ),
    .clk_qactive_o     (int_qactive   ),
    .pwr_preq_i        (pwr_preq_ss_r   ),
    .pwr_pstate_i      (pwr_pstate_syncd),
    .pwr_paccept_o     (pwr_paccept_o   ),
    .pwr_pdeny_o       (pwr_pdeny_o     ),
    .pwr_pactive_o     (pwr_pactive_o   ),
    .cfg_hold_o        (cfg_lpi_hold_o_int),
    .cfg_busy_i        (cfg_busy_int),
    .cfg_ram_req_i     (cfg_lpi_ram_req_o_int),
    .cfg_ram_ack_o     (cfg_lpi_ram_ack_int),
    .cfg_ram_init_o    (cfg_lpi_ram_init_int),
    .cfg_ram_init_done_i(fw_sr_ctrl_o_int[1]),
    .gate_hold_req_o   (gate_hold_req_lpi_wire),
    .gate_hold_ack_i   (gate_hold_ack_wire),
    .gate_busy_i       (gate_busy_wire | axi_slc_busy_s_wire),
    .rb_fc_con_i       (|cfg_pwr_st_o_int),
    .rb_fc_sr_pwr_i    (fw_sr_ctrl_o_int[0]),
    .rb_pwr_deny_i     (rb_pwr_deny_int),
    .rb_prot_en_o      (rb_prot_en_o_int),
    .default_state_o   (default_state_wire),
    .clk_gate_en       (clk_gate_en),
    .dftcgen           (dftcgen)
);

firewall_f0_xor2 u_bps_req (
  .din0 (bypass_i),
  .din1 (bypass_syncd),
  .dout (i_bps_req)
);

firewall_f0_or2 u_fw_qactive_or2_0 (
  .din0 (i_bps_req),
  .din1 (pwr_preq_i),
  .dout (i_qactive_0)
);

firewall_f0_or2 u_fw_qactive_or2_1 (
  .din0 (int_qactive),
  .din1 (i_qactive_0),
  .dout (i_qactive_1)
);

firewall_f0_or2 u_fw_qactive_or2_2 (
  .din0 (awakeup_s_i),
  .din1 (twakeup_ds_i),
  .dout (i_qactive_2)
);

firewall_f0_or2 u_fw_qactive_or2_3 (
  .din0 (i_qactive_1),
  .din1 (i_qactive_2),
  .dout (clk_qactive_o)
);

firewall_f0_ctlr_fctlr_regbank #(
  .CFG_AGENT_MST_ID                             (FW_CFG_AGENT_MST_ID     ),
  .FC_ID                                        (FC_ID                   ),
  .FC_PE_LVL                                    (FC_PE_LVL               ),
  .PE_CTRL_WIDTH                                (PE_CTRL_WIDTH           ),
  .PE_ST_WIDTH                                  (PE_ST_WIDTH             ),
  .RWE_CTRL_WIDTH                               (RWE_CTRL_WIDTH          ),
  .FC_NUM_RGN                                   (FC_NUM_RGN              ),
  .LOG2_FC_NUM_RGN                              (LOG2_FC_NUM_RGN         ),
  .RGN_CTRL0_WIDTH                              (RGN_CTRL0_WIDTH         ),
  .RGN_CTRL1_WIDTH                              (RGN_CTRL1_WIDTH         ),
  .FC_NUM_MPE                                   (FC_NUM_MPE              ),
  .RGN_LCTRL_WIDTH                              (RGN_LCTRL_WIDTH         ),
  .FW_LDE_LVL                                   (FW_LDE_LVL              ),
  .RGN_ST_WIDTH                                 (RGN_ST_WIDTH            ),
  .FC_MXRS                                      (FC_MXRS                 ),
  .FC_MNRS                                      (FC_MNRS                 ),
  .RGN_CFG0_WIDTH                               (RGN_CFG0_WIDTH          ),
  .PE_BPS_WIDTH                                 (PE_BPS_WIDTH            ),
  .FC_RGN_BASE_ADDR                             (FC_RGN_BASE_ADDR        ),
  .RGN_CFG1_WIDTH                               (RGN_CFG1_WIDTH          ),
  .FC_RGN_UPR_ADDR                              (FC_RGN_UPR_ADDR         ),
  .FC_RSE_LVL                                   (FC_RSE_LVL              ),
  .RGN_SIZE_WIDTH                               (RGN_SIZE_WIDTH          ),
  .FC_RGN_MULNPO2                               (FC_RGN_MULNPO2          ),
  .FC_RGN_SIZE                                  (FC_RGN_SIZE             ),
  .PROT_SIZE_WIDTH                              (PROT_SIZE_WIDTH         ),
  .RGN_TCFG0_WIDTH                              (RGN_TCFG0_WIDTH         ),
  .FC_TE_LVL                                    (FC_TE_LVL               ),
  .RGN_TCFG1_WIDTH                              (RGN_TCFG1_WIDTH         ),
  .RGN_TCFG2_WIDTH                              (RGN_TCFG2_WIDTH         ),
  .FC_MA_SPT                                    (FC_MA_SPT               ),
  .FC_SH_SPT                                    (FC_SH_SPT               ),
  .FC_INST_SPT                                  (FC_INST_SPT             ),
  .FC_PRIV_SPT                                  (FC_PRIV_SPT             ),
  .FC_SEC_SPT                                   (FC_SEC_SPT              ),
  .FC_SINGLE_MST                                (FC_SINGLE_MST           ),
  .FC_MST_ID_WIDTH                              (FC_MST_ID_WIDTH         ),
  .RGN_MPL0_WIDTH                               (RGN_MPL0_WIDTH          ),
  .RGN_MPL1_WIDTH                               (RGN_MPL1_WIDTH          ),
  .RGN_MPL2_WIDTH                               (RGN_MPL2_WIDTH          ),
  .RGN_MPL3_WIDTH                               (RGN_MPL3_WIDTH          ),
  .FE_TAL_WIDTH                                 (FE_TAL_WIDTH            ),
  .FE_TAU_WIDTH                                 (FE_TAU_WIDTH            ),
  .FE_TP_WIDTH                                  (FE_TP_WIDTH             ),
  .FE_CTRL_WIDTH                                (FE_CTRL_WIDTH           ),
  .IRQ_TYPE_WIDTH                               (IRQ_TYPE_WIDTH          ),
  .ME_CTRL_WIDTH                                (ME_CTRL_WIDTH           ),
  .ME_ST_WIDTH                                  (ME_ST_WIDTH             ),
  .EDR_TAL_WIDTH                                (EDR_TAL_WIDTH           ),
  .EDR_TAU_WIDTH                                (EDR_TAU_WIDTH           ),
  .EDR_TP_WIDTH                                 (EDR_TP_WIDTH            ),
  .EDR_CTRL_WIDTH                               (EDR_CTRL_WIDTH          ),
  .FC_ME_LVL                                    (FC_ME_LVL               ),
  .LD_CTRL_WIDTH                                (LD_CTRL_WIDTH           ),
  .FC_MST_ID_SINGLE_MST                         (FC_MST_ID_SINGLE_MST    ),
  .FW_NUM_FC                                    (FW_NUM_FC               ),
  .FW_CTRL_WIDTH                                (FW_CTRL_WIDTH           ),
  .FW_ST_WIDTH                                  (FW_ST_WIDTH             ),
  .FW_SR_CTRL_WIDTH                             (FW_SR_CTRL_WIDTH        ),
  .FC_INT_ST_WIDTH                              (FC_INT_ST_WIDTH         ),
  .FC_INT_MSK_WIDTH                             (FC_INT_MSK_WIDTH        ),
  .LOG2_FW_NUM_FC                               (LOG2_FW_NUM_FC          ),
  .PID0_WIDTH                                   (PID0_WIDTH              ),
  .PID1_WIDTH                                   (PID1_WIDTH              ),
  .PID2_WIDTH                                   (PID2_WIDTH              ),
  .PID3_WIDTH                                   (PID3_WIDTH              ),
  .PID4_WIDTH                                   (PID4_WIDTH              ),
  .CID0_WIDTH                                   (CID0_WIDTH              ),
  .CID1_WIDTH                                   (CID1_WIDTH              ),
  .CID2_WIDTH                                   (CID2_WIDTH              ),
  .CID3_WIDTH                                   (CID3_WIDTH              ),
  .IIDR_WIDTH                                   (IIDR_WIDTH              ),
  .AIDR_WIDTH                                   (AIDR_WIDTH              ),
  .FW_SRE_LVL                                   (FW_SRE_LVL              ),
  .FC_MST_ID_WIDTH_EXT                          (FC_MST_ID_WIDTH_EXT     ),
  .FC_ID_EXT                                    (FC_ID_EXT               ),
  .FC_SINGLE_MST_EXT                            (FC_SINGLE_MST_EXT       ),
  .FC_PE_LVL_EXT                                (FC_PE_LVL_EXT           ),
  .FC_TE_LVL_EXT                                (FC_TE_LVL_EXT           ),
  .FC_RSE_LVL_EXT                               (FC_RSE_LVL_EXT          ),
  .FC_ME_LVL_EXT                                (FC_ME_LVL_EXT           ),
  .FC_NUM_RGN_EXT                               (FC_NUM_RGN_EXT          ),
  .FC_MNRS_EXT                                  (FC_MNRS_EXT             ),
  .FC_MXRS_EXT                                  (FC_MXRS_EXT             ),
  .FC_NUM_MPE_EXT                               (FC_NUM_MPE_EXT          ),
  .FC_SEC_SPT_EXT                               (FC_SEC_SPT_EXT          ),
  .FC_MA_SPT_EXT                                (FC_MA_SPT_EXT           ),
  .FC_SH_SPT_EXT                                (FC_SH_SPT_EXT           ),
  .FC_INST_SPT_EXT                              (FC_INST_SPT_EXT         ),
  .FC_PRIV_SPT_EXT                              (FC_PRIV_SPT_EXT         ),
  .FC_MST_ID_SINGLE_MST_EXT                     (FC_MST_ID_SINGLE_MST_EXT),
  .FW_SE_LVL                                    (FW_SE_LVL               ),
  .FC_ADDR_WIDTH                                (FC_ADDR_WIDTH           ),
  .FW_TMP_TA_WIDTH                              (FW_TMP_TA_WIDTH         ),
  .FW_TMP_TP_WIDTH                              (FW_TMP_TP_WIDTH         ),
  .FW_TMP_CTRL_WIDTH                            (FW_TMP_CTRL_WIDTH       ),
  .FW_TMP_TA_ADDR                               (FW_TMP_TA_ADDR          ),
  .FW_TMP_TP_ADDR                               (FW_TMP_TP_ADDR          ),
  .FW_TMP_MID_ADDR                              (FW_TMP_MID_ADDR         ),
  .FW_TMP_CTRL_ADDR                             (FW_TMP_CTRL_ADDR        )
)
u_firewall_f0_ctlr_fctlr_regbank (
   .clk             (clk_gated),
   .reset_n         (reset_n),

   .arvalid_i(s_regslc_arvalid_o),
   .arready_i(s_regslc_arready_i),
   .awvalid_i(s_regslc_awvalid_o),
   .awready_i(s_regslc_awready_i),
   .wvalid_i (s_regslc_wvalid_o),
   .wready_i (s_regslc_wready_i),

   .rvalid_i (s_regslc_rvalid_i),
   .rready_i (s_regslc_rready_o),
   .bvalid_i (s_regslc_bvalid_i),
   .bready_i (s_regslc_bready_o),

   .fw_ctrl_i       (fw_ctrl_i_int),
   .fw_ctrl_en      (fw_ctrl_en_int),
   .fw_ctrl_o       (fw_ctrl_o_int),

   .fw_st_o         (fw_st_o_int),

   .fw_sr_ctrl_i    (fw_sr_ctrl_i_int),
   .fw_sr_ctrl_en   (fw_sr_ctrl_en_int),
   .fw_sr_ctrl_o    (fw_sr_ctrl_o_int),

   .pe_bps_i        (bypass_syncd),
   .pe_bps_o        (pe_bps_o_int),

   .fw_int_st_o     (fw_int_st_o_int),

   .fw_global_int_st(interrupt_o      ),
   .fw_tamper_irq   (tamper_interrupt_o),

   .ldi_st_i        (lockdown_syncd),

   .ld_ctrl_i       (ld_ctrl_i_int),
   .ld_ctrl_en      (ld_ctrl_en_int),
   .ld_ctrl_o       (ld_ctrl_o_int),

   .pe_ctrl_i       (pe_ctrl_i_int),
   .pe_ctrl_en      (pe_ctrl_en_int),
   .pe_ctrl_o       (pe_ctrl_o_int),

   .pe_st_o         (pe_st_o_int),

   .rwe_ctrl_i      (rwe_ctrl_i_int),
   .rwe_ctrl_en     (rwe_ctrl_en_int),
   .rwe_ctrl_o      (rwe_ctrl_o_int),

   .rgn_ctrl0_i     (rgn_ctrl0_i_int),
   .rgn_ctrl0_en    (rgn_ctrl0_en_int),
   .rgn_ctrl0_o     (rgn_ctrl0_o_int),
   .rgn_ctrl0_rgn_o (rgn_ctrl0_rgn_o_int),

   .rgn_ctrl1_i     (rgn_ctrl1_i_int),
   .rgn_ctrl1_en    (rgn_ctrl1_en_int),
   .rgn_ctrl1_rgn_o (rgn_ctrl1_rgn_o_int),
   .rgn_ctrl1_o     (rgn_ctrl1_o_int),

   .rgn_lctrl_i     (rgn_lctrl_i_int),
   .rgn_lctrl_en    (rgn_lctrl_en_int),
   .rgn_lctrl_rgn_o (rgn_lctrl_rgn_o_int),
   .rgn_lctrl_o     (rgn_lctrl_o_int),

   .rgn_st_rgn_o    (rgn_st_rgn_o_int),
   .rgn_st_o        (rgn_st_o_int),

   .rgn_cfg0_i      (rgn_cfg0_i_int),
   .rgn_cfg0_en     (rgn_cfg0_en_int),
   .rgn_cfg0_rgn_o  (rgn_cfg0_rgn_o_int),
   .rgn_cfg0_o      (rgn_cfg0_o_int),

   .rgn_cfg1_i      (rgn_cfg1_i_int),
   .rgn_cfg1_en     (rgn_cfg1_en_int),
   .rgn_cfg1_rgn_o  (rgn_cfg1_rgn_o_int),
   .rgn_cfg1_o      (rgn_cfg1_o_int),

   .rgn_size_i      (rgn_size_i_int),
   .rgn_size_en     (rgn_size_en_int),
   .rgn_size_rgn_o  (rgn_size_rgn_o_int),
   .rgn_size_o      (rgn_size_o_int),

   .rgn_tcfg0_i     (rgn_tcfg0_i_int),
   .rgn_tcfg0_en    (rgn_tcfg0_en_int),
   .rgn_tcfg0_rgn_o (rgn_tcfg0_rgn_o_int),
   .rgn_tcfg0_o     (rgn_tcfg0_o_int),

   .rgn_tcfg1_i     (rgn_tcfg1_i_int),
   .rgn_tcfg1_en    (rgn_tcfg1_en_int),
   .rgn_tcfg1_rgn_o (rgn_tcfg1_rgn_o_int),
   .rgn_tcfg1_o     (rgn_tcfg1_o_int),

   .rgn_tcfg2_i     (rgn_tcfg2_i_int),
   .rgn_tcfg2_en    (rgn_tcfg2_en_int),
   .rgn_tcfg2_rgn_o (rgn_tcfg2_rgn_o_int),
   .rgn_tcfg2_o     (rgn_tcfg2_o_int),

   .rgn_mid0_i      (rgn_mid0_i_int),
   .rgn_mid0_en     (rgn_mid0_en_int),
   .rgn_mid0_rgn_o  (rgn_mid0_rgn_o_int),
   .rgn_mid0_o      (rgn_mid0_o_int),

   .rgn_mid1_i      (rgn_mid1_i_int),
   .rgn_mid1_en     (rgn_mid1_en_int),
   .rgn_mid1_rgn_o  (rgn_mid1_rgn_o_int),
   .rgn_mid1_o      (rgn_mid1_o_int),

   .rgn_mid2_i      (rgn_mid2_i_int),
   .rgn_mid2_en     (rgn_mid2_en_int),
   .rgn_mid2_rgn_o  (rgn_mid2_rgn_o_int),
   .rgn_mid2_o      (rgn_mid2_o_int),

   .rgn_mid3_i      (rgn_mid3_i_int),
   .rgn_mid3_en     (rgn_mid3_en_int),
   .rgn_mid3_rgn_o  (rgn_mid3_rgn_o_int),
   .rgn_mid3_o      (rgn_mid3_o_int),

   .rgn_mpl0_i      (rgn_mpl0_i_int),
   .rgn_mpl0_en     (rgn_mpl0_en_int),
   .rgn_mpl0_rgn_o  (rgn_mpl0_rgn_o_int),
   .rgn_mpl0_o      (rgn_mpl0_o_int),

   .rgn_mpl1_i      (rgn_mpl1_i_int),
   .rgn_mpl1_en     (rgn_mpl1_en_int),
   .rgn_mpl1_rgn_o  (rgn_mpl1_rgn_o_int),
   .rgn_mpl1_o      (rgn_mpl1_o_int),

   .rgn_mpl2_i      (rgn_mpl2_i_int),
   .rgn_mpl2_en     (rgn_mpl2_en_int),
   .rgn_mpl2_rgn_o  (rgn_mpl2_rgn_o_int),
   .rgn_mpl2_o      (rgn_mpl2_o_int),

   .rgn_mpl3_i      (rgn_mpl3_i_int),
   .rgn_mpl3_en     (rgn_mpl3_en_int),
   .rgn_mpl3_rgn_o  (rgn_mpl3_rgn_o_int),
   .rgn_mpl3_o      (rgn_mpl3_o_int),


   .fe_tal_rdch_i (fe_tal_rdch_int ),
   .fe_tau_rdch_i (fe_tau_rdch_int ),
   .fe_tp_rdch_i  (fe_tp_rdch_int  ),
   .fe_mid_rdch_i (fe_mid_rdch_int ),
   .fe_rdch_en    (fe_rdch_en_int  ),
   .fe_type_rdch_i(fe_type_rdch_int),
   .rb_tmp_reg_err_rd_i (rb_tmp_reg_err_rd_int),

   .fe_tal_wrch_i (fe_tal_wrch_int ),
   .fe_tau_wrch_i (fe_tau_wrch_int ),
   .fe_tp_wrch_i  (fe_tp_wrch_int  ),
   .fe_mid_wrch_i (fe_mid_wrch_int ),
   .fe_wrch_en    (fe_wrch_en_int  ),
   .fe_type_wrch_i(fe_type_wrch_int),
   .rb_tmp_reg_err_wr_i (rb_tmp_reg_err_wr_int),


   .fe_tal_o        (fe_tal_o_int),
   .fe_tau_o        (fe_tau_o_int),
   .fe_tp_o         (fe_tp_o_int),
   .fe_mid_o        (fe_mid_o_int),

   .fe_ctrl_i       (fe_ctrl_i_int),
   .fe_ctrl_en      (fe_ctrl_en_int),
   .fe_ctrl_o       (fe_ctrl_o_int),

   .me_ctrl_i       (me_ctrl_i_int),
   .me_ctrl_en      (me_ctrl_en_int),
   .me_ctrl_o       (me_ctrl_o_int),
   .me_st_o         (me_st_o_int),


   .fc_int_st_i     (fc_int_st_i_int),
   .fc_int_st_en    (fc_int_st_en_int),
   .fc_int_st_o     (fc_int_st_o_int),

   .restore_done    (cfg_restore_done_int),

   .fc_int_msk_i    (fc_int_msk_i_int),
   .fc_int_msk_en   (fc_int_msk_en_int),
   .fc_int_msk_o    (fc_int_msk_o_int),

   .arprot_i        (s_regslc_arprot_o ),
   .armmusid_i      (s_regslc_armmusid_o ),
   .araddr_i        (s_regslc_araddr_o),
   .awprot_i        (s_regslc_awprot_o ),
   .awmmusid_i      (s_regslc_awmmusid_o ),
   .awaddr_i        (s_regslc_awaddr_o),

   .tamper_cfg      (tamper_cfg_o_int),
   .tamper_cfg_w    (tamper_cfg_w_o_int),

   .fw_tmp_ta_o     (fw_tmp_ta_o_int),
   .fw_tmp_tp_o     (fw_tmp_tp_o_int),
   .fw_tmp_mid_o    (fw_tmp_mid_o_int),

   .fw_tmp_ctrl_i   (fw_tmp_ctrl_i_int),
   .fw_tmp_ctrl_en  (fw_tmp_ctrl_en_int),
   .fw_tmp_ctrl_o   (fw_tmp_ctrl_o_int),

   .iidr_o          (iidr_o_int),
   .aidr_o          (aidr_o_int),

   .comp_pwr_st_i      (cfg_pwr_st_i_int   ),
   .comp_pwr_st_en     (cfg_pwr_st_en_o_int),
   .comp_pwr_st_o      (cfg_pwr_st_o_int ),
   .comp_pwr_st_ctrl_o (cfg_pwr_st_ctrl_o_int ),

   .fw_prot_size_i  (protsize_i),
   .fw_prot_size_o  (fw_prot_size_o_int),

   .sram_init_done_i (cfg_sram_init_done_int), 

   .fctlr_base_addr_o(fctlr_base_addr_o_int),
   .fctlr_upr_addr_o (fctlr_upr_addr_o_int ),

   .fctlr_rb_lpi_discon_deny_o(rb_pwr_deny_int),

   .cfg_irq_req_i   (cfg_irq_req_int),
   .cfg_irq_type_i  (cfg_irq_type_int),
   .cfg_irq_fw_id_i (cfg_irq_fw_id_int),

   .fw_pid0_o       (fw_pid0_o_int),
   .fw_pid1_o       (fw_pid1_o_int),
   .fw_pid2_o       (fw_pid2_o_int),
   .fw_pid3_o       (fw_pid3_o_int),
   .fw_pid4_o       (fw_pid4_o_int),

   .fw_cid0_o       (fw_cid0_o_int),
   .fw_cid1_o       (fw_cid1_o_int),
   .fw_cid2_o       (fw_cid2_o_int),
   .fw_cid3_o       (fw_cid3_o_int),

   .lpi_prot_size_sample_i (rb_prot_en_o_int),
   .ctrl_st_xfer_req        (ctrl_st_xfer_req_wire),
   .ctrl_st_xfer_ack        (gate_hold_ack_wire),
   .default_state_i         (default_state_wire),

   .dp_write_tamp_i         (rb_dp_write_tamp_i),
   .dp_read_tamp_i          (rb_dp_read_tamp_i)

);

generate
  if (FW_SRE_LVL == 1) begin : RAM_SRE1

    firewall_f0_ram_wrapper #(
        .DATA_WIDTH (SRAM_WIDTH),
        .ADDR_WIDTH (LOG2_SRAM_SIZE)
    )
    u_firewall_f0_sram (
        .clk         (clk_gated),
        .a           (sram_addr_int),
        .cena        (~sram_cenn_int),
        .global_wena (~sram_wenn_int),
        .q           (sram_data_o_int),
        .d           (sram_data_i_int),
        .DFTRAMBYP   (dftrambyp),
        .DFTRAMHOLD  (dftramhold)
    );

  end
  else begin: RAM_SRE0
    assign sram_data_o_int = {SRAM_WIDTH{1'b0}};
  end
endgenerate

endmodule
