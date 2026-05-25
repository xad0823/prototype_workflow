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




module interrupt_router_f0_tamper_logic_async
#(
  parameter LD_CTRL          = 12'h010,
  parameter SHD_INT_CFG      = 12'h104,
  parameter SHD_INT_LCTRL    = 12'h108,
  parameter INT_RTR_TMP_ST   = 12'hE90,
  parameter MASTER_ID_WIDTH  = 4'h8,
  parameter SECURE_MASTER_ID = 0,
  parameter LDE_LVL          = 2
)

(
  input  wire [11:0]     paddr_r_i,
  input  wire            ld_ctrl_ldi_st,
  input  wire [1:0]      ld_ctrl_lock,
  input  wire            shd_int_lctrl_lock,
  input  wire            prdata_en,
  input  wire            global_write_en,
  input  wire [1:0]      pprot_r_i,
  input  wire            master_id_i,
  output wire            tamper_o
);

  wire ld_ctrl_tamper;
  wire shd_int_cfg_tamper;
  wire shd_int_ctrl_tamper;
  wire tamper_access_tamper;

  assign ld_ctrl_tamper = ((paddr_r_i[11:0] == LD_CTRL[11:0]) & ld_ctrl_ldi_st & (ld_ctrl_lock > 2'b01) & (LDE_LVL >= 1)) ? 1'b1 : 1'b0;
  assign shd_int_cfg_tamper = ((paddr_r_i[11:0] == SHD_INT_CFG[11:0]) & (LDE_LVL >= 1) & ((ld_ctrl_lock == 2'b11) | ((ld_ctrl_lock <= 2'b10) & (shd_int_lctrl_lock)))) ? 1'b1 : 1'b0;
  assign shd_int_ctrl_tamper = ((paddr_r_i[11:0] == SHD_INT_LCTRL[11:0]) & (LDE_LVL >= 1) & (((ld_ctrl_lock == 2'b10) & (shd_int_lctrl_lock)) | (ld_ctrl_lock == 2'b11))) ? 1'b1 : 1'b0;
  assign tamper_access_tamper = (paddr_r_i[11:0] == INT_RTR_TMP_ST) & ((pprot_r_i != 2'b01) | (master_id_i != SECURE_MASTER_ID[MASTER_ID_WIDTH-1:0])) ? 1'b1 : 1'b0;
  assign tamper_o = (global_write_en & (ld_ctrl_tamper | shd_int_cfg_tamper | shd_int_ctrl_tamper)) | ((global_write_en | prdata_en) & tamper_access_tamper);

endmodule


