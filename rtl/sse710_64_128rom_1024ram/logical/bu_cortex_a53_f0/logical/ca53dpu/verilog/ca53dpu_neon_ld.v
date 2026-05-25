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
// Abstract : Neon structured load permutation module
//-----------------------------------------------------------------------------
//
// Overview
// --------
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_ld `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk_fp,
  input  wire                             reset_n,
  input  wire                             stall_wr_i,
  input  wire                             valid_instrs_wr_i,
  input  wire                             first_x64_wr_i,
  input  wire  [`CA53_NEON_VLD_CTL_W-1:0] neon_vld_ctl_f3_i,
  input  wire                       [1:0] ls_elem_size_wr_i,
  input  wire                      [63:0] fwd_ld_data_int_wr_i,
  input  wire                      [63:0] st0_data_wr_i,
  input  wire                             instr_is_cp10_cp11_wr_i,
  // Outputs
  output reg                       [63:0] ld_data_f3_o,
  output wire                      [63:0] dup_ld_data_f3_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [63:0] load_buffer;
  reg  [63:0] nxt_load_buffer;
  reg  [63:0] dup_data;
  reg   [3:0] dup_mask;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        load_buffer_en;
  wire        vldn_perm_en;
  wire        vldn_dup;
  wire  [1:0] vldn_perm_select_lo; // Which permutation is required
  wire  [1:0] vldn_perm_select_hi; // Which permutation is required

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign vldn_perm_en        = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_EN_BITS];
  assign vldn_dup            = neon_vld_ctl_f3_i[`CA53_NEON_VLD_DUP_BITS];
  assign vldn_perm_select_lo = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_SELECT_LO_BITS];
  assign vldn_perm_select_hi = neon_vld_ctl_f3_i[`CA53_NEON_VLD_PERM_SELECT_HI_BITS];

  // Select the data required this iteration and update the buffer for next cycle

  always @*
    case ({1'b0, ls_elem_size_wr_i, vldn_perm_select_hi, vldn_perm_select_lo})

      // Buffering cycle without permutation for VLD3/VLD4
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b00, 2'b00},
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b00, 2'b00}: begin
        ld_data_f3_o    = {64{1'b0}};
        nxt_load_buffer = fwd_ld_data_int_wr_i[63:0];
      end

      // VLD2.8
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b01, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[63:56], fwd_ld_data_int_wr_i[47:40],
                           fwd_ld_data_int_wr_i[31:24], fwd_ld_data_int_wr_i[15: 8],
                           fwd_ld_data_int_wr_i[55:48], fwd_ld_data_int_wr_i[39:32],
                           fwd_ld_data_int_wr_i[23:16], fwd_ld_data_int_wr_i[ 7: 0]};
        nxt_load_buffer = {64{1'b0}};
      end

      // VLD2.16
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b01, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[63:48], fwd_ld_data_int_wr_i[31:16],
                           fwd_ld_data_int_wr_i[47:32], fwd_ld_data_int_wr_i[15: 0]};
        nxt_load_buffer = {64{1'b0}};
      end

      // VLD3.8
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b10, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[23:16], load_buffer[63:56],
                           load_buffer[39:32],          load_buffer[15: 8],
                           fwd_ld_data_int_wr_i[15: 8], load_buffer[55:48],
                           load_buffer[31:24],          load_buffer[ 7: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:24], fwd_ld_data_int_wr_i[ 7: 0],
                           load_buffer[47:40],          load_buffer[23:16]};
      end
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b10, 2'b10}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[47:40], fwd_ld_data_int_wr_i[23:16],
                           load_buffer[63:56],          load_buffer[39:32],
                           load_buffer[31: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:48], fwd_ld_data_int_wr_i[39:24],
                           fwd_ld_data_int_wr_i[15: 0], load_buffer[55:40]};
      end
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b10, 2'b01}: begin
        ld_data_f3_o    = {load_buffer[63:56], load_buffer[47:40],
                           load_buffer[31:24], load_buffer[15: 8],
                           load_buffer[55:48], load_buffer[39:32],
                           load_buffer[23:16], load_buffer[ 7: 0]};
        nxt_load_buffer = fwd_ld_data_int_wr_i[63:0];
      end

      // VLD3.16
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b10, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[15: 0], load_buffer[31:16],
                           load_buffer[63:48],          load_buffer[15: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:16], load_buffer[47:32]};
      end
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b10, 2'b10}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[31:16], load_buffer[47:32],
                           load_buffer[31:16],          load_buffer[15: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:32], fwd_ld_data_int_wr_i[15: 0],
                           load_buffer[63:48]};
      end
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b10, 2'b01}: begin
        ld_data_f3_o    = {load_buffer[63:48], load_buffer[31:16],
                           load_buffer[47:32], load_buffer[15: 0]};
        nxt_load_buffer = fwd_ld_data_int_wr_i[63:0];
      end

      // VLD4.8
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b11, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[47:40], fwd_ld_data_int_wr_i[15: 8],
                           load_buffer[47:40],          load_buffer[15: 8],
                           fwd_ld_data_int_wr_i[39:32], fwd_ld_data_int_wr_i[ 7: 0],
                           load_buffer[39:32],          load_buffer[ 7: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:48], fwd_ld_data_int_wr_i[31:16],
                           load_buffer[63:48],          load_buffer[31:16]};
      end
      {`CA53_LS_ELEM_SIZE_8BIT, 2'b11, 2'b10}: begin
        ld_data_f3_o    = {load_buffer[63:56], load_buffer[47:40],
                           load_buffer[31:24], load_buffer[15: 8],
                           load_buffer[55:48], load_buffer[39:32],
                           load_buffer[23:16], load_buffer[ 7: 0]};
        nxt_load_buffer = fwd_ld_data_int_wr_i[63:0];
      end

      // VLD4.16
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b11, 2'b00}: begin
        ld_data_f3_o    = {fwd_ld_data_int_wr_i[31:16], load_buffer[31:16],
                           fwd_ld_data_int_wr_i[15: 0], load_buffer[15: 0]};
        nxt_load_buffer = {fwd_ld_data_int_wr_i[63:32],
                           load_buffer[63:32]};
      end
      {`CA53_LS_ELEM_SIZE_16BIT, 2'b11, 2'b10}: begin
        ld_data_f3_o    = {load_buffer[63:48], load_buffer[31:16],
                           load_buffer[47:32], load_buffer[15: 0]};
        nxt_load_buffer = fwd_ld_data_int_wr_i[63:0];
      end

      default: begin
        ld_data_f3_o    = {64{1'bx}};
        nxt_load_buffer = {64{1'bx}};
      end
    endcase

  // Register the buffered data
  assign load_buffer_en = instr_is_cp10_cp11_wr_i & vldn_perm_en & valid_instrs_wr_i & ~first_x64_wr_i & ~stall_wr_i;

  always @(posedge clk_fp)
    if (load_buffer_en)
      load_buffer <= nxt_load_buffer;

  always @*
    case (ls_elem_size_wr_i | {2{vldn_dup}})
      2'b00: // 8-bit
        case (vldn_perm_select_lo[1:0])
          2'b00:    dup_mask = 4'b0001;
          2'b01:    dup_mask = 4'b0010;
          2'b10:    dup_mask = 4'b0100;
          2'b11:    dup_mask = 4'b1000;
          default:  dup_mask = {4{1'bx}};
        endcase

      2'b01: // 16-bit
        case (vldn_perm_select_lo[1])
          1'b0:     dup_mask = 4'b0011;
          1'b1:     dup_mask = 4'b1100;
          default:  dup_mask = {4{1'bx}};
        endcase

      2'b10,2'b11: // 32-bit, or vldn_dup
        dup_mask = 4'b1111;

      default:
        dup_mask = {4{1'bx}};
    endcase

  always @*
    case (ls_elem_size_wr_i)
      2'b00: begin // 8-bit
        dup_data[31: 0] = {4{fwd_ld_data_int_wr_i[ 7: 0]}};
        dup_data[63:32] = {4{fwd_ld_data_int_wr_i[15: 8]}};
      end

      2'b01: begin // 16-bit
        dup_data[31: 0] = {2{fwd_ld_data_int_wr_i[15: 0]}};
        dup_data[63:32] = {2{fwd_ld_data_int_wr_i[31:16]}};
      end

      2'b10, 2'b11: // 32-bit
        dup_data = fwd_ld_data_int_wr_i[63:0];

      default:
        dup_data = {64{1'bx}};
    endcase

  assign dup_ld_data_f3_o[ 7: 0] = dup_mask[0] ? dup_data[ 7: 0] : st0_data_wr_i[ 7: 0];
  assign dup_ld_data_f3_o[15: 8] = dup_mask[1] ? dup_data[15: 8] : st0_data_wr_i[15: 8];
  assign dup_ld_data_f3_o[23:16] = dup_mask[2] ? dup_data[23:16] : st0_data_wr_i[23:16];
  assign dup_ld_data_f3_o[31:24] = dup_mask[3] ? dup_data[31:24] : st0_data_wr_i[31:24];

  assign dup_ld_data_f3_o[39:32] = dup_mask[0] ? dup_data[39:32] : st0_data_wr_i[39:32];
  assign dup_ld_data_f3_o[47:40] = dup_mask[1] ? dup_data[47:40] : st0_data_wr_i[47:40];
  assign dup_ld_data_f3_o[55:48] = dup_mask[2] ? dup_data[55:48] : st0_data_wr_i[55:48];
  assign dup_ld_data_f3_o[63:56] = dup_mask[3] ? dup_data[63:56] : st0_data_wr_i[63:56];

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_buffer_en")
  u_ovl_x_load_buffer_en (.clk       (clk_fp),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (load_buffer_en));
  // OVL_ASSERT_END

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
