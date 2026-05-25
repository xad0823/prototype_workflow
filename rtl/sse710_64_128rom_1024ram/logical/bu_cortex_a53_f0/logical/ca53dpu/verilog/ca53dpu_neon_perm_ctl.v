//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Neon Permutation Block
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs permutation of the input vector operands

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_perm_ctl (
  // Inputs
  input wire    [1:0] neon_inc_size_sel_f1_i, // Size of vector elements (32,16,8)
  input wire    [3:0] neon_perm_sel_f1_i,     // Selects permutation operation
  input wire    [6:0] imm_data_f1_i,
  input wire   [63:0] fad_c_data_f1_i,        // Selects the bytes from the input operands to create a new vector
  // Outputs
  output wire  [63:0] neon_perm_ctl_f1_o
);

  // -----------------------------
  // Reg declaration
  // -----------------------------

  reg  [63:0] mux_ctl;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  always @*
    case (neon_perm_sel_f1_i)
      4'b0000: // No permutation
        // B7, B6, B5, B4, B3, B2, B1, B0
        // A7, A6, A5, A4, A3, A2, A1, A0
        mux_ctl = 64'hFEDCBA98_76543210;

      4'b0001: //VPADD, VUZP, VPADAL, VPADDL
        case (neon_inc_size_sel_f1_i)
          2'b00: //8-bits
            // B7 B5 B3 B1 A7 A5 A3 A1
            // B6 B4 B2 B0 A6 A4 A2 A0
            mux_ctl = 64'hFDB97531_ECA86420;
          2'b01: //16-bits
            // B7 B6 B3 B2 A7 A6 A3 A2
            // B5 B4 B1 B0 A5 A4 A1 A0
            mux_ctl = 64'hFEBA7632_DC985410;
          2'b10: //32-bits
            mux_ctl = 64'hFEDC7654_BA983210;
          2'b11: //64-bits
            mux_ctl = 64'hFEDCBA98_76543210;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b0010: //VTRN
        case (neon_inc_size_sel_f1_i)
          2'b00: //8-bits
            // B7 A7 B5 A5 B3 A3 B1 A1
            // B6 A6 B4 A4 B2 A2 B0 A0
            mux_ctl = 64'hF7D5B391_E6C4A280;
          2'b01: //16-bits
            // B3 A3 B1 A1
            // B2 A2 B0 A0
            mux_ctl = 64'hFE76BA32_DC549810;
          2'b10: //32-bits
            // B1 A1, B0 A0
            mux_ctl = 64'hFEDC7654_BA983210;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b0011: //VZIP
        case (neon_inc_size_sel_f1_i)
          2'b00: //8-bits
            // B7 A7 B6 A6 B5 A5 B4 A4
            // B3 A3 B2 A2 B1 A1 B0 A0
            mux_ctl = 64'hF7E6D5C4_B3A29180;
          2'b01: //16-bits
            // B3 A3 B2 A2
            // B1 A1 B0 A0
            mux_ctl = 64'hFE76DC54_BA329810;
          2'b10: //32-bits
            //B1 A1, B0 A0
            mux_ctl = 64'hFEDC7654_BA983210;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b0100: //VREV16
        // B6 B7 B4 B5 B2 B3 B0 B1
        mux_ctl = 64'hEFCDAB89_00000000;

      4'b0101: //VREV32
        case (neon_inc_size_sel_f1_i)
          2'b00: //8-bits
            // B4 B5 B6 B7 B0 B1 B2 B3
            mux_ctl = 64'hCDEF89AB_00000000;
          2'b01: //16-bits
            // b5 b4 b7 b6 b1 b0 b3 b2
            mux_ctl = 64'hDCFE98BA_00000000;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b0110: //VREV64
        case (neon_inc_size_sel_f1_i)
          2'b00: //8-bits
            // B0 B1 B2 B3 B4 B5 B6 B7
            mux_ctl = 64'h89ABCDEF_00000000;
          2'b01: //16-bits
            // B1 B0 B3 B2 B5 B4 B7 B6
            mux_ctl = 64'h98BADCFE_00000000;
          2'b10: //32-bits
            // B3 B2 B1 B0 B7 B6 B5 B4
            mux_ctl = 64'hBA98FEDC_00000000;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b0111: //VTBL, VTBX
        mux_ctl = {fad_c_data_f1_i[63:60], fad_c_data_f1_i[55:52], fad_c_data_f1_i[47:44], fad_c_data_f1_i[39:36],
                   fad_c_data_f1_i[31:28], fad_c_data_f1_i[23:20], fad_c_data_f1_i[15:12], fad_c_data_f1_i[ 7: 4],
                   fad_c_data_f1_i[59:56], fad_c_data_f1_i[51:48], fad_c_data_f1_i[43:40], fad_c_data_f1_i[35:32],
                   fad_c_data_f1_i[27:24], fad_c_data_f1_i[19:16], fad_c_data_f1_i[11: 8], fad_c_data_f1_i[ 3: 0]};

      4'b1000: // VEXT
        case (imm_data_f1_i[2:0])
          3'b000: // No elements from operand b
            mux_ctl = 64'h76543210_00000000;
          3'b001: // 1 bottom element from operand b
            mux_ctl = 64'h87654321_00000000;
          3'b010: // 2 bottom elements from operand b
            mux_ctl = 64'h98765432_00000000;
          3'b011: // 3 bottom elements from operand b
            mux_ctl = 64'hA9876543_00000000;
          3'b100: // 4 bottom elements from operand b
            mux_ctl = 64'hBA987654_00000000;
          3'b101: // 5 bottom elements from operand b
            mux_ctl = 64'hCBA98765_00000000;
          3'b110: // 6 bottom elements from operand b
            mux_ctl = 64'hDCBA9876_00000000;
          3'b111: // 7 bottom elements from operand b
            mux_ctl = 64'hEDCBA987_00000000;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b1001, 4'b1010: // Shifts
        case (neon_inc_size_sel_f1_i)
          2'b00: begin // 8-bit - no byte permutation necessary
            mux_ctl = 64'h76543210_76543210;
          end

          2'b01: begin // 16-bit
            case (fad_c_data_f1_i[3])
              1'b0:       {mux_ctl[39:32], mux_ctl[ 7: 0]} = 16'h01_10;
              1'b1:       {mux_ctl[39:32], mux_ctl[ 7: 0]} = 16'h10_01;
              default:    {mux_ctl[39:32], mux_ctl[ 7: 0]} = {16{1'bx}};
            endcase

            case (fad_c_data_f1_i[19])
              1'b0:       {mux_ctl[47:40], mux_ctl[15: 8]} = 16'h23_32;
              1'b1:       {mux_ctl[47:40], mux_ctl[15: 8]} = 16'h32_23;
              default:    {mux_ctl[47:40], mux_ctl[15: 8]} = {16{1'bx}};
            endcase

            case (fad_c_data_f1_i[35])
              1'b0:       {mux_ctl[55:48], mux_ctl[23:16]} = 16'h45_54;
              1'b1:       {mux_ctl[55:48], mux_ctl[23:16]} = 16'h54_45;
              default:    {mux_ctl[55:48], mux_ctl[23:16]} = {16{1'bx}};
            endcase

            case (fad_c_data_f1_i[51])
              1'b0:       {mux_ctl[63:56], mux_ctl[31:24]} = 16'h67_76;
              1'b1:       {mux_ctl[63:56], mux_ctl[31:24]} = 16'h76_67;
              default:    {mux_ctl[63:56], mux_ctl[31:24]} = {16{1'bx}};
            endcase
          end

          2'b10: begin // 32-bit
            case (fad_c_data_f1_i[4:3])
              2'b00:      {mux_ctl[47:32], mux_ctl[15: 0]} = 32'h2103_3210;
              2'b01:      {mux_ctl[47:32], mux_ctl[15: 0]} = 32'h1032_2103;
              2'b10:      {mux_ctl[47:32], mux_ctl[15: 0]} = 32'h0321_1032;
              2'b11:      {mux_ctl[47:32], mux_ctl[15: 0]} = 32'h3210_0321;
              default:    {mux_ctl[47:32], mux_ctl[15: 0]} = {32{1'bx}};
            endcase

            case (fad_c_data_f1_i[36:35])
              2'b00:      {mux_ctl[63:48], mux_ctl[31:16]} = 32'h6547_7654;
              2'b01:      {mux_ctl[63:48], mux_ctl[31:16]} = 32'h5476_6547;
              2'b10:      {mux_ctl[63:48], mux_ctl[31:16]} = 32'h4765_5476;
              2'b11:      {mux_ctl[63:48], mux_ctl[31:16]} = 32'h7654_4765;
              default:    {mux_ctl[63:48], mux_ctl[31:16]} = {32{1'bx}};
            endcase
          end

          2'b11: begin // 64-bit
            case (fad_c_data_f1_i[5:3])
              3'b000:     mux_ctl[63: 0] = 64'h65432107_76543210;
              3'b001:     mux_ctl[63: 0] = 64'h54321076_65432107;
              3'b010:     mux_ctl[63: 0] = 64'h43210765_54321076;
              3'b011:     mux_ctl[63: 0] = 64'h32107654_43210765;
              3'b100:     mux_ctl[63: 0] = 64'h21076543_32107654;
              3'b101:     mux_ctl[63: 0] = 64'h10765432_21076543;
              3'b110:     mux_ctl[63: 0] = 64'h07654321_10765432;
              3'b111:     mux_ctl[63: 0] = 64'h76543210_07654321;
              default:    mux_ctl[63: 0] = {64{1'bx}};
            endcase
          end

          default: begin
            mux_ctl = {64{1'bx}};
          end
        endcase

      4'b1011: // Narrowing right shifts
        case (neon_inc_size_sel_f1_i)
          2'b00: begin // 16-bit -> 8-bit
            case (fad_c_data_f1_i[3])
              1'b0:       mux_ctl[63: 0] = 64'hFDB97531_ECA86420;
              1'b1:       mux_ctl[63: 0] = 64'hECA86420_FDB97531;
              default:    mux_ctl[63: 0] = {64{1'bx}};
            endcase
          end

          2'b01: begin // 32-bit -> 16-bit
            case (fad_c_data_f1_i[4:3])
              2'b00:      mux_ctl[63: 0] = 64'hCF_8B_47_03_DC_98_54_10;
              2'b01:      mux_ctl[63: 0] = 64'hFE_BA_76_32_CF_8B_47_03;
              2'b10:      mux_ctl[63: 0] = 64'hED_A9_65_21_FE_BA_76_32;
              2'b11:      mux_ctl[63: 0] = 64'hDC_98_54_10_ED_A9_65_21;
              default:    mux_ctl[63: 0] = {64{1'bx}};
            endcase
          end

          2'b10: begin // 64-bit - > 32-bit
            case (fad_c_data_f1_i[5:3])
              3'b000:     mux_ctl[63: 0] = 64'hA98F_2107_BA98_3210;
              3'b001:     mux_ctl[63: 0] = 64'h98FE_1076_A98F_2107;
              3'b010:     mux_ctl[63: 0] = 64'h8FED_0765_98FE_1076;
              3'b011:     mux_ctl[63: 0] = 64'hFEDC_7654_8FED_0765;
              3'b100:     mux_ctl[63: 0] = 64'hEDCB_6543_FEDC_7654;
              3'b101:     mux_ctl[63: 0] = 64'hDCBA_5432_EDCB_6543;
              3'b110:     mux_ctl[63: 0] = 64'hCBA9_4321_DCBA_5432;
              3'b111:     mux_ctl[63: 0] = 64'hBA98_3210_CBA9_4321;
              default:    mux_ctl[63: 0] = {64{1'bx}};
            endcase
          end

          default: begin
            mux_ctl = {64{1'bx}};
          end
        endcase

      4'b1100: // VDUP scalar
        case (imm_data_f1_i[3:0])
          `ca53dpu_sel_xxx1: // Element size 8
            mux_ctl = {16{ 1'b0, fad_c_data_f1_i[3:1]}};

          `ca53dpu_sel_xx10: begin // Element size 16
            case (imm_data_f1_i[3:2])
              2'b00: // 1st element
                mux_ctl = 64'h10101010_10101010;
              2'b01: // 2nd element
                mux_ctl = 64'h32323232_32323232;
              2'b10: // 3d element
                mux_ctl = 64'h54545454_54545454;
              2'b11: // 4th element
                mux_ctl = 64'h76767676_76767676;
              default:
                mux_ctl = {64{1'bx}};
            endcase
          end

          `ca53dpu_sel_x100: begin // Element size 32
            case (imm_data_f1_i[3])
              1'b0: // 1st element
                mux_ctl = 64'h32103210_32103210;
              1'b1: // 2nd element
                mux_ctl = 64'h76547654_76547654;
              default:
                mux_ctl = {64{1'bx}};
            endcase
          end

          4'b1000: begin // Element size 64
            mux_ctl = 64'h76543210_76543210;
          end

          default  : mux_ctl = {64{1'bx}};
        endcase

      4'b1101: // VSEL
        case (neon_inc_size_sel_f1_i)
          2'b10: // 32-bit
            mux_ctl = 64'hBA98BA98_32103210;
          2'b11: // 64-bit
            mux_ctl = 64'hFEDCBA98_76543210;
          default:
            mux_ctl = {64{1'bx}};
        endcase

      4'b1110: // VMOV (core to scalar) / INS
        case (imm_data_f1_i[3:0])
          `ca53dpu_sel_xxx1: begin // Element size 8
            case (imm_data_f1_i[3:1])
              3'b000:  mux_ctl = {60'h00000000_7654321, 1'b1, imm_data_f1_i[6:4]             };
              3'b001:  mux_ctl = {56'h00000000_765432,  1'b1, imm_data_f1_i[6:4],        4'h0};
              3'b010:  mux_ctl = {52'h00000000_76543,   1'b1, imm_data_f1_i[6:4],       8'h10};
              3'b011:  mux_ctl = {48'h00000000_7654,    1'b1, imm_data_f1_i[6:4],     12'h210};
              3'b100:  mux_ctl = {44'h00000000_765,     1'b1, imm_data_f1_i[6:4],    16'h3210};
              3'b101:  mux_ctl = {40'h00000000_76,      1'b1, imm_data_f1_i[6:4],   20'h43210};
              3'b110:  mux_ctl = {36'h00000000_7,       1'b1, imm_data_f1_i[6:4],  24'h543210};
              3'b111:  mux_ctl = {32'h00000000,         1'b1, imm_data_f1_i[6:4], 28'h6543210};
              default: mux_ctl = {64{1'bx}};
            endcase
          end
          `ca53dpu_sel_xx10: begin // Element size 16
            case ({imm_data_f1_i[3:2], imm_data_f1_i[6:5]})
              // Insert into first element
              4'b00_00: mux_ctl = 64'h00000000_76543298;
              4'b00_01: mux_ctl = 64'h00000000_765432BA;
              4'b00_10: mux_ctl = 64'h00000000_765432DC;
              4'b00_11: mux_ctl = 64'h00000000_765432FE;
              // Insert into first element
              4'b01_00: mux_ctl = 64'h00000000_76549810;
              4'b01_01: mux_ctl = 64'h00000000_7654BA10;
              4'b01_10: mux_ctl = 64'h00000000_7654DC10;
              4'b01_11: mux_ctl = 64'h00000000_7654FE10;
              // Insert into first element
              4'b10_00: mux_ctl = 64'h00000000_76983210;
              4'b10_01: mux_ctl = 64'h00000000_76BA3210;
              4'b10_10: mux_ctl = 64'h00000000_76DC3210;
              4'b10_11: mux_ctl = 64'h00000000_76FE3210;
              // Insert into first element
              4'b11_00: mux_ctl = 64'h00000000_98543210;
              4'b11_01: mux_ctl = 64'h00000000_BA543210;
              4'b11_10: mux_ctl = 64'h00000000_DC543210;
              4'b11_11: mux_ctl = 64'h00000000_FE543210;
              default:  mux_ctl = {64{1'bx}};
            endcase
          end

          `ca53dpu_sel_x100: begin // Element size 32
            case ({imm_data_f1_i[3], imm_data_f1_i[6]})
              // Insert into first element
              2'b0_0:  mux_ctl = 64'h00000000_7654BA98;
              2'b0_1:  mux_ctl = 64'h00000000_7654FEDC;
              // Insert into second element
              2'b1_0:  mux_ctl = 64'h00000000_BA983210;
              2'b1_1:  mux_ctl = 64'h00000000_FEDC3210;
              default: mux_ctl = {64{1'bx}};
            endcase
          end

          4'b1000: begin // Element size 64
            mux_ctl = 64'h00000000_FEDCBA98;
          end

          default  : mux_ctl = {64{1'bx}};
        endcase

      4'b1111: // VDUP (core register)
        case (neon_inc_size_sel_f1_i)
          2'b00:   mux_ctl = 64'h00000000_88888888;
          2'b01:   mux_ctl = 64'h00000000_98989898;
          2'b10:   mux_ctl = 64'h00000000_BA98BA98;
          2'b11:   mux_ctl = 64'h00000000_FEDCBA98;
          default: mux_ctl = {64{1'bx}};
        endcase

      default:
        mux_ctl = {64{1'bx}};
    endcase

  // This interleaving is a bit messy, but makes the constants in the
  // case statement above more readable

  assign neon_perm_ctl_f1_o = {mux_ctl[63:60], mux_ctl[31:28], mux_ctl[59:56], mux_ctl[27:24],
                               mux_ctl[55:52], mux_ctl[23:20], mux_ctl[51:48], mux_ctl[19:16],
                               mux_ctl[47:44], mux_ctl[15:12], mux_ctl[43:40], mux_ctl[11: 8],
                               mux_ctl[39:36], mux_ctl[ 7: 4], mux_ctl[35:32], mux_ctl[ 3: 0]};

endmodule // ca53dpu_neon_perm_ctl

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
