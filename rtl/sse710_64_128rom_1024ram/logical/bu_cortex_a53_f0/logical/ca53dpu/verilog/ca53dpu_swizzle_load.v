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
// Abstract : Load data swizzling unit
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Performs a rotate-right on load data, to align data from the DCU.  Also
// swizzles data according to endianess, and sign or zero extends data when
// appropriate.

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_swizzle_load `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         clk,
  input  wire         reset_n,
  input  wire         aarch64_state_i,
  input  wire  [63:0] dcu_ld_data_dc3_i,
  input  wire         en_ls_wr_i,
  input  wire   [1:0] ls_elem_size_ex2_i,
  input  wire   [2:0] v_addr_ex2_i,
  input  wire         spec_endianness_ex2_i,
  input  wire   [1:0] ls_elem_size_wr_i,
  input  wire         ls_sign_ext_wr_i,
  // Outputs
  output wire  [63:0] fwd_ld_data_agu_wr_o,
  output wire  [63:0] fwd_ld_data_int_wr_o,
  output wire  [63:0] ld_data0_wr_o,
  output wire  [63:0] ld_data1_wr_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [23:0] aligned_ctl_ptn_ex2;
  reg  [23:0] endian_ctl_ptn_ex2;
  reg         aarch64_state_wr;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [63:0] expanded_ctl_ptn_ex2;
  wire [63:0] ctl_wr;
  wire        byte_zero_extend;
  wire        byte_sign_extend;
  wire        hword_zero_extend;
  wire        hword_sign_extend;
  wire        word_sign_extend;
  wire        no_sign_extend;
  wire [63:0] rot_data;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Pattern generation
  // ------------------------------------------------------

  // Create an encoded control pattern (e.g. byte 0 is 3'b000, byte 1 is 3'b001 and there are
  // 8-bytes so a 24-bit pattern is required).
  // Align the control pattern depending on the bottom 3-bits of the address
  always @*
    case (v_addr_ex2_i[2:0])
      3'b000  : aligned_ctl_ptn_ex2 = 24'o76543210; // 7,6,5,4,3,2,1,0
      3'b001  : aligned_ctl_ptn_ex2 = 24'o07654321; // 0,7,6,5,4,3,2,1
      3'b010  : aligned_ctl_ptn_ex2 = 24'o10765432; // 1,0,7,6,5,4,3,2
      3'b011  : aligned_ctl_ptn_ex2 = 24'o21076543; // 2,1,0,7,6,5,4,3
      3'b100  : aligned_ctl_ptn_ex2 = 24'o32107654; // 3,2,1,0,7,6,5,4
      3'b101  : aligned_ctl_ptn_ex2 = 24'o43210765; // 4,3,2,1,0,7,6,5
      3'b110  : aligned_ctl_ptn_ex2 = 24'o54321076; // 5,4,3,2,1,0,7,6
      3'b111  : aligned_ctl_ptn_ex2 = 24'o65432107; // 6,5,4,3,2,1,0,7
      default : aligned_ctl_ptn_ex2 = {24{1'bx}};
    endcase

  // Swizzle the control pattern depending on the endianess of the request and the element size
  // of the transfer
  always @*
    case (ls_elem_size_ex2_i[1:0] & {2{spec_endianness_ex2_i}})
      `CA53_LDST_SIZE_BYTE  : endian_ctl_ptn_ex2 =  aligned_ctl_ptn_ex2[23: 0];

      `CA53_LDST_SIZE_HWORD : endian_ctl_ptn_ex2 = {aligned_ctl_ptn_ex2[20:18],
                                                  aligned_ctl_ptn_ex2[23:21],
                                                  aligned_ctl_ptn_ex2[14:12],
                                                  aligned_ctl_ptn_ex2[17:15],
                                                  aligned_ctl_ptn_ex2[ 8: 6],
                                                  aligned_ctl_ptn_ex2[11: 9],
                                                  aligned_ctl_ptn_ex2[ 2: 0],
                                                  aligned_ctl_ptn_ex2[ 5: 3]};

      `CA53_LDST_SIZE_WORD  : endian_ctl_ptn_ex2 = {aligned_ctl_ptn_ex2[14:12],
                                                  aligned_ctl_ptn_ex2[17:15],
                                                  aligned_ctl_ptn_ex2[20:18],
                                                  aligned_ctl_ptn_ex2[23:21],
                                                  aligned_ctl_ptn_ex2[ 2: 0],
                                                  aligned_ctl_ptn_ex2[ 5: 3],
                                                  aligned_ctl_ptn_ex2[ 8: 6],
                                                  aligned_ctl_ptn_ex2[11: 9]};

      `CA53_LDST_SIZE_DWORD : endian_ctl_ptn_ex2 = {aligned_ctl_ptn_ex2[ 2: 0],
                                                  aligned_ctl_ptn_ex2[ 5: 3],
                                                  aligned_ctl_ptn_ex2[ 8: 6],
                                                  aligned_ctl_ptn_ex2[11: 9],
                                                  aligned_ctl_ptn_ex2[14:12],
                                                  aligned_ctl_ptn_ex2[17:15],
                                                  aligned_ctl_ptn_ex2[20:18],
                                                  aligned_ctl_ptn_ex2[23:21]};
      default                : endian_ctl_ptn_ex2 = {24{1'bx}};
    endcase

  // Turn the encoded control pattern signals in to one-hot
  assign expanded_ctl_ptn_ex2[63:56] = f_one_hot_byte(endian_ctl_ptn_ex2[23:21]);
  assign expanded_ctl_ptn_ex2[55:48] = f_one_hot_byte(endian_ctl_ptn_ex2[20:18]);
  assign expanded_ctl_ptn_ex2[47:40] = f_one_hot_byte(endian_ctl_ptn_ex2[17:15]);
  assign expanded_ctl_ptn_ex2[39:32] = f_one_hot_byte(endian_ctl_ptn_ex2[14:12]);
  assign expanded_ctl_ptn_ex2[31:24] = f_one_hot_byte(endian_ctl_ptn_ex2[11: 9]);
  assign expanded_ctl_ptn_ex2[23:16] = f_one_hot_byte(endian_ctl_ptn_ex2[ 8: 6]);
  assign expanded_ctl_ptn_ex2[15: 8] = f_one_hot_byte(endian_ctl_ptn_ex2[ 5: 3]);
  assign expanded_ctl_ptn_ex2[ 7: 0] = f_one_hot_byte(endian_ctl_ptn_ex2[ 2: 0]);

  function [7:0] f_one_hot_byte;
    // This function takes three bits as input, and returns a one-hot encoded
    // byte of the same value. eg. 3'o2 => 8'b0000_0100
    input [2:0] binary;
    begin
      f_one_hot_byte[7:0] = 8'b0000_0001 << binary;
    end
  endfunction

  // Register the AArch64 state before use
  always @(posedge clk)
    if (en_ls_wr_i)
      aarch64_state_wr <= aarch64_state_i;

generate if (NEON_FP) begin : FPU1
  reg [63:0]    raw_ctl_wr;

  // If the processor is configured with FPU then element size 64-bits can be generated
  // which requires a more complicated swizzle and therefore more registers

  // Register the swizzle control signals
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      raw_ctl_wr[63:0] <= 64'h80_40_20_10_08_04_02_01;
    else if (en_ls_wr_i)
      raw_ctl_wr[63:0] <= expanded_ctl_ptn_ex2[63:0];

  // Expand the signals back out again
  assign ctl_wr[63:56] = raw_ctl_wr[63:56];
  assign ctl_wr[55:48] = raw_ctl_wr[55:48];
  assign ctl_wr[47:40] = raw_ctl_wr[47:40];
  assign ctl_wr[39:32] = raw_ctl_wr[39:32];
  assign ctl_wr[31:24] = raw_ctl_wr[31:24];
  assign ctl_wr[23:16] = raw_ctl_wr[23:16];
  assign ctl_wr[15: 8] = raw_ctl_wr[15: 8];
  assign ctl_wr[ 7: 0] = raw_ctl_wr[ 7: 0];

end else begin : FPU1_STUBS
  reg [31:0]    raw_ctl_wr;

  // Register the swizzle control signals
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      raw_ctl_wr[31:0] <= 32'h08_04_02_01;
    else if (en_ls_wr_i)
      raw_ctl_wr[31:0] <= expanded_ctl_ptn_ex2[31:0];

  // Expand the signals back out again
  assign ctl_wr[63:56] = {raw_ctl_wr[27:24], raw_ctl_wr[31:28]};
  assign ctl_wr[55:48] = {raw_ctl_wr[19:16], raw_ctl_wr[23:20]};
  assign ctl_wr[47:40] = {raw_ctl_wr[11: 8], raw_ctl_wr[15:12]};
  assign ctl_wr[39:32] = {raw_ctl_wr[ 3: 0], raw_ctl_wr[ 7: 4]};
  assign ctl_wr[31:24] =  raw_ctl_wr[31:24];
  assign ctl_wr[23:16] =  raw_ctl_wr[23:16];
  assign ctl_wr[15: 8] =  raw_ctl_wr[15: 8];
  assign ctl_wr[ 7: 0] =  raw_ctl_wr[ 7: 0];
end endgenerate

  // ------------------------------------------------------
  // Rotate word-aligned load data for the AGU
  // ------------------------------------------------------

  // Given how timing critical the AGU forwarding path is we can only forward word aligned
  // load-data that is either Big-Endian or Little-Endian.  This cuts out a mux from the path,
  // but retains the majority of the flexibility.  This forwarding path is typically used to
  // optimise the following code:
  //
  //    LDR r1, [r0]
  //         \
  //          \
  //           \
  //            \
  //             \
  //    LDR r2, [r1]
  //
  // This often appears in linked lists in C/C++. The address here does not
  // need sign extending or zeroing of redundant bytes, so it is output early
  // before the sign extend works. The under 32 bits are set to zeros for AArch32
  // because it is expected that anything picking up data from it will only be
  // using it as an ARM address.
  assign fwd_ld_data_agu_wr_o[63:0] = {// bits [63:56]
                                       ((({8{ctl_wr[56]}} & dcu_ld_data_dc3_i[ 7: 0])  |  // 64bit Big-Endian
                                         ({8{ctl_wr[63]}} & dcu_ld_data_dc3_i[63:56])) &  // 64bit Little-Endian
                                         ({8{aarch64_state_wr}})),
                                       // bits [55:48]
                                       ((({8{ctl_wr[49]}} & dcu_ld_data_dc3_i[15: 8])  |  // 64bit Big-Endian
                                         ({8{ctl_wr[54]}} & dcu_ld_data_dc3_i[55:48])) &  // 64bit Little-Endian
                                         ({8{aarch64_state_wr}})),
                                       // bits [47:40]
                                       ((({8{ctl_wr[42]}} & dcu_ld_data_dc3_i[23:16])  |  // 64bit Big-Endian
                                         ({8{ctl_wr[45]}} & dcu_ld_data_dc3_i[47:40])) &  // 64bit Little-Endian
                                         ({8{aarch64_state_wr}})),
                                       // bits [39:32]
                                       ((({8{ctl_wr[35]}} & dcu_ld_data_dc3_i[31:24])  |  // 64bit Big-Endian
                                         ({8{ctl_wr[36]}} & dcu_ld_data_dc3_i[39:32])) &  // 64bit Little-Endian
                                         ({8{aarch64_state_wr}})),
                                       // bits [31:24]
                                       (({8{ctl_wr[28]}} & dcu_ld_data_dc3_i[39:32])   |  // Upper-Word & 64bit, Big-Endian
                                        ({8{ctl_wr[31]}} & dcu_ld_data_dc3_i[63:56])   |  // Upper-Word, Little-Endian
                                        ({8{ctl_wr[24]}} & dcu_ld_data_dc3_i[ 7: 0])   |  // Lower-Word, Big-Endian
                                        ({8{ctl_wr[27]}} & dcu_ld_data_dc3_i[31:24])),    // Lower-Word & 64bit, Little-Endian
                                       // bits [23:16]
                                       (({8{ctl_wr[21]}} & dcu_ld_data_dc3_i[47:40])   |  // Upper-Word & 64bit, Big-Endian
                                        ({8{ctl_wr[22]}} & dcu_ld_data_dc3_i[55:48])   |  // Upper-Word, Little-Endian
                                        ({8{ctl_wr[17]}} & dcu_ld_data_dc3_i[15: 8])   |  // Lower-Word, Big-Endian
                                        ({8{ctl_wr[18]}} & dcu_ld_data_dc3_i[23:16])),    // Lower-Word & 64bit, Little-Endian
                                       // bits [15: 8]
                                       (({8{ctl_wr[14]}} & dcu_ld_data_dc3_i[55:48])   |  // Upper-Word & 64bit, Big-Endian
                                        ({8{ctl_wr[13]}} & dcu_ld_data_dc3_i[47:40])   |  // Upper-Word, Little-Endian
                                        ({8{ctl_wr[10]}} & dcu_ld_data_dc3_i[23:16])   |  // Lower-Word, Big-Endian
                                        ({8{ctl_wr[ 9]}} & dcu_ld_data_dc3_i[15: 8])),    // Lower-Word & 64bit, Little-Endian
                                       // bits [ 7: 0]
                                       (({8{ctl_wr[ 7]}} & dcu_ld_data_dc3_i[63:56])   |  // Upper-Word & 64bit, Big-Endian
                                        ({8{ctl_wr[ 4]}} & dcu_ld_data_dc3_i[39:32])   |  // Upper-Word, Little-Endian
                                        ({8{ctl_wr[ 3]}} & dcu_ld_data_dc3_i[31:24])   |  // Lower-Word, Big-Endian
                                        ({8{ctl_wr[ 0]}} & dcu_ld_data_dc3_i[ 7: 0]))};   // Lower-Word & 64bit, Little-Endian

  // ------------------------------------------------------
  // Rotate all combinations of load data
  // ------------------------------------------------------

  // Rotate all possible combinations of data.  This is still critical in to the branch
  // logic so we can't cascade the rotated data from the previous stage.

  // A multiplexor function to select one byte from eight
  function [7:0] f_mux_oh;
    input [63:0] data_in;
    input [7:0] control;
    begin
      case (control[7:0])
        8'b0000_0001 : f_mux_oh[7:0] = data_in[ 7: 0];
        8'b0000_0010 : f_mux_oh[7:0] = data_in[15: 8];
        8'b0000_0100 : f_mux_oh[7:0] = data_in[23:16];
        8'b0000_1000 : f_mux_oh[7:0] = data_in[31:24];
        8'b0001_0000 : f_mux_oh[7:0] = data_in[39:32];
        8'b0010_0000 : f_mux_oh[7:0] = data_in[47:40];
        8'b0100_0000 : f_mux_oh[7:0] = data_in[55:48];
        8'b1000_0000 : f_mux_oh[7:0] = data_in[63:56];
        default      : f_mux_oh[7:0] = 8'hxx;
      endcase
    end
  endfunction

  // Rotate the incoming load data in the above function using
  // the control signals generated in the previous cycle
  assign rot_data[63:56] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[63:56]);
  assign rot_data[55:48] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[55:48]);
  assign rot_data[47:40] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[47:40]);
  assign rot_data[39:32] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[39:32]);
  assign rot_data[31:24] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[31:24]);
  assign rot_data[23:16] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[23:16]);
  assign rot_data[15: 8] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[15: 8]);
  assign rot_data[ 7: 0] = f_mux_oh (dcu_ld_data_dc3_i[63:0], ctl_wr[ 7: 0]);

  // Forward the rotated, but not sign extended load data
  assign fwd_ld_data_int_wr_o[63:0] = rot_data[63:0];

  // ------------------------------------------------------
  // Sign extend the rotated load data
  // ------------------------------------------------------

  // size = 000 (BYTE), no sign extend
  assign byte_zero_extend  = {ls_elem_size_wr_i, ls_sign_ext_wr_i} == {`CA53_LDST_SIZE_BYTE, 1'b0};

  // size = 000 (BYTE), sign extend
  assign byte_sign_extend  = {ls_elem_size_wr_i, ls_sign_ext_wr_i} == {`CA53_LDST_SIZE_BYTE, 1'b1};

  // size = 001 (HALF-WORD), no sign extend
  assign hword_zero_extend = {ls_elem_size_wr_i, ls_sign_ext_wr_i} == {`CA53_LDST_SIZE_HWORD, 1'b0};

  // size = 001 (HALF-WORD), sign extend
  assign hword_sign_extend = {ls_elem_size_wr_i, ls_sign_ext_wr_i} == {`CA53_LDST_SIZE_HWORD, 1'b1};

  // size = 010 (WORD), sign extend
  assign word_sign_extend  = {ls_elem_size_wr_i, ls_sign_ext_wr_i} == {`CA53_LDST_SIZE_WORD, 1'b1};

  // Nothing for word, two-word or double-word loads, as
  // there is no such thing as sign extending those
  assign no_sign_extend = (~byte_zero_extend  &
                           ~byte_sign_extend  &
                           ~hword_zero_extend &
                           ~hword_sign_extend &
                           ~word_sign_extend);

  // Never need to zero or sign-ext the first byte of the bottom word
  assign ld_data0_wr_o[ 7: 0] = rot_data[7:0];

  // Sign, zero extend or do nothing to the second byte of the bottom word
  assign ld_data0_wr_o[15: 8] = ({8{byte_sign_extend}}   & {8{rot_data[7]}}) |
                                ({8{(hword_zero_extend |
                                     hword_sign_extend |
                                     word_sign_extend  |
                                     no_sign_extend)}}   & rot_data[15:8]);

  // Sign, zero extend or do nothing to the third and fourth bytes of the bottom word
  assign ld_data0_wr_o[31:16] = ({16{byte_sign_extend}}  & {16{rot_data[7]}})  |
                                ({16{hword_sign_extend}} & {16{rot_data[15]}}) |
                                ({16{(word_sign_extend |
                                      no_sign_extend)}}  & rot_data[31:16]);

  // Sign, zero extend or do nothing to the upper word
  assign ld_data0_wr_o[63:32] = ({32{byte_sign_extend}}  & {32{rot_data[7]}})  |
                                ({32{hword_sign_extend}} & {32{rot_data[15]}}) |
                                ({32{word_sign_extend}}  & {32{rot_data[31]}}) |
                                ({32{no_sign_extend}}    & rot_data[63:32]);

  // Always sign extend as a word, as the only sign-extending pair
  // instruction is A64 LDPSW
  assign ld_data1_wr_o[63:0] = { {32{rot_data[63]}}, rot_data[63:32]};

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_ls_wr_i")
  u_ovl_x_en_ls_wr_i (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (en_ls_wr_i));


  //----------------------------------------------------------------------------
  // OVL_ASSERT: Each byte of the ctl_wr bus must be one-hot (not zero)
  //             This required eight different assertions
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh0 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[7:0]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh1 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[15:8]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh2 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[23:16]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh3 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[31:24]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh4 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[39:32]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh5 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[47:40]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh6 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[55:48]));

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of ctl_wr must be one-hot")
    ovl_ctl_wr_oh7 (.clk       (clk),
                    .reset_n   (reset_n),
                    .test_expr (ctl_wr[63:56]));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: The OR of all eight bytes of destn_ctl must be 8'b1111_1111
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Each byte in destn_ctl should have a unique bit set")
    ovl_ctl_wr_uniq (.clk       (clk),
                    .reset_n    (reset_n),
                    .test_expr  ((ctl_wr[63:56] | ctl_wr[55:48] | ctl_wr[47:40] | ctl_wr[39:32] |
                                  ctl_wr[31:24] | ctl_wr[23:16] | ctl_wr[15: 8] | ctl_wr[ 7: 0]) == 8'b1111_1111));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: Each byte of the expanded_ctl_ptn_ex2 bus must be one-hot (not zero)
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL

  // Out Of reset the signals are X but they will not cause any issue, extend reset
  // period up to first qualifier
  reg ovl_expanded_ctl_hold_reset_n;
  wire ovl_expanded_ctl_valid_reset_n;
  // extend reset to first valid
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ovl_expanded_ctl_hold_reset_n <= 1'b0;
    else if (en_ls_wr_i)
      ovl_expanded_ctl_hold_reset_n <= 1'b1;
  // ensure first valid cycle is captured as well
  assign ovl_expanded_ctl_valid_reset_n = ovl_expanded_ctl_hold_reset_n | en_ls_wr_i;

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of expanded_ctl_ptn_ex2 must be one-hot")
    ovl_expanded_ctl_ptn_ex2_oh0 (.clk       (clk),
                                  .reset_n   (ovl_expanded_ctl_valid_reset_n),
`ifdef OVL_SVA
                                  .test_expr (ovl_expanded_ctl_valid_reset_n ? expanded_ctl_ptn_ex2[7:0] : {{7{1'b0}},1'b1}));
`else
                                  .test_expr (expanded_ctl_ptn_ex2[7:0]));
`endif

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of expanded_ctl_ptn_ex2 must be one-hot")
    ovl_expanded_ctl_ptn_ex2_oh1 (.clk       (clk),
                                  .reset_n   (ovl_expanded_ctl_valid_reset_n),
`ifdef OVL_SVA
                                  .test_expr (ovl_expanded_ctl_valid_reset_n ? expanded_ctl_ptn_ex2[15:8] : {{7{1'b0}},1'b1}));
`else
                                  .test_expr (expanded_ctl_ptn_ex2[15:8]));
`endif

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of expanded_ctl_ptn_ex2 must be one-hot")
    ovl_expanded_ctl_ptn_ex2_oh2 (.clk       (clk),
                                  .reset_n   (ovl_expanded_ctl_valid_reset_n),
`ifdef OVL_SVA
                                  .test_expr (ovl_expanded_ctl_valid_reset_n ? expanded_ctl_ptn_ex2[23:16] : {{7{1'b0}},1'b1}));
`else
                                  .test_expr (expanded_ctl_ptn_ex2[23:16]));
`endif

  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Each byte of expanded_ctl_ptn_ex2 must be one-hot")
    ovl_expanded_ctl_ptn_ex2_oh3 (.clk       (clk),
                                  .reset_n   (ovl_expanded_ctl_valid_reset_n),
`ifdef OVL_SVA
                                  .test_expr (ovl_expanded_ctl_valid_reset_n ? expanded_ctl_ptn_ex2[31:24] : {{7{1'b0}},1'b1}));
`else
                                  .test_expr (expanded_ctl_ptn_ex2[31:24]));
`endif
  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_swizzle_load

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
