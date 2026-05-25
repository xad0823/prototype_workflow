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

module firewall_f0_comp_reg_ctlr #(
    `include "firewall_f0_reg_width_params.vh"
    ,
    `include "firewall_f0_reg_addr_params.vh"
    parameter FC_CFG_DATA_W       = 32,
    parameter FC_NUM_RGN          = 2,
    parameter LOG2_FC_NUM_RGN     = 1,
    parameter REG_ADDR_WIDTH      = 10,
    parameter REG_DATA_WIDTH      = 32,
    parameter FW_SRE_LVL          = 1,
    parameter READ_DATA_SIZE      = 7,
    parameter FC_PE_LVL           = 2,
    parameter FW_LDE_LVL          = 2,
    parameter FC_MXRS             = 25,
    parameter FC_RSE_LVL          = 1,
    parameter FC_TE_LVL           = 2,
    parameter FC_NUM_MPE          = 2,
    parameter FC_SINGLE_MST       = 1,
    parameter FC_ME_LVL           = 1,
    parameter FC_INST_SPT         = 1,
    parameter FC_MA_SPT           = 1,
    parameter FC_SEC_SPT          = 1,
    parameter FC_PRIV_SPT         = 1,
    parameter FC_SH_SPT           = 1,
    parameter SRAM_WIDTH          = 32,
    parameter FC_ID               = 1,
    parameter FW_MAX_MST_ID_WIDTH = 8,
    parameter FC_MST_ID_WIDTH     = 8,
    parameter FW_NUM_FC           = 0
) (
    input  wire                                    clk,
    input  wire                                    reset_n,

    input  wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_i,
    output wire                                    pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_o,

    input  wire [PE_ST_WIDTH-1:0]                  pe_st_i,

    input  wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_i,
    output wire                                    rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_o,

    input  wire [RGN_CTRL0_WIDTH-1:0]              rgn_ctrl0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_ctrl0_en,
    output wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_o,

    input  wire [RGN_CTRL1_WIDTH-1:0]              rgn_ctrl1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_ctrl1_en,
    output wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_o,

    input  wire [RGN_LCTRL_WIDTH-1:0]              rgn_lctrl_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_lctrl_en,
    output wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_o,

    input  wire [RGN_ST_WIDTH-1:0]                 rgn_st_rgn_i,

    input  wire [RGN_CFG0_WIDTH-1:0]               rgn_cfg0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_cfg0_en,
    output wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]  rgn_cfg0_o,

    input  wire [RGN_CFG1_WIDTH-1:0]               rgn_cfg1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_cfg1_en,
    output wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]  rgn_cfg1_o,

    input  wire [RGN_SIZE_WIDTH-1:0]               rgn_size_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_size_en,
    output wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  rgn_size_o,

    input  wire [RGN_TCFG0_WIDTH-1:0]              rgn_tcfg0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg0_en,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_o,

    input  wire [RGN_TCFG1_WIDTH-1:0]              rgn_tcfg1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg1_en,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_o,

    input  wire [RGN_TCFG2_WIDTH-1:0]              rgn_tcfg2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg2_en,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid0_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid1_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid2_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid3_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid3_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_o,

    input  wire [RGN_MPL0_WIDTH-1:0]               rgn_mpl0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl0_en,
    output wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rgn_mpl0_o,

    input  wire [RGN_MPL1_WIDTH-1:0]               rgn_mpl1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl1_en,
    output wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rgn_mpl1_o,

    input  wire [RGN_MPL2_WIDTH-1:0]               rgn_mpl2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl2_en,
    output wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rgn_mpl2_o,

    input  wire [RGN_MPL3_WIDTH-1:0]               rgn_mpl3_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl3_en,
    output wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rgn_mpl3_o,

    input  wire [FE_TAL_WIDTH-1:0]                 fe_tal_i,

    input  wire [FE_TAU_WIDTH-1:0]                 fe_tau_i,

    input  wire [FE_TP_WIDTH-1:0]                  fe_tp_i,

    input  wire [FC_MST_ID_WIDTH-1:0]              fe_mid_i,

    input  wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_i,
    output wire                                    fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_o,

    input  wire [ME_CTRL_WIDTH-1:0]                me_ctrl_i,
    output wire                                    me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                me_ctrl_o,

    input  wire [ME_ST_WIDTH-1:0]                  me_st_i,
    output wire                                    me_st_en,
    output wire [ME_ST_WIDTH-1:0]                  me_st_o,

    input  wire [EDR_TAL_WIDTH-1:0]                edr_tal_i,
    output wire                                    edr_tal_en,
    output wire [EDR_TAL_WIDTH-1:0]                edr_tal_o,

    input  wire [EDR_TAU_WIDTH-1:0]                edr_tau_i,
    output wire                                    edr_tau_en,
    output wire [EDR_TAU_WIDTH-1:0]                edr_tau_o,

    input  wire [EDR_TP_WIDTH-1:0]                 edr_tp_i,
    output wire                                    edr_tp_en,
    output wire [EDR_TP_WIDTH-1:0]                 edr_tp_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              edr_mid_i,
    output wire                                    edr_mid_en,
    output wire [FC_MST_ID_WIDTH-1:0]              edr_mid_o,

    input  wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_i,
    output wire                                    edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_o,

    output wire                                    prot_size_en,
    output wire [PROT_SIZE_WIDTH-1:0]              prot_size_o,

    input  wire [PE_BPS_WIDTH-1:0]                 pe_bps_i,

    input  wire [LD_CTRL_WIDTH-1:0]                ld_ctrl_i,
    output wire                                    ld_ctrl_en,
    output wire [LD_CTRL_WIDTH-1:0]                ld_ctrl_o,

    output wire                                    reg_ctlr_restore_done_o,
    output wire                                    reg_ctlr_lpi_busy_o,

    input  wire                                    reg_ctlr_restore_i,
    input  wire [FC_CFG_DATA_W-1:0]                reg_ctlr_restore_data_i,
    input  wire                                    reg_ctlr_con_accept_i,
    input  wire                                    reg_ctlr_reg_rw_i,
    input  wire [REG_ADDR_WIDTH-1:0]               reg_ctlr_reg_addr_i,
    input  wire [REG_DATA_WIDTH-1:0]               reg_ctlr_wr_data_i,
    input  wire                                    reg_ctlr_reg_valid_i,

    output wire                                    reg_ctlr_wr_rsp_o,
    output wire                                    reg_ctlr_wr_tamp_o,
    output wire [REG_DATA_WIDTH-1:0]               reg_ctlr_rd_data_o,
    output wire                                    reg_ctlr_rw_o,
    output wire                                    reg_ctlr_msg_valid_o,
    output wire [READ_DATA_SIZE-1:0]               reg_ctlr_msg_size_o
);


localparam FC_PE_LVL_RSTR     = FC_PE_LVL;
localparam FW_LDE_LVL_RSTR    = FW_LDE_LVL;
localparam FC_MXRS_RSTR       = FC_MXRS;
localparam FC_RSE_LVL_RSTR    = FC_RSE_LVL;
localparam FC_TE_LVL_RSTR     = FC_TE_LVL;
localparam FC_NUM_MPE_RSTR    = FC_NUM_MPE;
localparam FC_SINGLE_MST_RSTR = FC_SINGLE_MST;
localparam FC_ME_LVL_RSTR     = FC_ME_LVL;
localparam FC_INST_SPT_RSTR   = FC_INST_SPT;
localparam FC_MA_SPT_RSTR     = FC_MA_SPT;
localparam FC_SEC_SPT_RSTR    = FC_SEC_SPT;
localparam FC_PRIV_SPT_RSTR   = FC_PRIV_SPT;
localparam FC_SH_SPT_RSTR     = FC_SH_SPT;
localparam FC_NUM_RGN_RSTR    = FC_NUM_RGN;
localparam FC_ID_RSTR         = FC_ID;
localparam RGN_MID0_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID1_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID2_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID3_WIDTH     = FW_MAX_MST_ID_WIDTH;

`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"
`include "firewall_f0_reg_exists_localparams.vh"
`include "firewall_f0_sram_reg_lut_localparams.vh"



localparam PE_CTRL_COMP   = PE_CTRL_EXISTS && (!PE_CTRL_FIXED || (FW_SRE_LVL == 0));
localparam PE_ST_COMP     = PE_ST_EXISTS && (!PE_ST_FIXED || (FW_SRE_LVL == 0));
localparam PE_BPS_COMP    = PE_BPS_EXISTS && (!PE_BPS_FIXED || (FW_SRE_LVL == 0));
localparam RWE_CTRL_COMP  = RWE_CTRL_EXISTS && (!RWE_CTRL_FIXED || (FW_SRE_LVL == 0));
localparam RGN_CTRL0_COMP = RGN_CTRL0_EXISTS && (!RGN_CTRL0_FIXED || (FW_SRE_LVL == 0));
localparam RGN_CTRL1_COMP = RGN_CTRL1_EXISTS && (!RGN_CTRL1_FIXED || (FW_SRE_LVL == 0));
localparam RGN_LCTRL_COMP = RGN_LCTRL_EXISTS && (!RGN_LCTRL_FIXED || (FW_SRE_LVL == 0));
localparam RGN_ST_COMP    = RGN_ST_EXISTS && (!RGN_ST_FIXED || (FW_SRE_LVL == 0));
localparam RGN_CFG0_COMP  = RGN_CFG0_EXISTS;
localparam RGN_CFG1_COMP  = RGN_CFG1_EXISTS;
localparam RGN_SIZE_COMP  = RGN_SIZE_EXISTS;
localparam RGN_TCFG0_COMP = RGN_TCFG0_EXISTS;
localparam RGN_TCFG1_COMP = RGN_TCFG1_EXISTS;
localparam RGN_TCFG2_COMP = RGN_TCFG2_EXISTS;
localparam RGN_MID0_COMP  = RGN_MID0_EXISTS;
localparam RGN_MID1_COMP  = RGN_MID1_EXISTS;
localparam RGN_MID2_COMP  = RGN_MID2_EXISTS;
localparam RGN_MID3_COMP  = RGN_MID3_EXISTS;
localparam RGN_MPL0_COMP  = RGN_MPL0_EXISTS;
localparam RGN_MPL1_COMP  = RGN_MPL1_EXISTS;
localparam RGN_MPL2_COMP  = RGN_MPL2_EXISTS;
localparam RGN_MPL3_COMP  = RGN_MPL3_EXISTS;
localparam FE_TAL_COMP    = FE_TAL_EXISTS;
localparam FE_TAU_COMP    = FE_TAU_EXISTS;
localparam FE_TP_COMP     = FE_TP_EXISTS;
localparam FE_MID_COMP    = FE_MID_EXISTS;
localparam FE_CTRL_COMP   = FE_CTRL_EXISTS;
localparam ME_CTRL_COMP   = ME_CTRL_EXISTS && (!ME_CTRL_FIXED || (FW_SRE_LVL == 0));
localparam ME_ST_COMP     = ME_ST_EXISTS && (!ME_ST_FIXED || (FW_SRE_LVL == 0));
localparam EDR_TAL_COMP   = EDR_TAL_EXISTS;
localparam EDR_TAU_COMP   = EDR_TAU_EXISTS;
localparam EDR_TP_COMP    = EDR_TP_EXISTS;
localparam EDR_MID_COMP   = EDR_MID_EXISTS;
localparam EDR_CTRL_COMP  = EDR_CTRL_EXISTS;
localparam PROT_SIZE_COMP = PROT_SIZE_EXISTS && (!PROT_SIZE_FIXED || (FW_SRE_LVL == 0));
localparam BYPASS_COMP    = BYPASS_EXISTS && (!BYPASS_FIXED || (FW_SRE_LVL == 0));
localparam LD_CTRL_COMP   = LD_CTRL_EXISTS && (!LD_CTRL_FIXED || (FW_SRE_LVL == 0));


localparam RESTORE_BEAT_COUNT = firewall_f0_ceil_divide(SRAM_WIDTH, FC_CFG_DATA_W);
localparam LOG2_RESTORE_BEAT_COUNT = firewall_f0_log2(RESTORE_BEAT_COUNT);
localparam RESTORE_BUFFER_SIZE = (RESTORE_BEAT_COUNT-1)*FC_CFG_DATA_W;


localparam CHECK_TYPE_WIDTH = 3;
localparam CHECK_RWE_DATA   = 3'b000;
localparam CHECK_RWE_MPL    = 3'b001;
localparam CHECK_RWE_EN     = 3'b010;
localparam CHECK_RWE_LOCK   = 3'b011;
localparam CHECK_FW_LOCK    = 3'b100;
localparam CHECK_LDE        = 3'b101;


wire reg_en_nxt;

wire                     pe_ctrl_en_reg_nxt;
wire                     pe_ctrl_en_res_nxt;
wire [PE_CTRL_WIDTH-1:0] pe_ctrl_wr_reg_nxt;
wire [PE_CTRL_WIDTH-1:0] pe_ctrl_wr_res_nxt;

wire                      rwe_ctrl_en_reg_nxt;
wire                      rwe_ctrl_en_res_nxt;
wire [RWE_CTRL_WIDTH-1:0] rwe_ctrl_wr_reg_nxt;
wire [RWE_CTRL_WIDTH-1:0] rwe_ctrl_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_ctrl0_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_ctrl0_en_res_nxt;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_ctrl1_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_ctrl1_en_res_nxt;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_lctrl_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_lctrl_en_res_nxt;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                  rgn_cfg0_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                  rgn_cfg0_en_res_nxt;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0] rgn_cfg0_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0] rgn_cfg0_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                  rgn_cfg1_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                  rgn_cfg1_en_res_nxt;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0] rgn_cfg1_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0] rgn_cfg1_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                  rgn_size_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                  rgn_size_en_res_nxt;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0] rgn_size_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0] rgn_size_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_tcfg0_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_tcfg0_en_res_nxt;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_tcfg1_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_tcfg1_en_res_nxt;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_tcfg2_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_tcfg2_en_res_nxt;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mid0_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mid0_en_res_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_wr_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mid1_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mid1_en_res_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_wr_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mid2_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mid2_en_res_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_wr_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mid3_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mid3_en_res_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_wr_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mpl0_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mpl0_en_res_nxt;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rgn_mpl0_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rgn_mpl0_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mpl1_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mpl1_en_res_nxt;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rgn_mpl1_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rgn_mpl1_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mpl2_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mpl2_en_res_nxt;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rgn_mpl2_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rgn_mpl2_wr_res_nxt;

wire [FC_NUM_RGN-1:0]                   rgn_mpl3_en_reg_nxt;
wire [FC_NUM_RGN-1:0]                   rgn_mpl3_en_res_nxt;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rgn_mpl3_wr_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rgn_mpl3_wr_res_nxt;

wire                     fe_ctrl_en_reg_nxt;
wire [FE_CTRL_WIDTH-1:0] fe_ctrl_wr_reg_nxt;

wire                     me_ctrl_en_reg_nxt;
wire                     me_ctrl_en_res_nxt;
wire [ME_CTRL_WIDTH-1:0] me_ctrl_wr_reg_nxt;
wire [ME_CTRL_WIDTH-1:0] me_ctrl_wr_res_nxt;

wire                     edr_tal_en_reg_nxt;
wire [EDR_TAL_WIDTH-1:0] edr_tal_wr_reg_nxt;

wire                     edr_tau_en_reg_nxt;
wire [EDR_TAU_WIDTH-1:0] edr_tau_wr_reg_nxt;

wire                    edr_tp_en_reg_nxt;
wire [EDR_TP_WIDTH-1:0] edr_tp_wr_reg_nxt;

wire                       edr_mid_en_reg_nxt;
wire [FC_MST_ID_WIDTH-1:0] edr_mid_wr_reg_nxt;

wire                      edr_ctrl_en_reg_nxt;
wire [EDR_CTRL_WIDTH-1:0] edr_ctrl_wr_reg_nxt;

wire                     ld_ctrl_en_reg_nxt;
wire [LD_CTRL_WIDTH-1:0] ld_ctrl_wr_reg_nxt;

wire                       prot_size_en_con_nxt;
wire                       prot_size_en_res_nxt;
wire [PROT_SIZE_WIDTH-1:0] prot_size_wr_con_nxt;
wire [PROT_SIZE_WIDTH-1:0] prot_size_wr_res_nxt;

reg [REG_DATA_WIDTH-1:0] rd_data_nxt;

wire [REG_ADDR_WIDTH+2-1:0] reg_addr_pad;
wire [REG_ADDR_WIDTH+2-1:0] reg_addr_enum;

reg [READ_DATA_SIZE-1:0] msg_size_nxt;

wire write_allowed;

wire tamper_rgn;
wire tamper_ld_st;
wire tamper_ld;
wire tamper;

reg                        dyn_chk_req_nxt;
reg [CHECK_TYPE_WIDTH-1:0] dyn_chk_req_type_nxt;

reg [FC_NUM_RGN-1:0] rwe_ctrl_pow_2;

integer i;

wire                  restore_val;
wire [SRAM_WIDTH-1:0] restore_data_int;

wire restore_sre_1;

wire [LOG2_RESTORE_SIZE-1:0] restore_cntr;
wire [LOG2_RESTORE_SIZE-1:0] restore_cntr_nxt;

wire restore_connect_done;
wire restore_done;
reg  restore_done_r;


assign reg_addr_pad = {reg_ctlr_reg_addr_i, 2'b00};


always @* begin
  rwe_ctrl_pow_2 = {FC_NUM_RGN{1'b0}};
  for (i=0; i<FC_NUM_RGN; i=i+1) begin
    if (rwe_ctrl_i == i) begin
      rwe_ctrl_pow_2[i] = 1'b1;
    end
  end
end


assign reg_addr_enum =
  (PE_CTRL_COMP && (reg_addr_pad == PE_CTRL_ADDR)) ? 
  PE_CTRL_ADDR :                                     
  (PE_ST_COMP && (reg_addr_pad == PE_ST_ADDR)) ?     
  PE_ST_ADDR :
  (PE_BPS_COMP && (reg_addr_pad == PE_BPS_ADDR)) ?
  PE_BPS_ADDR :
  (RWE_CTRL_COMP && (reg_addr_pad == RWE_CTRL_ADDR)) ?
  RWE_CTRL_ADDR :
  (RGN_CTRL0_COMP && (reg_addr_pad == RGN_CTRL0_ADDR)) ?
  RGN_CTRL0_ADDR :
  (RGN_CTRL1_COMP && (reg_addr_pad == RGN_CTRL1_ADDR)) ?
  RGN_CTRL1_ADDR :
  (RGN_LCTRL_COMP && (reg_addr_pad == RGN_LCTRL_ADDR)) ?
  RGN_LCTRL_ADDR :
  (RGN_ST_COMP && (reg_addr_pad == RGN_ST_ADDR)) ?
  RGN_ST_ADDR :
  (RGN_CFG0_COMP && (reg_addr_pad == RGN_CFG0_ADDR)) ?
  RGN_CFG0_ADDR :
  (RGN_CFG1_COMP && (reg_addr_pad == RGN_CFG1_ADDR)) ?
  RGN_CFG1_ADDR :
  (RGN_SIZE_COMP && (reg_addr_pad == RGN_SIZE_ADDR)) ?
  RGN_SIZE_ADDR :
  (RGN_TCFG0_COMP && (reg_addr_pad == RGN_TCFG0_ADDR)) ?
  RGN_TCFG0_ADDR :
  (RGN_TCFG1_COMP && (reg_addr_pad == RGN_TCFG1_ADDR)) ?
  RGN_TCFG1_ADDR :
  (RGN_TCFG2_COMP && (reg_addr_pad == RGN_TCFG2_ADDR)) ?
  RGN_TCFG2_ADDR :
  (RGN_MID0_COMP && (reg_addr_pad == RGN_MID0_ADDR)) ?
  RGN_MID0_ADDR :
  (RGN_MID1_COMP && (reg_addr_pad == RGN_MID1_ADDR)) ?
  RGN_MID1_ADDR :
  (RGN_MID2_COMP && (reg_addr_pad == RGN_MID2_ADDR)) ?
  RGN_MID2_ADDR :
  (RGN_MID3_COMP && (reg_addr_pad == RGN_MID3_ADDR)) ?
  RGN_MID3_ADDR :
  (RGN_MPL0_COMP && (reg_addr_pad == RGN_MPL0_ADDR)) ?
  RGN_MPL0_ADDR :
  (RGN_MPL1_COMP && (reg_addr_pad == RGN_MPL1_ADDR)) ?
  RGN_MPL1_ADDR :
  (RGN_MPL2_COMP && (reg_addr_pad == RGN_MPL2_ADDR)) ?
  RGN_MPL2_ADDR :
  (RGN_MPL3_COMP && (reg_addr_pad == RGN_MPL3_ADDR)) ?
  RGN_MPL3_ADDR :
  (FE_TAL_COMP && (reg_addr_pad == FE_TAL_ADDR)) ?
  FE_TAL_ADDR :
  (FE_TAU_COMP && (reg_addr_pad == FE_TAU_ADDR)) ?
  FE_TAU_ADDR :
  (FE_TP_COMP && (reg_addr_pad == FE_TP_ADDR)) ?
  FE_TP_ADDR :
  (FE_MID_COMP && (reg_addr_pad == FE_MID_ADDR)) ?
  FE_MID_ADDR :
  (FE_CTRL_COMP && (reg_addr_pad == FE_CTRL_ADDR)) ?
  FE_CTRL_ADDR :
  (ME_CTRL_COMP && (reg_addr_pad == ME_CTRL_ADDR)) ?
  ME_CTRL_ADDR :
  (ME_ST_COMP && (reg_addr_pad == ME_ST_ADDR)) ?
  ME_ST_ADDR :
  (EDR_TAL_COMP && (reg_addr_pad == EDR_TAL_ADDR)) ?
  EDR_TAL_ADDR :
  (EDR_TAU_COMP && (reg_addr_pad == EDR_TAU_ADDR)) ?
  EDR_TAU_ADDR :
  (EDR_TP_COMP && (reg_addr_pad == EDR_TP_ADDR)) ?
  EDR_TP_ADDR :
  (EDR_MID_COMP && (reg_addr_pad == EDR_MID_ADDR)) ?
  EDR_MID_ADDR :
  (EDR_CTRL_COMP && (reg_addr_pad == EDR_CTRL_ADDR)) ?
  EDR_CTRL_ADDR :
  (LD_CTRL_COMP && (reg_addr_pad == LD_CTRL_ADDR)) ?
  LD_CTRL_ADDR :
  {REG_ADDR_WIDTH+2{1'bx}};


assign pe_ctrl_en_reg_nxt   = (reg_addr_enum == PE_CTRL_ADDR);
assign rwe_ctrl_en_reg_nxt  = (reg_addr_enum == RWE_CTRL_ADDR);
assign rgn_ctrl0_en_reg_nxt = (reg_addr_enum == RGN_CTRL0_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_ctrl1_en_reg_nxt = (reg_addr_enum == RGN_CTRL1_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_lctrl_en_reg_nxt = (reg_addr_enum == RGN_LCTRL_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_cfg0_en_reg_nxt  = (reg_addr_enum == RGN_CFG0_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_cfg1_en_reg_nxt  = (reg_addr_enum == RGN_CFG1_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_size_en_reg_nxt  = (reg_addr_enum == RGN_SIZE_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg0_en_reg_nxt = (reg_addr_enum == RGN_TCFG0_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg1_en_reg_nxt = (reg_addr_enum == RGN_TCFG1_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg2_en_reg_nxt = (reg_addr_enum == RGN_TCFG2_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid0_en_reg_nxt  = (reg_addr_enum == RGN_MID0_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid1_en_reg_nxt  = (reg_addr_enum == RGN_MID1_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid2_en_reg_nxt  = (reg_addr_enum == RGN_MID2_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid3_en_reg_nxt  = (reg_addr_enum == RGN_MID3_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl0_en_reg_nxt  = (reg_addr_enum == RGN_MPL0_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl1_en_reg_nxt  = (reg_addr_enum == RGN_MPL1_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl2_en_reg_nxt  = (reg_addr_enum == RGN_MPL2_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl3_en_reg_nxt  = (reg_addr_enum == RGN_MPL3_ADDR) ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign fe_ctrl_en_reg_nxt   = (reg_addr_enum == FE_CTRL_ADDR);
assign me_ctrl_en_reg_nxt   = (reg_addr_enum == ME_CTRL_ADDR);
assign edr_tal_en_reg_nxt   = (reg_addr_enum == EDR_TAL_ADDR);
assign edr_tau_en_reg_nxt   = (reg_addr_enum == EDR_TAU_ADDR);
assign edr_tp_en_reg_nxt    = (reg_addr_enum == EDR_TP_ADDR);
assign edr_mid_en_reg_nxt   = (reg_addr_enum == EDR_MID_ADDR);
assign edr_ctrl_en_reg_nxt  = (reg_addr_enum == EDR_CTRL_ADDR);
assign ld_ctrl_en_reg_nxt   = (reg_addr_enum == LD_CTRL_ADDR);


assign pe_ctrl_wr_reg_nxt = PE_CTRL_COMP ?
  reg_ctlr_wr_data_i[PE_CTRL_WIDTH-1:0] :
  {PE_CTRL_WIDTH{1'b0}};

assign rwe_ctrl_wr_reg_nxt = RWE_CTRL_COMP ?
  reg_ctlr_wr_data_i[RWE_CTRL_WIDTH-1:0] :
  {RWE_CTRL_WIDTH{1'b0}};

assign rgn_ctrl0_wr_reg_nxt = RGN_CTRL0_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_CTRL0_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};

assign rgn_ctrl1_wr_reg_nxt = RGN_CTRL1_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_CTRL1_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};

assign rgn_lctrl_wr_reg_nxt = RGN_LCTRL_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_LCTRL_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};

assign rgn_cfg0_wr_reg_nxt = RGN_CFG0_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_CFG0_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_CFG0_WIDTH{1'b0}};

assign rgn_cfg1_wr_reg_nxt = RGN_CFG1_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_CFG1_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};

assign rgn_size_wr_reg_nxt = RGN_SIZE_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_SIZE_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};

assign rgn_tcfg0_wr_reg_nxt = RGN_TCFG0_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_TCFG0_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};

assign rgn_tcfg1_wr_reg_nxt = RGN_TCFG1_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_TCFG1_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};

assign rgn_tcfg2_wr_reg_nxt = RGN_TCFG2_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_TCFG2_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};

assign rgn_mid0_wr_reg_nxt = RGN_MID0_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[FC_MST_ID_WIDTH-1:0]}} :
  {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

assign rgn_mid1_wr_reg_nxt = RGN_MID1_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[FC_MST_ID_WIDTH-1:0]}} :
  {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

assign rgn_mid2_wr_reg_nxt = RGN_MID2_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[FC_MST_ID_WIDTH-1:0]}} :
  {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

assign rgn_mid3_wr_reg_nxt = RGN_MID3_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[FC_MST_ID_WIDTH-1:0]}} :
  {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

assign rgn_mpl0_wr_reg_nxt = RGN_MPL0_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_MPL0_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};

assign rgn_mpl1_wr_reg_nxt = RGN_MPL1_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_MPL1_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};

assign rgn_mpl2_wr_reg_nxt = RGN_MPL2_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_MPL2_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};

assign rgn_mpl3_wr_reg_nxt = RGN_MPL3_COMP ?
  {FC_NUM_RGN{reg_ctlr_wr_data_i[RGN_MPL3_WIDTH-1:0]}} :
  {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};

assign fe_ctrl_wr_reg_nxt = FE_CTRL_COMP ?
  reg_ctlr_wr_data_i[FE_CTRL_WIDTH-1:0] :
  {FE_CTRL_WIDTH{1'b0}};

assign me_ctrl_wr_reg_nxt = ME_CTRL_COMP ?
  reg_ctlr_wr_data_i[ME_CTRL_WIDTH-1:0] :
  {ME_CTRL_WIDTH{1'b0}};

assign edr_tal_wr_reg_nxt = EDR_TAL_COMP ?
  reg_ctlr_wr_data_i[EDR_TAL_WIDTH-1:0] :
  {EDR_TAL_WIDTH{1'b0}};

assign edr_tau_wr_reg_nxt = EDR_TAU_COMP ?
  reg_ctlr_wr_data_i[EDR_TAU_WIDTH-1:0] :
  {EDR_TAU_WIDTH{1'b0}};

assign edr_tp_wr_reg_nxt = EDR_TP_COMP ?
  reg_ctlr_wr_data_i[EDR_TP_WIDTH-1:0] :
  {EDR_TP_WIDTH{1'b0}};

assign edr_mid_wr_reg_nxt = EDR_MID_COMP ?
  reg_ctlr_wr_data_i[FC_MST_ID_WIDTH-1:0] :
  {FC_MST_ID_WIDTH{1'b0}};

assign edr_ctrl_wr_reg_nxt = EDR_CTRL_COMP ?
  reg_ctlr_wr_data_i[EDR_CTRL_WIDTH-1:0] :
  {EDR_CTRL_WIDTH{1'b0}};

assign ld_ctrl_wr_reg_nxt = LD_CTRL_COMP ?
  reg_ctlr_wr_data_i[LD_CTRL_WIDTH-1:0] :
  {LD_CTRL_WIDTH{1'b0}};


generate
  if (FW_SRE_LVL == 0) begin : SRE_0
    always @* begin
      case (reg_addr_enum)
        PE_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-PE_CTRL_WIDTH{1'b0}},
                                  pe_ctrl_i};
          msg_size_nxt         = PE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
          dyn_chk_req_type_nxt = CHECK_LDE;
        end
        PE_ST_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-PE_ST_WIDTH{1'b0}}, pe_st_i};
          msg_size_nxt         = PE_ST_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        PE_BPS_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-PE_BPS_WIDTH{1'b0}},
                                  pe_bps_i};
          msg_size_nxt         = PE_BPS_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        RWE_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RWE_CTRL_WIDTH{1'b0}},
                                  rwe_ctrl_i};
          msg_size_nxt         = RWE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        RGN_CTRL0_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_CTRL0_WIDTH{1'b0}},
                                 rgn_ctrl0_rgn_i};
          msg_size_nxt         = RGN_CTRL0_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_EN;
        end
        RGN_CTRL1_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_CTRL1_WIDTH{1'b0}},
                                  rgn_ctrl1_rgn_i};
          msg_size_nxt         = RGN_CTRL1_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_EN;
        end
        RGN_LCTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_LCTRL_WIDTH{1'b0}},
                                  rgn_lctrl_rgn_i};
          msg_size_nxt         = RGN_LCTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
          dyn_chk_req_type_nxt = CHECK_RWE_LOCK;
        end
        RGN_ST_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_ST_WIDTH{1'b0}},
                                  rgn_st_rgn_i};
          msg_size_nxt         = RGN_ST_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        RGN_CFG0_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_CFG0_WIDTH{1'b0}},
                                  rgn_cfg0_rgn_i};
          msg_size_nxt         = RGN_CFG0_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_CFG1_ADDR: begin
          rd_data_nxt          = rgn_cfg1_rgn_i;
          msg_size_nxt         = RGN_CFG1_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_SIZE_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_SIZE_WIDTH{1'b0}},
                                 rgn_size_rgn_i};
          msg_size_nxt         = RGN_SIZE_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG0_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_TCFG0_WIDTH{1'b0}},
                                  rgn_tcfg0_rgn_i};
          msg_size_nxt         = RGN_TCFG0_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG1_ADDR: begin
          rd_data_nxt          = rgn_tcfg1_rgn_i;
          msg_size_nxt         = RGN_TCFG1_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG2_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_TCFG2_WIDTH{1'b0}},
                                 rgn_tcfg2_rgn_i};
          msg_size_nxt         = RGN_TCFG2_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_MID0_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                  rgn_mid0_rgn_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID1_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                  rgn_mid1_rgn_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID2_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                rgn_mid2_rgn_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID3_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                  rgn_mid3_rgn_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL0_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_MPL0_WIDTH{1'b0}},
                                  rgn_mpl0_rgn_i};
          msg_size_nxt         = RGN_MPL0_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL1_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_MPL1_WIDTH{1'b0}},
                                  rgn_mpl1_rgn_i};
          msg_size_nxt         = RGN_MPL1_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL2_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_MPL2_WIDTH{1'b0}},
                                  rgn_mpl2_rgn_i};
          msg_size_nxt         = RGN_MPL2_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL3_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-RGN_MPL3_WIDTH{1'b0}},
                                  rgn_mpl3_rgn_i};
          msg_size_nxt         = RGN_MPL3_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        FE_TAL_ADDR: begin
          rd_data_nxt          = fe_tal_i;
          msg_size_nxt         = FE_TAL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        FE_TAU_ADDR: begin
          rd_data_nxt          = fe_tau_i;
          msg_size_nxt         = FE_TAU_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        FE_TP_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FE_TP_WIDTH{1'b0}}, fe_tp_i};
          msg_size_nxt         = FE_TP_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        FE_MID_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                  fe_mid_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        FE_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FE_CTRL_WIDTH{1'b0}},
                                  fe_ctrl_i};
          msg_size_nxt         = FE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        ME_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-ME_CTRL_WIDTH{1'b0}},
                                  me_ctrl_i};
          msg_size_nxt         = ME_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
          dyn_chk_req_type_nxt = CHECK_LDE;
        end
        ME_ST_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-ME_ST_WIDTH{1'b0}}, me_st_i};
          msg_size_nxt         = ME_ST_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        EDR_TAL_ADDR: begin
          rd_data_nxt          = edr_tal_i;
          msg_size_nxt         = EDR_TAL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        EDR_TAU_ADDR: begin
          rd_data_nxt          = edr_tau_i;
          msg_size_nxt         = EDR_TAU_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        EDR_TP_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-EDR_TP_WIDTH{1'b0}},
                                  edr_tp_i};
          msg_size_nxt         = EDR_TP_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        EDR_MID_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},
                                  edr_mid_i};
          msg_size_nxt         = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        EDR_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-EDR_CTRL_WIDTH{1'b0}},
                                  edr_ctrl_i};
          msg_size_nxt         = EDR_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b0;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};
        end
        LD_CTRL_ADDR: begin
          rd_data_nxt          = {{REG_DATA_WIDTH-LD_CTRL_WIDTH{1'b0}},
                                  ld_ctrl_i};
          msg_size_nxt         = LD_CTRL_WIDTH[READ_DATA_SIZE-1:0];
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_FW_LOCK;
        end
        default: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'bx}};
          msg_size_nxt         = {READ_DATA_SIZE{1'bx}};
          dyn_chk_req_nxt      = 1'bx;
          dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'bx}};
        end
      endcase
    end
  end
  else begin: SRE_1
    always @* begin

      dyn_chk_req_nxt      = 1'b0;
      dyn_chk_req_type_nxt = {CHECK_TYPE_WIDTH{1'b0}};

      case (reg_addr_enum)
        PE_ST_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-PE_ST_WIDTH{1'b0}}, pe_st_i};
          msg_size_nxt = PE_ST_WIDTH[READ_DATA_SIZE-1:0];
        end
        PE_BPS_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-PE_BPS_WIDTH{1'b0}},
                          pe_bps_i};
          msg_size_nxt = PE_BPS_WIDTH[READ_DATA_SIZE-1:0];
        end
        RGN_ST_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-RGN_ST_WIDTH{1'b0}}, rgn_st_rgn_i};
          msg_size_nxt = RGN_ST_WIDTH[READ_DATA_SIZE-1:0];
        end
        RGN_CFG0_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_CFG1_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_SIZE_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG0_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG1_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_TCFG2_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_DATA;
        end
        RGN_MID0_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID1_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID2_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MID3_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL0_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL1_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL2_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        RGN_MPL3_ADDR: begin
          rd_data_nxt          = {REG_DATA_WIDTH{1'b0}};
          msg_size_nxt         = {READ_DATA_SIZE{1'b0}};
          dyn_chk_req_nxt      = 1'b1;
          dyn_chk_req_type_nxt = CHECK_RWE_MPL;
        end
        FE_TAL_ADDR: begin
          rd_data_nxt  = fe_tal_i;
          msg_size_nxt = FE_TAL_WIDTH[READ_DATA_SIZE-1:0];
        end
        FE_TAU_ADDR: begin
          rd_data_nxt  = fe_tau_i;
          msg_size_nxt = FE_TAU_WIDTH[READ_DATA_SIZE-1:0];
        end
        FE_TP_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-FE_TP_WIDTH{1'b0}}, fe_tp_i};
          msg_size_nxt = FE_TP_WIDTH[READ_DATA_SIZE-1:0];
        end
        FE_MID_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, fe_mid_i};
          msg_size_nxt = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
        end
        FE_CTRL_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-FE_CTRL_WIDTH{1'b0}}, fe_ctrl_i};
          msg_size_nxt = FE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
        end
        ME_CTRL_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-ME_CTRL_WIDTH{1'b0}}, me_ctrl_i};
          msg_size_nxt = ME_CTRL_WIDTH[READ_DATA_SIZE-1:0];
        end
        ME_ST_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-ME_ST_WIDTH{1'b0}}, me_st_i};
          msg_size_nxt = ME_ST_WIDTH[READ_DATA_SIZE-1:0];
        end
        EDR_TAL_ADDR: begin
          rd_data_nxt  = edr_tal_i;
          msg_size_nxt = EDR_TAL_WIDTH[READ_DATA_SIZE-1:0];
        end
        EDR_TAU_ADDR: begin
          rd_data_nxt  = edr_tau_i;
          msg_size_nxt = EDR_TAU_WIDTH[READ_DATA_SIZE-1:0];
        end
        EDR_TP_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-EDR_TP_WIDTH{1'b0}}, edr_tp_i};
          msg_size_nxt = EDR_TP_WIDTH[READ_DATA_SIZE-1:0];
        end
        EDR_MID_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, edr_mid_i};
          msg_size_nxt = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
        end
        EDR_CTRL_ADDR: begin
          rd_data_nxt  = {{REG_DATA_WIDTH-EDR_CTRL_WIDTH{1'b0}}, edr_ctrl_i};
          msg_size_nxt = EDR_CTRL_WIDTH[READ_DATA_SIZE-1:0];
        end
        default: begin
          rd_data_nxt  = {REG_DATA_WIDTH{1'bx}};
          msg_size_nxt = {READ_DATA_SIZE{1'bx}};
        end
      endcase
    end
  end
endgenerate


generate
  if ((SRAM_WIDTH > FC_CFG_DATA_W) && FW_SRE_LVL == 1) begin : RESTORE_BUFF

    reg  [LOG2_RESTORE_BEAT_COUNT-1:0] restore_beat_cntr_r;
    wire [LOG2_RESTORE_BEAT_COUNT-1:0] restore_beat_cntr_nxt;

    reg [RESTORE_BUFFER_SIZE-1:0] restore_beat_r;
    reg [RESTORE_BUFFER_SIZE-1:0] restore_beat_nxt;

    integer rstr_idx;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        restore_beat_cntr_r <= {LOG2_RESTORE_BEAT_COUNT{1'b0}};
      end
      else begin
        if (reg_ctlr_restore_i) begin
          restore_beat_cntr_r <= restore_beat_cntr_nxt;
        end
      end
    end

    assign restore_beat_cntr_nxt =
      restore_beat_cntr_r == (RESTORE_BEAT_COUNT - 1) ?
      {LOG2_RESTORE_BEAT_COUNT{1'b0}} :
      restore_beat_cntr_r + {{(LOG2_RESTORE_BEAT_COUNT-1){1'b0}}, 1'b1};


    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        restore_beat_r <= {RESTORE_BUFFER_SIZE{1'b0}};
      end
      else begin
        if (reg_ctlr_restore_i) begin
          restore_beat_r <= restore_beat_nxt;
        end
      end
    end

    always @* begin
      restore_beat_nxt = restore_beat_r;
      for (rstr_idx=0; rstr_idx<RESTORE_BEAT_COUNT-1; rstr_idx=rstr_idx+1) begin
        if (rstr_idx == restore_beat_cntr_r) begin
          restore_beat_nxt[rstr_idx*FC_CFG_DATA_W +: FC_CFG_DATA_W] =
            reg_ctlr_restore_data_i;
        end
      end
    end

    assign restore_val =
      (restore_beat_cntr_r == (RESTORE_BEAT_COUNT - 1)) && reg_ctlr_restore_i;
    assign restore_data_int =
      {reg_ctlr_restore_data_i[SRAM_WIDTH-RESTORE_BUFFER_SIZE-1 : 0],
      restore_beat_nxt};
  end
  else begin: NO_RESTORE_BUFF
    assign restore_val      = reg_ctlr_restore_i;
    assign restore_data_int = reg_ctlr_restore_data_i;
  end


  if (FW_SRE_LVL == 1) begin : RESTORE

    reg [LOG2_RESTORE_SIZE-1:0] restore_cntr_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        restore_cntr_r <= {LOG2_RESTORE_SIZE{1'b0}};
      end
      else begin
        if (restore_val) begin
          restore_cntr_r <= restore_cntr_nxt;
        end
      end
    end

    assign restore_cntr_nxt = (restore_connect_done || restore_done) ?
      {LOG2_RESTORE_SIZE{1'b0}} :
      restore_cntr_r + {{(LOG2_RESTORE_SIZE-1){1'b0}}, 1'b1};

    assign restore_cntr = restore_cntr_r;

    assign restore_done = (restore_cntr_r == (RESTORE_SIZE-1)) && restore_val;

  end
  else begin: NO_RESTORE
    assign restore_cntr = {LOG2_RESTORE_SIZE{1'b0}};
    assign restore_cntr_nxt = {LOG2_RESTORE_SIZE{1'b0}};
    assign restore_done = 1'b0;
  end


  if ((FW_SRE_LVL == 1) && PROT_SIZE_BLOCK_SIZE != 0) begin: RESTORE_PROT_SIZE

    reg                       prot_size_en_res_nxt_r;
    reg [PROT_SIZE_WIDTH-1:0] prot_size_wr_res_nxt_r;

    always @* begin
      prot_size_en_res_nxt_r = 1'b0;
      prot_size_wr_res_nxt_r = {PROT_SIZE_WIDTH{1'b0}};

      if ((restore_cntr >= PROT_SIZE_START) &&
          (restore_cntr <= PROT_SIZE_END)) begin
        prot_size_en_res_nxt_r = 1'b1;
        prot_size_wr_res_nxt_r = restore_data_int[PROT_SIZE_WIDTH-1:0];
      end
    end

    assign prot_size_en_res_nxt = prot_size_en_res_nxt_r;
    assign prot_size_wr_res_nxt = prot_size_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_PROT_SIZE
    assign prot_size_en_res_nxt = 1'b0;
    assign prot_size_wr_res_nxt = {PROT_SIZE_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && RGN_TCFG2_BLOCK_SIZE > 1) begin: RESTORE_RGN_TCFG2

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg2_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_wr_res_nxt_r;
    integer rgn_tcfg2_id;

    always @* begin
      rgn_tcfg2_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg2_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};

      for (rgn_tcfg2_id=0; rgn_tcfg2_id<RGN_TCFG2_BLOCK_SIZE-1; rgn_tcfg2_id=rgn_tcfg2_id+1) begin
        if (rgn_tcfg2_id == (restore_cntr-RGN_TCFG2_START)) begin
          rgn_tcfg2_en_res_nxt_r[((rgn_tcfg2_id+1)*RGN_TCFG2_PER_ROW)-1 -: RGN_TCFG2_PER_ROW] = {RGN_TCFG2_PER_ROW{1'b1}};
          rgn_tcfg2_wr_res_nxt_r[((rgn_tcfg2_id+1)*RGN_TCFG2_PER_ROW*RGN_TCFG2_WIDTH)-1 -: RGN_TCFG2_PER_ROW*RGN_TCFG2_WIDTH] = restore_data_int[(RGN_TCFG2_PER_ROW*RGN_TCFG2_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_TCFG2_END) begin
        rgn_tcfg2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG2_LAST_ROW] = {RGN_TCFG2_LAST_ROW{1'b1}};
        rgn_tcfg2_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1 -: RGN_TCFG2_LAST_ROW*RGN_TCFG2_WIDTH] = restore_data_int[(RGN_TCFG2_LAST_ROW*RGN_TCFG2_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg2_en_res_nxt = rgn_tcfg2_en_res_nxt_r;
    assign rgn_tcfg2_wr_res_nxt = rgn_tcfg2_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_TCFG2_BLOCK_SIZE == 1)) begin: RESTORE_RGN_TCFG2_1

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg2_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_wr_res_nxt_r;

    always @* begin
      rgn_tcfg2_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg2_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};

      if (restore_cntr == RGN_TCFG2_END) begin
        rgn_tcfg2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG2_LAST_ROW] = {RGN_SIZE_LAST_ROW{1'b1}};
        rgn_tcfg2_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1 -: RGN_TCFG2_LAST_ROW*RGN_TCFG2_WIDTH] = restore_data_int[(RGN_TCFG2_LAST_ROW*RGN_TCFG2_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg2_en_res_nxt = rgn_tcfg2_en_res_nxt_r;
    assign rgn_tcfg2_wr_res_nxt = rgn_tcfg2_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_TCFG2
    assign rgn_tcfg2_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_tcfg2_wr_res_nxt = {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && PE_CTRL_BLOCK_SIZE != 0) begin: RESTORE_PE_CTRL

    reg                     pe_ctrl_en_res_nxt_r;
    reg [PE_CTRL_WIDTH-1:0] pe_ctrl_wr_res_nxt_r;

    always @* begin
      pe_ctrl_en_res_nxt_r = 1'b0;
      pe_ctrl_wr_res_nxt_r = {PE_CTRL_WIDTH{1'b0}};

      if ((restore_cntr >= PE_CTRL_START) &&
          (restore_cntr <= PE_CTRL_END)) begin
        pe_ctrl_en_res_nxt_r = 1'b1;
        pe_ctrl_wr_res_nxt_r = restore_data_int[PE_CTRL_WIDTH-1:0];
      end
    end

    assign pe_ctrl_en_res_nxt = pe_ctrl_en_res_nxt_r;
    assign pe_ctrl_wr_res_nxt = pe_ctrl_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_PE_CTRL
    assign pe_ctrl_en_res_nxt = 1'b0;
    assign pe_ctrl_wr_res_nxt = {PE_CTRL_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (ME_CTRL_BLOCK_SIZE != 0)) begin: RESTORE_ME_CTRL

    reg                     me_ctrl_en_res_nxt_r;
    reg [ME_CTRL_WIDTH-1:0] me_ctrl_wr_res_nxt_r;

    always @* begin
      me_ctrl_en_res_nxt_r = 1'b0;
      me_ctrl_wr_res_nxt_r = {ME_CTRL_WIDTH{1'b0}};

      if ((restore_cntr >= ME_CTRL_START) &&
          (restore_cntr <= ME_CTRL_END)) begin
        me_ctrl_en_res_nxt_r = 1'b1;
        me_ctrl_wr_res_nxt_r = restore_data_int[ME_CTRL_WIDTH-1:0];
      end
    end

    assign me_ctrl_en_res_nxt = me_ctrl_en_res_nxt_r;
    assign me_ctrl_wr_res_nxt = me_ctrl_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_ME_CTRL
    assign me_ctrl_en_res_nxt = 1'b0;
    assign me_ctrl_wr_res_nxt = {ME_CTRL_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RWE_CTRL_BLOCK_SIZE != 0)) begin: RESTORE_RWE_CTRL

    reg                      rwe_ctrl_en_res_nxt_r;
    reg [RWE_CTRL_WIDTH-1:0] rwe_ctrl_wr_res_nxt_r;

    always @* begin
      rwe_ctrl_en_res_nxt_r = 1'b0;
      rwe_ctrl_wr_res_nxt_r = {RWE_CTRL_WIDTH{1'b0}};

      if ((restore_cntr >= RWE_CTRL_START) &&
          (restore_cntr <= RWE_CTRL_END)) begin
        rwe_ctrl_en_res_nxt_r = 1'b1;
        rwe_ctrl_wr_res_nxt_r = restore_data_int[RWE_CTRL_WIDTH-1:0];
      end
    end

    assign rwe_ctrl_en_res_nxt = rwe_ctrl_en_res_nxt_r;
    assign rwe_ctrl_wr_res_nxt = rwe_ctrl_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RWE_CTRL
    assign rwe_ctrl_en_res_nxt = 1'b0;
    assign rwe_ctrl_wr_res_nxt = {RWE_CTRL_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_SIZE_BLOCK_SIZE > 1)) begin: RESTORE_RGN_SIZE

    reg [FC_NUM_RGN-1:0]                  rgn_size_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0] rgn_size_wr_res_nxt_r;
    integer rgn_size_id;

    always @* begin
      rgn_size_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_size_wr_res_nxt_r = {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};

      for (rgn_size_id=0; rgn_size_id<RGN_SIZE_BLOCK_SIZE-1; rgn_size_id=rgn_size_id+1) begin
        if (rgn_size_id == (restore_cntr-RGN_SIZE_START)) begin
          rgn_size_en_res_nxt_r[((rgn_size_id+1)*RGN_SIZE_PER_ROW)-1 -: RGN_SIZE_PER_ROW] = {RGN_SIZE_PER_ROW{1'b1}};
          rgn_size_wr_res_nxt_r[((rgn_size_id+1)*RGN_SIZE_PER_ROW*RGN_SIZE_WIDTH)-1 -: RGN_SIZE_PER_ROW*RGN_SIZE_WIDTH] = restore_data_int[(RGN_SIZE_PER_ROW*RGN_SIZE_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_SIZE_END) begin
        rgn_size_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_SIZE_LAST_ROW] = {RGN_SIZE_LAST_ROW{1'b1}};
        rgn_size_wr_res_nxt_r[(FC_NUM_RGN*RGN_SIZE_WIDTH)-1 -: RGN_SIZE_LAST_ROW*RGN_SIZE_WIDTH] = restore_data_int[(RGN_SIZE_LAST_ROW*RGN_SIZE_WIDTH)-1:0];
      end
    end

    assign rgn_size_en_res_nxt = rgn_size_en_res_nxt_r;
    assign rgn_size_wr_res_nxt = rgn_size_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_SIZE_BLOCK_SIZE == 1)) begin: RESTORE_RGN_SIZE_1

    reg [FC_NUM_RGN-1:0]                  rgn_size_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0] rgn_size_wr_res_nxt_r;

    always @* begin
      rgn_size_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_size_wr_res_nxt_r = {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};

      if (restore_cntr == RGN_SIZE_END) begin
        rgn_size_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_SIZE_LAST_ROW] = {RGN_SIZE_LAST_ROW{1'b1}};
        rgn_size_wr_res_nxt_r[(FC_NUM_RGN*RGN_SIZE_WIDTH)-1 -: RGN_SIZE_LAST_ROW*RGN_SIZE_WIDTH] = restore_data_int[(RGN_SIZE_LAST_ROW*RGN_SIZE_WIDTH)-1:0];
      end
    end

    assign rgn_size_en_res_nxt = rgn_size_en_res_nxt_r;
    assign rgn_size_wr_res_nxt = rgn_size_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_SIZE
    assign rgn_size_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_size_wr_res_nxt  = {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_CTRL0_BLOCK_SIZE > 1)) begin: RESTORE_RGN_CTRL0

    reg [FC_NUM_RGN-1:0]                   rgn_ctrl0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_wr_res_nxt_r;
    integer rgn_ctrl0_id;

    always @* begin
      rgn_ctrl0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_ctrl0_wr_res_nxt_r = {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};

      for (rgn_ctrl0_id=0; rgn_ctrl0_id<RGN_CTRL0_BLOCK_SIZE-1; rgn_ctrl0_id=rgn_ctrl0_id+1) begin
        if (rgn_ctrl0_id == (restore_cntr-RGN_CTRL0_START)) begin
          rgn_ctrl0_en_res_nxt_r[((rgn_ctrl0_id+1)*RGN_CTRL0_PER_ROW)-1 -: RGN_CTRL0_PER_ROW] = {RGN_CTRL0_PER_ROW{1'b1}};
          rgn_ctrl0_wr_res_nxt_r[((rgn_ctrl0_id+1)*RGN_CTRL0_PER_ROW*RGN_CTRL0_WIDTH)-1 -: RGN_CTRL0_PER_ROW*RGN_CTRL0_WIDTH] = restore_data_int[(RGN_CTRL0_PER_ROW*RGN_CTRL0_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_CTRL0_END) begin
        rgn_ctrl0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CTRL0_LAST_ROW] = {RGN_CTRL0_LAST_ROW{1'b1}};
        rgn_ctrl0_wr_res_nxt_r[(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1 -: RGN_CTRL0_LAST_ROW*RGN_CTRL0_WIDTH] = restore_data_int[(RGN_CTRL0_LAST_ROW*RGN_CTRL0_WIDTH)-1:0];
      end
    end

    assign rgn_ctrl0_en_res_nxt = rgn_ctrl0_en_res_nxt_r;
    assign rgn_ctrl0_wr_res_nxt = rgn_ctrl0_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_CTRL0_BLOCK_SIZE == 1)) begin: RESTORE_RGN_CTRL0_1

    reg [FC_NUM_RGN-1:0]                   rgn_ctrl0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_wr_res_nxt_r;

    always @* begin
      rgn_ctrl0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_ctrl0_wr_res_nxt_r = {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};

      if (restore_cntr == RGN_CTRL0_END) begin
        rgn_ctrl0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CTRL0_LAST_ROW] = {RGN_CTRL0_LAST_ROW{1'b1}};
        rgn_ctrl0_wr_res_nxt_r[(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1 -: RGN_CTRL0_LAST_ROW*RGN_CTRL0_WIDTH] = restore_data_int[(RGN_CTRL0_LAST_ROW*RGN_CTRL0_WIDTH)-1:0];
      end
    end

    assign rgn_ctrl0_en_res_nxt = rgn_ctrl0_en_res_nxt_r;
    assign rgn_ctrl0_wr_res_nxt = rgn_ctrl0_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_CTRL0
    assign rgn_ctrl0_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_ctrl0_wr_res_nxt  = {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_CTRL1_BLOCK_SIZE > 1)) begin: RESTORE_RGN_CTRL1

    reg [FC_NUM_RGN-1:0]                   rgn_ctrl1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_wr_res_nxt_r;
    integer rgn_ctrl1_id;

    always @* begin
      rgn_ctrl1_en_res_nxt_r  = {FC_NUM_RGN{1'b0}};
      rgn_ctrl1_wr_res_nxt_r  = {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};

      for (rgn_ctrl1_id=0; rgn_ctrl1_id<RGN_CTRL1_BLOCK_SIZE-1; rgn_ctrl1_id=rgn_ctrl1_id+1) begin
        if (rgn_ctrl1_id == (restore_cntr-RGN_CTRL1_START)) begin
          rgn_ctrl1_en_res_nxt_r[((rgn_ctrl1_id+1)*RGN_CTRL1_PER_ROW)-1 -: RGN_CTRL1_PER_ROW] = {RGN_CTRL1_PER_ROW{1'b1}};
          rgn_ctrl1_wr_res_nxt_r[((rgn_ctrl1_id+1)*RGN_CTRL1_PER_ROW*RGN_CTRL1_WIDTH)-1 -: RGN_CTRL1_PER_ROW*RGN_CTRL1_WIDTH] = restore_data_int[(RGN_CTRL1_PER_ROW*RGN_CTRL1_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_CTRL1_END) begin
        rgn_ctrl1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CTRL1_LAST_ROW] = {RGN_CTRL1_LAST_ROW{1'b1}};
        rgn_ctrl1_wr_res_nxt_r[(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1 -: RGN_CTRL1_LAST_ROW*RGN_CTRL1_WIDTH] = restore_data_int[(RGN_CTRL1_LAST_ROW*RGN_CTRL1_WIDTH)-1:0];
      end
    end

    assign rgn_ctrl1_en_res_nxt = rgn_ctrl1_en_res_nxt_r;
    assign rgn_ctrl1_wr_res_nxt = rgn_ctrl1_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_CTRL1_BLOCK_SIZE == 1)) begin: RESTORE_RGN_CTRL1_1

    reg [FC_NUM_RGN-1:0]                   rgn_ctrl1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_wr_res_nxt_r;

    always @* begin
      rgn_ctrl1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_ctrl1_wr_res_nxt_r = {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};

      if (restore_cntr == RGN_CTRL1_END) begin
        rgn_ctrl1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CTRL1_LAST_ROW] = {RGN_CTRL1_LAST_ROW{1'b1}};
        rgn_ctrl1_wr_res_nxt_r[(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1 -: RGN_CTRL1_LAST_ROW*RGN_CTRL1_WIDTH] = restore_data_int[(RGN_CTRL1_LAST_ROW*RGN_CTRL1_WIDTH)-1:0];
      end
    end

    assign rgn_ctrl1_en_res_nxt = rgn_ctrl1_en_res_nxt_r;
    assign rgn_ctrl1_wr_res_nxt = rgn_ctrl1_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_CTRL1
    assign rgn_ctrl1_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_ctrl1_wr_res_nxt  = {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_LCTRL_BLOCK_SIZE > 1)) begin: RESTORE_RGN_LCTRL

    reg [FC_NUM_RGN-1:0]                   rgn_lctrl_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_wr_res_nxt_r;
    integer rgn_lctrl_id;

    always @* begin
      rgn_lctrl_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_lctrl_wr_res_nxt_r = {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};

      for (rgn_lctrl_id=0; rgn_lctrl_id<RGN_LCTRL_BLOCK_SIZE-1; rgn_lctrl_id=rgn_lctrl_id+1) begin
        if (rgn_lctrl_id == (restore_cntr-RGN_LCTRL_START)) begin
          rgn_lctrl_en_res_nxt_r[((rgn_lctrl_id+1)*RGN_LCTRL_PER_ROW)-1 -: RGN_LCTRL_PER_ROW] = {RGN_LCTRL_PER_ROW{1'b1}};
          rgn_lctrl_wr_res_nxt_r[((rgn_lctrl_id+1)*RGN_LCTRL_PER_ROW*RGN_LCTRL_WIDTH)-1 -: RGN_LCTRL_PER_ROW*RGN_LCTRL_WIDTH] = restore_data_int[(RGN_LCTRL_PER_ROW*RGN_LCTRL_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_LCTRL_END) begin
        rgn_lctrl_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_LCTRL_LAST_ROW] = {RGN_LCTRL_LAST_ROW{1'b1}};
        rgn_lctrl_wr_res_nxt_r[(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1 -: RGN_LCTRL_LAST_ROW*RGN_LCTRL_WIDTH] = restore_data_int[(RGN_LCTRL_LAST_ROW*RGN_LCTRL_WIDTH)-1:0];
      end
    end

    assign rgn_lctrl_en_res_nxt = rgn_lctrl_en_res_nxt_r;
    assign rgn_lctrl_wr_res_nxt = rgn_lctrl_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_LCTRL_BLOCK_SIZE == 1)) begin: RESTORE_RGN_LCTRL_1

    reg [FC_NUM_RGN-1:0]                   rgn_lctrl_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_wr_res_nxt_r;

    always @* begin
      rgn_lctrl_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_lctrl_wr_res_nxt_r = {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};

      if (restore_cntr == RGN_LCTRL_END) begin
        rgn_lctrl_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_LCTRL_LAST_ROW] = {RGN_LCTRL_LAST_ROW{1'b1}};
        rgn_lctrl_wr_res_nxt_r[(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1 -: RGN_LCTRL_LAST_ROW*RGN_LCTRL_WIDTH] = restore_data_int[(RGN_LCTRL_LAST_ROW*RGN_LCTRL_WIDTH)-1:0];
      end
    end

    assign rgn_lctrl_en_res_nxt = rgn_lctrl_en_res_nxt_r;
    assign rgn_lctrl_wr_res_nxt = rgn_lctrl_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_LCTRL
    assign rgn_lctrl_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_lctrl_wr_res_nxt = {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MPL0_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MPL0

    reg [FC_NUM_RGN-1:0]                  rgn_mpl0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0] rgn_mpl0_wr_res_nxt_r;
    integer rgn_mpl0_id;

    always @* begin
      rgn_mpl0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl0_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};

      for (rgn_mpl0_id=0; rgn_mpl0_id<RGN_MPL0_BLOCK_SIZE-1; rgn_mpl0_id=rgn_mpl0_id+1) begin
        if (rgn_mpl0_id == (restore_cntr-RGN_MPL0_START)) begin
          rgn_mpl0_en_res_nxt_r[((rgn_mpl0_id+1)*RGN_MPL0_PER_ROW)-1 -: RGN_MPL0_PER_ROW] = {RGN_MPL0_PER_ROW{1'b1}};
          rgn_mpl0_wr_res_nxt_r[((rgn_mpl0_id+1)*RGN_MPL0_PER_ROW*RGN_MPL0_WIDTH)-1 -: RGN_MPL0_PER_ROW*RGN_MPL0_WIDTH] = restore_data_int[(RGN_MPL0_PER_ROW*RGN_MPL0_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_MPL0_END) begin
        rgn_mpl0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL0_LAST_ROW] = {RGN_MPL0_LAST_ROW{1'b1}};
        rgn_mpl0_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL0_WIDTH)-1 -: RGN_MPL0_LAST_ROW*RGN_MPL0_WIDTH] = restore_data_int[(RGN_MPL0_LAST_ROW*RGN_MPL0_WIDTH)-1:0];
      end
    end

    assign rgn_mpl0_en_res_nxt = rgn_mpl0_en_res_nxt_r;
    assign rgn_mpl0_wr_res_nxt = rgn_mpl0_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MPL0_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MPL0_1

    reg [FC_NUM_RGN-1:0]                  rgn_mpl0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0] rgn_mpl0_wr_res_nxt_r;

    always @* begin
      rgn_mpl0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl0_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};

      if (restore_cntr == RGN_MPL0_END) begin
        rgn_mpl0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL0_LAST_ROW] = {RGN_MPL0_LAST_ROW{1'b1}};
        rgn_mpl0_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL0_WIDTH)-1 -: RGN_MPL0_LAST_ROW*RGN_MPL0_WIDTH] = restore_data_int[(RGN_MPL0_LAST_ROW*RGN_MPL0_WIDTH)-1:0];
      end
    end

    assign rgn_mpl0_en_res_nxt = rgn_mpl0_en_res_nxt_r;
    assign rgn_mpl0_wr_res_nxt = rgn_mpl0_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MPL0
    assign rgn_mpl0_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_mpl0_wr_res_nxt = {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MPL1_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MPL1

    reg [FC_NUM_RGN-1:0]                  rgn_mpl1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0] rgn_mpl1_wr_res_nxt_r;
    integer rgn_mpl1_id;

    always @* begin
      rgn_mpl1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl1_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};

      for (rgn_mpl1_id=0; rgn_mpl1_id<RGN_MPL1_BLOCK_SIZE-1; rgn_mpl1_id=rgn_mpl1_id+1) begin
        if (rgn_mpl1_id == (restore_cntr-RGN_MPL1_START)) begin
          rgn_mpl1_en_res_nxt_r[((rgn_mpl1_id+1)*RGN_MPL1_PER_ROW)-1 -: RGN_MPL1_PER_ROW] = {RGN_MPL1_PER_ROW{1'b1}};
          rgn_mpl1_wr_res_nxt_r[((rgn_mpl1_id+1)*RGN_MPL1_PER_ROW*RGN_MPL1_WIDTH)-1 -: RGN_MPL1_PER_ROW*RGN_MPL1_WIDTH] = restore_data_int[(RGN_MPL1_PER_ROW*RGN_MPL1_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_MPL1_END) begin
        rgn_mpl1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL1_LAST_ROW] = {RGN_MPL1_LAST_ROW{1'b1}};
        rgn_mpl1_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL1_WIDTH)-1 -: RGN_MPL1_LAST_ROW*RGN_MPL1_WIDTH] = restore_data_int[(RGN_MPL1_LAST_ROW*RGN_MPL1_WIDTH)-1:0];
      end
    end

    assign rgn_mpl1_en_res_nxt = rgn_mpl1_en_res_nxt_r;
    assign rgn_mpl1_wr_res_nxt = rgn_mpl1_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MPL1_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MPL1_1

    reg [FC_NUM_RGN-1:0]                  rgn_mpl1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0] rgn_mpl1_wr_res_nxt_r;

    always @* begin
      rgn_mpl1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl1_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};

      if (restore_cntr == RGN_MPL1_END) begin
        rgn_mpl1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL1_LAST_ROW] = {RGN_MPL1_LAST_ROW{1'b1}};
        rgn_mpl1_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL1_WIDTH)-1 -: RGN_MPL1_LAST_ROW*RGN_MPL1_WIDTH] = restore_data_int[(RGN_MPL1_LAST_ROW*RGN_MPL1_WIDTH)-1:0];
      end
    end

    assign rgn_mpl1_en_res_nxt = rgn_mpl1_en_res_nxt_r;
    assign rgn_mpl1_wr_res_nxt = rgn_mpl1_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MPL1
    assign rgn_mpl1_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_mpl1_wr_res_nxt  = {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MPL2_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MPL2
    reg [FC_NUM_RGN-1:0]                  rgn_mpl2_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0] rgn_mpl2_wr_res_nxt_r;
    integer rgn_mpl2_id;

    always @* begin
      rgn_mpl2_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl2_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};

      for (rgn_mpl2_id=0; rgn_mpl2_id<RGN_MPL2_BLOCK_SIZE-1; rgn_mpl2_id=rgn_mpl2_id+1) begin
        if (rgn_mpl2_id == (restore_cntr-RGN_MPL2_START)) begin
          rgn_mpl2_en_res_nxt_r[((rgn_mpl2_id+1)*RGN_MPL2_PER_ROW)-1 -: RGN_MPL2_PER_ROW] = {RGN_MPL2_PER_ROW{1'b1}};
          rgn_mpl2_wr_res_nxt_r[((rgn_mpl2_id+1)*RGN_MPL2_PER_ROW*RGN_MPL2_WIDTH)-1 -: RGN_MPL2_PER_ROW*RGN_MPL2_WIDTH] = restore_data_int[(RGN_MPL2_PER_ROW*RGN_MPL2_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_MPL2_END) begin
        rgn_mpl2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL2_LAST_ROW] = {RGN_MPL2_LAST_ROW{1'b1}};
        rgn_mpl2_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL2_WIDTH)-1 -: RGN_MPL2_LAST_ROW*RGN_MPL2_WIDTH] = restore_data_int[(RGN_MPL2_LAST_ROW*RGN_MPL2_WIDTH)-1:0];
      end
    end

    assign rgn_mpl2_en_res_nxt = rgn_mpl2_en_res_nxt_r;
    assign rgn_mpl2_wr_res_nxt = rgn_mpl2_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MPL2_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MPL2_1
    reg [FC_NUM_RGN-1:0]                  rgn_mpl2_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0] rgn_mpl2_wr_res_nxt_r;

    always @* begin
      rgn_mpl2_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl2_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};

      if (restore_cntr == RGN_MPL2_END) begin
        rgn_mpl2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL2_LAST_ROW] = {RGN_MPL2_LAST_ROW{1'b1}};
        rgn_mpl2_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL2_WIDTH)-1 -: RGN_MPL2_LAST_ROW*RGN_MPL2_WIDTH] = restore_data_int[(RGN_MPL2_LAST_ROW*RGN_MPL2_WIDTH)-1:0];
      end
    end

    assign rgn_mpl2_en_res_nxt = rgn_mpl2_en_res_nxt_r;
    assign rgn_mpl2_wr_res_nxt = rgn_mpl2_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MPL2
    assign rgn_mpl2_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_mpl2_wr_res_nxt = {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MPL3_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MPL3
    reg [FC_NUM_RGN-1:0]                  rgn_mpl3_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0] rgn_mpl3_wr_res_nxt_r;
    integer rgn_mpl3_id;

    always @* begin
      rgn_mpl3_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl3_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};

      for (rgn_mpl3_id=0; rgn_mpl3_id<RGN_MPL3_BLOCK_SIZE-1; rgn_mpl3_id=rgn_mpl3_id+1) begin
        if (rgn_mpl3_id == (restore_cntr-RGN_MPL3_START)) begin
          rgn_mpl3_en_res_nxt_r[((rgn_mpl3_id+1)*RGN_MPL3_PER_ROW)-1 -: RGN_MPL3_PER_ROW] = {RGN_MPL3_PER_ROW{1'b1}};
          rgn_mpl3_wr_res_nxt_r[((rgn_mpl3_id+1)*RGN_MPL3_PER_ROW*RGN_MPL3_WIDTH)-1 -: RGN_MPL3_PER_ROW*RGN_MPL3_WIDTH] = restore_data_int[(RGN_MPL3_PER_ROW*RGN_MPL3_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_MPL3_END) begin
        rgn_mpl3_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL3_LAST_ROW] = {RGN_MPL3_LAST_ROW{1'b1}};
        rgn_mpl3_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL3_WIDTH)-1 -: RGN_MPL3_LAST_ROW*RGN_MPL3_WIDTH] = restore_data_int[(RGN_MPL3_LAST_ROW*RGN_MPL3_WIDTH)-1:0];
      end
    end

    assign rgn_mpl3_en_res_nxt = rgn_mpl3_en_res_nxt_r;
    assign rgn_mpl3_wr_res_nxt = rgn_mpl3_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MPL3_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MPL3_1
    reg [FC_NUM_RGN-1:0]                  rgn_mpl3_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0] rgn_mpl3_wr_res_nxt_r;

    always @* begin
      rgn_mpl3_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mpl3_wr_res_nxt_r = {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};

      if (restore_cntr == RGN_MPL3_END) begin
        rgn_mpl3_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MPL3_LAST_ROW] = {RGN_MPL3_LAST_ROW{1'b1}};
        rgn_mpl3_wr_res_nxt_r[(FC_NUM_RGN*RGN_MPL3_WIDTH)-1 -: RGN_MPL3_LAST_ROW*RGN_MPL3_WIDTH] = restore_data_int[(RGN_MPL3_LAST_ROW*RGN_MPL3_WIDTH)-1:0];
      end
    end

    assign rgn_mpl3_en_res_nxt = rgn_mpl3_en_res_nxt_r;
    assign rgn_mpl3_wr_res_nxt = rgn_mpl3_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MPL3
    assign rgn_mpl3_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_mpl3_wr_res_nxt  = {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MID0_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MID0
    reg [FC_NUM_RGN-1:0]                   rgn_mid0_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_wr_res_nxt_r;
    integer rgn_mid0_id;

    genvar j;
    wire [(RGN_MID0_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid0_data;
    for (j=0; j<RGN_MID0_PER_ROW; j=j+1) begin : FIT_MID0_RESTORE_DATA
      assign restore_mid0_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid0_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      for (rgn_mid0_id=0; rgn_mid0_id<RGN_MID0_BLOCK_SIZE-1; rgn_mid0_id=rgn_mid0_id+1) begin
        if (rgn_mid0_id == (restore_cntr-RGN_MID0_START)) begin
          rgn_mid0_en_res_nxt_r[((rgn_mid0_id+1)*RGN_MID0_PER_ROW)-1 -: RGN_MID0_PER_ROW] = {RGN_MID0_PER_ROW{1'b1}};
          rgn_mid0_wr_res_nxt_r[((rgn_mid0_id+1)*RGN_MID0_PER_ROW*FC_MST_ID_WIDTH)-1 -: RGN_MID0_PER_ROW*FC_MST_ID_WIDTH] = restore_mid0_data;
        end
      end
      if (restore_cntr == RGN_MID0_END) begin
        rgn_mid0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID0_LAST_ROW] = {RGN_MID0_LAST_ROW{1'b1}};
        rgn_mid0_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID0_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid0_data[(RGN_MID0_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid0_en_res_nxt = rgn_mid0_en_res_nxt_r;
    assign rgn_mid0_wr_res_nxt = rgn_mid0_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MID0_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MID0_1
    reg [FC_NUM_RGN-1:0]                   rgn_mid0_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_wr_res_nxt_r;

    genvar j;
    wire [(RGN_MID0_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid0_data;
    for (j=0; j<RGN_MID0_PER_ROW; j=j+1) begin : FIT_MID0_RESTORE_DATA
      assign restore_mid0_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid0_en_res_nxt_r  = {FC_NUM_RGN{1'b0}};
      rgn_mid0_wr_res_nxt_r  = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      if (restore_cntr == RGN_MID0_END) begin
        rgn_mid0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID0_LAST_ROW] = {RGN_MID0_LAST_ROW{1'b1}};
        rgn_mid0_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID0_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid0_data[(RGN_MID0_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid0_en_res_nxt = rgn_mid0_en_res_nxt_r;
    assign rgn_mid0_wr_res_nxt = rgn_mid0_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MID0
    assign rgn_mid0_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_mid0_wr_res_nxt  = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MID1_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MID1
    reg [FC_NUM_RGN-1:0]                   rgn_mid1_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_wr_res_nxt_r;
    integer rgn_mid1_id;

    genvar j;
    wire [(RGN_MID1_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid1_data;
    for (j=0; j<RGN_MID1_PER_ROW; j=j+1) begin : FIT_MID1_RESTORE_DATA
      assign restore_mid1_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid1_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      for (rgn_mid1_id=0; rgn_mid1_id<RGN_MID1_BLOCK_SIZE-1; rgn_mid1_id=rgn_mid1_id+1) begin
        if (rgn_mid1_id == (restore_cntr-RGN_MID1_START)) begin
          rgn_mid1_en_res_nxt_r[((rgn_mid1_id+1)*RGN_MID1_PER_ROW)-1 -: RGN_MID1_PER_ROW] = {RGN_MID1_PER_ROW{1'b1}};
          rgn_mid1_wr_res_nxt_r[((rgn_mid1_id+1)*RGN_MID1_PER_ROW*FC_MST_ID_WIDTH)-1 -: RGN_MID1_PER_ROW*FC_MST_ID_WIDTH] = restore_mid1_data;
        end
      end
      if (restore_cntr == RGN_MID1_END) begin
        rgn_mid1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID1_LAST_ROW] = {RGN_MID1_LAST_ROW{1'b1}};
        rgn_mid1_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID1_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid1_data[(RGN_MID1_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid1_en_res_nxt = rgn_mid1_en_res_nxt_r;
    assign rgn_mid1_wr_res_nxt = rgn_mid1_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MID1_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MID1_1
    reg [FC_NUM_RGN-1:0]                   rgn_mid1_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_wr_res_nxt_r;

    genvar j;
    wire [(RGN_MID1_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid1_data;
    for (j=0; j<RGN_MID1_PER_ROW; j=j+1) begin : FIT_MID1_RESTORE_DATA
      assign restore_mid1_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid1_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      if (restore_cntr == RGN_MID1_END) begin
        rgn_mid1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID1_LAST_ROW] = {RGN_MID1_LAST_ROW{1'b1}};
        rgn_mid1_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID1_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid1_data[(RGN_MID1_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid1_en_res_nxt = rgn_mid1_en_res_nxt_r;
    assign rgn_mid1_wr_res_nxt = rgn_mid1_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MID1
    assign rgn_mid1_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_mid1_wr_res_nxt = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MID2_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MID2
    reg [FC_NUM_RGN-1:0]                   rgn_mid2_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_wr_res_nxt_r;
    integer rgn_mid2_id;

    genvar j;
    wire [(RGN_MID2_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid2_data;
    for (j=0; j<RGN_MID2_PER_ROW; j=j+1) begin : FIT_MID2_RESTORE_DATA
      assign restore_mid2_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid2_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid2_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      for (rgn_mid2_id=0; rgn_mid2_id<RGN_MID2_BLOCK_SIZE-1; rgn_mid2_id=rgn_mid2_id+1) begin
        if (rgn_mid2_id == (restore_cntr-RGN_MID2_START)) begin
          rgn_mid2_en_res_nxt_r[((rgn_mid2_id+1)*RGN_MID2_PER_ROW)-1 -: RGN_MID2_PER_ROW] = {RGN_MID2_PER_ROW{1'b1}};
          rgn_mid2_wr_res_nxt_r[((rgn_mid2_id+1)*RGN_MID2_PER_ROW*FC_MST_ID_WIDTH)-1 -: RGN_MID2_PER_ROW*FC_MST_ID_WIDTH] = restore_mid2_data;
        end
      end
      if (restore_cntr == RGN_MID2_END) begin
        rgn_mid2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID2_LAST_ROW] = {RGN_MID2_LAST_ROW{1'b1}};
        rgn_mid2_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID2_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid2_data[(RGN_MID2_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid2_en_res_nxt = rgn_mid2_en_res_nxt_r;
    assign rgn_mid2_wr_res_nxt = rgn_mid2_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MID2_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MID2_1
    reg [FC_NUM_RGN-1:0]                   rgn_mid2_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_wr_res_nxt_r;

    genvar j;
    wire [(RGN_MID2_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid2_data;
    for (j=0; j<RGN_MID2_PER_ROW; j=j+1) begin : FIT_MID2_RESTORE_DATA
      assign restore_mid2_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid2_en_res_nxt_r  = {FC_NUM_RGN{1'b0}};
      rgn_mid2_wr_res_nxt_r  = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      if (restore_cntr == RGN_MID2_END) begin
        rgn_mid2_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID2_LAST_ROW] = {RGN_MID2_LAST_ROW{1'b1}};
        rgn_mid2_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID2_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid2_data[(RGN_MID2_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid2_en_res_nxt = rgn_mid2_en_res_nxt_r;
    assign rgn_mid2_wr_res_nxt = rgn_mid2_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MID2
    assign rgn_mid2_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_mid2_wr_res_nxt = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_MID3_BLOCK_SIZE > 1)) begin: RESTORE_RGN_MID3
    reg [FC_NUM_RGN-1:0]                   rgn_mid3_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_wr_res_nxt_r;
    integer rgn_mid3_id;

    genvar j;
    wire [(RGN_MID3_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid3_data;
    for (j=0; j<RGN_MID3_PER_ROW; j=j+1) begin : FIT_MID3_RESTORE_DATA
      assign restore_mid3_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid3_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid3_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      for (rgn_mid3_id=0; rgn_mid3_id<RGN_MID3_BLOCK_SIZE-1; rgn_mid3_id=rgn_mid3_id+1) begin
        if (rgn_mid3_id == (restore_cntr-RGN_MID3_START)) begin
          rgn_mid3_en_res_nxt_r[((rgn_mid3_id+1)*RGN_MID3_PER_ROW)-1 -: RGN_MID3_PER_ROW] = {RGN_MID3_PER_ROW{1'b1}};
          rgn_mid3_wr_res_nxt_r[((rgn_mid3_id+1)*RGN_MID3_PER_ROW*FC_MST_ID_WIDTH)-1 -: RGN_MID3_PER_ROW*FC_MST_ID_WIDTH] = restore_mid3_data;
        end
      end
      if (restore_cntr == RGN_MID3_END) begin
        rgn_mid3_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID3_LAST_ROW] = {RGN_MID3_LAST_ROW{1'b1}};
        rgn_mid3_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID3_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid3_data[(RGN_MID3_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid3_en_res_nxt = rgn_mid3_en_res_nxt_r;
    assign rgn_mid3_wr_res_nxt = rgn_mid3_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_MID3_BLOCK_SIZE == 1)) begin: RESTORE_RGN_MID3_1

    reg [FC_NUM_RGN-1:0]                   rgn_mid3_en_res_nxt_r;
    reg [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_wr_res_nxt_r;

    genvar j;
    wire [(RGN_MID3_PER_ROW*FC_MST_ID_WIDTH)-1:0] restore_mid3_data;
    for (j=0; j<RGN_MID3_PER_ROW; j=j+1) begin : FIT_MID3_RESTORE_DATA
      assign restore_mid3_data[j*FC_MST_ID_WIDTH +: FC_MST_ID_WIDTH] = restore_data_int[j*FW_MAX_MST_ID_WIDTH +: FC_MST_ID_WIDTH];
    end

    always @* begin
      rgn_mid3_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_mid3_wr_res_nxt_r = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};

      if (restore_cntr == RGN_MID3_END) begin
        rgn_mid3_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_MID3_LAST_ROW] = {RGN_MID3_LAST_ROW{1'b1}};
        rgn_mid3_wr_res_nxt_r[(FC_NUM_RGN*FC_MST_ID_WIDTH)-1 -: RGN_MID3_LAST_ROW*FC_MST_ID_WIDTH] = restore_mid3_data[(RGN_MID3_LAST_ROW*FC_MST_ID_WIDTH)-1:0];
      end
    end

    assign rgn_mid3_en_res_nxt = rgn_mid3_en_res_nxt_r;
    assign rgn_mid3_wr_res_nxt = rgn_mid3_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_MID3
    assign rgn_mid3_en_res_nxt = {FC_NUM_RGN{1'b0}};
    assign rgn_mid3_wr_res_nxt = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_TCFG0_BLOCK_SIZE > 1)) begin: RESTORE_RGN_TCFG0

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_wr_res_nxt_r;
    integer rgn_tcfg0_id;

    always @* begin
      rgn_tcfg0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg0_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};

      for (rgn_tcfg0_id=0; rgn_tcfg0_id<RGN_TCFG0_BLOCK_SIZE-1; rgn_tcfg0_id=rgn_tcfg0_id+1) begin
        if (rgn_tcfg0_id == (restore_cntr-RGN_TCFG0_START)) begin
          rgn_tcfg0_en_res_nxt_r[((rgn_tcfg0_id+1)*RGN_TCFG0_PER_ROW)-1 -: RGN_TCFG0_PER_ROW] = {RGN_TCFG0_PER_ROW{1'b1}};
          rgn_tcfg0_wr_res_nxt_r[((rgn_tcfg0_id+1)*RGN_TCFG0_PER_ROW*RGN_TCFG0_WIDTH)-1 -: RGN_TCFG0_PER_ROW*RGN_TCFG0_WIDTH] = restore_data_int[(RGN_TCFG0_PER_ROW*RGN_TCFG0_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_TCFG0_END) begin
        rgn_tcfg0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG0_LAST_ROW] = {RGN_TCFG0_LAST_ROW{1'b1}};
        rgn_tcfg0_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1 -: RGN_TCFG0_LAST_ROW*RGN_TCFG0_WIDTH] = restore_data_int[(RGN_TCFG0_LAST_ROW*RGN_TCFG0_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg0_en_res_nxt = rgn_tcfg0_en_res_nxt_r;
    assign rgn_tcfg0_wr_res_nxt = rgn_tcfg0_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_TCFG0_BLOCK_SIZE == 1)) begin: RESTORE_RGN_TCFG0_1

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_wr_res_nxt_r;

    always @* begin
      rgn_tcfg0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg0_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};

      if (restore_cntr == RGN_TCFG0_END) begin
        rgn_tcfg0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG0_LAST_ROW] = {RGN_TCFG0_LAST_ROW{1'b1}};
        rgn_tcfg0_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1 -: RGN_TCFG0_LAST_ROW*RGN_TCFG0_WIDTH] = restore_data_int[(RGN_TCFG0_LAST_ROW*RGN_TCFG0_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg0_en_res_nxt = rgn_tcfg0_en_res_nxt_r;
    assign rgn_tcfg0_wr_res_nxt = rgn_tcfg0_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_TCFG0
    assign rgn_tcfg0_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_tcfg0_wr_res_nxt  = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_TCFG1_BLOCK_SIZE > 1)) begin: RESTORE_RGN_TCFG1

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_wr_res_nxt_r;
    integer rgn_tcfg1_id;

    always @* begin
      rgn_tcfg1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg1_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};

      for (rgn_tcfg1_id=0; rgn_tcfg1_id<RGN_TCFG1_BLOCK_SIZE-1; rgn_tcfg1_id=rgn_tcfg1_id+1) begin
        if (rgn_tcfg1_id == (restore_cntr-RGN_TCFG1_START)) begin
          rgn_tcfg1_en_res_nxt_r[((rgn_tcfg1_id+1)*RGN_TCFG1_PER_ROW)-1 -: RGN_TCFG1_PER_ROW] = {RGN_TCFG1_PER_ROW{1'b1}};
          rgn_tcfg1_wr_res_nxt_r[((rgn_tcfg1_id+1)*RGN_TCFG1_PER_ROW*RGN_TCFG1_WIDTH)-1 -: RGN_TCFG1_PER_ROW*RGN_TCFG1_WIDTH] = restore_data_int[(RGN_TCFG1_PER_ROW*RGN_TCFG1_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_TCFG1_END) begin
        rgn_tcfg1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG1_LAST_ROW] = {RGN_TCFG1_LAST_ROW{1'b1}};
        rgn_tcfg1_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1 -: RGN_TCFG1_LAST_ROW*RGN_TCFG1_WIDTH] = restore_data_int[(RGN_TCFG1_LAST_ROW*RGN_TCFG1_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg1_en_res_nxt = rgn_tcfg1_en_res_nxt_r;
    assign rgn_tcfg1_wr_res_nxt = rgn_tcfg1_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_TCFG1_BLOCK_SIZE == 1)) begin: RESTORE_RGN_TCFG1_1

    reg [FC_NUM_RGN-1:0]                   rgn_tcfg1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_wr_res_nxt_r;

    always @* begin
      rgn_tcfg1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_tcfg1_wr_res_nxt_r = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};

      if (restore_cntr == RGN_TCFG1_END) begin
        rgn_tcfg1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_TCFG1_LAST_ROW] = {RGN_TCFG1_LAST_ROW{1'b1}};
        rgn_tcfg1_wr_res_nxt_r[(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1 -: RGN_TCFG1_LAST_ROW*RGN_TCFG1_WIDTH] = restore_data_int[(RGN_TCFG1_LAST_ROW*RGN_TCFG1_WIDTH)-1:0];
      end
    end

    assign rgn_tcfg1_en_res_nxt = rgn_tcfg1_en_res_nxt_r;
    assign rgn_tcfg1_wr_res_nxt = rgn_tcfg1_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_TCFG1
    assign rgn_tcfg1_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_tcfg1_wr_res_nxt  = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_CFG0_BLOCK_SIZE > 1)) begin: RESTORE_RGN_CFG0

    reg [FC_NUM_RGN-1:0]                  rgn_cfg0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0] rgn_cfg0_wr_res_nxt_r;
    integer rgn_cfg0_id;

    always @* begin
      rgn_cfg0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_cfg0_wr_res_nxt_r = {FC_NUM_RGN*RGN_CFG0_WIDTH{1'b0}};

      for (rgn_cfg0_id=0; rgn_cfg0_id<RGN_CFG0_BLOCK_SIZE-1; rgn_cfg0_id=rgn_cfg0_id+1) begin
        if (rgn_cfg0_id == (restore_cntr-RGN_CFG0_START)) begin
          rgn_cfg0_en_res_nxt_r[((rgn_cfg0_id+1)*RGN_CFG0_PER_ROW)-1 -: RGN_CFG0_PER_ROW] = {RGN_CFG0_PER_ROW{1'b1}};
          rgn_cfg0_wr_res_nxt_r[((rgn_cfg0_id+1)*RGN_CFG0_PER_ROW*RGN_CFG0_WIDTH)-1 -: RGN_CFG0_PER_ROW*RGN_CFG0_WIDTH] = restore_data_int[(RGN_CFG0_PER_ROW*RGN_CFG0_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_CFG0_END) begin
        rgn_cfg0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CFG0_LAST_ROW] = {RGN_CFG0_LAST_ROW{1'b1}};
        rgn_cfg0_wr_res_nxt_r[(FC_NUM_RGN*RGN_CFG0_WIDTH)-1 -: RGN_CFG0_LAST_ROW*RGN_CFG0_WIDTH] = restore_data_int[(RGN_CFG0_LAST_ROW*RGN_CFG0_WIDTH)-1:0];
      end
    end

    assign rgn_cfg0_en_res_nxt = rgn_cfg0_en_res_nxt_r;
    assign rgn_cfg0_wr_res_nxt = rgn_cfg0_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_CFG0_BLOCK_SIZE == 1)) begin: RESTORE_RGN_CFG0_1

    reg [FC_NUM_RGN-1:0]                  rgn_cfg0_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0] rgn_cfg0_wr_res_nxt_r;

    always @* begin
      rgn_cfg0_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_cfg0_wr_res_nxt_r = {FC_NUM_RGN*RGN_CFG0_WIDTH{1'b0}};

      if (restore_cntr == RGN_CFG0_END) begin
        rgn_cfg0_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CFG0_LAST_ROW] = {RGN_CFG0_LAST_ROW{1'b1}};
        rgn_cfg0_wr_res_nxt_r[(FC_NUM_RGN*RGN_CFG0_WIDTH)-1 -: RGN_CFG0_LAST_ROW*RGN_CFG0_WIDTH] = restore_data_int[(RGN_CFG0_LAST_ROW*RGN_CFG0_WIDTH)-1:0];
      end
    end

    assign rgn_cfg0_en_res_nxt = rgn_cfg0_en_res_nxt_r;
    assign rgn_cfg0_wr_res_nxt = rgn_cfg0_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_CFG0
    assign rgn_cfg0_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_cfg0_wr_res_nxt  = {FC_NUM_RGN*RGN_CFG0_WIDTH{1'b0}};
  end


  if ((FW_SRE_LVL == 1) && (RGN_CFG1_BLOCK_SIZE > 1)) begin: RESTORE_RGN_CFG1

    reg [FC_NUM_RGN-1:0]                  rgn_cfg1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0] rgn_cfg1_wr_res_nxt_r;
    integer rgn_cfg1_id;

    always @* begin
      rgn_cfg1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_cfg1_wr_res_nxt_r = {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};

      for (rgn_cfg1_id=0; rgn_cfg1_id<RGN_CFG1_BLOCK_SIZE-1; rgn_cfg1_id=rgn_cfg1_id+1) begin
        if (rgn_cfg1_id == (restore_cntr-RGN_CFG1_START)) begin
          rgn_cfg1_en_res_nxt_r[((rgn_cfg1_id+1)*RGN_CFG1_PER_ROW)-1 -: RGN_CFG1_PER_ROW] = {RGN_CFG1_PER_ROW{1'b1}};
          rgn_cfg1_wr_res_nxt_r[((rgn_cfg1_id+1)*RGN_CFG1_PER_ROW*RGN_CFG1_WIDTH)-1 -: RGN_CFG1_PER_ROW*RGN_CFG1_WIDTH] = restore_data_int[(RGN_CFG1_PER_ROW*RGN_CFG1_WIDTH)-1:0];
        end
      end
      if (restore_cntr == RGN_CFG1_END) begin
        rgn_cfg1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CFG1_LAST_ROW] = {RGN_CFG1_LAST_ROW{1'b1}};
        rgn_cfg1_wr_res_nxt_r[(FC_NUM_RGN*RGN_CFG1_WIDTH)-1 -: RGN_CFG1_LAST_ROW*RGN_CFG1_WIDTH] = restore_data_int[(RGN_CFG1_LAST_ROW*RGN_CFG1_WIDTH)-1:0];
      end
    end

    assign rgn_cfg1_en_res_nxt = rgn_cfg1_en_res_nxt_r;
    assign rgn_cfg1_wr_res_nxt = rgn_cfg1_wr_res_nxt_r;

  end
  else if ((FW_SRE_LVL == 1) && (RGN_CFG1_BLOCK_SIZE == 1)) begin: RESTORE_RGN_CFG1_1

    reg [FC_NUM_RGN-1:0]                  rgn_cfg1_en_res_nxt_r;
    reg [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0] rgn_cfg1_wr_res_nxt_r;

    always @* begin
      rgn_cfg1_en_res_nxt_r = {FC_NUM_RGN{1'b0}};
      rgn_cfg1_wr_res_nxt_r = {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};

      if (restore_cntr == RGN_CFG1_END) begin
        rgn_cfg1_en_res_nxt_r[FC_NUM_RGN-1 -: RGN_CFG1_LAST_ROW] = {RGN_CFG1_LAST_ROW{1'b1}};
        rgn_cfg1_wr_res_nxt_r[(FC_NUM_RGN*RGN_CFG1_WIDTH)-1 -: RGN_CFG1_LAST_ROW*RGN_CFG1_WIDTH] = restore_data_int[(RGN_CFG1_LAST_ROW*RGN_CFG1_WIDTH)-1:0];
      end
    end

    assign rgn_cfg1_en_res_nxt = rgn_cfg1_en_res_nxt_r;
    assign rgn_cfg1_wr_res_nxt = rgn_cfg1_wr_res_nxt_r;

  end
  else begin: NO_RESTORE_RGN_CFG1
    assign rgn_cfg1_en_res_nxt  = {FC_NUM_RGN{1'b0}};
    assign rgn_cfg1_wr_res_nxt  = {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};
  end

endgenerate


generate
  if (FC_CFG_DATA_W >= 16) begin : CON_SINGLE
    assign prot_size_en_con_nxt = (FC_PE_LVL == 2) ? reg_ctlr_con_accept_i : 1'b0;
    assign prot_size_wr_con_nxt = (FC_PE_LVL == 2) ? restore_data_int[11:4] : {PROT_SIZE_WIDTH{1'b0}};
    assign restore_connect_done = reg_ctlr_con_accept_i;
  end
  else if (FC_PE_LVL < 2) begin : CON_PE01_MULTIPLE

    reg  connect_packet_cntr;
    wire connect_packet_nxt;
    wire connect_packet_en;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        connect_packet_cntr <= 1'b0;
      end
      else begin
        if (connect_packet_en) begin
          connect_packet_cntr <= connect_packet_nxt;
        end
      end
    end

    assign connect_packet_en = reg_ctlr_con_accept_i ||
      (reg_ctlr_restore_i && connect_packet_cntr == 1'b1);
    assign connect_packet_nxt = reg_ctlr_con_accept_i ? 1'b1 : 1'b0;

    assign prot_size_en_con_nxt = 1'b0;
    assign prot_size_wr_con_nxt = {PROT_SIZE_WIDTH{1'b0}};

    assign restore_connect_done = reg_ctlr_restore_i &&
      connect_packet_cntr == 1'b1;

  end
  else begin: CON_PE2_MULTIPLE
    reg  connect_packet_cntr;
    wire connect_packet_nxt;
    wire connect_packet_en;
    reg [3:0] prot_size_4;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        connect_packet_cntr <= 1'b0;
        prot_size_4 <= 3'b0;
      end
      else begin
        if (connect_packet_en) begin
          connect_packet_cntr <= connect_packet_nxt;
        end
        if (reg_ctlr_con_accept_i) begin
          prot_size_4 <= restore_data_int[7:4];
        end
      end
    end

    assign connect_packet_en = reg_ctlr_con_accept_i ||
      (reg_ctlr_restore_i && connect_packet_cntr == 1'b1);
    assign connect_packet_nxt = reg_ctlr_con_accept_i ? 1'b1 : 1'b0;

    assign prot_size_en_con_nxt = reg_ctlr_restore_i &&
      connect_packet_cntr == 1'b1;
    assign prot_size_wr_con_nxt = {restore_data_int[3:0], prot_size_4};

    assign restore_connect_done = reg_ctlr_restore_i &&
      connect_packet_cntr == 1'b1;

  end
endgenerate


generate

  if (FW_LDE_LVL == 1) begin : LDE_1_TAMP
    assign tamper_rgn = 1'b0;

    assign tamper_ld_st =
      (dyn_chk_req_type_nxt == CHECK_FW_LOCK) && dyn_chk_req_nxt &&
      ((ld_ctrl_i[1:0] == 2'b10) || (ld_ctrl_i[1:0] == 2'b11)) &&
      reg_ctlr_wr_data_i[2];

    assign tamper_ld =
      (((dyn_chk_req_type_nxt == CHECK_LDE) && dyn_chk_req_nxt &&
      ((ld_ctrl_i[1:0] == 2'b10) || (ld_ctrl_i[1:0] == 2'b11))) ||
      (((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      (ld_ctrl_i[1:0] == 2'b11)));

    assign tamper = (FW_SRE_LVL == 0) ? tamper_rgn | tamper_ld_st | tamper_ld : 1'b0;
  end
  else if (FW_LDE_LVL == 2) begin : LDE_2_TAMP
    assign tamper_rgn =
      ((((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      rgn_lctrl_rgn_i[0]) ||
      ((dyn_chk_req_type_nxt == CHECK_RWE_LOCK) && dyn_chk_req_nxt &&
      (((ld_ctrl_i[1:0] == 2'b10) && rgn_lctrl_rgn_i[0]) ||
      (ld_ctrl_i[1:0] == 2'b11))));

    assign tamper_ld_st =
      (dyn_chk_req_type_nxt == CHECK_FW_LOCK) && dyn_chk_req_nxt &&
      ((ld_ctrl_i[1:0] == 2'b10) || (ld_ctrl_i[1:0] == 2'b11)) &&
      reg_ctlr_wr_data_i[2];

    assign tamper_ld =
      (((dyn_chk_req_type_nxt == CHECK_LDE) && dyn_chk_req_nxt &&
      ((ld_ctrl_i[1:0] == 2'b10) || (ld_ctrl_i[1:0] == 2'b11))) ||
      (((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      (ld_ctrl_i[1:0] == 2'b11)));

    assign tamper = tamper_rgn | tamper_ld_st | tamper_ld;
  end
  else begin : LDE_0_TAMP
    assign tamper_rgn   = 1'b0;
    assign tamper_ld_st = 1'b0;
    assign tamper_ld    = 1'b0;
    assign tamper       = tamper_rgn | tamper_ld_st | tamper_ld;
  end

endgenerate

wire mpe_en;

assign mpe_en = ((reg_addr_enum == RGN_MID0_ADDR) && rgn_st_rgn_i[1]) ||
  ((reg_addr_enum == RGN_MPL0_ADDR) && rgn_st_rgn_i[1]) ||
  ((reg_addr_enum == RGN_MID1_ADDR) && rgn_st_rgn_i[2]) ||
  ((reg_addr_enum == RGN_MPL1_ADDR) && rgn_st_rgn_i[2]) ||
  ((reg_addr_enum == RGN_MID2_ADDR) && rgn_st_rgn_i[3]) ||
  ((reg_addr_enum == RGN_MPL2_ADDR) && rgn_st_rgn_i[3]) ||
  ((reg_addr_enum == RGN_MID3_ADDR) && rgn_st_rgn_i[4]) ||
  ((reg_addr_enum == RGN_MPL3_ADDR) && rgn_st_rgn_i[4]);

assign write_allowed = ((dyn_chk_req_type_nxt == CHECK_RWE_DATA) && dyn_chk_req_nxt) ?
  !rgn_st_rgn_i[0] : ((dyn_chk_req_type_nxt == CHECK_RWE_MPL) && dyn_chk_req_nxt) ?
  !mpe_en : 1'b1;


always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    restore_done_r <= 1'b0;
  end
  else begin
    restore_done_r <= (restore_connect_done || restore_done);
  end
end

assign reg_ctlr_restore_done_o = restore_done_r;

assign reg_ctlr_msg_valid_o = reg_ctlr_reg_valid_i;

assign reg_ctlr_rw_o = reg_ctlr_reg_rw_i;

assign reg_ctlr_wr_rsp_o = tamper | !write_allowed;

assign reg_ctlr_wr_tamp_o = tamper;

assign reg_ctlr_msg_size_o = msg_size_nxt;

assign reg_ctlr_rd_data_o = rd_data_nxt;

assign reg_en_nxt = write_allowed && !tamper && reg_ctlr_reg_valid_i &&
  reg_ctlr_reg_rw_i;

assign restore_sre_1 = reg_ctlr_restore_i && (FW_SRE_LVL == 1) &&
  !prot_size_en_con_nxt && !reg_ctlr_con_accept_i;


assign pe_ctrl_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? pe_ctrl_en_res_nxt :
  reg_en_nxt && pe_ctrl_en_reg_nxt;
assign pe_ctrl_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? pe_ctrl_wr_res_nxt :
  pe_ctrl_wr_reg_nxt;

assign rwe_ctrl_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rwe_ctrl_en_res_nxt :
  reg_en_nxt && rwe_ctrl_en_reg_nxt;
assign rwe_ctrl_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rwe_ctrl_wr_res_nxt :
  rwe_ctrl_wr_reg_nxt;

assign rgn_ctrl0_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_ctrl0_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_ctrl0_en_reg_nxt;
assign rgn_ctrl0_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_ctrl0_wr_res_nxt :
  rgn_ctrl0_wr_reg_nxt;

assign rgn_ctrl1_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_ctrl1_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_ctrl1_en_reg_nxt;
assign rgn_ctrl1_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_ctrl1_wr_res_nxt :
  rgn_ctrl1_wr_reg_nxt;

assign rgn_lctrl_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_lctrl_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_lctrl_en_reg_nxt;
assign rgn_lctrl_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_lctrl_wr_res_nxt :
  rgn_lctrl_wr_reg_nxt;

assign rgn_cfg0_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_cfg0_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_cfg0_en_reg_nxt;
assign rgn_cfg0_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_cfg0_wr_res_nxt :
  rgn_cfg0_wr_reg_nxt;

assign rgn_cfg1_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_cfg1_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_cfg1_en_reg_nxt;
assign rgn_cfg1_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_cfg1_wr_res_nxt :
  rgn_cfg1_wr_reg_nxt;

assign rgn_size_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_size_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_size_en_reg_nxt;
assign rgn_size_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_size_wr_res_nxt :
  rgn_size_wr_reg_nxt;

assign rgn_tcfg0_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg0_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg0_en_reg_nxt;
assign rgn_tcfg0_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg0_wr_res_nxt :
  rgn_tcfg0_wr_reg_nxt;

assign rgn_tcfg1_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg1_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg1_en_reg_nxt;
assign rgn_tcfg1_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg1_wr_res_nxt :
  rgn_tcfg1_wr_reg_nxt;

assign rgn_tcfg2_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg2_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg2_en_reg_nxt;
assign rgn_tcfg2_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_tcfg2_wr_res_nxt :
  rgn_tcfg2_wr_reg_nxt;

assign rgn_mid0_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid0_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mid0_en_reg_nxt;
assign rgn_mid0_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid0_wr_res_nxt :
  rgn_mid0_wr_reg_nxt;

assign rgn_mid1_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid1_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mid1_en_reg_nxt;
assign rgn_mid1_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid1_wr_res_nxt :
  rgn_mid1_wr_reg_nxt;

assign rgn_mid2_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid2_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mid2_en_reg_nxt;
assign rgn_mid2_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid2_wr_res_nxt :
  rgn_mid2_wr_reg_nxt;

assign rgn_mid3_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid3_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mid3_en_reg_nxt;
assign rgn_mid3_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mid3_wr_res_nxt :
  rgn_mid3_wr_reg_nxt;

assign rgn_mpl0_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl0_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl0_en_reg_nxt;
assign rgn_mpl0_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl0_wr_res_nxt :
  rgn_mpl0_wr_reg_nxt;

assign rgn_mpl1_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl1_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl1_en_reg_nxt;
assign rgn_mpl1_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl1_wr_res_nxt :
  rgn_mpl1_wr_reg_nxt;

assign rgn_mpl2_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl2_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl2_en_reg_nxt;
assign rgn_mpl2_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl2_wr_res_nxt :
  rgn_mpl2_wr_reg_nxt;

assign rgn_mpl3_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl3_en_res_nxt :
  {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl3_en_reg_nxt;
assign rgn_mpl3_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? rgn_mpl3_wr_res_nxt :
  rgn_mpl3_wr_reg_nxt;

assign fe_ctrl_en = reg_en_nxt & fe_ctrl_en_reg_nxt;
assign fe_ctrl_o  = fe_ctrl_wr_reg_nxt;

assign ld_ctrl_en = reg_en_nxt & ld_ctrl_en_reg_nxt;
assign ld_ctrl_o  = ld_ctrl_wr_reg_nxt;

assign me_ctrl_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ? me_ctrl_en_res_nxt :
  reg_en_nxt & me_ctrl_en_reg_nxt;
assign me_ctrl_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ? me_ctrl_wr_res_nxt :
  me_ctrl_wr_reg_nxt;

assign me_st_en = 1'b0;
assign me_st_o  = {ME_ST_WIDTH{1'b0}};

assign edr_tal_en = reg_en_nxt & edr_tal_en_reg_nxt;
assign edr_tal_o  = edr_tal_wr_reg_nxt;

assign edr_tau_en = reg_en_nxt & edr_tau_en_reg_nxt;
assign edr_tau_o  = edr_tau_wr_reg_nxt;

assign edr_tp_en = reg_en_nxt & edr_tp_en_reg_nxt;
assign edr_tp_o  = edr_tp_wr_reg_nxt;

assign edr_mid_en = reg_en_nxt & edr_mid_en_reg_nxt;
assign edr_mid_o  = edr_mid_wr_reg_nxt;

assign edr_ctrl_en = reg_en_nxt & edr_ctrl_en_reg_nxt;
assign edr_ctrl_o  = edr_ctrl_wr_reg_nxt;

assign prot_size_en = (restore_sre_1 && (FW_SRE_LVL == 1)) ?
  prot_size_en_res_nxt : prot_size_en_con_nxt;
assign prot_size_o  = (restore_sre_1 && (FW_SRE_LVL == 1)) ?
  prot_size_wr_res_nxt : prot_size_wr_con_nxt;

assign reg_ctlr_lpi_busy_o = reg_ctlr_restore_i || reg_ctlr_con_accept_i ||
  reg_ctlr_reg_valid_i;

endmodule
