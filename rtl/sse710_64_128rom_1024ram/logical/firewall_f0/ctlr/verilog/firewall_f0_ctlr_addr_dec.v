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

module firewall_f0_ctlr_addr_dec #(
    `include "firewall_f0_reg_width_params.vh"
    ,
    `include "firewall_f0_ctlr_reg_width_params.vh"
    parameter REG_ADDR_WIDTH           = 10,
    parameter REG_DATA_WIDTH           = 32,
    parameter FW_NUM_FC                = 2,
    parameter LOG2_FW_NUM_FC           = 1,
    parameter FW_SRE_LVL               = 1,
    parameter FC_PE_LVL                = 2,
    parameter FW_LDE_LVL               = 2,
    parameter FC_MXRS                  = 25,
    parameter FC_MNRS                  = 8,
    parameter FC_RSE_LVL               = 1,
    parameter FC_TE_LVL                = 2,
    parameter FC_NUM_MPE               = 2,
    parameter FC_SINGLE_MST            = 1,
    parameter FC_ME_LVL                = 1,
    parameter FC_INST_SPT              = 1,
    parameter FC_MA_SPT                = 1,
    parameter FC_SEC_SPT               = 1,
    parameter FC_PRIV_SPT              = 1,
    parameter FC_SH_SPT                = 1,
    parameter READ_DATA_SIZE           = 7,
    parameter FC_NUM_RGN               = 4,
    parameter REG_ENUM_WIDTH           = 126,
    parameter LOG2_SRAM_SIZE           = 12,
    parameter FC_ID                    = 0,
    parameter SRAM_WIDTH               = 32,
    parameter LOG2_SRAM_WIDTH          = 5,
    parameter FC_MST_ID_WIDTH          = 8,
    parameter MAX_NUM_RGN              = 64,
    parameter CHECK_TYPE_WIDTH         = 3,
    parameter N_MEM_RET                = 1,
    parameter TOTAL_FC                 = 3,
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
    parameter FW_ID_WIDTH              = 2,
    parameter CHECK_RWE_DATA           = 3'b000,
    parameter CHECK_RWE_MPL            = 3'b001,
    parameter CHECK_RWE_EN             = 3'b010,
    parameter CHECK_RWE_LOCK           = 3'b011,
    parameter CHECK_FW_LOCK            = 3'b100,
    parameter CHECK_LDE                = 3'b101,
    parameter FC_RGN_BASE_ADDR_EXT     = 8192'h0,
    parameter FC_RGN_UPR_ADDR_EXT      = 8192'h0,
    parameter FC_RGN_SIZE_EXT          = 1024'h0,
    parameter FC_RGN_MULNPO2_EXT       = 128'h0,
    parameter FC_MST_ID_SINGLE_MST_EXT = 0,
    parameter FW_CFG_AGENT_MST_ID      = 0,
    parameter FW_MAX_MST_ID_WIDTH      = 8,
    parameter FC_MST_ID_WIDTH_EXT      = 8
) (
    input  wire                                    clk,
    input  wire                                    reset_n,

    input  wire [REG_ADDR_WIDTH-1:0]               addr_dec_reg_addr_i,
    input  wire [REG_ENUM_WIDTH-1:0]               addr_dec_reg_enum_addr_i,
    input  wire                                    addr_dec_rw_i,
    input  wire [FW_ID_WIDTH-1:0]                  addr_dec_fw_id_i,
    input  wire [LOG2_FW_NUM_FC-1:0]               addr_dec_fc_id_i,
    input  wire [REG_DATA_WIDTH-1:0]               addr_dec_wr_data_i,
    input  wire                                    addr_dec_acc_valid_i,
    input  wire                                    addr_dec_cfg_active_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              addr_dec_mst_id_i,
    input  wire [1:0]                              addr_dec_axprot_i,

    input  wire [FW_NUM_FC-1:0]                    addr_dec_pwr_st_i,
    input  wire [FW_CTRL_WIDTH-1:0]                fw_ctrl_i,
    input  wire [FW_ST_WIDTH-1:0]                  fw_st_i,
    input  wire [FW_SR_CTRL_WIDTH-1:0]             fw_sr_ctrl_i,
    input  wire [PE_BPS_WIDTH-1:0]                 pe_bps_i,
    input  wire [FW_INT_ST_WIDTH-1:0]              fw_int_st_i,
    input  wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]     ld_ctrl_i,
    input  wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_i,
    input  wire [PE_ST_WIDTH-1:0]                  pe_st_i,
    input  wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_i,
    input  wire [RGN_CTRL0_WIDTH-1:0]              rgn_ctrl0_rgn_i,
    input  wire [RGN_CTRL1_WIDTH-1:0]              rgn_ctrl1_rgn_i,
    input  wire [RGN_LCTRL_WIDTH-1:0]              rgn_lctrl_rgn_i,
    input  wire [RGN_ST_WIDTH-1:0]                 rgn_st_rgn_i,
    input  wire [RGN_CFG0_WIDTH-1:0]               rgn_cfg0_rgn_i,
    input  wire [RGN_CFG1_WIDTH-1:0]               rgn_cfg1_rgn_i,
    input  wire [RGN_SIZE_WIDTH-1:0]               rgn_size_rgn_i,
    input  wire [RGN_TCFG0_WIDTH-1:0]              rgn_tcfg0_rgn_i,
    input  wire [RGN_TCFG1_WIDTH-1:0]              rgn_tcfg1_rgn_i,
    input  wire [RGN_TCFG2_WIDTH-1:0]              rgn_tcfg2_rgn_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid0_rgn_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid1_rgn_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid2_rgn_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              rgn_mid3_rgn_i,
    input  wire [RGN_MPL0_WIDTH-1:0]               rgn_mpl0_rgn_i,
    input  wire [RGN_MPL1_WIDTH-1:0]               rgn_mpl1_rgn_i,
    input  wire [RGN_MPL2_WIDTH-1:0]               rgn_mpl2_rgn_i,
    input  wire [RGN_MPL3_WIDTH-1:0]               rgn_mpl3_rgn_i,
    input  wire [FE_TAL_WIDTH-1:0]                 fe_tal_i,
    input  wire [FE_TAU_WIDTH-1:0]                 fe_tau_i,
    input  wire [FE_TP_WIDTH-1:0]                  fe_tp_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              fe_mid_i,
    input  wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_i,
    input  wire [ME_CTRL_WIDTH-1:0]                me_ctrl_i,
    input  wire [ME_ST_WIDTH-1:0]                  me_st_i,
    input  wire [EDR_TAL_WIDTH-1:0]                edr_tal_i,
    input  wire [EDR_TAU_WIDTH-1:0]                edr_tau_i,
    input  wire [EDR_TP_WIDTH-1:0]                 edr_tp_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              edr_mid_i,
    input  wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_i,
    input  wire [(32*FC_INT_ST_WIDTH)-1:0]         fc_int_st_i,
    input  wire [(32*FC_INT_MSK_WIDTH)-1:0]        fc_int_msk_i,
    input  wire [FW_TMP_TA_WIDTH-1:0]              fw_tmp_ta_i,
    input  wire [FW_TMP_TP_WIDTH-1:0]              fw_tmp_tp_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              fw_tmp_mid_i,
    input  wire [FW_TMP_CTRL_WIDTH-1:0]            fw_tmp_ctrl_i,
    input  wire [IIDR_WIDTH-1:0]                   iidr_i,
    input  wire [AIDR_WIDTH-1:0]                   aidr_i,
    input  wire [(FW_NUM_FC*8)-1:0]                prot_size_i,

    output wire                                    fw_ctrl_en,
    output wire [FW_CTRL_WIDTH-1:0]                fw_ctrl_o,
    output wire                                    fw_sr_ctrl_en,
    output wire [FW_SR_CTRL_WIDTH-1:0]             fw_sr_ctrl_o,
    output wire [TOTAL_FC-1:0]                     ld_ctrl_en,
    output wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]     ld_ctrl_o,
    output wire                                    pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_o,
    output wire                                    rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_ctrl0_en,
    output wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0] rgn_ctrl0_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_ctrl1_en,
    output wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0] rgn_ctrl1_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_lctrl_en,
    output wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0] rgn_lctrl_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_cfg0_en,
    output wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]  rgn_cfg0_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_cfg1_en,
    output wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]  rgn_cfg1_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_size_en,
    output wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  rgn_size_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg0_en,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg1_en,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_tcfg2_en,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid0_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid0_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid1_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid1_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid2_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid2_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mid3_en,
    output wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0] rgn_mid3_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl0_en,
    output wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rgn_mpl0_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl1_en,
    output wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rgn_mpl1_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl2_en,
    output wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rgn_mpl2_o,
    output wire [FC_NUM_RGN-1:0]                   rgn_mpl3_en,
    output wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rgn_mpl3_o,
    output wire                                    fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_o,
    output wire                                    me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                me_ctrl_o,
    output wire                                    edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_o,
    output wire [31:0]                             fc_int_st_en,
    output wire [(32*FC_INT_ST_WIDTH)-1:0]         fc_int_st_o,
    output wire [31:0]                             fc_int_msk_en,
    output wire [(32*FC_INT_MSK_WIDTH)-1:0]        fc_int_msk_o,
    output wire                                    fw_tmp_ctrl_en,
    output wire [FW_TMP_CTRL_WIDTH-1:0]            fw_tmp_ctrl_o,

    output wire [REG_ADDR_WIDTH-1:0]               addr_dec_reg_addr_o,
    output wire                                    addr_dec_rw_o,
    output wire [FW_ID_WIDTH-1:0]                  addr_dec_fw_id_o,
    output wire [LOG2_FW_NUM_FC-1:0]               addr_dec_fc_id_o,
    output wire [REG_DATA_WIDTH-1:0]               addr_dec_wr_data_o,
    output wire [REG_DATA_WIDTH-1:0]               addr_dec_reg_rd_data_o,
    output wire                                    addr_dec_hit_o,
    output wire                                    addr_dec_hit_chk_need_o,
    output wire [CHECK_TYPE_WIDTH-1:0]             addr_dec_hit_chk_type_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_sram_row_o,
    output wire [LOG2_SRAM_WIDTH-1:0]              addr_dec_sram_col_o,
    output wire [READ_DATA_SIZE-1:0]               addr_dec_reg_size_o,
    output wire                                    addr_dec_wr_rsp_pend_o,
    output wire                                    addr_dec_fixed_o,
    output wire                                    addr_dec_read_only_o,
    output wire                                    addr_dec_tamper_o,
    output wire                                    addr_dec_wr_allow_fctlr_o,
    output wire                                    addr_dec_ctlr_n_comp_o,
    output wire                                    addr_dec_acc_valid_o,

    input  wire [REG_DATA_WIDTH-1:0]               addr_dec_unfrmt_rd_data_i,
    output wire [REG_DATA_WIDTH-1:0]               addr_dec_frmtd_rd_data_o,

    input  wire [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0]   addr_dec_shdw_rgn_i,
    output wire [RWE_CTRL_WIDTH-1:0]               addr_dec_shdw_rgn_o,
    output wire [FW_NUM_FC-1:0]                    addr_dec_shdw_rgn_en_o,
    output wire                                    addr_dec_rd_rgn_st_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_lctrl_op1_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_lctrl_op2_o,
    output wire [LOG2_SRAM_WIDTH-1:0]              addr_dec_shdw_rgn_lctrl_col_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_ctrl0_op1_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_ctrl0_op2_o,
    output wire [LOG2_SRAM_WIDTH-1:0]              addr_dec_shdw_rgn_ctrl0_col_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_ctrl1_op1_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_shdw_rgn_ctrl1_op2_o,
    output wire [LOG2_SRAM_WIDTH-1:0]              addr_dec_shdw_rgn_ctrl1_col_o,
    output wire [3:0]                              addr_dec_shdw_mpe_o,

    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_add_op1_o,
    output wire [LOG2_SRAM_SIZE-1:0]               addr_dec_add_op2_o,
    output wire                                    addr_dec_add_en_o,
    input  wire [LOG2_SRAM_SIZE-1:0]               addr_dec_add_res_i,

    output wire                                    addr_dec_clk_busy_o
);


localparam FC_PE_LVL_RSTR       = FC_PE_LVL_EXT;
localparam FC_MXRS_RSTR         = FC_MXRS_EXT;
localparam FC_RSE_LVL_RSTR      = FC_RSE_LVL_EXT;
localparam FC_TE_LVL_RSTR       = FC_TE_LVL_EXT;
localparam FC_NUM_MPE_RSTR      = FC_NUM_MPE_EXT;
localparam FC_SINGLE_MST_RSTR   = FC_SINGLE_MST_EXT;
localparam FC_ME_LVL_RSTR       = FC_ME_LVL_EXT;
localparam FC_INST_SPT_RSTR     = FC_INST_SPT_EXT;
localparam FC_MA_SPT_RSTR       = FC_MA_SPT_EXT;
localparam FC_SEC_SPT_RSTR      = FC_SEC_SPT_EXT;
localparam FC_PRIV_SPT_RSTR     = FC_PRIV_SPT_EXT;
localparam FC_SH_SPT_RSTR       = FC_SH_SPT_EXT;
localparam FC_NUM_RGN_RSTR      = FC_NUM_RGN_EXT;
localparam FC_ID_RSTR           = FC_ID;
localparam FC_MST_ID_WIDTH_RSTR = FC_MST_ID_WIDTH_EXT;
localparam RGN_MID0_WIDTH       = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID1_WIDTH       = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID2_WIDTH       = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID3_WIDTH       = FW_MAX_MST_ID_WIDTH;

`include "firewall_f0_ctlr_reg_enum.vh"
`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"
`include "firewall_f0_reg_exists_localparams.vh"
`include "firewall_f0_sram_reg_lut_localparams.vh"

localparam RESTORE_FC = N_MEM_RET ? FW_NUM_FC : FW_NUM_FC+1;


function [3*RESTORE_FC-1:0] log2_rgn;
  input [7*RESTORE_FC-1:0] rgn;
  integer i;
  integer rgn_res;
  reg [31:0] rgn_32;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      rgn_32 = {{(32-7){1'b0}}, rgn[(7*(i+1))-1 -: 7]};
      rgn_res = firewall_f0_log2(rgn_32);
      log2_rgn[(3*(i+1))-1 -: 3] = rgn_res[2:0];
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rwe_ctrl_wr_mask;
  input [3*RESTORE_FC-1:0] log2_rgn_fc;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer rgn_bits;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      rgn_bits = {29'b0, log2_rgn_fc[(3*(i+1))-1 -: 3]};
      for (j=0; j<rgn_bits; j=j+1) begin
        temp_mask[j] = 1'b1;
      end
      rwe_ctrl_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_ctrl1_wr_mask;
  input [3*RESTORE_FC-1:0] fc_num_mpe;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer num_mpe;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      num_mpe = {29'b0, fc_num_mpe[(3*(i+1))-1 -: 3]};
      for (j=0; j<num_mpe; j=j+1) begin
        temp_mask[j] = 1'b1;
      end
      rgn_ctrl1_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_cfg0_wr_mask;
  input [7*RESTORE_FC-1:0] fc_mxrs;
  input [7*RESTORE_FC-1:0] fc_mnrs;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer mxrs;
  integer mnrs;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      mxrs = fc_mxrs[(7*(i+1))-1 -: 7]-5;
      mnrs = {25'b0, fc_mnrs[(7*(i+1))-1 -: 7]};
      if (mxrs > 27) begin
        mxrs = 27;
      end
      for (j=0; j<mxrs; j=j+1) begin
        if (j >= mnrs) begin
          temp_mask[j] = 1'b1;
        end
      end
      rgn_cfg0_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_cfg1_wr_mask;
  input [7*RESTORE_FC-1:0] fc_mxrs;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer mxrs;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      mxrs = {25'b0, fc_mxrs[(7*(i+1))-1 -: 7]};
      if (mxrs <= 32) begin
        mxrs = 32;
      end
      for (j=0; j<mxrs-32; j=j+1) begin
        temp_mask[j] = 1'b1;
      end
      rgn_cfg1_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_size_wr_mask;
  input [RESTORE_FC-1:0] fc_rse;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer rse;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {{(REG_DATA_WIDTH-9){1'b0}}, {9{1'b1}}};
      rse = {31'b0, fc_rse[(i+1)-1 -: 1]};
      if (rse == 0) begin
        temp_mask[8] = 1'b0;
      end
      rgn_size_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_tcfg2_wr_mask;
  input [2*RESTORE_FC-1:0] fc_te;
  input [RESTORE_FC-1:0] fc_inst_spt;
  input [RESTORE_FC-1:0] fc_priv_spt;
  input [RESTORE_FC-1:0] fc_ma_spt;
  input [RESTORE_FC-1:0] fc_sh_spt;
  input [RESTORE_FC-1:0] fc_sec_spt;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer te;
  integer inst_spt;
  integer priv_spt;
  integer ma_spt;
  integer sh_spt;
  integer sec_spt;
  integer i;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      te = {30'b0, fc_te[2*(i+1)-1 -: 2]};
      inst_spt = {31'b0, fc_inst_spt[(i+1)-1 -: 1]};
      priv_spt = {31'b0, fc_priv_spt[(i+1)-1 -: 1]};
      ma_spt = {31'b0, fc_ma_spt[(i+1)-1 -: 1]};
      sh_spt = {31'b0, fc_sh_spt[(i+1)-1 -: 1]};
      sec_spt = {31'b0, fc_sec_spt[(i+1)-1 -: 1]};
      if (sec_spt == 1) begin
        temp_mask[1:0] = 2'b11;
      end
      if (sh_spt == 1) begin
        temp_mask[3:2] = 2'b11;
      end
      if (ma_spt == 1) begin
        temp_mask[11:4] = 8'b11111111;
      end
      if (priv_spt == 1) begin
        temp_mask[13:12] = 2'b11;
      end
      if (inst_spt == 1) begin
        temp_mask[15:14] = 2'b11;
      end
      if (ma_spt == 1) begin
        temp_mask[16] = 1'b1;
      end
      if (te > 1) begin
        temp_mask[17] = 1'b1;
      end
      rgn_tcfg2_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] rgn_mpl_wr_mask;
  input [RESTORE_FC-1:0] fc_inst_spt;
  input [RESTORE_FC-1:0] fc_priv_spt;
  input [RESTORE_FC-1:0] fc_ma_spt;
  input [RESTORE_FC-1:0] fc_sec_spt;
  input integer mpl0;
  input [RESTORE_FC-1:0] fc_single_mst;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer inst_spt;
  integer priv_spt;
  integer ma_spt;
  integer sec_spt;
  integer i;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {REG_DATA_WIDTH{1'b0}};
      inst_spt = {31'b0, fc_inst_spt[(i+1)-1 -: 1]};
      priv_spt = {31'b0, fc_priv_spt[(i+1)-1 -: 1]};
      ma_spt = {31'b0, fc_ma_spt[(i+1)-1 -: 1]};
      sec_spt = {31'b0, fc_sec_spt[(i+1)-1 -: 1]};
      if ((mpl0 == 0) && (!fc_single_mst[i])) begin
        temp_mask[12] = 1'b1;
      end
      if ((inst_spt == 1) && (sec_spt == 1) && (priv_spt == 1)) begin
        temp_mask[11] = 1'b1;
      end
      if ((sec_spt == 1) && (priv_spt == 1)) begin
        temp_mask[10:9] = 2'b11;
      end
      if ((sec_spt == 1) && (inst_spt == 1)) begin
        temp_mask[8] = 1'b1;
      end
      if (sec_spt == 1) begin
        temp_mask[7:6] = 2'b11;
      end
      if ((priv_spt == 1) && (inst_spt == 1)) begin
        temp_mask[5] = 1'b1;
      end
      if (priv_spt == 1) begin
        temp_mask[4:3] = 2'b11;
      end
      if (inst_spt == 1) begin
        temp_mask[2] = 1'b1;
      end
      temp_mask[1:0] = 2'b11;
      rgn_mpl_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [REG_DATA_WIDTH*RESTORE_FC-1:0] mid_wr_mask;
  input [32*RESTORE_FC-1:0] fc_mst_id;
  reg [REG_DATA_WIDTH-1:0] temp_mask;
  integer i;
  integer j;
  begin
    for (i=0; i<RESTORE_FC; i=i+1) begin
      temp_mask = {(REG_DATA_WIDTH){1'b0}};
      for (j=0; j<32; j=j+1) begin
        if (j < fc_mst_id[i*32 +: 32]) begin
          temp_mask[j] = 1'b1;
        end
      end
      mid_wr_mask[REG_DATA_WIDTH*(i+1)-1 -: REG_DATA_WIDTH] = temp_mask;
    end
  end
endfunction

function [RESTORE_FC*MAX_NUM_RGN-1:0] tcfg01_fixed_rgn;
  input [RESTORE_FC*MAX_NUM_RGN-1:0] rgn_mulnpo2;
  input [2*RESTORE_FC-1:0] pe_lvl;
  input [2*RESTORE_FC-1:0] fc_te;
  integer i;
  integer j;
  begin
    tcfg01_fixed_rgn = {RESTORE_FC*MAX_NUM_RGN{1'b0}};
    for (i=0; i<RESTORE_FC; i=i+1) begin
      for (j=0; j<MAX_NUM_RGN; j=j+1) begin
        if ((pe_lvl[2*(i+1)-1 -: 2] == 1) && (rgn_mulnpo2[i*MAX_NUM_RGN + j])) begin
          tcfg01_fixed_rgn[i*MAX_NUM_RGN + j] = 1'b1;
        end
        else if ((pe_lvl[2*(i+1)-1 -: 2] == 1) && (fc_te[2*(i+1)-1 -: 2] < 2) &&
          (!rgn_mulnpo2[i*MAX_NUM_RGN + j])) begin
          tcfg01_fixed_rgn[i*MAX_NUM_RGN + j] = 1'b1;
        end
      end
    end
  end
endfunction

function [RESTORE_FC*MAX_NUM_RGN-1:0] tcfg2_fixed_rgn;
  input [RESTORE_FC*MAX_NUM_RGN-1:0] rgn_mulnpo2;
  input [2*RESTORE_FC-1:0] pe_lvl;
  integer i;
  integer j;
  begin
    tcfg2_fixed_rgn = {RESTORE_FC*MAX_NUM_RGN{1'b0}};
    for (i=0; i<RESTORE_FC; i=i+1) begin
      for (j=0; j<MAX_NUM_RGN; j=j+1) begin
        if ((pe_lvl[2*(i+1)-1 -: 2] == 1) && (rgn_mulnpo2[i*MAX_NUM_RGN + j])) begin
          tcfg2_fixed_rgn[i*MAX_NUM_RGN + j] = 1'b1;
        end
      end
    end
  end
endfunction


localparam [3*RESTORE_FC-1:0] LOG2_NUM_RGN_FC = log2_rgn(FC_NUM_RGN_RSTR);

localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RWE_CTRL_MASK =
  rwe_ctrl_wr_mask(LOG2_NUM_RGN_FC);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_CTRL1_MASK =
  rgn_ctrl1_wr_mask(FC_NUM_MPE_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_CFG0_MASK =
  rgn_cfg0_wr_mask(FC_MXRS_RSTR, FC_MNRS_EXT);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_CFG1_MASK =
  rgn_cfg1_wr_mask(FC_MXRS_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_SIZE_MASK =
  rgn_size_wr_mask(FC_RSE_LVL_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_TCFG2_MASK =
  rgn_tcfg2_wr_mask(FC_TE_LVL_RSTR, FC_INST_SPT_RSTR, FC_PRIV_SPT_RSTR,
  FC_MA_SPT_RSTR, FC_SH_SPT_RSTR, FC_SEC_SPT_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_MPL0_MASK =
  rgn_mpl_wr_mask(FC_INST_SPT_RSTR, FC_PRIV_SPT_RSTR, FC_MA_SPT_RSTR,
  FC_SEC_SPT_RSTR, 0, FC_SINGLE_MST_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] RGN_MPL13_MASK =
  rgn_mpl_wr_mask(FC_INST_SPT_RSTR, FC_PRIV_SPT_RSTR, FC_MA_SPT_RSTR,
  FC_SEC_SPT_RSTR, 1, FC_SINGLE_MST_RSTR);
localparam [REG_DATA_WIDTH*RESTORE_FC-1:0] MID_MASK =
  mid_wr_mask(FC_MST_ID_WIDTH_RSTR);

localparam RGN_CTRL0_RGN = (SRAM_WIDTH/RGN_CTRL0_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_CTRL0_WIDTH);
localparam RGN_CTRL1_RGN = (SRAM_WIDTH/RGN_CTRL1_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_CTRL1_WIDTH);
localparam RGN_LCTRL_RGN = (SRAM_WIDTH/RGN_LCTRL_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_LCTRL_WIDTH);
localparam RGN_CFG0_RGN = (SRAM_WIDTH/RGN_CFG0_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_CFG0_WIDTH);
localparam RGN_CFG1_RGN = (SRAM_WIDTH/RGN_CFG1_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_CFG1_WIDTH);
localparam RGN_SIZE_RGN = (SRAM_WIDTH/RGN_SIZE_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_SIZE_WIDTH);
localparam RGN_TCFG0_RGN = (SRAM_WIDTH/RGN_TCFG0_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_TCFG0_WIDTH);
localparam RGN_TCFG1_RGN = (SRAM_WIDTH/RGN_TCFG1_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_TCFG1_WIDTH);
localparam RGN_TCFG2_RGN = (SRAM_WIDTH/RGN_TCFG2_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_TCFG2_WIDTH);
localparam RGN_MID0_RGN = (SRAM_WIDTH/FW_MAX_MST_ID_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH);
localparam RGN_MID1_RGN = (SRAM_WIDTH/FW_MAX_MST_ID_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH);
localparam RGN_MID2_RGN = (SRAM_WIDTH/FW_MAX_MST_ID_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH);
localparam RGN_MID3_RGN = (SRAM_WIDTH/FW_MAX_MST_ID_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH);
localparam RGN_MPL0_RGN = (SRAM_WIDTH/RGN_MPL0_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_MPL0_WIDTH);
localparam RGN_MPL1_RGN = (SRAM_WIDTH/RGN_MPL1_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_MPL1_WIDTH);
localparam RGN_MPL2_RGN = (SRAM_WIDTH/RGN_MPL2_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_MPL2_WIDTH);
localparam RGN_MPL3_RGN = (SRAM_WIDTH/RGN_MPL3_WIDTH < 2) ?
  0 : firewall_f0_log2(SRAM_WIDTH/RGN_MPL3_WIDTH);

localparam RGN_CTRL0_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_CTRL0_WIDTH);
localparam RGN_CTRL1_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_CTRL1_WIDTH);
localparam RGN_LCTRL_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_LCTRL_WIDTH);
localparam RGN_CFG0_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_CFG0_WIDTH);
localparam RGN_CFG1_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_CFG1_WIDTH);
localparam RGN_SIZE_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_SIZE_WIDTH);
localparam RGN_TCFG0_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_TCFG0_WIDTH);
localparam RGN_TCFG1_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_TCFG1_WIDTH);
localparam RGN_TCFG2_RGN_COL = firewall_f0_log2(SRAM_WIDTH/RGN_TCFG2_WIDTH);
localparam RGN_MID0_RGN_COL  = FW_SRE_LVL == 1 ? firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH) : 1;
localparam RGN_MID1_RGN_COL  = FW_SRE_LVL == 1 ? firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH) : 1;
localparam RGN_MID2_RGN_COL  = FW_SRE_LVL == 1 ? firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH) : 1;
localparam RGN_MID3_RGN_COL  = FW_SRE_LVL == 1 ? firewall_f0_log2(SRAM_WIDTH/FW_MAX_MST_ID_WIDTH) : 1;
localparam RGN_MPL0_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_MPL0_WIDTH);
localparam RGN_MPL1_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_MPL1_WIDTH);
localparam RGN_MPL2_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_MPL2_WIDTH);
localparam RGN_MPL3_RGN_COL  = firewall_f0_log2(SRAM_WIDTH/RGN_MPL3_WIDTH);

localparam [(RESTORE_FC*MAX_NUM_RGN)-1:0] RGN_TCFG01_FIXED_RGN =
  tcfg01_fixed_rgn(FC_RGN_MULNPO2_EXT, FC_PE_LVL_RSTR, FC_TE_LVL_RSTR);
localparam [(RESTORE_FC*MAX_NUM_RGN)-1:0] RGN_TCFG2_FIXED_RGN =
  tcfg2_fixed_rgn(FC_RGN_MULNPO2_EXT, FC_PE_LVL_RSTR);

localparam [REG_ENUM_WIDTH-1:0] ONE_DEC = {{REG_ENUM_WIDTH-1{1'b0}}, 1'b1};

localparam MAX_RWE_SRAM = (RWE_CTRL_WIDTH > LOG2_SRAM_SIZE) ?
  LOG2_SRAM_SIZE : RWE_CTRL_WIDTH;


wire                                        reg_en_nxt;
wire                                        fw_ctrl_en_reg_nxt;
wire                                        fw_sr_ctrl_en_reg_nxt;
wire [FW_CTRL_WIDTH-1:0]                    fw_ctrl_wr_reg_nxt;
wire [FW_SR_CTRL_WIDTH-1:0]                 fw_sr_ctrl_wr_reg_nxt;
wire [TOTAL_FC-1:0]                         ld_ctrl_en_reg_nxt;
wire [(TOTAL_FC*LD_CTRL_WIDTH)-1:0]         ld_ctrl_wr_reg_nxt;
wire                                        pe_ctrl_en_reg_nxt;
wire [PE_CTRL_WIDTH-1:0]                    pe_ctrl_wr_reg_nxt;
wire                                        rwe_ctrl_en_reg_nxt;
wire [RWE_CTRL_WIDTH-1:0]                   rwe_ctrl_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_ctrl0_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_CTRL0_WIDTH)-1:0]     rgn_ctrl0_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_ctrl1_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_CTRL1_WIDTH)-1:0]     rgn_ctrl1_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_lctrl_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_LCTRL_WIDTH)-1:0]     rgn_lctrl_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_cfg0_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_CFG0_WIDTH)-1:0]      rgn_cfg0_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_cfg1_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_CFG1_WIDTH)-1:0]      rgn_cfg1_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_size_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]      rgn_size_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg0_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0]     rgn_tcfg0_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg1_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0]     rgn_tcfg1_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_tcfg2_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0]     rgn_tcfg2_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mid0_en_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid0_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mid1_en_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid1_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mid2_en_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid2_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mid3_en_reg_nxt;
wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]     rgn_mid3_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mpl0_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]      rgn_mpl0_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mpl1_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]      rgn_mpl1_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mpl2_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]      rgn_mpl2_wr_reg_nxt;
wire [FC_NUM_RGN-1:0]                       rgn_mpl3_en_reg_nxt;
wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]      rgn_mpl3_wr_reg_nxt;
wire                                        fe_ctrl_en_reg_nxt;
wire [FE_CTRL_WIDTH-1:0]                    fe_ctrl_wr_reg_nxt;
wire                                        me_ctrl_en_reg_nxt;
wire [ME_CTRL_WIDTH-1:0]                    me_ctrl_wr_reg_nxt;
wire                                        edr_ctrl_en_reg_nxt;
wire [EDR_CTRL_WIDTH-1:0]                   edr_ctrl_wr_reg_nxt;
wire [31:0]                                 fc_int_st_en_reg_nxt;
wire [(32*FC_INT_ST_WIDTH)-1:0]             fc_int_st_wr_reg_nxt;
wire [31:0]                                 fc_int_msk_en_reg_nxt;
wire [(32*FC_INT_MSK_WIDTH)-1:0]            fc_int_msk_wr_reg_nxt;
wire                                        fw_tmp_ctrl_en_reg_nxt;
wire [FW_TMP_CTRL_WIDTH-1:0]                fw_tmp_ctrl_wr_reg_nxt;
wire [FW_NUM_FC-1:0]                        shdw_rwe_ctrl_en_reg_nxt;
wire [RWE_CTRL_WIDTH-1:0]                   shdw_rwe_ctrl_wr_reg_nxt;

reg [(RESTORE_FC*RGN_CFG0_WIDTH)-1:0]  rgn_cfg0_fixed_int;
reg [(RESTORE_FC*RGN_CFG1_WIDTH)-1:0]  rgn_cfg1_fixed_int;
reg [(RESTORE_FC*8)-1:0]               rgn_size_size_fixed_int;
reg [(RESTORE_FC*1)-1:0]               rgn_size_mulnpo2_fixed_int;
reg [(RESTORE_FC*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_fixed_int;
reg [(RESTORE_FC*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_fixed_int;
reg [RESTORE_FC-1:0]                   rgn_tcfg01_fixed_rgn_int;
reg [RESTORE_FC-1:0]                   rgn_tcfg2_fixed_rgn_int;

reg [FC_INT_ST_WIDTH-1:0]  fc_int_st_rd_nxt;
reg [FC_INT_MSK_WIDTH-1:0] fc_int_msk_rd_nxt;

reg [REG_DATA_WIDTH-1:0] addr_dec_rd_data_nxt;

reg [READ_DATA_SIZE-1:0] addr_dec_reg_size_nxt;

reg [FC_NUM_RGN-1:0] rwe_ctrl_pow_2;
reg [TOTAL_FC-1:0] fw_num_fc_pow_2;
reg [TOTAL_FC-1:0] int_st_pow_2;
reg [TOTAL_FC-1:0] int_msk_pow_2;

wire ctlr_n_comp;

reg [REG_DATA_WIDTH-1:0] addr_dec_wr_data_nxt;

reg [REG_DATA_WIDTH-1:0] frmtd_rd_data_nxt;

wire [REG_DATA_WIDTH-1:0] unfrmt_rd_data;

wire [REG_ENUM_WIDTH-1:0] reg_enum_addr;

wire tamper;
wire tamper_rgn;
wire tamper_ld;
wire tamper_ld_st;
wire tamper_master_id;
wire tamper_fctlr;

reg                        dyn_chk_req_nxt;
reg [CHECK_TYPE_WIDTH-1:0] dyn_chk_req_type_nxt;

reg hit_nxt;

reg wr_rsp_pend_nxt;

reg fixed_nxt;

reg read_only_nxt;

wire [LOG2_SRAM_SIZE-1:0] sram_row_nxt;
reg [LOG2_SRAM_WIDTH-1:0] sram_col_nxt;

reg [LOG2_SRAM_SIZE-1:0]   addr_dec_add_op1_nxt;
reg [SRAM_OFFSET_SIZE-1:0] addr_dec_add_op1_nxt_int;
reg [LOG2_SRAM_SIZE-1:0]   addr_dec_add_op2_nxt;

reg [LOG2_SRAM_SIZE-1:0]   rgn_lctrl_add_op1;
reg [SRAM_OFFSET_SIZE-1:0] rgn_lctrl_add_op1_int;
reg [LOG2_SRAM_SIZE-1:0]   rgn_lctrl_add_op2;
reg [LOG2_SRAM_WIDTH-1:0]  rgn_lctrl_sram_col;

reg [LOG2_SRAM_SIZE-1:0]   rgn_ctrl0_add_op1;
reg [SRAM_OFFSET_SIZE-1:0] rgn_ctrl0_add_op1_int;
reg [LOG2_SRAM_SIZE-1:0]   rgn_ctrl0_add_op2;
reg [LOG2_SRAM_WIDTH-1:0]  rgn_ctrl0_sram_col;

reg [LOG2_SRAM_SIZE-1:0]   rgn_ctrl1_add_op1;
reg [SRAM_OFFSET_SIZE-1:0] rgn_ctrl1_add_op1_int;
reg [LOG2_SRAM_SIZE-1:0]   rgn_ctrl1_add_op2;
reg [LOG2_SRAM_WIDTH-1:0]  rgn_ctrl1_sram_col;

reg [REG_DATA_WIDTH-1:0] write_msk_nxt;

wire comp_discon;
wire sre1_raz_addr;
wire sre1_raz_case;
wire rgn_st_shdw_hit;

wire [LD_CTRL_WIDTH-1:0] ld_ctrl_fc;
wire ldi_st;

wire mpe_en;
wire write_allowed_fctlr;

integer i;
genvar  wr_msk_idx;
integer num_fc_idx;
integer int_st_idx;
integer int_msk_idx;
integer fix_fw_idx;
integer fix_rgn_idx;


generate
  if (FW_SRE_LVL == 1 && FW_LDE_LVL > 0) begin : LD_CTRL_CTLR
    assign ctlr_n_comp = (addr_dec_fw_id_i == {FW_ID_WIDTH{1'b0}}) ||
      (reg_enum_addr == ONE_DEC<<LD_CTRL_ONE_HOT);
  end
  else begin: LD_CTRL_COMP
    assign ctlr_n_comp = addr_dec_fw_id_i == {FW_ID_WIDTH{1'b0}};
  end
endgenerate



always @* begin
  rwe_ctrl_pow_2 = {FC_NUM_RGN{1'b0}};
  for (i=0; i<FC_NUM_RGN; i=i+1) begin
    if (rwe_ctrl_i == i) begin
      rwe_ctrl_pow_2[i] = 1'b1;
    end
  end

  fw_num_fc_pow_2 = {TOTAL_FC{1'b0}};
  for (num_fc_idx=0; num_fc_idx<TOTAL_FC; num_fc_idx=num_fc_idx+1) begin
    if (addr_dec_fw_id_i == num_fc_idx) begin
      fw_num_fc_pow_2[num_fc_idx] = 1'b1;
    end
  end

  int_st_pow_2 = {TOTAL_FC{1'b0}};
  for (int_st_idx=0; int_st_idx<TOTAL_FC; int_st_idx=int_st_idx+1) begin
    if (reg_enum_addr[int_st_idx+FC0_INT_ST_ONE_HOT]) begin
      int_st_pow_2[int_st_idx] = 1'b1;
    end
  end

  int_msk_pow_2 = {TOTAL_FC{1'b0}};
  for (int_msk_idx=0; int_msk_idx<TOTAL_FC; int_msk_idx=int_msk_idx+1) begin
    if (reg_enum_addr[int_msk_idx+FC0_INT_MSK_ONE_HOT]) begin
      int_msk_pow_2[int_msk_idx] = 1'b1;
    end
  end

end

assign unfrmt_rd_data = addr_dec_unfrmt_rd_data_i;

generate
  if (FW_SRE_LVL==0) begin: NO_REMAP_GENBLK
    assign reg_enum_addr  = addr_dec_reg_enum_addr_i;
    assign rgn_st_shdw_hit = 1'b0;

  end
  else begin: REMAP_GENBLK
    reg [REG_ENUM_WIDTH-1:0] rmp_addr;
    reg rgn_st_shdw_hit_int;

    always @(*) begin: REMAP_ADDR

      rmp_addr = addr_dec_reg_enum_addr_i;
      rgn_st_shdw_hit_int = 1'b0;

      if (comp_discon && !addr_dec_rw_i) begin
        if (addr_dec_reg_enum_addr_i[PE_ST_ONE_HOT]==1'b1) begin
          rmp_addr = {REG_ENUM_WIDTH{1'b0}};
          rmp_addr[PE_CTRL_ONE_HOT] = 1'b1;
        end
        else if (addr_dec_reg_enum_addr_i[ME_ST_ONE_HOT]==1'b1) begin
          rmp_addr = {REG_ENUM_WIDTH{1'b0}};
          rmp_addr[ME_CTRL_ONE_HOT] = 1'b1;
        end
        else if (addr_dec_reg_enum_addr_i[RGN_ST_ONE_HOT]==1'b1) begin
          rgn_st_shdw_hit_int = 1'b1;
        end
      end
    end

    assign reg_enum_addr   = rmp_addr;
    assign rgn_st_shdw_hit = rgn_st_shdw_hit_int;

  end
endgenerate

assign addr_dec_rd_rgn_st_o =
  (comp_discon && addr_dec_reg_enum_addr_i[RGN_ST_ONE_HOT]) ? 1'b1 : 1'b0;


assign fw_ctrl_en_reg_nxt       = reg_enum_addr[FW_CTRL_ONE_HOT];
assign fw_sr_ctrl_en_reg_nxt    = reg_enum_addr[FW_SR_CTRL_ONE_HOT];
assign ld_ctrl_en_reg_nxt       = reg_enum_addr[LD_CTRL_ONE_HOT] ?
  fw_num_fc_pow_2[TOTAL_FC-1:0] & {{(TOTAL_FC-1){FW_SRE_LVL[0]}}, 1'b1} :
  {TOTAL_FC{1'b0}};
assign pe_ctrl_en_reg_nxt       = reg_enum_addr[PE_CTRL_ONE_HOT];
assign rwe_ctrl_en_reg_nxt      = reg_enum_addr[RWE_CTRL_ONE_HOT];
assign rgn_ctrl0_en_reg_nxt     = reg_enum_addr[RGN_CTRL0_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_ctrl1_en_reg_nxt     = reg_enum_addr[RGN_CTRL1_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_lctrl_en_reg_nxt     = reg_enum_addr[RGN_LCTRL_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_cfg0_en_reg_nxt      = reg_enum_addr[RGN_CFG0_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_cfg1_en_reg_nxt      = reg_enum_addr[RGN_CFG1_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_size_en_reg_nxt      = reg_enum_addr[RGN_SIZE_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg0_en_reg_nxt     = reg_enum_addr[RGN_TCFG0_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg1_en_reg_nxt     = reg_enum_addr[RGN_TCFG1_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_tcfg2_en_reg_nxt     = reg_enum_addr[RGN_TCFG2_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid0_en_reg_nxt      = reg_enum_addr[RGN_MID0_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid1_en_reg_nxt      = reg_enum_addr[RGN_MID1_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid2_en_reg_nxt      = reg_enum_addr[RGN_MID2_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mid3_en_reg_nxt      = reg_enum_addr[RGN_MID3_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl0_en_reg_nxt      = reg_enum_addr[RGN_MPL0_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl1_en_reg_nxt      = reg_enum_addr[RGN_MPL1_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl2_en_reg_nxt      = reg_enum_addr[RGN_MPL2_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign rgn_mpl3_en_reg_nxt      = reg_enum_addr[RGN_MPL3_ONE_HOT] ?
  rwe_ctrl_pow_2[FC_NUM_RGN-1:0] : {FC_NUM_RGN{1'b0}};
assign fe_ctrl_en_reg_nxt       = reg_enum_addr[FE_CTRL_ONE_HOT];
assign me_ctrl_en_reg_nxt       = reg_enum_addr[ME_CTRL_ONE_HOT];
assign edr_ctrl_en_reg_nxt      = reg_enum_addr[EDR_CTRL_ONE_HOT];
assign fc_int_st_en_reg_nxt     = {{REG_DATA_WIDTH-TOTAL_FC{1'b0}},
  int_st_pow_2[TOTAL_FC-1:0]};
assign fc_int_msk_en_reg_nxt    = {{REG_DATA_WIDTH-TOTAL_FC{1'b0}},
  int_msk_pow_2[TOTAL_FC-1:0]};
assign fw_tmp_ctrl_en_reg_nxt   = reg_enum_addr[FW_TMP_CTRL_ONE_HOT];
assign shdw_rwe_ctrl_en_reg_nxt = reg_enum_addr[RWE_CTRL_ONE_HOT] &&
  FW_SRE_LVL[0] ? fw_num_fc_pow_2[TOTAL_FC-1:1] : {FW_NUM_FC{1'b0}};


assign fw_ctrl_wr_reg_nxt       = addr_dec_wr_data_nxt[FW_CTRL_WIDTH-1:0];
assign fw_sr_ctrl_wr_reg_nxt    = addr_dec_wr_data_nxt[FW_SR_CTRL_WIDTH-1:0];
assign ld_ctrl_wr_reg_nxt       = {TOTAL_FC{addr_dec_wr_data_nxt[LD_CTRL_WIDTH-1:0]}};
assign pe_ctrl_wr_reg_nxt       = addr_dec_wr_data_nxt[PE_CTRL_WIDTH-1:0];
assign rwe_ctrl_wr_reg_nxt      = addr_dec_wr_data_nxt[RWE_CTRL_WIDTH-1:0];
assign rgn_ctrl0_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_CTRL0_WIDTH-1:0]}};
assign rgn_ctrl1_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_CTRL1_WIDTH-1:0]}};
assign rgn_lctrl_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_LCTRL_WIDTH-1:0]}};
assign rgn_cfg0_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_CFG0_WIDTH-1:0]}};
assign rgn_cfg1_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_CFG1_WIDTH-1:0]}};
assign rgn_size_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_SIZE_WIDTH-1:0]}};
assign rgn_tcfg0_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_TCFG0_WIDTH-1:0]}};
assign rgn_tcfg1_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_TCFG1_WIDTH-1:0]}};
assign rgn_tcfg2_wr_reg_nxt     = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_TCFG2_WIDTH-1:0]}};
assign rgn_mid0_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[FC_MST_ID_WIDTH-1:0]}};
assign rgn_mid1_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[FC_MST_ID_WIDTH-1:0]}};
assign rgn_mid2_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[FC_MST_ID_WIDTH-1:0]}};
assign rgn_mid3_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[FC_MST_ID_WIDTH-1:0]}};
assign rgn_mpl0_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_MPL0_WIDTH-1:0]}};
assign rgn_mpl1_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_MPL1_WIDTH-1:0]}};
assign rgn_mpl2_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_MPL2_WIDTH-1:0]}};
assign rgn_mpl3_wr_reg_nxt      = {FC_NUM_RGN{addr_dec_wr_data_nxt[RGN_MPL3_WIDTH-1:0]}};
assign fe_ctrl_wr_reg_nxt       = addr_dec_wr_data_nxt[FE_CTRL_WIDTH-1:0];
assign me_ctrl_wr_reg_nxt       = addr_dec_wr_data_nxt[ME_CTRL_WIDTH-1:0];
assign edr_ctrl_wr_reg_nxt      = addr_dec_wr_data_nxt[EDR_CTRL_WIDTH-1:0];
assign fc_int_st_wr_reg_nxt     = {32{addr_dec_wr_data_nxt[FC_INT_ST_WIDTH-1:0]}};
assign fc_int_msk_wr_reg_nxt    = {32{addr_dec_wr_data_nxt[FC_INT_MSK_WIDTH-1:0]}};
assign fw_tmp_ctrl_wr_reg_nxt   = addr_dec_wr_data_nxt[FW_TMP_CTRL_WIDTH-1:0];
assign shdw_rwe_ctrl_wr_reg_nxt = addr_dec_wr_data_nxt[RWE_CTRL_WIDTH-1:0];


always @* begin

  rgn_cfg0_fixed_int         = {RESTORE_FC*RGN_CFG0_WIDTH{1'b0}};
  rgn_cfg1_fixed_int         = {RESTORE_FC*RGN_CFG1_WIDTH{1'b0}};
  rgn_size_size_fixed_int    = {RESTORE_FC*8{1'b0}};
  rgn_size_mulnpo2_fixed_int = {RESTORE_FC*1{1'b0}};
  rgn_tcfg0_fixed_int        = {RESTORE_FC*RGN_TCFG0_WIDTH{1'b0}};
  rgn_tcfg1_fixed_int        = {RESTORE_FC*RGN_TCFG1_WIDTH{1'b0}};
  rgn_tcfg01_fixed_rgn_int   = {RESTORE_FC{1'b0}};
  rgn_tcfg2_fixed_rgn_int    = {RESTORE_FC{1'b0}};

  for (fix_fw_idx=0; fix_fw_idx<RESTORE_FC; fix_fw_idx=fix_fw_idx+1) begin
    for (fix_rgn_idx=0; fix_rgn_idx<MAX_NUM_RGN; fix_rgn_idx=fix_rgn_idx+1) begin

      if (fix_rgn_idx == addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*(fix_fw_idx+1))-1 -: RWE_CTRL_WIDTH]) begin
        rgn_cfg0_fixed_int[(RGN_CFG0_WIDTH*(fix_fw_idx+1))-1 -: RGN_CFG0_WIDTH] =
          FC_RGN_BASE_ADDR_EXT[(fix_fw_idx*MAX_NUM_RGN)*64 + (fix_rgn_idx*64) + 5 +: RGN_CFG0_WIDTH];

        rgn_cfg1_fixed_int[(RGN_CFG1_WIDTH*(fix_fw_idx+1))-1 -: RGN_CFG1_WIDTH] =
          FC_RGN_BASE_ADDR_EXT[(fix_fw_idx*MAX_NUM_RGN)*64 + (fix_rgn_idx*64) + 32 +: RGN_CFG1_WIDTH];

        rgn_tcfg0_fixed_int[(RGN_TCFG0_WIDTH*(fix_fw_idx+1))-1 -: RGN_TCFG0_WIDTH] =
          FC_RGN_UPR_ADDR_EXT[(fix_fw_idx*MAX_NUM_RGN)*64 + (fix_rgn_idx*64) + 5 +: RGN_TCFG0_WIDTH];

        rgn_tcfg1_fixed_int[(RGN_TCFG1_WIDTH*(fix_fw_idx+1))-1 -: RGN_TCFG1_WIDTH] =
          FC_RGN_UPR_ADDR_EXT[(fix_fw_idx*MAX_NUM_RGN)*64 + (fix_rgn_idx*64) + 32 +: RGN_TCFG1_WIDTH];

        rgn_size_size_fixed_int[(8*(fix_fw_idx+1))-1 -: 8] =
          FC_RGN_SIZE_EXT[(fix_fw_idx*MAX_NUM_RGN)*8 + (fix_rgn_idx*8) +: 8];

        rgn_size_mulnpo2_fixed_int[((fix_fw_idx+1))-1 -: 1] =
          FC_RGN_MULNPO2_EXT[(fix_fw_idx*MAX_NUM_RGN) + (fix_rgn_idx) +: 1];

        rgn_tcfg01_fixed_rgn_int[fix_fw_idx] =
          RGN_TCFG01_FIXED_RGN[(fix_fw_idx*MAX_NUM_RGN) + fix_rgn_idx];

        rgn_tcfg2_fixed_rgn_int[fix_fw_idx] =
          RGN_TCFG2_FIXED_RGN[(fix_fw_idx*MAX_NUM_RGN) + fix_rgn_idx];
      end

    end

  end
end


always @* begin
  case (reg_enum_addr)
    (ONE_DEC<<FC0_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[0 +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC1_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC2_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[2*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC3_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[3*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC4_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[4*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC5_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[5*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC6_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[6*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC7_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[7*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC8_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[8*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC9_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[9*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC10_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[10*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC11_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[11*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC12_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[12*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC13_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[13*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC14_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[14*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC15_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[15*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC16_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[16*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC17_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[17*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC18_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[18*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC19_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[19*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC20_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[20*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC21_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[21*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC22_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[22*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC23_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[23*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC24_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[24*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC25_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[25*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC26_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[26*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC27_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[27*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC28_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[28*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC29_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[29*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC30_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[30*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    (ONE_DEC<<FC31_INT_ST_ONE_HOT): begin
      fc_int_st_rd_nxt = fc_int_st_i[31*FC_INT_ST_WIDTH +: FC_INT_ST_WIDTH];
    end
    default: begin
      fc_int_st_rd_nxt = {FC_INT_ST_WIDTH{1'bx}};
    end
  endcase
end

always @* begin
  case (reg_enum_addr)
    (ONE_DEC<<FC0_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[0 +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC1_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC2_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[2*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC3_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[3*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC4_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[4*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC5_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[5*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC6_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[6*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC7_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[7*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC8_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[8*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC9_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[9*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC10_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[10*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC11_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[11*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC12_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[12*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC13_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[13*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC14_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[14*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC15_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[15*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC16_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[16*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC17_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[17*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC18_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[18*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC19_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[19*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC20_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[20*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC21_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[21*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC22_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[22*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC23_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[23*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC24_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[24*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC25_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[25*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC26_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[26*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC27_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[27*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC28_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[28*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC29_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[29*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC30_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[30*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    (ONE_DEC<<FC31_INT_MSK_ONE_HOT): begin
      fc_int_msk_rd_nxt = fc_int_msk_i[31*FC_INT_MSK_WIDTH +: FC_INT_MSK_WIDTH];
    end
    default: begin
      fc_int_msk_rd_nxt = {FC_INT_MSK_WIDTH{1'bx}};
    end
  endcase
end


always @* begin : ADDR_DEC_SRAM_ROW_COL

  integer idx;

  rgn_lctrl_add_op1     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_lctrl_add_op1_int = {SRAM_OFFSET_SIZE{1'b0}};
  rgn_lctrl_add_op2     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_lctrl_sram_col    = {LOG2_SRAM_WIDTH{1'b0}};

  for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
    if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_LCTRL_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
      rgn_lctrl_add_op1_int =
        RGN_LCTRL_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
        SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
      rgn_lctrl_add_op1 = rgn_lctrl_add_op1_int[LOG2_SRAM_SIZE-1:0];
      rgn_lctrl_add_op2 = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_LCTRL_RGN){1'b0}},
        addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_LCTRL_RGN +: MAX_RWE_SRAM-RGN_LCTRL_RGN]};
      rgn_lctrl_sram_col = (RGN_LCTRL_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} :
        addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_LCTRL_RGN_COL];
    end
  end

  rgn_ctrl0_add_op1     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_ctrl0_add_op1_int = {SRAM_OFFSET_SIZE{1'b0}};
  rgn_ctrl0_add_op2     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_ctrl0_sram_col    = {LOG2_SRAM_WIDTH{1'b0}};

  for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
    if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_CTRL0_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
      rgn_ctrl0_add_op1_int =
        RGN_CTRL0_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
        SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
      rgn_ctrl0_add_op1 = rgn_ctrl0_add_op1_int[LOG2_SRAM_SIZE-1:0];
      rgn_ctrl0_add_op2 = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_CTRL0_RGN){1'b0}},
        addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_CTRL0_RGN +: MAX_RWE_SRAM-RGN_CTRL0_RGN]};
      rgn_ctrl0_sram_col = (RGN_CTRL0_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} :
        addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_CTRL0_RGN_COL];
    end
  end

  rgn_ctrl1_add_op1     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_ctrl1_add_op1_int = {SRAM_OFFSET_SIZE{1'b0}};
  rgn_ctrl1_add_op2     = {LOG2_SRAM_SIZE{1'b0}};
  rgn_ctrl1_sram_col    = {LOG2_SRAM_WIDTH{1'b0}};

  for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
    if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_CTRL1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
      rgn_ctrl1_add_op1_int =
        RGN_CTRL1_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
        SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
      rgn_ctrl1_add_op1 = rgn_ctrl1_add_op1_int[LOG2_SRAM_SIZE-1:0];
      rgn_ctrl1_add_op2 = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_CTRL1_RGN){1'b0}},
        addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_CTRL1_RGN +: MAX_RWE_SRAM-RGN_CTRL1_RGN]};
      rgn_ctrl1_sram_col = (RGN_CTRL1_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_CTRL1_RGN_COL{1'b0}},
        addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_CTRL1_RGN_COL]};
    end
  end

end

assign addr_dec_shdw_rgn_lctrl_op1_o = rgn_lctrl_add_op1;
assign addr_dec_shdw_rgn_lctrl_op2_o = rgn_lctrl_add_op2;
assign addr_dec_shdw_rgn_lctrl_col_o = rgn_lctrl_sram_col;
assign addr_dec_shdw_rgn_ctrl0_op1_o = rgn_ctrl0_add_op1;
assign addr_dec_shdw_rgn_ctrl0_op2_o = rgn_ctrl0_add_op2;
assign addr_dec_shdw_rgn_ctrl0_col_o = rgn_ctrl0_sram_col;
assign addr_dec_shdw_rgn_ctrl1_op1_o = rgn_ctrl1_add_op1;
assign addr_dec_shdw_rgn_ctrl1_op2_o = rgn_ctrl1_add_op2;
assign addr_dec_shdw_rgn_ctrl1_col_o = rgn_ctrl1_sram_col;


always @* begin : ADDR_DEC_MUX

  integer idx;
  addr_dec_add_op1_nxt_int = {SRAM_OFFSET_SIZE{1'b0}};

  case (reg_enum_addr)
    (ONE_DEC<<FW_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_CTRL_WIDTH{1'b0}}, fw_ctrl_i};
      addr_dec_reg_size_nxt = FW_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {{(REG_DATA_WIDTH-FW_CTRL_WIDTH){1'b0}},
                              unfrmt_rd_data[FW_CTRL_WIDTH-1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<FW_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_ST_WIDTH{1'b0}}, fw_st_i};
      addr_dec_reg_size_nxt = FW_ST_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {{(REG_DATA_WIDTH-FW_ST_WIDTH){1'b0}},
                              unfrmt_rd_data[1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FW_SR_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_SR_CTRL_WIDTH{1'b0}}, fw_sr_ctrl_i};
      addr_dec_reg_size_nxt = FW_SR_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {unfrmt_rd_data[1],
                              {(REG_DATA_WIDTH-FW_SR_CTRL_WIDTH){1'b0}},
                              unfrmt_rd_data[0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt         = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<FW_TMP_TA_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_TMP_TA_WIDTH{1'b0}}, fw_tmp_ta_i};
      addr_dec_reg_size_nxt = FW_TMP_TA_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {11'b0, unfrmt_rd_data[FW_TMP_TA_WIDTH-1:0], 2'b0};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FW_TMP_TP_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_TMP_TP_WIDTH{1'b0}}, fw_tmp_tp_i};
      addr_dec_reg_size_nxt = FW_TMP_TP_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {12'b0, unfrmt_rd_data[2], 1'b0,
                              unfrmt_rd_data[1:0], 16'b0};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FW_TMP_MID_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, fw_tmp_mid_i};
      addr_dec_reg_size_nxt = FC_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
        {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, {FC_MST_ID_WIDTH{1'b1}}};
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FW_TMP_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FW_TMP_CTRL_WIDTH{1'b0}}, fw_tmp_ctrl_i};
      addr_dec_reg_size_nxt = FW_TMP_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-FW_TMP_CTRL_WIDTH{1'b0}},
                              addr_dec_wr_data_i[31:30],
                              addr_dec_wr_data_i[0]};
      frmtd_rd_data_nxt     = {unfrmt_rd_data[2:1],
                              {REG_DATA_WIDTH-FW_TMP_CTRL_WIDTH{1'b0}},
                              unfrmt_rd_data[0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<FC0_INT_ST_ONE_HOT), (ONE_DEC<<FC1_INT_ST_ONE_HOT),
    (ONE_DEC<<FC2_INT_ST_ONE_HOT), (ONE_DEC<<FC3_INT_ST_ONE_HOT),
    (ONE_DEC<<FC4_INT_ST_ONE_HOT), (ONE_DEC<<FC5_INT_ST_ONE_HOT),
    (ONE_DEC<<FC6_INT_ST_ONE_HOT), (ONE_DEC<<FC7_INT_ST_ONE_HOT),
    (ONE_DEC<<FC8_INT_ST_ONE_HOT), (ONE_DEC<<FC9_INT_ST_ONE_HOT),
    (ONE_DEC<<FC10_INT_ST_ONE_HOT), (ONE_DEC<<FC11_INT_ST_ONE_HOT),
    (ONE_DEC<<FC12_INT_ST_ONE_HOT), (ONE_DEC<<FC13_INT_ST_ONE_HOT),
    (ONE_DEC<<FC14_INT_ST_ONE_HOT), (ONE_DEC<<FC15_INT_ST_ONE_HOT),
    (ONE_DEC<<FC16_INT_ST_ONE_HOT), (ONE_DEC<<FC17_INT_ST_ONE_HOT),
    (ONE_DEC<<FC18_INT_ST_ONE_HOT), (ONE_DEC<<FC19_INT_ST_ONE_HOT),
    (ONE_DEC<<FC20_INT_ST_ONE_HOT), (ONE_DEC<<FC21_INT_ST_ONE_HOT),
    (ONE_DEC<<FC22_INT_ST_ONE_HOT), (ONE_DEC<<FC23_INT_ST_ONE_HOT),
    (ONE_DEC<<FC24_INT_ST_ONE_HOT), (ONE_DEC<<FC25_INT_ST_ONE_HOT),
    (ONE_DEC<<FC26_INT_ST_ONE_HOT), (ONE_DEC<<FC27_INT_ST_ONE_HOT),
    (ONE_DEC<<FC28_INT_ST_ONE_HOT), (ONE_DEC<<FC29_INT_ST_ONE_HOT),
    (ONE_DEC<<FC30_INT_ST_ONE_HOT), (ONE_DEC<<FC31_INT_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_INT_ST_WIDTH{1'b0}},
                               fc_int_st_rd_nxt};
      addr_dec_reg_size_nxt = FW_INT_ST_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {{(REG_DATA_WIDTH-FC_INT_ST_WIDTH){1'b0}},
                              unfrmt_rd_data[FC_INT_ST_WIDTH-1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<FC0_INT_MSK_ONE_HOT), (ONE_DEC<<FC1_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC2_INT_MSK_ONE_HOT), (ONE_DEC<<FC3_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC4_INT_MSK_ONE_HOT), (ONE_DEC<<FC5_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC6_INT_MSK_ONE_HOT), (ONE_DEC<<FC7_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC8_INT_MSK_ONE_HOT), (ONE_DEC<<FC9_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC10_INT_MSK_ONE_HOT), (ONE_DEC<<FC11_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC12_INT_MSK_ONE_HOT), (ONE_DEC<<FC13_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC14_INT_MSK_ONE_HOT), (ONE_DEC<<FC15_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC16_INT_MSK_ONE_HOT), (ONE_DEC<<FC17_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC18_INT_MSK_ONE_HOT), (ONE_DEC<<FC19_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC20_INT_MSK_ONE_HOT), (ONE_DEC<<FC21_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC22_INT_MSK_ONE_HOT), (ONE_DEC<<FC23_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC24_INT_MSK_ONE_HOT), (ONE_DEC<<FC25_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC26_INT_MSK_ONE_HOT), (ONE_DEC<<FC27_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC28_INT_MSK_ONE_HOT), (ONE_DEC<<FC29_INT_MSK_ONE_HOT),
    (ONE_DEC<<FC30_INT_MSK_ONE_HOT), (ONE_DEC<<FC31_INT_MSK_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_INT_MSK_WIDTH{1'b0}},
                               fc_int_msk_rd_nxt};
      addr_dec_reg_size_nxt = FC_INT_MSK_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {{(REG_DATA_WIDTH-FC_INT_MSK_WIDTH){1'b0}},
                              unfrmt_rd_data[FC_INT_MSK_WIDTH-1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<FW_INT_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = fw_int_st_i;
      addr_dec_reg_size_nxt = FW_INT_ST_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = unfrmt_rd_data[FW_INT_ST_WIDTH-1:0];
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<LD_CTRL_ONE_HOT): begin
      addr_dec_reg_size_nxt = LD_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  =
        (((addr_dec_wr_data_i[1:0] == 2'b10) && (FW_LDE_LVL == 1)) ||
        (addr_dec_wr_data_i[1:0] == 2'b01)) ?
        {29'b0, ld_ctrl_i[2], 2'b00} :
        {29'b0, ld_ctrl_i[2], addr_dec_wr_data_i[1:0]};
      frmtd_rd_data_nxt     = {{(REG_DATA_WIDTH-LD_CTRL_WIDTH){1'b0}},
                              unfrmt_rd_data[LD_CTRL_WIDTH-1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_FW_LOCK;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      addr_dec_rd_data_nxt  = {REG_DATA_WIDTH{1'b0}};
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
      for (idx=0; idx<TOTAL_FC; idx=idx+1) begin
        if ((idx == addr_dec_fw_id_i) && LD_CTRL_EXISTS[0] && (FW_SRE_LVL == 1)) begin
          addr_dec_rd_data_nxt = {{REG_DATA_WIDTH-LD_CTRL_WIDTH{1'b0}},
            ld_ctrl_i[((idx+1)*LD_CTRL_WIDTH)-1 -: LD_CTRL_WIDTH]};
        end
        else if (LD_CTRL_EXISTS[0] && (FW_SRE_LVL == 0)) begin
          addr_dec_rd_data_nxt = {{REG_DATA_WIDTH-LD_CTRL_WIDTH{1'b0}},
            ld_ctrl_i[LD_CTRL_WIDTH-1:0]};
        end
      end

    end
    (ONE_DEC<<PE_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-PE_CTRL_WIDTH{1'b0}}, pe_ctrl_i};
      addr_dec_reg_size_nxt = PE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-PE_CTRL_WIDTH){1'b0}},
                              addr_dec_wr_data_i[31],
                              addr_dec_wr_data_i[5:0]};
      frmtd_rd_data_nxt     = {unfrmt_rd_data[6],
                              {(REG_DATA_WIDTH-PE_CTRL_WIDTH){1'b0}},
                              unfrmt_rd_data[5:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && PE_CTRL_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int = PE_CTRL_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
        end
      end
      for (idx=1; idx<TOTAL_FC; idx=idx+1) begin
        if ((idx == addr_dec_fw_id_i) && PE_CTRL_EXISTS[idx-N_MEM_RET]) begin
          addr_dec_wr_data_nxt[3:2] = (addr_dec_wr_data_i[3] == 1'b0) ?
            2'b10 : addr_dec_wr_data_i[3:2];
        end
      end
      if (ctlr_n_comp) begin
        addr_dec_wr_data_nxt[3:2] = (addr_dec_wr_data_i[3] == 1'b0) ?
          2'b10 : addr_dec_wr_data_i[3:2];
      end

    end
    (ONE_DEC<<PE_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-PE_ST_WIDTH{1'b0}}, pe_st_i};
      addr_dec_reg_size_nxt = PE_ST_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {unfrmt_rd_data[6],
                              {(REG_DATA_WIDTH-PE_ST_WIDTH){1'b0}},
                              unfrmt_rd_data[5:0]};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<PE_BPS_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-PE_BPS_WIDTH{1'b0}}, pe_bps_i};
      addr_dec_reg_size_nxt = PE_BPS_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {unfrmt_rd_data[2],
                              {(REG_DATA_WIDTH-PE_BPS_WIDTH){1'b0}},
                              unfrmt_rd_data[1:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<RWE_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RWE_CTRL_WIDTH{1'b0}}, rwe_ctrl_i};
      addr_dec_reg_size_nxt = RWE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RWE_CTRL_WIDTH{1'b0}},
                               unfrmt_rd_data[RWE_CTRL_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-RWE_CTRL_WIDTH){1'b0}},
                              addr_dec_wr_data_i[RWE_CTRL_WIDTH-1:0]};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RWE_CTRL_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RWE_CTRL_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_wr_data_nxt = {{(REG_DATA_WIDTH-RWE_CTRL_WIDTH){1'b0}},
            addr_dec_wr_data_i[RWE_CTRL_WIDTH-1:0]} &
            RWE_CTRL_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
        end
      end

    end
    (ONE_DEC<<RGN_CTRL0_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_CTRL0_WIDTH{1'b0}}, rgn_ctrl0_rgn_i};
      addr_dec_reg_size_nxt = RGN_CTRL0_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_CTRL0_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_CTRL0_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_RWE_EN;
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-RGN_CTRL0_WIDTH){1'b0}},
                               addr_dec_wr_data_i[RGN_CTRL0_WIDTH-1:0]};
      sram_col_nxt          = rgn_ctrl0_sram_col;
      addr_dec_add_op1_nxt  = rgn_ctrl0_add_op1;
      addr_dec_add_op2_nxt  = rgn_ctrl0_add_op2;
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

    end
    (ONE_DEC<<RGN_CTRL1_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_CTRL1_WIDTH{1'b0}}, rgn_ctrl1_rgn_i};
      addr_dec_reg_size_nxt = RGN_CTRL1_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_CTRL1_WIDTH-1{1'b0}},
                               unfrmt_rd_data[RGN_CTRL1_WIDTH-1:0], 1'b0};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_RWE_EN;
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-RGN_CTRL1_WIDTH){1'b0}},
                              addr_dec_wr_data_i[4:1]};
      sram_col_nxt          = rgn_ctrl1_sram_col;
      addr_dec_add_op1_nxt  = rgn_ctrl1_add_op1;
      addr_dec_add_op2_nxt  = rgn_ctrl1_add_op2;
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_CTRL1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_wr_data_nxt = {{(REG_DATA_WIDTH-RGN_CTRL1_WIDTH){1'b0}},
            addr_dec_wr_data_i[4:1]} &
            RGN_CTRL1_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
        end
      end

    end
    (ONE_DEC<<RGN_LCTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_LCTRL_WIDTH{1'b0}}, rgn_lctrl_rgn_i};
      addr_dec_reg_size_nxt = RGN_LCTRL_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_LCTRL_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_LCTRL_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? ld_ctrl_fc[1:0] != 2'b00 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_RWE_LOCK;
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-RGN_LCTRL_WIDTH){1'b0}},
                               addr_dec_wr_data_i[RGN_LCTRL_WIDTH-1:0]};
      sram_col_nxt          = rgn_lctrl_sram_col;
      addr_dec_add_op1_nxt  = rgn_lctrl_add_op1;
      addr_dec_add_op2_nxt  = rgn_lctrl_add_op2;
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

    end
    (ONE_DEC<<RGN_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_ST_WIDTH{1'b0}}, rgn_st_rgn_i};
      addr_dec_reg_size_nxt = RGN_ST_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_ST_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_ST_WIDTH-1:0]};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<RGN_CFG0_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_CFG0_WIDTH{1'b0}}, rgn_cfg0_rgn_i};
      addr_dec_reg_size_nxt = RGN_CFG0_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {unfrmt_rd_data[RGN_CFG0_WIDTH-1:0], 5'b0};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_CFG0_WIDTH{1'b0}},
                               addr_dec_wr_data_i[REG_DATA_WIDTH-1:5]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_CFG0_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_CFG0_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt[MAX_RWE_SRAM-RGN_CFG0_RGN-1:0] =
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_CFG0_RGN +: MAX_RWE_SRAM-RGN_CFG0_RGN];
          sram_col_nxt = (RGN_CFG0_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_CFG0_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_CFG0_RGN_COL]};
          addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_CFG0_WIDTH{1'b0}},
            addr_dec_wr_data_i[REG_DATA_WIDTH-1:5]} &
            RGN_CFG0_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if (RGN_CFG0_FIXED[idx]) begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = {rgn_cfg0_fixed_int[(RGN_CFG0_WIDTH*(idx+1))-1-:RGN_CFG0_WIDTH], 5'b0} & {RGN_CFG0_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH-5], 5'b0};
          end
          else if ((FC_PE_LVL_EXT[2*(idx+1)-1 -: 2] == 2) &&
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*(idx+1))-1 -: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}})
          begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = {REG_DATA_WIDTH{1'b0}};
          end
        end
      end

    end
    (ONE_DEC<<RGN_CFG1_ONE_HOT): begin
      addr_dec_rd_data_nxt  = rgn_cfg1_rgn_i;
      addr_dec_reg_size_nxt = RGN_CFG1_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = unfrmt_rd_data[RGN_CFG1_WIDTH-1:0];
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_CFG1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt =
            RGN_CFG1_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op2_nxt[MAX_RWE_SRAM-RGN_CFG1_RGN-1:0] =
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_CFG1_RGN +: MAX_RWE_SRAM-RGN_CFG1_RGN];
          sram_col_nxt = (RGN_CFG1_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_CFG1_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_CFG1_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_CFG1_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if (RGN_CFG1_FIXED[idx]) begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = rgn_cfg1_fixed_int[(RGN_CFG1_WIDTH*(idx+1))-1-:RGN_CFG1_WIDTH] & RGN_CFG1_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          end
          else if ((FC_PE_LVL_EXT[2*(idx+1)-1 -: 2] == 2) &&
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*(idx+1))-1 -: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}})
          begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = {REG_DATA_WIDTH{1'b0}};
          end
        end
      end

    end
    (ONE_DEC<<RGN_SIZE_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_SIZE_WIDTH{1'b0}}, rgn_size_rgn_i};
      addr_dec_reg_size_nxt = RGN_SIZE_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_SIZE_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_SIZE_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-9{1'b0}},
                               addr_dec_wr_data_i[8:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_SIZE_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_SIZE_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_SIZE_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_SIZE_RGN +: MAX_RWE_SRAM-RGN_SIZE_RGN]};
          sram_col_nxt = (RGN_SIZE_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_SIZE_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_SIZE_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_SIZE_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if (RGN_SIZE_FIXED[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-9{1'b0}},
              rgn_size_mulnpo2_fixed_int[((idx+1))-1-:1],
              rgn_size_size_fixed_int[(8*(idx+1))-1-:8]};
            fixed_nxt         = 1'b1;
          end
          else if (addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}}) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-RGN_SIZE_WIDTH{1'b0}},
              8'b0, prot_size_i[idx*8 +: 8]};
            fixed_nxt         = 1'b1;
          end
        end
      end

      for (idx=1; idx<TOTAL_FC; idx=idx+1) begin
        if ((idx == addr_dec_fw_id_i) && RGN_SIZE_EXISTS[idx-N_MEM_RET]) begin
          if (addr_dec_wr_data_nxt[7:0] > FC_MXRS_EXT[7*(idx-1) +: 7]) begin
            addr_dec_wr_data_nxt[7:0] = 8'b0;
          end
          else if (addr_dec_wr_data_nxt[7:0] < (FC_MNRS_EXT[7*(idx-1) +: 7] + 5)) begin
            addr_dec_wr_data_nxt[7:0] = 8'b0;
          end
        end
      end
      if (ctlr_n_comp) begin
        if (addr_dec_wr_data_nxt[7:0] > FC_MXRS) begin
          addr_dec_wr_data_nxt[7:0] = 8'b0;
        end
        else if (addr_dec_wr_data_nxt[7:0] < (FC_MNRS + 5)) begin
          addr_dec_wr_data_nxt[7:0] = 8'b0;
        end
      end
      if (addr_dec_wr_data_nxt[7:0] > 8'h40) begin
        addr_dec_wr_data_nxt[7:0] = 8'b0;
      end

    end
    (ONE_DEC<<RGN_TCFG0_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_TCFG0_WIDTH{1'b0}}, rgn_tcfg0_rgn_i};
      addr_dec_reg_size_nxt = RGN_TCFG0_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {unfrmt_rd_data[RGN_TCFG0_WIDTH-1:0], 5'b0};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_TCFG0_WIDTH{1'b0}},
                               addr_dec_wr_data_i[REG_DATA_WIDTH-1:5]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_TCFG0_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_TCFG0_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt[MAX_RWE_SRAM-RGN_TCFG0_RGN-1:0] =
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_TCFG0_RGN +: MAX_RWE_SRAM-RGN_TCFG0_RGN];
          sram_col_nxt = (RGN_TCFG0_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_TCFG0_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_TCFG0_RGN_COL]};
          addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_TCFG0_WIDTH{1'b0}},
            addr_dec_wr_data_i[REG_DATA_WIDTH-1:5]} &
            RGN_CFG0_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if (rgn_tcfg01_fixed_rgn_int[idx]) begin
            frmtd_rd_data_nxt = {rgn_tcfg0_fixed_int[(RGN_TCFG0_WIDTH*(idx+1))-1-:RGN_TCFG0_WIDTH], 5'b0} & {RGN_CFG0_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH-5], 5'b0};
            fixed_nxt         = 1'b1;
          end
          else if ((FC_PE_LVL_EXT[2*(idx+1)-1 -: 2] == 2) &&
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*(idx+1))-1 -: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}})
          begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = {REG_DATA_WIDTH{1'b0}};
          end
        end
      end

    end
    (ONE_DEC<<RGN_TCFG1_ONE_HOT): begin
      addr_dec_rd_data_nxt  = rgn_tcfg1_rgn_i;
      addr_dec_reg_size_nxt = RGN_TCFG1_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = unfrmt_rd_data[RGN_TCFG1_WIDTH-1:0];
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_TCFG1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_TCFG1_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt[MAX_RWE_SRAM-RGN_TCFG1_RGN-1:0] =
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_TCFG1_RGN +: MAX_RWE_SRAM-RGN_TCFG1_RGN];
          sram_col_nxt = (RGN_TCFG1_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_TCFG1_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_TCFG1_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_CFG1_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if (rgn_tcfg01_fixed_rgn_int[idx]) begin
            frmtd_rd_data_nxt = rgn_tcfg1_fixed_int[(RGN_TCFG1_WIDTH*(idx+1))-1 -: RGN_TCFG1_WIDTH] & RGN_CFG1_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
            fixed_nxt         = 1'b1;
          end
          else if ((FC_PE_LVL_EXT[2*(idx+1)-1 -: 2] == 2) &&
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*(idx+1))-1 -: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}})
          begin
            fixed_nxt         = 1'b1;
            frmtd_rd_data_nxt = {REG_DATA_WIDTH{1'b0}};
          end
        end
      end

    end
    (ONE_DEC<<RGN_TCFG2_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_TCFG2_WIDTH{1'b0}}, rgn_tcfg2_rgn_i};
      addr_dec_reg_size_nxt = RGN_TCFG2_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_TCFG2_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_TCFG2_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_DATA;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_TCFG2_WIDTH{1'b0}},
                               addr_dec_wr_data_i[RGN_TCFG2_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_TCFG2_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_TCFG2_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt[MAX_RWE_SRAM-RGN_TCFG2_RGN-1:0] =
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_TCFG2_RGN +: MAX_RWE_SRAM-RGN_TCFG2_RGN];
          sram_col_nxt = (RGN_TCFG2_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_TCFG2_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_TCFG2_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_TCFG2_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          addr_dec_wr_data_nxt[3:2] = !FC_SH_SPT_RSTR[idx] ? 2'b01 : addr_dec_wr_data_nxt[3:2];
          if (rgn_tcfg2_fixed_rgn_int[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-3{1'b0}}, 1'b1, 2'b00};
            fixed_nxt         = 1'b1;
          end
          else if (addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RWE_CTRL_WIDTH] == {RWE_CTRL_WIDTH{1'b0}} &&
            FC_PE_LVL_EXT[2*(idx+1)-1 -: 2] == 2) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-RGN_TCFG2_WIDTH{1'b0}}, 1'b0,
                                 unfrmt_rd_data[RGN_TCFG2_WIDTH-2:0]};
          end
        end
      end

      addr_dec_wr_data_nxt[15:14] = (addr_dec_wr_data_i[15:14] == 2'b01) ? 2'b00 :
        addr_dec_wr_data_nxt[15:14];
      addr_dec_wr_data_nxt[13:12] = (addr_dec_wr_data_i[13:12] == 2'b01) ? 2'b00 :
        addr_dec_wr_data_nxt[13:12];
      addr_dec_wr_data_nxt[1:0] = (addr_dec_wr_data_i[1:0] == 2'b01) ? 2'b00 :
        addr_dec_wr_data_nxt[1:0];

    end
    (ONE_DEC<<RGN_MID0_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, rgn_mid0_rgn_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               unfrmt_rd_data[FW_MAX_MST_ID_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               addr_dec_wr_data_i[FW_MAX_MST_ID_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MID0_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MID0_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MID0_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MID0_RGN +: MAX_RWE_SRAM-RGN_MID0_RGN]};
          sram_col_nxt = (RGN_MID0_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MID0_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MID0_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            MID_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH];
          if ((idx+N_MEM_RET == addr_dec_fw_id_i) && FC_SINGLE_MST_RSTR[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
              FC_MST_ID_SINGLE_MST_EXT[(idx*32) +: FW_MAX_MST_ID_WIDTH]};
            fixed_nxt         = 1'b1;
          end
        end
      end

    end
    (ONE_DEC<<RGN_MID1_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, rgn_mid1_rgn_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               unfrmt_rd_data[FW_MAX_MST_ID_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               addr_dec_wr_data_i[FW_MAX_MST_ID_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MID1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MID1_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MID1_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MID1_RGN +: MAX_RWE_SRAM-RGN_MID1_RGN]};
          sram_col_nxt = (RGN_MID1_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MID1_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MID1_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            MID_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH];
          if ((idx+N_MEM_RET == addr_dec_fw_id_i) && FC_SINGLE_MST_RSTR[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
              FC_MST_ID_SINGLE_MST_EXT[(idx*32) +: FW_MAX_MST_ID_WIDTH]};
            fixed_nxt         = 1'b1;
          end
        end
      end

    end
    (ONE_DEC<<RGN_MID2_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, rgn_mid2_rgn_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               unfrmt_rd_data[FW_MAX_MST_ID_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               addr_dec_wr_data_i[FW_MAX_MST_ID_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MID2_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MID2_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MID2_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MID2_RGN +: MAX_RWE_SRAM-RGN_MID2_RGN]};
          sram_col_nxt = (RGN_MID2_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MID2_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MID2_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            MID_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH];
          if ((idx+N_MEM_RET == addr_dec_fw_id_i) && FC_SINGLE_MST_RSTR[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
              FC_MST_ID_SINGLE_MST_EXT[(idx*32) +: FW_MAX_MST_ID_WIDTH]};
            fixed_nxt         = 1'b1;
          end
        end
      end

    end
    (ONE_DEC<<RGN_MID3_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, rgn_mid3_rgn_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               unfrmt_rd_data[FW_MAX_MST_ID_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
                               addr_dec_wr_data_i[FW_MAX_MST_ID_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MID3_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MID3_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MID3_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MID3_RGN +: MAX_RWE_SRAM-RGN_MID3_RGN]};
          sram_col_nxt = (RGN_MID3_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MID3_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MID3_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            MID_MASK[REG_DATA_WIDTH*idx +: REG_DATA_WIDTH];
          if ((idx+N_MEM_RET == addr_dec_fw_id_i) && FC_SINGLE_MST_RSTR[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}},
              FC_MST_ID_SINGLE_MST_EXT[(idx*32) +: FW_MAX_MST_ID_WIDTH]};
            fixed_nxt         = 1'b1;
          end
        end
      end

    end
    (ONE_DEC<<RGN_MPL0_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL0_WIDTH{1'b0}}, rgn_mpl0_rgn_i};
      addr_dec_reg_size_nxt = RGN_MPL0_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_MPL0_WIDTH{1'b0}},
                               unfrmt_rd_data[RGN_MPL0_WIDTH-1:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL0_WIDTH{1'b0}},
                               addr_dec_wr_data_i[RGN_MPL0_WIDTH-1:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MPL0_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MPL0_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MPL0_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MPL0_RGN +: MAX_RWE_SRAM-RGN_MPL0_RGN]};
          sram_col_nxt = (RGN_MPL0_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MPL0_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MPL0_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_MPL0_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
          if ((idx+N_MEM_RET == addr_dec_fw_id_i) && FC_SINGLE_MST_RSTR[idx]) begin
            frmtd_rd_data_nxt = {{REG_DATA_WIDTH-RGN_MPL0_WIDTH{1'b0}}, 1'b0,
                                 unfrmt_rd_data[RGN_MPL0_WIDTH-2:0]};
          end
        end
      end

    end
    (ONE_DEC<<RGN_MPL1_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL1_WIDTH{1'b0}}, rgn_mpl1_rgn_i};
      addr_dec_reg_size_nxt = RGN_MPL1_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_MPL1_WIDTH{1'b0}}, 1'b0,
                               unfrmt_rd_data[RGN_MPL1_WIDTH-2:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL1_WIDTH{1'b0}}, 1'b0,
                               addr_dec_wr_data_i[RGN_MPL1_WIDTH-2:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MPL1_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MPL1_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MPL1_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MPL1_RGN +: MAX_RWE_SRAM-RGN_MPL1_RGN]};
          sram_col_nxt = (RGN_MPL1_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MPL1_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MPL1_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_MPL13_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
        end
      end

    end
    (ONE_DEC<<RGN_MPL2_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL2_WIDTH{1'b0}}, rgn_mpl2_rgn_i};
      addr_dec_reg_size_nxt = RGN_MPL2_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_MPL2_WIDTH{1'b0}}, 1'b0,
                               unfrmt_rd_data[RGN_MPL2_WIDTH-2:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL2_WIDTH{1'b0}}, 1'b0,
                               addr_dec_wr_data_i[RGN_MPL2_WIDTH-2:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MPL2_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MPL2_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MPL2_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MPL2_RGN +: MAX_RWE_SRAM-RGN_MPL2_RGN]};
          sram_col_nxt = (RGN_MPL2_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MPL2_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MPL2_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_MPL13_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
        end
      end

    end
    (ONE_DEC<<RGN_MPL3_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL3_WIDTH{1'b0}}, rgn_mpl3_rgn_i};
      addr_dec_reg_size_nxt = RGN_MPL3_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = {{REG_DATA_WIDTH-RGN_MPL3_WIDTH{1'b0}}, 1'b0,
                               unfrmt_rd_data[RGN_MPL3_WIDTH-2:0]};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = 1'b1;
      dyn_chk_req_type_nxt  = CHECK_RWE_MPL;
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-RGN_MPL3_WIDTH{1'b0}}, 1'b0,
                              addr_dec_wr_data_i[RGN_MPL3_WIDTH-2:0]};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;

      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && RGN_MPL3_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int =
            RGN_MPL3_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
          addr_dec_add_op2_nxt = {{LOG2_SRAM_SIZE-(MAX_RWE_SRAM-RGN_MPL3_RGN){1'b0}},
            addr_dec_shdw_rgn_i[(RWE_CTRL_WIDTH*idx) + RGN_MPL3_RGN +: MAX_RWE_SRAM-RGN_MPL3_RGN]};
          sram_col_nxt = (RGN_MPL3_RGN == 0) ? {LOG2_SRAM_WIDTH{1'b0}} : {{LOG2_SRAM_WIDTH-RGN_MPL3_RGN_COL{1'b0}},
            addr_dec_shdw_rgn_i[idx*RWE_CTRL_WIDTH +: RGN_MPL3_RGN_COL]};
          addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
            RGN_MPL13_MASK[REG_DATA_WIDTH*(idx+1)-1 -: REG_DATA_WIDTH];
        end
      end

    end
    (ONE_DEC<<FE_TAL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = fe_tal_i;
      addr_dec_reg_size_nxt = FE_TAL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FE_TAU_ONE_HOT): begin
      addr_dec_rd_data_nxt  = fe_tau_i;
      addr_dec_reg_size_nxt = FE_TAU_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FE_TP_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FE_TP_WIDTH{1'b0}}, fe_tp_i};
      addr_dec_reg_size_nxt = FE_TP_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {10'b0, unfrmt_rd_data[3], 2'b0,
                               unfrmt_rd_data[2:0], 16'b0};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<FE_MID_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, fe_mid_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
        {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}},{FC_MST_ID_WIDTH{1'b1}}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;

    end
    (ONE_DEC<<FE_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FE_CTRL_WIDTH{1'b0}}, fe_ctrl_i};
      addr_dec_reg_size_nxt = FE_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-FE_CTRL_WIDTH){1'b0}},
                               addr_dec_wr_data_i[31:30],
                               addr_dec_wr_data_i[3:0]};
      frmtd_rd_data_nxt     = {unfrmt_rd_data[5:4], 26'b0,
                               unfrmt_rd_data[3:0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    (ONE_DEC<<ME_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-ME_CTRL_WIDTH{1'b0}}, me_ctrl_i};
      addr_dec_reg_size_nxt = ME_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = {{(REG_DATA_WIDTH-ME_CTRL_WIDTH){1'b0}},
                              addr_dec_wr_data_i[31],
                              addr_dec_wr_data_i[4],
                              addr_dec_wr_data_i[1]};
      frmtd_rd_data_nxt     = {unfrmt_rd_data[2], 26'b0, unfrmt_rd_data[1],
                              2'b0, unfrmt_rd_data[0], 1'b0};
      hit_nxt               = (FW_SRE_LVL == 1) ? 1'b1 : 1'b0;
      dyn_chk_req_nxt       = (FW_LDE_LVL > 0) ? 1'b1 : 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      for (idx=0; idx<RESTORE_FC; idx=idx+1) begin
        if ((idx+N_MEM_RET == addr_dec_fw_id_i) && ME_CTRL_EXISTS[idx] && (FW_SRE_LVL == 1)) begin
          addr_dec_add_op1_nxt_int = ME_CTRL_START[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE] +
            SRAM_COMP_OFFSET[(SRAM_OFFSET_SIZE*(idx+1))-1 -: SRAM_OFFSET_SIZE];
          addr_dec_add_op1_nxt = addr_dec_add_op1_nxt_int[LOG2_SRAM_SIZE-1:0];
        end
      end

    end
    (ONE_DEC<<ME_ST_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-ME_ST_WIDTH{1'b0}}, me_st_i};
      addr_dec_reg_size_nxt = ME_ST_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {unfrmt_rd_data[2], 26'b0, unfrmt_rd_data[1],
                              2'b0, unfrmt_rd_data[0], 1'b0};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<EDR_TAL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = edr_tal_i;
      addr_dec_reg_size_nxt = EDR_TAL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<EDR_TAU_ONE_HOT): begin
      addr_dec_rd_data_nxt  = edr_tau_i;
      addr_dec_reg_size_nxt = EDR_TAU_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<EDR_TP_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-EDR_TP_WIDTH{1'b0}}, edr_tp_i};
      addr_dec_reg_size_nxt = EDR_TP_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i;
      frmtd_rd_data_nxt     = {10'b0, unfrmt_rd_data[3], 2'b0,
                              unfrmt_rd_data[2:0], 16'b0};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;
    end
    (ONE_DEC<<EDR_MID_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-FC_MST_ID_WIDTH{1'b0}}, edr_mid_i};
      addr_dec_reg_size_nxt = FW_MAX_MST_ID_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = addr_dec_wr_data_i &
        {{REG_DATA_WIDTH-FW_MAX_MST_ID_WIDTH{1'b0}}, {FW_MAX_MST_ID_WIDTH{1'b1}}};
      frmtd_rd_data_nxt     = unfrmt_rd_data;
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = CHECK_LDE;
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b1;

    end
    (ONE_DEC<<EDR_CTRL_ONE_HOT): begin
      addr_dec_rd_data_nxt  = {{REG_DATA_WIDTH-EDR_CTRL_WIDTH{1'b0}}, edr_ctrl_i};
      addr_dec_reg_size_nxt = EDR_CTRL_WIDTH[READ_DATA_SIZE-1:0];
      addr_dec_wr_data_nxt  = {{REG_DATA_WIDTH-EDR_CTRL_WIDTH{1'b0}},
                              addr_dec_wr_data_i[31:30],
                              addr_dec_wr_data_i[0]};
      frmtd_rd_data_nxt     = {unfrmt_rd_data[2:1],
                              {REG_DATA_WIDTH-EDR_CTRL_WIDTH{1'b0}},
                              unfrmt_rd_data[0]};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'b0}};
      hit_nxt               = 1'b0;
      dyn_chk_req_nxt       = 1'b0;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'b0}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'b0}};
      wr_rsp_pend_nxt       = 1'b0;
      fixed_nxt             = 1'b0;
      read_only_nxt         = 1'b0;
    end
    default: begin
      addr_dec_rd_data_nxt  = {REG_DATA_WIDTH{1'bx}};
      addr_dec_reg_size_nxt = {READ_DATA_SIZE{1'bx}};
      addr_dec_wr_data_nxt  = {REG_DATA_WIDTH{1'bx}};
      frmtd_rd_data_nxt     = {REG_DATA_WIDTH{1'bx}};
      addr_dec_add_op1_nxt  = {LOG2_SRAM_SIZE{1'bx}};
      addr_dec_add_op2_nxt  = {LOG2_SRAM_SIZE{1'bx}};
      hit_nxt               = 1'bx;
      dyn_chk_req_nxt       = 1'bx;
      dyn_chk_req_type_nxt  = {CHECK_TYPE_WIDTH{1'bx}};
      sram_col_nxt          = {LOG2_SRAM_WIDTH{1'bx}};
      wr_rsp_pend_nxt       = 1'bx;
      fixed_nxt             = 1'bx;
      read_only_nxt         = 1'bx;
    end
  endcase
end


generate
  if (FW_SRE_LVL == 1) begin : SRE_1_LDE
    reg [LD_CTRL_WIDTH-1:0] ld_ctrl_fc_int;
    integer fc_idx;

    always @* begin
      ld_ctrl_fc_int = {LD_CTRL_WIDTH{1'b0}};
      for (fc_idx=0; fc_idx<TOTAL_FC; fc_idx=fc_idx+1) begin
        if (addr_dec_fw_id_i == fc_idx) begin
          ld_ctrl_fc_int = ld_ctrl_i[fc_idx*LD_CTRL_WIDTH +: LD_CTRL_WIDTH];
        end
      end
    end

    assign ld_ctrl_fc = ld_ctrl_fc_int;
  end
  else begin: SRE_0_LDE
    assign ld_ctrl_fc = ld_ctrl_i[LD_CTRL_WIDTH-1:0];
  end
endgenerate


assign ldi_st = ld_ctrl_i[2];

generate

  if (FW_LDE_LVL == 1) begin : LDE_1_TAMP
    assign tamper_rgn = 1'b0;

    assign tamper_ld_st = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp
      && (dyn_chk_req_type_nxt == CHECK_FW_LOCK) && dyn_chk_req_nxt &&
      ((ld_ctrl_fc[1:0] == 2'b10) || (ld_ctrl_fc[1:0] == 2'b11)) &&
      ldi_st;

    assign tamper_ld = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp &&
      (((dyn_chk_req_type_nxt == CHECK_LDE) && dyn_chk_req_nxt &&
      ((ld_ctrl_fc[1:0] == 2'b10) || (ld_ctrl_fc[1:0] == 2'b11))) ||
      (((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      (ld_ctrl_fc[1:0] == 2'b11)));

    assign tamper_master_id = addr_dec_acc_valid_i && ctlr_n_comp &&
    (reg_enum_addr[FW_TMP_TA_ONE_HOT] || reg_enum_addr[FW_TMP_TP_ONE_HOT] ||
      reg_enum_addr[FW_TMP_MID_ONE_HOT] || reg_enum_addr[FW_TMP_CTRL_ONE_HOT])
      && ((addr_dec_mst_id_i != FW_CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0]) ||
      (!addr_dec_axprot_i[0] && (FC_PRIV_SPT == 1)) ||
      (addr_dec_axprot_i[1] && (FC_SEC_SPT > 0)));

    assign tamper_fctlr = tamper_rgn | tamper_ld_st | tamper_ld |
      tamper_master_id;
  end
  else if (FW_LDE_LVL == 2) begin : LDE_2_TAMP
    assign tamper_rgn = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp &&
      ((((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      rgn_lctrl_rgn_i[0]) ||
      ((dyn_chk_req_type_nxt == CHECK_RWE_LOCK) && dyn_chk_req_nxt &&
      (((ld_ctrl_fc[1:0] == 2'b10) && rgn_lctrl_rgn_i[0]) ||
      (ld_ctrl_fc[1:0] == 2'b11))));

    assign tamper_ld_st = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp
      && (dyn_chk_req_type_nxt == CHECK_FW_LOCK) && dyn_chk_req_nxt &&
      ((ld_ctrl_fc[1:0] == 2'b10) || (ld_ctrl_fc[1:0] == 2'b11)) &&
      ldi_st;

    assign tamper_ld = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp &&
      (((dyn_chk_req_type_nxt == CHECK_LDE) && dyn_chk_req_nxt &&
      ((ld_ctrl_fc[1:0] == 2'b10) || (ld_ctrl_fc[1:0] == 2'b11))) ||
      (((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN)) && dyn_chk_req_nxt &&
      (ld_ctrl_fc[1:0] == 2'b11)));

    assign tamper_master_id = addr_dec_acc_valid_i && ctlr_n_comp &&
    (reg_enum_addr[FW_TMP_TA_ONE_HOT] || reg_enum_addr[FW_TMP_TP_ONE_HOT] ||
      reg_enum_addr[FW_TMP_MID_ONE_HOT] || reg_enum_addr[FW_TMP_CTRL_ONE_HOT])
      && ((addr_dec_mst_id_i != FW_CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0]) ||
      (!addr_dec_axprot_i[0] && (FC_PRIV_SPT == 1)) ||
      (addr_dec_axprot_i[1] && (FC_SEC_SPT > 0)));

    assign tamper_fctlr = tamper_rgn | tamper_ld_st | tamper_ld |
      tamper_master_id;
  end
  else begin : LDE_0_TAMP
    assign tamper_rgn       = 1'b0;
    assign tamper_ld_st     = 1'b0;
    assign tamper_ld        = 1'b0;
    assign tamper_master_id = 1'b0;
    assign tamper_fctlr     = tamper_rgn | tamper_ld_st | tamper_ld |
      tamper_master_id;
  end

endgenerate


generate
  if (FW_SRE_LVL == 1 && FW_LDE_LVL > 0) begin : TAMP_GEN
    assign tamper = (dyn_chk_req_nxt && addr_dec_rw_i ||
      (addr_dec_acc_valid_i && tamper_master_id)) ?
      ((((dyn_chk_req_type_nxt == CHECK_RWE_DATA) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_MPL) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_EN) ||
      (dyn_chk_req_type_nxt == CHECK_RWE_LOCK)) &&
      (ld_ctrl_fc[1:0] == 2'b11)) ||
      ((dyn_chk_req_type_nxt == CHECK_LDE) && (ld_ctrl_fc[1] == 1'b1)) ||
      tamper_fctlr) : 1'b0;
  end
  else begin: NO_TAMP_GEN
    assign tamper = tamper_fctlr;
  end
endgenerate


assign mpe_en = (|rgn_mid0_en_reg_nxt && rgn_st_rgn_i[1]) ||
  (|rgn_mpl0_en_reg_nxt && rgn_st_rgn_i[1]) ||
  (|rgn_mid1_en_reg_nxt && rgn_st_rgn_i[2]) ||
  (|rgn_mpl1_en_reg_nxt && rgn_st_rgn_i[2]) ||
  (|rgn_mid2_en_reg_nxt && rgn_st_rgn_i[3]) ||
  (|rgn_mpl2_en_reg_nxt && rgn_st_rgn_i[3]) ||
  (|rgn_mid3_en_reg_nxt && rgn_st_rgn_i[4]) ||
  (|rgn_mpl3_en_reg_nxt && rgn_st_rgn_i[4]);

assign write_allowed_fctlr =
  (addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp) ?
  ((dyn_chk_req_type_nxt == CHECK_RWE_DATA) && dyn_chk_req_nxt) ?
  !rgn_st_rgn_i[0] :
  ((dyn_chk_req_type_nxt == CHECK_RWE_MPL) && dyn_chk_req_nxt) ?
  !mpe_en : 1'b1 : 1'b1;


generate
  if (FW_SRE_LVL == 1) begin : SRE_1
    assign comp_discon = (addr_dec_fw_id_i == {FW_ID_WIDTH{1'b0}}) ?
                           1'b0 : !addr_dec_pwr_st_i[addr_dec_fc_id_i];
    assign sre1_raz_addr = reg_enum_addr == (ONE_DEC<<EDR_CTRL_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<EDR_MID_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<EDR_TP_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<EDR_TAU_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<EDR_TAL_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<FE_CTRL_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<FE_MID_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<FE_TP_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<FE_TAU_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<FE_TAL_ONE_HOT) ||
                           reg_enum_addr == (ONE_DEC<<PE_BPS_ONE_HOT);
  end
  else begin: SRE_0
    assign comp_discon   = 1'b0;
    assign sre1_raz_addr = 1'b0;
  end
endgenerate

assign sre1_raz_case = (FW_SRE_LVL == 1) && comp_discon && sre1_raz_addr &&
                       !addr_dec_rw_i && !ctlr_n_comp;



assign addr_dec_rw_o = addr_dec_rw_i;
assign addr_dec_acc_valid_o = addr_dec_acc_valid_i;
assign addr_dec_reg_addr_o = addr_dec_reg_addr_i;
assign addr_dec_fw_id_o = addr_dec_fw_id_i;
assign addr_dec_fc_id_o = addr_dec_fc_id_i;


assign addr_dec_hit_o = addr_dec_acc_valid_i ? (hit_nxt | rgn_st_shdw_hit) : 1'b0;
assign addr_dec_hit_chk_need_o = dyn_chk_req_nxt;
assign addr_dec_hit_chk_type_o = dyn_chk_req_type_nxt;

assign addr_dec_sram_row_o = addr_dec_add_res_i;
assign addr_dec_sram_col_o = sram_col_nxt;

assign addr_dec_add_op1_o = addr_dec_add_op1_nxt;
assign addr_dec_add_op2_o = addr_dec_add_op2_nxt;
assign addr_dec_add_en_o  = addr_dec_cfg_active_i;


assign addr_dec_wr_data_o = addr_dec_wr_data_nxt;

assign addr_dec_wr_rsp_pend_o = wr_rsp_pend_nxt;

assign addr_dec_reg_size_o = addr_dec_reg_size_nxt;

assign addr_dec_reg_rd_data_o = sre1_raz_case ?
                                {REG_DATA_WIDTH{1'b0}} : addr_dec_rd_data_nxt;


assign reg_en_nxt = addr_dec_acc_valid_i && addr_dec_rw_i && ctlr_n_comp;

assign fw_ctrl_en = reg_en_nxt && fw_ctrl_en_reg_nxt;
assign fw_ctrl_o  = fw_ctrl_wr_reg_nxt;

assign fw_sr_ctrl_en = reg_en_nxt && fw_sr_ctrl_en_reg_nxt;
assign fw_sr_ctrl_o  = fw_sr_ctrl_wr_reg_nxt;

assign ld_ctrl_en = {TOTAL_FC{reg_en_nxt}} & ld_ctrl_en_reg_nxt;
assign ld_ctrl_o  = ld_ctrl_wr_reg_nxt;

assign pe_ctrl_en = reg_en_nxt && pe_ctrl_en_reg_nxt;
assign pe_ctrl_o  = pe_ctrl_wr_reg_nxt;

assign rwe_ctrl_en = reg_en_nxt && rwe_ctrl_en_reg_nxt;
assign rwe_ctrl_o  = rwe_ctrl_wr_reg_nxt;

assign rgn_ctrl0_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_ctrl0_en_reg_nxt;
assign rgn_ctrl0_o  = rgn_ctrl0_wr_reg_nxt;

assign rgn_ctrl1_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_ctrl1_en_reg_nxt;
assign rgn_ctrl1_o  = rgn_ctrl1_wr_reg_nxt;

assign rgn_lctrl_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_lctrl_en_reg_nxt;
assign rgn_lctrl_o  = rgn_lctrl_wr_reg_nxt;

assign rgn_cfg0_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_cfg0_en_reg_nxt;
assign rgn_cfg0_o  = rgn_cfg0_wr_reg_nxt;

assign rgn_cfg1_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_cfg1_en_reg_nxt;
assign rgn_cfg1_o  = rgn_cfg1_wr_reg_nxt;

assign rgn_size_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_size_en_reg_nxt;
assign rgn_size_o  = rgn_size_wr_reg_nxt;

assign rgn_tcfg0_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg0_en_reg_nxt;
assign rgn_tcfg0_o  = rgn_tcfg0_wr_reg_nxt;

assign rgn_tcfg1_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg1_en_reg_nxt;
assign rgn_tcfg1_o  = rgn_tcfg1_wr_reg_nxt;

assign rgn_tcfg2_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_tcfg2_en_reg_nxt;
assign rgn_tcfg2_o  = rgn_tcfg2_wr_reg_nxt;

assign rgn_mid0_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mid0_en_reg_nxt;
assign rgn_mid0_o  = rgn_mid0_wr_reg_nxt;

assign rgn_mid1_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mid1_en_reg_nxt;
assign rgn_mid1_o  = rgn_mid1_wr_reg_nxt;

assign rgn_mid2_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mid2_en_reg_nxt;
assign rgn_mid2_o  = rgn_mid2_wr_reg_nxt;

assign rgn_mid3_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mid3_en_reg_nxt;
assign rgn_mid3_o  = rgn_mid3_wr_reg_nxt;

assign rgn_mpl0_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl0_en_reg_nxt;
assign rgn_mpl0_o  = rgn_mpl0_wr_reg_nxt;

assign rgn_mpl1_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl1_en_reg_nxt;
assign rgn_mpl1_o  = rgn_mpl1_wr_reg_nxt;

assign rgn_mpl2_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl2_en_reg_nxt;
assign rgn_mpl2_o  = rgn_mpl2_wr_reg_nxt;

assign rgn_mpl3_en = {FC_NUM_RGN{reg_en_nxt}} & rgn_mpl3_en_reg_nxt;
assign rgn_mpl3_o  = rgn_mpl3_wr_reg_nxt;

assign fe_ctrl_en = reg_en_nxt && fe_ctrl_en_reg_nxt;
assign fe_ctrl_o  = fe_ctrl_wr_reg_nxt;

assign me_ctrl_en = reg_en_nxt && me_ctrl_en_reg_nxt;
assign me_ctrl_o  = me_ctrl_wr_reg_nxt;

assign edr_ctrl_en = reg_en_nxt && edr_ctrl_en_reg_nxt;
assign edr_ctrl_o  = edr_ctrl_wr_reg_nxt;

assign fc_int_st_en = {32{reg_en_nxt}} & fc_int_st_en_reg_nxt;
assign fc_int_st_o  = fc_int_st_wr_reg_nxt;

assign fc_int_msk_en = {32{reg_en_nxt}} & fc_int_msk_en_reg_nxt;
assign fc_int_msk_o  = fc_int_msk_wr_reg_nxt;

assign fw_tmp_ctrl_en = reg_en_nxt && fw_tmp_ctrl_en_reg_nxt;
assign fw_tmp_ctrl_o  = fw_tmp_ctrl_wr_reg_nxt;

assign addr_dec_shdw_rgn_en_o =
  {FW_NUM_FC{(addr_dec_acc_valid_i && addr_dec_rw_i)}} &
  shdw_rwe_ctrl_en_reg_nxt;
assign addr_dec_shdw_rgn_o    = shdw_rwe_ctrl_wr_reg_nxt;


assign addr_dec_frmtd_rd_data_o = frmtd_rd_data_nxt;

assign addr_dec_fixed_o = fixed_nxt;

assign addr_dec_read_only_o = read_only_nxt;

assign addr_dec_tamper_o = tamper;

assign addr_dec_wr_allow_fctlr_o = write_allowed_fctlr;

assign addr_dec_ctlr_n_comp_o = ctlr_n_comp;

assign addr_dec_shdw_mpe_o = { (|rgn_mid3_en_reg_nxt || |rgn_mpl3_en_reg_nxt),
                              (|rgn_mid2_en_reg_nxt || |rgn_mpl2_en_reg_nxt),
                              (|rgn_mid1_en_reg_nxt || |rgn_mpl1_en_reg_nxt),
                              (|rgn_mid0_en_reg_nxt || |rgn_mpl0_en_reg_nxt) };

assign addr_dec_clk_busy_o = addr_dec_acc_valid_i;

endmodule
