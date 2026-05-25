//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : Create IQ Format
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_iq_format_i1 (
  // Inputs
  input wire [39:0] instr_i,
  input wire        instr_valid_if3_i,
  input wire        instr_is_a32_i,
  input wire        instr_is_a64_i,
  input wire        instr_is_t16_i,
  input wire        instr_is_thumb_i,
  input wire        instr_is_dp_i,
  input wire        instr_is_ls_i,
  input wire        instr_is_fn_i,
  input wire [39:0] instr_t16t32_i,
  input wire        instr_dual_slot0_i,
  input wire        instr_dual_slot1_i,
  input wire        taken_i,
  input wire        instr_brn_t_cond_i,
  input wire        instr_brn_t3_i,
  input wire        cpsr_itd_i,
  input wire [2:0]  it_undef_i,
  input wire [3:0]  it_cc_i,
  input wire        it_block_i,
  // Outputs
  output reg [47:0] iq_instr_if3_o);

  localparam [5:0] SB_B_IMM       = 6'b100000;
  localparam [5:0] SB_BX          = 6'b100100;
  localparam [5:0] SB_BLX_BTAC    = 6'b100101;
  localparam [5:0] SB_CBZ_DIR     = 6'b101010;
  localparam [5:0] SB_CBZ         = 6'b101011;

  // -----------------------------
  // Signal declarations
  // -----------------------------

  wire         undef;
  reg  [3:0]   iq_cond_code;
  reg  [28:0]  iq_main_field;
  wire [5:0]   iq_sband;
  wire         iq_class_fn;
  wire         iq_class_other;
  wire         iq_class_ls;
  wire         iq_class_dp;
  wire         iq_taken;
  wire [1:0]   iq_pdtype;
  wire         iq_dual_slot1;
  wire         iq_dual_slot0;
  wire         it_itd_undef;
  wire         iq_class_branch;
  wire         iq_class_branch_t16;

  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------

  // ------------------------------------------------------
  // General control signals
  // ------------------------------------------------------

  // Is the instruction undefined?  The cases are:
  //   (A) T16 instruction with an undefined encoding
  //   (B) T16 IT instruction specifying IT block size > 1 when this feature is
  //       deprecated
  //   (C) T16 instruction in IT block that's now allowed under deprecated IT
  //       behaviour
  //   (D) Non-T16 instruction with undefined encoding
  assign undef = instr_valid_if3_i &
                 ((instr_is_t16_i ? (instr_i[18:16] == 3'b111) : (instr_i[18:13] == `ca53ifu_pd_undef)) |
                  it_itd_undef |
                  (it_undef_i[0] ? it_undef_i[1] : it_undef_i[2]));


  // Determine whether an IT instruction itself or an instruction
  // within an IT block has become UNDEF due to deprecated
  // behaviour
  assign it_itd_undef       = instr_is_t16_i & (instr_i[18:16] == 3'b100) & (instr_i[3:0] != 4'b1000) & cpsr_itd_i;
  // NOTE: Instr1 cannot include an it_itd_undef_instr because during ITD only one IT instruction is allowed in an IT block.
  //       If IT is in Instr1 the only instruction in the IT block is in instr0, if IT is in Instr0 instr1 is not possible
  //       pushing the instr in the IT block in instr0

  // ------------------------------------------------------
  // DPU instruction opcode generation
  // ------------------------------------------------------

  // Use branch class (i.e. set all other class type bits to 0):
  assign iq_class_branch     = (instr_i[18:13]        == SB_B_IMM)     |
                               (instr_i[18:13]        == SB_BX)        |
                               (instr_i[18:13]        == SB_BLX_BTAC)  |
                               (instr_i[18:13]        == SB_CBZ_DIR)   |
                               (instr_i[18:13]        == SB_CBZ);

  assign iq_class_branch_t16 = (instr_t16t32_i[38:33] == SB_B_IMM)     |
                               (instr_t16t32_i[38:33] == SB_BX)        |
                               (instr_t16t32_i[38:33] == SB_BLX_BTAC)  |
                               (instr_t16t32_i[38:33] == SB_CBZ_DIR);

  assign iq_class_fn    = ~undef & instr_is_fn_i;
  assign iq_class_other =  undef | (~instr_is_dp_i & ~instr_is_ls_i & ~instr_is_fn_i & ~(instr_is_t16_i ? iq_class_branch_t16 : iq_class_branch));
  assign iq_class_ls    = ~undef & instr_is_ls_i;
  assign iq_class_dp    = ~undef & instr_is_dp_i;

  assign iq_taken       = ~undef & taken_i;

  assign iq_pdtype[1]   = instr_is_thumb_i;
  assign iq_pdtype[0]   = ((instr_is_a32_i | instr_is_a64_i) & instr_i[19]) | instr_is_t16_i;

  assign iq_dual_slot0  = ~undef & instr_dual_slot0_i;
  assign iq_dual_slot1  = ~undef & (instr_is_t16_i ? instr_t16t32_i[39] : instr_dual_slot1_i);

  always @*
    case ({(instr_is_a32_i | instr_is_a64_i), (it_block_i & ~instr_brn_t_cond_i), (instr_is_t16_i & ~undef), instr_brn_t3_i})
      `ca53ifu_sel_1xxx : iq_cond_code = instr_i[39:36];        // A32: NZCV, A64: sf/m/n/d
      `ca53ifu_sel_01xx : iq_cond_code = it_cc_i[3:0];
      `ca53ifu_sel_001x : iq_cond_code = instr_t16t32_i[32:29];
      `ca53ifu_sel_0001 : iq_cond_code = instr_i[9:6];
      `ca53ifu_sel_0000 : iq_cond_code = 4'b1110;
      default           : iq_cond_code = 4'bxxxx;
    endcase

  always @*
    case ({(instr_is_t16_i & ~undef),instr_is_t16_i})
      2'b11, 2'b10 : iq_main_field = instr_t16t32_i[28:0];             // Thumb-16 instruction
      2'b01        : iq_main_field = {{13{1'b0}}, instr_i[15:0] };     // Thumb-16 undef
      2'b00        : iq_main_field = {instr_i[12:0],instr_i[35:20] };  // Thumb-32/ARM  instruction
      default      : iq_main_field = {29{1'bx}};
    endcase

  assign iq_sband = undef           ? `ca53ifu_pd_undef  :
                    instr_is_t16_i  ? instr_t16t32_i[38:33] : // T16-T32 sideband
                                      instr_i[18:13];         // From instruction

  always @*
    begin
      iq_instr_if3_o[47:42] = iq_sband;
      iq_instr_if3_o[41]    = iq_class_fn;
      iq_instr_if3_o[40]    = iq_class_other;
      iq_instr_if3_o[39]    = iq_class_ls;
      iq_instr_if3_o[38]    = iq_class_dp;
      iq_instr_if3_o[37]    = iq_taken;
      iq_instr_if3_o[36]    = iq_pdtype[1];
      iq_instr_if3_o[35]    = iq_pdtype[0];
      iq_instr_if3_o[34]    = iq_dual_slot1;
      iq_instr_if3_o[33]    = iq_dual_slot0;
      iq_instr_if3_o[32:29] = iq_cond_code;
      iq_instr_if3_o[28:0]  = iq_main_field;
    end

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
