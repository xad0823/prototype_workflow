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


localparam SRAM_OFFSET_SIZE = 16;
localparam FW_MAX_RGN       = 256;
localparam SRAM_BLOCK_SIZE  = firewall_f0_log2(FW_MAX_RGN/1)+1;
localparam SRAM_PER_ROW     = firewall_f0_log2(SRAM_WIDTH)+1;

localparam [(7*NUM_FW_COMP)-1:0] ONE_RGN  = {NUM_FW_COMP{7'h1}};

localparam [7*NUM_FW_COMP-1:0] FC_NUM_RGN_LUT = FC_NUM_RGN_RSTR[7*NUM_FW_COMP-1:0];


localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] PROT_SIZE_START =
  {SRAM_OFFSET_SIZE*NUM_FW_COMP{1'b0}};
localparam PROT_SIZE_PER_ROW = 1;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] PROT_SIZE_BLOCK_SIZE =
  block_size_func(ONE_RGN, PROT_SIZE_PER_ROW, PROT_SIZE_EXISTS, PROT_SIZE_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] PROT_SIZE_END  =
  end_offset_func(PROT_SIZE_START, PROT_SIZE_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] PROT_SIZE_LAST_ROW = 1;

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] PE_CTRL_START =
 start_offset_func(PROT_SIZE_END);
localparam PE_CTRL_PER_ROW    = 1;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] PE_CTRL_BLOCK_SIZE =
  block_size_func(ONE_RGN, PE_CTRL_PER_ROW, PE_CTRL_EXISTS, PE_CTRL_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] PE_CTRL_END  =
  end_offset_func(PE_CTRL_START, PE_CTRL_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0]PE_CTRL_LAST_ROW = 1;

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG2_START =
  start_offset_func(PE_CTRL_END);
localparam RGN_TCFG2_PER_ROW    = SRAM_WIDTH/RGN_TCFG2_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_TCFG2_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_TCFG2_PER_ROW, RGN_TCFG2_EXISTS, RGN_TCFG2_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG2_END  =
  end_offset_func(RGN_TCFG2_START, RGN_TCFG2_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_TCFG2_LAST_ROW =
  last_row_func(RGN_TCFG2_PER_ROW, RGN_TCFG2_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] ME_CTRL_START =
   start_offset_func(RGN_TCFG2_END);
localparam ME_CTRL_PER_ROW    = 1;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] ME_CTRL_BLOCK_SIZE =
  block_size_func(ONE_RGN, ME_CTRL_PER_ROW, ME_CTRL_EXISTS, ME_CTRL_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] ME_CTRL_END  =
  end_offset_func(ME_CTRL_START, ME_CTRL_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] ME_CTRL_LAST_ROW = 1;

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CTRL0_START =
  start_offset_func(ME_CTRL_END);
localparam RGN_CTRL0_PER_ROW    = SRAM_WIDTH/RGN_CTRL0_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_CTRL0_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_CTRL0_PER_ROW, RGN_CTRL0_EXISTS, RGN_CTRL0_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CTRL0_END  =
  end_offset_func(RGN_CTRL0_START, RGN_CTRL0_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_CTRL0_LAST_ROW =
  last_row_func(RGN_CTRL0_PER_ROW, RGN_CTRL0_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CTRL1_START =
  start_offset_func(RGN_CTRL0_END);
localparam RGN_CTRL1_PER_ROW    = SRAM_WIDTH/RGN_CTRL1_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_CTRL1_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_CTRL1_PER_ROW, RGN_CTRL1_EXISTS, RGN_CTRL1_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CTRL1_END  =
  end_offset_func(RGN_CTRL1_START,RGN_CTRL1_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_CTRL1_LAST_ROW =
  last_row_func(RGN_CTRL1_PER_ROW, RGN_CTRL1_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_LCTRL_START =
  start_offset_func(RGN_CTRL1_END);
localparam RGN_LCTRL_PER_ROW    = SRAM_WIDTH/RGN_LCTRL_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_LCTRL_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_LCTRL_PER_ROW, RGN_LCTRL_EXISTS, RGN_LCTRL_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_LCTRL_END  =
  end_offset_func(RGN_LCTRL_START, RGN_LCTRL_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_LCTRL_LAST_ROW =
  last_row_func(RGN_LCTRL_PER_ROW, RGN_LCTRL_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RWE_CTRL_START =
  start_offset_func(RGN_LCTRL_END);
localparam RWE_CTRL_PER_ROW    = 1;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RWE_CTRL_BLOCK_SIZE =
  block_size_func(ONE_RGN, RWE_CTRL_PER_ROW, RWE_CTRL_EXISTS, RWE_CTRL_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RWE_CTRL_END  =
  end_offset_func(RWE_CTRL_START, RWE_CTRL_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RWE_CTRL_LAST_ROW = 1;

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_SIZE_START =
  start_offset_func(RWE_CTRL_END);
localparam RGN_SIZE_PER_ROW    = SRAM_WIDTH/RGN_SIZE_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_SIZE_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_SIZE_PER_ROW, RGN_SIZE_EXISTS, RGN_SIZE_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_SIZE_END  =
  end_offset_func(RGN_SIZE_START, RGN_SIZE_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_SIZE_LAST_ROW =
  last_row_func(RGN_SIZE_PER_ROW, RGN_SIZE_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL0_START =
  start_offset_func(RGN_SIZE_END);
localparam RGN_MPL0_PER_ROW    = SRAM_WIDTH/RGN_MPL0_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MPL0_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MPL0_PER_ROW, RGN_MPL0_EXISTS, RGN_MPL0_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL0_END  =
  end_offset_func(RGN_MPL0_START, RGN_MPL0_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MPL0_LAST_ROW =
  last_row_func(RGN_MPL0_PER_ROW, RGN_MPL0_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL1_START =
  start_offset_func(RGN_MPL0_END);
localparam RGN_MPL1_PER_ROW    = SRAM_WIDTH/RGN_MPL1_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MPL1_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MPL1_PER_ROW, RGN_MPL1_EXISTS, RGN_MPL1_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL1_END  =
  end_offset_func(RGN_MPL1_START, RGN_MPL1_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MPL1_LAST_ROW =
  last_row_func(RGN_MPL1_PER_ROW, RGN_MPL1_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL2_START =
  start_offset_func(RGN_MPL1_END);
localparam RGN_MPL2_PER_ROW    = SRAM_WIDTH/RGN_MPL2_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MPL2_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MPL2_PER_ROW, RGN_MPL2_EXISTS, RGN_MPL2_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL2_END  =
  end_offset_func(RGN_MPL2_START, RGN_MPL2_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MPL2_LAST_ROW =
  last_row_func(RGN_MPL2_PER_ROW, RGN_MPL2_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL3_START =
  start_offset_func(RGN_MPL2_END);
localparam RGN_MPL3_PER_ROW    = SRAM_WIDTH/RGN_MPL3_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MPL3_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MPL3_PER_ROW, RGN_MPL3_EXISTS, RGN_MPL3_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MPL3_END  =
  end_offset_func(RGN_MPL3_START, RGN_MPL3_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MPL3_LAST_ROW =
  last_row_func(RGN_MPL3_PER_ROW, RGN_MPL3_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam[SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID0_START =
  start_offset_func(RGN_MPL3_END);
localparam RGN_MID0_PER_ROW    = SRAM_WIDTH/RGN_MID0_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MID0_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MID0_PER_ROW, RGN_MID0_EXISTS, RGN_MID0_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID0_END =
  end_offset_func(RGN_MID0_START, RGN_MID0_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MID0_LAST_ROW =
  last_row_func(RGN_MID0_PER_ROW, RGN_MID0_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID1_START =
  start_offset_func(RGN_MID0_END);
localparam RGN_MID1_PER_ROW    = SRAM_WIDTH/RGN_MID1_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MID1_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MID1_PER_ROW, RGN_MID1_EXISTS, RGN_MID1_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID1_END =
  end_offset_func(RGN_MID1_START, RGN_MID1_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MID1_LAST_ROW =
  last_row_func(RGN_MID1_PER_ROW, RGN_MID1_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID2_START =
  start_offset_func(RGN_MID1_END);
localparam RGN_MID2_PER_ROW    = SRAM_WIDTH/RGN_MID2_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MID2_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MID2_PER_ROW, RGN_MID2_EXISTS, RGN_MID2_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID2_END =
  end_offset_func(RGN_MID2_START, RGN_MID2_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MID2_LAST_ROW =
  last_row_func(RGN_MID2_PER_ROW, RGN_MID2_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID3_START =
  start_offset_func(RGN_MID2_END);
localparam RGN_MID3_PER_ROW    = SRAM_WIDTH/RGN_MID3_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_MID3_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_MID3_PER_ROW, RGN_MID3_EXISTS, RGN_MID3_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_MID3_END =
  end_offset_func(RGN_MID3_START, RGN_MID3_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_MID3_LAST_ROW =
  last_row_func(RGN_MID3_PER_ROW, RGN_MID3_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG0_START =
  start_offset_func(RGN_MID3_END);
localparam RGN_TCFG0_PER_ROW    = SRAM_WIDTH/RGN_TCFG0_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_TCFG0_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_TCFG0_PER_ROW, RGN_TCFG0_EXISTS, RGN_TCFG0_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG0_END =
  end_offset_func(RGN_TCFG0_START, RGN_TCFG0_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_TCFG0_LAST_ROW =
  last_row_func(RGN_TCFG0_PER_ROW, RGN_TCFG0_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG1_START =
  start_offset_func(RGN_TCFG0_END);
localparam RGN_TCFG1_PER_ROW    = SRAM_WIDTH/RGN_TCFG1_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_TCFG1_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_TCFG1_PER_ROW, RGN_TCFG1_EXISTS, RGN_TCFG1_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_TCFG1_END =
  end_offset_func(RGN_TCFG1_START, RGN_TCFG1_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_TCFG1_LAST_ROW =
  last_row_func(RGN_TCFG1_PER_ROW, RGN_TCFG1_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CFG0_START =
  start_offset_func(RGN_TCFG1_END);
localparam RGN_CFG0_PER_ROW    = SRAM_WIDTH/RGN_CFG0_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_CFG0_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_CFG0_PER_ROW, RGN_CFG0_EXISTS, RGN_CFG0_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CFG0_END =
  end_offset_func(RGN_CFG0_START, RGN_CFG0_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_CFG0_LAST_ROW =
  last_row_func(RGN_CFG0_PER_ROW, RGN_CFG0_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CFG1_START =
  start_offset_func(RGN_CFG0_END);
localparam RGN_CFG1_PER_ROW    = SRAM_WIDTH/RGN_CFG1_WIDTH;
localparam [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] RGN_CFG1_BLOCK_SIZE =
  block_size_func(FC_NUM_RGN_LUT, RGN_CFG1_PER_ROW, RGN_CFG1_EXISTS, RGN_CFG1_FIXED);
localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] RGN_CFG1_END =
  end_offset_func(RGN_CFG1_START, RGN_CFG1_BLOCK_SIZE);
localparam [SRAM_PER_ROW*NUM_FW_COMP-1:0] RGN_CFG1_LAST_ROW =
  last_row_func(RGN_CFG1_PER_ROW, RGN_CFG1_BLOCK_SIZE, FC_NUM_RGN_LUT);

localparam [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] FC_RESTORE_SIZE = RGN_CFG1_END;

localparam RESTORE_SIZE = restore_size_func(RGN_CFG1_END);

localparam LOG2_RESTORE_SIZE = (firewall_f0_log2(RESTORE_SIZE) < SRAM_PER_ROW) ? SRAM_PER_ROW : firewall_f0_log2(RESTORE_SIZE);

function [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] start_offset_func;
  input [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] start_offset;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      start_offset_func[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] =
        start_offset[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] + {{(SRAM_OFFSET_SIZE-1){1'b0}}, 1'b1};
    end
  end
endfunction

function [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] block_size_func;
  input [7*NUM_FW_COMP-1:0] num_rgn;
  input integer per_row;
  input [NUM_FW_COMP-1:0] exists;
  input [NUM_FW_COMP-1:0] fixed;
  integer i;
  integer rgn_size;
  integer div_result;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      if (exists[i] && !fixed[i]) begin
        rgn_size = {{25{1'b0}}, num_rgn[7*(i+1)-1 -: 7]};
        div_result = firewall_f0_ceil_divide(rgn_size, per_row);
        block_size_func[SRAM_BLOCK_SIZE*(i+1)-1 -: SRAM_BLOCK_SIZE] =
          div_result[SRAM_BLOCK_SIZE-1:0];
      end
      else begin
        block_size_func[SRAM_BLOCK_SIZE*(i+1)-1 -: SRAM_BLOCK_SIZE] =
          {SRAM_BLOCK_SIZE{1'b0}};
      end
    end
  end
endfunction

function [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] end_offset_func;
  input [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] start_offset;
  input [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0]  block_size;
  integer i;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      end_offset_func[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] =
        start_offset[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] +
        block_size[SRAM_BLOCK_SIZE*(i+1)-1 -: SRAM_BLOCK_SIZE] - {{(SRAM_OFFSET_SIZE-1){1'b0}}, 1'b1} ;
    end
  end
endfunction

function [SRAM_PER_ROW*NUM_FW_COMP-1:0] last_row_func;
  input integer per_row;
  input [SRAM_BLOCK_SIZE*NUM_FW_COMP-1:0] block_size;
  input [7*NUM_FW_COMP-1:0] num_rgn;
  integer i;
  integer per_row_calc;
  begin
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      per_row_calc = per_row - ((per_row*block_size[SRAM_BLOCK_SIZE*(i+1)-1 -: SRAM_BLOCK_SIZE]) -
      num_rgn[7*(i+1)-1 -: 7]);
      last_row_func[SRAM_PER_ROW*(i+1)-1 -: SRAM_PER_ROW] =
        per_row_calc[SRAM_PER_ROW-1:0];
    end
  end
endfunction

function integer restore_size_func;
  input [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] restore_size_fc;
  integer i;
  begin
    restore_size_func = 0;
    for (i = 0; i < NUM_FW_COMP; i=i+1) begin
      restore_size_func = restore_size_func +
        restore_size_fc[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] + 1;
    end
  end
endfunction

function [SRAM_OFFSET_SIZE*(NUM_FW_COMP+1)-1:0] sram_start_offset_func;
  input [SRAM_OFFSET_SIZE*NUM_FW_COMP-1:0] rgn_cfg1_end_offset;
  integer i;
  begin
    for (i=0; i<NUM_FW_COMP; i=i+1) begin
      if (i==0) begin
        sram_start_offset_func[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] =
          {SRAM_OFFSET_SIZE{1'b0}};
      end else begin
      sram_start_offset_func[SRAM_OFFSET_SIZE*(i+1)-1 -: SRAM_OFFSET_SIZE] =
        rgn_cfg1_end_offset[SRAM_OFFSET_SIZE*i-1 -: SRAM_OFFSET_SIZE] +
          {{(SRAM_OFFSET_SIZE-1){1'b0}}, 1'b1} + sram_start_offset_func[SRAM_OFFSET_SIZE*(i)-1 -: SRAM_OFFSET_SIZE];
      end
    end

    sram_start_offset_func[SRAM_OFFSET_SIZE*(NUM_FW_COMP+1)-1 -: SRAM_OFFSET_SIZE] =
      {SRAM_OFFSET_SIZE{1'b0}};

  end
endfunction

localparam [SRAM_OFFSET_SIZE*(NUM_FW_COMP+1)-1:0] SRAM_COMP_OFFSET = sram_start_offset_func(RGN_CFG1_END);
