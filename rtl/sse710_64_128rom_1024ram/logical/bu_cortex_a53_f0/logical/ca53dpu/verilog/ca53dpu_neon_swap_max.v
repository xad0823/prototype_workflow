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
// Abstract : Neon Comparison Block
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs comparison of the input vector operands and swap them
// in order the greater to be the operand a

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_neon_swap_max (
  // Inputs
  input wire    [1:0] neon_size_sel_f2_i,     // Size of vector elements (32,16,8)
  input wire          neon_unsigned_op_f2_i,  // Signed or unsigned comparison
  input wire   [63:0] neon_perm_opa_f2_i,     // Vn or Vd operand
  input wire   [63:0] neon_perm_opb_f2_i,     // Vm operand
  // Outputs
  output wire  [63:0] neon_swap_max_f2_o,     // Operand a
  output wire  [63:0] neon_swap_min_f2_o,     // Operand b
  output wire  [63:0] neon_cmp_gt_f2_o,       // Greater than result vector
  output wire  [63:0] neon_cmp_eq_f2_o        // Equal to result vector
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [7:0] aeqb;
  reg   [7:0] agtb;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [7:0] gtopnd;
  wire  [7:0] eqopnd;
  wire  [7:0] a_msb;
  wire  [7:0] b_msb;
  wire  [7:0] eqmsb;
  wire [63:0] nswap;
  wire [63:0] equal;
  wire  [7:0] syndrome_a;
  wire  [7:0] syndrome_b;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  assign gtopnd[0] = neon_perm_opa_f2_i[ 7: 0] >  neon_perm_opb_f2_i[ 7: 0];
  assign gtopnd[1] = neon_perm_opa_f2_i[15: 8] >  neon_perm_opb_f2_i[15: 8];
  assign gtopnd[2] = neon_perm_opa_f2_i[23:16] >  neon_perm_opb_f2_i[23:16];
  assign gtopnd[3] = neon_perm_opa_f2_i[31:24] >  neon_perm_opb_f2_i[31:24];
  assign gtopnd[4] = neon_perm_opa_f2_i[39:32] >  neon_perm_opb_f2_i[39:32];
  assign gtopnd[5] = neon_perm_opa_f2_i[47:40] >  neon_perm_opb_f2_i[47:40];
  assign gtopnd[6] = neon_perm_opa_f2_i[55:48] >  neon_perm_opb_f2_i[55:48];
  assign gtopnd[7] = neon_perm_opa_f2_i[63:56] >  neon_perm_opb_f2_i[63:56];

  assign eqopnd[0] = neon_perm_opa_f2_i[ 7: 0] == neon_perm_opb_f2_i[ 7: 0];
  assign eqopnd[1] = neon_perm_opa_f2_i[15: 8] == neon_perm_opb_f2_i[15: 8];
  assign eqopnd[2] = neon_perm_opa_f2_i[23:16] == neon_perm_opb_f2_i[23:16];
  assign eqopnd[3] = neon_perm_opa_f2_i[31:24] == neon_perm_opb_f2_i[31:24];
  assign eqopnd[4] = neon_perm_opa_f2_i[39:32] == neon_perm_opb_f2_i[39:32];
  assign eqopnd[5] = neon_perm_opa_f2_i[47:40] == neon_perm_opb_f2_i[47:40];
  assign eqopnd[6] = neon_perm_opa_f2_i[55:48] == neon_perm_opb_f2_i[55:48];
  assign eqopnd[7] = neon_perm_opa_f2_i[63:56] == neon_perm_opb_f2_i[63:56];

  assign a_msb[0] = neon_perm_opa_f2_i[ 7];
  assign a_msb[1] = neon_perm_opa_f2_i[15];
  assign a_msb[2] = neon_perm_opa_f2_i[23];
  assign a_msb[3] = neon_perm_opa_f2_i[31];
  assign a_msb[4] = neon_perm_opa_f2_i[39];
  assign a_msb[5] = neon_perm_opa_f2_i[47];
  assign a_msb[6] = neon_perm_opa_f2_i[55];
  assign a_msb[7] = neon_perm_opa_f2_i[63];

  assign b_msb[0] = neon_perm_opb_f2_i[ 7];
  assign b_msb[1] = neon_perm_opb_f2_i[15];
  assign b_msb[2] = neon_perm_opb_f2_i[23];
  assign b_msb[3] = neon_perm_opb_f2_i[31];
  assign b_msb[4] = neon_perm_opb_f2_i[39];
  assign b_msb[5] = neon_perm_opb_f2_i[47];
  assign b_msb[6] = neon_perm_opb_f2_i[55];
  assign b_msb[7] = neon_perm_opb_f2_i[63];

  assign eqmsb[0] = a_msb[0] == b_msb[0];
  assign eqmsb[1] = a_msb[1] == b_msb[1];
  assign eqmsb[2] = a_msb[2] == b_msb[2];
  assign eqmsb[3] = a_msb[3] == b_msb[3];
  assign eqmsb[4] = a_msb[4] == b_msb[4];
  assign eqmsb[5] = a_msb[5] == b_msb[5];
  assign eqmsb[6] = a_msb[6] == b_msb[6];
  assign eqmsb[7] = a_msb[7] == b_msb[7];

  // Calculate two syndromes which can be used to perform the comparison
  // Each pair of byte of input is reduced to a pair of two-bit values
  // The upper bit of each pair is the MSB of the corresponding byte,
  // while the lower bit pair is calculated from the other seven bits to
  // have the same comparison relationship (>, < or ==)

  assign syndrome_a = gtopnd;

  assign syndrome_b = ~eqopnd & ~gtopnd;

  always @*
    case ({neon_unsigned_op_f2_i, neon_size_sel_f2_i})
      3'b000 : begin // signed 8-bit elements comparison
        agtb[7] = eqmsb[7] ? gtopnd[7] : ~a_msb[7];
        agtb[6] = eqmsb[6] ? gtopnd[6] : ~a_msb[6];
        agtb[5] = eqmsb[5] ? gtopnd[5] : ~a_msb[5];
        agtb[4] = eqmsb[4] ? gtopnd[4] : ~a_msb[4];
        agtb[3] = eqmsb[3] ? gtopnd[3] : ~a_msb[3];
        agtb[2] = eqmsb[2] ? gtopnd[2] : ~a_msb[2];
        agtb[1] = eqmsb[1] ? gtopnd[1] : ~a_msb[1];
        agtb[0] = eqmsb[0] ? gtopnd[0] : ~a_msb[0];

        aeqb[7] = eqopnd[7];
        aeqb[6] = eqopnd[6];
        aeqb[5] = eqopnd[5];
        aeqb[4] = eqopnd[4];
        aeqb[3] = eqopnd[3];
        aeqb[2] = eqopnd[2];
        aeqb[1] = eqopnd[1];
        aeqb[0] = eqopnd[0];
      end
      3'b001 : begin // signed 16-bit elements comparison
        agtb[7:6] = {2{eqmsb[7] ? syndrome_a[7:6] > syndrome_b[7:6] : ~a_msb[7]}};
        agtb[5:4] = {2{eqmsb[5] ? syndrome_a[5:4] > syndrome_b[5:4] : ~a_msb[5]}};
        agtb[3:2] = {2{eqmsb[3] ? syndrome_a[3:2] > syndrome_b[3:2] : ~a_msb[3]}};
        agtb[1:0] = {2{eqmsb[1] ? syndrome_a[1:0] > syndrome_b[1:0] : ~a_msb[1]}};

        aeqb[7:6] = {2{&eqopnd[7:6]}};
        aeqb[5:4] = {2{&eqopnd[5:4]}};
        aeqb[3:2] = {2{&eqopnd[3:2]}};
        aeqb[1:0] = {2{&eqopnd[1:0]}};
      end
      3'b010 : begin // signed 32-bit elements comparison
        agtb[7:4] = {4{eqmsb[7] ? syndrome_a[7:4] > syndrome_b[7:4] : ~a_msb[7]}};
        agtb[3:0] = {4{eqmsb[3] ? syndrome_a[3:0] > syndrome_b[3:0] : ~a_msb[3]}};

        aeqb[7:4] = {4{&eqopnd[7:4]}};
        aeqb[3:0] = {4{&eqopnd[3:0]}};
      end
      3'b011 : begin // signed 64-bit elements comparison
        agtb[7:0] = {8{eqmsb[7] ? syndrome_a[7:0] > syndrome_b[7:0] : ~a_msb[7]}};

        aeqb[7:0] = {8{&eqopnd[7:0]}};
      end
      3'b100 : begin // unsigned 8-bit elements comparison
        agtb[7] = gtopnd[7];
        agtb[6] = gtopnd[6];
        agtb[5] = gtopnd[5];
        agtb[4] = gtopnd[4];
        agtb[3] = gtopnd[3];
        agtb[2] = gtopnd[2];
        agtb[1] = gtopnd[1];
        agtb[0] = gtopnd[0];

        aeqb[7] = eqopnd[7];
        aeqb[6] = eqopnd[6];
        aeqb[5] = eqopnd[5];
        aeqb[4] = eqopnd[4];
        aeqb[3] = eqopnd[3];
        aeqb[2] = eqopnd[2];
        aeqb[1] = eqopnd[1];
        aeqb[0] = eqopnd[0];
      end
      3'b101 : begin // unsigned 16-bit elements comparison
        agtb[7:6] = {2{syndrome_a[7:6] > syndrome_b[7:6]}};
        agtb[5:4] = {2{syndrome_a[5:4] > syndrome_b[5:4]}};
        agtb[3:2] = {2{syndrome_a[3:2] > syndrome_b[3:2]}};
        agtb[1:0] = {2{syndrome_a[1:0] > syndrome_b[1:0]}};

        aeqb[7:6] = {2{&eqopnd[7:6]}};
        aeqb[5:4] = {2{&eqopnd[5:4]}};
        aeqb[3:2] = {2{&eqopnd[3:2]}};
        aeqb[1:0] = {2{&eqopnd[1:0]}};
      end
      3'b110 : begin // unsigned 32-bit elements comparison
        agtb[7:4] = {4{syndrome_a[7:4] > syndrome_b[7:4]}};
        agtb[3:0] = {4{syndrome_a[3:0] > syndrome_b[3:0]}};

        aeqb[7:4] = {4{&eqopnd[7:4]}};
        aeqb[3:0] = {4{&eqopnd[3:0]}};
      end
      3'b111 : begin // unsigned 64-bit elements comparison
        agtb[7:0] = {8{syndrome_a[7:0] > syndrome_b[7:0]}};

        aeqb[7:0] = {8{&eqopnd[7:0]}};
      end
      default : begin
        agtb[7:0] = {8{1'bx}};
        aeqb[7:0] = {8{1'bx}};
      end
    endcase

  assign nswap = { {8{agtb[7]}}, {8{agtb[6]}}, {8{agtb[5]}}, {8{agtb[4]}}, {8{agtb[3]}}, {8{agtb[2]}}, {8{agtb[1]}}, {8{agtb[0]}} };
  assign equal = { {8{aeqb[7]}}, {8{aeqb[6]}}, {8{aeqb[5]}}, {8{aeqb[4]}}, {8{aeqb[3]}}, {8{aeqb[2]}}, {8{aeqb[1]}}, {8{aeqb[0]}} };

  // Selects the greater operand as the operand a
  assign neon_swap_max_f2_o = ( nswap & neon_perm_opa_f2_i) | (~nswap & neon_perm_opb_f2_i);
  assign neon_swap_min_f2_o = (~nswap & neon_perm_opa_f2_i) | ( nswap & neon_perm_opb_f2_i);

  // If the operand a is equal or greater than operand b then the output is set to all ones
  assign neon_cmp_gt_f2_o = nswap;
  assign neon_cmp_eq_f2_o = equal;

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
