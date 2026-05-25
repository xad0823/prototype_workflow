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
// Abstract: SIMD Adder for the ALU stage
// ----------------------------------------------------------------------------
//
// Overview
// ========
//
// This block contians the Main Arithmetic Unit for the ALU pipeline.
// The Arithmetic Unit uses a single 70-bit adder with interleaved
// control bits to allow SIMD computation.
//----------------------------------------------------------------------------

module ca53dpu_alu_au (
  // Inputs
  input  wire  [63:0] alu_data_a_i,               // Adder A operand
  input  wire  [63:0] alu_data_b_i,               // Adder B operand
  input  wire         ctl_64bit_op_i,             // 64 bit enable
  input  wire         cflag_wr_i,                 // Wr value of CFlag.
  input  wire         au_cin_ctl_i,
  input  wire         au_add_sub_cin_ctl_i,
  input  wire         au_simd_instr_addsubx_i,
  input  wire         au_simd_instr_subaddx_i,
  input  wire         au_sel_normal_a_hi_i,
  input  wire         au_sel_invert_a_hi_i,
  input  wire         au_sel_normal_a_lo_i,
  input  wire         au_sel_invert_a_lo_i,
  input  wire         au_sel_normal_b_hi_i,
  input  wire         au_sel_invert_b_hi_i,
  input  wire         au_sel_normal_b_lo_i,
  input  wire         au_sel_invert_b_lo_i,
  input  wire         au_valid_8_bit_simd_i,
  input  wire   [2:0] au_simd_forced_carryin_a_i,
  input  wire   [2:0] au_simd_forced_carryin_b_i,
  input  wire         au_sub_operation_i,
  input  wire         au_shift_rrx_i,             // Shift the B operand and extend
  input  wire         au_valid_simd_i,            // Indicate SIMD operation
  input  wire         au_simd_size_i,             // Indicate SIMD size (8-bit/16-bit)
  input  wire         au_simd_sign_arth_i,        // Indicate SIMD signed/unsigned
  input  wire         au_halving_i,               // Indicate half-word operation
  // Outputs
  output wire         au_nout_o,                  // n-flag from non-simd adder
  output wire  [63:0] au_sum_o,                   // Adder result
  output wire         au_carryin_o,               // Carry used by adder
  output wire   [3:0] au_new_geflags_o,           // GE flags
  output wire   [3:0] au_simd_sat_overflow_o,     // Indicate overflow for Q instructions
  output wire   [3:0] au_simd_sat_direction_o     // Indicate positive or negative overflow
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        alu_au_carryin;
  wire        rrx_bit;
  wire  [3:0] simd_operand_extend_a;
  wire  [3:0] simd_operand_extend_b;
  wire [63:0] alu_data_b_rrx;
  wire [63:0] au_data_a;
  wire [63:0] au_data_b;
  wire [63:0] au_result;
  wire [31:0] au_sum_simd_halving_16;
  wire [31:0] au_sum_simd_halving_8;
  wire [69:0] a_operand_adder;
  wire [69:0] b_operand_adder;
  wire [69:0] au_result_full;
  wire  [3:0] a_signbits;
  wire  [3:0] b_signbits;
  wire  [3:0] au_signbits_result;
  wire  [3:0] au_extend_result;
  wire  [3:0] sub_op_simd;
  wire  [3:0] new_geflags_simd_8;
  wire  [3:0] new_geflags_simd_16;
  wire        sel_no_simd;
  wire        sel_simd_halving_16;
  wire        sel_simd_halving_8;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Operand manipulation
  // ------------------------------------------------------
  //
  // Depending on whether we are doing an add or a subtract we want
  // to do a 1's compliment on the input.  However, the ADDSUBX and
  // SUBADDX instructions require only half the operand to be inverted.
  //
  // A 4:1 one-hot mux formats the b-operand depending on the type of
  // operation we want to do:
  //  - subtract
  //  - addsubx - swap 31:16 with 15:0 then the top 16-bits does
  //              an add and the bottom 16-bits does a sub.
  //  - subaddx - swap 31:16 with 15:0 then the top 16-bits does
  //              a sub and the bottom 16-bits does an add.
  //  - add

  // If rrx, then put cflag into bit 31.
  assign rrx_bit = au_shift_rrx_i ? cflag_wr_i : alu_data_b_i[31];

  // The B operand has the modified bit 31 inserted
  assign alu_data_b_rrx[63:0] = {alu_data_b_i[63:32], rrx_bit, alu_data_b_i[30:0]};

  // Create the B operand
  assign au_data_b[63:32] = ({32{au_sel_invert_b_hi_i}}    & ~alu_data_b_rrx[63:32]) |
                            ({32{au_sel_normal_b_hi_i}}    &  alu_data_b_rrx[63:32]);

  assign au_data_b[31:16] = ({16{au_sel_invert_b_lo_i}}    & ~alu_data_b_rrx[31:16]) |
                            ({16{au_simd_instr_addsubx_i}} &  alu_data_b_i[15:0])    |
                            ({16{au_simd_instr_subaddx_i}} & ~alu_data_b_i[15:0])    |
                            ({16{au_sel_normal_b_lo_i}}    &  alu_data_b_rrx[31:16]);

  assign au_data_b[15:0]  = ({16{au_sel_invert_b_lo_i}}    & ~alu_data_b_rrx[15:0])  |
                            ({16{au_simd_instr_addsubx_i}} & ~alu_data_b_i[31:16])   |
                            ({16{au_simd_instr_subaddx_i}} &  alu_data_b_i[31:16])   |
                            ({16{au_sel_normal_b_lo_i}}    &  alu_data_b_rrx[15:0]);

  // Create the A operand
  assign au_data_a[63:32] = ({32{au_sel_invert_a_hi_i}} & ~alu_data_a_i[63:32]) |
                            ({32{au_sel_normal_a_hi_i}} &  alu_data_a_i[63:32]);

  assign au_data_a[31:0]  = ({32{au_sel_invert_a_lo_i}} & ~alu_data_a_i[31:0]) |
                            ({32{au_sel_normal_a_lo_i}} &  alu_data_a_i[31:0]);

  assign a_signbits = {au_data_a[31], au_data_a[23], au_data_a[15], au_data_a[7]};
  assign b_signbits = {au_data_b[31], au_data_b[23], au_data_b[15], au_data_b[7]};

  // ------------------------------------------------------
  // SIMD operand extension bit generation
  // ------------------------------------------------------
  //
  // To assist in the halving and saturating operations, SIMD operands
  // are extended by one bit (4 8-bit operands become 4 9-bit operands, etc)
  // The extension is sign- or zero- extension as appropriate
  // (since these bits are merged in to the operands after the inversion has
  //  taken place, the zero-extension must take sub_operation into account)
  // For unused extra bits (e.g. bits 2 and 0 for a 16-bit operation), the
  // carry propagate bits are copied

  assign simd_operand_extend_a[0] = au_valid_8_bit_simd_i ? (au_simd_sign_arth_i ? a_signbits[0] :  au_sub_operation_i                           ) : au_simd_forced_carryin_a_i[0];
  assign simd_operand_extend_a[1] = au_valid_simd_i       ? (au_simd_sign_arth_i ? a_signbits[1] : (au_sub_operation_i | au_simd_instr_addsubx_i)) : au_simd_forced_carryin_a_i[1];
  assign simd_operand_extend_a[2] = au_valid_8_bit_simd_i ? (au_simd_sign_arth_i ? a_signbits[2] :  au_sub_operation_i                           ) : au_simd_forced_carryin_a_i[2];
  assign simd_operand_extend_a[3] = ctl_64bit_op_i        ? au_data_a[32] :
                                    au_simd_sign_arth_i   ? a_signbits[3] :
                                                            (au_valid_simd_i & (au_sub_operation_i | au_simd_instr_subaddx_i));

  assign simd_operand_extend_b[0] = au_valid_8_bit_simd_i ? (au_simd_sign_arth_i & b_signbits[0]) : au_simd_forced_carryin_b_i[0];
  assign simd_operand_extend_b[1] = au_valid_simd_i       ? (au_simd_sign_arth_i & b_signbits[1]) : au_simd_forced_carryin_b_i[1];
  assign simd_operand_extend_b[2] = au_valid_8_bit_simd_i ? (au_simd_sign_arth_i & b_signbits[2]) : au_simd_forced_carryin_b_i[2];
  assign simd_operand_extend_b[3] = ctl_64bit_op_i        ? au_data_b[32]
                                                          : (au_simd_sign_arth_i & b_signbits[3]);

  // ------------------------------------------------------
  // SIMD Operand generation
  // ------------------------------------------------------
  //
  // Interleave the control bits to create the operands we
  // will pass into the 70-bit adder.

  assign a_operand_adder[69:0] = {au_data_a[63:33],
                                  simd_operand_extend_a[3],
                                  au_data_a[31:24],
                                  au_simd_forced_carryin_a_i[2],
                                  simd_operand_extend_a[2],
                                  au_data_a[23:16],
                                  au_simd_forced_carryin_a_i[1],
                                  simd_operand_extend_a[1],
                                  au_data_a[15:8],
                                  au_simd_forced_carryin_a_i[0],
                                  simd_operand_extend_a[0],
                                  au_data_a[7:0]};

  assign b_operand_adder[69:0] = {au_data_b[63:33],
                                  simd_operand_extend_b[3],
                                  au_data_b[31:24],
                                  au_simd_forced_carryin_b_i[2],
                                  simd_operand_extend_b[2],
                                  au_data_b[23:16],
                                  au_simd_forced_carryin_b_i[1],
                                  simd_operand_extend_b[1],
                                  au_data_b[15:8],
                                  au_simd_forced_carryin_b_i[0],
                                  simd_operand_extend_b[0],
                                  au_data_b[7:0]};

  // ------------------------------------------------------
  // Carry Input to Adder
  // ------------------------------------------------------
  //
  // Create adder carry in

  assign alu_au_carryin = (au_add_sub_cin_ctl_i |        // Cin for add/sub-x instructions
                           (au_cin_ctl_i & cflag_wr_i)); // Cin for ADC/SBC/RSC if cc flag is set

  // ------------------------------------------------------
  // Main adder
  // ------------------------------------------------------

  assign au_result_full = a_operand_adder + b_operand_adder + alu_au_carryin;

  // Create result bus
  assign au_result          = {au_result_full[69:30],
                               au_result_full[27:20],
                               au_result_full[17:10],
                               au_result_full[ 7: 0]};

  // Extract extended bits
  assign au_extend_result   = {au_result_full[38],
                               au_result_full[28],
                               au_result_full[18],
                               au_result_full[ 8]};

  // Extract sign bits
  assign au_signbits_result = {au_result_full[37],
                               au_result_full[27],
                               au_result_full[17],
                               au_result_full[ 7]};

  // ------------------------------------------------------
  // Create results for 8-bit SIMD halving operations
  // ------------------------------------------------------

  assign au_sum_simd_halving_8  = {au_result_full[38:31],
                                   au_result_full[28:21],
                                   au_result_full[18:11],
                                   au_result_full[ 8: 1]};

  // ------------------------------------------------------
  // Create results for 16-bit SIMD halving operations
  // ------------------------------------------------------

  assign au_sum_simd_halving_16 = {au_result_full[38:30],
                                   au_result_full[27:21],
                                   au_result_full[18:10],
                                   au_result_full[ 7: 1]};

  // ------------------------------------------------------
  // SIMD saturation information
  // ------------------------------------------------------
  //
  // In this stage, we generate the information required for possible
  // saturation. This is then pipelined to the Wr stage, where the dedicated
  // saturation unit carries out the actual saturation operation.
  //
  // For signed operations, saturation occurs if the top bit of the result
  // element differs from the extended bit
  //
  // For unsigned operations, saturation occurs if the extended bit is set
  // (overflow for addition, underflow for subtraction)

  assign sub_op_simd = {au_sub_operation_i | au_simd_instr_subaddx_i, au_sub_operation_i,
                        au_sub_operation_i | au_simd_instr_addsubx_i, au_sub_operation_i};

  assign au_simd_sat_overflow_o  = au_simd_sign_arth_i ? (au_extend_result ^ au_signbits_result)
                                                       : au_extend_result;

  assign au_simd_sat_direction_o = au_simd_sign_arth_i ? au_extend_result
                                                       : sub_op_simd;

  // ------------------------------------------------------
  // GE flag generation
  // ------------------------------------------------------
  //
  // For unsigned addition, the appropriate GE bit is set if the operation overflows
  //
  // For signed addition or for subtraction, set the GE bit if the result is positive before truncation

  // 8-bit GE Flag Generation
  assign new_geflags_simd_8 = au_extend_result ^ ({4{au_simd_sign_arth_i}} | sub_op_simd);

  // 16-bit GE Flag Generation
  assign new_geflags_simd_16 = { {2{new_geflags_simd_8[3]}}, {2{new_geflags_simd_8[1]}} };

  assign au_new_geflags_o = au_simd_size_i ? new_geflags_simd_16
                                           : new_geflags_simd_8;

  // ------------------------------------------------------
  // Create mux select for different add results
  // ------------------------------------------------------

  assign sel_no_simd          = ~au_halving_i;
  assign sel_simd_halving_8   =  au_halving_i & ~au_simd_size_i;
  assign sel_simd_halving_16  =  au_halving_i &  au_simd_size_i;

  // ------------------------------------------------------
  // Create AU result output
  // ------------------------------------------------------

  assign au_sum_o = ({64{sel_no_simd}}         & au_result[63:0])                         |
                    ({64{sel_simd_halving_8}}  & {32'h0000_0000, au_sum_simd_halving_8})  |
                    ({64{sel_simd_halving_16}} & {32'h0000_0000, au_sum_simd_halving_16});

  // ------------------------------------------------------
  // Assign internals to outputs
  // ------------------------------------------------------

  assign au_nout_o    = ctl_64bit_op_i ? au_result[63] : au_result[31];
  assign au_carryin_o = alu_au_carryin;

endmodule
