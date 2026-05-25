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


`include "firewall_f0_comp_global_cfg_secenc_add_remap.vh"


`include "firewall_f0_ctlr_user_cfg_secenc.vh"

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_MST_ID0_VAL = FIREWALL_F0_CFG_GLOBAL_SECENC_FC_MST_ID0_VAL;

localparam [31:0] FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_PER_MST_ID0 = FIREWALL_F0_CFG_GLOBAL_SECENC_ERR_RESP_PER_MST_ID0_VAL; 


localparam FIREWALL_F0_CFG_SECENC_FW_LDE_LVL           = 0; 
localparam FIREWALL_F0_CFG_SECENC_FW_SRE_LVL           = 0; 
localparam FIREWALL_F0_CFG_SECENC_FW_CFG_AGENT_MST_ID  = 1; 
localparam FIREWALL_F0_CFG_SECENC_FW_NUM_FC            = 1; 
localparam FIREWALL_F0_CFG_SECENC_FW_MAX_MST_ID_WIDTH  = 1; 
localparam FIREWALL_F0_CFG_SECENC_LOG2_FW_NUM_FC       = 1; 
localparam FIREWALL_F0_CFG_SECENC_FC_AXIID_WIDTH       = 1; 
localparam FIREWALL_F0_CFG_SECENC_FC_MST_ID_WIDTH      = 1; 
localparam FIREWALL_F0_CFG_SECENC_FC_ADDR_WIDTH        = 21; 
localparam FIREWALL_F0_CFG_SECENC_FC_RSE_LVL           = 1; 
localparam FIREWALL_F0_CFG_SECENC_FC_SINGLE_MST        = 1; 
localparam FIREWALL_F0_CFG_SECENC_FC_MXRS              = 21; 
localparam FIREWALL_F0_CFG_SECENC_FC_MST_ID_SINGLE_MST = 1; 

 localparam FIREWALL_F0_CFG_SECENC_FC_PE_LVL                = 2'h1  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_TE_LVL                = 2'h0  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_ME_LVL                = 2'h0  ; 
 localparam FIREWALL_F0_CFG_SECENC_FW_SE_LVL                = 2'h1  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_FE                = 1     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_EDR               = 0     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_ID                    = 5'h0  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_READ_OS           = 1     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_WRITE_OS          = 1     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_AXIDATA_WIDTH         = 32    ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_AXIUSER_R_WIDTH       = 1     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_AXIUSER_B_WIDTH       = 1     ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_CFG_DATA_W            = 32    ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_RGN               = 7'h3  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_NUM_MPE               = 3'b001; 
 localparam FIREWALL_F0_CFG_SECENC_FC_MNRS                  = 7'h07 ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_SEC_SPT               = 1'h1  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_MA_SPT                = 1'h1  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_SH_SPT                = 1'h0  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_INST_SPT              = 1'h1  ; 
 localparam FIREWALL_F0_CFG_SECENC_FC_PRIV_SPT              = 1'h1  ; 



localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN0_BASE_ADDR = 24'h000000;
localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN0_UPR_ADDR  = 24'h00f000;
localparam [7:0]  FIREWALL_F0_CFG_SECENC_FC_RGN0_SIZE      = 8'h11;
localparam        FIREWALL_F0_CFG_SECENC_FC_RGN0_MULNPO2   = 1'b1;

localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN1_BASE_ADDR = 24'h000000;
localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN1_UPR_ADDR  = 24'h00f000;
localparam [7:0]  FIREWALL_F0_CFG_SECENC_FC_RGN1_SIZE      = 8'h11;
localparam        FIREWALL_F0_CFG_SECENC_FC_RGN1_MULNPO2   = 1'b1;

localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN2_BASE_ADDR = 24'h010000;
localparam [20:0] FIREWALL_F0_CFG_SECENC_FC_RGN2_UPR_ADDR  = 24'h1f000;
localparam [7:0]  FIREWALL_F0_CFG_SECENC_FC_RGN2_SIZE      = 8'h11;
localparam        FIREWALL_F0_CFG_SECENC_FC_RGN2_MULNPO2   = 1'b1;


localparam [62:0] FIREWALL_F0_CFG_SECENC_FC_RGN_BASE_ADDR = {
    FIREWALL_F0_CFG_SECENC_FC_RGN2_BASE_ADDR ,
    FIREWALL_F0_CFG_SECENC_FC_RGN1_BASE_ADDR ,
    FIREWALL_F0_CFG_SECENC_FC_RGN0_BASE_ADDR 
};

localparam [62:0] FIREWALL_F0_CFG_SECENC_FC_RGN_UPR_ADDR  = {
    FIREWALL_F0_CFG_SECENC_FC_RGN2_UPR_ADDR,
    FIREWALL_F0_CFG_SECENC_FC_RGN1_UPR_ADDR,
    FIREWALL_F0_CFG_SECENC_FC_RGN0_UPR_ADDR
};

localparam [23:0] FIREWALL_F0_CFG_SECENC_FC_RGN_SIZE  = {
    FIREWALL_F0_CFG_SECENC_FC_RGN2_SIZE,
    FIREWALL_F0_CFG_SECENC_FC_RGN1_SIZE,
    FIREWALL_F0_CFG_SECENC_FC_RGN0_SIZE
};

localparam [2:0] FIREWALL_F0_CFG_SECENC_FC_RGN_MULNPO2  = {
    FIREWALL_F0_CFG_SECENC_FC_RGN2_MULNPO2,
    FIREWALL_F0_CFG_SECENC_FC_RGN1_MULNPO2,
    FIREWALL_F0_CFG_SECENC_FC_RGN0_MULNPO2
};


localparam [31:0] FIREWALL_F0_CFG_SECENC_FC_MST_ID_WIDTH_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID_WIDTH[31:0] 
};

localparam [4:0] FIREWALL_F0_CFG_SECENC_FC_ID_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ID[4:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_SINGLE_MST_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SINGLE_MST[0:0] 
};

localparam [1:0] FIREWALL_F0_CFG_SECENC_FC_PE_LVL_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_PE_LVL[1:0] 
};

localparam [1:0] FIREWALL_F0_CFG_SECENC_FC_TE_LVL_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_TE_LVL[1:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_RSE_LVL_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_RSE_LVL[0:0] 
};

localparam [1:0] FIREWALL_F0_CFG_SECENC_FC_ME_LVL_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_ME_LVL[1:0] 
};

localparam [6:0] FIREWALL_F0_CFG_SECENC_FC_NUM_RGN_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_RGN[6:0] 
};

localparam [6:0] FIREWALL_F0_CFG_SECENC_FC_MNRS_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MNRS[6:0] 
};

localparam [6:0] FIREWALL_F0_CFG_SECENC_FC_MXRS_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MXRS[6:0] 
};

localparam [2:0] FIREWALL_F0_CFG_SECENC_FC_NUM_MPE_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_NUM_MPE[2:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_SEC_SPT_EXT = {
            FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SEC_SPT[0:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_MA_SPT_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MA_SPT[0:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_SH_SPT_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_SH_SPT[0:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_INST_SPT_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_INST_SPT[0:0] 
};

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_PRIV_SPT_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_PRIV_SPT[0:0] 
};


localparam [31:0] FIREWALL_F0_CFG_SECENC_FC_MST_ID_SINGLE_MST_EXT = {
        FIREWALL_F0_CFG_SECENC_ADD_REMAP_FC_MST_ID_SINGLE_MST[31:0] 
};

localparam [4095:0] FIREWALL_F0_CFG_SECENC_FC_RGN_BASE_ADDR_EXT = {
   {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}} , {64{1'b0}}  };

localparam [4095:0] FIREWALL_F0_CFG_SECENC_FC_RGN_UPR_ADDR_EXT = {
   {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}} , {64{1'b1}}  };

localparam [511:0] FIREWALL_F0_CFG_SECENC_FC_RGN_SIZE_EXT = {
   {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}} , {8{1'b1}}  };

localparam [63:0] FIREWALL_F0_CFG_SECENC_FC_RGN_MULNPO2_EXT = {
   1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0 , 1'b0  };


localparam FIREWALL_F0_CFG_SECENC_FC_AW_REG_SLC_S  = 0; 
localparam FIREWALL_F0_CFG_SECENC_FC_W_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_FC_B_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_FC_AR_REG_SLC_S  = 0; 
localparam FIREWALL_F0_CFG_SECENC_FC_R_REG_SLC_S   = 0; 
localparam FIREWALL_F0_CFG_SECENC_FC_BAS_REG_SLC   = 0; 

localparam FIREWALL_F0_CFG_SECENC_FC_NUM_MST_ID             = 1; 

localparam [0:0] FIREWALL_F0_CFG_SECENC_FC_MST_ID_VAL  = {
    FIREWALL_F0_CFG_SECENC_FC_MST_ID0_VAL
};

localparam [31:0] FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_PER_MST_ID  = {
    FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_PER_MST_ID0
};

localparam [31:0] FIREWALL_F0_CFG_SECENC_FC_ERR_RESP_DEF = 32'hdeaddead; 

localparam FIREWALL_F0_CFG_SECENC_FW_RAM_ROWS  = 0;
