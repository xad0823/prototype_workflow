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

localparam NUM_FW_COMP = (FC_ID == 0) ? FW_NUM_FC : 1;

localparam [2*NUM_FW_COMP-1:0] FC_PE_LVL_REG_EXISTS   = FC_PE_LVL_RSTR[2*NUM_FW_COMP-1:0];
localparam [1:0] FW_LDE_LVL_REG_EXISTS                = FW_LDE_LVL[1:0];
localparam [7*NUM_FW_COMP-1:0] FC_MXRS_REG_EXISTS     = FC_MXRS_RSTR[7*NUM_FW_COMP-1:0];
localparam [2*NUM_FW_COMP-1:0] FC_TE_LVL_REG_EXISTS   = FC_TE_LVL_RSTR[2*NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_RSE_LVL_REG_EXISTS    = FC_RSE_LVL_RSTR[NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_MA_SPT_REG_EXISTS     = FC_MA_SPT_RSTR[NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_INST_SPT_REG_EXISTS   = FC_INST_SPT_RSTR[NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_PRIV_SPT_REG_EXISTS   = FC_PRIV_SPT_RSTR[NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_SH_SPT_REG_EXISTS     = FC_SH_SPT_RSTR[NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_SEC_SPT_REG_EXISTS    = FC_SEC_SPT_RSTR[NUM_FW_COMP-1:0];
localparam [3*NUM_FW_COMP-1:0] FC_NUM_MPE_REG_EXISTS  = FC_NUM_MPE_RSTR[3*NUM_FW_COMP-1:0];
localparam [NUM_FW_COMP-1:0] FC_SINGLE_MST_REG_EXISTS = FC_SINGLE_MST_RSTR[NUM_FW_COMP-1:0];
localparam [2*NUM_FW_COMP-1:0] FC_ME_LVL_REG_EXISTS   = FC_ME_LVL_RSTR[2*NUM_FW_COMP-1:0];
localparam [4:0] FC_ID_REG_EXISTS                     = FC_ID_RSTR[4:0];

localparam [NUM_FW_COMP-1:0] PE_CTRL_EXISTS   = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] PE_CTRL_FIXED    = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] PE_ST_EXISTS     = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] PE_ST_FIXED      = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] PE_BPS_EXISTS    = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] PE_BPS_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RWE_CTRL_EXISTS  = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RWE_CTRL_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_CTRL0_EXISTS = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_CTRL0_FIXED  = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_CTRL1_EXISTS = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_CTRL1_FIXED  = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_LCTRL_EXISTS =
  pe_lde_exists_func(FC_PE_LVL_REG_EXISTS, FW_LDE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_LCTRL_FIXED  = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_ST_EXISTS    = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_ST_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_CFG0_EXISTS  = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_CFG0_FIXED   = pe_fixed_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_CFG1_EXISTS  =
  pe_mxrs_exists_func(FC_PE_LVL_REG_EXISTS, FC_MXRS_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_CFG1_FIXED   = pe_fixed_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_SIZE_EXISTS  = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_SIZE_FIXED   = pe_fixed_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG0_EXISTS =
  pe_te_rse_exists_func(FC_PE_LVL_REG_EXISTS, FC_TE_LVL_REG_EXISTS, FC_RSE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG0_FIXED  =
  pe_te_fixed_func(FC_PE_LVL_REG_EXISTS, FC_TE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG1_EXISTS =
  pe_te_rse_mxrs_exists_func(FC_PE_LVL_REG_EXISTS, FC_TE_LVL_REG_EXISTS, FC_RSE_LVL_REG_EXISTS,
    FC_MXRS_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG1_FIXED  =
  pe_te_fixed_func(FC_PE_LVL_REG_EXISTS, FC_TE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG2_EXISTS =
  rgn_tcfg2_exists_func(FC_TE_LVL_REG_EXISTS, FC_MA_SPT_REG_EXISTS, FC_INST_SPT_REG_EXISTS,
    FC_PRIV_SPT_REG_EXISTS, FC_SH_SPT_REG_EXISTS, FC_SEC_SPT_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_TCFG2_FIXED  = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_MID0_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 0);
localparam [NUM_FW_COMP-1:0] RGN_MID0_FIXED   =
  mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_MID1_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 1);
localparam [NUM_FW_COMP-1:0] RGN_MID1_FIXED   =
  mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_MID2_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 2);
localparam [NUM_FW_COMP-1:0] RGN_MID2_FIXED   =
  mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_MID3_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 3);
localparam [NUM_FW_COMP-1:0] RGN_MID3_FIXED   =
  mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] RGN_MPL0_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 0);
localparam [NUM_FW_COMP-1:0] RGN_MPL0_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_MPL1_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 1);
localparam [NUM_FW_COMP-1:0] RGN_MPL1_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_MPL2_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 2);
localparam [NUM_FW_COMP-1:0] RGN_MPL2_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] RGN_MPL3_EXISTS  =
  pe_mpe_func(FC_NUM_MPE_REG_EXISTS, FC_PE_LVL_REG_EXISTS, 3);
localparam [NUM_FW_COMP-1:0] RGN_MPL3_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] FE_TAL_EXISTS    =
  pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_TAL_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] FE_TAU_EXISTS    = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_TAU_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] FE_TP_EXISTS     = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_TP_FIXED      = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] FE_MID_EXISTS    = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_MID_FIXED     = mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_CTRL_EXISTS   = pe_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] FE_CTRL_FIXED    = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] ME_CTRL_EXISTS   = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] ME_CTRL_FIXED    = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] ME_ST_EXISTS     = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] ME_ST_FIXED      = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] EDR_TAL_EXISTS   = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_TAL_FIXED    = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] EDR_TAU_EXISTS   = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_TAU_FIXED    = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] EDR_TP_EXISTS    = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_TP_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] EDR_MID_EXISTS   = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_MID_FIXED    = mst_fixed_func(FC_SINGLE_MST_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_CTRL_EXISTS  = me_exists_func(FC_ME_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] EDR_CTRL_FIXED   = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] PROT_SIZE_EXISTS = pe_2_exists_func(FC_PE_LVL_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] PROT_SIZE_FIXED  = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] BYPASS_EXISTS    = {NUM_FW_COMP{1'b1}};
localparam [NUM_FW_COMP-1:0] BYPASS_FIXED     = {NUM_FW_COMP{1'b0}};
localparam [NUM_FW_COMP-1:0] LD_CTRL_EXISTS   =
  lde_sre_exists_func(FW_LDE_LVL_REG_EXISTS, FW_SRE_LVL[0], FC_ID_REG_EXISTS);
localparam [NUM_FW_COMP-1:0] LD_CTRL_FIXED    = {NUM_FW_COMP{1'b0}};

function [NUM_FW_COMP-1:0] pe_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_exists_func[i] = pe_lvl[2*(i+1)-1 -: 2] > 0;
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_fixed_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_fixed_func[i] = pe_lvl[2*(i+1)-1 -: 2] == 1;
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_lde_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input [1:0]               lde_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_lde_exists_func[i] = (pe_lvl[2*(i+1)-1 -: 2] > 0) &&
        (lde_lvl == 2);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_mxrs_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input [7*NUM_FW_COMP-1:0] mxrs;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_mxrs_exists_func[i] = (pe_lvl[2*(i+1)-1 -: 2] > 0) &&
        (mxrs[7*(i+1)-1 -: 7] > 32);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_te_rse_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input [2*NUM_FW_COMP-1:0] te_lvl;
  input [NUM_FW_COMP-1:0]   rse_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_te_rse_exists_func[i] = (pe_lvl[2*(i+1)-1 -: 2] > 0) &&
        ((te_lvl[2*(i+1)-1 -: 2] == 2) || (rse_lvl[(i+1)-1 -: 1] > 0));
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_te_fixed_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input [2*NUM_FW_COMP-1:0] te_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_te_fixed_func[i] = (pe_lvl[2*(i+1)-1 -: 2] == 1) &&
        (te_lvl[2*(i+1)-1 -: 2] < 2);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_te_rse_mxrs_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input [2*NUM_FW_COMP-1:0] te_lvl;
  input [NUM_FW_COMP-1:0]   rse_lvl;
  input [7*NUM_FW_COMP-1:0] mxrs;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_te_rse_mxrs_exists_func[i] = (pe_lvl[2*(i+1)-1 -: 2] > 0) &&
        ((te_lvl[2*(i+1)-1 -: 2] == 2) || (rse_lvl[(i+1)-1 -: 1] > 0)) &&
        (mxrs[7*(i+1)-1 -: 7] > 32);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] rgn_tcfg2_exists_func;
  input [2*NUM_FW_COMP-1:0] te_lvl;
  input [NUM_FW_COMP-1:0]   ma_spt;
  input [NUM_FW_COMP-1:0]   inst_spt;
  input [NUM_FW_COMP-1:0]   priv_spt;
  input [NUM_FW_COMP-1:0]   sh_spt;
  input [NUM_FW_COMP-1:0]   sec_spt;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      rgn_tcfg2_exists_func[i] = te_lvl[2*(i+1)-1 -: 2] > 0 &&
        !(ma_spt[(i+1)-1 -: 1] == 0 &&
        inst_spt[(i+1)-1 -: 1] == 0 && priv_spt[(i+1)-1 -: 1] == 0 &&
        sh_spt[(i+1)-1 -: 1] == 0 && sec_spt[(i+1)-1 -: 1] == 0 &&
        te_lvl[2*(i+1)-1 -: 2] == 1);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_mpe_func;
  input [3*NUM_FW_COMP-1:0] num_mpe;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  input integer mpe;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_mpe_func[i] = (num_mpe[3*(i+1)-1 -: 3] > mpe) &&
        (pe_lvl[2*(i+1)-1 -: 2] > 0);
    end
  end
endfunction

function [NUM_FW_COMP-1:0] mst_fixed_func;
  input [NUM_FW_COMP-1:0] single_mst;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      mst_fixed_func[i] = single_mst[(i+1)-1 -: 1] == 1;
    end
  end
endfunction

function [NUM_FW_COMP-1:0] me_exists_func;
  input [2*NUM_FW_COMP-1:0] me_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      me_exists_func[i] = me_lvl[2*(i+1)-1 -: 2] > 0;
    end
  end
endfunction

function [NUM_FW_COMP-1:0] pe_2_exists_func;
  input [2*NUM_FW_COMP-1:0] pe_lvl;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      pe_2_exists_func[i] = pe_lvl[2*(i+1)-1 -: 2] == 2;
    end
  end
endfunction

function [NUM_FW_COMP-1:0] lde_sre_exists_func;
  input [1:0]               lde_lvl;
  input                     sre_lvl;
  input [4:0]               fc_id;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      lde_sre_exists_func[i] = (lde_lvl > 0) &&
        (((sre_lvl == 0) && (fc_id[4:0] > 0)) ||
        ((sre_lvl == 1) && (fc_id[4:0] == 0)));
    end
  end
endfunction
