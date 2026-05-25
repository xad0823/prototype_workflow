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

module ca53ifu_pf_iq_format_i0 (
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
  input wire        it_undef_i,
  input wire [3:0]  it_cc_i,
  input wire        it_block_i,
  input wire        instr_abt_i,
  input wire        instr_pty_i,
  input wire        instr_hw_bkpt_i,
  input wire        instr_vcr_i,
  input wire        instr_expt_catch_i,
  input wire        instr_rst_catch_i,
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
  wire         iq_dual_slot0;
  wire         iq_dual_slot1;
  wire         bkpvcr;
  wire         spec_it_block_undef;
  wire         it_itd_undef;
  wire         it_itd_undef_instr;
  wire         er_catch;
  wire         iq_class_branch;
  wire         iq_class_branch_t16;

  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------

  // ------------------------------------------------------
  // General control signals
  // ------------------------------------------------------

  // Is the instruction a breakpoint or VCR hit request?
  assign bkpvcr = instr_valid_if3_i & (instr_hw_bkpt_i | instr_vcr_i);

  // Exception catch or reset catch
  assign er_catch = instr_valid_if3_i & (instr_expt_catch_i | instr_rst_catch_i);

  // Is the instruction undefined?  The cases are:
  //   (A) T16 instruction with an undefined encoding
  //   (B) T16 IT instruction specifying IT block size > 1 when this feature is
  //       deprecated
  //   (C) T16 instruction in IT block that's now allowed under deprecated IT
  //       behaviour
  //   (D) Non-T16 instruction with undefined encoding
  //   (E) Instruction not permitted or not permitted except last in IT block
  assign undef = instr_valid_if3_i &
                 ((instr_is_t16_i ? (instr_i[18:16] == 3'b111) : (instr_i[18:13] == `ca53ifu_pd_undef)) |
                  it_itd_undef_instr |
                  it_itd_undef |
                  it_undef_i);


  // ------------------------------------------------------
  // IT decode
  // ------------------------------------------------------

  // Determine whether instructions in an IT block are undefined
  // assuming the ITD bit is set.
  assign spec_it_block_undef = (instr_i[15:14]                              == 2'b11)        | // All 32-bit instructions, B(2), B(1), undef, SVC, LDM/STM
                               ({instr_i[15], instr_i[13:12]}               == 3'b111)       | // Misc 16-bit instructions
                               ({instr_i[15], instr_i[13:11]}               == 4'b1100)      | // ADD Rd, PC, #imm
                               (instr_i[15:11]                              == 5'b01001)     | // LDR Rd, [PC, #imm]
                               ({instr_i[15:12], instr_i[10], instr_i[6:3]} == 9'b010011111) | // ADD(4), CMP(3), MOV, BX PC, BLX PC
                               ({instr_i[15:10], instr_i[7], instr_i[2:0]}  == 10'b0100011111);// ADD(4), CMP(3), MOV

  // Determine whether an IT instruction itself or an instruction
  // within an IT block has become UNDEF due to deprecated
  // behaviour
  assign it_itd_undef       = instr_is_t16_i & (instr_i[18:16] == 3'b100) & (instr_i[3:0] != 4'b1000) & cpsr_itd_i;
  assign it_itd_undef_instr = it_block_i & ((spec_it_block_undef & instr_is_t16_i) | ~instr_is_t16_i) & cpsr_itd_i;


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


  assign iq_class_fn    = ~undef & ~bkpvcr & ~er_catch & ~instr_abt_i & ~instr_pty_i & instr_is_fn_i;
  assign iq_class_other = (undef |  bkpvcr |  er_catch |  instr_abt_i |  instr_pty_i) |
                          (~instr_is_dp_i & ~instr_is_ls_i & ~instr_is_fn_i & ~(instr_is_t16_i ? iq_class_branch_t16 : iq_class_branch));
  assign iq_class_ls    = ~undef & ~bkpvcr & ~er_catch & ~instr_abt_i & ~instr_pty_i & instr_is_ls_i;
  assign iq_class_dp    = ~undef & ~bkpvcr & ~er_catch & ~instr_abt_i & ~instr_pty_i & instr_is_dp_i;

  assign iq_taken       = (~undef & taken_i) | bkpvcr | er_catch | instr_abt_i | instr_pty_i;

  assign iq_pdtype[1]   = instr_is_thumb_i;
  assign iq_pdtype[0]   = (((instr_is_a32_i | instr_is_a64_i) & instr_i[19]) | instr_is_t16_i) & ~instr_abt_i & ~instr_pty_i & ~bkpvcr & ~er_catch;

  // Note instr_dual_slot0_i includes all instruction types but
  // instr_dual_slot1_i does not include T16
  assign iq_dual_slot0  = ~(instr_abt_i | instr_pty_i | bkpvcr | er_catch | undef) & instr_dual_slot0_i;
  assign iq_dual_slot1  = ~(instr_abt_i | instr_pty_i | bkpvcr | er_catch | undef) & (instr_is_t16_i ? instr_t16t32_i[39] : instr_dual_slot1_i);

  always @*
    case ({(instr_abt_i | instr_pty_i | bkpvcr | er_catch), (instr_is_a32_i | instr_is_a64_i), (it_block_i & ~instr_brn_t_cond_i), (instr_is_t16_i & ~undef), instr_brn_t3_i})
      `ca53ifu_sel_1xxxx : iq_cond_code = 4'b1110;
      `ca53ifu_sel_01xxx : iq_cond_code = instr_i[39:36];         // A32: NZCV, A64: sf/m/n/d
      `ca53ifu_sel_001xx : iq_cond_code = it_cc_i[3:0];
      `ca53ifu_sel_0001x : iq_cond_code = instr_t16t32_i[32:29];
      `ca53ifu_sel_00001 : iq_cond_code = instr_i[9:6];
      `ca53ifu_sel_00000 : iq_cond_code = 4'b1110;
      default            : iq_cond_code = 4'bxxxx;
    endcase

  always @*
    case ({er_catch, instr_abt_i, bkpvcr, instr_pty_i, (instr_is_t16_i & ~undef), instr_is_t16_i})
      `ca53ifu_sel_1xxxxx : iq_main_field = {{27{1'b0}}, instr_expt_catch_i, instr_rst_catch_i};  // Exception/reset catch
      `ca53ifu_sel_01xxxx : iq_main_field = {3'b100, {26{1'b0}}};                                 // Prefetch abort
      `ca53ifu_sel_001xxx : iq_main_field = {3'b110, {24{1'b0}}, instr_vcr_i, instr_hw_bkpt_i};   // Vector Catch/Breakpoint
      `ca53ifu_sel_0001xx : iq_main_field = {3'b111, {26{1'b0}}};                                 // Parity error
      `ca53ifu_sel_00001x : iq_main_field = instr_t16t32_i[28:0];                                 // Thumb-16 instruction
      `ca53ifu_sel_000001 : iq_main_field = {{13{1'b0}}, instr_i[15:0] };                         // Thumb-16 undef instruction (cannot use t16t32 because most of the time is drops to default)
      `ca53ifu_sel_000000 : iq_main_field = {instr_i[12:0],instr_i[35:20] };                      // Thumb-32/ARM instruction
      default             : iq_main_field = {29{1'bx}};
    endcase

  assign iq_sband = (undef | bkpvcr | er_catch | instr_abt_i | instr_pty_i)  ? `ca53ifu_pd_undef  :
                    instr_is_t16_i                                           ? instr_t16t32_i[38:33] : // T16-T32 sideband
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
