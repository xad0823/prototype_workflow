//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : ETM Instruction interface
//------------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"
`include "ca53_dpu_etm_defs.v"

module ca53dpu_etmif `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                         clk,
  input  wire                         reset_n,
  input  wire                         po_reset_n,
  input  wire                         DFTSE,
  input  wire                         etm_if_en_i,
  input  wire                   [1:0] valid_instrs_wr_i,
  input  wire                         end_instr_no_quash_wr_i,
  input  wire                  [63:1] pc_instr0_wr_i,               // Program counter
  input  wire                  [63:1] pc_instr0_ret_i,              // Program counter
  input  wire                         cpsr_tbit_ret_i,              // Current CPSR T-bit value
  input  wire                   [4:0] cpsr_mode_ret_i,              // Current CPSR mode value
  input  wire                   [1:0] dpu_exception_level_i,        // Current exception level
  input  wire                         size_instr0_wr_i,             // Size of instr0
  input  wire                         size_instr1_wr_i,             // Size of instr1
  input  wire                         size_instr0_ret_i,            // Size of instr0
  input  wire                         size_instr1_ret_i,            // Size of instr1
  input  wire                   [1:0] isa_instr0_wr_i,              // ISA of instruction(s) in wr-stage
  input  wire                   [1:0] isa_instr0_ret_i,             // ISA of instruction(s) in ret-stage
  input  wire                         quash_wr_i,                   // Transaction is quashed in Wr-stage.
  input  wire                         quash_slot0_wr_i,             // Transaction is quashed in Wr-stage.
  input  wire                         slot0_br_flush_wr_i,          // A slot 0 branch has flushed
  input  wire                         isb_wr_i,
  input  wire                         expt_rtn_wr_i,                // An exception return instruction has completed in Wr
  input  wire                         dpu_valid_branch_instr_wr_i,  // Indicate branch pipeline is valid
  input  wire                         slot1_branch_wr_i,            // Branch is in slot 1
  input  wire                         br_direct_wr_i,               // Indicate branch is direct/indirect
  input  wire                         br_pred_takenness_wr_i,
  input  wire                         mis_predicted_branch_wr_i,
  input  wire                         br_call_wr_i,
  input  wire                         dpu_fe_valid_ret_i,           // IFU flush force (indirect Br), start fetching from new addr
  input  wire                  [63:1] dpu_fe_addr_opa_ret_i,        // Force address operand A from indirect branch
  input  wire                  [17:1] dpu_fe_addr_opb_ret_i,        // Force address operand B from indirect branch
  input  wire                  [27:1] dpu_fe_addr_opb_wr_i,         // Operand-B of Wr stage force
  input  wire                         etm_trace_expt_i,             // ETM traceable exception
  input  wire                         etm_trace_dbgentry_i,         // Debug entry event
  input  wire                         expt_dbgexit_i,               // Debug exit event
  input  wire                         expt_slot1_ret_i,             // Exception occurred on slot 1 instruction
  input  wire                         stall_wr_i,
  input  wire [`CA53_EXPT_TYPE_W-1:0] expt_type_i,
  input  wire                   [4:0] expt_cpsr_mode_ret_i,         // Mode exception is taken in
  input  wire                         dbgdscr_halted_i,
  input  wire                         ns_state_i,                   // Core is in non-secure state
  input  wire                         dbg_non_inv_perm_us_i,        // Non-invasive debugging is permitted (unsynced)
  input  wire                         dbg_non_inv_perm_synced_i,    // Non-invasive debugging is permitted (synced)
  // Outputs
  output wire                         dpu_wpt_valid_o,
  output wire                  [63:1] dpu_wpt_addr_o,
  output wire                  [63:1] dpu_wpt_target_addr_opa_o,
  output wire                  [27:1] dpu_wpt_target_addr_opb_o,
  output wire                         dpu_wpt_advance_o,
  output wire                         dpu_wpt_range_o,
  output wire                   [2:0] dpu_wpt_type_o,
  output wire                         dpu_wpt_link_o,
  output wire                         dpu_wpt_taken_o,
  output wire                   [1:0] dpu_wpt_target_isa_o,
  output wire                         dpu_wpt_t32_nt16_o,
  output wire                   [3:0] dpu_wpt_exception_type_o,
  output wire                         dpu_wpt_non_secure_o,
  output wire                   [3:0] dpu_wpt_exlevel_o,
  output wire                         dpu_wpt_prohibited_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg         etmif_enabled;
  reg   [3:0] wpt_exception_type;
  reg         wpt_valid;
  reg   [2:0] wpt_type;
  reg   [4:1] wpt_addr_offset_inst;
  reg   [4:1] wpt_addr_offset_expt;
  reg   [4:1] wpt_target_offset;
  reg         wpt_size;
  reg         wpt_taken;
  reg         wpt_link;
  reg         wpt_range;
  reg         wpt_advance;
  reg         set_slot1_advance;
  reg         slot0_traced;
  reg         wpt_instr0_dual;
  reg         mispred_ret;
  reg  [63:1] wpt_addr;
  reg         etmif_prohib;
  reg   [3:0] wpt_exlevel;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        clk_etmif;
  wire        etmif_stop;
  wire        wr_instr_valid;
  wire        direct_br_wr;
  wire        indirect_br_wr;
  wire        expt_return_wr;
  wire        isb_valid_wr;
  wire        nxt_wpt_valid;
  wire  [2:0] nxt_wpt_type;
  wire        nxt_wpt_instr1;
  wire        nxt_wpt_size;
  wire        nxt_wpt_taken;
  wire        nxt_wpt_link;
  wire        nxt_wpt_range;
  wire        nxt_wpt_instr0_dual;
  wire        expt_trace;
  wire        expt_trace_n;
  wire        reset_expt_trace;
  wire        nxt_wpt_advance;
  wire        nxt_set_slot1_advance;
  wire        nxt_slot0_traced;
  wire        nxt_etmif_prohib;
  wire        non_inv_perm;
  wire        wpt_prohibited;
  wire        sel_addr_instr;
  wire [48:1] wpt_base_addr;
  wire  [4:1] wpt_addr_offset;
  wire [48:1] wpt_addr_nopabort;
  wire [63:1] raw_nxt_wpt_addr;
  wire [63:1] nxt_wpt_addr;
  wire        sel_target_addr;
  wire        sel_target_force_ret;
  wire        sel_target_force_wr;
  wire        sel_target_instr_wr;
  wire [63:1] wpt_target_opa;
  wire [27:1] wpt_target_opb;
  wire  [1:0] wpt_target_isa;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // The ETM interface can be gated using the ETM power up signal
  always @(posedge clk or negedge po_reset_n)
    if (~po_reset_n)
      etmif_enabled <= 1'b0;
    else
      etmif_enabled <= etm_if_en_i;

  ca53_cell_inter_clkgate u_inter_clkgate_etmif (
    .clk_i         (clk),
    .clk_enable_i  (etmif_enabled),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_etmif)
  );

  assign etmif_stop = etmif_enabled & ~etm_if_en_i;

  // ------------------------------------------------------
  // Logic in Wr stage of traced instruction
  // ------------------------------------------------------

  assign wr_instr_valid = etmif_enabled & valid_instrs_wr_i[0] & ~stall_wr_i & ~quash_slot0_wr_i;

  assign direct_br_wr   = wr_instr_valid & dpu_valid_branch_instr_wr_i &  br_direct_wr_i;
  assign indirect_br_wr = wr_instr_valid & dpu_valid_branch_instr_wr_i & ~br_direct_wr_i & ~expt_rtn_wr_i;
  assign expt_return_wr = wr_instr_valid & expt_rtn_wr_i;
  assign isb_valid_wr   = wr_instr_valid & isb_wr_i;

  assign nxt_wpt_valid = (((direct_br_wr | indirect_br_wr | isb_valid_wr | expt_return_wr |
                            etm_trace_expt_i | etm_trace_dbgentry_i) & ~dbgdscr_halted_i) | expt_dbgexit_i) & etm_if_en_i;

  assign nxt_wpt_type = ({3{direct_br_wr}}          & `CA53_ETM_WPT_DIRECTBRANCH) |
                        ({3{indirect_br_wr}}        & `CA53_ETM_WPT_INDIRECT)     |
                        ({3{isb_valid_wr}}          & `CA53_ETM_WPT_ISB)          |
                        ({3{expt_return_wr}}        & `CA53_ETM_WPT_EXCP_RETURN)  |
                        ({3{etm_trace_expt_i &
                            ~etm_trace_dbgentry_i}} & `CA53_ETM_WPT_EXCEPTION)    |
                        ({3{etm_trace_dbgentry_i}}  & `CA53_ETM_WPT_DBGENTRY)     |
                        ({3{expt_dbgexit_i}}        & `CA53_ETM_WPT_DBGEXIT);

  assign nxt_wpt_taken = wpt_prohibited   ? 1'b1                                                 :
                         (direct_br_wr   |
                          indirect_br_wr |
                          isb_valid_wr   |
                          expt_return_wr) ? (br_pred_takenness_wr_i ^ mis_predicted_branch_wr_i) :
                                            1'b1;

  assign nxt_wpt_link  = ~wpt_prohibited & (direct_br_wr | indirect_br_wr) & br_call_wr_i;

  assign nxt_wpt_instr1 = (etm_trace_expt_i | etm_trace_dbgentry_i | expt_dbgexit_i)
                                            ? (etmif_enabled & (expt_slot1_ret_i | (expt_type_i == `CA53_EXPT_TYPE_CALL)))
                                            : (etmif_enabled & slot1_branch_wr_i);

  assign nxt_wpt_instr0_dual = etmif_enabled & valid_instrs_wr_i[1] & ~nxt_wpt_instr1 & ~slot0_br_flush_wr_i;

  assign nxt_wpt_size = nxt_wpt_instr1 ? size_instr1_wr_i : size_instr0_wr_i;

  assign reset_expt_trace = etm_trace_expt_i & (expt_type_i == `CA53_EXPT_TYPE_RESET);

  assign nxt_wpt_range = ~(wpt_prohibited | expt_dbgexit_i | reset_expt_trace);

  assign expt_trace   = etmif_enabled &  (etm_trace_expt_i | etm_trace_dbgentry_i);
  assign expt_trace_n = etmif_enabled & ~(etm_trace_expt_i | etm_trace_dbgentry_i);

  always @*
    case ({isa_instr0_wr_i, nxt_wpt_instr1})
      3'b00_0: wpt_addr_offset_inst =                    4'b1100; // A32 slot 0:                -8
      3'b00_1: wpt_addr_offset_inst =                    4'b1110; // A32 slot 1:                -4
      3'b01_0: wpt_addr_offset_inst =                    4'b1110; // T32 slot 0:                -4
      3'b01_1: wpt_addr_offset_inst = size_instr0_wr_i ? 4'b0000  // T32 slot 1, slot 0 32-bit:  0
                                                       : 4'b1111; // T32 slot 1, slot 0 16-bit: -2
      3'b10_0: wpt_addr_offset_inst =                    4'b0000; // A64 slot 0:                 0
      3'b10_1: wpt_addr_offset_inst =                    4'b0010; // A64 slot 1:                +4
      default: wpt_addr_offset_inst =                    4'bxxxx;
    endcase

  always @*
    case ({expt_slot1_ret_i, (expt_type_i == `CA53_EXPT_TYPE_CALL), (expt_slot1_ret_i ? isa_instr0_wr_i : isa_instr0_ret_i)})
      4'b0_0_00: wpt_addr_offset_expt =                     4'b1100; // A32 slot 0:              -8
      4'b0_0_01: wpt_addr_offset_expt =                     4'b1110; // T32 slot 0:              -4
      4'b0_0_10: wpt_addr_offset_expt =                     4'b0000; // A64 slot 0:               0

      4'b0_1_00: wpt_addr_offset_expt =                     4'b1110; // A32 slot 0 call:         -4
      4'b0_1_01: wpt_addr_offset_expt = size_instr0_ret_i ? 4'b0000  // T32 slot 0 call 32-bit:   0
                                                          : 4'b1111; // T32 slot 0 call 16-bit:  -2
      4'b0_1_10: wpt_addr_offset_expt =                     4'b0010; // A64 slot 0 call:         +4
 
      // Slot 1 exception offsets are relative to the following instruction, as is the ISA
      4'b1_0_00: wpt_addr_offset_expt = size_instr1_ret_i ? 4'b1010  // A32 slot 1 32-bit:      -12
                                                          : 4'b1011; // A32 slot 1 16-bit:      -10
      4'b1_0_01: wpt_addr_offset_expt = size_instr1_ret_i ? 4'b1100  // T32 slot 1 32-bit:       -8
                                                          : 4'b1101; // T32 slot 1 16-bit:       -6
      4'b1_0_10: wpt_addr_offset_expt =                     4'b1110; // A64 slot 1:              -4
      default:   wpt_addr_offset_expt =                     4'bxxxx;
    endcase

  assign wpt_base_addr = ({48{expt_trace   & ~expt_slot1_ret_i}} & pc_instr0_ret_i[48:1]) |
                         ({48{expt_trace_n |  expt_slot1_ret_i}} & pc_instr0_wr_i[48:1]);

  assign wpt_addr_offset = ({4{expt_trace}}   & wpt_addr_offset_expt) |
                           ({4{expt_trace_n}} & wpt_addr_offset_inst);

  assign wpt_addr_nopabort = wpt_base_addr[48:1] + { {45{wpt_addr_offset[4]}}, wpt_addr_offset[3:1]};

  assign raw_nxt_wpt_addr = (expt_trace & ~expt_slot1_ret_i & isa_instr0_ret_i[1] &
                             (expt_type_i != `CA53_EXPT_TYPE_CALL))                ? pc_instr0_ret_i[63:1]
                                                                                   : { {16{wpt_addr_nopabort[48]}}, wpt_addr_nopabort[47:1]};

  assign sel_addr_instr = ~reset_expt_trace & ~wpt_prohibited & (nxt_wpt_type != `CA53_ETM_WPT_DBGEXIT);

  assign nxt_wpt_addr[63:32] = ({32{sel_addr_instr & isa_instr0_wr_i[1]}} & raw_nxt_wpt_addr[63:32]);
  assign nxt_wpt_addr[31: 1] = ({31{sel_addr_instr}}                      & raw_nxt_wpt_addr[31: 1]);

  always @(posedge clk_etmif or negedge reset_n)
    if (~reset_n)
      wpt_valid <= 1'b0;
    else
      wpt_valid <= nxt_wpt_valid;

  always @(posedge clk_etmif)
    if (nxt_wpt_valid) begin
      wpt_type        <= nxt_wpt_type;
      wpt_taken       <= nxt_wpt_taken;
      wpt_link        <= nxt_wpt_link;
      wpt_size        <= nxt_wpt_size;
      wpt_range       <= nxt_wpt_range;
      wpt_addr        <= nxt_wpt_addr;
      wpt_instr0_dual <= nxt_wpt_instr0_dual;
      mispred_ret     <= mis_predicted_branch_wr_i;
    end

  assign nxt_etmif_prohib = (wpt_valid | etmif_stop) ? (etmif_stop | wpt_prohibited)
                                                     : etmif_prohib;

  always @(posedge clk_etmif or negedge po_reset_n)
    if (~po_reset_n)
      etmif_prohib <= 1'b1;
    else
      etmif_prohib <= nxt_etmif_prohib;

  assign nxt_wpt_advance = (wpt_advance & ~wpt_valid) |
                           (etmif_enabled & (end_instr_no_quash_wr_i | quash_wr_i) & ~stall_wr_i & 
                            ((~quash_slot0_wr_i & (~nxt_wpt_valid | nxt_wpt_instr1) & ~slot0_traced) |  // Slot 0
                             (~quash_wr_i & valid_instrs_wr_i[1] & ~nxt_wpt_valid))) |                  // Slot 1
                           set_slot1_advance;

  assign nxt_set_slot1_advance = etmif_enabled & end_instr_no_quash_wr_i & ~stall_wr_i & ~quash_wr_i & nxt_wpt_valid & nxt_wpt_instr0_dual;
  
  assign nxt_slot0_traced = ((etmif_enabled & nxt_wpt_valid & ~nxt_wpt_instr1) | slot0_traced) &
                            ~(end_instr_no_quash_wr_i & ~stall_wr_i) & ~quash_wr_i & ~slot0_br_flush_wr_i;

  always @(posedge clk_etmif or negedge reset_n)
    if (~reset_n) begin
      wpt_advance       <= 1'b0;
      set_slot1_advance <= 1'b0;
      slot0_traced      <= 1'b0;
    end else begin
      wpt_advance       <= nxt_wpt_advance;
      set_slot1_advance <= nxt_set_slot1_advance;
      slot0_traced      <= nxt_slot0_traced;
    end


  // ------------------------------------------------------
  // Logic in Ret stage of traced instruction
  // ------------------------------------------------------

  // If this waypoint is from a Ret-stage force, must use the unsyncronised
  // version of dbg_non_inv_perm, as the force will synchronize the new value
  assign non_inv_perm = dpu_fe_valid_ret_i ? dbg_non_inv_perm_us_i : dbg_non_inv_perm_synced_i;

  assign wpt_prohibited = wpt_valid ? ~non_inv_perm : etmif_prohib;

  always @*
    case (expt_type_i)
      `CA53_EXPT_TYPE_RESET:            wpt_exception_type = `CA53_ETM_RESET_EXCP;
      `CA53_EXPT_TYPE_WPT:              wpt_exception_type = expt_cpsr_mode_ret_i[4] ? `CA53_ETM_DATA_FAULT_EXCP : `CA53_ETM_DATA_DEBUG_EXCP;
      `CA53_EXPT_TYPE_DATA:             wpt_exception_type = `CA53_ETM_DATA_FAULT_EXCP;
      `CA53_EXPT_TYPE_FIQ:              wpt_exception_type = `CA53_ETM_FIQ_EXCP;
      `CA53_EXPT_TYPE_IRQ:              wpt_exception_type = `CA53_ETM_IRQ_EXCP;
      `CA53_EXPT_TYPE_IMPRECISE:        wpt_exception_type = `CA53_ETM_SYS_ERR_EXCP;
      `CA53_EXPT_TYPE_INSTR_FAULT:      wpt_exception_type = `CA53_ETM_INST_FAULT_EXCP;
      `CA53_EXPT_TYPE_CALL:             wpt_exception_type = `CA53_ETM_CALL_EXCP;
      `CA53_EXPT_TYPE_TRAP,
      `CA53_EXPT_TYPE_COND_TRAP,
      `CA53_EXPT_TYPE_COND_TRAP_OR_UND,
      `CA53_EXPT_TYPE_WFI,
      `CA53_EXPT_TYPE_WFE:              wpt_exception_type = `CA53_ETM_TRAP_EXCP;
      `CA53_EXPT_TYPE_SP_ALIGNMENT:     wpt_exception_type = `CA53_ETM_ALIGN_EXCP;
      `CA53_EXPT_TYPE_PC_ALIGNMENT:     wpt_exception_type = expt_cpsr_mode_ret_i[4] ? `CA53_ETM_INST_FAULT_EXCP : `CA53_ETM_ALIGN_EXCP;
      `CA53_EXPT_TYPE_DEBUG_HLT:        wpt_exception_type = `CA53_ETM_DEBUG_HALT;
      `CA53_EXPT_TYPE_DEBUG_EXPT:       wpt_exception_type = expt_cpsr_mode_ret_i[4] ? `CA53_ETM_INST_FAULT_EXCP : `CA53_ETM_INST_DEBUG_EXCP;
      default:                          wpt_exception_type = `CA53_ETM_EXPT_TYPE_X;
    endcase

  always @*
    case ({wpt_target_isa[1:0], wpt_instr0_dual})
      3'b00_0: wpt_target_offset = 4'b1100;                               // A32: -8
      3'b00_1: wpt_target_offset = 4'b1010;                               // A32: -12
      3'b01_0: wpt_target_offset = 4'b1110;                               // T32: -4
      3'b01_1: wpt_target_offset = size_instr1_ret_i ? 4'b1100 : 4'b1101; // T32: -8/-6
      3'b10_0: wpt_target_offset = 4'b0000;                               // A64:  0
      3'b10_1: wpt_target_offset = 4'b1110;                               // A64: -4
      default: wpt_target_offset = 4'bxxxx;
    endcase

  assign sel_target_addr = ~wpt_prohibited & (wpt_type != `CA53_ETM_WPT_DBGENTRY);

  assign sel_target_force_ret = etmif_enabled & sel_target_addr &  dpu_fe_valid_ret_i;
  assign sel_target_force_wr  = etmif_enabled & sel_target_addr & ~dpu_fe_valid_ret_i &  mispred_ret;
  assign sel_target_instr_wr  = etmif_enabled & sel_target_addr & ~dpu_fe_valid_ret_i & ~mispred_ret;

  assign wpt_target_opa = ({63{sel_target_force_ret}} & dpu_fe_addr_opa_ret_i[63:1])                                                               |
                          ({63{sel_target_force_wr}}  & { {16{pc_instr0_ret_i[48]}}, pc_instr0_ret_i[47:2], pc_instr0_ret_i[1] & cpsr_tbit_ret_i}) |
                          ({63{sel_target_instr_wr}}  & pc_instr0_wr_i[63:1]);

  assign wpt_target_opb = ({27{sel_target_force_ret}} & { {10{dpu_fe_addr_opb_ret_i[17]}}, dpu_fe_addr_opb_ret_i[17:1]}) |
                          ({27{sel_target_force_wr}}  & {                                  dpu_fe_addr_opb_wr_i[27:1]})  |
                          ({27{sel_target_instr_wr}}  & { {23{wpt_target_offset[4]}},      wpt_target_offset[4:1]});

  assign wpt_target_isa = {~cpsr_mode_ret_i[4], cpsr_tbit_ret_i} & {2{~wpt_prohibited}};

  always @*
    case (dpu_exception_level_i)
      2'b00:    wpt_exlevel = 4'b0001;
      2'b01:    wpt_exlevel = 4'b0010;
      2'b10:    wpt_exlevel = 4'b0100;
      2'b11:    wpt_exlevel = 4'b1000;
      default:  wpt_exlevel = 4'bxxxx;
    endcase

  // ------------------------------------------------------
  // Output aliasing
  // ------------------------------------------------------

  assign dpu_wpt_valid_o            = wpt_valid & ~(wpt_prohibited & etmif_prohib);
  assign dpu_wpt_addr_o             = wpt_addr;
  assign dpu_wpt_target_addr_opa_o  = wpt_target_opa;
  assign dpu_wpt_target_addr_opb_o  = wpt_target_opb;
  assign dpu_wpt_advance_o          = wpt_advance;
  assign dpu_wpt_range_o            = wpt_range;
  assign dpu_wpt_type_o             = wpt_type;
  assign dpu_wpt_link_o             = wpt_link;
  assign dpu_wpt_taken_o            = wpt_taken;
  assign dpu_wpt_target_isa_o       = wpt_target_isa;
  assign dpu_wpt_t32_nt16_o         = wpt_size;
  assign dpu_wpt_exception_type_o   = wpt_exception_type;
  assign dpu_wpt_non_secure_o       = ns_state_i;
  assign dpu_wpt_exlevel_o          = wpt_exlevel;
  assign dpu_wpt_prohibited_o       = wpt_prohibited;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  //ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_wpt_valid")
  u_ovl_x_nxt_wpt_valid (.clk       (clk_etmif),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (nxt_wpt_valid));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_dpu_etm_defs.v"
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
