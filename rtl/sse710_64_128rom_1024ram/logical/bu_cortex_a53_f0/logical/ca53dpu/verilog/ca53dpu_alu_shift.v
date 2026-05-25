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
// Abstract: Main Shift Function generator For Ex1 Stage of Alu Pipeline.
// ----------------------------------------------------------------------------
//
// Overview
// ========
// This block instantiates the barrel shifter module.
//
// This block encodes the shift value required to pass to the barrel shifter
// to achieve the required shift operation.
//
// The shifts that are implemented are
//
// a) LSL  - Logical Shift Left
// b) LSR  - Logical Shift right
// c) ASR  - Arithmetic Shift right
// d) ROR  - Rotate right
// d) EXTR - Extract
//
//----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_alu_shift (
  //Inputs
  input  wire         aarch64_state_ex1_i,        // Processor is in AArch64
  input  wire  [63:0] alu_data_a_ex1_i,           // Second input data used for AArch64 EXTR
  input  wire  [63:0] alu_data_b_ex1_i,           // Input data
  input  wire   [7:0] alu_data_c_ex1_i,           // Shift distance
  input  wire         shift_op_right_shift_ex1_i, // Shift operation - right shift
  input  wire         shift_op_left_shift_ex1_i,  // Shift operation - left shift
  input  wire         shift_op_extr_instr_ex1_i,  // Shift operation - extr
  input  wire   [2:0] shift_op_ex1_i,             // Shift operation - mux control
  input  wire         shift_rrx_for_0_ex1_i,      // Special RRX operation.
  input  wire         ctl_64bit_op_ex1_i,         // 64 bit enable
  // Outputs
  output wire         shift_rrx_ex1_o,            // Did an RRX
  output wire  [63:0] shift_data_out_ex1_o,       // Output data
  output reg          shift_carry_out_ex1_o,      // Carry out
  output reg          shift_carry_valid_ex1_o,    // Carry out valid
  output wire  [63:0] shift_mask_ex1_o            // Mask output
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [63:0] rotate_out;
  reg         sign_mask_bit;
  reg  [63:0] force_mask;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [5:0] left_shift_value;
  wire  [5:0] right_shift_value;
  wire  [5:0] left_shift_amount;
  wire  [5:0] right_shift_amount;
  wire  [5:0] shift_amount;
  wire        shift_rrx_ex1;
  wire        shift_gte;           // Shift greater than or equals to the word size (32)
  wire        shift_gt;            // Shift greater that word size (32)
  wire        shift_0;
  wire [63:0] shift_mask;
  wire [31:1] shift_input_ls;
  wire [62:0] shift_input_2;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Function to generate a mask, with the num_bits least significant bits set
  function [63:0] f_mask_gen;
    input [5:0] num_bits;
    begin
      case (num_bits)
        6'b000000    : f_mask_gen = 64'h0000_0000_0000_0000;
        6'b000001    : f_mask_gen = 64'h0000_0000_0000_0001;
        6'b000010    : f_mask_gen = 64'h0000_0000_0000_0003;
        6'b000011    : f_mask_gen = 64'h0000_0000_0000_0007;
        6'b000100    : f_mask_gen = 64'h0000_0000_0000_000F;
        6'b000101    : f_mask_gen = 64'h0000_0000_0000_001F;
        6'b000110    : f_mask_gen = 64'h0000_0000_0000_003F;
        6'b000111    : f_mask_gen = 64'h0000_0000_0000_007F;
        6'b001000    : f_mask_gen = 64'h0000_0000_0000_00FF;
        6'b001001    : f_mask_gen = 64'h0000_0000_0000_01FF;
        6'b001010    : f_mask_gen = 64'h0000_0000_0000_03FF;
        6'b001011    : f_mask_gen = 64'h0000_0000_0000_07FF;
        6'b001100    : f_mask_gen = 64'h0000_0000_0000_0FFF;
        6'b001101    : f_mask_gen = 64'h0000_0000_0000_1FFF;
        6'b001110    : f_mask_gen = 64'h0000_0000_0000_3FFF;
        6'b001111    : f_mask_gen = 64'h0000_0000_0000_7FFF;
        6'b010000    : f_mask_gen = 64'h0000_0000_0000_FFFF;
        6'b010001    : f_mask_gen = 64'h0000_0000_0001_FFFF;
        6'b010010    : f_mask_gen = 64'h0000_0000_0003_FFFF;
        6'b010011    : f_mask_gen = 64'h0000_0000_0007_FFFF;
        6'b010100    : f_mask_gen = 64'h0000_0000_000F_FFFF;
        6'b010101    : f_mask_gen = 64'h0000_0000_001F_FFFF;
        6'b010110    : f_mask_gen = 64'h0000_0000_003F_FFFF;
        6'b010111    : f_mask_gen = 64'h0000_0000_007F_FFFF;
        6'b011000    : f_mask_gen = 64'h0000_0000_00FF_FFFF;
        6'b011001    : f_mask_gen = 64'h0000_0000_01FF_FFFF;
        6'b011010    : f_mask_gen = 64'h0000_0000_03FF_FFFF;
        6'b011011    : f_mask_gen = 64'h0000_0000_07FF_FFFF;
        6'b011100    : f_mask_gen = 64'h0000_0000_0FFF_FFFF;
        6'b011101    : f_mask_gen = 64'h0000_0000_1FFF_FFFF;
        6'b011110    : f_mask_gen = 64'h0000_0000_3FFF_FFFF;
        6'b011111    : f_mask_gen = 64'h0000_0000_7FFF_FFFF;
        6'b100000    : f_mask_gen = 64'h0000_0000_FFFF_FFFF;
        6'b100001    : f_mask_gen = 64'h0000_0001_FFFF_FFFF;
        6'b100010    : f_mask_gen = 64'h0000_0003_FFFF_FFFF;
        6'b100011    : f_mask_gen = 64'h0000_0007_FFFF_FFFF;
        6'b100100    : f_mask_gen = 64'h0000_000F_FFFF_FFFF;
        6'b100101    : f_mask_gen = 64'h0000_001F_FFFF_FFFF;
        6'b100110    : f_mask_gen = 64'h0000_003F_FFFF_FFFF;
        6'b100111    : f_mask_gen = 64'h0000_007F_FFFF_FFFF;
        6'b101000    : f_mask_gen = 64'h0000_00FF_FFFF_FFFF;
        6'b101001    : f_mask_gen = 64'h0000_01FF_FFFF_FFFF;
        6'b101010    : f_mask_gen = 64'h0000_03FF_FFFF_FFFF;
        6'b101011    : f_mask_gen = 64'h0000_07FF_FFFF_FFFF;
        6'b101100    : f_mask_gen = 64'h0000_0FFF_FFFF_FFFF;
        6'b101101    : f_mask_gen = 64'h0000_1FFF_FFFF_FFFF;
        6'b101110    : f_mask_gen = 64'h0000_3FFF_FFFF_FFFF;
        6'b101111    : f_mask_gen = 64'h0000_7FFF_FFFF_FFFF;
        6'b110000    : f_mask_gen = 64'h0000_FFFF_FFFF_FFFF;
        6'b110001    : f_mask_gen = 64'h0001_FFFF_FFFF_FFFF;
        6'b110010    : f_mask_gen = 64'h0003_FFFF_FFFF_FFFF;
        6'b110011    : f_mask_gen = 64'h0007_FFFF_FFFF_FFFF;
        6'b110100    : f_mask_gen = 64'h000F_FFFF_FFFF_FFFF;
        6'b110101    : f_mask_gen = 64'h001F_FFFF_FFFF_FFFF;
        6'b110110    : f_mask_gen = 64'h003F_FFFF_FFFF_FFFF;
        6'b110111    : f_mask_gen = 64'h007F_FFFF_FFFF_FFFF;
        6'b111000    : f_mask_gen = 64'h00FF_FFFF_FFFF_FFFF;
        6'b111001    : f_mask_gen = 64'h01FF_FFFF_FFFF_FFFF;
        6'b111010    : f_mask_gen = 64'h03FF_FFFF_FFFF_FFFF;
        6'b111011    : f_mask_gen = 64'h07FF_FFFF_FFFF_FFFF;
        6'b111100    : f_mask_gen = 64'h0FFF_FFFF_FFFF_FFFF;
        6'b111101    : f_mask_gen = 64'h1FFF_FFFF_FFFF_FFFF;
        6'b111110    : f_mask_gen = 64'h3FFF_FFFF_FFFF_FFFF;
        6'b111111    : f_mask_gen = 64'h7FFF_FFFF_FFFF_FFFF;
        default      : f_mask_gen = 64'hxxxx_xxxx_xxxx_xxxx;
      endcase
    end
  endfunction

  // ------------------------------------------------------
  // Compute rotation
  // ------------------------------------------------------
  // Compute the amount that the data needs to be rotated by, according to the
  // shift operation that is required

  assign left_shift_value   = (            alu_data_c_ex1_i[5:0]);
  assign right_shift_value  = (6'b000000 - alu_data_c_ex1_i[5:0]);
  assign left_shift_amount  = ctl_64bit_op_ex1_i ? left_shift_value  : {1'b0, left_shift_value[4:0]};
  assign right_shift_amount = ctl_64bit_op_ex1_i ? right_shift_value : {1'b0, right_shift_value[4:0]};

  assign shift_amount[5:0] = (({6{shift_op_right_shift_ex1_i}} & right_shift_amount[5:0]) |
                              ({6{shift_op_left_shift_ex1_i}}  & left_shift_amount[5:0]));

  // ------------------------------------------------------
  // Barrel shifter (rotate left function only)
  // ------------------------------------------------------

  assign shift_input_ls[31:1] = ctl_64bit_op_ex1_i ? alu_data_b_ex1_i[63:33] : alu_data_b_ex1_i[31:1];

  assign shift_input_2        = shift_op_extr_instr_ex1_i ? alu_data_a_ex1_i[62:0] : alu_data_b_ex1_i[62:0];

  always @*
    case (shift_amount[5:0])
      6'b000000 : rotate_out[31:0] = {alu_data_b_ex1_i[31:0]                        };
      6'b000001 : rotate_out[31:0] = {shift_input_2[30:0],     shift_input_ls[31]   };
      6'b000010 : rotate_out[31:0] = {shift_input_2[29:0],     shift_input_ls[31:30]};
      6'b000011 : rotate_out[31:0] = {shift_input_2[28:0],     shift_input_ls[31:29]};
      6'b000100 : rotate_out[31:0] = {shift_input_2[27:0],     shift_input_ls[31:28]};
      6'b000101 : rotate_out[31:0] = {shift_input_2[26:0],     shift_input_ls[31:27]};
      6'b000110 : rotate_out[31:0] = {shift_input_2[25:0],     shift_input_ls[31:26]};
      6'b000111 : rotate_out[31:0] = {shift_input_2[24:0],     shift_input_ls[31:25]};
      6'b001000 : rotate_out[31:0] = {shift_input_2[23:0],     shift_input_ls[31:24]};
      6'b001001 : rotate_out[31:0] = {shift_input_2[22:0],     shift_input_ls[31:23]};
      6'b001010 : rotate_out[31:0] = {shift_input_2[21:0],     shift_input_ls[31:22]};
      6'b001011 : rotate_out[31:0] = {shift_input_2[20:0],     shift_input_ls[31:21]};
      6'b001100 : rotate_out[31:0] = {shift_input_2[19:0],     shift_input_ls[31:20]};
      6'b001101 : rotate_out[31:0] = {shift_input_2[18:0],     shift_input_ls[31:19]};
      6'b001110 : rotate_out[31:0] = {shift_input_2[17:0],     shift_input_ls[31:18]};
      6'b001111 : rotate_out[31:0] = {shift_input_2[16:0],     shift_input_ls[31:17]};
      6'b010000 : rotate_out[31:0] = {shift_input_2[15:0],     shift_input_ls[31:16]};
      6'b010001 : rotate_out[31:0] = {shift_input_2[14:0],     shift_input_ls[31:15]};
      6'b010010 : rotate_out[31:0] = {shift_input_2[13:0],     shift_input_ls[31:14]};
      6'b010011 : rotate_out[31:0] = {shift_input_2[12:0],     shift_input_ls[31:13]};
      6'b010100 : rotate_out[31:0] = {shift_input_2[11:0],     shift_input_ls[31:12]};
      6'b010101 : rotate_out[31:0] = {shift_input_2[10:0],     shift_input_ls[31:11]};
      6'b010110 : rotate_out[31:0] = {shift_input_2[ 9:0],     shift_input_ls[31:10]};
      6'b010111 : rotate_out[31:0] = {shift_input_2[ 8:0],     shift_input_ls[31: 9]};
      6'b011000 : rotate_out[31:0] = {shift_input_2[ 7:0],     shift_input_ls[31: 8]};
      6'b011001 : rotate_out[31:0] = {shift_input_2[ 6:0],     shift_input_ls[31: 7]};
      6'b011010 : rotate_out[31:0] = {shift_input_2[ 5:0],     shift_input_ls[31: 6]};
      6'b011011 : rotate_out[31:0] = {shift_input_2[ 4:0],     shift_input_ls[31: 5]};
      6'b011100 : rotate_out[31:0] = {shift_input_2[ 3:0],     shift_input_ls[31: 4]};
      6'b011101 : rotate_out[31:0] = {shift_input_2[ 2:0],     shift_input_ls[31: 3]};
      6'b011110 : rotate_out[31:0] = {shift_input_2[ 1:0],     shift_input_ls[31: 2]};
      6'b011111 : rotate_out[31:0] = {shift_input_2[   0],     shift_input_ls[31: 1]};
      6'b100000 : rotate_out[31:0] = {alu_data_b_ex1_i[63:32]                       };
      6'b100001 : rotate_out[31:0] = {alu_data_b_ex1_i[62:31]                       };
      6'b100010 : rotate_out[31:0] = {alu_data_b_ex1_i[61:30]                       };
      6'b100011 : rotate_out[31:0] = {alu_data_b_ex1_i[60:29]                       };
      6'b100100 : rotate_out[31:0] = {alu_data_b_ex1_i[59:28]                       };
      6'b100101 : rotate_out[31:0] = {alu_data_b_ex1_i[58:27]                       };
      6'b100110 : rotate_out[31:0] = {alu_data_b_ex1_i[57:26]                       };
      6'b100111 : rotate_out[31:0] = {alu_data_b_ex1_i[56:25]                       };
      6'b101000 : rotate_out[31:0] = {alu_data_b_ex1_i[55:24]                       };
      6'b101001 : rotate_out[31:0] = {alu_data_b_ex1_i[54:23]                       };
      6'b101010 : rotate_out[31:0] = {alu_data_b_ex1_i[53:22]                       };
      6'b101011 : rotate_out[31:0] = {alu_data_b_ex1_i[52:21]                       };
      6'b101100 : rotate_out[31:0] = {alu_data_b_ex1_i[51:20]                       };
      6'b101101 : rotate_out[31:0] = {alu_data_b_ex1_i[50:19]                       };
      6'b101110 : rotate_out[31:0] = {alu_data_b_ex1_i[49:18]                       };
      6'b101111 : rotate_out[31:0] = {alu_data_b_ex1_i[48:17]                       };
      6'b110000 : rotate_out[31:0] = {alu_data_b_ex1_i[47:16]                       };
      6'b110001 : rotate_out[31:0] = {alu_data_b_ex1_i[46:15]                       };
      6'b110010 : rotate_out[31:0] = {alu_data_b_ex1_i[45:14]                       };
      6'b110011 : rotate_out[31:0] = {alu_data_b_ex1_i[44:13]                       };
      6'b110100 : rotate_out[31:0] = {alu_data_b_ex1_i[43:12]                       };
      6'b110101 : rotate_out[31:0] = {alu_data_b_ex1_i[42:11]                       };
      6'b110110 : rotate_out[31:0] = {alu_data_b_ex1_i[41:10]                       };
      6'b110111 : rotate_out[31:0] = {alu_data_b_ex1_i[40: 9]                       };
      6'b111000 : rotate_out[31:0] = {alu_data_b_ex1_i[39: 8]                       };
      6'b111001 : rotate_out[31:0] = {alu_data_b_ex1_i[38: 7]                       };
      6'b111010 : rotate_out[31:0] = {alu_data_b_ex1_i[37: 6]                       };
      6'b111011 : rotate_out[31:0] = {alu_data_b_ex1_i[36: 5]                       };
      6'b111100 : rotate_out[31:0] = {alu_data_b_ex1_i[35: 4]                       };
      6'b111101 : rotate_out[31:0] = {alu_data_b_ex1_i[34: 3]                       };
      6'b111110 : rotate_out[31:0] = {alu_data_b_ex1_i[33: 2]                       };
      6'b111111 : rotate_out[31:0] = {alu_data_b_ex1_i[32: 1]                       };
      default   : rotate_out[31:0] = 32'hxxxx_xxxx;
    endcase

  always @*
    case (shift_amount[5:0])
      6'b000000 : rotate_out[63:32] = {alu_data_b_ex1_i[63:32]                      };
      6'b000001 : rotate_out[63:32] = {shift_input_2[62:31]                         };
      6'b000010 : rotate_out[63:32] = {shift_input_2[61:30]                         };
      6'b000011 : rotate_out[63:32] = {shift_input_2[60:29]                         };
      6'b000100 : rotate_out[63:32] = {shift_input_2[59:28]                         };
      6'b000101 : rotate_out[63:32] = {shift_input_2[58:27]                         };
      6'b000110 : rotate_out[63:32] = {shift_input_2[57:26]                         };
      6'b000111 : rotate_out[63:32] = {shift_input_2[56:25]                         };
      6'b001000 : rotate_out[63:32] = {shift_input_2[55:24]                         };
      6'b001001 : rotate_out[63:32] = {shift_input_2[54:23]                         };
      6'b001010 : rotate_out[63:32] = {shift_input_2[53:22]                         };
      6'b001011 : rotate_out[63:32] = {shift_input_2[52:21]                         };
      6'b001100 : rotate_out[63:32] = {shift_input_2[51:20]                         };
      6'b001101 : rotate_out[63:32] = {shift_input_2[50:19]                         };
      6'b001110 : rotate_out[63:32] = {shift_input_2[49:18]                         };
      6'b001111 : rotate_out[63:32] = {shift_input_2[48:17]                         };
      6'b010000 : rotate_out[63:32] = {shift_input_2[47:16]                         };
      6'b010001 : rotate_out[63:32] = {shift_input_2[46:15]                         };
      6'b010010 : rotate_out[63:32] = {shift_input_2[45:14]                         };
      6'b010011 : rotate_out[63:32] = {shift_input_2[44:13]                         };
      6'b010100 : rotate_out[63:32] = {shift_input_2[43:12]                         };
      6'b010101 : rotate_out[63:32] = {shift_input_2[42:11]                         };
      6'b010110 : rotate_out[63:32] = {shift_input_2[41:10]                         };
      6'b010111 : rotate_out[63:32] = {shift_input_2[40: 9]                         };
      6'b011000 : rotate_out[63:32] = {shift_input_2[39: 8]                         };
      6'b011001 : rotate_out[63:32] = {shift_input_2[38: 7]                         };
      6'b011010 : rotate_out[63:32] = {shift_input_2[37: 6]                         };
      6'b011011 : rotate_out[63:32] = {shift_input_2[36: 5]                         };
      6'b011100 : rotate_out[63:32] = {shift_input_2[35: 4]                         };
      6'b011101 : rotate_out[63:32] = {shift_input_2[34: 3]                         };
      6'b011110 : rotate_out[63:32] = {shift_input_2[33: 2]                         };
      6'b011111 : rotate_out[63:32] = {shift_input_2[32: 1]                         };
      6'b100000 : rotate_out[63:32] = {shift_input_2[31: 0]                         };
      6'b100001 : rotate_out[63:32] = {shift_input_2[30: 0], alu_data_b_ex1_i[63]   };
      6'b100010 : rotate_out[63:32] = {shift_input_2[29: 0], alu_data_b_ex1_i[63:62]};
      6'b100011 : rotate_out[63:32] = {shift_input_2[28: 0], alu_data_b_ex1_i[63:61]};
      6'b100100 : rotate_out[63:32] = {shift_input_2[27: 0], alu_data_b_ex1_i[63:60]};
      6'b100101 : rotate_out[63:32] = {shift_input_2[26: 0], alu_data_b_ex1_i[63:59]};
      6'b100110 : rotate_out[63:32] = {shift_input_2[25: 0], alu_data_b_ex1_i[63:58]};
      6'b100111 : rotate_out[63:32] = {shift_input_2[24: 0], alu_data_b_ex1_i[63:57]};
      6'b101000 : rotate_out[63:32] = {shift_input_2[23: 0], alu_data_b_ex1_i[63:56]};
      6'b101001 : rotate_out[63:32] = {shift_input_2[22: 0], alu_data_b_ex1_i[63:55]};
      6'b101010 : rotate_out[63:32] = {shift_input_2[21: 0], alu_data_b_ex1_i[63:54]};
      6'b101011 : rotate_out[63:32] = {shift_input_2[20: 0], alu_data_b_ex1_i[63:53]};
      6'b101100 : rotate_out[63:32] = {shift_input_2[19: 0], alu_data_b_ex1_i[63:52]};
      6'b101101 : rotate_out[63:32] = {shift_input_2[18: 0], alu_data_b_ex1_i[63:51]};
      6'b101110 : rotate_out[63:32] = {shift_input_2[17: 0], alu_data_b_ex1_i[63:50]};
      6'b101111 : rotate_out[63:32] = {shift_input_2[16: 0], alu_data_b_ex1_i[63:49]};
      6'b110000 : rotate_out[63:32] = {shift_input_2[15: 0], alu_data_b_ex1_i[63:48]};
      6'b110001 : rotate_out[63:32] = {shift_input_2[14: 0], alu_data_b_ex1_i[63:47]};
      6'b110010 : rotate_out[63:32] = {shift_input_2[13: 0], alu_data_b_ex1_i[63:46]};
      6'b110011 : rotate_out[63:32] = {shift_input_2[12: 0], alu_data_b_ex1_i[63:45]};
      6'b110100 : rotate_out[63:32] = {shift_input_2[11: 0], alu_data_b_ex1_i[63:44]};
      6'b110101 : rotate_out[63:32] = {shift_input_2[10: 0], alu_data_b_ex1_i[63:43]};
      6'b110110 : rotate_out[63:32] = {shift_input_2[ 9: 0], alu_data_b_ex1_i[63:42]};
      6'b110111 : rotate_out[63:32] = {shift_input_2[ 8: 0], alu_data_b_ex1_i[63:41]};
      6'b111000 : rotate_out[63:32] = {shift_input_2[ 7: 0], alu_data_b_ex1_i[63:40]};
      6'b111001 : rotate_out[63:32] = {shift_input_2[ 6: 0], alu_data_b_ex1_i[63:39]};
      6'b111010 : rotate_out[63:32] = {shift_input_2[ 5: 0], alu_data_b_ex1_i[63:38]};
      6'b111011 : rotate_out[63:32] = {shift_input_2[ 4: 0], alu_data_b_ex1_i[63:37]};
      6'b111100 : rotate_out[63:32] = {shift_input_2[ 3: 0], alu_data_b_ex1_i[63:36]};
      6'b111101 : rotate_out[63:32] = {shift_input_2[ 2: 0], alu_data_b_ex1_i[63:35]};
      6'b111110 : rotate_out[63:32] = {shift_input_2[ 1: 0], alu_data_b_ex1_i[63:34]};
      6'b111111 : rotate_out[63:32] = {shift_input_2[    0], alu_data_b_ex1_i[63:33]};
      default   : rotate_out[63:32] = 32'hxxxx_xxxx;
    endcase

  // ------------------------------------------------------
  // Mask and sign-extend functions
  // ------------------------------------------------------
  // The following functions determine the size of the shift that is required

  // The raw data_c may actually be >= 32, but only in AArch32
  // In AArch64, the shift amount is always modulo the data size
  assign shift_gte = ~aarch64_state_ex1_i & (|alu_data_c_ex1_i[7:5]); // Raw shift data >= 32

  // Straightforward computation of whether data_c > number of bits (32)
  assign shift_gt  = ~aarch64_state_ex1_i & (|alu_data_c_ex1_i[7:6] | (alu_data_c_ex1_i[5] & (|alu_data_c_ex1_i[4:0])));

  // A shift of 0 is required whenever data_c == 0
  assign shift_0  = ctl_64bit_op_ex1_i  ? (alu_data_c_ex1_i[5:0] ==   6'b00_0000) :
                    aarch64_state_ex1_i ? (alu_data_c_ex1_i[4:0] ==    5'b0_0000) :
                                          (alu_data_c_ex1_i[7:0] == 8'b0000_0000);

  assign shift_rrx_ex1 = shift_rrx_for_0_ex1_i;

  // A mask is generated based on the shift amount
  assign shift_mask = f_mask_gen(shift_amount[5:0]);

  // The following process selects the sign_mask_bit and force_mask used to
  // generate the output data from the shifter.  It also selects the carry out
  // and the carry_valid output according to the shift function required.
  always @*
    case (shift_op_ex1_i)

      // Logical shift left
      //
      //  - Shifted data should be filled with zeros from the right (lsb).
      //  - A shift of >= num data bits (32 or 64) should cause the whole data to be zeroed.
      //  - The carry out is the last bit shifted off the left of the data (which
      //    will have been rotated into position [0]. If the shift is > 32, then
      //    the carry out will be zero.
      //  - For a shift of zero, the carry flag is preserved.
      `CA53_SHIFT_OP_NOP,
      `CA53_SHIFT_OP_LSL : begin
        sign_mask_bit           = 1'b0;
        force_mask              =  shift_mask | {64{shift_gte}};
        shift_carry_out_ex1_o   = rotate_out[0] & ~shift_gt;
        shift_carry_valid_ex1_o = ~shift_0;
      end

      // Arithmetic shift right
      //
      //  - Shifted data should be filled with the sign bit of the original
      //    data (bit [31] or bit [63]) from the right (msb).
      //  - A shift of >= num data bits (32 or 64) should cause the whole data to be sign extended.
      //  - A shift of 0 should cause no sign extension.
      //  - The carry out is the last bit shifted off the right of the data (which
      //    will have been rotated into position [31]. If the shift is >= 32, then
      //    the carry out will be the sign bit. (Only need to consider 32-bit case
      //    here, as AArch64 doesn't set the carry bit from a shift)
      //  - For a shift of zero, the carry flag is preserved.
      `CA53_SHIFT_OP_ASR : begin
        sign_mask_bit           = ctl_64bit_op_ex1_i ? alu_data_b_ex1_i[63] : alu_data_b_ex1_i[31];
        force_mask              = (~shift_mask | {64{shift_gte}}) & {64{~shift_0}};
        shift_carry_out_ex1_o   = shift_gt ? alu_data_b_ex1_i[31] : rotate_out[31];
        shift_carry_valid_ex1_o = ~shift_0;
      end

      // Logical shift right
      //
      //  - Shifted data should be filled with zeros from the right (msb).
      //  - A shift of >= num data bits (32 or 64) should cause the whole data to be zeroed.
      //  - The carry out is the last bit shifted off the right of the data (which
      //    will have been rotated into position [31].  If the shift is > 32, then
      //    the carry out will be zero. (Only need to consider 32-bit case
      //    here, as AArch64 doesn't set the carry bit from a shift)
      //  - For a shift of zero, the carry flag is
      //    preserved.
      `CA53_SHIFT_OP_LSR : begin
        sign_mask_bit           = 1'b0;
        force_mask              = (~shift_mask | {64{shift_gte}}) & {64{~shift_0}};
        shift_carry_out_ex1_o   = ~shift_gt & rotate_out[31];
        shift_carry_valid_ex1_o = ~shift_0;
      end

      // Rotate right
      //
      //  - Data should simply be rotated (no masking or sign extension)
      //  - The carry out is the last bit shifted off the right of the data (which
      //    will have been rotated into position [31]. (Only need to consider 32-bit
      //    case here, as AArch64 doesn't set the carry bit from a shift)
      //  - For a shift of zero, the carry flag is preserved, unless this was in
      //    fact an RRX operation.
      `CA53_SHIFT_OP_EXTR,
      `CA53_SHIFT_OP_ROR : begin
        sign_mask_bit           = 1'b0;
        force_mask              = 64'h0000_0000_0000_0000;
        shift_carry_out_ex1_o   = rotate_out[31];
        shift_carry_valid_ex1_o = ~shift_0 | shift_rrx_ex1;
      end

      // Default is for X-propagation only
      default : begin
        sign_mask_bit           = 1'bx;
        force_mask              = 64'hxxxx_xxxx_xxxx_xxxx;
        shift_carry_out_ex1_o   = 1'bx;
        shift_carry_valid_ex1_o = 1'bx;
      end
    endcase

  // Finally the output of the complete shift function is selected.  This may
  // either be the rotated input data (rotate_out), or a bit for either sign
  // extension or masking, used to perform logical or aritmetic shift
  // functions.
  assign shift_data_out_ex1_o = (( force_mask & {64{sign_mask_bit}}) |
                                 (~force_mask & rotate_out));

  //-------------------------------------------------
  // Assign Internals to Outputs.
  //-------------------------------------------------

  assign shift_rrx_ex1_o  = shift_rrx_ex1;
  assign shift_mask_ex1_o = shift_mask;

endmodule // ca53dpu_alu_shift

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
