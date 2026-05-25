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
// Abstract : PC incrementer in de-stage
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The program counter that is passed down the pipeline relates to the
// instruction decoded in decoder0 only.  If a single instruction is issued,
// the PC is the architectural PC that that instruction would read.  If two
// instructions are issued, the PC is the architectural PC for the first of
// the two instructions.  Hence in the pipeline, the PC is called
// pc_instr0_<stage>
//
// According to the ARM architecture, the PC for an instruction is the
// address of that instruction plus 8 in ARM-state, or 4 in Thumb-state.
// This is refered to as the architectural offset.
//
// The program counter is re-created in the de-stage, ready to be pipelined
// into the iss-stage.  The PC is changed in a number of ways:
//
//  - on reset, or another exception or mispredicted indirect branch, the PC
//  value is set to the exception vector address, plus the architectural
//  offset
//
//  - on issuing instructions, the PC is incremented according to the number
//  of instructions issued and the size of those instructions
//
//  - on decoding and issuing a predicted-taken direct branch, the offset for
//  the branch is added to the PC for that instruction, to generate the
//  address of the branch destination, to which is added the architectural
//  offset
//
//  - on decoding a function return instruction, the PC is replaced with the
//  return address that has been popped off the CRS and passed by the IFU,
//  and the architectural offset is added to this address
//
//  - when a mispredicted branch reaches the wr-stage, the PC is
//  calculated from the wr-stage A and B force operands, and an
//  architectural adjustment
//
// In this module, a single adder is implemented, which takes a base PC, an
// increment (which is a signed quantity) and an adjustment (which is an
// unsigned quantity).  PC, increment and adjustment are computed for each
// type of event, and then multiplexed according to the event that is
// occuring, thus:
//                          __
//                         |  |
//  instructions_issued ---|  |----- reg_instructions_issued
//  size_of_instruction    |/\|  |   reg_size_of_instruction
//            . . . . . . . . . .|. . . . . . . . .
//                               |                 .
//                      Calculate increment        .
//                      for PC based on size       .
//                      of instructiuons           .
//                        in iss-stage             .
//                               |                 .
//                               |                 .
//                               `-|\              .
//   Branch offset from iss-stage -| \ pc_incr     . This register is
//   dpu_fe_addr_opb_ret __________|  |_____       .
//   Return address from iss-stage-|  |     |      . actually in the iss-
//   dpu_fe_addr_opb_wr  ----------| /      |      . stage module
//                                 |/|      |      .
//                                   |      |      .   __
//   Adjust branch target to PC ---|\|     _|_     .  |  |
//    based on ISA & br position   | \    | + |-------|  |-- pc_instr0_iss
//   Adjust fetch address to PC ---|  |---|___|    .  |/\|
//    based on ISA                 | / pc_  |      .
//   Increment PC according to ----|/|adjust|      .
//    No. instructions issued        |      |      .
//                                   |      |      .
//                                 |\|      |      .
//   dpu_fe_addr_opa_wr -----------| \      |      .
//   dpu_fe_addr_opa_ret __________|  |_____|      .
//                                 |  | source_pc  .
//   pc_instr0_iss ----------------| /             .
//   Return address prediction ----|/|             .
//                                   |             .
//     Control selection muxes based on which events are occuring, in a priority
//     order.  1: indirect branch in ret-stage.  2: direct branch in wr-stage
//     3a: direct branch in iss-stage.  3b: return instruction in iss-stage
//     4: normal (non-branch) instructions in iss-stage

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_de_pc `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire         clk,
  input  wire         reset_n,
  input  wire   [1:0] valid_instrs_iss_i,
  input  wire         end_instr_iss_i,
  input  wire         size_instr0_iss_i,
  input  wire         size_instr1_iss_i,
  input  wire         size_instr1_ret_i,
  input  wire         aarch64_state_i,
  input  wire   [1:0] dpu_exception_level_i,
  input  wire         slot1_branch_iss_i,
  input  wire   [1:0] isa_instr0_iss_i,
  input  wire         instr0_de_pc_in_iss_i,
  input  wire         prefetch_abort_iss_i,
  input  wire  [48:1] rtn_addr_iss_i,
  input  wire  [27:1] br_offset_iss_i,
  input  wire         taken_br_instr_iss_i,
  input  wire         br_x_bit_iss_i,
  input  wire         btac_rtn_instr_iss_i,
  input  wire         tbit_btac_rtn_instr_iss_i,
  input  wire         in_halt_i,
  input  wire  [63:0] pc_instr0_iss_i,
  input  wire  [48:1] pc_instr0_wr_i,
  input  wire  [63:0] pc_instr0_ret_i,
  input  wire         thumb_instr0_iss_i,
  input  wire         thumb_instr0_ret_i,
  input  wire         thumb_instr1_ret_i,
  input  wire   [1:0] tlb_d_tcr_el1_tbi_i,
  input  wire         tlb_d_tcr_el2_tbi0_i,
  input  wire         tlb_d_tcr_el3_tbi0_i,
  input  wire  [48:1] dpu_fe_addr_opa_wr_i,
  input  wire  [27:1] dpu_fe_addr_opb_wr_i,
  input  wire         dpu_fe_valid_wr_i,
  input  wire         cpsr_tbit_wr_i,
  input  wire  [63:0] dpu_fe_addr_opa_ret_i,
  input  wire  [17:1] dpu_fe_addr_opb_ret_i,
  input  wire         dpu_fe_valid_ret_i,
  input  wire         cpsr_tbit_ret_i,
  input  wire         expt_slot1_ret_i,
  input  wire         insert_forceop_ret_i,
  input  wire         forceop_valid_de_i,
  input  wire         forceop_valid_iss_i,
  input  wire         incr_pc_halt_mode_ret_i,
  input  wire         dbg_halt_ecc_expt_iss_i,
  input  wire         dpu_halt_ifu_i,
  // Outputs
  output wire  [63:0] pc_instr0_de_o,
  output wire         mod_pc_top_bits_de_o,
  output wire         thumb_instr0_de_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [2:1] pc_instr0_adjust;
  reg   [2:1] pc_instr1_adjust;
  reg   [3:1] pc_br_adjust;
  reg  [63:0] source_pc;
  reg  [27:1] pc_incr;
  reg   [3:1] pc_adjust;
  reg         pc_force;
  reg         thumb;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [3:1] pc_instr_adjust;
  wire  [3:1] pc_return_adjust;
  wire  [3:1] pc_mis_adjust;
  wire  [3:1] pc_indirect_adjust;
  wire [63:0] raw_pc_instr0_de;
  wire        mod_pc_top_bits_de;
  wire        zero_top_byte;
  wire        set_top_byte;
  wire  [5:0] sel_pc_incr;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Compute the increment needed based on instruction issue
  // ------------------------------------------------------

  // Compute instruction 0 increment
  always @*
    case ({valid_instrs_iss_i[0], size_instr0_iss_i})
      2'b00,
      2'b01   : pc_instr0_adjust[2:1] = 2'b00; // No issue
      2'b10   : pc_instr0_adjust[2:1] = 2'b01; // Issue 16-bit instruction
      2'b11   : pc_instr0_adjust[2:1] = 2'b10; // Issue 32-bit instruction
      default : pc_instr0_adjust[2:1] = 2'bxx;
    endcase

  // Compute instruction 1 increment
  always @*
    case ({valid_instrs_iss_i[1], size_instr1_iss_i})
      2'b00,
      2'b01   : pc_instr1_adjust[2:1] = 2'b00; // No issue
      2'b10   : pc_instr1_adjust[2:1] = 2'b01; // Issue 16-bit instruction
      2'b11   : pc_instr1_adjust[2:1] = 2'b10; // Issue 32-bit instruction
      default : pc_instr1_adjust[2:1] = 2'bxx;
    endcase

  // Total the increment from both instructions:
  assign pc_instr_adjust = end_instr_iss_i ? pc_instr0_adjust + pc_instr1_adjust
                                           : 3'b000; // Not the end of the instruction - leave the PC alone

  // ------------------------------------------------------
  // Compute values for a direct (pred taken) branch in Iss
  // ------------------------------------------------------

  // Compute the twiddle needed when a direct branch has been predicted
  // taken.  The previous PC and the branch offset will give the correct
  // instruction address when the branch is in instr0, but an adjustment of
  // +2/+4 is needed (based on the size of instr0) when the branch is in
  // instr1.  In addition, the instruction address needs +4/+8 (depending on
  // the architecture of the instructions) to generate the architectural PC
  // - ie. the value that would be read by the instruction if the PC were
  // a data source register.
  // The pc_br_adjust signal assigned here incorporates both these factors

  always @*
    case ({slot1_branch_iss_i, aarch64_state_i, (br_x_bit_iss_i ^ isa_instr0_iss_i[0]), size_instr0_iss_i})
      `ca53dpu_sel_010x: pc_br_adjust = valid_instrs_iss_i[1] ? 3'b010 : 3'b000; // 0/4 : A64 branch in slot 0 with/without instr in slot 1
      `ca53dpu_sel_000x: pc_br_adjust = valid_instrs_iss_i[1] ? 3'b110 : 3'b100; // 8/12 : A32 branch in slot 0
      `ca53dpu_sel_001x: pc_br_adjust = valid_instrs_iss_i[1] ? (size_instr1_iss_i ? 3'b100 : 3'b011) : 3'b010; // 4 : T32 branch in slot 0
        4'b1101        : pc_br_adjust = 3'b010; // 4 : A64 branch in slot 1
        4'b1000        : pc_br_adjust = pc_instr0_iss_i[1] ? 3'b110 : 3'b100; // 12/8: A32 branch in slot 1, with 16-bit instruction in slot 0 (T32 BLX in Instr1 which went T32->A32)
        4'b1001        : pc_br_adjust = 3'b110; // 12: A32 branch in slot 1
        4'b1010        : pc_br_adjust = 3'b011; // 6 : T32 Branch in slot 1, with 16-bit instruction in slot 0
        4'b1011        : pc_br_adjust = 3'b100; // 8 : T32 branch in slot 1, with 32-bit instruction in slot 0
      default          : pc_br_adjust = 3'bxxx;
    endcase

  // ------------------------------------------------------
  // Compute values for a predicted return instr is in Iss
  // ------------------------------------------------------
  assign pc_return_adjust = aarch64_state_i           ? 3'b000 : // 0 : A64 ISA
                            tbit_btac_rtn_instr_iss_i ? 3'b010 : // 4 : T32 ISA
                                                        3'b100;  // 8 : A32 ISA

  // ------------------------------------------------------
  // Compute values for a mispredicted branch retires in Wr
  // ------------------------------------------------------
  assign pc_mis_adjust = aarch64_state_i ? 3'b000 : // 0 : A64 ISA
                         cpsr_tbit_wr_i  ? 3'b010 : // 4 : T32 ISA
                                           3'b100;  // 8 : A32 ISA

  // ------------------------------------------------------
  // Compute values for an indirect branch retiring in Ret
  // ------------------------------------------------------
  assign pc_indirect_adjust = in_halt_i       ? 3'b000 : // 0 : For DLR write during halt
                              aarch64_state_i ? 3'b000 : // 0 : A64 ISA
                              cpsr_tbit_ret_i ? 3'b010 : // 4 : T32 ISA
                                                3'b100;  // 8 : A32 ISA

  // ------------------------------------------------------
  // Select appropriate PC and increment
  // ------------------------------------------------------

  assign sel_pc_incr = {insert_forceop_ret_i,
                        ((dpu_fe_valid_ret_i | incr_pc_halt_mode_ret_i) & ~forceop_valid_de_i) | (forceop_valid_iss_i & ~dbg_halt_ecc_expt_iss_i),
                        in_halt_i,
                        dpu_fe_valid_wr_i & ~dpu_halt_ifu_i,
                        btac_rtn_instr_iss_i & valid_instrs_iss_i[0],
                        taken_br_instr_iss_i & valid_instrs_iss_i[0] & ~instr0_de_pc_in_iss_i
                       };

  // Priority encoder, since various operations from the end of the
  // pipeline take priority over events occuring at the beginning of the
  // pipeline, and further, branches at the beginning of the pipeline take
  // priority over normal instruction issue
  always @*
    case (sel_pc_incr)
      // Exception in Ret - give this the same PC as the instruction causing
      // the exception, to allow LR calculation
      `ca53dpu_sel_1x_xxxx: begin
        pc_force  = 1'b1;
        pc_adjust = 3'b000;
        case (expt_slot1_ret_i)
          1'b0: begin
            source_pc = pc_instr0_ret_i[63:0];
            pc_incr   = {27{1'b0}};
            thumb     = thumb_instr0_ret_i;
          end
          1'b1: begin
            // Get effective pc_instr1_ret by taking PC of next instruction
            // (pc_instr0_wr) and subtracting size of instr1_ret
            source_pc = { {16{pc_instr0_wr_i[48]}}, pc_instr0_wr_i[47:1], 1'b0};
            pc_incr   = {{26{1'b1}}, (size_instr1_ret_i ? 1'b0 :  // -4
                                                          1'b1)}; // -2
            thumb     = thumb_instr1_ret_i;
          end
          default: begin
            source_pc = {64{1'bx}};
            pc_incr   = {27{1'bx}};
            thumb     = 1'bx;
          end
        endcase
      end

      // Indirect branch in ret-stage (debug or normal)
      // Force operation in the iss-stage
      // Set the new PC to the correct value from the earlier force
      `ca53dpu_sel_01_xxxx: begin
        source_pc = dpu_fe_addr_opa_ret_i[63:0];
        pc_incr   = {{10{dpu_fe_addr_opb_ret_i[17]}}, dpu_fe_addr_opb_ret_i[17:1]};
        pc_adjust = in_halt_i ? 3'b000 : pc_indirect_adjust[3:1];
        pc_force  = 1'b1;
        thumb     = cpsr_tbit_ret_i;
      end

      // Normal instructions in the iss-stage in Halt mode
      // In halt mode, PC incrementation is not done.
      `ca53dpu_sel_00_1xxx: begin
        source_pc = pc_instr0_iss_i[63:0];
        pc_incr   = {27{1'b0}};
        pc_adjust = 3'b000;
        pc_force  = 1'b0;
        thumb     = thumb_instr0_iss_i;
      end

      // Mispredicted branch in wr-stage
      // For WFI, IFU is requested to enter halt mode. This is done by
      // asserting for one cycle, the signals dpu_fe_valid_wr and
      // dpu_halt_ifu. In this case we do not want the PC to be updated.
      `ca53dpu_sel_00_01xx: begin
        source_pc = { {16{dpu_fe_addr_opa_wr_i[48]}}, dpu_fe_addr_opa_wr_i[47:1], 1'b0};
        pc_incr   = dpu_fe_addr_opb_wr_i[27:1];
        pc_adjust = pc_mis_adjust[3:1];
        pc_force  = 1'b1;
        thumb     = cpsr_tbit_wr_i;
      end

      // Return/BTAC instruction in the iss-stage
      `ca53dpu_sel_00_001x: begin
        source_pc = { {16{rtn_addr_iss_i[48]}}, rtn_addr_iss_i[47:1], 1'b0};
        pc_incr   = {27{1'b0}};
        pc_adjust = pc_return_adjust[3:1];
        pc_force  = 1'b1;
        thumb     = tbit_btac_rtn_instr_iss_i & ~aarch64_state_i;
      end

      // Branch in the iss-stage
      6'b00_0001: begin
        source_pc = {pc_instr0_iss_i[63:2], pc_instr0_iss_i[1] & ~br_x_bit_iss_i, 1'b0};
        pc_incr   = br_offset_iss_i[27:1];
        pc_adjust = pc_br_adjust[3:1];
        pc_force  = 1'b1;
        thumb     = thumb_instr0_iss_i ^ br_x_bit_iss_i;
      end

      // Normal instructions in the iss-stage
      6'b00_0000: begin
        source_pc = pc_instr0_iss_i[63:0];
        pc_incr   = {27{1'b0}};
        pc_adjust = (instr0_de_pc_in_iss_i | prefetch_abort_iss_i) ? 3'b000 : pc_instr_adjust[3:1];
        pc_force  = 1'b0;
        thumb     = thumb_instr0_iss_i;
      end

      default: begin
        source_pc = {64{1'bx}};
        pc_incr   = {27{1'bx}};
        pc_adjust = {3{1'bx}};
        pc_force  = 1'bx;
        thumb     = 1'bx;
      end
    endcase

  // Increment the PC to get the next value
  assign raw_pc_instr0_de[63:0] = source_pc[63:0] + {{36{pc_incr[27]}}, pc_incr[27:1], 1'b0} + {pc_adjust[3:1], 1'b0};

  // Detect when the top 24 bits of the PC are changed, for the purpose of
  // enabling the flops for these registers (all the way down the pipe)
  // This always occurs when we are forcing a new PC (for a branch), and then
  // occurs whenever these bits have changed.  Change is detected by
  // predicting the carry in to the lsb
  assign mod_pc_top_bits_de = pc_force | ((&pc_instr0_iss_i[7:4]) & (|pc_adjust[3:1]));

  // Evaluate whether tagged addresses are in use, and the top PC byte should
  // be ignored
  assign zero_top_byte = ~aarch64_state_i                                                                                    |
                         ((dpu_exception_level_i[1] == 1'b0)  & tlb_d_tcr_el1_tbi_i[0] & ~raw_pc_instr0_de[55] & ~in_halt_i) |
                         ((dpu_exception_level_i    == 2'b10) & tlb_d_tcr_el2_tbi0_i                           & ~in_halt_i) |
                         ((dpu_exception_level_i    == 2'b11) & tlb_d_tcr_el3_tbi0_i                           & ~in_halt_i);
  assign set_top_byte  = aarch64_state_i &
                         ~in_halt_i      &
                         ((dpu_exception_level_i[1] == 1'b0)  & tlb_d_tcr_el1_tbi_i[1] &  raw_pc_instr0_de[55]);

  // Assign the output signals
  assign pc_instr0_de_o[63:56] = (raw_pc_instr0_de[63:56] & {8{~zero_top_byte}}) | 
                                                            {8{set_top_byte}};

  assign pc_instr0_de_o[55:32] =  raw_pc_instr0_de[55:32] & {24{aarch64_state_i}};
  assign pc_instr0_de_o[31: 0] =  raw_pc_instr0_de[31: 0];

  assign mod_pc_top_bits_de_o = mod_pc_top_bits_de;

  assign thumb_instr0_de_o = thumb;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
  `ifdef ARM_ASSERT_ON

  //--------------------------------------------------------------------------
  // OVL_ASSERT: ovl_valid_instr_iss_illegal
  // The syntax of the valid_instr_iss signals is:
  //   valid_instr_iss_i[0] = asserted when one or two instructions issued
  //   valid_instr_iss_i[1] = asserted when two instructions issued
  // This OVL checks for the illegal combination valid_instr_iss_i == 2'b10
  //--------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal valid_instrs_iss_i value.")
    ovl_valid_instrs_iss_illegal (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr (valid_instrs_iss_i == 2'b10));
  // OVL_ASSERT_END

  `endif // ARM_ASSERT_ON


endmodule // ca53dpu_de_pc

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
