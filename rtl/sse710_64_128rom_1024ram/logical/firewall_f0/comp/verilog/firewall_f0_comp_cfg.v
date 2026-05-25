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

module firewall_f0_comp_cfg #(
    `include "firewall_f0_reg_width_params.vh"
    ,
    parameter FC_CFG_DATA_W            = 32,
    parameter LOG2_FW_NUM_FC           = 4,
    parameter FC_NUM_RGN               = 2,
    parameter LOG2_FC_NUM_RGN          = 1,
    parameter REG_ADDR_WIDTH           = 10,
    parameter REG_DATA_WIDTH           = 32,
    parameter FW_SRE_LVL               = 1,
    parameter READ_DATA_SIZE           = 7,
    parameter IRQ_TYPE_WIDTH           = 5,
    parameter MSG_TYPE_WIDTH           = 3,
    parameter MSG_NOFRMT_SIZE          = 32,
    parameter MSG_TYPE_READ            = 3'b000,
    parameter MSG_TYPE_WRITE           = 3'b001,
    parameter MSG_TYPE_CONNECT         = 3'b010,
    parameter MSG_TYPE_DISCONNECT      = 3'b011,
    parameter MSG_TYPE_IRQ             = 3'b100,
    parameter NUM_FLT                  = 1,
    parameter NUM_EDR                  = 1,
    parameter FC_ME_LVL                = 1,
    parameter MSG_SIZE                 = 35,
    parameter READ_MSG_HDR_SIZE        = 3,
    parameter CFG_READ_RSP_T           = 1'b1,
    parameter CFG_WRITE_RSP_T          = 1'b0,
    parameter CFG_RSP_T                = 2'b10,
    parameter HNDSHK_REQ_T             = 2'b00,
    parameter IRQ_REQ_T                = 2'b01,
    parameter FC_ID                    = 1,
    parameter FC_PE_LVL                = 2,
    parameter FW_LDE_LVL               = 2,
    parameter FC_MXRS                  = 25,
    parameter FC_RSE_LVL               = 1,
    parameter FC_TE_LVL                = 2,
    parameter FC_NUM_MPE               = 2,
    parameter FC_SINGLE_MST            = 1,
    parameter FC_INST_SPT              = 1,
    parameter FC_MA_SPT                = 1,
    parameter FC_SEC_SPT               = 1,
    parameter FC_PRIV_SPT              = 1,
    parameter FC_SH_SPT                = 1,
    parameter SRAM_WIDTH               = 32,
    parameter MAX_NUM_OF_PKTS          = 2,
    parameter MSG_SIZE_WIDTH           = 1,
    parameter FC_BAS_REG_SLC           = 1,
    parameter FW_MAX_MST_ID_WIDTH      = 8,
    parameter FC_MST_ID_WIDTH          = 8
) (
    input  wire                                    clk,
    input  wire                                    reset_n,

    input  wire                                    cfg_tvalid_us_i,
    output wire                                    cfg_tready_us_o,
    input  wire [FC_CFG_DATA_W-1:0]                cfg_tdata_us_i,
    input  wire [(FC_CFG_DATA_W/8)-1:0]            cfg_tkeep_us_i,
    input  wire                                    cfg_tlast_us_i,
    input  wire [LOG2_FW_NUM_FC-1:0]               cfg_tdest_us_i,
    input  wire                                    cfg_twakeup_us_i,
    output wire                                    cfg_tvalid_ds_o,
    input  wire                                    cfg_tready_ds_i,
    output wire [FC_CFG_DATA_W-1:0]                cfg_tdata_ds_o,
    output wire [(FC_CFG_DATA_W/8)-1:0]            cfg_tkeep_ds_o,
    output wire                                    cfg_tlast_ds_o,
    output wire [LOG2_FW_NUM_FC-1:0]               cfg_tid_ds_o,
    output wire                                    cfg_twakeup_ds_o,

    input  wire [1:0]                              cfg_lpi_con_req_i,
    input  wire                                    cfg_lpi_discon_req_i,
    input  wire                                    cfg_lpi_clk_hold_i,
    output wire                                    cfg_lpi_pwr_accept_o,
    output wire                                    cfg_lpi_busy_o,

    output wire                                    cfg_gate_bas_o,

    input  wire [IRQ_TYPE_WIDTH-1:0]               cfg_irq_req_i,
    input  wire                                    cfg_irq_valid_i,

    input  wire [PE_CTRL_WIDTH-1:0]                cfg_pe_ctrl_i,
    output wire                                    cfg_pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                cfg_pe_ctrl_o,

    input  wire [PE_ST_WIDTH-1:0]                  cfg_pe_st_i,

    input  wire [RWE_CTRL_WIDTH-1:0]               cfg_rwe_ctrl_i,
    output wire                                    cfg_rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]               cfg_rwe_ctrl_o,

    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_ctrl0_en,
    output wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] cfg_rgn_ctrl0_o,
    input  wire [RGN_CTRL0_WIDTH-1:0]              cfg_rgn_ctrl0_rgn_i,

    input  wire [RGN_CTRL1_WIDTH-1:0]              cfg_rgn_ctrl1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_ctrl1_en,
    output wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] cfg_rgn_ctrl1_o,

    input  wire [RGN_LCTRL_WIDTH-1:0]              cfg_rgn_lctrl_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_lctrl_en,
    output wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] cfg_rgn_lctrl_o,

    input  wire [RGN_ST_WIDTH-1:0]                 cfg_rgn_st_rgn_i,

    input  wire [RGN_CFG0_WIDTH-1:0]               cfg_rgn_cfg0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_cfg0_en,
    output wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]  cfg_rgn_cfg0_o,

    input  wire [RGN_CFG1_WIDTH-1:0]               cfg_rgn_cfg1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_cfg1_en,
    output wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]  cfg_rgn_cfg1_o,

    input  wire [RGN_SIZE_WIDTH-1:0]               cfg_rgn_size_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_size_en,
    output wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  cfg_rgn_size_o,

    input  wire [RGN_TCFG0_WIDTH-1:0]              cfg_rgn_tcfg0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg0_en,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] cfg_rgn_tcfg0_o,

    input  wire [RGN_TCFG1_WIDTH-1:0]              cfg_rgn_tcfg1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg1_en,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] cfg_rgn_tcfg1_o,

    input  wire [RGN_TCFG2_WIDTH-1:0]              cfg_rgn_tcfg2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_tcfg2_en,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] cfg_rgn_tcfg2_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid0_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid0_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid1_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid1_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid2_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid2_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_rgn_mid3_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mid3_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] cfg_rgn_mid3_o,

    input  wire [RGN_MPL0_WIDTH-1:0]               cfg_rgn_mpl0_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl0_en,
    output wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  cfg_rgn_mpl0_o,

    input  wire [RGN_MPL1_WIDTH-1:0]               cfg_rgn_mpl1_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl1_en,
    output wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  cfg_rgn_mpl1_o,

    input  wire [RGN_MPL2_WIDTH-1:0]               cfg_rgn_mpl2_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl2_en,
    output wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  cfg_rgn_mpl2_o,

    input  wire [RGN_MPL3_WIDTH-1:0]               cfg_rgn_mpl3_rgn_i,
    output wire [FC_NUM_RGN-1:0]                   cfg_rgn_mpl3_en,
    output wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  cfg_rgn_mpl3_o,

    input  wire [FE_TAL_WIDTH-1:0]                 cfg_fe_tal_i,

    input  wire [FE_TAU_WIDTH-1:0]                 cfg_fe_tau_i,

    input  wire [FE_TP_WIDTH-1:0]                  cfg_fe_tp_i,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_fe_mid_i,

    input  wire [FE_CTRL_WIDTH-1:0]                cfg_fe_ctrl_i,
    output wire                                    cfg_fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                cfg_fe_ctrl_o,

    input  wire [ME_CTRL_WIDTH-1:0]                cfg_me_ctrl_i,
    output wire                                    cfg_me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                cfg_me_ctrl_o,

    input  wire [ME_ST_WIDTH-1:0]                  cfg_me_st_i,
    output wire                                    cfg_me_st_en,
    output wire [ME_ST_WIDTH-1:0]                  cfg_me_st_o,

    input  wire [EDR_TAL_WIDTH-1:0]                cfg_edr_tal_i,
    output wire                                    cfg_edr_tal_en,
    output wire [EDR_TAL_WIDTH-1:0]                cfg_edr_tal_o,

    input  wire [EDR_TAU_WIDTH-1:0]                cfg_edr_tau_i,
    output wire                                    cfg_edr_tau_en,
    output wire [EDR_TAU_WIDTH-1:0]                cfg_edr_tau_o,

    input  wire [EDR_TP_WIDTH-1:0]                 cfg_edr_tp_i,
    output wire                                    cfg_edr_tp_en,
    output wire [EDR_TP_WIDTH-1:0]                 cfg_edr_tp_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              cfg_edr_mid_i,
    output wire                                    cfg_edr_mid_en,
    output wire [FC_MST_ID_WIDTH-1:0]              cfg_edr_mid_o,

    input  wire [EDR_CTRL_WIDTH-1:0]               cfg_edr_ctrl_i,
    output wire                                    cfg_edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]               cfg_edr_ctrl_o,

    input  wire [LD_CTRL_WIDTH-1:0]                cfg_ld_ctrl_i,
    output wire                                    cfg_ld_ctrl_en,
    output wire [LD_CTRL_WIDTH-1:0]                cfg_ld_ctrl_o,

    output wire                                    cfg_prot_size_en,
    output wire [PROT_SIZE_WIDTH-1:0]              cfg_prot_size_o,

    input  wire [PE_BPS_WIDTH-1:0]                 cfg_bypass_i

);


`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"




wire                     us_a4s_lpi_busy_o;
wire [FC_CFG_DATA_W-1:0] us_a4s_data_o;
wire                     us_a4s_last_o;
wire                     us_a4s_valid_o;

wire                      msg_dec_a4s_ready_o;
wire                      msg_dec_a4s_discon_o;
wire                      msg_dec_lpi_busy_o;
wire                      msg_dec_reg_restore_o;
wire [FC_CFG_DATA_W-1:0]  msg_dec_reg_restore_data_o;
wire                      msg_dec_reg_con_accept_o;
wire                      msg_dec_reg_rw_o;
wire [REG_ADDR_WIDTH-1:0] msg_dec_reg_addr_o;
wire [REG_DATA_WIDTH-1:0] msg_dec_wr_data_o;
wire                      msg_dec_reg_valid_o;
wire                      msg_dec_pwr_accept_o;

wire                      reg_ctlr_restore_done_o;
wire                      reg_ctlr_lpi_busy_o;
wire                      reg_ctlr_wr_rsp_o;
wire                      reg_ctlr_wr_tamp_o;
wire [REG_DATA_WIDTH-1:0] reg_ctlr_rd_data_o;
wire                      reg_ctlr_rw_o;
wire                      reg_ctlr_msg_valid_o;
wire [READ_DATA_SIZE-1:0] reg_ctlr_msg_size_o;

wire                       msg_arb_lpi_busy_o;
wire [MSG_TYPE_WIDTH-1:0]  msg_arb_msg_type_o;
wire [MSG_NOFRMT_SIZE-1:0] msg_arb_msg_data_o;
wire [READ_DATA_SIZE-1:0]  msg_arb_rd_size_o;
wire                       msg_arb_msg_valid_o;
wire                       msg_arb_rw_valid_o;

wire [MSG_SIZE-1:0]        msg_crtr_msg_data_o;
wire [MSG_SIZE_WIDTH-1:0]  msg_crtr_msg_size_o;
wire                       msg_crtr_msg_valid_o;
wire                       msg_crtr_lpi_busy_o;

wire a4s_dn_ready_o;
wire a4s_dn_last_sent_o;
wire a4s_dn_lpi_busy_o;


firewall_f0_comp_a4s_us_fsm
  #(
    .FC_CFG_DATA_W  (FC_CFG_DATA_W),
    .LOG2_FW_NUM_FC (LOG2_FW_NUM_FC),
    .FC_BAS_REG_SLC (FC_BAS_REG_SLC)
  )
  u_firewall_f0_comp_a4s_us_fsm
  (
    .clk            (clk),
    .reset_n        (reset_n),
    .tvalid_us_i    (cfg_tvalid_us_i),
    .tready_us_o    (cfg_tready_us_o),
    .tdata_us_i     (cfg_tdata_us_i),
    .tkeep_us_i     (cfg_tkeep_us_i),
    .tlast_us_i     (cfg_tlast_us_i),
    .tdest_us_i     (cfg_tdest_us_i),
    .twakeup_us_i   (cfg_twakeup_us_i),
    .a4s_data_o     (us_a4s_data_o),
    .a4s_last_o     (us_a4s_last_o),
    .a4s_valid_o    (us_a4s_valid_o),
    .a4s_ready_i    (msg_dec_a4s_ready_o),
    .a4s_discon_i   (msg_dec_a4s_discon_o),
    .a4s_con_i      (cfg_lpi_con_req_i[0]),
    .a4s_clk_hold_i (cfg_lpi_clk_hold_i),
    .a4s_lpi_busy_o (us_a4s_lpi_busy_o),
    .a4s_gate_bas_o (cfg_gate_bas_o)
  );


firewall_f0_comp_msg_dec
  #(
    .FC_CFG_DATA_W                (FC_CFG_DATA_W),
    .REG_ADDR_WIDTH               (REG_ADDR_WIDTH),
    .REG_DATA_WIDTH               (REG_DATA_WIDTH),
    .FW_SRE_LVL                   (FW_SRE_LVL),
    .FC_PE_LVL                    (FC_PE_LVL)
  )
  u_firewall_f0_comp_msg_dec
  (
    .clk                          (clk),
    .reset_n                      (reset_n),
    .msg_dec_a4s_data_i           (us_a4s_data_o),
    .msg_dec_a4s_last_i           (us_a4s_last_o),
    .msg_dec_a4s_valid_i          (us_a4s_valid_o),
    .msg_dec_a4s_ready_o          (msg_dec_a4s_ready_o),
    .msg_dec_a4s_discon_o         (msg_dec_a4s_discon_o),
    .msg_dec_pwr_accept_o         (msg_dec_pwr_accept_o),
    .msg_dec_lpi_busy_o           (msg_dec_lpi_busy_o),
    .msg_dec_reg_restore_o        (msg_dec_reg_restore_o),
    .msg_dec_reg_restore_data_o   (msg_dec_reg_restore_data_o),
    .msg_dec_reg_con_accept_o     (msg_dec_reg_con_accept_o),
    .msg_dec_reg_rw_o             (msg_dec_reg_rw_o),
    .msg_dec_reg_addr_o           (msg_dec_reg_addr_o),
    .msg_dec_wr_data_o            (msg_dec_wr_data_o),
    .msg_dec_reg_valid_o          (msg_dec_reg_valid_o),
    .msg_dec_rw_nxt_i             (msg_arb_rw_valid_o),
    .msg_dec_last_sent_i          (a4s_dn_last_sent_o)
  );

firewall_f0_comp_reg_ctlr
  #(
    .FC_CFG_DATA_W         (FC_CFG_DATA_W),
    .FC_NUM_RGN            (FC_NUM_RGN),
    .LOG2_FC_NUM_RGN       (LOG2_FC_NUM_RGN),
    .REG_ADDR_WIDTH        (REG_ADDR_WIDTH),
    .REG_DATA_WIDTH        (REG_DATA_WIDTH),
    .FW_SRE_LVL            (FW_SRE_LVL),
    .READ_DATA_SIZE        (READ_DATA_SIZE),
    .FC_PE_LVL             (FC_PE_LVL),
    .FW_LDE_LVL            (FW_LDE_LVL),
    .FC_MXRS               (FC_MXRS),
    .FC_RSE_LVL            (FC_RSE_LVL),
    .FC_TE_LVL             (FC_TE_LVL),
    .FC_NUM_MPE            (FC_NUM_MPE),
    .FC_SINGLE_MST         (FC_SINGLE_MST),
    .FC_ME_LVL             (FC_ME_LVL),
    .FC_INST_SPT           (FC_INST_SPT),
    .FC_MA_SPT             (FC_MA_SPT),
    .FC_SEC_SPT            (FC_SEC_SPT),
    .FC_PRIV_SPT           (FC_PRIV_SPT),
    .FC_SH_SPT             (FC_SH_SPT),
    .SRAM_WIDTH            (SRAM_WIDTH),
    .FC_ID                 (FC_ID),
    .FW_MAX_MST_ID_WIDTH   (FW_MAX_MST_ID_WIDTH),
    .FC_MST_ID_WIDTH       (FC_MST_ID_WIDTH)
  )
  u_firewall_f0_comp_reg_ctlr
  (
    .clk                       (clk),
    .reset_n                   (reset_n),
    .pe_ctrl_i                 (cfg_pe_ctrl_i),
    .pe_ctrl_en                (cfg_pe_ctrl_en),
    .pe_ctrl_o                 (cfg_pe_ctrl_o),
    .pe_st_i                   (cfg_pe_st_i),
    .rwe_ctrl_i                (cfg_rwe_ctrl_i),
    .rwe_ctrl_en               (cfg_rwe_ctrl_en),
    .rwe_ctrl_o                (cfg_rwe_ctrl_o),
    .rgn_ctrl0_rgn_i           (cfg_rgn_ctrl0_rgn_i),
    .rgn_ctrl0_en              (cfg_rgn_ctrl0_en),
    .rgn_ctrl0_o               (cfg_rgn_ctrl0_o),
    .rgn_ctrl1_rgn_i           (cfg_rgn_ctrl1_rgn_i),
    .rgn_ctrl1_en              (cfg_rgn_ctrl1_en),
    .rgn_ctrl1_o               (cfg_rgn_ctrl1_o),
    .rgn_lctrl_rgn_i           (cfg_rgn_lctrl_rgn_i),
    .rgn_lctrl_en              (cfg_rgn_lctrl_en),
    .rgn_lctrl_o               (cfg_rgn_lctrl_o),
    .rgn_st_rgn_i              (cfg_rgn_st_rgn_i),
    .rgn_cfg0_rgn_i            (cfg_rgn_cfg0_rgn_i),
    .rgn_cfg0_en               (cfg_rgn_cfg0_en),
    .rgn_cfg0_o                (cfg_rgn_cfg0_o),
    .rgn_cfg1_rgn_i            (cfg_rgn_cfg1_rgn_i),
    .rgn_cfg1_en               (cfg_rgn_cfg1_en),
    .rgn_cfg1_o                (cfg_rgn_cfg1_o),
    .rgn_size_rgn_i            (cfg_rgn_size_rgn_i),
    .rgn_size_en               (cfg_rgn_size_en),
    .rgn_size_o                (cfg_rgn_size_o),
    .rgn_tcfg0_rgn_i           (cfg_rgn_tcfg0_rgn_i),
    .rgn_tcfg0_en              (cfg_rgn_tcfg0_en),
    .rgn_tcfg0_o               (cfg_rgn_tcfg0_o),
    .rgn_tcfg1_rgn_i           (cfg_rgn_tcfg1_rgn_i),
    .rgn_tcfg1_en              (cfg_rgn_tcfg1_en),
    .rgn_tcfg1_o               (cfg_rgn_tcfg1_o),
    .rgn_tcfg2_rgn_i           (cfg_rgn_tcfg2_rgn_i),
    .rgn_tcfg2_en              (cfg_rgn_tcfg2_en),
    .rgn_tcfg2_o               (cfg_rgn_tcfg2_o),
    .rgn_mid0_rgn_i            (cfg_rgn_mid0_rgn_i),
    .rgn_mid0_en               (cfg_rgn_mid0_en),
    .rgn_mid0_o                (cfg_rgn_mid0_o),
    .rgn_mid1_rgn_i            (cfg_rgn_mid1_rgn_i),
    .rgn_mid1_en               (cfg_rgn_mid1_en),
    .rgn_mid1_o                (cfg_rgn_mid1_o),
    .rgn_mid2_rgn_i            (cfg_rgn_mid2_rgn_i),
    .rgn_mid2_en               (cfg_rgn_mid2_en),
    .rgn_mid2_o                (cfg_rgn_mid2_o),
    .rgn_mid3_rgn_i            (cfg_rgn_mid3_rgn_i),
    .rgn_mid3_en               (cfg_rgn_mid3_en),
    .rgn_mid3_o                (cfg_rgn_mid3_o),
    .rgn_mpl0_rgn_i            (cfg_rgn_mpl0_rgn_i),
    .rgn_mpl0_en               (cfg_rgn_mpl0_en),
    .rgn_mpl0_o                (cfg_rgn_mpl0_o),
    .rgn_mpl1_rgn_i            (cfg_rgn_mpl1_rgn_i),
    .rgn_mpl1_en               (cfg_rgn_mpl1_en),
    .rgn_mpl1_o                (cfg_rgn_mpl1_o),
    .rgn_mpl2_rgn_i            (cfg_rgn_mpl2_rgn_i),
    .rgn_mpl2_en               (cfg_rgn_mpl2_en),
    .rgn_mpl2_o                (cfg_rgn_mpl2_o),
    .rgn_mpl3_rgn_i            (cfg_rgn_mpl3_rgn_i),
    .rgn_mpl3_en               (cfg_rgn_mpl3_en),
    .rgn_mpl3_o                (cfg_rgn_mpl3_o),
    .fe_tal_i                  (cfg_fe_tal_i),
    .fe_tau_i                  (cfg_fe_tau_i),
    .fe_tp_i                   (cfg_fe_tp_i),
    .fe_mid_i                  (cfg_fe_mid_i),
    .fe_ctrl_i                 (cfg_fe_ctrl_i),
    .fe_ctrl_en                (cfg_fe_ctrl_en),
    .fe_ctrl_o                 (cfg_fe_ctrl_o),
    .me_ctrl_i                 (cfg_me_ctrl_i),
    .me_ctrl_en                (cfg_me_ctrl_en),
    .me_ctrl_o                 (cfg_me_ctrl_o),
    .me_st_i                   (cfg_me_st_i),
    .me_st_en                  (cfg_me_st_en),
    .me_st_o                   (cfg_me_st_o),
    .edr_tal_i                 (cfg_edr_tal_i),
    .edr_tal_en                (cfg_edr_tal_en),
    .edr_tal_o                 (cfg_edr_tal_o),
    .edr_tau_i                 (cfg_edr_tau_i),
    .edr_tau_en                (cfg_edr_tau_en),
    .edr_tau_o                 (cfg_edr_tau_o),
    .edr_tp_i                  (cfg_edr_tp_i),
    .edr_tp_en                 (cfg_edr_tp_en),
    .edr_tp_o                  (cfg_edr_tp_o),
    .edr_mid_i                 (cfg_edr_mid_i),
    .edr_mid_en                (cfg_edr_mid_en),
    .edr_mid_o                 (cfg_edr_mid_o),
    .edr_ctrl_i                (cfg_edr_ctrl_i),
    .edr_ctrl_en               (cfg_edr_ctrl_en),
    .edr_ctrl_o                (cfg_edr_ctrl_o),
    .ld_ctrl_i                 (cfg_ld_ctrl_i),
    .ld_ctrl_en                (cfg_ld_ctrl_en),
    .ld_ctrl_o                 (cfg_ld_ctrl_o),
    .prot_size_en              (cfg_prot_size_en),
    .prot_size_o               (cfg_prot_size_o),
    .pe_bps_i                  (cfg_bypass_i),
    .reg_ctlr_restore_done_o   (reg_ctlr_restore_done_o),
    .reg_ctlr_lpi_busy_o       (reg_ctlr_lpi_busy_o),
    .reg_ctlr_restore_i        (msg_dec_reg_restore_o),
    .reg_ctlr_restore_data_i   (msg_dec_reg_restore_data_o),
    .reg_ctlr_con_accept_i     (msg_dec_reg_con_accept_o),
    .reg_ctlr_reg_rw_i         (msg_dec_reg_rw_o),
    .reg_ctlr_reg_addr_i       (msg_dec_reg_addr_o),
    .reg_ctlr_wr_data_i        (msg_dec_wr_data_o),
    .reg_ctlr_reg_valid_i      (msg_dec_reg_valid_o),
    .reg_ctlr_wr_rsp_o         (reg_ctlr_wr_rsp_o),
    .reg_ctlr_wr_tamp_o        (reg_ctlr_wr_tamp_o),
    .reg_ctlr_rd_data_o        (reg_ctlr_rd_data_o),
    .reg_ctlr_rw_o             (reg_ctlr_rw_o),
    .reg_ctlr_msg_valid_o      (reg_ctlr_msg_valid_o),
    .reg_ctlr_msg_size_o       (reg_ctlr_msg_size_o)
  );

firewall_f0_comp_msg_arb
  #(
    .REG_DATA_WIDTH            (REG_DATA_WIDTH),
    .READ_DATA_SIZE            (READ_DATA_SIZE),
    .IRQ_TYPE_WIDTH            (IRQ_TYPE_WIDTH),
    .MSG_TYPE_WIDTH            (MSG_TYPE_WIDTH),
    .MSG_NOFRMT_SIZE           (MSG_NOFRMT_SIZE),
    .MSG_TYPE_READ             (MSG_TYPE_READ),
    .MSG_TYPE_WRITE            (MSG_TYPE_WRITE),
    .MSG_TYPE_CONNECT          (MSG_TYPE_CONNECT),
    .MSG_TYPE_DISCONNECT       (MSG_TYPE_DISCONNECT),
    .MSG_TYPE_IRQ              (MSG_TYPE_IRQ),
    .FC_ME_LVL                 (FC_ME_LVL),
    .FC_PE_LVL                 (FC_PE_LVL)
  )
  u_firewall_f0_comp_msg_arb
  (
    .clk                       (clk),
    .reset_n                   (reset_n),
    .msg_arb_wr_rsp_i          (reg_ctlr_wr_rsp_o),
    .msg_arb_wr_tamp_i         (reg_ctlr_wr_tamp_o),
    .msg_arb_rd_data_i         (reg_ctlr_rd_data_o),
    .msg_arb_rw_i              (reg_ctlr_rw_o),
    .msg_arb_rd_size_i         (reg_ctlr_msg_size_o),
    .msg_arb_msg_valid_i       (reg_ctlr_msg_valid_o),
    .msg_arb_irq_req_i         (cfg_irq_req_i),
    .msg_arb_irq_valid_i       (cfg_irq_valid_i),
    .msg_arb_pwr_con_req_i     (cfg_lpi_con_req_i),
    .msg_arb_pwr_dis_con_req_i (cfg_lpi_discon_req_i),
    .msg_arb_lpi_busy_o        (msg_arb_lpi_busy_o),
    .msg_arb_msg_type_o        (msg_arb_msg_type_o),
    .msg_arb_msg_data_o        (msg_arb_msg_data_o),
    .msg_arb_rd_size_o         (msg_arb_rd_size_o),
    .msg_arb_msg_valid_o       (msg_arb_msg_valid_o),
    .msg_arb_rw_valid_o        (msg_arb_rw_valid_o),
    .msg_arb_ready_i           (a4s_dn_ready_o)
  );

firewall_f0_comp_message_creator
  #(
    .MSG_NOFRMT_SIZE        (MSG_NOFRMT_SIZE),
    .READ_DATA_SIZE         (READ_DATA_SIZE),
    .MSG_SIZE               (MSG_SIZE),
    .MSG_TYPE_WIDTH         (MSG_TYPE_WIDTH),
    .MSG_TYPE_READ          (MSG_TYPE_READ),
    .MSG_TYPE_WRITE         (MSG_TYPE_WRITE),
    .MSG_TYPE_CONNECT       (MSG_TYPE_CONNECT),
    .MSG_TYPE_DISCONNECT    (MSG_TYPE_DISCONNECT),
    .MSG_TYPE_IRQ           (MSG_TYPE_IRQ),
    .FC_CFG_DATA_W          (FC_CFG_DATA_W),
    .READ_MSG_HDR_SIZE      (READ_MSG_HDR_SIZE),
    .CFG_READ_RSP_T         (CFG_READ_RSP_T),
    .CFG_WRITE_RSP_T        (CFG_WRITE_RSP_T),
    .CFG_RSP_T              (CFG_RSP_T),
    .HNDSHK_REQ_T           (HNDSHK_REQ_T),
    .IRQ_REQ_T              (IRQ_REQ_T),
    .MAX_NUM_OF_PKTS        (MAX_NUM_OF_PKTS),
    .MSG_SIZE_WIDTH         (MSG_SIZE_WIDTH)
  )
  u_firewall_f0_comp_message_creator
  (
    .msg_crtr_msg_type_i    (msg_arb_msg_type_o),
    .msg_crtr_msg_data_i    (msg_arb_msg_data_o),
    .msg_crtr_msg_rd_size_i (msg_arb_rd_size_o),
    .msg_crtr_msg_valid_i   (msg_arb_msg_valid_o),
    .msg_crtr_msg_data_o    (msg_crtr_msg_data_o),
    .msg_crtr_msg_size_o    (msg_crtr_msg_size_o),
    .msg_crtr_msg_valid_o   (msg_crtr_msg_valid_o),
    .msg_crtr_lpi_busy_o    (msg_crtr_lpi_busy_o)
  );

firewall_f0_comp_a4s_ds_fsm
  #(
    .FC_CFG_DATA_W      (FC_CFG_DATA_W),
    .MSG_SIZE           (MSG_SIZE),
    .FC_ID              (FC_ID),
    .LOG2_FW_NUM_FC     (LOG2_FW_NUM_FC),
    .READ_DATA_SIZE     (READ_DATA_SIZE),
    .MAX_NUM_OF_PKTS    (MAX_NUM_OF_PKTS),
    .MSG_SIZE_WIDTH     (MSG_SIZE_WIDTH)
  )
  u_firewall_f0_comp_a4s_ds_fsm
  (
    .clk                (clk),
    .reset_n            (reset_n),
    .tvalid_ds_o        (cfg_tvalid_ds_o),
    .tready_ds_i        (cfg_tready_ds_i),
    .tdata_ds_o         (cfg_tdata_ds_o),
    .tkeep_ds_o         (cfg_tkeep_ds_o),
    .tlast_ds_o         (cfg_tlast_ds_o),
    .tid_ds_o           (cfg_tid_ds_o),
    .twakeup_ds_o       (cfg_twakeup_ds_o),
    .a4s_dn_msg_i       (msg_crtr_msg_data_o),
    .a4s_dn_msg_size_i  (msg_crtr_msg_size_o),
    .a4s_dn_msg_valid_i (msg_crtr_msg_valid_o),
    .a4s_dn_ready_o     (a4s_dn_ready_o),
    .a4s_dn_last_sent_o (a4s_dn_last_sent_o),
    .a4s_dn_lpi_busy_o  (a4s_dn_lpi_busy_o)
  );


assign cfg_lpi_pwr_accept_o = reg_ctlr_restore_done_o || msg_dec_pwr_accept_o;

assign cfg_lpi_busy_o = reg_ctlr_lpi_busy_o || msg_dec_lpi_busy_o ||
                        us_a4s_lpi_busy_o || msg_arb_lpi_busy_o ||
                        msg_crtr_lpi_busy_o || a4s_dn_lpi_busy_o ||
                        cfg_lpi_pwr_accept_o;

endmodule
