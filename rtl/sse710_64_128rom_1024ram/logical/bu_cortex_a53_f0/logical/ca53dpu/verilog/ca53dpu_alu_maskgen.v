//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Mask generator for Ex1 stage of pipeline
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block generates a mask value used for bitfield instructions
//
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_maskgen (
  // Inputs
  input  wire   [5:0] mask_gen_data_ex1_i,
  // Outputs
  output wire  [63:0] mask_data_ex1_o
);

  // Function to generate a mask, with (num_bits + 1) least significant bits set
  function [63:0] f_mask_gen;
    input [5:0] num_bits;
    begin
      case (num_bits)
        6'b000000    : f_mask_gen = 64'h0000_0000_0000_0001;
        6'b000001    : f_mask_gen = 64'h0000_0000_0000_0003;
        6'b000010    : f_mask_gen = 64'h0000_0000_0000_0007;
        6'b000011    : f_mask_gen = 64'h0000_0000_0000_000F;
        6'b000100    : f_mask_gen = 64'h0000_0000_0000_001F;
        6'b000101    : f_mask_gen = 64'h0000_0000_0000_003F;
        6'b000110    : f_mask_gen = 64'h0000_0000_0000_007F;
        6'b000111    : f_mask_gen = 64'h0000_0000_0000_00FF;
        6'b001000    : f_mask_gen = 64'h0000_0000_0000_01FF;
        6'b001001    : f_mask_gen = 64'h0000_0000_0000_03FF;
        6'b001010    : f_mask_gen = 64'h0000_0000_0000_07FF;
        6'b001011    : f_mask_gen = 64'h0000_0000_0000_0FFF;
        6'b001100    : f_mask_gen = 64'h0000_0000_0000_1FFF;
        6'b001101    : f_mask_gen = 64'h0000_0000_0000_3FFF;
        6'b001110    : f_mask_gen = 64'h0000_0000_0000_7FFF;
        6'b001111    : f_mask_gen = 64'h0000_0000_0000_FFFF;
        6'b010000    : f_mask_gen = 64'h0000_0000_0001_FFFF;
        6'b010001    : f_mask_gen = 64'h0000_0000_0003_FFFF;
        6'b010010    : f_mask_gen = 64'h0000_0000_0007_FFFF;
        6'b010011    : f_mask_gen = 64'h0000_0000_000F_FFFF;
        6'b010100    : f_mask_gen = 64'h0000_0000_001F_FFFF;
        6'b010101    : f_mask_gen = 64'h0000_0000_003F_FFFF;
        6'b010110    : f_mask_gen = 64'h0000_0000_007F_FFFF;
        6'b010111    : f_mask_gen = 64'h0000_0000_00FF_FFFF;
        6'b011000    : f_mask_gen = 64'h0000_0000_01FF_FFFF;
        6'b011001    : f_mask_gen = 64'h0000_0000_03FF_FFFF;
        6'b011010    : f_mask_gen = 64'h0000_0000_07FF_FFFF;
        6'b011011    : f_mask_gen = 64'h0000_0000_0FFF_FFFF;
        6'b011100    : f_mask_gen = 64'h0000_0000_1FFF_FFFF;
        6'b011101    : f_mask_gen = 64'h0000_0000_3FFF_FFFF;
        6'b011110    : f_mask_gen = 64'h0000_0000_7FFF_FFFF;
        6'b011111    : f_mask_gen = 64'h0000_0000_FFFF_FFFF;
        6'b100000    : f_mask_gen = 64'h0000_0001_FFFF_FFFF;
        6'b100001    : f_mask_gen = 64'h0000_0003_FFFF_FFFF;
        6'b100010    : f_mask_gen = 64'h0000_0007_FFFF_FFFF;
        6'b100011    : f_mask_gen = 64'h0000_000F_FFFF_FFFF;
        6'b100100    : f_mask_gen = 64'h0000_001F_FFFF_FFFF;
        6'b100101    : f_mask_gen = 64'h0000_003F_FFFF_FFFF;
        6'b100110    : f_mask_gen = 64'h0000_007F_FFFF_FFFF;
        6'b100111    : f_mask_gen = 64'h0000_00FF_FFFF_FFFF;
        6'b101000    : f_mask_gen = 64'h0000_01FF_FFFF_FFFF;
        6'b101001    : f_mask_gen = 64'h0000_03FF_FFFF_FFFF;
        6'b101010    : f_mask_gen = 64'h0000_07FF_FFFF_FFFF;
        6'b101011    : f_mask_gen = 64'h0000_0FFF_FFFF_FFFF;
        6'b101100    : f_mask_gen = 64'h0000_1FFF_FFFF_FFFF;
        6'b101101    : f_mask_gen = 64'h0000_3FFF_FFFF_FFFF;
        6'b101110    : f_mask_gen = 64'h0000_7FFF_FFFF_FFFF;
        6'b101111    : f_mask_gen = 64'h0000_FFFF_FFFF_FFFF;
        6'b110000    : f_mask_gen = 64'h0001_FFFF_FFFF_FFFF;
        6'b110001    : f_mask_gen = 64'h0003_FFFF_FFFF_FFFF;
        6'b110010    : f_mask_gen = 64'h0007_FFFF_FFFF_FFFF;
        6'b110011    : f_mask_gen = 64'h000F_FFFF_FFFF_FFFF;
        6'b110100    : f_mask_gen = 64'h001F_FFFF_FFFF_FFFF;
        6'b110101    : f_mask_gen = 64'h003F_FFFF_FFFF_FFFF;
        6'b110110    : f_mask_gen = 64'h007F_FFFF_FFFF_FFFF;
        6'b110111    : f_mask_gen = 64'h00FF_FFFF_FFFF_FFFF;
        6'b111000    : f_mask_gen = 64'h01FF_FFFF_FFFF_FFFF;
        6'b111001    : f_mask_gen = 64'h03FF_FFFF_FFFF_FFFF;
        6'b111010    : f_mask_gen = 64'h07FF_FFFF_FFFF_FFFF;
        6'b111011    : f_mask_gen = 64'h0FFF_FFFF_FFFF_FFFF;
        6'b111100    : f_mask_gen = 64'h1FFF_FFFF_FFFF_FFFF;
        6'b111101    : f_mask_gen = 64'h3FFF_FFFF_FFFF_FFFF;
        6'b111110    : f_mask_gen = 64'h7FFF_FFFF_FFFF_FFFF;
        6'b111111    : f_mask_gen = 64'hFFFF_FFFF_FFFF_FFFF;
        default      : f_mask_gen = 64'hxxxx_xxxx_xxxx_xxxx;
      endcase
    end
  endfunction

  assign mask_data_ex1_o = f_mask_gen(mask_gen_data_ex1_i);

endmodule // ca53dpu_alu_maskgen

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
