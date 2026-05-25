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

module firewall_f0_ctlr_reg_ctlr #(
    `include "firewall_f0_reg_width_params.vh"
    ,
    `include "firewall_f0_ctlr_reg_width_params.vh"
    parameter FC_CFG_DATA_W       = 32,
    parameter LOG2_FC_NUM_RGN     = 2,
    parameter REG_ADDR_WIDTH      = 10,
    parameter REG_DATA_WIDTH      = 32,
    parameter FW_SRE_LVL          = 1,
    parameter READ_DATA_SIZE      = 7,
    parameter FC_NUM_RGN          = 4,
    parameter FW_NUM_FC           = 13,
    parameter TOTAL_FC            = 14,
    parameter CHECK_TYPE_WIDTH    = 3,
    parameter FW_LDE_LVL          = 0,
    parameter FC_MST_ID_WIDTH     = 8
) (
    input  wire                                        clk,
    input  wire                                        reset_n,

    output wire                                        fw_ctrl_en,
    output wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_o,

    output wire                                        fw_sr_ctrl_en,
    output wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_o,

    output wire [TOTAL_FC-1:0]                         ld_ctrl_en,
    output wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]         ld_ctrl_o,

    output wire                                        pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_o,

    output wire                                        rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_ctrl0_en,
    output wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     rgn_ctrl0_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_ctrl1_en,
    output wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     rgn_ctrl1_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_lctrl_en,
    output wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     rgn_lctrl_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_cfg0_en,
    output wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      rgn_cfg0_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_cfg1_en,
    output wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      rgn_cfg1_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_size_en,
    output wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      rgn_size_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_tcfg0_en,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_tcfg1_en,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_tcfg2_en,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mid0_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid0_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mid1_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid1_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mid2_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid2_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mid3_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid3_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mpl0_en,
    output wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      rgn_mpl0_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mpl1_en,
    output wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      rgn_mpl1_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mpl2_en,
    output wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      rgn_mpl2_o,

    output wire [FC_NUM_RGN-1:0]                       rgn_mpl3_en,
    output wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      rgn_mpl3_o,

    output wire                                        fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_o,

    output wire                                        me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_o,

    output wire                                        edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]                   edr_ctrl_o,

    output wire [31:0]                                 fc_int_st_en,
    output wire [(32*FC_INT_ST_WIDTH)-1:0]             fc_int_st_o,

    output wire [31:0]                                 fc_int_msk_en,
    output wire [(32*FC_INT_MSK_WIDTH)-1:0]            fc_int_msk_o,

    output wire                                        fw_tmp_ctrl_en,
    output wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_o,

    input  wire                                        addr_dec_fw_ctrl_en,
    input  wire [FW_CTRL_WIDTH-1:0]                    addr_dec_fw_ctrl_i,

    input  wire                                        addr_dec_fw_sr_ctrl_en,
    input  wire [FW_SR_CTRL_WIDTH-1:0]                 addr_dec_fw_sr_ctrl_i,

    input  wire [TOTAL_FC-1:0]                         addr_dec_ld_ctrl_en,
    input  wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]         addr_dec_ld_ctrl_i,

    input  wire                                        addr_dec_pe_ctrl_en,
    input  wire [PE_CTRL_WIDTH-1:0]                    addr_dec_pe_ctrl_i,

    input  wire                                        addr_dec_rwe_ctrl_en,
    input  wire [RWE_CTRL_WIDTH-1:0]                   addr_dec_rwe_ctrl_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_ctrl0_en,
    input  wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     addr_dec_rgn_ctrl0_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_ctrl1_en,
    input  wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     addr_dec_rgn_ctrl1_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_lctrl_en,
    input  wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     addr_dec_rgn_lctrl_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_cfg0_en,
    input  wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      addr_dec_rgn_cfg0_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_cfg1_en,
    input  wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      addr_dec_rgn_cfg1_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_size_en,
    input  wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      addr_dec_rgn_size_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg0_en,
    input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     addr_dec_rgn_tcfg0_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg1_en,
    input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     addr_dec_rgn_tcfg1_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_tcfg2_en,
    input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     addr_dec_rgn_tcfg2_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid0_en,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid0_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid1_en,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid1_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid2_en,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid2_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mid3_en,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     addr_dec_rgn_mid3_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl0_en,
    input  wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      addr_dec_rgn_mpl0_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl1_en,
    input  wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      addr_dec_rgn_mpl1_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl2_en,
    input  wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      addr_dec_rgn_mpl2_i,

    input  wire [FC_NUM_RGN-1:0]                       addr_dec_rgn_mpl3_en,
    input  wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      addr_dec_rgn_mpl3_i,

    input  wire                                        addr_dec_fe_ctrl_en,
    input  wire [FE_CTRL_WIDTH-1:0]                    addr_dec_fe_ctrl_i,

    input  wire                                        addr_dec_me_ctrl_en,
    input  wire [ME_CTRL_WIDTH-1:0]                    addr_dec_me_ctrl_i,

    input  wire                                        addr_dec_edr_ctrl_en,
    input  wire [EDR_CTRL_WIDTH-1:0]                   addr_dec_edr_ctrl_i,

    input  wire [31:0]                                 addr_dec_fc_int_st_en,
    input  wire [(32*FC_INT_ST_WIDTH)-1:0]             addr_dec_fc_int_st_i,

    input  wire [31:0]                                 addr_dec_fc_int_msk_en,
    input  wire [(32*FC_INT_MSK_WIDTH)-1:0]            addr_dec_fc_int_msk_i,

    input  wire                                        addr_dec_fw_tmp_ctrl_en,
    input  wire [FW_TMP_CTRL_WIDTH-1:0]                addr_dec_fw_tmp_ctrl_i,

    output wire                                        reg_ctlr_clk_busy_o,

    input  wire                                        reg_ctlr_reg_valid_i,

    output wire                                        reg_ctlr_wr_valid_o
);


wire reg_en_nxt;


assign reg_ctlr_wr_valid_o = reg_ctlr_reg_valid_i;

assign reg_en_nxt = reg_ctlr_reg_valid_i;

assign fw_ctrl_en = reg_en_nxt && addr_dec_fw_ctrl_en;
assign fw_ctrl_o  = addr_dec_fw_ctrl_i;

assign fw_sr_ctrl_en = reg_en_nxt && addr_dec_fw_sr_ctrl_en;
assign fw_sr_ctrl_o  = addr_dec_fw_sr_ctrl_i;

assign ld_ctrl_en = {TOTAL_FC{reg_en_nxt}} & addr_dec_ld_ctrl_en;
assign ld_ctrl_o  = addr_dec_ld_ctrl_i;

assign pe_ctrl_en = reg_en_nxt && addr_dec_pe_ctrl_en;
assign pe_ctrl_o  = addr_dec_pe_ctrl_i;

assign rwe_ctrl_en = reg_en_nxt && addr_dec_rwe_ctrl_en;
assign rwe_ctrl_o  = addr_dec_rwe_ctrl_i;

assign rgn_ctrl0_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_ctrl0_en;
assign rgn_ctrl0_o  = addr_dec_rgn_ctrl0_i;

assign rgn_ctrl1_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_ctrl1_en;
assign rgn_ctrl1_o  = addr_dec_rgn_ctrl1_i;

assign rgn_lctrl_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_lctrl_en;
assign rgn_lctrl_o  = addr_dec_rgn_lctrl_i;

assign rgn_cfg0_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_cfg0_en;
assign rgn_cfg0_o  = addr_dec_rgn_cfg0_i;

assign rgn_cfg1_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_cfg1_en;
assign rgn_cfg1_o  = addr_dec_rgn_cfg1_i;

assign rgn_size_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_size_en;
assign rgn_size_o  = addr_dec_rgn_size_i;

assign rgn_tcfg0_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_tcfg0_en;
assign rgn_tcfg0_o  = addr_dec_rgn_tcfg0_i;

assign rgn_tcfg1_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_tcfg1_en;
assign rgn_tcfg1_o  = addr_dec_rgn_tcfg1_i;

assign rgn_tcfg2_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_tcfg2_en;
assign rgn_tcfg2_o  = addr_dec_rgn_tcfg2_i;

assign rgn_mid0_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mid0_en;
assign rgn_mid0_o  = addr_dec_rgn_mid0_i;

assign rgn_mid1_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mid1_en;
assign rgn_mid1_o  = addr_dec_rgn_mid1_i;

assign rgn_mid2_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mid2_en;
assign rgn_mid2_o  = addr_dec_rgn_mid2_i;

assign rgn_mid3_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mid3_en;
assign rgn_mid3_o  = addr_dec_rgn_mid3_i;

assign rgn_mpl0_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mpl0_en;
assign rgn_mpl0_o  = addr_dec_rgn_mpl0_i;

assign rgn_mpl1_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mpl1_en;
assign rgn_mpl1_o  = addr_dec_rgn_mpl1_i;

assign rgn_mpl2_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mpl2_en;
assign rgn_mpl2_o  = addr_dec_rgn_mpl2_i;

assign rgn_mpl3_en = {FC_NUM_RGN{reg_en_nxt}} & addr_dec_rgn_mpl3_en;
assign rgn_mpl3_o  = addr_dec_rgn_mpl3_i;

assign fe_ctrl_en = reg_en_nxt && addr_dec_fe_ctrl_en;
assign fe_ctrl_o  = addr_dec_fe_ctrl_i;

assign me_ctrl_en = reg_en_nxt && addr_dec_me_ctrl_en;
assign me_ctrl_o  = addr_dec_me_ctrl_i;

assign edr_ctrl_en = reg_en_nxt && addr_dec_edr_ctrl_en;
assign edr_ctrl_o  = addr_dec_edr_ctrl_i;

assign fc_int_st_en = {32{reg_en_nxt}} & addr_dec_fc_int_st_en;
assign fc_int_st_o  = addr_dec_fc_int_st_i;

assign fc_int_msk_en = {32{reg_en_nxt}} & addr_dec_fc_int_msk_en;
assign fc_int_msk_o  = addr_dec_fc_int_msk_i;

assign fw_tmp_ctrl_en = reg_en_nxt && addr_dec_fw_tmp_ctrl_en;
assign fw_tmp_ctrl_o  = addr_dec_fw_tmp_ctrl_i;

assign reg_ctlr_clk_busy_o = reg_ctlr_reg_valid_i;

endmodule
