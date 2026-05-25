//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-11-18 17:02:59 +0000 (Fri, 18 Nov 2011) $
//
//      Revision            : $Revision: 192060 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Neon multiplier array
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs SIMD multiplication of 1x54x54, 2x32x32, 4x16x16 or 8x8x8
//

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_fp_mul_array (
  // Inputs
  input  wire         clk_fp_mul,
  input  wire         reset_n,
  input  wire         array_en_f1_i,
  input  wire         array_en_f2_i,
  input  wire   [1:0] mul_size_f1_i,
  input  wire   [1:0] mul_size_f2_i,
  input  wire         signed_f2_i,
  input  wire   [1:0] mul_size_f3_i,
  input  wire  [63:0] mul_op_a_f1_i,
  input  wire  [63:0] mul_op_a_f2_i,
  input  wire  [63:0] mul_op_b_f2_i,
  input  wire   [3:0] neon_mul_sat_f3_i,
  input  wire [119:0] acc_val_f3_i,
  input  wire   [1:0] acc_halfprec_bits_f3_i,
  // Outputs
  output wire [126:0] mul_sum_raw_f3_o,
  output wire   [1:0] mul_halfprec_sum_f3_o
);

  // -----------------------------
  // Constant declarations
  // -----------------------------

  localparam P1 = 3;
  localparam P2 = 2;
  localparam M1 = 1;
  localparam M2 = 0;

  // -----------------------------
  // Genvar declarations
  // -----------------------------

  genvar i;
  genvar prod;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg    [1:0]  mul_size_array_f2 [8:0];
  reg   [32:0]  borrow_mask;
  reg   [32:1]  borrow_f2;
  reg   [67:0]  header_mask [32:0];
  reg    [3:0]  benc        [32:0];
  reg   [63:0]  prod_mask   [32:0];
  reg   [63:0]  lsb_mask    [32:0];
  reg   [32:1]  uns_mask_qual;
  reg  [126:0]  carry_mask_f2;
  reg  [126:0]  carry_mask_f3;
  reg  [112:0]  raw_pp_stage5_f3_0;
  reg  [126:26] raw_pp_stage5_f3_1;
  reg           raw_pp_stage5_f3_2_5;
  reg   [84:7]  raw_pp_stage5_f3_2_84_7;
  reg           raw_pp_stage5_f3_2_89;
  reg  [126:91] raw_pp_stage5_f3_2_126_91;
  reg  [121:39] raw_pp_stage5_f3_3;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [32:0]  carry_out;
  wire  [32:1]  borrow_f1;
  wire  [63:0]  uns_mask      [32:0];
  wire  [63:0]  carrybit_mask [32:0];
  wire  [67:0]  header_val    [32:0];
  wire  [63:0]  bsel_p1       [32:0];
  wire  [63:0]  bsel_p2       [32:0];
  wire  [63:0]  bsel_m1       [32:0];
  wire  [63:0]  bsel_m2       [32:0];
  wire  [69:0]  bmux          [32:0];
  wire [135:0]  mul_sum_opa_exp;
  wire [135:0]  mul_sum_opb_exp;
  wire [135:0]  mul_sum_exp;
  wire          mul_sum_carryin;
  wire [126:0]  pp_stage0_f2  [32:0];
  wire [126:0]  pp_stage1_f2  [21:0];
  wire [126:0]  pp_stage2_f2  [14:0];
  wire [126:0]  pp_stage3_f2   [9:0];
  wire [126:0]  pp_stage4_f2   [6:0];
  wire [126:0]  pp_stage5_f2   [4:0];
  wire [126:0]  pp_stage5_f3   [5:0];
  wire [126:0]  pp_stage6_f3   [3:0];
  wire [126:0]  pp_stage7_f3   [2:0];
  wire [126:0]  pp_stage8_f3   [1:0];

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  generate for (i = 0; i < 9; i = i + 1) begin : g_size_reg
    always @(posedge clk_fp_mul)
      if (array_en_f1_i)
        mul_size_array_f2[i] <= mul_size_f1_i;
  end endgenerate

  always @*
    case (mul_size_f1_i)
      2'b00: borrow_mask = 33'h1_EEEE_EEEE;
      2'b01: borrow_mask = 33'h1_FEFE_FEFE;
      2'b10: borrow_mask = 33'h1_FFFE_FFFE;
      2'b11: borrow_mask = 33'h1_FFFF_FFFE;
      default: borrow_mask = {33{1'bx}};
    endcase

  generate for (i = 1; i < 33; i = i + 1) begin : g_borrow
    assign borrow_f1[i] = mul_op_a_f1_i[i*2-1] & borrow_mask[i];
  end endgenerate

  always @(posedge clk_fp_mul)
    if (array_en_f1_i)
      borrow_f2 <= borrow_f1;

  function [3:0] gen_header;
    input integer p;
    input [1:0] size_f2;
    input signed_f2;
    input topbit;
    input [3:0] benc;

    reg       extbit;
    reg [3:0] long_header;

    begin
      extbit = topbit & signed_f2;

      long_header = ({4{benc[P1]}} &   {4{ extbit}}          ) |
                    ({4{benc[P2]}} & { {3{ extbit}},  topbit}) |
                    ({4{benc[M1]}} &   {4{~extbit}}          ) |
                    ({4{benc[M2]}} & { {3{~extbit}}, ~topbit});

      if (((size_f2 == 2'b00) && ((p % 4)  == 0)) ||
          ((size_f2 == 2'b01) && ((p % 8)  == 0)) ||
          ((size_f2 == 2'b10) && ((p % 16) == 0)) ||
          (p == 0)) begin
        gen_header = long_header ^ 4'b1000;
      end else if (((size_f2 == 2'b00) && ((p % 4)  == 3))  ||
                   ((size_f2 == 2'b01) && ((p % 8)  == 7)) ||
                   ((size_f2 == 2'b10) && ((p % 16) == 15))) begin
        gen_header = {2'b00, long_header[1:0] ^ 2'b10};
      end else begin
        gen_header = {2'b01, long_header[1:0] ^ 2'b10};
      end
    end
  endfunction

  generate for (prod = 0; prod < 33; prod = prod + 1) begin : g_product
    wire  [1:0] mul_size_f2;
    wire        borrow;
    wire        carry_in;
    wire        add_unsigned;

    assign mul_size_f2 = mul_size_array_f2[prod/4];

    if (prod == 0) begin : g_borrow0
      assign borrow              = 1'b0;
      assign carry_in            = 1'b0;
      assign add_unsigned        = 1'b0;
      assign carrybit_mask[prod] = {64{1'b0}};
    end else begin : g_borrow_others
      assign borrow              = borrow_f2[prod];
      assign carry_in            = carry_out[prod-1];
      assign add_unsigned        = ~signed_f2_i & mul_op_a_f2_i[prod*2-1];
      assign carrybit_mask[prod] = lsb_mask[prod-1];
    end

    if (prod < 32) begin : g_benc_low
      always @*
        case ({mul_op_a_f2_i[prod*2+:2], borrow})
          3'b000:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0000;
          3'b001:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b1000;
          3'b010:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b1000;
          3'b011:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0100;
          3'b100:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0001;
          3'b101:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0010;
          3'b110:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0010;
          3'b111:  {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0000;
          default: {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'bxxxx;
        endcase
    end else begin : g_benc_top
      always @*
        case (borrow)
          1'b0:    {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b0000;
          1'b1:    {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'b1000;
          default: {benc[prod][P1], benc[prod][P2], benc[prod][M1], benc[prod][M2]} = 4'bxxxx;
        endcase
    end

    assign carry_out[prod] = benc[prod][M1] | benc[prod][M2];

    assign header_val[prod][ 7: 0] = 8'h00;
    assign header_val[prod][11: 8] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[ 7], benc[prod]);
    assign header_val[prod][15:12] = 4'h0;
    assign header_val[prod][19:16] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[15], benc[prod]);
    assign header_val[prod][23:20] = 4'h0;
    assign header_val[prod][27:24] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[23], benc[prod]);
    assign header_val[prod][31:28] = 4'h0;
    assign header_val[prod][35:32] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[31], benc[prod]);
    assign header_val[prod][39:36] = 4'h0;
    assign header_val[prod][43:40] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[39], benc[prod]);
    assign header_val[prod][47:44] = 4'h0;
    assign header_val[prod][51:48] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[47], benc[prod]);
    assign header_val[prod][52]    = 1'b0;
    assign header_val[prod][59:53] = (mul_size_f2 == 2'b11) ? {3'b000, gen_header(prod, 2'b11, signed_f2_i, mul_op_b_f2_i[52], benc[prod])}
                                                      : {gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[55], benc[prod]), 3'b000};
    assign header_val[prod][63:60] = 4'h0;
    assign header_val[prod][67:64] = gen_header(prod, mul_size_f2, signed_f2_i, mul_op_b_f2_i[63], benc[prod]);

    always @*
      case (mul_size_f2)
        2'b00:   prod_mask[prod] = 64'h00000000_000000FF << ((prod / 4)  * 8);
        2'b01:   prod_mask[prod] = 64'h00000000_0000FFFF << ((prod / 8)  * 16);
        2'b10:   prod_mask[prod] = 64'h00000000_FFFFFFFF << ((prod / 16) * 32);
        2'b11:   prod_mask[prod] = 64'h001FFFFF_FFFFFFFF << ((prod / 27) * 64);
        default: prod_mask[prod] = {64{1'bx}};
      endcase

    always @*
      case (mul_size_f2)
        2'b00:   lsb_mask[prod] = 64'h00000000_00000001 << ((prod / 4)  * 8);
        2'b01:   lsb_mask[prod] = 64'h00000000_00000001 << ((prod / 8)  * 16);
        2'b10:   lsb_mask[prod] = 64'h00000000_00000001 << ((prod / 16) * 32);
        2'b11:   lsb_mask[prod] = 64'h00000000_00000001 << ((prod / 27) * 64);
        default: lsb_mask[prod] = {64{1'bx}};
      endcase

    if (prod == 0) begin : g_uns_mask0
      assign uns_mask[prod] = {64{1'b0}};
    end else begin : g_uns_mask_others
      always @*
        case (mul_size_f2)
          2'b00:   uns_mask_qual[prod] = ((prod % 4)  == 0);
          2'b01:   uns_mask_qual[prod] = ((prod % 8)  == 0);
          2'b10:   uns_mask_qual[prod] = ((prod % 16) == 0);
          2'b11:   uns_mask_qual[prod] = ((prod % 27) == 0);
          default: uns_mask_qual[prod] = 1'bx;
        endcase

      assign uns_mask[prod] = {64{uns_mask_qual[prod]}} & prod_mask[prod-1];
    end

    always @*
      case (mul_size_f2)
        2'b00:   header_mask[prod] = 68'h0_00000000_00000F00 << ((prod / 4)  * 8);
        2'b01:   header_mask[prod] = 68'h0_00000000_000F0000 << ((prod / 8)  * 16);
        2'b10:   header_mask[prod] = 68'h0_0000000F_00000000 << ((prod / 16) * 32);
        2'b11:   header_mask[prod] = (prod == 0) ? 68'h0_01E00000_00000000 :
                                     (prod < 27) ? 68'h0_00E00000_00000000 :
                                                   68'h0_00000000_00000000;
        default: header_mask[prod] = {68{1'bx}};
      endcase

    assign bsel_p1[prod] = ({64{benc[prod][P1]}} & prod_mask[prod]) | ({64{add_unsigned}} & uns_mask[prod]);
    assign bsel_p2[prod] =  {64{benc[prod][P2]}} & prod_mask[prod];
    assign bsel_m1[prod] =  {64{benc[prod][M1]}} & prod_mask[prod];
    assign bsel_m2[prod] =  {64{benc[prod][M2]}} & prod_mask[prod];

    assign bmux[prod] = ({4'b0000, (bsel_p1[prod]  &   mul_op_b_f2_i),                                      2'b00}) |
                        ({4'b0000, (bsel_p2[prod]  & { mul_op_b_f2_i[62:0] & ~lsb_mask[prod][63:1], 1'b0}), 2'b00}) |
                        ({4'b0000, (bsel_m1[prod]  &  ~mul_op_b_f2_i),                                      2'b00}) |
                        ({4'b0000, (bsel_m2[prod]  & {~mul_op_b_f2_i[62:0] |  lsb_mask[prod][63:1], 1'b1}), 2'b00}) |
                        ({(header_mask[prod] & header_val[prod]),                                           2'b00}) |
                        ({70{carry_in}} & {6'b000000, carrybit_mask[prod]});

  end endgenerate

  assign pp_stage0_f2[ 0] = { {59{1'b0}}, bmux[ 0][69: 2]};
  assign pp_stage0_f2[ 1] = { {57{1'b0}}, bmux[ 1][69: 0]};
  assign pp_stage0_f2[ 2] = { {55{1'b0}}, bmux[ 2][69: 0], { 2{1'b0}} };
  assign pp_stage0_f2[ 3] = { {53{1'b0}}, bmux[ 3][69: 0], { 4{1'b0}} };
  assign pp_stage0_f2[ 4] = { {51{1'b0}}, bmux[ 4][69: 0], { 6{1'b0}} };
  assign pp_stage0_f2[ 5] = { {49{1'b0}}, bmux[ 5][69: 0], { 8{1'b0}} };
  assign pp_stage0_f2[ 6] = { {47{1'b0}}, bmux[ 6][69: 0], {10{1'b0}} };
  assign pp_stage0_f2[ 7] = { {45{1'b0}}, bmux[ 7][69: 0], {12{1'b0}} };
  assign pp_stage0_f2[ 8] = { {43{1'b0}}, bmux[ 8][69: 0], {14{1'b0}} };
  assign pp_stage0_f2[ 9] = { {41{1'b0}}, bmux[ 9][69: 0], {16{1'b0}} };
  assign pp_stage0_f2[10] = { {39{1'b0}}, bmux[10][69: 0], {18{1'b0}} };
  assign pp_stage0_f2[11] = { {37{1'b0}}, bmux[11][69: 0], {20{1'b0}} };
  assign pp_stage0_f2[12] = { {35{1'b0}}, bmux[12][69: 0], {22{1'b0}} };
  assign pp_stage0_f2[13] = { {33{1'b0}}, bmux[13][69: 0], {24{1'b0}} };
  assign pp_stage0_f2[14] = { {31{1'b0}}, bmux[14][69: 0], {26{1'b0}} };
  assign pp_stage0_f2[15] = { {29{1'b0}}, bmux[15][69: 0], {28{1'b0}} };
  assign pp_stage0_f2[16] = { {27{1'b0}}, bmux[16][69: 0], {30{1'b0}} };
  assign pp_stage0_f2[17] = { {25{1'b0}}, bmux[17][69: 0], {32{1'b0}} };
  assign pp_stage0_f2[18] = { {23{1'b0}}, bmux[18][69: 0], {34{1'b0}} };
  assign pp_stage0_f2[19] = { {21{1'b0}}, bmux[19][69: 0], {36{1'b0}} };
  assign pp_stage0_f2[20] = { {19{1'b0}}, bmux[20][69: 0], {38{1'b0}} };
  assign pp_stage0_f2[21] = { {17{1'b0}}, bmux[21][69: 0], {40{1'b0}} };
  assign pp_stage0_f2[22] = { {15{1'b0}}, bmux[22][69: 0], {42{1'b0}} };
  assign pp_stage0_f2[23] = { {13{1'b0}}, bmux[23][69: 0], {44{1'b0}} };
  assign pp_stage0_f2[24] = { {11{1'b0}}, bmux[24][69: 0], {46{1'b0}} };
  assign pp_stage0_f2[25] = { { 9{1'b0}}, bmux[25][69: 0], {48{1'b0}} };
  assign pp_stage0_f2[26] = { { 7{1'b0}}, bmux[26][69: 0], {50{1'b0}} };
  assign pp_stage0_f2[27] = { { 5{1'b0}}, bmux[27][69: 0], {52{1'b0}} };
  assign pp_stage0_f2[28] = { { 3{1'b0}}, bmux[28][69: 0], {54{1'b0}} };
  assign pp_stage0_f2[29] = { { 1{1'b0}}, bmux[29][69: 0], {56{1'b0}} };
  assign pp_stage0_f2[30] = {             bmux[30][68: 0], {58{1'b0}} };
  assign pp_stage0_f2[31] = {             bmux[31][66: 0], {60{1'b0}} };
  assign pp_stage0_f2[32] = {             bmux[32][64: 0], {62{1'b0}} };

  function [126:0] csa_sum;
    input [126:0] pp0;
    input [126:0] pp1;
    input [126:0] pp2;

    csa_sum = pp0 ^ pp1 ^ pp2;
  endfunction

  function [126:0] csa_carry;
    input [126:0] pp0;
    input [126:0] pp1;
    input [126:0] pp2;

    begin
      csa_carry[0]    = 1'b0;
      csa_carry[126:1] = (pp0[125:0] & pp1[125:0]) | (pp1[125:0] & pp2[125:0]) | (pp2[125:0] & pp0[125:0]);
    end
  endfunction

  always @*
    case (mul_size_f2_i)
      2'b00:   carry_mask_f2 = 127'h7FFE_FFFE_FFFE_FFFE_FFFE_FFFE_FFFE_FFFE;
      2'b01:   carry_mask_f2 = 127'h7FFF_FFFE_FFFF_FFFE_FFFF_FFFE_FFFF_FFFE;
      2'b10:   carry_mask_f2 = 127'h7FFF_FFFF_FFFF_FFFE_FFFF_FFFF_FFFF_FFFE;
      2'b11:   carry_mask_f2 = 127'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE;
      default: carry_mask_f2 = {127{1'bx}};
    endcase

  assign pp_stage1_f2[ 0] = csa_sum(pp_stage0_f2[ 0], pp_stage0_f2[ 1], pp_stage0_f2[ 2]); // [59:0]
  assign pp_stage1_f2[ 2] = csa_sum(pp_stage0_f2[ 3], pp_stage0_f2[ 4], pp_stage0_f2[ 5]); // [65:4]
  assign pp_stage1_f2[ 4] = csa_sum(pp_stage0_f2[ 6], pp_stage0_f2[ 7], pp_stage0_f2[ 8]); // [71:10]
  assign pp_stage1_f2[ 6] = csa_sum(pp_stage0_f2[ 9], pp_stage0_f2[10], pp_stage0_f2[11]); // [77:16]
  assign pp_stage1_f2[ 8] = csa_sum(pp_stage0_f2[12], pp_stage0_f2[13], pp_stage0_f2[14]); // [83:22]
  assign pp_stage1_f2[10] = csa_sum(pp_stage0_f2[15], pp_stage0_f2[16], pp_stage0_f2[17]); // [100:28]
  assign pp_stage1_f2[12] = csa_sum(pp_stage0_f2[18], pp_stage0_f2[19], pp_stage0_f2[20]); // [106:34]
  assign pp_stage1_f2[14] = csa_sum(pp_stage0_f2[21], pp_stage0_f2[22], pp_stage0_f2[23]); // [112:40]
  assign pp_stage1_f2[16] = csa_sum(pp_stage0_f2[24], pp_stage0_f2[25], pp_stage0_f2[26]); // [118:46]
  assign pp_stage1_f2[18] = csa_sum(pp_stage0_f2[27], pp_stage0_f2[28], pp_stage0_f2[29]); // [124:84]
  assign pp_stage1_f2[20] = csa_sum(pp_stage0_f2[30], pp_stage0_f2[31], pp_stage0_f2[32]); // [126:90]

  assign pp_stage1_f2[ 1] = csa_carry(pp_stage0_f2[ 0], pp_stage0_f2[ 1], pp_stage0_f2[ 2]) & carry_mask_f2; // [58:3], [1]
  assign pp_stage1_f2[ 3] = csa_carry(pp_stage0_f2[ 3], pp_stage0_f2[ 4], pp_stage0_f2[ 5]) & carry_mask_f2; // [64:9], [7]
  assign pp_stage1_f2[ 5] = csa_carry(pp_stage0_f2[ 6], pp_stage0_f2[ 7], pp_stage0_f2[ 8]) & carry_mask_f2; // [70:15], [13]
  assign pp_stage1_f2[ 7] = csa_carry(pp_stage0_f2[ 9], pp_stage0_f2[10], pp_stage0_f2[11]) & carry_mask_f2; // [76:21], [19]
  assign pp_stage1_f2[ 9] = csa_carry(pp_stage0_f2[12], pp_stage0_f2[13], pp_stage0_f2[14]) & carry_mask_f2; // [82:27], [25]
  assign pp_stage1_f2[11] = csa_carry(pp_stage0_f2[15], pp_stage0_f2[16], pp_stage0_f2[17]) & carry_mask_f2; // [100:33], [31]
  assign pp_stage1_f2[13] = csa_carry(pp_stage0_f2[18], pp_stage0_f2[19], pp_stage0_f2[20]) & carry_mask_f2; // [105:39], [37]
  assign pp_stage1_f2[15] = csa_carry(pp_stage0_f2[21], pp_stage0_f2[22], pp_stage0_f2[23]) & carry_mask_f2; // [111:45], [43]
  assign pp_stage1_f2[17] = csa_carry(pp_stage0_f2[24], pp_stage0_f2[25], pp_stage0_f2[26]) & carry_mask_f2; // [117:51], [49]
  assign pp_stage1_f2[19] = csa_carry(pp_stage0_f2[27], pp_stage0_f2[28], pp_stage0_f2[29]) & carry_mask_f2; // [123:89], [87]
  assign pp_stage1_f2[21] = csa_carry(pp_stage0_f2[30], pp_stage0_f2[31], pp_stage0_f2[32]) & carry_mask_f2; // [126:95], [93]

  assign pp_stage2_f2[ 0] = csa_sum(pp_stage1_f2[ 0], pp_stage1_f2[ 1], pp_stage1_f2[ 2]); // [65:0]
  assign pp_stage2_f2[ 2] = csa_sum(pp_stage1_f2[ 3], pp_stage1_f2[ 4], pp_stage1_f2[ 5]); // [71:7]
  assign pp_stage2_f2[ 4] = csa_sum(pp_stage1_f2[ 6], pp_stage1_f2[ 7], pp_stage1_f2[ 8]); // [83:16]
  assign pp_stage2_f2[ 6] = csa_sum(pp_stage1_f2[ 9], pp_stage1_f2[10], pp_stage1_f2[11]); // [100:25]
  assign pp_stage2_f2[ 8] = csa_sum(pp_stage1_f2[12], pp_stage1_f2[13], pp_stage1_f2[14]); // [112:34]
  assign pp_stage2_f2[10] = csa_sum(pp_stage1_f2[15], pp_stage1_f2[16], pp_stage1_f2[17]); // [118:43]
  assign pp_stage2_f2[12] = csa_sum(pp_stage1_f2[18], pp_stage1_f2[19], pp_stage1_f2[20]); // [126:84]

  assign pp_stage2_f2[ 1] = csa_carry(pp_stage1_f2[ 0], pp_stage1_f2[ 1], pp_stage1_f2[ 2]) & carry_mask_f2; // [60:4], [2]
  assign pp_stage2_f2[ 3] = csa_carry(pp_stage1_f2[ 3], pp_stage1_f2[ 4], pp_stage1_f2[ 5]) & carry_mask_f2; // [71:11]
  assign pp_stage2_f2[ 5] = csa_carry(pp_stage1_f2[ 6], pp_stage1_f2[ 7], pp_stage1_f2[ 8]) & carry_mask_f2; // [78:22], [20]
  assign pp_stage2_f2[ 7] = csa_carry(pp_stage1_f2[ 9], pp_stage1_f2[10], pp_stage1_f2[11]) & carry_mask_f2; // [101:29]
  assign pp_stage2_f2[ 9] = csa_carry(pp_stage1_f2[12], pp_stage1_f2[13], pp_stage1_f2[14]) & carry_mask_f2; // [107:40], [38]
  assign pp_stage2_f2[11] = csa_carry(pp_stage1_f2[15], pp_stage1_f2[16], pp_stage1_f2[17]) & carry_mask_f2; // [118:47]
  assign pp_stage2_f2[13] = csa_carry(pp_stage1_f2[18], pp_stage1_f2[19], pp_stage1_f2[20]) & carry_mask_f2; // [125:90], [88]

  assign pp_stage2_f2[14] = pp_stage1_f2[21]; // [126:95], [93]


  assign pp_stage3_f2[ 0] = csa_sum(pp_stage2_f2[ 0], pp_stage2_f2[ 1], pp_stage2_f2[ 2]); // [71:0]
  assign pp_stage3_f2[ 2] = csa_sum(pp_stage2_f2[ 3], pp_stage2_f2[ 4], pp_stage2_f2[ 5]); // [83:11]
  assign pp_stage3_f2[ 4] = csa_sum(pp_stage2_f2[ 6], pp_stage2_f2[ 7], pp_stage2_f2[ 8]); // [112:25]
  assign pp_stage3_f2[ 6] = csa_sum(pp_stage2_f2[ 9], pp_stage2_f2[10], pp_stage2_f2[11]); // [118:38]
  assign pp_stage3_f2[ 8] = csa_sum(pp_stage2_f2[12], pp_stage2_f2[13], pp_stage2_f2[14]); // [126:84]

  assign pp_stage3_f2[ 1] = csa_carry(pp_stage2_f2[ 0], pp_stage2_f2[ 1], pp_stage2_f2[ 2]) & carry_mask_f2; // [66:5], [3]
  assign pp_stage3_f2[ 3] = csa_carry(pp_stage2_f2[ 3], pp_stage2_f2[ 4], pp_stage2_f2[ 5]) & carry_mask_f2; // [79:17]
  assign pp_stage3_f2[ 5] = csa_carry(pp_stage2_f2[ 6], pp_stage2_f2[ 7], pp_stage2_f2[ 8]) & carry_mask_f2; // [102:30]
  assign pp_stage3_f2[ 7] = csa_carry(pp_stage2_f2[ 9], pp_stage2_f2[10], pp_stage2_f2[11]) & carry_mask_f2; // [119:44]
  assign pp_stage3_f2[ 9] = csa_carry(pp_stage2_f2[12], pp_stage2_f2[13], pp_stage2_f2[14]) & carry_mask_f2; // [126:91], [89]


  assign pp_stage4_f2[ 0] = csa_sum(pp_stage3_f2[ 0], pp_stage3_f2[ 1], pp_stage3_f2[ 2]); // [83:0]
  assign pp_stage4_f2[ 2] = csa_sum(pp_stage3_f2[ 3], pp_stage3_f2[ 4], pp_stage3_f2[ 5]); // [112:17]
  assign pp_stage4_f2[ 4] = csa_sum(pp_stage3_f2[ 6], pp_stage3_f2[ 7], pp_stage3_f2[ 8]); // [126:38]

  assign pp_stage4_f2[ 1] = csa_carry(pp_stage3_f2[ 0], pp_stage3_f2[ 1], pp_stage3_f2[ 2]) & carry_mask_f2; // [72:6], [4]
  assign pp_stage4_f2[ 3] = csa_carry(pp_stage3_f2[ 3], pp_stage3_f2[ 4], pp_stage3_f2[ 5]) & carry_mask_f2; // [103:26]
  assign pp_stage4_f2[ 5] = csa_carry(pp_stage3_f2[ 6], pp_stage3_f2[ 7], pp_stage3_f2[ 8]) & carry_mask_f2; // [120:45]

  assign pp_stage4_f2[ 6] = pp_stage3_f2[ 9]; // [126:91], [89]


  assign pp_stage5_f2[ 0] = csa_sum(pp_stage4_f2[ 0], pp_stage4_f2[ 1], pp_stage4_f2[ 2]); // [112:0]
  assign pp_stage5_f2[ 1] = csa_sum(pp_stage4_f2[ 3], pp_stage4_f2[ 4], pp_stage4_f2[ 5]); // [126:26]

  assign pp_stage5_f2[ 2] = csa_carry(pp_stage4_f2[ 0], pp_stage4_f2[ 1], pp_stage4_f2[ 2]) & carry_mask_f2; // [84:7], [5]
  assign pp_stage5_f2[ 3] = csa_carry(pp_stage4_f2[ 3], pp_stage4_f2[ 4], pp_stage4_f2[ 5]) & carry_mask_f2; // [121:39]

  assign pp_stage5_f2[ 4] = pp_stage4_f2[ 6]; // [126:91], [89]

  always @(posedge clk_fp_mul)
    if (array_en_f2_i) begin
      raw_pp_stage5_f3_0[112:0]         <= pp_stage5_f2[0][112:0];
      raw_pp_stage5_f3_1[126:26]        <= pp_stage5_f2[1][126:26];
      raw_pp_stage5_f3_2_84_7[84:7]     <= pp_stage5_f2[2][84:7];
      raw_pp_stage5_f3_2_5              <= pp_stage5_f2[2][5];
      raw_pp_stage5_f3_3[121:39]        <= pp_stage5_f2[3][121:39];
      raw_pp_stage5_f3_2_126_91[126:91] <= pp_stage5_f2[4][126:91]; // Merge product 4 into product 2 as they don't overlap
      raw_pp_stage5_f3_2_89             <= pp_stage5_f2[4][89];
    end

  assign pp_stage5_f3[0][126:113] = { 14{1'b0}};
  assign pp_stage5_f3[0][112:  0] = raw_pp_stage5_f3_0[112:0];

  assign pp_stage5_f3[1][126: 26] = raw_pp_stage5_f3_1[126:26];
  assign pp_stage5_f3[1][ 25:  0] = { 26{1'b0}};

  assign pp_stage5_f3[2][126: 91] = raw_pp_stage5_f3_2_126_91[126:91];
  assign pp_stage5_f3[2][ 90]     =      1'b0;
  assign pp_stage5_f3[2][ 89]     =      raw_pp_stage5_f3_2_89;
  assign pp_stage5_f3[2][ 88: 85] = {  4{1'b0}};
  assign pp_stage5_f3[2][ 84:  7] = raw_pp_stage5_f3_2_84_7[84:7];
  assign pp_stage5_f3[2][  6]     =      1'b0;
  assign pp_stage5_f3[2][  5]     = raw_pp_stage5_f3_2_5;
  assign pp_stage5_f3[2][  4:  0] = {  5{1'b0}};

  assign pp_stage5_f3[3][126:122] = {  5{1'b0}};
  assign pp_stage5_f3[3][121: 39] = raw_pp_stage5_f3_3[121:39];
  assign pp_stage5_f3[3][ 38:  0] = { 39{1'b0}};

  assign pp_stage5_f3[4]          = {127{1'b1}}; // Set pp4 to -1

  assign pp_stage5_f3[5] = {7'h00, acc_val_f3_i};

  always @*
    case (mul_size_f3_i)
      2'b00:   carry_mask_f3 = 127'h7FFE_FFFE_FFFE_FFFE_FFFE_FFFE_FFFE_FFFE;
      2'b01:   carry_mask_f3 = 127'h7FFF_FFFE_FFFF_FFFE_FFFF_FFFE_FFFF_FFFE;
      2'b10:   carry_mask_f3 = 127'h7FFF_FFFF_FFFF_FFFE_FFFF_FFFF_FFFF_FFFE;
      2'b11:   carry_mask_f3 = 127'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE;
      default: carry_mask_f3 = {127{1'bx}};
    endcase


  assign pp_stage6_f3[ 0] = csa_sum(pp_stage5_f3[ 0], pp_stage5_f3[ 1], pp_stage5_f3[ 2]);
  assign pp_stage6_f3[ 1] = csa_sum(pp_stage5_f3[ 3], pp_stage5_f3[ 4], pp_stage5_f3[ 5]);
  assign pp_stage6_f3[ 2] = csa_carry(pp_stage5_f3[ 0], pp_stage5_f3[ 1], pp_stage5_f3[ 2]) & carry_mask_f3;
  assign pp_stage6_f3[ 3] = csa_carry(pp_stage5_f3[ 3], pp_stage5_f3[ 4], pp_stage5_f3[ 5]) & carry_mask_f3;

  assign pp_stage7_f3[ 0] = csa_sum(pp_stage6_f3[ 0], pp_stage6_f3[ 1], pp_stage6_f3[ 2]);
  assign pp_stage7_f3[ 1] = csa_carry(pp_stage6_f3[ 0], pp_stage6_f3[ 1], pp_stage6_f3[ 2]) & carry_mask_f3;
  assign pp_stage7_f3[ 2] = pp_stage6_f3[ 3];

  assign pp_stage8_f3[ 0] = csa_sum(pp_stage7_f3[ 0], pp_stage7_f3[ 1], pp_stage7_f3[ 2]);
  assign pp_stage8_f3[ 1] = csa_carry(pp_stage7_f3[ 0], pp_stage7_f3[ 1], pp_stage7_f3[ 2]) & carry_mask_f3;



  assign mul_sum_opa_exp = {pp_stage8_f3[0][126:112],                            ~carry_mask_f3[112],
                            pp_stage8_f3[0][111: 96],                            ~carry_mask_f3[ 96] & ~neon_mul_sat_f3_i[3],
                            pp_stage8_f3[0][ 95: 80],                            ~carry_mask_f3[ 80],
                            pp_stage8_f3[0][ 79: 64],                            ~carry_mask_f3[ 64] & ~neon_mul_sat_f3_i[2],
                            pp_stage8_f3[0][ 63: 48],                            ~carry_mask_f3[ 48],
                            pp_stage8_f3[0][ 47: 32], 1'b1,                      ~carry_mask_f3[ 32] & ~neon_mul_sat_f3_i[1],
                            pp_stage8_f3[0][ 31: 16],                            ~carry_mask_f3[ 16],
                            pp_stage8_f3[0][ 15:  0], 1'b1};

  assign mul_sum_opb_exp = {pp_stage8_f3[1][126:112],                            1'b1,
                            pp_stage8_f3[1][111: 96],                            ~neon_mul_sat_f3_i[3],
                            pp_stage8_f3[1][ 95: 80],                            1'b1,
                            pp_stage8_f3[1][ 79: 64],                            ~neon_mul_sat_f3_i[2],
                            pp_stage8_f3[1][ 63: 48],                            1'b1,
                            pp_stage8_f3[1][ 47: 32], acc_halfprec_bits_f3_i[1], ~neon_mul_sat_f3_i[1],
                            pp_stage8_f3[1][ 31: 16],                            1'b1,
                            pp_stage8_f3[1][ 15:  0], acc_halfprec_bits_f3_i[0]};

  assign mul_sum_carryin = ~neon_mul_sat_f3_i[0];

  assign mul_sum_exp = mul_sum_opa_exp + mul_sum_opb_exp + mul_sum_carryin;

  assign mul_sum_raw_f3_o = {mul_sum_exp[135:121],
                             mul_sum_exp[119:104],
                             mul_sum_exp[102: 87],
                             mul_sum_exp[ 85: 70],
                             mul_sum_exp[ 68: 53],
                             mul_sum_exp[ 51: 36],
                             mul_sum_exp[ 33: 18],
                             mul_sum_exp[ 16:  1]};

  assign mul_halfprec_sum_f3_o = {mul_sum_exp[35], mul_sum_exp[0]};

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: array_en_f1_i")
  u_ovl_x_array_en_f1_i (
    .clk       (clk_fp_mul),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (array_en_f1_i)
  );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: array_en_f2_i")
  u_ovl_x_array_en_f2_i (
    .clk       (clk_fp_mul),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (array_en_f2_i)
  );

  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_fp_mul_array

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
