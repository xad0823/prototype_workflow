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


module firewall_f0_ctlr_cfg #(
    `include "firewall_f0_reg_width_params.vh"
    ,
    `include "firewall_f0_ctlr_reg_width_params.vh"
    parameter MSG_SIZE                 = 45,
    parameter LOG2_MSG_SIZE            = 6,
    parameter LOG2_REG_DATA_WIDTH      = 5,
    parameter READ_DATA_SIZE           = 6,
    parameter IRQ_TYPE_WIDTH           = 5,
    parameter REG_ADDR_WIDTH           = 10,
    parameter REG_DATA_WIDTH           = 32,
    parameter REG_ENUM_WIDTH           = 117,
    parameter FW_LDE_LVL               = 1,
    parameter FW_SRE_LVL               = 1,
    parameter TOTAL_FC                 = 14,
    parameter SRAM_WIDTH               = 32,
    parameter LOG2_SRAM_WIDTH          = 5,
    parameter LOG2_SRAM_SIZE           = 12,
    parameter FC_CFG_DATA_W            = 32,
    parameter FC_AXIID_WIDTH           = 2,
    parameter FC_AXIUSER_B_WIDTH       = 1,
    parameter FC_AXIUSER_R_WIDTH       = 1,
    parameter FC_MST_ID_WIDTH          = 8,
    parameter FW_NUM_FC                = 13,
    parameter LOG2_FW_NUM_FC           = 4,
    parameter FC_NUM_RGN               = 4,
    parameter LOG2_FC_NUM_RGN          = 2,
    parameter FC_PE_LVL                = 2,
    parameter FC_MXRS                  = 15,
    parameter FC_MNRS                  = 2,
    parameter FC_RSE_LVL               = 1,
    parameter FC_TE_LVL                = 2,
    parameter FC_NUM_MPE               = 2,
    parameter FC_SINGLE_MST            = 0,
    parameter FC_ME_LVL                = 1,
    parameter FC_INST_SPT              = 1,
    parameter FC_MA_SPT                = 1,
    parameter FC_SEC_SPT               = 1,
    parameter FC_PRIV_SPT              = 1,
    parameter FC_SH_SPT                = 1,
    parameter FC_ID                    = 0,
    parameter FC_SEC_SPT_EXT           = 1,
    parameter FC_MA_SPT_EXT            = 1,
    parameter FC_SH_SPT_EXT            = 1,
    parameter FC_INST_SPT_EXT          = 1,
    parameter FC_PRIV_SPT_EXT          = 1,
    parameter FC_NUM_RGN_EXT           = 1,
    parameter FC_MNRS_EXT              = 1,
    parameter FC_MXRS_EXT              = 1,
    parameter FC_NUM_MPE_EXT           = 1,
    parameter FC_ME_LVL_EXT            = 1,
    parameter FC_RSE_LVL_EXT           = 1,
    parameter FC_PE_LVL_EXT            = 1,
    parameter FC_TE_LVL_EXT            = 1,
    parameter FC_SINGLE_MST_EXT        = 1,
    parameter FW_ID_WIDTH              = 5,
    parameter CHECK_RWE_DATA           = 3'b000,
    parameter CHECK_RWE_MPL            = 3'b001,
    parameter CHECK_RWE_EN             = 3'b010,
    parameter CHECK_RWE_LOCK           = 3'b011,
    parameter CHECK_FW_LOCK            = 3'b100,
    parameter CHECK_LDE                = 3'b101,
    parameter FC_RGN_BASE_ADDR_EXT     = 0,
    parameter FC_RGN_UPR_ADDR_EXT      = 0,
    parameter FC_RGN_SIZE_EXT          = 0,
    parameter FC_RGN_MULNPO2_EXT       = 0,
    parameter FC_MST_ID_EXT            = 0,
    parameter FW_CFG_AGENT_MST_ID      = 0,
    parameter FC_MST_ID_SINGLE_MST_EXT = 0,
    parameter FC_BAS_REG_SLC           = 0,
    parameter FW_MAX_MST_ID_WIDTH      = 8,
    parameter FC_MST_ID_WIDTH_EXT      = 8,
    parameter MAX_NUM_OF_PKTS          = 2,
    parameter MSG_SIZE_WIDTH           = 1

) (
    input  wire                                        clk,
    input  wire                                        reset_n,

    input  wire                                        cfg_tvalid_ds_i,
    output wire                                        cfg_tready_ds_o,
    input  wire [FC_CFG_DATA_W-1:0]                    cfg_tdata_ds_i,
    input  wire [(FC_CFG_DATA_W/8)-1:0]                cfg_tkeep_ds_i,
    input  wire                                        cfg_tlast_ds_i,
    input  wire [LOG2_FW_NUM_FC-1:0]                   cfg_tid_ds_i,
    input  wire                                        cfg_twakeup_ds_i,
    output wire                                        cfg_tvalid_us_o,
    input  wire                                        cfg_tready_us_i,
    output wire [FC_CFG_DATA_W-1:0]                    cfg_tdata_us_o,
    output wire [(FC_CFG_DATA_W/8)-1:0]                cfg_tkeep_us_o,
    output wire                                        cfg_tlast_us_o,
    output wire [LOG2_FW_NUM_FC-1:0]                   cfg_tdest_us_o,
    output wire                                        cfg_twakeup_us_o,

    input  wire [FC_AXIID_WIDTH-1:0]                   cfg_arid_i,
    input  wire [REG_ADDR_WIDTH-1:0]                   cfg_araddr_i,
    input  wire                                        cfg_arvalid_i,
    output wire                                        cfg_arready_o,
    input  wire [FC_AXIID_WIDTH-1:0]                   cfg_awid_i,
    input  wire [REG_ADDR_WIDTH-1:0]                   cfg_awaddr_i,
    input  wire                                        cfg_awvalid_i,
    output wire                                        cfg_awready_o,
    input  wire [REG_DATA_WIDTH-1:0]                   cfg_wdata_i,
    input  wire                                        cfg_wvalid_i,
    output wire                                        cfg_wready_o,
    output wire [FC_AXIID_WIDTH-1:0]                   cfg_bid_o,
    output wire [1:0]                                  cfg_bresp_o,
    output wire [FC_AXIUSER_B_WIDTH-1:0]               cfg_buser_o,
    output wire                                        cfg_bvalid_o,
    input  wire                                        cfg_bready_i,
    output wire [FC_AXIID_WIDTH-1:0]                   cfg_rid_o,
    output wire [REG_DATA_WIDTH-1:0]                   cfg_rdata_o,
    output wire [1:0]                                  cfg_rresp_o,
    output wire                                        cfg_rlast_o,
    output wire [FC_AXIUSER_R_WIDTH-1:0]               cfg_ruser_o,
    output wire                                        cfg_rvalid_o,
    input  wire                                        cfg_rready_i,
    input  wire [FW_ID_WIDTH-1:0]                      cfg_w_fw_id_i,
    input  wire [FW_ID_WIDTH-1:0]                      cfg_r_fw_id_i,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_w_mst_id_i,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_r_mst_id_i,
    output wire [FC_MST_ID_WIDTH-1:0]                  cfg_r_mst_id_o,
    input  wire [REG_ENUM_WIDTH-1:0]                   cfg_enum_w_addr_i,
    input  wire [REG_ENUM_WIDTH-1:0]                   cfg_enum_r_addr_i,
    input  wire [2:0]                                  cfg_awprot_i,
    input  wire [2:0]                                  cfg_arprot_i,

    output wire                                        cfg_reg_tamp_o,
    output wire                                        cfg_reg_tamp_w_o,
    input  wire [8*FW_NUM_FC-1:0]                      cfg_prot_size_i,
    output wire                                        cfg_sram_init_done_o,

    input  wire [FW_CTRL_WIDTH-1:0]                    cfg_fw_ctrl_i,
    output wire                                        cfg_fw_ctrl_en,
    output wire [FW_CTRL_WIDTH-1:0]                    cfg_fw_ctrl_o,

    input  wire [FW_ST_WIDTH-1:0]                      cfg_fw_st_i,

    input  wire [FW_SR_CTRL_WIDTH-1:0]                 cfg_fw_sr_ctrl_i,
    output wire                                        cfg_fw_sr_ctrl_en,
    output wire [FW_SR_CTRL_WIDTH-1:0]                 cfg_fw_sr_ctrl_o,

    input  wire [PE_BPS_WIDTH-1:0]                     cfg_pe_bps_i,

    input  wire [FW_INT_ST_WIDTH-1:0]                  cfg_fw_int_st_i,

    input  wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]         cfg_ld_ctrl_i,
    output wire [TOTAL_FC-1:0]                         cfg_ld_ctrl_en,
    output wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]         cfg_ld_ctrl_o,

    input  wire [PE_CTRL_WIDTH-1:0]                    cfg_pe_ctrl_i,
    output wire                                        cfg_pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                    cfg_pe_ctrl_o,

    input  wire [PE_ST_WIDTH-1:0]                      cfg_pe_st_i,

    input  wire [RWE_CTRL_WIDTH-1:0]                   cfg_rwe_ctrl_i,
    output wire                                        cfg_rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]                   cfg_rwe_ctrl_o,

    input  wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     cfg_rgn_ctrl0_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_ctrl0_en,
    output wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     cfg_rgn_ctrl0_o,
    input  wire [RGN_CTRL0_WIDTH-1:0]                  cfg_rgn_ctrl0_rgn_i,

    input  wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     cfg_rgn_ctrl1_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_ctrl1_en,
    input  wire [RGN_CTRL1_WIDTH-1:0]                  cfg_rgn_ctrl1_rgn_i,
    output wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     cfg_rgn_ctrl1_o,

    input  wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     cfg_rgn_lctrl_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_lctrl_en,
    input  wire [RGN_LCTRL_WIDTH-1:0]                  cfg_rgn_lctrl_rgn_i,
    output wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     cfg_rgn_lctrl_o,

    input  wire [RGN_ST_WIDTH-1:0]                     cfg_rgn_st_rgn_i,

    input  wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      cfg_rgn_cfg0_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_cfg0_en,
    input  wire [RGN_CFG0_WIDTH-1:0]                   cfg_rgn_cfg0_rgn_i,
    output wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      cfg_rgn_cfg0_o,

    input  wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      cfg_rgn_cfg1_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_cfg1_en,
    input  wire [RGN_CFG1_WIDTH-1:0]                   cfg_rgn_cfg1_rgn_i,
    output wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      cfg_rgn_cfg1_o,

    input  wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      cfg_rgn_size_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_size_en,
    input  wire [RGN_SIZE_WIDTH-1:0]                   cfg_rgn_size_rgn_i,
    output wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      cfg_rgn_size_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     cfg_rgn_tcfg0_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_tcfg0_en,
    input  wire [RGN_TCFG0_WIDTH-1:0]                  cfg_rgn_tcfg0_rgn_i,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     cfg_rgn_tcfg0_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     cfg_rgn_tcfg1_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_tcfg1_en,
    input  wire [RGN_TCFG1_WIDTH-1:0]                  cfg_rgn_tcfg1_rgn_i,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     cfg_rgn_tcfg1_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     cfg_rgn_tcfg2_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_tcfg2_en,
    input  wire [RGN_TCFG2_WIDTH-1:0]                  cfg_rgn_tcfg2_rgn_i,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     cfg_rgn_tcfg2_o,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid0_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mid0_en,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_rgn_mid0_rgn_i,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid0_o,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid1_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mid1_en,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_rgn_mid1_rgn_i,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid1_o,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid2_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mid2_en,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_rgn_mid2_rgn_i,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid2_o,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid3_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mid3_en,
    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_rgn_mid3_rgn_i,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     cfg_rgn_mid3_o,

    input  wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      cfg_rgn_mpl0_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mpl0_en,
    input  wire [RGN_MPL0_WIDTH-1:0]                   cfg_rgn_mpl0_rgn_i,
    output wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      cfg_rgn_mpl0_o,

    input  wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      cfg_rgn_mpl1_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mpl1_en,
    input  wire [RGN_MPL1_WIDTH-1:0]                   cfg_rgn_mpl1_rgn_i,
    output wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      cfg_rgn_mpl1_o,

    input  wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      cfg_rgn_mpl2_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mpl2_en,
    input  wire [RGN_MPL2_WIDTH-1:0]                   cfg_rgn_mpl2_rgn_i,
    output wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      cfg_rgn_mpl2_o,

    input  wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      cfg_rgn_mpl3_i,
    output wire [FC_NUM_RGN-1:0]                       cfg_rgn_mpl3_en,
    input  wire [RGN_MPL3_WIDTH-1:0]                   cfg_rgn_mpl3_rgn_i,
    output wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      cfg_rgn_mpl3_o,

    input  wire [FE_TAL_WIDTH-1:0]                     cfg_fe_tal_i,

    input  wire [FE_TAU_WIDTH-1:0]                     cfg_fe_tau_i,

    input  wire [FE_TP_WIDTH-1:0]                      cfg_fe_tp_i,

    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_fe_mid_i,

    input  wire [FE_CTRL_WIDTH-1:0]                    cfg_fe_ctrl_i,
    output wire                                        cfg_fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                    cfg_fe_ctrl_o,

    input  wire [ME_CTRL_WIDTH-1:0]                    cfg_me_ctrl_i,
    output wire                                        cfg_me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                    cfg_me_ctrl_o,

    input  wire [ME_ST_WIDTH-1:0]                      cfg_me_st_i,

    input  wire [EDR_TAL_WIDTH-1:0]                    cfg_edr_tal_i,

    input  wire [EDR_TAU_WIDTH-1:0]                    cfg_edr_tau_i,

    input  wire [EDR_TP_WIDTH-1:0]                     cfg_edr_tp_i,

    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_edr_mid_i,

    input  wire [EDR_CTRL_WIDTH-1:0]                   cfg_edr_ctrl_i,
    output wire                                        cfg_edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]                   cfg_edr_ctrl_o,

    input  wire [(32*FC_INT_ST_WIDTH)-1:0]             cfg_fc_int_st_i,
    output wire [31:0]                                 cfg_fc_int_st_en,
    output wire [(32*FC_INT_ST_WIDTH)-1:0]             cfg_fc_int_st_o,

    input  wire [(32*FC_INT_MSK_WIDTH)-1:0]            cfg_fc_int_msk_i,
    output wire [31:0]                                 cfg_fc_int_msk_en,
    output wire [(32*FC_INT_MSK_WIDTH)-1:0]            cfg_fc_int_msk_o,

    input  wire [FW_TMP_TA_WIDTH-1:0]                  cfg_fw_tmp_ta_i,

    input  wire [FW_TMP_TP_WIDTH-1:0]                  cfg_fw_tmp_tp_i,

    input  wire [FC_MST_ID_WIDTH-1:0]                  cfg_fw_tmp_mid_i,

    input  wire [FW_TMP_CTRL_WIDTH-1:0]                cfg_fw_tmp_ctrl_i,
    output wire                                        cfg_fw_tmp_ctrl_en,
    output wire [FW_TMP_CTRL_WIDTH-1:0]                cfg_fw_tmp_ctrl_o,

    input  wire [IIDR_WIDTH-1:0]                       cfg_iidr_i,

    input  wire [AIDR_WIDTH-1:0]                       cfg_aidr_i,

    output wire                                        cfg_irq_req_o,
    output wire [IRQ_TYPE_WIDTH-1:0]                   cfg_irq_type_o,
    output wire [LOG2_FW_NUM_FC-1:0]                   cfg_irq_fw_id_o,

    output wire [FW_NUM_FC-1:0]                        cfg_pwr_st_o,
    output wire [FW_NUM_FC-1:0]                        cfg_pwr_st_en_o,
    input  wire [FW_NUM_FC-1:0]                        cfg_pwr_st_i,

    output wire                                        cfg_restore_done_o,

    output wire [LOG2_SRAM_SIZE-1:0]                   cfg_sram_addr_o,
    output wire                                        cfg_sram_cenn_o,
    output wire                                        cfg_sram_wenn_o,
    output wire [SRAM_WIDTH-1:0]                       cfg_sram_data_o,
    input  wire [SRAM_WIDTH-1:0]                       cfg_sram_data_i,

    input  wire                                        cfg_lpi_hold_i,
    output wire                                        cfg_lpi_clk_busy_o,
    output wire                                        cfg_lpi_ram_req_o,
    input  wire                                        cfg_lpi_ram_ack_i,
    input  wire                                        cfg_lpi_ram_init_i,
    input  wire                                        cfg_default_state_i,

    output wire                                        cfg_gate_bas_o

);


`include "firewall_f0_msg_prot_types.vh"


localparam CHECK_TYPE_WIDTH = 3;
localparam MAX_NUM_RGN      = 64;
localparam ADDER_WIDTH      = LOG2_SRAM_SIZE;
localparam N_MEM_RET        = 1;


wire [FC_CFG_DATA_W-1:0]  ds_o_data_int ;
wire                      ds_o_last_int ;
wire                      ds_o_valid_int;
wire [LOG2_FW_NUM_FC-1:0] ds_o_tid_int  ;

wire ds_busy_int     ;
wire us_busy_int     ;
wire accrtr_busy_int ;
wire msgdec_busy_int ;
wire rdhnd_busy_int  ;
wire wrhnd_busy_int  ;
wire regctlr_busy_int;
wire addrdec_busy_int;
wire prtcnv_busy_int ;

wire [MSG_SIZE-1:0]            msgcrt_o_msg_int  ;
wire [MSG_SIZE_WIDTH-1:0]      msgcrt_o_size_int ;
wire                           msgcrt_o_valid_int;
wire [LOG2_FW_NUM_FC-1:0]      msgcrt_o_id_int   ;

wire                           us_o_block_int    ;
wire                           us_pkt_sent_int    ;
wire                           us_last_sent_int    ;

wire [REG_ADDR_WIDTH-1:0]      accrtr_o_reg_addr_int ;
wire                           accrtr_o_rw_int       ;
wire [FW_ID_WIDTH-1:0]         accrtr_o_fw_id_int    ;
wire [LOG2_FW_NUM_FC-1:0]      accrtr_o_fc_id_int    ;
wire [FC_CFG_DATA_W-1:0]       accrtr_o_wr_data_int  ;
wire [READ_DATA_SIZE-1:0]      accrtr_o_reg_size_int ;
wire                           accrtr_o_acc_valid_int;
wire                           accrtr_o_shdw_hit_chk_need_int;
wire [CHECK_TYPE_WIDTH-1:0]    accrtr_o_shdw_hit_chk_type_int;
wire [LOG2_SRAM_SIZE-1:0]      accrtr_o_shdw_sram_row_int;
wire [LOG2_SRAM_WIDTH-1:0]     accrtr_o_shdw_sram_col_int;
wire [READ_DATA_SIZE-1:0]      accrtr_o_shdw_reg_size_int;
wire                           accrtr_o_shdw_wr_rsp_pend_int;
wire                           accrtr_o_shdw_hit_valid_int;
wire                           accrtr_o_shdw_fixed_int;
wire                           accrtr_o_reg_ctlr_valid_o;
wire                           accrtr_o_rd_hndlr_rsp_o  ;
wire                           accrtr_o_rd_hndlr_tamp_o ;
wire [REG_DATA_WIDTH-1:0]      accrtr_o_rd_hndlr_data_o ;
wire                           accrtr_o_rd_hndlr_valid_o;
wire                           accrtr_o_wr_hndlr_rsp_int;
wire                           accrtr_o_wr_hndlr_tamp_int;
wire                           accrtr_o_wr_hndlr_valid_int;

wire [REG_ADDR_WIDTH-1:0]                   addrdec_o_reg_addr_int    ;
wire                                        addrdec_o_rw_int          ;
wire [FW_ID_WIDTH-1:0]                      addrdec_o_fw_id_int       ;
wire [LOG2_FW_NUM_FC-1:0]                   addrdec_o_fc_id_int       ;
wire [REG_DATA_WIDTH-1:0]                   addrdec_o_reg_rd_data_int ;
wire [REG_DATA_WIDTH-1:0]                   addrdec_o_wr_data_int     ;
wire                                        addrdec_o_hit_int         ;
wire                                        addrdec_o_hit_chk_need_int;
wire [CHECK_TYPE_WIDTH-1:0]                 addrdec_o_hit_chk_type_int;
wire [LOG2_SRAM_SIZE-1:0]                   addrdec_o_sram_row_int    ;
wire [LOG2_SRAM_WIDTH-1:0]                  addrdec_o_sram_col_int    ;
wire [READ_DATA_SIZE-1:0]                   addrdec_o_reg_size_int    ;
wire                                        addrdec_o_wr_rsp_pend_int;
wire                                        addrdec_o_fixed_int        ;
wire                                        addrdec_o_read_only_int    ;
wire                                        addrdec_o_tamper_int       ;
wire                                        addrdec_o_wr_allow_fctlr_int;
wire                                        addrdec_o_ctlr_n_comp_int;
wire                                        addrdec_o_acc_valid_int   ;
wire                                        addrdec_o_raz_discon_int  ;
wire                                        addrdec_o_wi_discon_int   ;
wire [ADDER_WIDTH-1:0]                      addrdec_add_op1_int;
wire [ADDER_WIDTH-1:0]                      addrdec_add_op2_int;
wire                                        addrdec_add_en_int;
wire [FW_CTRL_WIDTH-1:0]                    addr_dec_fw_ctrl_o_int;
wire                                        addr_dec_fw_ctrl_en_int;
wire [FW_SR_CTRL_WIDTH-1:0]                 addr_dec_fw_sr_ctrl_o_int;
wire                                        addr_dec_fw_sr_ctrl_en_int;
wire [((TOTAL_FC)*LD_CTRL_WIDTH)-1:0]       addr_dec_ld_ctrl_o_int;
wire [TOTAL_FC-1:0]                         addr_dec_ld_ctrl_en_int;
wire [PE_CTRL_WIDTH-1:0]                    addr_dec_pe_ctrl_o_int;
wire                                        addr_dec_pe_ctrl_en_int;
wire [RWE_CTRL_WIDTH-1:0]                   addr_dec_rwe_ctrl_o_int;
wire                                        addr_dec_rwe_ctrl_en_int;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     addr_dec_rgn_ctrl0_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_ctrl0_en_int;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     addr_dec_rgn_ctrl1_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_ctrl1_en_int;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     addr_dec_rgn_lctrl_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_lctrl_en_int;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      addr_dec_rgn_cfg0_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_cfg0_en_int;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      addr_dec_rgn_cfg1_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_cfg1_en_int;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      addr_dec_rgn_size_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_size_en_int;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     addr_dec_rgn_tcfg0_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg0_en_int;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     addr_dec_rgn_tcfg1_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg1_en_int;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     addr_dec_rgn_tcfg2_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg2_en_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid0_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid0_en_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid1_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid1_en_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid2_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid2_en_int;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid3_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid3_en_int;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      addr_dec_rgn_mpl0_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl0_en_int;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      addr_dec_rgn_mpl1_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl1_en_int;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      addr_dec_rgn_mpl2_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl2_en_int;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      addr_dec_rgn_mpl3_o_int;
wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl3_en_int;
wire [FE_CTRL_WIDTH-1:0]                    addr_dec_fe_ctrl_o_int;
wire                                        addr_dec_fe_ctrl_en_int;
wire [ME_CTRL_WIDTH-1:0]                    addr_dec_me_ctrl_o_int;
wire                                        addr_dec_me_ctrl_en_int;
wire [EDR_CTRL_WIDTH-1:0]                   addr_dec_edr_ctrl_o_int;
wire                                        addr_dec_edr_ctrl_en_int;
wire [(32*FC_INT_ST_WIDTH)-1:0]             addr_dec_fc_int_st_o_int;
wire [31:0]                                 addr_dec_fc_int_st_en_int;
wire [(32*FC_INT_MSK_WIDTH)-1:0]            addr_dec_fc_int_msk_o_int;
wire [31:0]                                 addr_dec_fc_int_msk_en_int;
wire [FW_TMP_CTRL_WIDTH-1:0]                addr_dec_fw_tmp_ctrl_o_int;
wire                                        addr_dec_fw_tmp_ctrl_en_int;
wire [RWE_CTRL_WIDTH-1:0]                   addr_dec_shdw_rgn_int;
wire [FW_NUM_FC-1:0]                        addr_dec_shdw_rgn_en_int;
wire [REG_DATA_WIDTH-1:0]                   addrdec_o_frmt_rd_data_int;
wire                                        addr_dec_rd_rgn_st_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_lctrl_op1_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_lctrl_op2_o_int;
wire [LOG2_SRAM_WIDTH-1:0]                  addr_dec_shdw_rgn_lctrl_col_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_ctrl0_op1_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_ctrl0_op2_o_int;
wire [LOG2_SRAM_WIDTH-1:0]                  addr_dec_shdw_rgn_ctrl0_col_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_ctrl1_op1_o_int;
wire [LOG2_SRAM_SIZE-1:0]                   addr_dec_shdw_rgn_ctrl1_op2_o_int;
wire [LOG2_SRAM_WIDTH-1:0]                  addr_dec_shdw_rgn_ctrl1_col_o_int;
wire [3:0]                                  addr_dec_shdw_mpe_o_int;

wire [FC_CFG_DATA_W-1:0]  msgdec_o_rd_data_int ;
wire                      msgdec_o_rd_last_int ;
wire                      msgdec_o_rd_valid_int;
wire                      msgdec_o_wr_rsp_int  ;
wire                      msgdec_o_wr_tamp_int ;
wire                      msgdec_o_wr_valid_int;
wire [1:0]                msgdec_o_pwr_con_req_int;
wire                      msgdec_o_pwr_discon_req_int;
wire                      msgdec_o_pwr_valid_int;
wire [LOG2_FW_NUM_FC-1:0] msgdec_o_pwr_fw_id_int;

wire [1:0]                 rdhnd_o_rsp_o   ;
wire                       rdhnd_o_tamp_o  ;
wire                       rdhnd_o_valid_o ;
wire [REG_DATA_WIDTH-1:0]  rdhnd_o_data_o  ;
wire [FC_MST_ID_WIDTH-1:0] rdhnd_mst_id_o  ;
wire [FC_AXIID_WIDTH-1:0]  rdhnd_rid_o  ;
wire [REG_DATA_WIDTH-1:0]  rdhnd_o_unfrmt_rd_data_int;

wire [1:0]                 wrhnd_o_rsp_int  ;
wire                       wrhnd_o_tamp_int ;
wire                       wrhnd_o_valid_int;
wire [FC_AXIID_WIDTH-1:0]  wrhnd_o_bid_int;

wire       regctlr_o_wr_valid_int;

wire [REG_ADDR_WIDTH-1:0]  prtcnv_o_reg_addr_int;
wire [REG_ENUM_WIDTH-1:0]  prtcnv_o_reg_enum_addr_int;
wire                       prtcnv_o_cfg_active_int;
wire                       prtcnv_o_trkr_int;
wire                       prtcnv_o_cfg_pend_int;
wire                       prtcnv_o_rw_int;
wire [FW_ID_WIDTH-1:0]     prtcnv_o_fw_id_int;
wire [LOG2_FW_NUM_FC-1:0]  prtcnv_o_fc_id_int;
wire [REG_DATA_WIDTH-1:0]  prtcnv_o_wr_data_int;
wire                       prtcnv_o_acc_valid_int;
wire [FC_MST_ID_WIDTH-1:0] prtcnv_o_r_mst_id_int;
wire [FC_AXIID_WIDTH-1:0]  prtcnv_o_w_bid_int;
wire [FC_AXIID_WIDTH-1:0]  prtcnv_o_r_rid_int;
wire [FC_MST_ID_WIDTH-1:0] prtcnv_o_mst_id_int;
wire [1:0]                 prtcnv_o_axprot_int;

wire [LOG2_FW_NUM_FC-1:0]             shdwctlr_o_fw_id_int;
wire [SRAM_WIDTH-1:0]                 shdwctlr_o_restore_data_int;
wire                                  shdwctlr_o_first_restore_data_int;
wire                                  shdwctlr_o_restore_valid_int;
wire                                  shdwctlr_o_cfg_valid_int;
wire                                  shdwctlr_o_wr_rsp_int;
wire                                  shdwctlr_o_wr_tamp_int;
wire                                  shdwctlr_o_wr_valid_int;
wire [REG_DATA_WIDTH-1:0]             shdwctlr_o_rd_data_int;
wire                                  shdwctlr_o_rd_valid_int;
wire                                  shdwctlr_o_prot_block_int;
wire                                  shdwctlr_o_us_last_pkt_int;
wire [ADDER_WIDTH-1:0]                shdwctlr_o_add_op1_int;
wire [ADDER_WIDTH-1:0]                shdwctlr_o_add_op2_int;
wire                                  shdwctlr_o_add_en_int;
wire                                  shdwctlr_o_restore_done_int;
wire [LOG2_FW_NUM_FC-1:0]             shdwctlr_o_restore_fw_id_int;
wire [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0] shdwctlr_o_rgn_int;
wire [FW_NUM_FC-1:0]                  shdwctlr_o_wr_aft_dsc_int;
wire [FW_NUM_FC-1:0]                  shdwctlr_o_wr_aft_rst_int;
wire                                  shdwctlr_o_clk_busy_int;

assign cfg_restore_done_o = shdwctlr_o_restore_done_int;

wire                      cmppwr_o_prot_block_int;
wire                      cmppwr_o_hndshk_pend_int;
wire                      cmppwr_restore_req_int;
wire [LOG2_FW_NUM_FC-1:0] cmppwr_restore_fw_id_int;
wire                      cmppwr_o_restore_valid_int;
wire [LOG2_FW_NUM_FC-1:0] cmppwr_o_con_fw_id_int;
wire                      cmppwr_o_con_valid_int;
wire                      cmppwr_o_shdw_con_valid_int;
wire [LOG2_FW_NUM_FC-1:0] cmppwr_o_shdw_con_fw_id_int;
wire                      cmppwr_o_discon_valid_int;
wire                      cmppwr_o_clk_busy_int;

wire [ADDER_WIDTH-1:0]    add_res_int;


firewall_f0_ctlr_a4s_ds_fsm #(
    .FC_CFG_DATA_W  (FC_CFG_DATA_W ),
    .LOG2_FW_NUM_FC (LOG2_FW_NUM_FC),
    .FC_BAS_REG_SLC (FC_BAS_REG_SLC)
) u_firewall_f0_ctlr_a4s_ds_fsm (
    .clk            (clk    ),
    .reset_n        (reset_n),
    .tvalid_ds_i    (cfg_tvalid_ds_i ),
    .tready_ds_o    (cfg_tready_ds_o ),
    .tdata_ds_i     (cfg_tdata_ds_i  ),
    .tkeep_ds_i     (cfg_tkeep_ds_i  ),
    .tlast_ds_i     (cfg_tlast_ds_i  ),
    .tid_ds_i       (cfg_tid_ds_i    ),
    .twakeup_ds_i   (cfg_twakeup_ds_i),
    .a4s_data_o     (ds_o_data_int ),
    .a4s_last_o     (ds_o_last_int ),
    .a4s_valid_o    (ds_o_valid_int),
    .a4s_tid_o      (ds_o_tid_int  ),
    .a4s_lpi_hold_i (cfg_lpi_hold_i   ),
    .a4s_lpi_busy_o (ds_busy_int      ),
    .a4s_gate_bas_o (cfg_gate_bas_o   )
);

firewall_f0_ctlr_a4s_us_fsm #(
    .FC_CFG_DATA_W               (FC_CFG_DATA_W      ),
    .LOG2_FW_NUM_FC              (LOG2_FW_NUM_FC     ),
    .MSG_SIZE                    (MSG_SIZE           ),
    .MSG_SIZE_WIDTH              (MSG_SIZE_WIDTH     ),
    .FW_SRE_LVL                  (FW_SRE_LVL         )
) u_firewall_f0_ctlr_a4s_us_fsm (
    .clk                         (clk    ),
    .reset_n                     (reset_n),
    .tvalid_us_o                 (cfg_tvalid_us_o ),
    .tready_us_i                 (cfg_tready_us_i ),
    .tdata_us_o                  (cfg_tdata_us_o  ),
    .tkeep_us_o                  (cfg_tkeep_us_o  ),
    .tlast_us_o                  (cfg_tlast_us_o  ),
    .tdest_us_o                  (cfg_tdest_us_o  ),
    .twakeup_us_o                (cfg_twakeup_us_o),
    .a4s_up_msg_i                (msgcrt_o_msg_int  ),
    .a4s_up_msg_size_i           (msgcrt_o_size_int ),
    .a4s_up_msg_valid_i          (msgcrt_o_valid_int),
    .a4s_up_msg_fw_id_i          (msgcrt_o_id_int   ),
    .a4s_up_prot_block_o         (us_o_block_int),
    .a4s_up_pkt_sent_o           (us_pkt_sent_int),
    .a4s_up_last_pkt_i           (shdwctlr_o_us_last_pkt_int),
    .a4s_up_first_restore_data_i (shdwctlr_o_first_restore_data_int),
    .a4s_us_last_sent_o          (us_last_sent_int),
    .a4s_up_lpi_busy_o           (us_busy_int)
);

firewall_f0_ctlr_message_creator #(
    .LOG2_FW_NUM_FC      (LOG2_FW_NUM_FC     ),
    .FC_CFG_DATA_W       (FC_CFG_DATA_W      ),
    .REG_ADDR_WIDTH      (REG_ADDR_WIDTH     ),
    .MSG_SIZE            (MSG_SIZE           ),
    .FW_SRE_LVL          (FW_SRE_LVL         ),
    .CFG_REQ_T           (CFG_REQ_T          ),
    .CFG_READ_REQ_T      (CFG_READ_REQ_T     ),
    .CFG_WRITE_REQ_T     (CFG_WRITE_REQ_T    ),
    .HNDSHK_RSP_T        (HNDSHK_RSP_T       ),
    .HNDSHK_CNCT_T       (HNDSHK_CNCT_T      ),
    .HNDSHK_DISCNCT_T    (HNDSHK_DISCNCT_T   ),
    .REG_DATA_WIDTH      (REG_DATA_WIDTH     ),
    .LOG2_MSG_SIZE       (LOG2_MSG_SIZE      ),
    .FW_NUM_FC           (FW_NUM_FC          ),
    .READ_DATA_SIZE      (READ_DATA_SIZE     ),
    .MAX_NUM_OF_PKTS     (MAX_NUM_OF_PKTS    ),
    .MSG_SIZE_WIDTH      (MSG_SIZE_WIDTH     )

) u_firewall_f0_ctlr_message_creator (
    .clk     (clk    ),
    .reset_n (reset_n),
    .msg_crtr_pwr_fw_id_i          (cmppwr_o_con_fw_id_int),
    .msg_crtr_con_valid_i          (cmppwr_o_con_valid_int),
    .msg_crtr_discon_valid_i       (cmppwr_o_discon_valid_int),
    .msg_crtr_restore_fw_id_i      (cmppwr_restore_fw_id_int),
    .msg_crtr_reg_addr_i           (accrtr_o_reg_addr_int ),
    .msg_crtr_rw_i                 (accrtr_o_rw_int       ),
    .msg_crtr_fw_id_i              (accrtr_o_fc_id_int    ),
    .msg_crtr_wr_data_i            (accrtr_o_wr_data_int  ),
    .msg_crtr_reg_size_i           (accrtr_o_reg_size_int ),
    .msg_crtr_acc_valid_i          (accrtr_o_acc_valid_int),
    .msg_crtr_restore_valid_i      (shdwctlr_o_restore_valid_int),
    .msg_crtr_restore_data_i       (shdwctlr_o_restore_data_int),
    .msg_crtr_cfg_valid_i          (shdwctlr_o_cfg_valid_int),
    .msg_crtr_msg_data_o           (msgcrt_o_msg_int  ),
    .msg_crtr_msg_size_o           (msgcrt_o_size_int ),
    .msg_crtr_msg_valid_o          (msgcrt_o_valid_int),
    .msg_crtr_id_o                 (msgcrt_o_id_int   ),
    .msg_crtr_prot_size_i          (cfg_prot_size_i)
);

firewall_f0_ctlr_access_router #(
    .REG_ADDR_WIDTH              (REG_ADDR_WIDTH  ),
    .REG_DATA_WIDTH              (REG_DATA_WIDTH  ),
    .FW_NUM_FC                   (FW_NUM_FC       ),
    .LOG2_FW_NUM_FC              (LOG2_FW_NUM_FC  ),
    .READ_DATA_SIZE              (READ_DATA_SIZE  ),
    .CHECK_TYPE_WIDTH            (CHECK_TYPE_WIDTH),
    .LOG2_SRAM_WIDTH             (LOG2_SRAM_WIDTH ),
    .FW_SRE_LVL                  (FW_SRE_LVL ),
    .LOG2_SRAM_SIZE              (LOG2_SRAM_SIZE  ),
    .FW_ID_WIDTH                 (FW_ID_WIDTH  ),
    .FW_LDE_LVL                  (FW_LDE_LVL)
) u_firewall_f0_ctlr_access_router (
    .acc_rtr_reg_addr_i          (addrdec_o_reg_addr_int    ),
    .acc_rtr_rw_i                (addrdec_o_rw_int          ),
    .acc_rtr_fw_id_i             (addrdec_o_fw_id_int       ),
    .acc_rtr_fc_id_i             (addrdec_o_fc_id_int       ),
    .acc_rtr_reg_rd_data_i       (addrdec_o_reg_rd_data_int ),
    .acc_rtr_wr_data_i           (addrdec_o_wr_data_int     ),
    .acc_rtr_hit_i               (addrdec_o_hit_int         ),
    .acc_rtr_hit_chk_need_i      (addrdec_o_hit_chk_need_int),
    .acc_rtr_hit_chk_type_i      (addrdec_o_hit_chk_type_int),
    .acc_rtr_sram_row_i          (addrdec_o_sram_row_int    ),
    .acc_rtr_sram_col_i          (addrdec_o_sram_col_int    ),
    .acc_rtr_reg_size_i          (addrdec_o_reg_size_int    ),
    .acc_rtr_wr_rsp_pend_i       (addrdec_o_wr_rsp_pend_int ),
    .acc_rtr_fixed_i             (addrdec_o_fixed_int       ),
    .acc_rtr_read_only_i         (addrdec_o_read_only_int   ),
    .acc_rtr_tamper_i            (addrdec_o_tamper_int      ),
    .acc_rtr_wr_allow_fctlr_i    (addrdec_o_wr_allow_fctlr_int),
    .acc_rtr_ctlr_n_comp_i       (addrdec_o_ctlr_n_comp_int ),
    .acc_rtr_acc_valid_i         (addrdec_o_acc_valid_int   ),
    .acc_rtr_shdw_hit_chk_need_o (accrtr_o_shdw_hit_chk_need_int),
    .acc_rtr_shdw_hit_chk_type_o (accrtr_o_shdw_hit_chk_type_int),
    .acc_rtr_shdw_sram_row_o     (accrtr_o_shdw_sram_row_int),
    .acc_rtr_shdw_sram_col_o     (accrtr_o_shdw_sram_col_int),
    .acc_rtr_shdw_reg_size_o     (accrtr_o_shdw_reg_size_int),
    .acc_rtr_shdw_wr_rsp_pend_o  (accrtr_o_shdw_wr_rsp_pend_int),
    .acc_rtr_shdw_hit_valid_o    (accrtr_o_shdw_hit_valid_int),
    .acc_rtr_shdw_fixed_o        (accrtr_o_shdw_fixed_int),
    .acc_rtr_msg_valid_o         (accrtr_o_acc_valid_int),
    .acc_rtr_msg_reg_size_o      (accrtr_o_reg_size_int ),
    .acc_rtr_reg_ctlr_valid_o    (accrtr_o_reg_ctlr_valid_o),
    .acc_rtr_rd_hndlr_rsp_o      (accrtr_o_rd_hndlr_rsp_o  ),
    .acc_rtr_rd_hndlr_tamp_o     (accrtr_o_rd_hndlr_tamp_o ),
    .acc_rtr_rd_hndlr_data_o     (accrtr_o_rd_hndlr_data_o ),
    .acc_rtr_rd_hndlr_valid_o    (accrtr_o_rd_hndlr_valid_o),
    .acc_rtr_wr_hndlr_rsp_o      (accrtr_o_wr_hndlr_rsp_int),
    .acc_rtr_wr_hndlr_tamp_o     (accrtr_o_wr_hndlr_tamp_int),
    .acc_rtr_wr_hndlr_valid_o    (accrtr_o_wr_hndlr_valid_int),
    .acc_rtr_reg_addr_o          (accrtr_o_reg_addr_int),
    .acc_rtr_rw_o                (accrtr_o_rw_int      ),
    .acc_rtr_fw_id_o             (accrtr_o_fw_id_int   ),
    .acc_rtr_fc_id_o             (accrtr_o_fc_id_int   ),
    .acc_rtr_wr_data_o           (accrtr_o_wr_data_int ),
    .acc_rtr_clk_busy_o          (accrtr_busy_int),
    .acc_rtr_comp_pwr_st_i       (cfg_pwr_st_i)
);

firewall_f0_ctlr_msg_dec #(
    .FC_CFG_DATA_W            (FC_CFG_DATA_W ),
    .LOG2_FW_NUM_FC           (LOG2_FW_NUM_FC),
    .IRQ_TYPE_WIDTH           (IRQ_TYPE_WIDTH),
    .REG_DATA_WIDTH           (REG_DATA_WIDTH),
    .FW_LDE_LVL               (FW_LDE_LVL)
) u_firewall_f0_ctlr_msg_dec (
    .clk                      (clk    ),
    .reset_n                  (reset_n),
    .msg_dec_a4s_data_i       (ds_o_data_int ),
    .msg_dec_a4s_last_i       (ds_o_last_int ),
    .msg_dec_a4s_valid_i      (ds_o_valid_int),
    .msg_dec_a4s_tid_i        (ds_o_tid_int  ),
    .msg_dec_pwr_con_req_o    (msgdec_o_pwr_con_req_int),
    .msg_dec_pwr_discon_req_o (msgdec_o_pwr_discon_req_int),
    .msg_dec_pwr_valid_o      (msgdec_o_pwr_valid_int),
    .msg_dec_pwr_fw_id_o      (msgdec_o_pwr_fw_id_int),
    .msg_dec_irq_req_o        (cfg_irq_req_o),
    .msg_dec_irq_type_o       (cfg_irq_type_o),
    .msg_dec_irq_fw_id_o      (cfg_irq_fw_id_o),
    .msg_dec_rd_data_o        (msgdec_o_rd_data_int ),
    .msg_dec_rd_last_o        (msgdec_o_rd_last_int ),
    .msg_dec_rd_valid_o       (msgdec_o_rd_valid_int),
    .msg_dec_wr_rsp_o         (msgdec_o_wr_rsp_int  ),
    .msg_dec_wr_tamp_o        (msgdec_o_wr_tamp_int ),
    .msg_dec_wr_valid_o       (msgdec_o_wr_valid_int),
    .msg_dec_lpi_clk_busy_o   (msgdec_busy_int)
);

firewall_f0_ctlr_rd_hndlr #(
    .REG_DATA_WIDTH            (REG_DATA_WIDTH),
    .FC_CFG_DATA_W             (FC_CFG_DATA_W ),
    .FC_MST_ID_WIDTH           (FC_MST_ID_WIDTH),
    .FC_AXIID_WIDTH            (FC_AXIID_WIDTH),
    .FW_LDE_LVL                (FW_LDE_LVL),
    .FW_SRE_LVL                (FW_SRE_LVL)
) u_firewall_f0_ctlr_rd_hndlr (
    .clk                       (clk    ),
    .reset_n                   (reset_n),
    .rd_hndlr_acc_rd_data_i    (accrtr_o_rd_hndlr_data_o ),
    .rd_hndlr_acc_rd_rsp_i     (accrtr_o_rd_hndlr_rsp_o  ),
    .rd_hndlr_acc_rd_tamp_i    (accrtr_o_rd_hndlr_tamp_o ),
    .rd_hndlr_acc_valid_i      (accrtr_o_rd_hndlr_valid_o),
    .rd_hndlr_msg_rd_data_i    (msgdec_o_rd_data_int),
    .rd_hndlr_rd_last_i        (msgdec_o_rd_last_int),
    .rd_hndlr_msg_valid_i      (msgdec_o_rd_valid_int),
    .rd_hndlr_shdw_rd_data_i   (shdwctlr_o_rd_data_int),
    .rd_hndlr_shdw_valid_i     (shdwctlr_o_rd_valid_int),
    .rd_hndlr_rsp_o            (rdhnd_o_rsp_o  ),
    .rd_hndlr_tamp_o           (rdhnd_o_tamp_o ),
    .rd_hndlr_valid_o          (rdhnd_o_valid_o),
    .rd_hndlr_data_o           (rdhnd_o_data_o ),
    .rd_hndlr_mst_id_o         (rdhnd_mst_id_o ),
    .rd_hndlr_mst_id_i         (prtcnv_o_r_mst_id_int ),
    .rd_hndlr_rid_i            (prtcnv_o_r_rid_int ),
    .rd_hndlr_rid_o            (rdhnd_rid_o ),
    .rd_hndlr_unfrmt_rd_data_o (rdhnd_o_unfrmt_rd_data_int),
    .rd_hndlr_frmt_rd_data_i   (addrdec_o_frmt_rd_data_int),
    .rd_hndlr_clk_busy_o       (rdhnd_busy_int)
);

firewall_f0_ctlr_wr_hndlr #(
    .FW_LDE_LVL            (FW_LDE_LVL),
    .FC_MST_ID_WIDTH       (FC_MST_ID_WIDTH),
    .FC_AXIID_WIDTH        (FC_AXIID_WIDTH),
    .FW_SRE_LVL            (FW_SRE_LVL)
) u_firewall_f0_ctlr_wr_hndlr (
    .clk                   (clk    ),
    .reset_n               (reset_n),
    .wr_hndlr_ctlr_valid_i (regctlr_o_wr_valid_int),
    .wr_hndlr_msg_rsp_i    (msgdec_o_wr_rsp_int  ),
    .wr_hndlr_msg_tamp_i   (msgdec_o_wr_tamp_int ),
    .wr_hndlr_msg_valid_i  (msgdec_o_wr_valid_int),
    .wr_hndlr_acc_rsp_i    (accrtr_o_wr_hndlr_rsp_int),
    .wr_hndlr_acc_tamp_i    (accrtr_o_wr_hndlr_tamp_int),
    .wr_hndlr_acc_valid_i  (accrtr_o_wr_hndlr_valid_int),
    .wr_hndlr_shdw_rsp_i   (shdwctlr_o_wr_rsp_int),
    .wr_hndlr_shdw_tamp_i  (shdwctlr_o_wr_tamp_int),
    .wr_hndlr_shdw_valid_i (shdwctlr_o_wr_valid_int),
    .wr_hndlr_rsp_o        (wrhnd_o_rsp_int  ),
    .wr_hndlr_tamp_o       (wrhnd_o_tamp_int ),
    .wr_hndlr_valid_o      (wrhnd_o_valid_int),
    .wr_hndlr_bid_i        (prtcnv_o_w_bid_int ),
    .wr_hndlr_bid_o        (wrhnd_o_bid_int ),
    .wr_hndlr_clk_busy_o   (wrhnd_busy_int)
);

firewall_f0_ctlr_reg_ctlr #(
    .FC_CFG_DATA_W           (FC_CFG_DATA_W     ),
    .LOG2_FC_NUM_RGN         (LOG2_FC_NUM_RGN),
    .REG_ADDR_WIDTH          (REG_ADDR_WIDTH    ),
    .REG_DATA_WIDTH          (REG_DATA_WIDTH    ),
    .FW_SRE_LVL              (FW_SRE_LVL        ),
    .READ_DATA_SIZE          (READ_DATA_SIZE    ),
    .FC_NUM_RGN              (FC_NUM_RGN     ),
    .TOTAL_FC                (TOTAL_FC     ),
    .CHECK_TYPE_WIDTH        (CHECK_TYPE_WIDTH),
    .FW_LDE_LVL              (FW_LDE_LVL),
    .FC_MST_ID_WIDTH         (FC_MST_ID_WIDTH)

) u_firewall_f0_ctlr_reg_ctlr (
    .clk                     (clk    ),
    .reset_n                 (reset_n),
    .fw_ctrl_en              (cfg_fw_ctrl_en),
    .fw_ctrl_o               (cfg_fw_ctrl_o),
    .fw_sr_ctrl_en           (cfg_fw_sr_ctrl_en),
    .fw_sr_ctrl_o            (cfg_fw_sr_ctrl_o),
    .ld_ctrl_en              (cfg_ld_ctrl_en),
    .ld_ctrl_o               (cfg_ld_ctrl_o),
    .pe_ctrl_en              (cfg_pe_ctrl_en),
    .pe_ctrl_o               (cfg_pe_ctrl_o),
    .rwe_ctrl_en             (cfg_rwe_ctrl_en),
    .rwe_ctrl_o              (cfg_rwe_ctrl_o),
    .rgn_ctrl0_en            (cfg_rgn_ctrl0_en),
    .rgn_ctrl0_o             (cfg_rgn_ctrl0_o),
    .rgn_ctrl1_en            (cfg_rgn_ctrl1_en),
    .rgn_ctrl1_o             (cfg_rgn_ctrl1_o),
    .rgn_lctrl_en            (cfg_rgn_lctrl_en),
    .rgn_lctrl_o             (cfg_rgn_lctrl_o),
    .rgn_cfg0_en             (cfg_rgn_cfg0_en),
    .rgn_cfg0_o              (cfg_rgn_cfg0_o),
    .rgn_cfg1_en             (cfg_rgn_cfg1_en),
    .rgn_cfg1_o              (cfg_rgn_cfg1_o),
    .rgn_size_en             (cfg_rgn_size_en),
    .rgn_size_o              (cfg_rgn_size_o),
    .rgn_tcfg0_en            (cfg_rgn_tcfg0_en),
    .rgn_tcfg0_o             (cfg_rgn_tcfg0_o),
    .rgn_tcfg1_en            (cfg_rgn_tcfg1_en),
    .rgn_tcfg1_o             (cfg_rgn_tcfg1_o),
    .rgn_tcfg2_en            (cfg_rgn_tcfg2_en),
    .rgn_tcfg2_o             (cfg_rgn_tcfg2_o),
    .rgn_mid0_en             (cfg_rgn_mid0_en),
    .rgn_mid0_o              (cfg_rgn_mid0_o),
    .rgn_mid1_en             (cfg_rgn_mid1_en),
    .rgn_mid1_o              (cfg_rgn_mid1_o),
    .rgn_mid2_en             (cfg_rgn_mid2_en),
    .rgn_mid2_o              (cfg_rgn_mid2_o),
    .rgn_mid3_en             (cfg_rgn_mid3_en),
    .rgn_mid3_o              (cfg_rgn_mid3_o),
    .rgn_mpl0_en             (cfg_rgn_mpl0_en),
    .rgn_mpl0_o              (cfg_rgn_mpl0_o),
    .rgn_mpl1_en             (cfg_rgn_mpl1_en),
    .rgn_mpl1_o              (cfg_rgn_mpl1_o),
    .rgn_mpl2_en             (cfg_rgn_mpl2_en),
    .rgn_mpl2_o              (cfg_rgn_mpl2_o),
    .rgn_mpl3_en             (cfg_rgn_mpl3_en),
    .rgn_mpl3_o              (cfg_rgn_mpl3_o),
    .fe_ctrl_en              (cfg_fe_ctrl_en),
    .fe_ctrl_o               (cfg_fe_ctrl_o),
    .me_ctrl_en              (cfg_me_ctrl_en),
    .me_ctrl_o               (cfg_me_ctrl_o),
    .edr_ctrl_en             (cfg_edr_ctrl_en),
    .edr_ctrl_o              (cfg_edr_ctrl_o),
    .fc_int_st_en            (cfg_fc_int_st_en),
    .fc_int_st_o             (cfg_fc_int_st_o),
    .fc_int_msk_en           (cfg_fc_int_msk_en),
    .fc_int_msk_o            (cfg_fc_int_msk_o),
    .fw_tmp_ctrl_en          (cfg_fw_tmp_ctrl_en),
    .fw_tmp_ctrl_o           (cfg_fw_tmp_ctrl_o),

    .addr_dec_fw_ctrl_en     (addr_dec_fw_ctrl_en_int),
    .addr_dec_fw_ctrl_i      (addr_dec_fw_ctrl_o_int),
    .addr_dec_fw_sr_ctrl_en  (addr_dec_fw_sr_ctrl_en_int),
    .addr_dec_fw_sr_ctrl_i   (addr_dec_fw_sr_ctrl_o_int),
    .addr_dec_ld_ctrl_en     (addr_dec_ld_ctrl_en_int),
    .addr_dec_ld_ctrl_i      (addr_dec_ld_ctrl_o_int),
    .addr_dec_pe_ctrl_en     (addr_dec_pe_ctrl_en_int),
    .addr_dec_pe_ctrl_i      (addr_dec_pe_ctrl_o_int),
    .addr_dec_rwe_ctrl_en    (addr_dec_rwe_ctrl_en_int),
    .addr_dec_rwe_ctrl_i     (addr_dec_rwe_ctrl_o_int),
    .addr_dec_rgn_ctrl0_en   (addr_dec_rgn_ctrl0_en_int),
    .addr_dec_rgn_ctrl0_i    (addr_dec_rgn_ctrl0_o_int),
    .addr_dec_rgn_ctrl1_en   (addr_dec_rgn_ctrl1_en_int),
    .addr_dec_rgn_ctrl1_i    (addr_dec_rgn_ctrl1_o_int),
    .addr_dec_rgn_lctrl_en   (addr_dec_rgn_lctrl_en_int),
    .addr_dec_rgn_lctrl_i    (addr_dec_rgn_lctrl_o_int),
    .addr_dec_rgn_cfg0_en    (addr_dec_rgn_cfg0_en_int),
    .addr_dec_rgn_cfg0_i     (addr_dec_rgn_cfg0_o_int),
    .addr_dec_rgn_cfg1_en    (addr_dec_rgn_cfg1_en_int),
    .addr_dec_rgn_cfg1_i     (addr_dec_rgn_cfg1_o_int),
    .addr_dec_rgn_size_en    (addr_dec_rgn_size_en_int),
    .addr_dec_rgn_size_i     (addr_dec_rgn_size_o_int),
    .addr_dec_rgn_tcfg0_en   (addr_dec_rgn_tcfg0_en_int),
    .addr_dec_rgn_tcfg0_i    (addr_dec_rgn_tcfg0_o_int),
    .addr_dec_rgn_tcfg1_en   (addr_dec_rgn_tcfg1_en_int),
    .addr_dec_rgn_tcfg1_i    (addr_dec_rgn_tcfg1_o_int),
    .addr_dec_rgn_tcfg2_en   (addr_dec_rgn_tcfg2_en_int),
    .addr_dec_rgn_tcfg2_i    (addr_dec_rgn_tcfg2_o_int),
    .addr_dec_rgn_mid0_en    (addr_dec_rgn_mid0_en_int),
    .addr_dec_rgn_mid0_i     (addr_dec_rgn_mid0_o_int),
    .addr_dec_rgn_mid1_en    (addr_dec_rgn_mid1_en_int),
    .addr_dec_rgn_mid1_i     (addr_dec_rgn_mid1_o_int),
    .addr_dec_rgn_mid2_en    (addr_dec_rgn_mid2_en_int),
    .addr_dec_rgn_mid2_i     (addr_dec_rgn_mid2_o_int),
    .addr_dec_rgn_mid3_en    (addr_dec_rgn_mid3_en_int),
    .addr_dec_rgn_mid3_i     (addr_dec_rgn_mid3_o_int),
    .addr_dec_rgn_mpl0_en    (addr_dec_rgn_mpl0_en_int),
    .addr_dec_rgn_mpl0_i     (addr_dec_rgn_mpl0_o_int),
    .addr_dec_rgn_mpl1_en    (addr_dec_rgn_mpl1_en_int),
    .addr_dec_rgn_mpl1_i     (addr_dec_rgn_mpl1_o_int),
    .addr_dec_rgn_mpl2_en    (addr_dec_rgn_mpl2_en_int),
    .addr_dec_rgn_mpl2_i     (addr_dec_rgn_mpl2_o_int),
    .addr_dec_rgn_mpl3_en    (addr_dec_rgn_mpl3_en_int),
    .addr_dec_rgn_mpl3_i     (addr_dec_rgn_mpl3_o_int),
    .addr_dec_fe_ctrl_en     (addr_dec_fe_ctrl_en_int),
    .addr_dec_fe_ctrl_i      (addr_dec_fe_ctrl_o_int),
    .addr_dec_me_ctrl_en     (addr_dec_me_ctrl_en_int),
    .addr_dec_me_ctrl_i      (addr_dec_me_ctrl_o_int),
    .addr_dec_edr_ctrl_en    (addr_dec_edr_ctrl_en_int),
    .addr_dec_edr_ctrl_i     (addr_dec_edr_ctrl_o_int),
    .addr_dec_fc_int_st_en   (addr_dec_fc_int_st_en_int),
    .addr_dec_fc_int_st_i    (addr_dec_fc_int_st_o_int),
    .addr_dec_fc_int_msk_en  (addr_dec_fc_int_msk_en_int),
    .addr_dec_fc_int_msk_i   (addr_dec_fc_int_msk_o_int),
    .addr_dec_fw_tmp_ctrl_en (addr_dec_fw_tmp_ctrl_en_int),
    .addr_dec_fw_tmp_ctrl_i  (addr_dec_fw_tmp_ctrl_o_int),
    .reg_ctlr_clk_busy_o     (regctlr_busy_int),
    .reg_ctlr_reg_valid_i    (accrtr_o_reg_ctlr_valid_o),
    .reg_ctlr_wr_valid_o     (regctlr_o_wr_valid_int)
);

firewall_f0_ctlr_addr_dec #(
    .REG_ADDR_WIDTH            (REG_ADDR_WIDTH),
    .REG_DATA_WIDTH            (REG_DATA_WIDTH),
    .FW_NUM_FC                 (FW_NUM_FC),
    .LOG2_FW_NUM_FC            (LOG2_FW_NUM_FC),
    .FW_SRE_LVL                (FW_SRE_LVL),
    .FC_PE_LVL                 (FC_PE_LVL),
    .FW_LDE_LVL                (FW_LDE_LVL),
    .FC_MXRS                   (FC_MXRS),
    .FC_MNRS                   (FC_MNRS),
    .FC_RSE_LVL                (FC_RSE_LVL),
    .FC_TE_LVL                 (FC_TE_LVL),
    .FC_NUM_MPE                (FC_NUM_MPE),
    .FC_SINGLE_MST             (FC_SINGLE_MST),
    .FC_ME_LVL                 (FC_ME_LVL),
    .FC_INST_SPT               (FC_INST_SPT),
    .FC_MA_SPT                 (FC_MA_SPT),
    .FC_SEC_SPT                (FC_SEC_SPT),
    .FC_PRIV_SPT               (FC_PRIV_SPT),
    .FC_SH_SPT                 (FC_SH_SPT),
    .READ_DATA_SIZE            (READ_DATA_SIZE),
    .FC_NUM_RGN                (FC_NUM_RGN),
    .REG_ENUM_WIDTH            (REG_ENUM_WIDTH),
    .LOG2_SRAM_SIZE            (LOG2_SRAM_SIZE),
    .FC_ID                     (FC_ID),
    .SRAM_WIDTH                (SRAM_WIDTH),
    .LOG2_SRAM_WIDTH           (LOG2_SRAM_WIDTH),
    .FC_MST_ID_WIDTH           (FC_MST_ID_WIDTH),
    .MAX_NUM_RGN               (MAX_NUM_RGN),
    .CHECK_TYPE_WIDTH          (CHECK_TYPE_WIDTH),
    .N_MEM_RET                 (N_MEM_RET),
    .TOTAL_FC                  (TOTAL_FC),
    .FC_SEC_SPT_EXT            (FC_SEC_SPT_EXT),
    .FC_MA_SPT_EXT             (FC_MA_SPT_EXT),
    .FC_SH_SPT_EXT             (FC_SH_SPT_EXT),
    .FC_INST_SPT_EXT           (FC_INST_SPT_EXT),
    .FC_PRIV_SPT_EXT           (FC_PRIV_SPT_EXT),
    .FC_NUM_RGN_EXT            (FC_NUM_RGN_EXT),
    .FC_MNRS_EXT               (FC_MNRS_EXT),
    .FC_MXRS_EXT               (FC_MXRS_EXT),
    .FC_NUM_MPE_EXT            (FC_NUM_MPE_EXT),
    .FC_ME_LVL_EXT             (FC_ME_LVL_EXT),
    .FC_RSE_LVL_EXT            (FC_RSE_LVL_EXT),
    .FC_PE_LVL_EXT             (FC_PE_LVL_EXT),
    .FC_TE_LVL_EXT             (FC_TE_LVL_EXT),
    .FC_SINGLE_MST_EXT         (FC_SINGLE_MST_EXT),
    .FW_ID_WIDTH               (FW_ID_WIDTH),
    .CHECK_RWE_DATA            (CHECK_RWE_DATA),
    .CHECK_RWE_MPL             (CHECK_RWE_MPL),
    .CHECK_RWE_EN              (CHECK_RWE_EN),
    .CHECK_RWE_LOCK            (CHECK_RWE_LOCK),
    .CHECK_FW_LOCK             (CHECK_FW_LOCK),
    .CHECK_LDE                 (CHECK_LDE),
    .FC_RGN_BASE_ADDR_EXT      (FC_RGN_BASE_ADDR_EXT),
    .FC_RGN_UPR_ADDR_EXT       (FC_RGN_UPR_ADDR_EXT ),
    .FC_RGN_SIZE_EXT           (FC_RGN_SIZE_EXT     ),
    .FC_RGN_MULNPO2_EXT        (FC_RGN_MULNPO2_EXT  ),
    .FC_MST_ID_SINGLE_MST_EXT  (FC_MST_ID_SINGLE_MST_EXT),
    .FW_CFG_AGENT_MST_ID       (FW_CFG_AGENT_MST_ID),
    .FW_MAX_MST_ID_WIDTH       (FW_MAX_MST_ID_WIDTH),
    .FC_MST_ID_WIDTH_EXT       (FC_MST_ID_WIDTH_EXT)

) u_firewall_f0_ctlr_addr_dec (
    .clk                       (clk    ),
    .reset_n                   (reset_n),
    .addr_dec_reg_addr_i       (prtcnv_o_reg_addr_int ),
    .addr_dec_reg_enum_addr_i  (prtcnv_o_reg_enum_addr_int ),
    .addr_dec_rw_i             (prtcnv_o_rw_int       ),
    .addr_dec_fw_id_i          (prtcnv_o_fw_id_int    ),
    .addr_dec_fc_id_i          (prtcnv_o_fc_id_int    ),
    .addr_dec_wr_data_i        (prtcnv_o_wr_data_int  ),
    .addr_dec_acc_valid_i      (prtcnv_o_acc_valid_int),
    .addr_dec_cfg_active_i     (prtcnv_o_cfg_active_int),
    .addr_dec_mst_id_i         (prtcnv_o_mst_id_int),
    .addr_dec_axprot_i         (prtcnv_o_axprot_int),

    .addr_dec_pwr_st_i         (cfg_pwr_st_i),
    .fw_ctrl_i                 (cfg_fw_ctrl_i),
    .fw_st_i                   (cfg_fw_st_i),
    .fw_sr_ctrl_i              (cfg_fw_sr_ctrl_i),
    .pe_bps_i                  (cfg_pe_bps_i),
    .fw_int_st_i               (cfg_fw_int_st_i),
    .ld_ctrl_i                 (cfg_ld_ctrl_i),
    .pe_ctrl_i                 (cfg_pe_ctrl_i),
    .pe_st_i                   (cfg_pe_st_i),
    .rwe_ctrl_i                (cfg_rwe_ctrl_i),
    .rgn_ctrl0_rgn_i           (cfg_rgn_ctrl0_rgn_i),
    .rgn_ctrl1_rgn_i           (cfg_rgn_ctrl1_rgn_i),
    .rgn_lctrl_rgn_i           (cfg_rgn_lctrl_rgn_i),
    .rgn_st_rgn_i              (cfg_rgn_st_rgn_i),
    .rgn_cfg0_rgn_i            (cfg_rgn_cfg0_rgn_i),
    .rgn_cfg1_rgn_i            (cfg_rgn_cfg1_rgn_i),
    .rgn_size_rgn_i            (cfg_rgn_size_rgn_i),
    .rgn_tcfg0_rgn_i           (cfg_rgn_tcfg0_rgn_i),
    .rgn_tcfg1_rgn_i           (cfg_rgn_tcfg1_rgn_i),
    .rgn_tcfg2_rgn_i           (cfg_rgn_tcfg2_rgn_i),
    .rgn_mid0_rgn_i            (cfg_rgn_mid0_rgn_i),
    .rgn_mid1_rgn_i            (cfg_rgn_mid1_rgn_i),
    .rgn_mid2_rgn_i            (cfg_rgn_mid2_rgn_i),
    .rgn_mid3_rgn_i            (cfg_rgn_mid3_rgn_i),
    .rgn_mpl0_rgn_i            (cfg_rgn_mpl0_rgn_i),
    .rgn_mpl1_rgn_i            (cfg_rgn_mpl1_rgn_i),
    .rgn_mpl2_rgn_i            (cfg_rgn_mpl2_rgn_i),
    .rgn_mpl3_rgn_i            (cfg_rgn_mpl3_rgn_i),
    .fe_tal_i                  (cfg_fe_tal_i),
    .fe_tau_i                  (cfg_fe_tau_i),
    .fe_tp_i                   (cfg_fe_tp_i),
    .fe_mid_i                  (cfg_fe_mid_i),
    .fe_ctrl_i                 (cfg_fe_ctrl_i),
    .me_ctrl_i                 (cfg_me_ctrl_i),
    .me_st_i                   (cfg_me_st_i),
    .edr_tal_i                 (cfg_edr_tal_i),
    .edr_tau_i                 (cfg_edr_tau_i),
    .edr_tp_i                  (cfg_edr_tp_i),
    .edr_mid_i                 (cfg_edr_mid_i),
    .edr_ctrl_i                (cfg_edr_ctrl_i),
    .fc_int_st_i               (cfg_fc_int_st_i),
    .fc_int_msk_i              (cfg_fc_int_msk_i),
    .fw_tmp_ta_i               (cfg_fw_tmp_ta_i),
    .fw_tmp_tp_i               (cfg_fw_tmp_tp_i),
    .fw_tmp_mid_i              (cfg_fw_tmp_mid_i),
    .fw_tmp_ctrl_i             (cfg_fw_tmp_ctrl_i),
    .iidr_i                    (cfg_iidr_i),
    .aidr_i                    (cfg_aidr_i),
    .prot_size_i               (cfg_prot_size_i),

    .fw_ctrl_en                (addr_dec_fw_ctrl_en_int),
    .fw_ctrl_o                 (addr_dec_fw_ctrl_o_int),
    .fw_sr_ctrl_en             (addr_dec_fw_sr_ctrl_en_int),
    .fw_sr_ctrl_o              (addr_dec_fw_sr_ctrl_o_int),
    .ld_ctrl_en                (addr_dec_ld_ctrl_en_int),
    .ld_ctrl_o                 (addr_dec_ld_ctrl_o_int),
    .pe_ctrl_en                (addr_dec_pe_ctrl_en_int),
    .pe_ctrl_o                 (addr_dec_pe_ctrl_o_int),
    .rwe_ctrl_en               (addr_dec_rwe_ctrl_en_int),
    .rwe_ctrl_o                (addr_dec_rwe_ctrl_o_int),
    .rgn_ctrl0_en              (addr_dec_rgn_ctrl0_en_int),
    .rgn_ctrl0_o               (addr_dec_rgn_ctrl0_o_int),
    .rgn_ctrl1_en              (addr_dec_rgn_ctrl1_en_int),
    .rgn_ctrl1_o               (addr_dec_rgn_ctrl1_o_int),
    .rgn_lctrl_en              (addr_dec_rgn_lctrl_en_int),
    .rgn_lctrl_o               (addr_dec_rgn_lctrl_o_int),
    .rgn_cfg0_en               (addr_dec_rgn_cfg0_en_int),
    .rgn_cfg0_o                (addr_dec_rgn_cfg0_o_int),
    .rgn_cfg1_en               (addr_dec_rgn_cfg1_en_int),
    .rgn_cfg1_o                (addr_dec_rgn_cfg1_o_int),
    .rgn_size_en               (addr_dec_rgn_size_en_int),
    .rgn_size_o                (addr_dec_rgn_size_o_int),
    .rgn_tcfg0_en              (addr_dec_rgn_tcfg0_en_int),
    .rgn_tcfg0_o               (addr_dec_rgn_tcfg0_o_int),
    .rgn_tcfg1_en              (addr_dec_rgn_tcfg1_en_int),
    .rgn_tcfg1_o               (addr_dec_rgn_tcfg1_o_int),
    .rgn_tcfg2_en              (addr_dec_rgn_tcfg2_en_int),
    .rgn_tcfg2_o               (addr_dec_rgn_tcfg2_o_int),
    .rgn_mid0_en               (addr_dec_rgn_mid0_en_int),
    .rgn_mid0_o                (addr_dec_rgn_mid0_o_int),
    .rgn_mid1_en               (addr_dec_rgn_mid1_en_int),
    .rgn_mid1_o                (addr_dec_rgn_mid1_o_int),
    .rgn_mid2_en               (addr_dec_rgn_mid2_en_int),
    .rgn_mid2_o                (addr_dec_rgn_mid2_o_int),
    .rgn_mid3_en               (addr_dec_rgn_mid3_en_int),
    .rgn_mid3_o                (addr_dec_rgn_mid3_o_int),
    .rgn_mpl0_en               (addr_dec_rgn_mpl0_en_int),
    .rgn_mpl0_o                (addr_dec_rgn_mpl0_o_int),
    .rgn_mpl1_en               (addr_dec_rgn_mpl1_en_int),
    .rgn_mpl1_o                (addr_dec_rgn_mpl1_o_int),
    .rgn_mpl2_en               (addr_dec_rgn_mpl2_en_int),
    .rgn_mpl2_o                (addr_dec_rgn_mpl2_o_int),
    .rgn_mpl3_en               (addr_dec_rgn_mpl3_en_int),
    .rgn_mpl3_o                (addr_dec_rgn_mpl3_o_int),
    .fe_ctrl_en                (addr_dec_fe_ctrl_en_int),
    .fe_ctrl_o                 (addr_dec_fe_ctrl_o_int),
    .me_ctrl_en                (addr_dec_me_ctrl_en_int),
    .me_ctrl_o                 (addr_dec_me_ctrl_o_int),
    .edr_ctrl_en               (addr_dec_edr_ctrl_en_int),
    .edr_ctrl_o                (addr_dec_edr_ctrl_o_int),
    .fc_int_st_en              (addr_dec_fc_int_st_en_int),
    .fc_int_st_o               (addr_dec_fc_int_st_o_int),
    .fc_int_msk_en             (addr_dec_fc_int_msk_en_int),
    .fc_int_msk_o              (addr_dec_fc_int_msk_o_int),
    .fw_tmp_ctrl_en            (addr_dec_fw_tmp_ctrl_en_int),
    .fw_tmp_ctrl_o             (addr_dec_fw_tmp_ctrl_o_int),

    .addr_dec_reg_addr_o       (addrdec_o_reg_addr_int    ),
    .addr_dec_rw_o             (addrdec_o_rw_int          ),
    .addr_dec_fw_id_o          (addrdec_o_fw_id_int       ),
    .addr_dec_fc_id_o          (addrdec_o_fc_id_int       ),
    .addr_dec_wr_data_o        (addrdec_o_wr_data_int     ),
    .addr_dec_reg_rd_data_o    (addrdec_o_reg_rd_data_int ),
    .addr_dec_hit_o            (addrdec_o_hit_int         ),
    .addr_dec_hit_chk_need_o   (addrdec_o_hit_chk_need_int),
    .addr_dec_hit_chk_type_o   (addrdec_o_hit_chk_type_int),
    .addr_dec_sram_row_o       (addrdec_o_sram_row_int    ),
    .addr_dec_sram_col_o       (addrdec_o_sram_col_int    ),
    .addr_dec_reg_size_o       (addrdec_o_reg_size_int    ),
    .addr_dec_wr_rsp_pend_o    (addrdec_o_wr_rsp_pend_int ),
    .addr_dec_fixed_o          (addrdec_o_fixed_int       ),
    .addr_dec_read_only_o      (addrdec_o_read_only_int   ),
    .addr_dec_tamper_o         (addrdec_o_tamper_int      ),
    .addr_dec_wr_allow_fctlr_o (addrdec_o_wr_allow_fctlr_int),
    .addr_dec_ctlr_n_comp_o    (addrdec_o_ctlr_n_comp_int ),
    .addr_dec_acc_valid_o      (addrdec_o_acc_valid_int   ),

    .addr_dec_shdw_rgn_i           (shdwctlr_o_rgn_int),
    .addr_dec_shdw_rgn_o           (addr_dec_shdw_rgn_int),
    .addr_dec_shdw_rgn_en_o        (addr_dec_shdw_rgn_en_int),
    .addr_dec_rd_rgn_st_o          (addr_dec_rd_rgn_st_o_int),
    .addr_dec_shdw_rgn_lctrl_op1_o (addr_dec_shdw_rgn_lctrl_op1_o_int),
    .addr_dec_shdw_rgn_lctrl_op2_o (addr_dec_shdw_rgn_lctrl_op2_o_int),
    .addr_dec_shdw_rgn_lctrl_col_o (addr_dec_shdw_rgn_lctrl_col_o_int),
    .addr_dec_shdw_rgn_ctrl0_op1_o (addr_dec_shdw_rgn_ctrl0_op1_o_int),
    .addr_dec_shdw_rgn_ctrl0_op2_o (addr_dec_shdw_rgn_ctrl0_op2_o_int),
    .addr_dec_shdw_rgn_ctrl0_col_o (addr_dec_shdw_rgn_ctrl0_col_o_int),
    .addr_dec_shdw_rgn_ctrl1_op1_o (addr_dec_shdw_rgn_ctrl1_op1_o_int),
    .addr_dec_shdw_rgn_ctrl1_op2_o (addr_dec_shdw_rgn_ctrl1_op2_o_int),
    .addr_dec_shdw_rgn_ctrl1_col_o (addr_dec_shdw_rgn_ctrl1_col_o_int),
    .addr_dec_shdw_mpe_o           (addr_dec_shdw_mpe_o_int),

    .addr_dec_unfrmt_rd_data_i (rdhnd_o_unfrmt_rd_data_int),
    .addr_dec_frmtd_rd_data_o  (addrdec_o_frmt_rd_data_int),

    .addr_dec_add_op1_o        (addrdec_add_op1_int),
    .addr_dec_add_op2_o        (addrdec_add_op2_int),
    .addr_dec_add_en_o         (addrdec_add_en_int),
    .addr_dec_add_res_i        (add_res_int),

    .addr_dec_clk_busy_o       (addrdec_busy_int)
);

firewall_f0_ctlr_prot_conv #(
    .FC_AXIID_WIDTH            (FC_AXIID_WIDTH    ),
    .REG_ADDR_WIDTH            (REG_ADDR_WIDTH    ),
    .REG_DATA_WIDTH            (REG_DATA_WIDTH    ),
    .FC_AXIUSER_B_WIDTH        (FC_AXIUSER_B_WIDTH),
    .FC_AXIUSER_R_WIDTH        (FC_AXIUSER_R_WIDTH),
    .FC_MST_ID_WIDTH           (FC_MST_ID_WIDTH   ),
    .LOG2_FW_NUM_FC            (LOG2_FW_NUM_FC    ),
    .FW_NUM_FC                 (FW_NUM_FC         ),
    .REG_ENUM_WIDTH            (REG_ENUM_WIDTH    ),
    .FW_ID_WIDTH               (FW_ID_WIDTH    )
) u_firewall_f0_ctlr_prot_conv (
    .clk                       (clk    ),
    .reset_n                   (reset_n),
    .prot_conv_arid_i          (cfg_arid_i   ),
    .prot_conv_araddr_i        (cfg_araddr_i ),
    .prot_conv_arvalid_i       (cfg_arvalid_i),
    .prot_conv_arready_o       (cfg_arready_o),
    .prot_conv_awid_i          (cfg_awid_i   ),
    .prot_conv_awaddr_i        (cfg_awaddr_i ),
    .prot_conv_awvalid_i       (cfg_awvalid_i),
    .prot_conv_awready_o       (cfg_awready_o),
    .prot_conv_wdata_i         (cfg_wdata_i  ),
    .prot_conv_wvalid_i        (cfg_wvalid_i ),
    .prot_conv_wready_o        (cfg_wready_o ),
    .prot_conv_bid_o           (cfg_bid_o    ),
    .prot_conv_bresp_o         (cfg_bresp_o  ),
    .prot_conv_buser_o         (cfg_buser_o  ),
    .prot_conv_bvalid_o        (cfg_bvalid_o ),
    .prot_conv_bready_i        (cfg_bready_i ),
    .prot_conv_rid_o           (cfg_rid_o    ),
    .prot_conv_rdata_o         (cfg_rdata_o  ),
    .prot_conv_rresp_o         (cfg_rresp_o  ),
    .prot_conv_rlast_o         (cfg_rlast_o  ),
    .prot_conv_ruser_o         (cfg_ruser_o  ),
    .prot_conv_rvalid_o        (cfg_rvalid_o ),
    .prot_conv_rready_i        (cfg_rready_i ),
    .prot_conv_w_fw_id_i       (cfg_w_fw_id_i),
    .prot_conv_r_fw_id_i       (cfg_r_fw_id_i),
    .prot_conv_w_mst_id_i      (cfg_w_mst_id_i),
    .prot_conv_r_mst_id_i      (cfg_r_mst_id_i),
    .prot_conv_r_mst_id_o      (cfg_r_mst_id_o),
    .prot_conv_enum_w_addr_i   (cfg_enum_w_addr_i),
    .prot_conv_enum_r_addr_i   (cfg_enum_r_addr_i),
    .prot_conv_awprot_i        (cfg_awprot_i[1:0]),
    .prot_conv_arprot_i        (cfg_arprot_i[1:0]),
    .prot_conv_reg_tamp_o      (cfg_reg_tamp_o),
    .prot_conv_reg_tamp_w_o    (cfg_reg_tamp_w_o),
    .prot_conv_reg_addr_o      (prtcnv_o_reg_addr_int ),
    .prot_conv_rw_o            (prtcnv_o_rw_int       ),
    .prot_conv_fw_id_o         (prtcnv_o_fw_id_int    ),
    .prot_conv_fc_id_o         (prtcnv_o_fc_id_int    ),
    .prot_conv_wr_data_o       (prtcnv_o_wr_data_int  ),
    .prot_conv_acc_valid_o     (prtcnv_o_acc_valid_int),
    .prot_conv_reg_enum_addr_o (prtcnv_o_reg_enum_addr_int),
    .prot_conv_cfg_active_o    (prtcnv_o_cfg_active_int),
    .prot_conv_mst_id_o        (prtcnv_o_mst_id_int),
    .prot_conv_axprot_o        (prtcnv_o_axprot_int),
    .prot_conv_pwr_block_i     (cmppwr_o_prot_block_int),
    .prot_conv_trkr_o          (prtcnv_o_trkr_int),
    .prot_conv_hndshk_pend_i   (cmppwr_o_hndshk_pend_int),
    .prot_conv_cfg_pend_o      (prtcnv_o_cfg_pend_int),
    .prot_conv_dn_prot_block_i (us_o_block_int),
    .prot_conv_shdw_block_i    (shdwctlr_o_prot_block_int),
    .prot_conv_wr_rsp_i        (wrhnd_o_rsp_int  ),
    .prot_conv_wr_tamp_i       (wrhnd_o_tamp_int ),
    .prot_conv_wr_valid_i      (wrhnd_o_valid_int),
    .prot_conv_wr_bid_o        (prtcnv_o_w_bid_int),
    .prot_conv_wr_bid_i        (wrhnd_o_bid_int),
    .prot_conv_rd_rsp_i        (rdhnd_o_rsp_o  ),
    .prot_conv_rd_tamp_i       (rdhnd_o_tamp_o ),
    .prot_conv_rd_valid_i      (rdhnd_o_valid_o),
    .prot_conv_rd_data_i       (rdhnd_o_data_o ),
    .prot_conv_rd_mst_id_i     (rdhnd_mst_id_o),
    .prot_conv_rd_mst_id_o     (prtcnv_o_r_mst_id_int),
    .prot_conv_rd_rid_o        (prtcnv_o_r_rid_int),
    .prot_conv_rd_rid_i        (rdhnd_rid_o),
    .prot_conv_clk_busy_o      (prtcnv_busy_int)
);

generate
  if (FW_SRE_LVL == 1) begin : SHDW_CTLR_SRE1

    firewall_f0_ctlr_shdw_ctlr #(
        .REG_ADDR_WIDTH                 (REG_ADDR_WIDTH),
        .REG_DATA_WIDTH                 (REG_DATA_WIDTH),
        .SRAM_WIDTH                     (SRAM_WIDTH),
        .READ_DATA_SIZE                 (READ_DATA_SIZE),
        .FW_NUM_FC                      (FW_NUM_FC),
        .LOG2_FW_NUM_FC                 (LOG2_FW_NUM_FC),
        .LOG2_SRAM_SIZE                 (LOG2_SRAM_SIZE),
        .LOG2_SRAM_WIDTH                (LOG2_SRAM_WIDTH),
        .FC_PE_LVL                      (FC_PE_LVL),
        .FW_LDE_LVL                     (FW_LDE_LVL),
        .FC_MXRS                        (FC_MXRS),
        .FC_TE_LVL                      (FC_TE_LVL),
        .FC_RSE_LVL                     (FC_RSE_LVL),
        .FC_MA_SPT                      (FC_MA_SPT),
        .FC_INST_SPT                    (FC_INST_SPT),
        .FC_PRIV_SPT                    (FC_PRIV_SPT),
        .FC_SH_SPT                      (FC_SH_SPT),
        .FC_SEC_SPT                     (FC_SEC_SPT),
        .FC_NUM_MPE                     (FC_NUM_MPE),
        .FC_SINGLE_MST                  (FC_SINGLE_MST),
        .FC_ME_LVL                      (FC_ME_LVL),
        .FW_SRE_LVL                     (FW_SRE_LVL),
        .FC_ID                          (FC_ID),
        .RGN_TCFG2_WIDTH                (RGN_TCFG2_WIDTH),
        .FC_NUM_RGN                     (FC_NUM_RGN),
        .RGN_CTRL0_WIDTH                (RGN_CTRL0_WIDTH),
        .RGN_CTRL1_WIDTH                (RGN_CTRL1_WIDTH),
        .RGN_LCTRL_WIDTH                (RGN_LCTRL_WIDTH),
        .RGN_SIZE_WIDTH                 (RGN_SIZE_WIDTH),
        .RGN_MPL0_WIDTH                 (RGN_MPL0_WIDTH),
        .RGN_MPL1_WIDTH                 (RGN_MPL1_WIDTH),
        .RGN_MPL2_WIDTH                 (RGN_MPL2_WIDTH),
        .RGN_MPL3_WIDTH                 (RGN_MPL3_WIDTH),
        .RGN_TCFG0_WIDTH                (RGN_TCFG0_WIDTH),
        .RGN_TCFG1_WIDTH                (RGN_TCFG1_WIDTH),
        .RGN_CFG0_WIDTH                 (RGN_CFG0_WIDTH),
        .RGN_CFG1_WIDTH                 (RGN_CFG1_WIDTH),
        .PE_CTRL_WIDTH                  (PE_CTRL_WIDTH),
        .ME_CTRL_WIDTH                  (ME_CTRL_WIDTH),
        .RWE_CTRL_WIDTH                 (RWE_CTRL_WIDTH),
        .CHECK_TYPE_WIDTH               (CHECK_TYPE_WIDTH),
        .FC_SEC_SPT_EXT                 (FC_SEC_SPT_EXT),
        .FC_MA_SPT_EXT                  (FC_MA_SPT_EXT),
        .FC_SH_SPT_EXT                  (FC_SH_SPT_EXT),
        .FC_INST_SPT_EXT                (FC_INST_SPT_EXT),
        .FC_PRIV_SPT_EXT                (FC_PRIV_SPT_EXT),
        .FC_NUM_RGN_EXT                 (FC_NUM_RGN_EXT),
        .FC_MNRS_EXT                    (FC_MNRS_EXT),
        .FC_MXRS_EXT                    (FC_MXRS_EXT),
        .FC_NUM_MPE_EXT                 (FC_NUM_MPE_EXT),
        .FC_ME_LVL_EXT                  (FC_ME_LVL_EXT),
        .FC_RSE_LVL_EXT                 (FC_RSE_LVL_EXT),
        .FC_PE_LVL_EXT                  (FC_PE_LVL_EXT),
        .FC_TE_LVL_EXT                  (FC_TE_LVL_EXT),
        .FC_SINGLE_MST_EXT              (FC_SINGLE_MST_EXT),
        .FW_ID_WIDTH                    (FW_ID_WIDTH),
        .CHECK_RWE_DATA                 (CHECK_RWE_DATA),
        .CHECK_RWE_MPL                  (CHECK_RWE_MPL),
        .CHECK_RWE_EN                   (CHECK_RWE_EN),
        .CHECK_RWE_LOCK                 (CHECK_RWE_LOCK),
        .CHECK_FW_LOCK                  (CHECK_FW_LOCK),
        .CHECK_LDE                      (CHECK_LDE),
        .FW_MAX_MST_ID_WIDTH            (FW_MAX_MST_ID_WIDTH)
    ) u_firewall_f0_ctlr_shdw_ctlr (
        .clk                            (clk),
        .reset_n                        (reset_n),

        .shdw_ctlr_rw_i                 (accrtr_o_rw_int),
        .shdw_ctlr_fw_id_i              (accrtr_o_fw_id_int),
        .shdw_ctlr_fc_id_i              (accrtr_o_fc_id_int),
        .shdw_ctlr_wr_data_i            (accrtr_o_wr_data_int),
        .shdw_ctlr_chk_need_i           (accrtr_o_shdw_hit_chk_need_int),
        .shdw_ctlr_chk_type_i           (accrtr_o_shdw_hit_chk_type_int),
        .shdw_ctlr_sram_row_i           (accrtr_o_shdw_sram_row_int),
        .shdw_ctlr_sram_col_i           (accrtr_o_shdw_sram_col_int),
        .shdw_ctlr_reg_size_i           (accrtr_o_shdw_reg_size_int),
        .shdw_ctlr_wr_rsp_pend_i        (accrtr_o_shdw_wr_rsp_pend_int),
        .shdw_ctlr_acc_valid_i          (accrtr_o_shdw_hit_valid_int),
        .shdw_ctlr_fixed_i              (accrtr_o_shdw_fixed_int),

        .shdw_ctlr_restore_req_i        (cmppwr_restore_req_int),
        .shdw_ctlr_restore_req_id_i     (cmppwr_restore_fw_id_int),
        .shdw_ctlr_restore_req_valid_i  (cmppwr_o_restore_valid_int),
        .shdw_ctlr_restore_done_o       (shdwctlr_o_restore_done_int),
        .shdw_ctlr_restore_fw_id_o      (shdwctlr_o_restore_fw_id_int),
        .shdw_ctlr_con_valid_i          (cmppwr_o_shdw_con_valid_int),
        .shdw_ctlr_con_fw_id_i          (cmppwr_o_shdw_con_fw_id_int),
        .shdw_ctlr_wr_aft_dsc_o         (shdwctlr_o_wr_aft_dsc_int),
        .shdw_ctlr_wr_aft_rst_o         (shdwctlr_o_wr_aft_rst_int),

        .shdw_ctlr_rgn_o                (shdwctlr_o_rgn_int),
        .shdw_ctlr_rgn_i                (addr_dec_shdw_rgn_int),
        .shdw_ctlr_rgn_en_i             (addr_dec_shdw_rgn_en_int),
        .shdw_ctlr_rd_rgn_st_i          (addr_dec_rd_rgn_st_o_int),
        .shdw_ctlr_rgn_lctrl_op1_i      (addr_dec_shdw_rgn_lctrl_op1_o_int),
        .shdw_ctlr_rgn_lctrl_op2_i      (addr_dec_shdw_rgn_lctrl_op2_o_int),
        .shdw_ctlr_rgn_lctrl_col_i      (addr_dec_shdw_rgn_lctrl_col_o_int),
        .shdw_ctlr_rgn_ctrl0_op1_i      (addr_dec_shdw_rgn_ctrl0_op1_o_int),
        .shdw_ctlr_rgn_ctrl0_op2_i      (addr_dec_shdw_rgn_ctrl0_op2_o_int),
        .shdw_ctlr_rgn_ctrl0_col_i      (addr_dec_shdw_rgn_ctrl0_col_o_int),
        .shdw_ctlr_rgn_ctrl1_op1_i      (addr_dec_shdw_rgn_ctrl1_op1_o_int),
        .shdw_ctlr_rgn_ctrl1_op2_i      (addr_dec_shdw_rgn_ctrl1_op2_o_int),
        .shdw_ctlr_rgn_ctrl1_col_i      (addr_dec_shdw_rgn_ctrl1_col_o_int),
        .shdw_ctlr_mpe_i                (addr_dec_shdw_mpe_o_int),

        .shdw_ctlr_fw_id_o              (shdwctlr_o_fw_id_int),
        .shdw_ctlr_restore_data_o       (shdwctlr_o_restore_data_int),
        .shdw_ctlr_first_restore_data_o (shdwctlr_o_first_restore_data_int),
        .shdw_ctlr_restore_valid_o      (shdwctlr_o_restore_valid_int),
        .shdw_ctlr_cfg_valid_o          (shdwctlr_o_cfg_valid_int),

        .shdw_ctlr_wr_rsp_o             (shdwctlr_o_wr_rsp_int),
        .shdw_ctlr_wr_tamp_o            (shdwctlr_o_wr_tamp_int),
        .shdw_ctlr_wr_valid_o           (shdwctlr_o_wr_valid_int),

        .shdw_ctlr_rd_data_o            (shdwctlr_o_rd_data_int),
        .shdw_ctlr_rd_valid_o           (shdwctlr_o_rd_valid_int),

        .shdw_ctlr_wr_rsp_i             (msgdec_o_wr_rsp_int),
        .shdw_ctlr_wr_valid_i           (msgdec_o_wr_valid_int),

        .shdw_ctlr_prot_block_o         (shdwctlr_o_prot_block_int),

        .shdw_ctlr_cmp_pwr_st_i         (cfg_pwr_st_i),
        .prot_size_i                    (cfg_prot_size_i),
        .sram_init_done_o               (cfg_sram_init_done_o),

        .shdw_ctlr_up_pkt_sent_i        (us_pkt_sent_int),
        .shdw_ctlr_us_last_pkt_o        (shdwctlr_o_us_last_pkt_int),

        .shdw_ctlr_lpi_ram_req_o        (cfg_lpi_ram_req_o),
        .shdw_ctlr_lpi_ram_ack_i        (cfg_lpi_ram_ack_i),
        .shdw_ctlr_clk_busy_o           (shdwctlr_o_clk_busy_int),
        .shdw_ctlr_lpi_ram_init_i       (cfg_lpi_ram_init_i),
        .shdw_ctlr_lpi_default_state_i  (cfg_default_state_i),

        .shdw_ctlr_add_op1_o            (shdwctlr_o_add_op1_int),
        .shdw_ctlr_add_op2_o            (shdwctlr_o_add_op2_int),
        .shdw_ctlr_add_en_o             (shdwctlr_o_add_en_int),
        .shdw_ctlr_add_rslt_i           (add_res_int),

        .shdw_ctlr_sram_addr_o          (cfg_sram_addr_o),
        .shdw_ctlr_sram_cenn_o          (cfg_sram_cenn_o),
        .shdw_ctlr_sram_wenn_o          (cfg_sram_wenn_o),
        .shdw_ctlr_sram_data_o          (cfg_sram_data_o),
        .shdw_ctlr_sram_data_i          (cfg_sram_data_i)
    );

  end
  else begin: SHDW_CTLR_SRE0
    assign shdwctlr_o_restore_done_int  = 1'b0;
    assign shdwctlr_o_restore_fw_id_int = {LOG2_FW_NUM_FC{1'b0}};
    assign shdwctlr_o_wr_aft_dsc_int    = {FW_NUM_FC{1'b0}};
    assign shdwctlr_o_wr_aft_rst_int    = {FW_NUM_FC{1'b0}};
    assign shdwctlr_o_rgn_int           = {(RWE_CTRL_WIDTH*FW_NUM_FC){1'b0}};
    assign shdwctlr_o_fw_id_int         = {LOG2_FW_NUM_FC{1'b0}};
    assign shdwctlr_o_restore_data_int  = {SRAM_WIDTH{1'b0}};
    assign shdwctlr_o_first_restore_data_int = 1'b0;
    assign shdwctlr_o_restore_valid_int = 1'b0;
    assign shdwctlr_o_cfg_valid_int     = 1'b0;
    assign shdwctlr_o_wr_rsp_int        = 1'b0;
    assign shdwctlr_o_wr_tamp_int       = 1'b0;
    assign shdwctlr_o_wr_valid_int      = 1'b0;
    assign shdwctlr_o_rd_data_int       = {REG_DATA_WIDTH{1'b0}};
    assign shdwctlr_o_rd_valid_int      = 1'b0;
    assign shdwctlr_o_prot_block_int    = 1'b0;
    assign cfg_sram_init_done_o         = 1'b0;
    assign shdwctlr_o_us_last_pkt_int   = 1'b0;
    assign cfg_lpi_ram_req_o            = 1'b0;
    assign shdwctlr_o_clk_busy_int      = 1'b0;
    assign shdwctlr_o_add_op1_int       = {ADDER_WIDTH{1'b0}};
    assign shdwctlr_o_add_op2_int       = {ADDER_WIDTH{1'b0}};
    assign shdwctlr_o_add_en_int        = 1'b0;
    assign cfg_sram_addr_o              = {LOG2_SRAM_SIZE{1'b0}};
    assign cfg_sram_cenn_o              = 1'b1;
    assign cfg_sram_wenn_o              = 1'b1;
    assign cfg_sram_data_o              = {SRAM_WIDTH{1'b0}};

  end
endgenerate

generate
  if (FW_SRE_LVL == 1) begin : ADDR_SRE1

    firewall_f0_ctlr_adder #(
        .ADDER_WIDTH        (ADDER_WIDTH)
    ) u_firewall_f0_ctlr_adder (
        .add_oprnd_shdw_1_i (shdwctlr_o_add_op1_int),
        .add_oprnd_shdw_2_i (shdwctlr_o_add_op2_int),
        .add_oprnd_addr_1_i (addrdec_add_op1_int),
        .add_oprnd_addr_2_i (addrdec_add_op2_int),
        .add_shdw_en_i      (shdwctlr_o_add_en_int),
        .add_addr_en_i      (addrdec_add_en_int),
        .add_rslt_o         (add_res_int)
    );

  end
  else begin: ADDR_SRE0
    assign add_res_int = {ADDER_WIDTH{1'b0}};
  end
endgenerate

firewall_f0_ctlr_cmp_pwr_hndsk #(
    .FW_SRE_LVL               (FW_SRE_LVL),
    .FW_NUM_FC                (FW_NUM_FC),
    .LOG2_FW_NUM_FC           (LOG2_FW_NUM_FC)
) u_firewall_f0_ctlr_cmp_pwr_hndsk (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .cmp_pwr_con_req_i        (msgdec_o_pwr_con_req_int),
    .cmp_pwr_discon_req_i     (msgdec_o_pwr_discon_req_int),
    .cmp_pwr_fw_id_i          (msgdec_o_pwr_fw_id_int),
    .cmp_pwr_req_valid_i      (msgdec_o_pwr_valid_int),
    .cmp_pwr_prot_block_o     (cmppwr_o_prot_block_int),
    .cmp_pwr_trkr_i           (prtcnv_o_trkr_int),
    .cmp_pwr_hndshk_pend_o    (cmppwr_o_hndshk_pend_int),
    .cmp_pwr_cfg_pend_i       (prtcnv_o_cfg_pend_int),
    .cmp_pwr_restore_req_o    (cmppwr_restore_req_int),
    .cmp_pwr_restore_fw_id_o  (cmppwr_restore_fw_id_int),
    .cmp_pwr_restore_valid_o  (cmppwr_o_restore_valid_int),
    .cmp_pwr_restore_done_i   (shdwctlr_o_restore_done_int),
    .cmp_pwr_shdw_init_done_i (cfg_sram_init_done_o),
    .cmp_pwr_wr_aft_dsc_i     (shdwctlr_o_wr_aft_dsc_int),
    .cmp_pwr_wr_aft_rst_i     (shdwctlr_o_wr_aft_rst_int),
    .cmp_pwr_con_fw_id_o      (cmppwr_o_con_fw_id_int),
    .cmp_pwr_con_valid_o      (cmppwr_o_con_valid_int),
    .cmp_pwr_shdw_con_valid_o (cmppwr_o_shdw_con_valid_int),
    .cmp_pwr_shdw_con_fw_id_o (cmppwr_o_shdw_con_fw_id_int),
    .cmp_pwr_discon_valid_o   (cmppwr_o_discon_valid_int),
    .cmp_pwr_clk_busy_o       (cmppwr_o_clk_busy_int),
    .cmp_pwr_us_last_sent_i   (us_last_sent_int),
    .comp_pwr_st_o            (cfg_pwr_st_o),
    .comp_pwr_st_en_o         (cfg_pwr_st_en_o),
    .comp_pwr_st_i            (cfg_pwr_st_i)
);


assign cfg_lpi_clk_busy_o = ds_busy_int || us_busy_int || accrtr_busy_int ||
                            msgdec_busy_int || rdhnd_busy_int ||
                            wrhnd_busy_int || regctlr_busy_int ||
                            addrdec_busy_int || prtcnv_busy_int ||
                            shdwctlr_o_clk_busy_int || cmppwr_o_clk_busy_int ||
                            !cfg_sram_cenn_o;


endmodule
