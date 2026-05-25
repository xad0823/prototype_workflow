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

localparam RWE_CTRL_RST_VAL       = 8'b00000000           ;
localparam RGN_LCTRL_RST_VAL      = 1'b0                  ;
localparam RGN_CTRL0_RST_VAL      = 1'b0                  ;
localparam RGN_CTRL1_RST_VAL      = 4'b0000               ;
localparam ME_CTRL_RST_VAL        = 3'b000                ;
localparam RGN_TCFG2_RST_VAL      = 18'b000000000000000100;

localparam FE_CTRL_FP_RST_VAL     = 4'b0000               ;
localparam FE_CTRL_SP_RST_VAL     = 1'b0                  ;

localparam EDR_CTRL_RST_VAL       = 3'b000                ;

localparam LD_CTRL_LOCK_RST_VAL   = 2'b00                 ;

localparam PE_CTRL_EN_RST_VAL        = (FC_ID==0) ? 1'b1 : 1'b0;
localparam PE_CTRL_BYPASSMSK_RST_VAL = 1'b0 ;
localparam PE_CTRL_FEPWR_RST_VAL     = 1'b0 ;
localparam PE_CTRL_FLTCFG_RST_VAL    = 2'b10;
localparam PE_CTRL_RAZ_RST_VAL       = 1'b0 ;
localparam PE_CTRL_ERR_RST_VAL       = 1'b1 ;
localparam [6:0] PE_CTRL_RST_VAL     =
  {PE_CTRL_EN_RST_VAL, PE_CTRL_BYPASSMSK_RST_VAL, PE_CTRL_FEPWR_RST_VAL,
  PE_CTRL_FLTCFG_RST_VAL, PE_CTRL_RAZ_RST_VAL, PE_CTRL_ERR_RST_VAL};
