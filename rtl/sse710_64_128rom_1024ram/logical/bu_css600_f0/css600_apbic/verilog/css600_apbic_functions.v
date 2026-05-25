//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Functions for css600_apbic
//
//----------------------------------------------------------------------------


  function integer logb2;
    input integer width;
    integer i;
    begin
      logb2 = 0;
      for (i = 0; 2**i < width; i=i+1)
        logb2 = logb2 + 1;
    end
  endfunction


  function integer count_bits;
    input [63:0] bitmask;
    integer i;
    begin
      count_bits = 0;
      for (i=0; i<64; i=i+1)
        if (bitmask[i])
          count_bits = count_bits + 1;
    end
  endfunction


  function integer max_inter_addr_width;
    input  [4095:0] psel_mask_all;
    integer expandergroup;
    integer bit_count;
    integer exp_sel_width;
    integer this_master_addr_width;
    begin
      max_inter_addr_width = 12;
      for (expandergroup=0; expandergroup<64; expandergroup=expandergroup+1) begin
        bit_count = count_bits(psel_mask_all[64*expandergroup +: 64]);
        exp_sel_width = logb2(bit_count);
        this_master_addr_width = max_addr_width(expandergroup) + exp_sel_width;
        if (this_master_addr_width > max_inter_addr_width)
          max_inter_addr_width = this_master_addr_width;
      end
    end
  endfunction


  function integer max_addr_width;
    input integer expandergroup;
    begin
      max_addr_width = 12;
      if ((L_M0_GROUP  == expandergroup) && (L_M0_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M0_ADDR_WIDTH;
      if ((L_M1_GROUP  == expandergroup) && (L_M1_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M1_ADDR_WIDTH;
      if ((L_M2_GROUP  == expandergroup) && (L_M2_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M2_ADDR_WIDTH;
      if ((L_M3_GROUP  == expandergroup) && (L_M3_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M3_ADDR_WIDTH;
      if ((L_M4_GROUP  == expandergroup) && (L_M4_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M4_ADDR_WIDTH;
      if ((L_M5_GROUP  == expandergroup) && (L_M5_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M5_ADDR_WIDTH;
      if ((L_M6_GROUP  == expandergroup) && (L_M6_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M6_ADDR_WIDTH;
      if ((L_M7_GROUP  == expandergroup) && (L_M7_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M7_ADDR_WIDTH;
      if ((L_M8_GROUP  == expandergroup) && (L_M8_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M8_ADDR_WIDTH;
      if ((L_M9_GROUP  == expandergroup) && (L_M9_ADDR_WIDTH  > max_addr_width)) max_addr_width = L_M9_ADDR_WIDTH;
      if ((L_M10_GROUP == expandergroup) && (L_M10_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M10_ADDR_WIDTH;
      if ((L_M11_GROUP == expandergroup) && (L_M11_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M11_ADDR_WIDTH;
      if ((L_M12_GROUP == expandergroup) && (L_M12_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M12_ADDR_WIDTH;
      if ((L_M13_GROUP == expandergroup) && (L_M13_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M13_ADDR_WIDTH;
      if ((L_M14_GROUP == expandergroup) && (L_M14_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M14_ADDR_WIDTH;
      if ((L_M15_GROUP == expandergroup) && (L_M15_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M15_ADDR_WIDTH;
      if ((L_M16_GROUP == expandergroup) && (L_M16_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M16_ADDR_WIDTH;
      if ((L_M17_GROUP == expandergroup) && (L_M17_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M17_ADDR_WIDTH;
      if ((L_M18_GROUP == expandergroup) && (L_M18_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M18_ADDR_WIDTH;
      if ((L_M19_GROUP == expandergroup) && (L_M19_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M19_ADDR_WIDTH;
      if ((L_M20_GROUP == expandergroup) && (L_M20_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M20_ADDR_WIDTH;
      if ((L_M21_GROUP == expandergroup) && (L_M21_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M21_ADDR_WIDTH;
      if ((L_M22_GROUP == expandergroup) && (L_M22_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M22_ADDR_WIDTH;
      if ((L_M23_GROUP == expandergroup) && (L_M23_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M23_ADDR_WIDTH;
      if ((L_M24_GROUP == expandergroup) && (L_M24_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M24_ADDR_WIDTH;
      if ((L_M25_GROUP == expandergroup) && (L_M25_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M25_ADDR_WIDTH;
      if ((L_M26_GROUP == expandergroup) && (L_M26_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M26_ADDR_WIDTH;
      if ((L_M27_GROUP == expandergroup) && (L_M27_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M27_ADDR_WIDTH;
      if ((L_M28_GROUP == expandergroup) && (L_M28_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M28_ADDR_WIDTH;
      if ((L_M29_GROUP == expandergroup) && (L_M29_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M29_ADDR_WIDTH;
      if ((L_M30_GROUP == expandergroup) && (L_M30_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M30_ADDR_WIDTH;
      if ((L_M31_GROUP == expandergroup) && (L_M31_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M31_ADDR_WIDTH;
      if ((L_M32_GROUP == expandergroup) && (L_M32_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M32_ADDR_WIDTH;
      if ((L_M33_GROUP == expandergroup) && (L_M33_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M33_ADDR_WIDTH;
      if ((L_M34_GROUP == expandergroup) && (L_M34_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M34_ADDR_WIDTH;
      if ((L_M35_GROUP == expandergroup) && (L_M35_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M35_ADDR_WIDTH;
      if ((L_M36_GROUP == expandergroup) && (L_M36_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M36_ADDR_WIDTH;
      if ((L_M37_GROUP == expandergroup) && (L_M37_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M37_ADDR_WIDTH;
      if ((L_M38_GROUP == expandergroup) && (L_M38_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M38_ADDR_WIDTH;
      if ((L_M39_GROUP == expandergroup) && (L_M39_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M39_ADDR_WIDTH;
      if ((L_M40_GROUP == expandergroup) && (L_M40_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M40_ADDR_WIDTH;
      if ((L_M41_GROUP == expandergroup) && (L_M41_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M41_ADDR_WIDTH;
      if ((L_M42_GROUP == expandergroup) && (L_M42_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M42_ADDR_WIDTH;
      if ((L_M43_GROUP == expandergroup) && (L_M43_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M43_ADDR_WIDTH;
      if ((L_M44_GROUP == expandergroup) && (L_M44_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M44_ADDR_WIDTH;
      if ((L_M45_GROUP == expandergroup) && (L_M45_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M45_ADDR_WIDTH;
      if ((L_M46_GROUP == expandergroup) && (L_M46_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M46_ADDR_WIDTH;
      if ((L_M47_GROUP == expandergroup) && (L_M47_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M47_ADDR_WIDTH;
      if ((L_M48_GROUP == expandergroup) && (L_M48_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M48_ADDR_WIDTH;
      if ((L_M49_GROUP == expandergroup) && (L_M49_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M49_ADDR_WIDTH;
      if ((L_M50_GROUP == expandergroup) && (L_M50_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M50_ADDR_WIDTH;
      if ((L_M51_GROUP == expandergroup) && (L_M51_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M51_ADDR_WIDTH;
      if ((L_M52_GROUP == expandergroup) && (L_M52_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M52_ADDR_WIDTH;
      if ((L_M53_GROUP == expandergroup) && (L_M53_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M53_ADDR_WIDTH;
      if ((L_M54_GROUP == expandergroup) && (L_M54_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M54_ADDR_WIDTH;
      if ((L_M55_GROUP == expandergroup) && (L_M55_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M55_ADDR_WIDTH;
      if ((L_M56_GROUP == expandergroup) && (L_M56_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M56_ADDR_WIDTH;
      if ((L_M57_GROUP == expandergroup) && (L_M57_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M57_ADDR_WIDTH;
      if ((L_M58_GROUP == expandergroup) && (L_M58_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M58_ADDR_WIDTH;
      if ((L_M59_GROUP == expandergroup) && (L_M59_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M59_ADDR_WIDTH;
      if ((L_M60_GROUP == expandergroup) && (L_M60_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M60_ADDR_WIDTH;
      if ((L_M61_GROUP == expandergroup) && (L_M61_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M61_ADDR_WIDTH;
      if ((L_M62_GROUP == expandergroup) && (L_M62_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M62_ADDR_WIDTH;
      if ((L_M63_GROUP == expandergroup) && (L_M63_ADDR_WIDTH > max_addr_width)) max_addr_width = L_M63_ADDR_WIDTH;
    end
  endfunction

