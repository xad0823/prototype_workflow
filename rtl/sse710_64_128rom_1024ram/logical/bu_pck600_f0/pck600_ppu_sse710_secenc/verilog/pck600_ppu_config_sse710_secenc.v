// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


`include "pck600_ppu_param_sse710_secenc.v"

localparam DEVCHAN_CFG = 4'h0;

localparam DEF_PWR_POLICY = 4'h0;
localparam DEF_PWR_DYN_EN = 1'b1;
localparam DEF_PWR_DYN_ST = 1'b1;
localparam DEF_OP_POLICY = 4'h0;
localparam DEF_OP_DYN_EN = 1'b0;
localparam DEF_OP_DYN_ST = 1'b0;
localparam WARM_RST_DEVREQEN_CFG = 1'b1;
localparam DBG_RECOV_PORST_CFG = 1'b0;

localparam STA_OFF_EMU_SPT_CFG = 1'b0;
localparam STA_MEM_RET_SPT_CFG = 1'b1;
localparam STA_MEM_RET_EMU_SPT_CFG = 1'b0;
localparam STA_LGC_RET_SPT_CFG = 1'b0;
localparam STA_FULL_RET_SPT_CFG = 1'b0;
localparam STA_MEM_OFF_SPT_CFG = 1'b0;
localparam STA_FUNC_RET_SPT_CFG = 1'b0;
localparam STA_DBG_RECOV_SPT_CFG = 1'b0;
localparam DYN_OFF_SPT_CFG = 1'b1;
localparam DYN_OFF_EMU_SPT_CFG = 1'b0;
localparam DYN_MEM_RET_SPT_CFG = 1'b1;
localparam DYN_MEM_RET_EMU_SPT_CFG = 1'b0;
localparam DYN_LGC_RET_SPT_CFG = 1'b0;
localparam DYN_FULL_RET_SPT_CFG = 1'b0;
localparam DYN_MEM_OFF_SPT_CFG = 1'b0;
localparam DYN_FUNC_RET_SPT_CFG = 1'b0;
localparam DYN_ON_SPT_CFG = 1'b1;
localparam DYN_WRM_RST_SPT_CFG = 1'b0;

localparam FUNC_RET_RAM_REG_CFG = 1'b0;
localparam FULL_RET_RAM_REG_CFG = 1'b0;
localparam MEM_RET_RAM_REG_CFG = 1'b0;

localparam NUM_OPMODE_CFG = 4'h0;
localparam OP_ACTIVE_CFG = 1'b0;

localparam STA_POLICY_OP_IRQ_CFG = 1'b0;
localparam STA_POLICY_PWR_IRQ_CFG = 1'b0;

localparam LOCK_CFG = 1'b0;

localparam SW_DEV_DEL_CFG = 1'b0;

localparam PWR_MODE_ENTRY_DEL_CFG = 1'b1;

localparam OFF_MEM_RET_TRANS_CFG = 1'b0;

localparam OPMODE_PCSM_SPT_CFG = 1'b0;

localparam DEV_SYNC_EN = 0;

localparam DEV_ACTIVE_SYNC_EN = 1;

localparam PCSM_SYNC_EN = 0;

localparam QCLK_SYNC_EN = 1;

localparam PCSM_OFF_INIT = 1;

localparam UARCH = 1;

localparam NUM_DEV_LPI = 1;
localparam NUM_PWR_DEVACTIVE = 11;
localparam NUM_OP_DEVACTIVE = 0;
localparam DEVACTIVE_LSB = 1;
localparam OP_MODE_WIDTH = 0;
localparam DEVPSTATE_WIDTH = 4;
localparam DEVPACTIVE_WIDTH = 11;
localparam PCSMPSTATE_WIDTH = 4;
localparam PPUHWSTAT_WIDTH = 16;
localparam OP_PPUHWSTAT_WIDTH = 0;

localparam TRANS_PATH_WIDTH = 5;

function integer cal_cri_counter_enable(input reg [7:0] clken_rst_dly, input reg [7:0] iso_clken_dly, input reg [7:0] rst_hwstat_dly,
                                    input reg [7:0] iso_rst_dly, input reg [7:0] clken_iso_dly, input reg swdev_del_cfg);
begin:f_cal_cri_counter_enable

  if(swdev_del_cfg == 1'b1)
  begin
    cal_cri_counter_enable = 1;
  end
  else
  begin
    if((clken_rst_dly > 0) | (iso_clken_dly > 0) | (rst_hwstat_dly > 0) |
       (iso_rst_dly > 0) | (clken_iso_dly > 0))
    begin
      cal_cri_counter_enable = 1;
    end
    else
    begin
      cal_cri_counter_enable = 0;
    end
  end

end
endfunction


function integer cal_cri_counter_width(input reg [7:0] clken_rst_dly, input reg [7:0] iso_clken_dly, input reg[7:0] rst_hwstat_dly,
                                   input reg [7:0] iso_rst_dly, input reg [7:0] clken_iso_dly, input reg swdev_del_cfg);
begin:f_cal_cri_counter_width

  if(swdev_del_cfg == 1'b1)
  begin
    cal_cri_counter_width = 8;
  end
  else
  begin
    if((clken_rst_dly[7:0] > 8'h7F) | (iso_clken_dly[7:0] > 8'h7F) | (rst_hwstat_dly[7:0] > 8'h7F) |
       (iso_rst_dly[7:0] > 8'h7F) | (clken_iso_dly[7:0] > 8'h7F))
    begin
      cal_cri_counter_width = 8;
    end
    else if((clken_rst_dly[7:0] > 8'h3F) | (iso_clken_dly[7:0] > 8'h3F) | (rst_hwstat_dly[7:0] > 8'h3F) |
            (iso_rst_dly[7:0] > 8'h3F) | (clken_iso_dly[7:0] > 8'h3F))
    begin
      cal_cri_counter_width = 7;
    end
    else if((clken_rst_dly[7:0] > 8'h1F) | (iso_clken_dly[7:0] > 8'h1F) | (rst_hwstat_dly[7:0] > 8'h1F) |
            (iso_rst_dly[7:0] > 8'h1F) | (clken_iso_dly[7:0] > 8'h1F))
    begin
      cal_cri_counter_width = 6;
    end
    else if((clken_rst_dly[7:0] > 8'h0F) | (iso_clken_dly[7:0] > 8'h0F) | (rst_hwstat_dly[7:0] > 8'h0F) |
            (iso_rst_dly[7:0] > 8'h0F) | (clken_iso_dly[7:0] > 8'h0F))
    begin
      cal_cri_counter_width = 5;
    end
    else if((clken_rst_dly[7:0] > 8'h07) | (iso_clken_dly[7:0] > 8'h07) | (rst_hwstat_dly[7:0] > 8'h07) |
            (iso_rst_dly[7:0] > 8'h07) | (clken_iso_dly[7:0] > 8'h07))
    begin
      cal_cri_counter_width = 4;
    end
    else if((clken_rst_dly[7:0] > 8'h03) | (iso_clken_dly[7:0] > 8'h03) | (rst_hwstat_dly[7:0] > 8'h03) |
            (iso_rst_dly[7:0] > 8'h03) | (clken_iso_dly[7:0] > 8'h03))
    begin
      cal_cri_counter_width = 3;
    end
    else if((clken_rst_dly[7:0] > 8'h01) | (iso_clken_dly[7:0] > 8'h01) | (rst_hwstat_dly[7:0] > 8'h01) |
            (iso_rst_dly[7:0] > 8'h01) | (clken_iso_dly[7:0] > 8'h01))
    begin
      cal_cri_counter_width = 2;
    end
    else
    begin
      cal_cri_counter_width = 1;
    end
  end

end
endfunction

localparam CRI_COUNTER_EN = cal_cri_counter_enable(CLKEN_RST_DLY_CFG,ISO_CLKEN_DLY_CFG,RST_HWSTAT_DLY_CFG,
                                                   ISO_RST_DLY_CFG,CLKEN_ISO_DLY_CFG,SW_DEV_DEL_CFG);
localparam CRI_COUNTER_WIDTH = cal_cri_counter_width(CLKEN_RST_DLY_CFG,ISO_CLKEN_DLY_CFG,RST_HWSTAT_DLY_CFG,
                                                 ISO_RST_DLY_CFG,CLKEN_ISO_DLY_CFG,SW_DEV_DEL_CFG);
