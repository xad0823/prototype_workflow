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
// Abstract : Store data swizzling unit
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs endian-swizzling followed by alignment shifting on store data

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_swizzle_store `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             stall_wr_i,
  input  wire                             pre_valid_instrs_wr_i,
  input  wire                             first_x64_wr_i,
  input  wire                     [127:0] store_data_wr_i,          // Raw input data
  input  wire                       [3:0] v_addr_ex2_i,             // Low-order bits of virtual address
  input  wire                             spec_endianness_ex2_i,    // CPSR endian bit
  input  wire                       [1:0] ls_elem_size_ex2_i,       // Transaction size
  input  wire                       [1:0] ls_elem_size_wr_i,        // Transaction size
  input  wire                             ls_valid_ex2_i,
  input  wire                             ls_store_ex2_i,
  input  wire                             ls_store_neon_ex2_i,
  input  wire                             instr_is_cp10_cp11_wr_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f2_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3_i,
  input  wire                             slot1_ls_ex2_i,
  input  wire                             cp_valid_ex2_i,
  // Output
  output wire                     [127:0] dpu_st_data_wr_o          // Swizzled/shifted data out
);

  // -----------------------------
  // Constant declaration
  // -----------------------------

  localparam [4:0] STR_B0  = 5'h00;
  localparam [4:0] STR_B1  = 5'h01;
  localparam [4:0] STR_B2  = 5'h02;
  localparam [4:0] STR_B3  = 5'h03;
  localparam [4:0] STR_B4  = 5'h04;
  localparam [4:0] STR_B5  = 5'h05;
  localparam [4:0] STR_B6  = 5'h06;
  localparam [4:0] STR_B7  = 5'h07;
  localparam [4:0] STR_B8  = 5'h08;
  localparam [4:0] STR_B9  = 5'h09;
  localparam [4:0] STR_B10 = 5'h0A;
  localparam [4:0] STR_B11 = 5'h0B;
  localparam [4:0] STR_B12 = 5'h0C;
  localparam [4:0] STR_B13 = 5'h0D;
  localparam [4:0] STR_B14 = 5'h0E;
  localparam [4:0] STR_B15 = 5'h0F;
  localparam [4:0] BUF_B0  = 5'h10;
  localparam [4:0] BUF_B1  = 5'h11;
  localparam [4:0] BUF_B2  = 5'h12;
  localparam [4:0] BUF_B3  = 5'h13;
  localparam [4:0] BUF_B4  = 5'h14;
  localparam [4:0] BUF_B5  = 5'h15;
  localparam [4:0] BUF_B6  = 5'h16;
  localparam [4:0] BUF_B7  = 5'h17;
  localparam [4:0] BUF_B8  = 5'h18;
  localparam [4:0] BUF_B9  = 5'h19;
  localparam [4:0] BUF_B10 = 5'h1A;
  localparam [4:0] BUF_B11 = 5'h1B;
  localparam [4:0] BUF_B12 = 5'h1C;
  localparam [4:0] BUF_B13 = 5'h1D;
  localparam [4:0] BUF_B14 = 5'h1E;
  localparam [4:0] BUF_B15 = 5'h1F;

  // -----------------------------
  // Genvar declaration
  // -----------------------------

  genvar b;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg     [4:0] aligned_ctl_ptn_ex2 [15:0];
  reg     [4:0] endian_ctl_ptn_ex2  [15:0];

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [127:0] neon_data_buffer;
  wire    [4:0] ctl_ptn_ex2         [15:0];
  wire    [4:0] aligned_ctl_ptn_wr  [15:0];
  wire          aligned_ctl_ptn_wr_en;
  wire    [3:0] alignment_sel;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Pattern generation
  // ------------------------------------------------------
generate if (NEON_FP) begin : NEON1
  wire          vldn_perm_en_ex2;
  wire    [1:0] vldn_perm_select_lo_ex2;
  wire    [1:0] vldn_perm_select_hi_ex2;
  wire          vldn_perm_en_wr;
  wire    [1:0] vldn_perm_select_lo_wr;
  wire    [1:0] vldn_perm_select_hi_wr;
  wire    [1:0] permutable_size_ex2;
  wire          neon_data_buffer_en;
  reg   [127:0] neon_data_buffer_reg;
  reg   [127:0] nxt_neon_data_buffer;
  reg     [4:0] neon_ctl_ptn_ex2 [15:0];

  assign vldn_perm_en_ex2        = neon_vld_ctl_f2_i[`CA53_NEON_VLD_PERM_EN_BITS];
  assign vldn_perm_select_lo_ex2 = neon_vld_ctl_f2_i[`CA53_NEON_VLD_PERM_SELECT_LO_BITS];
  assign vldn_perm_select_hi_ex2 = neon_vld_ctl_f2_i[`CA53_NEON_VLD_PERM_SELECT_HI_BITS];

  assign vldn_perm_en_wr         = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_EN_BITS];
  assign vldn_perm_select_lo_wr  = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_SELECT_LO_BITS];
  assign vldn_perm_select_hi_wr  = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_SELECT_HI_BITS];

  // set element size to 64-bit when we don't need to permute
  assign permutable_size_ex2 = {2{~ls_store_neon_ex2_i | ~vldn_perm_en_ex2}} | ls_elem_size_ex2_i[1:0];

  always @* begin
    neon_ctl_ptn_ex2[ 0] = STR_B0;
    neon_ctl_ptn_ex2[ 1] = STR_B0;
    neon_ctl_ptn_ex2[ 2] = STR_B0;
    neon_ctl_ptn_ex2[ 3] = STR_B0;
    neon_ctl_ptn_ex2[ 4] = STR_B0;
    neon_ctl_ptn_ex2[ 5] = STR_B0;
    neon_ctl_ptn_ex2[ 6] = STR_B0;
    neon_ctl_ptn_ex2[ 7] = STR_B0;
    neon_ctl_ptn_ex2[ 8] = STR_B0;
    neon_ctl_ptn_ex2[ 9] = STR_B0;
    neon_ctl_ptn_ex2[10] = STR_B0;
    neon_ctl_ptn_ex2[11] = STR_B0;
    neon_ctl_ptn_ex2[12] = STR_B0;
    neon_ctl_ptn_ex2[13] = STR_B0;
    neon_ctl_ptn_ex2[14] = STR_B0;
    neon_ctl_ptn_ex2[15] = STR_B0;

    case (permutable_size_ex2)
      `CA53_LDST_SIZE_BYTE  : begin
        case ({vldn_perm_select_hi_ex2, vldn_perm_select_lo_ex2})
          4'b00_00: begin
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B4;
          end
          4'b00_01: begin
            neon_ctl_ptn_ex2[ 0] = STR_B1;
            neon_ctl_ptn_ex2[ 1] = STR_B5;
          end
          4'b00_10: begin
            neon_ctl_ptn_ex2[ 0] = STR_B2;
            neon_ctl_ptn_ex2[ 1] = STR_B6;
          end
          4'b00_11: begin
            neon_ctl_ptn_ex2[ 0] = STR_B3;
            neon_ctl_ptn_ex2[ 1] = STR_B7;
          end

          4'b01_00,
          4'b01_01: begin // VST2.8
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B8;
            neon_ctl_ptn_ex2[ 2] = STR_B1;
            neon_ctl_ptn_ex2[ 3] = STR_B9;
            neon_ctl_ptn_ex2[ 4] = STR_B2;
            neon_ctl_ptn_ex2[ 5] = STR_B10;
            neon_ctl_ptn_ex2[ 6] = STR_B3;
            neon_ctl_ptn_ex2[ 7] = STR_B11;
            neon_ctl_ptn_ex2[ 8] = STR_B4;
            neon_ctl_ptn_ex2[ 9] = STR_B12;
            neon_ctl_ptn_ex2[10] = STR_B5;
            neon_ctl_ptn_ex2[11] = STR_B13;
            neon_ctl_ptn_ex2[12] = STR_B6;
            neon_ctl_ptn_ex2[13] = STR_B14;
            neon_ctl_ptn_ex2[14] = STR_B7;
            neon_ctl_ptn_ex2[15] = STR_B15;
          end

          4'b10_10: begin // VST3.8 (2nd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B8;
            neon_ctl_ptn_ex2[ 2] = STR_B0;
            neon_ctl_ptn_ex2[ 3] = BUF_B1;
            neon_ctl_ptn_ex2[ 4] = BUF_B9;
            neon_ctl_ptn_ex2[ 5] = STR_B1;
            neon_ctl_ptn_ex2[ 6] = BUF_B2;
            neon_ctl_ptn_ex2[ 7] = BUF_B10;
            neon_ctl_ptn_ex2[ 8] = STR_B2;
            neon_ctl_ptn_ex2[ 9] = BUF_B3;
            neon_ctl_ptn_ex2[10] = BUF_B11;
            neon_ctl_ptn_ex2[11] = STR_B3;
            neon_ctl_ptn_ex2[12] = BUF_B4;
            neon_ctl_ptn_ex2[13] = BUF_B12;
            neon_ctl_ptn_ex2[14] = STR_B4;
            neon_ctl_ptn_ex2[15] = BUF_B5;
          end
          4'b10_01: begin // VST3.8 (3rd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B2;
            neon_ctl_ptn_ex2[ 1] = BUF_B5;
            neon_ctl_ptn_ex2[ 2] = BUF_B0;
            neon_ctl_ptn_ex2[ 3] = BUF_B3;
            neon_ctl_ptn_ex2[ 4] = BUF_B6;
            neon_ctl_ptn_ex2[ 5] = BUF_B1;
            neon_ctl_ptn_ex2[ 6] = BUF_B4;
            neon_ctl_ptn_ex2[ 7] = BUF_B7;
            neon_ctl_ptn_ex2[ 8] = BUF_B8;
            neon_ctl_ptn_ex2[ 9] = STR_B0;
            neon_ctl_ptn_ex2[10] = STR_B8;
            neon_ctl_ptn_ex2[11] = BUF_B9;
            neon_ctl_ptn_ex2[12] = STR_B1;
            neon_ctl_ptn_ex2[13] = STR_B9;
            neon_ctl_ptn_ex2[14] = BUF_B10;
            neon_ctl_ptn_ex2[15] = STR_B2;
          end
          4'b10_00: begin // VST3.8 (4th cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B10;
            neon_ctl_ptn_ex2[ 1] = BUF_B0;
            neon_ctl_ptn_ex2[ 2] = BUF_B5;
            neon_ctl_ptn_ex2[ 3] = BUF_B11;
            neon_ctl_ptn_ex2[ 4] = BUF_B1;
            neon_ctl_ptn_ex2[ 5] = BUF_B6;
            neon_ctl_ptn_ex2[ 6] = BUF_B12;
            neon_ctl_ptn_ex2[ 7] = BUF_B2;
            neon_ctl_ptn_ex2[ 8] = BUF_B7;
            neon_ctl_ptn_ex2[ 9] = BUF_B13;
            neon_ctl_ptn_ex2[10] = BUF_B3;
            neon_ctl_ptn_ex2[11] = BUF_B8;
            neon_ctl_ptn_ex2[12] = BUF_B14;
            neon_ctl_ptn_ex2[13] = BUF_B4;
            neon_ctl_ptn_ex2[14] = BUF_B9;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end

          4'b11_00: begin // VST4.8 (odd cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B4;
            neon_ctl_ptn_ex2[ 2] = BUF_B8;
            neon_ctl_ptn_ex2[ 3] = BUF_B12;
            neon_ctl_ptn_ex2[ 4] = BUF_B1;
            neon_ctl_ptn_ex2[ 5] = BUF_B5;
            neon_ctl_ptn_ex2[ 6] = BUF_B9;
            neon_ctl_ptn_ex2[ 7] = BUF_B13;
            neon_ctl_ptn_ex2[ 8] = BUF_B2;
            neon_ctl_ptn_ex2[ 9] = BUF_B6;
            neon_ctl_ptn_ex2[10] = BUF_B10;
            neon_ctl_ptn_ex2[11] = BUF_B14;
            neon_ctl_ptn_ex2[12] = BUF_B3;
            neon_ctl_ptn_ex2[13] = BUF_B7;
            neon_ctl_ptn_ex2[14] = BUF_B11;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end
          4'b11_10: begin // VST4.8 (even cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B8;
            neon_ctl_ptn_ex2[ 2] = STR_B0;
            neon_ctl_ptn_ex2[ 3] = STR_B8;
            neon_ctl_ptn_ex2[ 4] = BUF_B1;
            neon_ctl_ptn_ex2[ 5] = BUF_B9;
            neon_ctl_ptn_ex2[ 6] = STR_B1;
            neon_ctl_ptn_ex2[ 7] = STR_B9;
            neon_ctl_ptn_ex2[ 8] = BUF_B2;
            neon_ctl_ptn_ex2[ 9] = BUF_B10;
            neon_ctl_ptn_ex2[10] = STR_B2;
            neon_ctl_ptn_ex2[11] = STR_B10;
            neon_ctl_ptn_ex2[12] = BUF_B3;
            neon_ctl_ptn_ex2[13] = BUF_B11;
            neon_ctl_ptn_ex2[14] = STR_B3;
            neon_ctl_ptn_ex2[15] = STR_B11;
          end

          default : begin
            neon_ctl_ptn_ex2[ 0] = 5'hxx;
            neon_ctl_ptn_ex2[ 1] = 5'hxx;
            neon_ctl_ptn_ex2[ 2] = 5'hxx;
            neon_ctl_ptn_ex2[ 3] = 5'hxx;
            neon_ctl_ptn_ex2[ 4] = 5'hxx;
            neon_ctl_ptn_ex2[ 5] = 5'hxx;
            neon_ctl_ptn_ex2[ 6] = 5'hxx;
            neon_ctl_ptn_ex2[ 7] = 5'hxx;
            neon_ctl_ptn_ex2[ 8] = 5'hxx;
            neon_ctl_ptn_ex2[ 9] = 5'hxx;
            neon_ctl_ptn_ex2[10] = 5'hxx;
            neon_ctl_ptn_ex2[11] = 5'hxx;
            neon_ctl_ptn_ex2[12] = 5'hxx;
            neon_ctl_ptn_ex2[13] = 5'hxx;
            neon_ctl_ptn_ex2[14] = 5'hxx;
            neon_ctl_ptn_ex2[15] = 5'hxx;
          end
        endcase
      end
      `CA53_LDST_SIZE_HWORD : begin
        case ({vldn_perm_select_hi_ex2, vldn_perm_select_lo_ex2})
          4'b00_00,
          4'b00_01: begin
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B1;
            neon_ctl_ptn_ex2[ 2] = STR_B4;
            neon_ctl_ptn_ex2[ 3] = STR_B5;
          end
          4'b00_10,
          4'b00_11: begin
            neon_ctl_ptn_ex2[ 0] = STR_B2;
            neon_ctl_ptn_ex2[ 1] = STR_B3;
            neon_ctl_ptn_ex2[ 2] = STR_B6;
            neon_ctl_ptn_ex2[ 3] = STR_B7;
          end

          4'b01_00,
          4'b01_01: begin // VST2.16
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B1;
            neon_ctl_ptn_ex2[ 2] = STR_B8;
            neon_ctl_ptn_ex2[ 3] = STR_B9;
            neon_ctl_ptn_ex2[ 4] = STR_B2;
            neon_ctl_ptn_ex2[ 5] = STR_B3;
            neon_ctl_ptn_ex2[ 6] = STR_B10;
            neon_ctl_ptn_ex2[ 7] = STR_B11;
            neon_ctl_ptn_ex2[ 8] = STR_B4;
            neon_ctl_ptn_ex2[ 9] = STR_B5;
            neon_ctl_ptn_ex2[10] = STR_B12;
            neon_ctl_ptn_ex2[11] = STR_B13;
            neon_ctl_ptn_ex2[12] = STR_B6;
            neon_ctl_ptn_ex2[13] = STR_B7;
            neon_ctl_ptn_ex2[14] = STR_B14;
            neon_ctl_ptn_ex2[15] = STR_B15;
          end

          4'b10_10: begin // VST3.16 (2nd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B8;
            neon_ctl_ptn_ex2[ 3] = BUF_B9;
            neon_ctl_ptn_ex2[ 4] = STR_B0;
            neon_ctl_ptn_ex2[ 5] = STR_B1;
            neon_ctl_ptn_ex2[ 6] = BUF_B2;
            neon_ctl_ptn_ex2[ 7] = BUF_B3;
            neon_ctl_ptn_ex2[ 8] = BUF_B10;
            neon_ctl_ptn_ex2[ 9] = BUF_B11;
            neon_ctl_ptn_ex2[10] = STR_B2;
            neon_ctl_ptn_ex2[11] = STR_B3;
            neon_ctl_ptn_ex2[12] = BUF_B4;
            neon_ctl_ptn_ex2[13] = BUF_B5;
            neon_ctl_ptn_ex2[14] = BUF_B12;
            neon_ctl_ptn_ex2[15] = BUF_B13;
          end
          4'b10_01: begin // VST3.16 (3rd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B4;
            neon_ctl_ptn_ex2[ 1] = BUF_B5;
            neon_ctl_ptn_ex2[ 2] = BUF_B0;
            neon_ctl_ptn_ex2[ 3] = BUF_B1;
            neon_ctl_ptn_ex2[ 4] = BUF_B2;
            neon_ctl_ptn_ex2[ 5] = BUF_B3;
            neon_ctl_ptn_ex2[ 6] = BUF_B6;
            neon_ctl_ptn_ex2[ 7] = BUF_B7;
            neon_ctl_ptn_ex2[ 8] = BUF_B8;
            neon_ctl_ptn_ex2[ 9] = BUF_B9;
            neon_ctl_ptn_ex2[10] = STR_B0;
            neon_ctl_ptn_ex2[11] = STR_B1;
            neon_ctl_ptn_ex2[12] = STR_B8;
            neon_ctl_ptn_ex2[13] = STR_B9;
            neon_ctl_ptn_ex2[14] = BUF_B10;
            neon_ctl_ptn_ex2[15] = BUF_B11;
          end
          4'b10_00: begin // VST3.16 (4th cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B4;
            neon_ctl_ptn_ex2[ 1] = BUF_B5;
            neon_ctl_ptn_ex2[ 2] = BUF_B10;
            neon_ctl_ptn_ex2[ 3] = BUF_B11;
            neon_ctl_ptn_ex2[ 4] = BUF_B0;
            neon_ctl_ptn_ex2[ 5] = BUF_B1;
            neon_ctl_ptn_ex2[ 6] = BUF_B6;
            neon_ctl_ptn_ex2[ 7] = BUF_B7;
            neon_ctl_ptn_ex2[ 8] = BUF_B12;
            neon_ctl_ptn_ex2[ 9] = BUF_B13;
            neon_ctl_ptn_ex2[10] = BUF_B2;
            neon_ctl_ptn_ex2[11] = BUF_B3;
            neon_ctl_ptn_ex2[12] = BUF_B8;
            neon_ctl_ptn_ex2[13] = BUF_B9;
            neon_ctl_ptn_ex2[14] = BUF_B14;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end

          4'b11_00: begin // VST4.16 (odd cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B4;
            neon_ctl_ptn_ex2[ 3] = BUF_B5;
            neon_ctl_ptn_ex2[ 4] = BUF_B8;
            neon_ctl_ptn_ex2[ 5] = BUF_B9;
            neon_ctl_ptn_ex2[ 6] = BUF_B12;
            neon_ctl_ptn_ex2[ 7] = BUF_B13;
            neon_ctl_ptn_ex2[ 8] = BUF_B2;
            neon_ctl_ptn_ex2[ 9] = BUF_B3;
            neon_ctl_ptn_ex2[10] = BUF_B6;
            neon_ctl_ptn_ex2[11] = BUF_B7;
            neon_ctl_ptn_ex2[12] = BUF_B10;
            neon_ctl_ptn_ex2[13] = BUF_B11;
            neon_ctl_ptn_ex2[14] = BUF_B14;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end
          4'b11_10: begin // VST4.16 (even cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B8;
            neon_ctl_ptn_ex2[ 3] = BUF_B9;
            neon_ctl_ptn_ex2[ 4] = STR_B0;
            neon_ctl_ptn_ex2[ 5] = STR_B1;
            neon_ctl_ptn_ex2[ 6] = STR_B8;
            neon_ctl_ptn_ex2[ 7] = STR_B9;
            neon_ctl_ptn_ex2[ 8] = BUF_B2;
            neon_ctl_ptn_ex2[ 9] = BUF_B3;
            neon_ctl_ptn_ex2[10] = BUF_B10;
            neon_ctl_ptn_ex2[11] = BUF_B11;
            neon_ctl_ptn_ex2[12] = STR_B2;
            neon_ctl_ptn_ex2[13] = STR_B3;
            neon_ctl_ptn_ex2[14] = STR_B10;
            neon_ctl_ptn_ex2[15] = STR_B11;
          end

          default : begin
            neon_ctl_ptn_ex2[ 0] = 5'hxx;
            neon_ctl_ptn_ex2[ 1] = 5'hxx;
            neon_ctl_ptn_ex2[ 2] = 5'hxx;
            neon_ctl_ptn_ex2[ 3] = 5'hxx;
            neon_ctl_ptn_ex2[ 4] = 5'hxx;
            neon_ctl_ptn_ex2[ 5] = 5'hxx;
            neon_ctl_ptn_ex2[ 6] = 5'hxx;
            neon_ctl_ptn_ex2[ 7] = 5'hxx;
            neon_ctl_ptn_ex2[ 8] = 5'hxx;
            neon_ctl_ptn_ex2[ 9] = 5'hxx;
            neon_ctl_ptn_ex2[10] = 5'hxx;
            neon_ctl_ptn_ex2[11] = 5'hxx;
            neon_ctl_ptn_ex2[12] = 5'hxx;
            neon_ctl_ptn_ex2[13] = 5'hxx;
            neon_ctl_ptn_ex2[14] = 5'hxx;
            neon_ctl_ptn_ex2[15] = 5'hxx;
          end
        endcase
      end
      `CA53_LDST_SIZE_WORD  : begin
        case ({vldn_perm_select_hi_ex2, vldn_perm_select_lo_ex2})
          4'b00_00,
          4'b00_01,
          4'b00_10,
          4'b00_11: begin
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B1;
            neon_ctl_ptn_ex2[ 2] = STR_B2;
            neon_ctl_ptn_ex2[ 3] = STR_B3;
            neon_ctl_ptn_ex2[ 4] = STR_B4;
            neon_ctl_ptn_ex2[ 5] = STR_B5;
            neon_ctl_ptn_ex2[ 6] = STR_B6;
            neon_ctl_ptn_ex2[ 7] = STR_B7;
          end

          4'b01_00,
          4'b01_01: begin // VST2.32
            neon_ctl_ptn_ex2[ 0] = STR_B0;
            neon_ctl_ptn_ex2[ 1] = STR_B1;
            neon_ctl_ptn_ex2[ 2] = STR_B2;
            neon_ctl_ptn_ex2[ 3] = STR_B3;
            neon_ctl_ptn_ex2[ 4] = STR_B8;
            neon_ctl_ptn_ex2[ 5] = STR_B9;
            neon_ctl_ptn_ex2[ 6] = STR_B10;
            neon_ctl_ptn_ex2[ 7] = STR_B11;
            neon_ctl_ptn_ex2[ 8] = STR_B4;
            neon_ctl_ptn_ex2[ 9] = STR_B5;
            neon_ctl_ptn_ex2[10] = STR_B6;
            neon_ctl_ptn_ex2[11] = STR_B7;
            neon_ctl_ptn_ex2[12] = STR_B12;
            neon_ctl_ptn_ex2[13] = STR_B13;
            neon_ctl_ptn_ex2[14] = STR_B14;
            neon_ctl_ptn_ex2[15] = STR_B15;
          end

          4'b10_10: begin // VST3.32 (2nd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B2;
            neon_ctl_ptn_ex2[ 3] = BUF_B3;
            neon_ctl_ptn_ex2[ 4] = BUF_B8;
            neon_ctl_ptn_ex2[ 5] = BUF_B9;
            neon_ctl_ptn_ex2[ 6] = BUF_B10;
            neon_ctl_ptn_ex2[ 7] = BUF_B11;
            neon_ctl_ptn_ex2[ 8] = STR_B0;
            neon_ctl_ptn_ex2[ 9] = STR_B1;
            neon_ctl_ptn_ex2[10] = STR_B2;
            neon_ctl_ptn_ex2[11] = STR_B3;
            neon_ctl_ptn_ex2[12] = BUF_B4;
            neon_ctl_ptn_ex2[13] = BUF_B5;
            neon_ctl_ptn_ex2[14] = BUF_B6;
            neon_ctl_ptn_ex2[15] = BUF_B7;
          end
          4'b10_01: begin // VST3.16 (3rd cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B2;
            neon_ctl_ptn_ex2[ 3] = BUF_B3;
            neon_ctl_ptn_ex2[ 4] = BUF_B4;
            neon_ctl_ptn_ex2[ 5] = BUF_B5;
            neon_ctl_ptn_ex2[ 6] = BUF_B6;
            neon_ctl_ptn_ex2[ 7] = BUF_B7;
            neon_ctl_ptn_ex2[ 8] = BUF_B8;
            neon_ctl_ptn_ex2[ 9] = BUF_B9;
            neon_ctl_ptn_ex2[10] = BUF_B10;
            neon_ctl_ptn_ex2[11] = BUF_B11;
            neon_ctl_ptn_ex2[12] = STR_B0;
            neon_ctl_ptn_ex2[13] = STR_B1;
            neon_ctl_ptn_ex2[14] = STR_B2;
            neon_ctl_ptn_ex2[15] = STR_B3;
          end
          4'b10_00: begin // VST3.16 (4th cycle)
            neon_ctl_ptn_ex2[ 0] = BUF_B8;
            neon_ctl_ptn_ex2[ 1] = BUF_B9;
            neon_ctl_ptn_ex2[ 2] = BUF_B10;
            neon_ctl_ptn_ex2[ 3] = BUF_B11;
            neon_ctl_ptn_ex2[ 4] = BUF_B0;
            neon_ctl_ptn_ex2[ 5] = BUF_B1;
            neon_ctl_ptn_ex2[ 6] = BUF_B2;
            neon_ctl_ptn_ex2[ 7] = BUF_B3;
            neon_ctl_ptn_ex2[ 8] = BUF_B4;
            neon_ctl_ptn_ex2[ 9] = BUF_B5;
            neon_ctl_ptn_ex2[10] = BUF_B6;
            neon_ctl_ptn_ex2[11] = BUF_B7;
            neon_ctl_ptn_ex2[12] = BUF_B12;
            neon_ctl_ptn_ex2[13] = BUF_B13;
            neon_ctl_ptn_ex2[14] = BUF_B14;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end

          4'b11_00: begin // VST4.32 (odd cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B2;
            neon_ctl_ptn_ex2[ 3] = BUF_B3;
            neon_ctl_ptn_ex2[ 4] = BUF_B4;
            neon_ctl_ptn_ex2[ 5] = BUF_B5;
            neon_ctl_ptn_ex2[ 6] = BUF_B6;
            neon_ctl_ptn_ex2[ 7] = BUF_B7;
            neon_ctl_ptn_ex2[ 8] = BUF_B8;
            neon_ctl_ptn_ex2[ 9] = BUF_B9;
            neon_ctl_ptn_ex2[10] = BUF_B10;
            neon_ctl_ptn_ex2[11] = BUF_B11;
            neon_ctl_ptn_ex2[12] = BUF_B12;
            neon_ctl_ptn_ex2[13] = BUF_B13;
            neon_ctl_ptn_ex2[14] = BUF_B14;
            neon_ctl_ptn_ex2[15] = BUF_B15;
          end
          4'b11_10: begin // VST4.32 (even cycles)
            neon_ctl_ptn_ex2[ 0] = BUF_B0;
            neon_ctl_ptn_ex2[ 1] = BUF_B1;
            neon_ctl_ptn_ex2[ 2] = BUF_B2;
            neon_ctl_ptn_ex2[ 3] = BUF_B3;
            neon_ctl_ptn_ex2[ 4] = BUF_B8;
            neon_ctl_ptn_ex2[ 5] = BUF_B9;
            neon_ctl_ptn_ex2[ 6] = BUF_B10;
            neon_ctl_ptn_ex2[ 7] = BUF_B11;
            neon_ctl_ptn_ex2[ 8] = STR_B0;
            neon_ctl_ptn_ex2[ 9] = STR_B1;
            neon_ctl_ptn_ex2[10] = STR_B2;
            neon_ctl_ptn_ex2[11] = STR_B3;
            neon_ctl_ptn_ex2[12] = STR_B8;
            neon_ctl_ptn_ex2[13] = STR_B9;
            neon_ctl_ptn_ex2[14] = STR_B10;
            neon_ctl_ptn_ex2[15] = STR_B11;
          end

          default : begin
            neon_ctl_ptn_ex2[ 0] = 5'hxx;
            neon_ctl_ptn_ex2[ 1] = 5'hxx;
            neon_ctl_ptn_ex2[ 2] = 5'hxx;
            neon_ctl_ptn_ex2[ 3] = 5'hxx;
            neon_ctl_ptn_ex2[ 4] = 5'hxx;
            neon_ctl_ptn_ex2[ 5] = 5'hxx;
            neon_ctl_ptn_ex2[ 6] = 5'hxx;
            neon_ctl_ptn_ex2[ 7] = 5'hxx;
            neon_ctl_ptn_ex2[ 8] = 5'hxx;
            neon_ctl_ptn_ex2[ 9] = 5'hxx;
            neon_ctl_ptn_ex2[10] = 5'hxx;
            neon_ctl_ptn_ex2[11] = 5'hxx;
            neon_ctl_ptn_ex2[12] = 5'hxx;
            neon_ctl_ptn_ex2[13] = 5'hxx;
            neon_ctl_ptn_ex2[14] = 5'hxx;
            neon_ctl_ptn_ex2[15] = 5'hxx;
          end
        endcase
      end
      `CA53_LDST_SIZE_DWORD : begin // Also covers non-NEON/FP store case
        neon_ctl_ptn_ex2[ 0] = STR_B0;
        neon_ctl_ptn_ex2[ 1] = STR_B1;
        neon_ctl_ptn_ex2[ 2] = STR_B2;
        neon_ctl_ptn_ex2[ 3] = STR_B3;
        neon_ctl_ptn_ex2[ 4] = STR_B4;
        neon_ctl_ptn_ex2[ 5] = STR_B5;
        neon_ctl_ptn_ex2[ 6] = STR_B6;
        neon_ctl_ptn_ex2[ 7] = STR_B7;
        neon_ctl_ptn_ex2[ 8] = STR_B8;
        neon_ctl_ptn_ex2[ 9] = STR_B9;
        neon_ctl_ptn_ex2[10] = STR_B10;
        neon_ctl_ptn_ex2[11] = STR_B11;
        neon_ctl_ptn_ex2[12] = STR_B12;
        neon_ctl_ptn_ex2[13] = STR_B13;
        neon_ctl_ptn_ex2[14] = STR_B14;
        neon_ctl_ptn_ex2[15] = STR_B15;
      end
      default             : begin
        neon_ctl_ptn_ex2[ 0] = 5'hxx;
        neon_ctl_ptn_ex2[ 1] = 5'hxx;
        neon_ctl_ptn_ex2[ 2] = 5'hxx;
        neon_ctl_ptn_ex2[ 3] = 5'hxx;
        neon_ctl_ptn_ex2[ 4] = 5'hxx;
        neon_ctl_ptn_ex2[ 5] = 5'hxx;
        neon_ctl_ptn_ex2[ 6] = 5'hxx;
        neon_ctl_ptn_ex2[ 7] = 5'hxx;
        neon_ctl_ptn_ex2[ 8] = 5'hxx;
        neon_ctl_ptn_ex2[ 9] = 5'hxx;
        neon_ctl_ptn_ex2[10] = 5'hxx;
        neon_ctl_ptn_ex2[11] = 5'hxx;
        neon_ctl_ptn_ex2[12] = 5'hxx;
        neon_ctl_ptn_ex2[13] = 5'hxx;
        neon_ctl_ptn_ex2[14] = 5'hxx;
        neon_ctl_ptn_ex2[15] = 5'hxx;
      end
    endcase
  end

  always @*
    case (ls_elem_size_wr_i)
      `CA53_LDST_SIZE_BYTE  : begin
        case ({vldn_perm_select_hi_wr, vldn_perm_select_lo_wr})
          4'b10_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b10_10: nxt_neon_data_buffer = {store_data_wr_i[127:40],
                                            neon_data_buffer[127:104],
                                            neon_data_buffer[ 63: 48]};
          4'b10_01: nxt_neon_data_buffer = {store_data_wr_i[127:80],
                                            store_data_wr_i[ 63:24],
                                            neon_data_buffer[127: 88]};

          4'b11_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b11_10: nxt_neon_data_buffer = {store_data_wr_i[127:96],
                                            store_data_wr_i[ 63:32],
                                            neon_data_buffer[127: 96],
                                            neon_data_buffer[ 63: 32]};

          default : nxt_neon_data_buffer = {128{1'bx}};
        endcase
      end
      `CA53_LDST_SIZE_HWORD : begin
        case ({vldn_perm_select_hi_wr, vldn_perm_select_lo_wr})
          4'b10_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b10_10: nxt_neon_data_buffer = {store_data_wr_i[127:32],
                                            neon_data_buffer[127:112],
                                            neon_data_buffer[ 63: 48]};
          4'b10_01: nxt_neon_data_buffer = {store_data_wr_i[127:80],
                                            store_data_wr_i[ 63:16],
                                            neon_data_buffer[127: 96]};

          4'b11_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b11_10: nxt_neon_data_buffer = {store_data_wr_i[127:96],
                                            store_data_wr_i[ 63:32],
                                            neon_data_buffer[127: 96],
                                            neon_data_buffer[ 63: 32]};

          default : nxt_neon_data_buffer = {128{1'bx}};
        endcase
      end

      `CA53_LDST_SIZE_WORD : begin
        case ({vldn_perm_select_hi_wr, vldn_perm_select_lo_wr})
          4'b10_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b10_10,
          4'b10_01: nxt_neon_data_buffer = {store_data_wr_i[127:32],
                                            neon_data_buffer[127: 96]};

          4'b11_00: nxt_neon_data_buffer =  store_data_wr_i[127: 0];
          4'b11_10: nxt_neon_data_buffer = {store_data_wr_i[127:96],
                                            store_data_wr_i[ 63:32],
                                            neon_data_buffer[127: 96],
                                            neon_data_buffer[ 63: 32]};

          default : nxt_neon_data_buffer = {128{1'bx}};
        endcase
      end

      // Doubleword accesses are never permuted, but elem_size isn't updated on the first cycle of a VST
      // so this term is required to cover the first cycle
      `CA53_LDST_SIZE_DWORD: nxt_neon_data_buffer = store_data_wr_i[127: 0];

      default: nxt_neon_data_buffer = {128{1'bx}};
    endcase

  assign neon_data_buffer_en = vldn_perm_en_wr & instr_is_cp10_cp11_wr_i & pre_valid_instrs_wr_i & ~first_x64_wr_i & ~stall_wr_i;

  always @(posedge clk)
    if (neon_data_buffer_en)
      neon_data_buffer_reg <= nxt_neon_data_buffer;

  assign neon_data_buffer = neon_data_buffer_reg;
  assign ctl_ptn_ex2[ 0] = neon_ctl_ptn_ex2[ 0];
  assign ctl_ptn_ex2[ 1] = neon_ctl_ptn_ex2[ 1];
  assign ctl_ptn_ex2[ 2] = neon_ctl_ptn_ex2[ 2];
  assign ctl_ptn_ex2[ 3] = neon_ctl_ptn_ex2[ 3];
  assign ctl_ptn_ex2[ 4] = neon_ctl_ptn_ex2[ 4];
  assign ctl_ptn_ex2[ 5] = neon_ctl_ptn_ex2[ 5];
  assign ctl_ptn_ex2[ 6] = neon_ctl_ptn_ex2[ 6];
  assign ctl_ptn_ex2[ 7] = neon_ctl_ptn_ex2[ 7];
  assign ctl_ptn_ex2[ 8] = neon_ctl_ptn_ex2[ 8];
  assign ctl_ptn_ex2[ 9] = neon_ctl_ptn_ex2[ 9];
  assign ctl_ptn_ex2[10] = neon_ctl_ptn_ex2[10];
  assign ctl_ptn_ex2[11] = neon_ctl_ptn_ex2[11];
  assign ctl_ptn_ex2[12] = neon_ctl_ptn_ex2[12];
  assign ctl_ptn_ex2[13] = neon_ctl_ptn_ex2[13];
  assign ctl_ptn_ex2[14] = neon_ctl_ptn_ex2[14];
  assign ctl_ptn_ex2[15] = neon_ctl_ptn_ex2[15];
end else begin : NEON1_STUBS
  assign neon_data_buffer = {128{1'b0}};
  assign ctl_ptn_ex2[ 0] = STR_B0;
  assign ctl_ptn_ex2[ 1] = STR_B1;
  assign ctl_ptn_ex2[ 2] = STR_B2;
  assign ctl_ptn_ex2[ 3] = STR_B3;
  assign ctl_ptn_ex2[ 4] = STR_B4;
  assign ctl_ptn_ex2[ 5] = STR_B5;
  assign ctl_ptn_ex2[ 6] = STR_B6;
  assign ctl_ptn_ex2[ 7] = STR_B7;
  assign ctl_ptn_ex2[ 8] = STR_B8;
  assign ctl_ptn_ex2[ 9] = STR_B9;
  assign ctl_ptn_ex2[10] = STR_B10;
  assign ctl_ptn_ex2[11] = STR_B11;
  assign ctl_ptn_ex2[12] = STR_B12;
  assign ctl_ptn_ex2[13] = STR_B13;
  assign ctl_ptn_ex2[14] = STR_B14;
  assign ctl_ptn_ex2[15] = STR_B15;
end endgenerate

  // Swizzle the aligned control pattern if the data is big endian:
  always @*
    case (ls_elem_size_ex2_i[1:0] & {2{spec_endianness_ex2_i & ~cp_valid_ex2_i}})
      `CA53_LDST_SIZE_BYTE  : begin // No endian swap - byte or little endian
        endian_ctl_ptn_ex2[ 0] = ctl_ptn_ex2[ 0];
        endian_ctl_ptn_ex2[ 1] = ctl_ptn_ex2[ 1];
        endian_ctl_ptn_ex2[ 2] = ctl_ptn_ex2[ 2];
        endian_ctl_ptn_ex2[ 3] = ctl_ptn_ex2[ 3];
        endian_ctl_ptn_ex2[ 4] = ctl_ptn_ex2[ 4];
        endian_ctl_ptn_ex2[ 5] = ctl_ptn_ex2[ 5];
        endian_ctl_ptn_ex2[ 6] = ctl_ptn_ex2[ 6];
        endian_ctl_ptn_ex2[ 7] = ctl_ptn_ex2[ 7];
        endian_ctl_ptn_ex2[ 8] = ctl_ptn_ex2[ 8];
        endian_ctl_ptn_ex2[ 9] = ctl_ptn_ex2[ 9];
        endian_ctl_ptn_ex2[10] = ctl_ptn_ex2[10];
        endian_ctl_ptn_ex2[11] = ctl_ptn_ex2[11];
        endian_ctl_ptn_ex2[12] = ctl_ptn_ex2[12];
        endian_ctl_ptn_ex2[13] = ctl_ptn_ex2[13];
        endian_ctl_ptn_ex2[14] = ctl_ptn_ex2[14];
        endian_ctl_ptn_ex2[15] = ctl_ptn_ex2[15];
      end
      `CA53_LDST_SIZE_HWORD : begin // Endian swap on halfword boundary
        endian_ctl_ptn_ex2[ 0] = ctl_ptn_ex2[ 1];
        endian_ctl_ptn_ex2[ 1] = ctl_ptn_ex2[ 0];

        endian_ctl_ptn_ex2[ 2] = ctl_ptn_ex2[ 3];
        endian_ctl_ptn_ex2[ 3] = ctl_ptn_ex2[ 2];

        endian_ctl_ptn_ex2[ 4] = ctl_ptn_ex2[ 5];
        endian_ctl_ptn_ex2[ 5] = ctl_ptn_ex2[ 4];

        endian_ctl_ptn_ex2[ 6] = ctl_ptn_ex2[ 7];
        endian_ctl_ptn_ex2[ 7] = ctl_ptn_ex2[ 6];

        endian_ctl_ptn_ex2[ 8] = ctl_ptn_ex2[ 9];
        endian_ctl_ptn_ex2[ 9] = ctl_ptn_ex2[ 8];

        endian_ctl_ptn_ex2[10] = ctl_ptn_ex2[11];
        endian_ctl_ptn_ex2[11] = ctl_ptn_ex2[10];

        endian_ctl_ptn_ex2[12] = ctl_ptn_ex2[13];
        endian_ctl_ptn_ex2[13] = ctl_ptn_ex2[12];

        endian_ctl_ptn_ex2[14] = ctl_ptn_ex2[15];
        endian_ctl_ptn_ex2[15] = ctl_ptn_ex2[14];
      end
      `CA53_LDST_SIZE_WORD  : begin // Endian swap on word boundary
        endian_ctl_ptn_ex2[ 0] = ctl_ptn_ex2[ 3];
        endian_ctl_ptn_ex2[ 1] = ctl_ptn_ex2[ 2];
        endian_ctl_ptn_ex2[ 2] = ctl_ptn_ex2[ 1];
        endian_ctl_ptn_ex2[ 3] = ctl_ptn_ex2[ 0];

        endian_ctl_ptn_ex2[ 4] = ctl_ptn_ex2[ 7];
        endian_ctl_ptn_ex2[ 5] = ctl_ptn_ex2[ 6];
        endian_ctl_ptn_ex2[ 6] = ctl_ptn_ex2[ 5];
        endian_ctl_ptn_ex2[ 7] = ctl_ptn_ex2[ 4];

        endian_ctl_ptn_ex2[ 8] = ctl_ptn_ex2[11];
        endian_ctl_ptn_ex2[ 9] = ctl_ptn_ex2[10];
        endian_ctl_ptn_ex2[10] = ctl_ptn_ex2[ 9];
        endian_ctl_ptn_ex2[11] = ctl_ptn_ex2[ 8];

        endian_ctl_ptn_ex2[12] = ctl_ptn_ex2[15];
        endian_ctl_ptn_ex2[13] = ctl_ptn_ex2[14];
        endian_ctl_ptn_ex2[14] = ctl_ptn_ex2[13];
        endian_ctl_ptn_ex2[15] = ctl_ptn_ex2[12];
      end
      `CA53_LDST_SIZE_DWORD : begin // Endian swap on dword boundary
        endian_ctl_ptn_ex2[ 0] = ctl_ptn_ex2[ 7];
        endian_ctl_ptn_ex2[ 1] = ctl_ptn_ex2[ 6];
        endian_ctl_ptn_ex2[ 2] = ctl_ptn_ex2[ 5];
        endian_ctl_ptn_ex2[ 3] = ctl_ptn_ex2[ 4];
        endian_ctl_ptn_ex2[ 4] = ctl_ptn_ex2[ 3];
        endian_ctl_ptn_ex2[ 5] = ctl_ptn_ex2[ 2];
        endian_ctl_ptn_ex2[ 6] = ctl_ptn_ex2[ 1];
        endian_ctl_ptn_ex2[ 7] = ctl_ptn_ex2[ 0];

        endian_ctl_ptn_ex2[ 8] = ctl_ptn_ex2[15];
        endian_ctl_ptn_ex2[ 9] = ctl_ptn_ex2[14];
        endian_ctl_ptn_ex2[10] = ctl_ptn_ex2[13];
        endian_ctl_ptn_ex2[11] = ctl_ptn_ex2[12];
        endian_ctl_ptn_ex2[12] = ctl_ptn_ex2[11];
        endian_ctl_ptn_ex2[13] = ctl_ptn_ex2[10];
        endian_ctl_ptn_ex2[14] = ctl_ptn_ex2[ 9];
        endian_ctl_ptn_ex2[15] = ctl_ptn_ex2[ 8];
      end
      default             : begin
        endian_ctl_ptn_ex2[ 0] = 5'hxx;
        endian_ctl_ptn_ex2[ 1] = 5'hxx;
        endian_ctl_ptn_ex2[ 2] = 5'hxx;
        endian_ctl_ptn_ex2[ 3] = 5'hxx;
        endian_ctl_ptn_ex2[ 4] = 5'hxx;
        endian_ctl_ptn_ex2[ 5] = 5'hxx;
        endian_ctl_ptn_ex2[ 6] = 5'hxx;
        endian_ctl_ptn_ex2[ 7] = 5'hxx;
        endian_ctl_ptn_ex2[ 8] = 5'hxx;
        endian_ctl_ptn_ex2[ 9] = 5'hxx;
        endian_ctl_ptn_ex2[10] = 5'hxx;
        endian_ctl_ptn_ex2[11] = 5'hxx;
        endian_ctl_ptn_ex2[12] = 5'hxx;
        endian_ctl_ptn_ex2[13] = 5'hxx;
        endian_ctl_ptn_ex2[14] = 5'hxx;
        endian_ctl_ptn_ex2[15] = 5'hxx;
      end
    endcase

  // Align the control pattern depending on the bottom 4-bits of the address.
  // Ignore the address for CP operations
  // - On slot 1 stores, the 64-bits of valid store data is supplied on
  // store_data_wr_i[127:64], so rotate by extra 4'b1000 which has effect of
  // rotating into [63:0] then applying rotation as if was supplied in those
  // bits.
  assign alignment_sel = (v_addr_ex2_i & {4{~cp_valid_ex2_i}}) ^ {slot1_ls_ex2_i, 3'b000};

  generate for (b=0; b<16; b=b+1) begin : g_alignment_ctl
    always @*
      case (alignment_sel[3:0])
        4'b0000 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[b];                              // 15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        4'b0001 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  1) ? (15 + b) : (b -  1)]; // 14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15
        4'b0010 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  2) ? (14 + b) : (b -  2)]; // 13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15,14
        4'b0011 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  3) ? (13 + b) : (b -  3)]; // 12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15,14,13
        4'b0100 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  4) ? (12 + b) : (b -  4)]; // 11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15,14,13,12
        4'b0101 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  5) ? (11 + b) : (b -  5)]; // 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15,14,13,12,11
        4'b0110 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  6) ? (10 + b) : (b -  6)]; //  9, 8, 7, 6, 5, 4, 3, 2, 1, 0,15,14,13,12,11,10
        4'b0111 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  7) ? ( 9 + b) : (b -  7)]; //  8, 7, 6, 5, 4, 3, 2, 1, 0,15,14,13,12,11,10, 9
        4'b1000 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  8) ? ( 8 + b) : (b -  8)]; //  7, 6, 5, 4, 3, 2, 1, 0,15,14,13,12,11,10, 9, 8
        4'b1001 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b <  9) ? ( 7 + b) : (b -  9)]; //  6, 5, 4, 3, 2, 1, 0,15,14,13,12,11,10, 9, 8, 7
        4'b1010 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 10) ? ( 6 + b) : (b - 10)]; //  5, 4, 3, 2, 1, 0,15,14,13,12,11,10, 9, 8, 7, 6
        4'b1011 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 11) ? ( 5 + b) : (b - 11)]; //  4, 3, 2, 1, 0,15,14,13,12,11,10, 9, 8, 7, 6, 5
        4'b1100 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 12) ? ( 4 + b) : (b - 12)]; //  3, 2, 1, 0,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4
        4'b1101 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 13) ? ( 3 + b) : (b - 13)]; //  2, 1, 0,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3
        4'b1110 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 14) ? ( 2 + b) : (b - 14)]; //  1, 0,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2
        4'b1111 : aligned_ctl_ptn_ex2[b] = endian_ctl_ptn_ex2[(b < 15) ? ( 1 + b) : (b - 15)]; //  0,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1
        default : aligned_ctl_ptn_ex2[b] = 5'bxxxxx;
      endcase
  end endgenerate

  // Register the control pattern into Wr
  assign aligned_ctl_ptn_wr_en = ~stall_wr_i & ls_valid_ex2_i & (ls_store_ex2_i | cp_valid_ex2_i);

  generate if (NEON_FP) begin : g_wr_ctl_ptn_neon
    reg  [4:0] aligned_ctl_ptn_wr_reg [15:0];

  
    for (b = 0; b < 16; b = b + 1) begin : g_byte
      always @(posedge clk)
        if (aligned_ctl_ptn_wr_en)
          aligned_ctl_ptn_wr_reg[b] <= aligned_ctl_ptn_ex2[b];
          
      assign aligned_ctl_ptn_wr[b] = aligned_ctl_ptn_wr_reg[b];
    end
  end else begin : g_wr_ctl_ptn_noneon
    reg  [3:0] aligned_ctl_ptn_wr_reg [15:0];

    for (b = 0; b < 16; b = b + 1) begin : g_byte
      always @(posedge clk)
        if (aligned_ctl_ptn_wr_en)
          aligned_ctl_ptn_wr_reg[b] <= aligned_ctl_ptn_ex2[b][3:0];
          
      assign aligned_ctl_ptn_wr[b] = {1'b0, aligned_ctl_ptn_wr_reg[b]};
    end
  end endgenerate

  // ------------------------------------------------------
  // Swizzle the store data
  // ------------------------------------------------------

  // Select a byte from the input
  function [7:0] select_byte;
    input   [4:0] sel;
    input [127:0] data;
    input [127:0] data_buffer;

    case (sel)
      STR_B0  : select_byte = data[  7:  0];
      STR_B1  : select_byte = data[ 15:  8];
      STR_B2  : select_byte = data[ 23: 16];
      STR_B3  : select_byte = data[ 31: 24];
      STR_B4  : select_byte = data[ 39: 32];
      STR_B5  : select_byte = data[ 47: 40];
      STR_B6  : select_byte = data[ 55: 48];
      STR_B7  : select_byte = data[ 63: 56];
      STR_B8  : select_byte = data[ 71: 64];
      STR_B9  : select_byte = data[ 79: 72];
      STR_B10 : select_byte = data[ 87: 80];
      STR_B11 : select_byte = data[ 95: 88];
      STR_B12 : select_byte = data[103: 96];
      STR_B13 : select_byte = data[111:104];
      STR_B14 : select_byte = data[119:112];
      STR_B15 : select_byte = data[127:120];
      BUF_B0  : select_byte = data_buffer[  7:  0];
      BUF_B1  : select_byte = data_buffer[ 15:  8];
      BUF_B2  : select_byte = data_buffer[ 23: 16];
      BUF_B3  : select_byte = data_buffer[ 31: 24];
      BUF_B4  : select_byte = data_buffer[ 39: 32];
      BUF_B5  : select_byte = data_buffer[ 47: 40];
      BUF_B6  : select_byte = data_buffer[ 55: 48];
      BUF_B7  : select_byte = data_buffer[ 63: 56];
      BUF_B8  : select_byte = data_buffer[ 71: 64];
      BUF_B9  : select_byte = data_buffer[ 79: 72];
      BUF_B10 : select_byte = data_buffer[ 87: 80];
      BUF_B11 : select_byte = data_buffer[ 95: 88];
      BUF_B12 : select_byte = data_buffer[103: 96];
      BUF_B13 : select_byte = data_buffer[111:104];
      BUF_B14 : select_byte = data_buffer[119:112];
      BUF_B15 : select_byte = data_buffer[127:120];
      default : select_byte = {8{1'bx}};
    endcase
  endfunction

  // Perform the swizzling on the store data
  assign dpu_st_data_wr_o[  7:  0] = select_byte(aligned_ctl_ptn_wr[ 0], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 15:  8] = select_byte(aligned_ctl_ptn_wr[ 1], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 23: 16] = select_byte(aligned_ctl_ptn_wr[ 2], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 31: 24] = select_byte(aligned_ctl_ptn_wr[ 3], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 39: 32] = select_byte(aligned_ctl_ptn_wr[ 4], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 47: 40] = select_byte(aligned_ctl_ptn_wr[ 5], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 55: 48] = select_byte(aligned_ctl_ptn_wr[ 6], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 63: 56] = select_byte(aligned_ctl_ptn_wr[ 7], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 71: 64] = select_byte(aligned_ctl_ptn_wr[ 8], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 79: 72] = select_byte(aligned_ctl_ptn_wr[ 9], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 87: 80] = select_byte(aligned_ctl_ptn_wr[10], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[ 95: 88] = select_byte(aligned_ctl_ptn_wr[11], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[103: 96] = select_byte(aligned_ctl_ptn_wr[12], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[111:104] = select_byte(aligned_ctl_ptn_wr[13], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[119:112] = select_byte(aligned_ctl_ptn_wr[14], store_data_wr_i[127:0], neon_data_buffer[127:0]);
  assign dpu_st_data_wr_o[127:120] = select_byte(aligned_ctl_ptn_wr[15], store_data_wr_i[127:0], neon_data_buffer[127:0]);

  //----------------------------------------------------------------------------
  // OVL definitions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  
generate if (NEON_FP) begin : NEON2
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: neon_data_buffer_en")
  u_ovl_x_neon_data_buffer_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (NEON1.neon_data_buffer_en));
end endgenerate

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: aligned_ctl_ptn_wr_en")
  u_ovl_x_aligned_ctl_ptn_wr_en (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (aligned_ctl_ptn_wr_en));

`endif

endmodule // ca53dpu_swizzle_store

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
